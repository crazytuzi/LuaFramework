--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	2016-3-23
-- 版  本:	2.0.19
-- 描  述:	节日期间连续7天每天充值领奖"
-- 应  用:  
---------------------------------------------------------------------------------------

Act_EveryDayChargeJR = class("Act_EveryDayChargeJR",Act_Template)
Act_EveryDayChargeJR.__index = Act_Template
Act_EveryDayChargeJR.szImage_ChargeStatus = "Image_ChargeStatus"
Act_EveryDayChargeJR.szImage_RewardStatus = "Image_RewardStatus"


function Act_EveryDayChargeJR:updateStatus()
    if not self.tbMissions then
        --活动不存在或者活动已经结束
		return false
	end
    local rank_again = false
    --判断当前任务的状态是否已经更新
    for i,v in pairs(self.tbMissions) do
        if self.tbMissions_old[i] ~= v then
            rank_again = true
            self.tbMissions_old[i] = v
        end
    end
    
    if rank_again then --任务状态已经更新，更新listView
        self:sortAndUpdate()
    end
end

function Act_EveryDayChargeJR:onClickGainReward(pSender, eventType)
    if eventType == ccs.TouchEventType.ended then
		if (not pSender) or (not pSender:isExsit()) then return end
		if self.tbMissions[self.tbItemList[pSender:getTag()].ID] == ActState.FINISHED then
		    pSender:setTouchEnabled(false)
		    g_act:rewardRequest(self.nActivetyID, self.tbItemList[pSender:getTag()].ID)
		    g_act:setRewardResponseCB(handler(self,self.gainRewardResponseCB))
		else
            g_WndMgr:showWnd("Game_ReCharge")     --进入商店
        end
	end
end

function Act_EveryDayChargeJR:setButtonState(buttonItem, state)
	local button_GetReward = tolua.cast(buttonItem:getChildByName("Button_GetReward"), "Button")
	local image_RewardStatus = tolua.cast(button_GetReward:getChildByName("Image_RewardStatus"), "ImageView")
    local Image_RewardStatusYiLing = tolua.cast(buttonItem:getChildByName("Image_RewardStatusYiLing"), "ImageView")

    buttonItem:loadTextureNormal(getActivityTaskImg("ListItem_Task"))
	buttonItem:loadTexturePressed(getActivityTaskImg("ListItem_Task_Press"))
	buttonItem:loadTextureDisabled(getActivityTaskImg("ListItem_Task_Disabled"))
    buttonItem:setTouchEnabled(false)
	buttonItem:setBright(false)
	button_GetReward:setTouchEnabled(false)
	button_GetReward:setBright(false)
	button_GetReward:setVisible(false)
    Image_RewardStatusYiLing:setVisible(false)
	if ActState.INVALID == state then --已领取
        Image_RewardStatusYiLing:setVisible(true)
	elseif ActState.DOING == state then --正在进行
		buttonItem:setTouchEnabled(true)
		buttonItem:setBright(true)
		button_GetReward:setTouchEnabled(true)
		button_GetReward:setBright(true)
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_ChargeStatus.."1"))
    elseif ActState.FINISHED == state then --可领取
		buttonItem:setTouchEnabled(true)
		buttonItem:setBright(true)
		button_GetReward:setTouchEnabled(true)
		button_GetReward:setBright(true)
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."2"))
    elseif ActState.INACTIVATED == state then --当前不可完成
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."1"))
	end
end