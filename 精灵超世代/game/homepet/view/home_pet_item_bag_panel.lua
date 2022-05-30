--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年6月5日
-- @description    : 
        -- 萌宠背包面板, 包括选择食物和道具面板
---------------------------------
HomePetItemBagPanel = HomePetItemBagPanel or BaseClass(BaseView)

local controller = HomepetController:getInstance()
local model = controller:getModel()

--背包
local backpack_model = BackpackController:getInstance():getModel()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function HomePetItemBagPanel:__init()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("homepet_travellingbag", "homepet_travellingbag"), type = ResourcesType.plist}
    }
    self.layout_name = "homepet/home_pet_item_bag_panel"

    self.show_type = HomepetConst.Item_bag_show_type.eBagItemType

end

function HomePetItemBagPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 


    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("物品"))

    self.close_btn = main_panel:getChildByName("close_btn")
    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("获取更多"))


    self.tab_container = self.main_container:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("食 物"),
        [2] = TI18N("道 具"),
        [3] = TI18N("珍 品"),
    }
    self.tab_item_type = {
        [1] = BackPackConst.item_type.HOME_PET_FOOD,
        [2] = BackPackConst.item_type.HOME_PET_ITEM,
        [3] = BackPackConst.item_type.HOME_PET_TREASURE,
    }
    self.tab_list = {}
    for i=1,3 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(Config.ColorData.data_new_color4[6])
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end

    self.lay_srollview = self.main_container:getChildByName("lay_srollview")

end

function HomePetItemBagPanel:register_event(  )
    registerButtonEventListener(self.background, function() self:onClosedBtn() end,false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn() end ,true, 2)
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, 1)


    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end

        --道具增加
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
        if not self.item_scrollview then return end
        if bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
            if self.tab_object then 
                self:updateList(self.tab_object.index)
            end
        end
    end)
    --物品道具删除 
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code,temp_add)
        if not self.item_scrollview then return end
        if bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
            if self.tab_object then 
                self:updateList(self.tab_object.index)
            end
        end
    end)
    --物品道具变化
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_add)
        if not self.item_scrollview then return end
        if bag_code == BackPackConst.Bag_Code.PETBACKPACK then 
            if self.tab_object then 
                self:updateList(self.tab_object.index)
            end
        end
    end)
end

--关闭
function HomePetItemBagPanel:onClosedBtn()
    controller:openHomePetItemBagPanel(false)
end

--获取更多
function HomePetItemBagPanel:onComfirmBtn()
    if not self.tab_object then return end
    local sub_index = 1 --默认食物
    if self.tab_item_type[self.tab_object.index] ==  BackPackConst.item_type.HOME_PET_ITEM then
        sub_index = 2 --道具
    end
    HomeworldController:getInstance():openHomeworldShopWindow(true, {index = 2, sub_index = sub_index})
end

--点击item
function HomePetItemBagPanel:onClickItemIndex(index)
    -- body self.item_type_list[index]
end


-- 切换标签页
function HomePetItemBagPanel:changeSelectedTab( index )
    if self.tab_object and self.tab_object.index == index then return end
    if self.tab_list[index] and self.tab_list[index].is_lock then return end

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(Config.ColorData.data_new_color4[6])
        self.tab_object.title:disableEffect(cc.LabelEffect.SHADOW)
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]

    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(Config.ColorData.data_new_color4[1])
        self.tab_object.title:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
    end

    --数据
    self:updateList(index)

    if self.tab_item_type[index] == BackPackConst.item_type.HOME_PET_TREASURE then
        self.comfirm_btn:setVisible(false)
    else
        self.comfirm_btn:setVisible(true)
    end 
end


--setting.index 选择页签  参考 HomepetConst.Item_bag_tab_type
--setting.show_type 显示类型 参考 HomepetConst.Item_bag_show_type
--setting.select_item_id 我选择的对应id
--setting.other_item_id 另外一个位置选择的道具id
--setting.select_key 当前选中的key位置

function HomePetItemBagPanel:openRootWnd(setting)
    local setting = setting or {}
    local index = setting.index or HomepetConst.Item_bag_tab_type.eFoodType
    self.show_type = setting.show_type or HomepetConst.Item_bag_show_type.eBagItemType
    self.select_item_id = setting.select_item_id
    self.other_item_id = setting.other_item_id
    self.select_key = setting.select_key

    self:checkTabUnlockInfo()
    self:changeSelectedTab(index)
end

function HomePetItemBagPanel:checkTabUnlockInfo()
    local _setLock = function(tab)
        if not tab then return end
        tab.is_lock = true
        setChildUnEnabled(true, tab.tab_btn)
    end
    if self.show_type == HomepetConst.Item_bag_show_type.eSelectFoodType then
        _setLock(self.tab_list[2])
        _setLock(self.tab_list[3])
    elseif self.show_type == HomepetConst.Item_bag_show_type.eSelectItemType then
        _setLock(self.tab_list[1])
        _setLock(self.tab_list[3])
    end
end

function HomePetItemBagPanel:updateList(index)
    if not index then return end
    if self.item_scrollview == nil then
        local scroll_view_size = self.lay_srollview:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 618,                -- 单元的尺寸width
            item_height = 145,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    local item_type = self.tab_item_type[index] or BackPackConst.item_type.HOME_PET_ITEM
    -- 
    local list = backpack_model:getBagItemList(BackPackConst.Bag_Code.PETBACKPACK)
    self.show_list = {}
    for k,goods_vo in pairs(list) do
        if goods_vo.config and goods_vo.config.type == item_type then
            if self.other_item_id and self.other_item_id == goods_vo.id and goods_vo.quantity == 1 then
                --数量只有一个不 用加入
            else
                table_insert(self.show_list, goods_vo)    
            end
            
        end
    end
    local sort_func = SortTools.tableUpperSorter({"quality", "base_id"})
    table_sort(self.show_list, sort_func)
    self.item_scrollview:reloadData()

    if #self.show_list == 0 then
        if self.tab_item_type[index] == BackPackConst.item_type.HOME_PET_ITEM then
            commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("一个道具都没有噢，快去商店获取吧~")})
        elseif self.tab_item_type[index] == BackPackConst.item_type.HOME_PET_FOOD then
            commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("一个食物都没有噢，快去商店获取吧~")})
        else--珍品
            commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("一个珍品都没有噢，快让宠物去旅行获取吧~")})
        end
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HomePetItemBagPanel:createNewCell(width, height)
   local cell = HomePetItemBagItem.new(width, height, self)
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HomePetItemBagPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HomePetItemBagPanel:updateCellByIndex(cell, index)
    cell.index = index
    local goods_vo = self.show_list[index]
    if not goods_vo then return end
    local index = HomepetConst.Item_bag_tab_type.eFoodType
    if self.tab_object then
        index = self.tab_object.index
    end
    --是否我选择了
    local is_select = self.select_item_id and self.select_item_id == goods_vo.id
    --是否另外一个选择了
    local is_other_select = self.other_item_id and self.other_item_id == goods_vo.id
    
    cell:setData(goods_vo, index, is_select, is_other_select)
end

-- --点击cell .需要在 createNewCell 设置点击事件
-- function HomePetItemBagPanel:onCellTouched(cell)
--     if not cell.index then return end
--     local goods_vo = self.show_list[cell.index]
--     if not goods_vo then return end

-- end


function HomePetItemBagPanel:close_callback()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self.item_list = {}

    controller:openHomePetItemBagPanel(false)
end


-- 子项
HomePetItemBagItem = class("HomePetItemBagItem", function()
    return ccui.Widget:create()
end)

function HomePetItemBagItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function HomePetItemBagItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("homepet/home_pet_item_bag_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")

    self.select_btn = self.main_container:getChildByName("select_btn")
    self.select_btn_label = self.select_btn:getChildByName("label")
    self.select_btn_label:setString(TI18N("选 择"))

    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn_label = self.cancel_btn:getChildByName("label")
    self.cancel_btn_label:setString(TI18N("取消选择"))

    self.item_node = self.main_container:getChildByName("item_node")
    self.item = BackPackItem.new(true,false,nil,0.8)
    self.item_node:addChild(self.item)
    -- self.item:setDefaultTip()
    self.name = self.main_container:getChildByName("name")
    self.name_desc_1 = self.main_container:getChildByName("name_desc_1")
    self.name_desc_2 = self.main_container:getChildByName("name_desc_2")

    self.name_desc_3 = createRichLabel(20, cc.c4b(0x8e,0x81,0x77,0xff), cc.p(0,1), cc.p(142, 60), 6, nil, 280)
    self.main_container:addChild(self.name_desc_3)
end

function HomePetItemBagItem:register_event( )
    registerButtonEventListener(self.select_btn, function() self:onSelectBtn()  end ,true, 1)
    registerButtonEventListener(self.cancel_btn, function() self:onCancelBtn()  end ,true, 1)
end

--选择
function HomePetItemBagItem:onSelectBtn()
    if not self.data then return end
    if not self.parent then return end

    if self.tab_index and self.tab_index == HomepetConst.Item_bag_tab_type.eTreasureType then
        local count = self.data.quantity
        controller:openHomePetItemSellPanel(true, {goods_vo = self.data, max_count = count})
    else
        if self.parent.show_type ~= HomepetConst.Item_bag_show_type.eBagItemType then--背包类型 
            GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_SELECT_ITEM_CALLBACK_EVENT, self.parent.select_key, self.data.id)
            self.parent:onClosedBtn()
        end
    end
end

--取消选择
function HomePetItemBagItem:onCancelBtn()
    if not self.data then return end
    if not self.parent then return end
    if self.parent.show_type ~= HomepetConst.Item_bag_show_type.eBagItemType then--背包类型 
        --发协议select_key
        GlobalEvent:getInstance():Fire(HomepetEvent.HOME_PET_SELECT_ITEM_CALLBACK_EVENT, self.parent.select_key)
        self.parent:onClosedBtn()
    end
end

--data 是goods_vo
--tab_index 当前tab页签
--is_select 是否选择 选择中会用到
--is_other_select 是否他人已经选择
function HomePetItemBagItem:setData(data, tab_index, is_select, is_other_select)
    if not data then return end
    self.data = data
    self.tab_index = tab_index
    local config = data.config
    if config then 
        if is_other_select then
            self.item:setBaseData(config.id, data.quantity - 1)
        else
            self.item:setBaseData(config.id, data.quantity)
        end
        self.name:setString(config.name)
        self.name_desc_1:setString(config.type_desc)
        self.name_desc_2:setString(config.use_desc)
        self.name_desc_3:setString(config.desc)
    end
    if tab_index == HomepetConst.Item_bag_tab_type.eTreasureType then
        --是珍品
        self:setSellBtn()
    else
        self:setBtnStatus(is_select)
    end
end

--is_select 是否选择 选择中会用到
function HomePetItemBagItem:setBtnStatus(is_select)
    if not self.parent then return end
    local is_select = is_select or false
    if self.parent.show_type == HomepetConst.Item_bag_show_type.eSelectFoodType then--选择食物类型
        self.cancel_btn:setVisible(is_select)
        self.select_btn:setVisible(not is_select)
    elseif self.parent.show_type == HomepetConst.Item_bag_show_type.eSelectItemType then--选择道具类型
        self.cancel_btn:setVisible(is_select)
        self.select_btn:setVisible(not is_select)
    elseif self.parent.show_type == HomepetConst.Item_bag_show_type.eBagItemType then--背包类型
        self.cancel_btn:setVisible(false)
        self.select_btn:setVisible(false)
    end
end

function HomePetItemBagItem:setSellBtn()
    self.cancel_btn:setVisible(false)
    self.select_btn:setVisible(true)
    self.select_btn_label:setString(TI18N("出售"))
end

function HomePetItemBagItem:DeleteMe()
    if self.item_list then
        for i,item in ipairs(self.item_list) do
            item.honor_item:DeleteMe()
        end
        self.item_list = {}
    end

    self:removeAllChildren()
    self:removeFromParent()
end