-- 
-- zxs
-- 精英赛avatar
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryAvatar = class("QUIWidgetSanctuaryAvatar", QUIWidget)
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetHeroTitleBox = import("..QUIWidgetHeroTitleBox")

function QUIWidgetSanctuaryAvatar:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
	}
	QUIWidgetSanctuaryAvatar.super.ctor(self,ccbFile,callBacks,options)

	q.setButtonEnableShadow(self._ccbOwner.btn_visit)
	self:resetData()
end

function QUIWidgetSanctuaryAvatar:onEnter()
	QUIWidgetSanctuaryAvatar.super.onEnter(self)
end

function QUIWidgetSanctuaryAvatar:onExit()
	QUIWidgetSanctuaryAvatar.super.onExit(self)

	self:resetData()
end

function QUIWidgetSanctuaryAvatar:resetData()
	self._ccbOwner.tf_battleforce:setString("0")
	self._ccbOwner.tf_server_name:setString("")
	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_rank:setString("0")
	self._ccbOwner.node_head1:removeAllChildren()
	self._ccbOwner.node_head2:removeAllChildren()
	self._ccbOwner.node_no:setVisible(true)
	self._avatar1 = nil
	self._avatar2 = nil
end

--设置信息
function QUIWidgetSanctuaryAvatar:setInfo(fighter, isRefresh)
	self:resetData()
	if not fighter then
		return
	end

	self._fighter = fighter
	self._ccbOwner.node_no:setVisible(false)
	local force = fighter.force or 0
	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_battleforce:setString(num..(unit or ""))
	self._ccbOwner.tf_server_name:setString(fighter.game_area_name or "")
	self._ccbOwner.tf_user_name:setString(fighter.name or "")
	self._ccbOwner.tf_rank:setString(fighter.sanctuaryWarScore or 0)

	local hasHero = false
	local heroInfo1 = remote.herosUtil:getMaxForceByHeros(self._fighter)
	if heroInfo1 and heroInfo1.actorId then
		self._avatar1 = QUIWidgetActorDisplay.new(heroInfo1.actorId, {heroInfo = heroInfo1})
		self._ccbOwner.node_head1:addChild(self._avatar1)
		hasHero = true
	end
	
	local heroInfo2 = remote.herosUtil:getMaxForceBySecondTeamHeros(self._fighter, true)
	if heroInfo2 and heroInfo2.actorId then
		self._avatar2 = QUIWidgetActorDisplay.new(heroInfo2.actorId, {heroInfo = heroInfo2})
		self._ccbOwner.node_head2:addChild(self._avatar2)
		hasHero = true
	end

	if self._fighter.defaultActorId and not hasHero then
		self._avatar1 = QUIWidgetActorDisplay.new(self._fighter.defaultActorId, {heroInfo = {skinId = self._fighter.defaultSkinId}})
		self._ccbOwner.node_head1:addChild(self._avatar1)
		self._ccbOwner.node_head1:setPositionX(0)
	end

	self:setIsSelf(remote.user.userId == fighter.userId)
	self:showTitle(self._fighter.title, self._fighter.soulTrial)

	if isRefresh then
		self._effect = QUIWidgetAnimationPlayer.new()
		self._effect:playAnimation("effects/douhuncang_guang.ccbi", nil,function()
			self._effect = nil
		end)
		self._effect:setPosition(0, -70)
		self:getView():addChild(self._effect)
		self._effect:setScale(1.3)
	else
		if self._effect ~= nil then
			self._effect:disappear()
			self._effect = nil
		end
	end
end

--设置是否自己
function QUIWidgetSanctuaryAvatar:setIsSelf(isSelf)
	self._ccbOwner.node_high:setVisible(not isSelf)
	self._ccbOwner.node_self:setVisible(isSelf)
end

--翻转
function QUIWidgetSanctuaryAvatar:setAvatarScaleX(scaleX)
	self._ccbOwner.node_head1:setScaleX(scaleX)
	self._ccbOwner.node_head2:setScaleX(scaleX)
end

function QUIWidgetSanctuaryAvatar:setShowInfo(isShow)
	self._ccbOwner.node_tf_client:setVisible(isShow)
	self._ccbOwner.node_self:setVisible(isShow)
	self._ccbOwner.node_high:setVisible(isShow)
	self._ccbOwner.node_no:setVisible(isShow)
	self._ccbOwner.btn_visit:setVisible(isShow)
end

function QUIWidgetSanctuaryAvatar:setShowNoFlag(isShow)
	self._ccbOwner.node_no:setVisible(isShow)
end

function QUIWidgetSanctuaryAvatar:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetSanctuaryAvatar:showDeadEffect( callback )
	local endIndex = 0
	if self._avatar1 then
		self._avatar1:displayWithBehavior(ANIMATION_EFFECT.DEAD)
		self._avatar1:setDisplayBehaviorCallback(function ()
			endIndex = endIndex + 1
			self._avatar1:setVisible(false)
			if endIndex == 2 then
				if callback then
					callback()
				end
			end
		end)
	else
		endIndex = endIndex + 1
	end
	if self._avatar2 then
		self._avatar2:displayWithBehavior(ANIMATION_EFFECT.DEAD)
		self._avatar2:setDisplayBehaviorCallback(function ()
			endIndex = endIndex + 1
			self._avatar2:setVisible(false)
			if endIndex == 2 then
				if callback then
					callback()
				end
			end
		end)
	else
		endIndex = endIndex + 1
	end
end

--点击查看玩家信息
function QUIWidgetSanctuaryAvatar:_onTriggerVisit()
	if self._fighter == nil then return end	

	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._fighter.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = self._fighter.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

return QUIWidgetSanctuaryAvatar