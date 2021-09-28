-- Filename：	ScoreWheelService.lua
-- Author：		DJN
-- Date：		2014-11-3
-- Purpose：		积分轮盘后端接口
module("ScoreWheelService", package.seeall)
require "script/ui/rechargeActive/scoreWheel/ScoreWheelData"
require "script/model/user/UserModel"
--require "script/ui/rechargeActive/MonthSignData"
--[[
	@des 	:获取玩家已抽取的奖励回调
	@param 	:
	@return :
--]]
function getRouletteInfo( p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            
            ScoreWheelData.setSignData(dictData.ret)
            --ScoreWheelLayer.refreshDataLabel()
            print("设置已经转盘数据完毕")
            
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(Callback, "roulette.getMyRouletteInfo", "roulette.getMyRouletteInfo", nil, true)
end
--[[
    @des    :抽奖回调
    @param  :
    @return :
--]]
function Roulette( p_times,p_callbackFunc1,p_args1,p_callbackFunc2,p_args2)
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            local needGold = tonumber(ScoreWheelData.getNeedGold())
            if(needGold ~= nil)then
                print("扣金币数量",needGold)
                UserModel.addGoldNumber(-needGold)
            else
                print("检测不需要扣金币")
            end
            ScoreWheelData.setWheelData(dictData.ret)
            print("设置本次转盘结果完毕")
            -----发奖 更新数据
            local scoreWheelResult = ScoreWheelData.getWheelData()
            local itemData = {} 
            local item = ItemUtil.getItemsDataByStr(nil,scoreWheelResult)
            itemData = item
            ScoreWheelData.updateReward(itemData)
            
            -- if(p_callbackFunc1 ~= nil) then
            --     p_callbackFunc1(p_callbackFunc2)
            -- end
            if(p_callbackFunc1 ~= nil) then
                -- local arg1 = p_args1[1]
                -- local arg2 = p_args1[2]
                p_callbackFunc1(p_args1[1],p_args1[2])
            end
            if(p_callbackFunc2 ~= nil) then
                p_callbackFunc2(p_args2)
            end

        end
    end
    local times = p_times
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(times))
    Network.rpc(Callback, "roulette.rollRoulette", "roulette.rollRoulette", arg, true)
end
--[[
    @des    :领取宝箱回调
    @param  :
    @return :
--]]
function GetBoxRew( p_tag,p_callbackFunc1 )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
          
           -- ScoreWheelData.setWheelData(dictData.ret)
            print("成功领取积分轮盘的宝箱",p_tag)
           -- getRouletteInfo(p_callbackFunc1)
            
            if(p_callbackFunc1 ~= nil) then
                p_callbackFunc1()
            end
        end
    end
    local tag = p_tag 
    local arg = CCArray:create()
    arg:addObject(CCInteger:create(tag))
    Network.rpc(Callback, "roulette.receiveBoxReward", "roulette.receiveBoxReward", arg, true)
end
--[[
    @des    :获取排行榜
    @param  :
    @return :
--]]
function getRankInfo( p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then           
            ScoreWheelData.setRankData(dictData.ret) 
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(Callback, "roulette.getRankList", "roulette.getRankList", nil, true)
end
--[[
    @des    :获取排行榜
    @param  :
    @return :
--]]
function getRankReward( p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then            
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(Callback, "roulette.receiveRankReward", "roulette.receiveRankReward", nil, true)
end