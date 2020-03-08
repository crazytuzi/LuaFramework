local SFestivalNormalRet = class("SFestivalNormalRet")
SFestivalNormalRet.TYPEID = 12600071
SFestivalNormalRet.TAKE_FESTIVAL_AWARD_NOT_IN_FESTIVAL_TIME = 0
SFestivalNormalRet.TAKE_FESTIVAL_AWARD_BAG_FULL = 1
SFestivalNormalRet.TAKE_FESTIVAL_AWARD_UNKNOW = 3
function SFestivalNormalRet:ctor(ret, args)
  self.id = 12600071
  self.ret = ret or nil
  self.args = args or {}
end
function SFestivalNormalRet:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SFestivalNormalRet:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SFestivalNormalRet:sizepolicy(size)
  return size <= 65535
end
return SFestivalNormalRet
