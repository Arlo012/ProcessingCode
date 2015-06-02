class Player
{
  PVector position;
  PVector speed;
  PVector acceleration;
  
  
  float  r=20;
  float maxSpeed = 10;
  float maxForce = .2;
  float leftEngine;
  float rightEngine;
  
  Player()
  {
    position = new PVector(width/2, height/2);
    speed = new PVector(1,1);
    acceleration = new PVector(0,0);
    leftEngine = 1;
    rightEngine = 1;
  }
  
  void update()
  {
    speed.add(acceleration);
    speed.limit(maxSpeed);
    //acceleration.mult(0);
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
    imageMode(CENTER);
    image(playerIMG,0,0);
    imageMode(CORNER);
    popMatrix();
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void applyBehaviors(int _avoidWeight, int _spinWeight)
  {
    PVector spinForce = spin();
    applyForce(spinForce);
  }
  
  PVector seek(PVector target)
  {
    PVector desired = PVector.sub(target,position);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer= PVector.sub(desired,speed);
    steer.limit(maxForce);
    return steer;
  }
  
  PVector spin()
  {
    map(leftEngine, 1, 501, 0, maxSpeed);
    map(rightEngine, 1, 501, 0, maxSpeed);
    PVector spinLeftEngine = new PVector(1,1);
    PVector spinRightEngine = new PVector(1,1);
    spinLeftEngine.set(-speed.y,speed.x);
    spinRightEngine.set(speed.y,-speed.x);
    spinLeftEngine.normalize();
    spinRightEngine.normalize();
    spinLeftEngine.mult(leftEngine);
    spinRightEngine.mult(rightEngine);
    PVector spinSum = PVector.add(spinRightEngine,spinLeftEngine);
    PVector desired = PVector.add(spinSum,speed);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer = PVector.sub(desired,speed);
    steer.limit(maxForce);
    return steer;
  }
  
  PVector EngineSpeed()
  {
    
  
  
    
    
      
}
