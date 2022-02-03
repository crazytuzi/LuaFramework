--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归商店
-- @DateTime:    2019-12-13 11:56:13
-- *******************************
ReturnActionShopPanel = class("ReturnActionShopPanel", function()
    return ccui.Widget:create()
end)
local controller = ReturnActionController:getInstance()
local model = controller:getModel()
local const_data = Config.HolidayReturnNewData.data_constant
local table_sort = table.sort
local change_text = {
	[1] = TI18N("活动每日每人限兑%d次"),
	[2] = TI18N("活动每人总限兑%d次")
}
local string_format = string.format
function ReturnActionShopPanel:ctor(bid)
	self.holiday_bid = bid
    self.first_come = true
    if const_data.exchange_item_id then
        self.summon_item_bid = const_data.exchange_item_id.val    
    end
    
	self:configUI()
    self:register_event()
    
end

function ReturnActionShopPanel:configUI( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("returnaction/returnaction_task_panel"))
	self.root_wnd:setPosition(-40,-66)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local title_con = main_container:getChildByName("title_con")
    title_con:getChildByName("label_time_key"):setString(TI18N("剩余时间:"))
    self.label_time = title_con:getChildByName("label_time")
    self.label_time:setString("")
    self.desc_txt = title_con:getChildByName("desc_txt")
    self.desc_txt:setPosition(cc.p(30,56))
    self.desc_txt:setTextColor(cc.c4b(0xff,0xdd,0x95,0xff))
    self.desc_txt:enableOutline(cc.c4b(0x4d,0x19,0x21,0xff), 1)
    
    self.icon = title_con:getChildByName("icon")
    self.icon_count = title_con:getChildByName("icon_count")
    self.icon_count:setVisible(true)
    self.icon_count:setString("")
    self.banner_spr = title_con:getChildByName("title_img")
    self.btn_rule = title_con:getChildByName("btn_rule")
    self.btn_rule:setScale(0.8)
    self.cur_cum = createRichLabel(20, cc.c4b(0xff,0xdd,0x95,0xff), cc.p(1,0.5), cc.p(680,24), nil, nil, 300)
    title_con:addChild(self.cur_cum)

    local goods_item = main_container:getChildByName("goods_item")
    local scroll_view_size = goods_item:getContentSize()
    local setting = {
        start_x = 3,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 3,                   -- y方向的间隔
        item_width = 688,               -- 单元的尺寸width
        item_height = 146,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(goods_item, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(true)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createTeskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfTeskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateTeskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self:setLoadBanner()
    model:setShopData()
    controller:sender27914()
    --消除首次红点显示
    ActionController:getInstance():setReturnActionShopFirstRedStatus(false)
end

function ReturnActionShopPanel:createTeskCell()
	local cell = ReturnActionShopItem.new()
    return cell
end
function ReturnActionShopPanel:numberOfTeskCells()
	if not self.task_items then return 0 end
    return #self.task_items
end
function ReturnActionShopPanel:updateTeskCellByIndex(cell, index)
	if not self.task_items then return end
    local cell_data = self.task_items[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ReturnActionShopPanel:setLoadBanner()
	local config = Config.ItemData.data_get_data(self.summon_item_bid)
    if config and self.icon then
        local head_icon = PathTool.getItemRes(config.icon)
        loadSpriteTexture(self.icon, head_icon, LOADTEXT_TYPE)
        self.icon:setScale(0.30)
    end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid) or 0
    self.icon_count:setString(count)

    local holiday_data = model:getReturnActionData(self.holiday_bid)
    local str = "txt_cn_returnaction4"
    if holiday_data then
        str = holiday_data.panel_res
    end
	local res = PathTool.getReturnActionRes(str)
	if not self.load_banner then
		self.load_banner = loadSpriteTextureFromCDN(self.banner_spr, res, ResourcesType.single, self.load_banner)
    end

    if const_data and const_data.exchange_item_id and self.summon_item_bid then 
        local config = Config.ItemData.data_get_data(self.summon_item_bid)
        if config then
            self.desc_txt:setString(string_format(TI18N("每日与回归玩家完成指定玩法 收集%s兑好礼"),config.name))
        end
    end
end

function ReturnActionShopPanel:register_event()
	if not self.shop_event then
        self.shop_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Shop_Event,function(data)
            setCountDownTime(self.label_time,data.endtime - GameNet:getInstance():getTime())
            if self.cur_cum then
                self.cur_cum:setString(string_format(TI18N("今天已获得：%d/%d"),data.get_count,data.limit_count))    
            end
            self:shopItemData()
        end)
    end

     -- 道具数量更新
     if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    
	registerButtonEventListener(self.btn_rule,function(param,sender, event_type)
		local config = const_data.tips_2
		TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
	end,true, 1,nil,0.8)
end

-- 刷新道具数量
function ReturnActionShopPanel:updateItemNum( bag_code, data_list )
	if self.summon_item_bid then
		if bag_code and data_list then
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				for i,v in pairs(data_list) do
					if v and v.base_id and self.summon_item_bid == v.base_id then
						local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
						self.icon_count:setString(summon_have_num)
						break
					end
				end
			end
		else
			local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
            self.icon_count:setString(summon_have_num)
		end
	end
end

function ReturnActionShopPanel:shopItemData()
	self.task_items = model:getShopData()
	if not self.task_items then return end

	for i,v in pairs(self.task_items) do
		v.count,v.totle,v.sort = self:remainCount(v)
	end
	local sort_func = SortTools.tableCommonSorter({{"sort", true},{"id", false}})
    table_sort(self.task_items, sort_func)

	if self.first_come == true then
		self.first_come = false
		self.item_scrollview:reloadData()
	else
		self.item_scrollview:resetCurrentItems()
	end
end
function ReturnActionShopPanel:remainCount(data)
	local count,totle,sort = 0,0,10
	local count_list = model:getServerShopData(data.id)
	if count_list then
		if data.sub_type == 1 then
			totle = data.r_limit_day
			count = data.r_limit_day - count_list.day_num
		elseif data.sub_type == 2 then
			totle = data.r_limit_all
			count = data.r_limit_all - count_list.all_num
		end
		if count <= 0 then
			count = 0
			sort = 0
		end
	end
	return count,totle,sort
end

function ReturnActionShopPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
end

function ReturnActionShopPanel:DeleteMe()
	doStopAllActions(self.label_time)
	if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end

    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end

    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end

	if self.shop_event then
        GlobalEvent:getInstance():UnBind(self.shop_event)
        self.shop_event = nil
    end
	if self.load_banner then 
        self.load_banner:DeleteMe()
        self.load_banner = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
end

------------------------------------------
-- 子项
ReturnActionShopItem = class("ReturnActionShopItem", function()
    return ccui.Widget:create()
end)

function ReturnActionShopItem:ctor()
    self:configUI()
    self:register_event()
end

function ReturnActionShopItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("returnaction/returnaction_shop_item"))
    self:setContentSize(cc.size(688,146))
    self:addChild(self.root_wnd)
    local main_container = self.root_wnd:getChildByName("main_container")
    self.title = main_container:getChildByName("title")
    self.title:setString("")
    self.remain_count = main_container:getChildByName("remain_count")
    self.remain_count:setString("")
    self.btn_change = main_container:getChildByName("btn_change")
	self.btn_change:getChildByName("Text_11"):setString(TI18N("兑 换"))
	self.goods = main_container:getChildByName("goods")
	self.goods:setScrollBarEnabled(false)

	self.change_current_item = BackPackItem.new(nil,true,nil,0.8)
    main_container:addChild(self.change_current_item)
    self.change_current_item:setPosition(cc.p(78, 56))
    self.change_current_item:setDefaultTip()
end
function ReturnActionShopItem:register_event()
	registerButtonEventListener(self.btn_change,function()
		if self.data and self.data.id and self.data.expend then
            local num = self.data.expend[1][2]
            local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.data.expend[1][1])
            if summon_have_num >= num then
    			controller:sender27915(self.data.id)
            else
                message(TI18N("物品不足~~~"))
            end
		end
	end,true, 1)
end


function ReturnActionShopItem:setData(data)
	if not data then return end
	self.data = data

	local str = string_format(change_text[data.sub_type], data.totle)
	self.title:setString(str)
	self.remain_count:setString(TI18N("活动剩余: ")..data.count)
	if data.count == 0 then
		setChildUnEnabled(true, self.btn_change)
		self.btn_change:setTouchEnabled(false)
	else
		setChildUnEnabled(false, self.btn_change)
		self.btn_change:setTouchEnabled(true)
	end
	
	if data.expend and data.expend[1] then
        if self.change_current_item then 
    		self.change_current_item:setBaseData(data.expend[1][1],data.expend[1][2])
        end
	end
	local data_list = data.award or {}
    local setting = {}
    setting.scale = 0.8
    setting.max_count = 3
    setting.is_center = false
    setting.space_x = 10
    self.change_item_list = commonShowSingleRowItemList(self.goods, self.change_item_list, data_list, setting)
end

function ReturnActionShopItem:DeleteMe()
	if self.change_current_item then
       self.change_current_item:DeleteMe()
       self.change_current_item = nil
    end
	if self.change_item_list then
        for i,v in pairs(self.change_item_list) do
            if v.DeleteMe then
                v:DeleteMe()    
            end
        end
        self.change_item_list = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end