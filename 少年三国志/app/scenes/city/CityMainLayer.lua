-- CityMainLayer
-- 领地大地图界面

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
    
end

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)
    
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(position, item)

        -- print("position.x: "..position.x.." position.y: "..position.y)

        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)

    end
    
    if align == ALIGN_CENTER then

        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])

        end
        
    elseif align == ALIGN_LEFT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x + _width, 0), items[index])

        end
        
    elseif align == ALIGN_RIGHT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth + _width, 0), items[index])

        end

    else
        
        assert(false, "Now we don't support other align type :"..align)
        
    end

end

local EffectNode = require "app.common.effects.EffectNode"

local CityMainLayer = class("CityMainLayer", UFCCSNormalLayer)

function CityMainLayer.create(...)
    return CityMainLayer.new("ui_layout/city_MainLayer.json", nil, ...)
end

function CityMainLayer:ctor(_, _, cityIndex)
    
    CityMainLayer.super.ctor(self)
    
    self._countdownHandler = {}
    
    self:initData(cityIndex)
end

function CityMainLayer:initData(cityIndex)
    
    self._cityIndex = cityIndex or self._cityIndex
    
end

function CityMainLayer:getCityIndex() return self._index end

function CityMainLayer:_clearTimer()
    if self._countdownHandler then
        for k, handler in pairs(self._countdownHandler) do
            G_GlobalFunc.removeTimer(handler)
        end
    end
    
    self._countdownHandler = {}
end

function CityMainLayer:onLayerLoad()
    local cityNum = #G_Me.cityData:getCityList()
    for i = 1, cityNum do
        self:enableLabelStroke("Label_level" .. i, Colors.strokeBrown, 1)
    end
end

function CityMainLayer:onLayerEnter()
    
    -- 注意，这里不再每次进入主界面就请求数据，而是采用缓存起来的数据
    -- 请求领地数据
--    G_HandlersManager.cityHandler:sendCityInfo(self._cityIndex)
    
    self:_initCityMainLayer()
    
    -- 收到消息则更新界面
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_INFO, function()
        self:_initCityMainLayer()
    end, self)
    
end

function CityMainLayer:onLayerExit()
    
    self:_clearTimer()
    
    uf_eventManager:removeListenerWithTarget(self)
    
end

function CityMainLayer:_initCityMainLayer(cityIndex)
    
    -- 更新城池状态
    local cityData = G_Me.cityData
    
    local cities = cityIndex and {cityData:getCityByIndex(cityIndex)} or cityData:getCityList()

    for i=1, #cities do
                
        local city = cities[i]
        
        if self._countdownHandler[city.id] then
            G_GlobalFunc.removeTimer(self._countdownHandler[city.id])
            self._countdownHandler[city.id] = nil
        end
        
        -- 清空领地火焰等特效
        local cityBtn = self:getButtonByName("Button_city"..city.id)
        cityBtn:removeAllNodes()

        -- 领地技能的等级
        self:showWidgetByName("Image_level_bg" .. city.id, city.level > 0)
        if city.level > 0 then
            self:showTextWithLabel("Label_level" .. city.id, tostring(city.level))
        end
        G_GlobalFunc.centerContent(self:getPanelByName("Panel_name" .. city.id))
        
        -- 是否达到开启
        if city.isLock then
            _updateImageView(self, "Image_lock"..city.id, {visible=true})
            G_GlobalFunc.setDark(cityBtn, true)
            _updateImageView(self, "Image_city_state"..city.id, {visible=false})
            _updateImageView(self, "Image_bubble"..city.id, {visible=false})
            _updateLabel(self, "Label_countdown"..city.id, {visible=false})
        else
            if not cityData:isMyCity() then

                if city.state == cityData.CITY_NEED_ATTACK or city.state == cityData.CITY_NEED_PATROL or city.state == cityData.CITY_HARVEST then
                    _updateImageView(self, "Image_lock"..city.id, {visible=false})
                    G_GlobalFunc.setDark(cityBtn, false)
                    _updateImageView(self, "Image_city_state"..city.id, {visible=false})
                    _updateImageView(self, "Image_bubble"..city.id, {visible=false})
                    _updateLabel(self, "Label_countdown"..city.id, {visible=false})

                elseif city.state == cityData.CITY_PATROLLING or city.state == cityData.CITY_RIOT then
                    
                    _updateImageView(self, "Image_lock"..city.id, {visible=false})
                    G_GlobalFunc.setDark(cityBtn, false)
                    
                    if city.state == cityData.CITY_RIOT then
                        _updateImageView(self, "Image_city_state"..city.id, {visible=true, texture=G_Path.getCityStatePathWithState(city.state)})
                        _updateImageView(self, "Image_bubble"..city.id, {visible=true})
                        _updateImageView(self, "Image_bubble_desc"..city.id, {texture=G_Path.getCityStateBubblePathWithState(city.state)})
                        _updateLabel(self, "Label_countdown"..city.id, {visible=true})
                        
                        -- 气泡动画
                        local bubble = self:getImageViewByName("Image_bubble"..city.id)
                        bubble:stopAllActions()
                        bubble:setScale(0.38)
                        bubble:setPosition(ccp(0, 0))
                        bubble:runAction(CCSequence:createWithTwoActions(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)), CCCallFunc:create(function()
                            bubble:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.4, ccp(0, 5)), CCMoveBy:create(0.4, ccp(0, -5)))))
                        end)))
                        
                        -- 城池火焰
                        local EffectNode = require "app.common.effects.EffectNode"
                        local effect = EffectNode.new("effect_city_riot_fire")
                        cityBtn:addNode(effect)
                        effect:setPositionX(-15)
                        effect:play()
                        
                    else
                        _updateImageView(self, "Image_city_state"..city.id, {visible=false})
                        _updateImageView(self, "Image_bubble"..city.id, {visible=false})
                        _updateLabel(self, "Label_countdown"..city.id, {visible=true})
                    end
                    
                    if city.patrol_time > 0 then
                    
                        local countdown = city.patrol_time
                        _updateLabel(self, "Label_countdown"..city.id, {visible=true, text=G_ServerTime:secondToString(countdown), stroke=Colors.strokeBlack})
                        
                        local delay = 0
                        self._countdownHandler[city.id] = G_GlobalFunc.addTimer(1, function(dt)
                            delay = delay + dt
                            -- 时间到，更新数据
                            if countdown - math.floor(delay) <= 0 then
                                self:_initCityMainLayer(city.id)
                            -- 发生暴动
                            elseif city.state == cityData.CITY_PATROLLING and cityData:hasRiot(city.id) then
                                self:_initCityMainLayer(city.id)
                            else
                                _updateLabel(self, "Label_countdown"..city.id, {text=G_ServerTime:secondToString(countdown - math.floor(delay)), stroke=Colors.strokeBlack})
                            end
                        end)
                    else
                        _updateLabel(self, "Label_countdown"..city.id, {visible=false})
                    end
                    
                end
                
            -- 尚未攻占，或攻占了没有安排巡逻武将
            elseif city.state == cityData.CITY_NEED_ATTACK or city.state == cityData.CITY_NEED_PATROL then
                _updateImageView(self, "Image_lock"..city.id, {visible=false})
                G_GlobalFunc.setDark(cityBtn, false)
                _updateImageView(self, "Image_city_state"..city.id, {visible=false})
                _updateImageView(self, "Image_bubble"..city.id, {visible=false})
                _updateLabel(self, "Label_countdown"..city.id, {visible=false})
                
                if city.state == cityData.CITY_NEED_ATTACK then

                    local EffectNode = require "app.common.effects.EffectNode"
                    local effect = EffectNode.new("effect_knife")
                    cityBtn:addNode(effect)
                    effect:play()
                    effect:setPosition(ccp(0, 100))
                    
                elseif city.state == cityData.CITY_NEED_PATROL then
                    
                    local EffectNode = require "app.common.effects.EffectNode"
                    local effect = EffectNode.new("effect_jiahao")
                    cityBtn:addNode(effect)
                    effect:play()
                    effect:setPosition(ccp(0, 50))
                end
                
            -- 已攻占
            elseif city.state == cityData.CITY_PATROLLING then
                -- 是否有巡逻
                if city.patrol_time > 0 then
                    
                    local countdown = city.patrol_time
                    _updateLabel(self, "Label_countdown"..city.id, {visible=true, text=G_ServerTime:secondToString(countdown), stroke=Colors.strokeBlack})
                    
                    local delay = 0
                    self._countdownHandler[city.id] = G_GlobalFunc.addTimer(1, function(dt)
                        delay = delay + dt
                        -- 时间到，更新数据
                        if countdown - math.floor(delay) <= 0 then
                            self:_initCityMainLayer(city.id)
                        -- 发生暴动
                        elseif cityData:hasRiot(city.id) then
                            self:_initCityMainLayer(city.id)
                        else
                            _updateLabel(self, "Label_countdown"..city.id, {text=G_ServerTime:secondToString(countdown - math.floor(delay)), stroke=Colors.strokeBlack})
                        end
                    end)
                else
                    _updateLabel(self, "Label_countdown"..city.id, {visible=false})
                end
                
                _updateImageView(self, "Image_lock"..city.id, {visible=false})
                G_GlobalFunc.setDark(self:getButtonByName("Button_city"..city.id), false)
                _updateImageView(self, "Image_city_state"..city.id, {visible=false})
                _updateImageView(self, "Image_bubble"..city.id, {visible=false})

            -- 有暴动或丰收
            elseif city.state == cityData.CITY_HARVEST or city.state == cityData.CITY_RIOT then
                _updateImageView(self, "Image_lock"..city.id, {visible=false})
                G_GlobalFunc.setDark(self:getButtonByName("Button_city"..city.id), false)
                _updateImageView(self, "Image_city_state"..city.id, {visible=true, texture=G_Path.getCityStatePathWithState(city.state)})
                _updateImageView(self, "Image_bubble"..city.id, {visible=true})
                _updateImageView(self, "Image_bubble_desc"..city.id, {texture=G_Path.getCityStateBubblePathWithState(city.state)})
                
                -- 气泡动画
                local bubble = self:getImageViewByName("Image_bubble"..city.id)
                bubble:stopAllActions()
                bubble:setScale(0.38)
                bubble:setPosition(ccp(0, 0))
                bubble:runAction(CCSequence:createWithTwoActions(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)), CCCallFunc:create(function()
                    bubble:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.4, ccp(0, 5)), CCMoveBy:create(0.4, ccp(0, -5)))))
                end)))
                                
                if city.state == cityData.CITY_HARVEST then
                    _updateLabel(self, "Label_countdown"..city.id, {visible=false})
                else
                    _updateLabel(self, "Label_countdown"..city.id, {visible=true})
                end
                
                if city.state == cityData.CITY_RIOT then
                    
                    -- 城池火焰
                    local cityBtn = self:getButtonByName("Button_city"..city.id)
                    cityBtn:removeAllNodes()
                    local EffectNode = require "app.common.effects.EffectNode"
                    local effect = EffectNode.new("effect_city_riot_fire")
                    cityBtn:addNode(effect)
                    effect:setPositionX(-15)
                    effect:play()
                    
                    if city.patrol_time > 0 then
                    
                        local countdown = city.patrol_time
                        _updateLabel(self, "Label_countdown"..city.id, {visible=true, text=G_ServerTime:secondToString(countdown), stroke=Colors.strokeBlack})
                        
                        local delay = 0
                        self._countdownHandler[city.id] = G_GlobalFunc.addTimer(1, function(dt)
                            delay = delay + dt
                            -- 时间到，更新数据
                            if countdown - math.floor(delay) <= 0 then
                                self:_initCityMainLayer(city.id)
                            else
                                _updateLabel(self, "Label_countdown"..city.id, {text=G_ServerTime:secondToString(countdown - math.floor(delay)), stroke=Colors.strokeBlack})
                            end
                        end)
                    else
                        _updateLabel(self, "Label_countdown"..city.id, {visible=false})
                    end
                    
                end
                
            end
        end
    end
    
    -- 更新玩家名字
    local friend = G_Me.friendData:getFriendByUid(G_Me.cityData:getCityUserId())
    local name = cityData:isMyCity() and G_Me.userData.name or (friend and friend.name or G_Me.userData.name)
    
    -- 我自己的领地不显示名字条目
    _updateImageView(self, "Image_user_name_bg", {visible=not G_Me.cityData:isMyCity()})
    
    _updateLabel(self, "Label_user_name", {text=name, stroke=Colors.strokeBlack})
    
    -- 可帮好友镇压次数
    _updateLabel(self, "Label_help_friend_desc", {text=G_lang:get("LANG_CITY_MAIN_LAYER_HELP_FRIEND_DESC")})
    -- 次数
    _updateLabel(self, "Label_help_friend_amount", {text=cityData:getRemainAssistCount()})
    
    local getPosition = _autoAlign(ccp(0, 0), {self:getLabelByName("Label_help_friend_desc"), self:getLabelByName("Label_help_friend_amount")}, ALIGN_CENTER)
    self:getLabelByName("Label_help_friend_desc"):setPosition(getPosition(1))
    self:getLabelByName("Label_help_friend_amount"):setPosition(getPosition(2))
    
    -- 我自己的界面回到领地按钮要隐藏
    self:showWidgetByName("Button_back_city", not G_Me.cityData:isMyCity())

    -- 好友界面不显示领地科技
    self:showWidgetByName("Button_tech", G_Me.cityData:isMyCity())

    -- 自己界面显示“一键巡逻”或者“一键收获”按钮
    self:_updateOneKeyPatrol()
    self:_updateOneKeyHarvest()
end

-- update the state of the "one key patrol" button
function CityMainLayer:_updateOneKeyPatrol()
    local canPatrolAll = G_Me.cityData:isMyCity() and G_Me.cityData:needPatrolAll()
    self:showWidgetByName("Button_onekey_patrol", canPatrolAll)
end

-- update the state of the "one key harvest" button
function CityMainLayer:_updateOneKeyHarvest()
    local canHarvest = G_Me.cityData:isMyCity() and G_Me.cityData:needHarvest()
    self:showWidgetByName("Button_onekey_harvest", canHarvest)

    if canHarvest then
        if not self._oneKeyEffect then
            self._oneKeyEffect = EffectNode.new("effect_particle_star")
            self._oneKeyEffect:setScale(0.5)
            self._oneKeyEffect:play()
            self:getWidgetByName("Button_onekey_harvest"):addNode(self._oneKeyEffect)
        end
    else
        if self._oneKeyEffect then
            self._oneKeyEffect:stop()
            self._oneKeyEffect:removeFromParentAndCleanup(true)
            self._oneKeyEffect = nil
        end
    end
end

return CityMainLayer
