-- FileName: PlayerBackController.lua 
-- Author: fuqiongqiong
-- Date: 2016-8-19
-- Purpose: 老玩家回归活动控制器

module("PlayerBackController",package.seeall)
require "script/ui/playerBack/PlayerBackService"
require "script/ui/playerBack/PlayerBackData"

function getOpen(callbackFunc )
	local callback = function ( pData )
		PlayerBackData.setOpen(pData)
		if callbackFunc then
            callbackFunc()
        end
	end
	PlayerBackService.getOpen(callback)
end

function getInfo(callbackFunc)
	local callback = function ( pData )
		PlayerBackData.setActivityInfo(pData)
		if callbackFunc then
            callbackFunc()
        end
	end
	PlayerBackService.getInfo(callback)
end

function buy(id,num,callbackFunc)
	local callback = function ( ... )
		if(callbackFunc)then
			callbackFunc()
		end
		--刷新界面
		PlayerBackLayer.createTableView(true)
	end
	PlayerBackService.buy(id,num,callback)
end

function gainReward(id,pSelect,callbackFunc)
	local callback = function ( ... )
		if(callbackFunc)then
			callbackFunc()
		end
		-- local num = PlayerBackLayer.getbiaoqianNum()
		local data = PlayerBackData.getRewardInfo(id)
		--改变按钮状态
		PlayerBackData.setButtonStatues(id)
		 --刷新界面
        local refreshCallBack = function ( ... )
        	if(tonumber(data.type) == PlayerBackDef.kTypeOfTaskOne)then
        		PlayerBackLayer.createUIOfGiftBack()
        	else
        		 --刷新界面
            	PlayerBackLayer.createTableView(true)	
        	end  
        end
       	--刷新标签红点
        PlayerBackLayer.refreshRedTipOfLable(tonumber(data.type))
        strReward = data.reward
	    if tonumber(data.type) == PlayerBackDef.kTypeOfTaskFour then
	        strReward = data.discountitem 
	    end
	    local rewardData1 = strReward
	    if(data.choice_award == 1)then
	    	--多选一
	    	local rewardData2 = string.split(strReward,",")
	    	rewardData1 = rewardData2[pSelect]
	    end
    	--弹出奖励匡
        local achie_reward = ItemUtil.getItemsDataByStr(rewardData1)
        if (tonumber(data.type) == PlayerBackDef.kTypeOfTaskOne) then
        	local day = PlayerBackData.getDayOfLeaf()
        	local level = UserModel.getHeroLevel()
        	for i=1,#achie_reward do
        		achie_reward[i].num = (achie_reward[i].num)*day	
        	end
     	end
        ReceiveReward.showRewardWindow( achie_reward,refreshCallBack, 3100, -640 )
        ItemUtil.addRewardByTable(achie_reward)	
	end
 	PlayerBackService.gainReward(id,pSelect,callback)	
 end