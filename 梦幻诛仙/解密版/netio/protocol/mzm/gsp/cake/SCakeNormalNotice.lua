local SCakeNormalNotice = class("SCakeNormalNotice")
SCakeNormalNotice.TYPEID = 12627723
SCakeNormalNotice.CLIENT_SERVER_TURN_DIFF = 1
SCakeNormalNotice.MAKE_CAKE_ERR__NOT_IN_SAME_FACTION = 2
SCakeNormalNotice.COLLECTION_ERR__NOT_IN_OWN_FACTION = 3
SCakeNormalNotice.EAT_SELF_TO_MAX = 20
SCakeNormalNotice.EAT_OTHER_TO_MAX = 21
SCakeNormalNotice.COLLECTION_START = 40
SCakeNormalNotice.ADD_CAKE_ERR_STAGE = 41
SCakeNormalNotice.ADD_CAKE_ERR_REPEAT = 42
SCakeNormalNotice.MAKE_CAKE_ERR_REPEAT = 43
SCakeNormalNotice.MAKE_CAKE_ERR_STAGE = 44
SCakeNormalNotice.COLLECTION_ERR_MAX = 45
SCakeNormalNotice.COOK_PERFECT = 60
SCakeNormalNotice.COOK_TERRIBLE = 61
SCakeNormalNotice.EAT_CAKE_DOUBLE = 80
function SCakeNormalNotice:ctor(result, args)
  self.id = 12627723
  self.result = result or nil
  self.args = args or {}
end
function SCakeNormalNotice:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalString(v)
  end
end
function SCakeNormalNotice:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalString()
    table.insert(self.args, v)
  end
end
function SCakeNormalNotice:sizepolicy(size)
  return size <= 65535
end
return SCakeNormalNotice
