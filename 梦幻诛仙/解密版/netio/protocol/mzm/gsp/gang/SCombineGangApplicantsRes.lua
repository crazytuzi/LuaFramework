local SCombineGangApplicantsRes = class("SCombineGangApplicantsRes")
SCombineGangApplicantsRes.TYPEID = 12589975
function SCombineGangApplicantsRes:ctor(applicants)
  self.id = 12589975
  self.applicants = applicants or {}
end
function SCombineGangApplicantsRes:marshal(os)
  os:marshalCompactUInt32(table.getn(self.applicants))
  for _, v in ipairs(self.applicants) do
    v:marshal(os)
  end
end
function SCombineGangApplicantsRes:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.CombineGang")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.applicants, v)
  end
end
function SCombineGangApplicantsRes:sizepolicy(size)
  return size <= 65535
end
return SCombineGangApplicantsRes
