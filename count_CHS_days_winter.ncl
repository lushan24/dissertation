begin
nov = asciiread("Nov_CHS_year.txt", -1, "float")
printVarSummary(nov)
dec = asciiread("Dec_CHS_year.txt", -1, "float")
jan = asciiread("Jan_CHS_year.txt", -1, "float")
feb = asciiread("Feb_CHS_year.txt", -1, "float")
mar = asciiread("Mar_CHS_year.txt", -1, "float")
winter = new((/2019-1961+1/), "float", -999.)
winter = 0

winter = nov(:58)+dec(:58)+jan(1:)+feb(1:)+mar(1:)
print(winter)
 x_year = ispan(1961,2019,1)
   wks   = gsn_open_wks ("png", "CHS-xy-line-winter"  )  ; send graphics to PNG file
 
 res   = True

res@vpXF      = 0.10        ; In page coordinates, where to start
res@vpYF      = 0.75        ; the plot
 res@vpHeightF = 0.43        ; Changes the aspect ratio
 res@vpWidthF  = 0.85
 ;res@gsnMaximize = True

 res@trYMinF   = 0.      ; min value on y-axis
 res@trYMaxF   =8.0        ; max value on y-axis
 ; res@tmXBMinorOn       = False
  res@tmYLMinorOn       = False
  res@tmXTMinorOn       = False
  res@tmYRMinorOn       = False
  res@tmXTOn            = False
  res@tmYROn            = False
 res@tiYAxisString = "" ; y-axis label      
 res@tiXAxisString = ""
 res@tiMainString  = ""; title
res@gsnLeftString = "CHS Winter" 
res@gsnRightString = ""
 font_height                   = 0.025
  res@gsnLeftStringFontHeightF=1.2 * font_height
  res@gsnRightStringFontHeightF=1.2 * font_height
  res@xyLineThicknessF       = 3.     ; Thicken the lines
  res@xyMarkLineMode         = "MarkLines"
  res@xyMarker               = 16

 res@gsnYRefLine           = avg(winter)              ; reference line   
res@trXMinF = 1960
res@trXMaxF = 2020
 plot = gsn_csm_xy (wks,x_year,winter,res)

end