local netguanka = {}
function netguanka.createGuanKaNpc(param, ptc_main, ptc_sub)
  local mapId = param.i_m
  local catchId = param.i_c
  local leftTime = param.i_t
  g_LocalPlayer:addFubenNpcData(mapId, catchId, leftTime)
end
function netguanka.delGuanKaNpc(param, ptc_main, ptc_sub)
  local mapId = param.i_m
  local catchId = param.i_c
  g_LocalPlayer:delFubenNpcData(mapId, catchId)
end
function netguanka.gotoGuanKaNpc(param, ptc_main, ptc_sub)
  local mapId = param.i_m
  local catchId = param.i_c
  g_MapMgr:AutoRouteFB({mapId, catchId})
end
function netguanka.setGuanKaStarData(param, ptc_main, ptc_sub)
  local unLockMapId = param.i_m
  local guankaData = param.t_catches
  local data = {}
  for _, catch in pairs(guankaData) do
    local mapid = catch.i_m
    local catchid = catch.i_c
    if data[mapid] == nil then
      data[mapid] = {}
    end
    local temp = data[mapid][catchid]
    if temp == nil then
      temp = {}
      data[mapid][catchid] = temp
    end
    temp.nstar = catch.i_s
  end
  g_LocalPlayer:setUnlockMap(unLockMapId)
  g_LocalPlayer:setFubenBaseData(data)
end
function netguanka.updateGuanKaStarData(param, ptc_main, ptc_sub)
  local mapId = param.i_m
  local catchId = param.i_c
  local starNum = param.i_s
  print("netguanka.updateGuanKaStarData", mapId, catchId, starNum)
  g_LocalPlayer:setFubenCatchInfo(mapId, catchId, starNum, 0)
end
function netguanka.setGuanKaAwardData(param, ptc_main, ptc_sub)
  local awardList = param.t_list
  g_LocalPlayer:setFubenAwardInfo(awardList)
end
function netguanka.updateGuanKaAwardData(param, ptc_main, ptc_sub)
  local awardId = param.i_id
  g_LocalPlayer:updateFubenAwardInfo(awardId)
end
return netguanka
