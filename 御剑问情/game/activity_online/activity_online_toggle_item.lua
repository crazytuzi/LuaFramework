OnLineActivityToggleItem = OnLineActivityToggleItem or BaseClass(BaseCell)

function OnLineActivityToggleItem:__init()
	self.title = self:FindVariable("Title")
	self.show_hl = self:FindVariable("ShowHL")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.remind_name = nil
	self.act_id = 0
	self.remind_change = nil
end

function OnLineActivityToggleItem:__delete()
	self:UBindRedPoint()
end

function OnLineActivityToggleItem:UBindRedPoint()
	if RemindManager.Instance and nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function OnLineActivityToggleItem:SetActId(id)
	self.act_id = id
end

function OnLineActivityToggleItem:GetActId()
	return self.act_id
end

function OnLineActivityToggleItem:SetBindRedPoint(remind_name)
	if nil == remind_name then
		self.show_red_point:SetValue(false)
		self:UBindRedPoint()
		return
	end

	if self.remind_name == remind_name then
		return
	end

	if nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
	end		

	self.remind_name = remind_name

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, self.remind_name)	
end

function OnLineActivityToggleItem:OnFlush()
	if nil == self.data then
		return
	end

	if self.title then
		self.title:SetValue(self.data.name)
	end
end

function OnLineActivityToggleItem:ListenClick(handler)
	self:ClearEvent("ClickTab")
	self:ListenEvent("ClickTab", handler)
end

function OnLineActivityToggleItem:FlushHl(act_id)
	if self.show_hl then
		self.show_hl:SetValue(self.act_id == act_id)
	end
end

function OnLineActivityToggleItem:RemindChangeCallBack(remind_name, num)
	if self.show_red_point then
		self.show_red_point:SetValue(num > 0)
	end
end
