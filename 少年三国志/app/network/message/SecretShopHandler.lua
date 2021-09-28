
local SecretShopHandler = class("SecretShopHandler", require("app.network.message.HandlerBase"))

function SecretShopHandler:_onCtor( ... )

end
  
function SecretShopHandler:initHandler(...)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_MysticalShopInfo, self._recvShopLeftNumber, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_MysticalShopRefresh, self._recvRefreshInfo, self)
end


function SecretShopHandler:_recvShopLeftNumber(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_MysticalShopInfo", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer then
--        G_Me.shopData:setSecretShopRefreshNum(decodeBuffer.refresh_count)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SECRETSHOP_REFRESH_NUMBER, nil, false,decodeBuffer)

        -- 免费刷新次数
        G_Me.shopData:setSecretShopFreeCount(decodeBuffer.free_refresh_count)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SHOP_HAS_FREE_REFRESH_COUNT, nil, false)
    end
end

function SecretShopHandler:_recvRefreshInfo(msgId, msg, len)
    local decodeBuffer = self:_decodeBuf("cs.S2C_MysticalShopRefresh", msg, len)
    if type(decodeBuffer) ~= "table" then 
        return 
    end
    if decodeBuffer and decodeBuffer.ret == 1 then
--        G_Me.shopData:setSecretShopInfo(decodeBuffer.id)
--        G_Me.shopData:setSecretShopRefreshNum(decodeBuffer.refresh_count)
        uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_SECRETSHOP_REFRESH_INFO, nil, false,decodeBuffer)

        -- 免费刷新次数
        G_Me.shopData:setSecretShopFreeCount(decodeBuffer.free_refresh_count)
    end
end

function SecretShopHandler:sendLeftNumberReq(...)
    local msg = {

    }

    local msgBuffer = protobuf.encode("cs.C2S_MysticalShopInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_MysticalShopInfo, msgBuffer)
end

function SecretShopHandler:sendRefreshReq(refreshType)
    local msg = {
        type = refreshType
    }

    local msgBuffer = protobuf.encode("cs.C2S_MysticalShopRefresh", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_MysticalShopRefresh, msgBuffer)
end

return SecretShopHandler
