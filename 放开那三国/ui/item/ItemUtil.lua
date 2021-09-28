-- Filename：	ItemUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-7-10
-- Purpose：		物品Item
module("ItemUtil", package.seeall)


require "script/utils/LuaUtil"
require "script/model/user/UserModel"
require "script/model/hero/HeroModel"
require "script/ui/hero/HeroPublicLua"
require "db/DB_City"
require "script/ui/guild/GuildDataCache"

local _forwardDelegate = nil
local _isBigMap		   = false
local BG_PATH		   = "images/common/"

-- 使用某个物品所获得的物品 i_id/i_num/isModifyCache <=> 物品templateid/个数/是否修改缓存
function getUseResultBy( i_id, i_num , isModifyCache)

	if(isModifyCache == nil) then
		isModifyCache = false
	end


	local useResult = nil
	local result = {}
	local result_text = ""
	require "db/DB_Item_direct"
	local i_data = DB_Item_direct.getDataById(i_id)


	if(i_data.coins and i_data.coins > 0) then
		result.coins = i_data.coins * i_num
		result_text = result_text  .. result.coins .. GetLocalizeStringBy("key_2894")
	end
	if(i_data.golds and i_data.golds > 0) then
		result.golds = i_data.golds * i_num
		result_text = result_text  .. result.golds .. GetLocalizeStringBy("key_1447")
	end
	if(i_data.energy and i_data.energy > 0) then
		result.energy = i_data.energy * i_num
		result_text = result_text  .. result.energy .. GetLocalizeStringBy("key_3238")
	end
	if(i_data.general_soul and i_data.general_soul > 0) then
		result.general_soul = i_data.general_soul * i_num
		result_text = result_text  .. result.general_soul .. GetLocalizeStringBy("key_1598")
	end
	if(i_data.endurance and i_data.endurance > 0) then
		result.endurance = i_data.endurance * i_num
		result_text = result_text  .. result.endurance .. GetLocalizeStringBy("key_2991")
	end
	-- 加经验
	if(i_data.exp and i_data.exp > 0) then
		result.exp = i_data.exp * i_num
		result_text = result_text  .. result.exp .. GetLocalizeStringBy("lic_1529")
	end
	-- if(i_data.award_item_id and i_data.award_item_id > 0) then
	-- 	result.award_item_id = i_data.award_item_id
	-- 	local tempData = ItemUtil.getItemById(i_data.award_item_id)
	-- 	result_text = result_text  .. tempData.name .. " "
	-- 	tempData = nil
	-- end

	-- 英雄卡牌
	if(i_data.award_card_id) then

		local tempArr = string.split(i_data.award_card_id , "|")

		result.award_card_id = tempArr[1]

		require "db/DB_Heroes"
		local tempData = DB_Heroes.getDataById(tonumber(tempArr[1]))
		result_text = result_text  .. tempData.name .. GetLocalizeStringBy("key_1869")

		package.loaded["db/DB_Heroes"] = nil

	end
	if(i_data.add_challenge_times and i_data.add_challenge_times > 0) then
		result.add_challenge_times = i_data.add_challenge_times * i_num
		result_text = result_text  .. result.add_challenge_times .. GetLocalizeStringBy("key_3088")
	end

	if( i_data.getPet and  i_data.getPet > 0 )then
		-- print("i_data.getPet",i_data.getPet)
		require "db/DB_Pet"
		result_text = result_text .. " " .. DB_Pet.getDataById(i_data.getPet).roleName .. "*" .. i_num
	end
	if( i_data.vip_exp ~= nil ) then
		-- 是Vip道具
		result_text = result_text .. GetLocalizeStringBy("yr_10000",(tonumber(i_data.vip_exp)*i_num))
	end
	-- 声望
	if(i_data.prestige and i_data.prestige > 0) then
		result.prestige = i_data.prestige * i_num
		result_text = result_text  .. result.prestige .. GetLocalizeStringBy("lic_1820")
	end
	-- 科技图纸
	if(i_data.tech and i_data.tech > 0) then
		result.tech = i_data.tech * i_num
		result_text = result_text  .. result.tech .. GetLocalizeStringBy("lic_1812")
	end
	if ( result )then
		useResult = {}
		useResult.result = result
		useResult.result_text = result_text

		if(isModifyCache) then
			if (result.coins) then
				UserModel.changeSilverNumber(result.coins)
			elseif(result.golds)then
				UserModel.changeGoldNumber(result.golds)
			elseif(result.energy)then
				UserModel.changeEnergyValue(result.energy)
			elseif(result.endurance)then
				UserModel.changeStaminaNumber(result.endurance)
			elseif(result.general_soul)then
				UserModel.changeHeroSoulNumber(result.general_soul)
			elseif(result.exp)then
				UserModel.addExpValue(result.exp)
			elseif(result.prestige)then
				UserModel.addPrestigeNum(result.prestige)
			elseif(result.tech)then
				UserModel.addBookNum(result.tech)
			else
			end
		end
	end
	return useResult
end


-- 通过ID获取某个物品的属性所有信息 i_id<=>item_template_id
function getItemById( i_id )
	i_id = tonumber(i_id)
	local i_data = nil
	if(i_id >= 10001 and i_id <= 20000) then
		-- 直接使用类：10001~30000
		require "db/DB_Item_direct"
		i_data = DB_Item_direct.getDataById(i_id)

	elseif(i_id >= 20001 and i_id <= 30000) then
		-- 礼包类物品：
		require "db/DB_Item_gift"
		i_data = DB_Item_gift.getDataById(i_id)

	elseif(i_id >= 30001 and i_id <= 40000) then
		-- 随机礼包类：
		require "db/DB_Item_randgift"
		i_data = DB_Item_randgift.getDataById(i_id)

	elseif(i_id >= 50001 and i_id <= 60000) then
		-- 坐骑饲料类：50001~80000
		require "db/DB_Item_feed"
		i_data = DB_Item_feed.getDataById(i_id)

	elseif(i_id >= 60001 and i_id <= 70000) then
		-- 普通物品
		require "db/DB_Item_normal"
		i_data = DB_Item_normal.getDataById(i_id)

	elseif(i_id >= 200001 and i_id <= 300000) then
		-- 武将技能书：
		require "db/DB_Item_book"
		i_data = DB_Item_book.getDataById(i_id)

	elseif(i_id >= 40001 and i_id <= 50000) then
		-- 好感礼物类：100001~120000
		require "db/DB_Item_star_gift"
		i_data = DB_Item_star_gift.getDataById(i_id)

	elseif(i_id >= 400001 and i_id <= 500000) then
		-- 武将碎片类：
		require "db/DB_Item_hero_fragment"
		i_data = DB_Item_hero_fragment.getDataById(i_id)

	elseif(i_id >= 1000001 and i_id <= 5000000) then
		-- 物品碎片类：
		require "db/DB_Item_fragment"
		i_data = DB_Item_fragment.getDataById(i_id)

	elseif(i_id >= 100001 and i_id <= 200000) then
		-- 装备类：
		require "db/DB_Item_arm"
		i_data = DB_Item_arm.getDataById(i_id)
		i_data.desc = i_data.info
	elseif(i_id >= 500001 and i_id <= 600000) then
		-- 宝物类：
		require "db/DB_Item_treasure"
		i_data = DB_Item_treasure.getDataById(i_id)
		i_data.desc = i_data.info
	elseif( i_id >= 5000001 and i_id <= 6000000 )then
		-- 宝物碎片
		require "db/DB_Item_treasure_fragment"
		i_data = DB_Item_treasure_fragment.getDataById(i_id)
		i_data.desc = i_data.info
	elseif( i_id >= 70001 and i_id <= 80000 )then
		-- 战魂
		require "db/DB_Item_fightsoul"
		i_data = DB_Item_fightsoul.getDataById(i_id)
		i_data.desc = i_data.info

	elseif( i_id >= 80001 and i_id <= 90000 )then
		-- 时装
		require "db/DB_Item_dress"
		i_data = DB_Item_dress.getDataById(i_id)

		i_data.desc = i_data.info
	elseif( i_id >= 6000001 and i_id <= 7000000 ) then
		require "db/DB_Item_pet_fragment"
		i_data = DB_Item_pet_fragment.getDataById(i_id)
	elseif( i_id >= 600001 and i_id <= 700000 ) then
		-- 神兵
		require "db/DB_Item_godarm"
		i_data = DB_Item_godarm.getDataById(i_id)
		i_data.desc = i_data.info
	elseif( i_id >= 7000001 and i_id <= 8000000 ) then
		-- 神兵碎片
		require "db/DB_Item_godarm_fragment"
		i_data = DB_Item_godarm_fragment.getDataById(i_id)
	elseif( i_id >= 700001 and i_id <= 800000 ) then
		-- 符印
		require "db/DB_Item_fuyin"
		i_data = DB_Item_fuyin.getDataById(i_id)
	elseif( i_id >= 8000001 and i_id <= 9000000 ) then
		-- 符印碎片
		require "db/DB_Item_fuyin_fragment"
		i_data = DB_Item_fuyin_fragment.getDataById(i_id)
	elseif( i_id >= 800001 and i_id <= 900000 ) then
		-- 锦囊
		require "db/DB_Item_pocket"
		i_data = DB_Item_pocket.getDataById(i_id)
	elseif( i_id >= 900001 and i_id <= 910000 ) then
		-- 兵符
		require "db/DB_Item_bingfu"
		i_data = DB_Item_bingfu.getDataById(i_id)
	elseif( i_id >= 9000001 and i_id <= 9100000 ) then
		-- 兵符碎片
		require "db/DB_Item_bingfu_fragment"
		i_data = DB_Item_bingfu_fragment.getDataById(i_id)
	elseif( i_id >= 920001 and i_id <= 930000 ) then
		-- 战车
		require "db/DB_Item_warcar"
		i_data = DB_Item_warcar.getDataById(i_id)
	else
		print("item not found i_id",i_id)

	end

	return i_data
end

M_Type_Arm 		= 1 	-- 装备
M_Type_Prop 	= 2 	-- 道具
M_Type_Treas	= 3 	-- 宝物

-- 根据模板ID返回物品类型
function getItemTypeByTId( item_template_id )
	local type_str = nil

	if(item_template_id >= 100001 and item_template_id <= 200000) then
		-- 装备类	：
		type_str = M_Type_Arm
	elseif(item_template_id >= 500001 and item_template_id <= 600000) then
		-- 宝物
		type_str = M_Type_Treas
	else
		-- 道具
		type_str = M_Type_Prop
	end

	return type_str
end

-- 获取饲料
function getFeedInfos()
	local feedInfos = {}
	local allBagInfo = DataCache.getBagInfo()
	if(table.isEmpty( allBagInfo ) == false	) then
		for k, prop_info in pairs(allBagInfo.props) do
			if( tonumber(prop_info.item_template_id)>= 50001 and tonumber(prop_info.item_template_id)<60000 ) then
				table.insert(feedInfos, prop_info)
			end
		end
	end
	return feedInfos
end

-- 获得宠物碎片的信息
function getPetFragInfos( )
	local petFragInfos = {}
	local allBagInfo = DataCache.getBagInfo()
	if(table.isEmpty( allBagInfo.petFrag ) == false	) then
		for k, petFragInfo in pairs(allBagInfo.petFrag) do
			if( tonumber(petFragInfo.item_template_id)>= 6000001 and tonumber(petFragInfo.item_template_id)<=7000000 ) then
				table.insert(petFragInfos, petFragInfo)
			end
		end
	end
	return petFragInfos

end

-- 获得某个物品的所有信息
function getFullItemInfoByGid( gid )
	local i_gid = tonumber(gid)
	-- i_gid= 2000004
	local bagInfo = DataCache.getBagInfo()
	-- local remoteBagInfo = DataCache.getRemoteBagInfo()
	local fullItemInfo = nil

	local i_data_t = {}
	if (i_gid >= 2000001 and i_gid < 3000000 ) then
		-- 装备
		i_data_t = bagInfo.arm
	elseif(i_gid >= 3000001 and i_gid < 4000000) then
		-- 道具
		i_data_t = bagInfo.props
	elseif(i_gid >= 4000001 and i_gid < 5000000) then
		-- 武将碎片
		i_data_t = bagInfo.heroFrag
	elseif(i_gid >= 5000001 and i_gid < 6000000) then
		-- 宝物
		i_data_t = bagInfo.treas

	elseif(i_gid >= 6000001 and i_gid < 7000000)then
		-- 装备碎片
		i_data_t = bagInfo.armFrag
	elseif(i_gid >= 11000001 and i_gid < 12000000)then
		-- 神兵碎片
		i_data_t = bagInfo.godWpFrag
	elseif(i_gid >= 13000001 and i_gid < 14000000)then
		-- 符印碎片
		i_data_t = bagInfo.runeFrag
	elseif(i_gid >= 16000001 and i_gid < 17000001)then
		-- 兵符碎片
		i_data_t = bagInfo.tallyFrag
	else
		print("Error: Not Found!")
	end
	-- print_t(i_data_t)
	if(not table.isEmpty(i_data_t))then
		for k,tempItem in pairs(i_data_t) do
			if( tonumber(tempItem.gid) == i_gid)then
				fullItemInfo = tempItem
				break
			end
		end
	else
		-- 在临时背包
		local isFind = false
		if(not table.isEmpty(bagInfo.arm))then
			-- 是不是装备
			for r_gid, r_data in pairs(bagInfo.arm) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(bagInfo.props))then
			-- 是不是道具
			for r_gid, r_data in pairs(bagInfo.props) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(bagInfo.treas))then
			-- 是不是宝物
			for r_gid, r_data in pairs(bagInfo.treas) do
				if( tonumber(r_gid) == i_gid) then
					ifullItemInfo = r_data
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(bagInfo.heroFrag))then
			-- 是不是武将碎片
			for r_gid, r_data in pairs(bagInfo.heroFrag) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end

		if( isFind == false and not table.isEmpty(bagInfo.armFrag))then
			-- 是不是装备碎片
			for r_gid, r_data in pairs(bagInfo.armFrag) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end

		if (isFind == false and not table.isEmpty(bagInfo.petFrag))then
			--是不是宠物碎片
			for r_gid,r_data in pairs(bagInfo.petFrag) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end
		if (isFind == false and not table.isEmpty(bagInfo.godWpFrag))then
			--是不是神兵碎片
			for r_gid,r_data in pairs(bagInfo.godWpFrag) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end
		if (isFind == false and not table.isEmpty(bagInfo.runeFrag))then
			--是不是符印碎片
			for r_gid,r_data in pairs(bagInfo.runeFrag) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end
		if (isFind == false and not table.isEmpty(bagInfo.tallyFrag))then
			--是不是兵符碎片
			for r_gid,r_data in pairs(bagInfo.tallyFrag) do
				if( tonumber(r_gid) == i_gid) then
					fullItemInfo = r_data
					break
				end
			end
		end
	end


	return fullItemInfo
end

-- 减少物品的个数    i_gid/i_num <=> 格子id/数量
function reduceItemByGid( i_gid, i_num, isForceDel )
	isForceDel = isForceDel or false
	i_gid = tonumber(i_gid)
	if(i_num == nil) then
		i_num = 1
	end
	local remoteBagInfo = DataCache.getRemoteBagInfo()
	local i_data_t = {}
	if (i_gid >= 2000001 and i_gid < 3000000 ) then
		-- 装备
		i_data_t = remoteBagInfo.arm
	elseif(i_gid >= 3000001 and i_gid < 4000000) then
		-- 道具
		i_data_t = remoteBagInfo.props
	elseif(i_gid >= 4000001 and i_gid < 5000000) then
		-- 武将碎片
		i_data_t = remoteBagInfo.heroFrag
	elseif(i_gid >= 5000001 and i_gid < 6000000) then
		-- 宝物
		i_data_t = remoteBagInfo.treas
	elseif(i_gid >= 6000001 and i_gid < 7000000)then
		-- 装备碎片
		i_data_t = remoteBagInfo.armFrag
	elseif(i_gid >= 9000001 and i_gid < 10000000)then
		--宠物碎片
		i_data_t = remoteBagInfo.petFrag
	end

	if(not table.isEmpty(i_data_t))then
		-- 不是临时背包
		for r_gid, r_data in pairs(i_data_t) do
			if( tonumber(r_gid) == i_gid) then
				if(isForceDel == true)then
					i_data_t[r_gid] = nil
				else
					if ( tonumber(r_data.item_num) <= i_num)then
						-- table.remove(i_data_t, r_gid)
						i_data_t[r_gid] = nil
					else
						i_data_t[r_gid].item_num = tonumber(r_data.item_num) - i_num
					end
				end
				if (i_gid >= 2000001 and i_gid < 3000000 ) then
					-- 装备
					remoteBagInfo.arm = i_data_t
				elseif(i_gid >= 3000001 and i_gid < 4000000) then
					-- 道具
					remoteBagInfo.props = i_data_t
				elseif(i_gid >= 4000001 and i_gid < 5000000) then
					-- 武将碎片
					remoteBagInfo.heroFrag = i_data_t
				elseif(i_gid >= 5000001 and i_gid < 6000000) then
					-- 宝物
					remoteBagInfo.treas = i_data_t
				elseif(i_gid >= 6000001 and i_gid < 7000000)then
					-- 装备碎片
					remoteBagInfo.armFrag = i_data_t
				elseif(i_gid >= 9000001 and i_gid < 10000000)then
					--宠物碎片
					remoteBagInfo.petFrag = i_data_t
				end
				DataCache.setBagInfo(remoteBagInfo)
				break
			end
		end
	else
		-- 在临时背包
		local isFind = false
		if(not table.isEmpty(remoteBagInfo.arm))then
			-- 是不是装备
			for r_gid, r_data in pairs(remoteBagInfo.arm) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.arm[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.arm[r_gid] = nil
						else
							remoteBagInfo.arm[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(remoteBagInfo.props))then
			-- 是不是道具
			for r_gid, r_data in pairs(remoteBagInfo.props) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.props[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.props[r_gid] = nil
						else
							remoteBagInfo.props[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(remoteBagInfo.treas))then
			-- 是不是宝物
			for r_gid, r_data in pairs(remoteBagInfo.treas) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.treas[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.treas[r_gid] = nil
						else
							remoteBagInfo.treas[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
		if( isFind == false and not table.isEmpty(remoteBagInfo.heroFrag))then
			-- 是不是武将碎片
			for r_gid, r_data in pairs(remoteBagInfo.heroFrag) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.heroFrag[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.heroFrag[r_gid] = nil
						else
							remoteBagInfo.heroFrag[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end

		if( isFind == false and not table.isEmpty(remoteBagInfo.armFrag))then
			-- 是不是装备碎片
			for r_gid, r_data in pairs(remoteBagInfo.armFrag) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.armFrag[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.armFrag[r_gid] = nil
						else
							remoteBagInfo.armFrag[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end

		if (isFind == false and not table.isEmpty(remoteBagInfo.petFrag))then
			--是不是宠物碎片
			for r_gid,r_data in pairs(remoteBagInfo.petFrag) do
				if( tonumber(r_gid) == i_gid) then
					if(isForceDel == true)then
						remoteBagInfo.petFrag[r_gid] = nil
					else
						if ( tonumber(r_data.item_num) <= i_num)then
							remoteBagInfo.petFrag[r_gid] = nil
						else
							remoteBagInfo.petFrag[r_gid].item_num = tonumber(r_data.item_num) - i_num
						end
					end
					isFind = true
					DataCache.setBagInfo(remoteBagInfo)
					break
				end
			end
		end
	end

	DataCache.setBagStatus(true)
end

--[[
	获得装备的各种数值
	parm	i_id<=>item_id
	return	t_numerial
			t_numerial.hp
			t_numerial.phy_att
			t_numerial.magic_att
			t_numerial.phy_def
			t_numerial.magic_def
--]]
function getEquipNumerialByIID( i_id )
	i_id = tonumber(i_id)

	local t_numerial = {}
	local t_numerial_pl = {}
	local t_equip_score = 0
	-- 获取装备数据
	local a_bagInfo = DataCache.getBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
	--		print("s_data.item_id==", s_data.item_id,  "i_id ===", i_id)
		if( tonumber(s_data.item_id) == i_id ) then
			equipData = s_data
			break
		end
	end

	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(i_id)
		if( not table.isEmpty(equipData))then
			require "db/DB_Item_arm"
			equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

		end
	end
	-- 进行计算
	if( table.isEmpty(equipData) == false) then
		local equip_desc = equipData.itemDesc
		local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)

		local developData = EquipAffixModel.getDevelopAffixByInfo(equipData)
		-- 生命值
		t_numerial.hp 		  = math.floor(equip_desc.baseLife + forceLevel* equip_desc.lifePL/100) + (developData[AffixDef.LIFE] or 0)
		-- 通用攻击
		t_numerial.gen_att	  = math.floor(equip_desc.baseGenAtt + forceLevel* equip_desc.genAttPL/100) + (developData[AffixDef.GENERAL_ATTACK] or 0)
		-- 物攻
		t_numerial.phy_att	  = math.floor(equip_desc.basePhyAtt + forceLevel* equip_desc.phyAttPL/100) + (developData[AffixDef.PHYSICAL_ATTACK] or 0)
		-- 魔攻
		t_numerial.magic_att  = math.floor(equip_desc.baseMagAtt + forceLevel* equip_desc.magAttPL/100) + (developData[AffixDef.MAGIC_ATTACK] or 0)
		-- 物防
		t_numerial.phy_def 	  = math.floor(equip_desc.basePhyDef + forceLevel* equip_desc.phyDefPL/100) + (developData[AffixDef.PHYSICAL_DEFEND] or 0)
		-- 魔防
		t_numerial.magic_def  = math.floor(equip_desc.baseMagDef + forceLevel* equip_desc.magDefPL/100) + (developData[AffixDef.MAGIC_DEFEND] or 0)

		t_numerial_pl.hp		= math.floor(equip_desc.lifePL/100) + (developData[AffixDef.LIFE] or 0)
		t_numerial_pl.gen_att	= equip_desc.genAttPL/100 + (developData[AffixDef.GENERAL_ATTACK] or 0) --math.floor(equip_desc.genAttPL/100)
		t_numerial_pl.phy_att	= equip_desc.phyAttPL/100 + (developData[AffixDef.PHYSICAL_ATTACK] or 0) --math.floor(equip_desc.phyAttPL/100)
		t_numerial_pl.magic_att	= equip_desc.magAttPL/100 + (developData[AffixDef.MAGIC_ATTACK] or 0) --math.floor(equip_desc.magAttPL/100)
		t_numerial_pl.phy_def	= equip_desc.phyDefPL/100 + (developData[AffixDef.PHYSICAL_DEFEND] or 0) --math.floor(equip_desc.phyDefPL/100)
		t_numerial_pl.magic_def	= equip_desc.magDefPL/100 + (developData[AffixDef.MAGIC_DEFEND] or 0)--math.floor(equip_desc.magDefPL/100)

		t_equip_score = equip_desc.base_score + forceLevel* equip_desc.grow_score

	end
	return t_numerial, t_numerial_pl, t_equip_score
end


-- 获得前两条数据用于显示
function getTop2NumeralByIID( i_id )
	local i_id = tonumber(i_id)
	local t_numerial, t_numerial_pl, t_equip_score = getEquipNumerialByIID(i_id)
	local f_data = 0
	local f_key  = nil
	local s_data = 0
	local s_key  = nil
	for key, t_num in pairs(t_numerial) do
		if(f_data == nil) then
			f_key  = key
			f_data = t_num
		elseif( t_num > f_data ) then
			s_key  = f_key
			s_data = f_data
			f_key  = key
			f_data = t_num
		elseif( t_num > s_data) then
			s_key  = key
			s_data = t_num
		end
	end
	local tmplData = {}
	local tmplData_PL = {}
	if (f_key) then
		tmplData[f_key] = f_data
		tmplData_PL[f_key] = t_numerial_pl[f_key]
	end
	if (s_key) then
		tmplData[s_key] = s_data
		tmplData_PL[s_key] = t_numerial_pl[s_key]
	end
	return tmplData, tmplData_PL, t_equip_score
end


--[[
	获得装备的各种数值
	parm	tmpl_id<=>item_template_id
	return	t_numerial
			t_numerial.hp
			t_numerial.phy_att
			t_numerial.magic_att
			t_numerial.phy_def
			t_numerial.magic_def
--]]
function getEquipNumerialByTmplID( tmpl_id )
	local tmpl_id = tonumber(tmpl_id)
	local t_numerial 	= {}
	local t_numerial_pl = {}
	local t_equip_score = 0
	-- 获取装备数据
	require "db/DB_Item_arm"
	local equip_desc = DB_Item_arm.getDataById(tmpl_id)


	-- 生命值
	t_numerial.hp 		  = equip_desc.baseLife
	-- 通用攻击
	t_numerial.gen_att	  = equip_desc.baseGenAtt
	-- 物攻
	t_numerial.phy_att	  = equip_desc.basePhyAtt
	-- 魔攻
	t_numerial.magic_att  = equip_desc.baseMagAtt
	-- 物防
	t_numerial.phy_def 	  = equip_desc.basePhyDef
	-- 魔防
	t_numerial.magic_def  = equip_desc.baseMagDef
	-- print("equip_desc.genAttPL, equip_desc.phyAttPL, equip_desc.magAttPL, equip_desc.phyDefPL, equip_desc.magDefPL===", equip_desc.genAttPL, equip_desc.phyAttPL, equip_desc.magAttPL, equip_desc.phyDefPL, equip_desc.magDefPL)
	t_numerial_pl.hp		= math.floor(equip_desc.lifePL/100)
	t_numerial_pl.gen_att	= equip_desc.genAttPL/100 --math.floor(equip_desc.genAttPL/100)
	t_numerial_pl.phy_att	= equip_desc.phyAttPL/100 --math.floor(equip_desc.phyAttPL/100)
	t_numerial_pl.magic_att	= equip_desc.magAttPL/100 --math.floor(equip_desc.magAttPL/100)
	t_numerial_pl.phy_def	= equip_desc.phyDefPL/100 --math.floor(equip_desc.phyDefPL/100)
	t_numerial_pl.magic_def	= equip_desc.magDefPL/100 --math.floor(equip_desc.magDefPL/100)

	t_equip_score = equip_desc.base_score



	return t_numerial, t_numerial_pl, t_equip_score
end

function getTop2NumeralByTmplID( tmpl_id )
	local tmpl_id = tonumber(tmpl_id)
	local t_numerial, t_numerial_pl, t_equip_score = getEquipNumerialByTmplID(tmpl_id)
	local f_data = 0
	local f_key  = nil
	local s_data = 0
	local s_key  = nil
	for key, t_num in pairs(t_numerial) do
		if(f_data == 0) then
			f_key  = key
			f_data = t_num
			-- print(f_key, f_data)
		elseif( t_num > f_data ) then
			s_key  = f_key
			s_data = f_data
			f_key  = key
			f_data = t_num
		elseif( t_num > s_data) then
			s_key  = key
			s_data = t_num
		end
	end

	local tmplData = {}
	local tmplData_PL = {}
	if (f_key) then
		tmplData[f_key] = f_data
		tmplData_PL[f_key] = t_numerial_pl[f_key]
	end
	if (s_key) then
		tmplData[s_key] = s_data
		tmplData_PL[s_key] = t_numerial_pl[s_key]
	end

	return tmplData, tmplData_PL, t_equip_score
end


-- 根据item_id 获取缓存信息 不带itemDesc字段
function getItemInfoByItemId( i_id )
	i_id = tonumber(i_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local item_info = nil
	for g_id, item_data in pairs(allBagInfo.arm) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end
	for g_id, item_data in pairs(allBagInfo.props) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end
	for g_id, item_data in pairs(allBagInfo.heroFrag) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end

	for g_id, item_data in pairs(allBagInfo.armFrag) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end

	for g_id, item_data in pairs(allBagInfo.treas) do
		if(i_id == tonumber(item_data.item_id)) then
			return item_data
		end
	end
	if( table.isEmpty(allBagInfo.fightSoul) == false )then
		for g_id, item_data in pairs(allBagInfo.fightSoul) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end
	if(table.isEmpty(allBagInfo.dress) == false)then
		for g_id, item_data in pairs(allBagInfo.dress) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	if( table.isEmpty(allBagInfo.petFrag) == false) then
		for g_id, item_data in pairs(allBagInfo.petFrag) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	if( table.isEmpty(allBagInfo.godWpFrag) == false ) then
		for g_id, item_data in pairs(allBagInfo.godWpFrag) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	if( table.isEmpty(allBagInfo.godWp) == false) then
		for g_id, item_data in pairs(allBagInfo.godWp) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	if( table.isEmpty(allBagInfo.rune) == false) then
		for g_id, item_data in pairs(allBagInfo.rune) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	if( table.isEmpty(allBagInfo.runeFrag) == false) then
		for g_id, item_data in pairs(allBagInfo.runeFrag) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	-- 锦囊
	if( table.isEmpty(allBagInfo.pocket) == false) then
		for g_id, item_data in pairs(allBagInfo.pocket) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	-- 兵符
	if( table.isEmpty(allBagInfo.tally) == false) then
		for g_id, item_data in pairs(allBagInfo.tally) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	-- 兵符碎片
	if( table.isEmpty(allBagInfo.tallyFrag) == false) then
		for g_id, item_data in pairs(allBagInfo.tallyFrag) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	-- 战车
	if( table.isEmpty(allBagInfo.chariotBag) == false) then
		for g_id, item_data in pairs(allBagInfo.chariotBag) do
			if(i_id == tonumber(item_data.item_id)) then
				return item_data
			end
		end
	end

	return nil
end

-- 通过itemid 获得背包里后端数据+db数据 带itemDesc字段
function getItemByItemId( p_itemId )
	-- print("p_itemId",p_itemId)
	local itemData = ItemUtil.getItemInfoByItemId(p_itemId)
	if( itemData ~= nil )then
		if( table.isEmpty(itemData.itemDesc) )then
			itemData.itemDesc = ItemUtil.getItemById(itemData.item_template_id)
		end
	end
	return itemData
end

-- 从hero身上获取装备xinxi
function getEquipInfoFromHeroByItemId( item_id )
	local equipInfo = nil
	local t_equips = HeroUtil.getEquipsOnHeros()

	if ( not table.isEmpty (t_equips)) then
		for t_item_id, t_equipInfo in pairs(t_equips) do
			if(tonumber(item_id) == tonumber(t_item_id)) then
				equipInfo = t_equipInfo
				break
			end
		end
	end

	return equipInfo
end

-- 从hero身上获取时装信息
function getFashionFromHeroByItemId( item_id )
	local fashionInfo = nil
	local t_fashions = HeroUtil.getFashionOnHeros()

	if ( not table.isEmpty (t_fashions)) then
		for t_item_id, t_fashionInfo in pairs(t_fashions) do
			if(tonumber(item_id) == tonumber(t_item_id)) then
				fashionInfo = t_fashionInfo
				break
			end
		end
	end
	return fashionInfo
end

-- 从hero身上获取宝物信息
function getTreasInfoFromHeroByItemId( item_id )
	local treasInfo = nil
	local t_treas = HeroUtil.getTreasOnHeros()

	if ( not table.isEmpty (t_treas)) then
		for t_item_id, t_treasInfo in pairs(t_treas) do
			if(tonumber(item_id) == tonumber(t_item_id)) then
				treasInfo = t_treasInfo
				break
			end
		end
	end

	return treasInfo
end

-- 从hero身上获取战魂信息
function getFightSoulInfoFromHeroByItemId( item_id )
	item_id = tonumber(item_id)
	local fightSoulInfo = nil
	local allFightSoul = HeroUtil.getAllFightSoulOnHeros()

	if ( not table.isEmpty (allFightSoul)) then
		for t_item_id, t_fightSoulInfo in pairs(allFightSoul) do
			if(item_id == tonumber(t_item_id)) then
				fightSoulInfo = t_fightSoulInfo
				break
			end
		end
	end

	return fightSoulInfo
end

-- 从hero身上获取战魂信息
function getPocketInfoFromHeroByItemId( item_id )
	item_id = tonumber(item_id)
	local pocketInfo = nil
	local allPocket = HeroUtil.getAllPocketOnHeros()

	if ( not table.isEmpty (allPocket)) then
		for t_item_id, t_pocketInfo in pairs(allPocket) do
			if(item_id == tonumber(t_item_id)) then
				pocketInfo = t_pocketInfo
				break
			end
		end
	end

	return pocketInfo
end

-- 从hero身上获取神兵信息
function getGodWeaponInfoFromHeroByItemId( item_id )
	item_id = tonumber(item_id)
	local godWeaPonInfo = nil
	local allGodWeaPon = HeroUtil.getAllGodWeaponOnHeros()

	if ( not table.isEmpty (allGodWeaPon)) then
		for t_item_id, t_godWeaPonInfo in pairs(allGodWeaPon) do
			if(item_id == tonumber(t_item_id)) then
				godWeaPonInfo = t_godWeaPonInfo
				break
			end
		end
	end

	return godWeaPonInfo
end

-- 从hero身上获取锦囊信息
function getPocketInfoFromHeroByItemId( item_id )
	item_id = tonumber(item_id)
	local pocketInfo = nil
	local allPocket = HeroUtil.getAllPocketOnHeros()

	if ( not table.isEmpty (allPocket)) then
		for t_item_id, t_pocketInfo in pairs(allPocket) do
			if(item_id == tonumber(t_item_id)) then
				pocketInfo = t_pocketInfo
				break
			end
		end
	end

	return pocketInfo
end

--[[
	@des 	: 从hero身上获取兵符信息
	@param 	: 
	@return : 
--]]
function getTallyInfoFromHeroByItemId( p_item_id )
	p_item_id = tonumber(p_item_id)
	local tallyInfo = nil
	local allTally = HeroUtil.getAllTallyOnHeros()

	if ( not table.isEmpty (allTally)) then
		for t_item_id, t_tallyInfo in pairs(allTally) do
			if(p_item_id == tonumber(t_item_id)) then
				tallyInfo = t_tallyInfo
				break
			end
		end
	end

	return tallyInfo
end

--[[
	@desc 	: 从装备的战车中获取战车信息
	@param 	: pItemId 战车的物品id
	@return : 战车信息
--]]
function getChariotInfoFormEquipedByItemId( pItemId )
	require "script/ui/chariot/ChariotMainData"
	local pos = ChariotMainData.getChariotPosByItemId(pItemId)
	local retData = nil
	if (pos > 0) then
		retData = ChariotMainData.getEquipChariotInfoByPos(pos)
	else
		print("getChariotInfoFormEquipedByItemId , it’s have not equip itemid =>",pItemId)
	end
	return retData
end

--[[
	@desc	背包里面是否有该物品
	@para 	item_template_id
	@return bool true/false <=> 有/无
--]]
function isItemInBagBy( item_tid )
	local r_cacheData = DataCache.getRemoteBagInfo()
	local tempData = {}
	local isHas = false
	if( not table.isEmpty(r_cacheData))then
		if( item_tid >= 100001 and item_tid <= 200000 ) then
			-- 装备
			tempData = r_cacheData.arm

		elseif(item_tid >= 400001 and item_tid <= 500000) then
			-- 武将碎片
			tempData = r_cacheData.heroFrag
		else
			-- 物品
			tempData = r_cacheData.props
		end
		if( not table.isEmpty(tempData))then
			for k, item_info in pairs(tempData) do
				if(tonumber(item_tid) == tonumber(item_info.item_template_id) ) then
					isHas = true
					break
				end
			end
		end
	end
	return isHas
end

-- 处理道具背包
function propBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.PROP_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Props)
		MainScene.changeLayer(bagLayer, "bagLayer")

	end
end


-- 道具背包是否已满
function isPropBagFull(isShowAlert,forwardDelegate)
	_forwardDelegate = forwardDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
	    if(not table.isEmpty(allBagInfo.props)) then
		    for k,v in pairs(allBagInfo.props) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.props)) then
			isFull = true
		end
	end

	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("key_3037")
		AlertTip.showAlert(tipText, propBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理装备背包
function equipBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.EQUIP_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Arming)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

-- 装备背包是否已满
function isEquipBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.arm)) then
		    for k,v in pairs(allBagInfo.arm) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.arm)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("key_1286")
		AlertTip.showAlert(tipText, equipBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理战魂背包
function fightSoulBagHandleFunc( isConfirm )
	if(isConfirm == true)then
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		require "script/ui/huntSoul/HuntSoulLayer"
		local layer = HuntSoulLayer.createHuntSoulLayer("fightSoulBag")
	    MainScene.changeLayer(layer,"HuntSoulLayer")
	end
end

-- 战魂背包是否已满
function isFightSoulBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.fightSoul)) then
		    for k,v in pairs(allBagInfo.fightSoul) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.fightSoul)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("key_2845")
		AlertTip.showAlert(tipText, fightSoulBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"),nil,false)
	end
    return isFull
end

-- 处理装备碎片背包
function equipFragBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.EQUIPFRAG_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_ArmFrag)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

-- 装备碎片背包是否已满
function isArmFragBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.armFrag)) then
		    for k,v in pairs(allBagInfo.armFrag) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.armFrag)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("key_1000")
		AlertTip.showAlert(tipText, equipFragBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理宝物背包
function treasBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.TREASURE_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Treas)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

-- 宝物背包是否已满
function isTreasBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.treas)) then
		    for k,v in pairs(allBagInfo.treas) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.treas)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("key_2854")
		AlertTip.showAlert(tipText, treasBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理时装背包
function fashionBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.DRESS_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Dress)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

-- 时装是否已满
function isFashionBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.dress)) then
		    for k,v in pairs(allBagInfo.dress) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.dress)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1442")
		AlertTip.showAlert(tipText, fashionBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理神兵背包
function godWeaponBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.GODWEAPON_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeapon)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

-- 神兵是否已满
function isGodWeaponBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.godWp)) then
		    for k,v in pairs(allBagInfo.godWp) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.godWp)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1440")
		AlertTip.showAlert(tipText, godWeaponBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理神兵碎片背包
function godWeaponFragBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.GODWEAPONFRAG_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_GodWeaponFrag)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

-- 神兵碎片是否已满
function isGodWeaponFragBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.godWpFrag)) then
		    for k,v in pairs(allBagInfo.godWpFrag) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.godWpFrag)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1441")
		AlertTip.showAlert(tipText, godWeaponFragBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理符印背包
function runeBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.RUNE_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Rune)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end
-- 符印背包是否已满
function isRuneBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.rune)) then
		    for k,v in pairs(allBagInfo.rune) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.rune)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1536")
		AlertTip.showAlert(tipText, runeBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理符印碎片背包
function runeFragBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.RUNEFRAG_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_RuneFrag)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end
-- 符印碎片背包是否已满
function isRuneFragBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.runeFrag)) then
		    for k,v in pairs(allBagInfo.runeFrag) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.runeFrag)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1537")
		AlertTip.showAlert(tipText, runeFragBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理锦囊背包
function pocketBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.POCKET_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_pocket)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end
-- 锦囊背包是否已满
function isPocketBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.pocket)) then
		    for k,v in pairs(allBagInfo.pocket) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.pocket)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1626")
		AlertTip.showAlert(tipText, pocketBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理兵符背包
function tallyBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.TALLY_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Tally)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end
-- 兵符背包是否已满
function isTallyBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.tally)) then
		    for k,v in pairs(allBagInfo.tally) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.tally)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1786")
		AlertTip.showAlert(tipText, tallyBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 处理兵符碎片背包
function tallyFragBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.TALLYFRAG_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_TallyFrag)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end
-- 兵符碎片背包是否已满
function isTallyFragBagFull(isShowAlert, forwordDelegate)
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.tallyFrag)) then
		    for k,v in pairs(allBagInfo.tallyFrag) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.tallyFrag)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lic_1787")
		AlertTip.showAlert(tipText, tallyFragBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

--[[
	@desc 	: 处理战车背包
	@param 	:
	@return : 
--]]
function chariotBagHandleFunc( isConfirm )
	require "script/ui/bag/BagLayer"
	if(isConfirm == true)then
		-- 弹扩充框
		require "script/ui/bag/BagEnlargeDialog"
		BagEnlargeDialog.showLayer(BagUtil.CHARIOT_TYPE, BagLayer.createItemNumbersSprite)
	else
		if type(_forwardDelegate) == "function" then
			_forwardDelegate()
		end
		local bagLayer = BagLayer.createLayer(BagLayer.Tag_Init_Chariot)
		MainScene.changeLayer(bagLayer, "bagLayer")
	end
end

--[[
	@desc 	: 战车背包是否已满
	@param 	:
	@return : 
--]]
function isChariotBagFull( isShowAlert, forwordDelegate )
	_forwardDelegate = forwordDelegate
	local isFull = false
	local allBagInfo = DataCache.getRemoteBagInfo()
    local m_number = 0

    -- 携带数
    if( not table.isEmpty(allBagInfo))then
    	-- 是否满了
		if(not table.isEmpty(allBagInfo.chariotBag)) then
		    for k,v in pairs(allBagInfo.chariotBag) do
		    	m_number = m_number + 1
		    end
		end
		if( m_number >= tonumber(allBagInfo.gridMaxNum.chariotBag)) then
			isFull = true
		end
	end
	if(isFull==true and isShowAlert==true)then
		local tipText = GetLocalizeStringBy("lgx_1080")
		AlertTip.showAlert(tipText, chariotBagHandleFunc, true, nil, GetLocalizeStringBy("key_2297"), GetLocalizeStringBy("key_1490"))
	end
    return isFull
end

-- 背包是否已满 return bool 满/没满 <=> true/false
function isBagFull(isShowAlert,callBack)
	local isFull = false
	isShowAlert = isShowAlert or true
	isFull = isPropBagFull(isShowAlert,callBack) or isEquipBagFull(isShowAlert,callBack) or isTreasBagFull(isShowAlert,callBack) or isArmFragBagFull(isShowAlert,callBack) or isFightSoulBagFull(isShowAlert,callBack) or isGodWeaponBagFull(isShowAlert,callBack) or isGodWeaponFragBagFull(isShowAlert,callBack)
	or isFashionBagFull(isShowAlert,callBack) or isRuneBagFull(isShowAlert,callBack) or isRuneFragBagFull(isShowAlert,callBack) or isPocketBagFull(isShowAlert,callBack) or isTallyBagFull(isShowAlert,callBack) or isTallyFragBagFull(isShowAlert,callBack) or isChariotBagFull(isShowAlert, callBack)
	if isFull then
		--关闭新手引导
		if NewGuide.guideClass ~= ksGuideClose then
			require "script/guide/NewGuide"
			require "script/guide/AstrologyGuide"
	        AstrologyGuide.cleanLayer()
	        NewGuide.guideClass = ksGuideClose
	        BTUtil:setGuideState(false)
	        NewGuide.saveGuideClass()
	    end
	end
	return isFull
end

-- 通过item_template_id 得到缓存匹配的第一条数据
function getCacheItemInfoBy( item_template_id )
	item_template_id = tonumber(item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local cacheItemInfo = nil
	if( not table.isEmpty(allBagInfo)) then
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					cacheItemInfo = item_info
					cacheItemInfo.gid = k
				end
			end
		end

		if(item_info==nil and not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					cacheItemInfo = item_info
					cacheItemInfo.gid = k
				end
			end
		end

		if(item_info==nil and not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					cacheItemInfo = item_info
					cacheItemInfo.gid = k
				end
			end
		end
	end

	return cacheItemInfo
end

-- 通过item_template_id 得到背包中物品的个数
function getCacheItemNumBy( item_template_id )
	item_template_id = tonumber(item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local item_num = 0
	if( not table.isEmpty(allBagInfo)) then
		-- 道具
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 装备
		if(item_num<=0 and not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 武将碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 宝物
		if(item_num<=0 and not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- add by licong
		-- 装备碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.armFrag)) then
			for k,item_info in pairs( allBagInfo.armFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 战魂
		if(item_num<=0 and not table.isEmpty( allBagInfo.fightSoul)) then
			for k,item_info in pairs( allBagInfo.fightSoul) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 时装
		if(item_num<=0 and not table.isEmpty( allBagInfo.dress)) then
			for k,item_info in pairs( allBagInfo.dress) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 宠物碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.petFrag)) then
			for k,item_info in pairs( allBagInfo.petFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 神兵
		if(item_num<=0 and not table.isEmpty( allBagInfo.godWp)) then
			for k,item_info in pairs( allBagInfo.godWp) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 神兵碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.godWpFrag)) then
			for k,item_info in pairs( allBagInfo.godWpFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 符印
		if(item_num<=0 and not table.isEmpty( allBagInfo.rune)) then
			for k,item_info in pairs( allBagInfo.rune) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 符印碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.runeFrag)) then
			for k,item_info in pairs( allBagInfo.runeFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 锦囊
		if(item_num<=0 and not table.isEmpty( allBagInfo.pocket)) then
			for k,item_info in pairs( allBagInfo.pocket) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 兵符
		if(item_num<=0 and not table.isEmpty( allBagInfo.tally)) then
			for k,item_info in pairs( allBagInfo.tally) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 兵符碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.tallyFrag)) then 
			for k,item_info in pairs( allBagInfo.tallyFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 战车
		if(item_num<=0 and not table.isEmpty( allBagInfo.chariotBag)) then 
			for k,item_info in pairs( allBagInfo.chariotBag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
	end

	return item_num
end

--[[
	@des  	: 得到消耗物品的itemid数组
	@param	: p_item_template_id 需要id，p_needNum需要数量
	@return : 符合条件itemId数组
--]]
function getCacheItemIdArrByNum( p_item_template_id, p_needNum )
	local item_template_id = tonumber(p_item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local find_num = 0
	local needNum = tonumber(p_needNum)
	local retItemIdArr = {}
	if( not table.isEmpty(allBagInfo)) then
		-- 道具
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					if( find_num >= needNum )then
						table.insert(retItemIdArr,item_info.item_id)
						break
					else
						table.insert(retItemIdArr,item_info.item_id)
					end
				end
			end
		end
	end
	return retItemIdArr
end

--[[
	@des  	: 得到特定p_item_template_id和数量的物品数组
	@param	: p_item_template_id 需要id，p_needNum需要数量
	@return : 符合条件物品数组
--]]
function getItemsByNum( p_item_template_id, p_needNum )
	local item_template_id = tonumber(p_item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local find_num = 0
	local needNum = tonumber(p_needNum)
	local retItems = {}
	if needNum <= 0 then
		return retItems
	end

	if( not table.isEmpty(allBagInfo)) then
		-- 道具
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end

		-- 装备
		if(find_num<=0 and not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 武将碎片
		if(find_num<=0 and not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 宝物
		if(find_num<=0 and not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end

		-- 装备碎片
		if(find_num<=0 and not table.isEmpty( allBagInfo.armFrag)) then
			for k,item_info in pairs( allBagInfo.armFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 战魂
		if(find_num<=0 and not table.isEmpty( allBagInfo.fightSoul)) then
			for k,item_info in pairs( allBagInfo.fightSoul) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 时装
		if(find_num<=0 and not table.isEmpty( allBagInfo.dress)) then
			for k,item_info in pairs( allBagInfo.dress) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 宠物碎片
		if(find_num<=0 and not table.isEmpty( allBagInfo.petFrag)) then
			for k,item_info in pairs( allBagInfo.petFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 神兵
		if(find_num<=0 and not table.isEmpty( allBagInfo.godWp)) then
			for k,item_info in pairs( allBagInfo.godWp) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 神兵碎片
		if(find_num<=0 and not table.isEmpty( allBagInfo.godWpFrag)) then
			for k,item_info in pairs( allBagInfo.godWpFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 符印
		if(find_num<=0 and not table.isEmpty( allBagInfo.rune)) then
			for k,item_info in pairs( allBagInfo.rune) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 符印碎片
		if(find_num<=0 and not table.isEmpty( allBagInfo.runeFrag)) then
			for k,item_info in pairs( allBagInfo.runeFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 锦囊
		if(find_num<=0 and not table.isEmpty( allBagInfo.pocket)) then
			for k,item_info in pairs( allBagInfo.pocket) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 兵符
		if(find_num<=0 and not table.isEmpty( allBagInfo.tally)) then
			for k,item_info in pairs( allBagInfo.tally) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 兵符碎片
		if(find_num<=0 and not table.isEmpty( allBagInfo.tallyFrag)) then 
			for k,item_info in pairs( allBagInfo.tallyFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
		-- 战车
		if(find_num<=0 and not table.isEmpty( allBagInfo.chariotBag)) then 
			for k,item_info in pairs( allBagInfo.chariotBag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					find_num = find_num + tonumber(item_info.item_num)
					table.insert(retItems,item_info)
					if( find_num >= needNum )then
						break
					end
				end
			end
		end
	end
	return retItems
end

-- 通过item_template_id得到神兵背包中进阶等级大于等于p_evolveLv的物品的个数，并返回进化等级最小的item_id如果没有则返回0
function getCacheGodNumByTidAndEvolveLv(item_template_id,p_evolveLv,p_itemId,p_itemTable)
	--local lowestNum = 999999
	local allBagInfo = DataCache.getRemoteBagInfo()
	local item_num = 0
	local findId = 0
	if(item_num<=0 and not table.isEmpty( allBagInfo.godWp)) then
		for k,item_info in pairs( allBagInfo.godWp) do
			if(tonumber(item_info.item_template_id) == tonumber(item_template_id)) then
				if tonumber(item_info.va_item_text.evolveNum) >= p_evolveLv and
					tonumber(item_info.item_id) ~= tonumber(p_itemId) and
					tonumber(item_info.va_item_text.reinForceLevel) == 0 and
					(item_info.va_item_text.lock == nil or tonumber(item_info.va_item_text.lock) ~= 1 )then

					local isAdd = true

					for i = 1,#p_itemTable do
						if tonumber(item_info.item_id) == tonumber(p_itemTable[i]) then
							isAdd = false
							break
						end
					end

					if isAdd then
						item_num = item_num + tonumber(item_info.item_num)
						findId = tonumber(item_info.item_id)
					end
				end
			end
		end
	end

	return item_num,findId
end

-- 通过item_template_id 得到背包中p_needLv级的物品的个数  默认寻找0级的
function getCacheItemNumByTidAndLv( item_template_id, p_needLv )
	item_template_id = tonumber(item_template_id)
	local allBagInfo = DataCache.getRemoteBagInfo()
	local item_num = 0
	local needItemLv = tonumber(p_needLv) or 0
	if( not table.isEmpty(allBagInfo)) then
		-- 道具
		if( not table.isEmpty( allBagInfo.props)) then
			for k,item_info in pairs( allBagInfo.props) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 装备
		if(item_num<=0 and not table.isEmpty( allBagInfo.arm)) then
			for k,item_info in pairs( allBagInfo.arm) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					if(needItemLv == tonumber(item_info.va_item_text.armReinforceLevel))then
						item_num = item_num + tonumber(item_info.item_num)
					end
				end
			end
		end
		-- 武将碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.heroFrag)) then
			for k,item_info in pairs( allBagInfo.heroFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 宝物
		if(item_num<=0 and not table.isEmpty( allBagInfo.treas)) then
			for k,item_info in pairs( allBagInfo.treas) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					if(needItemLv == tonumber(item_info.va_item_text.treasureLevel))then
						item_num = item_num + tonumber(item_info.item_num)
					end
				end
			end
		end
		-- add by licong
		-- 装备碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.armFrag)) then
			for k,item_info in pairs( allBagInfo.armFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end
		-- 战魂
		if(item_num<=0 and not table.isEmpty( allBagInfo.fightSoul)) then
			for k,item_info in pairs( allBagInfo.fightSoul) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					if(needItemLv == tonumber(item_info.va_item_text.fsLevel))then
						item_num = item_num + tonumber(item_info.item_num)
					end
				end
			end
		end
		-- 时装
		if(item_num<=0 and not table.isEmpty( allBagInfo.dress)) then
			for k,item_info in pairs( allBagInfo.dress) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					if(needItemLv == tonumber(item_info.va_item_text.dressLevel))then
						item_num = item_num + tonumber(item_info.item_num)
					end
				end
			end
		end
		-- 宠物碎片
		if(item_num<=0 and not table.isEmpty( allBagInfo.petFrag)) then
			for k,item_info in pairs( allBagInfo.petFrag) do
				if(tonumber(item_info.item_template_id) == item_template_id) then
					item_num = item_num + tonumber(item_info.item_num)
				end
			end
		end

	end

	return item_num
end

-- 获取装备评分 item_id
function getEquipScoreByItemId(item_id,isRed)
	local isRedCard = isRed or false
	local  item_id = tonumber(item_id)
	-- 获取装备数据
	local a_bagInfo = DataCache.getBagInfo()
	local equipData = nil
	for k,s_data in pairs(a_bagInfo.arm) do
		if( tonumber(s_data.item_id) == item_id ) then
			equipData = s_data
			break
		end
	end

	-- 如果为空则是武将身上的装备
	if(table.isEmpty(equipData))then
		equipData = getEquipInfoFromHeroByItemId(item_id)
		if( not table.isEmpty(equipData))then
			require "db/DB_Item_arm"
			equipData.itemDesc = DB_Item_arm.getDataById(equipData.item_template_id)

		end
	end

	local equip_desc = equipData.itemDesc
	local forceLevel = tonumber(equipData.va_item_text.armReinforceLevel)
	local t_equip_score = nil
	if(isRedCard==false)then
		t_equip_score = equip_desc.base_score + forceLevel* equip_desc.grow_score
	else
		t_equip_score = equip_desc.new_score + forceLevel* equip_desc.grow_score
	end
	return t_equip_score
end

-- 获取装备评分 item_template_id
function getEquipScoreByItemTmplId(item_template_id,isRed)
	local isRedCard = isRed or false
	require "db/DB_Item_arm"
	local equip_desc = DB_Item_arm.getDataById(item_template_id)
	if(isRedCard==false)then
		return equip_desc.base_score
	else
		return equip_desc.new_score
	end
end


-- 获取名将好感礼物
function getAllStarGifts()
	local allStarGifts = {}

	for gid, prop_info in pairs(DataCache.getRemoteBagInfo().props) do
		if( tonumber(prop_info.item_template_id) >= 40001 and tonumber(prop_info.item_template_id) <= 50000) then
			prop_info.gid = gid
			table.insert(allStarGifts, prop_info)
		end
	end

	return allStarGifts
end

-- 获取武将身上的装备 无gid
function getEquipsOnFormation()
	local formationInfo = DataCache.getFormationInfo()
	local equipsInfo_t = {}
	require "db/DB_Item_arm"
	if( not table.isEmpty(formationInfo))then
		for k,f_hid in pairs(formationInfo) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.arming)) ) then
					for p, equipInfo in pairs(f_hero.equip.arming) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = DB_Item_arm.getDataById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	table.sort( equipsInfo_t, BagUtil.equipSort )
	return equipsInfo_t
end

-- 获得上阵的宝物
function getTreasOnFormation()
	local formationInfo = DataCache.getFormationInfo()
	local equipsInfo_t = {}
	if( not table.isEmpty(formationInfo))then
		for k,f_hid in pairs(formationInfo) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.treasure)) ) then
					for p, equipInfo in pairs(f_hero.equip.treasure) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = ItemUtil.getItemById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	table.sort( equipsInfo_t, BagUtil.treasSort )
	return equipsInfo_t
end

-- 获得上阵的时装
function getDressOnFormation()
	local formationInfo = DataCache.getFormationInfo()
	local equipsInfo_t = {}
	if( not table.isEmpty(formationInfo))then
		for k,f_hid in pairs(formationInfo) do
			if(tonumber(f_hid)>0)then
				local f_hero = HeroModel.getHeroByHid(f_hid)
				if( (not table.isEmpty(f_hero)) and (not table.isEmpty(f_hero.equip.dress)) ) then
					for p, equipInfo in pairs(f_hero.equip.dress) do
						if( not table.isEmpty(equipInfo)) then
							equipInfo.itemDesc = ItemUtil.getItemById(equipInfo.item_template_id)
							equipInfo.itemDesc.desc = equipInfo.itemDesc.info
							equipInfo.equip_hid =  tonumber(f_hid)
							table.insert(equipsInfo_t, equipInfo)
						end
					end
				end
			end
		end
	end
	-- table.sort( equipsInfo_t, BagUtil.treasSort )
	return equipsInfo_t
end

-- 根据装备位置 筛选武将身上的装备 不查找的武将的hid
function getEquipsOnFormationByPos(equipPosition, d_hid)
	equipPosition = tonumber(equipPosition)
	local equipsInfo_t = getEquipsOnFormation()

	local p_equips = {}
	for k, equipInfo in pairs(equipsInfo_t) do
		if(d_hid and tonumber(equipInfo.equip_hid) == tonumber(d_hid) ) then

		elseif(tonumber(equipInfo.itemDesc.type) == equipPosition)then
			table.insert(p_equips, equipInfo)
		end
	end
	return p_equips
end

-- 根据装备位置 筛选武将身上的装备 不查找的武将的hid
function getTreasOnFormationByPos(equipPosition, d_hid)
	equipPosition = tonumber(equipPosition)
	local equipsInfo_t = getTreasOnFormation()

	local p_equips = {}
	for k, equipInfo in pairs(equipsInfo_t) do
		if(d_hid and tonumber(equipInfo.equip_hid) == tonumber(d_hid) ) then

		elseif(tonumber(equipInfo.itemDesc.type) == equipPosition)then
			table.insert(p_equips, equipInfo)
		end
	end
	return p_equips
end

-- 获得武将身上的战魂， hid的武将例外
function getFightSoulOnFormationExeptHid( e_hid )
	e_hid = tonumber(e_hid)
	local p_equips = {}

	local fightSoulOnHeros = HeroUtil.getAllFightSoulOnHeros()
	if( not table.isEmpty(fightSoulOnHeros))then
		for item_id, t_fightSoul in pairs(fightSoulOnHeros) do
			if( e_hid == tonumber(t_fightSoul.equip_hid) )then
			else
				table.insert(p_equips, t_fightSoul)
			end
		end
	end
	return p_equips
end

-- 获得武将身上的神兵， hid的武将例外
function getGodWeaponOnFormationExeptHid( e_hid )
	e_hid = tonumber(e_hid)
	local p_equips = {}

	local godWeaponOnHeros = HeroUtil.getAllGodWeaponOnHeros()
	if( not table.isEmpty(godWeaponOnHeros))then
		for item_id, t_god in pairs(godWeaponOnHeros) do
			if( e_hid == tonumber(t_god.equip_hid) )then
			else
				table.insert(p_equips, t_god)
			end
		end
	end
	return p_equips
end

-- 返回套装信息
function getSuitInfoByIds(item_template_id, hid)
	-- 获取装备数据
	require "db/DB_Item_arm"
	local equip_desc = DB_Item_arm.getDataById(item_template_id)

	if(equip_desc.jobLimit == nil )then
		return
	end

	-- 英雄身上的装备
	local equip_hero = {}
	if(hid and tonumber(hid)>0)then
		equip_hero = HeroUtil.getEquipsByHid(hid)
	end

	-- 获取套装数据
	require "db/DB_Suit"
	local suit_desc = DB_Suit.getDataById(equip_desc.jobLimit)
	-- 套装的各个装备
	local suit_equip_ids = string.split(string.gsub(suit_desc.suit_items, " ", ""), "," )

	-- 已有的套装装备
	local equips_ids_status = {}
	local had_count = 0
	for k, tmpl_id in pairs(suit_equip_ids) do
		equips_ids_status[tmpl_id] = false
		if(tonumber(tmpl_id) == tonumber(item_template_id))then
			equips_ids_status[tmpl_id] = true
			had_count = had_count + 1
		else
			for k,t_equipInfo in pairs(equip_hero) do
				if(tonumber(tmpl_id) == tonumber(t_equipInfo.item_template_id) )then
					equips_ids_status[tmpl_id] = true
					had_count = had_count + 1
					break
				end
			end
		end
	end

	-- 每级激活的套装属性
	local suit_attr_infos = {}
	for i=1,suit_desc.max_lock do
		local attr_info = {}
		attr_info.lock_num = tonumber(suit_desc["lock_num" .. i])
		attr_info.astAttr  = {}
		attr_info.hadUnlock = false
		-- 是否解锁
		if(attr_info.lock_num <= had_count)then
			attr_info.hadUnlock = true
		end

		-- 相应属性
		local astAttr_temp = string.split(string.gsub(suit_desc["astAttr" .. i], " ", ""), "," )
		for k,temp_str in pairs(astAttr_temp) do
			local t_arr = string.split(temp_str, "|" )
			attr_info.astAttr[t_arr[1] .. ""] = t_arr[2]
		end
		table.insert(suit_attr_infos, attr_info)
	end

	local suit_name = suit_desc.name

	return equips_ids_status, suit_attr_infos, suit_name
end


--[[ by licong
	@des 	:得到英雄身上已有的套装id, 套装激活的信息
	@param 	:hid
	@return :table{ suit_id套装id={ suit_id=num套装id,had_count=num套装激活的件数, suit_attr_infos=table激活属性, suit_name=string套装名字, isShow=是否激活了} }
--]]
function getSuitActivateNumByHid( hid )
	-- 英雄身上的装备
	local equip_hero = {}
	if(hid and tonumber(hid)>0)then
		equip_hero = HeroUtil.getEquipsByHid(hid)
	end
	local suitNumTab = {}
	for k,t_equipInfo in pairs(equip_hero) do
		-- print("t_equipInfo")
		-- print_t(t_equipInfo)
		if(t_equipInfo.item_template_id ~= nil)then
			-- 获取装备数据
			require "db/DB_Item_arm"
			local equip_desc = DB_Item_arm.getDataById(t_equipInfo.item_template_id)
			if(equip_desc.jobLimit ~= nil )then
				if(suitNumTab[tonumber(equip_desc.jobLimit)] == nil)then
					suitNumTab[tonumber(equip_desc.jobLimit)] = 1
				else
					suitNumTab[tonumber(equip_desc.jobLimit)] = suitNumTab[tonumber(equip_desc.jobLimit)] + 1
				end
			end
		end
	end
	-- 返回拥有的套装属性信息
	local retSuitTab = {}
	for s_id,s_num in pairs(suitNumTab) do
		local infoTab = {}
		infoTab.suit_attr_infos = {}
		-- 获取套装数据
		require "db/DB_Suit"
		local suit_desc = DB_Suit.getDataById(s_id)
		-- 每级激活的套装属性
		infoTab.isShow = false
		for i=1,suit_desc.max_lock do
			local attr_info = {}
			attr_info.lock_num = tonumber(suit_desc["lock_num" .. i])
			attr_info.astAttr  = {}
			-- 激活
			if(attr_info.lock_num <= s_num)then
				infoTab.isShow = true
				-- 相应属性
				local astAttr_temp = string.split(string.gsub(suit_desc["astAttr" .. i], " ", ""), "," )
				for k,temp_str in pairs(astAttr_temp) do
					local t_arr = string.split(temp_str, "|" )
					attr_info.astAttr[t_arr[1] .. ""] = t_arr[2]
				end
				infoTab.suit_attr_infos = attr_info
			else
				break
			end
		end
		infoTab.suit_name = suit_desc.name
		infoTab.had_count = s_num
		infoTab.suit_id = s_id
		retSuitTab[s_id] = infoTab
	end
	return retSuitTab
end

-- 得到激活红装进阶套装属性
function getEquipDevelopActivateInfoByHid( hid )
	local activateInfo = nil
	-- 英雄身上的装备
	local equip_hero = {}
	if(hid and tonumber(hid)>0)then
		equip_hero = HeroUtil.getEquipsByHid(hid)
	end
	local sameDevelopLevel = nil
	for k,t_equipInfo in pairs(equip_hero) do
		if t_equipInfo.va_item_text == nil then
			sameDevelopLevel = 0
			break
		end
		local tempDevelopLevel = tonumber(t_equipInfo.va_item_text.armDevelop) or 0
		if sameDevelopLevel == nil then
			sameDevelopLevel = tempDevelopLevel
		elseif tempDevelopLevel < sameDevelopLevel then
			sameDevelopLevel = tempDevelopLevel
		end
	end
	if sameDevelopLevel > 0 then
		activateInfo = {}
		activateInfo.developLevel = sameDevelopLevel
		activateInfo.affixInfo = EquipAffixModel.getDevelopSuitAffixByHid(hid)
	end
	return activateInfo
end

-- 装备变化
-- 计算属性变化的值
function showAttrChangeInfo(t_numerial_last, t_numerial_cur, p_flyTextCallBack,p_isReturn)
	print("t_numerial_last")
	print_t(t_numerial_last)
	print("t_numerial_cur")
	print_t(t_numerial_cur)
	if(table.isEmpty(t_numerial_cur))then
		t_numerial_cur = {}
	end
	local numerial_result = {}
	if(table.isEmpty(t_numerial_last))then
		numerial_result = t_numerial_cur
	else
		for c_k,cur_num in pairs(t_numerial_cur) do
			if(t_numerial_last[c_k] and tonumber(t_numerial_last[c_k]) >0 )then
				numerial_result[c_k] = tonumber(t_numerial_cur[c_k]) -tonumber(t_numerial_last[c_k])
				t_numerial_last[c_k] = 0
			else
				numerial_result[c_k] = tonumber(t_numerial_cur[c_k])
			end
		end
		for l_k, l_num in pairs(t_numerial_last) do
			if(tonumber(l_num)>0)then
				numerial_result[l_k] = -tonumber(l_num)
			end
		end
	end
	local t_text = {}
	for key,v_num in pairs(numerial_result) do
		if(v_num~=0) then
			local strName = ""
			if (key == "hp") then
				strName = GetLocalizeStringBy("key_1765")
			elseif (key == "gen_att") then
				strName = GetLocalizeStringBy("key_2980")
			elseif(key == "phy_att"  )then
				strName = GetLocalizeStringBy("key_2958")
			elseif(key == "magic_att")then
				strName = GetLocalizeStringBy("key_1536")
			elseif(key == "phy_def"  )then
				strName = GetLocalizeStringBy("key_1588")
			elseif(key == "magic_def")then
				strName = GetLocalizeStringBy("key_3133")
			end
			local o_text = {}
			o_text.txt = strName
			o_text.num = v_num
			table.insert(t_text, o_text)
		end
	end
	--如果要返回
	if p_isReturn ~= nil then
		return t_text
	end

	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text,p_flyTextCallBack)

end

function showFightSoulAttrChangeInfo( last_attr, cur_attr, p_isSub )
	-- print("showFightSoulAttrChangeInfo")
	-- print_t(last_attr)
	-- print_t(cur_attr)
	local t_text = {}
	for l_attid, l_data in pairs(last_attr) do
		local addNum = 0
	 	for c_attid, c_data in pairs(cur_attr) do
	 		if( tonumber(l_attid) == tonumber(c_attid) )then
	 			addNum = tonumber(c_data.realNum)
	 			cur_attr[c_attid] = nil
	 			break
	 		end
	 	end
	 	local o_text = {}
		o_text.txt = l_data.desc.displayName
		o_text.num = addNum - tonumber(l_data.realNum)
		o_text.displayNumType = l_data.desc.type
		if(o_text.num>0 or p_isSub == true)then
			table.insert(t_text, o_text)
		end
	end
	for c_attid,c_data in pairs(cur_attr) do
		local o_text = {}
		o_text.txt = c_data.desc.displayName
		o_text.num = c_data.realNum
		o_text.displayNumType = c_data.desc.type
		table.insert(t_text, o_text)
	end

	require "script/utils/LevelUpUtil"
	LevelUpUtil.showFlyText(t_text)
end

-- 宝物的基本属性
function getTreasAttrByTmplId( tmpl_id )
	local treasInfo = getItemById(tmpl_id)

	-- 属性信息
	local attr_arr 	= {}
	for i=1,5 do
		local str_info = treasInfo["base_attr"..i]
		if(str_info ~= nil)then
			local tempArr = string.split(str_info, "|")
			local tempArr_pl = string.split(treasInfo["increase_attr"..i], "|")

			local attr_e 	= {}
			attr_e.attId 	= tonumber(tempArr[1])
			attr_e.base 	= tonumber(tempArr[2])
			attr_e.num 		= tonumber(tempArr[2])
			attr_e.pl 		= tonumber(tempArr_pl[2])
			table.insert(attr_arr, attr_e)
		end
	end

	-- 评分
	local score_t = {}
	score_t.base = treasInfo.base_score
	score_t.num  = treasInfo.base_score
	score_t.pl   = treasInfo.increase_score

	-- 解锁属性
	local ext_active = {}
	local active_arr_1 = string.split(treasInfo.ext_active_arr, ",")
	for k, str_act in pairs(active_arr_1) do
		local temp_act_arr = string.split(str_act, "|")
		local t_ext_active = {}
		t_ext_active.openLv = tonumber(temp_act_arr[1])
		t_ext_active.attId 	= tonumber(temp_act_arr[2])
		t_ext_active.num = tonumber(temp_act_arr[3])
		t_ext_active.needDevelopLv 	= 0
		t_ext_active.isOpen = false
		table.insert(ext_active, t_ext_active)
	end

	--橙色宝物解锁属性
	local developExtActives = string.split(treasInfo.extra_active_affix, ",")
	for k,v in pairs(developExtActives) do
		local temp_act_arr = string.split(v, "|")
		local t_ext_active = {}
		t_ext_active.openLv 		= tonumber(temp_act_arr[1])
		t_ext_active.needDevelopLv 	= tonumber(temp_act_arr[2])
		t_ext_active.attId 			= tonumber(temp_act_arr[3])
		t_ext_active.num 			= tonumber(temp_act_arr[4])
		t_ext_active.isOpen 		= false
		table.insert(ext_active, t_ext_active)
	end

	--红色宝物解锁属性
	local developExtActives2 = string.split(treasInfo.extra_active_affix2, ",")
	for k,v in pairs(developExtActives2) do
		local temp_act_arr = string.split(v, "|")
		local t_ext_active = {}
		t_ext_active.openLv 		= tonumber(temp_act_arr[1])
		t_ext_active.needDevelopLv 	= tonumber(temp_act_arr[2])+6
		t_ext_active.attId 			= tonumber(temp_act_arr[3])
		t_ext_active.num 			= tonumber(temp_act_arr[4])
		t_ext_active.isOpen 		= false
		table.insert(ext_active, t_ext_active)
	end

	local enhanceLv = 0

	return attr_arr, score_t, ext_active, enhanceLv, treasInfo
end

-- 宝物的属性
function getTreasAttrByItemId( p_item_id, p_treasData )
	local item_id = tonumber(p_item_id)
	-- 获取宝物数据
	local retTreasData = nil
	if( table.isEmpty(p_treasData) )then
		retTreasData = getItemByItemId(p_item_id)
		if(retTreasData == nil)then
			retTreasData = getTreasInfoFromHeroByItemId(item_id)
		end
	else
		retTreasData = p_treasData
	end

	if( not table.isEmpty(retTreasData))then
		retTreasData.itemDesc = getItemById(retTreasData.item_template_id)
	end

	local attr_arr, score_t, ext_active = getTreasAttrByTmplId(retTreasData.item_template_id)
	local enhanceLv = tonumber(retTreasData.va_item_text.treasureLevel)
	if(enhanceLv and enhanceLv>0)then
		-- 计算属性信息
		for key, v in pairs(attr_arr) do
			attr_arr[key].num = v.base + v.pl * enhanceLv
		end
		-- 计算解锁属性
		for k,v in pairs(ext_active) do
			if(enhanceLv >= v.openLv)then
				if(v.needDevelopLv)then
					print("retTreasData.va_item_text.treasureDevelop====",retTreasData.va_item_text.treasureDevelop)
					print("v.needDevelopLv====",v.needDevelopLv)
					if( retTreasData.va_item_text and retTreasData.va_item_text.treasureDevelop ~= nil and tonumber(retTreasData.va_item_text.treasureDevelop) >= v.needDevelopLv )then
						ext_active[k].isOpen = true
					end
				else
					ext_active[k].isOpen = true
				end
			end
		end
	end

	-- 计算评分
	-- 橙色宝物重新计算评分
	if( retTreasData.va_item_text.treasureDevelop ~= nil and tonumber(retTreasData.va_item_text.treasureDevelop) > -1 and tonumber(retTreasData.va_item_text.treasureDevelop) <= 5)then
		score_t.base = tonumber(retTreasData.itemDesc.new_score)
	elseif( retTreasData.va_item_text and retTreasData.va_item_text.treasureDevelop ~= nil and tonumber(retTreasData.va_item_text.treasureDevelop) > 5 )then
		score_t.base = tonumber(retTreasData.itemDesc.new_score2)
	end
	score_t.num = score_t.base

	local newAttr = TreasAffixModel.getIncreaseAffixByInfo(retTreasData)
	for k_id,v_num in pairs(newAttr) do
		local isIn = false
		for i,attrInfo in pairs(attr_arr) do
			if( tonumber(k_id) == tonumber(attrInfo.attId) )then
				attr_arr[i].num = v_num
				isIn = true
			end
		end
		if( isIn == false )then
			local attr_e 	= {}
			attr_e.attId 	= tonumber(k_id)
			attr_e.base 	= 0
			attr_e.num 		= tonumber(v_num)
			attr_e.pl 		= 0
			table.insert(attr_arr, attr_e)
		end
	end

	return attr_arr, score_t, ext_active, enhanceLv, retTreasData
end

-- 物品属性的名称和数值的显示
function getAtrrNameAndNum( attrId, num )
	require "db/DB_Affix"
    local affixDesc = DB_Affix.getDataById(tonumber(attrId))
    num = tonumber(num)
    local realNum = num
    local displayNum = num
    if(affixDesc.type == 1)then
    	displayNum = num
    elseif(affixDesc.type == 2)then
		displayNum = num / 100
		if(displayNum > math.floor(displayNum))then
			displayNum = string.format("%.1f", displayNum)
		end
	elseif(affixDesc.type == 3)then
		displayNum = num / 100
		if(displayNum > math.floor(displayNum))then
			displayNum = string.format("%.1f", displayNum)
		end

		displayNum = displayNum .. "%"
    end

	return affixDesc, displayNum, realNum
end

-- 解析宝物字符串数组
function parseAttrStringToArr( attr_str )
	local parse_arr_1 = string.split(attr_str, ",")
	local parse_arr_2 = {}
	for k, sub_parse_str in pairs(parse_arr_1) do
		local sub_parse_arr = string.split(sub_parse_str, "|")
		table.insert(parse_arr_2, sub_parse_arr)
	end

	-- 排序
	local function keySort ( data_1, data_2 )
	   	return tonumber(data_1[1]) < tonumber(data_2[1])
	end
	table.sort( parse_arr_2, keySort )

	return parse_arr_2
end

-- 根据宝物的总经验 计算出宝物的当前等级、当前等级经验、当前等级升级所需总经验
function getTreasExpAndLevelInfo( item_template_id, totalExp )
	local tresInfo = getItemById(item_template_id)

	local parse_arr_2 = parseAttrStringToArr( tresInfo.total_upgrade_exp )

	local curLevel 			= 0 -- 当前等级
	local curLevelExp 		= 0 -- 当前等级经验
	local curLevelLimiteExp = 0 -- 当前等级经验上限

	local temp_exp_add = 0
	for k, exp_lv_arr in pairs(parse_arr_2) do
		temp_exp_add = temp_exp_add + exp_lv_arr[2]
		if(totalExp < temp_exp_add)then
			curLevel 			= tonumber(exp_lv_arr[1])
			curLevelLimiteExp 	= tonumber(exp_lv_arr[2])
			curLevelExp 		= curLevelLimiteExp - (tonumber(temp_exp_add) - totalExp)

			break
		elseif(totalExp == temp_exp_add)then
			curLevel 			= tonumber(exp_lv_arr[1]) + 1
			curLevelExp 		= 0
			curLevelLimiteExp 	= tonumber(parse_arr_2[k+1][2])
			break
		end
	end
	return curLevel, curLevelExp, curLevelLimiteExp
end

-- 计算某个等级 每单位经验所需要的 花费
function getSilverPerExpByLevel( item_template_id, level )
	level = tonumber(level)
	local tresInfo = getItemById(item_template_id)
	local sliverPer = 0
	local sliverPerExpArr = parseAttrStringToArr( tresInfo.upgrade_cost_arr )
	for k,v in pairs(sliverPerExpArr) do
		if(tonumber(v[1]) == level )then
			sliverPer = tonumber(v[2])
			break
		end
	end

	return sliverPer
end

-- 计算某个等级所需的全部经验
function getExpForLevelUp(item_template_id, level)
	local tresInfo = getItemById(item_template_id)
	local needExp = 0
	local parse_exp_arr = parseAttrStringToArr( tresInfo.total_upgrade_exp )
	for k,v in pairs(parse_exp_arr) do
		if(tonumber(v[1]) == level )then
			needExp = tonumber(v[2])
			break
		end
	end

	return needExp
end

-- 计算经验到从s_exp到e_exp需要的金币数
function getTreasCostToAddExp( item_template_id, s_exp, e_exp )
	-- print(" s_exp, e_exp===",  s_exp, e_exp)
	local slilverNum = 0
	local s_level, s_levelExp, s_levelLimiteExp = getTreasExpAndLevelInfo(item_template_id, s_exp)
	local e_level, e_levelExp, e_levelLimiteExp = getTreasExpAndLevelInfo(item_template_id, e_exp)

	if(s_level == e_level)then
		-- 没升级
		sliverNum = getSilverPerExpByLevel( item_template_id, s_level ) * (e_exp - s_exp)
	elseif(e_level-s_level == 1)then
		-- 只升了1级
		sliverNum = getSilverPerExpByLevel( item_template_id, s_level ) * (s_levelLimiteExp - s_levelExp)
		sliverNum = sliverNum + getSilverPerExpByLevel( item_template_id, e_level ) * e_levelExp
	elseif((e_level-s_level) >= 1)then
		-- 升了不止1级
		sliverNum = getSilverPerExpByLevel( item_template_id, s_level ) * (s_levelLimiteExp - s_levelExp)
		sliverNum = sliverNum + getSilverPerExpByLevel( item_template_id, e_level ) * e_levelExp

		for i_lv=s_level+1, e_level-1 do
			sliverNum = sliverNum + getExpForLevelUp(item_template_id, i_lv)*getSilverPerExpByLevel( item_template_id, i_lv )
		end
	end

	return sliverNum
end

-- 某个等级的基础经验
function getBaseExpBy( item_template_id, level )
	-- level = tonumber(level)
	local tresInfo = getItemById(item_template_id)
	-- local baseExp = 0

	-- local parse_exp_arr = parseAttrStringToArr( tresInfo.base_exp_arr )

	-- for k,v in pairs(parse_exp_arr) do

	-- 	if(tonumber(v[1]) == level )then
	-- 		baseExp = tonumber(v[2])
	-- 		break
	-- 	end
	-- end

	return tonumber(tresInfo.base_exp_arr)
end

--判断是否为经验金银书马
function isGoldOrSilverTreas(itemTid)
	local retData = false
	local tab = {501001,501002,502001,502002,503001,503002}
	for k,v in pairs(tab) do
		if( tonumber(itemTid) == v)then
			retData = true
		end
	end
	return retData
end

--added by zhang zihang
--通过itemTid和itemId判断是否是经验宝物或宝物精华
function isExpTreasById(itemTid,itemId)
	local tid = nil
	if( itemTid ~= nil)then
		tid = itemTid
	elseif(itemId ~= nil)then
		local a, b, c, d, treasData = getTreasAttrByItemId(itemId)
		tid = treasData.item_template_id
	else
		print("itemTid,itemId",itemTid,itemId)
	end
	local retData = false
	local tab = {501001,501002,502001,502002,503001,503002,501010}
	for k,v in pairs(tab) do
		if( tonumber(tid) == v)then
			retData = true
		end
	end
	return retData
end

-- 获取5个potential星级一下的宝物ids, (不包括 dup_arr 中的 item_id)
function getTreasIdsByCondition( potential, self_item_id, materialsArr, treas_type)
	potential = potential or 3
	materialsArr = materialsArr or {}
	local bagCache = DataCache.getBagInfo()
	local treas_cache = bagCache.treas

	if( not table.isEmpty(treas_cache) and #materialsArr<5)then

		for k,v in pairs(treas_cache) do
			-- 条件判断更改 by 张梓航
			-- 去除 白鹤 和 黑云
			if( (tonumber(treas_type) == tonumber(v.itemDesc.type)) and tonumber(v.item_template_id)~=501301 and tonumber(v.item_template_id)~=501302 and ((tonumber(v.itemDesc.quality) <= potential) or isGoldOrSilverTreas(v.item_template_id))) then
				local isInDupArr = false

				for k,material_v in pairs(materialsArr) do
					if(tonumber(v.item_id) == tonumber(material_v.item_id) )then
						isInDupArr = true
						break
					end
				end
				if(tonumber(v.item_id) == tonumber(self_item_id))then
					isInDupArr = true
				end
				if(isInDupArr == false)then
					local tab = {}
					local tempNum = 1
		    		if( tonumber(v.itemDesc.maxStacking) > 1 )then
		    			if( tonumber(v.item_num) >= 5)then
		    				tempNum = 5
		    			else
		    				tempNum = tonumber(v.item_num)
		    			end
					else
						tempNum = 1
					end
					tab.num = tempNum
					tab.item_id = v.item_id
					table.insert(materialsArr,tab)
					if(#materialsArr>=5)then
						break
					end
				end
			end
		end
	end
	return materialsArr
end

--- added by zhz
function getItemNameByItmTid( item_tid )

	local item_tmpl_id= tonumber(item_tid)
	local itemData = getItemById(item_tid)
	local itemName=  itemData.name
	if item_tmpl_id >= 80001 and item_tmpl_id < 90000 then

		local sex = UserModel.getUserSex()
		local itemInfo = DB_Item_dress.getDataById(item_tid)
		itemName= HeroUtil.getStringByFashionString(itemInfo.name, sex )
	end

	return itemName

end



-------------------------------------------------------------------------------------------------------
-- add by licong
-- 适用于显示奖励物品列表

--  分解表中物品字符串数据
function analyzeGoodsStr( goodsStr )
    if(goodsStr == nil)then
        return
    end
    local goodsData = {}
    local goodTab = string.split(goodsStr, ",")
    for k,v in pairs(goodTab) do
        local data = {}
        local tab = string.split(v, "|")
        data.type = tab[1]
        data.id   = tab[2]
        data.num  = tab[3]
        table.insert(goodsData,data)
    end
    -- print("~~~~~~~~~")
    -- print_t(goodsData)
    -- print("~~~~~~~~~")
    return goodsData
end

-- 数据解析 后端17类型奖励
function getServiceReward( p_serviceData )
	local dataTab = {}
	for k,v in pairs(p_serviceData) do
		local data = {}
		data.type = v[1]
        data.id   = v[2]
        data.num  = v[3]
        table.insert(dataTab,data)
	end
    local retTab = getItemsDataByStr(nil,dataTab)
	return retTab
end

-- 根据表配置得到展示物品的数据 奖励的17个类型
-- rewardDataStr 表配置奖励 1|0|1000
-- p_goodsData:解析后的数据{{type=1,id=0,num=1000},{},{}}
-- pIsNeedNum:是否查找自己所拥有的数量
function getItemsDataByStr( rewardDataStr, p_goodsData, pIsNeedNum )
    local goodsData = nil
	if(rewardDataStr ~= nil)then
		goodsData = analyzeGoodsStr(rewardDataStr)
	elseif(p_goodsData ~= nil)then
		goodsData = p_goodsData
	end
    -- print("--------------------")
    -- print_t(goodsData)
    if(goodsData == nil)then
        return
    end
    local itemData ={}
    for k,v in pairs(goodsData) do
        local tab = {}
        if( tonumber(v.type) == 1 ) then
            -- 银币
            tab.type = "silver"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name =  GetLocalizeStringBy("key_8042")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getSilverNumber()
            end
        elseif(tonumber(v.type) == 2 ) then
            -- 将魂
            tab.type = "soul"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_1086")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getSoulNum()
            end
       elseif(tonumber(v.type) == 3 ) then
            -- 金币
            tab.type = "gold"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_1447")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getGoldNumber()
            end
        elseif(tonumber(v.type) == 4 ) then
            -- 体力(wu)
            tab.type = "execution"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1299")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getEnergyValue()
            end
        elseif(tonumber(v.type) == 5 ) then
            -- 耐力(wu)
            tab.type = "stamina"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_2021")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getStaminaNumber()
            end
        elseif(tonumber(v.type) == 6 ) then
            -- 单个物品  类型6 类型id|物品数量默认1|物品id  以前约定特殊处理
            tab.type = "item"
            tab.num  = 1
            tab.tid  = tonumber(v.id)
            if(pIsNeedNum)then
            	tab.haveNum = getCacheItemNumBy(v.id)
            end
        elseif(tonumber(v.type) == 7 ) then
            -- 多个物品(wu)
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(pIsNeedNum)then
            	tab.haveNum = getCacheItemNumBy(v.id)
            end
        elseif(tonumber(v.type) == 8 ) then
            -- 等级*银币(wu)
            tab.type = "silver"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_8042")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getSilverNumber()
            end
        elseif(tonumber(v.type) == 9 ) then
            -- 等级*将魂(wu)
            tab.type = "soul"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_1086")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getSoulNum()
            end
        elseif(tonumber(v.type) == 10 ) then
            -- 单个英雄 类型10 类型id|物品数量默认1|英雄id  以前约定特殊处理(wu)
            tab.type = "hero"
            tab.num  = 1
            tab.tid  = tonumber(v.id)
            if(pIsNeedNum)then
            	tab.haveNum = HeroModel.getHeroNumberByHtid(v.id)
            end
        elseif(tonumber(v.type) == 11 ) then
            -- 魂玉
            tab.type = "jewel"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_1510")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getJewelNum()
            end
        elseif(tonumber(v.type) == 12 ) then
            -- 声望
            tab.type = "prestige"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name = GetLocalizeStringBy("key_2231")
            if(pIsNeedNum)then
            	tab.haveNum = UserModel.getPrestigeNum()
            end
        elseif(tonumber(v.type) == 13 ) then
            -- 多个英雄(wu)
            tab.type = "hero"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(pIsNeedNum)then
            	tab.haveNum = HeroModel.getHeroNumberByHtid(v.id)
            end
        elseif(tonumber(v.type) == 14 ) then
            -- 宝物碎片
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(pIsNeedNum)then
            	tab.haveNum = getCacheItemNumBy(v.id)
            end
        elseif(tonumber(v.type) == 15 ) then
	        -- 军团个人贡献
	        tab.type = "contri"
	        tab.num  = tonumber(v.num)
	        tab.tid  = tonumber(v.id)
	        tab.name = GetLocalizeStringBy("lic_1172")
	        if(pIsNeedNum)then
            	tab.haveNum = GuildDataCache.getSigleDoante()
            end
	    elseif(tonumber(v.type) == 16 ) then
	        -- 军团建设度
	        tab.type = "buildNum"
	        tab.num  = tonumber(v.num)
	        tab.tid  = tonumber(v.id)
	        tab.name = GetLocalizeStringBy("lic_1173")
	        if(pIsNeedNum)then
            	tab.haveNum = GuildDataCache.getGuildDonate()
            end
	    elseif(tonumber(v.type) == 17 ) then
	        -- 比武荣誉
	        tab.type = "honor"
	        tab.num  = tonumber(v.num)
	        tab.tid  = tonumber(v.id)
	        tab.name = GetLocalizeStringBy("fqq_002")
	        if(pIsNeedNum)then
            	tab.haveNum = UserModel.getHonorNum()
            end
	    elseif(tonumber(v.type) == 18 ) then
	    	--粮草
	    	tab.type = "grain"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lcyx_101")
	    	if(pIsNeedNum)then
            	tab.haveNum = GuildDataCache.getMyselfGrainNum()
            end
	    elseif(tonumber(v.type) == 19 ) then
	    	-- 神兵令
	    	tab.type = "coin"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lcyx_149")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
	    elseif(tonumber(v.type) == 20 ) then
	    	--战功
	    	tab.type = "zg"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lcyx_1819")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
	    elseif(tonumber(v.type) == 21 ) then
	    	-- 天工令
	    	tab.type = "tg_num"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lic_1561")
	    	if(pIsNeedNum)then
            	tab.haveNum = UserModel.getGodCardNum()
            end
	    elseif(tonumber(v.type) == 22 ) then
	    	--争霸令
	    	tab.type = "wm_num"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lcyx_1912")
	    	if(pIsNeedNum)then
            	tab.haveNum = UserModel.getWmNum()
            end
	    elseif(tonumber(v.type) == 23 ) then
	    	--炼狱令
	    	tab.type = "hellPoint"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lcyx_1917")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
	    elseif (tonumber(v.type) == 25) then
	    	-- 跨服荣誉 add by yangrui 15-10-13
	    	tab.type = "cross_honor"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("yr_2002")
	    	if(pIsNeedNum)then
            	tab.haveNum = UserModel.getCrossHonor()
            end
    	elseif (tonumber(v.type) == 26) then
    		-- 将星 add by shengyixian 15-12-07
	    	tab.type = "jh"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("syx_1053")
	    	if(pIsNeedNum)then
            	tab.haveNum = UserModel.getHeroJh()
            end
	    elseif (tonumber(v.type) == 27 ) then
       		-- 国战积分  add by shengyixian 15-12-07
       		tab.type = "copoint"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("fqq_015")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
	   	elseif (tonumber(v.type) == 28 ) then
       		-- 兵符积分  add by FQQ 16-01-08
       		tab.type = "tally_point"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("fqq_050")
	    	if(pIsNeedNum)then
            	tab.haveNum = UserModel.getTallyPointNumber()
            end
	    elseif (tonumber(v.type) == 29 ) then
       		-- 科技图纸
       		tab.type = "book_num"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lic_1812")
	    	if(pIsNeedNum)then
            	tab.haveNum = UserModel.getBookNum()
            end
        elseif (tonumber(v.type) == 30 ) then
       		-- 试炼币
       		tab.type = "tower_num"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lic_1845")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
        elseif (tonumber(v.type) == 31 ) then
       		-- 星魄
       		tab.type = "star_point"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lic_1844")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
        elseif (tonumber(v.type) == 32 ) then
       		-- 经验
       		tab.type = "exp_num"
	    	tab.num = tonumber(v.num)
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lic_1847")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
        elseif (tonumber(v.type) == 33 ) then
       		-- 经验*等级
       		tab.type = "exp_num"
	    	tab.num = tonumber(v.num) * UserModel.getHeroLevel()
	    	tab.tid = tonumber(v.id)
	    	tab.name = GetLocalizeStringBy("lic_1847")
	    	if(pIsNeedNum)then
            	tab.haveNum = 0
            end
	    else
            print("此类型不存在。。。",tonumber(v.type))
            -- return
        end
        -- 存入数组
        if(table.isEmpty(tab) == false) then
        	table.insert(itemData,tab)
        end
    end
    return  itemData
end

-- 根据表配置得到展示物品的数据 奖励的15个类型 专用军团任务
function getItemsDataByStrForTask( rewardDataStr )
    local goodsData = analyzeGoodsStr(rewardDataStr)
    -- print("--------------------")
    -- print_t(goodsData)
    if(goodsData == nil)then
        return
    end
    local itemData ={}
    for k,v in pairs(goodsData) do
        local tab = {}
        if( tonumber(v.type) == 1 ) then
            -- 银币
            tab.type = "silver"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name=  GetLocalizeStringBy("key_8042")
        elseif(tonumber(v.type) == 2 ) then
            -- 将魂
            tab.type = "soul"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1086")
       elseif(tonumber(v.type) == 3 ) then
            -- 金币
            tab.type = "gold"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1447")
        elseif(tonumber(v.type) == 4 ) then
            -- 体力(wu)
            tab.type = "execution"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1299")
        elseif(tonumber(v.type) == 5 ) then
            -- 耐力(wu)
            tab.type = "stamina"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_2021")
        elseif(tonumber(v.type) == 6 ) then
            -- 单个物品  类型6 类型id|物品数量默认1|物品id  以前约定特殊处理
            tab.type = "item"
            tab.num  = 1
            tab.tid  = tonumber(v.id)

        elseif(tonumber(v.type) == 7 ) then
            -- 多个物品(wu)
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)

        elseif(tonumber(v.type) == 8 ) then
            -- 等级*银币(wu)
            tab.type = "silver"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1189")
        elseif(tonumber(v.type) == 9 ) then
            -- 等级*将魂(wu)
            tab.type = "soul"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1469")
        elseif(tonumber(v.type) == 10 ) then
            -- 单个英雄 类型10 类型id|物品数量默认1|英雄id  以前约定特殊处理(wu)
            tab.type = "hero"
            tab.num  = 1
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 11 ) then
            -- 魂玉
            tab.type = "jewel"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_1510")
        elseif(tonumber(v.type) == 12 ) then
            -- 声望
            tab.type = "prestige"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            tab.name= GetLocalizeStringBy("key_2231")
        elseif(tonumber(v.type) == 13 ) then
            -- 多个英雄(wu)
            tab.type = "hero"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 14 ) then
            -- 宝物碎片
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)

        elseif(tonumber(v.type) == 15 ) then
	        -- 军团个人贡献
	        tab.type = "contri"
	        tab.num  = tonumber(v.num)
	        tab.tid  = tonumber(v.id)
	    else
            print("此类型不存在。。。",tonumber(v.type))
            -- return
        end
        -- 存入数组
        if(table.isEmpty(tab) == false) then
        	table.insert(itemData,tab)
        end
    end
    return  itemData
end


----建奖励node-------
function getRewardNode( rewardDataStr )
	-- body
	local goodsData = getItemsDataByStr(rewardDataStr)
	local node      = CCSprite:create()
	local sprite    = nil
	local label     = nil
	local numLabel  = nil
	-- printTable("rewardDataStr", rewardDataStr)
	if(tostring(goodsData[1].type) == "silver") then  -- modified by yangrui at 2015-12-03
		-- 银币
		sprite   = CCSprite:create("images/common/coin.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1687"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
	elseif(tostring(goodsData[1].type) == "soul") then
		-- 将魂
		sprite 	 = CCSprite:create("images/base/props/jianghun.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1616"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif(tostring(goodsData[1].type) == "gold") then
		-- 金币
		sprite   = CCSprite:create("images/base/props/jinbi_xiao.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1491"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif(tostring(goodsData[1].type) == "item") then
		-- 物品
		sprite   = CCSprite:create("images/base/props/jinbi_xiao.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1687"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif(tostring(goodsData[1].type) == "hero") then
		-- 英雄
		sprite   = CCSprite:create("images/base/props/jinbi_xiao.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1687"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif(tostring(goodsData[1].type) == "prestige") then
		-- 声望
		sprite   = CCSprite:create("images/base/props/shengwang.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_2231"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    elseif(tostring(goodsData[1].type) == "jewel") then
		-- 魂玉
		sprite   = CCSprite:create("images/base/props/hunyu.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1510"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    elseif(tostring(goodsData[1].type) == "execution") then
		-- 体力
		sprite   = CCSprite:create("images/base/props/tili_xiao.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_1032"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    elseif(tostring(goodsData[1].type) == "stamina") then
		-- 耐力
		sprite   = CCSprite:create("images/base/props/naili_xiao.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("key_2021"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif(tostring(goodsData[1].type) == "contri") then
		-- 个人贡献
		sprite   = CCSprite:create("images/battlemission/gong.png")
		label    = CCRenderLabel:create(GetLocalizeStringBy("llp_35"),g_sFontName,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
		numLabel = CCRenderLabel:create(goodsData[1].num,g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	elseif(tostring(goodsData[1].type) == "haveno") then
		return nil
	end
	node:addChild(sprite)
	node:addChild(label)
	node:addChild(numLabel)
	sprite:setAnchorPoint(ccp(0,0))
	label:setAnchorPoint(ccp(0,0))
	numLabel:setAnchorPoint(ccp(0,0))
	if(tostring(goodsData[1].type) ~= "contri" and tostring(goodsData[1].type) ~= "silver")then
		sprite:setScale(0.4)
	end
	numLabel:setColor(ccc3(0xfe,0xdb,0x1c))
	sprite:setPosition(ccp(0,0))
	if(tostring(goodsData[1].type) ~= "contri" and tostring(goodsData[1].type) ~= "silver")then
		label:setPosition(ccp(sprite:getContentSize().width*0.4,0))
		numLabel:setPosition(ccp(sprite:getContentSize().width*0.4+label:getContentSize().width,0))
		node:setContentSize(CCSizeMake(sprite:getContentSize().width*0.4+label:getContentSize().width+numLabel:getContentSize().width,sprite:getContentSize().height))
	else
		label:setPosition(ccp(sprite:getContentSize().width,0))
		numLabel:setPosition(ccp(sprite:getContentSize().width+label:getContentSize().width,0))
		node:setContentSize(CCSizeMake(sprite:getContentSize().width+label:getContentSize().width+numLabel:getContentSize().width,sprite:getContentSize().height))
	end
	return node
end

--------------------

----
function getNodeByStr( rewardDataStr , isBigMapCpy)
	_isBigMap = isBigMapCpy
    local goodsData = analyzeGoodsStr(rewardDataStr)
    -- print("--------------------")
    -- print_t(goodsData)
    if(goodsData == nil)then
        return
    end
    local itemData ={}
    for k,v in pairs(goodsData) do
        local tab = {}
        if( tonumber(v.type) == 1 ) then
            -- 银币
            tab.type = "silver"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then
            	_isBigMap = false
            	local bgNode = CCSprite:create()--
            	local iconSprite = CCSprite:create(BG_PATH.."coin.png")
            	iconSprite:setAnchorPoint(ccp(1,0.5))
            	bgNode:addChild(iconSprite)
            	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	local big = 0
            	local small = 0
            	local numLabel = nil
            	if(tab.num>=10000)then
            		big,small = math.modf(tab.num/10000)
            		if(small~=0)then
            			numLabel = CCRenderLabel:create(big.."."..small..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		else
            			numLabel = CCRenderLabel:create(big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		end
            	else
            		numLabel = CCRenderLabel:create(tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            	end

            	numLabel:setAnchorPoint(ccp(0,0.5))
            	iconSprite:addChild(numLabel)
            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            	bgNode:setAnchorPoint(ccp(0.5,0.5))
            	return bgNode
            end
        elseif(tonumber(v.type) == 2 ) then
            -- 将魂
            tab.type = "soul"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then
            	_isBigMap = false
            	local bgNode = CCSprite:create()
            	local iconSprite = CCSprite:create(BG_PATH.."icon_soul.png")
            	iconSprite:setAnchorPoint(ccp(1,0.5))
            	bgNode:addChild(iconSprite)
            	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	local numLabel = nil
            	if(tab.num>=10000)then
            		big,small = math.modf(tab.num/10000)
            		if(small~=0)then
            			numLabel = CCRenderLabel:create(big.."."..small..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		else
            			numLabel = CCRenderLabel:create(big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		end
            	else
            		numLabel = CCRenderLabel:create(tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            	end
            	numLabel:setAnchorPoint(ccp(0,0.5))
            	iconSprite:addChild(numLabel)
            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            	bgNode:setAnchorPoint(ccp(0.5,0.5))
            	return bgNode
            end
       elseif(tonumber(v.type) == 3 ) then
            -- 金币
            tab.type = "gold"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then
            	_isBigMap = false
            	local bgNode = CCSprite:create()
            	local iconSprite = CCSprite:create(BG_PATH.."gold.png")
            	iconSprite:setAnchorPoint(ccp(1,0.5))
            	bgNode:addChild(iconSprite)
            	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	local numLabel = nil
            	if(tab.num>=10000)then
            		big,small = math.modf(tab.num/10000)
            		if(small~=0)then
            			numLabel = CCRenderLabel:create(big.."."..small..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		else
            			numLabel = CCRenderLabel:create(big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		end
            	else
            		numLabel = CCRenderLabel:create(tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            	end
            	numLabel:setAnchorPoint(ccp(0,0.5))
            	iconSprite:addChild(numLabel)
            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            	bgNode:setAnchorPoint(ccp(0.5,0.5))
            	return bgNode
            end
        elseif(tonumber(v.type) == 4 ) then
            -- 体力(wu)
            tab.type = "execution"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 5 ) then
            -- 耐力(wu)
            tab.type = "stamina"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 6 ) then
            -- 单个物品  类型6 类型id|物品数量默认1|物品id  以前约定特殊处理
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 7 ) then
            -- 多个物品(wu)
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then
            	if(tonumber(tab.tid) == 60002 or tonumber(tab.tid) == 60014 or tonumber(tab.tid) == 10042 or
            		tonumber(tab.tid) == 30003 or tonumber(tab.tid) == 50403 or tonumber(tab.tid) == 60013 or
            		 tonumber(tab.tid) == 60001 or tonumber(tab.tid) == 30103 or
            		 tonumber(tab.tid) == 30021 or tonumber(tab.tid) == 30022 or tonumber(tab.tid) == 72002 or
            		 tonumber(tab.tid) == 60016 or tonumber(tab.tid) == 60007 or tonumber(tab.tid) == 30102 or
            		 tonumber(tab.tid) == 30803 or tonumber(tab.tid) == 30701 or tonumber(tab.tid) == 60019)then
	            	_isBigMap = false
	            	local bgNode = CCSprite:create()--
	            	local iconSprite = nil
	            	if(tonumber(tab.tid) == 60002)then
	            		iconSprite = CCSprite:create("images/arena/item_icon.png")
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 60014)then
	            		iconSprite = CCSprite:create("images/base/props/qianggongqi.png")
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 60019)then
	            		iconSprite = CCSprite:create("images/base/props/improveStone.png")
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 10042)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_19"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30003)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_14"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 50403)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_15"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 60013)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_16"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 60001)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_17"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30103)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_18"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30021)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_21"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30022)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_22"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 72002)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_23"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 60016)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_24"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 60007)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_25"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30102)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_26"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30803)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_98"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	elseif(tonumber(tab.tid) == 30701)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_99"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            		iconSprite:setAnchorPoint(ccp(1,0.5))
	            		bgNode:addChild(iconSprite)
	            		iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	end

	            	local numLabel = nil
	            	if(tab.num>=10000)then
	            		big,small = math.modf(tab.num/10000)
	            		numLabel = CCRenderLabel:create(" "..big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            	else
	            		numLabel = CCRenderLabel:create(" "..tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            	end
	            	-- numLabel:setScale(2)
	            	numLabel:setAnchorPoint(ccp(0,0.5))
	            	iconSprite:addChild(numLabel)
	            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            		bgNode:setAnchorPoint(ccp(0.5,0.5))
	            	return bgNode
	            end

            end
        elseif(tonumber(v.type) == 8 ) then
            -- 等级*银币(wu)
            tab.type = "silver"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 9 ) then
            -- 等级*将魂(wu)
            tab.type = "soul"
            tab.num  = tonumber(v.num) * UserModel.getHeroLevel()
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 10 ) then
            -- 单个英雄 类型10 类型id|物品数量默认1|英雄id  以前约定特殊处理(wu)
            tab.type = "hero"
            tab.num  = 1
            tab.tid  = tonumber(v.num)
        elseif(tonumber(v.type) == 11 ) then
            -- 魂玉
            tab.type = "jewel"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then

            	_isBigMap = false
            	local bgNode = CCSprite:create()--
            	local iconSprite = CCSprite:create("images/common/jewel_small.png")
            	iconSprite:setAnchorPoint(ccp(1,0.5))
            	bgNode:addChild(iconSprite)
            	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	local numLabel = nil
            	if(tab.num>=10000)then
            		big,small = math.modf(tab.num/10000)
            		if(small~=0)then
            			numLabel = CCRenderLabel:create(big.."."..small..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		else
            			numLabel = CCRenderLabel:create(big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		end
            	else
            		numLabel = CCRenderLabel:create(tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            	end
            	numLabel:setAnchorPoint(ccp(0,0.5))
            	iconSprite:addChild(numLabel)
            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            	bgNode:setAnchorPoint(ccp(0.5,0.5))
            	return bgNode

            end
        elseif(tonumber(v.type) == 12 ) then
            -- 声望
            tab.type = "prestige"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then
            	_isBigMap = false
            	local bgNode = CCSprite:create()--
            	local iconSprite = CCSprite:create("images/common/prestige.png")
            	iconSprite:setAnchorPoint(ccp(1,0.5))
            	bgNode:addChild(iconSprite)
            	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	local numLabel = nil
            	if(tab.num>=10000)then
            		big,small = math.modf(tab.num/10000)
            		if(small~=0)then
            			numLabel = CCRenderLabel:create(big.."."..small..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		else
            			numLabel = CCRenderLabel:create(big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            		end
            	else
            		numLabel = CCRenderLabel:create(tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
            	end
            	numLabel:setAnchorPoint(ccp(0,0.5))
            	iconSprite:addChild(numLabel)
            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            	bgNode:setAnchorPoint(ccp(0.5,0.5))
            	return bgNode
            end
        elseif(tonumber(v.type) == 13 ) then
            -- 多个英雄(wu)
            tab.type = "hero"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            if(_isBigMap == true)then
            	if(tonumber(tab.tid) == 40001)then
	            	_isBigMap = false
	            	local bgNode = CCSprite:create()--
	            	local iconSprite = nil
	            	if(tonumber(tab.tid) == 40001)then
	            		iconSprite = CCRenderLabel:create(GetLocalizeStringBy("llp_20"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            	end

	            	iconSprite:setAnchorPoint(ccp(1,0.5))
	            	bgNode:addChild(iconSprite)
	            	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	local numLabel = nil
	            	if(tab.num>=10000)then
	            		big,small = math.modf(tab.num/10000)
	            		numLabel = CCRenderLabel:create(" "..big..GetLocalizeStringBy("key_2593"),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            	else
	            		numLabel = CCRenderLabel:create(" "..tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
	            	end
	            	-- numLabel:setScale(2)
	            	numLabel:setAnchorPoint(ccp(0,0.5))
	            	iconSprite:addChild(numLabel)
	            	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
	            	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
            		bgNode:setAnchorPoint(ccp(0.5,0.5))
	            	return bgNode
	            end
	        end
        elseif(tonumber(v.type) == 14 ) then
            -- 多个物品(wu)
            tab.type = "item"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
        elseif(tonumber(v.type) == 17 ) then
            -- 荣誉
            tab.type = "honor"
            tab.num  = tonumber(v.num)
            tab.tid  = tonumber(v.id)
            local bgNode = CCSprite:create()--
        	local iconSprite = CCSprite:create("images/common/s_honor.png")
        	iconSprite:setAnchorPoint(ccp(1,0.5))
        	bgNode:addChild(iconSprite)
        	iconSprite:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
        	local numLabel = nil

        	numLabel = CCRenderLabel:create(tostring(tab.num),g_sFontPangWa,18,1, ccc3( 0x00, 0x00, 0x00), type_stroke)
        	-- end
        	numLabel:setAnchorPoint(ccp(0,0.5))
        	iconSprite:addChild(numLabel)
        	numLabel:setPosition(ccp(iconSprite:getContentSize().width,iconSprite:getContentSize().height*0.5))
        	bgNode:setContentSize(CCSizeMake(iconSprite:getContentSize().width+numLabel:getContentSize().width,iconSprite:getContentSize().height))
        	bgNode:setAnchorPoint(ccp(0.5,0.5))
        	return bgNode
        else
            print("此类型不存在。。。",tonumber(v.type))
            return
        end
        -- 存入数组
        if(_isBigMap == false)then
        	table.insert(itemData,tab)
        end
    end

	local node = CCSprite:create()
	return node

end
----

-- 创建展示物品列表cell
-- cellValues 物品数据
-- menu_priority:按钮的优先级，zOrderNum:z轴，info_layer_priority:展示界面的优先级
function createGoodListCell( cellValues, menu_priority, zOrderNum, info_layer_priority )
	-- print("//////////")
	-- print_t(cellValues)
	local cell = CCTableViewCell:create()
	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	if(cellValues.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(cellValues.type == "item") then
		-- 物品
		iconBg =  ItemSprite.getItemSpriteById(tonumber(cellValues.tid),nil, nil, nil,  menu_priority, zOrderNum, info_layer_priority)
		local itemData = ItemUtil.getItemById(cellValues.tid)
        if tonumber(cellValues.tid) >=  80001 and tonumber(cellValues.tid) <= 90000 then
			--时装名称特殊处理
			iconName = ItemSprite.getStringByFashionString(itemData.name)
		elseif(tonumber(cellValues.tid) >= 1800000 and tonumber(cellValues.tid)<= 1900000 ) then
			-- 时装碎片
			iconName = ItemSprite.getStringByFashionString(itemData.name)
		else
        	iconName = itemData.name
        end
        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	elseif(cellValues.type == "hero") then
		-- 英雄
		require "db/DB_Heroes"
		iconBg = ItemSprite.getHeroIconItemByhtid(cellValues.tid,menu_priority,zOrderNum,info_layer_priority)
		local heroData = DB_Heroes.getDataById(cellValues.tid)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	elseif(cellValues.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "stamina") then
		-- 耐力
		iconBg= ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "honor") then
		-- 荣誉
		iconBg= ItemSprite.getHonorIconSprite()
		iconName = GetLocalizeStringBy("lcy_10040")
		local quality = ItemSprite.getHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "contri") then
		-- 贡献
		iconBg= ItemSprite.getContriIconSprite()
		iconName = GetLocalizeStringBy("lcy_10041")
		local quality = ItemSprite.getContriQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "grain") then
		-- 贡献
		iconBg= ItemSprite.getGrainSprite()
		iconName = GetLocalizeStringBy("lcyx_101")
		local quality = ItemSprite.getGrainQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(cellValues.type == "coin") then
		-- 神兵令
		iconBg= ItemSprite.getGodWeaponTokenSprite()
		iconName = GetLocalizeStringBy("lcyx_149")
		local quality = ItemSprite.getGodWeaponTokenSpriteQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "cross_honor" ) then
    	-- 跨服荣誉 add by yangrui 15-10-13
		iconBg = ItemSprite.getKFBWHonorIcon()
		iconName = GetLocalizeStringBy("yr_2002")
		local quality = ItemSprite.getKFBWHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "tally_point" ) then 
    	-- 兵符积分
		iconBg = ItemSprite.getTallyPointIcon()
		iconName = GetLocalizeStringBy("syx_1072")
		local quality = ItemSprite.getTallyPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
   	elseif ( cellValues.type == "book_num" ) then 
    	-- 科技图纸
		iconBg = ItemSprite.getBookIcon()
		iconName = GetLocalizeStringBy("lic_1812")
		local quality = ItemSprite.getBookQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "tower_num" ) then 
    	-- 试炼币
		iconBg = ItemSprite.getTowerNumIcon()
		iconName = GetLocalizeStringBy("lic_1845")
		local quality = ItemSprite.getTowerNumQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "star_point" ) then 
    	-- 星魄
		iconBg = ItemSprite.getStarPointIcon()
		iconName = GetLocalizeStringBy("lic_1844")
		local quality = ItemSprite.getStarPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( cellValues.type == "exp_num" ) then 
    	-- 经验
		iconBg = ItemSprite.getExpNumIcon()
		iconName = GetLocalizeStringBy("lic_1847")
		local quality = ItemSprite.getExpNumQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    else
	end
	iconBg:setAnchorPoint(ccp(0,1))
	iconBg:setPosition(ccp(18,120))
	cell:addChild(iconBg)

	-- 物品数量
	if( tonumber(cellValues.num) > 1 )then
		local numberLabel = CCRenderLabel:create(cellValues.num,g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)-- modified by yangrui at 2015-12-03
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel)
	end

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.1-2))
	iconBg:addChild(descLabel)

	-- 是否是掉落
	if(cellValues.isDrop)then
		local dropMarkSp = CCSprite:create("images/common/gailv.png")
		dropMarkSp:setAnchorPoint(ccp(0,0))
		dropMarkSp:setPosition(ccp(0,0))
		iconBg:addChild(dropMarkSp)
	end

	return cell
end

-- 领取成功后修改本地数据
function addRewardByTable( rewardTab )
     for k,v in pairs(rewardTab) do
        if( v.type == "silver" ) then
            -- 加银币
            UserModel.addSilverNumber(tonumber(v.num))
        elseif( v.type == "soul" ) then
            -- 加将魂
            UserModel.addSoulNum(tonumber(v.num))
       elseif( v.type == "gold" ) then
            -- 加金币
            UserModel.addGoldNumber(tonumber(v.num))
        elseif( v.type == "execution" ) then
            -- 加体力点
            UserModel.addEnergyValue(tonumber(v.num))
        elseif( v.type == "stamina" ) then
            -- 加耐力点
            UserModel.addStaminaNumber(tonumber(v.num))
        elseif( v.type == "prestige") then
            -- 加声望
            UserModel.addPrestigeNum(tonumber(v.num))
        elseif( v.type == "jewel") then
            -- 加魂玉
            UserModel.addJewelNum(tonumber(v.num))
        elseif( v.type == "contri") then
            -- 个人贡献
            GuildDataCache.addSigleDonate(tonumber(v.num))
        elseif v.type == "honor" then
        	-- 比武荣誉
        	UserModel.addHonorNum(v.num)
        elseif( v.type == "grain") then
        	--粮草
        	GuildDataCache.setMyselfGrainNum(GuildDataCache.getMyselfGrainNum() + tonumber(v.num))
        elseif(v.type == "tg_num") then
        	UserModel.addGodCardNum(tonumber(v.num))
    	elseif ( v.type == "cross_honor" ) then
    		-- 跨服荣誉  add by yangrui 15-10-13
    		UserModel.addCrossHonor(tonumber(v.num))
    	elseif ( v.type == "fs_exp" ) then
    		-- 战魂经验
    		UserModel.addFSExpNum(tonumber(v.num))
    	elseif ( v.type == "wm_num" ) then
    		-- 争霸令
    		UserModel.addWmNum(tonumber(v.num))
    	elseif ( v.type == "jh" ) then
    		-- 将星
    		UserModel.addHeroJh(tonumber(v.num))
    	elseif ( v.type == "tally_point" ) then
    		-- 兵符积分
    		UserModel.addTallyPointNumber(tonumber(v.num))
    	elseif ( v.type == "book_num" ) then 
    		-- 科技图纸
    		UserModel.addBookNum(tonumber(v.num))
    	elseif ( v.type == "exp_num" ) then 
    		-- 经验
    		UserModel.addExpValue(tonumber(v.num))
    	else
        end
    end
end


-- 扣除本地数值 传入的是正数，方法内做减法处理
function subRewardByTable( rewardTab )
     for k,v in pairs(rewardTab) do
        if( v.type == "silver" ) then
            -- 加银币
            UserModel.addSilverNumber(-tonumber(v.num))
        elseif( v.type == "soul" ) then
            -- 加将魂
            UserModel.addSoulNum(-tonumber(v.num))
       elseif( v.type == "gold" ) then
            -- 加金币
            UserModel.addGoldNumber(-tonumber(v.num))
        elseif( v.type == "execution" ) then
            -- 加体力点
            UserModel.addEnergyValue(-tonumber(v.num))
        elseif( v.type == "stamina" ) then
            -- 加耐力点
            UserModel.addStaminaNumber(-tonumber(v.num))
        elseif( v.type == "prestige") then
            -- 加声望
            UserModel.addPrestigeNum(-tonumber(v.num))
        elseif( v.type == "jewel") then
            -- 加魂玉
            UserModel.addJewelNum(-tonumber(v.num))
        elseif( v.type == "contri") then
            -- 个人贡献
            GuildDataCache.addSigleDonate(-tonumber(v.num))
        elseif v.type == "honor" then
        	-- 比武荣誉
        	UserModel.addHonorNum(-tonumber(v.num))
        elseif( v.type == "grain") then
        	--粮草
        	GuildDataCache.setMyselfGrainNum(GuildDataCache.getMyselfGrainNum() - tonumber(v.num))
        elseif(v.type == "tg_num") then
        	UserModel.addGodCardNum(-tonumber(v.num))
    	elseif ( v.type == "cross_honor" ) then
    		-- 跨服荣誉  add by yangrui 15-10-13
    		UserModel.addCrossHonor(-tonumber(v.num))
    	elseif ( v.type == "fs_exp" ) then
    		-- 战魂经验
    		UserModel.addFSExpNum(-tonumber(v.num))
    	elseif ( v.type == "wm_num" ) then
    		-- 争霸令
    		UserModel.addWmNum(-tonumber(v.num))
    	elseif ( v.type == "jh" ) then
    		-- 将星
    		UserModel.addHeroJh(-tonumber(v.num))
    	elseif ( v.type == "tally_point" ) then
    		-- 兵符积分
    		UserModel.addTallyPointNumber(-tonumber(v.num))
    	elseif ( v.type == "book_num" ) then 
    		-- 科技图纸
    		UserModel.addBookNum(-tonumber(v.num))
    	else
        end
    end
end

-- 获得一个奖励的icon
function createGoodsIcon(goodsValues, menu_priority, zOrderNum, info_layer_priority, callFun ,p_needSpecial,p_donotNeedMenu,p_nameVisible,p_numVisible)
	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	--needSpecial这个参数的意思是
	--如果希望拿到带有武将信息回调的武魂头像的话，将这个参数设置为true即可
	--added by Zhang Zihang
	local needSpecial = p_needSpecial or false

	-------------------------------------------------
    -- p_donotNeedMenu 参数意思是 如果希望得到的物品头像不带点击后的物品详情介绍，仅仅返回一个sprite，就将这个参数置为true
	-- add by DJN
	local donotNeedMenu = p_donotNeedMenu or false
	-------------------------------------------------
	-- print("goodsValues.type",goodsValues.type)
	if(goodsValues.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(goodsValues.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(goodsValues.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	elseif(goodsValues.type == "item") then
		-- 物品
		--如果希望得到带有武将信息回调的武魂头像
		--added by Zhang Zihang
		if needSpecial and (tonumber(goodsValues.tid) >= 400001 and tonumber(goodsValues.tid) <= 500000) then
			iconBg = ItemSprite.getHeroSoulSprite(tonumber(goodsValues.tid),menu_priority,zOrderNum,info_layer_priority)
			local itemData = ItemUtil.getItemById(goodsValues.tid)
	        iconName = itemData.name
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
		--如果想得到的只是物品图标,点击后无弹窗的话
		--add by DJN  ---------------------------------------------------------------
	    elseif (donotNeedMenu)then
            iconBg = ItemSprite.getItemSpriteByItemId(goodsValues.tid)
	    	local itemData = ItemUtil.getItemById(tonumber(goodsValues.tid))
	        iconName = itemData.name
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
        ------------------------------------------------------------------------------
	    else
	    --得到物品的图标，点击后有弹窗介绍
	    	iconBg =  ItemSprite.getItemSpriteById(tonumber(goodsValues.tid),nil, callFun, nil,  menu_priority, zOrderNum, info_layer_priority)
			local itemData = ItemUtil.getItemById(goodsValues.tid)
			if tonumber(goodsValues.tid) >=  80001 and tonumber(goodsValues.tid) <= 90000 then
				--时装名称特殊处理
				iconName = ItemSprite.getStringByFashionString(itemData.name)
			elseif(tonumber(goodsValues.tid) >= 1800000 and tonumber(goodsValues.tid)<= 1900000 ) then
				-- 时装碎片
				iconName = ItemSprite.getStringByFashionString(itemData.name)
			else
	        	iconName = itemData.name
	        end
	        nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)

	    end
	elseif(goodsValues.type == "hero") then
		-- 英雄
		--如果想得到的只是图标,点击后无弹窗的话
		--add by DJN  --------------------------------------------------------------
		if(donotNeedMenu)then
			require "script/model/utils/HeroUtil"
			iconBg  = HeroUtil.getHeroIconByHTID(goodsValues.tid)
		-----------------------------------------------------------------------------
		else
			require "db/DB_Heroes"
			iconBg = ItemSprite.getHeroIconItemByhtid(goodsValues.tid,menu_priority,zOrderNum,info_layer_priority)
        end
		local heroData = DB_Heroes.getDataById(goodsValues.tid)
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
	elseif(goodsValues.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "stamina") then
		-- 耐力
		iconBg= ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "honor") then
		-- 荣誉
		iconBg= ItemSprite.getHonorIconSprite()
		iconName = GetLocalizeStringBy("lcy_10040")
		local quality = ItemSprite.getHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "contri") then
		-- 贡献
		iconBg= ItemSprite.getContriIconSprite()
		iconName = GetLocalizeStringBy("lcy_10041")
		local quality = ItemSprite.getContriQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "grain") then
    	-- 粮草
		iconBg= ItemSprite.getGrainSprite()
		iconName = GetLocalizeStringBy("lic_1323")
		local quality = ItemSprite.getGrainQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "coin") then
		-- 神兵令
		iconBg= ItemSprite.getGodWeaponTokenSprite()
		iconName = GetLocalizeStringBy("lcyx_149")
		local quality = ItemSprite.getGodWeaponTokenSpriteQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "zg") then
		-- 战功
		iconBg= ItemSprite.getBattleAchieIcon()
		iconName = GetLocalizeStringBy("lcyx_1819")
		local quality = ItemSprite.getBattleAchieQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "tg_num") then
		-- 天工令
		iconBg= ItemSprite.getTianGongLingIcon()
		iconName = GetLocalizeStringBy("lic_1561")
		local quality = ItemSprite.getTianGongLingQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "wm_num") then
		-- 争霸令
		iconBg= ItemSprite.getWmIcon()
		iconName = GetLocalizeStringBy("lcyx_1912")
		local quality = ItemSprite.getWmQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(goodsValues.type == "hellPoint") then
		-- 炼狱令
		iconBg= ItemSprite.getHellPointIcon()
		iconName = GetLocalizeStringBy("lcyx_1917")
		local quality = ItemSprite.getHellPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( goodsValues.type == "cross_honor" ) then
    	-- 跨服比武荣誉  add by yangrui 15-10-13
		iconBg = ItemSprite.getKFBWHonorIcon()
		iconName = GetLocalizeStringBy("yr_2002")
		local quality = ItemSprite.getKFBWHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( goodsValues.type == "jh" ) then
       	-- 将星  add by shengyixian 15-12-07
		iconBg = ItemSprite.getHeroJhIcon()
		iconName = GetLocalizeStringBy("syx_1053")
		local quality = ItemSprite.getHeroJhQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( goodsValues.type == "copoint" ) then
       	-- 国战积分  add by shengyixian 15-12-07
		iconBg = ItemSprite.getCopointIcon()
		iconName = GetLocalizeStringBy("fqq_015")
		local quality = ItemSprite.getCopointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif (goodsValues.type == "tally_point") then
       	-- 兵符积分  add by fqq 15-01-14
		iconBg = ItemSprite.getTallyPointIcon()
		iconName = GetLocalizeStringBy("syx_1072")
		local quality = ItemSprite.getTallyPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( goodsValues.type == "book_num" ) then 
    	-- 科技图纸
		iconBg = ItemSprite.getBookIcon()
		iconName = GetLocalizeStringBy("lic_1812")
		local quality = ItemSprite.getBookQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( goodsValues.type == "tower_num" ) then 
    	-- 试炼币
		iconBg = ItemSprite.getTowerNumIcon()
		iconName = GetLocalizeStringBy("lic_1845")
		local quality = ItemSprite.getTowerNumQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif ( goodsValues.type == "star_point" ) then 
    	-- 星魄
		iconBg = ItemSprite.getStarPointIcon()
		iconName = GetLocalizeStringBy("lic_1844")
		local quality = ItemSprite.getStarPointQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
   	elseif ( goodsValues.type == "exp_num" ) then 
    	-- 经验
		iconBg = ItemSprite.getExpNumIcon()
		iconName = GetLocalizeStringBy("lic_1847")
		local quality = ItemSprite.getExpNumQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    else
	end

	local numVisible
	if p_numVisible == nil then
		numVisible = true
	else
		numVisible = p_numVisible
	end

	-- 物品数量
	if( tonumber(goodsValues.num) > 1 )then
		local numberLabel = CCRenderLabel:create(goodsValues.num,g_sFontName,21,2,ccc3(0x00,0x00,0x00),type_stroke)  -- modified by yangrui at 2015-12-03
		numberLabel:setColor(ccc3(0x00,0xff,0x18))
		numberLabel:setAnchorPoint(ccp(0,0))
		print("numVisible====",numVisible)
		numberLabel:setVisible(numVisible)
		local width = iconBg:getContentSize().width - numberLabel:getContentSize().width - 6
		numberLabel:setPosition(ccp(width,5))
		iconBg:addChild(numberLabel)
	end

	--名字是否可见
	local nameVisible
	if p_nameVisible == nil then
		nameVisible = true
	else
		nameVisible = p_nameVisible
	end

	--- desc 物品名字
	local descLabel = CCRenderLabel:create("" .. iconName , g_sFontName,21,1,ccc3(0x00,0x00,0x00),type_stroke)
	descLabel:setColor(nameColor)
	descLabel:setAnchorPoint(ccp(0.5,0.5))
	descLabel:setVisible(nameVisible)
	descLabel:setPosition(ccp(iconBg:getContentSize().width*0.5 ,-iconBg:getContentSize().height*0.1-2))
	iconBg:addChild(descLabel)

	return iconBg,iconName,nameColor
end


-- 通过对应的数据，得到小的图标
-- added by zhz
function getSmallSprite( items)

	local smallIconSp

	if(items.type == "silver") then
		-- 银币
		smallIconSp= CCSprite:create("images/common/coin.png")
	elseif(items.type == "soul") then
		-- 将魂
		smallIconSp= CCSprite:create("images/common/icon_soul.png")

	elseif(items.type == "gold") then
		-- 金币
		smallIconSp= CCSprite:create("images/common/gold.png")

	elseif(items.type == "item") then
		-- 物品
		local item_info= getItemById( tonumber(items.tid))
		local icon_small= item_info.icon_small
		smallIconSp =  CCSprite:create("images/base/item_small/" ..icon_small )

	elseif(items.type == "hero") then
		-- 英雄
		require "db/DB_Heroes"
	elseif(items.type == "prestige") then
		-- 声望
		smallIconSp= CCSprite:create("images/common/prestige.png")

    elseif(items.type == "jewel") then
		-- 魂玉
		smallIconSp= CCSprite:create("images/common/soul_jade.png")

    elseif(items.type == "execution") then
		-- 体力
		smallIconSp= CCSprite:create("images/common/soul_jade.png")

    elseif(items.type == "stamina") then
		-- 耐力
		smallIconSp= CCSprite:create("images/common/soul_jade.png")
	elseif items.type == "honor" then
		-- 比武荣誉
		smallIconSp = CCSprite:create("images/common/s_honor.png")
	end

	return smallIconSp

end


--[[
	added by bzx
	@desc:	 	检查物品数量是否满足
	@param:		p_type  		需要的消耗类型 
	@param:	  	p_count 		需要的数量
	@param:		p_isShowTip 	是否要弹提示
--]]
function checkItemCountByType(p_type, p_count, p_isShowTip, p_touchPriority, p_zOrder)
	local countDatas = {}
	-- 银币
	countDatas["silver"] = {count = UserModel.getSilverNumber(), name = GetLocalizeStringBy("lic_1509")}
	-- 金币
	countDatas["gold"] = {count = UserModel.getGoldNumber()}
	-- 声望
	countDatas["prestige"] = {count = UserModel.getPrestigeNum(), name = GetLocalizeStringBy("key_8252")}
	-- 比武荣誉
	countDatas["honor"] = {count = UserModel.getHonorNum(), name = GetLocalizeStringBy("lic_1084")}
	local count = countDatas[p_type].count
	if count < p_count then
		if p_isShowTip then
			if p_type == "gold" then
				require "script/ui/tip/LackGoldTip"
				LackGoldTip.showTip()
			else
				AnimationTip.showTip(string.format(GetLocalizeStringBy("zz_121"), countDatas[p_type].name))
			end
		end
		return false
	end
	return true
end

---------------------------------------- added by bzx
-- 通过物品ID来增减物品数量
function addItemCountByID(item_id, item_count)
    local item_data = ItemUtil.getCacheItemInfoBy(item_id)
    if item_data ~= nil then
        item_data.item_num = item_data.item_num + item_count
    end
end
----------------------------------------

-------------------------------add by chengliang
function hasBetterEquipBy( equip_type, equip_score )

	equip_type = tonumber(equip_type)
	equip_score = tonumber(equip_score)

	local isBetter = false

	local remoteBagInfo = DataCache.getRemoteBagInfo()
	if( not table.isEmpty(remoteBagInfo) and  not table.isEmpty(remoteBagInfo.arm) )then
		local armInfos = remoteBagInfo.arm
		for item_id, arm_info in pairs(armInfos) do
			local arm_desc = ItemUtil.getItemById(arm_info.item_template_id)
			if( equip_type == tonumber(arm_desc.type) and tonumber(arm_desc.base_score) > equip_score )then
				isBetter = true
				break
			end
		end
	end

	return isBetter
end
----------------------------add by DJN
--[[
    @des    :判断传入的id的碎片类型
    @param  :p_id<=>item_template_id
    @return :--是碎片的话返回对应类型的数值，不是碎片返回nil
--]]
--获取碎皮详细信息可通过 getItemById函数
function isFragment(p_id)
	local i_id = tonumber(p_id)
	if(i_id >= 400001 and i_id <= 500000) then
		-- 武将碎片类：
		-- require "db/DB_Item_hero_fragment"
		-- i_data = DB_Item_hero_fragment.getDataById(i_id)
		return 1

	elseif(i_id >= 1000001 and i_id <= 5000000) then
		-- 物品碎片类：
		-- require "db/DB_Item_fragment"
		-- i_data = DB_Item_fragment.getDataById(i_id)
		return 2

	elseif( i_id >= 5000001 and i_id <= 6000000 )then
		-- 宝物碎片
		-- require "db/DB_Item_treasure_fragment"
		-- i_data = DB_Item_treasure_fragment.getDataById(i_id)
		-- i_data.desc = i_data.info
		return 3

	elseif( i_id >= 6000001 and i_id <= 7000000 ) then
		--宠物碎片
		-- require "db/DB_Item_pet_fragment"
		-- i_data = DB_Item_pet_fragment.getDataById(i_id)
		return 4

	elseif( i_id >= 7000001 and i_id <= 8000000 ) then
		-- 神兵碎片
		-- require "db/DB_Item_godarm_fragment"
		-- i_data = DB_Item_godarm_fragment.getDataById(i_id)
		return 5
	elseif( i_id >= 8000001 and i_id <= 9000000 ) then
		-- 符印碎片
		-- require "db/DB_Item_godarm_fragment"
		-- i_data = DB_Item_godarm_fragment.getDataById(i_id)
		return 6
	elseif( i_id >= 9000001 and i_id <= 9100000 ) then
		-- 兵符碎片
		return 7
	else
		print("item not found")

	end
end

---------------------------------- 橙色宝物 ----------------------------------

--[[
	@des 	: 得到宝物的品质
	@param 	: p_itemTid 模板id
	@return : num
--]]
function getTreasureQualityByTid( p_itemTid )
	local dbInfo = getItemById(p_itemTid)
	local retQuality = tonumber(dbInfo.quality)
	return retQuality
end

--[[
	@des 	: 得到宝物的品质
	@param 	: p_itemInfo宝物详细信息
	@return : num
--]]
function getTreasureQualityByItemInfo( p_itemInfo )
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local retQuality = tonumber(dbInfo.quality)
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.treasureDevelop ~= nil and tonumber(p_itemInfo.va_item_text.treasureDevelop) > -1 and tonumber(p_itemInfo.va_item_text.treasureDevelop) <= 5)then
		retQuality = tonumber(dbInfo.new_quality)
	elseif( p_itemInfo.va_item_text and p_itemInfo.va_item_text.treasureDevelop ~= nil and tonumber(p_itemInfo.va_item_text.treasureDevelop) > 5 )then
		retQuality = tonumber(dbInfo.new_quality2)
		print("retQuality",retQuality)
	end
	return retQuality
end

--[[
	@des 	: 得到宝物的品质
	@param 	: p_itemId: 物品id
	@return : num
--]]
function getTreasureQualityByItemId( p_itemId )
	local itemInfo = getItemInfoByItemId(p_itemId)
	if(itemInfo == nil)then
		itemInfo = getTreasInfoFromHeroByItemId(p_itemId)
	end
	local retQuality = getTreasureQualityByItemInfo( itemInfo )
	return retQuality
end

function getRealEnvolLevel( pLevel )
	if(tonumber(pLevel)>=6)then
 		return tonumber(pLevel)-6 
 	else
 		return tonumber(pLevel)
 	end
end


--[[
	@des 	: 得到宝物的品质
	@param 	: p_itemInfo宝物详细信息
	@return : num
--]]
function getTreasureNameByItemInfo( p_itemInfo, p_font, p_fontSize )
	-- local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	-- local dbInfo = getItemById(tid)
	-- local nameStr =  dbInfo.name
	-- if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.treasureDevelop ~= nil and tonumber(p_itemInfo.va_item_text.treasureDevelop) > -1 )then
	-- 	nameStr = nameStr .. p_itemInfo.va_item_text.treasureDevelop .. GetLocalizeStringBy("zzh_1159")
	-- end
	-- return nameStr
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local nameStr =  dbInfo.name
	local quality = ItemUtil.getTreasureQualityByItemInfo( p_itemInfo )
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local textInfo = {
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = p_font,      -- 默认字体
        labelDefaultColor = nameColor,  -- 默认字体颜色
        labelDefaultSize = p_fontSize,          -- 默认字体大小
        defaultType = "CCRenderLabel",
        defaultStrokeSize = 2,
        elements =
        {
            {
                text = nameStr,                     -- 文本内容
            }
        }
 	}

 	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.treasureDevelop ~= nil and tonumber(p_itemInfo.va_item_text.treasureDevelop) > -1 )then
	 	local tab1 = {}
	 	tab1.text = getRealEnvolLevel(p_itemInfo.va_item_text.treasureDevelop)
	 	tab1.color = ccc3(0x00, 0xff, 0x18)
	 	table.insert(textInfo.elements,tab1)
	 	local tab2 = {}
	 	tab2.text = GetLocalizeStringBy("zzh_1159")
	 	tab2.color = ccc3(0x00, 0xff, 0x18)
	 	table.insert(textInfo.elements,tab2)
	end
 	local label = LuaCCLabel.createRichLabel(textInfo)
	return label
end

--[[
	@des 	: 得到宝物的名字
	@param 	: p_itemInfo宝物详细信息
	@return : str
--]]
function getTreasureNameStrByItemInfo( p_itemInfo )
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local nameStr =  dbInfo.name
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.treasureDevelop ~= nil and tonumber(p_itemInfo.va_item_text.treasureDevelop) > -1 )then
		nameStr = nameStr .. getRealEnvolLevel(p_itemInfo.va_item_text.treasureDevelop) .. GetLocalizeStringBy("zzh_1159")
	end
	return nameStr
end

---------------------------------- 红色装备 ----------------------------------
--[[
	@des 	: 得到装备的品质
	@param 	: p_itemTid 模板id
	@return : num
--]]
function getEquipQualityByTid( p_itemTid )
	local dbInfo = getItemById(p_itemTid)
	local retQuality = tonumber(dbInfo.quality)
	return retQuality
end

--[[
	@des 	: 得到装备的品质
	@param 	: p_itemInfo装备详细信息
	@return : num
--]]
function getEquipQualityByItemInfo( p_itemInfo )
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local retQuality = tonumber(dbInfo.quality)
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.armDevelop ~= nil )then
		retQuality = tonumber(dbInfo.new_quality)
	end
	return retQuality
end

--[[
	@des 	: 得到装备的品质
	@param 	: p_itemId: 物品id
	@return : num
--]]
function getEquipQualityByItemId( p_itemId )
	local itemInfo = getItemInfoByItemId(p_itemId)
	if(itemInfo == nil)then
		itemInfo = getEquipInfoFromHeroByItemId(p_itemId)
	end
	local retQuality = getEquipQualityByItemInfo( itemInfo )
	return retQuality
end

function getEquipName( p_itemInfo )
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local nameStr =  dbInfo.name
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.treasureDevelop ~= nil and tonumber(p_itemInfo.va_item_text.treasureDevelop) > -1 )then
		nameStr = nameStr .. getRealEnvolLevel(p_itemInfo.va_item_text.treasureDevelop) .. GetLocalizeStringBy("zzh_1159")
	end
	return nameStr
end
--[[
	@des 	: 得到装备的品质
	@param 	: p_itemInfo装备详细信息
	@return : num
--]]
function getEquipNameByItemInfo( p_itemInfo, p_font, p_fontSize )
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local nameStr =  dbInfo.name
	local quality =ItemUtil.getEquipQualityByItemInfo( p_itemInfo )
	local nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
	local textInfo = {
        alignment = 1, -- 对齐方式  1 左对齐，2 居中， 3右对齐
        labelDefaultFont = p_font,      -- 默认字体
        labelDefaultColor = nameColor,  -- 默认字体颜色
        labelDefaultSize = p_fontSize,          -- 默认字体大小
        defaultType = "CCRenderLabel",
        defaultStrokeSize = 2,
        elements =
        {
            {
                text = nameStr,                     -- 文本内容
            }
        }
 	}

 	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.armDevelop ~= nil and tonumber(p_itemInfo.va_item_text.armDevelop) > 0 )then
	 	local tab1 = {}
	 	tab1.text = p_itemInfo.va_item_text.armDevelop
	 	tab1.color = ccc3(0x00, 0xff, 0x18)
	 	table.insert(textInfo.elements,tab1)
	 	local tab2 = {}
	 	tab2.text = GetLocalizeStringBy("zzh_1159")
	 	tab2.color = ccc3(0x00, 0xff, 0x18)
	 	table.insert(textInfo.elements,tab2)
	end
 	local label = LuaCCLabel.createRichLabel(textInfo)
	return label
end
--[[
	@des 	: 得到装备的名字
	@param 	: p_itemInfo装备详细信息
	@return : str
--]]
function getEquipNameStrByItemInfo( p_itemInfo )
	local tid = p_itemInfo.item_template_id or p_itemInfo.itemDesc.id
	local dbInfo = getItemById(tid)
	local nameStr =  dbInfo.name
	if( p_itemInfo.va_item_text and p_itemInfo.va_item_text.armDevelop ~= nil and tonumber(p_itemInfo.va_item_text.armDevelop) > 0 )then
		nameStr = nameStr .. p_itemInfo.va_item_text.armDevelop .. GetLocalizeStringBy("zzh_1159")
	end
	return nameStr
end
------------------------------------------------------------------------------------------------------------------------------------
--[[
	@des 	: 得到物品的名字
	@param 	: p_tid 物品tid
	@return : str
--]]
function getItemNameByTid( p_tid )
 	local dbData = ItemUtil.getItemById(p_tid)
 	local retName = nil
	if( tonumber(dbData.id) >= 80001 and tonumber(dbData.id) <= 90000 )then
		-- 时装
		retName = getFashionNameByNameStr( dbData.name )
	elseif(tonumber(dbData.id) >= 1800000 and tonumber(dbData.id) <= 1900000 ) then
		-- 时装碎片
		retName = getFashionNameByNameStr( dbData.name )
	else
		retName = dbData.name
	end
	return retName
end

--[[
	@des 	: 得到时装的名字
	@param 	: p_nameStr "20001|炎马烈铠,20002|天马霓裳"
	@return : str
--]]
function getFashionNameByNameStr( p_nameStr )
	local retName = nil
 	-- 时装
	local myModelId = UserModel.getUserModelId()
	local nameStrArr = string.split(p_nameStr, ",")
	for i=1,#nameStrArr do
		local temArr = string.split(nameStrArr[i], "|")
		if( tonumber(myModelId) == tonumber(temArr[1]) )then
			retName = temArr[2]
			break
		end
	end
	return retName
end










