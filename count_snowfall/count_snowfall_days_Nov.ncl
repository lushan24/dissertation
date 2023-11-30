
begin

  varname       = "hsnowf"

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

  mon = 11
  mon_Label = (/"Jan","Feb","Mar","Apr","May","Jue","Jun","Aug","Sep","Oct","Nov","Dec"/)
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
  filename="CMA-V3.mon.select.PRE-13011.196101-202012"
  fo = addfile(filedir+filename+".nc","r")
  tim   = fo->time
  u_time_DATE = cd_calendar(tim,-1)  
  tstar   = ind(u_time_DATE .eq. 196101)
  tlast   = ind(u_time_DATE .eq. 202012)
  print(tstar)
  print(tlast)

  snow = fo->$varname$(stat_id|area_i,time|tstar:tlast)
  printVarSummary(snow)

  YMD0    = cd_calendar(snow&time,0)  
  var_years = toint(YMD0(:,0))
  var_months  = toint(YMD0(:,1))
  var_days  = toint(YMD0(:,2))

  snow2 = new((/dimsizes(get_unique_values(var_years))/), "float", snow@_FillValue)
  i = 0
  do year = 1961,2020,1
  print(year)
  aim_winter = ind( var_months .eq. mon .and. var_years .eq. year ) ; 取10月
  print(aim_winter)
  snow2(i) = avg(snow(:,aim_winter))
  i=i+1
  end do
  print(snow2)
 x = ispan(1961,2020,1)
 wks   = gsn_open_wks ("png", "xy-line-" +mon_Label(mon-1))  ; send graphics to PNG file
 
 res   = True

 res@vpXF      = 0.10        ; In page coordinates, where to start
 res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.43        ; Changes the aspect ratio
 res@vpWidthF  = 0.85
 ;res@gsnMaximize = True

 res@trYMinF   = 0.      ; min value on y-axis
 res@trYMaxF   =  1.5        ; max value on y-axis
 ; res@tmXBMinorOn       = False
  res@tmYLMinorOn       = False
  res@tmXTMinorOn       = False
  res@tmYRMinorOn       = False
  res@tmXTOn            = False
  res@tmYROn            = False
 res@tiYAxisString = "" ; y-axis label      
 res@tiXAxisString = ""
 res@tiMainString  = ""; title
res@gsnLeftString = "HSD " +mon_Label(mon-1)
res@gsnRightString = ""
 font_height                   = 0.025
  res@gsnLeftStringFontHeightF=1.2 * font_height
  res@gsnRightStringFontHeightF=1.2 * font_height
  res@xyLineThicknessF       = 3.     ; Thicken the lines
  res@xyMarkLineMode         = "MarkLines"
  res@xyMarker               = 16
  
 res@gsnYRefLine           = avg(snow2)              ; reference line   
res@trXMinF = 1960
res@trXMaxF = 2020
 plot = gsn_csm_xy (wks,x,snow2,res)

end