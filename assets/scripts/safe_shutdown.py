import RPi.GPIO as GPIO  # import our GPIO module
import time
from subprocess import call

GPIO.setmode(GPIO.BCM)  # we are using BCM pin numbering

# Turn car amps on
OUT_1 = 22
GPIO.setup(OUT_1, GPIO.OUT, initial=GPIO.LOW)
GPIO.output(OUT_1, GPIO.HIGH)

IGN_PIN = 12        # our 12V switched pin is BCM12
EN_POWER_PIN = 25   # our latch pin is BCM25
IGN_LOW_TIME = 20   # time (s) before a shutdown is initiated after power loss

GPIO.setup(IGN_PIN, GPIO.IN)                          # set our 12V switched pin as an input
GPIO.setup(EN_POWER_PIN, GPIO.OUT, initial=GPIO.HIGH) # set our latch as an output
GPIO.output(EN_POWER_PIN, 1)                          # latch our power. We are now in charge of switching power off

ignLowCounter = 0

try:
    while True:
        if GPIO.input(IGN_PIN) != 1:   # if our 12V switched is not enabled
            if ignLowCounter == 0:     # Notify flutter if the ign has gone low but previously was not
                print("IGN LOW")
            time.sleep(1)              # wait a second
            ignLowCounter += 1         # increment our counter
            if ignLowCounter == IGN_LOW_TIME:  # if it has been switched off for >10s
                print("IGN OFF")
        else:
            if ignLowCounter != 0:     # If IGN is switched back on but was not previously on
                print("IGN HIGH")

            ignLowCounter = 0          # reset our counter, 12V switched is HIGH again

        time.sleep(0.1)  # small delay to reduce CPU usage
except KeyboardInterrupt:
    pass
finally:
    GPIO.cleanup()
