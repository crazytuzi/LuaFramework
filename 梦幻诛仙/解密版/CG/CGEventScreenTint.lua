local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local ECGUIMan = Lplus.ForwardDeclare("ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local ECPanelScreenTint = Lplus.Extend(ECPanelBase, "ECPanelScreenTint")
local def = ECPanelScreenTint.define
def.field("userdata").m_sprite = nil
def.field("userdata").m_color = nil
def.field("number").m_timer = 0
def.field("boolean").m_show = false
local m_TintInstance, s_eventObj
def.static("=>", ECPanelScreenTint).Instance = function()
  if not m_TintInstance then
    m_TintInstance = ECPanelScreenTint()
    m_TintInstance.m_depthLayer = GUIDEPTH.BOTTOMMOST
  end
  return m_TintInstance
end
def.override().OnCreate = function(self)
  if self.m_panel then
    self:Show(false)
    self.m_sprite = self.m_panel:GetComponentInChildren("UISprite")
    self:SetUISprite()
    self.m_sprite.alpha = 0
    if CG.Instance().isInArtEditor then
      self:Show(true)
    elseif self.m_show and self.m_timer == 0 then
      self.m_timer = GameUtil.AddGlobalTimer(0, true, function()
        self:Show(true)
      end)
    end
  end
end
def.override().OnDestroy = function(self)
  self:RemoveTimer()
end
def.method().SetUISprite = function(self)
  if s_eventObj then
    s_eventObj:SetUISprite(self.m_sprite)
  end
  self.m_sprite.color = self.m_color
end
def.method().ShowLater = function(self)
  if CG.Instance().isInArtEditor then
    self:Show(true)
    return
  end
  if self.m_show and self.m_timer == 0 then
    self.m_timer = GameUtil.AddGlobalTimer(0, true, function()
      self:Show(true)
      self.m_timer = 0
    end)
  end
end
def.method().RemoveTimer = function(self)
  if CG.Instance().isInArtEditor then
    return
  end
  if self.m_timer ~= 0 then
    GameUtil.RemoveGlobalTimer(self.m_timer)
    self.m_timer = 0
  end
end
ECPanelScreenTint.Commit()
local CGEventScreenTint = Lplus.Class("CGEventScreenTint")
local def = CGEventScreenTint.define
local s_inst
def.static("=>", CGEventScreenTint).Instance = function()
  if not s_inst then
    s_inst = CGEventScreenTint()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  if s_eventObj then
    s_eventObj:Finish()
  end
  s_eventObj = eventObj
  ECPanelScreenTint.Instance().m_color = dataTable.color
  ECPanelScreenTint.Instance().m_show = true
  if ECPanelScreenTint.Instance().m_panel then
    ECPanelScreenTint.Instance():ShowLater()
    ECPanelScreenTint.Instance():SetUISprite()
  else
    ECPanelScreenTint.Instance():CreatePanel(RESPATH.panel_ScreenTint)
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  ECPanelScreenTint.Instance():Show(false)
  ECPanelScreenTint.Instance():RemoveTimer()
  s_eventObj = nil
end
CGEventScreenTint.Commit()
CG.RegEvent("CGLuaEventScreenTint", CGEventScreenTint.Instance())
return ECPanelScreenTint
