-- Filename: HeroSort.lua
-- Author: fang
-- Date: 2013-08-30
-- Purpose: 该文件用于: 武将排序(所有有关武将排序的方式都放在这里统一处理)

module("HeroSort", package.seeall)

-- 排序种类
-- 1: 武将界面
m_hero=1
-- 2: 武魂界面
m_heroSoul=2
-- 3: 武将出售界面
m_heroSell=3
-- 4: 选择更换武将界面
m_heroChange=4
-- 5: 武将进阶选择武将界面
m_transferSelectHero=5
-- 6: 武将强化选择武将材料界面
m_strengthenSelectHero=6
-- 7: 强化所武将进阶界面
m_strengthenPlaceTransfer=7
-- 8: 强化所武将强化界面
m_strengthenPlaceStrengthen=8


local function fnCompareWithHtid( h1, h2 )
	print("fnCompareWithHtid",h1.htid, h2.htid)
	return h1.htid > h2.htid
end 

-- 按强化等级由高到低排序
local function fnCompareWithLevel(h1, h2)
	if(h1.level == h2.level) then
		fnCompareWithHtid(h1, h2)
	else
		return h1.level > h2.level
	end
end
-- 按进阶次数排序
local function fnCompareWithEvolveLevel(h1, h2)
	if tonumber(h1.evolve_level) == tonumber(h2.evolve_level) then
		return fnCompareWithLevel(h1, h2)
	else
		return tonumber(h1.evolve_level) > tonumber(h2.evolve_level)
	end
end
-- 按星级高低排序
local function fnCompareWithStarLevel(h1, h2)
	if h1.star_lv == h2.star_lv then
		return fnCompareWithEvolveLevel(h1, h2)
	else
		return h1.star_lv > h2.star_lv
	end
end

-- 1: 武将界面排序规则
-- 规则. a: 主角优先排第一位，
--		b: 已上阵武将优先显示在最上面(上阵武将再按战斗力排序)，
--		c: 剩下的则根据武将星级高低排序，高的排上，低的排下，
--		d: 若星级相同则根据战斗力高低排序
function fnSortOfHero(heroes)
	local tSortedHeroes = {}
	-- 上阵武将数组
	local arrBusyHeroes = {}
	-- 各星级武将数组
	local arrStarLevelHeroes = {}
	-- 主角放在第一位

	--小伙伴放在已上阵武将后面
	local companionsArr = {}

	-- 目前只包含最高星级为 10 级
	for i=1, 10 do
		table.insert(arrStarLevelHeroes, {})
	end
	require "script/model/hero/HeroModel"
	for i=1, #heroes do
		local value=heroes[i]
		if HeroModel.isNecessaryHero(value.htid) then
			-- 主角放在第一位
			tSortedHeroes[1] = value
		elseif value.isBusy then
			-- 上阵武将放在前面
			table.insert(arrBusyHeroes, value)
		elseif(LittleFriendData.isInLittleFriend(value.hid)) then
			-- 小伙伴
			table.insert(companionsArr, value)
		else
			-- 其他武将先按星级分类
			local star_lv = value.star_lv
			if not star_lv or star_lv == 0 then
				star_lv = 1
			end
			table.insert(arrStarLevelHeroes[star_lv], value)
		end
	end
	-- 上阵武将再按战斗力排序
	table.sort(arrBusyHeroes, fnCompareWithStarLevel)
	-- table.sort(arrBusyHeroes, sortForSoulTable)	--change by lichenyang 修改排序规则
	--小伙伴按星级排序
	table.sort(companionsArr, fnCompareWithStarLevel)
	
	-- 星级相同的武将再按战斗力排序
	for i=1, #arrStarLevelHeroes do
		table.sort(arrStarLevelHeroes[i], fnCompareWithEvolveLevel)
	end
	-- 把已排序好的上阵武将加入到 武将排序数组中
	for i=1, #arrBusyHeroes do
		table.insert(tSortedHeroes, arrBusyHeroes[i])
	end
	--把已排好的小伙伴加到 武将排序数组中
	for i=1, #companionsArr do
		table.insert(tSortedHeroes, companionsArr[i])
	end
	-- 把已排序好的星级/战斗力英雄数组加入到 武将排序数组中
	for i=1, 10 do
		local arrStarLevel = arrStarLevelHeroes[10-i+1]
		local arrLen = #arrStarLevel
		if arrLen > 0 then
			for k=1, arrLen do
				table.insert(tSortedHeroes, arrStarLevel[k])
			end
		end
	end

	return tSortedHeroes
end

-- 2: 武魂界面排序
-- 武魂界面排序规则：先根据得到的先后顺序排序，后得到排前，先得到排后，然后再根据星级排序
-- a: 可招募优先
-- b: 星级排序
function fnSortOfHeroSoul(heroes)

	-- print("heroes:")
	-- print_t(heroes)

	local tSortedHeroes = {}
	-- 可招募武将数组
	local arrCanRecruited = {}
	local arrStarLevel = {}
	for i=1, #heroes do
		if heroes[i].isRecruited then
			table.insert(arrCanRecruited, heroes[i])
		else
			table.insert(arrStarLevel, heroes[i])
		end
	end
	-- 按星级排序
	-- table.sort(arrStarLevel, fnCompareWithStarLevel)
	table.sort(arrStarLevel, sortForSoulTable) -- change by lichenyang 修改武魂列表排序顺序
	table.sort(arrCanRecruited,sortForSoulTable)
	-- 把可招募武将加入列表前端
	for i=1, #arrCanRecruited do
		table.insert(tSortedHeroes, arrCanRecruited[i])
	end
	-- 加入按星级排好序的数据
	for i=1, #arrStarLevel do
		table.insert(tSortedHeroes, arrStarLevel[i])
	end

	-- print("tSortedHeroes:")
	-- print_t(tSortedHeroes)

	return tSortedHeroes
end

-- 3: 武将出售界面：
-- 已上阵且5星武将进行过滤（包括主角），
-- 然后再根据出售的价格高低进行排序，价格低的排前，价格高的排后
function fnSortOfHeroSell(heroes)
	table.sort(heroes, function (h1, h2)
		return h1.price < h2.price
	end)
	
	return heroes
end

-- 4: 强化所武将强化界面：
-- 将主角卡牌过滤掉，然后其他同武将界面排序一样。
function fnSortOfSPStrengthen(heroes)
	local tSortedHeroes = {}
	local arrTmp = fnSortOfHero(heroes)
	-- 将主角卡牌过滤掉
	for i=2, #arrTmp do
		tSortedHeroes[i-1] = arrTmp[i]
	end

	return tSortedHeroes
end

-- 5: 强化所武将进阶界面：满足进阶条件者优先排在第一位（主角卡牌从该界面中过滤），
-- 已上阵武将优先显示在最上面(上阵武将再按战斗力排序)，
-- 剩下的则根据武将星级高低排序，高的排上，低的排下，
-- 若星级相同则根据战斗力高低排序

function fnSortOfSPTransfer(heroes)
	local tSortedHeroes = {}

	return tSortedHeroes
end

-- 释放HeroSort模块占用资源
function release( ... )
	HeroSort = nil
	for k, v in pairs(package.loaded) do
		local s, e = string.find(k, "/HeroSort")
		if s and e == string.len(k) then
			package.loaded[k] = nil
		end
	end
end


--武魂界面排序李晨阳
--品质>碎片个数>模版id排序
function sortForSoulTable( soul_1,soul_2 )
	local function comparHtid( h1, h2 )
		if(tonumber(h1.htid) > tonumber(h2.htid)) then
			return true
		else
			return false
		end
	end

	local function comparItemNum( h1, h2 )
		if(tonumber(h1.item_num) == tonumber(h2.item_num)) then
			return comparHtid(h1, h2)
		else
			if(tonumber(h1.item_num) > tonumber(h2.item_num)) then
				return true
			else
				return false
			end
		end
	end

	local function comparStartLevel( h1, h2 )
		if(tonumber(h1.star_lv) > tonumber(h2.star_lv)) then
			return true
		else
			return false
		end
	end

	if(tonumber(soul_1.star_lv) == tonumber(soul_2.star_lv)) then
		return comparItemNum(soul_1, soul_2)
	else
		return comparStartLevel(soul_1, soul_2)
	end
end

--武将列表排序方法
-- 1.进阶等级>2.武将等级>3.资质大小>4.武将ID
function sortForHeroList( p_heros )
	local compareWithEvolveLevel = function(h1, h2)
		if tonumber(h1.heroQuality) == tonumber(h2.heroQuality) then
			-- return compareWithLevel(h1, h2)
			if tonumber(h1.evolve_level) == tonumber(h2.evolve_level) then
				if tonumber(h1.level) == tonumber(h2.level) then
					return tonumber(h1.htid) > tonumber(h2.htid)
				else
					return tonumber(h1.level) > tonumber(h2.level)
				end
			else
				return tonumber(h1.evolve_level) > tonumber(h2.evolve_level)
			end
		else
			return tonumber(h1.heroQuality) > tonumber(h2.heroQuality)
		end
	end
	-- 上阵武将数组
	local arrBusyHeroes = {}
	-- 小伙伴放在已上阵武将后面
	local companionsHeros = {}
	-- 小伙伴放在已上阵武将后面
	local secondFriend = {}
	-- 其他武将
	local otherHeros = {}
	-- 橙卡优先
	local orangeHeros = {}
	local sortHeros = {}
	require "script/model/hero/HeroModel"
	require "script/ui/formation/secondfriend/SecondFriendData"
	for k,value in pairs(p_heros) do
		if HeroModel.isNecessaryHero(value.htid) then
			-- 主角放在第一位
			sortHeros[1] = value
			break
		end
	end
	for k,value in pairs(p_heros) do
		value.db_hero = nil
		if not HeroModel.isNecessaryHero(value.htid) then
			if value.isBusy then
				-- 上阵武将放在前面
				table.insert(arrBusyHeroes, value)
			elseif(LittleFriendData.isInLittleFriend(value.hid)) then
				-- 小伙伴
				table.insert(companionsHeros, value)
			elseif(SecondFriendData.isInSecondFriendByHid(value.hid)) then
				-- 小伙伴
				table.insert(secondFriend, value)
			elseif(tonumber(value.star_lv) >=6 ) then
				table.insert(orangeHeros, value)
			else
				table.insert(otherHeros, value)
			end
		end
	end
	table.sort(arrBusyHeroes, compareWithEvolveLevel)
	table.sort(companionsHeros, compareWithEvolveLevel)
	table.sort(secondFriend, compareWithEvolveLevel)
	table.sort(orangeHeros, compareWithEvolveLevel)
	table.sort(otherHeros, compareWithEvolveLevel)
	
	for i=1, #arrBusyHeroes do
		table.insert(sortHeros, arrBusyHeroes[i])
	end
	for i=1, #companionsHeros do
		table.insert(sortHeros, companionsHeros[i])
	end
	for i=1, #secondFriend do
		table.insert(sortHeros, secondFriend[i])
	end
	for i=1, #orangeHeros do
		table.insert(sortHeros, orangeHeros[i])
	end
	for i=1, #otherHeros do
		table.insert(sortHeros, otherHeros[i])
	end
	return sortHeros
end



