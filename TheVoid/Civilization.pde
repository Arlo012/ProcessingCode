public enum CivOrientation {
LEFT, RIGHT
}

int civIDcounter = 1;
public class Civilization implements Updatable
{
  //Units
  ArrayList<Ship> fleet;
  ArrayList<Planet> planets;
  ArrayList<Station> stations;
  ArrayList<Missile> missiles;
  ArrayList<LaserBeam> lasers;
  ArrayList<Shield> shields;              //Draw & update is handled by parent ship
  color outlineColor;
  
  //Unique info
  String name;
  int ID;                               //1 or 2
  private PVector topCorner;            //Which corner is this civilization in (0,0) or (width,0)
  CivOrientation orientation;
  int lastSecondUpdated = -1;                //0-59 of last time updated

  //UI window (TODO: move to playerController)
  TextWindow CivNameWindow;
  
  //Resources
  int massEnergy = 900;
  
  public Civilization(PVector _upperCorner, String _name)
  {
    topCorner = _upperCorner;
    name = _name;
    fleet = new ArrayList<Ship>();
    planets = new ArrayList<Planet>();
    stations = new ArrayList<Station>();
    missiles = new ArrayList<Missile>();
    lasers = new ArrayList<LaserBeam>();
    shields = new ArrayList<Shield>();
    
    ID = civIDcounter;
    civIDcounter++;
    if(ID > 2)
    {
      println("ERROR: Too many civiliazations generated!");
    }
    
    //Determine civilization orientation (LEFT?RIGHT)
    if(PVector.dist(topCorner,new PVector(0,0)) == 0)
    {
      orientation = CivOrientation.LEFT;
      outlineColor = color(0,255,0);
    }
    else if(PVector.dist(topCorner,new PVector(width,0)) == 0)
    {
      orientation = CivOrientation.RIGHT;
      outlineColor = color(255,0,0);
    }
    else
    {
      orientation = CivOrientation.RIGHT;
      println("ERROR: Incorrectly assigned civilization corner. Assuming right-side");
    }
    
    //Build civ name window based on side
    PVector windowSize = new PVector(250,50);
    if(orientation == CivOrientation.LEFT)
    {
      CivNameWindow = new TextWindow("Civ name window", topCorner, windowSize, name, 15, false);
    }
    else
    { 
      PVector textLocation = new PVector(topCorner.x - windowSize.x, topCorner.y);
      CivNameWindow = new TextWindow("Civ name window", textLocation, windowSize, name, 15, false);
    }
    CivNameWindow.SetTextRenderMode(CENTER);
  }
  
  //On clock of 1 second only
  public void Update()
  {
    if(lastSecondUpdated != second())
    {
      for(Station s : stations)
      {
        massEnergy += s.massEnergyGen;
      }
      lastSecondUpdated = second();
    }
    
    //TODO update my units
  }
  
  
  public void DrawCivilizationUI()
  {
    CivNameWindow.DrawObject();
  }
  
  //Place an icon in the upper-left corner of the civilization info screen
  public void SetCivilizationIcon(PImage _icon, int _size)
  {
    //HACK: the icon is rendering center and I don't see why -- just manually adjust with text window size
    CivNameWindow.AddIcon(new PVector(-CivNameWindow.size.x/2 + _size, CivNameWindow.size.y/2), 
    new PVector(_size, _size), _icon);
  }
  
}
