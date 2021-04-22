--
-- zxs
-- 宣传信息
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAdvertisingInfo = class("QUIDialogAdvertisingInfo", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QLogFile = import("...utils.QLogFile")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")

function QUIDialogAdvertisingInfo:ctor(options)
    local ccbFile = "ccb/Dialog_maode_open.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogAdvertisingInfo._onTriggerClose)},
        {ccbCallbackName = "onTriggerHeroIntroduce", callback = handler(self, QUIDialogAdvertisingInfo._onTriggerHeroIntroduce)},
        {ccbCallbackName = "onTriggerGo", callback = handler(self, QUIDialogAdvertisingInfo._onTriggerGo)},
    }
    QUIDialogAdvertisingInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._callback = options.callback
    self._data = options.data

    self:_init()
end

function QUIDialogAdvertisingInfo:_init()
    -- 大图
    if self._data.resource_1 then
        local icon = QSpriteFrameByPath(self._data.resource_1)
        if icon then
            self._ccbOwner.sp_image:setDisplayFrame(icon)
        end
    end

    -- 角色
    if self._data.resource_2 then
        local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
        self._fca = skeletonViewController:createSkeletonActorWithFile(self._data.resource_2, nil, false)
        self._fca:setScale(self._data.scale or 0.3)
        self._fca:playAnimation("stand", true)
        self._fca:scheduleUpdate_()
        self._ccbOwner.node_avatar:addChild(self._fca)
    end

    -- 特效
    if self._data.resource_3 then
        local skeletonViewController = QSkeletonViewController.sharedSkeletonViewController()
        self._effect = skeletonViewController:createSkeletonActorWithFile(self._data.resource_3, nil, false)
        self._effect:playAnimation("animation", true)
        self._effect:scheduleUpdate_()
        self._ccbOwner.node_effect:addChild(self._effect)
    end

    -- 开启限制
    self._ccbOwner.tf_level_tips:setVisible(false)
    if self._data.show_level then
        self._ccbOwner.tf_level_tips:setString("魂师等级"..self._data.show_level.."级后开启功能")
        self._ccbOwner.tf_level_tips:setVisible(true)
    end
    
    -- 关闭按钮
    self._ccbOwner.btn_close:setVisible(false)
    if self._data.position_1 then
        local pos = string.split(self._data.position_1, ",")
        self._ccbOwner.btn_close:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
        self._ccbOwner.btn_close:setVisible(true)
    end

    -- 播放按钮
    self._ccbOwner.node_play:setVisible(false)
    if self._data.position_2 then
        local pos = string.split(self._data.position_2, ",")
        self._ccbOwner.node_play:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
        self._ccbOwner.node_play:setVisible(true)
    end

    -- 时间显示
    self._ccbOwner.node_time:setVisible(false)
    if self._data.position_3 then
        local pos = string.split(self._data.position_3, ",")
        self._ccbOwner.node_time:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
        self._ccbOwner.node_time:setVisible(true)
    end

    -- 角色主题展示
    if self._data.position_4 then
        local pos = string.split(self._data.position_4, ",")
        self._ccbOwner.node_avatar:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
    end

    -- 前往
    self._ccbOwner.btn_go:setVisible(false)
    if self._data.position_5 then
        local pos = string.split(self._data.position_5, ",")
        self._ccbOwner.btn_go:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
        self._ccbOwner.btn_go:setVisible(true)
    end

    -- 特效
    if self._data.position_6 then
        local pos = string.split(self._data.position_6, ",")
        self._ccbOwner.node_effect:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
    end

    -- 前往按钮
    if self._data.btn_go_pic then
        local btnSprite1 = CCSprite:create(self._data.btn_go_pic)
        if btnSprite1 then
            local btnSprite2 = CCSprite:create(self._data.btn_go_pic)
            local btnSize = btnSprite1:getContentSize()
            self._ccbOwner.btn_go:setBackgroundSpriteFrameForState(btnSprite1:getDisplayFrame(), CCControlStateNormal)
            self._ccbOwner.btn_go:setBackgroundSpriteFrameForState(btnSprite2:getDisplayFrame(), CCControlStateHighlighted)
            self._ccbOwner.btn_go:setPreferredSize(btnSize);
        end
    end

    -- 道具位置
    if self._data.item_position then
        local posTbl = string.split(self._data.item_position, ";")
        for i, posStr in pairs(posTbl) do
            if self._ccbOwner["item_"..i] and posStr ~= "" then
                local pos = string.split(posStr, ",")
                self._ccbOwner["item_"..i]:setPosition(ccp(tonumber(pos[1]), tonumber(pos[2])))
            end
        end
    end

    -- 道具信息
    if self._data.item_info then
        local itemTbl = string.split(self._data.item_info, ";")
        for i, itemStr in pairs(itemTbl) do
            if self._ccbOwner["item_"..i] and itemStr ~= "" then
                local item = string.split(itemStr, ",")
                local itemType = remote.items:getItemType(item[1])
                if itemType == nil then
                    itemType = ITEM_TYPE.ITEM
                end
                local itemBox = QUIWidgetItemsBox.new()
                itemBox:showBoxEffect("effects/leiji_light.ccbi", true, 0, 0, 0.6)
                itemBox:setPromptIsOpen(true)
                itemBox:setGoodsInfo(item[1], itemType, tonumber(item[2]))
                self._ccbOwner["item_"..i]:addChild(itemBox)
            end
        end
    end

    local convertTime = function(value)
        if not value then
            return ""
        end
        local dayValue = string.split(value, ",")
        local openDay = string.split(dayValue[1], "/")
        local month = openDay[2]
        local day = openDay[3]
        local str = month.."月"..day.."日 "
        if dayValue[2] then
            str = str..dayValue[2]
        end
        return str
    end

    -- 时间头
    if self._data.title then
        self._ccbOwner.tf_title:setString(self._data.title)
    else
        self._ccbOwner.tf_title:setVisible(false)
    end

    -- 时间
    if self._data.open_time and self._data.end_time then
        local openTime = convertTime(self._data.open_time)
        local endTime = convertTime(self._data.end_time)
        self._ccbOwner.tf_time:setString(openTime.."~"..endTime)
    else
        self._ccbOwner.tf_time:setVisible(false)
    end

    -- 描述
    self._ccbOwner.tf_desc:setVisible(false)
    local showDayTbl = string.split(tostring(self._data.need_days), ";")
    local startDay = tonumber(showDayTbl[1]) or 0
    if startDay > 0 then
        self._ccbOwner.tf_desc:setVisible(true)
        self._ccbOwner.tf_desc:setString("（开服大于"..startDay.."天的服务器可参与）")
    end
    if self._data.limit_desc then
        self._ccbOwner.tf_desc:setVisible(true)
        self._ccbOwner.tf_desc:setString(self._data.limit_desc)
    end

    local posX = self._ccbOwner.tf_title:getPositionX()
    local width1 = self._ccbOwner.tf_title:getContentSize().width
    local width2 = self._ccbOwner.tf_time:getContentSize().width
    self._ccbOwner.tf_time:setPositionX(posX+width1)
    self._ccbOwner.tf_desc:setPositionX(posX+width1+width2)
end

function QUIDialogAdvertisingInfo:_onTriggerHeroIntroduce()
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBossIntroduce",
        options = {bossId = self._data.bossId, enemyTips = self._data.enemyTips}})
end

function QUIDialogAdvertisingInfo:_onTriggerGo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
    app.sound:playSound("common_small")

    self:popSelf()

    if self._data.themeId then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
            options = {themeId = self._data.themeId}}, {isPopCurrentDialog = true})
    else
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityCarnival"})
    end
end

function QUIDialogAdvertisingInfo:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogAdvertisingInfo:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogAdvertisingInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if self._callback then
        self._callback()
    end
end

return QUIDialogAdvertisingInfo