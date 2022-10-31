int buttonPin = 11;
int ledPin = 2;
int buttonState;
// setup a timers to measure the length of the button press
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
    /*    
    if (finalTimerValue > 2000) {
      return "long";
    } else {
      return "short";
    }
    */
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