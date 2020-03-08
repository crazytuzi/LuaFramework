local Lplus = require("Lplus")
local HuanhunProtocols = Lplus.Class("HuanhunProtocols")
local def = HuanhunProtocols.define
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
def.static("table").OnSSynHuanhuiInfo = function(p)
  activityInterface._huanhunItemInfos = p.itemInfos
  activityInterface._huanhunStatus = p.status
  activityInterface._seekHelpLeftCount = p.seekHelpLeftCount
  activityInterface._helpOtherLeftCount = p.helpOtherLeftCount
  activityInterface._huanhunTimeLimit = p.timeLimit
  if p.firstTime == 1 then
    local huanhun = require("Main.activity.ui.Huanhun").Instance()
    local myRoleID = _G.GetMyRoleID()
    local huanhunItemInfos = activityInterface._huanhunItemInfos
    huanhun:SetEnddingSec(activityInterface._huanhunTimeLimit:ToNumber() / 1000)
    huanhun:ShowDlg(myRoleID, huanhunItemInfos)
    warn("-------------------------------------huanhun")
  end
  activityInterface:_refreshActivityRequirements()
end
def.static("table").OnSSynHuanHunStatus = function(p)
  activityInterface._huanhunStatus = p.status
  local SSynHuanhuiInfo = require("netio.protocol.mzm.gsp.huanhun.SSynHuanhuiInfo")
  if p.status == SSynHuanhuiInfo.ST_HUN__HAND_UP then
    local huanhun = require("Main.activity.ui.Huanhun").Instance()
    local myRoleID = _G.GetMyRoleID()
    local targetRoleID = huanhun:GetTargetRoleID()
    if targetRoleID ~= nil and targetRoleID == myRoleID and huanhun:IsShow() then
      huanhun:HideDlg()
    end
  else
    local huanhun = require("Main.activity.ui.Huanhun").Instance()
    if huanhun:IsShow() then
      huanhun:_FillAward()
    end
  end
  activityInterface:_refreshActivityRequirements()
end
def.static("table").OnSCheckXItemInfoRep = function(p)
  local huanhun = require("Main.activity.ui.Huanhun").Instance()
  local huanhunItemInfos = p.itemInfos
  huanhun._forceSelectedIndex = p.itemIndex
  huanhun:ShowDlg(p.roleIdChecked, huanhunItemInfos)
end
def.static("table").OnSAddXItemInfoRep = function(p)
  local myRoleID = _G.GetMyRoleID()
  if p.roleIdSeekHelp == myRoleID then
    activityInterface._huanhunItemInfos[p.itemIndex] = p.itemInfo
    activityInterface:_refreshActivityRequirements()
  end
  local huanhun = require("Main.activity.ui.Huanhun").Instance()
  local targetRoleID = huanhun:GetTargetRoleID()
  if targetRoleID ~= nil and targetRoleID == p.roleIdSeekHelp then
    huanhun._huanhunItemInfos[p.itemIndex] = p.itemInfo
    huanhun:Fill()
  end
end
def.static("table").OnSNextTaskItemsRep = function(p)
  activityInterface._huanhunNextItem = p.itemIds
end
def.static("table").OnSHuanhunNormalResult = function(p)
  if p.result == p.SEEK_HELP_GANG__LEFT_NUM_NULL then
    Toast(textRes.activity[210])
  elseif p.result == p.SEEK_HELP_GANG__REPEAT then
    Toast(textRes.activity[211])
  elseif p.result == p.SEEK_HELP_GANG__NO_GANG then
    Toast(textRes.activity[212])
  elseif p.result == p.ADD_ITEM__FULL then
  elseif p.result == p.ADD_ITEM__COUNT_ERROR then
  elseif p.result == p.ADD_ITEM__ID_ERROR then
  elseif p.result == p.SEEK_HELP_GANG__NO_ENOUGH_FULL_BOX then
  elseif p.result == p.CHECK_OTHER_HELP_ITEM__OUT_TIME then
    Toast(textRes.activity[216])
  elseif p.result == p.HELP_OTHER_COUNT_NULL then
    Toast(textRes.activity[217])
  elseif p.result == p.HELP_OTHER_FORBID_NON_LEVEL then
    Toast(textRes.activity[218])
  end
end
def.static("table").OnSSeekHelpFromGangReq = function(p)
  local itemInfo = activityInterface._huanhunItemInfos[p.itemIndex]
  local ItemInfo = require("netio.protocol.mzm.gsp.huanhun.ItemInfo")
  itemInfo.gangHelpState = ItemInfo.ST_HELP__TRUE
  Toast(textRes.activity[213])
  activityInterface._seekHelpLeftCount = math.max(activityInterface._seekHelpLeftCount - 1, 0)
  local huanhun = require("Main.activity.ui.Huanhun").Instance()
  local myRoleID = _G.GetMyRoleID()
  local targetRoleID = huanhun:GetTargetRoleID()
  if huanhun:IsShow() == true and targetRoleID ~= nil and targetRoleID == myRoleID then
    huanhun._huanhunItemInfos[p.itemIndex].gangHelpState = ItemInfo.ST_HELP__TRUE
    huanhun:_FillItems()
    huanhun:SelectANotFinishedItem()
    huanhun:_FillSelectedItem()
  end
end
def.static("table").OnSGangHelpAddItemSuc = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local dispName = ""
  local itembase = ItemUtils.GetItemBase2(p.itemCfgId)
  if itembase ~= nil then
    dispName = itembase.name
  else
    local filterCfg = ItemUtils.GetItemFilterCfg(p.itemCfgId)
    dispName = filterCfg.name
  end
  local GangModule = require("Main.Gang.GangModule")
  local display = string.format(textRes.activity[221], p.roleNameOfferHelp, p.roleNameSeekHelp, dispName, p.itemNum)
  GangModule.ShowInGangChannel(display)
end
def.static("table").OnSynGangHelpInfo = function(p)
  warn("-------OnSynGangHelpInfo-----")
  for roleId, v in pairs(p.gangHelpInfo.role2helpData) do
    activityInterface._huanhunGangHelpInfo[roleId:ToNumber()] = v.boxIndex2Data
  end
end
def.static("table").OnSRmGangAllHelp = function(p)
  warn("-------OnSRmGangAllHelp=======")
  activityInterface._huanhunGangHelpInfo = {}
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Huanhun_GangHelInfoChange, {isAdd = false})
end
def.static("table").OnSRmGangHelpCache = function(p)
  warn("-------OnSRmGangHelpCache======")
  activityInterface._huanhunGangHelpInfo = {}
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Huanhun_GangHelInfoChange, {isAdd = false})
end
def.static("table").OnSRmGangHelp = function(p)
  warn("-------OnSRmGangHelp------")
  local helpInfo = activityInterface._huanhunGangHelpInfo[p.roleId:ToNumber()]
  if helpInfo then
    for i, v in pairs(p.boxIndexs) do
      helpInfo[v] = nil
    end
    local isOwnHelpInfo = false
    for i, v in pairs(helpInfo) do
      if v then
        isOwnHelpInfo = true
        break
      end
    end
    if not isOwnHelpInfo then
      activityInterface._huanhunGangHelpInfo[p.roleId:ToNumber()] = nil
    end
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Huanhun_GangHelInfoChange, {isAdd = false})
end
def.static("table").OnSAddGangHelp = function(p)
  warn("-------OnAddGangHelp:", p.roleId:ToNumber())
  local helpInfo = activityInterface._huanhunGangHelpInfo[p.roleId:ToNumber()] or {}
  for i, v in pairs(p.boxIndex2Data) do
    helpInfo[i] = v
  end
  activityInterface._huanhunGangHelpInfo[p.roleId:ToNumber()] = helpInfo
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Huanhun_GangHelInfoChange, {isAdd = true})
end
HuanhunProtocols.Commit()
return HuanhunProtocols
