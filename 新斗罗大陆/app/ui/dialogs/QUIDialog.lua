
local QUIViewController = import("..QUIViewController")
local QUIDialog = class("QUIDialog", QUIViewController)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QNavigationController = import("...controllers.QNavigationController")

QUIDialog.EFFECT_IN_SCALE = "showDialogScale" --缩放进场
QUIDialog.EFFECT_OUT_SCALE = "hideDialogScale" --缩放出场

function QUIDialog:ctor(ccbFile,callBacks,options)
	QUIDialog.super.ctor(self, QUIViewController.TYPE_DIALOG, ccbFile, callBacks, options)
    self:setOptions(options)

    self.___handlers = {}
    self.isAnimation = false --是否动画显示
    self.effectInName = QUIDialog.EFFECT_IN_SCALE --采用的动画名称
    self.effectOutName = QUIDialog.EFFECT_OUT_SCALE --采用的动画名称
    if options ~= nil then
        self.isQuickWay = options.isQuickWay
        if options.effectInName ~= nil then
            self.effectInName = options.effectInName
        end
        if options.effectOutName ~= nil then
            self.effectOutName = options.effectOutName
        end
    end
    self._isLock = false --是否唯一窗口
    self._isTouchSwallow = true
    self._enableDialogEvent = true
    if options ~= nil and options.isChild ~= nil then
        self._isChild = options.isChild
    else
        self._isChild =  false
    end

    self._enable = true

    --创建根节点的动画效果
    local rootCcbFile = "ccb/QDialog.ccbi"
    self._rootOwner = {}
    local proxy = CCBProxy:create()
    self._root = CCBuilderReaderLoad(rootCcbFile, proxy, self._rootOwner)
    if self._isChild ~= true and self._root then
        self._root:setPosition(display.cx, display.cy)
    end
    self._rootOwner.dialogTarget:addChild(self._view)

    self:___dialogButton()
end

--换UI的时候处理一下关闭按钮
function QUIDialog:___dialogButton( ... )
    if self._ccbOwner and self._ccbOwner.frame_btn_close then
        q.setButtonEnableShadow(self._ccbOwner.frame_btn_close)
    end
end

function QUIDialog:getOptions()
    if self._options == nil then self._options = {} end
    return self._options
end

function QUIDialog:setOptions(options)
    self._options = options
end

function QUIDialog:getEnable()
    return self._enable
end

--添加返回按钮
function QUIDialog:addBackEvent(isShowHome)
    local isShowHome = isShowHome
    if isShowHome == nil then isShowHome = true end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page ~= nil and page.setBackBtnVisible ~= nil then
        page:setBackBtnVisible(true)
        page:setHomeBtnVisible(isShowHome)
        QNotificationCenter.sharedNotificationCenter():addMainPageEvent(self)
        if self.isQuickWay == true then
            page:setScalingVisible(false)
        end
    end
    QDeliveryWrapper:setBuglyTag(88173)
end

--删除返回按钮
function QUIDialog:removeBackEvent()
    QNotificationCenter.sharedNotificationCenter():removeMainPageEvent(self)
end

function QUIDialog:getView()
    return self._root
end

function QUIDialog:getChildView()
    return self._view
end

function QUIDialog:playEffectIn()
    if self._isEffectPlay == true then
        return 
    end
    if self.isAnimation then
        self:createAnimationProxy()
        self._isEffectPlay = true
        self._rootAnimationManager:runAnimationsForSequenceNamed(self.effectInName)
    else
        self:viewAnimationInHandler()
    end
end

function QUIDialog:playEffectOut()
    if self._isEffectPlay == true then
        return 
    end
    if self.isAnimation then
        self._isEffectPlay = true
        self._rootAnimationManager:runAnimationsForSequenceNamed(self.effectOutName)
    else
        self:viewAnimationOutHandler()
    end
end

function QUIDialog:_onTrigger(callback, ...)
    if self.isAnimation and self._isEffectPlay == true then
        return
    end

    callback(...)
end

--[[
    设置dialog是否锁住
    锁住的dialog同时只会存在一个
--]]
function QUIDialog:setLock(b)
    self._isLock = b
end

function QUIDialog:getLock()
    return self._isLock
end

function QUIDialog:viewDidAppear()
    QUIDialog.super.viewDidAppear(self)
    if self._isChild ~= true and self._isTouchSwallow == true then
        self:_enableTouchSwallow()
    end

    if self._enableDialogEvent == true then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_DIALOG_DID_APPEAR})
    end
end

function QUIDialog:viewWillDisappear()
    QUIDialog.super.viewWillDisappear(self)
    self:_disableTouchSwallow()

    self:removeAnimationProxy()

    for _,handler in ipairs(self.___handlers) do
        scheduler.unscheduleGlobal(handler)
    end

    if self._enableDialogEvent == true then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.EVENT_DIALOG_WILL_DISAPPEAR})
    end
    self:removeBackEvent()
end

function QUIDialog:createAnimationProxy()
    self._rootAnimationManager = tolua.cast(self._root:getUserObject(), "CCBAnimationManager")
    self._rootAnimationManager:connectScriptHandler(handler(self, self.rootAnimationEndHandler))
end

function QUIDialog:removeAnimationProxy()
    if self._rootAnimationManager then
        self._rootAnimationManager:disconnectScriptHandler()
    end
end

function QUIDialog:rootAnimationEndHandler(name)
    if name == self.effectInName then
        self._isEffectPlay = false
        self:viewAnimationInHandler()
    elseif name == self.effectOutName then
        self:viewAnimationOutHandler()
    end
end

function QUIDialog:getEffectPlay()
    return self._isEffectPlay or false
end

function QUIDialog:viewAnimationInHandler()

end

function QUIDialog:viewAnimationOutHandler()
    self:popSelf()
end

function QUIDialog:onTriggerBackHandler()
    self:popSelf()
end

function QUIDialog:onTriggerHomeHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialog:_enableTouchSwallow()
    if(self:getView() == nil) then return end
    local color = ccc4(0, 0, 0, 128)

    if self._backTouchLayer == nil then
        self._backTouchLayer = CCLayerColor:create(color, display.width, display.height)
        self._backTouchLayer:setPosition(-display.width/2, -display.height/2)
        self._backTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self._backTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialog._onTouchEnable))
        self._backTouchLayer:setTouchEnabled(true)

        self:getView():addChild(self._backTouchLayer,-1)
    end
end

function QUIDialog:_disableTouchSwallow()
    if self._backTouchLayer ~= nil then
        self._backTouchLayer:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
        self._backTouchLayer:setTouchEnabled(false)
        self._backTouchLayer:removeFromParent()
        self._backTouchLayer = nil
    end
end

--set back button enable
function QUIDialog:setBackBtnEnable(b )
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page ~= nil and page.setBackBtnEnable ~= nil then
        page:setBackBtnEnable(b)
    end
end

--add touch layer at top layer stop touch event
function QUIDialog:enableTouchSwallowTop()
    if(self:getView() == nil) then return end

    if self._topTouchLayer == nil then
        self._enable = false
        self._topTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
        self._topTouchLayer:setPosition(-display.width/2, -display.height/2)
        self._topTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
        self._topTouchLayer:setTouchEnabled(true)
        self:getView():addChild(self._topTouchLayer,10000)
    end
end

--remove touch layer at top layer stop touch event
function QUIDialog:disableTouchSwallowTop()
    if self._topTouchLayer ~= nil then
        self._enable = true
        self._topTouchLayer:setTouchEnabled(false)
        self._topTouchLayer:removeFromParent()
        self._topTouchLayer = nil
    end
end

function QUIDialog:_backClickHandler()
    
end

function QUIDialog:popSelf()
    app:getNavigationManager():popViewController(self:getOptions().layerIndex, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialog:popSelfAtNextFrame()
    self:enableTouchSwallowTop()
    self:getChildView():setVisible(false)
    scheduler.performWithDelayGlobal(function ()
        app:getNavigationManager():popViewController(self:getOptions().layerIndex, QNavigationController.POP_TOP_CONTROLLER)
    end, 0)
end

function QUIDialog:_onTouchEnable(event)
	if event.name == "began" then
		return true
    elseif event.name == "moved" then
        
    elseif event.name == "ended" then
        if self.isAnimation == true and self._isEffectPlay == true then
            return
        end
        local handler = scheduler.performWithDelayGlobal(self:safeHandler(function()
            self:_backClickHandler(event)
            end),0)
        table.insert(self.___handlers, handler)
    elseif event.name == "cancelled" then
        
	end
end

return QUIDialog