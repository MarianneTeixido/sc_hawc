// Sonorización de datos de las curvas de luz de Crab, Mrk421 y Mrk501
//Observatorio Hawk https://www.hawc-observatory.org/

//calibración
// chico 0.0011980022099968
// grande 0.01241282988032

// crab

ServerOptions.inDevices;
o = Server.local.options;
o.device = "UMC404HD 192k";
o.outDevice.postln
o.outDevice_("UMC404HD 192k");
s.options.sampleRate =  44100;

Server.local.options.numInputBusChannels =  4;
Server.local.options.numOutputBusChannels =  4;

//dirección buffers
w = PathName.new("~/Documents/algoraves/samples/".standardizePath);

//r = Buffer.read(s,w.pathOnly++"bufagua01.aiff");
r = [Buffer.read(s,w.pathOnly++"bufagua01.aiff"),Buffer.read(s,w.pathOnly++"bufagua02.aiff"),
	Buffer.read(s,w.pathOnly++"bufagua03.wav"),Buffer.read(s,w.pathOnly++"voz01.wav"),
	Buffer.read(s,w.pathOnly++"voz02.wav"),Buffer.read(s,w.pathOnly++"voz03.wav"),
	Buffer.read(s,w.pathOnly++"voz04.wav"),Buffer.read(s,w.pathOnly++"voz05.wav"),
	Buffer.read(s,w.pathOnly++"voz06.wav"),Buffer.read(s,w.pathOnly++"voz06.wav"),
	Buffer.read(s,w.pathOnly++"voz08.wav"),Buffer.read(s,w.pathOnly++"voz09.wav"),
	Buffer.read(s,w.pathOnly++"voz10.wav"),Buffer.read(s,w.pathOnly++"voz11.wav")
];


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

PirS.start("192.168.1.65", 5612); // dirección IP de la otra compu. Se necesita la librería PiranhaLab
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


~dema = {Demand.kr(Impulse.kr(~tempo*9), 0, Dseq(b.asFloat*100000000000, inf))};
~deca = {Decay.kr(Demand.kr(Impulse.kr(~tempo*9), 0, Dseq(b.asFloat*10000000000, inf)) * Impulse.kr(~tempo*9), 0.3)};
~crabo = {SinOsc.ar(LinLin.kr(~dema, 0, 1, 150, 8000), 0, ~deca) * [4, 0.01, 0.01, 0.01]};

~dema2 = {Demand.kr(Impulse.kr(~tempo*6), 0, Dseq(d.asFloat*10000000000, inf))};
~deca2 = {Decay.kr(Demand.kr(Impulse.kr(~tempo*6), 0, Dseq(d.asFloat*10000000000, inf)) * Impulse.kr(~tempo*6), 0.3)};
~crab2 = {Saw.ar(LinLin.kr(~dema2, 0, 1, 160, 5000), ~deca2)*[0.01, 4, 0.02, 4] };

~dema3 = {Demand.kr(Impulse.kr(~tempo*8), 0, Dseq(b.asFloat*10000000000, inf))};
~deca3 = {Decay.kr(Demand.kr(Impulse.kr(~tempo*8), 0, Dseq(b.asFloat*10000000000, inf)) * Impulse.kr(~tempo*8), 0.3)};
~crab3 = {SinOsc.ar(LinLin.kr(~dema3, 0, 1, 10, 5000), 0, ~deca3)*[0.01, 0.01, 4, 0.01]};


//PMOsc con tres fuentes
~demaSin = {Demand.kr(Impulse.kr(4), 0, Dseq(d.asFloat*10000000000, inf))};
~decaSin = {Decay.kr(Demand.kr(Impulse.kr(4), 0, Dseq(d.asFloat*10000000000, inf)) * Impulse.kr(4))};

~sin =  {(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([50,20,350,360,350].pyramid*2,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin),0,Dseq([10,30],inf)),2),0,0.2)*~decaSin)*[4,4,4,4]};


~demaSin2 = {Demand.kr(Impulse.kr(6), 0, Dseq(d.asFloat*10000000000, inf))};
~decaSin2 = {Decay.kr(Demand.kr(Impulse.kr(14), 0, Dseq(d.asFloat*10000000000, inf)) * Impulse.kr(14), 4)};
~sin2 =  {Pan2.ar(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin2)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([150,20,350,300,350].pyramid*2,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin2),0,Dseq([15,30],inf)),2),0,0.2))*~decaSin2};


~demaSin3 = {Demand.kr(Impulse.kr(6), 0, Dseq(f.asFloat*10000000000, inf))};
~decaSin3 = {Decay.kr(Demand.kr(Impulse.kr(14), 0, Dseq(f.asFloat*10000000000, inf)) * Impulse.kr(14), 4)};
~sin3 =  {Pan2.ar(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin3)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([150,20,350,300,350].pyramid,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin3),0,Dseq([15,30],inf)),2),0,0.2))*~decaSin3};


//comodín a desarrollar
~lftri = {Pan2.ar(LFTri.ar(Demand.kr(Impulse.kr(~tempo * 8), 0, Dseq(b.asFloat*10000000000, inf)))*2).fold2(0.3) * SinOsc.kr(1 * Demand.kr(Impulse.kr(~tempo), 0, Dseq([~tempo*9, ~tempo*5, ~tempo*2, ~tempo*1,  ~tempo*3], inf)), 0, 0.2)*0.03};

//polifonías para el ruido
~voz1 = { LFNoise2.kr(1/(2..18)) * SinOsc.ar( Array.fill(16,{ 50 + 1300.0.rand }))!4/24}
~voz2 = { (SinOsc.ar( Array.fill(19,{ 10 + 1800.10.rand }) * Saw.kr([9,10,41]*Demand.kr(Impulse.kr(~tempo),0,Dseq([0.00025,15])),0,0.1,0.5),1.51)).tanh !4/ 19*1 };


/*
~decag2 = {Demand.kr(Impulse.kr(6), 0, Dseq(f.asFloat*10000000000, inf))};
~decag2 = {Decay.kr(Demand.kr(Impulse.kr(14), 0, Dseq(f.asFloat*10000000000, inf)) * Impulse.kr(14), 4)};
~grass2 =  {Pan2.ar(PMOsc.ar(Demand.kr(Impulse.kr(~tempo*4),0,Dseq(~demaSin3)),Demand.kr(Impulse.kr(~tempo*4),0,Dseq([150,20,350,300,350].pyramid,inf)),Lag.kr(Demand.kr(Impulse.kr(~decaSin3),0,Dseq([15,30],inf)),2),0,0.2))*~decaSin3};
*/

//~grass = {PlayBuf.ar(2,r[0],BufRateScale.kr(r[0]) * [b.asFloat*10000000000], Impulse.kr([b.asFloat*10000000000].scramble), BufFrames.kr(r[0])*Demand.kr(Impulse.kr(~tempo*6),0,Drand([b.asFloat*10000000000],inf))).clip2(0.2)*0.7};

~buf01 = {PlayBuf.ar(2,r[1],BufRateScale.kr(r[1]) * Lag.kr(Demand.kr(Impulse.kr(~tempo*0.05), 0, Dseq([1.2, 1, 1.2], inf)), 4) * [1, 1.05], Impulse.kr(Demand.kr(Impulse.kr(~tempo*4), 0, Drand([2, 3, 4,5]*1, inf))), BufFrames.kr(r[1])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.001,0.5,0.001,0.001]};


s.scope
s.meter
//SinOsc
~code.play;
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


//______________________audios video

~buf01.stop;
~buf02.stop;
~v01.stop;
~v02.stop;
~v03.stop;
~v04.stop;
~v05.stop;
~v06.stop;
~v07.stop;
~v08.stop;
~v09.stop;
~v10.stop;
~v11.stop;

s.meter

//audio videos
~buf01.play
~buf02.play

~v01.play;
~v02.play;
~v03.play;
~v04.play;
~v05.play;
~v06.play;
~v07.play;
~v08.play;
~v09.play;
~v10.play;
~v11.play;



//audio

~buf01 = {PlayBuf.ar(2,r[1],BufRateScale.kr(r[1])  * [1, 1.05], Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Drand([2, 3, 4,5]*1, inf))), BufFrames.kr(r[1])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.001,2,0.001,0.001]};



~v01 = {PlayBuf.ar(1,r[3],BufRateScale.kr(r[3]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/4]*1, inf))), BufFrames.kr(r[3])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[4,0.1,0.1,0.1]};

~v02 = {PlayBuf.ar(1,r[4],BufRateScale.kr(r[4]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/4]*1, inf))), BufFrames.kr(r[4])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v03 = {PlayBuf.ar(1,r[5],BufRateScale.kr(r[5]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[5])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v04 = {PlayBuf.ar(1,r[6],BufRateScale.kr(r[6]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[6])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v05 = {PlayBuf.ar(1,r[7],BufRateScale.kr(r[7]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[7])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v06 = {PlayBuf.ar(1,r[8],BufRateScale.kr(r[8]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[8])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v07 = {PlayBuf.ar(1,r[9],BufRateScale.kr(r[9]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[9])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v08 = {PlayBuf.ar(1,r[10],BufRateScale.kr(r[10]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[10])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v09 = {PlayBuf.ar(1,r[11],BufRateScale.kr(r[11]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[11])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v10 = {PlayBuf.ar(1,r[12],BufRateScale.kr(r[12]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[12])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};

~v11 = {PlayBuf.ar(1,r[13],BufRateScale.kr(r[13]) * 1, Impulse.kr(Demand.kr(Impulse.kr(~tempo), 0, Dseq([0.125/2]*1, inf))), BufFrames.kr(r[13])*Demand.kr(Impulse.kr(~tempo),0,Dseq([0],inf))).clip2(0.2)*[0.01,4,0.1,0.1]};
