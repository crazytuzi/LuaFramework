local SCrossBattleOwnLoginProcessDone = class("SCrossBattleOwnLoginProcessDone")
SCrossBattleOwnLoginProcessDone.TYPEID = 12617040
function SCrossBattleOwnLoginProcessDone:ctor(activity_cfg_id)
  self.id = 12617040
  self.activity_cfg_id = activity_cfg_id or nil
end
function SCrossBattleOwnLoginProcessDone:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SCrossBattleOwnLoginProcessDone:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SCrossBattleOwnLoginProcessDone:sizepolicy(size)
  return size <= 65535
end
return SCrossBattleOwnLoginProcessDone
