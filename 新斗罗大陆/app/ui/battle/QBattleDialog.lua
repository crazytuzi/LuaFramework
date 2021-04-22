
-- 战斗界面中的dialog的基类，主要完成暂停战斗，处理dialog的一些交互和显示
local QBattleDialog = class("QBattleDialog", function()
    return display.newNode()
end)

local QLayoutBase = import("..layout.QLayoutBase")

function QBattleDialog:ctor(ccbi, owner,callBacks)
    if app.battle ~= nil then
        app.battle:pause()
    end

    -- 创建遮罩层防止点击到dialog后面的东西
    self._overlay = CCLayerColor:create(ccc4(0, 0, 0, 128), display.width, display.height)
    self._overlay:setPosition(-display.width * 0.5, -display.height * 0.5)
    self._overlay:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._overlay:setTouchSwallowEnabled(true)
    self._overlay:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouchEnable))
    self._overlay:setTouchEnabled( true )

    self:addChild(self._overlay)


    local proxy = CCBProxy:create()
    if owner then
        owner["onOK"] = handler(self, QBattleDialog._onOK)
    else
        owner = {}
    end
    self._ccbOwner = owner;

    if callBacks then
        self:_setCCBOwnerValue(callBacks)
    end

    self._ccbNode = CCBuilderReaderLoad(ccbi, proxy, owner)
    self._ccbProxy = proxy;
    self:addChild(self._ccbNode)

    self:setPosition(display.cx, display.cy)
    if app.battle ~= nil then
        app.scene:addDialog(self)
    end
    if self._ccbOwner ~= nil and self._ccbOwner.layer_bj ~= nil then
        self._ccbOwner.layer_bj:setVisible(false)

        local bjSize = self._ccbOwner.layer_bj:getContentSize()
        local size = CCSize(bjSize.width * self._ccbOwner.layer_bj:getScaleX(), bjSize.height * self._ccbOwner.layer_bj:getScaleY())
        
        local config = nil
        if self._ccbOwner.ccb_bj ~= nil then
            self._ccbOwner.ccb_bj:setPosition(0, 0) -- 坐标置0，会根据layer_bj的坐标重新调整
            config = QLayoutBase.normalConfig
        elseif self._ccbOwner.ccb_bj_wide ~= nil then
            self._ccbOwner.ccb_bj_wide:setPosition(0, 0) -- 坐标置0，会根据layer_bj的坐标重新调整
            config = QLayoutBase.wideConfig
        end

        local pos = ccp( self._ccbOwner.layer_bj:getPosition() )
        local isIgnoreAnchorPointForPosition = self._ccbOwner.layer_bj:isIgnoreAnchorPointForPosition()
        if isIgnoreAnchorPointForPosition then
            pos =  ccp( pos.x + bjSize.width / 2, pos.y + bjSize.height / 2 )
        end

        self._ccbLayout = QLayoutBase.new( { displayOwner = self._ccbOwner, config = config } )
        self._ccbLayout:setObjectSize(size, pos)
    end
end

function QBattleDialog:close()
    self:removeSelf() 
    if app.battle ~= nil then
        app.battle:resume()
    end
end

function QBattleDialog:_onOK()
    if self.onOK then
        self.onOK()
    end
    self:close()
end

function QBattleDialog:_setCCBOwnerValue(callbacks)
    if callbacks == nil then
        return
    end

    for i, v in ipairs(callbacks) do
        local ccbCallbackName = v.ccbCallbackName
        local callback = v.callback
        if ccbCallbackName ~= nil and callback ~= nil then
            self._ccbOwner[ccbCallbackName] = callback
        end
    end
end

function QBattleDialog:_backClickHandler()
end

function QBattleDialog:_onTouchEnable(event)
    if event.name == "began" then
        return true
    elseif event.name == "moved" then
        
    elseif event.name == "ended" then
        scheduler.performWithDelayGlobal(function()
            if self._backClickHandler ~= nil then
                self:_backClickHandler()
            end
        end,0)
    elseif event.name == "cancelled" then
        
    end
end

function QBattleDialog:setOverlayOpacity(opacity)
    self._overlay:setOpacity(opacity)
end

return QBattleDialog