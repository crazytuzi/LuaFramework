local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ActivatePanel = Lplus.Extend(ECPanelBase, "ActivatePanel")
local def = ActivatePanel.define
local LoginUIMgr = require("Main.Login.LoginUIMgr")
local LoginUtility = require("Main.Login.LoginUtility")
local ActivateMgr = require("Main.Login.ActivateMgr")
def.field("table").uiObjs = nil
local instance
def.static("=>", ActivatePanel).Instance = function()
  if instance == nil then
    instance = ActivatePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  LoginUtility.CreateLoginBackground()
  self:CreatePanel(RESPATH.PREFAB_ACTIVE_ACCOUNT_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.uiObjs = {}
  self.uiObjs.input = self.m_panel:FindDirect("Img_Bg/Img_BgInput/Label"):GetComponent("UIInput")
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ACTIVATE_SUCCESS, ActivatePanel.OnActivateSuccess)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ACTIVATE_SUCCESS, ActivatePanel.OnActivateSuccess)
  self.uiObjs = nil
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Active" then
    self:OnActivateButtonClick()
  elseif id == "Btn_Back" then
    self:OnBackButtonClick()
  end
end
def.method().OnActivateButtonClick = function(self)
  local key = self.uiObjs.input.value
  if key == "" then
    Toast(textRes.Login[26])
    return
  end
  local result = ActivateMgr.Instance():Activate(key)
  if result == false then
    Toast(textRes.Login[37])
  end
end
def.method().OnBackButtonClick = function(self)
  self:DestroyPanel()
  LoginUIMgr.Instance():ShowChooseServerUI()
end
def.static("table", "table").OnActivateSuccess = function()
  instance:DestroyPanel()
end
return ActivatePanel.Commit()
