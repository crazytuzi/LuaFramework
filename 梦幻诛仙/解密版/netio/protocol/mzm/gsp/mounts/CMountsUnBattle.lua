local CMountsUnBattle = class("CMountsUnBattle")
CMountsUnBattle.TYPEID = 12606221
function CMountsUnBattle:ctor(cell_id)
  self.id = 12606221
  self.cell_id = cell_id or nil
end
function CMountsUnBattle:marshal(os)
  os:marshalInt32(self.cell_id)
end
function CMountsUnBattle:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
end
function CMountsUnBattle:sizepolicy(size)
  return size <= 65535
end
return CMountsUnBattle
