local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local GUIUtils = require("GUI.GUIUtils")
local CommercePitchPanel = Lplus.Extend(ECPanelBase, "CommercePitchPanel")
local PitchPanelNode = require("Main.CommerceAndPitch.ui.PitchPanelNode")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local TaskInterface = require("Main.task.TaskInterface")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local CommercePitchModule = Lplus.ForwardDeclare("CommercePitchModule")
local ItemModule = require("Main.Item.ItemModule")
local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
local AuctionNode = require("Main.Auction.ui.AuctionNode")
local def = CommercePitchPanel.define
local instance
def.const("table").NodeId = {
  PITCH = 2,
  TradingArcade = 3,
  Auction = 11
}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 2
def.const("table").StateConst = {
  Commerce = 1,
  Pitch = 2,
  TradingArcade = 3,
  Auction = 11
}
def.field("table").requirementsCondTbl = nil
def.field("number").requirementsCondCount = 0
def.field("table").requirementsItemTbl = nil
def.field("number").requirementsItemCount = 0
def.field("table").requirementsGroup = nil
def.field("table").requirementsCondItemId = nil
def.field("table").requirementsCommerceGroup = nil
def.field("table").requirementsCommerceCondItemId = nil
def.field("table").curRequirementCondItem = nil
def.field("table").curGroupReqiurements = nil
def.field("boolean").bWantToOpen = false
def.field("boolean").bOpenDefault = true
def.field("number").group = 0
def.field("number").groupS = 0
def.field("number").smallGroup = 0
def.field("number").bigGroup = 0
def.field("number").shiftTimes = 0
def.field("number").stateByTask = 0
def.static("=>", CommercePitchPanel).Instance = function()
  if nil == instance then
    instance = CommercePitchPanel()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.static("number").ShowCommercePitchPanel = function(st)
  local panel = CommercePitchPanel.Instance()
  panel.state = st
  panel:InitRequirements()
  if 0 == panel.requirementsCondCount and false == panel.bWantToOpen then
    panel:SetModal(true)
    panel:CreatePanel(RESPATH.PREFAB_COMMERCE_PITCH_PANEL, 1)
  end
end
def.static("number").ShowNodeByState = function(state)
  local self = CommercePitchPanel.Instance()
  if self:IsShow() then
    self.state = state
    if CommercePitchPanel.StateConst.Auction == self.state and not require("Main.Auction.AuctionModule").Instance():IsOpen(false) then
      self.state = CommercePitchPanel.StateConst.Pitch
    end
    if CommercePitchPanel.StateConst.Pitch == self.state then
      self:SwitchTo(CommercePitchPanel.NodeId.PITCH)
      local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Tan"):GetComponent("UIToggle")
      toggle:set_value(true)
    elseif CommercePitchPanel.StateConst.TradingArcade == self.state then
      if CommercePitchModule.Instance().afterShowCallback == nil then
        self:SwitchTo(CommercePitchPanel.NodeId.TradingArcade)
      end
      local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_BlackShop"):GetComponent("UIToggle")
      toggle:set_value(true)
    elseif CommercePitchPanel.StateConst.Auction == self.state then
      self:SwitchTo(CommercePitchPanel.NodeId.Auction)
      local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_AuctionHouse"):GetComponent("UIToggle")
      toggle:set_value(true)
    end
  else
    CommercePitchPanel.ShowCommercePitchPanel(state)
  end
end
def.override().OnCreate = function(self)
  self:CheckToSwitchState()
  self.nodes = {}
  local pitchPanelNode = self.m_panel:FindDirect("Img_Bg0/Group_Tan")
  self.nodes[CommercePitchPanel.NodeId.PITCH] = PitchPanelNode()
  self.nodes[CommercePitchPanel.NodeId.PITCH]:Init(self, pitchPanelNode)
  self.nodes[CommercePitchPanel.NodeId.PITCH].bOpenDefault = self.bOpenDefault
  local tradingArcadeNode = self.m_panel:FindDirect("Img_Bg0/Group_BlackShop")
  self.nodes[CommercePitchPanel.NodeId.TradingArcade] = TradingArcadeNode.Instance()
  self.nodes[CommercePitchPanel.NodeId.TradingArcade]:Init(self, tradingArcadeNode)
  self.nodes[CommercePitchPanel.NodeId.TradingArcade]:UpdateTabNotify()
  local auctionNode = self.m_panel:FindDirect("Img_Bg0/Group_AuctionHouse")
  self.nodes[CommercePitchPanel.NodeId.Auction] = AuctionNode.Instance()
  self.nodes[CommercePitchPanel.NodeId.Auction]:Init(self, auctionNode)
  self.nodes[CommercePitchPanel.NodeId.Auction]:UpdateTabNotify()
  if CommercePitchPanel.StateConst.Auction == self.state and not require("Main.Auction.AuctionModule").Instance():IsOpen(false) then
    self.state = CommercePitchPanel.StateConst.Pitch
  end
  if CommercePitchPanel.StateConst.Pitch == self.state then
    self:SwitchTo(CommercePitchPanel.NodeId.PITCH)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Tan"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif CommercePitchPanel.StateConst.TradingArcade == self.state then
    if CommercePitchModule.Instance().afterShowCallback == nil then
      self:SwitchTo(CommercePitchPanel.NodeId.TradingArcade)
    end
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_BlackShop"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif CommercePitchPanel.StateConst.Auction == self.state then
    self:SwitchTo(CommercePitchPanel.NodeId.Auction)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_AuctionHouse"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
  local Img_Red = self.m_panel:FindDirect("Img_Bg0/Tab_Tan"):FindDirect("Img_Red")
  local num = require("Main.CommerceAndPitch.data.PitchData").Instance():GetChangedSelledItemNum()
  if num > 0 then
    Img_Red:SetActive(true)
  else
    Img_Red:SetActive(false)
  end
  if CommercePitchModule.Instance().afterShowCallback then
    CommercePitchModule.Instance().afterShowCallback()
    CommercePitchModule.Instance().afterShowCallback = nil
  end
  Event.RegisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, CommercePitchPanel.OnSelledItemChanged)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommercePitchPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, CommercePitchPanel.OnTradingSellNotifyUpdate)
  Event.RegisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_REDDOT_CHANGE, CommercePitchPanel.OnAuctionNotifyUpdate)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CommercePitchPanel.OnFunctionOpenChange)
end
def.method().CheckToSwitchState = function(self)
  if self.bOpenDefault then
    return
  end
  local num = require("Main.CommerceAndPitch.data.PitchData").Instance():GetChangedSelledItemNum()
  if num > 0 then
    self.state = CommercePitchPanel.StateConst.Pitch
  end
end
def.static("table", "table").OnSelledItemChanged = function(params, context)
  local Img_Red = CommercePitchPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_Tan"):FindDirect("Img_Red")
  local num = require("Main.CommerceAndPitch.data.PitchData").Instance():GetChangedSelledItemNum()
  if num > 0 then
    Img_Red:SetActive(true)
  else
    Img_Red:SetActive(false)
  end
  local pitchPanelNode = CommercePitchPanel.Instance().m_panel:FindDirect("Img_Bg0/Group_Tan")
  local Img_Red2 = pitchPanelNode:FindDirect("Tab_Sell"):FindDirect("Img_Red")
  if num > 0 then
    Img_Red2:SetActive(true)
  else
    Img_Red2:SetActive(false)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  activityInterface:_refreshActivityRequirements()
end
def.static("table", "table").OnTradingSellNotifyUpdate = function(p1, p2)
  CommercePitchPanel.Instance().nodes[CommercePitchPanel.NodeId.TradingArcade]:UpdateTabNotify()
end
def.static("table", "table").OnAuctionNotifyUpdate = function(p1, p2)
  CommercePitchPanel.Instance().nodes[CommercePitchPanel.NodeId.Auction]:UpdateTabNotify()
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_AUCTION then
    CommercePitchPanel.Instance().nodes[CommercePitchPanel.NodeId.Auction]:UpdateTabNotify()
    if not _G.IsFeatureOpen(ModuleFunSwitchInfo.TYPE_AUCTION) and CommercePitchPanel.Instance().curNode == CommercePitchPanel.NodeId.Auction then
      CommercePitchPanel.Instance():SwitchTo(CommercePitchPanel.NodeId.PITCH)
      local toggle = CommercePitchPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_Tan"):GetComponent("UIToggle")
      toggle:set_value(true)
    end
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.COMMERCEANDPITCH, gmodule.notifyId.CommerceAndPitch.PITCH_CHANGED, CommercePitchPanel.OnSelledItemChanged)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, CommercePitchPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.TRADING_ARCADE, gmodule.notifyId.TradingArcade.TRADING_ARCADE_NOTIFY_UPDATE, CommercePitchPanel.OnTradingSellNotifyUpdate)
  Event.UnregisterEvent(ModuleId.AUCTION, gmodule.notifyId.Auction.AUCTION_REDDOT_CHANGE, CommercePitchPanel.OnAuctionNotifyUpdate)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, CommercePitchPanel.OnFunctionOpenChange)
  CommercePitchModule.Instance()._bIsByTask = false
  CommercePitchModule.Instance()._npcId = 0
  CommercePitchModule.Instance()._curRequirementByTask = nil
  CommercePitchModule.Instance().selectPitchItemId = 0
  CommercePitchModule.Instance().selectPitchItemIds = {}
  self.stateByTask = 0
  self.bOpenDefault = true
  require("Main.CommerceAndPitch.data.PitchData").Instance():SetAutoFreeRefresh(true)
  if self.curNode == CommercePitchPanel.NodeId.TradingArcade then
    self.nodes[CommercePitchPanel.NodeId.TradingArcade]:Hide()
  elseif self.curNode == CommercePitchPanel.NodeId.Auction then
    self.nodes[CommercePitchPanel.NodeId.Auction]:Hide()
  end
end
def.method().InitRequirements = function(self)
  self.group = 0
  self.groupS = 0
  self.smallGroup = 0
  self.bigGroup = 0
  self.stateByTask = 0
  local taskInterfaceInstance = TaskInterface.Instance()
  self.requirementsItemTbl = {}
  self.requirementsCondTbl = {}
  self.requirementsItemCount = 0
  self.requirementsCondCount = 0
  for taskId, graphIdRequiremnt in pairs(taskInterfaceInstance:GetTaskRequirements()) do
    for graphId, requiremnt in pairs(graphIdRequiremnt) do
      if false == CommercePitchUtils.IsItemId(requiremnt.requirementID) then
        if nil ~= self.requirementsCondTbl[requiremnt.requirementID] then
          self.requirementsCondTbl[requiremnt.requirementID].needNum = self.requirementsCondTbl[requiremnt.requirementID].needNum + requiremnt.needCount
        else
          self.requirementsCondCount = self.requirementsCondCount + 1
          self.requirementsCondTbl[requiremnt.requirementID] = {}
          self.requirementsCondTbl[requiremnt.requirementID].needNum = requiremnt.needCount
          self.requirementsCondTbl[requiremnt.requirementID].itemList = {}
        end
      elseif nil ~= self.requirementsItemTbl[requiremnt.requirementID] then
        self.requirementsItemTbl[requiremnt.requirementID] = self.requirementsItemTbl[requiremnt.requirementID] + requiremnt.needCount
      else
        self.requirementsItemCount = self.requirementsItemCount + 1
        self.requirementsItemTbl[requiremnt.requirementID] = requiremnt.needCount
      end
    end
  end
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  local activityAllRequirements = activityInterface:GetActivityAllRequirements()
  for requirementID, requiremnt in pairs(activityAllRequirements) do
    if false == CommercePitchUtils.IsItemId(requirementID) then
      if nil ~= self.requirementsCondTbl[requirementID] then
        self.requirementsCondTbl[requirementID].needNum = self.requirementsCondTbl[requirementID].needNum + requiremnt.needCount
      else
        self.requirementsCondCount = self.requirementsCondCount + 1
        self.requirementsCondTbl[requirementID] = {}
        self.requirementsCondTbl[requirementID].needNum = requiremnt.needCount
        self.requirementsCondTbl[requirementID].itemList = {}
      end
    elseif nil ~= self.requirementsItemTbl[requirementID] then
      self.requirementsItemTbl[requirementID] = self.requirementsItemTbl[requirementID] + requiremnt.needCount
    else
      self.requirementsItemCount = self.requirementsItemCount + 1
      self.requirementsItemTbl[requirementID] = requiremnt.needCount
    end
  end
  self.requirementsGroup = {}
  self.requirementsCondItemId = {}
  self.requirementsCommerceGroup = {}
  self.requirementsCommerceCondItemId = {}
  self.shiftTimes = 0
  self.bWantToOpen = false
  for k, v in pairs(self.requirementsItemTbl) do
    local group, smallGroup = CommercePitchUtils.ItemConditionIdToGroup(k)
    if 0 ~= group and 0 ~= smallGroup then
      self.requirementsGroup[group] = true
      self.requirementsGroup[group * 100 + smallGroup] = true
      self.group = group
      self.groupS = smallGroup
    else
      local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(k)
      if bigGroup ~= 0 then
        self.requirementsCommerceGroup[bigGroup] = true
        self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
        self.requirementsCommerceCondItemId[k] = true
        self.bigGroup = bigGroup
        self.smallGroup = smallGroup
      end
    end
  end
  if 0 < self.requirementsCondCount then
    self:RequireRequirements()
    self.bWantToOpen = true
  end
  self.curRequirementCondItem = {}
  local curRequire = CommercePitchModule.Instance():GetCurRequirementByTask()
  if curRequire ~= nil then
    for k, v in pairs(curRequire) do
      self.curRequirementCondItem[k] = {}
      self.curRequirementCondItem[k].needNum = v
      self.curRequirementCondItem[k].itemList = {}
      self.bWantToOpen = true
      self.shiftTimes = self.shiftTimes - 1
      if CommercePitchUtils.IsItemId(k) then
        self:FillConditionItemId(k, {k})
      else
        local p = require("netio.protocol.mzm.gsp.item.CSiftItemBySiftCfgReq").new(k)
        gmodule.network.sendProtocol(p)
      end
    end
  end
end
def.method().RequireRequirements = function(self)
  for k, v in pairs(self.requirementsCondTbl) do
    local p = require("netio.protocol.mzm.gsp.item.CSiftItemBySiftCfgReq").new(k)
    gmodule.network.sendProtocol(p)
    self.shiftTimes = self.shiftTimes - 1
  end
end
def.method("number", "table").FillConditionItemId = function(self, siftId, list)
  if self.bWantToOpen then
    local curRequire = CommercePitchModule.Instance():GetCurRequirementByTask()
    if nil ~= curRequire then
      for k, v in pairs(curRequire) do
        if siftId == k then
          local needNum = v
          self.curRequirementCondItem[k].itemList = {}
          for x, y in pairs(list) do
            table.insert(self.curRequirementCondItem[k].itemList, y)
          end
          local group, smallGroup = CommercePitchUtils.ItemConditionIdToGroup(k)
          if 0 ~= group and 0 ~= smallGroup then
            self.requirementsGroup[group] = true
            self.requirementsGroup[group * 100 + smallGroup] = true
            self.group = group
            self.groupS = smallGroup
            self.state = CommercePitchPanel.StateConst.Pitch
            self.stateByTask = CommercePitchPanel.StateConst.Pitch
            for m, n in pairs(self.curRequirementCondItem[k].itemList) do
              self.requirementsCondItemId[n] = true
            end
          else
            local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(k)
            if bigGroup ~= 0 then
            end
            for m, n in pairs(self.curRequirementCondItem[k].itemList) do
              local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(n)
              if 0 ~= group2 and 0 ~= smallGroup2 then
                self.requirementsGroup[group2] = true
                self.requirementsGroup[group2 * 100 + smallGroup2] = true
                self.group = group2
                self.groupS = smallGroup2
                self.requirementsCondItemId[n] = true
                self.state = CommercePitchPanel.StateConst.Pitch
                self.stateByTask = CommercePitchPanel.StateConst.Pitch
              else
                local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(n)
                if bigGroup ~= 0 then
                end
                local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(CommercePitchUtils.ItemIdToConditionId(n))
                if 0 ~= group2 and 0 ~= smallGroup2 then
                  self.requirementsGroup[group2] = true
                  self.requirementsGroup[group2 * 100 + smallGroup2] = true
                  self.group = group2
                  self.groupS = smallGroup2
                  self.requirementsCondItemId[n] = true
                  self.state = CommercePitchPanel.StateConst.Pitch
                  self.stateByTask = CommercePitchPanel.StateConst.Pitch
                end
              end
            end
          end
        end
      end
    end
    if nil ~= self.requirementsCondTbl[siftId] then
      local needNum = self.requirementsCondTbl[siftId].needNum
      self.requirementsCondTbl[siftId].itemList = {}
      for k, v in pairs(list) do
        table.insert(self.requirementsCondTbl[siftId].itemList, v)
      end
      local group, smallGroup = CommercePitchUtils.ItemConditionIdToGroup(siftId)
      if 0 ~= group and 0 ~= smallGroup then
        self.requirementsGroup[group] = true
        self.requirementsGroup[group * 100 + smallGroup] = true
        if self.group == 0 then
          self.group = group
          self.groupS = smallGroup
        end
        for m, n in pairs(self.requirementsCondTbl[siftId].itemList) do
          self.requirementsCondItemId[n] = true
        end
      else
        local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(siftId)
        if bigGroup ~= 0 then
          self.requirementsCommerceGroup[bigGroup] = true
          self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
          self.bigGroup = bigGroup
          self.smallGroup = smallGroup
          self.requirementsCommerceCondItemId[siftId] = true
        end
        for k, v in pairs(self.requirementsCondTbl[siftId].itemList) do
          local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(v)
          if 0 ~= group2 and 0 ~= smallGroup2 then
            self.requirementsGroup[group2] = true
            self.requirementsGroup[group2 * 100 + smallGroup2] = true
            if self.group == 0 then
              self.group = group2
              self.groupS = smallGroup2
            end
            self.requirementsCondItemId[v] = true
          else
            local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(CommercePitchUtils.ItemIdToConditionId(v))
            if 0 ~= group2 and 0 ~= smallGroup2 then
              self.requirementsGroup[group2] = true
              self.requirementsGroup[group2 * 100 + smallGroup2] = true
              if self.group == 0 then
                self.group = group2
                self.groupS = smallGroup2
              end
              self.requirementsCondItemId[v] = true
            else
              local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(v)
              if bigGroup ~= 0 then
                self.requirementsCommerceGroup[bigGroup] = true
                self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
                self.bigGroup = bigGroup
                self.smallGroup = smallGroup
                self.requirementsCommerceCondItemId[v] = true
              end
            end
          end
        end
      end
    end
    self.shiftTimes = self.shiftTimes + 1
    if self.shiftTimes == 0 then
      self:SetModal(true)
      self:CreatePanel(RESPATH.PREFAB_COMMERCE_PITCH_PANEL, 1)
      self.bWantToOpen = false
    end
  end
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
def.method().UpdateRequirementsCondTbl = function(self)
  self.requirementsCondItemId = {}
  self.requirementsGroup = {}
  self.requirementsCommerceGroup = {}
  self.requirementsCommerceCondItemId = {}
  for k, v in pairs(self.requirementsItemTbl) do
    local have = ItemModule.Instance():GetItemCountById(k)
    if v <= have then
      self.requirementsItemTbl[k] = nil
      table.remove(self.requirementsItemTbl, k)
      self.requirementsItemCount = self.requirementsItemCount - 1
    else
      local group, smallGroup = CommercePitchUtils.ItemConditionIdToGroup(k)
      if 0 ~= group and 0 ~= smallGroup then
        self.requirementsGroup[group] = true
        self.requirementsGroup[group * 100 + smallGroup] = true
        self.requirementsCondItemId[k] = true
      else
        local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(k)
        if bigGroup ~= 0 then
          self.requirementsCommerceGroup[bigGroup] = true
          self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
          self.requirementsCommerceCondItemId[k] = true
        end
      end
    end
  end
  for k, v in pairs(self.requirementsCondTbl) do
    local needNum = v.needNum
    local haveNum = 0
    for x, y in pairs(v.itemList) do
      haveNum = haveNum + ItemModule.Instance():GetItemCountById(y)
    end
    if needNum <= haveNum then
      self.requirementsCondTbl[k] = nil
      table.remove(self.requirementsCondTbl, k)
      self.requirementsCondCount = self.requirementsCondCount - 1
    else
      local group, smallGroup = CommercePitchUtils.ItemConditionIdToGroup(k)
      if 0 ~= group and 0 ~= smallGroup then
        self.requirementsGroup[group] = true
        self.requirementsGroup[group * 100 + smallGroup] = true
        for m, n in pairs(v.itemList) do
          self.requirementsCondItemId[n] = true
        end
      else
        local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(k)
        if bigGroup ~= 0 then
          self.requirementsCommerceGroup[bigGroup] = true
          self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
          self.requirementsCommerceCondItemId[k] = true
        end
        for m, n in pairs(self.requirementsCondTbl[k].itemList) do
          local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(n)
          if 0 ~= group2 and 0 ~= smallGroup2 then
            self.requirementsGroup[group2] = true
            self.requirementsGroup[group2 * 100 + smallGroup2] = true
            self.requirementsCondItemId[n] = true
          else
            local group2, smallGroup2 = CommercePitchUtils.ItemConditionIdToGroup(CommercePitchUtils.ItemIdToConditionId(n))
            if 0 ~= group2 and 0 ~= smallGroup2 then
              self.requirementsGroup[group2] = true
              self.requirementsGroup[group2 * 100 + smallGroup2] = true
              self.requirementsCondItemId[n] = true
            else
              local bigGroup, smallGroup = CommerceData.Instance():GetGroupInfoByItemId(n)
              if bigGroup ~= 0 then
                self.requirementsCommerceGroup[bigGroup] = true
                self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
                self.requirementsCommerceCondItemId[n] = true
              end
            end
          end
        end
      end
    end
  end
  self.nodes[self.curNode]:UpdateRequirementsCondTbl()
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if "Btn_Close" == id then
    Event.DispatchEvent(ModuleId.DYEING, gmodule.notifyId.Dyeing.CLOSET_PANEL_CLOSE, nil)
    self:DestroyPanel()
  elseif "Modal" == id then
    self:DestroyPanel()
  elseif "Tab_Commerce" == id then
    self:SwitchTo(CommercePitchPanel.NodeId.COMMERCE)
    self.state = CommercePitchPanel.StateConst.Commerce
  elseif "Tab_Tan" == id then
    self:SwitchTo(CommercePitchPanel.NodeId.PITCH)
    self.state = CommercePitchPanel.StateConst.Pitch
  elseif "Tab_BlackShop" == id then
    if TradingArcadeUtils.CheckOpen() == false then
      local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Tan"):GetComponent("UIToggle")
      toggle:set_value(true)
      return
    end
    self:SwitchTo(CommercePitchPanel.NodeId.TradingArcade)
    self.state = CommercePitchPanel.StateConst.TradingArcade
  elseif "Tab_AuctionHouse" == id then
    if require("Main.Auction.AuctionModule").Instance():ReachMinLevel(true) then
      self:SwitchTo(CommercePitchPanel.NodeId.Auction)
      self.state = CommercePitchPanel.StateConst.Auction
      return
    elseif self.curNode == CommercePitchPanel.NodeId.TradingArcade then
      local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_BlackShop"):GetComponent("UIToggle")
      toggle:set_value(true)
    else
      local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Tan"):GetComponent("UIToggle")
      toggle:set_value(true)
    end
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.method().TimeToRefeshPitch = function(self)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:UpdateRefeshLabel()
  end
end
def.method().UpdatePitchTimeLabel = function(self)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:UpdateTimeLabel()
  end
end
def.static().RequireRefeshPitch = function()
  PitchPanelNode.RequireRefeshPitch()
end
def.method("table").OnBuyItemRes = function(self, p)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:OnBuyItemRes(p)
  end
end
def.method().UpdatePitchSellList = function(self)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:UpdatePitchSellList()
  end
end
def.method("number", "table").ShowPitchItemTips = function(self, shoppingId, itemInfo)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:ShowPitchItemTips(shoppingId, itemInfo)
  end
end
def.method("number").OnCommonResultRes = function(self, res)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:OnCommonResultRes(res)
  end
end
def.method("userdata", "number", "number", "number").SucceedBuyCommerceItem = function(self, costGold, canBuyNum, itemId, itemCount)
  if CommercePitchPanel.NodeId.COMMERCE == self.curNode then
    self.nodes[self.curNode]:SucceedBuyItem(costGold, canBuyNum, itemId, itemCount)
  end
end
def.method("number").CommerceCommonResultRes = function(self, res)
  if CommercePitchPanel.NodeId.COMMERCE == self.curNode then
    self.nodes[self.curNode]:CommonResultRes(res)
  end
end
def.static("number", "number", "number").SellToCommerce = function(itemKey, itemId, shPrice)
end
def.static("number", "number", "number").SellToCommerceEx = function(itemKey, itemId, price)
end
def.method("=>", "table").GetNodes = function(self)
  return self.nodes
end
def.static("number", "number").SellToPitch = function(itemKey, itemId)
  CommercePitchPanel.Instance():SwitchTo(CommercePitchPanel.NodeId.PITCH)
  local toggle = CommercePitchPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_Tan"):GetComponent("UIToggle")
  toggle:set_value(true)
  CommercePitchPanel.Instance().nodes[CommercePitchPanel.Instance().curNode]:SellToPitch(itemKey, itemId)
end
def.static("number", "number").SellToTradingArcade = function(itemKey, itemId)
  if TradingArcadeUtils.CheckOpen() == false then
    return
  end
  CommercePitchPanel.Instance().nodes[CommercePitchPanel.NodeId.TradingArcade].nextNode = TradingArcadeNode.NodeId.SELL
  local toggle = CommercePitchPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_BlackShop"):GetComponent("UIToggle")
  toggle:set_value(true)
  CommercePitchPanel.Instance():SwitchTo(CommercePitchPanel.NodeId.TradingArcade)
  CommercePitchPanel.Instance().nodes[CommercePitchPanel.Instance().curNode]:SellToTradingArcade(itemKey, itemId)
end
def.static("table").TradingArcadeBuy = function(params)
  if TradingArcadeUtils.CheckOpen() == false then
    return
  end
  local toggle = CommercePitchPanel.Instance().m_panel:FindDirect("Img_Bg0/Tab_BlackShop"):GetComponent("UIToggle")
  toggle:set_value(true)
  local nodeId = CommercePitchPanel.NodeId.TradingArcade
  CommercePitchPanel.Instance().nodes[nodeId]:TradingArcadeBuy(params)
  CommercePitchPanel.Instance():SwitchTo(nodeId)
end
def.method().RefreshCommerceItemsInfo = function(self)
end
def.static("userdata", "number").SucceedSellBagItem = function(earnGold, canSellNum)
end
def.method().UpdateBag = function(self)
  self:UpdateRequirementsCondTbl()
end
def.method().UpdateSilverMoney = function(self)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:UpdateSilverMoney()
  end
end
def.method().UpdateGoldMoney = function(self)
end
def.method().UpdatePitchShoppingList = function(self)
  if CommercePitchPanel.NodeId.PITCH == self.curNode then
    self.nodes[self.curNode]:UpdatePitchShoppingList()
  end
end
def.method().RefeshCommerce = function(self)
end
def.method().UnSelectLastSellItem = function(self)
end
def.method("string", "userdata", "number", "table").onSpringFinish = function(self, id, scrollView, type, position)
  self.nodes[self.curNode]:onSpringFinish(id, scrollView, type, position)
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  self.nodes[self.curNode]:onSelect(id, selected, index)
end
CommercePitchPanel.Commit()
return CommercePitchPanel
