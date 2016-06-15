import processing.serial.*;
import cc.arduino.*;

Arduino arduino;
Servo upperServo;
Servo lowerServo;
Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;

float kickSize, snareSize, hatSize;

void setup() {
  size(360, 200);
  
  // Prints out the available serial ports.
  println(Arduino.list());
  
  //on Mac
  arduino = new Arduino(this, "/dev/tty.usbmodem1411", 57600);
  
  //on Linux 
  
  if(arduino == null) {
    exit();
  }
    
  // Alternatively, use the name of the serial port corresponding to your
  // Arduino (in double-quotes), as in the following line.
  //arduino = new Arduino(this, "/dev/tty.usbmodem621", 57600);
  
  upperServo = new Servo(arduino, 5);
  lowerServo = new Servo(arduino, 6);

  
  
  minim = new Minim(this);
  
  song = minim.loadFile("marcus_kellis_theme.mp3", 1024);
  song.play();
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new WalshBeatDetect(song.bufferSize(), song.sampleRate(), new BeatDetectedCallback());
  beat.setSensitivity(300);
  bl = new BeatListener(beat, song);  
  
  //UI Related
  //kickSize = snareSize = hatSize = 16;
  //// make a new beat listener, so that we won't miss any buffers for the analysis
  //textFont(createFont("Helvetica", 16));
  //textAlign(CENTER);

}

void draw() {

  background(0);

  // draw a green rectangle for every detect band
  // that had an onset this frame
  float rectW = width / beat.detectSize();
  for(int i = 0; i < beat.detectSize(); ++i)
  {
    // test one frequency band for an onset
    if ( beat.isOnset(i) )
    {
      fill(0,200,0);
      rect( i*rectW, 0, rectW, height);
    }
  }
  
  //// draw an orange rectangle over the bands in 
  //// the range we are querying
  //int lowBand = 5;
  //int highBand = 15;
  //// at least this many bands must have an onset 
  //// for isRange to return true
  //int numberOfOnsetsThreshold = 4;
  //if ( beat.isRange(lowBand, highBand, numberOfOnsetsThreshold) )
  //{
  //  fill(232,179,2,200);
  //  rect(rectW*lowBand, 0, (highBand-lowBand)*rectW, height);
  //}
  
  //if ( beat.isKick() )  {
  //  kickSize = 32;
  //}

  //if ( beat.isSnare() ) {
  //  snareSize = 32;
  //}
  
  //if ( beat.isHat() ) hatSize = 32;
  
  //fill(255);
    
  //textSize(kickSize);
  //text("KICK", width/4, height/2);
  
  //textSize(snareSize);
  //text("SNARE", width/2, height/2);
  
  //textSize(hatSize);
  //text("HAT", 3*width/4, height/2);
  
  //kickSize = constrain(kickSize * 0.95, 16, 32);
  //snareSize = constrain(snareSize * 0.95, 16, 32);
  //hatSize = constrain(hatSize * 0.95, 16, 32);

}
public enum BeatType {
  Any,
  Kick,
  Snear,
  Hat
};
  
public class BeatDetectedCallback {
  
  public void detected(BeatType beatType) {
    if(beatType == BeatType.Any) {
      lowerServo.turnToOneEnd();
    }
  }

}