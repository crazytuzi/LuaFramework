--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	张齐
-- 日  期:	2016-3-23
-- 版  本:	2.0.19
-- 描  述:  豪华签到活动
-- 应  用:  
---------------------------------------------------------------------------------------

Act_DailyChargeValue = class("Act_DailyChargeValue",Act_Template)
Act_DailyChargeValue.__index = Act_Template
Act_DailyChargeValue.szImage_ChargeStatus = "Image_ChargeStatus"

function Act_DailyChargeValue:updateStatus()
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

function Act_DailyChargeValue:onClickGainReward(pSender, eventType)
    if eventType == ccs.TouchEventType.ended then
		if (not pSender) or (not pSender:isExsit()) then return end
		--pSender:setTouchEnabled(false)
		g_WndMgr:showWnd("Game_ReCharge")     --进入商店
	end
end

function Act_DailyChargeValue:setButtonState(buttonItem, state)
	local button_GetReward = tolua.cast(buttonItem:getChildByName("Button_GetReward"), "Button")
	local image_RewardStatus = tolua.cast(button_GetReward:getChildByName("Image_RewardStatus"), "ImageView")

    buttonItem:loadTextureNormal(getActivityTaskImg("ListItem_Task"))
	buttonItem:loadTexturePressed(getActivityTaskImg("ListItem_Task_Press"))
	buttonItem:loadTextureDisabled(getActivityTaskImg("ListItem_Task_Disabled"))
	if ActState.INVALID == state or ActState.FINISHED == state then --已领取 或 可领取
		buttonItem:setTouchEnabled(false)
		buttonItem:setBright(false)
		button_GetReward:setTouchEnabled(false)
		button_GetReward:setBright(false)
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."2"))
	elseif ActState.DOING == state then --未领取
		buttonItem:setTouchEnabled(true)
		buttonItem:setBright(true)
		button_GetReward:setTouchEnabled(true)
		button_GetReward:setBright(true)
		button_GetReward:setVisible(true)
		image_RewardStatus:loadTexture(getActivityCenterImg(self.szImage_RewardStatus.."1"))
	end
end
