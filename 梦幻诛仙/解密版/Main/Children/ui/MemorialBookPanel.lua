local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MemorialBookPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
local Child = require("Main.Children.Child")
local ChildrenModule = require("Main.Children.ChildrenModule")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local GrowthMemo = require("Main.Children.data.GrowthMemo")
local def = MemorialBookPanel.define
local instance
def.static("=>", MemorialBookPanel).Instance = function()
  if instance == nil then
    instance = MemorialBookPanel()
  end
  return instance
end
def.field("table").m_uiObjs = nil
def.field(GrowthMemo).m_memo = nil
def.method(GrowthMemo).ShowPanel = function(self, memo)
  if self.m_panel ~= nil then
    self:DestroyPanel()
  end
  self.m_memo = memo
  self:CreatePanel(RESPATH.PREFAB_CHILDREN_MEMORIAL_BOOK, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  if self:InitData() == false then
    self:DestroyPanel()
    return
  end
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_uiObjs = nil
  self.m_memo = nil
end
def.override("boolean").OnShow = function(self, s)
end
def.method("=>", "boolean").InitData = function(self)
  return true
end
def.method().InitUI = function(self)
  self.m_uiObjs = {}
  self.m_uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_uiObjs.Group_Message = self.m_uiObjs.Img_Bg:FindDirect("Group_Message")
  self.m_uiObjs.Img_Bg_Note = self.m_uiObjs.Img_Bg:FindDirect("Img_Bg_Note")
  self.m_uiObjs.Scrollview_Note = self.m_uiObjs.Img_Bg_Note:FindDirect("Scrollview_Note")
  self.m_uiObjs.Drag_Tips = self.m_uiObjs.Scrollview_Note:FindDirect("Drag_Tips")
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  end
end
def.method().UpdateUI = function(self)
  self:UpdateGeneralInfos()
  self:UpdateMemoUnits()
end
def.method().UpdateGeneralInfos = function(self)
  local Label_BirthDay = self.m_uiObjs.Group_Message:FindDirect("Label_BirthDay")
  local Label_Family = self.m_uiObjs.Group_Message:FindDirect("Label_Family")
  local Label_Date1 = self.m_uiObjs.Group_Message:FindDirect("Label_Date1")
  local Label_Date2 = self.m_uiObjs.Group_Message:FindDirect("Label_Date2")
  local memo = self.m_memo
  local text = string.format(textRes.Children[4203], self:FormatTime(memo:GetBirthTime()))
  GUIUtils.SetText(Label_BirthDay, text)
  local timeText = self:FormatTime(memo:GetEnterChildhoodTime())
  text = ""
  if timeText ~= "" then
    text = string.format(textRes.Children[4205], timeText)
  end
  GUIUtils.SetText(Label_Date1, text)
  local timeText = self:FormatTime(memo:GetEnterAdultTime())
  text = ""
  if timeText ~= "" then
    text = string.format(textRes.Children[4206], timeText)
  end
  GUIUtils.SetText(Label_Date2, text)
  local owners = memo:GetChildOwners()
  local text = "nil"
  if owners then
    local strTable = {}
    for i, v in ipairs(owners) do
      local name = v:GetName()
      table.insert(strTable, name)
    end
    text = table.concat(strTable, textRes.Children[4208])
  end
  local text = string.format(textRes.Children[4204], text)
  GUIUtils.SetText(Label_Family, text)
end
def.method().UpdateMemoUnits = function(self)
  local memoUnites = self.m_memo:GetMemoUnits()
  local orderedUnites = {}
  for i, v in ipairs(memoUnites) do
    table.insert(orderedUnites, {i = i, v = v})
  end
  table.sort(orderedUnites, function(l, r)
    local occurTimeL = l.v:GetOccurTime()
    local occurTimeR = r.v:GetOccurTime()
    if occurTimeL ~= occurTimeR then
      return occurTimeL > occurTimeR
    else
      return l.i > r.i
    end
  end)
  local strTable = {}
  for i, ov in ipairs(orderedUnites) do
    local memoUnit = ov.v
    local occurTime = self:FormatTime(memoUnit:GetOccurTime())
    local eventText = memoUnit:GetFormattedText()
    local line = string.format(textRes.Children[4209], occurTime, eventText)
    table.insert(strTable, line)
  end
  local content = table.concat(strTable, "\n")
  GUIUtils.SetText(self.m_uiObjs.Drag_Tips, content)
end
def.method("userdata", "=>", "string").FormatTime = function(self, timestamp)
  if timestamp == nil or timestamp:eq(0) then
    return ""
  end
  timestamp = timestamp:ToNumber()
  local t = AbsoluteTimer.GetServerTimeTable(timestamp)
  return string.format(textRes.Children[4207], t.year, t.month, t.day)
end
return MemorialBookPanel.Commit()
