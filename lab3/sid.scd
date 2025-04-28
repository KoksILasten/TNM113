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

SynthDef(\distanceSonification, { arg freq = 220, level = 0, distance = 0;
	var output = LFTri.ar(freq) * level.lag(1);

	//var tencm = Synth.new(\tencm, \freq, freq, \distance, distance);

	output = output;

	Out.ar(0, {output}!2);
}).add;




SynthDef(\tencm, { arg freq =150, level = 0, distance = 2, lfo = 5;

	var output;
	var main = [

		SinOsc.ar(freq),
		SinOsc.ar(freq * 2),
		SinOsc.ar(freq * 4),
		SinOsc.ar(freq * 8)
	];

	//var env = EnvGen.ar(Env.perc(attackTime: 0.01, releaseTime: 0.5, level: 1, curve: -2));
	var filter = RLPF.ar(in:main, freq: 200, rq: 0.2);

	var onoff = LFPulse.kr(freq: lfo).range(distance,0);

	main = Mix(main) * 0.3 ;


	output = filter * onoff * level.lag(1);
	Out.ar(0, {output}!2);
}).add;


// Denna synthdefinition är en lyssnare på muspositionen på skärmen
SynthDef(\sendMouse, {
	SendReply.kr(Impulse.kr(60), '/mousePosition', [MouseX.kr(0,Window.screenBounds.right), MouseY.kr(0,Window.screenBounds.bottom), MouseButton.kr.round], 2323)
}).add;

)

(
// Följande registrerar distanceSonification synthdefinitionen på servern
~distanceSynth = Synth.new(\distanceSonification).register;
~bongSynth = Synth.new(\tencm).register;

// Denna funktion är den som tar emot avståndet mellan bilen och lampan,
// och som ska användas för att mappa avståndet till olika mått och sedan
// justera synthdefinitionen (distanceSonification) på servern.
~adjustTheSonification = { arg distance; // distance är inputargumentet
	// Deklarera variabler först
	var level, freq, lfo;
	// Skriv ut avståndet i Post window
	("The distance is:" + distance ++ "cm").postln;
	// Använd case för att ändra/mappa avståndet till olika andra värden
	case
	// För avstånd kortare än 10cm
	{ distance <= 10 } {
		level = 1;
		freq = 500;
		lfo = 10;
	}
	// För avstånd kortare än 30 cm
	{ distance <= 30 } {
		level = 1;
		freq = 220;
		lfo = 8;
	}
	// För avstånd kortare än 50 cm
	{ distance <= 50 } {
		level = 1;
		lfo = 4;
		freq = 150;
	}
	// över 300 cm
	{ distance > 300 }{
		level = 0;
	}
	// under 300cm
	{ distance <= 300}{
		level = 1;
		freq = 80;
		lfo = 1;
	};


	// Skicka informationen till synthdefinitionen
	~bongSynth.set(\freq, freq, \level, level, \distance, distance, \lfo, lfo);
	//~distanceSynth.set(\level, level, \freq, freq);
};



// En del GUI-grejer
~windowWidth = Window.screenBounds.right;
~windowHeight = Window.screenBounds.bottom;
~guiPosX = ((~windowWidth/2) - (1024/2));
~guiPosY = ((~windowHeight/2) - (768/2));
w = Window.new("SID - parking assistance",
	Rect.new(
		~guiPosX,
		~guiPosY,
		1024,
		768))
.front
.background_(Color.new255(0,0,0,255));
~backgroundImage = Image.new(thisProcess.nowExecutingPath.dirname +/+ "road.png");
~viewForBackgroundImage = UserView(w, Rect(0, 0, 1024, 768));
~viewForBackgroundImage.backgroundImage = ~backgroundImage;
~carImage = Image.new(thisProcess.nowExecutingPath.dirname +/+ "car.png");
~carLayer = UserView(w, Rect(-460, 0, 1024, 768));
~carLayer.backgroundImage = ~carImage;
~carLayer.animate = true;
~lampImage = Image.new(thisProcess.nowExecutingPath.dirname +/+ "lamp.png");
~viewForBackgroundImage2 = UserView(w, Rect(0, 0, 1024, 768));
~viewForBackgroundImage2.backgroundImage = ~lampImage;
// Följande togglar en flagga true/false beroende på om musknappen är nedtryckt
// eller inte.
~mouseDownFlag = false;
~viewForBackgroundImage2.mouseDownAction = {
	~mouseDownFlag = true;
};
~viewForBackgroundImage2.mouseUpAction = {
	~mouseDownFlag = false;
};
// Följande registrerar soundMouse synthdefinitionen på servern
~mouseListener = Synth.new(\sendMouse).register;
// Följande kod är en OSC-lyssnare som tar emot information från muslyssnaren (synthdefinitionen)
// och som gör om denna info och skickar mappad information till synthdefinitionen.
o = OSCFunc({ arg msg, time, addr, recvPort;
	if (s.serverRunning) {
		var xPos = msg[3].asInteger;
		var yPos = msg[4].asInteger;
		var newX = (xPos - 740 - ~guiPosX);
		var distance;
		// Om flaggan är true är musknappen nedtryckt och bilen ska flyttas på skärmen
		if (~mouseDownFlag) {
			// Begränsa hur långt i x-led som bilen kan förflyttas
			if (newX < -460) {
				newX = -460;
			};
			if (newX > 64) {
				newX = 64;
			};
			// Flytta bilen. Använd defer för att tillåta att ett GUI-objekt manipuleras.
			{~carLayer.moveTo((newX).asInteger, 0);}.defer;
			// Denna rad gör en linjär till linjär skalning av bilens koordinater i x-led
			// till frekvens från 220 (längst till vänster) till 880 (längst till höger).
			distance = linlin(newX, -460, 64, 600, 0);
			// Denna rad ropar på funktionen adjustTheSonification och skickar med avståndet
			// till lampan som ett heltal.
			~adjustTheSonification.value(distance.asInteger);
		} {
			// Här kan kod skrivas som utförs när musknappen släpps upp.
			~distanceSynth.set(\level, 0);
		};
	};
}, '/mousePosition'); // Detta gör att OSCFunc lyssnar efter muspositionen
// Följande stänger fönstret och OSC-lyssnaren när man stänger av processen i
// SC med <ctrl> & <enter> i Windows och <cmd> & <enter> i MacOS
CmdPeriod.doOnce({
	w.free;
	w.close;
	o.free;
	o.remove;
});
)