local SCorpsNormalInfo = class("SCorpsNormalInfo")
SCorpsNormalInfo.TYPEID = 12617485
SCorpsNormalInfo.CREATE_CORPS_ERR__NAME_ILLEGAL = 1
SCorpsNormalInfo.CREATE_CORPS_ERR__NAME_DUPLICATE = 2
SCorpsNormalInfo.CREATE_CORPS_ERR__DECLARATION_ILLEGAL = 3
SCorpsNormalInfo.INVITE_CORPS_ERR__IN_ANOTHER_CORPS = 20
SCorpsNormalInfo.INVITE_CORPS_ERR__ILLEGAL_LEVEL = 21
SCorpsNormalInfo.INVITE_CORPS_ERR__CORPS_FULL = 22
SCorpsNormalInfo.INVITE_CORPS_ERR__DUPLICATE_INVITE = 23
SCorpsNormalInfo.INVITE_CORPS_REP__TIMEOUT = 40
SCorpsNormalInfo.JOIN_CORPS__CORPS_FULL = 41
SCorpsNormalInfo.RENAME_CORPS_ERR__NAME_ILLEGAL = 60
SCorpsNormalInfo.RENAME_CORPS_ERR__NAME_DUPLICATE = 61
SCorpsNormalInfo.RP_DECLARATION_ERR__DECLARATION_ILLEGAL = 62
function SCorpsNormalInfo:ctor(result, args)
  self.id = 12617485
  self.result = result or nil
  self.args = args or {}
end
function SCorpsNormalInfo:marshal(os)
  os:marshalInt32(self.result)
  os:marshalCompactUInt32(table.getn(self.args))
  for _, v in ipairs(self.args) do
    os:marshalOctets(v)
  end
end
function SCorpsNormalInfo:unmarshal(os)
  self.result = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalOctets()
    table.insert(self.args, v)
  end
end
function SCorpsNormalInfo:sizepolicy(size)
  return size <= 65535
end
return SCorpsNormalInfo
