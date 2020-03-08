local OuterInfo = require("netio.protocol.mzm.gsp.xiaohuikuaipao.OuterInfo")
local SOuterDrawRsp = class("SOuterDrawRsp")
SOuterDrawRsp.TYPEID = 12622855
function SOuterDrawRsp:ctor(activityId, outerInfo, awardInfoList, stepCountList)
  self.id = 12622855
  self.activityId = activityId or nil
  self.outerInfo = outerInfo or OuterInfo.new()
  self.awardInfoList = awardInfoList or {}
  self.stepCountList = stepCountList or {}
end
function SOuterDrawRsp:marshal(os)
  os:marshalInt32(self.activityId)
  self.outerInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.awardInfoList))
  for _, v in ipairs(self.awardInfoList) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.stepCountList))
  for _, v in ipairs(self.stepCountList) do
    os:marshalInt32(v)
  end
end
function SOuterDrawRsp:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.outerInfo = OuterInfo.new()
  self.outerInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.xiaohuikuaipao.AwardInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.awardInfoList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.stepCountList, v)
  end
end
function SOuterDrawRsp:sizepolicy(size)
  return size <= 65535
end
return SOuterDrawRsp
