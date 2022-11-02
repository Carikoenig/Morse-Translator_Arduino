int buttonPin = 11;
int ledPin = 2;
int buttonState;
// setup a timers to measure the length of the button press
unsigned long lastNotPressedTime = 0;
unsigned long lastPressedTime = 0;
unsigned long duration = 0;
// store values coming from Processing
int received;


void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // Processing to Arduino part
  if (Serial.available()) {
    // read the incoming data from processing
    received = Serial.read();
    Serial.println(received);
    
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
      digitalWrite(ledPin, LOW);
      delay(1000);
      break;
    case 7:
      // new letter, we need a longer break than the obligatory 1 sec
      digitalWrite(ledPin, LOW);
      // in between letter break is 3 secs, since we always make 1 sec anyways add the remaining 2 secs
      delay(2000);
      break;
    case 8:
      // new word, break of 7 seconds needed(only put delay of 4000 because finish sending last letter comes with 3 sec break anyways)
      digitalWrite(ledPin, LOW);
      delay(4000);
      break;
    case 9:
    // error received (this means the character input from user was not in the MorseSigDict in processing)
    // TODO: how to handle this case?
    break;
    }    

  
  } else{
  // Arduino to Processing Part
  // read whether button is pressed
  buttonState = digitalRead(buttonPin);

  if (buttonState == HIGH) {
    // track the time of button press
    lastPressedTime = millis();
    duration = lastPressedTime - lastNotPressedTime;
    // Light the LED
    digitalWrite(ledPin, HIGH);
    // send info through serial
    Serial.println(String(duration) + "1");
  }
  if (buttonState == LOW) {
    //String pressLength;
    // classify the length of the button press
    // a long press is 2 seconds long in morse code
    // reset timer
    lastNotPressedTime = millis();
    // will be needed later to split words and sentences according to length of not pressing the button
    duration = lastNotPressedTime - lastPressedTime;
    // shut of light when button not pressed
    digitalWrite(ledPin, LOW);
    Serial.println(String(duration) + "0");
    //Serial.println(duration);
  }
  delay(50);

  }
  
  
}