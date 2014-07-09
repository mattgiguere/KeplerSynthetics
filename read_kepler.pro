function read_kepler, $
fname=fname, $
header=header, $
head0=head0, $
res0=res0, $
fdir=fdir, $
noplot=noplot, $
q1=q1, $
q2=q2

;PURPOSE: To read in the kepler light curves
;
;KEYWORDS:
;	FNAME: The file name of the light curve you would like to use. 
;
; 20100810 ~M. Giguere
; 20110304: Added Q2 keyword ~MJG
;		

if ~keyword_set(fname) then begin
fname = '000757099'
print, 'FILENAME WAS NOT SET!!'
STOP
endif

if strlen(fname) le 36 then begin
	if strlen(fname) lt 10 then fnamei=strt(long(fname), f='(I09)') else fnamei = strmid(fname, 4, 9)
	fname = 'kplr'+fnamei+'-2009166043257_llc.fits'
endif else fnamei = strmid(fname, 22, 9)

x = file_info(fname)

if keyword_set(q1) then begin
if ~keyword_set(fdir) then fdir = '/kepler/Q1_public/'

if ~x.exists then begin
x = file_info(fdir+fname)
if x.exists then fname=fdir+fname
endif

x = file_info(fname)
while (~x.exists OR size(res1, /type) eq 0) do begin
  print, 'read_kepler while'
  res0 = mrdfits(fname[0], 0, head0)
  res1 = mrdfits(fname[0], 1, header)
  y = file_info(fdir)
  x = file_info(fname)
  wait, 0.25
endwhile

fins = where(finite(res1.ap_corr_flux) gt 0)
res1 = res1[fins]
res = res1
endif;KW:q1

if keyword_set(q2) then begin
  fdir2 = '/kepler/Q2_public/'
  fname2i = 'kplr'+fnamei+'-2009259160929_llc.fits'
  fname2 = fdir2+fname2i
  res0_2 = mrdfits(fname2, 0, head0)
  res2 = mrdfits(fname2, 1, header)
  res = res2
endif

if keyword_set(q1) and keyword_set(q2) then begin
  res = [res1, res2]
endif

timearr = res.barytime
if n_elements(timearr) gt 1 then begin
if ~keyword_set(noplot) then begin
fluxarr = res.ap_corr_flux
plot, timearr, fluxarr/max(fluxarr), ps=8, $
/yst, yran=minmax(fluxarr/max(fluxarr)), $
xtitle='Barytime', $
ytitle='Normalized Flux'
endif;plot
endif else res = 0


return, res
end;read_kepler.pro