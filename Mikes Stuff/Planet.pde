class Planet
{
  int maxDiameter = 50;
  int minDiameter = 30;
  float diameter;
  PVector position;
  
  Planet(float posX,float posY)
  {
    position = new PVector(posX,posY);
    diameter = random(minDiameter,maxDiameter);
  }
  
  void display()
  {
    image(planetIMG, position.x, position.y, diameter, diameter);
  }
  
}
