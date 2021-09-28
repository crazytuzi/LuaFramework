-- FileName: WorldArenaController.lua
-- Author: licong
-- Date: 2015-07-01
-- Purpose: 巅峰对决控制器
--[[TODO List]]

module("WorldArenaController", package.seeall)

require "script/ui/tip/AnimationTip"
require "script/ui/WorldArena/WorldArenaMainData"
require "script/ui/WorldArena/WorldArenaMainService"

--[[
	@des 	: 报名回调
	@param 	: 
	@return :
--]]
function signUpCallback( p_callBack )
	--1.判断报名时间
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local signUpStartTime = WorldArenaMainData.getSignUpStartTime()
	local signUpEndTime = WorldArenaMainData.getSignUpEndTime()
	if( curTime < signUpStartTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1592"))
		return
	end
	if( curTime >= signUpEndTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1593"))
		return
	end
	--2.判断等级
	local needLv = WorldArenaMainData.getworldArenaNeedLv()
	if( needLv > UserModel.getHeroLevel() )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1594", needLv))
		return
	end
	--3.判断是否已经报过名
	local mySignUpTime = WorldArenaMainData.getMySignUpTime()
	if(mySignUpTime > 0)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1595"))
		return
	end

	local requestCallback = function( p_retData )
		--1.更新报名时间
		WorldArenaMainData.setMySignUpTime(p_retData)
		--2.刷新ui
		AnimationTip.showTip(GetLocalizeStringBy("lic_1596"))
		
		if( p_callBack )then
			p_callBack()
		end
	end
	WorldArenaMainService.signUp(requestCallback)
end


--[[
	@des 	: 更新战斗力回调
	@param 	: 
	@return : 
--]]
function updateFmtCallback( p_callBack )
	-- 是否可以更新战斗力
	--1.判断是否已经报过名
	local mySignUpTime = WorldArenaMainData.getMySignUpTime()
	if(mySignUpTime <= 0)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1597"))
		return
	end

	--2.判断是否报名结束
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local signUpEndTime = WorldArenaMainData.getSignUpEndTime()
	if(curTime >= signUpEndTime)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1604"))
		return
	end

	--3.是否有cd
	local lastUpdateTime = WorldArenaMainData.getlastUpdateFightForceTime()
	local updateCD = WorldArenaMainData.getUpdateFightForceCD()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	if( lastUpdateTime + updateCD > curTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1598"))
		return
	end

	local requestCallback = function( p_retData )
		-- 更新上次更新战斗信息时间
		WorldArenaMainData.setlastUpdateFightForceTime(p_retData) -- TODO
		--2.刷新ui
		AnimationTip.showTip(GetLocalizeStringBy("lic_1599"))

		if( p_callBack )then
			p_callBack()
		end
	end
	WorldArenaMainService.updateFmt(requestCallback)
end


--[[
	@des 	: 挑战回调
	@param 	:
	@return : 
--]]
function attackCallback( p_data, p_skip, p_callBack, p_challengCDTime )
	-- 1.攻击时间结束
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local atkEndTime = WorldArenaMainData.getAttackEndTime()
	if( curTime >= atkEndTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1616"))
		return
	end
	-- 2.挑战次数
	local subAtkNum = WorldArenaMainData.getAtkNum()
	if( subAtkNum <= 0 )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1664"))
		return
	end

	-- 3.挑战cd中
	local isInTen = WorldArenaMainData.getIsInLastTen()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	if( isInTen and p_challengCDTime > curTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1738"))
		return
	end

	local requestCallback = function( p_retData )
		if(p_retData.ret == "out_range")then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1605"))
		end

		if(p_retData.ret == "protect")then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1606"))
		end
		
		-- 更新数据
		WorldArenaMainData.updateWorldArenaInfo(p_retData)
		-- 刷新ui
		if( p_callBack )then
			p_callBack( p_retData )
		end
	end

	WorldArenaMainService.attack( p_data.server_id, p_data.pid, p_skip, requestCallback)
end


--[[
	@des 	: 购买挑战次数回调
	@param 	: 
	@return : 
--]]
function buyAtkNumCallback( p_num, p_callBack )
	-- 1.攻击时间结束
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local atkEndTime = WorldArenaMainData.getAttackEndTime()
	if( curTime >= atkEndTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1616"))
		return
	end
	-- 2.金币是否足够
	local costNum = WorldArenaMainData.getBuyAtkNumCost(p_num)
	if(UserModel.getGoldNumber() < costNum ) then  
		require "script/ui/tip/LackGoldTip"    
		LackGoldTip.showTip()
		return
	end
	-- 最大次数限制
	local maxNum = WorldArenaMainData.getBuyAtkMaxNum()
	-- 已购买次数
	local haveBuyNum = WorldArenaMainData.getHaveBuyAtkNum()
	if(haveBuyNum >= maxNum)then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1697"))
		return
	end

	local requestCallback = function( p_retData )
		-- 剩余次数
		WorldArenaMainData.setAtkNum(p_retData)
		-- 已购买次数
		WorldArenaMainData.setHaveBuyAtkNum(haveBuyNum + p_num)
		-- 扣除金币
		UserModel.addGoldNumber(-costNum)
		-- 刷新UI
		AnimationTip.showTip(GetLocalizeStringBy("lic_1600"))

		if( p_callBack )then
			p_callBack()
		end
	end

	WorldArenaMainService.buyAtkNum(p_num,requestCallback)
end


--[[
	@des 	: 重置回调
	@param 	: p_type:'silver'or'gold'
	@return : 
--]]
function resetCallback( p_type, p_callBack )
	-- 1.攻击时间结束
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	local atkEndTime = WorldArenaMainData.getAttackEndTime()
	if( curTime >= atkEndTime )then
		AnimationTip.showTip(GetLocalizeStringBy("lic_1616"))
		return
	end
	-- 判断消耗
	local haveNum = nil
	local costNum = nil
	if( p_type == "silver")then
		--1.银币重置次数
		local maxNum = WorldArenaMainData.getMaxResetNumBySilver()
		haveNum = WorldArenaMainData.getHaveResetNumBySilver()
		if( haveNum >= maxNum)then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1661"))
			return
		end
		--2.银币花费
		costNum = WorldArenaMainData.getNextResetCostBySilver()
		if(costNum > UserModel.getSilverNumber())then
			AnimationTip.showTip(GetLocalizeStringBy("lic_1662"))
			return
		end
	elseif( p_type == "gold")then
		--1.金币花费
		haveNum = WorldArenaMainData.getHaveResetNumByGold()
		costNum = WorldArenaMainData.getNextResetCostByGold()
		if(costNum > UserModel.getGoldNumber())then
			require "script/ui/tip/LackGoldTip"    
			LackGoldTip.showTip()
			return
		end
	else
		print("erro")
	end

	local requestCallback = function( p_retData )
		-- 修改数据
		if( p_type == "silver")then
			-- 修改已重置次数
			WorldArenaMainData.setHaveResetNumBySilver(haveNum + 1)
			-- 扣除银币
			UserModel.addSilverNumber(-costNum)
		elseif( p_type == "gold")then
			-- 修改已重置次数
			WorldArenaMainData.setHaveResetNumByGold(haveNum + 1)
			-- 扣除金币
			UserModel.addGoldNumber(-costNum)
		else
			print("erro")
		end
		-- 刷新ui
		AnimationTip.showTip(GetLocalizeStringBy("lic_1663"))

		if(p_callBack)then
			p_callBack()
		end
	end
	WorldArenaMainService.reset(p_type, requestCallback)
end








