--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionHead = class("QUIDialogUnionHead", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QScrollView = import("...views.QScrollView")
local QUIWidget = import("..widgets.QUIWidget")

local columnNumber = 4
local avatarWidth = 89
local gap = 20

function QUIDialogUnionHead:ctor(options)
 	local ccbFile = "ccb/Dialog_society_union_choose.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogUnionHead._onTriggerClose)},
    }
    QUIDialogUnionHead.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._avatars = {}
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)

    if options.type == 1 then
        local unionAvatars = QStaticDatabase:sharedDatabase():getUnionIcons()
        self:_updateAvatar(unionAvatars)
        -- self._ccbOwner.title:setString("请选择宗门图标")
        self._ccbOwner.frame_tf_title:setString("请选择宗门图标")
    else
        local unionFrames = QStaticDatabase:sharedDatabase():getUnionFrames()
        self:_updateFrame(unionFrames)
        -- self._ccbOwner.title:setString("基础头像框")
         self._ccbOwner.frame_tf_title:setString("基础头像框")
    end
end

function QUIDialogUnionHead:viewDidAppear( ... )
    QUIDialogUnionHead.super.viewDidAppear(self)
    self._scrollViewProxy = cc.EventProxy.new(self._scrollView)
    self._scrollViewProxy:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollViewProxy:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogUnionHead:viewWillDisappear( ... )
    QUIDialogUnionHead.super.viewWillDisappear(self)

    for k, v in ipairs(self._avatars) do
        v:removeEventListener(QUIWidgetAvatar.CLICK, handler(self, self._onUnionAvatarSelected))
    end

    if self._scrollViewProxy then
        self._scrollViewProxy:removeAllEventListeners()
        self._scrollViewProxy = nil
    end
end

function QUIDialogUnionHead:_onScrollViewMoving()
    self._isMoving = true
end

function QUIDialogUnionHead:_onScrollViewBegan()
    self._isMoving = false
end

function QUIDialogUnionHead:_updateAvatar(Ids)
    self._scrollView:clear()

    local heads = {{},{}}
    local dragonFighterInfo = remote.unionDragonWar:getMyDragonFighterInfo()
    local floor = 0
    if dragonFighterInfo ~= nil then
        floor = dragonFighterInfo.lastSeasonFloor
        local floorConfig = QStaticDatabase:sharedDatabase():getUnionDragonFloorInfoByFloor(floor)
        if floorConfig ~= nil then
            floor = floorConfig.total_dan
        else
            floor = 0
        end
    end
    for k, v in pairs(Ids) do
        if v.function_type == remote.union.HEAD_TYPE_DRAGON then
            local isLock = floor ~= v.condition
            table.insert(heads[2], {value = v, isLock = isLock})
        else
            table.insert(heads[1], {value = v})
        end
    end
    table.sort(heads[2], function (a,b)
        if a.value.sort ~= b.value.sort then
            return (a.value.sort or 0) < (b.value.sort or 0)
        end
        return a.value.id < b.value.id
    end)
    self._totalHeight = 10
    self:_createAvatarByHeads(heads[1], "请选择宗门图标")
    self:_createAvatarByHeads(heads[2], "巨龙之战 解锁头像")
    self._ccbOwner.widget:setVisible(false)

    self._scrollView:setRect(0, -self._totalHeight, 0, self._ccbOwner.sheet_layout:getContentSize().width) 
end

function QUIDialogUnionHead:_createAvatarByHeads(heads, desc)
    local widget = QUIWidget.new("ccb/Widget_society_union_choose.ccbi")
    widget:setPositionY(-(self._totalHeight))
    self._scrollView:addItemBox(widget)
    
    local index = 0
    for k, v in ipairs(heads) do
        local avatar = QUnionAvatar.new(tostring(v.value.id), nil, v.isLock)
        avatar:setPosition(ccp((avatarWidth + gap) * math.fmod(index, columnNumber) + avatarWidth - avatarWidth/2 + 14, 
                                -((avatarWidth + gap) * math.modf(index/columnNumber) + avatarWidth/2) - self._totalHeight))
        avatar:addEventListener(QUIWidgetAvatar.CLICK, handler(self, self._onUnionAvatarSelected))
        avatar:setScale(0.8)
        table.insert(self._avatars, avatar)
        self._scrollView:addItemBox(avatar)
        index = k
    end
    self._totalHeight = self._totalHeight + (avatarWidth + gap) * (math.ceil(index/columnNumber))
end

function QUIDialogUnionHead:_updateFrame(Ids)
    self._scrollView:clear()

    self._ccbOwner.widget:retain()
    self._ccbOwner.widget:removeFromParent()
    self._scrollView:addItemBox(self._ccbOwner.widget)
    self._ccbOwner.widget:release()

    local index = 0
    local totalHeight = 0
    for k, v in pairs(Ids) do
        local avatar = QUnionAvatar.new(k)
        avatar:setPosition(ccp(300, -(avatarWidth + gap) * (index + 1)))
        avatar:addEventListener(QUIWidgetAvatar.CLICK, handler(self, self._onUnionAvatarSelected))
        table.insert(self._avatars, avatar)
        self._scrollView:addItemBox(avatar)

        index = index + 1
    end
    totalHeight = avatarWidth * (index + 1)

    self._scrollView:setRect(0, -totalHeight, 0, self._ccbOwner.sheet_layout:getContentSize().width) 
end


function QUIDialogUnionHead:_onUnionAvatarSelected(event)
    if self._isMoving == true then return end
    if event.locked == true then 
        local head = QStaticDatabase:sharedDatabase():getHeadInfoById(event.avatar)
        app.tip:floatTip(head.tip)
        return
    end
    if self:getOptions().newAvatarSelected then
        local avatarId, frameId = remote.headProp:getAvatarFrameId(remote.union.consortia.icon)
        local newAvatar = remote.headProp:getAvatar(event.avatar, frameId)
        self:getOptions().newAvatarSelected(newAvatar)
    end
    self:_onTriggerClose()
end

function QUIDialogUnionHead:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogUnionHead:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    self:playEffectOut()
end

function QUIDialogUnionHead:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogUnionHead