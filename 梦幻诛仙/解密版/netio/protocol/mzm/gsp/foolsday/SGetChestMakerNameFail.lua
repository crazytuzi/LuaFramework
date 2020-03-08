local SGetChestMakerNameFail = class("SGetChestMakerNameFail")
SGetChestMakerNameFail.TYPEID = 12612869
SGetChestMakerNameFail.MODULE_CLOSE_OR_ROLE_FORBIDDEN = -1
SGetChestMakerNameFail.ROLE_STATUS_ERROR = -2
SGetChestMakerNameFail.PARAM_ERROR = -3
SGetChestMakerNameFail.DB_ERROR = -4
SGetChestMakerNameFail.MAKER_ID_NOT_EXIST = 1
function SGetChestMakerNameFail:ctor(res)
  self.id = 12612869
  self.res = res or nil
end
function SGetChestMakerNameFail:marshal(os)
  os:marshalInt32(self.res)
end
function SGetChestMakerNameFail:unmarshal(os)
  self.res = os:unmarshalInt32()
end
function SGetChestMakerNameFail:sizepolicy(size)
  return size <= 65535
end
return SGetChestMakerNameFail
