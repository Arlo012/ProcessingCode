//******* DRAW ********//

void DrawObjects(ArrayList<? extends Drawable> _objects)
{
  for(Drawable a : _objects)
  {
    a.DrawObject();
  }
}

/**
 * Draw sectors and all child objects
 * @param {Hashmap<Int,Sector> _sectors Draw sector background
 * then all objects on top of it
 */
void DrawSectors(Map<Integer, Sector> _sectors)
{
  //Draw sector backgrounds themselves
  for(Sector a : _sectors.values())
  {
    a.DrawObject();

    if(debugMode.value)
    {
      a.collider.DrawObject();
    }
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.planets);     //Stations drawn here too
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.asteroids);
  }

  for(Sector a : _sectors.values())
  {
    DrawObjects(a.ships);
  }
}

/**
 * Draw a raw arraylist of sector objects and their contents
 * @param {ArrayList<Sector>} _sectors Sector list to draw
 */
void DrawSectors(ArrayList<Sector> _sectors)
{
  //Draw sector backgrounds themselves
  for(Sector a : _sectors)
  {
    a.DrawObject();
  }

  for(Sector a : _sectors)
  {
    ArrayList<Planet> planets = a.planets;
    DrawObjects(planets);     //Stations drawn here too
  }

  for(Sector a : _sectors)
  {
    ArrayList<Asteroid> asteroids = a.asteroids;
    DrawObjects(asteroids);
  }

  for(Sector a : _sectors)
  {
    ArrayList<Ship> ships = a.ships;
    DrawObjects(ships);
  }
}


void DrawShields(ArrayList<Shield> _shields)
{
  for(Shield shield : _shields)
  {
    //Draw shield
    if(shield.collidable)
    {
      //TODO allow for shield rotation (need a physical object with rotation, shape wont cut it)
      shield.overlay.DrawObject();
    }
  }
}

//******* MOVE ********//

/**
 * Move all objects in a sector
 * @param _sectors [description]
 */
void MoveSectorObjects(Map<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.planets);     //Stations drawn here too
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.asteroids);
  }

  for(Sector a : _sectors.values())
  {
    MovePhysicalObject(a.ships);
  }
}

//Move an array of movable objects
void MovePhysicalObject(ArrayList<? extends Physical> physical)
{
  for(Physical a : physical)
  {
    a.Move();
  }
}

//******* ZOOM ********//

void BeginZoom()
{
  pushMatrix();
  translate(-wvd.orgX * wvd.viewRatio, -wvd.orgY * wvd.viewRatio);
  scale(wvd.viewRatio);
}

void EndZoom()
{
  popMatrix();
}

//******* EXPLOSIONS ********//

//Generate a number of explosions, generally upon the death of some ship, station, etc
void GenerateDeathExplosions(int _count, PVector _center, PVector _deadObjSize)
{
  for(int i = 0; i < _count; i++)
  {
    float explosionScale = rand.nextFloat() + 0.5;    //explosion scale 0.5-1.5
    PVector explosionSize = new PVector(explosionScale * 64, explosionScale * 48);  //Scale off standard size
    PVector spawnLoc = new PVector(_center.x + _deadObjSize.x/2 * rand.nextFloat() - 0.5, 
                  _center.y + _deadObjSize.y/2 * rand.nextFloat() - 0.5);
    
    Explosion explosion = new Explosion(spawnLoc, explosionSize); 
    int frameDelay = rand.nextInt(60);                //Delay 0-60 frames
    explosion.SetRenderDelay(frameDelay);             //Setup delay on this explosion to render
    
    //TODO add global explosion
    explosions.add(explosion);                        //Add this explosion to an ArrayList<Explosion> for rendering
  }
}
