import net.java.games.input.Component.*;
import net.java.games.input.Controller;
import net.java.games.input.ControllerEnvironment;
import net.java.games.input.Event;
import net.java.games.input.EventQueue;

Controller[] controllers;
Event event;

// Map per GameState om acties + uit te voeren actie in op te slaan
HashMap<String, Runnable> playingActions = new HashMap<>();
HashMap<Component.Identifier, Runnable> pausedActions  = new HashMap<>();
HashMap<Component.Identifier, Runnable> gameOverActions = new HashMap<>();
HashMap<Component.Identifier, Runnable> introActions = new HashMap<>();

Runnable defaultPausedAction;
Runnable defaultIntroAction;
Runnable defaultGameOverAction;

int highLigtedCheckBoxIndex = -1;


void setupInput() {
  controllers = ControllerEnvironment.getDefaultEnvironment().getControllers();
  event  = new Event();

  if (!anyControllerKeyboardOrJoyStick()) {
    println("No controller keyboard or joystick found");
    exit();
  }

  setupButtonActions();
}

void setupButtonActions() {
  playingActions.put(Component.Identifier.Key.RIGHT.toString(), () -> player2.moveRight());
  playingActions.put(Component.Identifier.Key.D.toString(), () -> player1.moveRight());
  playingActions.put(Component.Identifier.Key.LEFT.toString(), () -> player2.moveLeft());
  playingActions.put(Component.Identifier.Key.A.toString(), () -> player1.moveLeft());
  playingActions.put(Component.Identifier.Key.UP.toString(), () -> player2.moveUp());
  playingActions.put(Component.Identifier.Key.W.toString(), () -> player1.moveUp());
  playingActions.put(Component.Identifier.Key.DOWN.toString(), () -> player2.moveDown());
  playingActions.put(Component.Identifier.Key.S.toString(), () -> player1.moveDown());
  playingActions.put(Component.Identifier.Key.ESCAPE.toString(), () -> togglePaused());
  playingActions.put(Component.Identifier.Key.SPACE.toString(), () -> togglePaused());
  playingActions.put(Component.Identifier.Button.BASE4.toString(), () -> togglePaused()); //START button
  playingActions.put(Component.Identifier.Button.BASE3.toString(), () -> speedUpBoth()); //SELECT button
  playingActions.put(Component.Identifier.Key.P.toString(), () -> speedUpBoth());
  playingActions.put(Component.Identifier.Key.LSHIFT.toString(), () -> usePowerPlayer(player1));
  playingActions.put(Component.Identifier.Key.RSHIFT.toString(), () -> usePowerPlayer(player2));
  playingActions.put(Component.Identifier.Key.X.toString(), () -> looseTail(player1));
  playingActions.put(Component.Identifier.Key.RETURN.toString(), () -> looseTail(player2));
  playingActions.put("0:"+Component.Identifier.Button.PINKIE, () -> usePowerPlayer(player1)); //a button
  playingActions.put("0:"+Component.Identifier.Button.TRIGGER, () -> usePowerPlayer(player1)); //a button
  playingActions.put("0:"+Component.Identifier.Button.TOP, () -> usePowerPlayer(player1)); //a button
  playingActions.put("0:"+Component.Identifier.Button.TOP2, () -> usePowerPlayer(player1)); //a button
  playingActions.put("0:"+Component.Identifier.Button.THUMB, () -> usePowerPlayer(player1)); //a button
  playingActions.put("0:"+Component.Identifier.Button.THUMB2, () -> usePowerPlayer(player1)); //a button
  playingActions.put("1:"+Component.Identifier.Button.PINKIE, () -> usePowerPlayer(player2)); //a button p2
  playingActions.put("1:"+Component.Identifier.Button.TRIGGER, () -> usePowerPlayer(player2)); //a button p2
  playingActions.put("1:"+Component.Identifier.Button.TOP, () -> usePowerPlayer(player2)); //a button p2
  playingActions.put("1:"+Component.Identifier.Button.TOP2, () -> usePowerPlayer(player2)); //a button p2
  playingActions.put("1:"+Component.Identifier.Button.THUMB, () -> usePowerPlayer(player2)); //a button p2
  playingActions.put("1:"+Component.Identifier.Button.THUMB2, () -> usePowerPlayer(player2)); //a button p2


  defaultPausedAction = () ->  togglePaused();
  pausedActions.put(Component.Identifier.Key.ESCAPE, () -> exit());
  pausedActions.put(Component.Identifier.Key.SPACE, () -> togglePaused());
  introActions.put(Component.Identifier.Key.DOWN, () -> selectNextCheckboxDown());
  introActions.put(Component.Identifier.Key.UP, () -> selectNextCheckboxUp());  
  pausedActions.put(Component.Identifier.Button.BASE4, () -> togglePaused());
  pausedActions.put(Component.Identifier.Button.BASE3, () -> exit()); //select will exit
  

  defaultGameOverAction = () ->  startFreshPlay();
  gameOverActions.put(Component.Identifier.Key.ESCAPE, () -> exit());
  gameOverActions.put(Component.Identifier.Button.BASE3, () -> exit()); //select will exit

  introActions.put(Component.Identifier.Key.ESCAPE, () -> exit());
  introActions.put(Component.Identifier.Key.DOWN, () -> selectNextCheckboxDown());
  introActions.put(Component.Identifier.Key.UP, () -> selectNextCheckboxUp());
  introActions.put(Component.Identifier.Key.RETURN, () -> checkboxToggle());
  introActions.put(Component.Identifier.Button.PINKIE, () -> usePowerPlayer(player1)); //a button
  introActions.put(Component.Identifier.Button.TRIGGER, () -> checkboxToggle()); //a button
  introActions.put(Component.Identifier.Button.TOP, () -> checkboxToggle()); //a button
  introActions.put(Component.Identifier.Button.TOP2, () -> checkboxToggle()); //a button
  introActions.put(Component.Identifier.Button.THUMB, () -> checkboxToggle()); //a button
  introActions.put(Component.Identifier.Button.THUMB2, () -> checkboxToggle()); //a button
  introActions.put(Component.Identifier.Button.PINKIE, () -> checkboxToggle()); //a button p2
  introActions.put(Component.Identifier.Button.TRIGGER, () -> checkboxToggle()); //a button p2
  introActions.put(Component.Identifier.Button.TOP, () -> checkboxToggle()); //a button p2
  introActions.put(Component.Identifier.Button.TOP2, () -> checkboxToggle()); //a button p2
  introActions.put(Component.Identifier.Button.THUMB, () -> checkboxToggle()); //a button p2
  introActions.put(Component.Identifier.Button.THUMB2, () -> checkboxToggle()); //a button p2
  defaultIntroAction = () -> startFreshPlay();
}

boolean anyControllerKeyboardOrJoyStick() {

  for (Controller c : controllers) {
    Controller.Type type = c.getType();
    if (type == Controller.Type.STICK || type == Controller.Type.GAMEPAD || type == Controller.Type.KEYBOARD) {
      return true;
    }
  }
  return false;
}



boolean detectJoystick() {

  for (Controller c : controllers) {
    Controller.Type type = c.getType();

    if (type == Controller.Type.STICK || type == Controller.Type.GAMEPAD) {
      return true;
    }
  }
  return false;
}

void speedUpBoth() {
  frameRate = frameRate+1; //when lowe than zero, becosme bigger again
  if (frameRate == frameRateMax) {
    frameRate= 5;
  }
  frameRate(frameRate);
}

void updateInput() {
  //controllerId is just the order in the list
  for (int controllerId = 0; controllerId < controllers.length; controllerId++) {
    Controller controller = controllers[controllerId];

    // Skip mouse controllers
    if (controller.getType() == Controller.Type.MOUSE) {
      continue;
    }

    controller.poll();
    EventQueue eventQueue = controller.getEventQueue();

    while (eventQueue.getNextEvent(event)) {
      Component component = event.getComponent();
      float inputValue = event.getValue();

      // Debug output for input events
      println(controllerId + " : " + component.getName() + " "+ component.getIdentifier() +" : " + inputValue);

      if (component.isAnalog()) {
        handleAnalogInput(controllerId, component.getIdentifier(), inputValue);
      } else {
        handleDigitalInput(controllerId, component.getIdentifier(), inputValue == 1.0f);
      }
    }
  }
}

//Joystick!
void handleAnalogInput(int controllerId, Component.Identifier identifier, float value) {
  Direction direction = getDirection(identifier, value);

  //we decide what player (based on id of controls) were used
  SnakePlayer player = (controllerId == 0) ? player1 : player2;

  if (GameState.PLAYING == gameState) {
    player.move(direction);
  } else if (GameState.INTRO == gameState) {
    if (direction == Direction.DOWN) {
      selectNextCheckboxDown();
    }
    if (direction == Direction.UP) {
      selectNextCheckboxUp();
    }
  }
}

Direction getDirection(Component.Identifier identifier, float value) {
  if (value==1.0f && identifier == Component.Identifier.Axis.X) {
    return Direction.RIGHT;
  }
  if (value==-1.0f && identifier == Component.Identifier.Axis.X) {
    return Direction.LEFT;
  }
  if (value==1.0f && identifier == Component.Identifier.Axis.Y) {
    return Direction.DOWN;
  }
  if (value==-1.0f && identifier == Component.Identifier.Axis.Y) {
    return Direction.UP;
  }

  return null;
}


//buttons keyboard or buttons from (arcade) controller
void handleDigitalInput(int controllerId, Component.Identifier identifier, boolean pressed) {
  // we are only interested when pressed = false, we opnly get that if it was "on" before, so thath qualifies as a key pressed
  if (!pressed) return;

  Runnable action = null;

  switch (gameState) {
  case PLAYING:
    action = playingActions.get(identifier.getName());
    //try with the controllerID in the name (caue we put it in the table like that)
    if (action==null) action = playingActions.get(controllerId+":"+identifier);
    break;
  case PAUSED:
    action = pausedActions.get(identifier);
    if (action == null) action = defaultPausedAction; //any other key
    break;
  case GAME_OVER:
    action = gameOverActions.get(identifier);
    if (action == null) action = defaultGameOverAction; //any other key
    break;
  case INTRO:
    action = introActions.get(identifier);
    if (action == null) action = defaultIntroAction; //any other key
    break;
  }

  if (action != null) {
    action.run();
  }
}


void togglePaused() {
  gameState = (gameState == GameState.PLAYING) ? GameState.PAUSED : GameState.PLAYING;
}
