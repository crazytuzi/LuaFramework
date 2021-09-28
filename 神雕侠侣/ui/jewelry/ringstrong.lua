local jewelryNum = 4
local maxAttrNum = 4
local materialNum = 3
local jewelryPos = {6, 7, 8, 9}
local MoneyIcon = 1262
local function GetUnequipString(idx)
	local itemtypeid = idx*0x100 + 0x68
	local cfg = knight.gsp.item.GetCItemTypeTableInstance():getRecorder(itemtypeid)
	assert(cfg.id ~= -1)
	return require "utils.mhsdutils".get_resstring(2736)..cfg.name
end

local function GetEquipItemTypeName(idx)
	local itemtypeid = idx*0x100 + 0x68
	local cfg = knight.gsp.item.GetCItemTypeTableInstance():getRecorder(itemtypeid)
	assert(cfg.id ~= -1)
	return cfg.name
end
local function setitemnum(cell, itemid, neednum)
	local hasnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
	cell:SetTextUnit(neednum)
	if hasnum >= neednum then
		cell:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
	else
		cell:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
	end
end
local function showitem(slot, attr)
	GetGameUIManager():RemoveUIEffect(slot.item)
	local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
	local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor)
	if colorconfig.id~= -1 then
		GetGameUIManager():AddUIEffect(slot.item, colorconfig.effectshow)
	end
	slot.item:SetImage(GetIconManager():GetItemIconByID(attr.icon))
	slot.item:setID(attr.id)
	slot.name:setText(attr.name)
	slot.name:setProperty("TextColours", attr.colour)
end
local function showEquipItem(slot, pItem)
	showitem(slot, pItem:GetBaseObject())
	slot.item:setID(pItem:GetThisID())
end
local function GetSchoolBuff(attrid)
	local schoolid = GetDataManager():GetMainCharacterSchoolID()
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryshuxingbuff", attrid)
	if not cfg then
		return 1
	end
	if schoolid == 11 then
		return cfg.gumu / 100
	elseif schoolid == 12 then
		return cfg.gaibang / 100
	elseif schoolid == 14 then
		return cfg.baituo / 100
	elseif schoolid == 15 then
		return cfg.dali / 100
	elseif schoolid == 17 then
		return cfg.taohua / 100
	end
	return 1
end
local single = require "ui.singletondialog"

local RingStrong = {}
setmetatable(RingStrong, single)
RingStrong.__index = RingStrong
function RingStrong.new()
	local self = {}
	setmetatable(self, RingStrong)
	function self.GetLayoutFileName()
		return "ringstrong.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.items = {}
	for i = 1, jewelryNum do
		local item = {}
		item.selected = winMgr:getWindow("ringstrong/seclect"..(i - 1))
		item.selected:setMousePassThroughEnabled(true)
		item.selected:setVisible(false)
		local framename = i == 1 and "ringstrong/left/item" or "ringstrong/left/item"..(i - 1)
		item.frame = winMgr:getWindow(framename)
		item.item = CEGUI.toItemCell(winMgr:getWindow(framename.."/cell"))
		item.name = winMgr:getWindow(framename.."/name")
		item.type = winMgr:getWindow(framename.."/type")
		item.name:setMousePassThroughEnabled(true)
		item.type:setMousePassThroughEnabled(true)
		require "utils.mhsdutils".SetEquipWindowShowtips(item.item)
		item.item:subscribeEvent("MouseClick", RingStrong.HandleJewelrySelected, self)
		item.frame:subscribeEvent("MouseClick", RingStrong.HandleJewelrySelected, self)
		table.insert(self.items, item)
	end
	self.attrs = {}
	for i = 1, maxAttrNum do
		local attr = {}
		local wndname = "ringstrong/right/top/item"..(i-1)
		attr.frame = CEGUI.toGroupButton(winMgr:getWindow(wndname))
		attr.name = winMgr:getWindow(wndname.."/name")
		attr.level = winMgr:getWindow(wndname.."/level")
		attr.value = winMgr:getWindow(wndname.."/num")
		local childcount = attr.frame:getChildCount()
		for i = 0, childcount - 1 do
			local child = attr.frame:getChildAtIdx(i)
			child:setMousePassThroughEnabled(true)
		end
		attr.frame:setID(i)
		attr.frame:setMousePassThroughEnabled(false)
		attr.frame:setVisible(false)
		attr.frame:setSelected(false)
		attr.frame:subscribeEvent("SelectStateChanged", RingStrong.HandleAttrSelected, self)
		table.insert(self.attrs, attr)
	end
	self.Material = winMgr:getWindow("ringstrong/right/bot")
	self.materials = {}
	for i = 1, materialNum do
		local material = {}
		local prefix = "ringstrong/right/bot/"
		material.item = CEGUI.toItemCell(winMgr:getWindow(prefix.."item"..(i - 1)))
		material.name = winMgr:getWindow(prefix.."name"..(i - 1))
		require "utils.mhsdutils".SetWindowShowtips(material.item)
		table.insert(self.materials, material)
	end
	self.materials[materialNum].item:SetImage(GetIconManager():GetItemIconByID(MoneyIcon))
	self.materials[materialNum].name:setText(require "utils.mhsdutils".get_resstring(2636))
	self.okbtn = CEGUI.toPushButton(winMgr:getWindow("ringstrong/right/ok"))
	self.okbtn:subscribeEvent("Clicked", RingStrong.HandleOkBtnClicked, self)
	local default
	for i = 1, #self.items do
		self.items[i].type:setText(GetEquipItemTypeName(i))
		local pItem = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, jewelryPos[i])
		if not pItem then
			self.items[i].frame:setID(0)
			self.items[i].item:setID(0)
			self.items[i].name:setText(GetUnequipString(i))
		else
			showEquipItem(self.items[i], pItem)
			self.items[i].frame:setID(pItem:GetThisID())
			if not default then
				default = i
			end
		end
	end
	self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(RingStrong.OnItemNumChange)
	self.m_hPackMoneyChange = GetRoleItemManager().EventPackMoneyChange:InsertScriptFunctor(RingStrong.RefreshMoney)
	if default then
		self:OnSelectedJewelry(default)
	end
	return self
end

function RingStrong:OnSelectedJewelry(idx, refreshidx)
	if self.selectedItem then
		self.items[self.selectedItem].selected:setVisible(false)
	end
	self.selectedItem = idx
	self.items[self.selectedItem].selected:setVisible(true)
	local pItem = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, jewelryPos[idx])
	if pItem then
		local itemobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, pItem:GetThisID())
		if not itemobj or itemobj.bNeedRequireself then
			local p = knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.EQUIP, pItem:GetThisID())
			GetNetConnection():send(p)
		else
			local default
			for i = 1, #self.attrs do
				if i > #itemobj.props then
					self.attrs[i].frame:setVisible(false)
				else
					
					self.attrs[i].frame:setVisible(true)
					local dvalue = itemobj.props[i]
					self.attrs[i].level:setText(dvalue.level.."/"..dvalue.maxlevel)
					local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryshuxing", 
						dvalue.propkey)
					local value = cfg.value[dvalue.level - 1] * GetSchoolBuff(dvalue.propkey)
    				self.attrs[i].value:setText("+"..(cfg.baifenbi == 0 and value or (value / 100).."%"))
    				local namecfg = knight.gsp.effect.GetCEffectConfigTableInstance():getRecorder(dvalue.propkey - 1)
					self.attrs[i].name:setText(namecfg.classname)
					if refreshidx and refreshidx == i then
						GetGameUIManager():AddUIEffect(self.attrs[i].frame, 
							require "utils.mhsdutils".get_effectpath(10401), false)
					end
					if not default then
						default = i
					end
				end
			end
			if refreshidx then
				if self.selectedAttr == refreshidx then
					self:OnAttrSelected()
				end
			else
				if  default then
					self.attrs[default].frame:setSelected(true)
				end
			end
		end
	end
end

function RingStrong:HandleJewelrySelected(e)
	
	local selected
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	if e.window:getID() == 0 then
		return false
	end
	for i = 1, #self.items do
		if self.items[i].frame == e.window or self.items[i].item == e.window then
			selected = i
			break
		end
	end
	if not selected then
		return true
	end
	if self.selectedAttr then
		self.attrs[self.selectedAttr].frame:setSelected(false)
		self.selectedAttr = nil
	end
	self:OnSelectedJewelry(selected)
	
	return true
end
function RingStrong:RefreshMoney()
	local self = self or RingStrong:getInstanceOrNot()
	if not self then
		return
	end
	local hasmoney = GetRoleItemManager():GetPackMoney()
	if not self.selectedAttr or not self.selectedItem then
		return
	end
	local needmoney = 0
	local attridx = self.selectedAttr
	local pItem = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, jewelryPos[self.selectedItem])
	if pItem then
		local itemobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, pItem:GetThisID())
		if itemobj then
			local dvalue = itemobj.props[attridx]
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryjinglian", dvalue.level)
			assert(cfg)
			needmoney = cfg.money
		end
	end

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

	self.materials[materialNum].item:SetTextUnit(str)

	strBuild:delete()

	if hasmoney >= needmoney then
		self.materials[materialNum].item:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
	else
		self.materials[materialNum].item:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
	end
end
function RingStrong:RefreshJewelryAttr(itemkey, idx)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.EQUIP)
	if not pItem then
		return
	end
	local refreshidx
	for i = 1, #jewelryPos do
		if jewelryPos[i] == pItem:GetLocation().position then
			refreshidx = i
			break
		end
	end
	self:OnSelectedJewelry(refreshidx, idx)
end
function RingStrong:OnAttrSelected()
	local attridx = self.selectedAttr
	local pItem = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, jewelryPos[self.selectedItem])
	if pItem then
		local itemobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, pItem:GetThisID())
		if itemobj then
			local dvalue = itemobj.props[attridx]
			self.Material:setVisible(dvalue.level ~= dvalue.maxlevel)
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryjinglian", dvalue.level)
			if cfg then
				local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.item1)
				showitem(self.materials[1], attr)
				setitemnum(self.materials[1].item, cfg.item1, cfg.num1)
				attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.item2)
				showitem(self.materials[2], attr)
				setitemnum(self.materials[2].item, cfg.item2, cfg.num2)
				self:RefreshMoney()
			end
		end
	end
end
function RingStrong:HandleAttrSelected(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	if not mouseArgs.window:isSelected() then
		return true
	end
	local attridx = mouseArgs.window:getID()
	assert(self.selectedItem)
	self.selectedAttr = attridx
	self:OnAttrSelected()
	return true
end
function RingStrong:OnClose()
	GetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	GetRoleItemManager().EventPackMoneyChange:RemoveScriptFunctor(self.m_hPackMoneyChange)
	if self._instance then
		getmetatable(self)._instance = nil
	end
	Dialog.OnClose(self)
end
function RingStrong:DestroyDialog()
	local dlg = require "ui.label".getLabelById("jewelry")
	if dlg then
		dlg:OnClose()
	else
		single.DestroyDialog(self)
	end
end

function RingStrong.OnItemNumChange(bagid, itemkey, itembaseid)
--[[
	local self = RingStrong:getInstanceOrNot()
	if not self then
		return
	end
	if not self.selectedAttr or not self.selectedItem then
		return
	end
	local attridx = self.selectedAttr
	local pItem = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, jewelryPos[self.selectedItem])
	if pItem then
		local itemobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, pItem:GetThisID())
		if itemobj then
			local dvalue = itemobj.props[attridx]
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryjinglian", dvalue.level)
			if cfg and (itembaseid == cfg.item1 or itembaseid == cfg.item2) then
				local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.item1)
				setitemnum(self.materials[1].item, cfg.item1, cfg.num1)
				attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.item2)
				setitemnum(self.materials[2].item, cfg.item2, cfg.num2)
				self:RefreshMoney()
			end
		end
	end
	--]]
end

function RingStrong:HandleOkBtnClicked(e)
	if not self.selectedAttr or not self.selectedItem then
		GetChatManager():AddTipsMsg(145402)
		return true
	end
	local attridx = self.selectedAttr
	local pItem = GetRoleItemManager():FindItemByBagIDAndPos(knight.gsp.item.BagTypes.EQUIP, jewelryPos[self.selectedItem])
	if pItem then
		local itemobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.EQUIP, pItem:GetThisID())
		if itemobj then
			local dvalue = itemobj.props[attridx]
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryjinglian", dvalue.level)
			
			local hasnum = GetRoleItemManager():GetItemNumByBaseID(cfg.item1)
			if hasnum < cfg.num1 then
				GetChatManager():AddTipsMsg(145385)
				return true
			end
			hasnum = GetRoleItemManager():GetItemNumByBaseID(cfg.item2)
			if hasnum < cfg.num2 then
				GetChatManager():AddTipsMsg(145385)
				return true
			end
			hasnum = GetRoleItemManager():GetPackMoney()
			if hasnum < cfg.money then
				GetChatManager():AddTipsMsg(120025)
				return true
			end
			local p = require "protocoldef.knight.gsp.item.crefinedecoration":new()
			p.itemkey = pItem:GetThisID()
			p.propindex = attridx - 1
			require "manager.luaprotocolmanager":send(p)
		end
	end
	return true
end

return RingStrong
