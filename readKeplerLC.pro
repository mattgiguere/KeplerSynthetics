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
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;      readKeplerLC
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

stop
if keyword_set(postplot) then begin
   fn = nextnameeps('plot')
   thick, 2
   ps_open, fn, /encaps, /color
endif
plot, res1.time, res1.pdcsap_flux, ps=8, /ysty, /xsty
oploterr, res1.time, res1.pdcsap_flux, res1.pdcsap_flux_err, 8
if keyword_set(postplot) then begin
   ps_close
endif

return, res1
;stop
end;readKeplerLC.pro