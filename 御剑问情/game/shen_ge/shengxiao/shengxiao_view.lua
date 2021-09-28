ShengXiaoView = ShengXiaoView or BaseClass(BaseView)

local DISCOUNT_SHENXIAO_PRASE = 14
function ShengXiaoView:__init()
	self.ui_config = {"uis/views/shengxiaoview_prefab", "ShengXiaoView"}
	self.play_audio = true
	self.full_screen = true
	self.discount_close_time = 0
	self.discount_index = 0
end

function ShengXiaoView:__delete()

end

function ShengXiaoView:LoadCallBack()
	ShengXiaoCtrl.Instance:MainuiOpenCreate() --向服务端获取天象信息
	self.bind_gold = self:FindVariable("BindGold")
	self.gold = self:FindVariable("Gold")

	self:ListenEvent("OpenUplevel", BindTool.Bind(self.OpenUplevel, self))
	self:ListenEvent("OpenEquip", BindTool.Bind(self.OpenEquip, self))
	self:ListenEvent("OpenPiece", BindTool.Bind(self.OpenPiece, self))
	self:ListenEvent("OpenSpirit", BindTool.Bind(self.OpenSpirit, self))
	self:ListenEvent("OpenStarSoul", BindTool.Bind(self.OpenStarSoul, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("HandleAddGold", BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OnClickBiPin", BindTool.Bind(self.OnClickBiPin, self))

	self.uplevel_toggle = self:FindObj("TabUplevel").toggle
	self.equip_toggle = self:FindObj("TabEquip").toggle
	self.piece_toggle = self:FindObj("TabPiece").toggle
	self.spirit_toggle = self:FindObj("TabSpirit").toggle
	self.starsoul_toggle = self:FindObj("TabStarSoul").toggle
	self.show_bipin_icon = self:FindVariable("ShowBiPingIcon")
	self.discount_time = self:FindVariable("BiPinTime")

	-- 生肖升级
	self.shengxiao_uplevel_content = self:FindObj("UplevelContent")
	-- 生肖装备
	self.shengxiao_equip_content = self:FindObj("EquipContent")
	-- 生肖星途
	self.shengxiao_piece_content = self:FindObj("PieceContent")
	--生肖星灵
	self.shengxiao_spirit_content = self:FindObj("SpiritContent")
	--生肖星魂
	self.shengxiao_starsoul_content = self:FindObj("StarSoulContent")

	self.red_point_list = {
		[RemindName.ShengXiao_Equip] = self:FindVariable("ShowEquipRemind"),
		[RemindName.ShengXiao_Uplevel] = self:FindVariable("ShowUplevelRemind"),
		[RemindName.ShengXiao_Piece] = self:FindVariable("ShowPieceRemind"),
		[RemindName.ShengXiao_Spirit] = self:FindVariable("ShowSpiritRemind"),
		[RemindName.ShengXiao_StarSoul] = self:FindVariable("ShowStarSoulRemind"),
	}

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	RemindManager.Instance:Fire(RemindName.ShengXiao_Equip)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Piece)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Spirit)
	RemindManager.Instance:Fire(RemindName.ShengXiao_StarSoul)
end

function ShengXiaoView:ReleaseCallBack()
	if self.shengxiao_uplevel_view then
		self.shengxiao_uplevel_view:DeleteMe()
		self.shengxiao_uplevel_view = nil
	end

	if self.shengxiao_equip_view then
		self.shengxiao_equip_view:DeleteMe()
		self.shengxiao_equip_view = nil
	end

	if self.shengxiao_piece_view then
		self.shengxiao_piece_view:DeleteMe()
		self.shengxiao_piece_view = nil
	end

	if self.shengxiao_spirit_view then
		self.shengxiao_spirit_view:DeleteMe()
		self.shengxiao_spirit_view = nil
	end

	if self.shengxiao_starsoul_view then
		self.shengxiao_starsoul_view:DeleteMe()
		self.shengxiao_starsoul_view = nil
	end
	self.uplevel_toggle = nil
	self.equip_toggle = nil
	self.piece_toggle = nil
	self.spirit_toggle = nil
	self.starsoul_toggle = nil
	self.bind_gold = nil
	self.gold = nil
	self.show_bipin_icon = nil
	self.discount_time = nil

	self.red_point_list = {}


	self.shengxiao_uplevel_content = nil
	self.shengxiao_equip_content = nil
	self.shengxiao_piece_content = nil
	self.shengxiao_spirit_content = nil
	self.shengxiao_starsoul_content = nil

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end
end

function ShengXiaoView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	-- 一折抢购活动
	local discount_info, index = DisCountData.Instance:GetDiscountInfoByType(DISCOUNT_SHENXIAO_PRASE)
	self.discount_index = index
	self.show_bipin_icon:SetValue(discount_info ~= nil)
	self.discount_close_time = discount_info and discount_info.close_timestamp or 0
	if discount_info and self.discount_timer == nil then
		self:UpdateTimer()
		self.discount_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateTimer, self), 1)
	end
end

function ShengXiaoView:UpdateTimer()
	local time = self.discount_close_time - TimeCtrl.Instance:GetServerTime()
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
		self.show_bipin_icon:SetValue(false)
	else
		if time > 3600 then
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 1))
		else
			self.discount_time:SetValue(TimeUtil.FormatSecond(time, 2))
		end
	end
end

function ShengXiaoView:CloseCallBack()
	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	self.data_listen = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.shengxiao_equip_view ~= nil then
		self.shengxiao_equip_view:CloseCallBack()
	end
	if self.discount_timer then
		GlobalTimerQuest:CancelQuest(self.discount_timer)
		self.discount_timer = nil
	end
end

function ShengXiaoView:OnClickBiPin()
	ViewManager.Instance:Open(ViewName.DisCount, nil, "index", {self.discount_index})
end

function ShengXiaoView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function ShengXiaoView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ShengXiaoView:OpenUplevel()
	self:ShowIndex(TabIndex.shengxiao_uplevel)
	if nil ~= self.shengxiao_uplevel_view then
		self.shengxiao_uplevel_view:FlushAll()
	end
end

function ShengXiaoView:OpenEquip()
	self:ShowIndex(TabIndex.shengxiao_equip)
	if nil ~= self.shengxiao_equip_view then
		self.shengxiao_equip_view:FlushAll()
	end
end

function ShengXiaoView:OpenPiece()
	self:ShowIndex(TabIndex.shengxiao_piece)
	if nil ~= self.shengxiao_piece_view then
		self.shengxiao_piece_view:FlushAll()
	end
end

function ShengXiaoView:OpenSpirit()
	self:ShowIndex(TabIndex.shengxiao_spirit)
	if nil ~= self.shengxiao_spirit_view then
		self.shengxiao_spirit_view:FlushAll()
	end
end

function ShengXiaoView:OpenStarSoul()
	self:ShowIndex(TabIndex.shengxiao_starsoul)
	if nil ~= self.shengxiao_starsoul_view then
		self.shengxiao_starsoul_view:FlushAll()
	end
end


function ShengXiaoView:AsyncLoadView(index)
	if index == TabIndex.shengxiao_uplevel and not self.shengxiao_uplevel_view then
		UtilU3d.PrefabLoad("uis/views/shengxiaoview_prefab", "UplevelContent",
			function(obj)
				obj.transform:SetParent(self.shengxiao_uplevel_content.transform, false)
				obj = U3DObject(obj)
				self.shengxiao_uplevel_view = ShengXiaoUpLevelView.New(obj)
				if self.uplevel_toggle.isOn then
					self.shengxiao_uplevel_view:FlushAll()
				end
			end)
	end
	if index == TabIndex.shengxiao_equip and not self.shengxiao_equip_view then
		UtilU3d.PrefabLoad("uis/views/shengxiaoview_prefab", "EquipContent",
			function(obj)
				obj.transform:SetParent(self.shengxiao_equip_content.transform, false)
				obj = U3DObject(obj)
				self.shengxiao_equip_view = ShengXiaoEquipView.New(obj)
				if self.equip_toggle.isOn then
					self.shengxiao_equip_view:FlushAll()
				end
			end)
	end
	if index == TabIndex.shengxiao_piece and not self.shengxiao_piece_view then
		UtilU3d.PrefabLoad("uis/views/shengxiaoview_prefab", "PieceContent",
			function(obj)
				obj.transform:SetParent(self.shengxiao_piece_content.transform, false)
				obj = U3DObject(obj)
				self.shengxiao_piece_view = ShengXiaoPieceView.New(obj)
				if self.piece_toggle.isOn then
					self.shengxiao_piece_view:FlushAll()
				end
			end)
	end
	if index == TabIndex.shengxiao_spirit and not self.shengxiao_spirit_view then
		UtilU3d.PrefabLoad("uis/views/shengxiaoview_prefab", "SpiritContent",
		function(obj)
			obj.transform:SetParent(self.shengxiao_spirit_content.transform, false)
			obj = U3DObject(obj)
			self.shengxiao_spirit_view = ShengXiaoSpiritView.New(obj)
			if self.spirit_toggle.isOn then
				self.shengxiao_spirit_view:OpenCallBack()
				self.shengxiao_spirit_view:FlushAll()
			end
		end)
	end
	if index == TabIndex.shengxiao_starsoul and not self.shengxiao_starsoul_view then
		UtilU3d.PrefabLoad("uis/views/shengxiaoview_prefab", "StarSoulContent",
			function(obj)
				obj.transform:SetParent(self.shengxiao_starsoul_content.transform, false)
				obj = U3DObject(obj)
				self.shengxiao_starsoul_view = ShengXiaoStarSoulView.New(obj)
				if self.starsoul_toggle.isOn then
					self.shengxiao_starsoul_view:OpenCallBack()
					self.shengxiao_starsoul_view:FlushAll()
				end
			end)
	end

end
function ShengXiaoView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
	self.uplevel_toggle.isOn = false
	self.equip_toggle.isOn = false
	self.piece_toggle.isOn = false
	self.spirit_toggle.isOn = false
	self.starsoul_toggle.isOn = false
	if index == TabIndex.shengxiao_uplevel then
		self.uplevel_toggle.isOn = true
		if self.shengxiao_equip_view then
			self.shengxiao_equip_view:FlushAll()
		end
		if not ShengXiaoData.HasOpenShenxiaoUplevel then
			ShengXiaoData.HasOpenShenxiaoUplevel = true
			RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)
		end
	elseif index == TabIndex.shengxiao_equip then
		self.equip_toggle.isOn = true
		if self.shengxiao_equip_view then
			self.shengxiao_equip_view:FlushAll()
		end
	elseif index == TabIndex.shengxiao_piece then
		self.piece_toggle.isOn = true
		if self.shengxiao_piece_view then
			self.shengxiao_piece_view:FlushAll()
		end
	elseif index == TabIndex.shengxiao_spirit then
			self.spirit_toggle.isOn = true
		if self.shengxiao_spirit_view then
			self.shengxiao_spirit_view:FlushAll()
		end
	elseif index == TabIndex.shengxiao_starsoul then
			self.starsoul_toggle.isOn = true
		if self.shengxiao_starsoul_view then
			self.shengxiao_starsoul_view:FlushAll()
		end
	end
end

function ShengXiaoView:OnClickClose()
	self:Close()
end

function ShengXiaoView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShengXiaoView:OnFlush(param_list)
	if self.shengxiao_uplevel_view and self.uplevel_toggle.isOn then
		self.shengxiao_uplevel_view:FlushAll()
	end

	if self.shengxiao_equip_view and self.equip_toggle.isOn then
		self.shengxiao_equip_view:FlushAll()
	end
	if self.shengxiao_piece_view and self.piece_toggle.isOn then
		self.shengxiao_piece_view:FlushAll()
	end
	if self.shengxiao_spirit_view and self.spirit_toggle.isOn then
		self.shengxiao_spirit_view:FlushAll()
	end
	if self.shengxiao_starsoul_view and self.starsoul_toggle.isOn then
		self.shengxiao_starsoul_view:FlushAll()
	end

	for k, v in pairs(param_list) do
		if k == "all" and v.item_id then
			local seq = ShengXiaoData.Instance:GetShengXiaoIndexByCostItem(v.item_id)
			if seq > 0 then
				ShengXiaoData.Instance:SetUplevelIndex(seq)
			end
		elseif k == "shengxiao_equip_change" and self.equip_toggle.isOn then
			if self.shengxiao_equip_view then
				self.shengxiao_equip_view:AfterSuccessUp()
			end
		elseif k == "shengxiao_star_soul" and self.starsoul_toggle.isOn then
			if self.shengxiao_starsoul_view then
				self.shengxiao_starsoul_view:AfterSuccessUp()
				self.shengxiao_starsoul_view:FlushAll()
			end
		elseif k == "shengxiao_all_info" and self.uplevel_toggle.isOn then
			if ShengXiaoData.Instance:GetUpgradeZodiac() >= 0 then
				self.shengxiao_uplevel_view:FlushEffect()
			end
		end
	end
end