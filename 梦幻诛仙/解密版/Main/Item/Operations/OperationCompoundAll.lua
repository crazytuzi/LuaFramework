local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local OperationCompoundAll = Lplus.Extend(OperationBase, "OperationCompoundAll")
local def = OperationCompoundAll.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if source == ItemTipsMgr.Source.Bag and ItemUtils.GetItemCompounCfg(item.id) then
    local compounCfg = ItemUtils.GetItemCompounCfg(item.id)
    if compounCfg.canCompoundAll then
      if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ITEM_COMPOUND_ALL) then
        return false
      end
      return true
    end
    return false
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8501]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return true
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  if not self:CheckItem(item.id) then
    return true
  end
  local CollectSliderPanel = require("GUI.CollectSliderPanel")
  CollectSliderPanel.ShowCollectSliderPanel(textRes.Item[8305], 1.5, function()
    Toast(textRes.Item[8306])
  end, function(tag)
    if not self:CheckItem(item.id) then
      return
    end
    local compound = require("netio.protocol.mzm.gsp.item.CItemCompoundAllReq").new(item.uuid[#item.uuid])
    gmodule.network.sendProtocol(compound)
  end, nil)
  return true
end
def.method("number", "=>", "boolean").CheckItem = function(self, itemId)
  local compoundCfg = ItemUtils.GetItemCompounCfg(itemId)
  if compoundCfg == nil then
    return false
  end
  local EquipUtils = require("Main.Equip.EquipUtils")
  local makeNeedItem = EquipUtils.GetMakeItemTable(compoundCfg.makeCfgId)
  local strTable = {}
  if makeNeedItem.goldNum > 0 then
    local myGold = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
    if myGold < makeNeedItem.goldNum then
      Toast(textRes.Item[8350])
      return false
    end
  end
  if 0 < makeNeedItem.silverNum then
    local mySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
    if mySilver < makeNeedItem.silverNum then
      Toast(textRes.Item[8351])
      return false
    end
  end
  if 0 < makeNeedItem.vigorNum then
    local myVigorNum = require("Main.Hero.Interface").GetHeroProp().energy
    if myVigorNum < makeNeedItem.vigorNum then
      Toast(textRes.Item[8352])
      return false
    end
  end
  for k, v in ipairs(makeNeedItem.makeNeedItem) do
    local needItemId = v.itemId
    local needNum = v.itemNum
    local myItemNum = ItemModule.Instance():GetItemCountById(needItemId)
    if needNum > myItemNum then
      local needItemBase = ItemUtils.GetItemBase(needItemId)
      local name = needItemBase.name
      local color = needItemBase.namecolor
      Toast(string.format(textRes.Item[8353], ItemTipsMgr.Color[color], name))
      return false
    end
  end
  return true
end
OperationCompoundAll.Commit()
return OperationCompoundAll
