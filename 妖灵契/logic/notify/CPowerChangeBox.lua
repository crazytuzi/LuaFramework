local CPowerChangeBox = class("CPowerChangeBox", CBox)

function CPowerChangeBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BgSpr = self:NewUI(1, CSprite)
	self.m_NumberBox = self:NewUI(2, CBox)
	self.m_BaseGrid = self:NewUI(3, CGrid)
	self.m_OffsetGrid = self:NewUI(4, CGrid)
	self.m_CompareBox = self:NewUI(5, CBox)
	self.m_BaseWidget = self:NewUI(6, CBox)
	self.m_OffsetWidget = self:NewUI(7, CBox)
	self.m_DownSpr = self:NewUI(8, CSprite)
	self.m_UpSpr = self:NewUI(9, CSprite)
	self.m_IsUp = nil
	self.m_UpdateTimer = nil
	self.m_FadeOutTimer = nil
	self.m_NumberBox:SetActive(false)
	self.m_BaseNumList = {}
	self.m_OffSetList = {}
	self.m_CellWith, self.m_CellHeight = self.m_BaseGrid:GetCellSize()
	self:SetWidgetActive(false)
end

function CPowerChangeBox.ShowPowerChange(self, from, to)
	if from == to or (from + to > 1000000) then
		self:SetWidgetActive(false)
		return
	end
	self:SetWidgetActive(true)
	if self.m_UpdateTimer then
		Utils.DelTimer(self.m_UpdateTimer)
		self.m_UpdateTimer = nil
	end
	if self.m_FadeOutTimer then
		Utils.DelTimer(self.m_FadeOutTimer)
		self.m_FadeOutTimer = nil
	end
	self.m_IsUp = to > from
	local fromArr = self:GetNumArr(from)
	local toArr = self:GetNumArr(to)
	local offsetArr = self:GetNumArr(math.abs(to-from))
	self:InitGrid((#fromArr > #toArr) and #fromArr or #toArr, #offsetArr)
	self.m_DownSpr:SetActive(not self.m_IsUp)
	self.m_UpSpr:SetActive(self.m_IsUp)
	if self.m_IsUp then
		--属性变化速度
		local converFrom = from
		local converTo = to
		local AttrChangeSpeed = math.floor(to - from)
		self:SetNumText(self.m_OffSetList, offsetArr, 2)		
		local function wrap(dt)
			local temp = dt * AttrChangeSpeed
			if temp	< 1 then
				temp = 1
			end		
			converFrom = math.floor(converFrom + temp)					
			if converFrom > converTo then
				converFrom = converTo									
			end
			local arr = self:GetNumArr(converFrom)						
			self:SetNumText(self.m_BaseNumList, arr, 1, true)
			if converFrom == converTo then
				self:FadeOut()
				return false
			end				
			return true
		end
		self.m_UpdateTimer = Utils.AddTimer(wrap, 0, 0)	
	else
		--属性变化速度
		local converFrom = from
		local converTo = to
		local AttrChangeSpeed = math.floor(from - to)
		self:SetNumText(self.m_OffSetList, offsetArr, 3)		
		local function wrap(dt)
			local temp = dt * AttrChangeSpeed
			if temp	< 1 then
				temp = 1
			end				
			converFrom = math.floor(converFrom - temp)					
			if converFrom < converTo then
				converFrom = converTo									
			end
			local arr = self:GetNumArr(converFrom)						
			self:SetNumText(self.m_BaseNumList, arr, 1, true)
			if converFrom == converTo then
				self:FadeOut()
				return false
			end				
			return true
		end
		self.m_UpdateTimer = Utils.AddTimer(wrap, 0, 0)	
	end			
end

function CPowerChangeBox.GetNumArr(self, num)
	if not num or type(num) ~= "number" or num == 0 then
		return {0}
	end
	local t = {}
	if num > 0 then
		repeat
			local temp = num % 10
			table.insert(t, temp)
			num = math.floor(num / 10)
		until num <= 0
	end
	local d = {}
	for i = #t, 1, -1 do
		table.insert(d, t[i])
	end
	return d
end

function CPowerChangeBox.InitGrid(self, base, offset)
	if base > #self.m_BaseNumList then
		for i = 1, base - #self.m_BaseNumList do
			local oBox = self.m_NumberBox:Clone()
			oBox.m_NumSpr = oBox:NewUI(1, CSprite)
			self.m_BaseGrid:AddChild(oBox)
			table.insert(self.m_BaseNumList, oBox) 
		end
	end
	for i, v in ipairs(self.m_BaseNumList) do
		v:SetActive(false)
	end

	if offset > #self.m_OffSetList then
		for i = 1, base - #self.m_OffSetList do
			local oBox = self.m_NumberBox:Clone()
			oBox.m_NumSpr = oBox:NewUI(1, CSprite)
			self.m_OffsetGrid:AddChild(oBox)
			table.insert(self.m_OffSetList, oBox) 
		end
	end
	for i, v in ipairs(self.m_OffSetList) do
		v:SetActive(false)
	end	
end

function CPowerChangeBox.SetNumText(self, list, arr, mode, isBase)
	if not list or not next(list) or not arr or not next(arr) then
		return
	end
	for i, v in ipairs(list) do
		if arr[i] then
			v:SetActive(true)
			self:SetNum(v, arr[i], mode)		
		else
			v:SetActive(false)
		end
	end
	if isBase then
		self:SetPos(#arr)
	end
end

function CPowerChangeBox.SetPos(self, pos)
	local w, _ = self.m_BaseGrid:GetCellSize()
	self.m_CompareBox:SetLocalPos(Vector3.New(-90 + pos * self.m_CellWith, -4, 0))
	self.m_OffsetWidget:SetLocalPos(Vector3.New(-60 + pos * self.m_CellWith, -4, 0))
end

function CPowerChangeBox.SetNum(self, oBox, num, mode)
	if oBox and oBox.m_NumSpr then
		if mode == 1 then	
			oBox.m_NumSpr:SetSpriteName(string.format("text_normal_%d", num))
		elseif mode == 2 then
			oBox.m_NumSpr:SetSpriteName(string.format("text_up_%d", num))
		else
			oBox.m_NumSpr:SetSpriteName(string.format("text_down_%d", num))
		end
	end
end

function CPowerChangeBox.SetWidgetActive(self, b)
	self.m_BaseWidget:SetActive(b)
	self.m_OffsetWidget:SetActive(b)
	self.m_CompareBox:SetActive(b)
end

function CPowerChangeBox.FadeOut(self)
	local cb = function ()
		self:SetWidgetActive(false)
	end
	self.m_FadeOutTimer = Utils.AddTimer(cb, 0, 1.5)
end

return CPowerChangeBox

