local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleScheduleTips = Lplus.Extend(ECPanelBase, "CrossBattleScheduleTips")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local MathHelper = require("Common.MathHelper")
local def = CrossBattleScheduleTips.define
def.field("table").uiObjs = nil
def.field("string").titleStr = ""
def.field("string").timeStr = ""
def.field("table").position = nil
local instance
def.static("=>", CrossBattleScheduleTips).Instance = function()
  if instance == nil then
    instance = CrossBattleScheduleTips()
  end
  return instance
end
def.method("string", "string").ShowPanel = function(self, titleStr, timeStr)
  if self:IsShow() then
    return
  end
  self.titleStr = titleStr
  self.timeStr = timeStr
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_FIGHT_TIPS, 2)
  self:SetOutTouchDisappear()
end
def.method("string", "string", "userdata").ShowPanelAutoPos = function(self, titleStr, timeStr, source)
  if self:IsShow() then
    return
  end
  if source ~= nil then
    local widget = source:GetComponent("UIWidget")
    if widget ~= nil then
      local position = source.position
      local screenPos = WorldPosToScreen(position.x, position.y)
      self.position = {}
      self.position.sourceX = screenPos.x
      self.position.sourceY = screenPos.y
      self.position.sourceW = widget.width
      self.position.sourceH = widget.height
    else
      warn("ShowPanelAutoPos find no widget in " .. source.name)
    end
  end
  self:ShowPanel(titleStr, timeStr)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:CheckToAutoPos()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.titleStr = ""
  self.timeStr = ""
  self.position = nil
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Label_Date = self.uiObjs.Img_Bg0:FindDirect("Label_Date")
  self.uiObjs.Label_Time = self.uiObjs.Img_Bg0:FindDirect("Label_Time")
  GUIUtils.SetText(self.uiObjs.Label_Date, self.titleStr)
  GUIUtils.SetText(self.uiObjs.Label_Time, self.timeStr)
end
def.method().CheckToAutoPos = function(self)
  if self.position ~= nil then
    local bgWidget = self.uiObjs.Img_Bg0:GetComponent("UIWidget")
    if bgWidget == nil then
      return
    end
    local x, y = MathHelper.ComputeTipsAutoPosition(self.position.sourceX, self.position.sourceY, self.position.sourceW, self.position.sourceH, bgWidget.width, bgWidget.height, 0)
    self.uiObjs.Img_Bg0.localPosition = Vector.Vector3.new(x, y, 0)
  end
end
CrossBattleScheduleTips.Commit()
return CrossBattleScheduleTips
