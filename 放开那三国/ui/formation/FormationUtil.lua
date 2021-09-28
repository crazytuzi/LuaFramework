-- Filename：	FormationUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-7-18
-- Purpose：		阵型工具

module("FormationUtil", package.seeall)
require "script/utils/LuaUtil"
require "script/model/hero/HeroModel"
require "script/ui/hero/HeroPublicLua"
require "script/model/DataCache"

-- 摸个连写技能是否开启
-- function isUnionActive( u_id, hid )

-- 	local isActive = true

-- 	local t_union_profit = DB_Union_profit.getDataById(u_id)
-- 	local curHeroData = HeroUtil.getHeroInfoByHid(hid)
-- 	local card_ids = string.split(t_union_profit.union_card_ids, ",")
-- 	for k,type_card in pairs(card_ids) do
-- 		local type_card_arr = string.split(type_card, "|")
-- 		if(tonumber(type_card_arr[1]) == 1)then
-- 			if(tonumber(type_card_arr[2]) == 0)then
-- 				if( not isMainHeroOnFormation() ) then
-- 					isActive = false
-- 					break
-- 				end
-- 			else
-- 				if(not (HeroPublicLua.isBusyWithHtid(tonumber(type_card_arr[2]))) and (not HeroPublicLua.isOnLittleFriendBy(tonumber(type_card_arr[2])))  ) then
-- 					isActive = false
-- 					break
-- 				end
-- 			end
-- 		elseif(tonumber(type_card_arr[1]) == 2)then
-- 			isActive = false
-- 			for k,v in pairs(curHeroData.equip.treasure) do
-- 				-- 宝物
-- 				if( not table.isEmpty(v)) then
-- 					if(tonumber(v.item_template_id) ==tonumber(type_card_arr[2]) )then
-- 						isActive = true
-- 						break
-- 					end
-- 				end
-- 			end
-- 			if(isActive == false)then
-- 				-- 装备
-- 				for k,v in pairs(curHeroData.equip.arming) do
-- 					if( not table.isEmpty(v)) then
-- 						if(tonumber(v.item_template_id) ==tonumber(type_card_arr[2]) )then
-- 							isActive = true
-- 							break
-- 						end
-- 					end
-- 				end
-- 			end

-- 			if(isActive == false) then
-- 				--神兵
-- 				--added by Zhang Zihang
-- 				for k,v in pairs(curHeroData.equip.godWeapon) do
-- 					if( not table.isEmpty(v)) then
-- 						require "script/ui/item/GodWeaponItemUtil"
-- 						local itemInfo = GodWeaponItemUtil.getGodWeaponInfo(nil,v.item_id)
-- 						if(tonumber(v.item_template_id) ==tonumber(type_card_arr[2]) ) and (tonumber(itemInfo.va_item_text.evolveNum) >= tonumber(itemInfo.itemDesc.friend_open))then
-- 							isActive = true
-- 							break
-- 						end
-- 					end
-- 				end
-- 			end

-- 			if(isActive == false) then
-- 				break
-- 			end
-- 			--战马类型
-- 		elseif tonumber(type_card_arr[1]) == 3 then
-- 			local heroHorseQuality = HeroModel.getHorseQuality(hid)
-- 			if(tonumber(heroHorseQuality) ~= tonumber(type_card_arr[2])) then
-- 				isActive = false
-- 			end
-- 		--兵书类型
-- 		elseif tonumber(type_card_arr[1]) == 4 then
-- 			local heroHorseQuality = HeroModel.getBookQuality(hid)
-- 			if(tonumber(heroHorseQuality) ~= tonumber(type_card_arr[2])) then
-- 				isActive = false
-- 			end
-- 		else
-- 			print("error union type!")
-- 		end
-- 	end

-- 	if(isActive == true and t_union_profit.union_arribute_starlv)then
-- 		local starLvArr = string.split(t_union_profit.union_arribute_starlv, "|")
-- 		local starInfo = StarUtil.getStarInfoBySid(starLvArr[1])
-- 		if(tonumber(starInfo.level) < tonumber(starLvArr[2]) ) then
-- 			isActive = false
-- 		end
-- 	end

-- 	return isActive
-- end

-- 主角是否在正上
function isMainHeroOnFormation()
	local isOn = false
	local formation = DataCache.getFormationInfo()
	for k,v in pairs(formation) do
		if(v>0)then
			local hero = HeroModel.getHeroByHid(v)
			if(HeroModel.isNecessaryHero(hero.htid))then
				isOn = true
				return isOn
			end
		end
	end
	return isOn
end

-- 当前阵型开启的位置个数
function getFormationOpenedNum()
	return getFormationOpenedNumByLevel(UserModel.getHeroLevel())
end

-- 阵型等级开启的位置个数
function getFormationOpenedNumByLevel(level)
	level = tonumber(level)
	require "db/DB_Formation"
	local f_data = DB_Formation.getDataById(1)
	local userInfo = UserModel.getUserInfo()
	-- local f_open_levels = lua_string_split(f_data.openPositionLv, ",")
	-- local open_num = 0
	-- require "script/model/user/UserModel"
	-- -- 计算开启了几个位置
	-- for k, openLv in pairs(f_open_levels) do
	-- 	if(tonumber(userInfo.level) >= tonumber(openLv)) then
	-- 		open_num = open_num + 1
	-- 	end
	-- end
	local f_open_levels_str = lua_string_split(f_data.openNumByLv, ",")
	local f_open_levels = {}
	local open_num = 0
	for k,v in pairs(f_open_levels_str) do
		local temp_t = lua_string_split(v, "|")
		if( tonumber(temp_t[1])<= level )then
			if( open_num < tonumber(temp_t[2]) )then
				open_num = tonumber(temp_t[2])
			end
		end
	end
	return open_num
end

-- 某个位置是否开启 m_pos：start with 0
function isOpenedByPosition( m_pos )
	m_pos = tonumber(m_pos)
	require "db/DB_Formation"
	local f_data = DB_Formation.getDataById(1)

	local f_open_nums = lua_string_split(f_data.openSort, ",")
	local f_open_levels = lua_string_split(f_data.openPositionLv, ",")
	local open_num = 0
	require "script/model/user/UserModel"
	local userInfo = UserModel.getUserInfo()
	local curIndx = 0
	for k, v_pos in pairs(f_open_nums) do
		if(tonumber(v_pos) == m_pos) then
			curIndx = k
			break
		end
	end
	return tonumber(userInfo.level) >= tonumber(f_open_levels[curIndx])
end

-- 获得某个位置的开启等级
function getOpenLevelByPosition( m_pos )
	m_pos = tonumber(m_pos)
	require "db/DB_Formation"
	local f_data = DB_Formation.getDataById(1)

	local f_open_nums = lua_string_split(f_data.openSort, ",")
	local f_open_levels = lua_string_split(f_data.openPositionLv, ",")
	local open_num = 0
	require "script/model/user/UserModel"
	local userInfo = UserModel.getUserInfo()
	local curIndx = 0
	for k, v_pos in pairs(f_open_nums) do
		print(v_pos, "   ", m_pos)
		if( tonumber( v_pos) == tonumber(m_pos) )then
			curIndx = k
			break
		end
	end

	return tonumber(f_open_levels[curIndx])
end

-- 下一个上阵个数的开启等级
function nextOpendFormationNumAndLevel()
	
	require "db/DB_Formation"
	local f_data = DB_Formation.getDataById(1)
	local userInfo = UserModel.getUserInfo()

	local f_open_levels_str = lua_string_split(f_data.openNumByLv, ",")
	local f_open_levels = {}
	local nextLevel = 999
	for k,v in pairs(f_open_levels_str) do
		local temp_t = lua_string_split(v, "|")
		if( tonumber(temp_t[1])> UserModel.getHeroLevel() )then
			if(nextLevel > tonumber(temp_t[1]))then
				nextLevel = tonumber(temp_t[1])
			end
		end
	end

	return nextLevel
end

-- 下一个阵型开启的位置和等级
function nextOpendPosAndLevel()
	local opendNum = getFormationOpenedNum()

	require "db/DB_Formation"
	local f_data = DB_Formation.getDataById(1)
	
	local f_open_nums = lua_string_split(f_data.openSort, ",")
	local f_open_levels = lua_string_split(f_data.openPositionLv, ",")
	local nextPos = f_open_nums[opendNum+1]
	local nextLevel = f_open_levels[opendNum+1]
	return nextPos, nextLevel
end

-- 当前的上阵和能上阵的  返回值 number/number <==> 上阵将领个数/最大上阵个数
function getOnFormationAndLimited()
	local formationInfo = DataCache.getFormationInfo()
	local onNum = 0
	if(not table.isEmpty(formationInfo)) then
		for k,v in pairs(formationInfo) do
			if(tonumber(v)>0)then
				onNum = onNum +1
			end
		end
	end

	return onNum, getFormationOpenedNum()
end

-- 是否有相同将领已经上阵已经上阵
function isHadSameTemplateOnFormation(h_id)
	require "db/DB_Heroes"
	local isOn = false
	local heroInfo = HeroUtil.getHeroInfoByHid(tonumber(h_id))
	local formationInfo = DataCache.getFormationInfo()
	local onNum = 0
	for k,v in pairs(formationInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = DB_Heroes.getDataById(t_heroInfo.htid).model_id
			local modelIdB = DB_Heroes.getDataById(heroInfo.htid).model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				isOn = true
				break
			end
		end
	end
	return isOn
end

-- 是否有相同将领已经上阵已经上阵
function isHadSameTemplateOnFormationByHtid(h_tid)
	require "db/DB_Heroes"
	local isOn = false
	local formationInfo = DataCache.getFormationInfo()
	for k,v in pairs(formationInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = DB_Heroes.getDataById(t_heroInfo.htid).model_id
			local modelIdB = DB_Heroes.getDataById(tonumber(h_tid)).model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				isOn = true
				break
			end
		end
	end
	return isOn
end

-- 计算武将的连携
function parseHeroUnionProfit( cur_Hid, link_group )
	require "db/DB_Union_profit"
	require "script/model/utils/UnionProfitUtil"
	local s_link_arr = string.split(link_group, ",")
	local t_link_infos = {}
	for k, link_id in pairs(s_link_arr) do
		local t_union_profit = DB_Union_profit.getDataById(link_id)
		local link_info = {}
		link_info.dbInfo = t_union_profit
		link_info.isActive = UnionProfitUtil.isHeroParticularUnionOpen( link_id, cur_Hid )

		table.insert(t_link_infos, link_info)
	end

	return t_link_infos
end


-- 战魂格子是否开启
function isFightSoulOpenByPos( posIndex )
	require "db/DB_Normal_config"
	local dbInfo = DB_Normal_config.getDataById(1)
	posIndex = tonumber(posIndex)
	local openLvArr = string.split(dbInfo.fightSoulOpenLevel, ",")
	local isOpen = false
	local openLv = tonumber(openLvArr[posIndex])
	if( UserModel.getHeroLevel() >= openLv )then
		isOpen = true
	else
		isOpen = false
	end

	return isOpen, openLv
end

-- 得到羁绊点亮的个数
-- cur_Hid 当前英雄hid
function getHeroLinkUseNum( cur_Hid )
	local retNum = 0
	local curHeroData = HeroUtil.getHeroInfoByHid(cur_Hid)
	-- 羁绊
	local link_group = curHeroData.localInfo.link_group1
	-- 得到羁绊信息
	local link_group_Data = parseHeroUnionProfit( cur_Hid, link_group )
	for k,v in pairs(link_group_Data) do
		if( v.isActive )then
			retNum = retNum + 1
		end
	end
	return retNum
end

--[[
	@des 	:是否可以更换该武将到该位置上 更换武将用
	@param 	: h_id:要更换的武将hid，p_position:要更换的位置
	@return :true 可以 
--]]
function isSwapHeroOnFormationByHid(h_id,p_position)
	require "db/DB_Heroes"
	local retData = false
	local onPos = nil
	local heroInfo = HeroUtil.getHeroInfoByHid(tonumber(h_id))
	local formationInfo = DataCache.getSquad()
	for k,v in pairs(formationInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = DB_Heroes.getDataById(t_heroInfo.htid).model_id
			local modelIdB = DB_Heroes.getDataById(heroInfo.htid).model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				onPos = k
				break
			end
		end
	end

	-- print("onPos",onPos,"p_position",p_position)
	if(onPos ~= nil)then
		if(tonumber(onPos) == tonumber(p_position))then
			retData = true
		else
			retData = false
		end
	else
		retData = true
	end
	return retData
end

--[[
	@des 	:判断改神兵位置是否开启
	@param 	:p_position 1,2,3,4
	@return :ture 开启， needLv需要主角等级
--]]
function getGodWeaponIsOpen(p_position)
	local retNeedLv = 0
	local retIsOpen = false
	require "db/DB_Normal_config"
	local str = DB_Normal_config.getDataById(1).opengodamynum
	local strTab = string.split(str, ",")
	for k,v in pairs(strTab) do
		local tab = string.split(v, "|")
		if( tonumber(tab[1]) == tonumber(p_position))then
			retNeedLv = tonumber(tab[2])
			break
		end
	end

	local heroLv = UserModel.getHeroLevel()
	if(heroLv >= retNeedLv)then
		retIsOpen = true
	end
	return retIsOpen, retNeedLv
end





