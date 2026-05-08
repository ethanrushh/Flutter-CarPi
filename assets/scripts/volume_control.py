from gpiozero import RotaryEncoder, Button
from signal import pause
import subprocess
import time
import sys
import threading

# --- Configuration ---
VOLUME_STEP = 2       # Percent per tick
VOLUME_STEP_MFW = 4 # Volume step from multi-function steering wheel controls (controlled from the other end)
MIN_VOLUME = 0
MAX_VOLUME = 100
DEBOUNCE_TIME = 0.25  # 250ms debounce for encoder and button

# --- GPIO Pins ---
ENCODER_CLK = 15
ENCODER_DT = 5
BUTTON_PIN = 6

# --- Global state ---
current_volume = 50
last_position = 0
last_rotated_time = 0
last_button_time = 0

# --- Initialize GPIO devices ---
encoder = RotaryEncoder(a=ENCODER_CLK, b=ENCODER_DT, max_steps=0)
button = Button(BUTTON_PIN)

# --- Helper functions ---
def get_volume():
    """Read current system volume (integer %)."""
    result = subprocess.run(
        ["amixer", "get", "Master"],
        stdout=subprocess.PIPE,
        text=True
    )
    for line in result.stdout.splitlines():
        if "%" in line:
            left = line.split("[")[1].split("%")[0]
            return int(left)
    return 0

def set_volume(volume):
    """Clamp and set system volume."""
    volume = max(MIN_VOLUME, min(MAX_VOLUME, volume))
    subprocess.run(["amixer", "set", "Master", f"{volume}%"], stdout=subprocess.DEVNULL)

def rotated():
    """Handle rotation events from the encoder."""
    global current_volume, last_position, last_rotated_time

    now = time.time()
#    if now - last_rotated_time < DEBOUNCE_TIME:
#        return  # ignore ticks too close together
    last_rotated_time = now

    position = encoder.steps
    if position > last_position:
        current_volume += VOLUME_STEP
    elif position < last_position:
        current_volume -= VOLUME_STEP

    last_position = position

    current_volume = max(MIN_VOLUME, min(MAX_VOLUME, current_volume))
    set_volume(current_volume)
    print(current_volume)

def pressed():
    """Toggle mute on button press."""
    global last_button_time
    now = time.time()
    if now - last_button_time < DEBOUNCE_TIME:
        return
    last_button_time = now

    subprocess.run(["amixer", "set", "Master", "toggle"], stdout=subprocess.DEVNULL)

    # Print if we're muted or not
    result = subprocess.run(["amixer", "get", "Master"], capture_output=True, text=True)
    if "[off]" in result.stdout:
        print("M")
    else:
        print("U")


def handle_input(line: str):
    """Process commands from C#."""
    parts = line.strip().split()

#    print(parts)

    if not parts:
        return
    cmd, *args = parts

#    print(cmd)

    if cmd == "mfw_inst" and args:
        handle_mfw(args[0] == "True")

def handle_mfw(up: bool):
#    print("Handling MFW: " + up)
    """Handle multi-function wheel instruction."""
    global current_volume
#    print(f"MFW {'enabled' if enabled else 'disabled'}")

    # Example logic: adjust volume by VOLUME_STEP_MFW
    if up:
        current_volume += VOLUME_STEP_MFW
    else:
        current_volume -= VOLUME_STEP_MFW

    current_volume = max(MIN_VOLUME, min(MAX_VOLUME, current_volume))
    set_volume(current_volume)
    print(current_volume)

def stdin_reader():
    for line in sys.stdin:
#        print("got a line")
        handle_input(line)

# Start reading stdin in a background thread
threading.Thread(target=stdin_reader, daemon=True).start()

# --- Initialize state ---
current_volume = get_volume()
last_position = encoder.steps

encoder.when_rotated = rotated
button.when_pressed = pressed

# Set initial volume to 10% on startup
current_volume = 10
set_volume(current_volume)

#print("Sanity check")

pause()
