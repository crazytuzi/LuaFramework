-- --------------------------------------------------------------------
--- 荣耀月卡 
-- --------------------------------------------------------------------
HonorYuekaPanel = class("HonorYuekaPanel", function()
	return ccui.Widget:create()
end)

local controll = WelfareController:getInstance()
local card_data = Config.ChargeData.data_constant
local string_format = string.format
local card2_add_count = card_data.month_card2_sun.val
local item_bid_2 = card_data.month_card2_items.val[1][1]
local item_num_2 = card_data.month_card2_items.val[1][2]
local add_get_day_2 = card_data.month_card2_cont_day.val
function HonorYuekaPanel:ctor()
	self.current_day = 0
	self:loadResources()
end

function HonorYuekaPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","txt_cn_welfare_yueka_bg2"), type = ResourcesType.single },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
        	self:loadResListCompleted()
        end
    end)
end
function HonorYuekaPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end
function HonorYuekaPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/yueka_panel"))
	self:addChild(self.root_wnd)
	-- self:setCascadeOpacityEnabled(true)
	self:setPosition(17.5, 450)
	self:setAnchorPoint(0, 0)
	
	self.main_container = self.root_wnd:getChildByName("main_container")

	local bg = self.main_container:getChildByName("bg")
	local res_id = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_welfare_yueka_bg2")
    if not self.title_load then
        self.title_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(bg) then
                loadSpriteTexture(bg,res_id,LOADTEXT_TYPE)
            end
        end, self.title_load)
    end

	self.btn_1 = self.main_container:getChildByName("btn_1")
	self.btn_1:getChildByName("Text_1"):setString(TI18N("充值激活"))
	self.bar_bg = self.main_container:getChildByName("Image_1_0")
	self.bar = self.bar_bg:getChildByName("bar")
	if self.bar then
		self.bar:setScale9Enabled(true)
	end
	self.current_change = self.bar_bg:getChildByName("current_change")
	self.current_change:setString(TI18N("当前充值："))
	self.main_container:getChildByName("Text_3"):setVisible(false)
	self.main_container:getChildByName("btn_rule"):setVisible(false)

	self.image_get = self.main_container:getChildByName("image_get")
	self.image_get:setVisible(false)
	self.text_day = self.image_get:getChildByName("text_day")
	self.text_day:setString("")
	self.btn_get = self.image_get:getChildByName("btn_get")
	self.btn_get_label = self.btn_get:getChildByName("Text_4")
	self.btn_get_label:setString(TI18N("领取"))
	--self.btn_get_label:enableOutline(Config.ColorData.data_color4[263], 2)

	
	self.text_1 = createRichLabel(24, Config.ColorData.data_color4[1], cc.p(0.5,0.5), cc.p(180,50), nil, nil, 400)
    self.bar_bg:addChild(self.text_1)
    self.text_2 = createRichLabel(24, Config.ColorData.data_color4[1], cc.p(0.5,0.5), cc.p(524,210), nil, nil, 400)
    self.main_container:addChild(self.text_2)
    self.text_3 = createRichLabel(24, Config.ColorData.data_color4[1], cc.p(0.5,0.5), cc.p(524,164), nil, nil, 400)
    self.main_container:addChild(self.text_3)

	local str = string_format(TI18N("<div outline=2,#110800>任意累计充值达到</div><div fontcolor=#ffd862 outline=2,#000000> %d元 </div><div outline=2,#110800>即可激活</div>"),card2_add_count)
    self.text_1:setString(str)

    local item_config = Config.ItemData.data_get_data(card_data.month_card2_return.val[1][1])
	local str = string_format(TI18N("<div outline=2,#110800>充值就</div><div fontsize=34 fontcolor=#ffd862 outline=2,#000000> 送%d天 </div><div outline=2,#110800>月卡</div>"),add_get_day_2)
    self.text_2:setString(str)

    local item_config = Config.ItemData.data_get_data(item_bid_2)
	local str = string_format(TI18N("<div outline=2,#110800>每日可领取</div><div fontsize=34 fontcolor=#ffd862 outline=2,#000000> %d </div><img src=%s visible=true scale=0.30 />"),item_num_2,PathTool.getItemRes(item_config.icon))
	self.text_3:setString(str)
	controll:sender16705()
end

function HonorYuekaPanel:register_event()
	if self.update_supre_event == nil then
		self.update_supre_event = GlobalEvent:getInstance():Bind(WelfareEvent.Update_Yueka, function(data)
			local add_count,acc_count,item_bid,item_num,day,get_day,end_time = 100,100,nil,nil,0,0,0
			if data.card2_is_reward == 0 then
				self.image_get:setVisible(false)
				self.btn_1:setVisible(true)
				self.text_1:setVisible(true)
				self.bar_bg:setVisible(true)
				add_count = card2_add_count
				acc_count = data.card2_acc
			elseif data.card2_is_reward == 1 or data.card2_is_reward == 2 then
				item_bid = item_bid_2
				item_num = item_num_2
				day = data.card2_days
				get_day = add_get_day_2
				end_time = data.card2_end_time

				self.current_day = day
				self.image_get:setVisible(true)
				self.btn_1:setVisible(false)
				self.text_1:setVisible(false)
				self.bar_bg:setVisible(false)
				if data.card2_is_reward == 1 then
    				setChildUnEnabled(false, self.btn_get)
    				self.btn_get_label:setString(TI18N("领取"))
    				--self.btn_get_label:enableOutline(Config.ColorData.data_color4[263], 2)
				elseif data.card2_is_reward == 2 then
					setChildUnEnabled(true, self.btn_get)
					self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
					self.btn_get_label:setString(TI18N("已领取"))
				end
			end

			self.bar:setPercent(math.floor(acc_count/add_count *100))

			local str = string_format(TI18N("当前充值：%d / %d"),acc_count,add_count)
			self.current_change:setString(str)

	    	self.text_day:setString(self.current_day)
		end)
	end

	self.update_get_supre_event = GlobalEvent:getInstance():Bind(WelfareEvent.Update_Get_Yueka, function(_type)
		if _type == 2 then
			setChildUnEnabled(true, self.btn_get)
			self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
			self.btn_get_label:setString(TI18N("已领取"))

			self.current_day = self.current_day + 1
			self.text_day:setString(self.current_day)
		end
	end)
	
	registerButtonEventListener(self.btn_1, function()
		VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
		--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
    end,true, 1)
    registerButtonEventListener(self.btn_get, function()
		WelfareController:getInstance():sender16706(2)
    end,true, 1)
end

function HonorYuekaPanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function HonorYuekaPanel:DeleteMe()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end

    if self.title_load then 
        self.title_load:DeleteMe()
        self.title_load = nil
    end
	if self.update_supre_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_supre_event)
		self.update_supre_event = nil
	end
	if self.update_get_supre_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_get_supre_event)
		self.update_get_supre_event = nil
	end
end 