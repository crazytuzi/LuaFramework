local HandlerBase = require("app.network.message.HandlerBase")
local TimePrivilegeHandler = class("TimePrivilegeHandler", HandlerBase)


function TimePrivilegeHandler:_onCtor( ... )
	
end

function TimePrivilegeHandler:initHandler( ... )
    __Log("--TimePrivilegeHandler--")
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ShopTimeInfo, self.recvShopTimeInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ShopTimeRewardInfo, self.recvShopTimeRewardInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ShopTimeGetReward, self.recvShopTimeGetReward, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ShopTimePurchase, self.recvShopTimePurchase, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ShopTimeStartTime, self.recvShopTimeStartTime, self)


end

-- 进入限时优惠商店时拉取
function TimePrivilegeHandler:sendShopTimeInfo()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_ShopTimeInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ShopTimeInfo, msgBuffer)    
end


function TimePrivilegeHandler:recvShopTimeInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_ShopTimeInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timePrivilegeData:storeInitInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_INIT_MAIN_LAYER, nil, false, nil)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON, nil, false, nil)
    end
end


-- 全民奖励
function TimePrivilegeHandler:sendShopTimeRewardInfo()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_ShopTimeRewardInfo", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ShopTimeRewardInfo, msgBuffer)    
end


function TimePrivilegeHandler:recvShopTimeRewardInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ShopTimeRewardInfo", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timePrivilegeData:storeClaimAwardList(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_AWARD_INFO_SUCC, nil, false, nil)
    end
end

-- 领取全民奖励
function TimePrivilegeHandler:sendShopTimeGetReward(nId)
    local tMsg = {
        id = nId 
    }
    local msgBuffer = protobuf.encode("cs.C2S_ShopTimeGetReward", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ShopTimeGetReward, msgBuffer)    
end


function TimePrivilegeHandler:recvShopTimeGetReward(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ShopTimeGetReward", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then   
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_AWARD_SUCC, nil, false, decodeBuffer)
    end
end

-- 购买一个商品成功
function TimePrivilegeHandler:recvShopTimePurchase(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ShopTimePurchase", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timePrivilegeData:storeInitInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_BUY_GOODS_SUCC, nil, false, nil)
    end
end

-- 开服时间
function TimePrivilegeHandler:sendShopTimeStartTime()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_ShopTimeStartTime", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ShopTimeStartTime, msgBuffer)    
end


function TimePrivilegeHandler:recvShopTimeStartTime(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ShopTimeStartTime", msg)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer.ret == G_NetMsgError.RET_OK then
        G_Me.timePrivilegeData:storeStartTime(decodeBuffer.start_time)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_GET_OPEN_SERVER_SUCC, nil, false, nil)
    end
end


return TimePrivilegeHandler


