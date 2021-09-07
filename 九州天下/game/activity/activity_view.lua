require("game/activity/activity_daily_view")
require("game/activity/activity_battle_view")
require("game/activity/activity_kuafu_battle_view")

ActivityView = ActivityView or BaseClass(BaseView)

function ActivityView:__init()
	self.ui_config = {"uis/views/activityview","ActivityView"}
	self.play_audio = true
	self:SetMaskBg()
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

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	-- 清理变量和对象
	self.show_activity_red_point = nil
	self.tab_daily = nil
	self.tab_battle = nil
	self.tab_kuafu_battle = nil
	self.wing_start_up = nil
	self.activity_battle_red = nil

	if self.activity_call_back then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_call_back)
		self.activity_call_back = nil
	end	
end

function ActivityView:LoadCallBack()
	self.show_activity_red_point = self:FindVariable("ShowActivityRedPoint")
	self.activity_battle_red = self:FindVariable("ActivityBattleRed")

	self.daily_view = ActivityDailyView.New(self:FindObj("ActivityPanel"))
	self.battle_view = ActivityBattleView.New(self:FindObj("BattlePanel"))
	self.kuafu_battle_view = ActivityKuaFuBattleView.New(self:FindObj("KuaFuBattlePanel"))
	self.tab_daily = self:FindObj("TabDaily")
	self.tab_battle = self:FindObj("TabBattle")
	self.tab_kuafu_battle = self:FindObj("TabKuaFuBattle")

	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("ClickRecharge", BindTool.Bind(self.ClickRecharge, self))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))

	self.tab_daily.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.activity_daily))
	self.tab_battle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.activity_battle))
	self.tab_kuafu_battle.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self, TabIndex.activity_kuafu_battle))

	self.activity_call_back = BindTool.Bind(self.ActivityCallBackBattleRed, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_call_back)
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
	if self.tab_daily.toggle.isOn then
		self.daily_view:FlushDaily()
	elseif self.tab_battle.toggle.isOn then
		self.battle_view:FlushBattle()
	elseif self.tab_kuafu_battle.toggle.isOn then
		self.kuafu_battle_view:FlushKuaFuBattle()
	end

	self:Flush()
	self:ActivityCallBackBattleRed()
end

function ActivityView:CloseCallBack()

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

function ActivityView:ActivityCallBackBattleRed()
	local isShowRed = ActivityData.Instance:ActivityCallBackBattleRed() == 1
	local isDailyRed = ActivityData.Instance:ActivityCallDailyRed() == 1

	if self.activity_battle_red then
		self.activity_battle_red:SetValue(isShowRed)
	end
	
	if self.battle_view then
		self.battle_view:FlushBattle()
	end

	if self.show_activity_red_point then
		self.show_activity_red_point:SetValue(isDailyRed)
	end

	if self.daily_view then
		self.daily_view:FlushDaily()
	end
end