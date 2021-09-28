require("game/lianhun/lianhun_info_view")
require("game/lianhun/fu_ben_suoyaotower_view")
LianhunView = LianhunView or BaseClass(BaseView)
local INFO_TOGGLE = 1
local SLAUGHTER_TOGGLE = 2
local SUOYAO_TOWER = 3
function LianhunView:__init()
	self.ui_config = {"uis/views/lianhun_prefab","LianhunView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.def_index = TabIndex.lianhun_info
	self.cur_toggle = INFO_TOGGLE
	self.view_cfg = {}
	self.index_cfg = {}
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	self.open_trigger_handle = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.InitTab, self))
end

function LianhunView:__delete()
	GlobalEventSystem:UnBind(self.open_trigger_handle)

end

function LianhunView:ReleaseCallBack()
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
	self.title_word = nil
end

function LianhunView:LoadCallBack()
	self.view_cfg = {
	[INFO_TOGGLE] = {
		index_t = {TabIndex.lianhun_info},
		toggle = self:FindObj("ToggleLianhun"),
		content = self:FindObj("LianhunContent") ,
		event = "ClickLianhun",
		view = nil,
		view_name = LianhunInfoView,
		prefab = {"uis/views/lianhun_prefab", "LianhunInfoContent"},
		fun_open = "lianhunview",
		},
	[SLAUGHTER_TOGGLE] = {
		index_t = {TabIndex.fb_slaughter_devil},
		toggle = self:FindObj("tab_slaughter_devil"),
		content = self:FindObj("slaughter_devil_content"),
		event = "ClickSlaughterDevil",
		view = nil,
		view_name = SlaughterDevilContent,
		prefab = {"uis/views/lianhun_prefab", "SlaughterDevilContent"},
		fun_open = "lianhunview",
		},
	[SUOYAO_TOWER] = {
		index_t = {TabIndex.suoyao_tower},
		toggle = self:FindObj("TabSuoYaoTower"),
		content = self:FindObj("SuoYaoTowerContent"),
		event = "ClickSuoYaoTower",
		view = nil,
		view_name = SuoYaoTowerView,
		prefab = {"uis/views/lianhun_prefab", "SuoYaoTowerContent"},
		fun_open = "suoyao_tower",
		}
	}
	for k,v in pairs(self.view_cfg) do
		for k1,v1 in pairs(v.index_t) do
			self.index_cfg[v1] = k
		end
	end
	self.red_point_list = {
		[RemindName.Lianhun] = self:FindVariable("LianhunRedPoint"),
		[RemindName.SlaughterDevil] = self:FindVariable("SlaughterRedPoint"),
		[RemindName.SuoYaoTower] = self:FindVariable("SuoyaotaRedPoint"),
	}

	for k, v in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
		v:SetValue(RemindManager.Instance:GetRemind(k) > 0)
	end

	-- 监听UI事件
	self:ListenEvent("Close",
		BindTool.Bind(self.CloseView, self))
	for k,v in pairs(self.view_cfg) do
		self:ListenEvent(v.event,
		BindTool.Bind(self.OnClickTab, self, k))
	end

	-- 获取变量
	self.title_word = self:FindVariable("title_word")
end

function LianhunView:CloseView()
	self:Close()
end

function LianhunView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function LianhunView:OpenCallBack()
	self:InitTab()

	LianhunCtrl.Instance:SendSuoYaoTowerReq(SUOYAOTA_FB_OPERA_REQ_TYPE.SUOYAOTA_FB_OPERA_REQ_TYPE_ALL_INFO)
end

function LianhunView:CloseCallBack()
	if self.view_cfg[self.cur_toggle] and self.view_cfg[self.cur_toggle].view then
		self.view_cfg[self.cur_toggle].view:CloseCallBack()
	end
end

function LianhunView:InitTab()
	if not self:IsOpen() then return end
	local open_fun_data = OpenFunData.Instance
	for k,v in pairs(self.view_cfg) do
		v.toggle:SetActive(open_fun_data:CheckIsHide(v.fun_open))
	end
end

--点击标签按钮
function LianhunView:OnClickTab(tab)
	if tab == self.cur_toggle or self.view_cfg[tab] == nil then
		return
	end
	self:ShowIndex(self.view_cfg[tab].index_t[1])
end

function LianhunView:GetTabByIndex(index)
	return self.index_cfg[index] or INFO_TOGGLE
end

local cur_cfg = nil
function LianhunView:ShowIndexCallBack(index)
	local index = index or self:GetShowIndex()

	if index == TabIndex.suoyao_tower then
		ClickOnceRemindList[RemindName.SuoYaoTower] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.SuoYaoTower)
	end

	local tab = self:GetTabByIndex(index)

	for k,v in pairs(self.view_cfg) do
		v.toggle.toggle.isOn = false
	end

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
	self:Flush()
end

function LianhunView:AsyncLoadView(tab)
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

function LianhunView:OnFlush(param_t)
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
	self.title_word:SetValue(Language.LianHunTitile[tab])
end
