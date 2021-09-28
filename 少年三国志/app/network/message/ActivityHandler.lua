local ActivityHandler = class("ActivityHandler ", require("app.network.message.HandlerBase"))

function ActivityHandler:_onCtor( ... )

end

function ActivityHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_LiquorInfo, self._recvLiquorInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Drink, self._recvDrink, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_MrGuanInfo, self._recvMrGuanInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Worship, self._recvWorship, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_LoginRewardInfo, self._recvLoginRewardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_LoginReward, self._recvLoginReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetHolidayEventInfo, self._recvHolidayEventInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetHolidayEventAward, self._recvGetHolidayEventAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRechargeBack, self._recvGetRechargeBack, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RechargeBackGold, self._recvRechargeBackGold, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetPhoneBindNotice, self._recvGetPhoneBindNotice, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_VipDiscountInfo, self._recvVipDiscountInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BuyVipDiscount, self._recvBuyVipDiscount, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_VipDailyInfo, self._recvVipDailyInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_BuyVipDaily, self._recvBuyVipDaily, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetSpreadId, self._recvGetSpreadId, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RegisterId, self._recvRegisterId, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_InvitorGetRewardInfo, self._recvInvitorGetRewardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_InvitorDrawLvlReward, self._recvInvitorDrawLvlReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_InvitorDrawScoreReward, self._recvInvitorDrawScoreReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_InvitedDrawReward, self._recvInvitedDrawReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_InvitedGetDrawReward, self._recvInvitedGetDrawReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_QueryRegisterRelation, self._recvQueryRegisterRelation, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetInvitorName, self._recvGetInvitorName, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_VipWeekShopInfo, self._recvVipWeekShopInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_VipWeekShopBuy, self._recvVipWeekShopBuy, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetOlderPlayerInfo, self._recvOldUserInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetOlderPlayerVipExp, self._recvOldUserVipExp, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetOlderPlayerVipAward, self._recvOldUserVipAward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetOlderPlayerLevelAward, self._recvOldUserGift, self)

    -- 开服7日战力榜
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDays7CompInfo, self._recvSevenCompInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetDays7CompAward, self._recvSevenCompAward, self)

    -- 招财符
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FortuneInfo, self._recvFortuneInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FortuneBuySilver, self._recvFortuneBuySilver, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FortuneGetBox, self._recvFortuneGetBox, self)
end

-------------recv messages

function ActivityHandler:_recvLiquorInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_LiquorInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --print( "cs.S2C_LiquorInfo")
    -- dump(decodeBuffer)


    G_Me.activityData.wine.initData.status = 1
    G_Me.activityData.wine.initData.lastUpdate =  G_ServerTime:getTime()


    G_Me.activityData.wine.state = decodeBuffer.state
    G_Me.activityData.wine.next_time = decodeBuffer.next_time

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_DATA_WINE_UPDATED, nil, false, decodeBuffer)
end


function ActivityHandler:_recvDrink( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Drink", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --print("cs.S2C_Drink")
    -- todo
    -- dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.wine.initData.lastUpdate =  G_ServerTime:getTime()
        G_Me.activityData.wine.state = decodeBuffer.state
         --这里更新状态,其实最好更新状态不要放在之类, 因为单独发一调协议过来.但是寥寥不愿意改,so..
   
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_DATA_WINE_UPDATED, nil, false, decodeBuffer)

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_FINISH_WINE, nil, false, decodeBuffer)

        
    end
    


    

end


function ActivityHandler:_recvMrGuanInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_MrGuanInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --print("cs.S2C_MrGuanInfo")
    -- todo
    -- dump(decodeBuffer)


    G_Me.activityData.caishen.initData.status = 1
    G_Me.activityData.caishen.initData.lastUpdate =  G_ServerTime:getTime()

    G_Me.activityData.caishen.today_count = decodeBuffer.today_count
    G_Me.activityData.caishen.total_count = decodeBuffer.total_count
    G_Me.activityData.caishen.next_time = decodeBuffer.next_time


    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_DATA_CAISHEN_UPDATED, nil, false, decodeBuffer)
   
end


function ActivityHandler:_recvWorship( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Worship", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
 
    
    --print("cs.S2C_Worship")
    -- todo
    -- dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_FINISH_CAISHEN, nil, false, decodeBuffer.award)
        
    end
    


end

-- message S2C_LoginRewardInfo {
--   required uint32 total1 = 1;     // 普通签到已签到次数
--   required uint32 last_time1 = 2; // 普通签到上次签到时间
--   required uint32 vipid = 3;     // 豪华签到今日奖励id
--   required uint32 last_time_vip = 4; // 豪华签到上次签到时间
--   required bool cost = 5; // 今日是否已充值
-- }

function ActivityHandler:_recvLoginRewardInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_LoginRewardInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    G_Me.activityData.daily.initData.status = 1
    G_Me.activityData.daily.initData.lastUpdate =  G_ServerTime:getTime()

    G_Me.activityData.daily.total1 = decodeBuffer.total1
    G_Me.activityData.daily.vipid = decodeBuffer.vipid
    G_Me.activityData.daily.last_time1 = decodeBuffer.last_time1
    G_Me.activityData.daily.last_time_vip = decodeBuffer.last_time_vip
    G_Me.activityData.daily.cost = decodeBuffer.cost
    G_Me.activityData.daily.vip_available = decodeBuffer.vip_available
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_DATA_DAILY_UPDATED, nil, false, decodeBuffer)
     
    
end


function ActivityHandler:_recvLoginReward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_LoginReward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    __LogTag("ldx", "cs.S2C_LoginReward")

    -- todo
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        if decodeBuffer.type == 0 then
            --普通签到
            G_Me.activityData.daily.total1 = decodeBuffer.total
        else
            --豪华签到
            G_Me.activityData.daily.vipid = decodeBuffer.vipid
        end 
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_FINISH_DAILY, nil, false, decodeBuffer)

    end
    
end

function ActivityHandler:_recvGetRechargeBack( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRechargeBack", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.fanhuan:init(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GETRECHARGEBACK, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvRechargeBackGold( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RechargeBackGold", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.fanhuan:setHas(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECHARGEBACKGOLD, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvGetPhoneBindNotice( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetPhoneBindNotice", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    -- if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.phone:setNotice(decodeBuffer.notice)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GETPHONEBINDNOTICE, nil, false, decodeBuffer)

    -- end

end

function ActivityHandler:_recvVipDiscountInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_VipDiscountInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.vipDiscount:init(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIPDISCOUNTINFO, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvBuyVipDiscount( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BuyVipDiscount", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.vipDiscount:buySuccess()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BUYVIPDISCOUNT, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvVipDailyInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_VipDailyInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.vipDiscount:initDaily(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIPDAILYINFO, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvBuyVipDaily( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_BuyVipDaily", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.vipDiscount:getDaily()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_BUYVIPDAILY, nil, false, decodeBuffer)

    end

end


function ActivityHandler:_recvVipWeekShopInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_VipWeekShopInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    G_Me.activityData.vipDiscount:initShopInfo(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIPWEEKSHOPINFO, nil, false, decodeBuffer)

end

function ActivityHandler:_recvVipWeekShopBuy( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_VipWeekShopBuy", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    -- dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.vipDiscount:updateShopInfo(self._vipWeekShopBuyId)
        decodeBuffer.id = self._vipWeekShopBuyId
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_VIPWEEKSHOPBUY, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvGetSpreadId( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetSpreadId", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.invitor.spreadId = decodeBuffer.id
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GETSPREADID, nil, false, decodeBuffer)

    end
end

function ActivityHandler:_recvRegisterId( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RegisterId", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.invited:updateBindState(true)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_REGISTERID, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvInvitorGetRewardInfo( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_InvitorGetRewardInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    G_Me.activityData.invitor:initData(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_INVITORGETREWARDINFO, nil, false, decodeBuffer)

end

function ActivityHandler:_recvInvitorDrawLvlReward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_InvitorDrawLvlReward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then

        G_Me.activityData.invitor:getOneReward(self._invitorDrawRewardId)
        decodeBuffer.rewardId = self._invitorDrawRewardId
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_INVITORDRAWLVLREWARD, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvInvitorDrawScoreReward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_InvitorDrawScoreReward", msg, len)
    G_Me.activityData.invitor:drawScore()
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_INVITORDRAWSCOREREWARD, nil, false, decodeBuffer)
end

function ActivityHandler:_recvInvitedDrawReward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_InvitedDrawReward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.invited:got(self._invitedDrawRewardId)
        decodeBuffer.rewardId = self._invitedDrawRewardId
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_INVITEDDRAWREWARD, nil, false, decodeBuffer)

    end

end

function ActivityHandler:_recvInvitedGetDrawReward( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_InvitedGetDrawReward", msg, len)
    --dump(decodeBuffer)
    if rawget(decodeBuffer,"list") then
        G_Me.activityData.invited.gotList = decodeBuffer.list
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_INVITEDGETDRAWREWARD, nil, false, decodeBuffer)

end

function ActivityHandler:_recvQueryRegisterRelation( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_QueryRegisterRelation", msg, len)
    G_Me.activityData.invited:updateBindState(decodeBuffer.rret)
    --dump(decodeBuffer)
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_QUERYREGISTERRELATION, nil, false, decodeBuffer)

end

function ActivityHandler:_recvGetInvitorName( msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetInvitorName", msg, len)
    --dump(decodeBuffer)
    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GETINVITORNAME, nil, false, decodeBuffer)
    end
end

function ActivityHandler:_recvOldUserInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetOlderPlayerInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.userReturn:init(decodeBuffer)

        if G_Me.activityData.userReturn:isOldUser() then
            self:sendGetOldUserVipExp()
        end

        --uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_OLD_USER_INFO, nil, false)
    end
end

function ActivityHandler:_recvOldUserVipExp( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetOlderPlayerVipExp", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.userReturn:setVipExp(rawget(decodeBuffer, "exp"))
        --uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_OLD_USER_VIP_EXP, nil, false)
    end
end

function ActivityHandler:_recvOldUserVipAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetOlderPlayerVipAward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.userReturn:setHasGotVipExp()
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_OLD_USER_VIP_AWARD, nil, false)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    end
end

function ActivityHandler:_recvOldUserGift( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetOlderPlayerLevelAward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.userReturn:setHasGotGift(decodeBuffer.id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_OLD_USER_GIFT, nil, false, decodeBuffer.id)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
    end
end

function ActivityHandler:_recvSevenCompInfo( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetDays7CompInfo", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end

    -- dump(decodeBuffer)

    if decodeBuffer.ret == NetMsg_ERROR.RET_DAYS_SEVEN_COMP_SWITCH_CLOSE then
        G_Me.activityData.sevenDayFightValueRank:setClosedByServer()
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        if rawget(decodeBuffer, "infos") then
            G_Me.activityData.sevenDayFightValueRank:setCompRankInfo(decodeBuffer.infos)
        end
        if rawget(decodeBuffer, "me") then
            G_Me.activityData.sevenDayFightValueRank:setMyCompInfo(decodeBuffer.me)
        end
    end
    G_Me.activityData.sevenDayFightValueRank:setServerOpenTime(decodeBuffer.oszt)

    __Log("================open time " .. G_ServerTime:getTimeString(decodeBuffer.oszt))

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SEVEN_DAY_FIGHT_VALUE_RANK_COMP_INFO, nil, false, decodeBuffer)
end

function ActivityHandler:_recvSevenCompAward( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetDays7CompAward", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.sevenDayFightValueRank:setMyAwardsFlag(0)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SEVEN_DAY_FIGHT_VALUE_RANK_GET_AWARD, nil, false, decodeBuffer.awards)
    end
end

function ActivityHandler:_recvFortuneInfo( msgId, msg, len )
   local decodeBuffer = self:_decodeBuf("cs.S2C_FortuneInfo", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end

    -- if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.fortune:setTimes(decodeBuffer.times)
        G_Me.activityData.fortune:setBoxStatus(decodeBuffer.boxids)
        if rawget(decodeBuffer, "buys") then
            G_Me.activityData.fortune:setFortuneDetailInfo(decodeBuffer.buys)
        else
            G_Me.activityData.fortune:setFortuneDetailInfo({})
            G_Me.activityData.fortune:setTotalMoney({})
        end
        G_Me.activityData.fortune:setTotalMoney(decodeBuffer.buys)

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_FORTUNE_GET_INFO, nil, false, decodeBuffer)
        -- dump(decodeBuffer)
    -- end 
end

function ActivityHandler:_recvFortuneBuySilver( msgId, msg, len )
   local decodeBuffer = self:_decodeBuf("cs.S2C_FortuneBuySilver", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.fortune:setTimes(G_Me.activityData.fortune:getTimes() + 1)
        G_Me.activityData.fortune:updateTotalMoney(decodeBuffer.buy.silver)
        G_Me.activityData.fortune:updateFortuneDetailInfo(decodeBuffer.buy)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_FORTUNE_BUY_SUCCEED, nil, false, decodeBuffer)
        -- dump(decodeBuffer)
    end  
end

function ActivityHandler:_recvFortuneGetBox( msgId, msg, len )
    local decodeBuffer = self:_decodeBuf("cs.S2C_FortuneGetBox", msg, len)

    if type(decodeBuffer) ~= "table" then
        return
    end

    if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
        G_Me.activityData.fortune:updateBoxStatus({decodeBuffer.bid})
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_FORTUNE_GET_BOX_AWARD, nil, false, decodeBuffer)
        -- dump(decodeBuffer)
    end 
end

-------------send messages

function ActivityHandler:sendLiquorInfo( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_LiquorInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_LiquorInfo, msgBuffer)
end

--喝酒
function ActivityHandler:sendDrink( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_Drink", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Drink, msgBuffer)
end


function ActivityHandler:sendMrGuanInfo( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_MrGuanInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_MrGuanInfo, msgBuffer)
end

--拜神
function ActivityHandler:sendWorship( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_Worship", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_Worship, msgBuffer)
end


function ActivityHandler:sendLoginRewardInfo( )
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_LoginRewardInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_LoginRewardInfo, msgBuffer)
end

--获取每日奖励
function ActivityHandler:sendLoginReward(_type)
    local msg = {
       -- todo
       type = _type
    }
    local msgBuffer = protobuf.encode("cs.C2S_LoginReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_LoginReward, msgBuffer)
end


--获取圣诞活动
function ActivityHandler:sendHolidayEventInfo()
    local msg = {
       -- todo
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetHolidayEventInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetHolidayEventInfo, msgBuffer)
end

function ActivityHandler:_recvHolidayEventInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetHolidayEventInfo", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == 1 then
        G_Me.activityData.holiday:setExchangeList(decodeBuffer)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HOLIDAY_ACTIVITY_INFO, nil, false, decodeBuffer)
end

--获取圣诞活动
function ActivityHandler:sendGetHolidayEventAward(id)
    local msg = {
       -- todo
       id=id
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetHolidayEventAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetHolidayEventAward, msgBuffer)
end

function ActivityHandler:_recvGetHolidayEventAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetHolidayEventAward", msg, len)

    if type(decodeBuffer) ~= "table" then 
        return 
    end
    --dump(decodeBuffer)
    if decodeBuffer.ret == 1 then
        G_Me.activityData.holiday:setExchangeListNumById(decodeBuffer.id,decodeBuffer.num)
    end
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_HOLIDAY_ACTIVITY_AWARD, nil, false, decodeBuffer)
end

function ActivityHandler:sendGetRechargeBack()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetRechargeBack", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetRechargeBack, msgBuffer)
end

function ActivityHandler:sendRechargeBackGold()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RechargeBackGold", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RechargeBackGold, msgBuffer)
end

function ActivityHandler:sendGetPhoneBindNotice()
-- print("sendGetPhoneBindNotice")
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetPhoneBindNotice", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetPhoneBindNotice, msgBuffer)
end

function ActivityHandler:sendBuyVipDiscount(_id)
    local msg = {
        id = _id
    }
    G_Me.activityData.vipDiscount.buyId = _id
    local msgBuffer = protobuf.encode("cs.C2S_BuyVipDiscount", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BuyVipDiscount, msgBuffer)
end

function ActivityHandler:sendVipDiscountInfo()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_VipDiscountInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_VipDiscountInfo, msgBuffer)
end

function ActivityHandler:sendBuyVipDaily()
    local msg = {

    }
    local msgBuffer = protobuf.encode("cs.C2S_BuyVipDaily", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_BuyVipDaily, msgBuffer)
end

function ActivityHandler:sendVipDailyInfo()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_VipDailyInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_VipDailyInfo, msgBuffer)
end

function ActivityHandler:sendVipWeekShopBuy(_id)
    local msg = {
        id = _id ,
        num = 1
    }
    self._vipWeekShopBuyId = _id
    local msgBuffer = protobuf.encode("cs.C2S_VipWeekShopBuy", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_VipWeekShopBuy, msgBuffer)
end

function ActivityHandler:sendVipWeekShopInfo()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_VipWeekShopInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_VipWeekShopInfo, msgBuffer)
end

function ActivityHandler:sendGetSpreadId()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetSpreadId", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetSpreadId, msgBuffer)
end

function ActivityHandler:sendRegisterId(id)
    local msg = {
        id = id,
    }
    --dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_RegisterId", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_RegisterId, msgBuffer)
end

function ActivityHandler:sendInvitorGetRewardInfo()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_InvitorGetRewardInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_InvitorGetRewardInfo, msgBuffer)
end

function ActivityHandler:sendInvitorDrawLvlReward(reward_id,invited_id,invited_sid,invited_name,invited_qua)
    local msg = {
        reward_id = reward_id,
        invited_id = invited_id,
        invited_sid = invited_sid,
        invited_name = invited_name,
        invited_qua = invited_qua,
    }
    self._invitorDrawRewardId = reward_id
    local msgBuffer = protobuf.encode("cs.C2S_InvitorDrawLvlReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_InvitorDrawLvlReward, msgBuffer)
end

function ActivityHandler:sendInvitorDrawScoreReward()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_InvitorDrawScoreReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_InvitorDrawScoreReward, msgBuffer)
end

function ActivityHandler:sendInvitedDrawReward(id)
    local msg = {
        id = id 
    }
    self._invitedDrawRewardId = id
    local msgBuffer = protobuf.encode("cs.C2S_InvitedDrawReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_InvitedDrawReward, msgBuffer)
end

function ActivityHandler:sendInvitedGetDrawReward()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_InvitedGetDrawReward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_InvitedGetDrawReward, msgBuffer)
end

function ActivityHandler:sendQueryRegisterRelation()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_QueryRegisterRelation", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_QueryRegisterRelation, msgBuffer)
end

function ActivityHandler:sendGetInvitorName(id)
    local msg = {
        invitor_code = id 
    }
    --dump(msg)
    local msgBuffer = protobuf.encode("cs.C2S_GetInvitorName", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetInvitorName, msgBuffer)
end

function ActivityHandler:sendGetOldUserInfo()
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetOlderPlayerInfo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetOlderPlayerInfo, msgBuffer)
end

function ActivityHandler:sendGetOldUserVipExp()
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetOlderPlayerVipExp", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetOlderPlayerVipExp, msgBuffer)
end

function ActivityHandler:sendGetOldUserVipAward()
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetOlderPlayerVipExp", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetOlderPlayerVipAward, msgBuffer)
end

function ActivityHandler:sendGetOldUserGift(giftId)
    local msg = { id = giftId }
    local msgBuffer = protobuf.encode("cs.C2S_GetOlderPlayerLevelAward", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetOlderPlayerLevelAward, msgBuffer)
end

function ActivityHandler:sendGetSevenDayCompInfo(  )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetDays7CompInfo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetDays7CompInfo, msgBuffer)
end

function ActivityHandler:sendGetSevenDayAward(  )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_GetDays7CompAward", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_GetDays7CompAward, msgBuffer)
end

function ActivityHandler:sendGetFortuneInfo(  )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_FortuneInfo", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_FortuneInfo, msgBuffer)
end

function ActivityHandler:sendFortuneBuySilver(  )
    local msg = {}
    local msgBuffer = protobuf.encode("cs.C2S_FortuneBuySilver", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_FortuneBuySilver, msgBuffer)
end

function ActivityHandler:sendFortuneGetBox( boxId )
    local msg = {id = boxId}
    local msgBuffer = protobuf.encode("cs.C2S_FortuneGetBox", msg)
    self:sendMsg(NetMsg_ID.ID_C2S_FortuneGetBox, msgBuffer)
end

return ActivityHandler
