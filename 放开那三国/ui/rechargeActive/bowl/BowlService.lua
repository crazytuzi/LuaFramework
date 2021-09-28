-- Filename：	BowlService.lua
-- Author：		DJN
-- Date：		2014-11-3
-- Purpose：		聚宝盆后端接口
module("BowlService", package.seeall)
-- require "script/ui/rechargeActive/scoreWheel/ScoreWheelData"
-- require "script/model/user/UserModel"
require "script/ui/rechargeActive/bowl/BowlData"
--[[
	@des 	:获取玩家聚宝信息
	@param 	:
	@return :
--]]
function getBowlInfo( p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then           
            BowlData.setBowlInfo(dictData.ret)
            --ScoreWheelLayer.refreshDataLabel()
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(Callback, "bowl.getBowlInfo", "bowl.getBowlInfo", nil, true)
end
--[[
    @des    :购买宝盆
    @param  :
    @return :
--]]
function buyBowl( p_tag,p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then           
            --BowlData.setBowlInfo(dictData.ret)
            --ScoreWheelLayer.refreshDataLabel()
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_tag))
    Network.rpc(Callback, "bowl.buy", "bowl.buy", arg, true)
end
--[[
    @des    :领取奖励宝盆
    @param  :
    @return :
--]]
function reveiveReward( p_tag,p_day,p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then           
            --BowlData.setBowlInfo(dictData.ret)
            --ScoreWheelLayer.refreshDataLabel()
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_tag))
    arg:addObject(CCInteger:create(p_day))
    Network.rpc(Callback, "bowl.receive", "bowl.receive", arg, true)
end
