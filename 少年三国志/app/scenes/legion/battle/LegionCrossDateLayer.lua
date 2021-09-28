--LegionCrossDateLayer.lua

require("app.cfg.corps_fight_buff_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"


local LegionCrossDateLayer = class("LegionCrossDateLayer", UFCCSNormalLayer)



function LegionCrossDateLayer.create( ... )
	return LegionCrossDateLayer.new("ui_layout/Legion_CrossDateLayer.json")
end

function LegionCrossDateLayer:ctor( ... )
	self._countDownTime = 0
	self._crossSectionIndex = 0
	self._waitingCD = 0
	self._timer = nil
	self._curAttackCount = 0
	self._totalAttackCount = 0
	self._curHpCount = 0
	self._totalHpCount = 0
	self._applyCorpList = nil

	self.super.ctor(self, ...)
end

function LegionCrossDateLayer:onLayerLoad( ... )
	-- local CROSS_TIME = require("app.data.LegionData")._CROSS_TIME
	-- local timeFormat = "%02d:%02d-%02d:%02d"
	-- self:showTextWithLabel("Label_time_baoming", string.format(timeFormat, 
	-- 	0, 0, CROSS_TIME.BAOMING_END_HOUR, CROSS_TIME.BAOMING_END_MIN) )
	-- self:showTextWithLabel("Label_time_pipei", string.format(timeFormat, 
	-- 	CROSS_TIME.BAOMING_END_HOUR, CROSS_TIME.BAOMING_END_MIN, CROSS_TIME.PIPEI_END_HOUR, CROSS_TIME.PIPEI_END_MIN) )
	-- self:showTextWithLabel("Label_time_kaizhan", string.format(timeFormat, 
	-- 	CROSS_TIME.PIPEI_END_HOUR, CROSS_TIME.PIPEI_END_MIN, CROSS_TIME.FIGHT_END_HOUR, CROSS_TIME.FIGHT_END_MIN) )

	self:_initCorpCrossTimeInfo()

	self:enableLabelStroke("Label_result_title", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_price_gongji", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_price_shengming", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_title_baoming", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_time_baoming", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_guwu", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_result", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_dynamic", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_tip_pipei", Colors.strokeBrown, 1)

	self:registerBtnClickEvent("Button_back", handler(self, self._onBackClick))
	self:registerBtnClickEvent("Button_detail", handler(self, self._onMemberResultClick))
	self:registerBtnClickEvent("Button_help", handler(self, self._onHelpClick))
	self:registerBtnClickEvent("Button_baoming", handler(self, self._onBaomingClick))
	self:registerBtnClickEvent("Button_cancel_baoming", handler(self, self._onCancelBaomingClick))
	self:registerBtnClickEvent("Button_member_result", handler(self, self._onCrossBattleResultClick))
	--self:registerBtnClickEvent("Button_guwu_gongji", handler(self, self._onEncourageGongjiClick))
	--self:registerBtnClickEvent("Button_guwu_shengming", handler(self, self._onEncourageHpClick))

	self:_onCrossStatusRefresh()

	G_HandlersManager.legionHandler:sendGetCorpCrossBattleList()

	if G_Me.legionData:isOnMatch() and G_Me.legionData:isMatchFinish() then 
		G_HandlersManager.legionHandler:sendGetCrossBattleEncourage()
	end
end

function LegionCrossDateLayer:onLayerEnter( ... )
	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
	self:showWidgetByName("Panel_top", false)
	self:callAfterFrameCount(1, function ( ... )
	self:showWidgetByName("Panel_top", true)
			GlobalFunc.flyIntoScreenLR( { self:getWidgetByName("Panel_top") }, false, 0.4, 2, 100)	
	end)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_TIMES, self._onBattleTimeChange, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_APPLY_INFO, self._onCrossStatusRefresh, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_BROADCAST_BATTLE_STATUS, self._onCrossStatusRefresh, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_APPLY_BATTLE_STATUS_CHANGE, self._onCrossApplyInfoChange, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_ENCOURAGE_INFO, self._onUpdateEncourageInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_ENCOURAGE_BATTLE, self._onEncourageResult, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_ENCOURAGE_INFO, self._onUpdateEncourageInfo, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_FIELD, self._onBattleFieldChange, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_BROADCAST_BATTLE_FIELD, self._onBattleFieldChange, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_LIST, self._onRefreshApplyList, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_FLUSH_BATTLE_CORP, self._onRefreshApplyList, self)

end

function LegionCrossDateLayer:onLayerExit( ... )
	self:_removeTimer()
	self:_removeWaitingTimer()
end

function LegionCrossDateLayer:_onBackClick( ... )
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
		uf_sceneManager:popScene()
	else
		uf_sceneManager:replaceScene(require("app.scenes.legion.LegionScene").new())
	end
end

function LegionCrossDateLayer:_onHelpClick( ... )
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_LEGION_CROSS_HELP_TITLE_1"), content=G_lang:get("LANG_LEGION_CROSS_HELP_CONTENT_1")},
		{title=G_lang:get("LANG_LEGION_CROSS_HELP_TITLE_2"), content=G_lang:get("LANG_LEGION_CROSS_HELP_CONTENT_2")},})
end

function LegionCrossDateLayer:_onBaomingClick( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if not detailCorp or detailCorp.position < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_APPLY_RIGHT_1"))
	--elseif detailCorp.size < 3 then 
	--	return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_ENOUGH_MEMBER"))
	end

	G_HandlersManager.legionHandler:sendApplyCorpCrossBattle()
end

function LegionCrossDateLayer:_onCrossBattleResultClick( ... )
    require("app.scenes.legion.battle.LegionCrossResultLayer").show()
end

function LegionCrossDateLayer:_onCancelBaomingClick( ... )
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if not detailCorp or detailCorp.position < 1 then 
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_NO_APPLY_RIGHT_2"))
	end

	G_HandlersManager.legionHandler:sendQuitCorpCrossBattle()
end

function LegionCrossDateLayer:_onMemberResultClick( ... )
    require("app.scenes.legion.battle.LegionCrossDistrictDetailLayer").show()
end

function LegionCrossDateLayer:_onEncourageGongjiClick( ... )	
	local buffInfo = corps_fight_buff_info.get(2)
	local costGold = (self._totalAttackCount + 1)*(buffInfo and buffInfo.gold or 10)
	if costGold > G_Me.userData.gold then
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	G_HandlersManager.legionHandler:sendCrossBattleEncourage(true)
end

function LegionCrossDateLayer:_onEncourageHpClick( ... )	
	local buffInfo = corps_fight_buff_info.get(1)
	local costGold = (self._totalHpCount + 1)*(buffInfo and buffInfo.gold or 10)
	if costGold > G_Me.userData.gold then
		return require("app.scenes.shop.GoldNotEnoughDialog").show()
	end

	G_HandlersManager.legionHandler:sendCrossBattleEncourage(false)
end

function LegionCrossDateLayer:_onCrossApplyInfoChange( ret, hasApply )
	if type(ret) ~= "number" or ret ~= 1 then 
		return 
	end

	G_MovingTip:showMovingTip(G_lang:get(hasApply and "LANG_LEGION_CROSS_APPLY_JOIN_SUCCESS" or "LANG_LEGION_CROSS_APPLY_EXIT_SUCCESS"))
	self:_initSectionStatus()
end

function LegionCrossDateLayer:_onBattleFieldChange( ... )
	self:_initSectionStatus()
	self:_onCrossStatusRefresh()
end

function LegionCrossDateLayer:_onRefreshApplyList( ... )
	self:showWidgetByName("Label_nobaoming_tip", G_Me.legionData:getCrossApplyCount() < 1)
	if not self._applyCorpList then
        firstLoad = true 
		local panel = self:getPanelByName("Panel_legion_list")
		if panel == nil then
			return 
		end

		self._applyCorpList = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
    	self._applyCorpList:setCreateCellHandler(function ( list, index)
    	    return require("app.scenes.legion.battle.LegionCrossApplyItem").new(list, index)
    	end)
    	self._applyCorpList:setUpdateCellHandler(function ( list, index, cell)
    		if cell then 
    			cell:updateItem(index + 1)
    		end
    	end)
    	self._applyCorpList:setSelectCellHandler(function ( cell, index )
    	end)
	end
    self._applyCorpList:reloadWithLength(G_Me.legionData:getCrossApplyCount(), self._applyCorpList:getShowStart())
end

function LegionCrossDateLayer:_onBattleTimeChange( ... )
	self:_initCorpCrossTimeInfo()
	self:_updateWaitingCD()
end

function LegionCrossDateLayer:_initCorpCrossTimeInfo( ... )
	local _showTimeSection = function ( label, start, close )
		if type(start) == "number" and type(close) == "number" then
			local startTime = G_ServerTime:getDateObject(start)
			local endTime = G_ServerTime:getDateObject(close)
		--	local startTime = os.date("*t", start)	
		--	local endTime = os.date("*t", close)	
			local timeFormat = "%02d:%02d-%02d:%02d"

			self:showTextWithLabel(label, string.format(timeFormat, 
			 	startTime.hour, startTime.min, endTime.hour, endTime.min) )
		end
	end
	
	local battleTime = G_Me.legionData:getBattleTimeByStatus(2)
	_showTimeSection("Label_time_baoming", 
		battleTime and battleTime.start or nil, battleTime and battleTime.close or nil)
	battleTime = G_Me.legionData:getBattleTimeByStatus(3)
	_showTimeSection("Label_time_pipei",  
		battleTime and battleTime.start or nil, battleTime and battleTime.close or nil)
	battleTime = G_Me.legionData:getBattleTimeByStatus(4)
	_showTimeSection("Label_time_kaizhan",  
		battleTime and battleTime.start or nil, battleTime and battleTime.close or nil)
end

function LegionCrossDateLayer:_onUpdateEncourageInfo( ... )
	local encourageInfo = G_Me.legionData:getEncourageInfo()

	-- self:showTextWithLabel("Label_baoming_gongji", G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_ATTACK_FORMAT", 
	-- 	{value=5}) )
	local buffInfo = corps_fight_buff_info.get(2)
	local count = (encourageInfo and encourageInfo.total_atk_count) and encourageInfo.total_atk_count or 0
	local guwuCount = (encourageInfo and encourageInfo.atk_count ) and encourageInfo.atk_count or 0

	self:showTextWithLabel("Label_leiji_gongji", G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_ATTACK_FORMAT", 
		{value=string.format("%.1f", count*0.5)}) )
	self:showTextWithLabel("Label_guwu_gongji", count.."/"..(buffInfo and buffInfo.max) )

	self._curAttackCount  = guwuCount
	self._totalAttackCount = count
	local reachTopest = (buffInfo and self._totalAttackCount >= buffInfo.max) or (buffInfo and self._curAttackCount >= buffInfo.number)
	if reachTopest then 
		self:showWidgetByName("Button_guwu_gongji", false)
		self:showWidgetByName("Image_gongji_topest", true)
	else
		self:showTextWithLabel("Label_price_gongji", (guwuCount + 1)*(buffInfo and buffInfo.gold or 10) )	
		self:registerBtnClickEvent("Button_guwu_gongji", function ( ... )
		--__Log("guwu:attack:count=%d, max=%d, guwuCount:%d, max:%d", count, buffInfo.max, guwuCount, buffInfo.number)
			if buffInfo and self._totalAttackCount >= buffInfo.max then
				return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_TO_MAX"))
			elseif buffInfo and self._curAttackCount >= buffInfo.number then
				return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_TO_MAX_SINGLE", {timeValue=buffInfo.number}))
			end
			self:_onEncourageGongjiClick()
		end)
	end

	-- self:showTextWithLabel("Label_baoming_shengming", G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_HP_FORMAT", 
	-- 	{value=5}) )
	count = (encourageInfo and encourageInfo.total_hp_count) and encourageInfo.total_hp_count or 0
	guwuCount = (encourageInfo and encourageInfo.hp_count ) and encourageInfo.hp_count or 0
	self._curHpCount  = guwuCount
	self._totalHpCount = count

	buffInfo = corps_fight_buff_info.get(1)
	self:showTextWithLabel("Label_leiji_shengming", G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_HP_FORMAT", 
		{value=string.format("%.1f", count*0.5)}) )
	self:showTextWithLabel("Label_guwu_shengming", count.."/"..(buffInfo and buffInfo.max) )

	local reachTopest = (buffInfo and self._totalHpCount >= buffInfo.max) or (buffInfo and self._curHpCount >= buffInfo.number)
	if reachTopest then 
		self:showWidgetByName("Button_guwu_shengming", false)
		self:showWidgetByName("Image_shengming_topest", true)
	else
		self:showTextWithLabel("Label_price_shengming", (guwuCount + 1)*(buffInfo and buffInfo.gold or 10))
		self:registerBtnClickEvent("Button_guwu_shengming", function ( ... )
		--__Log("guwu:hp:count=%d, max=%d, guwuCount:%d, max:%d", count, buffInfo.max, guwuCount, buffInfo.number)
			if buffInfo and self._totalHpCount >= buffInfo.max then
				return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_TO_MAX"))
			elseif buffInfo and self._curHpCount >= buffInfo.number then
				return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_TO_MAX_SINGLE", {timeValue=buffInfo.number}))
			end

			self:_onEncourageHpClick()
		end)
	end
end

function LegionCrossDateLayer:_onEncourageResult( ret, eType, success )
	if success then 
		eType = eType or 1
		G_flyAttribute.addNormalText(G_lang:get(eType == 1 and "LANG_LEGION_CROSS_ENCOURAGE_HP_SUCCESS" or "LANG_LEGION_CROSS_ENCOURAGE_ATTACK_SUCCESS"),
			Colors.titleGreen, self:getLabelByName(eType == 1 and "Label_leiji_shengming" or "Label_leiji_gongji"))
		G_flyAttribute.play(function ( ... )
		end)
		--G_MovingTip:showMovingTip(G_lang:get(eType == 1 and "LANG_LEGION_CROSS_ENCOURAGE_HP_SUCCESS" or "LANG_LEGION_CROSS_ENCOURAGE_ATTACK_SUCCESS"))
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_ENCOURAGE_FAILED"))
	end

	self:_onUpdateEncourageInfo()
end

function LegionCrossDateLayer:_onCrossStatusRefresh() 
	self:_initTimer()
end

function LegionCrossDateLayer:_removeTimer( ... )
	if self._timer then 
		G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
	end
end

function LegionCrossDateLayer:_initTimer( ... )
	local timeSection, countdown = G_Me.legionData:getLegionSectionAndCountDown()

	local t = G_ServerTime:getDateObject()
	--local t = os.date("*t", G_ServerTime:getTime())
	__Log("timeSection:%d, countdown:%d, nowis:[%d:%d:%d]", timeSection, countdown, t.hour, t.min, t.sec)
	self:_initSectionStatus()

	self._countDownTime = countdown
	local _updateTime = function ( ... )
		if self._countDownTime < 0 then 
			self._countDownTime = 0
			return self:_initTimer()
		end
		local min = math.floor((self._countDownTime%3600)/60)
		local sec = self._countDownTime%60
		self:showTextWithLabel("Label_tip_down", G_lang:get("LANG_LEGION_CROSS_PIPEI_FORMAT", {minValue=min, secValue=sec}))
		self._countDownTime = self._countDownTime - 1	
	end

	if G_Me.legionData:isOnMatch() and timeSection == 3 and self._countDownTime > 0 then 
		_updateTime()
	end	

	self:_removeTimer()
	if self._countDownTime > 0 then
		self._timer = G_GlobalFunc.addTimer(G_Me.legionData:isOnMatch() and 1 or self._countDownTime, function()
			if G_Me.legionData:isOnMatch() then
				if _updateTime then 
					_updateTime()
				end
			else
				self:_initTimer()
			end
		end)
	end
end

function LegionCrossDateLayer:_initSectionStatus( ... )
	local hasDateing = G_Me.legionData:hasApply()
	local isDateingStatus = G_Me.legionData:isOnApply()
	local isMatchingStatus = G_Me.legionData:isOnMatch()
	local matchFinish = G_Me.legionData:isMatchFinish()
	local isOnBattleStatus = G_Me.legionData:isOnBattle()
	local isBattleFinishStatus = G_Me.legionData:isBattleFinish()
	local isOnWaiting = G_Me.legionData:isOnWaiting()

	-- hasDateing = true
	-- isDateingStatus = false
	-- isMatchingStatus = false
	-- matchFinish = true
	-- isBattleFinishStatus = true
	-- isOnBattleStatus = false

	if isMatchingStatus and matchFinish then 
		self:_onUpdateEncourageInfo()
	end

__Log("applyStats:%d, matchStats:%d, battleStats:%d, battleFinish:%d", 
	isDateingStatus and 1 or 0, isMatchingStatus and 1 or 0, isOnBattleStatus and 1 or 0, isBattleFinishStatus and 1 or 0)
__Log("hasApply:%d, hasMatch:%d", hasDateing and 1 or 0, matchFinish and 1 or 0)
	local showSectionPanel = isDateingStatus or isMatchingStatus or (isOnBattleStatus and not hasDateing)

	if isOnBattleStatus and hasDateing then
		return uf_sceneManager:replaceScene(require("app.scenes.legion.battle.LegionCrossMainScene").new())
	end

	self:showWidgetByName("Panel_content", not isOnWaiting)
	self:showWidgetByName("Panel_tip", isOnWaiting)
	self:showWidgetByName("Panel_up", showSectionPanel)
	self:showWidgetByName("Panel_baoming", isDateingStatus or (not hasDateing) or
	 (hasDateing and isMatchingStatus and not matchFinish))
	self:showWidgetByName("Panel_pipei", isMatchingStatus and matchFinish and hasDateing)
	self:showWidgetByName("Panel_result", isBattleFinishStatus)
	local showResult = isBattleFinishStatus and hasDateing
	self:showWidgetByName("Button_member_result", showResult)
	self:showWidgetByName("Image_result_title", showResult)
	self:showWidgetByName("Image_result", showResult)
	self:showWidgetByName("Image_overtime", (not isDateingStatus and not isBattleFinishStatus and not hasDateing))
	self:showWidgetByName("Label_overtime", (not isDateingStatus and isBattleFinishStatus and not hasDateing))
	self:showWidgetByName("Button_baoming", isDateingStatus and not hasDateing)
	self:showWidgetByName("Label_tip", isDateingStatus)
	self:showWidgetByName("Button_cancel_baoming", isDateingStatus and hasDateing)

	if isOnWaiting then 
		self:_updateWaitingCD()
	end

	if isDateingStatus then 
		self:_onRefreshApplyList()
	end

	if matchFinish then 
		self:showTextWithLabel("Label_tip_up", G_lang:get("LANG_LEGION_CROSS_DISTRICT_MATCH_FORMAT", {index=G_Me.legionData:getCrossField()}))
	end
	local showPipei = isMatchingStatus and hasDateing and not matchFinish
	self:showWidgetByName("Label_tip_pipei", showPipei)
	self:_loadingText("Label_tip_pipei", showPipei, G_lang:get("LANG_LEGION_CROSS_PIPEI_ING"))
	if showPipei then 
		EffectSingleMoving.run(self:getWidgetByName("Image_doing"), "smoving_shake", nil, {}, 1+ math.floor(math.random()*30))
	end
	
	local _changeActiveClr = function ( ctrlName, isActive )
		if type(ctrlName) ~= "string" then 
			return 
		end

		local label = self:getLabelByName(ctrlName)
		if label then 
			label:setColor(isActive and Colors.darkColors.DESCRIPTION or Colors.lightColors.DESCRIPTION)
			if isActive then
				label:createStroke(Colors.strokeBrown, 1)
			else
				label:removeStroke()
			end
		end
	end

	local img = nil
	if showSectionPanel then 
		img = self:getImageViewByName("Image_pipei")
		if img then 
			img:loadTexture((not isDateingStatus) and 
				"ui/legion/bg_pipei_dianliang.png" or "ui/legion/bg_pipei.png", UI_TEX_TYPE_LOCAL)
		end

		img = self:getImageViewByName("Image_kaizhan")
		if img then 
			img:loadTexture((not isDateingStatus and not isMatchingStatus) and 
				"ui/legion/bg_kaizhan_dianliang.png" or "ui/legion/bg_kaizhan.png", UI_TEX_TYPE_LOCAL)
		end

		_changeActiveClr("Label_title_pipei", not isDateingStatus)
		_changeActiveClr("Label_time_pipei", not isDateingStatus)
		_changeActiveClr("Label_title_kaizhan", (not isDateingStatus and not isMatchingStatus))
		_changeActiveClr("Label_time_kaizhan", (not isDateingStatus and not isMatchingStatus))
	end

	if hasDateing and isBattleFinishStatus then
		if G_Me.legionData:getBattleFieldCount() < 1 and not G_Me.legionData:isBattleFieldInit() then
			G_HandlersManager.legionHandler:sendGetCrossBattleField()
			uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_CROSS_REFRESH_BATTLE_FIELD, self._onUpdateBattleResult, self)
		else
			self:_onUpdateBattleResult()
		end
	end
end

function LegionCrossDateLayer:_onUpdateBattleResult( ... )
	local battleResult,finalExp = G_Me.legionData:calcBattleResult()

	-- battleResult = {{name="name1", sname="server1", rob_exp=50,robbed_exp=50},
	-- {name="name2", sname="server2", rob_exp=50,robbed_exp=150},
	-- {name="name3", sname="server3", rob_exp=150,robbed_exp=50},}
	-- finalExp = 88888

	local contentTitle = self:getLabelByName("Label_final_result")
	local contentList = self:getScrollViewByName("ScrollView_result")
	contentList:removeAllChildren()
	
	local scrollSize = contentList:getSize()
	local topY = 0
	local scrollItemHeight = 40

	local titleFormat = finalExp >= 0 and "LANG_LEGION_CROSS_CORP_RESULT_FORMAT_TITLE_WIN" or "LANG_LEGION_CROSS_CORP_RESULT_FORMAT_TITLE_FAIL"
	-- contentTitle:setText(G_lang:get(titleFormat,{expValue=finalExp}))
	local titleTxt = G_lang:get(titleFormat,{expValue=finalExp})
	contentTitle:setVisible(false)
	if not self._resultContentRichTitle then
		local label1 = CCSRichText:create(400, 40)
		label1:setFontName("ui/font/FZYiHei-M20S.ttf")
		label1:setFontSize(22)
		label1:setShowTextFromTop(true)
		contentTitle:getParent():addChild(label1)
		local posx,posy = contentTitle:getPosition()
		label1:setPositionXY(posx+20,posy+10)
		self._resultContentRichTitle = label1
	end
	self._resultContentRichTitle:appendContent(titleTxt, Colors.darkColors.DESCRIPTION)
	self._resultContentRichTitle:reloadData()

	local addTxt = function ( txt )
		local label1 = CCSRichText:create(scrollSize.width, scrollItemHeight)
    		label1:setFontName("ui/font/FZYiHei-M20S.ttf")
    		label1:setFontSize(22)
    		label1:setShowTextFromTop(true)
    		contentList:addChild(label1)
    		label1:appendContent(txt, Colors.darkColors.DESCRIPTION)
    		label1:reloadData()
    		
		local top = topY + scrollItemHeight/2
		label1:setPositionXY(scrollSize.width/2, top)
		topY = topY + scrollItemHeight*2/3
	end

	for key, value in pairs(battleResult) do 
		local descFinal = G_lang:get("LANG_LEGION_CROSS_CORP_RESULT_FORMAT_FINAL",{expValue=value.robbed_exp-value.rob_exp})
		addTxt(descFinal)
		local descTxt1 = G_lang:get("LANG_LEGION_CROSS_CORP_RESULT_FORMAT_WIN",{expValue=value.robbed_exp})
		local descTxt2 = G_lang:get("LANG_LEGION_CROSS_CORP_RESULT_FORMAT_FAIL",{expValue=value.rob_exp})
		addTxt(descTxt2)
		addTxt(descTxt1)
		local titleTxt = G_lang:get("LANG_LEGION_CROSS_CORP_RESULT_FORMAT_ENEMY",{serverName=value.sname,corpName=value.name})
		addTxt(titleTxt)
	end
	contentList:setInnerContainerSize(CCSizeMake(scrollSize.width,topY))
end

function LegionCrossDateLayer:_updateWaitingCD( ... )
	local waitingCD = G_Me.legionData:getWaitingCD()
	self._waitingCD = waitingCD or 0
	if waitingCD <= 0 then 
		self:showTextWithLabel("Label_tip_content", G_lang:get("LANG_LEGION_CROSS_WAIT_TIP", {dayValue=0, hourValue=0, minValue=0}))
		return 
	end

	local _updateTime = function ( ... )
		if self._waitingCD < 0 then 
			self._waitingCD = 0
			return self:_updateWaitingCD()
		end
		local hour = math.floor(self._waitingCD/3600)
		local day = math.floor(hour/24)
		hour = hour%24
		local min = math.ceil((self._waitingCD%3600)/60)
		local sec = self._waitingCD%60
		self:showTextWithLabel("Label_tip_content", G_lang:get("LANG_LEGION_CROSS_WAIT_TIP", {dayValue=day, hourValue=hour, minValue=min}))
		self._waitingCD = self._waitingCD - 1	
	end

	if G_Me.legionData:isOnWaiting() and self._waitingCD >= 0 then 
		_updateTime()
	end	

	self:_removeWaitingTimer()
	if self._waitingCD > 0 then
		self._waitingTimer = G_GlobalFunc.addTimer(60, function()
			if _updateTime then 
				_updateTime()
			end
		end)
	end
end

function LegionCrossDateLayer:_removeWaitingTimer( ... )
	if self._waitingTimer then 
		G_GlobalFunc.removeTimer(self._waitingTimer)
		self._waitingTimer = nil
	end
end

function LegionCrossDateLayer:_loadingText( ctrlName, loading, text )
	if type(ctrlName) ~= "string" then 
		return 
	end

	local label = self:getLabelByName(ctrlName)
	if not label then 
		return 
	end

	if not loading then 
		label:stopAllActions()
	else
		text = text or ""
		label:setText(text)
		local arr = CCArray:create()
		local delaytime = 0.4
		arr:addObject(CCDelayTime:create(delaytime))
		arr:addObject(CCCallFunc:create(function ( ... )
			self:showTextWithLabel(ctrlName, text.." .")
				end))
		arr:addObject(CCDelayTime:create(delaytime))
		arr:addObject(CCCallFunc:create(function ( ... )
			self:showTextWithLabel(ctrlName, text.." . .")
				end))
		arr:addObject(CCDelayTime:create(delaytime))
		arr:addObject(CCCallFunc:create(function ( ... )
			self:showTextWithLabel(ctrlName, text.." . . .")
				end))
		arr:addObject(CCDelayTime:create(delaytime))
		arr:addObject(CCCallFunc:create(function ( ... )
			self:showTextWithLabel(ctrlName, text)
				end))
		label:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end
end

return LegionCrossDateLayer

