local SSyncGangMiFangTimeEnd = class("SSyncGangMiFangTimeEnd")
SSyncGangMiFangTimeEnd.TYPEID = 12589917
function SSyncGangMiFangTimeEnd:ctor()
  self.id = 12589917
end
function SSyncGangMiFangTimeEnd:marshal(os)
end
function SSyncGangMiFangTimeEnd:unmarshal(os)
end
function SSyncGangMiFangTimeEnd:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMiFangTimeEnd
