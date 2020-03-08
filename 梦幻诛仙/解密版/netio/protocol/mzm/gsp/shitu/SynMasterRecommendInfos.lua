local SynMasterRecommendInfos = class("SynMasterRecommendInfos")
SynMasterRecommendInfos.TYPEID = 12601661
function SynMasterRecommendInfos:ctor(sessionid, all_master_recommend_infos)
  self.id = 12601661
  self.sessionid = sessionid or nil
  self.all_master_recommend_infos = all_master_recommend_infos or {}
end
function SynMasterRecommendInfos:marshal(os)
  os:marshalInt64(self.sessionid)
  os:marshalCompactUInt32(table.getn(self.all_master_recommend_infos))
  for _, v in ipairs(self.all_master_recommend_infos) do
    v:marshal(os)
  end
end
function SynMasterRecommendInfos:unmarshal(os)
  self.sessionid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfoAndModelInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.all_master_recommend_infos, v)
  end
end
function SynMasterRecommendInfos:sizepolicy(size)
  return size <= 65535
end
return SynMasterRecommendInfos
