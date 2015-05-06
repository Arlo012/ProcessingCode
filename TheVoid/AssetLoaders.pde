//Image Assetss
PImage bg;             //Background

//TODO move all PImage instances here
PImage nebula1, nebula2, nebula3;
ArrayList<PImage> nebulaSprites;
PImage shipSprite; 
PImage shieldSprite;
PImage redLaser, greenLaser;
ArrayList<PImage> enemyShipSprites; 
ArrayList<PVector> enemyShipSizes;      //Size (by index) of above sprite
int enemyShipTypeCount = 10;                //HACK this is rigid -- careful to update if add ships
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

  //Shields
  shieldSprite = loadImage("Assets/Effects/ShieldFull.png");

  //Nebulas
  nebula1 = loadImage("Assets/Nebula/Nebula1.png");
  nebula2 = loadImage("Assets/Nebula/Nebula2.png");
  nebula3 = loadImage("Assets/Nebula/Nebula3.png");
  nebulaSprites = new ArrayList<PImage>();
  nebulaSprites.add(nebula1);
  nebulaSprites.add(nebula2);
  nebulaSprites.add(nebula3);

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

