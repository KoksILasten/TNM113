// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;
s.plotTree;
// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

SynthDef(\samplePlayer, { arg bufnum = 0, rate = 1.0, freq = 20000, channels=2, rq=1.0, loop=0;
    var sound = PlayBuf.ar(
		numChannels: channels,
		bufnum: bufnum,
		rate: rate,
		trigger: 1,
		startPos: 0,
		loop: loop,
		doneAction: 2,
	);

	//var envelope2 = EnvGen.kr(Env.perc(attackTime: 0.01, releaseTime: 0.1, level: 1.0, curve: -4.0).range(1000,10000));

	var filtered = RLPF.ar(sound, freq: freq, rq: rq);
	var envelope = EnvGen.kr(
		Env.perc(0.01, 0.1, 1, 4));
	var output = filtered * envelope;

	Out.ar(0, [output, output]);
}).add;

(
// Steam wand sound
SynthDef(\steamWand, { |out=0, rate=1, amp=0.5, pan=0|
    var sound, env;
    sound = PinkNoise.ar() * LFNoise1.kr(10).range(0.5, 1.0);
    sound = BPF.ar(sound, LFNoise1.kr(0.3).range(1000, 3000), 0.1);
    sound = Pan2.ar(sound, pan);
    env = EnvGen.kr(Env.linen(0.5, 2, 1), doneAction:2);
    Out.ar(out, sound * env * amp * rate);
}).add;

// Machine hum/buzz
SynthDef(\machineHum, { |out=0, amp=0.3, pan=0|
    var sound, env;
    sound = SinOsc.ar([50, 50.5], 0, amp) * LFNoise1.kr(0.5).range(0.7, 1.0);
    sound = sound + (BPF.ar(PinkNoise.ar(0.1), 1200, 0.1) * 0.3);
    sound = Pan2.ar(sound, pan);
    Out.ar(out, sound);
}).add;
)
)

(
fork({
var playboi = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/playboi.mp3");
c = Synth.new(\samplePlayer, [\bufnum, playboi]);
c.set(\rate, [1].choose);
c.set(\freq, 20000);
c.set(\rq, 1.0);
c.set(\loop, 0);
});
0.15.wait;
)

(
EnvGen.kr(
	Env.perc(attackTime: 0.01, releaseTime: 0.5, level: 0.2, curve: -4.0);
);
)


// Klientside skript
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

var coffeeStrength = 2;

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

~coffeeSelector = { |repeats=1, pling=true|
    Routine({
        repeats.do { |i|
			a = Synth.new(\samplePlayer, [\bufnum, clickSound, \channels, 1]);
			a.set(\freq, 550);
            0.3.wait; // wait between repetitions
        };
		if(pling == true, {
			0.5.wait;
		repeats.do { |i|
				{ Saw.ar(150 * (i+1), 0.1) * EnvGen.ar(Env.perc(0.05, 0.2, 0.8, -4), doneAction:2) ! 2}.play;
			0.12.wait; // wait between repetitions
        };
		}, {});
    }).play;
};

~coffeeMaker = { |coffeeStg=1|
	fork({
		2.wait;
		{var noise = PinkNoise.ar();
			var noiseFilter = LPF.ar(noise, freq: 800);
			noiseFilter ! 2 * 0.2;
		}.play;
		k = Synth.new(\machineHum, [\amp, 0.3, \out
		l = Synth(\steamWand, [\amp, 0.7, \rate, 1.5]);
	b = Synth.new(\samplePlayer, [\bufnum, clickholdSound, \channels, 1]);
		0.3.wait;
	d = Synth.new(\samplePlayer,[\bufnum, rattleSound, \channels, 1]);
	d.set(\rate, 0.3);
	d.set(\rq, 0.2);
		c = Synth.new(\samplePlayer, [\bufnum,grusSound , \channels, 1]);
	c.set(\rate, 0.3);
		e = Synth.new(\samplePlayer, [\bufnum, plingSound, \channels, 1]);
	e.set(\rate, 3);
		e.set(\freq, 440);

		3.0.wait;
		d.free;
		c.free;
		e.free;

		//f = Synth.new(\riser);
		h = Synth.new(\samplePlayer, [\bufnum, stoneScrapeSound, \channels, 1]); //chicken
		h.set(\rate, 2);
		h.set(\loop,1);
		h.set(\rq, 0.3);
		g = Synth.new(\samplePlayer, [\bufnum, rawrSound, \channels, 1]);
		g.set(\rate, 0.2);
		g.set(\freq, 600);
		i = Synth.new(\samplePlayer, [\bufnum, stoneRollSound, \channels, 1]);
		i.set(\rate, 2);
		j = Synth.new(\samplePlayer, [\bufnum, waterSound, \channels, 2]);


		10.wait;

		j.free;


	});
};

~coffeeSelector.(coffeeStrength, true);
~coffeeMaker.(2);
)

