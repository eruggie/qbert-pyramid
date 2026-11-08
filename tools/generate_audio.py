#!/usr/bin/env python3
"""Original event synthesis; numerical VID-01 comparison in ARCADE_REVIEW.md.

No reference samples, speech model, copied tune or continuous music.
Only Python's standard library is needed to reproduce the assets.
"""
import hashlib, math, pathlib, struct, wave
ROOT = pathlib.Path(__file__).resolve().parents[1] / 'assets/audio'
RATE = 22050
# Oscillator endpoints are synthesis choices, not estimates of reference f0.
EFFECTS = {
    'jump': (190, 120, .035), 'land': (240, 110, .100),
    'color': (125, 1450, .130), 'fall': (440, 48, .280),
    'contact': (360, 800, .850), 'rescue': (105, 330, 1.100),
    'collect': (490, 230, .450), 'round': (510, 850, 2.750),
    'extra': (1240, 1240, .270), 'lure': (1080, 460, 1.150),
    'stasis_collect': (490, 230, .450), 'stasis_fall': (760, 95, .420),
    'level': (560, 1020, 2.750), 'game_over': (720, 160, .650),
}
# Relative balance: routine motion is below collection/death/lure.
GAINS = {'jump': .045, 'land': .115, 'color': .130, 'fall': .23,
         'contact': .225, 'rescue': .130, 'collect': .190,
         'round': .135, 'extra': .23, 'lure': .230,
         'stasis_collect': .19, 'stasis_fall': .13, 'level': .15, 'game_over': .18}

def samples_for(name, start, end, duration):
    if name in ("fall", "extra"):
        return _unverified_effect_samples(name, start, end, duration)
    phase=0.0; random=0x71ACE; samples=[]
    for i in range(round(duration*RATE)):
        t=i/RATE; ratio=t/duration
        frequency=start+(end-start)*ratio
        pulse=1.0
        envelope=min(1,t/.003)*min(1,(duration-t)/.008)
        if name == 'color':
            # One body followed by a rising terminal sweep, not two clicks.
            frequency=125+1325*ratio**2.2
        elif name == 'rescue':
            # Six ramps, 183 ms apart; fits the existing 1.2 s transport.
            local=(t % (duration/6))/(duration/6)
            frequency=105+65*ratio+165*local
        elif name == 'lure':
            frequency=start+(end-start)*ratio
        elif name == 'contact':
            # Five gated oscillator gestures, no imitation of reference speech.
            local=t%.17
            pulse=min(1,local/.004)*max(0,min(1,(.135-local)/.012))
            frequency=(360+440*(int(t/.17)%3)/2)*(1+.12*math.sin(t*63))
        elif name == 'stasis_collect':
            frequency=490-260*ratio+45*math.sin(t*37)
            pulse=.75+.25*math.cos(t*math.pi*2/.15)
            envelope *= (1-ratio)**.35
        elif name == 'game_over':
            frequency=start*(end/start)**ratio
            pulse=min(1,(t%.1625)/.005)*max(0,min(1,(.135-t%.1625)/.015))
            envelope *= (1-ratio)**.25
        elif name == 'collect':
            frequency=start+(end-start)*ratio+.12*start*math.sin(t*37)
            envelope *= (1-ratio)**.35
        elif name in ('round','level'):
            # Geometric rise, regular gates, then a 630 ms bent tail.
            if t < duration-.63:
                period=.125 if name == 'level' else .10
                local=t%period
                pulse=min(1,local/.003)*max(0,min(1,(period*.8-local)/.020))
                frequency=start*(end/start)**(t/(duration-.63))
            else:
                tail=(t-(duration-.63))/.63
                frequency=690-170*(1-abs(2*tail-1))
        elif name == 'extra':
            local=t%.09
            pulse=max(0,1-local/(.09*.8))
            envelope *= (1-ratio)**.45
        else:
            frequency=round(frequency/18)*18
            envelope *= (1-ratio)**.45
        phase += frequency/RATE
        harmonics=(.42,.19) if name in ('contact','lure') else (.28,.10)
        wave_value=math.sin(2*math.pi*phase)+harmonics[0]*math.sin(6*math.pi*phase)+harmonics[1]*math.sin(10*math.pi*phase)
        if name=='contact':
            random=(1103515245*random+12345)&0x7fffffff
            wave_value=.85*wave_value+.15*(random/0x3fffffff-1)
        samples.append(GAINS[name]*envelope*pulse*wave_value)
    peak=max(map(abs,samples))
    gain=min(1,.31/peak)
    return [round(v*gain*32767) for v in samples]

def _unverified_effect_samples(name, start, end, duration):
    phase=0.0; random=0x71ACE; samples=[]
    for i in range(round(duration*RATE)):
        t=i/RATE; ratio=t/duration
        frequency=round((start+(end-start)*ratio)/18)*18
        if name=='rescue': frequency *= 1.0 if int(t*28)%2==0 else 1.35
        phase += frequency/RATE
        # Limited harmonics approximate an early oscillator without harsh aliasing.
        wave_value=math.sin(2*math.pi*phase)+.28*math.sin(6*math.pi*phase)+.10*math.sin(10*math.pi*phase)
        if name=='contact':
            random=(1103515245*random+12345)&0x7fffffff
            wave_value=.55*wave_value+.45*(random/0x3fffffff-1)
        pulse=1.0
        if name in ('extra','round','color'):
            period={'extra':.09,'round':.08,'color':.0525}[name]
            local=t%period
            pulse=max(0,1-local/(period*.8))
        envelope=min(1,t/.003)*min(1,(duration-t)/.012)*(1-ratio)**.45*pulse
        samples.append(.23*envelope*wave_value)
    peak=max(map(abs,samples))
    gain=min(1,.31/peak)
    return [round(v*gain*32767) for v in samples]

def main():
    ROOT.mkdir(parents=True,exist_ok=True)
    for name, parameters in EFFECTS.items():
        data=samples_for(name,*parameters)
        with wave.open(str(ROOT/(name+'.wav')),'wb') as out:
            out.setparams((1,2,RATE,0,'NONE','not compressed'))
            out.writeframes(struct.pack('<'+'h'*len(data),*data))
    for obsolete in ['menu','menu_music','game_music']:
        for suffix in ['.wav','.wav.import']:
            (ROOT/(obsolete+suffix)).unlink(missing_ok=True)
    (ROOT/'SHA256SUMS.txt').write_text(''.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+p.name+'\n' for p in sorted(ROOT.glob('*.wav'))))
if __name__=='__main__': main()
