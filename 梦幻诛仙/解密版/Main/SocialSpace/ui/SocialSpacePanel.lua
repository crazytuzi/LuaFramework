local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SocialSpacePanel = Lplus.Extend(ECPanelBase, MODULE_NAME)
local Vector = require("Types.Vector")
local GUIUtils = require("GUI.GUIUtils")
local SpaceFriendsCircleNode = import(".SpaceFriendsCircleNode")
local SpaceInfoNode = import(".SpaceInfoNode")
local SpaceMessageBoard = import(".SpaceMessageBoard")
local SpaceOwnerMessagesNode = import(".SpaceOwnerMessagesNode")
local ECSocialSpaceMan = import("..ECSocialSpaceMan")
local def = SocialSpacePanel.define
local SocialSpaceUtils = import("..SocialSpaceUtils")
local DecoType = require("consts.mzm.gsp.item.confbean.FriendsCircleOrnamentItemType")
local NodeId = {
  None = 0,
  FriendsCircle = 1,
  MessageBoard = 2,
  Moments = 3,
  SpaceInfo = 4
}
def.const("table").NodeId = NodeId
local NodeDefines = {
  [NodeId.FriendsCircle] = {
    tabName = "Tap_001",
    rootName = "Img_001",
    nodeClass = SpaceFriendsCircleNode,
    sort = 1,
    needSpaceInfo = true
  },
  [NodeId.MessageBoard] = {
    tabName = "Tap_002",
    rootName = "Img_002",
    nodeClass = SpaceMessageBoard,
    sort = 2,
    needSpaceInfo = true
  },
  [NodeId.Moments] = {
    tabName = "Tap_003",
    rootName = "Img_003",
    nodeClass = SpaceOwnerMessagesNode,
    sort = 3,
    needSpaceInfo = true
  }
}
def.field("table").m_UIGOs = nil
def.field("table").m_nodes = nil
def.field("number").m_curNodeId = NodeId.None
def.field("number").m_nextNodeId = NodeId.None
def.field("table").m_baseInfo = nil
def.field("userdata").m_ownerId = Zero_Int64_Init
def.field("number").m_ownerServerId = 0
def.field("string").m_ownerName = ""
def.field("userdata").m_targetMsgId = nil
def.field("userdata").m_targetLeaveMsgId = nil
def.field("number").m_pendantDecoResId = 0
def.field("number").m_rahmenDecoResId = 0
def.field("function").m_onPanelReady = nil
local MAX_ALIVE_PANEL_NUM = 2
local panelStack = {}
def.static("table", "=>", SocialSpacePanel).ShowPanel = function(params)
  local self = SocialSpacePanel()
  self.m_ownerId = params.ownerId
  self.m_targetMsgId = params.msgId or Zero_Int64
  self.m_targetLeaveMsgId = params.leaveMsgId or Zero_Int64
  self.m_onPanelReady = params.onPanelReady
  self.m_TrigGC = true
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_SOCIAL_SPACE_PANEL, 1)
  return self
end
def.override("=>", "boolean").IsAliveInReconnect = function(self)
  if _G.IsCrossingServer() then
    return false
  end
  return true
end
def.override("boolean", "boolean").OnGUIChange = function(self, rolechange, userchange)
end
def.override().OnCreate = function(self)
  self:InitData()
  self:InitUI()
  self:UpdateUI()
  self:TryAddPopular()
end
def.override().AfterCreate = function(self)
  local panelNum = #panelStack
  for i = panelNum, 1, -1 do
    local panel = panelStack[i]
    if panel.m_ownerId == self.m_ownerId then
      panel:DestroyPanel()
      panelStack[i] = nil
    end
  end
  panelNum = #panelStack
  for i = panelNum, MAX_ALIVE_PANEL_NUM, -1 do
    local panel = panelStack[i]
    panel:DestroyPanel()
    panelStack[i] = nil
  end
  table.insert(panelStack, self)
  self:UpdatePanelOpenState()
  if self.m_onPanelReady then
    self.m_onPanelReady(self)
  end
end
def.override().OnDestroy = function(self)
  local removeIdx
  for i, v in ipairs(panelStack) do
    if self == v then
      removeIdx = i
      break
    end
  end
  if removeIdx then
    table.remove(panelStack, removeIdx)
  end
  self:UpdatePanelOpenState()
  self:HideCurNode()
  self:DestroyAllNode()
  self.m_UIGOs = nil
  self.m_nodes = nil
  self.m_curNodeId = NodeId.None
  self.m_targetMsgId = nil
  self.m_targetLeaveMsgId = nil
  self.m_pendantDecoResId = 0
  self.m_rahmenDecoResId = 0
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    if not _G.IsNil(self.m_panel) then
      self:HideCurNode()
    end
    return
  end
  self:SwitchToNode(self.m_nextNodeId)
end
def.method().HideCurNode = function(self)
  if self.m_nodes == nil then
    return
  end
  if self.m_curNodeId ~= NodeId.None then
    local node = self.m_nodes[self.m_curNodeId]
    if node then
      node:Hide()
    end
    self.m_curNodeId = NodeId.None
  end
  self:HideSpaceInfoNode()
end
def.method().DestroyAllNode = function(self)
  for nodeId, node in pairs(self.m_nodes) do
    node:Destroy()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  warn("onClickObj", id)
  if id == "Btn_Close" then
    self:OnCloseBtnClick()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      self:Check2SwitchToNode(nodeId)
    elseif self.m_curNodeId ~= NodeId.None then
      local node = self.m_nodes[self.m_curNodeId]
      if node then
        node:onClickObj(obj)
      end
      if self.m_nodes[NodeId.SpaceInfo] and self.m_nodes[NodeId.SpaceInfo]:IsNodeShow() then
        self.m_nodes[NodeId.SpaceInfo]:onClickObj(obj)
      end
    end
  end
end
def.method("userdata", "boolean").onPressObj = function(self, obj, state)
  local node = self.m_nodes[self.m_curNodeId]
  if node then
    node:onPressObj(obj, state)
  end
end
def.method("string").onDragStart = function(self, id)
  local node = self.m_nodes[self.m_curNodeId]
  if node then
    node:onDragStart(id)
  end
end
def.method("string").onDragEnd = function(self, id)
  local node = self.m_nodes[self.m_curNodeId]
  if node then
    node:onDragEnd(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.m_nodes[NodeId.SpaceInfo] and self.m_nodes[NodeId.SpaceInfo]:IsNodeShow() then
    self.m_nodes[NodeId.SpaceInfo]:onDrag(id, dx, dy)
  end
  local node = self.m_nodes[self.m_curNodeId]
  if node then
    node:onDrag(id, dx, dy)
  end
end
def.method("string", "string").onTextChange = function(self, id, text)
  local node = self.m_nodes[self.m_curNodeId]
  if node then
    node:onTextChange(id, text)
  end
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Img_Bg0 = self.m_panel:FindDirect("Img _Bg0")
  self.m_UIGOs.Group_Dec = self.m_UIGOs.Img_Bg0:FindDirect("Group_Dec")
  self.m_UIGOs.Texture_Rahmens = {}
  local Texture_Bg1 = self.m_UIGOs.Img_Bg0:FindDirect("Group_Playerinfo/Group_Left/Model/Texture_Bg")
  local Texture_Bg2 = self.m_UIGOs.Img_Bg0:FindDirect("Group_Playerinfo/Group_Left/Texture/Texture_Bg")
  table.insert(self.m_UIGOs.Texture_Rahmens, Texture_Bg1)
  table.insert(self.m_UIGOs.Texture_Rahmens, Texture_Bg2)
  local tab1 = self.m_UIGOs.Img_Bg0:FindDirect("Tap_001")
  local tab2 = self.m_UIGOs.Img_Bg0:FindDirect("Tap_002")
  local initPos = tab1.localPosition
  local posDelta = tab2.localPosition - tab1.localPosition
  self.m_UIGOs.Tab = {}
  self.m_UIGOs.Tab.initPos = initPos
  self.m_UIGOs.Tab.posDelta = posDelta
  self:InitNodes()
end
def.method().InitNodes = function(self)
  self.m_nodes = {}
  local Img_Bg = self.m_UIGOs.Img_Bg0
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = Img_Bg:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    if v.nodeClass then
      local node = v.nodeClass()
      node:Create(self, nodeRoot, {nodeId = nodeId})
      self.m_nodes[nodeId] = node
    end
  end
  local opendNodes = {}
  for nodeId, node in pairs(self.m_nodes) do
    if node:IsOpen() then
      table.insert(opendNodes, node)
    else
      GUIUtils.SetActive(node.m_node, false)
      local nodeDef = NodeDefines[node.nodeId]
      local tabGO = Img_Bg:FindDirect(nodeDef.tabName)
      GUIUtils.SetActive(tabGO, false)
    end
  end
  table.sort(opendNodes, function(l, r)
    return l.sort < r.sort
  end)
  for i, node in ipairs(opendNodes) do
    local tabGO = self:GetTabGOByNodeId(node.nodeId)
    tabGO.localPosition = self.m_UIGOs.Tab.initPos + self.m_UIGOs.Tab.posDelta * (i - 1)
  end
  self:AutoSelectNextNode()
end
def.method().InitData = function(self)
  local spaceData = ECSocialSpaceMan.Instance():GetSpaceData(self.m_ownerId)
  if not spaceData then
    return
  end
  self.m_baseInfo = spaceData.baseInfo
  if not self.m_baseInfo then
    self:DestroyPanel()
    return
  end
  self.m_ownerServerId = self.m_baseInfo.serverId
  self.m_ownerName = self.m_baseInfo.playerName
end
def.method().UpdateUI = function(self)
  self:UpdateTitle()
  self:UpdateDecorations()
end
def.method().UpdateTitle = function(self)
  local Label_Title = self.m_UIGOs.Img_Bg0:FindDirect("Group_Title/Label_Title")
  local title
  if self:IsMySpace() then
    title = textRes.SocialSpace[25]
  else
    title = textRes.SocialSpace[26]:format(self.m_ownerName)
  end
  GUIUtils.SetText(Label_Title, title)
end
def.method("=>", "boolean").IsMySpace = function(self)
  local myRoleId = _G.GetMyRoleID()
  return myRoleId == self.m_ownerId
end
def.method().AutoSelectNextNode = function(self)
  if self.m_targetMsgId ~= Zero_Int64 then
    self.m_nextNodeId = NodeId.Moments
  elseif self.m_targetLeaveMsgId ~= Zero_Int64 then
    self.m_nextNodeId = NodeId.MessageBoard
  elseif self:IsMySpace() then
    self.m_nextNodeId = NodeId.FriendsCircle
  else
    self.m_nextNodeId = NodeId.MessageBoard
  end
end
def.method("number").SwitchToNode = function(self, nodeId)
  if self.m_curNodeId == nodeId then
    return
  end
  if self.m_curNodeId ~= NodeId.None then
    local node = self.m_nodes[self.m_curNodeId]
    if node then
      node:Hide()
    end
  end
  local nodeDef = NodeDefines[nodeId]
  if nodeDef then
    if nodeDef.needSpaceInfo then
      self:ShowSpaceInfoNode()
    else
      self:HideSpaceInfoNode()
    end
  end
  self.m_curNodeId = nodeId
  self.m_nextNodeId = self.m_curNodeId
  local tabGO = self:GetTabGOByNodeId(nodeId)
  GUIUtils.Toggle(tabGO, true)
  local node = self.m_nodes[self.m_nextNodeId]
  if node then
    node:Show()
  end
end
def.method("number", "=>", "userdata").GetTabGOByNodeId = function(self, nodeId)
  local nodeDef = NodeDefines[nodeId]
  local tabGO = self.m_UIGOs.Img_Bg0:FindDirect(nodeDef.tabName)
  return tabGO
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in pairs(NodeDefines) do
    if tabName == v.tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method("number").Check2SwitchToNode = function(self, nodeId)
  local node = self.m_nodes[nodeId]
  if node then
    node:SetNeedReset(true)
  end
  self:SwitchToNode(nodeId)
end
def.method("=>", "table").GetCurNode = function(self)
  return self.m_nodes[self.m_curNodeId]
end
def.method().OnCloseBtnClick = function(self)
  self:DestroyPanel()
end
def.method().ShowSpaceInfoNode = function(self)
  if self.m_nodes[NodeId.SpaceInfo] == nil then
    local node = SpaceInfoNode()
    local Img_Bg = self.m_UIGOs.Img_Bg0
    local nodeRoot = Img_Bg:FindDirect("Group_Playerinfo")
    node:Create(self, nodeRoot, {
      nodeId = NodeId.SpaceInfo
    })
    self.m_nodes[NodeId.SpaceInfo] = node
  end
  if not self.m_nodes[NodeId.SpaceInfo]:IsNodeShow() then
    self.m_nodes[NodeId.SpaceInfo]:Show()
  end
end
def.method().HideSpaceInfoNode = function(self)
  if self.m_nodes[NodeId.SpaceInfo] and self.m_nodes[NodeId.SpaceInfo]:IsNodeShow() then
    self.m_nodes[NodeId.SpaceInfo]:Hide()
  end
end
def.method("number", "number").SetSpaceDeco = function(self, decoType, itemId)
  local decoItemCfg
  if itemId ~= 0 then
    decoItemCfg = SocialSpaceUtils.GetDecorationItemCfg(itemId)
  end
  local resId = decoItemCfg and decoItemCfg.resId or 0
  if decoType == DecoType.TYPE_PENDANT_ORNAMENT then
    self:SetPendantDeco(resId)
  elseif decoType == DecoType.TYPE_RAHMEN_ORNAMENT then
    self:SetRahmenDeco(resId)
  end
end
def.method("number").SetPendantDeco = function(self, resId)
  if self.m_pendantDecoResId == resId then
    return
  end
  self.m_pendantDecoResId = resId
  local function removeOldDecoGo(...)
    if not _G.IsNil(self.m_UIGOs.PendantDecGO) then
      GameObject.Destroy(self.m_UIGOs.PendantDecGO)
      self.m_UIGOs.PendantDecGO = nil
    end
  end
  local resPath = _G.GetIconPath(resId)
  if resPath == "" then
    removeOldDecoGo()
    return
  end
  GameUtil.AsyncLoad(resPath, function(ass)
    if ass == nil or not self:IsLoaded() then
      return
    end
    if resId ~= self.m_pendantDecoResId then
      return
    end
    removeOldDecoGo()
    local typename = getmetatable(ass).name
    if typename ~= "GameObject" then
      Debug.LogError("Bad type set to PendantDeco, type:" .. typename .. ",path:" .. resPath)
      return
    end
    local go = GameObject.Instantiate(ass)
    go:SetActive(true)
    go.name = "PendantDeco_" .. resId
    go.parent = self.m_UIGOs.Group_Dec
    go.localScale = Vector.Vector3.one
    go.localPosition = Vector.Vector3.zero
    self.m_UIGOs.PendantDecGO = go
  end)
end
def.method("number").SetRahmenDeco = function(self, resId)
  if self.m_rahmenDecoResId == resId then
    return
  end
  self.m_rahmenDecoResId = resId
  for i, TextureGO in ipairs(self.m_UIGOs.Texture_Rahmens) do
    GUIUtils.SetTexture(TextureGO, resId, function(uiTexture)
      uiTexture:MakePixelPerfect()
    end)
  end
end
def.method().UpdateDecorations = function(self)
  local widgetItemId, photoFrameItemId
  if self:IsMySpace() then
    local savedDecoData = ECSocialSpaceMan.Instance():GetSavedDecorateData()
    widgetItemId = savedDecoData[DecoType.TYPE_PENDANT_ORNAMENT] or 0
    photoFrameItemId = savedDecoData[DecoType.TYPE_RAHMEN_ORNAMENT] or 0
  else
    widgetItemId = self.m_baseInfo.widget
    photoFrameItemId = self.m_baseInfo.photoFrame
  end
  self:SetSpaceDeco(DecoType.TYPE_PENDANT_ORNAMENT, widgetItemId)
  self:SetSpaceDeco(DecoType.TYPE_RAHMEN_ORNAMENT, photoFrameItemId)
end
def.method().UpdatePanelOpenState = function(self)
  local opened = false
  local panel = panelStack[#panelStack]
  if panel and panel:IsMySpace() then
    opened = true
  end
  ECSocialSpaceMan.Instance():SetSelfSpacePanelOpened(opened)
end
def.method().TryAddPopular = function(self)
  if self:IsMySpace() then
    return
  end
  ECSocialSpaceMan.Instance():TryAddSpacePopular(self.m_ownerId)
end
return SocialSpacePanel.Commit()
