/* Basically a Point object */
class Coord {
  public Coord(float x, float y) {
    this.x = x;
    this.y = y;
  }
  float x;
  float y;
  
  public Coord getMirror() {
    return new Coord(-x, -y);
  }
  
  public String toString() {
    return String.format("(%f, %f)", x, y);
  }
}