--
-- Author: Your Name
-- Date: 2016-02-19 14:49:10
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroDetailInfoNew = class("QUIDialogHeroDetailInfoNew", QUIDialog)

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
local QUIWidgetFashionHeadBox = import("..widgets.QUIWidgetFashionHeadBox")

QUIDialogHeroDetailInfoNew.SKILL_DETAIL = "SKILL_DETAIL"
QUIDialogHeroDetailInfoNew.AWAKE_TALENT = "AWAKE_TALENT"
QUIDialogHeroDetailInfoNew.ARTIFACT = "ARTIFACT"
QUIDialogHeroDetailInfoNew.GOD_SKILL = "GOD_SKILL"
QUIDialogHeroDetailInfoNew.FASHION = "FASHION"

local START_POS = 244
local BTN_WIDTH = 132

function QUIDialogHeroDetailInfoNew:ctor(options)
	local ccbFile = "ccb/Dialog_Zhaohuanyulan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
		{ccbCallbackName = "onTriggerTalent", callback = handler(self, self._onTriggerAwake)},
		{ccbCallbackName = "onTriggerArtifact", callback = handler(self, self._onTriggerArtifact)},
		{ccbCallbackName = "onTriggerGodSkill", callback = handler(self, self._onTriggerGodSkill)},
		{ccbCallbackName = "onTriggerFashion", callback = handler(self, self._onTriggerFashion)},
	}
	QUIDialogHeroDetailInfoNew.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
	
	self._actorId = options.actorId
	self._isTips = options.isTips
	self._popCurrentDialog = options.popCurrentDialog or true
    if self._isTips then
        self._ccbOwner.tf_ok_name:setString("确 定")
    end

	self._genreIndex = 1
	self._selectNum = 1
	self._selectView = nil
	self._hasEnchatSkill = false
	self._hasArtifact = false
	self._hasGodSkill = false
	self._hasFashion = false
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

	self._selectTab = QUIDialogHeroDetailInfoNew.SKILL_DETAIL
    self:setHeroInfo()
    self:setPieceNum()
    self:updateTab()

    if FinalSDK.isHXShenhe() then
	    self._ccbOwner.achieve:setVisible(false)
	    self._ccbOwner.search_hero:setVisible(false)
	end
end

function QUIDialogHeroDetailInfoNew:viewDidAppear()
	QUIDialogHeroDetailInfoNew.super.viewDidAppear(self)
end

function QUIDialogHeroDetailInfoNew:viewWillDisappear()
	QUIDialogHeroDetailInfoNew.super.viewWillDisappear(self)
end

function QUIDialogHeroDetailInfoNew:updateTab()
	self:setButtonState(self._selectTab)

	if self._selectTab == QUIDialogHeroDetailInfoNew.SKILL_DETAIL then
		self:setSkillInfo()
	elseif self._selectTab == QUIDialogHeroDetailInfoNew.AWAKE_TALENT then 
		self:setAwakeInfo()
	elseif self._selectTab == QUIDialogHeroDetailInfoNew.ARTIFACT then 
		self:setArtifactInfo()	
	elseif self._selectTab == QUIDialogHeroDetailInfoNew.GOD_SKILL then 
		self:setGodSkillInfo()
	elseif self._selectTab == QUIDialogHeroDetailInfoNew.FASHION then 
		self:setFashionInfo()
	end
end

function QUIDialogHeroDetailInfoNew:setButtonState()
	local skillTab = self._selectTab == QUIDialogHeroDetailInfoNew.SKILL_DETAIL
	self._ccbOwner.btn_skill:setHighlighted(skillTab)
	self._ccbOwner.btn_skill:setEnabled(not skillTab)

	local awakeTab = self._selectTab == QUIDialogHeroDetailInfoNew.AWAKE_TALENT
	self._ccbOwner.btn_talent:setHighlighted(awakeTab)
	self._ccbOwner.btn_talent:setEnabled(not awakeTab)

	local artifactTab = self._selectTab == QUIDialogHeroDetailInfoNew.ARTIFACT
	self._ccbOwner.btn_artifact:setHighlighted(artifactTab)
	self._ccbOwner.btn_artifact:setEnabled(not artifactTab)

	local godSkillTab = self._selectTab == QUIDialogHeroDetailInfoNew.GOD_SKILL
	self._ccbOwner.btn_god:setHighlighted(godSkillTab)
	self._ccbOwner.btn_god:setEnabled(not godSkillTab)

	local fashionTab = self._selectTab == QUIDialogHeroDetailInfoNew.FASHION
	self._ccbOwner.btn_fashion:setHighlighted(fashionTab)
	self._ccbOwner.btn_fashion:setEnabled(not fashionTab)
end

--------------------------- main logic -----------------------------
function QUIDialogHeroDetailInfoNew:setHeroInfo()
    self._heroInfo = db:getCharacterByID(self._actorId)

    -- hero name and hero dec
    self._ccbOwner.frame_tf_title:setString(self._heroInfo.name or "")
    self._ccbOwner.hero_dec:setString("")

    local desc = self._heroInfo.brief or ""
	local itemContentSize = self._ccbOwner.desc_sheet_layout:getContentSize()
    local scrollView = QScrollView.new(self._ccbOwner.desc_sheet, itemContentSize, {bufferMode = 1})
    scrollView:setVerticalBounce(true)
	local text = QColorLabel:create(desc, 270, nil, nil, 20, GAME_COLOR_LIGHT.normal)
	text:setAnchorPoint(ccp(0, 1))
	local totalHeight = text:getContentSize().height
	scrollView:addItemBox(text)
	scrollView:setRect(0, -totalHeight, 0, 0)

    -- hero avatar
	local avatar = QUIWidgetHeroInformation.new()
	avatar:setAvatar(self._actorId, 1.1)
	avatar:setBackgroundVisible(false)
	avatar:setNameVisible(false)
	avatar:setStarVisible(false)
	self._ccbOwner.node_avatar:addChild(avatar)

	-- hero quality
    local aptitudeInfo = db:getActorSABC(self._actorId)
    self._ccbOwner.hero_qulity:setString(aptitudeInfo.qc.."级")

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
	self._ccbOwner.frame_tf_title = setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)

    -- hero genre
    self._genre, self._genreIndex = db:getHeroGenreById(self._actorId)
    self._genre = self._genre ~= nil and self._genre or "无"
	self._ccbOwner.genre:setString(self._genre)

    -- hero talent
    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.professionalNode:addChild(self._professionalIcon)
    end
    self._professionalIcon:setHero(self._actorId)

	local breakConfig = db:getBreakthroughByTalent(self._heroInfo.talent) --突破配置表
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

	local godSkillInfo = db:getGodSkillById(self._actorId)
    if godSkillInfo ~= nil then
    	self._hasGodSkill = true
    	local hasGradeSkill = {} -- 同一个grade的技能，只记录一次（针对ss+）
		for index, skillConfig in pairs(godSkillInfo) do
			if not hasGradeSkill[skillConfig.grade] then
				hasGradeSkill[skillConfig.grade] = true
				local skillTbl = string.split(skillConfig.skill_id, ";")
				local skillId = tonumber(skillTbl[1])
				print("skillId = ", skillId)
				local skillInfo = db:getSkillByID(skillId)
				local skill = {}
				skill.skill_id = skillId
				skill.real_level = skillConfig.level
				skill.show_level = skillConfig.grade
				skill.describe = QColorLabel.replaceColorSign(skillInfo.description or "", true)
				table.insert(self._godSkill, skill)
			end
		end
		self._selectTab = QUIDialogHeroDetailInfoNew.GOD_SKILL
    end
	self._ccbOwner.node_god:setVisible(self._hasGodSkill)

	local skinConfig = remote.heroSkin:getHeroSkinConfigListById(self._actorId)
    if q.isEmpty(skinConfig) == false then
    	self._hasFashion = true
    end
    self._ccbOwner.node_fashion:setVisible(self._hasFashion)

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

	if self._hasFashion then
		self._ccbOwner.node_fashion:setPositionX(posX)
		posX = posX + BTN_WIDTH
	end
end

function QUIDialogHeroDetailInfoNew:setPieceNum()
	local config = db:getGradeByHeroActorLevel(self._actorId, 0)
	if config == nil then return end

	local numWord = ""
    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    local gradeLevel = 0
    self._ccbOwner.tf_num_name:setString("合成碎片：")
    if heroInfo ~= nil then
    	gradeLevel = heroInfo.grade+1 or 0
        self._ccbOwner.tf_num_name:setString("升星碎片：")
    end
    
    local info = db:getGradeByHeroActorLevel(self._actorId, gradeLevel) or {}
	local currentNum = remote.items:getItemsNumByID(config.soul_gem) or 0
    if (self._heroInfo.aptitude == APTITUDE.SS or self._heroInfo.aptitude == APTITUDE.SSR) and gradeLevel > 0 then
		local godSkillTbl = db:getGodSkillById(self._actorId)
		local godSkillGrade = heroInfo.godSkillGrade or 1
		local godSkillConfig = godSkillTbl[godSkillGrade+1] or {}
	    self._needNum = godSkillConfig.stunt_num or 0
    	self._ccbOwner.tf_num_name:setString("神技进阶碎片：")
    	self._ccbOwner.tf_have_num:setPositionX(145)
    else
	    self._needNum = info.soul_gem_count or 0
    end
    if self._needNum > 0 then
        numWord = currentNum.."/"..self._needNum
    else
        numWord = currentNum
        self._ccbOwner.tf_num_name:setString("拥有碎片：")
    	self._ccbOwner.tf_have_num:setPositionX(100)
    end
	self._ccbOwner.tf_have_num:setString(numWord)
end

function QUIDialogHeroDetailInfoNew:setAwakeInfo()
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
			index = index + 1
		end
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

function QUIDialogHeroDetailInfoNew:setSkillInfo()
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

function QUIDialogHeroDetailInfoNew:setSkillBox(index, skillSlot, assistSkill)
	local gap = 38
	local skillCell = QUIWidgetHeroDetailSkillClient.new({skillSlot = skillSlot.skill_id_3, actorId = self._actorId, assistSkill = assistSkill})
	skillCell:addEventListener(QUIWidgetHeroDetailSkillClient.EVENT_CLICK, handler(self, self._cellClickSkill))
    skillCell:setSkillInfo(skillSlot, self._actorId)

    local boxSize = skillCell:getContentSize()
    local positionX = (boxSize.width + gap) * (index-1) + 60
    skillCell:setPosition(ccp(positionX, - boxSize.height/2))
    self._scrollView:addItemBox(skillCell)

	self._totleWidth = self._totleWidth + boxSize.width + gap
    table.insert(self._skillCell, skillCell)
end

function QUIDialogHeroDetailInfoNew:setArtifactInfo()
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
		index = index + 1
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

function QUIDialogHeroDetailInfoNew:setGodSkillInfo()
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
		index = index + 1
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

function QUIDialogHeroDetailInfoNew:setFashionInfo()
	self._scrollView:clear()

	local gap = 0
	local totleWidth = 0
	local index = 0
	local skinConfig = remote.heroSkin:getHeroSkinConfigListById(self._actorId)
	for _, config in pairs(skinConfig) do
		local fashionHeadBox = QUIWidgetFashionHeadBox.new()
		fashionHeadBox:addEventListener(QUIWidgetFashionHeadBox.EVENT_CLICK, handler(self, self._cellClickFashionHeadBox))
		fashionHeadBox:setInfo(config)
		fashionHeadBox:setFashionNameVisible(true)
		local boxSize = fashionHeadBox:getContentSize()
		local scale = 1
		if boxSize.height > self._height then
			scale = self._height / boxSize.height
		end
		fashionHeadBox:setScale(scale)
    	local positionX = (boxSize.width * scale + gap) * index + 60
    	fashionHeadBox:setPosition(ccp(positionX, - boxSize.height * scale / 2))
    	totleWidth = totleWidth + boxSize.width * scale + gap
		self._scrollView:addItemBox(fashionHeadBox)
		index = index + 1
	end

	self._scrollView:setRect(0, -self._height, 0, totleWidth)
end

-------------------------- assist function ------------------------------

function QUIDialogHeroDetailInfoNew:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogHeroDetailInfoNew:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogHeroDetailInfoNew:_onTriggerGet(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
	app.sound:playSound("common_common")

	if self._isTips then
		self:playEffectOut()
	else
		self:viewAnimationOutHandler()
		QQuickWay:addQuickWay(QQuickWay.HERO_DROP_WAY, self._actorId, self._needNum, nil, false)
	end
end

function QUIDialogHeroDetailInfoNew:_onTriggerSkill()
	if self._selectTab == QUIDialogHeroDetailInfoNew.SKILL_DETAIL then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogHeroDetailInfoNew.SKILL_DETAIL
	self:updateTab()
end

function QUIDialogHeroDetailInfoNew:_onTriggerAwake()
	if self._selectTab == QUIDialogHeroDetailInfoNew.AWAKE_TALENT then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogHeroDetailInfoNew.AWAKE_TALENT
	self:updateTab()
end

function QUIDialogHeroDetailInfoNew:_onTriggerArtifact()
	if self._selectTab == QUIDialogHeroDetailInfoNew.ARTIFACT then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogHeroDetailInfoNew.ARTIFACT
	self:updateTab()
end

function QUIDialogHeroDetailInfoNew:_onTriggerGodSkill()
	if self._selectTab == QUIDialogHeroDetailInfoNew.GOD_SKILL then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogHeroDetailInfoNew.GOD_SKILL
	self:updateTab()
end

function QUIDialogHeroDetailInfoNew:_onTriggerFashion()
	if self._selectTab == QUIDialogHeroDetailInfoNew.FASHION then
		return
	end
	app.sound:playSound("common_common")
	self._selectTab = QUIDialogHeroDetailInfoNew.FASHION
	self:updateTab()
end

function QUIDialogHeroDetailInfoNew:_cellClickSkill(event)
	if self._isMoving then return end

    app.sound:playSound("common_common")
	if event.assistSkill then
		self:viewAnimationOutHandler()
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAssistHeroSkill", 
	   			options = {actorId = event.actorId, assistSkill = event.assistSkill, skillSlotInfo = event.skillSlotInfo}},{isPopCurrentDialog = false})
	else
		app.tip:skillTip(event.skillId, 1)
	end
end

function QUIDialogHeroDetailInfoNew:_cellClickAwake(event)
	if self._isMoving then return end
    app.sound:playSound("common_common")
	app.tip:skillTip(event.skillId, 1, false, {isTalent = true, godGrade = event.godGrade, hideLevel = true, desc = event.desc, actorId = self._actorId})
end

function QUIDialogHeroDetailInfoNew:_cellClickFashionHeadBox(event)
	if self._isMoving then return end
    app.sound:playSound("common_common")
    
    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFashionSkinInfo", 
		options = {info = event.info}}, {isPopCurrentDialog = false})
end

function QUIDialogHeroDetailInfoNew:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogHeroDetailInfoNew:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogHeroDetailInfoNew:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogHeroDetailInfoNew