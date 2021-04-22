	-- @Author: xurui
-- @Date:   2018-08-13 14:51:02
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-23 18:04:32
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMetalCity = class("QUIWidgetMetalCity", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QChatDialog = import("...utils.QChatDialog")

QUIWidgetMetalCity.EVENT_CLICK_RECORD = "EVENT_CLICK_RECORD"
QUIWidgetMetalCity.EVENT_CLICK_FASTFIGHT = "EVENT_CLICK_FASTFIGHT"
QUIWidgetMetalCity.EVENT_CLICK_BOSSDATA = "EVENT_CLICK_BOSSDATA"
QUIWidgetMetalCity.EVENT_CLICK_FIGHT = "EVENT_CLICK_FIGHT"
QUIWidgetMetalCity.EVENT_CLICK_SKILL = "EVENT_CLICK_SKILL"

function QUIWidgetMetalCity:ctor(options)
	local ccbFile = "ccb/Widget_tower_client.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
		{ccbCallbackName = "onTriggerFastFight", callback = handler(self, self._onTriggerFastFight)},
		{ccbCallbackName = "onTriggerBossData", callback = handler(self, self._onTriggerBossData)},
		{ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
		{ccbCallbackName = "onTriggerSkill1", callback = handler(self, self._onTriggerSkill1)},
		{ccbCallbackName = "onTriggerSkill2", callback = handler(self, self._onTriggerSkill2)},
    }
    QUIWidgetMetalCity.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._bgScale = CalculateUIBgSize(self._ccbOwner.node_bg_main, 1280)
    CalculateUIBgSize(self._ccbOwner.node_floor, 1280)

    q.setButtonEnableShadow(self._ccbOwner.btn_boss_data)

	self._itemBoxs = {}
	self._bossAvatar = {}
	self._bossEffectAvatars = {}

	self._skillBox = {}
	self._bossEffect = {}
	self._offsetHeight = 0

	local posOffsetX = (self._ccbOwner.sp_bg_size:getContentSize().width * self._ccbOwner.sp_bg_size:getScaleX() - display.width)
	self:getCCBView():setPositionX(self:getCCBView():getPositionX() - posOffsetX/2)
end

function QUIWidgetMetalCity:onEnter()
end

function QUIWidgetMetalCity:onExit()
end

function QUIWidgetMetalCity:setInfo(info, index)
	self._info = info
	self._index = index
	self._myInfoDict = remote.metalCity:getMetalCityMyInfo()

	self._ccbOwner.sp_bg_cloud:setVisible(false)
	self._ccbOwner.node_floor:setVisible(true)
	if self._info.isShowCloud then
		self._ccbOwner.sp_bg_cloud:setVisible(true)
		self._ccbOwner.node_floor:setVisible(false)
	else
		self._ccbOwner.tf_instance_num:setString(string.format("%s-%s", self._info.metalcity_chapter, self._info.metalcity_floor))

		self:setMyAvatarInfo()

		self:setBossInfo()

		self:setAwardClient()

		self:setSkillInfo()

	end
	self:showBg()
end

function QUIWidgetMetalCity:setMyAvatarInfo()
	if self._info.num  == (self._myInfoDict.metalNum or 0) + 1 then
		if self._myAvatar == nil then
			self._myAvatar = QUIWidgetHeroInformation.new()
			self._ccbOwner.node_avatar:addChild(self._myAvatar)
		end
		self._myAvatar:setVisible(true)
		self._myAvatar:setAvatarByHeroInfo({skinId = remote.user.defaultSkinId}, remote.user.defaultActorId, 1.1)
		self._myAvatar:setNameVisible(false)
		self._ccbOwner.sp_vs:setVisible(true)
	else
		if self._myAvatar then
			self._myAvatar:setVisible(false)
		end
		self._ccbOwner.sp_vs:setVisible(false)
	end
end

function QUIWidgetMetalCity:setBossInfo()
	local isPass = self._info.num <= (self._myInfoDict.metalNum or 0)
	local isCurrentFloor = self._info.num  == (self._myInfoDict.metalNum or 0) + 1
	local config
	for i = 1, 2 do
		local trailInfo = remote.metalCity:getMetalCityMapConfigById(self._info["dungeon_id_"..i])
		if isPass then
			self._ccbOwner["sp_dead_"..i]:setVisible(true)
			self._ccbOwner["node_boss_"..i]:setVisible(false)
			self._ccbOwner["node_boss_info_"..i]:setVisible(false)
		else
			if self._bossAvatar[i] == nil then
				self._bossAvatar[i] = QUIWidgetHeroInformation.new()
				self._ccbOwner["node_boss_"..i]:addChild(self._bossAvatar[i])
			end
			if trailInfo then
				self._bossAvatar[i]:setAvatarByHeroInfo({}, trailInfo.monster_id, trailInfo.boss_size or 1)
				self._bossAvatar[i]:setNameVisible(false)
				self._bossAvatar[i]:setScaleX(-1)
			end
			self._ccbOwner["node_boss_info_"..i]:setVisible(true)
			self._ccbOwner["node_boss_"..i]:setVisible(true)
			self._ccbOwner["sp_dead_"..i]:setVisible(false)

			if isCurrentFloor then
				makeNodeFromGrayToNormal(self._bossAvatar[i])
			else
				makeNodeFromNormalToGray(self._bossAvatar[i])
				self._bossAvatar[i]:getAvatar():getActor():getSkeletonView():pauseAnimation()
			end
		end


		if trailInfo then
			local bossInfo = QStaticDatabase:sharedDatabase():getCharacterByID(trailInfo.monster_id)
			local monsterInfo = QStaticDatabase:sharedDatabase():getDungeonConfigByID(trailInfo.dungeon_id)
		    local monster = QStaticDatabase:sharedDatabase():getMonstersById(monsterInfo.monster_id)
		    local npc_level = 0
		    if monster and monster[1] then
		    	npc_level =  monster[1].npc_level or 0
		    end
			self._ccbOwner["tf_name_"..i]:setString(string.format("LV.%s %s", npc_level, bossInfo.name or ""))
		end

		local num, str = q.convertLargerNumber(self._info["metalcity_force_saodang_"..i] or 0)
		self._ccbOwner["tf_force_"..i]:setString(num..str)

		self._ccbOwner["tf_trail_title_"..i]:setVisible(isCurrentFloor)

		if config == nil then
			config = trailInfo
		end

		self:createBossEffect(i, isCurrentFloor, trailInfo)
	end

	
	if q.isEmpty(config) == false then
		if isCurrentFloor and isPass == false and config.word and self._wordWidget == nil then
			local array = CCArray:create()
			array:addObject(CCDelayTime:create(3))
			array:addObject(CCCallFunc:create(function()
					self:showWord(config.word)
				end))
			self._wordAction = self:getCCBView():runAction(CCSequence:create(array))
		else
			self:removeWord()
			if self._wordAction then
				self:getCCBView():stopAction(self._wordAction)
				self._wordAction = nil
			end
		end
	end

	self._ccbOwner.node_btn_fastFight:setVisible(isPass)
end

function QUIWidgetMetalCity:setAwardClient()
	local awards = QStaticDatabase:sharedDatabase():getluckyDrawById(self._info.box_1)
	local isPass = self._info.num <= (self._myInfoDict.metalNum or 0)
	local titleStr = "首通\n奖励"
	if isPass then
		awards = QStaticDatabase:sharedDatabase():getluckyDrawById(self._info.box_2)
		titleStr = "扫荡\n奖励"
	end
	self._ccbOwner.tf_award_title:setString(titleStr)
	self._ccbOwner.sp_award_bg:setVisible(not isPass)
	self._ccbOwner.node_item:removeAllChildren()
	self._itemBoxs = {}
	
	for i = 1, #awards do
		if self._itemBoxs[i] == nil then
			self._itemBoxs[i] = QUIWidgetItemsBox.new()
			self._itemBoxs[i]:setPositionX(95*i-95)
			self._ccbOwner.node_item:addChild(self._itemBoxs[i])
		end
		self._itemBoxs[i]:setGoodsInfo(awards[i].id, awards[i].typeName, awards[i].count)
	end
end

function QUIWidgetMetalCity:setSkillInfo()
	for i = 1, 2 do
		if self._info["jiguan_"..i] then
			self._ccbOwner["node_no_skill_"..i]:setVisible(false)
			self._ccbOwner["node_skill_"..i]:setVisible(true)
			if self._skillBox[i] == nil then
				self._skillBox[i] = QUIWidgetHeroSkillBox.new()
				self._ccbOwner["node_skill_"..i]:addChild(self._skillBox[i])
				self._skillBox[i]:setLock(false)
			end
			self._skillBox[i]:setSkillID(self._info["jiguan_"..i])
		else
			self._ccbOwner["node_no_skill_"..i]:setVisible(true)
			self._ccbOwner["node_skill_"..i]:setVisible(false)
		end
	end
end

function QUIWidgetMetalCity:createBossEffect(i, isCurrentFloor, trailInfo)
	if isCurrentFloor then
		if self._bossEffect[i] == nil then
			self._bossEffect[i] = QUIWidgetAnimationPlayer.new()
			self._ccbOwner["node_boss_effect_"..i]:addChild(self._bossEffect[i])
		end
		self._bossEffect[i]:setVisible(true)
		self._bossEffect[i]:setScale(0.7)
		self._ccbOwner["node_boss_effect_"..i]:setPositionY(trailInfo.starsY or 60)
		self._bossEffect[i]:playAnimation("ccb/effects/battle_ing.ccbi", nil, nil, false)
	else
		if self._bossEffect[i] then
			self._bossEffect[i]:setVisible(false)
		end
	end
end

function QUIWidgetMetalCity:showWord(str)
	if self._wordAction then
		self:getCCBView():stopAction(self._wordAction)
		self._wordAction = nil
	end
	self:removeWord()

	local word = "啦啦啦！啦啦啦！我是卖报的小行家！"
	if str ~= nil then
		word = str
	end
	self._wordWidget = QChatDialog.new()
	self._wordWidget:setPosition(ccp(-50, 0))
	self._ccbOwner.node_boss_word_1:addChild(self._wordWidget)
	self._wordWidget:setString(word)
	self._wordWidget:setScaleX(-1)

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(5.2))
	array:addObject(CCCallFunc:create(function()
			self:removeWord()
		end))
	array:addObject(CCDelayTime:create(7))
	array:addObject(CCCallFunc:create(function()
			self:showWord(str)
		end))
	self._wordAction = self:getCCBView():runAction(CCSequence:create(array))
end

function QUIWidgetMetalCity:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

function QUIWidgetMetalCity:showBg()
	self._ccbOwner.node_bg:removeAllChildren()
	self._ccbOwner.node_bg_2:removeAllChildren()

	self._offsetHeight = 0
	local trailInfo = remote.metalCity:getMetalCityMapConfigById(self._info.dungeon_id_1)
	if self._index == 1 then
		self._ccbOwner.sp_bg_ceiling:setVisible(true)
		if trailInfo.floor then
			QSetDisplayFrameByPath(self._ccbOwner.sp_bg_ceiling, trailInfo.floor)
		end
		self._offsetHeight = self._ccbOwner.sp_bg_floor:getContentSize().height
		self:getCCBView():setPositionY(-315 * self._bgScale)
	elseif self._index == 20 then
		if trailInfo.file then
	        local proxy = CCBProxy:create()
	        local root = CCBuilderReaderLoad(trailInfo.file, proxy, {})
			self._ccbOwner.node_bg_2:addChild(root)
		end
		self._offsetHeight = self._ccbOwner.sp_bg_ceiling:getContentSize().height
	else
		self._ccbOwner.sp_bg_ceiling:setVisible(false)
		self:getCCBView():setPositionY(-220 * self._bgScale)
	end

	if trailInfo.file then
        local proxy = CCBProxy:create()
        local root = CCBuilderReaderLoad(trailInfo.file, proxy, {})
		self._ccbOwner.node_bg:addChild(root)
	end
	
	if trailInfo.floor then
		QSetDisplayFrameByPath(self._ccbOwner.sp_bg_floor, trailInfo.floor)
	end

	self._ccbOwner.sp_bg_ceiling:setVisible(self._index == 1)

end

function QUIWidgetMetalCity:setAvatarStated(stated)
	if self._myAvatar then
		self._myAvatar:setVisible(stated)
	end
end

function QUIWidgetMetalCity:showPassOutEffect(deathEffct, callback)
	self:createEffectAvatar()

	self:setAvatarStated(false)
	local passOutEffect = function()
		self._effectMyAvatar:getActorView():runAction(CCFadeTo:create(0.7, 0))

		local avatarEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.node_avatar:addChild(avatarEffect)
		avatarEffect:setPositionY(-150)
		avatarEffect:playAnimation("ccb/effects/jijia_chuxian.ccbi", nil, function()
				self._effectMyAvatar:removeFromParent()
				self._effectMyAvatar = nil
				if callback then
					callback()
				end
			end, false)
	end

	if deathEffct then
		self:showBossDeathEffect(true, function()
				passOutEffect()
			end)
	else
		passOutEffect()
	end

end

function QUIWidgetMetalCity:showPassInEffect(callback)
	self:createEffectAvatar()
	self._effectMyAvatar:getActorView():setOpacity(0)
	self._effectMyAvatar:getActorView():setPositionX(100)

	local time = 0.2
	local array = CCArray:create()
	local array1 = CCArray:create()
	array1:addObject(CCFadeIn:create(time))
	array1:addObject(CCMoveTo:create(time, ccp(0, 0)))
	array:addObject(CCSpawn:create(array1))
	array:addObject(CCCallFunc:create(function()
			self:setAvatarStated(true)
			self._effectMyAvatar:removeFromParent()
			if callback then
				callback()
			end
		end))
	self._effectMyAvatar:getActorView():runAction(CCSequence:create(array))
end

function QUIWidgetMetalCity:createEffectAvatar()
	if self._effectMyAvatar == nil then
		self._effectMyAvatar = QUIWidgetHeroInformation.new()
		self._ccbOwner.node_avatar:addChild(self._effectMyAvatar)
		self._effectMyAvatar:setAvatarByHeroInfo({skinId = remote.user.defaultSkinId}, remote.user.defaultActorId, 1.1)
		self._effectMyAvatar:setNameVisible(false)
	end
end

function QUIWidgetMetalCity:showBossDeathEffect(showDeathEffct, callback)
	local endIndex = 0
	for i = 1, 2 do
		self._ccbOwner["sp_dead_"..i]:setVisible(false)
		self._ccbOwner["node_boss_"..i]:setVisible(true)
		self._ccbOwner["node_boss_info_"..i]:setVisible(true)
		if self._bossAvatar[i] then
			self._bossAvatar[i]:setVisible(false)
		end

		local trailInfo = remote.metalCity:getMetalCityMapConfigById(self._info["dungeon_id_"..i])

		if self._bossEffectAvatars[i] == nil then
			self._bossEffectAvatars[i] = QUIWidgetHeroInformation.new()
			self._ccbOwner["node_boss_"..i]:addChild(self._bossEffectAvatars[i])
		end

		if trailInfo then
			self._bossEffectAvatars[i]:setAvatarByHeroInfo({}, trailInfo.monster_id, trailInfo.boss_size or 1)
			self._bossEffectAvatars[i]:setNameVisible(false)
			self._bossEffectAvatars[i]:setScaleX(-1)
		end

		if showDeathEffct then
			self._bossEffectAvatars[i]:getAvatar():displayWithBehavior(ANIMATION_EFFECT.DEAD)
			self._bossEffectAvatars[i]:getAvatar():setDisplayBehaviorCallback(function ()
				endIndex = endIndex + 1

				self._ccbOwner["sp_dead_"..i]:setVisible(true)
				self._ccbOwner["node_boss_"..i]:setVisible(false)
				self._ccbOwner["node_boss_info_"..i]:setVisible(false)
				if endIndex == 2 then
					if callback then
						callback()
					end
				end
			end)
		end
	end
end

function QUIWidgetMetalCity:registerItemBoxPrompt( index, list )
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index, k, v)
	end
end

function QUIWidgetMetalCity:_onTriggerSkill1(event)
	if event == nil then return end
	
	if self._info.jiguan_1 then
		self:dispatchEvent({name = QUIWidgetMetalCity.EVENT_CLICK_SKILL, skillId = self._info.jiguan_1})
	end
end

function QUIWidgetMetalCity:_onTriggerSkill2(event)
	if event == nil then return end

	if self._info.jiguan_2 then
		self:dispatchEvent({name = QUIWidgetMetalCity.EVENT_CLICK_SKILL, skillId = self._info.jiguan_2})
	end
end

function QUIWidgetMetalCity:getContentSize()
	local size = self._ccbOwner.sp_bg_size:getContentSize()

	return CCSize(size.width * self._bgScale, (size.height + self._offsetHeight) * self._bgScale)
end 
 
function QUIWidgetMetalCity:_onTriggerRecord(event)
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCity.EVENT_CLICK_RECORD, info = self._info})
end

function QUIWidgetMetalCity:_onTriggerFastFight(event)
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCity.EVENT_CLICK_FASTFIGHT, info = self._info})
end

function QUIWidgetMetalCity:_onTriggerBossData()
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCity.EVENT_CLICK_BOSSDATA, info = self._info})
end

function QUIWidgetMetalCity:_onTriggerFight()
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetMetalCity.EVENT_CLICK_FIGHT, info = self._info})
end

return QUIWidgetMetalCity
