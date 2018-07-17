/*
   Set val_u high (wide goal posts)

  DG:
   val_0:72.73  val_1:196   val_2:4   val_b:43  val_u:251   val_a:240   val_r:142 //amber stuck at 240
   val_0:10.07  val_1:183   val_2:39  val_b:7   val_u:216   val_a:39  val_r:18
   val_0:22.87  val_1:184   val_2:72  val_b:16  val_u:183   val_a:72  val_r:42 //first one I was particularly happy with
   val_0:22.76  val_1:186   val_2:72  val_b:15  val_u:183   val_a:72  val_r:42 //Not a full reading, just resetting goal posts, but I'm happy with this too (possibly slighthly less than above)

  LW:
  val_0:22.66   val_1:204   val_2:91  val_b:11  val_u:164   val_a:91  val_r:46 //match on just moving dials #2/#3 with #1 set to ~DG (23)
  val_0:34.63   val_1:205   val_2:98  val_b:17  val_u:157   val_a:98  val_r:70 //match just moving #1 after above
  val_0:34.68   val_1:196   val_2:89  val_b:20  val_u:166   val_a:89  val_r:67 //match back on #2/#3
  val_0:33.66   val_1:196   val_2:89  val_b:20  val_u:166   val_a:89  val_r:65 // final adjustment on #1

  SA:
  val_0:22.81   val_1:175   val_2:50  val_b:18  val_u:205   val_a:50  val_r:39 // dial #2/3 match
  val_0:20.75   val_1:175   val_2:50  val_b:16  val_u:205   val_a:50  val_r:36 //
  val_0:47.98   val_1:195   val_2:59  val_b:29  val_u:196   val_a:59  val_r:93 //aborted

  DG:
  (Try setting val_u high?)
  ... Is it high enough already?
  ... Is there any negative impact of having it higher?
  val_0:18.11   val_1:185   val_2:62  val_b:12  val_u:193   val_a:62   val_r:33 //DG @1522 18/07/2017. DIfficult match to make, resorted to using #1 in mode designed for #2/3, but fairly happy with result in both modes
  val_0:31.28   val_1:186   val_2:100 val_b:21  val_u:255   val_a:100  val_r:58 //DG Set val_u high (wide goal posts)






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
const unsigned long L_dark   = 5000; //5 seconds dark before pre-light
const long L_break  = 10000; //10 seconds break between pulses
const long L_pulse  = 1000; //1 second pulse

const float C_hz    = 8;
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
  //  // NARROW Goal Posts
  //  // percentage brightness of red/blue
  //  //0-1023 --> 10-60
  //  val_0 = 60 - (analogRead(potPin_0)) / 20.46;
  //
  //  // red/blue-ness: At one end, all blue, at the other all red
  //  //0-1023 --> 175-226
  //  val_1 = 226 - (analogRead(potPin_1) / 20);
  //
  //  // yellow/uv-ness
  //  //0-1023 --> 50-101
  //  val_2 = 101 - (analogRead(potPin_2) / 20);
  //
  //  val_b = int((256 - val_1) * (val_0 / 100));   //~25-75    *conversion factor (reduces) ... 0.25-75
  //  val_u = 255 - val_2;                          //~154-255
  //  val_a = val_2;                                //=50-101
  //  val_r = int(val_1       * (val_0 / 100));     //=175-226  *conversion factor (reduces) ... 1.75-226

  // WIDE goal posts
  // percentage brightness of red/blue
  //0-1023 --> 0-100
  val_0 = (analogRead(potPin_0)) / 10.23;

  // red/blue-ness: At one end, all blue, at the other all red
  //0-1023 --> 0-255
  val_1 = (analogRead(potPin_1) / 4);

  // yellow/uv-ness: Blue fader (amber stays high)
  //0-1023 --> 0-255
  val_2 = (analogRead(potPin_2) / 4);

  val_b = int((256 - val_1) * (val_0 / 100));
  val_u = 255;
  val_a = val_2;
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
      previousTime = millis();
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
  //  String s11 = String(C_pulse);
  //  Serial.println(s11);
  //  Serial.println("--------");

}
