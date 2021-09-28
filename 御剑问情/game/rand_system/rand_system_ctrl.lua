require("game/rand_system/rand_system_data")
require("game/rand_system/rand_system_view")

RandSystemCtrl = RandSystemCtrl or  BaseClass(BaseController)

function RandSystemCtrl:__init()
	if RandSystemCtrl.Instance ~= nil then
		ErrorLog("[RandSystemCtrl] attempt to create singleton twice!")
		return
	end
	RandSystemCtrl.Instance = self

	self.view_is_open = false

	self.data = RandSystemData.New()
	self.view = RandSystemView.New(ViewName.RandSystem)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpen, self))
end

function RandSystemCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.close_time_quest then
		GlobalTimerQuest:CancelQuest(self.close_time_quest)
		self.close_time_quest = nil
	end

	RandSystemCtrl.Instance = nil
end

function RandSystemCtrl:CheckToOpenView()
	if self.view_is_open or IS_ON_CROSSSERVER then
		return
	end
	local last_show_index = self.data:GetLastShowIndex()
	local notice_info = self.data:GetNoticeInfoByIndex(last_show_index)
	local notice_time = notice_info.notice_time or 0
	if Status.NowTime - self.last_show_time < notice_time then
		return
	end

	self.view_is_open = true
	self.view:Open()

	self.close_time_quest = GlobalTimerQuest:AddDelayTimer(function()
		self.view:Close()

		local last_show_index = self.data:GetLastShowIndex()
		last_show_index = last_show_index + 1
		local max_notice_count = self.data:GetMaxNoticeCount()
		if last_show_index > max_notice_count then
			last_show_index = 1
		end
		self.data:SetLastShowIndex(last_show_index)

		self.last_show_time = Status.NowTime
		self.view_is_open = false
	end, 10)
end

--设置是否可以出现系统随机公告
function RandSystemCtrl:SetCanOpenSystem(state)
	if state then
		if self.close_time_quest then
			GlobalTimerQuest:CancelQuest(self.close_time_quest)
			self.close_time_quest = nil
		end
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.last_show_time = Status.NowTime
		self.view_is_open = false
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CheckToOpenView, self), 1)
	else
		self.last_show_time = COMMON_CONSTS.MAX_LOOPS
		if self.close_time_quest then
			GlobalTimerQuest:CancelQuest(self.close_time_quest)
			self.close_time_quest = nil
		end
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		if self.view:IsOpen() then
			self.view:Close()
		end
	end
end

function RandSystemCtrl:MainuiOpen()
	if self.last_show_time then
		return
	end
	self.last_show_time = Status.NowTime
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CheckToOpenView, self), 1)
end