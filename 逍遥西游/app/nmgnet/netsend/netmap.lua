local netmap = {}
function netmap.move(i_scene, t_loc, i_cf, i_flag)
  if t_loc then
    netprotocolextsend.scene(i_scene, t_loc[1], t_loc[2], i_cf, i_flag)
  end
end
function netmap.reqPlayerInfo(t_pids)
  if type(t_pids) ~= "table" then
    t_pids = {t_pids}
  end
  NetSend({t_pids = t_pids}, S2C_MAP, "P2")
end
function netmap.reqPlayerHide()
  netprotocolextsend.scene(0)
end
function netmap.reqPlayerShow()
  NetSend({}, S2C_MAP, "P4")
end
function netmap.reqDynamicNpcEvent(npcId)
  NetSend({i_id = npcId}, S2C_MAP, "P5")
end
function netmap.pickupMapTreasure(id)
  NetSend({id = id}, S2C_MAP, "P6")
end
function netmap.queryPlayerBangPaiName(pid)
  NetSend({pid = pid}, S2C_MAP, "P8")
end
return netmap
