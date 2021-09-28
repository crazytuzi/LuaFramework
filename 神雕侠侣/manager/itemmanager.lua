local itemmanager = {}
local	EQUIP = 8
local PET = 1
local PETAMULET = 161
local JEWELRY = 6
local function make_producecard(_os_)
	local self = require "protocoldef.rpcgen.knight.gsp.item.tickettipsoctets":new()
	self.bNeedRequireself = false
	self:unmarshal(_os_)
	return self
end

local function getBagItem(bagid)
	for i = 1, #itemmanager do
		if itemmanager[i].bagid == bagid then
			return itemmanager[i]
		end
	end
	local bagitems = {}
	bagitems.bagid = bagid
	table.insert(itemmanager, bagitems)
	return bagitems
end

local function getItemFirstType(itemtypeid)
	return itemtypeid % 0x10
end
local function GetSecondType(itemtypeid)
	local n = math.floor(itemtypeid / 0x10)
	return n % 0x10
end

function itemmanager.push_data(bagid, itemkey, tips)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if pItem == nil then
		return
	end
	local data = GNET.Marshal.OctetsStream(tips)
	local itemobj
	if getItemFirstType(pItem:GetItemTypeID()) == EQUIP then
		if GetSecondType(pItem:GetItemTypeID()) == JEWELRY then
			itemobj = require "protocoldef.rpcgen.knight.gsp.item.decorationtipsoctets":new()
			itemobj:unmarshal(data)
		else
			local index, item_local = require "ui.workshop.workshophelper".GetLocalItem(pItem:GetItemTypeID())
			if item_local then
				itemobj = require "manager.octets2table.equip"(data)
			--	items[itemkey] = itemobj
			
			end
		end
	elseif pItem:GetBaseObject().itemtypeid == 2454 then
		itemobj = make_producecard(data)
	elseif getItemFirstType(pItem:GetItemTypeID()) == PET and pItem:GetBaseObject().itemtypeid == PETAMULET then
		itemobj = require "protocoldef.rpcgen.knight.gsp.item.petamulettipsoctets":new()
		itemobj:unmarshal(data)
	end
	if itemobj then
		local items = getBagItem(bagid)
			for i = 1, #items do
				if items[i].itemkey == itemkey then
					items[i].itemobj = itemobj
					return
				end
			end
		local item = {}
		item.itemkey = itemkey
		item.itemobj = itemobj
		table.insert(items, item)
	end
end

function itemmanager.getObject(bagid, itemkey)
	for i = 1, #itemmanager do
		if itemmanager[i].bagid == bagid then
			for j = 1, #itemmanager[i] do
				if itemmanager[i][j].itemkey == itemkey then
					return itemmanager[i][j].itemobj
				end
			end
		end
	end
	return nil
end

return itemmanager