local OctetsStream = require("netio.OctetsStream")
local ModelId2DyeId = class("ModelId2DyeId")
function ModelId2DyeId:ctor(modelId, dyeId)
  self.modelId = modelId or nil
  self.dyeId = dyeId or nil
end
function ModelId2DyeId:marshal(os)
  os:marshalInt32(self.modelId)
  os:marshalInt32(self.dyeId)
end
function ModelId2DyeId:unmarshal(os)
  self.modelId = os:unmarshalInt32()
  self.dyeId = os:unmarshalInt32()
end
return ModelId2DyeId
