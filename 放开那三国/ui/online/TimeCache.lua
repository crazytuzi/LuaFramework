-- Filename：	TimeCache.lua
-- Author：		zhz
-- Date：		2013-7-23
-- Purpose：		时间数据的保存
module ("TimeCache", package.seeall)
require "script/utils/LuaUtil"

local _futureTime =nil 

local _rewardDataCache = {}
-- 设置保存时间
function setFutureTime( futureTime)
	_futureTime =futureTime
end

function getFutureTime( )
	return _futureTime
end

-- 设置 奖励数据
 function setRewardData(_rewardData)
	_rewardDataCache = _rewardData
end

function getRewardData()
	return _rewardDataCache
end
