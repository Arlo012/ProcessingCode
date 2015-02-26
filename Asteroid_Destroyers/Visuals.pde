
//Draw asteroid game object
void DrawAsteroid(ArrayList<Asteroid> _asteroids)
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

//Move an array of movable objects
void MoveGameObjects(ArrayList<? extends Movable> _movable)
{
  for(Movable toMove : _movable)
  {
    toMove.Move();
  }
}


//******* ROTATE *********/ 

//TODO (weird) this is a wrapper
void Rotate(float _angle)
{
  rotate(radians(_angle));
}


//Returns current angle
float closeEnoughAngle = 0.2;
float RotateInDirection(float _currentAngle, float _rotationRate)
{
  rotate(_currentAngle + _rotationRate);
  return _currentAngle + _rotationRate;
}

float RotateToFacePoint(float _currentAngle, PVector _myCenter, PVector _objectToFace)
{
  PVector up = PVector.fromAngle(radians(_currentAngle));
  println(up.x);
  float angBetween = PVector.angleBetween(up, _objectToFace);
  //println(degrees(angBetween));
  float newAngle = atan2(_objectToFace.y - _myCenter.y, _objectToFace.x - _myCenter.x);
  //if( (_myCenter.x - _objectToFace.x) * 
  rotate(newAngle);
  return newAngle;
}
