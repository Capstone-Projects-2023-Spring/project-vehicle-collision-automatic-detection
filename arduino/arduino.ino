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
int sleep = 0;
int start = 0;
const unsigned long interval = 60000;
unsigned long previousMillis = 0;

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
  Serial.print(F("Initialising the Bluefruit LE module: "));

  if(!Bluetooth.begin(VERBOSE_MODE)){
    error(F("Couldn't find Bluefruit, make sure it's in Command mode & check wiring?"));
  }
  Serial.println(F("OK!"));

  if(FACTORYRESET_ENABLE){
    /* Perform a factory reset to make sure everything is in a known state */
    Serial.println(F("Performing a factory reset: "));
    if (!Bluetooth.factoryReset()){
      error(F("Couldn't factory reset"));
    }
  }

  /* Disable command echo from Bluefruit */
  Bluetooth.echo(false);

  Bluetooth.verbose(false);

  /* Wait for connection */
  Serial.println("Looking for Bluetooth Device...");
  while (!Bluetooth.isConnected()){
    delay(500);    
  }

  // Change Mode LED Activity
  if (Bluetooth.isVersionAtLeast(MINIMUM_FIRMWARE_VERSION)){
    Bluetooth.sendCommandCheckOK("AT+HWModeLED=" MODE_LED_BEHAVIOUR);
  }

  // Set Bluefruit to DATA mode
  Bluetooth.setMode(BLUEFRUIT_MODE_DATA);

  Serial.println(F("******************************"));
  Serial.println(F("Bluetooth Device Connected!"));
  Serial.println(F("******************************"));
  start++;
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
    unsigned long currentMillis = millis();

    //reset sleep timer for first connection
    if(start == 1){
      previousMillis = currentMillis;
      start--;
    }

    //reset sleep timer for reconnection
    if(flag == 1){
      Serial.println(F("******************************"));
      Serial.println(F("Bluetooth Device Connected!"));
      Serial.println(F("******************************"));
      flag--;
      previousMillis = currentMillis;
    }

    //sleep if a minute of inactivity passes
    if((unsigned long)(currentMillis - previousMillis) >= interval && (unsigned long)(currentMillis - previousMillis) < interval * 5){
      if(sleep == 0){
        Serial.println("Going to Sleep!");
        sleep++;
        delay(500);
        LowPower.idle(SLEEP_8S, ADC_OFF, TIMER2_OFF, TIMER1_OFF, TIMER0_OFF, SPI_OFF, USART0_OFF, TWI_OFF);
      }
    }

    //power down if 5 minutes of inactivity passes
    if((unsigned long)(currentMillis - previousMillis) >= interval * 5){
      Serial.println("Powering Down!");
      delay(500);
      LowPower.powerDown(SLEEP_FOREVER, ADC_OFF, BOD_OFF);
    }

    //check for incoming data from bluetooth device
    if(Bluetooth.available() > 0){
      if(sleep == 1){
        Serial.println("Woke Up!");
        sleep--;
      }
      data = Bluetooth.readString();
      Serial.print("Bluetooth: " + data); 
      previousMillis = currentMillis;
    }

    //check for incoming data from hardware
    if(Serial.available() > 0){
      if(sleep == 1){
        Serial.println("Woke Up!");
        sleep--;
      }
      data = Serial.readString();
      Bluetooth.print("Serial: " + data);
      Serial.println("Message sent to bluetooth.");
      previousMillis = currentMillis; 
    }
  }

  //check if hardware disconnects from bluetooth device
  while (!Bluetooth.isConnected()){
    if(flag == 0){
      Serial.println(F("******************************"));
      Serial.println("Bluetooth Device Disconnected!");
      Serial.println(F("******************************"));
      flag++;
    }
    delay(500);
  }
}

/**
 * @brief Gets accelerometer reading
 * 
 * @param void takes nothing
 * 
 * @return float returns accelerometer reading
 */

float getAccelerometerRead(){
  return 0;
}

void error(const __FlashStringHelper*err){
  Serial.println(err);
  while (1);
}