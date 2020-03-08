local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local LoginUpdatePanel = Lplus.Extend(ECPanelBase, "LoginUpdatePanel")
local def = LoginUpdatePanel.define
local instance
local LoginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
def.field("number").fakeUpdateProgress = 1
def.field("number").updateTime = 0
def.static("=>", LoginUpdatePanel).Instance = function()
  if instance == nil then
    instance = LoginUpdatePanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_LOGIN_UPDATE_PANEL_RES, -1)
end
def.override().OnCreate = function(self)
  self:SetUpdateProgress(0)
  self:SetUpdateVersion("0.0.0.1", "1.0.0.0")
  self:SetUpdateState("updating...")
  self:SetTips("")
  Timer:RegisterIrregularTimeListener(self.OnUpdate, self)
end
def.override().OnDestroy = function(self)
end
def.method("string").onClick = function(self, id)
  print("click:", id)
  if id == "Btn_Loading" then
  elseif id == "Btn_Close" then
    self:Hide()
  end
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method("number").OnUpdate = function(self, dt)
  local interval = 0.05
  self.updateTime = self.updateTime + dt
  if interval <= self.updateTime then
    self:OnTimer()
    self.updateTime = self.updateTime - interval
  end
end
def.method().OnTimer = function(self)
  self.fakeUpdateProgress = self.fakeUpdateProgress + 0.05
  self:SetUpdateProgress(self.fakeUpdateProgress)
  if self.fakeUpdateProgress >= 1 then
    Timer:RemoveIrregularTimeListener(self.OnUpdate)
    self:FinishUpdate()
  end
end
def.method().FinishUpdate = function(self)
  self:HidePanel()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.UPDATE_FINISH, nil)
end
def.method("number").SetUpdateProgress = function(self, rate)
  self.m_panel:FindChild("Img_BgSlider"):GetComponent("UISlider"):set_sliderValue(rate)
end
def.method("string", "string").SetUpdateVersion = function(self, curVersion, newestVersion)
  local formatText = string.format("%s: %s", textRes.Login[12], curVersion)
  self.m_panel:FindChild("Label_01"):GetComponent("UILabel"):set_text(formatText)
  local formatText = string.format("%s: %s", textRes.Login[13], newestVersion)
  self.m_panel:FindChild("Label_02"):GetComponent("UILabel"):set_text(formatText)
end
def.method("string").SetUpdateState = function(self, state)
  self.m_panel:FindChild("Label_04"):GetComponent("UILabel"):set_text(state)
end
def.method("string").SetTips = function(self, tip)
  self.m_panel:FindChild("Label_Tips"):GetComponent("UILabel"):set_text(tip)
end
return LoginUpdatePanel.Commit()
