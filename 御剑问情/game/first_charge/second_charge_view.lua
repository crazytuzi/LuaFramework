require("game/first_charge/second_charge_content_view")
SecondChargeView = SecondChargeView or BaseClass(BaseView)

-- 首充界面
function SecondChargeView:__init()
	self.ui_config = {"uis/views/firstchargeview_prefab","SecondChargeView"}
	self.full_screen = false
	self.play_audio = true
	self.auto_close_time = 0
	self.is_stop_task = false
	self.selected_index = 0
end

function SecondChargeView:__delete()

end

local tab_index = {TabIndex.charge_first_rank, TabIndex.charge_second_rank,TabIndex.charge_thrid_rank}
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
		BindTool.Bind2(self.ChangeToIndex, self, tab_index[i]))
	end

	--需要引导的按钮
	self.btn_close = self:FindObj("BtnClose")

	self.top_desc = self:FindVariable("top_desc")
	-- self.left_desc = self:FindVariable("left_desc")
	-- self.right_desc = self:FindVariable("right_desc")
end

function SecondChargeView:ReleaseCallBack()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.SecondChargeView)
	end
	self.auto_close_time = 0
	self.is_stop_task = false
	self:RemoveDelayTime()
	if self.second_charge_content_view then
		self.second_charge_content_view:DeleteMe()
		self.second_charge_content_view = nil
	end

	-- 清理变量和对象
	self.btn_close = nil
	self.all_toggle_list = nil
	self.top_desc = nil
	self.selected_index = 0
end

function SecondChargeView:CloseCallBack()
	self.auto_close_time = 0
	if self.is_stop_task == true then
		TaskCtrl.Instance:SetAutoTalkState(true)
		TaskCtrl.Instance:DoTask()
	end
	self.is_stop_task = false
	self:RemoveDelayTime()
end

function SecondChargeView:RemoveDelayTime()
	if self.close_timer_quest then
		GlobalTimerQuest:CancelQuest(self.close_timer_quest)
		self.close_timer_quest = nil
	end
end

function SecondChargeView:SetAutoCloseTime(close_time, is_stop_task)
	self.auto_close_time = close_time
	self.is_stop_task =is_stop_task
end

local remind_cfg = {RemindName.FirstCharge, RemindName.SecondCharge, RemindName.ThirdCharge}
function SecondChargeView:OpenCallBack()
	self.selected_index = DailyChargeData.Instance:GetShowPushIndex()
	if self.second_charge_content_view then
		self.second_charge_content_view:Flush(self.selected_index)
	end
	DailyChargeData.Instance:SetShowPushIndex(self.selected_index)
	DailyChargeData.hasOpenFirstRecharge = true
	RemindManager.Instance:Fire(remind_cfg[self.selected_index])
	if self.all_toggle_list then
		self.all_toggle_list[self.selected_index].toggle.isOn = true
		self:Flush()
	end
end

function SecondChargeView:OnFlush(param_list)
	self:JumpToNextAward()
	self.second_charge_content_view:Flush(self.selected_index)
end


function SecondChargeView:JumpToNextAward()
	if nil == self.selected_index or self.selected_index <= 0 or self.selected_index > 3 then return end

	local active_flag, fetch_flag = DailyChargeData.Instance:GetThreeRechargeFlag(self.selected_index)
	if nil == active_flag or nil == fetch_flag then return end

	if active_flag == 1 and fetch_flag == 1 then
		local index = DailyChargeData.Instance:GetNeedJumpToNextIndex(self.selected_index)
		if index == 0 then return end

		local show_index = self:GetTableIndex(index)
		self:ChangeToIndex(show_index)
	end
end

function SecondChargeView:GetTableIndex(next_index)
	local show_index = TabIndex.charge_first_rank
	if nil == next_index then
		return show_index
	end

	for k,v in pairs(tab_index) do
		local index = v % 10
		if index == next_index then
			show_index = v
			break
		end
	end
	return show_index
end

function SecondChargeView:ShowIndexCallBack(index)
	-- 将index规范为个位数以不改变原有数字逻辑
	index = index % 10
	if index < 1 or index > 3 then
		index = 1
	end
	self.selected_index = index
	-- DailyChargeData.Instance:SetShowPushIndex(self.selected_index)
	
	if self.all_toggle_list then
		self.all_toggle_list[self.selected_index].toggle.isOn = true
	end
	if self.second_charge_content_view then
		self.second_charge_content_view:Flush(self.selected_index)
	end
	local bundle,asset = ResPath.GetChargeImage(self.selected_index)
	local bundle1,asset1 = nil,nil
	local bundle2,asset2 = nil,nil
	self.top_desc:SetAsset(bundle,asset)
	-- if self.selected_index == 1 then
	-- 	bundle1,asset1 = ResPath.GetFirstChargeImage(self.selected_index, "_l")
	-- 	bundle2,asset2 = ResPath.GetFirstChargeImage(self.selected_index, "_r")
	-- else
	-- 	bundle1,asset1 = ResPath.GetFirstChargeImage(self.selected_index)
	-- 	bundle2,asset2 = ResPath.GetFirstChargeImage(self.selected_index)
	-- end
	-- self.left_desc:SetAsset(bundle1,asset1)
	-- self.right_desc:SetAsset(bundle2,asset2)
end

function SecondChargeView:OnCloseClick()
	self:Close()
end