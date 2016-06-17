import processing.serial.*;
import cc.arduino.*;

final int ledPin = 11;
Led led;
int ledBreathCycle = 1;

Arduino arduino = null;
Servo upperServo;
Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;
float kickSize, snareSize, hatSize;
boolean makeATurn = false;
int currentFrame = 0;
float servoTimeInSec = 1f;
int servoTimeInFrame;
String[] songNames = new String[]{"marcus_kellis_theme.mp3"};

void setup() {
  size(360, 200);
  frameRate(30);
  
  // Prints out the available serial ports.
  println(Arduino.list());
  
  String osName = System.getProperty("os.name");
  if(osName.contains("Mac OS X")) {
    arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
  }
  else if(osName.contains("Linux")) {
    arduino = new Arduino(this, "/dev/ttyACM0", 57600);
  }
  
  if(arduino == null) {
    exit();
  }
  
  upperServo = new Servo(arduino, 5);
  led = new Led(arduino, ledPin);
  
  minim = new Minim(this);
  
}

void draw() {
  background(0);
  
  servoTimeInFrame = (int)secToFrame(servoTimeInSec);
  led.setBreathingLightMode((int)secToFrame(ledBreathCycle));
  
  if(song != null && song.isPlaying()) {
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
  } 
  else if(key == 's') { //stop
    if(song != null) {
      song.pause();
    }
  }
  else if(key - '0' >= 0 && '9' - key >= 0) {
    try {
      if(key == '0') {
        if(songNames.length >= 10) {
          song = minim.loadFile(songNames[9], 1024); 
        }
        else {
          song = null;
        }
      }
      else {
        int index = key - '0' - 1;
        if(index < songNames.length) {
          song = minim.loadFile(songNames[index], 1024); 
        }
        else {
          song = null;
        }
      }
      
      if(song != null) {
        beat = new WalshBeatDetect(song.bufferSize(), song.sampleRate(), new BeatDetectedCallback());
        beat.setSensitivity(300);
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
  else if(keyCode == ESC) { //you can do some clean up here
    led.turnOff();
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
  
//private void prepareExitHandler () {
//  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
//    public void run () {
//      println("SHUTDOWN HOOK");
//      // application exit code here
//    }
//  }));
//}

public float frameToSec(float numFrame) {
  return (numFrame / frameRate);
}

public float secToFrame(float sec) {
  return sec * frameRate;
}