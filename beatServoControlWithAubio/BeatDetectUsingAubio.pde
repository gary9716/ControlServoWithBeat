import java.io.InputStreamReader;

class BeatDetectUsingAubio {
  
  Runtime runtimeEnv;
  String fileAbsPath;
  String AubioPath = "";
  ArrayList<Float> timeStamps = new ArrayList<Float>();
  public boolean isFinishProcessing = false;
  int currentIndex = -1;
  
  BeatDetectUsingAubio(PApplet parent, String audioFileName) {
    runtimeEnv = Runtime.getRuntime();
    fileAbsPath = parent.sketchPath() + "/data/" + audioFileName;
    AubioPath = parent.sketchPath() + "/bin/";
    
    if(isOSX()) {
      AubioPath += "aubioonset_osx";
    }
    else if(isLinux()){
      AubioPath += "aubioonset_linux";
    }
    
    println(fileAbsPath);
    new Thread(new Runnable() {
      @Override
      public void run() {
         try {
           Process p = runtimeEnv.exec(AubioPath + " -t 0.7 " + fileAbsPath);
           
           BufferedReader reader = 
             new BufferedReader(new InputStreamReader(p.getInputStream()));
           String line;
           while ((line = reader.readLine())!= null) {
             timeStamps.add(new Float(line));
           }
           p.waitFor();
           isFinishProcessing = true;
         }
         catch(Exception e) {
           println(e.toString());
         }
         
      }
    
    }).start();
    
    
  }
  
  public int numBeatsAnalyzed() {
    return timeStamps.size();
  }
  
  public float getNextTimeStamp() {
    if(timeStamps.size() > 0 && currentIndex < timeStamps.size()) {
      currentIndex++;
      return timeStamps.get(currentIndex);
    }
    else 
      return -1;
  }
  
}