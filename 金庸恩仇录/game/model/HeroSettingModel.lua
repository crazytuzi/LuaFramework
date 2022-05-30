local data_item_item = require("data.data_item_item")
local data_taozhuang_taozhuang = require("data.data_taozhuang_taozhuang")
local HeroSettingModel = {}

HeroSettingModel.equipList = {}   --当前英雄的装备列表
HeroSettingModel.cardList = {}
HeroSettingModel.cardIndex = 0

HeroSettingModel.enemyEquipList = {}
HeroSettingModel.enemyCardList = {}

HeroSettingModel.isEnemy = false
function HeroSettingModel.getCurEquipList()
	return HeroSettingModel.equipList
end
-- self._cardList = game.player.m_formation["1"]
-- self._equip = game.player.m_formation["2"]
function HeroSettingModel.setEnemyList(cardList,equipList)
	-- print("ssetttenmeyList")
	HeroSettingModel.isEnemy = true
	HeroSettingModel.enemyEquipList = equipList
	HeroSettingModel.enemyCardList =  cardList
	-- body
end

function HeroSettingModel.restoreHeroList()
	HeroSettingModel.isEnemy = false
	HeroSettingModel.enemyEquipList = {}
	HeroSettingModel.enemyCardList = {}
end

function HeroSettingModel.resetIndexByPos(name)
	
	HeroSettingModel.cardIndex = 0
	HeroSettingModel.cardList = game.player.m_formation["1"]
	local curCardList
	
	if HeroSettingModel.isEnemy ~= true then
		curCardList = HeroSettingModel.cardList
	else
		curCardList = HeroSettingModel.enemyCardList
	end
	
	for i = 1,#curCardList do
		if curCardList[i].name == name then
			HeroSettingModel.cardIndex = i
			break
		end
	end
end


function HeroSettingModel.isEquipExist(equipResId)
	-- print("isisissisisiss "..equipResId)
	local curEquipList = {}
	HeroSettingModel.equipList = game.player.m_formation["2"]
	if HeroSettingModel.cardIndex ~= 0 then
		if HeroSettingModel.isEnemy ~= true then
			curEquipList = HeroSettingModel.equipList[HeroSettingModel.cardIndex]
		else
			curEquipList = HeroSettingModel.enemyEquipList[HeroSettingModel.cardIndex]
			-- print("enenenene")
		end
	end
	
	-- dump(curEquipList)
	
	curEquipList = curEquipList or {}
	
	for k,v in ipairs(curEquipList) do
		if v.resId == equipResId then
			return true
		end
	end
	return false
end

function HeroSettingModel.getSuitNum(suitId)
	local suitNum = 0
	
	local suitData = data_taozhuang_taozhuang[suitId].member
	
	local curSuitList
	if HeroSettingModel.isEnemy ~= true then
		curSuitList =HeroSettingModel.equipList[HeroSettingModel.cardIndex]
	else
		curSuitList = HeroSettingModel.enemyEquipList[HeroSettingModel.cardIndex]
	end
	
	curSuitList = curSuitList or {}
	
	if HeroSettingModel.cardIndex ~= 0 then
		for i =1,#suitData do
			for k,v in ipairs(curSuitList) do
				if v.resId == suitData[i] then
					suitNum = suitNum + 1
					break
				end
			end
		end
	end
	
	return suitNum
end

return HeroSettingModel