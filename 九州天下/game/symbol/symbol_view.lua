require("game/symbol/symbol_info_view")
require("game/symbol/symbol_fuzhou_view")
-- require("game/symbol/symbol_yuanhun_view")
require("game/symbol/symbol_mishi_view")
require("game/symbol/symbol_upgrade_view")

SymbolView = SymbolView or BaseClass(BaseView)

function SymbolView:__init()
	self.ui_config = {"uis/views/symbol","SymbolView"}
	self:SetMaskBg()
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
end

function SymbolView:__delete()
end

function SymbolView:ReleaseCallBack()
	self.gold = nil
	self.bind_gold = nil
	for k,v in pairs(self.view_cfg) do
		if v.view then
			v.view:DeleteMe()
		end
	end
	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end
	self.view_cfg = nil
	self.red_point_list = nil
end

function SymbolView:LoadCallBack()
	self.view_cfg = {
	[TabIndex.symbol_intro] = {
		index_t = {TabIndex.symbol_intro},
		toggle = self:FindObj("ToggleInfo"),
		content = self:FindObj("InfoContent") ,
		event = "OpenInfo",
		view = nil,
		view_name = SymbolInfoView,
		prefab = {"uis/views/symbol_prefab", "InfoContent"},
		fun_open = "symbol_intro",
		flush_param_t = {},
		},
	[TabIndex.symbol_fuzhou] = {
		toggle = self:FindObj("ToggleFuzhou"),
		content = self:FindObj("FuzhouContent") ,
		event = "OpenFuzhou",
		view = nil,
		view_name = SymbolFuzhouView,
		prefab = {"uis/views/symbol_prefab", "FuzhouContent"},
		fun_open = "symbol_fuzhou",
		flush_param_t = {["texture_upgrade_result"] = true},
		},
	-- [TabIndex.symbol_yuanhun] = {
	-- 	toggle = self:FindObj("ToggleYuanhun"),
	-- 	content = self:FindObj("YuanhunContent") ,
	-- 	event = "OpenYuanhun",
	-- 	view = nil,
	-- 	view_name = SymbolYuanhunView,
	-- 	prefab = {"uis/views/symbol_prefab", "YuanhunContent"},
	-- 	fun_open = "symbol_yuanhun",
	-- 	flush_param_t = {["xi_lian_result"] = true},
	-- 	},
	[TabIndex.symbol_mishi] = {
		toggle = self:FindObj("ToggleMishi"),
		content = self:FindObj("MishiContent") ,
		event = "OpenMishi",
		view = nil,
		view_name = SymbolMishiView,
		prefab = {"uis/views/symbol_prefab", "MishiContent"},
		fun_open = "symbol_mishi",
		flush_param_t = {["chou_reward"] = true},
		},
	[TabIndex.symbol_upgrade] = {
		toggle = self:FindObj("ToggleUpgrade"),
		content = self:FindObj("UpgradeContent") ,
		event = "OpenUpgrade",
		view = nil,
		view_name = SymbolUpgradeView,
		prefab = {"uis/views/symbol_prefab", "UpgradeContent"},
		fun_open = "symbol_upgrade",
		flush_param_t = {["heart_upgrade_result"] = true},
		},
	}

	self.red_point_list = {
		[RemindName.SymbolYuanSu] = self:FindVariable("ShowInfoRed"),
		[RemindName.SymbolYuanHuo] = self:FindVariable("ShowFuzhouRed"),
		-- [RemindName.SymbolYuanHun] = self:FindVariable("ShowYuanhunRed"),
		[RemindName.SymbolYuanYong] = self:FindVariable("ShowMishiRed"),
		[RemindName.SymbolYuanShi] = self:FindVariable("ShowUpgradeRed"),
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	for k,v in pairs(self.view_cfg) do
		self:ListenEvent(v.event,
		BindTool.Bind(self.OnClickTab, self, k))
	end

	-- 获取变量
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
end

function SymbolView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function SymbolView:OpenCallBack()
	SymbolCtrl.Instance:SendElementHeartReq(ELEMENT_HEART_REQ_TYPE.ALL_INFO)
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()
end

function SymbolView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	local show_index = self.show_index or 0
	if self.view_cfg[show_index] and self.view_cfg[show_index].view then
		self.view_cfg[show_index].view:CloseCallBack()
	end
end

function SymbolView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		local count = CommonDataManager.ConverMoney(value)
		if attr_name == "bind_gold" then
			self.bind_gold:SetValue(count)
		else
			self.gold:SetValue(count)
		end

		local view_cfg_info = self.view_cfg[TabIndex.symbol_mishi]
		if view_cfg_info.view then
			view_cfg_info.view:FlushBtnText()
		end
	end
end

function SymbolView:InitTab()
	local open_fun_data = OpenFunData.Instance
	for _, v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open) == true)
	end
end

function SymbolView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击标签按钮
function SymbolView:OnClickTab(index)
	self:ShowIndex(index)
end

function SymbolView:InitAllToggleIsOn()
	for _, v in pairs(self.view_cfg) do
		v.toggle.toggle.isOn = false
	end
end

local old_index = 0
function SymbolView:ShowIndexCallBack(index)
	index = index or 0

	if old_index ~= index then
		if self.view_cfg[old_index] and self.view_cfg[old_index].view then
			self.view_cfg[old_index].view:CloseCallBack()
		end
	end

	local view_cfg_info = self.view_cfg[index]
	if nil == view_cfg_info then
		self:ShowIndex(TabIndex.symbol_intro)
		return
	end

	old_index = index

	self:InitAllToggleIsOn()

	self:AsyncLoadView(index, view_cfg_info.prefab[1], view_cfg_info.prefab[2], self.async_load_call_back)

	view_cfg_info.toggle.toggle.isOn = true
	if view_cfg_info.view then
		view_cfg_info.view:OpenCallBack()
	end
end

function SymbolView:AsyncLoadCallBack(index, obj)
	local view_cfg_info = self.view_cfg[index]
	if view_cfg_info then
		obj.transform:SetParent(view_cfg_info.content.transform, false)
		obj = U3DObject(obj)
		view_cfg_info.view = view_cfg_info.view_name.New(obj)
		
		if self.show_index == index then
			view_cfg_info.view:OpenCallBack()
		end
	end
end

function SymbolView:OnFlush(param_t)
	local index = self.show_index or 0
	--根据index取得对应的界面配置
	local view_cfg_info = self.view_cfg[index]
	if nil == view_cfg_info then
		return
	end

	local view = view_cfg_info.view
	if nil == view then
		return
	end

	local flush_param_t = view_cfg_info.flush_param_t

	for k, v in pairs(param_t) do
		if k == "all" or flush_param_t[k] then
			view:Flush(k, v)
		end
	end
end
