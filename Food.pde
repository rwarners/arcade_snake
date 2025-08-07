class Food {
  final int COLOR_FOOD = color(255, 0, 0);
  final static String POWER_SPEED = "S";
  final static String POWER_WALL = "W";
  final static String POWER_INVINCIBLE = "I";

  PVector position;
  int growPoints;
  String power;

  Food(PVector position, int growPoints) {
    this(position, growPoints, null);
  }

  Food(PVector position, int growPoints, String power) {
    this.position=position;
    this.growPoints = growPoints;
    this.power = power;
  }

  private boolean isSpecial() {
    return power != null;
  }

  void draw() {
    noStroke();
    fill(COLOR_FOOD);
    boolean animate = isSpecial();
    drawRectInGrid(position, animate);
    if (growPoints > 1 && power ==null) {
      drawCharacterInGrid(String.valueOf(growPoints), position, COLOR_WHITE);
    }
    if (power !=null) {
      drawCharacterInGrid(power, position, COLOR_WHITE);
    }
  }
}

//--------------------------------------------------------------------------

PVector findRandomPositonToPutFood() {
  PVector position = new PVector();
  ;
  do {
    position.set(int(random(0, gridWidth)), int(random(0, gridHeigtht)));
  } while (isPositionFilledInGrid(position));
  return position;
}


Food createFood(int percentageKansOpBijznderFruit, boolean tryFurthestAway) {
  PVector position = getFoodSpawnPosition(tryFurthestAway);
    
  if (!powerUps) {
    return new Food(position, 1);
  }

  String power = getRandomFoodPowerOrNull(percentageKansOpBijznderFruit);

  if (power == null) {
    boolean isBonusGrow = random(100) < 20; // 20% kans op extra groeipunten
    int growAmount = isBonusGrow ? int(random(1, 4)) : 1;
    return new Food(position, growAmount);
  }

  return new Food(position, 1, power);
}


PVector getFoodSpawnPosition(boolean tryFurthestAway) {
  if (tryFurthestAway) {
    PVector furthest = findFarthestPositionToPutFood(player1.getHeadPosition(), player2.getHeadPosition(), gridWidth, gridHeigtht);
    if (furthest != null) {
      return furthest;
    }
  }
  return findRandomPositonToPutFood();
}

String getRandomFoodPowerOrNull(int percentageKansOpBijznderFruit) {
  if (random(100) < percentageKansOpBijznderFruit) { // kans op speciaal fruit
    boolean isInvincible = random(100) < 20;
    if (isInvincible) {
      return Food.POWER_INVINCIBLE;
    } else {
      boolean isSpeedPower = random(100 ) < 40; // procent kans op speed power, anders wall power
      return isSpeedPower ? Food.POWER_SPEED : Food.POWER_WALL;
    }
  }
  return null;
}

//finding a point that lies farthest from both A and B — but still within the grid.
PVector findFarthestPositionToPutFood(PVector a, PVector b, int gridWidth, int gridHeight) {
  PVector bestPoint = null;
  float maxDist = -1;
  PVector temp = new PVector();//we resue the same object

  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      PVector c = temp.set(x, y);
      if (isPositionFilledInGrid(c)) continue; // Skip occupied cells

      float distA = wrappedDist(a, c, gridWidth, gridHeight);
      float distB = wrappedDist(b, c, gridWidth, gridHeight);

      if (distA == distB && distA > maxDist) {
        maxDist = distA;
        bestPoint = c.copy();
      }
    }
  }

  return bestPoint;
}

float wrappedDist(PVector p1, PVector p2, int gridWidth, int gridHeight) {
  float dx = min(abs(p1.x - p2.x), gridWidth - abs(p1.x - p2.x));
  float dy = min(abs(p1.y - p2.y), gridHeight - abs(p1.y - p2.y));
  return sqrt(dx * dx + dy * dy);
}
