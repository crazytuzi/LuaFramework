
local QTouchController = class("QTouchController", function()
    return display.newNode()
end)

local QBaseActorView = import("..views.QBaseActorView")
local QTouchActorView = import("..views.QTouchActorView")
local QBaseEffectView = import("..views.QBaseEffectView")
local QNotificationCenter = import(".QNotificationCenter")
local QBattleManager = import(".QBattleManager")

QTouchController.EVENT_TOUCH_END_FOR_SELECT = "EVENT_TOUCH_END_FOR_SELECT"
QTouchController.EVENT_TOUCH_END_FOR_MOVE = "EVENT_TOUCH_END_FOR_MOVE"
QTouchController.EVENT_TOUCH_END_FOR_ATTACK = "EVENT_TOUCH_END_FOR_ATTACK"

QTouchController.FLASH_EFFECT_FILE = "cricle_1_1"

function QTouchController:ctor( option )
    self._circle = CCSprite:create(global.ui_drag_line_green_circle1)
    self._circle:setScaleX(0.5)
    self._circle:setScaleY(0.25)
    self:addChild(self._circle)
    self._circle:setVisible(false)

    self._flashEffect = QBaseEffectView.new(QTouchController.FLASH_EFFECT_FILE, nil)
    self:addChild(self._flashEffect, -2)
    self._flashEffect:setVisible(false)

    self._touchEpsilon = 5.0

    self:setNodeEventEnabled(true)
end

function QTouchController:onEnter()
    self:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    -- self:setCascadeBoundingBox(CCRect(BATTLE_AREA.left, BATTLE_AREA.bottom, BATTLE_AREA.width, BATTLE_AREA.height))
    self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

function QTouchController:registerEvent()
    self:setNodeEventEnabled(true)
    self:setCascadeBoundingBox(CCRect(0.0, 0.0, display.width, display.height))
    self:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch))
end

function QTouchController:onExit()
    self:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
end

function QTouchController:enableTouchEvent()
    self._disableSelfAndNoticeDrag = false
    self._selectActorView = nil
    self._selectActorViewTemp = nil
    self._selectTempIsEnemy = false
    self._heroViews = nil
    self._enemyViews = nil

    self:setTouchEnabled( true )

    self._eventProxy = cc.EventProxy.new(app.battle)
    self._eventProxy:addEventListener(QBattleManager.HERO_CLEANUP, handler(self, self._onHeroCleanup))
end

function QTouchController:disableTouchEvent()
    self._selectActorView = nil
    self._selectActorViewTemp = nil
    self._heroViews = nil
    self._enemyViews = nil

    self:setTouchEnabled( false )

    if self._eventProxy ~= nil then
        self._eventProxy:removeAllEventListeners()
        self._eventProxy = nil
    end
end

function QTouchController:_onHeroCleanup(event)
    if self._selectActorView ~= nil then
        if not self._selectActorView.getModel then
            self._selectActorView = nil
        elseif self._selectActorView:getModel() == event.hero then
            self._selectActorView = nil
        end
    end 
end

function QTouchController:setSelectActorView(actorView)
    if self._selectActorView ~= actorView then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTouchController.EVENT_TOUCH_END_FOR_SELECT, oldSelectView = self._selectActorView, newSelectView = actorView})
        self._selectActorView = actorView
    end
end

function QTouchController:getSelectActorView()
    return self._selectActorView
end

function QTouchController:onTouch(event)
    local allow, warning = app.battle:isAllowControl()
    if not allow then
        app.tip:floatTip(warning)
        return
    end

    local resolutionDY = app.scene:getGapHeight()
    event.y = event.y - resolutionDY

    local scale = BATTLE_SCREEN_WIDTH / UI_DESIGN_WIDTH
    if event.x ~= nil then
        event.x = event.x * scale
    end
    if event.y ~= nil then
        event.y = event.y * scale
    end
    
    local gapWidth = app.scene:getGapWidth()
    event.x = event.x - gapWidth * 0.5

    if event.name == "began" then
        return self:onTouchBegin(event.name, event.x, event.y)
    elseif event.name == "moved" then
        self:onTouchMoved(event.name, event.x, event.y)
    elseif event.name == "ended" then
        self:onTouchEnd(event.name, event.x, event.y)
    elseif event.name == "cancelled" then
        self:onTouchEnd(event.name, event.x, event.y)
    end
end

local function ghost_func(ghost)
    return ghost.actor and ghost.actor:isAttackedGhost() and not ghost.actor:isCopyHero()
end

local function ghost_get_func(ghost)
    return ghost.actor
end

local function createCache(tab)
    local t = {}
    for i,v in ipairs(tab) do
        t[v] = true
    end
    return t
end

function QTouchController:onTouchBegin( event, x, y )
    self._heroViews = app.scene:getHeroViews()
    self._enemyViews = app.scene:getEnemyViews()
    
    local actorViews = {}
    local heroes = {}
    table.mergeForArray(heroes, app.battle:getHeroes())
    table.mergeForArray(heroes, app.battle:getHeroGhosts(), ghost_func, ghost_get_func)
    local hero_cache = createCache(heroes)

    for i, view in ipairs(self._heroViews) do
        if view:getModel():isControlNPC() then
            table.insert(actorViews, view)
        else
            if hero_cache[view:getModel()] then
                table.insert(actorViews, view)
            end
        end
    end

    local enemies = {}
    table.mergeForArray(enemies, app.battle:getEnemies())
    table.mergeForArray(enemies, app.battle:getEnemyGhosts(), ghost_func, ghost_get_func)
    local enemy_cache = createCache(enemies)
    for i, view in ipairs(self._enemyViews) do
        if enemy_cache[view:getModel()] then
            table.insert(actorViews, view)
        end
    end

    local sortedActorView = q.sortNodeZOrder(actorViews, true)
    self._selectActorViewTemp = QBattle.getTouchingActor(sortedActorView, x, y)

    -- 检查是否点击到了QHeroStatusView的头像
    -- if not self._selectActorViewTemp then
    --     local wpos = self:convertToWorldSpace(ccp(x, y))
    --     for index, view in ipairs(app.scene._heroStatusViews) do
    --         local nodeskill = view._ccbOwner.node_skill1
    --         local nodepos = {x = nodeskill:getPositionX(), y = nodeskill:getPositionY()}
    --         local lpos = nodeskill:getParent():convertToNodeSpace(wpos)
    --         local touchRect = CCRectMake(nodepos.x - 50 - 150, nodepos.y - 50, 100, 100)
    --         if touchRect:containsPoint(ccp(lpos.x, lpos.y)) then
    --             self._selectActorViewTemp = app.scene:getActorViewFromModel(view:getActor())
    --             break
    --         end
    --     end
    -- end

    self._selectTempIsEnemy = false
    if self._selectActorViewTemp ~= nil then
        for i, view in ipairs(self._enemyViews) do
            if self._selectActorViewTemp == view then
                self._selectTempIsEnemy = true
                break
            end
        end
    else
        if self._selectActorView ~= nil then
            self._circle:setPosition(ccp(x, y))
            self._circle:setVisible(true)
        end
    end
    
    self._disableSelfAndNoticeDrag = false

    self._beginPointX = x
    self._beginPointY = y

    return true
end

function QTouchController:onTouchMoved( event, x, y )
    if self._disableSelfAndNoticeDrag == false then
        if math.abs(self._beginPointX - x) < self._touchEpsilon and math.abs(self._beginPointY - y) < self._touchEpsilon then
            return
        end
    end

    if self._selectActorViewTemp ~= nil then
        self._circle:setVisible(false)
        self._disableSelfAndNoticeDrag = true
        return
    end

    if self._selectActorView == nil or self._selectActorView.onTouchMoved == nil then
        return
    end

    if self._disableSelfAndNoticeDrag == false then
        self._circle:setVisible(false)
        self._disableSelfAndNoticeDrag = true
        local posX, posY = self._selectActorView:getPosition()
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTouchActorView.EVENT_ACTOR_TOUCHED_BEGIN, actorView = self._selectActorView, positionX = posX, positionY = posY})
    end

    self._selectActorView:onTouchMoved(event, x, y)

end

function QTouchController:onTouchEnd( event, x, y )
    self._touch_end = true

    self._circle:setVisible(false)

    if self._disableSelfAndNoticeDrag == true then
        if self._selectActorView ~= nil and self._selectActorView.onTouchEnd ~= nil then
            self._selectActorView:onTouchEnd(event, x, y)
        end
        self._selectActorViewTemp = nil
        return
    end

    if self._selectActorViewTemp == nil then
        -- 检查是否点到了符文(trap)
        local isClickOnRune = false
        for _, view in ipairs(app.scene:getEffectViews()) do
            if view.isTouchMoveOnMe and view:isTouchMoveOnMe(x, y) then
                isClickOnRune = true
            break
            end
        end
        -- touch and move
        if self._selectActorView ~= nil and not isClickOnRune then
            self:_flashMoveEffect(ccp(x, y))
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTouchController.EVENT_TOUCH_END_FOR_MOVE, heroView = self._selectActorView, positionX = x, positionY = y})
        end
        return
    end

    local actorViews = {}
    for i, view in ipairs(self._heroViews) do
        table.insert(actorViews, view)
    end

    for i, view in ipairs(self._enemyViews) do
        table.insert(actorViews, view)
    end

    local sortedActorView = q.sortNodeZOrder(actorViews, true)
    local selectActorView = QBattle.getTouchingActor(sortedActorView, x, y)

    -- 检查是否点击到了QHeroStatusView的头像
    -- if not selectActorView then
    --     local wpos = self:convertToWorldSpace(ccp(x, y))
    --     for index, view in ipairs(app.scene._heroStatusViews) do
    --         local nodeskill = view._ccbOwner.node_skill1
    --         local nodepos = {x = nodeskill:getPositionX(), y = nodeskill:getPositionY()}
    --         local lpos = nodeskill:getParent():convertToNodeSpace(wpos)
    --         local touchRect = CCRectMake(nodepos.x - 50 - 150, nodepos.y - 50, 100, 100)
    --         if touchRect:containsPoint(ccp(lpos.x, lpos.y)) then
    --             selectActorView = app.scene:getActorViewFromModel(view:getActor())
    --             break
    --         end
    --     end
    -- end

    if selectActorView ~= self._selectActorViewTemp then
        return
    end

    if self._selectActorView ~= nil then
        for i, view in ipairs(self._heroViews) do
            if view == self._selectActorViewTemp then
                -- select hero
                self:setSelectActorView(self._selectActorViewTemp)
                self._selectActorViewTemp = nil
                break
            end
        end
        if self._selectActorViewTemp ~= nil then
            for i, view in ipairs(self._enemyViews) do
                if view == self._selectActorViewTemp then
                    -- attack touched enemy
                    for i, view in ipairs(self._heroViews) do
                        if view:getModel():isHealth() == false and not view:getModel():isIdleSupport() then
                           QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTouchController.EVENT_TOUCH_END_FOR_ATTACK, heroView = view, targetView = self._selectActorViewTemp, is_focus = true})
                        end
                    end
                    self._selectActorViewTemp:invisibleSelectCircle(QBaseActorView.TARGET_CIRCLE)
                    self._selectActorViewTemp:getModel():onMarked()
                    self._selectActorViewTemp = nil
                else
                    view:getModel():onUnMarked()
                end
            end
        end
    else
        if self._selectTempIsEnemy == true then
            for i, view in ipairs(self._heroViews) do
                if view:getModel():isHealth() == false and not view:getModel():isIdleSupport() then
                    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTouchController.EVENT_TOUCH_END_FOR_ATTACK, heroView = view, targetView = self._selectActorViewTemp, is_focus = true})
                end
            end
            self._selectActorViewTemp:invisibleSelectCircle(QBaseActorView.TARGET_CIRCLE)
            self._selectActorViewTemp:getModel():onMarked()
            for i, view in ipairs(self._enemyViews) do
                if view ~= self._selectActorViewTemp then
                    view:getModel():onUnMarked()
                end
            end
        else
            self:setSelectActorView(self._selectActorViewTemp)
        end
        self._selectActorViewTemp = nil
    end
    
end

function QTouchController:_flashMoveEffect(position)
    self._flashEffect:setVisible(true)
    self._flashEffect:setPosition(position)
    self._flashEffect:playAnimation(self._flashEffect:getPlayAnimationName())
    self._flashEffect:afterAnimationComplete(function()
        self._flashEffect:setVisible(false)
    end)
end

function QTouchController:isTouchEnded()
    local result = self._touch_end
    self._touch_end = nil
    return result
end

return QTouchController
