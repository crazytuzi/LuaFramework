-- Filename：	ReResourceService.lua
-- Author：		DJN
-- Date：		2014-12-12
-- Purpose：		资源追回后端接口

module("ReResourceService", package.seeall)
require "script/ui/recover/ReResourceData"
require "script/ui/item/ReceiveReward"
require "script/ui/item/ItemUtil"
-- require "script/ui/tip/AnimationTip"
--             AnimationTip.showTip(GetLocalizeStringBy("djn_107"))

--[[
	@des 	:获取补领信息
	@param 	:
	@return :
--]]
function getResourceInfo( p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            ReResourceData.setResourceInfo(dictData.ret)

            if(ReResourceData.ifHaveReward())then
                DataCache.setReResourceStatus(true)
            end
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(Callback, "retrieve.getRetrieveInfo", "retrieve.getRetrieveInfo", nil, true)
end
--[[
    @des    :通过金币补领
    @param  :
    @return :
--]]
function recoverByGold( p_param,p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            -- print("金币补领结果")
            -- print_t(dictData.ret)
            local goodsId = {}    -----用于最后展示“恭喜获得"的奖励id表
            local goods = {}      -----用于最后展示“恭喜获得”的奖励表
            if(type(p_param) == "string" or type(p_param) == "number")then
                if(dictData.ret[tostring(p_param)]== "ok")then
                    -- 如果是追回吃烧鸡，则修改剩余追回次数
                    if ( tonumber(p_param) == 4) then
                        ReResourceData.updateTypeNumFromCache(p_param,-1)
                    else
                        ReResourceData.deleteTypeFromCache(p_param)
                    end
                    ReResourceData.UpGold(p_param)
                    table.insert(goodsId,p_param)
                elseif (dictData.ret[tostring(p_param)] == "lack") then
                    -- 金币不够
                    require "script/ui/tip/LackGoldTip"
                    LackGoldTip.showTip(-600,10000)
                    return
                elseif(dictData.ret[tostring(p_param)]== "already" or dictData.ret[tostring(p_param)]== "nothing")then
                    --------已经不可以领取
                    return
                end
            elseif(type(p_param == "table"))then
                for k,v in pairs(p_param)do
                    if(dictData.ret[tostring(v)]== "ok")then
                        -- 多次追回，如烧鸡
                        local typeNum = ReResourceData.getTypeNumFromCache(v)
                        for i=1,typeNum do
                            ReResourceData.UpGold(v)
                            table.insert(goodsId,v)
                        end
                        ReResourceData.deleteTypeFromCache(v)
                    elseif (dictData.ret[tostring(v)] == "lack") then
                        -- 金币不够
                        require "script/ui/tip/LackGoldTip"
                        LackGoldTip.showTip(-600,10000)
                        return
                    elseif(dictData.ret[tostring(v)]== "already" or dictData.ret[tostring(v)]== "nothing")then
                        --------已经不可以领取
                        return
                    end
                end
            end
            for k,v in pairs(goodsId) do
                local goodK = ReResourceData.getAllRewardByType(v,"gold")
                for i,j in pairs(goodK) do
                    table.insert(goods,j)
                end
            end

            -- 合并奖励 add by lgx 20160825
            goods = ReResourceData.mergeRewardTable(goods)
            
            ItemUtil.addRewardByTable(goods) ---发奖
            ReceiveReward.showRewardWindow(goods,p_callbackFunc,10000,-650)
        end
    end
   local times = p_param
   local arg = CCArray:create()
   local table = CCArray:create()
   local isAll = 0 -- 0表示单条追回 1表示一键追回
    if(type(times)== "string" or type(times)== "number")then
        table:addObject(CCInteger:create(times))
        isAll = 0
    elseif(type(times) == "table")then
        for k,v in pairs(times) do
            table:addObject(CCInteger:create(v))
        end
        isAll = 1
    end
    arg:addObject(table)
    arg:addObject(CCInteger:create(isAll))

    Network.rpc(Callback, "retrieve.retrieveByGold", "retrieve.retrieveByGold", arg, true)
end
--[[
    @des    :通过银币补领
    @param  :
    @return :
--]]
function recoverBySilver( p_param,p_callbackFunc )
    
    local Callback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then

            local goodsId = {}    -----用于最后展示“恭喜获得"的奖励id表
            local goods = {}      -----用于最后展示“恭喜获得”的奖励表
            if(type(p_param) == "string" or type(p_param) == "number")then          
                if(dictData.ret[tostring(p_param)]== "ok")then
                    -- 如果是追回吃烧鸡，则修改剩余追回次数
                    if ( tonumber(p_param) == 4) then
                        ReResourceData.updateTypeNumFromCache(p_param,-1)
                    else
                        ReResourceData.deleteTypeFromCache(p_param)
                    end
                    ReResourceData.UpSilver(p_param)
                    table.insert(goodsId,p_param)
                elseif (dictData.ret[tostring(p_param)] == "lack") then
                    -- 银币不够
                    require "script/ui/tip/AnimationTip"
                    AnimationTip.showTip(GetLocalizeStringBy("djn_107"))
                    return
                elseif(dictData.ret[tostring(p_param)]== "already" or dictData.ret[tostring(p_param)]== "nothing")then
                    --------已经不可以领取
                    return
                end
            elseif(type(p_param) == "table")then
              
                for k,v in pairs(p_param)do
                    if(dictData.ret[tostring(v)]== "ok")then                     
                        -- 多次追回，如烧鸡
                        local typeNum = ReResourceData.getTypeNumFromCache(v)
                        for i=1,typeNum do
                            ReResourceData.UpSilver(v)
                            table.insert(goodsId,v)
                        end
                        ReResourceData.deleteTypeFromCache(v)
                    elseif (dictData.ret[tostring(v)] == "lack") then
                        -- 银币不够
                        require "script/ui/tip/AnimationTip"
                        AnimationTip.showTip(GetLocalizeStringBy("djn_107"))
                        return
                    elseif(dictData.ret[tostring(v)]== "already" or dictData.ret[tostring(v)]== "nothing")then
                        --------已经不可以领取
                        return
                    end
                end
            end
       
            for k,v in pairs(goodsId) do
                local goodK = ReResourceData.getAllRewardByType(v,"silver")
                for i,j in pairs(goodK) do
                    table.insert(goods,j)
                end
            end

            -- 合并奖励 add by lgx 20160825
            goods = ReResourceData.mergeRewardTable(goods)
            ItemUtil.addRewardByTable(goods)  -- 发奖
            ReceiveReward.showRewardWindow(goods,p_callbackFunc,10000,-650)
        end
    end
    
    local times = p_param
    local arg = CCArray:create()
    local table = CCArray:create()
    local isAll = 0 -- 0表示单条追回 1表示一键追回
    if(type(times)== "string" or type(times)== "number")then
        table:addObject(CCInteger:create(times))
        isAll = 0
    elseif(type(times) == "table")then
        for k,v in pairs(times) do
            table:addObject(CCInteger:create(v))
        end
        isAll = 1
    end
    arg:addObject(table)
    arg:addObject(CCInteger:create(isAll))
    
    Network.rpc(Callback, "retrieve.retrieveBySilver", "retrieve.retrieveBySilver", arg, true)
end