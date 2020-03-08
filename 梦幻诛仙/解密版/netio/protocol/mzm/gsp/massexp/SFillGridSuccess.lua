local SFillGridSuccess = class("SFillGridSuccess")
SFillGridSuccess.TYPEID = 12608262
function SFillGridSuccess:ctor(cur_index)
  self.id = 12608262
  self.cur_index = cur_index or nil
end
function SFillGridSuccess:marshal(os)
  os:marshalInt32(self.cur_index)
end
function SFillGridSuccess:unmarshal(os)
  self.cur_index = os:unmarshalInt32()
end
function SFillGridSuccess:sizepolicy(size)
  return size <= 65535
end
return SFillGridSuccess
