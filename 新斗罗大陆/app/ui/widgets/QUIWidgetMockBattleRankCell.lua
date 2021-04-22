


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMockBattleRankCell = class("QUIWidgetMockBattleRankCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")

function QUIWidgetMockBattleRankCell:ctor(options)
	local ccbFile = "ccb/Widget_MockBattle_RankCell.ccbi"
	local callBack = {
		{ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetMockBattleRankCell.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:resetAll()
end

function QUIWidgetMockBattleRankCell:onEnter()
end

function QUIWidgetMockBattleRankCell:onExit()
end

function QUIWidgetMockBattleRankCell:resetAll()
	self._ccbOwner.node_hero:removeAllChildren()
	self._ccbOwner.tf_attend_rate:setString("")
	self._ccbOwner.tf_win_rate:setString("")
	self._ccbOwner.sp_first:setVisible(false)
	self._ccbOwner.sp_second:setVisible(false)
	self._ccbOwner.sp_third:setVisible(false)
	self._ccbOwner.tf_other:setString("")
	self._ccbOwner.node_mount_1:removeAllChildren()
	self._ccbOwner.node_mount_2:removeAllChildren()
	self._ccbOwner.node_mount_3:removeAllChildren()

end

function QUIWidgetMockBattleRankCell:setInfo(data,index)
	self:resetAll()

	local actor_id= data.actorId
	local attendanceRate = data.attendanceRate or 0
	local winRate= data.winRate or 0

	local mountids = data.wearZuoqiId or {}

	self._ccbOwner.sp_first:setVisible(index == 1)
	self._ccbOwner.sp_second:setVisible(index == 2)
	self._ccbOwner.sp_third:setVisible(index == 3)
	self._ccbOwner.tf_other:setVisible(index > 3)
	self._ccbOwner.tf_other:setString(index)

	self._ccbOwner.tf_attend_rate:setString(attendanceRate.."%")
	self._ccbOwner.tf_win_rate:setString(winRate.."%")


	local hero_data_ = remote.mockbattle:getCardInfoById(actor_id)
	local heroHead = QUIWidgetHeroHead.new()
    heroHead:setHeroInfo(hero_data_)
    -- heroHead:setHero(hero_data_.actorId)
    -- heroHead:setLevel(hero_data_.level)
    -- heroHead:setBreakthrough(hero_data_.breakthrough)
    -- heroHead:setStar(hero_data_.grade)
    heroHead:showSabc()
    heroHead:setScale(0.6)
    heroHead:setParam(actor_id)
    heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
    --heroHead:initGLLayer()
    self._ccbOwner.node_hero:addChild(heroHead)


	local index_ = 1
	for i,v in ipairs(mountids) do
		if index_ > 3 then break end
		local data_ = remote.mockbattle:getCardInfoById(v)
		if data_ ~= nil then
	    	local heroHead = QUIWidgetHeroHead.new()
	        heroHead:setHero(data_.actorId)
	        --heroHead:setLevel(data_.uiModel.level)
	        heroHead:setLevel(0)
	        heroHead:setStar(data_.uiModel.grade)
	        heroHead:showSabc()
	        heroHead:setScale(0.6)
	        heroHead:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self._onEvent))
	        --heroHead:initGLLayer()
			self._ccbOwner["node_mount_"..index_]:addChild(heroHead)
			index_ = index_ + 1
		else
			print(" 暗器ID "..v.." 是空的")
		end

	end
end

function QUIWidgetMockBattleRankCell:getContentSize()
	return self._ccbOwner.background:getContentSize()
end


function QUIWidgetMockBattleRankCell:_onEvent(event)
	if event.name == QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK then
		local heroHead = event.target
		local actorId = heroHead:getHeroActorID()
		local id = heroHead:getParam()
		if heroHead:getIsSoulSpirit() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleSoulCardInfo",
				options = {actorId = actorId, id = id }})
		elseif heroHead:getIsMount() then
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleMountCardInfo",
				options = {actorId = actorId, id = id }})
		elseif heroHead:getIsGodarm() then
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleGodarmCardInfo",
	            options = {actorId = actorId, id = id}})   
		else
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMockBattleHeroCardInfo",
				options = {actorId = actorId, id = id}})
		end
	end

end


return QUIWidgetMockBattleRankCell