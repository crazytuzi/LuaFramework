-- FileName: KuafuController.lua 
-- Author: yangrui 
-- Date: 15-9-29
-- Purpose: function description of module 

module ("KuafuController", package.seeall)

--[[
	@des 	: 挑战
	@param 	: 
	@return : 
--]]
function attack( pServerId, pPid, pCrazy, pSkip, pEnemyData, itemBtn )
	local requestCallback = function( pRetData )
	    -- 战斗播放结束后的回调
		function atkFunc( ... )
			-- 按钮恢复可点击状态
			if(itemBtn ~= nil)then
		    	itemBtn:setEnabled(true)
		    end
		    -- 更新剩余次数
		    -- 减挑战次数
		    if pCrazy == 0 then
				KuafuData.setAtkTimes(1)
			elseif pCrazy == 1 then
				KuafuData.setAtkTimes(2)
			end
			-- 刷新挑战次数Label
			KuafuMatchLayer.refreshAtkNumFunc()
	        -- 取消狂怒模式
	        KuafuData.setFury(false)
	        -- 重设狂怒按钮及特效
	        KuafuMatchLayer.refreshFuryModelAffterBattle()
			-- 战斗之后的提示
			-- local str = nil
		    if ( pRetData.appraisal ~= "E" and pRetData.appraisal ~= "F" ) then
		        -- 胜利
		        print("===胜利啦")
		        -- 取得的跨服荣誉
				local enemyForce = tonumber(pRetData.fight_force)
		        local winScore = KuafuData.getShouldAddHonor(enemyForce)
	    		-- 如果胜利  加胜场次数    ！！！
				KuafuData.setWinTimes(1)
		        -- 更新跨服荣誉
		        UserModel.addCrossHonor(winScore)
		        -- 刷新胜场进度条
		        KuafuMatchLayer.refreshRewardProgressBar()
		        -- 刷新胜场奖励宝箱
		        for id=1,4 do
		        	KuafuMatchLayer.refreshChestBtn(id)
		        end
		        -- 如果三个对手都击败了  设置对手信息
		        if pRetData.rival ~= nil then
		        	KuafuData.setEnemyData(pRetData.rival)
		        else
			        -- 处理战斗胜利的数据
			        KuafuData.modifyEnemyData(pPid,pServerId)
			    end
		        -- 刷新玩家形象
		        KuafuMatchLayer.refreshBattlePlayer()
		    else
		    	-- 失败
		    	-- 取得的跨服荣誉
		    	local failScore = KuafuData.getFailHonor()
		    	-- 更新跨服荣誉
		        UserModel.addCrossHonor(failScore)
		    end
		end
	    -- 调用 播放战斗
		require "script/battle/BattleLayer"
		local closeBattleLayer = function()
            BattleLayer.closeLayer()
        end
		-- 比武结束后的结算面板
		-- createAfterBattleLayer( appraisal, enemyDataTab, CallFun, fightStr )
		local resultLayer = KuafuResultLayer.createAfterBattleLayer(pRetData,pEnemyData,closeBattleLayer)
		
		-- showBattleWithString(str,callbackFunc,afterBattleView,bgName,bgmName,armyIds,onBattleView,isShowSkipButton,isShowStrengthNumber,p_battleType)
		BattleLayer.showBattleWithString(pRetData.fightRet,atkFunc,resultLayer,"ducheng.jpg","music11.mp3",nil,nil,nil,false)
	end
	KuafuService.attack(pServerId, pPid, pCrazy, pSkip, requestCallback)
end

--[[
	@des 	: 购买挑战次数
	@param 	: 
	@return : 
--]]
function buyAtkNum( pNum, pTotalPrice )
	local num = tonumber(pNum)
	local totalPrice = tonumber(pTotalPrice)
	local requestCallback = function( ... )
		-- 扣除金币
		UserModel.addGoldNumber(-totalPrice)
		-- 增加购买次数
		KuafuData.setBuyAtkNum(num)
		-- 刷新金币
		KuafuLayer.refreshGoldLabelFunc()
		-- 刷新比武次数
		KuafuMatchLayer.refreshAtkNumFunc()
	end
	KuafuService.buyAtkNum(num, requestCallback)
end

--[[
	@des 	: 刷新对手们
	@param 	: 
	@return : 
--]]
function refreshRival( ... )
	local requestCallback = function( pRetData )
		-- 设置对手信息
		KuafuData.setEnemyData(pRetData)
		-- 刷新对手
		KuafuMatchLayer.refreshBattlePlayer()
		-- 如果还有免费刷新次数  减少免费刷新次数
		local leftRefreshTimes = KuafuData.getFreeRefreshTimes()-KuafuData.getRefreshTimes()
		if leftRefreshTimes > 0 then
			KuafuData.setFreeRefreshTimes(-1)
			if leftRefreshTimes == 1 then
				-- 刷新  刷新按钮
				KuafuMatchLayer.createRefreshBtnFont()
			end
		else
			-- 减去金币
			UserModel.addGoldNumber(-KuafuData.getRefreshCost())
			-- 刷新金币
			KuafuLayer.refreshGoldLabelFunc()
		end
	end

	KuafuService.refreshRival(requestCallback)
end

--[[
	@des 	: 领取胜场奖励
	@param 	: 
	@return : 
--]]
function getPrize( pNum, pRewardTab )
	local requestCallback = function( ... )
		-- 修改本地数据 加奖励
		ItemUtil.addRewardByTable(pRewardTab)
		-- 展现领取奖励列表
		require "script/ui/item/ReceiveReward"
		ReceiveReward.showRewardWindow(pRewardTab,nil,1001,-425)
		-- 刷新金币数
		KuafuLayer.refreshGoldLabelFunc()
		-- 刷新银币数
		KuafuLayer.refreshSliverLabelFunc()
		-- 设置已领取奖励信息  传入领取需要的胜场
		KuafuData.setRewardData(pNum)
		-- 宝箱处理
		ShowChestLayer.chestRewardFunc()
	end

	KuafuService.getPrize(pNum, requestCallback)
end

--[[
	@des 	: 膜拜
	@param 	: 
	@return : 
--]]
function worship( pNum, pNotRefresh )
	local rewardData = nil
	if pNum == 1 then
		rewardData = KuafuData.getFirstProstrateReward()
	elseif pNum == 2 then
		rewardData = KuafuData.getSecondProstrateReward()
	end
	rewardData = ItemUtil.getItemsDataByStr(rewardData)
	local requestCallback = function( ... )
		-- 增加膜拜次数
		KuafuData.setProstrateTimes(1)
		-- 修改本地数据 加奖励
		ItemUtil.addRewardByTable(rewardData)
		-- 展现领取奖励列表
		require "script/ui/item/ReceiveReward"
		ReceiveReward.showRewardWindow(rewardData,nil,1001,-425)
		-- 刷新金币数
		KuafuLayer.refreshGoldLabelFunc()
		-- 刷新银币数
		KuafuLayer.refreshSliverLabelFunc()
		-- 刷新膜拜奖励  第一次膜拜才刷新
		if pNotRefresh ~= true then
			KuafuProstrateLayer.createTableview()
		end
		-- 刷新膜拜按钮
		KuafuProstrateLayer.createProstrateBtn()
	end

	KuafuService.worship(requestCallback)
end

--[[
	@des 	: 拉取排行榜信息
	@param 	: 
	@return : 
--]]
function getRankList( pCallback )
	local requestCallback = function( pRetData )
		KuafuData.setRankData(pRetData)
		if pCallback ~= nil then
			pCallback()
		end
	end

	KuafuService.getRankList(requestCallback)
end
