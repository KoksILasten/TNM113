// Starta servern
s.boot; // en rad kod körs med <Shift> och <Enter>
// Stop server
s.quit;
// Start oscilloscope
s.scope;

// När servern är igång skickar man över en eller flera synth definitioner till serven.
(
// Kod inom parenteser körs med <cmd> och <Enter> på Mac eller <ctrl> och <Enter> i Windows

   // Oboe (Reference Pitch)
SynthDef(\oboe, {
    |freq = 440, amp = 0.2, dur = 5, detune = 0, level=0 |
    var sig = SinOsc.ar(freq + (freq * detune));
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\violin, {
    |freq = 440, amp = 0.15, dur = 5, detune = 0, level=0|
    var sig = LFSaw.ar(freq + (freq * detune), 0, 0.3);
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\viola, {
    |freq = 440, amp = 0.15, dur = 5, detune = 0, level=0|
    var sig = LFSaw.ar(freq * 0.75 + (freq * 0.75 * detune), 0, 0.3);
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\cello, {
    |freq = 220, amp = 0.15, dur = 5, detune = 0, level=0|
    var sig = LFSaw.ar(freq + (freq * detune), 0, 0.3);
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\flute, {
    |freq = 440, amp = 0.15, dur = 5, detune = 0, level=0|
    var sig = SinOsc.ar(freq + (freq * detune), 0, 0.3);
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\clarinet, {
    |freq = 440, amp = 0.15, dur = 5, detune = 0, level=0|
	var sig = Pulse.ar(freq + (freq * detune), 0.5);
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\trumpet, {
    |freq = 440, amp = 0.2, dur = 5, detune = 0, level=0|
    var sig = Blip.ar(freq + (freq * detune), 5);
    Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\horn, {
    |freq = 220, amp = 0.2, dur = 5, detune = 0, level=0|
    var sig = Blip.ar(freq + (freq * detune), 3);
	Out.ar(0, sig!2 * amp * level.lag(1));
}).add;

SynthDef(\weatherPlayer, {
    |bufnum, amp = 0.5, rate = 0.8, modFreq = 0.25, modDepth = 0.1|

    var modSignal, audio;

    // Generate modulation for a subtle natural effect
    //modSignal = SinOsc.kr(modFreq, 0, modDepth, 1);

    // Play the buffer with modulation
    audio = PlayBuf.ar(1, bufnum, rate, loop: 1);

    // Apply a simple envelope
    audio = audio * amp *EnvGen.kr(Env.adsr(0.01, 0.1, 0.8, 0.2, 1), doneAction: 0);

    // Output to stereo
    Out.ar(0, audio!2);
}).add;



SynthDef(\temperatureSynth, { arg frequency = 220, level = 0;
	var output = SinOsc.ar(freq: frequency, mul: 0.3) * level.lag(0.5);

	Out.ar(0, {output}!2);
}).add;

)

(
//Weather sounds
//Cant read anything because this fucking language is a fucking joke. Actually fucking sucks. You can load them together but not the entire block
~sunshineBuffer = Buffer.read(s, "compiledSunshine.wav");
~snowfallBuffer = Buffer.read(s, "snowfall2.wav",bufnum:1);
~rainfallBuffer = Buffer.read(s, "rainZelda.wav");

// Flaggor som håller koll på vädret
~sunFlag = false;
~rainFlag = false;
~snowFlag = false;
// Synthinstansen för temperaturen
~temperatureSynth = Synth.new(\temperatureSynth);

// En del GUI-grejer
w = Window.new("Thermometer",
	Rect.new(
		20,
		200,
		1024,
		500))
.front;
u = UserView(w, Rect(0, 0, 1024, 500))
.background = Color.hsv(0.31, 0.2, 1, 0.5);
~text = StaticText(u, Rect(874, 20, 160, 60))
.string_(" 10.0 degrees")
.font_(Font("Monaco", 16));
~sunImage = Image.open(thisProcess.nowExecutingPath.dirname +/+ "sun.png").scalesWhenResized_(true).setSize(300, 300);
~sunshine = UserView(u, Rect(700, 120, 300, 300))
.background_(Color.new255(0,0,0,0))
.setBackgroundImage(~sunImage, alpha: 0.5);
~sunButton = Button.new(w,Rect(700,120,300,300))
.states_([
	["", Color.black, Color.gray(0,0)]
])
.action_({
	if (~sunFlag) {
		~sunFlag = false;
		~sunshine.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~sunImage, alpha: 0.5);
	} {
		~sunFlag = true;
		~sunshine.background_(Color.new255(0,0,0,25))
		.setBackgroundImage(~sunImage, alpha: 1);
		~rainFlag = false;
		~rain.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~rainImage, alpha: 0.5);
		~snowFlag = false;
		~snow.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~snowImage, alpha: 0.5);
	};
	~sunAction.value;
	~rainAction.value;
	~snowAction.value;
});
~rainImage = Image.open(thisProcess.nowExecutingPath.dirname +/+ "rain.png").scalesWhenResized_(true).setSize(300, 300);
~rain = UserView(u, Rect(360, 120, 300, 300))
.setBackgroundImage(~rainImage, alpha: 0.5);
~rainButton = Button.new(w,Rect(360,120,300,300))
.states_([
	["", Color.black, Color.gray(0,0)]
])
.action_({
	if (~rainFlag) {
		~rainFlag = false;
		~rain.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~rainImage, alpha: 0.5);
	} {
		~rainFlag = true;
		~rain.background_(Color.new255(0,0,0,25))
		.setBackgroundImage(~rainImage, alpha: 1);
		~sunFlag = false;
		~sunshine.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~sunImage, alpha: 0.5);
		~snowFlag = false;
		~snow.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~snowImage, alpha: 0.5);
	};
	~sunAction.value;
	~rainAction.value;
	~snowAction.value;
});
~snowImage =  Image.open(thisProcess.nowExecutingPath.dirname +/+ "snow.png").scalesWhenResized_(true).setSize(300, 300);
~snow = UserView(u, Rect(20, 120, 300, 300))
.setBackgroundImage(~snowImage, alpha:0.5);
~snowButton = Button.new(w,Rect(20,120,300,300))
.states_([
	["", Color.black, Color.gray(0,0)]
])
.action_({
	if (~snowFlag) {
		~snowFlag = false;
		~snow.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~snowImage, alpha: 0.5);
	} {
		~snowFlag = true;
		~snow.background_(Color.new255(0,0,0,25))
		.setBackgroundImage(~snowImage, alpha: 1);
		~sunFlag = false;
		~sunshine.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~sunImage, alpha: 0.5);
		~rainFlag = false;
		~rain.background_(Color.new255(0,0,0,0))
		.setBackgroundImage(~rainImage, alpha: 0.5);
	};
	~sunAction.value;
	~rainAction.value;
	~snowAction.value;
});
~slider = Slider(u, Rect(20, 20, 840, 60))
.value_(0.5);




// -------------------------|||||-------------------------
// --------------- Här nedan börjar det roliga -----------
// -------------------------|||||-------------------------


// När slidern klickas spelas ljudet från temperatursynthen upp
~slider.mouseDownAction = {
	//~temperatureSynth.set(\level, 1);
	    ~oboe.set(\level, 1);
    ~violin.set(\level, 1);
    ~viola.set(\level, 1);
    ~cello.set(\level, 1);
    ~flute.set(\level, 1);
    ~clarinet.set(\level, 1);
    ~trumpet.set(\level, 1);
    ~horn.set(\level, 1);
};
~slider.mouseUpAction = {
	//~temperatureSynth.set(\level, 0);
	    ~oboe.set(\level, 0);
    ~violin.set(\level, 0);
    ~viola.set(\level, 0);
    ~cello.set(\level, 0);
    ~flute.set(\level, 0);
    ~clarinet.set(\level, 0);
    ~trumpet.set(\level, 0);
    ~horn.set(\level, 0);
};

// Följande funktioner ropas på när de olika väderförhållandena väljs
~sunAction = {
	if (~sunFlag) {
		("Sun").postln;
		~sunSound = Synth(\weatherPlayer, [\bufnum, ~sunshineBuffer.bufnum]);
	} {
		("No sun").postln;
		~sunSound.free;
        ~sunSound = nil;
	};
};
~rainAction = {
	if (~rainFlag) {
		("Rain").postln;
		~rainSound = Synth(\weatherPlayer, [\bufnum, ~rainfallBuffer.bufnum, \amp, 0.5]);
	} {
		("No rain").postln;
		~rainSound.free;
        ~rainSound = nil;
	};
};
~snowAction = {
	if (~snowFlag) {
		("Snow").postln;
		~snowSound = Synth(\weatherPlayer, [\bufnum, ~snowfallBuffer.bufnum, \amp, 0.5]);
	} {
		("No snow").postln;
		~snowSound.free;
        ~snowSound = nil;
	};
};


//start of slider
~oboe = Synth(\oboe);
~violin = Synth(\violin);
~viola = Synth(\viola);
~cello = Synth(\cello);
~flute = Synth(\flute);
~clarinet = Synth(\clarinet);
~trumpet = Synth(\trumpet);
~horn = Synth(\horn);

// Följande funktion körs när slidern flyttas på
~slider.action_({ arg obj;
	var hue, string; // två variabler för GUIt
	// Följande skalar om sliderns värde till en float mellan -20 och 40
	var temperature = (linlin(obj.value, 0, 1, -20, 40)*10).round/10;

	// När temperaturen ändras gör söker med ljudet här
	//~temperatureSynth.set(\frequency, linexp(temperature, -20, 40, 110, 880));

	// Calculate detune factor based on temperature
	var detune = linlin(temperature, -20, 40, -0.8, 0.0);  // Detune from -0.8 (cold) to 0.8 (warm)

    // Set the frequency of the instruments and apply the detune
    ~oboe.set(\freq, 440, \detune, detune);
    ~violin.set(\freq, 440, \detune, detune);
    ~viola.set(\freq, 440, \detune, detune);
    ~cello.set(\freq, 220, \detune, detune);
    ~flute.set(\freq, 440, \detune, detune);
    ~clarinet.set(\freq, 440, \detune, detune);
    ~trumpet.set(\freq, 440, \detune, detune);
    ~horn.set(\freq, 220, \detune, detune);


	// Följande justerar bakgrundsfärgen i GUIt
	hue = linlin(temperature, -20, 40, 0.6, 0.1);
	if (temperature >= 0) {
		string = "" + temperature + "degrees";
	} {
		string = temperature + "degrees";
	};
	~text.string_(string);
	u.background_(Color.hsv(hue, 0.2, 1, 0.5));
});


// Följande stänger fönstret när processen stängs
CmdPeriod.doOnce({

	//free weather synths
	if(~sunSound.notNil, { ~sunSound.free; });
    if(~rainSound.notNil, { ~rainSound.free; });
    if(~snowSound.notNil, { ~snowSound.free; });

    // Free orchestra synths
    ~oboe.free;
	~violin.free;
	~viola.free;
	~cello.free;
    ~flute.free;
	~clarinet.free;
	~trumpet.free;
	~horn.free;

	~temperatureSynth.free;

	w.free;
	w.close;
});

)