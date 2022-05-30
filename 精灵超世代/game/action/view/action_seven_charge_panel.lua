----------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-05-23 19:35:22
-- @Description:   7天连充界面
----------------------------
ActionSevenChargePanel = class("ActionSevenChargePanel", function()
	return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
local model = controller:getModel()
local table_remove = table.remove
local table_insert = table.insert
local string_format = string.format
local SPECIAL_DAY = 7

function ActionSevenChargePanel:ctor(bid)
    self.holiday_bid = bid
	self:configUI()
	self:register_event()

	self.cur_day = 0 --连充活动第几天
	self.is_init = true --是否为初始化
	self.cur_item_index = 1
end

function ActionSevenChargePanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_seven_charge_panel"))
	self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setPosition(-40, -80)
	self:setAnchorPoint(0, 0)

	self.main_container = self.root_wnd:getChildByName("main_container")
	self.image_bg = self.main_container:getChildByName("image_bg")

    local str = ""
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str = tab_vo.reward_title
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.image_bg) then
                self.image_bg:loadTexture(res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

	self.btn_tips = self.main_container:getChildByName("btn_tips")
	self.img_progress_bg = self.main_container:getChildByName("img_progress_bg")
	self.img_progress_bg:getChildByName("txt_progres"):setString(TI18N("今日进度"))
	self.bar_bg = self.main_container:getChildByName("bar_bg")
	self.bar_progress = self.bar_bg:getChildByName("bar_progress")
	self.bar_progress:setScale9Enabled(true)
	self.bar_progress:setPercent(0)
	self.bar_progress:setPositionX(self.bar_progress:getPositionX() - 0.5)
	self.bar_num = self.bar_bg:getChildByName("bar_num") --进度条比例=当天已充值金额/当天签到指定金额
	self.bar_num:setString("")
	self.txt_time_title = self.main_container:getChildByName("txt_time_title")
	self.txt_time_title:setString(TI18N("剩余时间："))
	self.txt_time_value = self.main_container:getChildByName("txt_time_value")
	self.txt_time_value:setString("")
	self.btn_charge = self.main_container:getChildByName("btn_charge")
	self.txt_charge = self.btn_charge:getChildByName("label")
	self.txt_charge:setString(TI18N("前往充值"))
	self.btn_get_reward = self.main_container:getChildByName("btn_get_reward")
	self.btn_get_reward:getChildByName("label"):setString(TI18N("领取奖励"))
	self.btn_get_reward:setVisible(false)

	local total_reward_list = self.main_container:getChildByName("total_reward_list")
	local scroll_view_size = total_reward_list:getContentSize()
	local setting = {
        item_class = ActionSevenChargeItem,
        start_x = 0,
        space_x = 20,
        start_y = 5,
        space_y = 20,
        item_width = 137,
        item_height = 150,
        row = 2,
        col = 3,
        need_dynamic = true
    }
    self.total_reward_scrollview = CommonScrollViewLayout.new(total_reward_list, cc.p(10, -15), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.total_reward_scrollview:setSwallowTouches(false)
    self.total_reward_scrollview:setClickEnabled(false)

 	self.cur_reward_scrollview = self.main_container:getChildByName("cur_reward_list")
    self.cur_reward_scrollview:setScrollBarEnabled(false)

	controller:sender16666(self.holiday_bid)
	controller:cs16603(self.holiday_bid)
end

function ActionSevenChargePanel:register_event()
	if not self.update_holiday_common_event then
        self.update_holiday_common_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if not data then return end
            if data.bid == self.holiday_bid then
                self:setPanelData(data)
            end
        end)
    end

    registerButtonEventListener(self.btn_tips, function(param, sender, event_type)
        local config
        if self.holiday_bid == ActionRankCommonType.seven_charge then
            config = Config.HolidayClientData.data_constant.seven_charge_rules
        end
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    end ,true, 1)

    registerButtonEventListener(self.btn_charge, function()
    	local data = model:getSevenChargeDataByDay(self.cur_item_index)
		if data then
			if data.status == 3 then --补签领奖
				local function func()
					VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
					--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
		        end
		        local is_get_resignin = model:getIsGetResignin()
		        if data.re_signin_charge > 0 or is_get_resignin then
					local tip_str = string_format(TI18N("今天再充值%d元,即可领取补签奖励"), data.re_signin_charge)
					CommonAlert.show(tip_str, TI18N("确定"), func, TI18N("取消"), nil, CommonAlert.type.rich)
				end
			else
				VipController:getInstance():openVipMainWindow(true, VIPTABCONST.CHARGE)
				--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
			end
		end
    end ,true, 1)

    registerButtonEventListener(self.btn_get_reward, function()
		if self.holiday_bid and self.cur_item_index then
			controller:cs16604(self.holiday_bid, self.cur_item_index, 0)
		end
    end ,true, 1)
end

function ActionSevenChargePanel:setPanelData(data)
	if not data then return end
	--倒计时
	local time = data.remain_sec or 0
	commonCountDownTime(self.txt_time_value, time)
	local pos_x = self.txt_time_value:getPositionX() - self.txt_time_value:getContentSize().width
	self.txt_time_title:setPositionX(pos_x + 5)

	--当前天数
	self.cur_day = model:getCurChargeDay()
	local charge_data = model:getSevenChargeDataByDay(self.cur_day)

	--累计充值/目标充值
	self.bar_num:setString(string_format(TI18N("%d/%d元"), data.finish, charge_data.need_charge))
	self.bar_progress:setPercent(100 * data.finish / charge_data.need_charge)

	local temp_list = model:getSevenChargeData()
	if temp_list then
		local reward_list = deepCopy(temp_list)
		table_remove(reward_list, #reward_list) --取前6天
		if self.total_reward_scrollview then
			local tab = {}
        	tab.cur_day = self.cur_day --当前活动进度天数
	        self.total_reward_scrollview:setData(reward_list, function(data)
	        	self.cur_item_index = data.aim
		        if data and data.aim then
		            self:updateCurRewardList(data.aim)
		        end
		        self:updateBottemBtn(data)
		    end, nil, tab)
	    end
	end
	--第7天特殊处理
	local seven_data = model:getSevenChargeDataByDay(SPECIAL_DAY)
	self:updateSevenItem(seven_data)

	--刷新底部按钮、列表数据
	local wait_for_reward = {}
	local reward_list = model:getSevenChargeData()
	for k,v in pairs(reward_list) do
		if v.status == 1 then
			table_insert(wait_for_reward, v)
		end
	end
	local reward_day = 0
	if #wait_for_reward > 0 then
		for k,v in pairs(wait_for_reward) do
			local reward_day = v.aim
			local next_charge_data = model:getSevenChargeDataByDay(reward_day)
			self.cur_item_index = reward_day
			self:updateBottemBtn(next_charge_data)
			self:updateCurRewardList(reward_day)
			return
		end
	else
		self:updateBottemBtn(charge_data)
		self:updateCurRewardList()
	end
end

--第7天图标展示
function ActionSevenChargePanel:updateSevenItem(data)
	if data.aim == SPECIAL_DAY then
		if not self.seven_item then
			self.seven_item = BackPackItem.new(true, true, false, 1)
			self.main_container:addChild(self.seven_item)
			self.seven_item:setBaseData(data.item_bid, data.item_num)
		    self.seven_item:setAnchorPoint(cc.p(0.5, 0.5))
		    self.seven_item:setPosition(cc.p(585, 443))

		    local act_1 = cc.MoveBy:create(1, cc.p(0, 8))
		    local act_2 = cc.MoveBy:create(1, cc.p(0, -8))
		    self.seven_item:runAction(cc.RepeatForever:create(cc.Sequence:create(act_1, act_2)))
		end
		if self.cur_day == data.aim then
			self.img_arrow = createImage(self.seven_item, PathTool.getResFrame("actionsevencharge","actionsevencharge_5"), self.seven_item:getContentSize().width/2, 130, cc.p(0.5, 0), true, 1, false)
		end
		self.seven_item:addCallBack(function()
    		self:updateCurRewardList(SPECIAL_DAY)
    		self:updateBottemBtn(data)
			if data.status == 1 then --可领奖
				if self.holiday_bid then
					controller:cs16604(self.holiday_bid, data.aim, 0)
				end
			end
	    end)

		if self.is_init and self.seven_item then
			self.is_init = false
			local item_size = self.seven_item:getContentSize()
			self.item_effect = createEffectSpine(PathTool.getEffectRes(535), cc.p(item_size.width/2 + 10, item_size.height/2 - 35), cc.p(0.5, 0.5), true, PlayerAction.action)
			self.seven_item:addChild(self.item_effect)
			self.item_effect:setScale(0.9)
			--已领取
			self.has_get = createImage(self.seven_item, PathTool.getResFrame("actionsevencharge","actionsevencharge_2"), item_size.width/2, item_size.height/2, cc.p(0.5, 0.5), true, 1)
            --可补签
    		self.re_signin = createImage(self.seven_item, PathTool.getResFrame("actionsevencharge","actionsevencharge_1"), item_size.width/2, item_size.height/2, cc.p(0.5, 0.5), true, 1)
    		--价格
			self.price_bg = createScale9Sprite(PathTool.getResFrame("actionsevencharge","actionsevencharge_3"), 587, 271, LOADTEXT_TYPE_PLIST, self.main_container)
		    self.price_bg:setAnchorPoint(cc.p(0.5, 0))
			self.price_bg:setContentSize(cc.size(135, 39))
			self.price_bg:setCapInsets(cc.rect(12, 18, 3, 3))
			local str = string_format(TI18N("第%d天%d元"), data.aim, data.need_charge)
			self.txt_price_desc = createLabel(20, cc.c3b(253,204,127), nil, 587, 290, str, self.main_container, nil, cc.p(0.5, 0.5))
			self.txt_price_desc:setString(str)
		end

		self.item_effect:setVisible(data.status == 1)
		self.has_get:setVisible(data.status == 2)
		self.re_signin:setVisible(data.status == 3)
		if data.status == 2 then --已领取
			self.seven_item:setItemIconUnEnabled(true)
		end
	end
end

--加载水平居中的当前奖励列表
function ActionSevenChargePanel:updateCurRewardList(day)
	local day = day or self.cur_day
	local reward_list = model:getDailyRewardListById(day)
	if reward_list then
		local data_list = {}
	    for i,v in ipairs(reward_list) do
	        local item = {}
	        item[1] = v.bid
	        item[2] = v.num
	        table_insert(data_list, item)
	    end
	    if #data_list > 0 then
			local setting = {}
		    setting.scale = 0.8
		    setting.start_x = 0
		    setting.space_x = 30
		    setting.max_count = 5
		    setting.is_center = true
		    self.item_list = commonShowSingleRowItemList(self.cur_reward_scrollview, self.item_list, data_list, setting)
		end
	end
end

function ActionSevenChargePanel:updateBottemBtn(data)
	if data.status == 0 then --不可领奖
		if data.aim == self.cur_day then --当天进度
			self:updateBtnStatus(false, TI18N("前往充值"))
		else
			self:updateBtnStatus(false, TI18N("未达成"), true)
		end
	elseif data.status == 1 then --可领奖
		self:updateBtnStatus(true)
	elseif data.status == 2 then --已领取
		self:updateBtnStatus(false, TI18N("已领取"), true)
	elseif data.status == 3 and data.re_signin_charge then --补签
	    local is_get_resignin = model:getIsGetResignin()
	    if data.re_signin_charge <= 0 and not is_get_resignin then --补签可领奖
		    self:updateBtnStatus(true)
		else
			self:updateBtnStatus(false, TI18N("前往充值"))
		end
	end
end

--刷新领奖/充值按钮状态
function ActionSevenChargePanel:updateBtnStatus(can_get_reward, str, is_gray)
	self.btn_get_reward:setVisible(can_get_reward)
	self.btn_charge:setVisible(not can_get_reward)
	self.txt_charge:setString(str)
	if is_gray then
		self.btn_charge:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_charge)
		self.txt_charge:enableOutline(Config.ColorData.data_color4[84], 2)
	else
		self.btn_charge:setTouchEnabled(true)
		setChildUnEnabled(false, self.btn_charge)
		self.txt_charge:enableOutline(Config.ColorData.data_color4[264], 2)
	end
end

function ActionSevenChargePanel:setVisibleStatus(bool)
	bool = bool or false
	self:setVisible(bool)
end

function ActionSevenChargePanel:DeleteMe()
	if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
	doStopAllActions(self.txt_time_value)
	if self.total_reward_scrollview then
        self.total_reward_scrollview:DeleteMe()
    end
    self.total_reward_scrollview = nil
    if self.update_holiday_common_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_common_event)
        self.update_holiday_common_event = nil
    end
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.cur_reward_scrollview)
end

----------------------------------------
-- @Description:   7天连充子item
----------------------------------------
ActionSevenChargeItem = class("ActionSevenChargeItem", function()
    return ccui.Widget:create()
end)

function ActionSevenChargeItem:ctor()
    self:configUI()
end

function ActionSevenChargeItem:configUI()
    self.size = cc.size(137, 150)
    self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0, 0))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.reward_item = BackPackItem.new(true, true, false, 0.9)
    self.reward_item:addCallBack(function() self:selectItem() end)
    self.reward_item:setAnchorPoint(cc.p(0.5, 1))
    self.reward_item:setPosition(cc.p(self.size.width/2, self.size.height))
    self.root_wnd:addChild(self.reward_item)

    local reward_size = self.reward_item:getContentSize()
    --可补签
    local re_signin = createImage(self.reward_item, PathTool.getResFrame("actionsevencharge","actionsevencharge_1"), reward_size.width/2, reward_size.height/2, cc.p(0.5, 0.5), true, 1)
    re_signin:setVisible(false)
    self.reward_item.re_signin = re_signin
    --已领取
    local has_get = createImage(self.reward_item, PathTool.getResFrame("actionsevencharge","actionsevencharge_2"), reward_size.width/2, reward_size.height/2, cc.p(0.5, 0.5), true, 2)
    has_get:setVisible(false)
    self.reward_item.has_get = has_get

    self.price_bg = createScale9Sprite(PathTool.getResFrame("actionsevencharge","actionsevencharge_3"), self.size.width/2, 0, LOADTEXT_TYPE_PLIST, self.root_wnd)
    self.price_bg:setAnchorPoint(cc.p(0.5, 0))
	self.price_bg:setContentSize(cc.size(135, 39))
	self.price_bg:setCapInsets(cc.rect(12, 18, 3, 3))

	self.txt_price_desc = createLabel(20, cc.c3b(253,204,127), nil, self.size.width/2, 20, "", self.root_wnd, nil, cc.p(0.5, 0.5))
end

function ActionSevenChargeItem:addCallBack(callback)
	self.call_back = callback
end

function ActionSevenChargeItem:setExtendData(tab)
	self.cur_day = tab.cur_day
end

function ActionSevenChargeItem:setData(data)
	self.data = data

	self.is_get_resignin = model:getIsGetResignin()
	
	if data.item_bid and data.item_num then
		self.reward_item:setBaseData(data.item_bid, data.item_num, true)
	end

	if data.aim and data.need_charge then
		self.txt_price_desc:setString(string_format(TI18N("第%d天%d元"), data.aim, data.need_charge))
	end

	if data.status then
		if data.aim == self.cur_day and data.status ~= 2 then --当天进度
			self:showEffect(data.item_bid, true)
		end
		if data.status == 1 then --可领取
			self:showEffect(data.item_bid)
			self.reward_item.re_signin:setVisible(false)
		elseif data.status == 2 then --已领取
			self.reward_item:setItemIconUnEnabled(true)
			self.reward_item.has_get:setVisible(true)
		elseif data.status == 3 and data.re_signin_charge then --可补签
			self.reward_item.re_signin:setVisible(true)
			if data.re_signin_charge <= 0 and not self.is_get_resignin then
				self:showEffect(data.item_bid)
				self.reward_item.re_signin:setVisible(false)
			end
		end
	end
end

function ActionSevenChargeItem:showEffect(bid, in_progress)
	local in_progress = in_progress or false
	if in_progress then
		self.reward_item:showItemEffect(true, 262, PlayerAction.action, true, 1.1)
	else
	    local config = Config.ItemData.data_get_data(bid)
		if config and config.quality >= 4 then
			self.reward_item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
		else
			self.reward_item:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
		end
	end
end

function ActionSevenChargeItem:selectItem()
	if not self.data then
		message(TI18N("无奖励信息"))
		return
	end
	if self.call_back and self.data then
        self.call_back(self.data)
    end
end

function ActionSevenChargeItem:DeleteMe()
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
	self:removeAllChildren()
    self:removeFromParent()
end