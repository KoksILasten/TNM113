// Starta servern
(
s.boot; // en rad kod körs med <Shift> och <Enter>

s.plotTree;
)
// Stop server
s.quit;
// Start oscilloscope
s.scope;
// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\samplePlayer, { arg bufnum = 0, rate = 1, trigger = 1, startPos = 0, loop = 1, mix=0.33,room=0.5,damp=0.5 ;
    var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: rate,
		trigger: trigger,
		startPos: startPos,
		loop: loop,
		doneAction: 2,
	);
	var reverb = FreeVerb.ar(sound,mix,room,damp);
	var output = reverb;

	Out.ar(0, [output,output]);
}).add;

)
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/bank.wav");

x = Synth.new(\samplePlayer, [\bufnum, soundSample]);

)
x.set(\rate,0.5);
x.set(\rate,2);
x.set(\rate,10);
x.set(\rate,0.1);
/* Experimentera med olika faktorer, till exempel 0.5, 2, 10, 0.1. Hur låter det, och varför?
Svar: Tempot som ljudet spelas i samt frekvensen på ljudet ändras. */


// Klientside skript
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/bank.wav");

x = Synth.new(\samplePlayer, [\bufnum, soundSample]);

)

x.set(\rate,0.8);
x.set(\mix, 0.5);
x.set(\room, 0.9);
x.set(\damp, 0.1);
x.set(\loop, 0);

x.set(\bufnum,0);
x.free;