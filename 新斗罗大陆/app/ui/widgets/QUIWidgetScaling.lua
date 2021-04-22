
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetScaling = class("QUIWidgetScaling", QUIWidget)

local QRemote = import("...models.QRemote")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIWidgetScaling:ctor(options)
	local ccbFile = "ccb/Widget_scaling.ccbi"
    self._type = 1
    if display.width / display.height == 4 / 3 then
        self._type = 2
        ccbFile = "ccb/Widget_scaling_ipad.ccbi"
    end
	local callbacks = {
        {ccbCallbackName = "onTriggerOffSideMenu", callback = handler(self, self._onTriggerOffSideMenu)},
        {ccbCallbackName = "onButtondownSideMenuAchieve", callback = handler(self, self._onButtondownSideMenuAchieve)},
        {ccbCallbackName = "onButtondownSideMenuHero", callback = handler(self, self._onButtondownSideMenuHero)},
        {ccbCallbackName = "onButtondownSideMenuMount", callback = handler(self, self._onButtondownSideMenuMount)},
        {ccbCallbackName = "onButtondownSideMenuSoulSpirit", callback = handler(self, self._onButtondownSideMenuSoulSpirit)},
        {ccbCallbackName = "onButtondownSideMenuBag", callback = handler(self, self._onButtondownSideMenuBag)},
        {ccbCallbackName = "onButtondownSideMenuTask", callback = handler(self, self._onButtondownSideMenuTask)},
        {ccbCallbackName = "onButtondownSideMenuFriend", callback = handler(self, self._onButtondownSideMenuFriend)},
        {ccbCallbackName = "onButtondownSideMenuGodarm", callback = handler(self, self._onButtondownSideMenuGodarm)},
    }
	QUIWidgetScaling.super.ctor(self, ccbFile, callbacks, options)

    self._layer = options.stencil
    self._parent = options.parent

    self._ccbOwner.node_tips_all:setVisible(false)
    self._ccbOwner.node_tips_hero:setVisible(false)
    self._ccbOwner.node_tips_task:setVisible(false)
    self._ccbOwner.node_tips_achieve:setVisible(false)
    self._ccbOwner.node_tips_godarm:setVisible(false)

	-- handle side menu
    self._DisplaySideMenu = false
    self._isSideMenuDoAnimation = false
    self._isShowSoulAni = false
    self._isShowGodarmAni = false

    self._bgSize = self._ccbOwner.bg:getContentSize()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")
    self._layer:setVisible(false)

    self:checkButtons()
    self:checkTips()
    self:checkTutorial()
    self:initShowAni()
end

function QUIWidgetScaling:checkButtons()
    if self._type == 1 then
        self._offsetY = 105
        self._offsetX = 25
        self._height = 180
    else
        self._offsetY = 130
        self._offsetX = 10
        self._height = 220
    end
    -- if not app.unlock:getUnlockMount() then
    --     self._offsetX = 30
    --     self._offsetY = self._offsetY
    -- end
end

function QUIWidgetScaling:initShowAni()
    local function hide(node)
        node:setPositionY(0)
        node:setScaleY(0)
    end
    hide(self._ccbOwner.node_hero)
    hide(self._ccbOwner.node_mount)
    hide(self._ccbOwner.node_soulSpirit)
    hide(self._ccbOwner.node_bag)
    hide(self._ccbOwner.node_godarm)
    hide(self._ccbOwner.node_achieve)
    hide(self._ccbOwner.node_task)
    self._ccbOwner.bg:setScaleY(0)
end

function QUIWidgetScaling:_showAni()
    self:checkButtons()

    local posXs = {-15, -14, -11, -12, -12}
    if self._type == 2 then
        posXs = {-10, -8, -6, -7, -7}
    end
    
    local function showAni(node, posX, posY)
        node:setPositionY(posX)
        node:setPositionY(0)
        node:setScaleY(0)
        local array = CCArray:create()
        array:addObject(CCScaleTo:create(0.01, 1, 1))
        array:addObject(CCMoveTo:create(0.2, ccp(posX, posY-60)))
        array:addObject(CCMoveTo:create(0.1, ccp(posX, posY)))
        local sequence = CCSequence:create(array)
        node:runAction(sequence)
    end

    local offset = self._offsetX
    showAni(self._ccbOwner.node_hero, posXs[1], -offset)

    -- 暗器
    self._ccbOwner.node_mount:setVisible(false)
    if app.unlock:getUnlockMount() then
        offset = offset + self._offsetY
        self._ccbOwner.node_mount:setVisible(true)
        showAni(self._ccbOwner.node_mount, posXs[2], -offset)
    end

    self._ccbOwner.node_soulSpirit:setVisible(false)
    local soulSpiritUnlock = remote.soulSpirit:checkSoulSpiritUnlock()
    if soulSpiritUnlock then
        offset = offset + self._offsetY
        self._ccbOwner.node_soulSpirit:setVisible(true)
        if self._isShowSoulAni then
            self._ccbOwner.node_achieve:setVisible(true)
            showAni(self._ccbOwner.node_achieve, posXs[2], -offset)
            self._ccbOwner.node_soulSpirit:setPosition(ccp(posXs[2], -offset))
            self._ccbOwner.node_soulSpirit:setScale(0)
        else
            self._ccbOwner.node_soulSpirit:setVisible(true)
            showAni(self._ccbOwner.node_soulSpirit, posXs[2], -offset)
        end
    end
    self._ccbOwner.node_godarm:setVisible(false)
    local godArmUnlock = remote.godarm:checkGodArmUnlock()
    if godArmUnlock then
        offset = offset + self._offsetY
        self._ccbOwner.node_godarm:setVisible(true)
        if self._isShowGodarmAni then
            self._ccbOwner.node_bag:setVisible(true)
            showAni(self._ccbOwner.node_task, posXs[2], -offset)
            self._ccbOwner.node_godarm:setPosition(ccp(posXs[2], -offset))
            self._ccbOwner.node_godarm:setScale(0)            
        else
            self._ccbOwner.node_godarm:setVisible(true)
            showAni(self._ccbOwner.node_godarm, posXs[2], -offset)           
        end
    end

    -- 背包
    offset = offset + self._offsetY
    showAni(self._ccbOwner.node_bag, posXs[3], -offset)
    
    -- 成就
    if not soulSpiritUnlock then
        offset = offset + self._offsetY
        showAni(self._ccbOwner.node_achieve, posXs[4], -offset)
    end

    -- 任务
    if not godArmUnlock then    
        offset = offset + self._offsetY
        showAni(self._ccbOwner.node_task, posXs[5], -offset)
    end

    self._ccbOwner.bg:setContentSize(CCSize(self._bgSize.width, self._height + offset))
    self._ccbOwner.bg:setScaleY(0)
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.01))
    array:addObject(CCScaleTo:create(0.2, 1, 1.2))
    array:addObject(CCScaleTo:create(0.1, 1, 1))
    array:addObject(CCCallFunc:create(function()
            self:checkTips()
            self._isSideMenuDoAnimation = false
        end))
    local sequence = CCSequence:create(array)
    self._ccbOwner.bg:runAction(sequence)
end

function QUIWidgetScaling:_hideAni()
    local posX = -12

    local function showAni(node, posY)
        node:setPositionY(posY)
        node:setScaleY(1)
        local array = CCArray:create()
        array:addObject(CCMoveTo:create(0.2, ccp(posX, 0)))
        array:addObject(CCScaleTo:create(0.01, 1, 0))
        local sequence = CCSequence:create(array)
        node:runAction(sequence)
    end

    local offset = self._offsetX
    showAni(self._ccbOwner.node_hero, -offset)

    -- 暗器
    self._ccbOwner.node_mount:setVisible(false)
    if app.unlock:getUnlockMount() then
        offset = offset + self._offsetY
        self._ccbOwner.node_mount:setVisible(true)
        showAni(self._ccbOwner.node_mount, -offset)
    end

    self._ccbOwner.node_soulSpirit:setVisible(false)
    local soulSpiritUnlock = remote.soulSpirit:checkSoulSpiritUnlock()
    if soulSpiritUnlock then
        offset = offset + self._offsetY
        self._ccbOwner.node_soulSpirit:setVisible(true)
        showAni(self._ccbOwner.node_soulSpirit, -offset)
    end

    self._ccbOwner.node_godarm:setVisible(false)
    local godArmUnlock = remote.godarm:checkGodArmUnlock()
    if godArmUnlock then
        offset = offset + self._offsetY
        self._ccbOwner.node_godarm:setVisible(true)
        showAni(self._ccbOwner.node_godarm, -offset)        
    end
    -- 背包
    offset = offset + self._offsetY
    showAni(self._ccbOwner.node_bag, -offset)
    -- 成就
    if not soulSpiritUnlock then
        offset = offset + self._offsetY
        showAni(self._ccbOwner.node_achieve, -offset)
    end
    if not godArmUnlock then
        -- 任务
        offset = offset + self._offsetY
        showAni(self._ccbOwner.node_task, -offset)
    end

    self._ccbOwner.bg:setContentSize(CCSize(self._bgSize.width, self._height + offset))
    self._ccbOwner.bg:setScaleY(1)
    local array = CCArray:create()
    array:addObject(CCScaleTo:create(0.2, 1, 0))
    array:addObject(CCCallFunc:create(function()
            self:checkTips()
            self._isSideMenuDoAnimation = false
        end))
    local sequence = CCSequence:create(array)
    self._ccbOwner.bg:runAction(sequence)
end

function QUIWidgetScaling:checkTips()
    self._ccbOwner.node_tips_all:setVisible(false)
    self._ccbOwner.node_tips_hero:setVisible(false)
    self._ccbOwner.node_tips_mount:setVisible(false)
    self._ccbOwner.node_tips_soulSpirit:setVisible(false)
    self._ccbOwner.node_tips_backpack:setVisible(false)
    self._ccbOwner.node_tips_task:setVisible(false)
    self._ccbOwner.node_tips_achieve:setVisible(false)
    self._ccbOwner.node_tips_godarm:setVisible(false)

    local heroTips = remote.herosUtil:checkAllHerosIsTip()
    local mountTips = remote.mount:checkBackPackTips()
    local soulSpiritTips = remote.soulSpirit:checkBackPackTips()
    local godrmTips = remote.godarm:checkRedTips()
    local backpackTips = false
    -- 当有背包里面有小红点，每天只显示一次
    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.BACKPACK) == true then
        backpackTips = remote.items:checkItemRedTips()
    end
    local taskTips = remote.task:checkAllTask(false)
    local achieveTips = remote.achieve.achieveDone
    local overdue = remote.items:checkOverdueItems()

    if self._DisplaySideMenu then
        self._ccbOwner.node_tips_hero:setVisible(heroTips)
        self._ccbOwner.node_tips_mount:setVisible(mountTips)
        self._ccbOwner.node_tips_soulSpirit:setVisible(soulSpiritTips)
        self._ccbOwner.node_tips_backpack:setVisible(backpackTips)
        self._ccbOwner.node_tips_task:setVisible(taskTips)
        self._ccbOwner.node_tips_achieve:setVisible(achieveTips)
        self._ccbOwner.node_tips_godarm:setVisible(godrmTips)
        self._ccbOwner.node_tips_all:setVisible(false)
        self._ccbOwner.sp_expired:setVisible(overdue)
    else
        local soulSpiritUnlock = remote.soulSpirit:checkSoulSpiritUnlock()
        if soulSpiritUnlock then
            achieveTips = false
        end

        if remote.godarm:checkGodArmUnlock() then
            taskTips = false
        end

        if heroTips or mountTips or soulSpiritTips or backpackTips or taskTips or achieveTips or godrmTips then
            self._ccbOwner.node_tips_all:setVisible(true)
        end
    end
end

function QUIWidgetScaling:checkTutorial()
    if self._ccbOwner.node_tips_all:isVisible() then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
        if page ~= nil and dialog ~= nil and page.class.__cname == "QUIPageMainMenu" and 
            dialog.class.__cname ~= "QUIDialogTeamArrangement" and dialog.class.__cname ~= "QUIDialogDungeon" then
            page:checkGuiad()
        end
    end
end

function QUIWidgetScaling:onEnter()    
    self._layer:setTouchEnabled(true)
    self._layer:setTouchSwallowEnabled(true)
    self._layer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIWidgetScaling._onTouch))
    --数据更新监听
    self._remoteEventProxy = cc.EventProxy.new(remote)
    self._remoteEventProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self._onUserDataUpdate))
    self._remoteEventProxy:addEventListener(QRemote.TASK_UPDATE_EVENT, handler(self, self._onUserDataUpdate))
    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self._onUserDataUpdate))

    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._onUserDataUpdate))

    self._mountEventProxy = cc.EventProxy.new(remote.mount)
    self._mountEventProxy:addEventListener(remote.mount.EVENT_UPDATE, handler(self, self._onUserDataUpdate))

    self._taskEventProxy = cc.EventProxy.new(remote.task)
    self._taskEventProxy:addEventListener(remote.task.EVENT_DONE, handler(self, self._onTaskDone))
    self._taskEventProxy:addEventListener(remote.task.EVENT_TIME_DONE, handler(self, self._onUserDataUpdate))

    self._achieveEventProxy = cc.EventProxy.new(remote.achieve)
    self._achieveEventProxy:addEventListener(remote.achieve.EVENT_STATE_UPDATE, handler(self, self._onUserDataUpdate))
end

function QUIWidgetScaling:onExit()
    if self._remoteEventProxy ~= nil then
        self._remoteEventProxy:removeAllEventListeners()
        self._remoteEventProxy = nil
    end
    if self._mountEventProxy ~= nil then
        self._mountEventProxy:removeAllEventListeners()
        self._mountEventProxy = nil
    end
    if self._taskEventProxy ~= nil then
        self._taskEventProxy:removeAllEventListeners()
        self._taskEventProxy = nil
    end
    if self._achieveEventProxy ~= nil then
        self._achieveEventProxy:removeAllEventListeners()
        self._achieveEventProxy = nil
    end
    if self._itemProxy ~= nil then
        self._itemProxy:removeAllEventListeners()
        self._itemProxy = nil
    end
end

function QUIWidgetScaling:preSoulSpiritAni()
    self._isShowSoulAni = true
end

function QUIWidgetScaling:preGodarmAni()
    self._isShowGodarmAni = true
end

function QUIWidgetScaling:getSoulSpiritNodeWorldPos()
    self._ccbOwner.node_achieve:setVisible(false)
    local soulSpiritWorldPos = self._ccbOwner.node_achieve:convertToWorldSpace(ccp(0, 0))
    return soulSpiritWorldPos
end

function QUIWidgetScaling:getGodarmNodeWorldPos()
    self._ccbOwner.node_task:setVisible(false)
    local soulSpiritWorldPos = self._ccbOwner.node_task:convertToWorldSpace(ccp(0, 0))
    return soulSpiritWorldPos
end

function QUIWidgetScaling:showSoulSpiritAni(callback)
    self._isShowSoulAni = false

    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.3))
    array:addObject(CCScaleTo:create(0.3, 1, 1))
    array:addObject(CCCallFunc:create(callback))
    local sequence = CCSequence:create(array)
    self._ccbOwner.node_soulSpirit:runAction(sequence)
end

function QUIWidgetScaling:showGodarmAni(callback)
    self._isShowGodarmAni = false

    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.3))
    array:addObject(CCScaleTo:create(0.3, 1, 1))
    array:addObject(CCCallFunc:create(callback))
    local sequence = CCSequence:create(array)
    self._ccbOwner.node_godarm:runAction(sequence)
end

function QUIWidgetScaling:_onTouch(event)
    if self._isSideMenuDoAnimation == true then return end
    if event.name == "began" then
        self._layer:setVisible(false)
        self:_onTriggerOffSideMenu()
        return true
    end
end

function QUIWidgetScaling:_onUserDataUpdate(event)
    if self.class ~= nil then 
        self:checkTips()
        self:checkTutorial()
    end
end

function QUIWidgetScaling:_onTaskDone(event)
    if self.class ~= nil then 
        self:checkTips()
    end
end

function QUIWidgetScaling:_onButtondownSideMenuBag( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_bag) == false then return end

    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()

    if app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.BACKPACK) then
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.BACKPACK)
    end

    local packs = {1}
    if app.unlock:getUnlockGemStone() 
        or remote.gemstone:checkGemstoneBackPackItemNum() 
        or remote.spar:checkSparBackPackItemNum() then
        -- 2：魂骨、晶石
        -- table.insert(packs, #packs+1)
        table.insert(packs, 2)
    end
    if remote.soulSpirit:checkSoulSpiritUnlock() or remote.soulSpirit:checkSoulSpiritPackItemNum() then
        -- 3：魂灵
        -- table.insert(packs, #packs+1)
        table.insert(packs, 3)
    end
    
    if remote.godarm:checkGodArmUnlock() or remote.godarm:checkGodArmbBackPackItemNum() then
        table.insert(packs, 4)
    end

    if remote.magicHerb:checkMagicHerbUnlock() or remote.magicHerb:checkMagicHerbBackPackItemNum() then
        -- 4：仙品
        -- table.insert(packs, #packs+1)
        table.insert(packs, 5)
    end
    
    local barNum = #packs
    if barNum > 1 then
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogChooseBackPack", options = {packs = packs}})
    else
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBackpack", options = {packs = packs}})
    end
end

function QUIWidgetScaling:_onButtondownSideMenuAchieve( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_achieve) == false then return end

    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAchievement"})  
end

function QUIWidgetScaling:_onButtondownSideMenuTask( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_task) == false then return end

    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogDailyTask"})
end

function QUIWidgetScaling:_onButtondownSideMenuFriend(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_friend) == false then return end

    app.sound:playSound("common_small")
    if app.unlock:getUnlockFriend(true) == true then
        self._layer:setVisible(false)
        self:willPlayHide()
        return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriend"})
    end
end

function QUIWidgetScaling:_onButtondownSideMenuMount( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_mount) == false then return end

    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMountOverView"})
end

function QUIWidgetScaling:_onButtondownSideMenuSoulSpirit( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_soulSpirit) == false then return end

    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSoulSpiritOverView"})
end

function QUIWidgetScaling:_onButtondownSideMenuHero( event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_hero) == false then return end

    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroOverview"})
end

function QUIWidgetScaling:_onButtondownSideMenuGodarm( event )
    if q.buttonEventShadow(event, self._ccbOwner.btn_godarm) == false then return end
    app.sound:playSound("common_small")
    self._layer:setVisible(false)
    self:willPlayHide()
    return app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmOverView"})
end
function QUIWidgetScaling:_onTriggerOffSideMenu(tag, menuItem)
	if self._isSideMenuDoAnimation == true then
		return
	end
	local animationName = nil
	if self._DisplaySideMenu == true then
		self._DisplaySideMenu = false
		animationName = "side_menu_off"
        self._layer:setVisible(false)
        app.sound:playSound("common_menu_back")
	else
		self._DisplaySideMenu = true
		animationName = "side_menu_on"
        
        self._ccbOwner.node_tips_all:setVisible(false)
        
        --当前界面是dialog且不是下拉条派生出来的则加一层遮罩
        local dlg = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
        if dlg and "UI_TYPE_PAGE" ~= dlg._type and dlg:getLock() == false then
            self._layer:setVisible(true)
        end
        if self._auto and self._auto == true then
            self._isSideMenuDoAnimation = true
        end
        app.sound:playSound("common_menu")
	end
    self:scalingDisplay()
	
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_SAVE_STRENGTHEN_EXP})
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_HERO_EXP_CHECK})
    remote.herosUtil:requestSkillUp()

    self._isSideMenuDoAnimation = true

    if self._parent and self._parent.setLevelGuideStated then
        self._parent:setLevelGuideStated(not self._DisplaySideMenu)
    end
end

function QUIWidgetScaling:getScalingStatus()
    return self._DisplaySideMenu
end

function QUIWidgetScaling:scalingDisplay()
   if self._DisplaySideMenu == true then
        self._ccbOwner.button_scaling_down:setVisible(false)
        self._ccbOwner.button_scaling:setVisible(true)
        self:_showAni()
    else
        self._ccbOwner.button_scaling_down:setVisible(true)
        self._ccbOwner.button_scaling:setVisible(false)
        self:_hideAni()
    end
end

function QUIWidgetScaling:willPlayShow()
    if self._DisplaySideMenu == false then
        self._DisplaySideMenu = true
        self:scalingDisplay()
    end
end

function QUIWidgetScaling:willPlayHide()
    if self._isSideMenuDoAnimation == true then
        return
    end
    if self._DisplaySideMenu == true then
        self._DisplaySideMenu = false
        self:scalingDisplay()
    end
end

function QUIWidgetScaling:getWidth()
	return self:getView():getContentSize().width
end

return QUIWidgetScaling