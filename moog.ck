SqrOsc o => blackhole;
Moog f => ADSR e => dac;
(0::ms, 100::ms, 0.1, 300::ms) => e.set;
55 => f.freq;
55 => float ff;
ff => o.freq;

while (true) {
	//Math.random2f(0, 0.9) => f.filterQ;
	Math.random2f(0, 1) => f.filterSweepRate;
	Math.random2(0,1) == 1 ? 55.0 : 55*1.5 => float ff;
	ff => f.freq;
	1 => e.keyOn;
	1 => f.noteOn;
	100::ms => now;
	1 => e.keyOff;
	1 => f.noteOff;
	100::ms => now;
}