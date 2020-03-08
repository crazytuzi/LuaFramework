local Lplus = require("Lplus")
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local ActivityInterface = require("Main.activity.ActivityInterface")
local FeatureOpenListModule = require("Main.FeatureOpenList.FeatureOpenListModule")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local FoolsDayMgr = Lplus.Class("FoolsDayMgr")
local def = FoolsDayMgr.define
local instance
def.field("boolean")._bFeatureOpen = false
def.field("table")._arrOpenedChestRoleIds = nil
def.field("table")._itemTips = nil
def.field("table")._item = nil
def.static("=>", FoolsDayMgr).Instance = function()
  if instance == nil then
    instance = FoolsDayMgr()
    instance._arrOpenedChestRoleIds = instance._arrOpenedChestRoleIds or {}
  end
  return instance
end
def.method().Init = function(self)
  local UIFoolsDay = require("Main.Festival.FoolsDay.ui.UIFoolsDay")
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SGetChestMakerNameFail", FoolsDayMgr.OnSGetChestMakerNameFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SGetChestMakerNameSuccess", FoolsDayMgr.OnSGetChestMakerNameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SOpenChestFail", FoolsDayMgr.OnSOpenChestFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SOpenChestSuccess", FoolsDayMgr.OnSOpenChestSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SSynOpenChestMakerids", FoolsDayMgr.OnSSynOpenChestMakerids)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SGetFoolsDayInfoFail", UIFoolsDay.OnSGetFoolsDayInfoFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SGetTitleFail", UIFoolsDay.OnSGetTitleFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SGetTitleSuccess", UIFoolsDay.OnSGetTitleSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SSynFoolsDayInfo", UIFoolsDay.OnSSynFoolsDayInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SMakeChestFail", UIFoolsDay.OnSMakeChestFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SMakeChestSuccess", UIFoolsDay.OnSMakeChestSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.foolsday.SRefreshAlternativeBuffCfgidsFail", UIFoolsDay.OnSRefreshAlternativeBuffCfgidsFail)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, FoolsDayMgr.OnFeatureInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, FoolsDayMgr.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, FoolsDayMgr.OnActivityTodo)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, FoolsDayMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Reset, FoolsDayMgr.OnActivityStart)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, FoolsDayMgr.OnLeaveWorld)
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  ItemTipsMgr.RegisterPostTipsHandler(ItemType.FOOLS_DAY_ACTIVITY_ITEM, FoolsDayMgr.PostTipsContentHandler)
  local ItemNode = require("Main.Present.ui.ItemNode")
  ItemNode.RegisterExtraSelectItemTip(ItemType.FOOLS_DAY_ACTIVITY_ITEM, FoolsDayMgr.ShowExtraTipInPresentPanel)
end
def.static("table", "table").OnActivityTodo = function(p, context)
  local activityId = constant.CFoolsDayConsts.ACTIVITY_CFG_ID
  if p[1] ~= activityId then
    return
  end
  local objUIFoolsDay = require("Main.Festival.FoolsDay.ui.UIFoolsDay").Instance()
  objUIFoolsDay:ToShow()
end
def.method("boolean").SetFeatureOpen = function(self, bOpen)
  self._bFeatureOpen = bOpen
end
def.method("=>", "boolean").GetFeatureOpen = function(self)
  return self._bFeatureOpen
end
def.static("=>", "number").GetFeatureType = function()
  return Feature.TYPE_FOOLS_DAY
end
def.static("=>", "number").GetOpenSameRoleChestMaxTimes = function()
  return constant.CFoolsDayConsts.OPEN_SAME_ROLE_CHEST_MAX_TIME
end
def.static("=>", "number").GetTotalOpenChestTimes = function()
  return constant.CFoolsDayConsts.OPEN_CHEST_MAX_TIME
end
def.static("=>", "number").GetOpenChestMinLevel = function()
  return constant.CFoolsDayConsts.OPEN_CHEST_MIN_LEVLE
end
def.static("userdata", "number").AddToOpenChestRoleId = function(roleId, actId)
  local self = FoolsDayMgr.Instance()
  self._arrOpenedChestRoleIds[actId] = self._arrOpenedChestRoleIds[actId] or {}
  table.insert(self._arrOpenedChestRoleIds[actId], roleId:tostring())
end
def.static("userdata", "number", "=>", "boolean").ExistInOpenedRoleList = function(roleId, actId)
  local self = FoolsDayMgr.Instance()
  local roleList = self._arrOpenedChestRoleIds[actId]
  if roleList == nil then
    return false
  end
  for i = 1, #roleList do
    if roleList[i] == roleId:tostring() then
      return true
    end
  end
  return false
end
def.static("number", "=>", "number").GetOpenedTimes = function(actId)
  local self = FoolsDayMgr.Instance()
  local roleList = self._arrOpenedChestRoleIds[actId]
  if roleList == nil then
    return 0
  end
  return #roleList
end
def.static("table", "table").SetItemTips = function(itemTips, item)
  local self = FoolsDayMgr.Instance()
  self._itemTips = itemTips
  self._item = item
end
def.static("=>", "table").GetItemTips = function()
  local self = FoolsDayMgr.Instance()
  return self._itemTips
end
def.static("table", "table", "table").PostTipsContentHandler = function(item, itemBase, itemTips)
  if itemTips == nil then
    return
  end
  FoolsDayMgr.SetItemTips(itemTips, item)
  local roleId = FoolsDayMgr.GetItemExtraInfoByItemTips(item, itemTips)
  local roleInfo = FoolsDayMgr.GetFriendInfoByRoleId(roleId)
  if roleInfo ~= nil then
    FoolsDayMgr.UpdateItemTipsContent(roleInfo.name)
    return
  end
  FoolsDayMgr.SendGetChestMakerNameReq(roleId)
end
def.static("userdata", "=>", "table").GetFriendInfoByRoleId = function(roleId)
  if roleId == nil then
    return nil
  end
  local roleInfo
  local bIsMySelf = false
  bIsMySelf, roleInfo = FoolsDayMgr.IsMySelf(roleId)
  if bIsMySelf then
    return roleInfo
  end
  local FriendData = require("Main.friend.FriendData")
  local friendInfo = FriendData.Instance():GetFriendInfo(roleId)
  if friendInfo == nil then
    return nil
  end
  roleInfo = {
    name = friendInfo.roleName,
    roleId = friendInfo.roleId
  }
  return roleInfo
end
def.static("userdata", "=>", "boolean", "table").IsMySelf = function(roleId)
  local mySelfInfo = require("Main.Hero.HeroModule").Instance():GetHeroProp()
  local bIsMySelf = mySelfInfo.id:tostring() == roleId:tostring()
  local roleInfo
  if bIsMySelf then
    roleInfo = {
      name = mySelfInfo.name,
      roleId = mySelfInfo.id
    }
  end
  return bIsMySelf, roleInfo
end
def.static("table", "table", "=>", "userdata", "number").GetItemExtraInfoByItemTips = function(item, itemTips)
  if item == nil or itemTips == nil or not itemTips:IsShow() then
    return nil, 0
  end
  local ItemUtils = require("Main.Item.ItemUtils")
  local roleId = ItemUtils.GetRoleIdByItem(item, ItemXStoreType.MAKER_ID_LOW, ItemXStoreType.MAKER_ID_HIGH)
  local buffId = item.extraMap[ItemXStoreType.BUFF_ID] or 0
  return roleId, buffId
end
def.static("string").UpdateItemTipsContent = function(strMakerName)
  local self = FoolsDayMgr.Instance()
  if self._itemTips == nil or not self._itemTips:IsShow() then
    return
  end
  local roleId, buffId = FoolsDayMgr.GetItemExtraInfoByItemTips(self._item, self._itemTips)
  if roleId == nil or buffId == 0 then
    return
  end
  local actId = self._item.extraMap[ItemXStoreType.ACTIVITY_CFG_ID] or 0
  local bOpened = FoolsDayMgr.ExistInOpenedRoleList(roleId, actId)
  local openedTimes = 0
  if bOpened then
    openedTimes = 1
  end
  local maxTimes = FoolsDayMgr.GetOpenSameRoleChestMaxTimes()
  local appendHtml = string.format(textRes.Festival.FoolsDay[18], strMakerName, openedTimes, maxTimes)
  if FoolsDayMgr.IsMySelf(roleId) then
    local buffInfo = require("Main.Buff.BuffUtility").GetBuffCfg(buffId)
    appendHtml = appendHtml .. string.format(textRes.Festival.FoolsDay[19], buffInfo.name)
  end
  self._itemTips:AppendContent(appendHtml)
end
def.static("table").ShowExtraTipInPresentPanel = function(item)
  local buffId = item.extraMap[ItemXStoreType.BUFF_ID]
  local buffInfo = require("Main.Buff.BuffUtility").GetBuffCfg(buffId)
  Toast(textRes.Festival.FoolsDay[20]:format(buffInfo.name))
end
def.static("userdata").SendGetChestMakerNameReq = function(roleId)
  if roleId == nil then
    return
  end
  warn(">>>>CGetChestMakerName<<<<")
  local p = require("netio.protocol.mzm.gsp.foolsday.CGetChestMakerName").new(roleId)
  gmodule.network.sendProtocol(p)
end
def.static("number", "userdata").SendOpenChestReq = function(grid_num, makerid)
  warn(">>>>COpenChestReq<<<<")
  local p = require("netio.protocol.mzm.gsp.foolsday.COpenChestReq").new(grid_num, makerid)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSGetChestMakerNameFail = function(p)
  warn(">>>>SGetChestMakerNameFail<<<<")
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>MAKER_ID_NOT_EXIST<<<<")
  end
end
def.static("table").OnSGetChestMakerNameSuccess = function(p)
  local strMakerName = _G.GetStringFromOcts(p.name)
  warn(">>>>strMakerName = " .. strMakerName .. "<<<<")
  FoolsDayMgr.UpdateItemTipsContent(strMakerName)
end
def.static("table").OnSOpenChestFail = function(p)
  warn(">>>>SOpenChestFail<<<<")
  if p.res == -1 then
    warn(">>>>MODULE_CLOSE_OR_ROLE_FORBIDDEN<<<<")
  elseif p.res == -2 then
    warn(">>>>ROLE_STATUS_ERROR<<<<")
  elseif p.res == -3 then
    warn(">>>>PARAM_ERROR<<<<")
  elseif p.res == -4 then
    warn(">>>>DB_ERROR<<<<")
  elseif p.res == 1 then
    warn(">>>>OPEN_CHEST_TIME_TO_LIMIT<<<<")
  elseif p.res == 2 then
    local maxTimes = FoolsDayMgr.GetOpenSameRoleChestMaxTimes()
    local item = FoolsDayMgr.Instance()._item
    if item == nil then
      return
    end
    local actId = item.extraMap[ItemXStoreType.ACTIVITY_CFG_ID] or 0
    local openedTimes = FoolsDayMgr.GetOpenedTimes(actId)
    local totalMaxtimes = FoolsDayMgr.GetTotalOpenChestTimes()
    Toast(string.format(textRes.Festival.FoolsDay[22], maxTimes, openedTimes, totalMaxtimes))
  elseif p.res == 3 then
    warn(">>>>CUT_ITEM_FAIL<<<<")
  elseif p.res == 4 then
    warn(">>>>AWARD_FAIL<<<<")
  elseif p.res == 5 then
    warn(">>>>ROLE_LEVEL_NOT_ENOUGH<<<<")
    Toast(string.format(textRes.Festival.FoolsDay[16], FoolsDayMgr.GetOpenChestMinLevel()))
  end
end
def.static("table").OnSOpenChestSuccess = function(p)
  warn(">>>>SOpenChestSuccess<<<<")
  FoolsDayMgr.AddToOpenChestRoleId(p.makerid, p.activity_cfg_id)
end
def.static("table").OnSSynOpenChestMakerids = function(p)
  local self = FoolsDayMgr.Instance()
  if self._arrOpenedChestRoleIds[p.activity_cfg_id] ~= nil then
    self._arrOpenedChestRoleIds[p.activity_cfg_id] = {}
  end
  warn(">>>>Reset openList<<<<")
  for _, v in pairs(p.open_chest_maker_ids) do
    FoolsDayMgr.AddToOpenChestRoleId(v, p.activity_cfg_id)
  end
end
def.static("boolean").UpdateActivityInterface = function(bFeatureOpen)
  local activityInterface = ActivityInterface.Instance()
  local activityId = constant.CFoolsDayConsts.ACTIVITY_CFG_ID
  if bFeatureOpen then
    activityInterface:removeCustomCloseActivity(activityId)
  else
    activityInterface:addCustomCloseActivity(activityId)
  end
end
def.static("table", "table").OnActivityStart = function(p)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local nowSec = _G.GetServerTime()
  local date = AbsoluteTimer.GetServerTimeTable(nowSec)
  if date.hour == 0 and date.min == 0 then
    local self = FoolsDayMgr.Instance()
    self._arrOpenedChestRoleIds = {}
  end
end
def.static("table", "table").OnLeaveWorld = function(p, context)
  local self = FoolsDayMgr.Instance()
  self._arrOpenedChestRoleIds = {}
end
def.static("table", "table").OnFeatureInit = function(p, context)
  local featureOpenModule = FeatureOpenListModule.Instance()
  local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_FOOLS_DAY)
  local self = FoolsDayMgr.Instance()
  self:SetFeatureOpen(bFeatureOpen)
  FoolsDayMgr.UpdateActivityInterface(bFeatureOpen)
end
def.static("table", "table").OnFeatureOpenChange = function(p, context)
  if p.feature == Feature.TYPE_FOOLS_DAY then
    local featureOpenModule = FeatureOpenListModule.Instance()
    local bFeatureOpen = featureOpenModule:CheckFeatureOpen(Feature.TYPE_FOOLS_DAY)
    local self = FoolsDayMgr.Instance()
    self:SetFeatureOpen(bFeatureOpen)
    FoolsDayMgr.UpdateActivityInterface(bFeatureOpen)
  end
end
return FoolsDayMgr.Commit()
