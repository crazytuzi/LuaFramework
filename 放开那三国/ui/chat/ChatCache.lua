-- Filename: ChatCache.lua
-- Author: bzx
-- Date: 2014-05-19
-- Purpose: 聊天缓存

module("ChatCache", package.seeall)

local _shield_players = {}
local _key_shield_players = "key_shield_players"


local _isInChatUI = false


--[[
    缓存语音和文字
    {
        10002 = {
            audio = string,
            text  = string,
        },
    }
--]] 
local _audio_cache  = {}
local Audio_Num_Max = 100   -- 存储语音的上限

local _aid_arr      = {}   -- 用于删除id用

-- 聊天消息类型
ChatInfoType = {
    normal                  = 1,    -- 普通
    battle_report_player    = 2,    -- 玩家战报
    battle_report_union     = 3,    -- 军团战报
    battle_report_city      = 4,    -- 城池战报
    audio                   = 5,    -- 语音聊天
}

-- 频道类型
ChannelType = {
    world   = 1,    -- 世界
    union   = 2,    -- 军团
    pm      = 3,    -- 私聊
}

function setChatUIStatus( isIn )
    _isInChatUI = isIn
end

function isInChatUI()
    return _isInChatUI
end

function handleGetBlackUids(cbFlag, dictData, bRet)
    if dictData.err ~= "ok" then
        return
    end
    _shield_players = {}
    for i = 1, #dictData.ret do
        local uid = dictData.ret[i]
        _shield_players[uid] = uid
    end
end

-- 是否被屏蔽
function isShieldedPlayer(uid)
    if _shield_players[uid] ~= nil then
        return true
    end
    return false
end

-- 屏蔽
function addShieldedPlayer(uid)
    _shield_players[tostring(uid)] = uid
end

-- 删除屏蔽
function deleteShieldedPlayer(uid)
    _shield_players[tostring(uid)] = nil
end

-- 添加一条语音
function addAudioBy( aid, p_audio )
    if(_audio_cache[aid]==nil )then
        _audio_cache[aid] = {}
        handleAudioCacheMax(aid)
    end
    _audio_cache[aid].audio = p_audio
    
end

-- 添加一条语音文字
function addAudioTextBy(aid, p_text )
    if(_audio_cache[aid]==nil )then
        _audio_cache[aid] = {}
        handleAudioCacheMax(aid)
    end
    _audio_cache[aid].text = p_text
end

-- 获取语音
function getAudioBy( aid )
    print_t(_audio_cache)
    if(_audio_cache[aid]==nil)then
        return nil
    else
        return _audio_cache[aid].audio
    end
end

-- 获取语音文字
function getAudioTextBy( aid )
    if(_audio_cache[aid]==nil)then
        return nil
    else
        return _audio_cache[aid].text
    end
end

-- 设置缓存上限
function handleAudioCacheMax(aid)
    table.insert(_aid_arr, aid)    -- 用于删除id用
    print_t(_aid_arr)
    if(table.count(_audio_cache)>=Audio_Num_Max)then
        local del_num = math.floor(Audio_Num_Max*0.3)
        if(del_num > 0)then
            for i=1,del_num do
                _audio_cache[_aid_arr[1]] = nil
                table.remove(_aid_arr, 1)
            end
        end
    end
end







