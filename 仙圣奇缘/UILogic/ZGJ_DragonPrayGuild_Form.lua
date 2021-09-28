Game_DragonPrayGuild = class("Game_DragonPrayGuild")
Game_DragonPrayGuild.__index = Game_DragonPrayGuild

--骰子动画
local seed = 0
function Game_DragonPrayGuild:diceAction(widget, nIndex)
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
		button:addNode(armature)
		userAnimation:playWithIndex(0)		
		widget:loadTexture(getDragonPrayImg("ShaiZi"..g_DragonPrayGuild:getDiceType(nIndex)))

	end
end

function Game_DragonPrayGuild:diceActionEnd()
	self.Image_Background:setTouchEnabled(true)
	self.Label_MyPoints:setText(string.format(_T("您当前获得%d积分, 排名第%d"), g_DragonPrayGuild:getScoreAndRank()))
	self:refreshRank()
end

function Game_DragonPrayGuild:refreshRank()
	local tbRank = g_DragonPrayGuild:getRank()
	for i = 1, 5 do
		local Label_Rank = tolua.cast(self.Image_RankPNL:getChildByName("Label_Rank"..i), "Label")
		if tbRank[i] then
			Label_Rank:setVisible(true)
			Label_Rank:setText(i..string.format(". %s %d".._T("积分"), tbRank[i].name, tbRank[i].damage))
		else
			Label_Rank:setVisible(false)
		end
	end
end

--刷新界面信息
function Game_DragonPrayGuild:refreshInfo()
	self.BitmapLabel_PayRemainNum:setText(g_DragonPrayGuild:getPrayTime())
	self.nTimerID1 = g_Timer:pushTimer(1, function ()
		if not g_WndMgr:getWnd("Game_DragonPrayGuild") then return end
		self.bRun = false
		self:diceActionEnd()
	end)
end

function Game_DragonPrayGuild:onClickScreen(pSender, eventType)
	if ccs.TouchEventType.ended == eventType then
		if g_DragonPrayGuild:getPrayTime() <= 0 then
			g_ClientMsgTips:showMsgConfirm(_T("今天吉星高照的次数已经用完了"))
			return
		end
		self.Image_Background:setTouchEnabled(false)
		self.bRun = true
		for k, v in ipairs(self.tbDice) do
			self:diceAction(v, k)
		end
		g_DragonPrayGuild:requestPray()
	end
end

function Game_DragonPrayGuild:onClickRank(pSender, eventType)
	if ccs.TouchEventType.ended == eventType then
		g_DragonPrayGuild:openRank()
	end
end

function Game_DragonPrayGuild:checkData()
	if not g_DragonPrayGuild:isInit() then
		return false
	else
		return true
	end
end

function Game_DragonPrayGuild:initWnd()	
	local Image_TouchScreen = tolua.cast(self.rootWidget:getChildByName("Image_TouchScreen"), "ImageView")
	g_CreateScaleInOutAction(Image_TouchScreen)
	self.Label_MyPoints = tolua.cast(self.rootWidget:getChildByName("Label_MyPoints"), "Label")
	
	self.Image_RankPNL = self.rootWidget:getChildByName("Image_RankPNL")
	self.Image_RankPNL:setTouchEnabled(true)
	self.Image_RankPNL:addTouchEventListener(handler(self, self.onClickRank))
	

	-- tb = {"ab", "bbb", "aaaa", "aaaaa", "aaaaaaaaa"}
	-- str= {}
	-- for i = 1, 5 do
	-- 	local Label_Rank = tolua.cast(self.Image_RankPNL:getChildByName("Label_Rank"..i), "Label")
	-- 	Label_Rank:setAnchorPoint(ccp(0, 0.5))
	-- 	Label_Rank:setPositionX(-150)
	-- 	Label_Rank:ignoreContentAdaptWithSize(true)
	-- 	str[i] = tb[i]..string.rep("a", 30 - string.len(tb[i]))
	-- 	Label_Rank:setText(i..". "..tb[i]..string.rep("z", 30 - string.len(tb[i]) - 3).."300积分")
	-- 	cclog(Label_Rank:getPositionX())
	-- 	--Label_Rank:setText(i..string.format(" %s %d积分", g_DragonPrayGuild:getScoreAndRank()))
	-- end

	self.bRun = false
	self.tbDice = {}
	for i = 1, 7 do 
		local Image_DragonBall = self.rootWidget:getChildByName("Image_DragonBall"..i)
		self.Image_Icon = tolua.cast(Image_DragonBall:getChildByName("Image_Icon"), "ImageView")
		--self:diceAction(self.Image_Icon, i)
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
	
	self.BitmapLabel_PayRemainNum = tolua.cast(self.rootWidget:getChildByName("BitmapLabel_PayRemainNum"), "LabelBMFont")
	
	local Button_DragonPrayGuildGuide = tolua.cast(self.rootWidget:getChildByName("Button_DragonPrayGuildGuide"), "Button")
	g_RegisterGuideTipButton(Button_DragonPrayGuildGuide)

	self.Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	self.Image_Background:loadTexture(getBackgroundJpgImg("JiXingGaoZhao"))
	self.Image_Background:setTouchEnabled(true)
	self.Image_Background:addTouchEventListener(handler(self, self.onClickScreen))

	g_FormMsgSystem:RegisterFormMsg(FormMsg_DragonPrayGuild_Pray, handler(self, self.refreshInfo))
end

function Game_DragonPrayGuild:openWnd()
	self.Label_MyPoints:setText(string.format(_T("您当前获得%d积分, 排名第%d"), g_DragonPrayGuild:getScoreAndRank()))
	self:refreshRank()
	self.BitmapLabel_PayRemainNum:setText(g_DragonPrayGuild:getPrayTime())
end

function Game_DragonPrayGuild:closeWnd()
	-- body
	g_Timer:destroyTimerByID(self.nTimerID1)
	self.nTimerID_Game_DragonPrayGuild_1 = nil

	g_FormMsgSystem:UnRegistFormMsg(FormMsg_DragonPrayGuild_Pray)
	
	self.Image_Background:loadTexture(getUIImg("Blank"))

	g_DragonPrayGuild:reset()
end