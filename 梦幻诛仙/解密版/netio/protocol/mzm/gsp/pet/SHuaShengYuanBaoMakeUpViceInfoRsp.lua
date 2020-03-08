local SHuaShengYuanBaoMakeUpViceInfoRsp = class("SHuaShengYuanBaoMakeUpViceInfoRsp")
SHuaShengYuanBaoMakeUpViceInfoRsp.TYPEID = 12590679
function SHuaShengYuanBaoMakeUpViceInfoRsp:ctor(mainPetId, viceCfgId, needYuanBaoCount, skillCount)
  self.id = 12590679
  self.mainPetId = mainPetId or nil
  self.viceCfgId = viceCfgId or nil
  self.needYuanBaoCount = needYuanBaoCount or nil
  self.skillCount = skillCount or nil
end
function SHuaShengYuanBaoMakeUpViceInfoRsp:marshal(os)
  os:marshalInt64(self.mainPetId)
  os:marshalInt32(self.viceCfgId)
  os:marshalInt32(self.needYuanBaoCount)
  os:marshalInt32(self.skillCount)
end
function SHuaShengYuanBaoMakeUpViceInfoRsp:unmarshal(os)
  self.mainPetId = os:unmarshalInt64()
  self.viceCfgId = os:unmarshalInt32()
  self.needYuanBaoCount = os:unmarshalInt32()
  self.skillCount = os:unmarshalInt32()
end
function SHuaShengYuanBaoMakeUpViceInfoRsp:sizepolicy(size)
  return size <= 65535
end
return SHuaShengYuanBaoMakeUpViceInfoRsp
