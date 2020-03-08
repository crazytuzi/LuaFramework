local SSynCrossBattleCurrentActivityCfgid = class("SSynCrossBattleCurrentActivityCfgid")
SSynCrossBattleCurrentActivityCfgid.TYPEID = 12617052
function SSynCrossBattleCurrentActivityCfgid:ctor(activity_cfg_id)
  self.id = 12617052
  self.activity_cfg_id = activity_cfg_id or nil
end
function SSynCrossBattleCurrentActivityCfgid:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SSynCrossBattleCurrentActivityCfgid:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SSynCrossBattleCurrentActivityCfgid:sizepolicy(size)
  return size <= 65535
end
return SSynCrossBattleCurrentActivityCfgid
