
//Draw asteroid game object
void DrawAsteroids(ArrayList<Asteroid> _asteroids)
{
  for(Asteroid a : _asteroids)
  {
    a.DrawObject();
  }
}

void DrawGameArea(ArrayList<GameArea> _gameAreas)
{
  for(GameArea a : _gameAreas)
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

//Move an array of movable objects
void MovePhysicalObject(ArrayList<? extends Physical> physical)
{
  for(Physical a : physical)
  {
    a.Move();
  }
}
