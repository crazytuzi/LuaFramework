local Lplus = require("Lplus")
local RunningXuanGongData = require("Main.Soaring.data.RunningXuanGongData")
local ItemUtils = require("Main.Item.ItemUtils")
local UIRunningXuanGong
local TaskRunningXuanGong = require("Main.Soaring.proxy.TaskRunningXuanGong")
local TaskYZXGMgr = Lplus.Class("TaskYZXGMgr")
local def = TaskYZXGMgr.define
local instance
def.static("=>", TaskYZXGMgr).Instance = function()
  if instance == nil then
    instance = TaskYZXGMgr()
  end
  return instance
end
def.field("number")._mThumbsupCount = 0
def.field("number")._mTimerID = 0
def.method().Init = function(self)
  UIRunningXuanGong = require("Main.Soaring.ui.UIRunningXuanGong")
  self:_InitData()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SGetItemInDevelopItemActivitySuccess", TaskYZXGMgr.On_SGetItemInDevelopItemActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SGetItemInDevelopItemActivityFail", TaskYZXGMgr.On_SGetItemInDevelopItemActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SDevelopItemInDevelopItemActivitySuccess", TaskYZXGMgr.On_SDevelopItemInDevelopItemActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SDevelopItemInDevelopItemActivityFail", TaskYZXGMgr.On_SDevelopItemInDevelopItemActivityFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SCommitItemInDevelopItemActivitySuccess", TaskYZXGMgr.On_SCommitItemInDevelopItemActivitySuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.feisheng.SCommitItemInDevelopItemActivityFail", TaskYZXGMgr.On_SCommitItemInDevelopItemActivityFail)
  Event.RegisterEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YZXG_USE_ITEM, TaskYZXGMgr.OnUseItem)
end
def.method()._InitData = function(self)
end
def.static().Send_CGetItemInDevelopItemActivityReq = function()
  local p = require("netio.protocol.mzm.gsp.feisheng.CGetItemInDevelopItemActivityReq").new(TaskRunningXuanGong.ACTIVITY_ID)
  gmodule.network.sendProtocol(p)
end
def.static("table").On_SGetItemInDevelopItemActivitySuccess = function(p)
  local itemCfg = ItemUtils.GetItemBase(RunningXuanGongData.Instance():GetItemId())
  if itemCfg then
    Toast(string.format(textRes.Soaring.YZXG.GET_ITEM_SUCCESS, itemCfg.name))
  end
end
def.static("table").On_SGetItemInDevelopItemActivityFail = function(p)
  local SGetItemInDevelopItemActivityFail = require("netio.protocol.mzm.gsp.feisheng.SGetItemInDevelopItemActivityFail")
  if p.res == SGetItemInDevelopItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    Toast(textRes.Soaring.YZXG.MODULE_CLOSE_OR_ROLE_FORBIDDEN)
  elseif p.res == SGetItemInDevelopItemActivityFail.ROLE_STATUS_ERROR then
    Toast(textRes.Soaring.YZXG.ROLE_STATUS_ERROR)
  elseif p.res == SGetItemInDevelopItemActivityFail.PARAM_ERROR then
    Toast(textRes.Soaring.YZXG.PARAM_ERROR)
  elseif p.res == SGetItemInDevelopItemActivityFail.CHECK_NPC_SERVICE_ERROR then
    Toast(textRes.Soaring.YZXG.CHECK_NPC_SERVICE_ERROR)
  elseif p.res == SGetItemInDevelopItemActivityFail.CAN_NOT_JOIN_ACTIVITY then
    Toast(textRes.Soaring.YZXG.CAN_NOT_JOIN_ACTIVITY)
  elseif p.res == SGetItemInDevelopItemActivityFail.ALREADY_GET_ITEM then
    Toast(textRes.Soaring.YZXG.ALREADY_GET_ITEM)
  elseif p.res == SGetItemInDevelopItemActivityFail.BAG_FULL then
    Toast(textRes.Soaring.YZXG.BAG_FULL)
  end
end
def.static().Send_CDevelopItemInDevelopItemActivityReq = function()
  local p = require("netio.protocol.mzm.gsp.feisheng.CDevelopItemInDevelopItemActivityReq").new(TaskRunningXuanGong.ACTIVITY_ID, RunningXuanGongData.Instance():GetItemKey(), RunningXuanGongData.Instance():GetExpPerOperation())
  gmodule.network.sendProtocol(p)
end
def.static("table").On_SDevelopItemInDevelopItemActivitySuccess = function(p)
  Toast(string.format(textRes.Soaring.YZXG.DEVELOP_ITEM_SUCCESS, RunningXuanGongData.Instance():GetExpPerOperation()))
  Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YZXG_ADD_EXP_SUC, {
    p.real_add_extra_value
  })
end
def.static("table").On_SDevelopItemInDevelopItemActivityFail = function(p)
  local SDevelopItemInDevelopItemActivityFail = require("netio.protocol.mzm.gsp.feisheng.SDevelopItemInDevelopItemActivityFail")
  if p.res == SDevelopItemInDevelopItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    Toast(textRes.Soaring.YZXG.MODULE_CLOSE_OR_ROLE_FORBIDDEN)
  elseif p.res == SDevelopItemInDevelopItemActivityFail.ROLE_STATUS_ERROR then
    Toast(textRes.Soaring.YZXG.ROLE_STATUS_ERROR)
  elseif p.res == SDevelopItemInDevelopItemActivityFail.PARAM_ERROR then
    Toast(textRes.Soaring.YZXG.PARAM_ERROR)
  elseif p.res == SDevelopItemInDevelopItemActivityFail.CHECK_NPC_SERVICE_ERROR then
    Toast(textRes.Soaring.YZXG.CHECK_NPC_SERVICE_ERROR)
  elseif p.res == SDevelopItemInDevelopItemActivityFail.CAN_NOT_JOIN_ACTIVITY then
    Toast(textRes.Soaring.YZXG.CAN_NOT_JOIN_ACTIVITY)
  elseif p.res == SDevelopItemInDevelopItemActivityFail.EXTRA_VALUE_TO_LIMIT then
    Toast(textRes.Soaring.YZXG.EXTRA_VALUE_TO_LIMIT)
  elseif p.res == SDevelopItemInDevelopItemActivityFail.COST_FAIL then
    Toast(textRes.Soaring.YZXG.COST_FAIL_EXP)
  end
end
def.static().Send_CCommitItemInDevelopItemActivityReq = function()
  local itemkey = RunningXuanGongData.Instance():GetItemKey()
  if itemkey < 0 then
    Toast(textRes.Soaring.YZXG.COST_ITEM_FAIL)
  else
    local p = require("netio.protocol.mzm.gsp.feisheng.CCommitItemInDevelopItemActivityReq").new(TaskRunningXuanGong.ACTIVITY_ID, RunningXuanGongData.Instance():GetItemKey())
    gmodule.network.sendProtocol(p)
  end
end
def.static("table").On_SCommitItemInDevelopItemActivitySuccess = function(p)
  Event.DispatchEvent(ModuleId.SOARING, gmodule.notifyId.Soaring.YZXG_COMMIT_SUC, nil)
  local itemCfg = ItemUtils.GetItemBase(RunningXuanGongData.Instance():GetItemId())
  if itemCfg then
    Toast(string.format(textRes.Soaring.YZXG.COMMIT_ITEM_SUCCESS, itemCfg.name))
  end
end
def.static("table").On_SCommitItemInDevelopItemActivityFail = function(p)
  local SCommitItemInDevelopItemActivityFail = require("netio.protocol.mzm.gsp.feisheng.SCommitItemInDevelopItemActivityFail")
  if p.res == SCommitItemInDevelopItemActivityFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN then
    Toast(textRes.Soaring.YZXG.MODULE_CLOSE_OR_ROLE_FORBIDDEN)
  elseif p.res == SCommitItemInDevelopItemActivityFail.ROLE_STATUS_ERROR then
    Toast(textRes.Soaring.YZXG.ROLE_STATUS_ERROR)
  elseif p.res == SCommitItemInDevelopItemActivityFail.PARAM_ERROR then
    Toast(textRes.Soaring.YZXG.PARAM_ERROR)
  elseif p.res == SCommitItemInDevelopItemActivityFail.CHECK_NPC_SERVICE_ERROR then
    Toast(textRes.Soaring.YZXG.CHECK_NPC_SERVICE_ERROR)
  elseif p.res == SCommitItemInDevelopItemActivityFail.CAN_NOT_JOIN_ACTIVITY then
    Toast(textRes.Soaring.YZXG.CAN_NOT_JOIN_ACTIVITY)
  elseif p.res == SCommitItemInDevelopItemActivityFail.EXTRA_VALUE_TO_LIMIT then
    Toast(textRes.Soaring.YZXG.COST_ITEM_FAIL)
  elseif p.res == SCommitItemInDevelopItemActivityFail.EXTRA_VALUE_NOT_ENOUGH then
    Toast(textRes.Soaring.YZXG.EXTRA_VALUE_NOT_ENOUGH)
    UIRunningXuanGong.Instance():ShowPanel()
  elseif p.res == SCommitItemInDevelopItemActivityFail.AWARD_FAIL then
    Toast(textRes.Soaring.YZXG.AWARD_FAIL)
  end
end
def.static("table", "table").OnUseItem = function(p1, P2)
  warn("[TaskYZXGMgr:OnUseItem] OnUseItem!")
  UIRunningXuanGong.Instance():ShowPanel()
end
def.method().Reset = function(self)
  self._mThumbsupCount = 0
  self:ClearTimer()
end
return TaskYZXGMgr.Commit()
