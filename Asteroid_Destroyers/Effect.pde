PImage[] explosionImgs = new PImage[90];
int explosionImgCount = 90;

public enum EffectType{
  EXPLOSION
}

public class Effect extends Drawable
{
  PImage[] images;
  EffectType effectType;
  int imageFrames;
  
  //Delay action
  int frameDelay = 0;                    //Delay how many frames after creation to draw?
  long frameCountAtSpawn;            //At creation what was the framecount
  
  private int frameCounter = 0;      //Count how many frames of total we have gone thru
  
  Effect(String _name, PVector _loc, PVector _size, EffectType _effectType)
  {
    super(_name, _loc, _size, DrawableType.EFFECT);
    
    effectType = _effectType;
    frameCountAtSpawn = frameCount;
    
    if(effectType == EffectType.EXPLOSION)
    {
      imageFrames = 90;
      images = explosionImgs;
    }
    else
    {
      print("WARNING: Generated effect: ");
      print(name);
      print(" without any image frame counts. It will not draw\n");
    }
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
