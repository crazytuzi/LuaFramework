local ModelId2DyeId = require("netio.protocol.mzm.gsp.wing.ModelId2DyeId")
local SWingModelDyeRes = class("SWingModelDyeRes")
SWingModelDyeRes.TYPEID = 12596509
function SWingModelDyeRes:ctor(modelId2dyeid)
  self.id = 12596509
  self.modelId2dyeid = modelId2dyeid or ModelId2DyeId.new()
end
function SWingModelDyeRes:marshal(os)
  self.modelId2dyeid:marshal(os)
end
function SWingModelDyeRes:unmarshal(os)
  self.modelId2dyeid = ModelId2DyeId.new()
  self.modelId2dyeid:unmarshal(os)
end
function SWingModelDyeRes:sizepolicy(size)
  return size <= 65535
end
return SWingModelDyeRes
