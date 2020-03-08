local OctetsStream = require("netio.OctetsStream")
local EnterPosition = class("EnterPosition")
function EnterPosition:ctor(curx, cury, targetx, targety, direction)
  self.curx = curx or nil
  self.cury = cury or nil
  self.targetx = targetx or nil
  self.targety = targety or nil
  self.direction = direction or nil
end
function EnterPosition:marshal(os)
  os:marshalInt32(self.curx)
  os:marshalInt32(self.cury)
  os:marshalInt32(self.targetx)
  os:marshalInt32(self.targety)
  os:marshalInt32(self.direction)
end
function EnterPosition:unmarshal(os)
  self.curx = os:unmarshalInt32()
  self.cury = os:unmarshalInt32()
  self.targetx = os:unmarshalInt32()
  self.targety = os:unmarshalInt32()
  self.direction = os:unmarshalInt32()
end
return EnterPosition
