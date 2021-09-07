require("game/welfare/welfare_sign_in_view")
-- require("game/welfare/welfare_online_reward_view")
require("game/welfare/welfare_find_view")
-- require("game/welfare/welfare_offline_exp_view")
require("game/welfare/welfare_exchange_view")
require("game/welfare/welfare_happy_tree_view")
require("game/welfare/welfare_level_reward_view")

WelfareView = WelfareView or BaseClass(BaseView)

function WelfareView:__init()
	self.ui_config = {"uis/views/welfare","WelfareView"}
	self.play_audio = true
	self:SetMaskBg()
	self.toggle_list = {}
	self.view_list = {}
	self.def_index = TabIndex.welfare_sign
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

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	self.red_point_list = {}
	self.is_open_server_sign = nil
	self.tab_sign = nil
	self.tab_exchange = nil
	self.tab_level_reward = nil
	self.toggle_list = {}
	self.view_list = {}
	self.now_view = nil
end

function WelfareView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	--签到
	local sign_content = self:FindObj("SingIn")
	sign_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.sign_in_view = SignInView.New(obj)
		-- self.sign_in_view:ChangeSignIndex()
		-- self.sign_in_view:Flush()
	end)

	--等级豪礼
	local level_reward_content = self:FindObj("LevelReward")
	level_reward_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.level_reward_view = LevelRewardView.New(obj)
		self.level_reward_view:Flush()
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

	--欢乐果树
	local happytree_content = self:FindObj("HappyTree")
	happytree_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.happy_tree_view = HappyTreeView.New(obj, self)
		self.happy_tree_view:Flush()
		self.happy_tree_view:SetHappyTreeExchangeRedPoint()
	end)
	--红点
	self.red_point_list = {
		["Sign"] = self:FindVariable("SignRedPoint"),
		-- ["OnlineReward"] = self:FindVariable("OnlineRewardRedPoint"),
		["FindReward"] = self:FindVariable("FindRewardRedPoint"),
		["HappyTree"] = self:FindVariable("HappyTreeRedPoint"),
		["LevelReward"] = self:FindVariable("LevelRewardRedPoint"),
	}

	self.view_list = {
		[TabIndex.welfare_sign] = self.sign_in_view,
		[TabIndex.welfare_level_reward] = self.level_reward_view,
	}

	self.is_open_server_sign = self:FindVariable("IsOpenServerSign")
	self.tab_sign = self:FindObj("TabSign")
	self.tab_sign.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.welfare_sign))

	self.tab_exchange = self:FindObj("TabExchange")
	self.tab_level_reward = self:FindObj("TabLevelReward")
	self.tab_level_reward.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.welfare_level_reward))

	self.toggle_list = {
		[TabIndex.welfare_sign] = self.tab_sign.toggle,
		[TabIndex.welfare_level_reward] = self.tab_level_reward.toggle,
	}

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))
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

function WelfareView:CloseCallBack()

end

function WelfareView:ToggleChange(index, isOn)
	if ison then
		self:ChangeToIndex(index)
	end
end

function WelfareView:ShowIndexCallBack(index)
	self.now_view = self.view_list[index]
	self.toggle_list[index].isOn = true
	self:Flush()
end

function WelfareView:OpenCallBack()
	self:SetRedPoint()
	-- if self.tab_sign.toggle.isOn and self.sign_in_view then
	-- 	self.sign_in_view:ChangeSignIndex()
	-- end

	if self.tab_exchange ~= nil then
		self.tab_exchange:SetActive(not IS_AUDIT_VERSION)
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
	self:Close()
end

function WelfareView:OnFlush(param_t)
	if self.tab_exchange ~= nil then
		self.tab_exchange:SetActive(not IS_AUDIT_VERSION)
	end
	
	if WelfareData.Instance:GetIsOpenServerSign() then
		self.is_open_server_sign:SetValue(Language.Common.OpenServerSign)
	end
	for k, v in pairs(param_t) do
		if k == "sign_in" and self.sign_in_view and self.tab_sign.toggle.isOn then
			self.sign_in_view:Flush()
		end
	end
end