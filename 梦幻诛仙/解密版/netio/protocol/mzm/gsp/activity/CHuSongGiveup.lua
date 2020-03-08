local CHuSongGiveup = class("CHuSongGiveup")
CHuSongGiveup.TYPEID = 12587559
function CHuSongGiveup:ctor()
  self.id = 12587559
end
function CHuSongGiveup:marshal(os)
end
function CHuSongGiveup:unmarshal(os)
end
function CHuSongGiveup:sizepolicy(size)
  return size <= 65535
end
return CHuSongGiveup
