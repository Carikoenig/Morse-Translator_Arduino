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
    pressLength = butPressLength();
    Serial.println("1" + pressLength);
  } else {
    digitalWrite(ledPin, LOW); 
    Serial.println("0");
    //Serial.println(buttonState);
  }
  delay(20);
}

String butPressLength(){
  if(buttonState == HIGH){
    timer = millis();

  if(buttonState == LOW){}
  }}