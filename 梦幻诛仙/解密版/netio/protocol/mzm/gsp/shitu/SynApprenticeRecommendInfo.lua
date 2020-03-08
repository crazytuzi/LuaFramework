local ShiTuRoleInfoAndModelInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfoAndModelInfo")
local SynApprenticeRecommendInfo = class("SynApprenticeRecommendInfo")
SynApprenticeRecommendInfo.TYPEID = 12601660
function SynApprenticeRecommendInfo:ctor(apprentice_recommend_info)
  self.id = 12601660
  self.apprentice_recommend_info = apprentice_recommend_info or ShiTuRoleInfoAndModelInfo.new()
end
function SynApprenticeRecommendInfo:marshal(os)
  self.apprentice_recommend_info:marshal(os)
end
function SynApprenticeRecommendInfo:unmarshal(os)
  self.apprentice_recommend_info = ShiTuRoleInfoAndModelInfo.new()
  self.apprentice_recommend_info:unmarshal(os)
end
function SynApprenticeRecommendInfo:sizepolicy(size)
  return size <= 65535
end
return SynApprenticeRecommendInfo
