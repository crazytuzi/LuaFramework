local CShangGongReq = class("CShangGongReq")
CShangGongReq.TYPEID = 12610563
function CShangGongReq:ctor(shanggong_id, sessionid, sort_id, money_type, money_num)
  self.id = 12610563
  self.shanggong_id = shanggong_id or nil
  self.sessionid = sessionid or nil
  self.sort_id = sort_id or nil
  self.money_type = money_type or nil
  self.money_num = money_num or nil
end
function CShangGongReq:marshal(os)
  os:marshalInt32(self.shanggong_id)
  os:marshalInt64(self.sessionid)
  os:marshalInt32(self.sort_id)
  os:marshalInt32(self.money_type)
  os:marshalInt32(self.money_num)
end
function CShangGongReq:unmarshal(os)
  self.shanggong_id = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
  self.sort_id = os:unmarshalInt32()
  self.money_type = os:unmarshalInt32()
  self.money_num = os:unmarshalInt32()
end
function CShangGongReq:sizepolicy(size)
  return size <= 65535
end
return CShangGongReq
