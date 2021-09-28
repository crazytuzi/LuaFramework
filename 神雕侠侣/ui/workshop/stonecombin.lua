require "ui.dialog"
require "ui.workshop.workshopequipcell"
local GemTypeID = 0x5
StoneCombin = {}
setmetatable(StoneCombin, Dialog)
StoneCombin.__index = StoneCombin

local _instance
function StoneCombin.getInstance()
	LogInsane("new StoneCombin Instance")
	if not _instance then
		_instance = StoneCombin:new()
	end
	return _instance
end

function StoneCombin:new()
	local self = {}
	setmetatable(self, StoneCombin)
	self:OnCreate()
	return self
end

function StoneCombin.getInstanceOrNot()
	return _instance
end

function StoneCombin.GetLayoutFileName()
	return "stonecombin.layout"
end

function StoneCombin:DestroyDialog()
	self:OnClose()
end

function StoneCombin:OnClose()
	Dialog.OnClose(self)
    GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
	_instance = nil
end

local function sortGems(gemkeys)
	local gems = {}
	for i = 0, gemkeys:size() - 1 do
		local baggem = GetRoleItemManager():FindItemByBagAndThisID(gemkeys[i], knight.gsp.item.BagTypes.BAG)
		if baggem then
			local attr = baggem:GetBaseObject()
			table.insert(gems, baggem)
		end
	end
	table.sort(gems, function (v1, v2)
		local attr1 = v1:GetBaseObject()
		local attr2 = v2:GetBaseObject()
		return attr1.level < attr2.level
	end)
	return gems
end

function StoneCombin:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pGemPane = CEGUI.toScrollablePane(winMgr:getWindow("stonecombin/left/scroll"))
	self.m_pGems = {}
	self.m_pCombinGems = {}
	self.m_pCombinGemPositions = {}
	for i = 0, 3 do
		local t = {}
		t.gem = CEGUI.toItemCell(winMgr:getWindow("stonecombin/right/stone"..i))
		t.gem:subscribeEvent("TableClick", self.HandleCombineGemClicked, self)
		t.hasGem = false
		local curpos = t.gem:getPosition()
		local pos = CEGUI.UVector2()
		pos.x = curpos.x
		pos.y = curpos.y
		table.insert(self.m_pCombinGemPositions, pos)
		table.insert(self.m_pCombinGems, t)
	end
	self.m_pEndGem = CEGUI.toItemCell(winMgr:getWindow("stonecombin/right/endstone"))
	self.m_pEndGem:subscribeEvent("TableClick", self.HandleEndGemClicked, self)
	self.m_pMoney = winMgr:getWindow("stonecombin/right/money")
	self.m_pOkBtn = winMgr:getWindow("stonecombin/right/btn")
	self.m_pOkBtn:subscribeEvent("Clicked", self.HandleOkBtnClicked, self)
	local gemkeys = std.vector_int_()
	GetRoleItemManager():GetItemKeyListByType(gemkeys, GemTypeID)
	local gems = sortGems(gemkeys)
	for i = 1, #gems do
		local baggem = gems[i]
	--	GetRoleItemManager():FindItemByBagAndThisID(gemkeys[i], knight.gsp.item.BagTypes.BAG)
		local attr = baggem:GetBaseObject()
		if attr.level <= 14 then
			local itemcell = Workshopequipcell.new(self.m_pGemPane, i - 1)
			local iconManager = GetIconManager()
			
			itemcell.Name:setText(baggem:GetName())
			local color = MHSD_UTILS.getColourStringByNumber(baggem:GetNameColour())
			itemcell.Name:setProperty("TextColours", color)
			itemcell.Item:SetImage(iconManager:GetItemIconByID(attr.icon))
			itemcell.Level:setText(MHSD_UTILS.get_resstring(2792))
			itemcell.Item:setID(baggem:GetThisID())
			itemcell.Frame:subscribeEvent("MouseClick", self.HandleClickedItem, self)
			local t = {}
			t.gem = itemcell
			t.toy = itemcell.m_pMainFrame:getYPosition().offset
			t.number = baggem:GetNum()
			t.gem.Item:SetTextUnit(tostring(t.number))
			t.move = false
			table.insert(self.m_pGems, t)
		end
	end
	self.m_pMainFrame:subscribeEvent("WindowUpdate", self.HandleWindowUpdate, self)
	self.m_pMoney = winMgr:getWindow("stonecombin/right/money")
	self.m_pMoney:setText(tostring(0))
	self.m_pMoney:setProperty("TextColours", "FF00FF00")
    self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(StoneCombin.OnItemNumberChange)
end

function StoneCombin.OnItemNumberChange(bagid, itemkey, itembaseid)
	local self = _instance
	if self == nil then
		return
	end
	local has, gem = false, nil
	for i = 1, #self.m_pGems do
		if self.m_pGems[i].gem.Item:getID() == itemkey then
			has = true
			local baggem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
			if not baggem then
				self.m_pGems[i].number = 0
				self.m_pGems[i].gem.Item:SetTextUnit(tostring(0))
				self.m_pGems[i].gem.Item:setID(0)
			end
			if baggem then
				self.m_pGems[i].number = baggem:GetNum()
				self.m_pGems[i].gem.Item:SetTextUnit(tostring(self.m_pGems[i].number))
			end
		end
		if self.m_pGems[i].gem.Item:getID() == 0 then
			gem = i
		end
	end 
	if not has then
		local baggem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
		if not baggem then
			return 
		end
		local attr = baggem:GetBaseObject()
		if attr.level <= 14 then
			local itemcell, t
			if gem == nil then
				t = {}
				itemcell = Workshopequipcell.new(self.m_pGemPane, #self.m_pGems)
				t.gem = itemcell
			else
				t = self.m_pGems[gem]
				itemcell = self.m_pGems[gem].gem
			end
			local visible = 0
			for i = 1, #self.m_pGems do
				if self.m_pGems[i].gem:IsVisible() then
					visible = visible + 1
				end
			end
			local iconManager = GetIconManager()
			
			itemcell.Name:setText(baggem:GetName())
			local color = MHSD_UTILS.getColourStringByNumber(baggem:GetNameColour())
			itemcell.Name:setProperty("TextColours", color)
			itemcell.Item:SetImage(iconManager:GetItemIconByID(attr.icon))
			itemcell.Level:setText(MHSD_UTILS.get_resstring(2792))
			itemcell.Item:setID(baggem:GetThisID())
			
			t.toy = itemcell.m_pMainFrame:getHeight().offset * visible
			itemcell.m_pMainFrame:setYPosition(CEGUI.UDim(0, t.toy))
			t.number = baggem:GetNum()
			t.gem.Item:SetTextUnit(tostring(t.number))
			t.move = false
			if not gem then
				t.gem = itemcell
				itemcell.Frame:subscribeEvent("MouseClick", self.HandleClickedItem, self)
				table.insert(self.m_pGems, t)
				gem = #self.m_pGems
			end
			if self.config and self.config.id ~= attr.level then
				self:SetGemNotVisible(gem)
			end
		end
	end
end

function StoneCombin:HandleWindowUpdate(e)
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local speed = 800
	local offset = speed * updateArgs.d_timeSinceLastFrame
	for i = 1, #self.m_pGems do
		if self.m_pGems[i].move then
			local oldy = self.m_pGems[i].gem.m_pMainFrame:getYPosition().offset
			local newy
			if oldy > self.m_pGems[i].toy then
				newy = oldy - offset
				if newy < self.m_pGems[i].toy then
					newy = self.m_pGems[i].toy
					self.m_pGems[i].move = false
				end
			else
				newy = oldy + offset
				if newy > self.m_pGems[i].toy then
					newy = self.m_pGems[i].toy
					self.m_pGems[i].move = false
				end
			end
			self.m_pGems[i].gem.m_pMainFrame:setYPosition(CEGUI.UDim(0, newy))
		end
	end
end

function StoneCombin:SetGemNotVisible(k)
	if not self.m_pGems[k].gem:IsVisible() then
		return
	end
	local findy
	for i = 1, #self.m_pGems do
		if i == k then
			self.m_pGems[i].gem.m_pMainFrame:setYPosition(CEGUI.UDim(0, self.m_pGems[i].toy))
			self.m_pGems[i].gem:SetVisible(false)
			self.m_pGems[i].move = false
			findy = self.m_pGems[i].toy
		else
			if findy and self.m_pGems[i].gem:IsVisible() then
				self.m_pGems[i].move = true
				findy, self.m_pGems[i].toy = self.m_pGems[i].toy, findy
			end
		end
	end
end

function StoneCombin:HandleClickedItem(e)
	if self.m_pEndGem:getID() ~= 0 then
		return true
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local combingem
	for i = 1, #self.m_pCombinGems do
		if not self.m_pCombinGems[i].hasGem then
			combingem = self.m_pCombinGems[i]
			break
		end
	end
	if not combingem then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(144990)
        end
		return true
	end
	local clicked
	for i = 1, #self.m_pGems do
		if self.m_pGems[i].gem.Frame == mouseArgs.window then
			clicked = i
			self.m_pGems[i].number = self.m_pGems[i].number - 1
			self.m_pGems[i].gem.Item:SetTextUnit(tostring(self.m_pGems[i].number))
			if self.m_pGems[i].number <= 0 then
				self:SetGemNotVisible(i)
			end
			break
		end
	end
	if clicked then
		combingem.hasGem = true
		local itemkey = self.m_pGems[clicked].gem.Item:getID()
		local baggem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
		if baggem then
			local iconManager = GetIconManager()
			local attr = baggem:GetBaseObject()
			combingem.gem:SetImage(iconManager:GetItemIconByID(attr.icon))
			combingem.gem:setID(baggem:GetThisID())
			local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cgemsmeltprobs")
			self.config = tt:getRecorder(attr.level)
			self.gemnum = self.gemnum and self.gemnum + 1 or 1
			self:RefreshMoney()
			for i = 1, #self.m_pGems do
				local key = self.m_pGems[i].gem.Item:getID()
				local gem = GetRoleItemManager():FindItemByBagAndThisID(key, knight.gsp.item.BagTypes.BAG)
				if gem then
					local gemattr = gem:GetBaseObject()
					if attr.level ~= gemattr.level and i ~= clicked and self.m_pGems[i].gem:IsVisible() then
						self:SetGemNotVisible(i)
					end
				end
			end 
			
		end
	--	self.clicked.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end
end

function StoneCombin:SetGemVisible(k)
	for i = 1, #self.m_pGems do
		if i == k then
			self.m_pGems[i].gem:SetVisible(true)
			local offset = self.m_pGems[i].gem.m_pMainFrame:getHeight().offset
			local toy = 0
			for j = 1, #self.m_pGems do
				if self.m_pGems[j].gem:IsVisible() then
					self.m_pGems[j].move = true
					self.m_pGems[j].toy = toy
					toy = toy + offset
				end
			end
		end
	end
end

function StoneCombin:HandleCombineGemClicked(e)
	if self.m_pEndGem:getID() ~= 0 then
		return true
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local combingem
	for i = 1, #self.m_pCombinGems do
		if mouseArgs.window == self.m_pCombinGems[i].gem then
			combingem = self.m_pCombinGems[i]
			break
		end
	end
	if not combingem or not combingem.hasGem then
		return true
	end
	local itemkey = combingem.gem:getID()
	combingem.hasGem = false
	combingem.gem:SetImage(nil)
	combingem.gem:setID(0)
	local gem
	for i = 1, #self.m_pGems do
		if self.m_pGems[i].gem.Item:getID() == itemkey then
			gem = self.m_pGems[i]
			self.m_pGems[i].number = self.m_pGems[i].number + 1
			self.m_pGems[i].gem.Item:SetTextUnit(tostring(self.m_pGems[i].number))
			if self.m_pGems[i].number == 1 then
				-- display the gem
				self:SetGemVisible(i)
			end
			break
		end
	end
	local j = 1
	local emptyidxs = {}
	for i = 1, #self.m_pCombinGems do
		if self.m_pCombinGems[i].gem:getID() ~= 0 then
			self.m_pCombinGems[i].gem:setPosition(self.m_pCombinGemPositions[j])
			j = j + 1
		else
			table.insert(emptyidxs, i)
		end
	end
	self.gemnum = j - 1
	if #emptyidxs == #self.m_pCombinGems then
		self.config = nil
		for i = 1, #self.m_pGems do
			if self.m_pGems[i].gem.Item:getID() ~= 0 and not self.m_pGems[i].gem:IsVisible() then
				self:SetGemVisible(i)
			end
		end
	end
	for k = 1, #emptyidxs do
		self.m_pCombinGems[emptyidxs[k]].gem:setPosition(self.m_pCombinGemPositions[j])
		j = j + 1
	end
	--RefreshMoney
	self:RefreshMoney()
	return true
end

function StoneCombin:RefreshMoney()
	local needmoney
	if self.config == nil then
		needmoney = 0
	else
		if self.gemnum == 2 then
			needmoney = self.config.twotoonemoney
		elseif self.gemnum == 3 then
			needmoney = self.config.threetoonemoney
		elseif self.gemnum == 4 then
			needmoney = self.config.fourtoonemoney
		else
			needmoney = 0
		end
	end
	local money = GetRoleItemManager():GetPackMoney()
	self.m_pMoney:setText(tostring(needmoney))
	self.m_pMoney:setProperty("TextColours", money >= needmoney and "FF00FF00" or "FFFF0000")
end

function StoneCombin:HandleOkBtnClicked(e)
	if self.m_pEndGem:getID() ~= 0 then
		return true
	end
	local p = require "protocoldef.knight.gsp.item.cgemsmelt":new()
	for i = 1, #self.m_pCombinGems do
		local itemkey = self.m_pCombinGems[i].gem:getID()
		if itemkey ~= 0 then
			table.insert(p.itemkeys, itemkey)
		end
	end
	if #p.itemkeys > 1 then
		if self.config == nil then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(144991)
            end
			return
		end
		local needmoney
		if self.gemnum == 2 then
			needmoney = self.config.twotoonemoney
		elseif self.gemnum == 3 then
			needmoney = self.config.threetoonemoney
		elseif self.gemnum == 4 then
			needmoney = self.config.fourtoonemoney
		else
            if GetChatManager() then
                GetChatManager():AddTipsMsg(144991)
            end
			return
		end
		local money = GetRoleItemManager():GetPackMoney()
		if money < needmoney then
            if GetChatManager() then
                GetChatManager():AddTipsMsg(144991)
            end
			return
		end
		local net = require "manager.luaprotocolmanager".getInstance()
		net:send(p)
	else
		if GetChatManager() then
            GetChatManager():AddTipsMsg(144992)
        end
	end
end

function StoneCombin:CombinResult(itemkey)
	for i = 1, #self.m_pCombinGems do
		local key = self.m_pCombinGems[i].gem:getID()
		for i = 1, #self.m_pGems do
			if self.m_pGems[i].gem.Item:getID() == key then
				if self.m_pGems[i].number == 0 then
					self.m_pGems[i].gem.Item:setID(0)
				end
				break
			end
		end
		self.m_pCombinGems[i].gem:setID(0)
		self.m_pCombinGems[i].gem:SetImage(nil)
		self.m_pCombinGems[i].hasGem = false
	end
	self.gemnum = 0
	local endstone = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
	if endstone then
		self.m_pEndGem:setID(itemkey)
		local iconManager = GetIconManager()
		local attr = endstone:GetBaseObject()
		self.m_pEndGem:SetImage(iconManager:GetItemIconByID(attr.icon))
		GetGameUIManager():AddUIEffect(self.m_pEndGem, MHSD_UTILS.get_effectpath(10383), false)
	end
	self.config = nil
	for i = 1, #self.m_pGems do
		if self.m_pGems[i].gem.Item:getID() ~= 0 and self.m_pGems[i].gem.Item:getID() ~= itemkey and not self.m_pGems[i].gem:IsVisible() then
			self:SetGemVisible(i)
		end
	end
	self.m_pMoney:setText(tostring(0))
	self.m_pMoney:setProperty("TextColours", "FF00FF00")
end

function StoneCombin:HandleEndGemClicked(e)
	if self.m_pEndGem:getID() == 0 then
		return true
	end
	local itemkey = self.m_pEndGem:getID()
	self.m_pEndGem:setID(0)
	self.m_pEndGem:SetImage(nil)
	for i = 1, #self.m_pGems do
		if self.m_pGems[i].gem.Item:getID() == itemkey and not self.m_pGems[i].gem:IsVisible() then
			self:SetGemVisible(i)
			break
		end
	end
end
