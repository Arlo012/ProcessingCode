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
    beginShape();
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape(CLOSE);
    popMatrix();
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void applyBehaviors(int _avoidWeight, int _spinWeight)
  {
    //PVector seekForce = seek(new PVector(mouseX,mouseY));
    PVector spinForce = spin();
    applyForce(spinForce);
    //applyForce(seekForce);
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
    float ratio = leftEngine/rightEngine;
    map(ratio, (1/501), 501, -10, 10);
    PVector spin = new PVector(1,1);
    if(ratio > 0)
    {
      //if(speed.x == 0 && speed.y == 0)
      //{
      //  spin.set(0,1);
      //}
      //else
      //{
        spin.set(speed.y,-speed.x);
      //}
    }
    else
    {
      //if(speed.x == 0 && speed.y == 0)
      //{
      //  spin.set(0,-1);
      //}
      //else
      //{
        spin.set(-speed.y,speed.x);
      //}
    }
    spin.normalize();
    //spin.mult((leftEngine/501 + rightEngine/501)* (maxSpeed/2));
    spin.mult(abs(ratio));
    PVector desired = PVector.add(spin,speed);
    desired.normalize();
    desired.mult(maxSpeed);
    PVector steer = PVector.sub(desired,speed);
    steer.limit(maxForce);
    return steer;
  }
  
  
    
    
      
}
