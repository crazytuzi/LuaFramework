-- FileName: HappySignController.lua 
-- Author: shengyixian
-- Date: 15-9-25
-- Purpose: 欢乐签到控制器

module("HappySignController",package.seeall)
require "script/ui/rechargeActive/happySign/HappySignService"
require "script/ui/rechargeActive/happySign/HappySignData"
--[[
	@des 	:获取已经签到的数据
	@param 	:
	@return : 
--]]
function getSignInfo(callBack)
	HappySignService.getSignInfo(function ( ret )
		HappySignData.setLoginData(ret)
		if (callBack) then
			callBack()
		end
	end)
end
--[[
	@des 	:领取奖励
	@param 	:day 领取第几天的奖励 rewardId：当天的奖励中的第几个
	@return : 
--]]
function receive(day,rewardId,costNum)
	-- body
	HappySignData.setCurrSignDay(day)
	-- 接收奖励的回调
	local receiveCallBack = function ()
		-- body
		local isSelected = HappySignData.getIsSelectedByID(day)
		local rewardData = HappySignData.getRewardInfoById(day).reward
		local reward = ItemUtil.getItemsDataByStr(rewardData)
		require "script/ui/item/ReceiveReward"
		if isSelected then
			reward = {reward[rewardId]}
		end
		HappySignData.receiveReward(reward)
		ReceiveReward.showRewardWindow( reward, nil , 10008, -800 )		
		HappySignCell.reveiveCallBack()
		RechargeActiveMain.refreshHappySignTip()
		HappySignLayer.updateDaysLabel(HappySignData.getSignedDays())
		local goldCost = costNum
		if(goldCost == nil) then
			goldCost = 0
		end
		-- 刷新成功，减去金币
        UserModel.addGoldNumber(-goldCost)
	end
	HappySignService.gainSignReward(day,rewardId,function ( ... )
		-- body
		receiveCallBack()
	end)
end

