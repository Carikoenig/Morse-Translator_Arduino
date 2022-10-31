int buttonPin = 11;
int ledPin = 2;
int buttonState = 0;
// setup a timer to measure the length of the button press
unsigned long timer;

void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {

  // read whether button is pressed
  buttonState = digitalRead(buttonPin);
  //Serial.println(buttonState);

  if (buttonState == HIGH) {
    //Light the LED
    digitalWrite(ledPin, HIGH);
    // determine how long the button was pressed
    String pressLength = butPressLength();
    Serial.println("1" + pressLength);
  } else {
    // will be needed later to split words and sentences according to length of not pressing the button
    //digitalWrite(ledPin, LOW); // already handled this in the butpresss function?
    Serial.println("0");
    //Serial.println(buttonState);
  }
  delay(20);
}

String butPressLength() {
  int finalTimerValue = 0;
  //TODO: if while both problematic. send timer values to arduino and decide there if the highest val was reached and then classify
  if (buttonState == HIGH) {
    timer = millis();
  }
  digitalWrite(ledPin, LOW);
  if (buttonState == LOW) {
    finalTimerValue = timer;
    timer = 0;  // reset the timer for the next time the button gets pressed
  }
  // classify the length of the button press
  // a long press is 2 seconds long in morse code
  if (finalTimerValue > 2000) {
    return "long";
  } else {
    return "short";
  }
}