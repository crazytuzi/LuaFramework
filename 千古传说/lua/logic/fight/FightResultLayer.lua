
local FightResultLayer = class("FightResultLayer", BaseLayer)

TipsList = require("lua.table.t_s_help_tips")

function FightResultLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.fight.FightResultLayer")
end

function FightResultLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.fightResultInfo = FightManager.fightResultInfo

	self.replayBtn = TFDirector:getChildByPath(ui, 'replayBtn')
	self.leaveBtn = TFDirector:getChildByPath(ui, 'leaveBtn')
	self.btn_shtj = TFDirector:getChildByPath(ui, 'btn_shtj')
	self.leaveBtn.logic = self
	-- self.panel_shtj = TFDirector:getChildByPath(ui, 'panel_shtj')
	-- self.panel_shtj = self.btn_shtj
	self:ShowButton(false)

	self.rewardPanel = TFDirector:getChildByPath(self.ui, 'rewardPanel')
	self.rewardPanel.pic = TFDirector:getChildByPath(self.rewardPanel, 'Image_FightResultLayer_1')
	self.rewardPanel:setVisible(false)

	-- print("rewardPanel postion = ",self.rewardPanel:getPosition())
	self.failPanel = TFDirector:getChildByPath(self.ui, 'failPanel')
	self.failPanel:setVisible(false)

	self.failTipbg = {}
	self.failTipbg[1] = TFDirector:getChildByPath(self.ui, 'bg_zhiying1')
	self.failTipbg[2] = TFDirector:getChildByPath(self.ui, 'bg_zhiying2')

	self.ui = ui

	self.btnPos = {}
	self.btnList = {self.replayBtn, self.leaveBtn, self.btn_shtj}
	for i=1, 3 do
		self.btnPos[i] = {}
		self.btnPos[i].x = self.btnList[i]:getPositionX()
		self.btnPos[i].y = self.btnList[i]:getPositionY()
	end

	self.panelStars = {}
	for i=1, 3 do
		local panelStar = TFDirector:getChildByPath(self.ui, 'panel_hua' .. i)
		self.panelStars[i] = panelStar
	end

	-- self.panel_shtj_pos = {}
	-- self.panel_shtj_pos.x =  self.panel_shtj:getPosition().x
	-- self.panel_shtj_pos.y =  self.panel_shtj:getPosition().y

	TFAudio.stopMusic()
	self:PlaySoundEffect()
	self:PlayResultEffect()

	self.isguideClick = false

	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 18 then   --护矿
		self.leaveTimer = TFDirector:addTimer(20000,1,nil,function ()
			if self.leaveTimer then
				TFDirector:removeTimer(self.leaveTimer)
				self.leaveTimer = nil
			end
			FightManager:LeaveFight()
			TFDirector:dispatchGlobalEventWith(FightManager.FactionBossFightLeave,{});
		end)

		TFDirector:dispatchGlobalEventWith(FightManager.FactionBossFightResult,{ self.fightResultInfo.result });
	end
end

function FightResultLayer:removeUI()
	if self.updateTimerID ~= nil then
		TFDirector:removeTimer(self.updateTimerID)
	end

	self.super.removeUI(self)
end

function FightResultLayer:registerEvents(ui)	
	self.super.registerEvents(self)

	self.replayBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.relayClickHandle),1)
	self.leaveBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.leaveBtnHandle),1)

	self.btn_shtj:addMEListener(TFWIDGET_CLICK, audioClickfun(self.hurtCountClickHandle),1)
	local roleBtn = TFDirector:getChildByPath(ui, 'roleBtn')
	roleBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(function() FightManager:LeaveFight() CardRoleManager:openRoleList() end),1)

	local equipBtn = TFDirector:getChildByPath(ui, 'equipBtn')
	equipBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(function() FightManager:LeaveFight() EquipmentManager:OpenSmithyMainLaye() end),1)

	local mallBtn = TFDirector:getChildByPath(ui, 'mallBtn')
	mallBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(function() FightManager:LeaveFight() MallManager:openMallLayer() end),1)

	self.ui:setTouchEnabled(true)
	self.ui:addMEListener(TFWIDGET_CLICK, audioClickfun(function() self:uiClickHandle() end))

	ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end

function FightResultLayer:removeEvents()	
	self.super.removeEvents(self)
	if self.leaveTimer then
		TFDirector:removeTimer(self.leaveTimer)
		self.leaveTimer = nil	
	end

end

function FightResultLayer:PlaySoundEffect()
	local nResult = self.fightResultInfo.result
	if nResult == 0 then
		TFAudio.playEffect("sound/effect/fight_fail.mp3", false)
	else
		TFAudio.playEffect("sound/effect/fight_win.mp3", false)
	end
end


function FightResultLayer:getClimbEffectIndex()
	local oldNum = ClimbManager:getClimbStarInfo( self.fightResultInfo.climblev )
	local passLimit = self.fightResultInfo.rank
	local new_num = 0
	local effext_index = 0
    if passLimit == 0 then
        new_num = 1
    elseif passLimit == 3 then
        new_num = 3
    else
        new_num = 2
    end
    if oldNum == 0 then
		effext_index = new_num
    elseif oldNum == 1 then
    	if new_num == 1 then
    		effext_index = 7
    	else
			effext_index = new_num + 3 - 1
    	end
    elseif oldNum == 2 then
    	if new_num <= 2 then
    		effext_index = 8
    	else
			effext_index = 6
    	end
    else
    	effext_index = 9
    end
    print("effext_index = ",effext_index)
    return effext_index -1
end

function FightResultLayer:PlayStarAnimation()
	local nResult = self.fightResultInfo.result

	if nResult > 0 then
		local effectID1 = "fightwin"
		local effectID2 = "fightwin1"
		for i=1, nResult do
			ModelManager:addResourceFromFile(2, effectID1, 1)
			local effect = ModelManager:createResource(2, effectID1)
			local delayTimerID = TFDirector:addTimer(200 * i, 1, nil, 
				function() 
					TFDirector:removeTimer(delayTimerID)
					self.panelStars[i]:addChild(effect)
					ModelManager:addListener(effect, "ANIMATION_COMPLETE", function() 
						ModelManager:removeListener(effect, "ANIMATION_COMPLETE")
							effect:removeFromParent()
							ModelManager:addResourceFromFile(2, effectID2, 1)
							local starEffect = ModelManager:createResource(2, effectID2)
							self.panelStars[i]:addChild(starEffect)
							ModelManager:playWithNameAndIndex(starEffect, "", 0, 1, -1, -1)
					end)
					ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
				end)
		end
	end
end

function FightResultLayer:PlayResultEffect()
	self:ShowExpPanel()
	
	-- local nResult = self.fightResultInfo.result
	-- local effectName = "fightwin"
	-- if FightManager.fightBeginInfo.fighttype == 16 then
	-- 	effectName = "northClimbWin"
	-- elseif FightManager.fightBeginInfo.fighttype == 5 then
	-- 	effectName = "ClimbWin"
	-- end
	-- if nResult == 0 then
	-- 	effectName = "fightfail"
	-- end
	-- TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
	-- local effect = TFArmature:create(effectName.."_anim")
	-- if effect == nil then
	-- 	return
	-- end

	-- effect:setAnimationFps(GameConfig.ANIM_FPS)


	-- local nViewHeight = GameConfig.WS.height
 --    	local nViewWidth = GameConfig.WS.width
	-- effect:setPosition(ccp(nViewWidth/2, nViewHeight/2))

	-- self.ui:addChild(effect)

	-- if FightManager.fightBeginInfo.fighttype == 5 and nResult ~= 0 then
	-- 	local effect_index = self:getClimbEffectIndex()
	-- 	effect:playByIndex(effect_index, -1, -1, 0)
	-- 	local timerID = TFDirector:addTimer(10, 1, nil,
	-- 	function()
	-- 		TFDirector:removeTimer(timerID)
	-- 		self:ShowExpPanel()
	-- 	end)
	-- 	return
	-- end
	-- effect:setAnimationFps(GameConfig.ANIM_FPS*1.5)

	-- local shakeTime = {}
	-- if nResult == 0 then
	-- 	effect:playByIndex(0, -1, -1, 0)
	-- elseif nResult == 1 then
	-- 	effect:playByIndex(2, -1, -1, 0)
	-- 	shakeTime = {700}
	-- elseif nResult == 2 then
	-- 	effect:playByIndex(1, -1, -1, 0)
	-- 	shakeTime = {700, 900}
	-- elseif nResult == 3 then
	-- 	effect:playByIndex(0, -1, -1, 0)
	-- 	shakeTime = {700, 900, 1200}
	-- end

	-- for i=1,#shakeTime do
	-- 	TFDirector:addTimer(shakeTime[i], 1, nil, 
	-- 	function()
	-- 		if i == #shakeTime then
	-- 			TFDirector:currentScene():LastStarShake(8,8)
	-- 		else
	-- 			TFDirector:currentScene():StarShake(8,8)
	-- 		end
	-- 	end)
	-- end

	-- local timerID = TFDirector:addTimer(1500, 1, nil,
	-- function()
	-- 	TFDirector:removeTimer(timerID)
	-- 	self:ShowExpPanel()
	-- end)
end

function FightResultLayer:PlayUplevEffect(rolePanel, bEndRemove)
	local effectName = "fightlevel"
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
	local effect = TFArmature:create(effectName.."_anim")
	if effect == nil then
		return
	end

	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 0)
	effect:setPosition(ccp(-60, -100))
	rolePanel:addChild(effect)

	if bEndRemove then
		effect:addMEListener(TFARMATURE_COMPLETE, function()
			effect:removeFromParent()
		end)
	end
end

function FightResultLayer:ShowButton(bVisible)
	-- print("FightResultLayer:ShowButton(bVisible) ========")
	if not bVisible then
		self.replayBtn:setVisible(false)
		self.leaveBtn:setVisible(false)
		self.btn_shtj:setVisible(false)
		self.isguideClick = false
	else
		if not self.leaveBtn:isVisible() then
			-- local btnList = {self.replayBtn ,self.leaveBtn}
			local start = 1
			local fightType = FightManager.fightBeginInfo.fighttype
			-- if fightType >= 18 and fightType <= 23 then
			-- 	start = 2
			-- end

			for i=start,3 do
				local btn = self.btnList[i]
				btn:setVisible(true)
				btn:setOpacity(50)
				local btnPos = btn:getPosition()
				btn:setPosition(ccp(self.btnPos[i].x, self.btnPos[i].y-80))
				local btnTween = 
				{
					target = btn,
					{
						duration = 0.3,
						x = self.btnPos[i].x,
						y = self.btnPos[i].y,
						alpha = 255,

						onComplete =  function ()
							self.isguideClick = true
							btn:setTouchEnabled(true)
						end
					},
				}
				btn:setTouchEnabled(false)
				TFDirector:toTween(btnTween)
			end
		end

		-- if not self.panel_shtj:isVisible() then
		-- 	local fightType = FightManager.fightBeginInfo.fighttype
		-- 	-- if fightType > 18 and fightType <= 23 then
		-- 	-- 	return
		-- 	-- end
		-- 	local btn = self.panel_shtj
		-- 	btn:setVisible(true)
		-- 	btn:setOpacity(50)
		-- 	local btnPos = btn:getPosition()
		-- 	btn:setPosition(ccp(self.panel_shtj_pos.x - 160, self.panel_shtj_pos.y))
		-- 	local btnTween = 
		-- 	{
		-- 		target = btn,
		-- 		{
		-- 			duration = 0.3,
		-- 			x = self.panel_shtj_pos.x,
		-- 			y = self.panel_shtj_pos.y,
		-- 			alpha = 255,

		-- 			onComplete =  function ()
		-- 				btn:setTouchEnabled(true)
		-- 			end
		-- 		},
		-- 	}
		-- 	btn:setTouchEnabled(false)
		-- 	TFDirector:toTween(btnTween)
		-- end
	end
end

function FightResultLayer:isShowGuideClick()
	return self.isguideClick
end

function FightResultLayer:RefreshFailTip()
	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 5 or fightType == 16 then
		return
	end

	local fail_guideList = FightFailGuide:getGuildeListByLevel(MainPlayer:getLevel())

	for i=1,2 do
		local randomTip = math.random(1, fail_guideList:length())
		local guide = fail_guideList:objectAt(randomTip)
		if guide == nil then
			self.failTipbg[i]:setVisible(false)
			return
		end
		self.failTipbg[i]:setVisible(true)
		local txt_biaoti = TFDirector:getChildByPath(self.failTipbg[i], 'txt_biaoti')
		local Img_tishi = TFDirector:getChildByPath(self.failTipbg[i], 'Img_tishi')
		local txt_des = TFDirector:getChildByPath(self.failTipbg[i], 'txt_des')
		txt_biaoti:setText(guide.title)
		Img_tishi:setTexture(guide.img)
		txt_des:setText(guide.desc)
		function failGuideclick( btn )
			--quanhuan add 2015-9-16 17:17:05
			MissionManager:quickPassToGetFGoods(nil, nil)
			local scene = AlertManager:changeScene(SceneType.HOME,nil,TFSceneChangeType_PopBack)
			scene:gotoLayerByType(guide.layer_type)
		end
		self.failTipbg[i]:addMEListener(TFWIDGET_CLICK, failGuideclick)
		fail_guideList:removeObject(guide)
	end

end

function FightResultLayer:ShowExpPanel()
	local nResult = self.fightResultInfo.result
	local fightType = FightManager.fightBeginInfo.fighttype
	local resultPanel = nil
	if nResult == 0 and fightType ~= 3 and fightType ~= 5  then
		self.rewardPanel:setVisible(false)
		self.failPanel:setVisible(true)
		resultPanel = self.failPanel
		self:RefreshFailTip()
	else
		self.rewardPanel:setVisible(true)
		self.failPanel:setVisible(false)
		resultPanel = self.rewardPanel
	end
	self.rewardPanel.pic:setTexture("ui_new/Ys_common/win.png")
	local Panel_ClimbResult = TFDirector:getChildByPath(self.rewardPanel, "Panel_ClimbResult2")
	Panel_ClimbResult:setVisible(false)

	local rankBgImg = TFDirector:getChildByPath(self.rewardPanel, "rankBgImg")
	rankBgImg:setVisible(false)
	local fightType = FightManager.fightBeginInfo.fighttype
	if fightType == 3 then --群豪谱
		self.rewardPanel:setVisible(true)
		if nResult ~= 0 and self.fightResultInfo.rank ~= nil then
			rankBgImg:setVisible(true)
			local rankNum = TFDirector:getChildByPath(rankBgImg, "rankNum")
			rankNum:setVisible(true)
			rankNum:setText("d"..self.fightResultInfo.rank.."m")
		else
			self.rewardPanel.pic:setTexture("ui_new/Ys_common/lose.png")
		end
	elseif fightType == 5 then --无量山
		-- self.rewardPanel:setVisible(true)
		-- if nResult ~= 0 then
		-- 	local climbResultBg = TFDirector:getChildByPath(self.rewardPanel, "climbResultBg")
		-- 	climbResultBg:setVisible(true)
		-- 	local climbLvLabel = TFDirector:getChildByPath(self.rewardPanel, "climbLvLabel")
		-- 	self.fightResultInfo.climblev = self.fightResultInfo.climblev or 10
		-- 	climbLvLabel:setText(self.fightResultInfo.climblev)
		-- end
		if nResult == 0 then
			self.fightResultInfo.rank = self.fightResultInfo.rank or 0
		end
		print("self.fightResultInfo.rank",self.fightResultInfo.rank)
		local Panel_ClimbResult = TFDirector:getChildByPath(resultPanel, "Panel_ClimbResult2")
		Panel_ClimbResult:setVisible(true)
		local climbFloor = self.fightResultInfo.climblev
		local climbPassLimitConfig = ClimbPassLimitConfig:objectByID(climbFloor)
		if climbPassLimitConfig == nil then
			return
		end
		local floorOptionNow = string.split(climbPassLimitConfig.limit_id,"_")
		-- local floorOptionNow = NorthClimbManager:getNowFloorOption()
		for i=1,2 do
			local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan"..i)
			if floorOptionNow[i] == nil then
				img_tiaozhan:setVisible(false)
			else
				local txt_neirong = TFDirector:getChildByPath(img_tiaozhan, "txt_neirong")
				local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
				img_tiaozhan:setVisible(true)
				img_gou:setVisible(false)
				local battleInfo = ClimbLimitConfig:objectByID(tonumber(floorOptionNow[i]))
				txt_neirong:setText(battleInfo.show)
				txt_neirong:setTextAreaSize(CCSizeMake(270,0))

				local complete = bit_and(self.fightResultInfo.rank,2^(i-1))
				if complete == 0 then
					img_gou:setTexture("ui_new/fightresult/img_xda.png")
					-- img_gou:setVisible(false)
				else
					img_gou:setTexture("ui_new/fightresult/img_gouda.png")
				end
			end
		end
		if nResult ~= 0 then

			ClimbManager:addClimbStarInfo( climbFloor,self.fightResultInfo.rank )
		end

		local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan3")
		local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
		img_tiaozhan:setVisible(true)
		img_gou:setVisible(false)
		-- end
	elseif fightType == 12 then --争霸赛
		self.rewardPanel:setVisible(true)
		if nResult ~= 0 then
			local zhenbashaiBg = TFDirector:getChildByPath(self.rewardPanel, "zhenbashaiBg")
			zhenbashaiBg:setVisible(true)
			local txt_liansheng = TFDirector:getChildByPath(self.rewardPanel, "txt_liansheng")
			local txt_jifen = TFDirector:getChildByPath(self.rewardPanel, "txt_jifen")
			local txt_dangqianjifen = TFDirector:getChildByPath(self.rewardPanel, "txt_dangqianjifen")
			if self.fightResultInfo.championsInfo then
				txt_liansheng:setText(self.fightResultInfo.championsInfo.atkWinStreak)
				txt_jifen:setText(ZhengbaManager.score_add)
				txt_dangqianjifen:setText(self.fightResultInfo.championsInfo.score)
			end
		end
	elseif fightType == 16 then --无量山北峰
		-- self.rewardPanel:setVisible(true)
		-- if nResult ~= 0 then
		-- 	Panel_ClimbResult:setVisible(true)
		-- end
		local Panel_ClimbResult = TFDirector:getChildByPath(resultPanel, "Panel_ClimbResult")
		Panel_ClimbResult:setVisible(true)
		local floorOptionNow = NorthClimbManager:getNowFloorOption()
		for i=1,2 do
			local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan"..i)
			if floorOptionNow[i] == nil then
				img_tiaozhan:setVisible(false)
			else
				local txt_neirong = TFDirector:getChildByPath(img_tiaozhan, "txt_neirong")
				local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
				img_tiaozhan:setVisible(true)
				img_gou:setVisible(false)
				local battleInfo = BattleLimitedData:objectByID(floorOptionNow[i])
				txt_neirong:setText(battleInfo:getDescribe())
				txt_neirong:setTextAreaSize(CCSizeMake(270,0))
				if nResult ~= 0 then
					img_gou:setTexture("ui_new/fightresult/img_gouda.png")
				else
					local complete = bit_and(self.fightResultInfo.rank,2^(i-1))
					if complete == 0 then
						img_gou:setTexture("ui_new/fightresult/img_xda.png")
					else
						img_gou:setTexture("ui_new/fightresult/img_gouda.png")
					end
				end
			end
		end
		if nResult ~= 0 then
			local img_baoshou = TFDirector:getChildByPath(Panel_ClimbResult, "img_baoshou")
			if #floorOptionNow == 0 then
				img_baoshou:setVisible(true)
			else
				img_baoshou:setVisible(false)
			end
		else
			NorthClimbManager.isFail = true
			local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan3")
			local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
			img_tiaozhan:setVisible(true)
			img_gou:setVisible(false)
			local complete = bit_and(self.fightResultInfo.rank,2^(3-1))
			if complete == 0 then
				img_gou:setTexture("ui_new/fightresult/img_xda.png")
			else
				img_gou:setTexture("ui_new/fightresult/img_gouda.png")
			end
		end
	end

	local itemRewardBg = TFDirector:getChildByPath(self.ui, "itemRewardBg")
	itemRewardBg:setVisible(false)
	for i=1,5 do
		local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..i)
		itemQualityImg:setVisible(false)
	end

	if fightType == 9 and nResult ~= 0 then --血战
		self:ShowRoleHp()
		local bloodLabel = TFDirector:getChildByPath(self.ui, "bloodLabel")
		bloodLabel:setVisible(true)
	else
		self:ShowRoleExp()
	end
	self:ShowTeamExp()

	local panelPos = resultPanel:getPosition()
	resultPanel:setPosition(ccp(GameConfig.WS.width, panelPos.y))
	local moveTween = 
	{
		target = resultPanel,
		{
			duration = 0.3,
			x = panelPos.x,
			y = panelPos.y,

			onComplete = function ()
				if fightType == 3 or fightType == 5 or fightType == 9 or fightType == 12 or fightType == 16 then
					self:ShowRewardPanel()
					self:showNorthClimbAction()
					self:showSouthClimbAction()
				else
					if nResult == 0 then
						self:ShowRewardPanel()
					else
						self:PlayStarAnimation()
						self.updateTimerID = TFDirector:addTimer(20, -1, nil, 
						function() 
							self:UpdateExpPercent()
						end)
					end
				end
			end
		},
	}
	TFDirector:toTween(moveTween)
end


function FightResultLayer:showNorthClimbAction()
	if  FightManager.fightBeginInfo.fighttype ~= 16 then
		return
	end

	local nResult = self.fightResultInfo.result
	local resultPanel = nil
	if nResult == 0 then
		resultPanel = self.failPanel
	else
		resultPanel = self.rewardPanel
	end
	local Panel_ClimbResult = TFDirector:getChildByPath(resultPanel, "Panel_ClimbResult")
	local floorOptionNow = NorthClimbManager:getNowFloorOption()
	for i=1,2 do
		local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan"..i)
		if floorOptionNow[i] then
			local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
			img_gou:setVisible(true)
			self:_showNorthClimbAction(img_gou)
		end
	end
	if nResult == 0 then
		local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan3")
		local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
		img_gou:setVisible(true)
		self:_showNorthClimbAction(img_gou)
	end

end

function FightResultLayer:_showNorthClimbAction( target )
	target:setScale(5)
	local moveTween =
	{
		target = target,
		{
			duration = 0.1,
			scale = 0.9,
		},
		{
			duration = 0.1,
			scale = 1,
		}
	}
	TFDirector:toTween(moveTween)
end


function FightResultLayer:showSouthClimbAction()
	if  FightManager.fightBeginInfo.fighttype ~= 5 then
		return
	end

	local nResult = self.fightResultInfo.result
	local resultPanel = nil
	if nResult == 0 then
		resultPanel = self.failPanel
	else
		resultPanel = self.rewardPanel
	end
	local Panel_ClimbResult = TFDirector:getChildByPath(resultPanel, "Panel_ClimbResult2")
	-- local floorOptionNow = NorthClimbManager:getNowFloorOption()


	for i=1,2 do
		local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan"..i)


		local complete = bit_and(self.fightResultInfo.rank,2^(i-1))
		if complete == 0 then
		else
			local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
			img_gou:setVisible(true)
			self:_showNorthClimbAction(img_gou)
		end
	end
	if nResult ~= 0 then
		local img_tiaozhan = TFDirector:getChildByPath(Panel_ClimbResult, "img_tiaozhan3")
		local img_gou = TFDirector:getChildByPath(img_tiaozhan, "img_gou")
		img_gou:setVisible(true)
		self:_showNorthClimbAction(img_gou)
	end

end

-- function FightResultLayer:_showNorthClimbAction( target )
-- 	target:setScale(5)
-- 	local moveTween =
-- 	{
-- 		target = target,
-- 		{
-- 			duration = 0.2,
-- 			scale = 0.9,
-- 		},
-- 		{
-- 			duration = 0.2,
-- 			scale = 1,
-- 		}
-- 	}
-- 	TFDirector:toTween(moveTween)
-- end


function FightResultLayer:ShowTeamExp()
	local fightType = FightManager.fightBeginInfo.fighttype
	local teamExpInfo = self.fightResultInfo.teamexp
	if fightType == 3 or fightType == 5 or fightType == 9 or fightType == 12 or fightType == 16 or teamExpInfo == nil then
		local teamExpBg = TFDirector:getChildByPath(self.ui, "teamExpBg")
		teamExpBg:setVisible(false)
		return
	end

	local teamLevLabel = TFDirector:getChildByPath(self.ui, "teamLevLabel")
	teamExpInfo.currShowLev = teamExpInfo.oldLev
	teamLevLabel:setText(teamExpInfo.currShowLev)

	local teamExpLabel = TFDirector:getChildByPath(self.ui, "teamExpLabel")
	--teamExpLabel:setText("经验+"..teamExpInfo.addExp)
	teamExpLabel:setText(stringUtils.format(localizable.common_exp_add, teamExpInfo.addExp))

	local teamExpBar = TFDirector:getChildByPath(self.ui, "teamExpBar")

	local oldMaxExp = LevelData:getMaxPlayerExp(teamExpInfo.oldLev)
	local currMaxExp = LevelData:getMaxPlayerExp(teamExpInfo.currLev)
	local startPercent = math.floor(teamExpInfo.oldExp/oldMaxExp*100)
	teamExpBar:setPercent(startPercent)

	teamExpInfo.nEndPercent = math.floor(teamExpInfo.currExp/currMaxExp * 100)
	teamExpInfo.nEndPercent = math.min(teamExpInfo.nEndPercent, 100)
end

function FightResultLayer:ShowRoleExp()
	for i=1,5 do
		local rolePanel = TFDirector:getChildByPath(self.ui, "roleImg"..i)
		rolePanel:setVisible(false)
	end
	
	if self.fightResultInfo.explist == nil then
		return
	end

	local nExpCount = #self.fightResultInfo.explist
	for i=1, nExpCount do
		local expInfo = self.fightResultInfo.explist[i]
		local cardRole = CardRoleManager:getRoleById(expInfo.typeid)
		if cardRole == nil and expInfo.typeid > 0 then
			assert(false)
			break
		end

		local rolePanel = TFDirector:getChildByPath(self.ui, "roleImg"..i)
		if rolePanel == nil then
			return
		end
		
		rolePanel:setVisible(true)

		local qualityImg = TFDirector:getChildByPath(rolePanel, "qualityImg")
		qualityImg:setTexture(GetColorIconByQuality_82(cardRole.quality))				
		-- 背景修改为根据武学
		-- local cardRoleTmp = CardRoleManager:getRoleById(cardRole.id)
		-- local martialLevel = cardRole.martialLevel
		-- qualityImg:setTexture(GetColorIconByQuality(cardRole.quality))
		-- qualityImg:setScale(94/110)
		-- end

		local roleIcon = TFDirector:getChildByPath(rolePanel, "iconImg")
		roleIcon:setTexture(cardRole.icon)
		roleIcon:setRotationY(180)

		local levelLabel = TFDirector:getChildByPath(rolePanel, "levelLabel")
		expInfo.currShowLev = expInfo.oldLev
		levelLabel:setText("lv."..expInfo.currShowLev)
		
		local expLabel = TFDirector:getChildByPath(rolePanel, "expLabel")
		--expLabel:setText("经验+"..expInfo.addExp)
		expLabel:setText(stringUtils.format(localizable.common_exp_add, expInfo.addExp))

		local expBar = TFDirector:getChildByPath(rolePanel, "expBar")
		local oldMaxExp = LevelData:getMaxRoleExp(expInfo.oldLev)

		local currMaxExp = LevelData:getMaxRoleExp(expInfo.currLev)
		local startPercent = math.floor(expInfo.oldExp/oldMaxExp*100)
		expBar:setPercent(startPercent)

		expInfo.nEndPercent = math.floor(expInfo.currExp/currMaxExp * 100)
		expInfo.nEndPercent = math.min(expInfo.nEndPercent, 100)

		local totalAddPercent = 0
		if expInfo.currLev == expInfo.oldLev then
			totalAddPercent = expInfo.nEndPercent - startPercent
		elseif expInfo.currLev > expInfo.oldLev then
			totalAddPercent = 100 - startPercent + (expInfo.currLev-expInfo.oldLev-1)*100 + expInfo.nEndPercent
		end

		expInfo.addPercentOneTime = 2
		if totalAddPercent <= 50 then
			expInfo.addPercentOneTime = 2
		elseif totalAddPercent > 50 and totalAddPercent <= 200 then
			expInfo.addPercentOneTime = 4
		else
			expInfo.addPercentOneTime = 6
		end
	end
end

function GetRoleTypeId(posindex)
	for k,v in pairs(FightManager.fightBeginInfo.rolelist) do
		if v.posindex == posindex then
			return v.roleId
		end
	end
	return 0
end

function GetRoleMaxHp(posindex)
	for k,v in pairs(FightManager.fightBeginInfo.rolelist) do
		if v.posindex == posindex then
			return v.attr[1]
		end
	end
	return 0
end

function FightResultLayer:ShowRoleHp()
	for i=1,5 do
		local rolePanel = TFDirector:getChildByPath(self.ui, "roleImg"..i)
		rolePanel:setVisible(false)
	end

	local liveList = FightManager.lastEndFightMsg[4]
	local selfLiveList = {}
	for i=1,#liveList do
		local liveInfo = liveList[i]
		-- print("liveInfo[2] 000000== ",liveInfo[2])
		if liveInfo[1] < 9 and liveInfo[2] > 0 then
			-- print("liveInfo[2] == ",liveInfo[2])
			local info = {}
			info.roleId = GetRoleTypeId(liveInfo[1])
			local maxHp = GetRoleMaxHp(liveInfo[1])
			info.addhp = math.floor(maxHp*0.05)
			info.currhp = (liveInfo[2] + info.addhp) <= maxHp and (liveInfo[2] + info.addhp) or maxHp
			info.maxhp = maxHp
			selfLiveList[#selfLiveList+1] = info
		end
	end

	for i=1, #selfLiveList do
		local hpInfo = selfLiveList[i]
		local roleInfo = RoleData:objectByID(hpInfo.roleId)
		if roleInfo == nil and hpInfo.roleId > 0 then
			assert(false)
			break
		end

		local rolePanel = TFDirector:getChildByPath(self.ui, "roleImg"..i)
		if rolePanel == nil then
			break
		end

		rolePanel:setVisible(true)
		-- local quality = roleInfo.quality
		local qualityImg = TFDirector:getChildByPath(rolePanel, "qualityImg")
		qualityImg:setTexture(GetColorIconByQuality_82(roleInfo.quality))
		-- local martialLevel = cardRole.martialLevel
		-- qualityImg:setTexture(GetFightRoleBgByWuXueLevel(martialLevel))
		-- qualityImg:setScale(94/110)

		local roleIcon = TFDirector:getChildByPath(rolePanel, "iconImg")
		roleIcon:setTexture(roleInfo:getIconPath())

		local levelLabel = TFDirector:getChildByPath(rolePanel, "levelLabel")
		--levelLabel:setText("剩余血量")
		levelLabel:setText(localizable.common_left_hp)
		
		local expLabel = TFDirector:getChildByPath(rolePanel, "expLabel")
		--expLabel:setText("血量+"..hpInfo.addhp)
		expLabel:setText(stringUtils.format(localizable.common_hp_add, hpInfo.addhp))

		local expBar = TFDirector:getChildByPath(rolePanel, "expBar")
		local percent = math.floor(hpInfo.currhp/hpInfo.maxhp*100)
		expBar:setPercent(percent)
	end
end

function FightResultLayer:UpdateExpPercent()
	local bExpPercentEnd = true
	for i=1, 5 do
		local rolePanel = TFDirector:getChildByPath(self.ui, "roleImg"..i)
		if rolePanel == nil or rolePanel:isVisible() == false then
			break
		end

		local expInfo = self.fightResultInfo.explist[i]
		local expBar = TFDirector:getChildByPath(rolePanel, "expBar")

		local percent = expBar:getPercent()
		if expInfo.currShowLev >= expInfo.currLev and percent >= expInfo.nEndPercent then
		else
			if percent >= 100 then
				expInfo.currShowLev = expInfo.currShowLev + 1
				if expInfo.currShowLev == expInfo.currLev then
					self:PlayUplevEffect(rolePanel, false)
				else
					self:PlayUplevEffect(rolePanel, true)
				end
				percent = 0
				local levelLabel = TFDirector:getChildByPath(rolePanel, "levelLabel")
				levelLabel:setText("lv."..expInfo.currShowLev)
			end
			expBar:setPercent(percent+expInfo.addPercentOneTime)
			bExpPercentEnd = false
		end
	end

	local teamExpBar = TFDirector:getChildByPath(self.ui, "teamExpBar")
	if teamExpBar:isVisible() then
		local teamExpInfo = self.fightResultInfo.teamexp
		
		-- add by king
		if teamExpInfo ~= nil then
			local percent = teamExpBar:getPercent()
			if teamExpInfo.currShowLev >= teamExpInfo.currLev and percent >= teamExpInfo.nEndPercent then
			else
				if percent >= 100 then
					percent = 0 
					teamExpInfo.currShowLev = teamExpInfo.currShowLev + 1
					local teamLevLabel = TFDirector:getChildByPath(self.ui, "teamLevLabel")
					teamLevLabel:setText(teamExpInfo.currShowLev)
				end
				teamExpBar:setPercent(percent+1)
				bExpPercentEnd = false
			end
		end

		-- local percent = teamExpBar:getPercent()
		-- if teamExpInfo.currShowLev >= teamExpInfo.currLev and percent >= teamExpInfo.nEndPercent then
		-- else
		-- 	if percent >= 100 then
		-- 		percent = 0 
		-- 		teamExpInfo.currShowLev = teamExpInfo.currShowLev + 1
		-- 		local teamLevLabel = TFDirector:getChildByPath(self.ui, "teamLevLabel")
		-- 		teamLevLabel:setText(teamExpInfo.currShowLev)
		-- 	end
		-- 	teamExpBar:setPercent(percent+1)
		-- 	bExpPercentEnd = false
		-- end
	end

	if bExpPercentEnd then
		TFDirector:removeTimer(self.updateTimerID)
		self.updateTimerID = nil
		self:ShowRewardPanel()
	end
end

function FightResultLayer:ShowRewardPanel()
	local itemRewardBg = TFDirector:getChildByPath(self.ui, "itemRewardBg")
	if itemRewardBg == nil or itemRewardBg:isVisible() then
		return
	end

	local resCount = self:ShowRewardRes()
	local itemCount = self:ShowRewardItem()
	if itemCount > 0 then
		self:PlayItemEffect(1)
	end

	if resCount == 0 and itemCount == 0 then
		itemRewardBg:setVisible(false)
	else
		itemRewardBg:setVisible(true)
	end
	if fightType == 11 then --逗比策划说切磋没有奖励但是要把获得奖励面板打开
		itemRewardBg:setVisible(true)
	end
	if nResult ~= 0 and fightType == 12 then --逗比策划说切磋没有奖励但是要把获得奖励面板打开
		itemRewardBg:setVisible(true)
	end

	print("--------------->>>>>>>>>>>>>>>>> ShowRewardPanel")
	self:ShowButton(true)

	if fightType == 18 then
		self.replayBtn:setVisible(false)
	end
end

function FightResultLayer:PlayItemEffect(itemIndex)
	local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..itemIndex)
	if itemQualityImg == nil or itemQualityImg:isVisible() == false then
		return
	end

	local effectName = "fightitem"
	TFResourceHelper:instance():addArmatureFromJsonFile("effect/"..effectName..".xml")
	local effect = TFArmature:create(effectName.."_anim")
	effect:setAnimationFps(GameConfig.ANIM_FPS)
	effect:playByIndex(0, -1, -1, 0)
	effect:setZOrder(100)
	effect:setPosition(ccp(40, 40))
	itemQualityImg:addChild(effect)

	effect:addMEListener(TFARMATURE_COMPLETE, function()
		self:PlayItemEffect(itemIndex+1)
		effect:removeFromParent()
	end)
end

function FightResultLayer:ShowRewardRes()
	local resCount = 0
	if self.fightResultInfo.reslist ~= nil then
		resCount = #self.fightResultInfo.reslist
	end

	self.itemIndex = 1

	for i=1,resCount do
		local resInfo = self.fightResultInfo.reslist[i]
		local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..i)
		local itemIcon = TFDirector:getChildByPath(itemQualityImg, "itemIcon")

		itemQualityImg:setTexture(GetResourceQualityBG82(resInfo.type))
		itemQualityImg:setVisible(true)
		local resIconImg = GetResourceIcon(resInfo.type)
		itemIcon:setTexture(resIconImg)
		itemIcon:setScale(1.2)
		itemQualityImg:setVisible(true)
		itemIcon:setTouchEnabled(true)
		itemIcon:addMEListener(TFWIDGET_CLICK,
		audioClickfun(function()
			Public:ShowItemTipLayer(resInfo.itemid, resInfo.type, resInfo.num)
		end))

		local numLabel = TFLabelBMFont:create()
        numLabel:setFntFile("font/new/num_lv.fnt")
        numLabel:setScale(0.7)
        numLabel:setPosition(ccp(0, -50))
        itemQualityImg:addChild(numLabel)
        numLabel:setText("X"..resInfo.num)

        self.itemIndex = self.itemIndex + 1

	end

	return resCount
end

function FightResultLayer:ShowRewardItem()
	local itemCount = 0
	if self.fightResultInfo.itemlist ~= nil then
		itemCount = #self.fightResultInfo.itemlist
	end

	for i=1,itemCount do
		local itemQualityImg = TFDirector:getChildByPath(self.ui, "itemImg"..self.itemIndex)
		itemQualityImg:setVisible(true)
		self.itemIndex = self.itemIndex + 1

		local itemIcon = TFDirector:getChildByPath(itemQualityImg, "itemIcon")
		itemIcon:setScale(0.7)

		local itemInfo = self.fightResultInfo.itemlist[i]
		if itemInfo.type == 1 then
			local itemData = ItemData:objectByID(itemInfo.itemid)
			if itemData ~= nil then
				itemQualityImg:setTexture(GetColorIconByQuality_82(itemData.quality))
				itemIcon:setTexture(itemData:GetPath())
				itemIcon:setTouchEnabled(true)
				itemIcon:addMEListener(TFWIDGET_CLICK,
			    audioClickfun(function()
			        Public:ShowItemTipLayer(itemInfo.itemid, itemInfo.type)
			    end))

			    local numLabel = TFLabelBMFont:create()
			    numLabel:setFntFile("font/new/num_lv.fnt")
			    numLabel:setScale(0.7)
			    numLabel:setPosition(ccp(0, -50))
			    itemQualityImg:addChild(numLabel)
			    numLabel:setText("X"..itemInfo.num)
			end

			Public:addPieceImg(itemIcon, itemInfo)
			
		elseif itemInfo.type == 2 then
			local cardData = RoleData:objectByID(itemInfo.itemid)
			if cardData ~= nil then
				itemQualityImg:setTexture(GetColorIconByQuality_82(cardData.quality))
				itemIcon:setTexture(cardData:getIconPath())
				itemIcon:setTouchEnabled(true)
				itemIcon:addMEListener(TFWIDGET_CLICK,
			    audioClickfun(function()
			        Public:ShowItemTipLayer(itemInfo.itemid, itemInfo.type)
			    end))

			    local numLabel = TFLabelBMFont:create()
			    numLabel:setFntFile("font/new/num_lv.fnt")
			    numLabel:setScale(0.7)
			    numLabel:setPosition(ccp(0, -50))
			    itemQualityImg:addChild(numLabel)
			    numLabel:setText("X"..itemInfo.num)
			end
		end


        --秘籍添加红点 king
    	CommonManager:setRedPoint(itemIcon, MartialManager:dropRewardRedPoint(itemInfo), "dropRewardRedPoint", ccp(10,10))
	end

	return itemCount
end

function FightResultLayer:uiClickHandle()
	self:ShowRewardPanel()
end

function FightResultLayer.relayClickHandle(btn)
	FightManager:ReplayFight()
end
function FightResultLayer.hurtCountClickHandle(btn)
	FightManager:openHurtCount()
end

function FightResultLayer.leaveBtnHandle(btn)
	local self = btn.logic
	if FightManager:isHasSecondFight() then

		if self.fightResultInfo.rank  and self.fightResultInfo.rank == 1 then
			AdventureManager:startSecondBattle()
			return
		end
		if FightManager.isReplayFight then
			local reportId = AdventureManager:getNextReportId()
			print("reportId = ",reportId)
			if reportId and reportId ~= 0 then
				AdventureManager.openNextRecordId = nil
				AdventureManager:openSecondFightReport( reportId )
				return
			end
		end
		FightManager:LeaveFight()
	else
		FightManager:LeaveFight()
	end
end

return FightResultLayer
