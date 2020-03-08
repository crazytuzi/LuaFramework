local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local ItemUtils = require("Main.Item.ItemUtils")
local FabaoUtils = require("Main.Fabao.FabaoUtils")
local FabaoData = require("Main.Fabao.data.FabaoData")
local OperationWearOffFabao = Lplus.Extend(OperationBase, "OperationWearOffFabao")
local def = OperationWearOffFabao.define
def.field("number").m_FabaoType = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local fabaoBase = ItemUtils.GetFabaoItem(itemBase.itemid)
  if nil == fabaoBase then
    return false
  end
  if not FabaoData.Instance():IsWearOnFabao(item.uuid[1]) then
    return false
  end
  local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
  if source == ItemTipsMgr.Source.Equip or source == ItemTipsMgr.Source.Other then
    return false
  end
  local fabaoType = fabaoBase.fabaoType
  local wearFabaoInfo = FabaoData.Instance():GetFabaoByType(fabaoType)
  if nil == wearFabaoInfo then
    return false
  end
  self.m_FabaoType = fabaoType
  return true
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Fabao[79]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if 0 == self.m_FabaoType then
    return false
  end
  if _G.CheckCrossServerAndToast() then
    return false
  end
  local p = require("netio.protocol.mzm.gsp.fabao.CUnEquipFabaoReq").new(self.m_FabaoType)
  gmodule.network.sendProtocol(p)
  return true
end
OperationWearOffFabao.Commit()
return OperationWearOffFabao
