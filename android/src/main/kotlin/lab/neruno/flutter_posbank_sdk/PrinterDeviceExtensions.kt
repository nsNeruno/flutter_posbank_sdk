package lab.neruno.flutter_posbank_sdk

import com.posbank.hardware.serial.SerialPortDevice
import com.posbank.hardware.serial.SerialPortFlowControl
import com.posbank.hardware.serial.SerialPortTimeout
import com.posbank.printer.PrinterDevice

internal fun PrinterDevice.toMap(): Map<String, Any?> {
    return mapOf(
        "deviceName" to deviceName,
        "deviceType" to deviceType,
        "model" to model,
        "manufacturer" to manufacturer,
        "modelSimpleName" to modelSimpleName,
        "productID" to productID
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
        "dataBits" to dataBits,
        "stopBits" to stopBits,
        "parityBits" to parityBits,
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