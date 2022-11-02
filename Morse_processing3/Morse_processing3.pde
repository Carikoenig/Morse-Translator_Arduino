// watch user input regulations...what if no letters that can be translatd into morse: letters or other symbols that are not in 
// the international morse code chart will be ignored when translating text to the Arduino LED 

/*
https://processing.org/tutorials/text/#displaying-text
 https://en.wikipedia.org/wiki/Morse_code
 controlP5 library
 millis: https://www.arduino.cc/reference/en/language/functions/time/millis/
 trim: https://processing.org/reference/trim_.html
 connect processing to arduino: https://learn.sparkfun.com/tutorials/connecting-arduino-to-processing/all#from-processing
 */


// import and setup GUI library
import controlP5.*;
ControlP5 cp5;
//prepare text stuff
String user_input = "";
String display_input = "";
PFont f;
PFont f2;
PFont b;
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
// store the transformed signal grouped by having each letter or space in its own array
ArrayList<IntList> MorseAsLetters = new ArrayList<IntList>();
// have a temporary space to group the letter signal that belong together...might not workaout because templ always gets overwritten
//IntList templ = new IntList(); // might not be needed...exchange for templstring
String templstring = "";
//store the Letters that the signal from Arduino has been translated to
StringList Letters = new StringList();
// actually just recording the String right away should suffice
//String ArduinoToLetters = ""; // might not be needed
StringDict morseLetterDict; // to be filled in setup
// the finally finished String translation originated from the Arduino signal
String stringTranslation = "";
// show translation only after button was pressed by user on screen (0 = don't show, 1 = show)
int showTranslation = 0;
int showWarning = 0;
// show user hint in case translation button has been pressed before
int showArduinoHint = 0;
// contains the translations for letters to morse signals
StringDict morseSigDict; // filled in setup
// stores the complete Letter to Morse signal translation, so it can be printed on screen later
IntList morseList = new IntList();


void setup() {
  size(1900, 800);
  background(255);

  f = createFont("Arial", 26, true); 
  f2 = createFont("Arial", 16, true); 
  b = createFont("Arial Bold", 26, true);

  // load the morse alphabet picture to be shown on screen in draw()
  morsePic = loadImage("InternationalMorseCodePicFromWiki.PNG");

  cp5 = new ControlP5(this);
  // Screen to Arduino elements
  cp5.addTextfield("input").setPosition(50, 200).setSize(850, 150).setFont(f);
  cp5.addButton("translate").setPosition((width/4)-90, 550).setSize(180, 60).setFont(f);
  // Arduino to Screen elements
  cp5.addButton("translate_to_text").setPosition((width/2 + width/4 + 20), 510).setSize(200, 40).setFont(f2);
  cp5.addButton("delete").setPosition((width/2 + width/4 + 250), 510).setSize(200, 40).setFont(f2);

  //printArray(Serial.list());  // 0 passt
  String arduinoPort = Serial.list()[0];
  port = new Serial(this, arduinoPort, 9600);
  port.bufferUntil('\n');

  // create and fill the morse dictionary (s = short, L = long)
  morseLetterDict = new StringDict();
  //letters
  morseLetterDict.set("sL", "A");
  morseLetterDict.set("Lsss", "B");
  morseLetterDict.set("LsLs", "C");
  morseLetterDict.set("Lss", "D");
  morseLetterDict.set("s", "E");
  morseLetterDict.set("ssLs", "F");
  morseLetterDict.set("LLs", "G");
  morseLetterDict.set("ssss", "H");
  morseLetterDict.set("ss", "I");
  morseLetterDict.set("sLLL", "J");
  morseLetterDict.set("LsL", "K");
  morseLetterDict.set("sLss", "L");
  morseLetterDict.set("LL", "M");
  morseLetterDict.set("Ls", "N");
  morseLetterDict.set("LLL", "O");
  morseLetterDict.set("sLLs", "P");
  morseLetterDict.set("LLsL", "Q");
  morseLetterDict.set("sLs", "R");
  morseLetterDict.set("sss", "S");
  morseLetterDict.set("L", "T");
  morseLetterDict.set("ssL", "U");
  morseLetterDict.set("sssL", "V");
  morseLetterDict.set("sLL", "W");
  morseLetterDict.set("LssL", "X");
  morseLetterDict.set("LsLL", "Y");
  morseLetterDict.set("LLss", "Z");
  //numbers
  morseLetterDict.set("sLLLL", "1");
  morseLetterDict.set("ssLLL", "2");
  morseLetterDict.set("sssLL", "3");
  morseLetterDict.set("ssssL", "4");
  morseLetterDict.set("sssss", "5");
  morseLetterDict.set("Lssss", "6");
  morseLetterDict.set("LLsss", "7");
  morseLetterDict.set("LLLss", "8");
  morseLetterDict.set("LLLLs", "9");
  morseLetterDict.set("LLLLL", "0");


  // setup the dictionary that translates the other way around, from letters to morse signals
  morseSigDict = new StringDict();
  morseSigDict.set("A", "12");
  morseSigDict.set("B", "2111");
  morseSigDict.set("C", "2121");
  morseSigDict.set("D", "211");
  morseSigDict.set("E", "1");
  morseSigDict.set("F", "1121");
  morseSigDict.set("G", "221");
  morseSigDict.set("H", "1111");
  morseSigDict.set("I", "11");
  morseSigDict.set("J", "1222");
  morseSigDict.set("K", "212");
  morseSigDict.set("L", "1211");
  morseSigDict.set("M", "22");
  morseSigDict.set("N", "21");
  morseSigDict.set("O", "222");
  morseSigDict.set("P", "1221");
  morseSigDict.set("Q", "2212");
  morseSigDict.set("R", "121");
  morseSigDict.set("S", "111");
  morseSigDict.set("T", "2");
  morseSigDict.set("U", "112");
  morseSigDict.set("V", "1112");
  morseSigDict.set("W", "122");
  morseSigDict.set("X", "2112");
  morseSigDict.set("Y", "2122");
  morseSigDict.set("Z", "2211");
  //numbers
  morseSigDict.set("1", "12222");
  morseSigDict.set("2", "11222");
  morseSigDict.set("3", "11122");
  morseSigDict.set("4", "11112");
  morseSigDict.set("5", "11111");
  morseSigDict.set("6", "21111");
  morseSigDict.set("7", "22111");
  morseSigDict.set("8", "22211");
  morseSigDict.set("9", "22221");
  morseSigDict.set("0", "22222");
  //new word (code=8) when space as input given
  morseSigDict.set(" ", "8");
}

void draw() {

  // clear the screen, so old inputs don't stay printed when new things are being drawn when user input gets changed
  background(255); 


  // Screen to Arduino GUI
  textFont(f, 26);
  textAlign(CENTER);
  fill(100);
  text("1. Enter your text in the blue field.", width/4, 50);
  text("2.Press enter.", width/4, 100);
  text("3. Click on TRANSLATE", width/4, 150);
  textFont(f, 26);
  text("Your Input:", 110, 400);
  text("Your Output:", 110, 700);
  // measure the width of the text to restrict input in case it exceeds the allocated space for it
  float w = textWidth(user_input);
  if (w>=(width/2)) {
    fill(255, 0, 50);
    text("The input is too big for the screen!", width/4, 460);
    showArduinoHint = 0;
  } else {
    textFont(b, 26);
    fill(0);
    text(user_input, width/4, 460);
    // reset the text setting to the standard
    textFont(f, 26);
    fill(100);
  }
  if (showArduinoHint == 1) {
    fill(32, 6, 149);
    text("Watch arduino LED blink the morse code...", width/4, 700);
  }

  // Screen to Arduino Logic
  // all handled by the translate button function outside of draw
  // debugging
  println("The morse list(P to A): " + morseList);



  //line to seperate the Screen-Arduino/ Arduino-Screen functionalities visually
  line(width/2, 0, width/2, height);



  // Arduino to Screen GUI

  // instructions
  textFont(f, 26);
  fill(100);
  textAlign(CENTER);
  fill(32, 6, 149);
  text("Use the button on the Arduino to input morse signals.", width/2+width/4, 50);
  fill(100);

  //insert morse picture from wiki, so you have a chart to do morse with in case you're actually not fluent in morse
  image(morsePic, width/2 + 50, 100, 400, 450);

  //use the area next to the pic to display the morse input from user as circles and rectangles
  text("Your Input:", width/2 + width/4 + width/8, 120);



  // Arduino to Screen Logic

  // TODO: Outsource stuff in smaller functions for readability!!
  // TODO: make morse code signs bigger?

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
          // add a long press to the IntList storage
          MorseReceivedFromArduino.append(2);
          // add a long press to the temporary letter grouping space
          //templ.append(2);
          templstring = templstring + "L";
        } else if (previousInput/10 < 3000 && previousState == 1) {
          // add a short press to the IntList and templ
          MorseReceivedFromArduino.append(1);
          //templ.append(1);
          templstring = templstring + "s";
        } else if (previousState == 0 && previousInput/10 <=1000) {
          // add a simple space (between signals of same letter)
          MorseReceivedFromArduino.append(0);
          // do nothing with the templ
        } else if (previousState == 0 && previousInput/10 <=3000) {
          // add a space between letters
          MorseReceivedFromArduino.append(7);
          //since the signal that belongs to one letter (e.g. short-long-long) is finished we can determine which letter it belongs to
          String letter = checkLetter(templstring);
          // add the letter to the string translation
          //ArduinoToLetters = ArduinoToLetters + letter;
          stringTranslation = stringTranslation + letter;
          // after having pushed the templ to the other list, empty the temporary space so it can be filled with the new letter
          //templ.clear();
          // make the temporary string storage empty again so it can be filled with a new letter
          templstring = "";
        } else if (previousState == 0 && previousInput/10 > 3000) {
          // add a space between words (ideally it should be 7 seconds long, which technically is more than 3000;))
          MorseReceivedFromArduino.append(8);
          // an in between words space emerging means a) that the letter ends (if there was one before) and b) we have to put a space in the Output string
          if (templstring != "") {
            String letter = checkLetter(templstring);
            stringTranslation = stringTranslation + letter + " ";
            templstring = "";
          }
        } else {
          // error tracking
          MorseReceivedFromArduino.append(9);
          // append a "joker" letter to the Letter list...how to display this? Ignore?
          stringTranslation = stringTranslation + "(^o^)";
        }
      }

      //TODO: get rid of ANOYING flimmer...solution so far: put a small delay
      // TODO: trim the beginning space (half done, but what if it starts with 9?)

      // display the received signals in the IntList on screen as circles and rectangles
      int xloc = width/2 + width/4 + 20;
      int yloc = 200;
      int shapesize = 10;
      int xshift = 15;
      int filler = shapesize/2;
      fill(0);
      ellipseMode(CORNERS);
      // start loop with i = 1 because value at 0 always is the useless space that gets recorded before you push the button the first time
      for (int i = 1; i < MorseReceivedFromArduino.size(); i++) {
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

      // better way to stop flimmer probs exists, but for now...
      delay(7);
      // idea: instead of running through the foor loop all the way everytime: cut out the already read by making an object array of shapes that is going to be printed???maybe...but we would have to for loop through that as well to paint every time^^


      // Display the translated text on screen
      // make an array out of the array that groups the letters and spaces together in its own array by seperating after the spaces




      // was once useful for debugging
      //println("InputTrans: " + transInput);
      //println(SignalReceivedFromArduino);
      println(MorseReceivedFromArduino);
      //println("Letter list: " + MorseAsLetters);
      println(stringTranslation);

      //overwrite the previous States to the new ones for next loop
      previousInput = transInput;
      previousState = pressedState;
    }
  }

  // show the translated string (if button has been previously pressed)
  if (showTranslation == 1 && stringTranslation != "") {
    // needs to be checked double since printing continues even after the button was pressed if the user gives more input then (then the input could get too big at some point)
    if (textWidth(stringTranslation) > width/2) {
      showWarning = 1;
      // delete the stringtrans and templ
      stringTranslation = "";
      templstring = "";
    }
    textFont(b, 26);
    fill(0);
    textAlign(CENTER);
    text(stringTranslation, width/2+width/4, 700);
  }
  // show warning when user input too big
  if (showWarning == 1) {
    fill(255, 0, 50);
    text("The translation is too big for the screen, please delete your morse input!", width/2+width/4, 600);
  }
}

void input(String input) {
  //TODO: make a limit to limit the amount of user input...in draw() done?
  //set the user_input variable that draw() is showing on screen.
  user_input = input;
}

void translate() {

  // only translate if the input isn't too big
  if (textWidth(user_input)<=(width/2)) {

    // tell user to watch the Arduino to see translation;)
    showArduinoHint = 1;
    // remove everything from the Morse List from previous translations
    morseList.clear();
    // transform all letters to Uppercase, since only uppercase letters are in the Dictionary
    String input_upper = user_input.toUpperCase();
    //debugging
    println("Input_upper: " + input_upper);
    for (int i = 0; i < input_upper.length(); i++) {
      // get the char in the String at position i
      char singlel = input_upper.charAt(i);
      //debugging
      println("Char"+i+": "+singlel);
      String singles = str(singlel);
      //debugging
      println("singles letter string: "+singles);
      // look up the string representation of the morse code signal
      String morsesig = morseSigDict.get(singles);
      //debugging
      println("morsesig from dict: "+morsesig);

      // send integer signals to the Arduino if a representation of the character was found in the dict
      if (morsesig != null) {
        for (int s = 0; s <= morsesig.length(); s++) {
          // do this while we're inside the signal index
          if (morsesig.length() > s) {
            char signal = morsesig.charAt(s);
            //d
            //println("sinlge char signal" + s + " from letter" + i +": " + signal);
            // make the char into a string again, because otherwise int() will give me the ASCII number when I feed it with a character
            String signal2 = str(signal);
            //d
            //println("Signal2: "+signal2);
            int number = int(signal2);
            //d
            //println("single char signal as number: "+ number);
            port.write(number);
            // write signal seperator 0 not needed since Arduino side handles that
            // save the signal in a list for complete storage of signal on the processing side
            morseList.append(number);
            //also add signal seperator in case it isn't a space anyways
            if (number != 8) {
              morseList.append(0);
            }
          } else if (morsesig.length() == s && morsesig.charAt(0) != '8') {
            // we need to send a 7 when we are done looping through a single letter signal // not always (case letter is 8 = space)
            port.write(7);
            morseList.append(7);
            //d
            //println("END OF LETTER");
          }
        }
      } else {
        // send an error code otherwise
        port.write(9);
        //TODO: spereator needed? handling 9 not thought out yet
        // save the error in the IntList representation of the whole translation
        morseList.append(9);
        morseList.append(0);
      }
    }
  }
  /*
  // tell user to watch the Arduino to see translation;)
   showArduinoHint = 1;
   // remove everything from the Morse List from previous translations
   morseList.clear();
   // transform all letters to Uppercase, since only uppercase letters are in the Dictionary
   String input_upper = user_input.toUpperCase();
   //debuging
   println("Input_upper: " + input_upper);
   // TODO: make a morse translation from the user_input variable at button click
   for (int i = 0; i < input_upper.length(); i++) {
   // get the char in the String at position i
   char singlel = input_upper.charAt(i);
   //debugging
   println("Char"+i+": "+singlel);
   String singles = str(singlel);
   //debugging
   println("singles letter string: "+singles);
   // look up the string representation of the morse code signal
   String morsesig = morseSigDict.get(singles);
   //debugging
   println("morsesig from dict: "+morsesig);
   
   // send integer signals to the Arduino if a representation of the character was found in the dict
   if (morsesig != null) {
   for (int s = 0; s <= morsesig.length(); s++) {
   // do this while we're inside the signal index
   if (morsesig.length() > s) {
   char signal = morsesig.charAt(s);
   //d
   //println("sinlge char signal" + s + " from letter" + i +": " + signal);
   // make the char into a string again, because otherwise int() will give me the ASCII number when I feed it with a character
   String signal2 = str(signal);
   //d
   //println("Signal2: "+signal2);
   int number = int(signal2);
   //d
   //println("single char signal as number: "+ number);
   port.write(number);
   // write signal seperator 0 not needed since Arduino side handles that
   // save the signal in a list for complete storage of signal on the processing side
   morseList.append(number);
   //also add signal seperator in case it isn't a space anyways
   if (number != 8) {
   morseList.append(0);
   }
   } else if (morsesig.length() == s && morsesig.charAt(0) != '8') {
   // we need to send a 7 when we are done looping through a single letter signal // not always (case letter is 8 = space)
   port.write(7);
   morseList.append(7);
   //d
   //println("END OF LETTER");
   }
   
   }
   } else {
   // send an error code otherwise
   port.write(9);
   //TODO: spereator needed? handling 9 not thought out yet
   // save the error in the IntList representation of the whole translation
   morseList.append(9);
   morseList.append(0);
   }
   
   
   
   }
   */
}

void translate_to_text() {
  // when button gets pressed show the translation on the screen
  if (textWidth(stringTranslation) < width/2) {
    showTranslation = 1;
    // since string is always one letter behing...push the last letter in the string (except for when templstring is empty)
    if (templstring != "") {
      String letter = checkLetter(templstring);
      stringTranslation = stringTranslation + letter + " ";
      templstring = "";
    }
  } else {
    showWarning = 1;
    templstring = "";
    stringTranslation = "";
  }
}

void delete() {
  // remove all entries from the IntList where the Morse signal from Arduino is stored 
  // and delete the previous translation text
  MorseReceivedFromArduino.clear();
  stringTranslation= "";
  showTranslation = 0;
  showWarning = 0;
  templstring = "";
}

String checkLetter(String morsedLetter) {
  // determine which character is matched with the morsedLetter
  String letter = morseLetterDict.get(morsedLetter);
  if (letter != null) {
    return letter;
  } else {
    return "(?)";
  }
}
