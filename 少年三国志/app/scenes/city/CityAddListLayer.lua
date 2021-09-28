-- CityAddListLayer
-- 巡逻武将列表界面

-- private method

local function _updateLabel(target, name, text, stroke, color)
    
    local label = target:getLabelByName(name)
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
    img:loadTexture(texture, texType)
    
end


local CityAddListLayer = class("CityAddListLayer", UFCCSModelLayer)

function CityAddListLayer.create(...)
    return CityAddListLayer.new("ui_layout/city_SelectPatrolKnightLayer.json", nil, ...)
end

-- @param selCallback: callback when selecting a knight
-- @param backCallback: callback when clicking the back button
function CityAddListLayer:ctor(json, fun, knights, selectKnights, index, selCallback, backCallback)

    CityAddListLayer.super.ctor(self, json, fun)

    self._selCallback = selCallback
    self._backCallback = backCallback
    
    self:initData(knights, selectKnights, index)
    
    self:registerKeypadEvent(true, false)
    
end

function CityAddListLayer:initData(knights, selectKnights, index)
    
    self._index = index
    
    self:initSelectState(knights, selectKnights)
    
end

function CityAddListLayer:getCityIndex() return self._index end

function CityAddListLayer:initSelectState(knights, selectKnights)
    
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

function CityAddListLayer:onLayerLoad()
    self:registerBtnClickEvent("Button_back", function()
        if self._backCallback then
            self._backCallback()
        else
            self:close()
        end
    end)
end

function CityAddListLayer:onLayerEnter()
    
    if not self._listView then
        -- 自适应屏幕高度
        self:adapterWithScreen()
        
        -- 创建列表
        local panel = self:getPanelByName("Panel_list")
        -- 因为这里列表的高度无法适配到扣除固定尺寸大小后的大小，所以我们这里手动设置一下
        local size = panel:getSize()
        panel:setSize(CCSizeMake(size.width, display.height - self:getPanelByName("Panel_top"):getSize().height - 80))
        
        local listview = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
        self._listView = listview
        self:registerListViewEvent("Panel_list", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
        end)

        -- 分别设置创建方法和更新方法
        self._listView:setCreateCellHandler(function(list, index)

            -- 创建item
            local item = CCSItemCellBase:create("ui_layout/city_SelectPatrolKnightItem.json")
            -- 设置其按钮响应的方法
            item:setTouchEnabled(true)

            item:registerBtnClickEvent("Button_get", function()
                -- 选中则添加到选择列表里
                self._selectKnights[1] = self._knights[item:getCellIndex()+1]
                if self._selCallback then self._selCallback() end
                
            end)
            item:registerCellClickEvent(function ( cell, index )
                self._selectKnights[1] = self._knights[item:getCellIndex()+1]
                if self._selCallback then self._selCallback() end
            end)
            
            return item
        end)

        -- 更新cell显示
        self._listView:setUpdateCellHandler(function(list, index, cell)

            local knight = self._knights[index+1] -- c++从0下标开始...
            assert(knight, "Unknown index: "..index)
            local knightConfig = knight_info.get(knight.base_id)

            -- 头像
            _updateImageView(cell, "Image_icon", G_Path.getKnightIcon(knightConfig.res_id), UI_TEX_TYPE_LOCAL)
            
            cell:getImageViewByName("Image_icon"):setTouchEnabled(true)
            
            -- 头像现在需要响应事件用来显示详情
            cell:registerWidgetTouchEvent("Image_icon", function(widget, state)
                -- 对于图片(ImageView)的交互事件来讲，分为手指按下，移动和抬起几个动作, 2表示抬起，只有在抬起的时候才会响应，其余则不响应
                if state == 2 then
                    require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_KNIGHT, knightConfig.id) 
                end
            end)
            
            -- 品质框
            _updateImageView(cell, "Image_frame", G_Path.getEquipColorImage(knightConfig.quality, G_Goods.TYPE_KNIGHT), UI_TEX_TYPE_PLIST)
            
            _updateLabel(cell, "Label_content_attr1_desc", G_lang:get("LANG_CITY_ADD_LIST_ITEM_DESC", {amount=G_Me.bagData:getFragmentNumById(knightConfig.fragment_id)}))
            
            cell:getImageViewByName("Image_patrolling"):setVisible(G_Me.cityData:isPatrollingThisKnight(knight.base_id))
            
            cell:attachImageTextForBtn("Button_get", "Image_get_desc")
            cell:getButtonByName("Button_get"):setTouchEnabled(not G_Me.cityData:isPatrollingThisKnight(knight.base_id))
            
            cell:setTouchEnabled(not G_Me.cityData:isPatrollingThisKnight(knight.base_id))
            
            -- 名字
            _updateLabel(cell, "Label_name", knightConfig.advanced_level > 0 and knightConfig.name.."+"..knightConfig.advanced_level or knightConfig.name, Colors.strokeBrown, Colors.qualityColors[knightConfig.quality])
            
            -- 战术类型
            _updateLabel(cell, "Label_tactical_type", G_lang.getKnightTypeStr(knightConfig and knightConfig.character_tips or 1))
        end)
        
        self._listView:initChildWithDataLength(#self._knights, 0.2)
    else
        
        self._listView:reloadWithLength(#self._knights, 0, 0.2)
        
    end
    
end

function CityAddListLayer:onBackKeyEvent()
    self:close()
    return true
end

function CityAddListLayer:getSelecteds()
    return self._selectKnights
end

return CityAddListLayer

