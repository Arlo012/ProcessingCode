//Drawable types (casting helper)
public enum DrawableType {
  ASTEROID, SHIP, GAMEAREA, 
  STRUCTURE, UI, PLANET
}

int uniqueIDCounter = 0;
/* Drawable
 * Base class for all drawable objects in the project
 * Implements a basic DrawObject() method to draw a debug
 * rectangle even if not inherited from.
 */
public class Drawable
{
  protected int ID;
  DrawableType type;                      //ID what kind of drawable object this is
  
  //Image properties
  protected PVector location;               //On absolute plane
  protected PVector size;                  

  //Visuals
  protected PImage sprite;                 //TODO should be private

  //Movement
  protected PVector forward;               //On absolute plane

  public Drawable(PVector _loc, PVector _size, DrawableType _type)
  {
    type = _type;
    
    ID = uniqueIDCounter;
    uniqueIDCounter++;
    
    location = new PVector(_loc.x, _loc.y);
    size = new PVector(_size.x, _size.y);

    //Movement
    forward = new PVector(1, 0);      //Forward is by default in the positive x direction
  }
  public int GetID()
  {
    return ID;
  }

  public void DrawObject()
  {
    image(sprite, location.x, location.y);
  }

  public PVector GetLocation()
  {
    return location;
  }

  public PVector GetSize()
  {
    return size;
  }

}
