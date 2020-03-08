local SMapMonsterFightStart = class("SMapMonsterFightStart")
SMapMonsterFightStart.TYPEID = 12590951
function SMapMonsterFightStart:ctor(instanceid)
  self.id = 12590951
  self.instanceid = instanceid or nil
end
function SMapMonsterFightStart:marshal(os)
  os:marshalInt32(self.instanceid)
end
function SMapMonsterFightStart:unmarshal(os)
  self.instanceid = os:unmarshalInt32()
end
function SMapMonsterFightStart:sizepolicy(size)
  return size <= 65535
end
return SMapMonsterFightStart
