TipsFloatingName = TipsFloatingName or BaseClass()

function TipsFloatingName:__init()
	if TipsFloatingName.Instance ~= nil then
		error("[TipsFloatingName] attempt to create singleton twice!")
		return
	end
	TipsFloatingName.Instance = self
	self.floating_view = TipsFloatingView.New()
	self.next_time = 0.0
	self.list = {}
	Runner.Instance:AddRunObj(self, 3)
	self.play_audio = true
end

function TipsFloatingName:__delete()
	self.list = {}
	self.next_time = nil

	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end

	Runner.Instance:RemoveRunObj(self)
end

function TipsFloatingName:Update()
	if self.next_time > 0.0 then
		self.next_time = self.next_time - 0.2
	else
		self.next_time = 0.0
	end
	if #self.list > 3 then
		table.remove(self.list, 1)
	end
	if #self.list > 0 and self.next_time <= 0.0 then
		self.floating_view = TipsFloatingView.New()
		self.floating_view:Show(self.list[1])
		table.remove(self.list, 1)
		self.next_time = 4.0
	end
end

function TipsFloatingName:ShowFloatingTips(msg)
	if self.next_time > 0.0 then
		table.insert(self.list, msg)
	else
		self.floating_view = TipsFloatingView.New()
		self.floating_view:Show(msg)
		self.next_time = 4.0
	end
end
