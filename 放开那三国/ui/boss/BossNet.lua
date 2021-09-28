
-- Filename：	BossNet.lua
-- Author：		Li Pan
-- Date：		2013-12-26
-- Purpose：		世界boss

module("BossNet", package.seeall)

require "script/network/Network"
require "script/ui/boss/BossData"

local network_count = 0

function getBossInfo(uiCallBack)
	local function callback(flag,dictData,err)
		print("the BossData.bossInfo is :")
		print_t(dictData)
		BossData.bossInfo = dictData.ret
		print_t(dictData.ret)
		-- print("the dictData is :" .. dictData.ret.boss_time)

		uiCallBack()
	end 
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.enterBoss", "boss.enterBoss", args, true)
end

function getSpecialPlayer(uiCallBack)
	local function callback( flag,dictData,err )
		BossData.superHeroInfo = dictData.ret
		print("the getSpecialPlayer is :")
		print_t(dictData)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.getSuperHero", "boss.getSuperHero", args, true)
end

function getRankList(uiCallBack)
	local function callback( flag,dictData,err )
		BossData.rankList = dictData.ret
		print("the rankList is :")
		print_t(BossData.rankList)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.getAtkerRank", "boss.getAtkerRank", args, true)
end

--鼓舞
function silverInspire(uiCallBack)
	local function callback( flag,dictData,err )
		local ret = dictData.err
		if(ret ~= "ok") then
			return
		end
		BossData.inspireInfo = dictData.ret
		print("the rankList is :")
		print_t(BossData.inspireInfo)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.inspireBySilver", "boss.inspireBySilver", args, true)
end

function goldInspire(uiCallBack)
	local function callback( flag,dictData,err )
		BossData.inspireInfo = dictData.ret
		print("the rankList is :")
		print_t(BossData.inspireInfo)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.inspireByGold", "boss.inspireByGold", args, true)
end


function attackBoss( uiCallBack )
	local function callback( flag,dictData,err )
		local ret = dictData.err
		if(ret ~= "ok") then
			return
		end
		BossData.attackData = dictData.ret
		print("the attackData is :")
		print_t(BossData.attackData)
		print("dictData.ret.success",dictData.ret.success,type(dictData.ret.success))
		if(dictData.ret.success == "true" or dictData.ret.success == true)then
			uiCallBack()
		end
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.attack", "boss.attack", args, true)

	-- added by zhz ,台湾炫耀系统
	-- require "script/ui/showOff/ShowOffUtil"
	-- ShowOffUtil.sendShowOffByType(9)

end
	

function rebirthBoss( uiCallBack )
	local function callback( flag,dictData,err )
		local ret = dictData.err
		if(ret ~= "ok") then
			return
		end
		BossData.rebirthData = dictData.ret
		print("the attackData is :")
		print_t(BossData.rebirthData)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.revive", "boss.revive", args, true)
end


function bossOver( uiCallBack )
	local function callback( flag,dictData,err )
		BossData.prizeData = dictData.ret
		print("the prizeData is :")
		print_t(BossData.prizeData)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.over", "boss.over", args, true)
end


function leaveBoss( uiCallBack )
	local function callback( flag,dictData,err )
		BossData.leaveBossData = dictData.ret
		print("the leaveBossData is :")
		print_t(BossData.leaveBossData)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	Network.rpc(callback, "boss.leaveBoss", "boss.leaveBoss", args, true)
end


function getRank( uiCallBack )
	local function callback( flag,dictData,err )
		BossData.rankInfo = dictData.ret
		print("the rankInfo is :")
		print_t(BossData.rankInfo)
		uiCallBack()
	end
	local args = CCArray:create()
	args:addObject(CCString:create(tostring(1)))
	network_count = network_count +1
	Network.rpc(callback, "boss.getMyRank" .. network_count , "boss.getMyRank", args, true)
end

--[[
	@author:		bzx
	@desc:			保存Boss阵型
	@return 	nil
--]]
function setBossFormation( uiCallBack )
	local callback = function ( flag , dictData, err )
		if not err then
			return
		end
		local formation = DataCache.getCurFormation()
		BossData.setFormation(formation)
		if uiCallBack ~= nil then
			uiCallBack()
		end
	end
	local args = Network.argsHandler(1)
	Network.rpc(callback, "boss.setBossFormation", "boss.setBossFormation", args, true)
end

--[[
	@author:		bzx
	@desc:			设置是否使用Boss阵型
--]]
function useFormation( uiCallBack )
	local isUseFormation = nil
	if BossData.isUseFormation() ~= "1" then
		isUseFormation = "1"
	else
		isUseFormation = "0"
	end
	local callback = function ( flag , dictData, err )
		if not err then
			return
		end
		BossData.setUseFormation(isUseFormation)
		if uiCallBack ~= nil then
			uiCallBack()
		end
	end
	local args = Network.argsHandler(1, isUseFormation)
	Network.rpc(callback, "boss.setFormationSwitch", "boss.setFormationSwitch", args, true)
end






