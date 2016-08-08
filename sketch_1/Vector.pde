/* A Coord that is moving in a direction */
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