Game_DragonPray = class("Game_DragonPray")
Game_DragonPray.__index = Game_DragonPray

--骰子动画
local seed = 0
function Game_DragonPray:diceAction(widget, nIndex)
	if self.bRun then
		seed = seed + 1 
		math.randomseed(seed)
		widget:loadTexture(getDragonPrayImg("ShaiZi"..math.random(1, 6)))
		-- local nAngle = math.random(0, 360)
		local rotateBy = CCRotateBy:create(0.1, 360)
		local arrAct = CCArray:create()
		arrAct:addObject(rotateBy)
		arrAct:addObject(CCCallFuncN:create(function ()
				self:diceAction(widget, nIndex)
			end))
		local action = CCSequence:create(arrAct)
		widget:runAction(action)
	else
		local button =  tolua.cast(widget:getParent(),"Button")
			
		local armature,userAnimation = g_CreateCoCosAnimationWithCallBacks("ShangXiangSucc", nil, nil, 5)
		armature:setPositionY(3)
		armature:setScale(1.6)
        widget:setRotation(0)
		button:addNode(armature)
		userAnimation:playWithIndex(0)		
		widget:loadTexture(getDragonPrayImg("ShaiZi"..g_DragonPray:getDiceType(nIndex)))
	end
end

--刷新界面信息
function Game_DragonPray:refreshInfo()
	local nTime, nMax = g_DragonPray:getPrayTime()
	self.BitmapLabel_PayRemainNum:setText(nMax - nTime)
	g_adjustWidgetsRightPosition({self.BitmapLabel_PayRemainNum, self.Button_AddTimes}, -12)
	
	self.Label_DragonLevel:setText(g_DragonPray:getDragonLv().._T("级"))
	self.Label_DragonLevelLB:setPositionX(self.Button_DragonBallReward:getPositionX()-(self.Label_DragonLevelLB:getSize().width + self.Label_DragonLevel:getSize().width)/2)
	local expNow, expMax = g_DragonPray:getDragonExp()
	self.Label_DragonExp:setText(expNow.."/"..expMax)
	self.ProgressBar_DragonExp:setPercent(expNow/expMax * 100)

	local chgTimeNow, changeTimeMax = g_DragonPray:getChangeTime()
	self.Label_FreeRevertTimes:setText(chgTimeNow)
	self.Label_FreeRevertTimesMax:setText("/"..changeTimeMax)
	g_AdjustWidgetsPosition({self.Label_FreeRevertTimes, self.Label_FreeRevertTimesMax})
	self.Label_FreeRevertTimesLB:setPositionX(self.Button_YueLiReward:getPositionX()-(self.Label_FreeRevertTimesLB:getSize().width + self.Label_FreeRevertTimes:getSize().width + self.Label_FreeRevertTimesMax:getSize().width)/2)
	
	if macro_pb.DragonState_WaitPray == g_DragonPray:getState() then
		self.Button_Pray:setVisible(true)
		self.Button_Confirm:setVisible(false)
		self.Button_Revert:setVisible(false)
		self.Label_DragonBallReward:setText("+0")
		self.Label_YueLiReward:setText("+0")
		self.Label_AddExp:setText(_T("Exp+0"))
		self.Label_AddExp:setVisible(false)
		local Image_Arrow = tolua.cast(self.Label_AddExp:getChildByName("Image_Arrow"), "ImageView")
		Image_Arrow:setPositionX(self.Label_AddExp:getSize().width/2 + 15)
		Image_Arrow:stopAllActions()
	else
		self.Button_Pray:setVisible(false)
		self.Label_AddExp:setVisible(true)
		if self.bRun then
			self.nTimerID_Game_DragonPray_1 = g_Timer:pushTimer(1, function ()
				if not g_WndMgr:getWnd("Game_DragonPray") then return end
				
				self.bRun = false
				self.Button_Confirm:setVisible(true)
				self.Button_Revert:setVisible(true)
				self.Label_DragonBallReward:setText("+"..g_DragonPray:getDragonBall())
				self.Label_YueLiReward:setText("+"..g_DragonPray:getYueli())
				self.Label_AddExp:setText("Exp+"..g_DragonPray:getAddDragonExp())
				local Image_Arrow = tolua.cast(self.Label_AddExp:getChildByName("Image_Arrow"), "ImageView")
				Image_Arrow:setPositionX(self.Label_AddExp:getSize().width/2 + 15)
				Image_Arrow:stopAllActions()
				g_CreateUpAndDownAnimation(Image_Arrow, nil, nil, 1)
				
				if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventEnd", "Game_DragonPray") then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
			end)
		else
			self.Button_Confirm:setVisible(true)
			self.Button_Revert:setVisible(true)
			self.Label_DragonBallReward:setText("+"..g_DragonPray:getDragonBall())
			self.Label_YueLiReward:setText("+"..g_DragonPray:getYueli())
			self.Label_AddExp:setText("Exp+"..g_DragonPray:getAddDragonExp())
			local Image_Arrow = tolua.cast(self.Label_AddExp:getChildByName("Image_Arrow"), "ImageView")
			Image_Arrow:setPositionX(self.Label_AddExp:getSize().width/2 + 15)
			Image_Arrow:stopAllActions()
			g_CreateUpAndDownAnimation(Image_Arrow, nil, nil, 1)
		end
	end
end

function Game_DragonPray:addTimes(cost)
	if cost then
		-- cost = g_VIPBase:getVipValue("DragonPrayExCost")
		cost = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_DragonPrayTimes)
		if not g_CheckYuanBaoConfirm(cost, _T("购买神龙上供次数需要消耗")..cost.._T("元宝, 您的元宝不足是否前往充值")) then
			return
		end
		local str = _T("是否花费")..cost.._T("元宝购买1次神龙上供？")
		g_ClientMsgTips:showConfirm(str, function() 
			local function serverResponseCall(tiems)			
				local nTime, nMax = g_DragonPray:getPrayTime()
				self.BitmapLabel_PayRemainNum:setText(nMax - nTime)
				g_ShowSysTips({text = _T("成功购买1次神龙上供\n")})
				gTalkingData:onPurchase(TDPurchase_Type.TDP_DRAGON_PRAY_NUM,1,cost)		
			end
			g_VIPBase:responseFunc(serverResponseCall)
			g_VIPBase:requestVipBuyTimesRequest(VipType.VipBuyOpType_DragonPrayTimes)
		end)
	else
		g_ClientMsgTips:showMsgConfirm(_T("今天已达到购买次数上限\n升级VIP等级可以提升每天购买次数的上限"))
		return
	end
end

function Game_DragonPray:onClickAdd(pSender, eventType)
	if ccs.TouchEventType.ended == eventType then
		self:addTimes(g_DragonPray:isBuyEnabled() and g_DragonPray:getPrayCost())
	end
end


local function onClick_Button_Pray(pSender, nTag)
	local wndInstance = g_WndMgr:getWnd("Game_DragonPray")
	if wndInstance then
		local cost = g_DragonPray:getPrayCost()
		if 0 == cost then
			g_DragonPray:requestPray()
			wndInstance.bRun = true
			wndInstance.Button_Pray:setVisible(false)
			for k, v in ipairs(wndInstance.tbDice) do
				wndInstance:diceAction(v, k)
			end
		else
			wndInstance:addTimes(cost)
		end
	end
end

local function onClick_Button_Confirm(pSender, nTag)
	g_DragonPray:requestConfirm()
	local wndInstance = g_WndMgr:getWnd("Game_DragonPray")
	if wndInstance then
		local Image_DragonBody = tolua.cast(wndInstance.rootWidget:getChildByName("Image_DragonBody"),"ImageView")
		local function animationEndCall()
			if g_PlayerGuide:checkCurrentGuideSequenceNode("AnimationEnd", "IncenseStatue") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
		local armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("IncenseStatue", nil, animationEndCall, 5)
		armature:setScale(1.5)
		armature:setPositionY(45)
		Image_DragonBody:addNode(armature, 999)
		userAnimation:playWithIndex(0)
	end
end

local function onClick_Button_Revert(pSender, nTag)

	local function func()
		local wndInstance = g_WndMgr:getWnd("Game_DragonPray")
		if wndInstance then
			for k, v in ipairs(wndInstance.tbDice) do
				if macro_pb.DiceType_Ji ~= g_DragonPray:getDiceType(k) then
					wndInstance.bRun = true
					wndInstance:diceAction(v, k)
				end
			end
			if wndInstance.bRun then
				wndInstance.Button_Confirm:setVisible(false)
				wndInstance.Button_Revert:setVisible(false)
				g_DragonPray:requestChange()
			else
				g_ClientMsgTips:showMsgConfirm(string.format(_T("已经出现7个吉了, 再贪心也没有了")))
			end
		end
	end
	if g_DragonPray:getChangeCost() > 0 then
	
		local cost = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_DragonChangeCost)
		if not g_CheckYuanBaoConfirm(cost, _T("改运需要消耗")..cost.._T("元宝, 您的元宝不足是否前往充值")) then
			return
		end
		local str = _T("是否花费")..cost.._T("元宝购买1次逆天改运？")
		g_ClientMsgTips:showConfirm(str, func)
		
	else
		func()
	end
end


function Game_DragonPray:initWnd()
	local Image_BtnPNL = tolua.cast(self.rootWidget:getChildByName("Image_BtnPNL"), "ImageView")
	self.Button_Confirm = Image_BtnPNL:getChildByName("Button_Confirm")
	g_SetBtnWithGuideCheck(self.Button_Confirm, 1, onClick_Button_Confirm, true)
	
	self.Button_Revert = Image_BtnPNL:getChildByName("Button_Revert")
	g_SetBtnWithGuideCheck(self.Button_Revert, 1, onClick_Button_Revert, true)
	
	self.Button_Pray = Image_BtnPNL:getChildByName("Button_Pray")
	g_SetBtnWithGuideCheck(self.Button_Pray, 1, onClick_Button_Pray, true)
	
	local Image_DragonExp = tolua.cast(Image_BtnPNL:getChildByName("Image_DragonExp"), "ImageView")
	self.Label_DragonExp = tolua.cast(Image_DragonExp:getChildByName("Label_DragonExp"), "Label")
	self.ProgressBar_DragonExp = tolua.cast(Image_DragonExp:getChildByName("ProgressBar_DragonExp"), "LoadingBar")
	
	local Image_RewardPNL = tolua.cast(Image_BtnPNL:getChildByName("Image_RewardPNL"), "ImageView")
	
	self.Label_DragonLevelLB = tolua.cast(Image_RewardPNL:getChildByName("Label_DragonLevelLB"), "Label")
	self.Label_DragonLevel = tolua.cast(self.Label_DragonLevelLB:getChildByName("Label_DragonLevel"), "Label")
	self.Label_AddExp = tolua.cast(Image_BtnPNL:getChildByName("Label_AddExp"), "Label")
	
	self.Label_FreeRevertTimesLB = tolua.cast(Image_RewardPNL:getChildByName("Label_FreeRevertTimesLB"), "Label")
	self.Label_FreeRevertTimes = tolua.cast(self.Label_FreeRevertTimesLB:getChildByName("Label_FreeRevertTimes"), "Label")
	self.Label_FreeRevertTimesMax = tolua.cast(self.Label_FreeRevertTimesLB:getChildByName("Label_FreeRevertTimesMax"), "Label")
	
	self.Button_DragonBallReward = tolua.cast(Image_RewardPNL:getChildByName("Button_DragonBallReward"), "ImageView")
	self.Label_DragonBallReward = tolua.cast(self.Button_DragonBallReward:getChildByName("Label_DragonBallReward"), "Label")
	
	self.Button_YueLiReward = tolua.cast(Image_RewardPNL:getChildByName("Button_YueLiReward"), "ImageView")
	self.Label_YueLiReward = tolua.cast(self.Button_YueLiReward:getChildByName("Label_YueLiReward"), "Label")
	
	self.Button_AddTimes = tolua.cast(self.rootWidget:getChildByName("Button_AddTimes"), "Button")
	self.Button_AddTimes:setTouchEnabled(true)
	self.Button_AddTimes:addTouchEventListener(handler(self, self.onClickAdd))
	self.BitmapLabel_PayRemainNum = tolua.cast(self.rootWidget:getChildByName("BitmapLabel_PayRemainNum"), "LabelBMFont")
	
	self.bRun = false
	self.tbDice = {}
	for i = 1, 7 do 
		local Image_DragonBall = self.rootWidget:getChildByName("Image_DragonBall"..i)
		self.Image_Icon = tolua.cast(Image_DragonBall:getChildByName("Image_Icon"), "ImageView")
		self:diceAction(self.Image_Icon, i)
		table.insert(self.tbDice, self.Image_Icon)

		if i == 1 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, -1)
		elseif i == 2 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, 1)
		elseif i == 3 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, -1)
		elseif i == 4 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, 1)
		elseif i == 5 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, -1)
		elseif i == 6 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, 1)
		elseif i == 7 then
			g_CreateUpAndDownAnimation(Image_DragonBall, nil, nil, -1)
		end
	end
	local Image_Head = tolua.cast(self.rootWidget:getChildByName("Image_Head"), "ImageView")
	g_CreateUpAndDownAnimation(Image_Head, nil, nil, 1)
	self.clippingNode = g_GlitteringWidget(Image_Head, 1, 1, 100)
	
	self:refreshInfo()
	
	g_FormMsgSystem:RegisterFormMsg(FormMsg_DragonPray_Info, handler(self, self.refreshInfo))

	for i = 1, 6 do
		local Button_Skill = tolua.cast(Image_BtnPNL:getChildByName("Button_Skill"..i), "Button")
		g_SetBtnWithPressingEvent(Button_Skill, i, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	end
	g_SetBtnWithPressingEvent(self.Label_DragonLevelLB, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(self.Label_DragonLevel, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	g_SetBtnWithPressingEvent(self.Label_FreeRevertTimesLB, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(self.Label_FreeRevertTimes, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(self.Label_FreeRevertTimesMax, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Image_PayRemainNum1 = tolua.cast(self.rootWidget:getChildByName("Image_PayRemainNum1"), "ImageView")
	local Image_PayRemainNum2 = tolua.cast(self.rootWidget:getChildByName("Image_PayRemainNum2"), "ImageView")
	g_SetBtnWithPressingEvent(self.BitmapLabel_PayRemainNum, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(Image_PayRemainNum1, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(Image_PayRemainNum2, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(Image_DragonExp, 1, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)

	local Button_DragonPrayGuide = tolua.cast(self.rootWidget:getChildByName("Button_DragonPrayGuide"), "Button")
	g_RegisterGuideTipButton(Button_DragonPrayGuide, nil)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("ShenLongShangGong"))
end

function Game_DragonPray:openWnd()

end

function Game_DragonPray:closeWnd()
	-- body
	self.clippingNode:removeFromParentAndCleanup(true)
	g_Timer:destroyTimerByID(self.nTimerID_Game_DragonPray_1)
	self.nTimerID_Game_DragonPray_1 = nil

	g_FormMsgSystem:UnRegistFormMsg(FormMsg_DragonPray_Info)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
end

function Game_DragonPray:ModifyWnd_viet_VIET()
    local Label_DragonLevelLB = self.rootWidget:getChildAllByName("Label_DragonLevelLB")
	local Label_DragonLevel = self.rootWidget:getChildAllByName("Label_DragonLevel")
	Label_DragonLevelLB:setPositionX(-250)
	Label_DragonLevel:setPositionX(Label_DragonLevelLB:getSize().width)

	local Label_FreeRevertTimesLB = self.rootWidget:getChildAllByName("Label_FreeRevertTimesLB")
	local Label_FreeRevertTimes = self.rootWidget:getChildAllByName("Label_FreeRevertTimes")
	local Label_FreeRevertTimesMax = self.rootWidget:getChildAllByName("Label_FreeRevertTimesMax")
	Label_FreeRevertTimesLB:setPositionX(30)
	Label_FreeRevertTimes:setPositionX(Label_FreeRevertTimesLB:getSize().width)
    g_AdjustWidgetsPosition({Label_FreeRevertTimes, Label_FreeRevertTimesMax},2)
end