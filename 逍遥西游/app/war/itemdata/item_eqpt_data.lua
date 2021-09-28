if not CEqptData then
  CEqptData = class("CEqptData", CItemData)
end
function CEqptData:ctor(playerId, objId, lTypeId, copyProperties)
  CEqptData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CEqptData:LoadItemPropertyFromData()
  local pairs = pairs
  local itemId = self:getTypeId()
  if itemId == nil then
    return
  end
  local data_table = GetItemDataByItemTypeId(itemId)[itemId]
  local pro_dict_table = {ITEM_COMMON_ProList, ITEM_EQPT_ONLY_ProList}
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
    printLogDebug("eqpt_data", "读取导表失败，类型ID:%d", self:getTypeId())
  end
end
