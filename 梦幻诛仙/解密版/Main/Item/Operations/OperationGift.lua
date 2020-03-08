local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationGift = Lplus.Extend(OperationBase, "OperationGift")
local def = OperationGift.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.GIFT_BAG_ITEM then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.static("number", "table").BuyYuanbaoCallback = function(i, tag)
  if 1 == i then
  end
end
def.static("number", "table").BuyGoldCallback = function(i, tag)
  if 1 == i then
  end
end
def.static("number", "table").BuySilverCallback = function(i, tag)
  if 1 == i then
  end
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local ItemModule = require("Main.Item.ItemModule")
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local GiftBagType = require("consts.mzm.gsp.item.confbean.GiftBagType")
  local ItemUtils = require("Main.Item.ItemUtils")
  local itemCfg = ItemUtils.GetGiftBasicCfg(item.id)
  if itemCfg.giftbagtype == GiftBagType.NORMAL then
    local ItemUtils = require("Main.Item.ItemUtils")
    local itemCfg = ItemUtils.GetGiftBasicCfg(item.id)
    local itemBase = ItemUtils.GetItemBase(item.id)
    local MoneyType = require("consts.mzm.gsp.item.confbean.MoneyType")
    if itemCfg.moneyType == MoneyType.YUANBAO then
      local yuanbao = ItemModule.Instance():GetAllYuanBao()
      if Int64.lt(yuanbao, itemCfg.moneyNum) then
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[132], itemCfg.moneyNum), OperationGift.BuyYuanbaoCallback, nil)
        return false
      end
    elseif itemCfg.moneyType == MoneyType.GOLD then
      local gold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
      if Int64.lt(gold, itemCfg.moneyNum) then
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[134], itemCfg.moneyNum), OperationGift.BuyGoldCallback, nil)
        return false
      end
    elseif itemCfg.moneyType == MoneyType.SILVER then
      local silver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
      if Int64.lt(silver, itemCfg.moneyNum) then
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm("", string.format(textRes.Item[135], itemCfg.moneyNum), OperationGift.BuySilverCallback, nil)
        return false
      end
    elseif itemCfg.moneyType == MoneyType.GANGCONTRIBUTE then
      local GangModule = require("Main.Gang.GangModule")
      local bHasGang = GangModule.Instance():HasGang()
      if bHasGang == false then
        Toast(textRes.Item[136])
        return false
      else
        local bangGong = GangModule.Instance():GetHeroCurBanggong()
        if bangGong < itemCfg.moneyNum then
          Toast(textRes.Item[137])
          return false
        end
      end
    end
    local useItem = require("netio.protocol.mzm.gsp.item.CUseGiftBagItem").new(item.uuid[1], 0)
    gmodule.network.sendProtocol(useItem)
    if 1 < item.number then
      return false
    end
  elseif itemCfg.giftbagtype == GiftBagType.SPECIAL then
    local awardCfg = ItemTipsMgr.GetGiftAwardCfgTbl(item.id)
    if awardCfg ~= nil then
      local GiftTipsPanel = require("Main.Item.ui.GiftTipsPanel")
      GiftTipsPanel.ShowPreviewGifts(awardCfg.moneyList, awardCfg.expList, awardCfg.itemList, awardCfg.appellationId, awardCfg.titleId, item.id, item.uuid[1])
    end
  end
  return true
end
OperationGift.Commit()
return OperationGift
