

-- 装备重生之选择装备界面

local RecycleSelectEquipRebornLayer = class("RecycleSelectEquipRebornLayer", UFCCSModelLayer)

function RecycleSelectEquipRebornLayer.create(...)
    return RecycleSelectEquipRebornLayer.new("ui_layout/recycle_selectRebornEquipmentLayer.json", nil, ...)
end

function RecycleSelectEquipRebornLayer:_updateLabel(target, name, text, stroke, color)
    
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

function RecycleSelectEquipRebornLayer:_updateImageView(target, name, texture, texType)
    
    local img = target:getImageViewByName(name)
    assert(img ~= nil, "img is nil")
    img:loadTexture(texture, texType)
    
end

function RecycleSelectEquipRebornLayer:ctor(json, arg2, equipments, selectEquipments, callback)

    RecycleSelectEquipRebornLayer.super.ctor(self, json)

    self:initSelectState(equipments, selectEquipments)

    -- 更新当前面板的信息
    
    self._callback = callback    
end

function RecycleSelectEquipRebornLayer:initSelectState(equipments, selectEquipments)
    
    self._equipments = equipments
    
    -- 避免再次进入列表滑动出现问题
    if self._listView then
        self._listView:setUpdateEnabled(false)
        self._listView:setUpdateEnabled(true)
    end
    
    -- 选中的武将
    self._selectEquipments = selectEquipments or {}
    
end

function RecycleSelectEquipRebornLayer:onLayerEnter()

    self:registerKeypadEvent(true, false)

    if not self._listView then
         
        -- 自适应屏幕高度
        self:adapterWithScreen()
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_list")
        -- 因为这里列表的高度无法适配到扣除固定尺寸大小后的大小，所以我们这里手动设置一下
        local size = panel:getSize()
        -- 但是比较坑爹的是ImageView_8045的区域有一部分是透明的，所以还需要手动扣除一部分，大约30像素
        panel:setSize(CCSizeMake(size.width, display.height - self:getPanelByName("Panel_top"):getSize().height + 30))

        local listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listview
        
        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)
            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/recycle_selectRebornEquipmentItem.json")
            item:setTouchEnabled(true)
            -- 设置其按钮响应的方法
            item:registerBtnClickEvent("Button_get", function()
                -- 选中则添加到选择列表里
                self._selectEquipments[1] = self._equipments[item:getCellIndex()+1]
                if self._callback then self._callback() end
                
            end)
            item:registerCellClickEvent(function ( cell, index )
                self._selectEquipments[1] = self._equipments[item:getCellIndex()+1]
                if self._callback then self._callback() end
            end)

            return item
        end)
        
        -- 更新cell显示
        self._listView:setUpdateCellHandler(function(list, index, cell)

            local equipment = self._equipments[index+1] -- c++从0下标开始...
            assert(equipment, "Unknown index: "..index)
            require "app.cfg.equipment_info"
            local equipmentConfig = equipment_info.get(equipment.base_id)
            
            -- 背景底图
            self:_updateImageView(cell, "ImageView_bg", G_Path.getEquipIconBack(equipmentConfig.quality))
            
            -- 头像
            self:_updateImageView(cell, "ImageView_hero_head", G_Path.getEquipmentIcon(equipmentConfig.res_id), UI_TEX_TYPE_LOCAL)
            
            cell:getImageViewByName("ImageView_hero_head"):setTouchEnabled(true)
            
            -- 头像现在需要响应事件用来显示详情
            cell:registerWidgetClickEvent("ImageView_hero_head", function(widget, state)
                require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_EQUIPMENT, equipmentConfig.id) 
            end)
            
            -- 等级
            self:_updateLabel(cell, "Label_level", G_lang:get("LANG_RECYCLE_EQUIP_REBORN_ITEM_LEVEL", {level=equipment.level}))
            -- 精炼
            self:_updateLabel(cell, "Label_Refine_Num", G_lang:get("LANG_RECYCLE_EQUIP_REFINE", {refine = equipment.refining_level}))

            -- 名字
            self:_updateLabel(cell, "Label_name", equipmentConfig.name, Colors.strokeBlack, Colors.qualityColors[equipmentConfig.quality])
            
            -- 品质框
            self:_updateImageView(cell, "ImageView_pingji", G_Path.getEquipColorImage(equipmentConfig.quality, G_Goods.TYPE_EQUIPMENT), UI_TEX_TYPE_PLIST)
            
            -- 星级
            local starLevel = equipment.star
            if starLevel and starLevel > 0 then
                cell:showWidgetByName("Panel_Star",true)
                for i = 1, 5 do
                    cell:showWidgetByName(string.format("Image_start_%d_full", i), i <= starLevel)
                end
                -- 调整星星的位置，使居中
                local start_pos = {x = -105, y = -11}
                cell:getPanelByName("Panel_Star"):setPositionXY(start_pos.x + 9 * (5 - starLevel), start_pos.y)
            else
                cell:showWidgetByName("Panel_Star", false)
            end
        end)
        
        self._listView:initChildWithDataLength(#self._equipments, 0.2)        
    else        
        self._listView:reloadWithLength(#self._equipments, 0, 0.2)        
    end
    
end

function RecycleSelectEquipRebornLayer:onBackKeyEvent()
    if self._callback then
        self._callback()
    end
    self:close()
    return true
end

function RecycleSelectEquipRebornLayer:getSelecteds()
    return self._selectEquipments
end

return RecycleSelectEquipRebornLayer

