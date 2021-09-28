function getLingShouByLSZY()
  local lszyItemId
  for _, itemTypeId in pairs({
    ITEM_DEF_OTHER_LSZY_CE,
    ITEM_DEF_OTHER_LSZY_JH,
    ITEM_DEF_OTHER_LSZY_YM,
    ITEM_DEF_OTHER_LSZY_GZ,
    ITEM_DEF_OTHER_LSZY_TW
  }) do
    local itemId = g_LocalPlayer:GetOneItemIdByType(itemTypeId)
    if itemId ~= nil and itemId ~= 0 then
      lszyItemId = itemId
      break
    end
  end
  if lszyItemId == nil or lszyItemId == 0 then
    ShowNotifyTips("你没有灵兽之源，无法兑换")
    return
  end
  netsend.netitem.requestUseItem(lszyItemId)
end
