local CommonFunc = require("game/tips/tips_common_func")
TipsPropView = TipsPropView or BaseClass(BaseView)

function TipsPropView:__init()
	self.ui_config = {"uis/views/tips/proptips", "PropTip"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
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
	self.qualityline = self:FindVariable("QualityLine") 
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
	self.prop_type = self:FindVariable("PropType")

	self.show_ways = self:FindVariable("ShowTexts")
	self.show_icons = self:FindVariable("ShowIcons")

	self.text_way_list = {
		{is_show = self:FindVariable("ShowText1"), name = self:FindVariable("Text1")},
		{is_show = self:FindVariable("ShowText2"), name = self:FindVariable("Text2")},
		{is_show = self:FindVariable("ShowText3"), name = self:FindVariable("Text3")}
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
	}

	for i=1, 3 do
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
	self.button_handle = {}
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
	self.text_way_list = nil
	self.icon_list = nil
	self.show_zhanli = nil
	self.zhanli_text = nil
	self.prop_type = nil
	self.buttons = {}
	self.qualityline = nil

	
	
	self.button_handle = {}

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

	self.get_way_list = {}

	if next(self.button_handle) then
		for k,v in pairs(self.button_handle) do
			v:Dispose()
		end
	end
	
end

function TipsPropView:OpenCallBack()
	self.scroller_rect.normalizedPosition = Vector2(0, 1)
end

function TipsPropView:OnClickWay(index)
	if index == nil or self.get_way_list[index] == nil then return end
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
	else
		ViewManager.Instance:OpenByCfg(self.get_way_list[index], self.data)
	end

	ViewManager.Instance:CloseAllViewExceptViewName(list[1], list[2])
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
			if item_cfg and item_cfg.gift_type == GameEnum.ITEM_GIFT_TYPE.WEAPON then
				tx = Language.Common.ItemJieFeng
			end
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
	local bundle,sprite = ResPath.GetQualityLineBgIcon(item_cfg.color)
	self.qualityline:SetAsset(bundle, sprite)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.title_icon_name:SetValue(name_str)
	self.cell:SetData(self.data)
	self.cell:SetInteractable(false)

	local description =	ItemData.Instance:GetItemDescription(self.data.item_id)
	self.prop_describe:SetValue(description)

	local vo = GameVoManager.Instance:GetMainRoleVo()
	local level_zhuan = string.format(Language.Common.Zhuan_Level, item_cfg.limit_level)
	local level_str = vo.level >= item_cfg.limit_level and level_zhuan or string.format(Language.Mount.ShowRedStr, item_cfg.limit_level)

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
	-- self.show_storge_score:SetValue((self.data.item_id == 27789 or self.data.item_id == 27790 or self.data.item_id == 27791) and true or false)
	if item_cfg.guild_storage_score and item_cfg.guild_storage_score > 0 then
		self.storge_score:SetValue(item_cfg.guild_storage_score)
	end
	local show_power = item_cfg.power ~= nil and item_cfg.power ~= 0
	self.show_zhanli:SetValue(show_power)
	if show_power then
		self.zhanli_text:SetValue(tonumber(item_cfg.power))
	end

	local cfg = GuildCtrl.Instance.guild_data:GetStorageFixedItemCfg()
	if self.data.item_id == cfg.item_id and self.from_view == TipsFormDef.FROM_STORGE_ON_GUILD_STORGE then
		self.show_storge_score:SetValue(true)
		self.storge_score:SetValue(cfg.need_score)
	else
		self.show_storge_score:SetValue(false)
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
	if next(way) and (nil == item_cfg.get_msg or "" == item_cfg.get_msg) then
		for k, v in pairs(way) do
			local getway_cfg_k = getway_cfg[tonumber(way[k])]
			if (nil == getway_cfg_k and tonumber(v) == 0) or (getway_cfg_k and getway_cfg_k.icon) then
				self.show_icons:SetValue(true)
				self.show_ways:SetValue(false)
				if tonumber(v) == 0 then
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUIButton("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUIButton(getway_cfg_k.icon)
					self.icon_list[k].icon:SetAsset(bundle, asset)
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
