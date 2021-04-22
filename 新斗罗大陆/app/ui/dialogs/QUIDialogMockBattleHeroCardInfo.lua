--
-- Author: Your Name
-- Date: 2016-02-19 14:49:10
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattleHeroCardInfo = class("QUIDialogMockBattleHeroCardInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetHeroDetailSkillClient = import("..widgets.QUIWidgetHeroDetailSkillClient") 
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")

QUIDialogMockBattleHeroCardInfo.SKILL_DETAIL = "SKILL_DETAIL"
QUIDialogMockBattleHeroCardInfo.AWAKE_TALENT = "AWAKE_TALENT"
QUIDialogMockBattleHeroCardInfo.ARTIFACT = "ARTIFACT"
QUIDialogMockBattleHeroCardInfo.GOD_SKILL = "GOD_SKILL"

local START_POS = 244
local BTN_WIDTH = 132

function QUIDialogMockBattleHeroCardInfo:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_HeroCardInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
		{ccbCallbackName = "onTriggerTalent", callback = handler(self, self._onTriggerAwake)},
		{ccbCallbackName = "onTriggerArtifact", callback = handler(self, self._onTriggerArtifact)},
		{ccbCallbackName = "onTriggerGodSkill", callback = handler(self, self._onTriggerGodSkill)},
		{ccbCallbackName = "onTriggerGenre", callback = handler(self, self._onTriggerGenre)},
	}
	QUIDialogMockBattleHeroCardInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
	
	self._actorId = options.actorId
	self._id = options.id
	self._popCurrentDialog = options.popCurrentDialog or true

	self._mockHeroInfo = remote.mockbattle:getCardInfoByIndex(self._id)
    q.setButtonEnableShadow(self._ccbOwner.btn_genre)


	self._genreIndex = 1
	self._selectNum = 1
	self._selectView = nil
	self._hasEnchatSkill = false
	self._hasArtifact = false
	self._hasGodSkill = false
	self._enchants = {}
	self._artifact = {}
	self._godSkill = {}

	-- skill scroll view
	self._height = self._ccbOwner.sheet_layout:getContentSize().height
    self._width = self._ccbOwner.sheet_layout:getContentSize().width
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._width, self._height), {sensitiveDistance = 10})
    -- self._scrollView:replaceGradient(self._ccbOwner.node_shadow_left, self._ccbOwner.node_shadow_right, nil, nil)
    self._scrollView:replaceGradient( nil, nil, self._ccbOwner.node_shadow_left, self._ccbOwner.node_shadow_right)
    self._scrollView:setGradient(true)
    self._scrollView:setHorizontalBounce(true)

   	self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
   	self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))

	self._selectTab = QUIDialogMockBattleHeroCardInfo.SKILL_DETAIL
    self:setHeroInfo()
    self:updateTab()

    if FinalSDK.isHXShenhe() then
	    self._ccbOwner.achieve:setVisible(false)
	    self._ccbOwner.search_hero:setVisible(false)
	end
end

function QUIDialogMockBattleHeroCardInfo:viewDidAppear()
	QUIDialogMockBattleHeroCardInfo.super.viewDidAppear(self)
end

function QUIDialogMockBattleHeroCardInfo:viewWillDisappear()
	QUIDialogMockBattleHeroCardInfo.super.viewWillDisappear(self)
end

function QUIDialogMockBattleHeroCardInfo:updateTab()
	self:setButtonState(self._selectTab)

	if self._selectTab == QUIDialogMockBattleHeroCardInfo.SKILL_DETAIL then
		self:setSkillInfo()
	elseif self._selectTab == QUIDialogMockBattleHeroCardInfo.AWAKE_TALENT then 
		self:setAwakeInfo()
	elseif self._selectTab == QUIDialogMockBattleHeroCardInfo.ARTIFACT then 
		self:setArtifactInfo()	
	elseif self._selectTab == QUIDialogMockBattleHeroCardInfo.GOD_SKILL then 
		self:setGodSkillInfo()
	end
end

function QUIDialogMockBattleHeroCardInfo:setButtonState()
	local skillTab = self._selectTab == QUIDialogMockBattleHeroCardInfo.SKILL_DETAIL
	self._ccbOwner.btn_skill:setHighlighted(skillTab)
	self._ccbOwner.btn_skill:setEnabled(not skillTab)

	local awakeTab = self._selectTab == QUIDialogMockBattleHeroCardInfo.AWAKE_TALENT
	self._ccbOwner.btn_talent:setHighlighted(awakeTab)
	self._ccbOwner.btn_talent:setEnabled(not awakeTab)

	local artifactTab = self._selectTab == QUIDialogMockBattleHeroCardInfo.ARTIFACT
	self._ccbOwner.btn_artifact:setHighlighted(artifactTab)
	self._ccbOwner.btn_artifact:setEnabled(not artifactTab)

	local godSkillTab = self._selectTab == QUIDialogMockBattleHeroCardInfo.GOD_SKILL
	self._ccbOwner.btn_god:setHighlighted(godSkillTab)
	self._ccbOwner.btn_god:setEnabled(not godSkillTab)
end

--------------------------- main logic -----------------------------
function QUIDialogMockBattleHeroCardInfo:setHeroInfo()
    self._heroInfo = db:getCharacterByID(self._actorId)
    self._heroAttrInfo =  remote.mockbattle:getCardInfoById(self._actorId)

    -- hero name and hero dec
    self._ccbOwner.frame_tf_title:setString(self._heroInfo.name or "")

    local desc = self._heroInfo.brief or ""


    -- hero avatar
	local avatar = QUIWidgetHeroInformation.new()
	avatar:setMockBattleAvatar(self._id,self._actorId, 1.1)
	avatar:setBackgroundVisible(false)
	avatar:setNameVisible(false)
	avatar:setStarVisible(false)
	self._ccbOwner.node_avatar:addChild(avatar)

	-- hero quality
    local aptitudeInfo = db:getActorSABC(self._actorId)

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
	self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)

    -- hero talent
    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.professionalNode:addChild(self._professionalIcon)
    end
    self._professionalIcon:setHero(self._actorId)

	 --读本地突破配置
	local breakConfig = db:getBreakthroughByTalent(self._heroInfo.talent) 
	if breakConfig and breakConfig[1] then
		local itemId = breakConfig[1].weapon
		self._enchants = db:getEnchants(itemId, self._actorId)
		for index, enchant in ipairs(self._enchants) do
			if enchant.skill_show then
				self._hasEnchatSkill = true
				break
			end
		end
	end
	self._ccbOwner.node_talent:setVisible(self._hasEnchatSkill)
	 --读本地武魂真身
	local artifactId = remote.artifact:getArtiactByActorId(self._actorId)
	if artifactId then
		self._hasArtifact = true
		local skillConfigs = remote.artifact:getSkillByArtifactId(artifactId)
		for index, skillConfig in pairs(skillConfigs) do
			local skillInfo = db:getSkillByID(skillConfig.skill_id)
			local skill = {}
			skill.skill_id = skillConfig.skill_id
			skill.describe = QColorLabel.replaceColorSign(skillInfo.description or "", true)
			table.insert(self._artifact, skill)
		end
	end
	self._ccbOwner.node_artifact:setVisible(self._hasArtifact)

	--读本地神技
	local godSkillInfo = db:getGodSkillById(self._actorId)
    if godSkillInfo ~= nil then
    	self._hasGodSkill = true
    	local hasGradeSkill = {} -- 同一个grade的技能，只记录一次（针对ss+）
		for index, skillConfig in pairs(godSkillInfo) do
			if not hasGradeSkill[skillConfig.grade] then
				hasGradeSkill[skillConfig.grade] = true
				local skillTbl = string.split(skillConfig.skill_id, ";")
				local skillId = tonumber(skillTbl[1])
				local skillInfo = db:getSkillByID(skillId)
				local skill = {}
				skill.skill_id = skillId
				skill.real_level = skillConfig.level
				skill.show_level = skillConfig.grade
				skill.describe = QColorLabel.replaceColorSign(skillInfo.description or "", true)
				table.insert(self._godSkill, skill)
			end
		end
		self._selectTab = QUIDialogMockBattleHeroCardInfo.GOD_SKILL
    end
	self._ccbOwner.node_god:setVisible(self._hasGodSkill)

	-- 按钮排序
	local posX = START_POS
	if self._hasGodSkill then
		self._ccbOwner.node_god:setPositionX(posX)
		posX = posX + BTN_WIDTH
	end

	self._ccbOwner.node_skill:setPositionX(posX)
	posX = posX + BTN_WIDTH

	if self._hasEnchatSkill then
		self._ccbOwner.node_talent:setPositionX(posX)
		posX = posX + BTN_WIDTH
	end

	if self._hasArtifact then
		self._ccbOwner.node_artifact:setPositionX(posX)
		posX = posX + BTN_WIDTH
	end

	self:setAttrinfo()
end

function QUIDialogMockBattleHeroCardInfo:setAttrinfo()
    local prop = {hp_value = 1, attack_value = 2, armor_magic = 3, armor_physical = 4,}
    local map = remote.herosUtil:getUiPropMapByTeams(prop,{self._actorId},1,{ isMockBattle = true})
    --QPrintTable(map)
    for type_,prop_mod in pairs(map) do
        local index_ = prop[type_]        
        self._ccbOwner["tf_attr_name_"..index_]:setString(prop_mod.name)
        self._ccbOwner["tf_attr_value_"..index_]:setString(prop_mod.value_str)
    end
end

function QUIDialogMockBattleHeroCardInfo:setAwakeInfo()
	self._scrollView:clear()

	local gap = 0
	local totleWidth = 0
	local index = 0
	for _, enchant in ipairs(self._enchants) do
		if enchant.skill_show then
			local skillItemBox = QUIWidgetHeroSkillBox.new()
			skillItemBox:addEventListener(QUIWidgetHeroSkillBox.EVENT_CLICK, handler(self, self._cellClickAwake))
			skillItemBox:setSkillID(enchant.skill_show)
			skillItemBox:setSkillDesc(enchant.describe)
			skillItemBox:setStarFont("【"..(index+1).."星效果】")
			skillItemBox:setLock(false)
			local boxSize = skillItemBox:getContentSize()
	    	local positionX = (boxSize.width + gap) * index + 60
	    	skillItemBox:setPosition(ccp(positionX, - boxSize.height/2-10))
	    	totleWidth = totleWidth + boxSize.width + gap
			self._scrollView:addItemBox(skillItemBox)
		    if self._mockHeroInfo.equipments[1].enchants < enchant.enchant_level then
		    	makeNodeFromNormalToGray(skillItemBox)
		    end
			index = index + 1
		end
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

function QUIDialogMockBattleHeroCardInfo:setSkillInfo()
	self._scrollView:clear()

	self._skillCell = {}
	self._totleWidth = 0

	local index = 1
	local breakthroughConfig = db:getBreakthroughHeroByActorId(self._actorId)
    if breakthroughConfig ~= nil then
        for i = 1, #breakthroughConfig, 1 do
        	local assistSkillInfo = nil
        	
        	if breakthroughConfig[i].skill_id_3 == 3 then
		        assistSkillInfo = db:getAssistSkill(self._actorId)
		        if assistSkillInfo ~= nil then
		        	self:setSkillBox(index, breakthroughConfig[i], assistSkillInfo)
	        		index = index + 1
	        	end
    		end
            if breakthroughConfig[i].skill_id_3 ~= nil and breakthroughConfig[i].skill_id_3 ~= "" then
		        self:setSkillBox(index, breakthroughConfig[i])
	        	index = index + 1
   			end
        end
    end
	self._scrollView:setRect(0, -self._height, 0, self._totleWidth)
end

function QUIDialogMockBattleHeroCardInfo:setSkillBox(index, skillSlot, assistSkill)
	local gap = 38
	local skillCell = QUIWidgetHeroDetailSkillClient.new({skillSlot = skillSlot.skill_id_3, actorId = self._actorId, assistSkill = assistSkill ,skillLevel = self._heroAttrInfo.level})
	skillCell:addEventListener(QUIWidgetHeroDetailSkillClient.EVENT_CLICK, handler(self, self._cellClickSkill))
    skillCell:setSkillInfo(skillSlot, self._actorId)


    local boxSize = skillCell:getContentSize()
    local positionX = (boxSize.width + gap) * (index-1) + 60
    skillCell:setPosition(ccp(positionX, - boxSize.height/2))
    self._scrollView:addItemBox(skillCell)
   local is_grey = self._mockHeroInfo.breakthrough < skillSlot.breakthrough_level
   if is_grey then
    	makeNodeFromNormalToGray(skillCell)
    end
	self._totleWidth = self._totleWidth + boxSize.width + gap
    table.insert(self._skillCell, skillCell)
end

function QUIDialogMockBattleHeroCardInfo:setArtifactInfo()
	self._scrollView:clear()

	local gap = 0
	local totleWidth = 0
	local index = 0
	for _, artifact in pairs(self._artifact) do
		local skillItemBox = QUIWidgetHeroSkillBox.new()
		skillItemBox:addEventListener(QUIWidgetHeroSkillBox.EVENT_CLICK, handler(self, self._cellClickAwake))
		skillItemBox:setSkillID(artifact.skill_id)
		skillItemBox:setSkillDesc(artifact.describe)
		skillItemBox:setLock(false)
		local boxSize = skillItemBox:getContentSize()
    	local positionX = (boxSize.width + gap) * index + 60
    	skillItemBox:setPosition(ccp(positionX, - boxSize.height/2))
    	totleWidth = totleWidth + boxSize.width + gap
		self._scrollView:addItemBox(skillItemBox)
   		local is_grey = self._mockHeroInfo.artifact.artifactBreakthrough < index + 1
		if is_grey then
	    	makeNodeFromNormalToGray(skillItemBox)
	    end
		index = index + 1
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

function QUIDialogMockBattleHeroCardInfo:setGodSkillInfo()
	self._scrollView:clear()

	local gap = 0
	local totleWidth = 0
	local index = 0
	for _, godSkill in pairs(self._godSkill) do
		local skillItemBox = QUIWidgetHeroSkillBox.new()
		skillItemBox:addEventListener(QUIWidgetHeroSkillBox.EVENT_CLICK, handler(self, self._cellClickAwake))
		skillItemBox:setSkillID(godSkill.skill_id)
		skillItemBox:setGodSkillShowLevel(godSkill.real_level, self._actorId)
		skillItemBox:setSkillDesc(godSkill.describe)
		skillItemBox:setStarFont("【"..godSkill.show_level.."阶效果】")
		skillItemBox:setLock(false)
		local boxSize = skillItemBox:getContentSize()
    	local positionX = (boxSize.width + gap) * index + 60
    	skillItemBox:setPosition(ccp(positionX, - boxSize.height/2-10))
    	totleWidth = totleWidth + boxSize.width + gap
		self._scrollView:addItemBox(skillItemBox)
		if self._mockHeroInfo.godSkillGrade < godSkill.real_level then
			makeNodeFromNormalToGray(skillItemBox) 
		end
		index = index + 1
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

-------------------------- assist function ------------------------------

function QUIDialogMockBattleHeroCardInfo:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogMockBattleHeroCardInfo:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogMockBattleHeroCardInfo:_onTriggerOK(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_common")

	self:playEffectOut()
end

function QUIDialogMockBattleHeroCardInfo:_onTriggerSkill()
	if self._selectTab == QUIDialogMockBattleHeroCardInfo.SKILL_DETAIL then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogMockBattleHeroCardInfo.SKILL_DETAIL
	self:updateTab()
end

function QUIDialogMockBattleHeroCardInfo:_onTriggerAwake()
	if self._selectTab == QUIDialogMockBattleHeroCardInfo.AWAKE_TALENT then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogMockBattleHeroCardInfo.AWAKE_TALENT
	self:updateTab()
end

function QUIDialogMockBattleHeroCardInfo:_onTriggerArtifact()
	if self._selectTab == QUIDialogMockBattleHeroCardInfo.ARTIFACT then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogMockBattleHeroCardInfo.ARTIFACT
	self:updateTab()
end

function QUIDialogMockBattleHeroCardInfo:_onTriggerGodSkill()
	if self._selectTab == QUIDialogMockBattleHeroCardInfo.GOD_SKILL then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogMockBattleHeroCardInfo.GOD_SKILL
	self:updateTab()
end

--显示属性 QUIDialogHeroAttrDetailInfo
function QUIDialogMockBattleHeroCardInfo:_onTriggerGenre()
    app.sound:playSound("common_common")
	local actor_prop = self._heroAttrInfo.uiModel
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroAttrDetailInfo", 
		options = {actor_prop = actor_prop}}, {isPopCurrentDialog = false})
end

function QUIDialogMockBattleHeroCardInfo:_cellClickSkill(event)
	if self._isMoving then return end

    app.sound:playSound("common_common")
	if event.assistSkill then
		--self:viewAnimationOutHandler()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
	   			options = {actorId = event.actorId, assistSkill = event.assistSkill, skillSlotInfo = event.skillSlotInfo , isMockBattle = true}},{isPopCurrentDialog = false})
	else
		app.tip:skillTip(event.skillId, self._heroAttrInfo.level)
	end
end

function QUIDialogMockBattleHeroCardInfo:_cellClickAwake(event)
	if self._isMoving then return end
    app.sound:playSound("common_common")
	app.tip:skillTip(event.skillId, 1, false, {isTalent = true, godGrade = event.godGrade, hideLevel = true, desc = event.desc, actorId = self._actorId})
end

function QUIDialogMockBattleHeroCardInfo:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogMockBattleHeroCardInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMockBattleHeroCardInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogMockBattleHeroCardInfo