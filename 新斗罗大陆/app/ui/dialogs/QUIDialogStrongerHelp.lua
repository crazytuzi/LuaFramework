-- @Author: zhouxiaoshu
-- @Date:   2019-07-22 10:39:43
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-04 15:51:44

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogStrongerHelp = class("QUIDialogStrongerHelp", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
local QUIWidgetStrongerHelp = import("..widgets.QUIWidgetStrongerHelp")
local QTutorialDefeatedGuide = import("...tutorial.defeated.QTutorialDefeatedGuide")
local QUIDialogHeroInformation = import("...ui.dialogs.QUIDialogHeroInformation")

local PING_ZHI = {"ss", "s", "a+", "a", "b"}
local talkRate = 25

function QUIDialogStrongerHelp:ctor(options)
	local ccbFile = "ccb/Dialog_stronger_help.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
		{ccbCallbackName = "onTriggerShow", callback = handler(self, self._onTriggerShow)},
	}
	QUIDialogStrongerHelp.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(true)
    page.topBar:showWithMainPage()

	self._ccbOwner.btn_go:setScale(0.8)
    self._defaultId = options.defaultId or 0
	self._forceLevel = 5
	self:initForce()
	self:initHelpTips()
	self:initListView()
	remote.strongerUtil:saveShowRecord()

	self._ccbOwner.frame_tf_title:setString("我要变强")
	self._ccbOwner.node_right_center:setVisible(false)
end

function QUIDialogStrongerHelp:viewDidAppear()
	QUIDialogStrongerHelp.super.viewDidAppear(self)
	self:addBackEvent(true)
end

function QUIDialogStrongerHelp:viewWillDisappear()
	QUIDialogStrongerHelp.super.viewWillDisappear(self)
	self:removeBackEvent()

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end

function QUIDialogStrongerHelp:initHelpTips()
	remote.helpUtil:checkCanShowHelp()
	local scheduleFunc = function()
		local talkDesc = nil
		self._ccbOwner.btn_go:setVisible(false)

		-- 功能提示语言
		local index = app.random(1, 100)
		if index > talkRate then
			local helpList = remote.helpUtil:checkCanShowHelp()
			self._curGo = helpList[1]
			if self._curGo then
				talkDesc = self._curGo.help_content
				remote.helpUtil:setCurrentTimeByHelpType(self._curGo.help_function, 1)
				self._ccbOwner.btn_go:setVisible(true)
			end
		end

		-- 随机提示语言
		if not talkDesc then
			local strongerList = remote.helpUtil:getStrongerTalkList()
			local talkTbl = {}
			for i, stronger in pairs(strongerList) do
				if stronger.type_num == self._forceLevel or stronger.type_num == 0 then
					for i, talk in pairs(stronger.talkTbl or {}) do
						table.insert(talkTbl, talk)
					end
				end
			end
			-- 根据战力等级选择
			local num = app.random(1, #talkTbl)
			talkDesc = talkTbl[num]
		end

		if talkDesc and talkDesc ~= "" then
			if not self._richText then
				self._richText = QRichText.new(talkDesc, 210, {defaultSize = 20, stringType = 1})
				self._richText:setAnchorPoint(ccp(0,1))
				self._ccbOwner.node_desc:addChild(self._richText)
			end
			self._richText:setString(talkDesc)
		end
	end

	scheduleFunc()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	self._timeScheduler = scheduler.scheduleGlobal(scheduleFunc, 10)
end

function QUIDialogStrongerHelp:initForce()
	local teamLevel = remote.user.level
	self._ccbOwner.tf_level:setString("LV."..teamLevel)

    -- 战力
    local battleForce = remote.herosUtil:getMostHeroBattleForce()
    local num, unit = q.convertLargerNumber(battleForce)
    self._ccbOwner.tf_force:setString(num..unit)

    local fontInfo = db:getForceColorByForce(battleForce, true)
    if fontInfo then
    	local colorInfo = FONTCOLOR_TO_OUTLINECOLOR[fontInfo.color_index]
    	if colorInfo then
	    	self._ccbOwner.tf_force:setColor(colorInfo.fontColor)
	    	self._ccbOwner.tf_force:setOutlineColor(colorInfo.outlineColor)
	    	self._ccbOwner.tf_force:enableOutline()
	    end
    end

    -- 推荐战力
	local levelForce = remote.strongerUtil:getLevelForce()
	self._forceLevel = 5
	for i, force in pairs(levelForce) do
		if battleForce >= force then
			self._forceLevel = i
			break
		end
	end
    local battleForce1 = levelForce[2]
    local num, unit = q.convertLargerNumber(battleForce1)
    self._ccbOwner.tf_force1:setString(num..unit)

    local fontInfo = db:getForceColorByForce(battleForce1, true)
    if fontInfo then
    	local colorInfo = FONTCOLOR_TO_OUTLINECOLOR[fontInfo.color_index]
    	if colorInfo then
	    	self._ccbOwner.tf_force1:setColor(colorInfo.fontColor)
	    	self._ccbOwner.tf_force1:setOutlineColor(colorInfo.outlineColor)
	    	self._ccbOwner.tf_force1:enableOutline()
	    end
    end

    local pingzhi = PING_ZHI[self._forceLevel]
    self:setSABC(pingzhi)
end

function QUIDialogStrongerHelp:setSABC(pingzhi)
    local nodeOwner = {}
    local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
    self._ccbOwner.pingzhi_icon:addChild(pingzhiNode)
    q.setAptitudeShow(nodeOwner, pingzhi)
end

function QUIDialogStrongerHelp:initListView()
	self._data = remote.strongerUtil:getStrongerHelpList()
	table.sort( self._data, function(a, b)
		if a.isNew ~= b.isNew then
			return a.isNew == true
		elseif a.weight ~= b.weight then
			return a.weight > b.weight
		end
		return a.id < b.id
	end)

	local headIndex = 1
	for i, v in pairs(self._data) do
		if self._defaultId == v.id then
			headIndex = i
			break
		end
	end
	if headIndex >= #self._data then
		headIndex = headIndex - 1
	end
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._data[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetStrongerHelp.new()
            		item:addEventListener(QUIWidgetStrongerHelp.EVENT_GO_CLICK, handler(self, self.itemClickHandler))
	                isCacheNode = false
	            end
	            info.item = item
	            info.size = item:getContentSize()
            	list:registerBtnHandler(index, "btn_go", "_onTriggerGo", nil, true)
	            item:setInfo(itemData)

	            return isCacheNode
	        end,
	        enableShadow = false,
	        spaceY = -10,
	        curOriginOffset = 2,
	        curOffset = -6,
	        headIndex = headIndex,
	        totalNumber = #self._data,
	    }  
    	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._data, headIndex = headIndex})
	end
end

function QUIDialogStrongerHelp:itemClickHandler(event)
	if not event or not event.id then
		return
	end

	local curConfig = remote.strongerUtil:getStrongerHelpById(event.id)
	if not curConfig then
		return
	end
	self:getOptions().defaultId = event.id

	remote.strongerUtil:gotoByInfo(curConfig)
end

function QUIDialogStrongerHelp:_onTriggerShow()
	self:initHelpTips()
end

function QUIDialogStrongerHelp:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
	if not self._curGo then
		return
	end
	if self._curGo.help_function == "hero_up" then
		local state, ret = remote.helpUtil:checkHeroCanUpgrade()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.UPGRADE, options = {actorId = ret.actorId}})
	elseif self._curGo.help_function == "break_through" then
		local state, ret = remote.helpUtil:checkHeroEquipCanEvolve()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.EVOLVE1, options = {actorId = ret.actorId, equipmentId = ret.equipmentId}})
	elseif self._curGo.help_function == "daily_quest" then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
		remote.task:setCurTaskType(remote.task.TASK_TYPE_NONE)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDailyTask"})
	elseif self._curGo.help_function == "equipment_up" then
		local actorIds = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.ENHANCE, options = {actorId = actorIds[1]}})
	elseif self._curGo.help_function == "hero_skills" then
		local state, ret = remote.helpUtil:checkHeroSkillCanUpgrade()
		-- if nil ~= ret then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.SKILL, options = {actorId = ret.actorId}})
		-- end
	elseif self._curGo.help_function == "hero_train" then
		local actorIds = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.TRAIN, options = {actorId = actorIds[1], detailType = QUIDialogHeroInformation.HERO_TRAINING}})
	elseif self._curGo.help_function == "hero_glyphs" then
		local actorIds = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.GLYPH, options = {actorId = actorIds[1], detailType = QUIDialogHeroInformation.HERO_GLYPH}})
	elseif self._curGo.help_function == "knapsack_box" then
		local state, ret = remote.helpUtil:checkHaveGiftItems()
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack", options = {itemID = ret.itemID}})
	elseif self._curGo.help_function == "hero_ornament" then
		local state, ret = remote.helpUtil:checkJewelryCanLevelUp()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.ENHANCE, options = {actorId = ret.actorId, equipmentId = ret.equipmentId, equipmentPos = ret.equipPos}})
	elseif self._curGo.help_function == "baoshi_up" then
		local actorIds = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.GEMSTONE_EVOLVE, options = {actorId = actorIds[1]}})
	elseif self._curGo.shortcut then
    	local shortcutInfo = db:getShortcutByID(self._curGo.shortcut)
    	if shortcutInfo then
			QQuickWay:clickGoto(shortcutInfo)
		end
	end
end

return QUIDialogStrongerHelp