-- FileName: CountryWarUtil.lua
-- Author: lichenyang
-- Date: 2015-11-19
-- Purpose: 国战工具模块
--[[TODO List]]

module("CountryWarObserver", package.seeall)

require "script/ui/countryWar/CountryWarMainData"

local _lastStage 	= nil
local _currStage 	= nil
local _listeners 	= {}
local _actionNode 	= nil

function initObserver()
	if _actionNode ~= nil then
		error("init Country war Observer Error")
		return
	end
	_listeners 	= {}
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	_lastStage = CountryWarMainData.getCurStage()
	_currStage = CountryWarMainData.getCurStage()

	_actionNode = CCNode:create()
	runningScene:addChild(_actionNode)
	print("curr stage = ",_currStage)
	schedule(_actionNode, updateTimer, 1)
end

function destoryObserver()
	_actionNode:stopAllActions()
	_actionNode:removeFromParentAndCleanup(true)
	_actionNode = nil
	_listeners = {}
end

function updateTimer()
	_currStage = CountryWarMainData.getCurStage()
	if _currStage > _lastStage then
		_lastStage = _currStage
		dispatch(_currStage)
	end
	print(string.format("stage check cur = %s last = %s", _currStage, _lastStage))
end

function dispatch( pStage )
	local requestCallback = function ( pRecData )
		CountryWarMainData.setCountryWarInfo(pRecData)
		for k,v in pairs(_listeners) do
			v(pStage)
		end
	end
	require "script/ui/countryWar/CountryWarMainService"
	CountryWarMainService.getCoutrywarInfo(requestCallback)
end

function registerListener( pListener )
	if pListener then
		table.insert(_listeners, pListener)
	end	
end

function removeListener( pListener )
	for k,v in pairs(_listeners) do
		if v == pListener then
			_listeners[k] = nil
		end
	end
end

