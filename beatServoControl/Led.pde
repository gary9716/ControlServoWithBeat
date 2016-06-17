import AULib.*;

public class Led {
  
  final int minLight = 0;
  final int maxLight = 255;
  
  Arduino arduino;
  int ledPin;
  int numFramesToTarget;
  int currentFrame = 0;
  int startLight = minLight;
  int targetLight = maxLight;
  
  Led(Arduino arduino, int ledPin) {
    currentFrame = 0;
    this.ledPin = ledPin;
    this.arduino = arduino;
    arduino.pinMode(ledPin, Arduino.OUTPUT);
  }

  public void setBreathingLightMode(int numFrames) {
    numFramesToTarget = numFrames;
  }
  
  public void turnToNextLight() { //called per frame
    currentFrame++;
    float t_param = (float)currentFrame / numFramesToTarget;
    int nextLight = (int)(startLight + (targetLight - startLight) * AULib.ease(AULib.EASE_IN_OUT_CUBIC, t_param));
    //println(nextLight);
    arduino.analogWrite(ledPin, constrain(nextLight,minLight,maxLight));
    if(nextLight == targetLight) {
      targetLight = maxLight - targetLight;
      startLight = maxLight - startLight;
      currentFrame = 0;
    }
  }
  
  public void turnOff() {
    arduino.analogWrite(ledPin, 0); 
  }

}