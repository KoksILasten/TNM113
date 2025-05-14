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

SynthDef(\dataSonification, { arg freq, width = 0.1;
	    var output = [
        SinOsc.ar(freq*2),
        SinOsc.ar(freq),

    ];
    var pulse = LFPulse.kr(10, width: width);

    output = LPF.ar(output/2 * pulse, freq: freq);

    Out.ar(0, {output}!2);
}).add;

SynthDef(\unstableOutputWarning,{ arg freq = 220, level = 0;
// unstable frequencies not in harmony
	var output = [
		SinOsc.ar(freq),
		SinOsc.ar(freq/1.2),
	];
	output = LPF.ar(output/2, freq: 440);

	Out.ar(0, {output * level.lag(1)}!2);
}).add; //unstab warning end

SynthDef(\bipolarWarning,{ arg freq = 220, level = 0;

	var output = [
		SinOsc.ar(freq),
		SinOsc.ar(freq*1.3),
	];

	output = output + output / 4;

	Out.ar(0, {output/2 * level.lag(1)}!2);
}).add; //unstab warning end


SynthDef(\zeroTargetNull,{ arg freq = 220, level = 0;

	var output = [
		LFTri.ar(freq),
	];

	var pulse = LFPulse.ar(5, width: 0.3);

	output = output * pulse;

	Out.ar(0, {output/2 * level.lag(1)}!2);
}).add; //zero warning end

SynthDef(\heatWarning,{ arg freq = 2500, level = 0;
// unstable frequencies not in harmony
    var freqy = freq + LFNoise1.kr(2!2).range(-50, 50); // Add instability
	var amp = Env.adsr(0.1, 3).kr; // Percussive envelope
    var sig = SinOsc.ar(freqy) * amp; // Whistle core
    var crackle = PinkNoise.ar(0.2 * LFNoise1.kr(10!2).range(0, 1)); // Boiling noise
    var filter = BPF.ar(crackle, freq * 2, 0.1); // Filter noise to match pitch
	Out.ar(0, {(sig + filter) * 0.5 * level.lag(1)}!2);
}).add; //heat warning end

SynthDef(\unstable,{ arg freq = 220, level = 0;

	var output = [
		SinOsc.ar(freq),
		SinOsc.ar(freq, 0.02),
	];


	var combFilter = CombN.ar(output, maxdelaytime: 0.2);

	output = combFilter;

	Out.ar(0, {combFilter/2 * level.lag(1)}!2);
}).add; //unstab warning end


) // end of defs


(
// Följande registrerar dataSonification synthdefinitionen på servern
~dataSynth = Synth.new(\dataSonification).register;
~unstableSynth = Synth.new(\unstableOutputWarning).register;
~bipolarSynth = Synth.new(\bipolarWarning).register;
~heatSynth = Synth.new(\heatWarning).register;
~nullSynth = Synth.new(\zeroTargetNull).register;
~errorMessage = Set[];

// Följande är en OSC-lyssnare för level-meddelanden
OSCdef(\levelListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		// Ta hand om meddelandet om det inte är samma som förra
		if (inputmsg[1].asInteger != ~statusLevel) {
			// Detta plockar ut level ur meddelandet som ett heltal
			// och sparar i environment-variabeln
			~statusLevel = inputmsg[1].asInteger;

			if (~statusLevel.notNil) {
				switch (~statusLevel,
					0, {
						~dataSynth.set(\width, 0.8);
						//"skibidi".postln;

					},
					1, {
						~dataSynth.set(\width, 0.6);

					},
					2, {
						~dataSynth.set(\freq, 0.4);

					},
					3, {
						~dataSynth.set(\width, 0.1);
					},
					{
						// default fallback
						//~dataSynth.set(\freq, frequency);
						inputmsg[1].postln;
					}
				);
			} {
				// No error message
				~dataSynth.set(\width, 0.4)
			}

		};
	};
}, 'level');



OSCdef(\dataListener, {
	arg inputmsg;
	var frequency;

	if (inputmsg.size > 1) {
		if (inputmsg[1].asInteger != ~currentData) {
			~currentData = inputmsg[1].asInteger;
			frequency = ~mapPitch.value(~currentData);

			~dataSynth.set(\freq, frequency);


			if (~errorMessage.notNil) {
				switch (~errorMessage,
					'Bipolar capacity low', {
						~dataSynth.set(\freq, frequency * 2);
						~bipolarSynth.set(\level, 1, \freq, 220);
						~unstableSynth.set(\level, 0);
						~heatSynth.set(\level, 0);
						~nullSynth.set(\level, 0);
					},
					'Zero target null', {
						//~dataSynth.set(\freq, frequency * 2.5);
						~unstableSynth.set(\level, 0);
						~bipolarSynth.set(\level, 0);
						~heatSynth.set(\level, 0);
						~nullSynth.set(\level, 1, \freq, 660);
						//~errorMessage.postln;
					},
					'Risk for overheating', {
						//~dataSynth.set(\freq, frequency * 3);
						~unstableSynth.set(\level, 0);
						~bipolarSynth.set(\level, 0);
						~heatSynth.set(\level, 1, \freq, 1600);
						~nullSynth.set(\level, 0);
						//~errorMessage.postln;
					},
					'Unstable output', {
						//~dataSynth.set(\freq, frequency * 3.5);
						~unstableSynth.set(\freq, frequency, \level, 1);
						~bipolarSynth.set(\level, 0);
						~heatSynth.set(\level, 0);
						~nullSynth.set(\level, 0);
						~errorMessage.postln;
					},
					{
						// default fallback
						~dataSynth.set(\freq, frequency);
						~unstableSynth.set(\level, 0);
						~bipolarSynth.set(\level, 0);
						~heatSynth.set(\level, 0);
						~nullSynth.set(\level, 0);
					}
				);
			} {
				// No error message
				~dataSynth.set(\freq, frequency);
			}
		}
	};
}, 'data');


// Följande är en OSC-lyssnare för fel-meddelanden
OSCdef(\errorListener, { |msg|
	if(msg.size>1){
		if (msg[1] != nil){
			~errorMessage.add(msg[1]);
			if( msg.size>2){
				msg[2].postln;
				if(~errorMessage.includes(msg[2])){}{

				~errorMessage.add(msg[2]);
				}
			};

			~errorMessage.postln; // debug: print message
			if (msg.size> 2){
				//msg[2].postln;

			};

		}{
			~erroMessage.clear();
		};

	};


~erroMessage.clear();
~errorMessage.postln;
}, 'error');


~mapPitch = { arg freq;
	// Först görs en linjär till linjär mappning av värdet till frekvens (i Hz)
	var frequency = linlin(freq, 0, 300, 220, 880) ;
	// returnerar värdet
	frequency.value;
};

)

// Följande rad kollar vilken lokal address som OSC-lyssnaren använder. Denna måste
// vara samma i båda programmen, så att "monitorGUIt" skickar på rätt address.
NetAddr.localAddr;