local CommonFunc = require("game/tips/tips_common_func")
TipsPropView = TipsPropView or BaseClass(BaseView)

function TipsPropView:__init()
	self.ui_config = {"uis/views/tips/proptips_prefab", "PropTip"}
	self.view_layer = UiLayer.Pop

	self.buttons = {}
	self.button_label = Language.Tip.ButtonLabel
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_handle = {}
	self.get_way_list = {}
	self.close_call_back = nil
	self.index = nil -- 魔器特殊处理
	self.is_magic_weapon = false
	self.play_audio = true
end

function TipsPropView:LoadCallBack()
	self:ListenEvent("CloseButton",
		BindTool.Bind(self.CloseTips, self))
	self:ListenEvent("OnClickWay1",
		BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2",
		BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3",
		BindTool.Bind(self.OnClickWay, self, 3))

	-- self.quality_img = self:FindObj("Quality_BG")
	self.price_icon = self:FindObj("SaleIcon")
	self.cell = ItemCell.New()
	self.cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.title_icon_name = self:FindVariable("TitleIconName")
	self.use_level = self:FindVariable("UseLevel")
	self.prop_describe = self:FindVariable("Describe")
	self.price_text = self:FindVariable("Price")
	self.sale_info_content = self:FindVariable("SaleInfo")

	self.limit_day = self:FindVariable("LimitDay")
	self.limit_hour = self:FindVariable("LimitHour")
	self.limit_min = self:FindVariable("LimitMin")
	self.limit_sec = self:FindVariable("LimitSec")
	self.show_time_limit = self:FindVariable("ShowTimeLimit")
	self.show_day_limit = self:FindVariable("ShowDayLimit")
	self.show_storge_score = self:FindVariable("ShowStorgeScore")
	self.storge_score = self:FindVariable("StorgeScore")
	self.show_zhanli = self:FindVariable("ShowZhanLi")
	self.zhanli_text = self:FindVariable("ZhanLiText")

	self.show_ways = self:FindVariable("ShowTexts")
	self.show_icons = self:FindVariable("ShowIcons")
	self.tab_images = self:FindVariable("tab_images")
	self.text_way_list = {
		{is_show = self:FindVariable("ShowText1"), name = self:FindVariable("Text1")},
		{is_show = self:FindVariable("ShowText2"), name = self:FindVariable("Text2")},
		{is_show = self:FindVariable("ShowText3"), name = self:FindVariable("Text3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1"), text = self:FindVariable("IconText1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2"), text = self:FindVariable("IconText2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3"), text = self:FindVariable("IconText3")},
	}

	for i=1, 4 do
		local btn = self:FindObj("Button"..i)
		local text = btn:FindObj("Text")
		self.buttons[i] = {btn = btn, text = text}
	end
end

function TipsPropView:__delete()
	self.buttons = {}
	self.data = nil
	self.from_view = nil
	self.handle_param_t = {}
	self.button_label = nil
	CommonFunc.DeleteMe()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function TipsPropView:ReleaseCallBack()
	if self.cell ~= nil then
		self.cell:DeleteMe()
		self.cell = nil
	end

	-- 清理变量和对象
	self.price_icon = nil
	self.scroller_rect = nil
	self.title_icon_name = nil
	self.use_level = nil
	self.prop_describe = nil
	self.price_text = nil
	self.sale_info_content = nil
	self.limit_day = nil
	self.limit_hour = nil
	self.limit_min = nil
	self.limit_sec = nil
	self.show_time_limit = nil
	self.show_day_limit = nil
	self.show_storge_score = nil
	self.storge_score = nil
	self.show_ways = nil
	self.show_icons = nil
	self.tab_images = nil
	self.text_way_list = nil
	self.icon_list = nil
	self.show_zhanli = nil
	self.zhanli_text = nil
	self.buttons = {}
end

function TipsPropView:CloseTips()
	self:Close()
end

function TipsPropView:CloseCallBack()
	if self.close_call_back ~= nil then
		if self.is_magic_weapon then
			self.close_call_back(self.index)
		else
			self.close_call_back()
		end
	end
	self.close_call_back = nil

	if self.time_count ~= nil then
		CountDown.Instance:RemoveCountDown(self.time_count)
		self.time_count = nil
	end

	for _, v in pairs(self.button_handle) do
		v:Dispose()
	end
	self.button_handle = {}

	self.get_way_list = {}
end

function TipsPropView:OpenCallBack()
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
end

function TipsPropView:OnClickWay(index)
	if index == nil or self.get_way_list[index] == nil then return end
	ViewManager.Instance:CloseAllViewExceptViewName(ViewName.TipsPropView)

	local list = Split(self.get_way_list[index], "#")
	if list[1] == ViewName.Compose then	-- 合成面板
		local cfg = ComposeData.Instance:GetComposeItem(self.data.item_id)
		local index = TabIndex.compose_stone

		if cfg ~= nil then
			if 2 == cfg.type then
				index = TabIndex.compose_jinjie
			elseif 3 == cfg.type then
				index = TabIndex.compose_other
			end
			ComposeData.Instance:SetToProductId(cfg.stuff_id_1)
		end
		ViewManager.Instance:Open(list[1], index, "all", self.data)

	elseif nil ~= list[2] and list[1] == ViewName.ActivityDetail then -- 如果是活动面板
		local act_id = tonumber(list[2])
		local act_info = ActivityData.Instance:GetActivityInfoById(act_id)
		if nil ~= next(act_info) then
			ActivityCtrl.Instance:ShowDetailView(act_id)
		end
	else
		-- ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)
		-- local tab_index = list[2] and TabIndex[list[2]] or 0
		-- ViewManager.Instance:Open(list[1], tab_index, "all", self.data)
		local tab_index = TabIndex[list[2]]
		if tonumber(list[2]) then
			tab_index = tonumber(list[2])
		end
		ViewManager.Instance:Open(list[1], tab_index, "all", self.data)
	end

	self:Close()
	-- ViewManager.Instance:CloseAllViewExceptViewName(list[1])
end

-- 根据不同情况，显示和隐藏按钮
local function showHandlerBtn(self)
	if self.from_view == nil then
		return
	end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	local handler_types = CommonFunc.GetOperationState(self.from_view, self.data, item_cfg, big_type)
	for k ,v in pairs(self.buttons) do
		local handler_type = handler_types[k]
		local tx = self.button_label[handler_type]
		if tx ~= nil then
			tx = self.data.btn_text or tx
			v.btn:SetActive(true)
			v.text.text.text = tx
			if self.button_handle[k] ~= nil then
				self.button_handle[k]:Dispose()
			end
			self.button_handle[k] = self:ListenEvent("Button"..k,
				BindTool.Bind(self.OnClickHandle, self, handler_type))
		else
			v.btn:SetActive(false)
		end
	end
end

function TipsPropView:OnClickHandle(handler_type)
	if self.data == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	if not CommonFunc.DoClickHandler(self.data,item_cfg,handler_type,self.from_view,self.handle_param_t) then
		return
	end

	--魔器特殊处理
	if item_cfg.use_type == 41 then
		self.index = self.data.id
		self.is_magic_weapon = true
	end

	self:Close()
end

--data = {item_id=100....} 如果背包有的话最好把背包的物品传过来
function TipsPropView:SetData(data, from_view, param_t, close_call_back)
	if not data then
		return
	end
	if type(data) == "string" then
		self.data = CommonStruct.ItemDataWrapper()
		self.data.item_id = data
	else
		self.data = data
	end
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self:Open()
	self.from_view = from_view or TipsFormDef.FROM_NORMAL
	self.handle_param_t = param_t or {}
	self:Flush()
end

function TipsPropView:OnFlush()
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	-- local bundle,sprite = ResPath.GetQualityBgIcon(item_cfg.color)
	-- self.quality_img.image:LoadSprite(bundle,sprite)
	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.title_icon_name:SetValue(name_str)
	self.cell:SetData(self.data)
	self.cell:SetInteractable(false)
	local bundle, asset = ResPath.GetTipsImageByIndex(item_cfg.color)
	self.tab_images:SetAsset(bundle, asset)

	local prof = PlayerData.Instance:GetRoleBaseProf()
	local description = item_cfg.description
	if big_type == GameEnum.ITEM_BIGTYPE_GIF and (not description or description == "") then
		if item_cfg.need_gold and item_cfg.need_gold > 0 then
			description = string.format(Language.Tip.GlodGiftTip, item_cfg.need_gold)
		elseif item_cfg.gift_type and item_cfg.gift_type == 3 then
			description = Language.Tip.FixGiftTip
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = string.format(Language.Tip.SelectGiftTip, item_cfg.rand_num)
			end
		else
			description = Language.Tip.FixGiftTip
			if item_cfg.rand_num and item_cfg.rand_num ~= "" and item_cfg.rand_num > 0 then
				description = string.format(Language.Tip.RandomGiftTip, item_cfg.rand_num)
			end
		end
		for k, v in pairs(ItemData.Instance:GetGiftItemList(self.data.item_id)) do
			local item_cfg2 = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg2 and (item_cfg2.limit_prof == prof or item_cfg2.limit_prof == 5) then
				local color_name_str = "<color="..ITEM_TIP_CONTEXT_COLOR[item_cfg2.color]..">"..item_cfg2.name.."</color>"
				if description ~= "" then
					description = description.."\n"..color_name_str.."X"..v.num
				else
					description = description..color_name_str.."X"..v.num
				end
			end
		end
	end
	self.prop_describe:SetValue(description)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	-- local level_befor = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level % 100) or 100
	-- local level_behind = math.floor(item_cfg.limit_level % 100) ~= 0 and math.floor(item_cfg.limit_level / 100) or math.floor(item_cfg.limit_level / 100) - 1
	-- local level_zhuan = string.format(Language.Common.Zhuan_Level, level_befor, level_behind) --level_befor.."级【"..level_behind.."转】"
	local level_zhuan = PlayerData.GetLevelString(item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, level_zhuan)

	self.use_level:SetValue(level_str)
	if(self.data.price == nil) then
		self.data.price = item_cfg.sellprice
	end
	if self.data.price ~= nil then
		self.price_text:SetValue(self.data.price)
	else
		self.sale_info_content:SetValue(false)
	end
	showHandlerBtn(self)
	self:SetWay()
	-- self.scroller_rect.normalizedPosition = Vector2(0, 1)

	if self.data.invalid_time and self.data.invalid_time > 0 then
		self:SetPropLimitTime(self.data.invalid_time)
	elseif item_cfg.time_length and item_cfg.time_length > 0 then
		local time_limit = tonumber(item_cfg.time_length)
		local is_show_day_limit = time_limit - 24 * 3600 > 0
		if not is_show_day_limit then
			local left_hour = math.floor(time_limit / 3600)
			local left_min = math.floor((time_limit - left_hour * 3600) / 60)
			local left_sec = math.floor(time_limit - left_hour * 3600 - left_min * 60)
			self.limit_hour:SetValue(left_hour)
			self.limit_min:SetValue(left_min)
			self.limit_sec:SetValue(left_sec)
		else
			self.limit_day:SetValue(math.ceil(time_limit / 24 / 3600))
		end
	end
	self.show_time_limit:SetValue(item_cfg.time_length and item_cfg.time_length > 0 or false)
	self.show_storge_score:SetValue((self.data.item_id == 27789 or self.data.item_id == 27790 or self.data.item_id == 27791) and true or false)
	if item_cfg.guild_storage_score and item_cfg.guild_storage_score > 0 then
		self.storge_score:SetValue(item_cfg.guild_storage_score)
	end
	local show_power = item_cfg.power ~= nil and item_cfg.power ~= 0
	self.show_zhanli:SetValue(show_power)
	if show_power then
		self.zhanli_text:SetValue(tonumber(item_cfg.power))
	end
end

-- 设置限时物品倒计时
function TipsPropView:SetPropLimitTime(invalid_time)
	if not invalid_time then return end

	local diff_time = invalid_time - TimeCtrl.Instance:GetServerTime()

	local is_show_day_limit = diff_time - 24 * 3600 > 0
	self.show_day_limit:SetValue(is_show_day_limit)
	self.limit_day:SetValue(math.ceil(diff_time / 24 / 3600))

	if not self.time_count and diff_time > 0 and not is_show_day_limit then
		local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.time_count ~= nil then
					CountDown.Instance:RemoveCountDown(self.time_count)
					self.time_count = nil
				end
				self:Close()
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)
			self.limit_hour:SetValue(left_hour)
			self.limit_min:SetValue(left_min)
			self.limit_sec:SetValue(left_sec)
		end

		diff_time_func(0, diff_time)
		if self.time_count ~= nil then
			CountDown.Instance:RemoveCountDown(self.time_count)
			self.time_count = nil
		end
		self.time_count = CountDown.Instance:AddCountDown(
			diff_time, 0.5, diff_time_func)
	end
end

function TipsPropView:SetWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	for k, v in ipairs(self.icon_list) do
		v.is_show:SetValue(false)
		self.text_way_list[k].is_show:SetValue(false)
	end

	if item_cfg.get_msg == nil and item_cfg.get_way == nil then
		return 
	end

	if next(way) and (nil == item_cfg.get_msg or "" == item_cfg.get_msg) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.show_icons:SetValue(true)
				self.show_ways:SetValue(false)
				if tonumber(v) == 0 then
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUI("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					asset = asset .. "_text"
					self.icon_list[k].text:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUI(getway_cfg_k.icon)
					if asset and asset ~= "" then
						self.icon_list[k].icon:SetAsset(bundle, asset)
						asset = asset .. "_text"
						self.icon_list[k].text:SetAsset(bundle, asset)
					end

					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			else
				self.show_ways:SetValue(true)
				self.show_icons:SetValue(false)
				if tonumber(v) == 0 then
					self.text_way_list[k].is_show:SetValue(true)
					self.text_way_list[k].name:SetValue(Language.Common.Shop)
					self.get_way_list[k] = "ShopView"
				elseif getway_cfg_k then
					self.text_way_list[k].is_show:SetValue(true)
					if getway_cfg_k.button_name ~= "" and getway_cfg_k.button_name ~= nil then
						self.text_way_list[k].name:SetValue(getway_cfg_k.button_name)
					else
						self.text_way_list[k].name:SetValue(getway_cfg_k.discription)
					end
					self.get_way_list[k] = getway_cfg_k.open_panel
				end
			end
		end
	elseif nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg then
		self.show_ways:SetValue(true)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		self.show_icons:SetValue(false)
		for k, v in pairs(msg) do
			self.text_way_list[k].is_show:SetValue(true)
			self.text_way_list[k].name:SetValue(v)
		end
	end
end