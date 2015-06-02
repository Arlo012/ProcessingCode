class Player
{
  PVector position;
  PVector speed;
  PVector acceleration;
  
  float  minThrust = .1;
  float  maxThrust = 10;
  
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
  
  void applyBehaviors()
  {
    PVector spinForce = spin();
    PVector thrustForce = Thrust();
    applyForce(thrustForce);
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
    println("Rotation Vector: " + spinSum);
    return steer;
  }
  
  PVector Thrust()
  {
    PVector thrust = speed;
    thrust.normalize();
    thrust.mult(((leftEngine/maxThrust)+(rightEngine/maxThrust))/2);
    thrust.add(speed);
    thrust.normalize();
    thrust.mult(maxSpeed);
    println(thrust);
    println("Thrust Vector: " + thrust);
    return thrust;
  }
    
  
  
    
    
      
}
