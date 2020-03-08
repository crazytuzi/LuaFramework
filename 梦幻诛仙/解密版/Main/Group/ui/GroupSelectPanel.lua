local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GroupSelectPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = GroupSelectPanel.define
local GroupModule = require("Main.Group.GroupModule")
def.field("table").m_UIGOs = nil
def.field("string").m_title = ""
def.field("number").m_maxSelectNum = 0
def.field("function").m_onSelect = nil
def.field("table").m_groupList = nil
def.field("table").m_selectedGroups = nil
local instance
def.static("=>", GroupSelectPanel).Instance = function()
  if instance == nil then
    instance = GroupSelectPanel()
  end
  return instance
end
def.method("string", "number", "function").ShowPanel = function(self, title, maxSelectNum, onSelect)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self.m_title = title
  self.m_maxSelectNum = maxSelectNum
  self.m_onSelect = onSelect
  self:SetOutTouchDisappear()
  self:CreatePanel(RESPATH.PREFAB_GROUP_SHARE_PANEL, 2)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_groupList = nil
  self.m_onSelect = nil
  self.m_title = ""
  self.m_maxSelectNum = 0
  self.m_selectedGroups = nil
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id:find("Group_NameList_") then
    self:OnClickGroupItem(obj)
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  end
end
def.method().InitData = function(self)
  self.m_selectedGroups = {}
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Label_Title = self.m_UIGOs.Img_Bg:FindDirect("Label")
  self.m_UIGOs.Group_Info = self.m_UIGOs.Img_Bg:FindDirect("Group_Info")
  self.m_UIGOs.ScrollView = self.m_UIGOs.Group_Info:FindDirect("Scroll View")
  self.m_UIGOs.List_Name = self.m_UIGOs.ScrollView:FindDirect("List_Name")
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateGroupList()
end
def.method().UpdateTitle = function(self)
  GUIUtils.SetText(self.m_UIGOs.Label_Title, self.m_title)
end
def.method().UpdateGroupList = function(self)
  local curGroupList = GroupModule.Instance():GetSortedBasicGroupList()
  self:SetGroupList(curGroupList)
end
def.method("table").SetGroupList = function(self, groupList)
  self.m_groupList = groupList
  local itemCount = #groupList
  local uiList = self.m_UIGOs.List_Name:GetComponent("UIList")
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local itemGOs = uiList:get_children()
  for i, itemGO in ipairs(itemGOs) do
    local groupInfo = groupList[i]
    self:SetGroupInfo(i, itemGO, groupInfo)
  end
end
def.method("number", "userdata", "table").SetGroupInfo = function(self, index, itemGO, groupInfo)
  local Label_PupilName = itemGO:FindDirect(("Label_PupilName_%d"):format(index))
  GUIUtils.SetText(Label_PupilName, groupInfo.groupName)
end
def.method("userdata").OnClickGroupItem = function(self, itemGO)
  local index = tonumber(itemGO.name:split("_")[3])
  local isSelected = GUIUtils.IsToggle(itemGO)
  if isSelected then
    self:OnSelectGroupItemGO(index, itemGO)
  else
    self:OnUnSelectGroupItemGO(index, itemGO)
  end
end
def.method("number", "userdata").OnSelectGroupItemGO = function(self, index, itemGO)
  if self.m_maxSelectNum > 1 then
    local selectedNum = self:GetSelectedGroupNum()
    if selectedNum == self.m_maxSelectNum then
      Toast(textRes.Group[35]:format(self.m_maxSelectNum))
      GUIUtils.Toggle(itemGO, false)
      return
    end
  elseif self.m_maxSelectNum == 1 and self:GetSelectedGroupNum() == 1 then
    local lastIndex = next(self.m_selectedGroups)
    self.m_selectedGroups[lastIndex] = nil
    local lastItemGO = self.m_UIGOs.List_Name:FindDirect("Group_NameList_" .. lastIndex)
    GUIUtils.Toggle(lastItemGO, false)
  end
  local groupInfo = self.m_groupList[index]
  self.m_selectedGroups[index] = groupInfo.groupId
end
def.method("number", "userdata").OnUnSelectGroupItemGO = function(self, index, itemGO)
  self.m_selectedGroups[index] = nil
end
def.method("=>", "number").GetSelectedGroupNum = function(self)
  return table.nums(self.m_selectedGroups)
end
def.method().OnClickConfirmBtn = function(self)
  if self.m_onSelect then
    local groupIds = {}
    for k, groupId in pairs(self.m_selectedGroups) do
      table.insert(groupIds, groupId)
    end
    local closePanel = self.m_onSelect(groupIds)
    if closePanel ~= false then
      self:DestroyPanel()
    end
  end
end
return GroupSelectPanel.Commit()
