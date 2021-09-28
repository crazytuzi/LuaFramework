local single = require "ui.singletondialog"
local MoneyIconID = 1262
WorkshopJl = {}
local NeedYuanbaoNum = 100
setmetatable(WorkshopJl, single)
WorkshopJl.__index = WorkshopJl
local function ShowItemInCell(item, cell, namewnd)
	if item then
		local iconManager = GetIconManager()
		local attr = item:GetBaseObject()
		namewnd:setText(item:GetName())
		local itemcolor = require "utils.mhsdutils".getColourStringByNumber(item:GetNameColour())
		namewnd:setProperty("TextColours", itemcolor);
		cell:SetImage(iconManager:GetItemIconByID(attr.icon))
	else
		namewnd:setText("")
		cell:SetImage(nil)
	end
end

function WorkshopJl.new()
	local self = {}
	setmetatable(self, WorkshopJl)
	function self.GetLayoutFileName()
		return "jinlian.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	local name_prefix = "jinlian/"
	self.m_pItempane = CEGUI.toScrollablePane(winMgr:getWindow(name_prefix.."left"))
	self.m_pJlBtn = CEGUI.toGroupButton(winMgr:getWindow(name_prefix.."jinlian0"))
	self.m_pCzBtn = CEGUI.toGroupButton(winMgr:getWindow(name_prefix.."jinlian1"))
	
	self.m_pIntroduce = winMgr:getWindow(name_prefix.."right/bot/title/name1")
	self.m_pCantPane = winMgr:getWindow(name_prefix.."cant")
	self.m_pNormalPane = winMgr:getWindow(name_prefix.."right")
	self.m_pAppendAttrs = {}
	for i = 1, 4 do
		local appendattr = {}
		appendattr.frame = CEGUI.toGroupButton(winMgr:getWindow(name_prefix.."right/part"..i))
		appendattr.part1 = winMgr:getWindow(name_prefix.."right/part"..i.."/txt1")
		appendattr.part2 = winMgr:getWindow(name_prefix.."right/part"..i.."/txt2")
		appendattr.part3 = winMgr:getWindow(name_prefix.."right/part"..i.."/txt3")
		table.insert(self.m_pAppendAttrs, appendattr)
		local childcount = appendattr.frame:getChildCount()
		for i = 0, childcount - 1 do
			local child = appendattr.frame:getChildAtIdx(i)
			child:setMousePassThroughEnabled(true)
		end
		appendattr.frame:setMousePassThroughEnabled(false)
		appendattr.frame:subscribeEvent("MouseClick", WorkshopJl.HandleAttrSelected, self)
	end
	self.m_pMaterials = {}
	local material = {}
	material.m_pItem = CEGUI.toItemCell(winMgr:getWindow(name_prefix.."right/bot/item3"))
	material.m_pName = winMgr:getWindow(name_prefix.."right/bot/item2")
	table.insert(self.m_pMaterials, material)
	local material = {}
	material.m_pItem = CEGUI.toItemCell(winMgr:getWindow(name_prefix.."right/bot/item1"))
	material.m_pName = winMgr:getWindow(name_prefix.."right/bot/name1")
	table.insert(self.m_pMaterials, material)
	
	self.m_pJlOkBtn = CEGUI.toPushButton(winMgr:getWindow(name_prefix.."right/ok1"))
	self.m_pCzOkBtn = CEGUI.toPushButton(winMgr:getWindow(name_prefix.."right/ok2"))
	for i = 1, #self.m_pMaterials do
		require "utils.mhsdutils".SetWindowShowtips(self.m_pMaterials[i].m_pItem)
	end
	self.m_pItemlist = {}
	for i = 0, 5 do
		local newItem = require "ui.workshop.workshopequipcell".new(self.m_pItempane, i)
		table.insert(self.m_pItemlist, newItem)
		newItem.Frame:subscribeEvent("MouseClick", WorkshopJl.HandleItemSelected, self)
	end
	self.m_pJlBtn:subscribeEvent("MouseClick", WorkshopJl.HandleJlBtnClicked, self)
	self.m_pCzBtn:subscribeEvent("MouseClick", WorkshopJl.HandleCzBtnClicked, self)
	self.m_pJlOkBtn:subscribeEvent("Clicked", WorkshopJl.HandleJlOkBtnClicked, self)
	self.m_pCzOkBtn:subscribeEvent("Clicked", WorkshopJl.HandleCzOkBtnClicked, self)
	
	self.m_pIntroduceText = winMgr:getWindow(name_prefix.."right/bot/title/name1")
	self:LoadEquip()
	
	self:SetMode(1)
	self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(WorkshopJl.OnItemNumChange)
	self.m_hPackMoneyChange = GetRoleItemManager().EventPackMoneyChange:InsertScriptFunctor(WorkshopJl.OnMoneyChange)
	return self
end

local function setItemslot(itemslot, item, iteminfo)
	local utils = require "utils.mhsdutils"
	if not item then
		itemslot.Name:setText(utils.get_resstring(2736)..utils.get_resstring(iteminfo.empty_string))
		itemslot.Level:setText("")
		itemslot.Frame:setID(0)
	else
		ShowItemInCell(item, itemslot.Item, itemslot.Name)
		itemslot.Level:setText("")
		local equipObj = toEquipObject(item:GetObject())
		if equipObj then
			if item:GetObject().bNeedRequireData then
				GetNetConnection():send(knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, item:GetThisID()))
		--		itemslot.CrystalNum = math.huge
			else
			--[[
				newItem.CrystalNum = equipObj.crystalnum
				newItem.CrystalProgress = equipObj.crystalprogress
				newItem.Level:setText(toStarIntroduce(newItem.CrystalNum))
				newItem.Level:setProperty("TextColours",
					MHSD_UTILS.getColourStringByNumber(item:GetNameColour()))
					--]]
			end
		else
		--	newItem.Level:setText("")
		end
		itemslot.Frame:setID(item:GetThisID())
	end
end

local itemlist = require "ui.workshop.workshophelper".ItemList
function WorkshopJl:LoadEquip()
	for i = 1, #itemlist do
		local itemslot = self.m_pItemlist[i]
		local item = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, itemlist[i].type)
		setItemslot(itemslot, item, itemlist[i])
	end
end


local function getResult(cfg, type)
	if not cfg then
		return
	end
	if type == 0 then
		return cfg.wuqi
	elseif type == 1 then
		return cfg.huwan
	elseif type == 2 then
		return cfg.xianglian
	elseif type == 3 then
		return cfg.yifu
	elseif type == 4 then
		return cfg.yaodai
	elseif type == 5 then
		return cfg.xiezi
	end
end

function WorkshopJl:ShowAppendAtts(obj, type)
	if not obj then
		for i = 1, #self.m_pAppendAttrs do
			self.m_pAppendAttrs[i].frame:setVisible(false)
			self.m_pAppendAttrs[i].part1:setText("")
			self.m_pAppendAttrs[i].part2:setText("")
			self.m_pAppendAttrs[i].part3:setText("")
		end
		return
	end
	for i = 1, #obj.plusEffec do
		local effect = obj.plusEffec[i]
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjiachengguanxi", effect.attrid)
		local formula = getResult(cfg, type)
		if formula then
			local namecfg = knight.gsp.effect.GetCEffectConfigTableInstance():getRecorder(effect.attrid - 1)
			if cfg and cfg.id ~= -1 then
				self.m_pAppendAttrs[i].frame:setVisible(true)
				self.m_pAppendAttrs[i].part1:setText(namecfg.classname)
				self.m_pAppendAttrs[i].part2:setText("Lv"..effect.attrnum)
				local variables = {}
				variables["Lv"] = effect.attrnum
				local n = require "utils.formula"(formula, variables)
				if cfg.baifenbi == 0 then
					self.m_pAppendAttrs[i].part3:setText("+"..n)
				else
					self.m_pAppendAttrs[i].part3:setText("+"..(n*100).."%")
				end
				
			else
				self.m_pAppendAttrs[i].frame:setVisible(false)
				
				self.m_pAppendAttrs[i].part1:setText("")
				self.m_pAppendAttrs[i].part2:setText("")
				self.m_pAppendAttrs[i].part3:setText("")
			end
		end
	end
	for i = #obj.plusEffec + 1, #self.m_pAppendAttrs do
		self.m_pAppendAttrs[i].frame:setVisible(false)
		self.m_pAppendAttrs[i].part1:setText("")
		self.m_pAppendAttrs[i].part2:setText("")
		self.m_pAppendAttrs[i].part3:setText("")
	end
	if #obj.plusEffec == 0 then
		self.m_pCantPane:setVisible(true)
		self.m_pNormalPane:setVisible(false)
	else
		self.m_pCantPane:setVisible(false)
		self.m_pNormalPane:setVisible(true)
	end
end

function WorkshopJl:HandleItemSelected(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	if mouseArgs.window and mouseArgs.window:getID() ~= 0 then
		for i = 1, #self.m_pItemlist do
			local itemslot = self.m_pItemlist[i]
			if itemslot.Frame:getID() == mouseArgs.window:getID() then
				self:SetItemSelectedEx(i)
				--[[
				GetNetConnection():send(
					knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, 
					itemslot.Frame:getID()))
					--]]
				return true
			end
		end
	end
	return true
end

local function ShowMaterial(itemid, cell, namewnd)
	if itemid then
		local iconManager = GetIconManager()
		local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemid)
		namewnd:setText(attr.name)
		namewnd:setProperty("TextColours", attr.colour);
		cell:SetImage(iconManager:GetItemIconByID(attr.icon))
	else
		namewnd:setText("")
		cell:SetImage(nil)
	end
end

function WorkshopJl:RefreshMaterial(effect)
	if not effect then
		for i = 1, #self.m_pMaterials do
			local material = self.m_pMaterials[i]
			material.m_pItem:setVisible(false)
			material.m_pName:setVisible(false)
			ShowMaterial(false, material.m_pItem, material.m_pName)
			material.m_pItem:SetTextUnit("")
		end
		return
	end
	if self.mode == 1 then
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cshuxingxiaohao", effect.attrnum)
		if cfg and cfg.id ~= -1 then
			for i = 1, #self.m_pMaterials do
				local material = self.m_pMaterials[i]
				local itemnum = require "utils.tableutil".tablelength(cfg.items)--#cfg.items
				if i <= itemnum then
					material.m_pItem:setVisible(true)
					material.m_pName:setVisible(true)
					local itemid = cfg.items[i - 1]
					local itemnum = cfg.nums[i - 1]
					ShowMaterial(itemid, material.m_pItem, material.m_pName)
					material.m_pItem:SetTextUnit(itemnum)
					local hasnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
					if hasnum >= itemnum then
						material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
					else
						material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
					end
				elseif i == itemnum + 1 then
					material.m_pItem:setVisible(true)
					material.m_pName:setVisible(true)
					material.m_pName:setText(require "utils.mhsdutils".get_resstring(2636))
					material.m_pItem:SetImage(GetIconManager():GetItemIconByID(MoneyIconID))
					local hasmoney = GetRoleItemManager():GetPackMoney()
					local needmoney = cfg.needmoney

					local strBuild = StringBuilder:new()
					local str = nil
					local found = false
					local ids = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getAllID()

				    for k,v in pairs(ids) do
						local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(v)
						if Config.CUR_3RD_LOGIN_SUFFIX == item.platformid then
							found = true
							if needmoney < item.number then
								strBuild:SetNum("parameter1",needmoney)
								str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
							else
								if item.number == 1000000 then	
					 				strBuild:SetNum("parameter1",  (math.floor(needmoney / 1e4) / 1e2))
								 else
									strBuild:SetNum("parameter1", math.ceil(needmoney/item.number))
								end
								strBuild:SetNum("parameter2",item.company)
								str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
							end
							break
						end
					end

					if not found then
						local item = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyinliang"):getRecorder(1)
						if needmoney < item.number then
							strBuild:SetNum("parameter1",needmoney)
							str = strBuild:GetString(MHSD_UTILS.get_resstring(3064))
						else
							if item.number == 1000000 then	
				 				strBuild:SetNum("parameter1",  (math.floor(needmoney / 1e4) / 1e2))
							 else
								strBuild:SetNum("parameter1", math.ceil(needmoney/item.number))
							end
							strBuild:SetNum("parameter2",item.company)
							str = strBuild:GetString(MHSD_UTILS.get_resstring(3063))
						end
					end
					material.m_pItem:SetTextUnit(str)
					strBuild:delete()
					
					if hasmoney >= cfg.needmoney then
						material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
					else
						material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
					end
				else
					material.m_pItem:setVisible(false)
					material.m_pName:setVisible(false)
					ShowMaterial(false, material.m_pItem, material.m_pName)
					material.m_pItem:SetTextUnit("")
				end
			end
		end
	elseif self.mode == 2 then
		local neednum = NeedYuanbaoNum
		local hasnum = GetDataManager():GetYuanBaoNumber()
		for i = 1, #self.m_pMaterials do
			local material = self.m_pMaterials[i]
			if i <= 1 then
				material.m_pItem:setVisible(true)
				material.m_pName:setVisible(true)
				material.m_pName:setText(require "utils.mhsdutils".get_resstring(414))
				material.m_pName:setProperty("TextColours", "0");
				material.m_pItem:SetImage(GetIconManager():GetItemIconByID(1431))
				material.m_pItem:SetTextUnit(neednum)
				if hasnum >= neednum then
			--		material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
				else
			--		material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
				end
			else
				material.m_pItem:setVisible(false)
				material.m_pName:setVisible(false)
				ShowMaterial(false, material.m_pItem, material.m_pName)
				material.m_pItem:SetTextUnit("")
			end
		end
		-- yuanbao
	end
end
--- 1=jinglian 2=chongzhu
function WorkshopJl:SetMode(mode)
	if mode == self.mode then
		return
	end
	self.mode = mode
	self.m_pJlOkBtn:setVisible(mode == 1)
	self.m_pCzOkBtn:setVisible(mode == 2)
	self.m_pIntroduceText:setText(mode == 1 and require "utils.mhsdutils".get_msgtipstring(145331) or
		require "utils.mhsdutils".get_msgtipstring(145332))
	
	if not self.m_pSelectedItem then
		for i = 1, #self.m_pItemlist do
		local itemslot = self.m_pItemlist[i]
		if itemslot.Frame:getID() ~= 0 then
			self:SetItemSelectedEx(i)
			break
		end
	end
	end
	if self.m_pSelectedItem and self.m_pSelectedAttr then
		local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
			self.m_pSelectedItem.Frame:getID())
		if equipobj then
			--#obj.plusEffec
			for i = 1, #self.m_pAppendAttrs do
				if self.m_pSelectedAttr == self.m_pAppendAttrs[i] then
					self:RefreshMaterial(equipobj.plusEffec[i])
				end
			end
		end
	end
end

local function getEquiptype(typeid)
	local t = typeid % 16
	if t ~= 8 then
		return -1
	end
	return math.floor(typeid / 16) % 16
end

function WorkshopJl:SetItemSelectedEx(i)
	local curclicked = self.m_pItemlist[i]
	if self.m_pSelectedItem and self.m_pSelectedItem ~= curclicked then
		self.m_pSelectedItem.Frame:setProperty("Image", "set:MainControl9 image:shopcellnormal")
	end
	if self.m_pSelectedItem ~= curclicked then
		self.m_pSelectedItem = curclicked
		self.m_pSelectedItem.Frame:setProperty("Image", "set:MainControl9 image:shopcellchoose")
	end
	local item = GetRoleItemManager():FindItemByBagAndThisID(self.m_pSelectedItem.Frame:getID(), 
		knight.gsp.item.BagTypes.EQUIP)
	local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
		self.m_pSelectedItem.Frame:getID())
	self:ShowAppendAtts(equipobj, getEquiptype(item:GetItemTypeID()))
	if equipobj and #equipobj.plusEffec > 0 then
		if not self.m_pSelectedAttr then
			self.m_pSelectedAttr = self.m_pAppendAttrs[1]
			self.m_pSelectedAttr.frame:setSelected(true)
			self:RefreshMaterial(equipobj.plusEffec[1])
		else
			if not self.m_pSelectedAttr.frame:isVisible() then
				self.m_pSelectedAttr = self.m_pAppendAttrs[1]
				self.m_pSelectedAttr.frame:setSelected(true)
				self:RefreshMaterial(equipobj.plusEffec[1])
			else
				for j = 1, #self.m_pAppendAttrs do
					if self.m_pSelectedAttr == self.m_pAppendAttrs[j] then
						local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
							self.m_pSelectedItem.Frame:getID())
						if equipobj and #equipobj.plusEffec >= j then
							self:RefreshMaterial(equipobj.plusEffec[j])
						end
						break
					end
				end
			end
		end
	else
		self.m_pSelectedAttr = nil
		self:RefreshMaterial()
	end
--	self:RefreshClickedItemInfo()
--	self:RefreshPreviewItemInfo()
--	self:RefreshMaterial()
end

function WorkshopJl:SetItemSelected(bagid, itemkey)
end

function WorkshopJl:RefreshItemTips(item)
	if item:GetLocation().tableType ~= knight.gsp.item.BagTypes.EQUIP then
		return
	end
	for i = 1, #itemlist do
		if item:GetLocation().position == itemlist[i].type then
			local itemslot = self.m_pItemlist[i]
			setItemslot(itemslot, item, itemlist[i])
			break
		end
	end
	if not self.m_pSelectedItem then
		return
	end 
	if item:GetThisID() == self.m_pSelectedItem.Frame:getID() then
		for i = 1, #self.m_pItemlist do
			if self.m_pSelectedItem == self.m_pItemlist[i] then
				self:SetItemSelectedEx(i)
				if not self.m_pSelectedAttr then
					return
				end
				for j = 1, #self.m_pAppendAttrs do
					if self.m_pSelectedAttr == self.m_pAppendAttrs[j] then
						local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
							self.m_pSelectedItem.Frame:getID())
						if equipobj and #equipobj.plusEffec >= j then
							self:RefreshMaterial(equipobj.plusEffec[j])
						end
						break
					end
				end
				break
			end
		end
	end
end

function WorkshopJl:HandleAttrSelected(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	if self.m_pSelectedAttr and self.m_pSelectedAttr.frame == e.window then
		return true
	end 
	for i = 1, #self.m_pAppendAttrs do
		if e.window == self.m_pAppendAttrs[i].frame then
			if self.m_pSelectedAttr then
			end
			self.m_pSelectedAttr = self.m_pAppendAttrs[i]
			if self.m_pSelectedItem then
				local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
					self.m_pSelectedItem.Frame:getID())
				if equipobj and #equipobj.plusEffec >= i then
					self:RefreshMaterial(equipobj.plusEffec[i])
				end
			end
		end
	end
	
	return true
end

function WorkshopJl:HandleJlBtnClicked(e)
	self:SetMode(1)
	return true
end

function WorkshopJl:HandleCzBtnClicked(e)
	self:SetMode(2)
	return true
end
function WorkshopJl:HandleJlOkBtnClicked(e)
	if self.mode ~= 1 then
		return false
	end
	if not self.m_pSelectedItem or not self.m_pSelectedAttr then
		return true
	end
	local idx
	for i = 1, #self.m_pAppendAttrs do
		if self.m_pSelectedAttr == self.m_pAppendAttrs[i] then
			idx = i
			break
		end
	end
	assert(idx)
	local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
		self.m_pSelectedItem.Frame:getID())
	assert(equipobj and #equipobj.plusEffec >= idx)
	
	local effect = equipobj.plusEffec[idx]
	--[[
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cshuxingxiaohao", effect.attrnum)
	if cfg and cfg.id ~= -1 then
		local hasmoney = GetRoleItemManager():GetPackMoney()
		if hasmoney < cfg.needmoney then
			LogInsane("Not enought money")
			return true
		end

		local itemnum = require "utils.tableutil".tablelength(cfg.items)--#cfg.items
		for i = 1, itemnum do
			local itemid = cfg.items[i - 1]
			local itemnum = cfg.nums[i - 1]
			local hasnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
			if hasnum < itemnum then
				LogInsane("Not enough item"..itemid)
				return true
			end
		end
	end
	--]]
	local p = require "protocoldef.knight.gsp.item.cjinglianappendattr":new()
	p.equipitemkey = self.m_pSelectedItem.Frame:getID()
	p.appendattrid = effect.attrid
	p.index = idx - 1
	p.level = effect.attrnum
	require "manager.luaprotocolmanager":send(p)
	return true
end

local confirmCzAttrType = nil
local function confirmCzAttr()
	if confirmCzAttrType then
         GetMessageManager():CloseConfirmBox(confirmCzAttrType, false)
     end
     confirmCzAttrType = nil
    
    local self = WorkshopJl:getInstance()
    if not self then
    	return
    end
    
     if self.mode ~= 2 then
		return
	end
	if not self.m_pSelectedItem or not self.m_pSelectedAttr then
		return
	end
	local idx
	for i = 1, #self.m_pAppendAttrs do
		if self.m_pSelectedAttr == self.m_pAppendAttrs[i] then
			idx = i
			break
		end
	end
	assert(idx)
     local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
		self.m_pSelectedItem.Frame:getID())
	assert(equipobj and #equipobj.plusEffec >= idx)
	local effect = equipobj.plusEffec[idx]
	local p = require "protocoldef.knight.gsp.item.crenewappendattr":new()
	p.equipitemkey = self.m_pSelectedItem.Frame:getID()
	p.appendattrid = effect.attrid
	p.level = effect.attrnum
	p.index = idx - 1
	require "manager.luaprotocolmanager":send(p)
end

function WorkshopJl:HandleCzOkBtnClicked(e)
	if self.mode ~= 2 then
		return false
	end
	if not self.m_pSelectedItem or not self.m_pSelectedAttr then
		return true
	end
	local idx
	for i = 1, #self.m_pAppendAttrs do
		if self.m_pSelectedAttr == self.m_pAppendAttrs[i] then
			idx = i
			break
		end
	end
	assert(idx)
	--[[
	local yuanbaonum = GetDataManager():GetYuanBaoNumber()
	if yuanbaonum < NeedYuanbaoNum then
		LogInsane("Not enough yuanbao")
		return true
	end
	--]]
--	local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145301).msg
  --  local t = require "utils.mhsdutils"
     --[[
    local sb = require "utils.stringbuilder":new()
	local needyuanbao = self.yuanbaonum
    sb:SetNum("parameter1", needyuanbao)
    --]]
  --  confirmCzAttrType = t.addConfirmDialog(msg, confirmCzAttr)
    
     local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
		self.m_pSelectedItem.Frame:getID())
	assert(equipobj and #equipobj.plusEffec >= idx)
	local effect = equipobj.plusEffec[idx]
	local p = require "protocoldef.knight.gsp.item.crenewappendattr":new()
	p.equipitemkey = self.m_pSelectedItem.Frame:getID()
	p.appendattrid = effect.attrid
	p.level = effect.attrnum
	p.index = idx - 1
	require "manager.luaprotocolmanager":send(p)
	
	return true
end
function WorkshopJl:OnClose()
	require "ui.dialog".OnClose(self)
	GetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	GetRoleItemManager().EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
	getmetatable(self)._instance = nil
end
function WorkshopJl:DestroyDialog()
	if self.m_LinkLabel then
		self.m_LinkLabel:OnClose()
		self.m_LinkLabel = nil
	else
		self:OnClose()
	end
	getmetatable(self)._instance = nil
end

function WorkshopJl.OnItemNumChange(bagid, itemkey, itembaseid)
	local self = WorkshopJl:getInstanceOrNot()
	if not self then
		return
	end
	if not self.m_pSelectedItem or not self.m_pSelectedAttr then
		return
	end
	if self.mode ~= 1 then
		return
	end
	local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
		self.m_pSelectedItem.Frame:getID())
	if not equipobj then
		return
	end
	--#obj.plusEffec
	for i = 1, #self.m_pAppendAttrs do
		if self.m_pSelectedAttr == self.m_pAppendAttrs[i] then
			local effect = equipobj.plusEffec[i]
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cshuxingxiaohao", effect.attrnum)
			if not cfg or cfg.id == -1 then
				return
			end
			local itemnum = require "utils.tableutil".tablelength(cfg.items)
			for j = 1, itemnum do
				local material = self.m_pMaterials[j]
				local itemid = cfg.items[j - 1]
				if itembaseid == itemid then
					local itemnum = cfg.nums[j - 1]
					local hasnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
					if hasnum >= itemnum then
						material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
					else
						material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
					end
				end
			end
			break
		end
	end
end

function WorkshopJl.OnMoneyChange()
	local self = WorkshopJl:getInstanceOrNot()
	if not self then
		return
	end
	if not self.m_pSelectedItem or not self.m_pSelectedAttr then
		return
	end
	if self.mode ~= 1 then
		return
	end
	local equipobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP,
		self.m_pSelectedItem.Frame:getID())
	if not equipobj then
		return
	end
	for i = 1, #self.m_pAppendAttrs do
		if self.m_pSelectedAttr == self.m_pAppendAttrs[i] then
			local effect = equipobj.plusEffec[i]
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cshuxingxiaohao", effect.attrnum)
			if not cfg or cfg.id == -1 then
				return
			end
			local itemnum = require "utils.tableutil".tablelength(cfg.items)
			if #self.m_pMaterials > itemnum then
				local material = self.m_pMaterials[itemnum + 1]
				local hasmoney = GetRoleItemManager():GetPackMoney()
				if hasmoney >= cfg.needmoney then
					material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
				else
					material.m_pItem:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
				end
			end
			break
		end
	end
end

return WorkshopJl