local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceBlacklistPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceBlacklistPanel.define
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
def.field("table").m_UIGOs = nil
def.field("table").m_blackRoleList = nil
def.field("table").m_friendMarkContainer = nil
local instance
def.static("=>", SpaceBlacklistPanel).Instance = function()
  if instance == nil then
    instance = SpaceBlacklistPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsLoaded() then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_BLACKLIST_PANEL, 2)
end
def.override().OnCreate = function(self)
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEventWithContext(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, self.OnBlacklistChanged, self)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SOCIAL_SPACE, gmodule.notifyId.SocialSpace.BlacklistChanged, self.OnBlacklistChanged)
  self.m_UIGOs = nil
  self.m_blackRoleList = nil
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Btn_Del" then
    self:OnClickDelBtn(obj)
  elseif id == "Img_Head" then
    self:OnClickRoleHead(obj)
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_Data = self.m_UIGOs.Img_Bg:FindDirect("Group_List")
  self.m_UIGOs.Group_NoData = self.m_UIGOs.Group_Data:FindDirect("Group_NoData")
  self.m_UIGOs.Group_List = self.m_UIGOs.Group_Data:FindDirect("Group_List")
  self.m_UIGOs.ScrollView = self.m_UIGOs.Group_List:FindDirect("Scrolllist")
  self.m_UIGOs.List = self.m_UIGOs.ScrollView:FindDirect("List")
  self.m_UIGOs.List:SetActive(false)
end
def.method().UpdateUI = function(self)
  self:UpdateBlacklist()
end
def.method().UpdateBlacklist = function(self)
  ECSocialSpaceMan.Instance():ReqHostBlacklist(function(data)
    if not self:IsLoaded() then
      return
    end
    local blackRoleList = ECSocialSpaceMan.Instance():GetActiveBlackRoleList()
    self:SetBlackRoleList(blackRoleList)
  end, false)
end
def.method("table").SetBlackRoleList = function(self, blackRoleList)
  self.m_blackRoleList = blackRoleList
  local itemCount = #blackRoleList
  local haveData = itemCount > 0
  self.m_UIGOs.List:SetActive(haveData)
  self.m_UIGOs.Group_NoData:SetActive(not haveData)
  if not haveData then
    return
  end
  local uiList = self.m_UIGOs.List:GetComponent("UIList")
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  local childGOs = uiList.children
  for i = 1, itemCount do
    local roleInfo = blackRoleList[i]
    local itemObj = childGOs[i]
    self:SetBlackRoleInfo(itemObj, roleInfo)
  end
end
def.method("userdata", "table").SetBlackRoleInfo = function(self, itemObj, roleInfo)
  local Img_Head = itemObj:FindDirect("Img_Head")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local Img_MenPai = Img_Head:FindDirect("Img_MenPai")
  local Img_Sex = Img_Head:FindDirect("Img_Sex")
  local Label_Name = Img_Head:FindDirect("Label_Name")
  local Img_Friend = Img_Head:FindDirect("Img_Friend")
  _G.SetAvatarIcon(Img_Head, roleInfo.idphoto, roleInfo.avatarFrameId)
  if roleInfo.name == "" or not roleInfo.name then
  end
  GUIUtils.SetText(Label_Name, (tostring(roleInfo.roleId)))
  GUIUtils.SetText(Label_Lv, "")
  GUIUtils.SetSprite(Img_MenPai, "nil")
  GUIUtils.SetSprite(Img_Sex, "nil")
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = roleInfo.roleId
  })
end
def.method("userdata").OnClickDelBtn = function(self, obj)
  local itemObj = obj.parent
  local index = tonumber(itemObj.name:split("_")[2])
  if index == nil then
    return
  end
  local roleInfo = self.m_blackRoleList[index]
  ECSocialSpaceMan.Instance():ReqRemoveRoleFromBlacklist(roleInfo.roleId)
end
def.method("table").OnBlacklistChanged = function(self, params)
  if params.remove then
    local roleId = params.roleId
    local idx = self:FindRoleIdxByRoleId(roleId)
    if idx ~= 0 then
      self:RemoveRoleByIdx(idx)
    end
  end
end
def.method("userdata", "=>", "number").FindRoleIdxByRoleId = function(self, roleId)
  if self.m_blackRoleList == nil then
    return 0
  end
  for i, v in ipairs(self.m_blackRoleList) do
    if v.roleId == roleId then
      return i
    end
  end
  return 0
end
def.method("number").RemoveRoleByIdx = function(self, idx)
  local itemCount = #self.m_blackRoleList
  if idx < 0 or idx > itemCount then
    print("idx invalid, ", idx)
    return
  end
  for i = idx + 1, itemCount do
    local itemObj = self.m_UIGOs.List:GetChild(i)
    itemObj.name = "item_" .. i - 1
  end
  local itemObj = self.m_UIGOs.List:GetChild(idx)
  itemObj.transform:SetAsLastSibling()
  table.remove(self.m_blackRoleList, idx)
  itemCount = itemCount - 1
  local uiList = self.m_UIGOs.List:GetComponent("UIList")
  uiList:set_itemCount(itemCount)
  uiList:Resize()
  if itemCount == 0 then
    self.m_UIGOs.List:SetActive(false)
    self.m_UIGOs.Group_NoData:SetActive(true)
  elseif idx > itemCount then
    do
      local itemObj = self.m_UIGOs.List:GetChild(itemCount)
      local uiScrollView = self.m_UIGOs.ScrollView:GetComponent("UIScrollView")
      GameUtil.AddGlobalTimer(0, true, function()
        GameUtil.AddGlobalTimer(0, true, function()
          if _G.IsNil(uiScrollView) then
            return
          end
          uiScrollView:DragToMakeVisible(itemObj.transform)
        end)
      end)
    end
  end
end
def.method("userdata").OnClickRoleHead = function(self, obj)
  local index = tonumber(obj.parent.name:split("_")[2])
  if index == nil then
    return
  end
  local roleInfo = self.m_blackRoleList[index]
  if roleInfo == nil then
    return
  end
  ECSocialSpaceMan.Instance():ShowPlayerMenu(obj, roleInfo.roleId, roleInfo.name, roleInfo.idphoto, 0)
end
return SpaceBlacklistPanel.Commit()
