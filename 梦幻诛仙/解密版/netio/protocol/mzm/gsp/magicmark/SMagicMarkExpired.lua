local SMagicMarkExpired = class("SMagicMarkExpired")
SMagicMarkExpired.TYPEID = 12609544
function SMagicMarkExpired:ctor(magicMarkType)
  self.id = 12609544
  self.magicMarkType = magicMarkType or nil
end
function SMagicMarkExpired:marshal(os)
  os:marshalInt32(self.magicMarkType)
end
function SMagicMarkExpired:unmarshal(os)
  self.magicMarkType = os:unmarshalInt32()
end
function SMagicMarkExpired:sizepolicy(size)
  return size <= 65535
end
return SMagicMarkExpired
