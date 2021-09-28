-- FileName: HeroTurnedController.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统控制层

module("HeroTurnedController", package.seeall)

require "script/ui/turnedSys/HeroTurnedService"
require "script/ui/turnedSys/HeroTurnedData"
require "script/ui/tip/AnimationTip"

--[[
	@desc 	: 获得所有的武将幻化图鉴
	@param 	: pCallback 回调方法
	@return : 
--]]
function getAllTurnInfo( pCallback )
	-- 请求回调
	local requestCallback = function ( pData )
		-- 设置幻化数据
		HeroTurnedData.setAllTurnInfo(pData)

		if pCallback then
			pCallback()
		end
	end
	-- 发送请求
	HeroTurnedService.getAllTurnInfo(requestCallback)
end

--[[
	@desc	: 根据武将id，获取武将可幻化列表
    @param	: pCallback 回调方法
    @param 	: pHid 武将id
    @return	: 
—-]]
function getTurnInfoByHid( pCallback, pHid )
	-- 请求回调
	local requestCallback = function ( pData )
		-- 设置当前选择武将的幻化数据
		HeroTurnedData.setCurTurnInfo(pData)
		if pCallback then
			pCallback(pData)
		end
	end
	-- 发送请求
	HeroTurnedService.getTurnInfoByHid(requestCallback,pHid)
end

--[[
	@desc 	: 显示界面方法
	@param 	: pCallback 回调方法
	@param 	: pHid 武将id
	@param 	: pTurnId 幻化形象id
	@return : 
--]]
function heroTruned( pCallback, pHid, pTurnId )
	-- 判断幻化条件
	local isCan = HeroTurnedData.isCanTurned(pHid)
	if ( isCan == false ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1124"))
		return
	end

	local isUnlock = HeroTurnedData.isUnLockedTurnId(pTurnId)
	if ( isUnlock == false and pTurnId ~= 0 ) then
		AnimationTip.showTip(GetLocalizeStringBy("lgx_1125"))
		return
	end

	-- 请求回调
	local requestCallback = function ( pData )
		-- 设置当前的幻化形象id
		HeroTurnedData.setCurTurnedIdByHid(pHid,pTurnId)
		if pCallback then
			pCallback(pData)
		end
	end

	-- 发送幻化请求
	HeroTurnedService.heroTruned(requestCallback,pHid,pTurnId)
end

