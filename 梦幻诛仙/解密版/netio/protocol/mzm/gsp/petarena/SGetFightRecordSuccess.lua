local SGetFightRecordSuccess = class("SGetFightRecordSuccess")
SGetFightRecordSuccess.TYPEID = 12628245
function SGetFightRecordSuccess:ctor(records)
  self.id = 12628245
  self.records = records or {}
end
function SGetFightRecordSuccess:marshal(os)
  os:marshalCompactUInt32(table.getn(self.records))
  for _, v in ipairs(self.records) do
    v:marshal(os)
  end
end
function SGetFightRecordSuccess:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.petarena.FightRecordData")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.records, v)
  end
end
function SGetFightRecordSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetFightRecordSuccess
