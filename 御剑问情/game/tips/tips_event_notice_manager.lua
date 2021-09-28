TipsEventNoticeManager = TipsEventNoticeManager or BaseClass()

function TipsEventNoticeManager:__init()
	if TipsEventNoticeManager.Instance ~= nil then
		error("[TipsEventNoticeManager] attempt to create singleton twice!")
		return
	end
	TipsEventNoticeManager.Instance = self
	self.activity_notice_tips = TipsEventNoticeView.New()
	self.next_time = 0.0
	self.common_list = {}
	self.special_list = {}
	self.index = 0
	Runner.Instance:AddRunObj(self, 3)
	self.play_audio = true
end

function TipsEventNoticeManager:__delete()
	self.common_list = {}
	self.special_list = {}
	self.next_time = nil
	if self.activity_notice_tips ~= nil then
		self.activity_notice_tips:DeleteMe()
		self.activity_notice_tips = nil
	end
	Runner.Instance:RemoveRunObj(self)
end

function TipsEventNoticeManager:ShowNoticeTips(msg, types)
	if self.next_time > 0.0 then
		if types == TIPSEVENTTYPES.SPECIAL then
			table.insert(self.special_list, msg)
		else
			table.insert(self.common_list, msg)
		end
	else
		self.activity_notice_tips:Show(msg, types)
		self.next_time = 2
	end
end

function TipsEventNoticeManager:Update()
	if self.next_time > 0.0 then
		self.next_time = self.next_time - UnityEngine.Time.deltaTime
	else
		self.next_time = 0.0
	end
	local common_count = #self.common_list
	local special_count = #self.special_list
	local count = common_count + special_count
	if count == 0 and self.activity_notice_tips:AnimatorIsHide() and self.activity_notice_tips:IsOpen() then
		self.activity_notice_tips:Close()
	end

	if count > 0 and self.activity_notice_tips:AnimatorIsHide() then -- and self.next_time <= 0.0
		if special_count > 0 then
			self.activity_notice_tips:Show(self.special_list[special_count], TIPSEVENTTYPES.SPECIAL)
		else
			self.activity_notice_tips:Show(self.common_list[common_count], TIPSEVENTTYPES.COMMON)
		end
		self.common_list = {}
		self.special_list = {}
	end
end

function TipsEventNoticeManager:ClearCacheList()
	self.list = {}
	self.type_list = {}
end