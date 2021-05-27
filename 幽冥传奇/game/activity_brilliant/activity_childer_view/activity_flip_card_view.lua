ActFlipCardView = ActFlipCardView or BaseClass(ActBaseView)

function ActFlipCardView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function ActFlipCardView:__delete()
    if nil ~= self.record_list_view then
		self.record_list_view:DeleteMe()
		self.record_list_view = nil
	end

	if nil ~= self.brand_group then
		self.brand_group:Clear()
		self.brand_group = nil
	end

	if self.open_alert then
		self.open_alert:DeleteMe()
		self.open_alert = nil
	end
end

function ActFlipCardView:InitView()
	local ph_record_list = self.ph_list.ph_record_list
	self.record_list_view = ListView.New()
	self.record_list_view:CreateView({x = ph_record_list.x, y = ph_record_list.y, width = ph_record_list.w, height = ph_record_list.h,
		direction = ScrollDir.Vertical, itemRender = BrandRecordRender, gravity = nil, bounce = true})
	self.record_list_view:SetItemsInterval(7)
	self.record_list_view:AddListEventListener(BindTool.Bind(self.RecordListEvent, self))
    self.node_t_list.layout_flip_cards.node:addChild(self.record_list_view:GetView(), 99)
    
    local ph_brand_area = self.ph_list.ph_brand_area
	self.brand_group = self:CreateBrandGroup(ph_brand_area.x, ph_brand_area.y, ph_brand_area.w, ph_brand_area.h, 3, ActBrandRender, self.ph_list.ph_brand_render)
	self.node_t_list.layout_flip_cards.node:addChild(self.brand_group:GetView(), 99)
	self.brand_group:SetClickEvent(BindTool.Bind(self.OnClickBrand, self))
	self.brand_group:GetStartBrand():AddClickEventListener(BindTool.Bind(self.OnClickStartBrand, self), true)
	XUI.AddClickEventListener(self.brand_group.reset_button, BindTool.Bind(self.OnClickResetBrand, self))
end

local is_draw = false
function ActFlipCardView:OnClickStartBrand(brand_render)
	if is_draw then return end
	is_draw = true
	GlobalTimerQuest:AddDelayTimer(function ()
		is_draw = false
	end, 0.5)

	local times = ActivityBrilliantData.Instance:GetBrandTimes()
	if times > 0 then
		self.brand_group:DealBrand(true)
	end
end

local is_reset = false
function ActFlipCardView:OnClickResetBrand()
	if is_reset then return end
	is_reset = true
	GlobalTimerQuest:AddDelayTimer(function ()
		is_reset = false
	end, 0.5)

	self.brand_group:PackUpBrand(true, function()
		self:ResetBrand()
		self.brand_group:ShowStartBrand()
		self:FlushBrand()
	end)
end

local is_click_brand = false
function ActFlipCardView:OnClickBrand(brand_render)
	if is_click_brand then return end
	is_click_brand = true
	GlobalTimerQuest:AddDelayTimer(function ()
		is_click_brand = false
	end, 0.5)
	if nil == brand_render then
		return
	end
	local index = brand_render:GetIndex()
	if brand_render:CanTurnOpen() then
		local need_gold = ActivityBrilliantData.Instance:GetCurTurnBrandNeedGold()
		if need_gold > 0 then
			self.open_alert = self.open_alert or Alert.New()
			self.open_alert:SetShowCheckBox(false)
			self.open_alert:SetLableString(string.format(Language.ActivityBrilliant.OpenBrandAlertFormat, need_gold))
			self.open_alert:SetOkFunc(function()
				ItemData.Instance:SetDaley(true)
				ActivityBrilliantCtrl.SentTurnBrandReq(index)
			end)
			self.open_alert:Open()
		else
			ItemData.Instance:SetDaley(true)
			ActivityBrilliantCtrl.SentTurnBrandReq(index)
		end
	end
end

function ActFlipCardView:ResetBrand()
	ActivityBrilliantCtrl.EndCurBrand()
	ActivityBrilliantCtrl.ActivityReq(3, ACT_ID.XYFP)
	local brand_data_list = ActivityBrilliantData.Instance:GetBrandDataList()
	self.brand_group:ReadyAllBrands(brand_data_list)
end

function ActFlipCardView:SwitchIndexView()
	ActivityBrilliantCtrl.EndCurBrand()
end

function ActFlipCardView:ShowIndexView()
	ActivityBrilliantCtrl.SendTurnRecordReq()
	if ActivityBrilliantData.Instance:HaveBrandNum() == 0 then
		self:ResetBrand()
		self.brand_group:ShowStartBrand()
		self:FlushBrand()
	else
		self.brand_group:DealBrand(false)
		self:OpenBrand()
	end
end

function ActFlipCardView:FlushBrand()
	local start_brand = self.brand_group:GetStartBrand()
	local brand_times = ActivityBrilliantData.Instance:GetBrandTimes()
	if brand_times > 0 then
		start_brand:SetEffect(451)
		start_brand:RunShakeAction()
	else
		start_brand:SetEffect(0)
		start_brand:StopShakeAction()
	end

	local left_times_txt = string.format(Language.ActivityBrilliant.BrandTimesFormat, brand_times > 0 and COLORSTR.GREEN or COLORSTR.RED, brand_times)
	RichTextUtil.ParseRichText(self.brand_group.turn_left_txt, left_times_txt)

	local opened_count = ActivityBrilliantData.Instance:HaveBrandNum()
	self.brand_group.reset_button:setVisible( opened_count > 0)
	-- self.brand_group.turn_left_txt:setVisible( opened_count > 0)
end

function ActFlipCardView:RecordListEvent(render, event_type)
	if event_type == XuiListEventType.Refresh then
		render:jumpToTop()
	end
end

function ActFlipCardView:CreateBrandGroup(x, y, w, h, brand_num, brand_render, render_ui_cfg)
	local view = XUI.CreateLayout(x, y, w, h)
	local center_pos = cc.p(w / 2, h / 2)

	-- 开始的牌 点击后展开所有牌
	local start_brand = brand_render.New()
	start_brand:SetUiConfig(render_ui_cfg, true)
	start_brand:SetAnchorPoint(0.5, 0.5)
	start_brand:SetPosition(center_pos.x, center_pos.y)
	start_brand:SetIsStartBrand()
	start_brand:SetVisible(false)
	view:addChild(start_brand:GetView(), 200, 200)

	-- 可翻开的牌
	local brands = {}
	brand_num = brand_num or 1
	local r = 160

	for i = 1, brand_num do
		local brand = brand_render.New()
		brand:SetIndex(i)
		brand:SetUiConfig(render_ui_cfg, true)
		brand:SetAnchorPoint(0.5, 0.5)
		view:addChild(brand:GetView(), 99)

		local angle = (90 + 360 / brand_num * (i - 1)) % 360
		local x_rate = 1.8
		local y_rate = 1
		local end_x, end_y = center_pos.x + r * math.cos(math.rad(angle)) * x_rate, center_pos.y + r * math.sin(math.rad(angle)) * y_rate
		brand:SetPosition(center_pos.x, center_pos.y)
		brand:SetMoveStartPos(center_pos.x, center_pos.y)
		brand:SetMoveEndPos(end_x, end_y)
		brand:SetTurnEndCallback(function()
			ItemData.Instance:SetDaley(false)
		end)
		brands[i] = brand
	end

	local turn_left_txt = RichTextUtil.ParseRichText(nil, "", 20, nil, center_pos.x, center_pos.y - 130, 250, 28)
	XUI.RichTextSetCenter(turn_left_txt)
	-- turn_left_txt:setVisible(false)
	view:addChild(turn_left_txt, 300)

	-- 点击提示文字图片
	local tip_img = XUI.CreateImageView(w / 2, h / 2 - 20, ResPath.GetActivityBrilliant("bg_200"), true)
	tip_img:addChild(XUI.CreateImageView(165, 50, ResPath.GetActivityBrilliant("word_click_brand"), true), 1, 1)
	view:addChild(tip_img, 1)
	tip_img:setVisible(false)

	-- 重置牌组
	local reset_button = XUI.CreateButton(w / 2, h / 2 - 170, nil, nil, false, ResPath.GetCommon("btn_118"), "", nil, true)
	reset_button:setTitleFontName(COMMON_CONSTS.FONT)
	reset_button:setTitleFontSize(20)
	reset_button:setTitleText(Language.CrossServer.ResetBrand)
	view:addChild(reset_button, 10)
	reset_button:setVisible(false)

	local brands_obj = {
		view = view,
		brands = brands,
		start_brand = start_brand,
		reset_button = reset_button,
		turn_left_txt = turn_left_txt,

		GetView = function(obj)
			return obj.view
		end,
		ShowStartBrand = function(obj)
			obj.start_brand:SetVisible(true)
			-- turn_left_txt:setVisible(true)
			for k, v in pairs(obj.brands) do
				v:SetPosition(center_pos.x, center_pos.y)
				v:SetVisible(false)
			end
			tip_img:setVisible(false)
		end,
		DealBrand = function(obj, action, callback)
			for k, v in pairs(obj.brands) do
				v:SetVisible(true)
				if not v:DealBrand(action) then
					return
				end
			end
			obj.start_brand:SetVisible(false)
			-- turn_left_txt:setVisible(false)
			if action then
				tip_img:setScale(0)
				tip_img:setVisible(true)
				tip_img:runAction(cc.Sequence:create(cc.EaseBackOut:create(cc.ScaleTo:create(0.6, 1)), cc.CallFunc:create(function()
					tip_img:setScale(1)
					if callback then
						callback()
					end
				end)))
			else
				tip_img:setVisible(true)
				if callback then
					callback()
				end
			end
		end,
		PackUpBrand = function(obj, action, callback)
			for k, v in pairs(obj.brands) do
				v:SetVisible(true)
				-- v:TurnToClose()
				if not v:PackUp(action) then
					return
				end
			end
			obj.reset_button:setVisible(false)
			if action then
				tip_img:setVisible(true)
				tip_img:runAction(cc.Sequence:create(cc.EaseExponentialOut:create(cc.ScaleTo:create(0.6, 0)), cc.CallFunc:create(function()
					tip_img:setVisible(false)
					-- obj.start_brand:SetVisible(true)
					if callback then
						callback()
					end
				end)))
			else
				tip_img:setVisible(false)
				-- obj.start_brand:SetVisible(true)
				if callback then
					callback()
				end
			end
		end,
		GetBrand = function(obj, index)
			return obj.brands[index]
		end,
		FlushAllBrands = function(obj)
			for k, v in pairs(obj.brands) do
				v:Flush()
			end
		end,
		ReadyAllBrands = function(obj, data_list)
			for k, v in pairs(obj.brands) do
				v:ReadyBrand(data_list and data_list[k])
			end
		end,
		GetStartBrand = function(obj)
			return obj.start_brand
		end,
		SetClickEvent = function(obj, func)
			for k, v in pairs(obj.brands) do
				v:AddClickEventListener(func, false)
			end
		end,
		TurnOneBrand = function(obj, index, data)
			local brand = obj.brands[index]
			if nil ~= brand then
				brand:TurnToOpen(data)
			else
			end
		end,
		TurnCloseAllBrand = function(obj, data_list)
		    for k, v in pairs(obj.brands) do
				v:TurnToClose(data_list and data_list[k])
			end
		end,
		Clear = function(obj)
			for k, v in pairs(obj.brands) do
				v:DeleteMe()
			end
			obj.brands = {}
		end,
	}

	return brands_obj
end

function ActFlipCardView:AddActCommonClickEventListener()
	XUI.AddClickEventListener(self.node_t_list.btn_tips.node, BindTool.Bind(self.view.OnClickActTipHandler, self.view))
end

function ActFlipCardView:RefreshView(param_list)
	self.brand_group:FlushAllBrands()
	self:FlushBrand()
	self:FlushRecord()
	self:OpenBrand()
end

function ActFlipCardView:OpenBrand()
	local has_open = false
	for k, v in pairs(self.brand_group.brands) do
		local data = ActivityBrilliantData.Instance:GetBrandData(v:GetIndex())
		if data and data.item_data.item_id > 0 then
			v:TurnToOpen(data)
			has_open = true
		end
	end
	return has_open
end

function ActFlipCardView:FlushRecord()
	local record_list = ActivityBrilliantData.Instance:GetTurnRecordList() or {}
	local end_index = #record_list
	local data = {}
	local item = nil
	for i = 0, 999 do
		item = record_list[end_index - i]
		if item then
			data[#data + 1] = item
		else
			break
		end
	end
	self.record_list_view:SetDataList(data)
end

function ActFlipCardView:OnFlushTopView(beg_time, end_time, desc)
    local beg_time_t = os.date("*t", beg_time)
    local end_time_t = os.date("*t", end_time)
    local str_time = string.format(Language.ActivityBrilliant.AboutTime, beg_time_t.month, beg_time_t.day, beg_time_t.hour, beg_time_t.min)
	local str_time_2 = string.format(Language.ActivityBrilliant.AboutTime, end_time_t.month, end_time_t.day, end_time_t.hour, end_time_t.min)
	RichTextUtil.ParseRichText(self.node_t_list.rich_act_open_time.node, str_time .. "-" .. str_time_2, 22, COLOR3B.GREEN)
	RichTextUtil.ParseRichText(self.node_t_list.rich_act_desc.node, desc[1] or "")
	self.node_t_list.btn_tips.node:setVisible(desc[2] ~= nil)
end

function ActFlipCardView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(end_time - now_time)
	RichTextUtil.ParseRichText(self.node_t_list.rich_act_left_time.node, str, 22, COLOR3B.GREEN)
end

function ActFlipCardView:ItemConfigCallback()
    self.brand_group:FlushAllBrands()
end
