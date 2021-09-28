-- Filename：	RankService.lua
-- Author：		DJN
-- Date：		2014-9-5
-- Purpose：		排行榜系统后端接口

module("RankService", package.seeall)
require "script/ui/rank/RankData"
--[[
	@des 	:军团排名回调
	@param 	:
	@return :
--]]
function getGuildInfo( p_callbackFunc )
    
    local getGuildListCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            RankData.setRankGuildListData(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(getGuildListCallback, "guild.getGuildRankList", "guild.getGuildRankList", nil, true)
end

--[[
    @des    :个人战力排名回调
    @param  :
    @return :
--]]
function getFightForceInfo( p_callbackFunc )
    local getFightForceCallback = function( cbFlag, dictData, bRet )
      
        if(dictData.err == "ok") then
            RankData.setRankFightForceData(dictData.ret[2],dictData.ret[1])
           
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(getFightForceCallback, "user.rankByFightForce", "user.rankByFightForce", nil, true)
end
--[[
    @des    :等级排名回调
    @param  :
    @return :
--]]
function getLevelInfo( p_callbackFunc )
    local getLevelCallback = function( cbFlag, dictData, bRet )
        -- print("*******输出原始的后端数据********")
        -- print_t(dictData)
        -- print("****************************")
        if(dictData.err == "ok") then
            RankData.setRankLevelData(dictData.ret[2],dictData.ret[1])
            --  print("网络中给用户排名传值")
            -- print(dictData.ret[1])
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(getLevelCallback, "user.rankByLevel", "user.rankByLevel", nil, true)
end
--[[
    @des    :比武排名回调
    @param  :
    @return :
--]]
function getMatchInfo( callbackFunc )
    local function requestFunc( cbFlag, dictData, bRet )
        if(bRet == true)then
            RankData.setRankMatchListData(dictData.ret)
            -- 回调
            if(callbackFunc ~= nil)then
                callbackFunc()
            end
        end
    end
    Network.rpc(requestFunc, "compete.getRankList", "compete.getRankList", nil, true)
    --Network.rpc(requestFunc, "user.rankByFightForce", "user.rankByFightForce", nil, true)

end
--[[
    @des    :比武个人信息回调（与比武排名列表用的接口不同，单列出来）
    @param  :
    @return :
--]]
function getMatchUserInfo( callbackFunc )
    local function requestFunc( cbFlag, dictData, bRet )
    
        if(bRet == true)then
            local dataRet = dictData.ret
            -- 比武所有信息
            RankData.setRankMatchUserData (dataRet)
            -- 回调
            if(callbackFunc ~= nil)then
                callbackFunc()
            end
        end
    end
    Network.rpc(requestFunc, "compete.getCompeteInfo", "compete.getCompeteInfo", nil, true)

end

--[[
    @des    :爬塔排名回调
    @param  :
    @return :
--]]
function getTowerInfo( callbackFunc )
    print("pata网络回调开始")
    -- 获取排行榜信息回调
    local function getTowerRankCallFun( cbFlag, dictData, bRet )
        if(dictData.err == "ok")then
            -- 自身数据
            --_mySelfData = dictData.ret.user_rank
            -- 排行列表
            RankData.setRankTowerListData(dictData.ret.rank_list,dictData.ret.user_rank)
            -- print("爬塔服务器个人数据")
            -- print_t(dictData.ret.user_rank)
            -- print("pata数据设置完毕")
            -- 回调
            if(callbackFunc()~= nil)then
                callbackFunc()
                --print("pata回调结束")
            end
           
        end
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(50))
    Network.rpc(getTowerRankCallFun, "tower.getTowerRank ","tower.getTowerRank", args, true)
 
end

--[[
    @des    :副本排名回调
    @param  :
    @return :
--]]
function getCopyInfo( callbackFunc )
   
    -- 获取排行榜信息回调
    local function getCopyRankCallFun( cbFlag, dictData, bRet )
        if(dictData.err == "ok")then
            -- 自身数据
            --_mySelfData = dictData.ret.user_rank
            -- 排行列表
            RankData.setRankCopyListData(dictData.ret.rank_list,dictData.ret.user_rank)
            -- print("副本服务器个人数据")
            -- print_t(dictData.ret.user_rank)
            -- print("fuben数据设置完毕")
            -- 回调
            if(callbackFunc()~= nil)then
                callbackFunc()
               -- print("fuben回调结束")
            end
           
        end
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(50))
    Network.rpc(getCopyRankCallFun, "ncopy.getUserRankByCopy ","ncopy.getUserRankByCopy", args, true)
 
end

--[[
    @des    :宠物排名回调
    @param  :
    @return :
--]]
function getPetInfo( callbackFunc )
   
    -- 获取排行榜信息回调
    local function getPetRankCallFun( cbFlag, dictData, bRet )
   
        if(dictData.err == "ok")then

            RankData.setRankPetData(dictData.ret.rankList,dictData.ret.myRank)
            --print("宠物数据设置完毕")
            -- 回调
            if(callbackFunc()~= nil)then
                callbackFunc()
               -- print("fuben回调结束")
            end
           
        end
    end
    -- local args = CCArray:create()
    -- args:addObject(CCInteger:create(50))
    Network.rpc(getPetRankCallFun, "pet.getRankList","pet.getRankList", nil, true)
 
end

--[[
    @des    :竞技场排名回调
    @param  :
    @return :
--]]
function getArenInfo( callbackFunc )
    local function requestFunc( cbFlag, dictData, bRet )
        -- print ("getRankList---后端数据")
        if(bRet == true)then
            -- print_t(dictData.ret)
            RankData.setRankArenListData(dictData.ret)
             --print("jingji数据设置完毕")
            if(callbackFunc ~= nil)then
                callbackFunc()
            end
        end
    end
    Network.rpc(requestFunc, "arena.getRankList", "arena.getRankList", nil, true)
end

--[[
    @des    :竞技个人排名回调
    @param  :
    @return :
--]]
function getArenaUserInfo( callbackFunc )
    local function requestFunc( cbFlag, dictData, bRet )
        -- print ("getArenaInfo---后端数据")
        if(bRet == true)then
            -- print_t(dictData.ret)
            local dataRet = dictData.ret
            if(dataRet.ret == "lock")then
                -- 竞技场业务忙
                require "script/ui/tip/AnimationTip"
                local str = GetLocalizeStringBy("key_2152")
                AnimationTip.showTip(str)
                return
            end
            if(dataRet.ret == "ok")then
                RankData.setRankArenUserData(dataRet.res)
                -- 设置挑战列表数据
               -- ArenaData.setOpponentsData( dataRet.res.opponents )
                if(callbackFunc ~= nil)then
                    callbackFunc()
                end
            end
        end
    end
    Network.rpc(requestFunc, "arena.getArenaInfo", "arena.getArenaInfo", nil, true)
end
--[[
    @des    :个人宠物信息回调
    @param  :
    @return :
--]]
function getUserPetInfo( p_uid,callbackFunc )
    local function requestFunc( cbFlag, dictData, bRet )
        -- print ("getUserPetInfo---后端数据")
        if(dictData.err == "ok")then
            -- print_t(dictData.ret)
            RankData.setUserUpPetData(dictData.ret)
             --print("jingji数据设置完毕")
            if(callbackFunc ~= nil)then
                print("执行回调")
                callbackFunc()
            end
        end
    end
    local args = CCArray:create()
    args:addObject(CCInteger:create(p_uid))
    Network.rpc(requestFunc, "pet.getPetInfoForRank", "pet.getPetInfoForRank", args, true)
end
--[[
    @des    :排行榜中人物宠物信息回调
    @param  :
    @return :
--]]
-- function getPetInfo( _uid )
--     local uid = tonumber(_uid)
--     local function requestFunc( cbFlag, dictData, bRet )
--         -- print ("getArenaInfo---后端数据")
--         if(dictData.err == "ok")then
--             -- print_t(dictData.ret)
--             local dataRet = dictData.ret.uid.arrPet
--             print("宠物数据开始")
--             print_t(dataRet)
--             RankData.setPetInfo(dataRet)
--                 -- if(callbackFunc ~= nil)then
--                 --     callbackFunc()
--                 -- end
            
--         end
--     end
--     print("创建宠物信息传进的uid")
--     print(uid)
--     print("----")
--     local args = CCArray:create()
--     args:addObject(CCInteger:create(_uid))
--     local args2 =CCArray:create()
--     args2:addObject(args)
--     Network.rpc(requestFunc, "user.getBattleDataOfUsers", "user.getBattleDataOfUsers", args2, true)
-- end
    
-- --[[
--     @des    :副本排名回调
--     @param  :
--     @return :
-- --]]
-- function getCopyInfo( callbackFunc )
   
--     -- 获取排行榜信息回调
--     local function getCopyRankCallFun( cbFlag, dictData, bRet )
--          print("fuben网络回调开始")
--         if(dictData.err == "ok")then
--             -- 自身数据
--             --_mySelfData = dictData.ret.user_rank
--             -- 排行列表
--             RankData.setRankCopyListData(dictData.ret.rank_list)

--             print("fuben数据设置完毕")
--             print("数据")
--             print_t(dictData.ret.rank_list)
--             -- 回调
--             if(callbackFunc()~= nil)then
--                 callbackFunc()
--                 print("fuben回调结束")
--             end
           
--         end
--     end
--     local args = CCArray:create()
--     args:addObject(CCInteger:create(50))
--     Network.rpc(getCopyRankCallFun, "ncopy.getUserRankByCopy", "ncopy.getUserRankByCopy", args, true)
 
-- end



-- function getGuildInfo( p_callbackFunc )
--     local getGuildListCallback = function( cbFlag, dictData, bRet )
--         -- if(dictData.err == "ok") then
--         --     require "script/ui/rank/RankData"
--         --     RankData.setRankGuildListData(dictData.ret)
--         --     if(p_callbackFunc ~= nil) then
--         --         p_callbackFunc()
--         --     end
--         -- end
--         print("kaishishuchu----------------------------")
--         print_t(dictData)
--         print("+++++++++++++++++")
--     end
--     Network.rpc(getGuildListCallback, "user.IUser.rankByFightForce", "user.IUser.rankByFightForce", nil, true)
-- end

