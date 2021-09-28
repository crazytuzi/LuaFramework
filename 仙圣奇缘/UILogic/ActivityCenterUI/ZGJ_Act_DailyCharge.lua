
--7天每日单笔充值返利
Act_DailyCharge = class("Act_DailyCharge",Act_Template)
Act_DailyCharge.__index = Act_Template
Act_DailyCharge.szImage_RewardStatus = "Image_ChargeStatus"

function Act_DailyCharge:sortAndUpdateBySortRank()
    
	table.sort(self.tbItemList, function (a, b)
		if not self.tbMissions then
			return false
		end
		local state_a = self.tbMissions[a.ID] or ActState.INVALID 
		local state_b = self.tbMissions[b.ID] or ActState.INVALID 
		if state_a == state_b then
			return a.SortRank < b.SortRank
		else
            --任务完成状态排序
            if state_a == ActState.INACTIVATED then
                return  state_a - 2.5 > state_b
            elseif state_b == ActState.INACTIVATED then
                return  state_a > state_b - 2.5
            else
                return state_a > state_b
            end
		end
	end)
	--防止报错
	if self.listView_BtnItem:isExsit() then
        local nItemsCount = GetTableLen(self.tbItemList)
		self.listView_BtnItem:updateItems(nItemsCount)
	end
end

--领取响应回调
function Act_DailyCharge:gainRewardResponseCB()
	self:sortAndUpdateBySortRank()
	-- self.listView_BtnItem:updateItems(#self.tbItemList)
	-- if self.curButton then
	-- 	self.curButton:setVisible(false)
	-- 	self.curButton:setTouchEnabled(false)
	-- 	local buttonItem = self.curButton:getParent()
	-- 	buttonItem:setBright(false)
	-- 	local Image_RewardStatusYiLing = tolua.cast(buttonItem:getChildByName("Image_RewardStatusYiLing"), "ImageView")
	-- 	Image_RewardStatusYiLing:setVisible(true)
	-- end
end

function Act_DailyCharge:updateStatus()
    self:sortAndUpdateBySortRank()
end

function Act_DailyCharge:onClickGainReward(pSender, eventType)
    if eventType == ccs.TouchEventType.ended then
		if (not pSender) or (not pSender:isExsit()) then return end
		--pSender:setTouchEnabled(false)
		g_WndMgr:showWnd("Game_ReCharge")     --进入商店
	end
end

function Act_DailyCharge:setButtonState(buttonItem, state)
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
g_taiwanGoogleIosPay = {
    [301] = 1,
    [302] = 2,
    [303] = 3,
    [304] = 4,
    [305] = 5,
}

g_taiwanTaiYouPay = {
    [302] = 1,
    [310] = 2,
    [311] = 3,
    [312] = 4,
    [313] = 5,
    [314] = 6,
    [315] = 7,
    [316] = 8,
    [317] = 9,
    [318] = 10,
    [319] = 11,
    [320] = 12,
    [321] = 13,
    [322] = 14,
    [323] = 15,
}

--初始化
function Act_DailyCharge:init(panel, tbItemList)
	if not panel then
		return 
	end
    self.tbItemList = {}
    for i,v in pairs(tbItemList) do
        if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_TAIWAN_ANDROID
        or g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_TAIWAN_IOS then
            if g_taiwanGoogleIosPay[v["ID"]] then
               self.tbItemList[g_taiwanGoogleIosPay[v["ID"]]] = v 
            end        
        elseif g_GamePlatformSystem:GetServerPlatformType() == LOGIN_PLATFORM_TAIWANTAIYOU_ANDROID then
            if g_taiwanTaiYouPay[v["ID"]] then
               self.tbItemList[g_taiwanTaiYouPay[v["ID"]]] = v 
            end   
        else
            self.tbItemList[v["SortRank"]] = v
        end
    end
	self.listView_BtnItem = tolua.cast(panel:getChildByName("ListView_Activety"), "ListViewEx")
	local item = self.listView_BtnItem:getChildByName("Panel_Activety")
	local function updateFunc(widget,index)
		return self:setPanelItem(widget, index)
	end
	registerListViewEvent(self.listView_BtnItem, item, updateFunc)
	self:sortAndUpdateBySortRank()
	
	local imgScrollSlider = self.listView_BtnItem:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_Activety_X then
		g_tbScrollSliderXY.ListView_Activety_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Activety_X - 3)
    g_act:resetBubbleById(self.nActivetyID) --重置可领取奖励个数
end

--override
-- function Act_DailyCharge:onClickGainReward(widget, nTag)
--     local state = self.tbMissions[self.tbItemList[nTag]["ID"]]
--     if ActState.INVALID == state then --已领取
--         g_ClientMsgTips:showMsgConfirm(_T("您已充值该档次，对应奖励已发送到您的邮箱请及时领取。"))
--     else
--         g_WndMgr:showWnd("Game_ReCharge")
--     end
-- end

--override
-- function Act_DailyCharge:setButtonState(Button_Activety, nIndex)
--     self.super.setButtonState(self, Button_Activety, nIndex)
--     local Image_Charge = Button_Activety:getChildByName("Image_Charge")
--     local Label_NeedValue = tolua.cast(Image_Charge:getChildByName("Label_NeedValue"), "Label")
--     local Label_RefreshTime = tolua.cast(Button_Activety:getChildByName("Label_RefreshTime"), "Label")
--     local Label_ChargeStatus = tolua.cast(Button_Activety:getChildByName("Label_ChargeStatus"), "Label")

--     local Label_NewPriceLB = tolua.cast(Image_Charge:getChildByName("Label_NewPriceLB"), "Label")
--     local CCNode_NewPriceLB = tolua.cast(Label_NewPriceLB:getVirtualRenderer(), "CCLabelTTF")

--     CCNode_NewPriceLB:disableShadow(true)
--     if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
--         Label_ChargeStatus:setFontSize(16)
--         local Image_YuanBao2 = Image_Charge:getChildByName("Image_YuanBao2")
--         Label_NewPriceLB:setFontSize(16)
--         g_AdjustWidgetsPosition({Label_NewPriceLB, Image_YuanBao2},1)
--     end
--     Label_NeedValue:setText(self.tbItemList[nIndex]["NeedValue"])

--     local CCNode_NeedValue = tolua.cast(Label_NeedValue:getVirtualRenderer(), "CCLabelTTF")
--     CCNode_NeedValue:disableShadow(true)
    
    
    
--     local function onShowRewardTip(pSender, nIndex)
--         local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("DropSubPackClient", self.tbItemList[nIndex]["DropClientID"], 1)
--         g_ShowDropItemTip(CSV_DropSubPackClient)
--     end
    
--     local function onCloseTip()
--     end
    
--     self.tbButtonEnable[nIndex] = true
--     local state = self.tbMissions[self.tbItemList[nIndex]["ID"]]
--     if ActState.INVALID == state then --已充值
--         Label_ChargeStatus:setText(_T("已充值"))
--         Image_Charge:setVisible(false)
--         Label_RefreshTime:setVisible(true)
--         self.tbLabelTime[nIndex] = Label_RefreshTime
        
--         local function onShowSysTip(pSender, nTag)
--             g_ShowSysTips({text=_T("您已充值该档次，对应奖励已发送到您的邮箱请及时领取。")})
--         end
--         g_SetBtnWithPressingEventAndImage(Button_Activety, nIndex, onShowRewardTip, onShowSysTip, onCloseTip, true, 0.5)
--     else
--         Label_ChargeStatus:setText(_T("未充值"))
--         Image_Charge:setVisible(true)
--         Label_RefreshTime:setVisible(false)
--         self.tbLabelTime[nIndex] = nil
        
--         local function onShowChargeWnd(pSender, nTag)
--             g_WndMgr:showWnd("Game_ReCharge")
--         end
--         g_SetBtnWithPressingEventAndImage(Button_Activety, nIndex, onShowRewardTip, onShowChargeWnd, onCloseTip, true, 0.5)
--     end
    
--     local CCNode_RefreshTime = tolua.cast(Label_RefreshTime:getVirtualRenderer(), "CCLabelTTF")
--     CCNode_RefreshTime:disableShadow(true)

--     --刷新各label时间
--     for k, v in pairs(self.tbLabelTime) do
--         if not self.tbTimerID[k] then
--             self:setCoolTime()
--             self.tbTimerID[k] = g_Timer:pushLoopTimer(1, handler(self, self.setCoolTime))
--         end
--     end
-- end

-- --override
-- function Act_DailyCharge:init(panel, tbItemList)
--     self.tbLabelTime = {}
--     self.tbTimerID = {}
--     self.super.init(self, panel, tbItemList)
-- end

-- function Act_DailyCharge:setCoolTime()
--     local nTime = 24 * 60 * 60 - g_GetServerHour() * 60 * 60- g_GetServerMin() * 60 - g_GetServerSecs()
--     if 24 * 60 * 60 == nTime then
--         for k,v in pairs(self.tbTimerID) do
--             g_Timer:destroyTimerByID(v)
--         end
--         self.super.sortAndUpdate(self)
--         return
--     end
--     local szTime = TimeTableToStr(SecondsToTable(nTime),":")
--     for k, v in pairs(self.tbLabelTime) do
--         if v:isExsit() then
--             v:setText(szTime.._T("后重置"))
--         end
--     end 
-- end

-- --override
-- function Act_DailyCharge:destroy()
--     if not self.tbTimerID then
--         return
--     end
--     for k,v in pairs(self.tbTimerID) do
--         g_Timer:destroyTimerByID(v)
--     end
-- end
