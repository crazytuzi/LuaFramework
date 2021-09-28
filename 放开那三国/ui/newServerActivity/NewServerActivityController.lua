-- FileName: NewServeActivityController.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-4
-- Purpose: 新服活动控制层

module("NewServerActivityController",package.seeall)
require "script/ui/newServerActivity/NewServerActivityService"
require "script/ui/newServerActivity/NewServerActivityData"
require "script/ui/newServerActivity/NewServerDef"
function getInfo(fight, callbackFunc )
	local callback = function ( pData )
		NewServerActivityData.setInfo(pData)
		if callbackFunc then
            callbackFunc()
        end
	end
	NewServerActivityService.getInfo(fight,callback)
end
--领取完成的任务奖励
function obtainReward(taskId,callbackFunc)
	local callback = function ( ... )
		if(callbackFunc)then
			callbackFunc()
		end
		local data = NewServerActivityData.getDBInfoByTaskId(taskId)
		local achie_reward = ItemUtil.getItemsDataByStr( data.reward)
	    ReceiveReward.showRewardWindow( achie_reward,nil, 999, -510 )
	    ItemUtil.addRewardByTable(achie_reward)
	end
	NewServerActivityService.obtainReward(taskId,callback)
end
--购买商品
function buy(day,callbackFunc)

	local callback = function ( pData )
		if(pData.ret == "ok")then
			if(callbackFunc)then
				callbackFunc()
			end
		else
			print("购买失败!!!")
		end
	end
	NewServerActivityService.buy(day,callback)
end