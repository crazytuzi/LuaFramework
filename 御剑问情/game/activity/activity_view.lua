require("game/activity/activity_daily_view")
require("game/activity/activity_battle_view")
require("game/activity/activity_kuafu_battle_view")

ActivityView = ActivityView or BaseClass(BaseView)

function ActivityView:__init()
	self.full_screen = true								-- 是否是全屏界面
	self.ui_config = {"uis/views/activityview_prefab","ActivityView"}
	self.play_audio = true
end

function ActivityView:__delete()

end

function ActivityView:ReleaseCallBack()
	if self.daily_view then
		self.daily_view:DeleteMe()
		self.daily_view = nil
	end

	if self.battle_view then
		self.battle_view:DeleteMe()
		self.battle_view = nil
	end

	if self.kuafu_battle_view then
		self.kuafu_battle_view:DeleteMe()
		self.kuafu_battle_view = nil
	end

	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.tab_daily = nil
	self.tab_battle = nil
	self.tab_kuafu_battle = nil
	self.wing_start_up = nil
end

function ActivityView:LoadCallBack()
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("bind_gold")

	self.daily_view = ActivityDailyView.New(self:FindObj("ActivityPanel"))
	self.battle_view = ActivityBattleView.New(self:FindObj("BattlePanel"))
	self.kuafu_battle_view = ActivityKuaFuBattleView.New(self:FindObj("KuaFuBattlePanel"))
	self.tab_daily = self:FindObj("TabDaily")
	self.tab_battle = self:FindObj("TabBattle")
	self.tab_kuafu_battle = self:FindObj("TabKuaFuBattle")

	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("ClickRecharge",
		BindTool.Bind(self.ClickRecharge, self))

	self.tab_daily.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.activity_daily))
	self.tab_battle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.activity_battle))
	self.tab_kuafu_battle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.activity_kuafu_battle))
end

function ActivityView:OnToggleChange(index, ison)
	if index == self.show_index then
		return
	end
	self.show_index = index
	if ison then
		if index == TabIndex.activity_daily then
			self.daily_view:FlushDaily()
		elseif index == TabIndex.activity_battle then
			self.battle_view:FlushBattle()
		elseif index == TabIndex.activity_kuafu_battle then
			self.kuafu_battle_view:FlushKuaFuBattle()
		end
	end
end

function ActivityView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ActivityView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")

	if self.tab_daily.toggle.isOn then
		self.daily_view:FlushDaily()
	elseif self.tab_battle.toggle.isOn then
		self.battle_view:FlushBattle()
	elseif self.tab_kuafu_battle.toggle.isOn then
		self.kuafu_battle_view:FlushKuaFuBattle()
	end

	self:Flush()
end

function ActivityView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function ActivityView:PlayerDataChangeCallback(attr_name, value, old_value)
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
end

function ActivityView:ShowIndexCallBack(index)
	if index == TabIndex.activity_daily then
		self.tab_daily.toggle.isOn = true
	elseif index == TabIndex.activity_battle then
		self.tab_battle.toggle.isOn = true
	elseif index == TabIndex.activity_kuafu_battle then
		self.tab_kuafu_battle.toggle.isOn = true
	end
end

function ActivityView:HandleClose()
	ViewManager.Instance:Close(ViewName.Activity)
end

function ActivityView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "daily" and self.tab_daily.toggle.isOn then
			self.daily_view:FlushDaily()
		elseif k == "battle" and self.tab_battle.toggle.isOn then
			self.battle_view:FlushBattle()
		elseif k == "kuafu_battle" and self.tab_kuafu_battle.toggle.isOn then
			self.kuafu_battle_view:FlushKuaFuBattle()
		end
	end
end