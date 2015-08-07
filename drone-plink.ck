Gain master => dac;

Impulse imp =>
Gain g =>
ResonZ f =>
Dyno d =>
Pan2 p =>
JCRev rev =>
TwoPole tp =>
master;

SawOsc s[3] =>
Gain sg[3] =>
ResonZ f2 =>
Chorus c =>
NRev nr =>
Gain droneGain =>
master;

Shakers sha => master;
8 => sha.preset;

VoicForm singer => NRev singerRev => master;
0.5 => singer.unVoiced;
0.1 => singer.voiced;
0.3 => singerRev.mix;

0.33 => sg[0].gain => sg[1].gain => sg[2].gain;
24 => int root;

SinOsc sine => blackhole;
6.0 => sine.freq;
50 => f2.freq;
0.05 => nr.mix;
2 => s[0].sync;
2 => s[1].sync;
2 => s[2].sync;
sine => s[0];
sine => s[1];
sine => s[2];
3 => sine.gain;

d.limit();
0.2 => rev.mix;

0.9 => droneGain.gain;
0.3 => g.gain;
0.3 => singer.gain;

fun void setRoot(int root) {
	Std.mtof(root) => s[0].freq;
	Std.mtof(root + 3) => s[1].freq;
	Std.mtof(root + 7) => s[2].freq;
}

fun int rnd(int from, int to) {
	return Math.random2(from, to);
}

fun float rndf(float from, float to) {
	return Math.random2f(from, to);
}

fun int prob(int percent) {
	return rnd(1, 100) > percent;
}

fun void fadeout() {
	master.gain() => float gain;
	while (gain > 0) {
		gain * 0.9 => gain;
		gain => master.gain;
		50::ms => now;
	}
}

float ff;
int n;

3::minute => dur shredDuration;
now => time shredStarted;

fun int shredPlaying() {
	return now < shredStarted + shredDuration;
}

while (shredPlaying()) {
	if (prob(70)) {
		rnd(36, 60) => n;
		setRoot(n);
		//rnd(600, 3600) => f2.freq;
		//rnd(50, 600) => f2.Q;
		rnd(-1, 2) => int oct;
		Std.mtof(n + oct * 12) => singer.freq;
	}
	
	if (prob(50)) {
		rnd(0, 22) => sha.preset;
		rndf(0, 1) => sha.energy;
		rndf(0.8, 1.0) => sha.decay;
		rndf(80, 200) => sha.freq;
	}
	
	rnd(0, 128) => singer.phonemeNum;
	
	rndf(200, 3000) => ff;
	ff/1.5 => tp.freq;
	ff => f.freq;
	rndf(70, 1000) => f.Q;
	rndf(-0.8, 0.8) => p.pan;
	if (prob(30)) {
		rnd(50, 600) => imp.next;
	}
	rnd(60, 900)::ms => now;
}

fadeout();