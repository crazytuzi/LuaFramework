local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local FabaoModule = require("Main.Fabao.FabaoModule")
local FabaoData = require("Main.Fabao.data.FabaoData")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local OperationWearOnFabao = Lplus.Extend(OperationBase, "OperationWearOnFabao")
local def = OperationWearOnFabao.define
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  if itemBase.itemType == ItemType.FABAO_ITEM and source == ItemTipsMgr.Source.FabaoBag then
    local fabaoBase = ItemUtils.GetFabaoItem(itemBase.itemid)
    if nil == fabaoBase then
      return false
    end
    return true
  end
  return false
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Fabao[78]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local heroLevel = require("Main.Hero.Interface").GetBasicHeroProp().level
  local fabaoOpenLevel = FabaoUtils.GetFabaoConstValue("FABAO_OPEN_LEVEL") or 60
  if heroLevel < fabaoOpenLevel then
    Toast(textRes.Fabao[54]:format(fabaoOpenLevel))
    return true
  end
  local ItemModule = require("Main.Item.ItemModule")
  local hasFabaoTask, taskId = FabaoModule.HasFabaoTask()
  if hasFabaoTask then
    Toast(textRes.Fabao[59])
    if 0 ~= taskId then
      local FabaoTaskGraphID = FabaoUtils.GetFabaoConstValue("FABAO_TASK_MAP_ID")
      Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.TASK_TRACE_ITEM_CLICK, {taskId, FabaoTaskGraphID})
      ItemModule.Instance():CloseInventoryDlg()
    end
    return true
  end
  if itemKey < 0 then
    return false
  end
  local fabaoItemInfo = ItemModule.Instance():GetItemByBagIdAndItemKey(bagId, itemKey)
  if nil == fabaoItemInfo then
    return false
  end
  local fabaoBase = ItemUtils.GetFabaoItem(fabaoItemInfo.id)
  if nil == fabaoBase then
    return false
  end
  local function wearOn()
    local p = require("netio.protocol.mzm.gsp.fabao.CEquipFabaoReq").new(itemKey)
    gmodule.network.sendProtocol(p)
  end
  local fabaoType = fabaoBase.fabaoType
  local FabaoData = require("Main.Fabao.data.FabaoData")
  local wearFabaoInfo = FabaoData.Instance():GetFabaoByType(fabaoType)
  if nil == wearFabaoInfo then
    wearOn()
  else
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    local itemBase = ItemUtils.GetItemBase(fabaoItemInfo.id)
    local fabaoName = itemBase.name
    local desc = string.format(textRes.Fabao[80], fabaoName)
    CommonConfirmDlg.ShowConfirm(textRes.Fabao[81], desc, function(select, tag)
      if 1 == select then
        wearOn()
      end
    end, nil)
  end
  return true
end
OperationWearOnFabao.Commit()
return OperationWearOnFabao
