
-- zxs
-- 武魂真身信息
-- 
local QUIWidget = import("..QUIWidget")
local QUIWidgetArtifactInfoDetail = class("QUIWidgetArtifactInfoDetail", QUIWidget)

local QScrollView = import("....views.QScrollView") 
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetArtifactInfoDetailClient = import(".QUIWidgetArtifactInfoDetailClient")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QQuickWay = import("....utils.QQuickWay")

function QUIWidgetArtifactInfoDetail:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_artifact_info.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerEvolution", callback = handler(self, self._onTriggerEvolution)},
        {ccbCallbackName = "onTriggerAutoAdd", callback = handler(self, self._onTriggerAutoAdd)},
        {ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
    }
    QUIWidgetArtifactInfoDetail.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    
    q.setButtonEnableShadow(self._ccbOwner.btn_break)
    q.setButtonEnableShadow(self._ccbOwner.btn_break2)
    q.setButtonEnableShadow(self._ccbOwner.btn_auto_add)

    remote.artifact.artifactWearShow = false
    self._ccbOwner.node_on_auto_add:setVisible(false)
end

function QUIWidgetArtifactInfoDetail:onEnter()
    self:initScrollView()
end

function QUIWidgetArtifactInfoDetail:onExit()
end

function QUIWidgetArtifactInfoDetail:initScrollView()
    if not self._scrollView then
        local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView:setVerticalBounce(true)
    end

    if not self._scrollView1 then
        local itemContentSize1 = self._ccbOwner.sheet_layout1:getContentSize()
        self._scrollView1 = QScrollView.new(self._ccbOwner.sheet, itemContentSize1, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView1:setVerticalBounce(true)
    end
end

function QUIWidgetArtifactInfoDetail:setInfo(actorId)
    self._ccbOwner.node_on_auto_add:setVisible(false)

    self:initScrollView()

    self._actorId = actorId
    local client = QUIWidgetArtifactInfoDetailClient.new()
    client:setInfo(actorId)
    local contentSize = client:getContentSize()
    client:setPosition(ccp(0, 0))   

    local artifactId = remote.artifact:getArtiactByActorId(self._actorId)
    self._artifactId = artifactId

    self._scrollView:clear()
    self._scrollView1:clear()
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    if heroInfo.artifact then
        self._ccbOwner.node_awake:setVisible(false)
        self._ccbOwner.node_item:setVisible(false)
        self._ccbOwner.node_grade_tips:setVisible(false)
        self._scrollView1:addItemBox(client)
        self._scrollView1:setRect(0, -contentSize.height, 0, contentSize.width)
        client:setUnwearButtonStated(true)   
    else
        self._ccbOwner.node_awake:setVisible(true)
        self._ccbOwner.node_item:setVisible(true)

        local gradeConfig = remote.artifact:getGradeByArtifactLevel(artifactId, 1)
        -- local newGradeConfig = remote.artifact:getGradeByArtifactLevel(artifactId, self._grade+1)
        local soulCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
        
        self._ccbOwner.tf_progress:setString(soulCount.."/"..gradeConfig.soul_gem_count)
        self._ccbOwner.sp_progress:setScaleX(math.min(soulCount/gradeConfig.soul_gem_count, 1))
        self._ccbOwner.node_grade_tips:setVisible(false)
        local itemBox = QUIWidgetItemsBox.new()
        self._ccbOwner.node_item:removeAllChildren()
        self._ccbOwner.node_item:addChild(itemBox)
        if soulCount >= gradeConfig.soul_gem_count then
            self._ccbOwner.node_grade_tips:setVisible(true)
        end

        if remote.artifact:canAutoAddAndGrade(artifactId) then
            print("node_on_auto_add")
            self._ccbOwner.node_awake:setVisible(false)
            self._ccbOwner.node_on_auto_add:setVisible(true)
            itemBox:setGoodsInfo(gradeConfig.soul_gem, ITEM_TYPE.ITEM, soulCount)
            itemBox:setItemCount(string.format("%d/%d", soulCount, gradeConfig.soul_gem_count))
            itemBox:setPositionX(130)
            self._ccbOwner.node_item:setScale(0.75)
        else 
            print("node_awake", gradeConfig.soul_gem)
            self._ccbOwner.node_awake:setVisible(true)
            self._ccbOwner.node_on_auto_add:setVisible(false)
            itemBox:setGoodsInfo(gradeConfig.soul_gem, ITEM_TYPE.ITEM)
            itemBox:setPositionX(0)
            self._ccbOwner.node_item:setScale(0.5)
        end
        itemBox:hideSabc()

        self._scrollView:addItemBox(client)
        self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)

        local lockConfig = app.unlock:getConfigByKey("UNLOCK_ARTIFACT")
        if heroInfo.level >= lockConfig.hero_level then
            makeNodeFromGrayToNormal(self._ccbOwner.node_break)
            self._ccbOwner.tf_btnName:enableOutline()
        else
            makeNodeFromNormalToGray(self._ccbOwner.node_break)
            self._ccbOwner.tf_btnName:disableOutline()
            self._ccbOwner.node_grade_tips:setVisible(false)
        end
        client:setUnwearButtonStated(false)   
    end
end

function QUIWidgetArtifactInfoDetail:_onTriggerEvolution(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_break) == false then return end
    app.sound:playSound("common_cancel")
    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    local lockConfig = app.unlock:getConfigByKey("UNLOCK_ARTIFACT")
    if heroInfo.level < lockConfig.hero_level then
        app.tip:floatTip("魂师等级不足~")
        return
    end
    local artifactId = remote.artifact:getArtiactByActorId(self._actorId)
    local gradeConfig = remote.artifact:getGradeByArtifactLevel(artifactId, 1)
    local soulCount = remote.items:getItemsNumByID(gradeConfig.soul_gem)
    if soulCount >= gradeConfig.soul_gem_count then
        local callback = function()
            remote.artifact:artifactCombineRequest(self._actorId, false, function ()
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogShowArtifactInfo",
                    options = { actorId = self._actorId }},{isPopCurrentDialog = false})
            end)
        end
        local itemConfig = db:getItemByID(gradeConfig.soul_gem)
        local heroInfo = db:getCharacterByID(self._actorId)
        local content = string.format("##n是否消耗##l【%s】*%d，金币*%d，##n让##l%s##n进行武魂真身觉醒？",itemConfig.name, gradeConfig.soul_gem_count, gradeConfig.money, heroInfo.name) 
        app:alert({content = content, title = "系统提示", callback = function(callType)
                if callType == ALERT_TYPE.CONFIRM then
                    callback()
                end
            end, isAnimation = true, colorful = true}, true, true)
    else
        QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, gradeConfig.soul_gem)
    end
end

function QUIWidgetArtifactInfoDetail:_onPlus(event)
    if q.buttonEventShadow(event,self._ccbOwner.btn_plus) == false then return end
    local artifactId = remote.artifact:getArtiactByActorId(self._actorId)
    local gradeConfig = remote.artifact:getGradeByArtifactLevel(artifactId, 1)
    if gradeConfig ~= nil then
        local dropType = QQuickWay.ITEM_DROP_WAY
        QQuickWay:addQuickWay(dropType, gradeConfig.soul_gem, nil, nil, false)
    end
end

-- 一键添加
function QUIWidgetArtifactInfoDetail:_onTriggerAutoAdd()
    app.sound:playSound("common_small")

    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    local lockConfig = app.unlock:getConfigByKey("UNLOCK_ARTIFACT")
    if heroInfo.level < lockConfig.hero_level then
        app.tip:floatTip("魂师等级不足~")
        return
    end

    local callback = function()
        self:setInfo(self._actorId)
    end

    local autoAddInfo = remote.artifact:getAutoAddGradeInfo(self._artifactId, 0)
    QKumo(autoAddInfo)
    print(self._actorId)
    print(self._artifactId)
    app:getNavigationManager():pushViewController(app.middleLayer, {
        uiType = QUIViewController.TYPE_DIALOG, 
        uiClass = "QUIDialogArtifactAutoGrade", 
        options = {
            actorId = self._actorId, 
            artifactId = self._artifactId, 
            curGrade = 0, 
            isCombine = true,
            callback = callback,
            autoAddInfo = autoAddInfo}
        },{
            isPopCurrentDialog = false
        }
    )
end

return QUIWidgetArtifactInfoDetail