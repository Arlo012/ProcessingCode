//******* DRAW ********//

//Draw asteroid game object
void DrawAsteroids(ArrayList<Asteroid> _asteroids, boolean _displayIcons)
{
  for(Asteroid a : _asteroids)
  {
    a.DrawObject();
    if(_displayIcons)
    {
      a.iconOverlay.DrawObject();
    }
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
        a.currentOrder.DrawObject();      //Draw the current order
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
