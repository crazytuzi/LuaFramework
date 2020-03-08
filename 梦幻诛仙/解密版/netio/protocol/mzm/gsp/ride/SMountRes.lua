local SMountRes = class("SMountRes")
SMountRes.TYPEID = 797953
function SMountRes:ctor(rideCfgId)
  self.id = 797953
  self.rideCfgId = rideCfgId or nil
end
function SMountRes:marshal(os)
  os:marshalInt32(self.rideCfgId)
end
function SMountRes:unmarshal(os)
  self.rideCfgId = os:unmarshalInt32()
end
function SMountRes:sizepolicy(size)
  return size <= 65535
end
return SMountRes
