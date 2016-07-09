import processing.serial.*;
import cc.arduino.*;
import AULib.*;

public class Servo {
  
  public static final int MaxAngle = 95;
  public static final int MinAngle = 85;
  public static final int MiddleAngle = (MaxAngle + MinAngle)/2;
  
  int servoPin;
  Arduino arduino;
  int currentAngle = MinAngle;
  int targetAngle = MinAngle;
  int startAngle = 0;
  int numFramesToTarget = 0;

  public Servo(Arduino arduino, int servoPin) {
    this.arduino = arduino;
    this.servoPin = servoPin;
    arduino.pinMode(this.servoPin, Arduino.SERVO);
    
    //set angle to init angle
    turnTo(MiddleAngle);
  } 

  public void turnTo(int angle) {
    int resultAngle = constrain(angle, MinAngle, MaxAngle);
    arduino.servoWrite(servoPin, resultAngle);
    currentAngle = resultAngle;
  }

  public void turnToOneEnd() { //it would turn to the angle that is further to target angle.
    if(currentAngle - MinAngle > MaxAngle - currentAngle) {
      turnTo(MinAngle);
    }
    else {
      turnTo(MaxAngle);
    }
  }

  public void setTheTargetToOneEnd(int numFrames) {
    if(currentAngle - MinAngle > MaxAngle - currentAngle) {
      setTheTarget(MinAngle, numFrames);
    }
    else {
      setTheTarget(MaxAngle, numFrames);
    }
  }

  public void setTheTarget(int angle, int numFrames) {
    numFramesToTarget = numFrames;
    targetAngle = angle;
    startAngle = currentAngle;
  }

  public int getNextAngle(float currentFrame) {
    if(numFramesToTarget == 0) {
      return currentAngle;
    }
    else if(currentFrame >= numFramesToTarget) {
      return targetAngle;
    }

    float t_param = currentFrame / numFramesToTarget;
    return (int)(startAngle + (targetAngle - startAngle) * AULib.ease(AULib.EASE_LINEAR, t_param));
  }

  public void turnToNextAngle(float currentFrame) {
    int angle = getNextAngle(currentFrame);
    //println("next:" +angle);
    turnTo(angle);
  }

}