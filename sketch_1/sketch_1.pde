import javax.sound.sampled.*;

TargetDataLine tdl = null;
int sampleSize = 133;
float sampleRate = 8000;
float[] lowPass = new float[10];
int lowPassInd = 0;
int lastVal = 0;

Vector[] balls = new Vector[10];                  
Trail lines = new Trail(50);

class Coord {
  public Coord(float x, float y) {
    this.x = x;
    this.y = y;
  }
  float x;
  float y;
}

class Vector {  
    public Vector(Coord pos, Coord dir) {
      this.pos = pos;
      this.dir = dir;
    }  
  private Coord pos;
  private Coord dir;
  
  public Coord getNextPos() {
    pos.x = pos.x + dir.x;
    pos.y = pos.y + dir.y;
    
    return new Coord(pos.x, pos.y);
  }
  
  public void mirrorX() {
    dir.x = -dir.x;
  }
  
  public void mirrorY() {
    dir.y = -dir.y;
  }  
}

class Trail {
  public Trail(int limit) {
    this.limit = limit;
    this.trail = new Coord[limit];
    for(int i=0; i<limit; i++) {
      this.trail[i] = new Coord(0,0);
    }
  }
  
  private final int limit;
  private int currIndex = 0;
  public Coord[] trail;
  
  public void addCoord(Coord c) {
    currIndex = currIndex++ % limit;
    trail[currIndex++] = c;
  }
}

private static long extendSign(long temp, int bitsPerSample) {
    int extensionBits = 64 - bitsPerSample;
    return (temp << extensionBits) >> extensionBits;
  }

void setup() {
  size(1024, 1024, P2D); 
  try {    
    int sampleSizeBits = 16;
    int numChannels = 1; // Mono
    AudioFormat format = new AudioFormat(sampleRate, sampleSizeBits, numChannels, true, true);
    tdl = AudioSystem.getTargetDataLine(format);
    tdl.open(format);
    tdl.start();
    if (!tdl.isOpen()) {
      System.exit(1);      
    } 
  } catch (Exception e) {
    print(e);    
  }
  
  for(int i=0; i <10; i++) {
    balls[i] = new Vector(
                  new Coord(random(width),random(height)), 
                  new Coord(random(-1,1), random(-1,1)));
  }  
}

float average(float[] arr) {
  float sum = 0;
  int count = 0;
  for (float f : arr) {
    sum += f;
    count++;
  }
  return sum / count;
}

float scaleF(float val, float oldMax, float newMax) {
  float scaleFactor = val / oldMax;
  return scaleFactor * newMax;
}

int nextVal(int v) {
  return (v + 1) % 255; 
}

Coord nextBounce(Vector v) {
  Coord p = v.getNextPos();
  if (p.x > width || p.x < 0) {
    v.mirrorX();
    v.getNextPos();
  }
  if (p.y > height || p.y < 0) {
    v.mirrorY();
    v.getNextPos();
  }
  return p;
}

void draw() {  
  clear();
  if (tdl == null) {
    background(255, 0, 0);
    return;
  }
  
  byte[] data = new byte[272];
  int read = tdl.read(data, 0, 272);
  long sum = 0;
  if (read > 0) {    
    for (int i = 0; i < read-1; i = i + 1) {
      long val = ((data[i] & 0xffL) << 8L) | (data[i + 1] & 0xffL);
      long valf = extendSign(val, 16);
      if (Math.abs(valf) >= Math.pow(2,14)) {
        sum += valf;
      }
    }
  }
  
  lowPass[lowPassInd++ % 10] = sum;  
  background(0, scaleF(average(lowPass), (float)Math.pow(2,16), 255), 60);
  
  
  lastVal = nextVal(lastVal); 
  fill(lastVal);
  
  for (Vector ball : balls) {
    Coord el = nextBounce(ball);
    ellipse(el.x, el.y, 20, 50);
  }
  
  stroke(255, 0, 0);
  
  lines.addCoord(new Coord(mouseX, mouseY));
  for (Coord l : lines.trail) {
      line(l.x, l.y, l.x+100, l.y+100);
  }
}