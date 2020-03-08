local SCurrentWeekCannotAccept = class("SCurrentWeekCannotAccept")
SCurrentWeekCannotAccept.TYPEID = 12587569
function SCurrentWeekCannotAccept:ctor()
  self.id = 12587569
end
function SCurrentWeekCannotAccept:marshal(os)
end
function SCurrentWeekCannotAccept:unmarshal(os)
end
function SCurrentWeekCannotAccept:sizepolicy(size)
  return size <= 65535
end
return SCurrentWeekCannotAccept
