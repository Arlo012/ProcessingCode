void UpdateAsteroids(ArrayList<Asteroid> _asteroids)
{
  for (Iterator<Asteroid> iterator = _asteroids.iterator(); iterator.hasNext();) 
  {
    Asteroid roid = iterator.next();
    roid.Update();
    if (roid.toBeKilled) 
    {
        // Remove the current element from the iterator and the list.
        iterator.remove();
    }
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

void UpdateMissiles(ArrayList<Missile> _missiles)
{
  for (Iterator<Missile> iterator = _missiles.iterator(); iterator.hasNext();) 
  {
    Missile missile = iterator.next();
    missile.Update();
    if (missile.toBeKilled) 
    {
        // Remove the current element from the iterator and the list.
        iterator.remove();
    }
  }
}
