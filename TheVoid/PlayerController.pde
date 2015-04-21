public enum PlayMode {
PLAY,   //Standard move/attack
PLACE_SHIP,   //Place ships
PLACE_MISSILE   //Place missiles
}

public class PlayerController
{
  private Civilization civ;
  private Drawable clickFocus;        //Player last clicked on
  PlayMode playMode;
  
  //Costs
  static final int shipCost = 1000;
  static final int missileCost = 200;
  
  //Controller UI
  private TextWindow statusBar;         //Main UI
  ArrayList <ToggleButton> allToggleButtons;
  
  //Buttons (clickable)
  public ToggleButton debugToggleButton, cancelOrders, playButton, buildMissileButton, buildShipButton;
  public TogglableBoolean missileButtonClicked, shipButtonClicked, playButtonClicked;
  
  //UI Info
  public TextWindow massEnergyTotal, massEnergySec;    //Resources
  private Shape selectedButtonBackground;              //Colored background to show what mode is currently active
  
  PlayerController(Civilization _civ)
  {
    civ = _civ;
    playMode = PlayMode.PLAY;
    
    //UI booleans for modes
    missileButtonClicked = new TogglableBoolean(false);
    shipButtonClicked = new TogglableBoolean(false);
    playButtonClicked = new TogglableBoolean(false);
    
    SetupStatusBar();    //Must be called after all togglable booleans setup
  }
  
  //Setup the main UI for the player (bottom  bar)
  private void SetupStatusBar()
  {
    int UIHeight = 100;
    int UIWidth;
    if(debuggingAllowed)
    {
      UIWidth = width/2;
    }
    else
    {
      UIWidth = width/3;
    }

    PVector iconSize = new PVector(36, 36);
    float row1Y, row2Y, column1X, column2X, column3X;    //Icon columns/ rows

    //List initializers
    allToggleButtons = new ArrayList<ToggleButton>();
    
    if(civ.orientation == CivOrientation.LEFT)
    {
      PVector UICorner = new PVector(0, height - UIHeight);      
      
    //Main bar
      statusBar = new TextWindow("Main player UI", new PVector(UICorner.x, UICorner.y), //<>//
                               new PVector(UIWidth, UIHeight), "", false);
      statusBar.SetTextRenderMode(CORNER);      //Text render mode
      statusBar.renderMode = CORNER;            //UI render mode
      //statusBar.SetBackgroundColor(color(85,103,137, 200));
      statusBar.SetGradient(color(0, 100), color(255, 100));
      
    //Clickable Buttons
      if(debuggingAllowed)
      {
        //Debug button
        debugToggleButton = new ToggleButton("Debug mode toggle", new PVector(UICorner.x + UIWidth - 75, UICorner.y + UIHeight/2), 
                      new PVector(100, 49), "DEBUG", "PNG/blue_button13.png", debugMode, false);          
        allToggleButtons.add(debugToggleButton);
      }
      
      //UI Setup
      row1Y = UICorner.y + UIHeight/10;
      row2Y = UICorner.y + 2.5 * UIHeight/10 + iconSize.y;
      column1X = UICorner.x + UIHeight/10;
      column2X = UICorner.x + 2.5 * UIHeight/10 + iconSize.x;
      column3X = UICorner.x + 5 * UIHeight/10 + 2 * iconSize.x;
    }
    
    else    //Assume right side
    {
      PVector UICorner = new PVector(width-UIWidth, height - UIHeight); 
      
    //Main bar
      statusBar = new TextWindow("Main player UI", new PVector(UICorner.x, UICorner.y),
                               new PVector(UIWidth, UIHeight), "", false);
      statusBar.SetTextRenderMode(CORNER);      //Text render mode
      statusBar.renderMode = CORNER;            //UI render mode
      //statusBar.SetBackgroundColor(color(85,103,137, 200));
      statusBar.SetGradient(color(0, 100), color(255, 100));
      
    //Clickable Buttons
      if(debuggingAllowed)
      {
        //Debug button
        debugToggleButton = new ToggleButton("Debug mode toggle", new PVector(UICorner.x + 75, UICorner.y + UIHeight/2), 
                      new PVector(100, 49), "DEBUG", "PNG/blue_button13.png", debugMode, false);          
        allToggleButtons.add(debugToggleButton);
      }
      
      //UI Setup
      row1Y = UICorner.y + UIHeight/10;
      row2Y = UICorner.y + 2.5 * UIHeight/10 + iconSize.y;    
      column1X = UICorner.x + UIWidth - UIHeight/10 - iconSize.x;    //TODO why do these need an iconsize.x offset?
      column2X = UICorner.x + UIWidth - (2.5 * UIHeight/10 + iconSize.x)- iconSize.x;
      column3X = UICorner.x + UIWidth - (5 * UIHeight/10 + 2 * iconSize.x) - 200 - iconSize.x;    //HACK 200 is width of info bars (see massEnergyTotal below)
      
    }
  
    //Pilotable controls
    cancelOrders = new ToggleButton("Stop Ship Button", new PVector(column1X, row1Y),
                iconSize, "", "PNG/red_cross.png", null, false);
    cancelOrders.SetRenderMode(CORNER);
    cancelOrders.SetClickSound(clickCancelOrderButtonSound);
    allToggleButtons.add(cancelOrders);
    
    buildMissileButton = new ToggleButton("Build Missile Button", new PVector(column1X, row2Y),
                iconSize, " 200", "Missile05.png", missileButtonClicked, false);
    buildMissileButton.SetTextColor(color(255, 100));
    buildMissileButton.SetRenderMode(CORNER);
    buildMissileButton.SetClickSound(clickMissileSpawnButtonSound);
    allToggleButtons.add(buildMissileButton);
    
    buildShipButton = new ToggleButton("Build Ship Button", new PVector(column2X, row2Y),
                iconSize, "1000", "ship.png", shipButtonClicked, false);
    buildShipButton.SetTextColor(color(255, 100));
    buildShipButton.SetRenderMode(CORNER);
    buildShipButton.SetClickSound(clickShipSpawnButtonSound);
    allToggleButtons.add(buildShipButton);
    
    playButton = new ToggleButton("Play Button", new PVector(column2X, row1Y),
                iconSize, "", "PNG/green_sliderRight.png", playButtonClicked, false);
    playButton.SetRenderMode(CORNER);
    playButton.SetClickSound(clickNormalModeButtonSound);
    allToggleButtons.add(playButton);
    
    
  //UI Only Buttons
    massEnergyTotal = new TextWindow("Mass Energy Total UI", new PVector(column3X, row2Y),
                             new PVector(iconSize.x + 200, iconSize.y), "Mass-Energy", false);
    massEnergyTotal.textRenderMode = CORNER; 
    
    massEnergySec = new TextWindow("Mass Energy/sec UI", new PVector(column3X, row1Y),
                             new PVector(iconSize.x + 200, iconSize.y), "Mass-Energy/sec", false);
    massEnergySec.textRenderMode = CORNER; 
    
    //UI feedback (currently selected)
    PVector buttonCenter = new PVector(playButton.location.x + playButton.size.x/2,
                            playButton.location.y + playButton.size.y/2);
    PVector backgroundSize = new PVector(playButton.size.x * 1.2, playButton.size.y * 1.2);
    selectedButtonBackground = new Shape("UI Selected Feedback", buttonCenter, backgroundSize, 
                color(255, 100), ShapeType._SQUARE_);
    selectedButtonBackground.SetFillColor(color(#41ED39, 50));
  }
  
  //Draw all menus and buttons
  public void DrawUI()
  {
    statusBar.DrawObject();
    selectedButtonBackground.DrawObject();      //Currently selected mode, set in UpdateUI
    DrawButtons(allToggleButtons);
    massEnergyTotal.DrawObject();
    massEnergySec.DrawObject();
  }
  
  //Update all button actions to the current target (NOTE: only call this for one player, as it over-writes main UI)
  public void UpdateUI()
  {
    //Update the stop button's target
    if(clickFocus instanceof Pilotable)
    {
      Pilotable pilot = (Pilotable)clickFocus;
      cancelOrders.varToToggle = pilot.allStopOrder;
    }
    
  //Mass-Energy Update  
    //Update total mass-energy stored
    String massEnergyText = "Mass-Energy:  ";
    massEnergyText += String.format("%,d",civ.massEnergy);
    massEnergyTotal.UpdateText(massEnergyText);
    
    //Update mass energy per second text
    int massEperSec = 0;
    for(Station s : civ.stations)
    {
      massEperSec += s.massEnergyGen;
    }
    String massEnergySecText = "Mass-Energy/sec:  ";
    massEnergySecText += String.format("%,d",massEperSec);
    massEnergySec.UpdateText(massEnergySecText);
  
  //Catch click of mode-change buttons
    if(missileButtonClicked.value)
    {
      playMode = PlayMode.PLACE_MISSILE;
      missileButtonClicked.Toggle();
      
      //Move selected icon
      PVector buttonCenter = new PVector(buildMissileButton.location.x + buildMissileButton.size.x/2,
                            buildMissileButton.location.y + buildMissileButton.size.y/2);
      selectedButtonBackground.location = buttonCenter;
      
      //Disable all station placement UI 
      for(Station s : civ.stations)
      {
        s.displayPlacementCircle = true;
      }
    }
    else if(shipButtonClicked.value)
    {
      playMode = PlayMode.PLACE_SHIP;
      shipButtonClicked.Toggle();
      
      //Move selected icon
      PVector buttonCenter = new PVector(buildShipButton.location.x + buildShipButton.size.x/2,
                            buildShipButton.location.y + buildShipButton.size.y/2);
      selectedButtonBackground.location = buttonCenter;
      
      //Disable all station placement UI 
      for(Station s : civ.stations)
      {
        s.displayPlacementCircle = true;
      }
    }
    else if(playButtonClicked.value)
    {
      playMode = PlayMode.PLAY;
      playButtonClicked.Toggle();
      
      //Move selected icon
      PVector buttonCenter = new PVector(playButton.location.x + playButton.size.x/2,
                            playButton.location.y + playButton.size.y/2);
      selectedButtonBackground.location = buttonCenter;
      
      //Disable all station placement UI 
      for(Station s : civ.stations)
      {
        s.displayPlacementCircle = false;
      }
    }

  }
  
  //Set the drawable target that the player is clicked on
  public void SetTarget(Drawable _target)
  {
    clickFocus = _target;
  }
  
  //Pass in PVector in SCREEN coordinates and determine action
  public void HandleLeftClick(PVector _clickLocation)
  {
    //First check for UI click, i.e. not scaled with zoom/pan
    Clickable click = CheckClickableOverlap(allToggleButtons, _clickLocation);
    if(click != null)      //Do UI handling
    {
      if(click instanceof ToggleButton)
      {
        click.Click();
      }
      
    }
    
    else  //Process gameobjects        
    {
      //Convert to game coordinates (zoomed & panned)
      _clickLocation.x = wvd.pixel2worldX(_clickLocation.x);
      _clickLocation.y = wvd.pixel2worldY(_clickLocation.y);
      
      if(playMode == PlayMode.PLAY)      //Do gameobject handling in local coordinates
      {
        //Check if we clicked on this player's fleet
        click = CheckClickableOverlap(civ.fleet, _clickLocation);
        
        if(click == null)    //No ship clicked - also check the missiles
        {
          click = CheckClickableOverlap(civ.missiles, _clickLocation);
        }
        HandleClickedGameObject(click);    //Handle whatever the player clicked
      }
      
      else if (playMode == PlayMode.PLACE_SHIP)   //Place ships
      {
        //Check if the click is in the click radius of all stations
        boolean inClickRadius = false;
        for(Station s : civ.stations)
        {
          if(CheckShapeOverlap(s.placementCircle, _clickLocation))
          {
            inClickRadius = true;
            if(debugMode.value)
            {
              println("INFO: Spawning ship inside station radius");
            }
            break;
          }
        }
        
        if(inClickRadius)
        {
          if(shipCost <= civ.massEnergy)
          {
            Ship shipToAdd = new Ship("Ship", _clickLocation, new PVector(30, 22), shipSprite, 1000, civ.outlineColor, civ);
            if(civ.orientation == CivOrientation.RIGHT)  //Rotate 180 degrees for right side
            {
              shipToAdd.currentAngle = radians(180);
              shipToAdd.destinationAngle = radians(180);
            }
            
            civ.massEnergy -= shipCost;
            civ.fleet.add(shipToAdd); 
          }

          else
          {
            errorSound.play();
          }

        }
        else
        {
          if(debugMode.value)
          {
            println("INFO: Requested ship spawn location outside station spawn radius");
          }
        }

      }
      
      else if (playMode == PlayMode.PLACE_MISSILE)   //Place missiles
      {
        //Check if the click is in the click radius of all stations
        boolean inClickRadius = false;
        for(Station s : civ.stations)
        {
          if(CheckShapeOverlap(s.placementCircle, _clickLocation))
          {
            inClickRadius = true;
            if(debugMode.value)
            {
              println("INFO: Spawning missile inside station radius");
            }
            break;
          }
        }
        
        if(inClickRadius)
        {
          if(missileCost <= civ.massEnergy)
          {
            Missile missileToAdd = new Missile(new PVector(_clickLocation.x, _clickLocation.y), new PVector(0,0), civ.outlineColor, civ);
            if(civ.orientation == CivOrientation.RIGHT)  //Rotate 180 degrees for right side
            {
              missileToAdd.currentAngle = radians(180);
              missileToAdd.destinationAngle = radians(180);
            }
            
            civ.massEnergy -= missileCost;
            civ.missiles.add(missileToAdd); 
          }

          else
          {
            errorSound.play();
          }
          
        }
        else
        {
          if(debugMode.value)
          {
            println("INFO: Requested ship missile location outside station spawn radius");
          }
        }
      }
      
      else 
      {
        println("WARNING: Unhandled playmode for active player controller!");
      }
    }
    
    click = null;
  }
  
  //Pass in PVector in SCREEN coordinates and determine action
  public void HandleRightClick(PVector _clickLocation)
  {
    if(playMode == PlayMode.PLAY)
    {
      //Do some UI things with right click here w/o pan/zoom compensation
      
      //Convert to game coordinates (zoomed & panned)
      _clickLocation.x = wvd.pixel2worldX(_clickLocation.x);
      _clickLocation.y = wvd.pixel2worldY(_clickLocation.y);
      
      //Check if this is clickable. First check is lowest priority
      //HACK: overlapping objects will be a problem here
      Clickable click = CheckClickableOverlap(civ.fleet, _clickLocation);
      if(click == null) {
        click = CheckClickableOverlap(civ.stations, _clickLocation);   
      }
      if(click == null) {
        click = CheckClickableOverlap(asteroids, _clickLocation);
      }
      if(click == null) {
        click = CheckClickableOverlap(otherPlayer.civ.fleet, _clickLocation);
      }
      if(click == null) {
        click = CheckClickableOverlap(otherPlayer.civ.stations, _clickLocation);
      }
      
      if(click != null)  //We actually clicked something
      {
        if(click instanceof Physical)    //Check if this is owned by this civ
        {
          Physical phys = (Physical)click;
          if(phys.owner != civ)    //The clicked object is NOT owned by this civ
          {
            //Safe to attack
            if(clickFocus instanceof Pilotable)      //Kill orders 
            {
              Pilotable pilot = (Pilotable)clickFocus;
              if(debugMode.value)
              {
                print(pilot.name);
                print(" attacking ");
                print(phys.name);
                println();
              }
              pilot.AddNewOrder(_clickLocation, phys, OrderType._KILL_);  
            }
          }
          else
          {
            //Orbit orders could go here
          }
        }
      }
      
      else    //We clicked on nothing
      {
        if(clickFocus instanceof Pilotable)      //Move orders 
        {
          Pilotable pilot = (Pilotable)clickFocus;
          pilot.AddNewOrder(_clickLocation, null, OrderType._MOVE_);   
        }
      }
    }
    else if (playMode == PlayMode.PLACE_SHIP || playMode == PlayMode.PLACE_MISSILE)
    {
      //Return to play mode if right click during ship placement
      //HACK emulate pressing the button
      playButtonClicked.Toggle();
    }
  }
  
  //Restores the currently selected target to its un-clicked state
  private void RestoreSelectedTarget()
  {
    //Restore icon color
    if(clickFocus instanceof Physical)
    {
      Physical phys = (Physical)clickFocus;
      phys.iconOverlay.RestoreDefaultColor();
    }
    
    if(clickFocus instanceof Pilotable)
    {
      Pilotable pilot = (Pilotable)clickFocus;
      pilot.currentlySelected = false;
    }
  }
  
  //Select a new clicked target and make changes after it has been clicked
  private void SelectNewTarget(Clickable _clicked)
  {
    clickFocus = (Drawable)_clicked;
    
    if(debugMode.value)
    {
      print("INFO: Selected new target ");
      print(clickFocus.name);
      print("\n");
    }
    
    if(clickFocus instanceof Physical)    //Catch all physical objects
    {
      Physical phys = (Physical)clickFocus;
      
      //Update their border color to white
      phys.iconOverlay.SetBorderColor(color(255));
    }
    
    if(clickFocus instanceof Pilotable)    //Catch missiles, ships, etc
    {
      Pilotable pilot = (Pilotable)clickFocus;
      
      //Set their selected bit
      pilot.currentlySelected = true;
    }

    //ADD NEW CLICKABLE TYPES HERE
  }
  
  private void HandleClickedGameObject(Clickable click) //<>//
  {
    if(click != null)    //We actually clicked something
    {
      if(clickFocus == null)  //We currently have NOTHING selected -- just get a new target
      {      //<>//
        SelectNewTarget(click);
      }
      
      //We DO have something selected right now
      else
      {
        RestoreSelectedTarget();        //Restore info about the target clicked new
        SelectNewTarget(click);         //Set new target of what we just clicked on
      }
      
    }
    
    else    //We clicked in empty space
    {
      if(clickFocus == null)    //We currently have NOTHING selected
      {
        //DO NOTHING
      }
      
      else   //We DO have something selected right now
      {
        RestoreSelectedTarget();
        
        clickFocus = null;
      }
    }
  }
  
    
  //Go through all objects and make sure they are deselected. Useful for turn changes where
  // the opponent cannot select this civ's pieces. Prevents other player from seeing rendered
  // station spawn radii if turn ends in placement mode
  public void CedeControlForTurnChange()
  {
    if(debugMode.value)
    {
      print("INFO: ");
      print(civ.name);
      print(" is ceding turn control at t=");
      print(millis());
      print("\n");
    }
    
    for(Ship s : civ.fleet)
    {
      s.currentlySelected = false;
    }
    for(Missile m : civ.missiles)
    {
      m.currentlySelected = false;
    }
    
    //Disable all station placement UI 
    for(Station s : civ.stations)
    {
      s.displayPlacementCircle = false;
    }
  }
  
}
