require("game/baoju/achieve/achieve_view")
require("game/baoju/medal/medal_view")
require("game/baoju/zhibao/zhibao_view")

BaoJuView = BaoJuView or BaseClass(BaseView)

function BaoJuView:__init()
	self.ui_config = {"uis/views/baoju","BaoJuView"}
	self.play_audio = true
	self.full_screen = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function BaoJuView:LoadCallBack()
	--监听UI事件
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	--成就
	self.achieve_view = AchieveView.New(self:FindObj("AchieveView"))
	--勋章
	self.medal_view = MedalView.New()
	local medal_content = self:FindObj("MedalView")
	medal_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.medal_view:SetInstance(obj)
		self.medal_view:OpenCallBack()
	end)

	--至宝
	self.zhibao_view = ZhiBaoView.New()
	local zhibao_content = self:FindObj("ZhiBaoView")
	zhibao_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.zhibao_view:SetInstance(obj)
		-- self.zhibao_view:OpenCallBack()
	end)

	--至宝Toggle
	self.zhibao_toggle = self:FindObj("ZhiBaoToggle")
	-- self.ZhiBaoActiveToggle = self:FindObj("ZhiBaoActiveToggle")
	-- self.ZhiBaoUpGradeToggle = self:FindObj("ZhiBaoUpGradeToggle")
	self.zhibao_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_zhibao))

	--勋章Toggle
	self.medal_toggle = self:FindObj("MedalToggle")
	self.medal_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_medal))

	--成就Toggle
	self.achieve_toggle = self:FindObj("AchieveToggle")
	-- self.ZhiBaoTitleToggle = self:FindObj("ZhiBaoTitleToggle")
	-- self.ZhiBaoAchieveToggle = self:FindObj("ZhiBaoAchieveToggle")
	self.achieve_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_achieve_title))

	--红点
	self.red_point_list = {
		["Remind_Achieve"] = self:FindVariable("AchieveRedPoint"),
		["Remind_Medal"] = self:FindVariable("MedalRedPoint"),
		["Remind_ZhiBao"] = self:FindVariable("ZhiBaoRedPoint"),
	}

	self.def_index = TabIndex.baoju_zhibao_upgrade
	self:InitTab()

	--引导用按钮
	self.btn_close = self:FindObj("BtnClose")

	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.BaoJu, BindTool.Bind(self.GetUiCallBack, self))

	-- 功能开启
	self.event_quest = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
	RemindManager.Instance:Bind(self.remind_change)
end

function BaoJuView:ShowOrHideTab()
	if self:IsOpen() then
		local show_list = {}
		local open_fun_data = OpenFunData.Instance
		-- show_list[1] = open_fun_data:CheckIsHide("baoju_zhibao_active")
		-- show_list[2] = open_fun_data:CheckIsHide("baoju_zhibao_upgrade")
		show_list[1] = open_fun_data:CheckIsHide("baoju_zhibao_upgrade")
		show_list[2] = open_fun_data:CheckIsHide("baoju_medal")
		show_list[3] = open_fun_data:CheckIsHide("baoju_achieve_title")
		show_list[4] = open_fun_data:CheckIsHide("baoju_achieve_overview")

		-- self.ZhiBaoActiveToggle:SetActive(show_list[1])
		self.zhibao_toggle:SetActive(show_list[1])
		self.medal_toggle:SetActive(show_list[2])
		-- self.ZhiBaoTitleToggle:SetActive(show_list[4])
		-- self.ZhiBaoAchieveToggle:SetActive(show_list[5])
		self.achieve_toggle:SetActive(show_list[3] or show_list[4])
	end
end

function BaoJuView:OpenCallBack()
	self:ShowOrHideTab()
	if self.zhibao_toggle.gameObject.activeSelf then
		self.zhibao_toggle.toggle.isOn = false
	end
	for k,v in pairs(self.red_point_list) do
		v:SetValue(RemindManager.Instance:GetRemind(k))
	end
	if self.zhibao_toggle.toggle.isOn then
		self.zhibao_view:OpenCallBack()
	elseif self.medal_toggle.toggle.isOn then
		if self.medal_view and self.medal_view:IsOpen() then
			self.medal_view:OpenCallBack()
		end
	elseif self.achieve_toggle.toggle.isOn then
		self.achieve_view:OpenCallBack()
	end
end

function BaoJuView:CloseCallBack()
	if self.medal_view and self.medal_view:IsOpen() then
		self.medal_view:CloseCallBack()
	end
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

	if self.achieve_view then
		self.achieve_view:DeleteMe()
		self.achieve_view = nil
	end

	if self.medal_view then
		self.medal_view:DeleteMe()
		self.medal_view = nil
	end

	if self.zhibao_view then
		self.zhibao_view:DeleteMe()
		self.zhibao_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.event_quest then
		GlobalEventSystem:UnBind(self.event_quest)
	end
end

function BaoJuView:HandleClose()
	self.show_index = -1
	self:Close()
end

function BaoJuView:ToggleChange(index, is_On)
	if is_On then
		if index == self.show_index then
			return
		end
		self.show_index = index
		if index == TabIndex.baoju_zhibao then
			self.zhibao_view:OpenCallBack()
		elseif index == TabIndex.baoju_medal then
			if self.medal_view and self.medal_view:IsOpen() then
				self.medal_view:OpenCallBack()
			end
		elseif index == TabIndex.baoju_achieve_title then
			self.achieve_view:OpenCallBack()
		end
	end
end

--实际刷新的函数
local doFlushView =
{
	[TabIndex.baoju_zhibao] = function(self)
		self.zhibao_toggle.toggle.isOn = true
		self.zhibao_view:Flush()
	end,
	-- [TabIndex.baoju_zhibao_upgrade] = function(self)
	-- 	self.zhibao_toggle.toggle.isOn = true
	-- 	self.zhibao_view:ShowView(TabIndex.baoju_zhibao_upgrade)
	-- end,
	[TabIndex.baoju_medal] = function(self)
		self.medal_toggle.toggle.isOn = true
		if self.medal_view and self.medal_view:IsOpen() then
			self.medal_view:FlushScroller()
		end
	end,
	[TabIndex.baoju_achieve_title] = function(self)
		if not self.achieve_toggle.toggle.isOn then
			self.achieve_toggle.toggle.isOn = true
			-- self.ZhiBaoTitleToggle.toggle.isOn = true
			-- self.ZhiBaoAchieveToggle.toggle.isOn = false
			self.achieve_view:ShowView(TabIndex.baoju_achieve_title)
		end
	end,
	[TabIndex.baoju_achieve_overview] = function(self)
		if not self.achieve_toggle.toggle.isOn then
			self.achieve_toggle.toggle.isOn = true
			-- self.ZhiBaoTitleToggle.toggle.isOn = false
			-- self.ZhiBaoAchieveToggle.toggle.isOn = true
			self.achieve_view:ShowView(TabIndex.baoju_achieve_overview)
		end

		-- self.achieve_view.overview_view:OnAchieveChange()
	end,
}

--决定显示那个界面
function BaoJuView:ShowIndexCallBack(index)
	if index == 0 or nil then
		index = TabIndex.baoju_zhibao
	end

	local func = doFlushView[index]
	if func ~= nil then
		func(self)
	end
end

-- -- --初始化图标
-- function BaoJuView:InitTab()
-- 	local list = TaskData.Instance:GetTaskCompletedList()

-- 	if list[OPEN_FUNCTION_TYPE_ID.ZHIBAO] == 1 then
-- 		self.zhibao_toggle:SetActive(true)
-- 	else
-- 		self.zhibao_toggle:SetActive(false)
-- 	end

-- 	if list[OPEN_FUNCTION_TYPE_ID.MEDAL] == 1 then
-- 		self.medal_toggle:SetActive(true)
-- 	else
-- 		self.medal_toggle:SetActive(false)
-- 	end

-- 	self.achieve_toggle:SetActive(true)
-- end

--初始化图标
function BaoJuView:InitTab()
	self.zhibao_toggle:SetActive(true)
	self.medal_toggle:SetActive(true)
	self.achieve_toggle:SetActive(true)
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
		self.achieve_toggle.toggle.isOn = true
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
		if index == TabIndex.baoju_zhibao then
			if self.zhibao_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.baoju_zhibao)
				return self.zhibao_toggle, callback
			end
		elseif index == TabIndex.baoju_medal then
			if self.medal_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.baoju_medal)
				return self.medal_toggle, callback
			end
		elseif index == TabIndex.baoju_achieve_title then
			if self.achieve_toggle.gameObject.activeInHierarchy then
				local callback = BindTool.Bind(self.OnChangeToggle, self, TabIndex.baoju_achieve_title)
				return self.achieve_toggle, callback
			end
		end
	elseif self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	elseif ui_name == GuideUIName.BaoJuGoToJinJieFuBen or ui_name == GuideUIName.BaojuGotoDaily then
		if not self.zhibao_view.activedegree_view then
			return
		end
		local list = self.zhibao_view.activedegree_view.cell_list
		if list then
			for k, v in pairs(list) do
				local act_name = v:GetDailyName()
				if (act_name == Language.Guide.DailyName and ui_name == GuideUIName.BaojuGotoDaily)
					or (act_name == Language.Guide.LevelFb and ui_name == GuideUIName.BaoJuGoToJinJieFuBen) then
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
	if self.medal_view and self.medal_view:IsOpen() then
		self.medal_view:SetScrollInit(data)
	end
end