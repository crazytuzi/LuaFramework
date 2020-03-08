local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local ModuleBase = require("Main.module.ModuleBase")
local WingsDataMgr = require("Main.Wings.data.WingsDataMgr")
local WingsInterface = require("Main.Wings.WingsInterface")
local WingsPropPanel = require("Main.Wings.ui.WingsPropPanel")
local WingsSkillPanel = require("Main.Wings.ui.WingsSkillPanel")
local WingsOverviewPanel = require("Main.Wings.ui.WingsOverviewPanel")
local WingsModule = Lplus.Extend(ModuleBase, "WingsModule")
local def = WingsModule.define
local instance
def.static("=>", WingsModule).Instance = function()
  if instance == nil then
    instance = WingsModule()
    instance.m_moduleId = ModuleId.WINGS
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_WINGS_CLICK, WingsModule.OnWingsBtnClicked)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_ROOT_USED, WingsModule.OnWingsRootUsed)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_EXP_ITEM_USED, WingsModule.OnWingsExpItemUsed)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_USE_ALL_EXP_ITEM, WingsModule.OnAllWingsExpItemUsed)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_VIEW_ITEM_USED, WingsModule.OnWingsViewItemUsed)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_OPEN_WINGS_PANEL_REQ, WingsModule.OnWingsOpenPanelReq)
  Event.RegisterEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_OPEN_WINGS_VIEW_PANEL_REQ, WingsModule.OnOpenWingsViewPanelReq)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SWingErrorInfo", WingsModule.OnSWingErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SSyncAllWing", WingsModule.OnSSyncAllWing)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SOpenNewWingRes", WingsModule.OnSOpenNewWingRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SRestWingPropertyRes", WingsModule.OnSRestWingPropertyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SReplaceWingPropertyRes", WingsModule.OnSReplaceWingPropertyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SUseWingExpItemRes", WingsModule.OnSUseWingExpItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseWingViewItemRes", WingsModule.OnSUseWingViewItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SWingPhaseUpRes", WingsModule.OnSWingPhaseUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SRandomSkillRes", WingsModule.OnSRandomSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SUnderstandSkillRes", WingsModule.OnSUnderstandSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SCurrentWingIndex", WingsModule.OnSCurrentWingIndex)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SResetWing", WingsModule.OnSResetWing)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SGetAllWingViewRes", WingsModule.OnSGetAllWingViewRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SWingModelDyeRes", WingsModule.OnSWingModelDyeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SChangeWingViewRes", WingsModule.OnSChangeWingViewRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SResetSkillRes", WingsModule.OnSResetSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SReplaceSkillRes", WingsModule.OnSReplaceSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.wing.SRemoveResetSkillRes", WingsModule.OnSRemoveResetSkillRes)
end
def.method("=>", "boolean").IsWingsFuncUnlocked = function(self)
  return WingsDataMgr.Instance():IsWingsFuncUnlocked()
end
def.method("number").ReqAllWingsViews = function(self, schemaIdx)
  local p = require("netio.protocol.mzm.gsp.wing.CGetAllWingViewReq").new(schemaIdx)
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnWingsBtnClicked = function(params, context)
  local WingsUtility = require("Main.Wings.WingsUtility")
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    local graphID = WingsDataMgr.WING_TASK_GRAPH_ID
    local taskID = WingsUtility.GetCurWingsTaskID()
    if taskID ~= 0 then
      Toast(textRes.Wings[36])
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskID, graphID})
    else
      Toast(textRes.Wings[37])
    end
  else
    require("Main.Wings.ui.WingsPanel").Instance():ShowPanel()
  end
end
def.static("table", "table").OnWingsRootUsed = function(params, context)
  local curRoleLevel = require("Main.Hero.HeroModule").Instance():GetHeroProp().level
  local needRoleLevel = WingsDataMgr.MIN_ROLE_LEVEL_FOR_WING
  if curRoleLevel < needRoleLevel then
    Toast(string.format(textRes.Wings[1], needRoleLevel))
    return
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  if item == nil then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseWingRootItem").new(item.uuid[1])
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnWingsExpItemUsed = function(params, context)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  if item == nil then
    return
  end
  local schemaIdx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if schemaIdx ~= 0 then
    local p = require("netio.protocol.mzm.gsp.wing.CUseWingExpItem").new(schemaIdx, item.uuid[1])
    gmodule.network.sendProtocol(p)
  end
end
def.static("table", "table").OnWingsViewItemUsed = function(params, context)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  if item == nil then
    return
  end
  local p = require("netio.protocol.mzm.gsp.item.CUseWingViewItem").new(item.uuid[1])
  gmodule.network.sendProtocol(p)
end
def.static("table", "table").OnWingsOpenPanelReq = function(params, context)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  local nodeId = params[1] or 1
  local uiPath = params[2]
  WingsInterface.OpenWingsPanelToTab(nodeId)
  if uiPath then
    local GUIUtils = require("GUI.GUIUtils")
    local light = params[3] or GUIUtils.Light.Square
    GUIUtils.AddLightEffectToPanel(uiPath, light)
  end
end
def.static("table", "table").OnOpenWingsViewPanelReq = function(params, context)
  if not WingsDataMgr.Instance():IsWingsFuncUnlocked() then
    Toast(textRes.Wings[2])
    return
  end
  if params.index ~= nil then
    WingsModule.Instance():ReqAllWingsViews(params.index)
  end
end
def.static("table", "table").OnAllWingsExpItemUsed = function(params, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(params.bagId, params.itemKey)
  if item == nil then
    return
  end
  local schemaIdx = WingsDataMgr.Instance():GetCurrentSchemaIdx()
  if schemaIdx ~= 0 then
    local p = require("netio.protocol.mzm.gsp.wing.CUseAllWingExpItem").new(schemaIdx, item.uuid[1])
    gmodule.network.sendProtocol(p)
  end
end
def.static("table").OnSSyncAllWing = function(p)
  WingsDataMgr.Instance():SetAllWingsData(p)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SYNC_INFO, nil)
end
def.static("table").OnSOpenNewWingRes = function(p)
  local isUnlockingWings = not WingsDataMgr.Instance():IsWingsFuncUnlocked()
  WingsDataMgr.Instance():AppendWingsSchema(p)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SCHEMA_CHANGED, nil)
  if isUnlockingWings then
    WingsInterface.OpenWingsPanel()
  end
end
def.static("table").OnSRestWingPropertyRes = function(p)
  WingsDataMgr.Instance():SetPropertyData(p, false)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_PROP_CHANGED, nil)
end
def.static("table").OnSReplaceWingPropertyRes = function(p)
  WingsDataMgr.Instance():SetPropertyData(p, true)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_PROP_CHANGED, nil)
  WingsDataMgr.Instance():ClearResetPropData()
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_PROP_CHANGED, nil)
end
def.static("table").OnSUseWingExpItemRes = function(p)
  WingsDataMgr.Instance():RefreshNewLevelData(p)
  if p.oldLevel < p.newLevel then
    Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_PROP_CHANGED, nil)
    Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_LEVEL_UP, nil)
  end
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_EXP_ADDED, nil)
end
def.static("table").OnSWingPhaseUpRes = function(p)
  if WingsDataMgr.Instance():GetCurrentSchemaIdx() ~= p.index then
    return
  end
  if p.hasSkill == 0 then
    Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASEUP_CONSUME, nil)
  elseif p.hasSkill == 1 then
    WingsDataMgr.Instance():SetRandomSkillTable(p)
    WingsSkillPanel.Instance():ShowPanel()
  end
end
def.static("table").OnSRandomSkillRes = function(p)
  if WingsDataMgr.Instance():GetCurrentSchemaIdx() ~= p.index then
    return
  end
  WingsDataMgr.Instance():SetRandomSkillTable(p)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RANDOM_SKILL_CHANGED, nil)
end
def.static("table").OnSUnderstandSkillRes = function(p)
  WingsDataMgr.Instance():RefreshNewPhaseData(p)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_PHASE_UP, {
    newphase = p.phase
  })
end
def.static("table").OnSCurrentWingIndex = function(p)
  WingsDataMgr.Instance():TurnOnWingSchema(p.curIndex)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_ACTIVE_SCHEMA_CHANGED, nil)
end
def.static("table").OnSResetWing = function(p)
  if not p.index then
    return
  end
  WingsDataMgr.Instance():SetWingsSchema(p)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SCHEMA_CHANGED, nil)
end
def.static("table").OnSGetAllWingViewRes = function(p)
  WingsDataMgr.Instance():SetWingsViewList(p.modelids)
  require("Main.Wings.ui.WingsViewPanel").Instance():ShowPanel(p.index)
end
def.static("table").OnSWingModelDyeRes = function(p)
  local idx = WingsDataMgr.Instance():SetWingsDyeRes(p.modelId2dyeid)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_DYED, {index = idx})
end
def.static("table").OnSChangeWingViewRes = function(p)
  WingsDataMgr.Instance():SetCurrentViewBySchemaIdx(p.index, p.isshowwing, p.modelId2dyeid)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_CURRENT_VIEW_CHANGED, nil)
end
def.static("table").OnSUseWingViewItemRes = function(p)
  Toast(textRes.Wings[3])
end
def.static("table").OnSResetSkillRes = function(p)
  WingsDataMgr.Instance():SetResetSkillInfo(p)
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_SKILL_CHANGED, nil)
end
def.static("table").OnSReplaceSkillRes = function(p)
  WingsDataMgr.Instance():ResetOneSkillGroup(p)
  WingsDataMgr.Instance():ClearResetSkillInfo()
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_SKILL_REPLACED, nil)
end
def.static("table").OnSRemoveResetSkillRes = function(p)
  WingsDataMgr.Instance():ClearResetSkillInfo()
  Event.DispatchEvent(ModuleId.WINGS, gmodule.notifyId.Wings.WINGS_RESET_SKILL_CHANGED, nil)
end
def.static("table").OnSWingErrorInfo = function(p)
  if textRes.Wings.ErrorInfo[p.resCode] ~= nil then
    Toast(textRes.Wings.ErrorInfo[p.resCode])
  end
end
def.override().OnReset = function(self)
  WingsDataMgr.Instance():ResetAllStates()
end
WingsModule.Commit()
return WingsModule
