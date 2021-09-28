-- FileName: MissionRankService.lua
-- Author:lcy
-- Date: 2014-04-00
-- Purpose: function description of module
--[[TODO List]]

module("MissionRankService", package.seeall)

-- /**
-- * @return
-- * [
-- * list =>
-- * 		   	1=>	[
-- * 					uname => string,
-- * 					fame => int,
-- * 					server_name => string,
-- * 					vip => int,
-- * 					level => int,
-- * 					dress => array(),
-- *					htid = > int
-- * 		   		],
-- *
-- * 			2=>	[
-- * 					uname => string,
-- * 					fame => int,
-- * 					server_name => string,
-- * 					vip => int,
-- * 					level => int,
-- * 					dress => array(),
-- *					htid = > int
-- * 		   		],
-- *
-- * mine => [
-- * 				fame => int,
-- * 				rank => int,
-- * 		   ],
-- *
-- * ]
-- *
-- */
function getRankList(pCallback)
    local requestFunc = function(cbFlag,dictData,bRet)
        -- local dictData = {
        --     ret = {
        --         list = {
        --             ["1"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["2"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["3"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["4"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["5"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["6"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["20"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["50"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --             ["500"] = {uname = "张三", fame = 45454, server_name = "ppPhone", vip = 1, level = 10, dress = {["1"]=80002}, htid = 20002},
        --         },
        --         mine = {
        --             fame = 4545,
        --             rank = 6,
        --         }
        --     },
        --     err = "ok",
        -- }
        if dictData.err == "ok" then
            if(pCallback ~= nil)then
                pCallback(dictData.ret)
            end
        end
    end
    -- requestFunc()
    Network.rpc(requestFunc,"mission.getRankList","mission.getRankList",nil,true)
end

