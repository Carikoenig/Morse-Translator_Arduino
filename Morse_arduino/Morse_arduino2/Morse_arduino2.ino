int buttonPin = 11;
int ledPin = 2;
int buttonState;
// setup a timer to measure the length of the button press
unsigned long timer;
//int finalTimerValue = 0;
unsigned long lastNotPressedTime = 0;
unsigned long lastPressedTime = 0;
unsigned long duration = 0;


void setup() {
  pinMode(buttonPin, INPUT);
  pinMode(ledPin, OUTPUT);
  Serial.begin(9600);
}

void loop() {
  // read whether button is pressed
  buttonState = digitalRead(buttonPin);
  // track the since program started to run
   timer = millis();
  
  if (buttonState == HIGH) {
    // track the time of button press
    lastPressedTime = millis();
    duration = lastPressedTime - lastNotPressedTime;
    // Light the LED
    digitalWrite(ledPin, HIGH);
    // send info through serial
    Serial.println("1");
    Serial.println(duration);
  }
  if (buttonState == LOW) {
    //finalTimerValue = timer;
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
    lastNotPressedTime = millis();  
    duration = lastNotPressedTime - lastPressedTime;
    // will be needed later to split words and sentences according to length of not pressing the button
    digitalWrite(ledPin, LOW);  // already handled this in the butpresss function?
    Serial.println("0");
    Serial.println(duration);
  }
  delay(50);
  
}