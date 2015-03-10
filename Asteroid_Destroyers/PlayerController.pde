public class PlayerController
{
  private Civilization civ;
  private Drawable playerTarget;        //Player last clicked on
  
  //Controller UI
  private TextWindow statusBar;         //Main UI
  ArrayList <Button> allToggleButtons;
  
  //Buttons
  Button debugToggleButton, stopShipButton;
  
  PlayerController(Civilization _civ)
  {
    civ = _civ;
    SetupStatusBar();
  }
  
  //Setup the main UI for the player
  private void SetupStatusBar()
  {
  //Main bar
    int UIHeight = 100;
    int UIWidth = width;
    PVector UICorner = new PVector(0, height - UIHeight);
    statusBar = new TextWindow("Main player UI", new PVector(0, height - UIHeight),
                             new PVector(UIWidth, UIHeight), "", false);
    statusBar.SetTextRenderMode(CORNER);      //Text render mode
    statusBar.renderMode = CORNER;            //UI render mode
    statusBar.SetBackgroundColor(color(0, 200));
    
  //Buttons
    allToggleButtons = new ArrayList<Button>();
    
    //Debug button
    debugToggleButton = new Button("Debug mode toggle", new PVector(UICorner.x + UIWidth - 75, UICorner.y + UIHeight/2), 
                  new PVector(100, 49), "DEBUG", "PNG/blue_button13.png", debugMode, false);          
    allToggleButtons.add(debugToggleButton);
    
    //Ship controls
    PVector iconSize = new PVector(36, 36);
    stopShipButton = new Button("Stop Ship Icon", new PVector(UICorner.x + UIHeight/10, UICorner.y + UIHeight/10),
                iconSize, "", "PNG/red_cross.png", null, false);
    stopShipButton.SetRenderMode(CORNER);
    allToggleButtons.add(stopShipButton);
  }
  
  //Draw all menus and buttons
  public void DrawUI()
  {
    statusBar.DrawObject();
    DrawButtons(allToggleButtons);
  }
  
  //Update all button actions to the current target
  public void UpdateUI()
  {
    //Update the stop button's target
    if(playerTarget instanceof Pilotable)
    {
      Pilotable pilot = (Pilotable)playerTarget;
      stopShipButton.varToToggle = pilot.allStopOrder;
    }
    
  }
  
  //Set the drawable target that the player is clicked on
  public void SetTarget(Drawable _target)
  {
    playerTarget = _target;
  }
  
  //Pass in PVector in SCREEN coordinates and determine action
  public void HandleLeftClick(PVector _clickLocation)
  {
    //First check for UI click, i.e. not scaled with zoom/pan
    Clickable click = CheckClickableOverlap(allToggleButtons, _clickLocation);
    if(click != null)      //Do UI handling
    {
      if(click instanceof Button)
      {
        click.Click();
      }
      
    }
    else          //Do gameobject handling
    {
      //Convert to game coordinates (zoomed & panned)
      _clickLocation.x = wvd.pixel2worldX(_clickLocation.x);
      _clickLocation.y = wvd.pixel2worldY(_clickLocation.y);
      
      //Check if we clicked on this player's fleet
      click = CheckClickableOverlap(civ.fleet, _clickLocation);
      
      if(click == null)    //No ship - also check the missiles
      {
        click = CheckClickableOverlap(missiles, _clickLocation);
      }
      HandleClickedGameObject(click);
    }
    
    click = null;
 
  }
  
  //Pass in PVector in SCREEN coordinates and determine action
  public void HandleRightClick(PVector _clickLocation)
  {
    //Do some UI things with right click here w/o pan/zoom compensation
    
    //Convert to game coordinates (zoomed & panned)
    _clickLocation.x = wvd.pixel2worldX(_clickLocation.x);
    _clickLocation.y = wvd.pixel2worldY(_clickLocation.y);
    
    //Check if this is clickable
    Clickable click = CheckClickableOverlap(civ.fleet, _clickLocation);
    
    if(click != null)  //We actually clicked something
    {
      //Attacks could go here
    }
    
    else    //We clicked on nothing
    {
      if(playerTarget instanceof Ship)      //Move orders 
      {
        Ship ship = (Ship)playerTarget;
        ship.AddNewOrder(_clickLocation, null, OrderType._MOVE_);      //TODO implement other movement types here
      }
      if(playerTarget instanceof Missile)
      {
        //TODO this is temporary for demo purposes only -- orders should be given while missile inside ship
        Missile missile = (Missile)playerTarget;
        missile.AddNewOrder(_clickLocation, null, OrderType._MOVE_);      //TODO implement other movement types here
      }
    }
    
  }
  
  //Restores the currently selected target to its un-clicked state
  private void RestoreSelectedTarget()
  {
    //Restore icon color
    if(playerTarget instanceof Physical)
    {
      Physical phys = (Physical)playerTarget;
      phys.iconOverlay.RestoreDefaultColor();
    }
    
    if(playerTarget instanceof Pilotable)
    {
      Pilotable pilot = (Pilotable)playerTarget;
      pilot.currentlySelected = false;
    }
  }
  
  //Select a new clicked target and make changes after it has been clicked
  private void SelectNewTarget(Clickable _clicked)
  {
    playerTarget = (Drawable)_clicked;
    
    if(debugMode.value)
    {
      print("INFO: Selected new target ");
      print(playerTarget.name);
      print("\n");
    }
    
    if(playerTarget instanceof Physical)    //Catch all physical objects
    {
      Physical phys = (Physical)playerTarget;
      
      //Update their border color to white
      phys.iconOverlay.SetBorderColor(color(255));
    }
    
    if(playerTarget instanceof Pilotable)    //Catch missiles, ships, etc
    {
      Pilotable pilot = (Pilotable)playerTarget;
      
      //Set their selected bit
      pilot.currentlySelected = true;
    }

    //ADD NEW CLICKABLE TYPES HERE
  }
  
  private void HandleClickedGameObject(Clickable click)
  {
    if(click != null)    //We actually clicked something
    {
      if(playerTarget == null)  //We currently have NOTHING selected -- just get a new target
      {     
        SelectNewTarget(click); //<>//
      }
      
      //We DO have something selected right now
      else
      {
        RestoreSelectedTarget();
        SelectNewTarget(click);
      }
      
    }
    
    else    //We clicked in empty space
    {
      if(playerTarget == null)    //We currently have NOTHING selected
      {
        //DO NOTHING
      }
      
      else   //We DO have something selected right now
      {
        RestoreSelectedTarget();
        
        playerTarget = null;
      }
    }
  }
  
}
