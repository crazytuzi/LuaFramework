local SSyncApplicantList = class("SSyncApplicantList")
SSyncApplicantList.TYPEID = 12588315
function SSyncApplicantList:ctor(applicants)
  self.id = 12588315
  self.applicants = applicants or {}
end
function SSyncApplicantList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.applicants))
  for _, v in ipairs(self.applicants) do
    v:marshal(os)
  end
end
function SSyncApplicantList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamApplicant")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.applicants, v)
  end
end
function SSyncApplicantList:sizepolicy(size)
  return size <= 65535
end
return SSyncApplicantList
