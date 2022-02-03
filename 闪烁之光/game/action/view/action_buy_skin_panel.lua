--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 皮肤购买
-- @DateTime:    2019-05-10 09:49:04
-- *******************************
ActionBuySkinPanel = class("ActionBuySkinPanel", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
function ActionBuySkinPanel:ctor(bid)
	self.holiday_bid = bid
	self.touch_buy_skin = true
	self.attr_list = {}
	self:configUI()
	self:register_event()
end

function ActionBuySkinPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_buy_skin_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.holiday_bg = self.main_container:getChildByName("bg")
    self:setHolidayBG()
    
    self.btn_fight = self.main_container:getChildByName("btn_fight")
    self.btn_fight:getChildByName("Text_1"):setString(TI18N("皮肤预览"))
    -- self.btn_fight:setVisible(false)
    self.text_attr = self.main_container:getChildByName("Text_32")
    self.text_attr:setString(TI18N("属性加成："))
    self.text_attr:setVisible(false)

    local Text_2 = self.main_container:getChildByName("Text_2")
    Text_2:setString(TI18N("现价:￥"))
    Text_2:setVisible(false)
    self.text_price = self.main_container:getChildByName("text_price")
    self.text_price:setVisible(false)
    self.text_price:setString("")
    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy_text = self.btn_buy:getChildByName("Text_4")
    self.btn_buy_text:setString("")
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")

	local goods = self.main_container:getChildByName("goods")
	local scroll_view_size = goods:getContentSize()
    local setting = {
        item_class = BackPackItem,
        start_x = 10,
        space_x = 10,
        start_y = 15,
        space_y = 0,
        item_width = BackPackItem.Width*0.90,
        item_height = BackPackItem.Height*0.90,
        row = 1,
        col = 0,
        scale = 0.90
    }
    self.item_scrollview = CommonScrollViewLayout.new(goods,cc.p(0,0),ScrollViewDir.horizontal,ScrollViewStartPos.top,scroll_view_size,setting)
    self.item_scrollview:setSwallowTouches(false)
    
    controller:cs16603(self.holiday_bid)
end

function ActionBuySkinPanel:setHolidayBG()
	local str_bg = "txt_cn_hero_skin_buy"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.aim_title ~= "" and tab_vo.aim_title then
        str_bg = tab_vo.aim_title
    end
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str_bg)
    if not self.bg_load then
        self.bg_load = loadSpriteTextureFromCDN(self.holiday_bg, res, ResourcesType.single, self.bg_load)
    end
end

function ActionBuySkinPanel:register_event()
	if not self.skin_buy_event then
        self.skin_buy_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if not data then return end
            if data.bid == self.holiday_bid then
            	commonCountDownTime(self.time_text, data.remain_sec)
                self:setData(data)
            end
        end)
    end    
	registerButtonEventListener(self.btn_fight, function()  --皮肤预览按钮屏蔽
		TimesummonController:getInstance():send23219(ActionRankCommonType.action_skin_buy)
	end, true, 2, nil,nil, 2)
	
	registerButtonEventListener(self.btn_buy, function()
		self:setCheckHasHeroSkin()
	end, true)
end

--购买皮肤
function ActionBuySkinPanel:setCheckHasHeroSkin()
	if not self.touch_buy_skin then return end
	if not self.cur_skin_id then return end

	--判断皮肤是否拥有
	local is_has_skin = HeroController:getModel():isUnlockHeroSkin(self.cur_skin_id, true)
	if is_has_skin then
		local skin_info = Config.PartnerSkinData.data_skin_info
		if skin_info and skin_info[self.cur_skin_id] then
			local data = skin_info[self.cur_skin_id].diamond_num
			if data and data[1] then
				local item_config = Config.ItemData.data_get_data(data[1][1])
				local icon_src = PathTool.getItemRes(item_config.icon)
				local str = string.format(TI18N("您已拥有当前皮肤的永久使用权，再次购买后使用将会转化成 <img src='%s' scale=0.3 /><div fontcolor=#289b14> *%d </div>，是否继续购买"),icon_src,data[1][2])
		        local call_back = function()
		            self:setChargeSkin()
		        end
		        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
				return
			end
		end
	end
	self:setChargeSkin()
end
function ActionBuySkinPanel:setChargeSkin()
	if self.buy_skin_ticket == nil then
        self.buy_skin_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_buy_skin = true
            if self.buy_skin_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.buy_skin_ticket)
                self.buy_skin_ticket = nil
            end
        end,3)
    end
    self.touch_buy_skin = nil
	if self.buy_charge_id then
		local charge_config = Config.ChargeData.data_charge_data[self.buy_charge_id]
		if charge_config then
			sdkOnPay(charge_config.val, 1, charge_config.id, charge_config.name)
		end
	end
end
function ActionBuySkinPanel:setData(data_list)
	local data = data_list.aim_list or nil
	if data and data[1] and data[1].aim_args then
		local effect_list = keyfind('aim_args_key', 40, data[1].aim_args) or nil
		if effect_list then
			local effect_count = effect_list.aim_args_val or 0
			local res_id = Config.EffectData.data_effect_info[effect_count]
		    if res_id then
				self.bg_effect = createEffectSpine(res_id, cc.p(0, -70), cc.p(0.5, 0.5), true, PlayerAction.action)
				self.main_container:addChild(self.bg_effect)
			end
		end

		local skin_list = keyfind('aim_args_key', 35, data[1].aim_args) or nil
		local skin_count
		if skin_list then
			skin_count = skin_list.aim_args_val or 0
		end
		if skin_count then
			self.cur_skin_id = skin_count
			self:setAttrGoodsData(skin_count,data[1].item_list)
		end

		if data_list.finish ~= 0 then
			setChildUnEnabled(true, self.btn_buy)
			self.btn_buy_text:setString(TI18N("已购买"))
			self.btn_buy_text:disableEffect(cc.LabelEffect.OUTLINE)
			self.btn_buy:setTouchEnabled(false)
		else
			--现价
			local new_list = keyfind('aim_args_key', 33, data[1].aim_args) or nil
			local buy_charge_id
			if new_list then
				buy_charge_id = new_list.aim_args_val or 0
			end
			if buy_charge_id then
				self.buy_charge_id = buy_charge_id
				local charge_data = Config.ChargeData.data_charge_data
				if charge_data[buy_charge_id] then
					self.btn_buy_text:setString("￥"..charge_data[buy_charge_id].val)
				end
			end
		end
	end
end

--设置属性
function ActionBuySkinPanel:setAttrGoodsData(bid, item_data)
	local skin_attr = Config.PartnerSkinData.data_skin_info
	if skin_attr and skin_attr[bid] then
		local attr = skin_attr[bid].skin_attr or {}
		local str_sttr = {}
		for i,v in pairs(attr) do
			local attr_icon = PathTool.getAttrIconByStr(v[1])
			local name = Config.AttrData.data_key_to_name[v[1]] or ""
		    local sttr_1,sttr_2,sttr_3 = commonGetAttrInfoByKeyValue(v[1], v[2])
	 		str_sttr[i] = string.format("<img src=%s visible=true scale=1 /><div fontColor=#89ff83 outline=2,#000000> %s+%s</div>",sttr_1,sttr_2,sttr_3)
		end
		local str = ""
		for i=1, #str_sttr do
			str = str .. str_sttr[i] .. "  "
		end

		local attr_msg = createRichLabel(22, cc.c4b(0xff,0xff,0xff,0xff), cc.p(1, 0.5), cc.p(679,262),nil,nil,600)
		self.main_container:addChild(attr_msg)
		attr_msg:setString(TI18N("<div fontColor=#ffffff outline=2,#000000>属性加成：</div>")..str)
	end
	if item_data then
		local list = {}
	    for k, v in pairs(item_data) do
	        local vo = {}
            vo.bid = v.bid
            vo.quantity = v.num
            table.insert(list, vo)
	    end
	    if #list > 4 then
	    	self.item_scrollview:setClickEnabled(true)
	    else
	    	self.item_scrollview:setClickEnabled(false)
	    end
	    self.item_scrollview:setData(list)
	    self.item_scrollview:addEndCallBack(function()
	        local list = self.item_scrollview:getItemList()
	        for k,v in pairs(list) do
	            v:setDefaultTip()
	        end
	    end)
	end
end

function ActionBuySkinPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function ActionBuySkinPanel:DeleteMe()
	if self.buy_skin_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.buy_skin_ticket)
        self.buy_skin_ticket = nil
    end
	doStopAllActions(self.time_text)
	if self.bg_effect then
        self.bg_effect:clearTracks()
        self.bg_effect:removeFromParent()
        self.bg_effect = nil
    end
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.skin_buy_event then
        GlobalEvent:getInstance():UnBind(self.skin_buy_event)
        self.skin_buy_event = nil
    end
end