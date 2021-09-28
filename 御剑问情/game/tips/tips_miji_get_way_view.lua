TipsMijiGetWayView = TipsMijiGetWayView or BaseClass(BaseView)

function TipsMijiGetWayView:__init()
	self.ui_config = {"uis/views/tips/mijigetwaytips_prefab", "MijiGetWayTips"}
	self.view_layer = UiLayer.Pop
	self.get_way_list = {}
	self.play_audio = true
	self.ITEM_ID = 27602  --先写死，其中一个秘籍的物品ID
end

function TipsMijiGetWayView:ReleaseCallBack()
	self.get_way_list = {}

	-- 清理变量和对象
	self.show_ways = nil
	self.show_icons = nil
	self.text_way_list = nil
	self.icon_list = nil
end

function TipsMijiGetWayView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))


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

function TipsMijiGetWayView:SetData(close_call_back)
	if close_call_back ~= nil then
		self.close_call_back = close_call_back
	end
end

function TipsMijiGetWayView:OpenCallBack()
	local cfg = ItemData.Instance:GetItemConfig(self.ITEM_ID)
	if cfg then
		self:ShowWay()
	end
end

function TipsMijiGetWayView:CloseView()
	self:Close()
end

function TipsMijiGetWayView:CloseCallBack()
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
	self.get_way_list = {}
end


function TipsMijiGetWayView:ShowWay()
	local item_cfg = ItemData.Instance:GetItemConfig(self.ITEM_ID)
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
					local bundle, asset = ResPath.GetMainUI("Icon_System_Shop")
					self.icon_list[k].icon:SetAsset(bundle, asset)
					self.get_way_list[k] = "ShopView"
				else
					self.icon_list[k].is_show:SetValue(true)
					local bundle, asset = ResPath.GetMainUI(getway_cfg_k.icon)
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