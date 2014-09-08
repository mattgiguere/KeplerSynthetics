pro add_synthetic, $
fname=fname, $
rpl=rpl, $
rst=rst, $
per=per, $
inc=inc, $
mpl=mpl, $
mst=mst, $
phase=phase, $
hd209458=hd209458, $
output=output, $
timebaseline=timebaseline, $
postplot=postplot

;PURPOSE: To restore the kepler data, add a synthetic
;	transit signal, save the result to a FITS file and
;	optionally plot the synthetic LC. 
;
;INPUT:
;	fname: the filename
;	Rpl: the radius of the planet (in Earth radii)
;	Rst: the radius of the star (in solar radii)
;	PER: the orbital period (in days)
;	INC: the orbital inclination (in degrees)
;	Mpl: the mass of the planet (in earth masses)
;	Mst: the mass of the star (in solar masses)
;	timebaseline: The timebaseline of the Kepler
;		data to calculate the synthetic lightcurve for
;
;OPTIONAL INPUT:
;	phase: changes the start point of the curve (0 - 1)
;	hd209458: uses this system to test the output values
;
;OPTIONAL OUTPUT:
;	output: the normalized lightcurve
;
; c. 2010.09.06 ~MJG
; 2014.07.10 ~MJG heavily modified to work with latest lightcurves

REARTH = 6.371d6 ;meters
RSUN = 6.955d8 ;meters

loadct, 39, /silent
plotdir = '/raw/kepler/synplots/'

res = readKeplerLC(fname=fname, header=header, head0=head0, /noplot, res0=res0)
nelres = n_elements(res)
print, '# el in res is: ', nelres

rpl_init = rpl
if ~keyword_set(rst) then begin
    rst = sxpar(head0, 'RADIUS')
endif else begin
	print, 'R STAR WAS INPUT. THE VALUE BEING USED IS: '
	print, rst, 'R_SUN.'
endelse

print, 'rst is: ', rst
if keyword_set(phase) then print, 'phase is: ', phase
rndmamp = max(res.time) - min(res.time) - 30d
res_original = res
rpl_original = rpl
rst_original = rst


;This section of code (the repeat begin...endrep until loop)
;will handle problems due to synthetic transits falling 
;within gaps. 

;define what fraction of transits falling into gaps is acceptable:
fracgaps = 0.3

gaptrial = 0
repeat begin
	print, 'Gap trial is now: ', gaptrial
	;reset the input parameters:
	res = res_original
	rpl = rpl_original
	rst = rst_original
	;now choose a new random starting time:
	starttime = rndmamp * randomu(seed)
	print, 'starttime is: ', starttime
	startel = where(res.time gt starttime + min(res.time))
	startel = startel[0]
	endel = where(res.time ge res[startel].time + 30d)
	endel = endel[0]
	;figure out the timebaseline (in minutes) to feed to gen_synthetic:
	timebaseline= (res[endel].time - res[startel].time)*24d * 60d

	;now chop the "res" structure for the remainder of this program:
	res = res[startel:endel]
	nelres = n_elements(res)

	;the time (in minutes) between observations:
	timestep = (max(res.time) - min(res.time))/nelres * 24d * 60d

	;Set the phase to zero. This will make gen_synthetic randomly
	;set the phase, yet still allow it to be extracted for 
	;superimposing on the plot and saving to the FITS header.
	phase = 0
	
	;Generate the synthetic transit using GEN_SYNTHETIC.PRO:
	gen_synthetic, $
	rpl=rpl, $
	rst=rst, $
	per=per, $
	phase=phase, $
	output=output, $
	timebaseline=timebaseline


	nbnndout = dblarr(nelres)
	;this will bin the gen_synthetic output to be the same 
	;length as the ~29.4 minute kepler observations:
	for i=0LL, nelres-1d do begin 
	nbnndout[i] = total(output[floor(i*timestep): floor((i+1)*timestep)-1L])/(floor((i+1)*timestep) - floor(i*timestep))
	endfor

	;now to list the spots where the transit occurs:
	lowspots = where(nbnndout lt 1d)
	beglow = lowspots[0]
	lowarr = nbnndout lt 1d

	kepflux = res.pdcsap_flux
	normkepflux = kepflux/max(kepflux)

	;find the gaps in the data:
	gaps = ~finite(kepflux)
	gapnans = where(gaps eq 1)

	;create an array of ones for plotting purposes:
	gapspots = dblarr(total(gaps)) + median(normkepflux)
	
	;figure out which transit elements fall in gaps
	numInGaps = lowarr * gaps

	;now calculate the actual fraction of transit elements
	;that fall within the gaps in the data:
	fracInGaps = total(numInGaps) / total(lowarr)
	print, 'fracInGaps: ', fracInGaps
	gaptrial++

endrep until fracInGaps lt fracgaps

;find the final element of the 1st transit:
il = 1
while (il lt n_elements(lowspots)-1) and (lowspots[il]-1L eq lowspots[il-1]) do begin
il++
endwhile
print, 'lowspots[il]: ', lowspots[il]
print, 'lowspots[il-1L]: ', lowspots[il-1L]
endlow = lowspots[il-1L]

if keyword_set(postplot) then begin
	!p.charthick=3
	!p.thick=3
	postnamesyn = nextnameeps(plotdir+'JustSynthetics', /nosuf, /silent)
	ps_open, postnamesyn, /encaps, /col
endif
plot, res.time, nbnndout, $
xtitle='Time', /xsty, $
ytitle='Normalized Flux', /yst, $
yra=[min(nbnndout)^2d, 1], ps=8

oplot, res[lowspots].time, nbnndout[lowspots], ps=8, col=250
if keyword_set(postplot) then begin
	ps_close
endif

normerr = res.pdcsap_flux_err/max(kepflux[where(finite(kepflux))])

origkepflux = kepflux
orignormkeplflux = kepflux/median(origkepflux)

;inject transit event(s):
kepflux *= nbnndout
normkepflux = kepflux/median(origkepflux)

;stop
!p.charthick=1
!p.thick=1

if keyword_set(postplot) then begin
	postname = nextnameeps(plotdir+'SyntheticsAndLC', /nosuf, /silent)
	ps_open, postname, /encaps, /color
endif

timearr = res.time - min(res.time)
minmaxyra = [0.999*min(normkepflux[where(finite(normkepflux))]), $
			1.001d*max(normkepflux[where(finite(normkepflux))])]
plot, timearr, normkepflux, ps=8, /xsty, $
xtitle = 'Days from Beginning of Segment', $
ytitle = ' Normalized Flux', /yst, yra=minmaxyra, symsize=0.25, /nodata

oplot, timearr, orignormkeplflux, ps=8, color=120
oplot, timearr, normkepflux, ps=8, color=0

;oploterr, timearr, normkepflux, normerr, 3
oploterr, timearr, normkepflux, normerr, 8
oplot, timearr, normkepflux, ps=8

oplot, timearr[lowspots], normkepflux[lowspots], ps=8, col=250

xyouts, 0.2, 0.2, 'R_st (in R_sun): '+ $
strt(rst/rsun, f='(F5.2)'), /norm

xyouts, 0.2, 0.17, 'radius_pl (in R_earth): '+ $
strt(rpl/REARTH, f='(F4.1)'), /norm

xyouts, 0.2, 0.14, 'period (days): '+ $
strt(per, f='(F8.2)'), /norm

if keyword_set(phase) then begin
xyouts, 0.2, 0.11, 'phase: '+ $
strt(phase, f='(F8.2)'), /norm
endif



if keyword_set(postplot) then begin
	ps_close
endif

head0o = head0
h0el = n_elements(head0)
head0 = [head0o[0:(h0el - 2)], $
head0o[h0el-1]]

;filename with no directory:
fnamesplit = strsplit(fname, '/', /extract)
fnamend = fnamesplit[-1]
print, fnamend
fnamenofits = strmid(fnamend, 0, strlen(fnamend)-5)
fdir = '/raw/kepler/synthetics/'
fitsnm = nextname(fdir+'synthetic','.fits')

;now overwrite the pdcsap_flux and pdcsap_flux_err with the 
;synthetic information:
res.pdcsap_flux = normkepflux
res.pdcsap_flux_err = normerr

fxaddpar, head0, 'SYNTHTIC', 'TRUE', 'A synthetic planet has been added'
fxaddpar, head0, 'PLRAD', strt(rpl_init, f='(F8.3)'), 'Synthetic planet radius (R_EARTH)'
fxaddpar, head0, 'PLPER', strt(per, f='(F10.3)'), 'Synthetic planet period (days)'
fxaddpar, head0, 'PLPHASE', strt(phase, f='(F10.4)'), 'Transit phase'
fxaddpar, head0, 'TRANELS', strt(beglow)+':'+strt(endlow), 'Elements with 1st transit event'
				
mwrfits, res0, fitsnm, head0, /create
mwrfits, res, fitsnm, header

end add_synthetic.pro