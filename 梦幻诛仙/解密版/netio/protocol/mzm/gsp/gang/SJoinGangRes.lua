local SJoinGangRes = class("SJoinGangRes")
SJoinGangRes.TYPEID = 12589884
function SJoinGangRes:ctor(gangName)
  self.id = 12589884
  self.gangName = gangName or nil
end
function SJoinGangRes:marshal(os)
  os:marshalString(self.gangName)
end
function SJoinGangRes:unmarshal(os)
  self.gangName = os:unmarshalString()
end
function SJoinGangRes:sizepolicy(size)
  return size <= 65535
end
return SJoinGangRes
