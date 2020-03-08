local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MallPanel = Lplus.Extend(ECPanelBase, "MallPanel")
local def = MallPanel.define
local TreasureNode = require("Main.Mall.ui.TreasureNode")
local PayNode = require("Main.Pay.ui.PayNode")
local CommerceNode = require("Main.Mall.ui.CommercePanel")
local PromotionNode = require("Main.Mall.ui.PromotionNode")
local MallData = require("Main.Mall.data.MallData")
local CurrencyChargeNode = require("Main.Mall.ui.CurrencyChargeNode")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local TaskInterface = require("Main.task.TaskInterface")
local CommercePitchUtils = require("Main.CommerceAndPitch.CommercePitchUtils")
local ItemModule = require("Main.Item.ItemModule")
local CommerceData = require("Main.CommerceAndPitch.data.CommerceData")
local instance
def.const("table").NodeId = {
  TREASURE = 1,
  PAY = 2,
  CURRENCYCHARGE = 3,
  COMMERCE = 4,
  PROMOTION = 5
}
def.field("table").nodes = nil
def.field("number").curNode = 0
def.field("number").state = 0
def.const("table").StateConst = {
  Treasure = 1,
  Pay = 2,
  CurrencyCharge = 3,
  Commerce = 4,
  Promotion = 5
}
def.field("number").malltype = 0
def.field(MallData).data = nil
def.field("number").selectItemId = 0
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
def.static("=>", MallPanel).Instance = function()
  if instance == nil then
    instance = MallPanel()
    instance:Init()
    instance.m_TrigGC = true
    instance.m_TryIncLoadSpeed = true
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.PAY, gmodule.notifyId.Pay.RECHARTE_RETURN_STATUS, MallPanel.OnPayReturnStatus)
end
def.method("number", "number", "number").ShowPanel = function(self, state, itemId, malltype)
  if IsCrossingServer() then
    ToastCrossingServerForbiden()
    return
  end
  if self:IsShow() then
    self:InitRequirements()
    self.state = state
    self.selectItemId = itemId
    self.malltype = malltype
    self:UpdateState()
    return
  end
  self:InitRequirements()
  self.state = state
  self.selectItemId = itemId
  self.malltype = malltype
  self:SetModal(true)
  self:CreatePanel(RESPATH.PREFAB_MALL_PANEL, 1)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MallPanel.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, MallPanel.OnDailyPurchaseRedPoint)
  self.nodes = {}
  local treasureNode = self.m_panel:FindDirect("Img_Bg0/Img_ZhenBao")
  self.nodes[MallPanel.NodeId.TREASURE] = TreasureNode.Instance()
  self.nodes[MallPanel.NodeId.TREASURE]:Init(self, treasureNode)
  local payNode = self.m_panel:FindDirect("Img_Bg0/Group_Recharge")
  self.nodes[MallPanel.NodeId.PAY] = PayNode.Instance()
  self.nodes[MallPanel.NodeId.PAY]:Init(self, payNode)
  local currencyChargeNode = self.m_panel:FindDirect("Img_Bg0/Group_DuiHuan")
  self.nodes[MallPanel.NodeId.CURRENCYCHARGE] = CurrencyChargeNode.Instance()
  self.nodes[MallPanel.NodeId.CURRENCYCHARGE]:Init(self, currencyChargeNode)
  local commerceNode = self.m_panel:FindDirect("Img_Bg0/Group_Commerce")
  self.nodes[MallPanel.NodeId.COMMERCE] = CommerceNode.Instance()
  self.nodes[MallPanel.NodeId.COMMERCE]:Init(self, commerceNode)
  local promotionNode = self.m_panel:FindDirect("Img_Bg0/Group_OnSale")
  self.nodes[MallPanel.NodeId.PROMOTION] = PromotionNode.Instance()
  self.nodes[MallPanel.NodeId.PROMOTION]:Init(self, promotionNode)
  self:UpdateTabs()
  self:updateRedPoint()
  self:updateDailyPurchaseRedPoint()
end
local MysteryStoreInterface = require("Main.Mall.MysteryStoreInterface")
local EC = require("Types.Vector")
def.method().UpdateTabs = function(self)
  local MallModule = require("Main.Mall.MallModule")
  local onSaleTab = self.m_panel:FindDirect("Img_Bg0/Tap_OnSale")
  local payTab = self.m_panel:FindDirect("Img_Bg0/Tap_Recharge")
  local tY = onSaleTab:GetComponent("UISprite"):get_height()
  local bCanShow = MysteryStoreInterface.CanShowMysteryStore()
  if bCanShow then
    onSaleTab:SetActive(true)
    local dst = payTab.transform.localPosition - onSaleTab.transform.localPosition
    if math.abs(dst.y) <= 10 then
      local tmpPos = EC.Vector3.new(0, -tY, 0)
      payTab.transform.localPosition = payTab.transform.localPosition + tmpPos
    end
  else
    onSaleTab:SetActive(false)
    if math.abs((onSaleTab.transform.localPosition - payTab.transform.localPosition).y) > 10 then
      local tmpPos = EC.Vector3.new(0, tY, 0)
      payTab.transform.localPosition = payTab.transform.localPosition + tmpPos
      if self.state == MallPanel.StateConst.Promotion then
        self.state = MallPanel.StateConst.Commerce
      end
    end
  end
  self:UpdateState()
  self:updateRedPoint()
end
def.method().UpdateState = function(self)
  if MallPanel.StateConst.Treasure == self.state then
    if self.malltype ~= 0 then
      self.nodes[MallPanel.NodeId.TREASURE].selectMallType = self.malltype
      self.nodes[MallPanel.NodeId.TREASURE].selectItemId = self.selectItemId
      self.malltype = 0
    end
    if self.selectItemId ~= 0 then
      self.nodes[MallPanel.NodeId.TREASURE].selectItemId = self.selectItemId
      self.selectItemId = 0
    end
    self:SwitchTo(MallPanel.NodeId.TREASURE)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tap_ZhenBao"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif MallPanel.StateConst.Pay == self.state then
    self:SwitchTo(MallPanel.NodeId.PAY)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tap_Recharge"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif MallPanel.StateConst.CurrencyCharge == self.state then
    self:SwitchTo(MallPanel.NodeId.CURRENCYCHARGE)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tap_DuiHuan"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif MallPanel.StateConst.Commerce == self.state then
    self:SwitchTo(MallPanel.NodeId.COMMERCE)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tab_Commerce"):GetComponent("UIToggle")
    toggle:set_value(true)
  elseif MallPanel.StateConst.Promotion == self.state then
    self:SwitchTo(MallPanel.NodeId.PROMOTION)
    local toggle = self.m_panel:FindDirect("Img_Bg0/Tap_OnSale"):GetComponent("UIToggle")
    toggle:set_value(true)
  end
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, MallPanel.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.MALL, gmodule.notifyId.Mall.UpdateDailyPurchaseRedPoint, MallPanel.OnDailyPurchaseRedPoint)
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  CommercePitchModule.Instance()._bIsByTask = false
  CommercePitchModule.Instance()._npcId = 0
  CommercePitchModule.Instance()._curRequirementByTask = nil
  CommercePitchModule.Instance().selectPitchItemId = 0
  self.stateByTask = 0
  self.bOpenDefault = true
  TreasureNode.Instance():DestroyRelateModel()
  local node = self.nodes[self.curNode]
  if not _G.IsNil(node) then
    node:Hide()
  end
  self:Clear()
end
def.override("boolean").OnShow = function(self, show)
  if show then
    if self.curNode == MallPanel.NodeId.PAY then
      self.nodes[self.curNode]:OnShow()
    elseif self.curNode == MallPanel.NodeId.TREASURE then
      self.nodes[self.curNode]:OnVisible()
    end
  end
end
def.method().Clear = function(self)
  self.curNode = 0
  self.state = 0
  self.selectItemId = 0
  CommerceData.Instance():clearCalcItemCalcItemPriceInfo()
end
def.method().Hide = function(self)
  self:DestroyPanel()
  self = nil
end
def.method("number", "boolean").SetToggleState = function(self, nodeId, targetState)
  local toggleObj
  if MallPanel.NodeId.TREASURE == nodeId then
    toggleObj = self.m_panel:FindDirect("Img_Bg0/Tap_ZhenBao")
  elseif MallPanel.NodeId.PAY == nodeId then
    toggleObj = self.m_panel:FindDirect("Img_Bg0/Tap_Recharge")
  elseif MallPanel.NodeId.CURRENCYCHARGE == nodeId then
    toggleObj = self.m_panel:FindDirect("Img_Bg0/Tap_DuiHuan")
  elseif MallPanel.NodeId.COMMERCE == nodeId then
    toggleObj = self.m_panel:FindDirect("Img_Bg0/Tab_Commerce")
  elseif MallPanel.NodeId.PROMOTION == nodeId then
    toggleObj = self.m_panel:FindDirect("Img_Bg0/Tap_OnSale")
  end
  if toggleObj then
    toggleObj:GetComponent("UIToggle"):set_value(targetState)
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
def.method("string", "boolean").onPress = function(self, id, state)
  if self.curNode == MallPanel.NodeId.TREASURE then
    self.nodes[self.curNode]:onPress(id, state)
  end
end
def.method("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  warn("onClickObj" .. id)
  if "Btn_Close" == id then
    self:Hide()
    Event.DispatchEvent(ModuleId.MALL, gmodule.notifyId.Mall.PanelClose, nil)
  elseif "Modal" == id then
    self:Hide()
  elseif id == "Img_MoneyIcon" then
    require("Main.Item.ItemModule").Instance():ShowYuanbaoDetail(1)
  elseif "Tap_ZhenBao" == id then
    self:SwitchTo(MallPanel.NodeId.TREASURE)
  elseif "Tap_Recharge" == id then
    self:SwitchTo(MallPanel.NodeId.PAY)
  elseif "Tap_DuiHuan" == id then
    self:SwitchTo(MallPanel.NodeId.CURRENCYCHARGE)
  elseif "Tab_Commerce" == id then
    self:SwitchTo(MallPanel.NodeId.COMMERCE)
  elseif "Tap_OnSale" == id then
    self:SwitchTo(MallPanel.NodeId.PROMOTION)
  else
    self.nodes[self.curNode]:onClickObj(clickobj)
  end
end
def.method().updateRedPoint = function(self)
  if self.m_panel == nil then
    return
  end
  if PayNode.Instance():canGetSaveAmtAward() == true then
    self.m_panel:FindDirect("Img_Bg0/Group_Recharge/Group_Tab/Img_Tab/Group_RechargeReturn/Img_Red"):SetActive(false)
    self.m_panel:FindDirect("Img_Bg0/Tap_Recharge/Img_Red"):SetActive(true)
    self.m_panel:FindDirect("Img_Bg0/Group_Recharge/Img_ListBg/Btn_OutGet/Img_Red"):SetActive(true)
  else
    self.m_panel:FindDirect("Img_Bg0/Group_Recharge/Group_Tab/Img_Tab/Group_RechargeReturn/Img_Red"):SetActive(false)
    self.m_panel:FindDirect("Img_Bg0/Tap_Recharge/Img_Red"):SetActive(false)
    self.m_panel:FindDirect("Img_Bg0/Group_Recharge/Img_ListBg/Btn_OutGet/Img_Red"):SetActive(false)
  end
  local bMysteryStoreRedPt = require("Main.Mall.ui.PromotionNode").IsActiveRedPt()
  self.m_panel:FindDirect("Img_Bg0/Tap_OnSale/Img_Red"):SetActive(bMysteryStoreRedPt)
end
def.method().updateDailyPurchaseRedPoint = function(self)
  if self.m_panel == nil then
    return
  end
  local isShowRedPoint = MallData.Instance():isShowDailyPurchaseRedPoint()
  local Tab_Red = self.m_panel:FindDirect("Img_Bg0/Tap_ZhenBao/Img_Red")
  Tab_Red:SetActive(isShowRedPoint)
end
def.static("table", "table").OnPayReturnStatus = function(params, tbl)
  MallPanel.Instance():updateRedPoint()
end
def.static("table", "table").OnDailyPurchaseRedPoint = function(p1, p2)
  MallPanel.Instance():updateDailyPurchaseRedPoint()
end
def.method("userdata", "number", "number", "number").SucceedBuyCommerceItem = function(self, costGold, canBuyNum, itemId, itemCount)
  if MallPanel.NodeId.COMMERCE == self.curNode then
    CommerceNode.Instance():SucceedBuyItem(costGold, canBuyNum, itemId, itemCount)
  end
end
def.method("number").CommerceCommonResultRes = function(self, res)
  if MallPanel.NodeId.COMMERCE == self.curNode then
    CommerceNode.Instance():CommonResultRes(res)
  end
end
def.static("number", "number", "number", "number").SellToCommerce = function(bagId, itemKey, itemId, shPrice)
  CommerceNode.SellToCommerce(bagId, itemKey, itemId, shPrice)
end
def.static("number", "number", "number", "number", "number").SellAllToCommerce = function(bagId, itemKey, itemId, number, shPrice)
  CommerceNode.SellAllToCommerce(bagId, itemKey, itemId, number, shPrice)
end
def.static("number", "number", "number", "number").SellToCommerceEx = function(bagId, itemKey, itemId, price)
  CommerceNode.SellToCommerceEx(bagId, itemKey, itemId, price)
end
def.method().RefreshCommerceItemsInfo = function(self)
  if MallPanel.NodeId.COMMERCE == self.curNode then
    CommerceNode.Instance():RefreshCommerceItemsInfo()
  end
end
def.static("userdata", "number").SucceedSellBagItem = function(earnGold, canSellNum)
  CommerceNode.SucceedSellItem(earnGold, canSellNum)
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
end
def.method().UpdateBag = function(self)
  self:UpdateRequirementsCondTbl()
  if MallPanel.NodeId.COMMERCE == self.curNode then
    CommerceNode.Instance():CommerceBagsUpdate()
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
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
  if CommercePitchModule.Instance().showByTask == true then
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
  local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
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
def.method().RefeshCommerce = function(self)
  if MallPanel.NodeId.COMMERCE == self.curNode then
    self.nodes[self.curNode]:RefeshCommerce()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  local activityInterface = require("Main.activity.ActivityInterface").Instance()
  activityInterface:_refreshActivityRequirements()
end
def.method().UpdateGoldMoney = function(self)
  if MallPanel.NodeId.COMMERCE == self.curNode then
    self.nodes[self.curNode]:UpdateGoldMoney()
  end
end
def.method().UnSelectLastSellItem = function(self)
  if MallPanel.NodeId.COMMERCE == self.curNode then
    self.nodes[self.curNode]:UnSelectLastSellItem()
  end
end
def.method("number", "table").FillConditionItemId = function(self, siftId, list)
  if self.bWantToOpen then
    local CommercePitchModule = require("Main.CommerceAndPitch.CommercePitchModule")
    local CommercePitchPanel = require("Main.CommerceAndPitch.ui.CommercePitchPanel")
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
              self.requirementsCommerceGroup[bigGroup] = true
              self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
              self.bigGroup = bigGroup
              self.smallGroup = smallGroup
              self.state = MallPanel.StateConst.Commerce
              self.stateByTask = MallPanel.StateConst.Commerce
              self.requirementsCommerceCondItemId[k] = true
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
                  self.requirementsCommerceGroup[bigGroup] = true
                  self.requirementsCommerceGroup[bigGroup * 100 + smallGroup] = true
                  self.bigGroup = bigGroup
                  self.smallGroup = smallGroup
                  self.state = MallPanel.StateConst.Commerce
                  self.stateByTask = MallPanel.StateConst.Commerce
                  self.requirementsCommerceCondItemId[n] = true
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
      self:CreatePanel(RESPATH.PREFAB_MALL_PANEL, 1)
      self.bWantToOpen = false
    end
  end
end
def.method("string").onDragStart = function(self, id)
  self.nodes[self.curNode]:onDragStart(id)
end
def.method("string").onDragEnd = function(self, id)
  self.nodes[self.curNode]:onDragEnd(id)
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  self.nodes[self.curNode]:onDrag(id, dx, dy)
end
return MallPanel.Commit()
