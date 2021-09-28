local netguanka = {}
function netguanka.askToCreateNpc(mapId, catchId)
  NetSend({i_m = mapId, i_c = catchId}, S2C_GUANKA, "P1")
end
function netguanka.askToFightNpc(mapId, catchId)
  NetSend({i_m = mapId, i_c = catchId}, S2C_GUANKA, "P2")
end
function netguanka.unlockMapId(mapId)
  NetSend({i_m = mapId}, S2C_GUANKA, "P3")
end
function netguanka.getGuanKaAwardId(awardId)
  NetSend({i_id = awardId}, S2C_GUANKA, "P11")
end
return netguanka
