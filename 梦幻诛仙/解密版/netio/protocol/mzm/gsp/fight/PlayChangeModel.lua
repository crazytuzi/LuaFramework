local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local PlayChangeModel = class("PlayChangeModel")
function PlayChangeModel:ctor(fighterid, model)
  self.fighterid = fighterid or nil
  self.model = model or ModelInfo.new()
end
function PlayChangeModel:marshal(os)
  os:marshalInt32(self.fighterid)
  self.model:marshal(os)
end
function PlayChangeModel:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
return PlayChangeModel
