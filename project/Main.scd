// =============================================
// Skate 2. Menu sound replacer with controller support
// =============================================
// Boot the server

s.boot;
// Wait for server to boot before continuing
(

SynthDef(\samplePlayer, {
    |bufnum, amp = 0.5, rate = 0.9, modFreq = 0.25, modDepth = 0.1, level = 0 , loop = 1|

    var modSignal, audio;

    // Generate modulation for a subtle natural effect
    //modSignal = SinOsc.kr(modFreq, 0, modDepth, 1);

    // Play the buffer with modulation
    audio = PlayBuf.ar(2, bufnum, rate, loop: loop);

    // Apply a simple envelope
	//audio = audio * amp * EnvGen.kr(Env.adsr(0.01, 0.1, 0.8, 0.2, 1), doneAction: 0) * level.lag(5);
	audio = audio * amp * EnvGen.kr(Env.perc(0.01, 1.5, 1.0, -2));

    // Output to stereo
    Out.ar(0, audio!2);
}).add;

)

(
//TEST. VI kommer använda dictionary när det är på riktigt.
//load all sounds must be WAV :((
~morningMusicSample = Buffer.read(s, thisProcess.nowExecutingPath.dirname++"/sounds/CementGrind.wav");


HID.closeAll;
s.waitForBoot({
    // Path to your skateboard sound samples
    //~samplePath = PathName(thisProcess.nowExecutingPath).parentPath +/+ "sounds/";

    // Buffer dictionary to store samples
    //~samples = Dictionary.new;

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

	//open controller detta är specifikt min controller använd HID.postAvailable; för att hitta din kontrollers vendorID och ProductID
	~controller = HID.open(1118, 654);

	if(~controller.isNil) {
        "Failed to open controller! Check IDs.".postln;
    } {
        "Controller connected successfully!".postln;
	};


	HID.action = { |value = 0, page = 1, usage = 57, elid = 0|

		"value: %, page: %, usage: %, elid: %".format(value, page, usage, elid).postln;
		"".postln;

		//Standard Xinput (I think) iaf min kontroller
		switch(usage,
			57, { ~pressCheck.value(value, "D-PAD");
				switch(page,
					1, { "D-PAD UP".postln;
						{Synth.new(\samplePlayer, [\bufnum, ~morningMusicSample, \level, 1]); }.play;


					},
					3, { "D-PAD RIGHT".postln;},
					7, { "D-PAD LEFT".postln;},
					5, { "D-PAD DOWN".postln;},
				);
			},
			1, { ~pressCheck.value(value, "A");}, //A
			2, { ~pressCheck.value(value, "B");}, //B
			3, { ~pressCheck.value(value, "Y");}, //Y
			4, { ~pressCheck.value(value, "X");}, //X
			5, { ~pressCheck.value(value, "LB");}, //LB
			6, { ~pressCheck.value(value, "RB");}, //RB
			7, { ~pressCheck.value(value, "SELECT");}, //SELECT
			8, { ~pressCheck.value(value, "START");}, //START
			50, { ~pressCheck.value(value, "LT");}, //LT //LT och RT fungerar inte presscheck till 100% men det spelar ingen roll
			51, { ~pressCheck.value(value, "RT");}, //RT
		);

	};



    // Load skateboard sounds into buffers



});

)//EOF