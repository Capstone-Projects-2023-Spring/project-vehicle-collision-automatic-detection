#include "accelerometer.h"

void testAccelerometerReading() {
  Serial.println("Testing accelerometer reading...");
  int16_t x, y, z;
  int resultX, resultY, resultZ = 0;

  for (int i = 0; i < 10; i++) {
    xl.readAxes(x, y, z);
    if (x) {
      resultX = 1;
    }
    if (y) {
      resultY = 1;
    }
    if (z) {
      resultZ = 1;
    }
  }

  if (resultX && resultY && resultZ) {
    Serial.println("passed");
  } else {
    Serial.println("FAILED");
  }
}

void testConvertToReading() {
  int seed = analogRead(7); //uses stray voltage from unused pin to get "true" random number
  randomSeed(seed);
  bool passed = true;

  Serial.println("Testing convertToReading()...");
  
  for(int i = 0; i < 10; i++) {
    int rand = random();
    float g = xl.convertToG(scale, rand);
    int reading = convertToReading(scale, g);
    if (reading != rand) {
      passed = false;
    }
  }

  if (passed) {
      Serial.println("passed");
  } else {
      Serial.println("FAILED");
  }
}

void testGetMaxG() { //assumes device is at rest, may fail if device is currently accelerating/decelerating
  Serial.println("Testing getMaxG()...");

  float avgMaxG = 0;
  int numTests = 10;
  
  for(int i = 0; i < numTests; i++) {
    while(!(xl.newXData() || xl.newYData() || xl.newZData())){}
    avgMaxG += getMaxG();
  }
  
  avgMaxG /= numTests;
  
  if (avgMaxG < 5.0 && avgMaxG >= 0.0) {
    Serial.println("passed");
  } else {
    Serial.println("FAILED");
  }
}