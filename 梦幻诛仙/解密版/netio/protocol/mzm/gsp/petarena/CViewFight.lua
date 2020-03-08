local CViewFight = class("CViewFight")
CViewFight.TYPEID = 12628249
function CViewFight:ctor(recordid)
  self.id = 12628249
  self.recordid = recordid or nil
end
function CViewFight:marshal(os)
  os:marshalInt64(self.recordid)
end
function CViewFight:unmarshal(os)
  self.recordid = os:unmarshalInt64()
end
function CViewFight:sizepolicy(size)
  return size <= 65535
end
return CViewFight
