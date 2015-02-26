
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
void MoveGameObjects(ArrayList<? extends Movable> _movable)
{
  //WARNING be careful -- if any class uses an override for the move function this wont catch it
  for(Movable toMove : _movable)
  {
    toMove.Move();
  }
}
