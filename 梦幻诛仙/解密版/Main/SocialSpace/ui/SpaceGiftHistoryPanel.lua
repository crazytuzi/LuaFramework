local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SpaceGiftHistoryPanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local def = SpaceGiftHistoryPanel.define
local ECSpaceMsgs = require("Main.SocialSpace.ECSpaceMsgs")
local SocialSpaceUtils = import("..SocialSpaceUtils")
local ECSocialSpaceMan = require("Main.SocialSpace.ECSocialSpaceMan")
local ECDebugOption = require("Main.ECDebugOption")
local ItemUtils = require("Main.Item.ItemUtils")
def.field("table").m_UIGOs = nil
def.field("userdata").m_ownerId = nil
def.field("table").m_historyList = nil
def.field("table").m_friendMarkContainer = nil
local instance
def.static("=>", SpaceGiftHistoryPanel).Instance = function()
  if instance == nil then
    instance = SpaceGiftHistoryPanel()
  end
  return instance
end
def.method("userdata").ShowPanel = function(self, ownerId)
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self.m_ownerId = ownerId
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_GIFT_LIST_PANEL, 2)
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
  elseif id == "Img_Head" and obj.parent.parent.name:sub(1, 5) == "item_" then
    local index = tonumber(obj.parent.parent.name:split("_")[2])
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
  GUIUtils.SetText(self.m_UIGOs.Group_NoData:FindDirect("Img_Talk/Label"), textRes.SocialSpace[107])
end
def.method().UpdateUI = function(self)
  self:UpdateGiftHistoryList()
end
def.method().UpdateGiftHistoryList = function(self)
  ECSocialSpaceMan.Instance():Req_GetGiftRecords(self.m_ownerId, function(data)
    if not self:IsLoaded() then
      return
    end
    local data = ECSocialSpaceMan.Instance():GetSpaceData(self.m_ownerId)
    self.m_historyList = data.getGiftHistory or {}
    self:UpdateGiftHistoryListInner()
  end, false)
end
def.method().UpdateGiftHistoryListInner = function(self)
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
  local Group_Head = groupGO:FindDirect("Group_Head")
  local Img_Head = Group_Head:FindDirect("Img_Head")
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
  local Group_Gift = Group_Head:FindDirect("Group_Gift")
  local Label_Info = Group_Head:FindDirect("Label_Info")
  local Label_Date = Group_Head:FindDirect("Label_Date")
  local timeText = SocialSpaceUtils.TimestampToDisplayText(historyInfo.timestamp)
  GUIUtils.SetText(Label_Date, timeText)
  local html = Label_Info:GetComponent("NGUIHTML")
  html:ForceHtmlText(historyInfo.content)
  local Img_Icon = Group_Gift:FindDirect("Img_Icon")
  local Label_Num = Group_Gift:FindDirect("Label_Num")
  GUIUtils.SetText(Label_Num, historyInfo.giftCount)
  local uiTexture = Img_Icon:GetComponent("UITexture")
  if uiTexture == nil then
    local sprite = Img_Icon:GetComponent("UISprite")
    if sprite then
      local widget = sprite:GetComponent("UIWidget")
      local w = widget:get_width()
      local h = widget:get_height()
      local d = widget.depth
      Object.Destroy(sprite)
      uiTexture = Img_Icon:AddComponent("UITexture")
      uiTexture.depth = d
      uiTexture:set_width(w)
      uiTexture:set_height(h)
    end
  end
  local itemBase = ItemUtils.GetItemBase(historyInfo.giftId)
  local icon = itemBase and itemBase.icon or 0
  GUIUtils.FillIcon(uiTexture, icon)
end
def.method("number", "userdata").OnClickHistoryItemHead = function(self, index, obj)
  local historyInfo = self.m_historyList[index]
  if historyInfo == nil then
    return
  end
  ECSocialSpaceMan.Instance():ShowPlayerMenu(obj, historyInfo.roleId, historyInfo.playerName, historyInfo.idphoto, 0)
end
return SpaceGiftHistoryPanel.Commit()
