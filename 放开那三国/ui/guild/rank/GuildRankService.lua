-- Filename：	GuildRankService.lua
-- Author：		DJN
-- Date：		2014-7-11
-- Purpose：		军团排行榜后端接口

module("GuildRankService", package.seeall)
require "script/ui/guild/rank/GuildRankData"
--[[
	@des 	:军团战力排行网络请求回调
	@param 	:创建UI回调函数
	@return :
--]]
function getInfo( p_callbackFunc )
    local getGuildListCallback = function( cbFlag, dictData, bRet )
        if(dictData.err == "ok") then
            GuildRankData.setRankGuildListData(dictData.ret)
            if(p_callbackFunc ~= nil) then
                p_callbackFunc()
            end
        end
    end
    Network.rpc(getGuildListCallback, "guild.getGuildRankList", "guild.getGuildRankList", nil, true)
end


