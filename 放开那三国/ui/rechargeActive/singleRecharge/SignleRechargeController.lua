-- FileName: SignleRechargeController.lua 
-- Author: fuqiongqiong
-- Date: 2016-3-8
-- Purpose: 单充回馈控制层

module ("SignleRechargeController",package.seeall)
require "script/ui/rechargeActive/singleRecharge/SignleRechargeService"
require "script/ui/rechargeActive/ActiveCache"
require "script/ui/item/ReceiveReward"
--获取已经领取的次数
function getInfo( pCallback )
	local requestCallback = function ( pRecData )
		SignleRechargeData.setHasInfo(pRecData.hadReward)
		SignleRechargeData.gettoReward(pRecData.toReward)
		if(pCallback)then
			pCallback()
		end
	end
	SignleRechargeService.getInfo(requestCallback)
end

--领取奖励
function gainReward( rewardId, rewardIndex, pCallback )
	--判断背包满
    require "script/ui/item/ItemUtil"
    if(ItemUtil.isBagFull() == true )then
        return
    end
	local requestCallback = function ( pRecData )
		if(pRecData == "ok")then
			local pGoodInfo =SignleRechargeData.getRewardInfoById(rewardId)
			SignleRechargeLayer.refreshRedTip()

			--当N选1时，取出被选择的奖励
			local sReward = pGoodInfo.payReward
			print("gainReward sReward before: ", sReward)
			if sReward ~= nil and sReward ~= "" and rewardIndex > 0 then   
				local tbReward = lua_string_split(sReward, ",")
				sReward = tbReward[rewardIndex]
			end
			print("gainReward sReward after: ", sReward)

			--弹出奖励提示面板
			SignleRechargeLayer.createTableView()
	        local achie_reward = ItemUtil.getItemsDataByStr( sReward )
		    ReceiveReward.showRewardWindow( achie_reward,nil, 999, -510 )
		    ItemUtil.addRewardByTable(achie_reward)
	    else
    		print("gainReward error!")
		end
	end
	SignleRechargeService.gainReward(rewardId, rewardIndex, requestCallback)
end