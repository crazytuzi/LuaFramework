-- FileName: DevilTowerController.lua
-- Author: lgx
-- Date: 2016-07-29
-- Purpose: 试炼梦魇控制层

module("DevilTowerController", package.seeall)

require "script/ui/deviltower/DevilTowerData"
require "script/ui/deviltower/DevilTowerService"
require "script/ui/item/ItemUtil"
require "script/ui/tip/AnimationTip"

-- 模块局部变量 --


--[[
	@desc	: 获取试炼梦魇信息
    @param	: pCallback 回调方法
    @return	: 
—-]]
function getDevilTowerInfo( pCallback )
	-- 请求回调
	local requestCallback = function ( pData )
		-- 初始化试炼数据
		DevilTowerData.setDevilTowerInfo(pData)
		if pCallback then
			pCallback()
		end
	end
	-- 发送请求
	DevilTowerService.getTowerInfo(requestCallback)
end

--[[
	@desc	: 攻击当前塔层怪物
	@param	: pCallback 回调方法
    @param  : pLayerId 塔层id
	@param  : pArmyId 塔层据点id
    @return	: 
—-]]
function attackNpc( pCallback, pLayerId, pArmyId )
	-- 1.判断背包是否满
	if (ItemUtil.isBagFull() == true) then
		return
	end

	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)

	-- 2.判断是否在扫荡
	if (DevilTowerData.isDevilTowerSweep() == true) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2992"))
	elseif (tonumber(towerInfo.can_fail_hell) <= 0) then
	-- 3.攻打次数不足，使用金币购买
		buyDefeatNum()
	elseif (DevilTowerData.isDevilTowerHadPassed() == true) then
	-- 4.判断是否到达最高层
		AnimationTip.showTip(GetLocalizeStringBy("key_1677"))
	elseif (UserModel.getAvatarLevel() < curFloorDesc.needLevel) then
	-- 5.判断主角需要的等级
		AnimationTip.showTip(GetLocalizeStringBy("key_1468"))
	else
		-- 进入战斗
		local enterCallback = function ( pRet )
			-- 进入塔层成功
			if (pRet == "ok") then
				local defeatCallback = function( pData )
					-- 攻击怪物成功
					if (pData.fightRet ~= nil) then
						local battleEndCallback = function()
							-- 战斗结束 离开塔层
							if (pCallback ~= nil) then
								pCallback(pData.newcopyorbase)
							end
							DevilTowerService.leaveTowerLv(nil,pLayerId)
						end
						-- 结算面板
						local closeResultCallback = function()
							-- 播放试炼梦魇背景音乐
							require "script/ui/deviltower/DevilTowerLayer"
							DevilTowerLayer.playDevilTowerBgMusic()
						end
						require "script/ui/deviltower/DevilTowerFightResultLayer"
    					local resultLayer = DevilTowerFightResultLayer.createLayer(pData.appraisal,pArmyId,pData.reward,closeResultCallback,nil,nil)
					    
					    -- 进入战斗场景
					    require "script/battle/BattleLayer"
						BattleLayer.showBattleWithString(pData.fightRet,battleEndCallback,resultLayer,nil,nil,nil,nil,nil,false,4)
					end
				end
				DevilTowerService.defeatMonster(defeatCallback,pLayerId,pArmyId)
			end
		end
		DevilTowerService.enterLevel(enterCallback,pLayerId)
	end
end

--[[
	@desc	: 重置试炼梦魇
    @param	: pCallback 回调方法
    @return	: 
—-]]
function resetDevilTower( pCallback )
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local curFloorDesc = DevilTowerData.getDevilTowerById(towerInfo.cur_hell)

	if (tonumber(towerInfo.cur_hell) <= 1) then
		-- 1.判断是否在第一层
		AnimationTip.showTip(GetLocalizeStringBy("key_1980"))
	elseif (DevilTowerData.isDevilTowerSweep() == true) then
		-- 2.判断是否在扫荡
		AnimationTip.showTip(GetLocalizeStringBy("key_2244"))
	elseif (tonumber(towerInfo.reset_hell) <= 0) then
		-- 3.判断剩余重置次数
		buyResetNum(pCallback)
	else
		-- 弹出重置提示框
		local resetConfirmCallback = function( pIsConfirm )
			if(pIsConfirm == true)then
				local resetCallback = function()
					-- 扣除重置次数
					DevilTowerData.addResetTimes(-1)

					-- 修改当前塔层为1
					DevilTowerData.changeCurHell(1)

					-- 修改成通关状态
					DevilTowerData.setDevilTowerPassedStatus(false)

					-- 修改失败次数
					local loseTimes = DevilTowerData.getMaxLoseTimes()
					DevilTowerData.changeDefeatTimes(loseTimes)

					-- 提示
					AnimationTip.showTip(GetLocalizeStringBy("key_3103"))

					if (pCallback ~= nil) then
						pCallback()
					end
				end
				DevilTowerService.resetTower(resetCallback)
			end
		end
		AlertTip.showAlert(GetLocalizeStringBy("key_1521"), resetConfirmCallback, true, nil, GetLocalizeStringBy("key_2864"), GetLocalizeStringBy("key_2326"), nil)
	end
end

--[[
	@desc	: 立即完成试炼梦魇
    @param	: pCallback 回调方法
    @return	: 
—-]]
function finishDevilTower( pCallback )
	-- 1.是否在扫荡中
	local isSweep = DevilTowerData.isDevilTowerSweep()
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	require "script/ui/deviltower/FinishNowDialog"
	local cormfirmFinishCallback = function( pLevel )
		-- 判断输入的扫荡层数是否正确
		local isOK = checkEndLevel(pLevel)
		if (isOK) then
			local curHell = towerInfo.cur_hell
			local wipeGold = DevilTowerData.getWipeGold()
    		local costGold = (pLevel-curHell+1)*wipeGold
			if (costGold > UserModel.getGoldNumber()) then
		        -- 金币不足
		        require "script/ui/tip/LackGoldTip"
		        LackGoldTip.showTip()
		        return false
		    end
			-- 请求回调
		    local finishCallback = function( pRetData )
		    	-- 扣除金币
		    	UserModel.addGoldNumber(-costGold)

		    	-- 更新数据
				DevilTowerData.setDevilTowerInfo(pRetData)

				-- 提示
				AnimationTip.showTip(tonumber(DevilTowerData.getDevilTowerInfo().cur_hell)..GetLocalizeStringBy("llp_67"))

				-- 回调 UI表现
				if (pCallback ~= nil) then
					pCallback()
				end
		    end
		    -- 发送请求
		    DevilTowerService.sweepByGold(finishCallback,pLevel)
		    return true
		else
			return false
		end
	end
	FinishNowDialog.showDialog(isSweep,towerInfo,cormfirmFinishCallback,nil,nil)
end

--[[
	@desc	: 判断输入的层数是否正确
    @param	: pLevel 层数
    @return	: bool 层数是否正确
—-]]
function checkEndLevel( pLevel )
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local maxHell = towerInfo.max_hell
	local curHell = towerInfo.cur_hell

	if (pLevel == nil) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2954"))
        return false
    end

    pLevel = string.gsub(pLevel, " ", "")
    if (pLevel == nil or pLevel == "") then
        AnimationTip.showTip(GetLocalizeStringBy("key_2954"))
        return false
    end

    if (string.isIntergerByStr(pLevel) == false ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_2542"))
        return false
    end

    pLevel = tonumber(pLevel)
    if (pLevel > tonumber(maxHell)) then
        AnimationTip.showTip(GetLocalizeStringBy("key_3066").. maxHell .. GetLocalizeStringBy("key_2073"))
        return false
    end

    if (pLevel < tonumber(curHell)) then
        AnimationTip.showTip(GetLocalizeStringBy("key_3377").. (tonumber(curHell)) .. GetLocalizeStringBy("key_2073"))
        return false
    end
    -- 默认返回
    return true
end

--[[
	@desc	: 扫荡到指定塔层
    @param	: pCallback 回调方法
    @return	: 
—-]]
function sweepDevilTower( pCallback )
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	if (DevilTowerData.isDevilTowerHadPassed() == true) then
		-- 1.判断是否到达最高层
		AnimationTip.showTip(GetLocalizeStringBy("key_2532"))
	elseif (tonumber(towerInfo.cur_hell) > tonumber(towerInfo.max_hell)) then
		-- 2.判断是否当前塔层是否大于历史最大塔层
		AnimationTip.showTip(GetLocalizeStringBy("key_2264"))
	elseif (tonumber(towerInfo.can_fail_hell) <= 0) then
		-- 3.攻打次数不足，使用金币购买
		buyDefeatNum()
	else
		-- 弹出扫荡提示框
		require "script/ui/deviltower/DevilTowerSweepDialog"
		local maxHell = towerInfo.max_hell
		local curHell = towerInfo.cur_hell
		local cormfirmSweepCallback = function( pLevel )
			-- 判断输入的扫荡层数是否正确
			local isOK = checkEndLevel(pLevel)
			if (isOK) then
				-- 请求回调
			    local sweepCallback = function( pRetData )
			    	-- 更新数据
					DevilTowerData.setDevilTowerInfo(pRetData)

					-- 回调 UI表现
					if (pCallback ~= nil) then
						pCallback(pLevel)
					end
			    end
			    -- 发送请求
			    DevilTowerService.sweep(sweepCallback,curHell,pLevel)
			    return true
			else
				return false
			end
		end
		DevilTowerSweepDialog.showDialog(maxHell,cormfirmSweepCallback,nil,nil)
	end
end

--[[
	@desc	: 取消扫荡
    @param	: pCallback 回调方法
    @return	: 
—-]]
function endSweepDevilTower( pCallback )
	-- 停止扫荡计时器
	DevilTowerLayer.stopScheduler()
	-- 请求回调
	local endSweepCallback = function( pRetData )
		-- 提示
		AnimationTip.showTip(GetLocalizeStringBy("key_1361"))
		-- 更新数据
		DevilTowerData.setDevilTowerInfo(pRetData)

		-- 回调 UI表现
		if (pCallback ~= nil) then
			pCallback()
		end
	end
	-- 发送请求
	DevilTowerService.endSweep(endSweepCallback)
end

--[[
	@desc	: 进入下一层
    @param	: pCallback 回调方法
    @return	: 
—-]]
function enterNextLayer( pCallback )
	-- 1.判断是否在扫荡
	if (DevilTowerData.isDevilTowerSweep() == true) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2992"))
		return
	end
	-- 2.判断是否到达最高层
	if (DevilTowerData.isDevilTowerHadPassed() == true) then
		AnimationTip.showTip(GetLocalizeStringBy("key_1677"))
		return
 	end
	-- 3.回调 UI表现
	if (pCallback ~= nil) then
		pCallback()
	end
end

--[[
	@desc	: 购买挑战次数
    @param	: 
    @return	: 
—-]]
function buyDefeatNum()
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	if (DevilTowerData.getMaxBuyLoseTimes() <= tonumber(towerInfo.gold_buy_hell)) then
		-- 1.判断购买挑战次数限制
		AnimationTip.showTip(GetLocalizeStringBy("key_3379"))
	else
		local costGold = DevilTowerData.getCostGoldByTimes(tonumber(towerInfo.gold_buy_hell)+1)
		local confirmCallback = function()
			-- 确定购买
			if (UserModel.getGoldNumber() < costGold) then
				-- 金币不足
				require "script/ui/tip/LackGoldTip"
    			LackGoldTip.showTip()
			else
				local buyAttackNumCallback = function( pRet )
					-- 购买成功
					-- 扣除金币
					local goldNum = tonumber(pRet)
					UserModel.addGoldNumber(-goldNum)

					-- 更新数据
					DevilTowerData.addBuyDefeatNumByGold(1)
					DevilTowerData.addDefeatTimes(1)

					-- 提示
					AnimationTip.showTip(GetLocalizeStringBy("key_2277"))

					-- 刷新界面
					require "script/ui/deviltower/DevilTowerLayer"
					DevilTowerLayer.refreshTopUI()
					DevilTowerLayer.refreshLoveStar()
				end
				DevilTowerService.buyDefeatNum(buyAttackNumCallback)
			end
		end
		-- 弹出花费金币购买挑战次数提示框
		require "script/ui/tip/AlertTipGold"
		AlertTipGold.showAlert(GetLocalizeStringBy("key_1949"), costGold, confirmCallback)
	end
end

--[[
	@desc	: 购买重置次数
    @param	: pCallback 回调方法
    @return	: 
—-]]
function buyResetNum( pCallback )
	-- 获取数据
	local towerInfo = DevilTowerData.getDevilTowerInfo()
	local maxBuyTimes = DevilTowerData.getMaxBuyResetTimes()
	local hadBuyTimes = tonumber(towerInfo.buy_hell_num)
	if (maxBuyTimes <= hadBuyTimes) then
		-- 1.判断购买重置次数限制
		AnimationTip.showTip(GetLocalizeStringBy("key_2543"))
	else
		AnimationTip.showTip(GetLocalizeStringBy("key_3304"))
		-- 弹出花费金币购买重置次数提示框
		require "script/ui/deviltower/BuyResetTimesDialog"
		local costGold = DevilTowerData.getResetCostGold()
		local cormfirmCallback = function()
			if (UserModel.getGoldNumber() < costGold) then
				-- 1.判断金币是否足够
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip()
			else
				local resetByGoldCallback = function()
					-- 扣除金币
					UserModel.addGoldNumber(-costGold)

					-- 增加金币购买重置次数
					DevilTowerData.addResetTimesByGold(1)

					-- 修改当前塔层为1
					DevilTowerData.changeCurHell(1)

					-- 修改成通关状态
					DevilTowerData.setDevilTowerPassedStatus(false)

					-- 修改失败次数
					local loseTimes = DevilTowerData.getMaxLoseTimes()
					DevilTowerData.changeDefeatTimes(loseTimes)

					-- 提示
					AnimationTip.showTip(GetLocalizeStringBy("key_3103"))

					if (pCallback ~= nil) then
						pCallback()
					end
				end
				-- 发送请求 
				DevilTowerService.buyAtkNum(resetByGoldCallback,1)
			end
		end
		BuyResetTimesDialog.showDialog(costGold,maxBuyTimes,hadBuyTimes,cormfirmCallback,nil,nil)
	end
end
