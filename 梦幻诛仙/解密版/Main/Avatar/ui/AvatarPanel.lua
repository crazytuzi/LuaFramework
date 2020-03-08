local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AvatarPanel = Lplus.Extend(ECPanelBase, "AvatarPanel")
local AvatarInterface = require("Main.Avatar.AvatarInterface")
local avatarInterface = AvatarInterface.Instance()
local ItemUtils = require("Main.Item.ItemUtils")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local AvatarNode = require("Main.Avatar.ui.AvatarNode")
local AvatarFrameNode = require("Main.Avatar.ui.AvatarFrameNode")
local ChatBubbleNode = require("Main.Chat.ChatBubble.ui.BubbleNode")
local def = AvatarPanel.define
local NodeId = {
  Avatar = 1,
  AvatarFrame = 2,
  Bubble = 3
}
def.field("table").nodes = nil
def.field("number").curNode = NodeId.Avatar
def.field("number").selectedItemId = 0
def.field("number").selectedAvatarFrameId = 0
def.field("number").selectBubbleId = 0
local NodeDefines = {
  [NodeId.Avatar] = {
    tabName = "Tap_Head",
    rootName = "Group_ChangeHead",
    node = AvatarNode
  },
  [NodeId.AvatarFrame] = {
    tabName = "Tap_BgHead",
    rootName = "Group_ChangeBgHead",
    node = AvatarFrameNode
  },
  [NodeId.Bubble] = {
    tabName = "Tap_PaoPao",
    rootName = "Group_ChangePaoPao",
    node = ChatBubbleNode
  }
}
local instance
def.static("=>", AvatarPanel).Instance = function()
  if instance == nil then
    instance = AvatarPanel()
  end
  return instance
end
def.method("number").ShowPanelByItemId = function(self, itemId)
  self.selectedItemId = itemId
  self.curNode = NodeId.Avatar
  self:ShowPanel()
end
def.method("number").ShowPanelToAvatarFrame = function(self, selectedAvatarFrameId)
  self.curNode = NodeId.AvatarFrame
  self.selectedAvatarFrameId = selectedAvatarFrameId
  self:ShowPanel()
end
def.method("number").ShowPanelToBubbleNode = function(self, selBubbleId)
  self.curNode = NodeId.Bubble
  self.selectBubbleId = selBubbleId
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PERFAB_CHANGE_HEAD, 1)
  self:SetModal(true)
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self.nodes[self.curNode]:Show()
    self:refreshTabRedPoint()
  else
    self.nodes[self.curNode]:Hide()
  end
end
def.override().OnCreate = function(self)
  self:InitNodes()
  self:InitTabs()
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, AvatarPanel.OnAvatarChange)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar, AvatarPanel.OnGetNewAvatar)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Attr_Change, AvatarPanel.OnAvatarAttrChange)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Extended_Success, AvatarPanel.OnAvatarExtend)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, AvatarPanel.OnAvatarFrameChange)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar_Frame, AvatarPanel.OnGetNewAvatarFrame)
  Event.RegisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, AvatarPanel.OnRefreshRedPoint)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, AvatarPanel.OnAvatarChange)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar, AvatarPanel.OnGetNewAvatar)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Attr_Change, AvatarPanel.OnAvatarAttrChange)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Extended_Success, AvatarPanel.OnAvatarExtend)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, AvatarPanel.OnAvatarFrameChange)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Get_New_Avatar_Frame, AvatarPanel.OnGetNewAvatarFrame)
  Event.UnregisterEvent(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Red_Point_Info_Change, AvatarPanel.OnRefreshRedPoint)
end
def.static("table", "table").OnAvatarChange = function(p1, p2)
  if instance and instance:IsShow() and instance.curNode == NodeId.Avatar then
    instance.nodes[instance.curNode]:setAvatarList()
    instance.nodes[instance.curNode]:setAvatarInfo()
    local curAvatarId = avatarInterface:getCurAvatarId()
    local avatarCfg = AvatarInterface.GetAvatarCfgById(curAvatarId)
    if avatarCfg then
      Toast(string.format(textRes.Avatar[16], avatarCfg.name))
    end
  end
end
def.static("table", "table").OnGetNewAvatar = function(p1, p2)
  if instance and instance:IsShow() and instance.curNode == NodeId.Avatar then
    instance.nodes[NodeId.Avatar]:setAvatarList()
    instance.nodes[NodeId.Avatar]:setAvatarInfo()
  end
end
def.static("table", "table").OnAvatarAttrChange = function(p1, p2)
  if instance and instance:IsShow() and instance.curNode == NodeId.Avatar then
    instance.nodes[NodeId.Avatar]:setAvatarInfo()
  end
end
def.static("table", "table").OnAvatarExtend = function(p1, p2)
  if instance and instance:IsShow() and instance.curNode == NodeId.Avatar then
    instance.nodes[NodeId.Avatar]:setAvatarInfo()
  end
end
def.static("table", "table").OnAvatarFrameChange = function(p1, p2)
  if instance and instance:IsShow() and instance.curNode == NodeId.AvatarFrame then
    instance.nodes[NodeId.AvatarFrame]:resetAvatarFrameInfo()
  end
end
def.static("table", "table").OnGetNewAvatarFrame = function(p1, p2)
  if instance and instance:IsShow() and instance.curNode == NodeId.AvatarFrame then
    instance.nodes[NodeId.AvatarFrame]:resetAvatarFrameInfo()
  end
end
def.static("table", "table").OnRefreshRedPoint = function(p1, p2)
  if instance and instance:IsShow() then
    instance:refreshTabRedPoint()
  end
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self.curNode = NodeId.Avatar
  self.selectedItemId = 0
  self.selectedAvatarFrameId = 0
  self.selectBubbleId = 0
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("--------AvatarPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif id == "Tap_Head" then
    self:SwitchTo(NodeId.Avatar)
  elseif id == "Tap_BgHead" then
    self:SwitchTo(NodeId.AvatarFrame)
  elseif id == "Tap_PaoPao" then
    self:SwitchTo(NodeId.Bubble)
  else
    self.nodes[self.curNode]:onClickObj(clickObj)
  end
end
def.method().setCurAvatarInfo = function(self)
  local Img_BgCharacter = self.m_panel:FindDirect("Img_Bg0/Img_BgCharacter")
  local Icon_Head = Img_BgCharacter:FindDirect("Icon_Head")
  _G.SetAvatarIcon(Icon_Head)
  local Icon_BgHead = Img_BgCharacter:FindDirect("Icon_BgHead")
  _G.SetAvatarFrameIcon(Icon_BgHead)
  local imgBubble = Img_BgCharacter:FindDirect("Img_PaoPao")
  _G.SetAvatarBubble(imgBubble)
end
def.method().InitNodes = function(self)
  self.nodes = {}
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.node then
      self.nodes[nodeId] = v.node()
      self.nodes[nodeId]:Init(self, nodeRoot)
    else
      self.nodes[nodeId] = v.node
    end
  end
end
def.method("=>", "boolean").IsOpen = function(self)
  for nodeId, v in pairs(NodeDefines) do
    if v.node then
      local node
      if self.nodes and self.nodes[nodeId] then
        node = self.nodes[nodeId]
      else
        node = v.node()
      end
      if node and node:IsOpen() then
        return true
      end
    end
  end
  return false
end
def.method().InitTabs = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for nodeId, v in pairs(NodeDefines) do
    local tab = Img_Bg0:FindDirect(v.tabName)
    local isOpen = true
    if self.nodes[nodeId] then
      isOpen = self.nodes[nodeId]:IsOpen()
    end
    if isOpen then
      tab:SetActive(true)
      tab:GetComponent("UIToggle").value = self.curNode == nodeId
    else
      tab:SetActive(false)
    end
  end
end
def.method().refreshTabRedPoint = function(self)
  local Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  for nodeId, v in pairs(NodeDefines) do
    local tab = Img_Bg0:FindDirect(v.tabName)
    if tab then
      local Img_Red = tab:FindDirect("Img_Red")
      local node = self.nodes[nodeId]
      if Img_Red and node and node:IsHaveNotifyMessage() then
        Img_Red:SetActive(true)
      else
        Img_Red:SetActive(false)
      end
    end
  end
end
def.method("number").SwitchTo = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  local preNode = self.curNode
  self.curNode = nodeId
  self.nodes[preNode]:Hide()
  self.nodes[self.curNode]:Show()
end
AvatarPanel.Commit()
return AvatarPanel
