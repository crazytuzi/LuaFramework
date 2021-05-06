local CBirthPopupBox = class("CBirthPopupBox", CBox)

function CBirthPopupBox.ctor(self, obj, mode, selectIndex, isHideTouchOut)
	CBox.ctor(self, obj)
	self.m_YearScrollView = self:NewUI(1, CScrollView)
	self.m_YearGrid = self:NewUI(2, CGrid)
	self.m_MonthScrollView = self:NewUI(3, CScrollView)
	self.m_MonthGrid = self:NewUI(4, CGrid)
	self.m_DayScrollView = self:NewUI(5, CScrollView)
	self.m_DayGrid = self:NewUI(6, CGrid)
	self.m_Label = self:NewUI(7, CLabel)
	self.m_Label:SetActive(false)
	self.m_Data = {
		year = 2017,
		month = 1,
		day = 1,
	}
	self:InitScrollView()
	--self:ScrollTargetLevel(2017, 9, 8)
end

function CBirthPopupBox.GetBirthDay(self)
	return self.m_Data
end

function CBirthPopupBox.InitScrollView(self)
	self.m_YearGrid:Clear()
	for i = 1900, 2050 do
		local label = self.m_Label:Clone()
		label:SetActive(true)
		label:SetName(tostring(i))
		label:SetText(i)
		label:SetActive(true)
		self.m_YearGrid:AddChild(label)
	end
	self.m_YearScrollView:ResetPosition()
	self.m_YearScrollView:InitCenterOnCompnent(self.m_YearGrid, callback(self, "OnCenterChild", "year"))
	
	self.m_MonthGrid:Clear()
	for i = 1, 12 do
		local label = self.m_Label:Clone()
		label:SetActive(true)
		label:SetName(tostring(i))
		label:SetText(i)
		label:SetActive(true)
		self.m_MonthGrid:AddChild(label)
	end
	self.m_MonthScrollView:ResetPosition()
	self.m_MonthScrollView:InitCenterOnCompnent(self.m_MonthGrid, callback(self, "OnCenterChild", "month"))

	self.m_DayScrollView:ResetPosition()
	self.m_DayGrid:Clear()
	for i = 1, 30 do
		local label = self.m_Label:Clone()
		label:SetActive(true)
		label:SetName(tostring(i))
		label:SetText(i)
		label:SetActive(true)
		self.m_DayGrid:AddChild(label)
	end
	self.m_MonthScrollView:ResetPosition()
	self.m_DayScrollView:InitCenterOnCompnent(self.m_DayGrid, callback(self, "OnCenterChild", "day"))
end

function CBirthPopupBox.OnCenterChild(self, stype, scrollview, gameObject)
	local grid = self.m_YearGrid
	if stype == "month" then
		grid = self.m_MonthGrid
	elseif stype == "day" then
		grid = self.m_DayGrid
	end

	local idx = grid:GetChildIdx(gameObject.transform)
	local label = grid:GetChild(idx)
	if label then
		self.m_Data = self.m_Data or {}
		self.m_Data[stype] = tonumber(label:GetText())
	end
	self:UpdateBirthList()
	if self.m_CallBack then
		self.m_CallBack(self.m_Data)
	end
end


function CBirthPopupBox.ScrollTargetLevel(self, year, month, day)
	local _, h = self.m_YearGrid:GetCellSize()
	if month then
		local scrollPos = Vector3.New(0, h*(month - 2), 0)
		self.m_MonthScrollView:MoveRelative(scrollPos)
	end

	if year then
		self.m_YearScrollView:ResetPosition()
		local scrollPos = Vector3.New(0, h*(year - 1902), 0)
		self.m_YearScrollView:MoveRelative(scrollPos)
	end

	if day then
		local scrollPos = Vector3.New(0, h*(day - 2), 0)
		self.m_DayScrollView:MoveRelative(scrollPos)
	end

	local timer = nil
	local function update()
		if timer then
			Utils.DelTimer(timer)
		end
		if year then
			local yearobj = self.m_YearGrid:GetChild(year - 1899)
			if not Utils.IsNil(yearobj) then
				self.m_YearScrollView:CenterOn(yearobj.m_Transform)
			end
		end
		if month then
			local monthobj = self.m_MonthGrid:GetChild(month)
			if not Utils.IsNil(monthobj) then
				self.m_MonthScrollView:CenterOn(monthobj.m_Transform)
			end
		end
		if day then
			local dayobj = self.m_DayGrid:GetChild(day)
			if not Utils.IsNil(dayobj) then
				self.m_DayScrollView:CenterOn(dayobj.m_Transform)
			end
		end
		return false
	end
	timer = Utils.AddTimer(update, 0.1, 0.2)
end

function CBirthPopupBox.UpdateBirthList(self)
	local year = self.m_Data["year"]
	local month = self.m_Data["month"]
	
	local m4 = year%4
	local m100 = year%100
	local m400 = year%400
	local isrun = false
	if m4 == 0 and (m100 ~= 0 or m400 == 0) then
		isrun = true
	end
	local month2day = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	if isrun then
		month2day[2] = 29
	end
	local iDay = month2day[month]
	local amount = self.m_DayGrid:GetCount()
	if amount < iDay then
		for i = amount+1, iDay do
			local label = self.m_Label:Clone()
			label:SetText(tostring(i))
			label:SetActive(true)
			self.m_DayGrid:AddChild(label)
		end

	elseif amount > iDay then
		local delList = {}
		for i = iDay + 1, amount do
			local obj = self.m_DayGrid:GetChild(i)
			table.insert(delList, obj)
		end
		for _, delObj in ipairs(delList) do
			self.m_DayGrid:RemoveChild(delObj)
		end
		if self.m_Data["day"] > iDay then
			self:ScrollTargetLevel(nil, nil, iDay)
		end
	end
end

function CBirthPopupBox.SetCallBack(self, cb)
	self.m_CallBack = cb
end

return CBirthPopupBox