// audio chain
SawOsc o[4] => Gain og[4];

ADSR env => 
ResonZ f => 
Pan2 p => 
Chorus c => 
PRCRev r => 
Gain master => 
dac;

FMVoices bass => ADSR bassEnv => ResonZ bassFilter => master;

Gain drums => LPF drumFilter => Dyno compressor => master;
SndBuf kick;
SndBuf clap;
SndBuf ch;
SndBuf oh;
SndBuf crash;

loadSound(kick, "kick");
loadSound(clap, "snare");
loadSound(ch, "hihat-closed");
loadSound(oh, "hihat-open");
loadSound(crash, "crash");

o[0] => og[0];
o[1] => og[1];
o[2] => og[2];
o[3] => og[3];
og[0] => env;
og[1] => env;
og[2] => env;
og[3] => env;
2 => o[0].sync;
2 => o[1].sync;
2 => o[2].sync;
2 => o[3].sync;

// audio setup
(10::ms, 70::ms, 0.0, 120::ms) => env.set;
0.7 => master.gain;
0 => og[0].gain;
1 => og[1].gain;

0.9 => drums.gain;
0.7 => kick.gain;
0.5 => clap.gain;
0.4 => ch.gain;
0.2 => oh.gain;
0.3 => crash.gain;
compressor.limit();

0.6 => bass.gain;

// Chorus
0.2 => c.modDepth;
0.3 => c.mix;

// Reverb
0.05 => r.mix;

0 => int beat;
// start on the root:
0 => int currentStep;

float chord[];

[1, 3, 5] @=> int triad[];
[1, 3, 5, 7] @=> int seventh[];
[triad, seventh] @=> int chordTypes[][];

[0, 2, 4, 5, 7, 9, 11] @=> int major[];
[0, 2, 3, 5, 7, 8, 10] @=> int minor[];


[1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0] @=> int ptrChord[];
[1,0,1,1,0,0,1,0,1,0,0,1,0,1,1,0] @=> int ptrBass[];
[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0] @=> int ptrKick[];
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0] @=> int ptrClap[];
[1,0,1,0,1,0,1,0,1,0,1,0,1,1,0,1] @=> int ptrCH[];
[0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0] @=> int ptrOH[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int ptrCrash[];

minor @=> int scale[];
124.0 => float bpm;
(60/bpm * 4 * 1000) / 16 => float stepDuration;
0.55 => float swing;
float d;

if (bpm > 140) {
	[1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0] @=> ptrKick;
	[0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0] @=> ptrClap;
	[0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0] @=> ptrOH;
}


fun void loadSound(SndBuf b, string s) {
	b => drums;
	me.dir() + "/audio/" + s + ".wav" => b.read;
	b.samples() => b.pos;
}

fun int getScaleStep(int step, int scale[]) {
	return step % scale.cap();
}

fun int[] getChord(int root, int step, int scale[], int steps[]) {
	int r[steps.cap()];
	for (0 => int i; i < steps.cap(); i++) {
		root + scale[getScaleStep(step + steps[i] - 1, scale)] => r[i];
	}
	return r;
}

fun float[] getChordFreq(int chord[]) {
	float r[chord.cap()];
	for (0 => int i; i < chord.cap(); i++) {
		Std.mtof(chord[i]) => r[i];
	}
	return r;
}

fun void setGain(Gain g[], float gain) {
	for (0 => int i; i < g.cap(); i++) {
		gain => g[i].gain;
	}
}

fun void setChordFreq(SawOsc o[], float chord[]) {
	for (0 => int i; i < Math.min(o.cap(), chord.cap()); i++) {
		chord[i] => o[i].freq;
	}
}

fun int rnd(int from, int to) {
	return Math.random2(from, to);
}

fun float rndf(float from, float to) {
	return Math.random2f(from, to);
}

fun int rndx(int cap) {
	return rnd(0, cap - 1);
}

fun void triggerChord(int currentStep) {
	getChordFreq(
		getChord(
			48,
			currentStep,
			major,
			chordTypes[rndx(chordTypes.cap())]
		)
	) @=> chord;
	setChordFreq(o, chord);
	rndf(0, 1000) => float ff;
	100 + ff => f.freq;
	0.05 + 0.25 - 0.25 * (ff/1000) => r.mix;
	rndf(-1, 1) => p.pan;
	setGain(og, 0.3);
	
	for (chord.cap() => int i; i < o.cap(); i++) {
		0 => og[i].gain;
	}
	
	1 => env.keyOn;
}

fun int prob(int percent) {
	return rnd(1, 100) <= percent;
}

fun void trigger(SndBuf s) {
	0 => s.pos;
}

fun void playStep(SndBuf s, int pattern[], int beat, int probability) {
	if (
		(pattern[beat % pattern.cap()] == 1) || 
		prob(probability)
	) {
		trigger(s);
	}
}


while (true) {
	if (prob(20)) {
		rnd(200, 9000) => drumFilter.freq;
		rndf(0.4, 1.0) => drumFilter.Q;
	}
	if (ptrChord[beat % ptrChord.cap()] == 1) {
		if (prob(70)) {
			rnd(1, 7) => currentStep;
		}
		triggerChord(currentStep);
	}
	if (ptrBass[beat % ptrBass.cap()] == 1) {
		o[ prob(20) ? 1 : prob(30) ? 2 : 0 ].freq() / 2 => bass.freq;
		rndf(0.8, 1) => bass.vowel;
		o[0].freq() => bassFilter.freq;
		rndf(0.5, 0.9) => bassFilter.Q;
		1 => bass.noteOn;
		1 => bassEnv.keyOn;
	}
	
	playStep(kick, ptrKick, beat, 1);
	playStep(clap, ptrClap, beat, 5);
	playStep(ch, ptrCH, beat, 10);
	playStep(oh, ptrOH, beat, 0);
	playStep(crash, ptrCrash, beat, beat % 64 == 0 ? 100 : 0);
	
	// Drift
	//((rndf(-1, 1) * 0.001) + 1.0) * stepDuration => stepDuration;
	
	// step delay with swing
	((beat % 2 == 0) ? 0.5 + swing : 1.5 - swing) => d;
	d * stepDuration::ms => now;
	1 => env.keyOff;
	1 => bass.noteOff;
	1 => bassEnv.keyOff;
	beat++;
}