local OctetsStream = require("netio.OctetsStream")
local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local NPCModelInfo = class("NPCModelInfo")
NPCModelInfo.TITLEID = 0
NPCModelInfo.APPELLATIONID = 1
NPCModelInfo.RIDE_ID = 2
NPCModelInfo.RIDE_COLOR_ID = 3
NPCModelInfo.NAME = 0
NPCModelInfo.APPELLATION = 1
function NPCModelInfo:ctor(id, model, int_props, string_props)
  self.id = id or nil
  self.model = model or ModelInfo.new()
  self.int_props = int_props or {}
  self.string_props = string_props or {}
end
function NPCModelInfo:marshal(os)
  os:marshalInt64(self.id)
  self.model:marshal(os)
  do
    local _size_ = 0
    for _, _ in pairs(self.int_props) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.int_props) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.string_props) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.string_props) do
    os:marshalInt32(k)
    os:marshalString(v)
  end
end
function NPCModelInfo:unmarshal(os)
  self.id = os:unmarshalInt64()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.int_props[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalString()
    self.string_props[k] = v
  end
end
return NPCModelInfo
