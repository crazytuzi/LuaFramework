local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockBattleMonster = class("QUIWidgetBlackRockBattleMonster", QUIWidget)
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QStaticDatabase = import("....controllers.QStaticDatabase")

QUIWidgetBlackRockBattleMonster.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetBlackRockBattleMonster.FAST_FIGHTER = "FAST_FIGHTER"

function QUIWidgetBlackRockBattleMonster:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_zdren2.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
        {ccbCallbackName = "onTriggerFastFighter", callback = handler(self, self._onTriggerFastFighter)},
    }
	QUIWidgetBlackRockBattleMonster.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._originalScaleX = self._ccbOwner.node_sp:getScaleX()
	self._originalPosY = self._ccbOwner.node_figher:getPositionY()
	q.setButtonEnableShadow(self._ccbOwner.btn_saodang)
end

function QUIWidgetBlackRockBattleMonster:setDungeonId(dungeonInfo,isMyself)
	self._isMyself = isMyself
	self._dungeonInfo = dungeonInfo
	self._soulSpiritId = dungeonInfo.soulSpiritId
	self._battleVerify = dungeonInfo.battleVerify
	self._dungeonId = dungeonInfo.stepId
    if self._buffWidget ~= nil then
        self._buffWidget:removeFromParent()
        self._buffWidget = nil
    end
  
    self:hideFun()
	if self._dungeonInfo.isNpc == true then
		self._ccbOwner.node_monster:setVisible(true)
		local dungeonConfig = remote.blackrock:getConfigByDungeonId(self._dungeonId)
		if self._avatar ~= nil then
			self._avatar:removeFromParent()
			self._avatar = nil
		end
		self._avatar = QUIWidgetActorDisplay.new(dungeonConfig.monster_id)

		self._ccbOwner.node_avatar:addChild(self._avatar)
		local scale = 1
		if dungeonConfig.monster_id_size ~= nil then
			scale = tonumber(dungeonConfig.monster_id_size)
		end
		self._avatar:setScale(scale)

		local offsetY = 0
		if dungeonConfig.weapon_location ~= nil then
			offsetY = tonumber(dungeonConfig.weapon_location)
		end
		self._ccbOwner.node_figher:setPositionY(self._originalPosY + offsetY)

		self._ccbOwner.tf_role:setString(dungeonConfig.monster_name)
        self._ccbOwner.tf_role:setString(dungeonConfig.monster_name)
        self._combatTeamId = dungeonConfig.combat_team_id
        if dungeonConfig.combat_team_id == 1 then
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.blue)
        elseif dungeonConfig.combat_team_id == 2 then
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.purple)
        elseif dungeonConfig.combat_team_id == 3 then
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.orange)
        elseif dungeonConfig.combat_team_id == 4 then
            self._ccbOwner.tf_role:setColor(UNITY_COLOR_LIGHT.red)
        end
        		
		self:showDead(false)

        self:hideFun(dungeonConfig.character_monster_sign)

		local num,unit = q.convertLargerNumber(dungeonConfig.monster_battleforce)
		self._ccbOwner.tf_force:setString(num..(unit or ""))
		-- self._ccbOwner.node_figher:setVisible(false)
		self:setFight(false)
		self:setHpVisible(false)

		local dungeonStrId = QStaticDatabase:sharedDatabase():convertDungeonID(self._dungeonId)
		local left, max = app:getMonsterTotalLeftHp(dungeonInfo.npcsHpMp, dungeonStrId)
		self:setHp(self._originalScaleX * math.min(left/max, 1))
	else
		
		self._ccbOwner.node_monster:setVisible(false)
        local buffConfig = QStaticDatabase:sharedDatabase():getBlackRockBuffId(self._dungeonId)
        if buffConfig == nil then
            app.tip:floatTip("【"..self._buffId.."】ID的BUFF在量表中未找到~")
            return
        end
        local buffPath = QSpriteFrameByPath(buffConfig.buff_photo_site)
        self._buffWidget = CCSprite:createWithSpriteFrame(buffPath)
        if self._buffWidget then
            self:getView():addChild(self._buffWidget)
            self._buffWidget:setPosition(ccp(5, 30))         
        end  

		
        -- local buffConfig = QStaticDatabase:sharedDatabase():getBlackRockBuffId(self._dungeonId)
        -- self._buffWidget = QUIWidget.new("ccb/effects/"..buffConfig.buff_photo_site..".ccbi")
        -- self:getView():addChild(self._buffWidget)
	end
end

function QUIWidgetBlackRockBattleMonster:getIsNpc()
	return self._dungeonInfo.isNpc
end

function QUIWidgetBlackRockBattleMonster:hideFun(index)
	self._ccbOwner.sp_single:setVisible(false)
	self._ccbOwner.sp_attack:setVisible(false)
	self._ccbOwner.sp_armor:setVisible(false)
	self._ccbOwner.sp_multi:setVisible(false)
	if index ~= nil then
    	if index == 1 then
			self._ccbOwner.sp_attack:setVisible(true)
		elseif index == 2 then
			self._ccbOwner.sp_armor:setVisible(true)
		elseif index == 3 then
			self._ccbOwner.sp_multi:setVisible(true)
		elseif index == 4 then
			self._ccbOwner.sp_single:setVisible(true)
		end
	end
end

--播放动作
function QUIWidgetBlackRockBattleMonster:avatarPlayAnimation(value, callback)
	if self._avatar ~= nil then
		self._avatar:displayWithBehavior(value)
		self._avatar:setDisplayBehaviorCallback(callback)
	end
end

function QUIWidgetBlackRockBattleMonster:stopDisplay( ... )
	if self._avatar ~= nil then
		self._avatar:stopDisplay()
	end
end

--设置血量
function QUIWidgetBlackRockBattleMonster:setHp(scale)
	self._ccbOwner.node_sp:setScaleX(scale)
end

function QUIWidgetBlackRockBattleMonster:showDead(b)
	self._maxPassBossId = remote.blackrock:getMaxCombatTeamId()
	self._ccbOwner.node_dead:setVisible(b and self._dungeonInfo.isNpc == true)
	if app.unlock:checkLock("UNLOCK_CHUANLINGTA_SAODANG", false) then
		if self._combatTeamId and tonumber(self._maxPassBossId) >= tonumber(self._combatTeamId) and self._isMyself then
			self._ccbOwner.btn_fastFighter:setVisible(not b and self._dungeonInfo.isNpc == true)
		else
			self._ccbOwner.btn_fastFighter:setVisible(false)
		end
	else
		self._ccbOwner.btn_fastFighter:setVisible(false)
	end
	self._ccbOwner.node_monster:setVisible(not b and self._dungeonInfo.isNpc == true)
	if self._buffWidget ~= nil then
		self._buffWidget:setVisible(not b and self._dungeonInfo.isNpc == false)
	end
end

function QUIWidgetBlackRockBattleMonster:getAvatar()
	return self._avatar
end

function QUIWidgetBlackRockBattleMonster:setFight(b)
	self._ccbOwner.node_figher:setVisible(b)
end

function QUIWidgetBlackRockBattleMonster:setHpVisible(b)
	self._ccbOwner.node_hp:setVisible(b)
end

function QUIWidgetBlackRockBattleMonster:setGridPos(pos)
	self._gridPos = pos
end

function QUIWidgetBlackRockBattleMonster:getGridPos()
	return self._gridPos
end

function QUIWidgetBlackRockBattleMonster:_onTriggerClick(e)
	self:dispatchEvent({name = QUIWidgetBlackRockBattleMonster.EVENT_CLICK, dungeonId = self._dungeonId,soulSpiritId = self._soulSpiritId,battleVerify=self._battleVerify})
end

function QUIWidgetBlackRockBattleMonster:_onTriggerFastFighter(event)
	if not app.unlock:checkLock("UNLOCK_CHUANLINGTA_SAODANG", false) then
		return
	end
	-- if q.buttonEventShadow(event,self._ccbOwner.btn_saodang) == false then return end
	self:dispatchEvent({name = QUIWidgetBlackRockBattleMonster.FAST_FIGHTER, dungeonId = self._dungeonId,soulSpiritId = self._soulSpiritId,battleVerify=self._battleVerify})
end
return QUIWidgetBlackRockBattleMonster