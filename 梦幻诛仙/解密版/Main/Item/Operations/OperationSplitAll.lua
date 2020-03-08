local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local OperationSplitAll = Lplus.Extend(OperationBase, "OperationSplitAll")
local def = OperationSplitAll.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and ItemUtils.GetItemSplitCfg(item.id) ~= nil then
    if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ITEM_SPLIT) then
      return false
    end
    local cfg = ItemUtils.GetItemSplitCfg(item.id)
    if not cfg.canSplitAll then
      return false
    end
    local isBind = ItemUtils.IsItemBind(item)
    if isBind and not cfg.canSplitBind then
      return false
    end
    local itemNum = ItemModule.Instance():GetItemCountById(item.id)
    return itemNum > 1
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[12101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  if not self:CheckItem(item) then
    return true
  end
  local CollectSliderPanel = require("GUI.CollectSliderPanel")
  CollectSliderPanel.ShowCollectSliderPanel(textRes.Item[12102], 1.5, function()
    Toast(textRes.Item[12103])
  end, function(tag)
    if not self:CheckItem(item) then
      return
    end
    local compound = require("netio.protocol.mzm.gsp.item.CSplitItemReq").new(item.uuid[#item.uuid], 1)
    gmodule.network.sendProtocol(compound)
  end, nil)
  return true
end
def.method("table", "=>", "boolean").CheckItem = function(self, item)
  local splitCfg = ItemUtils.GetItemSplitCfg(item.id)
  if splitCfg == nil then
    return false
  end
  local itemNum = ItemModule.Instance():GetItemCountById(item.id)
  local strTable = {}
  if splitCfg.requiredGold > 0 then
    local myGold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if Int64.new(splitCfg.requiredGold * itemNum):gt(myGold) then
      Toast(textRes.Item[12107])
      return false
    end
  end
  if 0 < splitCfg.requiredSilver then
    local mySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if Int64.new(splitCfg.requiredSilver * itemNum):gt(mySilver) then
      Toast(textRes.Item[12108])
      return false
    end
  end
  if 0 < splitCfg.requiredVigor then
    local myVigorNum = require("Main.Hero.Interface").GetHeroProp().energy
    if myVigorNum < splitCfg.requiredVigor * itemNum then
      Toast(textRes.Item[12109])
      return false
    end
  end
  return true
end
OperationSplitAll.Commit()
return OperationSplitAll
