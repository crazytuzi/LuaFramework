local CMapBookCtrl = class("CMapBookCtrl", CCtrlBase)

define.MapBook = {
	Event = {
		UpdateWorldMap = 100,
		UpdatePartnerBook = 101,
		UpdateEquipBook = 102,
		UpdateRedPoint = 103,
	}
}

function CMapBookCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CMapBookCtrl.ResetCtrl(self)
	self:InitWorldCity()
	self:InitBookList({})
	self:InitRedPoint({})
	self.m_PartnerProgress = 0
	self.m_EquipProgress = 0
end

function CMapBookCtrl.LoginInit(self)
	
end

function CMapBookCtrl.InitWorldCity(self)
	self.m_WorldDict = {}
	self.m_City2Part = {}
	self.m_CityList = {}
	for _, oData in ipairs(data.mapbookdata.WORLDMAP) do
		self.m_City2Part[oData.building] = self.m_City2Part[oData.building] or {}
		table.insert(self.m_City2Part[oData.building], oData)
		if not table.index(self.m_CityList, oData.building) then
			table.insert(self.m_CityList, oData.building)
		end
	end
	table.sort(self.m_CityList)
end

function CMapBookCtrl.SetWorldOpen(self, iOpen)
	self.m_WorldOpen = iOpen
end

function CMapBookCtrl.GetWorldOpen(self)
	return self.m_WorldOpen
end

function CMapBookCtrl.InitWorldData(self, worldList)
	for _, oData in ipairs(worldList) do
		self.m_WorldDict[oData.id] = oData
	end
	self.m_InitWorldData = true
	self.m_WordAward = false
end

function CMapBookCtrl.UpdateWorldData(self, oData)
	self.m_WorldDict[oData.id] = oData
	self:OnEvent(define.MapBook.Event.UpdateRedPoint, oData)
	self:OnEvent(define.MapBook.Event.UpdateWorldMap, oData)
end

function CMapBookCtrl.IsCityWard(self, iCity)
	local partdata = g_MapBookCtrl:GetCityPart(iCity)
	if not partdata then
		return false
	end
	local flag =true
	local iEventID = nil
	for i = 1, 3 do
		if partdata[i] then
			local sdata = g_MapBookCtrl:GetWorldData(partdata[i].id)
			if sdata["done"] == 1 then
				return true
			end
		end
	end
	return false
end

function CMapBookCtrl.IsCityPartWard(self, iPart)
	local sdata = g_MapBookCtrl:GetWorldData(iPart)
	if sdata["done"] == 1 then
		return true
	end
	return false
end

function CMapBookCtrl.UpdateWorldRedDot(self)
	local oView = CWorldMapBookView:GetView()
	if oView and oView:GetActive() then
		return
	end
	self.m_WordAward = true
	self:OnEvent(define.MapBook.Event.UpdateRedPoint, nil)
end

function CMapBookCtrl.IsOpen(self)
	return g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.mapbook.open_grade
end

function CMapBookCtrl.IsHasAward(self)
	if not self:IsOpen() then
		return false
	end
	
	if self:IsHasWorldMapAward() then
		return true
	end
	if self:IsHasPartnerBookNotify() then
		return true
	end
	if self:IsHasLostBookNotify() then
		return true
	end
	if self:IsHasPersonBookNotify() then
		return true
	end
	return false
end

function CMapBookCtrl.IsHasWorldMapAward(self)
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.worldbook.open_grade then
		return false
	end
	
	local bAward = false
	for id, t in pairs(self.m_WorldDict) do
		if t["done"] == 1 then
			bAward = true
			break
		end
	end
	if self.m_WordAward then
		return true
	end
	return bAward
end

function CMapBookCtrl.GetWorldData(self, id)
	if self.m_WorldDict[id] then
		return self.m_WorldDict[id]
	else
		local t = {
			id = id,
			done = 0,
			cur = {},
		}
		return t
	end
end

function CMapBookCtrl.GetCityPart(self, iCity)
	return self.m_City2Part[iCity]
end

function CMapBookCtrl.GetCityList(self)
	return self.m_CityList
end


--符文佚书，人物传记相关
function CMapBookCtrl.InitBookList(self, bookList)
	self.m_EquipBookList = {}
	self.m_PartnerBookList = {}
	self.m_PersonBookList = {}
	for id, oBook in pairs(data.mapbookdata.PARTNER) do
		local t = self:GetDefaultBook()
		table.update(t, oBook)
		self.m_PartnerBookList[id] = t
	end

	for id, oBook in pairs(data.mapbookdata.PARTNEREQUIP) do
		local t = self:GetDefaultBook()
		table.update(t, oBook)
		self.m_EquipBookList[id] = t
	end

	for id, oBook in pairs(data.mapbookdata.PERSON) do
		local t = self:GetDefaultBook()
		table.update(t, oBook)
		self.m_PersonBookList[id] = t
	end

	for _, oBook in ipairs(bookList) do
		if self.m_PartnerBookList[oBook.id] then 
			table.update(self.m_PartnerBookList[oBook.id], oBook)

		elseif self.m_EquipBookList[oBook.id] then
			table.update(self.m_EquipBookList[oBook.id], oBook)

		elseif self.m_PersonBookList[oBook.id] then
			local oldBook = self.m_PersonBookList[oBook.id]
			table.update(self.m_PersonBookList[oBook.id], oBook)
			self.m_PersonBookList[oBook.id].fight = oldBook.fight
			self.m_PersonBookList[oBook.id].total = oldBook.total
			self.m_PersonBookList[oBook.id].rewards = oldBook.rewards
		end
	end
end

function CMapBookCtrl.InitRedPoint(self, pointList)
	self.m_RedPoint = {}
	for _, bookRedPoint in ipairs(pointList) do
		self.m_RedPoint[bookRedPoint.book_type] = bookRedPoint.red_point
	end
end

function CMapBookCtrl.GetDefaultBook(self)
	local t = {
		show = 0,
		entry_name = 0,
		repair = 0,
		unlock = 0,
		progress = 0,
		condition = {},
		chapter = {},
		red_point = 0,
	}
	return t
end

function CMapBookCtrl.GetEquipBookList(self)
	local keys = table.keys(self.m_EquipBookList)
	table.sort(keys)
	local bookList = {}
	for _, id in ipairs(keys) do
		if self.m_EquipBookList[id]["show"] == 1 then
			table.insert(bookList, self.m_EquipBookList[id])
		end
	end
	return bookList
end

function CMapBookCtrl.GetPartnerBookList(self)
	local keys = table.keys(self.m_PartnerBookList)
	table.sort(keys)
	local bookList = {}
	for _, id in ipairs(keys) do
		table.insert(bookList, self.m_PartnerBookList[id])
	end
	return bookList
end

function CMapBookCtrl.GetPersonBookList(self)
	local keys = table.keys(self.m_PersonBookList)
	table.sort(keys)
	local bookList = {}
	for _, id in ipairs(keys) do
		table.insert(bookList, self.m_PersonBookList[id])
	end
	return bookList
end

function CMapBookCtrl.UpdateBook(self, oBook)
	if self.m_PartnerBookList[oBook.id] then
		local t = self:GetDefaultBook()
		table.update(t, oBook)
		oBook = t
		table.update(oBook, data.mapbookdata.PARTNER[oBook.id])
		self.m_PartnerBookList[oBook.id] = oBook
		self:OnEvent(define.MapBook.Event.UpdatePartnerBook, oBook)
	
	elseif self.m_EquipBookList[oBook.id] then
		local t = self:GetDefaultBook()
		table.update(t, oBook)
		oBook = t
		table.update(oBook, data.mapbookdata.PARTNEREQUIP[oBook.id])
		self.m_EquipBookList[oBook.id] = oBook
		self:OnEvent(define.MapBook.Event.UpdateEquipBook, oBook)
	
	elseif self.m_PersonBookList[oBook.id] then
		local oldBook = self.m_PersonBookList[oBook.id]
		local t = self:GetDefaultBook()
		table.update(t, oBook)
		oBook = t
		table.update(oBook, data.mapbookdata.PERSON[oBook.id])
		oBook.fight = oldBook.fight
		oBook.total = oldBook.total
		oBook.rewards = oldBook.rewards
		self.m_PersonBookList[oBook.id] = oBook
		self:OnEvent(define.MapBook.Event.UpdateEquipBook, oBook)
	end
end

function CMapBookCtrl.UpdatePartnerProgress(self, iProgress)
	self.m_PartnerProgress = iProgress
end

function CMapBookCtrl.UpdateEquipProgress(self, iProgress)
	self.m_EquipProgress = iProgress
end

function CMapBookCtrl.UpdateNpcInfo(self, infoList)
	for _, info in ipairs(infoList) do
		for k, v in pairs(self.m_PersonBookList) do
			if v.target_id == info.npc_type then
				v.fight = info.fight
				v.total = info.total
				v.rewards = info.rewards
				break
			end
		end
	end
end

function CMapBookCtrl.UpdateRedPoint(self, bookRedPoint)
	self.m_RedPoint[bookRedPoint.book_type] = bookRedPoint.red_point
	self:OnEvent(define.MapBook.Event.UpdateRedPoint, bookRedPoint)
end

function CMapBookCtrl.IsHasLostBookNotify(self)
	return false
end

function CMapBookCtrl.IsHasPartnerBookNotify(self)
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.partnerbook.open_grade then
		return false
	end
	return self.m_RedPoint[1] == 1
end

function CMapBookCtrl.IsHasPersonBookNotify(self)
	if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.personbook.open_grade then
		return false
	end
	return self.m_RedPoint[3] == 1
end

function CMapBookCtrl.OnClickMenu(self, iType)
	if self.m_RedPoint[iType] == 1 then
		nethandbook.C2GSCloseHandBookUI(iType)
	end
end

function CMapBookCtrl.OnClickBook(self, bookData)
	if bookData.red_point > 0 then
		nethandbook.C2GSOpenBookChapter(bookData.id)
	end
end

return CMapBookCtrl