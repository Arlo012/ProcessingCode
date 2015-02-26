
/*
* Generate Asteroids
* @param  area GameArea to render these asteroids on
* @see         GenerateAsteroids
* This function will generate asteroids in random locations on a given game area
*/
int initialAsteroidCount = 100;
PVector asteroidSizeRange = new PVector(20, 75);      //Min, max asteroid size
int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
float maxVelocity = .15;                 //Max velocity in given x/y direction of asteroid
void GenerateAsteroids(GameArea area)
{
  println("Generating asteroids");
  int minX = int(area.GetCenter().x - area.GetSize().x/2);
  int minY = int(area.GetCenter().y - area.GetSize().y/2);
  int maxX = int(area.GetSize().x);
  int maxY = int(area.GetSize().y);
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int loopCounter = 0;    //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < initialAsteroidCount)
  {
    int size = rand.nextInt(int(asteroidSizeRange.y - asteroidSizeRange.x))+ int(asteroidSizeRange.x);
    
    //Generate a random X coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size
    int xCoor = rand.nextInt(maxX - int(asteroidSizeRange.y)) + minX + int(asteroidSizeRange.y/2);
    int yCoor = rand.nextInt(maxY)+minY;
    
    //Generate random rotation speed
    float rotateSpeed = .02 * rand.nextFloat() - .01;    //Generate random spinning value (-0.01, .01];
    
    //Generate random movement vector
    float xVelocity = (2 * maxVelocity * rand.nextFloat() - maxVelocity)/10;    //Desensitize in x direction
    float yVelocity = 2 * maxVelocity * rand.nextFloat() - maxVelocity;
    
    //Check that this asteroid will not spawn on top of another    
    noOverlap = true;    //Assume this coordinate is good to begin
    for(Asteroid roid : asteroids)
    {
      //Check if this asteroid's center + diameter overlaps with roid's center + diameter
      if( Math.abs(roid.GetCenter().x-xCoor) < roid.GetSize().x/2 + size/2 
            && Math.abs(roid.GetCenter().y-yCoor) < roid.GetSize().y/2 + size/2 )
      {
        noOverlap = false;
        //println("Asteroid location rejected!");
        break;
      }
    }
    
    if(noOverlap)
    {  
      Asteroid toBuild = new Asteroid(xCoor, yCoor, size);
      toBuild.SetRotationRate(rotateSpeed);
      toBuild.ChangeVelocity(new PVector(xVelocity, yVelocity));
      toBuild.SetRotationMode(1);    //Spinning
      //TODO direction random?
      asteroids.add(toBuild);
      //println("Built an asteroid!");
      i++;
    }
    
    loopCounter++;
    if(loopCounter > generationPersistenceFactor * initialAsteroidCount)
    {
      print("Asteroid generation failed for ");
      print(initialAsteroidCount - i);
      print(" asteroid(s)\n");
      break;    //abort the generation loop
    }
  }
}

void GenerateAsteroidSpin()
{
  //TODO implement me
}

//Check for keypresses
void keyPressed() 
{
  //Player 1 movement
  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
    }
    else if (keyCode == DOWN) 
    {
    }
  }
  
  if(key == ENTER)
  {
    asteroids.get(0).SetDestinationAngle(250);
    asteroids.get(0).SetRotationMode(1);    //Spin
    println("DEBUG: Rotating asteroid");
  }
  
  //Player 2 movement
  if (key == 'w') 
  {
    ships.get(0).SetRotationMode(2);
    ships.get(0).SetRotationTarget(new PVector(mouseX,mouseY));
  }
  else if (key == 's') 
  {
   
  }
  
}

//See http://www.openprocessing.org/sketch/123457
//Returns angle between two provided vectors 0-2pi rad
float vAtan2cent(PVector cent, PVector _v2, PVector _v1) {
  //Create local variables
  PVector v1 = new PVector(_v1.x, _v1.y);
  PVector v2 = new PVector(_v2.x, _v2.y);
  
  v1.sub(cent);
  v2.sub(cent);
  v2.mult(-1);
  float ang = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
  return ang;
}
