local SSyncGangTeamApplicants = class("SSyncGangTeamApplicants")
SSyncGangTeamApplicants.TYPEID = 12589999
function SSyncGangTeamApplicants:ctor(applicants)
  self.id = 12589999
  self.applicants = applicants or {}
end
function SSyncGangTeamApplicants:marshal(os)
  os:marshalCompactUInt32(table.getn(self.applicants))
  for _, v in ipairs(self.applicants) do
    os:marshalInt64(v)
  end
end
function SSyncGangTeamApplicants:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.applicants, v)
  end
end
function SSyncGangTeamApplicants:sizepolicy(size)
  return size <= 65535
end
return SSyncGangTeamApplicants
