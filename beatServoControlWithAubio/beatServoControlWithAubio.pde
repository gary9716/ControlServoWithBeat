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
BeatDetectUsingAubio beatDetect;
float kickSize, snareSize, hatSize;
boolean makeATurn = false;
int currentFrame = 0;
float servoTimeInSec = 0.5f;
int servoTimeInFrame;
String[] songNames = new String[]{"LifeisStrange-Crosses.mp3","OOR_jibunrock.mp3"};
int[] sensitivity = new int[]{300,300};
int detectingWay = 0;

float nextTimestamp = -1;
float withinTime = 0.05f;
float lastDetectedTime;
boolean beatDetected(AudioPlayer song) {
  float currentSongPos = song.position()/1000.0f;
  
  if(currentSongPos > nextTimestamp) {
    float temp = nextTimestamp;
    nextTimestamp = beatDetect.getNextTimeStamp();
    if(abs(currentSongPos - temp) < withinTime) {
      
      lastDetectedTime = currentSongPos;
      return true;
    }
    else {
      return false;
    }
  }
  else {
    if(abs(currentSongPos - nextTimestamp) < withinTime) {
      nextTimestamp = beatDetect.getNextTimeStamp();
      
      lastDetectedTime = currentSongPos;
      return true;
    }
    else {
      return false;
    }
  }
}


void setup() {
  size(360, 200);
  frameRate(30);
  
  // Prints out the available serial ports.
  println(Arduino.list());
  
  if(isOSX()) {
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
  else if(isLinux()) {
    arduino = new Arduino(this, "/dev/ttyACM0", 57600);
  }
  
  if(arduino == null) {
    exit();
  }
  
  upperServo = new Servo(arduino, upperServoPin);
  led = new Led(arduino, ledPin);
  
  minim = new Minim(this);
}

void draw() {
  background(0);
  
  servoTimeInFrame = (int)secToFrame(servoTimeInSec);
  led.setBreathingLightMode((int)secToFrame(ledBreathCycle));
  
  if(song != null && song.isPlaying()) {
    if(beatDetected(song)) {
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
          beatDetect = new BeatDetectUsingAubio(this, songNames[index]);
          song = minim.loadFile(songNames[index], 1024); 
        }
        else {
          song = null;
        }
      }
      else {
        index = key - '0' - 1;
        if(index < songNames.length) {
          beatDetect = new BeatDetectUsingAubio(this, songNames[index]);
          song = minim.loadFile(songNames[index], 1024); 
        }
        else {
          song = null;
        }
      }
      
      
    }
    catch(Exception e) {
      song = null;
      println(e.toString());
    }
    
    nextTimestamp = -1;
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

  
public float frameToSec(float numFrame) {
  return (numFrame / frameRate);
}

public float secToFrame(float sec) {
  return sec * frameRate;
}

public boolean isOSX() {
  return System.getProperty("os.name").contains("Mac OS X");
}

public boolean isLinux() {
  return System.getProperty("os.name").contains("Linux");
}