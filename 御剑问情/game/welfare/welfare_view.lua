require("game/welfare/welfare_sign_in_view")
-- require("game/welfare/welfare_online_reward_view")
require("game/welfare/welfare_find_view")
-- require("game/welfare/welfare_offline_exp_view")
require("game/welfare/welfare_exchange_view")
require("game/welfare/welfare_happy_tree_view")
require("game/welfare/welfare_level_reward_view")
require("game/welfare/welfare_gold_turntable_view")

WelfareView = WelfareView or BaseClass(BaseView)

WelfareView.TabIndex = {
	sign = 1,
	level = 2,
	turntable = 3,
	zhaohui = 4,
	duihuan = 5,
}

function WelfareView:__init()
	self.ui_config = {"uis/views/welfare_prefab","WelfareView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

--游戏中被删除时,退出游戏时也会调用
function WelfareView:ReleaseCallBack()
	if self.sign_in_view then
		self.sign_in_view:DeleteMe()
		self.sign_in_view = nil
	end

	if self.find_view then
		self.find_view:DeleteMe()
		self.find_view = nil
	end

	if self.exchange_view then
		self.exchange_view:DeleteMe()
		self.exchange_view = nil
	end

	if self.happy_tree_view then
		self.happy_tree_view:DeleteMe()
		self.happy_tree_view = nil
	end

	if self.level_reward_view then
		self.level_reward_view:DeleteMe()
		self.level_reward_view = nil
	end

	if self.goldturn_table_content then
		self.goldturn_table_content:DeleteMe()
		self.goldturn_table_content = nil
	end

	-- 清理变量和对象
	self.red_point_list = nil
	self.tab_sign = nil
	self.tab_level = nil
	self.tab_turntable = nil
	self.page = nil
	self.tab_duihuan = nil
	self.tab_zhaohui = nil
end

function WelfareView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	--签到
	local sign_content = self:FindObj("SingIn")
	sign_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.sign_in_view = SignInView.New(obj)
		self.sign_in_view:ChangeSignIndex()
		self.sign_in_view:Flush()
	end)

	--找回
	local find_content = self:FindObj("Find")
	find_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.find_view = FindView.New(obj)
		self:FlushFind()
	end)

	--兑换
	local exchange_content = self:FindObj("Exchange")
	exchange_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.exchange_view = WelfareExchangeView.New(obj)
	end)

	--钻石转盘
	local goldturn_table_content = self:FindObj("GoldTurntableContent")
	goldturn_table_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.goldturn_table_content = GoldTurntableView.New(obj)
	end)
	--红点
	self.red_point_list = {
		["Sign"] = self:FindVariable("SignRedPoint"),
		-- ["OnlineReward"] = self:FindVariable("OnlineRewardRedPoint"),
		["FindReward"] = self:FindVariable("FindRewardRedPoint"),
		["HappyTree"] = self:FindVariable("HappyTreeRedPoint"),
		-- ["LevelReward"] = self:FindVariable("LevelRewardRedPoint"),
		["GoldTurntable"] = self:FindVariable("GoldTurntableRedPoint")
	}

	for i=1,6 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.page = self:FindVariable("page")
	self.page:SetValue(1)
	self.tab_sign = self:FindObj("TabSign")
	self.tab_level = self:FindObj("TabLevel")
	self.tab_turntable = self:FindObj("Tabturntable")
	self.tab_zhaohui = self:FindObj("TaZhaoHui")
	self.tab_duihuan = self:FindObj("TaDuiHuan")
	self.tab_sign.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.sign))
	self.tab_level.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.level))
	self.tab_turntable.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.turntable))
	self.tab_zhaohui.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.zhaohui))
	self.tab_duihuan.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, WelfareView.TabIndex.duihuan))
end

function WelfareView:SetRedPoint()
	if not self:IsLoaded() then
		return
	end
	local red_point_info_list = WelfareData.Instance:GetAllRedPoint()
	if red_point_info_list then
		for k,v in pairs(self.red_point_list) do
			local state = red_point_info_list[k] or false
			v:SetValue(state)
		end
	end
	if self.happy_tree_view then
		self.happy_tree_view:SetHappyTreeExchangeRedPoint()
	end
end

function WelfareView:OpenCallBack()
	self:SetRedPoint()
	if self.tab_sign.toggle.isOn and self.sign_in_view then
		self.sign_in_view:ChangeSignIndex()
	end
	WelfareCtrl.Instance:SendTurntableReward(Yuan_Bao_Zhuanpan_OPERATE_TYPE.SET_JC_ZhUANSHI_NUM)
end

function WelfareView:CloseCallBack()
	ViewManager.Instance:FlushView(ViewName.FuBen)
	ViewManager.Instance:FlushView(ViewName.Boss)
	ViewManager.Instance:FlushView(ViewName.YunbiaoView)
	ViewManager.Instance:FlushView(ViewName.MarryMe)

	if nil ~= self.goldturn_table_content then
		self.goldturn_table_content:CloseCallBack()
	end

	WelfareData.Instance:SetIsHideTip(false)
end

function WelfareView:ShowIndexCallBack(index)
	if index == TabIndex.welfare_sign_in then
		self.tab_sign.toggle.isOn = true
	elseif index == TabIndex.welfare_level then
		self.tab_level.toggle.isOn = true
	elseif index == TabIndex.welfare_goldturn then
		self.tab_turntable.toggle.isOn = true
		self.page:SetValue(2)
	end
end

function WelfareView:ToggleChange(index, isOn)
	if not isOn then
		return
	end

	if index == WelfareView.TabIndex.level then
		if self.level_reward_view then
			self.level_reward_view:Flush()
		end
	elseif index == WelfareView.TabIndex.turntable then
		WelfareCtrl.Instance:SendTurntableReward(Yuan_Bao_Zhuanpan_OPERATE_TYPE.SET_JC_ZhUANSHI_NUM)
	end
end

function WelfareView:FlushFind()
	if self.find_view then
		self.find_view:FlushScroller()
		self.find_view:Flush()
	end
end

function WelfareView:OnSeverDataChange()
	if not self:IsLoaded() then
		return
	end
	self:SetRedPoint()
	self:FlushFind()
	if self.happy_tree_view then
		self.happy_tree_view:Flush()
	end
	if self.level_reward_view then
		self.level_reward_view:Flush()
	end
end

function WelfareView:HandleClose()
	BossCtrl.Instance:DaBaoFlushTurn()
	BossCtrl.Instance:MikuFlushTurn()
	self:Close()
end

function WelfareView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "sign_in" and self.sign_in_view then
			self.sign_in_view:Flush()
		elseif k == "yuan_baonum" and self.goldturn_table_content then
			self.goldturn_table_content:SetYuanbaoNum(v[1],v[2])
			self:SetRedPoint()
		elseif k == "startturn" and self.goldturn_table_content then
			self.goldturn_table_content:StartTurn(v[1],2.7)
		end
	end
end

function WelfareView:OnToggleClick(i,is_click)
	self.page:SetValue(i)
end