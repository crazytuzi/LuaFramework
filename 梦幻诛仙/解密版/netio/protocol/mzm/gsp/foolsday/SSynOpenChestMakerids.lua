local SSynOpenChestMakerids = class("SSynOpenChestMakerids")
SSynOpenChestMakerids.TYPEID = 12612876
function SSynOpenChestMakerids:ctor(activity_cfg_id, open_chest_maker_ids)
  self.id = 12612876
  self.activity_cfg_id = activity_cfg_id or nil
  self.open_chest_maker_ids = open_chest_maker_ids or {}
end
function SSynOpenChestMakerids:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalCompactUInt32(table.getn(self.open_chest_maker_ids))
  for _, v in ipairs(self.open_chest_maker_ids) do
    os:marshalInt64(v)
  end
end
function SSynOpenChestMakerids:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.open_chest_maker_ids, v)
  end
end
function SSynOpenChestMakerids:sizepolicy(size)
  return size <= 65535
end
return SSynOpenChestMakerids
