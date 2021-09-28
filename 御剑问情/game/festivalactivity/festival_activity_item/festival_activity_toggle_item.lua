FestivalActivityToggleItem = FestivalActivityToggleItem or BaseClass(BaseCell)

function FestivalActivityToggleItem:__init()
	self.title = self:FindVariable("Title")
	self.show_hl = self:FindVariable("ShowHL")
	self.btn = self:FindVariable("Btn")
	self.btn_hl = self:FindVariable("BtnHL")
	self.show_red_point = self:FindVariable("ShowRedPoint")
	self.text_type = self:FindVariable("TextType")
	self.remind_name = nil
	self.act_id = 0
	self.remind_change = nil
	-- self:ListenEvent("ClickTab", BindTool.Bind(self.ClickTab, self))
	
end

function FestivalActivityToggleItem:__delete()
	if RemindManager.Instance and nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end

	self.btn = nil
	self.btn_hl = nil
end

function FestivalActivityToggleItem:UBindRedPoint()
	if RemindManager.Instance and nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function FestivalActivityToggleItem:SetActId(id)
	self.act_id = id
end

function FestivalActivityToggleItem:GetActId()
	return self.act_id
end

function FestivalActivityToggleItem:SetBindRedPoint(remind_name)
	if nil == remind_name then
		self.show_red_point:SetValue(false)
		self:UBindRedPoint()
		return
	end

	if self.remind_name == remind_name.remind_name then
		return
	end

	if nil ~= self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
	end		

	self.remind_name = remind_name.remind_name

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, remind_name.remind_name)	
end

function FestivalActivityToggleItem:SetImageInfo(data)
	if nil == data then
		return
	end
	
	self.btn:SetAsset(ResPath.GetFestivalImage(data.bg_type, data.btn))
	self.btn_hl:SetAsset(ResPath.GetFestivalImage(data.bg_type, data.btn_hl))
	self.text_type:SetValue(data.text_type)
end

function FestivalActivityToggleItem:OnFlush()
	if nil == self.data then
		return
	end

	if self.title then
		self.title:SetValue(self.data.name)
	end

end

function FestivalActivityToggleItem:ListenClick(handler)
	self:ClearEvent("ClickTab")
	self:ListenEvent("ClickTab", handler)
end

function FestivalActivityToggleItem:FlushHl(act_id)
	if self.show_hl then
		self.show_hl:SetValue(self.act_id == act_id)
	end
end

function FestivalActivityToggleItem:RemindChangeCallBack(remind_name, num)
	if self.show_red_point then
		self.show_red_point:SetValue(num > 0)
	end
end
