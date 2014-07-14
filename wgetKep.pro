;+
;
;  NAME: 
;     wgetKep
;
;  PURPOSE: To download the lightcurves using wget. Without
;	specifying a "decade" it will download everything. If you
;	do specify a decade it will only download files where the
;	first four numbers of the Kepler ID belong to that decade. 
;	One can also specify the first 4 characters of the Kepler
;	ID to winnow down the download sample even more using the
;	firstFour keyword. See examples below.
;
;  CATEGORY:
;      Kepler
;
;  CALLING SEQUENCE:
;
;      wgetKep
;
;  INPUTS:
;
;  OPTIONAL INPUTS:
;		DECADE: Only download KIC Numbers that have the first 
;	four numbers belonging to the input decade. For example, 
;
;		IDL>wgetKep, decade=6
;
;	will download files from kplr0060* - kplr0069*
;
;		FIRSTFOUR: Only download KIC Numbers that have the first
;	four numbers belonging to the input firstfour. E.g.
;
;		IDL>wgetKep, firstfour=0089
;
;	will download all files beginning with kplr0089
;
;		KIC: download all files for the given KIC number.
;
;  OUTPUTS:
;
;  OPTIONAL OUTPUTS:
;
;  KEYWORD PARAMETERS:
;    
;  EXAMPLE:
;	To get all files with KICs beginning with kplr0103:
;      IDL>wgetKep, firstfour=0103
;	To get all files with KICs beginning with kplr006:
;		IDL>wgetKep, decade=6
;	To download ALL lightcurves (warning, this takes days):
;		IDL>wgetKep
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2014.07.14 10:18:28
;
;-
pro wgetKep, $
decade=decade, $
firstfour=firstfour, $
kic = kic

if keyword_set(kic) then begin
	kic = strt(kic, f='(I09)')
	print, 'KIC is: ', kic
	ff = strmid(kic, 0, 4)
	spawn, "wget -nH --cut-dirs=5 "+$
	"--directory-prefix=/raw/kepler/lightcurves/"+ff+"/"+kic+"/"+$
	" -r -l0 -c -N -np -R 'index*' -erobots=off "+$
	"http://archive.stsci.edu/pub/kepler/lightcurves/"+ff+"/"+kic+"/"
	if file_test('/raw/kepler/lightcurves/'+ff+'/'+kic+'/'+kic) then begin
		spawn, 'rm -rf /raw/kepler/lightcurves/'+ff+'/'+kic+'/'+kic
	endif
	
endif;KW(firstfour)

if keyword_set(firstfour) then begin
	ff = strt(firstfour, f='(I04)')
	spawn, "wget -nH --cut-dirs=4 --directory-prefix=/raw/kepler/lightcurves/"+ff+"/ -r -l0 -c -N -np -R 'index*' -erobots=off http://archive.stsci.edu/pub/kepler/lightcurves/"+ff+"/"
endif;KW(firstfour)

if keyword_set(decade) then begin
	;convert the input decade into a string:
	decade = str(decade, f='(I03)')
	for i=0, 9 do begin
		spawn, "wget -nH --cut-dirs=4 --directory-prefix=/raw/kepler/lightcurves/"+decade+strt(i)+"/ -r -l0 -c -N -np -R 'index*' -erobots=off http://archive.stsci.edu/pub/kepler/lightcurves/"+decade+strt(i)+"/"
	endfor;cycle through decade
endif;KW(decade)

if ~keyword_set(decade) and ~keyword_set(firstfour) and ~keyword_set(kic) then begin
	print, "WARNING! This takes days to complete!"
	read, "Are you sure you want to download ALL files (y/n)", ans
	if ans eq "y" then begin
		spawn, "wget -nH --cut-dirs=4 --directory-prefix=/raw/kepler/lightcurves/ -r -l0 -c -N -np -R 'index*' -erobots=off http://archive.stsci.edu/pub/kepler/lightcurves/"
	endif else print, 'Download aborted.'
endif

;stop
end;wgetKep.pro