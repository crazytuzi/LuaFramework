-- RecycleSelectRebornLayer

-- private method

local function _updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
    assert(label ~= nil, "label is nil")
    if stroke then
        label:createStroke(stroke, 1)
    end
    if color then
        label:setColor(color)
    end
    
    label:setText(text)
end

local function _updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    assert(img ~= nil, "img is nil")
    img:loadTexture(texture, texType)
    
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

local RecycleSelectRebornLayer = class("RecycleSelectRebornLayer", UFCCSModelLayer)

function RecycleSelectRebornLayer.create(...)
    return RecycleSelectRebornLayer.new("ui_layout/recycle_selectKnightRebornLayer.json", nil, ...)
end

function RecycleSelectRebornLayer:ctor(_, _, knights, selectKnights, callback)

    RecycleSelectRebornLayer.super.ctor(self)

    self._callback = callback
    
    self:initSelectState(knights, selectKnights)    
end

function RecycleSelectRebornLayer:initSelectState(knights, selectKnights)
    
    self._knights = knights
    
    -- 因为UIListView在退出"舞台"的时候会把schedule取消，但是重新加载（retain保留起来）没有重新启用，所以这里需要再打开一次
    if self._listView then
        -- 因为这里listview中的标示update的状态量还是true（但实际上和事实不符），因其逻辑判断为问题，所以先关闭一次再开启
        self._listView:setUpdateEnabled(false)
        self._listView:setUpdateEnabled(true)
    end
    
    -- 选中的武将
    self._selectKnights = selectKnights or {}

end

function RecycleSelectRebornLayer:onLayerEnter()
    self:registerKeypadEvent(true, false)

    if not self._listView then
        -- 自适应屏幕高度
        self:adapterWithScreen()
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_list")
        -- 因为这里列表的高度无法适配到扣除固定尺寸大小后的大小，所以我们这里手动设置一下
        local size = panel:getSize()
        panel:setSize(CCSizeMake(size.width, display.height - self:getPanelByName("Panel_top"):getSize().height))
        
        local listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listview
        self:registerListViewEvent("Panel_list", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
        end)

        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)

            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/recycle_selectKnightRebornItem.json")
            -- 设置其按钮响应的方法
            item:setTouchEnabled(true)
            item:registerBtnClickEvent("Button_get", function()
                -- 选中则添加到选择列表里
                self._selectKnights[1] = self._knights[item:getCellIndex()+1]
                if self._callback then self._callback() end
                
            end)
            item:registerCellClickEvent(function ( cell, index )
                self._selectKnights[1] = self._knights[item:getCellIndex()+1]
                if self._callback then self._callback() end
            end)
            
            return item
        end)

        -- 更新cell显示
        self._listView:setUpdateCellHandler(function(list, index, cell)

            local knight = self._knights[index+1] -- c++从0下标开始...
            assert(knight, "Unknown index: "..index)
            local knightConfig = knight_info.get(knight.base_id)

            cell:showWidgetByName("Image_Main_Knight_Tag", knight.base_id == G_Me.bagData.knightsData:getMainKnightBaseId())

            -- 头像
            _updateImageView(cell, "Image_icon", G_Path.getKnightIcon(knightConfig.res_id), UI_TEX_TYPE_LOCAL)
            
            cell:getImageViewByName("Image_icon"):setTouchEnabled(true)
            
            -- 头像现在需要响应事件用来显示详情
            cell:registerWidgetClickEvent("Image_icon", function(widget, state)
                require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knightConfig.id) 
            end)
            
            -- 品质框
            _updateImageView(cell, "Image_frame", G_Path.getEquipColorImage(knightConfig.quality, G_Goods.TYPE_KNIGHT), UI_TEX_TYPE_PLIST)
            
            -- 等级
            _updateLabel(cell, "Label_content_level_desc", G_lang:get("LANG_RECYCLE_REBORN_LEVEL_DESC"))
            _updateLabel(cell, "Label_content_level", knight.level)
            local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_content_level_desc"),
            cell:getLabelByName("Label_content_level")}, ALIGN_LEFT)
            cell:getLabelByName("Label_content_level_desc"):setPosition(getPosition(1))
            cell:getLabelByName("Label_content_level"):setPosition(getPosition(2))

            -- 突破
            _updateLabel(cell, "Label_content_advance_desc", G_lang:get("LANG_RECYCLE_REBORN_ADVANCE_DESC"))
            _updateLabel(cell, "Label_content_advance", knightConfig.advanced_level > 0 and '+'..knightConfig.advanced_level or '0')
            local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_content_advance_desc"),
            cell:getLabelByName("Label_content_advance")}, ALIGN_LEFT)
            cell:getLabelByName("Label_content_advance_desc"):setPosition(getPosition(1))
            cell:getLabelByName("Label_content_advance"):setPosition(getPosition(2))

            -- 天命
            _updateLabel(cell, "Label_content_destiny_desc", G_lang:get("LANG_RECYCLE_REBORN_DESTINY_DESC"))
            _updateLabel(cell, "Label_content_destiny", G_lang:get("LANG_RECYCLE_REBORN_DESTINY_AMOUNT", {destiny=knight.halo_level}))
            local getPosition = _autoAlign(ccp(0, 0), {cell:getLabelByName("Label_content_destiny_desc"),
            cell:getLabelByName("Label_content_destiny")}, ALIGN_LEFT)
            cell:getLabelByName("Label_content_destiny_desc"):setPosition(getPosition(1))
            cell:getLabelByName("Label_content_destiny"):setPosition(getPosition(2))
            
            -- 名字
            _updateLabel(cell, "Label_name", knightConfig.name, Colors.strokeBrown, Colors.qualityColors[knightConfig.quality])
            
            -- 战术类型
            _updateLabel(cell, "Label_tactical_type", G_lang.getKnightTypeStr(knightConfig and knightConfig.character_tips or 1))

            -- 化神等级
            local godTitleLabel = cell:getLabelByName("Label_God_Level")
            local godImage = cell:getImageViewByName("Image_God_Level")
            if knightConfig.god_level == 0 and knight.pulse_level == 0 then
                godTitleLabel:setVisible(false)
                godImage:setVisible(false)
            else
                local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
                godTitleLabel:setVisible(true)
                godImage:setVisible(true)
                local nowGodLevel = G_Me.bagData.knightsData:getGodLevel(knight.id)
                godTitleLabel:setText(HeroGodCommon.getDisplyLevel4(nowGodLevel, knightConfig.quality))
                godImage:loadTexture(G_Path.getGodQualityShuiYin(knightConfig.quality))
            end

            --觉醒等级
            local stars = G_Me.bagData.knightsData:getKnightAwakenLevelByKnightId(knight.id) or -1
            cell:showWidgetByName("Panel_Star", stars >= 0)
            if stars >= 0 then 
                cell:showWidgetByName("Image_Star1", stars >= 1)
                cell:showWidgetByName("Image_Star2", stars >= 2)
                cell:showWidgetByName("Image_Star3", stars >= 3)
                cell:showWidgetByName("Image_Star4", stars >= 4)
                cell:showWidgetByName("Image_Star5", stars >= 5)
                cell:showWidgetByName("Image_Star6", stars >= 6)
            end

            --以下代码在2.0.50中用来回退觉醒等级
            cell:showWidgetByName("Panel_Star", false)
        end)
        
        self._listView:initChildWithDataLength(#self._knights, 0.2)
    else
        
        self._listView:reloadWithLength(#self._knights, 0, 0.2)
        
    end
    
end

function RecycleSelectRebornLayer:onBackKeyEvent()
    self:close()
    return true
end

function RecycleSelectRebornLayer:getSelecteds()
    return self._selectKnights
end

return RecycleSelectRebornLayer

