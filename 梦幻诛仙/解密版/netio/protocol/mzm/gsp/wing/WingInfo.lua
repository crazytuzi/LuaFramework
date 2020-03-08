local OctetsStream = require("netio.OctetsStream")
local ModelId2DyeId = require("netio.protocol.mzm.gsp.wing.ModelId2DyeId")
local WingInfo = class("WingInfo")
function WingInfo:ctor(exp, level, phase, propertyList, skillList, modelId2dyeid)
  self.exp = exp or nil
  self.level = level or nil
  self.phase = phase or nil
  self.propertyList = propertyList or {}
  self.skillList = skillList or {}
  self.modelId2dyeid = modelId2dyeid or ModelId2DyeId.new()
end
function WingInfo:marshal(os)
  os:marshalInt32(self.exp)
  os:marshalInt32(self.level)
  os:marshalInt32(self.phase)
  os:marshalCompactUInt32(table.getn(self.propertyList))
  for _, v in ipairs(self.propertyList) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.skillList))
  for _, v in ipairs(self.skillList) do
    v:marshal(os)
  end
  self.modelId2dyeid:marshal(os)
end
function WingInfo:unmarshal(os)
  self.exp = os:unmarshalInt32()
  self.level = os:unmarshalInt32()
  self.phase = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingProperty")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.propertyList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.wing.WingSkill")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.skillList, v)
  end
  self.modelId2dyeid = ModelId2DyeId.new()
  self.modelId2dyeid:unmarshal(os)
end
return WingInfo
