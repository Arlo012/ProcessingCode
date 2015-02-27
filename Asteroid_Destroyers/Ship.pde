//TODO implement all the other ship sprites....
PImage shipSprite;      //Loaded in setup()

/**
 * An asteroid gameobject, inheriting from Drawable
 */
public class Ship extends Physical 
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
  public Ship(PVector _loc, PVector _size, PImage _sprite, int _mass) 
  {
    //Parent constructor
    super(_loc, _size, _mass, DrawableType.SHIP);
    
    sprite = _sprite;
    sprite.resize(int(size.x), int(size.y));
  }


}
