// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;
s.plotTree;

// När servern är igång skickar man över en eller flera synth definitioner till serven.
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

// Bass drum
(
SynthDef(\bassDrum, { arg t_trig = 1;
	var body, hit, output;
	hit  = LFTri.ar(freq:80); //More muffled
	//hit  = LFSaw.ar(freq:80); //Snappier
	//hit  = PinkNoise.ar(0.5); //Meatier ;)
	hit = hit * EnvGen.ar(Env.perc(0,releaseTime:0.01, level:1.5, curve:-4), t_trig);
	body = SinOsc.ar(freq:60); // provade freq [50, 60, 70, 74, 80, 90] allt förbi 90 börjar låta mer snare typ
	body = body * EnvGen.ar(Env.perc(0,releaseTime:0.1, level:1, curve:-4), t_trig); // doneAction resleases synth when env is done.

	output = (body+hit)*3;
	//output = hit;
	//output = body;
	Out.ar(0, {output}!2);
}).play;

)


// Snare drum
(
SynthDef(\snareDrum, { arg t_trig = 1;

	var body, body1, body2, hit, output, bodyFreq = 130, noise;

	//hit  = LFTri.ar(freq:80); //More muffled
	hit  = LFSaw.ar(freq:30); //Snappier
	//hit  = PinkNoise.ar(0.5); //Meatier ;)

	hit = hit * EnvGen.ar(Env.perc(0,releaseTime:0.01, level:1.5, curve:-4), t_trig);

	body1 = SinOsc.ar(freq:bodyFreq);
	body2 = SinOsc.ar(freq:bodyFreq *1.5);

	body1 = body1 * EnvGen.ar(Env.perc(0,releaseTime:0.1, level:1, curve:-4), t_trig);
	body2 = body2 * EnvGen.ar(Env.perc(0,releaseTime:0.1, level:0.9, curve:-4), t_trig, doneAction:2); // doneAction resleases synth when env is done.

	//noise = PinkNoise.ar();
	noise = WhiteNoise.ar(0.25);
	noise =HPF.ar(noise,freq:750);
	noise = noise * EnvGen.ar(Env.perc(0,releaseTime:0.25, level:0.5, curve:-4), t_trig);


	body = (body1+body2)*0.7;

	output = (noise + body + hit)*3;

	//output = noise;

	Out.ar(0, {output}!2);

}).play;
)

// ClHiHat
(
SynthDef(\clHiHat, { arg t_trig=1;
	var noise = WhiteNoise.ar(0.4);

	var output = noise * EnvGen.ar(Env.perc(0.005 , releaseTime: 0.025, level: 1 , curve:-1), t_trig);
	output = RHPF.ar(output, freq: 1300, rq: 0.6);

	Out.ar(0, {output}!2);

}).play;
)

// OpHiHat
(
SynthDef(\opHiHat, { arg t_trig=1;
	var noise = WhiteNoise.ar(0.4);
	var sq0,sq1,sq2,sq3,output;

	//cymbal
	sq0 = LFSaw.ar(1150, iphase: 0.0 ,mul: 1.0);
	sq1 = LFSaw.ar(820, iphase: 0.0, mul: 1.0);
	sq2 = LFSaw.ar(317, iphase: 0.0,  mul: 1.0);
	sq3 = LFSaw.ar(465, iphase: 0.0,  mul: 1.0);

	sq0 = (sq0 + sq2 + sq1 + sq3) / 4;


	// low filter noise part
	noise = RHPF.ar(noise, 682, rq: 0.9);

	output = (noise + sq0 / 2 ) * EnvGen.ar(Env.perc(0.005 , releaseTime: 0.08, level: 1 , curve:-1), t_trig);
	output = RHPF.ar(output, freq: 1200, rq: 0.8); //high filter

	Out.ar(0, {output}!2);

}).play;
)

// High tom
(
SynthDef(\highTom, { arg t_trig;

}).add;
)

// Low tom
(
SynthDef(\lowTom, { arg t_trig;

}).add;
)

// Woodblock
(
SynthDef(\woodBlock, { arg t_trig;

}).add;
)

(
// Cowbell
SynthDef(\cowBell, { arg t_trig = 1;
	//var trig = Impulse.ar(0);
    var freqs = [1000, 1500, 3500, 5000, 6000]; // Resonant frequencies
    var decays = [0.1, 0.15, 0.20, 0.25, 0.3]; // Decay times for each frequency
    var noise = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.1, curve: -6), t_trig, doneAction: 7) * 0.3;
    var env = EnvGen.ar(Env.perc(0.001, 4.0), t_trig, doneAction:7);

    var resonances = Mix.ar(
        freqs.collect { |freq, i|
            Ringz.ar(Impulse.ar(0), freq, decays[i]) * 0.1});

    var sig = (resonances + noise) * env;
    sig = RHPF.ar(sig, 1000, rq: 0.3);
    Out.ar(0, sig ! 2); // Stereo output
}).play;
)

// Crash
(
SynthDef(\crash, { arg t_trig;
    var body, body1, body2, body3, body4, body5, hit, output, bodyFreq = 800;
	var noise = WhiteNoise.ar() * EnvGen.ar(Env.perc(0.001, 0.1), t_trig) * 0.3;
	var freqs = [488, 691, 977, 1381, 1953, 2762];¨¨

	//Pulse.ar();
	body = LFSaw.ar(freq: 500, mul: 1);
	body1 = LFSaw.ar(freq: 1400, mul: 1);
	body2 = LFSaw.ar(freq: 1000, mul: 1);
	body3 = LFSaw.ar(freq: 4422, mul: 1);
	body4 = LFSaw.ar(freq: 5800, mul: 1);
	body5 = LFSaw.ar(freq: 6500, mul: 1);

	body = Mix(body1, body2, body3, body4, body5, body, PinkNoise.ar());
	body = RHPF.ar(in: body, freq: 500, rq: 0.01);

	body = body * EnvGen.ar(Env.perc(0.001, 0.5, curve: -4));
    output = body;

    Out.ar(0, {output}!2);
}).play;
)