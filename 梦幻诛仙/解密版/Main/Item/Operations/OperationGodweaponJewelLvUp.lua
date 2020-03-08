local MODULE_NAME = (...)
local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local OperationGodweaponJewelLvUp = Lplus.Extend(OperationBase, MODULE_NAME)
local def = OperationGodweaponJewelLvUp.define
local JewelMgr = require("Main.GodWeapon.JewelMgr")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local JewelUtils = require("Main.GodWeapon.Jewel.JewelUtils")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local CurrencyFactory = require("Main.Currency.CurrencyFactory")
local txtConst = textRes.GodWeapon.Jewel
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.SUPER_EQUIPMENT_JEWEL_ITEM and bFeatureOpen then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return txtConst[5]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local bFeatureOpen = JewelMgr.IsFeatureOpen()
  if not bFeatureOpen then
    Toast(txtConst[11])
    return true
  end
  if _G.CheckCrossServerAndToast() then
    return true
  end
  local slotNode = require("Main.GodWeapon.ui.JewelNode").Instance()
  local slot = slotNode:GetCurSelSlot()
  local slotItem = slotNode:GetSlotItem()
  local stageCfg = slotNode:GetSelEquipStageCfg()
  if slotItem == nil then
    return true
  end
  local jewelItemCfg = JewelUtils.GetJewelItemByItemId(slotItem.id, false)
  if jewelItemCfg == nil then
    return true
  end
  if stageCfg ~= nil and jewelItemCfg.level >= stageCfg.maxGemLevel then
    Toast(txtConst[46])
    return true
  end
  local bCanLvUp, mapCostItems = JewelMgr.CanJewelLvUpEx(jewelItemCfg.itemId)
  if not bCanLvUp then
    if mapCostItems.itemNotEnough then
      for itemId, num in pairs(mapCostItems.items) do
        if itemId >= 0 then
          local itemBase = ItemUtils.GetItemBase(itemId)
          if itemBase ~= nil then
            Toast(txtConst[38]:format(itemBase.name))
          end
        end
      end
    elseif mapCostItems.moneyNotEnough then
      for moneyType, num in pairs(mapCostItems.moneys) do
        JewelMgr.GotoBuyMoney(moneyType, true)
        return true
      end
    elseif mapCostItems.jewelNotEnough then
      Toast(txtConst[39])
    end
  end
  local strContent = ""
  if 0 < jewelItemCfg.nxtLvNeedItemNum then
    for itemId, num in pairs(mapCostItems.items) do
      local needItemBase = ItemUtils.GetItemBase(jewelItemCfg.nxtLvNeedItemId)
      if needItemBase ~= nil then
        strContent = strContent .. txtConst[19]:format(jewelItemCfg.nxtLvNeedItemNum, needItemBase.name)
      end
    end
  end
  if 0 < jewelItemCfg.nxtLvNeedMoneyNum then
    if strContent ~= "" then
      strContent = strContent .. txtConst[42]
    end
    for moneyType, num in pairs(mapCostItems.moneys) do
      local moneyData = CurrencyFactory.Create(moneyType)
      strContent = strContent .. " " .. txtConst[19]:format(num, moneyData:GetName())
    end
  end
  if 0 < jewelItemCfg.needCurLvItemNum then
    if strContent ~= "" then
      strContent = strContent .. txtConst[42]
    end
    strContent = strContent .. txtConst[28]
  end
  if strContent ~= "" then
    strContent = txtConst[18] .. strContent
    CommonConfirmDlg.ShowConfirm(txtConst[26], strContent, function(select)
      if select == 1 then
        self:ToSendReq(jewelItemCfg, slotItem, bagId, itemKey, slot)
      end
    end, nil)
  else
    self:ToSendReq(jewelItemCfg, slotItem, bagId, itemKey, slot)
  end
  return true
end
def.method("table", "table", "number", "number", "number").ToSendReq = function(self, jewelItemCfg, slotItem, bagId, itemKey, slot)
  if jewelItemCfg.nxtLvItemId == 0 then
    Toast(txtConst[8])
    return
  end
  local JewelProtocols = require("Main.GodWeapon.Jewel.JewelProtocols").CSendUpdateJewel(bagId, itemKey, slot)
end
return OperationGodweaponJewelLvUp.Commit()
