/*
* Generate Asteroids
* @param  sector Sector to render these asteroids on
* @see         GenerateAsteroids
* This function will generate asteroids in random locations on a given game area
*/
int initialAsteroidCount = 20;
int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
AsteroidFactory asteroidFactory = new AsteroidFactory();
void GenerateAsteroids(Sector sector)
{
  println("INFO: Generating asteroids");
  
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
        println("INFO: Asteroid location rejected!");
        break;
      }
    }
    
    if(noOverlap)
    {  
      sector.asteroids.add(asteroidFactory.GenerateAsteroid());
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
}

/*
* Generate Planets
* @param  sector Sector to render these planets on
* @param  count How many planets to spawn
* @see          GeneratePlanets
* This function will generate planets in random locations on a given sector
*/
PVector planetSizeRange = new PVector(50, 100);      //Min, max planet size
int borderSpawnDistance = 1;      //How far from the gameArea border should the planet spawn?
void GeneratePlanets(Sector sector, int count)
{
  //Guarantee no planets within 3 diameters from the edge of the game area
  println("Generating Planets");  
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
    
    //Generate random rotation speed
    float rotateSpeed = .01 * rand.nextFloat() - .005;    //Generate random spinning value (-0.005, .005];
    
    //Check that this planet will not spawn too near one another 
    noOverlap = true;    //Assume this coordinate is good to begin
    
    //TODO re-implement
    // for(Planet planet : _civ.planets)
    // {
    //   //Check if this planet's center + diameter overlaps with planet's center + 4 * diameter
    //   if( Math.abs(planet.GetLocation().x-xCoor) < planet.GetSize().x * 1.5 + size * 1.5
    //         && Math.abs(planet.GetLocation().y-yCoor) < planet.GetSize().y * 1.5 + size * 1.5 )
    //   {
    //     noOverlap = false;
    //     println("INFO: Planet location rejected!");
    //     break;
    //   }
    // }
    
    //Guarantee planets are too close to each oher
    if(noOverlap)
    {  
      Planet toBuild = new Planet("Planet", new PVector(xCoor, yCoor), size, int(10000*size/planetSizeRange.y));
      toBuild.SetRotationRate(rotateSpeed);
      toBuild.SetRotationMode(RotationMode.SPIN);    //Spinning
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)

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
        print(" planet(s)\n");
        break;    //abort the generation loop
      }
    }
  }
}

//Checks if an object implements an interface, returns bool
public static boolean implementsInterface(Object object, Class interf){
    return interf.isInstance(object);
}

//For a given planet, generate stations around it
void GenerateStations(Planet planet, int count)
{
  //Create possible station locations around each planet
  ArrayList<PVector> stationOrbitLocationCandidates = new ArrayList<PVector>();
  
  PVector locationCandidate1 = new PVector(planet.location.x - 75, planet.location.y);
  PVector locationCandidate2 = new PVector(planet.location.x + 75, planet.location.y);
  PVector locationCandidate3 = new PVector(planet.location.x, planet.location.y - 75);
  PVector locationCandidate4 = new PVector(planet.location.x, planet.location.y + 75);
 
  stationOrbitLocationCandidates.add(locationCandidate1);
  stationOrbitLocationCandidates.add(locationCandidate2);
  stationOrbitLocationCandidates.add(locationCandidate3);
  stationOrbitLocationCandidates.add(locationCandidate4);
  
  for(int i = 0; i < count; i++)
  {
    //Random size
    int sizeGen = rand.nextInt(Station.maxStationSize * 2/3) + Station.maxStationSize * 1/2;       //TODO how does this work again?
    PVector stationSize = new PVector(sizeGen, sizeGen);
    
    //Randomly select station location from generated list above
    int locationSelectedIndex = rand.nextInt(stationOrbitLocationCandidates.size());
    PVector stationLoc = stationOrbitLocationCandidates.get(locationSelectedIndex);
    stationOrbitLocationCandidates.remove(locationSelectedIndex);
    
    //Select station color & build station
    Station station;
    int stationLevel = rand.nextInt(2) + 1;
    if(stationLevel == 1)
    {
      station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation1);
    }
    else if(stationLevel == 2)
    {
      station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation2);
    }
    else
    {
      station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation3);
    }

    //TODO add this to sector
    // _civ.stations.add(station);
  }
}
