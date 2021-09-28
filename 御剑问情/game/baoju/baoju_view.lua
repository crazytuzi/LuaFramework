-- require("game/baoju/achieve/achieve_view")
require("game/baoju/medal/medal_view")
require("game/baoju/zhibao/zhibao_view")

BaoJuView = BaoJuView or BaseClass(BaseView)

local async_load_list = {
	[TabIndex.baoju_medal] = {"uis/views/baoju_prefab", "MedalView"},
	[TabIndex.baoju_zhibao_upgrade] = {"uis/views/baoju_prefab", "Upgrade"},
	[TabIndex.baoju_zhibao_active] = {"uis/views/baoju_prefab", "ActiveDegree"},
}

function BaoJuView:__init()
	self.full_screen = true								-- 是否是全屏界面
	self.ui_config = {"uis/views/baoju_prefab","BaoJuView"}
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.async_load_call_back = BindTool.Bind(self.AsyncLoadCallBack, self)
	self.def_index = TabIndex.baoju_zhibao_active
end

function BaoJuView:LoadCallBack()
	--钻石
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("AddGold", BindTool.Bind(self.ClickAddGold, self))
	--成就
	-- self.achieve_view = AchieveView.New(self:FindObj("AchieveView"))
	--勋章
	self.medal_content = self:FindObj("MedalView")

	--至宝
	self.zhibao_content = self:FindObj("ZhiBaoView")

	--活跃
	self.active_content = self:FindObj("ActiveView")

	--至宝Toggle
	self.zhibao_toggle = self:FindObj("ZhiBaoToggle")
	self.zhibao_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_zhibao_upgrade))

	--勋章Toggle
	self.medal_toggle = self:FindObj("MedalToggle")
	self.medal_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_medal))

	--活跃Toggle
	self.active_toggle = self:FindObj("ActiveToggle")
	self.active_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_zhibao_active))

	--红点
	self.red_point_list = {
		[RemindName.Active] = self:FindVariable("ActiveRedPoint"),
		[RemindName.Medal] = self:FindVariable("MedalRedPoint"),
		[RemindName.ZhiBao] = self:FindVariable("ZhiBaoRedPoint"),
	}

	self.def_index = TabIndex.baoju_zhibao_upgrade
	self:InitTab()

	--引导用按钮
	self.btn_close = self:FindObj("BtnClose")

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.BaoJu, BindTool.Bind(self.GetUiCallBack, self))

	-- 功能开启
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function BaoJuView:ShowOrHideTab()
	if self:IsOpen() then
		local show_list = {}
		local open_fun_data = OpenFunData.Instance
		show_list[1] = open_fun_data:CheckIsHide("baoju_zhibao_active")
		show_list[2] = open_fun_data:CheckIsHide("baoju_zhibao_upgrade")
		show_list[3] = open_fun_data:CheckIsHide("baoju_medal")
		-- show_list[4] = open_fun_data:CheckIsHide("baoju_achieve_title")
		-- show_list[5] = open_fun_data:CheckIsHide("baoju_achieve_overview")

		self.medal_toggle:SetActive(show_list[3])
		-- self.active_toggle:SetActive(show_list[4] or show_list[5])
	end
end

function BaoJuView:OpenCallBack()
	-- 监听系统事件
	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])

	self:ShowOrHideTab()
	for k,v in pairs(self.red_point_list) do
		v:SetValue(RemindManager.Instance:GetRemind(k))
	end
	if self.zhibao_toggle.toggle.isOn then
		if self.zhibao_view then
			self.zhibao_view:OpenCallBack()
		end
	elseif self.medal_toggle.toggle.isOn then
		if self.medal_view then
			self.medal_view:OpenCallBack()
		end
	elseif self.active_toggle.toggle.isOn then
		if self.active_view then
			self.active_view:OpenCallBack()
		end
	end
end

function BaoJuView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end

	if self.medal_view then
		self.medal_view:CloseCallBack()
	end
	if self.zhibao_view then
		self.zhibao_view:CloseCallBack()
	end
	if self.active_view then
		self.active_view:CloseCallBack()
	end
	--关闭特效界面
	TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.BaoJu)
	ZhiBaoData.Instance:SetStartFlyObj(nil)
end

function BaoJuView:RemindChangeCallBack(key, value)
	if self.red_point_list[key] then
		self.red_point_list[key]:SetValue(value > 0)
	end
end

function BaoJuView:SetRedPoint(key, value)
	if self:IsLoaded() then
		self.red_point_list[key]:SetValue(value)
	end
end

--游戏中被删除时,退出游戏时也会调用
function BaoJuView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.BaoJu)
	end

	-- if self.achieve_view then
	-- 	self.achieve_view:DeleteMe()
	-- 	self.achieve_view = nil
	-- end

	if self.medal_view then
		self.medal_view:DeleteMe()
		self.medal_view = nil
	end

	if self.zhibao_view then
		self.zhibao_view:DeleteMe()
		self.zhibao_view = nil
	end

	if self.active_view then
		self.active_view:DeleteMe()
		self.active_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end

	-- 清理变量和对象
	self.zhibao_toggle = nil
	self.medal_toggle = nil
	self.active_toggle = nil
	self.red_point_list = nil
	self.btn_close = nil
	self.gold = nil
	self.bind_gold = nil
	self.medal_content = nil
	self.zhibao_content = nil
	self.active_content = nil
end

function BaoJuView:HandleClose()
	self.show_index = -1
	self:Close()
end

function BaoJuView:ClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function BaoJuView:ToggleChange(index, is_On)
	if is_On then
		local asset_bundle_list = async_load_list[index] or {}
		self:AsyncLoadView(index, asset_bundle_list[1], asset_bundle_list[2], self.async_load_call_back)

		if index == self.show_index then
			return
		end
		self.show_index = index
		if index == TabIndex.baoju_zhibao_upgrade then
			if self.zhibao_view then
				self.zhibao_view:OpenCallBack()
			end
		elseif index == TabIndex.baoju_medal then
			--关闭特效界面
			TipsCtrl.Instance:DestroyFlyEffectByViewName(ViewName.BaoJu)
			ZhiBaoData.Instance:SetStartFlyObj(nil)
			if self.medal_view then
				self.medal_view:OpenCallBack()
			end
		elseif index == TabIndex.baoju_zhibao_active then
			--关闭特效界面
			if self.active_view then
				self.active_view:OpenCallBack()
			end
		end
	end
end

--实际刷新的函数
local doFlushView =
{
	[TabIndex.baoju_zhibao_active] = function(self)
		if nil == self.zhibao_toggle then return end

		self.active_toggle.toggle.isOn = true
		if self.active_view then
			self.active_view:Flush()
		end
	end,
	[TabIndex.baoju_zhibao_upgrade] = function(self)
		if nil == self.zhibao_toggle then return end

		self.zhibao_toggle.toggle.isOn = true
		if self.zhibao_view then
			self.zhibao_view:Flush()
		end
	end,
	[TabIndex.baoju_medal] = function(self)
		if nil == self.medal_toggle then return end

		self.medal_toggle.toggle.isOn = true
		if self.medal_view then
			self.medal_view:FlushScroller()
		end
	end,
	-- [TabIndex.baoju_achieve_title] = function(self)
	-- 	if not self.active_toggle.toggle.isOn then
	-- 		self.active_toggle.toggle.isOn = true
	-- 		self.achieve_view:ShowView(TabIndex.baoju_achieve_title)
	-- 	end
	-- end,
	-- [TabIndex.baoju_achieve_overview] = function(self)
	-- 	if not self.active_toggle.toggle.isOn then
	-- 		self.active_toggle.toggle.isOn = true
	-- 		self.achieve_view:ShowView(TabIndex.baoju_achieve_overview)
	-- 	end
	-- end,
}

function BaoJuView:AsyncLoadCallBack(index, obj)
	if index == TabIndex.baoju_medal then
		obj.transform:SetParent(self.medal_content.transform, false)
		obj = U3DObject(obj)
		self.medal_view = MedalView.New(obj)
		self.medal_view:OpenCallBack()
		self.medal_view:Flush()
	elseif index == TabIndex.baoju_zhibao_upgrade then
		obj.transform:SetParent(self.zhibao_content.transform, false)
		obj = U3DObject(obj)
		self.zhibao_view = ZhiBaoUpgradeView.New(obj)
		self.zhibao_view:OpenCallBack()
		self.zhibao_view:Flush()
	elseif index == TabIndex.baoju_zhibao_active then
		obj.transform:SetParent(self.active_content.transform, false)
		obj = U3DObject(obj)
		self.active_view = ZhiBaoActiveDegreeView.New(obj)
		self.active_view:Flush()
	end
end

--决定显示那个界面
function BaoJuView:ShowIndexCallBack(index)
	local asset_bundle_list = async_load_list[index] or {}
	self:AsyncLoadView(index, asset_bundle_list[1], asset_bundle_list[2], self.async_load_call_back)
	
	if index == 0 or nil then
		index = TabIndex.baoju_zhibao_active
	end

	local func = doFlushView[index]
	if func ~= nil then
		func(self)
	end
end

--初始化图标
function BaoJuView:InitTab()
	self.zhibao_toggle:SetActive(true)
	self.medal_toggle:SetActive(true)
	self.active_toggle:SetActive(true)
end

--引导用函数
function BaoJuView:OnChangeToggle(index)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if index == TabIndex.mount_jinjie then
		self.zhibao_toggle.toggle.isOn = true
	elseif index == TabIndex.wing_jinjie then
		self.medal_toggle.toggle.isOn = true
	elseif index == TabIndex.halo_jinjie then
		self.active_toggle.toggle.isOn = true
	end
end

function BaoJuView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if ui_name == GuideUIName.Tab then
		local index = TabIndex[ui_param]
		if index == self.show_index then
			return NextGuideStepFlag
		end
		if index == TabIndex.baoju_zhibao_active then
			if self.zhibao_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.baoju_zhibao_active)
				return self.zhibao_toggle, callback
			end
		elseif index == TabIndex.baoju_medal then
			if self.medal_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.baoju_medal)
				return self.medal_toggle, callback
			end
		elseif index == TabIndex.baoju_achieve_title then
			if self.active_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.baoju_achieve_title)
				return self.active_toggle, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	elseif ui_name == GuideUIName.BaoJuGoToJinJieFuBen or ui_name == GuideUIName.BaojuGotoDaily then
		if not self.active_view then
			return
		end
		local list = self.active_view.cell_list
		if list then
			for k, v in pairs(list) do
				local go_to_panel = v:GetGoToPanel()
				if go_to_panel == "DailyTask" then
					local btn_go = v.btn_go
					if btn_go and btn_go.gameObject.activeInHierarchy then
						return btn_go
					end
				end
			end
		end
	end
end

function BaoJuView:OnFlush(data)
	if self.medal_view then
		self.medal_view:SetScrollInit(data)
	end
end

function BaoJuView:PlayerDataChangeCallback(attr_name, value, old_value)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(vo.gold))
	end
	if attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(vo.bind_gold))
	end
end