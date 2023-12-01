

begin

  varname       = "snow"

  s_filename    = "CMA-V3.select.PRE-13011_TEM-12001.stat_info.196101-202012.txt"
  s_filedir     = "G:/data_xu/Precip/station-V3/data_select_wangls/"
   ;*station information
  s_info_tmp    = asciiread(s_filedir+s_filename,-1,"integer") 
  s_info    = onedtond(s_info_tmp,(/dimsizes(s_info_tmp)/10,10/)) 
  s_info!0    = "id"      
  s_info&id   = s_info(:,0)
  printVarSummary(s_info)
  s_info!1    = "info"
  s_info&info   = (/"id","lat","lon","alt","ystar","mstar","dstar","yend","mend","dend"/)
  printVarSummary(s_info)
   ;*lat&lon
  lat   = s_info(:,1)/100+(s_info(:,1)-s_info(:,1)/100*100)/60.0
  lon   = s_info(:,2)/100+(s_info(:,2)-s_info(:,2)/100*100)/60.0

 ;;;;;;;;;;;;;;;;;;;;;; define area
  latmin = 40.
  latmax = 55.
  lonmin = 120.
  lonmax = 135. 
  area_i  = ind( lat .ge. latmin .and. lat .le. latmax .and. lon .ge. lonmin .and. lon .le. lonmax )  
  lat_area  = lat(area_i)
  lon_area  = lon(area_i) 
;;;;;;;;;;;;;;;;;;;;; read snow data 
  filedir="G:/data_xu/Precip/station-V3/data_select_wangls/"
  filename="CMA-V3.day.select.PRE-13011.196101-202012"
  fo = addfile(filedir+filename+".nc","r")
  snow = fo->$varname$(stat_id|area_i,time|:)
  printVarSummary(snow)
  nid = dimsizes(snow&stat_id)

  YMD0    = cd_calendar(snow&time,0)  
  var_years = toint(YMD0(:,0))
  var_months  = toint(YMD0(:,1))
  var_days  = toint(YMD0(:,2))

  aimday      = ind(var_months .ge. 11 .or. var_months .le. 3 )

  stat = new((/dimsizes(nid)/), "float", 32766) ; 计算每个站点的95百分位数

  do i = 0,dimsizes(stat)-1   
  samp = snow(i,aimday)
  printVarSummary(samp)

  snowdaily = samp(ind(samp .gt. 0.1))
  ;printVarSummary(snowdaily)
  qsort(snowdaily)
  ;print(snowdaily)

  dimt = dimsizes(snowdaily)
  x95  = round(.80*dimt,3)-1     ; at 0
  ;print(x95)
  stat(i) = snowdaily(x95)

  delete([/samp, snowdaily, dimt, x95/]) 
  end do
  delete(nid)
  printMinMax(stat, True)
  print(avg(stat))    ;;;;;;;;;;;; 取所有站点80百分位的平均值作为阈值
  x90 = avg(stat)

itime =new((/2020-1961+1,31/), "integer", 999)
print("------------------------------")
  month = 12
  mon_Label = (/"Jan","Feb","Mar","Apr","May","Jue","Jun","Aug","Sep","Oct","Nov","Dec"/)

;;;;;;;;;;;;;
do i = 1961,2020,1
 do j = 1,30,1
  oneday = ind(var_years .eq. i .and. var_months .eq. month .and. var_days .eq. j)
  snow_oneday = snow(:,oneday) ; 某一天的降雪
  nid = dimsizes(snow_oneday&stat_id)
  heavy_points = ind(snow_oneday .ge. x90)
  ;print(dimsizes(heavy_points))
  heavy_ratio = dimsizes(heavy_points)/(nid*1.)*100.
  ;print(heavy_ratio)

  if heavy_ratio .ge. 40. then
      print(i*10000+month*100+j)
 
      itime(i-1961,j-1)= i*10000+month*100+j  
      ; snow_year(i-1961,j-1) = 1
  end if
  delete(heavy_points)
end do 
end do
;Consider x[*] with _FillValue attribute: 
;(a) count the number of not _FillValue (missing values); 
;(b) extract only the non-missing values.
  N = num(.not.ismissing(itime))  ; count number of non-missing 
  print(N)
  x = ndtooned(itime)
  igood = ind(.not.ismissing(x))
  xgood = x(igood)
  print(xgood)

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  yyyymmdd = xgood
  yyyy  = yyyymmdd/10000 
  mmdd  = yyyymmdd-yyyy*10000                ; mmdd = yyyymmdd%10000
  mm    = mmdd/100
  dd    = mmdd-mm*100                        ; dd   = mmdd%100
  year_num = new((/2020-1961+1/), "integer", 999)
  year_num = 0
  do i = 0,dimsizes(year_num)-1
    year_num(i) = num(yyyy .eq. 1961+i)
  end do
  print(year_num)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   var_T  = onedtond(year_num,(/1,dimsizes(year_num)/))
  fmtf    = "1i3"  
  opt   = True
  opt@fout  = mon_Label(month-1)+"_CHS_year.txt"
  write_matrix(var_T,fmtf,opt)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 x_year = ispan(1961,2020,1)
   wks   = gsn_open_wks ("png", "CHS-xy-line" +mon_Label(month-1) )  ; send graphics to PNG file
 
 res   = True

res@vpXF      = 0.10        ; In page coordinates, where to start
res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.43        ; Changes the aspect ratio
 res@vpWidthF  = 0.85
 ;res@gsnMaximize = True

 res@trYMinF   = 0.      ; min value on y-axis
 res@trYMaxF   =  5.0        ; max value on y-axis
 ; res@tmXBMinorOn       = False
  res@tmYLMinorOn       = False
  res@tmXTMinorOn       = False
  res@tmYRMinorOn       = False
  res@tmXTOn            = False
  res@tmYROn            = False
 res@tiYAxisString = "" ; y-axis label      
 res@tiXAxisString = ""
 res@tiMainString  = ""; title
res@gsnLeftString = "CHS " +mon_Label(month-1)
res@gsnRightString = ""
 font_height                   = 0.025
  res@gsnLeftStringFontHeightF=1.2 * font_height
  res@gsnRightStringFontHeightF=1.2 * font_height
  res@xyLineThicknessF       = 3.     ; Thicken the lines
  res@xyMarkLineMode         = "MarkLines"
  res@xyMarker               = 16

 res@gsnYRefLine           = avg(year_num)              ; reference line   
res@trXMinF = 1960
res@trXMaxF = 2020
 plot = gsn_csm_xy (wks,x_year,year_num,res)

end