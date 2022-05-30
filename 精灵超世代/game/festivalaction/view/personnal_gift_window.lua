--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 个人推送礼包
-- @DateTime:    2019-07-26 11:21:19
-- *******************************
PersonnalGiftWindow = PersonnalGiftWindow or BaseClass(BaseView)

local controller = FestivalActionController:getInstance()
local num_pos_x = 325 --数字的位置
function PersonnalGiftWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "festivalaction/personal_gift_window"
    self.res_list = {
    	{ path = PathTool.getPlistImgForDownLoad("personalgift","personalgift"), type = ResourcesType.plist},
    	{ path = PathTool.getPlistImgForDownLoad("num","type30"), type = ResourcesType.plist},
	}
    self.item_list = {}
    self.cur_index = nil
    self.touch_index = 2 --默认的位置
    self.max_index = 3 --最大个数
    self.touch_buy_btn = true
end

function PersonnalGiftWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    local image_bg = self.main_container:getChildByName("image_bg")
    local res = PathTool.getPlistImgForDownLoad("bigbg/festivalaction","personalgift_bg1")
    self.image_bg_load = loadSpriteTextureFromCDN(image_bg, res, ResourcesType.single, self.image_bg_load)

    self.item_scroll = self.main_container:getChildByName("item_scroll")
    self.item_scroll:setScrollBarEnabled(false)

    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy_label = self.btn_buy:getChildByName("Text_1")
    self.btn_buy_label:setString("")
    self.time = self.main_container:getChildByName("time")
    self.time:setString("")
    self.limit_buy_text = self.main_container:getChildByName("limit_buy_text")
    self.limit_buy_text:setString("")
    self.gift_percent_num = CommonNum.new(30, self.main_container, nil, -5, cc.p(0.5, 0.5))
    self.gift_percent_num:setPosition(num_pos_x, 217)

  	local tab_page = self.main_container:getChildByName("tab_page")
  	tab_page:setVisible(false)
  	self.btn_left = tab_page:getChildByName("btn_left")
  	self.btn_right = tab_page:getChildByName("btn_right")
  	self.page_icon_list = {}
  	for i=1,3 do
  		self.page_icon_list[i] = tab_page:getChildByName("page_icon_"..i)
  	end
  	self:tabPageIconView(self.touch_index)

    self.btn_close = self.main_container:getChildByName("btn_close")
end
--奖励
function PersonnalGiftWindow:setRewardData(award_list)
	local pos_y = self.item_scroll:getContentSize().height
	local scroll = false
	local scale = 0.9
	local start_pos = 0
	local pos_list = {165,125,60,5}
	if #award_list <= 4 then
		pos_y = pos_y * 0.5 + 40
		start_pos = pos_list[#award_list]
		scroll = true
		self.item_scroll:setTouchEnabled(false)
	else
		scale = 0.8
		start_pos = 25
		local total_height = (BackPackItem.Height*scale) * math.ceil(#award_list/4)
	    local max_height = math.max(pos_y, total_height)
	    self.item_scroll:setInnerContainerSize(cc.size(self.item_scroll:getContentSize().width, max_height))
	end
	local pos_y_start = self.item_scroll:getInnerContainerSize().height - 60
	for i=1, #award_list do
		if not self.item_list[i] then
			self.item_list[i] = BackPackItem.new(true, true)
		    self.item_list[i]:setAnchorPoint(0, 0.5)
		    self.item_scroll:addChild(self.item_list[i])
		end
		if self.item_list[i] then
			self.item_list[i]:setScale(scale)
			self.item_list[i]:setDefaultTip(true)
			self.item_list[i]:setBaseData(award_list[i][1],award_list[i][2])
			local x = start_pos + (BackPackItem.Width*scale + 10) * ((i-1)%4)
			if scroll then
				self.item_list[i]:setPosition(x, pos_y)
			else
				local y = pos_y_start - math.floor((i-1)/4)*(BackPackItem.Height*scale+10)
				self.item_list[i]:setPosition(x, y)
			end
		end
	end
end
function PersonnalGiftWindow:openRootWnd()
    controller:sender26300()
end
function PersonnalGiftWindow:register_event()
	self:addGlobalEvent(FestivalActionEvent.Personal_Gift_Event,function(data)
		self:setData(data)
	end)
	registerButtonEventListener(self.btn_close, function()
		controller:openPersonalGiftView(false)
	end, false,2)
	registerButtonEventListener(self.background, function()
		controller:openPersonalGiftView(false)
	end, false,2)
	registerButtonEventListener(self.btn_buy, function()
		self:touchBtnCharge()
	end, true, 1)
	registerButtonEventListener(self.btn_left, function()
		self:onTouchLeft()
	end, false)
	registerButtonEventListener(self.btn_right, function()
		self:onTouchRight()
	end, false)
end
function PersonnalGiftWindow:setData(data)
	local warehouse_config = Config.HolidayPersonalGiftData.data_gift_warehouse
	if warehouse_config and warehouse_config[data.award_id] then
		local tab_data = {}
		tab_data.less_time = data.end_time - GameNet:getInstance():getTime()
		tab_data.time_model = 2
		tab_data.text = TI18N("后礼包消失")
		FestivalActionConst.CountDownTime(self.time, tab_data)

		local config = warehouse_config[data.award_id]
		self:setRewardData(config.award)
		
		self.limit_buy_text:setString(string.format(TI18N("限购: %d/%d"),data.count,config.limit_count))
		if data.count >= config.limit_count then
			self.btn_buy_label:setString(TI18N("已购买"))
			setChildUnEnabled(true, self.btn_buy)
			self.btn_buy:setTouchEnabled(false)
			self.btn_buy_label:disableEffect(cc.LabelEffect.OUTLINE)
		else
			self.btn_buy_label:setString(config.price..TI18N("元"))
		end

		self.gift_percent_num:setNum(config.name,true)
	  	local icon_per = createSprite(nil,num_pos_x+self.gift_percent_num:getContentSize().width*0.5, 185, self.main_container, cc.p(0, 0.5))
	  	loadSpriteTexture(icon_per, PathTool.getResFrame("type30","type30_per"), LOADTEXT_TYPE_PLIST)

		local price_config = Config.HolidayPersonalGiftData.data_price
		if price_config and price_config[config.price] then
			self.charge_id = price_config[config.price].charge_id
		end
	end
end
--点击充值按钮
function PersonnalGiftWindow:touchBtnCharge()
	if not self.charge_id then return end
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

    local charge_config = Config.ChargeData.data_charge_data[self.charge_id]
	if charge_config then
		sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
	end
end
--
function PersonnalGiftWindow:tabPageIconView(index)
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
end
--左边
function PersonnalGiftWindow:onTouchLeft()
	self.touch_index = self.touch_index - 1
	if self.touch_index <= 1 then
		self.touch_index = 1
	end
	self:tabPageIconView(self.touch_index)
end
--右边
function PersonnalGiftWindow:onTouchRight()
	self.touch_index = self.touch_index + 1
	if self.touch_index >= self.max_index then
		self.touch_index = self.max_index
	end
	self:tabPageIconView(self.touch_index)
end

function PersonnalGiftWindow:close_callback()
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
	controller:openPersonalGiftView(false)
end