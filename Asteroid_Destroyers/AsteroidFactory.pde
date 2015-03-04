/*
 * Generates asteroids
*/

public class AsteroidFactory
{
  //Default values
  private PVector asteroidSizeRange = new PVector(10, 20);      //Min, max asteroid size
  private PVector maxVelocity = new PVector(0.01,0.65);                 //Max velocity in given x/y direction of asteroid

  //Generator values (keep these stored for next asteroid to create
  private int minX, minY, maxX, maxY, size, xCoor, yCoor;
  private float rotateSpeed, xVelocity, yVelocity;

  AsteroidFactory(){
  }

  AsteroidFactory(PVector _sizeRange)
  {
    asteroidSizeRange = _sizeRange;
  }
  
  void SetMaxVelocity(PVector _maxVelocity)
  {
    maxVelocity = _maxVelocity;
  }
  
  
  //Generate a new asteroid in a given area
  void SetNextAsteroidParameters(GameArea _area)
  {
    minX = int(_area.GetLocation().x);
    minY = int(_area.GetLocation().y);
    maxX = int(_area.GetSize().x);
    maxY = int(_area.GetSize().y);
  
    size = rand.nextInt(int(asteroidSizeRange.y - asteroidSizeRange.x))+ int(asteroidSizeRange.x);
    
    //Generate a random X coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size
    xCoor = rand.nextInt(maxX - int(asteroidSizeRange.y)) + minX + int(asteroidSizeRange.y/2);
    yCoor = rand.nextInt(maxY)+minY;
    
    //Generate random rotation speed
    rotateSpeed = .02 * rand.nextFloat() - .01;    //Generate random spinning value (-0.01, .01];
    
    //Generate random movement vector
    xVelocity = 2 * maxVelocity.x * rand.nextFloat() - maxVelocity.x;    //Desensitize in x direction
    yVelocity = 2 * maxVelocity.y * rand.nextFloat() - maxVelocity.y;
  }
  
  
  //Build asteroid with parameters generated in SetNextAsteroidParameters and return it
  Asteroid GenerateAsteroid()
  {
    Asteroid toBuild = new Asteroid("Asteroid", new PVector(xCoor, yCoor), size, int(10000*size/asteroidSizeRange.y));
    toBuild.SetRotationRate(rotateSpeed);
    toBuild.SetVelocity(new PVector(xVelocity, yVelocity));
    toBuild.SetRotationMode(1);    //Spinning
    toBuild.SetMaxSpeed(2.5);      //Local speed limit for asteroid
    //TODO direction random?
    
    return toBuild;
  }
  
  PVector GetNextAsteroidLocation()
  {
    return new PVector(xCoor, yCoor);
  }
  
  int Size()
  {
    return size;
  }
  
  //Force the asteroid's Y direction to have this sign (for use with spawn areas)
  void OverrideYDirection(float _sign)
  {
    if(_sign > 0)    //DOWN, positive
    {
      if(yVelocity < 0)    //Flip, making positive
      {
        yVelocity *= -1;
      }
    }
    else            //UP, negative
    {
      if(yVelocity > 0)
      {
        yVelocity *= -1;    //Flip, making negative
      }
    }
  }
}
