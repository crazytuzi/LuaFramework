-- FileName: HolidayHappyController.lua 
-- Author: fuqiongqiong
-- Date: 2016-5-27
-- Purpose: 节日狂欢控制器

module("HolidayHappyController",package.seeall)
require "script/ui/holidayhappy/HolidayHappyService"
require "script/ui/holidayhappy/HolidayHappyData"
require "script/ui/holidayhappy/HolidayHappyDef"
-- require "script/ui/holidayhappy/HolidayHappyLimitExchargeLayer"
function getInfo(callbackFunc)
	local callback = function ( pData )
		HolidayHappyData.SetDataOfAll(pData)
		if callbackFunc then
            callbackFunc()
        end
	end
	HolidayHappyService.getInfo(callback)
end

--完成任务领取奖励
function taskReward(id,callbackFunc)
	local callback = function ( ... )
		if callbackFunc then
            callbackFunc()
        end
        --判断任务类型 是1还是4
        local bigType = tonumber(HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(id)).bigtype)
        local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
        if(bigType == HolidayHappyDef.kTypeOfTaskOne)then
        	--任务类型1
        	--修改缓存数据
            HolidayHappyData.setredTipArray(tonumber(id),2)
            -- HolidayHappyData.changeRedTip(tonumber(id))
        elseif bigType == HolidayHappyDef.kTypeOfTaskFour then
        	--任务类型4
        	--可以领取奖励次数-1
        	HolidayHappyData.setCanReceiveTimes(id,seasonNumOfClick)
        	local remainTimes,canReceiveTimes,allTimes = HolidayHappyData.remainTimesOfRecharge(bigType,tonumber(id),seasonNumOfClick)
        	if(canReceiveTimes == 0)then
        		--修改红点信息
        		HolidayHappyData.setredtipOfSingleRecharge(id)
                if(remainTimes > 0)then
                    --按钮变为前往
                    HolidayHappyData.setredTipArray(tonumber(id),0)
                else
                    --按钮为已领取
                    HolidayHappyData.setredTipArray(tonumber(id),2)
                end
        	end
        end
       
        --刷新标签红点
        local numTag = HolidayHappyLayer.getbiaoqianNum()
        HolidayHappyLayer.refreshRedTipOfLable(numTag)
        --弹出奖励匡
        local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(id))
        local reward
        if(tonumber(data.bigtype) == HolidayHappyDef.kTypeOfTaskOne)then
        	reward = data.reward
        elseif tonumber(data.bigtype) == HolidayHappyDef.kTypeOfTaskFour then
        	reward = data.sihgleReward
        end
		local achie_reward = ItemUtil.getItemsDataByStr(reward)
	    
        -- local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
        -- if(tonumber(data.bigtype) == HolidayHappyDef.kTypeOfTaskOne)then
        --     --修改缓存数据
        --     HolidayHappyData.setDataOfAfterReceive(id,seasonNumOfClick)
        -- end
        
        local refreshCallBack = function ( ... )
            --刷新界面
            HolidayHappyLayer.createtableView(true)
        end
        ReceiveReward.showRewardWindow( achie_reward,refreshCallBack, 999, -640 )
        ItemUtil.addRewardByTable(achie_reward)
	end
	HolidayHappyService.taskReward(id,callback)
end

--充值后领取奖励
function chargeReward(id,callbackFunc)
	local callback = function ( ... )
		if callbackFunc then
            callbackFunc()
        end
	end
	HolidayHappyService.chargeReward(id,callback)
end

--购买商品
function buy(id,num,callbackFunc)
	local callback = function ( ... )
		if callbackFunc then
            callbackFunc()
        end
        --刷新次数
        -- HolidayHappyCell.refreshNumOfBuy(num)
        local refreshCallBack = function ( ... )
            --刷新界面
            HolidayHappyLayer.createtableView()
        end
        local reward = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(id)).discount
        local achie_reward = ItemUtil.getItemsDataByStr(reward)
        achie_reward[1].num = (achie_reward[1].num)*num
         print_t(achie_reward)
        ReceiveReward.showRewardWindow( achie_reward,refreshCallBack, 999, -640 )
        ItemUtil.addRewardByTable(achie_reward)
	end
	HolidayHappyService.buy(id,num,callback)
end

-- 兑换商品
function exchange(id,num,callbackFunc)
	local callback = function ( ... )
		if callbackFunc then
            callbackFunc()
        end
        HolidayHappyData.addExchangeNum(id,num)
        local dataArray = HolidayHappyData.getDataOfNeed()


        for k,v in pairs(dataArray) do
            if(tonumber(v.id) == tonumber(id))then
                local need = string.split(v.need,",")
                for i=1,#need do
                    local needSubItem = ItemUtil.getItemsDataByStr(need[i])
                     ItemUtil.subRewardByTable(needSubItem)
                end
            end
           
        end
        HolidayHappyLimitExchargeLayer.createLayer(true)
        if(HolidayHappyData.isRedTipOfExchange2())then
            if( not HolidayHappyData.isRedTipOfExchange())then
                --在兑换次数未用完，材料用完的情况下
                 HolidayHappyLayer.refreshRedTipOfExcharge()
            end
        else
            --兑换次数用完的情况下
            HolidayHappyLayer.refreshRedTipOfExcharge()
       end
	end

    local delayAction = function ( ... )
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        performWithDelay(runningScene,callback,0.1)
    end
	HolidayHappyService.exchange(id,num,delayAction)
end

--补签
function signReward(id,callbackFunc)
	local callback = function ( ... )
		if callbackFunc then
            callbackFunc()
        end
        --扣金币
        UserModel.addGoldNumber(-20)
        -- local seasonNumOfClick = HolidayHappyLayer.getSeasonNumOfClick()
        --修改缓存
        HolidayHappyData.setredTipArray(tonumber(id),2)
        --刷新界面
        local refreshCallBack = function ( ... )
            --刷新界面
            HolidayHappyLayer.createtableView()
        end
        --弹出奖励匡
        local data = HolidayHappyData.getDataOfFestival_rewardByTaskId(tonumber(id))
        local achie_reward = ItemUtil.getItemsDataByStr(data.reward)
        ReceiveReward.showRewardWindow( achie_reward,refreshCallBack, 3100, -640 )
        ItemUtil.addRewardByTable(achie_reward)
	end
	HolidayHappyService.signReward(id,callback)
end