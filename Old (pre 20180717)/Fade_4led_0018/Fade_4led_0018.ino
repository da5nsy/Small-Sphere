/*
  COPY OF _0015, resurected for later testing:

  
  Testing settinig points

  Match for DG (at 7hz), with amber maxed
  82.50  195 0   | 50  160 255 255

  Match for DG (at 7hz), with amber decreased to 240
  66.28  207 88  | 32  137 167 240 | 14/02
  75.66  197 93  | 44  149 162 240 | (roughly) 14/02
  72.34  206 92  | 36  149 163 240 | (fairly precisely) 1619 14/02
  60.31  197 59  | 35  118 196 240 | 2hz with black ring removed, 14/02
  65.00  205 63  | 33  133 192 240 | 2hz with black ring removed, 14/02
  60.31  221 75  | 21  133 180 240 | 20hz with black ring removed, 14/02
  54.25  197 66  | 32  106 189 240 | 7hz with black ring removed, 14/02
  -- made controls more precise--
  -- range limited to:  50-80
                        175-225
                        50-100
  15/02: black ring removed, in dark, without glasses, with ski-mask, with screen behind (showing white disk with square black fixation):
  7hz  68.09 208 90  | 32  141 165 240  13:00
  5hz  67.71 203 78  | 35  137 177 240  13:00 (78 should be 75?- loose connection)
  5hz  71.85 201 81  | 39  144 174 240  14:30 (observation: felt stable at medium eccentricity, with minor slight flicker at low ecc and medium flickr at high ecc)
                                              cont. #2 knob could be made more sensitive (it quickly goes from strong red to strong blue)
                                              whereas #3 could be made less sensitive (it barely seems to affect the appearance of the stimuli)
                                              -- modified knob #1 to run between 50 and 90 (checking that I wan't limiting the luminance range)
  5hz  77.68 204 81  | 40  158 174 240  15:30 Flicker still present, not entirely nulled, but best match possible.
  5hz  58.37 206 98  | 29  120 157 240  16:45
  5hz  77.14 197 88  | 45  151 167 240  17:40
  5hz  77.14 202 87  | 41  155 168 240  17:40 Immediate re-do following lower than expected #2 on prev. Just re-set #2.
  5hz  72.68 175 50  | 58  127 205 240  9:00  Hannah (without mask)
  5hz  67.44 206 95  | 33  138 160 240  9:00  "
  5hz  76.28 207 97  | 37  157 158 240  9:00  "
  5hz  71.31 208 98  | 34  148 157 240  10:00 "
  5hz  65.41 218 86  | 24  142 169 240  10:00 Danny with mask
  5hz  62.67 198 86  | 36  124 169 240  Immediate retrial of above
  5hz  77.61 198 76  | 45  153 179 240  23/02 as 15/02


 
*/

int led_uv =    3; // the PWM pin the LED is attached to
int led_blue =  5;
int led_amber = 9;
int led_red =   10;

int potPin_0 =    A0; //
int potPin_1 =    A1;
int potPin_2 =    A2;

float val_0 = 70;
int val_1 = 200;
int val_2 = 80;

int hz = 5;

void setup() {
  pinMode(led_uv, OUTPUT);
  pinMode(led_blue, OUTPUT);
  pinMode(led_amber, OUTPUT);
  pinMode(led_red, OUTPUT);

  Serial.begin(9600);
}

void loop() {

  // percentage brightness of red/blue
  //0-1023 --> 50-80
  val_0 = 90 - (analogRead(potPin_0)) / 25.575; // read the value from the sensor

  // red/blue-ness: At one end, all blue, at the other all red
  //0-1023 --> 175-225
  val_1 = 226 - (analogRead(potPin_1) / 20); // read the value from the sensor

  // yellow/uv-ness: Blue fader (amber stays high)
  //0-1023 --> 50-100
  val_2 = 101 - (analogRead(potPin_2) / 20); // read the value from the sensor

/*
  analogWrite(led_uv,     0);
  analogWrite(led_amber,  0);
  analogWrite(led_blue,   int((256 - val_1) * (val_0 / 100)));
  analogWrite(led_red,    int(val_1       * (val_0 / 100)));
  delay(1000 / hz);
//*/

///*
  analogWrite(led_blue,   0);
  analogWrite(led_red,    0);
  analogWrite(led_uv,     255 - val_2);
  analogWrite(led_amber,  240);
  delay(1000 / hz);
//*/
  Serial.print(hz);
  Serial.print("hz");
  Serial.print("\t");
  Serial.print(val_0);
  Serial.print("\t");
  Serial.print(val_1);
  Serial.print("\t");
  Serial.print(val_2);
  Serial.print("\t");
  Serial.print("|");
  Serial.print("\t");
  Serial.print(int((256 - val_1) * (val_0 / 100)));
  Serial.print("\t");
  Serial.print(int(val_1       * (val_0 / 100)));
  Serial.print("\t");
  Serial.print(255 - val_2);
  Serial.print("\t");
  Serial.println(240);



}
