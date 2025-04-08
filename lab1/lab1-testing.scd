// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\samplePlayer, { arg bufnum = 0;
    var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: 1,
		startPos: 0,
		loop: 0,
		doneAction: 0,
	);

	var output = sound;

	Out.ar(0, output);
}).add;

)
s.plotTree;
(
x = {
	var sig, env;
	env = Line.kr(1,0,1,doneAction:2);
	sig = Pulse.ar(ExpRand(30,500))*env;
}.play;

)
s.freeAll;

// Klientside skript
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/BestickSlapp.wav");
var env = XLine.kr(1.0, 2.0, 1.0, doneAction:2);
soundSample=soundSample*env;
Synth.new(\samplePlayer, [\bufnum, soundSample]);

)
(
Env.new.plot;
)
//----------------------------------------------------
(
var sig, f, env;
env = XLine.kr(1.0, 0.01, 1.0, doneAction:2);
env.plot;
f = SoundFile(thisProcess.nowExecutingPath.dirname++"/sfx/BestickSlapp.wav",doneAction:0);
sig = Pulse.ar(f)*env;
postln(f.numChannels);
postln(f.sampleRate);
f.play*env;
//f.seek(offset: 20, origin: 0).play;
)

(
SynthDef.new(\millie,{
	arg songStart=44100*3, playRate=1, pitchRatio=1.0;

	//Read in an audiofile, for the server s, path, for channel 0(first channel)
	b = Buffer.readChannel(s, "D:/Repos/TNM113-Labs/lab1/playboi.mp3",channels:[0]);

	a =  (PlayBuf.ar(1, b, startPos:songStart, , rate:playRate, doneAction:2) * 0.1).dup;

	//a = PitchShift.ar(a,pitchRatio:pitchRatio, timeDispersion:0.1);

	Out.ar(0,a);

}).add;
)
(
SynthDef.new(\sfxTest,{
	arg songStart = 0, playRate = 1;
	var wowies = 0;

	b = Buffer.readChannel(s,thisProcess.nowExecutingPath.dirname++"/sfx/BestickSlapp.wav", channels:[0]);


Out.ar(0,b);
}).add;
)
x= Synth.new(\sfxTest);

x.set(\songStart,44100*4);
x.set(\playRate,10);
x.set(\pitchRatio,1);

b.numFrames;
x=b.numFrames;

//Start of lab1





