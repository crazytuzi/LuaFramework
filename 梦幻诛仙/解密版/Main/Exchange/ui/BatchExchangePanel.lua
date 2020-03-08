local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BatchExchangePanel = Lplus.Extend(ECPanelBase, "BatchExchangePanel")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local ExchangeInterface = require("Main.Exchange.ExchangeInterface")
local Vector3 = require("Types.Vector3").Vector3
local ExchangeType = require("consts.mzm.gsp.exchange.confbean.ExchangeType")
local exchangeInterface = ExchangeInterface.Instance()
local ItemData = require("Main.Item.ItemData")
local def = BatchExchangePanel.define
local instance
def.const("table").itemPosX = {
  -213,
  -110,
  -30,
  58
}
def.const("number").Max_Num = 999
def.field("number").activityId = 0
def.field("number").exchangeId = 0
def.field("number").exchangeCount = 1
def.static("=>", BatchExchangePanel).Instance = function()
  if instance == nil then
    instance = BatchExchangePanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("number", "number").ShowPanel = function(self, activityId, exchangeId)
  if self:IsShow() then
    return
  end
  self.activityId = activityId
  self.exchangeId = exchangeId
  self:CreatePanel(RESPATH.PREFAB_PIECE_EXCHANGE_PANEL, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:setExchangeInfo()
  else
    self.exchangeCount = 1
  end
end
def.override().OnCreate = function(self)
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_Exchange" then
    self:sendExchange()
  elseif id == "Btn_Add" then
    local canExchangeNum = self:canExchangeNum()
    if canExchangeNum <= self.exchangeCount then
      Toast(textRes.Exchange[10])
      return
    end
    self.exchangeCount = self.exchangeCount + 1
    self:setExchangeInfo()
  elseif id == "Btn_Minus" then
    if self.exchangeCount > 1 then
      self.exchangeCount = self.exchangeCount - 1
      self:setExchangeInfo()
    end
  elseif id == "Btn_Max" then
    self.exchangeCount = self:canExchangeNum()
    self:setExchangeInfo()
  elseif id == "Img_BgNum" then
    do
      local canExchangeNum = self:canExchangeNum()
      local NumberPad = require("GUI.CommonDigitalKeyboard")
      NumberPad.Instance():ShowPanelEx(-1, function(num)
        if self:IsShow() then
          if num == self.exchangeCount then
            return
          end
          if num > canExchangeNum then
            NumberPad.Instance():SetEnteredValue(canExchangeNum)
            Toast(string.format(textRes.NPCStore[22], canExchangeNum))
            num = canExchangeNum
          end
          if num < 1 then
            NumberPad.Instance():SetEnteredValue(0)
            num = 1
          else
            NumberPad.Instance():SetEnteredValue(num)
          end
          self.exchangeCount = num
          self:setExchangeInfo()
        end
      end, {self = self})
      NumberPad.Instance():SetPos(260, 0)
    end
  else
    if strs[1] == "Img" and strs[2] == "Item" then
      local idx = tonumber(strs[3])
      if idx then
        self:displayItemTips(idx, clickObj)
      end
    else
    end
  end
end
def.method().sendExchange = function(self)
  local itemData = ItemData.Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  if itemData:IsFull(BagInfo.BAG) then
    Toast(textRes.Exchange[1])
  else
    do
      local exchangeCfg = ExchangeInterface.GetExchangeCfg(self.exchangeId)
      local activityId = self.activityId
      local exchangeNum = exchangeInterface:getExchangeNum(activityId, exchangeCfg.sort_id)
      local canExchangeNum = self:canExchangeNum()
      if exchangeCfg.max_exchange_num > 0 and canExchangeNum <= 0 then
        Toast(textRes.Exchange[2])
        return
      end
      local openId = ExchangeInterface.GetExchangeOpendId(activityId)
      if openId > 0 and not IsFeatureOpen(openId) then
        Toast(textRes.Exchange[5])
        return
      end
      for i, v in pairs(exchangeCfg.itemList) do
        local count = 0
        local name = ""
        local itemId = v.itemId
        if exchangeCfg.exchange_type == ExchangeType.USE_SAME_PRICE_ITEM_ID then
          local filterCfg = ItemUtils.GetItemFilterCfg(itemId)
          name = filterCfg.name
          for index, siftCfg in ipairs(filterCfg.siftCfgs) do
            count = count + itemData:GetNumberByItemId(BagInfo.BAG, siftCfg.idvalue)
          end
        else
          local itemBase = ItemUtils.GetItemBase(itemId)
          count = itemData:GetNumberByItemId(BagInfo.BAG, itemId)
          name = itemBase.name
        end
        if count < v.itemNum * self.exchangeCount then
          Toast(string.format(textRes.Exchange[11], name))
          return
        end
      end
      local function callback(id)
        if id == 1 then
          local req = require("netio.protocol.mzm.gsp.exchange.CExchangeAwardReq").new(activityId, exchangeCfg.sort_id, self.exchangeCount)
          gmodule.network.sendProtocol(req)
          self:HidePanel()
        end
      end
      callback(1)
    end
  end
end
def.method("number", "userdata").displayItemTips = function(self, itemIdx, go)
  local exchangeCfgId = self.exchangeId
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
def.method("=>", "number").canExchangeNum = function(self)
  local exchangeCfg = ExchangeInterface.GetExchangeCfg(self.exchangeId)
  if exchangeCfg.max_exchange_num == 0 then
    return BatchExchangePanel.Max_Num
  end
  local exchangeNum = exchangeInterface:getExchangeNum(exchangeCfg.activity_cfg_id, exchangeCfg.sort_id)
  return exchangeCfg.max_exchange_num - exchangeNum
end
def.method().setExchangeInfo = function(self)
  local itemData = ItemData.Instance()
  local exchangeCfg = ExchangeInterface.GetExchangeCfg(self.exchangeId)
  local Group_Exchange = self.m_panel:FindDirect("Img_Bg0/Group_Exchange")
  local itemNum = 0
  local isGrey = false
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local occupation = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
  local gender = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
  for itemIndex = 1, 3 do
    local itemInfo = exchangeCfg.itemList[itemIndex]
    local Img_Item = Group_Exchange:FindDirect("Img_Item_" .. itemIndex)
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
      local needNum = itemInfo.itemNum * self.exchangeCount
      if count >= needNum then
        numStr = string.format("[00ff00]%d[-]/%d", count, needNum)
      else
        numStr = string.format("[ff0000]%d[-]/%d", count, needNum)
      end
      Label_Num:GetComponent("UILabel"):set_text(numStr)
      itemNum = itemNum + 1
    else
      Img_Item:SetActive(false)
    end
  end
  local exchangeNum = exchangeInterface:getExchangeNum(exchangeCfg.activity_cfg_id, exchangeCfg.sort_id)
  local item_award = Group_Exchange:FindDirect("Img_Item_4")
  local pos = item_award.transform.localPosition
  item_award.transform.localPosition = Vector3.new(BatchExchangePanel.itemPosX[itemNum + 1], pos.y, pos.z)
  local key = string.format("%d_%d_%d", exchangeCfg.award_cfg_id, occupation.ALL, gender.ALL)
  local awardcfg = ItemUtils.GetGiftAwardCfg(key)
  local itemInfo = awardcfg.itemList[1]
  local itemBase = ItemUtils.GetItemBase(itemInfo.itemId)
  local Texture_Award = item_award:FindDirect("Img_ItemIcon"):GetComponent("UITexture")
  GUIUtils.FillIcon(Texture_Award, itemBase.icon)
  local Label_ItemNumber = item_award:FindDirect("Label_ItemNumber")
  Label_ItemNumber:GetComponent("UILabel"):set_text(itemInfo.num * self.exchangeCount)
  local Label_Num = item_award:FindDirect("Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(itemBase.name)
  local Label_Exchange_Num = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Num/Img_BgNum/Label_Num")
  local Btn_Max = self.m_panel:FindDirect("Img_Bg0/Group_Right/Group_Num/Btn_Max")
  if exchangeCfg.max_exchange_num == 0 then
    Label_Exchange_Num:GetComponent("UILabel"):set_text(self.exchangeCount)
    Btn_Max:SetActive(false)
  else
    local canExchangeNum = self:canExchangeNum()
    warn("exchangeCount:", Label_Exchange_Num, Label_Exchange_Num:GetComponent("UILable"), self.exchangeCount, canExchangeNum)
    Label_Exchange_Num:GetComponent("UILabel"):set_text(self.exchangeCount .. "/" .. canExchangeNum)
    Btn_Max:SetActive(true)
  end
end
return BatchExchangePanel.Commit()
