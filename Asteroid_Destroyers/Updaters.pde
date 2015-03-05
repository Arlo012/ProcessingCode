void UpdateAsteroids(ArrayList<Asteroid> _asteroids)
{
  for(Asteroid a : _asteroids)
  {
    a.Update();
  }
}

void UpdateShips(ArrayList<Ship> _ships)
{
  for(Ship a : _ships)
  {
    a.Update();
  }
}

void UpdatePlanets(ArrayList<Planet> _planets)
{
  for(Planet a : _planets)
  {
    a.Update();
  }
}
