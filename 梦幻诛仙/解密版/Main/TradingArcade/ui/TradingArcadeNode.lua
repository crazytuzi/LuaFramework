local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local TradingArcadeNode = Lplus.Extend(TabNode, "TradingArcadeNode")
local TradingArcadeModule = Lplus.ForwardDeclare("TradingArcadeModule")
local GUIUtils = require("GUI.GUIUtils")
local def = TradingArcadeNode.define
local NodeId = {
  None = 0,
  BUY = 1,
  SELL = 2,
  PUBLIC = 3
}
def.const("table").NodeId = NodeId
local NodeDefines = {
  [NodeId.BUY] = {
    tabName = "Tab_Buy",
    rootName = "Group_Buy",
    nodeFName = "Main.TradingArcade.ui.TradingArcadeBuy"
  },
  [NodeId.SELL] = {
    tabName = "Tab_Sell",
    rootName = "Group_Sell",
    nodeFName = "Main.TradingArcade.ui.TradingArcadeSell"
  },
  [NodeId.PUBLIC] = {
    tabName = "Tab_Public",
    rootName = "Group_Buy",
    nodeFName = "Main.TradingArcade.ui.TradingArcadePublic"
  }
}
def.const("table").SpriteName = {
  Nil = "nil",
  Selled = "Img_Sell",
  Expire = "Img_Overdue",
  Get = "Img_Get"
}
def.field("table").nodes = nil
def.field("number").curNode = NodeId.None
def.field("number").nextNode = NodeId.BUY
def.field("table").tabToggles = nil
def.field("userdata").Img_Red = nil
def.field("boolean").m_isUIInited = false
def.field("number").timerId = 0
local instance
def.static("=>", TradingArcadeNode).Instance = function(self)
  if instance == nil then
    instance = TradingArcadeNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  TabNode.Init(self, base, node)
  self.nodes = {}
end
def.method().InitUI = function(self)
  if self.m_isUIInited then
    return
  end
  self.m_isUIInited = true
  self.tabToggles = {}
  for nodeId, v in ipairs(NodeDefines) do
    local toggleObj = self.m_node:FindDirect(v.tabName)
    if toggleObj then
      self.tabToggles[nodeId] = toggleObj:GetComponent("UIToggle")
      local uiToggledObjects = toggleObj:GetComponent("UIToggledObjects")
      if uiToggledObjects then
        Object.DestroyImmediate(uiToggledObjects)
      end
    end
    local nodeRoot = self.m_node:FindDirect(v.rootName)
    GUIUtils.SetActive(nodeRoot, false)
  end
end
def.method().UpdateTabNotify = function(self)
  local hasNotify = TradingArcadeModule.Instance():HasNotify()
  if self.Img_Red == nil or self.Img_Red.isnil then
    self.Img_Red = self.m_node.parent:FindDirect("Tab_BlackShop/Img_Red")
  end
  GUIUtils.SetActive(self.Img_Red, hasNotify)
  if self.isShow then
    self:UpdateNodeTabNotifys()
  end
end
def.method().UpdateNodeTabNotifys = function(self)
  for nodeId, v in ipairs(NodeDefines) do
    local hasNotify = self:GetNode(nodeId):HasNotify()
    local Img_Red = self.tabToggles[nodeId].gameObject:FindDirect("Img_Red")
    GUIUtils.SetActive(Img_Red, hasNotify)
  end
end
def.method("number").SwitchToNode = function(self, nodeId)
  if self.curNode == nodeId then
    return
  end
  if self.curNode ~= NodeId.None then
    self:GetNode(self.curNode):Hide()
  end
  self.curNode = nodeId
  self.nextNode = self.curNode
  self.tabToggles[self.curNode]:set_value(true)
  self:GetNode(self.curNode):Show()
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateNodeTabNotifys()
  self:SwitchToNode(self.nextNode)
  self:StartUpdateTimer()
end
def.override().OnHide = function(self)
  if self.curNode == NodeId.None then
    return
  end
  self:GetNode(self.curNode):Hide()
  self.curNode = NodeId.None
  self:Clear()
  self:StopUpdateTimer()
end
def.method().Clear = function(self)
  self.tabToggles = nil
  self.m_isUIInited = false
  gmodule.moduleMgr:GetModule(ModuleId.TRADING_ARCADE):ClearSubId2CfgIdCaches()
  require("Main.TradingArcade.ui.BuyAndPublicCommon").Clear()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  do break end
  do break end
  local nodeId = self:GetTabNodeId(id)
  if nodeId ~= NodeId.None then
    self:SwitchToNode(nodeId)
  else
    self:GetNode(self.curNode):onClickObj(clickobj)
  end
end
def.override("string").onDragStart = function(self, id)
  self:GetNode(self.curNode):onDragStart(id)
end
def.override("string").onDragEnd = function(self, id)
  self:GetNode(self.curNode):onDragEnd(id)
end
def.method().UpdateRequirementsCondTbl = function(self)
end
def.method("number", "number").SellToTradingArcade = function(self, itemKey, itemId)
  self:SwitchToNode(NodeId.SELL)
  self:GetNode(self.curNode):SellItem(itemKey, itemId)
end
def.method("number", "=>", "table").GetNode = function(self, nodeId)
  local node = self.nodes[nodeId]
  if node == nil and NodeDefines[nodeId].nodeFName then
    local Node = require(NodeDefines[nodeId].nodeFName)
    node = Node.Instance()
    local nodeRoot = self.m_node:FindDirect(NodeDefines[nodeId].rootName)
    self.nodes[nodeId] = node
    self.nodes[nodeId]:InitEx({
      self.m_base,
      nodeRoot,
      nodeId
    })
  end
  return node
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in ipairs(NodeDefines) do
    if v.tabName == tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method("userdata").Touch = function(self, go)
  self.m_base.m_msgHandler:Touch(go)
end
def.method().StartUpdateTimer = function(self)
  if self.timerId ~= 0 then
    return
  end
  self.timerId = GameUtil.AddGlobalTimer(5, false, function()
    if self.m_base.m_panel == nil then
      self:StopUpdateTimer()
      return
    end
    self:GetNode(self.curNode):OnTimer()
  end)
end
def.method().StopUpdateTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method("number", "number", "number").OpenSubTypePage = function(self, nodeId, subId, siftLevel)
  if self.isShow == false then
    return
  end
  if nodeId == NodeId.BUY or nodeId == NodeId.PUBLIC then
    local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
    BuyServiceMgr.Instance():ClearAllGoods()
    local node = self:GetNode(nodeId)
    if not node.isShow then
      self:SwitchToNode(nodeId)
    end
    node:OpenSubTypePage(subId, siftLevel)
  end
end
def.method("number", "table").SetSearchMgr = function(self, nodeId, searchMgr)
  if nodeId == NodeId.BUY or nodeId == NodeId.PUBLIC then
    local node = self:GetNode(nodeId)
    node:SetSearchWrapper(searchMgr)
  end
end
def.method("number", "table").OpenWithMarketItem = function(self, nodeId, marketItem)
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  local ItemUtils = require("Main.Item.ItemUtils")
  if nodeId == NodeId.BUY or nodeId == NodeId.PUBLIC then
    local cfg = TradingArcadeUtils.GetMarketItemCfg(marketItem.itemId)
    local subid = cfg and cfg.subid or 0
    local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
    BuyServiceMgr.Instance():ClearAllGoods()
    BuyServiceMgr.Instance():AddPageItemInfo({
      subid = subid,
      totalPageNum = 1,
      pageIndex = 1,
      marketItemList = {marketItem}
    })
    local itemBase = ItemUtils.GetItemBase(marketItem.itemId)
    local BuyAndPublicCommon = require("Main.TradingArcade.ui.BuyAndPublicCommon")
    BuyAndPublicCommon.LocateAndSetSubTypePage(subid, itemBase.useLevel)
    self.nextNode = nodeId
  end
end
def.method("number", "table").OpenWithMarketPet = function(self, nodeId, marketPet)
  local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
  if nodeId == NodeId.BUY or nodeId == NodeId.PUBLIC then
    local cfg = TradingArcadeUtils.GetMarketPetCfg(marketPet.petCfgId)
    local subid = cfg and cfg.subid or 0
    local BuyServiceMgr = require("Main.TradingArcade.BuyServiceMgr")
    BuyServiceMgr.Instance():ClearAllGoods()
    BuyServiceMgr.Instance():AddPagePetInfo({
      subid = subid,
      totalPageNum = 1,
      pageIndex = 1,
      marketPetList = {marketPet}
    })
    local BuyAndPublicCommon = require("Main.TradingArcade.ui.BuyAndPublicCommon")
    BuyAndPublicCommon.LocateAndSetSubTypePage(subid, 0)
    self.nextNode = nodeId
  end
end
def.method("table").TradingArcadeBuy = function(self, params)
  local MarketState = require("netio.protocol.mzm.gsp.market.MarketState")
  local function getNodeId(state)
    if bit.band(state, MarketState.STATE_PUBLIC) ~= 0 then
      return NodeId.PUBLIC
    elseif bit.band(state, MarketState.STATE_SELL) ~= 0 then
      return NodeId.BUY
    end
    return NodeId.PUBLIC
  end
  if params.marketItem then
    local nodeId = getNodeId(params.marketItem.state)
    self:OpenWithMarketItem(nodeId, params.marketItem)
  elseif params.marketPet then
    local nodeId = getNodeId(params.marketPet.state)
    self:OpenWithMarketPet(nodeId, params.marketPet)
  end
end
TradingArcadeNode.Commit()
return TradingArcadeNode
