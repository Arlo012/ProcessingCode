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
  
  public Civilization(PVector _upperCorner, String _name, ArrayList<Ship> _fleet, ArrayList<Planet> _planets, 
          ArrayList<Station> _stations, ArrayList<Missile> _missiles)
  {
    topCorner = _upperCorner;
    name = _name;
    fleet = _fleet;
    planets = _planets;
    stations = _stations;
    missiles = _missiles;
    
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
    }
    else if(PVector.dist(topCorner,new PVector(width,0)) == 0)
    {
      orientation = CivOrientation.RIGHT;
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
