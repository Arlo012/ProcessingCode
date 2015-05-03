public class Enemy extends Ship
{
  //AI here
  boolean inAvoid;
  Player player;
  
  
  public Enemy(String _name, PVector _loc, PVector _size, PImage _sprite, int _mass, color _outlineColor, Sector _sector) 
  {
    //Parent constructor
    super(_name, _loc, _size, _sprite, _mass, _outlineColor, _sector);
    player = playerShip;
    inAvoid = false;
    
  }


  @Override public void Update()
  {
   super.Update();
   PVector avoidForce = Avoid(playerShip.location);
   PVector seekForce = Seek(playerShip.location);
   if(CheckShapeOverlap(player.seekCircle, location))    //Sees if within the Seek radius
   {
     if(CheckShapeOverlap(player.avoidCircle, location))
     {
       inAvoid = true;
     }
     if(inAvoid && CheckShapeOverlap(player.seekAgainCircle,location))    //Currently avoiding the player until outside seek again range
     {
       ApplyForce(avoidForce);      //Run away from player
     }
     else      //We've made it outside seek again -- attack player
     {
       ApplyForce(seekForce);
       inAvoid = false;
     } 
   }


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
          LaserBeam beam = new LaserBeam(location, targetVector, currentSector);
          
          //TODO put the beam object somewhere

          lastFireTime = millis();
        }

      }
    }
  }
  
  
  PVector Seek(PVector target)
  {
    //if(seekAgainDiameter is true && seekRadius true)
    PVector desired = PVector.sub(target, location);
    desired.normalize();
    desired.mult(localSpeedLimit);
    PVector steer= PVector.sub(desired, velocity);
    steer.limit(maxForceMagnitude);
    
    return steer;
  }
  
  PVector Avoid(PVector target)
  {
    //if(avoidDiameter is true and seekAgainDiameter is false)
    PVector desired = PVector.sub(target,location);
    desired.normalize();
    desired.mult(localSpeedLimit);
    PVector steer= PVector.sub(desired,velocity);
    steer.limit(maxForceMagnitude);
    steer.mult(-1);                             // to flip the direction of the desired vector in the opposite direction of the target
    
    return steer;
  }
}
