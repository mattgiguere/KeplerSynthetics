function reasonable_mass, rpl
;PURPOSE: Although we don't know the actual
;mass, this routine will come up with a reasonable
;one using the average density of Earth, Jupiter, &
;Neptune to construct a rocky planet, gas giant, or
;ice giant, respectively, based on the input radius
;
; 2010.11.24 ~MJG
;

;Make a guess at the size of the planet:

M_earth = 5.974d24 ;kg
r_earth = 6.378d6 ;meters
rsun = 6.955d8 ;meters
rpl *= r_earth

if rpl lt 2d *r_earth then begin
rho = 5515d ;kg m^-3
mpl = 4d / 3d * !dpi * rho * rpl^3d
endif 

if ((rpl ge 2d*r_earth) AND (rpl lt 6d*r_earth )) then begin
rho = 1638d ;kg m^-3
mpl = 4d / 3d * !dpi * rho * rpl^3d
endif 

if rpl ge 6d*r_earth then begin
rho = 1326d ;kg m^-3
mpl = 4d / 3d * !dpi * rho * rpl^3d
endif 

rpl /= rsun

mpl /= m_earth
return, mpl
end;reasonable_mass.pro

pro get_rad_per, i, ntargets, rpl, per, pmin, randomp, randomr
;This will get the random radius and period
;within the desired range:

case 1 of 
  ;RADIUS IS FROM 1 - 1.25 R_EARTH
  (i le 0.1d*ntargets): begin
	 ;1 < rpl < 1.25
	 ;pmin < period < 15d
	 rpl = 0.25d* (*randomr)[i] + 1d
	 per = (15d - pmin)* (*randomp)[i] + pmin
  end
  
  ((i gt 0.1d*ntargets) AND ( i le 0.2*ntargets)): begin
	 ;1 < rpl < 1.25
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 rpl = 0.25d * (*randomr)[i] + 1d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  
  ;RADIUS IS FROM 1.25 - 1.5 R_EARTH
  ((i gt 0.2d*ntargets) AND ( i le 0.3*ntargets)): begin
	 ;1.25 < rpl < 1.5
	 rpl = 0.25d* (*randomr)[i] + 1.25d
	 ;PMIN < period < 15d
	 upperp = 15d & lowerp = pmin
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  ((i gt 0.3d*ntargets) AND ( i le 0.4*ntargets)): begin
	 ;1.25 < rpl < 1.5
	 rpl = 0.25d* (*randomr)[i] + 1.25d
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  ;RADIUS IS FROM 1.5 - 1.75 R_EARTH
  ((i gt 0.4d*ntargets) AND ( i le 0.5*ntargets)): begin
	 ;1.5 < rpl < 1.75
	 rpl = 0.25d* (*randomr)[i] + 1.5d
	 ;PMIN < period < 15d
	 upperp = 15d & lowerp = pmin
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  ((i gt 0.5d*ntargets) AND ( i le 0.6*ntargets)): begin
	 ;1.5 < rpl < 1.75
	 rpl = 0.25d* (*randomr)[i] + 1.5d
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  
  ;RADIUS IS FROM 1.75 - 2 R_EARTH
	 ((i gt 0.6d*ntargets) AND ( i le 0.7*ntargets)): begin
	 ;1.75 < rpl < 2
	 rpl = 0.25d* (*randomr)[i] + 1.75d
	 ;PMIN < period < 15d
	 upperp = 15d & lowerp = pmin
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  ((i gt 0.7d*ntargets) AND ( i le 0.8*ntargets)): begin
	 ;1.75 < rpl < 2
	 rpl = 0.25d* (*randomr)[i] + 1.75d
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  
  ;RADIUS IS FROM 2 - 2.5 R_EARTH
	 ((i gt 0.8d*ntargets) AND ( i le 0.85*ntargets)): begin
	 ;2 < rpl < 2.5
	 rpl = 0.5d* (*randomr)[i] + 2d
	 ;PMIN < period < 15d
	 upperp = 15d & lowerp = pmin
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  ((i gt 0.85d*ntargets) AND ( i le 0.9*ntargets)): begin
	 ;2 < rpl < 2.5
	 rpl = 0.5d* (*randomr)[i] + 2d
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  
  ;RADIUS IS FROM 2.5 - 4 R_EARTH
  ((i gt 0.9d*ntargets) AND ( i le 0.925*ntargets)): begin
	 ;2.5 < rpl < 4
	 rpl = 1.5d* (*randomr)[i] + 2.5d
	 ;PMIN < period < 15d
	 upperp = 15d & lowerp = pmin
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  ((i gt 0.925d*ntargets) AND ( i le 0.95*ntargets)): begin
	 ;2.5 < rpl < 4
	 rpl = 1.5d* (*randomr)[i] + 2.5d
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
  
  
  ;RADIUS IS FROM 4 - 12 R_EARTH
  ((i gt 0.95d*ntargets) AND ( i le 0.975*ntargets)): begin
	 ;4 < rpl < 12
	 rpl = 8d* (*randomr)[i] + 4d
	 ;PMIN < period < 15d
	 upperp = 15d & lowerp = pmin
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end

  (i gt 0.975d*ntargets): begin
	 ;4 < rpl < 12
	 rpl = 8d* (*randomr)[i] + 4d
	 ;15d < period < 3yr
	 upperp = 3d * 365d & lowerp = 15d
	 per = (upperp - lowerp)* (*randomp)[i] + lowerp
  end
endcase

end ;get_rad_per.pro

pro drive_synthetics, $
istart=istart, iend=iend, $
runnum=runnum


;PURPOSE: To generate all of the synthetic lightcurves for the
;PlanetHunters project. This is the final version just before
;launch
;
;OPTIONAL KEYWORDS:
;
;ISTART: The initial starting value (handy if running on
;multiple processors
;
;IEND: The final starting value  (handy if running on
;multiple processors
;
;RUNNUM: After having a hell of a time working with
;calling the same file from multiple machines (it kept
;saying it has reached the end of the file when there
;were still plenty of files to run) I decided to break
;the target list up into 15 different randomly created
;lists. I used the routine BREAKTARGETARRAYS.PRO for 
;this. Just enter a run number between 1 and 15 for 
;whatever machine you want to work on and it will 
;use a list just for that run.
;
; 2010.11.23 ~MJG
;

r_earth = 6.378d6 ;meters
Rsun = 6.955d8 ;meters
msun = 1.989d30 ;kg
Gnewt = 6.673d-11 ;N m^2 kg^-2
syn_flag=0

if ~keyword_set(runnum) then begin
  ;restore the IDL SAVE file that contains
  ;an array listing all of the targets:
  restore, '~/idl/kepler/allq1targets.dat'
  
  ;create a variable named remaining targets
  ;that will slowly loose it's elements as this
  ;routine goes on:
  rq1tfn = '~/idl/kepler/remainingq1targets.dat'
  restore, rq1tfn
endif else begin
  case runnum of
	 1: fnmrn = '~/idl/kepler/remainingtargets1.dat'
	 2: fnmrn = '~/idl/kepler/remainingtargets2.dat'
	 3: fnmrn = '~/idl/kepler/remainingtargets3.dat'
	 4: fnmrn = '~/idl/kepler/remainingtargets4.dat'
	 5: fnmrn = '~/idl/kepler/remainingtargets5.dat'
	 6: fnmrn = '~/idl/kepler/remainingtargets6.dat'
	 7: fnmrn = '~/idl/kepler/remainingtargets7.dat'
	 8: fnmrn = '~/idl/kepler/remainingtargets8.dat'
	 9: fnmrn = '~/idl/kepler/remainingtargets9.dat'
	 10: fnmrn = '~/idl/kepler/remainingtargets10.dat'
	 11: fnmrn = '~/idl/kepler/remainingtargets11.dat'
	 12: fnmrn = '~/idl/kepler/remainingtargets12.dat'
	 13: fnmrn = '~/idl/kepler/remainingtargets13.dat'
	 14: fnmrn = '~/idl/kepler/remainingtargets14.dat'
	 15: fnmrn = '~/idl/kepler/remainingtargets15.dat'
  endcase
  restore, fnmrn
  q1targets = remaining_targets
endelse

;the total number of targets:
ntargets = n_elements(q1targets)
perarr = dblarr(ntargets)
rplarr = dblarr(ntargets)
badfiles = dblarr(ntargets)
randomp = randomu(18, ntargets)
randomr = randomu(42, ntargets)
prandp = ptr_new(randomp)
prandr = ptr_new(randomr)
res=0

if ~keyword_set(istart) then i=0L else i=istart
if ~keyword_set(iend) then iend = ntargets
while (i lt iend) do begin

print, '**************************************'
print, 'i',strt(runnum),' is now:', i
print, '**************************************'

;now draw a random element that will be removed
;from the remaining_targets array. There was a problem
;with some of the files, where they only contained
;one element for barytime, timecorr and cadence #
;and everything else was -Inf:
  fname = remaining_targets[i]
exists = check_syn_exists(fname)
print, fname, ' exists? ', exists
  
if ~exists then begin
  ;the short fname for later use. fname will be overwritten
  ;by read_kepler in a few lines
  fnames = fname
  res = read_kepler(fname=fname, header=header, head0=head0, res0=res0)
  

;There are some junk files within the Q1 data release. 
;(There's only 1 flux element that's -Inf)
;This will skip those files:
if size(res, /type) eq 8 then begin

rst = sxpar(head0, 'RADIUS')
logg = sxpar(head0, 'LOGG')

;calculate the minimum orbital period if the radius
;of the star is provided in the header file:
if rst gt 0 then begin
print, 'logg is: ', logg
;The factor of 100 is to convert to m / s^-2 from 
;the cgs cm / s^2 which is what log g is usually
;written in terms of:
Mst = 10^logg* rst^2*rsun^2 / Gnewt / 100d
pmin = 2d *!dpi * rst^1.5*rsun^1.5 / sqrt(Gnewt * Mst)
pmin /= (24d * 3600d) ;convert to days
pmin *= 2d ;a bit of a buffer to avoid NaNs
mst /= msun ;convert to solar masses
endif else begin
mst = 1d
rst = 1d
pmin = 0.7d
endelse

get_rad_per, i, ntargets, rpl, per, pmin, prandp, prandr
PRINT, 'THE RADIUS IS: ', rpl
print, 'THE PERIOD IS: ', per
print, 'THE MIN PERIOD IS: ', pmin
print, '**************************************'

perarr[i] = per
rplarr[i] = rpl

mpl = reasonable_mass(rpl)

if per lt pmin then stop
outputarray = $
nolimbd_transit(rpl=rpl, rst=rst, $
period=per, $
mpl=mpl, $
mst=mst, $
timearray=res.barytime, $
/randomphase, $
syn_flag=syn_flag)

normkepflux = res.ap_corr_flux / median(res.ap_corr_flux)
!p.multi=[0,1,3]
plot, res.barytime - min(res.barytime), $
normkepflux, xtitle='Days From Beginning of Quarter', $
ytitle='Relative Flux', /ysty, $
title='Original', ps=8

synthetickepflux = normkepflux*outputarray
plot, res.barytime - min(res.barytime), $
synthetickepflux, xtitle='Days From Beginning of Quarter', $
ytitle='Relative Flux', /ysty, $
title='With Synthetic', ps=8

plot, res.barytime - min(res.barytime), $
synthetickepflux - normkepflux, $
xtitle='Days From Beginning of Quarter', $
ytitle='Difference', /ysty, $
title='Difference', ps=8


synth_struct = create_struct($
'barytime', res.barytime      , $
'timcorr', res.timcorr       , $
'cadence_number', res.cadence_number, $
'ap_cent_row', res.ap_cent_row   , $
'ap_cent_r_err', res.ap_cent_r_err , $
'ap_cent_col', res.ap_cent_col   , $
'ap_cent_c_err', res.ap_cent_c_err , $
'ap_raw_flux', res.ap_raw_flux   , $
'ap_raw_err', res.ap_raw_err    , $
'ap_corr_flux', res.ap_corr_flux  , $
'ap_corr_err', res.ap_corr_err   , $
'ap_ins_flux', res.ap_ins_flux   , $
'ap_ins_err', res.ap_ins_err    , $
'dia_raw_flux', res.dia_raw_flux  , $
'dia_raw_err', res.dia_raw_err   , $
'dia_corr_flux', res.dia_corr_flux , $
'dia_corr_err', res.dia_corr_err  , $
'dia_ins_flux', res.dia_ins_flux  , $
'dia_ins_err', res.dia_ins_err   , $
'synthetic_flux', synthetickepflux, $
'transit_flag_arr', syn_flag )

head0o = head0
h0el = n_elements(head0)
head0 = [head0o[0:(h0el - 2)], $
"SYNTHETC= 'TRUE    '           / A synthetic planet has been added", $
'PLRAD   =                 '+strt(rpl*rsun/r_earth, f='(F7.2)')+$
' / Synthetic planet radius (R_EARTH)', $
'PLPER   =                 '+strt(per, f='(F9.2)')+$
' / Synthetic planet period (days)', $
head0o[h0el-1]]

fnamesl = strlen(fnames)
fnamesbeg = strmid(fnames, 0, fnamesl-5)
fdir = '/kepler/synthetics/fits/'
fitsnm = fdir+fnamesbeg+'_syn.fits'

mwrfits, res0, fitsnm, head0, /create
mwrfits, synth_struct, fitsnm, header

;timearr=res.barytime - min(res.barytime)
;binkepler, timearr, synthetickepflux, newspline
;keplerBLS, timearr=timearr, fluxarr=newspline, $
;postplot=postplot, filename=fname
endif else badfiles[i] = 1d
;stop
endif;check_syn_exists()
syn_flag=0
res=0
i++
endwhile; remaining_targets > 0
foutp = nextname('~/idl/kepler/drive_synth_output')
save, /all, filename=foutp
stop
end ;drive_synthetics.pro