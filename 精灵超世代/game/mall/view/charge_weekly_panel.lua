-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      周礼包
-- <br/>Create: 2019-11-13
-- --------------------------------------------------------------------
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

ChargeWeeklyPanel = ChargeWeeklyPanel or BaseClass()

function ChargeWeeklyPanel:__init(parent, offset_y)
    self.is_init = true
    self.parent = parent
    self.offset_y = offset_y or 0

    self:loadResListCompleted()
end

function ChargeWeeklyPanel:loadResListCompleted( )
	self:createRootWnd()
    self:registerEvent()
end

function ChargeWeeklyPanel:createRootWnd( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_value_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    local con_size = self.main_container:getContentSize()
    self.vip_tips_txt = createLabel(20, 1, cc.c4b(75,64,111,255), con_size.width - 10, 842, TI18N("均可获得vip积分"), self.main_container, 2, cc.p(1, 0.5))

    local time_bg = self.main_container:getChildByName("time_bg")
    time_bg:setVisible(true)
    time_bg:getChildByName("time_title"):setString(TI18N("剩余时间："))
    self.time_txt = time_bg:getChildByName("time_txt")

    self.item_list = self.main_container:getChildByName("item_list")
    local list_size = self.item_list:getContentSize()
    local scroll_view_size = cc.size(list_size.width, list_size.height+self.offset_y)
	local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 10,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        -- item_width = 227,               -- 单元的尺寸width
        -- item_height = 330,              -- 单元的尺寸height
        item_width = 680,               -- 单元的尺寸width
        item_height = 136,              -- 单元的尺寸height
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
    image_1:setContentSize(cc.size(list_size.width+10, list_size.height+self.offset_y+15))
    local image_pos_y = image_1:getPositionY()
    image_1:setPositionY(image_pos_y - self.offset_y)
end

function ChargeWeeklyPanel:createNewCell(width, height)
    local cell = ChargeWeeklyItem.new(width, height)
    cell:addCallBack(handler(self, self.onClickCallBack))
	return cell
end

function ChargeWeeklyPanel:numberOfCells(  )
    if not self.weekly_data then return 0 end
    return #self.weekly_data
end

function ChargeWeeklyPanel:updateCellByIndex( cell, index )
    if not self.weekly_data then return end
    cell.index = index
    local cell_data = self.weekly_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ChargeWeeklyPanel:onClickCallBack( charge_id )
    if charge_id then
        self.cur_charge_id = charge_id
    end
end

function ChargeWeeklyPanel:registerEvent( )
    if self.update_month_week_data == nil then
        self.update_month_week_data = GlobalEvent:getInstance():Bind(WelfareEvent.Updata_Week_Month_Data,function(data)
            if data.type == 1 then -- 周限购
                self:updateItemData(data)
            end
        end)
    end
    if self.update_month_charge_data == nil then
        self.update_month_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function(data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if self.cur_charge_id and charge_config and data.status == 1 and data.charge_id == self.cur_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
                end
            end
        end)
    end
end

function ChargeWeeklyPanel:updateItemData( data )
    if not data then return end

    if self.cur_charge_id then
        self:setBuyCount(data.first_gift)
        for k,w_data in pairs(self.weekly_data) do
            w_data.count = w_data.limit_count - self:getBuyCount(w_data.charge_id)
            if w_data.count <= 0 then
                w_data.count = 0
            end
            w_data.reward, w_data.res_id = self:getRegisteDayReward(w_data.charge_id, data.reg_day)
        end
        local item_list = self.item_scrollview:getActiveCellList()
        for k,item in pairs(item_list) do
            if item:getChargeId() == self.cur_charge_id then
                self.item_scrollview:resetItemByIndex(item.index)
                break
            end
        end
        self.cur_charge_id = nil
    else
        self:setData(data)
    end
end

function ChargeWeeklyPanel:setData( data )
    if not data then return end

    self:setLessTime(data.ref_time - GameNet:getInstance():getTime())

    local data_list = Config.MiscData.data_cycle_gift_info[data.type]
    local reward_list = Config.MiscData.data_cycle_gift_reward
    if data_list then
		self:setBuyCount(data.first_gift)
		self.weekly_data = {}
        for i,v in pairs(data_list) do
            local is_open = false
            if reward_list[v.charge_id] then
                for _,n in pairs(reward_list[v.charge_id]) do
                    if data.reg_day >= n.min and data.reg_day <= n.max then
                        is_open = true
                        break
                    end
                end
            end
            local w_data = deepCopy(v)
            if is_open == true then
                w_data.count = v.limit_count - self:getBuyCount(v.charge_id)
                if w_data.count <= 0 then
                    w_data.count = 0
                    w_data.sort_count = 0
                else
                    w_data.sort_count = 1
                end
                w_data.reward, w_data.res_id = self:getRegisteDayReward(v.charge_id, data.reg_day)
                _table_insert(self.weekly_data, w_data)
            end
		end
    	self:sortList(self.weekly_data)
		self.item_scrollview:reloadData()
	end
end

function ChargeWeeklyPanel:getRegisteDayReward(id,day)
    local reward_list = Config.MiscData.data_cycle_gift_reward
	if reward_list[id] then
		local num = 1
		for i,v in pairs(reward_list[id]) do
			if day >= v.min and day <= v.max then
				num = v.sort_id
				break
			end
		end
		return reward_list[id][num].reward, reward_list[id][num].res_id
	end
	return {}
end

--排序
function ChargeWeeklyPanel:sortList(list)
    if self.init_sort then return end
    self.init_sort = true
    local sort_func = SortTools.tableCommonSorter({{"sort_count", true}, {"sort_id", false}, {"charge_id", false}})
	_table_sort(list,sort_func)
end

--获取购买的数量
function ChargeWeeklyPanel:setBuyCount(data)
	if not data or next(data) == nil then return end
	self.buyCountData = {}
	for i,v in pairs(data) do
		self.buyCountData[v.id] = v.count
	end
end

function ChargeWeeklyPanel:getBuyCount(id)
	if self.buyCountData and self.buyCountData[id] then
		return self.buyCountData[id]
	end
	return 0
end

function ChargeWeeklyPanel:setLessTime(less_time)
    if tolua.isnull(self.time_txt) then return end
    doStopAllActions(self.time_txt)
    if less_time > 0 then
        self:setTimeFormatString(less_time)
        self.time_txt:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(self.time_txt)
                self.time_txt:setString("00:00:00")
            else
                self:setTimeFormatString(less_time)
            end
        end))))
    else
        self:setTimeFormatString(less_time)
    end
end

function ChargeWeeklyPanel:setTimeFormatString(time)
    if time > 0 then
        self.time_txt:setString(TimeTool.GetTimeForFunction(time))
    else
        doStopAllActions(self.time_txt)
        self.time_txt:setString("00:00:00")
    end
end

function ChargeWeeklyPanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
    	self.is_init = false
        WelfareController:getInstance():sender21007(1)
    elseif self.weekly_data and next(self.weekly_data) ~= nil then
        self:sortList(self.weekly_data)
		self.item_scrollview:reloadData()
    end
end

function ChargeWeeklyPanel:addChild( node )
	if not tolua.isnull(self.root_wnd) and not tolua.isnull(node) then
        self.root_wnd:addChild(node)
    end
end

function ChargeWeeklyPanel:setPosition( pos )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos)
    end
end

function ChargeWeeklyPanel:__delete()
    doStopAllActions(self.time_txt)
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_month_week_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_month_week_data)
        self.update_month_week_data = nil
    end
    if self.update_month_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_month_charge_data)
        self.update_month_charge_data = nil
    end
end

-----------------------@ item
ChargeWeeklyItem = class("ChargeWeeklyItem", function()
	return ccui.Widget:create()
end)

function ChargeWeeklyItem:ctor(width, height)
    self:configUI(width, height)
    self:registerEvent()

    self.touch_buy_month = true
end

function ChargeWeeklyItem:configUI(width, height)
 --    self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_week_item"))

 --    self.size = cc.size(width, height)
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


    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel_item"))
    self:addChild(self.root_wnd)

    local size = cc.size(width, height)
    self:setContentSize(size)
    self.root_wnd:setContentSize(size)
    self:setAnchorPoint(0.5,0.5)

    local main_container = self.root_wnd:getChildByName("main_container")
    main_container:setContentSize(size)
    main_container:setPositionX(width * 0.5)
    self.has_get = main_container:getChildByName("has_get")
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
        item_width = BackPackItem.Width*0.80,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.80,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.80
    }
    self.good_scrollview = CommonScrollViewLayout.new(item_goods, cc.p(0,0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)

end

function ChargeWeeklyItem:registerEvent(  )
    registerButtonEventListener(self.btn_charge, handler(self, self.onClickItem), true, 1, nil, nil, nil, true)
end

function ChargeWeeklyItem:onClickItem(  )
    if not self.touch_buy_month or not  self.data or not self.data.charge_id then return end

    if self.data.count <= 0 then
        message(TI18N("该礼包已售罄"))
        return
    end
    if self.callback then
        self.callback(self.data.charge_id)
    end
    
    if self.data.val == 0 then
        MallController:getInstance():sender21023(self.data.charge_id)
        return
    end

    if self.buy_month_ticket == nil then
        self.buy_month_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_buy_month = true
            if self.buy_month_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.buy_month_ticket)
                self.buy_month_ticket = nil
            end
        end,2)
    end
    self.touch_buy_month = nil
    
    ActionController:getInstance():sender21016(self.data.charge_id)
end

function ChargeWeeklyItem:addCallBack( callback )
    self.callback = callback
end

function ChargeWeeklyItem:setData1( data )
    if not data then return end

    self.data = data

    -- 图标
    local icon_res = _string_format("resource/mall_charge_icon/mall_charge_icon_%s.png", data.res_id or 1)
    self.icon_load = loadSpriteTextureFromCDN(self.icon_sp, icon_res, ResourcesType.single, self.icon_load)

    -- 限购
    self.limit_txt:setString(TI18N("剩余: ") .. (data.count or 0))

    if data.count <= 0 then
        self.sell_out_img:setVisible(true)
    else
        self.sell_out_img:setVisible(false)
    end

    -- 价格
    self.price_txt:setString(GetSymbolByType() .. data.val)

    -- 0元且未售罄则显示红点
    if data.val == 0 and data.count > 0 then
        addRedPointToNodeByStatus(self.container, true, -5, -2)
    else
        addRedPointToNodeByStatus(self.container, false)
    end

    -- 奖励物品
    local item_list = {}
    for k, v in pairs(data.reward) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        _table_insert(item_list, vo)
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

function ChargeWeeklyItem:setData( data )
    if not data then return end

    self.data = data
    -- 物品列表
    local list = {}
    for k, v in pairs(data.reward) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        _table_insert(list, vo)
    end
    self.good_scrollview:setData(list)
    self.good_scrollview:addEndCallBack(function()
        local item_list = self.good_scrollview:getItemList()
        for k,v in pairs(item_list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)

    if data.count == 0 then -- 卖完
        self.btn_charge:setVisible(false)
        self.text_remian:setVisible(false)
        self.has_get:setVisible(true)
        addRedPointToNodeByStatus(self.btn_charge, false, 5, 5)
    else
        self.has_get:setVisible(false)
        self.btn_charge:setVisible(true)
        self.text_remian:setVisible(true)

        self.text_remian:setString(_string_format(TI18N("剩余:%s"), data.count))
        -- 价格
        self.charge_price:setString(GetSymbolByType()..data.val)
        if data.val == 0 then
            --0元得有红点
            addRedPointToNodeByStatus(self.btn_charge, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.btn_charge, false, 5, 5)
        end
    end
end

function ChargeWeeklyItem:getChargeId(  )
    if self.data then
        return self.data.charge_id
    end
end

function ChargeWeeklyItem:DeleteMe(  )
    -- self.container:setClippingEnabled(false)
    if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
    -- for k,item in pairs(self.award_item_list) do
    --     item:DeleteMe()
    --     item = nil
    -- end
    if self.buy_month_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_month_ticket)
        self.buy_month_ticket = nil
    end
    if self.icon_load then
        self.icon_load:DeleteMe()
        self.icon_load = nil
    end
    self:removeAllChildren()
	self:removeFromParent()
end