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




// Klientside skript
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/BestickSlapp.wav");
var env = XLine.kr(1.0, 2.0, 1.0, doneAction:2);
soundSample=soundSample*env;
Synth.new(\samplePlayer, [\bufnum, soundSample]);

)

//----------------------------------------------------
(
var f, env;
env = XLine.kr(1.0, 2.0, 1.0, doneAction:2);
f = SoundFile(thisProcess.nowExecutingPath.dirname++"/sfx/BestickSlapp.wav")*env;
postln(f.numChannels);
postln(f.sampleRate);

f.play;
//f.seek(offset: 20, origin: 0).play;
)

(
SynthDef.new(\millie,{
	arg songStart=44100*3, playRate=1, pitchRatio=1.0;

	//Read in an audiofile, for the server s, path, for channel 0(first channel)
	b = Buffer.readChannel(s, "D:/Repos/TNM113-Labs/lab1/playboi.mp3",channels:[0]);

	a =  (PlayBuf.ar(1, b, startPos:songStart, loop: 1, rate:playRate) * 0.1).dup;

	a = PitchShift.ar(a,pitchRatio:pitchRatio, timeDispersion:0.1);

	Out.ar(0,a);

}).add;
)
(
SynthDef.new(\sfxTest,{
	arg songStart = 0, playRate = 1;
	var wowies = 0;

	b = Buffer.readChannel(s,"D:/Repos/TNM113-Labs/sfx/Hissknapp.aac", channels:[0]);



});
)
x= Synth.new(\millie);

x.set(\songStart,44100*4);
x.set(\playRate,0.5);
x.set(\pitchRatio,1);

b.numFrames;
x=b.numFrames;



