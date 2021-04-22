local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountInformation = class("QUIDialogMountInformation", QUIDialog)
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
local QUIDialogHeroOverview = import("..dialogs.QUIDialogHeroOverview")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIDialogMountInformation.TAB_DETAIL = "TAB_DETAIL"
QUIDialogMountInformation.TAB_STRONG = "TAB_STRONG"
QUIDialogMountInformation.TAB_GRADE = "TAB_GRADE"
QUIDialogMountInformation.TAB_CHANGE = "TAB_CHANGE"
QUIDialogMountInformation.TAB_TALENT = "TAB_TALENT"
QUIDialogMountInformation.TAB_MARBLE = "TAB_MARBLE"

-- 暗器装备魂师
function QUIDialogMountInformation:ctor(options)
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
        {ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
		{ccbCallbackName = "onTriggerDressingMount", callback = handler(self, self._onTriggerDressingMount)},
        {ccbCallbackName = "onTriggerTabMarble", callback = handler(self, self._onTriggerTabMarble)},
	}
	QUIDialogMountInformation.super.ctor(self, ccbFile, callBacks, options)
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


    setShadow5(self._ccbOwner.tf_force)
    self._ccbOwner.frame_tf_title:setString("暗  器")

	self._mountId = options.mountId or 0
	self._tab = options.tab or QUIDialogMountInformation.TAB_DETAIL
    self._isDressView = options.isDressView
    self._oldTab = self._tab
	self._mountList = {}
	self._oldBattleForce = 0
	self._textUpdate = QTextFiledScrollUtils.new()

    if remote.mount:checkMountIsSS(self._mountId) then
        self._showSSMountEffect = true
    end
end

function QUIDialogMountInformation:viewDidAppear()
	QUIDialogMountInformation.super.viewDidAppear(self)

    self._mountProxy = cc.EventProxy.new(remote.mount)
    self._mountProxy:addEventListener(remote.mount.EVENT_WEAR, handler(self, self.mountWearHandler))
    self._mountProxy:addEventListener(remote.mount.EVENT_UNWEAR, handler(self, self.mountUnwearHandler))
    self._mountProxy:addEventListener(remote.mount.EVENT_WEAR_MOUNT, handler(self, self.mountWearMountHandler))
    self._mountProxy:addEventListener(remote.mount.EVENT_UNWEAR_MOUNT, handler(self, self.mountUnwearMountHandler))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(remote.HERO_UPDATE_EVENT, handler(self, self.onEvent))
	self._heroProxy = cc.EventProxy.new(remote.herosUtil)
	self._heroProxy:addEventListener(remote.herosUtil.EVENT_REFESH_BATTLE_FORCE, handler(self, self.onEvent))

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.onHeroSelected, self)

	self:addBackEvent()

	self:getMountList()

	self:updateMountInfo()
end

function QUIDialogMountInformation:viewWillDisappear()
	QUIDialogMountInformation.super.viewWillDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogHeroOverview.SELECT_CLICK, self.onHeroSelected, self)

	self._mountProxy:removeAllEventListeners()
	self._remoteProxy:removeAllEventListeners()
	self._heroProxy:removeAllEventListeners()
	self:removeBackEvent()

	if self._textUpdate ~= nil then
		self._textUpdate:stopUpdate()
		self._textUpdate = nil
	end
end

function QUIDialogMountInformation:getMountList()
    local mountList = remote.mount:getMountList()
    for _, value in pairs(mountList) do
        self._mountList[#self._mountList+1] = value
    end

    table.sort(self._mountList, function (a, b)
        if a.aptitude ~= b.aptitude then
            return a.aptitude > b.aptitude
        elseif a.grade ~= b.grade then
            return a.grade > b.grade
        elseif a.enhanceLevel ~= b.enhanceLevel then
            return a.enhanceLevel > b.enhanceLevel
        else
            return a.zuoqiId > b.zuoqiId
        end
    end)

    for i, mount in ipairs(self._mountList) do
        if self._mountId == mount.zuoqiId then
            self._mountIndex = i
            break
        end
    end
    self._ccbOwner.node_arrow_left:setVisible(#self._mountList > 1) 
    self._ccbOwner.node_arrow_right:setVisible(#self._mountList > 1) 

    -- 暗器
	if self._mountBox == nil then
	    self._mountBox = QUIWidgetMountBox.new()
	    self._mountBox:showRedTips(false)
        self._ccbOwner.node_mount_box:addChild(self._mountBox)
	    self._ccbOwner.node_mount_box:setScale(1.2)
	end
end

function QUIDialogMountInformation:updateMountInfo()
	self._mountInfo = remote.mount:getMountById(self._mountId)
    self._mountBox:setMountInfo(self._mountInfo)
	self._actorId = self._mountInfo.actorId or 0

    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.node_dress_mount_box:removeAllChildren()
    self._ccbOwner.node_dressing:setVisible(false)
    self._ccbOwner.node_marble:setVisible(false)
    self._wearMountBox = nil
    
    -- 是否有配件
    local isNoTalent = false
    if remote.mount:getIsSuperMount(self._mountId) then
        self._ccbOwner.node_normal_mount:setVisible(false)
        self._ccbOwner.node_super_mount:setVisible(true)
        self._ccbOwner.node_mount_box:setPositionX(-40)
        self._ccbOwner.node_talent:setVisible(true)
        self._ccbOwner.node_change:setVisible(true)

        self._wearMountBox = QUIWidgetMountBox.new()
        self._wearMountBox:addEventListener(self._wearMountBox.MOUNT_EVENT_CLICK, handler(self, self.wearMountClickHandler))
        self._wearMountBox:showRedTips(false)
        self._ccbOwner.node_dress_mount_box:addChild(self._wearMountBox)

        if self._mountInfo.wearZuoqiInfo then
            self._wearMountBox:setMountInfo(self._mountInfo.wearZuoqiInfo)
        else
            self._wearMountBox:setNoDressTips()
            if self._actorId ~= 0 then
                self._wearMountBox:showRedTips(remote.mount:checkNoEquipMountS())
            end
        end
        if remote.mount:getIsSSRMount(self._mountId) then
            self._ccbOwner.node_marble:setVisible(true)
        end

    else
        self._ccbOwner.node_normal_mount:setVisible(true)
        self._ccbOwner.node_super_mount:setVisible(false)
        self._ccbOwner.node_mount_box:setPositionX(20)
        self._ccbOwner.node_talent:setVisible(false)
        self._ccbOwner.node_change:setVisible(false)

        local superZuoqiId = self._mountInfo.superZuoqiId or 0
        if superZuoqiId ~= 0 then
            local characher = db:getCharacterByID(superZuoqiId)
            self._ccbOwner.tf_dressing_tips:setString(string.format("当前暗器佩戴在%s上", characher.name))
            self._ccbOwner.node_dressing:setVisible(true)
        end

        isNoTalent = true
    end

	if ((self._tab == QUIDialogMountInformation.TAB_CHANGE or self._tab == QUIDialogMountInformation.TAB_TALENT) and isNoTalent)
        or (self._tab == QUIDialogMountInformation.TAB_MARBLE and not remote.mount:getIsSSRMount(self._mountId)) then
        self._tab = QUIDialogMountInformation.TAB_DETAIL
    end
    self:initHero()
    self:selectTab()
    self:checkRedTips()
end

function QUIDialogMountInformation:initNoHero()
    self._ccbOwner.tf_name:setString("")
    self._ccbOwner.tf_level:setString("")
    self._ccbOwner.node_force:setVisible(false)
    self._ccbOwner.node_back:setVisible(true)

    local characher = db:getCharacterByID(self._mountId)
    if characher.zuoqi_pj then
        self._ccbOwner.tf_equip_tips:setString("配件暗器无法装备")
        self._ccbOwner.node_add_icon:setVisible(false)
        self._ccbOwner.btn_avatar:setVisible(false)
    else
        self._ccbOwner.tf_equip_tips:setString("尚未装备")
        self._ccbOwner.node_add_icon:setVisible(true)
        self._ccbOwner.btn_avatar:setVisible(true)
    end

end

--初始化装备这块和头像
function QUIDialogMountInformation:initHero()
    local actorId = self._actorId
    local superZuoqiId = self._mountInfo.superZuoqiId or 0

    if actorId == 0 and superZuoqiId ~= 0 then
        local mountInfo = remote.mount:getMountById(superZuoqiId)
        actorId = mountInfo.actorId or 0
    end
    
    self:updateMasterLevel()

    if actorId == 0 then
        self:initNoHero()
        return
    end

    self._ccbOwner.node_back:setVisible(false)
	self._heroInfo = clone(remote.herosUtil:getHeroByID(actorId))
	local characher = db:getCharacterByID(actorId)
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
end

function QUIDialogMountInformation:updateMasterLevel()
    
    self._ccbOwner.master_level:setString("LV.0")
    if self._tab == QUIDialogMountInformation.TAB_STRONG then
        local mountConfig = db:getCharacterByID(self._mountInfo.zuoqiId)
        local talents = db:getMountMasterInfo(mountConfig.aptitude) or {}
        for i, talent in pairs(talents) do
            if talent.condition <= self._mountInfo.enhanceLevel then
                self._ccbOwner.master_level:setString("LV."..talent.level)
            end
        end
    elseif self._tab == QUIDialogMountInformation.TAB_MARBLE then
        local talents = remote.mount:getMountGraveMaster(self._mountInfo.zuoqiId)
        for i, talent in pairs(talents) do
            if talent.condition <= (self._mountInfo.grave_level or 0) then
                self._ccbOwner.master_level:setString("LV."..talent.level)
            end
        end  
    end
end

function QUIDialogMountInformation:setBattleForceText(battleForce)
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


function QUIDialogMountInformation:checkRedTips()
	self._ccbOwner.sp_change_tip:setVisible(false)
    self._ccbOwner.sp_marble_tip:setVisible(false)
    if self._mountInfo.actorId > 0 then
		local UIHeroModel = remote.herosUtil:getUIHeroByID(self._mountInfo.actorId)
		self._ccbOwner.sp_change_tip:setVisible(UIHeroModel:getMountReformTip())
    elseif self._mountInfo.superZuoqiId and self._mountInfo.superZuoqiId > 0 then
	end
    self._ccbOwner.sp_grade_tip:setVisible(remote.mount:checkMountCanGrade(self._mountInfo))
    self._ccbOwner.sp_marble_tip:setVisible(remote.mount:checkCanGrave(self._mountInfo.zuoqiId))
end

function QUIDialogMountInformation:removeAllTabState()
    self._ccbOwner.node_master:setVisible(false)
    self._ccbOwner.sp_detail_tip:setVisible(false)
    self._ccbOwner.sp_level_tip:setVisible(false)
    self._ccbOwner.sp_talent_tip:setVisible(false)
end

function QUIDialogMountInformation:selectTab()
	self:getOptions().tab = self._tab
	self:removeAllTabState()

    if remote.mount:checkMountIsSS(self._mountId) then
        self._showSSMountEffect = true
    end

	if self._infoWidget ~= nil then
		self._infoWidget:setVisible(false)
		self._infoWidget = nil
	end
	if self._tab == QUIDialogMountInformation.TAB_DETAIL then
        self._ccbOwner.frame_tf_title:setString("暗器详情")
        self._tabManager:selected(self._ccbOwner.tab_detail)
        -- self._ccbOwner.sp_detail_tip:setPositionX(40)
        self:selectedTabDetail()
    elseif self._tab == QUIDialogMountInformation.TAB_STRONG then
        self._ccbOwner.frame_tf_title:setString("暗器精炼")
        self._ccbOwner.node_master:setVisible(true)
        self:updateMasterLevel()
        self._tabManager:selected(self._ccbOwner.tab_level)
        -- self._ccbOwner.sp_level_tip:setPositionX(40)
        self:selectedTabLevel()
    elseif self._tab == QUIDialogMountInformation.TAB_GRADE then
        self._ccbOwner.frame_tf_title:setString("暗器升星")
        self._tabManager:selected(self._ccbOwner.tab_grade)
        -- self._ccbOwner.sp_grade_tip:setPositionX(40)
        self:selectedTabGrade()
    elseif self._tab == QUIDialogMountInformation.TAB_CHANGE then
        self._ccbOwner.frame_tf_title:setString("暗器改造")
        self._tabManager:selected(self._ccbOwner.tab_change)
        -- self._ccbOwner.sp_change_tip:setPositionX(40)
        self:selectedTabChange()
    elseif self._tab == QUIDialogMountInformation.TAB_TALENT then
        self._ccbOwner.frame_tf_title:setString("暗器配件")
        self._tabManager:selected(self._ccbOwner.tab_talent)
        -- self._ccbOwner.sp_talent_tip:setPositionX(40)
        self:selectedTabTalent()
    elseif self._tab == QUIDialogMountInformation.TAB_MARBLE then
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

--卸载暗器
function QUIDialogMountInformation:mountUnwearHandler(event)
    if self._isDressView then
        self:popSelf()
        return
    end
    local mountId = event.mountId
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
            self:disableTouchSwallowTop()
            if self._strengthenEffectShow ~= nil then
                self._strengthenEffectShow:disappear()
                self._strengthenEffectShow = nil
            end
            remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end)    
end

--卸载暗器
function QUIDialogMountInformation:mountUnwearMountHandler(event)
    self:mountUnwearHandler(event) 
end

--穿装备事件
function QUIDialogMountInformation:mountWearHandler(event)
    app.sound:playSound("sound_num")

    local effect = QUIWidgetAnimationPlayer.new()
    effect:setPosition(ccp(2,-5))
    self._ccbOwner.node_mount_box:addChild(effect)
    effect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
    
    if self._mountBox then
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
        arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
        arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
        arr:addObject(CCScaleTo:create(0.1,1,1))
        self._mountBox:runAction(CCSequence:create(arr))
    end

    self:mountWearAni(event.mountId)
end

--穿装备事件
function QUIDialogMountInformation:mountWearMountHandler(event)
    app.sound:playSound("sound_num")
    
    local effect = QUIWidgetAnimationPlayer.new()
    effect:setPosition(ccp(2,-5))
    self._ccbOwner.node_dress_mount_box:addChild(effect)
    effect:playAnimation("ccb/effects/EquipmentUpgarde.ccbi")
    
    if self._wearMountBox then
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1,1.2,1.2))
        arr:addObject(CCScaleTo:create(0.05,1.4,1.4))
        arr:addObject(CCScaleTo:create(0.05,1.2,1.2))
        arr:addObject(CCScaleTo:create(0.1,1,1))
        self._wearMountBox:runAction(CCSequence:create(arr))
    end

    self:mountWearAni(event.mountId)
end

function QUIDialogMountInformation:mountWearAni(mountId)
    if self._isDressView then
        self:popSelf()
        return
    end
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
        addPropText("生命", math.floor(hp_value))
        addPropText("物理防御", math.floor(armor_physical))
        addPropText("法术防御", math.floor(armor_magic))
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
function QUIDialogMountInformation:selectedTabLevel()
	if self._strengthWidget == nil then
		self._strengthWidget = QUIWidgetMountInfoStrength.new({parent = self})
		self._ccbOwner.node_right:addChild(self._strengthWidget)
	end
	self._strengthWidget:setMountId(self._mountId)
	self._infoWidget = self._strengthWidget
end

--选中进阶
function QUIDialogMountInformation:selectedTabChange()
    if self._changeWidget == nil then
        self._changeWidget = QUIWidgetMountInfoChange.new()
        self._ccbOwner.node_right:addChild(self._changeWidget)
    end
    self._changeWidget:setMountId(self._mountId)
    self._infoWidget = self._changeWidget
end

--选中进阶
function QUIDialogMountInformation:selectedTabGrade()
	if self._gradeWidget == nil then
		self._gradeWidget = QUIWidgetMountInfoGrade.new()
		self._ccbOwner.node_right:addChild(self._gradeWidget)
	end
	self._gradeWidget:setMountId(self._mountId)
	self._infoWidget = self._gradeWidget
end

--选中详细
function QUIDialogMountInformation:selectedTabDetail()
	if self._detailWidget == nil then
		self._detailWidget = QUIWidgetMountInfoDetail.new()
		self._ccbOwner.node_right:addChild(self._detailWidget)
	end
	self._detailWidget:setMountId(self._mountId, self._showSSMountEffect)
    if self._showSSMountEffect and remote.mount:checkMountIsSS(self._mountId) then
        self._showSSMountEffect = false
    end
	self._infoWidget = self._detailWidget
end

--选中天赋
function QUIDialogMountInformation:selectedTabTalent()
    if self._talentWidget == nil then
        self._talentWidget = QUIWidgetMountInfoTalent.new()
        self._ccbOwner.node_right:addChild(self._talentWidget)
    end
    self._talentWidget:setMountId(self._mountId, self._showSSMountEffect)
    if remote.mount:checkMountIsSS(self._mountId) then
        self._showSSMountEffect = true
    end
    self._infoWidget = self._talentWidget
end

--选中雕刻
function QUIDialogMountInformation:selectedTabMarble( )
    if self._marbleWidget == nil then
        self._marbleWidget = QUIWidgetMountInfoGrave.new({parent = self})
        self._ccbOwner.node_right:addChild(self._marbleWidget)
    end
    self._marbleWidget:setMountId(self._mountId)
    self._infoWidget = self._marbleWidget
end

function QUIDialogMountInformation:onHeroSelected(event)
	local actorId = event.actorId
    local mountId = self._mountId
    if actorId then
        remote.mount:mountWareRequest(mountId, actorId, function ()
            remote.mount:dispatchEvent({name = remote.mount.EVENT_WEAR, mountId = mountId})
        end)
    end
end

function QUIDialogMountInformation:wearMountClickHandler(event)
    local wearZuoqiInfo = self._mountInfo.wearZuoqiInfo
    if wearZuoqiInfo then
        local nextIndex = self._mountIndex + 1
        for i, v in pairs(self._mountList) do
            if v.zuoqiId == wearZuoqiInfo.zuoqiId then
                nextIndex = i
                break
            end
        end
        self._mountId = self._mountList[nextIndex].zuoqiId
        self._mountIndex = nextIndex
        self:getOptions().mountId = self._mountId

        self:updateMountInfo()
        self:updateBattleForce()
    else
        local mountId = self._mountId
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {mountId = mountId}})
    end
end

function QUIDialogMountInformation:onEvent(event)
	if event.name == remote.HERO_UPDATE_EVENT then
		self:updateMountInfo()
	elseif event.name == remote.herosUtil.EVENT_REFESH_BATTLE_FORCE then
		self:updateBattleForce()
	end
end

function QUIDialogMountInformation:updateBattleForce()
	if self._oldBattleForce == nil or self._oldBattleForce == 0 then return end
    if self._actorId == 0 then return end

	local heroProp = remote.herosUtil:createHeroPropById(self._actorId)
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
            if ccbOwner and ccbOwner.content then
                if forceChange < 0 then
                  ccbOwner.content:setString(" -" .. math.abs(forceChange))
                else
                  ccbOwner.content:setString(" +" .. math.abs(forceChange))
                end
            end
        end)
    end
end 

function QUIDialogMountInformation:_onTriggerTabTalent()
    if self._tab == QUIDialogMountInformation.TAB_TALENT then
        return
    end
    app.sound:playSound("common_menu")

    self._oldTab = self._tab
    self._tab = QUIDialogMountInformation.TAB_TALENT
    self:selectTab()
end

function QUIDialogMountInformation:_onTriggerTabChange()
    if self._tab == QUIDialogMountInformation.TAB_CHANGE then
        return
    end
    app.sound:playSound("common_menu")

    self._oldTab = self._tab
    self._tab = QUIDialogMountInformation.TAB_CHANGE
    self:selectTab()
end

function QUIDialogMountInformation:_onTriggerTabStrength()
    if self._tab == QUIDialogMountInformation.TAB_STRONG then
        return
    end
    app.sound:playSound("common_menu")

    self._oldTab = self._tab
    self._tab = QUIDialogMountInformation.TAB_STRONG
	self:selectTab()
end

function QUIDialogMountInformation:_onTriggerTabGrade()
    if self._tab == QUIDialogMountInformation.TAB_GRADE then
        return
    end
	app.sound:playSound("common_menu")

    self._oldTab = self._tab
    self._tab = QUIDialogMountInformation.TAB_GRADE
	self:selectTab()
end

function QUIDialogMountInformation:_onTriggerTabDetail()
    if self._tab == QUIDialogMountInformation.TAB_DETAIL then
        return
    end
	app.sound:playSound("common_menu")
    self._oldTab = self._tab
    self._tab = QUIDialogMountInformation.TAB_DETAIL

	self:selectTab()
end

function QUIDialogMountInformation:_onTriggerTabMarble()
    if self._tab == QUIDialogMountInformation.TAB_MARBLE then
        return
    end
    app.sound:playSound("common_menu")
    self._oldTab = self._tab
    self._tab = QUIDialogMountInformation.TAB_MARBLE

    self:selectTab()

end

function QUIDialogMountInformation:_onTriggerMaster(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_master) == false then return end
	app.sound:playSound("common_menu")

    if self._tab == QUIDialogMountInformation.TAB_STRONG then 
        local talents = remote.mount:getMountStrengthMaster(self._mountInfo.zuoqiId)

        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
            options = {talents = talents,compareLevel = self._mountInfo.enhanceLevel}})
    elseif self._tab == QUIDialogMountInformation.TAB_MARBLE then 
        local dbTalents = remote.mount:getMountGraveMaster(self._mountInfo.zuoqiId) or {}
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountTalent", 
            options = {talents = dbTalents,compareLevel = self._mountInfo.grave_level,title = "雕刻法阵"}})           
    end
end

function QUIDialogMountInformation:stopActionAndEffect()
    if self._textUpdate then
        self._textUpdate:stopUpdate()
    end
    if self._strengthenEffectShow ~= nil then
        self._strengthenEffectShow:disappear()
        self._strengthenEffectShow = nil
    end
    if self._gemstoneHandler ~= nil then
        self:getScheduler().unscheduleGlobal(self._gemstoneHandler)
        self._gemstoneHandler = nil
    end
end

function QUIDialogMountInformation:_onTriggerLeft()
    app.sound:playSound("common_change")

    self:stopActionAndEffect()

    local nextIndex = self._mountIndex - 1
    nextIndex = nextIndex <= 0 and #self._mountList or nextIndex
    self._mountId = self._mountList[nextIndex].zuoqiId
    self._mountIndex = nextIndex
    self:getOptions().mountId = self._mountId
   
    self:updateMountInfo()
    self:updateBattleForce()
end

function QUIDialogMountInformation:_onTriggerRight()
    app.sound:playSound("common_change")
    
    self:stopActionAndEffect()

    local nextIndex = self._mountIndex + 1
    nextIndex = nextIndex > #self._mountList and 1 or nextIndex
    self._mountId = self._mountList[nextIndex].zuoqiId
    self._mountIndex = nextIndex
    self:getOptions().mountId = self._mountId

    self:updateMountInfo()
    self:updateBattleForce()
end

function QUIDialogMountInformation:_onTriggerAvatar()
    app.sound:playSound("common_small")

    local lockConfig = app.unlock:getConfigByKey("UNLOCK_ZUOQI") or {}
    local mountLevel = lockConfig.hero_level or 0
    local heros = remote.herosUtil:getHaveHero(mountLevel)
    if #heros <= 0 then
        app.tip:floatTip("魂师大人，只有魂师达到"..mountLevel.."级或更高后才能使用暗器哦~")
    else
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview", options = {mountEquip = true}}, {isPopCurrentDialog = false})
    end
end

function QUIDialogMountInformation:_onTriggerDressingMount(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_dressing_mount) == false then return end
    app.sound:playSound("common_small")

    self:stopActionAndEffect()

    local superZuoqiId = self._mountInfo.superZuoqiId or 0
    local nextIndex = self._mountIndex + 1
    for i, v in pairs(self._mountList) do
        if v.zuoqiId == superZuoqiId then
            nextIndex = i
            break
        end
    end
    self._mountId = self._mountList[nextIndex].zuoqiId
    self._mountIndex = nextIndex
    self:getOptions().mountId = self._mountId

    self:updateMountInfo()
    self:updateBattleForce()
end

function QUIDialogMountInformation:onTriggerBackHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerBack()
end

function QUIDialogMountInformation:onTriggerHomeHandler(tag)
	if self._topTouchLayer ~= nil then return end
	self:_onTriggerHome()
end
 
-- 对话框退出
function QUIDialogMountInformation:_onTriggerBack(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 对话框退出
function QUIDialogMountInformation:_onTriggerHome(tag, menuItem)
    self:enableTouchSwallowTop()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogMountInformation