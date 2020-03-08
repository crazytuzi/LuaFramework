local SEndHuSongRes = class("SEndHuSongRes")
SEndHuSongRes.TYPEID = 12587558
SEndHuSongRes.NORMAL = 1
SEndHuSongRes.GIVE_UP = 2
function SEndHuSongRes:ctor(husongcfgid, ret)
  self.id = 12587558
  self.husongcfgid = husongcfgid or nil
  self.ret = ret or nil
end
function SEndHuSongRes:marshal(os)
  os:marshalInt32(self.husongcfgid)
  os:marshalInt32(self.ret)
end
function SEndHuSongRes:unmarshal(os)
  self.husongcfgid = os:unmarshalInt32()
  self.ret = os:unmarshalInt32()
end
function SEndHuSongRes:sizepolicy(size)
  return size <= 65535
end
return SEndHuSongRes
