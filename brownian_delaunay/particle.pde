class particle
{
  public float xpos, ypos;
  float xspeed, yspeed;
  int ewidth;
  int eheight;
  float speedfactor;
  float dampfactor;
  color col;
  
  particle(float x, float y,int ew, int eh, float sf, float df,color c)
  {
    xpos=x;
    ypos=y;
    xspeed=0;
    yspeed=0;
    ewidth=ew;
    eheight=eh;
    speedfactor=sf;
    dampfactor=df;
    col=c;
  }
  
  void collide()
  {
  int leftcols = (int)random(0, eheight+1);
  int rightcols=(int)random(0, eheight+1);
  int topcols= (int)random(0, ewidth+1);
  int botcols= (int)random(0, ewidth+1);
  
  xspeed+= (leftcols-rightcols)/speedfactor;
  yspeed+= (topcols-botcols)/speedfactor;
 }
 
 void move()
 {
   xpos+=xspeed;
   ypos+=yspeed;
   if (xpos+ewidth> width || xpos-ewidth<0) xspeed*=-1;
   if (ypos+eheight> height || ypos-eheight<0) yspeed*=-1;
 }
 
 void render()
 {
   fill(col);
   ellipse(xpos, ypos, ewidth, eheight);
 }
 
}
