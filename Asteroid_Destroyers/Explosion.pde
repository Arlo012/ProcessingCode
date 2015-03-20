PImage[] explosionImgs = new PImage[90];
int explosionImgCount = 90;

/*
 * Displays a range of png images to simulate an explosion, and plays a sound
*/
public class Explosion extends Drawable
{
  PImage[] images;
  int imageFrames;
  
  //Sound
  SoundFile sound;
  boolean soundPlayed = false;
  
  //Delay action
  int frameDelay = 0;                    //Delay how many frames after creation to draw?
  long frameCountAtSpawn;            //At creation what was the framecount
  
  private int frameCounter = 0;      //Count how many frames of total we have gone thru
  
  Explosion(PVector _loc, PVector _size)
  {
    super("Explosion", _loc, _size, DrawableType.EFFECT);
    
    frameCountAtSpawn = frameCount;
    
    imageFrames = 90;        //based on image count
    images = explosionImgs;
    
    sound = explosionSound;
  }
  
  //Delay how many frames from creation to actually render?
  public void SetRenderDelay(int _frames)
  {
    frameDelay = _frames;
  }
  
  @Override public void DrawObject()
  {
    if(frameCount >= frameCountAtSpawn + frameDelay)
    {
      if(!soundPlayed)
      {
        sound.amp(0.5);
        sound.play();
        soundPlayed = true;
      }
      if(frameCounter < imageFrames)
      {
        pushStyle();
        imageMode(CENTER);
        image(images[frameCounter], location.x, location.y);
        popStyle();
        frameCounter++;
      }
      else
      {
        toBeKilled = true;
      }
    }
  }
}
