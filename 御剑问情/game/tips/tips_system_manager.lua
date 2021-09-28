TipsSystemManager = TipsSystemManager or BaseClass()

function TipsSystemManager:__init()
	if TipsSystemManager.Instance ~= nil then
		error("[TipsSystemManager] attempt to create singleton twice!")
		return
	end
	TipsSystemManager.Instance = self
	self.system_tips = TipsSystemView.New()
	self.next_time = 0.0
	self.list = {}
	Runner.Instance:AddRunObj(self, 3)
end

function TipsSystemManager:__delete()
	self.list = {}
	self.next_time = nil
	if self.system_tips then
		self.system_tips:DeleteMe()
		self.system_tips = nil
	end
	Runner.Instance:RemoveRunObj(self)
end

function TipsSystemManager:ShowSystemTips(msg, speed)
	speed = speed or 1
	if type(speed) ~= "number" then
		speed = 1
	end
	if self.next_time > 0.0 then
		table.insert(self.list, {msg = msg, speed = speed})
	else
		self.system_tips = TipsSystemView.New()
		self.system_tips:Show(msg, speed)
		self.next_time = 4.0 / speed
	end
end

function TipsSystemManager:Update()
	if self.next_time > 0.0 then
		self.next_time = self.next_time - 0.05
	else
		self.next_time = 0.0
	end
	if #self.list > 2 then
		table.remove(self.list, 1)
	end
	if #self.list > 0 and self.next_time <= 0.0 then
		self.system_tips = TipsSystemView.New()
		self.system_tips:Show(self.list[1].msg, self.list[1].speed)
		self.next_time = 4.0 / (self.list[1].speed or 1)
		table.remove(self.list, 1)
	end
end