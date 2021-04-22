--
-- Kumo.Wang
-- 魂靈信息界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritDetail = class("QUIDialogSoulSpiritDetail", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIViewController = import("..QUIViewController")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIDialogHeroOverview = import("..dialogs.QUIDialogHeroOverview")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QUIWidgetSoulSpiritDetail = import("..widgets.QUIWidgetSoulSpiritDetail")
local QUIWidgetSoulSpiritLevel = import("..widgets.QUIWidgetSoulSpiritLevel")
local QUIWidgetSoulSpiritGrade = import("..widgets.QUIWidgetSoulSpiritGrade")
local QUIWidgetSoulSpiritAwaken = import("..widgets.QUIWidgetSoulSpiritAwaken")
local QUIWidgetSoulSpiritInherit = import("..widgets.QUIWidgetSoulSpiritInherit")
local QActorProp = import("...models.QActorProp")

QUIDialogSoulSpiritDetail.TAB_DETAIL = "TAB_DETAIL"
QUIDialogSoulSpiritDetail.TAB_LEVEL = "TAB_LEVEL"
QUIDialogSoulSpiritDetail.TAB_GRADE = "TAB_GRADE"
QUIDialogSoulSpiritDetail.TAB_AWAKEN = "TAB_AWAKEN"
QUIDialogSoulSpiritDetail.TAB_INHERIT = "TAB_INHERIT"

QUIDialogSoulSpiritDetail.MODEL_SOULSPIRIT = "MODEL_SOULSPIRIT"
QUIDialogSoulSpiritDetail.MODEL_HERO = "MODEL_HERO"

function QUIDialogSoulSpiritDetail:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Detail.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTabDetail", callback = handler(self, self._onTriggerTabDetail)},
		{ccbCallbackName = "onTriggerTabGrade", callback = handler(self, self._onTriggerTabGrade)},
        {ccbCallbackName = "onTriggerTabLevel", callback = handler(self, self._onTriggerTabLevel)},
        {ccbCallbackName = "onTriggerTabAwaken", callback = handler(self, self._onTriggerTabAwaken)},
		{ccbCallbackName = "onTriggerTabInherit", callback = handler(self, self._onTriggerTabInherit)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
        {ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
		{ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
	}
	QUIDialogSoulSpiritDetail.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    page.topBar:showWithSoulSpirit()
	
    setShadow5(self._ccbOwner.tf_force)

    ui.tabButton(self._ccbOwner.btn_tab_detail, "详情")
    ui.tabButton(self._ccbOwner.btn_tab_level, "吞噬")
    ui.tabButton(self._ccbOwner.btn_tab_grade, "升星")
    ui.tabButton(self._ccbOwner.btn_tab_awaken, "觉醒")
    ui.tabButton(self._ccbOwner.btn_tab_inherit, "传承")
    local tabs = {}
    table.insert(tabs, self._ccbOwner.btn_tab_detail)
    table.insert(tabs, self._ccbOwner.btn_tab_level)
    table.insert(tabs, self._ccbOwner.btn_tab_grade)
    table.insert(tabs, self._ccbOwner.btn_tab_awaken)
    table.insert(tabs, self._ccbOwner.btn_tab_inherit)
    self._tabManager = ui.tabManager(tabs)

    -- 这里分魂师线和魂灵线，分别对应魂灵列表进入和魂师列表进入。
    -- 魂师线：卸下魂灵，魂灵消失；左右切换按照魂师列表。
    -- 魂灵线：存在被护佑魂师时，才可做卸下替换操作；卸下魂灵，魂师消失；左右切换按照魂灵列表。
    -- 
    if options then
        self._id = options.id
        self._soulSpiritIdList = options.soulSpiritIdList
        self._heroId = options.heroId
        self._heroIdList = options.heroIdList
    end
    self._showList = {} 
    self._model = nil
	self._tab = options and options.tab or QUIDialogSoulSpiritDetail.TAB_DETAIL
	self._oldBattleForce = 0
	self._textUpdate = QTextFiledScrollUtils.new()
end

function QUIDialogSoulSpiritDetail:viewDidAppear()
	QUIDialogSoulSpiritDetail.super.viewDidAppear(self)

    self._soulSpiritProxy = cc.EventProxy.new(remote.soulSpirit)
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_WEAR, handler(self, self.wearHandler))
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_UNWEAR, handler(self, self.unwearHandler))
    self._soulSpiritProxy:addEventListener(remote.soulSpirit.EVENT_UPDATE, handler(self, self.onEvent))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))

	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self.onEvent))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.onHeroSelected, self)

	self:addBackEvent()
	self:initList()
end

function QUIDialogSoulSpiritDetail:viewWillDisappear()
	QUIDialogSoulSpiritDetail.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.onHeroSelected, self)

	self._soulSpiritProxy:removeAllEventListeners()
	self._remoteProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()
	self:removeBackEvent()

	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end
    remote.soulSpirit:cleanSelectedFoodDic()
end

function QUIDialogSoulSpiritDetail:initList()
    print("QUIDialogSoulSpiritDetail:initList(1) ", self._id, self._soulSpiritIdList, self._heroId, self._heroIdList)
    if self._soulSpiritIdList then
        QPrintTable(self._soulSpiritIdList)
        if self._id and self._id > 0 then
            for i, id in ipairs(self._soulSpiritIdList) do
                if self._id == id then
                    self._soulSpiritIndex = i
                    break
                end
            end
        end
        if not self._soulSpiritIndex then
            self._soulSpiritIndex = 1
            self._id = self._soulSpiritIdList[self._soulSpiritIndex]
        end

        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = soulSpiritInfo.heroId

        self._showList = self._soulSpiritIdList
        self._model = QUIDialogSoulSpiritDetail.MODEL_SOULSPIRIT
    end
    if self._heroIdList then
        QPrintTable(self._heroIdList)
        if self._heroId and self._heroId > 0 then
            for i, heroId in ipairs(self._heroIdList) do
                if self._heroId == heroId then
                    self._heroIdIndex = i
                    break
                end
            end
        end
        if not self._heroIdIndex then
            self._heroIdIndex = 1
            self._heroId = self._heroIdList[self._heroIdIndex]
        end
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        self._id = soulSpiritInfo and soulSpiritInfo.id

        self._showList = self._heroIdList
        self._model = QUIDialogSoulSpiritDetail.MODEL_HERO
    end
    print("QUIDialogSoulSpiritDetail:initList(2) ", self._id, self._soulSpiritIdList, self._heroId, self._heroIdList)

    self._ccbOwner.arrowLeft:setVisible(#self._showList > 1)
    self._ccbOwner.btn_left:setVisible(#self._showList > 1)
    self._ccbOwner.arrowRight:setVisible(#self._showList > 1)
    self._ccbOwner.btn_right:setVisible(#self._showList > 1)

	if self._soulSpiritBox == nil then
	    self._soulSpiritBox = QUIWidgetSoulSpiritHead.new()
        self._soulSpiritBox:addEventListener(QUIWidgetSoulSpiritHead.EVENT_SOULSPIRIT_HEAD_CLICK, handler(self, self.onEvent))
	    self._ccbOwner.node_box:addChild(self._soulSpiritBox)
        self._soulSpiritBox:setScale(0.8)
	end

    self:updateInfo()
end

function QUIDialogSoulSpiritDetail:updateInfo()
    self:updateBox()
	self._ccbOwner.node_avatar:removeAllChildren()

	if not self._heroId or self._heroId == 0 then
        self:initNoHero()
	else
        self:initHero()
    end

    self:updateButton()
    self:selectTab()
    self:checkRedTips()
end

function QUIDialogSoulSpiritDetail:initNoHero()
    self._ccbOwner.node_heroName:setVisible(false)
    self._ccbOwner.node_force:setVisible(false)
    self._ccbOwner.node_sketch:setVisible(true)
end

function QUIDialogSoulSpiritDetail:initHero()
    local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
    if not heroInfo then 
        self:initNoHero()
        return 
    end

    self._ccbOwner.node_heroName:setVisible(true)
    self._ccbOwner.node_force:setVisible(true)
    self._ccbOwner.node_right:setVisible(true)
    self._ccbOwner.node_sketch:setVisible(false)

    local fontColor = BREAKTHROUGH_COLOR_LIGHT["white"]
	local breakLevel, color = remote.herosUtil:getBreakThrough(heroInfo.breakthrough)
	if color ~= nil then
        fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    self._ccbOwner.tf_level:setColor(fontColor)
    self._ccbOwner.tf_level = setShadowByFontColor(self._ccbOwner.tf_level, fontColor)

    local characher = QStaticDatabase.sharedDatabase():getCharacterByID(self._heroId)
	local name = characher.name or ""
	if breakLevel > 0 then
		name = name.." +"..breakLevel
	end
	self._ccbOwner.tf_name:setString(name)
    self._ccbOwner.tf_level:setString("LV."..(heroInfo.level or "0"))

	local heroInfomation = QUIWidgetHeroInformation.new()
	self._ccbOwner.node_avatar:addChild(heroInfomation:getView())
	heroInfomation:setAvatar(heroInfo.actorId, 1.1)
	heroInfomation:setNameVisible(false)
	heroInfomation:setStarVisible(false)
	heroInfomation:setBackgroundVisible(false)

	local heroModel = remote.herosUtil:createHeroProp(heroInfo)
	local battleForce = heroModel:getBattleForce()
    self._oldBattleForce = battleForce
	self:setBattleForceText(battleForce)
end

function QUIDialogSoulSpiritDetail:setBattleForceText(battleForce)
    local num, word = q.convertLargerNumber(battleForce)
    self._ccbOwner.tf_force:setString(num..word)

    local fontInfo = QStaticDatabase.sharedDatabase():getForceColorByForce(battleForce)
    if fontInfo ~= nil then
		local color = string.split(fontInfo.force_color, ";")
		self._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))
    end

	if battleForce == self._newBattle then
		self._ccbOwner.tf_force:runAction(CCScaleTo:create(0.2, 1))
	end
	self._oldBattleForce = battleForce
end 

function QUIDialogSoulSpiritDetail:checkRedTips()
    self._ccbOwner.detail_tip:setVisible(false)
    self._ccbOwner.level_tip:setVisible(false)
    self._ccbOwner.grade_tip:setVisible(false)
    self._ccbOwner.awaken_tip:setVisible(false)
	self._ccbOwner.inherit_tip:setVisible(false)
	if self._id and self._id > 0 then
        self._ccbOwner.grade_tip:setVisible(remote.soulSpirit:isGradeRedTipsById(self._id))
        self._ccbOwner.awaken_tip:setVisible(remote.soulSpirit:isAwakenRedTipsById(self._id))
		self._ccbOwner.inherit_tip:setVisible(remote.soulSpirit:isInheritRedTipsById(self._id))
	end
end

function QUIDialogSoulSpiritDetail:removeAllTabState()
 --    self._ccbOwner.btn_tab_detail:setEnabled(true)
 --    self._ccbOwner.btn_tab_detail:setHighlighted(false)
	-- self._ccbOwner.btn_tab_level:setEnabled(true)
	-- self._ccbOwner.btn_tab_level:setHighlighted(false)
	-- self._ccbOwner.btn_tab_grade:setEnabled(true)
	-- self._ccbOwner.btn_tab_grade:setHighlighted(false)
    self._ccbOwner.node_master:setVisible(false)
    self._ccbOwner.tf_empty_tips:setVisible(false)
end

function QUIDialogSoulSpiritDetail:selectTab()
	self:getOptions().tab = self._tab
	self:removeAllTabState()

	if self._rightWidget ~= nil then
		self._rightWidget:setVisible(false)
		self._rightWidget = nil
	end
    if self._tab == QUIDialogSoulSpiritDetail.TAB_DETAIL then
        self:selectedTabDetail()
        self._ccbOwner.frame_tf_title:setString("魂灵详情")
	elseif self._tab == QUIDialogSoulSpiritDetail.TAB_LEVEL then
        self:updateMaster()
		self:selectedTabLevel()
        self._ccbOwner.frame_tf_title:setString("魂灵吞噬")
	elseif self._tab == QUIDialogSoulSpiritDetail.TAB_GRADE then
		self:selectedTabGrade()
        self._ccbOwner.frame_tf_title:setString("魂灵升星")
    elseif self._tab == QUIDialogSoulSpiritDetail.TAB_AWAKEN then
        self:selectedTabAwaken()
        self._ccbOwner.frame_tf_title:setString("魂灵觉醒")
    elseif self._tab == QUIDialogSoulSpiritDetail.TAB_INHERIT then
        self:selectedTabInherit()
        self._ccbOwner.frame_tf_title:setString("魂灵传承")        
	end

	if self._rightWidget ~= nil then
		self._rightWidget:setVisible(true)
	end
end

function QUIDialogSoulSpiritDetail:updateBox()
    if self._id then
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._soulSpiritBox:setInfo(soulSpiritInfo)
    else
        self._soulSpiritBox:setInfo()
    end
end


function QUIDialogSoulSpiritDetail:updateButton()

    local soulSpiritId = 0 
    if self._id then
        soulSpiritId = self._id
    elseif self._heroId then

        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        soulSpiritId = soulSpiritInfo and soulSpiritInfo.id or 0
    end

    if soulSpiritId == 0 then
    self._ccbOwner.node_awaken:setVisible(false)
    self._ccbOwner.node_inherit:setVisible(false)
        self._tab = QUIDialogSoulSpiritDetail.TAB_DETAIL
        return
    end

    local characterConfig = db:getCharacterByID(soulSpiritId)
    local quality = characterConfig.aptitude
    local unlockAwaken = app.unlock:checkLock("UNLOCK_SOUL_AWAKEN") and quality >=APTITUDE.S
    local unlockInherit = quality >=APTITUDE.SS 

    self._ccbOwner.node_awaken:setVisible(unlockAwaken)
    self._ccbOwner.node_inherit:setVisible(unlockInherit)
    if not unlockAwaken then
        self._ccbOwner.node_inherit:setPositionY(-18)
    else
        self._ccbOwner.node_inherit:setPositionY(-93)
    end


    if self._tab == QUIDialogSoulSpiritDetail.TAB_AWAKEN and not unlockAwaken then
        self._tab = QUIDialogSoulSpiritDetail.TAB_DETAIL
    elseif self._tab == QUIDialogSoulSpiritDetail.TAB_INHERIT and not unlockInherit then
        self._tab = QUIDialogSoulSpiritDetail.TAB_DETAIL
    end
end

function QUIDialogSoulSpiritDetail:updateMaster()
    -- print("QUIDialogSoulSpiritDetail:updateMaster() ", self._id)
    if self._id then
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        local soulSpiritConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
        local masterConfigListWithAptitude = remote.soulSpirit:getMasterConfigListByAptitude(soulSpiritConfig.aptitude) or {}
        for _, config in ipairs(masterConfigListWithAptitude) do
            if config.condition <= soulSpiritInfo.level then
                self._ccbOwner.master_level:setString("LV"..config.level)
            end
        end
        self._ccbOwner.node_master:setVisible(true)
    else
        self._ccbOwner.node_master:setVisible(false)
    end
end

function QUIDialogSoulSpiritDetail:unwearHandler(event)
    print("QUIDialogSoulSpiritDetail:unwearHandler() ", event.id)
    local id = event.id

    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)

    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
    local levelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(characterConfig.aptitude, soulSpiritInfo.level)
    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, soulSpiritInfo.grade)
    local inheritConfig = db:getSoulSpiritInheritConfig(soulSpiritInfo.devour_level , soulSpiritInfo.id)

    local propDic = {}
    propDic = remote.soulSpirit:getPropDicByConfig(levelConfig, propDic)
    propDic = remote.soulSpirit:getPropDicByConfig(gradeConfig, propDic)
    propDic = remote.soulSpirit:getPropDicByConfig(inheritConfig, propDic)

    local ccbFile = "ccb/effects/SoulSpirit_PropTips.ccbi"
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end
    if self._model == QUIDialogSoulSpiritDetail.MODEL_SOULSPIRIT then
        self._id = event.id
        self._heroId = nil
    elseif self._model == QUIDialogSoulSpiritDetail.MODEL_HERO then
        self._id = nil
        self._heroId = event.heroId
    end
    self:getOptions().id = self._id
    self:getOptions().heroId = self._heroId
    self:updateInfo()
    self._wearEffectShow = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(self._wearEffectShow)
    self._wearEffectShow:setPosition(ccp(0, 100))
    self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
    	ccbOwner.node_red:setVisible(true)
    	ccbOwner.node_green:setVisible(false)
        ccbOwner.tf_title2:setString("取消护佑")
        for i= 6, 10 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local function addPropText(name,value)
            if index > 5 then return end
            ccbOwner["node_"..(index+5)]:setVisible(true)
            ccbOwner["tf_name"..(index+5)]:setString(name.."－"..value)
            index = index + 1
        end
        for key, value in pairs(propDic) do
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            if not isPercent then
                -- 策劃的特殊需求，穿戴的時候，不顯示百分比的屬性，因為加了百分比屬性，必須合併不然太多，但合併了又太長，影響美觀！
                local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2) 
                addPropText(name, str)
            end
        end
        end, function()
            if self._wearEffectShow ~= nil then
                self._wearEffectShow:disappear()
                self._wearEffectShow = nil
            end
            
            remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end)    
end

function QUIDialogSoulSpiritDetail:wearHandler(event)
    local id = event.id

    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(id)

    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(id)
    local levelConfig = remote.soulSpirit:getLevelConfigByAptitudeAndLevel(characterConfig.aptitude, soulSpiritInfo.level)
    local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(id, soulSpiritInfo.grade)
    local inheritConfig = db:getSoulSpiritInheritConfig(soulSpiritInfo.devour_level , soulSpiritInfo.id)

    local propDic = {}
    propDic = remote.soulSpirit:getPropDicByConfig(levelConfig, propDic)
    propDic = remote.soulSpirit:getPropDicByConfig(gradeConfig, propDic)
    propDic = remote.soulSpirit:getPropDicByConfig(inheritConfig, propDic)

    local ccbFile = "ccb/effects/SoulSpirit_PropTips.ccbi"
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end

    if self._model == QUIDialogSoulSpiritDetail.MODEL_HERO then
         local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
        arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
        arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
        arr:addObject(CCScaleTo:create(0.1,0.8,0.8))
        self._soulSpiritBox:runAction(CCSequence:create(arr))
    end
    
    app.sound:playSound("sound_num")

    self._id = event.id
    self._heroId = event.heroId
    self:getOptions().id = self._id
    self:getOptions().heroId = self._heroId
    self:updateInfo()

    self:enableTouchSwallowTop()
    self._wearEffectShow = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(self._wearEffectShow)
    self._wearEffectShow:setPosition(ccp(0, 100))
    self._wearEffectShow:playAnimation(ccbFile, function(ccbOwner)
        ccbOwner.node_green:setVisible(true)
        ccbOwner.node_red:setVisible(false)
        ccbOwner.tf_title1:setString("护佑成功")
        for i=1, 5 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local function addPropText(name,value)
            if index > 5 then return end
            ccbOwner["node_"..index]:setVisible(true)
            ccbOwner["tf_name"..index]:setString(name.."＋"..value)
            index = index + 1
        end
        for key, value in pairs(propDic) do
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            if not isPercent then
                -- 策劃的特殊需求，穿戴的時候，不顯示百分比的屬性，因為加了百分比屬性，必須合併不然太多，但合併了又太長，影響美觀！
                local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2) 
                addPropText(name, str)
            end
        end
        end, function()
            if self._wearEffectShow ~= nil then
                self._wearEffectShow:disappear()
                self._wearEffectShow = nil
            end
            
            self:disableTouchSwallowTop()
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end)    
end

function QUIDialogSoulSpiritDetail:selectedTabLevel()
	-- self._ccbOwner.btn_tab_level:setEnabled(false)
	-- self._ccbOwner.btn_tab_level:setHighlighted(true)
    self._tabManager:selected(self._ccbOwner.btn_tab_level)

    if not self._id or self._id == 0 then
        self._ccbOwner.node_right:setVisible(false)
        self._ccbOwner.tf_empty_tips:setVisible(true)
        return
    end

	if self._levelWidget == nil then
        print("[Kumo] add QUIWidgetSoulSpiritLevel ")
		self._levelWidget = QUIWidgetSoulSpiritLevel.new()
		self._ccbOwner.node_right:addChild(self._levelWidget)
	end
	self._levelWidget:setInfo(self._id, self._heroId)
	self._rightWidget = self._levelWidget
end

function QUIDialogSoulSpiritDetail:_isWidgetLock()
    local isLock = false

    if self._levelWidget then
        if self._levelWidget.isPlaying then
            isLock = self._levelWidget:isPlaying()
        end
    end

    return isLock
end

function QUIDialogSoulSpiritDetail:selectedTabGrade()
	-- self._ccbOwner.btn_tab_grade:setEnabled(false)
	-- self._ccbOwner.btn_tab_grade:setHighlighted(true)
    self._tabManager:selected(self._ccbOwner.btn_tab_grade)
    
    if not self._id or self._id == 0 then
        self._ccbOwner.node_right:setVisible(false)
        self._ccbOwner.tf_empty_tips:setVisible(true)
        return
    end

	if self._gradeWidget == nil then
        print("[Kumo] add QUIWidgetSoulSpiritGrade ")
		self._gradeWidget = QUIWidgetSoulSpiritGrade.new()
		self._ccbOwner.node_right:addChild(self._gradeWidget)
	end
	self._gradeWidget:setInfo(self._id, self._heroId)
	self._rightWidget = self._gradeWidget
end

function QUIDialogSoulSpiritDetail:selectedTabAwaken()
    self._tabManager:selected(self._ccbOwner.btn_tab_awaken)
    
    if not self._id or self._id == 0 then
        self._ccbOwner.node_right:setVisible(false)
        self._ccbOwner.tf_empty_tips:setVisible(true)
        return
    end

    if self._awakenWidget == nil then
        print("[qsy] add QUIWidgetSoulSpiritAwaken ")
        self._awakenWidget = QUIWidgetSoulSpiritAwaken.new()
        self._ccbOwner.node_right:addChild(self._awakenWidget)
    end
    self._awakenWidget:setInfo(self._id, self._heroId)
    self._rightWidget = self._awakenWidget
end

function QUIDialogSoulSpiritDetail:selectedTabInherit()
    self._tabManager:selected(self._ccbOwner.btn_tab_inherit)
    
    if not self._id or self._id == 0 then
        self._ccbOwner.node_right:setVisible(false)
        self._ccbOwner.tf_empty_tips:setVisible(true)
        return
    end

    if self._inheritWidget == nil then
        print("[qsy] add QUIWidgetSoulSpiritInherit ")
        self._inheritWidget = QUIWidgetSoulSpiritInherit.new()
        self._ccbOwner.node_right:addChild(self._inheritWidget)
    end
    self._inheritWidget:setInfo(self._id)
    self._rightWidget = self._inheritWidget
end

function QUIDialogSoulSpiritDetail:selectedTabDetail()
	-- self._ccbOwner.btn_tab_detail:setEnabled(false)
	-- self._ccbOwner.btn_tab_detail:setHighlighted(true)
    self._tabManager:selected(self._ccbOwner.btn_tab_detail)

    if not self._id or self._id == 0 then
        self._ccbOwner.node_right:setVisible(false)
        self._ccbOwner.tf_empty_tips:setVisible(true)
        return
    end

	if self._detailWidget == nil then
        print("[Kumo] add QUIWidgetSoulSpiritDetail ")
		self._detailWidget = QUIWidgetSoulSpiritDetail.new()
		self._ccbOwner.node_right:addChild(self._detailWidget)
	end
    self._detailWidget:setInfo(self._id, self._heroId)
	self._rightWidget = self._detailWidget
end

function QUIDialogSoulSpiritDetail:onHeroSelected(event)
    if event.actorId and self._id then
        remote.soulSpirit:soulSpiritEquipRequest(event.actorId, self._id, true)
    end
end

function QUIDialogSoulSpiritDetail:onEvent(event)
	if event.name == remote.HERO_UPDATE_EVENT then
		self:updateInfo()
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:updateBattleForce()
    elseif event.name == QUIWidgetSoulSpiritHead.EVENT_SOULSPIRIT_HEAD_CLICK then
        if self._heroId and not self._id then
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOverView", 
                options = {heroId = self._heroId}})
        end
    elseif event.name == remote.soulSpirit.EVENT_UPDATE then
        self:updateMaster()
        self:updateBox()
        self:checkRedTips()
	end
end

function QUIDialogSoulSpiritDetail:updateBattleForce()
	if self._oldBattleForce == nil or self._oldBattleForce == 0 then return end
    if not self._heroId or self._heroId == 0 then return end

	local heroProp = remote.herosUtil:createHeroPropById(self._heroId)
	local battleForce = heroProp:getBattleForce()
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

function QUIDialogSoulSpiritDetail:_onTriggerTabLevel()
    if self:_isWidgetLock() then return end

    if self._tab == QUIDialogSoulSpiritDetail.TAB_LEVEL then
        return
    end
    app.sound:playSound("common_menu")
    self._tab = QUIDialogSoulSpiritDetail.TAB_LEVEL
	self:selectTab()
end

function QUIDialogSoulSpiritDetail:_onTriggerTabGrade()
    if self:_isWidgetLock() then return end

    if self._tab == QUIDialogSoulSpiritDetail.TAB_GRADE then
        return
    end
	app.sound:playSound("common_menu")
    self._tab = QUIDialogSoulSpiritDetail.TAB_GRADE
	self:selectTab()
end

function QUIDialogSoulSpiritDetail:_onTriggerTabDetail()
    if self:_isWidgetLock() then return end

    if self._tab == QUIDialogSoulSpiritDetail.TAB_DETAIL then
        return
    end
	app.sound:playSound("common_menu")
    self._tab = QUIDialogSoulSpiritDetail.TAB_DETAIL
	self:selectTab()
end

function QUIDialogSoulSpiritDetail:_onTriggerTabAwaken()
    if self:_isWidgetLock() then return end

    if self._tab == QUIDialogSoulSpiritDetail.TAB_AWAKEN then
        return
    end
    app.sound:playSound("common_menu")
    self._tab = QUIDialogSoulSpiritDetail.TAB_AWAKEN
    self:selectTab()
end


function QUIDialogSoulSpiritDetail:_onTriggerTabInherit()
    if self:_isWidgetLock() then return end

    if self._tab == QUIDialogSoulSpiritDetail.TAB_INHERIT then
        return
    end
    app.sound:playSound("common_menu")
    self._tab = QUIDialogSoulSpiritDetail.TAB_INHERIT
    self:selectTab()
end

function QUIDialogSoulSpiritDetail:_onTriggerMaster()
    if self:_isWidgetLock() then return end

	app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritMasterInfo", 
        options = {id = self._id}})
end

function QUIDialogSoulSpiritDetail:stopActionAndEffect()
    if self._textUpdate then
        self._textUpdate:stopUpdate()
    end
    if self._wearEffectShow ~= nil then
        self._wearEffectShow:disappear()
        self._wearEffectShow = nil
    end
end

function QUIDialogSoulSpiritDetail:_onTriggerLeft()
    if self:_isWidgetLock() then return end

    app.sound:playSound("common_change")

    self:stopActionAndEffect()

    if self._model == QUIDialogSoulSpiritDetail.MODEL_SOULSPIRIT then
        local nextIndex = self._soulSpiritIndex - 1
        nextIndex = nextIndex <= 0 and #self._soulSpiritIdList or nextIndex
        self._soulSpiritIndex = nextIndex

        self._id = self._soulSpiritIdList[self._soulSpiritIndex]
        self:getOptions().id = self._id
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = soulSpiritInfo.heroId
        self:getOptions().heroId = self._heroId
    elseif self._model == QUIDialogSoulSpiritDetail.MODEL_HERO then
        local nextIndex = self._heroIdIndex - 1
        nextIndex = nextIndex <= 0 and #self._heroIdList or nextIndex
        self._heroIdIndex = nextIndex

        self._heroId = self._heroIdList[self._heroIdIndex]
        self:getOptions().heroId = self._heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        self._id = soulSpiritInfo and soulSpiritInfo.id
        self:getOptions().id = self._id
    end

    self:updateInfo()
    self:updateBattleForce()
end

function QUIDialogSoulSpiritDetail:_onTriggerRight()
    if self:_isWidgetLock() then return end

    app.sound:playSound("common_change")
    
    self:stopActionAndEffect()

    if self._model == QUIDialogSoulSpiritDetail.MODEL_SOULSPIRIT then
        local nextIndex = self._soulSpiritIndex + 1
        nextIndex = nextIndex > #self._soulSpiritIdList and 1 or nextIndex
        self._soulSpiritIndex = nextIndex

        self._id = self._soulSpiritIdList[self._soulSpiritIndex]
        self:getOptions().id = self._id
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = soulSpiritInfo.heroId
        self:getOptions().heroId = self._heroId
    elseif self._model == QUIDialogSoulSpiritDetail.MODEL_HERO then
        local nextIndex = self._heroIdIndex + 1
        nextIndex = nextIndex > #self._heroIdList and 1 or nextIndex
        self._heroIdIndex = nextIndex

        self._heroId = self._heroIdList[self._heroIdIndex]
        self:getOptions().heroId = self._heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        self._id = soulSpiritInfo and soulSpiritInfo.id
        self:getOptions().id = self._id
    end

    self:updateInfo()
    self:updateBattleForce()
end

function QUIDialogSoulSpiritDetail:_onTriggerAvatar()
    if self:_isWidgetLock() then return end
    app.sound:playSound("common_small")
    local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
    QPrintTable(soulSpiritInfo)
    if soulSpiritInfo and soulSpiritInfo.heroId and soulSpiritInfo.heroId > 0 then
        -- 有魂師，點擊魂師，目前無事發生。以後未知。
    else
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview", options = {soulSpiritEquip = true}}, {isPopCurrentDialog = false})
    end
end

function QUIDialogSoulSpiritDetail:onTriggerBackHandler(tag)
    if self:_isWidgetLock() then return end

	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogSoulSpiritDetail:onTriggerHomeHandler(tag)
    if self:_isWidgetLock() then return end

	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogSoulSpiritDetail:_onTriggerBack(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogSoulSpiritDetail:_onTriggerHome(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogSoulSpiritDetail