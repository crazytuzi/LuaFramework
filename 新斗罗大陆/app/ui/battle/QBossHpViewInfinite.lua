
local QBossHpViewInfinite = class("QBossHpViewInfinite", function()
    return display.newNode()
end)

local QRectUiMask = import(".QRectUiMask")
local QActor = import("...models.QActor")
local QUIWidgetHeroHeadStar = import("..widgets.QUIWidgetHeroHeadStar")

-- constants
local FADEOUT_DURATION = 0.5
local LAST_BAR_SPEED = 2.0
local HP_PER_LAYER = 1000
local LAYER_HSI = {
    {10, 0, 0},
    {-20, 0.75, 0},
    {-160, 0.3, 0},
    {168, 0.7, 0},
    {100, 0, 0},
}
local LAYER_COLOR = {}
for i, hsi in ipairs(LAYER_HSI) do
    local hue = (hsi[1] + 180) / 360 * 255
    local saturation = (hsi[2] + 1) / 2 * 255
    local intensity = (hsi[3] + 1) / 2 * 255
    LAYER_COLOR[i] = ccc3(hue,saturation, intensity)
end

local function createMask()
    local mask = QRectUiMask.new()
    local node = display.newNode()
    node:addChild(mask)
    function node:update2(...)
        mask:update2(...)
    end
    function node:update(...)
        mask:update(...)
    end
    function node:setFromLeftToRight(...)
        mask:setFromLeftToRight(...)
    end
    function node:getFromToPercent()
        return mask:getFromToPercent()
    end
    function node:addChild(...)
        mask:addChild(...)
    end
    return node
end

-- view and bar creator
local function createBar(bar_type, index)
    if bar_type == "main" then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Fighting.plist")
        local sprite = createSpriteWithSpriteFrame("Boss_xuetiao.png")
        sprite:setShaderProgram(qShader.Q_ProgramPositionTextureHSI)
        sprite:setColor(LAYER_COLOR[(index - 1) % 5 + 1])
        sprite:setScaleX(1)
        sprite:setScaleY(1)
        local bar = createMask()
        bar:setFromLeftToRight(false)
        bar:addChild(sprite)
        function bar:updatePercent(percent)
            self:update2(0, percent)
        end
        function bar:setPercent(percent)
            self:update(percent)
        end
        bar:setPositionX(bar:getPositionX() + 15)
        return bar
    elseif bar_type == "anim" then
        local node = display.newNode()
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Fighting.plist")
        local sprite = createSpriteWithSpriteFrame("Boss_xuetiao.png")
        sprite:setShaderProgram(qShader.Q_ProgramPositionTextureHSI)
        sprite:setColor(LAYER_COLOR[(index - 1) % 5 + 1])
        sprite:setScaleX(1)
        sprite:setScaleY(1)
        node:addChild(sprite)
        local layer = CCLayerColor:create(ccc4(255, 255, 255, 0), sprite:getContentSize().width, sprite:getContentSize().height)
        layer:setPosition(-sprite:getContentSize().width/2, -sprite:getContentSize().height/2)
        layer:setScaleX(1)
        layer:setScaleY(1)
        layer:setCascadeBoundingBox(CCRect(0, 0, 0, 0))
        node:addChild(layer)
        local bar = createMask()
        bar:setFromLeftToRight(false)
        bar:addChild(node)
        function bar:play(from_percent, to_percent, duration, wait_time)
            if self._playingAnimation == true then
                return
            end
            self._playingAnimation = true
            self:setVisible(true)
            self:update2(from_percent, to_percent)

            local arr = CCArray:create()
            if wait_time > 0 then
                arr:addObject(CCDelayTime:create(wait_time))
            end
            arr:addObject(CCFadeTo:create(duration / 2, 96))
            arr:addObject(CCCallFunc:create(function() 
                sprite:setVisible(false) 
            end))
            arr:addObject(CCFadeTo:create(duration / 2, 0))
            arr:addObject(CCCallFunc:create(function() 
                self._playingAnimation = nil 
                self:setVisible(false)
            end))
            layer:runAction(CCSequence:create(arr))
        end
        function bar:isPlaying()
            return self._playingAnimation
        end
        function bar:stop()
            layer:stopAllActions()
            self._playingAnimation = nil
            self:setVisible(false)
        end
        bar:setPositionX(bar:getPositionX() + 15)
        return bar
    end
end

local function createHpViewController(hp_per_layer, bar_create_func)
    local root_node = display.newNode()
    root_node:retain()
    local layer_nodes = {}
    local main_bar_by_layer = {}
    local anim_bars_by_layer = {}
    local controller = {}
    local current_hp = 0

    local function _layerNode(index)
        local node = layer_nodes[index]
        return node
    end

    for i = 0, 5 ,1 do
        local index = i
        if i == 0 then index = 5 end
        local node = display.newNode()
        root_node:addChild(node, i)
        layer_nodes[i] = node

        local main_bar = bar_create_func("main", index)
        node:addChild(main_bar, 0)
        main_bar_by_layer[i] = main_bar
        if i == 0 then
            main_bar:updatePercent(1)
        end
    end

    local function _next(value, value_limit, value_per_layer, dir)
        local tmp1 = value / value_per_layer
        local limit1, limit2 = math.floor(tostring(tmp1)), math.ceil(tostring(tmp1))
        -- print(tmp1, limit1, limit2)
        limit2 = (limit1 == limit2) and (limit2 + dir) or limit2
        local tmp2 = math.clamp(tmp1 + dir, limit1, limit2)

        local next_value = math.clamp(tmp2 * value_per_layer, value, value_limit)
        local to_percent = (next_value / value_per_layer) - math.floor(tonumber(next_value / value_per_layer))
        local from_percent = tmp1 - math.floor(tonumber(tmp1))
        if dir > 0 and to_percent == 0 then
            to_percent = 1
        elseif dir < 0 and from_percent == 0 then
            from_percent = 1
        end
        return next_value, from_percent, to_percent, math.floor(tonumber(tmp1 - from_percent)) + 1
    end

    function controller:_updateMainBar(index, to_percent)
        index = index % 5 + 1
        local main_bar = main_bar_by_layer[index]
        for i, bar in ipairs(main_bar_by_layer) do
            if i ~= 0 then
                if i > index then bar:updatePercent(0)
                elseif i < index then bar:updatePercent(1) end
            end
        end
        main_bar:updatePercent(to_percent)
    end

    function controller:_addAnimBar(index, from_percent, to_percent, division, order)
        index = index % 5 + 1
        local anim_bars = anim_bars_by_layer[index]
        if anim_bars == nil then
            anim_bars = {}
            anim_bars_by_layer[index] = anim_bars
        end
        local anim_bar = bar_create_func("anim", index)
        table.insert(anim_bars, anim_bar)
        _layerNode(index):addChild(anim_bar, 1)
        anim_bar:play(from_percent, to_percent, FADEOUT_DURATION / division, (order - 1) * FADEOUT_DURATION / division)
    end

    function controller:getRootNode()
        return root_node
    end

    function controller:onChangeHP(new_hp, no_animation)
        local old_hp = current_hp

        if new_hp == old_hp then
            return
        end

        local dir = (new_hp - old_hp) / math.abs(new_hp - old_hp)
        local cur_hp = old_hp
        local anim_zones = {}
        while true do
            -- calculate zone
            local from_percent, to_percent, layer_index
            cur_hp, from_percent, to_percent, layer_index = _next(cur_hp, new_hp, hp_per_layer, dir)
            -- update main bar
            if no_animation or layer_index > 1 then
                self:_updateMainBar(layer_index, to_percent)
            end
            -- create animation bar
            if not no_animation and layer_index > 1 then
                table.insert(anim_zones, {layer_index, from_percent, to_percent})
            end
            if cur_hp == new_hp then
                break
            end
        end
        -- for order, obj in ipairs(anim_zones) do
        --     self:_addAnimBar(obj[1], obj[2], obj[3], #anim_zones, order)
        -- end

        current_hp = new_hp

        -- performance polish
        local top_index = 0
        for index, main_bar in pairs(main_bar_by_layer) do
            local _, to_percent = main_bar:getFromToPercent()
            if to_percent ~= 0 then
                top_index = index
            end
        end
        for index, main_bar in pairs(main_bar_by_layer) do
            if index <= top_index - 2 then
                main_bar:setVisible(false)
            elseif index <= top_index then
                main_bar:setVisible(true)
                -- main_bar:setVisible(false)
            else
                main_bar:setVisible(false)
            end
        end
    end

    function controller:update(dt, hp)
        self:removeUnuseNode()

        -- update last main bar
        -- local main_bar1 = main_bar_by_layer[cur_index]
        -- if main_bar1 then
        --     local anim_bars2 = anim_bars_by_layer[2]
        --     if anim_bars2 == nil or next(anim_bars2) == nil then
        --         local from, to = main_bar1:getFromToPercent()
        --         local cur = math.min(hp / hp_per_layer, 1.0)
        --         local dto = cur - to
        --         if dto ~= 0 then
        --             local dir = dto / math.abs(dto)
        --             local new_to = to + dir * dt * LAST_BAR_SPEED
        --             new_to = math.clamp(new_to, to, cur)
        --             main_bar1:updatePercent(new_to)
        --             -- print("controller:update",from, to, cur_index, self:getLayerCount(), cur, dto, new_to)
        --         end
        --     end
        -- end
    end

    function controller:removeUnuseNode()
        for _, obj in pairs(anim_bars_by_layer) do
            for index, bar in pairs(obj) do
                if not bar:isPlaying() then
                    bar:removeFromParent()
                    obj[index] = nil
                end
            end
        end
        -- for index, bar in pairs(main_bar_by_layer) do
        --     local _, to_percent = bar:getFromToPercent()
        --     if to_percent == 0 then
        --         bar:removeFromParent()
        --         main_bar_by_layer[index] = nil
        --     end
        -- end
        -- for index, node in pairs(layer_nodes) do
        --     if node:getChildrenCount() == 0 then
        --         node:removeFromParent()
        --         layer_nodes[index] = nil
        --     end
        -- end
    end

    function controller:stopAllAnimation()
        for _, obj in pairs(anim_bars_by_layer) do
            for index, bar in pairs(obj) do
                bar:stop()
                bar:removeFromParent()
                obj[index] = nil
            end
        end
    end

    function controller:dispose()
        for _, obj in pairs(anim_bars_by_layer) do
            for index, bar in pairs(obj) do
                bar:stop()
                bar:removeFromParent()
                obj[index] = nil
            end
        end

        for index, bar in pairs(main_bar_by_layer) do
            bar:removeFromParent()
            main_bar_by_layer[index] = nil
        end

        root_node:release()
    end

    function controller:setHPPerLayer(value)
        hp_per_layer = value
    end

    function controller:getLayerCount()
        do
            local count, flo = math.modf(current_hp / hp_per_layer)
            if flo ~= 0 then
                count = count + 1
            end
            return count
        end

        local top_index = 0
        for index, main_bar in pairs(main_bar_by_layer) do
            local _, to_percent = main_bar:getFromToPercent()
            if to_percent ~= 0 then
                top_index = index
            end
        end

        return top_index
    end

    return controller
end

function QBossHpViewInfinite:ctor()
    local proxy = CCBProxy:create()
    self._owner = {}

    local node = CCBuilderReaderLoad("ccb/Battle_Widget_BossHealth.ccbi", proxy, self._owner)
    self:addChild(node)

    --setShadow5(self._owner.label_name, ccc3(0, 0, 0))

    -- self._foreground = QRectUiMask.new()
    -- self._foreground:setFromLeftToRight(false)
    -- local hpForeground = self._owner.Sprite_BossHealthFG
    -- local positionX, positionY = hpForeground:getPosition()
    -- hpForeground:retain()
    -- hpForeground:removeFromParent()
    -- self._foreground:addChild(hpForeground)
    -- self._foreground:setPosition(positionX, positionY)
    -- hpForeground:setPosition(0.0, 0.0)
    -- hpForeground:release()

    -- self._background = QRectUiMask.new()
    -- self._background:setFromLeftToRight(false)
    -- local hpBackground = self._owner.Sprite_BossHealthBG  
    -- local positionX, positionY = hpBackground:getPosition()  
    -- hpBackground:retain()
    -- hpBackground:removeFromParent()
    -- self._background:addChild(hpBackground)
    -- self._background:setPosition(positionX, positionY)
    -- hpBackground:setPosition(0.0, 0.0)
    -- hpBackground:release()

    -- self._owner.Node_BossHealth:addChild(self._background) -- 用于血条消退动画的中间层
    -- self._owner.Node_BossHealth:addChild(self._foreground) 

    self._owner.Sprite_BossHealthBG:setVisible(false)
    self._owner.Sprite_BossHealthFG:setVisible(false)

    self:setNodeEventEnabled(true)
    -- 用于血条消退的动画

    self._barController = createHpViewController(HP_PER_LAYER, createBar)
    self._barController:getRootNode():setPositionX(-14)
    self._owner.Node_BossHealth:addChild(self._barController:getRootNode())
end

function QBossHpViewInfinite:onEnter()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self._onFrame))
    self:scheduleUpdate_()
end

function QBossHpViewInfinite:onExit()
    if self._actor ~= nil and self._actorEventProxy ~= nil then
        self._actorEventProxy:removeEventListener(QActor.HP_CHANGED_EVENT, self._onHpChanged, self)
    end

    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
    self:unscheduleUpdate()
    if self._actorEventProxy ~= nil then
        self._actorEventProxy:removeAllEventListeners()
    end

    if self._barController then
        self._barController:dispose()
        self._barController = nil
    end
end

function QBossHpViewInfinite:setStar(star)
    if self._starWidget == nil then
        self._starWidget = QUIWidgetHeroHeadStar.new()
        self._starWidget:setScale(0.6)
        self._owner.star:addChild(self._starWidget)
    end
    self._starWidget:setStar(star)
    -- local _owner = self._owner
    -- _owner.nodeSmallStar1:setVisible(star == 1)
    -- _owner.nodeSmallStar2:setVisible(star == 2)
    -- _owner.nodeSmallStar3:setVisible(star == 3)
    -- _owner.nodeSmallStar4:setVisible(star == 4)
    -- _owner.nodeSmallStar5:setVisible(star == 5)
    -- _owner.nodeBigStar:setVisible(star>5)
    -- if star > 5 then
    --     _owner.starNum:setString(tostring(star))
    -- end
end

function QBossHpViewInfinite:setName(name)
    self._owner.label_name:setString(name)
end

function QBossHpViewInfinite:setLevel(level)
    self._owner.label_level:setString(tostring(level))
end

function QBossHpViewInfinite:setBreakthrough(breakthrough)
    local breakthroughLevel,color = remote.herosUtil:getBreakThrough(breakthrough)
    local cccolor = BREAKTHROUGH_COLOR_LIGHT[color]
    if cccolor then
        self._owner.label_name:setColor(cccolor)
    end
end

function QBossHpViewInfinite:setActor(actor)

    if self._actor ~= nil and self._actorEventProxy ~= nil then
        self._actorEventProxy:removeAllEventListeners()
    end

    self._actor = actor
    if actor ~= nil then
        self._hp = actor:getHp()

        if app.battle then
            local max_layer
            if app.battle:isInRebelFight() then
                max_layer = 30
            else
                max_layer = 1200
            end
            local hpPerLayer = self._hpPerLayer or 1000
            hpPerLayer = math.max(hpPerLayer, 1)
            local maxHp = actor:getMaxHp()
            while maxHp / hpPerLayer > max_layer do
                hpPerLayer = hpPerLayer * 2
            end
            self:setHPPerLayer(hpPerLayer)
        end

        self._owner.Sprite_BossIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(self._actor:getIcon()))
        self:updateHpBar(actor:getHp(), true)
        if self._actorEventProxy then
            self._actorEventProxy:removeEventListener(QActor.HP_CHANGED_EVENT, self._onHpChanged, self)
            self._actorEventProxy = nil
        end
        self._actorEventProxy = cc.EventProxy.new(self._actor)
        self._actorEventProxy:addEventListener(QActor.HP_CHANGED_EVENT, handler(self, self._onHpChanged))

        self:setStar(actor:getGradeValue() + 1)
        self:setName(actor:getDisplayTitleName())
        self:setLevel(actor:getDisplayLevel())
        if app.battle:isInRebelFight() then
            local invasion = app.battle:getDungeonConfig().invasion
            if invasion.boss_type == 1 then
                self:setBreakthrough(1) -- green
            elseif invasion.boss_type == 2 then
                self:setBreakthrough(6) -- blue
            elseif invasion.boss_type == 4 then
                self:setBreakthrough(13) -- orange
            else
                self:setBreakthrough(11)-- purple
            end
        elseif app.battle:isInSocietyDungeon() then
            self:setBreakthrough(11) -- union boss is always purple in breakthrough color
        elseif  app.battle:isInWorldBoss() then
            self:setBreakthrough(11)
        else
            self:setBreakthrough(actor:getBreakthroughValue())
        end
        self._maxLayerCount = self:getLayerCount()
    else
        if self._actorEventProxy then
            self._actorEventProxy:removeEventListener(QActor.HP_CHANGED_EVENT, self._onHpChanged, self)
            self._actorEventProxy = nil
        end
        self._hp = 0
    end
end

function QBossHpViewInfinite:setHPPerLayer(value)
    if type(value) == "number" and value > 0 then
        self._barController:setHPPerLayer(value)
        self._hpPerLayer = value
    end
end

function QBossHpViewInfinite:getActor()
    return self._actor
end

function QBossHpViewInfinite:_onFrame(dt)
    if self._actor then
        self._barController:update(dt, self._hp)
                                         -- 注意这个不是ASCII的x，小心！！！
        self._owner.label_count:setString("×" .. tostring(self._barController:getLayerCount()))
    end
end

function QBossHpViewInfinite:_onHpChanged(event)
    self:updateHpBar()
    if self._actor then
        self._hp = self._actor:getHp()
    end
end

function QBossHpViewInfinite:updateHpBar(no_animation)
    if self._actor and app.battle and not app.battle:isBattleEnded() then
        self._barController:onChangeHP(self._actor:getHp(), no_animation)
        if no_animation then
            self._owner.label_count:setString("×" .. tostring(self._barController:getLayerCount()))
        end
    end
end

function QBossHpViewInfinite:getMaxLayerCount()
    if self._maxLayerCount then
        return self._maxLayerCount
    end
end

function QBossHpViewInfinite:getLayerCount()
    return self._barController:getLayerCount()
end

function QBossHpViewInfinite:getHpPerLayer()
    return self._hpPerLayer
end

function QBossHpViewInfinite:setIsEliteBoss(isEliteBoss)
    isEliteBoss = isEliteBoss and true or false
    self._owner.Sprite_dragon:setVisible(not isEliteBoss)
    self._owner.elite_dragon:setVisible(isEliteBoss)
    self._owner.elite_cricle:setVisible(isEliteBoss)
end

return QBossHpViewInfinite