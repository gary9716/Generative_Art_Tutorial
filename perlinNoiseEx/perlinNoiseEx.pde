void setup() {
  size(500,300);
  background(255);
  strokeWeight(5);
  smooth();
  //stroke(0,30);
  
  int borderX = 20;
  int borderY = 150;
  int step = 10;
  float lastX = -999;
  float lastY = -999;
  float y = borderY;
  float ynoise = customRand(1);
  
  for (int x = borderX;x <= width - borderX;x += step) {
    
    y = borderY + customRand(30);
  //  y = borderY + random(height - 2 * borderY);
    if(lastX > -999) {
      line(x,y,lastX,lastY);
    }
  
    lastX = x;
    lastY = y;
  }
}

float customRand(float seed) {
  return ((pow(random(1), 3) + pow(noise(1), 3))/2 * seed);
}

