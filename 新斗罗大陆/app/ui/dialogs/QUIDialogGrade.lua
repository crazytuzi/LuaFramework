--
-- Author: Your Name
-- Date: 2014-06-19 11:41:29
--
local QUIDialog = import(".QUIDialog")
local QUIDialogGrade = class("QUIDialogGrade",QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetGlyphClientCell = import("..widgets.QUIWidgetGlyphClientCell")
local QActorProp = import("...models.QActorProp")

QUIDialogGrade.GRAY_COLOR = ccc3(253, 234, 183)
QUIDialogGrade.LIGHT_COLOR = ccc3(0, 197, 0)

QUIDialogGrade.EVENT_GRADE_SUCC = "EVENT_GRADE_SUCC"

function QUIDialogGrade:ctor(options)
	local ccbFile = "ccb/Battle_Dialog_shengxing.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", 	callback = handler(self, QUIDialogGrade._onTriggerClose)},
	}
	QUIDialogGrade.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(false)
    CalculateUIBgSize(self._ccbOwner.bj)

    self._isEnd = false
	self.actorId = options.actorId
	self.callback = options.callback
	self.addGrade = options.addGrade or 1
	app.sound:playSound("task_complete")
    self:removeAll()
    
	self._ccbOwner.sp_normal:setVisible(true)
	

	local heroInfo = remote.herosUtil:getHeroByID(self.actorId)
    self:changeActorBg(self.actorId)
    if heroInfo ~= nil then
	    local oldHeroConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.actorId, heroInfo.grade - self.addGrade)
	    local newHeroConfig = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self.actorId, heroInfo.grade)
    	
    	local oldHeroInfo = remote.herosUtil:getOldHeroById(heroInfo.actorId)
    	local oldHeroModel = app:createHeroWithoutCache(oldHeroInfo)
    	local newHeroModel = app:createHeroWithoutCache(heroInfo)

    	local old_hp_grow = (oldHeroConfig.hp_grow or 0) * heroInfo.level
    	local new_hp_grow = (newHeroConfig.hp_grow or 0) * heroInfo.level
    	local old_attack_grow = (oldHeroConfig.attack_grow or 0) * heroInfo.level
    	local new_attack_grow = (newHeroConfig.attack_grow or 0) * heroInfo.level

    	-- 算出值
    	local oldHpValue = math.floor((oldHeroConfig.hp_value or 0) + old_hp_grow)
    	local newHpValue = math.floor((newHeroConfig.hp_value or 0) + new_hp_grow)
    	self:dealNum(oldHpValue, newHpValue, "hp")

    	local oldAttackValue = math.floor((oldHeroConfig.attack_value or 0) + old_attack_grow)
    	local newAttackValue = math.floor((newHeroConfig.attack_value or 0) + new_attack_grow)
    	self:dealNum(oldAttackValue, newAttackValue, "attack")

    	local oldBattleForce = oldHeroModel:getBattleForce()
    	local newBattleForce = newHeroModel:getBattleForce()
    	self:dealNum(oldBattleForce, newBattleForce, "battleforce")

		local oldHpGrow = math.floor(oldHeroConfig.hp_grow or 0)
    	local newHpGrow = math.floor(newHeroConfig.hp_grow or 0)
    	self:dealNum(oldHpGrow, newHpGrow, "hp_grow")

		local oldAttackGrow = math.floor(oldHeroConfig.attack_grow or 0)
    	local newAttackGrow = math.floor(newHeroConfig.attack_grow or 0)
    	self:dealNum(oldAttackGrow, newAttackGrow, "attack_grow")

		local oldStringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(heroInfo.grade - self.addGrade + 1)
		local newStringTilte = remote.herosUtil:getJobTitleByGradeLevelNum(heroInfo.grade + 1)
		self._ccbOwner.old_job_title:setString(oldStringTilte or "三界外")
		self._ccbOwner.new_job_tltile:setString(newStringTilte or "三界外")

		self:setName(self._ccbOwner.oldName, heroInfo.grade - self.addGrade + 1)
		self:setName(self._ccbOwner.newName, heroInfo.grade + 1)

		local oldHead = QUIWidgetHeroHead.new()
		local newHead = QUIWidgetHeroHead.new()
		self._ccbOwner.old_head:addChild(oldHead)

		self._newHeadVibrate = QUIWidgetHeroHeadVibrate.new({star = heroInfo.grade + 1, head = newHead})
		self._ccbOwner.new_head:addChild(self._newHeadVibrate)
		self._schedulerHandler = scheduler.performWithDelayGlobal(function ( ... )
			self._schedulerHandler = nil
			self._newHeadVibrate:playStarAnimation()
		end, 1.7)

        oldHead:setHeroSkinId(oldHeroInfo.skinId)
		oldHead:setHero(self.actorId)
		oldHead:setLevel(oldHeroInfo.level)
		local grade = heroInfo.grade - self.addGrade
		if grade < 0 then grade = 0 end
		oldHead:setStar(grade)
        newHead:setHeroSkinId(heroInfo.skinId)
		newHead:setHero(self.actorId)
		newHead:setLevel(heroInfo.level)

		self:calcSkillList(heroInfo)
		    
    	if heroInfo.grade % GRAD_MAX == 0 then
    		local path = "ui/dl_wow_pic/battle_jiesuan/jscg_y.png"
    		local spf = QSpriteFrameByPath(path)
    		if spf then
    			self._ccbOwner.sp_normal:setDisplayFrame(spf)
    		end
    	end
	end
	self._animationStageIsEnd = false
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))

    -- set hero avatar
    if self.actorId > 0 then
    	local db = QStaticDatabase:sharedDatabase()
		local info = db:getCharacterByID(tostring(self.actorId))
		local dialogDisplay = db:getDialogDisplay()[tostring(self.actorId)]
		local card = ""
		local x = 0
		local y = 0
		local scale = 1
		local rotation = 0
		local turn = 1

		if heroInfo and heroInfo.skinId and heroInfo.skinId > 0 then
			local skinConfig = remote.heroSkin:getHeroSkinBySkinId(tostring(self.actorId), heroInfo.skinId)
	        if skinConfig.fightEnd_card then
	        	card = skinConfig.fightEnd_card
				if skinConfig.fightEnd_display then
					local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.fightEnd_display)
					x = skinDisplaySetConfig.x or 0
					y = skinDisplaySetConfig.y or 0
					scale = skinDisplaySetConfig.scale or 1
					rotation = skinDisplaySetConfig.rotation or 0
					turn = skinDisplaySetConfig.isturn or 1
				end
	        end
		end

		if card == "" and dialogDisplay and dialogDisplay.break_card then
			card = dialogDisplay.break_card
			x = dialogDisplay.break_x
			y = dialogDisplay.break_y
			scale = dialogDisplay.break_scale
			rotation = dialogDisplay.break_rotation
			turn = dialogDisplay.break_isturn
		end
		if card == "" then
			card = "icon/hero_card/art_snts.png"
		end

		local frame = QSpriteFrameByPath(card)
		if frame then
			self._ccbOwner.sp_bg_mvp:setDisplayFrame(frame)
			self._ccbOwner.sp_bg_mvp:setPosition(x, y)
			self._ccbOwner.sp_bg_mvp:setScaleX(scale*turn)
			self._ccbOwner.sp_bg_mvp:setScaleY(scale)
			self._ccbOwner.sp_bg_mvp:setRotation(rotation)
		else
			assert(false, "<<<"..card..">>>not exist!")
		end
		self._ccbOwner.label_name_title:setString(info.title or "")
		self._ccbOwner.label_name:setString(info.name or "")
	end

    app.sound:playSound("hero_grow_up")
end

function QUIDialogGrade:calcSkillList(heroInfo)
	self._skillList = {}

	-- for grade = heroInfo.grade - self.addGrade + 1, heroInfo.grade do
	-- 	local heroConfig = db:getGradeByHeroActorLevel(self.actorId, grade)
	-- 	if heroConfig.glyph_id and app.unlock:checkLock("GLYPH_SYSTEMS", false) then
	-- 		table.insert(self._skillList, heroConfig.glyph_id)
	-- 	end
	-- end
	-- 直接取最后一个技能
	local heroConfig = db:getGradeByHeroActorLevel(self.actorId, heroInfo.grade)
	if heroConfig.glyph_id and app.unlock:checkLock("GLYPH_SYSTEMS", false) then
		table.insert(self._skillList, heroConfig.glyph_id)
	end

	self._curSkillIndex = 1
	self._skillMax = #self._skillList

	self._isActivedGlyphSkill = false
	if self._skillMax > 0 then
		self._isActivedGlyphSkill = true
	end
end

function QUIDialogGrade:changeNextShowSkill()
	if self._curSkillIndex > self._skillMax then
		return
	end

	local glyphId = self._skillList[self._curSkillIndex]

	if not self._skillWidget then
		self._skillWidget = QUIWidgetGlyphClientCell.new()
		self._ccbOwner.node_skill:addChild(self._skillWidget)
		self._skillWidget:setEnabled(false)
		self._skillWidget:setLevelVisible(false)
		self._skillWidget:setNameVisible(false)
	end

	self._skillWidget:setSkill(glyphId, 1)

	local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(glyphId, 1)
	self._ccbOwner.tf_skill_name:setString("新体技："..skillConfig.glyph_name)
	local str = self:_getExplainBySkillConfig(skillConfig)
	self._ccbOwner.tf_skill_desc:setString(str)
	remote.user:sendEventNewGlyph(self.actorId, glyphId)

	self._curSkillIndex = self._curSkillIndex + 1
end

function QUIDialogGrade:dealNum(oldValue, newValue, str)
	local oldNum, oldWord = q.convertLargerNumber(oldValue)
	local newNum, newWord = q.convertLargerNumber(newValue)

	-- if newValue >= 1000000 then
	-- 	local num, word = q.convertLargerNumber(newValue - oldValue)
	-- 	local numStr = "(+"..num..word..")"
	-- 	self._ccbOwner["tf_"..str.."_up"]:setString(numStr)
	-- 	self._ccbOwner["sp_"..str]:setVisible(false)
	-- 	self._ccbOwner["tf_"..str.."_old"]:setString(newNum..newWord)
	-- 	self._ccbOwner["tf_"..str.."_new"]:setString("")
	-- else
		self._ccbOwner["tf_"..str.."_up"]:setString("")
		self._ccbOwner["sp_"..str]:setVisible(true)
		self._ccbOwner["tf_"..str.."_old"]:setString(oldNum..oldWord)
		self._ccbOwner["tf_"..str.."_new"]:setString(newNum..newWord)
	--end
end

function QUIDialogGrade:changeActorBg(actorId)
	local actorInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
	local texture
    if actorInfo.lower == "b" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj1.jpg")
	elseif actorInfo.lower == "s" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj3.jpg")
    elseif actorInfo.lower == "ss" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj4.jpg")
    else
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj2.jpg")
    end
    self._ccbOwner.bj:setTexture(texture)
end

function QUIDialogGrade:setName(ccbNode, star)
	local heroName = QStaticDatabase:sharedDatabase():getCharacterByID(self.actorId).name
    local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(star)
	ccbNode:setString(heroName.."("..level..gardeName..")")
end

function QUIDialogGrade:viewWillDisappear()
	QUIDialogGrade.super.viewWillDisappear(self)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(true)

	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QUIDialogGrade:viewAnimationEndHandler(name)
	self._animationStageIsEnd = true
	self._animationStage = name
	print("self._animationStage = "..self._animationStage)

	if self._animationStage == "1" then
		self._nextAnimationStage = "2"
	else
		if self._isActivedGlyphSkill then
			if self._curSkillIndex == 1 then
				self:changeNextShowSkill()
				self._nextAnimationStage = "3"
			else
				if self._animationStage == "3" or self._animationStage == "5" then
					self._nextAnimationStage = "4"
					if self._curSkillIndex > self._skillMax then
						self._ccbOwner.node_ok:setVisible(true)
						self._isEnd = true
					end
				elseif self._nextAnimationStage == "4" then
					self:changeNextShowSkill()
					self._nextAnimationStage = "5"
					self._animationManager:runAnimationsForSequenceNamed(self._nextAnimationStage)
				end
			end
		else
			self._isEnd = true
		end
	end
end

function QUIDialogGrade:removeAll()
	self._ccbOwner.tf_hp_new:setString("")
	self._ccbOwner.tf_attack_new:setString("")
	self._ccbOwner.tf_hp_old:setString("")
	self._ccbOwner.tf_attack_old:setString("")
	self._ccbOwner.tf_skill_name:setString("")
	self._ccbOwner.tf_skill_desc:setString("")
	
	self._ccbOwner.node_skill:setVisible(false)
end

-------event--------------
function QUIDialogGrade:_onTriggerClose()
	if self._isEnd == false then return end
	self:playEffectOut()
end

function QUIDialogGrade:_backClickHandler()
	if not self._animationStageIsEnd or self._animationStage == "4" then
		return
	end
	self._animationStageIsEnd = false

	if self._isEnd then
		self:_onTriggerClose()
	else
		if self._nextAnimationStage then
			self._animationManager:runAnimationsForSequenceNamed(self._nextAnimationStage)
		end
	end
end

function QUIDialogGrade:viewAnimationOutHandler()
	local callback = self.callback
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.class.__cname == "QUIPageMainMenu" then
    	page:checkGuiad()
	end
end

function QUIDialogGrade:_getExplainBySkillConfig( skillLevelConfig )
	local tbl = {}
	local str = ""
	for name, filed in pairs(QActorProp._field) do
		if skillLevelConfig[name] then
			local strName = filed.name
			strName = string.gsub(strName, "法术", "")
			strName = string.gsub(strName, "法防", "防御")
			strName = string.gsub(strName, "物理", "")
			strName = string.gsub(strName, "物防", "防御")
			strName = string.gsub(strName, "百分比", "")
			strName = string.gsub(strName, "全队PVP", "PVP")
			local strNum = tostring(skillLevelConfig[name])
			if string.find(strNum, "%.") then
				strNum = (skillLevelConfig[name] * 100).."%"
			end

			-- 防止重复，同时，让类似魔法防御和物理防御这样的成对属性合并成防御属性
			local isNew = true
			for _, value in pairs(tbl) do
				if string.len(strName) < 12 then
					if value == strName.." + "..strNum then
						isNew = false
					end
				else
					if value == strName.."\n + "..strNum then
						isNew = false
					end
				end
			end

			if isNew then
				if string.len(strName) < 12 then
					table.insert(tbl, strName.." + "..strNum)
				else
					table.insert(tbl, strName.."\n + "..strNum)
				end
			end
		end
	end

	for index, value in pairs(tbl) do
		if index == #tbl then
			str = str..value
			break
		end
		str = str..value.."\n"
	end

	-- return tbl
	return str
end

return QUIDialogGrade