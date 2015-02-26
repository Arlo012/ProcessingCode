//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * An asteroid gameobject, inheriting from Drawable
 */
public class Ship extends Drawable 
{

  /*
   * Constructor
   * @param  _xloc    x coordinate of the ship
   * @param  _yloc    y coordinate of the ship
   * @param  _xdim    x size of this ship
   * @param  _ydim    y size of this ship
   * @param  _sprite  sprite of this ship
   * @see         Asteroid
   */
  public Ship(int _xloc, int _yloc, int _xDim, int _yDim, PImage _sprite) 
  {
    //Parent constructor
    super(_xloc, _yloc, _xDim, _yDim);
    
    sprite = _sprite;
    sprite.resize(int(size.x), int(size.y));
  }


}
