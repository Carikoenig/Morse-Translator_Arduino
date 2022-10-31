// watch user input regulations...what if no letters that can be translatd into morseß
// what if user inputs endless text...have a limit
// what i fno input was given...give user a message to put input etc.

/*
https://processing.org/tutorials/text/#displaying-text
https://en.wikipedia.org/wiki/Morse_code
controlP5 library
 */

// TODO: set up git repository for the project!!!!

// import and setup GUI library
import controlP5.*;
ControlP5 cp5;
//prepare text stuff
String user_input = "";
String display_input = "";
PFont f;
PFont instructionFont;
// setup the connection to the arduino part
import processing.serial.*;
Serial port;
float buttonState;

//TODO: make a dictionary to translate letters to morse

void setup() {
  size(1500, 600);
  background(255);

  f = createFont("Arial", 26, true); // Arial, 16 point, anti-aliasing on
  instructionFont = createFont("Arial", 9, true); 

  cp5 = new ControlP5(this);
  //TODO: how to center the cp5 elements on screen...they're a bit off
  cp5.addTextfield("input").setPosition(300, 200).setSize(1000, 80).setFont(f);
  cp5.addButton("translate").setPosition(width/2, 300).setSize(180, 60).setFont(f);
  
  printArray(Serial.list());  // 0 passt
  String arduinoPort = Serial.list()[0];
  port = new Serial(this, arduinoPort, 9600);
}

void draw() {
  // TODO: clear the screen, so old inputs don't stay printed when new things are being drawn when user input gets changed
  background(255); // nicer to only redraw if user_input got changed?
  // TODO: how to format the user input, so that is going to be nicely formatted
  // make breaks when it is out of range from screen etc

  // TODO: doe it really have to be redrawn every single frame??? can we have some reraw only when the b
  //the button gets pushed?
  textFont(f, 26);
  textAlign(CENTER);
  text("1. Enter your text in the blue field.", width/2, 50);
  text("2.Press enter.", width/2, 100);
  text("3. Click on TRANSLATE", width/2, 150);
  textFont(f, 36);
  //text(user_input, width/2, 50);
  float w = textWidth(user_input);
  //println("This is the width of the user_input in the specific font and size: " + w);
  if (w>=1500) {
    //println("if triggered, text too big");
    //TODO: save too big input in some way though so user won't have to enter everything again?
    fill(255, 0, 50);
    text("The input is too big for the screen!", width/2, 300);
  } else {
    fill(100);
    text(user_input, width/2, 300);
  }
  
  // info send through Serial
  if (port.available() > 0) { // If data is available,
    buttonState = port.read();        // read it and store it in val
    buttonState = map(buttonState, 0, 255, 0, height);  // Convert the value
  }
  rect(100, height-100, 50, 20);
  println(buttonState);
}

void input(String input) {
  //TODO: make a limit to limit the amount of user input
  //set the user_input variable that draw() is showing on screen.
  user_input = input;
}
void translate() {
  // TODO: make a morse translation from the user_input variable at button click
}

// ASK: Why does my led not light the way I want? How to send info from Processing to Arduino? 
