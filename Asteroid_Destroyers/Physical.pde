public class Physical extends Drawable implements Movable, Turnable, Collidable
{
  protected int mass;
  protected PVector velocity;              //On absolute plane
  
  //Rotation
  protected int rotationMode;              //-1 = stationary, 0 = instant, 1 = spin, 2 = face point
  protected float currentAngle; 
  protected int spinDirection;             //-1 CCW, 1 CW
  protected float destinationAngle;        //TODO phase out -- why need a destination angle if have target?
  protected float rotationRate;            //Degrees/sec
  protected PVector rotationLookTarget;    //Coordinate of what we want to look at
  
  public Physical(PVector _loc, PVector _size, int _mass, DrawableType _type)
  {
    super(_loc, _size, _type);
    
    mass = _mass;
    velocity = new PVector(0, 0);
    
    //Rotation
    currentAngle = 0;
    destinationAngle = 0;
    rotationMode = -1;      //Default to no rotation
    rotationRate = 0.01;    //Degrees/sec TODO broken not related to deg/sec right now
    spinDirection = 1;      //CW
    rotationLookTarget = new PVector(0,0);      //Default look at origin
  }
  
  @Override public void DrawObject()
  {
    pushMatrix();
    translate(location.x, location.y);
    
    if(debugMode)
    {
      //Debug velocity direction
      stroke(255, 0, 0);
      line(0, 0, 100 * velocity.x, 100 * velocity.y);
    }
    
    
    //Handle rotation
    if (rotationMode == -1)
    {   //Not rotating
    } 
    else if (rotationMode == 0)
    {
      //Rotate instantly
      rotate(destinationAngle);
      println(destinationAngle);
      currentAngle = destinationAngle;      //We instantly rotated there
    } 
    else if (rotationMode == 1)
    {
      //Rotate in direction
      currentAngle += spinDirection * rotationRate;
      rotate(currentAngle);
    } 
    else if (rotationMode == 2)
    {
      RotateToTarget();
    } 
    else
    {
      println("WARNING: Rotation mode not supported");
    }

    //End handle rotation

    imageMode(CENTER);

    //Display forward vector (white), velocity vector (red)
    if (debugMode)
    {
      //Debug forward direction
      stroke(255);
      line(0, 0, 50 * forward.x, 50 * forward.y);    
    }

    translate(-location.x, -location.y);      //Return to standard orientation before drawing
    image(sprite, location.x, location.y);
    popMatrix();
  }
  
  //******* MOVE *********/
  public void SetDestinationAngle(float _destination)
  {
    destinationAngle = _destination;
  }

  //Modify the current velocity of the object 
  public void ChangeVelocity(PVector _vector)
  {
    velocity = _vector;
  }

  //Move location of the asteroid
  public void Move()
  {
    location = PVector.add(location, velocity);
  }

  //******* ROTATE *********/
  //0 = instant, 1 = spin, 2 = standard
  public void SetRotationMode(int _rotateMode)
  {
    rotationMode = _rotateMode;
  }

  public void SetRotationRate(float _degreePerSec)
  {
    rotationRate = _degreePerSec;
  }

  public void SetRotationTarget(PVector _target)
  {
    rotationLookTarget = _target;
  }
  
  //Rotate mode 2
  private void RotateToTarget()
  {
    PVector targetRelativeToLocal = new PVector(rotationLookTarget.x - location.x, 
                rotationLookTarget.y - location.y);

    float radToRotate = atan2(targetRelativeToLocal.y - forward.y, targetRelativeToLocal.x - forward.x);
    //println(degrees(radToRotate));
    //println(degrees(currentAngle));
    //println("-------");
    if(degrees(currentAngle) > 360)
    {
      currentAngle -= radians(360);
    }
    else if(degrees(currentAngle) < -360)
    {
      currentAngle += radians(360);
    }

    
    //Check for wrap-around degrees
    if(degrees(radToRotate - currentAngle) < -180)
    {
      radToRotate += radians(360);
    }
    else if(degrees(radToRotate - currentAngle) > 180)
    {
      radToRotate -= radians(360);
    }
    
    
    if (Math.abs(radToRotate - currentAngle) > radians(0.5))
    {
      if (radToRotate - currentAngle > 0)
      {
        //CW
        spinDirection = 1;
      } 
      else
      {
        spinDirection = -1;
      }
      
      currentAngle += spinDirection * rotationRate;
      rotate(currentAngle);
    }
    else
    {
      rotate(currentAngle);
    }
  }
  
  //******* COLLIDE *********/
  public void HandleCollision(Physical _other)
  {
    PVector deltaV = new PVector(0,0);
    deltaV.x = (_other.velocity.x - velocity.x) * _other.mass/mass/100;
    deltaV.y = (_other.velocity.y - velocity.y) * _other.mass/mass/100;
    
    //TODO it seems like the collison algorithm is making this happen repeatedly. Check that out first
    //deltaV.x = -2*velocity.x;
    //deltaV.y = -2*velocity.y;
    
    //println(deltaV); //<>//
    ChangeVelocity(deltaV);

    
    //TODO testme 
    rotationRate /= 1.5;
  }
}
