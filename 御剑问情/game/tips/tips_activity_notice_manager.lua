TipsActivityNoticeManager = TipsActivityNoticeManager or BaseClass()

function TipsActivityNoticeManager:__init()
	if TipsActivityNoticeManager.Instance ~= nil then
		error("[TipsActivityNoticeManager] attempt to create singleton twice!")
		return
	end
	TipsActivityNoticeManager.Instance = self
	self.activity_notice_tips = TipsActivityNoticeView.New()
	self.next_time = 0.0
	self.list = {}
	Runner.Instance:AddRunObj(self, 3)
	self.play_audio = true
end

function TipsActivityNoticeManager:__delete()
	self.list = {}
	self.next_time = nil
	if self.activity_notice_tips ~= nil then
		self.activity_notice_tips:DeleteMe()
		self.activity_notice_tips = nil
	end
	Runner.Instance:RemoveRunObj(self)
end

function TipsActivityNoticeManager:ShowActivityNoticeTips(msg)
	if self.next_time > 0.0 then
		table.insert(self.list, msg)
	else
		self.activity_notice_tips:Show(msg)
		self.next_time = 2
	end
end

function TipsActivityNoticeManager:Update()
	if self.next_time > 0.0 then
		self.next_time = self.next_time - UnityEngine.Time.deltaTime
	else
		self.next_time = 0.0
	end

	if #self.list == 0 and self.activity_notice_tips:AnimatorIsHide() and self.activity_notice_tips:IsOpen() then
		self.activity_notice_tips:Close()
	end

	if #self.list > 0 and self.activity_notice_tips:AnimatorIsHide() then -- and self.next_time <= 0.0
		self.activity_notice_tips:Show(self.list[1])
		table.remove(self.list, 1)
	end
end

function TipsActivityNoticeManager:ClearCacheList()
	self.list = {}
end