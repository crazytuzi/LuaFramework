
-- Filename：    GuildRankData.lua
-- Author：      DJN
-- Date：        2014-7-8
-- Purpose：     军团战力排行数据函数

module("GuildRankData", package.seeall)

--[[
    @des    :获取当前用户所在军团的排行和战力情况 
    @param  :
    @return :
--]]
function getUserGuildRankInfo( ... )
    local user_guild_rank = nil
    local user_guild_fight_force = nil
    -- require "script/ui/guild/GuildDataCache"
    -- local user_guild_id = tonumber (GuildDataCache.getMineSigleGuildId())--获取当前用户所在军团的

    -- ---------------当前用户没有加入军团
    -- if (user_guild_id <= 0 )then
    --     --print("用户没加入军团")
    --     user_guild_rank = GetLocalizeStringBy("key_1554")
    --     user_guild_fight_force = GetLocalizeStringBy("key_1554")

    -- ---------------当前用户加入过军团
    -- else 
    --     --print("用户已经加入军团")
        
    --     user_guild_rank = GetLocalizeStringBy("key_1054")
    --     user_guild_fight_force = tonumber (GuildDataCache.getGildFightForce())
    --     print("缓存里面的战斗力")
    --     print(tonumber (GuildDataCache.getGildFightForce()))
    --     print(user_guild_fight_force)
    --     --print_t(user_guild_fight_force)
    --     --print_t(user_guild_id)
    --     ---------------得到排名列表数据
    --     m_rankTabViewInfo = getRankGuildListData() or {}

    --     for k,v in pairs(m_rankTabViewInfo) do
    --         if(tonumber(v.guild_id)== user_guild_id)then
    --             --print("检索到军团排名,给user_rank重新赋值")
    --             user_guild_rank = tostring(v.rank)
    --         break
    --         end
    --     end
    -- end 
    -- return user_guild_rank , user_guild_fight_force

    require "script/ui/guild/GuildDataCache"
    if(tonumber(GuildDataCache.getMineSigleGuildInfo().rank) == tonumber(0) or GuildDataCache.getMineSigleGuildInfo().rank==nil )then --用户没有加入军团的时候，后端将排名返回为0
        user_guild_rank = GetLocalizeStringBy("djn_52")
        user_guild_fight_force = GetLocalizeStringBy("key_1554") 

    else
        user_guild_rank = GuildDataCache.getMineSigleGuildInfo().rank
        user_guild_fight_force = GuildDataCache.getMineSigleGuildInfo().fight_force
        -- print("军团排名信息")
        -- print(user_guild_rank)
        -- print(user_guild_fight_force)
    end
    return user_guild_rank , user_guild_fight_force
end
--[[
    @des    :得到战力前50军团数据
    @param  :
    @return :
--]]
function getRankGuildListData( ... )
    --print(GetLocalizeStringBy("djn_1"))
    return _rankguildListInfo
end
--[[
    @des    :对排名进行重新排序,防止后端数据在网络解析时出错
    @param  :
    @return :
--]]
local function rankSort ( goods_1, goods_2 )
    return tonumber(goods_1.rank) < tonumber(goods_2.rank)
    end
--[[
    @des    :设置战力前50军团数据
    @param  :
    @return :
--]]
function setRankGuildListData( listData, offset )
    _rankguildListInfo = listData  
    table.sort( _rankguildListInfo, rankSort )
end

