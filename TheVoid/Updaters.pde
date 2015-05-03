/*
 *  Updater methods on physical objects that run update loop and check for
 *  death condition.
 */

void UpdatePhysicalObjects(ArrayList<? extends Physical> _object)
{
  for (Iterator<? extends Physical> iterator = _object.iterator(); iterator.hasNext();) 
  {
    Physical obj = iterator.next();
    obj.Update();
    if (obj.toBeKilled) 
    {
      // Remove the current element from the iterator and the list.
      iterator.remove();
    }
  }
}


void UpdateSectors(ArrayList<Sector> _sectors)
{
  for(Sector a : _sectors)
  {
    UpdatePhysicalObjects(a.ships);
    UpdatePhysicalObjects(a.asteroids);
    UpdatePhysicalObjects(a.planets);    //Station updates occur in planet update loop
  }
}


void UpdateSectors(HashMap<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    UpdatePhysicalObjects(a.ships);
    UpdatePhysicalObjects(a.asteroids);
    UpdatePhysicalObjects(a.planets);  //Station updates occur in planet update loop
  }
}

