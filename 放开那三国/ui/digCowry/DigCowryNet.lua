-- Filename：	DigCowryNet.lua
-- Author：		Li Pan
-- Date：		2014-1-8
-- Purpose：		挖宝

module("DigCowryNet", package.seeall)

require "script/network/Network"
require "script/ui/digCowry/DigCowryData"

-- *     uid
-- *     today_free_num:int        今天免费挖宝的次数
-- *     today_gold_num:int        今天金币挖宝的次数
-- *     accum_free_num:int        活动期间内免费挖宝的次数
-- *     accum_gold_num:int        活动期间内金币挖宝的次数
-- *     va_rob_tomb:array            主要存储黑名单的物品被挖到的次数        
-- *     [
-- *         black_list:array
-- *         [
-- *             itemTmplId=>robNum
-- *         ]
-- *     ]
-- *     last_refresh_time:int      上一次刷新数据库信息的时间（前端暂时无用）
function getDigInfo(uiCallBack)
	local function callback(flag,dictData,err)
		print("the DigCowryData.digInfo is :")
		print_t(dictData)
		DigCowryData.digInfo = dictData.ret
		print_t(dictData.ret)
		-- print("the dictData is :" .. dictData.ret.boss_time)
		uiCallBack()
	end 
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "robtomb.getMyRobInfo", "robtomb.getMyRobInfo", args, true)
end


function digCowry(uiCallBack, times ,type)
	local function callback(flag,dictData,err)
		local ret = dictData.err
		if(ret ~= "ok") then
			return
		end
		-- print("the digCowry.digInfo is :")
		-- print_t(dictData)
		DigCowryData.DigCowryInfo = dictData.ret
		-- print_t(dictData.ret)
		-- print("the dictData is :" .. dictData.ret.boss_time)
		uiCallBack()
	end 
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(times)))
	-- args:addObject(CCString:create(tostring(type)))

	Network.rpc(callback, "robtomb.rob", "robtomb.rob", args, true)
end
