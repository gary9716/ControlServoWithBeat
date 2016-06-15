import processing.serial.*;
import cc.arduino.*;

public class Servo {
  int servoPin;
  Arduino arduino;
  int targetAngle;

  final int MaxAngle = 180;
  final int MinAngle = 0;

  public Servo(Arduino arduino, int servoPin) {
    this.arduino = arduino;
    this.servoPin = servoPin;
    arduino.pinMode(this.servoPin, Arduino.SERVO);
  } 

  public void turnTo(int angle) {
    arduino.servoWrite(servoPin, constrain(angle, MinAngle, MaxAngle));
    targetAngle = angle;
  }

  public void turnToOneEnd() { //it would turn to the angle that is further to target angle.
    if(targetAngle - MinAngle > MaxAngle - targetAngle) {
      turnTo(MinAngle);
    }
    else {
      turnTo(MaxAngle);
    }
  }

}