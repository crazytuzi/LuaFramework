ExchangeView.SHOW_EXCHANGE_RED =
{
	9, 		--兑换类型
}

ArenaActivityView = ArenaActivityView or BaseClass(BaseView)

function ArenaActivityView:__init()
	self.full_screen = true								-- 是否是全屏界面
	self.ui_config = {"uis/views/arena_prefab","ArenaActivityView"}
	self.play_audio = true
	self.def_index = TabIndex.arena_view
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ArenaActivityView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function ArenaActivityView:ReleaseCallBack()
	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.show_arena_red_point = nil
	self.show_arena_reward_red_point = nil
	self.show_arena_tupo_red_point = nil
	self.tab_arena = nil
	self.tab_arena_reward = nil
	self.tab_arena_tupo = nil
	self.tab_arena_exchange = nil
	self.show_xianshi = nil
	self.top_text_path = nil
	self.red_point_list = {}

	if self.arena_view then
		self.arena_view:DeleteMe()
		self.arena_view = nil
	end

	if self.arena_reward_view then
		self.arena_reward_view:DeleteMe()
		self.arena_reward_view = nil
	end

	if self.arena_tupo_view then
		self.arena_tupo_view:DeleteMe()
		self.arena_tupo_view = nil
	end

	if self.arena_exchange_view then
		self.arena_exchange_view:DeleteMe()
		self.arena_exchange_view = nil
	end
	self.arena_view_obj = nil
	self.arena_reward_view_obj = nil
	self.arena_tupo_view_obj = nil
	self.arena_exchange_view_obj = nil
	GlobalEventSystem:UnBind(self.open_trigger_handle)
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.first_role_stand = nil

	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.ArenaActivityView)
	end
end

function ArenaActivityView:LoadCallBack()
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("bind_gold")
	self.top_text_path = self:FindVariable("top_text_path")

	self.show_arena_red_point = self:FindVariable("ShowArenaPoint")
	self.show_arena_reward_red_point = self:FindVariable("ShowRewardPoint")
	self.show_arena_tupo_red_point = self:FindVariable("ShowTupoPoint")

	self.tab_arena = self:FindObj("TabArena")
	self.tab_arena_reward = self:FindObj("TabArenaReward")
	self.tab_arena_tupo = self:FindObj("TabArenaTupo")
	self.tab_arena_exchange = self:FindObj("TabArenaExchange")

	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("ClickRecharge",
		BindTool.Bind(self.ClickRecharge, self))
	self:ListenEvent("OnClickArena",
		BindTool.Bind(self.OnToggleChange, self, TabIndex.arena_view))
	self:ListenEvent("OnClickArenaReward",
		BindTool.Bind(self.OnToggleChange, self, TabIndex.arena_reward_view))
	self:ListenEvent("OnClickArenaTupo",
		BindTool.Bind(self.OnToggleChange, self, TabIndex.arena_tupo_view))
	self:ListenEvent("OnClickArenaExchange",
		BindTool.Bind(self.OnToggleChange, self, TabIndex.arena_exchange_view))
	self:ListenEvent("OnClickJump",
		BindTool.Bind(self.JumpXingYao, self))

	self.arena_view_obj = self:FindObj("ArenaView")
	self.arena_reward_view_obj = self:FindObj("ArenaRewardView")
	self.arena_tupo_view_obj = self:FindObj("ArenaTupoView")
	self.arena_exchange_view_obj = self:FindObj("ArenaExchangeView")

	self.show_xianshi = self:FindVariable("ShowXianShi")

	self.top_text_path:SetValue(CommonDataManager.ConverMoney(ExchangeData.Instance:GetScoreList()[EXCHANGE_PRICE_TYPE.GUANGHUI]))
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.ArenaActivityView, BindTool.Bind(self.GetUiCallBack, self))
	self.red_point_list = {
		[RemindName.ArenaExchange] = self:FindVariable("ShowExchangePoint"),
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function ArenaActivityView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ArenaActivityView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	self.tab_arena:SetActive(open_fun_data:CheckIsHide("arena_view"))
end

function ArenaActivityView:OnToggleChange(index)
	if index == self.show_index then
		return
	end
	self:ShowIndex(index)
end

function ArenaActivityView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ArenaActivityView:OpenCallBack()
	--开始引导
	FunctionGuide.Instance:TriggerGuideByName("arena")

	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")

	ClickOnceRemindList[RemindName.ArenaChallange] = 0
	self:Flush()
	self:InitTab()
	self:InitTabXianShi()
end

function ArenaActivityView:CloseCallBack()
	FunctionGuide.Instance:DelWaitGuideListByName("arena")

	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ArenaActivityView:InitTabXianShi()
	self.show_xianshi:SetValue(ArenaData.Instance:GetArenaExchangeRemind() > 0)
end

function ArenaActivityView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.gold:SetValue(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.bind_gold:SetValue(count)
	end
	if attr_name == "guanghui" then
		local count = vo.guanghui
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. Language.Common.Wan
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. Language.Common.Yi
		end
		self.top_text_path:SetValue(count)
	end
end

function ArenaActivityView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
	if index == TabIndex.arena_view then
		self.tab_arena.toggle.isOn = true
		if self.arena_view then
			self.arena_view:OpenCallBack()
			self.arena_view:FlushArenaView()
			self.arena_view:StartBubbleCountDown()
		end
	elseif index == TabIndex.arena_reward_view then
		self.tab_arena_reward.toggle.isOn = true
		if self.arena_reward_view then
			self.arena_reward_view:OpenCallBack()
		end
	elseif index == TabIndex.arena_tupo_view then
		self.tab_arena_tupo.toggle.isOn = true
		if self.arena_tupo_view then
			self.arena_tupo_view:OpenCallBack()
		end
	elseif index == TabIndex.arena_exchange_view then
		RemindManager.Instance:SetRemindToday(RemindName.ArenaExchange)
		self.tab_arena_exchange.toggle.isOn = true
		if self.arena_exchange_view then
			self.arena_exchange_view:OpenCallBack()
		end
	end
end

function ArenaActivityView:JumpXingYao()
	self:ShowIndex(TabIndex.arena_view)
end

function ArenaActivityView:AsyncLoadView(index)
	if index == TabIndex.arena_view and not self.arena_view then
		UtilU3d.PrefabLoad("uis/views/arena_prefab", "ArenaView",
			function(obj)
				obj.transform:SetParent(self.arena_view_obj.transform, false)
				obj = U3DObject(obj)
				self.arena_view = ArenaView.New(obj)
				self.arena_view:OpenCallBack()
				self.arena_view:FlushArenaView()
				self.first_role_stand = self.arena_view:GetFirstRoleStand()
			end
		)
	elseif index == TabIndex.arena_reward_view and not self.arena_reward_view then
		UtilU3d.PrefabLoad("uis/views/arena_prefab", "ArenaRewardView",
			function(obj)
				obj.transform:SetParent(self.arena_reward_view_obj.transform, false)
				obj = U3DObject(obj)
				self.arena_reward_view = ArenaRewardView.New(obj)
				self.arena_reward_view:OpenCallBack()
			end
		)
	elseif index == TabIndex.arena_tupo_view and not self.arena_tupo_view then
		UtilU3d.PrefabLoad("uis/views/arena_prefab", "ArenaTupoView",
			function(obj)
				obj.transform:SetParent(self.arena_tupo_view_obj.transform, false)
				obj = U3DObject(obj)
				self.arena_tupo_view = ArenaTupoView.New(obj)
				self.arena_tupo_view:OpenCallBack()
			end
		)
	elseif index == TabIndex.arena_exchange_view and not self.arena_exchange_view then
		UtilU3d.PrefabLoad("uis/views/arena_prefab", "ArenaExchange",
			function(obj)
				obj.transform:SetParent(self.arena_exchange_view_obj.transform, false)
				obj = U3DObject(obj)
				self.arena_exchange_view = ArenaExchangeView.New(obj)
				self.arena_exchange_view:OpenCallBack()
			end
		)
	end
end

function ArenaActivityView:HandleClose()
	ViewManager.Instance:Close(ViewName.ArenaActivityView)
end

function ArenaActivityView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	for k,v in pairs(param_t) do
		if k == "arena" then
			if self.arena_view then
				self.arena_view:FlushArenaView()
			end
		elseif k == "xianshi_tab" then
			self:InitTabXianShi()
		else
			if cur_index == TabIndex.arena_view then
				if self.arena_view then
					self.arena_view:FlushArenaView()
				end
			elseif cur_index == TabIndex.arena_reward_view then
				if self.arena_reward_view then
					self.arena_reward_view:Flush()
				end
			elseif cur_index == TabIndex.arena_tupo_view then
				if self.arena_tupo_view then
					self.arena_tupo_view:Flush()
				end
			elseif cur_index == TabIndex.tab_arena_exchange then
				if self.arena_exchange_view then
					self.arena_exchange_view:Flush()
				end
			end
		end
	end
	local is_show = ArenaData.Instance:GetRemindNum()

	self.show_arena_red_point:SetValue(is_show)
	self.show_arena_reward_red_point:SetValue(ArenaData.Instance:GetRewardRemindNum())
	self.show_arena_tupo_red_point:SetValue(ArenaData.Instance:GetArenaTupoRemind() > 0)
end

function ArenaActivityView:OnChangeToggle(index)
	if index == TabIndex.arena_view then
		self.tab_arena.toggle.isOn = true
		if self.arena_view then
			self.arena_view:OpenCallBack()
		end
	end
end

function ArenaActivityView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end

	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.arena_view then
			if self.tab_arena.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.arena_view)
				return self.tab_arena, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
	return nil
end