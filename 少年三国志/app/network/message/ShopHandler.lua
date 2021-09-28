local HandlerBase = require("app.network.message.HandlerBase")
local ShopHandler = class("ArenaHandler",HandlerBase)
local BagConst = require("app.const.BagConst")
require("app.const.ShopType")
require("app.cfg.shop_score_info")
require("app.cfg.month_card_info")
function ShopHandler:ctor(...)
   
end

function ShopHandler:initHandler( ... )
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_EnterShop, self._recvShopInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_Shopping, self._recvBuyMsg, self)
    
    --抽卡相关
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitLp, self._recvDropGoodKnightMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitLpTen, self._recvDropGoodKnightTenMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitJp, self._recvDropGodlyKnightMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitJpTen, self._recvDropGodlyKnightTenMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitInfo, self._recvDropKnightInfoMsg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitJpTw, self._recvDropGodlyKnight20Msg, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecruitZy, self._recvZhenYingDropKnight, self)
    --阵营抽将
    
    --充值相关
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRecharge, self._recvRechargeInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_UseMonthCard, self._recvUseMonthCardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RechargeSuccess, self._revRechargeSuccess, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetRechargeBonus, self._recvFirstRechargeAward, self)
    
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCorpSpecialShop, self._recvGetCorpSpecialShop, self)

    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_CorpSpecialShopping, self._recvCorpSpecialShopping, self)
    
end


--发送购买信息
function ShopHandler:sendBuyItem(item_mod,item_id,item_size, option)
    __LogTag(TAG,"mode = %s,id = %s,item.Size = %s",item_mod,item_id,item_size)
    local BuyInfo = {
        size = item_size,
        mode = item_mod,
        id = item_id,
        index = option,
    }
    local isDiscount,discount = nil,nil
    if mode == SHOP_TYPE_SECRET_SHOP then
        isDiscount,discount = G_Me.activityData.custom:isSecretDiscount()
    elseif mode == SHOP_TYPE_SCORE then
        --检查折扣信息
        isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item_id)
    end
    if isDiscount then
        if discount < 500 or discount > 1000 then
            G_MovingTip:showMovingTip("该道具暂时无法购买")
            return
        end
    end

    __LogTag(TAG,"ShopHandler:sendBuyItem")
    local msgBuffer = protobuf.encode("cs.C2S_Shopping", BuyInfo) 
    self:sendMsg(NetMsg_ID.ID_C2S_Shopping, msgBuffer)
end

--接收购买消息
function ShopHandler:_recvBuyMsg(msgId, msg, len)
    __LogTag(TAG,"_recvBuyMsg messageId = %d",msgId)
    local decodeBuffer = self:_decodeBuf("cs.S2C_Shopping", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.mode == SHOP_TYPE_SCORE and decodeBuffer.ret == 1 then
            local info = shop_score_info.get(decodeBuffer.id)
            if info and info.shop == SCORE_TYPE.ZHUAN_PAN then
                --自己计算积分
                local info = shop_score_info.get(decodeBuffer.id)
                --[[
                    price_type == 10表示积分类型
                ]]
                if info and info.price_type == 10 then
                    local totalPrice = G_Me.shopData:getTotalPrice(info,decodeBuffer.size)
                    if G_Me.wheelData.score then
                        G_Me.wheelData.score = G_Me.wheelData.score - totalPrice
                    end
                    if G_Me.wheelData.score < 0 then
                        G_Me.wheelData.score = 0
                    end
                end 
            end
            G_Me.shopData:updateScorePurchaseNumById(decodeBuffer.id,decodeBuffer.size)
        end 

        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, nil, false, decodeBuffer)
    end
end

--进入商品发送消息
function ShopHandler:sendShopInfo(item_mode)
    local ShopInfo = {
        mode = item_mode,
    }
    __LogTag(TAG,"ShopHandler:sendShopInfo")
    local msgBuffer = protobuf.encode("cs.C2S_EnterShop", ShopInfo) 
    self:sendMsg(NetMsg_ID.ID_C2S_EnterShop, msgBuffer)
end

--接收商店消息
function ShopHandler:_recvShopInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_EnterShop", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        --获取到商店消息
        --dump(decodeBuffer)
        if decodeBuffer.mode == SHOP_TYPE_SCORE then
            G_Me.shopData:EnterScoreShop(decodeBuffer)
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_INFO, nil, false, decodeBuffer)
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------
-- 查询招募信息
function ShopHandler:sendDropKnightInfo()
    __LogTag(TAG,"ShopHandler:sendDropKnightInfo")
    local DropKnightInfo = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RecruitInfo", DropKnightInfo) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitInfo, msgBuffer)
end

--接收招募信息
function ShopHandler:_recvDropKnightInfoMsg(msgId, msg, len)
    __LogTag(TAG,"ShopHandler:_recvDropKnightInfoMsg")
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.shopData:setDropInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_KNIGHT_INFO, nil, false, decodeBuffer)
    end
end


--良品招将一次消息
function ShopHandler:sendDropGoodKnight(consumeType)
    __LogTag(TAG,"consumeType = %s",consumeType)
    local DropGoodKnight = {
        consume_type = consumeType,
    }
    local msgBuffer = protobuf.encode("cs.C2S_RecruitLp", DropGoodKnight) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitLp, msgBuffer)
end

--接收良品招将一次的消息
function ShopHandler:_recvDropGoodKnightMsg(msgId, msg, len)
    __LogTag(TAG,"ShopHandler:_recvDropGoodKnightMsg")
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitLp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.consume_type == 0 then
            G_Me.shopData.dropKnightInfo.lp_free_count = G_Me.shopData.dropKnightInfo.lp_free_count + 1
            G_Me.shopData.dropKnightInfo.lp_free_time = G_ServerTime:getTime() + BagConst.GOOD_KNIGHT_CD
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_GOOD_KNIGHT, nil, false, decodeBuffer)
    end
end

--良品招将十次消息
function ShopHandler:sendDropGoodKnightTen(consumeType)
    local DropGoodKnightTen = {
        consume_type = consumeType,
    }
    __LogTag(TAG,"ShopHandler:sendDropGoodKnightTen")
    local msgBuffer = protobuf.encode("cs.C2S_RecruitLpTen", DropGoodKnightTen) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitLpTen, msgBuffer)
end

--接收良品招将十次的消息
function ShopHandler:_recvDropGoodKnightTenMsg(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitLpTen", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_GOOD_KNIGHT, nil, false, decodeBuffer)
    end
end

--send极品招将一次消息
function ShopHandler:sendDropGodlyKnight(consumeType)
    local DropGodlyKnight = {
        consume_type = consumeType,
    }
    if consumeType == BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.MONEY then
        if not self:_checkDiscountEnabled() then
            return
        end
    end
    local msgBuffer = protobuf.encode("cs.C2S_RecruitJp", DropGodlyKnight) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitJp, msgBuffer)
end

function ShopHandler:_checkDiscountEnabled()
    --判断打折是否正确
    local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
    if isDiscount then
        if discount < 500 or discount > 1000 then
            G_MovingTip:showMovingTip("暂时不能进行此活动")
            return false
        end
    end
    return true
end

--receive极品招将一次的消息
function ShopHandler:_recvDropGodlyKnightMsg(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitJp", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.consume_type == 0 then
            G_Me.shopData.dropKnightInfo.jp_free_time = G_ServerTime:getTime() + BagConst.GOLD_KNIGHT_CD
        end
        G_Me.shopData.dropKnightInfo.jp_recruited_times = G_Me.shopData.dropKnightInfo.jp_recruited_times + #decodeBuffer.knight_base_id
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, nil, false, decodeBuffer)
    end
end

--send极品招将十次消息
function ShopHandler:sendDropGodlyKnightTen(consumeType)
    local DropGodlyKnightTen = {
        consume_type = consumeType,
    }
    if consumeType == BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.MONEY then
        if not self:_checkDiscountEnabled() then
            return
        end
    end
    local msgBuffer = protobuf.encode("cs.C2S_RecruitJpTen", DropGodlyKnightTen) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitJpTen, msgBuffer)
end

--receive极品招将十次的消息
function ShopHandler:_recvDropGodlyKnightTenMsg(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitJpTen", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.shopData.dropKnightInfo.jp_recruited_times = G_Me.shopData.dropKnightInfo.jp_recruited_times + 10
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, nil, false, decodeBuffer)
    end
end

--send极品招将20次消息
function ShopHandler:sendDropGodlyKnight20(consumeType)
    local DropGodlyKnight20 = {
        consume_type = consumeType,
    }
    if consumeType == BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.MONEY then
        if not self:_checkDiscountEnabled() then
            return
        end
    end
    local msgBuffer = protobuf.encode("cs.C2S_RecruitJpTw", DropGodlyKnight20) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitJpTw, msgBuffer)
end

--receive极品招将20次的消息
function ShopHandler:_recvDropGodlyKnight20Msg(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitJpTw", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT_20, nil, false, decodeBuffer)
    end
end

--阵营抽将
function ShopHandler:sendZhenYingDropKnight()
    local zy = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_RecruitZy", zy) 
    self:sendMsg(NetMsg_ID.ID_C2S_RecruitZy, msgBuffer)
end

--阵营抽将
function ShopHandler:_recvZhenYingDropKnight(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RecruitZy", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            G_Me.shopData.dropKnightInfo.zy_recruited_times = G_Me.shopData.dropKnightInfo.zy_recruited_times + 1
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_DROP_ZHEN_YING, nil, false, decodeBuffer)
    end
end


--获取充值信息
function ShopHandler:sendRechargeInfo()
    local recharge = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetRecharge", recharge) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetRecharge, msgBuffer)
end

function ShopHandler:_recvRechargeInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRecharge", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        G_Me.shopData:setRecharge(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_RECHARGE_INFO, nil, false, decodeBuffer)
    end 
end


--使用月卡
function ShopHandler:sendUseMonthCard(_id)
    local card = {
        id = _id
    }
    local msgBuffer = protobuf.encode("cs.C2S_UseMonthCard", card) 
    self:sendMsg(NetMsg_ID.ID_C2S_UseMonthCard, msgBuffer)
end


function ShopHandler:_recvUseMonthCardInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_UseMonthCard", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            G_Me.shopData:setMonthCardStatus(decodeBuffer.id)
            local card = month_card_info.get(decodeBuffer.id)
            if card then
                G_MovingTip:showMovingTip(G_lang:get("LANG_MONTH_CARD_AWARD",{gold=card.gold_back}))
            end
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_USE_MONTHCARD_INFO, nil, false, decodeBuffer)
    end 
end

function ShopHandler:_revRechargeSuccess(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_RechargeSuccess", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
        if decodeBuffer.ret == 1 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_RECHARGE_SUCCESS"))
        end
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, nil, false, decodeBuffer)
    end 
end
    

--首冲奖励
function ShopHandler:sendFirstRechargeAward(drop_id)
    local recharge = {
        id = drop_id
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetRechargeBonus", recharge) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetRechargeBonus, msgBuffer)
end

function ShopHandler:_recvFirstRechargeAward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetRechargeBonus", msg, len)
        if type(decodeBuffer) ~= "table" then 
            return 
        end
        if decodeBuffer then
            if rawget(decodeBuffer,"bonus") then
                G_Me.shopData:setFirstRechargeForActivity(decodeBuffer.bonus)
            end
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_RECHARGE_AWARD, nil, false, decodeBuffer)
        end 
end


--军团
function ShopHandler:sendGetCorpSpecialShop()
    local msg = {
    }
    local msgBuffer = protobuf.encode("cs.C2S_GetCorpSpecialShop", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetCorpSpecialShop, msgBuffer)
end

function ShopHandler:_recvGetCorpSpecialShop(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_GetCorpSpecialShop", msg, len)
        if type(decodeBuffer) ~= "table" then 
            return 
        end
        if decodeBuffer then
            G_Me.shopData:setCorpShopInfo(decodeBuffer)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_SHOP_INFO, nil, false, decodeBuffer)
        end 
end 


--发送购买
function ShopHandler:sendCorpSpecialShopping(_id)
    local msg = {
        id=_id;
    }

    local msgBuffer = protobuf.encode("cs.C2S_CorpSpecialShopping", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_CorpSpecialShopping, msgBuffer)
end

function ShopHandler:_recvCorpSpecialShopping(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_CorpSpecialShopping", msg, len)
        if type(decodeBuffer) ~= "table" then 
            return 
        end
        if decodeBuffer then
            G_Me.shopData:updateCorpItem(decodeBuffer)
            uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GET_CORP_SHOP_SHOPPING, nil, false, decodeBuffer)
        end 
end 

return ShopHandler

