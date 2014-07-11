;+
;
;  NAME: 
;     test_gen_synthetic
;
;  PURPOSE: Unit Testing of the gen_synthetic routine
;   
;
;  CATEGORY:
;      Planet Hunters
;
;  CALLING SEQUENCE:
;
;      test_gen_synthetic
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
;      test_gen_synthetic
;
;  MODIFICATION HISTORY:
;        c. Matt Giguere 2014.07.14 18:29:33
;
;-
pro test_gen_synthetic, $
help = help, $
postplot = postplot

angstrom = '!6!sA!r!u!9 %!6!n'
!p.color=0
!p.background=255
loadct, 39, /silent
usersymbol, 'circle', /fill, size_of_sym = 0.5

nelres = 1470L
timestep = 29.405511d

;************************************************
; TEST 1: PHASE NEAR ZERO
;************************************************
print, "first test 0 phase (transit happens at the beginning):""
gen_synthetic, rpl=4.2, rst=1.01, per=3.5, phase=1d-5, timebaseline = 43226.101, output=output

plot, output, ps=8, /ysty, /xsty
print, 'Phase should be zero.'
stop

nbnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the 30 minute kepler observations:
for i=0LL, nelres-1d do nbnndout[i] = total(output[floor(i*timestep): floor((i+1)*timestep)-1L])/(floor((i+1)*timestep) - floor(i*timestep))

plot, nbnndout, ps=8, /ysty, yran=[0.9999*min(nbnndout), 1.0001*max(nbnndout)]
print, 'Binned phase should be near zero.'
stop

;************************************************
; TEST 2: PHASE 0.5
;************************************************
print, "first test 0 phase (transit happens at the beginning):""
gen_synthetic, rpl=4.2, rst=1.01, per=3.5, phase=0.5, timebaseline = 43226.101, output=output

plot, output, ps=8, /ysty, /xsty
print, 'Phase should be 0.5.'
stop

nbnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the 30 minute kepler observations:
for i=0LL, nelres-1d do nbnndout[i] = total(output[floor(i*timestep): floor((i+1)*timestep)-1L])/(floor((i+1)*timestep) - floor(i*timestep))

plot, nbnndout, ps=8, /ysty, yran=[0.9999*min(nbnndout), 1.0001*max(nbnndout)]
print, 'Binned phase should be 0.5.'
stop

;************************************************
; TEST 3: PHASE 1.0
;************************************************
print, "first test 0 phase (transit happens at the beginning):""
gen_synthetic, rpl=4.2, rst=1.01, per=3.5, phase=1.0, timebaseline = 43226.101, output=output

plot, output, ps=8, /ysty, /xsty
stop

nbnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the 30 minute kepler observations:
for i=0LL, nelres-1d do nbnndout[i] = total(output[floor(i*timestep): floor((i+1)*timestep)-1L])/(floor((i+1)*timestep) - floor(i*timestep))

plot, nbnndout, ps=8, /ysty, yran=[0.9999*min(nbnndout), 1.0001*max(nbnndout)]
print, 'Binned phase should be near 1.'
stop


;************************************************
; TEST 4: LONG PERIOD WITH HIGH PHASE
;************************************************
print, "first test 0 phase (transit happens at the beginning):""
gen_synthetic, rpl=4.2, rst=1.01, per=350d, phase=.95, timebaseline = 43226.101, output=output

plot, output, ps=8, /ysty, /xsty
print, 'Phase should be zero.'
stop

nbnndout = dblarr(nelres)
;this will bin the gen_synthetic output to be the same 
;length as the 30 minute kepler observations:
for i=0LL, nelres-1d do nbnndout[i] = total(output[floor(i*timestep): floor((i+1)*timestep)-1L])/(floor((i+1)*timestep) - floor(i*timestep))

plot, nbnndout, ps=8, /ysty, yran=[0.9999*min(nbnndout), 1.0001*max(nbnndout)]
print, 'Binned phase should be zero.'
stop


end;test_gen_synthetic.pro 
