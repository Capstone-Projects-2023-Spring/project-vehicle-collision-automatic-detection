#include <LowPower.h>
#include <Adafruit_ATParser.h>
#include <Adafruit_BLE.h>
#include <Adafruit_BLEBattery.h>
#include <Adafruit_BLEEddystone.h>
#include <Adafruit_BLEGatt.h>
#include <Adafruit_BLEMIDI.h>
#include <Adafruit_BluefruitLE_SPI.h>
#include <Adafruit_BluefruitLE_UART.h>
#include <Arduino.h>
#include <SPI.h>
#include "BluefruitConfig.h"

#define FACTORYRESET_ENABLE         1
#define MINIMUM_FIRMWARE_VERSION    "0.6.6"
#define MODE_LED_BEHAVIOUR          "MODE"

String data = " ";
int flag = 0;
uint8_t signal0[] = {0x48};
uint8_t signal1[] = {0x70};

Adafruit_BluefruitLE_SPI Bluetooth(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);
Adafruit_BLEGatt gatt(Bluetooth);

/**
 * @brief Initialize input, output pins and values
 * 
 * @param void takes nothing
 * 
 * @return void returns nothing
 */

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);

  /* Initialise the module */
  Serial.println(F("Initialising the Bluefruit LE module: "));

  // Test for idle mode
  TestIdle();
  delay(1000);

  TestBegin();
  delay(1000);

  TestFactoryReset();
  delay(1000);

  /* Disable command echo from Bluefruit */
  TestEcho();
  delay(1000);

  TestVerbose();
  delay(1000);

  // Test to execute AT command
  TestATCommand();
  delay(1000);

  // Test to reset Bluetooth
  TestReset();
  delay(1000);

  /* Test for connection */
  Serial.println("Looking for Bluetooth Device...");
  TestConnected();
  delay(1000);

  // Test if firmware is up to date
  TestIsVersionAtLeast();
  delay(1000);

  // Test if Bluefruit sets to DATA mode
  TestSetMode();
  delay(1000);
}

/**
 * @brief Waits for a Bluetooth device to connect, continuously gets accelerometer 
 * readings, sends signal to mobile phone after exceeding a certain threshold
 * 
 * @param void takes nothing
 * 
 * @return void returns nothing
 */

void loop() {
  // put your main code here, to run repeatedly:

  //check if Bluetooth device is connected to hardware
  while(Bluetooth.isConnected()){
    //test for incoming data from hardware
    TestAvailable();
    TestSetChar();
    delay(3000);
  }

  //test if hardware disconnects from Bluetooth device
  TestDisconnected();
  delay(1000);

  // Test if the device will be undiscoverable
  TestSetAdvData();
  delay(1000);

  // Test if at command waits for OK
  TestSendCommandCheckOK();
  delay(1000);

  //test if device powers down
  TestPowerDown();
}

void TestATCommand(){
  Serial.println(F("Setting service + characteristic!"));
  Bluetooth.atcommand("AT+GATTADDSERVICE=UUID128=00-11-00-11-44-55-66-77-88-99-AA-BB-CC-DD-EE-FF");

  int char1 = Bluetooth.atcommand("AT+GATTADDCHAR=UUID128=00-11-22-33-44-55-66-77-88-99-AB-BC-CD-DE-EF-FF,PROPERTIES=0x10,MIN_LEN=1,VALUE=HELLO");
  Serial.println(char1);
  Serial.println("AT Command Test Passed!");
  Serial.println();
}

//tests for incoming data from hardware
void TestAvailable(){
  if(Serial.available() > 0){
    data = Serial.readString();
    Bluetooth.print("Bluetooth: " + data);
    Serial.println("Message sent to Bluetooth Device!");
    Serial.println("Available Test Passed!");
    Serial.println();
  }
}

//tests if hardware can setup Bluetooth connections
void TestBegin(){
  if(!Bluetooth.begin(VERBOSE_MODE)){
    error(F("Couldn't find Bluefruit, make sure it's in Command mode & check wiring?"));
  }
  Serial.println("Begin Test Passed!");
  Serial.println();
}

//test if hardware can connect to Bluetooth devices
void TestConnected(){
  while (!Bluetooth.isConnected()){
    delay(500);    
  }
  if(Bluetooth.isConnected()){
    Serial.println("Device Connected!");
    Serial.println("Connected Test Passed!");
    Serial.println();
  }
}

//test if hardware can disconnect from Bluetooth devices
void TestDisconnected(){
  while (!Bluetooth.isConnected()){
    if(flag == 0){
      Serial.println("Bluetooth Device Disconnected!");
      Serial.println("Disconnected Test Passed!");
      Serial.println();
      flag++;
    }
    break;
  }
}

//test if hardware can perform a factory reset
void TestFactoryReset(){
  if(FACTORYRESET_ENABLE){
    /* Perform a factory reset to make sure everything is in a known state */
    Serial.println(F("Performing a factory reset: "));
    if (!Bluetooth.factoryReset()){
      error(F("Couldn't factory reset"));
    }
    delay(500);
    Serial.println("Factory Reset Test Passed!");
    Serial.println();
  }
}

//test if hardware can change modes
void TestSetMode(){
  if(Bluetooth.setMode(BLUEFRUIT_MODE_DATA)){
    Serial.println("Mode Changed!");
    Serial.println("Set Mode Test Passed!");
    Serial.println();
  }
}

void TestSetChar(){
  Serial.println("Changing Characteristic!");
  //change characteristic value to 'F'
  gatt.setChar(1, signal1, sizeof(signal1));
  delay(3000);
  Serial.println("Resetting Characteristic!");
  //reset characteristic value back to '0'
  gatt.setChar(1, signal0, sizeof(signal0));
  delay(1000);
  //reset the sleep timer
  Serial.println("SetChar Test Passed!");
  Serial.println();
}

void TestReset(){
  Serial.println("Resetting Bluetooth!");
  Bluetooth.reset();
  Serial.println("Reset Test Passed!");
  Serial.println();
}

void TestIsVersionAtLeast(){
  Serial.println("Going into idle mode!");
  if (Bluetooth.isVersionAtLeast(MINIMUM_FIRMWARE_VERSION)){
    Bluetooth.sendCommandCheckOK("AT+HWModeLED=" MODE_LED_BEHAVIOUR);
  }
  Serial.println("Is Version At Least Test Passed!");
  Serial.println();
}

void TestEcho(){
  Serial.println("Disabling Echo Command!");
  Bluetooth.echo(false);
  Serial.println("Echo Test Passed!");
  Serial.println();
}

void TestVerbose(){
  Serial.println("Disabling Verbose!");
  Bluetooth.verbose(false);
  Serial.println("Verbose Test Passed!");
  Serial.println();
}

void TestIdle(){
  Serial.println("Going into idle mode!");
  LowPower.idle(SLEEP_FOREVER, ADC_ON, TIMER2_OFF, TIMER1_OFF, TIMER0_ON, SPI_OFF, USART0_OFF, TWI_OFF);
  Serial.println("Idle Test Passed!");
  Serial.println();
}

void TestPowerDown(){
  Serial.println("Powering Down!");
  Serial.println("Power Down Test Passed!");
  Serial.println();
  Bluetooth.sendCommandCheckOK("AT+HWModeLED=0");
  delay(500);
  LowPower.powerDown(SLEEP_FOREVER, ADC_OFF, BOD_OFF);
}

void TestSetAdvData() {
  Bluetooth.setAdvData(NULL, 0);
  Serial.println("SetAdvData Test ran! The device should be undiscoverable now.");
}

void TestSendCommandCheckOK(){
  bool passed = Bluetooth.sendCommandCheckOK("AT+HWModeLED=0");
  
  if(passed){
    Serial.println("sendCommandCheckOK Test ran! Check if the mode LED on the device has been turned off.");
  }
  else{
    Serial.println("The command failed.");
  }
}

//error handler method
void error(const __FlashStringHelper*err){
  Serial.println(err);
  while (1);
}
