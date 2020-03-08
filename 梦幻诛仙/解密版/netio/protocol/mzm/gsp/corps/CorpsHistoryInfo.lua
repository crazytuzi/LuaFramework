local OctetsStream = require("netio.OctetsStream")
local CorpsHistoryInfo = class("CorpsHistoryInfo")
function CorpsHistoryInfo:ctor(historyId, recordTime, historyType, parameters)
  self.historyId = historyId or nil
  self.recordTime = recordTime or nil
  self.historyType = historyType or nil
  self.parameters = parameters or {}
end
function CorpsHistoryInfo:marshal(os)
  os:marshalInt32(self.historyId)
  os:marshalInt32(self.recordTime)
  os:marshalInt32(self.historyType)
  os:marshalCompactUInt32(table.getn(self.parameters))
  for _, v in ipairs(self.parameters) do
    os:marshalOctets(v)
  end
end
function CorpsHistoryInfo:unmarshal(os)
  self.historyId = os:unmarshalInt32()
  self.recordTime = os:unmarshalInt32()
  self.historyType = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.parameters, v)
  end
end
return CorpsHistoryInfo
