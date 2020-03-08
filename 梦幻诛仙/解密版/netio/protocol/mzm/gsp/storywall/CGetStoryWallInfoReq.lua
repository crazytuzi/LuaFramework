local CGetStoryWallInfoReq = class("CGetStoryWallInfoReq")
CGetStoryWallInfoReq.TYPEID = 12606468
function CGetStoryWallInfoReq:ctor()
  self.id = 12606468
end
function CGetStoryWallInfoReq:marshal(os)
end
function CGetStoryWallInfoReq:unmarshal(os)
end
function CGetStoryWallInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetStoryWallInfoReq
