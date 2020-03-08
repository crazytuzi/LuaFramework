local SMapMonsterFightEnd = class("SMapMonsterFightEnd")
SMapMonsterFightEnd.TYPEID = 12590952
function SMapMonsterFightEnd:ctor(instanceid)
  self.id = 12590952
  self.instanceid = instanceid or nil
end
function SMapMonsterFightEnd:marshal(os)
  os:marshalInt32(self.instanceid)
end
function SMapMonsterFightEnd:unmarshal(os)
  self.instanceid = os:unmarshalInt32()
end
function SMapMonsterFightEnd:sizepolicy(size)
  return size <= 65535
end
return SMapMonsterFightEnd
