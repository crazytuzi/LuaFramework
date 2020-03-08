local CHuSongReq = class("CHuSongReq")
CHuSongReq.TYPEID = 12587549
CHuSongReq.HU_SONG_NORMAL_SREVICEID = 150205052
CHuSongReq.HU_SONG_SPECIAL_SREVICEID = 150205053
CHuSongReq.HU_SONG_DEC_SREVICEID = 150205054
function CHuSongReq:ctor(huSongType)
  self.id = 12587549
  self.huSongType = huSongType or nil
end
function CHuSongReq:marshal(os)
  os:marshalInt32(self.huSongType)
end
function CHuSongReq:unmarshal(os)
  self.huSongType = os:unmarshalInt32()
end
function CHuSongReq:sizepolicy(size)
  return size <= 65535
end
return CHuSongReq
