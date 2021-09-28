require("game/Littlepet/Little_pet_home_view")
require("game/Littlepet/Little_pet_feed_view")
require("game/Littlepet/Little_pet_toy_view")
require("game/Littlepet/Little_pet_shop_view")
require("game/Littlepet/Little_pet_exchange_view")

local HOME_TOGGLE = 1
local FEED_TOGGLE = 2
local TOY_TOGGLE = 3
local SHOP_TOGGLE = 4
local EXCHANGE_TOGGLE = 5

LittlePetView = LittlePetView or BaseClass(BaseView)

function LittlePetView:__init()
	self.ui_config = {"uis/views/littlepetview_prefab","LittlePetView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function LittlePetView:__delete()

end

function LittlePetView:ReleaseCallBack()
	self.gold = nil
	self.bind_gold = nil
	self.ji_fen = nil

	for k,v in pairs(self.view_cfg) do
		if v.view then
			v.view:DeleteMe()
		end
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.view_cfg = {}
	self.index_cfg = {}
	self.red_point_list = {}
	
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function LittlePetView:LoadCallBack()
	self.view_cfg = {}
	self.index_cfg = {}

	-- 获取变量
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	self.ji_fen = self:FindVariable("JiFen")

	-- 监听UI事件
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("AddGold",BindTool.Bind(self.HandleAddGold, self))
	
	self.red_point_list = {
		[RemindName.LittlePetHome] = self:FindVariable("ShowHomeRedPoint"),
		[RemindName.LittlePetFeed] = self:FindVariable("ShowFeedRedPoint"),
		[RemindName.LittlePetToy] = self:FindVariable("ShowToyRedPoint"),
		[RemindName.LittlePetShop] = self:FindVariable("ShowShopRedPoint"),
		[RemindName.LittlePetExchange] = self:FindVariable("ShowExchangeRedPoint"),
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end
	
	self:RegisterAllView()

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function LittlePetView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function LittlePetView:OpenCallBack()
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)

	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()
	self:ShowJiFen()
end

function LittlePetView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function LittlePetView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open))
	end
end

function LittlePetView:ShowJiFen()
	local ji_fen = LittlePetData.Instance:GetCurJiFenByInfo()
	ji_fen = CommonDataManager.ConverMoney(ji_fen)
	self.ji_fen:SetValue(ji_fen)
end

function LittlePetView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(vo.gold))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(vo.bind_gold))
	end
end

function LittlePetView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击标签按钮
function LittlePetView:OnClickTab(tab)
	if tab == self.cur_toggle or self.view_cfg[tab] == nil then
		return
	end
	self:ShowIndex(self.view_cfg[tab].index_t[1])
end

function LittlePetView:GetTabByIndex(index)
	return self.index_cfg[index] or HOME_TOGGLE
end

function LittlePetView:ShowIndexCallBack(index)
	local index = index or self:GetShowIndex()
	local tab = self:GetTabByIndex(index)

	if self.cur_toggle ~= tab then
		if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
			self.view_cfg[self.cur_toggle].view:CloseCallBack()
		end
	end
	if nil == self.view_cfg[tab] then return end

	self:AsyncLoadView(tab)
	local cfg = self.view_cfg[tab]
	cfg.toggle.toggle.isOn = true
	self.cur_toggle = tab
	if cfg.view then
		cfg.view:OpenCallBack()
	end
end

function LittlePetView:AsyncLoadView(tab)
	local cfg = self.view_cfg[tab]
	if nil == cfg then return end
	if cfg.view == nil then
		UtilU3d.PrefabLoad(cfg.prefab[1], cfg.prefab[2],
			function(prefab)
				prefab.transform:SetParent(cfg.content.transform, false)
				prefab = U3DObject(prefab)
				cfg.view = cfg.view_name.New(prefab)
				cfg.view:OpenCallBack()
			end)
	end
end

function LittlePetView:OnFlush(param_t)
	self:ShowJiFen()
	local cur_index = self:GetShowIndex()
	local tab = self:GetTabByIndex(cur_index)
	if nil == self.view_cfg[tab] then return end

	local cfg = self.view_cfg[tab]
	if nil == cfg then return end

	if cfg.view then
		for k,v in pairs(param_t) do
			cfg.view:Flush(k, v)
		end
	end
end

function LittlePetView:GetChouJiangReward()
	if self.cur_toggle == SHOP_TOGGLE and self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:GetChouJiangRewardByInfo()
	end
end

function LittlePetView:RegisterAllView()
	self.view_cfg = {
	[HOME_TOGGLE] = {
		index_t = {TabIndex.little_pet_home},
		toggle = self:FindObj("TabHome"),
		content = self:FindObj("HomeContent") ,
		event = "OpenHome",
		view = nil,
		view_name = LittlePetHomeView,
		prefab = {"uis/views/littlepetview_prefab", "HomeContent"},
		fun_open = "littlepet",
		},
	[FEED_TOGGLE] = {
		index_t = {TabIndex.little_pet_feed},
		toggle = self:FindObj("TabFeed"),
		content = self:FindObj("FeedContent") ,
		event = "OpenFeed",
		view = nil,
		view_name = LittlePetFeedView,
		prefab = {"uis/views/littlepetview_prefab", "FeedContent"},
		fun_open = "littlepet",
		},
	[TOY_TOGGLE] = {
		index_t = {TabIndex.little_pet_toy},
		toggle = self:FindObj("TabToy"),
		content = self:FindObj("ToyContent") ,
		event = "OpenToy",
		view = nil,
		view_name = LittlePetToyView,
		prefab = {"uis/views/littlepetview_prefab", "ToyContent"},
		fun_open = "littlepet",
		},
	[SHOP_TOGGLE] = {
		index_t = {TabIndex.little_pet_shop},
		toggle = self:FindObj("TabShop"),
		content = self:FindObj("ShopContent") ,
		event = "OpenShop",
		view = nil,
		view_name = LittlePetShopView,
		prefab = {"uis/views/littlepetview_prefab", "ShopContent"},
		fun_open = "littlepet",
		},
	[EXCHANGE_TOGGLE] = {
		index_t = {TabIndex.little_pet_exchange},
		toggle = self:FindObj("TabExchange"),
		content = self:FindObj("ExchangeContent") ,
		event = "OpenExchange",
		view = nil,
		view_name = LittlePetExchangeView,
		prefab = {"uis/views/littlepetview_prefab", "ExchangeContent"},
		fun_open = "littlepet",
		},
	}

	for k,v in pairs(self.view_cfg) do
		for k1,v1 in pairs(v.index_t) do
			self.index_cfg[v1] = k
		end
	end

	for k,v in pairs(self.view_cfg) do
		self:ListenEvent(v.event,BindTool.Bind(self.OnClickTab, self, k))
	end
end