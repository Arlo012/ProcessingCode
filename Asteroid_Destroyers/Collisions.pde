//Handle collisiosn between two sets of drawable objects
//ONLY VALID FOR CIRCLES/ RECTANGLES
void HandleCollisions(ArrayList<? extends Physical> a, ArrayList<? extends Physical> b)
{
  for(Physical obj1 : a)
  {
    //TODO add a check if in the same GameArea?
    for(Physical obj2 : b)
    {
      if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
          && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
          && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
          && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
      {
        
        print("COLLISION BETWEEN: ");
        print(obj1.name);
        print(" & ");
        print(obj2.name);
        print("\n");
        
        obj1.HandleCollision(obj2);
        obj2.HandleCollision(obj1);
      }
    }
  }
}

//ONLY VALID FOR CIRCLES/ RECTANGLES
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

          //Give both collision handlers info about the other
          a.get(i).HandleCollision(a.get(j)); //<>//
          a.get(j).HandleCollision(a.get(i)); //<>//
        }
      }
    }
  }
}

//ONLY VALID FOR CIRCLES/ RECTANGLES
void HandleWeaponCollisions(ArrayList<? extends Missile> a, ArrayList<? extends Physical> b)
{
  for(Physical obj1 : a)
  {
    //TODO add a check if in the same GameArea?
    for(Physical obj2 : b)
    {
      if(obj1.location.x + obj1.size.x/2 >= obj2.location.x - obj2.size.x/2    //X from right
          && obj1.location.y + obj1.size.y/2 >= obj2.location.y - obj2.size.y/2  //Y from top
          && obj1.location.x - obj1.size.x/2 <= obj2.location.x + obj2.size.x/2  //X from left
          && obj1.location.y - obj1.size.y/2 <= obj2.location.y + obj2.size.y/2)    //Y from bottom
      {
        
        print("COLLISION BETWEEN: ");
        print(obj1.name);
        print(" & ");
        print(obj2.name);
        print("\n");
        
        obj1.HandleCollision(obj2);
        obj2.HandleCollision(obj1);
      }
    }
  }
}

//Handle a click with any drawable object and a given point, checking of the obj is clickable
Clickable CheckClickableOverlap(ArrayList<? extends Drawable> a, PVector point)
{
  PVector collisionOffset;      //Offset due to center vs rect rendering (rect = 0 offset)
  for(Drawable obj1 : a)
  {
    //Check if this is CENTER or CORNER rendered -- center rendered needs to account for half size of self, rect for full
    if(obj1.renderMode == CENTER)
    {
      collisionOffset = new PVector(obj1.size.x/2, obj1.size.y/2);
    }
    else if(obj1.renderMode == CORNER)
    {
      collisionOffset = new PVector(obj1.size.x, obj1.size.y);
    }
    else
    {
      collisionOffset = new PVector(obj1.size.x/2, obj1.size.y/2);
      print("WARNING: Unsupported collision offset mode on");
      print(obj1.name);
      print("\n");
    }
    
    if(obj1.location.x + collisionOffset.x >= point.x        //X from right
        && obj1.location.y + collisionOffset.y >= point.y    //Y from top
        && obj1.location.x - collisionOffset.x <= point.x    //X from left
        && obj1.location.y - collisionOffset.y <= point.y)   //Y from bottom
    {
      if(obj1 instanceof Clickable)
      {
        Clickable clickable = (Clickable)obj1;
        return clickable;
      }
    }
  }
  
  return null;
}
