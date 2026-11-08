#!/usr/bin/env python3
"""Original low-resolution procedural art. No reference pixels or external assets."""
import pathlib, struct, zlib, math
ROOT = pathlib.Path(__file__).resolve().parents[1] / 'assets/arcade'
W, H = 40, 48

def png(path, w, h, pixels):
    def chunk(kind, data):
        return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind + data) & 0xffffffff)
    raw = b''.join(b'\0' + bytes(pixels[y*w*4:(y+1)*w*4]) for y in range(h))
    path.write_bytes(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('>IIBBBBB', w,h,8,6,0,0,0)) + chunk(b'IDAT', zlib.compress(raw,9)) + chunk(b'IEND',b''))

def rgba(c):
    return tuple(bytes.fromhex(c)) + (255,) if c else (0,0,0,0)

class Sprite:
    def __init__(self): self.data = bytearray(W*H*4)
    def pixel(self,x,y,c):
        if 0<=x<W and 0<=y<H: self.data[(y*W+x)*4:(y*W+x)*4+4] = bytes(rgba(c))
    def rect(self,x,y,w,h,c):
        for yy in range(int(y),int(y+h)):
            for xx in range(int(x),int(x+w)): self.pixel(xx,yy,c)
    def ellipse(self,x,y,rx,ry,c):
        for yy in range(math.floor(y-ry),math.ceil(y+ry)+1):
            for xx in range(math.floor(x-rx),math.ceil(x+rx)+1):
                if ((xx-x)/rx)**2+((yy-y)/ry)**2 <= 1: self.pixel(xx,yy,c)
    def line(self,x0,y0,x1,y1,c,width=1):
        count=max(abs(x1-x0),abs(y1-y0),1)
        for t in range(count+1): self.rect(round(x0+(x1-x0)*t/count),round(y0+(y1-y0)*t/count),width,width,c)
    def poly(self,points,c):
        for y in range(H):
            for x in range(W):
                hit=False
                for a,b in zip(points,points[1:]+points[:1]):
                    if (a[1]>y)!=(b[1]>y) and x<(b[0]-a[0])*(y-a[1])/(b[1]-a[1])+a[0]: hit=not hit
                if hit:self.pixel(x,y,c)

def sprite(kind,direction,pose):
    s=Sprite(); right=direction in (1,3); back=direction<2; f=1 if right else -1
    hop=-2 if pose==1 else 0; squash=2 if pose==2 else 0
    if kind==0:
        # Amber hopper: short wedge muzzle, gold crest and broad two-toed feet.
        for off in [-4,4]:
            s.line(20+off,36+hop,20+off+f*(2 if pose==1 else 0),42+hop,'bd3816',2)
            s.rect(17+off,42+hop,6,2,'ffb52b')
        s.ellipse(20,32+hop+squash,8,9-squash,'8c291c')
        s.ellipse(20,31+hop+squash,7,8-squash,'f16a15')
        s.ellipse(18,29+hop,5,6,'ff9b21')
        s.rect(17,20+hop,3,3,'ffe165'); s.rect(21,19+hop,2,4,'ffe165')
        sy=26+hop if back else 30+hop
        s.poly([(20+f*5,sy-1),(20+f*13,sy+3),(20+f*12,sy+5),(20+f*5,sy+3)],'b93b1b')
        s.poly([(20+f*5,sy-2),(20+f*12,sy+2),(20+f*12,sy+3),(20+f*5,sy+2)],'ffae29')
        for off in ([f*4] if back else [-2,4]):
            s.rect(19+off,24+hop,3,5,'fff4bf'); s.rect(20+off+(1 if right else 0),26+hop,1,2,'231c35')
    elif kind in (1,6):
        base,shade,light = ('ef1736','9c1030','ffe4ca') if kind==1 else ('17c134','0b642c','dcff9a')
        s.ellipse(20,38+hop,7+squash,6-squash,'171728')
        s.ellipse(20,37+hop,7+squash,6-squash,shade)
        s.ellipse(19,36+hop,6+squash,5-squash,base)
        s.rect(16,33+hop,2,2,light); s.rect(18,32+hop,2,1,light)
    elif kind==2:
        # Two separated angular coils and a long neck, not the original Coily drawing.
        lift=4 if pose==1 else (-1 if pose==2 else 0)
        s.line(11,42,18,40,'8e168e',3)
        for cy,rx in [(37,8),(30-lift//2,6)]:
            s.ellipse(20,cy,rx,4,'791479'); s.ellipse(20,cy-1,rx-1,3,'c733cb')
            s.ellipse(20,cy-1,rx-4,1,None)
            s.rect(17,cy+2,7,1,'f58adc')
        s.line(23,30-lift//2,23,22-lift,'b22aba',4)
        s.ellipse(20+f*2,20-lift,7,5,'771077')
        s.ellipse(20+f*2,19-lift,6,4,'d641d1')
        s.rect(18,13-lift,2,3,'fba7ed'); s.rect(22,14-lift,2,2,'fba7ed')
        for off in ([-1,4] if not back else [3*f]):
            s.rect(19+off,17-lift,3,3,'fff2e0'); s.pixel(20+off+f,18-lift,'24182f')
        s.line(20+f*6,22-lift,20+f*10,24-lift,'f7a49b',1)
    elif kind in (3,4):
        f=1 if kind==3 else -1
        for leg in range(3):
            x=16+leg*4; knee=25-leg*2 if pose==1 else 28-leg*2
            s.line(x,34,20+(x-20)*2,knee,'c52bbd',2)
            s.line(20+(x-20)*2,knee,20+(x-20)*2+f*3,knee-4,'f788da',1)
            s.line(x,36,x-f*5,42+hop,'8c167c',2)
            s.line(x-f*5,42+hop,x-f*8,42+hop,'d943c4',2)
        s.ellipse(20-f*3,34+hop,7,6,'a71d99')
        s.ellipse(20-f*3,33+hop,5,4,'e74bce')
        s.poly([(20+f*2,29+hop),(20+f*9,30+hop),(20+f*10,37+hop),(20+f,39+hop)],'d736c2')
        for off in [2,6]:
            s.rect(19+f*off,29+hop,3,5,'fff3de'); s.rect(20+f*off,31+hop,1,2,'201328')
        s.line(20+f*7,37+hop,20+f*10,39+hop,'ffc1e5',2)
    elif kind==5:
        s.rect(13,41+hop,6,3,'087539'); s.rect(22,41+hop,6,3,'087539')
        s.ellipse(20,33+hop+squash,7,10-squash,'095a32')
        s.ellipse(19,32+hop+squash,6,9-squash,'26cd4a')
        s.poly([(16,23+hop),(19,18+hop),(21,23+hop),(24,20+hop),(24,25+hop)],'ffc04a')
        s.rect(14,27+hop,12,6,'16342e')
        for x in [15,22]: s.rect(x,28+hop,3,4,'fff8b9'); s.pixel(x+(2 if right else 0),30+hop,'172527')
        s.rect(18,36+hop,4,2,'91f681')
    return s.data

# Hand-authored compact 5x7 alphabet; generic glyph construction, no copied font file.
GLYPHS = {
    '*':'00000/10101/01110/11111/01110/10101/00000',
'A':'01110/10001/10001/11111/10001/10001/10001','B':'11110/10001/10001/11110/10001/10001/11110',
'C':'01111/10000/10000/10000/10000/10000/01111','D':'11110/10001/10001/10001/10001/10001/11110',
'E':'11111/10000/10000/11110/10000/10000/11111','F':'11111/10000/10000/11110/10000/10000/10000',
'G':'01111/10000/10000/10111/10001/10001/01111','H':'10001/10001/10001/11111/10001/10001/10001',
'I':'111/010/010/010/010/010/111','J':'00111/00010/00010/00010/10010/10010/01100',
'K':'10001/10010/10100/11000/10100/10010/10001','L':'10000/10000/10000/10000/10000/10000/11111',
'M':'10001/11011/10101/10101/10001/10001/10001','N':'10001/11001/11001/10101/10011/10011/10001',
'O':'01110/10001/10001/10001/10001/10001/10001/01110','P':'11110/10001/10001/11110/10000/10000/10000',
'Q':'01110/10001/10001/10001/10101/10010/01101','R':'11110/10001/10001/11110/10100/10010/10001',
'S':'01111/10000/10000/01110/00001/00001/11110','T':'11111/00100/00100/00100/00100/00100/00100',
'U':'10001/10001/10001/10001/10001/10001/01110','V':'10001/10001/10001/10001/10001/01010/00100',
'W':'10001/10001/10001/10101/10101/11011/10001','X':'10001/10001/01010/00100/01010/10001/10001',
'Y':'10001/10001/01010/00100/00100/00100/00100','Z':'11111/00001/00010/00100/01000/10000/11111',
'0':'01110/10001/10011/10101/11001/10001/01110','1':'010/110/010/010/010/010/111',
'2':'01110/10001/00001/00010/00100/01000/11111','3':'11110/00001/00001/01110/00001/00001/11110',
'4':'10010/10010/10010/11111/00010/00010/00010','5':'11111/10000/10000/11110/00001/00001/11110',
'6':'01110/10000/10000/11110/10001/10001/01110','7':'11111/00001/00010/00100/01000/01000/01000',
'8':'01110/10001/10001/01110/10001/10001/01110','9':'01110/10001/10001/01111/00001/00001/01110',
':':'0/1/1/0/1/1/0','-':'00000/00000/00000/11111/00000/00000/00000',
'.':'0/0/0/0/0/1/1','/':'00001/00001/00010/00100/01000/10000/10000',
'!':'1/1/1/1/1/0/1','?':'11110/00001/00010/00100/00100/00000/00100',
'+':'00000/00100/00100/11111/00100/00100/00000',' ':'000/000/000/000/000/000/000',
}

def main():
    ROOT.mkdir(parents=True,exist_ok=True)
    sw,sh=W*12,H*7; sheet=bytearray(sw*sh*4)
    for kind in range(7):
        for direction in range(4):
            for pose in range(3):
                data=sprite(kind,direction,pose); x=(direction*3+pose)*W; y=kind*H
                for row in range(H): sheet[((y+row)*sw+x)*4:((y+row)*sw+x+W)*4]=data[row*W*4:(row+1)*W*4]
    png(ROOT/'actors.png',sw,sh,sheet)
    fw,fh=128,64; pixels=bytearray(fw*fh*4); chars=[]
    for index, code in enumerate(range(32,127)):
        glyph=GLYPHS.get(chr(code).upper(),GLYPHS['?']).split('/')
        x=(index%16)*8; y=(index//16)*10
        width=max(map(len,glyph))
        for yy,line in enumerate(glyph):
            for xx,value in enumerate(line):
                if value=='1': pixels[((y+yy)*fw+x+xx)*4:((y+yy)*fw+x+xx)*4+4]=b'\xff'*4
        chars.append(f'char id={code} x={x} y={y} width={width} height=8 xoffset=0 yoffset=0 xadvance={width+1} page=0 chnl=15')
    png(ROOT/'arcade_font.png',fw,fh,pixels)
    (ROOT/'arcade_font.fnt').write_text('info face="Q*Bert Pyramid Grid" size=8 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1\ncommon lineHeight=10 base=8 scaleW=128 scaleH=64 pages=1 packed=0\npage id=0 file="arcade_font.png"\nchars count=95\n'+'\n'.join(chars)+'\n')
if __name__=='__main__': main()
