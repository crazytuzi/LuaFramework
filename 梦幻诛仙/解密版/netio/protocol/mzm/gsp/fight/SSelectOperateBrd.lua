local SSelectOperateBrd = class("SSelectOperateBrd")
SSelectOperateBrd.TYPEID = 12594180
function SSelectOperateBrd:ctor(fighterid, op_type, content, auto)
  self.id = 12594180
  self.fighterid = fighterid or nil
  self.op_type = op_type or nil
  self.content = content or nil
  self.auto = auto or nil
end
function SSelectOperateBrd:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.op_type)
  os:marshalOctets(self.content)
  os:marshalInt32(self.auto)
end
function SSelectOperateBrd:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.op_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
  self.auto = os:unmarshalInt32()
end
function SSelectOperateBrd:sizepolicy(size)
  return size <= 65535
end
return SSelectOperateBrd
