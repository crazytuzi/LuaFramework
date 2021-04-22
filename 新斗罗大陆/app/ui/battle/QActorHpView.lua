
local QActorHpView = class("QActorHpView", function()
    return display.newNode()
end)

local DEBUG_DISPLAY_HP_PERCENT_TEXT = false
local DEBUG_ALWAYS_DISPLAY = false

local QRectUiMask = import(".QRectUiMask")
local ScaleY = 0.85

function QActorHpView:ctor(actor, actorView)
    self._actor = actor
    self._actorView = actorView

    -- self._foreground = QRectUiMask.new()
    -- self._foreground:setAdditionalWidth(4)

    -- if actor:getType() == ACTOR_TYPES.HERO or actor:getType() == ACTOR_TYPES.HERO_NPC then
    --     self._background = CCSprite:create(global.ui_hp_background_hero)
    --     self._foreground:addChild(CCSprite:create(global.ui_hp_foreground_hero))
    -- else 
    --     self._background = CCSprite:create(global.ui_hp_background_npc)
    --     self._foreground:addChild(CCSprite:create(global.ui_hp_foreground_npc))
    -- end

    if actor:getType() == ACTOR_TYPES.HERO or actor:getType() == ACTOR_TYPES.HERO_NPC then
        self._background = CCSprite:create(global.ui_hp_background_hero)
        self._foreground = q.createHpBar(global.ui_hp_foreground_hero)
        self._foreground:setHeadPadding(4)
        self._background:setScaleY(ScaleY)
        self._foreground:setScaleY(ScaleY)
    else 
        self._background = CCSprite:create(global.ui_hp_background_npc)
        self._foreground = q.createHpBar(global.ui_hp_foreground_npc)
        self._foreground:setHeadPadding(4)
        self._background:setScaleY(ScaleY)
        self._foreground:setScaleY(ScaleY)
    end

    -- self._middleground = QRectUiMask.new()
    -- self._middleground:setAdditionalWidth(4)
    -- local redBar = CCSprite:create(global.ui_hp_background_tmp)
    -- self._middleground:addChild(redBar)

    self._middleground = q.createHpBar(global.ui_hp_background_tmp)
    self._middleground:setHeadPadding(4)
    self._middleground:setScaleY(ScaleY)

    self._absorbground = q.createHpBar(global.ui_hp_absorb)
    self._absorbground:setScaleY(ScaleY)

    self._hpLimit = q.createHpBarRevers(global.ui_hp_limit)
    self._hpLimit:setHeadPadding(4)
    self._hpLimit:setScaleY(ScaleY)

    self:addChild(self._background)
    self:addChild(self._middleground) -- 用于血条消退动画的中间层
    self:addChild(self._foreground)
    self:addChild(self._absorbground)
    self:addChild(self._hpLimit)

    -- 角色的初始血量可能不是满的
    local percent = actor:getHp() / actor:getMaxHp()
    self._middleground:update(percent)
    self._foreground:update(percent)
    -- 角色的初始护盾为0
    self._absorbPercent = 0
    self._absorbground:update(self._absorbPercent)
    self._hpLimit:update(1)

    if not DEBUG_ALWAYS_DISPLAY then
        self:setVisible(false)
    end

    self:setCascadeOpacityEnabled(true)
    self._foreground:setCascadeOpacityEnabled(true)
    self._middleground:setCascadeOpacityEnabled(true)
    self._hpLimit:setCascadeOpacityEnabled(true)

    -- 用于血条消退的动画
    self:setNodeEventEnabled(true)
    self._percent = percent

    if DEBUG_DISPLAY_HP_PERCENT_TEXT then
        self._percentLabel = CCLabelTTF:create("REPLAY", global.font_default, 25)
        self:addChild(self._percentLabel)
    end
end

function QActorHpView:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QActorHpView:onExit()
    self:unscheduleUpdate()
    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
end

function QActorHpView:_onFrame(dt)
    local actorView = self._actorView
    -- if actorView and actorView.getScale then
    --     self:setScale(1 / actorView:getScale())
    -- end

    if self._lastUpdate == nil then return end

    local speed = 2 -- 每秒消退血条的速度 1 = 100%
    local hang = 0.2 -- 在开始消退动画前停顿的时间

    local cur = self._lastPercent - (app.battle:getTime() - self._lastUpdate - 0.2) * speed 
    if cur > self._lastPercent then return end -- 尚在停顿期内

    if cur < self._percent then
        -- 已经消退到当前血条，停止动画
        cur = self._percent
        -- 重置时间等待下次掉血
        self._lastUpdate = nil
    end

    self._middleground:update(cur)
end

function QActorHpView:update(percent)
    percent = math.clamp(percent, 0, 1)
    self._foreground:update(percent)
    self._hpLimit:update(1 - self._actor:getRecoverHpLimit() / self._actor:getMaxHp())

    -- 记录上次更新的时间和当前的percent，用于血条消退的动画
    if self._lastUpdate == nil then
        self._lastUpdate = app.battle:getTime()
        self._lastPercent = self._percent
        self._middleground:update(self._percent)
    end

    self._percent = percent

    if self._fadeOutHandler ~= nil then
        scheduler.unscheduleGlobal(self._fadeOutHandler)
        self._fadeOutHandler = nil
    end

    self:stopAllActions()

    self._fadeOutHandler = scheduler.performWithDelayGlobal(function()
            self._fadeOutHandler = nil
            local node = tolua.cast(self, "CCNode")
            if node ~= nil then
            -- 如果关卡退出了，这里依然有可能执行到，因此需要校验node是否依然有效
                node:runAction(CCFadeOut:create(global.ui_hp_hide_fadeout_time))
            end
    end, global.ui_hp_hide_delay_time)

    self:setVisible(true)
    self:setOpacity(255)

    if DEBUG_DISPLAY_HP_PERCENT_TEXT then
        self._percentLabel:setString(string.format("%0.2f", percent))
    end
end

function QActorHpView:updateAbsorb(percent, hpMaxBefore)
    self._absorbPercent = self._absorbPercent + percent
    if hpMaxBefore then
        local totalAbsorb = hpMaxBefore * self._absorbPercent
        local newPercent = totalAbsorb / self._actor:getMaxHp()
        self._absorbPercent = newPercent
    end
    local showPercent = math.clamp(self._absorbPercent, 1.0, 0)

    self._absorbground:update(showPercent)

    if self._fadeOutHandler ~= nil then
        scheduler.unscheduleGlobal(self._fadeOutHandler)
        self._fadeOutHandler = nil
    end

    self:stopAllActions()

    self._fadeOutHandler = scheduler.performWithDelayGlobal(function()
            self._fadeOutHandler = nil
            local node = tolua.cast(self, "CCNode")
            if node ~= nil then
            -- 如果关卡退出了，这里依然有可能执行到，因此需要校验node是否依然有效
                node:runAction(CCFadeOut:create(global.ui_hp_hide_fadeout_time))
            end
    end, global.ui_hp_hide_delay_time)

    self:setVisible(true)
    self:setOpacity(255)
end

function QActorHpView:hide()
    if DEBUG_ALWAYS_DISPLAY then
        return
    end
    if self._fadeOutHandler then
        scheduler.unscheduleGlobal(self._fadeOutHandler)
        self._fadeOutHandler = nil
    end
    self:stopAllActions()
    self:setOpacity(0)
end

function QActorHpView:onCleanup()
    if self._fadeOutHandler then
        scheduler.unscheduleGlobal(self._fadeOutHandler)
        self._fadeOutHandler = nil
    end
    self:stopAllActions()
    self:unscheduleUpdate()
end

function QActorHpView:getAbsorbPercent()
    return self._absorbPercent
end

return QActorHpView