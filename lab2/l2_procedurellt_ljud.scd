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
	body = body * EnvGen.ar(Env.perc(0,releaseTime:0.1, level:1, curve:-4), t_trig, doneAction:2); // doneAction resleases synth when env is done.

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
SynthDef(\clHiHat, { arg t_trig;

}).play;
)

// OpHiHat
(
SynthDef(\opHiHat, { arg t_trig;

}).add;
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

// Cowbell
(
SynthDef(\cowBell, { arg t_trig;

}).add;
)

// Crash
(
SynthDef(\crash, { arg t_trig;

}).add;
)