
//Draw asteroid game object
void DrawAsteroids(ArrayList<Asteroid> _asteroids)
{
  for(Asteroid a : _asteroids)
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

void DrawShips(ArrayList<Ship> _ships)
{
  for(Ship a : _ships)
  {
    a.DrawObject();
  }
}

void DrawPlanets(ArrayList<Planet> _planets)
{
  for(Planet a : _planets)
  {
    a.DrawObject();
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

//Move an array of pilotable objects
void MovePilotableObject(ArrayList<? extends Pilotable> pilotable)
{
  for(Pilotable a : pilotable)
  {
    a.Move();
  }
}


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
