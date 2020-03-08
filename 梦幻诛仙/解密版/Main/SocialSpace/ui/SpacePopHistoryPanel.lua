local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpacePopHistoryPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpacePopHistoryPanel.define
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
def.field("table").m_UIGOs = nil
def.field("userdata").m_ownerId = nil
def.field("table").m_historyList = nil
def.field("table").m_friendMarkContainer = nil
local instance
def.static("=>", SpacePopHistoryPanel).Instance = function()
  if instance == nil then
    instance = SpacePopHistoryPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, ownerId)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_ownerId = ownerId
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_POP_HISTORY_PANEL, 2)
end
def.override().OnCreate = function(self)
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_ownerId = nil
  self.m_historyList = nil
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Img_Head" and obj.parent.name:sub(1, 5) == "item_" then
    local index = tonumber(obj.parent.name:split("_")[2])
    if index then
      self:OnClickHistoryItemHead(index, obj)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_List0 = self.m_UIGOs.Img_Bg:FindDirect("Group_List")
  self.m_UIGOs.Group_NoData = self.m_UIGOs.Group_List0:FindDirect("Group_NoData")
  self.m_UIGOs.Group_List = self.m_UIGOs.Group_List0:FindDirect("Group_List")
  self.m_UIGOs.Scrolllist = self.m_UIGOs.Group_List:FindDirect("Scrolllist")
  self.m_UIGOs.List = self.m_UIGOs.Scrolllist:FindDirect("List")
  self.m_UIGOs.List:SetActive(false)
  local PlayerTemplateSprite = self.m_UIGOs.List:FindDirect("Player/Sprite")
  GUIUtils.AddBoxCollider(PlayerTemplateSprite)
  local uiDragScrollView = PlayerTemplateSprite:GetComponent("UIDragScrollView")
  if uiDragScrollView == nil then
    PlayerTemplateSprite:AddComponent("UIDragScrollView")
  end
  GUIUtils.SetText(self.m_UIGOs.Group_NoData:FindDirect("Img_Talk/Label"), textRes.SocialSpace[59])
end
def.method().UpdateUI = function(self)
  self:UpdatePopHistoryList()
end
def.method().UpdatePopHistoryList = function(self)
  ECSocialSpaceMan.Instance():Req_GetSpacePopularRecords(self.m_ownerId, function(data)
    if not self:IsLoaded() then
      return
    end
    local data = ECSocialSpaceMan.Instance():GetSpaceData(self.m_ownerId)
    self.m_historyList = data.guestHistory or {}
    self:UpdatePopHistoryListInner()
  end, false)
end
def.method().UpdatePopHistoryListInner = function(self)
  self.m_UIGOs.List:SetActive(true)
  local uiList = self.m_UIGOs.List:GetComponent("UIList")
  local itemCount = #self.m_historyList
  uiList.itemCount = itemCount
  uiList:Resize()
  local childGOs = uiList.children
  for i = 1, itemCount do
    local groupGO = childGOs[i]
    local historyInfo = self.m_historyList[i]
    self:SetHistoryItemInfo(groupGO, historyInfo)
  end
  GUIUtils.SetActive(self.m_UIGOs.Group_NoData, itemCount == 0)
end
def.method("userdata", "table").SetHistoryItemInfo = function(self, groupGO, historyInfo)
  local Img_Head = groupGO:FindDirect("Img_Head")
  local Label_Name = Img_Head:FindDirect("Label_Name")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local Img_MenPai = Img_Head:FindDirect("Img_MenPai")
  local Img_Sex = Img_Head:FindDirect("Img_Sex")
  local Img_Friend = Img_Head:FindDirect("Img_Friend")
  _G.SetAvatarIcon(Img_Head, historyInfo.idphoto, historyInfo.avatarFrameId)
  GUIUtils.SetText(Label_Name, historyInfo.playerName)
  GUIUtils.SetText(Label_Lv, historyInfo.level)
  GUIUtils.SetSprite(Img_MenPai, "nil")
  GUIUtils.SetSprite(Img_Sex, "nil")
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = historyInfo.roleId
  })
  local Btn_Like = groupGO:FindDirect("Btn_Like")
  local Btn_Get = groupGO:FindDirect("Btn_Get")
  GUIUtils.SetActive(Btn_Like, historyInfo.historyType == ECSpaceMsgs.HistoryType.ADD_POPULAR)
  GUIUtils.SetActive(Btn_Get, historyInfo.historyType == ECSpaceMsgs.HistoryType.GET_GIFT)
end
def.method("number", "userdata").OnClickHistoryItemHead = function(self, index, obj)
  local historyInfo = self.m_historyList[index]
  if historyInfo == nil then
    return
  end
  ECSocialSpaceMan.Instance():ShowPlayerMenu(obj, historyInfo.roleId, historyInfo.playerName, historyInfo.idphoto, historyInfo.serverId)
end
return SpacePopHistoryPanel.Commit()
