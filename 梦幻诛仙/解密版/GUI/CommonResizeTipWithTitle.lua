local Lplus = require("Lplus")
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonResizeTipWithTitle = Lplus.Extend(ECPanelBase, "CommonResizeTipWithTitle")
local GUIMan = require("GUI.ECGUIMan")
local def = CommonResizeTipWithTitle.define
def.field("string").content = ""
def.field("string").title = ""
def.field("number").sourceX = 0
def.field("number").sourceY = 0
def.field("number").sourceW = 0
def.field("number").sourceH = 0
def.field("boolean").fitPosition = true
def.field("number").x = 0
def.field("number").y = 0
local instance
def.static("=>", CommonResizeTipWithTitle).Instance = function()
  if instance == nil then
    instance = CommonResizeTipWithTitle()
  end
  return instance
end
def.method("string", "string", "number", "number", "number", "number").ShowTip = function(self, title, content, sourceX, sourceY, sourceW, sourceH)
  self.title = title
  self.content = content
  self.sourceX = sourceX
  self.sourceY = sourceY
  self.sourceW = sourceW
  self.sourceH = sourceH
  self.fitPosition = true
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_RESIZE_TITLE_TIP, 2)
    self:SetOutTouchDisappear()
  end
end
def.method("userdata", "string", "string").ShowTargetTip = function(self, targetObj, title, content)
  if targetObj == nil then
    return
  end
  local position = targetObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = targetObj:GetComponent("UIWidget")
  self:ShowTip(title, content, screenPos.x, screenPos.y, widget.width, widget.height)
end
def.method("string", "string", "number", "number").ShowTipWithPos = function(self, title, content, x, y)
  self.title = title
  self.content = content
  self.x = x
  self.y = y
  self.fitPosition = false
  if self:IsShow() then
    self:UpdateInfo()
  else
    self:CreatePanel(RESPATH.PREFAB_COMMON_RESIZE_TITLE_TIP, 2)
    self:SetOutTouchDisappear()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateInfo()
end
def.override().OnDestroy = function(self)
  self.title = ""
  self.content = ""
end
def.method().UpdateInfo = function(self)
  self:UpdateContent()
  self.m_panel:SetActive(true)
  self:UpdatePosition()
end
def.method().UpdateContent = function(self)
  self.m_panel:FindDirect("Img_Bg/Label_Title"):GetComponent("UILabel").text = self.title
  self.m_panel:FindDirect("Img_Bg/Label_Describe"):GetComponent("UILabel").text = self.content
end
def.method().UpdatePosition = function(self)
  if self.fitPosition then
    local ui_Frame = self.m_panel:FindDirect("Img_Bg")
    local wgt = ui_Frame:GetComponent("UIWidget")
    local screenHeight = GUIMan.Instance().m_uiRootCom:get_activeHeight()
    local screenWidth = screenHeight / Screen.height * Screen.width
    local targetX, targetY = 0, 0
    if self.sourceY - wgt.height + self.sourceH / 2 < -screenHeight / 2 then
      targetY = self.sourceY - self.sourceH / 2 + wgt.height / 2
    else
      targetY = self.sourceY + self.sourceH / 2 - wgt.height / 2
    end
    if self.sourceX - self.sourceW / 2 - wgt.width < -screenWidth / 2 then
      targetX = self.sourceX + self.sourceW / 2 + wgt.width / 2
    else
      targetX = self.sourceX - self.sourceW / 2 - wgt.width / 2
    end
    self.m_panel.localPosition = Vector.Vector3.new(targetX, targetY, 0)
  else
    self.m_panel.localPosition = Vector.Vector3.new(self.x, self.y, 0)
  end
end
CommonResizeTipWithTitle.Commit()
return CommonResizeTipWithTitle
