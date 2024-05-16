package lab.neruno.flutter_posbank_sdk

import android.bluetooth.BluetoothDevice
import android.content.Context
import android.hardware.usb.UsbDevice
import android.os.Handler
import android.os.Looper
import android.os.Message
import com.posbank.hardware.serial.SerialPort
import com.posbank.hardware.serial.SerialPortDevice
import com.posbank.hardware.serial.SerialPortManager
import com.posbank.printer.Printer
import com.posbank.printer.PrinterConstants
import com.posbank.printer.PrinterDevice
import com.posbank.printer.PrinterManager

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.math.absoluteValue

/** FlutterPosbankSdkPlugin */
class FlutterPosbankSdkPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, Handler.Callback {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var printerManager: PrinterManager
  private var serialPort: SerialPort? = null
  private var printer: Printer? = null
  private lateinit var applicationContext: Context
  
  private var usbDevices: MutableList<UsbDevice> = mutableListOf()
  private var serialDevices: MutableList<SerialPortDevice> = mutableListOf()
  private var bluetoothDevices: MutableList<BluetoothDevice> = mutableListOf()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_posbank_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    when (call.method) {
      "startDiscovery" -> {
        val options = call.argument<Int>("options") ?: PrinterConstants.PRINTER_TYPE_SERIAL
        if (options.and(PrinterConstants.PRINTER_TYPE_SERIAL) == PrinterConstants.PRINTER_TYPE_SERIAL) {
          val devices: HashMap<String, SerialPortDevice>? = SerialPortManager.getDeviceList()
          devices?.let {
            printerManager.setSerialPorts(it.keys.toTypedArray())
          }
        }
        usbDevices.clear()
        serialDevices.clear()
        bluetoothDevices.clear()
        printerManager.startDiscovery(options)
        result.success(null)
      }
      "getSerialPortDeviceList" -> {
        val devices: HashMap<String, SerialPortDevice>? = SerialPortManager.getDeviceList()
        result.success(
          devices?.mapValues {
            it.value.toMap()
          }
        )
      }
      "setSerialPorts" -> {
        val ports = call.argument<List<String>>("ports")
        if (ports != null) {
          printerManager.setSerialPorts(ports.toTypedArray())
        }
        result.success(null)
      }
      "openSerialPortDevice" -> {
        val deviceName = call.argument<String>("deviceName")
        if (deviceName != null) {
          val device = SerialPortManager.getDeviceList()[deviceName]
          if (device != null) {
            serialPort = SerialPortManager.openDevice(device)
            result.success(null)
            return
          }
        }
        result.error("PosbankError", "Failed to open Serial Port Device for name $deviceName", null)
      }
      "getDevicesList" -> {
        result.success(
          printerManager.deviceList?.mapValues {
            it.value.toMap(applicationContext)
          }
        )
      }
      "getDevice" -> {
        val deviceName = call.argument<String>("deviceName")
        if (deviceName != null) {
          result.success(
            printerManager.deviceList?.get(deviceName)?.run { toMap(applicationContext) }
          )
        } else {
          result.success(null)
        }
      }
      "requestUsbDevicePermission" -> {
        val deviceId = call.argument<Int>("deviceId")
        val device = usbDevices.find { device ->
          device.deviceId == deviceId
        }

        device?.requestPermission(applicationContext)
        result.success(null)
      }
      "connectDevice" -> {
        val deviceName = call.argument<String>("deviceName")
        if (deviceName != null) {
          val device = printerManager.deviceList?.get(deviceName)
          if (device != null) {
            val printer = printerManager.connectDevice(device)
            if (printer != null) {
              val initialize = call.argument<Boolean>("initialize") ?: false
              this.printer?.disconnect()
              this.printer = printer
              if (initialize) {
                printer.initialize()
              }
              result.success(null)
              return
            }
          }
        }

        result.error("PosbankError", "Printer with name [$deviceName] not found", null)
      }
      "initializePrinter" -> {
        printer?.initialize()
        result.success(null)
      }
      "disconnectPrinter" -> {
        printer?.disconnect()
        printer = null
        result.success(null)
      }
      "shutdownPrinter" -> {
        printer?.shutDown()
        printer = null
        result.success(null)
      }
      "getPrinterStatus" -> {
        printer?.getStatus()
        result.success(if (printer != null) { null } else { -1 })
      }
      "lineFeed" -> {
        val lines = call.argument<Int>("lines")?.absoluteValue
        if (lines != null && lines > 0) {
          when (printer?.lineFeed(lines)) {
            PrinterConstants.PRINTER_RESULT_OK -> { result.success(null) }
            PrinterConstants.PRINTER_RESULT_ERR_NOT_SUPPORTED -> {
              result.error("PosbankError", "Line feed command not supported", null)
            }
            else -> {
              result.success(null)
            }
          }
        } else {
          result.success(null)
        }
      }
      "cutPaper" -> {
        val feeds = call.argument<Int>("feeds")?.absoluteValue
        when (if (feeds != null) { printer?.cutPaper(feeds) } else { printer?.cutPaper() }) {
          PrinterConstants.PRINTER_RESULT_OK -> { result.success(null) }
          PrinterConstants.PRINTER_RESULT_ERR_NOT_SUPPORTED -> {
            result.error("PosbankError", "Paper cut command not supported", null)
          }
          else -> { result.success(null) }
        }
      }
      "printText" -> {
        // TODO: Handle overload with Locale
        val text = call.argument<String>("text")
        val alignment = call.argument<Int>("alignment")?.absoluteValue ?: PrinterConstants.PRINTER_ALIGNMENT_LEFT
        val textAttribute = call.argument<Int>("textAttribute")?.absoluteValue ?: PrinterConstants.PRINTER_TEXT_ATTRIBUTE_FONT_A
        val textSize = call.argument<Int>("textSize")?.absoluteValue ?: (PrinterConstants.PRINTER_CHAR_SIZE_VERTICAL1 or PrinterConstants.PRINTER_CHAR_SIZE_HORIZONTAL1)
        when (printer?.printText(text, alignment, textAttribute, textSize)) {
          PrinterConstants.PRINTER_RESULT_OK -> {
            result.success(null)
          }
          PrinterConstants.PRINTER_RESULT_ERR_INVALID_ARGUMENT -> {
            result.error("PosbankError", "Invalid print argument(s)", null)
          }
          else -> {
            result.success(null)
          }
        }
      }
      "print1dBarcode" -> {
        val data = call.argument<String>("data")
        val barCodeSystem = call.argument<Int>("barCodeSystem")?.absoluteValue ?: PrinterConstants.PRINTER_BAR_CODE_UPC_A
        val alignment = call.argument<Int>("alignment")?.absoluteValue ?: PrinterConstants.PRINTER_ALIGNMENT_LEFT
        val width = call.argument<Int>("width")?.absoluteValue ?: 24
        val height = call.argument<Int>("height")?.absoluteValue ?: 12
        val charPosition = call.argument<Int>("charPosition") ?: PrinterConstants.PRINTER_HRI_CHARACTERS_BELOW_BAR_CODE
        when (printer?.print1dBarCode(data, barCodeSystem, alignment, width, height, charPosition)) {
          PrinterConstants.PRINTER_RESULT_OK -> { result.success(null) }
          PrinterConstants.PRINTER_RESULT_ERR_NOT_SUPPORTED -> {
            result.error("PosbankError", "Invalid print argument(s)", null)
          }
          else -> { result.success(null) }
        }
      }
      // TODO: Implement printQrCode
      // TODO: Implement printPdf417
      // TODO: Implement printBitmap
      "kickOutDrawer" -> {
        val connectorPin = call.argument<Boolean>("usePin5") ?: false
        val rsp = printer?.kickOutDrawer(
          if (connectorPin) {
            PrinterConstants.PRINTER_CASH_DRAWER_CONNECTOR_PIN_2
          } else {
            PrinterConstants.PRINTER_CASH_DRAWER_CONNECTOR_PIN_1
          }
        )
        when (rsp) {
          PrinterConstants.PRINTER_RESULT_OK -> { result.success(null) }
          PrinterConstants.PRINTER_RESULT_ERR_NOT_SUPPORTED -> {
            result.error("PosbankError", "Invalid Drawer operation", null)
          }
          else -> { result.success(null) }
        }
      }
      "executeDirectIO" -> {
        val bytesData = call.argument<ByteArray>("bytesData")
        if (bytesData != null) {
          when (printer?.executeDirectIO(bytesData)) {
            PrinterConstants.PRINTER_RESULT_OK -> { result.success(null) }
            PrinterConstants.PRINTER_RESULT_ERR_NOT_SUPPORTED -> {
              result.error("PosbankError", "Invalid command", null)
            }
            else -> { result.success(null) }
          }
        } else {
          result.success(null)
        }
      }
      "printSelfTest" -> {
        when (printer?.printSelfTest()) {
          PrinterConstants.PRINTER_RESULT_OK -> { result.success(null) }
          PrinterConstants.PRINTER_RESULT_ERR_NOT_SUPPORTED -> {
            result.error("PosbankError", "Self Test command not supported", null)
          }
          else -> { result.success(null) }
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  // BEGIN: ActivityAware Implementation
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    val context = binding.activity.applicationContext
    val looper = Looper.getMainLooper()
    val handler = Handler(looper, this)
    printerManager = PrinterManager(context, handler, looper)

    applicationContext = context
  }

  override fun onDetachedFromActivityForConfigChanges() { /* No-op */ }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) { /* No-op */ }

  override fun onDetachedFromActivity() { /* No-op */ }

  // END: ActivityAware Implementation

  // BEGIN: Handler.Callback
  override fun handleMessage(msg: Message): Boolean {

    var objKey = "obj"
    val obj = msg.obj.let {

      var obj: Map<String, Any?>? = null

      if (it is PrinterDevice) {
        when (val deviceContext = it.deviceContext) {
          is UsbDevice -> {
            val device: UsbDevice = deviceContext

            obj = device.toMap(applicationContext)
            objKey = "usb"

            usbDevices.add(device)
          }
          is SerialPortDevice -> {
            val device: SerialPortDevice = deviceContext

            obj = device.toMap()
            objKey = "serial"

            serialDevices.add(device)
          }
          is BluetoothDevice -> {
            val device: BluetoothDevice = deviceContext

            obj = device.toMap(applicationContext)
            objKey = "bluetooth"

            bluetoothDevices.add(device)
          }
        }
      }

      obj
    }

    val payload = mapOf(
      "what" to msg.what,
      "arg1" to msg.arg1,
      "arg2" to msg.arg2,
      "data" to mapOf<String, Any?>(
        *with (msg.data) {
          keySet().map {
            Pair(it, this.getString(it) ?: this.getInt(it))
          }
        }.toTypedArray()
      ),
      objKey to obj
    )

    channel.invokeMethod(
      "onPrinterMessage",
      payload
    )

    return true
  }
  // END: Handler.Callback
}
