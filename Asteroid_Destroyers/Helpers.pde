/*
* Generate Asteroids
* @param  area GameArea to render these asteroids on
* @see         GenerateAsteroids
* This function will generate asteroids in random locations on a given game area
*/
int initialAsteroidCount = 250;
PVector asteroidSizeRange = new PVector(10, 35);      //Min, max asteroid size
int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
PVector maxVelocity = new PVector(0.01,0.65);                 //Max velocity in given x/y direction of asteroid
void GenerateAsteroids(GameArea area)
{
  println("Generating asteroids");
  int minX = int(area.GetLocation().x);
  int minY = int(area.GetLocation().y);
  int maxX = int(area.GetSize().x);
  int maxY = int(area.GetSize().y);
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;    //To check if loop has run too long
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
    float xVelocity = 2 * maxVelocity.x * rand.nextFloat() - maxVelocity.x;    //Desensitize in x direction
    float yVelocity = 2 * maxVelocity.y * rand.nextFloat() - maxVelocity.y;
    
    //If we are doing asteroid collisions make sure none spawn over-lapped
    if(asteroidCollisionAllowed)
    {
        //Check that this asteroid will not spawn on top of another    
      noOverlap = true;    //Assume this coordinate is good to begin
      for(Asteroid roid : asteroids)
      {
        //Check if this asteroid's center + diameter overlaps with roid's center + diameter
        if( Math.abs(roid.GetLocation().x-xCoor) < roid.GetSize().x/2 + size/2 
              && Math.abs(roid.GetLocation().y-yCoor) < roid.GetSize().y/2 + size/2 )
        {
          noOverlap = false;
          //println("Asteroid location rejected!");
          break;
        }
      }
      
      if(noOverlap)
      {  
        Asteroid toBuild = new Asteroid(new PVector(xCoor, yCoor), size, int(10000*size/asteroidSizeRange.y));
        toBuild.SetRotationRate(rotateSpeed);
        toBuild.SetVelocity(new PVector(xVelocity, yVelocity));
        toBuild.SetRotationMode(1);    //Spinning
        toBuild.SetMaxSpeed(2.5);      //Local speed limit for asteroid
        //TODO direction random?
        asteroids.add(toBuild);
        //println("Built an asteroid!");
        i++;
      }
      else
      {
        //Failed to generate the asteroid
        timeoutCounter++;
        if(timeoutCounter > generationPersistenceFactor * initialAsteroidCount)
        {
          print("Asteroid generation failed for ");
          print(initialAsteroidCount - i);
          print(" asteroid(s)\n");
          break;    //abort the generation loop
        }
      }
    }
    
    else    //We dont care about asteroid collisions, just spawn normally
    {
      //HACK - this code is repeated from above
      Asteroid toBuild = new Asteroid(new PVector(xCoor, yCoor), size, int(10000*size/asteroidSizeRange.y));
      toBuild.SetRotationRate(rotateSpeed);
      toBuild.SetVelocity(new PVector(xVelocity, yVelocity));
      toBuild.SetRotationMode(1);    //Spinning
      toBuild.SetMaxSpeed(2.5);      //Local speed limit for asteroid
      //TODO direction random?
      asteroids.add(toBuild);
      i++;
    }
    

  }
}

void GenerateAsteroidSpin()
{
  //TODO implement me
}


/*
* Generate Planets
* @param  area GameArea to render these planets on
* @param  planets ArrayList<Planets> to store planets in
* @param  count How many planets to spawn
* @see          GeneratePlanets
* This function will generate planets in random locations on a given game area
*/
PVector planetSizeRange = new PVector(20, 35);      //Min, max planet size
void GeneratePlanets(GameArea area, ArrayList<Planet> planets, int count)
{
  println("Generating Planets");
  int minX = int(area.GetLocation().x + planetSizeRange.x * 2);
  int minY = int(area.GetLocation().y + planetSizeRange.y * 2);
  int maxX = int(area.GetSize().x - planetSizeRange.x * 2);
  int maxY = int(area.GetSize().y - planetSizeRange.y * 2);
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;      //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < count)
  {
    int size = rand.nextInt(int(planetSizeRange.y - planetSizeRange.x))+ int(planetSizeRange.x);
    
    //Generate a random X/Y coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size
    int xCoor = rand.nextInt(maxX - int(planetSizeRange.y)) + minX + int(planetSizeRange.y/2);
    int yCoor = rand.nextInt(maxY)+minY;
    
    //Generate random rotation speed
    float rotateSpeed = .01 * rand.nextFloat() - .005;    //Generate random spinning value (-0.005, .005];
    
    //Check that this planet will not spawn on top of another    
    noOverlap = true;    //Assume this coordinate is good to begin
    for(Planet planet : planets)
    {
      //Check if this planet's center + diameter overlaps with planet's center + 4 * diameter
      if( Math.abs(planet.GetLocation().x-xCoor) < planet.GetSize().x/2 + 2 * size 
            && Math.abs(planet.GetLocation().y-yCoor) < planet.GetSize().y/2 + 2 * size )
      {
        noOverlap = false;
        println("Planet location rejected!");
        break;
      }
    }
    
    //Guarantee planets are too close to each oher
    if(noOverlap)
    {  
      Planet toBuild = new Planet(new PVector(xCoor, yCoor), size, int(10000*size/planetSizeRange.y));
      toBuild.SetRotationRate(rotateSpeed);
      toBuild.SetRotationMode(1);    //Spinning
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)
      //TODO direction random?
      planets.add(toBuild);
      //println("Built a planet!");
      i++;
    }
    else
    {
      //Failed to generate the planet
      timeoutCounter++;
      if(timeoutCounter >  4 * count)    //Try to generate 4x as many planets
      {
        print("Planet generation failed for ");
        print(count - i);
        print(" asteroid(s)\n");
        break;    //abort the generation loop
      }
    }
    
  }
}


//Checks if an object implements an interface, returns bool
public static boolean implementsInterface(Object object, Class interf){
    return interf.isInstance(object);
}
