package lab.neruno.flutter_posbank_sdk

import android.Manifest
import android.app.PendingIntent
import android.bluetooth.BluetoothDevice
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbEndpoint
import android.hardware.usb.UsbInterface
import android.hardware.usb.UsbManager
import android.os.Build
import androidx.core.app.ActivityCompat
import com.posbank.hardware.serial.SerialPortDevice
import com.posbank.hardware.serial.SerialPortFlowControl
import com.posbank.hardware.serial.SerialPortTimeout
import com.posbank.printer.PrinterConstants
import com.posbank.printer.PrinterDevice
import java.lang.UnsupportedOperationException

internal fun PrinterDevice.toMap(context: Context): Map<String, Any?> {
    return mapOf(
        "deviceName" to deviceName,
        "deviceType" to deviceType,
        "model" to model,
        "manufacturer" to manufacturer,
        "modelSimpleName" to modelSimpleName,
        "productID" to productID,
        "deviceContext" to run {
            var obj: Map<String, Any?>? = null
            when (val deviceContext = this.deviceContext) {
                is UsbDevice -> {
                    val device: UsbDevice = deviceContext

                    obj = device.toMap(context)
                }
                is SerialPortDevice -> {
                    val device: SerialPortDevice = deviceContext

                    obj = device.toMap()
                }
                is BluetoothDevice -> {
                    val device: BluetoothDevice = deviceContext

                    obj = device.toMap(context)
                }
            }

            obj
        }
    )
}

internal fun SerialPortDevice.toMap(): Map<String, Any?> {
    val flowControl: SerialPortFlowControl = this.flowControl
    val timeout: SerialPortTimeout = this.timeout
    return mapOf(
        "deviceName" to deviceName,
        "windowName" to windowName,
        "description" to description,
        "deviceID" to deviceID,
        "baudrate" to baudrate,
        "dataBits" to dataBits.bitLength,
        "stopBits" to stopBits.value,
        "parityBits" to parityBits.ordinal,
        "flowControl" to flowControl.ordinal,
        "timeout" to with (timeout) {
            mapOf(
                "inter_byte_timeout" to inter_byte_timeout,
                "read_timeout_constant" to read_timeout_constant,
                "read_timeout_multiplier" to read_timeout_multiplier,
                "write_timeout_constant" to write_timeout_constant,
                "write_timeout_multiplier" to write_timeout_multiplier
            )
        }
    )
}

internal fun UsbDevice.toMap(applicationContext: Context): Map<String, Any?> {
    val usbManager = applicationContext.getSystemService(UsbManager::class.java)

    val hasPermission = usbManager.hasPermission(this)

    val interfaceData = mutableListOf<Map<String, Any?>>()
    for (i in 0 until interfaceCount) {
        val usbInterface: UsbInterface = getInterface(i)

        val endpointData = mutableListOf<Map<String, Any?>>()
        for (j in 0 until usbInterface.endpointCount) {
            val endpoint: UsbEndpoint = usbInterface.getEndpoint(j)

            endpointData.add(
                mapOf(
                    "address" to endpoint.address,
                    "endpointNumber" to endpoint.endpointNumber,
                    "direction" to endpoint.direction,
                    "attributes" to endpoint.attributes,
                    "type" to endpoint.type,
                    "maxPacketSize" to endpoint.maxPacketSize,
                    "interval" to endpoint.interval
                )
            )
        }

        interfaceData.add(
            mapOf(
                "id" to usbInterface.id,
                "alternateSetting" to usbInterface.alternateSetting,
                "name" to usbInterface.name,
                "interfaceClass" to usbInterface.interfaceClass,
                "interfaceSubclass" to usbInterface.interfaceSubclass,
                "interfaceProtocol" to usbInterface.interfaceProtocol,
                "endpoints" to endpointData.toList(),
            )
        )
    }

    return mapOf(
        "deviceName" to deviceName,
        "manufacturerName" to manufacturerName,
        "productName" to productName,
        "version" to version,
        "serialNumber" to serialNumber,
        "deviceId" to deviceId,
        "vendorId" to vendorId,
        "productId" to productId,
        "deviceClass" to deviceClass,
        "deviceSubclass" to deviceSubclass,
        "deviceProtocol" to deviceProtocol,
        "configurationCount" to configurationCount,
        "interfaces" to interfaceData.toList(),
        "hasPermission" to hasPermission
    )
}

internal fun UsbDevice.requestPermission(applicationContext: Context) {
    val usbManager = applicationContext.getSystemService(UsbManager::class.java)

    usbManager.requestPermission(
        this,
        PendingIntent.getBroadcast(
            applicationContext,
            0,
            Intent(PrinterConstants.PRINTER_USB_PERMISSION),
            PendingIntent.FLAG_IMMUTABLE
        ),
    )
}

internal fun BluetoothDevice.toMap(context: Context): Map<String, Any?> {

    val btConnectGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        ActivityCompat.checkSelfPermission(
            context,
            Manifest.permission.BLUETOOTH_CONNECT
        ) == PackageManager.PERMISSION_GRANTED
    } else {
        false
    }

    return mapOf(
        "address" to address,
        "name" to if (btConnectGranted) { name } else { null },
        "type" to if (btConnectGranted) { type } else { null },
        "alias" to if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && btConnectGranted) {
            alias
        } else { null },
        "bluetoothClass" to if (btConnectGranted) { bluetoothClass.let {
            mapOf<String, Any?>(
                "deviceClass" to it.deviceClass,
                "majorDeviceClass" to it.majorDeviceClass
            )
        } } else { null },
        "uuids" to uuids.map {
            with (it.uuid) {
                this.version()
                mapOf<String, Any?>(
                    "leastSignificantBits" to leastSignificantBits,
                    "mostSignificantBits" to mostSignificantBits,
                    "version" to version(),
                    "variant" to variant(),
                    "timestamp" to try { timestamp() } catch (ex: UnsupportedOperationException) { null },
                    "clockSequence" to try { clockSequence() } catch (ex: UnsupportedOperationException) { null },
                    "node" to try { node() } catch (ex: UnsupportedOperationException) { null },
                    "string" to toString()
                )
            }
        }.toList(),
        "bondState" to if (btConnectGranted) { bondState } else { null }
    )
}