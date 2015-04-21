/*
* Generate Asteroids
* @param  area GameArea to render these asteroids on
* @see         GenerateAsteroids
* This function will generate asteroids in random locations on a given game area
*/
int initialAsteroidCount = 130;
int generationPersistenceFactor = 5;     //How hard should I try to generate the requested asteroids?
AsteroidFactory asteroidFactory = new AsteroidFactory();
void GenerateAsteroids(GameArea _area)
{
  println("INFO: Generating asteroids");
  
  //Tile arraylist constructor 
  int i = 0;      //Iterator  
  int timeoutCounter = 0;    //To check if loop has run too long
  boolean noOverlap = true;    //Is this coordinate original, or will it allow overlap?
  while(i < initialAsteroidCount)
  {
    //Generate new asteroid location, size, etc parameters
    asteroidFactory.SetNextAsteroidParameters(_area);
    
    //If we are doing asteroid collisions make sure none spawn over-lapped
    if(asteroidCollisionAllowed)
    {
      //Check that this asteroid will not spawn on top of another    
      
      PVector roidLoc = asteroidFactory.GetNextAsteroidLocation();    //Asteroid location
      int roidSize = asteroidFactory.Size();
      noOverlap = true;    //Assume this coordinate is good to begin
      for(Asteroid roid : asteroids)
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
        asteroids.add(asteroidFactory.GenerateAsteroid());
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
      asteroids.add(asteroidFactory.GenerateAsteroid());
      i++;
    }
  }
}

/*
* Generate Planets
* @param  area GameArea to render these planets on
* @param  planets ArrayList<Planets> to store planets in
* @param  count How many planets to spawn
* @see          GeneratePlanets
* This function will generate planets in random locations on a given game area
*/
PVector planetSizeRange = new PVector(50, 100);      //Min, max planet size
int borderSpawnDistance = 1;      //How far from the gameArea border should the planet spawn?
void GeneratePlanets(GameArea area, Civilization _civ, int count)
{
  //Guarantee no planets within 3 diameters from the edge of the game area
  println("Generating Planets");  
  int minX = int(area.GetLocation().x + planetSizeRange.y * borderSpawnDistance);
  int minY = int(area.GetLocation().y + planetSizeRange.y * borderSpawnDistance);
  int maxX = int(area.GetLocation().x + area.GetSize().x - planetSizeRange.y * borderSpawnDistance);
  int maxY = int(area.GetLocation().y + area.GetSize().y - planetSizeRange.y * borderSpawnDistance);
  
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
    for(Planet planet : _civ.planets)
    {
      //Check if this planet's center + diameter overlaps with planet's center + 4 * diameter
      if( Math.abs(planet.GetLocation().x-xCoor) < planet.GetSize().x * 1.5 + size * 1.5
            && Math.abs(planet.GetLocation().y-yCoor) < planet.GetSize().y * 1.5 + size * 1.5 )
      {
        noOverlap = false;
        println("INFO: Planet location rejected!");
        break;
      }
    }
    
    //Guarantee planets are too close to each oher
    if(noOverlap)
    {  
      Planet toBuild = new Planet("Planet", new PVector(xCoor, yCoor), size, int(10000*size/planetSizeRange.y), _civ);
      toBuild.SetRotationRate(rotateSpeed);
      toBuild.SetRotationMode(RotationMode.SPIN);    //Spinning
      toBuild.SetMaxSpeed(0);        //Local speed limit for planet (don't move)
      //TODO direction random?
      _civ.planets.add(toBuild);
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

/*
 * Checks for any offscreen asteroids, despawns them, and replaces them
 * Note: this assumes no asteroid collisions
*/
ArrayList<Asteroid> toSpawn = new ArrayList<Asteroid>();
void AsteroidOffScreenUpdate(ArrayList<Asteroid> _roids, Map<String,GameArea> _areaMap)
{
  if(asteroidCollisionAllowed)
  {
    println("WARNING: Asteroid respawn not supported for collidable asteroids");
  }
  else
  {
    //See example @ http://stackoverflow.com/questions/223918/iterating-through-a-list-avoiding-concurrentmodificationexception-when-removing
    for (Iterator<Asteroid> iterator = _roids.iterator(); iterator.hasNext();) 
    {
      Asteroid roid = iterator.next();
      if (roid.isOffScreen) 
      {
        // Remove the current element from the iterator and the list.
        iterator.remove();
        
        //Generate new asteroid
        
        int spawnAreaRandom = rand.nextInt(2);
        String areaToSpawn = new String("");
        if(spawnAreaRandom == 1)
        {
          areaToSpawn = "Top Asteroid Spawn";
        }
        else
        {
          areaToSpawn = "Bottom Asteroid Spawn";
        }

        asteroidFactory.SetNextAsteroidParameters(_areaMap.get(areaToSpawn));
        asteroidFactory.OverrideYDirection(spawnAreaRandom == 1 ? 1 : -1);      //If spawned @ top go down & vice versa
        Asteroid toAdd = asteroidFactory.GenerateAsteroid();
        //Generate a new asteroid to replace
        toSpawn.add(toAdd);
      }
    }
    
  }
  
  //Add all new asteroids
  if(!toSpawn.isEmpty())
  {
    for(Asteroid roid : toSpawn)
    {
      _roids.add(roid);
    }
    toSpawn.clear();

  }
}

//For a given civilization, generate stations around its planets
void GenerateStations(Civilization _civ, int count)
{
  //Create possible station locations around each planet
  ArrayList<PVector> stationOrbitLocationCandidates = new ArrayList<PVector>();
  
  for(Planet p : _civ.planets)
  {
    PVector locationCandidate1 = new PVector(p.location.x - 75, p.location.y);
    PVector locationCandidate2 = new PVector(p.location.x + 75, p.location.y);
    PVector locationCandidate3 = new PVector(p.location.x, p.location.y - 75);
    PVector locationCandidate4 = new PVector(p.location.x, p.location.y + 75);
    stationOrbitLocationCandidates.add(locationCandidate1);
    stationOrbitLocationCandidates.add(locationCandidate2);
    stationOrbitLocationCandidates.add(locationCandidate3);
    stationOrbitLocationCandidates.add(locationCandidate4);
  }
  
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
    if(_civ.ID == 1)    //Blue
    {
      if(stationLevel == 1)
      {
        station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation1, P1);
      }
      else if(stationLevel == 2)
      {
        station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation2, P1);
      }
      else
      {
        station = new Station(StationType.MILITARY, stationLoc, stationSize, blueStation3, P1);
      }
      
    }
    else                //Red
    {
      if(stationLevel == 1)
      {
        station = new Station(StationType.MILITARY, stationLoc, stationSize, redStation1, P2);
      }
      else if(stationLevel == 2)
      {
        station = new Station(StationType.MILITARY, stationLoc, stationSize, redStation2, P2);
      }
      else
      {
        station = new Station(StationType.MILITARY, stationLoc, stationSize, redStation3, P2);
      }
    }
    
    _civ.stations.add(station);
  }
}
