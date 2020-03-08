local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local AwardPanel = Lplus.Extend(ECPanelBase, "AwardPanel")
local DailySignInDelegateNode = require("Main.Award.ui.DailySignInDelegateNode")
local AccumulativeLoginNode = require("Main.Award.ui.AccumulativeLoginNode")
local LevelUpAwardNode = require("Main.Award.ui.LevelUpAwardNode")
local GiftNode = require("Main.Award.ui.GiftNode")
local OnlineAwardNode = require("Main.Award.ui.OnlineAwardNode")
local FirstRechargeAwardNode = require("Main.Award.ui.FirstRechargeAwardNode")
local RechargeOBTAwardNode = require("Main.Award.ui.RechargeOBTAwardNode")
local GrowFundNode = require("Main.Award.ui.GrowFundNode")
local FresherSignInMgr = require("Main.Award.mgr.FresherSignInMgr")
local FresherSignInNode = require("Main.Award.ui.FresherSignInNode")
local GrowFundMgr = require("Main.Award.mgr.GrowFundMgr")
local MonthCardNode = require("Main.Award.ui.MonthCardNode")
local MonthCardMgr = require("Main.Award.mgr.MonthCardMgr")
local LotteryAwardNode = require("Main.Award.ui.LotteryAwardNode")
local NewServerAwardNode = require("Main.Award.ui.NewServerAwardNode")
local RechargeLeijiAwardNode = require("Main.Award.ui.RechargeLeijiAwardNode")
local HeroReturnNode = require("Main.Award.ui.HeroReturnNode")
local DailyGiftAwardNode = require("Main.Award.ui.DailyGiftAwardNode")
local StartWorkBenefitsNode = require("Main.Award.ui.StartWorkBenefitsNode")
local AllowPushNode = require("Main.Award.ui.AllowPushNode")
local InviteAwardNode = require("Main.Award.ui.InviteAwardNode")
local EfunBindPhoneAwardNode = require("Main.Award.ui.EfunBindPhoneAwardNode")
local BackExpNode = require("Main.Award.ui.BackExpNode")
local StrongerFundNode = require("Main.Award.ui.StrongerFundNode")
local FeatureVoteNode = require("Main.Award.ui.FeatureVoteNode")
local WechatInviteAwardNode = require("Main.Award.ui.WechatInviteAwardNode")
local ExchangeYuanBaoNode = require("Main.Award.ui.ExchangeYuanBaoNode")
local MondayFreeNode = require("Main.Award.ui.MondayFreeNode")
local ActivityRetrieveNode = require("Main.Award.ui.ActivityRetrieveNode")
local ECMSDK = require("ProxySDK.ECMSDK")
local Vector = require("Types.Vector")
local def = AwardPanel.define
local Vector = require("Types.Vector")
local ECGUIMan = require("GUI.ECGUIMan")
local NodeId = {
  None = 0,
  DailySignIn = 1,
  AccumulativeLogin = 2,
  LevelUpAward = 3,
  Gift = 4,
  OnlineAward = 5,
  FirstRechargeAward = 6,
  RechargeOBTAward = 7,
  GrowFund = 8,
  FresherSignIn = 9,
  MonthCard = 10,
  LotteryAward = 11,
  RechargeLeiji = 12,
  NewServerAward = 13,
  HeroReturn = 14,
  DailyGiftAward = 15,
  StartWork = 16,
  InviteAward = 17,
  AllowPush = 18,
  BackExp = 19,
  StongerFund = 20,
  FeatureVote = 21,
  WechatInviteAward = 22,
  EfunBindPhoneAward = 23,
  ExchangeYuanBao = 25,
  MondayFree = 26,
  ActivityRetrieve = 27
}
def.const("table").NodeId = NodeId
def.field("table").nodes = nil
def.field("table").showedNodeList = nil
def.field("number").curNode = NodeId.DailySignIn
def.field("boolean").isSpecNode = false
def.field("table").uiObjs = nil
def.field("table").tabToggles = nil
def.field("table").tabPos = nil
def.field("table").tabNameMapNodeId = nil
def.field("number").timerId = 0
local NodeDefines = {
  [NodeId.DailySignIn] = {
    tabName = "Tab_QiaoDao",
    rootName = "Group_Qiandao",
    node = DailySignInDelegateNode
  },
  [NodeId.ActivityRetrieve] = {
    tabName = "Tab_ActivityGetBack",
    rootName = "Group_AsyncRoot",
    node = ActivityRetrieveNode
  },
  [NodeId.AccumulativeLogin] = {
    tabName = "Tab_LeiDeng",
    rootName = "Group_LeiDeng",
    node = AccumulativeLoginNode
  },
  [NodeId.LevelUpAward] = {
    tabName = "Tab_LvUp",
    rootName = "Group_LvUp",
    node = LevelUpAwardNode
  },
  [NodeId.Gift] = {
    tabName = "Tab_PresentId",
    rootName = "Group_PresentId",
    node = GiftNode
  },
  [NodeId.OnlineAward] = {
    tabName = "Tab_OnLine",
    rootName = "Group_OnLine",
    node = OnlineAwardNode
  },
  [NodeId.FirstRechargeAward] = {
    tabName = "Tab_RechargeFirst",
    rootName = "Group_AsyncRoot",
    node = FirstRechargeAwardNode
  },
  [NodeId.RechargeOBTAward] = {
    tabName = "Tab_RechargeReturn",
    rootName = "Group_AsyncRoot",
    node = RechargeOBTAwardNode
  },
  [NodeId.GrowFund] = {
    tabName = "Tab_GrowFund",
    rootName = "Group_GrowFund",
    node = GrowFundNode
  },
  [NodeId.FresherSignIn] = {
    tabName = "Tab_QiaoDao2",
    rootName = "Group_Qiandao2",
    node = FresherSignInNode
  },
  [NodeId.MonthCard] = {
    tabName = "Tab_WeekCard",
    rootName = "Group_WeekCard",
    node = MonthCardNode,
    dynamicName = function()
      return MonthCardMgr.Instance():GetCurMonthCardName()
    end
  },
  [NodeId.LotteryAward] = {
    tabName = "Tab_RandomPrize",
    rootName = "Group_AsyncRoot",
    node = LotteryAwardNode
  },
  [NodeId.NewServerAward] = {
    tabName = "Tab_NewService",
    rootName = "Group_NewService",
    node = NewServerAwardNode
  },
  [NodeId.RechargeLeiji] = {
    tabName = "Tab_RechargeLeiJi",
    rootName = "Group_AsyncRoot",
    node = RechargeLeijiAwardNode
  },
  [NodeId.HeroReturn] = {
    tabName = "Tab_HeroBack",
    rootName = "Group_HeroBack",
    node = HeroReturnNode
  },
  [NodeId.DailyGiftAward] = {
    tabName = "Tab_DayGift",
    rootName = "Group_AsyncRoot",
    node = DailyGiftAwardNode
  },
  [NodeId.StartWork] = {
    tabName = "Tab_StartWork",
    rootName = "Group_AsyncRoot",
    node = StartWorkBenefitsNode
  },
  [NodeId.InviteAward] = {
    tabName = "Tab_InviteFriend",
    rootName = "Group_AsyncRoot",
    node = InviteAwardNode
  },
  [NodeId.EfunBindPhoneAward] = {
    tabName = "Tab_PhoneAttached",
    rootName = "Group_AsyncRoot",
    node = EfunBindPhoneAwardNode
  },
  [NodeId.AllowPush] = {
    tabName = "Tab_TuiSongPrize",
    rootName = "Group_AsyncRoot",
    node = AllowPushNode
  },
  [NodeId.BackExp] = {
    tabName = "Tab_BackExp",
    rootName = "Group_AsyncRoot",
    node = BackExpNode
  },
  [NodeId.StongerFund] = {
    tabName = "Tab_StrongerFund",
    rootName = "Group_GrowFund",
    node = StrongerFundNode
  },
  [NodeId.FeatureVote] = {
    tabName = "Tab_PreGame",
    rootName = "Group_AsyncRoot",
    node = FeatureVoteNode,
    dynamicName = function()
      return FeatureVoteNode.GetCurActivityName()
    end
  },
  [NodeId.WechatInviteAward] = {
    tabName = "Tab_WeChatInvite",
    rootName = "Group_AsyncRoot",
    node = WechatInviteAwardNode
  },
  [NodeId.ExchangeYuanBao] = {
    tabName = "Tab_RiverGod",
    rootName = "Group_AsyncRoot",
    node = ExchangeYuanBaoNode
  },
  [NodeId.MondayFree] = {
    tabName = "Tab_HappyMonday",
    rootName = "Group_AsyncRoot",
    node = MondayFreeNode
  }
}
local instance
def.static("=>", AwardPanel).Instance = function()
  if instance == nil then
    instance = AwardPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  self.m_TrigGC = true
  self.tabNameMapNodeId = {}
  for nodeId, v in pairs(NodeDefines) do
    self.tabNameMapNodeId[v.tabName] = nodeId
  end
end
def.method().ShowPanel = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.m_panel and not self.m_panel.isnil then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_AWARD_PANEL, 1)
  self:SetModal(true)
end
def.method("number").ShowPanelEx = function(self, nodeId)
  if _G.CheckCrossServerAndToast() then
    return
  end
  self.isSpecNode = true
  self.curNode = nodeId
  self:ShowPanel()
end
def.method("string", "=>", "number").GetNodeIdByTabName = function(self, tabName)
  return self.tabNameMapNodeId[tabName] or 0
end
def.method("number", "=>", "boolean").CheckNodeAvaliable = function(self, nodeId)
  local nodeInfo = NodeDefines[nodeId]
  if nodeInfo then
    local tempObject = nodeInfo.node()
    return tempObject:IsOpen()
  else
    return false
  end
end
def.override().OnCreate = function(self)
  self:InitUI()
  self.nodes = {}
  for nodeId, v in pairs(NodeDefines) do
    local nodeRoot = self.uiObjs.Img_Bg0:FindDirect(v.rootName)
    if nodeRoot then
      nodeRoot:SetActive(false)
    end
    self.nodes[nodeId] = v.node()
    self.nodes[nodeId]:Init(self, nodeRoot)
    self.nodes[nodeId].nodeId = nodeId
  end
  GrowFundMgr.Instance():updateFillInfo()
  self:ArrangeTabPos()
  for i, node in ipairs(self.showedNodeList) do
    node:UpdateNotifyState()
  end
  self:SelectProperNode()
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACCUMULATIVE_LOGIN_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.FIRST_RECHARGE_STATUS_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SIGN_BEFORE_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, AwardPanel.UpdateMonthCard)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.RECHARGE_LEIJI_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.NEw_SERVER_AWARD_CLOSE, AwardPanel.OnNewServerAwardClose)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_MESSAGE_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.ALLOWPUSH_RED_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_TAB_NOTIFY_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NODE_OPEN_CHANGE, AwardPanel.OnAwardNodeOpenChange)
  Event.RegisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
end
def.override("boolean").OnShow = function(self, isShow)
  if not isShow then
    if self.m_panel then
      self:OnHide()
    end
    return
  end
  if GameUtil.IsEvaluation() then
    do
      local uiGrid = self.m_panel:FindDirect("Img_Bg0/Group_Left/Scroll View/Grid"):GetComponent("UIGrid")
      if uiGrid then
        GameUtil.AddGlobalLateTimer(0, true, function()
          if uiGrid and self.m_panel and false == self.m_panel.isnil then
            uiGrid:Reposition()
          end
        end)
      end
    end
  end
  self:SwitchToNode(self.curNode)
end
def.method().OnHide = function(self)
  if self.curNode ~= AwardPanel.NodeId.None then
    self.nodes[self.curNode]:Hide()
  end
end
def.override().OnDestroy = function(self)
  if self.nodes == nil then
    return
  end
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_SIGN_IN_STATE_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACCUMULATIVE_LOGIN_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.FIRST_RECHARGE_STATUS_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.SIGN_BEFORE_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_MONTH_CARD, AwardPanel.UpdateMonthCard)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.ACHIEVEMENT_GOAL_INFO_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.ACHIEVEMENT, gmodule.notifyId.Achievement.NEw_SERVER_AWARD_CLOSE, AwardPanel.OnNewServerAwardClose)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_AWARD_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.GET_GIFT_ACTIVITY_AWARD_SUCCESS, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.CUSTOM_ACTIVITY, gmodule.notifyId.CustomActivity.CUSTOM_ACTIVITY_OPEN_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Active_Changed, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.BACK_EXP_INFO_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.DAILY_GIFT_FREE_AWARD_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_TAB_NOTIFY_UPDATE, AwardPanel.OnTabNotifyMessageUpdate)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.AWARD_NODE_OPEN_CHANGE, AwardPanel.OnAwardNodeOpenChange)
  Event.UnregisterEvent(ModuleId.AWARD, gmodule.notifyId.Award.MONDAY_FREE_INFO_CHANGE, AwardPanel.OnTabNotifyMessageUpdate)
  if self.curNode ~= AwardPanel.NodeId.None then
    self.nodes[self.curNode]:Hide()
  end
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
  end
  self:Clear()
  require("Main.Common.EnterWorldAlertMgr").Instance():Next()
  local ECGame = require("Main.ECGame")
  local shortcutMenuKey = ECGame.Instance():GetShortcutMenuKey()
  if shortcutMenuKey == _G.ShortcutMenuKeys.jiangli then
    ECGame.Instance():ClearShortcutMenuKey()
  end
end
def.method("userdata").onClickObj = function(self, obj)
  local id = obj.name
  if self:onClick(id) then
  else
    self.nodes[self.curNode]:onClickObj(obj)
  end
end
def.method("string", "=>", "boolean").onClick = function(self, id)
  local rs = true
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  else
    local nodeId = self:GetTabNodeId(id)
    if nodeId ~= NodeId.None then
      ECMSDK.SendTLogToServer(_G.TLOGTYPE.REWARD, {
        nodeId,
        id:sub(5, -1)
      })
      self:SwitchToNode(nodeId)
    else
      rs = false
    end
  end
  return rs
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.uiObjs.Group_Left = self.uiObjs.Img_Bg0:FindDirect("Group_Left")
  self.uiObjs.ScrollView = self.uiObjs.Group_Left:FindDirect("Scroll View")
  self.uiObjs.Grid = self.uiObjs.ScrollView:FindDirect("Grid")
  self.uiObjs.Group_AsyncRoot = self.uiObjs.Img_Bg0:FindDirect("Group_AsyncRoot")
  if self.uiObjs.Group_AsyncRoot == nil then
    self.uiObjs.Group_AsyncRoot = GameObject.GameObject("Group_AsyncRoot")
    self.uiObjs.Group_AsyncRoot.transform.parent = self.uiObjs.Img_Bg0.transform
    self.uiObjs.Group_AsyncRoot.transform.localScale = Vector.Vector3.one
  end
  local initnode = NodeId.DailySignIn
  if FresherSignInMgr.Instance():IsOpen() == true then
    initnode = NodeId.FresherSignIn
    self.curNode = NodeId.FresherSignIn
  end
  self.tabToggles = {}
  local uiGrid = self.uiObjs.Grid:GetComponent("UIGrid")
  local childCount = self.uiObjs.Grid.childCount
  for i = 0, childCount - 1 do
    local child = self.uiObjs.Grid:GetChild(i)
    local nodeId = self.tabNameMapNodeId[child.name]
    if nodeId then
      self.tabToggles[nodeId] = child:GetComponent("UIToggle")
      local NodeDef = NodeDefines[nodeId]
      if NodeDef and NodeDef.dynamicName then
        local tabName = NodeDef.dynamicName()
        if tabName and tabName ~= "" then
          local Label_Tab = child:FindDirect("Label_Tab")
          Label_Tab:GetComponent("UILabel"):set_text(tabName)
        end
      end
    else
      child:SetActive(false)
      warn(string.format("%s is not handle, hide it.", child.name))
    end
  end
  for k, v in pairs(self.tabToggles) do
    v:set_startsActive(false)
  end
end
def.method("string", "=>", "number").GetTabNodeId = function(self, tabName)
  for nodeId, v in pairs(NodeDefines) do
    if v.tabName == tabName then
      return nodeId
    end
  end
  return NodeId.None
end
def.method("number").SwitchToNode = function(self, node)
  if self.curNode ~= AwardPanel.NodeId.None and self.curNode ~= node then
    self.nodes[self.curNode]:Hide()
  end
  self.curNode = node
  self.tabToggles[self.curNode]:set_value(true)
  warn("SwitchToNode", node, os.clock())
  self.nodes[self.curNode]:Show()
end
def.method("number", "boolean").SetTabNotify = function(self, nodeId, state)
  if self.tabToggles[nodeId] == nil then
    return
  end
  local tab = self.tabToggles[nodeId].gameObject
  local Img_Red = tab:FindDirect("Img_Red")
  if Img_Red then
    Img_Red:SetActive(state)
  end
end
def.method().ArrangeTabPos = function(self)
  local unlockedNodeList = {}
  for nodeId, node in pairs(self.nodes) do
    if node:IsOpen() then
      table.insert(unlockedNodeList, node)
    elseif self.tabToggles[nodeId] then
      self.tabToggles[nodeId]:set_value(false)
      self.tabToggles[nodeId].gameObject:SetActive(false)
    end
  end
  self.uiObjs.Grid:GetComponent("UIGrid"):Reposition()
  self.showedNodeList = unlockedNodeList
end
def.method().SelectProperNode = function(self)
  local isLastNodeExist = false
  for i, node in ipairs(self.showedNodeList) do
    if node.nodeId == self.curNode then
      isLastNodeExist = true
      if self.isSpecNode then
        break
      end
    end
    if not self.isSpecNode and node:IsHaveNotifyMessage() then
      self.curNode = node.nodeId
      isLastNodeExist = true
      break
    end
  end
  if not isLastNodeExist and self.showedNodeList[1] then
    self.curNode = self.showedNodeList[1].nodeId
  end
end
def.static("table", "table").OnTabNotifyMessageUpdate = function(p1, p2)
  local self = instance
  local nodeId = p1 and p1[1]
  if nodeId then
    local node = self.nodes[nodeId]
    if node then
      node:UpdateNotifyState()
    end
  else
    for nodeId, node in pairs(self.nodes) do
      node:UpdateNotifyState()
    end
  end
end
def.static("table", "table").OnNewServerAwardClose = function(p1, p2)
  if instance then
    do
      local NewServerAwardMgr = require("Main.Award.mgr.NewServerAwardMgr")
      local newServerAwardMgr = NewServerAwardMgr.Instance()
      instance.timerId = GameUtil.AddGlobalTimer(20, true, function()
        if instance.m_panel == nil or instance.m_panel.isnil then
          return
        end
        instance:ArrangeTabPos()
        if not newServerAwardMgr:isOpenNewServerActivity() then
          if instance.curNode == NodeId.NewServerAward then
            instance:SwitchToNode(NodeId.DailySignIn)
          end
        elseif instance.curNode == NodeId.NewServerAward and instance.nodes[NodeId.NewServerAward] then
          instance.nodes[NodeId.NewServerAward]:setTabInfo()
        end
      end)
    end
  end
end
def.static("table", "table").OnAwardNodeOpenChange = function(p1, p2)
  local nodeId = p1.nodeId
  if nodeId == nil then
    return
  end
  if NodeDefines[nodeId] == nil then
    return
  end
  if instance then
    local nodeAvailable = instance:CheckNodeAvaliable(nodeId)
    if instance.tabToggles[nodeId] ~= nil then
      instance.tabToggles[nodeId].gameObject:SetActive(nodeAvailable)
    end
    instance:ArrangeTabPos()
    if instance.curNode == nodeId then
      if not nodeAvailable then
        instance:SwitchToNode(NodeId.DailySignIn)
      else
        instance:SwitchToNode(nodeId)
      end
    end
  end
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.nodes = nil
  self.showedNodeList = nil
  self.tabPos = nil
  self.isSpecNode = false
end
def.method().Reset = function(self)
  self.curNode = NodeId.DailySignIn
end
def.method("number").UpdateTabName = function(self, nodeId)
  if self.m_panel and self.uiObjs and self.uiObjs.Grid then
    local NodeDef = NodeDefines[nodeId]
    if NodeDef then
      local Tab = self.uiObjs.Grid:FindDirect(NodeDef.tabName)
      if Tab and NodeDef.dynamicName then
        local tabName = NodeDef.dynamicName()
        if tabName and tabName ~= "" then
          local Label_Tab = Tab:FindDirect("Label_Tab")
          Label_Tab:GetComponent("UILabel"):set_text(tabName)
        end
      end
    end
  end
end
def.static("table", "table").UpdateMonthCard = function()
  AwardPanel.OnTabNotifyMessageUpdate(nil, nil)
  if instance and instance.m_panel then
    instance:UpdateTabName(NodeId.MonthCard)
  end
end
return AwardPanel.Commit()
