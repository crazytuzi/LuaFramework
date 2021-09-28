-- Filename：    WorldGroupService.lua
-- Author：      DJN
-- Date：        2015-8-3
-- Purpose：    跨服团购网络


module ("WorldGroupService", package.seeall)

require "script/ui/rechargeActive/worldGroupBuy/WorldGroupData"
--[[
    @des    :获取信息
    @param  :0=>获取全部信息  1=>获取团购数量信息(为了五秒钟一次的主动刷新)
    @return :
--]]
function getInfo( p_param, p_callbackFunc )
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            WorldGroupData.setNetInfo(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_param))
    --TODO  NOLOADING RPC
    Network.rpc(Callback, "worldgroupon.getInfo", "worldgroupon.getInfo", arg, true)
end
--[[
    @des    :购买请求
    @param  :
    @return :
--]]
function buy( p_ID,p_time, p_callbackFunc )
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            --WorldGroupData.setNetInfo(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc(dictData.ret)
            end
        else
            --针对活动购买期最后一秒买东西的逗逼玩家
            AnimationTip.showTip(GetLocalizeStringBy("djn_221"))
        end
    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_ID))
    arg:addObject(CCInteger:create(p_time))
    Network.rpc(Callback, "worldgroupon.buy", "worldgroupon.buy", arg, true)
end
--[[
    @des    :积分领奖请求
    @param  :
    @return :
--]]
function getPointReward( p_ID, p_callbackFunc )
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            WorldGroupData.addRewardRecord(p_ID)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(p_ID))
    Network.rpc(Callback, "worldgroupon.recReward", "worldgroupon.recReward", arg, true)
end

