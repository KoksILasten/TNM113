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
SynthDef(\samplePlayer2, { arg bufnum=0,rate=1,freq=20000,channels=2,rq=1.0,loop=0;
	var sound = PlayBuf.ar(
		numChannels: channels,
		bufnum: bufnum,
		rate: BufRateScale.kr(bufnum),
		trigger: 1,
		startPos: 0,
		loop: 0,
		doneAction: 2,
	);
	var filtered = RLPF.ar(sound, freq: freq, rq: rq);
    var envelope = EnvGen.kr(Env.perc(0.01, 0.1, 1, -4),doneAction: 0);
	var output = sound * envelope;

	Out.ar(0, output ! 2);
}).add;
)
(
SynthDef(\samplePlayer, { arg bufnum = 0,rate=1,freq=20000,channels=2,rq=1.0,loop=0;
    var sound = PlayBuf.ar(
		numChannels: 2,
		bufnum: bufnum,
		rate: rate,
		trigger: 1,
		startPos: 0,
		loop: loop,
		doneAction: 0,
	);

	var filtered = RLPF.ar(sound, freq: freq, rq: rq);
    var envelope = EnvGen.kr(Env.perc(0.01, 0.1, 1, -4),doneAction: 0);
	var output = filtered;

	Out.ar(0, output ! 2);
}).add;

SynthDef(\steamWand, { |out=0, rate=1, amp=0.5, pan=0|
    var sound, env;
    sound = PinkNoise.ar() * LFNoise1.kr(10).range(0.5, 1.0);
    sound = BPF.ar(sound, LFNoise1.kr(0.3).range(1000, 3000), 0.1);
    sound = Pan2.ar(sound, pan);
    env = EnvGen.kr(Env.linen(0.5, 2, 1), doneAction:2);
    Out.ar(out, sound * env * amp * rate);
}).add;

SynthDef(\machineHum, { |out=0, amp=0.3, pan=0|
    var sound, env;
    sound = SinOsc.ar([50, 50.5], 0, amp) * LFNoise1.kr(0.5).range(0.7, 1.0);
    sound = sound + (BPF.ar(PinkNoise.ar(0.1), 1200, 0.1) * 0.3);
    sound = Pan2.ar(sound, pan);
    Out.ar(out, sound);
}).add;
)

(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var soundSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/playboi.mp3");

x = Synth.new(\samplePlayer, [\bufnum, soundSample]);

)
(
x.set(\freq,4000);
x.set(\rq,0.9);
x.set(\rate,0.5);
x.set(\rate,2);
x.set(\rate,10);
x.set(\rate,0.1);
)
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


(
fork({
var playboi = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/playboi.mp3");
c = Synth.new(\samplePlayer, [\bufnum, playboi]);
c.set(\rate, 1);
c.set(\freq, 20000);
c.set(\rq, 1.0);
c.set(\loop, 0);
});
)

(
EnvGen.kr(
	Env.perc(attackTime: 0.01, releaseTime: 0.5, level: 0.2, curve: -4.0);
);
)


// Klientside skript
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var coffeeStrength = 3;

var clickSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Reflex-click-02.wav");
var clickholdSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Reflex-click-03.wav");
var rattleSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Dvitamin.wav");
var acSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Ac2.wav");
var plingSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Pling.wav");
var grusSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Grus2.wav");
var eSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/playboi_eeee.wav");
var rawrSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Audacity_Isolated_Clips/Rarrwv.wav");
var stoneScrapeSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Sten6.wav");
var stoneRollSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/Stenvagga.wav");
var waterSound = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sfx/VattenRinna2.wav");


//postln(thisProcess.nowExecutingPath.dirname);

~coffeeSelector = { |repeats=1, pling=true|
    Routine({
        repeats.do { |i|
            a = Synth.new(\samplePlayer, [\bufnum, clickSound, \channels, 1]);
            a.set(\freq, 550);
            0.3.wait;
        };

        // Modified boolean test
        if(pling, { // Removed explicit == true comparison
            0.5.wait;
            repeats.do { |i|
                { Saw.ar(150 * (i+1), 0.1) *
                  EnvGen.ar(Env.perc(0.05, 0.2, 0.8, -4), doneAction:2) ! 2
                }.play;
                0.12.wait;
            };
        });
    }).play;
};

~coffeeMaker = { |coffeeStg=1|
	fork({
		s.sync;
		3.0.wait;
		{var noise = PinkNoise.ar();
			var noiseFilter = LPF.ar(noise, freq: 800);
			noiseFilter ! 2 * 0.5;
		}.play;

		k = Synth.new(\machineHum, [\amp, 0.15]);
		b = Synth.new(\samplePlayer, [\bufnum, clickholdSound, \channels, 1]);
		0.3.wait;
		d = Synth.new(\samplePlayer,[\bufnum, rattleSound, \channels, 1]);
		d.set(\rate, 0.3);
		d.set(\rq, 0.2);
		0.2.wait;
		c = Synth.new(\samplePlayer, [\bufnum,grusSound , \channels, 1]);
		c.set(\rate, 0.3);
		e = Synth.new(\samplePlayer, [\bufnum, plingSound, \channels, 1]);
		e.set(\rate, 3);
		e.set(\freq, 440);
		h = Synth.new(\samplePlayer, [\bufnum, stoneScrapeSound, \channels, 1]); //chicken
		h.set(\rate, 0.5);
		h.set(\loop,1);
		h.set(\rq, 0.3);

		3.0.wait;
		d.free;
		c.free;
		e.free;
		h.free;

		//f = Synth.new(\riser);
		g = Synth.new(\samplePlayer, [\bufnum, rawrSound, \channels, 1]);
		g.set(\rate, 0.2);
		g.set(\freq, 600);
		i = Synth.new(\samplePlayer, [\bufnum, stoneRollSound, \channels, 1]);
		i.set(\rate, 2);
		0.5.wait;
		j = Synth.new(\samplePlayer, [\bufnum, waterSound, \channels, 2]);
		m = Synth.new(\samplePlayer, [\bufnum, eSound, \channels, 2]);
		m.set(\rate, 0.2);
		m.set(\rq, 0.2);
		m.set(\freq, 440);
		0.3.wait;
		l = Synth(\steamWand, [\amp, 0.5, \rate, 2]);


		10.wait;

		s.freeAll;


	});
};
~coffeeSelector.(coffeeStrength, true);
~coffeeMaker.(coffeeStrength);

)

