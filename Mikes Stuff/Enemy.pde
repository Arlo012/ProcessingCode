class Enemy
{
  PVector position;
  PVector speed;
  PVector acceleration;
  
  int size;
  float maxForce = 4;
  float maxSpeed = .1;
  
  Enemy(float posX, float posY)
  {
    position = new PVector(posX,posY);
    speed = new PVector(0,0);
    acceleration = new PVector(0,0);
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
    image(enemyIMG, position.x, position.y);
  }
}
  
