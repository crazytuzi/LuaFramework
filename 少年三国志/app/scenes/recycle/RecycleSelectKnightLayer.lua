-- RecycleSelectKnightLayer

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

local RecycleSelectKnightLayer = class("RecycleSelectKnightLayer", UFCCSModelLayer)

function RecycleSelectKnightLayer.create(...)
    return RecycleSelectKnightLayer.new("ui_layout/recycle_selectKnightLayer.json", nil, ...)
end

function RecycleSelectKnightLayer:ctor(_, _, knights, selectKnights)

    RecycleSelectKnightLayer.super.ctor(self)

    self:initSelectState(knights, selectKnights)

    -- 更新当前面板的信息
    
    -- 选中武将
    _updateLabel(self, "Label_selectDesc", G_lang:get("LANG_RECYCLE_SELECT_KNIGHT_DESC"), Colors.strokeBrown)

    -- 当前选中数
    _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBrown)

end

function RecycleSelectKnightLayer:initSelectState(knights, selectKnights)
    
    self._knights = knights
    
    -- 因为UIListView在退出"舞台"的时候会把schedule取消，但是重新加载（retain保留起来）没有重新启用，所以这里需要再打开一次
    if self._listView then
        -- 因为这里listview中的标示update的状态量还是true（但实际上和事实不符），因其逻辑判断为问题，所以先关闭一次再开启
        self._listView:setUpdateEnabled(false)
        self._listView:setUpdateEnabled(true)
    end
    
    -- 选中的武将
    self._selectKnights = selectKnights or {}
    
    -- 默认选中数
    self._selectAmount = table.nums(self._selectKnights)
    _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)

end

function RecycleSelectKnightLayer:onLayerEnter()
    
    self:registerKeypadEvent(true, false)

    if not self._listView then
        -- 自适应屏幕高度
        self:adapterWithScreen()
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_list")
        -- 因为这里列表的高度无法适配到扣除固定尺寸大小后的大小，所以我们这里手动设置一下
        local size = panel:getSize()
        -- 但是比较坑爹的是ImageView_8045的区域有一部分是透明的，所以还需要手动扣除一部分，大约30像素
        panel:setSize(CCSizeMake(size.width, display.height - self:getPanelByName("Panel_top"):getSize().height - self:getImageViewByName("ImageView_8045"):getSize().height + 30))
        
        local listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listview
        self:registerListViewEvent("Panel_list", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
        end)
        self._listView:setSelectCellHandler(function ( list, knightId, param, cell )
            __Log("knightId:%d, param:%d", knightId, param)
                local isCheck = (param and param == 1)
                if isCheck and table.nums(self._selectKnights) >= 5 then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_KNIGHT_LIMIT"))
                    return false
                end
                
                -- 更新显示数目
                self._selectAmount = self._selectAmount + (isCheck and 1 or -1)
                _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)
                
                -- 选中则添加到选择列表里, 否则清空
                self._selectKnights[cell:getCellIndex()+1] = isCheck and self._knights[cell:getCellIndex()+1] or nil
                return true
        end)
        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)
            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/recycle_selectKnightItem.json")
            -- 设置其按钮响应的方法
            item:enableWidgetByName("CheckBox_selected", false)
            item:setTouchEnabled(true)
            item:registerCheckboxEvent("CheckBox_selected", function(widget, state, isCheck)
                item:selectedCell(index, 0 )
                -- 最多5个，超过则不能再选
                if isCheck and table.nums(self._selectKnights) >= 5 then
                    widget:setSelectedState(false)
                    G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_KNIGHT_LIMIT"))
                    return
                end
                
                -- 更新显示数目
                self._selectAmount = self._selectAmount + (isCheck and 1 or -1)
                _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)
                
                -- 选中则添加到选择列表里, 否则清空
                self._selectKnights[item:getCellIndex()+1] = isCheck and self._knights[item:getCellIndex()+1] or nil
                
            end)
            item:registerCellClickEvent(function ( cell, index )
                local checkbox = item:getCheckBoxByName("CheckBox_selected")
                if checkbox then
                    checkbox:setSelectedState(not checkbox:getSelectedState())
                    local ret = item:selectedCell(index, checkbox:getSelectedState() and 1 or 0)
                    if checkbox:getSelectedState() and not ret then
                        checkbox:setSelectedState(false)
                    end     
                end
            end) 

            return item
        end)

        -- 更新cell显示
        self._listView:setUpdateCellHandler(function(list, index, cell)

            local knight = self._knights[index+1] -- c++从0下标开始...
            assert(knight, "Unknown index: "..index)
            local knightConfig = knight_info.get(knight.base_id)

            -- 头像
            _updateImageView(cell, "ImageView_hero_head", G_Path.getKnightIcon(knightConfig.res_id), UI_TEX_TYPE_LOCAL)
            
            cell:getImageViewByName("ImageView_hero_head"):setTouchEnabled(true)
            
            -- 头像现在需要响应事件用来显示详情
            cell:registerWidgetTouchEvent("ImageView_hero_head", function(widget, state)
                -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                if not (not state or state == 2) then
                    return
                end
                
                require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knightConfig.id) 
            end)
            
            -- 品质框
            _updateImageView(cell, "ImageView_pingji", G_Path.getEquipColorImage(knightConfig.quality, G_Goods.TYPE_KNIGHT), UI_TEX_TYPE_PLIST)
            
            -- 等级和突破
            _updateLabel(cell, "Label_level", G_lang:get("LANG_RECYCLE_KNIGHT_ITEM_LEVEL", {level=knight.level, jingjie=knightConfig.advanced_level > 0 and '+'..knightConfig.advanced_level or '0'}), nil)
            -- 名字
            _updateLabel(cell, "Label_name", knightConfig.name, Colors.strokeBrown, Colors.qualityColors[knightConfig.quality])
            -- 星级
--            for i=1, 6 do
--                cell:getImageViewByName("ImageView_star_dark"..i):setVisible(i > knightConfig.star)
--            end
            -- 资质
--            _updateLabel(cell, "Label_potential", G_lang:get("LANG_RECYCLE_KNIGHT_ITEM_POTENTIAL", {potential = knightConfig.potential}), Colors.strokeBlack) 
            -- 官职
--            _updateLabel(cell, "Label_title", G_lang:get("LANG_RECYCLE_KNIGHT_ITEM_TITLE"), Colors.strokeBlack)
--            _updateLabel(cell, "Label_title_desc", G_lang:get("LANG_RECYCLE_KNIGHT_ITEM_TITLE_DESC", {title = knightConfig.job}), Colors.strokeBlack)
            -- 战力
--            _updateLabel(cell, "Label_power", G_lang:get("LANG_RECYCLE_KNIGHT_ITEM_POWER"), Colors.strokeBlack)
--            _updateLabel(cell, "Label_power_desc", G_lang:get("LANG_RECYCLE_KNIGHT_ITEM_POWER_DESC", {power = 123456}), Colors.strokeBlack)
            -- 级别
--            if knightConfig.advanced_level > 0 then
--                cell:getLabelByName("Label_jingjie"):setVisible(true)
--                _updateLabel(cell, "Label_jingjie", '+'..knightConfig.advanced_level, Colors.strokeBlack)
--            else
--                cell:getLabelByName("Label_jingjie"):setVisible(false)
--            end
            -- 已选中
            cell:getCheckBoxByName("CheckBox_selected"):setSelectedState(tobool(self._selectKnights[index+1]))

        end)
        
        self._listView:initChildWithDataLength(#self._knights, 0.2)
    else
        
        self._listView:reloadWithLength(#self._knights, 0, 0.2)
        
    end
    
end

function RecycleSelectKnightLayer:onBackKeyEvent()
    self:close()
    return true
end

function RecycleSelectKnightLayer:getSelecteds()
    return self._selectKnights
end

return RecycleSelectKnightLayer

