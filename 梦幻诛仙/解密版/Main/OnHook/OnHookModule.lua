local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local OnHookModule = Lplus.Extend(ModuleBase, "OnHookModule")
require("Main.module.ModuleId")
local OnHookPanel = require("Main.OnHook.ui.OnHookPanel")
local OnHookUtils = require("Main.OnHook.OnHookUtils")
local DoublePointData = require("Main.OnHook.DoublePointData")
local HeroModule = require("Main.Hero.HeroModule")
local ItemUtils = require("Main.Item.ItemUtils")
local def = OnHookModule.define
local instance
def.field(OnHookPanel)._dlg = nil
def.field(DoublePointData)._data = nil
def.field("boolean").bWaitToOnHook = false
def.static("=>", OnHookModule).Instance = function()
  if nil == instance then
    instance = OnHookModule()
    instance._dlg = OnHookPanel.Instance()
    instance._data = DoublePointData.Instance()
    instance.m_moduleId = ModuleId.ONHOOK
  end
  return instance
end
def.override().Init = function(self)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_AUTOFIGHT_CLICK, OnHookModule._onShow)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.LONG_PRESS_BTN_AUTOFIGHT, OnHookModule._onHook)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guaji.SSyncDoublePoint", OnHookModule._onSDoublePoint)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guaji.SGetPointRes", OnHookModule._onSGetPoint)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guaji.SFrozenPointRes", OnHookModule._onSFrozenPoint)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResUseDoublePoint", OnHookModule._onSResUseDoublePoint)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guaji.SSyncDoubleItemuseCount", OnHookModule._onSSynDoubleItemuseCount)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.guaji.SChangeSwitchSuccess", OnHookModule._onSChangeSwitchSuccess)
  Event.RegisterEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.DOUBLEPOINTCHANGE, OnHookModule.OnDoublePointChange)
  Event.RegisterEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.NEWDOUBLEPOINT, OnHookModule.OnGetNewDoublePoint)
  Event.RegisterEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.FROZENPOINT, OnHookModule.OnFrozenDoublePoint)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, OnHookModule.ShowOnHook)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_DoubleTip, OnHookModule.OnActivityDoubleTip)
  Event.RegisterEvent(ModuleId.MAP, gmodule.notifyId.Map.MAP_CHANGE, OnHookModule.OnMapChange)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  local data = self._data
  data:SetAllNull()
end
def.static("table", "table").ShowOnHook = function(p1, p2)
  local id = p1[1]
  if id == require("Main.activity.ActivityInterface").DigongGuaye_ACTIVITY_ID then
    OnHookModule._onShow(nil, nil)
  end
end
def.static("table", "table").OnActivityDoubleTip = function(p1, p2)
  OnHookPanel.JudgeIfPointEnough(false, false, true)
end
def.static("table", "table").OnMapChange = function(p1, p2)
  if OnHookModule.Instance().bWaitToOnHook and false == PlayerIsInFight() then
    GameUtil.AddGlobalTimer(0.1, true, function()
      local PubroleModule = require("Main.Pubrole.PubroleModule")
      local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
      if true == PubroleModule.Instance():IsInFollowState(heroProp.id) then
        Toast(textRes.OnHook[20])
        return
      end
      local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
      if heroModule:IsInState(RoleState.ESCORT) then
        Toast(textRes.OnHook[22])
        return
      end
      HeroModule.Instance():Patrol()
      OnHookModule.Instance().bWaitToOnHook = false
    end)
  elseif HeroModule.Instance():IsPatroling() then
    HeroModule.Instance():StopPatroling()
  end
end
def.static("number").EnterOneMapToOnHook = function(mapId)
  if PlayerIsInFight() then
    Toast(textRes.OnHook[21])
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule:IsInState(RoleState.ESCORT) then
    Toast(textRes.OnHook[22])
    return
  end
  local PubroleModule = require("Main.Pubrole.PubroleModule")
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if true == PubroleModule.Instance():IsInFollowState(heroProp.id) then
    Toast(textRes.OnHook[20])
    return
  end
  local curMapId = require("Main.Map.MapModule").Instance():GetMapId()
  local bSameMap = curMapId == mapId
  if false == bSameMap then
    if HeroModule.Instance():EnterMap(mapId, nil) then
      OnHookModule.Instance().bWaitToOnHook = true
    end
  else
    HeroModule.Instance():Patrol()
  end
end
def.static().EnterRecommendMapToOnHook = function()
  local mapId = require("Main.OnHook.OnHookData").GetRecommendOnHookMapId()
  OnHookModule.EnterOneMapToOnHook(mapId)
end
def.static("table", "table")._onShow = function(p1, p2)
  OnHookModule.ShowPanel()
end
def.static().ShowPanel = function()
  if instance._dlg.m_panel == nil then
    instance._dlg:SetModal(true)
    instance._dlg:CreatePanel(RESPATH.PREFAB_ON_HOOK_PANEL, 1)
  else
    instance._dlg:DestroyPanel()
  end
end
def.static("table", "table")._onHook = function(p1, p2)
  if PlayerIsInFight() then
    Toast(textRes.OnHook[21])
    return
  end
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  if heroModule:IsInState(RoleState.ESCORT) then
    Toast(textRes.OnHook[22])
    return
  end
  local mapId = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapId()
  local isInOnHookMap = require("Main.OnHook.OnHookData").IsOnHookMap(mapId)
  if not isInOnHookMap then
    Toast(textRes.OnHook[28])
    return
  end
  local PubroleModule = require("Main.Pubrole.PubroleModule")
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if true == PubroleModule.Instance():IsInFollowState(heroProp.id) then
    Toast(textRes.OnHook[20])
    return
  end
  if HeroModule.Instance():IsPatroling() then
    HeroModule.Instance():StopPatroling()
  else
    OnHookPanel.JudgeIfPointEnough(true, true, false)
  end
end
def.static("table", "table").OnDoublePointChange = function(p1, p2)
  if nil ~= instance._dlg and nil ~= instance._dlg.m_panel then
    instance._dlg:UpdateDoublePointLabel(p1[1], p1[2])
  end
end
def.static("table", "table").OnGetNewDoublePoint = function(p1, p2)
  Toast(string.format(textRes.OnHook[2], p1[1]))
end
def.static("table", "table").OnFrozenDoublePoint = function(p1, p2)
  local num = OnHookUtils.GetFrozenOnceCostNum()
  Toast(string.format(textRes.OnHook[5], num))
end
def.static("table")._onSChangeSwitchSuccess = function(p)
  instance._data:SetIsUseDoublePoint(p.switch_type, p.open > 0)
end
def.static("table")._onSDoublePoint = function(p)
  instance._data:SetFrozenPoolPointNum(p.frozenPoolPointNum)
  instance._data:SetGetingPoolPointNum(p.getingPoolPointNum)
  if p.switches then
    for i = 1, #p.switches do
      instance._data:SetIsUseDoublePoint(p.switches[i], false)
    end
  end
  local tbl = {
    p.frozenPoolPointNum,
    p.getingPoolPointNum
  }
  Event.DispatchEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.DOUBLEPOINTCHANGE, tbl)
end
def.static("table")._onSGetPoint = function(p)
  local tbl0 = {
    p.addFrozenPoolNum
  }
  Event.DispatchEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.NEWDOUBLEPOINT, tbl0)
  instance._data:SetFrozenPoolPointNum(p.frozenPoolPointNum)
  instance._data:SetGetingPoolPointNum(p.getingPoolPointNum)
  local tbl = {
    p.frozenPoolPointNum,
    p.getingPoolPointNum
  }
  Event.DispatchEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.DOUBLEPOINTCHANGE, tbl)
  OnHookPanel.AfterGetDoublePoint()
end
def.static("table")._onSResUseDoublePoint = function(p)
  instance._data:SetDoubleItemUseCount(p.daycanusecount, p.canusecount)
  local itemBase = ItemUtils.GetItemBase(p.itemid)
  Toast(string.format(textRes.OnHook[6], itemBase.name, p.result))
  Toast(string.format(textRes.OnHook[26], p.canusecount, itemBase.name))
  OnHookPanel.AfterGetDoublePoint()
end
def.static("table")._onSSynDoubleItemuseCount = function(p)
  instance._data:SetDoubleItemUseCount(p.daycanusecount, p.weekcanusecount)
end
def.static("table")._onSFrozenPoint = function(p)
  Event.DispatchEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.FROZENPOINT, nil)
  instance._data:SetFrozenPoolPointNum(0)
  instance._data:SetGetingPoolPointNum(p.getingPoolPointNum)
  local tbl = {
    0,
    p.getingPoolPointNum
  }
  Event.DispatchEvent(ModuleId.ONHOOK, gmodule.notifyId.OnHook.DOUBLEPOINTCHANGE, tbl)
end
def.static("=>", "number").GetFrozenPoolPointNum = function()
  return instance._data:GetFrozenPoolPointNum()
end
def.static("=>", "number").GetGetingPoolPointNum = function()
  return instance._data:GetGetingPoolPointNum()
end
def.static("=>", "boolean").GetIsUseDoublePoint = function()
  local SwitchType = require("netio.protocol.mzm.gsp.guaji.SwitchType")
  return instance._data:GetIsUseDoublePoint(SwitchType.GUA_JI)
end
def.static("=>", "number").GetWeekCanUseCount = function()
  return instance._data:GetWeekCanUseCount()
end
OnHookModule.Commit()
return OnHookModule
