local data_item_nature = require("data.data_item_nature")
local data_shangxiansheding_shangxiansheding = require("data.data_shangxiansheding_shangxiansheding")

local PetModel = {}
PetModel.totalTable = {}
PetModel.sellAbleData = nil
PetModel.debrisData = nil
PetModel.expandCost = nil
PetModel.soulList = {}

function PetModel.sendPetReq(param)
	RequestHelper.getPetList({
	callback = function(data)
		PetModel.expandCost = {
		data["4"],
		data["5"]
		}
		PetModel.setPetTable(data["1"])
		param.callback()
	end
	})
end

function PetModel.sendSoulReq(param)
	RequestHelper.getPetDebrisList({
	callback = function(listData)
		PetModel.soulList = listData["1"]
		param.callback()
	end
	})
end

function PetModel.sendSellCardReq(param)
	RequestHelper.sendSellCardRes({
	callback = function(data)
		show_tip_label(common:getLanguageString("@HeroSellSucceed") .. data["1"][1] .. common:getLanguageString("@SilverLabel"))
		game.player.m_silver = data["1"][2]
		PostNotice(NoticeKey.MainMenuScene_Update)
		PostNotice(NoticeKey.CommonUpdate_Label_Silver)
		param.callback()
	end,
	ids = param.sellStr
	})
end

function PetModel.getCellValue(cellData, showRelation)
	local _showRelation = showRelation
	local maxNum = 4000000
	local cellValue = 0
	if cellData.pos ~= nil and 0 < cellData.pos then
		cellValue = cellValue + maxNum
	end
	local cardStaticData = ResMgr.getPetData(cellData.resId)
	if cellData.fateState == 1 then
		cellValue = cellValue + maxNum / 10
	end
	cellValue = cellValue + maxNum / 1500 * cardStaticData.arr_zizhi
	cellValue = cellValue + maxNum / 7000 * cellData.cls
	cellValue = cellValue + maxNum / 10000 * cellData.level / 100
	cellValue = cellValue + cellData.resId / 100000
	return cellValue
end

function PetModel.getPetChoseValue(cellData)
	local petData = cellData.data
	return PetModel.getCellValue(petData, 0)
end

function PetModel.sortPetChose(cellTable)
	table.sort(cellTable, function(a, b)
		return PetModel.getHeroChoseValue(a) > PetModel.getHeroChoseValue(b)
	end)
end

function PetModel.setPetTable(cellTable)
	for key, value in pairs(cellTable) do
		if value.cid == nil then
			value.cid = 0
		end
	end
	PetModel.totalTable = cellTable
	PetModel.sort(PetModel.totalTable)
end

function PetModel.getPetTable()
	return PetModel.totalTable
end

function PetModel.getInitPetDataById(id)
	local data_pet_pet = require("data.data_pet_pet")
	if not data_pet_pet[id] then
		return {}
	end
	local petData = {}
	petData.baseRate = clone(data_pet_pet[id].base)
	petData.addBaseRate = {
	0,
	0,
	0,
	0
	}
	petData._id = id
	petData.cls = 0
	petData.skills = clone(data_pet_pet[id].skills)
	petData.skillLevels = {
	1,
	1,
	1,
	1
	}
	petData.resId = id
	petData.level = 1
	petData.star = data_pet_pet[id].star
	petData.curExp = 0
	petData.levelLimit = data_pet_pet[id].maxLevel
	return petData
end
local expTbl = {
0,
0,
"expThree",
"expFour",
"expFive"
}
local expGatherTbl = {
0,
0,
"expThreeGather",
"expFourGather",
"expFiveGather"
}

function PetModel.getPetExpValue(pet)
	dump(pet)
	local data_petlevel_petlevel = require("data.data_petlevel_petlevel")
	local sumExp = data_petlevel_petlevel[pet.level][expGatherTbl[pet.star]]
	return ResMgr.getPetData(pet.resId).exp + sumExp + pet.curExp
end

function PetModel.getNeedMaxExp(resId, curLevel, curExp, star)
	local petData = ResMgr.getPetData(resId)
	local limitPetLevel = data_shangxiansheding_shangxiansheding[11].level	
	local maxLevel = limitPetLevel > game.player.m_level and game.player.m_level or limitPetLevel
	local data_petlevel_petlevel = require("data.data_petlevel_petlevel")
	local sumExp = data_petlevel_petlevel[curLevel][expGatherTbl[star]]
	local sumMaxExp = data_petlevel_petlevel[maxLevel][expGatherTbl[star]]
	return sumMaxExp - sumExp - curExp
end

function PetModel.sort(cellTable, reverse)
	table.sort(cellTable, function(a, b)
		if reverse == true then
			return PetModel.getCellValue(a) < PetModel.getCellValue(b)
		else
			return PetModel.getCellValue(a) > PetModel.getCellValue(b)
		end
	end)
end

function PetModel.getSellAbleTable()
	local sellList = {}
	for i = 1, #PetModel.totalTable do
		local resId = PetModel.totalTable[i].resId
		local petData = ResMgr.getPetData(resId)
		if petData.price > 0 and PetModel.totalTable[i].pos == 0 and PetModel.totalTable[i].lock ~= 1 then
			sellList[#sellList + 1] = PetModel.totalTable[i]
		end
	end
	PetModel.sellAbleData = sellList
	return sellList
end

function PetModel.getPetByObjId(petObjID)
	for i = 1, #PetModel.totalTable do
		if petObjID == PetModel.totalTable[i]._id then
			return PetModel.totalTable[i]
		end
	end
	return nil
end

function PetModel.getCardFatePet(heroId)
	if not PetModel.cardFateTbl then
		PetModel.cardFateTbl = {}
		local data_pet_pet = require("data.data_pet_pet")
		for key, pet in pairs(data_pet_pet) do
			if pet.fateType then
				for _, fateId in pairs(pet.fatePerson) do
					if not PetModel.cardFateTbl[fateId] then
						PetModel.cardFateTbl[fateId] = {}
					end
					table.insert(PetModel.cardFateTbl[fateId], pet.id)
				end
			end
		end
	end
	return PetModel.cardFateTbl[heroId]
end

function PetModel.setPetDebrisData(data)
	PetModel.debrisData = data
end

function PetModel.getPetDebrisData(data)
	return PetModel.debrisData
end

function PetModel.updatePetDebrisData(debId, num)
	for index, debrisData in pairs(PetModel.debrisData) do
		if debrisData.itemId == debId then
			debrisData.itemCnt = debrisData.itemCnt + num
			if debrisData.itemCnt <= 0 then
				table.remove(PetModel.debrisData, index)
				return
			end
		end
	end
end

function PetModel.getPetYuanFenStrByTabId(tabId, petCls, showMax)
	local petStaticData = ResMgr.getPetData(tabId)
	local result = ""
	if petStaticData and petStaticData.fateType then
		if showMax then
		else
			result = petStaticData.fateDesc
		end
		for i = 1, #petStaticData.fateType do
			local nature = data_item_nature[petStaticData.fateType[i]]
			local value = petStaticData.fateBase
			if petCls > 0 then
				value = value + petStaticData.fateAdd[petCls]
			end
			local val = ""
			if nature.type ~= 1 then
				val = "%"
			end
			result = result .. " " .. nature.nature .. "+" .. value .. val
		end
	end
	return result
end

function PetModel.getPetSkillIcon(param)
	local skillId = param.id
	local showName = param.showName
	local nameColor = param.nameColor
	local skillLevel = param.level or 1
	local hasCorner = param.hasCorner or true
	local lockType = param.lockType or 0
	local icon
	local customName = param.customName
	if lockType == 2 then
		display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
		icon = display.newSprite("#zhenrong_lock_bg.png")
	else
		icon = ResMgr.getIconSprite({
		id = skillId,
		resType = ResMgr.PET_SKILL,
		star = 4,
		hasCorner = hasCorner
		})
		local iconSize = icon:getContentSize()
		if showName then
			local data_petskill_petskill = require("data.data_petskill_petskill")
			local label = ui.newTTFLabelWithOutline({
			text = customName or data_petskill_petskill[skillId].name,
			size = 20,
			font = FONTS_NAME.font_fzcy,
			align = ui.TEXT_ALIGN_CENTER,
			color = nameColor or NAME_COLOR[4],
			outlineColor = FONT_COLOR.BLACK,
			dimensions = cc.size(100, 0)
			})
			label:setPosition(iconSize.width / 2, -16)
			icon:addChild(label)
		end
		if hasCorner then
			label = ui.newTTFLabelWithOutline({
			text = string.format("%d", skillLevel),
			size = 22,
			font = FONTS_NAME.font_fzcy,
			color = FONT_COLOR._WHITE,
			outlineColor = FONT_COLOR.BLACK,
			})
			icon.lvLable = label
			icon:addChild(label)
			label:align(display.LEFT_TOP, 5, iconSize.height)
		end
		if lockType == 1 then
			display.addSpriteFramesWithFile("ui_zhenrong.plist", "ui_zhenrong.png")
			local s = display.newSprite("#zhenrong_spirit_lock.png")
			icon.lockIcon = s
			s:setPosition(cc.p(iconSize.width * 0.5, iconSize.height * 0.5))
			icon:addChild(s)
		end
	end
	return icon
end

return PetModel