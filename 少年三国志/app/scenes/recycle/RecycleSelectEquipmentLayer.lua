-- RecycleSelectEquipmentLayer

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

local RecycleSelectEquipmentLayer = class("RecycleSelectEquipmentLayer", UFCCSModelLayer)

function RecycleSelectEquipmentLayer.create(...)
    return RecycleSelectEquipmentLayer.new("ui_layout/recycle_selectEquipmentLayer.json", nil, ...)
end

function RecycleSelectEquipmentLayer:ctor(_, _, equipments, selectEquipments)

    RecycleSelectEquipmentLayer.super.ctor(self)

    self:initSelectState(equipments, selectEquipments)

    -- 更新当前面板的信息
    
    -- 选中装备
    _updateLabel(self, "Label_selectDesc", G_lang:get("LANG_RECYCLE_SELECT_EQUIPMENT_DESC"), Colors.strokeBlack)

    -- 当前选中数
    _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)
    
end

function RecycleSelectEquipmentLayer:initSelectState(equipments, selectEquipments)
    
    self._equipments = equipments
    
    -- 因为UIListView在退出"舞台"的时候会把schedule取消，但是重新加载（retain保留起来）没有重新启用，所以这里需要再打开一次
    if self._listView then
        -- 因为这里listview中的标示update的状态量还是true（但实际上和事实不符），因其逻辑判断为问题，所以先关闭一次再开启
        self._listView:setUpdateEnabled(false)
        self._listView:setUpdateEnabled(true)
    end
    
    -- 选中的武将
    self._selectEquipments = selectEquipments or {}
    
    -- 默认选中数
    self._selectAmount = table.nums(self._selectEquipments)
    _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)
    
end

function RecycleSelectEquipmentLayer:onLayerEnter()
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
        
        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)
            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/recycle_selectEquipmentItem.json")
            item:setTouchEnabled(true)
            item:enableWidgetByName("CheckBox_selected", false)
            -- 设置其按钮响应的方法
            item:registerCheckboxEvent("CheckBox_selected", function(widget, state, isCheck)
                item:selectedCell(index, 0 )
                -- 最多5个，超过则不能再选
                if isCheck and table.nums(self._selectEquipments) >= 5 then
                    widget:setSelectedState(false)
                    G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_EQUIPMENT_LIMIT"))
                    return
                end

                -- 更新显示数目
                self._selectAmount = self._selectAmount + (isCheck and 1 or -1)
                _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)
                
                -- 选中则添加到选择列表里, 否则清空
                self._selectEquipments[item:getCellIndex()+1] = isCheck and self._equipments[item:getCellIndex()+1] or nil

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
        
        self._listView:setSelectCellHandler(function ( list, knightId, param, cell )
            local isCheck = (param and param == 1)
            -- 最多5个，超过则不能再选
            if isCheck and table.nums(self._selectEquipments) >= 5 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_SELECT_EQUIPMENT_LIMIT"))
                return
            end

            -- 更新显示数目
            self._selectAmount = self._selectAmount + (isCheck and 1 or -1)
            _updateLabel(self, "Label_selectAmount", self._selectAmount, Colors.strokeBlack)

            -- 选中则添加到选择列表里, 否则清空
            self._selectEquipments[cell:getCellIndex()+1] = isCheck and self._equipments[cell:getCellIndex()+1] or nil
            return true
        end)
        
        -- 更新cell显示
        self._listView:setUpdateCellHandler(function(list, index, cell)

            local equipment = self._equipments[index+1] -- c++从0下标开始...
            assert(equipment, "Unknown index: "..index)
            require "app.cfg.equipment_info"
            local equipmentConfig = equipment_info.get(equipment.base_id)
            
            -- 背景底图
            _updateImageView(cell, "ImageView_bg", G_Path.getEquipIconBack(equipmentConfig.quality))
            
            -- 头像
            _updateImageView(cell, "ImageView_hero_head", G_Path.getEquipmentIcon(equipmentConfig.res_id), UI_TEX_TYPE_LOCAL)
            
            cell:getImageViewByName("ImageView_hero_head"):setTouchEnabled(true)
            
            -- 头像现在需要响应事件用来显示详情
            cell:registerWidgetTouchEvent("ImageView_hero_head", function(widget, state)
                -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                if not (not state or state == 2) then
                    return
                end
                
                require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_EQUIPMENT, equipmentConfig.id) 
            end)
            
            -- 等级
            _updateLabel(cell, "Label_level", G_lang:get("LANG_RECYCLE_EQUIPMENT_ITEM_LEVEL", {level=equipment.level}))
            -- 名字
            _updateLabel(cell, "Label_name", equipmentConfig.name, Colors.strokeBlack, Colors.qualityColors[equipmentConfig.quality])
            
            -- 品质框
            _updateImageView(cell, "ImageView_pingji", G_Path.getEquipColorImage(equipmentConfig.quality, G_Goods.TYPE_EQUIPMENT), UI_TEX_TYPE_PLIST)
            
            -- 精炼
            _updateLabel(cell, "Label_Refine_Num", G_lang:get("LANG_RECYCLE_EQUIP_REFINE", {refine = equipment.refining_level}))

            local starLevel = equipment.star
            if starLevel and starLevel > 0 then
                cell:showWidgetByName("Panel_Star",true)
                for i = 1, 5 do
                    cell:showWidgetByName(string.format("Image_start_%d_full", i), i <= starLevel)
                end

                local start_pos = {x = -105, y = -11}
                cell:getPanelByName("Panel_Star"):setPositionXY(start_pos.x + 9 * (5 - starLevel), start_pos.y)
            else
                cell:showWidgetByName("Panel_Star", false)
            end

            cell:getCheckBoxByName("CheckBox_selected"):setSelectedState(tobool(self._selectEquipments[index+1]))

        end)
        
        self._listView:initChildWithDataLength(#self._equipments, 0.2)
        
    else
        
        self._listView:reloadWithLength(#self._equipments, 0, 0.2)
        
    end
    
end

function RecycleSelectEquipmentLayer:onBackKeyEvent()
    self:close()
    return true
end

function RecycleSelectEquipmentLayer:getSelecteds()
    return self._selectEquipments
end

return RecycleSelectEquipmentLayer

