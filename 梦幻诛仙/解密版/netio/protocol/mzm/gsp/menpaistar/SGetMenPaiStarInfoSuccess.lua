local MenPaiStarInfo = require("netio.protocol.mzm.gsp.menpaistar.MenPaiStarInfo")
local SGetMenPaiStarInfoSuccess = class("SGetMenPaiStarInfoSuccess")
SGetMenPaiStarInfoSuccess.TYPEID = 12612357
function SGetMenPaiStarInfoSuccess:ctor(menpai_star_info)
  self.id = 12612357
  self.menpai_star_info = menpai_star_info or MenPaiStarInfo.new()
end
function SGetMenPaiStarInfoSuccess:marshal(os)
  self.menpai_star_info:marshal(os)
end
function SGetMenPaiStarInfoSuccess:unmarshal(os)
  self.menpai_star_info = MenPaiStarInfo.new()
  self.menpai_star_info:unmarshal(os)
end
function SGetMenPaiStarInfoSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetMenPaiStarInfoSuccess
