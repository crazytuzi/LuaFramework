local SStoryWallRefresh = class("SStoryWallRefresh")
SStoryWallRefresh.TYPEID = 12606467
function SStoryWallRefresh:ctor()
  self.id = 12606467
end
function SStoryWallRefresh:marshal(os)
end
function SStoryWallRefresh:unmarshal(os)
end
function SStoryWallRefresh:sizepolicy(size)
  return size <= 65535
end
return SStoryWallRefresh
