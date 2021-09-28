local items = {}
local itemDefs = def.itemDefs

local function checkExist(k, arr)
	for i, v in ipairs(arr) do
		if v == k then
			return true
		end
	end

	return 
end

g_itemConf = {
	get = function (self, k)
		return self[k]
	end,
	getVar = function (self, k)
		return self[k]
	end
}

local function renameItem(t)
	t.allowFlag = t.AllowFlag
	t.name = t.iname
	t.stdMode = t.Stdmode
	t.outlook = t.OutLook
	t.looks = t.Looks
	t.duraMax = t.DuraMax
	t.aniCount = t.anicount
	t.needConf = t.NeedConf
	t.maxAC = t.MaxAc
	t.maxMAC = t.MaxMAC
	t.maxDC = t.MaxDC
	t.maxMC = t.MaxMC
	t.maxSC = t.MaxSc
	t.maxCC = t.MaxCC
	t.needLevel = t.NeedLevel
	t.itemExtAbil = t.ItemExtAbil
	t.needJob = t.NeedJob
	t.AllowFlag = nil
	t.iname = nil
	t.Stdmode = nil
	t.OutLook = nil
	t.Looks = nil
	t.DuraMax = nil
	t.anicount = nil
	t.NeedConf = nil
	t.MaxAc = nil
	t.MaxMAC = nil
	t.MaxDC = nil
	t.MaxMC = nil
	t.MaxSc = nil
	t.MaxCC = nil
	t.NeedLevel = nil
	t.ItemExtAbil = nil
	t.NeedJob = nil

	return t
end

local function loadItems()
	local nameToIndex = {}
	items.names = {}
	local isNameNil = false

	for i, v in ipairs(itemDefs) do
		if not v.name then
			v = renameItem(v)
		end

		if v and v.name then
			nameToIndex[v.name] = i

			setmetatable(v, {
				__index = g_itemConf
			})

			items.names[v.name] = i
		else
			isNameNil = i
		end
	end

	if isNameNil then
		luaReportException("renameItem faild", "items-loadItems", "item index is " .. isNameNil)
	end

	table.merge(items, itemDefs)

	items.name2Index = nameToIndex

	local function initItem(param)
		local data = {}
		local defaultItem = {
			allowFlag = tonumber(data[2]) or 0,
			name = data[3] or "未知物品",
			stdMode = tonumber(data[4]) or 0,
			shape = tonumber(data[5]),
			source = tonumber(data[6]) or 0,
			outlook = tonumber(data[7]),
			looks = tonumber(data[8]) or 0,
			weight = tonumber(data[9]) or 0,
			duraMax = tonumber(data[10]) or 0,
			aniCount = tonumber(data[11]) or 0,
			needConf = tonumber(data[12]) or 0,
			AC = tonumber(data[13]) or 0,
			maxAC = tonumber(data[14]) or 0,
			MAC = tonumber(data[15]) or 0,
			maxMAC = tonumber(data[16]) or 0,
			DC = tonumber(data[17]) or 0,
			maxDC = tonumber(data[18]) or 0,
			MC = tonumber(data[19]) or 0,
			maxMC = tonumber(data[20]) or 0,
			SC = tonumber(data[21]) or 0,
			maxSC = tonumber(data[22]) or 0,
			CC = tonumber(data[23]) or 0,
			maxCC = tonumber(data[24]) or 0,
			need = tonumber(data[25]) or 0,
			needLevel = tonumber(data[26]) or 0,
			antiqueLv = tonumber(data[27]) or 0,
			wParam1 = tonumber(data[28]) or 0,
			wParam2 = tonumber(data[29]) or 0,
			intParam = tonumber(data[30]) or 0,
			itemScore = tonumber(data[31]) or 0,
			price = tonumber(data[32]) or 0,
			itemType1 = tonumber(data[33]) or 0,
			itemType2 = tonumber(data[34]) or 0,
			itemType3 = tonumber(data[35]) or 0,
			itemLevel = tonumber(data[36]) or 0,
			suitEquipType = tonumber(data[37]) or 0,
			intparam2 = tonumber(data[38]) or 0,
			intparam3 = tonumber(data[39]) or 0,
			maxSteelLv = tonumber(data[40]) or 0,
			maxVeinsLv = tonumber(data[41]) or 0,
			baseEffectID = tonumber(data[42]) or 0,
			itemExtAbil = data[43],
			needJob = tonumber(data[44]) or 7,
			ItemConf = tonumber(data[45]) or 0
		}

		setmetatable(defaultItem, g_itemConf)

		return defaultItem
	end

	items.defaultItem = renameItem()
	local descfile = res.getfile("config/itemdesc.txt")
	local descdatas = string.split(descfile, "\n")
	items.desc = {}

	for i, v in ipairs(descdatas) do
		if v ~= "" then
			local data = string.split(v, "=")
			items.desc[data[1]] = data[2]
		end
	end

	return 
end

scheduler.performWithDelayGlobal(slot4, 0)

itemDiuqi = import("csv2cfg.diuqi")
items.getItemsDiuqi = function (name)
	for i, v in ipairs(itemDiuqi) do
		if v.name == name then
			return v
		end
	end

	return nil
end
local autoItems = import("csv2cfg.autoUseItem")
local index = {}

for k, v in ipairs(slot5) do
	index[v.name] = v
end

setmetatable(autoItems, {
	__index = index
})

items.autoUse = autoItems
items.initFilt = function ()
	local filtFileName = "config/itemFilt180.txt"
	local filterfile = res.getfile(filtFileName)
	local filterdatas = string.split(filterfile, "\n")
	items.filt = {}
	items.filtNames = {}
	local category = {}

	for i, v in ipairs(filterdatas) do
		if v ~= "" then
			local data = string.split(v, ",")
			items.filt[data[1]] = {
				category = data[2],
				pickOnRatting = string.find(data[3], "1") ~= nil,
				pickUp = string.find(data[4], "1") ~= nil,
				hintName = string.find(data[5], "1") ~= nil,
				isGood = string.find(data[6], "1") ~= nil
			}
			local showNum = (data[7] and data[7]) or "0"
			local isShow = string.find(showNum, "1") ~= nil
			items.filt[data[1]].isShow = isShow
			items.filtNames[#items.filtNames + 1] = data[1]
			category[data[2]] = true
		end
	end

	items.category = {}

	for k, v in pairs(category) do
		table.insert(items.category, k)
	end

	return 
end
items.getItemIdByName = function (name)
	if items.name2Index then
		return items.name2Index[name]
	end

	return 
end
items.getItemById = function (id)
	if id and id <= #items then
		return items[id]
	else
		return nil
	end

	return 
end
items.setStdItemData = function (baseItem, index)
	local item = {
		FIndex = index,
		FDura = (baseItem and baseItem.duraMax) or 0,
		FDuraMax = (baseItem and baseItem.duraMax) or 0,
		FItemIdent = 1,
		FItemValueList = {}
	}

	setmetatable(item, {
		__index = gItemOp
	})
	item.decodedCallback(item)

	return item
end
items.getStdItemById = function (id)
	return items.setStdItemData(items.getItemById(id), id)
end
items.valueType2Key = {
	[0] = "AC",
	"maxAC",
	"MAC",
	"maxMAC",
	"DC",
	"maxDC",
	"MC",
	"maxMC",
	"SC",
	"maxSC",
	"CC",
	"maxCC",
	"normalStateSet",
	"need",
	"needLevel",
	"antiqueLv",
	"maxDura",
	"hitSpeed",
	"quickRate",
	"accurate",
	"posiAC",
	"HP",
	"MP",
	"price",
	"strength",
	"AttributeDC",
	"AttributeAC",
	"AttributeMAC",
	"AttributeMaxMC",
	"AttributeMaxSC",
	"AttributeLucky",
	"AttributeStrength",
	"AttributeHitSpeed",
	"AttributeSTONE_DEF",
	"AttributePOIS_RESUME",
	"AttributeAccurate",
	"AttributeDura",
	"AttributeQuickRate",
	"AttributeMaxDura",
	"AttributeMcAvoid",
	"JewelType",
	"JewelAbil",
	"JewelDC",
	"JewelMC",
	"JewelSC",
	"JewelAC",
	"JewelMAC",
	"JewelDura",
	"JewelHitSpeed",
	"JewelQuickRate",
	"JewelAccurate",
	"JewelPoisAc",
	"JewelDownSpeed",
	"JewelStrength",
	"VTGiftProp",
	"AttributeMcHit",
	"AttributeRefin",
	"AttributeUpType",
	"UpLevel",
	"vtIdentifyDC",
	"vtIdentifyMC",
	"vtIdentifySC",
	"vtIdentifyMAXDC",
	"vtIdentifyMAXMC",
	"vtIdentifyMaxSC",
	"vtIdentifyAC",
	"vtIdentifyMAXAC",
	"vtIdentifyMAC",
	"vtIdentifyMAXMAC",
	"vtIdentifyMAXHP",
	"vtIdentifyMAXMP",
	"vtIdentifyHitRate",
	"vtIdentifyDex",
	"vtIdentifyLevel",
	"vtIdentifyRapeDam",
	"vtIdentifyCriticalDam",
	"vtIdentifyRecvHP",
	"vtIdentifyRecvMP",
	"vtTransform",
	"vtAttributeSecRefine"
}
items.key2ValueName = {
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"攻击",
	"防御",
	"魔御",
	"魔法",
	"道术",
	"幸运",
	"强度",
	"攻击速度",
	"麻痹抗性",
	"中毒恢复",
	"准确",
	nil,
	"敏捷",
	"最大持久",
	"魔法躲避",
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	nil,
	"攻击下限",
	"魔法下限",
	"道术下限",
	"攻击上限",
	"魔法上限",
	"道术上限",
	[77.0] = "回魔上限",
	[66.0] = "防御上限",
	[81.0] = "魔法",
	[70.0] = "魔法值",
	[74.0] = "强攻伤害",
	[76.0] = "回血上限",
	[82.0] = "道术",
	[65.0] = "防御下限",
	[75.0] = "暴击系数",
	[67.0] = "魔御下限",
	[69.0] = "生命值",
	[68.0] = "魔御上限",
	[72.0] = "敏捷",
	[80.0] = "攻击",
	[71.0] = "准确"
}

return items
