require("game/card/card_info_view")
require("game/card/card_recyle_view")

local INFO_TOGGLE = 1
local RECYLE_TOGGLE = 2
CardView = CardView or BaseClass(BaseView)

function CardView:__init()
	self.ui_config = {"uis/views/cardview_prefab","CardView"}
	self.full_screen = true
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.card_info
	self.cur_toggle = INFO_TOGGLE
	self.view_cfg = {}
	self.index_cfg = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function CardView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)

end

function CardView:ReleaseCallBack()
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
end

function CardView:LoadCallBack()
	self.view_cfg = {
	[INFO_TOGGLE] = {
		index_t = {TabIndex.card_info},
		toggle = self:FindObj("ToggleCard"),
		content = self:FindObj("CardContent") ,
		event = "ClickCard",
		view = nil,
		view_name = CardInfoView,
		prefab = {"uis/views/cardview_prefab", "CardInfoContent"},
		fun_open = "cardview",
		},
	[RECYLE_TOGGLE] = {
		index_t = {TabIndex.card_recyle},
		toggle = self:FindObj("ToggleRecyle"),
		content = self:FindObj("RecyleContent") ,
		event = "ClickRecyle",
		view = nil,
		view_name = CardRecyleView,
		prefab = {"uis/views/cardview_prefab", "CardRecyleContent"},
		fun_open = "cardview",
		},
	}
	for k,v in pairs(self.view_cfg) do
		for k1,v1 in pairs(v.index_t) do
			self.index_cfg[v1] = k
		end
	end

	self.red_point_list = {
		[RemindName.CardActive] = self:FindVariable("CardRedPoint"),
		[RemindName.CardRecyle] = self:FindVariable("RecyleRedPoint"),
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
	for k,v in pairs(self.view_cfg) do
		self:ListenEvent(v.event,
		BindTool.Bind(self.OnClickTab, self, k))
	end

	-- 获取变量
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
end

function CardView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function CardView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	self:InitTab()
end

function CardView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function CardView:PlayerDataChangeCallback(attr_name, value, old_value)
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

function CardView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open))
	end
end

function CardView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

--点击标签按钮
function CardView:OnClickTab(tab)
	if tab == self.cur_toggle or self.view_cfg[tab] == nil then
		return
	end
	self:ShowIndex(self.view_cfg[tab].index_t[1])
end

function CardView:GetTabByIndex(index)
	return self.index_cfg[index] or INFO_TOGGLE
end

local cur_cfg = nil
function CardView:ShowIndexCallBack(index)
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

function CardView:AsyncLoadView(tab)
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

function CardView:OnFlush(param_t)
	if param_t.all and param_t.all.item_id and param_t.all.item_id > 0 then
		local item_id = param_t.all.item_id
		local _, is_open = CardData.Instance:IsBetterCardPiece(item_id)
		if not is_open then
			TipsCtrl.Instance:ShowSystemMsg(Language.Card.UnopenedChapterTips)
		end
	end
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
