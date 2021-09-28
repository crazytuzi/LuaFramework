local netwar = {}
function netwar.startWar(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local fbWarID = param.i_gid
  local warType = param.i_wartype
  local warTypeData = {}
  if warType == WARTYPE_FUBEN then
    local mapID = param.i_mapid
    local catchID = param.i_catchid
    local isSuper = param.i_super
    if isSuper == nil then
      isSuper = 0
    end
    warTypeData = {
      mapID = mapID,
      catchID = catchID,
      isSuper = isSuper
    }
  end
  StartSingleWar(warID, fbWarID, warType, warTypeData)
end
function netwar.warAward(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  local t_items = param.t_items or {}
  local itemData = {}
  for _, item in pairs(t_items) do
    itemID = item.i_itemid
    itemNum = item.i_num
    itemData[itemID] = itemNum
  end
  local heroaddexp = param.i_heroaddexp or 0
  local heroinfo = {}
  local i_heroexp = param.i_heroexp or {}
  for _, info in pairs(i_heroexp) do
    local heroid = info.i_heroid
    heroinfo[heroid] = {
      prelevel = info.i_heroprelevel,
      preexp = info.i_heropreexp,
      level = info.i_herolevel,
      exp = info.i_heroexp
    }
  end
  local petaddexp = param.i_petaddexp or 0
  local petinfo = {}
  local i_petexp = param.i_petexp or {}
  for _, info in pairs(i_petexp) do
    local petid = info.i_petid
    petinfo[petid] = {
      prelevel = info.i_petprelevel,
      preexp = info.i_petpreexp,
      level = info.i_petlevel,
      exp = info.i_petexp
    }
  end
  local moneyaward = param.i_moneyaward or 0
  local warResultData = {}
  warResultData.warID = warID
  warResultData.itemData = itemData
  warResultData.heroaddexp = heroaddexp
  warResultData.heroinfo = heroinfo
  warResultData.petaddexp = petaddexp
  warResultData.petinfo = petinfo
  warResultData.moneyaward = moneyaward
  SetWarResultData_Server(warID, warResultData)
end
function netwar.warFailed(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  SetWarFailed_Server(warID)
end
function netwar.warDaPing(param, ptc_main, ptc_sub)
  local warID = param.i_warid
  SetWarDaPing_Server(warID)
end
function netwar.setWarSetting(param, ptc_main, ptc_sub)
  local settingInfo = param.i_setting
  local info = {}
  for _, data in pairs(settingInfo) do
    info[data.i_pos] = data.i_heroid
  end
  g_LocalPlayer:setWarSetting(info)
end
function netwar.updateWarSettingSuccess(param, ptc_main, ptc_sub)
end
function netwar.setWarDrugSetting(param, ptc_main, ptc_sub)
  local i_hpset = param.i_hpset
  local i_mpset = param.i_mpset
  local drugSetting = {SelectHPType = i_hpset, SelectMPType = i_mpset}
  g_LocalPlayer:setAIUseDrugSetting(drugSetting)
end
function netwar.updateWarDrugSettingSuccess(param, ptc_main, ptc_sub)
  SendMessage(MsgID_WarDrugSettingSuccess)
end
function netwar.isInWar(param, ptc_main, ptc_sub)
  local inWarId = param.i_w
  print("netwar.isInWar:", inWarId)
  if JudgeIsInWar() and g_WarScene:getWarID() ~= inWarId then
    QuitWarSceneAndBackToPreScene()
  end
end
return netwar
