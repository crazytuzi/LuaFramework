--------------------------------------------------------------------------------------
-- 文件名:	Game_Turntable.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述:	转盘奖励
-- 应  用:  
---------------------------------------------------------------------------------------

Game_Turntable = class("Game_Turntable")
Game_Turntable.__index = Game_Turntable

function Game_Turntable:initWnd()
	
	g_FormMsgSystem:RegisterFormMsg(FormMsg_Turn_Info, handler(self, self.update))

end

function Game_Turntable:closeWnd()
	self.nNum = nil
	if self.nColdTiematId  then 
		g_Timer:destroyTimerByID(self.nColdTiematId)
		self.nColdTiematId = nil
	end
	if self.nTimerId then
		g_Timer:destroyTimerByID(self.nTimerId)
		self.nTimerId = nil
	end	
	self.nDropType	= nil
	self.info = nil
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_Turn_Info)
	self.callFunc = nil
end


function Game_Turntable:openWnd(param)
	
	if not self.rootWidget then return end
	local ButtonContentPNL = self:getButtonContentPNL()
	if not ButtonContentPNL then return end 
	self.callFunc = nil
	local param = {
		endedFunc = function()
			self.layout_:setTouchEnabled(true)
			local love = g_Hero:getFriendPoints()
			if love <= 0 then 
				g_ClientMsgTips:showMsgConfirm(_T("您的友情之心不够了哦亲, 快找小伙伴赠送一些吧~"))
				return 
			end
			local types = VipType.VipBuyOpType_TurnTableTimes

			local num = g_VIPBase:getAddTableByNum(types)
			local cntNum = g_VIPBase:getVipLevelCntNum(types)
			
			local nType = macro_pb.TurntableTimes
			local count = g_Hero:getDailyNoticeLimitByType(nType)
			local useCount = g_Hero:getDailyNoticeByType(nType)
			if useCount >= (count + cntNum) then 
				g_ClientMsgTips:showMsgConfirm(_T("抽奖次数已经用完"))
				return 
			end
			--预加载窗口缓存防止卡顿
			g_WndMgr:getFormtbRootWidget("Game_RewardMsgConfirm")
			g_TurnTableInfoData:requestTurnTableStartResponse()
		end,
	}
	self:initLayout(param)
	
	local Button_ZhuanPanGuide = tolua.cast(self.rootWidget:getChildByName("Button_ZhuanPanGuide"), "Button")
	g_RegisterGuideTipButton(Button_ZhuanPanGuide, nil)
	

	--获取品质 把转盘上的指针停靠在亮起的物品上
	local nIndex = g_TurnTableInfoData:getCurCfgIdx()
	local Button_Item = tolua.cast(ButtonContentPNL:getChildByName("Button_Item"..nIndex),"Button")
	local param = {
		normal = getTurntableImg("Mask_Check"),
	}
	g_setBtnLoadTexture(Button_Item,param)

	local rotate = 45 * nIndex

	local Image_PointArrow = tolua.cast(ButtonContentPNL:getChildByName("Image_PointArrow"),"ImageView")
	Image_PointArrow:setRotation(rotate-45)

	--抽奖次数
	local nType = macro_pb.TurntableTimes
	local useCount = g_Hero:getDailyNoticeByType(nType)
	local count = g_Hero:getDailyNoticeLimitByType(nType)
	
	local types = VipType.VipBuyOpType_TurnTableTimes
	local cntNum = g_VIPBase:getVipLevelCntNum(types)
	
	self.nNum = (count+cntNum) - useCount
	--开始按钮的亮起
	if self.nNum ~= 0 then  self:startButton(true) end
		
	local friendHeartNum = g_DataMgr:getGlobalCfgCsv("turn_cost_friend_heart_num")
	self:loveHeart(friendHeartNum)

	
	for i = 1,8 do
		local Button_Item = tolua.cast(ButtonContentPNL:getChildByName("Button_Item"..i),"Button")
		local param = {
			normal = getTurntableImg("Mask"),
			pressed = getTurntableImg("Mask"),
			disabled = getTurntableImg("Mask_Check")
		}
		g_setBtnLoadTexture(Button_Item,param)
		
		local qualityID = g_TurnTableInfoData:getTurnShowLstByQuality(i)
		local cfgID = g_TurnTableInfoData:getTurnShowLstByCfgId(i)

		local activityTable = g_DataMgr:getCsvConfig_FirstKeyData("ActivityTurnTable", cfgID)
		if activityTable == nil  then return end
		local icon = activityTable["LevelIcon"] --默认取第一个

		local Image_RewardIcon = tolua.cast(Button_Item:getChildByName("Image_RewardIcon"),"ImageView")
		Image_RewardIcon:loadTexture(getIconImg(icon..qualityID))
	end
	
	local types = VipType.VipBuyOpType_TurnTableTimes
	local num = g_VIPBase:getAddTableByNum(types)
	self:lotteryNum( count + num - useCount, count + num)
end

--获取 转盘父节点
function Game_Turntable:getButtonContentPNL()
	local wndInstance = g_WndMgr:getWnd("Game_Turntable")
	if wndInstance and wndInstance.rootWidget then 
		local Image_TurntablePNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_TurntablePNL"),"ImageView")
		local Button_ContentPNL = tolua.cast(Image_TurntablePNL:getChildByName("Button_ContentPNL"),"Button")
		return Button_ContentPNL
	end
	return nil
end

--[[
	屏幕点击事件
	local param = {
		endedFunc = function() end,--离开事件
		beganFunc = function() end,--点击事件
		movedFunc = function() end,--移动事件
	}
]]
function Game_Turntable:initLayout(param)
		
	if not self.rootWidget then return end 
	local ButtonContentPNL = self:getButtonContentPNL()
	if not ButtonContentPNL then return end 
	local Button_Start = tolua.cast(ButtonContentPNL:getChildByName("Button_Start"),"Button")
	Button_Start:setTouchEnabled(true)
	
	local layoutTouch =  Layout:create()
	layoutTouch:setSize(CCSize(1280,720))
	local function onTouch(pSender,eventType)
		if Button_Start and not Button_Start:isTouchEnabled() then return end
		if eventType == ccs.TouchEventType.ended then--离开事件
			if Button_Start then
				if param.endedFunc then  param.endedFunc() end
				Button_Start:setBrightStyle(BRIGHT_NORMAL)
				-- pSender:setTouchEnabled(true)
			end
		elseif eventType == ccs.TouchEventType.began then --点击事件
			if Button_Start and self.nNum ~= 0 then
				Button_Start:setBrightStyle(BRIGHT_HIGHLIGHT)
				pSender:setTouchEnabled(false)
			end
			g_playSoundEffect("Sound/ButtonClick.mp3")
		elseif eventType == ccs.TouchEventType.canceled then
			if Button_Start then
				Button_Start:setBrightStyle(BRIGHT_NORMAL)
				pSender:setTouchEnabled(true)
			end
		end
	end        
	layoutTouch:setTouchEnabled(true)
	layoutTouch:addTouchEventListener(onTouch)
	self.rootWidget:addChild(layoutTouch)
	self.layout_ =  layoutTouch
		
	local Button_Return = tolua.cast(self.rootWidget:getChildByName("Button_Return"),"Button")
	Button_Return:setZOrder(INT_MAX)
end 

--开始按钮的亮起和暗化
function Game_Turntable:startButton(falg)
	local ButtonContentPNL = self:getButtonContentPNL()
	if not ButtonContentPNL then return end 
	
	local Button_Start = tolua.cast(ButtonContentPNL:getChildByName("Button_Start"),"Button")
	Button_Start:setBright(falg)
	-- isBright
end

--保持转盘上只有一个亮起的
function Game_Turntable:singleBright(nIndex)
	local ButtonContentPNL = self:getButtonContentPNL()
	if not ButtonContentPNL then return end 
	for i = 1,8 do
		local Button_Item = tolua.cast(ButtonContentPNL:getChildByName("Button_Item"..i),"Button")
		local param = {
			normal = getTurntableImg("Mask"),
			-- pressed = getTurntableImg("Mask"),
			-- disabled = getTurntableImg("Mask_Check")
		}
		g_setBtnLoadTexture(Button_Item,param)
	end
	local Button_Item = tolua.cast(ButtonContentPNL:getChildByName("Button_Item"..nIndex),"Button")
	local param = {
		normal = getTurntableImg("Mask_Check"),
		-- pressed = getTurntableImg("Mask"),
		-- disabled = getTurntableImg("Mask_Check")
	}
	g_setBtnLoadTexture(Button_Item,param)
end

--可用爱心数量
function Game_Turntable:loveHeart(numLove)
	if not self.rootWidget then return end
	numLove = numLove or 0
	if numLove < 0 then numLove = 0 end 
	local Label_NeedFriendPointLB = tolua.cast(self.rootWidget:getChildByName("Label_NeedFriendPointLB"),"Label")
	local Label_NeedFriendPoint = tolua.cast(Label_NeedFriendPointLB:getChildByName("Label_NeedFriendPoint"),"Label")
	if love == 0 then
		self:startButton(false)
		g_setTextColor(Label_NeedFriendPoint,ccs.COLOR.RED)
	else
		g_setTextColor(Label_NeedFriendPoint,ccs.COLOR.LIME_GREEN)
	end 
	Label_NeedFriendPoint:setText("×"..numLove)
end

--抽奖次数
function Game_Turntable:lotteryNum(nNum, allNum)
	if not self.rootWidget then return end
		
	if nNum < 0 or not nNum then nNum = 0 end

	local Image_LotteryNum = tolua.cast(self.rootWidget:getChildByName("Image_LotteryNum"),"ImageView")
	local Label_LotteryNumLB = tolua.cast(Image_LotteryNum:getChildByName("Label_LotteryNumLB"),"Label")
	local Label_LotteryNum = tolua.cast(Label_LotteryNumLB:getChildByName("Label_LotteryNum"),"Label")
		
	if nNum == 0 then 
		self.nNum = nNum		
		self:startButton(false)
		g_setTextColor(Label_LotteryNum,ccs.COLOR.RED)		
	else
		g_setTextColor(Label_LotteryNum,ccs.COLOR.LIME_GREEN)	
	end
	Label_LotteryNum:setText(nNum)
	local Label_LotteryNumMaxLB = tolua.cast(Label_LotteryNumLB:getChildByName("Label_LotteryNumMaxLB"),"Label")
	Label_LotteryNumMaxLB:setText("/"..allNum)
				
	Label_LotteryNumLB:setPositionX(-(Label_LotteryNumLB:getSize().width+Label_LotteryNum:getSize().width+Label_LotteryNumMaxLB:getSize().width)/2)
	Label_LotteryNum:setPositionX( Label_LotteryNumLB:getSize().width + 2 )
	Label_LotteryNumMaxLB:setPositionX(  Label_LotteryNumLB:getSize().width / 2 + Label_LotteryNum:getSize().width + Label_LotteryNum:getPositionX() /2 )

	local Button_AddTimes = tolua.cast(Image_LotteryNum:getChildByName("Button_AddTimes"),"Button")
	local function onClickAddNum(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then 
			local types = VipType.VipBuyOpType_TurnTableTimes
			local allNumVip = g_VIPBase:getVipLevelCntNum(types)
			local num = g_VIPBase:getAddTableByNum(types)
			
			if num >= allNumVip then 
				g_ShowSysTips({text=_T("您今日爱心转盘的购买次数已用完\n下一VIP等级可以增加购买次数上限")})
				return 
			end
			
			local gold = g_VIPBase:getVipLevelCntGold(types)
			local txt = string.format(_T("购买爱心转盘次数需要花费%d元宝，您的元宝不够是否前往充值？"), gold)
			if not g_CheckYuanBaoConfirm(gold,txt) then
				return
			end	
			
			local str = string.format(_T("是否花费%d元宝购买1次爱心转盘？"), gold)
			g_ClientMsgTips:showConfirm(str, function() 
				local function serverResponseCall(tiems)			
					local nType = macro_pb.TurntableTimes
					--今天已经使用的次数
					local useCount = g_Hero:getDailyNoticeByType(nType)
					--每天的基础数值
					local count = g_Hero:getDailyNoticeLimitByType(nType)
					Label_LotteryNum:setText(count + tiems - useCount)
					g_setTextColor(Label_LotteryNum,ccs.COLOR.LIME_GREEN)		
					Label_LotteryNumMaxLB:setText("/"..(count+tiems))
					
					self:startButton(true)
		
					Label_LotteryNum:setPositionX( Label_LotteryNumLB:getSize().width + 2 )
					Label_LotteryNumMaxLB:setPositionX(  Label_LotteryNumLB:getSize().width / 2 + Label_LotteryNum:getSize().width + Label_LotteryNum:getPositionX() /2 )
					pSender:setPositionX( Label_LotteryNumLB:getSize().width / 2 + Label_LotteryNum:getSize().width + Label_LotteryNumMaxLB:getSize().width  + 6)

					g_ShowSysTips({text = string.format(_T("成功购买1次爱心转盘\n您还可购买%d次。"), allNumVip- tiems)})
					
					gTalkingData:onPurchase(TDPurchase_Type.TDP_LOTTERY_NUM, 1, gold)	
			
				end
				g_VIPBase:responseFunc(serverResponseCall)
				g_VIPBase:requestVipBuyTimesRequest(types)
			end)
		end
	end
	Button_AddTimes:setTouchEnabled(true)
	Button_AddTimes:addTouchEventListener(onClickAddNum)
	Button_AddTimes:setZOrder(INT_MAX)
	Button_AddTimes:setPositionX( Label_LotteryNumLB:getSize().width / 2 + Label_LotteryNum:getSize().width + Label_LotteryNumMaxLB:getSize().width  + 6)
	
	-- g_AdjustWidgetsPosition({Label_LotteryNumLB, Label_LotteryNum, Label_LotteryNumMaxLB},10)
	-- self:coldTiemShow()
end

--[[
-- function Game_Turntable:coldTiemShow()
	-- if not self.rootWidget then return end
	
	-- local Image_LotteryNum = tolua.cast(self.rootWidget:getChildByName("Image_LotteryNum"),"ImageView")
	-- local Image_CoolTime = tolua.cast(Image_LotteryNum:getChildByName("Image_CoolTime"),"ImageView")
	-- local Label_CoolTime = tolua.cast(Image_CoolTime:getChildByName("Label_CoolTime"),"Label")
		
	-- local coldTiemat = g_TurnTableInfoData:getTurnShowColdTiemat()	
	-- local ButtonContentPNL = self:getButtonContentPNL()
	-- if not ButtonContentPNL then return end 
		
	-- local Button_Start = tolua.cast(ButtonContentPNL:getChildByName("Button_Start"),"Button")
	
	-- local function loopTiemFunc()
		-- if not g_WndMgr:getWnd("Game_Turntable") then return true end
		-- local ndif = coldTiemat - g_GetServerTime()  
		-- if coldTiemat < g_GetServerTime() then 
			-- Image_CoolTime:setVisible(false)
			-- if self.nColdTiematId then
				-- g_Timer:destroyTimerByID(self.nColdTiematId)
				-- self.nColdTiematId = nil
				
				-- self:startButton(true)
				-- self.layout_:setTouchEnabled(true)
				-- Button_Start:setTouchEnabled(true)
			-- end
		-- else
			-- Image_CoolTime:setVisible(true)
			-- local cooldown = SecondsToTable(ndif)
			-- Label_CoolTime:setText(TimeTableToStr(cooldown,":",true))
		-- end
	-- end
	
	-- if coldTiemat > g_GetServerTime() then
		-- local ndif = coldTiemat - g_GetServerTime()  
		-- local cooldown = SecondsToTable(ndif)
		-- Label_CoolTime:setText(TimeTableToStr(cooldown,":",true))
		-- if self.nColdTiematId then
			-- g_Timer:destroyTimerByID(self.nColdTiematId)
			-- self.nColdTiematId = nil
		-- end
		-- self.nColdTiematId = g_Timer:pushLoopTimer(1,function() loopTiemFunc() end)
		
		-- self:startButton(false)
		-- self.layout_:setTouchEnabled(false)
	
		-- Button_Start:setTouchEnabled(false)
	-- else
		-- -- Label_CoolTime:setText("00:00:00")
		-- Image_CoolTime:setVisible(false)
	-- end
	
	-- local Image_Tip = tolua.cast(Image_CoolTime:getChildByName("Image_Tip"),"Button")
	-- local function onClickRemove(pSender,eventType)
		-- if eventType == ccs.TouchEventType.ended then 
			-- local types = VipType.VipBuyOpType_TurnTableCD
			-- local gold = g_VIPBase:getVipLevelCDGold(types)
			-- if not g_CheckYuanBaoConfirm(gold,_T("您的元宝不足是否前往充值")) then
				-- return
			-- end
			
			-- local str = string.format(_T("是否花费%d元宝清除冷却时间？"),gold)
			-- g_ClientMsgTips:showConfirm(str, function() 
				-- local function removeCDFunc()
					-- g_TurnTableInfoData:setTurnShowColdTiemat(0)
					-- Image_CoolTime:setVisible(false)
					-- self:startButton(true)
					-- self.layout_:setTouchEnabled(true)
					-- Button_Start:setTouchEnabled(true)
					-- if self.nColdTiematId then 
						-- g_Timer:destroyTimerByID(self.nColdTiematId)
						-- self.nColdTiematId = nil
					-- end
					-- g_ShowSysTips({text = _T("冷却时间清除成功，下一VIP等级将减少消耗的元宝")})
					-- gTalkingData:onPurchase(TDPurchase_Type.TDP_TURNTABLE_REMOVE_CD,1,gold)	
					
				-- end
				-- g_VIPBase:responseFunc(removeCDFunc)
				-- g_VIPBase:requestVipBuyTimesRequest(types)
			-- end)
		-- end
	-- end
	-- Image_Tip:setTouchEnabled(true)
	-- Image_Tip:addTouchEventListener(onClickRemove)
	-- -- g_SetBtnWithPressImage(Image_Tip, 1, onClickRemove, true, 1)
	
-- end
]]

function Game_Turntable:update(curTurnIdx)
	local nType = macro_pb.TurntableTimes
	local useCount = g_Hero:getDailyNoticeByType(nType) 
	local count = g_Hero:getDailyNoticeLimitByType(nType)
	
	local types = VipType.VipBuyOpType_TurnTableTimes
	local num = g_VIPBase:getAddTableByNum(types)
	local allNum = count + num	
	
	self:lotteryNum(allNum - useCount, allNum)
	
	local friendHeartNum = g_DataMgr:getGlobalCfgCsv("turn_cost_friend_heart_num")
	self:loveHeart(friendHeartNum)
	
	local ButtonContentPNL = self:getButtonContentPNL()
	if not ButtonContentPNL then return end 
	
	local Image_PointArrow = tolua.cast(ButtonContentPNL:getChildByName("Image_PointArrow"),"ImageView")
	local rotate = 0	
	--开始按钮的暗化
	self:startButton(false)

	g_MsgNetWorkWarning:showWarningText(true)
	

	local Button_Start = tolua.cast(ButtonContentPNL:getChildByName("Button_Start"),"Button")
	Button_Start:setTouchEnabled(false)
	
	
	local function objAction(count,times)
		self:singleBright(count)
		Image_PointArrow:setRotation(rotate)
		rotate = rotate + 45
		if rotate >= 360 then 
			rotate = 0
		end
	end
	local function actionEnded()
		--开始按钮的亮起
		if self.nNum ~= 0 then 
			self:startButton(true)
		end
		--在掉落那里
		if self.callFunc then
			self.callFunc()
			self.callFunc = nil
		end
		if self.nTimerId then
			g_Timer:destroyTimerByID(self.nTimerId)
			self.nTimerId = nil
		end	
		g_MsgNetWorkWarning:closeNetWorkWarning()
		
		local ButtonContentPNL = self:getButtonContentPNL()
		if not ButtonContentPNL then return end 
		local Button_Start = tolua.cast(ButtonContentPNL:getChildByName("Button_Start"),"Button")
		Button_Start:setTouchEnabled(true)
	
		self.layout_:setTouchEnabled(true)
	end
	local paramAnimation = {
		numAward = 8, --"有多少个奖励物品 box "
		executeConst = 32, --"在停到获得奖励之前 会有一点次数的 循环亮起动画 这个数需是 numAward 的倍数"
		rewardLev = curTurnIdx,--"品质等级 动画最终停止的地方"
		totalTime = 1,--总时间
		easeTime = 4,--缓冲时间
		func = objAction,--回调函数带 count 每累加到numAward后重置为1 
		endFunc =actionEnded,--动画结束后的回调函数
	}
	self.nTimerId = g_AnimationAward(paramAnimation)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Turntable") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end

end