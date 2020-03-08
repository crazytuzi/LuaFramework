local SSyncEndHuSong = class("SSyncEndHuSong")
SSyncEndHuSong.TYPEID = 12590898
function SSyncEndHuSong:ctor()
  self.id = 12590898
end
function SSyncEndHuSong:marshal(os)
end
function SSyncEndHuSong:unmarshal(os)
end
function SSyncEndHuSong:sizepolicy(size)
  return size <= 65535
end
return SSyncEndHuSong
