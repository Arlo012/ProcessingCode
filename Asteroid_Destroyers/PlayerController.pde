public class PlayerController
{
  private Civilization civ;
  private Drawable clickFocus;        //Player last clicked on
  
  //Controller UI
  private TextWindow statusBar;         //Main UI
  ArrayList <Button> allToggleButtons;
  
  //Buttons (clickable)
  public Button debugToggleButton, cancelOrders, buildMissileOrder, buildShipOrder;
  
  //UI Info
  public TextWindow massEnergyTotal, massEnergySec;    //Resources
  
  //Background shapes
  private ArrayList<Shape> UIShapes;    //TODO phase these out ?
  
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
    int UIWidth = width/2;
    PVector UICorner = new PVector(0, height - UIHeight);
    statusBar = new TextWindow("Main player UI", new PVector(0, height - UIHeight),
                             new PVector(UIWidth, UIHeight), "", false);
    statusBar.SetTextRenderMode(CORNER);      //Text render mode
    statusBar.renderMode = CORNER;            //UI render mode
    //statusBar.SetBackgroundColor(color(85,103,137, 200));
    statusBar.SetGradient(color(0, 100), color(255, 100));
    
  //Clickable Buttons
    allToggleButtons = new ArrayList<Button>();
    
    //Debug button
    debugToggleButton = new Button("Debug mode toggle", new PVector(UICorner.x + UIWidth - 75, UICorner.y + UIHeight/2), 
                  new PVector(100, 49), "DEBUG", "PNG/blue_button13.png", debugMode, false);          
    allToggleButtons.add(debugToggleButton);
    
    //UI Setup
    PVector iconSize = new PVector(36, 36);
    float row1Y = UICorner.y + UIHeight/10;
    float row2Y = UICorner.y + 2.5 * UIHeight/10 + iconSize.y;
    float column1X = UICorner.x + UIHeight/10;
    float column2X = UICorner.x + 2.5 * UIHeight/10 + iconSize.x;
    float column3X = UICorner.x + 5 * UIHeight/10 + 2 * iconSize.x;
    
    //Pilotable controls
    cancelOrders = new Button("Stop Ship Button", new PVector(column1X, row1Y),
                iconSize, "", "PNG/red_cross.png", null, false);
    cancelOrders.SetRenderMode(CORNER);
    allToggleButtons.add(cancelOrders);
    
    buildMissileOrder = new Button("Build Missile Button", new PVector(column1X, row2Y),
                iconSize, "", "Missile05.png", null, false);
    buildMissileOrder.SetRenderMode(CORNER);
    allToggleButtons.add(buildMissileOrder);
    
    buildShipOrder = new Button("Build Ship Button", new PVector(column2X, row2Y),
                iconSize, "", "ship.png", null, false);
    buildShipOrder.SetRenderMode(CORNER);
    allToggleButtons.add(buildShipOrder);
    
  //Background Shapes 
    UIShapes = new ArrayList<Shape>();
    /*
    for(Button B : allToggleButtons)
    {
      PVector buttonCenter = new PVector(B.location.x + B.size.x/2, B.location.y + B.size.y/2);
      PVector backgroundSize = new PVector(B.size.x * 1.2, B.size.y * 1.2);
      Shape backgroundShape = new Shape("UI Decoration", buttonCenter, backgroundSize, 
                color(#5B9AD1, 200), ShapeType._SQUARE_);
      backgroundShape.renderMode = CENTER;
      backgroundShape.SetFillColor(color(#103758));
      UIShapes.add(backgroundShape);
    }
    */
    
  //UI Only Buttons
    massEnergyTotal = new TextWindow("Mass Energy Total UI", new PVector(column3X, row2Y),
                             new PVector(iconSize.x + 200, iconSize.y), "Mass-Energy", false);
    massEnergyTotal.textRenderMode = CORNER; 
  }
  
  //Draw all menus and buttons
  public void DrawUI()
  {
    statusBar.DrawObject();
    DrawShapes(UIShapes);
    DrawButtons(allToggleButtons);
    massEnergyTotal.DrawObject();
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
    
    String massEnergyText = "Mass-Energy:  ";
    massEnergyText += String.format("%,d",civ.massEnergy);
    massEnergyTotal.UpdateText(massEnergyText);
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
        click = CheckClickableOverlap(civ.missiles, _clickLocation);
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
        if(phys.owner != civ.name)    //The clicked object is NOT owned by this civ
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
  
  private void HandleClickedGameObject(Clickable click)
  {
    if(click != null)    //We actually clicked something
    {
      if(clickFocus == null)  //We currently have NOTHING selected -- just get a new target
      {     
        SelectNewTarget(click); //<>//
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
  
}
