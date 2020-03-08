local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceLikeListPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceLikeListPanel.define
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
def.field("table").m_UIGOs = nil
def.field("table").m_likeList = nil
def.field("number").m_msgType = 0
def.field("userdata").m_ownerId = nil
def.field("userdata").m_msgId = nil
def.field("table").m_friendMarkContainer = nil
local instance
def.static("=>", SpaceLikeListPanel).Instance = function()
  if instance == nil then
    instance = SpaceLikeListPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("number", "userdata", "userdata").ShowPanel = function(self, msgType, ownerId, msgId)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_msgType = msgType
  self.m_ownerId = ownerId
  self.m_msgId = msgId
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_LIKE_LIST_PANEL, 2)
end
def.override().OnCreate = function(self)
  self.m_friendMarkContainer = require("Main.SocialSpace.FriendMarkHelper").Instance():CreateContainer()
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self.m_UIGOs = nil
  self.m_likeList = nil
  self.m_msgType = 0
  self.m_ownerId = nil
  self.m_msgId = nil
  if self.m_friendMarkContainer then
    self.m_friendMarkContainer:Destroy()
    self.m_friendMarkContainer = nil
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if id == "Btn_Close" or id == "Modal" then
    self:DestroyPanel()
  elseif id == "Img_Head" and obj.parent.name:sub(1, 5) == "item_" then
    local index = tonumber(obj.parent.name:split("_")[2])
    if index then
      self:OnClickLikeItemHead(index, obj)
    end
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.m_UIGOs.Group_List0 = self.m_UIGOs.Img_Bg:FindDirect("Group_List")
  self.m_UIGOs.Group_NoData = self.m_UIGOs.Group_List0:FindDirect("Group_NoData")
  self.m_UIGOs.Group_List = self.m_UIGOs.Group_List0:FindDirect("Group_List")
  self.m_UIGOs.Scrollview = self.m_UIGOs.Group_List:FindDirect("Scrollview")
  self.m_UIGOs.List = self.m_UIGOs.Scrollview:FindDirect("List")
  local uiScrollList = self.m_UIGOs.List:GetComponent("UIScrollList")
  ScrollList_setCount(uiScrollList, 0)
  local GUIScrollList = self.m_UIGOs.List:GetComponent("GUIScrollList")
  if not GUIScrollList then
    self.m_UIGOs.List:AddComponent("GUIScrollList")
  end
end
def.method().UpdateUI = function(self)
  self:UpdateLikeList()
end
def.method().UpdateLikeList = function(self)
  ECSocialSpaceMan.Instance():Req_GetStatusFavorList(self.m_msgType, self.m_ownerId, self.m_msgId, function(msg)
    if not self:IsLoaded() then
      return
    end
    self.m_likeList = msg.favorList
    self:UpdateLikeListInner()
  end, false)
end
def.method().UpdateLikeListInner = function(self)
  local uiScrollList = self.m_UIGOs.List:GetComponent("UIScrollList")
  ScrollList_setUpdateFunc(uiScrollList, function(item, i)
    local likeInfo = self.m_likeList[i]
    item.name = "item_" .. i
    self:SetLikeItemInfo(item, likeInfo)
  end)
  local itemCount = #self.m_likeList
  ScrollList_setCount(uiScrollList, itemCount)
  GUIUtils.SetActive(self.m_UIGOs.Group_NoData, itemCount == 0)
end
def.method("userdata", "table").SetLikeItemInfo = function(self, groupGO, likeInfo)
  local Img_Head = groupGO:FindDirect("Img_Head")
  local Label_Name = Img_Head:FindDirect("Label_Name")
  local Label_Lv = Img_Head:FindDirect("Label_Lv")
  local Img_MenPai = Img_Head:FindDirect("Img_MenPai")
  local Img_Sex = Img_Head:FindDirect("Img_Sex")
  local Img_Friend = Img_Head:FindDirect("Img_Friend")
  _G.SetAvatarIcon(Img_Head, likeInfo.idphoto, likeInfo.avatarFrameId)
  GUIUtils.SetText(Label_Name, likeInfo.name)
  GUIUtils.SetText(Label_Lv, "")
  GUIUtils.SetSprite(Img_MenPai, "nil")
  GUIUtils.SetSprite(Img_Sex, "nil")
  self.m_friendMarkContainer:AddFriendMark({
    go = Img_Friend,
    roleId = likeInfo.id
  })
end
def.method("number", "userdata").OnClickLikeItemHead = function(self, index, obj)
  local likeInfo = self.m_likeList[index]
  if likeInfo == nil then
    return
  end
  ECSocialSpaceMan.Instance():ShowPlayerMenu(obj, likeInfo.id, likeInfo.name, likeInfo.idphoto, likeInfo.serverId)
end
return SpaceLikeListPanel.Commit()
