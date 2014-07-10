;+
;
;  NAME: 
;     readKeplerLC
;
;  PURPOSE: 
;		To read in the Kepler lightcurves from the new path location.
;		This is the way all lightcurves should be read in post-20140709,
;		which is the date I started the download to get all the up-to-date
;		lightcurves and target_pixel_files.
;
;  CATEGORY:
;      PLANET HUNTERS
;
;  CALLING SEQUENCE:
;      readKeplerLC
;
;  INPUTS:
;
;  OPTIONAL INPUTS:
;
;  OUTPUTS:
;	RES: A structure containing the following 20 tags:
; This information is from the Kepler Data Archive Site:
;http://archive.stsci.edu/kepler/manuals/ArchiveManualNewFormat.pdf
;
;Col #. Tag [Units]: Description
;1. TIME [days (kepler BJD)]: Barycentric Julian Day calculated for
;	the target in the file
;2. TIMECORR [days]: Barycentric correction minus time slice correction
;	 applied to the time
;3. CADENCENO []: Unique cadence number
;4. SAP_FLUX [e-/s]: Raw aperture photometry flux
;5. SAP_FLUX_ERR [e-/s]: Raw aperture photometry error
;6. SAP_BKG [e-/s]: Background flux in optimal aperture
;7. SAP_BKG_ERR [e-/s]: Background error in optimal aperture
;8. PDCSAP_FLUX [e-/s]: Aperture photometry flux after pre-search data
;	 conditioning (AKA corrected flux)
;9. PDCSAP_FLUX_ERR [e-/s]: Aperture photometry error after Pre-search
;		Data Conditioning (ARA corrected error)
;10. SAP_QUALITY []: Bit flags indicating when data phenomena occur
;11. PSF_CENTR1 [px]: PSF-fitted column centroid
;12. PSF_CENTR1_ERR [px]: PSF-fitted column error
;13. PSF_CENTR2 [px]: PSF-fitted row centroid
;14. PSF_CENTR2_ERR [px]: PSF-fitted row error
;15. MOM_CENTR1 [px]: Moment-derived column centroid
;16. MOM_CENTR1_ERR [px]: Moment-derived column error
;17. MOM_CENTR2 [px]: Moment-derived row centroid
;18. MOM_CENTR2_ERR [px]: Moment-derived row error
;19. POS_CORR1 [px]: Column position correction based on bright stars
;20. POS_CORR2 [px]: Row position correction based on bright stars
;  OPTIONAL OUTPUTS:
;	set the head0 or header keywords to get the FITS header information
;	for the 0th extension or 1st extension, respectively.
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      	res = readKeplerLC(fname='/my/path/kplr0054...fits', $
;							head0=headerExt0, $
;							header=headerExt1, /noplot)
;		plot, res.time, res.sap_flux, ps=8
;		print, headerExt0
;		print, headerExt1
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2014.07.14 10:49:12
;
;-
function readKeplerLC, $
help = help, $
postplot = postplot, $
fname = fname, $
header = header, $
head0 = head0, $
noplot = noplot

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5

if keyword_set(help) then begin
	print, '*************************************************'
	print, '*************************************************'
	print, '        HELP INFORMATION FOR ddocu_text'
	print, 'KEYWORDS: '
	print, ''
	print, 'HELP: Use this keyword to print all available arguments'
	print, ''
	print, ''
	print, ''
	print, '*************************************************'
	print, '                     EXAMPLE                     '
	print, "IDL>"
	print, 'IDL> '
	print, '*************************************************'
	stop
endif


print, '*************************************************'
print, 'The filename is: '
print, fname
print, '*************************************************'

;this loop is meant to handle temporarily dropped NFS mounts:
x = file_info(fname)
while (~x.exists OR size(res1, /type) eq 0) do begin
  print, 'read_kepler while'
  res0 = mrdfits(fname[0], 0, head0)
  res1 = mrdfits(fname[0], 1, header)
  x = file_info(fname)
  wait, 0.25
endwhile

if ~keyword_set(noplot) then begin
	if keyword_set(postplot) then begin
	   fn = nextnameeps('plot')
	   thick, 2
	   ps_open, fn, /encaps, /color
	endif
	plot, res1.time, res1.pdcsap_flux, ps=8, /ysty, /xsty, xtitle='Time', ytitle='Flux'
	oploterr, res1.time, res1.pdcsap_flux, res1.pdcsap_flux_err, 8
	if keyword_set(postplot) then begin
	   ps_close
	endif
endif;~KW(noplot)

return, res1
;stop
end;readKeplerLC.pro