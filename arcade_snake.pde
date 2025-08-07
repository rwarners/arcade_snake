static boolean USE_SHADER = !System.getProperty("os.name", "").trim().equals("Linux"); //on = nice effects but slow performance on pi 4

//can be changed in settings
int gridWidth = 32;
//can be changed in settings
boolean powerUps = true;
//can be changed in settings
boolean wallsDissapear = true;
//will be calculated based on gtidWith and screen size
int gridHeigtht = 0; 

final int INITIAL_SNAKE_LENGTH = 4;
final int INITIAL_FOOD_COUNT = 8;

enum GameState {
  PLAYING, PAUSED, GAME_OVER, INTRO
}
GameState gameState;

ArrayList<Food> foodList = new ArrayList();
ArrayList<Wall> walls = new ArrayList();

//size of the the cells in the (invisble) grid, will be calculated based on the width of the screen
int gridCellSizePx;

SnakePlayer player1;
SnakePlayer player2;
SoundManager soundManager;

PShader shader;
PImage img;

int frameRateMax = 12;  //snakes move at this speed

void setup() {
  fullScreen(USE_SHADER?P2D:JAVA2D);
  pixelDensity(1);
  noCursor();
  frameRate(8); 
  updateGridSizes(gridWidth);
  setupInput();
  setupScreens();
  setupSettings();
  setupSound();
  createPlayers();
  initGame();
  gameState = GameState.INTRO;
  soundManager.playMusic();

  if (USE_SHADER) {
    shader = loadShader("crt_effect.glsl");
    shader.set("iResolution", float(width), float(height), 1.0);  //pass width and heigt to shader
  } else {
    img = loadImage("crt8.jpg");
    img.resize(width, height);
  }
}

void updateGridSizes(int gridWidthInCells) {
  gridWidth = gridWidthInCells;
  gridCellSizePx = width/gridWidth; //how muchpixels each cell/blokc/grid item is
  gridHeigtht = height/gridCellSizePx;
}

void draw() {
  updateInput();
  updateGame();
  renderGame();
}

void updateGame() {
  switch (gameState) {
  case PLAYING:
    soundManager.playMusic();
    if (player1.isFast() ||  frameCount  % 2 ==0) {
      player1.moveFurther();
      handleFoodCollisions(player1);
    }
    if (player2.isFast() ||  frameCount  % 2 ==0) {
      player2.moveFurther();
      handleFoodCollisions(player2);
    }

    if (checkGameOverConditions()) { 
      gameState = GameState.GAME_OVER;
      soundManager.playGameOver();
    }
    break;
  case PAUSED:
    soundManager.stopMusic();
    break;
  default:
    //no logic
  }
}


void renderGame() {
  if (USE_SHADER) {
    background(10, 10, 10);
  } else {
    background(img);
  }

  switch (gameState) {
  case PLAYING:
    renderGameplay();
    break;
  case PAUSED:
    renderGameplay();
    renderPauseScreen();
    break;
  case GAME_OVER:
    renderGameplay(); // Show final state
    renderGameOver();
    break;
  case INTRO:
    renderIntroScreen();
    break;
  }

  renderScore();

  if (USE_SHADER) {
    // Apply CRT shader on everythibg so far
    //works only with size(P2D) or fulLSCreen(P2D) and remove the PImage backcground
    filter(shader);
  } else {
    drawScanLines();
  }
  
   renderFPS();
}

void drawScanLines() {
  stroke(10, 10, 10, 30); // semi-transparent black
  strokeWeight(4);
  for (float y = 0; y <  height; y += 6) {
    line(5, y, width-5, y);
  }
}

void renderFPS() {
  text("FPS: " + (int)frameRate, (width/2)-30, 100);
}


void handleFoodCollisions(SnakePlayer player) {
  for (int i = foodList.size() - 1; i >= 0; i--) {
    Food food = foodList.get(i);
    if (player.hitFood(food)) {
      soundManager.playFood();
      player.grow(food.growPoints);
      player.addPowerUp(food.power);
      foodList.remove(i); // Safe removal in reverse order
      Food newFood = createFood(18, true);
      foodList.add(newFood); // Adding at end is safe
    }
  }
}


void renderGameplay() {
  // Draw food first so snakes appear on top
  for (Food food : foodList) {
    food.draw();
  }

  for (Wall wall : walls) {
    wall.draw();
  }

  player1.draw();
  player2.draw();
}


void renderScore() {
  fill(255, 255, 255);
  textAlign(LEFT);
  text("Score: " + player1.getScore(), 120, 100);
  textAlign(RIGHT);
  text("Score: " + player2.getScore(), width - 120, 100);
}

boolean checkHitWall(SnakePlayer player) {
  walls.removeIf(wall -> !wall.isVisible());

  for (Wall wall : walls) {
    if (player.getHeadPosition().equals(wall.position)) {
      return true;
    }
  }

  return false;
}

boolean checkGameOverConditions() {
  boolean player1Dead = checkPlayerDead(player1);
  boolean player2Dead = checkPlayerDead(player2);
  boolean player1HitOther = player1.hitOtherSnake(player2);
  boolean player2HitOther = player2.hitOtherSnake(player1);
  return player1Dead || player2Dead || player1HitOther || player2HitOther;
}



boolean checkPlayerDead(SnakePlayer player) {
  if (player.isInVincible()) {
    return false;
  }
  boolean hitWall = checkHitWall(player);
  boolean hitSelf = player.hitSelf();

  return hitWall || hitSelf;
}

void startFreshPlay() {
  gameState = GameState.PLAYING;
  initGame();
  soundManager.playStart();
}

//used everytime a new game starts
void initGame() {
  walls.clear();
  player1.respawn();
  player2.respawn();
  createInitialFood();
}


void createPlayers() {
  int startX1 = INITIAL_SNAKE_LENGTH ;
  int startX2 = gridWidth - INITIAL_SNAKE_LENGTH ;
  int startY = 5;

  player1 = new SnakePlayer(new PVector(startX1, startY), 4, Direction.RIGHT, color(29, 105, 219));
  player2 = new SnakePlayer(new PVector(startX2, startY), 4, Direction.LEFT, color(219, 105, 29));
}

void createInitialFood() {
  foodList.clear();
  for (int i = 0; i < INITIAL_FOOD_COUNT; i++) {   
    foodList.add(createFood(15, false));
  }
}

void looseTail(SnakePlayer player) {
  while (player.getLength() > INITIAL_SNAKE_LENGTH) {
    walls.add(new Wall(player.loseTail(), wallsDissapear));
  }
}

void usePowerPlayer(SnakePlayer player) {
  //if (player.usesPower()) return;
  if (!powerUps) return;

  String power = player.removePowerAvailable();
  if (Food.POWER_SPEED == power) {
    player.setFast(true);
  }
  if (Food.POWER_INVINCIBLE == power) {
    player.setInvincible(true);
  }
  if (Food.POWER_WALL == power) {
    looseTail(player);
  }
}
