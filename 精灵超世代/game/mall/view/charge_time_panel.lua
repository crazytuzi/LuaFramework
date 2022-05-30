-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      限时礼包
-- <br/>Create: 2019-11-15
-- --------------------------------------------------------------------
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

ChargeTimePanel = ChargeTimePanel or BaseClass()

function ChargeTimePanel:__init(parent, offset_y)
    self.is_init = true
    self.parent = parent
    self.offset_y = offset_y or 0
    self.holiday_bid = 91006 -- 活动id
    self.dic_limit = {}
    self:loadResListCompleted()
end

function ChargeTimePanel:loadResListCompleted( )
	self:createRootWnd()
    self:registerEvent()
end

function ChargeTimePanel:createRootWnd( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_value_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    local con_size = self.main_container:getContentSize()
    self.vip_tips_txt = createLabel(20, 1, cc.c4b(75,64,111,255), con_size.width - 10, 842, TI18N("均可获得vip积分"), self.main_container, 2, cc.p(1, 0.5))

    self.tips_txt = self.main_container:getChildByName("tips_txt")
    self.tips_txt:setVisible(true)
    self.tips_txt:setString(TI18N("限时折扣，礼包大放送"))
    self.tips_txt:setPositionY(self.tips_txt:getPositionY()+30)

    local time_bg = self.main_container:getChildByName("time_bg")
    time_bg:setVisible(true)
    time_bg:getChildByName("time_title"):setString(TI18N("剩余时间:"))
    self.time_txt = time_bg:getChildByName("time_txt")

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

function ChargeTimePanel:createNewCell(  )
    local cell = ChargeLimitItem.new()
	return cell
end

function ChargeTimePanel:numberOfCells(  )
    if not self.limit_data then return 0 end
    return #self.limit_data
end

function ChargeTimePanel:updateCellByIndex( cell, index )
    if not self.limit_data then return end
    cell.index = index
    local cell_data = self.limit_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ChargeTimePanel:registerEvent( )
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if data.bid == self.holiday_bid then
                self:setData(data)
            end
        end)
    end
end

function ChargeTimePanel:setData( data )
    if not data then return end

    if self.limit_data == nil then
        self.limit_data = {}
    end
    for i, v in ipairs(data.aim_list) do
        --99是和后端 运营协议好的数字  99 为每日礼的
        if self.dic_limit[v.aim] == nil then
            self.dic_limit[v.aim] = v
            _table_insert(self.limit_data,v)
        else
            for key,val in pairs(v) do
                self.dic_limit[v.aim][key] = val
            end
        end
        local data = self.dic_limit[v.aim]
        if data.aim ~= 99 then 
            data.sort_index = 1
            if data.status == 1 then
                data.sort_index = 0
            elseif data.status == 2 then
                data.sort_index = 2
            end
        end
    end

    -- 剩余时间
    if data.remain_sec then
        commonCountDownTime(self.time_txt, data.remain_sec)
    end
    if not self.init_sort then
        self.init_sort = true
        local sort_func = SortTools.tableLowerSorter({"sort_index", "aim"})
        _table_sort(self.limit_data, sort_func)
    end

    self.item_scrollview:reloadData(nil, nil, true)
end

function ChargeTimePanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
    	self.is_init = false
        ActionController:getInstance():cs16603(self.holiday_bid)
    end
end

function ChargeTimePanel:addChild( node )
	if not tolua.isnull(self.root_wnd) and not tolua.isnull(node) then
        self.root_wnd:addChild(node)
    end
end

function ChargeTimePanel:setPosition( pos )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos)
    end
end

function ChargeTimePanel:__delete()
    if self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_limit_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_limit_charge_data)
        self.update_limit_charge_data = nil
    end
end

-----------------------@ item
ChargeLimitItem = class("ChargeLimitItem", function()
	return ccui.Widget:create()
end)

function ChargeLimitItem:ctor()
    self:configUI()
    self:registerEvent()

    self.touch_buy_limit = true
end

function ChargeLimitItem:configUI(  )
 --    self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_week_item"))
    
 --    self.size = cc.size(227, 330)
 --    self:setAnchorPoint(cc.p(0, 0))
 --    self:addChild(self.root_wnd)
	-- self:setCascadeOpacityEnabled(true)
	-- self:setContentSize(self.size)
	-- self:setTouchEnabled(true)
	-- self:setSwallowTouches(false)

 --    self.container = self.root_wnd:getChildByName("container")
 --    self.container:setSwallowTouches(false)

 --    self.icon_sp = self.container:getChildByName("icon_sp")
 --    self.price_txt = self.container:getChildByName("price_txt")
 --    self.limit_txt = self.container:getChildByName("limit_txt")
 --    self.sell_out_img = self.container:getChildByName("sell_out_img")
 --    self.sell_out_img:setLocalZOrder(99)

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

function ChargeLimitItem:registerEvent(  )
    registerButtonEventListener(self.btn_charge, handler(self, self.onClickItem), true, 1, nil, nil, nil, true)
end

function ChargeLimitItem:onClickItem(  )
    if not self.touch_buy_limit or not self.data then return end

    if self.data.status == 0 then
        self.touch_buy_limit = nil
        local new_price = keyfind('aim_args_key', 27, self.data.aim_args) or {}
        sdkOnPay(new_price.aim_args_val, 1, self.data.aim, self.data.aim_str)
        if self.buy_charge_limit_ticket == nil then
            self.buy_charge_limit_ticket = GlobalTimeTicket:getInstance():add(function()
                self.touch_buy_limit = true
                if self.buy_charge_limit_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.buy_charge_limit_ticket)
                    self.buy_charge_limit_ticket = nil
                end
            end,2)
        end
    elseif self.data.status == 2 then
        message(TI18N("该礼包已售罄"))
    end
end

function ChargeLimitItem:setData1( data )
    if not data then return end

    self.data = data

    -- 图标
    local icon_res_id = self:getValByKey(data.aim_args, 41)
    if icon_res_id < 1 then icon_res_id = 1 end
    local icon_res = _string_format("resource/mall_charge_icon/mall_charge_icon_%s.png", icon_res_id)
    self.icon_load = loadSpriteTextureFromCDN(self.icon_sp, icon_res, ResourcesType.single, self.icon_load)

    -- 限购
    local _type = self:getValByKey(data.aim_args,7) or 0
    local max_num = self:getValByKey(data.aim_args,2) or 0  -- 最大购买数量
    local cur_num = self:getValByKey(data.aim_args,6) or 0  -- 当前购买数量
    local left_num = max_num - cur_num -- 剩余购买数量
    if left_num < 0 then left_num = 0 end
    if _type == 1 then --日限购
        self.limit_txt:setString(TI18N("周限购:" .. left_num))
    elseif _type == 2 then --累计限购
        limit_str = TI18N("限购:" .. left_num)
        self.limit_txt:setString(TI18N("限购:" .. left_num))
    end

    -- 是否售完
    self.sell_out_img:setVisible(left_num == 0)

    -- 价格
    local new_price =  self:getValByKey(data.aim_args, 27) or 0
    self.price_txt:setString("￥" .. new_price)

    -- 奖励物品
    local item_list = {}
    for k, v in ipairs(data.item_list) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        if vo then
            vo.quantity = v.num
            _table_insert(item_list, vo)
        end
    end
    for k,item in pairs(self.award_item_list) do
        item:setVisible(false)
    end
    for i,vo in ipairs(item_list) do
        local item = self.award_item_list[i]
        if not item then
            item = BackPackItem.new(true, true, false, 0.5, nil, true)
            self.container:addChild(item)
            self.award_item_list[i] = item
        end
        item:setVisible(true)
        item:setData(vo)
        item:setNumFontSize(32)
        local pos_x = 78 - (i%2-1)*(BackPackItem.Width*0.5+10)
        if i == #item_list and i%2 == 1 then
            pos_x = 113
        end
        local pos_y = 0
        if i%2 == 0 then
            pos_y = 140 - (i/2 - 1)*(BackPackItem.Height*0.5+5)
        else
            pos_y = 140 - math.floor(i/2)*(BackPackItem.Height*0.5+5)
        end
        item:setPosition(pos_x, pos_y)
    end
end

function ChargeLimitItem:setData( data )
    if not data then return end
    self.data = data
    -- 物品列表
    local list = {}
    for k, v in ipairs(data.item_list) do
        local data = {}
        data.bid = v.bid
        data.quantity = v.num
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

    self.name:setString(data.aim_str or "")
        -- 限购
    local _type = self:getValByKey(data.aim_args,7) or 0
    local max_num = self:getValByKey(data.aim_args,2) or 0  -- 最大购买数量
    local cur_num = self:getValByKey(data.aim_args,6) or 0  -- 当前购买数量
    local left_num = max_num - cur_num -- 剩余购买数量
    if left_num < 0 then left_num = 0 end
    -- if _type == 1 then --日限购
    --     self.limit_txt:setString(TI18N("周限购:" .. left_num))
    -- elseif _type == 2 then --累计限购
    --     limit_str = TI18N("限购:" .. left_num)
    --     self.limit_txt:setString(TI18N("限购:" .. left_num))
    -- end

    if left_num == 0 then -- 卖完
        self.btn_charge:setVisible(false)
        self.text_remian:setVisible(false)
        self.has_get:setVisible(true)
        addRedPointToNodeByStatus(self.btn_charge, false, 5, 5)
    else
        self.has_get:setVisible(false)
        self.btn_charge:setVisible(true)
        self.text_remian:setVisible(true)

        self.text_remian:setString(_string_format(TI18N("剩余:%s"), left_num))
        -- 价格
        local new_price =  self:getValByKey(data.aim_args, 27) or 0
        self.charge_price:setString(new_price .. TI18N("元"))
        if new_price == 0 then
            --0元得有红点
            addRedPointToNodeByStatus(self.btn_charge, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.btn_charge, false, 5, 5)
        end
    end
end

function ChargeLimitItem:getValByKey(aim_args, key)
    if not aim_args then
        return 0
    end
    local val = 0
    for i, v in ipairs(aim_args) do
        if v.aim_args_key == key then
            val = v.aim_args_val
        end
    end
    return val
end

function ChargeLimitItem:DeleteMe(  )
    -- self.container:setClippingEnabled(false)
    -- for k,item in pairs(self.award_item_list) do
    --     item:DeleteMe()
    --     item = nil
    -- end

    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end

    if self.buy_charge_limit_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_charge_limit_ticket)
        self.buy_charge_limit_ticket = nil
    end
    if self.icon_load then
        self.icon_load:DeleteMe()
        self.icon_load = nil
    end
    self:removeAllChildren()
	self:removeFromParent()
end