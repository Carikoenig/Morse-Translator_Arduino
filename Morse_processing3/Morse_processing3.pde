// watch user input regulations...what if no letters that can be translatd into morseß
// what if user inputs endless text...have a limit
// what i fno input was given...give user a message to put input etc.

/*
https://processing.org/tutorials/text/#displaying-text
 https://en.wikipedia.org/wiki/Morse_code
 controlP5 library
 millis: https://www.arduino.cc/reference/en/language/functions/time/millis/
 */


// import and setup GUI library
import controlP5.*;
ControlP5 cp5;
//prepare text stuff
String user_input = "";
String display_input = "";
PFont f;
PFont f2;
// prepare picture display on screen
PImage morsePic;
// setup the connection to the arduino part
import processing.serial.*;
Serial port;
int buttonState;
// not necessary any more
// store all the received morse signals created by pushing the button on the Arduino
//IntList SignalReceivedFromArduino = new IntList();
// temporary storage of previous state, used to compare with current in the loop to throw out unneccessary values (only keeping the highest)
int previousInput = 0;
int previousState = 0;
// store the transformed signal as Morse Code an Integer variation
// 1 = short press, 2 = long press, 0 = space for new signal, 7 = space for new letter, 8 = new word, 9 = error
IntList MorseReceivedFromArduino = new IntList();

//TODO: make a dictionary to translate letters to morse. joker symbol for not matching letter inputs (e.g. input that can't be found in the morse dict), handle errors as spaces?

void setup() {
  size(1900, 800);
  background(255);

  f = createFont("Arial", 26, true); // Arial, 16 point, anti-aliasing on
  f2 = createFont("Arial", 16, true); 

  // load the morse alphabet picture to be shown on screen in draw()
  morsePic = loadImage("InternationalMorseCodePicFromWiki.PNG");

  cp5 = new ControlP5(this);
  //TODO: how to center the cp5 elements on screen...they're a bit off
  // Screen to Arduino elements
  cp5.addTextfield("input").setPosition(50, 200).setSize(850, 150).setFont(f);
  cp5.addButton("translate").setPosition((width/4)-90, 380).setSize(180, 60).setFont(f);
  // Arduino to Screen elements
  cp5.addButton("translate_to_text").setPosition((width/2 + width/4 + 20), 510).setSize(200, 40).setFont(f2);
  cp5.addButton("delete").setPosition((width/2 + width/4 + 250), 510).setSize(200, 40).setFont(f2);

  printArray(Serial.list());  // 0 passt
  String arduinoPort = Serial.list()[0];
  port = new Serial(this, arduinoPort, 9600);
  port.bufferUntil('\n');
}

void draw() {
  // TODO: clear the screen, so old inputs don't stay printed when new things are being drawn when user input gets changed
  background(255); // nicer to only redraw if user_input got changed?
  // TODO: how to format the user input, so that is going to be nicely formatted
  // make breaks when it is out of range from screen etc


  // TODO: does it really have to be redrawn every single frame??? can we have some redraw only when the 
  //the button gets pushed?

  // Screen to Arduino GUI
  textFont(f, 26);
  textAlign(CENTER);
  fill(100);
  text("1. Enter your text in the blue field.", width/4, 50);
  text("2.Press enter.", width/4, 100);
  text("3. Click on TRANSLATE", width/4, 150);
  textFont(f, 26);
  //text(user_input, width/2, 50);
  float w = textWidth(user_input);
  //println("This is the width of the user_input in the specific font and size: " + w);
  if (w>=(width/2)) {
    //println("if triggered, text too big");
    //TODO: save too big input in some way though so user won't have to enter everything again?...nooo, we're not that nice^^
    fill(255, 0, 50);
    text("The input is too big for the screen!", width/4, 500);
  } else {
    fill(100);
    text(user_input, width/4, 500);
  }

  // TODO: Screen to Arduino Logic



  //line to seperate the Screen-Arduino/ Arduino-Screen functionalities visually
  line(width/2, 0, width/2, height);



  // Arduino to Screen GUI

  // instructions
  textFont(f, 26);
  fill(100);
  textAlign(CENTER);
  text("Use the button on the Arduino to input morse signals.", width/2+width/4, 50);

  //insert morse picture from wiki, so you have a chart to do morse with in case you're actually not fluent in morse
  image(morsePic, width/2 + 50, 100, 400, 450);

  //use the area next to the pic to display the morse input from user as circles and rectangles
  text("Your Input:", width/2 + width/4 + width/8, 120);



  // Arduino to Screen Logic

  // TODO: Outsource stuff in smaller functions for readability!!
  // TODO: display the integer morse as text on screen

  // receive data from the arduino side
  if (port.available() > 0) { 
    // Strings are used here, because  the transformation and sending of integers did not work,
    // even not after 2 tutors tried to help me in the workshop sessions on thursdays (thanks to Gino and the guy in the purple hoddie btw)
    String input = port.readStringUntil('\n');
    int transInput;
    int pressedState;
    if (input != null) {
      // transform the Sting into int
      // trim needed because otherwise I get a Format exception. It seems to be the case that whitespaces and other stuff,
      // which can't be parsed to an Integer can be send along through Serial Port
      input = input.trim();
      transInput = int(input);
      // 1 = button pressed, 0 = not pressed (get last digit by dividing through 10)
      pressedState = transInput % 10;
      // store every value
      //SignalReceivedFromArduino.append(transInput);


      if (previousState != pressedState) {

        // read the duration of the signal (divide through 10 to get rid of last digit that indicates press or no press)
        if (previousInput/10 > 3000 && previousState == 1) {
          // add a long press to the ArrayList
          MorseReceivedFromArduino.append(2);
        } else if (previousInput/10 < 3000 && previousState == 1) {
          // add a short press to the ArrayList
          MorseReceivedFromArduino.append(1);
        } else if (previousState == 0 && previousInput/10 <=1000) {
          // add a simple space (between signals of same letter)
          MorseReceivedFromArduino.append(0);
        } else if (previousState == 0 && previousInput/10 <=3000) {
          // add a space between letters
          MorseReceivedFromArduino.append(7);
        } else if (previousState == 0 && previousInput/10 > 3000) {
          // add a space between words (ideally it should be 7 seconds long, which technically is more than 3000;))
          MorseReceivedFromArduino.append(8);
        } else {
          // error tracking
          MorseReceivedFromArduino.append(9);
        }
      }

      //TODO: get rid of ANOYING flimmer
      // TODO: trim the beginning space
      
      // display the received signals in the IntList on screen as circles and rectangles
      int xloc = width/2 + width/4 + 20;
      int yloc = 200;
      int shapesize = 10;
      int xshift = 15;
      int filler = shapesize/2;
      fill(0);
      ellipseMode(CORNERS);
      for (int i = 0; i < MorseReceivedFromArduino.size(); i++) {
        int morseSig = MorseReceivedFromArduino.get(i);
        switch(morseSig) {
        case 1: 
          // short press
          ellipse(xloc, yloc, xloc+shapesize, yloc+shapesize);
          xloc = xloc + xshift;
          break;
        case 2: 
          // long press
          rect(xloc, yloc, shapesize*3, shapesize);
          xloc = xloc + shapesize*3 + filler;
          break;
        case 0:
          // seperate signal
          // nothing to do here since I already shift the x in case 1 and 2
          break;
        case 7:
          // new letter
          // make 3 units shift in x to mark new letter begin
          xloc = xloc + shapesize*3;
          break;
        case 8:
          // new word
          // make 7 units shift in x to mark new word begin
          xloc = xloc + shapesize*7;
          break;
        case 9:
          // error
          // display nothing for now??? TODO error handling
          break;
        }
        // reset yloc if needed
        if (xloc > width -50) {
          yloc = yloc + shapesize+filler;
          xloc = width/2 + width/4 + 20;
        }
        if (yloc > 460) {
          fill(255, 0, 50);
          textAlign(LEFT);
          text("Your input is too big for the screen!", width/2 + width/4 + 20, 165);
          break;
        }
      }


      // was once useful for debugging
      //println("InputTrans: " + transInput);
      //println(SignalReceivedFromArduino);
      println(MorseReceivedFromArduino);

      //overwrite the previous States to the new ones for next loop
      previousInput = transInput;
      previousState = pressedState;
    }
  }
  //buttonState = map(buttonState, 0, 255, 0, height);  // Convert the value

  //rect(100, height-100, 50, 20);
  //println(buttonState);
}

void input(String input) {
  //TODO: make a limit to limit the amount of user input
  //set the user_input variable that draw() is showing on screen.
  user_input = input;
}

void translate() {
  // TODO: make a morse translation from the user_input variable at button click
}

void translate_to_text() {
  // transform the IntList to a CharList, then make a string out of it and print it on screen
}

void delete() {
  // remove all entries from the IntList where the Morse signal from Arduino is stored
  MorseReceivedFromArduino.clear();
}
