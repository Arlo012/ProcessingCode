public class PlayerController
{
  private Civilization civ;
  private Drawable playerTarget;        //Player last clicked on
  
  PlayerController(Civilization _civ)
  {
    civ = _civ;
  }
  
  public void SetTarget(Drawable _target)
  {
    playerTarget = _target;
  }
  
  //Pass in PVector in ZOOM-CONVERTED coordinates and determine actions
  public void HandleLeftClick(PVector _clickLocation)
  {
    PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
      
    //Check if this is clickable
    Clickable click = CheckClickableOverlap(civ.fleet, currentMouseLoc);
   
    //We actually clicked something
    if(click != null)
    {
      //We currently have NOTHING selected -- just get a new target
      if(playerTarget == null)
      {
        playerTarget = (Drawable)click;
        
        if(playerTarget instanceof Physical)
        {
          Physical phys = (Physical)playerTarget;
          phys.iconOverlay.UpdateIcon(color(255));
        }
        
        if(playerTarget instanceof Ship)
        {
          Ship ship = (Ship)playerTarget;
          ship.currentlySelected = true;
        }
      }
      
      //We DO have something selected right now
      else
      {
        
      }
      
    }
    
    //We clicked in empty space
    else
    {
      //We currently have NOTHING selected
      if(playerTarget == null)
      {
        //NOTHING
      }
      
      //We DO have something selected right now
      else
      {
        //Restore icon color
        if(playerTarget instanceof Physical)
        {
          Physical phys = (Physical)playerTarget;
          phys.iconOverlay.RestoreDefaultColor();
        }
        
        if(playerTarget instanceof Ship)
        {
          Ship ship = (Ship)playerTarget;
          ship.currentlySelected = false;
        }
        
        playerTarget = null;
      }
    }
  

  }
  
  public void HandleRightClick(PVector _clickLocation)
  {
    PVector currentMouseLoc = new PVector(wvd.pixel2worldX(mouseX), wvd.pixel2worldY(mouseY));
      
    //Check if this is clickable
    Clickable click = CheckClickableOverlap(civ.fleet, currentMouseLoc);
   
    
    //We actually clicked something
    if(click != null)
    {
      //Attacks could go here
    }
    
    //We clicked on nothing
    else
    {
      //Move orders here
      if(playerTarget instanceof Ship)
      {
        Ship ship = (Ship)playerTarget;
        ship.AddNewOrder(_clickLocation, null, OrderType._MOVE_);      //TODO implement other movement types here
      }
    }
    
  }
  
}
