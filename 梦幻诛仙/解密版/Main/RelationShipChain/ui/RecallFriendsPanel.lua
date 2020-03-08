local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local RelationShipChainMgr = require("Main.RelationShipChain.RelationShipChainMgr")
local RecallNode = require("Main.Recall.ui.RecallNode")
local ReCallFriendsNode = require("Main.RelationShipChain.ui.ReCallFriendsNode")
local GetRecallAwardNode = require("Main.RelationShipChain.ui.GetRecallAwardNode")
local RecallModule = require("Main.Recall.RecallModule")
local RecallFriendsPanel = Lplus.Extend(ECPanelBase, "RecallFriendsPanel")
local def = RecallFriendsPanel.define
def.field("table")._subNodeInfos = nil
def.field("number").m_CurNode = -1
def.field("table").m_Nodes = nil
def.field("table").m_UIGO = nil
local instance
def.static("=>", RecallFriendsPanel).Instance = function()
  if not instance then
    instance = RecallFriendsPanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, node)
  if self:IsShow() then
    self:DestroyPanel()
  end
  self.m_CurNode = node
  self:CreatePanel(RESPATH.PREFAB_CALL_BACK_FRIENDS_PANEL, GUILEVEL.MUTEX)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self.m_Nodes = {}
  for k, v in ipairs(self:GetSubNodeInfos()) do
    local instance = v.Instance
    local groupGO = self.m_panel:FindDirect(v.GroupName)
    local tabGO = self.m_panel:FindDirect(v.TabName)
    self.m_Nodes[k] = instance
    self.m_Nodes[k]:Init(self, groupGO)
    tabGO:SetActive(instance:IsUnlock())
  end
  if RelationShipChainMgr.IsRecallPlayer() then
    RelationShipChainMgr.GetRecallFriendSignAwardInfo({})
  end
end
def.override().OnDestroy = function(self)
  if self._subNodeInfos then
    local node = self.m_CurNode
    for _, v in ipairs(self._subNodeInfos) do
      local instance = v.Instance
      if instance and instance.isShow then
        instance:Hide()
      end
    end
    self._subNodeInfos = nil
  end
  self.m_CurNode = 1
  self.m_Nodes = nil
  self.m_UIGO = nil
end
def.override("boolean").OnShow = function(self, flag)
  self:_HandleEventListeners(flag)
  if flag then
    self:Update()
    self:UpdateNewRecallReddot()
    self:UpdateNewAwardReddot()
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_Close" then
    self:DestroyPanel()
    Event.DispatchEvent(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.ClosePanel, nil)
  elseif id == "Tab_Friend" then
    self:SwitchToNode(self:GetSubNodeInfos()[1].ID)
  elseif id == "Tab_Prize" then
    self:SwitchToNode(self:GetSubNodeInfos()[2].ID)
  else
    self.m_Nodes[self.m_CurNode]:onClickObj(clickobj)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tab_Power" then
    self:SwitchToNode(self:GetSubNodeInfos()[1].ID)
  elseif id == "Tab_Prize" then
    self:SwitchToNode(self:GetSubNodeInfos()[2].ID)
  else
    self.m_Nodes[self.m_CurNode]:onClick(id)
  end
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.m_Nodes[self.m_CurNode]:onDrag(id, dx, dy)
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.m_Nodes[self.m_CurNode]:onPress(id, state)
end
def.method("number").SwitchToNode = function(self, node)
  if self.m_CurNode == node then
    return
  end
  self.m_CurNode = node
  self:Update()
end
def.method().Update = function(self)
  local node = self.m_CurNode
  for _, v in ipairs(self:GetSubNodeInfos()) do
    local instance = v.Instance
    local tabGO = self.m_panel:FindDirect(v.TabName)
    if v.ID == node then
      instance:InitUI()
      instance:Show()
    else
      instance:Hide()
    end
    GUIUtils.Toggle(tabGO, v.ID == node)
    instance:UpdateRedot()
  end
end
def.method("=>", "table").GetSubNodeInfos = function(self)
  if nil == self._subNodeInfos then
    local recallNode = RecallModule.Instance():IsOpen(false) and RecallNode.Instance() or ReCallFriendsNode.Instance()
    self._subNodeInfos = {
      {
        ID = 1,
        Instance = recallNode,
        GroupName = "Img_Bg0/Group_Friend",
        TabName = "Img_Bg0/Tab_Friend"
      },
      {
        ID = 2,
        Instance = GetRecallAwardNode.Instance(),
        GroupName = "Img_Bg0/Group_Prize",
        TabName = "Img_Bg0/Tab_Prize"
      }
    }
  end
  return self._subNodeInfos
end
def.method("boolean")._HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendBigGiftAward, RecallFriendsPanel.OnNotifyRecallFriendBigGiftAward)
    eventFunc(ModuleId.RELATIONSHIPCHAIN, gmodule.notifyId.RelationShipChain.NotifyRecallFriendSignAward, RecallFriendsPanel.OnNotifyRecallFriendSignAward)
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.RECALL_AFK_INFO_CHANGE, RecallFriendsPanel.OnRecallInfoChange)
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.HERO_RETURN_INFO_CHANGE, RecallFriendsPanel.OnAwardInfoChange)
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_ACTIVE_CHANGE, RecallFriendsPanel.OnAwardInfoChange)
    eventFunc(ModuleId.RECALL, gmodule.notifyId.Recall.BINDED_FRIEND_REBATE_CHANGE, RecallFriendsPanel.OnAwardInfoChange)
    eventFunc(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, RecallFriendsPanel.OnFunctionOpenChange)
  end
end
def.static("table", "table").OnNotifyRecallFriendBigGiftAward = function(param, context)
  local self = RecallFriendsPanel.Instance()
  self:UpdateNewAwardReddot()
end
def.static("table", "table").OnNotifyRecallFriendSignAward = function(param, context)
  local self = RecallFriendsPanel.Instance()
  self:UpdateNewAwardReddot()
end
def.static("table", "table").OnRecallInfoChange = function(param, context)
  local self = RecallFriendsPanel.Instance()
  self:UpdateNewRecallReddot()
end
def.method().UpdateNewRecallReddot = function(self)
  local Img_Red = self.m_panel:FindDirect("Img_Bg0/Tab_Friend/Img_Red")
  GUIUtils.SetActive(Img_Red, RecallModule.Instance():NeedRecallReddot())
end
def.static("table", "table").OnAwardInfoChange = function(param, context)
  local self = RecallFriendsPanel.Instance()
  self:UpdateNewAwardReddot()
end
def.method().UpdateNewAwardReddot = function(self)
  local bGiftReddot = RecallModule.Instance():NeedGiftReddot()
  local bLoginReddot = RecallModule.Instance():NeedLoginReddot()
  local bActiveReddot = RecallModule.Instance():NeedActiveReddot()
  local bRebateReddot = RecallModule.Instance():NeedRebateReddot()
  local Img_Red = self.m_panel:FindDirect("Img_Bg0/Tab_Prize/Img_Red")
  GUIUtils.SetActive(Img_Red, bGiftReddot or bLoginReddot or bActiveReddot or bRebateReddot)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_CROSS_SERVER_RECALL_FRIEND or param.feature == ModuleFunSwitchInfo.TYPE_RECALL_FRIEND_REBATE or param.feature == ModuleFunSwitchInfo.TYPE_RECALL_FRIEND_BIND then
    local self = RecallFriendsPanel.Instance()
    self:DestroyPanel()
  end
end
return RecallFriendsPanel.Commit()
