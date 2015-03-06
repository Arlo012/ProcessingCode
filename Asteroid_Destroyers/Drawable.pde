//Drawable types (casting helper)
public enum DrawableType {
  ASTEROID, SHIP, GAMEAREA, 
  STRUCTURE, UI, PLANET,
}

int uniqueIDCounter = 0;
/* Drawable
 * Base class for all drawable objects in the project
 * Implements a basic DrawObject() method
 */
public class Drawable
{
  protected int ID;
  protected String name;
  DrawableType drawType;                      //ID what kind of drawable object this is
  
  //Image properties
  protected PVector location;               //On absolute plane
  protected PVector size;                  

  //Visuals
  protected PImage sprite;                 //TODO should be private

  //Movement
  protected PVector forward;               //On absolute plane

  public Drawable(String _name, PVector _loc, PVector _size, DrawableType _type)
  {
    drawType = _type;
    name = _name;
    
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
  
  public String GetName()
  {
    return name;
  }

  //Render this base object's sprite, if it is initialized
  public void DrawObject()
  {
    if(sprite != null)
    {
      image(sprite, location.x, location.y);
    }
    else
    {
      print("WARNING: Tried to draw base drawable object with no sprite! ID = ");
      print(ID);
      print("\n");
    }
  }

  public PVector GetLocation()
  {
    return location;
  }

  public PVector GetSize()
  {
    return size;
  }
  
  //Special force-updater for location of a UI element
  public void UpdateLocation(PVector _location)
  {
    if(drawType == DrawableType.UI)
    {
      location = _location;
    }
    else
    {
      print("WARNING: Tried to force update location of the following non-UI object:");
      print(ID);
      print(", ");
      print(name);
      print("\n");
    }
  }

}
