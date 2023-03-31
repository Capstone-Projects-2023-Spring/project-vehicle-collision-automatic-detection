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

Adafruit_BluefruitLE_SPI Bluetooth(BLUEFRUIT_SPI_CS, BLUEFRUIT_SPI_IRQ, BLUEFRUIT_SPI_RST);

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
  Serial.print(F("Initialising the Bluefruit LE module test: "));

  TestBegin();

  TestFactoryReset();

  /* Disable command echo from Bluefruit */
  Bluetooth.echo(false);

  Bluetooth.verbose(false);

  /* Test for connection */
  Serial.println("Looking for Bluetooth Device...");
  TestConnected();

  // Change Mode LED Activity
  if (Bluetooth.isVersionAtLeast(MINIMUM_FIRMWARE_VERSION)){
    Bluetooth.sendCommandCheckOK("AT+HWModeLED=" MODE_LED_BEHAVIOUR);
  }

  // Test if Bluefruit sets to DATA mode
  TestSetMode();
}

/**
 * @brief Waits for a bluetooth device to connect, continuously gets accelerometer 
 * readings, sends signal to mobile phone after exceeding a certain threshold
 * 
 * @param void takes nothing
 * 
 * @return void returns nothing
 */

void loop() {
  // put your main code here, to run repeatedly:

  //check if bluetooth device is connected to hardware
  while(Bluetooth.isConnected()){
    //test for incoming data from hardware
    TestAvailable();
  }

  //test if hardware disconnects from bluetooth device
  TestDisconnected();
}

//tests for incoming data from hardware
void TestAvailable(){
  if(Serial.available() > 0){
    data = Serial.readString();
    Bluetooth.print("Bluetooth: " + data);
    Serial.println("Message sent to Bluetooth Device!");
    Serial.println("Available Test Passed!");
  }
}

//tests if hardware can setup bluetooth connections
void TestBegin(){
  if(!Bluetooth.begin(VERBOSE_MODE)){
    error(F("Couldn't find Bluefruit, make sure it's in Command mode & check wiring?"));
  }
  Serial.println("Begin Test Passed!");
}

//test if hardware can connect to bluetooth devices
void TestConnected(){
  while (!Bluetooth.isConnected()){
    delay(500);    
  }
  if(Bluetooth.isConnected()){
    Serial.println("Device Connected!");
    Serial.println("Connected Test Passed!");
  }
}

//test if hardware can disconnect from bluetooth devices
void TestDisconnected(){
  while (!Bluetooth.isConnected()){
    if(flag == 0){
      Serial.println("Bluetooth Device Disconnected!");
      Serial.println("Disconnected Test Passed!");
      flag++;
    }
    delay(500);
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
  }
}

//test if hardware can change modes
void TestSetMode(){
  if(Bluetooth.setMode(BLUEFRUIT_MODE_DATA)){
    Serial.println("Mode Changed!");
    Serial.println("Set Mode Test Passed!");
  }
}

//error handler method
void error(const __FlashStringHelper*err){
  Serial.println(err);
  while (1);
}