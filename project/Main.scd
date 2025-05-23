// =============================================
// Skate 2. Menu sound replacer with controller support
// =============================================
// Boot the server

s.boot;
// Wait for server to boot before continuing
(

SynthDef(\ABPlayer, {
    |bufnum, amp = 0.5, rate = 0.9, lpfcutoff = 20000, decay = 0.3, level = 0 , loop = 0|

    var audio;

    // Play the buffer with modulation
    audio = PlayBuf.ar(2, bufnum, rate, loop: loop);

    // Apply a simple envelope

	audio = audio * amp * EnvGen.kr(Env.perc(0.01, decay, 1.0, -4), doneAction: 2);
	audio = LPF.ar(audio, lpfcutoff);

    // Output to stereo
    Out.ar(0, audio!2);
}).add;


SynthDef(\dPadUpDownPlayer, {
    |bufnum, amp = 0.5, rate = 0.9, level = 0 , loop = 0|

    var audio;

    // Play the buffer with modulation
    audio = PlayBuf.ar(2, bufnum, rate, loop: loop);

    // Apply a simple envelope
	audio = audio * amp * EnvGen.kr(Env.perc(0.01, 0.3, 1.0, -4), doneAction: 2);
	audio = LPF.ar(audio, 1500);

    // Output to stereo
    Out.ar(0, audio!2);
}).add;

SynthDef(\dPadLeftRightPlayer, {
    |bufnum, amp = 0.5, rate = 0.9, level = 0 , loop = 0|

    var audio;

    // Play the buffer with modulation
    audio = PlayBuf.ar(2, bufnum, rate, loop: loop);

    // Apply a simple envelope
	audio = audio * amp * EnvGen.kr(Env.perc(0.01, 0.4, 1.0, -4), doneAction: 2);

    // Output to stereo
    Out.ar(0, audio!2);
}).add;

SynthDef(\musicPlayer, {
    |bufnum, amp = 0.5, rate = 0.9, lpfcutoff = 20000, level = 0 , loop = 0|

    var audio;

    // Play the buffer with modulation
    audio = PlayBuf.ar(2, bufnum, rate, loop: loop);
    // Apply a simple envelope
	audio = audio * amp * EnvGen.kr(Env.adsr(0.01, 0.3, 0.5, curve: -4), doneAction: 2);
	audio = LPF.ar(audio, lpfcutoff);

    // Output to stereo
    Out.ar(0, audio!2);
}).add;

SynthDef(\x3Player, { |amp = 0.5|
    var env, tone, toneTwo, toneThree, noise, noiseTwo, filtNoise, sound, pulse;

    // Amplitude envelope: very fast attack, sustain, then exponential decay
	env = EnvGen.kr(Env.perc(0.01, 0.8, curve: -4), doneAction: 2);
	pulse = LFPulse.kr(Line.kr(22, 10, 0.5), width: 0.5) * 3;

    // Descending tone
    tone = SinOsc.ar(Line.kr(220, 60, 0.7)) * env;
	toneTwo = SinOsc.ar(Line.kr(110, 622.25, 0.5)) * pulse * env;
	toneThree = SinOsc.ar(Line.kr(110, 622.25, 0.5), 0.1) * pulse * env;
	// Mix tone
	tone = (tone + toneTwo + toneThree) /3;

    // Noisy component: band-limited noise burst
    noise = WhiteNoise.ar(0.3);
	noiseTwo = BrownNoise.ar(0.3);
	noiseTwo = LPF.ar(noiseTwo, 250);
	// combine noise
	noise = (noise + noiseTwo)/2;

    // Filtered noise with decaying cutoff
	filtNoise = RLPF.ar(noise, Line.kr(5000, 500, 0.4), 0.5) * env;

    // Mix and output
    sound = (tone + filtNoise) * amp;

    Out.ar(0, Pan2.ar(sound, 0));
}).add;



)
(
//load all sounds must be WAV :((
~dpadUpSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/dpadUp.wav");
~dpadDownSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/dpadDown.wav");
~dpadLeftSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/dpadR.wav");
~dpadRightSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/dpadR.wav");
~aSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/brosCoping.wav");
~bSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/backLjud.wav");
~startSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/earConLong.wav");
~selectSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/song2.wav");
~loadingSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/completedSoundClips/loading.wav");

// volume controll for the music
~musicAmp = 0.0.clip(0,1);



HID.closeAll;
s.waitForBoot({


	//check if releasing or pressing button
	~pressCheck = { |value = 0, button = "A"|
    if(value == 1){
        (button + " pressed").postln;
    }{
        (button + " released").postln;
    };
	};

	//HID.postAvailable;
	HID.findAvailable; // List connected devices
	HID.debug = false; //enable/disable debug mode (output to terminal)

	// open controller detta är specifikt min controller använd HID.postAvailable; för att hitta din kontrollers vendorID och ProductID
	try{
		~controller = HID.open(1118, 654); //Magnus
		// ~controller = HID.open(1118, 673); //Alex
	}{
		"Failed to open controller! Check IDs.".postln;
	};

	//read the HID input
	HID.action = { |value = 0, page = 1, usage = 57, elid = 0|
		// sanity check just so it doesnt post anything when touching joysticks or drifting.
		if(abs(value) < 2) {
		"value: %, page: %, usage: %, elid: %".format(value, page, usage, elid).postln;
		"".postln;
		};

		// Standard Xinput keys (I think) iaf våra kontrollers
		switch(usage,
			57, { ~pressCheck.value(value, "D-PAD");
				switch(page,
					1, { "D-PAD UP".postln;
						Synth.new(\dPadUpDownPlayer, [\bufnum, ~dpadUpSample, \level, 1, \amp, 1]);
					},
					3, { "D-PAD RIGHT".postln;
						Synth.new(\dPadLeftRightPlayer, [\bufnum, ~dpadRightSample, \level, 1, \amp, 2, \rate, 1.5]);
						if(~musicSynth.notNil){
							~musicAmp = (~musicAmp + 0.1).clip(0,1);
							"Music Volume: ".post;
							~musicAmp.postln;
							~musicSynth.set(\amp, ~musicAmp);
							};
					},
					7, { "D-PAD LEFT".postln;
						Synth.new(\dPadLeftRightPlayer, [\bufnum, ~dpadLeftSample, \level, 1, \amp, 2]);
							if(~musicSynth.notNil){
							~musicAmp = (~musicAmp - 0.1).clip(0,1);
							"Music Volume: ".post;
							~musicAmp.postln;
							~musicSynth.set(\amp, ~musicAmp);
							};
					},
					5, { "D-PAD DOWN".postln;
						Synth.new(\dPadUpDownPlayer, [\bufnum, ~dpadDownSample, \level, 1, \amp, 0.5]);
						},
				);
			}, //A
			1, { ~pressCheck.value(value, "A");
				if(value == 1){
					Synth.new(\ABPlayer, [\bufnum, ~aSample, \level, 1, \amp, 0.7, \decay, 0.3, \lpfcutoff, 5000, \rate, 0.3]);
				};

			}, //B
			2, { ~pressCheck.value(value, "B");
				if(value == 1){
				Synth.new(\ABPlayer, [\bufnum, ~bSample, \level, 1, \amp, 0.3, \decay, 0.2, \lpfcutoff, 8000 ]);
				};

			}, //X
			3, { ~pressCheck.value(value, "X");
				if(value == 1){
					Synth(\x3Player, [\amp, 0.8]);
				};

			}, //Y
			4, { ~pressCheck.value(value, "Y");
				if(value == 1){
					~loadingSynth = Synth.new(\musicPlayer, [\bufnum, ~loadingSample, \level, 1, \amp, 0.3, \decay, 0.2, \lpfcutoff, 8000 ]);
				}{
					~loadingSynth.free;
				};

			}, //LB
			5, { ~pressCheck.value(value, "LB");
				// not used but is avalible

			}, //RB
			6, { ~pressCheck.value(value, "RB");
				// not used but is avalible

			}, //SELECT
			7, { ~pressCheck.value(value, "SELECT");
				if(value == 1){
				~musicSynth = Synth.new(\musicPlayer, [\bufnum, ~selectSample, \level, 1, \amp, 0, \lpfcutoff, 20000]);
				};

			}, //START
			8, { ~pressCheck.value(value, "START");
				if(value == 1){
				~startSynth = Synth.new(\musicPlayer, [\bufnum, ~startSample, \level, 1, \amp, 1.0, \lpfcutoff, 6000]);
				}{
					~startSynth.free;
				};

			},
		);

	};

});

)//EOF