WeekCellInfoPanel = BaseClass(LuaUI)

function WeekCellInfoPanel:__init( ... )
	self.URL = "ui://oa3ahys9ve3oh";
	self:__property(...)
	self:Config()
end

-- Set self property
function WeekCellInfoPanel:SetProperty( ... )
end

-- start
function WeekCellInfoPanel:Config()
	self.cells = {}
end

-- wrap UI to lua
function WeekCellInfoPanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Activity","WeekCellInfoPanel");

	self.title = self.ui:GetChild("title")
	self.time = self.ui:GetChild("time")
	self.type = self.ui:GetChild("type")
	self.count = self.ui:GetChild("count")
	self.desc = self.ui:GetChild("desc")

	self.t4 = self.ui:GetChild("t4")
	self.n4 = self.ui:GetChild("n4")
	self.n41 = self.ui:GetChild("n41")
	self.n15 = self.ui:GetChild("n15")
end

function WeekCellInfoPanel:SetData(data)
	self.title.text = data.name
	self.time.text = data.taskTime
	self.type.text = data.taskStyle
	local maxCount = nil
	if data.type == 1 then
		maxCount = data.maxCount +  ActivityModel:GetInstance():GetVipLevelAdd( data.id )
	else
		maxCount = data.maxCount
	end
	self.count.text = StringFormat("{0}次", maxCount)
	self.desc.text = data.des
	self.icon = PkgCell.New(self.ui)
	self.icon:SetXY(22, 22)	
	self.icon:OpenTips(false)
	self.icon:SetDataByCfg(2, data.icon, 1, 0)

	self.desc.y = self.t4.y
	self.n4.y = self.desc.y + self.desc.textHeight + 14
	self.n41.y = self.n4.y + self.n4.height + 14
	for i,v in ipairs(self.cells) do
		v:Destroy()
	end
	self.cells = {}
	for i = 1, #data.reward do
		local iconData = data.reward[i]
		local icon = PkgCell.New(self.ui)
		icon:SetXY(110 + 100*(i - 1), self.n41.y)	
		icon:OpenTips(true)
		icon:SetDataByCfg(iconData[1], iconData[2], iconData[3], 0)
		self.cells[i] = icon
	end

	self.n15.height = self.n41.y + 130
end

-- Combining existing UI generates a class
function WeekCellInfoPanel.Create( ui, ...)
	return WeekCellInfoPanel.New(ui, "#", {...})
end

function WeekCellInfoPanel:__delete()
	if self.icon then
		self.icon:Destroy()
		for i,v in ipairs(self.cells) do
			v:Destroy()
		end
	end
	self.icon = nil
end