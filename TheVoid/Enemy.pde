public class Enemy extends Ship
{
  //AI here
  
  public Enemy(String _name, PVector _loc, PVector _size, PImage _sprite, 
        int _mass, color _outlineColor, Sector _sector) 
  {
    //Parent constructor
    super(_name, _loc, _size, _sprite, _mass, _outlineColor, _sector);
  }


  @Override public void Update()
  {
  	super.Update();

   //**** WEAPONS *****//
   //TODO update me for new AI?
    if(millis() - lastFireTime > currentFireInterval)    //Time to fire?
    {
      if(!targets.isEmpty())
      {
        Physical closestTarget = null;    //Default go after first target
        float closestDistance = 99999;
        for(Physical phys : targets)    //Check each target to find if it is closest
        {
          PVector distance = new PVector(0,0);
          PVector.sub(phys.location,location,distance);
          if(distance.mag() < closestDistance)
          {
            closestTarget = phys;
          }
        }
        
        if(closestTarget != null)    //Found a target
        {
          //Calculate laser targeting vector
          PVector targetVector = PVector.sub(closestTarget.location, location);
          targetVector.normalize();        //Normalize to simple direction vector
          targetVector.x += rand.nextFloat() * 0.5 - 0.25;
          targetVector.y += rand.nextFloat() * 0.5 - 0.25;
          
          //Create laser object
          LaserBeam beam = new LaserBeam(location, targetVector);
          
          //TODO put the beam object somewhere

          lastFireTime = millis();
        }

      }
    }
  }
}
