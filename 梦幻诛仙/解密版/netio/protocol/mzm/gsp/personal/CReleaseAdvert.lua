local SimpleAdvertInfo = require("netio.protocol.mzm.gsp.personal.SimpleAdvertInfo")
local CReleaseAdvert = class("CReleaseAdvert")
CReleaseAdvert.TYPEID = 12603659
function CReleaseAdvert:ctor(advert)
  self.id = 12603659
  self.advert = advert or SimpleAdvertInfo.new()
end
function CReleaseAdvert:marshal(os)
  self.advert:marshal(os)
end
function CReleaseAdvert:unmarshal(os)
  self.advert = SimpleAdvertInfo.new()
  self.advert:unmarshal(os)
end
function CReleaseAdvert:sizepolicy(size)
  return size <= 65535
end
return CReleaseAdvert
