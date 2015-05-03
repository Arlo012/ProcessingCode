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

    if(obj.velocity.mag() > 0)      //If moving, check if it has left the sector
    {
      if(!CheckShapeOverlap(obj.currentSector.collider, obj.location))   //Is object inside the sector still?
      {
        println("[INFO] " + obj.name + " has left its parent sector...");
        //TODO should be doing rectangle-rectangle collision, not point-point. This should do for now
        //Object left sector -- find new sector it is in
        for(Sector sector : sectors.values())
        {
          if(CheckShapeOverlap(sector.collider, obj.location))
          {
            obj.currentSector = sector;
            println("[INFO] " + obj.name + " moved to sector " + sector.name);

            //HACK check if this is the playership to generate more sectors
            if(obj.name.toLowerCase().contains("player"))
            {
              //Add to temp hashmap, merge at end (see GameLoops & AssetLoader's MergeSectorMaps)
              generatedSectors = BuildSectors(obj.currentSector);
            }

            //Remove from current sector's objects, add to next sector's objects
            sector.ReceiveNewObject(obj);
            iterator.remove();      //Remove from current list inside sector
            return;
          }
        }
        println("[ERROR] Couldn't find what sector " + obj.name + " is in!");
      }
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

