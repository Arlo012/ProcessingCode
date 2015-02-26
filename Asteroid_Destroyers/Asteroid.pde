int uniqueAsteroidIDCounter = 0;

//Each sprite spaced 128 pixels apart
PImage asteroidSpriteSheet;      //Loaded in setup()

/**
 * An asteroid gameobject, inheriting from Drawable
 */
public class Asteroid extends Drawable 
{
  //Unique ID
  private int id;

  /*
   * Constructor
   * @param  _size  diameter of the asteroid
   * @param  _xloc  x coordinate of the asteroid
   * @param  _yloc  y coordinate of the asteroid
   * @see         Asteroid
   */
  public Asteroid(int _xloc, int _yloc, int _diameter) 
  {
    //Parent constructor
    super(_xloc, _yloc, _diameter, _diameter);

    //Unique ID
    id = uniqueAsteroidIDCounter;
    uniqueAsteroidIDCounter++;

    //Select my asteroid image from spritesheet
    int RandomAsteroidIndex1 = rand.nextInt(9);      //x coordinate in sprite sheet
    int RandomAsteroidIndex2 = rand.nextInt(9);      //y coordinate in sprite sheet

    //Set the sprite to the random subset of the spritesheet
    sprite = asteroidSpriteSheet.get(RandomAsteroidIndex1 * 128, RandomAsteroidIndex2 * 128, 128, 128);
    sprite.resize(int(size.x), int(size.y));
  }

  public int GetID()
  {
    return id;
  }


}
