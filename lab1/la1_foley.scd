// Starta servern
(
s.boot; // en rad kod körs med <Shift> och <Enter>
// Start oscilloscope
s.scope;

)
// Stop server
s.quit;
// Plot tree
s.plotTree;
// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\samplePlayer, { arg bufnum = 0, rate = 1, trigger = 1, startPos = 0, loop = 1, mix=0.33,room=0.5,damp=0.5, freq=440, rq=0.9 ;
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
	var envelope1 = EnvGen.kr(Env.perc(attackTime: 4, releaseTime: 20,
level: 1.0, curve: -4.0));
	var envelope2 = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 0.1,
level: 1.0, curve: -4.0).range(100,10000));
	var output = RLPF.ar(reverb,freq:freq, rq:rq) * envelope1 ;

	Out.ar(0, [output,output]);
}).add;

)
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/playboi.mp3");

x = Synth.new(\samplePlayer, [\bufnum, soundSample]);

)
x.set(\freq,4000);
x.set(\rq,0.9);
x.set(\rate,0.5);
x.set(\rate,2);
x.set(\rate,10);
x.set(\rate,0.1);
/* Experimentera med olika faktorer, till exempel 0.5, 2, 10, 0.1. Hur låter det, och varför?
-- Svar: Tempot som ljudet spelas i samt frekvensen på ljudet ändras.
--------------------------------------------------------------------------------*/
/*
Hur låter det? Testa olika brytfrekvenser, hur påverkar det ljudet?
- Svar: Skär ut alla frekvenser över vald, så låga värden ger mycket bas.

Hur låter det? Testa olika brytfrekvenser, hur påverkar det ljudet?
- Svar: Skär ut alla frekvenser under vald, så höga värden ger ingen bas.

Testa att använda ett resonant filter och förändra värdet på rq. Hur låter det?
- Svar: Detta förstärker den valda frekvensen, där variationer i rq pendlar hur mycket den blir förstärkt eller blandad med de andra kanalerna.

Testa att använda ett bandpassfilter och förändra brytfrekvensen. Experimentera också med
andra värden på rq. Hur låter det, och hur ser frekvensanalysen ut?
- Svar: Den verkar isolera kring den valda frekvensen


Hur låter det? Hörs det att envelopen påverkar ljudets volymmässiga kontur?
- Svar: Ja! Volymen sjunker sakt men säkert, eller snabbare beroende

*/

{ LPF.ar(Saw.ar(200,0.1), SinOsc.kr(XLine.kr(0.7,300,20),0,3600,4000)) }.play;
​
// kr:
(
{ var ctl = LPF.kr(LFPulse.kr(8), SinOsc.kr(XLine.kr(1, 30, 5)) + 2);
    SinOsc.ar(ctl * 200 + 400)
}.play;
)
​
(
{ var ctl = LPF.kr(SinOsc.kr(),440);
    SinOsc.ar(ctl)
}.play;
)





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