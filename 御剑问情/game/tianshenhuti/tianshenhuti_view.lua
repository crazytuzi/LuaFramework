require("game/tianshenhuti/tianshenhuti_info_view")
require("game/tianshenhuti/tianshenhuti_compose_view")
require("game/tianshenhuti/tianshenhuti_conversion_view")
require("game/tianshenhuti/tianshenhuti_box_view")
require("game/tianshenhuti/tianshenhuti_bigboss_view")
require("game/tianshenhuti/tianshenhuti_boss_view")

local INFO_TOGGLE = 1
local COMPOSE_TOGGLE = 2
local CONVERSION_TOGGLE = 3
local BOX_TOGGLE = 4
local BIG_BOSS_TOGGLE = 5
local BOSS_TOGGLE = 6
TianshenhutiView = TianshenhutiView or BaseClass(BaseView)

function TianshenhutiView:__init()
	self.ui_config = {"uis/views/tianshenhutiview_prefab","TianshenhutiView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.tianshenhuti_info
	self.cur_toggle = INFO_TOGGLE
	self.view_cfg = {}
	self.index_cfg = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function TianshenhutiView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function TianshenhutiView:ReleaseCallBack()
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
	self.view_cfg = {}
	self.index_cfg = {}
	self.red_point_list = {}
	self.show_lock = nil
	self.zhekou = nil
end

function TianshenhutiView:LoadCallBack()
	self.view_cfg = {
	[INFO_TOGGLE] = {
		index_t = {TabIndex.tianshenhuti_info},
		toggle = self:FindObj("ToggleInfo"),
		content = self:FindObj("InfoContent") ,
		event = "ClickInfo",
		view = nil,
		view_name = TianshenhutiInfoView,
		prefab = {"uis/views/tianshenhutiview_prefab", "InfoPanel"},
		fun_open = "tianshenhutiview",
		},
	[COMPOSE_TOGGLE] = {
		index_t = {TabIndex.tianshenhuti_compose},
		toggle = self:FindObj("ToggleCompose"),
		content = self:FindObj("ComposeContent") ,
		event = "ClickCompose",
		view = nil,
		view_name = TianshenhutiComposeView,
		prefab = {"uis/views/tianshenhutiview_prefab", "ComposePanel"},
		fun_open = "tianshenhutiview",
		},
	[CONVERSION_TOGGLE] = {
		index_t = {TabIndex.tianshenhuti_conversion},
		toggle = self:FindObj("ToggleConversion"),
		content = self:FindObj("ConversionContent") ,
		event = "ClickConversion",
		view = nil,
		view_name = TianshenhutiConversionView,
		prefab = {"uis/views/tianshenhutiview_prefab", "ConversionPanel"},
		fun_open = "tianshenhutiview",
		},
	[BOX_TOGGLE] = {
		index_t = {TabIndex.tianshenhuti_box},
		toggle = self:FindObj("ToggleBox"),
		content = self:FindObj("BoxContent") ,
		event = "ClickBox",
		view = nil,
		view_name = TianshenhutiBoxView,
		prefab = {"uis/views/tianshenhutiview_prefab", "BoxPanel"},
		fun_open = "tianshenhutiview",
		},
	[BIG_BOSS_TOGGLE] = {
		index_t = {TabIndex.tianshenhuti_bigboss},
		toggle = self:FindObj("ToggleBigBoss"),
		content = self:FindObj("BigBossContent") ,
		event = "ClickBigBoss",
		view = nil,
		view_name = TianshenhutiBigBossView,
		prefab = {"uis/views/tianshenhutiview_prefab", "BigBossPanel"},
		fun_open = "tianshenhutiview",
		},
	[BOSS_TOGGLE] = {
		index_t = {TabIndex.tianshenhuti_boss},
		toggle = self:FindObj("ToggleBoss"),
		content = self:FindObj("BossContent") ,
		event = "ClickBoss",
		view = nil,
		view_name = TianshenhutiBossView,
		prefab = {"uis/views/tianshenhutiview_prefab", "BossPanel"},
		fun_open = "tianshenhutiview",
		},
	}
	for k,v in pairs(self.view_cfg) do
		for k1,v1 in pairs(v.index_t) do
			self.index_cfg[v1] = k
		end
	end

	self.red_point_list = {
		[RemindName.Tianshenhuti] = self:FindVariable("InfoRedPoint"),
		-- [RemindName.TianshenhutiCompose] = self:FindVariable("ComposeRedPoint"),
		-- [RemindName.TianshenhutiConversion] = self:FindVariable("ConversionRedPoint"),
		[RemindName.TianshenhutiBox] = self:FindVariable("BoxRedPoint"),
		-- [RemindName.TianshenhutiBigBoss] = self:FindVariable("BigBossRedPoint"),
		-- [RemindName.TianshenhutiBoss] = self:FindVariable("BossRedPoint"),
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end

	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.Close, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("OnClickLock",
		BindTool.Bind(self.OnClickLock, self))
	for k,v in pairs(self.view_cfg) do
		self:ListenEvent(v.event,
		BindTool.Bind(self.OnClickTab, self, k))
	end

	self.show_lock = self:FindVariable("ShowLock")
	self.zhekou = self:FindVariable("BoxZheKou")

	-- 获取变量
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
end

function TianshenhutiView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function TianshenhutiView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()
end

function TianshenhutiView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function TianshenhutiView:PlayerDataChangeCallback(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		local count = value
		if count > 99999 and count <= 99999999 then
			count = count / 10000
			count = math.floor(count)
			count = count .. "万"
		elseif count > 99999999 then
			count = count / 100000000
			count = math.floor(count)
			count = count .. "亿"
		end
		if attr_name == "bind_gold" then
			self.bind_gold:SetValue(count)
		else
			self.gold:SetValue(count)
		end
	end
end

function TianshenhutiView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open))
	end
	local week_number = tonumber(os.date("%w", TimeCtrl.Instance:GetServerTime()))
	self.show_lock:SetValue(0 ~= week_number and 6 ~= week_number)
	local zhekou = TianshenhutiData.Instance:GetBoxZheKou()
	self.zhekou:SetValue(zhekou / 10)
end

function TianshenhutiView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TianshenhutiView:OnClickLock()
	SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.WeekLimit)
end

--点击标签按钮
function TianshenhutiView:OnClickTab(tab)
	if tab == self.cur_toggle or self.view_cfg[tab] == nil then
		return
	end
	self:ShowIndex(self.view_cfg[tab].index_t[1])
end

function TianshenhutiView:GetTabByIndex(index)
	return self.index_cfg[index] or INFO_TOGGLE
end

local cur_cfg = nil
function TianshenhutiView:ShowIndexCallBack(index)
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

function TianshenhutiView:AsyncLoadView(tab)
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

function TianshenhutiView:OnFlush(param_t)
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
