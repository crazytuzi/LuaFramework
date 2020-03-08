local PictureInfo = require("netio.protocol.mzm.gsp.question.PictureInfo")
local SSyncPictureInfo = class("SSyncPictureInfo")
SSyncPictureInfo.TYPEID = 12594734
function SSyncPictureInfo:ctor(info)
  self.id = 12594734
  self.info = info or PictureInfo.new()
end
function SSyncPictureInfo:marshal(os)
  self.info:marshal(os)
end
function SSyncPictureInfo:unmarshal(os)
  self.info = PictureInfo.new()
  self.info:unmarshal(os)
end
function SSyncPictureInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncPictureInfo
