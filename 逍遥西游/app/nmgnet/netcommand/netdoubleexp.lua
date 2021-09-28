local netdoubleexp = {}
function netdoubleexp.updateDoubleExpData(param, ptc_main, ptc_sub)
  print("netdoubleexp.updateDoubleExpData:", param, ptc_main, ptc_sub)
  if param then
    local deP = param.i_p
    local deRestP = param.i_r
    local useSBDTimes = param.i_time
    print("updateDoubleExpData", deP, deRestP, useSBDTimes)
    g_LocalPlayer:setDoubleExpData(deP, deRestP, useSBDTimes)
  end
end
function netdoubleexp.useDoubleDrugResult(param, ptc_main, ptc_sub)
  print("netdoubleexp.useDoubleDrugResult:", param, ptc_main, ptc_sub)
  local result = param.result
end
return netdoubleexp
