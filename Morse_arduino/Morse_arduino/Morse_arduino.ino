int buttonPin = 2;
int ledPin = 13;
int buttonState = 0;

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
    // light on when button is pressed
    digitalWrite(ledPin, HIGH);
    //Serial.println(buttonState);
    //send the buttonState value to Processing
    Serial.write((byte)buttonState);
    // don't overflow port, so wait a bit
    delay(500);  
  } else {
    // shut off light when button is not pressed
    digitalWrite(ledPin, LOW);
  }
}
