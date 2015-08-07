SndBuf s => Chorus c => Pan2 p => GVerb r => dac;

0.1 => c.mix;
60.0 => c.modFreq;
0.6 => c.modDepth;

//0.1 => r.mix;
2::second => r.revtime;
30 => r.roomsize;
0.5 => r.dry;
0.2 => r.early;
0.3 => r.tail;

me.dir() + "/audio/b.wav" => s.read;
s.samples() => int len;

while (true) {
    Math.random2f(0.0, 0.9) => s.gain;
    Math.random2f(.25, 2.0) => s.rate;
    Math.random2f(-1.0, 1.0) => p.pan;
	Math.random2(0, len) => s.pos;
    Math.random2(20, 800)::ms => now;
}
