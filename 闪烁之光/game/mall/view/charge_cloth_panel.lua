-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      神装礼包(现改为自选礼包,触发式)
-- <br/>Create: 2019-11-15
-- --------------------------------------------------------------------
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format
local _table_remove = table.remove

ChargeClothPanel = ChargeClothPanel or BaseClass()

function ChargeClothPanel:__init(parent, offset_y)
    self.is_init = true
    self.parent = parent
    self.offset_y = offset_y or 0

    self:loadResListCompleted()
end

function ChargeClothPanel:loadResListCompleted( )
	self:createRootWnd()
    self:registerEvent()
end

function ChargeClothPanel:createRootWnd( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_value_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    local con_size = self.main_container:getContentSize()
    self.vip_tips_txt = createLabel(20, 1, cc.c4b(75,64,111,255), con_size.width - 10, 842, TI18N("均可获得vip积分"), self.main_container, 2, cc.p(1, 0.5))

    self.tips_txt = self.main_container:getChildByName("tips_txt")
    self.tips_txt:setVisible(true)
    self.tips_txt:setString(TI18N("自选材料，特惠直购，助你战力飞升"))
    self.tips_txt:setPositionY(850)
    self.item_list = self.main_container:getChildByName("item_list")
    local list_size = self.item_list:getContentSize()
    local scroll_view_size = cc.size(list_size.width, list_size.height+self.offset_y)
	local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 680,               -- 单元的尺寸width
        item_height = 152,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(0, -self.offset_y) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)

    local image_1 = self.main_container:getChildByName("image_1")
    image_1:setContentSize(cc.size(list_size.width+10, list_size.height+self.offset_y+20))
    local image_pos_y = image_1:getPositionY()
    image_1:setPositionY(image_pos_y - self.offset_y)
end

function ChargeClothPanel:createNewCell(  )
    local cell = ChargeClothItem.new()
    cell:addCallBack(handler(self, self.onClickCallBack))
	return cell
end

function ChargeClothPanel:numberOfCells(  )
    if not self.cloth_data then return 0 end
    return #self.cloth_data
end

function ChargeClothPanel:updateCellByIndex( cell, index )
    if not self.cloth_data then return end
    cell.index = index
    local cell_data = self.cloth_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ChargeClothPanel:onClickCallBack( charge_id )
    if charge_id then
        self.cloth_charge_id = charge_id
    end
end

function ChargeClothPanel:registerEvent( )
    if self.update_clothes_data == nil then
        self.update_clothes_data = GlobalEvent:getInstance():Bind(MallEvent.Get_Chose_Shop_Data_Event,function(data)
            self:updateItemData(data)
        end)
    end

    if self.update_cloth_charge_data == nil then
        self.update_cloth_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function(data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if self.cloth_charge_id and charge_config and data.status == 1 and data.charge_id == self.cloth_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
                end
            end
        end)
    end
end

function ChargeClothPanel:updateItemData( data )
    if self.cloth_charge_id and self.item_scrollview then
        for _,n_data in pairs(data.list or {}) do
            for k,c_data in pairs(self.cloth_data) do
                if n_data.id == c_data.id then
                    for key,val in pairs(n_data) do
                        c_data[key] = val
                        c_data.is_sell_out = (n_data.buy_num >= n_data.limit_num)
                    end
                    break
                end
            end
        end
        local item_list = self.item_scrollview:getActiveCellList()
        for k,item in pairs(item_list) do
            if item:getChargeId() == self.cloth_charge_id then
                self.item_scrollview:resetItemByIndex(item.index)
                break
            end
        end
        self.cloth_charge_id = nil
    else
        self:setData(data)
    end
end

function ChargeClothPanel:setData( data )
    if not data then return end

    self.cloth_data = {}
    for k,v in pairs(data.list or {}) do
        v.is_sell_out = (v.buy_num >= v.limit_num)
        _table_insert(self.cloth_data, v)
    end

    self:reloadItemList()
end

function ChargeClothPanel:reloadItemList(  )
    for i = #self.cloth_data, 1, -1 do
        local data = self.cloth_data[i]
        if data.is_sell_out and data.price == 0 then -- 0元礼包售罄后不再显示
            _table_remove(self.cloth_data, i)
        end
    end
    local function sortFunc( objA, objB )
        if objA.is_sell_out and not objB.is_sell_out then
            return false
        elseif not objA.is_sell_out and objB.is_sell_out then
            return true
        elseif objA.rank == objB.rank then -- 排序一致的话，结束时间小的放到前面
            return objA.end_time < objB.end_time
        else
            return objA.rank < objB.rank
        end
    end
    _table_sort(self.cloth_data, sortFunc)
    self.item_scrollview:reloadData()
end

function ChargeClothPanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
        self.is_init = false
        MallController:getInstance():sender27800()
    elseif self.cloth_data and next(self.cloth_data) ~= nil then
        self:reloadItemList()
    end
end

function ChargeClothPanel:addChild( node )
	if not tolua.isnull(self.root_wnd) and not tolua.isnull(node) then
        self.root_wnd:addChild(node)
    end
end

function ChargeClothPanel:setPosition( pos )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos)
    end
end

function ChargeClothPanel:__delete()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_clothes_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_clothes_data)
        self.update_clothes_data = nil
    end

    if self.update_cloth_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_cloth_charge_data)
        self.update_cloth_charge_data = nil
    end
end


-----------------------@ item
ChargeClothItem = class("ChargeClothItem", function()
	return ccui.Widget:create()
end)

function ChargeClothItem:ctor()
    self:configUI()
    self:registerEvent()

    self.touch_buy_cloth = true
end

function ChargeClothItem:configUI(  )
 --    self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_privilege_item"))
    
 --    self.size = cc.size(227, 485)
 --    self:setAnchorPoint(cc.p(0, 0))
 --    self:addChild(self.root_wnd)
	-- self:setCascadeOpacityEnabled(true)
	-- self:setContentSize(self.size)
	-- self:setTouchEnabled(true)
	-- self:setSwallowTouches(false)

 --    self.container = self.root_wnd:getChildByName("container")
 --    self.container:setSwallowTouches(false)

 --    self.name_sp = self.container:getChildByName("name_sp")
 --    self.icon_sp = self.container:getChildByName("icon_sp")
 --    self.price_txt = self.container:getChildByName("price_txt")
 --    self.limit_txt = self.container:getChildByName("limit_txt")
 --    self.old_price_txt = self.container:getChildByName("old_price_txt")
 --    self.line_sp = self.container:getChildByName("line_sp")
 --    self.sell_out_img = self.container:getChildByName("sell_out_img")
 --    self.sell_out_img:setLocalZOrder(99)

 --    local name_pos_x, name_pos_y = self.name_sp:getPosition()
 --    self.name_sp:setVisible(false)
 --    self.name_txt = createLabel(30, cc.c4b(255,244,196,255), cc.c4b(65,29,4,255), name_pos_x, name_pos_y, "", self.container, 2, cc.p(0.5, 0.5), "fonts/title.ttf" )

 --    self.time_txt = createRichLabel(22, cc.c3b(100,50,35), cc.p(0.5, 0.5), cc.p(113, 70))
 --    self.container:addChild(self.time_txt)

 --    self.award_item_list = {}
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_cloth_item"))
    self:addChild(self.root_wnd)

    local size = cc.size(680, 152)
    self:setContentSize(size)
    self.root_wnd:setContentSize(size)
    self:setAnchorPoint(0.5,0.5)

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:setContentSize(size)
    -- main_container:setPositionX(680 * 0.5)
    self.has_get = main_container:getChildByName("has_get")
    self.name = main_container:getChildByName("name")
    self.name:setString("")
    self.btn_charge = main_container:getChildByName("btn_charge")
    self.charge_price = self.btn_charge:getChildByName("Text_4_0")
    self.text_remian = main_container:getChildByName("Text_4") 
    self.time = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(588, 25))
    main_container:addChild(self.time)

    local item_goods = main_container:getChildByName("good_cons")
    local scroll_view_size = item_goods:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 12,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.70,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.70,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.70
    }
    self.good_scrollview = CommonScrollViewLayout.new(item_goods, cc.p(0,0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end

function ChargeClothItem:registerEvent(  )
    registerButtonEventListener(self.btn_charge, handler(self, self.onClickItem), true, 1, nil, nil, nil, true)
end

function ChargeClothItem:onClickItem(  )
    if not self.touch_buy_cloth or not self.data or not self.data.charge_id then return end

    if self.data.is_sell_out then
        message(TI18N("该礼包已售罄"))
        return
    end

    -- 价格为0，则是免费礼包，无需走SDK
    if self.data.price == 0 then
        if self.callback then
            self.callback(self.data.charge_id)
        end
        MallController:getInstance():sender27801(self.data.charge_id)
        return
    end

    if self.buy_hero_clothes_ticket == nil then
        self.buy_hero_clothes_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_buy_cloth = true
            if self.buy_hero_clothes_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.buy_hero_clothes_ticket)
                self.buy_hero_clothes_ticket = nil
            end
        end,2)
    end
    self.touch_buy_cloth = nil

    if self.data.charge_id then
        if self.callback then
            self.callback(self.data.charge_id)
        end
        ActionController:getInstance():sender21016(self.data.charge_id)
    end
end

function ChargeClothItem:addCallBack( callback )
    self.callback = callback
end

function ChargeClothItem:setData1( data )
    if not data then return end

    self.data = data

    -- 名称
    self.name_txt:setString(data.res_name or "")

    -- 图标
    local icon_res = _string_format("resource/mall_charge_icon/mall_charge_icon_%s.png", data.icon or 1)
    self.icon_load = loadSpriteTextureFromCDN(self.icon_sp, icon_res, ResourcesType.single, self.icon_load)

    -- 限购类型
    local left_num = data.limit_num - data.buy_num
    if self.data.limit_type == 1 then -- 天限购
        self.limit_txt:setString(TI18N("日限购:") .. left_num)
    elseif self.data.limit_type == 2 then -- 周限购
        self.limit_txt:setString(TI18N("周限购:") .. left_num)
    elseif self.data.limit_type == 3 then -- 月限购
        self.limit_txt:setString(TI18N("月限购:") .. left_num)
    elseif self.data.limit_type == 4 then -- 永久限购
        self.limit_txt:setString(TI18N("限购:") .. left_num)
    end

    -- 是否售完
    self.sell_out_img:setVisible(data.is_sell_out)

    -- 永久限购的显示原价、否则显示剩余时间
    if data.limit_type == 4 then
        -- 原价
        if data.original_price then
            self.old_price_txt:setString(TI18N("原价:￥") .. data.original_price)
            self.old_price_txt:setVisible(true)
            self.line_sp:setVisible(true)
        else
            self.old_price_txt:setVisible(false)
            self.line_sp:setVisible(false)
        end
        self.time_txt:setVisible(false)
    else
        local cur_time = GameNet:getInstance():getTime()
        local less_time = data.end_time - cur_time
        commonCountDownTime(self.time_txt, less_time, {time_title = TI18N("剩余"), time_color = "#249003", label_type = CommonAlert.type.rich})
        self.old_price_txt:setVisible(false)
        self.line_sp:setVisible(false)
    end

    -- 价格
    self.price_txt:setString("￥" .. data.price)

    --价格为0且未售罄则显示红点
    if self.data.price == 0 and data.is_sell_out == false then
        addRedPointToNodeByStatus(self.container, true, -5, -2)
    else
        addRedPointToNodeByStatus(self.container, false)
    end

    -- 奖励物品
    for k,item in pairs(self.award_item_list) do
        item:setVisible(false)
    end
    for i,v in ipairs(data.award_list or {}) do
        local bid = v.item_id
        local num = v.item_num
        local item = self.award_item_list[i]
        if not item then
            item = BackPackItem.new(true, true, false, 0.6, nil, true)
            self.container:addChild(item)
            self.award_item_list[i] = item
        end
        item:setVisible(true)
        item:setBaseData(bid, num)
        item:setNumFontSize(30)
        local pos_x = 75 - (i%2-1)*(BackPackItem.Width*0.6+10)
        local pos_y = 0
        if i%2 == 0 then
            pos_y = 220 - (i/2 - 1)*(BackPackItem.Height*0.6+5)
        else
            pos_y = 220 - math.floor(i/2)*(BackPackItem.Height*0.6+5)
        end
        item:setPosition(pos_x, pos_y)
    end
end

function ChargeClothItem:setData( data )
    if not data then return end

    self.data = data
    -- 物品列表
    local list = {}
    for i,v in ipairs(data.award_list or {}) do
        local data = {}
        data.bid = v.item_id
        data.quantity = v.item_num
        _table_insert(list, data)
    end

    self.good_scrollview:setData(list)
    self.good_scrollview:addEndCallBack(function()
        local item_list = self.good_scrollview:getItemList()
        for k,v in pairs(item_list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)

    self.name:setString(data.res_name or "")

        -- 限购类型
    local left_num = data.limit_num - data.buy_num

    if left_num == 0 then -- 卖完
        self.btn_charge:setVisible(false)
        self.text_remian:setVisible(false)
        self.has_get:setVisible(true)
        addRedPointToNodeByStatus(self.btn_charge, false, 5, 5)
        self.time:setVisible(false)
        doStopAllActions(self.time)
    else
        self.has_get:setVisible(false)
        self.btn_charge:setVisible(true)
        self.text_remian:setVisible(true)

        if self.data.limit_type == 1 then -- 天限购
            self.text_remian:setString(_string_format(TI18N("日限购:%s"), left_num))
        elseif self.data.limit_type == 2 then -- 周限购
            self.text_remian:setString(_string_format(TI18N("周限购:%s"), left_num))
        elseif self.data.limit_type == 3 then -- 月限购
            self.text_remian:setString(_string_format(TI18N("月限购:%s"), left_num))
        elseif self.data.limit_type == 4 then -- 永久限购
            self.text_remian:setString(_string_format(TI18N("限购:%s"), left_num))
        end

        if self.data.limit_type == 4 then -- 永久限购
            self.time:setVisible(false)
            doStopAllActions(self.time)
        else
            self.time:setVisible(true)
            local cur_time = GameNet:getInstance():getTime()
            local less_time = data.end_time - cur_time
            commonCountDownTime(self.time, less_time, {time_title = TI18N("剩余"), time_color = "#249003", label_type = CommonAlert.type.rich})
        end
        
        -- 价格
        self.charge_price:setString(data.price .. TI18N("元"))
        if data.price == 0 then
            --0元得有红点
            addRedPointToNodeByStatus(self.btn_charge, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.btn_charge, false, 5, 5)
        end
    end
end

function ChargeClothItem:getChargeId(  )
    if self.data then
        return self.data.charge_id
    end
end

function ChargeClothItem:DeleteMe(  )
    -- self.container:setClippingEnabled(false)

    -- for k,item in pairs(self.award_item_list) do
    --     item:DeleteMe()
    --     item = nil
    -- end

    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end

    if self.buy_hero_clothes_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_hero_clothes_ticket)
        self.buy_hero_clothes_ticket = nil
    end
    if self.icon_load then
        self.icon_load:DeleteMe()
        self.icon_load = nil
    end
    self:removeAllChildren()
	self:removeFromParent()
end