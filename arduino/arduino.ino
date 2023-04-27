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
#include "accelerometer.h"
#include "SparkFun_LIS331.h"

#define FACTORYRESET_ENABLE         1
#define MINIMUM_FIRMWARE_VERSION    "0.6.6"
#define MODE_LED_BEHAVIOUR          "MODE"

LIS331 xl;
float scale = 100.0;
float threshold = 10.0;

String data = " ";
int flag = 0;
int start = 0;
const unsigned long interval = 30000;
unsigned long previousMillis = 0;
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
  Serial.begin(115200);
  
  /* Put the device into idle mode */
  LowPower.idle(SLEEP_FOREVER, ADC_ON, TIMER2_OFF, TIMER1_OFF, TIMER0_ON, SPI_OFF, USART0_OFF, TWI_OFF);

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

  // Create custom characteristic
  Serial.println(F("Setting service + characteristic!"));
  Bluetooth.atcommand("AT+GATTADDSERVICE=UUID128=00-11-00-11-44-55-66-77-88-99-AA-BB-CC-DD-EE-FF");

  int char1 = Bluetooth.atcommand("AT+GATTADDCHAR=UUID128=00-11-22-33-44-55-66-77-88-99-AB-BC-CD-DE-EF-FF,PROPERTIES=0x10,MIN_LEN=1,VALUE=HELLO");
  Serial.println(char1);

  // Reset Bluefruit for custom characteristic
  Bluetooth.reset();

  /* Wait for connection */
  Serial.println("Looking for Bluetooth Device...");
  while (!Bluetooth.isConnected()){
    unsigned long currentMillis = millis();
    // Power down if 30 seconds of no connection passes
    if((unsigned long)(currentMillis - previousMillis) >= interval){
      Serial.println("Powering Down!");
      // Make the Bluetooth undiscoverable
      Bluetooth.setAdvData(NULL, 0);
      // Turn off the Mode LED
      Bluetooth.sendCommandCheckOK("AT+HWModeLED=0");
      delay(500);
      // Power down the device
      LowPower.powerDown(SLEEP_FOREVER, ADC_OFF, BOD_OFF);
    }
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

  delay(500);

  //accelerometer
  pinMode(9,INPUT);       // Interrupt pin input
  pinMode(10, OUTPUT);    // CS for SPI
  digitalWrite(10, HIGH); // Make CS high
  pinMode(11, OUTPUT);    // MOSI for SPI
  pinMode(12, INPUT);     // MISO for SPI
  pinMode(13, OUTPUT);    // SCK for SPI
  SPI.begin();
  xl.setSPICSPin(10);     // This MUST be called BEFORE .begin() so 
                          //  .begin() can communicate with the chip
  xl.begin(LIS331::USE_SPI); // Selects the bus to be used and sets
                          //  the power up bit on the accelerometer.
                          //  Also zeroes out all accelerometer
                          //  registers that are user writable.
  // This next section configures an interrupt. It will cause pin
  //  INT1 on the accelerometer to go high when the absolute value
  //  of the reading on the Z-axis exceeds a certain level for a
  //  certain number of samples.
  xl.intSrcConfig(LIS331::INT_SRC, 1); // Select the source of the
                          //  signal which appears on pin INT1. In
                          //  this case, we want the corresponding
                          //  interrupt's status to appear. 
  xl.setIntDuration(1, 1); // Number of samples a value must meet
                          //  the interrupt condition before an
                          //  interrupt signal is issued. At the
                          //  default rate of 50Hz, this is one sec.
  float intThresholdG = sqrt(pow(threshold, 2)/2.0); //Minimum G on an individual axis for total to exceed threshold
  int intThresholdCount = convertToReading(scale, intThresholdG);
  xl.setIntThreshold(intThresholdCount/16, 1); // Threshold for an interrupt. This is
                          //  not actual counts, but rather, actual
                          //  counts divided by 16.
  xl.enableInterrupt(LIS331::X_AXIS, LIS331::TRIG_ON_HIGH, 1, true);  
  xl.enableInterrupt(LIS331::Y_AXIS, LIS331::TRIG_ON_HIGH, 1, true);
  xl.enableInterrupt(LIS331::Z_AXIS, LIS331::TRIG_ON_HIGH, 1, true);
                          // Enable the interrupt. Parameters indicate
                        //  which axis to sample, when to trigger
                          //  (in this case, when the absolute mag
                          //  of the signal exceeds the threshold),
                          //  which interrupt source we're configuring,
                          //  and whether to enable (true) or disable
                          //  (false) the interrupt.
  xl.setPowerMode(LIS331::NORMAL);
  xl.setODR(LIS331::DR_50HZ);
  xl.setFullScale(LIS331::LOW_RANGE);
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

    //put device into idle mode
    LowPower.idle(SLEEP_FOREVER, ADC_ON, TIMER2_OFF, TIMER1_OFF, TIMER0_ON, SPI_OFF, USART0_OFF, TWI_OFF);

    //reset sleep timer for first connection
    if(start == 1){
      previousMillis = currentMillis;
      //initialize characteristic value to '0'
      gatt.setChar(1, signal0, sizeof(signal0));
      start--;
      delay(500);
    }

    //reset sleep timer for reconnection
    if(flag == 1){
      Serial.println(F("******************************"));
      Serial.println(F("Bluetooth Device Connected!"));
      Serial.println(F("******************************"));
      previousMillis = currentMillis;
      //initialize characteristic value to '0'
      gatt.setChar(1, signal0, sizeof(signal0));
      flag--;
      delay(500);
    }

    float maxG;

    //print max g value
    if(xl.newXData() || xl.newYData() || xl.newZData()){
      float maxG = getMaxG();
      int16_t x, y, z;
      xl.readAxes(x, y, z);
      Serial.println(maxG);
    }

    //checks if threshold might have been exceeded, then verifies
    if (digitalRead(9) == HIGH && (maxG = getMaxG()) > threshold) { 
      Serial.println("Interrupt: " + String(maxG) + "g");
      Serial.println("Changing Characteristic!");
      //change characteristic value to 'F'
      gatt.setChar(1, signal1, sizeof(signal1));
      delay(3000);
      Serial.println("Resetting Characteristic!");
      //reset characteristic value back to '0'
      gatt.setChar(1, signal0, sizeof(signal0));
      delay(1000);
      //reset the sleep timer
      previousMillis = currentMillis;
    } 

    //disconnect from bluetooth if 10 minutes of inactivity passes
    if((unsigned long)(currentMillis - previousMillis) >= interval * 20){
      previousMillis = currentMillis;
      Bluetooth.disconnect();
      delay(500);
    }

    //check for incoming data from bluetooth device
    if(Bluetooth.available() > 0){
      data = Bluetooth.readString();
      Serial.print("Bluetooth: " + data); 
      previousMillis = currentMillis;
    }

    //check for incoming data from hardware
    if(Serial.available() > 0){
      data = Serial.readString();
      Bluetooth.print("Serial: " + data);
      Serial.println("Message sent to bluetooth.");
      previousMillis = currentMillis; 
    }
  }

  //check if hardware disconnects from bluetooth device
  while (!Bluetooth.isConnected()){
    unsigned long currentMillis = millis();

    //put device into idle mode
    LowPower.idle(SLEEP_FOREVER, ADC_ON, TIMER2_OFF, TIMER1_OFF, TIMER0_ON, SPI_OFF, USART0_OFF, TWI_OFF);

    if(flag == 0){
      Serial.println(F("**"));
      Serial.println("Bluetooth Device Disconnected!");
      Serial.println(F("**"));
      flag++;
      previousMillis = currentMillis;
    }
    delay(500);

    //power down if 30 seconds of no connection passes
    if((unsigned long)(currentMillis - previousMillis) >= interval){
      Serial.println("Powering Down!");
      // Make the Bluetooth undiscoverable
      Bluetooth.setAdvData(NULL, 0);
      // Turn off the Mode LED
      Bluetooth.sendCommandCheckOK("AT+HWModeLED=0");
      delay(500);
      // Power down the device
      LowPower.powerDown(SLEEP_FOREVER, ADC_OFF, BOD_OFF);
    }
  }
}

/**
 * @brief Error handler for Arduino methods
 * 
 * @param err error message string
 * 
 * @return void returns nothing
 */

void error(const __FlashStringHelper*err){
  Serial.println(err);
  while (1);
}

/**
 * @brief Convert sensor reading into an integer value
 * 
 * @param maxScale maximum scale for g-force
 * 
 * @param g minimum g on individual axis
 * 
 * @return integer value of sensor reading
 */

int convertToReading(int maxScale, float g) {
  int reading = int((g * 2047) / maxScale);
  return reading;
}

/**
 * @brief Calculates maximum g-force in any direction
 * 
 * @param void takes nothing
 * 
 * @return maximum g-force
 */

float getMaxG() {
  int16_t x, y, z;

  xl.readAxes(x, y, z);
  
  float xg = xl.convertToG(scale,x);
  float yg = xl.convertToG(scale,y);
  float zg = xl.convertToG(scale,z);
  
  float maxG = sqrt(pow(xg, 2) + pow(yg, 2) + pow(zg, 2)); //pythagoream theorem for three dimensions

  return maxG;
}