--******** 文件说明 ********
-- @Author:      lc 
-- @description: 个人推送礼包
-- @DateTime:    2019-12-7
-- *******************************
LimitTimeGiftWindow = LimitTimeGiftWindow or BaseClass(BaseView)

local controller = LimitTimeActionController:getInstance()
local num_pos_x = 325 --数字的位置
local string_format = string.format
local table_insert = table.insert
local config_gift_info = Config.HolidayPersonalFireGiftData.data_gift_info
function LimitTimeGiftWindow:__init()
    self.win_type = WinType.Mini
    self.is_full_screen	= true
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "limit_time/limit_time_gift_window"
    self.res_list = {
    	{ path = PathTool.getPlistImgForDownLoad("personalgift","personalgift"), type = ResourcesType.plist},
    	{ path = PathTool.getPlistImgForDownLoad("num","type30"), type = ResourcesType.plist},
    	{ path = PathTool.getPlistImgForDownLoad("bigbg/festivalaction","personalgift_bg1"), type = ResourcesType.single},
	}
    self.item_list = {}
    self.cur_index = nil
    self.touch_index = 1 --默认的位置
    self.max_index = 5--最大个数
    self.touch_buy_btn = true
end

function LimitTimeGiftWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 2) 
    local image_bg = self.main_container:getChildByName("image_bg")
    local res = PathTool.getPlistImgForDownLoad("bigbg/festivalaction","personalgift_bg1")
    self.image_bg_load = loadSpriteTextureFromCDN(image_bg, res, ResourcesType.single, self.image_bg_load)

    self.item_scroll = self.main_container:getChildByName("item_scroll")
    self.item_scroll_size = self.item_scroll:getContentSize()
    self.item_scroll:setScrollBarEnabled(false)

    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy_label = self.btn_buy:getChildByName("Text_1")
    self.btn_buy_label:setString("")
    self.time = self.main_container:getChildByName("time")
    self.time:setString("")
    self.limit_buy_text = self.main_container:getChildByName("limit_buy_text")
    self.limit_buy_text:setString("")
    self.gift_percent_num = CommonNum.new(30, self.main_container, nil, -5, cc.p(0.5, 0.5))
    self.gift_percent_num:setPosition(num_pos_x, 220)

  	self.tab_page = self.main_container:getChildByName("tab_page")
  	self.tab_page_size = self.tab_page:getContentSize()
  	self.tab_page:setVisible(false)
  	self.btn_left = self.tab_page:getChildByName("btn_left")
  	self.btn_right = self.tab_page:getChildByName("btn_right")
  	self.page_icon_list = {}
  	-- for i = 1,1 do
  	-- 	self.page_icon_list[i] = self.tab_page:getChildByName("page_icon_"..i)
  	-- end
  	-- self:tabPageIconView(self.touch_index)
    self.btn_close = self.main_container:getChildByName("btn_close")

end

function LimitTimeGiftWindow:openRootWnd()
	controller:sender28000()
end
function LimitTimeGiftWindow:register_event()
	--事件 设置奖励数据
	self:addGlobalEvent(LimitTimeActionEvent.Limit_Time_Gift_Event,function(data) 
		self:setData(data)
	end)

	registerButtonEventListener(self.btn_close, function()
		controller:openLimitTimeGiftWindow(false)
	end, false,2)

	registerButtonEventListener(self.background, function()
		controller:openLimitTimeGiftWindow(false)
	end, false,2)

	registerButtonEventListener(self.btn_buy, function()
		self:BtnCharge()
	end, true, 1)
	registerButtonEventListener(self.btn_left, function()
		self:onTouchLeft()
	end, false)
	registerButtonEventListener(self.btn_right, function()
		self:onTouchRight()
	end, false)
end


--倒计时
function LimitTimeGiftWindow:CountDownTime(node,data)
    local less_time = data.less_time or 0
    local time_model = data.time_model or 1
    local text = data.text or ""
    if tolua.isnull(node) then return end
    doStopAllActions(node)

    local function setRemainTimeString(time)
        if time > 0 then
            if time_model == 1 then
                node:setString(TimeTool.GetTimeFormat(time))
            elseif time_model == 2 then
                node:setString(TimeTool.GetTimeFormat(less_time)..text)
            end
        else
            doStopAllActions(node)
            node:setString("00:00:00")
            if time_model == 2 then
                controller:openLimitTimeGiftWindow(false)
            end
        end
    end

    if less_time > 0 then
        setRemainTimeString(less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                setRemainTimeString(less_time)
            end
        end))))
    else
        setRemainTimeString(less_time)
    end
end


function LimitTimeGiftWindow:setData(data)
	self.data = data or {}
	if self.data.gifts ~= nil and next(self.data.gifts) ~= nil then
		if #self.data.gifts <= 1 then
			self.tab_page:setVisible(false)
		else
			self.tab_page:setVisible(true)
		end
		self:setTabPos(self.data.gifts)
    else
    	controller:openLimitTimeGiftWindow(false)
    end
end

function LimitTimeGiftWindow:setPanelData(index)
	local index = index or 1
	local tab_data = {}
		tab_data.less_time = self.data.gifts[index].end_time - GameNet:getInstance():getTime()
		tab_data.time_model = 2
		tab_data.text = TI18N("后礼包消失")
		self:CountDownTime(self.time, tab_data)
		local award_id = self.data.gifts[index].award_id or 101
	    local data_list = config_gift_info[award_id].award
	    local setting,list = self:setRewardSetting(data_list)
	    self.gold_scrollview  = createScrollView(self.item_scroll_size.width, self.item_scroll_size.height, 0, 50, self.item_scroll, ScrollViewDir.horizontal) 
	    self.item_list = commonShowSingleRowItemList(self.gold_scrollview, self.item_list, list, setting)
	    if #list <= 4 then
	    	self.item_scroll:setTouchEnabled(false)
	    else
	    	self.item_scroll:setTouchEnabled(true)
	    end
	    local limit_condition = config_gift_info[self.data.gifts[index].award_id]
		self.limit_buy_text:setString(string.format(TI18N("限购: %s/%s"),self.data.gifts[index].count, limit_condition.limit_count))
		if self.data.gifts[index].count >= limit_condition.limit_count then
			self.btn_buy_label:setString(TI18N("已购买"))
			setChildUnEnabled(true, self.btn_buy)
			self.btn_buy:setTouchEnabled(false)
			self.btn_buy_label:disableEffect(cc.LabelEffect.OUTLINE)
		else
			self.btn_buy_label:setString(limit_condition.price .. TI18N("元"))
		end
		self.gift_percent_num:setNum(limit_condition.art_words,true)
		if self.icon_per == nil then 
	  		self.icon_per = createSprite(nil, num_pos_x + self.gift_percent_num:getContentSize().width * 0.5, 188, self.main_container, cc.p(0, 0.5))
	  		loadSpriteTexture(self.icon_per, PathTool.getResFrame("type30","type30_per"), LOADTEXT_TYPE_PLIST)
	  	else
	  		self.icon_per:setPositionX(num_pos_x + self.gift_percent_num:getContentSize().width * 0.5)
	 	end
end

--礼包数量
function LimitTimeGiftWindow:setTabPos( list )
	self.max_index = #list or 1
	for i=1,self.max_index do
		self.page_icon_list[i] = self.tab_page:getChildByName("page_icon_"..i)
		self.page_icon_list[i]:setPositionX((self.tab_page_size.width * i / (self.max_index + 1)))
	end
	if self.max_index < 5 then
	  	for i = self.max_index + 1,5 do
	  		self.tab_page:getChildByName("page_icon_"..i):setVisible(false)
	  	end
	end
  	self:tabPageIconView(self.touch_index)
end

function LimitTimeGiftWindow:setRewardSetting( data )
    local setting = {}
    setting.scale = 0.9
    setting.space_x = 10
    setting.is_center = true
    setting.max_count = 4
    local data_list1 = {}
    if data then
        for k, v in pairs(data) do
            table_insert(data_list1, {v[1], v[2]})
        end
    end
    return setting,data_list1
end

--
function LimitTimeGiftWindow:tabPageIconView(index)
	if self.cur_index == index then return end

	if self.cur_tab ~= nil then
		if self.page_icon_list[self.cur_index] then
			loadSpriteTexture(self.page_icon_list[self.cur_index], PathTool.getResFrame("personalgift","personalgift_2"), LOADTEXT_TYPE_PLIST)
		end
	end
	self.cur_index = index
	self.cur_tab = self.page_icon_list[self.cur_index]
	if self.cur_tab then
		if self.page_icon_list[self.cur_index] then
			loadSpriteTexture(self.page_icon_list[self.cur_index], PathTool.getResFrame("personalgift","personalgift_1"), LOADTEXT_TYPE_PLIST)
		end
	end
	self:setPanelData(self.cur_index)
end

--点击充值按钮
function LimitTimeGiftWindow:BtnCharge()
	-- if not self.charge_id then return end
	if not self.touch_buy_btn then return end

	if self.buy_btn_ticket == nil then
        self.buy_btn_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_buy_btn = true
            if self.buy_btn_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.buy_btn_ticket)
                self.buy_btn_ticket = nil
            end
        end,2)
    end
    self.touch_buy_btn = nil
    if self.data ~= nil and next(self.data) ~= nil then
        local charge_id  = config_gift_info[self.data.gifts[self.cur_index].award_id].charge_id
        local charge_config = Config.ChargeData.data_charge_data[charge_id or 0]
    	if charge_config then
    		sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
    	end
    end
end

--左边
function LimitTimeGiftWindow:onTouchLeft()
	self.touch_index = self.touch_index - 1
	if self.touch_index <= 1 then
		self.touch_index = 1
	end
	self:tabPageIconView(self.touch_index)
end
--右边
function LimitTimeGiftWindow:onTouchRight()
	self.touch_index = self.touch_index + 1
	if self.touch_index >= self.max_index then
		self.touch_index = self.max_index
	end
	self:tabPageIconView(self.touch_index)
end




function LimitTimeGiftWindow:close_callback()
	doStopAllActions(self.time)
	if self.image_bg_load then
        self.image_bg_load:DeleteMe()
        self.image_bg_load = nil
    end
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
	if self.gift_percent_num then
		self.gift_percent_num:DeleteMe()
		self.gift_percent_num = nil
	end
    if self.buy_btn_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_btn_ticket)
        self.buy_btn_ticket = nil
    end
	controller:openLimitTimeGiftWindow(false)
end