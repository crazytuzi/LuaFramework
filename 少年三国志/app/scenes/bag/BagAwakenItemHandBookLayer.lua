-- BagAwakenItemHandBookLayer

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


require "app.cfg.item_awaken_info"
local HeroAwakenItemDetailLayer = require "app.scenes.herofoster.HeroAwakenItemDetailLayer"


local BagAwakenItemHandBookLayer = class("BagAwakenItemHandBookLayer", UFCCSModelLayer)

function BagAwakenItemHandBookLayer.create(...)
    return BagAwakenItemHandBookLayer.new("ui_layout/bag_BagAwakenItemHandbookLayer.json", Colors.modelColor, ...)
end

function BagAwakenItemHandBookLayer:ctor(...)
    
    BagAwakenItemHandBookLayer.super.ctor(self)
    
    self:closeAtReturn(true)
    require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
    
    self:showAtCenter(true)
    
    -- 通用控件，右上角的关闭按钮
    local function _onClose()
        self:animationToClose()
        local soundConst = require("app.const.SoundConst")
        G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
    end

    self:registerBtnClickEvent("Button_close", _onClose)
    self:enableAudioEffectByName("Button_close", false)
    
    self:registerBtnClickEvent("Button_close1", _onClose)
    self:enableAudioEffectByName("Button_close1", false)
    
end

function BagAwakenItemHandBookLayer:onLayerEnter()
    
    self:updateView()
    
end

function BagAwakenItemHandBookLayer:updateView()
    
    -- 计算一下当前所有道具的归类
    local items = {container = {}}
    
    items.add = function(quality, item)
        local _items = items.container[quality] or {}
        _items[#_items+1] = item
        items.container[quality] = _items
    end
    
    items.get = function(quality)
        return items.container[quality] or {}
    end
    
    items.kindList = function()
        local list = {}
        for k, v in pairs(items.container) do
            list[#list+1] = k
        end
        return list
    end
    
    -- 遍历觉醒道具表，把所有数据归入
    for i=1, item_awaken_info.getLength() do
        local itemInfo = item_awaken_info.indexOf(i)
        items.add(itemInfo.quality, itemInfo)
    end
    
    local scrollView = self:getScrollViewByName("ScrollView_items")
    
    -- 获取有几种quality
    local kinds = items.kindList()
    table.sort(kinds, function(a, b)
        return a > b
    end)
    
    local totalHeight = 0
    
    for i=1, #kinds do
        
        local kind = kinds[i]
        -- 因为每个icon栏一行5个，所以这按照图鉴里的个数/5来决定有几个item项目
        local rowNum = math.ceil(#items.get(kind) / 5)
--        local itemWidget = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/bag_BagAwakenItemHandbookFrameCell.json")
        local itemWidget = CCSItemCellBase:create("ui_layout/bag_BagAwakenItemHandbookFrameCell.json")
        
        local iconWidgets = {container = {}}
        iconWidgets.add = function(_widget)
            iconWidgets.container[#iconWidgets.container+1] = _widget
        end
        
        iconWidgets.at = function(index)
            return iconWidgets.container[index]
        end
        
        iconWidgets.count = function()
            return #iconWidgets.container
        end
        
        iconWidgets.pack = function()
            return clone(iconWidgets.container)
        end
        
        local padding = 16   -- 边距
        
        for j=1, rowNum do
--            local iconWidget = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/bag_BagAwakenItemHandbookCell.json")
            local iconWidget = CCSItemCellBase:create("ui_layout/bag_BagAwakenItemHandbookCell.json")
            itemWidget:addChild(iconWidget, 1, j)
            
            local itemSize = itemWidget:getSize()
            local iconSize = iconWidget:getSize()
            local spacing = 4    -- 位置间距
            
            itemWidget:setSize(CCSizeMake(itemSize.width, 52 + j * iconSize.height + (j-1) * spacing + padding)) -- 这里有一部分是固定高度
            iconWidget:setPositionXY((itemSize.width - iconSize.width) / 2, (j-1) * (iconSize.height + spacing) + padding)
            
            iconWidgets.add(iconWidget)
        end
        
        -- 更新下数据
        self:_updateScrollViewCell(itemWidget, iconWidgets.pack(), items.get(kind))
        
        -- 因为其加载位置的时候是反着的，所以这里重置一下位置好正过来
        local endIndex = iconWidgets.count()
        for j=1, math.floor(endIndex/2) do
            local pos1 = ccp(iconWidgets.at(j):getPosition())
            local pos2 = ccp(iconWidgets.at(endIndex - (j-1)):getPosition())
            pos1, pos2 = pos2, pos1
            iconWidgets.at(j):setPosition(pos1)
            iconWidgets.at(endIndex - (j-1)):setPosition(pos2)
        end
        
        itemWidget:setPositionY(totalHeight)
        totalHeight = totalHeight + itemWidget:getSize().height
        
        scrollView:addChild(itemWidget)

    end
    
    local newSize = CCSizeMake(scrollView:getContentSize().width, totalHeight)
    scrollView:setInnerContainerSize(newSize)
    
    -- 要跳到头部，否则默认是在底部
    scrollView:jumpToTop()
    
end

function BagAwakenItemHandBookLayer:_updateScrollViewCell(cell, subCells, data)
    
    -- 更新品质标签
    _updateLabel(cell, "Label_5", {text=G_lang:get("LANG_AWAKEN_HANDBOOK_QUALITY"..data[1].quality), stroke=Colors.strokeBrown, color=Colors.qualityColors[data[1].quality]})

    local rowNum = math.ceil(#data / 5)
    
    for i=1, rowNum do
        
        local subCell = subCells[i]

        for j=1, 5 do
            
            local _data = data[(i-1)*5+j]
            
            _updateImageView(subCell, "ImageView_item"..j, {visible=tobool(_data)})

            if _data then

                _updateImageView(subCell, "ImageView_frame"..j, {texture=G_Path.getEquipColorImage(_data.quality), texType=UI_TEX_TYPE_PLIST})
                _updateImageView(subCell, "ImageView_head"..j, {texture=_data.icon, texType=UI_TEX_TYPE_LOCAL})
                _updateImageView(subCell, "ImageView_bg"..j, {texture=G_Path.getEquipIconBack(_data.quality), texType=UI_TEX_TYPE_PLIST})
                _updateLabel(subCell, "Label_name"..j, {text=_data.name, stroke=Colors.strokeBlack, color=Colors.qualityColors[_data.quality]})
                
                subCell:registerWidgetClickEvent("ImageView_head"..j, function()
                    
                    -- 分可合成和可获取两种状态
                    local state = _data.compose_id ~= 0 and HeroAwakenItemDetailLayer.STATE_COMPOSE or HeroAwakenItemDetailLayer.STATE_GET
                    
                    local layer
                    layer = HeroAwakenItemDetailLayer.create(_data.id, state, function(_state, _layer)

                        -- 表示获取状态确认
                        if _state == HeroAwakenItemDetailLayer.STATE_GET then
                            require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_AWAKEN_ITEM, _data.id,
                                GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {2}))
                        -- 表示合成状态确认
                        elseif _state == HeroAwakenItemDetailLayer.STATE_COMPOSE then

                            local newlayer = require("app.scenes.herofoster.HeroAwakenItemComposeLayer").create(nil, _data.id, GlobalFunc.sceneToPack("app.scenes.bag.BagScene", {2}),
                                function(_itemId, _newLayer,fastCompose,num)
                                    local returnOk = function() 
                                        _layer:updateView()
                                        _newLayer:playComposeAnimation(function(event)
                                            if event == "finish" then
                                                G_MovingTip:showMovingTip(G_lang:get("LANG_AWAKEN_COMPOSE_SUCCESS_DESC"))
                                                -- 成功合成后更新合成树
                                                _newLayer:updateComposeTree(nil, false)
                                            end
                                        end)
                                    end 

                                    if not fastCompose then 
                                        -- 请求合成装备
                                        G_HandlersManager.bagHandler:sendComposeAwakenItem(_itemId)
                                        -- 监听消息
                                        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_AWAKEN_COMPOSE_ITEM_NOTI, function(_, message)
                                            if message.ret == NetMsg_ERROR.RET_OK then
                                                returnOk()
                                            end
                                            uf_eventManager:removeListenerWithTarget(self)
                                        end, self)
                                    else 
                                        G_HandlersManager.bagHandler:sendFastComposeAwakenItem(_itemId,num)
                                        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_FAST_AWAKEN_COMPOSE_ITEM_NOTI, function(_, message)
                                            if message.ret == NetMsg_ERROR.RET_OK then
                                                returnOk()
                                                _newLayer:doNotRealLabelAndAnimation(true)
                                            else 
                                                -- 不ok的情况需要刷新一下
                                                _newLayer:updateComposeTree(nil, false)
                                                _newLayer:doNotRealLabelAndAnimation(false)
                                            end
                                            uf_eventManager:removeListenerWithTarget(self)
                                        end,self)
                                    end 
                                end)
                            uf_sceneManager:getCurScene():addChild(newlayer)
                            newlayer:setParentLayer(layer)
                        end
                    end)
                    uf_sceneManager:getCurScene():addChild(layer)

                end)
                
            end
        end
    end
    
end

return BagAwakenItemHandBookLayer
