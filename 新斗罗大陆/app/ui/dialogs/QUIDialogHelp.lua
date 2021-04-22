--[[	
	QUIDialogHelp
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogHelp = class("QUIDialogHelp", QUIDialog)

local QRichText = import("...utils.QRichText")
local QTutorialDefeatedGuide = import("...tutorial.defeated.QTutorialDefeatedGuide")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIDialogHeroInformation = import("...ui.dialogs.QUIDialogHeroInformation")
local QQuickWay = import("...utils.QQuickWay")

QUIDialogHelp.HELP_ICON_DISAPPEAR = "HELP_ICON_DISAPPEAR"

local lastHelpList = {}

--初始化
function QUIDialogHelp:ctor(options)
	local ccbFile = "Dialog_Help.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGo", callback = handler(self, QUIDialogHelp._onTriggerGo)},
	}
	QUIDialogHelp.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:initData()
	self:render()

	self.isAnimation = true
end


-- 获取数据
function QUIDialogHelp:initData(  )
	local helpList = remote.helpUtil:checkCanShowHelp()
	self._curGo = helpList[1]
	if self._curGo then
		remote.helpUtil:setCurrentTimeByHelpType(self._curGo.help_function, 1)
	end

	if #helpList == 0 then
		self._helpIconDisappear = true
	end
end


--渲染
function QUIDialogHelp:render(  )
	-- body
	if self._curGo.icon then
		local sprite = CCSprite:create(self._curGo.icon)
		if sprite then
			self._ccbOwner.helpIcon2:setDisplayFrame(sprite:getDisplayFrame())
			self._ccbOwner.helpIcon1:setDisplayFrame(sprite:getDisplayFrame())
		end
	end

	self._ccbOwner.helpTitle:setString(self._curGo.help_headline or "每日任务")
	local richText = QRichText.new(self._curGo.help_content,290,{lineHeight = 42, stringType = 1})
	if richText then
		richText:setAnchorPoint(ccp(0,1))
		self._ccbOwner.describeTTF:addChild(richText)
	end

	self._animationManager = tolua.cast(self._ccbOwner.helpAnimation:getUserObject(), "CCBAnimationManager")
	if self._animationManager then
		self._animationManager:stopAnimation()
		local action = CCSequence:createWithTwoActions(CCDelayTime:create(1.5),CCCallFunc:create(function( )
			-- body
			if tolua.cast(self._animationManager, "CCBAnimationManager") then
				self._animationManager:runAnimationsForSequenceNamed("Default Timeline")	
			end
		end))
		self._ccbOwner.helpAnimation:runAction(action)
	end
end

--describe：
function QUIDialogHelp:_onTriggerGo()
	--代码
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
		local herosID = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.ENHANCE, options = {actorId = herosID[1]}})

	elseif self._curGo.help_function == "hero_skills" then
		local state, ret = remote.helpUtil:checkHeroSkillCanUpgrade()
		-- if nil ~= ret then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.SKILL, options = {actorId = ret.actorId}})
		-- end
	elseif self._curGo.help_function == "hero_train" then
		local herosID = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.TRAIN, options = {actorId = herosID[1], detailType = QUIDialogHeroInformation.HERO_TRAINING}})
	
	elseif self._curGo.help_function == "hero_glyphs" then
		local herosID = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.GLYPH, options = {actorId = herosID[1], detailType = QUIDialogHeroInformation.HERO_GLYPH}})
	
	elseif self._curGo.help_function == "knapsack_box" then
		local state, ret = remote.helpUtil:checkHaveGiftItems()
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack", options = {itemID = ret.itemID}})
	
	elseif self._curGo.help_function == "hero_ornament" then
		local state, ret = remote.helpUtil:checkJewelryCanLevelUp()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.ENHANCE, options = {actorId = ret.actorId, equipmentId = ret.equipmentId, equipmentPos = ret.equipPos}})
	
	elseif self._curGo.help_function == "baoshi_up" then
		local herosID = remote.herosUtil:getHaveHero()
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialDefeatedGuide.GEMSTONE_EVOLVE, options = {actorId = herosID[1]}})
	
	elseif self._curGo.shortcut then
    	local shortcutInfo = QStaticDatabase.sharedDatabase():getShortcutByID(self._curGo.shortcut)
    	if shortcutInfo then
			app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
			QQuickWay:clickGoto(shortcutInfo)
		end
	end
	
	if self._helpIconDisappear then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogHelp.HELP_ICON_DISAPPEAR})
	end
end

--describe：关闭对话框
function QUIDialogHelp:close( )
	app.sound:playSound("common_cancel")
	self:playEffectOut()
	if self._helpIconDisappear then
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIDialogHelp.HELP_ICON_DISAPPEAR})
	end
end

--describe：viewAnimationOutHandler 
function QUIDialogHelp:viewAnimationOutHandler()
	--代码

	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

end

--describe：_backClickHandler 
function QUIDialogHelp:_backClickHandler()
	--代码
	self:close()
end

return QUIDialogHelp
