require("game/illustrated_handbook/boss_card_info_view")

local BOSS_INFO_TOGGLE = 1

IllustratedHandbookView = IllustratedHandbookView or BaseClass(BaseView)

function IllustratedHandbookView:__init()
	self.ui_config = {"uis/views/illustratedhandbook_prefab","IllustratedHandbookView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
end

function IllustratedHandbookView:__delete()

end

function IllustratedHandbookView:ReleaseCallBack()
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
	
	GlobalEventSystem:UnBind(self.open_trigger_handle)
end

function IllustratedHandbookView:LoadCallBack()
	self.def_index = TabIndex.boss_card_info
	self.cur_toggle = BOSS_INFO_TOGGLE
	self.view_cfg = {}
	self.index_cfg = {}

	self.view_cfg = {
	[BOSS_INFO_TOGGLE] = {
		index_t = {TabIndex.boss_card_info},
		toggle = self:FindObj("ToggleBoss"),
		content = self:FindObj("BossContent") ,
		event = "ClickBoss",
		view = nil,
		view_name = BossCardInfoView,
		prefab = {"uis/views/illustratedhandbook_prefab", "BossInfoContent"},
		fun_open = "illustrated_handbook",
		},
	}
	for k,v in pairs(self.view_cfg) do
		for k1,v1 in pairs(v.index_t) do
			self.index_cfg[v1] = k
		end
	end

	self.red_point_list = {
		[RemindName.BossHandBook] = self:FindVariable("BossRedPoint"),
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
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

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function IllustratedHandbookView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function IllustratedHandbookView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()
end

function IllustratedHandbookView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function IllustratedHandbookView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open))
	end
end

function IllustratedHandbookView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(vo.gold))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(vo.bind_gold))
	end
end

function IllustratedHandbookView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击标签按钮
function IllustratedHandbookView:OnClickTab(tab)
	if tab == self.cur_toggle or self.view_cfg[tab] == nil then
		return
	end
	self:ShowIndex(self.view_cfg[tab].index_t[1])
end

function IllustratedHandbookView:GetTabByIndex(index)
	return self.index_cfg[index] or BOSS_INFO_TOGGLE
end

function IllustratedHandbookView:ShowIndexCallBack(index)
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

function IllustratedHandbookView:AsyncLoadView(tab)
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

function IllustratedHandbookView:OnFlush(param_t)
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

function IllustratedHandbookView:FlushEffect()
	local cur_index = self:GetShowIndex()
	local tab = self:GetTabByIndex(cur_index)

	if tab == BOSS_INFO_TOGGLE then
		if nil == self.view_cfg[tab] then return end
		
		local cfg = self.view_cfg[tab]
		if nil == cfg then return end

		cfg.view:FlushEffect()
	end
end
