local Lplus = require("Lplus")
local OperationBase = require("Main.Item.Operations.OperationBase")
local ItemUtils = require("Main.Item.ItemUtils")
local OperationUnmountLongjing = Lplus.Extend(OperationBase, "OperationUnmountLongjing")
local def = OperationUnmountLongjing.define
def.field("number").m_fabaoType = 0
def.field("number").m_pos = 0
def.override("number", "table", "table", "=>", "boolean").CanDispaly = function(self, source, item, itemBase)
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  if itemBase.itemType == ItemType.FABAO_LONGJING_ITEM then
    self.m_pos = item.longjingPos
    self.m_fabaoType = item.fabaoType
    return true
  else
    return false
  end
end
def.override("=>", "string").GetOperationName = function(self)
  return textRes.Fabao[79]
end
def.override("number", "number", "userdata", "table", "=>", "boolean").Operate = function(self, bagId, itemKey, m_panel, context)
  if 0 == self.m_pos or 0 == self.m_fabaoType then
    return false
  end
  local FabaoModule = require("Main.Fabao.FabaoModule")
  FabaoModule.RequestLongjingUnMount(self.m_fabaoType, self.m_pos)
  return true
end
OperationUnmountLongjing.Commit()
return OperationUnmountLongjing
