s.boot;
s.free;
//select code and use shift + enter to run.
//Use camelCase for varibles otherwise it could cause an error

postln("hello World");
("Hello World").postln;

//runs as block when hovering on ( ) and ctrl + enter
(
postln("Hello");
(" World!").postln;
)

//variable only exits in current scope
(
var x = ("Hello world");
x.postln;
)

(
s.boot; //boots server
s.serverRunning; //checks if server booted
)

//basic tone
{ [SinOsc.ar(440, 0, 0.2), SinOsc.ar(442, 0, 0.2)] }.play;

// function created with {}
f = { "Function evaluated".postln; };
f.value;
f.value;
f.value;

(
f = { arg a; a.value + 3 };    // call 'value' on the arg; polymorphism awaits!
f.value(3);            // 3.value = 3, so this returns 3 + 3 = 6
)
(
g = { 3.0.rand; };
f.value(g);            // here the arg is a Function. Cool, huh?
f.value(g);            // try it again, different result)
)

( //function with multiple
f = { arg a, b;
    a - b;
};
f.value(5, 3);
)

( //specify different orders by using what are called keyword arguments
f = { arg a, b; a / b; };    // '/' means divide
f.value(10, 2);            // regular style
f.value(b: 2, a: 10);        // keyword style
)

(
f = { arg a, b = 2; a + b; };
f.value(2);
)

( //Declare.'
f = { arg a, b; a + b; };
g = { |a, b| a + b; };
f.value(2, 2);
g.value(2, 2);
)

(
{ var ampOsc;
    ampOsc = SinOsc.kr(0.5, 1.5, 0.5, 0.5);
    SinOsc.ar(440, 0, ampOsc);
}.play;
)
(
SynthDef.new(\coffeeTest,{
	arg freq = 0.5;
    var ampOsc;
	ampOsc = SinOsc.kr(freq, 1.5, 0.5, 0.5);
    SinOsc.ar(440, 0, ampOsc);
}).add;
)
x = Synth.new(\coffeeTest);

x.set(\freq,10);
x.set(\freq,0.5);


(
f = SoundFile.new;
f.openRead("D:/Repos/TNM113-Labs/lab1/sfx/VattenRinna.aac");
postln(f.numChannels);
postln(f.sampleRate);
f = f.seek(origin:20);
f.play;
//f.seek(offset: 20, origin: 0).play;
)

(
SynthDef.new(\millie,{
	arg songStart=44100*3, playRate=1, pitchRatio=1.0;
	// It's a proper audio file -- server can load it
	b = Buffer.readChannel(s, "D:/Repos/TNM113-Labs/lab1/playboi.mp3",channels:[0]);


// It's a sinewave...
a =  (PlayBuf.ar(1, b, startPos:songStart, loop: 1, rate:playRate) * 0.1).dup ;

//a = PitchShift.ar(a,pitchRatio:pitchRatio, timeDispersion:0.1);

	Out.ar(0,a);

}).add;
)
x= Synth.new(\millie);

x.set(\songStart,44100*4);
x.set(\playRate,0.5);
x.set(\pitchRatio,1);

b.numFrames;
x=b.numFrames;



