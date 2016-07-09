import processing.serial.*;
import cc.arduino.*;

final int ledPin = 11;
final int upperServoPin = 6;
Led led;
int ledBreathCycle = 1;

Arduino arduino = null;
Servo upperServo;
Minim minim;
AudioPlayer song = null;
BeatDetect beat;
BeatListener bl;
float kickSize, snareSize, hatSize;
boolean makeATurn = false;
int currentFrame = 0;
float servoTimeInSec = 0.75f;
int servoTimeInFrame;
String[] songNames = new String[]{"LifeisStrange-Crosses.mp3","OOR_jibunrock.mp3"};
int[] sensitivity = new int[]{300,300};
int detectingWay = 0;

void setup() {
  size(360, 200);
  frameRate(30);
  
  // Prints out the available serial ports.
  println(Arduino.list());
  
  String osName = System.getProperty("os.name");
  if(osName.contains("Mac OS X")) {
    try {
      arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
    }
    catch(Exception e) {
      try {
        arduino = new Arduino(this, "/dev/tty.usbmodem1421", 57600);
      }
      catch(Exception e2) {
        arduino = null;
      }
    }
  }
  else if(osName.contains("Linux")) {
    arduino = new Arduino(this, "/dev/ttyACM0", 57600);
  }
  
  if(arduino == null) {
    exit();
  }
  
<<<<<<< HEAD
  upperServo = new Servo(arduino, upperServoPin);
=======
  upperServo = new Servo(arduino, 6);
>>>>>>> ba2b8bd5c7b578f05d342a7d8df49d0a52bd368d
  led = new Led(arduino, ledPin);
  
  minim = new Minim(this);
}

boolean beatDetected() {
  if(detectingWay == 0) {
    return beat.isHat();
  }
  else {
    return beat.isKick();
  }
}

void draw() {
  background(0);
  
  servoTimeInFrame = (int)secToFrame(servoTimeInSec);
  led.setBreathingLightMode((int)secToFrame(ledBreathCycle));
  
  if(song != null && song.isPlaying()) {
    if(beatDetected()) {
      upperServo.setTheTargetToOneEnd(servoTimeInFrame);
    }
    
    if(currentFrame < servoTimeInFrame) {
      currentFrame++; 
    }
    
    upperServo.turnToNextAngle(currentFrame);
  }
  led.turnToNextLight();
}

public void keyPressed() {
  if (key == 'p') { //play
    if(song != null) {
      if(song.isPlaying()) {
        return;
      }
      song.play();
    }
    else {
      println("please load a song before pressing play");
    }
  } 
  else if(key == 's') { //stop
    if(song != null) {
      song.pause();
    }
    else {
      println("there is no song to be stopped");
    }
  }
  else if(key - '0' >= 0 && '9' - key >= 0) {
    try {
      int index;
      if(key == '0') {
        index = 9;
        if(songNames.length >= 10) {
          song = minim.loadFile(songNames[index], 1024); 
        }
        else {
          song = null;
        }
      }
      else {
        index = key - '0' - 1;
        if(index < songNames.length) {
          song = minim.loadFile(songNames[index], 1024); 
        }
        else {
          song = null;
        }
      }
      
      if(index == 0) {
        detectingWay = 1;
      }
      else {
        detectingWay = 0;
      }
      
      
      if(song != null) {
        beat = new BeatDetect(song.bufferSize(), song.sampleRate());
        beat.setSensitivity(sensitivity[index]);
        bl = new BeatListener(beat, song);
      }
    }
    catch(Exception e) {
      song = null;
      println(e.toString());
    }

  }
  else if(key == 't') {
    upperServo.turnToOneEnd();
  }
  else if(key == 'm') {
    upperServo.turnTo(Servo.MiddleAngle);
  }
  else if(keyCode == ESC) { //you can do some clean up here
    led.turnOff();
    upperServo.turnTo(Servo.MiddleAngle);
  }
}

public class BeatDetectedCallback {
  
  public void detected(BeatType beatType) {
    if(beatType == BeatType.Any) {
      currentFrame = 0;
      upperServo.setTheTargetToOneEnd(servoTimeInFrame);
    }
  }

}

public enum BeatType {
  Any,
  Kick,
  Snear,
  Hat
};
  
public float frameToSec(float numFrame) {
  return (numFrame / frameRate);
}

public float secToFrame(float sec) {
  return sec * frameRate;
}