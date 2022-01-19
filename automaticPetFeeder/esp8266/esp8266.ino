#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <Servo.h>

//Provide the token generation process info.
#include <addons/TokenHelper.h>

//Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>


#define WIFI_SSID "SerhatMuratFurkan"
#define WIFI_PASSWORD "21032000"

#define API_KEY "AIzaSyAF7qgiz-y6u0OzGhVLFn_kktQ1RYhr9LE"
#define DATABASE_URL "deneme2-28fe3-default-rtdb.europe-west1.firebasedatabase.app" 

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;

// donanim
const int led = 2;

Servo sg90; // create a servo object
int servoPin = 15; // ESP8266 D8 // GPIO15 - 16

void setup(){

  Serial.begin(115200);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED){
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback; //see addons/TokenHelper.h

  /* Sign up */
  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("ok");
    signupOK = true;
  }
  else{
    Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  
  sg90.attach(servoPin); // attaches the servo on pin 13 to the servo object
  pinMode(led, OUTPUT); 
}

void loop(){

  // && signupOK
  if (Firebase.ready() && signupOK){

    if (Firebase.RTDB.getString(&fbdo, "/led/ledStatus")) {
      int ledStatus = fbdo.intData();
        Serial.print("ledStatus ");
        Serial.println(ledStatus);

        if(ledStatus == 1){
          digitalWrite(led, LOW);
          Serial.println("led yakıldı");
        }
        else if(ledStatus == 0){
          digitalWrite(led, HIGH);
          Serial.println("led kapatıldı");
        }
        else{
          Serial.println("ledStatus kısmında bilginmeyen bir hata oluştu");
        }
    }
    else {
      Serial.println("ledStatus elseye girdi hata: " + fbdo.errorReason());
    }
    
    if (Firebase.RTDB.getString(&fbdo, "/servo/servoStatus")) {
      int servoStatus = 76;
      servoStatus = fbdo.intData();
      Serial.print("servoStatus ");
      Serial.println(servoStatus);
      if(servoStatus == 1){
        sg90.write(90);
        delay(1000);
        sg90.write(1);
        Firebase.RTDB.setInt(&fbdo, "/servo/servoStatus", 0);
        Serial.println("Mama verildi");
      }
    }
    else {
      Serial.println("servoStatus elseye girdi hata: " + fbdo.errorReason());
    }
    
    delay(3000);
  }
}
