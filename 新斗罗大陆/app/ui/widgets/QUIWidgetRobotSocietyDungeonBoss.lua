--
-- Author: Kumo.Wang
-- Date: Tue May 24 19:01:52 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRobotSocietyDungeonBoss = class("QUIWidgetRobotSocietyDungeonBoss", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetActorActivityDisplay = import(".actorDisplay.QUIWidgetActorActivityDisplay")

QUIWidgetRobotSocietyDungeonBoss.EVENT_CLICK = "QUIWidgetRobotSocietyDungeonBoss_EVENT_CLICK"
QUIWidgetRobotSocietyDungeonBoss.EVENT_DEAD = "QUIWidgetRobotSocietyDungeonBoss_EVENT_DEAD"

function QUIWidgetRobotSocietyDungeonBoss:ctor(options)
	local ccbFile = "ccb/Widget_society_fuben_zidong.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetRobotSocietyDungeonBoss._onTriggerClick)},
	}
	QUIWidgetRobotSocietyDungeonBoss.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
	self._curHp = options.bossHp
	self._chapter = options.chapter
	self._wave = options.wave
	self._index = options.wave

	self._isDead = true

	local scoietyWaveConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	self._bossId = scoietyWaveConfig.boss
	self._bossLevel = scoietyWaveConfig.levels

	self._initTotalHpScaleX = self._ccbOwner.sp_hp:getScaleX()

	-- self._ccbOwner.tf_name = setShadow5(self._ccbOwner.tf_name)

	self:_init()
end

function QUIWidgetRobotSocietyDungeonBoss:onEnter()

end

function QUIWidgetRobotSocietyDungeonBoss:onExit()

end

function QUIWidgetRobotSocietyDungeonBoss:getSize()
	return self._ccbOwner.s9s_size:getContentSize()
end

function QUIWidgetRobotSocietyDungeonBoss:isDead()
	return self._curHp == 0
end

function QUIWidgetRobotSocietyDungeonBoss:updateHp( curHp )
	if curHp then self._curHp = curHp end

	local totalHp = self:getTotalHp( self._bossId, self._bossLevel )
	local sx = self._curHp / totalHp * self._initTotalHpScaleX
	-- print("[Kumo] 血条 ", self._curHp, totalHp, sx, self._initTotalHpScaleX)
	self._ccbOwner.sp_hp:setScaleX( sx )

	if self._curHp > 0 then
		self._ccbOwner.node_zhenwang:setVisible(false)
	else
		self._ccbOwner.node_zhenwang:setVisible(true)
	end
end

function QUIWidgetRobotSocietyDungeonBoss:getTotalHp( bossId, bossLevel )
	if not self._bossId or not self._bossLevel then return 0 end

	if not bossId then bossId = self._bossId end
	if not bossLevel then bossLevel = self._bossLevel end

	local characterData = QStaticDatabase.sharedDatabase():getCharacterDataByID( bossId, bossLevel )
	local totalHp = characterData.hp_value + characterData.hp_grow * characterData.npc_level

	return totalHp
end

function QUIWidgetRobotSocietyDungeonBoss:_init()
	local character = QStaticDatabase.sharedDatabase():getCharacterByID(self._bossId)
	self._ccbOwner.tf_name:setString(character.name)
	local head = CCSprite:create("res/"..character.icon)
	self._ccbOwner.node_head:addChild(head, -1)
	local colors = QResPath("color_frame_purple")
	self:addSpriteFrame(self._ccbOwner.node_rect_normal, colors[1])
	self:_showBossType()
	self:updateHp()
end

function QUIWidgetRobotSocietyDungeonBoss:addSpriteFrame(sp, frameName)
	if string.find(frameName, "%.plist") ~= nil then
		sp:setDisplayFrame(QSpriteFrameByPath(frameName))
	else
		local texture = CCTextureCache:sharedTextureCache():addImage(frameName)
		sp:setTexture(texture)
		local size = texture:getContentSize()
		local rect = CCRectMake(0, 0, size.width, size.height)
		sp:setTextureRect(rect)
	end
end

function QUIWidgetRobotSocietyDungeonBoss:_showBossType()
	local bossConfig = QStaticDatabase.sharedDatabase():getScoietyWave(self._wave, self._chapter)
	local index = 1
	while true do
		local node = self._ccbOwner["sp_bossType_"..index]
		if node then
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end
	if bossConfig and bossConfig.boss_type then
		local px, py = 0, -100
		local tfw = self._ccbOwner.tf_name:getContentSize().width
		local tbl = string.split(bossConfig.boss_type, ";")
		local count = table.nums(tbl)
		if tbl and count > 0 then
			for i, value in pairs(tbl) do
				local node = self._ccbOwner["sp_bossType_"..value]
				if node then
					node:setVisible(true)
					local nx = px
					local ny = py
					if count ~= 1 then
						if i == 1 then
							nx = px - node:getContentSize().width/2
						else
							nx = px + node:getContentSize().width/2
						end
					end
					node:setPosition(nx, ny)
				end
			end
		end
	end
end

return QUIWidgetRobotSocietyDungeonBoss