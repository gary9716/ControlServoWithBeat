import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import processing.serial.*;

class MyFreqBeatDetect extends BeatDetect{
  
  BeatDetectedCallback cb;
    
  public MyFreqBeatDetect(int timeSize, float sampleRate, BeatDetectedCallback cb) {
    super(timeSize, sampleRate);
    this.cb = cb;
    this.setSensitivity(300);
    this.detectMode(BeatDetect.FREQ_ENERGY);
    
    
  }
  
  @Override
  public void detect(float[] buffer) {
    super.detect(buffer);
  }

  
  
}