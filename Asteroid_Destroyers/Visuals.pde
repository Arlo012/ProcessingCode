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

void DrawPlanets(ArrayList<Planet> _planets)
{
  for(Planet a : _planets)
  {
    a.DrawObject();
  }
}

void DrawEffects(ArrayList<Effect> _effect)
{
  for(Effect a : _effect)
  {
    a.DrawObject();
  }
}

void DrawButtons(ArrayList<Button> _buttons)
{
  for(Button a : _buttons)
  {
    a.DrawObject();
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
    
    Effect explosion = new Effect("Explosion", spawnLoc, explosionSize, EffectType.EXPLOSION); 
    int frameDelay = rand.nextInt(60);
    explosion.SetRenderDelay(frameDelay);
    
    effects.add(explosion);
  }
}
