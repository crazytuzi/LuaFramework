local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local CorpsMemberExtroInfo = class("CorpsMemberExtroInfo")
function CorpsMemberExtroInfo:ctor(multiFightValue, model)
  self.multiFightValue = multiFightValue or nil
  self.model = model or ModelInfo.new()
end
function CorpsMemberExtroInfo:marshal(os)
  os:marshalInt32(self.multiFightValue)
  self.model:marshal(os)
end
function CorpsMemberExtroInfo:unmarshal(os)
  self.multiFightValue = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
return CorpsMemberExtroInfo
