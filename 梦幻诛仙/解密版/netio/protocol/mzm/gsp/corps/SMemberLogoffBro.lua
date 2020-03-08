local SMemberLogoffBro = class("SMemberLogoffBro")
SMemberLogoffBro.TYPEID = 12617505
function SMemberLogoffBro:ctor(memebrId)
  self.id = 12617505
  self.memebrId = memebrId or nil
end
function SMemberLogoffBro:marshal(os)
  os:marshalInt64(self.memebrId)
end
function SMemberLogoffBro:unmarshal(os)
  self.memebrId = os:unmarshalInt64()
end
function SMemberLogoffBro:sizepolicy(size)
  return size <= 65535
end
return SMemberLogoffBro
