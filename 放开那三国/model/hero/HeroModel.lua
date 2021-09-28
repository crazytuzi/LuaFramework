-- Filename: HeroModel.lua.
-- Author: fang.
-- Date: 2013-07-09
-- Purpose: 武将数据

module("HeroModel", package.seeall)



-- 所有英雄数据
local _allHeroes

local newHeroTable 	= nil
bHaveNewHero = nil

-- 获得所有武将信息
function getAllHeroes()
	return _allHeroes
end
-- 设置所有武将信息
function setAllHeroes(heroes)
	_allHeroes = heroes
	-- 补齐英雄数据
	for k,v in pairs(_allHeroes) do
		initHeroInfos(k)
	end

 	--初始化羁绊信息
    --added by Zhang Zihang
    require "script/model/utils/UnionProfitUtil"
    if table.isEmpty(UnionProfitUtil.getUnionProfitInfo()) then
        UnionProfitUtil.setUnionProfitInfo()
    end

end

--[[
	@des:补齐英雄数据
--]]
function initHeroInfos( p_hid )
	local heroInfo = _allHeroes[p_hid]

	if not heroInfo.hid then
		heroInfo.hid = p_hid
	end
	if not heroInfo.level then
		heroInfo.level = "1"
	end
	if not heroInfo.soul then
		heroInfo.soul = "0"
	end
	if not heroInfo.evolve_level then
		heroInfo.evolve_level = "0"
	end
	if not heroInfo.equip then
		heroInfo.equip = {}
	end
	if not heroInfo.equip.arming then
		heroInfo.equip.arming = {
			[1] = "0",
			[2] = "0",
			[3] = "0",
			[4] = "0",
		}
	end
	if not heroInfo.equip.skillBook then
		heroInfo.equip.skillBook = {}
	end
	if not heroInfo.equip.treasure then
		heroInfo.equip.treasure ={
			[1] = "0",
			[2] = "0",
		}
	end
	if not heroInfo.equip.dress then
		heroInfo.equip.dress ={
			[1] = "0",
		}
	end
	
	if not heroInfo.equip.fightSoul then
		heroInfo.equip.fightSoul ={}
	end
	if not heroInfo.equip.godWeapon then
		heroInfo.equip.godWeapon ={}
	end
	-- 战车
	if not heroInfo.equip.chariot then
		heroInfo.equip.chariot = {}
	end
	if not heroInfo.talent then
		heroInfo.talent ={}
	end
	if not heroInfo.talent.confirmed then
		heroInfo.talent.confirmed ={}
	end
	if not heroInfo.talent.to_confirm then
		heroInfo.talent.to_confirm ={}
	end
	if not heroInfo.talent.sealed then
		heroInfo.talent.sealed ={}
	end
	if not heroInfo.transfer then
		heroInfo.transfer = "0"
	end
	_allHeroes[p_hid] = heroInfo
end


-- 通过hid获得英雄属性
function getHeroByHid(hid)
	return _allHeroes[tostring(hid)]
end
-- 获取所有英雄hids
function getAllHeroesHid()
	local hids = {}
	if _allHeroes == nil then
		return hids
	end
	for k, v in pairs(_allHeroes) do
		hids[#hids+1] = v.hid
	end

	return hids
end
-- 获得当前武将数量
function getHeroNumber()
	return table.count(_allHeroes)
end

-- 通过国家ID获取国家相应等级图标
-- cid -> 所属国家id
-- star_lv -> 星级
function getCiconByCidAndlevel(cid, star_lv)
	local countries = {"wei", "shu", "wu", "qun"}
	if (countries[cid] == nil) then
--		CCLuaLog (string.format("Error: no such country with %d %s", cid, "cid."))
		return "images/common/transparent.png"
	end
	return "images/hero/" .. countries[cid] .. "/" .. countries[cid] .. star_lv .. ".png"
end

-- 通过国家ID获取国家相应等级大图标（是大图标）
-- cid -> 所属国家id
-- star_lv -> 星级
function getLargeCiconByCidAndlevel(cid, star_lv)
	local countries = {"wei", "shu", "wu", "qun"}
	if (countries[cid] == nil) then
--		CCLuaLog (string.format("Error: no such country with %d %s", cid, "cid."))
		return "images/common/transparent.png"
	end
	local quality = star_lv

	return "images/common/hero_show/country/"..countries[cid].."/"..countries[cid]..quality..".png"
end

-- 删除某个英雄
-- hid -> 被删除的英雄hid
function deleteHeroByHid(hid)
	_allHeroes[tostring(hid)] = nil
end
-- 添加英雄
-- hid -> 被添加的英雄hid
function addHeroWithHid(hid, h_data)
	_allHeroes[tostring(hid)] = h_data

	--add by lichenyang
	haveNewHero(hid, h_data)

	-- 解锁幻化图鉴 add by lgx 20161012
	require "script/ui/turnedSys/HeroTurnedData"
	local htid = h_data.htid
	local heroInfo = HeroTurnedData.getTurnDBInfoById(htid)
	HeroTurnedData.activeTurnByIdAndModelId(htid,heroInfo.model_id)
end
-- 增加英雄天命
function addDestinyByHid( hid )
	print("----------=======")
	print_t(_allHeroes[tostring(hid)])
	_allHeroes[tostring(hid)].destiny = _allHeroes[tostring(hid)].destiny + 1
end
-- 清空英雄天命
function clearDestinyByHid( hid )
	_allHeroes[tostring(hid)].destiny = 0
	if(tonumber(_allHeroes[tostring(hid)].localInfo.id)>=80000)then
		_allHeroes[tostring(hid)].destiny = 20
	end
end
-- 根据英雄htid获得头像
function getHeroHeadIconByHtid(htid)
	require "db/DB_Heroes"
	local data = DB_Heroes.getDataById(htid)
	return "images/base/hero/head_icon/"..data.head_icon_id
end

-- 根据英雄htid判断是否为主角
function isNecessaryHero(htid)
	require "db/DB_Heroes"
	local data = DB_Heroes.getDataById(htid)
	if data == nil then
		require "db/DB_Monsters"
		local monsterInfo = DB_Monsters.getDataById(htid)
		if(monsterInfo ~= nil)then
			local heroInfo = DB_Heroes.getDataById(monsterInfo.htid)
			if heroInfo ~= nil then
				return heroInfo.model_id == 20001 or heroInfo.model_id == 20002
			end
		end
		return false
	else
		return data.model_id == 20001 or data.model_id == 20002
	end
end
-- 通过英雄hid判断是否为主角
function isNecessaryHeroByHid(pHid)
	local htid = _allHeroes[tostring(pHid)].htid

	return isNecessaryHero(htid)
end

-- 获取武将性别
-- return, 1男，2女
function getSex(htid)
	require "db/DB_Heroes"
	local model_id = DB_Heroes.getDataById(htid).model_id
	if model_id == 20001 then
		return 1
	elseif model_id == 20002 then
		return 2
	end
	return -1
end

function changeAvatarInfo( pInfo )
	-- body
	for k,v in pairs(_allHeroes) do
		if(tonumber(k)==tonumber(pInfo.hid))then
			_allHeroes[k] = pInfo
			break
		end
	end
end

--[[
	@des : 得到武将原型id
--]]
function getHeroModelId(htid  )
	require "db/DB_Heroes"
	local model_id = DB_Heroes.getDataById(htid).model_id
	return model_id
end

-- 获取主角的武将信息方法
function getNecessaryHero( ... )
	if _allHeroes == nil then
		return
	end
	for k, v in pairs(_allHeroes) do
		local db_hero = DB_Heroes.getDataById(v.htid)
		if db_hero.model_id == 20001 or db_hero.model_id == 20002 then
			return v
		end
	end
end
-- 设置主角武将的htid
function setNecessaryHeroHtid(pHtid)
	if _allHeroes == nil then
		return
	end
	for k, v in pairs(_allHeroes) do
		local db_hero = DB_Heroes.getDataById(v.htid)
		if db_hero.model_id == 20001 or db_hero.model_id == 20002 then
			_allHeroes[k].htid = pHtid
			return v
		end
	end
end


-- 通过htid获得所有htid相同的当前武将列表
function getAllByHtid(tParam)
	local tArrHeroes = {}
	for k, v in pairs(_allHeroes) do
		if tonumber(v.htid) == tParam.htid then
			table.insert(tArrHeroes, v)
		end
	end
	return tArrHeroes
end

-- 通过武将hid修改武将的进阶等级
function setHeroEvolveLevelByHid( pHid, pLevel )
	_allHeroes[tostring(pHid)].evolve_level = pLevel
end

-- 通过武将hid修改武将等级
function setHeroLevelByHid( pHid, pLevel )
	_allHeroes[tostring(pHid)].level = pLevel
end

--
function setMainHeroLevel(pLevel)
	for k, v in pairs(_allHeroes) do
		local htid = tonumber(v.htid)
		if isNecessaryHero(htid) then
			_allHeroes[k].level=pLevel
			break
		end
	end
end

-- add by chengliang
-- 修改hero身上装备的强化等级
function changeHeroEquipReinforceBy( hid, item_id, addLv )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
	 	if(tonumber( arm_info.item_id ) == item_id) then
	 		local level = tonumber(arm_info.va_item_text.armReinforceLevel) + addLv
	 		_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceLevel"] = tostring(level)
	 		break
	 	end
	 end
	 --刷新装备属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeEquip(hid)
end

--获得空白武将的数量
function getHeroNumberByHtid( htid )
	local countNum = 0
	for k,v in pairs(_allHeroes) do
		--htid
		if tonumber(htid) == tonumber(v.htid) then
			--未锁定
			if not v.lock or tonumber(v.lock) == 0 then
				--level
				if not v.level or tonumber(v.level) <= 1 then
					--evlove_level
					if not v.evlove_level or tonumber(v.evlove_level) <= 1 then
						countNum = countNum + 1
					end
				end
			end
		end
	end
	return countNum
end

-- 通过hid设置武将上锁的状态
-- 如果武将没有锁定  此字段没有  如果锁定 值为1
function setHeroLockStatusByHid(hid, status )
	local heroInfo = getHeroByHid(hid)
	heroInfo.lock = status
end

function getHeroLockStatusByHid( pHid )
	local heroInfo = getHeroByHid(pHid)
	local lockStatus = tonumber(heroInfo.lock) or 0
	return lockStatus
end



-- 通过hid设置武将身上的5星(紫色)装备上锁的状态  add by licong
-- 如果装备没有锁定  lock字段没有  如果锁定 lock值为1
-- p_hid 英雄hid, p_item_id 装备item_id, p_status 状态 1是锁定，0是解锁lock字段赋值nil
function setHeroEquipLockStatusByHid(p_hid, p_item_id, p_status )
	for k, v in pairs(_allHeroes) do
		for pos, arm_info in pairs(_allHeroes[tostring(p_hid)].equip.arming) do
		 	if(tonumber( arm_info.item_id ) == tonumber(p_item_id)) then
		 		if(tonumber(p_status) == 1)then
		 			-- 加锁 1
		 			_allHeroes[tostring(p_hid)].equip.arming[pos]["va_item_text"]["lock"] = tonumber(p_status)
		 		else
		 			-- 解锁 0
		 			_allHeroes[tostring(p_hid)].equip.arming[pos]["va_item_text"]["lock"] = nil
		 		end
		 		break
		 	end
		 end
	end
end

-- add by chengliang
-- 设置hero身上装备的强化等级
function setHeroEquipReinforceLevelBy( hid, item_id, curLv )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
	 	if(tonumber( arm_info.item_id ) == item_id) then
	 		_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceLevel"] = tostring(curLv)
	 		break
	 	end
	 end
end

-- add by chengliang
-- 设置hero身上装备的强化费用
function setHeroEquipReinforceLevelCostBy( hid, item_id, curCost )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
	 	if(tonumber( arm_info.item_id ) == item_id) then
	 		_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"] = tostring(curCost)
	 		break
	 	end
	 end
end

-- add by chengliang
-- 修改hero身上装备的强化等级
function changeHeroEquipReinforceCostBy( hid, item_id, addCost )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
	 	if(tonumber( arm_info.item_id ) == item_id) then
	 		if(_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"])then
	 			_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"] = tostring(tonumber(arm_info.va_item_text.armReinforceLevel) + tonumber(addCost))
	 		else
		 		_allHeroes[tostring(hid)].equip.arming[pos]["va_item_text"]["armReinforceCost"] = tostring(addCost)
		 	end

	 		break
	 	end
	 end
end

function changeHeroEquipDevelopby(hid,item_id,developLv)
	-- body
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
		print("arm_info.item_id==",arm_info.item_id)
		print("item_id==",item_id)
	 	if(tonumber( arm_info.item_id ) == tonumber(item_id)) then
		 	_allHeroes[tostring(hid)].equip.arming[pos].va_item_text.armDevelop = tonumber(developLv)
		 	print("heyyoyoyoyoy",developLv)
		 	print_t(_allHeroes[tostring(hid)].equip.arming[pos])
		 	print("heyyoyoyoyoy",developLv)
	 		break
	 	end
	end
end

-- add by chengliang
-- 卸下武将身上的装备
function removeEquipFromHeroBy( hid, r_pos)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.arming) do
	 	if(tonumber( pos ) == tonumber(r_pos)) then
	 		_allHeroes[tostring(hid)].equip.arming[pos] = "0"
	 		break
	 	end
	end
	--刷新装备属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeEquip(hid)
end

function removePocketFromHeroBy( hid,r_pos )
	_allHeroes[tostring(hid)].equip.pocket[tostring(r_pos)] = "0"
end

-- 卸下武将身上的神兵
function removeGodWeaponFromHeroBy( hid, r_pos)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.godWeapon) do
	 	if(tonumber( pos ) == tonumber(r_pos)) then
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos] = "0"
	 		break
	 	end
	end
	--刷新神兵属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeGodWeapon(hid)
end

-- 检查武将(hid)是否装备了某个装备id(item_template_id)
function checkEquipStatus(pHid, pItid)
	local tArming = _allHeroes[tostring(pHid)].equip.arming
	for k, v in pairs(tArming) do
		if type(v) == "table" then
			if tonumber(v.item_template_id) == tonumber(pItid) then
				return true
			end
		end
	end
	return false
end

-- 检查武将(hid)是否装备了某个宝物(item_template_id)
function checkTreasureStatus(pHid, pItid)
	local tArming = _allHeroes[tostring(pHid)].equip.treasure
	for k, v in pairs(tArming) do
		if type(v) == "table" then
			if tonumber(v.item_template_id) == tonumber(pItid) then
				return true
			end
		end
	end

	return false
end

-- add by chengliang
-- 卸下武将身上的宝物
function removeTreasFromHeroBy( hid, r_pos)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.treasure) do
	 	if(tonumber( pos ) == tonumber(r_pos)) then
	 		_allHeroes[tostring(hid)].equip.treasure[pos] = "0"
	 		break
	 	end
	 end
	 --刷新宝物属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeTreas(hid)
end

-- 为指定hid的武将设置武魂数
function setHeroSoulByHid(pHid, pSoul)
	_allHeroes[tostring(pHid)].soul = pSoul
end

-- 通过武将hid增加进阶等级
function addEvolveLevelByHid(pHid, pAddedLevel)
	_allHeroes[tostring(pHid)].evolve_level = tonumber(_allHeroes[tostring(pHid)].evolve_level) + pAddedLevel
end

-- 通过武将hid修改其htid
function setHtidByHid(pHid, pHtid)
	_allHeroes[tostring(pHid)].htid = pHtid

	-- 进化武将 解锁幻化图鉴 add by lgx 20161012
	require "script/ui/turnedSys/HeroTurnedData"
	local heroInfo = HeroTurnedData.getTurnDBInfoById(pHtid)
	HeroTurnedData.activeTurnByIdAndModelId(pHtid,heroInfo.model_id)
end

-- 判断当前武将数量是否已达上限
-- out: true表示武将数量已达上限，false表示未达上限
function isLimitedCount()
	local nCount = table.count(_allHeroes)
	if nCount >= UserModel.getHeroLimit() then
		return true
	end

	return false
end

-- 交换两个武将的装备信息  -- 程亮
function exchangeEquipInfo( f_hid, s_hid )
	if(f_hid == nil or s_hid == nil) then
		return
	end
	f_hid = tonumber(f_hid)
	s_hid = tonumber(s_hid)

	local f_equipInfo = _allHeroes["" .. f_hid].equip
	_allHeroes["" .. f_hid].equip = _allHeroes["" .. s_hid].equip
	_allHeroes["" .. s_hid].equip = f_equipInfo
end

-- 获得当前所有武将的国家分类数量
-- return. tHeroNumByCountry = {wei=18, shu=56, wu=98, qun=99}
function getHeroNumByCountry( ... )
	require "db/DB_Heroes"
	local nWei=0
	local nShu=0
	local nWu=0
	local nQun=0
	if _allHeroes then
		for k, v in pairs(_allHeroes) do
			local db_hero = DB_Heroes.getDataById(v.htid)
			local countryId = db_hero.country
			if countryId == 1 then
				nWei = nWei + 1
			elseif countryId == 2 then
				nShu = nShu + 1
			elseif countryId == 3 then
				nWu = nWu + 1
			else
				nQun = nQun + 1
			end
		end
	end
	local tHeroNumByCountry = {}
	tHeroNumByCountry.wei = nWei
	tHeroNumByCountry.shu = nShu
	tHeroNumByCountry.wu = nWu
	tHeroNumByCountry.qun = nQun

	return tHeroNumByCountry
end

-- 通过武将的htid和进阶次数计算出该武将的等级上限
-- params: pHtid: 武将的htid, pEvolveLevel: 该武将的进阶等级
-- return: 武将等级上限
function getHeroLimitLevel(pHtid, pEvolveLevel)
	local nLimitLevel = 0
	local nEvolveLevel = pEvolveLevel or 0
	local db_hero = DB_Heroes.getDataById(pHtid)
	if db_hero then
		nLimitLevel = db_hero.strength_limit_lv + tonumber(nEvolveLevel)*db_hero.strength_interval_lv
	end

	return nLimitLevel
end

-- 修改武将身上的装备等级
function addArmLevelOnHerosBy( hid, pos, addLv )
	local enhanceLv = tonumber(_allHeroes["" .. hid].equip.arming["" .. pos].va_item_text.armReinforceLevel) + tonumber(addLv)
	_allHeroes["" .. hid].equip.arming["" .. pos].va_item_text.armReinforceLevel = enhanceLv
	--刷新装备属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeEquip(hid)
end

-- 修改武将身上的宝物等级
function addTreasLevelOnHerosBy( hid, pos, addLv, totalExp )
	local enhanceLv = tonumber(_allHeroes["" .. hid].equip.treasure["" .. pos].va_item_text.treasureLevel) + tonumber(addLv)
	_allHeroes["" .. hid].equip.treasure["" .. pos].va_item_text.treasureLevel = enhanceLv
	_allHeroes["" .. hid].equip.treasure["" .. pos].va_item_text.treasureExp = totalExp
	--刷新宝物属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeTreas(hid)
end

-- 修改武将身上的战魂等级
function addFSLevelOnHerosBy( hid, pos, cruLv, totalExp )
	_allHeroes["" .. hid].equip.fightSoul["" .. pos].va_item_text.fsLevel = cruLv
	_allHeroes["" .. hid].equip.fightSoul["" .. pos].va_item_text.fsExp = totalExp
	--刷新战魂属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeFightSoul(hid)
end

--[[
	@des 	:修改战魂精炼等级
	@param 	:p_hid:英雄hid p_pos:战魂装备位置, p_evolveLv:洗练等级
	@return :
--]]
function changeHeroFightSoulEvolveLv( p_hid, p_pos, p_evolveLv)
	_allHeroes["" .. p_hid].equip.fightSoul["" .. p_pos].va_item_text.fsEvolve = p_evolveLv
	--刷新战魂属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeFightSoul(p_hid)
end

-- 修改武将身上的时装等级
function addFashionLevelOnHerosBy( hid, pos, cruLv )
	_allHeroes["" .. hid].equip.dress["" .. pos].va_item_text.dressLevel = cruLv
	--刷新时装属性
	require "script/model/affix/DressAffixModel"
	DressAffixModel.getAffixByHid(hid, true)
	DressAffixModel.getUnLockAffix(true)
end

-- 通过item_template_id获取武魂当前数量和需要的数量
-- return. {item_num=物品实际数量, need_num=物品需要的数量}
function getNumByItemTemplateId(pItemTemplateId)
	local tRetValue = {item_num=0, need_num=0}

	local tHeroFrag = DataCache.getHeroFragFromBag()
	if not tHeroFrag then
		return tRetValue
	end

	for k,v in pairs(tHeroFrag) do
		if tonumber(v.item_template_id) == tonumber(pItemTemplateId) then
			tRetValue.item_num = tonumber(v.item_num)
			break
		end
	end
	if tRetValue.item_num > 0 then
		require "db/DB_Item_hero_fragment"
		local heroFragment = DB_Item_hero_fragment.getDataById(pItemTemplateId)
		tRetValue.need_num = heroFragment.need_part_num
	end

	return tRetValue
end


function setHeroFixedPotentiality( item_id ,potentiality_info )
	for k,v in pairs(_allHeroes) do
		for kh,vh in pairs(v.equip.arming) do
			if(tonumber(vh) ~= 0) then
				if(tonumber(vh.item_id) == tonumber(item_id)) then
					_allHeroes[tostring(k)].equip.arming[tostring(kh)].va_item_text.armFixedPotence = potentiality_info
					print(GetLocalizeStringBy("key_3082"))
					break
				end
			end
		end
	end
end

function setHeroPotentiality( item_id)
	for k,v in pairs(_allHeroes) do
		for kh,vh in pairs(v.equip.arming) do
			if(tonumber(vh)  ~= 0) then
				if(tonumber(vh.item_id) == tonumber(item_id)) then
					_allHeroes[tostring(k)].equip.arming[tostring(kh)].va_item_text.armPotence = vh.va_item_text.armFixedPotence
					_allHeroes[tostring(k)].equip.arming[tostring(kh)].va_item_text.armFixedPotence = nil
					print(GetLocalizeStringBy("key_3082"))
					--刷新装备属性
					require "script/model/hero/HeroAffixFlush"
					HeroAffixFlush.onChangeEquip(v.hid)
					break
				end
			end
		end
	end
end

--[[
	@设置宝物精炼等级
--]]
function setTreasureEvolveLevel( item_id, evolve_level )
	for k,v in pairs(_allHeroes) do
		for kh,vh in pairs(v.equip.treasure) do
			if(tonumber(vh)  ~= 0) then
				if(tonumber(vh.item_id) == tonumber(item_id)) then
					_allHeroes[tostring(k)].equip.treasure[tostring(kh)].va_item_text.treasureEvolve = evolve_level
					--刷新宝物属性
					require "script/model/hero/HeroAffixFlush"
					HeroAffixFlush.onChangeTreas(v.hid)
					break
				end
			end
		end
	end
end

--[[
	@des 	:	记忆新获得武将
	@params	:	hid 武将id
	@return :
--]]
function haveNewHero( hid, hero_info )
	require "db/DB_Heroes"
	local heroStraLv = DB_Heroes.getDataById(hero_info.htid).star_lv
	if(tonumber(heroStraLv) < 4) then
		return
	end

	if(newHeroTable == nil) then
		--从本地读取
		local newHeroBuffer = CCUserDefault:sharedUserDefault():getStringForKey("hava_new_hero_table")
		if(newHeroBuffer == nil or newHeroBuffer == "") then
			newHeroTable 				= {}
		else
			newHeroTable 		= table.unserialize(newHeroBuffer)
		end
	end
	newHeroTable[tostring(hid)] = true
	local serializeBuffer 		= table.serialize(newHeroTable)
	CCUserDefault:sharedUserDefault():setStringForKey("hava_new_hero_table", serializeBuffer)
	CCUserDefault:sharedUserDefault():flush()

	--主界面武将按钮new 特效
	require "script/ui/main/MainBaseLayer"
	MainBaseLayer.addNewHeroButton()
	bHaveNewHero = true
end

--[[
	@des 	:	删除持久化的新英雄
	@params	:	hid 武将id
--]]
function removeHavaNewHero( hid )
	if(newHeroTable == nil) then
		return
	end
	newHeroTable[tostring(hid)] = nil
	local serializeBuffer 		= table.serialize(newHeroTable)
	CCUserDefault:sharedUserDefault():setStringForKey("hava_new_hero_table", serializeBuffer)
	CCUserDefault:sharedUserDefault():flush()
end

--[[
	@des 	:	清楚所有标志为新的英雄
]]
function clearAllNewHeroSign()
	newHeroTable = nil
	CCUserDefault:sharedUserDefault():setStringForKey("hava_new_hero_table", "")
	CCUserDefault:sharedUserDefault():flush()
end


--[[
	@des 	:	判断武将是否是新武将
	@params	:	hid 武将id
--]]
function isNewHero( hid )
	if(newHeroTable == nil) then
		return false
	end

	if(newHeroTable[tostring(hid)] == true) then
		return true
	else
		return false
	end
end


--[[
	@des 	:	是否拥有新武将
]]
function isHaveNewHero()
	if(newHeroTable ~= nil) then
		return true
	else
		return false
	end
end

function isShowHeroTip( ... )
	local ret = false
	require "script/ui/hero/HeroLayer"
	require "script/ui/hero/HeroSoulLayer"
	local isEnterHeroBag = HeroLayer.getIsEnter()
	if HeroSoulLayer.getFuseSoulNum()>0 and not isEnterHeroBag then
		ret = true
	end
	return ret
end


--[[
	@des 	: 初始化缓存数据
--]]
function initNewHero( ... )
 	if(newHeroTable == nil) then
		--从本地读取
		local newHeroBuffer = CCUserDefault:sharedUserDefault():getStringForKey("hava_new_hero_table")
		if(newHeroBuffer == nil or newHeroBuffer == "") then
			newHeroTable 				= nil
		else
			newHeroTable 		= table.unserialize(newHeroBuffer)
		end
	end
	if(isHaveNewHero()) then
		bHaveNewHero = true
	else
		bHaveNewHero = false
	end
end


--------------------------------------------------------------------------- 战魂战斗力计算方法 ------------------------------------------------------------------
local _allSoulAttr 				= {} -- 缓存 { [hid] = { id = value }, }  key全部都number类型

--[[
	@des 	:得到装备战魂的属性值 用于战斗力
	@param 	: f_hid  p_isForce 是否重新计算 true重新计算
	@return :阵容上装备战魂的属性 
--]]
function getHeroFightSoulAffix( p_hid, p_isForce )
    -- if(p_hid == nil)then
    --     return {}
    -- end
    -- require "script/ui/huntSoul/HuntSoulData"
    -- local affixs      = {}
    -- local heroInfo = getHeroByHid(tostring(p_hid))
    -- if(heroInfo.equip.fightSoul == nil) then
    --     return affixs
    -- end
    -- for k,v in pairs(heroInfo.equip.fightSoul) do
    --     if not table.isEmpty(v) then
    --         local affixInfo = HuntSoulData.getFightSoulAttrByItem_id(v.item_id)
    --         for key,value in pairs(affixInfo) do
    --             if(affixs[key] == nil) then
    --                 affixs[key] = {}
    --             end
    --             affixs[key].desc = value.desc.displayName
    --             if(affixs[key].realNum == nil) then
    --                 affixs[key].realNum = tonumber(value.realNum)
    --             else
    --                 affixs[key].realNum = tonumber(value.realNum) + tonumber(affixs[key].realNum)
    --             end
    --             if(affixs[key].displayNum == nil) then
    --                 local tempAffix = nil
    --                 tempAffix, affixs[key].displayNum = ItemUtil.getAtrrNameAndNum(key, affixs[key].realNum)
    --             else
    --                 local tempAffix = nil
    --                 tempAffix, affixs[key].displayNum =  ItemUtil.getAtrrNameAndNum(key, affixs[key].realNum) --tonumber(affixs[key].displayNum) + value.displayNum
    --             end
    --         end
    --     end
    -- end
    -- return affixs


    local retTab = {}
	local hid = tonumber(p_hid)
	if(p_isForce ~= true and not table.isEmpty(_allSoulAttr[hid]) )then
		-- 优先返回缓存
		retTab = _allSoulAttr[hid]
		return retTab
	end

	-- 重新计算

	if(hid ~= nil and hid > 0 )then
		require "script/ui/huntSoul/HuntSoulData"
	    local tempSoul = HeroUtil.getFightSoulByHid( hid )
		if(not table.isEmpty(tempSoul))then
			for k,v in pairs(tempSoul) do
	            local attrInfo = HuntSoulData.getSoulFightForce(v)
	            for id,affixValue in pairs(attrInfo) do
					if( retTab[tonumber(id)] == nil)then
						retTab[tonumber(id)] = tonumber(affixValue)
					else
						retTab[tonumber(id)] = retTab[tonumber(id)] + tonumber(affixValue)
					end
				end
	        end
	    end
		_allSoulAttr[hid] = retTab
	end
	print("===>1")
	print_t(retTab)
	return retTab
end


--[[
	@des:得到武将详细属性
--]]
function getShowHeroDetailAffix( p_hid, p_htid )
	local retTable = {}
	require "db/DB_Normal_config"
	require "db/DB_Affix"
	require "script/model/affix/HeroAffixModel"
	require "script/model/hero/FightForceModel"

	if p_hid then
		heroAffix = FightForceModel.getHeroDisplayAffix(p_hid)
	else
		heroAffix = FightForceModel.getHeroBaseDisplayAffix(p_htid)
	end
	local heroDetailAffixIds = string.split(DB_Normal_config.getDataById(1).heroDetailedAffix, ",")
	for i,v in ipairs(heroDetailAffixIds) do
		local affix = {}
		local tempAffix = nil
		affix.name = DB_Affix.getDataById(v).displayName
		if(heroAffix[tonumber(v)] == nil) then
			affix.value = 0
		else
			tempAffix, affix.value = ItemUtil.getAtrrNameAndNum(v, tonumber(heroAffix[tonumber(v)]))
			affix.value = affix.value or 0
		end
		table.insert(retTable, affix)
	end
	return retTable
end


--经验宝物过滤列表
local _expTreasIds = {
	501001,
	501002,
	502001,
	502002,
	501010,
	503001,
	503002,
}
--[[
	@des: 得到战马品质
--]]
function getHorseQuality( p_hid )
	require "db/DB_Item_treasure"
	local heroInfo = getHeroByHid(p_hid)
	local treasureInfo = heroInfo.equip.treasure
	local horseTid = nil
	if(treasureInfo["1"] ~= nil and treasureInfo["1"].item_template_id ~= nil) then
		horseTid = treasureInfo["1"].item_template_id
		for k,v in pairs(_expTreasIds) do
			if(tonumber(horseTid) == v) then
				return 0
			end
		end
		local quality = ItemUtil.getTreasureQualityByItemInfo(treasureInfo["1"])
		return quality
	else
		return 0
	end
end

--[[
	@des: 得到兵书品质
--]]
function getBookQuality( p_hid )
	require "db/DB_Item_treasure"
	local heroInfo = getHeroByHid(p_hid)
	local treasureInfo = heroInfo.equip.treasure
	local bookTid = nil
	if(treasureInfo["2"] ~= nil and treasureInfo["2"].item_template_id ~= nil) then
		bookTid = treasureInfo["2"].item_template_id
		for k,v in pairs(_expTreasIds) do
			if(tonumber(bookTid) == v) then
				return 0
			end
		end
		local quality = ItemUtil.getTreasureQualityByItemInfo(treasureInfo["2"])
		return quality
	else
		return 0
	end
end

--[[
	@des 	:根据hid把武将设置成p_heroInfo的内容 added by Zhang Zihang
	@param 	:$ p_hid 		:武将hid
	@param 	:$ p_heroInfo 	:要替换的武将信息
	@return :
--]]
function setHeroByHid(p_hid,p_heroInfo)
	_allHeroes[tostring(p_hid)] = p_heroInfo
end
--[[
	@des 	:根据hid获取武将是物攻型还是法攻型  add by DJN  2014/11/12
	@param 	:$ p_hid 		:武将hid
	@param 	:
	@return : 1表示物攻、2表示法攻。
--]]
function getHerotypeByHid(p_hid)
	require "db/DB_Heroes"
	--print("传进来的hid",p_hid)

	local heroAllInfo = nil
	local allHeros = HeroModel.getAllHeroes()

	for t_hid, t_hero in pairs(allHeros) do

		if( tonumber(t_hid) ==  tonumber(p_hid)) then
			heroAllInfo = t_hero
			break
		end
	end
	--print("解析后的htid",heroAllInfo.htid)
	local heroType = DB_Heroes.getDataById(tonumber(heroAllInfo.htid)).herotype
	return heroType
end
--[[
	@des 	:根据hid获取htid
	@param 	:$ p_hid 		:武将hid
	@param 	:
	@return : 1表示物攻、2表示法攻。
--]]
function getHtidByHid(p_hid)
	require "db/DB_Heroes"
	print("传进来的hid",p_hid)

	local heroAllInfo = nil
	local allHeros = HeroModel.getAllHeroes()

	for t_hid, t_hero in pairs(allHeros) do

		if( tonumber(t_hid) ==  tonumber(p_hid)) then
			heroAllInfo = t_hero
			break
		end
	end
	print("解析后的htid",heroAllInfo.htid)
	return heroAllInfo.htid
end

------------------------------------------------------------------------ 修改英雄身上神兵缓存数据 --------------------------------------------------------------------------
--[[
	@des 	:修改神兵等级，总经验
	@param 	:hid英雄hid p_item_id:神兵itemId,p_curLv当前等级, p_totalExp当前全部经验 p_addSilver:强化花费费用
	@return :
--]]
function changeHeroGodWeaponReinforceBy( hid,  p_itemId, p_curLv, p_totalExp, p_addSilver )
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.godWeapon) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_itemId)) then
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.reinForceLevel = tostring(p_curLv)
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.reinForceExp = tostring(p_totalExp)
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.reinForceCost = tostring( tonumber(_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.reinForceCost) + tonumber(p_addSilver) )
	 		break
	 	end
	end

	--刷新神兵属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeGodWeapon(hid)
end

--修改人身上神兵信息
function changeHeroGodWeaponEvolveNumBy(hid,p_itemId,curLv,p_curLv,p_totalExp)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.godWeapon) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_itemId)) then
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.reinForceLevel = tostring(p_curLv)
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.reinForceExp = tostring(p_totalExp)
	 		_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.evolveNum = tostring(curLv)
	 		break
	 	end
	end
	--刷新神兵属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeGodWeapon(hid)
end

--[[
	@des 	:修改神兵洗练可替换属性
	@param 	:hid英雄hid p_item_id:神兵itemId,p_fixId:第几层,p_attrId:可替换属性信息
	@return :
--]]
function changeHeroGodWeaponToConfirmBy( hid,p_itemId, p_fixId, p_attrId)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.godWeapon) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_itemId)) then
	 		if( not table.isEmpty(_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.toConfirm) )then
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.toConfirm[tostring(p_fixId)] = p_attrId
	 		else
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.toConfirm = {}
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.toConfirm[tostring(p_fixId)] = p_attrId
	 		end
	 		break
	 	end
	end
end

--[[
	@des 	:修改神兵洗练已替换属性
	@param 	:hid英雄hid p_item_id:神兵itemId,p_fixId:第几层,p_attrId:已替换属性信息
	@return :
--]]
function changeHeroGodWeaponConfirmedBy( hid, p_itemId, p_fixId, p_attrId)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.godWeapon) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_itemId)) then
	 		if( not table.isEmpty(_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.confirmed) )then
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.confirmed[tostring(p_fixId)] = p_attrId
	 		else
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.confirmed = {}
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.confirmed[tostring(p_fixId)] = p_attrId
	 		end
	 		break
	 	end
	end

	--刷新神兵属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeGodWeapon(hid)
end

--[[
	@des 	:修改神兵批量洗练洗练可替换属性
	@param 	:hid英雄hid p_item_id:神兵itemId,p_fixId:第几层,p_attrIdTab:可替换属性信息table
	@return :
--]]
function changeHeroGodWeaponBatchBy( hid,p_itemId, p_fixId, p_attrIdTab)
	for pos, arm_info in pairs(_allHeroes[tostring(hid)].equip.godWeapon) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_itemId)) then
	 		if( not table.isEmpty(_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.btc) )then
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.btc[tostring(p_fixId)] = p_attrIdTab
	 		else
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.btc = {}
	 			_allHeroes[tostring(hid)].equip.godWeapon[pos].va_item_text.btc[tostring(p_fixId)] = p_attrIdTab
	 		end
	 		break
	 	end
	end
end

--------------------------------------------------------------------------- 修改宝物镶嵌信息 ---------------------------------------------------------------
--[[
	@des 	:修改宝物镶嵌的符印信息
	@param 	:p_hid:英雄hid p_treasureItemId:宝物id, p_runeItemInfo:符印信息, p_index:第几个位置
	@return :
--]]
function changeHeroTreasureRuneBy( p_hid,p_treasureItemId, p_runeItemInfo, p_index)
	for pos, arm_info in pairs(_allHeroes[tostring(p_hid)].equip.treasure) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_treasureItemId)) then
	 		if( not table.isEmpty(_allHeroes[tostring(p_hid)].equip.treasure[pos].va_item_text.treasureInlay) )then
	 			_allHeroes[tostring(p_hid)].equip.treasure[pos].va_item_text.treasureInlay[tostring(p_index)] = p_runeItemInfo
	 		else
	 			_allHeroes[tostring(p_hid)].equip.treasure[pos].va_item_text.treasureInlay = {}
	 			_allHeroes[tostring(p_hid)].equip.treasure[pos].va_item_text.treasureInlay[tostring(p_index)] = p_runeItemInfo
	 		end
	 		-- print("==>>>>>>>")
	 		-- print_t(_allHeroes[tostring(p_hid)].equip.treasure[pos])
	 		break
	 	end
	end
	--刷新宝物属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeTreas(p_hid)
end

--[[
	@des 	:修改宝物进阶信息
	@param 	:p_hid:英雄hid p_treasureItemId:宝物id, p_treasureDevelop:进阶次数
	@return :
--]]
function changeHeroTreasureDevelopBy( p_hid,p_treasureItemId, p_treasureDevelop)
	for pos, arm_info in pairs(_allHeroes[tostring(p_hid)].equip.treasure) do
	 	if(tonumber( arm_info.item_id ) == tonumber(p_treasureItemId)) then
	 		_allHeroes[tostring(p_hid)].equip.treasure[pos].va_item_text.treasureDevelop = p_treasureDevelop
	 		break
	 	end
	 end
	 --刷新宝物属性
	require "script/model/hero/HeroAffixFlush"
	HeroAffixFlush.onChangeTreas(p_hid)
	--刷新羁绊信息
	UnionProfitUtil.refreshUnionProfitInfo()
end

--清空某个武将重生后的丹药信息
function clearPillInfoByHid( p_hid )
	if(  table.isEmpty(_allHeroes[tostring(p_hid)]) == false)then
		_allHeroes[tostring(p_hid)].pill = {}
	end
end

--[[
	@des:计算武将背包开启价钱
--]]
function getOpenHeroBagCost()
	local function fnCaculateCost(times)
		if times <=0 then
			return 0
		end
		if times == 1 then
			return 25
		end
		return fnCaculateCost(times-1)+25
	end
	-- 需要花费金币
	local nGoldCost = fnCaculateCost((UserModel.getHeroLimit()-100)/5 + 1)
	return nGoldCost
end


------------------------------------------------------------------------ 修改英雄身上锦囊缓存数据 --------------------------------------------------------------------------
--[[
	@des 	:修改神兵等级，总经验
	@param 	:hid英雄hid p_item_id:神兵itemId,p_curLv当前等级, p_totalExp当前全部经验 p_addSilver:强化花费费用
	@return :
--]]
function changeHeroPocketBy( hid, pos, pInfo)
	_allHeroes[tostring(hid)].equip.pocket[tostring(pos)] = {}
	_allHeroes[tostring(hid)].equip.pocket[tostring(pos)] = pInfo
	print("~~~~~~~~",pos)
	print_t(pInfo)
	print("~~~~~~~~",pos)
end

function changeHeroPocketLockStatus( hid, pos )
	-- body
	if(_allHeroes[tostring(hid)].equip.pocket[tostring(pos)].va_item_text.lock)then
		_allHeroes[tostring(hid)].equip.pocket[tostring(pos)].va_item_text.lock = nil
	else
		_allHeroes[tostring(hid)].equip.pocket[tostring(pos)].va_item_text.lock = 1
	end
end

-- added by bzx
function haveTalent(p_hid)
	local heroData = getHeroByHid(p_hid)
	return heroData.talent ~= nil and not table.isEmpty(heroData.talent.confirmed)
end
--根据武将hid判断这个武将是否满足进入丹药系统功能
function isHeroCanPill(p_hid )
	if not DataCache.getSwitchNodeState( ksSwitchDrug,false )then
		return false
	end
    local retData = isCanPill(p_hid)
    return retData
end

-- 该武将是否能装备丹药
function isCanPill( p_hid )
	local isCan = false
	local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
    if heroInfo and 
        heroInfo.localInfo.potential >= 5 and 
        ( tonumber(heroInfo.evolve_level) >= 1 or  tonumber(heroInfo.localInfo.star_lv) >= 6) then
        isCan = true
    end
	return isCan
end

--根据武将hid判断这个武将当前是否有服用丹药
function isHeroPillOn(p_hid)
	if(  not table.isEmpty(_allHeroes[tostring(p_hid)]) and not table.isEmpty(_allHeroes[tostring(p_hid)].pill) )then
		for k_typeId,v_info in pairs(_allHeroes[tostring(p_hid)].pill)do
			if not table.isEmpty(v_info) then
				for k_pillId,v_num in pairs(v_info)do
					if tonumber(v_num) >0 then
						return true
					end
				end
			end
		end
	end
	return false
end

--得到武将的觉醒能力
function getMasterTalentId( pHid, pPos)
	local heroInfo = getHeroByHid(pHid)
	local awakeId = nil
	if heroInfo.masterTalent then
		awakeId = heroInfo.masterTalent[tostring(pPos)]
	end
	return tonumber(awakeId)
end
--修改武将的觉醒能力
function setMasterTalentId( pHid, pPos, pId )
	local heroInfo = getHeroByHid(pHid)
	heroInfo.masterTalent = heroInfo.masterTalent or {}
	heroInfo.masterTalent[tostring(pPos)] = pId
end

---------------------------------------------------修改英雄身上的兵符缓存数据---------------------------------------------------

--[[
	@des 	: 修改武将身上的兵符强化等级
	@param 	: 
	@return : 
--]]
function changeHeroTallyLvBy( hid,  p_itemId, p_curLv, p_totalExp )
	for pos, v_info in pairs(_allHeroes[tostring(hid)].equip.tally) do
	 	if(tonumber( v_info.item_id ) == tonumber(p_itemId)) then
	 		_allHeroes[tostring(hid)].equip.tally[pos].va_item_text.tallyLevel = tostring(p_curLv)
	 		_allHeroes[tostring(hid)].equip.tally[pos].va_item_text.tallyExp = tostring(p_totalExp)
	 		break
	 	end
	end
end

--[[
	@des 	: 修改武将身上的兵符进阶等级
	@param 	: 
	@return : 
--]]
function changeHeroTallyDevLvBy( hid,  p_itemId, p_curLv )
	for pos, v_info in pairs(_allHeroes[tostring(hid)].equip.tally) do
	 	if(tonumber( v_info.item_id ) == tonumber(p_itemId)) then
	 		_allHeroes[tostring(hid)].equip.tally[pos].va_item_text.tallyDevelop = tostring(p_curLv)
	 		break
	 	end
	end
end

--[[
	@des 	: 修改武将身上的兵符精炼等级
	@param 	: 
	@return : 
--]]
function changeHeroTallyEvolveLvBy( hid,  p_itemId, p_curLv )
	for pos, v_info in pairs(_allHeroes[tostring(hid)].equip.tally) do
	 	if(tonumber( v_info.item_id ) == tonumber(p_itemId)) then
	 		_allHeroes[tostring(hid)].equip.tally[pos].va_item_text.tallyEvolve = tostring(p_curLv)
	 		break
	 	end
	end
end

--[[
	@des 	: 根据英雄信息获取英雄显示名字
	@param 	: 
	@return : 
--]]
function getHeroName( pHeroInfo )
	if HeroModel.isNecessaryHero(pHeroInfo.htid) then
		return UserModel.getUserName()
	end
	local haveNextSpecial = false
	require "db/DB_Heroes"
	require "db/DB_Monsters_tmpl"
	local dbInfo = DB_Heroes.getDataById(pHeroInfo.htid)
	if not dbInfo then
		dbInfo = DB_Monsters_tmpl.getDataById(pHeroInfo.htid)
	end
	if( not dbInfo)then
		require "db/DB_Monsters"
		local htid = DB_Monsters.getDataById(pHeroInfo.htid).htid
		dbInfo = DB_Monsters_tmpl.getDataById(htid)
	end
	local dbData = string.split(dbInfo.destinyName,",")
	local str = ""
	for j=1,table.count(dbData)do
		local dbData1 = string.split(dbData[j],"|")
		if(tonumber(dbData1[1])<=tonumber(pHeroInfo.destiny))then
			haveNextSpecial = true
			str = dbData1[2]
		end
	end
	if(haveNextSpecial==false)then
		return dbInfo.name
	end
	return str
end

--------------------------------------------------- 修改主角身上的战车缓存数据 ---------------------------------------------------
--[[
	@desc	: 获取主角身上的战车信息
    @param	: 
    @return	: table {pos => chariotInfo} 战车信息
—]]
function getMasterHeroChariotInfo()
	local masterHeroInfo = getNecessaryHero()
	local arrChariot = masterHeroInfo.equip.chariot
	local chariotEquipInfo = {}
	if (not table.isEmpty(arrChariot)) then
		require "script/ui/chariot/ChariotMainData"
		for k,v in pairs(arrChariot) do
			if (not table.isEmpty(v)) then
				local chariotInfo = ChariotMainData.parseNetChariot(v)
				chariotEquipInfo[tonumber(k)] = chariotInfo
			end
		end
	end

	print("---------------getMasterHeroChariotInfo-----------------")
	print_t(chariotEquipInfo)
	print("---------------getMasterHeroChariotInfo-----------------")

	return chariotEquipInfo
end

--[[
	@desc	: 修改主角身上的战车信息
    @param	: pPos 战车装备位置
    @param 	: pChariotInfo 战车信息
    @return	:  
—]]
function changeMasterHeroChariotByPos( pPos, pChariotInfo )
	local masterHeroInfo = getNecessaryHero()
	local arrChariot = masterHeroInfo.equip.chariot
	if (arrChariot) then
		arrChariot[tostring(pPos)] = pChariotInfo
	end

	print("---------------changeMasterHeroChariotByPos-----------------")
	print_t(arrChariot)
	print("---------------changeMasterHeroChariotByPos-----------------")
end
