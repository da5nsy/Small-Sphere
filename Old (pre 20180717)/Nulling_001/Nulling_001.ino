/*
   Forked from Fade_4led_0015, for serious nulling.
   Trying to emulate Spitschan scheme
*/

const int led_blue  = 5; // the PWM pin the LED is attached to
const int led_uv    = 6;
const int led_amber = 9;
const int led_red   = 10;

const int switchPin = 3; //The toggle switch

const int potPin_0  = A0; //The potentiometers
const int potPin_1  = A1;
const int potPin_2  = A2;

const float L_hz    = 60; //double the actual 'hz' (30hz)
const unsigned long L_dark   = 5000; //
const long L_break  = 10000; //10 seconds break between pulses
const long L_pulse  = 1000; //1 second pulse

const float C_hz    = 2;
const long C_break  = 1000; // 1 second break between pulses
const long C_pulse  = 500;

float val_0;
int   val_1;
int   val_2;

int   val_b;
int   val_u;
int   val_a;
int   val_r;

int switchVal;
unsigned long currentTime;
unsigned long previousTime;

void setup() {
  // Input
  pinMode(switchPin, INPUT);

  // Output
  pinMode(led_blue, OUTPUT);
  pinMode(led_uv, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);

  Serial.begin(9600);
  previousTime = millis();
}

void loop() {
  switchVal = digitalRead(switchPin);

  // percentage brightness of red/blue
  //0-1023 --> 50-80
  val_0 = 90 - (analogRead(potPin_0)) / 25.575;

  // red/blue-ness: At one end, all blue, at the other all red
  //0-1023 --> 175-225
  val_1 = 226 - (analogRead(potPin_1) / 20);

  // yellow/uv-ness: Blue fader (amber stays high)
  //0-1023 --> 50-100
  val_2 = 101 - (analogRead(potPin_2) / 20);

  val_b = int((256 - val_1) * (val_0 / 100));
  val_u = 255 - val_2;
  val_a = 240;
  val_r = int(val_1       * (val_0 / 100));

  if (switchVal == HIGH) {
    while (currentTime < previousTime + L_dark) {
      analogWrite(led_blue,   0);
      analogWrite(led_uv,     0); //light off for 5 seconds
      analogWrite(led_amber,  0);
      analogWrite(led_red,    0);
      currentTime = millis();
    }

    currentTime = millis();
    if (currentTime < previousTime + L_break) {
      analogWrite(led_blue,   0);
      analogWrite(led_uv,     val_u);
      analogWrite(led_amber,  val_a);
      analogWrite(led_red,    0);
      delay(500);
    }
    else {
      analogWrite(led_blue,   0);
      analogWrite(led_uv,     val_u);
      analogWrite(led_amber,  val_a);
      analogWrite(led_red,    0);
      delay(1000 / L_hz);

      analogWrite(led_blue,   val_b);
      analogWrite(led_uv,     0);
      analogWrite(led_amber,  0);
      analogWrite(led_red,    val_r);
      delay(1000 / L_hz);

      if (currentTime > previousTime + L_break + L_pulse) {
        previousTime = currentTime;
      }

    }
  }
  else {
    analogWrite(led_blue,   val_b);
    analogWrite(led_uv,     0);
    analogWrite(led_amber,  0);
    analogWrite(led_red,    val_r);
    delay(1000 / C_hz);

    analogWrite(led_blue,   0);
    analogWrite(led_uv,     val_u);
    analogWrite(led_amber,  val_a);
    analogWrite(led_red,    0);
    delay(1000 / C_hz);

    currentTime = millis();
    if (currentTime > previousTime + C_pulse) {
      delay(C_break);
      previousTime = currentTime;
    }
  }

  String s1 = "val_0:";
  String s2 = "\t val_1:";
  String s3 = "\t val_2:";
  String s4 = "\t val_b:";
  String s5 = "\t val_u:";
  String s6 = "\t val_a:";
  String s7 = "\t val_r:";
  String s8 = s1 + val_0 + s2 + val_1 + s3 + val_2 + s4 + val_b + s5 + val_u + s6 + val_a + s7 + val_r;
  Serial.println(s8);

//  String s9 = String(previousTime);
//  Serial.print("previousTime: \t");
//  Serial.println(s9);
//  String s10 = String(currentTime);
//  Serial.print("currentTime: \t");
//  Serial.println(s10);
//  //String s11 = String(C_pulse);
//  //Serial.println(s11);
//  Serial.println("--------");
  
}
