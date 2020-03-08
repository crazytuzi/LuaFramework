local SJiuXiaoWinBossRes = class("SJiuXiaoWinBossRes")
SJiuXiaoWinBossRes.TYPEID = 12595470
function SJiuXiaoWinBossRes:ctor(cfgid)
  self.id = 12595470
  self.cfgid = cfgid or nil
end
function SJiuXiaoWinBossRes:marshal(os)
  os:marshalInt32(self.cfgid)
end
function SJiuXiaoWinBossRes:unmarshal(os)
  self.cfgid = os:unmarshalInt32()
end
function SJiuXiaoWinBossRes:sizepolicy(size)
  return size <= 65535
end
return SJiuXiaoWinBossRes
