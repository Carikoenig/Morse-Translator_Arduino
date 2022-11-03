/* Morse Translator: this code is part of my (Carina König) final project for the DBB100 Creative Programming course from TU/e. 
It builds a translation device, that enables the user to translate Morse code signals.
The device works both ways - it can translate morse to text, or text to morse.

Besides this arduino code, an Arduino and several additional electrical components (LED, push-buttons, cable, breadboard, 2 resistors),
as well as the processing programming script is needed to make it work.
*/

int buttonPin = 11;
int ledPin = 2;
int buttonState;
// setup timers to measure the length of the button press
unsigned long lastNotPressedTime = 0;
unsigned long lastPressedTime = 0;
unsigned long duration = 0;
// store values temporarily that got sent from Processing in here
int received;


void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  
  // Processing to Arduino part

  // As long as data from Processing is being sent prioritize this work step, so don't accept input from the Arduino button.
  // To avoid confusion, only accept data transferral in the other direction, once data sending from Processing has finished.
  if (Serial.available()) {

    // read the incoming data from processing
    received = Serial.read();
    // depending on which signal got sent, decide whether and for how long to light the LED
    switch (received) {
      case 1:
        // short blink
        digitalWrite(ledPin, HIGH);
        delay(1000);
        // add the obligatory break afterwards of at least one unit
        digitalWrite(ledPin, LOW);
        delay(1000);
        break;
      case 2:
        // long blink
        digitalWrite(ledPin, HIGH);
        delay(3000);
        // add the obligatory break afterwards of at least one unit
        digitalWrite(ledPin, LOW);
        delay(1000);
        break;
      case 7:
        // new letter, we need a longer break than the obligatory 1 sec
        digitalWrite(ledPin, LOW);
        // in between letter break is 3 secs, since we always make 1 sec break anyways after a signal, add the remaining 2 secs
        delay(2000);
        break;
      case 8:
        // new word, break of 7 seconds needed (only put delay of 4000 because finish sending last letter comes with 3 sec break anyways)
        digitalWrite(ledPin, LOW);
        delay(4000);
        break;
      case 9:
        // error received (this means the character input from user was not in the MorseSigDict in processing)
        // Since we don't have a translation for this, just do nothing...
        break;
    }


  } else {

    // Arduino to Processing Part

    // read whether button is pressed
    buttonState = digitalRead(buttonPin);
    // send a corresponding signal to processing, containing info about press state and duration (and light the LED when the button is pressed of course)
    // info is send every x milli seconds. This creates many values that later won't be necessary e.g. sending the info of button being pressed 1 sec
    // and then x milli seconds later still pressed but duration got updated to 1 sec and x millis. 
    // The processing code side handles this by filtering out the lower duration values of the same button press (or not press), by only taking the highest duration value into account.
    if (buttonState == HIGH) {
      // track the time of button press
      lastPressedTime = millis();
      // determine the duration of the button press: we have measured the time when the button was not pressed the last time. Subtract this time from the now time.
      duration = lastPressedTime - lastNotPressedTime;
      // Light the LED
      digitalWrite(ledPin, HIGH);
      // send info through serial: we send a string with the duration and an added number, that tells whether the button was pressed(=1).
      Serial.println(String(duration) + "1");
    }
    if (buttonState == LOW) {
      // save the now time as the time the button was not pressed the last time
      lastNotPressedTime = millis();
      // measure the duration of the not pressed state
      duration = lastNotPressedTime - lastPressedTime;
      // shut of light when button not pressed
      digitalWrite(ledPin, LOW);
      // send the info about duration and not presed state(=0) to processing
      Serial.println(String(duration) + "0");
    }
    // delay for x milli seconds to not overflow processing with too much data.
    delay(50);
  }
}