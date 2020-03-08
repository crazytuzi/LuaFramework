local BagInfo = require("netio.protocol.mzm.gsp.item.BagInfo")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local SSynOcpEquipRes = class("SSynOcpEquipRes")
SSynOcpEquipRes.TYPEID = 12607745
function SSynOcpEquipRes:ctor(ocp, ocpequipbags, modelinfo)
  self.id = 12607745
  self.ocp = ocp or nil
  self.ocpequipbags = ocpequipbags or BagInfo.new()
  self.modelinfo = modelinfo or ModelInfo.new()
end
function SSynOcpEquipRes:marshal(os)
  os:marshalInt32(self.ocp)
  self.ocpequipbags:marshal(os)
  self.modelinfo:marshal(os)
end
function SSynOcpEquipRes:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.ocpequipbags = BagInfo.new()
  self.ocpequipbags:unmarshal(os)
  self.modelinfo = ModelInfo.new()
  self.modelinfo:unmarshal(os)
end
function SSynOcpEquipRes:sizepolicy(size)
  return size <= 65535
end
return SSynOcpEquipRes
