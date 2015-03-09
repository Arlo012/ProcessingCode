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
  
  private int frameCounter = 0;      //Count how many frames of total we have gone thru
  
  Effect(String _name, PVector _loc, PVector _size, EffectType _effectType)
  {
    super(_name, _loc, _size, DrawableType.EFFECT);
    effectType = _effectType;
    
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
  
  @Override public void DrawObject()
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
