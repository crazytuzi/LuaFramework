local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local Observer = class("Observer")
Observer.TYPE_ACTIVE = 0
Observer.TYPE_PASIVE = 1
function Observer:ctor(observerid, level, name, gender, occupation, model)
  self.observerid = observerid or nil
  self.level = level or nil
  self.name = name or nil
  self.gender = gender or nil
  self.occupation = occupation or nil
  self.model = model or ModelInfo.new()
end
function Observer:marshal(os)
  os:marshalInt64(self.observerid)
  os:marshalInt32(self.level)
  os:marshalString(self.name)
  os:marshalInt32(self.gender)
  os:marshalInt32(self.occupation)
  self.model:marshal(os)
end
function Observer:unmarshal(os)
  self.observerid = os:unmarshalInt64()
  self.level = os:unmarshalInt32()
  self.name = os:unmarshalString()
  self.gender = os:unmarshalInt32()
  self.occupation = os:unmarshalInt32()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
return Observer
