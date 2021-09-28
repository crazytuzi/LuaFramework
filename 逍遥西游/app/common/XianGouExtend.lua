ShopXianGouExtend = {}
function ShopXianGouExtend.extend(object)
  object.m_XianGouShopList = {}
  object.m_XianGouShopUpdateTimer = nil
  function object:SetXianGouShopList(list)
    local newList = {}
    local changePageList = {}
    for xgId, _ in pairs(object.m_XianGouShopList) do
      if data_ShopXianGou[xgId] ~= nil then
        local pageNum = data_ShopXianGou[xgId].shopNum
        changePageList[pageNum] = true
      end
    end
    for _, tData in pairs(list) do
      local xgId = tData.no
      local endTimePoint = tData.tp
      local num = tData.num
      if xgId then
        newList[xgId] = {endTimePoint = endTimePoint, num = num}
        if data_ShopXianGou[xgId] ~= nil then
          local pageNum = data_ShopXianGou[xgId].shopNum
          changePageList[pageNum] = true
        end
      end
    end
    object.m_XianGouShopList = newList
    if object.m_XianGouShopUpdateTimer then
      scheduler.unscheduleGlobal(object.m_XianGouShopUpdateTimer)
    end
    object.m_XianGouShopUpdateTimer = scheduler.scheduleGlobal(function()
      if object.CheckXianGouShopList then
        object:CheckXianGouShopList()
      end
    end, 1)
    SendMessage(MsgID_ShopXianGouListChange, changePageList)
  end
  function object:GetXianGouShopList()
    return object.m_XianGouShopList
  end
  function object:CheckXianGouShopList()
    local delList = {}
    local curTime = g_DataMgr:getServerTime()
    for xgId, xgData in pairs(object.m_XianGouShopList) do
      local endTime = xgData.endTimePoint
      if curTime > endTime then
        delList[#delList + 1] = xgId
      end
    end
    local changeFlag = false
    local changePageList = {}
    for _, xgId in pairs(delList) do
      changeFlag = true
      object.m_XianGouShopList[xgId] = nil
      if data_ShopXianGou[xgId] ~= nil then
        local pageNum = data_ShopXianGou[xgId].shopNum
        changePageList[pageNum] = true
      end
    end
    if changeFlag then
      SendMessage(MsgID_ShopXianGouListChange, changePageList)
    end
  end
  function object:DelXianGouUpdateTimer()
    if object.m_XianGouShopUpdateTimer then
      scheduler.unscheduleGlobal(object.m_XianGouShopUpdateTimer)
      object.m_XianGouShopUpdateTimer = nil
    end
  end
end
return ShopXianGouExtend
