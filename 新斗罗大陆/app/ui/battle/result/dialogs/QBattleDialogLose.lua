--
-- Author: Your Name
-- Date: 2014-05-20 10:08:48
--
local QBattleDialog = import("...QBattleDialog")
local QBattleDialogLose = class(".QBattleDialogLose", QBattleDialog)

local QTutorialDefeatedGuide = import(".....tutorial.defeated.QTutorialDefeatedGuide")
local QStaticDatabase = import(".....controllers.QStaticDatabase")
local QBattleDialogAgainstRecord = import(".....ui.battle.QBattleDialogAgainstRecord")

local function pass()
	return true
end

local function noPass()
	return false
end 

function QBattleDialogLose:ctor(data, owner)
	local ccbFile = "ccb/Battle_Dialog_Defeat.ccbi"
	local callBacks = {
						{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogLose._onTriggerNext)},
						{ccbCallbackName = "onDefeatedGuide", callback = handler(self, QBattleDialogLose._onDefeatedGuide)},
						{ccbCallbackName = "onTriggerData", callback = handler(self, QBattleDialogLose._onTriggerData)},
					}

	if owner == nil then 
		owner = {}
	end

	QBattleDialogLose.super.ctor(self,ccbFile,owner,callBacks)

	self.guidePrompts = {
		{title = "魂师升级", typeName = "up_hero", pic = "btn_exp", sp = "sp_exp", condition = handler(self, self.checkUpgradePass), event = QTutorialDefeatedGuide.UPGRADE},
		{title = "装备突破", typeName = "break_through", pic = "btn_equipment_break", sp = "sp_equipment_break", condition = handler(self, self.checkEvolve1Pass), event = QTutorialDefeatedGuide.EVOLVE1},
		{title = "魂师升星", typeName = "hero_star", pic = "btn_grade", sp = "sp_grade", condition = handler(self, self.checkStarupPass), event = QTutorialDefeatedGuide.STARUP},
		{title = "成长大师", typeName = "grow_up", pic = "btn_grow", sp = "sp_grow", condition = handler(self, self.checkHeroGrow), event = QTutorialDefeatedGuide.GROW},
		{title = "魂技升级", typeName = "up_skill", pic = "btn_skill", sp = "sp_skill", condition = handler(self, self.checkSkillPass), event = QTutorialDefeatedGuide.SKILL},
		{title = "酒馆召唤", typeName = "tavern_summon", pic = "btn_chest", sp = "sp_chest", condition = pass, event = QTutorialDefeatedGuide.TAVERN},
		-- {title = "装备穿戴", pic = "equipment", comment = "穿戴齐战甲才能英勇杀敌，\n快去穿装备！", condition = handler(self, self.checkAvailableEquipmentPass), event = QTutorialDefeatedGuide.EQUIPMENT},
		-- {title = "装备获取", pic = "farm", comment = "点“+”号可以快捷刷装备，\n小伙伴你知道嘛！", condition = handler(self, self.checkFarmPass), event = QTutorialDefeatedGuide.FARM},
		-- {title = "装备强化", pic = "enhance", comment = "装备强化可以提高装备属性哦！", condition = handler(self, self.checkEnhancePass), event = QTutorialDefeatedGuide.ENHANCE},
		-- {title = "装备突破", pic = "evolution", comment = "装备突破后会变得更厉害！材料不足也要辛勤收集哦~", condition = handler(self, self.checkEvolve2Pass), event = QTutorialDefeatedGuide.EVOLVE2},
		-- {title = "装备觉醒", pic = "enchant", comment = "装备觉醒可以大幅度提升装备强化增加的属性！", condition = handler(self, self.checkEnchantPass), event = QTutorialDefeatedGuide.ENCHANTE},
	}
	self._actorId = nil
	self._battleHeroes = {}
	for _, v in ipairs(app.battle:getHeroes()) do
		-- nzhang: 有可能是join hero，所以用remote.herosUtil:getUIHeroByID(v:getActorID())判断一下先
		if not app.battle:isGhost(v) and remote.herosUtil:getUIHeroByID(v:getActorID()) then
			table.insert(self._battleHeroes, v:getActorID())
		end
	end
	for _, v in ipairs(app.battle:getDeadHeroes()) do
		if not app.battle:isGhost(v) and remote.herosUtil:getUIHeroByID(v:getActorID()) then
			table.insert(self._battleHeroes, v:getActorID())
		end
	end
	for _, v in ipairs(app.battle:getSupportHeroes()) do
		if not app.battle:isGhost(v) and remote.herosUtil:getUIHeroByID(v:getActorID()) then
			table.insert(self._battleHeroes, v:getActorID())
		end
	end
	-- app.battle:resume()
	-- self._ccbOwner.title = setShadow(self._ccbOwner.title, 2)
	self._ccbOwner.node_arena:setVisible(true)

	if data ~= nil and data.defeat_strategy ~= nil and data.defeat_strategy ~= "" then
		self._ccbOwner.description:setString("本关攻略：" .. data.defeat_strategy)
	else
		self._ccbOwner.description:setVisible(false)
	end

	self:hideAllPic()
	self:chooseBestGuide()

  	self._audioHandler = app.sound:playSound("battle_failed")
    audio.stopBackgroundMusic()
end

function QBattleDialogLose:hideAllPic()
	for _, v in ipairs(self.guidePrompts) do 
		self._ccbOwner[v.pic]:setVisible(false)
		self._ccbOwner[v.sp]:setVisible(false)
	end
end

function QBattleDialogLose:getGuidePromptsByType(typeName)
	for _,v in ipairs(self.guidePrompts) do
		if v.typeName == typeName then
			return v
		end
	end
end

--选出最适合的几个
function QBattleDialogLose:chooseBestGuide()
	local defeatConfig = QStaticDatabase:sharedDatabase():getDefeatGuidance()
	local defeats = nil
	for _,value in pairs(defeatConfig) do
		if value[1].minlevel <= remote.user.level and remote.user.level <= value[1].maxlevel then
			defeats = value
			break
		end
	end
	if defeats == nil then 
		return
	end

	local guides = {}
	local count = 0
	for _,value in ipairs(defeats) do
		local funValue = self:getGuidePromptsByType(value.guidance)
		if funValue ~= nil then
			local b = false
			local actorId = nil
			local equipmentId = nil
			b,actorId,equipmentId = funValue.condition(self)
			if b then
				count = count + 1
				funValue.actorId = actorId
				funValue.equipmentId = equipmentId
				self._ccbOwner[funValue.pic]:setVisible(true)
				table.insert(guides, funValue)
				if count == 3 then break end
			end
		end
	end
	self._handlers = {}
	if count > 0 then
		local startX = -(count-1)*100
		local totalIndex = #guides
		for index,value in ipairs(guides) do
			self._ccbOwner[value.pic]:setPositionX(display.width)
			self._ccbOwner[value.sp]:setPositionX(startX + (index -1) * 200)
    		local arr = CCArray:create()
			arr:addObject(CCDelayTime:create((index-1) * 0.2 + 1))
			arr:addObject(CCMoveTo:create(0.3, ccp(startX + (index -1) * 200, self._ccbOwner[value.pic]:getPositionY())))
			arr:addObject(CCDelayTime:create((totalIndex - index + 1) * 0.2))
			arr:addObject(CCCallFunc:create(function ()
				self:playEffect(self._ccbOwner[value.pic], self._ccbOwner[value.sp], (index-1) * 2)
			end))
			self._ccbOwner[value.pic]:runAction(CCSequence:create(arr))
		end
	end
end

function QBattleDialogLose:playEffect(target, sp, delay)
    local arr = CCArray:create()
    if delay > 0 then
		arr:addObject(CCDelayTime:create(delay))
	end
    arr:addObject(CCScaleTo:create(0.2,1.1,1.1))
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1.1,1.1))
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1.1,1.1))
    arr:addObject(CCScaleTo:create(0.2,1,1))
    arr:addObject(CCDelayTime:create(5+2.7-delay))
    target:runAction(CCRepeatForever:create(CCSequence:create(arr)))

    local sp2 = CCSprite:createWithSpriteFrame(sp:getDisplayFrame())
    sp2:setPositionX(sp:getPositionX())
    sp2:setPositionY(sp:getPositionY())
    local func = ccBlendFunc()
    func.src = GL_ONE
    func.dst = GL_ONE
    sp2:setBlendFunc(func)
    sp:getParent():addChild(sp2)
    local arr2 = CCArray:create()
    arr2:addObject(CCCallFunc:create(function()
    		sp2:setOpacity(0)
            end))
    arr2:addObject(CCDelayTime:create(delay + 0.8))
	arr2:addObject(CCFadeTo:create(0.5, 80))
	arr2:addObject(CCFadeTo:create(0.5, 0))
    arr2:addObject(CCDelayTime:create(4+2.7-delay))
    sp2:runAction(CCRepeatForever:create(CCSequence:create(arr2)))

    local arr3 = CCArray:create()
	arr3:addObject(CCDelayTime:create(delay + 0.8))
    arr3:addObject(CCCallFunc:create(function()
				sp:setScaleX(1)
				sp:setScaleY(1)
    			sp:setOpacity(100)
	            sp:setVisible(true)
            end))
    local arr4 = CCArray:create()
    arr4:addObject(CCScaleTo:create(1, 1.4, 1.4))
    arr4:addObject(CCFadeTo:create(1, 0))
    arr3:addObject(CCSpawn:create(arr4))
    arr3:addObject(CCCallFunc:create(function()
            	sp:setVisible(false)
            end))
    arr3:addObject(CCDelayTime:create(4+2.7-delay))
    sp:runAction(CCRepeatForever:create(CCSequence:create(arr3)))
end

function QBattleDialogLose:removeAll()
	if self._handlers ~= nil then
		for _,handler in ipairs(self._handlers) do
			scheduler.unscheduleGlobal(handler)
		end
		self._handlers = nil
	end
end

function QBattleDialogLose:getHeroList()
	return self._battleHeroes
end

function QBattleDialogLose:checkFarmPass()
    for _, v in ipairs(self:getHeroList()) do 
    	local equpmentId = remote.herosUtil:checkFarm(v)
    	if equpmentId then
    		return true,v,equpmentId
    	end
    end
    return false
end

function QBattleDialogLose:checkEnhancePass()
	-- Check if enhance is unlocked
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockEnhance() == false then
        return false
    end

    for _, v in ipairs(self:getHeroList()) do 
    	local equpmentId = remote.herosUtil:checkHerosEnhanceByID(v)
    	if equpmentId then
    		return true,v,equpmentId
    	end
    end

    return false
end

function QBattleDialogLose:checkEvolve1Pass()
    for _, v in ipairs(self:getHeroList()) do 
    	print("check: "..v)
    	local equpmentId = remote.herosUtil:getHerosEvolutionIdByActorId(v)
    	if equpmentId then
    		print("equpmentId: "..equpmentId)
    		return true,v,equpmentId
    	end
    end
		print("nonononono: ")
    return false
end

function QBattleDialogLose:checkEvolve2Pass() -- TODO, need return equipment Id
    for _, v in ipairs(self:getHeroList()) do 
    	local _, equpmentId = remote.herosUtil:checkHerosBreakthroughByID(v)
    	if equpmentId then
    		return true,v,equpmentId
    	end
    end

    return false
end


function QBattleDialogLose:checkEnchantPass() -- TODO, need return equipment Id
	-- Check if enchant is unlocked
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockEnchant() == false then
        return false
    end

    for _, v in ipairs(self:getHeroList()) do 
    	local equpmentId = remote.herosUtil:checkHeroEnchantByID(v)
    	if equpmentId then
    		return true,v,equpmentId
    	end
    end

    return false
end

function QBattleDialogLose:checkSkillPass()
	-- Check if skill upgrade is unlocked
	local config = QStaticDatabase:sharedDatabase():getConfiguration()
	if app.unlock:getUnlockSkill() == false then
        return false
    end

    -- Check if skill upgrade is available and glyph is enough
    for _, v in ipairs(self:getHeroList()) do 
		if remote.herosUtil:checkHerosSkillByID(v) then
			return true,v,nil
		end
	end

    return false
end

function QBattleDialogLose:checkUpgradePass()
	-- Check if exp item exists
	local expItems = QStaticDatabase:sharedDatabase():getItemsByProp("exp")
	if expItems ~= nil or #expItems ~= 0 then
		for k, v in pairs(expItems) do
			if remote.items:getItemsNumByID(v.id) > 0 then
				-- Check if any hero can upgrade
				for _, v in ipairs(self:getHeroList()) do
					if remote.herosUtil:heroCanUpgrade2(v) == true then
    					return true,v,nil
					end
				end
				break
			end
		end
	else
		return false
	end

	return false
end

function QBattleDialogLose:checkHeroGrow()
	local b = false
	local actorId = nil
	local equipmentId = nil
	b,actorId,equipmentId = self:checkEnhancePass()
	if b then
		return b,actorId,equipmentId
	end
	b,actorId,equipmentId = self:checkEvolve2Pass()
	if b then
		return b,actorId,equipmentId
	end
	b,actorId,equipmentId = self:checkEnchantPass()
	if b then
		return b,actorId,equipmentId
	end
	return b,actorId,equipmentId
end

function QBattleDialogLose:checkStarupPass()
	-- Check if any hero can upgrade
	for _, v in ipairs(self:getHeroList()) do
		local hero = remote.herosUtil:getHeroByID(v)
		local maxGrade = QStaticDatabase:sharedDatabase():getGradeByHeroId(v)
		if hero.grade < (#maxGrade - 1) then
    		return true,v,nil
		end
	end

	return false
end

function QBattleDialogLose:_backClickHandler()
    self:_onTriggerNext()
end

function QBattleDialogLose:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:removeAll()
	self._ccbOwner:onChoose()
end

function QBattleDialogLose:_onDefeatedGuide(event, target)
	self:removeAll()
	for _, v in ipairs(self.guidePrompts) do 
		if self._ccbOwner[v.pic] == target then
			self._ccbOwner:onChoose({name = v.event, options = {actorId = v.actorId, equipmentId = v.equipmentId}})
			return
		end
	end
	-- self._ccbOwner:onChoose({name = self.guideEvent, options = {actorId = self._actorId, equipmentId = self._equpmentId}})
end

function QBattleDialogLose:_onTriggerData(event)
    app.sound:playSound("common_small")
    QBattleDialogAgainstRecord.new({},{}) 
end

return QBattleDialogLose