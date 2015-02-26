int uniqueIDCounter = 0;
/* Drawable
 * Base class for all drawable objects in the project
 * Implements a basic DrawObject() method to draw a debug
 * rectangle even if not inherited from.
 */
public class Drawable implements Movable, Turnable
{
  protected int ID;
  
  //Image properties
  protected PVector center;               //On absolute plane
  protected PVector size;                  

  //Visuals
  protected PImage sprite;

  //Movement
  protected PVector velocity;              //On absolute plane
  protected PVector forward;               //On absolute plane

  //Rotation
  protected int rotationMode;              //-1 = stationary, 0 = instant, 1 = spin, 2 = face point
  protected float currentAngle; 
  protected int spinDirection;             //-1 CCW, 1 CW
  protected float destinationAngle;        //TODO phase out -- why need a destination angle if have target?
  protected float rotationRate;            //Degrees/sec
  protected PVector rotationLookTarget;    //Coordinate of what we want to look at

    //Location & movement
  protected PVector movementVector;

  public Drawable(int _centerX, int _centerY, int _width, int _height)
  {
    ID = uniqueIDCounter;
    uniqueIDCounter++;
    
    center = new PVector(_centerX, _centerY);
    size = new PVector(_width, _height);

    //Movement
    movementVector = new PVector(0, 0);
    forward = new PVector(1, 0);      //Forward is by default in the positive x direction
    velocity = new PVector(0, 0);

    //Rotation
    currentAngle = 0;
    destinationAngle = 0;
    rotationMode = -1;      //Default to no rotation
    rotationRate = 0.01;    //Degrees/sec TODO broken not related to deg/sec right now
    spinDirection = 1;      //CW
    rotationLookTarget = center;      //Default look at self
  }
  public int GetID()
  {
    return ID;
  }

  public void DrawObject()
  {
    pushMatrix();
    translate(center.x, center.y);
    
    if(debugMode)
    {
      //Debug velocity direction
      stroke(255, 0, 0);
      line(0, 0, 1000 * velocity.x, 1000 * velocity.y);
    }
    
    
    //Handle rotation
    float initialAngle = currentAngle;
    //rotate(initialAngle);      //Begin working in my 'forward' frame

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
    //rotate(-initialAngle);                //Return to default frame of reference

    //Display forward vector (white), velocity vector (red)
    if (debugMode)
    {
      //Debug forward direction
      stroke(255);
      line(0, 0, 100 * forward.x, 100 * forward.y);    
    }

    translate(-center.x, -center.y);      //Return to standard orientation before drawing
    image(sprite, center.x, center.y);
    popMatrix();
  }

  public PVector GetCenter()
  {
    return center;
  }

  public PVector GetSize()
  {
    return size;
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

  //Move center of the asteroid
  public void Move()
  {
    center = PVector.add(center, velocity);
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
    PVector targetRelativeToLocal = new PVector(rotationLookTarget.x - center.x, 
                rotationLookTarget.y - center.y);

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
}
