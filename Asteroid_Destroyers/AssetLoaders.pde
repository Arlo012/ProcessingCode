//Image Assetss
PImage bg;             //Background
PImage lion, skull;    //Icons

//TODO move all PImage instances here
PImage redLaser, greenLaser;
void LoadImageAssets()
{
  //bg = loadImage("Assets/Backgrounds/image5_0.jpg");
  bg = loadImage("Assets/Backgrounds/spacefield_a-000.png");
  bg.resize(width, height);
  
  //Load sprites
  asteroidSpriteSheet = loadImage("Assets/Environment/asteroids.png");
  shipSprite = loadImage("Assets/Ships/10(2).png");
  lion = loadImage("Assets/Icons/Lion.png");
  skull = loadImage("Assets/Icons/Skull.png");
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
GameArea asteroidField, topAsteroidSpawn, bottomAsteroidSpawn, P1Field, P2Field;
void BuildGameAreas()
{
  gameAreas = new HashMap<String, GameArea>();

  //Create asteroid field filling half of the screen
  asteroidField = new GameArea("Asteroid Field", new PVector(width/3, 0), 
                      new PVector(width/3, height));
  gameAreas.put(asteroidField.GetName(), asteroidField);

  //Create two asteroid spawn areas
  topAsteroidSpawn = new GameArea("Top Asteroid Spawn", new PVector(width/3, -150), 
                      new PVector(width/3, 100));
  bottomAsteroidSpawn = new GameArea("Bottom Asteroid Spawn", new PVector(width/3, height + 50), 
                      new PVector(width/3, 100));
  gameAreas.put(topAsteroidSpawn.GetName(), topAsteroidSpawn);
  gameAreas.put(bottomAsteroidSpawn.GetName(), bottomAsteroidSpawn);

  //Left/right player area
  P1Field = new GameArea("P1 Build Area", new PVector(0, 0), 
                      new PVector(width/3, height));
  P2Field = new GameArea("P2 Build Area", new PVector(2*width/3, 0), 
                      new PVector(width/3, height));
  P1Field.SetDebugColor(color(0, 0, 255));
  P2Field.SetDebugColor(color(255, 0, 0));
  gameAreas.put(P1Field.GetName(), P1Field);
  gameAreas.put(P2Field.GetName(), P2Field);
}

//Setup two civilizations and associated objects
void GameObjectSetup()
{
  //Game object initializers
  asteroids = new ArrayList<Asteroid>();
  debrisSpawned = new ArrayList<Asteroid>();
  GenerateAsteroids(asteroidField);        //See Helpers.pde
  
  //Civilization setup
  P1 = new Civilization(new PVector(0,0), "Robot Jesus Collective");
  P1.SetCivilizationIcon(skull,24);
  
  P2 = new Civilization(new PVector(width,0), "Normal Squishy Humans");
  P2.SetCivilizationIcon(lion,24);
 
  //Planet setup
  GeneratePlanets(P1Field, P1, 4);
  GeneratePlanets(P2Field, P2, 4); 
 
  //Station setup
  GenerateStations(P1, 4);
  GenerateStations(P2, 4);
  
  //Controller setup
  Controller1 = new PlayerController(P1);
  Controller2 = new PlayerController(P2);
  currentPlayer = Controller1;
  otherPlayer = Controller2;
  
  //UI setup
  toDisplay = new LinkedList<Clickable>();
  
  //Effects setup
  explosions = new ArrayList<Explosion>();
}
