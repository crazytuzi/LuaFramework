--
-- Kumo.Wang
-- 回收站，单个回收界面——暗器重生
--
local QUIWidgetRecycleForAlone = import("..widgets.QUIWidgetRecycleForAlone")
local QUIWidgetRecycleForMountReset = class("QUIWidgetRecycleForMountReset", QUIWidgetRecycleForAlone)

local QUIViewController = import("..QUIViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QRichText = import("...utils.QRichText")
local QUIDialogMountOverView = import("..dialogs.QUIDialogMountOverView")

function QUIWidgetRecycleForMountReset:ctor(options)
	QUIWidgetRecycleForMountReset.super.ctor(self, options)
end

function QUIWidgetRecycleForMountReset:onEnter()
    QUIWidgetRecycleForMountReset.super.onEnter(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QUIDialogMountOverView.MOUNT_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForMountReset:onExit()
    QUIWidgetRecycleForMountReset.super.onExit(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIDialogMountOverView.MOUNT_CLICK, self._onItemSelected, self)
end

function QUIWidgetRecycleForMountReset:_onItemSelected(event)
    if self.isPlaying then return end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithHeroReborn()
    if event.mount == nil then return end

    self.info = event.mount
    self:update()
end

function QUIWidgetRecycleForMountReset:init()
    -- 初始化商店按鈕icon
    local config = remote.items:getWalletByType(ITEM_TYPE.STORM_MONEY)
    local spf = QSpriteFrameByPath(config.alphaIcon)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 1)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 2)
    self._ccbOwner.btn_store:setBackgroundSpriteFrameForState(spf, 4)
    self._ccbOwner.tf_store_name:setString("金属商店")

    QUIWidgetRecycleForMountReset.super.init(self)

    self.itemClassName = "QUIWidgetActorDisplay"
    self.priceKey = "ZUOQI_RECYCLE"
    
    -- 初始化剪影
    QSetDisplayFrameByPath(self._ccbOwner.sp_sketch, QResPath("recycleSketch")[3])
    self._ccbOwner.sp_sketch:setFlipX(true)
    self._ccbOwner.tf_unselect_tips:setString("选择需要重生的暗器")
end

function QUIWidgetRecycleForMountReset:initExplain()
    QUIWidgetRecycleForMountReset.super.initExplain(self)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "100%"},
            {oType = "font", size = 22, color = COLORS.a, strokeColor = COLORS.t, content = "返还养成的资源与材料，暗器"},
            {oType = "font", size = 22, color = COLORS.C, strokeColor = COLORS.t, content = "变为1级"},
        }, 680, {autoCenter = true})
    richText:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.node_tf_explain:addChild(richText)
end

function QUIWidgetRecycleForMountReset:initMenu()
    QUIWidgetRecycleForMountReset.super.initMenu(self)

    self._ccbOwner.node_btn_help:setVisible(true)
    self._ccbOwner.node_btn_store:setVisible(true)
end

function QUIWidgetRecycleForMountReset:updateData()
    if self.info then
        self._ccbOwner.node_unselected:setVisible(false)
        self._ccbOwner.node_selected:setVisible(true)
        self._ccbOwner.node_avatar:removeAllChildren()

        if not self.itemClass then
            self.itemClass = import(app.packageRoot .. ".ui.widgets." .. self.itemClassName)
        end

        self.avatar = self.itemClass.new(self.info.zuoqiId)
        self._ccbOwner.node_avatar:addChild(self.avatar:getView())

        -- Show title 
        local character = db:getCharacterByID(self.info.zuoqiId)
        if character then
            local nameStr = character.name
            local color = remote.mount:getColorByMountId(self.info.zuoqiId)
            local fontColor = QIDEA_QUALITY_COLOR[color]
            self._ccbOwner.tf_name:setColor(fontColor)
            setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
            self._ccbOwner.tf_name:setString(nameStr)
            self._ccbOwner.node_name_info:setVisible(true)
        end
    else
        self._ccbOwner.node_unselected:setVisible(true)
        self._ccbOwner.node_selected:setVisible(false)
    end
end

function QUIWidgetRecycleForMountReset:updateRecyclePreviewInfo()
    local info = {}
    self.importantKeysList = {"money"}

    if not self.info then return info end

    local enhanceExp = db:getMountEnhanceTotalExpByLevel(self.info.aptitude, self.info.enhanceLevel) + self.info.enhanceExp
    local expItem = db:getMountMaterialById(self.info.zuoqiId)
    local expItems = string.split(expItem.shengji_daoju, "^")

    local returnMaterial = {tonumber(expItems[3]), tonumber(expItems[2]), tonumber(expItems[1])}
    local heightMaterialExp = db:getItemByID(returnMaterial[1]).zuoqi_exp
    local advancedMaterialExp = db:getItemByID(returnMaterial[2]).zuoqi_exp
    local cheapMaterialExp = db:getItemByID(returnMaterial[3]).zuoqi_exp
    local heightMaterial = math.floor(enhanceExp / heightMaterialExp)
    local advancedMaterial = math.floor(enhanceExp % heightMaterialExp / advancedMaterialExp)
    local cheapMaterial = math.floor(enhanceExp % heightMaterialExp % advancedMaterialExp / cheapMaterialExp)

    if heightMaterial > 0 then
        info[returnMaterial[1]] = (info[returnMaterial[1]] or 0) + heightMaterial
    end
    if advancedMaterial > 0 then
        info[returnMaterial[2]] = (info[returnMaterial[2]] or 0) + advancedMaterial
    end
    if cheapMaterial > 0 then
        info[returnMaterial[3]] = (info[returnMaterial[3]] or 0) + cheapMaterial
    end

    -- 回收暗器
    self:_getFragmentPreviewInfo(info)
    -- 回收升星金币
    self:_getGradePreviewInfo(info)

    self:_getReformPreviewInfo(info)

    return info
end

function QUIWidgetRecycleForMountReset:_getFragmentPreviewInfo(info)
    local fragmentCount = 0
    local fragmentId = nil
    for i = 1, self.info.grade, 1 do
        local config = db:getGradeByHeroActorLevel(self.info.zuoqiId, i)
        if fragmentId ~= config.soul_gem then
            -- 記錄當前的循環fragmentId，如果不一樣，則保存之前的數據，繼續新的fragmentId循環
            if fragmentId ~= nil then
                if info[fragmentId] then
                    info[fragmentId] = info[fragmentId] + fragmentCount
                elseif fragmentCount > 0 then
                    info[fragmentId] = fragmentCount
                end
                table.insert(self.importantKeysList, 1, fragmentId)
            end
            fragmentId = config.soul_gem
        end
        fragmentCount = fragmentCount + config.soul_gem_count
    end  

    if fragmentId ~= nil then
        if info[fragmentId] then
            info[fragmentId] = info[fragmentId] + fragmentCount
        elseif fragmentCount > 0 then
            info[fragmentId] = fragmentCount
        end
        table.insert(self.importantKeysList, 1, fragmentId)
    end
end
function QUIWidgetRecycleForMountReset:_getGradePreviewInfo(info)
    local grade = db:getGradeByHeroId(self.info.zuoqiId)
    local minGrade = db:getCharacterByID(self.info.zuoqiId).grade

    for k, v in pairs(grade) do
        if v.grade_level <= self.info.grade then
            if v.grade_level > minGrade then
                local addValue = v.money or 0
                if info["money"] then
                    info["money"] = info["money"] + addValue
                elseif addValue > 0 then
                    info["money"] = addValue
                end
            end
        end
    end
end
function QUIWidgetRecycleForMountReset:_getReformPreviewInfo(info)
    if not self.info.reformLevel or self.info.reformLevel == 0 then
        return
    end
    local mountConfig = db:getCharacterByID(self.info.zuoqiId)
    local itemId = nil
    local itemCount = 0
    local money = 0
    for i = 1, self.info.reformLevel do
        local curConfig = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, i)
        local itemTbl1 = string.split(curConfig.consume_1, "^")
        local itemTbl2 = string.split(curConfig.consume_2, "^")
        itemId = tonumber(itemTbl1[1])
        itemCount = itemCount + tonumber(itemTbl1[2])
        money = money + tonumber(itemTbl2[2])
    end

    info[itemId] = itemCount

    local addValue = money
    if info["money"] then
        info["money"] = info["money"] + addValue
    elseif addValue > 0 then
        info["money"] = addValue
    end
end


function QUIWidgetRecycleForMountReset:onTriggerRecycle()
    if self.isPlaying then return end
    app.sound:playSound("common_small")

    if not self.info then
        app.tip:floatTip("请先选择一个需要重生的暗器") 
        return
    end

    if self.info.actorId and self.info.actorId ~= 0 then
        app.tip:floatTip("魂师大人，无法重生已装备的暗器，请将暗器卸下后重生～")
        return
    end

    if self.info.wearZuoqiInfo then
        app.tip:floatTip("魂师大人，当前暗器装备了配件暗器，请先卸下配件暗器后重生～")
        return 
    end

    if remote.user.token < self.price then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    local function callRebornAPI(finalRecycleInfo)
        remote.mount:mountReborn(self.info.zuoqiId, function ()
                if self._ccbView then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                    self:_onTriggerRecycleFinished(finalRecycleInfo)
                end
            end,function ()
                if self._ccbView then
                    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
                    self.id = nil
                    self.info = nil
                    self:update()
                end
            end)
    end

    local info = self:updateRecyclePreviewInfo()    
    QKumo(info)
    local finalRecycleInfo = self:sortRecyclePreviewInfo(info)
    if next(finalRecycleInfo) == nil then
        app.tip:floatTip("魂师大人，该暗器已经是初始状态，不需要重生了～")
        return 
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {compensations = finalRecycleInfo, token = self.price, title = "暗器重生后将返还以下资源，是否确认分解该暗器", callFunc = callRebornAPI}})
end
function QUIWidgetRecycleForMountReset:_onTriggerRecycleFinished(finalRecycleInfo)
    self.isPlaying = true
    local effect = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_effect:addChild(effect)
    effect:playAnimation("effects/HeroRecoverEffect_up.ccbi", function()
            if self._ccbView then
                effect._ccbOwner.node_avatar:setVisible(false)
            end
        end, function()
            if self._ccbView then
                effect:removeFromParentAndCleanup(true)
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornReturns", 
                    options = {compensations = finalRecycleInfo, type = 4, subtitle = "暗器重生返还以下资源"}}, {isPopCurrentDialog = false})
                self.id = nil
                self.info = nil
                self:update()
                self.isPlaying = false
            end
        end)
end

function QUIWidgetRecycleForMountReset:onTriggerStore()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    remote.stores:openShopDialog(SHOP_ID.metalCityShop)
end

function QUIWidgetRecycleForMountReset:onTriggerHelp()
    if self.isPlaying then return end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornRule", options = {type = 9}}, {isPopCurrentDialog = false})
end

function QUIWidgetRecycleForMountReset:onTriggerSelect()
    if self.isPlaying then return end
    app.sound:playSound("common_small")
    local hasMount = false
    local haveMounts = remote.mount:getMountMap()
    for _, mount in pairs(haveMounts) do
        if mount.actorId == 0 and (mount.enhanceLevel ~= 1 or mount.grade ~= 0) then
            hasMount = true
            break
        end
    end
    if hasMount then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {isReborn = true}})
    else
        app.tip:floatTip("没有可以重生的暗器~")
    end
end

return QUIWidgetRecycleForMountReset
