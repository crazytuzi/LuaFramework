-- Filename：	ScoreShopService.lua
-- Author：		DJN
-- Date：		2015-3-3
-- Purpose：    积分商店网络


module ("ScoreShopService", package.seeall)
require "script/ui/rechargeActive/scoreShop/ScoreShopData"

--[[
	@des 	:获取玩家积分商店信息
	@param 	:
	@return :
--]]
function getShopInfo( p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then           
            ScoreShopData.setShopInfo(dictData.ret)
            --ScoreWheelLayer.refreshDataLabel()
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(Callback, "scoreshop.getShopInfo", "scoreshop.getShopInfo", nil, true)
end
--[[
    @des    :兑换物品
    @param  :
    @return :
--]]
function buyItem( p_id,p_num,p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then           
           -- ScoreShopData.setShopInfo(dictData.ret)
            --ScoreWheelLayer.refreshDataLabel()
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end

    local args = CCArray:create()
    args:addObject(CCInteger:create(p_id))
    args:addObject(CCInteger:create(p_num))
    Network.rpc(Callback, "scoreshop.buy", "scoreshop.buy", args, true)
end