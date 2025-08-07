class SnakePlayer {
  private ArrayList<PVector> body = new ArrayList();
  private ArrayList<String> powerUpsCollected = new ArrayList();

  private final static int MAX_POWERUP_COLLECTED = 4;
  //when player starts again these are the head and tail positions defining the sname's body
  private PVector headPositionStart;
  private int lengthStart;
  private Direction directionStart;


  //just storing if the player is fast after usign powerup
  private int nrOfMovementsFast = 0;
  private int nrOfMovementsInvincible = 0;
  private static final int MAX_FRAMES_FAST = 12;
  private static final int MAX_FRAMES_INVINCIBLE = 22;


  private color bodyColor;
  private int score;
  //current direction
  private Direction direction;


  //only when drawn = true we accept new inputs/movement, otherwise situation can occur when you go into illegal directions (into yourself)
  boolean drawn=false;


  SnakePlayer(PVector head, int length, Direction dir, color bodyColor) {
    this.bodyColor= bodyColor;
    this.headPositionStart = head;
    this.lengthStart=length;
    this.directionStart = dir;
    createBody(head, length, dir);
  }

  private void createBody(PVector head, int length, Direction dir) {
    body.clear();
    this.direction = dir;
    for (int i = 0; i < length; i++) {
      PVector segment = head.copy();
      switch (dir) {
      case RIGHT:
        segment.x -= i; // body trails to the left
        break;
      case LEFT:
        segment.x += i; // body trails to the right
        break;
      case UP:
        segment.y += i; // body trails downward
        break;
      case DOWN:
        segment.y -= i; // body trails upward
        break;
      }
      body.add(segment);
    }
  }

  boolean isInVincible() {
    return nrOfMovementsInvincible > 0;
  }

  void setInvincible(boolean inVincible) {
    nrOfMovementsInvincible = inVincible ? MAX_FRAMES_INVINCIBLE : 0;
  }

  boolean isFast() {
    return nrOfMovementsFast > 0;
  }

  boolean usesPower() {
    return isFast() || isInVincible();
  }


  void setFast(boolean fast) {
    nrOfMovementsFast = fast ? MAX_FRAMES_FAST : 0;
  }

  String removePowerAvailable() {
    return powerUpsCollected.isEmpty() ? null : powerUpsCollected.remove(0);
  }


  void addPowerUp(String powerUp) {
    if (powerUp!=null &&powerUpsCollected!=null && powerUpsCollected.size() < MAX_POWERUP_COLLECTED) {
      powerUpsCollected.add(0, powerUp);
    }
  }

  void respawn() {
    powerUpsCollected.clear();
    nrOfMovementsFast = 0;
    nrOfMovementsInvincible = 0;
    createBody(headPositionStart, lengthStart, directionStart);
  }

  PVector getHeadPosition() {
    return body.get(0);
  }

  int getLength() {
    return body.size();
  }

  void addScore(int numberOfPoints) {
    score += numberOfPoints;
  }

  int getScore() {
    return score;
  }

  PVector loseTail() {
    return body.remove(body.size() - 1);
  }

  void move(Direction target) {
    if (drawn && direction.isAllowed(target)) {
      direction = target;
      drawn = false;
    }
  }

  void moveDown() {
    move(Direction.DOWN);
  }
  void moveLeft() {
    move(Direction.LEFT);
  }

  void moveRight() {
    move(Direction.RIGHT);
  }

  void moveUp() {
    move(Direction.UP);
  }


  void draw() {
    //we draw the head last, so it is vsible when player hit itself
    for (int segmentPosition = body.size()-1; segmentPosition >= 0; segmentPosition--) {
      PVector positie = body.get(segmentPosition);
      //head
      if (positie.equals(getHeadPosition())) {
        stroke(255, 255, 255);
        if (isInVincible()) {
          float alpha = map(nrOfMovementsInvincible, MAX_FRAMES_INVINCIBLE, 0, 0, 255);
          float correctedAlpha = pow(alpha / 255.0, 4) * 255;
          fill(color(red(bodyColor-10), green(bodyColor-10), blue(bodyColor-10), correctedAlpha));
          strokeWeight(1);
          drawRectInGrid(positie);

          //drawCharacterInGrid(letter, positie, COLOR_WHITE);
        } else {
          strokeWeight(4);
          fill(bodyColor);
          drawRectInGrid(positie);
        }
      } else {
        colorMode(HSB, 100); //hsb in percentages now
        float hue = map(segmentPosition, 0, 40, 34, 5); //34 = green, so map length of snake to a value between 0 and 40 and map that to 34 to 5..,.
        fill(hue, 100, 100);
        //some parts of body look bit sifferetn, they can contiain items

        noStroke();
      }
      drawRectInGrid(positie);
      colorMode(RGB);

      if (segmentPosition < powerUpsCollected.size()) {
        String letter = powerUpsCollected.get(segmentPosition);
        drawCharacterInGrid(letter, positie, COLOR_WHITE);
      }
    }
    textAlign(LEFT, BASELINE);
    colorMode(RGB, 255);
    //a hack, is it time to draw or not
    //if (player1.isFast() ||  frameCount  % 2 ==0) {
    drawn = true;
    //}
  }

  float easeInOutQuad(float x) {
    return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2;
  }

  //snake moves, and sometimes geos through wall to other side
  void moveFurther() {
    if (isFast()) nrOfMovementsFast--;
    if (isInVincible()) nrOfMovementsInvincible--;
    PVector head = getHeadPosition();
    PVector newHead = direction.getNextWrappedPosition(head, gridWidth, gridHeigtht);
    body.add(0, newHead);
    body.remove(body.size() - 1);
  }


  boolean hitFood(Food food) {
    PVector head = getHeadPosition();
    return (head.x == food.position.x && head.y == food.position.y);
  }

  void grow(int nrToGrow) {
    for (int i=0; i<nrToGrow; i++) {
      body.add(new PVector(body.get(body.size() - 1).x, body.get(body.size() - 1).y));
    }
  }

  boolean hitOtherSnake(SnakePlayer other) {
    return other.body.contains(getHeadPosition());
  }

  boolean hitSelf() {
    return body.subList(1, body.size()).contains(getHeadPosition());
  }

  boolean occupiesPosition(PVector position) {
    return body.contains(position);
  }
}

//-----------------------------------------------------------------


public enum Direction {
  UP, DOWN, LEFT, RIGHT;

  public boolean isAllowed(Direction other) {
    boolean isSame = (this == other);
    boolean isOpposite = (this.getOpposite() == other);

    return !(isSame || isOpposite);
  }

  private Direction getOpposite() {
    switch (this) {
    case UP:
      return DOWN;
    case DOWN:
      return UP;
    case LEFT:
      return RIGHT;
    case RIGHT:
      return LEFT;
    default:
      throw new IllegalStateException("Onbekende richting: " + this);
    }
  }

  private PVector getNextPosition(PVector head) {
    switch (this) {
    case RIGHT:
      return new PVector(head.x + 1, head.y);
    case DOWN:
      return new PVector(head.x, head.y + 1);
    case LEFT:
      return new PVector(head.x - 1, head.y);
    case UP:
      return new PVector(head.x, head.y - 1);
    default:
      throw new IllegalStateException("Onbekende richting: " + this);
    }
  }
  //next postion based on direction and take into account going through the borders
  public PVector getNextWrappedPosition(PVector head, int gridWidth, int gridHeight) {
    PVector next = getNextPosition(head);

    // Wrap horizontally
    if (next.x < 0) {
      next.x = gridWidth - 1;
    } else if (next.x >= gridWidth) {
      next.x = 0;
    }

    // Wrap vertically
    if (next.y < 0) {
      next.y = gridHeight - 1;
    } else if (next.y >= gridHeight) {
      next.y = 0;
    }

    return next;
  }
}
