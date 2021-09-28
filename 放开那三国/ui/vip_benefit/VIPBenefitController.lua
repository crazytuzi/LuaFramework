-- Filename：	VIPBenefitController.lua
-- Author：		Fu Qiongqiong
-- Date：		2016-4-7
-- Purpose：		vip每周礼包控制器

module("VIPBenefitController", package.seeall)
require "script/ui/vip_benefit/VIPBenefitService"
require "script/ui/vip_benefit/VIPBenefitData"
require "script/ui/item/ReceiveReward"
-- require "script/ui/rechargeActive/RechargeActiveMain"
function buyWeekGift(pId,pCallback)
	--判断背包
	require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
	local buyCallback = function ( pRecData )
		if(pRecData == "ok")then
			--扣除金币
			local goldCost = VIPBenefitData.getGoldCost(pId)
			UserModel.addGoldNumber(- goldCost)
			--修改缓存,修改界面按钮状态
			-- VIPBenefitLayer.setWeekGiftBag(pId)
			--修改缓存,修改小红点状态
			VIPBenefitData.changeAlreadyBag(pId)
			--刷新界面
			VIPBenefitLayer.updateUI()
			--刷新每周礼包界面的红点
			VIPBenefitLayer.delateSecondTip()
			--刷新小红点提示
			require "script/ui/rechargeActive/RechargeActiveMain"
			RechargeActiveMain.refreshweekGiftBagTip()
			--弹出奖励框
			local data = VIPBenefitData.getAllWeekGiftBag()
			local data1 = data[tonumber(pId)]
			local achie_reward = ItemUtil.getItemsDataByStr( data1.reward)
		    ReceiveReward.showRewardWindow( achie_reward,nil, 999, -635 )
		    ItemUtil.addRewardByTable(achie_reward)
		end
	end
	VIPBenefitService. buyWeekGift(pId,buyCallback)
end

function getVipBonusInfo( pCallback )
	local callBack = function ( pRecData )
		VIPBenefitData.setWeekGiftBag(pRecData.week_gift)
		if(pCallback)then
			pCallback()
		end		
	end
	VIPBenefitService.getVipBonusInfo(callBack)
end