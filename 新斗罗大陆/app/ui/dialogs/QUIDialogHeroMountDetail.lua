local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHeroMountDetail = class("QUIDialogHeroMountDetail", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetMountInfoDetail = import("..widgets.mount.QUIWidgetMountInfoDetail")
local QUIWidgetMountInfoEmpty = import("..widgets.mount.QUIWidgetMountInfoEmpty")
local QUIWidgetMountInfoStrength = import("..widgets.mount.QUIWidgetMountInfoStrength")
local QUIWidgetMountInfoGrade = import("..widgets.mount.QUIWidgetMountInfoGrade")
local QUIWidgetMountInfoChange = import("..widgets.mount.QUIWidgetMountInfoChange")
local QUIWidgetMountInfoTalent = import("..widgets.mount.QUIWidgetMountInfoTalent")
local QUIWidgetMountInfoGrave = import("..widgets.mount.QUIWidgetMountInfoGrave")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

QUIDialogHeroMountDetail.TAB_STRONG = "TAB_STRONG"
QUIDialogHeroMountDetail.TAB_GRADE = "TAB_GRADE"
QUIDialogHeroMountDetail.TAB_DETAIL = "TAB_DETAIL"
QUIDialogHeroMountDetail.TAB_CHANGE = "TAB_CHANGE"
QUIDialogHeroMountDetail.TAB_TALENT = "TAB_TALENT"
QUIDialogHeroMountDetail.TAB_MARBLE = "TAB_MARBLE"

-- 魂师装备暗器
function QUIDialogHeroMountDetail:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_xinxi_04.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerTabDetail", callback = handler(self, self._onTriggerTabDetail)},
		{ccbCallbackName = "onTriggerTabGrade", callback = handler(self, self._onTriggerTabGrade)},
		{ccbCallbackName = "onTriggerTabStrength", callback = handler(self, self._onTriggerTabStrength)},
        {ccbCallbackName = "onTriggerTabChange", callback = handler(self, self._onTriggerTabChange)},
		{ccbCallbackName = "onTriggerTabTalent", callback = handler(self, self._onTriggerTabTalent)},
		{ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggerRight)},
		{ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggerLeft)},
		{ccbCallbackName = "onTriggerMaster", callback = handler(self, self._onTriggerMaster)},
		{ccbCallbackName = "onTriggerTabMarble", callback = handler(self, self._onTriggerTabMarble)},
	}
	QUIDialogHeroMountDetail.super.ctor(self, ccbFile, callBacks, options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setManyUIVisible()
    page.topBar:showWithMount()
	

    ui.tabButton(self._ccbOwner.tab_detail, "详情")
    ui.tabButton(self._ccbOwner.tab_level, "精炼")
    ui.tabButton(self._ccbOwner.tab_grade, "升星")
    ui.tabButton(self._ccbOwner.tab_change, "改造")
    ui.tabButton(self._ccbOwner.tab_talent, "配件")
    ui.tabButton(self._ccbOwner.tab_marble, "雕刻")

    self._tabManager = ui.tabManager({self._ccbOwner.tab_detail, self._ccbOwner.tab_level, self._ccbOwner.tab_grade,self._ccbOwner.tab_change,
                        self._ccbOwner.tab_talent,self._ccbOwner.tab_marble})


	if options ~= nil then
		self._pos = options.pos or 0
		self._heros = options.heros or {}
		self._currentTab = options.initTab
	end
	self._equipmentStrengthen = nil
	self._oldBattleForce = 0
    if self:checkCunrrentMountIsSS(self._heros[self._pos]) then
		self._showSSMountEffect = true
	end

	if #self._heros == 1 then
        self._ccbOwner.arrowLeft:setVisible(false)
        self._ccbOwner.arrowRight:setVisible(false)
    end
    self._ccbOwner.node_back:setVisible(false)
    self._ccbOwner.frame_tf_title:setString("暗  器")
end

function QUIDialogHeroMountDetail:viewDidAppear()
	QUIDialogHeroMountDetail.super.viewDidAppear(self)

    self._mountProxy = cc.EventProxy.new(remote.mount)
    self._mountProxy:addEventListener(remote.mount.EVENT_WEAR, handler(self, self.mountWearHandler))
    self._mountProxy:addEventListener(remote.mount.EVENT_UNWEAR, handler(self, self.mountUnwearHandler))
    self._mountProxy:addEventListener(remote.mount.EVENT_WEAR_MOUNT, handler(self, self.mountWearMountHandler))
    self._mountProxy:addEventListener(remote.mount.EVENT_UNWEAR_MOUNT, handler(self, self.mountUnwearMountHandler))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self.onEvent))

	self:addBackEvent()
	self:setInfo(self._heros[self._pos])
end

function QUIDialogHeroMountDetail:viewWillDisappear()
	QUIDialogHeroMountDetail.super.viewWillDisappear(self)

	self._mountProxy:removeAllEventListeners()
	self._remoteProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()
	self:removeBackEvent()

	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end
end

function QUIDialogHeroMountDetail:setInfo(actorId)
	self._actorId = actorId
	self._hero = remote.herosUtil:getHeroByID(actorId)
	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self:initHeroArea()
	self:updateMountInfo()
	self:tabSelectHandler()
	self:checkRedTips()
end

--初始化装备这块和头像
function QUIDialogHeroMountDetail:initHeroArea()
	self._heroInfo = clone(remote.herosUtil:getHeroByID(self._actorId))
	local characher = db:getCharacterByID(self._actorId)
	self._ccbOwner.tf_level:setString("LV."..(self._heroInfo.level or "0"))
    self._ccbOwner.node_force:setVisible(true)

    local fontColor = BREAKTHROUGH_COLOR_LIGHT["white"]
	local breakLevel,color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	self._ccbOwner.tf_level:setColor(fontColor)
	self._ccbOwner.tf_level = setShadowByFontColor(self._ccbOwner.tf_level, fontColor)

	local name = characher.name or ""
	if breakLevel > 0 then
		name = name.." +"..breakLevel
	end
	self._ccbOwner.tf_name:setString(name)
	self:updateMasterLevel()

	self._ccbOwner.node_avatar:removeAllChildren()
	local information = QUIWidgetHeroInformation.new()
	self._ccbOwner.node_avatar:addChild(information:getView())
	information:setAvatar(self._heroInfo.actorId, 1.1)
	information:setNameVisible(false)
	information:setStarVisible(false)
	information:setBackgroundVisible(false)

	local heroModel = remote.herosUtil:createHeroProp(self._heroInfo)
	local battleForce = heroModel:getBattleForce()
    self._oldBattleForce = battleForce
	self:setBattleForceText(battleForce)

	-- 暗器部分
	if self._mountBox == nil then
	    self._mountBox = QUIWidgetMountBox.new()
        self._mountBox:addEventListener(self._mountBox.MOUNT_EVENT_CLICK, handler(self, self.mountClickHandler))
	    self._ccbOwner.node_mount_box:addChild(self._mountBox)
	    self._ccbOwner.node_mount_box:setScale(1.2)
	end
    self._mountBox:setHero(self._actorId)
end

function QUIDialogHeroMountDetail:updateMasterLevel()
	self._ccbOwner.master_level:setString("LV.0")
	if self._heroInfo.zuoqi then
		if self._currentTab == QUIDialogHeroMountDetail.TAB_STRONG then
		    local mountConfig = db:getCharacterByID(self._heroInfo.zuoqi.zuoqiId)
		    local talents = db:getMountMasterInfo(mountConfig.aptitude) or {}
		    for i, talent in pairs(talents) do
		        if talent.condition <= self._heroInfo.zuoqi.enhanceLevel then
		            self._ccbOwner.master_level:setString("LV."..talent.level)
		        end
		    end
		elseif self._currentTab == QUIDialogHeroMountDetail.TAB_MARBLE then
			local talents = remote.mount:getMountGraveMaster(self._heroInfo.zuoqi.zuoqiId)
		    for i, talent in pairs(talents) do
		        if talent.condition <= (self._heroInfo.zuoqi.grave_level or 0) then
		            self._ccbOwner.master_level:setString("LV."..talent.level)
		        end
		    end
		end
	end	
end

function QUIDialogHeroMountDetail:updateMountInfo()
	-- 是否有配件
	local isHasTalent = false

	self._ccbOwner.node_dress_mount_box:removeAllChildren()
	self._ccbOwner.node_dressing:setVisible(false)
    self._ccbOwner.node_talent:setVisible(false)
    self._ccbOwner.node_change:setVisible(false)
    self._ccbOwner.node_marble:setVisible(false)

	if self._heroInfo.zuoqi then
		local mountInfo = remote.mount:getMountById(self._heroInfo.zuoqi.zuoqiId)
	    if remote.mount:getIsSuperMount(self._heroInfo.zuoqi.zuoqiId) then
	        self._ccbOwner.node_normal_mount:setVisible(false)
	        self._ccbOwner.node_super_mount:setVisible(true)
	        self._ccbOwner.node_mount_box:setPositionX(-40)
	        self._ccbOwner.node_talent:setVisible(true)
        	self._ccbOwner.node_change:setVisible(true)

	        self._wearMountBox = QUIWidgetMountBox.new()
	        self._wearMountBox:addEventListener(self._wearMountBox.MOUNT_EVENT_CLICK, handler(self, self.wearMountClickHandler))
        	self._wearMountBox:showRedTips(false)
	        self._ccbOwner.node_dress_mount_box:addChild(self._wearMountBox)
	        if mountInfo.wearZuoqiInfo then
	            self._wearMountBox:setMountInfo(mountInfo.wearZuoqiInfo)
	        	self._wearMountBox:showRedTips(remote.mount:checkMountCanGrade(mountInfo.wearZuoqiInfo))
	        else
	            self._wearMountBox:setNoDressTips()
	        	self._wearMountBox:showRedTips(remote.mount:checkNoEquipMountS())
	        end
	        isHasTalent = true

	        if remote.mount:getIsSSRMount(self._heroInfo.zuoqi.zuoqiId) then
	        	self._ccbOwner.node_marble:setVisible(true)
	        end
	    else
	        self._ccbOwner.node_normal_mount:setVisible(true)
	        self._ccbOwner.node_super_mount:setVisible(false)
	        self._ccbOwner.node_mount_box:setPositionX(20)

	        if mountInfo.superZuoqiId and mountInfo.superZuoqiId > 0 then
	            local characher = db:getCharacterByID(mountInfo.superZuoqiId)
	            self._ccbOwner.tf_dressing_tips:setString(string.format("当前暗器佩戴在%s上", characher.name))
	            self._ccbOwner.node_dressing:setVisible(true)
	        end
	    end
	else
		self._ccbOwner.node_normal_mount:setVisible(true)
        self._ccbOwner.node_super_mount:setVisible(false)
        self._ccbOwner.node_mount_box:setPositionX(20)
	end

	if ((self._currentTab == QUIDialogHeroMountDetail.TAB_TALENT or self._currentTab == QUIDialogHeroMountDetail.TAB_CHANGE) and not isHasTalent) 
		or (self._currentTab == QUIDialogHeroMountDetail.TAB_MARBLE and not remote.mount:getIsSSRMount(self._heroInfo.zuoqi.zuoqiId)) then
        self._currentTab = QUIDialogHeroMountDetail.TAB_DETAIL
    end
end

function QUIDialogHeroMountDetail:setBattleForceText(battleForce)
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

function QUIDialogHeroMountDetail:tabSelectHandler()
	if self._hero.zuoqi ~= nil then
		self._currentTab = self._currentTab or QUIDialogHeroMountDetail.TAB_DETAIL
		self:selectTab(self._currentTab, true)
	else
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		self:removeAllTabState()
		if self._emptyWidget == nil then
			self._emptyWidget = QUIWidgetMountInfoEmpty.new()
			self._ccbOwner.node_right:addChild(self._emptyWidget)
		end
		self._emptyWidget:setInfo(self._actorId)
		self._infoWidget = self._emptyWidget
		self._infoWidget:setVisible(true)
	end
end

function QUIDialogHeroMountDetail:checkRedTips()
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	self._ccbOwner.sp_grade_tip:setVisible(UIHeroModel:getMountGradeTip())
	self._ccbOwner.sp_change_tip:setVisible(UIHeroModel:getMountReformTip())
	self._ccbOwner.sp_marble_tip:setVisible(UIHeroModel:getMountGraveTip())
end

function QUIDialogHeroMountDetail:removeAllTabState()
    self._ccbOwner.node_master:setVisible(false)
    self._ccbOwner.sp_detail_tip:setVisible(false)
    self._ccbOwner.sp_level_tip:setVisible(false)
    self._ccbOwner.sp_change_tip:setVisible(false)
    self._ccbOwner.sp_talent_tip:setVisible(false)
    self._ccbOwner.sp_marble_tip:setVisible(false)
end

function QUIDialogHeroMountDetail:selectTab(name, isforce)
	if self._hero.zuoqi == nil then 
		app.tip:floatTip("魂师大人，您目前还没有装备暗器哦~")
		return 
	end
	
    if self:checkCunrrentMountIsSS(self._heros[self._pos]) then
    	self._showSSMountEffect = true
	end

	if self._currentTab ~= name or isforce == true then
		self._currentTab = name
		self:getOptions().initTab = name
		self:removeAllTabState()
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(false)
			self._infoWidget = nil
		end
		if self._currentTab == QUIDialogHeroMountDetail.TAB_DETAIL then
	        self._ccbOwner.frame_tf_title:setString("暗器详情")
	        -- self._ccbOwner.sp_detail_tip:setPositionX(40)
	        self._tabManager:selected(self._ccbOwner.tab_detail)
	        self:selectedTabDetail()
	    elseif self._currentTab == QUIDialogHeroMountDetail.TAB_STRONG then
	        self._ccbOwner.frame_tf_title:setString("暗器精炼")
	        self._ccbOwner.node_master:setVisible(true)
	        self:updateMasterLevel()
	        -- self._ccbOwner.sp_level_tip:setPositionX(40)
	        self._tabManager:selected(self._ccbOwner.tab_level)
	        self:selectedTabLevel()
	    elseif self._currentTab == QUIDialogHeroMountDetail.TAB_GRADE then
	        self._ccbOwner.frame_tf_title:setString("暗器升星")
	        -- self._ccbOwner.sp_grade_tip:setPositionX(40)
	        self._tabManager:selected(self._ccbOwner.tab_grade)
	        self:selectedTabGrade()
	    elseif self._currentTab == QUIDialogHeroMountDetail.TAB_CHANGE then
	        self._ccbOwner.frame_tf_title:setString("暗器改造")
	        -- self._ccbOwner.sp_change_tip:setPositionX(40)
	        self._tabManager:selected(self._ccbOwner.tab_change)
	        self:selectedTabChange()
	    elseif self._currentTab == QUIDialogHeroMountDetail.TAB_TALENT then
	        self._ccbOwner.frame_tf_title:setString("暗器配件")
	        self._tabManager:selected(self._ccbOwner.tab_talent)
	        -- self._ccbOwner.sp_talent_tip:setPositionX(40)
	        self:selectedTabTalent()
	    elseif self._currentTab == QUIDialogHeroMountDetail.TAB_MARBLE then
	    	self._ccbOwner.frame_tf_title:setString("暗器雕刻")
	    	self._tabManager:selected(self._ccbOwner.tab_marble)
	    	self._ccbOwner.node_master:setVisible(true)
	    	self:updateMasterLevel()
	    	self:selectedTabMarble()
	    end
		if self._infoWidget ~= nil then
			self._infoWidget:setVisible(true)
		end
	end
end

--卸载暗器
function QUIDialogHeroMountDetail:mountUnwearMountHandler(event)
    self:mountUnwearHandler(event) 
end

--卸载暗器
function QUIDialogHeroMountDetail:mountUnwearHandler(event)
    local mountId = event.mountId
    local mountProp = remote.mount:getMountPropById(mountId)
    local prop = mountProp:getTotalProp()
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end
    self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(self._strengthenEffectShow)
    self._strengthenEffectShow:setPosition(ccp(0, 100))
    self._strengthenEffectShow:playAnimation(ccbFile, function(ccbOwner)
    	ccbOwner.node_red:setVisible(true)
    	ccbOwner.node_green:setVisible(false)
        ccbOwner.tf_title2:setString("卸下暗器成功")
        for i=5,8 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local function addPropText(name,value)
            if index > 4 then return end
            value = value or 0
            if value > 0 then
                ccbOwner["node_"..(index+4)]:setVisible(true)
                trace(index+4,"wk")
                ccbOwner["tf_name"..(index+4)]:setString(name.."－"..value)
                index = index + 1
            end
        end
        local attack_value = (prop.attack_value or 0)*((prop.attack_percent or 0) + 1)
        local hp_value = (prop.hp_value or 0)*((prop.hp_percent or 0) + 1)
        local armor_physical = (prop.armor_physical or 0)*((prop.armor_physical_percent or 0) + 1)
        local armor_magic = (prop.armor_magic or 0)*((prop.armor_magic_percent or 0) + 1)
        addPropText("攻击", math.floor(attack_value))
        addPropText("生命", math.floor(hp_value))
        addPropText("物理防御", math.floor(armor_physical))
        addPropText("法术防御", math.floor(armor_magic))
        end, function()
            if self._strengthenEffectShow ~= nil then
                self._strengthenEffectShow:disappear()
                self._strengthenEffectShow = nil
            end
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end)    
end

--穿装备事件
function QUIDialogHeroMountDetail:mountWearHandler(event)
    app.sound:playSound("sound_num")

    local effect = QUIWidgetAnimationPlayer.new()
    effect:setPosition(ccp(2,-5))
    self._ccbOwner.node_mount_box:addChild(effect)
    effect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._mountBox:runAction(CCSequence:create(arr))

    self:mountWearAni(event.mountId)
end

--穿装备事件
function QUIDialogHeroMountDetail:mountWearMountHandler(event)
    app.sound:playSound("sound_num")
    
    local effect = QUIWidgetAnimationPlayer.new()
    effect:setPosition(ccp(2,-5))
    self._ccbOwner.node_dress_mount_box:addChild(effect)
    effect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
    
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
    arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
    arr:addObject(CCScaleTo:create(0.1,1,1))
    self._wearMountBox:runAction(CCSequence:create(arr))

    self:mountWearAni(event.mountId)
end

function QUIDialogHeroMountDetail:mountWearAni(mountId)
    local mountProp = remote.mount:getMountPropById(mountId)
    local prop = mountProp:getTotalProp()
    local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end

    self:enableTouchSwallowTop()
    self._strengthenEffectShow = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(self._strengthenEffectShow)
    self._strengthenEffectShow:setPosition(ccp(0, 100))
    self._strengthenEffectShow:playAnimation(ccbFile, function(ccbOwner)
        ccbOwner.node_green:setVisible(true)
        ccbOwner.node_red:setVisible(false)
        ccbOwner.tf_title1:setString("装备暗器成功")
        for i=1,4 do
            ccbOwner["node_"..i]:setVisible(false)
        end
        local index = 1
        local function addPropText(name,value)
            if index > 4 then return end
            value = value or 0
            if value > 0 then
                ccbOwner["node_"..index]:setVisible(true)
                ccbOwner["tf_name"..index]:setString(name.."＋"..value)
                index = index + 1
            end
        end
        local attack_value = (prop.attack_value or 0)*((prop.attack_percent or 0) + 1)
        local hp_value = (prop.hp_value or 0)*((prop.hp_percent or 0) + 1)
        local armor_physical = (prop.armor_physical or 0)*((prop.armor_physical_percent or 0) + 1)
        local armor_magic = (prop.armor_magic or 0)*((prop.armor_magic_percent or 0) + 1)
        addPropText("攻击", math.floor(attack_value))
        addPropText("生命",  math.floor(hp_value))
        addPropText("物理防御",  math.floor(armor_physical))
        addPropText("法术防御",  math.floor(armor_magic))
        end, function()
            if self._strengthenEffectShow ~= nil then
                self._strengthenEffectShow:disappear()
                self._strengthenEffectShow = nil
            end
            self:disableTouchSwallowTop()
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end)    
end


--选中强化
function QUIDialogHeroMountDetail:selectedTabLevel()
	if self._strengthWidget == nil then
		self._strengthWidget = QUIWidgetMountInfoStrength.new({parent = self})
		self._ccbOwner.node_right:addChild(self._strengthWidget)
	end
	self._strengthWidget:setInfo(self._actorId)
	self._infoWidget = self._strengthWidget
end

--选中进阶
function QUIDialogHeroMountDetail:selectedTabGrade()
	if self._gradeWidget == nil then
		self._gradeWidget = QUIWidgetMountInfoGrade.new()
		self._ccbOwner.node_right:addChild(self._gradeWidget)
	end
	self._gradeWidget:setInfo(self._actorId)
	self._infoWidget = self._gradeWidget
end

--选中详细
function QUIDialogHeroMountDetail:selectedTabDetail()
	if self._detailWidget == nil then
		self._detailWidget = QUIWidgetMountInfoDetail.new()
		self._ccbOwner.node_right:addChild(self._detailWidget)
	end
	self._detailWidget:setInfo(self._actorId, self._showSSMountEffect)
	if self._showSSMountEffect and self:checkCunrrentMountIsSS(self._actorId) then
    	self._showSSMountEffect = false
	end
	self._detailWidget:setButtonVisible(true)
	self._infoWidget = self._detailWidget
end

--选中天赋
function QUIDialogHeroMountDetail:selectedTabTalent()
    if self._talentWidget == nil then
        self._talentWidget = QUIWidgetMountInfoTalent.new()
        self._ccbOwner.node_right:addChild(self._talentWidget)
    end
	self._talentWidget:setInfo(self._actorId, self._showSSMountEffect)
	if self._showSSMountEffect and self:checkCunrrentMountIsSS(self._actorId) then
    	self._showSSMountEffect = false
	end
    self._infoWidget = self._talentWidget
end

--选中雕刻
function QUIDialogHeroMountDetail:selectedTabMarble( )
    if self._marbleWidget == nil then
        self._marbleWidget = QUIWidgetMountInfoGrave.new({parent = self})
        self._ccbOwner.node_right:addChild(self._marbleWidget)
    end
	self._marbleWidget:setInfo(self._actorId)
    self._infoWidget = self._marbleWidget
end
--选中进阶
function QUIDialogHeroMountDetail:selectedTabChange()
    if self._changeWidget == nil then
        self._changeWidget = QUIWidgetMountInfoChange.new()
        self._ccbOwner.node_right:addChild(self._changeWidget)
    end
    self._changeWidget:setInfo(self._actorId)
    self._infoWidget = self._changeWidget
end

function QUIDialogHeroMountDetail:mountClickHandler(event)
    app.sound:playSound("common_item")
    local lockConfig = app.unlock:getConfigByKey("UNLOCK_ZUOQI")
    if lockConfig.hero_level > self._hero.level then
        app.tip:floatTip("魂师大人，魂师达到"..lockConfig.hero_level.."级后才能装备暗器")
        return
    end
    if event.mountId == nil then
    	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {actorId = self._hero.actorId, isSelect = true}})
    end
end

function QUIDialogHeroMountDetail:wearMountClickHandler(event)
	local mountInfo = remote.mount:getMountById(self._heroInfo.zuoqi.zuoqiId)
    local wearZuoqiInfo = mountInfo.wearZuoqiInfo
    if wearZuoqiInfo then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountInformation", 
        	options={mountId = wearZuoqiInfo.zuoqiId, isDressView = true}})
    else
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {mountId = self._heroInfo.zuoqi.zuoqiId}})
    end
end

function QUIDialogHeroMountDetail:onEvent(event)
	if event.name == remote.HERO_UPDATE_EVENT then
		self:setInfo(self._heros[self._pos])
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:_refreshBatlleForce()
	end
end

function QUIDialogHeroMountDetail:_refreshBatlleForce()
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

function QUIDialogHeroMountDetail:checkCunrrentMountIsSS(actorId)
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    if heroInfo and heroInfo.zuoqi then
	    local mountId = heroInfo.zuoqi.zuoqiId
	    if remote.mount:checkMountIsSS(mountId) then
	    	return true
	    end
	end

    return false
end

function QUIDialogHeroMountDetail:_onTriggerTabTalent()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroMountDetail.TAB_TALENT)
end

function QUIDialogHeroMountDetail:_onTriggerTabChange()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroMountDetail.TAB_CHANGE)
end

function QUIDialogHeroMountDetail:_onTriggerTabStrength()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroMountDetail.TAB_STRONG)
end

function QUIDialogHeroMountDetail:_onTriggerTabGrade()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroMountDetail.TAB_GRADE)
end

function QUIDialogHeroMountDetail:_onTriggerTabDetail()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroMountDetail.TAB_DETAIL)
end

function QUIDialogHeroMountDetail:_onTriggerTabMarble()
	app.sound:playSound("common_menu")
	self:selectTab(QUIDialogHeroMountDetail.TAB_MARBLE)
end

function QUIDialogHeroMountDetail:_onTriggerMaster()
	app.sound:playSound("common_menu")

	local mountInfo = remote.herosUtil:getHeroByID(self._actorId).zuoqi
	if self._currentTab == QUIDialogHeroMountDetail.TAB_STRONG then
		local talents = remote.mount:getMountStrengthMaster(mountInfo.zuoqiId)
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
	        options = {talents = talents,compareLevel = mountInfo.enhanceLevel}})
	elseif self._currentTab == QUIDialogHeroMountDetail.TAB_MARBLE then

		local dbTalents = remote.mount:getMountGraveMaster(mountInfo.zuoqiId) or {}
	    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
	        options = {talents = dbTalents,compareLevel = mountInfo.grave_level,title = "雕刻法阵"}})		
	end
end

function QUIDialogHeroMountDetail:_onTriggerLeft()
    app.sound:playSound("common_change")
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        self._oldBattleForce = 0
        local options = self:getOptions()
        options.pos = self._pos
        if options.parentOptions ~= nil then
        	options.parentOptions.pos = options.pos
        end
		self:setInfo(self._heros[self._pos])
	end
end

function QUIDialogHeroMountDetail:_onTriggerRight()
    app.sound:playSound("common_change")
    local n = table.nums(self._heros)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        self._oldBattleForce = 0
        local options = self:getOptions()
        options.pos = self._pos
        if options.parentOptions ~= nil then
        	options.parentOptions.pos = options.pos
        end
		self:setInfo(self._heros[self._pos])
	end
end

function QUIDialogHeroMountDetail:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogHeroMountDetail:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogHeroMountDetail:_onTriggerBack(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogHeroMountDetail:_onTriggerHome(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogHeroMountDetail