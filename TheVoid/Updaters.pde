/*
 *  This is a bunch of updater methods that iterate through arraylist of objects.
 *  It is pretty clunky to do it this way, but there are problems with child objects 
 *  having different update methods than their parents. 
 *     TODO: Investigate a way around this
 */

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
  for (Iterator<Ship> iterator = _ships.iterator(); iterator.hasNext();) 
  {
    Ship ship = iterator.next();
    ship.Update();
    if (ship.toBeKilled) 
    {
        // Remove the current element from the iterator and the list.
        iterator.remove();
    }
  }
}

void UpdateShields(ArrayList<Shield> _shields)
{
  for (Iterator<Shield> iterator = _shields.iterator(); iterator.hasNext();) 
  {
    Shield shield = iterator.next();
    shield.Update();
    if (shield.toBeKilled) 
    {
      // Remove the current element from the iterator and the list.
      iterator.remove();
    }
  }
}

void UpdatePlanets(ArrayList<Planet> _planets)
{
  for(Planet a : _planets)
  {
    a.Update();
  }
}

void UpdateStations(ArrayList<Station> _stations)
{
  for (Iterator<Station> iterator = _stations.iterator(); iterator.hasNext();) 
  {
    Station station = iterator.next();
    station.Update();
    if (station.toBeKilled) 
    { 
      // Remove the current element from the iterator and the list.
      iterator.remove();
    }
  }
}

void UpdateLasers(ArrayList<LaserBeam> _lasers)
{
  for (Iterator<LaserBeam> iterator = _lasers.iterator(); iterator.hasNext();) 
  {
    LaserBeam beam = iterator.next();
    beam.Update();
    if (beam.toBeKilled) 
    { 
      // Remove the current element from the iterator and the list.
      iterator.remove();
    }
  }
}

void UpdateExplosions(ArrayList<Explosion> _explosion)
{
  for (Iterator<Explosion> iterator = _explosion.iterator(); iterator.hasNext();) 
  {
    Explosion explosion = iterator.next();
    if (explosion.toBeKilled) 
    { 
      // Remove the current element from the iterator and the list.
      iterator.remove();
    }
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
