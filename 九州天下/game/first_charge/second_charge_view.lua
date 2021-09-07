require("game/first_charge/second_charge_content_view")
SecondChargeView = SecondChargeView or BaseClass(BaseView)

function SecondChargeView:__init()
	self.ui_config = {"uis/views/firstchargeview","SecondChargeView"}
	self.full_screen = false
	self.play_audio = true
	self.auto_close_time = 0
	self.is_stop_task = false
	self.selected_index = 0
end

function SecondChargeView:__delete()

end

function SecondChargeView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.SecondChargeView)
	end
	self.auto_close_time = 0
	self.is_stop_task = false

	if self.second_charge_content_view then
		self.second_charge_content_view:DeleteMe()
		self.second_charge_content_view = nil
	end

	-- 清理变量和对象
	self.btn_close = nil
	self.all_toggle_list = nil
	self.selected_index = 0
end

function SecondChargeView:CloseCallBack()
	self.auto_close_time = 0
	if self.is_stop_task == true then
		TaskCtrl.Instance:SetAutoTalkState(true)
		TaskCtrl.Instance:DoTask()
	end
	self.is_stop_task = false
	if self.close_timer_quest then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
end

function SecondChargeView:SetAutoCloseTime(close_time, is_stop_task)
	self.auto_close_time = close_time
	self.is_stop_task =is_stop_task
end

function SecondChargeView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseClick, self))
	self.second_charge_content_view = SecondChargeContentView.New(self:FindObj("second_charge_content_view"))
	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
	if self.auto_close_time ~= 0 then
		self.close_timer_quest = GlobalTimerQuest:AddDelayTimer(function()
			self:Close()
		end, self.auto_close_time)
	end

	if self.is_stop_task then
		TaskCtrl.Instance:SetAutoTalkState(false)
	end
	self.all_toggle_list = {}
	for i = 1, 3 do
		self.all_toggle_list[i] = self:FindObj("toggle_" .. i)
		self:ListenEvent("OnClickToFlush" .. i,
		BindTool.Bind2(self.OnClickToFlush, self, i))
	end

	--需要引导的按钮
	self.btn_close = self:FindObj("BtnClose")

	--功能引导注册
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.SecondChargeView, BindTool.Bind(self.GetUiCallBack, self))
end
local remind_cfg = {RemindName.FirstCharge, RemindName.SecondCharge, RemindName.ThirdCharge}
function SecondChargeView:OpenCallBack()
	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
	self.second_charge_content_view:OpenCallBack()
	DailyChargeData.Instance:SetShowPushIndex(self.selected_index)
	DailyChargeData.hasOpenFirstRecharge = true
	RemindManager.Instance:Fire(remind_cfg[self.selected_index])
	if self.all_toggle_list then
		self.all_toggle_list[self.selected_index].toggle.isOn = true
		self:Flush()
	end
end

function SecondChargeView:OnClickToFlush(index)
	DailyChargeData.Instance:SetShowPushIndex(index)
	local select_index = DailyChargeData.Instance:GetShowPushIndex()
	if self.selected_index == select_index then return end
	self:Flush()
end

function SecondChargeView:OnFlush(param_list)
	if self.second_charge_content_view then
		self.second_charge_content_view:Flush()
	end
	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
end

function SecondChargeView:OnCloseClick()
	self:Close()
end

function SecondChargeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end