--
-- Author: Kumo.Wang
-- 仙品英雄面板界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroMagicHerb = class("QUIWidgetHeroMagicHerb", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QRemote = import("...models.QRemote")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")
local QUIWidgetAnimationPlayer = import(".QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import(".actorDisplay.QUIWidgetFcaAnimation")

function QUIWidgetHeroMagicHerb:ctor(options)
	local ccbFile = "ccb/Widget_MagicHerb.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerInspect", callback = handler(self, self._onTriggerInspect)},
        {ccbCallbackName = "onTriggerSuitSkill", callback = handler(self, self._onTriggerSuitSkill)},
        {ccbCallbackName = "onMagicHerbQuickChange", callback = handler(self, self._onMagicHerbQuickChange)},
    }
	QUIWidgetHeroMagicHerb.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroOverView()
    
    q.setButtonEnableShadow(self._ccbOwner.btn_change)

    self._magicHerbBoxlist = {}
    self._isAnimation = false
    self:_init() 
end

function QUIWidgetHeroMagicHerb:onEnter()
    self._isAnimation = false
    self._magicHerbProxy = cc.EventProxy.new(remote.magicHerb)
    self._magicHerbProxy:addEventListener(remote.magicHerb.EVENT_REFRESH_MAGIC_HERB, handler(self, self._refreshMagicHerbHandler))
end

function QUIWidgetHeroMagicHerb:onExit()
    self._isAnimation = false
    self._magicHerbProxy:removeAllEventListeners()
end

function QUIWidgetHeroMagicHerb:update(actorId)
    self._isAnimation = false
    local oldActorID = self._actorId
    self._actorId = actorId
    self:setHero(self._actorId)
end

function QUIWidgetHeroMagicHerb:saveListInfo(heroList, heroPos, parentOptions)
    self._heroList = heroList
    self._heroPos = heroPos
    self._parentOptions = parentOptions
end

function QUIWidgetHeroMagicHerb:isRunAnimation()
    return self._isAnimation
end

function QUIWidgetHeroMagicHerb:setHero(actorId)
    self._actorId = actorId
    self._uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)

    for pos, box in ipairs(self._magicHerbBoxlist) do
        box:setHeroId(self._actorId)
        local magicHerbWearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(pos)
        -- QPrintTable(magicHerbWearedInfo)
        if magicHerbWearedInfo and magicHerbWearedInfo.sid then
            box:setInfo(magicHerbWearedInfo.sid)
        else
            box:setInfo()
        end
        local redTips = self._uiHeroModel:checkHeroMagicHerbRedTipsByPos(pos)
        box:setRedTipStatus(redTips)
    end
    
    self:_animationEndHandler()
    if not remote.magicHerb.donotShowSuit then
        self:_showSuitIcon()
    end

    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    local oldMagicHerbs = clone(heroInfo.magicHerbs)
    heroInfo.magicHerbs = {}
    local oldHeroModel = QActorProp.new(heroInfo)
    local oldBattleForce = math.ceil(oldHeroModel:getBattleForce(true))

    heroInfo.magicHerbs = oldMagicHerbs
    local newHeroModel = QActorProp.new(heroInfo)
    local newBattleForce = math.ceil(newHeroModel:getBattleForce(true))
        
    local tempForce = newBattleForce - oldBattleForce
    local force, unit = q.convertLargerNumber(tempForce)
    self._ccbOwner.tf_magicHerb_force:setString(force..unit)
end

function QUIWidgetHeroMagicHerb:_init()
    local pos = 1
    while true do
        local node = self._ccbOwner["node_MagicHerb_"..pos]
        if node then
            node:removeAllChildren()
            local box = QUIWidgetMagicHerbBox.new({pos = pos})
            box:addEventListener(QUIWidgetMagicHerbBox.EVENT_CLICK, handler(self, self._onClick))
            node:addChild(box)
            self._magicHerbBoxlist[pos] = box
            pos = pos + 1
        else
            break
        end
    end
    self._ccbOwner.btn_change:setVisible(app.unlock:checkLock("XIANPIN_QUICK_EXCHANGE", false))
end

function QUIWidgetHeroMagicHerb:_onClick(event, isForce)
    if self._isAnimation and not isForce then return end
    app.sound:playSound("common_small")
    
    local magicHerbWearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(event.pos)
    if magicHerbWearedInfo then
        -- 已穿戴
        -- app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbDetailInfo", 
        --     options = {sid = magicHerbWearedInfo.sid, actorId = self._actorId, pos = event.pos}})
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbDetail", 
            options = {heroList = self._heroList, heroPos = self._heroPos, pos = event.pos, parentOptions = self._parentOptions}})
    else
        -- 未穿戴
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbCheckroom", 
            options = {actorId = self._actorId, pos = event.pos, needMark = true}})
    end
end

function QUIWidgetHeroMagicHerb:_updateHero(magicHerbSid, isOnWear)
    if self._actorId then
        self:setHero(self._actorId)
    end
    if magicHerbSid then
        -- 属性展示界面
        local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(magicHerbSid)
        if magicHerbItemInfo then
            remote.magicHerb.donotShowSuit = false

            local basicPropList = {}
            local tbl = {}
            local attachPropList = {}
            local magicHerbGradeConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(magicHerbItemInfo.itemId,magicHerbItemInfo.grade or 1)

            if magicHerbGradeConfig then
                -- QPrintTable(magicHerbGradeConfig)
                for key, value in pairs(magicHerbGradeConfig) do
                    if QActorProp._field[key] then
                        local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                        local num = value
                        if tbl[key] then
                            tbl[key] = {name = name, num = tbl[key].num + num, isPercent = QActorProp._field[key].isPercent}
                        else
                            tbl[key] = {name = name, num = num, isPercent = QActorProp._field[key].isPercent}
                        end
                    end
                end
            end
            local magicHerbUpLevelConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(magicHerbItemInfo.itemId, magicHerbItemInfo.level or 1)
            if magicHerbUpLevelConfig then
                -- QPrintTable(magicHerbUpLevelConfig)
                for key, value in pairs(magicHerbUpLevelConfig) do
                    if QActorProp._field[key] then
                        local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                        local num = value
                        if tbl[key] then
                            tbl[key] = {name = name, num = tbl[key].num + num, isPercent = QActorProp._field[key].isPercent}
                        else
                            tbl[key] = {name = name, num = num, isPercent = QActorProp._field[key].isPercent}
                        end
                    end
                end
            end
            local tmpTbl1 = {}
            local tmpTbl2 = {}
            for key, value in pairs(tbl) do
                if key == "armor_physical" or key == "armor_magic" then
                    table.insert(tmpTbl1, value)
                elseif key == "armor_physical_percent" or key == "armor_magic_percent" then
                    table.insert(tmpTbl2, value)
                else
                    table.insert(basicPropList, value)
                end
            end
            if #tmpTbl1 == 2 then
                table.insert(basicPropList, {name = "双防", num = tmpTbl1[1].num, isPercent = tmpTbl1[1].isPercent})
            elseif #tmpTbl1 == 1 then
                table.insert(basicPropList, {name = tmpTbl1[1].name, num = tmpTbl1[1].num, isPercent = tmpTbl1[1].isPercent})
            end
            if #tmpTbl2 == 2 then
                table.insert(basicPropList, {name = "双防", num = tmpTbl2[1].num, isPercent = tmpTbl2[1].isPercent})
            elseif #tmpTbl2 == 1 then
                table.insert(basicPropList, {name = tmpTbl2[1].name, num = tmpTbl2[1].num, isPercent = tmpTbl2[1].isPercent})
            end
        
            local magicHerbInfo = magicHerbItemInfo
            if magicHerbInfo then 
                -- QPrintTable(magicHerbInfo)
                if magicHerbInfo.attributes then
                    for _, value in ipairs(magicHerbInfo.attributes) do
                        if value.attribute and QActorProp._field[value.attribute] then
                            local name = QActorProp._field[value.attribute].uiName or QActorProp._field[value.attribute].name
                            local num = value.refineValue or 0
                            table.insert(attachPropList, {name = name, num = num, isPercent = QActorProp._field[value.attribute].isPercent})
                        end
                    end
                end
            end

            if #basicPropList > 0 or #attachPropList > 0 then
                local ccbFile = "ccb/effects/Baoshi_tips.ccbi"
                app.sound:playSound("force_add")
                self._effectShow = QUIWidgetAnimationPlayer.new()
                self:getParent():getParent():addChild(self._effectShow)
                self._effectShow:setPositionY(100)
                self._effectShow:playAnimation(ccbFile, function(ccbOwner)
                    ccbOwner.node_green:setVisible(true)
                    ccbOwner.node_red:setVisible(false)
                    local symbol = "+"
                    if isOnWear then
                        ccbOwner.tf_title1:setString("携带成功")
                        symbol = "+"
                    else
                        ccbOwner.tf_title1:setString("卸下成功")
                        symbol = "-"
                    end
                    for i=1, 4 do
                        ccbOwner["node_"..i]:setVisible(false)
                    end
                    local index = 1
                    for _, value in ipairs(basicPropList) do
                        local node = ccbOwner["node_"..index]
                        local tf = ccbOwner["tf_name"..index]
                        if node and tf then
                            local num = value.num
                            num = q.getFilteredNumberToString(num, value.isPercent, 2)     
                            tf:setString(value.name..symbol..num)
                            node:setVisible(true)
                            index = index + 1
                        end
                    end
                    for _, value in ipairs(attachPropList) do
                        local node = ccbOwner["node_"..index]
                        local tf = ccbOwner["tf_name"..index]
                        if node and tf then
                            local num = value.num
                            num = q.getFilteredNumberToString(num, value.isPercent, 2)     
                            tf:setString(value.name..symbol..num)
                            node:setVisible(true)
                            index = index + 1
                        end
                    end
                    end, function()
                        if self._effectShow ~= nil then
                            self._effectShow:disappear()
                            self._effectShow = nil
                        end
                        if isOnWear then
                            local suitSkill,_minAptitudeInSuit,_minBreedLvInSuit , magicHerbSuitConfig = self._uiHeroModel:getMagicHerbSuitSkill()
                            if suitSkill and magicHerbSuitConfig then
                                -- 套装激活展示界面
                                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbActivateSuit", 
                                    options = {actorId = self._actorId, suitSkill = suitSkill,magicHerbSuitConfig=magicHerbSuitConfig, callback = handler(self, self._updateSuit)}})
                            else
                                self._isAnimation = false
                            end
                        else
                            self._isAnimation = false
                        end
                    end)    
            end
        else
            self._isAnimation = false
        end
    end
end

function QUIWidgetHeroMagicHerb:_updateSuit(suitSkill)
    if not self._fcaAnimation and self._ccbView then
        self._ccbOwner.node_activate_suit_effect:removeAllChildren()
        self._fcaAnimation = QUIWidgetFcaAnimation.new("fca/xianpin_zbihecheng_effect", "res")
        self._fcaAnimation:setEndCallback(handler(self, self._animationEndHandler))
        self._fcaAnimation:playAnimation("animation", false)
        self._ccbOwner.node_activate_suit_effect:addChild(self._fcaAnimation)

        local ccArrary = CCArray:create()
        ccArrary:addObject(CCDelayTime:create(1.5))
        ccArrary:addObject(CCCallFunc:create(function()
            self:_showSuitIcon()
        end))
        self._ccbOwner.node_activate_suit_effect:runAction(CCSequence:create(ccArrary))
    end
end

function QUIWidgetHeroMagicHerb:_animationEndHandler()
    if self._fcaAnimation then
        self._fcaAnimation:stop()
    end
    self._ccbOwner.node_activate_suit_effect:removeAllChildren()
    self._fcaAnimation = nil
    if not remote.magicHerb.donotShowSuit then
        self._isAnimation = false
    end
end

function QUIWidgetHeroMagicHerb:_showSuitIcon()
    self._ccbOwner.tf_name:setVisible(false)
    self._ccbOwner.node_MagicHerb_skill:removeAllChildren()

    local suitSkill = self._uiHeroModel:getMagicHerbSuitSkill()
    if suitSkill then
        local skillConfig = QStaticDatabase.sharedDatabase():getSkillByID(suitSkill)
        if skillConfig then
            local icon = CCSprite:create(skillConfig.icon)
            
            if icon then
                self._ccbOwner.node_MagicHerb_skill:addChild(icon)
                icon:setScale(1)
                icon:setShaderProgram(qShader.Q_ProgramPositionTextureColorCircle)
                icon:setOpacity(1 * 255)
            end
            self._ccbOwner.tf_name:setVisible(true)
            self._ccbOwner.tf_name:setString(skillConfig.name)
        end
    end
end

function QUIWidgetHeroMagicHerb:_updateInfo()
end

function QUIWidgetHeroMagicHerb:_onTriggerInspect(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_inspect) == false then return end
    if self._isAnimation then return end

    app.sound:playSound("common_small")
    local wearInfoList = {}
    for pos, _ in ipairs(self._magicHerbBoxlist) do
        local magicHerbWearedInfo = self._uiHeroModel:getMagicHerbWearedInfoByPos(pos)
        if magicHerbWearedInfo and magicHerbWearedInfo.sid then
            table.insert(wearInfoList, {pos = pos, sid = magicHerbWearedInfo.sid})
        end
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbPropView", 
        options = {wearInfoList = wearInfoList}})
end

function QUIWidgetHeroMagicHerb:_onTriggerSuitSkill()
    if self._isAnimation then return end

    app.sound:playSound("common_small")
    local isSuit = self._uiHeroModel:isHasSuitMagicHerb()
    if isSuit then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbSuitView", 
            options = {actorId = self._actorId}})
    else
        app.tip:floatTip("当前未获得百草集效果，需装备三个同类型的仙品")  
    end
end

function QUIWidgetHeroMagicHerb:_refreshMagicHerbHandler(event)
    if event.sid ~= nil then
        self._isAnimation = true
        self:_updateHero(event.sid, event.isOnWear)
    else
        if self._actorId then
            self:setHero(self._actorId)
        end
    end
end

function QUIWidgetHeroMagicHerb:_onMagicHerbQuickChange()
    if self._isAnimation then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMagicHerbQuickChange", 
        options = {actorId = self._actorId}})

end

return QUIWidgetHeroMagicHerb