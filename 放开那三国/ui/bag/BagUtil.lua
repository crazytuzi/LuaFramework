-- Filename：	BagUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-9-10
-- Purpose：		物品Item

module("BagUtil", package.seeall)


require "script/utils/LuaUtil"

-- 背包扩充各背包对应参数 
EQUIP_TYPE  							= 1 	-- 装备背包参数
PROP_TYPE  								= 2 	-- 道具背包参数
TREASURE_TYPE  							= 3 	-- 宝物背包参数
EQUIPFRAG_TYPE  						= 4 	-- 装备碎片背包参数
DRESS_TYPE  							= 5 	-- 时装背包参数
GODWEAPON_TYPE  						= 6 	-- 神兵背包参数
GODWEAPONFRAG_TYPE  					= 7 	-- 神兵碎片背包参数
RUNE_TYPE  								= 8 	-- 符印背包参数
RUNEFRAG_TYPE  							= 9 	-- 符印碎片背包参数
POCKET_TYPE  							= 10 	-- 锦囊背包参数
TALLY_TYPE  							= 11 	-- 兵符背包参数
TALLYFRAG_TYPE  						= 12 	-- 兵符碎片背包参数
CHARIOT_TYPE                            = 13    -- 战车背包参数

-- 单独处理背包
PET_TYPE  								= 20 	-- 宠物背包类型
HERO_TYPE 								= 21    -- 武将背包类型


function getNextOpenPropGridPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((bagInfo.gridMaxNum.props - 30) / 5 + 1) * 5*5
	end
	return price
end

function getNextOpenArmFragGridPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((bagInfo.gridMaxNum.armFrag - 50) / 5 + 1) * 5*5
	end
	return price
end

function getNextOpenArmGridPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((bagInfo.gridMaxNum.arm - 30) / 5 + 1) * 5*5
	end
	return price
end

function getNextOpenTreasGridPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((bagInfo.gridMaxNum.treas - 30) / 5 + 1) * 5*5
	end
	return price
end

function getNextOpenDressGridPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((bagInfo.gridMaxNum.dress - 100) / 5 + 1) * 5*5
	end
	return price
end

-- 神兵背包扩充价格
function getNextOpenGodWeaponPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.godWp) - 100) / 5 + 1) * 5*5
	end
	return price
end

-- 神兵碎片背包扩充价格
function getNextOpenGodWeaponFragPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.godWpFrag) - 100) / 5 + 1) * 5*5
	end
	return price
end

-- 符印背包扩充价格
function getNextOpenRunePrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.rune) - 100) / 5 + 1) * 5*5
	end
	return price
end

-- 符印碎片背包扩充价格
function getNextOpenRuneFragPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.runeFrag) - 100) / 5 + 1) * 5*5
	end
	return price
end

-- 锦囊背包扩充价格
function getNextOpenPocketPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.pocket) - 200) / 5 + 1) * 5*5
	end
	return price
end

-- 兵符背包扩充价格
function getNextOpenTallyPrice() 
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.tally) - 100) / 5 + 1) * 5*5
	end
	return price
end

-- 兵符碎片背包扩充价格
function getNextOpenTallyFragPrice()
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(bagInfo)) then
		price = ((tonumber(bagInfo.gridMaxNum.tallyFrag) - 100) / 5 + 1) * 5*5
	end
	return price
end

--[[
	@des 	: 得到下次开格子价钱 后端公式5*5+（当前格子数-初始格子数）*5
	@param 	: p_bagType 背包类型
	@return : num
--]]
function getNextOpenCostByBagType( p_bagType )
	local price = 0
	local bagInfo = DataCache.getRemoteBagInfo()
	if(p_bagType == EQUIP_TYPE)then
		price = ((bagInfo.gridMaxNum.arm - 30) / 5 + 1) * 5*5
	elseif( p_bagType == PROP_TYPE )then
		price = ((bagInfo.gridMaxNum.props - 30) / 5 + 1) * 5*5
	elseif( p_bagType == TREASURE_TYPE )then
		price = ((bagInfo.gridMaxNum.treas - 30) / 5 + 1) * 5*5
	elseif( p_bagType == EQUIPFRAG_TYPE )then
		price = ((bagInfo.gridMaxNum.armFrag - 50) / 5 + 1) * 5*5
	elseif( p_bagType == DRESS_TYPE )then
		price = ((bagInfo.gridMaxNum.dress - 100) / 5 + 1) * 5*5
	elseif( p_bagType == GODWEAPON_TYPE )then
		price = ((tonumber(bagInfo.gridMaxNum.godWp) - 100) / 5 + 1) * 5*5
	elseif( p_bagType == GODWEAPONFRAG_TYPE )then
		price = ((tonumber(bagInfo.gridMaxNum.godWpFrag) - 100) / 5 + 1) * 5*5
	elseif( p_bagType == RUNE_TYPE )then
		price = ((tonumber(bagInfo.gridMaxNum.rune) - 100) / 5 + 1) * 5*5
	elseif( p_bagType == RUNEFRAG_TYPE )then
		price = ((tonumber(bagInfo.gridMaxNum.runeFrag) - 100) / 5 + 1) * 5*5
	elseif( p_bagType == POCKET_TYPE )then
		price = ((tonumber(bagInfo.gridMaxNum.pocket) - 200) / 5 + 1) * 5*5   
	elseif( p_bagType == TALLY_TYPE )then 
		price = ((tonumber(bagInfo.gridMaxNum.tally) - 100) / 5 + 1) * 5*5   
	elseif( p_bagType == TALLYFRAG_TYPE )then 
		price = ((tonumber(bagInfo.gridMaxNum.tallyFrag) - 100) / 5 + 1) * 5*5 
	elseif ( p_bagType == CHARIOT_TYPE ) then
	  	price = ((tonumber(bagInfo.gridMaxNum.chariotBag) - 50) / 5 + 1) * 5*5 
	elseif( p_bagType == PET_TYPE )then 
		require "script/ui/pet/PetData"
		price = PetData.getPetBagEnlargeCostNum()
	elseif( p_bagType == HERO_TYPE )then 
		require "script/model/hero/HeroModel"
		price = HeroModel.getOpenHeroBagCost()
	elseif( p_bagType == CHARIOT_TYPE )then
		price = ((tonumber(bagInfo.gridMaxNum.chariotBag) - 50) / 5 + 1) * 5*5   
	else
	end
	return price
end

-- 装备排序算法 （策划需求的 逆序）
function equipSort( equip_1, equip_2 )
	local isPre = false
	if( tonumber(equip_1.itemDesc.quality) < tonumber(equip_2.itemDesc.quality))then

		isPre = true
	elseif(tonumber(equip_1.itemDesc.quality) == tonumber(equip_2.itemDesc.quality))then
		if(tonumber(equip_1.itemDesc.type) > tonumber(equip_2.itemDesc.type))then
			isPre = true
		elseif(tonumber(equip_1.itemDesc.type) == tonumber(equip_2.itemDesc.type))then
			local t_equip_score_1 = equip_1.itemDesc.base_score + tonumber(equip_1.va_item_text.armReinforceLevel) * equip_1.itemDesc.grow_score
			local t_equip_score_2 = equip_2.itemDesc.base_score + tonumber(equip_2.va_item_text.armReinforceLevel) * equip_2.itemDesc.grow_score

			if(t_equip_score_1 < t_equip_score_2)then
				isPre = true
			else
				isPre = false
			end
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

-- 宝物排序算法
function treasSort( equip_1, equip_2 )
	local isPre = false
	local quality1 = ItemUtil.getTreasureQualityByItemInfo( equip_1 )
	local quality2 = ItemUtil.getTreasureQualityByItemInfo( equip_2 )
	if( tonumber(quality1) < tonumber(quality2))then
		isPre = true
	elseif(tonumber(quality1) == tonumber(quality2))then
		if(tonumber(equip_1.itemDesc.type) > tonumber(equip_2.itemDesc.type))then
			isPre = true
		elseif(tonumber(equip_1.itemDesc.type) == tonumber(equip_2.itemDesc.type))then
			local t_equip_score_1 = equip_1.itemDesc.base_score
			local t_equip_score_2 = equip_2.itemDesc.base_score

			if(t_equip_score_1 < t_equip_score_2)then
				isPre = true
			else
				isPre = false
			end
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

-- 战魂排序算法
function fightSoulSort( equip_1, equip_2 )
	local isPre = false
	if( tonumber(equip_1.itemDesc.quality) < tonumber(equip_2.itemDesc.quality))then
		isPre = true
	elseif(tonumber(equip_1.itemDesc.quality) == tonumber(equip_2.itemDesc.quality))then
		if(tonumber(equip_1.itemDesc.sort) > tonumber(equip_2.itemDesc.sort))then
			isPre = true
		elseif(tonumber(equip_1.itemDesc.sort) == tonumber(equip_2.itemDesc.sort))then
			local t_equip_lv_1 = tonumber(equip_1.va_item_text.fsLevel)
			local t_equip_lv_2 = tonumber(equip_2.va_item_text.fsLevel)
			if(t_equip_lv_1 < t_equip_lv_2)then
				isPre = true
			elseif(t_equip_lv_1 == t_equip_lv_2)then
				if(tonumber(equip_1.item_template_id) > tonumber(equip_2.item_template_id))then
					return true
				else
					return false
				end
			else
				isPre = false
			end
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:神兵背包可装备神兵排序算法:进化等级》强化等级》品质
	@param 	:
	@return :返回 品质《强化等级《进化等级 返回的是一个倒叙的 tableView用
--]]
function equipGodWeaponSort( p_godWeapon_1, p_godWeapon_2 )
	local isPre = false
	require "script/ui/item/GodWeaponItemUtil"
	local quality_1,_,_ = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,p_godWeapon_1)
	local quality_2,_,_ = GodWeaponItemUtil.getGodWeaponQualityAndEvolveNum(nil,nil,p_godWeapon_2)
	if(quality_1 < quality_2)then
		isPre = true
	elseif(quality_1 == quality_2)then
		local reinForceLevel_1 = tonumber(p_godWeapon_1.va_item_text.reinForceLevel)
		local reinForceLevel_2 = tonumber(p_godWeapon_2.va_item_text.reinForceLevel)
		if(reinForceLevel_1 < reinForceLevel_2)then
			isPre = true
		elseif(reinForceLevel_1 == reinForceLevel_2)then
			local evolveNum_1 = tonumber(p_godWeapon_1.va_item_text.evolveNum)
			local evolveNum_2 = tonumber(p_godWeapon_2.va_item_text.evolveNum)
			if(evolveNum_1 < evolveNum_2)then
				isPre = true
			elseif(evolveNum_1 == evolveNum_2)then
				if(tonumber(p_godWeapon_1.item_template_id) > tonumber(p_godWeapon_2.item_template_id))then
					isPre = true
				else
					isPre = false
				end
			else
				isPre = false
			end
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:经验神兵的排序算法 需要显示由大到小
	@param 	:
	@return :返回 经验由小到大 也是也个倒叙
--]]
function expGodWeaponSort( p_godWeapon_1, p_godWeapon_2 )
	local isPre = false
	local offerExp1 = tonumber(p_godWeapon_1.itemDesc.giveexp)
	if(p_godWeapon_1.va_item_text and p_godWeapon_1.va_item_text.reinForceExp )then
		offerExp1 = offerExp1 + tonumber(p_godWeapon_1.va_item_text.reinForceExp)
	end
	local offerExp2 = tonumber(p_godWeapon_2.itemDesc.giveexp)
	if(p_godWeapon_2.va_item_text and p_godWeapon_2.va_item_text.reinForceExp )then
		offerExp2 = offerExp2 + tonumber(p_godWeapon_2.va_item_text.reinForceExp)
	end
	if(offerExp1 < offerExp2)then
		isPre = true
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:得到神兵背包已排序数据 神兵背包排序算法:已装备》进化等级》强化等级》品质》经验   已装备经验需要分离单独处理这里不做处理
	@param 	:p_godWeaponBag Info神兵背包原始数据
	@return :返回顺序 进化等级》强化等级》品质》经验 的倒叙
--]]
function getSortDataForGodWeaponBag( p_godWeaponBagInfo )
	local retData = p_godWeaponBagInfo
	if( not table.isEmpty(p_godWeaponBagInfo) )then

		local expTab = {} -- 经验神兵
		local equipTab = {} -- 可装备神兵
		for k,itemInfo in pairs(p_godWeaponBagInfo) do
			-- 筛选经验神兵
			if( tonumber(itemInfo.itemDesc.isgodexp) == 1 )then
				table.insert(expTab,itemInfo)
			else
				table.insert(equipTab,itemInfo)
			end
		end
		-- 经验神兵排序
		table.sort(expTab,expGodWeaponSort)
		-- 可装备神兵排序
		table.sort(equipTab,equipGodWeaponSort)

		retData = {}
		for k,v in pairs(expTab) do
			table.insert(retData,v)
		end
		for k,v in pairs(equipTab) do
			table.insert(retData,v)
		end
	end
	return retData
end

--[[
	@des 	:得到神兵碎片背包已排序数据 神兵碎片背包排序算法:能合成》碎片个数多的》品质
	@param 	:p_godWeaponBag Info神兵背包原始数据
	@return :返回顺序 品质》碎片个数多的 》能合成
--]]
function godWeaponFragSortForBag( p_godWeapon_1, p_godWeapon_2 )
	local isPre = false
	if(tonumber(p_godWeapon_1.item_num) < tonumber(p_godWeapon_2.item_num))then
		isPre = true
	elseif(tonumber(p_godWeapon_1.item_num) == tonumber(p_godWeapon_2.item_num))then
		if( tonumber(p_godWeapon_1.itemDesc.quality) < tonumber(p_godWeapon_2.itemDesc.quality) ) then
			isPre = true
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:得到符印背包排序数据 符印背包排序算法:品质》id 
	@param 	:符印数据
	@return :返回顺序 id 》品质
--]]
function runeSortForBag( p_rune_1, p_rune_2 )
	local isPre = false
	if(tonumber(p_rune_1.itemDesc.quality) < tonumber(p_rune_2.itemDesc.quality))then
		isPre = true
	elseif(tonumber(p_rune_1.itemDesc.quality) == tonumber(p_rune_2.itemDesc.quality))then
		if( tonumber(p_rune_1.itemDesc.id) < tonumber(p_rune_2.itemDesc.id) ) then
			isPre = true
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:得到符印碎片背包已排序数据  碎片背包排序算法:能合成》碎片个数多的》品质
	@param 	:
	@return :返回顺序 品质》碎片个数多的 》能合成
--]]
function runeFragSortForBag( p_rune_1, p_rune_2 )
	local isPre = false
	if(tonumber(p_rune_1.item_num) < tonumber(p_rune_2.item_num))then
		isPre = true
	elseif(tonumber(p_rune_1.item_num) == tonumber(p_rune_2.item_num))then
		if( tonumber(p_rune_1.itemDesc.quality) < tonumber(p_rune_2.itemDesc.quality) ) then
			isPre = true
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:得到锦囊背包排序数据 符印背包排序算法:品质》等级》id 
	@param 	:
	@return :返回顺序 id 》等级 》品质
--]]
function pocketSortForBag( p_pocket_1, p_pocket_2 )
	local isPre = false

	if(tonumber(p_pocket_1.itemDesc.quality) < tonumber(p_pocket_2.itemDesc.quality))then
		isPre = true
	elseif(tonumber(p_pocket_1.itemDesc.quality) == tonumber(p_pocket_2.itemDesc.quality))then
		if(tonumber(p_pocket_1.va_item_text.pocketLevel) < tonumber(p_pocket_2.va_item_text.pocketLevel))then
			isPre = true
		elseif(tonumber(p_pocket_1.va_item_text.pocketLevel) == tonumber(p_pocket_2.va_item_text.pocketLevel))then
			if( tonumber(p_pocket_1.itemDesc.id) < tonumber(p_pocket_2.itemDesc.id) ) then
				isPre = true
			else
				isPre = false
			end
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:得到兵符背包排序数据 符背包排序算法:品质》等级》id 
	@param 	:
	@return :返回顺序 id 》等级 》品质
--]]
function tallySortForBag( p_data_1, p_data_2 )
	local isPre = false

	if(tonumber(p_data_1.itemDesc.quality) < tonumber(p_data_2.itemDesc.quality))then
		isPre = true
	elseif(tonumber(p_data_1.itemDesc.quality) == tonumber(p_data_2.itemDesc.quality))then
		if(tonumber(p_data_1.va_item_text.tallyLevel) < tonumber(p_data_2.va_item_text.tallyLevel))then
			isPre = true
		elseif(tonumber(p_data_1.va_item_text.tallyLevel) == tonumber(p_data_2.va_item_text.tallyLevel))then
			if( tonumber(p_data_1.itemDesc.id) < tonumber(p_data_2.itemDesc.id) ) then
				isPre = true
			else
				isPre = false
			end
		else
			isPre = false
		end
	else
		isPre = false
	end
	return isPre
end

--[[
	@des 	:得到符碎片背包已排序数据  碎片背包排序算法:能合成》碎片个数多的》品质
	@param 	:
	@return :返回顺序 品质 》能合成
--]]
function tallyFragSortForBag( p_data_1, p_data_2 )
	local isPre = false
	if( tonumber(p_data_1.itemDesc.quality) < tonumber(p_data_2.itemDesc.quality) ) then
		isPre = true
	else
		isPre = false
	end
	
	return isPre
end

function getPropOrderPriority( item_template_id )
	item_template_id = tonumber(item_template_id)
	local orderN = 0
	if(item_template_id >= 30001 and item_template_id <= 40000) then
		orderN = 1
	elseif(item_template_id >= 20001 and item_template_id <= 30000) then
		orderN = 2
	elseif(item_template_id >= 10001 and item_template_id <= 30000) then
		orderN = 3
	elseif(item_template_id >= 40001 and item_template_id <= 50000) then
		orderN = 4
	elseif(item_template_id >= 50001 and item_template_id <= 60000) then
		orderN = 5
	else
		orderN = 6
	end
	return orderN
end

-- 道具排序 （策划需求的 逆序）
function propsSort( item_1, item_2 )
	local order_1 = getPropOrderPriority(item_1.item_template_id)
	local order_2 = getPropOrderPriority(item_2.item_template_id)
	local isPre = false

	if(order_1 > order_2) then
		isPre = true
	elseif(order_1 == order_2)then
		if( tonumber(item_1.itemDesc.quality) < tonumber(item_2.itemDesc.quality) ) then
			isPre = true
		--为了满足开箱子位置不变的策划需求添加 add by zhang zihang
		elseif ( tonumber(item_1.itemDesc.quality) == tonumber(item_2.itemDesc.quality) ) then
			if tonumber(item_2.item_template_id) < tonumber(item_1.item_template_id) then
				isPre = true
			end
		end
	end

	return isPre
end

-- 装备碎片排序
function armFragSort( item_1, item_2 )

	local isPre = false

	if( tonumber(item_1.itemDesc.quality) < tonumber(item_2.itemDesc.quality) ) then
		isPre = true
	elseif(tonumber(item_1.itemDesc.quality) == tonumber(item_2.itemDesc.quality)) then
		if(tonumber(item_1.item_num) < tonumber(item_2.item_num))then
			isPre = true
		elseif(tonumber(item_1.item_num) == tonumber(item_2.item_num))then
			if(tonumber(item_1.item_template_id) < tonumber(item_2.item_template_id))then
				isPre = true
			end
		end
	end

	return isPre
end

-- 战车排序
function sortChariotForBag( item_1, item_2 )
	--按品质排序
	if item_1.itemDesc.quality > item_2.itemDesc.quality then
		return false
	elseif item_1.itemDesc.quality < item_2.itemDesc.quality then
		return true
	else

	end

	--按等级排序
	local nChariotEnforce1, nChariotEnforce2 = tonumber(item_1.va_item_text.chariotEnforce), tonumber(item_2.va_item_text.chariotEnforce)
	if nChariotEnforce1 > nChariotEnforce2 then
		return false
	elseif nChariotEnforce1 < nChariotEnforce2 then
		return true
	else

	end

	return tonumber(item_1.item_id) > tonumber(item_2.item_id)
end

-- 从背包中选出宝物
function getTreasInfosExceptGid(p_ex_itemId, p_posType)
	local bagInfo = DataCache.getBagInfo()
	local retData = nil
	if(p_ex_itemId and p_posType)then
		local temp_treas = {}
		for k,v in pairs(bagInfo.treas) do
			if(tonumber(v.item_id) ~= tonumber(p_ex_itemId) and tonumber(p_posType) == tonumber(v.itemDesc.type) and tonumber(v.itemDesc.base_exp_arr) > 0 )then
				table.insert(temp_treas, v)
			end
		end
		retData = temp_treas
	end

	return retData
end

-- 解析特定字符串 (0|100,1|200)
function parseTreasString( treas_str )
	local result_arr = {}
	local t_arr = string.split(string.gsub(treas_str, " ", ""), "," )
	for k,v in pairs(t_arr) do
		local tt_arr = string.split(string.gsub(v, " ", ""), "|" )
		result_arr[tt_arr[1]] = tonumber(tt_arr[2])
	end
	return result_arr
end

-- 计算宝物的升级概率
function getTreasUpgradeRate( item_id, m_item_ids )
	local rate = 0
	if( item_id and (not table.isEmpty(m_item_ids)) )then
		local s_total = 0
		for k, itemId in pairs(m_item_ids) do
			local itemInfo = ItemUtil.getItemInfoByItemId(tonumber(itemId))
			itemInfo.itemDesc = ItemUtil.getItemById(tonumber(itemInfo.item_template_id))
			local result_arr = parseTreasString(itemInfo.itemDesc.base_exp_arr)
			s_total = s_total + result_arr["" .. itemInfo.va_item_text.treasureLevel]
		end
		local item_Info = ItemUtil.getItemInfoByItemId(tonumber(item_id))

		if(table.isEmpty(item_Info))then
			item_Info = ItemUtil.getTreasInfoFromHeroByItemId(tonumber(item_id))
		end
		item_Info.itemDesc = ItemUtil.getItemById(tonumber(item_Info.item_template_id))
		local result_arr = parseTreasString(item_Info.itemDesc.total_upgrade_exp)
		local t_total = result_arr["" .. item_Info.va_item_text.treasureLevel]
		rate = s_total/t_total
	end
	rate = rate > 1 and 1 or rate

	return rate
end

-- 计算宝物的获得的经验
function getTreasAddExpBy( m_item_ids )

	local totalExp = 0
	for k, v in pairs(m_item_ids) do
		local item_Info = ItemUtil.getItemByItemId(v.item_id)

		if(tonumber(item_Info.itemDesc.maxStacking) > 1)then
			totalExp = totalExp + tonumber(item_Info.itemDesc.base_exp_arr) * v.num
		else
			totalExp = totalExp + tonumber(item_Info.itemDesc.base_exp_arr) + tonumber(item_Info.va_item_text.treasureExp)
		end
	end

	return totalExp
end

-- 计算宝物升级所需硬币
function getCostSliverByItemId( item_id )
	local item_Info = ItemUtil.getItemInfoByItemId(tonumber(item_id))

	if(table.isEmpty(item_Info))then
		item_Info = ItemUtil.getTreasInfoFromHeroByItemId(tonumber(item_id))
	end
	item_Info.itemDesc = ItemUtil.getItemById(tonumber(item_Info.item_template_id))
	local result_arr = parseTreasString(item_Info.itemDesc.upgrade_cost_arr)
	local costSliver = result_arr["" .. item_Info.va_item_text.treasureLevel]
	local levelLimited = item_Info.itemDesc.level_limited
	costSliver = costSliver or 0

	return costSliver, levelLimited
end

-- 类型对应名称
local name_text_arr = {
						-- 1
						{GetLocalizeStringBy("key_2338"), GetLocalizeStringBy("key_2431"), GetLocalizeStringBy("key_1977"), GetLocalizeStringBy("key_2841") },
						-- 2
						"",
						-- 3
						GetLocalizeStringBy("key_1870"),
						-- 4
						GetLocalizeStringBy("key_3140"),
						-- 5
						GetLocalizeStringBy("key_1801"),
						-- 6
						GetLocalizeStringBy("key_1870"),
						-- 7
						GetLocalizeStringBy("key_3237"),
						-- 8
						GetLocalizeStringBy("key_1870"),
						-- 9
						GetLocalizeStringBy("key_2832"),
						-- 10
						GetLocalizeStringBy("key_1870"),
						-- 11
						{GetLocalizeStringBy("key_1767"), GetLocalizeStringBy("key_3093")},
						-- 12
						GetLocalizeStringBy("key_1801"),
						-- 13
						GetLocalizeStringBy("key_1624"),
						-- 14
						GetLocalizeStringBy("key_2020"),
						-- 15
						"",
						-- 16
						{GetLocalizeStringBy("lic_1447"), GetLocalizeStringBy("lic_1448"), GetLocalizeStringBy("lic_1449"), GetLocalizeStringBy("lic_1450"),GetLocalizeStringBy("lic_1451") },
						-- 17
						GetLocalizeStringBy("key_1801"),
						-- 18
						{GetLocalizeStringBy("lic_1538"), GetLocalizeStringBy("lic_1539")},
						-- 19
						GetLocalizeStringBy("key_1801"),
						-- 20 锦囊
						GetLocalizeStringBy("lic_1625"),
						-- 21 兵符
						{GetLocalizeStringBy("lic_1774"),GetLocalizeStringBy("lic_1775"),GetLocalizeStringBy("lic_1776")},
					   }

-- 获得某个物品的印章
function getSealSpriteByItemTempId( item_template_id )
	local name_text = nil
	if(item_template_id ~= nil)then
		local item_info = ItemUtil.getItemById(item_template_id)
		if(item_info.item_type == 1 or item_info.item_type == 11 or item_info.item_type == 16 or item_info.item_type == 18 )then
			local t_name_text = name_text_arr[item_info.item_type]
			name_text = t_name_text[item_info.type]
		elseif(item_info.item_type == 20)then
			name_text = item_info.pocket_desc
		elseif(item_info.item_type == 21)then
			local t_name_text = name_text_arr[item_info.item_type]
			name_text = t_name_text[item_info.bingfu_type]
		else
			name_text = name_text_arr[item_info.item_type]
		end
	end
	if(name_text == nil)then
		name_text = GetLocalizeStringBy("key_1870")
	end
	local nameLabel = CCLabelTTF:create(name_text, g_sFontPangWa, 24)
    nameLabel:setColor(ccc3(0xff, 0xe7, 0x64))
    nameLabel:setAnchorPoint(ccp(0.5, 0.5))


    local sealSprite = CCScale9Sprite:create("images/common/bg/seal_9s_bg.png")
    sealSprite:setContentSize(CCSizeMake( nameLabel:getContentSize().width + 10, 37))
    nameLabel:setPosition(ccp( sealSprite:getContentSize().width*0.5, sealSprite:getContentSize().height*0.5))
    sealSprite:addChild(nameLabel)

    return sealSprite
end


-------------- 添加装备碎片能合成个数提示  by licong---------------
-- 装备碎片能合成装备的个数
function getCanCompoundNumByArmFrag( ... )
	local bagInfo = DataCache.getBagInfo()
	local  armFragData = {}
	if (bagInfo) then
		armFragData = bagInfo.armFrag
	end
	-- print(GetLocalizeStringBy("key_1398"))
	-- print_t(armFragData)
	local num = 0
	for k,v in pairs(armFragData) do
		if( tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num) )then
			num = num + 1
		end
	end
	return num
end

-- 是否显示装备按钮上红圈
function isShowTipSprite( ... )
	local num = getCanCompoundNumByArmFrag()
	if(num > 0)then
		return true
	else
		return false
	end
end

----------------------------------------------------------


-------------- 添加神兵碎片能合成个数提示  by licong---------------
-- 神兵碎片能合成神兵的个数
function getCanCompoundNumByGodWeaponFrag( ... )
	local num = 0
	local bagInfo = DataCache.getBagInfo()
	if ( not table.isEmpty(bagInfo) ) then
		for k,v in pairs(bagInfo.godWpFrag) do
			if( tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num) )then
				num = num + 1
			end
		end
	end
	return num
end

-- 是否显示神兵按钮上红圈
function isShowGodWeaponTipSprite( ... )
	local num = getCanCompoundNumByGodWeaponFrag()
	if(num > 0)then
		return true
	else
		return false
	end
end

-------------- 添加符印碎片能合成个数提示  by licong---------------
-- 符印碎片能合成神兵的个数
function getCanCompoundNumByRuneFrag( ... )
	local num = 0
	local bagInfo = DataCache.getBagInfo()
	for k,v in pairs(bagInfo.runeFrag) do
		if( tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num) )then
			num = num + 1
		end
	end
	print(num)
	return num
end

-- 是否显示符印按钮上红圈
function isShowRuneTipSprite( ... )
	local num = getCanCompoundNumByRuneFrag()
	if(num > 0)then
		return true
	else
		return false
	end
end

-------------- 添加兵符碎片能合成个数提示  by licong---------------
-- 兵符碎片能合成神兵的个数
function getCanCompoundNumByTallyFrag( ... )
	local num = 0
	local bagInfo = DataCache.getBagInfo()
	for k,v in pairs(bagInfo.tallyFrag) do
		if( tonumber(v.itemDesc.need_part_num) <= tonumber(v.item_num) )then
			num = num + 1
		end
	end
	print(num)
	return num
end

-- 是否显示兵符按钮上红圈
function isShowTallyTipSprite( ... )
	local num = getCanCompoundNumByTallyFrag()
	if(num > 0)then
		return true
	else
		return false
	end
end

-------------------------战车背包 红点相关-----------------------------------
function isShowChariotTipSprite( ... )
	local bShowSprite = false
	
	local bHasNew = getNewChariot()
	if bHasNew then
		bShowSprite = true
	end

	return bShowSprite
end

function userDefaultKeyForNewChariot( ... )
	local sKey = UserModel.getUserUid() .. "new_chariot"
	print("userDefaultKeyForNewChariot: ", sKey)
	return sKey
end

--是否新获得的战车
function getNewChariot( ... )
	local sKey = userDefaultKeyForNewChariot()
	local bHasNew = CCUserDefault:sharedUserDefault():getBoolForKey(sKey)
	return bHasNew
end

--保存红点状态
function setNewChariot( pBool )
	local bHasNew = pBool or false
	print("setNewChariot bHasNew: ", bHasNew)
	local sKey = userDefaultKeyForNewChariot()
	CCUserDefault:sharedUserDefault():setBoolForKey(sKey, bHasNew)
	CCUserDefault:sharedUserDefault():flush()
end

local _mapUnequipedChariot = {}
--记录刚卸下的战车的item_id（在卸下战车操作成功时调用）
function recordUnequipedChariot( pChariotId )
	_mapUnequipedChariot[tonumber(pChariotId)] = true
end

--根据战车id，判断是否是刚卸下的战车
function isUnequipedChariot( pChariotId )
	local bRet = false

	if not table.isEmpty(_mapUnequipedChariot) and _mapUnequipedChariot[tonumber(pChariotId)] == true then
		bRet = true
	end

	return bRet
end

--处理推送过来的战车信息红点显示状态
function setNewChariotWithPush( pChariotId )
	local bUnequiped = isUnequipedChariot(pChariotId)
	if not bUnequiped then
		setNewChariot(true)

		--一旦显示红点，后面就不再需要判断是否是卸下的战车
		_mapUnequipedChariot = {}
	end
end

----------------------------------------------------------

-- 补全背包数据
function handleBagInfos( p_bag_info )
	for sub_key, sub_bag_info in pairs(p_bag_info) do
		if( "gridStart" ~= sub_key and "gridMaxNum" ~= sub_key and (not table.isEmpty(sub_bag_info)) )then
			for m_item_id, m_item_info in pairs(sub_bag_info) do

				-- 不得已而为之
				p_bag_info[sub_key][m_item_id].item_id = tostring(tonumber(p_bag_info[sub_key][m_item_id].item_id))

				if(m_item_info.item_num == nil)then
					p_bag_info[sub_key][m_item_id].item_num = "1"
				end
				if(table.isEmpty(m_item_info.va_item_text) )then
					p_bag_info[sub_key][m_item_id].va_item_text = {}
					if(sub_key == "treas")then
						p_bag_info[sub_key][m_item_id].va_item_text.treasureLevel = "0"
					end
				end
			end
		end
	end
	return p_bag_info
end



--[[
	@des 	: 得到使用金箱子限制
	@param 	:
	@return : vip and needLv
--]]
function getUseGoldBoxLimit()
	require "db/DB_Normal_config"
	local dbData = DB_Normal_config.getDataById(1)
	local temp = string.split(dbData.usegoldbox,"|")
	return tonumber(temp[1]),tonumber(temp[2])
end

--[[
	@des 	: 使用产出金币和VIP经验的物品 add by yangrui at 16-01-06
	@param 	:
	@return : 
--]]
function userProductGoldAndVipExpItem( pItemData, pUseNum )
	-- 之前充值的额度
	local priorChargeGoldNum = DataCache.getChargeGoldNum()
	-- 之前的VIP等级
	local priorVipLv = UserModel.getVipLevel()
	-- 当前的vip等级
	local curVipLv = UserModel.getVipLevel()
	if( pItemData.itemDesc.vip_exp ~= nil )then
		require "script/model/DataCache"
		local addGoldNum = tonumber(pItemData.itemDesc.golds)*pUseNum
		DataCache.addChargeGold(addGoldNum)
	end
	-- 如果增加的金币数大于升级所需的金币数 刷新上方信息栏
	local curChargeGoldNum = DataCache.getChargeGoldNum()
	-- 当前已充值的金币数在VIP表中处于哪儿一VIP等级
	require "db/DB_Vip"
	local lvPos = 0
	local vipData = DB_Vip.Vip
	local vipDataLen = table.count(vipData)
	for i=1,vipDataLen do
		local curData = DB_Vip.getDataById(i)
		if curData.rechargeValue <= curChargeGoldNum then
			lvPos = curData.level
		else
			break
		end
	end
	if lvPos > priorVipLv then
		-- 修改vip等级
		UserModel.setVipLevel(lvPos)
		-- refresh vip lv
		require "script/ui/main/MainScene"
		MainScene.updateAvatarInfo()
	end
end

--[[
	@des 	: 判断版本是否支持背包cell下拉
	@param 	:
	@return : 
--]]
function isSupportBagCell()
	local retData = false
	if(string.checkScriptVersion(g_publish_version, "5.0.0") >=0)then
		retData = true
	else
		retData = false
	end
	return retData
end



