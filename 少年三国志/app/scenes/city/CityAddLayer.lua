-- CityAddLayer
-- 领地添加巡逻武将界面

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

require("app.cfg.city_info")

local CityAddLayer = class("CityAddLayer", UFCCSNormalLayer)

function CityAddLayer.create(...)
    return CityAddLayer.new("ui_layout/city_PatrolAddMainLayer.json", nil, ...)
end

function CityAddLayer:ctor(_, _, index)
    
    CityAddLayer.super.ctor(self)
    
    -- 手动适配一下位置
    local panel = self:getPanelByName("Panel_add")
    panel:setPositionY(panel:getPositionY() + (display.height - 853) * 0.4)
    
    self:initData(index)

end

function CityAddLayer:initData(index)
        
    -- 记录一下城池的索引
    self._index = index
    
end

function CityAddLayer:getCityIndex() return self._index end

function CityAddLayer:onLayerEnter()
    
    self:_initCityAddLayer()
    
end

function CityAddLayer:_initCityAddLayer()

    local city = city_info.get(self._index)
    assert(city, "Could not find the city info with id: "..self._index)
    
    -- 背景界面需要更新，未来打算根据city_info里的资源id来读取
    _updateImageView(self, "Image_bg", {texture=G_Path.getCityBGPathWithId(city.pic2)})
    
    -- 更新下城市名称
    _updateImageView(self, "Image_city_name", {texture=G_Path.getCityNamePathWithId(city.id)})
    
    -- 添加按钮动画
    local addBtn = self:getButtonByName("Button_add")
    addBtn:setOpacity(255)
    addBtn:stopAllActions()
    addBtn:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(1), CCFadeIn:create(1))))
    
    -- 城池描述
--    _updateLabel(self, "Label_patrol_desc", {text=city.patrol_directions})

    if not self._listView then
        
        local list = self:getPanelByName("Panel_content")
        self._listView = CCSListViewEx:createWithPanel(list, LISTVIEW_DIR_VERTICAL)
            
        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)
            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/city_PatrolAddAwardItem.json")
            if index+1 == 3 then
                local size = item:getSize()
                item:setSize(CCSizeMake(size.width, size.height/2))
            end
            
            return item
        end)
        
    end

    self._listView:setUpdateCellHandler(function(list, index, cell)

        if index+1 == 3 then
            -- 最后一段显示文字
            cell:showWidgetByName("Panel_content", true)
            cell:showWidgetByName("Panel_award", false)
            
            -- 简介文字
            _updateLabel(cell, "Label_content", {text=city.directions})
            
            -- xx简介
            _updateLabel(cell, "Label_city_desc", {text=city.name..G_lang:get("LANG_CITY_ADD_CITY_DESC"), stroke=Colors.strokeBrown, border = 2})
            
            local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_city_desc")}, ALIGN_LEFT)
            cell:getLabelByName("Label_city_desc"):setPosition(getPosition(1))
            
        else
            cell:showWidgetByName("Panel_content", false)
            cell:showWidgetByName("Panel_award", true)

            -- xx特长/名将
            _updateLabel(cell, "Label_city_specialty", {text=city.name..G_lang:get(index+1 == 1 and "LANG_CITY_ADD_CITY_KNIGHT" or "LANG_CITY_ADD_CITY_SPECIALTY"), stroke=Colors.strokeBrown, border = 2})

            --（巡逻时有几率获得）
            _updateLabel(cell, "Label_city_specialty_desc", {text=G_lang:get("LANG_CITY_ADD_CITY_SPECIALTY_DESC")})

            local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_city_specialty"), cell:getLabelByName("Label_city_specialty_desc")}, ALIGN_LEFT)
            cell:getLabelByName("Label_city_specialty"):setPosition(getPosition(1))
            cell:getLabelByName("Label_city_specialty_desc"):setPosition(getPosition(2))
            
            if index+1 == 1 then
                
                for i=1, 4 do
                    local _value = city["drop_knight_"..i]
                    if _value ~= 0 then

                        _updateImageView(cell, "ImageView_item"..i, {visible=true})

                        local _type = G_Goods.TYPE_KNIGHT
                        local good = G_Goods.convert(_type, _value)

                        -- 背景
                        _updateImageView(cell, 'ImageView_bg'..i, {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
                        -- icon
                        _updateImageView(cell, 'ImageView_head'..i, {texture=good.icon})
                        -- 品级框
                        _updateImageView(cell, 'ImageView_frame'..i, {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})
                        -- 名称
                        _updateLabel(cell, "Label_name"..i, {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
                        -- 数量
    --                        _updateLabel(cell, "Label_amount"..i, {text='x'..awards[index*4 + i].size, stroke=Colors.strokeBlack})

                        -- 头像现在需要响应事件用来显示详情
                        cell:registerWidgetTouchEvent("ImageView_head"..i, function(widget, state)
                            -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                            if state == 2 then
                                require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
                            end
                        end)

                    else
                        _updateImageView(cell, "ImageView_item"..i, {visible=false})
                    end
                end
                
            else
                
                local count = 1
                for i=1, 3 do
                    local _type = city["type_"..i]
                    if _type ~= 0 then
                        
                        count = count + 1
                        
                        _updateImageView(cell, "ImageView_item"..i, {visible=true})

                        local _value = city["value_"..i]
                        local _size = city["size_"..i]
                        local good = G_Goods.convert(_type, _value)

                        -- 背景
                        _updateImageView(cell, 'ImageView_bg'..i, {texture=G_Path.getEquipIconBack(good.quality), texType=UI_TEX_TYPE_PLIST})
                        -- icon
                        _updateImageView(cell, 'ImageView_head'..i, {texture=good.icon})
                        -- 品级框
                        _updateImageView(cell, 'ImageView_frame'..i, {texture=G_Path.getEquipColorImage(good.quality, good.type), texType=UI_TEX_TYPE_PLIST})
                        -- 名称
                        _updateLabel(cell, "Label_name"..i, {text=good.name, color=Colors.qualityColors[good.quality], stroke=Colors.strokeBlack})
                        -- 数量
    --                        _updateLabel(cell, "Label_amount"..i, {text='x'..awards[index*4 + i].size, stroke=Colors.strokeBlack})

                        -- 头像现在需要响应事件用来显示详情
                        cell:registerWidgetTouchEvent("ImageView_head"..i, function(widget, state)
                            -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                            if state == 2 then
                                require("app.scenes.common.dropinfo.DropInfo").show(good.type, good.value)
                            end
                        end)
                    end
                end
                
                for i=count, 4 do
                    _updateImageView(cell, "ImageView_item"..i, {visible=false})
                end
                
            end
        end

    end)
    
    self._listView:initChildWithDataLength(3)
    
    -- 点击添加巡逻武将
    _updateLabel(self, "Label_add_desc", {text=G_lang:get("LANG_CITY_ADD_BUTTON_DESC"), stroke=Colors.strokeBlack})
    
    -- 每次巡逻，都可获得巡逻武将的碎片哦！
    _updateLabel(self, "Label_award_desc", {text=G_lang:get("LANG_CITY_ADD_BUTTON_DETAIL_DESC"), stroke=Colors.strokeBlack})
    
end

return CityAddLayer
