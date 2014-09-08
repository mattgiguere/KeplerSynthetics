pro gen_synthetic, $
doplot=doplot, $
rpl=rpl, $
rst=rst, $
per=per, $
inc=inc, $
limbd = limbd, $
mpl=mpl, $
mst=mst, $
phase=phase, $
hd209458=hd209458, $
output=output, $
timebaseline=timebaseline, $
ncmplttrnst=ncmplttrnst
;PURPOSE: TO generate a synthetic transit signal to Kepler data. 
;
;INPUT:
;	Rpl: the radius of the planet (in Earth radii)
;	Rst: the radius of the star (in solar radii)
;	PER: the orbital period (in days)
;	INC: the orbital inclination (in degrees)
;  LIMBD: the limb darkening factor. 
;	Mpl: the mass of the planet (in earth masses)
;	Mst: the mass of the star (in solar masses)
;	timebaseline: The timebaseline (in minutes) of the Kepler
;		data to calculate the synthetic lightcurve for
;
;OPTIONAL INPUT:
;	phase: changes the start point of the curve (0 - 1). WARNING! If
;		you set the phase exactly to zero IDL think you did NOT
;		set the keyword and will reassign the phase to a uniform
;		random number between 0 and 1.
;
;	hd209458: uses this system to test the output values
;
;	ncmplttrnst: set this if you do NOT care if at least 1 
;	complete transit will be within the lightcurve. NOT setting 
;	this puts a further constraint on the. For example
;	if your transit is one hour long and you only have ten hours of
;	data, NOT setting the incompletetransit will make the phase no greater
;	than 0.9.
;
;OPTIONAL OUTPUT:
;	output: the normalized lightcurve
;
;c. 2010.09.05 ~MJG


if ~keyword_set(rpl) then rpl = 1d
if ~keyword_set(rst) then rst = 1d
if ~keyword_set(per) then per = 15d
if ~keyword_set(inc) then inc = 90d
if ~keyword_set(limbd) then limbd=0.6d


;adjust mass of planet:
if ~keyword_set(mpl) then begin
	;Power law index from Lissauer et al. 2011 ApJ 187, 8
	mpl = rpl^2.06d
endif

;roughly based on Gray OASP Book Appendix B:
if ~keyword_set(mst) then mst = rst

if ~keyword_set(phase) then phase = randomu(seed)

print, 'rpl is: ', rpl
print, 'rst is: ', rst
print, 'per is: ', per
print, 'mpl is: ', mpl
print, 'mst is: ', mst
print, 'inc is: ', inc
print, 'phase is: ', phase

;test with the 209458 values:
if keyword_set(hd209458) then begin
  rpl = 1.4*11.209d
  rst = 1.2d
  per = 3.524739d
  inc = 87.1d
  mpl = 0.64d * 318d
  mst = 1d
endif


;Constants
Gnewt = 6.67428d-11 ;m^3 kg^-1 s^-2
RSUN = 6.955d8 ;meters
MSUN = 1.9891d30 ;kg
REARTH = 6.371d6 ;meters
MEARTH = 5.9736d24 ;kg
day2sec = 3600d * 24d

rpl *= rearth
mpl *= mearth
rst *= rsun
mst *= msun
psecs = per*day2sec

inc *=!dtor

amaj = (psecs^2/ (4d *!dpi) * Gnewt * (mpl + mst))^(1d / 3d)

if ~keyword_set(timebaseline) then nelwhole = 1d4 else nelwhole = $
timebaseline
flux = dblarr(nelwhole)+1d

depth = (Rpl/Rst)^2

;the total duration (from contact point 1 to 4):
innernum = (1d + (rpl/rst))^2d - (amaj/rst*cos(inc))^2d
innerden = 1d - cos(inc)^2d
t_tot = psecs / !dpi * asin(Rst/amaj*(innernum/innerden)^0.5d)

;the transit duration completely within the disk (from contact
;point 2 to 3):
lowercrud = (innernum)^0.5d
uppercrud = ((1d - (rpl/rst))^2d - (amaj/rst*cos(inc))^2d)^0.5d
t_com = psecs/!dpi*asin(sin(t_tot*!dpi/psecs)*uppercrud/lowercrud)

print, 'the depth of transit is: ', depth
print, 'the total duration is: ', t_tot/3600d
print, 'the complete duration is: ', t_com/3600d

neltr = round(t_tot/60d)
nelwing = round((t_tot - t_com)/2d / 60d)
leftwing= 1d -  depth*dindgen(nelwing+1d)/nelwing
rightwing = (1d - depth) + depth*dindgen(nelwing+1d)/nelwing
trnstcrv = [leftwing, dblarr(t_com/60) + (1d - depth), rightwing]
neltrnst = n_elements(trnstcrv)

;check to make sure complete transit fits
;within the lightcruve:
if ~keyword_set(incompletetransit) then begin
	fraction = neltrnst / (psecs/60d)
	if phase gt (1d - fraction) then phase = (1d - fraction)
	
	;now to handle long-period events and ensure the transit
	;falls within the lightcurve:
	if phase*psecs/60 gt nelwhole-neltrnst then $
		phase = (nelwhole - neltrnst)/(psecs/60d)*randomu(seed)
	
	print, 'New Phase is: ', phase
endif;KW(incompletetransit)

start=phase*psecs/60d

;now loop over adding repeated transit events:
while start lt nelwhole do begin
	;make sure we're not indexing beyond the last element of flux:
	if ((start + neltrnst -1) lt n_elements(flux)) then begin
		flux[start:(start + neltrnst-1)] *= trnstcrv
	endif else begin
		;if we're not capturing egress completely, handle it:
		lenfx = n_elements(flux)
		trnstlen = lenfx - start
		flux[start:*] *= trnstcrv[0:trnstlen]
	endelse
  start += psecs/60d
endwhile

if keyword_set(doplot) then begin
window, /free
!p.multi=[0,1,1]

plot, trnstcrv, ps=8, /ysty, yra=[(1d - depth)*.999, 1]

plot, dindgen(timebaseline), flux, $
xtitle='Time (minutes since start)', $
ytitle='Normalized Flux', /yst, $
yra=[(1d - 2d*depth), 1], ps=8
endif

output=flux
;stop

;phsd = dindgen(timebaseline) mod (5d * 60d * 24d)
;plot, phsd, flux, /yst, $
;yra=[(1d - 2d*depth), 1], ps=8, $
;xtitle='phase folded'

;stop
end;gen_synthetic.pro