local SLevelGuideAwardNotice = class("SLevelGuideAwardNotice")
SLevelGuideAwardNotice.TYPEID = 12597002
function SLevelGuideAwardNotice:ctor()
  self.id = 12597002
end
function SLevelGuideAwardNotice:marshal(os)
end
function SLevelGuideAwardNotice:unmarshal(os)
end
function SLevelGuideAwardNotice:sizepolicy(size)
  return size <= 65535
end
return SLevelGuideAwardNotice
