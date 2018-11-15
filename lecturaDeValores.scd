// Sonorización de datos de las curvas de luz de Crab, Mrk421 y Mrk501
//Observatorio Hawk https://www.hawc-observatory.org/

//calibración
// chico 0.0011980022099968
// grande 0.01241282988032

// crab

x = CSVFileReader.read(thisProcess.nowExecutingPath.dirname +/+"../csv/HAWC_fluxlc_Crab_.csv", true, true).postcs;

a = Array.fill(472, { arg i; x[i+1][0].split($ ) });
b = Array.fill(472, { arg i; a[i][0] });

//h = b.sort
//h[471] // chico
//h[0] // grande
//h[471].asFloat*100000000000 // chico 0.012142932893696
//h[0].asFloat*100000000000 // grande 0.01241282988032

// mrk421

y = CSVFileReader.read(thisProcess.nowExecutingPath.dirname +/+"../csv/HAWC_fluxlc_Mrk421_.csv", true, true).postcs;

c = Array.fill(471, { arg i; y[i+1][0].split($ ) });
d = Array.fill(471, { arg i; c[i][0] });

//h = d.sort
//h[470] // chico
//h[0] // grande
//h[470].asFloat*100000000000 // chico 0.01215144315904
//h[0].asFloat*100000000000 // grande -0.00128261856256


/// mrk501

z = CSVFileReader.read(thisProcess.nowExecutingPath.dirname +/+"../csv/HAWC_fluxlc_Mrk501_.csv", true, true).postcs;

e = Array.fill(479, { arg i; z[i+1][0].split($ ) });
f = Array.fill(479, { arg i; e[i][0] });

//h = f.sort
//h[478] // chico
//h[0] // grande
//h[478].asFloat*100000000000 // chico 0.0011980022099968
//h[0].asFloat*100000000000 // grande -0.001229125466112


// proxy

PirS.start("192.168.1.100", 5612); // dirección IP de la otra compu. Se necesita la librería PiranhaLab
//PirS.start("127.0.0.1", 5612); // dirección local. Se necesita la librería PiranhaLab

p = ProxySpace.push(s.boot);
p.makeTempoClock((120/120));
p.quant = 4;

// fuentes como un continuo

~crab = {Demand.kr(Impulse.kr(8), 0, Dseq(b.asFloat*10000000000, inf))};
~mrk421 = {Demand.kr(Impulse.kr(8), 0, Dseq(d.asFloat*100000000000, inf))};
~mrk501 = {Demand.kr(Impulse.kr(8), 0, Dseq(f.asFloat*100000000000, inf))};

// replys que jalan el demand

~crabSend = {SendReply.kr(Impulse.kr(30), '/crabSend', ~crab.kr)};
~mrk421Send = {SendReply.kr(Impulse.kr(30), '/mrk421Send', ~mrk421.kr)};
~mrk501Send = {SendReply.kr(Impulse.kr(30), '/mrk501Send', ~mrk501.kr)};

// oscdef

(

OSCdef(\crabSend, {|msg|
	var data = msg[3];
	msg[3].postln;
	PirS.n.sendMsg("/crabSend", data);
}, '/crabSend');

OSCdef(\mrk421Send, {|msg|
	var data = msg[3];
	//msg[3].postln;
	PirS.n.sendMsg("/mrk421Send", data);
}, '/mrk421Send');

OSCdef(\mrk501Send, {|msg|
	var data = msg[3];
	//msg[3].postln;
	PirS.n.sendMsg("/mrk501Send", data);
}, '/mrk501Send');

)

//Pausar OSC
OSCdef(\crabSend).free;
OSCdef(\mrk421Send).free;
OSCdef(\mrk501Send).free;


s.meter

//para controlar el trigger
/*
~dust = {Dust.kr(12)};
~impulse = Impulse.kr(12)};
~trigger = ~dust;
*/

// demands con valores del csv
// fuentes b d f


~dema = {Demand.kr(Impulse.kr(~tempo*16), 0, Dseq(b.asFloat*100000000000, inf))};
~deca = {Decay.kr(Demand.kr(Impulse.kr(~tempo*16), 0, Dseq(b.asFloat*10000000000, inf)) * Impulse.kr(~tempo*16), 0.3)};
~crabo = {Pan2.ar(SinOsc.ar(LinLin.kr(~dema, 0, 1, 150, 8000), 0, ~deca)) * 4};

~dema2 = {Demand.kr(Impulse.kr(~tempo*6), 0, Dseq(d.asFloat*10000000000, inf))};
~deca2 = {Decay.kr(Demand.kr(Impulse.kr(~tempo*6), 0, Dseq(d.asFloat*10000000000, inf)) * Impulse.kr(~tempo*6), 0.3)};
~crab2 = {Pan2.ar(Saw.ar(LinLin.kr(~dema2, 0, 1, 100, 5000), ~deca2)) * 5};

~dema3 = {Demand.kr(Impulse.kr(~tempo*4), 0, Dseq(b.asFloat*10000000000, inf))};
~deca3 = {Decay.kr(Demand.kr(Impulse.kr(~tempo*4), 0, Dseq(b.asFloat*10000000000, inf)) * Impulse.kr(~tempo*4), 0.3)};
~crab3 = {Pan2.ar(SinOsc.ar(LinLin.kr(~dema3, 0, 1, 10, 5000), 0, ~deca3)) * 4};


//PMOsc con tres fuentes
~demaSin = {Demand.kr(Impulse.kr(6), 0, Dseq(b.asFloat*10000000000, inf))};
~decaSin = {Decay.kr(Demand.kr(Impulse.kr(14), 0, Dseq(b.asFloat*10000000000, inf)) * Impulse.kr(14), 4)};
~sin =  {Pan2.ar(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([150,20,350,300,350].pyramid*2,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin),0,Dseq([15,30],inf)),2),0,0.2))*~decaSin};


~demaSin2 = {Demand.kr(Impulse.kr(6), 0, Dseq(d.asFloat*10000000000, inf))};
~decaSin2 = {Decay.kr(Demand.kr(Impulse.kr(14), 0, Dseq(d.asFloat*10000000000, inf)) * Impulse.kr(14), 4)};
~sin2 =  {Pan2.ar(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin2)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([150,20,350,300,350].pyramid*2,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin2),0,Dseq([15,30],inf)),2),0,0.2))*~decaSin2};


~demaSin3 = {Demand.kr(Impulse.kr(6), 0, Dseq(f.asFloat*10000000000, inf))};
~decaSin3 = {Decay.kr(Demand.kr(Impulse.kr(14), 0, Dseq(f.asFloat*10000000000, inf)) * Impulse.kr(14), 4)};
~sin3 =  {Pan2.ar(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin3)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([150,20,350,300,350].pyramid,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin3),0,Dseq([15,30],inf)),2),0,0.2))*~decaSin3};


//comodín a desarrollar
~lftri = {Pan2.ar(LFTri.ar(Demand.kr(Impulse.kr(~tempo * 8), 0, Dseq(b.asFloat*10000000000, inf)))*2).fold2(0.3) * SinOsc.kr(1 * Demand.kr(Impulse.kr(~tempo), 0, Dseq([~tempo*9, ~tempo*5, ~tempo*2, ~tempo*1,  ~tempo*3], inf)), 0, 0.2)*0.3};

//polifonías para el ruido
~voz1 = { LFNoise2.kr(1/(2..18)) * SinOsc.ar( Array.fill(16,{ 50 + 1300.0.rand }))!2/24}
~voz2 = { Pan2.ar(SinOsc.ar( Array.fill(19,{ 60 + 1800.10.rand }) * Saw.kr([9,10]*Demand.kr(Impulse.kr(~tempo),0,Dseq([0.0025,15])),0,0.1,0.5),1.51)).tanh / 9*1 };


//SinOsc
~crabo.play;
~crab2.play;
~crab3.play;

//otras
~sin.play;
~sin2.play;
~sin3.play;

//comodín
~lftri.play;

//polifonías
~voz1.play;
~voz2.play;

//___________________stop and clear

~crabo.stop;
~crab2.stop;
~crab3.stop;

~sin.stop;
~sin2.stop;
~sin3.stop;

~lftri.stop;

~voz1.stop;
~voz2.stop;