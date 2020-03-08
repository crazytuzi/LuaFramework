local ShiTuRoleInfoAndModelInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfoAndModelInfo")
local SAgreeOrRefuseShouTu = class("SAgreeOrRefuseShouTu")
SAgreeOrRefuseShouTu.TYPEID = 12601621
function SAgreeOrRefuseShouTu:ctor(operator, apprenticeRoleInfo, masterRoleInfo)
  self.id = 12601621
  self.operator = operator or nil
  self.apprenticeRoleInfo = apprenticeRoleInfo or ShiTuRoleInfoAndModelInfo.new()
  self.masterRoleInfo = masterRoleInfo or ShiTuRoleInfoAndModelInfo.new()
end
function SAgreeOrRefuseShouTu:marshal(os)
  os:marshalInt32(self.operator)
  self.apprenticeRoleInfo:marshal(os)
  self.masterRoleInfo:marshal(os)
end
function SAgreeOrRefuseShouTu:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.apprenticeRoleInfo = ShiTuRoleInfoAndModelInfo.new()
  self.apprenticeRoleInfo:unmarshal(os)
  self.masterRoleInfo = ShiTuRoleInfoAndModelInfo.new()
  self.masterRoleInfo:unmarshal(os)
end
function SAgreeOrRefuseShouTu:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefuseShouTu
