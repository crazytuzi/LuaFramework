-- FileName: RechargeGiftController.lua
-- Author: yangrui
-- Date: 15-10-30
-- Purpose: function description of module

module ("RechargeGiftController", package.seeall)

--[[
	@des 	: 领取奖励
	@param 	: pRewardId  奖励id  pSelect  奖励档位
	@return : 
--]]
function obtainReward( pRewardId, pSelect, pCallBack )
	local requestCallback = function( ... )
		-- 设置已领取奖励信息
		RechargeGiftData.setReceivedRewardData(pRewardId)
		-- 添加奖励到本地
		local rewardString = nil
		if pSelect == nil then
			rewardString = RechargeGiftData.getRewardById(pRewardId)
		else
			rewardString = RechargeGiftData.getSelectRewardById(pRewardId,pSelect)
		end
		local rewardData = ItemUtil.getItemsDataByStr(rewardString)
		if rewardData ~= nil then
			ItemUtil.addRewardByTable(rewardData)
		end
		RechargeGiftLayer.refreshUI()
		require "script/ui/rechargeActive/RechargeActiveMain"
		RechargeActiveMain.refreshRechargeGiftTipNum(RechargeActiveMain._tagRechargeGift)
		require "script/ui/item/ReceiveReward"
	    ReceiveReward.showRewardWindow(rewardData,nil,1010,-500)
	end
	RechargeGiftService.obtainReward(pRewardId,pSelect,requestCallback)
end