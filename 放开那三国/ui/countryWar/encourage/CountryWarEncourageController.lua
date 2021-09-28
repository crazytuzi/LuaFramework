-- FileName: CountryWarEncourageController.lua
-- Author: yangrui
-- Date: 2015-11-18
-- Purpose: 国战鼓舞

module("CountryWarEncourageController", package.seeall)

--[[
	@des 	: 鼓舞
	@param 	: 
	@return : 
--]]
function inspire( pCallback )
	-- 国战币是否满足
	local haveCountryWarCoin = CountryWarMainData.getCocoin()
	local encourageCost = CountryWarEncourageData.getEncourageCost()
	if haveCountryWarCoin < encourageCost then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5008"))  -- 国战币不足
		return
	end
	-- 攻击鼓舞是否已达上限
	local encouragedTimes = CountryWarEncourageData.getEncourageForceTimes()
	local encourageUpperTimes = CountryWarEncourageData.getEncourageUpperLevel()
	if encouragedTimes >= encourageUpperTimes then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5009"))
		return
	end
	local requestCallback = function( pData )
		if pData.ret == "ok" then
			-- 扣除国战币
			local encourageCost = CountryWarEncourageData.getEncourageCost()
			CountryWarMainData.addCocoin(-encourageCost)
			-- 增加攻击鼓舞次数
			CountryWarEncourageData.addEncourageForceTimes(1)
			-- 添加攻击提升
			local upVal = CountryWarEncourageData.getEncourageUpForcePercent()
			CountryWarEncourageData.addForceUpValue(upVal)
			-- 刷新攻击提升Label
			CountryWarEncourageLayer.updateForceUpLabel()
			-- 刷新国战币
			CountryWarPlaceLayer.refreshCoin()
			if pCallback ~= nil then
				pCallback()
			end
		end
	end
	CountryWarEncourageService.inspire(requestCallback)
end

--[[
	@des 	: 清除达阵后的cd
	@param 	: 
	@return : 
--]]
function clearJoinCd( pCallback )
	-- 是否有参战冷却
    local curBattleCD = CountryWarPlaceData.getCanJoinTime()
	local curTime = TimeUtil.getSvrTimeByOffset(0)
	if curTime >= curBattleCD then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5007"))
		return
	end
	-- 国战币是否满足
	local haveCountryWarCoin = CountryWarMainData.getCocoin()
	local removeCDCost = CountryWarEncourageData.getRemoveBattleCDCost()
	if haveCountryWarCoin < removeCDCost then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5008"))  -- 国战币不足
		return
	end
	-- 是否有离场冷却
	if TimeUtil.getSvrTimeByOffset(0) < CountryWarPlaceData.getQuitReadyTime() then
		AnimationTip.showTip(GetLocalizeStringBy("lcyx_129"))
		return
	end
	local requestCallback = function( pData )
		if pData == "ok" then
			-- 扣除国战币
			local removeCDCost = CountryWarEncourageData.getRemoveBattleCDCost()
			CountryWarMainData.addCocoin(-removeCDCost)
			-- 刷新国战币
			CountryWarPlaceLayer.refreshCoin()
			if pCallback ~= nil then
				pCallback()
			end
		end
	end
	CountryWarEncourageService.clearJoinCd(requestCallback)
end

--[[
 	@des 	: 手动回血
 	@param 	: 
 	@return : 
 --]]
function recoverByUser( pCallback )
	-- 是否需要回满血怒
	if not CountryWarEncourageData.judgeIsNeedRecoveryBlood() then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5020"))
		return
	end
	-- 是否可以回血
	local usrOnRoadData = CountryWarPlaceData.getUserInfoOnRoad()
	if usrOnRoadData.exit == 1 then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5023"))
		return
	end
	-- 国战币是否满足
	local haveCountryWarCoin = CountryWarMainData.getCocoin()
	local recoveryBloodCost = CountryWarEncourageData.getRecoveryBloodCost()
	if haveCountryWarCoin < recoveryBloodCost then
		AnimationTip.showTip(GetLocalizeStringBy("yr_5008"))  -- 国战币不足
		return
	end
	local requestCallback = function( pData )
		if pData == "fail" then
			-- 啥也不处理
			return
		end
		-- 扣除国战币
		local recoveryBloodCost = CountryWarEncourageData.getRecoveryBloodCost()
		CountryWarMainData.addCocoin(-recoveryBloodCost)
		-- 刷新国战币
		CountryWarPlaceLayer.refreshCoin()
		-- 补满血
		CountryWarPlaceData.setUserRecoverOnRoad()
		if pCallback ~= nil then
			pCallback()
		end
	end
	CountryWarEncourageService.recoverByUser(requestCallback)
end

--[[
 	@des 	: 手动设置恢复参数
 	@param 	: 
 	@return : 
 --]]
function setRecoverPara( pPercent, pCallback )
	-- ret:string	ok|fail|poor,成功|失败|数值不足
	local requestCallback = function( pData )
		if pData == "ok" then
			if pCallback ~= nil then
				pCallback()
			end
		end
	end
	CountryWarEncourageService.setRecoverPara(pPercent,requestCallback)
end

--[[
 	@des 	: 自动回血开关
 	@param 	: 
 	@return : 
 --]]
function turnAutoRecover( pOnOrOff, pCallback )
	-- ret:string	ok|fail|poor,成功|失败|数值不足
	local requestCallback = function( pData )
		if pData == "ok" then
	        -- 保存设置的状态
	        CountryWarPlaceData.setAutoRecoverState(pOnOrOff)
			if pCallback ~= nil then
				if pOnOrOff == 1 then
					pCallback()
				end
			end
		end
	end
	CountryWarEncourageService.turnAutoRecover(pOnOrOff,requestCallback)
end
