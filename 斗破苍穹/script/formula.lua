formula = {}

local function getDictData(qualityId, starLevelId, dictCardData)
	local dictData = nil
	if qualityId == StaticQuality.white or (dictCardData.qualityId == qualityId and dictCardData.starLevelId == starLevelId) then
		dictData = dictCardData
	else
		starLevelId = starLevelId - 1
		if starLevelId == 0 then
			qualityId = qualityId - 1
			starLevelId = DictQuality[tostring(qualityId)].maxStarLevel + 1
		end
		for key, obj in pairs(DictAdvance) do
			if dictCardData.id == obj.cardId and obj.qualityId == qualityId and obj.starLevelId == starLevelId then
				dictData = obj
				break
			end
		end
	end
	return dictData
end

---卡牌血量
--@cardLevel : 卡牌等级
--@qualityId : 卡牌品质ID
--@starLevelId : 卡牌星级ID
--@dictCardData : 卡牌字典数据
function formula.getCardBlood(cardLevel, qualityId, starLevelId, dictCardData)
	local dictData = getDictData(qualityId, starLevelId, dictCardData)
	if cardLevel and dictData then
		return dictData.blood + (cardLevel - 1) * dictData.bloodAdd
	else
		return 0
	end
end

---卡牌斗气攻击
--@cardLevel : 卡牌等级
--@qualityId : 卡牌品质ID
--@starLevelId : 卡牌星级ID
--@dictCardData : 卡牌字典数据
function formula.getCardGasAttack(cardLevel, qualityId, starLevelId, dictCardData)
	local dictData = getDictData(qualityId, starLevelId, dictCardData)
	if cardLevel and dictData then
			return dictData.wuAttack + (cardLevel - 1) * dictData.wuAttackAdd
	else
		return 0
	end
end

---卡牌斗气防御
--@cardLevel : 卡牌等级
--@qualityId : 卡牌品质ID
--@starLevelId : 卡牌星级ID
--@dictCardData : 卡牌字典数据
function formula.getCardGasDefense(cardLevel, qualityId, starLevelId, dictCardData)
	local dictData = getDictData(qualityId, starLevelId, dictCardData)
	if cardLevel and dictData then
		return dictData.wuDefense + (cardLevel - 1) * dictData.wuDefenseAdd
	else
		return 0
	end 
end

---卡牌灵魂攻击
--@cardLevel : 卡牌等级
--@qualityId : 卡牌品质ID
--@starLevelId : 卡牌星级ID
--@dictCardData : 卡牌字典数据
function formula.getCardSoulAttack(cardLevel, qualityId, starLevelId, dictCardData)
	local dictData = getDictData(qualityId, starLevelId, dictCardData)
	if cardLevel and dictData then
		return dictData.faAttack + (cardLevel - 1) * dictData.faAttackAdd
	else
		return 0
	end
end

---卡牌灵魂防御
--@cardLevel : 卡牌等级
--@qualityId : 卡牌品质ID
--@starLevelId : 卡牌星级ID
--@dictCardData : 卡牌字典数据
function formula.getCardSoulDefense(cardLevel, qualityId, starLevelId, dictCardData)
	local dictData = getDictData(qualityId, starLevelId, dictCardData)
	if cardLevel and dictData then
		return dictData.faDefense + (cardLevel - 1) * dictData.faDefenseAdd
	else
		return 0
	end
end

---卡牌命中
--@cardLevel : 卡牌等级
--@dictCardData : 卡牌字典数据
function formula.getCardHit(cardLevel, dictCardData)
	if cardLevel and dictCardData then
		return dictCardData.hit + (cardLevel - 1) * dictCardData.hitAdd
	else
		return 0
	end
end

---卡牌闪避
--@cardLevel : 卡牌等级
--@dictCardData : 卡牌字典数据
function formula.getCardDodge(cardLevel, dictCardData)
	if cardLevel and dictCardData then
		return dictCardData.dodge + (cardLevel - 1) * dictCardData.dodgeAdd
	else
		return 0
	end
end

---卡牌暴击
--@cardLevel : 卡牌等级
--@dictCardData : 卡牌字典数据
function formula.getCardCrit(cardLevel, dictCardData)
	if cardLevel and dictCardData then
		return dictCardData.crit + (cardLevel - 1) * dictCardData.critAdd
	else
		return 0
	end
end

---卡牌韧性
--@cardLevel : 卡牌等级
--@dictCardData : 卡牌字典数据
function formula.getCardTenacity(cardLevel, dictCardData)
	if cardLevel and dictCardData then
		return dictCardData.flex + (cardLevel - 1) * dictCardData.flexAdd
	else
		return 0
	end
end

---装备属性值
--@equipLevel : 装备等级
--@initValue : 初始值
--@addValue : 增幅值
function formula.getEquipAttribute(equipLevel, initValue, addValue)
	return initValue + equipLevel * addValue
end

---异火技能属性提升值
--@fireLv : 异火等级
--@fireSkillAdd : 异火技能加成系数
function formula.getFireSkillAttribute(fireLv, fireSkillAdd)
	return 100 + (fireLv - 1) * fireSkillAdd
end

---功法/法宝属性1的值
--@magicLv : 功法/法宝等级
--@initValue : 初始值
--@addValue : 增幅值
function formula.getMagicValue1(magicLv, initValue, addValue)
	return initValue + (magicLv - 1) * addValue
end

---手动技能战斗力值
--@manualSkillLv : 手动技能等级
--@initFightValue : 手动技能初始战斗力值
--@addFightValue : 手动技能战斗力加成值
function formula.getManualSkillFightValue(manualSkillLv, initFightValue, addFightValue)
	return initFightValue + (manualSkillLv - 1) * addFightValue
end