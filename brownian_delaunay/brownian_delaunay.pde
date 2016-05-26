/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/6270*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
import megamu.mesh.*;
Delaunay delaunay;

int numparticles =100;
particle[] particles;
float[][] positions;
void setup()
{
  size(500, 500);
  background(255);
  noStroke();
  smooth();
  rectMode(CENTER);
  particles = new particle[numparticles];
  positions = new float[numparticles][2];
  for(int i=0; i<numparticles; i++)
  {
    particles[i] = new particle(random(450, width-20), random(450, height-20), 10, 10, 5, 0.9,
                             color(0, 0, 0, 255));
  }
  
}

void draw()
{
  background(255);
  for(int i=0; i<numparticles; i++)
  {
    particles[i].collide();
    particles[i].move();
//    particles[i].render();
  
    particles[i].xspeed*=particles[i].dampfactor;
    particles[i].yspeed*=particles[i].dampfactor;
    positions[i][0] = particles[i].xpos;
    positions[i][1] = particles[i].ypos;

  }
  stroke(9);
  
  delaunay = new Delaunay(positions);

  int[][] myLinks = delaunay.getLinks();

  for(int i=0; i < myLinks.length; i++)
  {
    int startIndex = myLinks[i][0];
    int endIndex = myLinks[i][1];
  
    float startX = positions[startIndex][0];
    float startY = positions[startIndex][1];
    float endX = positions[endIndex][0];
    float endY = positions[endIndex][1];
    line( startX, startY, endX, endY );
  }
  
}

