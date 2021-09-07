require("game/baoju/achieve/achieve_view")
require("game/baoju/medal/medal_view")
require("game/baoju/zhibao/zhibao_view")

BaoJuView = BaoJuView or BaseClass(BaseView)

function BaoJuView:__init()
	self.ui_config = {"uis/views/baoju","BaoJuView"}
	self.play_audio = true
	self:SetMaskBg()
	self.def_index = TabIndex.baoju_zhibao
	self.show_index = TabIndex.baoju_zhibao

end

function BaoJuView:LoadCallBack()
	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))
	
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
	end)

	--至宝Toggle
	self.zhibao_toggle = self:FindObj("ZhiBaoToggle")
	self.zhibao_toggle.toggle.isOn = true
	self.zhibao_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_zhibao))

	--勋章Toggle
	self.medal_toggle = self:FindObj("MedalToggle")
	self.medal_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_medal))

	--成就Toggle
	self.achieve_toggle = self:FindObj("AchieveToggle")
	self.achieve_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.ToggleChange, self, TabIndex.baoju_achieve_title))

	--红点
	self.red_point_list = {
		-- [RemindName.Achieve] = self:FindVariable("AchieveRedPoint"),
		[RemindName.Medal] = self:FindVariable("MedalRedPoint"),
		[RemindName.ZhiBao] = self:FindVariable("ZhiBaoRedPoint"),
	}
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

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	self.red_point_list = {}
	self.zhibao_toggle = nil
	self.medal_toggle = nil
	self.achieve_toggle = nil
	self.btn_close = nil
end

function BaoJuView:ShowOrHideTab()
	if self:IsOpen() then
		local show_list = {}
		local open_fun_data = OpenFunData.Instance
		show_list[1] = open_fun_data:CheckIsHide("baoju_zhibao_upgrade")
		show_list[2] = open_fun_data:CheckIsHide("baoju_medal")
		self.zhibao_toggle:SetActive(show_list[1])
		self.medal_toggle:SetActive(show_list[2])
		-- self.ZhiBaoTitleToggle:SetActive(show_list[4])
		-- self.ZhiBaoAchieveToggle:SetActive(show_list[5])
		self.achieve_toggle:SetActive(false)
	end
end

function BaoJuView:OpenCallBack()
	self:ShowOrHideTab()
	for k,v in pairs(self.red_point_list) do
		v:SetValue(RemindManager.Instance:GetRemind(k))
	end
	if self.zhibao_toggle.toggle.isOn then
		-- self:CallRemindInit()
		self.zhibao_view:OpenCallBack()
	elseif self.medal_toggle.toggle.isOn then
		if self.medal_view and self.medal_view:IsOpen() then
			self.medal_view:OpenCallBack()
		end
	end
end

function BaoJuView:CallRemindInit()
	-- ClickOnceRemindList[RemindName.ZhiBao_Active] = 0
	ClickOnceRemindList[RemindName.ZhiBao_Upgrade] = 0
	ClickOnceRemindList[RemindName.ZhiBao_HuanHua] = 0
	-- RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ZhiBao_Active)
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ZhiBao_Upgrade)
	RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ZhiBao_HuanHua)
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

function BaoJuView:HandleClose()
	self:Close()
end

function BaoJuView:ToggleChange(index, is_On)
	if is_On then
		if index == TabIndex.baoju_zhibao then
			--self:CallRemindInit()
			self.zhibao_view:OpenCallBack()
		elseif index == TabIndex.baoju_medal then
			if self.medal_view and self.medal_view:IsOpen() then
				self.medal_view:OpenCallBack()
			end
		elseif index == TabIndex.baoju_achieve_title then
			self.achieve_view:OpenCallBack()
		end
		self:ChangeToIndex(index)

		self:ShowIndexCallBack(index)
		self.show_index = index
	end
end

--决定显示那个界面
function BaoJuView:ShowIndexCallBack(index)
	if self.show_index == TabIndex.baoju_zhibao then
		self.zhibao_toggle.toggle.isOn = true
		ClickOnceRemindList[RemindName.ZhiBao_Active] = 0
		RemindManager.Instance:CreateIntervalRemindTimer(RemindName.ZhiBao_Active)
	elseif self.show_index == TabIndex.baoju_medal then
		self.medal_toggle.toggle.isOn = true
	end
	self:Flush()
end

--初始化图标
function BaoJuView:InitTab()
	self.zhibao_toggle:SetActive(true)
	self.medal_toggle:SetActive(true)
	self.achieve_toggle:SetActive(false)
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
	elseif ui_name == GuideUIName.BaojuGotoDaily then
		if not self.zhibao_view then
			return
		end

		local list = self.zhibao_view.cell_list
		if list then
			for k, v in pairs(list) do
				local goto_panel = v:GetGotoPanel()
				-- if (act_name == Language.Guide.DailyName and ui_name == GuideUIName.BaojuGotoDaily) 
				-- 	or (act_name == Language.Guide.LevelFb and ui_name == GuideUIName.BaoJuGoToJinJieFuBen) then
				-- 	local btn_go = v.btn_go
				-- 	if btn_go and btn_go.gameObject.activeInHierarchy then
				-- 		return btn_go
				-- 	end
				-- end
				if goto_panel == "DailyTask" then
					local btn_go = v:GetActiveDegreeItem()
					if btn_go then
						return btn_go --v.gameObject btn_go
					end
				end
			end
		end
	elseif ui_name == GuideUIName.BaoJuGoToFuBen then
		local btn_Object = self.zhibao_view:GetEnterBtn()
		if btn_Object then
			local callback = self.zhibao_view:GetEnterCallBack()
			return btn_Object, callback
		end
		
	end
end

function BaoJuView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if self.show_index == TabIndex.baoju_zhibao then
				self.zhibao_view:Flush()
			elseif self.show_index == TabIndex.baoju_medal then
				self.medal_view:Flush()
			end
		end
	end
end
