--PlayAttribute.lua

local PlayAttribute = {}


function PlayAttribute._doPlayAttribute( attributeName, value, delayTime, posx, posy, func )
	value = value or 0
	if value ~= 0 then 
        local node = require("app.scenes.common.AttrTextTip").new()
    	node:setPosition(ccp(posx, posy))
    	node:playWithNameAndDelta(attributeName, value, delayTime, func)
    	uf_notifyLayer:getTipNode():addChild(node, 0, 100)
    end
end

function PlayAttribute._doPlayText( text, delayTime, posx, posy, func )
	if value ~= 0 then 
        local node = require("app.scenes.common.AttrTextTip").new()
    	node:setPosition(ccp(posx, posy))
    	node:playWithRichText(text, delayTime, func)
    	uf_notifyLayer:getTipNode():addChild(node, 0, 100)
    end
end

function PlayAttribute._doPlayAttributeArray( attributes, startCount, func )
	if type(attributes) ~= "table" or #attributes < 1 then
		return 0
	end

	startCount = startCount or 0
	local validAttributes = {}
	for key, value in pairs(attributes) do 
		if value[2] ~= 0 then
			table.insert(validAttributes, #validAttributes + 1, value)
		end
	end

	local sortFunc = function ( value1, value2 )
		return value1[2] > value2[2]
	end
	table.sort(validAttributes, sortFunc)
	local count = #validAttributes
	for key, value in pairs(validAttributes) do 
		--__Log("key:%s, value:%s, key:%d, startCount:%d, delay:%d", value[1],value[2], key, startCount, (1-2*key)*15)
		local callback = (key == count) and func or nil
		if startCount > 0 then
			PlayAttribute._doPlayAttribute(value[1], value[2], (key + startCount + 1 )*15, display.cx, display.cy +  (1-2*key)*15, callback)
		else
			PlayAttribute._doPlayAttribute(value[1], value[2], (key + startCount + 1 )*15, display.cx, display.cy +  (count - key*2 + 1)*15, callback)
		end
	end

	return count
end

function PlayAttribute._doPlayTextArray( attributes, startCount, func )
	if type(attributes) ~= "table" or #attributes < 1 then
		return 0
	end

	startCount = startCount or 0
	local count = #attributes
	for key, value in pairs(attributes) do
		local callback = (key == count) and func or nil
		PlayAttribute._doPlayText(value, (key + startCount + 1)*15, display.cx, display.cy + ((count - key)*2 + 1)*15, callback)
	end

	return count
end

--武将部分
function PlayAttribute.playKnightAttributeWithKnightId( knightId, startCount, func )
	if not knightId or knightId <= 0 then 
		return 0
	end

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if not knightInfo then
		return 0
	end

	local level = knightInfo["level"] or 1
	return PlayAttribute.playKnightAttributeWithBaseId(knightInfo["base_id"] or 0, knightInfo["level"] or 1, startCount, func)
end

function PlayAttribute.playKnightAttributeWithBaseId( baseId, level, startCount, func )
	require("app.cfg.knight_info")
	local knightBaseInfo = knight_info.get(baseId)
	if not knightBaseInfo then
		return 0
	end
	level = level or 1

	local hpValue = knightBaseInfo.base_hp + (level - 1)*knightBaseInfo.develop_hp
	local attackValue = 0
	if knightBaseInfo.damage_type == 1 then
		attackValue	= knightBaseInfo.base_physical_attack + level*knightBaseInfo.develop_physical_attack
	else
		attackValue	= knightBaseInfo.base_magical_attack + level*knightBaseInfo.develop_magical_attack
	end
	local physicDefValue = knightBaseInfo.base_physical_defence + (level - 1)*knightBaseInfo.develop_physical_defence
	local magicDefValue = knightBaseInfo.base_magical_defence + (level - 1)*knightBaseInfo.develop_magical_defence
	
	--__Log("hpValue:%d, attack:%d, phsyic:%d, magic:%d", hpValue, attackValue, physicDefValue, magicDefValue)

	return PlayAttribute._doPlayAttributeArray({{G_lang:get("LANG_GROWUP_ATTRIBUTE_SHENGMING"), hpValue}, 
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI"), attackValue},
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_WUFANG"), physicDefValue},
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_MOFANG"), magicDefValue}}, startCount, func)

end

function PlayAttribute.playKnightAttributeWithLevelOffset( baseId, offsetLevel, startCount, func )
	local endLevel = endLevel or 1
	local startLevel = startLevel or 1
	local offsetLevel = offsetLevel or 0
	if offsetLevel == 0 then
		return 0
	end

	require("app.cfg.knight_info")
	local knightBaseInfo = knight_info.get(baseId)
	if not knightBaseInfo then
		return 0
	end

	local hpValue = offsetLevel*knightBaseInfo.develop_hp
	local physicDefValue = offsetLevel*knightBaseInfo.develop_physical_defence
	local magicDefValue = offsetLevel*knightBaseInfo.develop_magical_defence
	local attackValue = 0
	if knightBaseInfo.damage_type == 1 then
		attackValue	= offsetLevel*knightBaseInfo.develop_physical_attack
	else
		attackValue	= offsetLevel*knightBaseInfo.develop_magical_attack
	end

	return PlayAttribute._doPlayAttributeArray({{G_lang:get("LANG_GROWUP_ATTRIBUTE_SHENGMING"), hpValue}, 
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI"), attackValue},
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_WUFANG"), physicDefValue},
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_MOFANG"), magicDefValue}}, startCount, func)
	
end

function PlayAttribute.playKnightAttributeChangeWithKnightId( knightId1, knightId2, startCount )
	if not knightId1 or knightId1 <= 0 or not knightId2 or knightId2 <= 0 then 
		return 0
	end

	local knightInfo1 = G_Me.bagData.knightsData:getKnightByKnightId(knightId1)
	local knightInfo2 = G_Me.bagData.knightsData:getKnightByKnightId(knightId2)
	if not knightInfo1 or not knightInfo2 then
		return 0
	end

	require("app.cfg.knight_info")
	local knightBaseInfo1 = knight_info.get(knightInfo1["base_id"])
	local knightBaseInfo2 = knight_info.get(knightInfo2["base_id"])
	if not knightBaseInfo1 or not knightBaseInfo2 then
		return 0
	end

	local level1 = knightInfo1["level"] or 1
	local level2 = knightInfo2["level"] or 1

	local hpValue1 = knightBaseInfo1.base_hp + (level1 - 1)*knightBaseInfo1.develop_hp
	local attackValue1 = 0
	if knightBaseInfo1.damage_type == 1 then
		attackValue1 = knightBaseInfo1.base_physical_attack + level1*knightBaseInfo1.develop_physical_attack
	else
		attackValue1 = knightBaseInfo1.base_magical_attack + level1*knightBaseInfo1.develop_magical_attack
	end
	local physicDefValue1 = knightBaseInfo1.base_physical_defence + (level1 - 1)*knightBaseInfo1.develop_physical_defence
	local magicDefValue1 = knightBaseInfo1.base_magical_defence + (level1 - 1)*knightBaseInfo1.develop_magical_defence

	local hpValue2 = knightBaseInfo2.base_hp + (level2 - 1)*knightBaseInfo2.develop_hp
	local attackValue2 = 0
	if knightBaseInfo2.damage_type == 1 then
		attackValue2 = knightBaseInfo2.base_physical_attack + level2*knightBaseInfo2.develop_physical_attack
	else
		attackValue2 = knightBaseInfo2.base_magical_attack + level2*knightBaseInfo2.develop_magical_attack
	end
	local physicDefValue2 = knightBaseInfo2.base_physical_defence + (level2 - 2)*knightBaseInfo2.develop_physical_defence
	local magicDefValue2 = knightBaseInfo2.base_magical_defence + (level2 - 2)*knightBaseInfo2.develop_magical_defence

	return PlayAttribute._doPlayAttributeArray({{G_lang:get("LANG_GROWUP_ATTRIBUTE_SHENGMING"), hpValue2 - hpValue1}, 
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI"), attackValue2 - attackValue1},
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_WUFANG"), physicDefValue2 - physicDefValue1},
										{G_lang:get("LANG_GROWUP_ATTRIBUTE_MOFANG"), magicDefValue2 - magicDefValue1}}, startCount)
	
end

function PlayAttribute.playKnightAssociationActive( activeAssociate, retText, startCount )
	if not activeAssociate or #activeAssociate < 1 then
		return 0
	end

	require("app.cfg.knight_info")
	require("app.cfg.association_info")
	local attributeArr = {}
	if retText then
		table.insert(attributeArr, #attributeArr + 1, retText)
	end

	for key, value in pairs(activeAssociate) do 
		if type(value) == "table" and #value > 0 then
			local knightInfo = knight_info.get(value[1])
			local associationInfo = association_info.get(value[2])
			if knightInfo and associationInfo then
				table.insert(attributeArr, #attributeArr + 1, G_lang:get("LANG_KNIGHT_ACTIVE_ASSOCIATION", {knightName=knightInfo.name, associationName=associationInfo.name}))
				--G_MovingTip:showMovingTip(G_lang:get("LANG_KNIGHT_ACTIVE_ASSOCIATION", {knightName=knightInfo.name, associationName=associationInfo.name}),{hasBg=false,})
			end
		end
	end

	return PlayAttribute._doPlayTextArray(attributeArr, startCount)
end

function PlayAttribute.playTextArray( textArr, startCount, func )
	if not textArr or type(textArr) ~= "table" then 
		return startCount
	end

	return PlayAttribute._doPlayTextArray(textArr, startCount, func)
end

function PlayAttribute.playKnightAttriChange( attri1, attri2, startCount )
	if not attri1 or not attri2 then 
		return
	end

	local attriArr = {}
	local attri1Value = attri1.hp or 0
	local attri2Value = attri2.hp or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_SHENGMING"), attri2Value - attri1Value})
	end

	attri1Value = attri1.attack or 0
	attri2Value = attri2.attack or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_GONGJI"), attri2Value - attri1Value})
	end

	attri1Value = attri1.phyDefense or 0
	attri2Value = attri2.phyDefense or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_WUFANG"), attri2Value - attri1Value})
	end

	attri1Value = attri1.magicDefense or 0
	attri2Value = attri2.magicDefense or 0
	if attri2Value ~= attri1Value then
		table.insert(attriArr, #attriArr + 1, {G_lang:get("LANG_GROWUP_ATTRIBUTE_MOFANG"), attri2Value - attri1Value})
	end

	PlayAttribute._doPlayAttributeArray(attriArr, startCount)
end

--装备部分
function PlayAttribute.playEquipAttributeWithEquipId( equipId )
	if not equipId or equipId < 1 then
		return 
	end

	local equipInfo = G_Me.bagData.equipmentList:getItemByKey(equipId)
	if not equipInfo then
		return 
	end
	local equipAttr = equipInfo:getStrengthAttrs()
	local playAttri = nil
	playAttri = function ( func )
		if #equipAttr > 0 then
			PlayAttribute._doPlayAttribute(equipAttr[1].typeString, equipAttr[1].value, 15, function (  )
				table.remove(equipAttr, 1)
				playAttri()
			end)
		end
	end

	playAttri()
end

--[[
	equipId 强化或精炼之后的装备ID
	startLevel 强化或精炼之前的 装备等级
]]
function PlayAttribute.playEquipAttributeWithLevelOffset( equipId, startLevel )
	local equipInfo = G_Me.bagData.equipmentList:getItemByKey(equipId)
	if not equipInfo then
		return 
	end
	local baseInfo = equipInfo.getInfo()
	local equipAttr = equipInfo:getStrengthAttrs()
	local valueStartArr = equipInfo:getStrengthAttrs(startLevel)

	local attributeArr = {}
	for key, value in pairs(equipAttr) do 
		if valueStartArr[key] then
			 table.insert(attributeArr, #attributeArr+1, {equipAttr[key].typeString, equipAttr[key].value-valueStartArr[key]})
		end
	end
	PlayAttribute._doPlayAttributeArray(attributeArr)
end

function PlayAttribute.playEquipAttributeChangeWithEquipId( equipId01, equipId02, startCount  )
	local equipInfo01 = G_Me.bagData.equipmentList:getItemByKey(equipId01)
	local equipInfo02 = G_Me.bagData.equipmentList:getItemByKey(equipId02)
	local equipAttr01 = equipInfo01 and equipInfo01:getStrengthAttrs() or {}
	local equipAttr02 = equipInfo02 and equipInfo02:getStrengthAttrs() or {}
	--[[
		替换时，属性类型可能会变动
		以属性类型为key
		table形式为
		{
			"攻击":{+0.5%,+0.3%}, --差值为-0.2%	
		}
	]]
	local _newAttrs = {}
	local _newAttrsIndex = {}
	for i,v in ipairs(equipAttr01)do
		_newAttrsIndex[i] = v.typeString
		_newAttrs[v.typeString] = {}
		_newAttrs[v.typeString][1] = v.value
		_newAttrs[v.typeString][2] = 0
	end
	for i,v in ipairs(equipAttr02)do
		if _newAttrs[v.typeString] ~= nil then
			_newAttrs[v.typeString][2] = v.value
		else
			_newAttrs[v.typeString]={}
			_newAttrsIndex[#_newAttrsIndex+1] = v.typeString
			_newAttrs[v.typeString][1] = 0
			_newAttrs[v.typeString][2] = v.value
		end 
	end

	-- local playAttri = nil
	-- playAttri = function ( func )
	-- 	if #_newAttrsIndex > 0 then
	-- 		--差值为后面一个减去前面一个
	-- 		local offset = _newAttrs[_newAttrsIndex[1]][2]-_newAttrs[_newAttrsIndex[1]][1]
	-- 		PlayAttribute._doPlayAttribute(_newAttrsIndex[1], offset, 15, function (  )
	-- 			table.remove(_newAttrsIndex, 1)
	-- 			playAttri()
	-- 		end)
	-- 	end
	-- end
	--playAttri()

	local attributeArr = {}
	for key, value in pairs(_newAttrsIndex) do 
		if _newAttrs[value] then
			 table.insert(attributeArr, #attributeArr+1, {value, _newAttrs[value][2]-_newAttrs[value][1]})
		end
	end
	PlayAttribute._doPlayAttributeArray(attributeArr, startCount)
end

--宝物部分
function PlayAttribute.playTreasureAttributeWithEquipId( treasureId )
	local treaureInfo = G_Me.bagData.treasureList:getItemByKey(treasureId)
	if not treaureInfo then
		assert("宝物不存在,ID:" .. treasureId)
		return 
	end
	local treasureAttr = treaureInfo:getStrengthAttrs()
	local playAttri = nil
	playAttri = function ( func )
		if #treasureAttr > 0 then
			PlayAttribute._doPlayAttribute(treasureAttr[1].typeString, treasureAttr[1].value, 15, function (  )
				table.remove(treasureAttr, 1)
				playAttri()
			end)
		end
	end
	local attributeArr = {}
	for key, value in pairs(treasureAttr) do 
		if treasureAttr[key] then
			 table.insert(attributeArr, #attributeArr+1, {treasureAttr[key].typeString, treasureAttr[key].value})
		end
	end
	PlayAttribute._doPlayAttributeArray(attributeArr)

end

--[[
	equipId 强化或精炼之后的装备ID
	startLevel 强化或精炼之前的 装备等级
]]
function PlayAttribute.playTreasureWithLevelOffset(equipId, startLevel )
	-- body
	local treasureInfo = G_Me.bagData.treasureList:getItemByKey(equipId)

	if not treasureInfo or startLevel == treasureInfo.level then
		return 
	end
	local baseInfo = treasureInfo.getInfo(treasureInfo)
	local treasureAttr = treasureInfo:getStrengthAttrs()
	local valueStartArr = treasureInfo:getStrengthAttrs(startLevel)
	local attributeArr = {}
	for key, value in pairs(treasureAttr) do 
		if valueStartArr[key] then
			 table.insert(attributeArr, #attributeArr+1, {treasureAttr[key].typeString, treasureAttr[key].value-valueStartArr[key].value})
		end
	end
	PlayAttribute._doPlayAttributeArray(attributeArr)
end

function PlayAttribute.playTreasureAttributeChangeWithEquipId( treasure01, treasure02, startCount )
	-- body
	local treasureInfo01 = G_Me.bagData.treasureList:getItemByKey(treasure01)
	local treasureInfo02 = G_Me.bagData.treasureList:getItemByKey(treasure02)
	local treasureAttr01 = treasureInfo01 and treasureInfo01:getStrengthAttrs() or {}
	local treasureAttr02 = treasureInfo02 and treasureInfo02:getStrengthAttrs() or {}
	--[[
		替换时，属性类型可能会变动
		以属性类型为key
		table形式为
		{
			"攻击":{+0.5%,+0.3%}, --差值为-0.2%	
		}
	]]
	local _newAttrs = {}
	local _newAttrsIndex = {}

	for i,v in ipairs(treasureAttr01)do
		_newAttrsIndex[i] = v.typeString
		_newAttrs[v.typeString] = {}
		_newAttrs[v.typeString][1] = v.value
		_newAttrs[v.typeString][2] = 0
	end
	for i,v in ipairs(treasureAttr02)do
		if _newAttrs[v.typeString] ~= nil then
			_newAttrs[v.typeString][2] = v.value
		else
			_newAttrs[v.typeString]={}
			_newAttrsIndex[#_newAttrsIndex+1] = v.typeString
			_newAttrs[v.typeString][1] = 0  
			_newAttrs[v.typeString][2] = v.value
		end 
	end

	-- local playAttri = nil
	-- playAttri = function ( func )
	-- 	if #_newAttrsIndex > 0 then
	-- 		--差值为后面一个减去前面一个
	-- 		local offset = _newAttrs[_newAttrsIndex[1]][2]-_newAttrs[_newAttrsIndex[1]][1]
	-- 		PlayAttribute._doPlayAttribute(_newAttrsIndex[1], offset, 15, function (  )
	-- 			table.remove(_newAttrsIndex, 1)
	-- 			playAttri()
	-- 		end)
	-- 	end
	-- end
	--playAttri()

	local attributeArr = {}
	for key, value in pairs(_newAttrsIndex) do 
		if _newAttrs[value] then
			 table.insert(attributeArr, #attributeArr+1, {value, _newAttrs[value][2]-_newAttrs[value][1]})
		end
	end
	PlayAttribute._doPlayAttributeArray(attributeArr, startCount)
end


return PlayAttribute
