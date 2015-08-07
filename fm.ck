ADSR env;
Gain g => Pan2 p => GVerb r => Gain master => dac;
ADSR modEnv;
SinOsc mod => env;
env => SinOsc car;
10::second => r.revtime;
90 => r.roomsize;
0.03 => r.tail;
0.01 => r.early;
0.2 => r.dry;
0.9 => r.damping;

car => env => g;
0.3 => g.gain;
440 => mod.freq;
440 => car.freq;
2 => car.sync;
0.6 => master.gain;
/*
VoicForm s => Gain gs => r;
0.3 => gs.gain;
//Math.random2(0, 128) => s.phonemeNum;
//0.3 => s.loudness;
//0.7 => s.voiced;
//0.05 => s.unVoiced;
2220 => s.freq;
100 => s.noteOn;
0.1 => s.voiceMix;
0.05 => s.gain;
*/
(1::ms, 30::ms, 0.0, 120::ms) => env.set;

[1.0/16, 1.0/12, 1.0/8, 1.0/6, 1.0/4, 1.0/3, 1.0/2, 1, 1.5, 2, 5.0/3, 2.5, 3, 3.5, 4] @=> float f[];
while (true) {
	
	220 * f[Math.random2(0, f.cap()-1)] => car.freq;
	f[Math.random2(0, f.cap()-1)] => float ff;
	0.1 + 0.7/8 * (8-ff) => g.gain;
	<<< g.gain() >>>;
	220 * ff => mod.freq;
	Math.random2f(-1, 1) => p.pan;
	Math.random2f(1, 1000) => mod.gain;
	10 => env.keyOn;
	50::ms => now;
	1 => env.keyOff;
	150::ms => now;
	0 => car.gain;
	0 => mod.gain;
}
