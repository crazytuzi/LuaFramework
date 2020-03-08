local SSyncGangMaintain = class("SSyncGangMaintain")
SSyncGangMaintain.TYPEID = 12589839
function SSyncGangMaintain:ctor(costMoney)
  self.id = 12589839
  self.costMoney = costMoney or nil
end
function SSyncGangMaintain:marshal(os)
  os:marshalInt32(self.costMoney)
end
function SSyncGangMaintain:unmarshal(os)
  self.costMoney = os:unmarshalInt32()
end
function SSyncGangMaintain:sizepolicy(size)
  return size <= 65535
end
return SSyncGangMaintain
