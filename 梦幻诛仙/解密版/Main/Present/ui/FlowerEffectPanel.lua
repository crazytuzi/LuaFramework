local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local FlowerEffectPanel = Lplus.Extend(ECPanelBase, "FlowerEffectPanel")
local def = FlowerEffectPanel.define
local instance
def.field("string").givePlayerName = ""
def.field("string").flowerName = ""
def.field("number").flowerNum = 0
def.field("string").recievePlayerName = ""
def.field("string").message = ""
def.field("string").color = ""
def.field("number").openTime = 0
def.static("=>", FlowerEffectPanel).Instance = function()
  if instance == nil then
    instance = FlowerEffectPanel()
  end
  return instance
end
def.method("string", "string", "number", "string", "string", "string").ShowPanel = function(self, givePlayerName, flowerName, flowerNum, recievePlayerName, message, color)
  self.givePlayerName = givePlayerName
  self.flowerName = flowerName
  self.flowerNum = flowerNum
  self.recievePlayerName = recievePlayerName
  self.message = message
  self.color = color
  self:CreatePanel(RESPATH.PREFAB_FLOWER_PANEL, 0)
  self:SetOutTouchDisappear()
end
def.override().OnCreate = function(self)
  self:UpdateInfo()
  self.openTime = 0
  Timer:RegisterIrregularTimeListener(self.OnIncTimer, self)
end
def.method("number").OnIncTimer = function(self, dt)
  self.openTime = self.openTime + dt
  if self.openTime >= 5 then
    self:DestroyPanel()
    self = nil
  end
end
def.override().OnDestroy = function(self)
  Timer:RemoveIrregularTimeListener(self.OnIncTimer)
  self.openTime = 0
end
def.method().UpdateInfo = function(self)
  local Img_Bg = self.m_panel:FindDirect("Img_Bg")
  local Label_Name1 = Img_Bg:FindDirect("Label_Name1"):GetComponent("UILabel")
  local Label_Item = Img_Bg:FindDirect("Label_Item"):GetComponent("UILabel")
  local Label_Message = Img_Bg:FindDirect("Label_Message"):GetComponent("UILabel")
  Label_Name1:set_text(self.givePlayerName)
  Label_Item:set_text(string.format(textRes.Present[19], self.color, self.flowerName, self.flowerNum))
  Label_Message:set_text(self.message)
end
return FlowerEffectPanel.Commit()
