
int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
AsteroidFactory asteroidFactory = new AsteroidFactory();
/**
* This function will generate asteroids in random locations on a given game area. If too 
* many asteroids are requested the function will only generate as many as it can without
* overlapping.
* @param  {Sector} sector Sector to render these asteroids on
* @param  {Integer} initialAsteroidCount how many asteroids to generate (max)
* @see  Sector.pde for implementation, AsteroidFactory.pde for generation of asteroids
*/
void GenerateAsteroids(Sector sector, int initialAsteroidCount)
{
  println("[INFO] Generating asteroids");
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;    //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < initialAsteroidCount)
  {
    //Generate new asteroid location, size, etc parameters
    asteroidFactory.SetNextAsteroidParameters(sector);
    
    PVector roidLoc = asteroidFactory.GetNextAsteroidLocation();    //Asteroid location
    int roidSize = asteroidFactory.Size();
    noOverlap = true;    //Assume this coordinate is good to begin
    for(Asteroid roid : sector.asteroids)
    {
      //Check if this asteroid's center + diameter overlaps with roid's center + diameter
      if( Math.abs(roid.GetLocation().x-roidLoc.x) < roid.GetSize().x/2 + roidSize/2 
            && Math.abs(roid.GetLocation().y-roidLoc.y) < roid.GetSize().y/2 + roidSize/2 )
      {
        noOverlap = false;
        println("[INFO] Asteroid location rejected!");
        break;
      }
    }
    
    if(noOverlap)
    { 
      Asteroid toAdd = asteroidFactory.GenerateAsteroid();
      toAdd.baseAngle = rand.nextInt((360) + 1);
      sector.asteroids.add(toAdd);
      i++;
    }
    else
    {
      //Failed to generate the asteroid
      timeoutCounter++;
      if(timeoutCounter > generationPersistenceFactor * initialAsteroidCount)
      {
        print("[WARNING] Asteroid generation failed for ");
        print(initialAsteroidCount - i);
        print(" asteroid(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}


PVector planetSizeRange = new PVector(50, 100);      //Min, max planet size
int borderSpawnDistance = 1;      //How far from the gameArea border should the planet spawn?
/**
* Generate planets in random locations on a given sector
* @param  {Sector} sector Sector to render these planets on
* @param  Integer} count How many planets to spawn
* @see  Sector.pde for implementation
*/
void GeneratePlanets(Sector sector, int count)
{
  //Guarantee no planets within 3 diameters from the edge of the game area
  println("[INFO] Generating Planets");  
  int minX = int(sector.GetLocation().x + planetSizeRange.y * borderSpawnDistance);
  int minY = int(sector.GetLocation().y + planetSizeRange.y * borderSpawnDistance);
  int maxX = int(sector.GetLocation().x + sector.GetSize().x - planetSizeRange.y * borderSpawnDistance);
  int maxY = int(sector.GetLocation().y + sector.GetSize().y - planetSizeRange.y * borderSpawnDistance);
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;      //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < count)
  {
    int size = rand.nextInt(int(planetSizeRange.y - planetSizeRange.x))+ int(planetSizeRange.x);
    
    //Generate a random X/Y coordinate guaranteed to be within the boundary
    //accounting for the diameter of the asteroid where asteroidSizeRange.y is max size

    int xCoor = rand.nextInt(maxX-minX)+minX;
    int yCoor = rand.nextInt(maxY-minY)+minY;
    
    //Check that this planet will not spawn too near one another 
    noOverlap = true;    //Assume this coordinate is good to begin
    
    //TODO re-implement
    for(Planet planet : sector.planets)
    {
      //Check if this planet's center + diameter overlaps with planet's center + 4 * diameter
      if( Math.abs(planet.GetLocation().x-xCoor) < planet.GetSize().x * 1.5 + size * 1.5
            && Math.abs(planet.GetLocation().y-yCoor) < planet.GetSize().y * 1.5 + size * 1.5 )
      {
        noOverlap = false;
        println("[INFO] Planet location rejected!");
        break;
      }
    }
    
    //Guarantee planets are too close to each oher
    if(noOverlap)
    {  
      Planet toBuild = new Planet("Planet", new PVector(xCoor, yCoor), size, int(10000*size/planetSizeRange.y), sector);
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)
      toBuild.baseAngle = rand.nextInt((360) + 1);
      sector.planets.add(toBuild);
      println("[INFO] Generated a new planet at " + toBuild.location + " in sector " + sector.name);
      i++;
    }
    else
    {
      //Failed to generate the planet
      timeoutCounter++;
      if(timeoutCounter >  4 * count)    //Try to generate 4x as many planets
      {
        print("[WARNING] Planet generation failed for ");
        print(count - i);
        print(" planet(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}


float shipScaleFactor = 0.25;     //Scale down ship sizes by this factor
/**
 * Build a given number of enemies on the provided Sector. If there
 * are planets, generate around the planet. If asteroid, generate
 * around asteroids. Else just generate anywhere in free space.
 * @param {Sector} sector Sector to build the enemies on
 * @param {Integer} count How many enemies to make
 */
void GenerateEnemies(Sector sector, int count)
{
  PVector position = sector.location.get();   //Default position at origin of sector

  int minX, minY, maxX, maxY;                 //Max allowed positions

  int enemyShipRandomIndex = rand.nextInt((enemyShipTypeCount -1) + 1);
  PImage enemySprite = enemyShipSprites.get(enemyShipRandomIndex).get();    //Make sure to get a COPY of the vector
  PVector enemyShipSize = enemyShipSizes.get(enemyShipRandomIndex).get();

  //Scale enemyshipsize
  enemyShipSize.x = int(shipScaleFactor * enemyShipSize.x);
  enemyShipSize.y = int(shipScaleFactor * enemyShipSize.y);

  if (enemyShipSize.x <= 0 || enemyShipSize.y <= 0)
  {
    println("[ERROR] Ship Scale error! Returning ship to standard size (large)");
    enemyShipSize = enemyShipSizes.get(enemyShipRandomIndex).get();
  }

  for(int i = 0; i < count; i++)
  {
    PVector shipSize = new PVector(75,30);
    if(sector.asteroids.size() > 0)   //This sector has asteroids -- check for overlap
    {
      boolean validLocation = false;
      while(!validLocation)
      {
        //Generation parameters
        minX = int(sector.GetLocation().x + enemyShipSize.x);
        minY = int(sector.GetLocation().y + enemyShipSize.y);
        maxX = int(sector.GetSize().x - enemyShipSize.x);
        maxY = int(sector.GetSize().y - enemyShipSize.y);

        //Generate position offsets from the sector location
        position.x = rand.nextInt(maxX - int(shipSize.x)) + minX + int(shipSize.x/2);
        position.y = rand.nextInt(maxY)+minY;

        for(Asteroid roid : sector.asteroids)
        {
          //Check if this asteroid's center + diameter overlaps with ships center = size
          if( Math.abs(roid.GetLocation().x-position.x) < roid.GetSize().x/2 + shipSize.x 
                && Math.abs(roid.GetLocation().y-position.y) < roid.GetSize().y/2 + shipSize.y )
          {
            validLocation = false;
            println("[INFO] Enemy placement location rejected!");
            break;
          }
          validLocation = true;   //Went thru each asteroid -- no overlap
        }
      }

    }
    else
    {      
      //Generation parameters
      minX = int(sector.GetLocation().x);
      minY = int(sector.GetLocation().y);
      maxX = int(sector.GetSize().x);
      maxY = int(sector.GetSize().y);

      //Generate position offsets from the sector location
      position.x = rand.nextInt(maxX - int(shipSize.x)) + minX + int(shipSize.x/2);
      position.y = rand.nextInt(maxY)+minY;
    }

    Enemy enemyGen = new Enemy("Bad guy", position, enemyShipSize, enemySprite, 
      1000, color(255,0,0), sector);
    enemyGen.baseAngle = rand.nextInt((360) + 1);     //Random rotation 0-360
    sector.ships.add(enemyGen);
  }

}

/**
 * Checks if an object implements an interface, returns boo
 * @param  object Any object
 * @param  interf Interface to compare against
 * @return {Boolean} True for implements, false if doesn't
 */
public static boolean implementsInterface(Object object, Class interf){
    return interf.isInstance(object);
}

