//******* DRAW ********//

//Draw asteroid game object
void DrawAsteroids(ArrayList<Asteroid> _asteroids, boolean _displayIcons)
{
  for(Asteroid a : _asteroids)
  {
    a.DrawObject();
    if(_displayIcons && a.drawOverlay)
    {
      a.iconOverlay.DrawObject();
    }
  }
}

//Draw structure game object
void DrawStations(ArrayList<Station> _stations)
{
  for(Station a : _stations)
  {
    a.DrawObject();
  }
}


void DrawGameArea(Map<String, GameArea> _gameAreas)
{
  for(GameArea a : _gameAreas.values())
  {
    a.DrawObject();
  }
}

void DrawShips(ArrayList<Ship> _ships, boolean _displayIcons)
{
  for(Ship a : _ships)
  {
    a.DrawObject();
    if(_displayIcons)
    {
      a.iconOverlay.DrawObject();
    }
    
    //Actions if this ship is currently selected by the player
    if(a.currentlySelected)
    {
      if(a.currentOrder != null)
      {
        //HACK this shouldn't be in here -- handle inside pilotable class somewhere
        pushStyle();
        stroke(color(#E5F236));      //Draw a yellow line to indicate actual course
        
        //Handle in absolute coordinates (w/o translate) because delta position difficult to calculate
        line(a.location.x,a.location.y, a.currentOrder.location.x, a.currentOrder.location.y);
        a.currentOrder.DrawObject();      //Draw the current order
        popStyle();
      }

      for(Order o : a.orders)
      {
        //Draw order waypoints
        o.DrawObject();
      }
    }
  }
}

void DrawMissiles(ArrayList<Missile> _missiles, boolean _displayIcons)
{
  for(Missile a : _missiles)
  {
    a.DrawObject();
    if(_displayIcons)
    {
      a.iconOverlay.DrawObject();
    }
    
    //Actions if this ship is currently selected by the player
    if(a.currentlySelected)
    {
      if(a.currentOrder != null)
      {
        //HACK this shouldn't be in here -- handle inside pilotable class somewhere
        pushStyle();
        stroke(color(#E5F236));      //Draw a yellow line to indicate actual course
        
        //Handle in absolute coordinates (w/o translate) because delta position difficult to calculate
        line(a.location.x,a.location.y, a.currentOrder.location.x, a.currentOrder.location.y);
        a.currentOrder.DrawObject();      //Draw the current order
        popStyle();
      }

      for(Order o : a.orders)
      {
        //Draw order waypoints
        o.DrawObject();
      }
    }
  }
}

void DrawLasers(ArrayList<LaserBeam> _projectiles)
{
  for(LaserBeam lb : _projectiles)
  {
    lb.DrawObject();
  }
}

void DrawPlanets(ArrayList<Planet> _planets)
{
  for(Planet a : _planets)
  {
    a.DrawObject();
  }
}

void DrawEffects(ArrayList<Explosion> _effect)
{
  for(Explosion a : _effect)
  {
    a.DrawObject();
  }
}

void DrawButtons(ArrayList<ToggleButton> _buttons)
{
  for(ToggleButton a : _buttons)
  {
    a.DrawObject();
  }
}

void DrawShapes(ArrayList<Shape> _shapes)
{
  for(Shape a : _shapes)
  {
    a.DrawObject();
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

//Move an array of movable objects
void MovePhysicalObject(ArrayList<? extends Physical> physical)
{
  for(Physical a : physical)
  {
    a.Move();
  }
}

//Move an array of pilotable objects
void MovePilotableObject(ArrayList<? extends Pilotable> pilotable)
{
  for(Pilotable a : pilotable)
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
    
    explosions.add(explosion);                        //Add this explosion to an ArrayList<Explosion> for rendering
  }
}
