require("game/compose/compose_content_view")
require("game/compose/compose_equip_view")

ComposeView = ComposeView or BaseClass(BaseView)

function ComposeView:__init()
	self.ui_config = {"uis/views/composeview_prefab","ComposeView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self.item_change = BindTool.Bind(self.ItemChange, self)
end

function ComposeView:__delete()

end

function ComposeView:ReleaseCallBack()
	if self.compose_content_view then
		self.compose_content_view:DeleteMe()
		self.compose_content_view = nil
	end

	if self.compose_equip_view then
		self.compose_equip_view:DeleteMe()
		self.compose_equip_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	-- 清理变量和对象
	self.baoshi_bar = nil
	self.qita_bar = nil
	self.jinjie_bar = nil
	self.equip_bar = nil
	self.red_point_list = nil
	self.diamond = nil
	self.bind_gold = nil
	self.compose_content = nil
	self.equip_content = nil

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end
end

function ComposeView:LoadCallBack()
	self:ListenEvent("close_view",BindTool.Bind(self.BackOnClick,self))
	self:ListenEvent("chongzhi",BindTool.Bind(self.ChongZhi,self))
	self:ListenEvent("baoshi_click", BindTool.Bind(self.BaoshiOnClick, self))
	self:ListenEvent("forge_click", BindTool.Bind(self.JinjieOnClick, self))
	self:ListenEvent("other_click", BindTool.Bind(self.QitaOnClick, self))
	self:ListenEvent("equip_click", BindTool.Bind(self.EquipOnClick, self))

	self.baoshi_bar = self:FindObj("baoshi_bar")
	self.qita_bar = self:FindObj("qita_bar")
	self.jinjie_bar = self:FindObj("jinjie_bar")
	self.equip_bar = self:FindObj("equip_bar")

	-- 子面板
	self.compose_content = self:FindObj("compose_content_view")
	self.equip_content = self:FindObj("equip_content")

	self.red_point_list = {
		[RemindName.ComposeStone] = self:FindVariable("ShowStoneRedPoint"),
		[RemindName.ComposeOther] = self:FindVariable("ShowOtherRedPoint"),
		[RemindName.ComposeJinjie] = self:FindVariable("ShowJinjieRedPoint"),
	}
	self.diamond = self:FindVariable("diamond")
	self.bind_gold = self:FindVariable("bind_gold")
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

-- 玩家钻石改变时
function ComposeView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.diamond:SetValue(CommonDataManager.ConverMoney(value))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function ComposeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ComposeView:OpenCallBack()
	if ShengXiaoCtrl.Instance:GetBagView():IsOpen() then
		ShengXiaoCtrl.Instance:GetBagView():Close()
	end
	if self.compose_content_view then
		self.compose_content_view:FlushBuyNum()
	end

	--监听物品变化
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change)

	RemindManager.Instance:Fire(RemindName.Compose, true)
end

function ComposeView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
end

function ComposeView:ItemChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, old_data)
	if put_reason == PUT_REASON_TYPE.PUT_REASON_RED_COLOR_EQUIPMENT_COMPOSE then
		--装备合成
		self:Flush("equip_compose", {true})
	else
		self:Flush(nil, {change_item_id})
	end
end

--关闭面板
function ComposeView:BackOnClick()
	ViewManager.Instance:Close(ViewName.Compose)
end

--充值
function ComposeView:ChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ComposeView:BaoshiOnClick()
	self:ShowIndex(TabIndex.compose_stone)
end

function ComposeView:QitaOnClick()
	self:ShowIndex(TabIndex.compose_other)
end

function ComposeView:JinjieOnClick()
	self:ShowIndex(TabIndex.compose_jinjie)
end

function ComposeView:EquipOnClick()
	self:ShowIndex(TabIndex.compose_equip)
end

function ComposeView:AsyncLoadView(index)
	if index == TabIndex.compose_equip and not self.compose_equip_view then
		UtilU3d.PrefabLoad("uis/views/composeview_prefab", "EquipContent",
			function(obj)
				obj.transform:SetParent(self.equip_content.transform, false)
				obj = U3DObject(obj)
				self.compose_equip_view = ComposeEquipView.New(obj)
				self.compose_equip_view:InitView()
			end)

	elseif (index == TabIndex.compose_stone
		or index == TabIndex.compose_other
		or index == TabIndex.compose_jinjie)
		and not self.compose_content_view then

		UtilU3d.PrefabLoad("uis/views/composeview_prefab", "ComposeContentView",
			function(obj)
				obj.transform:SetParent(self.compose_content.transform, false)
				obj = U3DObject(obj)
				self.compose_content_view = ComposeContentView.New(obj)
				if self.show_index ~= TabIndex.compose_equip then
					self:ShowIndexCallBack(self.show_index)
				end
			end)
	end
end

function ComposeView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)

	if index == TabIndex.compose_jinjie then
		self.jinjie_bar.toggle.isOn = true
		if self.compose_content_view then
			self.compose_content_view:OnJinJie()
		end
	elseif index == TabIndex.compose_other then
		self.qita_bar.toggle.isOn = true
		if self.compose_content_view then
			self.compose_content_view:OnQiTa()
		end
	elseif index == TabIndex.compose_stone then
		self.baoshi_bar.toggle.isOn = true
		if self.compose_content_view then
			self.compose_content_view:OnBaoShi()
		end
	elseif index == TabIndex.compose_equip then
		self.equip_bar.toggle.isOn = true
		if self.compose_equip_view then
			self.compose_equip_view:InitView()
		end
	else
		self:ShowIndex(TabIndex.compose_stone)
	end
end

function ComposeView:OnFlush(param_t)
	if param_t.equip_compose then
		if self.compose_equip_view then
			self.compose_equip_view:FlushView(param_t.equip_compose[1])
		end
	else
		if self.compose_content_view then
			local item_id = param_t["all"][1]
			self.compose_content_view:ItemDataChangeCallback(item_id)
		end
	end
end