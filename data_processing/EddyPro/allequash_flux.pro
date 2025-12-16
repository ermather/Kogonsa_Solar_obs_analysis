FUNCTION allequash_processflux,yr,day,rebuild=rebuild,noupload=noupload,fheader=fheader,metbuild=metbuild,tsbuild=tsbuild,fluxbuild=fluxbuild_in,oldway=oldway,debug=debug,nobiomet=nobiomet,skipflux=skipflux,waterbuild=waterbuild
;2014-


;2018-09-12
;"TOA5","Allequash","CR1000","12539","CR1000.Std.32.03","CPU:ALWET_OpEC_powerDiag3.CR1","34424","ts_data"
;"TIMESTAMP","RECORD","Ux","Uy","Uz","Ts","diag_sonic","CO2_li","H2O_li","amb_press_li","agc_li"
;"TS","RN","m/s","m/s","m/s","C","arb","mg/m^3","g/m^3","kPa","%"
;"","","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp"

;2018-11-15
;"TOA5","Allequash","CR1000X","3630","CR1000X.Std.03.00","CPU:allequash_v2_0_00.cr1x","62343","ts_data"
;"TIMESTAMP","RECORD","milliseconds","seconds","nanoseconds","delta_milliseconds","CH4_77","amb_press_77","amb_tmpr_77","rssi_77","Ux","Uy","Uz","Ts","diag_csat","co2","h2o","press_li7500","diag_irga"
;"TS","RN","ms","s","ns","ms","ug/m^3","kPa","C","%","m/s","m/s","m/s","C","unitless","mg/m^3","g/m^3","kPa","unitless"
;"","","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp"


;2022 water
;  "TIMESTAMP","RECORD","Level_Avg","water_temp_c_Avg","rain_mm_Tot"
; one minute averages
  
  IF n_elements(fluxbuild_in) NE 0 THEN fluxbuild = fluxbuild_in

  ystr = string(yr,format='(i4.4)')
  dystr = jd_to_Dy(day,y=yr)
  fheader = ['Year','DOY','Hour','SWd','SWu','LWd','LWu','Rnet','T','Rh','WS','Wdir','co2','h2o','ch4','cflux','qflux','tflux','ch4flux','flag_c','flag_q','flag_t','flag_ch4','cstor','qstor','tstor','ch4stor','NEE_CO2','LE','H','NEE_CH4','u*','tke','L','Ta_sonic','AirP','Rho','Cp','RH_Licor','VPD','Td','Fprint_pk','Fprint_off','Fprint_90','U_var','V_var','W_var'] ;0-46
  IF yr GE 2022 THEN fheader = [fheader,'Water_Level','Water_Temp','Precip'] ;47-49
  fdata = make_array(n_elements(fheader),48,/float,value=nan())

  print,'Allequash flux for '+dystr

  dr = '/air/incoming/Allequash/'+ystr+'/'+dystr+'/'
  dralt = '/air/incoming/Allequash/'+dystr+'/'
  drout = '/air/incoming/Allequash/output/'+ystr+'/'
  create_dir,dr
  create_dir,drout

  dybef = day-1
  yrbef = yr
  IF dybef EQ 0 THEN BEGIN
    yrbef = yr-1
    dybef = days_in_year(yr-1)
  ENDIF 
  dyaft = day+1
  yraft = yr
  IF dyaft GT days_in_year(yr) THEN begin 
    yraft = yr+1
    dyaft = 1
  ENDIF 

  yrbef_str = string(yrbef,format='(i4.4)')
  yraft_str = string(yraft,format='(i4.4)')
  dybef_str = jd_to_dy(dybef,y=yrbef)
  dyaft_str = jd_to_dy(dyaft,y=yraft)

  drbef = '/air/incoming/Allequash/'+yrbef_str+'/'+dybef_str+'/'
  draft = '/air/incoming/Allequash/'+yraft_str+'/'+dyaft_str+'/'
  drbef_alt = '/air/incoming/Allequash/'+dybef_str+'/'
  draft_alt = '/air/incoming/Allequash/'+dyaft_str+'/'


  sfile = drout + 'Allequash_'+dystr+'_rawdata.sav'
  tarfile = drout + 'US-ALQ_'+dystr+'_L0rawdata.tar.gz'

  drcur_met = '/air/incoming/Allequash/current/Allequash_metdata_avg_'+ystr+'_'+strmid(dystr,4,2)+'_'+strmid(dystr,6,2)+'*.dat'
  drcur_ts = '/air/incoming/Allequash/current/Allequash_ts_data_'+ystr+'_'+strmid(dystr,4,2)+'_'+strmid(dystr,6,2)+'*.dat'
  drcur_met_b = '/air/incoming/Allequash/current/Allequash_metdata_avg_'+yrbef_str+'_'+strmid(dybef_str,4,2)+'_'+strmid(dybef_str,6,2)+'*.dat'
  drcur_ts_b = '/air/incoming/Allequash/current/Allequash_ts_data_'+yrbef_str+'_'+strmid(dybef_str,4,2)+'_'+strmid(dybef_str,6,2)+'*.dat'
  drcur_met_a = '/air/incoming/Allequash/current/Allequash_metdata_avg_'+yraft_str+'_'+strmid(dyaft_str,4,2)+'_'+strmid(dyaft_str,6,2)+'*.dat'
  drcur_ts_a = '/air/incoming/Allequash/current/Allequash_ts_data_'+yraft_str+'_'+strmid(dyaft_str,4,2)+'_'+strmid(dyaft_str,6,2)+'*.dat'

  IF yr GE 2022 THEN BEGIN
    drcur_water =  '/air/incoming/Allequash/current/Allequash_water_'+ystr+'_'+strmid(dystr,4,2)+'_'+strmid(dystr,6,2)+'*.dat'
    drcur_water_b = '/air/incoming/Allequash/current/Allequash_water_'+yrbef_str+'_'+strmid(dybef_str,4,2)+'_'+strmid(dybef_str,6,2)+'*.dat'
    drcur_water_a = '/air/incoming/Allequash/current/Allequash_water_'+yraft_str+'_'+strmid(dyaft_str,4,2)+'_'+strmid(dyaft_str,6,2)+'*.dat'    
  ENDIF 
  
;find files for day
;read all files
  mcount = 0
  mcountp = 0
  mcounta = 0
  mcountb = 0
  tcount = 0
  tcountp = 0
  tcounta = 0
  tcountb = 0
  wcount = 0
  wcountp = 0
  wcounta = 0
  wcountb = 0

  mfiles = file_search([[dr,dralt] + 'Allequash_metdata_avg_*.dat',drcur_met],count=mcountp)
  IF mcountp GT 0 THEN BEGIN 
    mfilebef = file_search([drbef + 'Allequash_metdata_avg_*.dat',drbef_alt + 'Allequash_metdata_avg_*.dat',drcur_met_b],count=mcountb)
    IF mcountb GT 0 THEN mfiles = [mfilebef[n_elements(mfilebef)-1],mfiles]
    mfileaft = file_search([draft + 'Allequash_metdata_avg_*.dat',draft_alt + 'Allequash_metdata_avg_*.dat',drcur_met_a],count=mcounta)
    IF mcounta GT 0 THEN mfiles = [mfiles,mfileaft[0]]
    mcount = mcounta + mcountp + mcountb
  ENDIF ELSE mcount = mcountp
  
  tfiles = file_search([[dr,dralt] + 'Allequash_ts_data_*.dat',drcur_ts],count=tcountp)
  IF tcountp GT 0 THEN BEGIN 
    tfilebef = file_search([drbef + 'Allequash_ts_data_*.dat',drbef_alt + 'Allequash_ts_data_*.dat',drcur_ts_b],count=tcountb)
    IF tcountb GT 0 THEN tfiles = [tfilebef[n_elements(tfilebef)-1],tfiles]
    tfileaft = file_search([draft + 'Allequash_ts_data_*.dat',draft_alt + 'Allequash_ts_data_*.dat',drcur_ts_a],count=tcounta)
    IF tcounta GT 0 THEN tfiles = [tfiles,tfileaft[0]]
    tcount = tcounta + tcountp + tcountb
  ENDIF ELSE tcount = tcountp

  wfiles = file_search([[dr,dralt] + 'Allequash_water_*.dat',drcur_water],count=wcountp)
  IF wcountp GT 0 THEN BEGIN 
    wfilebef = file_search([drbef + 'Allequash_water_*.dat',drbef_alt + 'Allequash_water_*.dat',drcur_water_b],count=wcountb)
    IF wcountb GT 0 THEN wfiles = [wfilebef[n_elements(wfilebef)-1],wfiles]
    wfileaft = file_search([draft + 'Allequash_water_*.dat',draft_alt + 'Allequash_water_*.dat',drcur_water_a],count=wcounta)
    IF wcounta GT 0 THEN wfiles = [wfiles,wfileaft[0]]
    wcount = wcounta + wcountp + wcountb
  ENDIF ELSE wcount = wcountp
  
  restored = 0b
  IF file_test(sfile,/read) AND ~keyword_set(rebuild) AND (tcountp NE 0 OR mcountp NE 0 OR wcountp NE 0) THEN BEGIN 
    print,'  Restoring binary file'
    restore,sfile
    restored = 1b
  ENDIF 

;if save file exists, skip next 3 steps, unless rebuild
  IF n_elements(metdata) EQ 0 OR keyword_set(rebuild) OR keyword_set(metbuild) THEN BEGIN 
;make our target arrays
    metheader = ['Year','DOY','Hour','SW_Down','SW_up','LW_down','LW_up','RNet','AirT','RH']
    IF yr GE 2022 THEN metheader = ['Year','DOY','Hour','SW_Down','SW_up','LW_down','LW_up','RNet','AirT','RH','Level','Water_Temp','Rain_mm']
    metdata = make_array(n_elements(metheader),1440,/float,value=nan())
    metdata[0,*] = yr
    metdata[1,*] = day
    metdata[2,*] = findgen(1440)/60.0

    IF mcount GT 0 THEN BEGIN
      print,'  Reading ',string(n_elements(mfiles)),' met files'
      FOR i = 0,n_elements(mfiles)-1 DO BEGIN
        openr,fl,mfiles[i],/get_lun
        s = ''
        FOR j = 0,3 DO readf,fl,s
        FOR k = 0,file_lines(mfiles[i])-5 DO BEGIN
          s = ''
          readf,fl,s
          s = strsplit(s,',"',/extract)
          tstamp = s[0]
;          tstamp_yr = strmid(tstamp,1,4)
;          tstamp_mo = strmid(tstamp,6,2)
;          tstamp_dy = strmid(tstamp,9,2)
;          tstamp_hr = strmid(tstamp,12,2)
;          tstamp_mn = strmid(tstamp,15,2)
          tstamp_yr = strmid(tstamp,0,4)
          tstamp_mo = strmid(tstamp,5,2)
          tstamp_dy = strmid(tstamp,8,2)
          tstamp_hr = strmid(tstamp,11,2)
          tstamp_mn = strmid(tstamp,14,2)
          tstamp_time = float(tstamp_hr)+float(tstamp_mn)/60.0
          tstamp_doy = dy_to_jd(tstamp_yr+tstamp_mo+tstamp_dy)
          tstamp_yr = long(tstamp_yr)
          tstamp_loc = long(tstamp_time * 60)
          IF tstamp_doy EQ day AND tstamp_yr EQ yr AND tstamp_loc GE 0 AND tstamp_loc LT 1440 THEN metdata[3:9,tstamp_loc] = float(s[[2,3,4,5,8,15,16]])
        ENDFOR
        free_lun,fl
      ENDFOR 
    ENDIF

    IF wcount GT 0 THEN BEGIN
      print,'  Reading ',string(n_elements(wfiles)),' water files'
      FOR i = 0,n_elements(wfiles)-1 DO BEGIN
        openr,fl,wfiles[i],/get_lun
        s = ''
        FOR j = 0,3 DO readf,fl,s
        FOR k = 0,file_lines(wfiles[i])-5 DO BEGIN
          s = ''
          readf,fl,s
          s = strsplit(s,',"',/extract)
          tstamp = s[0]
          tstamp_yr = strmid(tstamp,0,4)
          tstamp_mo = strmid(tstamp,5,2)
          tstamp_dy = strmid(tstamp,8,2)
          tstamp_hr = strmid(tstamp,11,2)
          tstamp_mn = strmid(tstamp,14,2)
          tstamp_time = float(tstamp_hr)+float(tstamp_mn)/60.0
          tstamp_doy = dy_to_jd(tstamp_yr+tstamp_mo+tstamp_dy)
          tstamp_yr = long(tstamp_yr)
          tstamp_loc = long(tstamp_time * 60)
          IF tstamp_doy EQ day AND tstamp_yr EQ yr AND tstamp_loc GE 0 AND tstamp_loc LT 1440 THEN metdata[10:12,tstamp_loc] = float(s[[2,3,4]])
        ENDFOR
        free_lun,fl
      ENDFOR 
    ENDIF 
   
  ENDIF

  IF n_elements(tsdata) EQ 0 OR keyword_set(rebuild) OR keyword_set(tsbuild) THEN BEGIN 
    tsheader = ['Year','DOY','Hour','Minute','Second','U','V','W','T','Diag','CO2','H2O','Press7500','AGC7500','CH4','Press7700','Temp7700','RSSI']
    tsdata = make_array(n_elements(tsheader),864000l,/float,value=nan())
    tsdata[0,*] = yr
    tsdata[1,*] = day
    tsdata[2,*] = long(findgen(864000l)/36000.)
    tsdata[3,*] = long(lindgen(864000l) MOD 36000)/600
    tsdata[4,*] = long(lindgen(864000l) MOD 600)/10.0

    IF tcount GT 0 THEN BEGIN
      FOR i = 0,n_elements(tfiles)-1 DO BEGIN
        print,'  Reading ',tfiles[i]
        openr,fl,tfiles[i],/get_lun
        s = ''
        FOR j = 0,3 DO readf,fl,s
        FOR k = 0l,file_lines(tfiles[i])-5l DO BEGIN
          s = ''
          readf,fl,s
          s = strsplit(s,',"',/extract)
          tstamp = s[0]
          tstamp_yr = strmid(tstamp,0,4)
          tstamp_mo = strmid(tstamp,5,2)
          tstamp_dy = strmid(tstamp,8,2)
          tstamp_hr = strmid(tstamp,11,2)
          tstamp_mn = strmid(tstamp,14,2)
          tstamp_sec = strmid(tstamp,17)
          tstamp_doy = dy_to_jd(tstamp_yr+tstamp_mo+tstamp_dy)
          tstamp_yr = long(tstamp_yr)
          tstamp_loc = long(long(tstamp_hr)*36000l+long(tstamp_mn)*600+long(float(tstamp_sec)*10.0))
          IF tstamp_doy EQ day AND tstamp_yr EQ yr AND tstamp_loc GE 0l AND tstamp_loc LT 864000l THEN BEGIN
            IF n_elements(s) EQ 15 THEN tsdata[5:17,tstamp_loc] = float(s[2:14])
            IF n_elements(s) EQ 11 THEN tsdata[5:13,tstamp_loc] = float(s[2:10])
            IF n_elements(s) GE 19 THEN tsdata[5:13,tstamp_loc] = float(S[10:18])
            IF n_elements(s) GE 19 THEN tsdata[14:17,tstamp_loc] = float(S[6:9])
          ENDIF 
        ENDFOR 
        free_lun,fl
      ENDFOR 
    ENDIF 
  ENDIF


  IF (restored EQ 0b) OR keyword_set(rebuild) OR keyword_set(metbuild) OR keyword_set(tsbuild) THEN BEGIN 
;save file
;    fluxbuild = 1b ;if we read new files, then we need to recompute flux
    save,metheader,metdata,tsheader,tsdata,filename=sfile,/compress
;zip and upload to Ameriflux
    IF ~keyword_set(noupload) AND ((tcountp GT 0) OR (mcountp GT 0) OR (wcountp GT 0)) THEN BEGIN
;stop
      print,'  Zipping and uploading data to Ameriflux'
      spawn,'tar cvzf '+tarfile+' '+dr+'Allequash_metdata_avg_*.dat '+dr+'Allequash_ts_data_*.dat '+dr+'Allequash_water_*.dat '+drcur_met+' '+drcur_ts
      IF file_test(tarfile,/read) THEN BEGIN
        print,'  Calling scp -i /home/adesai/ameriflux_keys/us-alq '+tarfile+' fluxnet@dtn01.nersc.gov:'
        spawn,'scp -v -i /home/adesai/ameriflux_keys/us-alq '+tarfile+' fluxnet@dtn01.nersc.gov:'
      ENDIF 
    ENDIF
  ENDIF 
;stop

;make 30 minute averages or totals
;SWd,SWu,LWd,LWu,PAR,P,T,Rh,rain,Level,WaterT,WS,Wdir,co2,h2o,ch4,cflux,qflux,ch4flux
  


; fheader =
; ['Year','DOY','Hour','SWd','SWu','LWd','LWu','Rnet','T','Rh','WS','Wdir','co2','h2o','ch4','cflux','qflux','tflux','ch4flux','flag_c','flag_q','flag_t','flag_ch4','cstor','qstor','tstor','ch4stor','NEE_CO2','LE','H','NEE_CH4','u*','tke','L','Ta_sonic','AirP','Rho','Cp','RH_Licor','VPD','Td','Fprint_pk','Fprint_off','Fprint_90']

                                ;  metheader =
                                ;  ['Year','DOY','Hour','SW_Down','SW_up','LW_down','LW_up','RNet','AirT','RH']

  ; tsheader = ['Year','DOY','Hour','Minute','Second','U','V','W','T','Diag','CO2','H2O','Press7500','AGC7500','CH4','Press7700','Temp7700','RSSI']
  
;if ngood gt threshold (50%)
;need sonic alignment (check code)
  fdata[0,*] = yr
  fdata[1,*] = day
  fdata[2,*] = findgen(48)/2.0
  
  mgood = average_cols(finite(metdata),30,/tot)
  tsgood = average_cols(finite(tsdata),18000,/tot)
  mgood = mgood GT 15
  bmet = where(mgood EQ 0,nbm)
  IF nbm GT 0 THEN mgood[bmet] = nan()
  tsgood = tsgood GT 900
  bts = where(tsgood EQ 0,nbt)
  IF nbt GT 0 THEN tsgood[bts] = nan()

  mavg = average_cols(metdata,30,/nan)*mgood
  tsavg = average_cols(tsdata,18000,/nan)*tsgood

  fdata[3:7,*] = screen_arr(mavg[3:7,*],-1500,1500)  ;range check (radiation)
  fdata[8:9,*] = mavg[8:9,*]                         ;T and RH
  IF yr GE 2022 THEN BEGIN 
    fdata[47:49,*] = mavg[10:12,*]           ;water level, water temp, rain_mm
    fdata[49,*] *= 30.                       ;convert precip to total mm
  ENDIF 
  fdata[8,*] = screen_arr(fdata[8,*],-50,50) ;airt in C
  fdata[9,*] = screen_arr(fdata[9,*],0,100) ;RH

  fdata[10,*] = screen_arr(sqrt(screen_arr(tsavg[5,*],-50,50)^2+screen_arr(tsavg[6,*],-50,50)^2),-50,50) ;windspeed
  sonic_axis = 260.0 ;in metadata file
  fdata[11,*] = screen_Arr(float(float((sonic_axis-float(atan(tsavg[6,*],tsavg[5,*]) * 180.0/!pi))+360.0) MOD 360),0,359.999)
  fdata[35,*] = screen_arr(tsavg[12,*],90.,110.)
  
  IF keyword_set(skipflux) THEN return,fdata

;call eddypro if 10 hz data exists and hasn't previously output
  fcount = 0
  ocount = 0
  IF ~keyword_set(rebuild) AND ~keyword_set(fluxbuild) THEN fluxfile = file_search(dr+'*_full_output_*.csv',count=fcount)

  IF tcount GT 0 AND fcount EQ 0 THEN BEGIN
    print,'  Calling EddyPro'

    oldfile = file_search('/air/incoming/Allequash/output/eddypro/input/*',count=delold)
    IF delold GT 0 THEN file_delete,oldfile,/allow_nonexistent
    oldfile = file_search('/air/incoming/Allequash/output/eddypro/output/*',count=delold)
    IF delold GT 0 THEN file_delete,oldfile,/allow_nonexistent,/recursive
;change

;OLD WAY (gets stuck on some files)
    IF keyword_set(oldway) THEN BEGIN 
      jfiles = tfiles
      FOR i = 0,n_elements(tfiles)-1 DO jfiles[i] = (reverse(strsplit(tfiles[i],'/',/extract)))[0]
      IF mcountb GT 0 AND n_elements(jfiles) GE 2 THEN jfiles[0]=strmid(jfiles[1],0,29)+'0000.dat'
      IF n_elements(jfiles) GE 2 AND (jfiles[0] EQ jfiles[1]) THEN BEGIN 
        jfiles = jfiles[1:*]
        tfiles = tfiles[1:*]
      ENDIF 
      FOR i = 0,n_elements(tfiles)-1 DO file_link,tfiles[i],'/air/incoming/Allequash/output/eddypro/input/'+jfiles[i]
    ENDIF ELSE BEGIN 
;NEW WAY (slower)
;Write TOA5 file out from tsdata
;'/air/incoming/Allequash/output/eddypro/input/Allequash_ts_data_YYYY_MM_DD_0000.dat'
;have to fix because new time stamp differs, also convert NAN to -9999.0
;Also use Diag flag and reasonable values to screen 

;create new array that matches TOA5


             bigheader = ['"TOA5","Allequash","CR1000X","3630","CR1000X.Std.03.00","CPU:allequash_v2_0_00.cr1x","62343","ts_data"',$
                     '"TIMESTAMP","RECORD","Ux","Uy","Uz","Ts","diag_csat","co2","h2o","press_li7500","diag_irga","CH4_density","press_li7700","Temp_li7700","RSSI_li7700"',$
                     '"TS","RN","m/s","m/s","m/s","C","unitless","mg/m^3","g/m^3","kPa","unitless","ug/m^3","kPa","C","%"',$
                     '"","","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp","Smp"']
        
        toa5data = make_array(20,864000,/float,value=nan())
        toa5data[0,*] = yr
        yyyymmdd = jd_to_dy(day,y=yr)      
        toa5data[1,*] = float(strmid(yyyymmdd,4,2))
        toa5data[2,*] = float(strmid(yyyymmdd,6,2))
        toa5data[3:5,*] = tsdata[2:4,*] ;h,m,sec


;screen values here
        toa5data[6,*] = findgen(864000l)
        toa5data[7:8,*] = screen_arr(tsdata[5:6,*],-35,35) ;u,v
        toa5data[9,*] = screen_arr(tsdata[7,*],-10,10)     ;w
        toa5data[10,*] = screen_arr(tsdata[8,*],-40,40)    ;Ts
        toa5data[11,*] = tsdata[9,*]                       ;diag
        bcsat = where(toa5data[11,*] GT 65,nbc)
        IF nbc GT 0 THEN BEGIN 
          toa5data[7,bcsat] = !values.f_nan
          toa5data[8,bcsat] = !values.f_nan
          toa5data[9,bcsat] = !values.f_nan
          toa5data[10,bcsat] = !values.f_nan
        ENDIF 
        toa5data[12,*] = screen_arr(tsdata[10,*],100,3000) ;co2 
        toa5data[13,*] = screen_arr(tsdata[11,*],0,30)     ;h2o
        toa5data[14,*] = screen_arr(tsdata[12,*],85,110)   ;pressure-50
        toa5data[15,*] = tsdata[13,*]
        bli7500 = where(toa5data[15,*] LT 13 OR ~finite(toa5data[14,*]),nbl) ;alternate flag, after 1/22 2015 use column 17
        IF nbl GT 0 THEN toa5data[12,bli7500] = nan()
        IF nbl GT 0 THEN toa5data[13,bli7500] = nan()
        toa5data[16,*] = screen_arr(tsdata[14,*],0.0,4000.) ;ch4
        toa5data[17,*] = screen_arr(tsdata[15,*],85,110)    ;P7700 
        toa5data[18,*] = screen_arr(tsdata[16,*],-40,40)    ;T7700
        toa5data[19,*] = tsdata[17,*]
        bli7700 = where(toa5data[19,*] LT 10. OR ~finite(toa5data[17,*]) OR ~finite(toa5data[18,*]),nbl7) ;RSSI filter < 10
        IF nbl7 GT 0 THEN toa5data[16,bli7700] = nan()
        bval = where(~finite(toa5data),nbv)
        IF nbv GT 0 THEN toa5data[bval] = -9999.0
        IF keyword_set(debug) THEN stop
        bigfname = '/air/incoming/Allequash/output/eddypro/input/Allequash_ts_data_'+strmid(yyyymmdd,0,4)+'_'+strmid(yyyymmdd,4,2)+'_'+strmid(yyyymmdd,6,2)+'_0000.dat'
        print,'  Writing ',bigfname
        openw,fl,bigfname,/get_lun
        printf,fl,bigheader,format='(a0)'
        FOR j = 0l,n_elements(tsdata[0,*])-1l DO printf,fl,'"',toa5data[0:5,j],'"',toa5data[6:19,j],format='(a1,i4.4,"-",i2.2,"-",i2.2,1x,i2.2,":",i2.2,":",f04.1,a1,",",i0,",",4(f0,","),i0,",",3(f0,","),i0,",",3(f0,","),f0)'
        free_lun,fl
      ENDELSE
    
    bmetf = file_search(dr + string(day,format='(i3.3)')+ 'biomet.data',count=bmetfp)
    IF bmetfp NE 0 THEN file_copy,bmetf[0],'/air/incoming/Allequash/output/eddypro/input/biomet.data',/overwrite
    IF (~keyword_set(nobiomet)) AND (bmetfp NE 0) THEN BEGIN 
      spawn,'cd /air/incoming/Allequash/output/eddypro/ini; /air/code/eddypro-engine/bin/eddypro_rp -s linux -c console allequash_biomet.eddypro'
    ENDIF ELSE BEGIN 
      spawn,'cd /air/incoming/Allequash/output/eddypro/ini; /air/code/eddypro-engine/bin/eddypro_rp -s linux -c console allequash.eddypro'
    ENDELSE 
    outfiles = file_search('/air/incoming/Allequash/output/eddypro/output/*.csv',count=ocount)
    fluxfile = file_search('/air/incoming/Allequash/output/eddypro/output/*_full_output_*.csv',count=fcount)
  ENDIF ELSE BEGIN 
    IF fcount NE 0 THEN print,'  Reading existing eddypro output ' ELSE print,'  Skipping eddy pro, no high freq data'
  ENDELSE 
 
;read fluxes
;filename,date,time,DOY,daytime,file_records,used_records,Tau,qc_Tau,H,qc_H,LE,qc_LE,co2_flux,qc_co2_flux,h2o_flux,qc_h2o_flux,ch4_flux,qc_ch4_flux,H_strg,LE_strg,co2_strg,h2o_strg,ch4_strg,co2_v-adv,h2o_v-adv,ch4_v-adv,co2_molar_density,co2_mole_fraction,co2_mixing_ratio,co2_time_lag,co2_def_timelag,h2o_molar_density,h2o_mole_fraction,h2o_mixing_ratio,h2o_time_lag,h2o_def_timelag,ch4_molar_density,ch4_mole_fraction,ch4_mixing_ratio,ch4_time_lag,ch4_def_timelag,sonic_temperature,air_temperature,air_pressure,air_density,air_heat_capacity,air_molar_volume,ET,water_vapor_density,e,es,specific_humidity,RH,VPD,Tdew,u_unrot,v_unrot,w_unrot,u_rot,v_rot,w_rot,wind_speed,max_wind_speed,wind_dir,yaw,pitch,roll,u*,TKE,L,(z-d)/L,bowen_ratio,T*,model,x_peak,x_offset,x_10%,x_30%,x_50%,x_70%,x_90%,un_Tau,Tau_scf,un_H,H_scf,un_LE,LE_scf,un_co2_flux,co2_scf,un_h2o_flux,h2o_scf,un_ch4_flux,ch4_scf,spikes_hf,amplitude_resolution_hf,drop_out_hf,absolute_limits_hf,skewness_kurtosis_hf,skewness_kurtosis_sf,discontinuities_hf,discontinuities_sf,timelag_hf,timelag_sf,attack_angle_hf,non_steady_wind_hf,u_spikes,v_spikes,w_spikes,ts_spikes,co2_spikes,h2o_spikes,ch4_spikes,u_var,v_var,w_var,ts_var,co2_var,h2o_var,ch4_var,w/ts_cov,w/co2_cov,w/h2o_cov,w/ch4_cov,air_p_mean,air_p_mean

  IF fcount GT 0 THEN BEGIN
    ffile = fluxfile[n_elements(fluxfile)-1]
    print,'  Copying flux output from ',ffile
    epdata = read_csv(ffile,n_table_header=3,missing_value=-9999.0)
    ep_doy = epdata.field004-0.02
    ep_hr = ((round((ep_doy-fix(ep_doy))*48)/2.0)+24.0) MOD 24 
    gep = where(long(ep_doy) EQ day,ngep)
    IF ngep GT 0 THEN BEGIN
      ep_loc = long(ep_hr[gep]*2)
      ep_h = screen_arr((epdata.field010)[gep],-200,700)
      ep_hqc = (epdata.field011)[gep]
      ep_l = screen_arr((epdata.field012)[gep],-200,700)
      ep_lqc = (epdata.field013)[gep]
      ep_c = screen_arr((epdata.field014)[gep],-50,50)
      ep_cqc = (epdata.field015)[gep]
      ep_ch4 = screen_arr((epdata.field018)[gep],-10,10)*1000.0 ;nmol
      ep_ch4qc = (epdata.field019)[gep]
      ep_ustar = screen_arr((epdata.field069)[gep],0.0,10.0)
      ep_tke = screen_arr((epdata.field070)[gep],0.0,50.0)
      ep_MO = screen_arr((epdata.field071)[gep],-9998.0,10000.0)
      
      ep_hstor = screen_arr((epdata.field020)[gep],-200,700)
      ep_lstor = screen_arr((epdata.field021)[gep],-200,700)
      ep_cstor = screen_arr((epdata.field022)[gep],-50,50)
      ep_ch4stor = screen_arr((epdata.field024)[gep],-10,10)*1000.0 
      
      ep_co2mix = screen_arr((epdata.field030)[gep],300,1000.0)
      ep_qmix = screen_arr((epdata.field035)[gep],0.0,40.0)
      ep_ch4mix = screen_arr((epdata.field040)[gep],1.5,20.0)
      
      ep_airt = screen_arr((epdata.field044)[gep],223.0,323.0)-273.15
      ep_airp = screen_arr((epdata.field045)[gep],90000.0,110000.0)/1000.0
      ep_rho = screen_arr((epdata.field046)[gep],0.75,2.0)
      ep_cp = screen_arr((epdata.field047)[gep],950.,1100.)
      ep_rh = screen_arr((epdata.field054)[gep],0.,100.)
      ep_vpd = screen_arr((epdata.field055)[gep],0,5000.0)
      ep_td = screen_arr((epdata.field056)[gep],223.0,323.0)-273.15
;      ep_ws = (epdata.field063)[gep]
;      ep_wd = (epdata.field065)[gep]
      
      ep_fprintpeak = screen_arr((epdata.field076)[gep],-1000.0,5e4)
      ep_fprintoff = screen_arr((epdata.field077)[gep],-1000.0,1000.0)
      ep_fprint90 = screen_arr((epdata.field082)[gep],-1000.0,5e4)

      ep_uvar = screen_arr((epdata.field114)[gep],0,50.)
      ep_vvar = screen_arr((epdata.field115)[gep],0,50.)
      ep_wvar = screen_arr((epdata.field116)[gep],0,20.)

; fheader =
; ['Year','DOY','Hour','SWd','SWu','LWd','LWu','Rnet','T','Rh','WS','Wdir','co2','h2o','ch4','cflux','qflux','tflux','ch4flux','flag_c','flag_q','flag_t','flag_ch4','cstor','qstor','tstor','ch4stor','NEE_CO2','LE','H','NEE_CH4','u*','tke','L','Ta_sonic','AirP','Rho','Cp','RH_Licor','VPD','Td','Fprint_pk','Fprint_off','Fprint_90']  ;Nov 17, 2022 add: 'U_var','V_var','W_var'
      
      fdata[12,ep_loc] = ep_co2mix
      fdata[13,ep_loc] = ep_qmix
      fdata[14,ep_loc] = ep_ch4mix
      fdata[15,ep_loc] = ep_c
      fdata[16,ep_loc] = ep_l
      fdata[17,ep_loc] = ep_h
      fdata[18,ep_loc] = ep_ch4
      fdata[19,ep_loc] = ep_cqc
      fdata[20,ep_loc] = ep_lqc
      fdata[21,ep_loc] = ep_hqc
      fdata[22,ep_loc] = ep_ch4qc
      fdata[23,ep_loc] = ep_cstor
      fdata[24,ep_loc] = ep_lstor
      fdata[25,ep_loc] = ep_hstor
      fdata[26,ep_loc] = ep_ch4stor

      IF n_elements(fdata[*,0]) GE 47 THEN BEGIN
        fdata[44,ep_loc] = ep_uvar
        fdata[45,ep_loc] = ep_vvar
        fdata[46,ep_loc] = ep_wvar
      ENDIF 

      bad = where(ep_cqc EQ 2 OR ep_c EQ -9999,nb)
      IF nb GT 0 THEN ep_c[bad]=nan()
      bad = where(ep_lqc EQ 2 OR ep_l EQ -9999,nb)
      IF nb GT 0 THEN ep_l[bad]=nan()
      bad = where(ep_hqc EQ 2 OR ep_h EQ -9999,nb)
      IF nb GT 0 THEN ep_h[bad]=nan()
      bad = where(ep_ch4qc EQ 2 OR ep_ch4 EQ -9999,nb)
      IF nb GT 0 THEN ep_ch4[bad]=nan()
      
      bad = where(~finite(ep_cstor),nb)
      IF nb LT 24.0 THEN ep_cstor = zapbadval(ep_cstor)
      bad = where(~finite(ep_lstor),nb)
      IF nb LT 24.0 THEN ep_lstor = zapbadval(ep_lstor)
      bad = where(~finite(ep_hstor),nb)
      IF nb LT 24.0 THEN ep_hstor = zapbadval(ep_hstor)
      bad = where(~finite(ep_ch4stor),nb)
      IF nb LT 24.0 THEN ep_ch4stor = zapbadval(ep_ch4stor)

      fdata[27,ep_loc] = ep_c+ep_cstor
      fdata[28,ep_loc] = ep_l+ep_lstor
      fdata[29,ep_loc] = ep_h+ep_hstor
      fdata[30,ep_loc] = ep_ch4+ep_ch4stor
      fdata[31,ep_loc] = ep_ustar
      fdata[32,ep_loc] = ep_tke
      fdata[33,ep_loc] = ep_mo
      fdata[34,ep_loc] = ep_airt
;      fdata[35,ep_loc] = ep_airp
      fdata[36,ep_loc] = ep_rho
      fdata[37,ep_loc] = ep_cp
      fdata[38,ep_loc] = ep_rh
      fdata[39,ep_loc] = ep_vpd
      fdata[40,ep_loc] = ep_td
      fdata[41,ep_loc] = ep_fprintpeak
      fdata[42,ep_loc] = ep_fprintoff
      fdata[43,ep_loc] = ep_fprint90
      
      bad = where(fdata LE -9999,nbad)
      IF nbad GT 0 THEN fdata[bad] = nan()
      
    ENDIF 
    ;stop
    IF ocount GT 0 THEN file_move,'/air/incoming/Allequash/output/eddypro/output/*.csv',dr,/overwrite
  ENDIF ELSE print,'  No flux output found to copy'
  IF keyword_set(debug) THEN stop
;return it
  return,fdata

END

PRO allequash_processfluxyear,yr,startday=startday,endday=endday,noupload=noupload,rebuild=rebuild,email=email,procfile=procfile,metbuild=metbuild,tsbuild=tsbuild,fluxbuild=fluxbuild
  
  yrstr = string(yr,format='(i4.4)')
  yrdr = yrstr+'/'

  IF n_elements(yr) EQ 0 THEN yr=2014
  IF n_elements(startday) EQ 0 THEN startday = 1L
  diy = long(days_in_year(yr))
  IF n_elements(endday) EQ 0 THEN endday = diy

  ffile = '/air/incoming/allequash/flux/flux_'+yrstr+'.xdf'

  IF file_test(ffile,/read) THEN f = read_xdf(ffile,header=fheader)

  

  FOR doy = startday,endday DO BEGIN 
    flux = allequash_processflux(yr,doy,rebuild=rebuild,noupload=noupload,fheader=fheader,metbuild=metbuild,tsbuild=tsbuild,fluxbuild=fluxbuild)
    IF n_elements(f) EQ 0 THEN BEGIN 
      f = make_array(n_elements(fheader),diy*48l,/float,value=nan())
      f[0,*] = yr
      f[1,*] = (lindgen(diy*48l)/48)+1
    ENDIF 
    lstart = (doy-1l)*48l
    lend = (doy*48l)-1l
    f[*,lstart:lend]=flux

    IF keyword_set(procfile) THEN BEGIN 
;for flux processing write file daily to allow for easy restart
      write_xdf,ffile,f,header=fheader
      openw,fl,'/air/incoming/allequash/'+string(yr,format='(i4.4)')+'/processed_'+jd_to_dy(doy,y=yr),/get_lun
      printf,fl,' '
      free_lun,fl  
    ENDIF ELSE BEGIN
      IF doy MOD 30 EQ 0 THEN write_xdf,ffile,f,header=fheader
    ENDELSE 
  ENDFOR

  IF ~keyword_set(procfile) THEN write_xdf,ffile,f,header=fheader

  fheader = ['Year','DOY','Hour','SWd','SWu','LWd','LWu','Rnet','T','Rh','WS','Wdir','co2','h2o','ch4','cflux','qflux','tflux','ch4flux','flag_c','flag_q','flag_t','flag_ch4','cstor','qstor','tstor','ch4stor','NEE_CO2','LE','H','NEE_CH4','u*','tke','L','Ta_sonic','AirP','Rho','Cp','RH_Licor','VPD','Td','Fprint_pk','Fprint_off','Fprint_90','U_var','V_var','W_var']
  IF yr GE 2022 THEN fheader = [fheader,'Water_Level','Water_Temp','Precip'] ;47-49

  IF keyword_set(email) THEN BEGIN
    openw,fl,'/air/incoming/wlef/lastday.txt',/get_lun,/append
    printf,fl,''
    printf,fl,'ALLEQUASH FLUX'
    totvar = float(lend-lstart)+1.0
    FOR i = 0,n_elements(fheader)-1 DO IF total(~finite(f[i,lstart:lend])) GT (totvar/1.8) THEN printf,fl,fheader[i],' ',100*total(~finite(f[i,lstart:lend]))/totvar,'% missing'
    free_lun,fl
  ENDIF

END

PRO allequash_fillnee,yr,mcutoff=mcutoff,cutoff=cutoff,debug=debug,noupload=noupload,nowrite=nowrite,nofixpar=nofixpar
  y = yr
  yrstr = string(yr,format='(i4.4)')
  yrdr = yrstr+'/'

  f = read_xdf('/air/incoming/allequash/flux/flux_'+yrstr+'.xdf',header=fh)

;screen cflux, cstor (gapfill)
;screen lflux, lstor, make lnee
;screen tflux, tstor, make tnee
;screen ch4flux, ch4stor, make ch4nee
;screen mflux

  cflux = f[15,*]
  qflux = f[16,*]
  tflux = f[17,*]
  ch4flux = f[18,*]
  
  cflag = f[19,*]
  qflag = f[20,*]
  tflag = f[21,*]
  ch4flag = f[22,*]

  cstor = f[23,*]
  qstor = f[24,*]
  tstor = f[25,*]
  ch4stor = f[26,*]

  bc = where(cflag EQ 2 OR ~finite(cflag),nbc)
  IF nbc GT 0 THEN cflux[bc] = nan()
  IF nbc GT 0 THEN cstor[bc] = nan()
  bc = where(qflag EQ 2 OR ~finite(qflag),nbc)
  IF nbc GT 0 THEN qflux[bc] = nan()
  IF nbc GT 0 THEN qstor[bc] = nan()
  bc = where(tflag EQ 2 OR ~finite(tflag),nbc)
  IF nbc GT 0 THEN tflux[bc] = nan()
  IF nbc GT 0 THEN tstor[bc] = nan()
  bc = where(ch4flag EQ 2 OR ~finite(ch4flag),nbc)
  IF nbc GT 0 THEN ch4flux[bc] = nan()
  IF nbc GT 0 THEN ch4stor[bc] = nan()

  dn_c = daynight(lat=46.030759,lon=-89.60673,/utc,interval=48,yr=yr,timezone=0) 
  day_c = dn_c NE 0
  night_c = dn_c EQ 0
  
  ;local despike for 

  qf_d = qflux
  qf_n = qflux
  qf_d[where(night_c)]=nan()
  qf_n[where(day_c)]=nan()
  qf_D = localdespike(screen_arr(qf_d,-20,600),nsig=4,window=48*13)
  qf_n = localdespike(screen_arr(qf_n,-100,100),nsig=4,window=48*13)
  qflux = merge_array(qf_d,qf_n)

  cf_d = cflux
  cf_n = cflux
  cf_d[where(night_c)]=nan()
  cf_n[where(day_c)]=nan()
  cf_D = localdespike(screen_arr(cf_d,-30,10),nsig=4,window=48*13)
  cf_n = localdespike(screen_arr(cf_n,-10,20),nsig=4,window=48*13)
  cflux = merge_array(cf_d,cf_n)

  tf_d = tflux
  tf_n = tflux
  tf_d[where(night_c)]=nan()
  tf_n[where(day_c)]=nan()
  tf_D = localdespike(screen_arr(tf_d,-100,600),nsig=4,window=48*13)
  tf_n = localdespike(screen_arr(tf_n,-300,100),nsig=4,window=48*13)
  tflux = merge_array(tf_d,tf_n)

  ch4f_d = ch4flux
  ch4f_n = ch4flux
  ch4f_d[where(night_c)]=nan()
  ch4f_n[where(day_c)]=nan()
  ch4f_D = localdespike(screen_arr(ch4f_d,-50,180),nsig=4,window=48*13)
  ch4f_n = localdespike(screen_arr(ch4f_n,-50,180),nsig=4,window=48*13)
  ch4flux = merge_array(ch4f_d,ch4f_n)
  
;  cflux = localdespike(screen_arr(cflux,-40,40),nsig=3,window=48)
;  qflux = localdespike(screen_arr(qflux,-100,600))
;  tflux = localdespike(screen_arr(tflux,-300,600))
;  ch4flux = localdespike(screen_arr(ch4flux,-500,500))
  
  cstor = localdespike(screen_arr(cstor,-50,50))
  qstor = localdespike(screen_arr(qstor,-30,30))
  tstor = localdespike(screen_arr(tstor,-30,30))
  ch4stor = localdespike(screen_arr(ch4stor,-60,60))

  cstor_f = zapbadval(ensemble_fill(cstor,ptsperday=48,mindays=14,maxdays=56,enoughdays=14,/circular))
  qstor_f = zapbadval(ensemble_fill(qstor,ptsperday=48,mindays=14,maxdays=56,enoughdays=14,/circular))
  tstor_f = zapbadval(ensemble_fill(tstor,ptsperday=48,mindays=14,maxdays=56,enoughdays=14,/circular))
  ch4stor_f = zapbadval(ensemble_fill(ch4stor,ptsperday=48,mindays=14,maxdays=56,enoughdays=14,/circular))
  
  cnee = screen_arr(cflux + cstor_f,-50,50)
  qnee = screen_arr(qflux + qstor_f,-100,600)
  tnee = screen_arr(tflux + tstor_f,-300,600)
  ch4nee = screen_arr(ch4flux + ch4stor_f,-300,300)

  f[15,*] = cflux
  f[16,*] = qflux
  f[17,*] = tflux
  f[18,*] = ch4flux

  f[23,*] = cstor
  f[24,*] = qstor
  f[25,*] = tstor
  f[26,*] = ch4stor
  
  f[27,*] = cnee
  f[28,*] = qnee
  f[29,*] = tnee
  f[30,*] = ch4nee

  mflux = f[31,*]
  flag = finite(mflux) AND (mflux LT 0.05) AND night_c

;u* screen
  cpref = cnee
  cpref[where(flag)]=nan()
  
;gap-fill met
  f[3,where(night_c)]=0.0
  swfactor = 2.0
  gpar = f[3,*]*swfactor
  t30 = merge_array((f[8,*]),(f[34,*])) ;air t + sonic air t

  IF ~keyword_set(nofixpar) THEN BEGIN 
    IF file_test('/air/incoming/lcreek/alldata2000'+yrstr+'-processed.sav',/read) THEN BEGIN
      restore,'/air/incoming/lcreek/alldata2000'+yrstr+'-processed.sav'
      pp = (reform(shift(lc_par_fill[*,y-2000l],12)))[0:n_elements(reform(gpar))-1]
      tt = (reform(shift(lc_tair_pref[*,y-2000l],12)))[0:n_elements(reform(t30))-1]
      tt = fit_array(tt,t30)
      parfactor = mean(pp[where(finite(gpar))],/nan)/mean(gpar[where(finite(pp))],/nan)
      IF ~finite(parfactor) THEN parfactor = 1.0
      gpar = merge_array(gpar*parfactor,pp)
      t30 = merge_array(t30,tt)
    ENDIF ELSE BEGIN        
      IF file_test('/air/incoming/WillowCreek/alldata'+yrstr+'-processed.sav',/read) THEN BEGIN
        restore,'/air/incoming/WillowCreek/alldata'+yrstr+'-processed.sav'
        pp = (reform(shift(wc_par_fill[*],12)))[0:n_elements(reform(gpar))-1]
        tt = (reform(shift(wc_tair_pref[*],12)))[0:n_elements(reform(t30))-1]
        tt = fit_array(tt,t30)
        parfactor = mean(pp[where(finite(gpar))],/nan)/mean(gpar[where(finite(pp))],/nan)
        IF ~finite(parfactor) THEN parfactor = 1.0
        gpar = merge_array(gpar*parfactor,pp)
        t30 = merge_array(t30,tt)
      ENDIF ELSE BEGIN 
        IF file_test('/air/incoming/wlef/alldata'+yrstr+'-processed.sav',/read) THEN BEGIN
          restore,'/air/incoming/wlef/alldata'+yrstr+'-processed.sav'
          pp = (congrid(reform(shift(par_pref,6)),17568,/interp))[0:n_elements(reform(gpar))-1]
          tt = (congrid(reform(shift(tair_30_filled,6)),17568,/interp))[0:n_elements(reform(t30))-1]
          tt = fit_array(tt,t30)
          parfactor = mean(pp[where(finite(gpar))],/nan)/mean(gpar[where(finite(pp))],/nan)
          IF ~finite(parfactor) THEN parfactor = 1.0
          gpar = merge_array(gpar*parfactor,pp)
          t30 = merge_array(t30,tt)
        ENDIF 
      ENDELSE 
    ENDELSE 
  ENDIF

  IF ~keyword_set(nowrite) THEN write_xdf,'/air/incoming/allequash/flux/fluxclean_'+yrstr+'.xdf',f,header=fh

  temp = ensemble_fill(t30,ptsperday=48,mindays=14,maxdays=56,enoughdays=14,/circular) ;pick one, gap fill
  par = reform(zapbadval(ensemble_fill(gpar,ptsperday=48,mindays=14,maxdays=56,enoughdays=14,/circular)))
  par[where(night_c)]=0.0

  yr = y
;timezone shift to CST (shift by 12)
  chop2 = n_elements(cpref)-1
  chop1 = n_elements(cpref)-1-12
  temp = shift(temp,-12)
  temp[chop1:chop2]=nan()
  temp = zapbadval(temp)
  par = shift(par,-12)
  par[chop1:chop2]=nan()
  cpref = shift(cpref,-12)
  cpref[chop1:chop2]=nan()

;cutoff temp/par
  IF n_elements(mcutoff) NE 0 THEN BEGIN
    dd = (findgen(n_elements(temp))/48.)+1.
    bval_co = where(dd LT mcutoff[0] OR dd GE mcutoff[1],nbval_co)
    IF nbval_co GT 0 THEN BEGIN
      temp[bval_co]=nan()
      par[bval_co]=nan()
    ENDIF 
  ENDIF

;gap_fill NEE
  IF isallnan(cpref) OR isallnan(par) OR isallnan(temp) THEN BEGIN
    fnee = cpref
    fnee[*] = !values.f_nan
    resp = fnee
    psyn = fnee
    modnee = fnee
  ENDIF ELSE BEGIN 
    CalcRespPsynFits,yr,nee=cpref,par=par,temp=temp,respfit=rf,psynfit=pf,fillednee=fn,badval=nan(),badlocs=bl,resphead=rh,psynhead=ph,filledhead=fnh,leafon=leafon,leafoff=leafoff,cutoff=cutoff,lat=46.0827,lon=-89.9792
    IF n_elements(fn) NE 0 THEN BEGIN 
      resp = fn[8,*]
      psyn = fn[13,*]
      modnee = fn[15,*]
      fnee = fn[16,*]
    ENDIF ELSE BEGIN
      fnee = cpref
      fnee[*] = !values.f_nan
      resp = fnee
      psyn = fnee
      modnee = fnee
    ENDELSE 
  ENDELSE
 
;output

  IF keyword_set(debug) THEN stop

  IF n_elements(fn) NE 0 THEN write_xdf,'/air/incoming/allequash/flux/fillnee_'+yrstr+'.xdf',fn,header=fnh

  f[3:*,*] = shift(f[3:*,*],0,-12)
  f[3:*,chop1:chop2]=nan()

  bval = where(~finite(f),nbad)
  IF nbad GT 0 THEN f[bval] = -9999.0

  fname_flux = '/air/incoming/allequash/flux/'+'allequash'+yrstr+'_flux.txt'
  fname_fill = '/air/incoming/allequash/flux/'+'allequash_fillednee_'+yrstr

  fheader = ['Year','DOY','Hour','SWd','SWu','LWd','LWu','Rnet','T','Rh','WS','Wdir','co2','h2o','ch4','cflux','qflux','tflux','ch4flux','flag_c','flag_q','flag_t','flag_ch4','cstor','qstor','tstor','ch4stor','NEE_CO2','LE','H','NEE_CH4','u*','tke','L','Ta_sonic','AirP','Rho','Cp','RH_Licor','VPD','Td','Fprint_pk','Fprint_off','Fprint_90','U_var','V_var','W_var']

  openw,fl,fname_flux,/get_lun
  printf,fl,fh,format='(a4," ",a3," ",a4," ",21(a10," "),4(a10," "),23(a10," "),a10)'
  FOR k = 0,n_elements(f[0,*])-1 DO printf,fl,f[*,k],format='(I4,1x,I3,1x,f4.1,1x,16(f10.3,1x),4(i10,1x),23(f10.3,1x),f10.3)'
  free_lun,fl

  IF n_elements(fn) NE 0 THEN BEGIN 
    bval = where(~finite(fn),nbad)
    IF nbad GT 0 THEN fn[bval] = -9999.0
    openw,fl,fname_fill,/get_lun
    FOR k = 0,n_elements(fn[0,*])-1 DO printf,fl,fn[*,k],format='(i4.4,i4,i5.4,f8.3,13f12.3)'
    free_lun,fl
  ENDIF 

  IF ~keyword_set(noupload) THEN BEGIN 
    spawn,'scp -v -i /home/adesai/ameriflux_keys/us-alq '+fname_flux+' '+fname_fill+' fluxnet@dtn01.nersc.gov:'
  ENDIF 
END

PRO allequash_amerifluxout,theyr,endday=endday,debug=debug

  ystr4 = string(theyr,format='(i4.4)')
  IF file_test('/air/incoming/allequash/flux/fluxclean_'+ystr4+'.xdf',/read) THEN BEGIN
    f = read_xdf('/air/incoming/allequash/flux/fluxclean_'+ystr4+'.xdf',header=fh)
  ENDIF ELSE BEGIN
    f = read_xdf('/air/incoming/allequash/flux/flux_'+ystr4+'.xdf',header=fh)
  ENDELSE
  
  IF file_test('/air/incoming/allequash/flux/fillnee_'+ystr4+'.xdf',/read) THEN BEGIN 
    fn = read_xdf('/air/incoming/allequash/flux/fillnee_'+ystr4+'.xdf',header=fnh)
  ENDIF ELSE BEGIN
    fn = make_array(17,17568,/float,value=-9999)
  ENDELSE
  
  print,'  Writing Ameriflux file ',theyr

  ndays = days_in_year(theyr)
  nhrs = ndays * 48l
  nyrs = 1
  fjday = reform(((findgen(17568l*nyrs)/48.0) MOD 366)+1,17568,nyrs)
  day = long(fjday)
  day = day[0:nhrs-1]
  ts_1 = jd_to_dy(day,y=theyr)
  hr = reform(findgen(17568l*nyrs) MOD 48,17568,nyrs) / 2.0
  hh = fix(hr)
  mm = fix(60.*(hr-hh))
  ts_st = ts_1+string(hh,format='(i2.2)')+string(mm,format='(i2.2)')
  ts_en = shift(ts_st,-1)
  ts_en[nhrs-1] = string(theyr+1,format='(i4.4)')+str_right(ts_en[nhrs-1],8)

  IF n_elements(endday) NE 0 THEN nhrs = endday * 48l
  
  badval = -9999.0

;time zone conversion
  chop2 = n_elements(f[0,*])-1
  chop1 = n_elements(f[0,*])-1-12
  f[3:*,*] = shift(f[3:*,*],0,-12)
  f[3:*,chop1:chop2]=nan()

;calc day night in LST
  dn_c = daynight(lat=46.030759,lon=-89.60673,interval=48,yr=yr,timezone=-6) 
  day = dn_c NE 0
  night = dn_c EQ 0

;Make night 0
  sw_in = f[3,*]
  sw_out = f[4,*]
  sw_in[where(night)]=0.0
  sw_out[where(night)]=0.0

;remove some filled zero in SW
  theday = 1-night
  FOR bnight = 1,days_in_year(theyr) DO BEGIN
    solarinday = sw_in[where(theday AND day EQ bnight)]
    IF isallnan(solarinday) THEN sw_in[where(night AND day EQ bnight)]=nan() 
    solaroutday = sw_out[where(theday AND day EQ bnight)]
    IF isallnan(solaroutday) THEN sw_out[where(night AND day EQ bnight)]=nan() 
  ENDFOR 

;unit conversions here (h2o mmol/mol, vpd to hPa)
  f[13,*] *= 18.0/28.97  ;h2o to mmol/mol
  f[14,*] *= 1000.       ;ch4 to nmol/mol

 ;merge temp
  f[8,*] = merge_array(f[8,*],f[34,*]) ;air t + sonic air t
  f[9,*] = screen_arr(merge_array(f[9,*],f[38,*]),1,100) ;rh and rh_licor
  
;nee, flux fixes
  alq_fillnee_new = fn[16,*]
  alq_reco_new = fn[8,*]
  alq_gpp_new = fn[13,*]
  
  alq_reco_new2 = alq_fillnee_new*(alq_fillnee_new GT alq_reco_new)+alq_reco_new*(alq_fillnee_new LE alq_reco_new)
  alq_gpp_new2 = alq_reco_new - alq_fillnee_new

                                ;ameriflux 2020 fixes
                                ; outliers in LW
  f[39,*]*=0.01 ;VPD to hPa
  f[5,*] = screen_arr(f[5,*],50,600) ;LW outliers 
  f[6,*] = screen_arr(f[6,*],50,600)

  f[44:46,*] = sqrt(f[44:46,*]) ;convert variance to sigma


                                ;2022 variables
  IF theyr GE 2022 THEN BEGIN
    alq_wdepth = screen_arr(f[47,*],0.01,10)

    alq_wtemp = f[48,*]
    btemp = where(alq_wtemp EQ 0,nbtemp)
    IF nbtemp GT 0 THEN alq_wtemp[btemp] = nan()
    f[48,*] = alq_wtemp
    
    ;    fdata[47:49,*] = mavg[10:12,*]           ;water level, water temp, rain_mm

    alq_wdepth_c = alq_wdepth  - 2. ; alq_press_psi  ;psi
    alq_dens = (999.83952 + 16.945176*alq_wtemp - 7.9870401e-3*alq_wtemp^2 $
              - 46.170461e-06*alq_wtemp^3 + 105.56302e-9*alq_wtemp^4 - 280.54253e-12*alq_wtemp^5) / $
              (1+16.8798850e-3*alq_wtemp)
    alq_dens *= 0.0624279606 ;pounds per cubic foot
    alq_wdepth_m = alq_wdepth_c * 144 * 0.3048  / alq_dens  ;psi to psf / pcf * f_$
    alq_wdepth_m = alq_wdepth_m                             ;- 1.6 lcreek ref

    f[47,*] = alq_wdepth_m
    IF theyr EQ 2022 THEN f[47,9000:9350]= nan()
    IF theyr EQ 2022 THEN f[48,9000:9350]= nan()

  ENDIF

  IF theyr EQ 2023 THEN f[10,*] = screen_arr(f[10,*],0,15)
  IF theyr EQ 2023 THEN f[49,*] = screen_arr(f[49,*],0,100)

;Line: 202301121600, NETRAD set to -9999
  IF theyr EQ 2023 THEN  f[7,560] = nan()    
;Line: 202301080900, NETRAD, SW_IN and PPFD_in set to -9999
  IF theyr EQ 2023 THEN fn[12,354]=nan()
  IF theyr EQ 2023 THEN f[3,354]=nan()
  IF theyr EQ 2023 THEN f[7,354]=nan()
  
  IF keyword_set(debug) THEN stop
  
;replace badval
  bval = wherE(~finite(f) OR f LT -9999,nbv)
  IF nbv GT 0 THEN f[bval] = badval
  bval = wherE(~finite(fn) OR fn LT -9999,nbv)
  IF nbv GT 0 THEN fn[bval] = badval
  bval = wherE(~finite(alq_fillnee_new) OR alq_fillnee_new LT -9999,nbv)
  IF nbv GT 0 THEN alq_fillnee_new[bval] = badval
  bval = wherE(~finite(alq_reco_new) OR alq_reco_new LT -9999,nbv)
  IF nbv GT 0 THEN alq_reco_new[bval] = badval
  bval = wherE(~finite(alq_gpp_new) OR alq_gpp_new LT -9999,nbv)
  IF nbv GT 0 THEN alq_gpp_new[bval] = badval
  
  fname = 'US-ALQ_HH_'+ts_st[0]+'_'+ts_en[nhrs-1]+'.csv'
  openw,fl,'/air/incoming/allequash/flux/'+fname,/get_lun

;Ameriflux header
  header = 'TIMESTAMP_START,TIMESTAMP_END,SW_IN,SW_OUT,LW_IN,LW_OUT,NETRAD,'
  header+= 'TA,RH,WS,WD,CO2,H2O,CH4,'
  header+= 'FC,LE,H,FCH4,'
  header+= 'FC_SSITC_TEST,LE_SSITC_TEST,H_SSITC_TEST,FCH4_SSITC_TEST,'
  header+= 'SC,SLE,SH,SCH4,'
  header+= 'NEE,USTAR,MO_LENGTH,PA,VPD,'
  header+= 'FETCH_MAX,FETCH_90,'
  header+= 'TA_F,PPFD_IN_F,NEE_F,RECO_F,GPP_F,'
  header+= 'U_SIGMA,V_SIGMA,W_SIGMA'
  IF theyr GE 2022 THEN header+= ',WTD,TW,P'

;gap fill TA, PPFD, NEE, SW, FC, RH, CH4_F, LE, VPD
  
;old header
  ;TIMESTAMP_START,TIMESTAMP_END,H,H_PI_F,LE,LE_PI_F,WD,WS,USTAR,TA_PI_F,VPD_PI,VPD_PI_F,SW_IN,NEE_PI,NEE_PI_F,RECO_PI_F,GPP_PI_F,FC,CO2,TA,SW_IN_PI_F,RH,FC_PI_F,RH_PI_F,CH4,FCH4,SW_OUT,LW_IN,LW_OUT,NETRAD,FCH4_PI_F
  
  printf,fl,header
  FOR i = 0,nhrs-1 DO BEGIN
    IF theyr LT 2022 THEN BEGIN 
      printf,fl,ts_st[i],ts_en[i],f[3:27,i],f[31,i],f[33,i],f[35,i],f[39,i],f[41,i],f[43,i],fn[7,i],fn[12,i],alq_fillnee_new[i],alq_reco_new[i],alq_gpp_new[i],f[44,i],f[45,i],f[46,i],$
             format='(i12,",",i12,",",16(g0.7,","),4(i0,","),18(g0.7,","),g0.7)'
    ENDIF ELSE BEGIN
      printf,fl,ts_st[i],ts_en[i],f[3:27,i],f[31,i],f[33,i],f[35,i],f[39,i],f[41,i],f[43,i],fn[7,i],fn[12,i],alq_fillnee_new[i],alq_reco_new[i],alq_gpp_new[i],f[44,i],f[45,i],f[46,i],f[47,i],f[48,i],f[49,i],$
             format='(i12,",",i12,",",16(g0.7,","),4(i0,","),21(g0.7,","),g0.7)'
    ENDELSE 
  ENDFOR 
  free_lun,fl
  
END

PRO allequash_fluxall,yr,startday=startday,endday=endday,noupload=noupload,rebuild=rebuild,noflux=noflux,nofill=nofill,nosave=nosave,metbuild=metbuild,tsbuild=tsbuild,fluxbuild=fluxbuild,nooutput=nooutput
;based on wcreek_fluxall

  cuttm = systime(/julian)
  caldat,cuttm,mon,day,curyr,hour,minute,secod
  curdoy = dy_to_jd(string(curyr,format='(i4.4)')+string(mon,format='(i2.2)')+string(day,format='(i2.2)'))

  ;default year is this year
  IF n_elements(yr) EQ 0 THEN yr = curyr
;default process to today
  IF n_elements(endday) EQ 0 THEN IF yr EQ curyr THEN endday = curdoy ELSE endday = days_in_year(yr) ;(curdoy-1) > 1

  IF n_elements(startday) EQ 0 THEN BEGIN
    procprefix = '/air/incoming/allequash/'+string(yr,format='(i4.4)')+'/processed_'+string(yr,format='(i4.4)')
    procfiles = file_Search(procprefix+'*',count=nproc)
    IF nproc EQ 0 THEN startday = 1 ELSE BEGIN
      procfiles = reverse(procfiles[sort(procfiles)])
      lastfile = procfiles[0]
      lastday = str_right(lastfile,8)
;      lastday = strmid(lastday,0,4)+strmid(lastday,5,2)+strmid(lastday,8,2)
      startday = dy_to_jd(lastday)
    ENDELSE 
  ENDIF

  IF endday GT startday THEN BEGIN 
    print,'Allequash Process Flux for day ',startday,' to ',endday,' for year',yr
    IF ~keyword_set(noflux) THEN allequash_processfluxyear,yr,startday=startday,endday=endday,rebuild=rebuild,/email,/procfile,metbuild=metbuild,tsbuild=tsbuild,fluxbuild=fluxbuild,noupload=noupload
    IF ~keyword_set(nofill) THEN allequash_fillnee,yr,mcutoff=[1,endday],cutoff=[1,endday],noupload=noupload
    yr_o = yr
    IF ~keyword_set(nooutput) THEN BEGIN
      allequash_amerifluxout,yr_o
    ENDIF 
  ENDIF ELSE BEGIN
    print,'No new files to process'
  ENDELSE 

END

