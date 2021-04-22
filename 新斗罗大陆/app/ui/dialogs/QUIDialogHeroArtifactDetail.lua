--
-- zxs
-- 武魂真身主界面
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroArtifactDetail = class("QUIDialogHeroArtifactDetail", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetArtifactInfoDetail = import("..widgets.artifact.QUIWidgetArtifactInfoDetail")
local QUIWidgetArtifactInfoLevel = import("..widgets.artifact.QUIWidgetArtifactInfoLevel")
local QUIWidgetArtifactInfoGrade = import("..widgets.artifact.QUIWidgetArtifactInfoGrade")
local QUIWidgetArtifactInfoSkill = import("..widgets.artifact.QUIWidgetArtifactInfoSkill")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("...ui.QUIViewController")

QUIDialogHeroArtifactDetail.TAB_DETAIL = "TAB_DETAIL"
QUIDialogHeroArtifactDetail.TAB_LEVEL = "TAB_LEVEL"
QUIDialogHeroArtifactDetail.TAB_GRADE = "TAB_GRADE"
QUIDialogHeroArtifactDetail.TAB_SKILL = "TAB_SKILL"

function QUIDialogHeroArtifactDetail:ctor(options)
	local ccbFile = "ccb/Dialog_artifact.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerBack", callback = handler(self, self._onTriggerBack)},
		{ccbCallbackName = "onTriggerTabDetail", callback = handler(self, self._onTriggerTabDetail)},
		{ccbCallbackName = "onTriggerTabLevel", callback = handler(self, self._onTriggerTabLevel)},
		{ccbCallbackName = "onTriggerTabGrade", callback = handler(self, self._onTriggerTabGrade)},
		{ccbCallbackName = "onTriggerTabSkill", callback = handler(self, self._onTriggerTabSkill)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
	}
	QUIDialogHeroArtifactDetail.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
	if page.topBar then
    	page.topBar:showWithArtifact()
    end

    self._ccbOwner.frame_tf_title:setString("武魂真身")
    ui.tabButton(self._ccbOwner.tab_detail, "详情")
    ui.tabButton(self._ccbOwner.tab_level, "强化")
    ui.tabButton(self._ccbOwner.tab_grade, "升星")
    ui.tabButton(self._ccbOwner.tab_skill, "天赋")
	self._tabManager = ui.tabManager({self._ccbOwner.tab_detail, self._ccbOwner.tab_level, self._ccbOwner.tab_grade, self._ccbOwner.tab_skill})

	self._pos = options.pos or 0
	self._heros = options.heros or {}
	self._currentTab = QUIDialogHeroArtifactDetail.TAB_DETAIL
	self._oldBattleForce = 0

	if #self._heros == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end
end

function QUIDialogHeroArtifactDetail:viewDidAppear()
	QUIDialogHeroArtifactDetail.super.viewDidAppear(self)
	self:addBackEvent()

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))

	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self.onEvent))

	self._itemsProxy = cc.EventProxy.new(remote.items)
	self._itemsProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))

	self:setInfo(self._heros[self._pos], true)
end

function QUIDialogHeroArtifactDetail:viewWillDisappear()
	QUIDialogHeroArtifactDetail.super.viewWillDisappear(self)
	self:removeBackEvent()
	self._remoteProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()
	self._itemsProxy:removeAllEventListeners()

	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end
end

function QUIDialogHeroArtifactDetail:checkTab()
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	if remote.artifact.artifactGradeShow and UIHeroModel:getArtifactState() == remote.artifact.STATE_CAN_BREAK then
		self._currentTab = QUIDialogHeroArtifactDetail.TAB_GRADE
	elseif UIHeroModel:getArtifactTotalPoint() > UIHeroModel:getArtifactUsePoint() then
		self._currentTab = QUIDialogHeroArtifactDetail.TAB_SKILL
	end

	local options = self:getOptions()
	if options.initTab then
		self._currentTab = options.initTab
	end
end

function QUIDialogHeroArtifactDetail:setInfo(actorId, firstIn)
	self._oldBattleForce = 0
    self:getOptions().pos = self._pos

	self._actorId = actorId
	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	self._artifactId = remote.artifact:getArtiactByActorId(actorId)
	self._hero = remote.herosUtil:getHeroByID(actorId)
	self._heroUIModel = remote.herosUtil:getUIHeroByID(actorId)
	self._artifact = self._heroInfo.artifact

	self:initHeroArea()
	self:checkRedTips()

	if firstIn then
		self:checkTab()
	end
	-- 切换过程中会遇到没有激活的魂师
	if not self._artifact then
		self._currentTab = QUIDialogHeroArtifactDetail.TAB_DETAIL
	end
	self:selectTab(self._currentTab, true)
end

--初始化装备这块和头像
function QUIDialogHeroArtifactDetail:initHeroArea()
	local characher = db:getCharacterByID(self._heroInfo.actorId)
    local fontColor = BREAKTHROUGH_COLOR_LIGHT["white"]
	local breakLevel, color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_level:setColor(fontColor)
	setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	setShadowByFontColor(self._ccbOwner.tf_level, fontColor)
	self._ccbOwner.tf_level:setString("LV."..(self._heroInfo.level or "0"))
	local name = characher.name or ""
	if breakLevel > 0 then
		name = name.."+"..breakLevel
	end
	self._ccbOwner.tf_name:setString(name)

	self._ccbOwner.node_avatar:removeAllChildren()
	local information = QUIWidgetHeroInformation.new()
	self._ccbOwner.node_avatar:addChild(information:getView())
	information:setAvatar(self._heroInfo.actorId, 1.1)
	information:setNameVisible(false)
	information:setStarVisible(false)
	information:setBackgroundVisible(false)

	self._heroModel = remote.herosUtil:createHeroProp(self._heroInfo)
	local battleForce = self._heroModel:getBattleForce()
    self._oldBattleForce = battleForce
	self:setBattleForceText(battleForce)

	-- 
	if self._artifact then
		makeNodeFromGrayToNormal(self._ccbOwner.tab_level)
		makeNodeFromGrayToNormal(self._ccbOwner.tab_grade)
	    local talents = db:getArtifactMasterInfo(characher.aptitude) or {}
	    for i, talent in pairs(talents) do
	        if talent.condition <= self._artifact.artifactLevel then
	            self._ccbOwner.master_level:setString("LV"..talent.level)
	        end
	    end
	else
		makeNodeFromNormalToGray(self._ccbOwner.tab_level)
		makeNodeFromNormalToGray(self._ccbOwner.tab_grade)
	end

	-- 真身部分
	if self._artifactBox == nil then
	    self._artifactBox = QUIWidgetArtifactBox.new()
	    self._ccbOwner.node_box:addChild(self._artifactBox)
	end
    self._artifactBox:setHero(self._actorId)
	self._artifactBox:showRedTips(false)
end

function QUIDialogHeroArtifactDetail:setBattleForceText(battleForce)
    local num, word = q.convertLargerNumber(battleForce)
    self._ccbOwner.tf_force:setString(num..word)

    local fontInfo = db:getForceColorByForce(battleForce)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))
    end

	if battleForce == self._newBattle then
		self._ccbOwner.tf_force:runAction(CCScaleTo:create(0.2, 1))
	end
	self._oldBattleForce = battleForce
end 

function QUIDialogHeroArtifactDetail:checkRedTips()
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._ccbOwner.sp_level_tip:setVisible(false)
	self._ccbOwner.sp_grade_tip:setVisible(false)
	if remote.artifact.artifactGradeShow then
		self._ccbOwner.sp_grade_tip:setVisible(UIHeroModel:getArtifactState() == remote.artifact.STATE_CAN_BREAK)
	end
	self._ccbOwner.sp_skill_tip:setVisible(UIHeroModel:getArtifactTotalPoint() > UIHeroModel:getArtifactUsePoint())
end

function QUIDialogHeroArtifactDetail:removeAllTabState()
	self._ccbOwner.tab_detail:setEnabled(true)
	self._ccbOwner.tab_detail:setHighlighted(false)	
	self._ccbOwner.tab_level:setEnabled(true)
	self._ccbOwner.tab_level:setHighlighted(false)
	self._ccbOwner.tab_grade:setEnabled(true)
	self._ccbOwner.tab_grade:setHighlighted(false)
	self._ccbOwner.tab_skill:setEnabled(true)
	self._ccbOwner.tab_skill:setHighlighted(false)
    self._ccbOwner.node_master:setVisible(false)
end

function QUIDialogHeroArtifactDetail:selectTab(name, initTab)
	if self._currentTab ~= name or initTab then
		self._currentTab = name
		self:getOptions().initTab = name
		self:removeAllTabState()

		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		if self._currentTab == QUIDialogHeroArtifactDetail.TAB_DETAIL then
			self:selectedTabDetail()
		elseif self._currentTab == QUIDialogHeroArtifactDetail.TAB_LEVEL then
        	self._ccbOwner.node_master:setVisible(true)
			self:selectedTabLevel()
		elseif self._currentTab == QUIDialogHeroArtifactDetail.TAB_GRADE then
			self:selectedTabGrade()
		elseif self._currentTab == QUIDialogHeroArtifactDetail.TAB_SKILL then
			self:selectedTabSkill()
		end
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(true)
		end
	end
end

--选中详细
function QUIDialogHeroArtifactDetail:selectedTabDetail()
	-- self._ccbOwner.tab_detail:setEnabled(false)
	-- self._ccbOwner.tab_detail:setHighlighted(true)
	self._tabManager:selected(self._ccbOwner.tab_detail)

	if self._detailWidget == nil then
		self._detailWidget = QUIWidgetArtifactInfoDetail.new()
		self._ccbOwner.node_right:addChild(self._detailWidget)
	end
	self._detailWidget:setInfo(self._actorId)
	self._infoWidget = self._detailWidget
end

--选中升级
function QUIDialogHeroArtifactDetail:selectedTabLevel()
	-- self._ccbOwner.tab_level:setEnabled(false)
	-- self._ccbOwner.tab_level:setHighlighted(true)
	self._tabManager:selected(self._ccbOwner.tab_level)
	if self._levelWidget == nil then
		self._levelWidget = QUIWidgetArtifactInfoLevel.new({parent = self})
		self._ccbOwner.node_right:addChild(self._levelWidget)
	end
	self._levelWidget:setInfo(self._actorId)
	self._infoWidget = self._levelWidget
end

--选中突破
function QUIDialogHeroArtifactDetail:selectedTabGrade()
	-- self._ccbOwner.tab_grade:setEnabled(false)
	-- self._ccbOwner.tab_grade:setHighlighted(true)
	self._tabManager:selected(self._ccbOwner.tab_grade)
	if self._gradeWidget == nil then
		self._gradeWidget = QUIWidgetArtifactInfoGrade.new()
		self._ccbOwner.node_right:addChild(self._gradeWidget)
	end
	self._gradeWidget:setInfo(self._actorId)
	self._infoWidget = self._gradeWidget
end

function QUIDialogHeroArtifactDetail:selectedTabSkill()
	-- self._ccbOwner.tab_skill:setEnabled(false)
	-- self._ccbOwner.tab_skill:setHighlighted(true)
	self._tabManager:selected(self._ccbOwner.tab_skill)
	if self._skillWidget == nil then
		self._skillWidget = QUIWidgetArtifactInfoSkill.new({parent = self})
		self._ccbOwner.node_right:addChild(self._skillWidget)
	end
	self._skillWidget:setInfo(self._actorId)
	self._infoWidget = self._skillWidget
end

function QUIDialogHeroArtifactDetail:_onTriggerTabDetail()
	if self._tab == QUIDialogHeroArtifactDetail.TAB_DETAIL then
        return
    end
    app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroArtifactDetail.TAB_DETAIL)
end

function QUIDialogHeroArtifactDetail:_onTriggerTabLevel()
	if self._tab == QUIDialogHeroArtifactDetail.TAB_LEVEL then
        return
    end
    app.sound:playSound("common_menu")
	if not self._artifact then 
        app.tip:floatTip("获得武魂真身后，才能开启该标签页！")
        return 
    end
	self:selectTab(QUIDialogHeroArtifactDetail.TAB_LEVEL)
end

function QUIDialogHeroArtifactDetail:_onTriggerTabGrade()
	if self._tab == QUIDialogHeroArtifactDetail.TAB_GRADE then
        return
    end
    app.sound:playSound("common_menu")
	if not self._artifact then 
        app.tip:floatTip("获得武魂真身后，才能开启该标签页！")
        return 
    end
	self:selectTab(QUIDialogHeroArtifactDetail.TAB_GRADE)
end

function QUIDialogHeroArtifactDetail:_onTriggerTabSkill()
	if self._tab == QUIDialogHeroArtifactDetail.TAB_SKILL then
        return
    end
    app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroArtifactDetail.TAB_SKILL)
end

function QUIDialogHeroArtifactDetail:onEvent(event)
	if event.name == remote.HERO_UPDATE_EVENT then
		self:setInfo(self._heros[self._pos])
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:_refreshBatlleForce()
	elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
		self:checkRedTips()
	end
end

function QUIDialogHeroArtifactDetail:_refreshBatlleForce()
	if self._oldBattleForce == nil or self._oldBattleForce == 0 then return end

	local heroProp = remote.herosUtil:createHeroPropById(self._actorId)
	local battleForce = heroProp:getBattleForce()
	if self._textUpdate == nil then
		self._textUpdate = QTextFiledScrollUtils.new()
	end
	local forceChange = math.floor(battleForce - self._oldBattleForce)
	self._newBattle = battleForce
	self._ccbOwner.tf_force:runAction(CCScaleTo:create(0.2, 1.5))
	self._textUpdate:addUpdate(self._oldBattleForce, battleForce, handler(self, self.setBattleForceText), 1)
	if forceChange ~= 0 then 
		local effectName
      	if forceChange > 0 then
        	effectName = "effects/Tips_add.ccbi"
        	app.sound:playSound("force_add")
      	elseif forceChange < 0 then 
        	effectName = "effects/Tips_Decrease.ccbi"
      	end
      	local numEffect = QUIWidgetAnimationPlayer.new()
      	self._ccbOwner.battleForceNode:addChild(numEffect)
      	numEffect:playAnimation(effectName, function(ccbOwner)
            if forceChange < 0 then
              ccbOwner.content:setString(" -" .. math.abs(forceChange))
            else
              ccbOwner.content:setString(" +" .. math.abs(forceChange))
            end
        end)
    end
end 

function QUIDialogHeroArtifactDetail:_onTriggerRight()
    app.sound:playSound("common_change")
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.pos = self._pos
        if options.parentOptions ~= nil then
        	for index,actorId in ipairs(options.parentOptions.hero) do
        		if actorId == self._heros[self._pos] then
        			options.parentOptions.pos = index
        			break
        		end
        	end
        end
		self:setInfo(self._heros[self._pos])
	end
end

function QUIDialogHeroArtifactDetail:_onTriggerLeft()
    app.sound:playSound("common_change")
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.pos = self._pos
        if options.parentOptions ~= nil then
        	for index,actorId in ipairs(options.parentOptions.hero) do
        		if actorId == self._heros[self._pos] then
        			options.parentOptions.pos = index
        			break
        		end
        	end
        end
		self:setInfo(self._heros[self._pos])
	end
end

function QUIDialogHeroArtifactDetail:_onTriggerMaster()
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactTalent", 
        options = {actorId = self._actorId}})
end

function QUIDialogHeroArtifactDetail:onTriggerBackHandler(tag)
	self:_onTriggerBack()
end

function QUIDialogHeroArtifactDetail:onTriggerHomeHandler(tag)
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogHeroArtifactDetail:_onTriggerBack(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogHeroArtifactDetail:_onTriggerHome(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroArtifactDetail