local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ExchangePanel = Lplus.Extend(ECPanelBase, "ExchangePanel")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ExchangeInterface = require("Main.Exchange.ExchangeInterface")
local Vector3 = require("Types.Vector3").Vector3
local ExchangeType = require("consts.mzm.gsp.exchange.confbean.ExchangeType")
local exchangeInterface = ExchangeInterface.Instance()
local def = ExchangePanel.define
local instance
def.const("table").itemPosX = {
  -213,
  -110,
  -30,
  58
}
def.field("table").curExchangeList = nil
def.field("number").curIndex = 1
def.field("table").pageIdList = nil
def.field("number").jumpActivityId = 0
def.field("number").jumpPageId = 0
def.field("table").pageExchangeMap = nil
def.static("=>", ExchangePanel).Instance = function()
  if instance == nil then
    instance = ExchangePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("number").ShowPanelByActivityId = function(self, activityId)
  if self:IsShow() then
    return
  end
  self.jumpPageId = ExchangeInterface.GetExchangePageId(activityId)
  self:ShowPanel()
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_COMMON_EXCHANGE_PANEL, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self.curIndex = 1
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s then
    local pageIdList = exchangeInterface:getExchangePageIdList()
    if #pageIdList > 0 then
      self.pageIdList = pageIdList
      self:setPageList()
      self:selectedActivity(self.curIndex)
    end
    Event.RegisterEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_SUCCESS, ExchangePanel.OnExchangeSuccess)
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ExchangePanel.OnBagInfoSynchronized)
  else
    self.curIndex = 1
    self.curExchangeList = nil
    self.jumpActivityId = 0
    self.jumpPageId = 0
    Event.UnregisterEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_SUCCESS, ExchangePanel.OnExchangeSuccess)
    Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ExchangePanel.OnBagInfoSynchronized)
  end
end
def.override().OnCreate = function(self)
end
def.static("table", "table").OnExchangeSuccess = function(p1, p2)
  if instance and instance.curIndex and instance.m_panel and not instance.m_panel.isnil then
    instance:setPageList()
    instance:setExchangeList(instance.pageIdList[instance.curIndex])
    Event.DispatchEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_RED_POINT_CHANGE, {})
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance and instance.curIndex and instance.m_panel and not instance.m_panel.isnil then
    instance:setPageList()
    instance:setExchangeList(instance.pageIdList[instance.curIndex])
    Event.DispatchEvent(ModuleId.EXCHANGE, gmodule.notifyId.Exchange.EXCHANGE_RED_POINT_CHANGE, {})
  end
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if strs[1] == "Img" and strs[2] == "Item" then
    local parent = clickObj.parent.parent
    local parentStrs = string.split(parent.name, "_")
    if parentStrs[1] == "item" then
      self:displayItemTips(tonumber(parentStrs[2]), tonumber(strs[3]), clickObj)
    end
  elseif strs[1] == "Img" and strs[2] == "Activity" then
    self:selectedActivity(tonumber(strs[3]))
  elseif id == "Btn_Close" then
    self:HidePanel()
  else
    if id == "Btn_Exchange" then
      local parent = clickObj.parent.parent
      local parentStrs = string.split(parent.name, "_")
      self:sendExchange(tonumber(parentStrs[2]))
    else
    end
  end
end
def.method("number").selectedActivity = function(self, index)
  self.curIndex = index
  self.curExchangeList = nil
  self:setExchangeList(self.pageIdList[index])
end
def.method("number").sendExchange = function(self, index)
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  if itemData:IsFull(BagInfo.BAG) then
    Toast(textRes.Exchange[1])
  else
    do
      local exchangeCfgId = self.curExchangeList[index]
      local exchangeCfg = ExchangeInterface.GetExchangeCfg(exchangeCfgId)
      local activityId = exchangeCfg.activity_cfg_id
      local exchangeNum = exchangeInterface:getExchangeNum(activityId, exchangeCfg.sort_id)
      if exchangeCfg.max_exchange_num > 0 and exchangeNum >= exchangeCfg.max_exchange_num then
        Toast(textRes.Exchange[2])
        return
      end
      local openId = ExchangeInterface.GetExchangeOpendId(activityId)
      if openId > 0 and not IsFeatureOpen(openId) then
        Toast(textRes.Exchange[5])
        return
      end
      do
        local BatchExchangePanel = require("Main.Exchange.ui.BatchExchangePanel")
        BatchExchangePanel.Instance():ShowPanel(activityId, exchangeCfgId)
        return
      end
      local function callback(id)
        if id == 1 then
          local req = require("netio.protocol.mzm.gsp.exchange.CExchangeAwardReq").new(activityId, exchangeCfg.sort_id)
          gmodule.network.sendProtocol(req)
        end
      end
      local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
      local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
      local key = string.format("%d_%d_%d", exchangeCfg.award_cfg_id, occupation.ALL, gender.ALL)
      local awardcfg = ItemUtils.GetGiftAwardCfg(key)
      local itemInfo = awardcfg.itemList[1]
      local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", string.format(textRes.Exchange[3], itemBase.name), callback, {})
    end
  end
end
def.method("number", "number", "userdata").displayItemTips = function(self, index, itemIdx, go)
  local exchangeCfgId = self.curExchangeList[index]
  local exchangeCfg = ExchangeInterface.GetExchangeCfg(exchangeCfgId)
  local itemId
  if itemIdx == 4 then
    local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
    local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
    local key = string.format("%d_%d_%d", exchangeCfg.award_cfg_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    local itemInfo = awardcfg.itemList[1]
    itemId = itemInfo.itemId
    local position = go:get_position()
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = go:GetComponent("UIWidget")
    ItemTipsMgr.Instance():ShowBasicTips(itemId, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), 0, false)
  else
    local itemInfo = exchangeCfg.itemList[itemIdx]
    itemId = itemInfo.itemId
    if exchangeCfg.exchange_type == ExchangeType.USE_SAME_PRICE_ITEM_ID then
      local filterCfg = ItemUtils.GetItemFilterCfg(itemId)
      local siftCfgs = filterCfg.siftCfgs
      if siftCfgs and siftCfgs[1] then
        itemId = siftCfgs[1].idvalue
      end
    end
    ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemId, go, 0, true)
  end
end
def.method().setPageList = function(self)
  local Grid = self.m_panel:FindDirect("Img_Bg0/List/Scroll View/Grid")
  local uilist = Grid:GetComponent("UIList")
  uilist.itemCount = #self.pageIdList
  uilist:Resize()
  for i, v in ipairs(self.pageIdList) do
    local pageCfg = ExchangeInterface.GetExchangePageCfg(v)
    local Img_Activity = Grid:FindDirect("Img_Activity_" .. i)
    local Label_EquipName = Img_Activity:FindDirect("Label_EquipName01_" .. i)
    Label_EquipName:GetComponent("UILabel"):set_text(pageCfg.desc)
    if self.jumpPageId > 0 then
      local isSelected = v == self.jumpPageId
      Img_Activity:GetComponent("UIToggle").value = isSelected
      if isSelected then
        self.curIndex = i
      end
    else
      Img_Activity:GetComponent("UIToggle").value = i == self.curIndex
    end
    local canExchange = exchangeInterface:calcExchangePageRedPoint(v)
    local Img_New = Img_Activity:FindDirect("Img_New_" .. i)
    Img_New:SetActive(canExchange)
  end
  if self.jumpPageId > 0 then
    self.jumpPageId = 0
    GameUtil.AddGlobalTimer(0, true, function()
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      uilist:DragToMakeVisible(self.curIndex - 1, 80)
    end)
  end
end
def.method("table").sortExchangeList = function(self, exchangeList)
  local function isOwnExchangeNum(id)
    local cfg = ExchangeInterface.GetExchangeCfg(id)
    local exchangeNum = exchangeInterface:getExchangeNum(cfg.activity_cfg_id, cfg.sort_id)
    if cfg.max_exchange_num == 0 then
      return true
    end
    if exchangeNum >= cfg.max_exchange_num then
      return false
    end
    return true
  end
  local function comp(id1, id2)
    local cfg1 = ExchangeInterface.GetExchangeCfg(id1)
    local cfg2 = ExchangeInterface.GetExchangeCfg(id2)
    local canEchange1 = exchangeInterface:canEchange(cfg1.activity_cfg_id, id1)
    local canEchange2 = exchangeInterface:canEchange(cfg2.activity_cfg_id, id2)
    if canEchange1 and canEchange2 then
      return cfg1.display_sort_id < cfg2.display_sort_id
    elseif canEchange1 then
      return true
    elseif canEchange2 then
      return false
    else
      local isOwnNum1 = isOwnExchangeNum(id1)
      local isOwnNum2 = isOwnExchangeNum(id2)
      if isOwnNum1 and isOwnNum2 then
        return cfg1.display_sort_id < cfg2.display_sort_id
      elseif isOwnNum1 then
        return true
      elseif isOwnNum2 then
        return false
      else
        return cfg1.display_sort_id < cfg2.display_sort_id
      end
    end
  end
  table.sort(exchangeList, comp)
end
def.method("number").setExchangeList = function(self, pageId)
  local pageCfg = ExchangeInterface.GetExchangePageCfg(pageId)
  local Group_Right = self.m_panel:FindDirect("Img_Bg0/Group_Right")
  local Label_Time = Group_Right:FindDirect("Label_StartTime")
  Label_Time:GetComponent("UILabel"):set_text(pageCfg.time_desc)
  local Label_Info = Group_Right:FindDirect("Label_Info")
  Label_Info:GetComponent("UILabel"):set_text(pageCfg.activity_desc)
  local ScrollView = Group_Right:FindDirect("GameObject/Scroll View")
  local Grid = Group_Right:FindDirect("GameObject/Scroll View/Grid")
  local exchangeList = self.curExchangeList
  local isReposition = false
  if exchangeList == nil then
    exchangeList = exchangeInterface:getExchangeListByPageId(pageId)
    self:sortExchangeList(exchangeList)
    self.curExchangeList = exchangeList
    isReposition = true
  end
  local uilist = Grid:GetComponent("UIList")
  uilist.itemCount = #exchangeList
  uilist:Resize()
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  local listItem
  for i, v in ipairs(exchangeList) do
    local item_bg = Grid:FindDirect("item_" .. i)
    local exchangeCfg = ExchangeInterface.GetExchangeCfg(v)
    local Img_ListBg = item_bg:FindDirect("Img_ListBg")
    local itemNum = 0
    local isGrey = false
    for itemIndex = 1, 3 do
      local itemInfo = exchangeCfg.itemList[itemIndex]
      local Img_Item = Img_ListBg:FindDirect("Img_Item_" .. itemIndex)
      if itemInfo and 0 < itemInfo.itemId then
        Img_Item:SetActive(true)
        local Texture_Icon = Img_Item:FindDirect("Img_ItemIcon"):GetComponent("UITexture")
        local itemId = itemInfo.itemId
        local count = 0
        local icon = 0
        if exchangeCfg.exchange_type == ExchangeType.USE_SAME_PRICE_ITEM_ID then
          local filterCfg = ItemUtils.GetItemFilterCfg(itemId)
          icon = filterCfg.icon
          for index, siftCfg in ipairs(filterCfg.siftCfgs) do
            count = count + itemData:GetNumberByItemId(BagInfo.BAG, siftCfg.idvalue)
          end
        else
          local itemBase = ItemUtils.GetItemBase(itemId)
          count = itemData:GetNumberByItemId(BagInfo.BAG, itemInfo.itemId)
          icon = itemBase.icon
        end
        GUIUtils.FillIcon(Texture_Icon, icon)
        local Label_ItemNumber = Img_Item:FindDirect("Label_ItemNumber")
        Label_ItemNumber:GetComponent("UILabel"):set_text("")
        local Label_Num = Img_Item:FindDirect("Label_Num")
        local numStr
        if count >= itemInfo.itemNum then
          numStr = string.format("[00ff00]%d[-]/%d", count, itemInfo.itemNum)
        else
          numStr = string.format("[ff0000]%d[-]/%d", count, itemInfo.itemNum)
        end
        Label_Num:GetComponent("UILabel"):set_text(numStr)
        itemNum = itemNum + 1
        if count < itemInfo.itemNum and not isGrey then
          isGrey = true
        end
      else
        Img_Item:SetActive(false)
      end
    end
    local exchangeNum = exchangeInterface:getExchangeNum(exchangeCfg.activity_cfg_id, exchangeCfg.sort_id)
    local Btn_Exchange = Img_ListBg:FindDirect("Btn_Exchange")
    local Img_Full = Img_ListBg:FindDirect("Img_Full")
    if 0 < exchangeCfg.max_exchange_num and exchangeNum >= exchangeCfg.max_exchange_num then
      Btn_Exchange:SetActive(false)
      Img_Full:SetActive(true)
    else
      Btn_Exchange:SetActive(true)
      Img_Full:SetActive(false)
      if isGrey then
        Btn_Exchange:GetComponent("UIButton"):set_isEnabled(false)
      else
        if listItem == nil then
          listItem = item_bg
        end
        Btn_Exchange:GetComponent("UIButton"):set_isEnabled(true)
      end
    end
    local item_award = Img_ListBg:FindDirect("Img_Item_4")
    local pos = item_award.transform.localPosition
    item_award.transform.localPosition = Vector3.new(ExchangePanel.itemPosX[itemNum + 1], pos.y, pos.z)
    local key = string.format("%d_%d_%d", exchangeCfg.award_cfg_id, occupation.ALL, gender.ALL)
    local awardcfg = ItemUtils.GetGiftAwardCfg(key)
    local itemInfo = awardcfg.itemList[1]
    local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
    local Texture_Award = item_award:FindDirect("Img_ItemIcon"):GetComponent("UITexture")
    GUIUtils.FillIcon(Texture_Award, itemBase.icon)
    local Label_ItemNumber = item_award:FindDirect("Label_ItemNumber")
    Label_ItemNumber:GetComponent("UILabel"):set_text(itemInfo.num)
    local Label_Num = item_award:FindDirect("Label_Num")
    Label_Num:GetComponent("UILabel"):set_text(itemBase.name)
    local Label_Times = Img_ListBg:FindDirect("Label_Times")
    local exchangeNumStr
    if 0 < exchangeCfg.max_exchange_num then
      exchangeNumStr = exchangeNum .. "/" .. exchangeCfg.max_exchange_num
    else
      exchangeNumStr = textRes.Exchange[4]
    end
    Label_Times:GetComponent("UILabel"):set_text(exchangeNumStr)
  end
  if isReposition then
    GameUtil.AddGlobalTimer(0.1, true, function()
      if self.m_panel == nil or self.m_panel.isnil or ScrollView.isnil then
        return
      end
      ScrollView:GetComponent("UIScrollView"):ResetPosition()
    end)
  end
end
return ExchangePanel.Commit()
