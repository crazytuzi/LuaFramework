-- @Author: xurui
-- @Date:   2018-08-07 15:06:15
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-23 17:44:53
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMetalCity = class("QUIDialogMetalCity", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QMetalCityArrangement = import("...arrangement.QMetalCityArrangement")
local QUIWidgetMetalCity = import("..widgets.QUIWidgetMetalCity")
local QListView = import("...views.QListView")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogMetalCity:ctor(options)
	local ccbFile = "ccb/Dialog_tower_main.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerStore", callback = handler(self, self._onTriggerStore)},
		{ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
    }
    QUIDialogMetalCity.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible(false)
	page:setScalingVisible(false)
	page.topBar:showWithStyle({TOP_BAR_TYPE.TOKEN_MONEY, TOP_BAR_TYPE.STORM_MONEY})

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._tutorialMetalNum = options.tutorialMetalNum
    end

    self._chapterDataList = {}																	--当前章节的信息
    self._lastChapter, self._lastFloor = remote.metalCity:getCurrentChapterNum()          		--当前通关的章节和层数     
    self._selectChapter = self._lastChapter 													--当前选中的章节  		
    self._selectFloor = self._lastFloor 														--当前选中的章节 

    self._offsetY = (display.height-400)/2									--将当前层数移动到界面中间的偏移量	
    -- CalculateBattleUIPosition(self._ccbOwner.node_offside , true)

    self._ccbOwner.sheet_layout:setContentSize(CCSize(display.width, display.height))
   	self._ccbOwner.sheet_layout:setPositionX(-display.width/2)
end

function QUIDialogMetalCity:viewDidAppear()
	QUIDialogMetalCity.super.viewDidAppear(self)

	self._metalCityEventProxy = cc.EventProxy.new(remote.metalCity)
    self._metalCityEventProxy:addEventListener(remote.metalCity.UPDATE_METALCITY_FIGHT_COUNT, handler(self, self.setFightCount))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.updateTopNBattleForce))

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)

	self:setChapterInfo()

	self:setFightCount()

	if self._tutorialMetalNum then
		self:setMetalNum(self._tutorialMetalNum)
	end

	self:addBackEvent(false)
end

function QUIDialogMetalCity:viewWillDisappear()
  	QUIDialogMetalCity.super.viewWillDisappear(self)

    self._metalCityEventProxy:removeAllEventListeners()

    self._remoteProxy:removeAllEventListeners()

	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattle, self)
    
	self:removeBackEvent()
end

function QUIDialogMetalCity:initListView()
	local totalNumber = #self._chapterDataList
	local headIndex = totalNumber - self._selectFloor
	local headIndexPosOffset = self._offsetY
	if headIndex == 0 or headIndex == 1 then
		headIndexPosOffset = 0
	end
	
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = false,
	        totalNumber = totalNumber,
	        enableShadow = false,
	        topShadow = self._ccbOwner.sp_top,
	        bottomShadow = self._ccbOwner.sp_bottom,
	        headIndex = headIndex,
	        headIndexPosOffset = headIndexPosOffset,
	        endRate = 0,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = totalNumber, headIndex = headIndex, headIndexPosOffset = headIndexPosOffset})
	end
end

function QUIDialogMetalCity:renderFunHandler(list, index, info)
    local isCacheNode = true
    local data = self._chapterDataList[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetMetalCity.new()
    	item:addEventListener(QUIWidgetMetalCity.EVENT_CLICK_RECORD, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetMetalCity.EVENT_CLICK_FASTFIGHT, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetMetalCity.EVENT_CLICK_BOSSDATA, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetMetalCity.EVENT_CLICK_FIGHT, handler(self, self._clickEvent))
    	item:addEventListener(QUIWidgetMetalCity.EVENT_CLICK_SKILL, handler(self, self._clickEvent))

        isCacheNode = false
    end
    info.item = item
	item:setInfo(data, index)
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_fast_fight", "_onTriggerFastFight", nil, true)
    list:registerBtnHandler(index, "btn_record", "_onTriggerRecord", nil, true)
    list:registerBtnHandler(index, "btn_boss_data", "_onTriggerBossData")
    list:registerBtnHandler(index, "btn_fight", "_onTriggerFight")
    list:registerBtnHandler(index, "btn_skill_1", "_onTriggerSkill1")
    list:registerBtnHandler(index, "btn_skill_2", "_onTriggerSkill2")

    item:registerItemBoxPrompt(index, list)

	return isCacheNode
end

function QUIDialogMetalCity:_exitFromBattle()
	self._lastChapter, self._lastFloor = remote.metalCity:getCurrentChapterNum()     
	if self._selectChapter ~= self._lastChapter then
		self._selectChapter = self._lastChapter
	end     		

	self:setChapterInfo()

	self:setFightCount()

	self:checkAwardStr()
end

function QUIDialogMetalCity:setChapterInfo()
	self._myInfoDict = remote.metalCity:getMetalCityMyInfo()
	self._chapterDataList = remote.metalCity:getMetalCityConfigByChapter(self._selectChapter)

	if self._chapterDataList[1] then
		local mapInfo = remote.metalCity:getMetalCityMapConfigById(self._chapterDataList[1].dungeon_id_1)
		self._ccbOwner.tf_chapter_name:setString(mapInfo.instance_name or "")
	end

	self:updateData()

    self:initListView()

    self:updateTopNBattleForce()

    self:checkShopTip()
end

function QUIDialogMetalCity:checkShopTip( ... )
	self._ccbOwner.shop_tips:setVisible(remote.metalCity:checkMetalCityShopRedTips())
end

function QUIDialogMetalCity:updateTopNBattleForce()
	local force = remote.herosUtil:getMostHeroBattleForce() or 0
	local fontInfo = QStaticDatabase:sharedDatabase():getForceColorByForce(tonumber(force),true)
	if fontInfo then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_defens_force:setColor(ccc3(color[1], color[2], color[3]))
	end
	local num, word = q.convertLargerNumber(force)
	self._ccbOwner.tf_defens_force:setString(num..word)

	self._ccbOwner.node_pvp:setVisible(false)
	self._ccbOwner.widget_node_team:setVisible(false)
	self._ccbOwner.sp_inherit:setVisible(false)
	QSetDisplayFrameByPath(self._ccbOwner.sp_words_zhanli, "ui/update_common/zi_zhanli.png")
	self._ccbOwner.tf_defens_force:setPositionX(180)
end

function QUIDialogMetalCity:updateData()
	local data = {}
	for index, value in ipairs(self._chapterDataList) do
		if value.metalcity_chapter == self._lastChapter and value.num > self._myInfoDict.metalNum + 3 then
			value.isShowCloud = true
		else
			value.isShowCloud = false
		end
	end

	local maxChapter = remote.metalCity:getMetalCityChapterMaxNum()
	if self._selectChapter - 1 <= 0 then
		self._ccbOwner.node_left:setVisible(false)
	else
		self._ccbOwner.node_left:setVisible(true)
	end
	
	if self._selectChapter >= self._lastChapter or self._selectChapter + 1 > maxChapter then
		self._ccbOwner.node_right:setVisible(false)
	else
		self._ccbOwner.node_right:setVisible(true)
	end

	if self._selectChapter < self._lastChapter then
		self._selectFloor = #self._chapterDataList
	else
		self._selectFloor = self._lastFloor
	end

	table.sort( self._chapterDataList, function(a, b)
			if a.num ~= b.num then
				return a.num > b.num
			else
				return false
			end
		end )
end

function QUIDialogMetalCity:setFightCount()
	local fightCount, canBuyCount = remote.metalCity:getMetalCityFightCount()

	self._ccbOwner.tf_fight_num:setString(fightCount or 0)

	self._ccbOwner.node_btn_plus:setVisible(canBuyCount > 0)
end

function QUIDialogMetalCity:_clickEvent(event)
	if event == nil then return end

	local info = event.info or {}
	if event.name == QUIWidgetMetalCity.EVENT_CLICK_RECORD then
		remote.metalCity:requestMetalCityReports(info.num, function(data)
				if self:safeCheck() and data.metalCityResponse then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityRecord",
						options = {info = data.metalCityResponse.reports or {},reportType = REPORT_TYPE.METAL_CITY}})					
				end
			end)


	elseif event.name == QUIWidgetMetalCity.EVENT_CLICK_FASTFIGHT then
		self:quickFight(info)
	elseif event.name == QUIWidgetMetalCity.EVENT_CLICK_BOSSDATA then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityBossIntroduce",
			options = {info = info}})
	elseif event.name == QUIWidgetMetalCity.EVENT_CLICK_FIGHT then
		if info.num ~= (self._myInfoDict.metalNum or 0)+1 then
			return
		end

		if self:checkFightCount() == false then
			return
		end

		local config = remote.metalCity:getMetalCityConfigByFloor(info.num)
		local metalCityArrangement1 = QMetalCityArrangement.new({info = info, teamKey = remote.teamManager.METAL_CIRY_ATTACK_TEAM1})
		local metalCityArrangement2 = QMetalCityArrangement.new({info = info, teamKey = remote.teamManager.METAL_CIRY_ATTACK_TEAM2})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
			options = {arrangement1 = metalCityArrangement1, arrangement2 = metalCityArrangement2, fighterInfo = config, widgetClass = "QUIWidgetMetalCityTeamBossInfo"}})

	elseif event.name == QUIWidgetMetalCity.EVENT_CLICK_SKILL then
		app.tip:skillTip(event.skillId, 1, true, {hideLevel = true, skillTitle = "机关说明", showType = false, skillNamePos = {x = 0, y = -20}})
	end
end

function QUIDialogMetalCity:checkAwardStr(isToturial, callback)
	local awardsStr = remote.metalCity:getMetalCityRewards()
	local awardRatio = remote.metalCity:getMetalCityRewardRatio()
	if awardsStr ~= nil and awardsStr ~= "" then

		if isToturial == nil then
			self:resetCurrentFloorForPassEffect()
		end

		local awards = remote.items:analysisServerItem(awardsStr)

		remote.metalCity:setMetalCityRewardRatio(1)
		remote.metalCity:setMetalCityRewards("")

		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	        options = {awards = awards, awardRatio = awardRatio, callBack = function()
	        		if callback then
	        			callback()
	        		end
	        		if isToturial == nil then
	        			self:checkPassEffect()
	        		end
	        	end}},{isPopCurrentDialog = false} )
	    dialog:setTitle("恭喜您获得首通奖励")
	else
		if callback then
			callback()
		end
	end
end

function QUIDialogMetalCity:checkPassEffect()
	local passMetalNum = remote.metalCity:getCurrentPassMetalNum()
	if passMetalNum == nil then return end
    remote.metalCity:setCurrentPassMetalNum()

    local nextFloorInfo = remote.metalCity:getMetalCityConfigByFloor(passMetalNum+1)
    if q.isEmpty(nextFloorInfo) then
    	return
    end

	local startNum = passMetalNum
	local endNum = passMetalNum + 1
	self:showPassEffect(startNum, endNum, true)
end

function QUIDialogMetalCity:resetCurrentFloorForPassEffect( ... )
	local passMetalNum = remote.metalCity:getCurrentPassMetalNum()
	if passMetalNum == nil then return end
    local startFloorInfo = remote.metalCity:getMetalCityConfigByFloor(passMetalNum)
    local endFloorInfo = remote.metalCity:getMetalCityConfigByFloor(passMetalNum+1)
    if q.isEmpty(startFloorInfo) or q.isEmpty(endFloorInfo) then
    	return
    end

    local startIndex = #self._chapterDataList - startFloorInfo.metalcity_floor + 1
    local endIndex = startIndex - 1
    local offsetOut = -self._offsetY
    if startIndex == #self._chapterDataList then
    	offsetOut = 0
    end

	local chapteOffset = endFloorInfo.metalcity_chapter - startFloorInfo.metalcity_chapter
	if chapteOffset == 0 then
    	self._contentListView:startScrollToIndex(startIndex, nil, 1000, nil, offsetOut)
		local item = self._contentListView:getItemByIndex(endIndex)
		if item then
			item:setAvatarStated(false)
		end
	else
		self:_onTriggerLeft()
	end
	local item = self._contentListView:getItemByIndex(startIndex)
	if item then
		item:showBossDeathEffect(false)
		item:createEffectAvatar()
	end
end

function QUIDialogMetalCity:showPassEffect(startNum, endNum)
	if self._contentListView == nil then return end

    local startFloorInfo = remote.metalCity:getMetalCityConfigByFloor(startNum)
    local endFloorInfo = remote.metalCity:getMetalCityConfigByFloor(endNum)
    if q.isEmpty(startFloorInfo) or q.isEmpty(endFloorInfo) then
    	return
    end
    local startIndex = #self._chapterDataList - startFloorInfo.metalcity_floor + 1
    local endIndex = startIndex - 1
    local offsetIn = -self._offsetY
    if startIndex == 2 then
    	offsetIn = 0
    end

	self:enableTouchSwallowTop()
	local chapteOffset = endFloorInfo.metalcity_chapter - startFloorInfo.metalcity_chapter
	if chapteOffset ~= 0 then
		endIndex = #self._chapterDataList
	end

	local item = self._contentListView:getItemByIndex(startIndex)
	if item then
		item:showPassOutEffect(true, function()

			local passInEffect = function(index)
				local item = self._contentListView:getItemByIndex(index)
				item:showPassInEffect(function()
						self:disableTouchSwallowTop()
					end)
			end

			if chapteOffset == 0 then
				self._contentListView:startScrollToIndex(endIndex, nil, 20, function()
					passInEffect(endIndex)
				end, offsetIn)
			else
				self:_onTriggerRight()

				local item = self._contentListView:getItemByIndex(endIndex)
				item:setAvatarStated(false)
				passInEffect(endIndex)
			end
		end)
	end
end

function QUIDialogMetalCity:checkFightCount( ... )
	local fightCount, canBuyCount = remote.metalCity:getMetalCityFightCount()
	if fightCount <= 0 then
		if canBuyCount > 0 then
			self:_onTriggerPlus()
		else
			app.tip:floatTip("今日战斗次数已用完~")
		end
		return false
	end

	return true
end

function QUIDialogMetalCity:quickFight(info)
	if self:checkFightCount() == false then
		return
	end

	remote.metalCity:responsMetalCityFightQuick(info.num, function(data)
			remote.user:addPropNumForKey("todayMetalCityFightCount")
			remote.user:addPropNumForKey("totalMetalCityFightCount")

            app.taskEvent:updateTaskEventProgress(app.taskEvent.METAILCITY_EVENT, 1, false, true)

			self:setFightCount()

			if self:safeCheck() then
				self:showQuickFightDialog(data.metalCityResponse, info)
			end
		end)
end

function QUIDialogMetalCity:showQuickFightDialog(response, info)
	if response.rewards then
		local awards = remote.items:analysisServerItem(response.rewards)
		local awardRatio = remote.metalCity:getMetalCityRewardRatio()

		remote.metalCity:setMetalCityRewardRatio(1)
		remote.metalCity:setMetalCityRewards("")
		local allAwards = {}
		local prizes = {}
		prizes.awards = {}
		for _,awardInfo in pairs(awards) do
			table.insert(prizes.awards,awardInfo)
		end
		table.insert(allAwards,prizes)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnityFastBattle", 
			options = {fast_type = FAST_FIGHT_TYPE.METALCITY_FAST, awards = allAwards, info = info, userComeBackRatio = awardRatio, isCanFast = true,callback = function (isAgain)
				if isAgain then
					self:quickFight(info)
				end
			end}})	
	end
end

function QUIDialogMetalCity:showTutorialLocateEffect()
	self:enableTouchSwallowTop()
	local item = self._contentListView:getItemByIndex(#self._chapterDataList)

	local awardsStr = remote.metalCity:getMetalCityRewards()
	if awardsStr ~= nil and awardsStr ~= "" then
		item:showPassOutEffect(false, function()

			self._lastChapter, self._lastFloor = remote.metalCity:getCurrentChapterNum()     
			if self._selectChapter ~= self._lastChapter then
				self._selectChapter = self._lastChapter
			end

			self:setChapterInfo()

			local item = self._contentListView:getItemByIndex(#self._chapterDataList - self._lastFloor)
			item:setAvatarStated(false)
			item:showPassInEffect(function()
					self:disableTouchSwallowTop()
				end)
		end)
	end
end

function QUIDialogMetalCity:showTutorialAwardDialog()
	self:checkAwardStr(true, function ()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTutorialDialog",
			options = {}})
	end)
end

function QUIDialogMetalCity:setMetalNum(metalNum)
	local oldMetalNum = self._myInfoDict.metalNum
	remote.metalCity:setMetalCityMyInfo({metalNum = metalNum})
	self._lastChapter, self._lastFloor = remote.metalCity:getCurrentChapterNum()     
	if self._selectChapter ~= self._lastChapter then
		self._selectChapter = self._lastChapter
	end
	self:getOptions().tutorialMetalNum = nil
	self._tutorialMetalNum = nil

	self:setChapterInfo()

	remote.metalCity:setMetalCityMyInfo({metalNum = oldMetalNum})
end

function QUIDialogMetalCity:getTutorialItem()
	local headIndex = #self._chapterDataList - self._selectFloor
	return self._contentListView:getItemByIndex(headIndex)
end

function QUIDialogMetalCity:_onTriggerStore(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_shop) == false then return end
	app.sound:playSound("common_small")

	remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIDialogMetalCity:_onTriggerRank()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "metalCity"}}, {isPopCurrentDialog = false})
end

function QUIDialogMetalCity:_onTriggerRule()
	app.sound:playSound("common_small")

  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityHelp",
    	options = {info = self.myInfo}})
end

function QUIDialogMetalCity:_onTriggerPlus(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase",
			options = {cls = "QBuyCountMetalCity"}})
end

function QUIDialogMetalCity:_onTriggerLeft()
	app.sound:playSound("common_small")

	self._selectChapter = self._selectChapter - 1

	self:setChapterInfo()
end

function QUIDialogMetalCity:_onTriggerRight()
	app.sound:playSound("common_small")

	self._selectChapter = self._selectChapter + 1

	self:setChapterInfo()
end

return QUIDialogMetalCity
