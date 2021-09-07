TipsSystemManager = TipsSystemManager or BaseClass()
local CacheMsgMaxCount = 20							--传闻缓存队列最大长度

function TipsSystemManager:__init()
	if TipsSystemManager.Instance ~= nil then
		error("[TipsSystemManager] attempt to create singleton twice!")
		return
	end
	TipsSystemManager.Instance = self
	self.system_tips = TipsSystemView.New()
	self.special_system_tips = TipsSpecialSystemView.New()
	self.next_time = 0.0
	self.list = {}
	self.tips_list = {}
	self.index = 1
	Runner.Instance:AddRunObj(self, 3)
end

function TipsSystemManager:__delete()
	self.list = {}
	for k,v in pairs(self.tips_list) do
		v:DeleteMe()
	end
	self.tips_list= {}
	self.next_time = 0.0
	if self.system_tips ~= nil then
		self.system_tips:DeleteMe()
		self.system_tips = nil
	end

	if self.special_system_tips ~= nil then
		self.special_system_tips:DeleteMe()
		self.special_system_tips = nil
	end

	TipsSystemManager.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

function TipsSystemManager:ShowSystemTips(msg, speed, is_special)
	speed = speed or 1
	if type(speed) ~= "number" then
		speed = 1
	end
	if #self.list >= CacheMsgMaxCount then
		table.remove(self.list, 1)
	end
	table.insert(self.list, {msg = msg, speed = speed, is_special = is_special})
end

function TipsSystemManager:CreateTip(msg, speed, is_special)
	local tips_cell

	if is_special then
		tips_cell = TipsSpecialSystemView.New()
	else
		tips_cell = TipsSystemView.New()
	end
	self.tips_list[self.index] = tips_cell
	tips_cell:Show(msg, speed)
end

function TipsSystemManager:Update()
	if #self.list <= 0 then return end
	if self.next_time > Status.NowTime then return end
	self.next_time = Status.NowTime + 0.25

	local msg = self.list[1].msg
	local speed = self.list[1].speed
	local is_special = self.list[1].is_special
	local tips_cell = self.tips_list[self.index]
	if tips_cell then
		if is_special ~= tips_cell.is_special then
			tips_cell:Close()
			tips_cell:DeleteMe()
			self:CreateTip(msg, speed, is_special)
		else
			tips_cell:Close()
			tips_cell:Show(msg, speed)
		end
	else
		self:CreateTip(msg, speed, is_special)
	end

	for i = 1, #self.tips_list do
		if i ~= self.index and self.tips_list[i] then
			local cur_speed = self.tips_list[i]:GetAnimSpeed()
			self.tips_list[i]:ChangeSpeed(cur_speed * 3)
		end
	end

	self.index = self.index + 1
	if self.index > 5 then
		self.index = 1
	end
	table.remove(self.list, 1)
end