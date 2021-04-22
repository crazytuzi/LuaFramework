local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMockBattleCardInfo = class("QUIWidgetMockBattleCardInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QMockBattle = import("..network.models.QMockBattle")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

function QUIWidgetMockBattleCardInfo:ctor(options)
	local ccbFile = "ccb/Widget_MockBattle_CardInfo1.ccbi"
	self._isDouble = options.isDouble or false
	if self._isDouble then
		ccbFile = "ccb/Widget_MockBattle_CardInfo2.ccbi"
	end
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetMockBattleCardInfo.super.ctor(self, ccbFile, callBack, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMockBattleCardInfo:onEnter()
end

function QUIWidgetMockBattleCardInfo:onExit()
end


function QUIWidgetMockBattleCardInfo:setTouchHandle( func_)

	self._touch_func = func_
end

function QUIWidgetMockBattleCardInfo:setInfo(info)

	local mount_max_num = self._isDouble and 8 or 4

	local hero_num = 0
	local mount_num = 0
	local soul_num = 0
	local godArm_num = 0

	for i,value in pairs(info) do
		local data_ = remote.mockbattle:getCardInfoByIndex(value)

		local heroHead = QUIWidgetHeroHead.new()
		heroHead:setHeroInfo(data_)
        heroHead:showSabc()
        heroHead:setParam(value)
        heroHead:setScale(0.8)
        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))

		if data_.cType == QMockBattle.CARD_TYPE_HERO then
			hero_num = hero_num + 1
	        self._ccbOwner["node_hero_c"..hero_num]:addChild(heroHead)
		elseif data_.cType == QMockBattle.CARD_TYPE_MOUNT then
			mount_num = mount_num + 1
	        self._ccbOwner["node_mount_c"..mount_num]:addChild(heroHead)			
		elseif data_.cType == QMockBattle.CARD_TYPE_SOUL then
			soul_num = soul_num + 1
	        self._ccbOwner["node_soul_c"..soul_num]:addChild(heroHead)			
		elseif data_.cType == QMockBattle.CARD_TYPE_GODARM then
			godArm_num = godArm_num + 1
	        self._ccbOwner["node_godArm_c"..godArm_num]:addChild(heroHead)	
		end
	end

	local seasonType = self._isDouble and 2 or 1

	local max_num = remote.mockbattle:getCardMaxBySeasonAndType( seasonType, QMockBattle.CARD_TYPE_HERO)
    self._ccbOwner.tf_hero_num:setString("魂师（"..hero_num.."/"..max_num.."）")
	for i = hero_num + 1,8 do
		local heroHead = QUIWidgetHeroHead.new()
		heroHead:setHeroByFile(1, QResPath("mockbattle_card_icon_bg")[1], 1)
		heroHead:setScale(0.8)
		self._ccbOwner["node_hero_c"..i]:addChild(heroHead)
	end
	max_num = remote.mockbattle:getCardMaxBySeasonAndType( seasonType, QMockBattle.CARD_TYPE_MOUNT)
    self._ccbOwner.tf_mount_num:setString("暗器（"..mount_num.."/"..max_num.."）")
	for i=mount_num + 1,max_num do
		local heroHead = QUIWidgetHeroHead.new()
		heroHead:setHeroByFile(1,  QResPath("mockbattle_card_icon_bg")[2], 1)
		heroHead:setScale(0.8)
		self._ccbOwner["node_mount_c"..i]:addChild(heroHead)
	end
	max_num = remote.mockbattle:getCardMaxBySeasonAndType( seasonType, QMockBattle.CARD_TYPE_SOUL)
    self._ccbOwner.tf_soul_num:setString("魂灵（"..soul_num.."/"..max_num.."）")
	for i=soul_num + 1,max_num do
		local heroHead = QUIWidgetHeroHead.new()
		heroHead:setHeroByFile(1,  QResPath("mockbattle_card_icon_bg")[3], 1)
		heroHead:setScale(0.8)
		self._ccbOwner["node_soul_c"..i]:addChild(heroHead)
	end	
    if self._isDouble then
		max_num = remote.mockbattle:getCardMaxBySeasonAndType( seasonType, QMockBattle.CARD_TYPE_GODARM)
    	self._ccbOwner.tf_godArm_num:setString("神器（"..godArm_num.."/"..max_num.."）")
		for i=godArm_num + 1,max_num do
			local heroHead = QUIWidgetHeroHead.new()
			heroHead:setHeroByFile(1,  QResPath("mockbattle_card_icon_bg")[4], 1)
			heroHead:setScale(0.8)
			self._ccbOwner["node_godArm_c"..i]:addChild(heroHead)
		end	    	
    end

end


function QUIWidgetMockBattleCardInfo:_onEvent(event)

	if self._touch_func() then
		return
	end

	if event.name == QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK then
		local heroHead = event.target
		local actorId = heroHead:getHeroActorID()
		local id = heroHead:getParam()
		if heroHead:getIsSoulSpirit() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleSoulCardInfo",
				options = {actorId = actorId, id = id }})
		elseif heroHead:getIsMount() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleMountCardInfo",
				options = {actorId = actorId, id = id}})
		elseif heroHead:getIsGodarm() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleGodarmCardInfo",
				options = {actorId = actorId, id = id}})
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleHeroCardInfo",
				options = {actorId = actorId, id = id}})
		end
	end

end


function QUIWidgetMockBattleCardInfo:getContentSize()
	return self._ccbOwner.content_size:getContentSize()
end

return QUIWidgetMockBattleCardInfo