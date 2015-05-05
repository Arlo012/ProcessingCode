//Handle collisiosn between two sets of drawable objects
//ONLY VALID FOR CIRCLES/ RECTANGLES


/**
 * Handle intra-sector collisions between ships and asteroids
 * @param {Map<Integer, Sector>} _sectors Sector to do collision checks on
 */
void HandleSectorCollisions(Map<Integer, Sector> _sectors)
{
  for(Sector a : _sectors.values())
  {
    HandleCollisions(a.asteroids, a.ships);
    HandleCollisions(a.laserFire, playerShip);
    HandleCollisions(a.laserFire, a.asteroids);
    HandleCollisions(a.laserFire, a.ships);

    for(Planet p : a.planets)
    {
      HandleCollisions(a.laserFire, p.stations);
    }

    for(Shield s : playerShip.shields)
    {
      // if(CheckShapeOverlap(s.collider, )
    }
    
    
  }
}

void HandleCollisions(ArrayList<? extends Physical> a, ArrayList<? extends Physical> b)
{
  for(Physical obj1 : a)
  {
    for(Physical obj2 : b)
    {
      if(obj1.collidable && obj2.collidable)
      {
        if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
            && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
            && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
            && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
        {
          
          if(debugMode.value)
          {
            print("[DEBUG] COLLISION BETWEEN: ");
            print(obj1.name);
            print(" & ");
            print(obj2.name);
            print("\n");
          }
          // collisionSound.play();
          obj1.HandleCollision(obj2);
          obj2.HandleCollision(obj1);
        }
      }

    }
  }
}

void HandleCollisions(ArrayList<? extends Physical> a, Physical obj2)
{
  for(Physical obj1 : a)
  {
    if(obj1.collidable && obj2.collidable)
    {
      if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
          && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
          && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
          && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
      {
        
        if(debugMode.value)
        {
          print("[DEBUG] COLLISION BETWEEN: ");
          print(obj1.name);
          print(" & ");
          print(obj2.name);
          print("\n");
        }
        // collisionSound.play();
        obj1.HandleCollision(obj2);
        obj2.HandleCollision(obj1);
      }
    }
  }
}

/**
 * Handle self collisions within physical object list
 * @param a ArrayList of physical objects to check self-collision on
 */
void HandleCollisions(ArrayList<? extends Physical> a)
{
  for(int i = 0; i < a.size(); i++)
  {
    for(int j = 0; j < a.size(); j++)
    {
      if(i != j)        //Don't compare to myself
      {
        if(a.get(i).location.x + a.get(i).size.x/2 >= a.get(j).location.x - a.get(j).size.x/2    //X from right
          && a.get(i).location.y + a.get(i).size.y/2 >= a.get(j).location.y - a.get(j).size.y/2  //Y from top
          && a.get(i).location.x - a.get(i).size.x/2 <= a.get(j).location.x + a.get(j).size.x/2  //X from left
          && a.get(i).location.y - a.get(i).size.y/2 <= a.get(j).location.y + a.get(j).size.y/2)    //Y from bottom
        {
          if(debugMode.value)
          {
            print("COLLISION BETWEEN: ");
            print(a.get(i).GetID());
            print(" & ");
            print(a.get(j).GetID());
            print("\n");
          } 
          // collisionSound.play(); 
          //Give both collision handlers info about the other
          a.get(i).HandleCollision(a.get(j)); //<>//
          a.get(j).HandleCollision(a.get(i)); //<>//
        }
      }
    }
  }
}

//Check if a point falls within a drawable object
boolean CheckDrawableOverlap(Drawable obj, PVector point)
{
  if(obj != null)
  {  
    PVector collisionOffset;      //Offset due to center vs rect rendering (rect = 0 offset)
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self
    if(obj.renderMode == CENTER)
    {
      collisionOffset = new PVector(-obj.size.x/2, -obj.size.y/2);
    }
    else if(obj.renderMode == CORNER)
    {
      collisionOffset = new PVector(0,0);
    }
    else
    {
      collisionOffset = new PVector(obj.size.x/2, obj.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj.name);
      print("\n");
    }
    
    if(point.x >= obj.location.x + collisionOffset.x
      && point.y >= obj.location.y + collisionOffset.y
      && point.y <= obj.location.y + collisionOffset.y + obj.size.y
      && point.x <= obj.location.x + collisionOffset.x + obj.size.x)
    {
      return true;
    }
  }
  
  return false;
}
