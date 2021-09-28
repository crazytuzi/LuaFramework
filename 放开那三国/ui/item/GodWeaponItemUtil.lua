-- FileName: GodWeaponItemUtil.lua 
-- Author: licong 
-- Date: 14-12-15 
-- Purpose: function description of module 


module("GodWeaponItemUtil", package.seeall)

require "db/DB_Union_profit"
require "db/DB_Item_godarm"
require "script/ui/formation/FormationUtil"

--[[
	@des 	:得到神兵的品质,进化次数，显示的阶数
	@param 	: $p_item_templ_id 		:神兵模板id
	@param 	: $p_item_id 			:神兵物品id
	@param 	: $p_item_info 			:神兵信息，如果不为空，则用该信息，如果为空，则根据getGodWeaponInfo获取信息
	@return :神兵品质
	@return :神兵进阶次数
	@return :神兵显示的阶数
--]]
function getGodWeaponQualityAndEvolveNum(p_item_templ_id,p_item_id,p_item_info)
	--返回的品质
	local retQualityNum = nil
	--返回的进阶次数
	local retEvolveNum = nil
	--返回的用于显示的进阶次数
	local retShowNum = nil

	--用于存储神兵信息
	local itemInfo = {}
	--如果神兵信息存在，则用参数的神兵信息
	if p_item_info ~= nil then
		itemInfo = p_item_info
	--如果神兵信息不存在，获取神兵信息
	else
		itemInfo = getGodWeaponInfo(p_item_templ_id,p_item_id)
	end

	--如果itemInfo中没有物品缓存信息，则读取表中信息
	if table.isEmpty(itemInfo.va_item_text) then
		retEvolveNum = tonumber(itemInfo.itemDesc.originalevolve)
	--否则读取缓存信息
	else
		retEvolveNum = tonumber(itemInfo.va_item_text.evolveNum)
	end

	retQualityNum,retShowNum = getDBQualityAndShowNum(itemInfo.itemDesc.id,retEvolveNum)

	return retQualityNum,retEvolveNum,retShowNum
end

--[[
	@des 	:根据总进阶次数，得到神兵品质和显示的阶数
	@param 	: $p_item_templ_id 		:物品模板id
	@param 	: $p_evolveNum 			:总进化次数
	@return :神兵品质
	@return :神兵显示的阶数
--]]
function getDBQualityAndShowNum(p_item_templ_id,p_evolveNum)
	local dbInfo = DB_Item_godarm.getDataById(p_item_templ_id)

	--返回的品质
	local retQualityNum = nil
	--返回的用于显示的进阶次数
	local retShowNum = nil
	--读取策划表中进阶次数和品质，显示阶数的关系
	local strTab = string.split(dbInfo.evolvequality, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if(tonumber(tab[1]) == p_evolveNum )then
			retQualityNum = tonumber(tab[2])
			retShowNum = tonumber(tab[3])
			break
		end
	end

	return retQualityNum,retShowNum
end

--[[
	@des 	:得到神兵信息
	@param 	: $p_item_templ_id 		:神兵模板id
	@param 	: $p_item_id 			:神兵物品id
	@return :神兵信息
--]]
function getGodWeaponInfo(p_item_templ_id,p_item_id)
	--如果没有获得信息，则返回nil
	local itemInfo = nil
	--如果物品id不为空
	if p_item_id ~= nil then
		--在背包中找
		itemInfo = ItemUtil.getItemByItemId(p_item_id)
		--如果背包中没找到，则在英雄身上找
		if table.isEmpty(itemInfo) then
			-- 英雄身上找
			itemInfo = ItemUtil.getGodWeaponInfoFromHeroByItemId(p_item_id)
		end
	--如果没有物品id
	else
		itemInfo = {}
		itemInfo.itemDesc = ItemUtil.getItemById(p_item_templ_id)
	end

	return itemInfo
end

--[[
	@des 	:得到hid武将穿戴神兵p_item_templ_id后的羁绊信息
	@param 	: $p_item_templ_id 		:神兵的模板id
	@param  : $p_hid 				:武将hid，如果为空则表示没有人穿，羁绊未开启
	@param  : p_itemInfo 			:物品详细信息，需求加的匆忙，必须传入整个物品信息
	@param  : p_otherHeroInfo       :对方阵容那个人的信息
	@return :羁绊信息
--]]
function getGodWeaponUnionInfo(p_item_templ_id,p_hid,p_itemInfo,p_otherHeroInfo)
	--db表中的数据
	local dbTable = DB_Item_godarm.getDataById(p_item_templ_id)

	local returnTable = {}
	--默认全都未开启
	local splitTable = {}
	if(dbTable.godamyfriend ~= nil)then
		splitTable = string.split(dbTable.godamyfriend,",")
	end
	for i = 1,#splitTable do
		local innerTable = {}
		local innerString = string.split(splitTable[i],"|")
		--innerTable.dbInfo = DB_Union_profit.getDataById(splitTable[i])
		innerTable.dbInfo = DB_Union_profit.getDataById(innerString[1])
		--自己的号里面，没有人穿，且对方阵容没有人穿
		if p_hid == nil and p_otherHeroInfo == nil then
			innerTable.isOpen = false
		--如果有hid则在该武将身上查找物品，看羁绊是否开启
		else
			--innerTable.isOpen = isUnionWeakUp(splitTable[i],p_hid,innerTable.dbInfo,true)
			innerTable.isOpen = isUnionWeakUp(innerString[2],p_hid,p_itemInfo,p_otherHeroInfo)
		end
		table.insert(returnTable,innerTable)
	end

	-- 主角的
	local unionId = nil
	if(dbTable.zhujue_union ~= nil)then
		unionId = dbTable.zhujue_union
	end
	if(unionId ~= nil)then
		local innerTable = {}
		innerTable.dbInfo = DB_Union_profit.getDataById(unionId)
		--自己的号里面，没有人穿，且对方阵容没有人穿
		if p_hid == nil and p_otherHeroInfo == nil then
			innerTable.isOpen = false
		--如果有hid则在该武将身上查找物品，看羁绊是否开启
		else
			local zhujueMoldId = UserModel.getUserModelId()
			innerTable.isOpen = isUnionWeakUp(zhujueMoldId,p_hid,p_itemInfo,p_otherHeroInfo)
		end
		table.insert(returnTable,innerTable)
	end
	return returnTable
end

--[[
	@des 	:判断神兵羁绊是否开启，此方法已经确定了神兵已经被人穿上了
	@param 	: $p_htid 				:羁绊信息
	@param  : $p_hid 				:武将hid
	@param  : $p_itemInfo 			:物品所有信息
	@param  : $p_otherHeroInfo 		:对方阵容那个人的信息
	@return :羁绊是否开启
--]]
function isUnionWeakUp(p_htid,p_hid,p_itemInfo,p_otherHeroInfo)

	local isOpen = false

	local heroInfo
	--如果不是查看对方阵容
	if p_otherHeroInfo == nil then
		heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
	--如果是查看对方阵容，则用对方阵容的数据信息
	else
		heroInfo = p_otherHeroInfo
	end

	local openLv = p_itemInfo.itemDesc.friend_open

	if (tonumber(heroInfo.localInfo.model_id) == tonumber(p_htid)) and 
		openLv ~= nil and 
		(tonumber(p_itemInfo.va_item_text.evolveNum) >= tonumber(openLv)) then
		
		isOpen = true
	end

	return isOpen
end

--[[
	@des 	:为战斗的时候判断羁绊提供的御用方法
	@param 	:英雄信息
	@return :开启的羁绊id的table
--]]
function unionInfoForFight(p_heroInfo)
	local returnTable = {}
	--英雄的db信息
	local heroDBInfo = DB_Heroes.getDataById(p_heroInfo.htid)
	--没有找到，说明是怪，不是人, 检查是否有装备信息
	if heroDBInfo == nil or table.isEmpty(p_heroInfo.equipInfo) then
		return returnTable
	end

	--英雄的modelId
	-- local heroModelId = tonumber(heroDBInfo.model_id)
	-- 英雄的dB信息
	p_heroInfo.localInfo = heroDBInfo
	--穿戴的神兵信息
	local equipGodData = p_heroInfo.equipInfo.godWeapon or {}
	--对于穿戴的每个神兵
	for k,v in pairs(equipGodData) do
		-- local equipInfo = v
		-- --神兵的进阶次数
		-- local evolveNum = tonumber(equipInfo.va_item_text.evolveNum)
		--神兵的db信息
		-- local equipDBInfo = DB_Item_godarm.getDataById(equipInfo.item_template_id)
		-- --羁绊开启所需进阶等级
		-- local openLv = tonumber(equipDBInfo.friend_open)
		-- --羁绊信息
		-- local unionTable = string.split(equipDBInfo.godamyfriend,",")
		-- --对于该神兵的每个羁绊
		-- for j = 1,#unionTable do
		-- 	local unionPairTable = string.split(unionTable[j],"|")
		-- 	--羁绊的id
		-- 	local unionId = tonumber(unionPairTable[1])
		-- 	--和羁绊相关联的人的id
		-- 	local heroId = tonumber(unionPairTable[2])
		-- 	--如果是该武将，且进阶等级大于羁绊开启等级
		-- 	if (heroModelId == heroId) and (evolveNum >= openLv) then
		-- 		table.insert(returnTable,unionId)
		-- 	end
		-- end
		if(tonumber(v) ~= 0) then
			--神兵的db信息
			local equipDBInfo = DB_Item_godarm.getDataById(v.item_template_id)
			v.itemDesc = equipDBInfo
			local unionInfo = getGodWeaponUnionInfo(v.item_template_id,nil,v,p_heroInfo)
			-- print("unionInfo==>")
			-- print_t(unionInfo)
			for j = 1,#unionInfo do
				if(unionInfo[j].isOpen == true)then
					table.insert(returnTable,unionInfo[j].dbInfo.id)
				end
			end
		end
	end
	-- print("==>>>>")
	-- print_t(returnTable)
	return returnTable
end

--[[
	@des 	:得到神兵大图
	@param 	: $p_item_templ_id 		:神兵模板id
	@param 	: $p_item_id 			:神兵物品id，为空则没有特效
	@param  : $p_hid 				:武将hid，如果为空则没有特效
	@param  : p_itemInfo			:神兵信息，若为空则根据getGodWeaponInfo得到物品信息
	@param  : p_evolveNum 			:神兵进化等级，在进化后显示下一等级的图片时使用，其他地方调用为空
	@param  : p_move				:是否上下移动，默认移动
	@return :神兵大图
--]]
function getWeaponBigSprite(p_item_templ_id,p_item_id,p_hid,p_itemInfo,p_evolveNum,p_move)
	if p_move ~= nil then
		move = p_move
	else
		move = true
	end
	--用于存储神兵信息
	local itemInfo = {}
	--如果神兵信息存在，则用参数的神兵信息
	if p_itemInfo ~= nil then
		itemInfo = p_itemInfo
	--如果神兵信息不存在，获取神兵信息
	else
		itemInfo = getGodWeaponInfo(p_item_templ_id,p_item_id)
	end
	
	-- --总进阶次数
	-- local retEvolveNum
	-- --如果itemInfo中没有物品缓存信息，则读取表中信息
	-- if p_evolveNum ~= nil then
	-- 	retEvolveNum = p_evolveNum
	-- elseif table.isEmpty(itemInfo.va_item_text) then
	-- 	retEvolveNum = tonumber(itemInfo.itemDesc.originalevolve)
	-- --否则读取缓存信息
	-- else
	-- 	retEvolveNum = tonumber(itemInfo.va_item_text.evolveNum)
	-- end

	----是否激活了武将羁绊
	-- local isConnect = false
	-- if p_hid ~= nil then
	-- 	local splitTable = string.split(itemInfo.itemDesc.godamyfriend,",")
	-- 	for i = 1,#splitTable do
	-- 		--local dbInfo = DB_Union_profit.getDataById(splitTable[i])
	-- 		--if isUnionWeakUp(splitTable[i],p_hid,dbInfo,true) then
	-- 		local innerString = string.split(splitTable[i],"|")
	-- 		if isUnionWeakUp(innerString[2],p_hid,itemInfo) then
	-- 			isConnect = true
	-- 			break
	-- 		end
	-- 	end 
	-- end
	local returnSprite

	local bigSprite = CCSprite:create("images/base/godarm/big/" .. itemInfo.itemDesc.icon_big)

	spriteSize = bigSprite:getContentSize()

	----如果有特效，且有人穿戴，且触发羁绊，且进化阶数大于配置的最小值，则激活羁绊
	-- if itemInfo.itemDesc.triggereffect ~= nil and
	-- 	p_hid ~= nil and
	-- 	isConnect and
	-- 	itemInfo.itemDesc.openEffect ~= nil and
	-- 	retEvolveNum >= tonumber(itemInfo.itemDesc.openEffect) then

	--修改为主要有特效就播
	if itemInfo.itemDesc.triggereffect ~= nil then

		returnSprite = CCSprite:create()
		returnSprite:setContentSize(spriteSize)

		--特效
		-- local shineLayerSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/godeffect/" .. itemInfo.itemDesc.triggereffect .. "/" .. itemInfo.itemDesc.triggereffect),-1,CCString:create(""))
		local shineLayerSprite = XMLSprite:create("images/base/effect/godeffect/" .. itemInfo.itemDesc.triggereffect .. "/" .. itemInfo.itemDesc.triggereffect)
		shineLayerSprite:setPosition(spriteSize.width*0.5,0)
		returnSprite:addChild(shineLayerSprite)

		-- local animationEnd = function(actionName,xmlSprite)
	 --    end

	 --    local animationFrameChanged = function(frameIndex,xmlSprite)
	 --    end

	 --    local delegate = BTAnimationEventDelegate:create()
	 --    delegate:registerLayerEndedHandler(animationEnd)
	 --    delegate:registerLayerChangedHandler(animationFrameChanged)
	    
	    -- shineLayerSprite:setDelegate(delegate)
	else
		returnSprite = bigSprite
	end

	if move then
		local arrActions = CCArray:create()
		arrActions:addObject(CCMoveBy:create(1.5,ccp(0,20*g_fElementScaleRatio)))
		arrActions:addObject(CCMoveBy:create(1.5,ccp(0,-20*g_fElementScaleRatio)))
		local sequence = CCSequence:create(arrActions)
		local repeatSequence = CCRepeatForever:create(sequence)
		returnSprite:runAction(repeatSequence)
	end

	return returnSprite
end

--[[
	@des 	:得到神兵属性值
	@param 	: $p_item_templ_id 		:神兵模板id
	@param 	: $p_item_id 			:神兵物品id
	@param 	: $p_item_info 			:神兵信息，为空则根据getGodWeaponInfo获取信息
	@return :神兵属性
--]]
function getWeaponAbility(p_item_templ_id,p_item_id,p_item_info)
	local itemInfo = nil
	--如果神兵信息存在，则用参数的神兵信息
	if p_item_info ~= nil then
		itemInfo = p_item_info
	--如果神兵信息不存在，获取神兵信息
	else
		itemInfo = getGodWeaponInfo(p_item_templ_id,p_item_id)
	end
	--得到装备的quality
	local _,itemQuality = getGodWeaponQualityAndEvolveNum(nil,nil,itemInfo)

	--级别，起始等级为0
	local itemLv = 0
	--如果有缓存信息，则用缓存信息的level
	if not table.isEmpty(itemInfo.va_item_text) then
		itemLv = tonumber(itemInfo.va_item_text.reinForceLevel)
	end

	local dbInfo = itemInfo.itemDesc

	local reTable = getAttrTable(itemQuality,itemLv,dbInfo.id)
	
	return reTable
end

--[[
	@des 	:得到神兵所有属性值,对外方法
	@param 	: $p_quality 			:神兵品质
	@param 	: $p_lv 				:神兵等级
	@param 	: $p_item_templ_id 		:该神兵模板id
	@return :神兵属性
--]]
function getAttrTable(p_quality,p_lv,p_item_templ_id)
	local dbInfo = DB_Item_godarm.getDataById(p_item_templ_id)

	local reTable = {}
	for i = 1,4 do
		local innerTable = {}
		local baseString = dbInfo["baseabilityID" .. i]
		local addString = dbInfo["growabilityID" .. i]

		--如果字段存在
		if baseString ~= nil then
			local sBaseTable = string.split(baseString,",")
			local sAddTable = string.split(addString,",")

			local itemType
			local baseNum
			local addNum

			--在分解后的段中寻找
			for i = 1,#sBaseTable do
				local baseInfo = string.split(sBaseTable[i],"|")
				local addInfo = string.split(sAddTable[i],"|")

				if tonumber(baseInfo[1]) == p_quality then
					itemType = baseInfo[2]
					baseNum = baseInfo[3]
					addNum = addInfo[3]
					break
				end
			end

			if baseNum ~= nil then
				local realNum = baseNum + p_lv*addNum
				local affixInfo,dealNum = ItemUtil.getAtrrNameAndNum(itemType,realNum)

				innerTable.id = itemType
				innerTable.showNum = dealNum
				innerTable.realNum = realNum
				innerTable.name = affixInfo.displayName

				table.insert(reTable,innerTable)
			end
		end
	end

	return reTable
end

--[[
	@des 	:得到神兵等级
	@param 	: $p_item_templ_id 		:神兵模板id
	@param 	: $p_item_id 			:神兵物品id
	@param 	: $p_item_info 			:神兵信息，如果为空，则根据getGodWeaponInfo获取信息
	@return :神兵等级
--]]
function getLvAndExp(p_item_templ_id,p_item_id,p_item_info)
	local itemInfo = nil
	--如果神兵信息存在，则用参数的神兵信息
	if p_item_info ~= nil then
		itemInfo = p_item_info
	--如果神兵信息不存在，获取神兵信息
	else
		itemInfo = getGodWeaponInfo(p_item_templ_id,p_item_id)
	end

	--级别，起始等级为0
	local itemLv = 0
	--local curExp = 0
	--如果有缓存信息，则用缓存信息的level
	if not table.isEmpty(itemInfo.va_item_text) then
		itemLv = tonumber(itemInfo.va_item_text.reinForceLevel)
		--curExp = tonumber(itemInfo.va_item_text.reinForceExp)
	end
	
	return itemLv
end

--[[
	@des 	:得到神兵进化材料信息
	@param 	: $p_item_templ_id 		:神兵模板id
	@param  : $p_evolveNum			:总进阶次数
	@param  : $p_item_id 			:当前物品的itemid
	@return :是否到了进化上限
			 是 ：true
			 否 ：false
	@return :神兵进化材料信息
	@return :进化材料是否充足
--]]
function getEvolveItemInfo(p_item_templ_id,p_evolveNum,p_item_id)
	local dbInfo = DB_Item_godarm.getDataById(p_item_templ_id)

	local splitTable = string.split(dbInfo.godamyevolveID,",")
	local resolveId
	--寻找进化id
	for i = 1,#splitTable do
		local continueTable = string.split(splitTable[i],"|")
		if tonumber(p_evolveNum) == tonumber(continueTable[1]) then
			resolveId = continueTable[2]
			break
		end
	end
	local returnTable = {}
	if resolveId == nil then
		return true
	end
	require "db/DB_Godarm_transfer"
	print("resolveId====",resolveId)
	local resolveInfo = DB_Godarm_transfer.getDataById(resolveId)

	local isEnough = true

	returnTable.item = {}
	returnTable.godConsumId = {}
	returnTable.silver = tonumber(resolveInfo.costsilver) or 0
	returnTable.heroLv = tonumber(resolveInfo.needavaterlv)
	returnTable.enhanceLv = tonumber(resolveInfo.needresolvegodlv)
	local consumeTable = {}
	if resolveInfo.costgodamy ~= nil then
		local godTable = string.split(resolveInfo.costgodamy,",")
		for i = 1,#godTable do
			local addTable = {}
			local innerTable = string.split(godTable[i],"|")
			addTable.id = tonumber(innerTable[1])
			addTable.evolveNum = tonumber(innerTable[2])
			addTable.type = "god"
			addTable.have,consumeId = ItemUtil.getCacheGodNumByTidAndEvolveLv(addTable.id,addTable.evolveNum,p_item_id,consumeTable)

			addTable.num = 1
			
			if addTable.have >= addTable.num then
				addTable.have = addTable.have + i - 1
			end

			table.insert(consumeTable,consumeId)

			if addTable.have < addTable.num then
				isEnough = false
			end
			table.insert(returnTable.item,addTable)
			table.insert(returnTable.godConsumId,consumeId)
		end
	end

	if resolveInfo.resolveitemID ~= nil then
		local itemTable = string.split(resolveInfo.resolveitemID,",")
		for i = 1,#itemTable do
			local addTable = {}
			local innerTable = string.split(itemTable[i],"|")
			addTable.id = tonumber(innerTable[1])
			addTable.num = tonumber(innerTable[2])
			addTable.type = "normal"
			addTable.have = tonumber(ItemUtil.getCacheItemNumBy(innerTable[1]))
			if addTable.have < addTable.num then
				isEnough = false
			end
			table.insert(returnTable.item,addTable)
		end
	end

	return false,returnTable,isEnough
end

--[[
	@des 	:是否达到神兵进化上限
	@param 	: $p_item_templ_id 		:神兵模板id
	@param 	: $p_evolveNum 			:当前总进阶次数
	@return :达到，返回true，没达到 false
--]]
function isMaxEvolveLv(p_item_templ_id,p_evolveNum)
	local dbTable = DB_Item_godarm.getDataById(p_item_templ_id)

	if dbTable.godamyevolveID == nil then
		return true
	end

	local splitTable = string.split(dbTable.godamyevolveID,",")

	local secondSplitTable = string.split(splitTable[#splitTable],"|")
	if tonumber(p_evolveNum) > tonumber(secondSplitTable[1]) then
		return true
	else
		return false
	end
end

--------------------------------------------------------------------------- 神兵战斗力计算方法 ------------------------------------------------------------------
local _allGodAttr 				= {} -- 缓存 { [hid] = { id = value }, }  key全部都number类型

--[[
	@des 	:得到装备神兵的属性值 用于战斗力
	@param 	: f_hid  p_isForce 是否重新计算 true重新计算
	@return :阵容上装备神兵的属性 
--]]
function getGodWeaponFightScore(f_hid, p_isForce)
	--TODO: BY HID
	-- require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
	-- local retTab = {}
	-- if( tonumber(f_hid) > 0 )then
	-- 	local tempGodWeapon = HeroUtil.getGodWeaponByHid( f_hid )
	-- 	if(not table.isEmpty(tempGodWeapon))then
	-- 		for k,v in pairs(tempGodWeapon) do
	-- 			-- 基础属性
	-- 			local attr = getWeaponAbility(nil,v.item_id)
	-- 			for i,a_info in pairs(attr) do
	-- 				if( retTab[tonumber(a_info.id)] == nil)then
	-- 					retTab[tonumber(a_info.id)] = tonumber(a_info.realNum)
	-- 				else
	-- 					retTab[tonumber(a_info.id)] = retTab[tonumber(a_info.id)] + tonumber(a_info.realNum)
	-- 				end
	-- 			end
	-- 			-- 洗练属性
	-- 			local attr2 = GodWeaponFixData.getGodWeapinFixAttrForFight(v.item_id)
	-- 			for i_2,a_info_2 in pairs(attr2) do
	-- 				if( retTab[tonumber(a_info_2.id)] == nil)then
	-- 					retTab[tonumber(a_info_2.id)] = tonumber(a_info_2.realNum)
	-- 				else
	-- 					retTab[tonumber(a_info_2.id)] = retTab[tonumber(a_info_2.id)] + tonumber(a_info_2.realNum)
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- return retTab

	local retTab = {}
	local hid = tonumber(f_hid)
	if(p_isForce ~= true and not table.isEmpty(_allGodAttr[hid]) )then
		-- 优先返回缓存
		retTab = _allGodAttr[hid]
		return retTab
	end

	-- 重新计算
	require "script/ui/godweapon/godweaponfix/GodWeaponFixData"
	if(hid ~= nil and hid > 0 )then
		local tempGodWeapon = HeroUtil.getGodWeaponByHid( hid )
		if(not table.isEmpty(tempGodWeapon))then
			for k,v in pairs(tempGodWeapon) do
				-- 基础属性
				local attr = getWeaponAbility(nil,v.item_id)
				for i,a_info in pairs(attr) do
					if( retTab[tonumber(a_info.id)] == nil)then
						retTab[tonumber(a_info.id)] = tonumber(a_info.realNum)
					else
						retTab[tonumber(a_info.id)] = retTab[tonumber(a_info.id)] + tonumber(a_info.realNum)
					end
				end
				-- 洗练属性
				local attr2 = GodWeaponFixData.getGodWeapinFixAttrForFight(v.item_id)
				for i_2,a_info_2 in pairs(attr2) do
					if( retTab[tonumber(a_info_2.id)] == nil)then
						retTab[tonumber(a_info_2.id)] = tonumber(a_info_2.realNum)
					else
						retTab[tonumber(a_info_2.id)] = retTab[tonumber(a_info_2.id)] + tonumber(a_info_2.realNum)
					end
				end
			end
		end
		_allGodAttr[hid] = retTab
	end

	return retTab
end

--[[
	@des 	:得到装备神兵的羁绊属性值
	@param 	: 
	@return :阵容上装备神兵的羁绊属性值
--]]
function getGodWeaponUnionFightScore()
	local retTab = {}
	-- 阵容
	local formation = DataCache.getFormationInfo()
	if(formation == nil)then
		return retTab
	end
	for f_pos, f_hid in pairs(formation) do
		if( tonumber(f_hid)>0 )then
			retTab[tonumber(f_hid)] = {}
			local tempGodWeapon = HeroUtil.getGodWeaponByHid( f_hid )
			if(not table.isEmpty(tempGodWeapon))then
				for k,v in pairs(tempGodWeapon) do
					local unionInfo = getGodWeaponUnionInfo(v.item_template_id,f_hid,v)
					for m,un_info in pairs(unionInfo) do
						if(un_info.isOpen == true)then
							if(un_info.dbInfo.union_arribute_ids ~= nil and un_info.dbInfo.union_arribute_nums ~= nil)then 
								local id_tab = string.split(un_info.dbInfo.union_arribute_ids,",")
								local attrNum_tab = string.split(un_info.dbInfo.union_arribute_nums,",")
								for i,id in pairs(id_tab) do
									if( retTab[tonumber(f_hid)][tonumber(id)] == nil)then
										retTab[tonumber(f_hid)][tonumber(id)] = tonumber(attrNum_tab[i])
									else
										retTab[tonumber(f_hid)][tonumber(id)] = retTab[tonumber(f_hid)][tonumber(id)] + tonumber(attrNum_tab[i])
									end
								end
							end
						end
					end
				end
			end
		end
	end
	return retTab
end

-------------------------------------------------------- 神兵背包新神兵 new标识--------------------------------------------------------
local _newGodWeaponTab 				= nil

--[[
	@des 	:	添加新获得神兵
	@params	:	p_item_id 神兵item_id
	@return :	
--]]
function addNewGodWeapon( p_item_id )

	print("p_item_id")
	print_t(p_item_id)

	if(_newGodWeaponTab == nil) then
		--从本地读取
		local newGodBuffer = CCUserDefault:sharedUserDefault():getStringForKey(UserModel.getUserUid() .. "hava_new_god_table")
		if(newGodBuffer == nil or newGodBuffer == "") then
			_newGodWeaponTab = {}
		else
			_newGodWeaponTab = table.unserialize(newGodBuffer)
		end	
	end
	_newGodWeaponTab[tostring(p_item_id)] = true
	local serializeBuffer = table.serialize(_newGodWeaponTab)
	CCUserDefault:sharedUserDefault():setStringForKey(UserModel.getUserUid() .. "hava_new_god_table", serializeBuffer)
	CCUserDefault:sharedUserDefault():flush()

	print("_newGodWeaponTab===>")
	print_t(_newGodWeaponTab)

end

--[[
	@des 	: 清除所有标志为new的神兵
]]
function clearAllNewGodWeaponSign()
	_newGodWeaponTab = nil
	CCUserDefault:sharedUserDefault():setStringForKey(UserModel.getUserUid() .. "hava_new_god_table", "")
	CCUserDefault:sharedUserDefault():flush()
end


--[[
	@des 	:	判断神兵是否是新神兵
	@params	:	p_item_id 神兵itemid
--]]
function isNewGodWeapon( p_item_id )
	if(_newGodWeaponTab == nil) then
		return false
	end

	if(_newGodWeaponTab[tostring(p_item_id)] == true) then
		return true
	else
		return false
	end
end


--[[
	@des 	:	是否拥有新神兵
]]
function isHaveNewGodWeapon()
	if(_newGodWeaponTab ~= nil) then
		return true
	else
		return false
	end
end

--[[
	@des 	: 初始化新神兵缓存数据
--]]
function initNewGodWeapon( ... )
 	if(_newGodWeaponTab == nil) then
		--从本地读取
		local newGodBuffer = CCUserDefault:sharedUserDefault():getStringForKey( UserModel.getUserUid() .. "hava_new_god_table" )
		print("newGodBuffer = ", newGodBuffer)
		if(newGodBuffer == nil or newGodBuffer == "") then
			_newGodWeaponTab = nil
		else
			_newGodWeaponTab = table.unserialize(newGodBuffer)
		end	
	end
end



































