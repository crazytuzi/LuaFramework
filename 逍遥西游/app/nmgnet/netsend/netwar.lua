local netwar = {}
function netwar.submitWarResult(i_warid, i_result, t_warpet, t_skillp, t_petc, warUseTime)
  NetSend({
    i_warid = i_warid,
    i_result = i_result,
    t_warpet = t_warpet,
    t_petc = t_petc,
    t_skillp = t_skillp,
    i_t = warUseTime
  }, "war", "P2")
end
function netwar.warUseDrug(i_warid, i_iid, i_num)
  NetSend({
    i_warid = i_warid,
    i_iid = i_iid,
    i_num = i_num
  }, "war", "P4")
end
function netwar.submitWarSetting(settingInfo)
  local info = {}
  for pos, hid in pairs(settingInfo) do
    info[#info + 1] = {i_pos = pos, i_heroid = hid}
  end
  NetSend({i_setting = info}, "war", "P10")
end
function netwar.submitWarDrugSetting(i_hpset, i_mpset)
  NetSend({i_hpset = i_hpset, i_mpset = i_mpset}, "war", "P11")
end
function netwar.shimenWar(taskid)
  NetSend({taskid = taskid}, "war", "P13")
end
function netwar.mapMonsterWar(warId, customId)
  NetSend({i_w = warId, i_p = customId}, "war", "P14")
end
function netwar.mapMonsterWarForSanJieLiLian(warId, customId)
  NetSend({i_w = warId, i_p = customId}, "war", "P15")
end
function netwar.tellSerToKillWar(warId)
  print("tellSerToKillWar", warId)
  NetSend({warId = warId}, "war", "P18")
end
function netwar.daTingCangBaoTu(warId)
  print("daTingCangBaoTu", warId)
  NetSend({warId = warId}, "war", "P19")
end
return netwar
