
local HandlerBase = require("app.network.message.HandlerBase")
local ThemeDropHandler = class("ThemeDropHandler", HandlerBase)

function ThemeDropHandler:_onCtor()
	
end

function ThemeDropHandler:initHandler()
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ThemeDropZY, self._recvThemeDropZY, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ThemeDropAstrology, self._recvThemeDropAstrology, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ThemeDropExtract, self._recvThemeDropExtract, self)
    
end

-- 进入主界面
function ThemeDropHandler:sendThemeDropZY()
    local tMsg = {}
    local msgBuffer = protobuf.encode("cs.C2S_ThemeDropZY", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ThemeDropZY, msgBuffer)
end

function ThemeDropHandler:_recvThemeDropZY(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ThemeDropZY", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
    	G_Me.themeDropData:storeInitializeInfo(decodeBuffer)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_THEME_DROP_ENTER_MAIN_LAYER, nil, false, decodeBuffer)
        -- speedbar 中商城红点
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_THEME_DROP_UPDATE_SHOP_TIPS, nil, false, nil)    
    end
end

-- 占星， type(0==免费，1==占1次，2==占10次)
function ThemeDropHandler:sendThemeDropAstrology(nType, nGroupCycle)
    local tMsg = {
    	type = nType,
    	zy_cycle = nGroupCycle,
	}
    local msgBuffer = protobuf.encode("cs.C2S_ThemeDropAstrology", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ThemeDropAstrology, msgBuffer)
end

function ThemeDropHandler:_recvThemeDropAstrology(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ThemeDropAstrology", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
    	G_Me.themeDropData:updateFreeDropTimes(decodeBuffer.left_free_times)
    	G_Me.themeDropData:updateRemainDropTimes(decodeBuffer.left_consume_times)
        G_Me.themeDropData:updateStarValue(decodeBuffer.sv_sum)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_THEME_DROP_ASTROLOGY_SUCC, nil, false, decodeBuffer)
        -- speedbar 中商城红点
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_THEME_DROP_UPDATE_SHOP_TIPS, nil, false, nil)    
    end
end

-- 领取红将
function ThemeDropHandler:sendThemeDropExtract(nKnightId, nGroupCycle)
    local tMsg = {
    	knight_id = nKnightId,
    	zy_cycle = nGroupCycle,
	}
    local msgBuffer = protobuf.encode("cs.C2S_ThemeDropExtract", tMsg) 
    self:sendMsg(NetMsg_ID.ID_C2S_ThemeDropExtract, msgBuffer)
end

function ThemeDropHandler:_recvThemeDropExtract(msgId,msg,len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_ThemeDropExtract", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == G_NetMsgError.RET_OK then
    	G_Me.themeDropData:updateStarValue(decodeBuffer.star_value)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_THEME_CLAIM_RED_KNIGHT_SUCC, nil, false, decodeBuffer)
        -- speedbar 中商城红点
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_THEME_DROP_UPDATE_SHOP_TIPS, nil, false, nil)    
    end
end


return ThemeDropHandler