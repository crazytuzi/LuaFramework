local ModelId2DyeId = require("netio.protocol.mzm.gsp.wing.ModelId2DyeId")
local SChangeWingViewRes = class("SChangeWingViewRes")
SChangeWingViewRes.TYPEID = 12596493
function SChangeWingViewRes:ctor(index, modelId2dyeid, isshowwing)
  self.id = 12596493
  self.index = index or nil
  self.modelId2dyeid = modelId2dyeid or ModelId2DyeId.new()
  self.isshowwing = isshowwing or nil
end
function SChangeWingViewRes:marshal(os)
  os:marshalInt32(self.index)
  self.modelId2dyeid:marshal(os)
  os:marshalInt32(self.isshowwing)
end
function SChangeWingViewRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.modelId2dyeid = ModelId2DyeId.new()
  self.modelId2dyeid:unmarshal(os)
  self.isshowwing = os:unmarshalInt32()
end
function SChangeWingViewRes:sizepolicy(size)
  return size <= 65535
end
return SChangeWingViewRes
