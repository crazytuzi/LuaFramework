local bag = {
	max = 48,
	isHero = false,
	items = {},
	quickItems = {},
	customs = {},
	throwing = {},
	eat = {},
	take = {},
	split = {},
	fusion = {},
	npcItemIdent = {},
	strengthen = {},
	upgradeWeapon = {},
	jewelryComposition = {},
	milRankComposition = {},
	horseSoulPanel = {},
	f2fDeal = {},
	clothComposition = {
		material = {}
	},
	name2Index = {}
}
gItemOp = {
	isPileUp = function (self)
		if self.getVar(self, "name") ~= "" and self.FItemIdent ~= 0 then
			return 150 < self.getVar(self, "stdMode")
		end

		return 
	end,
	isBinded = function (self)
		if self.getVar(self, "normalStateSet") then
			return ycFunction:band(self.getVar(self, "normalStateSet"), 2) ~= 0
		elseif self.getVar(self, "stdMode") == 2 then
			return self.getVar(self, "shape") == 10 or self.getVar(self, "shape") == 23 or self.getVar(self, "shape") == 31
		elseif self.getVar(self, "stdMode") == 3 then
			return self.getVar(self, "shape") == 30
		end

		return 
	end,
	isNeedResetPos = function (self, target)
		if self.FDuraMax < self.FDura + target.FDura then
			return true
		end

		return 
	end,
	isCanPileUp = function (self, target)
		if not target then
			return false
		end

		if not self.isPileUp(self) or not target.isPileUp(target) then
			return false
		end

		if self.isBinded(self) ~= target.isBinded(target) then
			return false
		end

		if self.getVar(self, "stdMode") ~= target.getVar(target, "stdMode") then
			return false
		end

		if self.getVar(self, "shape") ~= target.getVar(target, "shape") then
			return false
		end

		if self.getVar(self, "name") ~= target.getVar(target, "name") then
			return false
		end

		if self.FItemIdent == target.FItemIdent then
			return false
		end

		if self.FDuraMax <= self.FDura or target.FDuraMax <= target.FDura then
			return false
		end

		if self.FDura <= 0 or target.FDura <= 0 then
			return false
		end

		return true
	end,
	getStd = function (self)
		return _G.def.items[tonumber(self.FIndex)] or _G.def.items.defaultItem
	end,
	getVar = function (self, name)
		local value = self.extendField and self.extendField[name]

		if value == nil then
			if not self._item then
				self._item = self.getStd(self)
			end

			value = self._item and self._item[name]
		end

		return value
	end,
	setIndex = function (self, index)
		self.FIndex = index
		self._item = self.getStd(self)

		assert(self._item, "item should be exist")

		return 
	end,
	isMysicItem = function (self, stdMode, shape)
		if checkExist(stdMode or 0, 15, 19, 20, 21, 22, 23, 24, 26) then
			slot3 = checkExist(shape or 0, 130, 131, 132)
		end

		return slot3
	end,
	isGoodItem = function (self)
		if self.goodItem then
			return self.goodItem
		end

		local function getData(k)
			return self:getVar(k)
		end

		local function getDataStd(k)
			return self:getStd():get(k)
		end

		local function checkGood(key)
			local front = getData(key) or 0
			local after = getData("max" .. key) or 0

			if 0 < front or 0 < after then
				local normalAfter = getDataStd("max" .. key)

				if normalAfter and normalAfter < after then
					return true
				end
			end

			return 
		end

		local function checkGood2(value, normalValue)
			if normalValue and normalValue < value then
				return true
			end

			return 
		end

		local stdMode = self.getVar(slot0, "stdMode")
		local checkBase = nil

		if checkExist(stdMode, 5, 6, 19, 20, 21, 23, 24) then
			checkBase = {
				"DC",
				"MC",
				"SC"
			}
		elseif checkExist(stdMode, 10, 11, 15, 16, 22, 26, 27, 28, 37) then
			checkBase = {
				"AC",
				"MAC",
				"DC",
				"MC",
				"SC"
			}
		end

		if checkBase then
			for i = 1, #checkBase, 1 do
				if checkGood(checkBase[i]) then
					self.goodItem = true

					return true
				end
			end
		end

		local checkOther = {}
		local source = getData("source")
		local sourceN = getDataStd("source")
		local AC = getData("AC")
		local maxAC = getData("maxAC")
		local MAC = getData("MAC")
		local maxMAC = getData("maxMAC")
		local ACN = getDataStd("AC")
		local maxACN = getDataStd("maxAC")
		local MACN = getDataStd("MAC")
		local maxMACN = getDataStd("maxMAC")

		if checkExist(stdMode, 5, 6) then
			if checkIn(source, 1, 10) then
				checkOther[#checkOther + 1] = {
					source,
					sourceN
				}
			elseif checkIn(source, -50, -1) then
				checkOther[#checkOther + 1] = {
					-source,
					-sourceN
				}
			end

			if 0 < maxAC then
				local ac = getData("accurate") or maxAC
				checkOther[#checkOther + 1] = {
					ac,
					maxACN
				}
			end

			if 10 < maxMAC then
				if macN then
					macN = maxMACN
					macN = (10 < macN and macN - 10) or macN
				end

				checkOther[#checkOther + 1] = {
					maxMAC - 10,
					macN
				}
			end

			if 0 < AC then
				checkOther[#checkOther + 1] = {
					AC,
					ACN
				}
			end
		elseif checkExist(stdMode, 19, 20, 24) then
			if 0 < maxAC then
				checkOther[#checkOther + 1] = {
					maxAC,
					maxACN
				}
			end

			if 0 < maxMAC then
				checkOther[#checkOther + 1] = {
					maxMAC,
					maxMACN
				}
			end
		elseif checkExist(stdMode, 21, 23) then
			if 0 < maxAC then
				checkOther[#checkOther + 1] = {
					maxAC,
					maxACN
				}
			end

			if 0 < maxMAC then
				checkOther[#checkOther + 1] = {
					maxMAC,
					maxMACN
				}
			end

			if 0 < AC then
				checkOther[#checkOther + 1] = {
					AC,
					ACN
				}
			end
		end

		if 0 < #checkOther then
			for i, v in ipairs(checkOther) do
				if checkGood2(v[1], v[2]) then
					self.goodItem = true

					return true
				end
			end
		end

		self.goodItem = false

		return false
	end,
	decodedCallback = function (self)
		self._item = self.getStd(self)

		if not self._item then
			return 
		end

		self.extendField = {}
		local keyValueRecords = self.FItemValueList

		for _, v in ipairs(keyValueRecords) do
			local valueType = v.FValueType
			local value = v.FValue

			if _G.def.items.valueType2Key[valueType] then
				self.extendField[_G.def.items.valueType2Key[valueType]] = value
			end
		end

		return 
	end
}
bag.setName2Index = function (self, name, i)
	if not name or not i then
		return 
	end

	if not self.name2Index[name] then
		self.name2Index[name] = {
			indexs = {},
			num = 0
		}
	end

	local itemIndex = self.name2Index[name]

	table.insert(itemIndex.indexs, 1, i)

	itemIndex.num = itemIndex.num + 1

	return 
end
bag.delName2Index = function (self, name, i)
	if not name or not i then
		return 
	end

	local itemIndex = self.name2Index[name]

	if itemIndex then
		local num = itemIndex.num
		local indexs = itemIndex.indexs
		local pos = table.indexof(indexs, i)

		for k = pos, num, 1 do
			indexs[k] = indexs[k + 1]
		end

		indexs[num] = nil
		itemIndex.num = num - 1
	end

	return 
end
bag.set = function (self, result)
	self.items = {}
	self.name2Index = {}
	self.throwing = {}
	self.eat = {}
	self.take = {}

	self.delAllQuickItem(self)

	for k, v in ipairs(result.FList) do
		if not self.isInOperatePanel(self, v) then
			self.items[#self.items + 1] = v

			setmetatable(v, {
				__index = gItemOp
			})
			v.decodedCallback(v)
			self.setName2Index(self, v.getVar(v, "name"), #self.items)
		end
	end

	for i, v in pairs(self.quickItems) do
		self.fillQuickItemTest(self, i)
	end

	g_data.eventDispatcher:dispatch("M_BAGITEM_CHG")

	return 
end
bag.isInOperatePanel = function (self, v)
	local isInPanel = false

	if self.isInFusion(self, v) or self.isInStrengthen(self, v) or self.isInNecklaceIdent(self, v) or self.isInclothComposition(self, v) or self.isupgradeWeapon(self, v) or self.isnpcItemIdent(self, v) or self.isInJewelryComposition(self, v) or self.ismilRankComposition(self, v) or self.ishorseSoulPanel(self, v) or self.isInf2fDeal(self, v) or self.isInMedalOperate(self, v) then
		isInPanel = true
	end

	return isInPanel
end
bag.isInFusion = function (self, item)
	for i, v in pairs(self.fusion) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.isInJewelryComposition = function (self, item)
	for i, v in pairs(self.jewelryComposition) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.isInStrengthen = function (self, item)
	for i, v in pairs(self.strengthen) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.isInf2fDeal = function (self, item)
	for i, v in pairs(self.f2fDeal) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.isInNecklaceIdent = function (self, item)
	local neck = self.necklaceIdent

	if self.necklaceIdent and item.FItemIdent == self.necklaceIdent.FItemIdent then
		return true
	end

	return false
end
bag.isInclothComposition = function (self, item)
	if self.clothComposition then
		for k, v in pairs(self.clothComposition.material) do
			if item.FItemIdent == v.FItemIdent then
				return true
			end
		end
	end

	return false
end
bag.isupgradeWeapon = function (self, item)
	for i, v in pairs(self.upgradeWeapon) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.isnpcItemIdent = function (self, item)
	for i, v in pairs(self.npcItemIdent) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.ismilRankComposition = function (self, item)
	for i, v in pairs(self.milRankComposition) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.ishorseSoulPanel = function (self, item)
	for i, v in pairs(self.horseSoulPanel) do
		if item.FItemIdent == v.FItemIdent then
			return true
		end
	end

	return false
end
bag.setItemMedalOperateState = function (self, item, op)
	if not item then
		return 
	end

	if op then
		self.medalOperate = item
	else
		self.medalOperate = nil
	end

	return 
end
bag.isInMedalOperate = function (self, item)
	if not self.medalOperate then
		return false
	end

	return self.medalOperate.FItemIdent == item.FItemIdent
end
bag.equipAmulet = function (self, force)
	local amuletNames = {
		"护身符"
	}
	local item, where = nil

	for k, am in ipairs(amuletNames) do
		for k, v in pairs(self.items) do
			if string.find(v.getVar(v, "name"), am) then
				item = v
				where = getTakeOnPosition(item.getVar(item, "stdMode"))

				break
			end
		end

		if item then
			break
		end

		for k, v in pairs(self.quickItems) do
			if v.item and am == v.item:getVar("name") then
				item = v
				where = getTakeOnPosition(item.getVar(item, "stdMode"))

				break
			end
		end

		if item then
			break
		end
	end

	if item and self.use(self, "take", item.FItemIdent, {
		where = where,
		force = force
	}) then
		local bagPanel = main_scene.ui.panels.bag

		if bagPanel then
			bagPanel.delItem(bagPanel, item.FItemIdent)
		end

		return true
	end

	return false
end
bag.addItem = function (self, data)
	for i = 1, self.max, 1 do
		if self.items[i] and self.items[i].FItemIdent == data.FItemIdent then
			print("这物品已经在包里了")

			return i
		end

		if not self.items[i] then
			self.items[i] = data

			self.setName2Index(self, data.getVar(data, "name"), i)
			self.addItemForQuickBtn(self, data)

			return i
		end
	end

	return 
end
bag.add = function (self, result)
	local ret = {}
	local data_ = result.FItem

	setmetatable(data_, {
		__index = gItemOp
	})
	data_.decodedCallback(data_)
	self.addItem(self, data_)

	ret[#ret + 1] = {
		where = "bag",
		data = data_
	}

	return ret
end
bag.upt = function (self, result)
	local data = result.FItem

	setmetatable(data, {
		__index = gItemOp
	})
	data.decodedCallback(data)

	if self.isInStrengthen(self, data) then
		for k, v in pairs(self.strengthen) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.strengthen[k] = data

				return data.FItemIdent
			end
		end
	elseif self.isInNecklaceIdent(self, data) then
		if self.necklaceIdent.FItemIdent == data.FItemIdent and self.necklaceIdent:getVar("name") == data.getVar(data, "name") then
			self.necklaceIdent = data

			return data.FItemIdent
		end
	elseif self.isInclothComposition(self, data) then
		if self.clothComposition.material then
			for k, v in pairs(self.clothComposition.material) do
				if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
					self.clothComposition.material[k] = data

					return data.FItemIdent
				end
			end
		end
	elseif self.isupgradeWeapon(self, data) then
		for k, v in pairs(self.upgradeWeapon) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.upgradeWeapon[k] = data

				return data.FItemIdent
			end
		end
	elseif self.isnpcItemIdent(self, data) then
		for k, v in pairs(self.npcItemIdent) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.npcItemIdent[k] = data

				return data.FItemIdent
			end
		end
	elseif self.ismilRankComposition(self, data) then
		for k, v in pairs(self.milRankComposition) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.milRankComposition[k] = data

				return data.FItemIdent
			end
		end
	elseif self.ishorseSoulPanel(self, data) then
		for k, v in pairs(self.horseSoulPanel) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.horseSoulPanel[k] = data

				return data.FItemIdent
			end
		end
	elseif self.isInf2fDeal(self, data) then
		for k, v in pairs(self.f2fDeal) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.f2fDeal[k] = data

				return data.FItemIdent
			end
		end
	else
		for k, v in pairs(self.items) do
			if v.FItemIdent == data.FItemIdent and v.getVar(v, "name") == data.getVar(data, "name") then
				self.items[k] = data

				self.setName2Index(self, data.getVar(data, "name"), k)

				return data.FItemIdent
			end
		end
	end

	return 
end
bag.bindQuickItem = function (self, btnid, use, callback)
	if self.quickItems[btnid] then
		return 
	end

	self.quickItems[btnid] = {
		use = use,
		callback = callback
	}

	return 
end
bag.bindCustomsItem = function (self, btnid, use, makeIndex, callback)
	self.bindQuickItem(self, btnid, use, callback)

	local quick = self.quickItems[btnid]
	quick.custom = true

	for k, v in ipairs(quick.use) do
		for i, v2 in pairs(self.items) do
			if v2.FItemIdent == tonumber(makeIndex) then
				quick.item = v2

				quick.callback(v2.FItemIdent)

				quick.itemName = v2.getVar(v2, "name")

				for id, i_quick in pairs(self.quickItems) do
					if id ~= btnid and i_quick.item and i_quick.item.FItemIdent == makeIndex then
						i_quick.callback()

						i_quick.item = nil

						self.fillQuickItemTest(self, id)
					end
				end
			end
		end
	end

	return 
end
bag.isInQuicks = function (self, makeIndex)
	for k, v in pairs(self.quickItems) do
		if v.custom and v.item and v.item.FItemIdent == tonumber(makeIndex) then
			return true
		end
	end

	return false
end
bag.unbindQuickItem = function (self, btnid)
	if self.quickItems[btnid] then
		self.quickItems[btnid] = nil
	end

	return 
end
bag.addItemForQuickBtn = function (self, data)
	for k, v in pairs(self.quickItems) do
		if not v.item then
			for i, v2 in ipairs(v.use) do
				if data.getVar(data, "name") == v2 and not self.isInQuicks(self, data.FItemIdent) then
					v.item = data

					v.callback(data.FItemIdent)
				end
			end
		end
	end

	g_data.eventDispatcher:dispatch("M_BAGITEM_CHG")

	return 
end
bag.fillQuickItemTest = function (self, btnid)
	local quick = self.quickItems[btnid]

	if not quick then
		return 
	end

	if quick.item then
		return 
	end

	if quick.itemName then
		for k, v in pairs(self.items) do
			if v.getVar(v, "name") == quick.itemName and not self.isInQuicks(self, v.FItemIdent) then
				quick.item = v

				quick.callback(v.FItemIdent)

				quick.item.fill = true

				return 
			end
		end
	end

	for k, v in ipairs(quick.use) do
		for i, v2 in pairs(self.items) do
			if v2.getVar(v2, "name") == v and not self.isInQuicks(self, v2.FItemIdent) then
				quick.item = v2

				quick.callback(v2.FItemIdent)

				quick.itemName = v2.getVar(v2, "name")
				quick.item.fill = true

				return 
			end
		end
	end

	return 
end
bag.delQuickItem = function (self, makeIndex)
	for k, v in pairs(self.quickItems) do
		if v.item and v.item.FItemIdent == tonumber(makeIndex) then
			v.callback()

			v.item = nil

			break
		end
	end

	return 
end
bag.delAllQuickItem = function (self)
	for k, v in pairs(self.quickItems) do
		if v.item then
			v.callback()

			v.item = nil
		end
	end

	return 
end
bag.getQuickItemCount = function (self)
	local cnt = 0

	for k, v in pairs(self.quickItems) do
		if v.item then
			cnt = cnt + 1
		end
	end

	return cnt
end
bag.getItem = function (self, makeIndex)
	for k, v in pairs(self.items) do
		if makeIndex == v.FItemIdent then
			return k, v
		end
	end

	return 
end
bag.getItemByIndex = function (self, itemIndex)
	for k, v in pairs(self.items) do
		if itemIndex == v.FIndex then
			return k, v
		end
	end

	return 
end
bag.getItemTotalNumByIndex = function (self, itemIndex)
	local itemNum = 0

	for k, v in pairs(self.items) do
		if itemIndex == v.FIndex then
			itemNum = itemNum + v.FDura
		end
	end

	return itemNum
end
bag.getItemStrengthen = function (self, makeIndex)
	for k, v in pairs(self.strengthen) do
		if makeIndex == v.FItemIdent then
			return v
		end
	end

	return 
end
bag.getItemf2fDeal = function (self, makeIndex)
	for k, v in pairs(self.f2fDeal) do
		if makeIndex == v.FItemIdent then
			return v
		end
	end

	return 
end
bag.getItemNecklaceIdent = function (self, makeIndex)
	if makeIndex == self.necklaceIdent.FItemIdent then
		return self.necklaceIdent
	end

	return 
end
bag.getItemclothComposition = function (self, makeIndex)
	if self.clothComposition and self.clothComposition.material then
		for k, v in pairs(self.clothComposition.material) do
			if makeIndex == v.FItemIdent then
				return v
			end
		end
	end

	return 
end
bag.getupgradeWeapon = function (self, makeIndex)
	for k, v in pairs(self.upgradeWeapon) do
		if makeIndex == v.FItemIdent then
			return v
		end
	end

	return 
end
bag.getnpcItemIdent = function (self, makeIndex)
	for k, v in pairs(self.npcItemIdent) do
		if makeIndex == v.FItemIdent then
			return v
		end
	end

	return 
end
bag.getmilRankComposition = function (self, makeIndex)
	for k, v in pairs(self.milRankComposition) do
		if makeIndex == v.FItemIdent then
			return v
		end
	end

	return 
end
bag.gethorseSoulPanel = function (self, makeIndex)
	for k, v in pairs(self.horseSoulPanel) do
		if makeIndex == v.FItemIdent then
			return v
		end
	end

	return 
end
bag.getItemWithTable = function (self, names)
	for i, v in ipairs(names) do
		for k, v2 in pairs(self.items) do
			if v == v2.getVar(v2, "name") then
				return v2, "bag"
			end
		end
	end

	return 
end
bag.getBagItemCounts = function (self)
	local count = 0

	for k, v2 in pairs(self.items) do
		count = count + 1
	end

	return count
end
bag.getItemWithName = function (self, name)
	local itemIndex = self.name2Index[name]

	if itemIndex and itemIndex.indexs and 0 < itemIndex.num then
		return self.items[itemIndex.indexs[1]], "bag"
	end

	return 
end
bag.getItemWithstdMode = function (self, mods)
	for k, v in pairs(self.items) do
		for i = 1, #mods, 1 do
			if v.getVar(v, "stdMode") == mods[i] then
				return v, "bag"
			end
		end
	end

	return 
end
bag.getItemsWithstdMode = function (self, mods)
	local items = {}

	for k, v in pairs(self.items) do
		for i = 1, #mods, 1 do
			if v.getVar(v, "stdMode") == mods[i] then
				items[#items + 1] = v
			end
		end
	end

	return items
end
bag.getItemWithShortName = function (self, name)
	local function getItem(sName)
		for k, v in pairs(self.items) do
			local itemName = v.getVar(v, "name")

			if string.find(itemName, sName) then
				return v
			end
		end

		return 
	end

	local tarItem = nil

	if type(slot1) == "table" then
		for i, v in ipairs(name) do
			if type(v) == "string" then
				tarItem = getItem(v)

				if tarItem then
					return tarItem, "bag"
				end
			end
		end
	elseif type(name) == "string" then
		tarItem = getItem(name)

		if tarItem then
			return tarItem, "bag"
		end
	end

	return 
end
bag.getAllItemsWithShortName = function (self, name)
	local items = {}

	local function getItem(sName)
		for k, v in pairs(self.items) do
			local itemName = v.getVar(v, "name")

			if string.find(itemName, sName) then
				items[#items + 1] = v
			end
		end

		return 
	end

	if type(slot1) == "table" then
		for i, v in ipairs(name) do
			if type(v) == "string" then
				getItem(v)
			end
		end
	elseif type(name) == "string" then
		getItem(name)
	end

	return items, "bag"
end
bag.getItemWithNameAndDura = function (self, name, dura)
	local function getItem(sName, dura)
		for k, v in pairs(self.items) do
			local itemName = v.getVar(v, "name")

			if string.find(itemName, sName) and dura <= v.FDura then
				return v
			end
		end

		return 
	end

	return slot3(name, dura)
end
bag.getItemCount = function (self, name)
	local cnt = 0
	local item1 = self.getItemWithName(self, name)

	if item1 then
		local itemIndex = self.name2Index[name]

		if item1.isPileUp(item1) then
			for i = 1, itemIndex.num, 1 do
				local index = itemIndex.indexs[i]
				cnt = cnt + self.items[index].FDura
			end
		else
			cnt = itemIndex.num
		end
	end

	return cnt
end
bag.getFreeCount = function (self)
	local cnt = 0

	for i = 1, self.max, 1 do
		if not self.items[i] then
			cnt = cnt + 1
		end
	end

	return cnt
end
bag.delItem = function (self, makeIndex)
	self.delQuickItem(self, makeIndex)

	local isSuccess = nil

	for k, v in pairs(self.items) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.delName2Index(self, v.getVar(v, "name"), k)

			self.items[k] = nil
			isSuccess = true
		end
	end

	if isSuccess then
		for k, v in pairs(self.quickItems) do
			if v.item and v.item.FItemIdent == tonumber(makeIndex) then
				v.callback()

				v.item = nil

				break
			end
		end
	end

	g_data.eventDispatcher:dispatch("M_BAGITEM_CHG")

	return isSuccess
end
bag.delStrengthenItem = function (self, makeIndex)
	for k, v in pairs(self.strengthen) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.strengthen[k] = nil
		end
	end

	return 
end
bag.delf2fDealItem = function (self, makeIndex)
	for k, v in pairs(self.f2fDeal) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.f2fDeal[k] = nil
		end
	end

	return 
end
bag.delNecklaceIdentItem = function (self, makeIndex)
	if self.necklaceIdent.FItemIdent == tonumber(makeIndex) then
		self.necklaceIdent = nil
	end

	return 
end
bag.delclothCompositionItem = function (self, makeIndex)
	for k, v in pairs(self.clothComposition.material) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.clothComposition.material[k] = nil
		end
	end

	return 
end
bag.delupgradeWeapon = function (self, makeIndex)
	for k, v in pairs(self.upgradeWeapon) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.upgradeWeapon[k] = nil
		end
	end

	return 
end
bag.delnpcItemIdent = function (self, makeIndex)
	for k, v in pairs(self.npcItemIdent) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.npcItemIdent[k] = nil
		end
	end

	return 
end
bag.delmilRankComposition = function (self, makeIndex)
	for k, v in pairs(self.milRankComposition) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.milRankComposition[k] = nil
		end
	end

	return 
end
bag.delhorseSoulPanel = function (self, makeIndex)
	for k, v in pairs(self.horseSoulPanel) do
		if v.FItemIdent == tonumber(makeIndex) then
			self.horseSoulPanel[k] = nil
		end
	end

	return 
end
bag.changePos = function (self, idx1, idx2)
	if self.items[idx1] then
		local name = self.items[idx1]:getVar("name")

		self.delName2Index(self, name, idx1)
		self.setName2Index(self, name, idx2)
	end

	if self.items[idx2] then
		local name = self.items[idx2]:getVar("name")

		self.delName2Index(self, name, idx2)
		self.setName2Index(self, name, idx1)
	end

	self.items[idx2] = self.items[idx1]
	self.items[idx1] = self.items[idx2]

	return 
end
bag.isAallCanPileUp = function (self, idx1, idx2)
	local item1 = self.items[idx1]
	local item2 = self.items[idx2]

	if item1 and item2 and item1.isCanPileUp(item1, item2) then
		return true
	end

	return false
end
bag.throw = function (self, makeIndex)
	local isSuccess = nil

	for k, v in pairs(self.items) do
		if makeIndex == v.FItemIdent then
			self.throwing[makeIndex] = v

			self.delName2Index(self, v.getVar(v, "name"), k)

			self.items[k] = nil
			isSuccess = true

			break
		end
	end

	if isSuccess then
		for k, v in pairs(self.quickItems) do
			if v.item and v.item.FItemIdent == tonumber(makeIndex) then
				v.callback()

				v.item = nil

				break
			end
		end
	end

	g_data.eventDispatcher:dispatch("M_BAGITEM_CHG")

	return 
end
bag.throwEnd = function (self, makeIndex, isSuccess)
	if not isSuccess and self.throwing[makeIndex] then
		self.addItem(self, self.throwing[makeIndex])
	end

	self.throwing[makeIndex] = nil

	return 
end
bag.use = function (self, action, makeIndex, params)
	local limit = 1

	if params and params.force then
		limit = 0.2
	end

	local time = socket.gettime()

	if self[action].item and socket.gettime() - self[action].time < limit then
		return 
	end

	local isSuccess = nil
	local itemPileUp = false
	local multiUse = false

	for k, v in pairs(self.items) do
		if makeIndex == v.FItemIdent then
			multiUse = v.getVar(v, "stdMode") == 2
			self[action].item = v
			self[action].time = socket.gettime()
			self[action].params = params
			itemPileUp = self.items[k]:isPileUp()

			if not itemPileUp and not multiUse then
				self.delName2Index(self, v.getVar(v, "name"), k)

				self.items[k] = nil
			end

			isSuccess = true

			break
		end
	end

	if isSuccess and not itemPileUp and not multiUse then
		for k, v in pairs(self.quickItems) do
			if v.item and v.item.FItemIdent == makeIndex then
				v.callback()

				v.item = nil
			end
		end
	end

	return isSuccess
end
bag.useEnd = function (self, action, isSuccess)
	local ret, item, isQuick, where = nil

	if self[action].item then
		item = self[action].item
		ret = item.FItemIdent
		isQuick = self[action].params and self[action].params.quick
		local isPile = item.isPileUp(item)
		local multiUse = item.getVar(item, "stdMode") == 2

		if not isPile and not multiUse then
			if isSuccess then
				if action == "take" then
					if self.isHero then
						g_data.heroEquip:setItem(self[action].params.where, item)
					else
						g_data.equip:setItem(self[action].params.where, item)
					end
				end
			else
				self.addItem(self, item)
			end
		end
	end

	self[action] = {}

	return ret, item, isQuick, where
end
bag.duraChange = function (self, makeindex, dura, duraMax, price)
	for k, v in pairs(self.items) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			g_data.eventDispatcher:dispatch("M_BAGITEM_CHG")

			return 
		end
	end

	if self.eat.item and makeindex == self.eat.item.FItemIdent then
		self.eat.item.FDura = dura
		self.eat.item.FDuraMax = duraMax
	end

	for k, v in pairs(self.strengthen) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	if makeindex == self.necklaceIdent then
		self.necklaceIdent.FDura = dura
		self.necklaceIdent.FDuraMax = duraMax

		return 
	end

	for k, v in pairs(self.clothComposition.material) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	for k, v in pairs(self.upgradeWeapon) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	for k, v in pairs(self.npcItemIdent) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	for k, v in pairs(self.milRankComposition) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	for k, v in pairs(self.horseSoulPanel) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	for k, v in pairs(self.f2fDeal) do
		if makeindex == v.FItemIdent then
			v.FDura = dura
			v.FDuraMax = duraMax

			return 
		end
	end

	return 
end
bag.PileUpNext = function (self)
	if g_data.player.inPileUping then
		return false
	end

	for i, v in pairs(self.items) do
		local ret = self.AutoItemAdd(self, v)

		if ret then
			return ret
		end
	end

	return 
end
bag.AutoItemAdd = function (self, item)
	for i, v in pairs(self.items) do
		if v.isCanPileUp(v, item) then
			return {
				v,
				item
			}
		end
	end

	return 
end
bag.tmpPrintItem = function (self, str)
	for i, v in pairs(self.items) do
		print(i, v.getVar(v, "name"), v.FItemIdent, v.getVar(v, "stdMode"), v.FDura)
	end

	return 
end
bag.addCustoms = function (self, custom_id, makeIndex, name, source)
	if not self.customs then
		self.customs = {}
	end

	self.customs[custom_id] = {
		makeIndex = makeIndex,
		name = name,
		source = source
	}

	return 
end
bag.delCustoms = function (self, custom_id)
	self.customs[custom_id] = nil

	return 
end
bag.getCustom = function (self, custom_id)
	if not self.customs then
		self.customs = {}
	end

	return self.customs[custom_id]
end

return bag
