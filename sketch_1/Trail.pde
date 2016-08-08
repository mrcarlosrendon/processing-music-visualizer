/* A "trail" of Coord objects with a limited membership, 
if Coords are added past the limit, the oldest gets deleted */
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