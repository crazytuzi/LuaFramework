local CF5DayTarget = class("CF5DayTarget")
CF5DayTarget.TYPEID = 12597004
function CF5DayTarget:ctor(curGold)
  self.id = 12597004
  self.curGold = curGold or nil
end
function CF5DayTarget:marshal(os)
  os:marshalInt64(self.curGold)
end
function CF5DayTarget:unmarshal(os)
  self.curGold = os:unmarshalInt64()
end
function CF5DayTarget:sizepolicy(size)
  return size <= 65535
end
return CF5DayTarget
