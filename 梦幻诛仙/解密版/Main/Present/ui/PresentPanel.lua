local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PresentPanel = Lplus.Extend(ECPanelBase, "PresentPanel")
local def = PresentPanel.define
local GUIUtils = require("GUI.GUIUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local PresentData = require("Main.Present.data.PresentData")
local FriendData = require("Main.friend.FriendData")
local PresentUtility = require("Main.Present.PresentUtility")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemSourceEnum = require("netio.protocol.mzm.gsp.item.ItemSourceEnum")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemNode = require("Main.Present.ui.ItemNode")
local GiftNode = require("Main.Present.ui.GiftNode")
local instance
def.field(PresentData).data = nil
def.field("table").uiTbl = nil
def.field("table").selectPlayerInfo = nil
def.field("number").selectType = 0
def.field("table").friendsList = nil
def.field("table").itemList = nil
def.field("table").presentList = nil
def.field("table").selectList = nil
def.field("number").selectFriendIndex = 1
def.field("userdata").selectRoleId = nil
def.const("table").NodeId = {GIFT = 1, ITEM = 2}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.const("table").StateConst = {Gift = 1, Item = 2}
def.static("=>", PresentPanel).Instance = function()
  if instance == nil then
    instance = PresentPanel()
    instance:Init()
    instance.state = PresentPanel.StateConst.Item
  end
  return instance
end
def.method().Init = function(self)
  self.data = PresentData.Instance()
end
def.method("number", "table").ShowPanel = function(self, type, info)
  self.state = type
  self.selectPlayerInfo = info
  self.selectFriendIndex = 1
  self:InitData()
  if self.friendsList and self.friendsList[self.selectFriendIndex] then
    self.selectRoleId = self.friendsList[self.selectFriendIndex].roleId
  end
  if self:IsShow() then
    self:FillPresentPanel()
  else
    self:SetModal(true)
    self:CreatePanel(RESPATH.PREFAB_PRESENT_PANEL, 0)
  end
end
def.override().OnCreate = function(self)
  self.uiTbl = PresentUtility.FillPresentUI(self.uiTbl, self.m_panel)
  self.nodes = {}
  local itemNode = self.uiTbl.Group_Item
  self.nodes[PresentPanel.NodeId.ITEM] = ItemNode()
  self.nodes[PresentPanel.NodeId.ITEM]:Init(self, itemNode)
  local giftNode = self.uiTbl.Group_Flower
  self.nodes[PresentPanel.NodeId.GIFT] = GiftNode()
  self.nodes[PresentPanel.NodeId.GIFT]:Init(self, giftNode)
  if PresentPanel.StateConst.Item == self.state then
    self:SwitchTo(PresentPanel.NodeId.ITEM)
    local toggle = self.uiTbl.Tab_Item:GetComponent("UIToggle")
    toggle:set_value(true)
  elseif PresentPanel.StateConst.Gift == self.state then
    self:SwitchTo(PresentPanel.NodeId.GIFT)
    local toggle = self.uiTbl.Tab_Present:GetComponent("UIToggle")
    toggle:set_value(true)
  end
  self:FillPresentPanel()
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PresentPanel._onBagInfoSyncronized)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_HistoryChanged, PresentPanel._onHistoryYuanbaoChanged)
  Event.RegisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentInfoChanged, PresentPanel._onPresentInfoChanged)
  Event.RegisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentSucceed, PresentPanel._onPresentSucceed)
  Event.RegisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.FlowerSucceed, PresentPanel._onFlowerSucceed)
  Event.RegisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.FriendQinMiDuChanged, PresentPanel._onFriendQinMiDuChanged)
end
def.method("number").SwitchTo = function(self, nodeId)
  self.curNode = 0
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      self.curNode = nodeId
      v:Show()
    else
      v:Hide()
    end
  end
end
def.static("table", "table")._onBagInfoSyncronized = function(params, tbl)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() then
    self.nodes[self.curNode]:OnBagInfoChanged()
  end
end
def.static("table", "table")._onHistoryYuanbaoChanged = function(params, tbl)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() and self.curNode == PresentPanel.NodeId.ITEM then
    self.nodes[self.curNode]:UpdatePresentYuanbao()
  end
end
def.static("table", "table")._onPresentInfoChanged = function(params, tbl)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() and self.curNode == PresentPanel.NodeId.ITEM then
    self.nodes[self.curNode]:ClearSelect()
    self.nodes[self.curNode]:UpdatePresentTimes()
  end
end
def.static("table", "table")._onPresentSucceed = function(params, tbl)
  Toast(textRes.Present[6])
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() and self.curNode == PresentPanel.NodeId.ITEM then
    self.nodes[self.curNode]:SucceedPresent(params[1])
  end
end
def.static("table", "table")._onFlowerSucceed = function(params, tbl)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() and self.curNode == PresentPanel.NodeId.GIFT then
    self.nodes[self.curNode]:SucceedFlower(params[1])
  end
end
def.static("table", "table")._onFriendQinMiDuChanged = function(params, tbl)
  local self = instance
  if self.m_panel and self.m_panel:get_activeInHierarchy() then
    self:UpdateFriendQinMiDu(params[1], params[2])
  end
end
def.method("userdata", "number").UpdateFriendQinMiDu = function(self, roleId, val)
  local uiList = self.uiTbl.Grid_List:GetComponent("UIList")
  local friendsUI = uiList:get_children()
  local name = ""
  for k, v in pairs(self.friendsList) do
    if v.roleId == roleId then
      v.relationValue = val
      name = v.roleName
    end
  end
  for i = 1, #friendsUI do
    local friendUI = friendsUI[i]
    local Label_Name = friendUI:FindDirect(string.format("Label_Name_%d", i)):GetComponent("UILabel"):get_text()
    if Label_Name == name then
      local QinMiInfo = friendUI:FindDirect(string.format("QinMiInfo_%d", i))
      local Label_Stranger = friendUI:FindDirect(string.format("Label_Stranger_%d", i))
      if val >= 0 then
        QinMiInfo:SetActive(true)
        Label_Stranger:SetActive(false)
        QinMiInfo:FindDirect(string.format("Label_Num_%d", i)):GetComponent("UILabel"):set_text(val)
      else
        QinMiInfo:SetActive(false)
        Label_Stranger:SetActive(true)
      end
    end
  end
end
def.method().InitData = function(self)
  self.friendsList = {}
  local list = FriendData.Instance():GetFriendList()
  for k, v in pairs(list) do
    table.insert(self.friendsList, v)
  end
  table.sort(self.friendsList, function(left, right)
    return left.relationValue > right.relationValue
  end)
  if self.selectPlayerInfo ~= nil then
    for k, v in pairs(self.friendsList) do
      if v.roleId == self.selectPlayerInfo.roleId then
        table.remove(self.friendsList, k)
        break
      end
    end
    self.selectPlayerInfo.roleName = self.selectPlayerInfo.name
    self.selectPlayerInfo.roleLevel = self.selectPlayerInfo.level
    self.selectPlayerInfo.sex = self.selectPlayerInfo.gender
    local memberInfo = FriendData.Instance():GetFriendInfo(self.selectPlayerInfo.roleId)
    if nil ~= memberInfo then
      self.selectPlayerInfo.relationValue = memberInfo.relationValue
    else
      self.selectPlayerInfo.relationValue = -1
    end
    if Int64.gt(self.selectPlayerInfo.teamId, -1) then
      self.selectPlayerInfo.teamMemCount = self.selectPlayerInfo.teamMemberNum
    else
      self.selectPlayerInfo.teamMemCount = 0
    end
    table.insert(self.friendsList, 1, self.selectPlayerInfo)
  end
end
def.method().FillPresentPanel = function(self)
  self:FillFriendsList()
end
def.method().FillFriendsList = function(self)
  local uiList = self.uiTbl.Grid_List:GetComponent("UIList")
  uiList:set_itemCount(#self.friendsList)
  uiList:Resize()
  GameUtil.AddGlobalLateTimer(0, true, function()
    if not uiList.isnil then
      uiList:Reposition()
    end
  end)
  local friendsUI = uiList:get_children()
  for i = 1, #friendsUI do
    local friendUI = friendsUI[i]
    local friendInfo = self.friendsList[i]
    self:FillFriendInfo(friendUI, i, friendInfo)
  end
  self:TouchGameObject(self.m_panel, self.m_parent)
end
def.method("userdata", "number", "table").FillFriendInfo = function(self, friendUI, index, friendInfo)
  local Label_Name = friendUI:FindDirect(string.format("Label_Name_%d", index)):GetComponent("UILabel")
  local Img_BgHead = friendUI:FindDirect(string.format("Img_BgHead_%d", index))
  local Icon_Head = Img_BgHead:FindDirect(string.format("Icon_Head_%d", index))
  local Label_Lv = Img_BgHead:FindDirect(string.format("Label_Lv_%d", index)):GetComponent("UILabel")
  local Img_Scholl = friendUI:FindDirect(string.format("Img_Scholl_%d", index)):GetComponent("UISprite")
  local Img_FgHead = Img_BgHead:FindDirect(string.format("Img_FgHead_%d", index))
  Label_Name:set_text(friendInfo.roleName)
  Label_Lv:set_text(friendInfo.roleLevel)
  local FriendUtils = require("Main.friend.FriendUtils")
  GUIUtils.SetActive(Img_FgHead, false)
  _G.SetAvatarIcon(Icon_Head, friendInfo.avatarId, friendInfo.avatarFrameId)
  local occupationIconId = FriendUtils.GetOccupationIconId(friendInfo.occupationId)
  FriendUtils.FillIcon(occupationIconId, Img_Scholl, 3)
  local QinMiInfo = friendUI:FindDirect(string.format("QinMiInfo_%d", index))
  local Label_Stranger = friendUI:FindDirect(string.format("Label_Stranger_%d", index))
  if friendInfo.relationValue >= 0 then
    QinMiInfo:SetActive(true)
    Label_Stranger:SetActive(false)
    QinMiInfo:FindDirect(string.format("Label_Num_%d", index)):GetComponent("UILabel"):set_text(friendInfo.relationValue)
  else
    QinMiInfo:SetActive(false)
    Label_Stranger:SetActive(true)
  end
  local Img_Sex = friendUI:FindDirect(string.format("Img_Sex01_%d", index))
  GUIUtils.SetSprite(Img_Sex, GUIUtils.GetGenderSprite(friendInfo.sex))
  if self.selectFriendIndex == index then
    friendUI:GetComponent("UIToggle"):set_value(true)
  else
    friendUI:GetComponent("UIToggle"):set_value(false)
  end
end
def.override().OnDestroy = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, PresentPanel._onBagInfoSyncronized)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_HistoryChanged, PresentPanel._onHistoryYuanbaoChanged)
  Event.UnregisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentInfoChanged, PresentPanel._onPresentInfoChanged)
  Event.UnregisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.PresentSucceed, PresentPanel._onPresentSucceed)
  Event.UnregisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.FlowerSucceed, PresentPanel._onFlowerSucceed)
  Event.UnregisterEvent(ModuleId.PRESENT, gmodule.notifyId.Present.FriendQinMiDuChanged, PresentPanel._onFriendQinMiDuChanged)
end
def.method().Clear = function(self)
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("number").OnSelectFriendClick = function(self, index)
  self.selectFriendIndex = index
  self.selectRoleId = self.friendsList[self.selectFriendIndex].roleId
  if self.m_panel and self.m_panel:get_activeInHierarchy() and self.curNode == PresentPanel.NodeId.ITEM then
    self.nodes[self.curNode]:ReturnSelectToSrc()
    self.nodes[self.curNode]:ClearSelect()
    self.nodes[self.curNode]:InitItems()
    self.nodes[self.curNode]:FillItemsList(true)
    self.nodes[self.curNode]:FillSelectList()
    self.nodes[self.curNode]:FillPresentTimesInfo()
  end
end
def.method("string", "string").onTextChange = function(self, id, val)
  if PresentPanel.Instance().curNode == PresentPanel.NodeId.GIFT then
    self.nodes[self.curNode]:onTextChange(id, val)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    self:Hide()
  elseif string.sub(id, 1, #"Img_BgFriend_") == "Img_BgFriend_" then
    local index = tonumber(string.sub(id, #"Img_BgFriend_" + 1, -1))
    self:OnSelectFriendClick(index)
  elseif "Tab_Item" == id then
    self:SwitchTo(PresentPanel.NodeId.ITEM)
  elseif "Tab_Present" == id then
    self:SwitchTo(PresentPanel.NodeId.GIFT)
  elseif "Modal" == id then
    self:Hide()
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
return PresentPanel.Commit()
