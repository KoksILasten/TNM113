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

SynthDef(\dataSonification, { arg freq;
	    var output = [
        SinOsc.ar(freq*2),
        SinOsc.ar(freq),

    ];
    var pulse = LFPulse.kr(10, width: 0.1);

    output = LPF.ar(output/2 * pulse, freq: freq);

    Out.ar(0, {output}!2);
}).add;

SynthDef(\unstableOutputWarning,{ | freq |
// unstable frequencies not in harmony
	var output = [
		SinOsc.ar(freq),
		SinOsc.ar(freq/1.2)
	];
	output = LPF.ar(output/2, freq: freq);

	Out.ar(0, {output}!2);
}).add; //unstab warning end

)


(
// Följande registrerar dataSonification synthdefinitionen på servern
~dataSynth = Synth.new(\dataSonification).register;
//~unstableSynth = Synth.new(\unstableOutputWarning).register;
~activeErrors = Set[];

// Följande är en OSC-lyssnare för level-meddelanden
OSCdef(\levelListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		// Ta hand om meddelandet om det inte är samma som förra
		if (inputmsg[1].asInteger != ~statusLevel) {
			// Detta plockar ut level ur meddelandet som ett heltal
			// och sparar i environment-variabeln
			~statusLevel = inputmsg[1].asInteger;
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

			if (~activeErrors.notEmpty) {
				~activeErrors.do { |err|
					err.postln;
					switch (err,
						'Bipolar capacity low', {
							~dataSynth.set(\freq, frequency * 2);
						},
						'Zero target null', {
							~dataSynth.set(\freq, frequency * 2.5);
						},
						'Risk for overheating', {
							~dataSynth.set(\freq, frequency * 3);
						},
						'Unstable output', {
							~dataSynth.set(\freq, frequency * 3.5);
						},
						{  // Default case: unknown error
							~dataSynth.set(\freq, frequency);
							("Unrecognized error: " ++ err ++ " — using default frequency").postln;
						}
					);
				};
			} {
				~dataSynth.set(\freq, frequency);
				"No error — using default frequency".postln;
			};
		};
	};
}, 'data');





OSCdef(\errorListener, { arg inputmsg;
	if (inputmsg.size > 1) {
		var msg = inputmsg[1].asString;

		if (msg == "No error" or: { msg.isEmpty }) {
			~activeErrors.clear;
			"No active errors — cleared error list".postln;
		} {
			~activeErrors.add(msg);
			("New error received: " ++ msg).postln;
		};
	};
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