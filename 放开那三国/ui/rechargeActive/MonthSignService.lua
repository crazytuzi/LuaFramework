-- Filename：	MonthSignService.lua
-- Author：		DJN
-- Date：		2014-10-13
-- Purpose：		月签到后端接口
module("MonthSignService", package.seeall)
require "script/ui/rechargeActive/MonthSignData"
--[[
	@des 	:获取玩家已领取的奖励回调
	@param 	:
	@return :
--]]
function getSignInfo( p_callbackFunc )
    
    local getSignCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            MonthSignData.setSignData(dictData.ret)
          --  print("设置data数据完毕")
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(getSignCallback, "sign.getMonthSignInfo", "sign.getMonthSignInfo", nil, true)
end
--[[
    @des    :领取某一天的奖励
    @param  :
    @return :
--]]
function Sign( day,p_callbackFunc )
    
    local SignCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            -- print("输出领取信息************")
            -- print_t(dictData)
            --更新用户获奖数据
            MonthSignData.setCurReward()
            --重置一次领奖数据，并在其中执行传入的回调函数
            getSignInfo(p_callbackFunc)
        end
    end
    local time = day
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(time))
    
    Network.rpc(SignCallback, "sign.gainMonthSignReward", "sign.gainMonthSignReward", nil, true)
end

