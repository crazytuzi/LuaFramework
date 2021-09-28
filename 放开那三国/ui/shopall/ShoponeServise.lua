-- FileName: ShoponeServise.lua
-- Author: FQQ
-- Date: 15-08-28
-- Purpose: 商店整合网络层

module("ShoponeServise", package.seeall)

--主界面商店整合中拉取神秘商店信息
function getShopInfo( ... )
    local shopInfoCallBack = function ( cbFlag, dictData, bRet )
        -- body
        if dictData.err ~= "ok" then
            return
        end
        ActiveCache.setShopInfo(dictData.ret)
    end
    Network.rpc(shopInfoCallBack, "mysteryshop.getShopInfo" , "mysteryshop.getShopInfo", nil , true)
end