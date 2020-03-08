local MODULE_NAME = (...)
local Lplus = require("Lplus")
local HomelandGuideMgr = Lplus.Class(MODULE_NAME)
local HomelandModule = Lplus.ForwardDeclare("HomelandModule")
local HomelandUtils = require("Main.Homeland.HomelandUtils")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local GUIUtils = require("GUI.GUIUtils")
local ECGUIMan = require("GUI.ECGUIMan")
local CommonGuideTip = require("GUI.CommonGuideTip")
local def = HomelandGuideMgr.define
def.const("table").GuideStep = {CLICK_FURNITURE_BAG_BTN = 1, CLICK_FURNITURE_ITEM = 2}
def.const("table").GuideStyleEnum = CommonGuideTip.StyleEnum
def.field("table").m_guidePanels = nil
def.field("table").m_leaveHouseHandler = nil
local instance
def.static("=>", HomelandGuideMgr).Instance = function(self)
  if instance == nil then
    instance = HomelandGuideMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.ENTER_HOUSE, HomelandGuideMgr.OnEnterHouse)
  Event.RegisterEvent(ModuleId.HOMELAND, gmodule.notifyId.Homeland.LEAVE_HOUSE, HomelandGuideMgr.OnLeaveHouse)
  Event.RegisterEvent(ModuleId.FIRST, gmodule.notifyId.First.Panel_PostCreate, HomelandGuideMgr.OnPanel_PostCreate)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, HomelandGuideMgr.OnLeaveWorld)
end
def.method("number", "=>", "string").GetStepKey = function(self, step)
  return string.format("HOMELAND_GUIDE_STEP_%d", step)
end
def.method("number", "=>", "boolean").HasGuided = function(self, step)
  local key = self:GetStepKey(step)
  return LuaPlayerPrefs.HasRoleKey(key)
end
def.method("number").MarkAsGuided = function(self, step)
  local key = self:GetStepKey(step)
  LuaPlayerPrefs.SetRoleInt(key, 1)
end
def.method("table", "string", "string", "number", "function").ShowGuideTip = function(self, panel, targetPath, content, dir, onReady)
  GameUtil.AddGlobalTimer(0, true, function()
    if panel == nil then
      return
    end
    if panel.m_panel == nil or panel.m_panel.isnil then
      self.m_guidePanels = self.m_guidePanels or {}
      self.m_guidePanels[tostring(panel)] = {
        content = content,
        targetPath = targetPath,
        dir = dir,
        onReady = onReady
      }
      return
    end
    local target = panel.m_panel:FindDirect(targetPath)
    self:ShowGuideTipOnGO(panel, target, content, dir, onReady)
  end)
end
def.method("table", "userdata", "string", "number", "function").ShowGuideTipOnGO = function(self, panel, target, content, dir, onReady)
  if target == nil then
    return
  end
  local function readyToShow()
    local guideDlg = CommonGuideTip.ShowGuideTip(content, target, dir)
    if onReady then
      onReady(guideDlg, target)
    end
  end
  local function activeCheck()
    if target.isnil then
      return
    end
    if target.activeInHierarchy then
      readyToShow()
      return
    end
    GameUtil.AddGlobalTimer(0.2, true, function()
      activeCheck()
    end)
  end
  activeCheck()
end
def.method("function").AddLeaveHouseHandler = function(self, handler)
  self.m_leaveHouseHandler = self.m_leaveHouseHandler or {}
  self.m_leaveHouseHandler[#self.m_leaveHouseHandler + 1] = handler
end
local setAutoRemove = function(go, onRemove, removeEventName)
  if go == nil or go.isnil then
    return
  end
  local msgHandler = go:GetComponent("UIEventToLua")
  if msgHandler == nil then
    msgHandler = go:AddComponent("UIEventToLua")
  end
  if msgHandler then
    local removeEventName = removeEventName or "onClick"
    local msgt = {
      [removeEventName] = function(_, id)
        if not msgHandler.isnil then
          GameObject.Destroy(msgHandler)
        end
        if onRemove then
          onRemove()
        end
      end
    }
    msgHandler:SetMsgTable(msgt, {})
  end
end
def.static("table", "table").OnEnterHouse = function()
  if not HomelandModule.Instance():IsInSelfHomeland() then
    return
  end
  if instance:HasGuided(HomelandGuideMgr.GuideStep.CLICK_FURNITURE_BAG_BTN) then
    return
  end
  local panel = require("Main.MainUI.ui.MainUIPanel").Instance()
  local targetPath = "Pnl_BtnGroup_Bottom/MenuGroup_Btn/Btn_Home"
  local content = textRes.Homeland[84]
  instance:ShowGuideTip(panel, targetPath, content, CommonGuideTip.StyleEnum.UP, function(dlg, target)
    if panel.m_panel == nil then
      return
    end
    local function removeGuideDlg()
      dlg:HideDlg()
    end
    local Btn_Home = target
    setAutoRemove(Btn_Home, removeGuideDlg)
    local Btn_Menu = panel.m_panel:FindDirect("Pnl_BtnGroup_Bottom/MenuGroup_Btn/Btn_Menu")
    setAutoRemove(Btn_Menu, removeGuideDlg)
    instance:AddLeaveHouseHandler(removeGuideDlg)
    instance:MarkAsGuided(HomelandGuideMgr.GuideStep.CLICK_FURNITURE_BAG_BTN)
  end)
end
def.static("table", "table").OnLeaveHouse = function()
  if instance.m_leaveHouseHandler then
    for i, handler in ipairs(instance.m_leaveHouseHandler) do
      handler()
    end
    instance.m_leaveHouseHandler = nil
  end
end
def.static("table", "table").OnPanel_PostCreate = function(params)
  local panel = params[2]
  if panel == nil or panel.m_panel == nil then
    return
  end
  if instance.m_guidePanels == nil then
    return
  end
  if instance.m_guidePanels[tostring(panel)] == nil then
    return
  end
  local guidePanel = instance.m_guidePanels[tostring(panel)]
  local target = panel.m_panel:FindDirect(guidePanel.targetPath)
  instance:ShowGuideTipOnGO(panel, target, guidePanel.content, guidePanel.dir, guidePanel.onReady)
  instance.m_guidePanels[tostring(panel)] = nil
end
def.static("table", "table").OnLeaveWorld = function(params)
  instance.m_guidePanels = nil
  instance.m_leaveHouseHandler = nil
end
return HomelandGuideMgr.Commit()
