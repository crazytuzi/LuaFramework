local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceFocusListPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local SocialSpaceFocusMan = require("Main.SocialSpace.SocialSpaceFocusMan")
local SocialSpaceProfileMan = require("Main.SocialSpace.SocialSpaceProfileMan")
local def = SpaceFocusListPanel.define
def.field("table").m_UIGOs = nil
def.field("table").m_focusList = nil
def.field("table").m_friendMarkContainer = nil
local instance
def.static("=>", SpaceFocusListPanel).Instance = function()
  if instance == nil then
    instance = SpaceFocusListPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_FOCUS_LIST_PANEL, _G.GUILEVEL.DEPENDEND)
end
def.override().OnCreate = function(self)
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListChanged, self.OnFocusListChanged, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.FocusListChanged, self.OnFocusListChanged)
  self.m_UIGOs = nil
  self.m_focusList = nil
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Remove" then
    self:OnClickBtnRemove(obj)
  elseif id == "Img_Head" then
    self:OnClickRoleHead(obj)
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_NoData = self.m_UIGOs.Img_Bg:FindDirect("Group_List/Group_NoData")
  self.m_UIGOs.Group_List = self.m_UIGOs.Img_Bg:FindDirect("Group_List/Group_List")
  self.m_UIGOs.ScrollView = self.m_UIGOs.Group_List:FindDirect("Scrolllist")
  self.m_UIGOs.List = self.m_UIGOs.ScrollView:FindDirect("List")
  self.m_UIGOs.UIScrollList = self.m_UIGOs.List:GetComponent("UIScrollList")
  local GUIScrollList = self.m_UIGOs.List:GetComponent("GUIScrollList")
  if GUIScrollList == nil then
    self.m_UIGOs.List:AddComponent("GUIScrollList")
  end
end
def.method().UpdateUI = function(self)
  self:UpdateFocusList()
end
def.method().UpdateFocusList = function(self)
  SocialSpaceFocusMan.Instance():AsyncGetActiveFocusList(function(focusList)
    if not self:IsLoaded() then
      return
    end
    self:SetFocusList(focusList)
  end)
end
def.method("table").SetFocusList = function(self, focusList)
  self.m_focusList = focusList
  if focusList then
    local itemCount = #focusList
    if itemCount > 0 then
      self:ShowListGrop()
      self:SetFocusScrollList(self.m_UIGOs.UIScrollList, focusList)
    else
      self:ShowEmptyGroup(textRes.SocialSpace[118])
    end
  else
    self:ShowEmptyGroup(textRes.SocialSpace[117])
  end
end
def.method().ShowListGrop = function(self)
  GUIUtils.SetActive(self.m_UIGOs.Group_NoData, false)
  GUIUtils.SetActive(self.m_UIGOs.Group_List, true)
end
def.method("userdata", "table").SetFocusScrollList = function(self, uiScrollList, focusList)
  local itemCount = #focusList
  local firstIndex = 1
  ScrollList_setUpdateFunc(uiScrollList, function(item, index)
    local focusRoleInfo = focusList[index]
    self:SetFocusListItem(index, item, focusRoleInfo)
  end)
  ScrollList_setCount(uiScrollList, itemCount)
end
def.method("number", "userdata", "table").SetFocusListItem = function(self, index, itemGO, focusRoleInfo)
  local markGO = itemGO:FindChildByPrefix("Mark_")
  if markGO == nil then
    markGO = GameObject.GameObject("Mark_" .. index)
    markGO.parent = itemGO
  else
    markGO.name = "Mark_" .. index
  end
  local roleId = focusRoleInfo.roleId
  local profileLoadded = false
  SocialSpaceProfileMan.Instance():AsyncGetRoleProfile(roleId, function(profile)
    if not self:IsLoaded() then
      return
    end
    if _G.IsNil(itemGO) then
      return
    end
    local curMarkGO = itemGO:FindChildByPrefix("Mark_")
    if curMarkGO == nil then
      return
    end
    local markIndex = tonumber(curMarkGO.name:split("_")[2])
    if markIndex ~= index then
      return
    end
    if profile == nil then
      return
    end
    profileLoadded = true
    self:SetFocusListItemByProfile(itemGO, profile)
  end)
  if profileLoadded then
    return
  end
  local Group_Head = itemGO:FindDirect("Group_Head")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Label_Name = Img_Head:FindDirect("Label_Name")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local Img_MenPai = Img_Head:FindDirect("Img_MenPai")
  local Img_Sex = Img_Head:FindDirect("Img_Sex")
  local Img_Friend = Img_Head:FindDirect("Img_Friend")
  GUIUtils.SetText(Label_Name, "")
  GUIUtils.SetText(Label_Lv, "")
  GUIUtils.SetSprite(Img_MenPai, "nil")
  GUIUtils.SetSprite(Img_Sex, "nil")
  _G.SetAvatarIcon(Img_Head, 0, 0)
  GUIUtils.SetTexture(Img_Head, 0)
  GUIUtils.SetActive(Img_Friend, false)
end
def.method("userdata", "table").SetFocusListItemByProfile = function(self, itemGO, profile)
  local Group_Head = itemGO:FindDirect("Group_Head")
  local Img_Head = Group_Head:FindDirect("Img_Head")
  local Label_Name = Img_Head:FindDirect("Label_Name")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local Img_MenPai = Img_Head:FindDirect("Img_MenPai")
  local Img_Sex = Img_Head:FindDirect("Img_Sex")
  local Img_Friend = Img_Head:FindDirect("Img_Friend")
  GUIUtils.SetText(Label_Name, profile.name)
  GUIUtils.SetSprite(Img_MenPai, GUIUtils.GetOccupationSmallIcon(profile.prof))
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(profile.gender))
  _G.SetAvatarIcon(Img_Head, profile.avatarId, profile.avatarFrameId)
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = profile.roleId
  })
end
def.method("string").ShowEmptyGroup = function(self, promptText)
  GUIUtils.SetActive(self.m_UIGOs.Group_NoData, true)
  GUIUtils.SetActive(self.m_UIGOs.Group_List, false)
  local Label = self.m_UIGOs.Group_NoData:FindDirect("Img_Talk/Label")
  GUIUtils.SetText(Label, promptText)
end
def.method("userdata").OnClickBtnRemove = function(self, btn)
  local _, itemIndex = ScrollList_getItem(btn)
  if itemIndex == nil then
    return
  end
  local focusRoleInfo = self.m_focusList[itemIndex]
  SocialSpaceFocusMan.Instance():ReqDelFocusOnRole(focusRoleInfo.roleId)
end
def.method("userdata").OnClickRoleHead = function(self, obj)
  local _, index = ScrollList_getItem(obj)
  if index == nil then
    return
  end
  local roleInfo = self.m_focusList[index]
  if roleInfo == nil then
    return
  end
  ECSocialSpaceMan.Instance():ShowPlayerMenu(obj, roleInfo.roleId, "", 0, 0)
end
def.method("table").OnFocusListChanged = function(self, params)
  self:UpdateFocusList()
end
return SpaceFocusListPanel.Commit()
