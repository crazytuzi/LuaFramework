require("game/clothespress/clothespress_suit_view")
require("game/clothespress/clothespress_looks_view")
require("game/clothespress/clothespress_dress_view")

local SUIT_TOGGLE = 1
local LOOKS_TOGGLE = 2
local DRESS_TOGGLE = 3

ClothespressView = ClothespressView or BaseClass(BaseView)

function ClothespressView:__init()
	self.ui_config = {"uis/views/clothespress_prefab","ClothespressView"}
	self.full_screen = false
	self.play_audio = true
	self.is_check_reduce_mem = true

	self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
end

function ClothespressView:__delete()

end

function ClothespressView:ReleaseCallBack()
	self.show_lock = nil

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

function ClothespressView:LoadCallBack()
	self.view_cfg = {}
	self.index_cfg = {}

	self.show_lock = self:FindVariable("ShowLock")

	-- 监听UI事件
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickLock",BindTool.Bind(self.OnClickLock, self))
	
	self.red_point_list = {
		[RemindName.ClothespressSuit] = self:FindVariable("SuitRedPoint"),
		[RemindName.ClothespressLooks] = self:FindVariable("LooksRedPoint"),
		[RemindName.ClothespressDress] = self:FindVariable("DressRedPoint"),
	}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end

	self:RegisterAllView()

	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function ClothespressView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ClothespressView:OpenCallBack()
	self:InitTab()
end

function ClothespressView:CloseCallBack()
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function ClothespressView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open))
	end
	self.show_lock:SetValue(true)
end

function ClothespressView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ClothespressView:OnClickLock()
	SysMsgCtrl.Instance:ErrorRemind(Language.Clothespress.NotOpenTips)
end

--点击标签按钮
function ClothespressView:OnClickTab(tab)
	if tab == self.cur_toggle or self.view_cfg[tab] == nil then
		return
	end
	self:ShowIndex(self.view_cfg[tab].index_t[1])
end

function ClothespressView:GetTabByIndex(index)
	return self.index_cfg[index] or SUIT_TOGGLE
end

function ClothespressView:ShowIndexCallBack(index)
	local index = index or self:GetShowIndex()
	local tab = self:GetTabByIndex(index)

	if self.cur_toggle ~= tab then
		if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
			self.view_cfg[self.cur_toggle].view:CloseCallBack()
		end
	end

	if nil == self.view_cfg[tab] then return end

	local cfg = self.view_cfg[tab]
	local asset_bundle_info = cfg.prefab
	self.cur_toggle = tab
	self:AsyncLoadView(tab, asset_bundle_info[1], asset_bundle_info[2], self.async_load_call_back)
	
	cfg.toggle.toggle.isOn = true
	if cfg.view then
		cfg.view:OpenCallBack()
	end
end

function ClothespressView:AsyncLoadCallBack(tab, obj)
	local view_cfg_info = self.view_cfg[tab]
	if view_cfg_info then
		obj.transform:SetParent(view_cfg_info.content.transform, false)
		obj = U3DObject(obj)
		view_cfg_info.view = view_cfg_info.view_name.New(obj)
		
		if self.cur_toggle == tab then
			view_cfg_info.view:OpenCallBack()
		end
	end
end

function ClothespressView:OnFlush(param_t)
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

function ClothespressView:RegisterAllView()
	self.view_cfg = {
	[SUIT_TOGGLE] = {
		index_t = {TabIndex.clothespress_suit},
		toggle = self:FindObj("ToggleSuit"),
		content = self:FindObj("SuitContent") ,
		event = "ClickSuit",
		view = nil,
		view_name = ClothespressSuitView,
		prefab = {"uis/views/clothespress_prefab", "SuitContent"},
		fun_open = "clothespress",
		},
	[LOOKS_TOGGLE] = {
		index_t = {TabIndex.clothespress_looks},
		toggle = self:FindObj("ToggleLooks"),
		content = self:FindObj("LooksContent") ,
		event = "ClickLooks",
		view = nil,
		view_name = ClothespressLooksView,
		prefab = {"uis/views/clothespress_prefab", "LooksContent"},
		fun_open = "clothespress",
		},
	[DRESS_TOGGLE] = {
		index_t = {TabIndex.clothespress_dress},
		toggle = self:FindObj("ToggleDress"),
		content = self:FindObj("DressContent") ,
		event = "ClickDress",
		view = nil,
		view_name = ClothespressDressView,
		prefab = {"uis/views/clothespress_prefab", "DressContent"},
		fun_open = "clothespress",
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