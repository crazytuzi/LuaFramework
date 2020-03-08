local FabaoArtifactInfo = require("netio.protocol.mzm.gsp.fabaolingqi.FabaoArtifactInfo")
local SGetArtifactInfoRes = class("SGetArtifactInfoRes")
SGetArtifactInfoRes.TYPEID = 12618259
function SGetArtifactInfoRes:ctor(role_id, class_id, info)
  self.id = 12618259
  self.role_id = role_id or nil
  self.class_id = class_id or nil
  self.info = info or FabaoArtifactInfo.new()
end
function SGetArtifactInfoRes:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.class_id)
  self.info:marshal(os)
end
function SGetArtifactInfoRes:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.class_id = os:unmarshalInt32()
  self.info = FabaoArtifactInfo.new()
  self.info:unmarshal(os)
end
function SGetArtifactInfoRes:sizepolicy(size)
  return size <= 65535
end
return SGetArtifactInfoRes
