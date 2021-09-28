if not CLifeItemData then
  CLifeItemData = class("CLifeItemData", CItemData)
end
function CLifeItemData:ctor(playerId, objId, lTypeId, copyProperties)
  CLifeItemData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CLifeItemData:LoadItemPropertyFromData()
  local pairs = pairs
  local itemId = self:getTypeId()
  local data_table = GetItemDataByItemTypeId(itemId)[itemId]
  local pro_dict_table = {ITEM_COMMON_ProList}
  if data_table then
    for _, dict in pairs(pro_dict_table) do
      for k, v in pairs(dict) do
        local v_ = data_table[v]
        if v_ then
          self:setProperty(v, v_)
        end
      end
    end
  else
    printLogDebug("lifeitem_data", "读取导表失败，类型ID:%d", self:getTypeId())
  end
end
