local OctetsStream = require("netio.OctetsStream")
local CallHelpData = class("CallHelpData")
function CallHelpData:ctor(boxIndex2Data)
  self.boxIndex2Data = boxIndex2Data or {}
end
function CallHelpData:marshal(os)
  local _size_ = 0
  for _, _ in pairs(self.boxIndex2Data) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.boxIndex2Data) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function CallHelpData:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.huanhun.BoxData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.boxIndex2Data[k] = v
  end
end
return CallHelpData
