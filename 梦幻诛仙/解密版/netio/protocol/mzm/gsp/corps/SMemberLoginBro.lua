local SMemberLoginBro = class("SMemberLoginBro")
SMemberLoginBro.TYPEID = 12617502
function SMemberLoginBro:ctor(memebrId)
  self.id = 12617502
  self.memebrId = memebrId or nil
end
function SMemberLoginBro:marshal(os)
  os:marshalInt64(self.memebrId)
end
function SMemberLoginBro:unmarshal(os)
  self.memebrId = os:unmarshalInt64()
end
function SMemberLoginBro:sizepolicy(size)
  return size <= 65535
end
return SMemberLoginBro
