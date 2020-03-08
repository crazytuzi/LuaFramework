local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonUISmallTip = Lplus.Extend(ECPanelBase, "CommonUISmallTip")
local def = CommonUISmallTip.define
def.field("string").content = ""
def.field("number").sourceX = 0
def.field("number").sourceY = 0
def.field("number").sourceW = 0
def.field("number").sourceH = 0
def.field("number").prefer = 0
def.field("string").tipType = "x"
def.field("userdata").ui_Table_Tips = nil
def.field("userdata").ui_Label_Describe = nil
local instance
def.static("=>", CommonUISmallTip).Instance = function()
  if instance == nil then
    instance = CommonUISmallTip()
  end
  return instance
end
def.method("string", "number", "number", "number", "number", "number").ShowTip = function(self, content, sourceX, sourceY, sourceW, sourceH, prefer)
  self.content = content
  self.sourceX = sourceX
  self.sourceY = sourceY
  self.sourceW = sourceW
  self.sourceH = sourceH
  self.prefer = prefer
  self.tipType = "x"
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_SMALL_TIP_PANEL_RES, 2)
    self:SetOutTouchDisappear()
  end
end
def.method("string", "number", "number", "number", "number", "number").ShowTipY = function(self, content, sourceX, sourceY, sourceW, sourceH, prefer)
  self.content = content
  self.sourceX = sourceX
  self.sourceY = sourceY
  self.sourceW = sourceW
  self.sourceH = sourceH
  self.prefer = prefer
  self.tipType = "y"
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_SMALL_TIP_PANEL_RES, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().HideTip = function(self)
  self:DestroyPanel()
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
  self.content = ""
  self.ui_Table_Tips = nil
  self.ui_Label_Describe = nil
end
def.method().InitUI = function(self)
  self.ui_Label_Describe = self.m_panel:FindDirect("Label_Describe")
  self.ui_Table_Tips = self.ui_Label_Describe:FindDirect("Table_Tips")
end
def.method().UpdateInfo = function(self)
  self:UpdateContent()
  self.m_panel:SetActive(true)
  local tipFrame = self.ui_Table_Tips
  self:UpdatePosition()
  GameUtil.AddGlobalLateTimer(0, true, function()
    GameUtil.AddGlobalLateTimer(0, true, function()
      if self.m_panel and not self.m_panel.isnil then
        self:UpdatePosition()
      end
    end)
  end)
end
def.method().UpdateContent = function(self)
  local label = self.ui_Label_Describe:GetComponent("UILabel")
  label:set_text(self.content)
  label:UpdateNGUIText()
end
def.method().UpdatePosition = function(self)
  local ui_Table_Tips = self.ui_Table_Tips
  local tipWidth = ui_Table_Tips:GetComponent("UISprite"):get_width()
  local tipHeight = ui_Table_Tips:GetComponent("UISprite"):get_height()
  local adjustedY = self.sourceY
  if adjustedY > 0 then
    adjustedY = adjustedY + (tipHeight - self.sourceH) / 2
  else
    adjustedY = adjustedY - (tipHeight - self.sourceH) / 2
  end
  local targetX, targetY = self.sourceX, adjustedY
  if self.tipType == "x" then
    targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPosition(self.sourceX, adjustedY, self.sourceW, self.sourceH, tipWidth, tipHeight, self.prefer)
  elseif self.tipType == "y" then
    targetX, targetY = require("Common.MathHelper").ComputeTipsAutoPositionY(self.sourceX, adjustedY, self.sourceW, self.sourceH, tipWidth, tipHeight, self.prefer)
  end
  local tipFrame = self.ui_Label_Describe
  tipFrame:set_localPosition(Vector.Vector3.new(targetX, targetY, 0))
end
CommonUISmallTip.Commit()
return CommonUISmallTip
