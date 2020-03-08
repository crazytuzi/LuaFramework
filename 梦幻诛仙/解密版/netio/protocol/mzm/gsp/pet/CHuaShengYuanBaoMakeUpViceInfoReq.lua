local CHuaShengYuanBaoMakeUpViceInfoReq = class("CHuaShengYuanBaoMakeUpViceInfoReq")
CHuaShengYuanBaoMakeUpViceInfoReq.TYPEID = 12590680
function CHuaShengYuanBaoMakeUpViceInfoReq:ctor(mainPetId)
  self.id = 12590680
  self.mainPetId = mainPetId or nil
end
function CHuaShengYuanBaoMakeUpViceInfoReq:marshal(os)
  os:marshalInt64(self.mainPetId)
end
function CHuaShengYuanBaoMakeUpViceInfoReq:unmarshal(os)
  self.mainPetId = os:unmarshalInt64()
end
function CHuaShengYuanBaoMakeUpViceInfoReq:sizepolicy(size)
  return size <= 65535
end
return CHuaShengYuanBaoMakeUpViceInfoReq
