local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local NpcExchangePanel = Lplus.Extend(ECPanelBase, "NpcExchangePanel")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GUIUtils = require("GUI.GUIUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local Vector3 = require("Types.Vector3").Vector3
local NpcExchangeMgr = require("Main.Exchange.NpcExchangeMgr")
local def = NpcExchangePanel.define
local instance
def.field("number").exchangeId = 0
def.field("number").exchangeNum = 1
def.field("table").needItems = nil
def.field("table").itemsPrice = nil
def.field("number").needYuabaoNum = 0
def.field("number").exchangeMaxNum = 0
def.field("boolean").isUseYuanbao = false
def.field("number").canExchangeNum = 0
def.static("=>", NpcExchangePanel).Instance = function()
  if instance == nil then
    instance = NpcExchangePanel()
    instance:Init()
  end
  return instance
end
def.method("table").OnSyncItemPrice = function(self, p)
  if self and self:IsShow() then
    self.itemsPrice = self.itemsPrice or {}
    for i, v in pairs(p) do
      self.itemsPrice[i] = v
    end
    self:setExchangeYuanbaoNum()
  end
end
def.method().Init = function(self)
end
def.method("number", "boolean").ShowPanel = function(self, exchangeId, isUseYuanbao)
  if self:IsShow() then
    return
  end
  self.isUseYuanbao = isUseYuanbao
  self.exchangeId = exchangeId
  self:CreatePanel(RESPATH.PREFAB_TREASURE_MAP_EXCHANGE, 1)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self.exchangeId = 0
  self.exchangeNum = 1
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s then
    self:setExchangeMaxNum()
    self:initExchangeInfo()
    self:setItemInfo()
    self:reqItemYubaoPrice()
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, NpcExchangePanel.OnBagInfoSynchronized)
  else
    Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, NpcExchangePanel.OnBagInfoSynchronized)
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(p1, p2)
  if instance and instance:IsShow() then
    instance:setExchangeNum()
    instance:setItemInfo()
  end
end
def.override().OnCreate = function(self)
end
def.method().setExchangeMaxNum = function(self)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEM_CONSTS_CFG, "MAX_EXCHANGE_COUNT")
  if record == nil then
    return nil
  end
  self.exchangeMaxNum = record:GetIntValue("value")
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  local strs = string.split(id, "_")
  if id == "Btn_Exchange" then
    local canExchange = ActivityInterface.Instance():isNpcExchangeWithinTime(self.exchangeId)
    if not canExchange then
      Toast(textRes.activity[408])
      return false
    end
    self:confirmExchange()
  elseif id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Btn_UseGold" then
    self:setExchangeYuanbaoNum()
    if not self.isUseYuanbao then
      Toast(textRes.activity[401])
    end
  elseif id == "Btn_Add" then
    local exchangeItemCfg = ItemUtils.GetExchangeItemCfg(self.exchangeId)
    local npcExchangeMgr = NpcExchangeMgr.Instance()
    local dailyMaxNum = exchangeItemCfg.dailyExchangeTimesLimit
    if dailyMaxNum > 0 then
      local dailyNum = npcExchangeMgr:getTodayExchangeTimes(self.exchangeId)
      if dailyMaxNum <= self.exchangeNum + dailyNum then
        Toast(textRes.Exchange[6])
        return
      end
    end
    local maxNum = exchangeItemCfg.exchangeTimesLimit
    if maxNum > 0 then
      local exchangeNum = npcExchangeMgr:getExchangeTimes(self.exchangeId)
      if maxNum <= self.exchangeNum + exchangeNum then
        Toast(textRes.Exchange[7])
        return
      end
    end
    if self.exchangeNum >= self.exchangeMaxNum then
      Toast(textRes.activity[399])
      return
    end
    if not self.isUseYuanbao and self.exchangeNum >= self.canExchangeNum then
      Toast(textRes.activity[404])
      return
    end
    self.exchangeNum = self.exchangeNum + 1
    self:setExchangeNum()
  elseif id == "Btn_Minus" then
    if self.exchangeNum <= 1 then
      return
    end
    self.exchangeNum = self.exchangeNum - 1
    self:setExchangeNum()
  elseif strs[1] == "item" then
    local index = tonumber(strs[2])
    if index then
      local exchangeItemCfg = ItemUtils.GetExchangeItemCfg(self.exchangeId)
      local itemInfo = exchangeItemCfg.needItemList[index]
      if itemInfo and itemInfo.itemId then
        ItemTipsMgr.Instance():ShowBasicTipsWithGO(itemInfo.itemId, clickObj, 0, true)
      end
    end
  end
end
def.method().initExchangeInfo = function(self)
  local Img_Item = self.m_panel:FindDirect("Img_Bg/Img_Item")
  local Btn_Exchange = self.m_panel:FindDirect("Img_Bg/Btn_Exchange")
  local Group_Yuanbao = Btn_Exchange:FindDirect("Group_Yuanbao")
  Group_Yuanbao:SetActive(false)
  if self.isUseYuanbao then
    Img_Item:SetActive(true)
  else
    Img_Item:SetActive(false)
  end
  self:setExchangeNum()
end
def.method().reqItemYubaoPrice = function(self)
  local itemIds = {}
  for i, v in pairs(self.needItems) do
    table.insert(itemIds, i)
  end
  local p = require("netio.protocol.mzm.gsp.item.CReqItemYuanbaoPrice").new(itemIds)
  gmodule.network.sendProtocol(p)
end
def.method().checkExchangeTimes = function(self)
end
def.method().confirmExchange = function(self)
  local exchangeItemCfg = ItemUtils.GetExchangeItemCfg(self.exchangeId)
  local npcExchangeMgr = NpcExchangeMgr.Instance()
  local dailyMaxNum = exchangeItemCfg.dailyExchangeTimesLimit
  if dailyMaxNum > 0 then
    local dailyNum = npcExchangeMgr:getTodayExchangeTimes(self.exchangeId)
    if dailyMaxNum <= dailyNum then
      Toast(textRes.Exchange[6])
      return
    end
  end
  local maxNum = exchangeItemCfg.exchangeTimesLimit
  if maxNum > 0 then
    local exchangeMaxNum = npcExchangeMgr:getExchangeTimes(self.exchangeId)
    if maxNum <= exchangeMaxNum then
      Toast(textRes.Exchange[7])
      return
    end
  end
  local Btn_UseGold = self.m_panel:FindDirect("Img_Bg/Img_Item/Btn_UseGold")
  local Btn_toggle = Btn_UseGold:GetComponent("UIToggle")
  if Btn_toggle.value then
    local ItemModule = require("Main.Item.ItemModule")
    local yuanbaoNum = ItemModule.Instance():GetAllYuanBao()
    if Int64.ToNumber(yuanbaoNum) >= self.needYuabaoNum then
      local p = require("netio.protocol.mzm.gsp.item.CExchangeUseItem").new(self.exchangeId, self.exchangeNum, Int64.new(self.needYuabaoNum))
      gmodule.network.sendProtocol(p)
    else
      _G.GotoBuyYuanbao()
    end
  else
    local itemData = require("Main.Item.ItemData").Instance()
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    local isEnough = true
    for i, v in pairs(self.needItems) do
      local count = itemData:GetNumberByItemId(BagInfo.BAG, i)
      local needNum = v * self.exchangeNum
      if count < needNum then
        isEnough = false
        break
      end
    end
    if isEnough then
      local p = require("netio.protocol.mzm.gsp.item.CExchangeUseItem").new(self.exchangeId, self.exchangeNum, Int64.new(0))
      gmodule.network.sendProtocol(p)
    elseif self.isUseYuanbao then
      local function callback(id)
        if id == 1 then
          local Btn_UseGold = self.m_panel:FindDirect("Img_Bg/Img_Item/Btn_UseGold")
          local Btn_toggle = Btn_UseGold:GetComponent("UIToggle")
          Btn_toggle.value = true
          self:setExchangeYuanbaoNum()
        end
      end
      local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
      CommonConfirmDlg.ShowConfirm("", textRes.activity[398], callback, {self})
    else
      Toast(textRes.activity[403])
    end
  end
end
def.method().setItemInfo = function(self)
  local exchangeItemCfg = ItemUtils.GetExchangeItemCfg(self.exchangeId)
  if exchangeItemCfg == nil then
    warn("!!!!!!error exchangeId:", self.exchangeId)
    return
  end
  local Grid = self.m_panel:FindDirect("Img_Bg/Grid")
  local uilist = Grid:GetComponent("UIList")
  local itemInfos = exchangeItemCfg.needItemList
  uilist.itemCount = #itemInfos
  uilist:Resize()
  self.needItems = {}
  local itemData = require("Main.Item.ItemData").Instance()
  local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
  local canExchangeNum = self.exchangeMaxNum
  for i, v in ipairs(itemInfos) do
    local item = Grid:FindDirect("item_" .. i)
    local Img_ItemIcon = item:FindDirect("Img_ItemIcon")
    local Texture_Icon = Img_ItemIcon:GetComponent("UITexture")
    local itemBase = ItemUtils.GetItemBase(v.itemId)
    GUIUtils.FillIcon(Texture_Icon, itemBase.icon)
    local Label_Number = item:FindDirect("Label_Number"):GetComponent("UILabel")
    local count = itemData:GetNumberByItemId(BagInfo.BAG, v.itemId)
    Label_Number:set_text(count .. "/" .. v.itemNum)
    self.needItems[v.itemId] = v.itemNum
    local num = math.floor(count / v.itemNum)
    if canExchangeNum > num then
      canExchangeNum = num
    end
  end
  self.canExchangeNum = canExchangeNum
end
def.method().setExchangeNum = function(self)
  local Label_Num = self.m_panel:FindDirect("Img_Bg/Label_NumBuy/Btn_Num/Label_Num")
  Label_Num:GetComponent("UILabel"):set_text(self.exchangeNum)
  self:setExchangeYuanbaoNum()
end
def.method().setExchangeYuanbaoNum = function(self)
  local Btn_UseGold = self.m_panel:FindDirect("Img_Bg/Img_Item/Btn_UseGold")
  local Btn_toggle = Btn_UseGold:GetComponent("UIToggle")
  local Group_Yuanbao = self.m_panel:FindDirect("Img_Bg/Btn_Exchange/Group_Yuanbao")
  local Label_Wash = self.m_panel:FindDirect("Img_Bg/Btn_Exchange/Label_Wash")
  if self.isUseYuanbao then
    if Btn_toggle.value then
      Group_Yuanbao:SetActive(true)
      self:calcNeedYuanbaoNum()
      local Label_Money = Group_Yuanbao:FindDirect("Label_Money")
      Label_Money:GetComponent("UILabel"):set_text(self.needYuabaoNum)
      Label_Wash:SetActive(false)
    else
      Group_Yuanbao:SetActive(false)
      Label_Wash:SetActive(true)
    end
  else
    Btn_toggle.value = false
  end
end
def.method().calcNeedYuanbaoNum = function(self)
  if self.itemsPrice then
    local totalPrice = 0
    local itemData = require("Main.Item.ItemData").Instance()
    local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
    for i, v in pairs(self.needItems) do
      local count = itemData:GetNumberByItemId(BagInfo.BAG, i)
      local needNum = v * self.exchangeNum
      if count < needNum then
        local price = self.itemsPrice[i]
        if price then
          totalPrice = totalPrice + price * (needNum - count)
        else
          warn("!!!!!!!!!no item price:", i)
        end
      end
    end
    self.needYuabaoNum = totalPrice
  end
end
return NpcExchangePanel.Commit()
