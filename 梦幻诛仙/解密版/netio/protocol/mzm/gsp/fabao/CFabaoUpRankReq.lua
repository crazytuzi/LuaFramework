local CFabaoUpRankReq = class("CFabaoUpRankReq")
CFabaoUpRankReq.TYPEID = 12595970
function CFabaoUpRankReq:ctor(equiped, fabaouuid, useyuanbao)
  self.id = 12595970
  self.equiped = equiped or nil
  self.fabaouuid = fabaouuid or nil
  self.useyuanbao = useyuanbao or nil
end
function CFabaoUpRankReq:marshal(os)
  os:marshalInt32(self.equiped)
  os:marshalInt64(self.fabaouuid)
  os:marshalInt32(self.useyuanbao)
end
function CFabaoUpRankReq:unmarshal(os)
  self.equiped = os:unmarshalInt32()
  self.fabaouuid = os:unmarshalInt64()
  self.useyuanbao = os:unmarshalInt32()
end
function CFabaoUpRankReq:sizepolicy(size)
  return size <= 65535
end
return CFabaoUpRankReq
