int buttonPin = 11;
int ledPin = 2;
int buttonState;
// setup a timer to measure the length of the button press
unsigned long timer = 0;
int finalTimerValue = 0;

void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // read whether button is pressed
  buttonState = digitalRead(buttonPin);

  if (buttonState == HIGH) {
    // track the time of button press
    timer = millis();
    // Light the LED
    digitalWrite(ledPin, HIGH);
    // send info through serial
    Serial.println("1");
    Serial.println(timer);
  }
  if (buttonState == LOW) {
    finalTimerValue = timer;
    //String pressLength;
    // classify the length of the button press
    // a long press is 2 seconds long in morse code
    /*    
    if (finalTimerValue > 2000) {
      return "long";
    } else {
      return "short";
    }
    
    Serial.println("0 FTValue: "+ finalTimerValue);
    Serial.println("0 timer: " + timer);
    */

    // reset timer
    timer = 0;  
    // will be needed later to split words and sentences according to length of not pressing the button
    digitalWrite(ledPin, LOW);  // already handled this in the butpresss function?
    Serial.println("0");
    Serial.println(finalTimerValue);
  }
  delay(50);
}