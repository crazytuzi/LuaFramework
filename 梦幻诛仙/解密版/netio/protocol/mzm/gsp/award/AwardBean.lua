local OctetsStream = require("netio.OctetsStream")
local AwardBean = class("AwardBean")
AwardBean.AWARD_TYPE__ROLE_EXP = 1
AwardBean.AWARD_TYPE__SILVER = 10
AwardBean.AWARD_ADD_TYPE__LEADER = 1
AwardBean.AWARD_ADD_TYPE__TEAM = 2
AwardBean.AWARD_ADD_TYPE__STABLE_TEAM = 3
AwardBean.AWARD_ADD_TYPE__SWORN = 4
AwardBean.AWARD_ADD_TYPE__MARRIAGE = 5
AwardBean.AWARD_MOD_TYPE__SERVER = 20
AwardBean.AWARD_MOD_TYPE__QQ_N_VIP = 100
AwardBean.AWARD_MOD_TYPE__QQ_S_VIP = 101
AwardBean.AWARD_MOD_TYPE__QQ_GAME_CENTER = 102
AwardBean.AWARD_MOD_TYPE__WECAHT_GAME_CENTER = 103
AwardBean.AWARD_MOD_TYPE__APP_GAME_CENTER = 104
function AwardBean:ctor(yuanbao, gold, silver, gang, goldIngot, roleExp, petExp, xiulianExp, petExpMap, itemMap, tokenMap, awardAddMap)
  self.yuanbao = yuanbao or nil
  self.gold = gold or nil
  self.silver = silver or nil
  self.gang = gang or nil
  self.goldIngot = goldIngot or nil
  self.roleExp = roleExp or nil
  self.petExp = petExp or nil
  self.xiulianExp = xiulianExp or nil
  self.petExpMap = petExpMap or {}
  self.itemMap = itemMap or {}
  self.tokenMap = tokenMap or {}
  self.awardAddMap = awardAddMap or {}
end
function AwardBean:marshal(os)
  os:marshalInt64(self.yuanbao)
  os:marshalInt64(self.gold)
  os:marshalInt64(self.silver)
  os:marshalInt32(self.gang)
  os:marshalInt32(self.goldIngot)
  os:marshalInt32(self.roleExp)
  os:marshalInt32(self.petExp)
  os:marshalInt32(self.xiulianExp)
  do
    local _size_ = 0
    for _, _ in pairs(self.petExpMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.petExpMap) do
      os:marshalInt64(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.itemMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.itemMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  do
    local _size_ = 0
    for _, _ in pairs(self.tokenMap) do
      _size_ = _size_ + 1
    end
    os:marshalCompactUInt32(_size_)
    for k, v in pairs(self.tokenMap) do
      os:marshalInt32(k)
      os:marshalInt32(v)
    end
  end
  local _size_ = 0
  for _, _ in pairs(self.awardAddMap) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.awardAddMap) do
    os:marshalInt32(k)
    v:marshal(os)
  end
end
function AwardBean:unmarshal(os)
  self.yuanbao = os:unmarshalInt64()
  self.gold = os:unmarshalInt64()
  self.silver = os:unmarshalInt64()
  self.gang = os:unmarshalInt32()
  self.goldIngot = os:unmarshalInt32()
  self.roleExp = os:unmarshalInt32()
  self.petExp = os:unmarshalInt32()
  self.xiulianExp = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt64()
    local v = os:unmarshalInt32()
    self.petExpMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.itemMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.tokenMap[k] = v
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local BeanClazz = require("netio.protocol.mzm.gsp.award.AwardAddBean")
    local v = BeanClazz.new()
    v:unmarshal(os)
    self.awardAddMap[k] = v
  end
end
return AwardBean
