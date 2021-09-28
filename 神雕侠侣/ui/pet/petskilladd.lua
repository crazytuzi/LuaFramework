require "ui.dialog"
require "utils.log"
require "ui.pet.petskillbookcell"
PetSkillAdd = {}
setmetatable(PetSkillAdd, Dialog)
PetSkillAdd.__index = PetSkillAdd
function PetSkillAdd:SetBookSelected(wnd, bSelected)
	if not bSelected then
		wnd:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	else
		wnd:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end
end

local _instance
function PetSkillAdd.getSingleton()
	return _instance
end

function PetSkillAdd.getSingletonDialog(itemevent, x)
	if _instance == nil then
		_instance = PetSkillAdd.new(itemevent, x)
	end
	return _instance
end
function PetSkillAdd.getSingletonDialogAndShow(itemevent, x)
	if _instance == nil then
		_instance = PetSkillAdd.new(itemevent, x)
	else
		if not _instance:IsVisible() then
			_instance:SetVisible(true)
		end
	end

	return _instance
end

function PetSkillAdd.new(itemevent, x)
	local t = {}
	setmetatable(t, PetSkillAdd)
	t.__index = PetSkillAdd
	t.booktype = 0x31
	t.MultiSelectedMode = false
	t:OnCreate(itemevent, x)
	t:GetWindow():setAlwaysOnTop(true)
	return t
end

function PetSkillAdd:OnCreate(itemevent, x)
	LogInsane("PetSkillAdd:OnCreate")
	Dialog.OnCreate(self)
	self:InitUI()
	self:InitBooks()
	self:InitEvent(itemevent, x)
end
--------- ui ---
function PetSkillAdd:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.BookItems = {}
	--[[
	for i = 1, 4 do
		self.BookItems[i] = {}
		local bookitem = self.BookItems[i]
		local uiindex = i - 1
		bookitem.Frame = winMgr:getWindow("petskilladd/main/book"..uiindex)
		bookitem.Item = CEGUI.toItemCell(winMgr:getWindow("petskilladd/main/item"..uiindex))
		bookitem.Name = winMgr:getWindow("petskilladd/main/name"..uiindex)
	end
	self.PrevPage = CEGUI.toPushButton(winMgr:getWindow("petskilladd/main/up"))
	self.NextPage = CEGUI.toPushButton(winMgr:getWindow("petskilladd/main/down"))
	--]]
	self.BookPane = CEGUI.toScrollablePane(winMgr:getWindow("petskilladd/main/scroll"))
	self.OkButton = CEGUI.toPushButton(winMgr:getWindow("petskilladd/ok"))
	self.CancelButton = CEGUI.toPushButton(winMgr:getWindow("petskilladd/cancel"))
end

function PetSkillAdd:InitBooks()
	self:RefreshBook()
	for i = 0, self.Books:size() - 1 do
		local index = i + 1
		self.BookItems[index] = PetSkillBookCell.new(self.BookPane)
		local height = self.BookItems[index].m_pMainFrame:getHeight():asAbsolute(0)
		local offset = height * i or 1	
		self.BookItems[index].m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
		
		local itemkey = self.Books[i]
		local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
		if item ~= nil then
			self.BookItems[index].Item:SetImage(GetIconManager():GetItemIconByID(item:GetBaseObject().icon))
			self.BookItems[index].Name:setText(item:GetBaseObject().name)
			local color = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
			self.BookItems[index].Name:setProperty("TextColours", color)
			self.BookItems[index].Item:setID(item:GetThisID())
		end
	end
--	self:ShowPage(1)
end

function PetSkillAdd.OnItemNumChange(bagid, itemkey, itembaseid)
	if not _instance then
		return
	end
	local self = _instance
	if bagid ~= knight.gsp.item.BagTypes.BAG then
		return
	end
	for i = 1, #self.BookItems do
		local bookitem = self.BookItems[i]
		if bookitem.Item:getID() == itemkey then
			local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
			if not item then
				bookitem:SetVisible(false)
				local curYpos = bookitem.m_pMainFrame:getYPosition().offset
				for j = i + 1, #self.BookItems do
					local tempYpos = self.BookItems[j].m_pMainFrame:getYPosition().offset
					self.BookItems[j].m_pMainFrame:setYPosition(CEGUI.UDim(0, curYpos))
					curYpos = tempYpos
				end
				table.remove(self.BookItems, i)
			end
			break
		end
	end
end
--[[
function PetSkillAdd:ShowPage(page)
	local booknum = self.Books:size()
	local maxpage
	if booknum ~= 0 then
	 	maxpage = math.floor((booknum - 1)  / 4) + 1
	else
		maxpage = 1
	end
	if page ~= nil then self.showingPage = page end
	if self.showingPage == nil then self.showingPage = 1 end
	if self.showingPage <= 0 then self.showingPage = 1 end
	if self.showingPage > maxpage then self.showingPage = maxpage end
	local showingbase = (self.showingPage-1)*4
	for i = 1, 4 do
		if i + showingbase <= booknum then
			local item = GetRoleItemManager():FindItemByBagAndThisID(self.Books[showingbase + i - 1], knight.gsp.item.BagTypes.BAG)
			if item ~= nil then
				self.BookItems[i].Item:SetImage(GetIconManager():GetItemIconByID(item:GetBaseObject().icon))
				self.BookItems[i].Name:setText(item:GetBaseObject().name)
				local color = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
				self.BookItems[i].Name:setProperty("TextColours", color)
				self.BookItems[i].Item:setID(item:GetThisID())
			else
				self.BookItems[i].Item:SetImage(nil)
				self.BookItems[i].Name:setText("")
				self.BookItems[i].Item:setID(0)
			end
		else
			self.BookItems[i].Item:SetImage(nil)
			self.BookItems[i].Name:setText("")
			self.BookItems[i].Item:setID(0)
		end
	end
end
--]]
------------- event ---
function PetSkillAdd:InitEvent(itemevent, x)
	for i = 1, #self.BookItems do
		local bookitem = self.BookItems[i]
		if itemevent == nil then
			itemevent = PetSkillAdd.HandleItemSelected
			x = self
		end
		LogInsane(string.format("Skillbook window %s subscriber event ", bookitem.Frame:getName()))
		bookitem.Frame:subscribeEvent("MouseClick", itemevent, x)
		bookitem.Item:subscribeEvent("MouseClick", itemevent, x)
	end
--	self.PrevPage:subscribeEvent("MouseClick", PetSkillAdd.HandlePreviousPage, self)
--	self.NextPage:subscribeEvent("MouseClick", PetSkillAdd.HandleNextPage, self)
	self.OkButton:subscribeEvent("MouseClick", PetSkillAdd.HandleOkBtnClicked, self)
	self.CancelButton:subscribeEvent("MouseClick", PetSkillAdd.HandleCancelBtnClicked, self)
    self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(PetSkillAdd.OnItemNumChange)
end

function PetSkillAdd:HandleItemSelected(e)
	LogInsane("PetSkillAdd:HandleItemSelected")
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.BookItems do
		if self.BookItems[i].Frame == mouseArgs.window or self.BookItems[i].Item == mouseArgs.window then
			if self.BookItems[i].Item:getID() ~= 0 then
				if self.SelectedItem then
					self:SetBookSelected(self.SelectedItem.Frame, false)
				end
				self.SelectedItem = self.BookItems[i]
				self:SetBookSelected(self.SelectedItem.Frame, true)
			end
			break
		end
	end
	return true
end
--[[
function PetSkillAdd:HandlePreviousPage(e)
	if self.showingPage == nil and self.showingPage <= 1 then
		return true
	end
	self:ShowPage(self.showingPage - 1)
end

function PetSkillAdd:HandleNextPage(e)
	if self.showingPage == nil then
		return true
	end
	self:ShowPage(self.showingPage + 1)
end
--]]
function PetSkillAdd:HandleOkBtnClicked(e)
	if self.SelectedItem == nil then
		LogInsane("choose a book please")
		return true
	end
	LogInsane("choose book key="..self.SelectedItem.Item:getID())
	local bookkey = self.SelectedItem.Item:getID()
	GetNetConnection():send(knight.gsp.pet.CPetLearnSkillByBook(self.petKey, bookkey))
	self:DestroyDialog()
end

function PetSkillAdd:HandleCancelBtnClicked(e)
	self:DestroyDialog()
	return true
end
---------- event end ---
----- update data ----
function PetSkillAdd:RefreshBook()
	if self.Books == nil then
		self.Books = std.vector_int_()
	else
		self.Books:clear()
	end
	GetRoleItemManager():GetItemKeyListByType(self.Books, self.booktype)
end
--end---
--
function PetSkillAdd:DestroyDialog()
	LogInsane("destory PetSkillAdd dialog")
	if self == _instance then
		self:OnClose()
        GetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
		_instance = nil
	else
		LogInsane("Something class instance?")
	end
end
					 
function PetSkillAdd:GetLayoutFileName()
	LogInsane("PetSkillAdd:GetLayoutFileName")
	return "petskilladd.layout"
end

function PetSkillAdd:SetPetkey(petkey)
	self.petKey = petkey
end

return PetSkillAdd
