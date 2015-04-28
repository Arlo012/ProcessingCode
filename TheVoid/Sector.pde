enum SectorType {
  ASTEROIDFIELD, EMPTY, PLANETARY
}

//An area in 2D space containing asteroids, planets, ships, stations, etc
public class Sector extends Drawable implements Updatable
{
  //Contents of this sector
  public ArrayList<Asteroid> asteroids;
  public ArrayList<Planet> planets;
  public ArrayList<Ship> ships;
  
  //Link to neighboring sectors
  public Sector aboveSector, belowSector, leftSector, rightSector,
                  ULSector, URSector, LLSector, LRSector;
  
  private color debugViewColor;
  private SectorType sectorType;

  //Sector parameters
  int minPlanets = 1;
  int maxPlanets = 4;
  int minAsteroids = 10;
  int maxAsteroids = 100;

  /*
  * Constructor
  * @param  _areaName string name of this game area
  * @param  _loc      posistion vector of sector location
  * @param  _size     size of the sector
  * @see         Sector
  */
  public Sector(int _ID, PVector _loc, PVector _size, PImage _background)
  {
    super(Integer.toString(_ID), _loc, _size);
    
    sprite = _background;
    sprite.resize(int(size.x), int(size.y));
    
    renderMode = CORNER;        //Don't draw sector in center
     
    //Object containers
    asteroids = new ArrayList<Asteroid>();
    planets = new ArrayList<Planet>();
    ships = new ArrayList<Ship>();
    
    //Determine what type of sector we are
    int sectorTypeRand = rand.nextInt((3 - 1) + 1) + 1;   //rand.nextInt((max - min) + 1) + min;
    if(sectorTypeRand == 1)
    {
      println("[INFO] Building asteroid field sector");
      sectorType = SectorType.ASTEROIDFIELD;
      
      //Generate asteroids in this sector
      int asteroidCount = rand.nextInt((maxAsteroids - minAsteroids) + 1) + minAsteroids;
      GenerateAsteroids(this, asteroidCount);
    }
    else if(sectorTypeRand == 2)
    {
      println("[INFO] Building empty sector");   
      sectorType = SectorType.EMPTY;
    }
    else if(sectorTypeRand == 3)
    {
      println("[INFO] Building planetary sector"); 
      sectorType = SectorType.PLANETARY;

      //Generate planets
      int planetCount = rand.nextInt((maxPlanets - minPlanets) + 1) + minPlanets;
      GeneratePlanets(this, planetCount);
    }
    else
    {
      println("[ERROR] Invalid sector type selected. Defaulting to asteroid field");  
      sectorType = SectorType.ASTEROIDFIELD;
      
      //Generate asteroids in this sector
      int asteroidCount = rand.nextInt((maxAsteroids - minAsteroids) + 1) + minAsteroids;
      GenerateAsteroids(this, asteroidCount);
    }

    //DEBUG INFO
    debugViewColor = color(255);    //Default = white
  }
  
  public void SetDebugColor(color _color)
  {
    debugViewColor = _color;
  }
  
  @Override public void DrawObject()
  {
    super.DrawObject();    //Draw using parent method
    
    //Draw this sector's game objects
    DrawAsteroids(asteroids, false);
    DrawPlanets(planets);
    DrawShips(ships, false);

    if(debugMode.value)    //Draw debug outline of sector
    {
      rectMode(CORNER);
      fill(debugViewColor, 50);
      rect(location.x, location.y, size.x, size.y);
    }
  }

  public void Update()
  {
    for(Ship ship : ships)
    {
      ship.Update();
      ship.ApplyBehaviors(1,1);
    }
  }
  
  /*
   * Check if this sector has already popualted & linked its neighbors
   */
  public boolean HasNeighbor(String _neighbor)
  {
    //Switch statements not allowed in Processing except on Strings/Enums
    if(_neighbor == "UL")
    {
      if(ULSector != null)    //If UL sector exists
      {
        return true;  
      }
      //Break out of ifs, return false
    }
    else if(_neighbor == "Above")
    {
      if(aboveSector != null)  
      {
        return true;  
      }
    }
    else if(_neighbor == "UR")
    {
      if(URSector != null)
      {
        return true;  
      }
    }
    else if(_neighbor == "Left")
    {
      if(leftSector != null)
      {
        return true;  
      }
    }
    else if(_neighbor == "Right")
    {
      if(rightSector != null)
      {
        return true;  
      }
    }
    else if(_neighbor == "LL")
    {
      if(LLSector != null)
      {
        return true;  
      }
    }
    else if(_neighbor == "Below")
    {
      if(belowSector != null)
      {
        return true;  
      }
    }
    else if(_neighbor == "LR")
    {
      if(LRSector != null) 
      {
        return true;  
      }
    }
    else    //A weird string was passed in....
    {
      println("[WARNING] Requested neighbor on unspecified direction.");
    } //<>//
    
    return false;
  }
}
