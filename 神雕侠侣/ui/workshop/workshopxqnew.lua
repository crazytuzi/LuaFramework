require "ui.dialog"
require "ui.workshop.workshophelper"
require "ui.workshop.workshopequipcell"
require "utils.mhsdutils"
require "utils.stringbuilder"
WorkshopXqNew = {
}
local GemTypeID = 0x5
local FUNCTION_INDEX = 1
local BAG_INDEX = 2
local STONE_INDEX = 3
setmetatable(WorkshopXqNew, Dialog)
WorkshopXqNew.__index = WorkshopXqNew
local _instance
function WorkshopXqNew.getInstance()
	if _instance == nil then
		_instance = WorkshopXqNew:new()
		_instance:OnCreate()
	end
	return _instance
end

local function IsGemMatchItem(gemid, itemid)
	--local gemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(gemid)
	local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemid)
	if itemattr == -1 then
		return false
	end
	local gemconfig = knight.gsp.item.GetCGemEffectTableInstance():getRecorder(gemid)
	if gemconfig.id == -1 then
		return false
	end
	local itemtype = itemattr.itemtypeid
	
	local itemsecondtype = math.floor(itemtype/0x10)%0x10
	LogInsane("itemtype ="..itemtype..", secondtype="..itemsecondtype)
	local matchnum = gemconfig.equiptype:size()
	for i = 1, matchnum do
		LogInsane(string.format("gemid=%d match type=%d, itemtype=%d", gemid, gemconfig.equiptype[i-1], itemsecondtype))
		if gemconfig.equiptype[i-1] == itemsecondtype then
			return true
		end
	end
	return false
end

function WorkshopXqNew.getInstanceOrNot()
	return _instance
end

function WorkshopXqNew:new()
	LogInsane("new WorkshopXqNew Instance")
	local self = {}
	self = Dialog:new()
	setmetatable(self, WorkshopXqNew)
	self.m_LinkLabel = nil
	self.XqProgressing = false
	self.XqItems = {}
	self.ShowPane = {}
	self.GemCells = {}
	self.BagGemLines = {}
	self.clickedbaggem = nil
	self.clickcell = nil
    self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopXqNew.OnItemNumberChange)
	return self
end
------------------ UI create -----------
function WorkshopXqNew:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.EffectWnd = winMgr:getWindow("workshopxqnew/effect")
	self.ItemPane = CEGUI.toScrollablePane(winMgr:getWindow("workshopxqnew/left/list"))
	self.GemPane = CEGUI.toScrollablePane(winMgr:getWindow("workshopxqnew/left/info/scroll"))
	self:InitGems()
	self:InitEquipItems()
	self.ShowPane[1] = {}
	self.ShowPane[1].Container = winMgr:getWindow("workshopxqnew/right/info")
	self.ShowPane[2] = {}
	self.ShowPane[2].Container = winMgr:getWindow("workshopxqnew/right/stoneback")
	self.ShowPane[2].BagGems = CEGUI.toScrollablePane(winMgr:getWindow("workshopxqnew/right/stoneback/main"))
	self.ShowPane[2].XqButton = CEGUI.toPushButton(winMgr:getWindow("workshopxqnew/right/stoneback/ok"))
	self.ShowPane[2].XqButton:subscribeEvent("MouseClick", self.HandleXqBtnClicked, self)
	self.ShowPane[3] = {}
	self.ShowPane[3].Container = winMgr:getWindow("workshopxqnew/right/check")
	self.ShowPane[3].Item = CEGUI.toItemCell(winMgr:getWindow("workshopxqnew/right/check/item"))
	self.ShowPane[3].Name = winMgr:getWindow("workshopxqnew/right/check/name")
	self.ShowPane[3].Describe = winMgr:getWindow("workshopxqnew/right/check/name1")
	self.ShowPane[3].Usage = winMgr:getWindow("workshopxqnew/right/check/name2")
	self.ShowPane[3].UnxqButton = CEGUI.toPushButton(winMgr:getWindow("workshopxqnew/right/check/get"))
	self.ShowPane[3].UnxqButton:subscribeEvent("MouseClick", self.HandleUnxqBtnClicked, self)
	self:ShowTab(FUNCTION_INDEX)
	
	for i = 1, #self.XqItems do
		if self.XqItems[i].Item:getID() ~= 0 then
			self:SetItemSelected(knight.gsp.item.BagTypes.EQUIP, self.XqItems[i].Item:getID())
			break
		end
	end
	self:RefreshCanXqEffect()
end

function WorkshopXqNew.OnItemNumberChange(bagid, itemkey, itembaseid)
	LogInsane(string.format("bagid=%d, itemkey=%d, itembaseid=%d", bagid, itemkey, itembaseid))
	if _instance == nil then 
		return
	end
	if _instance.clickcell == nil then
		return
	end
	_instance:ShowTab(BAG_INDEX)
	_instance:ShowBagGems()
	_instance:RefreshCanXqEffect()
end

function WorkshopXqNew:RefreshCanXqEffect()
	local clickeditem = self.clickedwindow and GetRoleItemManager():FindItemByBagAndThisID(self.clickedwindow:getID(), knight.gsp.item.BagTypes.EQUIP)
		or nil
	for i = 1, #self.XqItems do
		if self.XqItems[i].Item:getID() ~= 0 then
			local item = GetRoleItemManager():FindItemByBagAndThisID(self.XqItems[i].Item:getID(), knight.gsp.item.BagTypes.EQUIP)
			if self:CanItemXq(item) then
				if not self.XqItems[i].HasEffect then
					GetGameUIManager():AddUIEffect(self.XqItems[i].Mark, MHSD_UTILS.get_effectpath(10377), true)
				end
				self.XqItems[i].HasEffect = true
				if clickeditem and item == clickeditem then
					if self:IsTabVisible(STONE_INDEX) then
						self:ShowTab(BAG_INDEX)
					end
				end
			else
				if self.XqItems[i].HasEffect then
					GetGameUIManager():RemoveUIEffect(self.XqItems[i].Mark)
				end
				self.XqItems[i].HasEffect = false
				if clickeditem and item == clickeditem then
					if self:IsTabVisible(BAG_INDEX) then
						self:ShowTab(FUNCTION_INDEX)
					end
				end
			end
		end
	end
end

function WorkshopXqNew:CanItemXq(item)
	if item == nil then
		return false
	end
	local equipObj = toEquipObject(item:GetObject())
	if equipObj == nil then
		return false
	end
	local gemlist = std.vector_int_()
	equipObj:GetGemlist(gemlist)
	local gemsize = gemlist:size()
	local canXqNum = #self.GemCells
	if gemsize >= canXqNum then
		return false
	end

	local rolelevel = GetDataManager():GetMainCharacterLevel()
	local tbl = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cbaoshixiangqian")
	equipObj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, item:GetThisID())
	local blesslv = 0
	if equipObj then 
		blesslv = equipObj.blesslv 
	end
	local holeNum = 0
	for i=1,canXqNum do
		local cfg = tbl:getRecorder(i)
		if rolelevel >= cfg.needplayerlv and blesslv >= cfg.needblesslv then
			holeNum = i
		else
			break
		end
	end
	canXqNum = holeNum
	if gemsize >= canXqNum then
		return false
	end
	local itemid = item:GetBaseObject().id
	local gemkeys = std.vector_int_()
	GetRoleItemManager():GetItemKeyListByType(gemkeys, GemTypeID)
	if gemkeys:size() <= 0 then
		return false
	end
	for i = 0, gemkeys:size() - 1 do
		local baggem = GetRoleItemManager():FindItemByBagAndThisID(gemkeys[i], knight.gsp.item.BagTypes.BAG)
		if IsGemMatchItem(baggem:GetBaseObject().id, itemid) then
			return true
		end
	end
	return false
end

function WorkshopXqNew:OnEffectEnd()
	if _instance == nil then
		return
	end
	_instance.XqProgressing = false
	if _instance.clickedwindow == nil then
		return
	end
	if _instance.clickedbaggem == nil then
		return
	end
	LogInsane("Send CAddGemToEquip protocol")
	local item = GetRoleItemManager():FindItemByBagAndThisID(_instance.clickedwindow:getID(), knight.gsp.item.BagTypes.EQUIP)
	local baggem = GetRoleItemManager():FindItemByBagAndThisID(_instance.clickedbaggem:getID(), knight.gsp.item.BagTypes.BAG)
	if item == nil or baggem == nil then
		return
	end
	local send = knight.gsp.item.CAddGemToEquip(item:GetThisID(),1,baggem:GetThisID())
    GetNetConnection():send(send)
end

function WorkshopXqNew:HandleXqBtnClicked(e)
	if self.XqProgressing or self.m_waitGemEffect then
		return false
	end
	if self.clickedwindow == nil then
		return
	end
	if self.clickedbaggem == nil then
		return
	end
	
	local pEffect = GetGameUIManager():AddUIEffect(self.EffectWnd, MHSD_UTILS.get_effectpath(10176), false);
    if pEffect then
    	print("Add qh effect notify")
    	local notify = CGameUImanager:createNotify(self.OnEffectEnd)
       pEffect:AddNotify(notify);
    	self.XqProgressing = true
    end
end

function WorkshopXqNew:HandleUnxqBtnClicked(e)
	LogInsane("WorkshopXqNew:HandleUnxqBtnClicked")
	if self.clickedwindow == nil then
		return true
	end
	if self.clickedwindow:getID() == 0 then
		return true
	end
	if self.clickcell == nil then
		return true
	end
	if self.clickcell.GemIndexInEquip == -1 then
		return true
	end
	local send = knight.gsp.item.CRemoveGemFromEquip(self.clickedwindow:getID(), 1, self.clickcell.GemIndexInEquip)
	GetNetConnection():send(send)
	return true
end

function WorkshopXqNew:IsTabVisible(type)
	return self.ShowPane[type] and 
		   self.ShowPane[type].Container and 
		   self.ShowPane[type].Container:isVisible()
end

function WorkshopXqNew:ShowTab(type)
	local infopane = nil
	for i = 1, #self.ShowPane do
		if type == i then
			infopane = self.ShowPane[i]
			self.ShowPane[i].Container:setVisible(true)
		else
			self.ShowPane[i].Container:setVisible(false)
		end
	end
	if infopane == nil then
		return
	end
end

-------for equipcell ----
local function NewGem(parent, n)
	local newCell = {}
	setmetatable(newCell, Dialog)
	newCell.__index = newCell
	function newCell.GetLayoutFileName()
		return "workshopxqbookcell.layout"
	end
	LogInsane("try create workshopxqbookcell")
	Dialog.OnCreate(newCell, parent, n)
	local winMgr = CEGUI.WindowManager:getSingleton()
	newCell.Item = CEGUI.toItemCell(winMgr:getWindow(n.."workshopxqbookcell/item"))
	newCell.Name = winMgr:getWindow(n.."workshopxqbookcell/name")
	newCell.Text = winMgr:getWindow(n.."workshopxqbookcell/level")
	newCell.Lock = winMgr:getWindow(n.."workshopxqbookcell/lock")
	newCell.Suolian = winMgr:getWindow(n.."workshopxqbookcell/item/suolian")

	local stringformat = MHSD_UTILS.get_resstring(2752)
	local sb = StringBuilder:new()
	sb:SetNum("parameter1", 20*n)
	local showstr = sb:GetString(stringformat)
    sb:delete()
	LogInsane("showstr="..showstr)
	newCell.Lock:setText(showstr)
	newCell.Suolian:setVisible(false)
	
	local height = newCell.m_pMainFrame:getHeight():asAbsolute(0)
	local posindex = n - 1
	local offset = height * posindex or 1
	newCell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	return newCell
end

local function NewBagGem(parent, n)
	local newBagGem = {}
	setmetatable(newBagGem, Dialog)
	newBagGem.__index = newBagGem
	function newBagGem.GetLayoutFileName()
		return "workshopxqnewcell.layout"
	end
	LogInsane("try create workshopxqnewcell")
	Dialog.OnCreate(newBagGem, parent, n)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local stringformat = MHSD_UTILS.get_resstring(2752)
	--newBagGem.Items = {}
	for i = 1, 3 do
		newBagGem[i] = {}
		local idx = i - 1
		newBagGem[i].Item = CEGUI.toItemCell(winMgr:getWindow(n.."workshopxqnewcell/back/item"..idx))
		if idx == 0 then
			newBagGem[i].Name = winMgr:getWindow(n.."workshopxqnewcell/back/name")
		else
			newBagGem[i].Name = winMgr:getWindow(n.."workshopxqnewcell/back/name"..idx)
		end
		require "utils.mhsdutils".SetBagWindowShowtips(newBagGem[i].Item)
	end
	newBagGem.Frame = winMgr:getWindow(n.."workshopxqnewcell")
	local height = newBagGem.m_pMainFrame:getHeight():asAbsolute(0)
	local posindex = n - 1
	local offset = height * posindex or 1
	newBagGem.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	
	return newBagGem
end

local function GetMaxLevelGem(item)
	local maxid = 0
	local maxgemid = 0
	local maxgemlevel = 0
	local equipObj = toEquipObject(item:GetObject())
	if equipObj then
		local gemlist = std.vector_int_()
		equipObj:GetGemlist(gemlist)
		local gemsize = gemlist:size()
		for i = 1, gemsize do
			local gemid = gemlist[i - 1]
			local gemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(gemid)
			if gemattr.level > maxid then
				maxid = i
				maxgemid = gemid
				maxgemlevel = gemattr.level
			end
		end
	end
	return maxid, maxgemid, maxgemlevel
end

function WorkshopXqNew:AddEquip(n)
	local itemcell = Workshopequipcell.new(self.ItemPane, (n - 1))
	self.XqItems[n] = itemcell
	local item_info = WorkshopHelper.ItemList[n]
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local item = GetRoleItemManager():FindItemByBagIDAndPos(bagid, item_info.type)
	if item == nil then
		itemcell.Name:setText(MHSD_UTILS.get_resstring(2736)..MHSD_UTILS.get_resstring(item_info.empty_string))
		itemcell.Level:setText("")
	else
		local equipObj = toEquipObject(item:GetObject())
		if equipObj then
			if item:GetObject().bNeedRequireData then
				GetNetConnection():send(knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, item:GetThisID()))
			end
		end
			
		local iconManager = GetIconManager()
		local attr = item:GetBaseObject()
		itemcell.Name:setText(item:GetName())
		local color = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
		itemcell.Name:setProperty("TextColours", color)
		itemcell.Item:SetImage(iconManager:GetItemIconByID(attr.icon))
		
		local maxid, maxgemid, maxgemlevel = GetMaxLevelGem(item)
		if maxgemid == 0 then
			itemcell.Level:setText(MHSD_UTILS.get_resstring(2749))
		else
			local stringformat = MHSD_UTILS.get_resstring(2748)
			local sb = StringBuilder:new()
			sb:Set("parameter1", maxgemlevel)
			local showstr = sb:GetString(stringformat)
            sb:delete()
			itemcell.Level:setText(showstr)
		end
		itemcell.Item:setID(item:GetThisID())
	end
	itemcell.Frame:subscribeEvent("MouseClick", self.HandleClickedItem, self)
end

function WorkshopXqNew:OnSelectedItem(item)
	local rolelevel = GetDataManager():GetMainCharacterLevel()
	local equipObj = toEquipObject(item:GetObject())
	if equipObj then
		local gemlist = std.vector_int_()
		equipObj:GetGemlist(gemlist)
		local gemsize = gemlist:size()
		local gemCellNum = #self.GemCells
		for i = 1, gemsize do
			if i > gemCellNum then
				LogInsane("too many gems in equipitem")
				break
			end
			local gemCell = self.GemCells[i]
			local gemid = gemlist[i - 1]
			local gemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(gemid)
			local iconManager = GetIconManager()
			gemCell.Name:setText(gemattr.name)
			gemCell.Name:setProperty("TextColours", gemattr.colour)
			gemCell.Item:SetImage(iconManager:GetItemIconByID(gemattr.icon))
			local gemconfig = knight.gsp.item.GetCGemEffectTableInstance():getRecorder(gemid)
			gemCell.Text:setText(gemconfig.inlayeffect)
			gemCell.Lock:setVisible(false)
			gemCell.Status = 1
			gemCell.GemIndexInEquip = i - 1
			if gemCell.HasEffect then
				GetGameUIManager():RemoveUIEffect(gemCell.Item)
			end
			gemCell.HasEffect = false
		end

		local tbl = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cbaoshixiangqian")
		equipObj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, item:GetThisID())
		local blesslv = 0
		if equipObj then 
			blesslv = equipObj.blesslv 
		end

		for i = gemsize + 1, gemCellNum do
			LogInsane("Show gem plus effect "..gemsize..",i ="..gemCellNum)
			local gemCell = self.GemCells[i]
			local cfg = tbl:getRecorder(i)

			if rolelevel >= cfg.needplayerlv and blesslv >= cfg.needblesslv then
				gemCell.Lock:setVisible(false)
				gemCell.Suolian:setVisible(false)
				gemCell.Status = 2
				if not gemCell.HasEffect and not self.m_waitGemEffect then
					GetGameUIManager():AddUIEffect(gemCell.Item, MHSD_UTILS.get_effectpath(10374), true, 0, 0, true)
				end
				gemCell.HasEffect = true
			else
				gemCell.Status = 3
				if gemCell.HasEffect then
					GetGameUIManager():RemoveUIEffect(gemCell.Item)
				end
				gemCell.HasEffect = false
				if i <= 4 then
					gemCell.Lock:setVisible(true)
					gemCell.Suolian:setVisible(false)
				else
					gemCell.Suolian:setVisible(true)
					gemCell.Lock:setVisible(false)
				end
			end

			gemCell.GemIndexInEquip = -1
			gemCell.Name:setText("")
			gemCell.Item:SetImage(nil)
			gemCell.Text:setText("")
		end
	end
end

function WorkshopXqNew:PlayUnlockEffect( i )
	self.GemPane:getVertScrollbar():setScrollPosition(100)
	local gemCell = self.GemCells[i]
	if gemCell then
		self.m_waitGemEffect = i
		GetGameUIManager():RemoveUIEffect(gemCell.Item)
		local effect = GetGameUIManager():AddUIEffect(gemCell.Item, MHSD_UTILS.get_effectpath(10448), false, 0, 0, true)
		local notify = CGameUImanager:createNotify(self.OnUnlockEffectEnd)
		effect:AddNotify(notify)
	end
end

function WorkshopXqNew.OnUnlockEffectEnd()
	if _instance then
		local self = _instance
		GetGameUIManager():AddUIEffect(self.GemCells[self.m_waitGemEffect].Item, MHSD_UTILS.get_effectpath(10374), true)
		self.m_waitGemEffect = nil
	end
end

function WorkshopXqNew:SetClickedItem( i )
	if self.XqItems[i].Item:getID() == 0 then
		return false
	end
	if self.clickedwindow then
		for i = 1, #self.XqItems do
			if self.clickedwindow == self.XqItems[i].Item then
				self.XqItems[i].Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
				break
			end
		end
	end
	self.clickedwindow = self.XqItems[i].Item
	self.XqItems[i].Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")

	local bagid = knight.gsp.item.BagTypes.EQUIP
	local itemkey = self.clickedwindow:getID()
	if itemkey == 0 then
		return true
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if item == nil then
		return true
	end
	self:OnSelectedItem(item)
	self:ShowTab(1)
	return true
end

function WorkshopXqNew:HandleClickedItem(e)
	LogInsane("WorkshopXqNew:HandleClickedItem")
	if self.XqProgressing or self.m_waitGemEffect then
		return false
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.XqItems do
		if mouseArgs.window == self.XqItems[i].Frame then
			if self.XqItems[i].Item:getID() == 0 then
				return false
			end
			if self.clickedwindow then
				for i = 1, #self.XqItems do
					if self.clickedwindow == self.XqItems[i].Item then
						self.XqItems[i].Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
						break
					end
				end
			end
			self.clickedwindow = self.XqItems[i].Item
			self.XqItems[i].Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
			break
		end
	end
	--self.clickedwindow = mouseArgs.window
	local bagid = knight.gsp.item.BagTypes.EQUIP
	local itemkey = self.clickedwindow:getID()
	if itemkey == 0 then
		return true
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if item == nil then
		return true
	end
	self:OnSelectedItem(item)
	self:ShowTab(1)
	return true
end
-------for equipcell end---

function WorkshopXqNew:InitEquipItems()
	for i = 1, #WorkshopHelper.ItemList do
		self:AddEquip(i)
	end
end

function WorkshopXqNew:AddGem(i)
	self.GemCells[i] = NewGem(self.GemPane, i)
	self.GemCells[i].Name:setText("")
	self.GemCells[i].Text:setText("")
	self.GemCells[i].Status = 3
	self.GemCells[i].HasEffect = false
	self.GemCells[i].Item:subscribeEvent("MouseClick", self.HandleClickedGem, self)
end

function WorkshopXqNew:ShowBagGems()
	if self.clickedwindow == nil then
		return
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickedwindow:getID(), knight.gsp.item.BagTypes.EQUIP)
	if item == nil then
		return
	end
	local itemid = item:GetBaseObject().id
	local gemkeys = std.vector_int_()
	GetRoleItemManager():GetItemKeyListByType(gemkeys, GemTypeID)
	local curItemRow = nil
	local curlinenum = #self.BagGemLines
	local row = 0
	
	local j = 0
	for i = 0, gemkeys:size() - 1 do
		local baggem = GetRoleItemManager():FindItemByBagAndThisID(gemkeys[i], knight.gsp.item.BagTypes.BAG)
		if IsGemMatchItem(baggem:GetBaseObject().id, itemid) then
			local idx = j % 3
			row = math.floor(j / 3)
			if idx == 0 then
				if row < curlinenum then
					LogInsane("Use Old BagGem..row="..row..", curlinenum="..curlinenum)
					curItemRow = self.BagGemLines[row + 1]
					curItemRow.Frame:setVisible(true)
				else
					LogInsane("NewBagGem")
					curItemRow = NewBagGem(self.ShowPane[2].BagGems, row)
					for k = 1, 3 do
						curItemRow[k].Item:subscribeEvent("MouseClick", self.HandleBagGemClicked, self)
					end
					self.BagGemLines[row + 1] = curItemRow
				end
			end
			local gemnum = baggem:GetNum()
			LogInsane("idx="..idx)
			local itemcell = curItemRow[idx + 1]
			local iconManager = GetIconManager()
			local attr = baggem:GetBaseObject()
			itemcell.Name:setText(baggem:GetName())
			local color = MHSD_UTILS.getColourStringByNumber(baggem:GetNameColour())
			itemcell.Name:setProperty("TextColours", color)
			itemcell.Item:SetImage(iconManager:GetItemIconByID(attr.icon))
			itemcell.Item:SetTextUnit(gemnum)
			itemcell.Item:setID(baggem:GetThisID())
			j = j + 1
		end
	end
	local maxindex = math.ceil(j / 3) * 3
	for i = j, maxindex - 1 do
		local idx = i % 3
		LogInsane("i="..i..",idx="..idx..",maxindex"..maxindex)
		local itemcell = curItemRow[idx + 1]
		itemcell.Name:setText("")
		itemcell.Item:SetImage(nil)
		itemcell.Item:SetTextUnit("")
		itemcell.Item:setID(0)
	end
	local startrow  = maxindex/3 + 1
	curlinenum = #self.BagGemLines
	for i = startrow, curlinenum do
		self.BagGemLines[i].Frame:setVisible(false)
	end
end

function WorkshopXqNew:HandleClickedGem(e)
	if self ~= _instance then
		LogInsane("self not equip instance")
	end
	if self.XqProgressing or self.m_waitGemEffect then
		return false
	end
	if self.clickedwindow == nil then
		return false
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.clickedwindow:getID(), knight.gsp.item.BagTypes.EQUIP)
	if item == nil then
		LogInsane("you should choose a item first")
		return false
	end
	local itemid = item:GetBaseObject().id
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local cellnum = #self.GemCells
	self.clickcell = nil
	for i = 1, cellnum do
		if self.GemCells[i].Item == mouseArgs.window then
			LogInsane("you clicked lua window="..mouseArgs.window:getName())
			self.clickcell = self.GemCells[i]
			break;
		end
	end
	if self.clickcell == nil then
		return true
	end
	if self.clickcell.Status == 3 then
		LogInsane("This item is unclickable")
		return true
	elseif self.clickcell.Status == 2 then
		self:ShowTab(BAG_INDEX)
		self:ShowBagGems()
		return true
	elseif self.clickcell.Status == 1 then
		local equipObj = toEquipObject(item:GetObject())
		if equipObj == nil then
			return true
		end
		if self.clickcell.GemIndexInEquip == -1 then
			return true
		end
		local gemlist = std.vector_int_()
		equipObj:GetGemlist(gemlist)
		if self.clickcell.GemIndexInEquip >= gemlist:size() then
			return true;
		end
		self:ShowTab(STONE_INDEX)
		local pane = self.ShowPane[STONE_INDEX]
		local gemid = gemlist[self.clickcell.GemIndexInEquip]
		LogInsane("clicked gemid="..gemid)
		local gemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(gemid)
		pane.Name:setText(gemattr.name)
		pane.Name:setProperty("TextColours", gemattr.colour)
		pane.Item:SetImage(GetIconManager():GetItemIconByID(gemattr.icon))
		local gemconfig = knight.gsp.item.GetCGemEffectTableInstance():getRecorder(gemid)
		pane.Describe:setText(gemconfig.inlayeffect)
		pane.Usage:setText(gemconfig.inlaypos)
		return true
	end
	return true
end

function WorkshopXqNew:HandleBagGemClicked(e)
	if self.XqProgressing or self.m_waitGemEffect then
		return false
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	if mouseArgs.window:getID() == 0 then
		return false
	end
	if self.clickedbaggem then
		self.clickedbaggem:SetSelected(false)
	end
	self.clickedbaggem = mouseArgs.window
	self.clickedbaggem:SetSelected(true)
end

function WorkshopXqNew:InitGems()
	local gemshownum = 6
	for i = 1, gemshownum do
		self:AddGem(i)
	end
end

function WorkshopXqNew:SetItemSelected(bagid, itemkey)
	if bagid == knight.gsp.item.BagTypes.EQUIP then
		
		if self.clickedwindow then
			for i = 1, #self.XqItems do
				if self.clickedwindow == self.XqItems[i].Item then
					self.XqItems[i].Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
					break
				end
			end
		end
		for i = 1, #self.XqItems do
			LogInsane(string.format("check key=%d, itemkey=%d",self.XqItems[i].Item:getID(), itemkey))
			if self.XqItems[i].Item:getID() == itemkey then
				self.clickedwindow = self.XqItems[i].Item
				LogInsane(string.format("set %d selected", i))
				self.XqItems[i].Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
				local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
				if item then
					self:OnSelectedItem(item)
					self:ShowTab(1)
				end
			end
			
		end
	end
end

function WorkshopXqNew:RefreshItemTips(item)
	LogInsane("WorkshopXqNew:RefreshItemTips")
	for i = 1, #self.XqItems do
		if self.XqItems[i].Item:getID() ~= 0 then
			local xqitem = GetRoleItemManager():FindItemByBagAndThisID(self.XqItems[i].Item:getID(), knight.gsp.item.BagTypes.EQUIP)
			if xqitem == item then
				local item_info = WorkshopHelper.ItemList[i]
				local bagid = knight.gsp.item.BagTypes.EQUIP
				local iconManager = GetIconManager()
				local attr = item:GetBaseObject()
				self.XqItems[i].Name:setText(item:GetName())
				local color = MHSD_UTILS.getColourStringByNumber(item:GetNameColour())
				self.XqItems[i].Name:setProperty("TextColours", color)
				self.XqItems[i].Item:SetImage(iconManager:GetItemIconByID(attr.icon))
				
				local maxid, maxgemid, maxgemlevel = GetMaxLevelGem(item)
				if maxgemid == 0 then
					self.XqItems[i].Level:setText(MHSD_UTILS.get_resstring(2749))
				else
					local stringformat = MHSD_UTILS.get_resstring(2748)
					local sb = StringBuilder:new()
					sb:Set("parameter1", maxgemlevel)
					local showstr = sb:GetString(stringformat)
                    sb:delete()
					self.XqItems[i].Level:setText(showstr)
				end
				break
			end
		end
	end
	local clickeditem = GetRoleItemManager():FindItemByBagAndThisID(self.clickedwindow:getID(), knight.gsp.item.BagTypes.EQUIP)
	if clickeditem == item then
		LogInsane("Find item not the clickeditem")
		self:OnSelectedItem(clickeditem)
	end
	self:RefreshCanXqEffect()
end
------------------- UI create function set ------
function WorkshopXqNew:GetLayoutFileName()
	return "workshopxqnew.layout"
end
function WorkshopXqNew:DestroyDialog()
	if self.m_LinkLabel then
		self.m_LinkLabel:OnClose()
		self.m_LinkLabel = nil
	else
		self:OnClose()
	end
end
function WorkshopXqNew:OnClose()
	Dialog.OnClose(self)
	self.m_LinkLabel =nil
	self.XqProgressing = false
	self.BagGemLines = {}
	self.GemCells = {}
	self.ItemNumChangeNotifier = nil
	LogInsane("WorkshopXqNew:OnClose"..#self.BagGemLines)
    GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
	_instance = nil
end
return WorkshopXqNew
