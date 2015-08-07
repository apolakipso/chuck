SinOsc f1 => dac;
SinOsc f2 => dac;

0.5 => f1.gain;
0.5 => f2.gain;

220 => f1.freq;
440 => f2.freq;

while (true) {
    //440 * f2.freq() => f1.freq;
    300::ms => now;
}