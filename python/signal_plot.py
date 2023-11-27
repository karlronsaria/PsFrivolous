import numpy as np
import matplotlib.pyplot as plot
import sys

period = 64
amplitude = 255
time = np.arange(0, 2 * period, 0.1)

def get_signal(rng, period, offset = 0):
    # S(x) = (1/2)A (1 + cos( (2x/P + k) π ))
    return (amplitude/2.0) * (1 + np.cos(np.pi * (2 * rng / period + offset)))

curves = [
    { "color": "red",   "offset": 0 },
    { "color": "green", "offset": 2/3.0 },
    { "color": "blue",  "offset": 4/3.0 }
]

for curve in curves:
    plot.plot(
        time,
        get_signal(rng=time, period=period, offset=curve["offset"]),
        curve["color"]
    )

plot.title('Color Wheel')
plot.xlabel('Time')
plot.ylabel('Aplitude')
plot.grid(True, which='both')

if "--show" in sys.argv:
    plot.show()
    sys.exit()

if "--save" in sys.argv:
    import datetime
    dt = datetime.datetime.now().strftime('%Y_%m_%d_%H%M%S')

    plot.savefig(
        f'plot_{dt}.png',
        format='png',
        transparent=('--trans' in sys.argv)
    )

    sys.exit()

plot.show()
