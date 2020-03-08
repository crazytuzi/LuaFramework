local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChildShow = Lplus.Extend(ECPanelBase, "ChildShow")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ChildrenUtils = require("Main.Children.ChildrenUtils")
local BaseData = require("Main.Children.data.BaseData")
local SubPanel = require("Main.Children.ui.SubPanel")
local BabySubPanel = require("Main.Children.ui.BabySubPanel")
local ChatTeenSubPanel = require("Main.Children.ui.ChatTeenSubPanel")
local YouthSubPanel = require("Main.Children.ui.YouthSubPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = ChildShow.define
def.field(SubPanel).subPanel = nil
def.field(BaseData).childData = nil
def.field("table").nameList = nil
def.field("number").birthTime = -1
def.static(BaseData, "table", "number").ShowChildren = function(data, list, time)
  if data == nil then
    return
  end
  local dlg = ChildShow()
  dlg.childData = data
  dlg.nameList = list
  dlg.birthTime = time
  if dlg.childData:IsBaby() then
    dlg:CreatePanel(RESPATH.PREFAB_CHILD_SHOW_BABY, 1)
  elseif dlg.childData:IsTeen() then
    dlg:CreatePanel(RESPATH.PREFAB_CHILD_SHOW_TEEN, 1)
  elseif dlg.childData:IsYouth() then
    dlg:CreatePanel(RESPATH.PERFAB_CHILD_SHOW_YOUTH, 1)
  end
end
def.override().OnCreate = function(self)
  self:UpdateSubPanel()
  self:UpdateCommon()
  self:UpdateUnique()
end
def.override().OnDestroy = function(self)
  if self.subPanel then
    self.subPanel:Destroy()
  end
end
def.override("boolean").OnShow = function(self, show)
end
def.method().UpdateSubPanel = function(self)
  if self.childData:IsBaby() then
    self.subPanel = BabySubPanel()
    self.subPanel:Create(self.m_panel:FindDirect("Img_Bg0/Group_Right_YingEr"))
  elseif self.childData:IsTeen() then
    self.subPanel = ChatTeenSubPanel()
    self.subPanel:Create(self.m_panel:FindDirect("Img_Bg0/Group_Right_TongNian"))
  elseif self.childData:IsYouth() then
    self.subPanel = YouthSubPanel()
    self.subPanel:SetViewOnlyMode()
    self.subPanel:Create(self.m_panel:FindDirect("Img_Bg0/Group_Right_ZhangCheng"))
  end
  self.subPanel:Show(self.childData)
end
def.method().UpdateUnique = function(self)
  if self.childData:IsBaby() then
  elseif self.childData:IsTeen() then
    local times = self.childData:GetTotalCourseNum()
    local totalTimes = constant.CChildHoodConst.TOTAL_NUM
    local slider = self.m_panel:FindDirect("Img_Bg0/Slider_Study")
    local sliderLbl = slider:FindDirect("Label_Slider")
    slider:GetComponent("UISlider").value = times / totalTimes
    sliderLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", times, totalTimes))
  elseif self.childData:IsYouth() then
  end
end
def.method().UpdateCommon = function(self)
  if self.birthTime >= 0 then
    local timeTbl = require("Main.Common.AbsoluteTimer").GetServerTimeTable(self.birthTime)
    local timeStr = string.format(textRes.Children[2035], timeTbl.year, timeTbl.month, timeTbl.day, timeTbl.hour, timeTbl.min, timeTbl.sec)
    local birthLbl = self.m_panel:FindDirect("Img_Bg0/Group_Tips/Label_BirthDay")
    birthLbl:GetComponent("UILabel"):set_text(timeStr)
  else
    local birthLbl = self.m_panel:FindDirect("Img_Bg0/Group_Tips/Label_BirthDay")
    birthLbl:GetComponent("UILabel"):set_text(textRes.Children[2036])
  end
  if self.nameList and 0 <= #self.nameList then
    local parentStr = table.concat(self.nameList, ",")
    local parentLbl = self.m_panel:FindDirect("Img_Bg0/Group_Tips/Label_ParentsName")
    parentLbl:GetComponent("UILabel"):set_text(parentStr)
  else
    local parentLbl = self.m_panel:FindDirect("Img_Bg0/Group_Tips/Label_ParentsName")
    parentLbl:GetComponent("UILabel"):set_text(textRes.Children[2036])
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif self.subPanel:onClick(id) then
  end
end
def.method("string", "boolean").onToggle = function(self, id, active)
  if self.subPanel:onToggle(id, active) then
  end
end
def.method("string").onDragStart = function(self, id)
  if self.subPanel:onDragStart(id) then
  end
end
def.method("string").onDragEnd = function(self, id)
  if self.subPanel:onDragEnd(id) then
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.subPanel:onDrag(id, dx, dy) then
  end
end
return ChildShow.Commit()
