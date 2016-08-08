import java.util.List;
import java.util.ArrayList;

int numBoids = 13;
int boidWidth = 10;
int boidHeight = 10;
Vector[] boids = new Vector[numBoids];

int height = 1024;
int width = 1024;

int velocity = 1;
float neighborDist = 200;
int debugLineLength = 8;

void setup() {
  size(1024, 1024);
  for (int i=0; i<numBoids; i++) {
    boids[i] = new Vector(new Coord(random(width), random(height)), 
      new Coord(random(-velocity, velocity), random(-velocity, velocity)));
  }
  strokeWeight(2);
}

List<Vector> getNeighbors(Vector[] boids, Vector boid) {
  List<Vector> neighbors = new ArrayList<Vector>();
  Coord boidPos = boid.getCurrentPosition();
  for (Vector boid2 : boids) {
    if (boid2 == boid) {
      continue;
    }
    Coord boid2Pos = boid2.getCurrentPosition();
    float distance = computeDistance(boidPos, boid2Pos);    
    if (distance < neighborDist) {
      /*print(boidPos + " " + boid2Pos);      
       println(distance);*/
      neighbors.add(boid2);
    }
  }  
  return neighbors;
}

Vector getClosestNeighbor(List<Vector> neighbors, Vector boid) {  
  Coord boidPos = boid.getCurrentPosition();
  Vector closest = null;
  float minDistance = 999999;
  for (Vector neighbor : neighbors) {
    Coord neighPos = neighbor.getCurrentPosition();
    float dist = computeDistance(boidPos, neighPos);
    if (dist < minDistance) {
      minDistance = dist;
      closest = neighbor;
    }
  }  
  return closest;
}

Coord getAverageHeading(List<Vector> boids) {
  float sumX = 0;
  float sumY = 0;
  for (Vector boid : boids) {
    Coord dir = boid.getDirection();
    sumX += dir.x;
    sumY += dir.y;
  }  
  return new Coord(sumX / boids.size(), sumY / boids.size());
}

Coord getAveragePosition(List<Vector> boids) {
  float sumX = 0;
  float sumY = 0;
  //println("average");
  for (Vector boid : boids) {    
    Coord pos = boid.getCurrentPosition();
    //println(pos);
    sumX += pos.x;
    sumY += pos.y;
  }
  Coord averagePos = new Coord(sumX / boids.size(), sumY / boids.size());
  //println("avg: " + averagePos);
  return averagePos;
}

float computeDistance(Coord a, Coord b) {
  float diffX = Math.max(a.x, b.x) - Math.min(a.x, b.x);
  float diffY = Math.max(a.y, b.y) - Math.min(a.y, b.y);
  float distance = (float)Math.sqrt(diffX*diffX + diffY*diffY);
  /*print(a);
   print(" ");
   print(b);  
   println(" " + distance);*/
  return distance;
}

Coord computeNormalizedDirection(Coord a, Coord b) {
  float diffX = a.x - b.x;
  float diffY = a.y - b.y;
  float dist = computeDistance(a, b);   
  return new Coord(diffX/dist, diffY/dist);
}

Coord normalize(Coord a) {
  float dist = (float)Math.sqrt(a.x*a.x + a.y*a.y);
  return new Coord(a.x/dist, a.y/dist);
}

void debugShowNeighborLines(Coord pos, List<Vector> neighbors) {
  for (Vector neighbor : neighbors) {
    stroke(255, 255, 255, 50);
    Coord neighborPos = neighbor.getCurrentPosition();
    line(pos.x, pos.y, neighborPos.x, neighborPos.y);
  }
}

void draw() {
  clear();
  stroke(0, 0, 0);
  for (Vector boid : boids) {
    Coord pos = boid.getNextPos();
    ellipse(pos.x, pos.y, boidWidth, boidHeight);
  }

  for (Vector boid : boids) {
    Coord boidPos = boid.getCurrentPosition();
    List<Vector> neighbors = getNeighbors(boids, boid);
    if (neighbors.size() > 0) {
      debugShowNeighborLines(boidPos, neighbors);

      // alignment - red
      Coord averageHeading = getAverageHeading(neighbors);    
      stroke(255, 0, 0); 
      line(boidPos.x, boidPos.y, boidPos.x + averageHeading.x*debugLineLength, boidPos.y + averageHeading.y*debugLineLength);

      // cohesion - green
      Coord averagePosition = getAveragePosition(neighbors);    
      Coord towardsAveragePosition = computeNormalizedDirection(averagePosition, boidPos);

      stroke(0, 255, 0); 
      line(boidPos.x, boidPos.y, boidPos.x + towardsAveragePosition.x*debugLineLength, boidPos.y + towardsAveragePosition.y*debugLineLength);

      // Separation - yellow
      Vector closestNeighbor = getClosestNeighbor(neighbors, boid);
      Coord closestNeighborPos = closestNeighbor.getCurrentPosition();
      Coord awayFromClosestNeighbor = computeNormalizedDirection(boidPos, closestNeighborPos);

      stroke(255, 255, 0); 
      line(boidPos.x, boidPos.y, boidPos.x + awayFromClosestNeighbor.x*debugLineLength, boidPos.y + awayFromClosestNeighbor.y*debugLineLength);

      // Combine all rules
      boid.setDirection(normalize(
        new Coord(
        averageHeading.x + towardsAveragePosition.x + awayFromClosestNeighbor.x, 
        averageHeading.y + towardsAveragePosition.y + awayFromClosestNeighbor.y)));
    }
  }
}