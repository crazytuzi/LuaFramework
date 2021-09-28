RechargeExtend = {}
function RechargeExtend.extend(object)
  object.m_CanShowRechargeView = false
  object.m_CanShowRechargeItemList = {}
  object.m_MoMoChongzhiFanliStartTime = nil
  object.m_MoMoChongzhiFanliEndTime = nil
  object.m_XiaoFeiFanliStartTime = nil
  object.m_XiaoFeiFanliEndTime = nil
  object.m_XiaoFeiFanliUseGold = 0
  object.m_XiaoFeiFanliAddGold = 0
  object.m_PaiMaiShenShouStartTime = nil
  object.m_PaiMaiShenShouEndTime = nil
  object.m_PaiMaiShenShouData = {}
  object.m_FanliData = {}
  function object:setCanShowRechargeView(flag)
    object.m_CanShowRechargeView = flag
    SendMessage(MsgID_ChongZhi_Open)
  end
  function object:getCanShowRechargeView()
    return true
  end
  function object:setCanShowRechargeItemList(list)
    object.m_CanShowRechargeItemList = list
    SendMessage(MsgID_ChongZhi_ItemListUpdate)
    dump(list, "RechargeItemList*******************")
  end
  function object:getCanShowRechargeItemList()
    return object.m_CanShowRechargeItemList
  end
  function object:JudgeCanBuyGift(shopItemNo)
    for _, no in pairs(object.m_CanShowRechargeItemList) do
      if no == shopItemNo then
        return true
      end
    end
    return false
  end
  function object:updateFanliData(awardId, state)
    object.m_FanliData[awardId] = state
    SendMessage(MsgID_ChongZhiFanli_Update)
  end
  function object:getFanliData()
    return object.m_FanliData
  end
  function object:getCanGetFanliAward()
    for _, state in pairs(object.m_FanliData) do
      if state == 2 then
        return true
      end
    end
    return false
  end
  function object:setMoMoChongZhiFanliTime(startTime, endTime)
    object.m_MoMoChongzhiFanliStartTime = startTime
    object.m_MoMoChongzhiFanliEndTime = endTime
    SendMessage(MsgID_MAIL_ChongZhiFanli_Update)
  end
  function object:getMoMoChongZhiFanliTime()
    return object.m_MoMoChongzhiFanliStartTime, object.m_MoMoChongzhiFanliEndTime
  end
  function object:JudgeCanGetChongZhiFanli()
    local curTime = g_DataMgr:getServerTime()
    if object.m_MoMoChongzhiFanliStartTime and object.m_MoMoChongzhiFanliEndTime and curTime > object.m_MoMoChongzhiFanliStartTime and curTime < object.m_MoMoChongzhiFanliEndTime then
      return true
    end
    return false
  end
  function object:setXiaoFeiFanLiData(startTime, endTime, xiaofeiNum, addNum)
    object.m_XiaoFeiFanliStartTime = startTime or object.m_XiaoFeiFanliStartTime
    object.m_XiaoFeiFanliEndTime = endTime or object.m_XiaoFeiFanliEndTime
    object.m_XiaoFeiFanliUseGold = xiaofeiNum or object.m_XiaoFeiFanliUseGold
    object.m_XiaoFeiFanliAddGold = addNum or object.m_XiaoFeiFanliAddGold
    SendMessage(MsgID_MAIL_XiaoFeiFanli_Update)
  end
  function object:getXiaoFeiFanLiTime()
    return object.m_XiaoFeiFanliStartTime, object.m_XiaoFeiFanliEndTime
  end
  function object:getXiaoFeiFanLiData()
    return object.m_XiaoFeiFanliUseGold, object.m_XiaoFeiFanliAddGold
  end
  function object:JudgeCanGetXiaoFeiFanLi()
    local curTime = g_DataMgr:getServerTime()
    if object.m_XiaoFeiFanliStartTime and object.m_XiaoFeiFanliEndTime and curTime > object.m_XiaoFeiFanliStartTime and curTime < object.m_XiaoFeiFanliEndTime then
      return true
    end
    return false
  end
  function object:setPaiMaiShenShouTime(startTime, endTime)
    object.m_PaiMaiShenShouStartTime = startTime
    object.m_PaiMaiShenShouEndTime = endTime
    SendMessage(MsgID_PaiMaiShenShouUpdate)
  end
  function object:getPaiMaiShenShouTime()
    return object.m_PaiMaiShenShouStartTime, object.m_PaiMaiShenShouEndTime
  end
  function object:setPaiMaiShenShouData(list)
    object.m_PaiMaiShenShouData = list or {}
    SendMessage(MsgID_PaiMaiShenShouUpdate)
  end
  function object:getPaiMaiShenShouData()
    return object.m_PaiMaiShenShouData
  end
  function object:JudgeCanGetPaiMaiShenShou()
    local curTime = g_DataMgr:getServerTime()
    if object.m_PaiMaiShenShouStartTime == nil or object.m_PaiMaiShenShouEndTime == nil then
      return false
    end
    if object.m_PaiMaiShenShouData == nil then
      return false
    end
    if curTime <= object.m_PaiMaiShenShouStartTime or curTime >= object.m_PaiMaiShenShouEndTime then
      return false
    end
    for _, petData in pairs(object.m_PaiMaiShenShouData) do
      if petData.i_s == nil or petData.i_s == 0 then
        return true
      end
    end
    return false
  end
  function object:JudgeCanGetXianQiSuiPian()
    if activity.guoqingMgr and activity.guoqingMgr:getStatus() == 1 then
      return true
    end
    return false
  end
  function object:getGetXianQiSuiPianTime()
    if activity.guoqingMgr then
      return activity.guoqingMgr:getTimeData()
    end
    return nil, nil
  end
  function object:JudgeCanPlayerGetXQSP()
    if object:JudgeCanGetXianQiSuiPian() == false then
      return false
    end
    if activity.guoqingMgr then
      return activity.guoqingMgr:getCanPlayerGetXQSP()
    end
    return false
  end
  function object:JudgeCanGetBenZhouTeMai()
    for _, shopItem in pairs(WEEKLY_SHOP_ITEM_LIST) do
      if object:JudgeCanBuyGift(shopItem) then
        return true
      end
    end
    return false
  end
end
return RechargeExtend
