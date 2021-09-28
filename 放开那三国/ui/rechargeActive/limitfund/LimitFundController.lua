-- FileName: LimitFundController.lua 
-- Author: fuqiongqiong
-- Date: 2016-9-13
-- Purpose: 限时基金控制器

module("LimitFundController",package.seeall)
require "script/ui/rechargeActive/limitfund/LimitFundService"
require "script/ui/rechargeActive/limitfund/LimitFundData"
require "script/ui/tip/AnimationTip"
function getInfo(callbackFunc)
	local callback = function ( pData )
		LimitFundData.setDataInfo(pData)
		if callbackFunc then
            callbackFunc()
        end
	end
 	LimitFundService.getInfo(callback)
end
	
	
function buy(id,num,callbackFunc)
	local callback = function (pData)
    if(pData ~= "ok")then
        AnimationTip.showTip(GetLocalizeStringBy("fqq_168"))
        return
    end
		if callbackFunc then
            callbackFunc()
        end
        --改变预期收入
        LimitFundData.addExpectMoney(LimitFundData.getGoldOfReturn(id)*num)
        --刷新界面
        LimitFundLayer.createTopUIOfBuyTime()
	end
 	LimitFundService.buy(id, num,callback)	
end
	
	
function gain(index,callbackFunc)
 	local callback = function ()
		if callbackFunc then
            callbackFunc()
        end	
        --领取后修改按钮状态
        LimitFundData.changeGainNum(index)
        --刷新小红点提示
        require "script/ui/rechargeActive/RechargeActiveMain"
        RechargeActiveMain.refreshLimitFundTip()
        --刷新界面
        LimitFundLayer.updataTableView()
       
        local returnNum = 0
        local typeNumTable = LimitFundData.getTypeOfNumTable()
        for k,v in pairs(typeNumTable) do
            local dataTable = LimitFundData.getDataOfWay(tonumber(v.type))
            local dataTable2 = dataTable[index]
            local allreadyNum = LimitFundData.getAllreadyNum(tonumber(v.type))
            returnNum = returnNum + dataTable2[4]*allreadyNum
        end
 
        local rewardData1= "3|0|"..returnNum
        local achie_reward = ItemUtil.getItemsDataByStr(rewardData1)
        local allreadyByNum = LimitFundData.getAllreadyNum(id)
        ReceiveReward.showRewardWindow( achie_reward,nil, 3100, -640 )
        ItemUtil.addRewardByTable(achie_reward)
	end
 	LimitFundService.gain(index,callback)	
end