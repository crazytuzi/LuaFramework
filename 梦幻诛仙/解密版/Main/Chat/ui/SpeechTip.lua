local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpeechTip = Lplus.Extend(ECPanelBase, "SpeechTip")
local def = SpeechTip.define
local instance
def.const("number").LEVEL = 9
def.static("=>", SpeechTip).Instance = function()
  if instance == nil then
    instance = SpeechTip()
    instance.m_HideOnDestroy = true
    instance:SetDepth(4)
  end
  return instance
end
def.method().Open = function(self)
  if self.m_panel == nil then
    self:CreatePanel(RESPATH.PREFAB_VOICE_PANEL, -1)
  end
end
def.method("boolean").Pause = function(self, pause)
  if self:IsShow() then
    self:Switch(not pause)
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.method("number").Voice = function(self, volume)
  if self:IsShow() then
    local level = math.ceil(volume * SpeechTip.LEVEL)
    self:SetVolume(level)
  end
end
def.override().OnCreate = function(self)
  self:Switch(true)
  self:SetVolume(0)
end
def.method("boolean").Switch = function(self, on)
  if on then
    self.m_panel:FindDirect("Img_Bg/Group_Record"):SetActive(true)
    self.m_panel:FindDirect("Img_Bg/Group_Cancel"):SetActive(false)
  else
    self.m_panel:FindDirect("Img_Bg/Group_Record"):SetActive(false)
    self.m_panel:FindDirect("Img_Bg/Group_Cancel"):SetActive(true)
  end
end
def.method("number").SetVolume = function(self, level)
  local record = self.m_panel:FindDirect("Img_Bg/Group_Record")
  for i = 1, SpeechTip.LEVEL do
    local mark = record:FindDirect("Img_" .. i)
    if i <= level then
      mark:SetActive(true)
    else
      mark:SetActive(false)
    end
  end
end
SpeechTip.Commit()
return SpeechTip
