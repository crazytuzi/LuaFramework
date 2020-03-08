local XiangFangInfo = require("netio.protocol.mzm.gsp.gang.XiangFangInfo")
local CangKuInfo = require("netio.protocol.mzm.gsp.gang.CangKuInfo")
local JinKuInfo = require("netio.protocol.mzm.gsp.gang.JinKuInfo")
local YaoDianInfo = require("netio.protocol.mzm.gsp.gang.YaoDianInfo")
local ShuYuanInfo = require("netio.protocol.mzm.gsp.gang.ShuYuanInfo")
local SSyncGangInfo = class("SSyncGangInfo")
SSyncGangInfo.TYPEID = 12589852
function SSyncGangInfo:ctor(gangId, name, bangZhu, level, money, vitality, purpose, designDutyNameId, createTime, xueTuMaxLevel, buildEndTime, tanHeEndTime, tanHeRoleId, memberList, announcementList, xiangFangInfo, cangKuInfo, jinKuInfo, yaoDianInfo, mapInstanceId, shuYuanInfo, isSign, signStr, fuli_timestamp, mifang_start_time, mifang_end_time, displayid, teams)
  self.id = 12589852
  self.gangId = gangId or nil
  self.name = name or nil
  self.bangZhu = bangZhu or nil
  self.level = level or nil
  self.money = money or nil
  self.vitality = vitality or nil
  self.purpose = purpose or nil
  self.designDutyNameId = designDutyNameId or nil
  self.createTime = createTime or nil
  self.xueTuMaxLevel = xueTuMaxLevel or nil
  self.buildEndTime = buildEndTime or nil
  self.tanHeEndTime = tanHeEndTime or nil
  self.tanHeRoleId = tanHeRoleId or nil
  self.memberList = memberList or {}
  self.announcementList = announcementList or {}
  self.xiangFangInfo = xiangFangInfo or XiangFangInfo.new()
  self.cangKuInfo = cangKuInfo or CangKuInfo.new()
  self.jinKuInfo = jinKuInfo or JinKuInfo.new()
  self.yaoDianInfo = yaoDianInfo or YaoDianInfo.new()
  self.mapInstanceId = mapInstanceId or nil
  self.shuYuanInfo = shuYuanInfo or ShuYuanInfo.new()
  self.isSign = isSign or nil
  self.signStr = signStr or nil
  self.fuli_timestamp = fuli_timestamp or nil
  self.mifang_start_time = mifang_start_time or nil
  self.mifang_end_time = mifang_end_time or nil
  self.displayid = displayid or nil
  self.teams = teams or {}
end
function SSyncGangInfo:marshal(os)
  os:marshalInt64(self.gangId)
  os:marshalString(self.name)
  os:marshalString(self.bangZhu)
  os:marshalInt32(self.level)
  os:marshalInt32(self.money)
  os:marshalInt32(self.vitality)
  os:marshalString(self.purpose)
  os:marshalInt32(self.designDutyNameId)
  os:marshalInt32(self.createTime)
  os:marshalInt32(self.xueTuMaxLevel)
  os:marshalInt32(self.buildEndTime)
  os:marshalInt32(self.tanHeEndTime)
  os:marshalInt64(self.tanHeRoleId)
  os:marshalCompactUInt32(table.getn(self.memberList))
  for _, v in ipairs(self.memberList) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.announcementList))
  for _, v in ipairs(self.announcementList) do
    v:marshal(os)
  end
  self.xiangFangInfo:marshal(os)
  self.cangKuInfo:marshal(os)
  self.jinKuInfo:marshal(os)
  self.yaoDianInfo:marshal(os)
  os:marshalInt32(self.mapInstanceId)
  self.shuYuanInfo:marshal(os)
  os:marshalInt32(self.isSign)
  os:marshalString(self.signStr)
  os:marshalInt64(self.fuli_timestamp)
  os:marshalInt64(self.mifang_start_time)
  os:marshalInt64(self.mifang_end_time)
  os:marshalInt64(self.displayid)
  os:marshalCompactUInt32(table.getn(self.teams))
  for _, v in ipairs(self.teams) do
    v:marshal(os)
  end
end
function SSyncGangInfo:unmarshal(os)
  self.gangId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.bangZhu = os:unmarshalString()
  self.level = os:unmarshalInt32()
  self.money = os:unmarshalInt32()
  self.vitality = os:unmarshalInt32()
  self.purpose = os:unmarshalString()
  self.designDutyNameId = os:unmarshalInt32()
  self.createTime = os:unmarshalInt32()
  self.xueTuMaxLevel = os:unmarshalInt32()
  self.buildEndTime = os:unmarshalInt32()
  self.tanHeEndTime = os:unmarshalInt32()
  self.tanHeRoleId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.MemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.memberList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.GangAnnouncement")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.announcementList, v)
  end
  self.xiangFangInfo = XiangFangInfo.new()
  self.xiangFangInfo:unmarshal(os)
  self.cangKuInfo = CangKuInfo.new()
  self.cangKuInfo:unmarshal(os)
  self.jinKuInfo = JinKuInfo.new()
  self.jinKuInfo:unmarshal(os)
  self.yaoDianInfo = YaoDianInfo.new()
  self.yaoDianInfo:unmarshal(os)
  self.mapInstanceId = os:unmarshalInt32()
  self.shuYuanInfo = ShuYuanInfo.new()
  self.shuYuanInfo:unmarshal(os)
  self.isSign = os:unmarshalInt32()
  self.signStr = os:unmarshalString()
  self.fuli_timestamp = os:unmarshalInt64()
  self.mifang_start_time = os:unmarshalInt64()
  self.mifang_end_time = os:unmarshalInt64()
  self.displayid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.GangTeam")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teams, v)
  end
end
function SSyncGangInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncGangInfo
