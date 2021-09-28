if not CLianYaoShiData then
  CLianYaoShiData = class("CLianYaoShiData", CItemData)
end
function CLianYaoShiData:ctor(playerId, objId, lTypeId, copyProperties)
  CLianYaoShiData.super.ctor(self, playerId, objId, lTypeId, copyProperties)
end
function CLianYaoShiData:LoadItemPropertyFromData()
  local pairs = pairs
  local itemId = self:getTypeId()
  local data_table = GetItemDataByItemTypeId(itemId)[itemId]
  local pro_dict_table = {ITEM_COMMON_ProList, ITEM_LIANYAOSHI_ONLY_ProList}
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
    printLogDebug("lianyaoshi_data", "读取导表失败，类型ID:%d", self:getTypeId())
  end
end
