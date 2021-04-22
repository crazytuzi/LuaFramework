-- @Author: zhouxiaoshu
-- @Date:   2019-09-10 14:30:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-12 14:19:26
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSotoTeam = class("QUIWidgetSotoTeam", QUIWidget)

local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QChatDialog = import("...utils.QChatDialog")

QUIWidgetSotoTeam.EVENT_BATTLE = "EVENT_BATTLE"
QUIWidgetSotoTeam.EVENT_VISIT = "EVENT_VISIT"
QUIWidgetSotoTeam.EVENT_WORSHIP = "EVENT_WORSHIP"
QUIWidgetSotoTeam.EVENT_QUICK_BATTLE = "EVENT_QUICK_BATTLE"

function QUIWidgetSotoTeam:ctor(options)
	local ccbFile = "ccb/Widget_SotoTeam.ccbi"
  	local callBacks = {
      	{ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
      	{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
      	{ccbCallbackName = "onTriggerFans", callback = handler(self, self._onTriggerFans)},
      	{ccbCallbackName = "onTriggerFastFight", callback = handler(self, self._onTriggerFastFight)},
  	}
	QUIWidgetSotoTeam.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._words = db:getArenaLangaue()

    self:resetInfo()
end

function QUIWidgetSotoTeam:onExit()
	QUIWidgetSotoTeam.super.onExit(self)
    -- if self._avatar ~= nil then
    -- 	self._avatar:removeFromParent()
    -- 	self._avatar = nil
    -- end
end

function QUIWidgetSotoTeam:resetInfo()
	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_wave_value:setString(0)
	self._ccbOwner.tf_force_value:setString(0)
	self._ccbOwner.node_fans:setVisible(false)
	self._ccbOwner.node_other:setVisible(false)
	self._ccbOwner.node_info:setVisible(false)
	self._ccbOwner.node_fast_fight:setVisible(false)
	self._ccbOwner.node_avatar:removeAllChildren()
end

function QUIWidgetSotoTeam:setInfo(info, refresh)
	self:resetInfo()

	self._info = info

	if refresh then
		self._effect = QUIWidgetAnimationPlayer.new()
		self._effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
			self._effect = nil
		end)
		self._effect:setPositionY(10)
		self:addChild(self._effect)
	else
		if self._effect ~= nil then
			self._effect:disappear()
			self._effect = nil
		end
	end

	local actorId
	local heroInfo
	if self._info.defaultActorId and self._info.defaultActorId ~= 0 then
		actorId = self._info.defaultActorId
		heroInfo = remote.herosUtil:getSpecifiedHeroById(self._info, actorId)
	else
		heroInfo = remote.herosUtil:getMaxForceByHeros(self._info)
		actorId =  heroInfo.actorId
	end
	if actorId then
		if q.isEmpty(heroInfo) then
			heroInfo = {skinId = self._info.defaultSkinId or 0}
		end
		local showHeroInfo = clone(heroInfo)
		showHeroInfo.skinId = self._info.defaultSkinId or 0
			
		self._avatar = QUIWidgetActorDisplay.new(actorId, {heroInfo = showHeroInfo})
		self._avatar:setPositionY(-140)
		self._avatar:setScaleX(-1.1)
		self._avatar:setScaleY(1.1)
		self._ccbOwner.node_avatar:addChild(self._avatar)
	end

	self._ccbOwner.tf_user_name:setString(self._info.name or "")
	self._ccbOwner.tf_wave_value:setString(self._info.rank or 0)
	
	local force = self._info.force or 0
	local inherit_force = self._info.sotoTeamTopnForce or 0
	if inherit_force ~= 0 then -- 传承战力非0 则显示传承战力 服务器判断当前玩法
		force = inherit_force
	end
	local force, unit = q.convertLargerNumber(math.floor(force))
	self._ccbOwner.tf_force_value:setString(force..(unit or ""))
	self._ccbOwner.tf_server_name:setString(self._info.game_area_name or "")

	self._ccbOwner.node_info:setVisible(true)
	if remote.user.userId == self._info.userId then
		self._ccbOwner.node_self:setVisible(true)
		self._ccbOwner.node_other:setVisible(false)
	else
		self._ccbOwner.node_self:setVisible(false)
		self._ccbOwner.node_other:setVisible(true)
	end
	self:showTitle(self._info.title, self._info.soulTrial)
end

function QUIWidgetSotoTeam:setHideBg()
	self:showFloorBg(0)
end

function QUIWidgetSotoTeam:getUserId()
	if self._info then
		return self._info.userId
	end
	return 0
end

function QUIWidgetSotoTeam:setIsWorship(isWorship)
	self._ccbOwner.node_fans:setVisible(isWorship)

	local isFans = remote.sotoTeam:checkTodayWorshipByPos(self._info.rank)
	self._ccbOwner.node_fans_ready:setVisible(not isFans)
	self._ccbOwner.sp_fans_end:setVisible(isFans)
	self._ccbOwner.tf_fans_count:setString(self._info.worshipCount or 0)
	self._ccbOwner.tf_fans_count:setScale(1)
	local size = self._ccbOwner.tf_fans_count:getContentSize()
	if size.width > 60 then
		self._ccbOwner.tf_fans_count:setScale(60/size.width)
	end

	if isWorship then
		local rank = self._info.rank or 0
		if 4 <= rank and rank <= 5 then
			rank = 4
		end
		self:showFloorBg(rank)
	else

		local myInfo = remote.sotoTeam:getMyInfo()

	    if app.unlock:checkLock("UNLOCK_SOTO_CLEANOUT", false) then
	        self._ccbOwner.node_fast_fight:setVisible(true)
			if myInfo.curRank < self._info.rank then
				self._isFastFlag = true
				self._ccbOwner.tf_fast_fight:setString("扫荡")
			else
				self._isFastFlag = false
				self._ccbOwner.tf_fast_fight:setString("自动战斗")
			end        
	    else
	        self._ccbOwner.node_fast_fight:setVisible(myInfo.curRank < self._info.rank)
			self._isFastFlag = true
			self._ccbOwner.tf_fast_fight:setString("扫荡")
	    end
	    	
		self._ccbOwner.node_reduce_effect:setVisible(app.tip:checkReduceUnlokState("sotoTeamFastBattle"))
		self:showFloorBg(5)
	end
end

function QUIWidgetSotoTeam:showFans(callback)
	self._effectPlayer = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.node_effect:addChild(self._effectPlayer)
	self._effectPlayer:playAnimation("ccb/effects/mobai.ccbi", nil, function ()
		self._ccbOwner.node_effect:removeAllChildren()
		self:setIsWorship(true)
		if callback then
			callback()
		end
	end)
end

function QUIWidgetSotoTeam:setCascadeOpacity()
    self:setNodeCascadeOpacityEnabled(self._ccbOwner.node_all)
end

function QUIWidgetSotoTeam:setNodeCascadeOpacityEnabled( node )
    -- body
    if node then
        node:setCascadeOpacityEnabled(true)
        local children = node:getChildren()
        if children then
            for index = 0, children:count()-1, 1 do
                local tempNode = children:objectAtIndex(index)
                local tempNode = tolua.cast(tempNode, "CCNode")
                if tempNode then
                    self:setNodeCascadeOpacityEnabled(tempNode)
                end
            end
        end
    end
end

function QUIWidgetSotoTeam:setOpacity(opacity)
	self._ccbOwner.node_all:setOpacity(opacity)
end

function QUIWidgetSotoTeam:setAvatarScale(scale)
	self._ccbOwner.node_avatar:setScaleX(scale)
end

function QUIWidgetSotoTeam:setBgScaleY(scaleY)
	for i = 1, 5 do
		if i ~= 1 and self._ccbOwner["node_bg_"..i]:isVisible() then
			self._ccbOwner["sp_bg_"..i]:setScaleY(scaleY)
			break
		end
	end
end

function QUIWidgetSotoTeam:showFloorBg(floor)
	for i = 1, 5 do
		self._ccbOwner["node_bg_"..i]:setVisible(false)
	end
	if self._ccbOwner["node_bg_"..floor] then
		self._ccbOwner["node_bg_"..floor]:setVisible(true)
	end
end

function QUIWidgetSotoTeam:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetSotoTeam:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

function QUIWidgetSotoTeam:showWord(str)
	self:removeWord()
	if self._info == nil then return end
	local word = "封号斗罗"
	if str ~= nil then
		word = str
	elseif self._words ~= nil then
		local maxCount = table.nums(self._words)
		local count = math.random(1, maxCount)
		for _,value in pairs(self._words) do
			if value.id == count then
				word = value.langaue
				break
			end
		end
	end

	if self._wordWidget == nil then
		self._wordWidget = QChatDialog.new()
		self:addChild(self._wordWidget)
	end
	self._wordWidget:setPosition(ccp(80, 150))
	self._wordWidget:setString(word)
end

function QUIWidgetSotoTeam:showDeadEffect( callback )
	if self._avatar then
		self._avatar:displayWithBehavior(ANIMATION_EFFECT.DEAD)
		self._avatar:setDisplayBehaviorCallback(function ()
			self._avatar:setVisible(false)
			if callback then
				callback()
			end
		end)
	else
		if callback then
			callback()
		end
	end
end

function QUIWidgetSotoTeam:_onTriggerFastFight(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fast_fight) == false then return end
	self:dispatchEvent({name = QUIWidgetSotoTeam.EVENT_QUICK_BATTLE, info = self._info,isFastFight = self._isFastFlag})
end

function QUIWidgetSotoTeam:_onTriggerFans(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fans) == false then return end
	self:dispatchEvent({name = QUIWidgetSotoTeam.EVENT_WORSHIP, info = self._info})
end

function QUIWidgetSotoTeam:_onTriggerInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_info) == false then return end
	self:dispatchEvent({name = QUIWidgetSotoTeam.EVENT_VISIT, info = self._info})
end

function QUIWidgetSotoTeam:_onTriggerAvatar()
	self:dispatchEvent({name = QUIWidgetSotoTeam.EVENT_BATTLE, info = self._info})
end

return QUIWidgetSotoTeam