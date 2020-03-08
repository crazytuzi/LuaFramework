local SHuSongRes = class("SHuSongRes")
SHuSongRes.TYPEID = 12587552
function SHuSongRes:ctor(husongcfgid, husong_couple_npc_cfgid)
  self.id = 12587552
  self.husongcfgid = husongcfgid or nil
  self.husong_couple_npc_cfgid = husong_couple_npc_cfgid or nil
end
function SHuSongRes:marshal(os)
  os:marshalInt32(self.husongcfgid)
  os:marshalInt32(self.husong_couple_npc_cfgid)
end
function SHuSongRes:unmarshal(os)
  self.husongcfgid = os:unmarshalInt32()
  self.husong_couple_npc_cfgid = os:unmarshalInt32()
end
function SHuSongRes:sizepolicy(size)
  return size <= 65535
end
return SHuSongRes
