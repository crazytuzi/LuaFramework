local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BackToGamePanel = Lplus.Extend(ECPanelBase, "BackToGamePanel")
local SignNode = require("Main.BackToGame.ui.SignNode")
local ActivityNode = require("Main.BackToGame.ui.ActivityNode")
local ExpNode = require("Main.BackToGame.ui.ExpNode")
local BackHomeNode = require("Main.BackToGame.ui.BackHomeNode")
local GoodsNode = require("Main.BackToGame.ui.GoodsNode")
local CatNode = require("Main.BackToGame.ui.CatNode")
local BTGDailySign = require("Main.BackToGame.mgr.BTGDailySign")
local BTGExp = require("Main.BackToGame.mgr.BTGExp")
local BTGBackHome = require("Main.BackToGame.mgr.BTGBackHome")
local BTGJiFen = require("Main.BackToGame.mgr.BTGJiFen")
local BTGLimitSell = require("Main.BackToGame.mgr.BTGLimitSell")
local BTGTask = require("Main.BackToGame.mgr.BTGTask")
local BTGCat = require("Main.BackToGame.mgr.BTGCat")
local BackToGameModule = Lplus.ForwardDeclare("BackToGameModule")
local BackToGameUtils = require("Main.BackToGame.BackToGameUtils")
local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local def = BackToGamePanel.define
local instance
def.static("=>", BackToGamePanel).Instance = function()
  if instance == nil then
    instance = BackToGamePanel()
  end
  return instance
end
def.const("table").NodeId = {
  Sign = 1,
  Activity = 2,
  Exp = 3,
  Award = 4,
  Goods = 5,
  Cat = 6
}
def.const("table").Tabs = {
  [1] = "Tab_QiaoDao",
  ["Tab_QiaoDao"] = 1,
  [2] = "Tab_Activity",
  ["Tab_Activity"] = 2,
  [3] = "Tab_LeiDeng",
  ["Tab_LeiDeng"] = 3,
  [4] = "Tab_Gift",
  ["Tab_Gift"] = 4,
  [5] = "Tab_OnSale",
  ["Tab_OnSale"] = 5,
  [6] = "Tab_Cat",
  ["Tab_Cat"] = 6
}
def.const("table").TabsRed = {
  Tab_QiaoDao = {BTGDailySign},
  Tab_Activity = {BTGJiFen},
  Tab_LeiDeng = {BTGExp, BTGTask},
  Tab_Gift = {BTGBackHome},
  Tab_OnSale = {BTGLimitSell},
  Tab_Cat = {BTGCat}
}
def.field("table").nodes = nil
def.field("number").curNode = 1
def.static("number").ShowBackToGamePanel = function(nodeId)
  local dlg = BackToGamePanel.Instance()
  if not dlg:IsShow() then
    if nodeId > 0 then
      dlg.curNode = nodeId
    end
    dlg:CreatePanel(RESPATH.PREFAB_ComeBack, 1)
    dlg:SetModal(true)
  end
end
def.static().HideBackToGamePanel = function()
  local dlg = BackToGamePanel.Instance()
  dlg:DestroyPanel()
end
def.override().OnCreate = function(self)
  Event.RegisterEventWithContext(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, BackToGamePanel.OnNewDay, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.DailySignUpdate, BackToGamePanel.OnDailySignUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, BackToGamePanel.OnActivityUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ExpUpdate, BackToGamePanel.OnExpUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.TaskUpdate, BackToGamePanel.OnTaskUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.BackHomeUpdate, BackToGamePanel.OnBackHomeUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.LimitSellUpdate, BackToGamePanel.OnLimitSellUpdate, self)
  Event.RegisterEventWithContext(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.CatTokenChange, BackToGamePanel.OnCatTokenChange, self)
  Event.RegisterEventWithContext(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BackToGamePanel.OnFunctionOpenChange, self)
  local nodeGroup = self.m_panel:FindDirect("Img_Bg0")
  self.nodes = {}
  local signNode = nodeGroup:FindDirect("Group_QianDao")
  signNode:SetActive(false)
  self.nodes[BackToGamePanel.NodeId.Sign] = SignNode()
  self.nodes[BackToGamePanel.NodeId.Sign]:Init(self, signNode)
  local actNode = nodeGroup:FindDirect("Group_Activity")
  actNode:SetActive(false)
  self.nodes[BackToGamePanel.NodeId.Activity] = ActivityNode()
  self.nodes[BackToGamePanel.NodeId.Activity]:Init(self, actNode)
  local expNode = nodeGroup:FindDirect("Group_LeiDeng")
  expNode:SetActive(false)
  self.nodes[BackToGamePanel.NodeId.Exp] = ExpNode()
  self.nodes[BackToGamePanel.NodeId.Exp]:Init(self, expNode)
  local backHomeNode = nodeGroup:FindDirect("Group_Gift")
  backHomeNode:SetActive(false)
  self.nodes[BackToGamePanel.NodeId.Award] = BackHomeNode()
  self.nodes[BackToGamePanel.NodeId.Award]:Init(self, backHomeNode)
  local goodsNode = nodeGroup:FindDirect("Group_OnSale")
  goodsNode:SetActive(false)
  self.nodes[BackToGamePanel.NodeId.Goods] = GoodsNode()
  self.nodes[BackToGamePanel.NodeId.Goods]:Init(self, goodsNode)
  local catNode = nodeGroup:FindDirect("Group_Cat")
  catNode:SetActive(false)
  self.nodes[BackToGamePanel.NodeId.Cat] = CatNode()
  self.nodes[BackToGamePanel.NodeId.Cat]:Init(self, catNode)
  local selNode = self:AutoSelectTab()
  if selNode == 0 then
    self:DestroyPanel()
    return
  end
  self:UpdateTabOpen()
  self:UpdateCountDown()
  self:UpdateEndTime()
  self:SwitchNode(selNode)
  self:UpdateRed()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.SERVER, gmodule.notifyId.Server.NEW_DAY, BackToGamePanel.OnNewDay)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.DailySignUpdate, BackToGamePanel.OnDailySignUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ActivityUpdate, BackToGamePanel.OnActivityUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.ExpUpdate, BackToGamePanel.OnExpUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.TaskUpdate, BackToGamePanel.OnTaskUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.BackHomeUpdate, BackToGamePanel.OnBackHomeUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.LimitSellUpdate, BackToGamePanel.OnLimitSellUpdate)
  Event.UnregisterEvent(ModuleId.BACK_TO_GAME, gmodule.notifyId.BackToGame.CatTokenChange, BackToGamePanel.OnCatTokenChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, BackToGamePanel.OnFunctionOpenChange)
  self.nodes[self.curNode]:Hide()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    self.nodes[self.curNode]:Show()
  else
    self.nodes[self.curNode]:Hide()
  end
end
def.method("table").OnFunctionOpenChange = function(self, param)
  local f = param.feature
  if f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_SIGN or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_POINT or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_EXP or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_AWARD or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_BUY_GIFT or f == ModuleFunSwitchInfo.TYPE_BACK_GAME_ACTIVITY_RECHARGE then
    local selNode = self:AutoSelectTab()
    if selNode == 0 then
      self:DestroyPanel()
      return
    end
    self:UpdateTabOpen()
    self:SwitchNode(selNode)
  end
end
def.method("table").OnNewDay = function(self, param)
  self:UpdateCountDown()
end
def.method("table").OnDailySignUpdate = function(self, param)
  self:UpdateTabRed("Tab_QiaoDao")
end
def.method("table").OnActivityUpdate = function(self, param)
  self:UpdateTabRed("Tab_Activity")
end
def.method("table").OnExpUpdate = function(self, param)
  self:UpdateTabRed("Tab_LeiDeng")
end
def.method("table").OnTaskUpdate = function(self, param)
  self:UpdateTabRed("Tab_LeiDeng")
end
def.method("table").OnBackHomeUpdate = function(self, param)
  self:UpdateTabRed("Tab_Gift")
end
def.method("table").OnLimitSellUpdate = function(self, param)
  self:UpdateTabRed("Tab_OnSale")
end
def.method("table").OnCatTokenChange = function(self, param)
  self:UpdateTabRed("Tab_Cat")
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Tab_QiaoDao" then
    self:SwitchNode(BackToGamePanel.NodeId.Sign)
  elseif id == "Tab_Activity" then
    self:SwitchNode(BackToGamePanel.NodeId.Activity)
  elseif id == "Tab_LeiDeng" then
    self:SwitchNode(BackToGamePanel.NodeId.Exp)
  elseif id == "Tab_Gift" then
    self:SwitchNode(BackToGamePanel.NodeId.Award)
  elseif id == "Tab_OnSale" then
    self:SwitchNode(BackToGamePanel.NodeId.Goods)
  elseif id == "Tab_Cat" then
    self:SwitchNode(BackToGamePanel.NodeId.Cat)
  else
    self.nodes[self.curNode]:onClick(id)
  end
end
def.method("number").SwitchNode = function(self, nodeId)
  local oldNodeId = self.curNode
  for k, v in pairs(self.nodes) do
    if nodeId == k then
      self.curNode = nodeId
      v:Show()
    elseif k == oldNodeId then
      v:Hide()
    end
  end
  self:UpdateTab()
end
def.method().UpdateCountDown = function(self)
  local startms = BackToGameModule.Instance():GetJoinTime()
  local startDay = BackToGameUtils.MsToDay(startms)
  local curSec = GetServerTime()
  local curDay = BackToGameUtils.SecToDay(curSec)
  local cfg = BackToGameUtils.GetBackGameActivity(BackToGameModule.Instance():GetCurActivity())
  local lastDay = cfg.backGameCycleDay
  local leftDay = lastDay - (curDay - startDay)
  local dayLbl = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_Label/Label_Time")
  if leftDay > 1 then
    dayLbl:GetComponent("UILabel"):set_text(tostring(leftDay) .. textRes.Common.Day)
  else
    dayLbl:GetComponent("UILabel"):set_text(textRes.BackToGame[2])
  end
end
def.method().UpdateEndTime = function(self)
  local activityId = BackToGameModule.Instance():GetCurActivity()
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local actCfg = ActivityInterface.GetActivityCfgById(activityId)
  local lbl = self.m_panel:FindDirect("Img_Bg0/Group_Time/Label_Time")
  if actCfg then
    lbl:GetComponent("UILabel"):set_text(actCfg.timeDes)
  else
    lbl:GetComponent("UILabel"):set_text("")
  end
end
def.method().UpdateTabOpen = function(self)
  local tabGroup = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/ScrollView/Group_Item")
  for k, v in ipairs(BackToGamePanel.Tabs) do
    local node = self.nodes[k]
    if node then
      local tab = tabGroup:FindDirect(v)
      tab:SetActive(node:IsOpen())
    else
      local tab = tabGroup:FindDirect(v)
      tab:SetActive(false)
    end
  end
  tabGroup:GetComponent("UIGrid"):Reposition()
end
def.method("=>", "number").AutoSelectTab = function(self)
  local curNode = self.nodes[self.curNode]
  if curNode:IsOpen() then
    return self.curNode
  else
    for k, v in ipairs(BackToGamePanel.Tabs) do
      local node = self.nodes[k]
      if node:IsOpen() then
        return k
      end
    end
    return 0
  end
end
def.method().UpdateTab = function(self)
  local tabGroup = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/ScrollView/Group_Item")
  for k, v in ipairs(BackToGamePanel.Tabs) do
    if k == self.curNode then
      local tab = tabGroup:FindDirect(v)
      tab:GetComponent("UIToggle").value = true
    else
      local tab = tabGroup:FindDirect(v)
      tab:GetComponent("UIToggle").value = false
    end
  end
end
def.method("userdata", "boolean").SetTabRed = function(self, tab, isRed)
  local red = tab:FindDirect("Img_Red")
  if red then
    red:SetActive(isRed)
  end
end
def.method().UpdateRed = function(self)
  self:UpdateTabRed("Tab_QiaoDao")
  self:UpdateTabRed("Tab_Activity")
  self:UpdateTabRed("Tab_LeiDeng")
  self:UpdateTabRed("Tab_Gift")
  self:UpdateTabRed("Tab_OnSale")
  self:UpdateTabRed("Tab_Cat")
end
def.method("string").UpdateTabRed = function(self, tabName)
  local tab = self.m_panel:FindDirect("Img_Bg0/Group_Left/Group_List/ScrollView/Group_Item/" .. tabName)
  if tab then
    if BackToGamePanel.TabsRed[tabName] then
      local subModules = BackToGamePanel.TabsRed[tabName]
      for k, v in ipairs(subModules) do
        if v.Instance():IsRed() then
          self:SetTabRed(tab, true)
          return
        end
      end
      self:SetTabRed(tab, false)
    else
      self:SetTabRed(tab, false)
    end
  end
end
BackToGamePanel.Commit()
return BackToGamePanel
