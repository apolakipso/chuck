// Master
Gain master => 
dac;

// Chord
SawOsc o[4] => Gain og[4];
ADSR env => 
ResonZ f => 
Pan2 p => 
Chorus c => 
PRCRev r =>
master;

// Bass
FMVoices bass =>
ADSR bassEnv =>
ResonZ bassFilter =>
master;

// Drums
Gain drums =>
LPF drumFilter =>
Dyno compressor =>
master;



// Chord setup
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
(10::ms, 70::ms, 0.0, 120::ms) => env.set;
0.7 => master.gain;
0 => og[0].gain;
1 => og[1].gain;
0.2 => c.modDepth;
0.3 => c.mix;
0.05 => r.mix;

// Bass setup
0.6 => bass.gain;

// Drums setup
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
10000 => drumFilter.freq;
0.9 => drums.gain;
0.7 => kick.gain;
0.5 => clap.gain;
0.4 => ch.gain;
0.2 => oh.gain;
0.3 => crash.gain;
compressor.limit();


// Timing setup
0 => int beat;
124.0 => float bpm;
172 => bpm;
(60/bpm * 4 * 1000) / 16 => float stepDuration;
0.55 => float swing;
float d;


// Scale setup
[1, 3, 5] @=> int triad[];
[1, 3, 5, 7] @=> int seventh[];
[triad, seventh] @=> int chordTypes[][];
[0, 2, 4, 5, 7, 9, 11] @=> int major[];
[0, 2, 3, 5, 7, 8, 10] @=> int minor[];

minor @=> int scale[];
float chord[];

// start on the root
0 => int currentStep;

// Pattern setup
[1,0,0,1,0,0,1,0,1,0,0,1,0,0,1,0] @=> int ptrChord[];
[1,0,1,1,0,0,1,0,1,0,0,1,0,1,1,0] @=> int ptrBass[];
[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0] @=> int ptrKick[];
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0] @=> int ptrClap[];
[1,0,1,0,1,0,1,0,1,0,1,0,1,1,0,1] @=> int ptrCH[];
[0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0] @=> int ptrOH[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int ptrCrash[];

if (bpm > 140) {
	[1,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0] @=> ptrKick;
	[0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0] @=> ptrClap;
	[0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0] @=> ptrOH;
}

fun void n(dur d) {
	d => now;
}

fun void loadSound(SndBuf b, string s) {
	b => drums;
	me.dir() + "/audio/" + s + ".wav" => b.read;
	b.samples() => b.pos;
}

fun void playSound(SndBuf s) {
	0 => s.pos;
	n(s.samples()::samp);
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

fun int playStep(int pattern[], int beat, int probability) {
	return (pattern[beat % pattern.cap()] == 1) || prob(probability);
}

while (true) {
	if (prob(20)) {
		rnd(500, 9000) => drumFilter.freq;
		//rndf(0.4, 1.0) => drumFilter.Q;
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
	
	if (playStep(ptrKick, beat, 1)) spork ~ playSound(kick);
	if (playStep(ptrClap, beat, 5)) spork ~ playSound(clap);
	if (playStep(ptrCH, beat, 10)) spork ~ playSound(ch);
	if (playStep(ptrOH, beat, 0)) spork ~ playSound(oh);
	if (playStep(ptrCrash, beat, beat % 64 == 0 ? 100 : 0)) spork ~ playSound(crash);
	
	// Drift
	//((rndf(-1, 1) * 0.001) + 1.0) * stepDuration => stepDuration;
	
	// step delay with swing
	((beat % 2 == 0) ? 0.5 + swing : 1.5 - swing) => d;
	n(d * stepDuration::ms);
	1 => env.keyOff;
	1 => bass.noteOff;
	1 => bassEnv.keyOff;
	beat++;
}