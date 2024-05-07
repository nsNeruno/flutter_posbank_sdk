enum PrinterType {
  unknown._(0x0,),
  bluetooth._(0x1,),
  network._(0x2,),
  usb._(0x4,),
  serial._(0x8,);

  const PrinterType._(this.value,);

  final int value;
}

enum PrinterState {
  none,
  connecting,
  connected,
}

class PrinterMessage {

  PrinterMessage._();

  static const paramUnknown = -1;
  static const stateChanged = 0x1;
  static const connSucceeded = 0x2;
  static const connFailed = 0x03;
  static const connLost = 0x04;
  static const connClosed = 0x05;
  static const dataReceived = 0x10;
  static const dataWriteCompleted = 0x11;

  /// TBD
  static const deviceName = 0x20;
  static const toast = 0x2F;

  /// TBD
  static const completeProcessBitmap = 0x31;
  static const discoveryStarted = 0x3E;
  static const discoveryFinished = 0x4F;

  /// Unused
  static const deviceSet = 0x40;
  static const usbDeviceSet = 0x41;
  static const serialDeviceSet = 0x43;
  static const bluetoothDeviceSet = 0x44;
  static const networkDeviceSet = 0x45;

  /// TBD
  static const response = 0x5F;

  static const errorInvalidArgument = 0x80;
  static const errorOutOfMemory = 0x81;
  static const errorNvMemoryCapacity = 0x82;

  /// Unused
  static const errorClassNotFound = 0x83;

  static const errorCmdNotSupported = 0x84;
}

class PrinterProcess {

  PrinterProcess._();

  static const none = 0x00;
  static const initialize = 0x01;
  static const getStatus = 0x03;
  static const getPrinterId = 0x06;
  static const autoStatusBack = 0x07;
  static const getCodePage = 0x08;
  static const executeDirectIO = 0x09;
  static const setSingleByteFont = 0x0A;
  static const setDoubleByteFont = 0x0B;
  static const getNvImageKeyCodes = 0x12;
  static const defineNvImage = 0x13;
  static const removeNvImage = 0x14;
  static const updateFirmware = 0x15;
  static const connected = 0x16;
  static const kickOutCashDrawer = 0x20;
}

enum PrinterStatus {
  normal._(0x00,),
  coverOpen._(0x04,),
  paperFed._(0x08,),
  paperNearEnd._(0x0C,),
  // printingStopped._(0x20,),
  // errorOccurred._(0x40,),
  paperNotPresent._(0x60,);

  const PrinterStatus._(this.value,);

  final int value;
}

enum PrinterAlignment {
  left,
  center,
  right,
}

enum PrinterTextAttribute {
  fontA._(0x00,),
  fontB._(0x01,),
  fontC._(0x02,),
  underline1DotThick._(0x04,),
  underline2DotThick._(0x08,),
  emphasized._(0x10,),
  reverse._(0x20,),
  reverseOrder._(0x40,);

  const PrinterTextAttribute._(this.value,);

  final int value;
}

enum PrinterCharSizeVertical {
  vertical1,
  vertical2,
  vertical3,
  vertical4,
  vertical5,
  vertical6,
  vertical7,
  vertical8,
}

enum PrinterCharSizeHorizontal {
  horizontal1._(0x00,),
  horizontal2._(0x10,),
  horizontal3._(0x20,),
  horizontal4._(0x30,),
  horizontal5._(0x40,),
  horizontal6._(0x50,),
  horizontal7._(0x60,),
  horizontal8._(0x70,);

  const PrinterCharSizeHorizontal._(this.value,);

  final int value;
}

enum PrinterBarCodeSystem {
  upcA._(0x41,),
  upcE._(0x42,),
  ean13._(0x43,),
  ean8._(0x44,),
  code39._(0x45,),
  itf._(0x46,),
  codabar._(0x47,),
  code93._(0x48,),
  code128._(0x49,);

  const PrinterBarCodeSystem._(this.value,);

  final int value;
}

enum PrinterHRICharacter {
  notPrinted,
  aboveBarCode,
  belowBarCode,
  aboveAndBelowBarCode,
}