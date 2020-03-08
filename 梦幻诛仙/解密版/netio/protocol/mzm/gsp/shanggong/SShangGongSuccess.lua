local SShangGongSuccess = class("SShangGongSuccess")
SShangGongSuccess.TYPEID = 12610564
function SShangGongSuccess:ctor(shanggong_id, sort_id)
  self.id = 12610564
  self.shanggong_id = shanggong_id or nil
  self.sort_id = sort_id or nil
end
function SShangGongSuccess:marshal(os)
  os:marshalInt32(self.shanggong_id)
  os:marshalInt32(self.sort_id)
end
function SShangGongSuccess:unmarshal(os)
  self.shanggong_id = os:unmarshalInt32()
  self.sort_id = os:unmarshalInt32()
end
function SShangGongSuccess:sizepolicy(size)
  return size <= 65535
end
return SShangGongSuccess
