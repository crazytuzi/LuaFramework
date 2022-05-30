--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 活动神装道具商店
-- @DateTime:    2019-05-05 14:44:53
-- *******************************
ActionHeroClothesPanel = class("ActionHeroClothesPanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
function ActionHeroClothesPanel:ctor(holiday_id)
	self.holiday_id = holiday_id
	self:configUI()
	self:register_event()
end

function ActionHeroClothesPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel"))
	self:addChild(self.root_wnd)
	self:setPosition(-40, -64)
	self:setAnchorPoint(0, 0)

	local main_container = self.root_wnd:getChildByName("main_container")
	local title_con = main_container:getChildByName("title_con")
    self.btn_rule = title_con:getChildByName("btn_rule")
    self.btn_rule:setVisible(false)
	local sprite_title = title_con:getChildByName("sprite_title")
	
	local str_banner
	local tab_vo = controller:getActionSubTabVo(self.holiday_id)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str_banner = tab_vo.reward_title
    end
    if str_banner then
		local res = PathTool.getWelfareBannerRes(str_banner)
	    if not self.banner_load then
	        self.banner_load = createResourcesLoad(res, ResourcesType.single, function()
	            if not tolua.isnull(sprite_title) then
	    			loadSpriteTexture(sprite_title, res, LOADTEXT_TYPE)
	    		end
	    	end,self.banner_load)
	    end
	end

    local time_panel = title_con:getChildByName("time_panel")
    time_panel:getChildByName("Text_1"):setString(TI18N("剩余时间: "))
    self.remain_time = time_panel:getChildByName("remain_time")
    self.remain_time:setString("")

    local item_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = item_cons:getContentSize()
    local setting = {
        item_class = ActionHeroClothesItem,
        start_x = 0,
        space_x = 0,
        start_y = 0,
        space_y = 0,
        item_width = 688,
        item_height = 136,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_cons,cc.p(0,0),ScrollViewDir.vertical,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    controller:sender25500()
end

function ActionHeroClothesPanel:setConfigData(period)
	local data
	local clothes_data = controller:getModel():getHeroClothesShopData()
	if clothes_data then
		data = clothes_data
	else
		controller:getModel():setHeroClothesShopData(period)
		local temp_data = controller:getModel():getHeroClothesShopData()
		if temp_data then
			data = temp_data
		end
	end
	return data
end
function ActionHeroClothesPanel:setDataItem(period)
	local data = self:setConfigData(period)
	if data and self.item_scrollview then
	 	local list = {}
	 	for i,v in pairs(data) do
	 		local ser_data = controller:getModel():getLimitTypeData(v.id)
	 		v.sort = 0
	 		v.count = 0
	 		if ser_data then
                local num = 0
	 			--[[ if v.limit_type == 1 then
		  			num = v.limit_day - ser_data.day_num
		  		elseif v.limit_type == 2 then
		  			num = v.limit_week - ser_data.week_num
		  		elseif v.limit_type == 3 then
		  			num = v.limit_month - ser_data.month_num
		  		elseif v.limit_type == 4 then
		  			num = v.limit_all - ser_data.all_num
		  		end ]]
		  		if num <= 0 then
		  			num = 0
		  			v.sort = 1
		  		end
		  		v.count = num
	 		end
            if v.limit_type == 4 and v.count == 0 then
            else
    	 		table.insert(list,v)
            end
	 	end
	 	local sort_func = SortTools.tableCommonSorter({{"sort", false},{"id", false}})
	 	table.sort(list, sort_func)
		self.item_scrollview:setData(list)
	end
end
function ActionHeroClothesPanel:register_event()
	if self.update_clothes_data == nil then
        self.update_clothes_data = GlobalEvent:getInstance():Bind(ActionEvent.Updata_Hero_Clothes_Shop_Data,function(data)
            if not data then return end
            if data.week_time then
    			commonCountDownTime(self.remain_time, data.week_time-GameNet:getInstance():getTime())
            end
            if data.period then
                self:setDataItem(data.period)
            end
        end)
    end
end

function ActionHeroClothesPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ActionHeroClothesPanel:DeleteMe()
	doStopAllActions(self.remain_time)
	if self.banner_load then
        self.banner_load:DeleteMe()
    end
    self.banner_load = nil
    controller:getModel():setColthesDataInit()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.update_clothes_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_clothes_data)
        self.update_clothes_data = nil
    end
end

--子项
ActionHeroClothesItem = class("ActionHeroClothesItem", function()
    return ccui.Widget:create()
end)

function ActionHeroClothesItem:ctor()
    self.buy_clothes_item = true
	self:configUI()
	self:register_event()
end

function ActionHeroClothesItem:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/week_month_panel_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(688,136))
    self:setAnchorPoint(0,0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.has_get = main_container:getChildByName("has_get")
    self.has_get:setVisible(false)
    self.btn_charge = main_container:getChildByName("btn_charge")
    self.charge_price = self.btn_charge:getChildByName("Text_4_0")
    self.charge_price:setString("")
    self.text_remian = main_container:getChildByName("Text_4")   
    self.text_remian:setString("")

    local good_cons = main_container:getChildByName("good_cons")
    local scroll_view_size = good_cons:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 0,
        space_x = 10,
        start_y = 12,
        space_y = 0,
        item_width = BackPackItem.Width*0.80,
        item_height = BackPackItem.Height*0.80,
        row = 1,
        col = 0,
        scale = 0.80
    }
    self.good_scrollview = CommonScrollViewLayout.new(good_cons, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.good_scrollview:setSwallowTouches(false)
end
function ActionHeroClothesItem:register_event()
	registerButtonEventListener(self.btn_charge, function()
		self:btnBuyCommodity()
	end, true, 1)
end
--购买
function ActionHeroClothesItem:btnBuyCommodity()
	if not self.buy_clothes_item then return end
    if self.buy_hero_clothes_ticket == nil then
        self.buy_hero_clothes_ticket = GlobalTimeTicket:getInstance():add(function()
            self.buy_clothes_item = true
            if self.buy_hero_clothes_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.buy_hero_clothes_ticket)
                self.buy_hero_clothes_ticket = nil
            end
        end,2)
    end
    self.buy_clothes_item = nil

    if self.data and self.data.charge_id then
    	local charge_config = Config.ChargeData.data_charge_data[self.data.charge_id]
    	if charge_config then
        	sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
        end
    end
end

local limit_name = {TI18N("每日限购: "),TI18N("每周限购: "),TI18N("每月限购: "),TI18N("永久限购: ")}
function ActionHeroClothesItem:setData(data)
	self.data = data
    self.charge_price:setString(GetSymbolByType() .. data.price)

	if data.count <= 0 then
	    setChildUnEnabled(true, self.btn_charge)
	    self.btn_charge:setTouchEnabled(false)
        self.charge_price:disableEffect(cc.LabelEffect.SHADOW)
	else
	    setChildUnEnabled(false, self.btn_charge)
	    self.btn_charge:setTouchEnabled(true)
        self.charge_price:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)
	end
	self.text_remian:setString(limit_name[data.limit_type]..data.count)


    local list = {}
    for k, v in pairs(data.award) do
        local vo = {}
        vo.bid = v[1]
        vo.quantity = v[2]
        table.insert(list, vo)
    end
    if #list > 4 then
        self.good_scrollview:setClickEnabled(true)
    else
        self.good_scrollview:setClickEnabled(false)
    end
    self.good_scrollview:setData(list)
 	self.good_scrollview:addEndCallBack(function()
        local list = self.good_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            v:setSwallowTouches(false)
        end
    end)
end
function ActionHeroClothesItem:DeleteMe()
	if self.buy_hero_clothes_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_hero_clothes_ticket)
        self.buy_hero_clothes_ticket = nil
    end
	if self.good_scrollview then
        self.good_scrollview:DeleteMe()
        self.good_scrollview = nil
    end
	self:removeAllChildren()
	self:removeFromParent()
end
