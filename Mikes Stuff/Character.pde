class Player
{
  PVector position;
  PVector speed;
  PVector acceleration;
  
  
  float  r=20;
  float maxSpeed = 10;
  float maxForce = .1;
  float leftEngine;
  float rightEngine;
  
  Player()
  {
    position = new PVector(width/2, height/2);
    speed = new PVector(0,0);
    acceleration = new PVector(0,0);
    leftEngine = 0;
    rightEngine = 0;
  }
  
  void update()
  {
    speed.add(acceleration);
    speed.limit(maxSpeed);
    position.add(speed);
    acceleration.mult(0);
  }
  
  void display()
  {
    float theta = speed.heading2D() + PI/2;
    fill(255);
    stroke(0);
    strokeWeight(1);
    pushMatrix();
    translate(position.x,position.y);
    rotate(theta);
    beginShape();
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape(CLOSE);
    popMatrix();
  }
}
