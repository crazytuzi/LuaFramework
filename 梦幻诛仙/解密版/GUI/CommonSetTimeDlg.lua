local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonSetTimeDlg = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = CommonSetTimeDlg.define
local GROUP_NUM = 3
def.field("table").m_UIGOs = nil
def.field("string").m_title = ""
def.field("string").m_tips = ""
def.field("table").m_allOptions = nil
def.field("table").m_lastOptions = nil
def.field("table").m_selOptions = nil
def.field("function").m_callback = nil
def.field("function").m_cancelCallback = nil
def.static("string", "table", "table", "function", "=>", CommonSetTimeDlg).ShowDlg = function(title, allOptions, lastOptions, callback)
  return CommonSetTimeDlg.ShowDlgWithCancel(title, allOptions, lastOptions, callback, nil)
end
def.static("string", "table", "table", "function", "function", "=>", CommonSetTimeDlg).ShowDlgWithCancel = function(title, allOptions, lastOptions, callback, cancelCallback)
  local dlg = CommonSetTimeDlg()
  dlg:Init()
  dlg.m_title = title
  dlg.m_tips = ""
  dlg.m_allOptions = allOptions
  dlg.m_lastOptions = lastOptions
  dlg.m_callback = callback
  dlg.m_cancelCallback = cancelCallback
  dlg.m_selOptions = lastOptions and clone(lastOptions) or {}
  dlg:ShowPanel()
  return dlg
end
def.method().Init = function(self)
end
def.method("string").SetTips = function(self, tips)
  self.m_tips = tips
  if self.m_panel and self.m_panel.isnil == false then
    self:UpdateTips()
  end
end
def.method("number", "=>", "table").GetGroupOptions = function(self, groupIndex)
  return self.m_allOptions[groupIndex]
end
def.method().ShowPanel = function(self)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_GANG_DUNGEON_SET_TIME, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:CloseAllGroups()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_title = ""
  self.m_tips = ""
  self.m_allOptions = nil
  self.m_lastOptions = nil
  self.m_callback = nil
  self.m_cancelCallback = nil
  self.m_selOptions = nil
end
def.method("userdata").onClickObj = function(self, obj)
  self:CloseAllGroups()
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Sprite" and obj.parent.name == "Group_Title" then
    local grandParentId = obj.parent.parent.name
    if grandParentId == "Group_Week" then
      self:OnClickGroup(1)
    elseif grandParentId == "Group_Hour" then
      self:OnClickGroup(2)
    elseif grandParentId == "Group_Minute" then
      self:OnClickGroup(3)
    end
  elseif string.find(id, "Btn_Item_") then
    self:OnClickBtnItemObj(obj)
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn(0)
  elseif id == "Btn_Set" then
    self:OnClickConfirmBtn(1)
  elseif id == "Btn_Cancel" then
    self:OnClickCancelBtn()
  end
end
def.method().OnClickCancelBtn = function(self)
  if self.m_cancelCallback then
    local ret = self:m_cancelCallback()
    if ret == false then
      self:DestroyPanel()
    end
  end
end
def.method("number").OnClickConfirmBtn = function(self, state)
  local completed = true
  for i = 1, GROUP_NUM do
    if self.m_selOptions[i] == nil then
      completed = false
      break
    end
  end
  if not completed then
    Toast(textRes.GangDungeon[4])
    return
  end
  if self.m_callback then
    local ret = self:m_callback(self.m_allOptions, self.m_selOptions, state)
    if ret ~= false then
      self:DestroyPanel()
    end
  end
end
def.method("number").OnClickGroup = function(self, groupIndex)
  local GroupParam = self.m_UIGOs.GroupParams[groupIndex]
  self:OpenGroup(GroupParam, true)
  local groupList = GroupParam.groupList
  local options = self:GetGroupOptions(groupIndex)
  self:SetGroupList(groupList, options, {
    labelName = GroupParam.itemLabelName
  })
end
def.method("userdata").OnClickBtnItemObj = function(self, obj)
  local index = tonumber(obj.name:split("_")[3])
  local groupListGO = obj.parent.parent.parent.parent.parent
  local GroupParam
  for i, v in ipairs(self.m_UIGOs.GroupParams) do
    if groupListGO:IsEq(v.groupList) then
      GroupParam = v
      break
    end
  end
  if GroupParam == nil then
    return
  end
  local options = self:GetGroupOptions(GroupParam.i)
  local option = options[index]
  local groupGO = GroupParam.group
  local Group_Title = groupGO:FindDirect("Group_Title")
  local Label_Name = Group_Title:FindDirect(GroupParam.LabelName)
  GUIUtils.SetText(Label_Name, option.name)
  self.m_selOptions[GroupParam.i] = index
end
def.method().ResetOptions = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.m_selOptions = {}
  self.m_lastOptions = nil
  self:UpdateSelectedValues()
  self:UpdateBtns()
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.m_UIGOs.Grid_Time = self.m_UIGOs.Img_Bg0:FindDirect("Grid_Time")
  self.m_UIGOs.Group_First = self.m_UIGOs.Grid_Time:FindDirect("Group_Week")
  self.m_UIGOs.Group_FirstList = self.m_UIGOs.Group_First:FindDirect("Group_WeekList")
  self.m_UIGOs.Group_Second = self.m_UIGOs.Grid_Time:FindDirect("Group_Hour")
  self.m_UIGOs.Group_SecondList = self.m_UIGOs.Group_Second:FindDirect("Group_HourList")
  self.m_UIGOs.Group_Third = self.m_UIGOs.Grid_Time:FindDirect("Group_Minute")
  self.m_UIGOs.Group_ThirdList = self.m_UIGOs.Group_Third:FindDirect("Group_MinuteList")
  self.m_UIGOs.Btn_Confirm = self.m_UIGOs.Img_Bg0:FindDirect("Btn_Confirm")
  self.m_UIGOs.Btn_Set = self.m_UIGOs.Img_Bg0:FindDirect("Btn_Set")
  self.m_UIGOs.Btn_Cancel = self.m_UIGOs.Img_Bg0:FindDirect("Btn_Cancel")
  self.m_UIGOs.Label_Tips = self.m_UIGOs.Img_Bg0:FindDirect("Label_Tips")
  local GroupParam1 = {
    group = self.m_UIGOs.Group_First,
    groupList = self.m_UIGOs.Group_FirstList,
    ImgUpName = "Btn_ChooseWeekUp",
    ImgDownName = "Btn_ChooseWeekDown",
    LabelName = "Label_Week",
    itemLabelName = "Label_Name2"
  }
  local GroupParam2 = {
    group = self.m_UIGOs.Group_Second,
    groupList = self.m_UIGOs.Group_SecondList,
    ImgUpName = "Btn_ChooseHourUp",
    ImgDownName = "Btn_ChooseHourDown",
    LabelName = "Label_Hour",
    itemLabelName = "Label_Hour"
  }
  local GroupParam3 = {
    group = self.m_UIGOs.Group_Third,
    groupList = self.m_UIGOs.Group_ThirdList,
    ImgUpName = "Btn_ChooseMinuteUp",
    ImgDownName = "Btn_ChooseMinuteDown",
    LabelName = "Label_Minute",
    itemLabelName = "Label_Minute"
  }
  self.m_UIGOs.GroupParams = {
    GroupParam1,
    GroupParam2,
    GroupParam3
  }
  for i, v in ipairs(self.m_UIGOs.GroupParams) do
    v.i = i
  end
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateBtns()
  self:UpdateSelectedValues()
  self:UpdateTips()
end
def.method().UpdateTitle = function(self)
  local Img_SubTitle = self.m_UIGOs.Img_Bg0:FindDirect("Img_SubTitle")
  local Label_Title = Img_SubTitle:FindDirect("Label_Title")
  GUIUtils.SetText(Label_Title, self.m_title)
end
def.method().UpdateSelectedValues = function(self)
  for i, v in ipairs(self.m_UIGOs.GroupParams) do
    local GroupParam = v
    local groupGO = GroupParam.group
    local Group_Title = groupGO:FindDirect("Group_Title")
    local Label_Name = Group_Title:FindDirect(GroupParam.LabelName)
    local options = self:GetGroupOptions(GroupParam.i)
    local selIndex = self.m_selOptions[GroupParam.i]
    local optionName = ""
    if selIndex and options[selIndex] then
      optionName = options[selIndex].name
    elseif options[selIndex] then
      options[selIndex] = nil
    end
    GUIUtils.SetText(Label_Name, optionName)
  end
end
def.method().UpdateBtns = function(self)
  local showCancel = self.m_cancelCallback ~= nil and self.m_lastOptions ~= nil
  GUIUtils.SetActive(self.m_UIGOs.Btn_Confirm, not showCancel)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Set, showCancel)
  GUIUtils.SetActive(self.m_UIGOs.Btn_Cancel, showCancel)
end
def.method().CloseAllGroups = function(self)
  for i, v in ipairs(self.m_UIGOs.GroupParams) do
    self:OpenGroup(v, false)
  end
end
def.method("table", "boolean").OpenGroup = function(self, params, isOpen)
  local groupGO = params.groupList.parent
  local Group_Title = groupGO:FindDirect("Group_Title")
  local ImgUp = Group_Title:FindDirect(params.ImgUpName)
  local ImgDown = Group_Title:FindDirect(params.ImgDownName)
  GUIUtils.SetActive(params.groupList, isOpen)
  GUIUtils.SetActive(ImgUp, isOpen)
  GUIUtils.SetActive(ImgDown, not isOpen)
end
def.method("userdata", "table", "table").SetGroupList = function(self, groupGO, options, params)
  local List_Item = groupGO:FindDirect("Group_ScrollView/Scroll View/List_Item")
  local uiList = List_Item:GetComponent("UIList")
  local optionCount = #options
  uiList.itemCount = optionCount
  uiList:Resize()
  local childGOs = uiList.children
  for i = 1, optionCount do
    local childGO = childGOs[i]
    local option = options[i]
    self:SetGroupListItem(childGO, option, params)
  end
end
def.method("userdata", "table", "table").SetGroupListItem = function(self, itemGO, option, params)
  local Btn_Item = itemGO:FindChildByPrefix("Btn_Item_", false)
  if Btn_Item == nil then
    return
  end
  local Label_Name = Btn_Item:FindChildByPrefix(params.labelName, false)
  GUIUtils.SetText(Label_Name, option.name)
end
def.method().UpdateTips = function(self)
  GUIUtils.SetText(self.m_UIGOs.Label_Tips, self.m_tips)
end
return CommonSetTimeDlg.Commit()
