local SGetCorpsHistoryRep = class("SGetCorpsHistoryRep")
SGetCorpsHistoryRep.TYPEID = 12617519
function SGetCorpsHistoryRep:ctor(corpsId, start, historyList)
  self.id = 12617519
  self.corpsId = corpsId or nil
  self.start = start or nil
  self.historyList = historyList or {}
end
function SGetCorpsHistoryRep:marshal(os)
  os:marshalInt64(self.corpsId)
  os:marshalInt32(self.start)
  os:marshalCompactUInt32(table.getn(self.historyList))
  for _, v in ipairs(self.historyList) do
    v:marshal(os)
  end
end
function SGetCorpsHistoryRep:unmarshal(os)
  self.corpsId = os:unmarshalInt64()
  self.start = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.corps.CorpsHistoryInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.historyList, v)
  end
end
function SGetCorpsHistoryRep:sizepolicy(size)
  return size <= 65535
end
return SGetCorpsHistoryRep
