-- Filename: WorldCarnivalEventDispatcher.lua
-- Author: bzx
-- Date: 2014-08-25
-- Purpose: 跨服赛事件调度器

module("WorldCarnivalEventDispatcher", package.seeall)

btimport "script/ui/world_carnival/WorldCarnivalData"
btimport "script/ui/world_carnival/WorldCarnivalService"

local _curTime = nil
local _listeners = nil
local _timeSprite = nil
local _lastRound = nil
local _lastStatus = nil
local _lastSubRound = nil
local _lastSubStatus = nil

-- 开始启动定时器
function open()
    _curTime = TimeUtil.getSvrTimeByOffset()
    local curRound =  WorldCarnivalData.getCurRound()
    local curStatus = WorldCarnivalData.getCurStatus()
    if curRound == WorldCarnivalConstant.ROUND_3 and curStatus >= WorldCarnivalConstant.STATUS_DONE then
        print("跨服赛已经结束，无法开启")
        return
    end
    if not tolua.isnull(_timeSprite) then
        return
    end
	--后端推送注册
    print("注册推送regisgerRoundPush")
	WorldCarnivalService.re_worldcarnival_update()
    _timeSprite = CCSprite:create()
    CCDirector:sharedDirector():getRunningScene():addChild(_timeSprite)
    updateTime()
    schedule(_timeSprite, updateTime, 1)
end

-- 刷新当前时间和比赛状态
function updateTime()
    local curRound =  WorldCarnivalData.getCurRound()
    local curStatus = WorldCarnivalData.getCurStatus()
    local curSubRound = WorldCarnivalData.getCurSubRound()
    local curSubStatus = WorldCarnivalData.getCurSubStatus()
	_curTime = TimeUtil.getSvrTimeByOffset()
    -- print("当前时间：", TimeUtil.getTimeFormatYMDHMS(_curTime))
    local round = curRound
    local status = curStatus
    local subRound = curSubRound
    local subStatus = curSubStatus
    if not WorldCarnivalData.isEnd() then
        local nextSubRoundStartTime = WorldCarnivalData.getNextSubRoundStartTime()
        if curSubStatus == WorldCarnivalConstant.STATUS_DONE then
            if _curTime >= nextSubRoundStartTime then
                if curStatus == WorldCarnivalConstant.STATUS_DONE then
                    round = curRound + 1
                    status = WorldCarnivalConstant.STATUS_FIGHTING
                    subRound = 1
                else
                    subRound = curSubRound + 1
                end
                subStatus = WorldCarnivalConstant.STATUS_FIGHTING
                statusChange(round, status, subRound, subStatus)
            end
        end
    end
    tellListener(round, status, subRound, subStatus, "update")
    if curRound == WorldCarnivalConstant.ROUND_3 and curStatus >= WorldCarnivalConstant.STATUS_DONE then
        print("比赛结束")
        close()
    end
end

-- 关闭定时器
function close()
    _listeners = nil
    if _timeSprite ~= nil then
        _timeSprite:removeFromParentAndCleanup(true)
    end
end

--[[
	@des : 阶段变化
--]]
function statusChange( p_round, p_status, p_subRound, p_subStatus)
    print("状态变化了--",  p_round, p_status, p_subRound, p_subStatus)
	WorldCarnivalData.setCurRound(p_round)
	WorldCarnivalData.setCurStatus(p_status)
    WorldCarnivalData.setCurSubRound(p_subRound)
    WorldCarnivalData.setCurSubStatus(p_subStatus)
    tellListener(p_round, p_status, p_subRound, p_subStatus, "statusChange")
    setLastStatus(p_round, p_status, p_subRound, p_subStatus)
end

-- 得到上一次的比赛状态
function getLastStatus( ... )
    return _lastRound, _lastStatus, _lastSubRound, _lastSubStatus
end

-- 设置上一次的比赛状态
function setLastStatus(p_lastRound, p_lastStatus, p_lastSubRound, p_lastSubStatus )
    _lastRound = p_lastRound
    _lastStatus = p_lastStatus
    _lastSubRound = p_lastSubRound
    _lastSubStatus = p_lastSubStatus
end

-- 广播事件
function tellListener(p_round, p_status, p_subRound, p_subStatus, p_event)
    if _listeners == nil then
        return
    end
    for k, v in pairs(_listeners) do
        v(p_round, p_status, p_subRound, p_subStatus, p_event)
    end
end

-- 增加事件监听器
function addListener(p_tag, p_listener)
    _listeners = _listeners or {}
    _listeners[p_tag] = p_listener
end

-- 听到当前时间
function getCurTime()
    return _curTime
end