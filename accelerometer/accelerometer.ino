#include "SparkFun_LIS331.h"
#include <SPI.h>

LIS331 xl;
float scale = 100.0;
float threshold = 8.0;

void setup() 
{
  // put your setup code here, to run once:
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
  Serial.begin(115200);
  //test();
}

void loop() 
{
  /*if(xl.newXData() || xl.newYData() || xl.newZData()){
    float maxG = getMaxG();
    Serial.println(maxG);
  }*/

  if (digitalRead(9) == HIGH) { //threshold MIGHT have been exceeded
    float maxG = getMaxG();
    Serial.println("Interrupt: " + String(maxG) + "g");
    if (maxG > threshold) { //this is the real check
        Serial.println("Threshold exceeded");
    }
  }
}

int convertToReading(int maxScale, float g) {
  int reading = int((g * 2047) / maxScale);
  return reading;
}

//calculates maximum g-force in any direction
float getMaxG() {
  int16_t x, y, z;

  xl.readAxes(x, y, z);
  
  float xg = xl.convertToG(scale,x);
  float yg = xl.convertToG(scale,y);
  float zg = xl.convertToG(scale,z);
  
  //Serial.println(String(xg) + " " + String(yg) + " " + String(zg));
  
  float maxG = sqrt(pow(xg, 2) + pow(yg, 2) + pow(zg, 2)); //pythagoream theorem for three dimensions

  return maxG;
}

void test() {
  int seed = analogRead(7); //uses stray voltage from unused pin to get "true" random number
  randomSeed(seed);
  
  Serial.println("Testing convertToReading()");

  for(int i = 0; i < 10; i++) {
    int rand = random();
    float g = xl.convertToG(scale, rand);
    int reading = convertToReading(scale, g);
    if (reading == rand) {
      Serial.println(String(rand) + " passed");
    } else {
      Serial.println(String(rand) + " FAILED");
    }
  }

}
