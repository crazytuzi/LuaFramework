-- Filename: LordWarEventDispatcher.lua
-- Author: bzx
-- Date: 2014-08-25
-- Purpose: 跨服赛事件调度器

module("LordWarEventDispatcher", package.seeall)

require "script/ui/lordWar/LordWarData"

local _curTime 
local _listeners
local _node

function open()
    _curTime = BTUtil:getSvrTimeInterval()
    local curRound =  LordWarData.getCurRound()
    local curStatus = LordWarData.getCurRoundStatus()
    if curRound == LordWarData.kCross2To1 and curStatus >= LordWarData.kRoundFighted then
        print("跨服赛已经结束，无法开启")
        return
    end
    if _node ~= nil then
        return
    end
	--后端推送注册
    print("注册推送regisgerRoundPush")
	LordWarService.regisgerRoundPush(roundChange)
    _node = CCNode:create()
    CCDirector:sharedDirector():getRunningScene():addChild(_node)
    updateTime()
    schedule(_node, updateTime, 1)
end

function updateTime()
	_curTime = BTUtil:getSvrTimeInterval()
    -- print("当前时间：", TimeUtil.getTimeFormatYMDHMS(_curTime))
    local curRound =  LordWarData.getCurRound()
    local curStatus = LordWarData.getCurRoundStatus()
    local round = curRound
    local status = curStatus
    local rounds = {
        LordWarData.kRegister,
        -LordWarData.kInnerAudition,
        LordWarData.kInner32To16,
        LordWarData.kInner16To8,
        LordWarData.kInner8To4,
        LordWarData.kInner4To2,	
        LordWarData.kInner2To1,		
        LordWarData.kCrossAudition,    
        LordWarData.kCross32To16, 		
        LordWarData.kCross16To8,  		
        LordWarData.kCross8To4, 	
        LordWarData.kCross4To2, 			
        LordWarData.kCross2To1, 		
    }
    for i = 1, #rounds do
        local roundTemp = rounds[i]
        if roundTemp >= curRound then
            if _curTime >= LordWarData.getRoundStartTime(roundTemp) then
                if curRound == roundTemp - 1 and curStatus == LordWarData.kRoundEnd then
                    status = LordWarData.kRoundFighting
                    round = roundTemp
                elseif curRound == LordWarData.kRegister and _curTime >= LordWarData.getRoundEndTime(LordWarData.kRegister) then
                    round = LordWarData.kInnerAudition
                    status = LordWarData.kRoundFighting
                elseif curRound == LordWarData.kOutRange and _curTime >= LordWarData.getRoundStartTime(LordWarData.kRegister) then
                    round = LordWarData.kRegister
                    status = LordWarData.kRoundFighting
                end
            else
                break
            end
        end
    end
    if round ~= curRound then
        print("round改变：curRound=", round, "curStatus=", status)
        LordWarData.setCurRound(round)
        LordWarData.setCurStatus(status)
        LordWarData.setCurSubRound(-1)
        tellListener(round, status, "roundChange")
    end
    tellListener(round, status, "update")
    if round == LordWarData.kCross2To1 and status >= LordWarData.kRoundFighted then
        print("跨服赛结束")
        close()
    end
end

function close()
    _listeners = nil
    if _node ~= nil then
        _node:removeFromParentAndCleanup(true)
        _node = nil
    end
end

--[[
	@des : 阶段变化
--]]
function roundChange( p_round, p_status, p_subRound)
    print("roundChange推送了")
	if(p_round > LordWarData.kCross2To1) then
		return
	end
    print("后端推送数据round变化")
	LordWarData.setCurRound(p_round)
	LordWarData.setCurStatus(p_status)
    if p_status == LordWarData.kRoundFighted then
        p_subRound = 4
    elseif p_status > LordWarData.kRoundFighted then
        p_subRound = -1
    end
    LordWarData.setCurSubRound(p_subRound)
    tellListener(p_round, p_status, "roundChange")
	-- 发奖状态清除上阶段助威人
	if(p_status == LordWarData.kRoundFighted) then
		LordWarData.setCheerInfo("0", "0")
	end
	print(" p_round, p_status",  p_round, p_status)
end

function tellListener(p_round, p_status, p_event)
    if _listeners == nil then
        return
    end
    for k, v in pairs(_listeners) do
        v(p_round, p_status, p_event)
    end
end

function addListener(key, value)
    _listeners = _listeners or {}
    _listeners[key] = value
end

function getCurTime()
    return _curTime
end