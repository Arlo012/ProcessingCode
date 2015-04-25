//Image Assetss
PImage bg;             //Background

//TODO move all PImage instances here
PImage redLaser, greenLaser;
void LoadImageAssets()
{
  bg = loadImage("Assets/Backgrounds/back_3.png");
  bg.resize(width, height);
  
  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");
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


//Generate the game areas used to identify pieces of the playing field. View these in debugmode
int sectorID = 1;      //Unique sector ID. Begin generating @ 1 because the startSector has ID = 0
void BuildSectors(Sector _origin)
{
  //TODO:
  //Around the origin sector, build all 8 other sectors....
  //re-use for other generation

  //Old code for gameAreas....
  // asteroidField = new Sector("Asteroid Field", new PVector(width/3, 0), 
  //                     new PVector(width/3, height));
  // sectors.put(asteroidField.GetName(), asteroidField);
}

//TODO merge in sector generation here...

void GameObjectSetup()
{
  LoadImageAssets();
  LoadSoundAssets();
  
  Sector startSector = new Sector(0, new PVector(0,0), sectorSize, bg);
  sectors.put(0, startSector);
  
  //TODO generate other sectors around this one
  //BuildSectors(startSector);    //See AssetLoaders.pde
}
