//Handle collisiosn between two sets of drawable objects
void HandleCollisions(ArrayList<? extends Drawable> a, ArrayList<? extends Drawable> b)
{
  for(Drawable obj1 : a)
  {
    //TODO add a check if in the same GameArea
    for(Drawable obj2 : b)
    {
      if(obj1.center.x + obj1.size.x/2 >= obj2.center.x - obj2.size.x/2    //X from right
          && obj1.center.y + obj1.size.y/2 >= obj2.center.y - obj2.size.y/2  //Y from top
          && obj1.center.x - obj1.size.x/2 <= obj2.center.x + obj2.size.x/2  //X from left
          && obj1.center.y - obj1.size.y/2 <= obj2.center.y + obj2.size.y/2)    //Y from bottom
      {
        print("COLLISION BETWEEN: ");
        print(obj1.GetID());
        print(" & ");
        print(obj2.GetID());
        print("\n");
      }
    }
  }
}

void HandleCollisions(ArrayList<? extends Drawable> a)
{
  for(int i = 0; i < a.size(); i++)
  {
    for(int j = 0; j < a.size(); j++)
    {
      if(i != j)
      {
        //Don't compare to myself
        if(a.get(i).center.x + a.get(i).size.x/2 >= a.get(j).center.x - a.get(j).size.x/2    //X from right
          && a.get(i).center.y + a.get(i).size.y/2 >= a.get(j).center.y - a.get(j).size.y/2  //Y from top
          && a.get(i).center.x - a.get(i).size.x/2 <= a.get(j).center.x + a.get(j).size.x/2  //X from left
          && a.get(i).center.y - a.get(i).size.y/2 <= a.get(j).center.y + a.get(j).size.y/2)    //Y from bottom
        {
          print("COLLISION BETWEEN: ");
          print(a.get(i).GetID());
          print(" & ");
          print(a.get(j).GetID());
          print("\n");
        }
      }
    }
  }
}
