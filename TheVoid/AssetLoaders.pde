//Image Assetss
PImage bg;             //Background

//TODO move all PImage instances here
PImage redLaser, greenLaser;
ArrayList<PImage> enemyShipSprites; 
ArrayList<PVector> enemyShipSizes;      //Size (by index) of above sprite
int enemyShipCount = 10;                //HACK this is rigid -- careful to update if add ships
void LoadImageAssets()
{
  bg = loadImage("Assets/Backgrounds/back_3.png");
  bg.resize(width, height);
  
  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");

  //enemy ships
  enemyShipSprites = new ArrayList<PImage>();
  enemyShipSizes = new ArrayList<PVector>();

  //Total of 10 enemy ship sprites
  enemyShipSprites.add(loadImage("Assets/Ships/7(1).png"));
  enemyShipSizes.add(new PVector(257,140));
  enemyShipSprites.add(loadImage("Assets/Ships/8(1).png"));
  enemyShipSizes.add(new PVector(232,182));
  enemyShipSprites.add(loadImage("Assets/Ships/9(1).png"));
  enemyShipSizes.add(new PVector(336,230));
  enemyShipSprites.add(loadImage("Assets/Ships/10(1).png"));
  enemyShipSizes.add(new PVector(110,116));
  enemyShipSprites.add(loadImage("Assets/Ships/11(1).png"));
  enemyShipSizes.add(new PVector(225,398));
  enemyShipSprites.add(loadImage("Assets/Ships/12(1).png"));
  enemyShipSizes.add(new PVector(122,342));
  enemyShipSprites.add(loadImage("Assets/Ships/13(1).png"));
  enemyShipSizes.add(new PVector(104,168));
  enemyShipSprites.add(loadImage("Assets/Ships/1(1).png"));
  enemyShipSizes.add(new PVector(135,124));
  enemyShipSprites.add(loadImage("Assets/Ships/2(1).png"));
  enemyShipSizes.add(new PVector(199,134));
  enemyShipSprites.add(loadImage("Assets/Ships/3(1).png"));
  enemyShipSizes.add(new PVector(248,182));

  missileSprite = loadImage("Assets/Weapons/Missile05.png");
  redStation1 = loadImage("Assets/Stations/Spacestation1-1.png");
  redStation2 = loadImage("Assets/Stations/Spacestation1-2.png");
  redStation3 = loadImage("Assets/Stations/Spacestation1-3.png");
  blueStation1 = loadImage("Assets/Stations/Spacestation2-1.png");
  blueStation2 = loadImage("Assets/Stations/Spacestation2-2.png");
  blueStation3 = loadImage("Assets/Stations/Spacestation2-3.png");
  smokeTexture = loadImage("Assets/Effects/Smoke/0000.png");
  redLaser = loadImage("Assets/Weapons/redLaser.png");
  greenLaser = loadImage("Assets/Weapons/greenLaser.png");
  
  //Load explosions (see Explosion.pde for variables)
  for (int i = 1; i < explosionImgCount + 1; i++) 
  {
    // Use nf() to number format 'i' into four digits
    String filename = "Assets/Effects/64x48/explosion1_" + nf(i, 4) + ".png";
    explosionImgs[i-1] = loadImage(filename);
  }
}

SoundFile explosionSound, collisionSound, laserSound, 
    clickShipSpawnButtonSound, clickMissileSpawnButtonSound, clickNormalModeButtonSound, 
    clickCancelOrderButtonSound, errorSound, shieldHitSound;
    
SoundFile introMusic;
ArrayList<SoundFile> mainTracks;
void LoadSoundAssets()
{
  String sketchDir = sketchPath("");    //Get current directory
  explosionSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Impact/explosion2.wav");
  collisionSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Impact/Hit Impact Metal Scrap Debris_UC 06.wav");
  laserSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Weapons/laser6.wav");
  clickShipSpawnButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/AstroDroid11.wav");
  clickMissileSpawnButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/AstroDroid26.wav");
  clickNormalModeButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/on.ogg");
  clickCancelOrderButtonSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/off.ogg");
  errorSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/UI/error.wav");
  shieldHitSound = new SoundFile(this, sketchDir + "Assets/SoundEffects/Impact/138489__randomationpictures__shield-hit-2.wav");

  //Music
  introMusic = new SoundFile(this, sketchDir + "Assets/Music/ZanderNoriega-Darker_Waves_0.mp3");
  mainTracks = new ArrayList<SoundFile>();
  SoundFile track1 = new SoundFile(this, sketchDir + "Assets/Music/e.ogg");
  SoundFile track2 = new SoundFile(this, sketchDir + "Assets/Music/Nebulous.mp3");
  SoundFile track3 = new SoundFile(this, sketchDir + "Assets/Music/poss_-_next_-_attack.mp3");
  SoundFile track4 = new SoundFile(this, sketchDir + "Assets/Music/streetsound_150_bpm.mp3");
  mainTracks.add(track1); 
  mainTracks.add(track2);
  mainTracks.add(track3);
  mainTracks.add(track4);
}


int sectorID = 1;      //Unique sector ID. Begin generating @ 1 because the startSector has ID = 0
SectorDirection[] sectorDirections = new SectorDirection[]{SectorDirection.UL, SectorDirection.Above, 
  SectorDirection.UR, SectorDirection.Left, SectorDirection.Right, SectorDirection.LL, 
  SectorDirection.Below, SectorDirection.LR};
/**
 * Generate sectors around the provided sector. Check which sectors have already been
 * generated by using the sector's neighbor pointers.
 * @param {Sector} _origin The starting sector from which to generate surrounding sectors
 */
void BuildSectors(Sector _origin)
{
  //Hold a list of sectors to generate linkings
  Sector[] sectorGenArray = new Sector[9];
  sectorGenArray[4] = _origin;      //origin is at core of these 9 sectors
  int sectorCounter = 0;

  //Check all 8 surrounding sectors 
  for(SectorDirection direction : sectorDirections)
  {
    Sector neighbor;     //Sector to generate or grab below
    if(!_origin.HasNeighbor(direction))
    {
      //No neighbor in this direction -- generate one
      PVector sectorLocation = _origin.GetNeighborLocation(direction);
      neighbor = new Sector(sectorID, sectorLocation, sectorSize, bg, SectorType.RANDOM);
      sectors.put(sectorID, neighbor);
      sectorID++;     //Next unique ID for this sector!
    }
    else
    {
      neighbor = _origin.GetNeighbor(direction);
    }

    sectorGenArray[sectorCounter] = neighbor;   //Track an adjacent sector

    sectorCounter++;            //Next sector!
    if(sectorCounter == 4)      //Skip -- this is the core
    {
      sectorCounter++;
    }
  }

  //Attach adjacent sectors to each other
  for(int i = 1; i < 10; i++)
  {
    if(i%3 != 0)    //If not far right side
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Right, sectorGenArray[i]);
      if(i > 3)   //Not top row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.UR, sectorGenArray[i-3]);
      }
      if( i < 7)   //Not bottom row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.LR, sectorGenArray[i+3]);
      }
    }
    if(i != 1 && i%4 != 0)    //Not far left side
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Left, sectorGenArray[i-2]);
      if(i > 3)   //Not top row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.UL, sectorGenArray[i-5]);
      }
      if( i < 7)   //Not bottom row
      {
        sectorGenArray[i-1].SetNeighbor(SectorDirection.LL, sectorGenArray[i+1]);
      }
    }
    if(i > 3)     //Not top row
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Above, sectorGenArray[i-4]);
    }
    if(i < 7)     //Not bottom row
    {
      sectorGenArray[i-1].SetNeighbor(SectorDirection.Below, sectorGenArray[i+2]);
    }   

  }
}


/**
 * Load assets such as sprites, music, and build all sectors.
 */
void GameObjectSetup()
{
  LoadImageAssets();
  LoadSoundAssets();
  
  Sector startSector = new Sector(0, new PVector(0,0), sectorSize, bg, SectorType.PLANETARY);
  sectors.put(0, startSector);
  
  //Generate other sectors around this one
  println("[INFO] Generating sectors around the origin...");
  BuildSectors(startSector);
  BuildSectors(startSector.GetNeighbor(SectorDirection.Right));
  BuildSectors(startSector.GetNeighbor(SectorDirection.Left));    //HACK this should just be done recursively, but book-keeping tough
  BuildSectors(startSector.GetNeighbor(SectorDirection.Below));
  BuildSectors(startSector.GetNeighbor(SectorDirection.Above));
  // BuildSectors(startSector.GetNeighbor(SectorDirection.UL));
  // BuildSectors(startSector.GetNeighbor(SectorDirection.UR));
  // BuildSectors(startSector.GetNeighbor(SectorDirection.LL));
  // BuildSectors(startSector.GetNeighbor(SectorDirection.LR));
  println("[INFO] Start sector generation complete! There are now " + sectorID + " sectors generated.");

  //DEBUG FOR LINKING SECTORS
  if(debugMode.value)
  {
    println(startSector);
  }
  
}
