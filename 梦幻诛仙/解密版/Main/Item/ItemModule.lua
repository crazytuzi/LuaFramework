local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
require("Main.module.ModuleId")
local ItemData = require("Main.Item.ItemData")
local ItemUtils = require("Main.Item.ItemUtils")
local InventoryDlg = require("Main.Item.ui.InventoryDlg")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local GetNewItem = require("Main.Item.ui.GetNewItem")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local SSyncMoneyChange = require("netio.protocol.mzm.gsp.role.SSyncMoneyChange")
local SSyncYuanbaoChange = require("netio.protocol.mzm.gsp.yuanbao.SSyncYuanbaoChange")
local ItemAccessMgr = require("Main.Item.ItemAccessMgr")
local PersonalHelper = require("Main.Chat.PersonalHelper")
local EquipUtils = require("Main.Equip.EquipUtils")
local SSyncCashInfo = require("netio.protocol.mzm.gsp.qingfu.SSyncCashInfo")
local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemModule = Lplus.Extend(ModuleBase, "ItemModule")
local def = ItemModule.define
local _instance
def.const("number").BAG = BagInfo.BAG
def.const("number").EQUIPBAG = BagInfo.EQUIPBAG
def.const("number").GOD_WEAPON_JEWEL_BAG = BagInfo.SUPER_EQUIPMENT_JEWEL_BAG
def.const("number").TREASURE_BAG = BagInfo.TREASURE_BAG
def.const("number").FABAOBAG = BagInfo.FABAO_BAG
def.const("number").CHANGE_MODEL_CARD_BAG = BagInfo.CHANGE_MODEL_CARD_BAG
def.const("number").PET_MARK_BAG = BagInfo.PET_MARK_BAG
local storageBagIds = {}
def.const("table").STORAGEBAGS = storageBagIds
def.const("number").MONEY_TYPE_GOLD = SSyncMoneyChange.MONEY_TYPE_GOLD
def.const("number").MONEY_TYPE_SILVER = SSyncMoneyChange.MONEY_TYPE_SILVER
def.const("number").MONEY_TYPE_GOLD_INGOT = SSyncMoneyChange.MONEY_TYPE_GOLD_INGOT
def.const("number").CASH_SAVE_AMT = SSyncCashInfo.SAVE_AMT
def.const("number").CASH_TOTAL_CASH = SSyncCashInfo.TOTAL_CASH
def.const("number").CASH_TOTAL_COST = SSyncCashInfo.TOTAL_COST
def.const("number").CASH_TOTAL_COST_BIND = SSyncCashInfo.TOTAL_COST_BIND
def.const("number").CASH_PRESENT = SSyncCashInfo.TOTAL_PRESENT
def.const("number").CASH_PRESENT_BIND = SSyncCashInfo.TOTAL_PRESENT_BIND
def.field(InventoryDlg)._dlg = nil
def.field(GetNewItem)._getNewItem = nil
def.static("=>", ItemModule).Instance = function()
  if _instance == nil then
    _instance = ItemModule()
    _instance.m_moduleId = ModuleId.ITEM
    _instance._dlg = InventoryDlg.Instance()
    _instance._getNewItem = GetNewItem()
    _instance._getNewItem.queue = {}
  end
  return _instance
end
def.field(ItemData)._data = nil
def.field("table")._newItemMap = nil
def.field("table")._equipFix = nil
def.field("boolean").syncCash = true
def.field("table")._newTurnedCardItemMap = nil
def.field("table")._newBagItemMap = nil
def.override().Init = function(self)
  self._data = ItemData.Instance()
  ItemAccessMgr.Instance():Init()
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SAllBagInfo", ItemModule._onSAllBagInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SBagChangeInfo", ItemModule._onSBagChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SAllStorageInfo", ItemModule._onSAllStorageInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SStorageChangeInfo", ItemModule._onSStorageChangeInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SCommonErrorInfo", ItemModule._onSCommonErrorInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SExtendBagRes", ItemModule._onSExtendBagRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SSyncMoneyChange", ItemModule._onMoneyChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSynBagAddItem", ItemModule._onSSynBagAddItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.qingfu.SSyncCashInfo", ItemModule._onSSynCashChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.mall.SSynJifen", ItemModule._onSSynCredits)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.role.SUseDrug", ItemModule._onSUseDrug)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SItemCompoundRes", ItemModule._onSItemCompoundRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSplitItemRes", ItemModule._onSSplitItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SFixAllEquipmentsRes", ItemModule._onSEquipFix)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SFixEquipmentRes", ItemModule._onSEquipFix)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseGiftBagItemRes", ItemModule.OnSUseGiftBagItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResItemWithCarryMax", ItemModule.OnItemCarryMax)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SItemCarryMaxErr", ItemModule.OnAwardCarryMax)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSellSilverRes", ItemModule.OnItemSellSilver)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SSellGoldRes", ItemModule.OnItemSellGold)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SBuyGoldSilverRes", ItemModule.OnBuyCurrencyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SBuyGoldIngotRsp", ItemModule.OnBuyCurrencyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SBuyGoldUseInGotRes", ItemModule.OnBuyCurrencyRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.chivalry.SSynAddChivalryNum", ItemModule.OnSSynAddChivalryNum)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.award.SSynAddShengWangNum", ItemModule.OnSSynAddShengWangNum)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SReNameStorageSuccess", ItemModule.OnChangeStorageName)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SOpenNewStorageRes", ItemModule.OnOpenStorageSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseSelectBagItemRes", ItemModule._onSUseSelectBagItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseMoneyBagItemRes", ItemModule._onSUseMoneyBagItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseMarriageSugerItem", ItemModule._onSUseSugerRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SBanTradeRes", ItemModule._onTradingBan)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SEquipRes", ItemModule.OnSEquipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SRoleEquipInfoNotAllowed", ItemModule.OnLookOverFail)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SQueryRoleEquipInfoRes", ItemModule.OnLookOverSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SUseCatItemSuccess", ItemModule.OnSUseCatItemSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SItemClickRemoveSuccess", ItemModule.OnSItemClickRemoveSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SExpBottleGetExpNotify", ItemModule.OnSExpBottleGetExpNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SDoubleItemGetNotify", ItemModule.OnSDoubleItemGetNotify)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SItemCompoundAllRes", ItemModule.OnSItemCompoundAllRes)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_BAG_CLICK, ItemModule._onShow)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, ItemModule._onEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, ItemModule._onEndFight)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_FIGHT_VALUE_CHANGED, ItemModule._onFightPowerChange)
  Event.RegisterEvent(ModuleId.TASK, gmodule.notifyId.task.Task_Item_Changed, ItemModule._onTaskItemUpdate)
  Event.RegisterEvent(ModuleId.WING, gmodule.notifyId.Wing.WINGS_CHANGE, ItemModule._onWingChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ItemModule._onEnterWorld)
  Event.RegisterEvent(ModuleId.LOTTERY, gmodule.notifyId.Lottery.LOTTERY_PANEL_CLOSE, ItemModule._onLotteryClosed)
  Event.RegisterEvent(ModuleId.FASHION, gmodule.notifyId.Fashion.FashionFunctionUnlock, ItemModule._OnFashionUnlock)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Get_NewOne, ItemModule.OnItemGetNewOne)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  local storageIds = ItemUtils.GetAllStorageId()
  for _, v in ipairs(storageIds) do
    table.insert(storageBagIds, v)
  end
  require("Main.Item.ItemPriceHelper").Init()
  require("Main.Item.AutoUsing.AutoUsingMgr").Instance():Init()
  print("ItemModule Init done")
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  self._data:Clear()
  self._newItemMap = nil
  self._newTurnedCardItemMap = nil
  self._newBagItemMap = nil
  if self._dlg then
    self._dlg:Clear()
  end
  self.syncCash = true
  local EasyUseDlg = require("Main.Item.ui.EasyUseDlg")
  EasyUseDlg.CloseAll()
end
def.static("table").OnSSynAddChivalryNum = function(p)
  if p.addNum <= 0 then
    Toast(textRes.Item[144])
  else
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    local jifenAward = {}
    table.insert(jifenAward, {
      PersonalHelper.Type.Text,
      textRes.Item[143]
    })
    table.insert(jifenAward, {
      PersonalHelper.Type.Xiayi,
      p.addNum
    })
    PersonalHelper.CommonTableMsg(jifenAward)
  end
end
def.static("table").OnSSynAddShengWangNum = function(p)
  if p.addNum <= 0 then
    Toast(textRes.Item[145])
  else
    local PersonalHelper = require("Main.Chat.PersonalHelper")
    local jifenAward = {}
    table.insert(jifenAward, {
      PersonalHelper.Type.Text,
      textRes.Item[143]
    })
    table.insert(jifenAward, {
      PersonalHelper.Type.Xiayi,
      p.addNum
    })
    PersonalHelper.CommonTableMsg(jifenAward)
  end
end
def.static("table")._onSAllBagInfo = function(p)
  local data = ItemModule.Instance()._data
  for bagId, bag in pairs(p.bags) do
    data:SetBag(bagId, bag.capacity, "")
    for itemKey, item in pairs(bag.items) do
      data:SetItem(bagId, itemKey, item.id, itemKey, item.number, Int64.new(), 0, item.flag, item.extraMap, item.exproList, item.uuid, item.fumoProList, item.extraProps, item.extraInfoMap, item.super_equipment_cost_bean, item.jewelMap)
    end
    if bagId == ItemModule.BAG then
      local leftcap = data:GetBagCapacity(ItemModule.BAG) - data:GetBagSize(ItemModule.BAG)
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_BagLeftCapacityChanged, {left = leftcap})
    end
  end
end
def.static("table")._onSBagChangeInfo = function(p)
  print("_onSBagChangeInfo")
  local equipChange = false
  local data = ItemModule.Instance()._data
  local oldleftcap = data:GetBagCapacity(ItemModule.BAG) - data:GetBagSize(ItemModule.BAG)
  local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
  for itemKey, value in pairs(p.data.removed) do
    if p.data.bagid == ItemModule.EQUIPBAG then
      local item = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.EQUIPBAG, itemKey)
      if item and itemKey ~= WearPos.AIRCRAFT then
        local itemBase = ItemUtils.GetItemBase(item.id)
        local color = EquipUtils.GetEquipDynamicColor(item, nil, itemBase)
        Toast(string.format(textRes.Item[140], require("Main.Chat.HtmlHelper").NameColor[color], ItemUtils.GetItemName(item, itemBase)))
      end
    end
    data:RemoveItem(p.data.bagid, itemKey)
  end
  local chgItems = {}
  for itemKey, item in pairs(p.data.changed) do
    do
      local bAddNewItem = false
      if p.data.bagid == ItemModule.BAG then
        local oldItem = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.BAG, itemKey)
        if oldItem then
          bAddNewItem = oldItem.number < item.number
        else
          bAddNewItem = true
        end
      end
      if p.data.bagid == ItemModule.EQUIPBAG then
        local itemOld = ItemModule.Instance():GetItemByBagIdAndItemKey(ItemModule.EQUIPBAG, itemKey)
        if itemOld == nil or itemOld.id ~= item.id then
          local itemBase = ItemUtils.GetItemBase(item.id)
          local color = EquipUtils.GetEquipDynamicColor(item, nil, itemBase)
          Toast(string.format(textRes.Item[139], require("Main.Chat.HtmlHelper").NameColor[color], ItemUtils.GetItemName(item, itemBase)))
          if itemOld ~= nil and itemOld.id ~= item.id then
            do
              local uuid = itemOld.uuid[1]
              GameUtil.AddGlobalTimer(0.5, true, function()
                local key = ItemModule.Instance():GetItemByUUID(uuid, ItemModule.BAG)
                if key ~= -1 then
                  local EquipModule = require("Main.Equip.EquipModule")
                  EquipModule.ShowInheritConfirmDlg(uuid, key, ItemModule.BAG, item)
                end
              end)
            end
          end
        end
      end
      data:SetItem(p.data.bagid, itemKey, item.id, itemKey, item.number, Int64.new(), 0, item.flag, item.extraMap, item.exproList, item.uuid, item.fumoProList, item.extraProps, item.extraInfoMap, item.super_equipment_cost_bean, item.jewelMap)
      if p.data.bagid == ItemModule.BAG and bAddNewItem then
        table.insert(chgItems, {item = item, itemKey = itemKey})
      end
    end
  end
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, {
    bagId = p.data.bagid,
    chgItems = chgItems
  })
  if p.data.bagid == ItemModule.BAG then
    local leftcap = data:GetBagCapacity(ItemModule.BAG) - data:GetBagSize(ItemModule.BAG)
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_BagLeftCapacityChanged, {left = leftcap})
    if leftcap == 0 and oldleftcap > 0 then
      Toast(textRes.Item[32])
    end
  elseif p.data.bagid == ItemModule.EQUIPBAG then
    local broken = _instance:CheckEquipBroken()
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Equip_Broken_Update, {broken = broken})
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, {
      bagId = p.data.bagid
    })
  elseif p.data.bagid == ItemModule.GOD_WEAPON_JEWEL_BAG then
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_GodWeapon_Bag_Change, {
      bagId = p.data.bagid
    })
  elseif p.data.bagid == ItemModule.TREASURE_BAG then
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Treasure_Bag_Change, {
      bagId = p.data.bagid
    })
  end
end
def.static("table")._onSAllStorageInfo = function(p)
  print("_onSAllStorageInfo")
  local data = ItemModule.Instance()._data
  for bagId, bag in pairs(p.storages) do
    data:SetBag(bagId, bag.capacity, bag.name)
    for itemKey, item in pairs(bag.items) do
      data:SetItem(bagId, itemKey, item.id, itemKey, item.number, Int64.new(), 0, item.flag, item.extraMap, item.exproList, item.uuid, item.fumoProList, item.extraProps, item.extraInfoMap, item.super_equipment_cost_bean, item.jewelMap)
    end
  end
end
def.static("table")._onSStorageChangeInfo = function(p)
  print("_onSStorageChangeInfo")
  local data = ItemModule.Instance()._data
  for itemKey, value in pairs(p.data.removed) do
    data:RemoveItem(p.data.bagid, itemKey)
  end
  for itemKey, item in pairs(p.data.changed) do
    data:SetItem(p.data.bagid, itemKey, item.id, itemKey, item.number, Int64.new(), 0, item.flag, item.extraMap, item.exproList, item.uuid, item.fumoProList, item.extraProps, item.extraInfoMap, item.super_equipment_cost_bean, item.jewelMap)
  end
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateStorage()
  end
end
def.static("table", "table")._onTaskItemUpdate = function(p1, p2)
  print("_onTaskItemUpdate")
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
end
def.static("table", "table")._onWingChange = function(p1, p2)
  print("_onWingChange")
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
end
def.static("table", "table")._onLotteryClosed = function(params, context)
  print("_onLotteryClosed")
  if params.lotteryItemId ~= 0 then
    local items = _instance:GetItemsByItemID(ItemModule.BAG, params.lotteryItemId)
    if items == nil then
      return
    end
    local bagCap = _instance:GetBagCapacity()
    for key = 0, bagCap do
      if items[key] ~= nil then
        _instance:OpenInventoryDlgToKey(key)
        break
      end
    end
  end
end
def.static("table")._onSCommonErrorInfo = function(p)
  if p.errorCode == p.SPECIFIC_BAG_GRID_NOT_ENOUGH or p.errorCode == p.SPECIFIC_BAG_FULL then
    local bagId = tonumber(p.params[1])
    if bagId and textRes.Item[bagId] then
      Toast(string.format(textRes.Item[13002], textRes.Item[bagId]))
    end
    return
  end
  if p.errorCode == p.ITEM_OPER_USECOUNT_WRONG then
    local itemId = tonumber(p.params[1])
    local num = tonumber(p.params[2])
    local itemBase = ItemUtils.GetItemBase(itemId)
    local name = itemBase.name
    local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
    Toast(string.format(textRes.Item[8339], color, name, num))
    return
  end
  if textRes.ItemCommonError[p.errorCode] ~= nil then
    Toast(textRes.ItemCommonError[p.errorCode])
  end
end
def.static("table")._onSExtendBagRes = function(p)
  print("_onSExtendBagRes")
  local data = ItemModule.Instance()._data
  data:SetBag(p.bagid, p.capcity, "")
  if ItemModule.Instance()._dlg.m_panel and p.bagid == ItemModule.BAG then
    ItemModule.Instance()._dlg:ResetBagCapacity()
    ItemModule.Instance()._dlg:UpdateBag()
    local leftcap = data:GetBagCapacity(ItemModule.BAG) - data:GetBagSize(ItemModule.BAG)
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_BagLeftCapacityChanged, {left = leftcap})
    if leftcap == 0 then
      Toast(textRes.Item[32])
    end
  end
end
def.static("table")._onMoneyChange = function(p)
  print("_onMoneyChange")
  local data = ItemModule.Instance()._data
  for k, v in pairs(p.changeMoneyMap) do
    local yuanbao = data:GetMoney(k)
    if yuanbao ~= nil and v > yuanbao then
      ItemModule.Instance()._getNewItem:GetMoney(k)
    end
    data:SetMoney(k, v)
    if k == ItemModule.MONEY_TYPE_GOLD then
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldChanged, {value = v})
    elseif k == ItemModule.MONEY_TYPE_SILVER then
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_SilverChanged, {value = v})
    elseif k == ItemModule.MONEY_TYPE_GOLD_INGOT then
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Money_GoldIngotChanged, {value = v})
    end
  end
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
end
def.static("table")._onSSynYuanbaoChange = function(p)
  print("_onSSynYuanbaoChange")
  local data = ItemModule.Instance()._data
  for k, v in pairs(p.yuanbaoChangeMap) do
    local yuanbao = data:GetYuanbao(k)
    if yuanbao ~= nil and v > yuanbao and k ~= ItemModule.YUANBAO_TYPE_HISTORY then
      ItemModule.Instance()._getNewItem:GetMoney(2)
    end
    data:SetYuanbao(k, v)
    if k == ItemModule.YUANBAO_TYPE_AWARD then
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, {value = v})
    elseif k == ItemModule.YUANBAO_TYPE_BUY then
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, {value = v})
    elseif k == ItemModule.YUANBAO_TYPE_HISTORY then
      Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_HistoryChanged, {value = v})
    end
  end
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
end
def.static("table")._onSSynCashChange = function(p)
  print("_onSSynCashChange")
  local data = ItemModule.Instance()._data
  local oldBind = data:GetYuanbao(ItemModule.CASH_PRESENT_BIND) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND)
  local oldCash = data:GetYuanbao(ItemModule.CASH_TOTAL_CASH) + data:GetYuanbao(ItemModule.CASH_PRESENT) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST)
  local oldHistory = data:GetYuanbao(ItemModule.CASH_TOTAL_CASH)
  for k, v in pairs(p.infos) do
    print("CASH:", k, v)
    data:SetYuanbao(k, v)
  end
  local newBind = data:GetYuanbao(ItemModule.CASH_PRESENT_BIND) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND)
  local newCash = data:GetYuanbao(ItemModule.CASH_TOTAL_CASH) + data:GetYuanbao(ItemModule.CASH_PRESENT) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST)
  local newHistory = data:GetYuanbao(ItemModule.CASH_TOTAL_CASH)
  if newBind ~= oldBind then
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_AwardChanged, {value = newBind})
  end
  if newCash ~= oldCash then
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_BuyChanged, {value = newCash})
  end
  if newHistory ~= oldHistory then
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Yuanbao_HistoryChanged, {value = oldHistory})
    if not ItemModule.Instance().syncCash then
      Toast(textRes.Pay[2])
    end
  end
  if newBind + newCash > oldBind + oldCash and not ItemModule.Instance().syncCash then
    ItemModule.Instance()._getNewItem:GetMoney(3)
  end
  ItemModule.Instance().syncCash = false
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
end
def.static("table")._onSSynCredits = function(p)
  print("_onSSynCredits")
  local data = ItemModule.Instance()._data
  for k, v in pairs(p.jifen) do
    data:SetCredits(k, v)
  end
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Credit_Change, data._credits)
end
def.static("table")._onSUseDrug = function(data)
  print("OnSUseDrug")
  if data.collisionBuffId ~= nil then
    local BuffUtils = require("Main.Buff.BuffUtility")
    local oldBuff = BuffUtils.GetBuffCfg(data.collisionBuffId)
    local newBuff = BuffUtils.GetBuffCfg(data.drugBuffId)
    local title = textRes.Buff[8]
    local doReplace = string.format(textRes.Buff[1], newBuff.name, oldBuff.name)
    CommonConfirmDlg.ShowConfirm(title, doReplace, ItemModule.BuffConfirmCallback, {
      bagId = data.bagid,
      itemKey = data.itemKey
    })
  end
end
def.static("table")._onSSynBagAddItem = function(p)
  local bagId = ItemModule.Instance():GetBagIdByItemId(p.itemid)
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Get_NewOne, {
    keyList = p.grids,
    itemId = p.itemid,
    itemNum = p.count,
    bagId = bagId
  })
  if bagId == ItemModule.BAG then
    for k, v in pairs(p.grids) do
      ItemModule.Instance():SetItemNew(v, true)
    end
    ItemModule.Instance()._getNewItem:GetItem(p.itemid)
    GameUtil.AddGlobalTimer(1, true, function()
      for k, v in pairs(p.grids) do
        ItemModule.Instance():TryEasyUse(p.itemid, v)
      end
    end)
  elseif bagId == ItemModule.FABAOBAG then
    ItemModule.Instance()._getNewItem:GetFabao(p.itemid)
  elseif bagId == ItemModule.CHANGE_MODEL_CARD_BAG then
    for k, v in pairs(p.grids) do
      ItemModule.Instance():SetTurnedCardItemNew(v, true)
    end
    ItemModule.Instance()._getNewItem:GetCard(p.itemid)
    Event.DispatchEvent(ModuleId.TURNED_CARD, gmodule.notifyId.TurnedCard.Turned_CArd_Item_Red_Point_Change, nil)
  elseif bagId == ItemModule.PET_MARK_BAG then
    for k, v in pairs(p.grids) do
      ItemModule.Instance():SetBagItemNew(ItemModule.PET_MARK_BAG, v, true)
    end
    ItemModule.Instance()._getNewItem:GetPetMark(p.itemid)
  elseif bagId == ItemModule.TREASURE_BAG then
    for k, v in pairs(p.grids) do
      ItemModule.Instance():SetBagItemNew(ItemModule.TREASURE_BAG, v, true)
    end
    ItemModule.Instance()._getNewItem:GetItem(p.itemid)
  else
    ItemModule.Instance()._getNewItem:GetItem(p.itemid)
  end
end
def.static("table")._onSItemCompoundRes = function(p)
  print("_onSItemCompoundRes")
  local itemId = p.itemid
  local itemKey = p.itemkey
  local itemBase = ItemUtils.GetItemBase(itemId)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Item[8304], PersonalHelper.Type.ItemMap, {
    [itemId] = 1
  })
  if itemBase.itemType == ItemType.CHANGE_MODEL_CARD_ITEM or itemBase.itemType == ItemType.CHANGE_MODEL_CARD_FRAGMENT then
    return
  end
  _instance:OpenInventoryDlgToKey(itemKey)
end
def.static("table")._onSSplitItemRes = function(p)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Item[12106], PersonalHelper.Type.ItemMap, p.acquired_items)
end
def.static("table")._onSWingXilianRes = function(p)
  print("_onSWingXilianRes")
  local SkillUtils = require("Main.Skill.SkillUtility")
  local skill1 = p.skillid1
  local skill2 = p.skillid2
  local skillStr = ""
  if skill1 > 0 then
    local skillCfg = SkillUtils.GetSkillCfg(skill1)
    if skillCfg then
      skillStr = skillStr .. string.format("<font color=#00ff00>[%s]</font>", skillCfg.name)
    end
  end
  if skill2 > 0 then
    local skillCfg = SkillUtils.GetSkillCfg(skill2)
    if skillCfg then
      skillStr = skillStr .. string.format("<font color=#00ff00>[%s]</font>", skillCfg.name)
    end
  end
  Toast(textRes.Item[8327] .. skillStr)
end
def.static("table")._onSEquipFix = function(p)
  GameUtil.AddGlobalLateTimer(0.5, true, function()
    Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Equip_Broken_Update, {broken = false})
  end)
  Toast(textRes.Item[8345])
end
def.static("table").OnItemCarryMax = function(p)
  local itemId = p.itemid
  local carryMax = p.carrymax
  local addNum = p.addnum
  local itemBase = ItemUtils.GetItemBase(itemId)
  local name = itemBase.name
  local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
  Toast(string.format(textRes.Item[8338], color, name, carryMax))
end
def.static("table").OnAwardCarryMax = function(p)
  local itemId = p.itemId
  local itemBase = ItemUtils.GetItemBase(itemId)
  local name = itemBase.name
  local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
  Toast(string.format(textRes.Item[8366], color, name))
end
def.static("table").OnItemSellSilver = function(p)
  local silver = p.silvernum
  if silver > 0 then
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Item[8346], PersonalHelper.Type.Silver, Int64.new(silver))
  end
end
def.static("table").OnItemSellGold = function(p)
  local gold = p.goldnum
  if gold > 0 then
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Item[8346], PersonalHelper.Type.Gold, Int64.new(gold))
  end
end
def.static("table").OnBuyCurrencyRes = function(p)
  Toast(textRes.GetMoney[6])
end
def.static("table").OnChangeStorageName = function(p)
  local data = ItemModule.Instance()._data
  data:SetBag(p.storageid, -1, p.name)
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateStorage()
  end
end
def.static("table").OnOpenStorageSuccess = function(p)
  local data = ItemModule.Instance()._data
  data:SetBag(p.storageid, p.capacity, p.name)
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    for k, v in ipairs(ItemModule.STORAGEBAGS) do
      if v == p.storageid then
        ItemModule.Instance()._dlg.storageIndex = k
        break
      end
    end
    ItemModule.Instance()._dlg:UpdateStorage()
  end
end
def.static("table")._onSUseSelectBagItemRes = function(p)
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Use_Selectable_Bag_Item_Res, {
    p.itemid,
    p.num
  })
end
def.static("table")._onSUseMoneyBagItemRes = function(p)
  local moneyType = p.moneytype
  local moneyCount = p.num
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.GetMoneyMsgByType(moneyType, tostring(moneyCount))
end
def.static("table")._onSUseSugerRes = function(p)
  local bagFull = p.isBagFull
  if bagFull == p.BAG_NOT_FULL then
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Item[161], PersonalHelper.Type.ItemMap, p.item2count)
  elseif bagFull == p.BAG_FULL then
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, textRes.Item[161], PersonalHelper.Type.ItemMap, p.item2count, PersonalHelper.Type.Text, textRes.Item[162])
  end
end
def.static("table").OnLookOverFail = function(p)
  Toast(textRes.Item[200])
end
def.static("table").OnLookOverSuccess = function(p)
  warn("OnLookOverSuccess")
  require("Main.Item.ui.LookOverEquip").ShowCharactorEquipInfo(p)
end
def.static("table")._onTradingBan = function(p)
  local ChatMsgBuilder = require("Main.Chat.ChatMsgBuilder")
  local name = ChatMsgBuilder.Unmarshal(p.name)
  Toast(string.format(textRes.Item[208], name))
end
def.static("table", "table")._onEnterWorld = function(params, context)
  local broken = _instance:CheckEquipBroken()
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Equip_Broken_Update, {broken = broken})
end
def.static("table", "table")._onShow = function(params, context)
  if _instance._dlg.m_panel == nil then
    _instance._dlg:CreatePanel(RESPATH.DLG_INVENTORY, 1)
    _instance._dlg:SetModal(true)
    local full = _instance:IsBagFull(ItemModule.BAG)
    if full then
      Toast(textRes.Item[32])
    end
  else
    _instance._dlg:DestroyPanel()
  end
end
def.static("table", "table")._onEnterFight = function(params, context)
end
def.static("table", "table")._onEndFight = function(params, context)
end
def.static("table", "table")._onFightPowerChange = function(params, context)
  print("_onFightPowerChange")
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateAutomatic()
  end
end
def.method("=>", "number").GetCurrentStorage = function(self)
  if self._dlg and self._dlg:IsShow() then
    local index = self._dlg:GetCurrentStorageIndex()
    local storageId = ItemModule.STORAGEBAGS[index]
    return storageId or 0
  else
    return 0
  end
end
def.method("number", "=>", "number").GetBagIdByItemId = function(self, itemId)
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase then
    return self:GetBagIdByItemType(itemBase.itemType)
  else
    return ItemModule.BAG
  end
end
def.method("number", "=>", "number").GetBagIdByItemType = function(self, itemType)
  local bagId = ItemUtils.GetBagIdByItemType(itemType)
  if bagId == 0 then
    return ItemModule.BAG
  else
    return bagId
  end
end
def.method("number", "=>", "number").GetItemCountById = function(self, itemId)
  local data = self._data
  local bagId = self:GetBagIdByItemId(itemId)
  local num = data:GetNumberByItemId(bagId, itemId)
  return num
end
def.method("number", "=>", "userdata").GetMoney = function(self, type)
  local data = self._data
  local num = data:GetMoney(type)
  return num
end
def.method("number", "=>", "userdata").GetYuanbao = function(self, type)
  local data = self._data
  local num = data:GetYuanbao(type)
  return num
end
def.method("number", "=>", "userdata").GetCredits = function(self, type)
  local data = self._data
  local num = data:GetCredits(type)
  return num
end
def.method("=>", "userdata").getBindYuanBao = function(self)
  local data = self._data
  local bind = data:GetYuanbao(ItemModule.CASH_PRESENT_BIND) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND)
  return bind
end
def.method("=>", "userdata").getCashYuanBao = function(self)
  local data = self._data
  local cash = data:GetYuanbao(ItemModule.CASH_TOTAL_CASH) + data:GetYuanbao(ItemModule.CASH_PRESENT) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST)
  return cash
end
def.method("=>", "userdata").GetAllYuanBao = function(self)
  local data = self._data
  local bind = data:GetYuanbao(ItemModule.CASH_PRESENT_BIND) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST_BIND)
  local cash = data:GetYuanbao(ItemModule.CASH_TOTAL_CASH) + data:GetYuanbao(ItemModule.CASH_PRESENT) - data:GetYuanbao(ItemModule.CASH_TOTAL_COST)
  return bind + cash
end
def.method("=>", "number").GetBagCapacity = function(self)
  local data = self._data
  local cap = data:GetBagCapacity(ItemModule.BAG)
  return cap
end
def.method("=>", "number").GetBagLeftSize = function(self)
  local data = self._data
  return data:GetBagCapacity(ItemModule.BAG) - data:GetBagSize(ItemModule.BAG)
end
def.method("number", "=>", "number").GetBagLeftSizeByBagId = function(self, bagId)
  local data = self._data
  return data:GetBagCapacity(bagId) - data:GetBagSize(bagId)
end
def.method("=>", "number", "number").GetMinBagLeftSize = function(self)
  local data = self._data
  local bagToCheck = {
    ItemModule.BAG,
    ItemModule.GOD_WEAPON_JEWEL_BAG,
    ItemModule.FABAOBAG
  }
  local min = math.huge
  local bagId = ItemModule.BAG
  for k, v in ipairs(bagToCheck) do
    local left = data:GetBagCapacity(v) - data:GetBagSize(v)
    if min > left then
      min = left
      bagId = v
    end
    if min == 0 then
      break
    end
  end
  return min, bagId
end
def.method("=>", "number").GetJewelBagCapacity = function(self)
  local data = self._data
  local cap = data:GetBagCapacity(ItemModule.GOD_WEAPON_JEWEL_BAG)
  return cap
end
def.method().GetJewelBagLeftCapacity = function(self)
  local data = self._data
  return data:GetBagCapacity(ItemModule.GOD_WEAPON_JEWEL_BAG) - data:GetBagSize(ItemModule.GOD_WEAPON_JEWEL_BAG)
end
def.method("=>", "number").GetTreasureBagCapacity = function(self)
  local data = self._data
  local cap = data:GetBagCapacity(ItemModule.TREASURE_BAG)
  return cap
end
def.method().GetTreasureBagLeftCapacity = function(self)
  local data = self._data
  return data:GetBagCapacity(ItemModule.TREASURE_BAG) - data:GetBagSize(ItemModule.TREASURE_BAG)
end
def.method("=>", "number").GetTaskItemCapacity = function(self)
  return 25
end
def.method("=>", "table").GetHeroEquipments = function(self)
  local data = self._data
  local bag = data:GetBag(ItemModule.EQUIPBAG)
  return bag
end
def.method("number", "=>", "table").GetHeroEquipmentCfg = function(self, wearPos)
  local data = self._data
  local key, item = data:GetItemByPosition(ItemModule.EQUIPBAG, wearPos)
  if key ~= -1 then
    return item
  end
  return nil
end
def.method("number", "=>", "table").GetBrokenEquipsByBagID = function(self, bagId)
  local data = self._data
  return data:GetBrokenEquipsByBagID(bagId)
end
def.method("number", "=>", "table").GetItemsByBagId = function(self, bagId)
  local data = self._data
  local bag = data:GetBag(bagId)
  return bag
end
def.method("number", "=>", "table").GetOrderedItemsByBagId = function(self, bagId)
  local data = self._data
  local bag = data:GetBag(bagId)
  local itemList = {}
  for itemKey, item in pairs(bag) do
    table.insert(itemList, item)
  end
  table.sort(itemList, function(left, right)
    return left.itemKey < right.itemKey
  end)
  return itemList
end
def.method("number", "number", "=>", "table").GetItemByBagIdAndItemKey = function(self, bagId, itemKey)
  local data = self._data
  local item = data:GetItem(bagId, itemKey)
  return item
end
def.method("=>", "table").GetItems = function(self)
  local data = self._data
  local bag = data:GetBag(ItemModule.BAG)
  return bag
end
def.method("=>", "table").GetAllItems = function(self)
  local data = self._data
  local bag = {}
  bag[ItemModule.BAG] = data:GetBag(ItemModule.BAG)
  bag[ItemModule.GOD_WEAPON_JEWEL_BAG] = data:GetBag(ItemModule.GOD_WEAPON_JEWEL_BAG)
  bag[ItemModule.FABAOBAG] = data:GetBag(ItemModule.FABAOBAG)
  bag[ItemModule.TREASURE_BAG] = data:GetBag(ItemModule.TREASURE_BAG)
  return bag
end
def.method("number", "=>", "table").GetStorages = function(self, index)
  local data = self._data
  local storageId = ItemModule.STORAGEBAGS[index]
  if storageId then
    local bag = data:GetBag2(ItemModule.STORAGEBAGS[index])
    return bag
  else
    return nil
  end
end
def.method("number", "number", "=>", "number", "table").GetItemByPosition = function(self, bagId, position)
  local data = self._data
  local key, item = data:GetItemByPosition(bagId, position)
  return key, item
end
def.method("number", "number", "=>", "table").GetItemsByItemType = function(self, bagId, itemType)
  local data = self._data
  local items = data:GetItemsByItemType(bagId, itemType)
  return items
end
def.method("number", "number", "=>", "table").GetItemsByItemID = function(self, bagId, itemID)
  local data = self._data
  local items = data:GetItemsByItemID(bagId, itemID)
  return items
end
def.method("number", "table", "=>", "table").GetItemsByItemIds = function(self, bagId, ids)
  local data = self._data
  local items = data:GetItemsByItemIds(bagId, ids)
  return items
end
def.method("number", "number", "=>", "number").GetNumberByItemId = function(self, bagId, id)
  local data = self._data
  local count = data:GetNumberByItemId(bagId, id)
  return count
end
def.method("number", "number", "=>", "number").GetNumByItemType = function(self, bagId, itemType)
  local data = self._data
  local count = data:GetNumByItemType(bagId, itemType)
  return count
end
def.method("number", "number", "boolean", "=>", "table").GetItemsByItemTypeIgnoreTimeEffect = function(self, bagId, itemType, ignore)
  local data = self._data
  local items = data:GetItemsByItemTypeIgnoreTimeEffect(bagId, itemType, ignore)
  return items
end
def.method("number", "number", "boolean", "=>", "table").GetItemsByItemIDIgnoreTimeEffect = function(self, bagId, itemID, ignore)
  local data = self._data
  local items = data:GetItemsByItemIDIgnoreTimeEffect(bagId, itemID, ignore)
  return items
end
def.method("number", "number", "boolean", "=>", "number").GetNumberByItemIdIgnoreTimeEffect = function(self, bagId, id, ignore)
  local data = self._data
  local count = data:GetNumberByItemIdIgnoreTimeEffect(bagId, id, ignore)
  return count
end
def.method("number", "number", "boolean", "=>", "number").GetNumByItemTypeIgnoreTimeEffect = function(self, bagId, itemType, ignore)
  local data = self._data
  local count = data:GetNumByItemTypeIgnoreTimeEffect(bagId, itemType, ignore)
  return count
end
def.method("number", "number", "=>", "number", "table").SelectOneItemByItemType = function(self, bagId, itemType)
  local data = self._data
  return data:SelectOneItemByItemType(bagId, itemType)
end
def.method("number", "number", "=>", "number", "table").SelectOneItemByItemId = function(self, bagId, itemId)
  local data = self._data
  return data:SelectOneItemByItemId(bagId, itemId)
end
def.method("number", "=>", "number", "table").SearchOneItemByItemType = function(self, itemType)
  local data = self._data
  local bagId = self:GetBagIdByItemType(itemType)
  return data:SelectOneItemByItemType(bagId, itemType)
end
def.method("number", "=>", "number", "table").SearchOneItemByItemId = function(self, itemId)
  local data = self._data
  local bagId = self:GetBagIdByItemId(itemId)
  return data:SelectOneItemByItemId(bagId, itemId)
end
def.method("number", "=>", "boolean").IsBagItemCanClickToRemove = function(self, itemKey)
  local key, item = self:GetItemByPosition(ItemModule.BAG, itemKey)
  if key == -1 or item == nil then
    return false
  end
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local itemId = item.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  if ItemUtils.IsTimeEffectItem(itemId) and ItemUtils.IsItemOutOfTime(item) then
    return true
  end
  if itemBase.itemType == ItemType.EXP_BOTTLE_ITEM then
    local curExp = item.extraMap[ItemXStoreType.LEFT_BOTTLE_EXP_VALUE] or 0
    local totalExp = item.extraMap[ItemXStoreType.TOTAL_BOTTLE_EXP_VALUE] or 0
    if totalExp ~= 0 and curExp == 0 then
      return true
    end
    return false
  end
  if itemBase.itemType == ItemType.DOUBLE_ITEM then
    local curTimes = item.extraMap[ItemXStoreType.LEFT_DOUBLE_ITEM_USE_TIMES] or 0
    if curTimes <= 0 then
      return true
    end
    return false
  end
  return false
end
def.method().ClearItemNew = function(self)
  self._newItemMap = {}
end
def.method("number", "boolean").SetItemNew = function(self, itemKey, isNew)
  if self._newItemMap == nil then
    self._newItemMap = {}
  end
  if isNew == true then
    self._newItemMap[itemKey] = true
  else
    self._newItemMap[itemKey] = nil
  end
end
def.method("number", "=>", "boolean").GetItemNew = function(self, itemKey)
  if self._newItemMap == nil then
    return false
  end
  if self._newItemMap[itemKey] then
    return self._newItemMap[itemKey]
  else
    return false
  end
end
def.method().ClearTurnedCardItemNew = function(self)
  self._newTurnedCardItemMap = {}
end
def.method("number", "boolean").SetTurnedCardItemNew = function(self, itemKey, isNew)
  if self._newTurnedCardItemMap == nil then
    self._newTurnedCardItemMap = {}
  end
  if isNew then
    self._newTurnedCardItemMap[itemKey] = true
  else
    self._newTurnedCardItemMap[itemKey] = nil
  end
end
def.method("number", "=>", "boolean").GetTurnedCardItemNew = function(self, itemKey)
  if self._newTurnedCardItemMap == nil then
    return false
  end
  if self._newTurnedCardItemMap[itemKey] then
    return true
  end
  return false
end
def.method("number").ClearBagItemNew = function(self, bagId)
  if self._newBagItemMap == nil then
    return
  end
  self._newBagItemMap[bagId] = {}
end
def.method("number", "number", "boolean").SetBagItemNew = function(self, bagId, itemKey, isNew)
  if self._newBagItemMap == nil then
    self._newBagItemMap = {}
  end
  if self._newBagItemMap[bagId] == nil then
    self._newBagItemMap[bagId] = {}
  end
  if isNew == true then
    self._newBagItemMap[bagId][itemKey] = true
  else
    self._newBagItemMap[bagId][itemKey] = nil
  end
end
def.method("number", "number", "=>", "boolean").GetBagItemNew = function(self, bagId, itemKey)
  if self._newBagItemMap == nil then
    return false
  end
  if self._newBagItemMap[bagId] == nil then
    return false
  end
  if self._newBagItemMap[bagId][itemKey] then
    return self._newBagItemMap[bagId][itemKey]
  else
    return false
  end
end
def.method("number").ExtendStorage = function(self, storageIndex)
  local storageId = ItemModule.STORAGEBAGS[storageIndex]
  if storageId then
    do
      local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
      local storageCfg = ItemUtils.GetStorageCfg(storageId)
      local type = storageCfg.moneyType
      local num = storageCfg.num
      local moneyName = textRes.Item.MoneyName[type]
      local haveNum = 0
      if type == MoneyType.YUANBAO then
        haveNum = self:GetAllYuanBao()
      elseif type == MoneyType.GOLD then
        haveNum = self:GetMoney(ItemModule.MONEY_TYPE_GOLD)
      elseif type == MoneyType.SILVER then
        haveNum = self:GetMoney(ItemModule.MONEY_TYPE_SILVER)
      elseif type == MoneyType.GANGCONTRIBUTE then
        local GangModule = require("Main.Gang.GangModule")
        local bHasGang = GangModule.Instance():HasGang()
        if bHasGang == false then
          Toast(textRes.Item[136])
          return
        else
          local bangGong = GangModule.Instance():GetHeroCurBanggong()
          haveNum = Int64.new(bangGong)
        end
      end
      CommonConfirmDlg.ShowConfirm(textRes.Item[151], string.format(textRes.Item[150], num, moneyName), function(select)
        if select == 1 then
          local open = require("netio.protocol.mzm.gsp.item.COpenNewStorage").new(haveNum)
          gmodule.network.sendProtocol(open)
        end
      end, nil)
    end
  end
end
def.method("number", "userdata").TryExtendBag = function(self, bagId, uuid)
  local data = self._data
  local curCap = data:GetBagCapacity(bagId)
  local bagCfg = DynamicData.GetRecord(CFG_PATH.DATA_BAGCFG, bagId)
  local maxCap = bagCfg:GetIntValue("maxcapacity")
  if curCap >= maxCap then
    Toast(textRes.Item[164])
    return
  end
  local initCap = bagCfg:GetIntValue("initcapacity")
  local addCount = bagCfg:GetIntValue("addCount")
  local extendItemId = bagCfg:GetIntValue("extendItemId")
  local extendTimes = (curCap - initCap) / addCount + 1
  local bagExtendCfg = DynamicData.GetTable(CFG_PATH.DATA_EXTENDBAGCFG)
  local count = DynamicDataTable.GetRecordsCount(bagExtendCfg)
  for i = 0, count - 1 do
    local cfg = DynamicDataTable.GetRecordByIdx(bagExtendCfg, i)
    local cfgBagId = cfg:GetIntValue("bagId")
    local extendCount = cfg:GetIntValue("extendCount")
    if extendCount == extendTimes and cfgBagId == bagId then
      local itemNeed = cfg:GetIntValue("itemCount")
      local title = string.format(textRes.Item[21], textRes.Item[bagId])
      local desc = string.format(textRes.Item[22], addCount, textRes.Item[bagId])
      local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
      ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
        if select < 0 then
        elseif select == 0 then
          if uuid == nil then
            ItemModule.ExtendBag(bagId, 0, _instance:GetAllYuanBao())
          else
            ItemModule.ExtendBagWithUUID(bagId, uuid)
          end
        elseif uuid == nil then
          ItemModule.ExtendBag(bagId, 1, _instance:GetAllYuanBao())
        else
          ItemModule.ExtendBagWithUUID(bagId, uuid)
        end
      end)
      break
    end
  end
end
def.method("number", "number").TryEasyUse = function(self, itemId, itemKey)
  local record = DynamicData.GetRecord(CFG_PATH.DATA_ITEMEASYUSE, itemId)
  if record ~= nil then
    local isLight = record:GetCharValue("islight") ~= 0
    local countDown = record:GetIntValue("resttime")
    local needNum = record:GetIntValue("itemNum")
    local item = self._data:GetItem(ItemModule.BAG, itemKey)
    if item == nil or needNum > item.number then
      return
    end
    local hasNum = self._data:GetNumberByItemId(ItemModule.BAG, itemId)
    if needNum > hasNum then
      return
    end
    local itemBase = ItemUtils.GetItemBase(item.id)
    local ope = ItemTipsMgr.Instance():GetFirstOperation(ItemTipsMgr.Source.Bag, item, itemBase)
    local EasyUseDlg = require("Main.Item.ui.EasyUseDlg")
    EasyUseDlg.ShowEasyUse(item, itemKey, ope, isLight, countDown)
  end
end
def.method("boolean").BlockItemGetEffect = function(self, block)
  self._getNewItem:Block(block)
end
def.method().CloseInventoryDlg = function(self)
  if self._dlg.m_panel ~= nil then
    self._dlg:DestroyPanel()
  end
end
def.method("number").OpenInventoryDlgToKey = function(self, itemKey)
  if self._dlg.m_panel == nil then
    self._dlg:CreatePanel(RESPATH.DLG_INVENTORY, 1)
    self._dlg:SetModal(true)
  end
  self._dlg:SelectItem(itemKey + 1)
end
def.method().OpenInventoryDlgToBottom = function(self)
  if self._dlg.m_panel == nil then
    self._dlg:CreatePanel(RESPATH.DLG_INVENTORY, 1)
    self._dlg:SetModal(true)
  end
  GameUtil.AddGlobalTimer(1, true, function()
    if self._dlg then
      self._dlg:ScrollToEnd()
    end
  end)
end
def.method("number", "=>", "boolean").IsBagFull = function(self, bagId)
  local data = self._data
  return data:IsFull(bagId)
end
def.method("=>", "number").IsAnyBagFull = function(self)
  local data = self._data
  local toBeCheck = {
    ItemModule.BAG,
    ItemModule.GOD_WEAPON_JEWEL_BAG,
    ItemModule.FABAOBAG
  }
  for k, v in ipairs(toBeCheck) do
    if data:IsFull(v) then
      return v
    end
  end
  return 0
end
def.method("number", "=>", "number").IsBagFullForItemId = function(self, itemId)
  local bagId = self:GetBagIdByItemId(itemId)
  if self:IsBagFull(bagId) then
    return bagId
  else
    return 0
  end
end
def.method("table", "=>", "number").IsEnoughForItems = function(self, items)
  local needBagLeftSize = {}
  for k, v in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(k)
    local needGrid = math.ceil(v / itemBase.pilemax)
    local bagId = self:GetBagIdByItemType(itemBase.itemType)
    needBagLeftSize[bagId] = (needBagLeftSize[bagId] or 0) + needGrid
  end
  local data = self._data
  for k, v in pairs(needBagLeftSize) do
    local left = self:GetBagLeftSizeByBagId(k)
    if v > left then
      return k
    end
  end
  return 0
end
def.method("number").ToastBagFull = function(self, bagId)
  local name = textRes.Item[bagId] or textRes.Item[ItemModule.BAG]
  Toast(string.format(textRes.Item[13001], name))
end
def.method("=>", "table").GetInFightItem = function(self)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local data = self._data
  local ItemInFight = {}
  local items = data:GetBag(ItemModule.BAG)
  for k, v in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if itemBase.itemType == ItemType.IN_FIGHT_DRUG or itemBase.itemType == ItemType.DRUG_ITEM then
      local item = ItemInFight[v.id]
      if item == nil then
        item = {}
        item.id = v.id
        item.icon = itemBase.icon
        item.name = itemBase.name
        item.nameColor = itemBase.namecolor
        item.useLevel = itemBase.useLevel
        item.count = v.number
        item.type = itemBase.itemType
        item.uuidList = {}
        item.info = v
        for i = 1, #v.uuid do
          table.insert(item.uuidList, v.uuid[i])
        end
        ItemInFight[v.id] = item
      else
        item.count = item.count + v.number
        item.info = v
        for i = 1, #v.uuid do
          table.insert(item.uuidList, v.uuid[i])
        end
      end
    end
  end
  items = data:GetBag(ItemModule.TREASURE_BAG)
  for k, v in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(v.id)
    if itemBase.itemType == ItemType.SUPER_IN_FIGHT_DRUG_ITEM then
      local item = ItemInFight[v.id]
      if item == nil then
        item = {}
        item.id = v.id
        item.icon = itemBase.icon
        item.name = itemBase.name
        item.nameColor = itemBase.namecolor
        item.useLevel = itemBase.useLevel
        item.count = v.number
        item.type = itemBase.itemType
        item.uuidList = {}
        item.info = v
        for i = 1, #v.uuid do
          table.insert(item.uuidList, v.uuid[i])
        end
        ItemInFight[v.id] = item
      else
        item.count = item.count + v.number
        item.info = v
        for i = 1, #v.uuid do
          table.insert(item.uuidList, v.uuid[i])
        end
      end
    end
  end
  local ItemInFightSort = {}
  for k, v in pairs(ItemInFight) do
    table.insert(ItemInFightSort, v)
  end
  table.sort(ItemInFightSort, function(a, b)
    return a.id < b.id
  end)
  return ItemInFightSort
end
def.method("=>", "table").GetExtraSkill = function(self)
  local WearPos = require("consts.mzm.gsp.item.confbean.WearPos")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local data = self._data
  local k2, fabao = data:GetItemByPosition(ItemModule.EQUIPBAG, WearPos.FABAO)
  local skills = {}
  if k2 > 0 then
    local FabaoUtils = require("Main.Fabao.FabaoUtils")
    local skillsCfg = FabaoUtils.GetFaoBaoSkillCfg(fabao)
    for k, v in pairs(skillsCfg) do
      local id = v.id
      if id > 0 then
        table.insert(skills, id)
      end
    end
  end
  return skills
end
def.method("=>", "boolean").CheckEquipBroken = function(self)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local data = self._data
  local equips = data:GetBag(ItemModule.EQUIPBAG)
  local isBroken = false
  for k, v in pairs(equips) do
    local itemId = v.id
    local itemBase = ItemUtils.GetItemBase(itemId)
    if itemBase.itemType == ItemType.EQUIP then
      isBroken = v.extraMap[ItemXStoreType.USE_POINT_VALUE] <= 50
      if isBroken then
        break
      end
    end
  end
  return isBroken
end
def.method("=>", "table").GetEquipBrokenBuff = function(self)
  local buff
  local broken = self:CheckEquipBroken()
  if broken then
    buff = {}
    buff.title = textRes.Item[8342]
    buff.times = ""
    buff.desc = textRes.Item[8343]
    buff.icon = 244
  end
  return buff
end
def.method("boolean").FixAllEquip = function(self, includeBag)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local data = self._data
  local bagType = {
    ItemModule.EQUIPBAG
  }
  if includeBag then
    bagType = {
      ItemModule.EQUIPBAG,
      ItemModule.BAG
    }
  end
  local silverNeed = 0
  for _, v in pairs(bagType) do
    local equips = data:GetBag(v)
    for k, v in pairs(equips) do
      local itemId = v.id
      local itemBase = ItemUtils.GetItemBase(itemId)
      if itemBase.itemType == ItemType.EQUIP then
        local equipBase = ItemUtils.GetEquipBase(itemId)
        silverNeed = silverNeed + self:GetFixSilver(itemBase, equipBase, v)
      end
    end
  end
  CommonConfirmDlg.ShowConfirm(textRes.Item[8318], string.format(textRes.Item[8344], silverNeed), function(select)
    if select == 1 then
      local fixEquip = require("netio.protocol.mzm.gsp.item.CFixAllEquipments").new()
      gmodule.network.sendProtocol(fixEquip)
    end
  end, nil)
end
def.method("=>", "number", "table").GetAllQilingInfo = function(self)
  local qilingData = {}
  local equipments = self:GetHeroEquipments()
  local lowestLevel = math.huge
  for i = 0, 5 do
    local equip = equipments[i]
    local qilingLv = -1
    if equip then
      local strenLevel = equip.extraMap[ItemXStoreType.STRENGTH_LEVEL] or 0
      qilingLv = strenLevel
    end
    if lowestLevel > qilingLv then
      lowestLevel = qilingLv
    end
    qilingData[i] = qilingLv
  end
  local myLv = require("Main.Hero.Interface").GetBasicHeroProp().level
  local highestQilingLevel = EquipUtils.GetMostQiLingLevelByLevel(myLv)
  local allQilingLevels = EquipUtils.GetAllQilingList()
  local showList = {}
  for k, v in ipairs(allQilingLevels) do
    if v <= highestQilingLevel then
      table.insert(showList, v)
    end
  end
  local lightIndex = -1
  for k, v in ipairs(showList) do
    if lowestLevel >= v then
      lightIndex = k
    end
  end
  return lightIndex, showList
end
def.method("table", "table", "table", "=>", "number").GetFixSilver = function(self, itemBase, equipBase, item)
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local equipFullDurable = equipBase.usePoint
  local durable = item.extraMap[ItemXStoreType.USE_POINT_VALUE]
  local fixCost = 0
  local equipLevl = itemBase.useLevel
  if equipFullDurable > durable then
    local entries = DynamicData.GetTable(CFG_PATH.DATA_EQUIP_TRANS_INHERIT_CFG)
    local count = DynamicDataTable.GetRecordsCount(entries)
    DynamicDataTable.FastGetRecordBegin(entries)
    for i = 0, count - 1 do
      local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
      local equipmentLevel = DynamicRecord.GetIntValue(entry, "equipmentLevel")
      if equipmentLevel == equipLevl then
        fixCost = DynamicRecord.GetIntValue(entry, "fixOnePointNeedSilver")
        break
      end
    end
    DynamicDataTable.FastGetRecordEnd(entries)
    local useSilver = (equipFullDurable - durable) * fixCost
    return useSilver
  else
    return 0
  end
end
def.method("userdata", "number", "=>", "number", "table").GetItemByUUID = function(self, uuid, bagid)
  if self._data == nil then
    return -1, nil
  end
  local items = self._data:GetBag(bagid)
  if items == nil then
    return -1, nil
  end
  for k, v in pairs(items) do
    if uuid:eq(v.uuid[1]) then
      return k, v
    end
  end
  return -1, nil
end
def.method("number").ShowYuanbaoDetail = function(self, prefer)
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local cash = self:getCashYuanBao()
  local bind = self:getBindYuanBao()
  local str = string.format(textRes.Item[211], bind:tostring(), cash:tostring())
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTipY(str, screenPos.x, screenPos.y, 64, 64, prefer)
end
def.method("number", "=>", "boolean").IsItemInRedPointState = function(self, itemKey)
  if self:IsItemRedPointViewed(itemKey) then
    return false
  end
  local key, item = self:GetItemByPosition(ItemModule.BAG, itemKey)
  if key == -1 or item == nil then
    return false
  end
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local itemId = item.id
  local itemBase = ItemUtils.GetItemBase(itemId)
  if itemBase.itemType == ItemType.CHAINED_GIFT_BAG_ITEM then
    local endTime = item.extraMap[ItemXStoreType.CHAINED_GIFT_BAG_USE_TIME] or 0
    local curTime = _G.GetServerTime()
    if endTime > curTime then
      return false
    end
    local giftChainCfg = ItemUtils.GetChainGiftBagCfg(itemId)
    if giftChainCfg == nil then
      return false
    else
      return giftChainCfg.sn ~= 1
    end
  end
  return false
end
local itemRedPointKey = "Item_Red_Point_"
def.method("number").MarkItemRedPointViewed = function(self, itemKey)
  local key, item = self:GetItemByPosition(ItemModule.BAG, itemKey)
  if key == -1 or item == nil then
    return
  end
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  local storageKey = itemRedPointKey .. Int64.tostring(item.uuid[1])
  LuaPlayerPrefs.SetRoleString(storageKey, "1")
end
def.method("number", "=>", "boolean").IsItemRedPointViewed = function(self, itemKey)
  local key, item = self:GetItemByPosition(ItemModule.BAG, itemKey)
  if key == -1 or item == nil then
    return false
  end
  local storageKey = itemRedPointKey .. Int64.tostring(item.uuid[1])
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  if LuaPlayerPrefs.HasRoleKey(storageKey) then
    return true
  end
  return false
end
def.static("number", "table").BuffConfirmCallback = function(select, tag)
  if select > 0 then
    local confirmUseDrugOut = require("netio.protocol.mzm.gsp.role.CConfirmUseDrugResult").new(tag.itemKey, tag.bagId)
    gmodule.network.sendProtocol(confirmUseDrugOut)
  end
end
def.static("number", "number").Equip = function(bagId, itemKey)
  local pEquip = require("netio.protocol.mzm.gsp.item.CEquip").new(itemKey)
  gmodule.network.sendProtocol(pEquip)
  print("Equip", itemKey)
end
def.static("number", "number").UnEquip = function(bagId, itemKey)
  local pUnEquip = require("netio.protocol.mzm.gsp.item.CUnEquip").new(itemKey)
  gmodule.network.sendProtocol(pUnEquip)
  print("UnEquip", itemKey)
end
def.static("number").ArrangeBag = function(bagId)
  local arrange = require("netio.protocol.mzm.gsp.item.CArrange").new(bagId)
  gmodule.network.sendProtocol(arrange)
end
def.static("number").ArrangeStorage = function(storageId)
  if storageId > 0 then
    local arrange = require("netio.protocol.mzm.gsp.item.CArrangeStorage").new(storageId)
    gmodule.network.sendProtocol(arrange)
  else
    local data = _instance._data
    for k, v in ipairs(ItemModule.STORAGEBAGS) do
      local bag = data:GetBag2(v)
      if bag then
        warn("ArrangeStorage", v)
        local arrange = require("netio.protocol.mzm.gsp.item.CArrangeStorage").new(v)
        gmodule.network.sendProtocol(arrange)
      end
    end
  end
end
def.static("number", "string").RenameStorage = function(storageId, rename)
  local rename = require("netio.protocol.mzm.gsp.item.CReNameStorage").new(storageId, rename)
  gmodule.network.sendProtocol(rename)
end
def.static("number", "number").MoveItemToBag = function(itemKey, storageId)
  local cmove = require("netio.protocol.mzm.gsp.item.CMoveItemIntoBag").new(itemKey, storageId)
  gmodule.network.sendProtocol(cmove)
end
def.static("number", "number").MoveItemToStorage = function(itemKey, storageId)
  local cmove = require("netio.protocol.mzm.gsp.item.CMoveItemIntoStorage").new(itemKey, storageId)
  gmodule.network.sendProtocol(cmove)
end
def.static("number", "number", "userdata").ExtendBag = function(bagId, isYuanbao, curGold)
  local extendBag = require("netio.protocol.mzm.gsp.item.CExtendBag").new(bagId, isYuanbao, curGold)
  gmodule.network.sendProtocol(extendBag)
end
def.static("number", "userdata").ExtendBagWithUUID = function(bagId, uuid)
  if bagId == ItemModule.BAG then
    local extendBag = require("netio.protocol.mzm.gsp.item.CUseExtendBagItem").new(uuid)
    gmodule.network.sendProtocol(extendBag)
  end
end
def.static("number", "number").SellItem = function(bagId, itemKey)
  local sellItem = require("netio.protocol.mzm.gsp.item.CSellItemReq").new(bagId, itemKey)
  gmodule.network.sendProtocol(sellItem)
end
def.static("userdata", "number").UseSelectBagItem = function(uuid, selectindex)
  local p = require("netio.protocol.mzm.gsp.item.CUseSelectBagItem").new(uuid, selectindex)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").UseMoneyBagItem = function(uuid)
  local p = require("netio.protocol.mzm.gsp.item.CUseMoneyBagItem").new(uuid, 0)
  gmodule.network.sendProtocol(p)
end
def.static("userdata").ItemClickRemove = function(uuid)
  local p = require("netio.protocol.mzm.gsp.item.CItemClickRemoveReq").new(uuid, 0)
  gmodule.network.sendProtocol(p)
end
def.static("table").OnSUseGiftBagItemRes = function(p)
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemBase = ItemUtils.GetItemBase(p.itemid)
  Toast(string.format(textRes.Item[131], itemBase.name))
  local num = p.usednum
  local awardbean = p.awardbean
  awardbean.yuanbao = Int64.new(Int64.ToNumber(awardbean.yuanbao) * num)
  awardbean.gold = Int64.new(Int64.ToNumber(awardbean.gold) * num)
  awardbean.silver = Int64.new(Int64.ToNumber(awardbean.silver) * num)
  awardbean.gang = awardbean.gang * num
  awardbean.goldIngot = awardbean.goldIngot * num
  awardbean.roleExp = awardbean.roleExp * num
  awardbean.petExp = awardbean.petExp * num
  awardbean.xiulianExp = awardbean.xiulianExp * num
  for i, v in pairs(awardbean.itemMap) do
    awardbean.itemMap[i] = v * num
  end
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.CHAINED_GIFT_BAG_ITEM then
    local nextGift = ItemUtils.GetNextGiftInChainGiftBag(p.itemid)
    if nextGift ~= nil then
      awardbean.itemMap[nextGift.itemId] = nextGift.itemNum * num
    end
  end
  for i, v in pairs(awardbean.tokenMap) do
    awardbean.tokenMap[i] = v * num
  end
  for i, v in pairs(awardbean.awardAddMap) do
    if v.addValues then
      for k, vv in pairs(v.addValues) do
        if v.addValues and v.addValues[k] then
          v.addValues[k] = vv * num
        end
      end
    end
  end
  local str = textRes.Item[161]
  local awardInfo = require("Main.Award.AwardUtils").GetHtmlTextsFromAwardBean(awardbean, str)
  for _, v in ipairs(awardInfo) do
    require("Main.Chat.PersonalHelper").SendOut(v)
  end
end
def.static("table").OnSUseCatItemSuccess = function(p)
  Toast(string.format(textRes.Cat[6]))
  gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):GoToMyExplorerCat()
end
def.static("table").OnSEquipRes = function(p)
  warn("OnSEquipRes~~~~~~~~~~~~~~ ")
  local EquipModule = require("Main.Equip.EquipModule")
  EquipModule.OnWearEquipRes(p.uuids, p.super_equipment_uuids)
end
def.static("table", "table")._OnFashionUnlock = function(p1, p2)
  if ItemModule.Instance()._dlg.m_panel ~= nil then
    ItemModule.Instance()._dlg:UpdateFashion()
  end
end
def.static("table").OnSItemClickRemoveSuccess = function(p)
  local itemBase = ItemUtils.GetItemBase(p.item_cfg_id)
  if itemBase ~= nil then
    local color = require("Main.Chat.HtmlHelper").NameColor[itemBase.namecolor]
    Toast(string.format(textRes.Item[8373], color, itemBase.name))
  end
end
def.static("table").OnSExpBottleGetExpNotify = function(p)
  local awardInfo = require("netio.protocol.mzm.gsp.award.AwardBean").new()
  awardInfo.roleExp = p.get_exp
  local AwardUtils = require("Main.Award.AwardUtils")
  local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(awardInfo, textRes.Item[8374])
  for i, v in ipairs(htmlTexts) do
    PersonalHelper.SendOut(v)
  end
end
def.static("table").OnSDoubleItemGetNotify = function(p)
  for i = 1, #p.item_trigger_list do
    local triggerItem = p.item_trigger_list[i]
    local awardInfo = require("netio.protocol.mzm.gsp.award.AwardBean").new()
    awardInfo.roleExp = 0
    awardInfo.itemMap = {}
    awardInfo.itemMap[triggerItem.double_item_id] = triggerItem.double_item_number
    local itemBase = ItemUtils.GetItemBase(triggerItem.trigger_item_id)
    local sourceName = string.format(textRes.Item[8376], itemBase and itemBase.name or "")
    local AwardUtils = require("Main.Award.AwardUtils")
    local htmlTexts = AwardUtils.GetHtmlTextsFromAwardBean(awardInfo, sourceName)
    for i, v in ipairs(htmlTexts) do
      PersonalHelper.SendOut(v)
    end
  end
  if p.today_trigger_times then
    local curTimes = p.today_trigger_times
    local totalTimes = constant.CDoubleItemCfgConsts.max_double_item_times_every_day
    local tips = string.format(textRes.Item[8382], curTimes, totalTimes - curTimes)
    PersonalHelper.SendOut(tips)
  end
end
def.static("table").OnSItemCompoundAllRes = function(p)
  warn("--------OnSItemCompoundAllRes:")
  local costStrs = {}
  for i, v in pairs(p.costItemId2Num) do
    local costItemBase = ItemUtils.GetItemBase(i)
    local str = string.format(textRes.Item[8503], v, ItemTipsMgr.Color[costItemBase.namecolor], costItemBase.name)
    table.insert(costStrs, str)
  end
  local str = table.concat(costStrs, "\227\128\129")
  local compoundStrs = {}
  for i, v in pairs(p.compoundItemId2Num) do
    local itemBase = ItemUtils.GetItemBase(i)
    local str = string.format(textRes.Item[8503], v, ItemTipsMgr.Color[itemBase.namecolor], itemBase.name)
    table.insert(compoundStrs, str)
  end
  local compoundStr = table.concat(compoundStrs, "\227\128\129")
  local content = string.format(textRes.Item[8502], str, compoundStr)
  PersonalHelper.CommonMsg(PersonalHelper.Type.Text, content)
end
def.method("number", "number", "=>", "boolean").CheckMoneyEnough = function(self, type, num)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  if type == MoneyType.YUANBAO then
    local have = self:getCashYuanBao()
    if have:lt(num) then
      GotoBuyYuanbao()
      return false
    else
      return true
    end
  elseif type == MoneyType.GOLD then
    local have = self:GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if num > have then
      GoToBuyGold(true)
      return false
    else
      return true
    end
  elseif type == MoneyType.SILVER then
    local have = self:GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if num > have then
      GoToBuySilver(true)
      return false
    else
      return true
    end
  elseif type == MoneyType.GOLD_INGOT then
    local have = self:GetMoney(ItemModule.MONEY_TYPE_GOLD_INGOT)
    if num > have then
      GoToBuyGoldIngot(true)
      return false
    else
      return true
    end
  else
    return true
  end
end
local TreasureBagNotify = "TreasureBagNotify"
def.method("=>", "boolean").HasTreasureBagNotify = function(self)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  if LuaPlayerPrefs.HasRoleKey(TreasureBagNotify) then
    local notify = LuaPlayerPrefs.GetRoleInt(TreasureBagNotify)
    return notify == 1
  end
  return false
end
def.method("boolean").SetTreasureBagNotify = function(self, hasNotify)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  if hasNotify then
    LuaPlayerPrefs.SetRoleInt(TreasureBagNotify, 1)
  else
    LuaPlayerPrefs.SetRoleInt(TreasureBagNotify, 0)
  end
  Event.DispatchEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_Treasure_Bag_Notify_Change, nil)
end
def.method("=>", "boolean").HasViewTreasureBagNotify = function(self)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  if LuaPlayerPrefs.HasRoleKey(TreasureBagNotify) then
    local notify = LuaPlayerPrefs.GetRoleInt(TreasureBagNotify)
    return notify == 0
  end
  return false
end
def.static("table", "table").OnItemGetNewOne = function(params, context)
  local bagId = params.bagId
  if bagId == ItemModule.TREASURE_BAG and not ItemModule.Instance():HasViewTreasureBagNotify() then
    ItemModule.Instance():SetTreasureBagNotify(true)
  end
end
def.static("number", "=>", "userdata").GetCurrencyNumByType = function(mtype)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  local ItemModule = require("Main.Item.ItemModule")
  if mtype == MoneyType.YUANBAO then
    return ItemModule.Instance():GetAllYuanBao() or Int64.new(0)
  else
    if mtype == MoneyType.SILVER then
      mtype = ItemModule.MONEY_TYPE_SILVER
    elseif mtype == MoneyType.GOLD then
      mtype = ItemModule.MONEY_TYPE_GOLD
    elseif mtype == MoneyType.GOLD_INGOT then
      mtype = ItemModule.MONEY_TYPE_GOLD_INGOT
    end
    return ItemModule.Instance():GetMoney(mtype) or Int64.new(0)
  end
end
def.static("number", "boolean").GotoChargeByCurrencyType = function(mtype, bConfirm)
  local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
  if mtype == MoneyType.YUANBAO then
    _G.GotoBuyYuanbao()
  elseif mtype == MoneyType.GOLD then
    _G.GoToBuyGold(bconfirm)
  elseif mtype == MoneyType.SILVER then
    _G.GoToBuySilver(bconfirm)
  elseif mtype == MoneyType.GOLD_INGOT then
    _G.GoToBuyGoldIngot(bconfirm)
  end
end
ItemModule.Commit()
return ItemModule
