-- CityPatrolStateLayer
-- 领地巡逻进行中界面

local _split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end

local function _updatePanel(target, name, params)
    
    local panel = target:getPanelByName(name)

    if params.visible ~= nil then
        panel:setVisible(params.visible)
    end
    
end

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        local border = params.border and params.border or 1
        label:createStroke(params.stroke, border)
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

local function _createKnight(knightPath, jsonPath, withShadow)
    
    local node = display.newNode()
    
    local cardJson = decodeJsonFile(jsonPath)
    assert(cardJson, "Could not read the json with path: "..jsonPath)
    
    local cardSprite = display.newSprite(knightPath)
    local anchorPoint = cardSprite:getAnchorPoint()
    local size = cardSprite:getCascadeBoundingBox(true).size
    anchorPoint = ccp((anchorPoint.x * size.width - cardJson.x) / size.width, (anchorPoint.y * size.height - cardJson.y) / size.height)
    cardSprite:setAnchorPoint(anchorPoint)
    node:addChild(cardSprite)
    
    if withShadow then
        local shadow = display.newSprite(G_Path.getKnightShadow())
        shadow:setPosition(ccp(tonumber(cardJson.shadow_x) + cardSprite:getPositionX(), tonumber(cardJson.shadow_y) + cardSprite:getPositionY()))
        node:addChild(shadow)
    end
    
    return node
    
end

require "app.cfg.city_common_event_info"
require "app.cfg.city_npc_info"
require "app.cfg.city_knight_text"


local CityPatrolStateLayer = class("CityPatrolStateLayer", UFCCSNormalLayer)

function CityPatrolStateLayer.create(...)
    return CityPatrolStateLayer.new("ui_layout/city_PatrolStateMainLayer.json", nil, ...)
end

function CityPatrolStateLayer:ctor(_, _, index)
    
    CityPatrolStateLayer.super.ctor(self)
    
    self:initData(index)
    
    -- 存储事件的容器
    self._events = {container={}}
    
    self._events.addEvent = function(...)
        local events = {...}
        for i=1, #events do
            self._events.container[#self._events.container+1] = events[i]
        end
    end
    
    self._events.at = function(index)
        return self._events.container[index]
    end
    
    self._events.count = function()
        return #self._events.container
    end
    
    self._events.clear = function()
        self._events.container = {}
    end
    
    -- 存储奖励的容器
    self._awards = {
        _container = {},
        _index = {}
    }
    
    self._awards.addAward = function(award)
        local multiple = math.max(rawget(award, "times") or 1, 1)

        if award.id == -1 then --表示这是丰收奖励，这里特殊处理
            
            local kac, duration, efficiency = G_Me.cityData:getPatrolInfoByIndex(self._index)
            local cityEndInfo = city_end_event_info.get(kac, duration, efficiency)
            assert(cityEndInfo, "Could not find the city_end_info with advance_code: "..kac.." duration: "..duration.." efficiency: "..efficiency)
            
            local reward = G_Me.cityData:getHarvestRewardSizeByIndex(self._index)
            for i=1, #reward do
                local _type = cityEndInfo['type_'..i]
                local _value = cityEndInfo['value_'..i]
                local _size = reward[i] * multiple
                if _type ~= 0 then
                    local oldAward = self._awards._container[tostring(_type).."_".._value]
                    if not oldAward then
                        self._awards._container[tostring(_type).."_".._value] = {type=_type, value=_value, size=_size}
                        -- 数字下标索引
                        self._awards._index[#self._awards._index+1] = self._awards._container[tostring(_type).."_".._value]
                    else
                        oldAward.size = oldAward.size + _size
                    end
                end
            end
            
        else
            
            local awardConfig = city_common_event_info.get(award.id)
            assert(awardConfig, "Could not find the award in common_event with id: "..award.id)

            local _type = awardConfig.type
            local _value = awardConfig.value
            local _size = awardConfig.size * multiple
            
            if _type ~= 0 then
                local oldAward = self._awards._container[tostring(_type).."_".._value]
                if not oldAward then
                    self._awards._container[tostring(_type).."_".._value] = {type=_type, value=_value, size=_size}
                    -- 数字下标索引
                    self._awards._index[#self._awards._index+1] = self._awards._container[tostring(_type).."_".._value]
                else
                    oldAward.size = oldAward.size + _size
                end
            end
        end
        
        table.sort(self._awards._index, function(a, b)
            return a.type < b.type or (a.type == b.type and a.value < b.value)
        end)
        
    end
    
    self._awards.at = function(index)
        return self._awards._index[index]
    end
    
    self._awards.count = function()
        return #self._awards._index
    end
    
    self._awards.clear = function()
        self._awards._index = {}
        self._awards._container = {}
    end
    
    -- 手动适配一下位置
    local panel = self:getPanelByName("Panel_knight")
    panel:setPositionY(panel:getPositionY() + (display.height - 853) * 0.4)
    
    panel = self:getPanelByName("Panel_knight_patrol")
    panel:setPositionY(panel:getPositionY() + (display.height - 853) * 0.6)
    
    for i=1, 3 do
        panel = self:getPanelByName("Panel_npc"..i)
        panel:setPositionY(panel:getPositionY() + (display.height - 853) * 0.6)
    end
    
end

function CityPatrolStateLayer:initData(index)

    -- 记录一下城池的索引
    self._index = index
    
    -- 记录一下选择的武将
    self._knightId = G_Me.cityData:getPatrolKnightIDByIndex(index)
    
end

function CityPatrolStateLayer:getCityIndex() return self._index end

function CityPatrolStateLayer:onLayerEnter()
    
    -- 因为UIListView在退出"舞台"的时候会把schedule取消，但是重新加载（retain保留起来）没有重新启用，所以这里需要再打开一次
    if self._eventList then
        -- 因为这里listview中的标示update的状态量还是true（但实际上和事实不符），因其逻辑判断为问题，所以先关闭一次再开启
        self._eventList:setUpdateEnabled(false)
        self._eventList:setUpdateEnabled(true)
        self._eventList:initChildWithDataLength(0)
    end
    
    if self._awardList then
        -- 因为这里listview中的标示update的状态量还是true（但实际上和事实不符），因其逻辑判断为问题，所以先关闭一次再开启
        self._awardList:setUpdateEnabled(false)
        self._awardList:setUpdateEnabled(true)
        self._awardList:initChildWithDataLength(0)
    end
    
    self._events.clear()
    self._awards.clear()
    
    local cityData = G_Me.cityData
    
    -- 暴动镇压按钮
    local btnAssist = self:getButtonByName("Button_assist")
    
    -- 先刷新事件
    local preIEEvent, preREEvent = cityData:previousEvent(self._index)
    
    -- 合并事件时间
    local events = {}
    local ieIndex = 1
    for i=1, #preREEvent do
        events[#events+1] = preREEvent[i]
        for j=ieIndex, #preIEEvent do
            if preREEvent[i+1] then
                if preIEEvent[j].displayTime < preREEvent[i+1].displayTime then
                    events[#events+1] = preIEEvent[j]
                    ieIndex = ieIndex + 1
                else
                    break
                end
            else
                events[#events+1] = preIEEvent[j]
                ieIndex = ieIndex + 1
            end
        end
    end
    
    for i=1, #preIEEvent do
        if preIEEvent[i]["end"] == 0 then
            btnAssist:setVisible(true)
            btnAssist:stopAllActions()
            btnAssist:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(1, 1.05), CCScaleTo:create(1, 1))))
            break
        end
    end
    
    -- 添加互动事件和资源事件至事件列表
    for i=1, #events do
        
        -- 资源事件一定存在
        self._events.addEvent(events[i])
        
    end

    if self._events.count() > 0 then
        self:_createEventList()
        self._eventList:reloadWithLength(self._events.count()+1, self._events.count()+1)
        self._eventList:scrollToShowCell(self._events.count()+1, 0)
    end
    
    -- 添加资源事件至奖励列表
    for i=1, #preREEvent do
        self._awards.addAward(preREEvent[i])
    end
    
    if self._awards.count() > 0 then
        self:_createAwardList()
        self._awardList:reloadWithLength(self._awards.count())
    end
    
    self._timerHandler = G_GlobalFunc.addTimer(1, function(dt)
        
        -- 每一秒钟去检查是否有新消息
        local ieEvent, reEvent = cityData:nextEvent(self._index)
        
        -- 添加事件
        if ieEvent or reEvent then
            
            if reEvent then
                self._events.addEvent(reEvent)
            end
            
            if ieEvent then
                self._events.addEvent(ieEvent)
            end
            
            if not self._eventList then
                self:_createEventList()
            end
            
            -- 更新显示
            self._eventList:reloadWithLength(self._events.count()+1, self._events.count()+1)
            self._eventList:scrollToShowCell(self._events.count()+1, 0)
        end
        
        if ieEvent then
            -- 暴动出现，则播放暴动动画
            self:_playRiotAnimation()
            -- 按钮不可见表明上一个暴动事件已经结束或者还没有出现暴动事件
            if not G_Me.cityData:isMyCity() and not btnAssist:isVisible() then
                btnAssist:setVisible(true)
                btnAssist:stopAllActions()
                btnAssist:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(1, 1.05), CCScaleTo:create(1, 1))))
            end
        end
        
        -- 新奖励
        if reEvent then
            
            -- 添加事件
            self._awards.addAward(reEvent)
            
            if not self._awardList then
                self:_createAwardList()
            end
            
            self._awardList:reloadWithLength(self._awards.count())
        end
    end)
    
    -- 被帮助镇压暴动也需要播放动画
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_ASSISTED, function()
        -- 播放解决暴动动画，完事了再播放巡逻动画
        self:_playResolveRiotAnimation(function(event)
            if event == "finish" then
                self._isPlayingResolveAnimation = false
                self:_initCityPatrolStateLayer()
            end
        end)
    end, self)
    
    self:_initCityPatrolStateLayer()
    
end

function CityPatrolStateLayer:onLayerExit()
    
    if self._timerHandler then
        G_GlobalFunc.removeTimer(self._timerHandler)
        self._timerHandler = nil
    end
    
    if self._countdownHandler then
        G_GlobalFunc.removeTimer(self._countdownHandler)
        self._countdownHandler = nil
    end
    
    if self._nextAwardCountdownHandler then
        G_GlobalFunc.removeTimer(self._nextAwardCountdownHandler)
        self._nextAwardCountdownHandler = nil
    end
    
    uf_eventManager:removeListenerWithTarget(self)
    
    -- 暴动动画标记要清除
    self._isPlayingResolveAnimation = false
    
    -- 清理动画节点
    local panel = self:getPanelByName("Panel_knight_patrol")
    panel:removeAllNodes()
    
    local panel = self:getPanelByName("Panel_knight")
    panel:removeAllNodes()
    
end

function CityPatrolStateLayer:_createAwardList()
    
    -- 列表只能在这里创建
    if not self._awardList then
        -- 创建列表
        local panel = self:getPanelByName("Panel_award_list")

        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_HORIZONTAL)
        self._awardList = listView

        listView:setCreateCellHandler(function()
            return CCSItemCellBase:create("ui_layout/city_PatrolStateAwardItem.json")
        end)

        listView:setUpdateCellHandler(function(list, index, cell)

            local _award = self._awards.at(index+1)
            local good = G_Goods.convert(_award.type, _award.value)
            -- 背景
            _updateImageView(cell, 'Image_bg', {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
            -- icon
            _updateImageView(cell, 'Image_icon', {texture=good.icon})
            -- 品级框
            _updateImageView(cell, 'Image_frame', {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})
            -- 名称
--            _updateLabel(self, "Label_name", {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
            -- 数量
            _updateLabel(cell, "Label_amount", {text='x'.._award.size, stroke=Colors.strokeBlack})
            
            -- 头像现在需要响应事件用来显示详情
            cell:registerWidgetTouchEvent("Image_icon", function(widget, state)
                -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                if state == 2 then
                    require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
                end
            end)
            
        end)

        listView:initChildWithDataLength(self._awards.count())
        
    end
    
end

function CityPatrolStateLayer:_createEventList()
    
    if not self._eventList then
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_event_list")
        
        local listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._eventList = listView
        
        listView:setCreateCellHandler(function()
            return require("app.scenes.city.CityPatrolStateEventItem").new()
--            return CCSItemCellBase.new()
        end)
        
        listView:setUpdateCellHandler(function(list, index, cell)
            
            if index+1 < self._events.count()+1 then

                cell:showWidgetByName("Panel_content", true)
                cell:showWidgetByName("Panel_countdown", false)
                
                local event = self._events.at(index+1)
                local multiple = math.max(rawget(event, "times") or 1, 1)
                local curTime = G_ServerTime:getDataObjectFormat("%X", event.displayTime)
                --local curTime = os.date("%X", event.displayTime)

                if not rawget(event, "isHarvest") then

                    local eventConfig = city_common_event_info.get(event.id)            

                    local text = eventConfig.directions
                    local knightConfig = knight_info.get(self._knightId)
                    local good = G_Goods.convert(eventConfig.type, eventConfig.value)
        --            assert(good, "Could not find the good with type: "..eventConfig.type.." and value: "..eventConfig.value)

                    if multiple == 2 then
                        text = string.gsub(text, "</root>", G_lang:get("LANG_CITY_HARVEST_DOUBLE_POSTFIX"))
                    end

                    text = GlobalFunc.formatText(text, {
                        quality_knight=Colors.qualityDecColors[knightConfig.quality],
                        knight=knightConfig.name,
                        quality_reward = good and Colors.qualityDecColors[good.quality] or nil,
                        reward = good and good.name.."x"..(eventConfig.size * multiple) or nil,
                        name = rawget(event, "name") and rawget(event, "name") or nil
                        }
                    )

                    cell:updateContent("["..curTime.."]", text)

                else

                    local eventConfig = city_end_event_info.get(G_Me.cityData:getPatrolInfoByIndex(self._index))

                    local text = eventConfig.directions
                    local knightConfig = knight_info.get(self._knightId)
                    local good1, good2, good3

                    if multiple == 2 then
                        text = string.gsub(text, "</root>", G_lang:get("LANG_CITY_HARVEST_DOUBLE_POSTFIX"))
                    end

                    if eventConfig.type_1 ~= 0 then good1 = G_Goods.convert(eventConfig.type_1, eventConfig.value_1) end
                    if eventConfig.type_2 ~= 0 then good2 = G_Goods.convert(eventConfig.type_2, eventConfig.value_2) end
                    if eventConfig.type_3 ~= 0 then good3 = G_Goods.convert(eventConfig.type_3, eventConfig.value_3) end

                    local awardSize = G_Me.cityData:getHarvestRewardSizeByIndex(self._index)
                    local awardDesc = good1 and good1.name.."x"..(awardSize[1] * multiple) or ""
                    awardDesc = awardDesc .. (good2 and ", "..good2.name.."x"..(awardSize[2] * multiple) or "")
                    awardDesc = awardDesc .. (good3 and ", "..good3.name.."x"..(awardSize[3] * multiple) or "")

                    text = GlobalFunc.formatText(text, {
                        quality_knight=Colors.qualityDecColors[knightConfig.quality],
                        knight=knightConfig.name,
                        reward = awardDesc,
                        }
                    )

                    cell:updateContent("["..curTime.."]", text)

                end
            
            else 

                cell:showWidgetByName("Panel_content", false)
                cell:showWidgetByName("Panel_countdown", true)
                
                -- 下一次倒计时
                local nextAwardCountdown = G_Me.cityData:getNextAwardTime(self._index)
                if nextAwardCountdown > 0 then
                    
                    -- 下次领奖倒计时
                    _updateLabel(cell, "Label_next_award_desc", {text=G_lang:get("LANG_CITY_PATROLLING_NEXT_AWARD_DESC")})
                    _updateLabel(cell, "Label_next_award_countdown", {visible=true, text=G_ServerTime:secondToString(nextAwardCountdown)})
                    
                    -- 下次领奖时间倒计时
                    if self._nextAwardCountdownHandler then
                        G_GlobalFunc.removeTimer(self._nextAwardCountdownHandler)
                    end
                    
                    local delay = 0
                    self._nextAwardCountdownHandler = G_GlobalFunc.addTimer(1, function(dt)
                        delay = delay + dt
                        -- 时间到，更新数据
                        if nextAwardCountdown - math.floor(delay) <= 0 then
                            delay = delay % G_Me.cityData:efficiencyToSeconds(G_Me.cityData:getPatrolEfficiencyByIndex(self._index))
                            nextAwardCountdown = G_Me.cityData:getNextAwardTime(self._index)
                            if nextAwardCountdown == 0 then
                                G_GlobalFunc.removeTimer(self._nextAwardCountdownHandler)
                                self._nextAwardCountdownHandler = nil
                            else
                                _updateLabel(cell, "Label_next_award_countdown", {text=G_ServerTime:secondToString(nextAwardCountdown - math.floor(delay))})
                            end
                        else
                            _updateLabel(cell, "Label_next_award_countdown", {text=G_ServerTime:secondToString(nextAwardCountdown - math.floor(delay))})
                        end
                    end)
                else
                    _updateLabel(cell, "Label_next_award_desc", {text=G_lang:get("LANG_CITY_PATROLLING_FINISH_DESC")})
                    _updateLabel(cell, "Label_next_award_countdown", {visible=false})
                end
                
                local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_next_award_desc"), cell:getLabelByName("Label_next_award_countdown")}, ALIGN_LEFT)
                cell:getLabelByName("Label_next_award_desc"):setPosition(getPosition(1))
                cell:getLabelByName("Label_next_award_countdown"):setPosition(getPosition(2))
                
            end
            
        end)
        
        listView:initChildWithDataLength(self._events.count()+1)
        
    end
    
end

function CityPatrolStateLayer:_initCityPatrolStateLayer()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)
    
    local cardConfig = knight_info.get(self._knightId)
    assert(cardConfig, "Could not find the card config with id:"..self._knightId)
    
    -- 背景界面需要更新，未来打算根据city_info里的资源id来读取
    _updateImageView(self, "Image_bg", {texture=G_Path.getCityBGPathWithId(city.pic2)})
    
    -- 更新下城市名称
    _updateImageView(self, "Image_city_name", {texture=G_Path.getCityNamePathWithId(city.id)})
    
    -- 巡逻奖励
    _updateLabel(self, "Label_patrol_award_desc", {text=G_lang:get("LANG_CITY_PATROLLING_AWARD_DESC"), stroke=Colors.strokeBrown, border = 2})

    -- 巡逻倒计时
    local cityData = G_Me.cityData:getCityByIndex(self._index)
    local countdown = cityData.patrol_time
    _updateLabel(self, "Label_patrol_countdown", {visible=countdown > 0, text=G_ServerTime:secondToString(countdown)})
    
    local getBtn = self:getButtonByName("Button_get_award")
    self:attachImageTextForBtn("Button_get_award", "Image_get_award_desc")
    getBtn:setTouchEnabled(countdown <= 0)
    
    getBtn:removeAllNodes()
    
    local function _onCountDownFinish()
        
        getBtn:setTouchEnabled(true)

        local EffectNode = require "app.common.effects.EffectNode"
        local node = EffectNode.new("effect_around2")
        node:setScale(1.4)
        node:play()
        getBtn:addNode(node)

        -- 已完成文字
        local text = G_lang:get("LANG_CITY_PATROL_KNIGHT_FINISH_DESC")
        text = GlobalFunc.formatText(text, {
            patrol_knight_color=Colors.qualityDecColors[cardConfig.quality],
            patrol_knight=cardConfig.name,
            }
        )

        local panel = self:getPanelByName("Panel_knight_desc")
        panel:setVisible(true)
        panel:removeChildByTag(100, true)

        local label = self:getLabelByName("Label_knight_desc")
        local size = label:getSize()
        label:setText("")

        local label1 = CCSRichText:create(size.width, size.height)
        label1:setFontName(label:getFontName())
        label1:setFontSize(label:getFontSize())
        label1:setShowTextFromTop(true)
        label1:setTextAlignment(ui.TEXT_ALIGN_CENTER)
        label1:enableStroke(Colors.strokeBlack)
        label1:setPositionXY(label:getPositionX(), label:getPositionY() + (display.height-853)*0.15)

        label1:clearRichElement()
        label1:appendContent(text, ccc3(255, 255, 255))
        label1:reloadData()
        panel:addChild(label1, 5, 100)
        
        _updateLabel(self, "Label_patrol_countdown", {visible=false})
        _updateLabel(self, "Label_patrolling", {text=G_lang:get(G_Me.activityData.custom:isCityActive() and "LANG_CITY_PATROLLING_ACTIVITY_DESC" or "LANG_CITY_PATROLLING_DONE_DESC")})
        
        -- 镇压按钮要隐藏
        self:getButtonByName("Button_assist"):setVisible(false)

        -- 动画要变成完成动画
        if not self._isPlayingResolveAnimation then
            self:_playKnightAnimation()
        end
        
    end
    
    if countdown > 0 then
        
        if self._countdownHandler then
            G_GlobalFunc.removeTimer(self._countdownHandler)
        end
        
        local delay = 0
        self._countdownHandler = G_GlobalFunc.addTimer(1, function(dt)
            delay = delay + dt
            -- 时间到，更新数据
            if countdown - math.floor(delay) <= 0 then
                _onCountDownFinish()
                G_GlobalFunc.removeTimer(self._countdownHandler)
                self._countdownHandler = nil
            else
                _updateLabel(self, "Label_patrol_countdown", {text=G_ServerTime:secondToString(countdown - math.floor(delay))})
            end
        end)
        
        _updatePanel(self, "Panel_knight_desc", {visible=false})

    end
    
    -- 巡逻中/巡逻完成
    _updateLabel(self, "Label_patrolling", {text=countdown > 0 and G_lang:get("LANG_CITY_PATROLLING_DESC") or G_lang:get("LANG_CITY_PATROLLING_DONE_DESC")})
    
    -- 领取按钮敌方不可见
    getBtn:setVisible(G_Me.cityData:isMyCity())
    
    -- 镇压暴动按钮
    if G_Me.cityData:isMyCity() then
        self:getButtonByName("Button_assist"):setVisible(false)
    end
        
    self:registerBtnClickEvent("Button_assist", function()
        
        -- 看看次数是否到头
        if not G_Me.cityData:hasAbilityToAssist() then
            -- vip达到7级则镇压次数达到最高
            if G_Me.userData.vip < 7 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_PATROL_ASSIST_COUNT_NOT_ENOUGH"))
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_CITY_PATROL_ASSIST_COUNT_USED_OUT"))
            end
            return
        end
        
        -- 请求领地数据
        G_HandlersManager.cityHandler:sendCityAssist(G_Me.cityData:getCityUserId(), self._index)
        
        -- 收到消息则更新界面
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CITY_ASSIST, CityPatrolStateLayer._cityAssistCallBack, self)
        
    end)
    
    -- 丰收了就是丰收动画
    if G_Me.cityData:needHarvestByIndex(self._index) then
        _onCountDownFinish()
    -- 有暴动则播暴动动画
    elseif G_Me.cityData:hasRiot(self._index) then
        self:_playRiotAnimation()
    -- 否则是巡逻动画
    else
        self:_playPatrolAnimation()
    end
    
end

-- 领取奖励的响应回调
function CityPatrolStateLayer:_cityAssistCallBack(message)
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)
    
    local cardConfig = knight_info.get(self._knightId)
    assert(cardConfig, "Could not find the card config with id:"..self._knightId)
    
    if message.ret == NetMsg_ERROR.RET_RIOT_ASSISTED then

        self:getButtonByName("Button_assist"):setVisible(false)

        G_Me.cityData:setCityAssist(message, self._index)

        return
    end

    G_Me.cityData:setCityAssist(message, self._index)

    self:getButtonByName("Button_assist"):setVisible(false)

--    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(message.award)
--    uf_notifyLayer:getModelNode():addChild(_layer)
    
    self:_playResolveRiotAnimation(function(event)
        
        if event == "finish" then
            
            self._isPlayingResolveAnimation = false
            self:_initCityPatrolStateLayer()
            
            -- 弹框提示
            local awardLayer = UFCCSModelLayer.new("ui_layout/city_PatrolAssistAwardLayer.json", Colors.modelColor)
            uf_sceneManager:getCurScene():addChild(awardLayer)

            awardLayer:adapterWithScreen()
            
            -- 注册事件
            awardLayer:registerTouchEvent(false, true, 0)
            awardLayer.onTouchEnd = function()
                awardLayer:animationToClose()
            end
            
            -- 更新武将卡牌
            local friend = G_Me.friendData:getFriendByUid(G_Me.cityData:getCityUserId())
            local cardConfig = knight_info.get(friend.mainrole)
            assert(cardConfig, "Could not find the card with id: "..friend.mainrole)

            _updateImageView(awardLayer, "Image_knight", {texture=G_Path.getKnightPic(cardConfig.res_id)})

            local cardJson = decodeJsonFile(G_Path.getKnightPicConfig(cardConfig.res_id))
            assert(cardJson, "Could not find the card json with id: "..cardConfig.res_id)

            local knight = awardLayer:getImageViewByName("Image_knight")
            knight:setAnchorPoint(ccp((knight:getSize().width/2 - tonumber(cardJson.x)) / knight:getSize().width, (knight:getSize().height/2 - tonumber(cardJson.y)) / knight:getSize().height))

            -- 图太大了，缩小到原来的70%
            knight:setScale(0.7)

            -- 更新感谢文本
            _updateLabel(awardLayer, "Label_award_desc", {text=G_lang:get("LANG_CITY_PATROLLING_RIOT_ASSIST_DESC")})

            -- 奖励
            local _award = message.award[1]
            assert(_award, "cityAssist award could not be empty ! count: "..tostring(#message.award))

            local good = G_Goods.convert(_award.type, _award.value)
            -- 背景
            _updateImageView(awardLayer, 'Image_bg', {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
            -- icon
            _updateImageView(awardLayer, 'Image_icon', {texture=good.icon})
            -- 品级框
            _updateImageView(awardLayer, 'Image_frame', {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})
            -- 名称
            _updateLabel(awardLayer, "Label_name", {text=good.name..'x'.._award.size, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
            -- 玩家名字
            _updateLabel(awardLayer, "Label_user_name", {text=friend.name, color=Colors.qualityColors[cardConfig.quality]})
            
            require("app.common.effects.EffectSingleMoving").run(awardLayer:getImageViewByName("Image_continue"), "smoving_wait", nil, {})
            
        end
        
    end)
    
end

-- 创建巡逻动画
function CityPatrolStateLayer:_playPatrolAnimation()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)

    local cardConfig = knight_info.get(self._knightId)
    assert(cardConfig, "Could not find the card config with id:"..self._knightId)
    
    self:_playNPCAnimation()
    
    _updatePanel(self, "Panel_knight_patrol", {visible=true})
    _updatePanel(self, "Panel_knight", {visible=false})
        
    local patrolNode = require("app.common.effects.EffectMovingNode").new("moving_xunluo", 
        function(key)
            -- 角色卡牌
            if key == "kapai" then
                local node = display.newNode()
                local cardSprite = _createKnight(G_Path.getBattleConfigImage("knight", cardConfig.res_id..".png"), G_Path.getBattleConfig("knight", cardConfig.res_id.."_fight"))
                cardSprite:setScale(0.6)
                node:addChild(cardSprite)
                return node
            elseif key == "yanwu" then
                local effect = require("app.common.effects.EffectNode").new("effect_yanwu")
                effect:play()
                return effect
            elseif key == "sp" then
                local effect = require("app.common.effects.EffectNode").new("effect_patrolling")
                effect:play()
                return effect
            end
        end
    )
    
    local panel = self:getPanelByName("Panel_knight_patrol")
    panel:removeAllNodes()
    panel:addNode(patrolNode)
    
    patrolNode:play()
    
end

function CityPatrolStateLayer:_playRiotAnimation()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)

    local cardConfig = knight_info.get(self._knightId)
    assert(cardConfig, "Could not find the card config with id:"..self._knightId)
    
    self:_playNPCAnimation()
    
    _updatePanel(self, "Panel_knight_patrol", {visible=true})
    _updatePanel(self, "Panel_knight", {visible=false})
    
    local riotNode = require("app.common.effects.EffectMovingNode").new("moving_baodong", 
        function(key)
            -- 角色卡牌
            if key == "kapai" then
                local node = display.newNode()
                local cardSprite = _createKnight(G_Path.getBattleConfigImage("knight", cardConfig.res_id..".png"), G_Path.getBattleConfig("knight", cardConfig.res_id.."_fight"))
                cardSprite:setScale(0.6)
                node:addChild(cardSprite)
                return node
            elseif key == "yanwu" then
                local effect = require("app.common.effects.EffectNode").new("effect_yanwu")
                effect:play()
                return effect
            elseif key == "emotion" then
                return display.newSprite(G_Path.getFaceIco(14))
            end
        end
    )
    
    local riotFireNode = require("app.common.effects.EffectMovingNode").new("moving_bg_fire", 
        function(key)
            -- 角色卡牌
            if string.match(key, "sp_debuff_fire") then
                local effect = require("app.common.effects.EffectNode").new("effect_city_riot_fire")
                effect:play()
                return effect
            end
        end
    )
    
    local panel = self:getPanelByName("Panel_knight_patrol")
    panel:removeAllNodes()
    panel:addNode(riotFireNode)
    panel:addNode(riotNode)
    riotFireNode:setPositionY(-109)

    riotNode:play()
    riotFireNode:play()
    
end

function CityPatrolStateLayer:_playResolveRiotAnimation(callback)
    
    self:_clearNPC()
    
    -- 标记正在播放解决暴动动画
    self._isPlayingResolveAnimation = true
    
    local patrolNode = require("app.common.effects.EffectMovingNode").new("moving_zy_yawu", 
        function(key)
            if string.match(key, "Layer_sp_yw_a") then
                local effect = require("app.common.effects.EffectNode").new("effect_crc_yw_a")
                effect:play()
                return effect
            elseif string.match(key, "Layer_sp_yw_b") then
                local effect = require("app.common.effects.EffectNode").new("effect_crc_yw_b")
                effect:play()
                return effect
            elseif string.match(key, "Layer_sp_a") then
                local effect = require("app.common.effects.EffectNode").new("effect_city_riot_a")
                effect:play()
                return effect
            elseif string.match(key, "Layer_sp_c") then
                local effect = require("app.common.effects.EffectNode").new("effect_city_riot_c")
                effect:play()
                return effect
            elseif string.match(key, "Layer_sp_d") then
                local effect = require("app.common.effects.EffectNode").new("effect_crh_d")
                effect:play()
                return effect
            end
        end,
        callback
    )
    
    local panel = self:getPanelByName("Panel_knight_patrol")
    panel:removeAllNodes()
    panel:addNode(patrolNode)

    patrolNode:play()
    
end

function CityPatrolStateLayer:_playKnightAnimation()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)

    local cardConfig = knight_info.get(self._knightId)
    assert(cardConfig, "Could not find the card config with id:"..self._knightId)
    
    self:_clearNPC()
    
    _updatePanel(self, "Panel_knight", {visible=true})
    _updatePanel(self, "Panel_knight_patrol", {visible=false})
    
    -- 隐藏对话框和人物名称
    _updateImageView(self, "Image_dialog", {visible=false})
    _updateImageView(self, "Image_role_name_bg", {visible=false})

    local cardNode = nil
    
    local jumpNode = require("app.common.effects.EffectMovingNode").new("moving_card_jump", 
        function(key)
            -- 角色卡牌
            if key == "char" then
                cardNode = display.newNode()
                local cardSprite = _createKnight(G_Path.getKnightPic(cardConfig.res_id), G_Path.getKnightPicConfig(cardConfig.res_id), true)
                cardSprite:setScale(0.6)
                cardNode:addChild(cardSprite)
                return cardNode
            -- 烟尘
            elseif key == "effect_card_dust" then
                local effect = require("app.common.effects.EffectNode").new("effect_card_dust")
                effect:play()
                return effect  
            end
        end,
        function(event)
            if event == "finish" then
                if cardNode then
                    -- 呼吸动画
--                    cardNode:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(1.5, 1.05), CCScaleTo:create(1.5, 1))))
                    require("app.common.effects.EffectSingleMoving").run(cardNode, "smoving_idle", nil, {}, 1+math.floor(math.random()*30))
                end
                
                -- 显示对话框和人物名称
                _updateImageView(self, "Image_role_name_bg", {visible=true})
                
                local imgDialog = self:getImageViewByName("Image_dialog")
                imgDialog:setVisible(true)
                imgDialog:setScale(0.38)
                imgDialog:runAction(CCEaseBounceOut:create(CCScaleTo:create(0.5, 1)))
                
                -- 角色名字
                _updateLabel(self, "Label_role_name", {text=cardConfig.name, color=Colors.qualityColors[cardConfig.quality]})

                _updateLabel(self, "Label_dialog", {text=G_lang:get("LANG_CITY_PATROLLING_FINISH_KNIGHT_DESC")})
                
            end
        end
    )

    local panel = self:getPanelByName("Panel_knight")
    panel:removeAllNodes()
    panel:addNode(jumpNode)

    jumpNode:play()
    
end

-- 清理NPC动画
function CityPatrolStateLayer:_clearNPC()
    for i=1, 3 do
        local npcPanel = self:getPanelByName("Panel_npc"..i)
        npcPanel:setTouchEnabled(false)
        npcPanel:removeAllNodes()
    end
end

function CityPatrolStateLayer:_playNPCAnimation()
    
    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)
    
    self:_clearNPC()
    
    -- npc
    local npcs = {}
    local disableCities = {}
    disableCities.set = function(_t)
        disableCities._content = _t
    end
    disableCities.contain = function(va)
        for k, v in pairs(disableCities._content) do
            if v == va then return true end
        end
        return false
    end
    
    if G_Me.cityData:hasRiot(self._index) then
        local count = 0
        local v = city_npc_info.get(6)
        repeat
            count = count + 1
            npcs[#npcs+1] = v
        until count == 3
    else
        for k=1, city_npc_info.getLength() do
            local v = city_npc_info.indexOf(k)
            disableCities.set(_split(v.disable_city_id, ","))
            if v.id ~= 6 and not disableCities.contain(tostring(city.id)) then   -- 6是暴动士兵，需要排除，不能在排除城市列表中出现
                npcs[#npcs+1] = v
            end
        end
    end
    
    npcs.at = function(index)
        return npcs[index]
    end
    
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    
    for i=1, 3 do
        local index = math.random(1, #npcs)
        local npcConfig = npcs.at(index)
        assert(npcConfig, "Could not find the npc config with index: "..index)
        
        local npc = _createKnight(G_Path.getKnightPic(npcConfig.res_id), G_Path.getKnightPicConfig(npcConfig.res_id), true)
        npc:setScale(0.25)
        local npcPanel = self:getPanelByName("Panel_npc"..i)
        npcPanel:setTouchEnabled(true)
        npcPanel:addNode(npc)
        npc:setPositionX(50)
        
--        npc:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(1.5, 0.26), CCScaleTo:create(1.5, 0.25))))
        require("app.common.effects.EffectSingleMoving").run(npc, "smoving_idle", nil, {}, 1+math.floor(math.random()*30))
        
        -- 5秒钟一个表情或者对话
        local count = 0
        local _next = nil
        _next = function(delay)
            
            count = math.max(1, (count + 1) % 7)
            npc:stopActionByTag(100)
            npc:removeChildByTag(100)
            
            for j=count, 6 do
                if j%2 == 1 then    -- 对话
                    local txt = npcConfig["text_"..((j+1)/2)]
                    if txt ~= "0" then

                        local _createBubble = function()
                            
                            local bubble = display.newSprite(G_Path.getDialogQipao())
                            npc:addChild(bubble, 0, 100)
                            local label = G_GlobalFunc.createGameLabel(txt, 30, Colors.lightColors.DESCRIPTION, nil, CCSizeMake(170, 80))
                            bubble:addChild(label)
                            label:setPositionXY(bubble:getContentSize().width/2 + 13, bubble:getContentSize().height/2 + 4)
                            
                            bubble:setScale(0.76)
                            
                            local actions = CCArray:create()
                            actions:addObject(CCEaseBounceOut:create(CCScaleTo:create(0.5, 2)))
                            actions:addObject(CCDelayTime:create(5))
                            actions:addObject(CCCallFunc:create(function()
                                _next()
                            end))
                            
                            bubble:runAction(CCSequence:create(actions))
                            bubble:setAnchorPoint(ccp(0, 0.5))
                            bubble:setPosition(ccp(70, 350))
                            
                        end
                        
                        if delay then
                            local action = CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(function()
                                _createBubble()
                            end))
                            action:setTag(100)
                            npc:runAction(action)
                        else
                            _createBubble()
                        end
                        
                        break
                    else
                        count = math.max(1, (count + 1) % 7)
                    end
                else    -- 表情
                    local faceId = tonumber(npcConfig["face_"..j/2])
                    if faceId ~= 0 then
                        
                        local _createFace = function()
                            local face = display.newSprite(G_Path.getFaceIco(faceId))
                            npc:addChild(face, 0, 100)
                            face:setPositionXY(60, 450)
                            face:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5), CCCallFunc:create(function()
                                _next()
                            end)))
                            face:setScale(2)
                        end
                        
                        if delay then
                            local action = CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(function()
                                _createFace()
                            end))
                            action:setTag(100)
                            npc:runAction(action)
                        else
                            _createFace()
                        end
                        
                        break
                    else
                        count = math.max(1, (count + 1) % 7)
                    end
                end
            end
        end
        
        _next(not G_Me.cityData:hasRiot(self._index) and math.random(3, 15) or 0)
        
        self:registerWidgetTouchEvent("Panel_npc"..i, function(widget, state)
            if state == 2 then
                _next()
            end
        end)
        
        table.remove(npcs, index)
    end
    
end

return CityPatrolStateLayer
