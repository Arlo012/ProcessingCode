class Asteroid
{
  int minDiameter = 10;
  int maxDiameter = 20;
  float maxSpeed = 5;
  float maxForce = .4;
  float sizeX;
  float sizeY;
  
  PVector position;
  PVector speed;
  PVector acceleration;
  
  Asteroid(float posX,float posY)
  {
    position = new PVector(posX,posY);
    speed = new PVector(0,0);
    acceleration = new PVector(0,0);
    sizeX = random(minDiameter,maxDiameter);
    sizeY = random(minDiameter,maxDiameter);
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
    image(asteroidIMG,position.x,position.y, sizeX, sizeY);
  }
    
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void applyBehavoirs()
  {
    
  }
}
  
  
