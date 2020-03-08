local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local ItemModule = require("Main.Item.ItemModule")
local MathHelper = require("Common.MathHelper")
local OperationFumo = Lplus.Extend(OperationBase, "OperationFumo")
local def = OperationFumo.define
def.field("boolean").bind = false
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if source == ItemTipsMgr.Source.Bag and itemBase.itemType == ItemType.MAGIC_MATERIAL then
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Item[8101]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  local item = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if item == nil then
    return
  end
  local itemBase = require("Main.Item.ItemUtils").GetItemBase(item.id)
  local fumoCfg = require("Main.Skill.LivingSkillUtility").GetEnchantingPropInfo(item.id)
  local equipKey, equipItem = ItemModule.Instance():GetItemByPosition(ItemModule.EQUIPBAG, fumoCfg.wearPos)
  local posName = textRes.Item[fumoCfg.wearPos + 10000]
  if equipKey < 0 then
    Toast(textRes.Item[8307] .. posName)
    return true
  end
  local hasSameType = false
  for k, v in ipairs(equipItem.fumoProList) do
    local leftTime = Int64.ToNumber(v.timeout) - GetServerTime()
    if leftTime > 0 and v.proType == fumoCfg.extraProperty then
      hasSameType = true
      break
    end
  end
  if hasSameType then
    CommonConfirmDlg.ShowConfirm(textRes.Item[8319], string.format(textRes.Item[8320], posName), function(selection, tag)
      if selection == 1 then
        local pEquip = require("netio.protocol.mzm.gsp.item.CUseFumoItemReq").new(item.uuid[#item.uuid])
        gmodule.network.sendProtocol(pEquip)
      end
    end, nil)
  else
    local pEquip = require("netio.protocol.mzm.gsp.item.CUseFumoItemReq").new(item.uuid[#item.uuid])
    gmodule.network.sendProtocol(pEquip)
  end
  if PlayerIsInFight() then
    GameUtil.AddGlobalLateTimer(0.1, true, function()
      Toast(textRes.Item[9700])
    end)
  end
  return true
end
OperationFumo.Commit()
return OperationFumo
