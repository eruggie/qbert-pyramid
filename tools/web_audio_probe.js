// Test instrumentation only: measure the actual outgoing WebAudio waveform.
(() => {
 const probe = window.audioProbe = { contexts: [], peak: 0, samples: 0 };
 const connect = AudioNode.prototype.connect;
 AudioNode.prototype.connect = function(target, ...args) {
  const result = connect.call(this, target, ...args);
  if (target instanceof AudioDestinationNode && this.context.qbertAnalyser) {
   connect.call(this, this.context.qbertAnalyser);
  }
  return result;
 };
 const Base = window.AudioContext;
 window.AudioContext = class extends Base {
  constructor(...args) {
   super(...args);
   this.qbertAnalyser = this.createAnalyser();
   this.qbertAnalyser.fftSize = 2048;
   probe.contexts.push(this);
  }
 };
 setInterval(() => {
  for (const context of probe.contexts) {
   const samples = new Float32Array(2048);
   context.qbertAnalyser.getFloatTimeDomainData(samples);
   for (const value of samples) probe.peak = Math.max(probe.peak, Math.abs(value));
   probe.samples++;
  }
 }, 10);
})();
