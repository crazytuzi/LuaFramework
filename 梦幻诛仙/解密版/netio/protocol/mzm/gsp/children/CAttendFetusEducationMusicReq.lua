local CAttendFetusEducationMusicReq = class("CAttendFetusEducationMusicReq")
CAttendFetusEducationMusicReq.TYPEID = 12609294
function CAttendFetusEducationMusicReq:ctor()
  self.id = 12609294
end
function CAttendFetusEducationMusicReq:marshal(os)
end
function CAttendFetusEducationMusicReq:unmarshal(os)
end
function CAttendFetusEducationMusicReq:sizepolicy(size)
  return size <= 65535
end
return CAttendFetusEducationMusicReq
