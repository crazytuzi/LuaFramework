local SCoupleNormalRet = class("SCoupleNormalRet")
SCoupleNormalRet.TYPEID = 12600585
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_TARGET_DO_NOT_WEAR_AIR_CRAFT = 0
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_TARGET_IN_ACTIVITY = 1
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_TARGET_IN_TEAM = 2
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_TARGET_IN_COUPLE_RIDE = 3
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_OUT_OF_DATE = 4
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_MAP_CAN_NOT_FLY = 5
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_OTHER_IN_MODEL_CHANGE = 6
SCoupleNormalRet.REFUSE_OR_AGREE_RIDE_IN_MODEL_CHANGE = 7
function SCoupleNormalRet:ctor(ret, args)
  self.id = 12600585
  self.ret = ret or nil
  self.args = args or {}
end
function SCoupleNormalRet:marshal(os)
  os:marshalInt32(self.ret)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCoupleNormalRet:unmarshal(os)
  self.ret = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCoupleNormalRet:sizepolicy(size)
  return size <= 65535
end
return SCoupleNormalRet
