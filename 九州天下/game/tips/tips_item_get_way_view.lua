TipsItemGetWayView = TipsItemGetWayView or BaseClass(BaseView)

function TipsItemGetWayView:__init()
	self.ui_config = {"uis/views/tips/itemgetwaytips", "ItemGetWayTips"}
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
	self.get_way_list = {}
	self.play_audio = true
end

function TipsItemGetWayView:ReleaseCallBack()
	self.get_way_list = {}
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.item_name = nil
	self.item_icon = nil
	self.color = nil
	self.show_ways = nil
	self.show_icons = nil
	self.text_way_list = nil
	self.icon_list = nil
end

function TipsItemGetWayView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("OnClickWay1", BindTool.Bind(self.OnClickWay, self, 1))
	self:ListenEvent("OnClickWay2", BindTool.Bind(self.OnClickWay, self, 2))
	self:ListenEvent("OnClickWay3", BindTool.Bind(self.OnClickWay, self, 3))
	self:ListenEvent("OnClickIcon4", BindTool.Bind(self.OnClickWay, self, 4))

	self.item_name = self:FindVariable("ItemName")
	self.item_icon = self:FindVariable("ItemIcon")
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.color = self:FindVariable("Color")
	self.show_ways = self:FindVariable("ShowTextWays")
	self.show_icons = self:FindVariable("ShowIconWays")
	self.text_way_list = {
		{is_show = self:FindVariable("ShowWay1"), name = self:FindVariable("WayName1")},
		{is_show = self:FindVariable("ShowWay2"), name = self:FindVariable("WayName2")},
		{is_show = self:FindVariable("ShowWay3"), name = self:FindVariable("WayName3")},
	}
	self.icon_list = {
		{is_show = self:FindVariable("ShowIcon1"), icon = self:FindVariable("Icon1")},
		{is_show = self:FindVariable("ShowIcon2"), icon = self:FindVariable("Icon2")},
		{is_show = self:FindVariable("ShowIcon3"), icon = self:FindVariable("Icon3")},
		{is_show = self:FindVariable("ShowIcon4"), icon = self:FindVariable("Icon4")},
	}
end

function TipsItemGetWayView:SetData(item_id, close_call_back)
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
	self.item_id = item_id
end

function TipsItemGetWayView:OpenCallBack()
	local cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if cfg then
		self.item_name:SetValue(cfg.name)
		self.color:SetValue(Language.Common.QualityRGBColor[cfg.color])

		local data = {}
		data.item_id = self.item_id
		local func = function() if ViewManager.Instance:IsOpen(ViewName.Shop) then self:Close() end end
		data.close_call_back = func
		self.item_cell:SetData(data)
		self:ShowWay()
	end
end

function TipsItemGetWayView:CloseView()
	self:Close()
end

function TipsItemGetWayView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.get_way_list = {}
	self.item_id = 0
end

function TipsItemGetWayView:OnClickWay(index)
	if nil == self.get_way_list[index] then return end
	local data = {item_id = self.item_id}
	local list = Split(self.get_way_list[index], "#")
	if list[1] == ViewName.Compose then	-- 合成面板
		local cfg = ComposeData.Instance:GetComposeItem(self.item_id)
		local index = TabIndex.compose_stone
		if cfg ~= nil then
			if 2 == cfg.type then
				index = TabIndex.compose_jinjie
			elseif 3 == cfg.type then
				index = TabIndex.compose_other
			end
			ComposeData.Instance:SetToProductId(cfg.stuff_id_1)
		end
		ViewManager.Instance:Open(list[1], index, "all", data)
	else
		ViewManager.Instance:OpenByCfg(self.get_way_list[index], data)
	end
	if self.item_id == ResPath.CurrencyToIconId.shengwang then
		PlayerCtrl.Instance:FlushPlayerView("bag_recycle")
	end
	ViewManager.Instance:CloseAllViewExceptViewName(list[1], list[2])
end

function TipsItemGetWayView:ShowWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local getway_cfg = ConfigManager.Instance:GetAutoConfig("getway_auto").get_way
	local get_way = item_cfg.get_way or ""
	local way = Split(get_way, ",")
	if next(way) then
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
				if v == 0 then
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
	elseif nil == next(way) and (nil ~= item_cfg.get_msg and "" ~= item_cfg.get_msg) then
		self.show_ways:SetValue(true)
		self.show_icons:SetValue(false)
		local get_msg = item_cfg.get_msg or ""
		local msg = Split(get_msg, ",")
		for k, v in pairs(msg) do
			self.text_way_list[k].is_show:SetValue(true)
			self.text_way_list[k].name:SetValue(v)
		end
	end
end
