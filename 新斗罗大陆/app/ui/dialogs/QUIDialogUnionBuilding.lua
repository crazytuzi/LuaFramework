
local QUIDialogBaseUnion = import("..dialogs.QUIDialogBaseUnion")
local QUIDialogUnionBuilding = class("QUIDialogUnionBuilding", QUIDialogBaseUnion)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

local LIGHT_COLOR = {
    COLORS.v,
    ccc3(26, 192, 255),
    ccc3(255, 0, 255),
}

function QUIDialogUnionBuilding:ctor(options)
    local ccbFile = "ccb/Dialog_society_union_guanli.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerNormalFete", callback = handler(self, QUIDialogUnionBuilding._onTriggerNormalFete)},
        {ccbCallbackName = "onTriggerAdvancedFete", callback = handler(self, QUIDialogUnionBuilding._onTriggerAdvancedFete)},
        {ccbCallbackName = "onTriggerSuperbFete", callback = handler(self, QUIDialogUnionBuilding._onTriggerSuperbFete)},
        {ccbCallbackName = "onTriggerFete", callback = handler(self, QUIDialogUnionBuilding._onTriggerFete)},
        {ccbCallbackName = "onTriggerRewardOpen1", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward1)},
        {ccbCallbackName = "onTriggerRewardOpen2", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward2)},
        {ccbCallbackName = "onTriggerRewardOpen3", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward3)},
        {ccbCallbackName = "onTriggerRewardOpen4", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward4)},
        {ccbCallbackName = "onTriggerRewardClose1", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward1)},
        {ccbCallbackName = "onTriggerRewardClose2", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward2)},
        {ccbCallbackName = "onTriggerRewardClose3", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward3)}, 
        {ccbCallbackName = "onTriggerRewardClose4", callback = handler(self, QUIDialogUnionBuilding._onTriggerReward4)},
        {ccbCallbackName = "onTriggerView", callback = handler(self, QUIDialogUnionBuilding._onTriggerView)},
        -- {ccbCallbackName = "onTriggerLevelReward", callback = handler(self, QUIDialogUnionBuilding._onTriggerLevelReward)},
	}
    QUIDialogUnionBuilding.super.ctor(self, ccbFile, callBacks, options) 
    
    CalculateUIBgSize(self._ccbOwner.node_far, 1280)

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")

    self._canFete = true
    for i = 1, 3 do
        self._ccbOwner["node_ball_"..i]:setVisible(false)
        self._ccbOwner["node_builded_"..i]:setVisible(false)
        self._ccbOwner["node_costInfo_"..i]:setVisible(false)
        self._ccbOwner["node_not_builded_"..i]:setVisible(false)
    end
end

function QUIDialogUnionBuilding:_init( options )
    -- body
    self._feteType = 0
    
    self:setInfo()
    self:updateData()
end

function QUIDialogUnionBuilding:updateData(  )
    -- body
    remote.union:unionOpenRequest(function (  )
        -- body
        if self._appear then
            self:setInfo()
        end
    end)
end

function QUIDialogUnionBuilding:viewDidAppear()
    QUIDialogUnionBuilding.super.viewDidAppear(self)
  
end

function QUIDialogUnionBuilding:viewWillDisappear()
    QUIDialogUnionBuilding.super.viewWillDisappear(self)
 
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setUpdateDataByManual(TOP_BAR_TYPE.CONSORTIA_MONEY, nil)
    page.topBar:setDisableTopClick(nil)
    
end

function QUIDialogUnionBuilding:handleUnionInfoUpdate()
    if self:safeCheck() then
        self:setInfo()
    end
end

function QUIDialogUnionBuilding:setInfo()
    local function calculateFeteProgress(allProgress, unionProgress)
        local count = #allProgress
        local proportion = 0
        local lastProgress = 0
        local currentProgress = 0
        for k, v in ipairs(allProgress) do
            currentProgress = (v - lastProgress)
            if unionProgress >= v then
                proportion = proportion + 1/count
            else
                break
            end
            lastProgress = v
        end
        proportion = proportion + (unionProgress - lastProgress)*(1/count)*(1/currentProgress)

        return proportion
    end

    self:_updateFeteBox()
    self:_updateRewards(remote.union.consortia.sacrifice, remote.union.consortia.level)
    self._ccbOwner.fete_button:setVisible(self._feteType ~= 0)

    self._ccbOwner.progressTTF1:setString("建设进度：")
    self._ccbOwner.progressTTF2:setString(remote.union.consortia.sacrifice or 0)
    self._ccbOwner.progressTTF3:setString("建设人数：")
    self._ccbOwner.progressTTF4:setString((remote.union.consortia.sacrificeCount or 0).."/"..(remote.union.consortia.memberCount or 0))

    local progressTable = {}
    for k, v in pairs(db:getSocietyFeteReward(remote.union.consortia.level)) do
        table.insert(progressTable, v.fete_schedule)
    end
    self._feteMask = self:_addFeteMaskLayer(self._ccbOwner.fete_bar, self._ccbOwner.fete_mask)
    self._feteMask:setScaleX(calculateFeteProgress(progressTable, remote.union.consortia.sacrifice))

    local index = 1
    while true do
        local sp = self._ccbOwner["sp_playerRecall_"..index]
        if sp then
            sp:setVisible(remote.playerRecall:isOpen())
            index = index + 1
        else
            break
        end 
    end
end

function QUIDialogUnionBuilding:_updateFeteBox()
    -- Normal fete
    local rate = 1
    if remote.playerRecall:isOpen() then
        rate = rate + remote.playerRecall:getBuffNumByType(4)/100
    end
    for i = 1, 3 do
        local curConfig = db:getSocietyFete(i)
        self._ccbOwner["sp_gold_"..i]:setVisible(curConfig.gold_consumption > 0)
        self._ccbOwner["sp_token_"..i]:setVisible(curConfig.token_consumption > 0)
        self._ccbOwner["tf_cost_"..i]:setString(curConfig.gold_consumption ~= 0 and curConfig.gold_consumption or curConfig.token_consumption)
        self._ccbOwner["tf_progress_"..i]:setString("建设进度+" .. curConfig.schedule_increased)

        local expIncreased = curConfig.exp_increased*rate
        local contributionGain = curConfig.contribution_gain*rate
        self._ccbOwner["tf_exp_"..i]:setString("宗门经验+" .. expIncreased)
        self._ccbOwner["tf_contribute_"..i]:setString("宗门贡献+" .. contributionGain)
    end

    self._ccbOwner.node_month_card:setVisible(false)
    if remote.activity:checkMonthCardActive(1) then
        self._ccbOwner.node_month_card:setVisible(true)
        self._ccbOwner.tf_cost_desc:setString(188)
    end

    if self._canFete then
        self:_updateFeteButton() 
    end
end

function QUIDialogUnionBuilding:_updateFeteButton()
    local feteType = self._feteType
    local sacrificeType = remote.user.userConsortia.daily_sacrifice_type or 0
    for i = 1, 3 do
        self._ccbOwner["node_builded_"..i]:setVisible(sacrificeType == i)
        self._ccbOwner["node_costInfo_"..i]:setVisible(sacrificeType ~= i)
        self._ccbOwner["node_not_builded_"..i]:setVisible(sacrificeType == 0)
        self._ccbOwner["sp_on_"..i]:setVisible(feteType == i)
        self._ccbOwner["sp_off_"..i]:setVisible(feteType ~= i)
        self._ccbOwner["node_ball_"..i]:setVisible(feteType == i)
    end
    if feteType > 0 then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.2, 1.5))
        actionArrayIn:addObject(CCScaleTo:create(0.2, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        self._ccbOwner["sp_on_"..feteType]:runAction(ccsequence)
    end
end

function QUIDialogUnionBuilding:_updateRewards(progress, level)
    local feteConfig = db:getSocietyFeteReward(level)
    for k, v in ipairs(feteConfig) do
        self._ccbOwner["reward" .. k .. "_progress"]:setString(v.fete_schedule)
        self._ccbOwner["node_reward" .. k .. "_open"]:setVisible(remote.user.userConsortia["draw" .. k])
        self._ccbOwner["node_reward" .. k .. "_close"]:setVisible(not remote.user.userConsortia["draw" .. k])
        self._ccbOwner["node_reward" .. k .. "_light"]:setVisible(v.fete_schedule <= progress and not remote.user.userConsortia["draw" .. k])
    end

    -- Update level reward
    local rewardLogStr = remote.user.userConsortia.rewardLog or ""
    local rewardLogs = string.split(rewardLogStr, "#")
    local initLevel = (remote.user.userConsortia.initConsortiaLevel or 0) + 1
    for k, v in ipairs(rewardLogs) do 
        if initLevel == tonumber(v) then
            initLevel = initLevel + 1
        end
    end
end

function QUIDialogUnionBuilding:_addFeteMaskLayer(ccb, mask)
    local width = ccb:getContentSize().width * ccb:getScaleX()
    local height = ccb:getContentSize().height * ccb:getScaleY()
    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0))
    maskLayer:setPosition(ccp(0, 0))

    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccb:setPosition(ccp(0, 0))
    ccclippingNode:addChild(ccb)
    ccb:release()

    mask:addChild(ccclippingNode)
    return maskLayer
end

function QUIDialogUnionBuilding:showSelectAnimation()
    self._animationManager:runAnimationsForSequenceNamed("2")

    local feteType = self._feteType
    for i = 1, 3 do
        self._ccbOwner["node_ball_"..i]:setVisible(feteType == i)
    end
    for i = 1, 8 do
        self._ccbOwner["sp_light_ani_"..i]:setColor(LIGHT_COLOR[feteType])
    end

    self._ccbOwner.fete_button:setVisible(true)
    self._ccbOwner.fete_button:setScale(0)
    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCScaleTo:create(0.2, 1.5))
    actionArrayIn:addObject(CCScaleTo:create(0.2, 1))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._ccbOwner.fete_button:runAction(ccsequence)
end

function QUIDialogUnionBuilding:animationEndHandler(name)
    if name ~= "3" then
        return
    end

    self._isAnimation = false
    self._animationManager:runAnimationsForSequenceNamed("1")

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setUpdateDataByManual(TOP_BAR_TYPE.CONSORTIA_MONEY, nil)
    page.topBar:setDisableTopClick(false)
    page.topBar:manualUpdateConsortiaMoney()
          
    local config = db:getSocietyFete(self._feteType)
    if not config then return end

    local ccbFile2 = "ccb/effects/society_tree_number.ccbi"
    local effectShow = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effectShow)
    effectShow:setPosition(ccp(134, -86))
    effectShow:playAnimation(ccbFile2)
    effectShow._ccbOwner.node_5:setVisible(false)
    if self._feteType == 3 and remote.activity:checkMonthCardActive(1) then
        effectShow._ccbOwner.node_5:setVisible(true)
        effectShow._ccbOwner.number5:setString("钻石节省110")
    end

    effectShow._ccbOwner.txt1:setString("建设成功")
    effectShow._ccbOwner.number1:setString("")
    effectShow._ccbOwner.txt2:setString("建设进度")
    effectShow._ccbOwner.number2:setString("+" .. config.schedule_increased)
    effectShow._ccbOwner.txt3:setString("宗门贡献")
    if remote.playerRecall:isOpen() then
        effectShow._ccbOwner.number3:setString("+" .. (config.contribution_gain * (1 + remote.playerRecall:getBuffNumByType(4)/100)))
    else
        effectShow._ccbOwner.number3:setString("+" .. config.contribution_gain)
    end

    local sacrificeCount = remote.union.consortia.sacrificeCount or 0
    local level = remote.union.consortia.level or 1
    local memberLimit = tonumber(db:getSocietyMemberLimitByLevel(level)) or 1
    if self._oldSacrificeCount == sacrificeCount and sacrificeCount >= memberLimit then
        effectShow._ccbOwner.node_4:setVisible(false)
    else
        effectShow._ccbOwner.txt4:setString("宗门经验")
        if remote.playerRecall:isOpen() then
            effectShow._ccbOwner.number4:setString("+" .. (config.exp_increased * (1 + remote.playerRecall:getBuffNumByType(4)/100)))
        else
            effectShow._ccbOwner.number4:setString("+" .. config.exp_increased)
        end
    end

    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_WIDGET_NAME_UPDATE})

    self._feteType = 0 
    self:_updateFeteButton()
    self:setInfo()
end

function QUIDialogUnionBuilding:showFeteAnimation(  )
    self._animationManager:stopAnimation()
    self._animationManager:runAnimationsForSequenceNamed("3")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
    self._ccbOwner.fete_button:setVisible(false)
    self._ccbOwner.node_fca_ani:removeAllChildren()
    self._isAnimation = true

    local buildAni = QResPath("union_build_ani")[self._feteType]
    if buildAni then
        local fcaAnimation = QUIWidgetFcaAnimation.new(buildAni, "res")
        self._ccbOwner.node_fca_ani:addChild(fcaAnimation)
        --fcaAnimation:setTransformColor(ccc3(0, 255, 255))
        fcaAnimation:playAnimation("animation", false)
        fcaAnimation:setEndCallback(function( )
            fcaAnimation:removeFromParent()
        end)
    end
end

function QUIDialogUnionBuilding:_onTriggerNormalFete()
    if self._isAnimation then
        return
    end
    if remote.user.userConsortia.daily_sacrifice_type and remote.user.userConsortia.daily_sacrifice_type ~= 0 then
        app.tip:floatTip("魂师大人，您今日已经建设过了， 明天记得要来哦! ")
        return
    end
    app.sound:playSound("common_menu")

    self._feteType = 1
    self:_updateFeteButton()
    self:showSelectAnimation()
end

function QUIDialogUnionBuilding:_onTriggerAdvancedFete()
    if self._isAnimation then
        return
    end
    if remote.user.userConsortia.daily_sacrifice_type and remote.user.userConsortia.daily_sacrifice_type ~= 0 then
        app.tip:floatTip("魂师大人，您今日已经建设过了， 明天记得要来哦! ")
        return
    end
    app.sound:playSound("common_menu")

    self._feteType = 2
    self:_updateFeteButton()
    self:showSelectAnimation()
end

function QUIDialogUnionBuilding:_onTriggerSuperbFete()
    if self._isAnimation then
        return
    end
    if remote.user.userConsortia.daily_sacrifice_type and remote.user.userConsortia.daily_sacrifice_type ~= 0 then
        app.tip:floatTip("魂师大人，您今日已经建设过了， 明天记得要来哦! ")
        return
    end
    app.sound:playSound("common_menu")

    self._feteType = 3
    self:_updateFeteButton()
    self:showSelectAnimation()
end

function QUIDialogUnionBuilding:_onTriggerFete(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_fete) == false then return end
    app.sound:playSound("common_small")
  
    if self._feteType == 0 then return end

    local config = db:getSocietyFete(self._feteType)
    if not config then return end

    if config.gold_consumption and config.gold_consumption > 0 then
        if remote.user.money < config.gold_consumption then
            QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
            return
        end
    elseif config.token_consumption and config.token_consumption > 0 then
        local superCost = config.token_consumption
        if self._feteType == 3 and remote.activity:checkMonthCardActive(1) then
            superCost = 188
        end
        if remote.user.token < superCost then
            QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
            return
        end
    end


    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page.topBar:setUpdateDataByManual(TOP_BAR_TYPE.CONSORTIA_MONEY , true)
    page.topBar:setDisableTopClick(true)

    self._oldSacrificeCount = remote.union.consortia.sacrificeCount or 0
    remote.union:unionFeteRequest( self._feteType, false, function (data)
        remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_SACRIFICE)
        remote.user.userConsortia.daily_sacrifice_type = self._feteType
        remote.user.userConsortia.sacrificeCount = remote.user.userConsortia.sacrificeCount + 1
        --xurui: 更新每日建设活跃任务
        remote.union.unionActive:updateActiveTaskProgress(20001, self._feteType, true)
        self:showFeteAnimation()
        
        if self:getOptions().feteCallback then
            self:getOptions().feteCallback()
        end
    end,function (  )
        -- body
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page.topBar:setUpdateDataByManual(TOP_BAR_TYPE.CONSORTIA_MONEY, nil)
        page.topBar:setDisableTopClick(false)

    end )
end

function QUIDialogUnionBuilding:_onTriggerReward1()
    if self._isAnimation then
        return
    end

    app.sound:playSound("common_small")
    if (not remote.user.userConsortia.draw1) and (remote.union.consortia.sacrifice >= db:getSocietyFeteReward(remote.union.consortia.level)[1].fete_schedule) then
        if self._canFete == false then
            app.tip:floatTip("今日无法领取建设奖励，请参与建设后再来领取~")
            return
        end
        remote.union:unionFeteRewardRequest({1}, false,function (data)
            self:_feteRewardCallback(data)
        end)
    else
        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRewardBox",
        --     options = {boxNum = 1, type = 2}},{isPopCurrentDialog = false})
        self:_openUnionRewardBox(1)
    end
end

function QUIDialogUnionBuilding:_onTriggerReward2()
    if self._isAnimation then
        return
    end
    app.sound:playSound("common_small")
    if  (not remote.user.userConsortia.draw2) and (remote.union.consortia.sacrifice >= db:getSocietyFeteReward(remote.union.consortia.level)[2].fete_schedule) then
        if self._canFete == false then
            app.tip:floatTip("今日无法领取建设奖励，请参与建设后再来领取~")
            return
        end

        remote.union:unionFeteRewardRequest({2}, false,function (data)
                self:_feteRewardCallback(data)
            end)
    else
        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRewardBox",
        --     options = {boxNum = 2, type = 2}},{isPopCurrentDialog = false})
        self:_openUnionRewardBox(2)
    end
end

function QUIDialogUnionBuilding:_onTriggerReward3()
    if self._isAnimation then
        return
    end
    app.sound:playSound("common_small")
    if (not remote.user.userConsortia.draw3) and (remote.union.consortia.sacrifice >= db:getSocietyFeteReward(remote.union.consortia.level)[3].fete_schedule) then
        if self._canFete == false then
            app.tip:floatTip("今日无法领取建设奖励，请参与建设后再来领取~")
            return
        end

        remote.union:unionFeteRewardRequest({3}, false,function (data)
            self:_feteRewardCallback(data)
        end)
    else
        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRewardBox",
        --     options = {boxNum = 3, type = 2}},{isPopCurrentDialog = false})
        self:_openUnionRewardBox(3)
    end
end

function QUIDialogUnionBuilding:_onTriggerReward4()
    if self._isAnimation then
        return
    end
    app.sound:playSound("common_small")

    if (not remote.user.userConsortia.draw4) and (remote.union.consortia.sacrifice >= db:getSocietyFeteReward(remote.union.consortia.level)[4].fete_schedule) then
        if self._canFete == false then
            app.tip:floatTip("今日无法领取建设奖励，请参与建设后再来领取~")
            return
        end

        remote.union:unionFeteRewardRequest({4}, false,function (data)
            self:_feteRewardCallback(data)
        end)
    else
        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRewardBox",
        --     options = {boxNum = 4, type = 2}},{isPopCurrentDialog = false})
        self:_openUnionRewardBox(4)
    end
    
end

function QUIDialogUnionBuilding:_openUnionRewardBox(boxNum)
    local tips = "今日建设进度达到"..db:getSocietyFeteReward(remote.union.consortia.level)[boxNum].fete_schedule.."，可获得以下奖励"
    local awards = {}
    local basicAward = db:getSocietyFeteReward(remote.union.consortia.level)[boxNum].basic_award
    local strs = string.split(basicAward, ";")
    for _,str in ipairs(strs) do
        if str ~= nil and str ~= "" then
            local _awards = string.split(str, "^")
            local typeName = remote.items:getItemType(_awards[1])
            local id = nil
            local count = tonumber(_awards[2])
            if typeName == nil then
                typeName = ITEM_TYPE.ITEM
                id = tonumber(_awards[1])
            end
            table.insert(awards, {id = id, typeName = typeName, count = count})
        end
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsBoxAlert",
        options = {awards = awards, isGet = false, tips = tips, isShowRedpacketTips = false, titleStr = "建设奖励"}},{isPopCurrentDialog = false} )
end

function QUIDialogUnionBuilding:_onTriggerView(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_view) == false then return end
    if self._isAnimation then
        return
    end
    app.sound:playSound("common_small")

    remote.union:getUnionSacrificeInfoRequest(function(data)
            if self:safeCheck() and data.consortiaFighters then
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionSacrificeView", 
                    options = {consortiaFighters = data.consortiaFighters}},{isPopCurrentDialog = false})
                self:setInfo()
            end
        end)
end
 
function QUIDialogUnionBuilding:_feteRewardCallback(data)
    local awards = {}
    for k, v in ipairs(data.prizes) do
        table.insert(awards, {id = v.id, typeName = v.type, count = v.count})
    end
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
        options = {awards = awards}}, {isPopCurrentDialog = false})
    dialog:setTitle("恭喜您获得宗门奖励")

    self:setInfo()
end

-- function QUIDialogUnionBuilding:_onTriggerLevelReward()
--     local rewardLogStr = remote.user.userConsortia.rewardLog or ""
--     local rewardLogs = string.split(rewardLogStr, "#")
--     local initLevel = remote.user.userConsortia.initConsortiaLevel + 1
--     for k, v in ipairs(rewardLogs) do 
--         if initLevel == tonumber(v) then
--             initLevel = initLevel + 1
--         end
--     end

--     app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionRewardBox",
--         options = {condition = initLevel, type = 1, eligible = initLevel <= remote.union.consortia.level, 
--                     id = db:getSocietyLevel(initLevel).level_reward, 
--                     confirmCallback = function ( ... )
--                             remote.union:unionFeteLevelUpRewardRequest(initLevel, function (data)
--                                 self:_feteRewardCallback(data)
--                             end)
--                         end}},{isPopCurrentDialog = false})
-- end

function QUIDialogUnionBuilding:onTriggerBackHandler(tag)
    if self._isAnimation then
        return
    end
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end


return QUIDialogUnionBuilding
