local SChildAbortionNotify = class("SChildAbortionNotify")
SChildAbortionNotify.TYPEID = 12609392
function SChildAbortionNotify:ctor()
  self.id = 12609392
end
function SChildAbortionNotify:marshal(os)
end
function SChildAbortionNotify:unmarshal(os)
end
function SChildAbortionNotify:sizepolicy(size)
  return size <= 65535
end
return SChildAbortionNotify
