local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgFormationTip = Lplus.Extend(ECPanelBase, "DlgFormationTip")
local Vector = require("Types.Vector")
local FormationModule = Lplus.ForwardDeclare("FormationModule")
local FormationUtils = require("Main.Formation.FormationUtils")
local GUIUtils = require("GUI.GUIUtils")
local def = DlgFormationTip.define
def.field("table").mainFormationInfo = nil
def.field("table").compareFormationInfo = nil
def.field("function").callbackOnHide = nil
def.field("table").callbackContent = nil
def.field("number").position = 0
def.method("table", "table", "number", "function", "table").ShowFormationTip = function(self, mainFormationInfo, compareFormationInfo, position, cb, cbContent)
  self.mainFormationInfo = mainFormationInfo
  self.compareFormationInfo = compareFormationInfo
  self.position = position
  self.callbackOnHide = cb
  self.callbackContent = cbContent
  self:CreatePanel(RESPATH.FORMATION_TIP_DLG, 2)
  self:SetOutTouchDisappear()
  Event.RegisterEventWithContext(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgFormationTip.OnLeaveFight, self)
end
def.override().OnCreate = function(self)
  self:UpdatePanel()
  self:UpdatePosition()
end
def.override().OnDestroy = function(self)
  if self.callbackOnHide then
    self.callbackOnHide(self.callbackContent)
  end
  self.callbackOnHide = nil
  self.callbackContent = nil
  self = nil
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgFormationTip.OnLeaveFight)
end
def.method().UpdatePanel = function(self)
  local prefix = ""
  if self.position > 0 then
    prefix = textRes.Formation[22]
  elseif self.position < 0 then
    prefix = textRes.Formation[23]
  end
  local title = self.m_panel:FindDirect("Img_Bg0/Label_Name"):GetComponent("UILabel")
  title:set_text(prefix .. string.format(textRes.Formation[12], self.mainFormationInfo.level) .. self.mainFormationInfo.name)
  local infoGroup = self.m_panel:FindDirect("Img_Bg0/Group_Info")
  for i = 1, 5 do
    local desc = infoGroup:FindDirect(string.format("Group%d/Label_Des", i)):GetComponent("UILabel")
    local effect = self.mainFormationInfo.Effect[i]
    local effectA = ""
    if effect.EffectA then
      local isGood = effect.EffectA.isGood and 0 <= effect.EffectA.value or not effect.EffectA.isGood and 0 > effect.EffectA.value
      local formatStr = isGood and textRes.Formation[19] or textRes.Formation[20]
      effectA = string.format(formatStr, effect.EffectA.str)
    end
    local effectB = ""
    if effect.EffectB then
      local isGood = effect.EffectB.isGood and 0 <= effect.EffectB.value or not effect.EffectB.isGood and 0 > effect.EffectB.value
      local formatStr = isGood and textRes.Formation[19] or textRes.Formation[20]
      effectB = string.format(formatStr, effect.EffectB.str)
    end
    desc:set_text(effectA .. effectB)
  end
  local desc = self.m_panel:FindDirect("Img_Bg0/Label_Describe"):GetComponent("UILabel")
  if self.compareFormationInfo == nil then
    desc:set_text(string.format(textRes.Formation[10]))
  elseif self.mainFormationInfo.KZInfo[self.compareFormationInfo.id] ~= nil then
    desc:set_text(string.format(textRes.Formation[8], self.mainFormationInfo.KZInfo[self.compareFormationInfo.id].value / 100))
  elseif self.mainFormationInfo.BKInfo[self.compareFormationInfo.id] ~= nil then
    desc:set_text(string.format(textRes.Formation[9], self.mainFormationInfo.BKInfo[self.compareFormationInfo.id].value / 100))
  else
    desc:set_text(string.format(textRes.Formation[10]))
  end
  local labelTip = self.m_panel:FindDirect("Img_Bg0/Label_Tip")
  if self.position > 0 then
    labelTip:SetActive(true)
  else
    labelTip:SetActive(false)
  end
  local bg = self.m_panel:FindDirect("Img_Bg0")
  local bgTable = bg:GetComponent("UITableResizeBackground")
  bgTable:Reposition()
end
def.method().UpdatePosition = function(self)
  local bg = self.m_panel:FindDirect("Img_Bg0")
  local bgSprite = bg:GetComponent("UISprite")
  local width = bgSprite:get_width()
  local height = bgSprite:get_height()
  local screenHeight = require("GUI.ECGUIMan").Instance().m_uiRootCom:get_activeHeight()
  local screenWidth = screenHeight / Screen.height * Screen.width
  if self.position == 0 then
    bg.localPosition = Vector.Vector3.zero
  elseif self.position > 0 then
    local y = screenHeight * 0.5
    local x = screenWidth * 0.5 - width * 0.5
    bg.localPosition = Vector.Vector3.new(x, y, 0)
  elseif self.position < 0 then
    local y = screenHeight * 0.5
    local x = screenWidth * -0.5 + width * 0.5
    bg.localPosition = Vector.Vector3.new(x, y, 0)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  local self = p1
  self:DestroyPanel()
end
DlgFormationTip.Commit()
return DlgFormationTip
