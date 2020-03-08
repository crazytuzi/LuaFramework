local SRomanticDanceFriendValueAdd = class("SRomanticDanceFriendValueAdd")
SRomanticDanceFriendValueAdd.TYPEID = 12613134
function SRomanticDanceFriendValueAdd:ctor(add_value)
  self.id = 12613134
  self.add_value = add_value or nil
end
function SRomanticDanceFriendValueAdd:marshal(os)
  os:marshalInt32(self.add_value)
end
function SRomanticDanceFriendValueAdd:unmarshal(os)
  self.add_value = os:unmarshalInt32()
end
function SRomanticDanceFriendValueAdd:sizepolicy(size)
  return size <= 65535
end
return SRomanticDanceFriendValueAdd
