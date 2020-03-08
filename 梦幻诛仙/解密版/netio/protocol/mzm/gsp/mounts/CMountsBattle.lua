local CMountsBattle = class("CMountsBattle")
CMountsBattle.TYPEID = 12606217
function CMountsBattle:ctor(cell_id, mounts_id)
  self.id = 12606217
  self.cell_id = cell_id or nil
  self.mounts_id = mounts_id or nil
end
function CMountsBattle:marshal(os)
  os:marshalInt32(self.cell_id)
  os:marshalInt64(self.mounts_id)
end
function CMountsBattle:unmarshal(os)
  self.cell_id = os:unmarshalInt32()
  self.mounts_id = os:unmarshalInt64()
end
function CMountsBattle:sizepolicy(size)
  return size <= 65535
end
return CMountsBattle
