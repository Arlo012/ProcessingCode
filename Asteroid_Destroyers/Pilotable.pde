  
public class Pilotable extends Physical
{
  PVector destination;
  
   /*
   * Constructor
   * @param  _size  diameter of the asteroid
   * @param  _xloc  x coordinate of the asteroid
   * @param  _yloc  y coordinate of the asteroid
   * @see         Asteroid
   */
  public Pilotable(String _name, PVector _loc, PVector _size, int _mass, DrawableType _type) 
  {
    //Parent constructor
    super(_name, _loc, _size, _mass, _type);
    
    rotationMode = 2;    //Face target
  }
  
  private void SetDestination(PVector _destination)
  {
    destination = _destination;
    
    //HACK instantly change direction
    float velocityMag = velocity.mag();      //Previous magnitude
    //Get vector direction from delta of locations
    PVector newVelocity = new PVector(destination.x - location.x, destination.y - location.y);
    newVelocity.normalize();      //Make unit vector prior to scaling
    newVelocity.mult(velocityMag);
    SetVelocity(newVelocity);
  }
  
  public void MoveToTarget(PVector _target)
  {
    //TODO this wont work if the velocity is changed after this is called
    SetRotationTarget(_target);
    SetDestination(_target);
  }
}
  
  
