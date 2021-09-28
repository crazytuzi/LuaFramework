--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-8
-- 版  本:	1.0
-- 描  述:	节日累计充值活动
-- 应  用:  
---------------------------------------------------------------------------------------

Act_TotalCharge_JR = class("Act_TotalCharge_JR",Act_Template)
Act_TotalCharge_JR.__index = Act_Template

Act_TotalCharge_JR.szImage_ChargeStatus = "Image_ChargeStatus"
Act_TotalCharge_JR.szImage_RewardStatus = "Image_RewardStatus"

--初始化
function Act_TotalCharge_JR:init(panel, tbItemList)
	if not panel then
		return 
	end
    self.super.init(self, panel, tbItemList)
    self.mTotalChargeTtf = tolua.cast(panel:getChildByName("Label_CurrentNum"), "Label")
    --设置累计充值元宝数
    self:setTotalCharge(g_Hero:getTotalChargeYuanBaoJR())
end

function Act_TotalCharge_JR:updateStatus()
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
    --更新累计充值元宝数
    self:setTotalCharge(g_Hero:getTotalChargeYuanBaoJR())
end

function Act_TotalCharge_JR:setTotalCharge(yuanbao)
    local strTip = string.format(_T("您已累计充值%d元宝"), yuanbao)
    self.mTotalChargeTtf:setText(strTip)
end

function Act_TotalCharge_JR:onClickGainReward(pSender, eventType)
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

function Act_TotalCharge_JR:setButtonState(buttonItem, state)
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
	end
end
