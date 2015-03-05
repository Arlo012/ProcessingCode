  
public class Pilotable extends Physical
{
  PVector destination;              //Where would I like to go?
  int collisionStunTime;            //If collision occurs, how long stunned before movement may occur (milliseconds)
  
   /*
   * Constructor
   * @param  _name  string to identify this
   * @param  _loc   2d vector of location
   * @param  _size  2d vector of size
   * @param  _mass  integer of mass
   * @param  _type  A DrawableType (depending who extends this class)
   * @see         Pilotable
   */
  public Pilotable(String _name, PVector _loc, PVector _size, int _mass, DrawableType _type) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _type);
    
    rotationMode = 2;    //Face target
    collisionStunTime = 2000;      //2 second stun
  }
  
  //Set the point this pilotable object will fly to
  public void SetDestination(PVector _destination)
  {
    destination = _destination;
    AccelerateToTarget();
  }
  
  //Move location
  @Override public void Move()
  {
    if(!Stunned())
    {
      if(!AtTarget())
      {
        AccelerateToTarget();
        SetRotationTarget(destination);
      }
      else
      {
        AllStop();
      }

    }
    else
    {
      //println("STUNNED");
      
    }
    location = PVector.add(location, velocity);
    
  }
  
  //Public method to provide a target and actuate rotation & acceleration
  public void MoveToTarget(PVector _target)
  {
     SetRotationTarget(_target);
     SetDestination(_target);
  }
  
  private void AccelerateToTarget()
  {
    PVector newVelocity = new PVector(localSpeedLimit, 0);    //New vector straight in front of object
    newVelocity.rotate(currentAngle);
    newVelocity.mult(acceleration);
    ChangeVelocity(newVelocity);
    
  }
  
  private void AllStop()
  {
    //println("All stop!");
    SetVelocity(new PVector(0,0));    //TODO is this the most fun way to play?
  }
  
  private boolean AtTarget()
  {
    if(abs(wvd.pixel2worldX(location.x) - wvd.pixel2worldX(destination.x)) < size.x/2
      && abs(wvd.pixel2worldY(location.y) - wvd.pixel2worldY(destination.y)) < size.y/2)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
  
  private boolean Stunned()
  {
    if(millis() - lastCollisionTime < collisionStunTime)
    {
      return true;
    }
    else
    {
      return false;
    }
  }
}
  
  
