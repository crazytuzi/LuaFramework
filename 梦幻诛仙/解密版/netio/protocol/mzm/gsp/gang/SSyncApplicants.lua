local SSyncApplicants = class("SSyncApplicants")
SSyncApplicants.TYPEID = 12589953
function SSyncApplicants:ctor(applicants)
  self.id = 12589953
  self.applicants = applicants or {}
end
function SSyncApplicants:marshal(os)
  os:marshalCompactUInt32(table.getn(self.applicants))
  for _, v in ipairs(self.applicants) do
    v:marshal(os)
  end
end
function SSyncApplicants:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.Applicant")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.applicants, v)
  end
end
function SSyncApplicants:sizepolicy(size)
  return size <= 65535
end
return SSyncApplicants
