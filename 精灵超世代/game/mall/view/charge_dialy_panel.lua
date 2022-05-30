-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      每日特惠
-- <br/>Create: 2019-11-13
-- --------------------------------------------------------------------
local _table_sort = table.sort
local _table_insert = table.insert
local _string_format = string.format

ChargeDialyPanel = ChargeDialyPanel or BaseClass()

function ChargeDialyPanel:__init(parent, offset_y)
    self.is_init = true
    self.parent = parent
    self.offset_y = offset_y or 0

    self:loadResListCompleted()
end

function ChargeDialyPanel:loadResListCompleted( )
	self:createRootWnd()
    self:registerEvent()
end

function ChargeDialyPanel:createRootWnd( )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/charge_value_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.main_container = self.root_wnd:getChildByName("main_container")

    local con_size = self.main_container:getContentSize()
    self.vip_tips_txt = createLabel(20, 1, cc.c4b(75,64,111,255), 10, 842, TI18N("均可获得vip积分"), self.main_container, 2, cc.p(0, 0.5))
    
    --[[ self.tips_txt = self.main_container:getChildByName("tips_txt")
    self.tips_txt:setVisible(false)
    self.tips_txt:setString(TI18N("均可获得 vip 积分")) ]]

    self.daily_btn = self.main_container:getChildByName("daily_btn")
    self.daily_btn:setVisible(true)
    self.daily_btn_tips = self.daily_btn:getChildByName("redpoint")

    self.item_list = self.main_container:getChildByName("item_list")
    local list_size = self.item_list:getContentSize()
    local scroll_view_size = cc.size(list_size.width+10, list_size.height+self.offset_y)
	local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 5,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 684,               -- 单元的尺寸width
        item_height = 224,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_list, cc.p(-5, -self.offset_y) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells)
    self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex)

    local image_1 = self.main_container:getChildByName("image_1")
    image_1:setContentSize(cc.size(list_size.width+10, list_size.height+self.offset_y+20))
    local image_pos_y = image_1:getPositionY()
    image_1:setPositionY(image_pos_y - self.offset_y)
end

function ChargeDialyPanel:createNewCell(  )
    local cell = ChargeDialyItem.new()
    cell:addCallBack(handler(self, self.onClickCallBack))
	return cell
end

function ChargeDialyPanel:numberOfCells(  )
    if not self.dialy_data then return 0 end
    return #self.dialy_data
end

function ChargeDialyPanel:updateCellByIndex( cell, index )
    if not self.dialy_data then return end
    cell.index = index
    local cell_data = self.dialy_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ChargeDialyPanel:onClickCallBack( charge_id )
    if charge_id then
        self.gift_charge_id = charge_id
    end
end

function ChargeDialyPanel:registerEvent( )
    if self.update_daily_gift == nil then
		self.update_daily_gift = GlobalEvent:getInstance():Bind(VipEvent.DAILY_GIFT_INFO,function ( )
            if self.item_scrollview then
                self.item_scrollview:resetCurrentItems()
            end
		end)
    end
    
    -- 每日礼领取状态更新
	if self.update_daily_award == nil then
		self.update_daily_award = GlobalEvent:getInstance():Bind(WelfareEvent.Update_Daily_Awawd_Data,function ( )
			self:updateDailyAwardRed()
		end)
    end
    
    if self.daygift_charge_data == nil then
        self.daygift_charge_data = GlobalEvent:getInstance():Bind(ActionEvent.Is_Charge_Event,function (data)
            if data and data.status and data.charge_id then
                local charge_config = Config.ChargeData.data_charge_data[data.charge_id]
                if charge_config and data.status == 1 and data.charge_id == self.gift_charge_id then
                    sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name, charge_config.name)
                end
            end
        end)
    end

    if not self.role_vo then
		self.role_vo = RoleController:getInstance():getRoleVo()
		if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" or key == "vip_lev" then
                    self:setData()
                end
            end)
        end
    end
    
    registerButtonEventListener(self.daily_btn, function (  )
		WelfareController:getInstance():sender21009()
	end, true)
end

function ChargeDialyPanel:setData(  )
    self.dialy_data = {}
	if self.role_vo == nil then
		self.role_vo = RoleController:getInstance():getRoleVo()
	end
	for k,config in pairs(Config.ChargeData.data_daily_gift_data) do
		-- 判断是否达到显示要求
		if config.show_lv and config.show_lv <= self.role_vo.lev and config.show_vip_lv and config.show_vip_lv <= self.role_vo.vip_lev then
			_table_insert(self.dialy_data, deepCopy(config))
		end
	end
	local sort_func = SortTools.KeyLowerSorter("sort_id")
    _table_sort(self.dialy_data, sort_func)

    self.item_scrollview:reloadData()
    if #self.dialy_data > 3 then
        self.item_scrollview:setClickEnabled(true)
    else
        self.item_scrollview:setClickEnabled(false)
    end
	self:updateDailyAwardRed()
end

function ChargeDialyPanel:updateDailyAwardRed(  )
    local red_status = false
    -- 每日礼
    local award_status = WelfareController:getInstance():getModel():getDailyAwardStatus()
    if award_status == 0 then
        red_status = true
    end
    self.daily_btn_tips:setVisible(red_status)
end

function ChargeDialyPanel:setVisibleStatus( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end

    if status == true and self.is_init == true then
        self.is_init = false
        WelfareController:getInstance():getModel():updateDailyGiftRedStatus(false)
        self:setData()
        self:updateDailyAwardRed()
    end
end

function ChargeDialyPanel:addChild( node )
	if not tolua.isnull(self.root_wnd) and not tolua.isnull(node) then
        self.root_wnd:addChild(node)
    end
end

function ChargeDialyPanel:setPosition( pos )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setPosition(pos)
    end
end

function ChargeDialyPanel:__delete()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_daily_gift then
        GlobalEvent:getInstance():UnBind(self.update_daily_gift)
        self.update_daily_gift = nil
    end
    if self.update_daily_award then
    	GlobalEvent:getInstance():UnBind(self.update_daily_award)
    	self.update_daily_award = nil
    end
    if self.daygift_charge_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.daygift_charge_data)
        self.daygift_charge_data = nil
    end
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end
end

-----------------------@ item
ChargeDialyItem = class("ChargeDialyItem", function()
	return ccui.Widget:create()
end)

function ChargeDialyItem:ctor()
    self:configUI()
    self:registerEvent()

    self.touch_buy_gift = true
end

function ChargeDialyItem:configUI(  )
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("vip/daily_gift_item"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(684, 224))
    self:setAnchorPoint(0,0)

    self.container = self.root_wnd:getChildByName("container")
    self.image_bg = self.container:getChildByName("image_bg")
    self.title_txt = self.container:getChildByName("title_txt")
    self.buy_btn = self.container:getChildByName("buy_btn")
    self.buy_btn.label = self.buy_btn:getTitleRenderer()
    if self.buy_btn.label ~= nil then
    	self.buy_btn.label:enableOutline(cc.c4b(0x76,0x45,0x19,0xff), 2)
    end
    self.left_num = self.container:getChildByName("left_num")
    self.zhe_panel = self.container:getChildByName("zhe_panel")
    self.zhe_panel:setVisible(false)
    self.zhe_panel:getChildByName("price_title"):setString(TI18N("原价"))
    self.price_txt = self.zhe_panel:getChildByName("price_txt")
    self.icon_sp = self.container:getChildByName("icon_sp")

    local good_list = self.container:getChildByName("good_list")
    local scroll_size = good_list:getContentSize()
	local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 15,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = 0.7
    }
    self.good_scrollview = CommonScrollViewLayout.new(good_list, cc.p(0, 5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_size, setting)
end

function ChargeDialyItem:registerEvent(  )
    registerButtonEventListener(self.buy_btn, handler(self, self.onClickItem), true)
end

function ChargeDialyItem:onClickItem(  )
    if self.gift_config then
		local role_vo = RoleController:getInstance():getRoleVo()
        local limit_vip = self.gift_config.limit_vip
		if role_vo.vip_lev >= limit_vip then
			local charge_id = self.gift_config.charge_id
            local charge_config = Config.ChargeData.data_charge_data[charge_id or 0]
			if charge_config and self.touch_buy_gift == true then
                self.touch_buy_gift = nil
                if self.callback then
                    self.callback(self.gift_config.charge_id)
                end
	            ActionController:getInstance():sender21016(charge_config.id)
				if self.send_buy_gift_ticket == nil then
	                self.send_buy_gift_ticket = GlobalTimeTicket:getInstance():add(function()
	                    self.touch_buy_gift = true
	                    if self.send_buy_gift_ticket ~= nil then
	                        GlobalTimeTicket:getInstance():remove(self.send_buy_gift_ticket)
	                        self.send_buy_gift_ticket = nil
	                    end
	                end,2)
	            end
			end
		else
			message(_string_format(TI18N("VIP%d可购买"), limit_vip))
		end
	end
end

function ChargeDialyItem:addCallBack( callback )
    self.callback = callback
end

function ChargeDialyItem:setData( data )
    if not data then return end
	self.gift_config = data

	local gift_bid = data.id -- 礼包id
    local buy_count = VipController:getInstance():getModel():getDailyGiftBuyCountById(gift_bid) -- 已购次数
    
    -- 图标
    local icon_res = _string_format("resource/mall_charge_icon/%s.png", data.icon_res or "")
    self.icon_load = loadSpriteTextureFromCDN(self.icon_sp, icon_res, ResourcesType.single, self.icon_load)

	-- 背景
	local gift_res = PathTool.getTargetRes("bigbg", self.gift_config.bg_res,false,false)
	self.gift_bg_load = loadImageTextureFromCDN(self.image_bg, gift_res, ResourcesType.single, self.gift_bg_load)

	-- 名称
	self.title_txt:setString(self.gift_config.name)
	if self.gift_config.bg_res == "txt_cn_bigbg_25" then
		self.title_txt:enableOutline(cc.c3b(50, 60, 111), 2)
	elseif self.gift_config.bg_res == "txt_cn_bigbg_26" then
		self.title_txt:enableOutline(cc.c3b(56, 24, 70), 2)
	elseif self.gift_config.bg_res == "txt_cn_bigbg_27" then
		self.title_txt:enableOutline(cc.c3b(124, 55, 21), 2)
	end--

	-- 是否已经达到购买次数上限
	if self.gift_config.limit_count <= buy_count then
		setChildUnEnabled(true, self.buy_btn)
		self.buy_btn:setTouchEnabled(false)
		self.buy_btn:setTitleText(TI18N("今日已购"))
	else
		setChildUnEnabled(false, self.buy_btn)
		self.buy_btn:setTouchEnabled(true)
		self.buy_btn:setTitleText(string.format(TI18N("%d元"), self.gift_config.val or 0))
	end

	-- 剩余数量
	self.left_num:setString(string.format(TI18N("限购:%d次"), (self.gift_config.limit_count-buy_count)))

	-- 描述内容
	if not self.gift_desc_txt then
		self.gift_desc_txt = createRichLabel(22, 1, cc.p(0, 1), cc.p(210, 206), 0, nil, 260)
		self.container:addChild(self.gift_desc_txt)
	end
	local res_str = string.format("<img src='%s' scale=0.3 />", PathTool.getItemRes(3))
	self.gift_desc_txt:setString(string.format(self.gift_config.desc, res_str, res_str))

	-- 原价显示
	if self.gift_config.old_price and self.gift_config.old_price > 0 then
		self.zhe_panel:setVisible(true)
		self.price_txt:setString(self.gift_config.old_price .. TI18N("元"))
	else
		self.zhe_panel:setVisible(false)
	end

	-- 奖励物品
	local role_vo = RoleController:getInstance():getRoleVo()
	local gift_award_cfg = Config.ChargeData.data_daily_gift_award[gift_bid]
	if gift_award_cfg then
		local award_data = {}
		for k,v in pairs(gift_award_cfg) do
			if v.min <= role_vo.lev and v.max >= role_vo.lev then
				award_data = deepCopy(v.reward)
				break
			end
		end
		local item_list = {}
		for k,v in pairs(award_data) do
	        local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
	        if vo then
	        	vo.quantity = v[2]
	        	table.insert(item_list,vo)
	        end
	    end
		self.good_scrollview:setData(item_list)
		local is_show_double = false
		if self.gift_config and self.gift_config.is_double and self.gift_config.is_double == 1 then
			is_show_double = true
		end
		self.good_scrollview:addEndCallBack(function (  )
	        local list = self.good_scrollview:getItemList()
	        for k,v in pairs(list) do
	        	-- 判断是否显示双倍显示
	        	if is_show_double then
	        		local item_cfg = v:getData()
		        	if item_cfg and item_cfg.id == 3 then
		        		v:setDoubleIcon(true)
		        	else
		        		v:setDoubleIcon(false)
		        	end
	        	end
	            v:setDefaultTip()
	        end
	    end)
	end
end

function ChargeDialyItem:getData(  )
    return self.data
end

function ChargeDialyItem:DeleteMe(  )
    if self.gift_bg_load then
		self.gift_bg_load:DeleteMe()
		self.gift_bg_load = nil
	end

	if self.good_scrollview then
		self.good_scrollview:DeleteMe()
		self.good_scrollview = nil
	end
    if self.send_buy_gift_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.send_buy_gift_ticket)
        self.send_buy_gift_ticket = nil
    end
    if self.icon_load then
        self.icon_load:DeleteMe()
        self.icon_load = nil
    end
    self:removeAllChildren()
	self:removeFromParent()
end