-- Filename：	DataCache.lua
-- Author：		Cheng Liang
-- Date：		2013-6-21
-- Purpose：		数据中心


module ("DataCache", package.seeall)
require "script/utils/LuaUtil"
require "script/ui/item/ItemUtil"
require "script/ui/bag/BagUtil"
require "script/ui/formation/LittleFriendData"
require "script/ui/shop/ShopUtil"
require "script/ui/chariot/ChariotMainData"

local _normalCopyCache 	= nil	-- 普通副本
local _eliteCopyCache 	= nil	-- 精英副本
local _activeCopyCache 	= nil	-- 活动副本
local _heroCopyCache 	= nil	-- 列传副本
--
local _formationInfo 	= nil	-- 阵型

local _bagInfo 			= nil	-- 背包
local _squadInfo 		= nil	-- 阵容

local _starCache 		= nil	-- 名仕

local _lieCache 		= nil   -- 列传

local _shopCache 		= nil	-- 商店信息

local _switchCache 		= nil	-- 功能节点开启信息

local _newNormalCopyId 	= nil 	-- 新开启的副本

local _bossTreeLevel    = nil   -- 摇钱树等级备份

local _isBagChanged 	= true 	-- 背包是否有变化，是否需要排序

local _allBagInfo 		= {} 	-- 合并的背包



-------------------------------------- 副本 -------------------------------------
-- 获得新开起的副本
function getNewNormalCopyId()
	return _newNormalCopyId
end
-- 设置新开启的副本
function setNewNormalCopyId(newNormalCopyId)
	_newNormalCopyId = newNormalCopyId
end

-- 普通副本
function getNormalCopyData( )

	local data = {}
	if (not table.isEmpty(_normalCopyCache)) then
		local copyList = _normalCopyCache.copy_list
		local function keySort ( key_1, key_2 )
		   	return tonumber(key_1) < tonumber(key_2)
		end
		local allKeys = table.allKeys(copyList)
		table.sort( allKeys, keySort )
		require "db/DB_Copy"
		for k,keyIndex in pairs(allKeys) do
			local tbl = copyList[keyIndex]
			tbl.copyInfo = DB_Copy.getDataById(tbl.copy_id)
			table.insert(data, tbl)
		end
		local copy_len = table.count(data)
		if(copy_len<CopyUtil.getMaxCopyId())then
			print("copy_len<CopyUtil.getMaxCopyId()====", copy_len, CopyUtil.getMaxCopyId())
			local tbl = {}
			tbl.uid = UserModel.getUserUid()
			tbl.copy_id = copy_len + 1
			tbl.score = 0
			tbl.prized_num = 0
			tbl.isGray = true
			tbl.va_copy_info = {}
			tbl.va_copy_info.progress = {}
			tbl.va_copy_info.defeat_num = {}
			tbl.va_copy_info.reset_num = {}
			tbl.copyInfo = DB_Copy.getDataById(tbl.copy_id)

			table.insert(data, tbl)
		end
	end

	return data
end
--
function setNormalCopyData( normalCopyData )
	_normalCopyCache = normalCopyData
	if(normalCopyData.sweep_cd)then
        _normalCopyCache.sweep_cool_time = TimeUtil.getSvrTimeByOffset()+tonumber(normalCopyData.sweep_cd)
    end
end

-- 列传副本-LLp-2014-4-22
-- function getHeroCopyData( )

-- 	local data = {}
-- 	print("!!!!!~~~~~~")
-- 	if (not table.isEmpty(_heroCopyCache)) then
-- 		print("~~~~~~!!!!!")
-- 		require "db/DB_Hero_copy"
-- 		_heroCopyCache.copyInfo = DB_Hero_copy.getDataById(_heroCopyCache.copyid)
-- 		table.insert(data, _heroCopyCache)

-- 		-- local copy_len = table.count(data)
-- 		-- if(copy_len<CopyUtil.getMaxHeroCopyId())then
-- 		-- 	print("~!")
-- 		-- 	local tbl = {}
-- 		-- 	tbl.uid = UserModel.getUserUid()
-- 		-- 	tbl.copy_id = copy_len + 1
-- 		-- 	tbl.isGray = true
-- 		-- 	tbl.va_copy_info = {}
-- 		-- 	tbl.va_copy_info.progress = {}
-- 		-- 	tbl.copyInfo = DB_Hero_copy.getDataById(tbl.copy_id)

-- 		-- 	table.insert(data, tbl)
-- 		-- end
-- 	end

-- 	return data
-- end
--
-- function setHeroCopyData( normalCopyData )
-- 	_heroCopyCache = normalCopyData
-- end

-- 获得重置cd次数
function getClearSweepNum()
	return tonumber(_normalCopyCache.clear_sweep_num)
end
-- 设置得重置cd次数
function addClearSweepNum(cd_times)
	_normalCopyCache.clear_sweep_num = tonumber(_normalCopyCache.clear_sweep_num)+tonumber(cd_times)
end

-- 获取副本扫荡的cd时间
function getSweepCoolTime()
	return _normalCopyCache.sweep_cool_time
end
-- 设置副本扫荡的cd时间
function setSweepCoolTime( cd_time)
    _normalCopyCache.sweep_cool_time = TimeUtil.getSvrTimeByOffset()+tonumber(cd_time)
end

-- 只拿出副本信息
function setNormalCopyList( copyList )
	_normalCopyCache.copy_list = copyList
end

function getReomteNormalCopyData()
	local copy_list = {}
	if(not table.isEmpty(_normalCopyCache))then
		copy_list = _normalCopyCache.copy_list
	end
	return copy_list
end
--列传
function getReomteHeroCopyData()
	local copy_list = {}
	if(not table.isEmpty(_heroCopyCache))then
		copy_list = _heroCopyCache
	end
	return copy_list
end
-- 修改副本的宝箱状态
function changeCopyBoxStatus( copy_id, prized_num )
	for k, copy_info in pairs(_normalCopyCache.copy_list) do
		if(tonumber(copy_info.copy_id) == tonumber(copy_id))then
			_normalCopyCache.copy_list[k].prized_num = "" .. prized_num
			break
		end
	end
end

-- 精英副本
function getEliteCopyData( )
	local data = {}
	if (_eliteCopyCache and _eliteCopyCache.va_copy_info) then
		require "db/DB_Elitecopy"

		--对获取到的数据进行转换
		for copyIdStr, status in pairs(_eliteCopyCache.va_copy_info.progress) do
			local tbl = {}
			tbl.copyInfo = DB_Elitecopy.getDataById(tonumber(copyIdStr))
			tbl.copyInfo.status = tonumber(status)
			table.insert(data, tbl)
		end
		data.can_defeat_num = tonumber(_eliteCopyCache.can_defeat_num)

		-- added by zhz ,购买攻击次数的次数
		data.buy_atk_num= tonumber(_eliteCopyCache.buy_atk_num)
	end
	local function keySort (  copyInfo_1, copyInfo_2 )
	   	return tonumber(copyInfo_1.copyInfo.id) < tonumber(copyInfo_2.copyInfo.id)
	end
	table.sort( data, keySort )
	return data
end
function setEliteCopyData( eliteCopyData )
	_eliteCopyCache = eliteCopyData
end
-- 减少精英副本的攻打次数
function addCanDefatNum(num)
	_eliteCopyCache.can_defeat_num = _eliteCopyCache.can_defeat_num + num
end
--[[
    @des    : 获取精英副本的攻打次数
    @param  : 
    @return : 
--]]
function getCanDefatNum( ... )
	return _eliteCopyCache.can_defeat_num
end

-- added by zhz,增加可以攻击的次数
function addBuyAtkNum(num)
	_eliteCopyCache.buy_atk_num = _eliteCopyCache.buy_atk_num + num
end

-- 活动副本
function getActiveCopyData()
	local data = {}
	if (_activeCopyCache) then

		local function keySort ( key_1, key_2 )
		   	return tonumber(key_1) > tonumber(key_2)
		end
		local allKeys = table.allKeys(_activeCopyCache)
		table.sort( allKeys, keySort )
		require "db/DB_Activitycopy"
		for k,keyIndex in pairs(allKeys) do
			local tbl = _activeCopyCache[keyIndex]
			tbl.copyInfo = DB_Activitycopy.getDataById(tbl.copy_id)
			table.insert(data, tbl)
		end
	end
	return data
end
function setActiveCopyData( activeCopyData )
	_activeCopyCache = activeCopyData
end

function getAcopyData()
	return _activeCopyCache
end




-- 修改经验熊猫活动的剩余次数
function addHeroExpDefeatNum( add_times )
	add_times = tonumber(add_times) or 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300004 )then
				_activeCopyCache[copy_id].can_defeat_num = tonumber(_activeCopyCache[copy_id].can_defeat_num) + add_times
				break
			end
		end
	end
end

-- 获得经验熊猫活动的剩余次数
function getHeroExpDefeatNum()
	local defautNum = 0

	if( CopyUtil.isHeroExpCopyOpen() and  (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300004 )then
				defautNum = tonumber(_activeCopyCache[copy_id].can_defeat_num)
				break
			end
		end
	end

	return defautNum
end

-- 修改经验宝物活动的剩余次数
function addTreasureExpDefeatNum( add_times )
	local add_times = tonumber(add_times) or 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300002 )then
				_activeCopyCache[copy_id].can_defeat_num = tonumber(_activeCopyCache[copy_id].can_defeat_num) + add_times
				break
			end
		end
	end
end

-- 获得经验宝物活动的剩余次数
function getTreasureExpDefeatNum()
	local defautNum = 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300002 )then
				defautNum = tonumber(_activeCopyCache[copy_id].can_defeat_num)
				break
			end
		end
	end

	return defautNum
end

-- 获得经验宝物活动的：购买攻击次数的次数, added by zhz
function getTreasureBuyAtkNum( ... )
	local defautNum = 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300002 )then
				defautNum = tonumber(_activeCopyCache[copy_id].buy_atk_num)
				break
			end
		end
	end
	return defautNum
end

-- 修改经验宝物活动的：购买攻击次数的次数, added by zhz
function addTreasureAtkNum( add_times )
	local add_times = tonumber(add_times) or 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300002 )then
				_activeCopyCache[copy_id].buy_atk_num = tonumber(_activeCopyCache[copy_id].buy_atk_num) + add_times
				break
			end
		end
	end
end



-- 修改普通副本某个据点的剩余攻打次数
function addDefeatNumByCopyAndFort( copy_id, fort_id, add_times )
	local defeatNUm = _normalCopyCache.copy_list["" .. copy_id].va_copy_info.defeat_num["" .. fort_id]
	_normalCopyCache.copy_list["" .. copy_id].va_copy_info.defeat_num["" .. fort_id] = tonumber(defeatNUm) + tonumber(add_times)
end

-- 获得摸个据点重置攻打次数所需金币
function getResetDefeatNumGoldBy( copy_id, fort_id)
	local costGold = 20
	if( not table.isEmpty(_normalCopyCache.copy_list["" .. copy_id]) and not table.isEmpty(_normalCopyCache.copy_list["" .. copy_id].va_copy_info))then
		if(_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num["" .. fort_id])then
			costGold = (tonumber(_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num["" .. fort_id]) ) *10 + 20
		end
	end

	return costGold
end

-- 修改摸个据点重置次数
function addRestDefeatNumTimes( copy_id, fort_id, add_times )
	add_times = tonumber(add_times)
	if(table.isEmpty(_normalCopyCache.copy_list["" .. copy_id]))then
		_normalCopyCache.copy_list["" .. copy_id] = {}
	end
	if(table.isEmpty(_normalCopyCache.copy_list["" .. copy_id].va_copy_info))then
		_normalCopyCache.copy_list["" .. copy_id].va_copy_info = {}
	end
	if(table.isEmpty(_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num))then
		_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num = {}
	end
	if(_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num["" .. fort_id] == nil)then
		_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num["" .. fort_id] = "0"
	end
	_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num["" .. fort_id] = "" .. (tonumber(_normalCopyCache.copy_list["" .. copy_id].va_copy_info.reset_num["" .. fort_id]) + add_times)
end

-- 获得精英副本的剩余次数
function getEliteCopyLeftNum()
	local l_num = 0
	if(_eliteCopyCache and _eliteCopyCache.can_defeat_num)then
		l_num = tonumber(_eliteCopyCache.can_defeat_num)
	end
	return l_num
end

-- 获得活动副本的剩余次数
function getActiveCopyLeftNum()
	local l_num = 0
	require "script/ui/copy/expcopy/ExpCopyData"
	local expNum = ExpCopyData.getCanDefeatNum() -- 经验副本攻打次数

	require "script/ui/copy/heroDestineyCopy/HeroDestineyCopyData"
	local nHeroDestineyNum = HeroDestineyCopyData.getLeftAtkNum()   -- 英雄天命副本剩余攻打次数

	l_num = getGoldTreeDefeatNum() + getTreasureExpDefeatNum() + getHeroExpDefeatNum() + expNum + nHeroDestineyNum
	return l_num
end

-------------------------------------- 摇钱树 -------------------------------------------
function getTreeBossLevel()
	local exp = tonumber(_activeCopyCache["300001"].va_copy_info.gold_tree_exp) or 0
	local level = 1
	local maxLv = getConfigTreeMaxLv()
	for i=1,maxLv do
		if(exp >= getTreeBossMaxExp(i)) then
			exp = exp - getTreeBossMaxExp(i)
			level = i
		else
			break
		end
	end
	-- local level = _activeCopyCache["300001"].va_copy_info.gold_tree_level
	-- if not level then
	-- 	level = 1
	-- end
	return 	tonumber(level)
end

--[[
	@des 	: 得到摇钱树升级表最大配置等级
	@param 	:
	@return : num
--]]
function getConfigTreeMaxLv()
	-- require "db/DB_Normal_config"
	-- local moneyTreeExpId = DB_Normal_config.getDataById(1).moneyTreeExp
	-- require "script/utils/LevelUpUtil"
	-- local maxLv = LevelUpUtil.getConfigMaxLvByExpId(moneyTreeExpId)
	require "db/DB_Normal_config"
	local maxLv = DB_Normal_config.getDataById(1).moneyTreeLvLimit
	return maxLv
end

--得到当前级别的升级经验
function getTreeBossMaxExp( p_level )

	local level = p_level
	require "db/DB_Level_up_exp"
	require "db/DB_Normal_config"
	local moneyTreeExpId = DB_Normal_config.getDataById(1).moneyTreeExp
	print("moneyTreeExpId==",moneyTreeExpId)
	local maxExpNum = DB_Level_up_exp.getDataById(moneyTreeExpId)["lv_" .. level]
	print("level==",level)
	return tonumber(maxExpNum)
end

--[[
	@author:				bzx
	@desc:					设置是否使用摇钱树阵型
	@param:		p_valid 	true为使用，false为取消
	@return:	nil
--]]
function setUseTreeFormation(p_valid)
	_activeCopyCache["300001"].va_copy_info.fmt_valid = tostring(p_valid)
end

--[[
	@author:			bzx
	@desc:				得到当前是否使用了摇钱树阵型
	@return:	bool
--]]
function isUseTreeFormation( ... )
	return _activeCopyCache["300001"].va_copy_info.fmt_valid
end

--[[
	@author:		bzx
	@desc:								设置摇钱树阵型
	@param:			p_formationInfo		阵型数据
	@return:	nil
--]]
function setTreeFormationInfo( p_formationInfo )
	_activeCopyCache["300001"].va_copy_info.battle_info = _activeCopyCache["300001"].va_copy_info.battle_info or {}
	_activeCopyCache["300001"].va_copy_info.battle_info.arrHero = p_formationInfo
end

--[[
	@author:			bzx
	@desc:				得到当前摇钱树阵型
	@return:	bool
--]]
function getTreeFormationInfo( ... )
	if _activeCopyCache["300001"].va_copy_info.battle_info ~= nil then
		return _activeCopyCache["300001"].va_copy_info.battle_info.arrHero
	end
	return nil
end

--[[
	@author:			bzx
	@desc:				得到未保存的当前阵型
	@return:	table
--]]
function getCurFormation( ... )
	local formationData = {}
	local formationInfo = DataCache.getFormationInfo()
	for i = 1, 6 do
		local hid = formationInfo[tostring(i - 1)] or formationInfo[i]
		if tonumber(hid) ~= 0 then
			local heroData = table.hcopy(HeroUtil.getHeroInfoByHid(hid), {})
			formationData[tostring(i - 1)] = heroData
		end
	end
	return formationData
end

function addBossTreeExp( p_expNum )
	if not _activeCopyCache["300001"].va_copy_info.gold_tree_exp then
		_activeCopyCache["300001"].va_copy_info.gold_tree_exp = 0
	end

	if not _activeCopyCache["300001"].va_copy_info.gold_tree_level then
		_activeCopyCache["300001"].va_copy_info.gold_tree_level = 1
	end

	local exp = _activeCopyCache["300001"].va_copy_info.gold_tree_exp
	_activeCopyCache["300001"].va_copy_info.gold_tree_exp = tonumber(exp) + tonumber(p_expNum)
end

function getTreeBossExp()
	local exp = _activeCopyCache["300001"].va_copy_info.gold_tree_exp
	if not exp then
		exp = 0
	end
	local level = getTreeBossLevel()
	for i=1, level do
		exp = tonumber(exp) - getTreeBossMaxExp(i)
	end
	return 	tonumber(exp)
end

-- 获得摇钱树活动的剩余次数
function getGoldTreeDefeatNum()
	local defautNum = 0
	if((not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300001 )then
				defautNum = tonumber(v.can_defeat_num)
				break
			end
		end
	end

	return defautNum
end

-- 修改摇钱树活动的剩余次数
function addGoldTreeDefeatNum( add_times )
	add_times = tonumber(add_times) or 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300001 )then
				_activeCopyCache[copy_id].can_defeat_num = tonumber(_activeCopyCache[copy_id].can_defeat_num) + add_times
				break
			end
		end
	end
end

-- 获得获得摇钱树活动的可以购买的 攻击次数 added by zhz
function getGoldTreeAtkNum( )
	local defautNum = 0
	if((not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300001 )then
				defautNum = tonumber(v.buy_atk_num)
				break
			end
		end
	end

	return defautNum
end

-- 修改获得摇钱树活动的可以购买的 攻击次数 added by zhz
function addGoldTreeAtkNum( add_times )
	add_times = tonumber(add_times) or 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300001 )then

				print("=========================== _activeCopyCache[copy_id]")
				print_t(_activeCopyCache[copy_id])
				_activeCopyCache[copy_id].buy_atk_num = tonumber(_activeCopyCache[copy_id].buy_atk_num) + add_times
				break
			end
		end
	end
end

-- 获得摇钱树活动的金币挑战的次数
function getAtkGoldTreeByUseGoldNum()
	local defautNum = 0
	if((not table.isEmpty(_activeCopyCache)) )then
		print("***********")
		print_t(_activeCopyCache)
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300001 )then
				defautNum = tonumber(v.va_copy_info.gold_atk_num)
				break
			end
		end
	end
	return defautNum
end

-- 修改摇钱树活动的金币挑战次数
function addAtkGoldTreeByUseGoldNum( add_times )
	add_times = tonumber(add_times) or 0
	if( (not table.isEmpty(_activeCopyCache)) )then
		for copy_id,v in pairs(_activeCopyCache) do
			if(tonumber(copy_id) == 300001 )then
				_activeCopyCache[copy_id].va_copy_info.gold_atk_num = tonumber(_activeCopyCache[copy_id].va_copy_info.gold_atk_num) + add_times
				break
			end
		end
	end
end

-- 存储摇钱树战斗前等级
function bakBossTreeLevel( )
	_bossTreeLevel = getTreeBossLevel()
end

function getBakBossTreeLevel( ... )
	return _bossTreeLevel or 1
end

-------------------------------------- 阵型和阵容 -------------------------------------
-- 阵型信息
function getFormationInfo()
	return _formationInfo
end
function setFormationInfo( formationData )
	_formationInfo = formationData
end

-- 阵容信息
function getSquad()
	return _squadInfo
end


function setSquad( squadData )
	_squadInfo = squadData
end

function getRedFormation()
	local heroTable = {}
	for k,v in pairs(_squadInfo) do
		if(tonumber(v)~=0)then
			local heroInfo = HeroUtil.getHeroInfoByHid(v)
			if(tonumber(heroInfo.localInfo.star_lv)>=7 and tonumber(heroInfo.hid) ~= tonumber(UserModel.getUserHid()))then
				table.insert(heroTable,heroInfo)
			end
		end
	end
	return heroTable
end

function getGoldFormation()
	local heroTable = {}
	for k,v in pairs(_squadInfo) do
		print("v====",v)
		if(tonumber(v)~=0)then
			local heroInfo = HeroUtil.getHeroInfoByHid(v)
			if(tonumber(heroInfo.localInfo.star_lv)>=8 and tonumber(heroInfo.hid) ~= tonumber(UserModel.getUserHid()))then
				table.insert(heroTable,heroInfo)
			end
		end
	end
	return heroTable
end

-- 得到上阵武将数量
function getFormationHeroCount( ... )
	local count = 0
	for k, v in pairs(_squadInfo) do
		local hid = tonumber(v)
		if hid > 0 then
			count = count + 1
		end
	end
	return count
end


-- 判断一个武将是否在阵上
function isHeroBusy(tParam)
	local isBusy = false
	for k, v in pairs(_formationInfo) do
		if (v == tParam.hid) then
			isBusy=true
			break
		end
	end
	if(isBusy == false)then
		isBusy = LittleFriendData.isInLittleFriend(tonumber(tParam.hid))
	end
	return isBusy
end


-------------------------------------- 背包 -------------------------------------
-- 背包
function getRemoteBagInfo(  )
	return _bagInfo
end


function setBagStatus ( isChanged )
	_isBagChanged = isChanged
end


-- 如果背包没有变化则 不遍历
function getBagInfo()

	if(table.isEmpty(_allBagInfo) == false and _isBagChanged == false )then
		-- 不需要重新排序
		return _allBagInfo
	end
	_allBagInfo = {}
	-- 处理
	if(_bagInfo)then
		-- 处理装备
		require "db/DB_Item_arm"
		local temp_arm = {}
		if(not table.isEmpty(_bagInfo.arm))then
			for g_id, s_arm in pairs(_bagInfo.arm) do
				local tempItem = {}
				tempItem = s_arm
				tempItem.gid = g_id
				tempItem.itemDesc = DB_Item_arm.getDataById(s_arm.item_template_id)
				tempItem.itemDesc.desc = tempItem.itemDesc.info
				table.insert(temp_arm, tempItem)
			end
			table.sort( temp_arm, BagUtil.equipSort )
		end
		_allBagInfo.arm = temp_arm

		-- 处理装备碎片
		local temp_armFrag = {}
		if(not table.isEmpty(_bagInfo.armFrag))then
			for g_id, s_armFrag in pairs(_bagInfo.armFrag) do
				local tempItem = {}
				tempItem = s_armFrag
				tempItem.gid = g_id
				tempItem.itemDesc =  ItemUtil.getItemById(s_armFrag.item_template_id)
				tempItem.itemDesc.desc = tempItem.itemDesc.info
				table.insert(temp_armFrag, tempItem)
			end
			table.sort( temp_armFrag, BagUtil.armFragSort )
		end
		_allBagInfo.armFrag = temp_armFrag

		-- 处理道具
		local temp_props = {}
		local before_props = {}
		local total_props = {}
		if(not table.isEmpty(_bagInfo.props))then
			for g_id, s_item in pairs(_bagInfo.props) do
				local i_id = tonumber( s_item.item_template_id)
				local tempItem = {}
				tempItem = s_item
				tempItem.gid = g_id
				if(i_id >= 10001 and i_id <= 20000) then
					-- 直接使用类：
					require "db/DB_Item_direct"
					tempItem.itemDesc = DB_Item_direct.getDataById(i_id)
					tempItem.isDirectUse = true		-- 可以直接使用
					table.insert(before_props,tempItem )
				else
					tempItem.itemDesc = ItemUtil.getItemById(i_id)
					table.insert(temp_props,tempItem )
				end
			end
			table.sort( before_props, BagUtil.propsSort )
			table.sort( temp_props, BagUtil.propsSort )
		end
		for k,v in pairs(temp_props) do
			table.insert(total_props,v)
		end
		for k,v in pairs(before_props) do
			table.insert(total_props,v)
		end

		_allBagInfo.props = total_props

		-- 宝物
		local temp_treas = {}
		if(not table.isEmpty(_bagInfo.treas))then
			for g_id, s_trea in pairs(_bagInfo.treas) do
				local tempItem = {}
				tempItem = s_trea
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_trea.item_template_id)
				table.insert(temp_treas, tempItem)
			end
			table.sort( temp_treas, BagUtil.treasSort )
		end
		_allBagInfo.treas = temp_treas

		-- 武魂
		local temp_heroFrag = {}
		if(not table.isEmpty(_bagInfo.heroFrag))then
			for g_id, s_heroFrag in pairs(_bagInfo.heroFrag) do
				local tempItem = {}
				tempItem = s_heroFrag
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_heroFrag.item_template_id)
				table.insert(temp_heroFrag, tempItem)
			end
		end
		_allBagInfo.heroFrag = temp_heroFrag

		-- 时装
		local temp_dress = {}
		if(not table.isEmpty(_bagInfo.dress))then
			for g_id, s_dress in pairs(_bagInfo.dress) do
				local tempItem = {}
				tempItem = s_dress
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_dress.item_template_id)
				table.insert(temp_dress, tempItem)
			end
		end
		_allBagInfo.dress = temp_dress

		-- 战魂
		local temp_fightSoul = {}
		if(not table.isEmpty(_bagInfo.fightSoul))then
			for g_id, s_fightsoul in pairs(_bagInfo.fightSoul) do
				local tempItem = {}
				tempItem = s_fightsoul
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_fightsoul.item_template_id)
				table.insert(temp_fightSoul, tempItem)
			end
			table.sort( temp_fightSoul, BagUtil.fightSoulSort )
		end
		_allBagInfo.fightSoul = temp_fightSoul

		--宠物碎片
		local temp_petFrag = {}
		if(not table.isEmpty(_bagInfo.petFrag)) then
			for g_id,s_petFrag in pairs(_bagInfo.petFrag) do
				local tempItem = {}
				tempItem = s_petFrag
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_petFrag.item_template_id)
				table.insert(temp_petFrag,tempItem)
			end
		end
		_allBagInfo.petFrag = temp_petFrag

		-- 神兵
		local temp_godWeapon = {}
		if(not table.isEmpty(_bagInfo.godWp)) then
			for g_id,s_godWeapon in pairs(_bagInfo.godWp) do
				local tempItem = {}
				tempItem = s_godWeapon
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_godWeapon.item_template_id)
				table.insert(temp_godWeapon,tempItem)
			end
		end
		_allBagInfo.godWp = BagUtil.getSortDataForGodWeaponBag(temp_godWeapon)

		-- 神兵碎片
		local temp_godWeaponFrag = {}
		if(not table.isEmpty(_bagInfo.godWpFrag)) then
			for g_id,s_godWeaponFrag in pairs(_bagInfo.godWpFrag) do
				local tempItem = {}
				tempItem = s_godWeaponFrag
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_godWeaponFrag.item_template_id)
				table.insert(temp_godWeaponFrag,tempItem)
			end
			table.sort( temp_godWeaponFrag, BagUtil.godWeaponFragSortForBag )
		end
		_allBagInfo.godWpFrag = temp_godWeaponFrag

		-- 符印
		local temp_rune = {}
		if(not table.isEmpty(_bagInfo.rune)) then
			for g_id,s_rune in pairs(_bagInfo.rune) do
				local tempItem = {}
				tempItem = s_rune
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_rune.item_template_id)
				table.insert(temp_rune,tempItem)
			end
			table.sort( temp_rune, BagUtil.runeSortForBag )
		end
		_allBagInfo.rune = temp_rune

		-- 符印碎片
		local temp_runeFrag = {}
		if(not table.isEmpty(_bagInfo.runeFrag)) then
			for g_id,s_runeFrag in pairs(_bagInfo.runeFrag) do
				local tempItem = {}
				tempItem = s_runeFrag
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_runeFrag.item_template_id)
				table.insert(temp_runeFrag,tempItem)
			end
			table.sort( temp_runeFrag, BagUtil.runeFragSortForBag )
		end
		_allBagInfo.runeFrag = temp_runeFrag

		-- 锦囊
		local temp_pocket = {}
		if(not table.isEmpty(_bagInfo.pocket)) then
			for g_id,s_pocket in pairs(_bagInfo.pocket) do
				local tempItem = {}
				tempItem = s_pocket
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_pocket.item_template_id)
				table.insert(temp_pocket,tempItem)
			end
			table.sort( temp_pocket, BagUtil.pocketSortForBag )
		end
		_allBagInfo.pocket = temp_pocket

		-- 兵符
		local temp_tally = {}
		if(not table.isEmpty(_bagInfo.tally)) then
			for g_id,s_tally in pairs(_bagInfo.tally) do
				local tempItem = {}
				tempItem = s_tally
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_tally.item_template_id)
				table.insert(temp_tally,tempItem)
			end
			table.sort( temp_tally, BagUtil.tallySortForBag )
		end
		_allBagInfo.tally = temp_tally

		-- 兵符碎片
		local temp_tallyFrag = {}
		if(not table.isEmpty(_bagInfo.tallyFrag)) then
			for g_id,s_tallyFrag in pairs(_bagInfo.tallyFrag) do
				local tempItem = {}
				tempItem = s_tallyFrag
				tempItem.gid = g_id
				tempItem.itemDesc = ItemUtil.getItemById(s_tallyFrag.item_template_id)
				table.insert(temp_tallyFrag,tempItem)
			end
			table.sort( temp_tallyFrag, BagUtil.tallyFragSortForBag )
		end
		_allBagInfo.tallyFrag = temp_tallyFrag

		-- 战车
		local temp_tallchariot = {}
		if(not table.isEmpty(_bagInfo.chariotBag))then
			for g_id,s_chariot in pairs(_bagInfo.chariotBag) do
				local tempItem = ChariotMainData.parseNetChariot(s_chariot, g_id)
				table.insert(temp_tallchariot, tempItem)
			end
			table.sort(temp_tallchariot, BagUtil.sortChariotForBag)
		end
		_allBagInfo.chariotBag = temp_tallchariot
	end

	setBagStatus(false)
	return _allBagInfo
end

function setBagInfo( bagData )

	_bagInfo = bagData
end

-- 根据item_id 重置装备属性信息
function resetArmInfoByItemID( item_id )
	item_id = tonumber(item_id)
	if(not table.isEmpty(_bagInfo.arm))then
		for g_id, s_arm in pairs(_bagInfo.arm) do
			if(tonumber(s_arm.item_id) == item_id)then
				-- print("_bagInfo信息")
				-- print_t(_bagInfo.arm)
				_bagInfo.arm[g_id].va_item_text.armReinforceLevel = "0"
				_bagInfo.arm[g_id].va_item_text.armReinforceCost = "0"
				_bagInfo.arm[g_id].va_item_text.armPotence = nil
				_bagInfo.arm[g_id].va_item_text.armDevelop = nil

				break
			end
		end
	end
end



function resetTreasureInfoByItemID( item_id )
	item_id = tonumber(item_id)
	if not table.isEmpty(_bagInfo.treas) then
		for g_id,s_arm in pairs(_bagInfo.treas) do
			if tonumber(s_arm.item_id) == item_id then
				_bagInfo.treas[g_id].va_item_text.treasureEvolve = "0"
				_bagInfo.treas[g_id].va_item_text.treasureExp = "0"
				_bagInfo.treas[g_id].va_item_text.treasureLevel = "0"
				_bagInfo.treas[g_id].va_item_text.treasureInlay = {}
				_bagInfo.treas[g_id].va_item_text.treasureDevelop = nil
				break
			end
		end
	end
end

--根据item_id 重置时装属性信息
function resetClothInfoByItemId( item_id )
	item_id = tonumber(item_id)
	print("before")
	print_t(_bagInfo.dress)
	if(not table.isEmpty(_bagInfo.dress))then
		for g_id, s_arm in pairs(_bagInfo.dress) do
			if(tonumber(s_arm.item_id) == item_id)then
				print("_bagInfo信息")
				print_t(_bagInfo.dress)
				_bagInfo.dress[g_id].va_item_text.dressLevel = "0"
				break
			end
		end
	end

	print("after")
	print_t(_bagInfo.dress)
end

-- 修改开启格子的个数
function addGidNumBy( t_type, addNum )
	if(t_type == 1) then
		_bagInfo.gridMaxNum.arm = "" .. (tonumber(_bagInfo.gridMaxNum.arm) + addNum)
	elseif(t_type == 2) then
		_bagInfo.gridMaxNum.props = "" .. (tonumber(_bagInfo.gridMaxNum.props) + addNum)
	elseif(t_type == 3) then
		_bagInfo.gridMaxNum.treas = "" .. (tonumber(_bagInfo.gridMaxNum.treas) + addNum)
	elseif(t_type == 4) then
		_bagInfo.gridMaxNum.armFrag = "" .. (tonumber(_bagInfo.gridMaxNum.armFrag) + addNum)
	elseif(t_type == 5) then
		_bagInfo.gridMaxNum.dress = "" .. (tonumber(_bagInfo.gridMaxNum.dress) + addNum)
	elseif(t_type == 6) then
		_bagInfo.gridMaxNum.godWp = "" .. (tonumber(_bagInfo.gridMaxNum.godWp) + addNum)
	elseif(t_type == 7) then
		_bagInfo.gridMaxNum.godWpFrag = "" .. (tonumber(_bagInfo.gridMaxNum.godWpFrag) + addNum)
	elseif(t_type == 8) then
		_bagInfo.gridMaxNum.rune = "" .. (tonumber(_bagInfo.gridMaxNum.rune) + addNum)
	elseif(t_type == 9) then
		_bagInfo.gridMaxNum.runeFrag = "" .. (tonumber(_bagInfo.gridMaxNum.runeFrag) + addNum)
	elseif(t_type == 10) then
		_bagInfo.gridMaxNum.pocket = "" .. (tonumber(_bagInfo.gridMaxNum.pocket) + addNum)
	end
end

--[[
	@des 	: 修改开启格子的个数 
	@param 	: p_bagType 背包类型 p_addNum 增加格子数
	@return : 
--]]
function addGidNumByByBagType( p_bagType, p_addNum )
	if(p_bagType == BagUtil.EQUIP_TYPE)then
		_bagInfo.gridMaxNum.arm = tonumber(_bagInfo.gridMaxNum.arm) + p_addNum
	elseif( p_bagType == BagUtil.PROP_TYPE )then
		_bagInfo.gridMaxNum.props = tonumber(_bagInfo.gridMaxNum.props) + p_addNum
	elseif( p_bagType == BagUtil.TREASURE_TYPE )then
		_bagInfo.gridMaxNum.treas = tonumber(_bagInfo.gridMaxNum.treas) + p_addNum
	elseif( p_bagType == BagUtil.EQUIPFRAG_TYPE )then
		_bagInfo.gridMaxNum.armFrag = tonumber(_bagInfo.gridMaxNum.armFrag) + p_addNum
	elseif( p_bagType == BagUtil.DRESS_TYPE )then
		_bagInfo.gridMaxNum.dress = tonumber(_bagInfo.gridMaxNum.dress) + p_addNum
	elseif( p_bagType == BagUtil.GODWEAPON_TYPE )then
		_bagInfo.gridMaxNum.godWp = tonumber(_bagInfo.gridMaxNum.godWp) + p_addNum
	elseif( p_bagType == BagUtil.GODWEAPONFRAG_TYPE )then
		_bagInfo.gridMaxNum.godWpFrag = tonumber(_bagInfo.gridMaxNum.godWpFrag) + p_addNum
	elseif( p_bagType == BagUtil.RUNE_TYPE )then
		_bagInfo.gridMaxNum.rune = tonumber(_bagInfo.gridMaxNum.rune) + p_addNum
	elseif( p_bagType == BagUtil.RUNEFRAG_TYPE )then
		_bagInfo.gridMaxNum.runeFrag = tonumber(_bagInfo.gridMaxNum.runeFrag) + p_addNum
	elseif( p_bagType == BagUtil.POCKET_TYPE )then
		_bagInfo.gridMaxNum.pocket = tonumber(_bagInfo.gridMaxNum.pocket) + p_addNum
	elseif( p_bagType == BagUtil.TALLY_TYPE )then
		_bagInfo.gridMaxNum.tally = tonumber(_bagInfo.gridMaxNum.tally) + p_addNum
	elseif( p_bagType == BagUtil.TALLYFRAG_TYPE )then
		_bagInfo.gridMaxNum.tallyFrag = tonumber(_bagInfo.gridMaxNum.tallyFrag) + p_addNum
	elseif( p_bagType == BagUtil.CHARIOT_TYPE)then
		_bagInfo.gridMaxNum.chariotBag = tonumber(_bagInfo.gridMaxNum.chariotBag) + p_addNum
	elseif( p_bagType == BagUtil.PET_TYPE )then
		require "script/ui/pet/PetData"
		PetData.addOpenBagNum(p_addNum)
	elseif( p_bagType == BagUtil.HERO_TYPE )then
		UserModel.setHeroLimit( UserModel.getHeroLimit() + p_addNum )
	else
	end
end

-- 通过p_item_id背包的5星(紫色)装备上锁的状态  add by licong
-- 如果装备没有锁定  lock字段没有  如果锁定 lock值为1
--  p_item_id 装备item_id, p_status 状态 1是锁定，0是解锁lock字段赋值nil
function setBagEquipLockStatusByItemId(p_item_id, p_status )
	local isInBag = false
	for g_id, arm_info  in pairs(_bagInfo.arm) do
		if ( tonumber(arm_info.item_id) == tonumber(p_item_id) ) then
			if( tonumber(p_status) == 1)then
				-- 加锁 1
				_bagInfo.arm[g_id].va_item_text.lock = p_status
			else
				-- 解锁 0
				_bagInfo.arm[g_id].va_item_text.lock = nil
			end
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

--修改红卡进阶等级
function setBagEquipDevelopLvByItemId( p_item_id,p_level )
	-- body
	for g_id, arm_info  in pairs(_bagInfo.arm) do
		if ( tonumber(arm_info.item_id) == tonumber(p_item_id) ) then
			arm_info.va_item_text.armDevelop = tonumber(p_level)
			break
		end
	end
end

-- 修改装备的强化等级
function changeArmReinforceBy( item_id, addLv )
	local isInBag = false
	for g_id, arm_info  in pairs(_bagInfo.arm) do
		if ( arm_info.item_id == "" .. item_id ) then
			local level = tonumber(arm_info.va_item_text.armReinforceLevel) + addLv
			_bagInfo.arm[g_id].va_item_text.armReinforceLevel = "" .. level
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

-- 修改装备的强化等级
function setArmReinforceLevelBy( item_id, curLv )
	local isInBag = false
	for g_id, arm_info  in pairs(_bagInfo.arm) do
		if ( arm_info.item_id == "" .. item_id ) then
			_bagInfo.arm[g_id].va_item_text.armReinforceLevel = "" .. curLv
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

-- 修改装备的强化费用
function setArmReinforceLevelCostBy( item_id, curCost )
	local isInBag = false
	for g_id, arm_info  in pairs(_bagInfo.arm) do
		if ( arm_info.item_id == "" .. item_id ) then
			_bagInfo.arm[g_id].va_item_text.armReinforceCost = "" .. curCost
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

-- 修改装备的强化费用
function changeArmReinforceCostBy( item_id, addCost )
	local isInBag = false
	for g_id, arm_info  in pairs(_bagInfo.arm) do
		if ( arm_info.item_id == "" .. item_id ) then
			if(_bagInfo.arm[g_id].va_item_text.armReinforceCost)then
				_bagInfo.arm[g_id].va_item_text.armReinforceCost = tostring(tonumber(arm_info.va_item_text.armReinforceCost) + addCost)
			else
				_bagInfo.arm[g_id].va_item_text.armReinforceCost = "" .. addCost
			end
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

-- 修改宝物强化等级
function changeTreasReinforceBy( item_id, addLv, totalExp )
	local isInBag = false
	for g_id, treas_info  in pairs(_bagInfo.treas) do
		if ( treas_info.item_id == "" .. item_id ) then
			local level = tonumber(treas_info.va_item_text.treasureLevel) + addLv
			_bagInfo.treas[g_id].va_item_text.treasureLevel = "" .. level
			_bagInfo.treas[g_id].va_item_text.treasureExp = totalExp
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

-- 修改时装的强化等级
function setFashionLevelBy( item_id, curLv )
	for g_id, dress_info  in pairs(_bagInfo.dress) do
		if ( dress_info.item_id == "" .. item_id ) then
			_bagInfo.dress[g_id].va_item_text.dressLevel = "" .. curLv
			break
		end
	end
end

--修改神兵进化等级
function setGodWeaponEvolveNumById(item_id,curLv,curForLv,curExp)
	for g_id,god_info in pairs(_bagInfo.godWp) do
		if god_info.item_id == "" .. item_id then
			_bagInfo.godWp[g_id].va_item_text.evolveNum = "" .. curLv
			_bagInfo.godWp[g_id].va_item_text.reinForceLevel = "" .. curForLv
			_bagInfo.godWp[g_id].va_item_text.reinForceExp = "" .. curExp
			break
		end
	end
end

--重置神兵进化等级和级别
function resetGodWeaponById(item_id,db_info)
	for g_id,god_info in pairs(_bagInfo.godWp) do
		if god_info.item_id == "" .. item_id then
			_bagInfo.godWp[g_id].va_item_text.reinForceLevel = "0"
			_bagInfo.godWp[g_id].va_item_text.evolveNum = "" .. db_info.originalevolve
			_bagInfo.godWp[g_id].va_item_text.reinForceExp = "0"
			break
		end
	end
end
--重置锦囊级别
function resetPocketById(item_id,db_info)
	for g_id,pocket_info in pairs(_bagInfo.pocket) do
		if pocket_info.item_id == "" .. item_id then
			_bagInfo.pocket[g_id].va_item_text.pocketLevel = "0"
			_bagInfo.pocket[g_id].va_item_text.pocketExp = "0"
			break
		end
	end
end
-- 从背包中获得武魂数据
-- added by fang. 2013.08.08
function getHeroFragFromBag()
	if not _bagInfo then
		return nil
	end
	return _bagInfo.heroFrag
end
-- 在背包中删除gid对应的武魂数据（在招募后该武将对应的武魂数据为0）
-- added by fang. 2013.08.08
function delHeroFragOfGid(gid)
	_bagInfo.heroFrag[tostring(gid)] = nil
end
-- 在招募后减少背包gid对应的武魂数据
-- added by fang. 2013.08.08
function setHeroFragItemNumOfGid(gid, item_num)
	_bagInfo.heroFrag[tostring(gid)].item_num = item_num
end

-- 通过模板id后的武魂数量(如果没有返回0 )
-- added by zhz ,2013.10.5
function getHeroFragNumByItemTmpid( item_template_id )
	if(table.isEmpty(_bagInfo.heroFrag)) then
		return 0
	end
	for k ,v in pairs(_bagInfo.heroFrag) do
		if(tonumber(v.item_template_id) == tonumber(item_template_id)) then
			return v.item_num
		end
	end
	return 0
end
---------------------------- 列传 --------------------------------
function setLieData( lieCache )
	-- body
	_lieCache = lieCache
end

function getLieData()
	-- body
	return _lieCache
end

-- 增加该武将通关次数
function addPassHeroCopyTimesBy( htid, copyid ,diffculty)
	htid = tonumber(htid)
	if( (not table.isEmpty(_lieCache))) then
		local lieCount = 0
		for k,v in pairs(_lieCache) do
			lieCount = lieCount+1
			if(htid == tonumber(k) )then
				-- _starCache.star_list[k].pass_hcopy_num = tonumber(_starCache.star_list[k].pass_hcopy_num) + addTimes
				if ( table.isEmpty(_lieCache[tostring(k)]) ==true ) then
					_lieCache[tostring(k)] = {}
				end
				if(table.isEmpty(_lieCache[tostring(k)][tostring(copyid)]) == true)then
					_lieCache[tostring(k)][tostring(copyid)] = {}
				end

				_lieCache[tostring(k)][tostring(copyid)][tostring(diffculty)] = "1"
				break
			end
			if(lieCount == table.count(_lieCache))then
				_lieCache[tostring(htid)] = {}
				_lieCache[tostring(htid)][tostring(copyid)] = {}
				_lieCache[tostring(htid)][tostring(copyid)][tostring(diffculty)] = "1"
				break
			end
		end
	else
		_lieCache = {}
		_lieCache[tostring(htid)] = {}
		_lieCache[tostring(htid)][tostring(copyid)] = {}
		_lieCache[tostring(htid)][tostring(copyid)][tostring(diffculty)] = "1"
	end
end

---------------------------- 名仕 --------------------------------
-- 保存
function saveStarInfoToCache( starInfo )
	_starCache = starInfo
	--将名将信息加入修行中
	--added by Zhang Zihang
	require "script/ui/replaceSkill/ReplaceSkillData"
	ReplaceSkillData.updateAllInfo(_starCache)
end
-- 获取
function getStarInfoFromCache()
	return _starCache
end
-- 获取所有star列表 id 递增
function getStarArr()
	local starArr = {}
	if( (not table.isEmpty(_starCache)) and  (not table.isEmpty(_starCache.star_list)) ) then
		local allKeys = table.allKeys(_starCache.star_list)
		local function keySort ( key_1, key_2 )
		   	return tonumber(key_1) < tonumber(key_2)
		end
		table.sort( allKeys, keySort )

		for k,keyIndex in pairs(allKeys) do
			local tbl = _starCache.star_list[keyIndex]
			table.insert(starArr, tbl)
		end
	end

	return starArr
end

-- 修改名将的经验
function addExpToStar( star_id, addExp, ratioGrow)
	if( (not table.isEmpty(_starCache)) and  (not table.isEmpty(_starCache.star_list)) ) then
		for key, star_info in pairs(_starCache.star_list) do
			if(tonumber(key) == tonumber(star_id) ) then
				_starCache.star_list[key].total_exp = _starCache.star_list[key].total_exp + tonumber(addExp)
				require "db/DB_Star_level"
				local tempData = DB_Star_level.getDataById(tonumber(_starCache.star_list[key].star_tid))
				-- local lastLv = tonumber(_starCache.star_list[key].level)
				_starCache.star_list[key].level = StarUtil.getLevelByTotalExp( _starCache.star_list[key].total_exp, _starCache.star_list[key].star_tid )
				-- if(lastLv < tonumber(_starCache.star_list[key].level) )then
				-- 	_starCache.star_list[key].ratio = 0
				-- else
				-- 	_starCache.star_list[key].ratio = tonumber(_starCache.star_list[key].ratio) + tonumber(ratioGrow)
				-- end

				break
			end
		end
	end
end

-- 修改名将的等级
function addLevelToStar( star_id, addLv)
	if( (not table.isEmpty(_starCache)) and  (not table.isEmpty(_starCache.star_list)) ) then
		for key, star_info in pairs(_starCache.star_list) do
			if(tonumber(key) == tonumber(star_id) ) then
				_starCache.star_list[key].level = tonumber(_starCache.star_list[key].level) + addLv
				-- 修改经验
				_starCache.star_list[key].total_exp = StarUtil.getTotalExpByLevel(_starCache.star_list[key].star_tid, _starCache.star_list[key].level)
				-- _starCache.star_list[key].ratio = 0
				break
			end
		end
	end
end

-- 修改名将数据
function changeStarData( p_starId, p_starData )
	print("p_starId",p_starId)
	print_t(p_starData)
	print("---- star_list")
	print_t(_starCache.star_list)
	if( (not table.isEmpty(_starCache)) and  (not table.isEmpty(_starCache.star_list)) ) then
		for key, star_info in pairs(_starCache.star_list) do
			if(tonumber(key) == tonumber(p_starId) ) then
				print("key",key)
				-- 修改等级
				_starCache.star_list[key].level = p_starData.level
				-- 修改经验
				_starCache.star_list[key].total_exp = p_starData.total_exp
				break
			end
		end
	end
end

-- 增加一个名将
function addStarToCache( starInfo )
	if(table.isEmpty(_starCache)) then
		-- _starCache ={}
		-- _starCache.rob_num = 0
		-- _starCache.star_list = {}
		-- _starCache.star_list[starInfo.star_id] = starInfo
	else
		_starCache.star_list[starInfo.star_id] = starInfo
		--添加到宗师录
		--added by Zhang Zihang
		require "script/ui/replaceSkill/ReplaceSkillData"
		ReplaceSkillData.addNewTeacher(starInfo)
	end
end

-- -- 增加该武将通关次数
-- function addPassHeroCopyTimesBy( htid, copyid )
-- 	htid = tonumber(htid)
-- 	if( (not table.isEmpty(_starCache)) and  (not table.isEmpty(_starCache.star_list)) and (not table.isEmpty(_starCache.star_list.va_star))  ) then

-- 		for k,v in pairs(_starCache.star_list) do
-- 			if(htid == tonumber(v.star_tid) )then
-- 				-- _starCache.star_list[k].pass_hcopy_num = tonumber(_starCache.star_list[k].pass_hcopy_num) + addTimes
-- 				if( not table.isEmpty(_starCache.star_list[k].va_star) )then
-- 					if ( table.isEmpty(_starCache.star_list[k].va_star.hcopy) ==true ) then
-- 						_starCache.star_list[k].va_star.hcopy = {}
-- 					end
-- 					_starCache.star_list[k].va_star.hcopy[tostring(copyid)] = {}
-- 					_starCache.star_list[k].va_star.hcopy[tostring(copyid)]["1"] = "1"
-- 				end
-- 				break
-- 			end
-- 		end
-- 	end
-- end


-- 比武和打劫的次数
function addRobNum( times )
	_starCache.rob_num = tostring(tonumber(_starCache.rob_num) + times)
end

-- 次数
function getRobNum()
	return tonumber(_starCache.rob_num)
end

------------------- shop ----------------
function setShopCache( shopInfo )
	_shopCache = shopInfo
end

function getShopCache( )
	return _shopCache
end
-- 修改
function addSiliverFreeNum( addNum )
	_shopCache.silver_recruit_num = tonumber(_shopCache.silver_recruit_num) + tonumber(addNum)
	if(tonumber(_shopCache.silver_recruit_num)<=0)then
		require "db/DB_Tavern"
		local mediumDesc = DB_Tavern.getDataById(2)

		_shopCache.silver_recruit_time  = mediumDesc.free_time_cd
		ShopUtil.dealLoyal(_shopCache,1)
		_shopCache.silverExpireTime 	= _shopCache.silver_recruit_time + os.time()
	end
end

-- 修改
function addGoldFreeNum( addNum )
	_shopCache.gold_recruit_num = tonumber(_shopCache.gold_recruit_num) + tonumber(addNum)
	if(tonumber(_shopCache.gold_recruit_num)<=0)then
		require "db/DB_Tavern"
		local seniorDesc = DB_Tavern.getDataById(3)

		_shopCache.gold_recruit_time = seniorDesc.free_time_cd
		ShopUtil.dealLoyal(_shopCache,2)
		_shopCache.goldExpireTime 	 = _shopCache.gold_recruit_time + os.time()
	end
end

-- 修改神将累积招将次数, added by zhz
function changeGoldRecruitSum(addNum )
	_shopCache.gold_recruit_sum = _shopCache.gold_recruit_sum + tonumber(addNum)
end


-- 添加神将信息
function changeSeniorHeros( gold_recruit_t, htid )
	_shopCache.va_shop.gold_recruit = gold_recruit_t
	_shopCache.va_shop.gold_hero = htid
end
-- 修改摸个商品的购买次数
function addBuyNumberBy( goods_id, addNum )
	addNum = tonumber(addNum)
	if(table.isEmpty(_shopCache.goods)) then
		_shopCache.goods = {}
	end
	if(_shopCache.goods["" .. goods_id])then
		_shopCache.goods["" .. goods_id].num = tonumber(_shopCache.goods["" .. goods_id].num) + addNum
	else
		_shopCache.goods["" .. goods_id] = {}
		_shopCache.goods["" .. goods_id].num = addNum
	end
end

-- 修改首刷状态
function changeFirstStatus()
	if( tonumber(_shopCache.gold_recruit_status) <2 ) then
		_shopCache.gold_recruit_status = "" .. (tonumber(_shopCache.gold_recruit_status) + 2)
	end
end

-- 修改战将首刷状态
function changeSiliverFirstStatus()
	if( tonumber(_shopCache.silver_recruit_status) <2 ) then
		_shopCache.silver_recruit_status = "" .. (tonumber(_shopCache.silver_recruit_status) + 2)
	end
end

-- 获得积分
function getShopPoint(  )
	return _shopCache.point
end
-- 修改积分
function changeShopPoint( point)
	_shopCache.point = tonumber(_shopCache.point) - point
end
-- 增加积分
function addShopPoint( point)
	_shopCache.point = tonumber(_shopCache.point) + point
end

-- 获得当前可以领取的vip礼包数量, added by zhz
function getCanReceiveVipNUm(  )
	require "db/DB_Vip"
	require "script/model/user/UserModel"
	if(_shopCache== nil or table.isEmpty(_shopCache) ) then
		return 0
	end
	local vip_gift=   _shopCache.va_shop.vip_gift
	local num=0

	if( not table.isEmpty(vip_gift)) then
		for i=1, #vip_gift do

			if(tonumber(vip_gift[i]) == 0 and DB_Vip.getDataById(i).vip_gift_ids ~= nil ) then
				num = num+1
			end
		end
	else
		local maxId = UserModel.getVipLevel()+1

		for i=1, maxId do
			if(DB_Vip.getDataById(i).vip_gift_ids ~= nil) then
				num= num+1
			end
		end
	end
	return num
end

-- 获得可以招募的英雄数目
function getRecuitFreeNum( )
	local num=0
	if(table.isEmpty(_shopCache) or _shopCache== nil) then
		return num
	end

	if ( tonumber(_shopCache.silver_recruit_num) >0 ) then
		num= num+1
	end
	if( tonumber(_shopCache.gold_recruit_num) >0) then
		num= num+1
	end

	return num
end

function getShopGiftForFree( ... )
	-- local num = getRecuitFreeNum()+ getCanReceiveVipNUm()
	local num = getRecuitFreeNum()
	return num
end

----------------------------------  设置charge_gold:用户充值金币的数量  added by zhz ---------------
local _chageGold = 0
function setChargeGoldNum( chargeGold )
	_chageGold = chargeGold
end

function getChargeGoldNum( )
	return  _chageGold
end

function addChargeGold( pNum )
	local gold = tonumber(pNum) or 0
	_chageGold = _chageGold + gold
end



--------------------------------奖励中心通知状态---------------------------
local bNewRewardStatus=false
-- 获取奖励中心状态
function getRewardCenterStatus( ... )
	return bNewRewardStatus
end
-- 设置奖励中心状态
function setRewardCenterStatus(pStatus)
	bNewRewardStatus = pStatus
end

---------------------------------------------------add by DJN 2014/12/12 ----------------------
--------------------------------资源追回通知状态---------------------------
local bReResourceStatus=false
-- 获取资源追回状态
function getReResourceStatus( ... )
	return bReResourceStatus
end
-- 设置资源追回状态
function setReResourceStatus(pStatus)
	bReResourceStatus = pStatus
end
------------------------------------------------------------------------------------------------


--设置vip礼包购买状态
function setBuyedVipGift( vipLevel )
	_shopCache.va_shop.vip_gift[vipLevel] = 1

end

------------------------------------- 对手阵容的查看 -----------------------
local _rivalFormation = {}

function addFormaton( formation )
	table.insert(_rivalFormation, formation)
end

function getFromation(uid )
	for k,formation in pairs(_rivalFormation) do
		if( formation.uid == uid) then
			return formation
		end
	end
	return false
end

-------------------------------功能节点开启信息----------------------------
-- add by lichenyang 2013.08.29
function saveSwitchCache( cache_info )
	_switchCache = cache_info
end

--打开功能节点
function addNewSwitchNode( switchNodeId )
	table.insert(_switchCache, tonumber(switchNodeId))
end

--查看功能节点是否开启
-- switchEnmu:功能节点的枚举值，在GlobalVars.lua中查看列表
-- isShow: 是否显示提示框 传入nil或true为显示 传入false是不显示
-- return: true 开启 false 关闭
function getSwitchNodeState( switchEnmu, isShow )
	for k,v in pairs(_switchCache) do
		if(tonumber(v) == switchEnmu) then
			return true
		end
	end
	if(isShow == nil or isShow == true) then
		require "db/DB_Switch"
		local switchInfo = DB_Switch.getDataById(switchEnmu)
		local param = nil
		if(switchInfo.level ~= nil) then
			param = switchInfo.level
		else
			print("switchInfo.copyId", switchInfo.copyId)
			require "db/DB_Stronghold"
			local strongInfo = DB_Stronghold.getDataById(switchInfo.copyId)
			param = strongInfo.name
		end
		local desc = string.gsub(switchInfo.desc, "xx", param)
		require "script/ui/tip/AnimationTip"
		AnimationTip.showTip(desc)
	end
	return false
end

function setBagItemPotentiality( item_id )
	print("setBagItemPotentiality = ", item_id)
	print_t(potentiality_info)
	print(GetLocalizeStringBy("key_1794"))
	for k,v in pairs(_bagInfo.arm) do
		if(tonumber(v.item_id) == tonumber(item_id)) then
			_bagInfo.arm[tostring(k)].va_item_text.armPotence = v.va_item_text.armFixedPotence
			_bagInfo.arm[tostring(k)].va_item_text.armFixedPotence = nil
			print(GetLocalizeStringBy("key_3082"))
			break
		end
	end
	print(GetLocalizeStringBy("key_1180"))
	print_t(_bagInfo.arm)
end

function setBagItemFixedPotentiality( item_id ,potentiality_info )
	print("setBagItemFixedPotentiality = ", item_id)
	print_t(potentiality_info)
	print(GetLocalizeStringBy("key_1794"))
	for k,v in pairs(_bagInfo.arm) do
		if(tonumber(v.item_id) == tonumber(item_id)) then
			_bagInfo.arm[tostring(k)].va_item_text.armFixedPotence = potentiality_info
			print(GetLocalizeStringBy("key_3082"))
			break
		end
	end
	print(GetLocalizeStringBy("key_1180"))
	print_t(_bagInfo.arm)
end

--[[
	@设置宝物精炼等级
]]
function setTreasureEvolveLevel( item_id, evolve_level )
	for k,v in pairs(_bagInfo.treas) do
		if(tonumber(v.item_id) == tonumber(item_id)) then
			_bagInfo.treas[tostring(k)].va_item_text.treasureEvolve = evolve_level
			break
		end
	end
end


-- 修改战魂等级
function changeFSLvByItemId( item_id, level, totalExp )
	local isInBag = false
	for g_id, fs_info  in pairs(_bagInfo.fightSoul) do
		if ( fs_info.item_id == "" .. item_id ) then
			_bagInfo.fightSoul[g_id].va_item_text.fsLevel = "" .. level
			_bagInfo.fightSoul[g_id].va_item_text.fsExp = "" .. totalExp
			isInBag = true
			break
		end
	end
	if( isInBag == false)then
		-- TODO 英雄身上
	end
end

--[[
	@des 	:返回当前所有副本的总星数
	@param 	:
	@return :副本总星数
--]]
function getSumCopyStar()
	--得到副本信息
	local copyDataInfo = getReomteNormalCopyData()
	local copyScore = 0
	for k,v in pairs(copyDataInfo) do
		copyScore = copyScore + tonumber(v.score)
	end

	return copyScore
end

------------------------------------------------------------------------ 修改神兵缓存数据 --------------------------------------------------------------------------
--[[
	@des 	:修改神兵等级，总经验
	@param 	:p_item_id:神兵itemId,p_curLv当前等级, p_totalExp当前全部经验 p_addSilver:强化花费费用
	@return :
--]]
function changeGodWeaponLvAndExpInBag( p_itemId, p_curLv, p_totalExp, p_addSilver )
	for g_id, fs_info  in pairs(_bagInfo.godWp) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			_bagInfo.godWp[g_id].va_item_text.reinForceLevel = "" .. p_curLv
			_bagInfo.godWp[g_id].va_item_text.reinForceExp = "" .. p_totalExp
			_bagInfo.godWp[g_id].va_item_text.reinForceCost = tostring( tonumber(_bagInfo.godWp[g_id].va_item_text.reinForceCost) + tonumber(p_addSilver) )
			break
		end
	end
end

--[[
	@des 	:修改神兵洗练可替换属性
	@param 	:p_item_id:神兵itemId,p_fixId:第几层,p_attrId:可替换属性信息
	@return :
--]]
function changeGodWeaponToConfirmInBag( p_itemId, p_fixId, p_attrId)
	for g_id, fs_info  in pairs(_bagInfo.godWp) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			if(not table.isEmpty(_bagInfo.godWp[g_id].va_item_text.toConfirm) )then
				_bagInfo.godWp[g_id].va_item_text.toConfirm[tostring(p_fixId)] = p_attrId
			else
				_bagInfo.godWp[g_id].va_item_text.toConfirm = {}
				_bagInfo.godWp[g_id].va_item_text.toConfirm[tostring(p_fixId)] = p_attrId
			end
			break
		end
	end
end

--[[
	@des 	:修改神兵洗练已替换属性
	@param 	:p_item_id:神兵itemId,p_fixId:第几层,p_attrId:已替换属性信息
	@return :
--]]
function changeGodWeaponConfirmedInBag( p_itemId,  p_fixId, p_attrId)
	for g_id, fs_info  in pairs(_bagInfo.godWp) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			if(not table.isEmpty(_bagInfo.godWp[g_id].va_item_text.confirmed) )then
				_bagInfo.godWp[g_id].va_item_text.confirmed[tostring(p_fixId)] = p_attrId
			else
				_bagInfo.godWp[g_id].va_item_text.confirmed = {}
				_bagInfo.godWp[g_id].va_item_text.confirmed[tostring(p_fixId)] = p_attrId
			end
			break
		end
	end
end

--[[
	@des 	:修改神兵批量洗练可替换属性
	@param 	:p_item_id:神兵itemId,p_fixId:第几层,p_attrIdTab:可替换属性信息table
	@return :
--]]
function changeGodWeaponBatchInBag( p_itemId, p_fixId, p_attrIdTab)
	for g_id, fs_info  in pairs(_bagInfo.godWp) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			if(not table.isEmpty(_bagInfo.godWp[g_id].va_item_text.btc) )then
				_bagInfo.godWp[g_id].va_item_text.btc[tostring(p_fixId)] = p_attrIdTab
			else
				_bagInfo.godWp[g_id].va_item_text.btc = {}
				_bagInfo.godWp[g_id].va_item_text.btc[tostring(p_fixId)] = p_attrIdTab
			end
			break
		end
	end
end
---------------------------------------------------------------------------- 修改宝物镶嵌信息 -----------------------------------------------------------------------
--[[
	@des 	:修改宝物镶嵌的符印信息
	@param 	:p_treasureItemId:宝物itemId, p_runeItemInfo:符印信息, p_index:第几个位置
	@return :
--]]
function changeTreasureRuneInBag( p_treasureItemId, p_runeItemInfo, p_index)
	for g_id, fs_info  in pairs(_bagInfo.treas) do
		if ( tonumber(fs_info.item_id) == tonumber(p_treasureItemId) ) then
			if(not table.isEmpty(_bagInfo.treas[g_id].va_item_text.treasureInlay) )then
				_bagInfo.treas[g_id].va_item_text.treasureInlay[tostring(p_index)] = p_runeItemInfo
			else
				_bagInfo.treas[g_id].va_item_text.treasureInlay = {}
				_bagInfo.treas[g_id].va_item_text.treasureInlay[tostring(p_index)] = p_runeItemInfo
			end
			break
		end
	end
end
----------------------------------------------------------------------------- 符印缓存信息 ------------------------------------------------------------------------

--[[
	@des 	: 获得宝物背包所有镶嵌的符印
	@param 	:
	@return :
--]]
function getAllRuneInTreasureBag()
	local allRune = {}
	for g_id, itemInfo  in pairs(_bagInfo.treas) do
		if( itemInfo.va_item_text and itemInfo.va_item_text.treasureInlay )then
			for k,v in pairs(itemInfo.va_item_text.treasureInlay) do
				allRune[v.item_id] = v
				allRune[v.item_id].pos = k
				allRune[v.item_id].treasureItemId = itemInfo.item_id
				allRune[v.item_id].itemDesc = ItemUtil.getItemById(v.item_template_id)
			end
		end
	end
	return allRune
end

--[[
	@des 	:修改宝物进阶信息
	@param 	:p_treasureItemId:宝物itemId, p_treasureDevelop:进阶次数
	@return :
--]]
function changeTreasureDevelopInBag( p_treasureItemId, p_treasureDevelop)
	for g_id, fs_info  in pairs(_bagInfo.treas) do
		if ( tonumber(fs_info.item_id) == tonumber(p_treasureItemId) ) then
			_bagInfo.treas[g_id].va_item_text.treasureDevelop = p_treasureDevelop
			break
		end
	end
end

--[[
	@des 	:获取背包中的所有丹药（既然是存在于背包中 那么就是没有被服用的丹药）
	@param 	:
	@return :
--]]
function getPillInBag()
	local props = getBagInfo().props

	if(table.isEmpty(props))then return end

	local resultTab = {}
	for k_index,v_info in pairs(props)do
		local tmpId = tonumber(v_info.item_template_id)
		if(61100 <= tmpId and tmpId <= 61399)then
			table.insert(resultTab,v_info)
		end
	end
	return resultTab
end
-------------------------------------修改背包里锦囊数据-----------------------------------
function changePocketLvAndExpInBag( p_itemId, p_curLv, p_totalExp)
	for g_id, fs_info  in pairs(_bagInfo.pocket) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			_bagInfo.pocket[g_id].va_item_text.pocketLevel = "" .. p_curLv
			_bagInfo.pocket[g_id].va_item_text.pocketExp = "" .. p_totalExp
			break
		end
	end
end

function removePocketFromBag( p_itemId )
	-- body
	for g_id, fs_info  in pairs(_bagInfo.pocket) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			_bagInfo.pocket[g_id] = nil
			break
		end
	end
end

function changePocketLockInBag( p_itemId)
	for g_id, fs_info  in pairs(_bagInfo.pocket) do
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			if( _bagInfo.pocket[g_id].va_item_text.lock and tonumber(_bagInfo.pocket[g_id].va_item_text.lock) ==1)then
				_bagInfo.pocket[g_id].va_item_text.lock = nil
			else
				_bagInfo.pocket[g_id].va_item_text.lock = 1
			end
			break
		end
	end
end


--[[
	@des 	:修改战魂洗练等级
	@param 	:p_item_id:itemId,p_evolveLv:洗练等级
	@return :
--]]
function changeFightSouEvolveLvInBag( p_itemId, p_evolveLv )
	for g_id, fs_info  in pairs(_bagInfo.fightSoul) do  
		if ( tonumber(fs_info.item_id) == tonumber(p_itemId) ) then
			if(not table.isEmpty(_bagInfo.fightSoul[g_id].va_item_text ) )then	
				_bagInfo.fightSoul[g_id].va_item_text.fsEvolve = p_evolveLv
			end
			break
		end
	end
end

---------------------------------------------------兵符缓存---------------------------------------------------

--[[
	@des 	: 修改兵符强化等级
	@param 	: 
	@return : 
--]]
function changeTallyLvAndExpInBag( p_itemId, p_curLv, p_totalExp )
	for g_id, v_info  in pairs(_bagInfo.tally) do
		if ( tonumber(v_info.item_id) == tonumber(p_itemId) ) then
			_bagInfo.tally[g_id].va_item_text.tallyLevel = "" .. p_curLv
			_bagInfo.tally[g_id].va_item_text.tallyExp = "" .. p_totalExp
			break
		end
	end
end

--[[
	@des 	: 修改兵符进阶等级
	@param 	: 
	@return : 
--]]
function changeTallyDevLvInBag( p_itemId, p_curLv )
	for g_id, v_info  in pairs(_bagInfo.tally) do
		if ( tonumber(v_info.item_id) == tonumber(p_itemId) ) then
			_bagInfo.tally[g_id].va_item_text.tallyDevelop = "" .. p_curLv
			break
		end
	end
end

--[[
	@des 	: 修改兵符精炼等级
	@param 	: 
	@return : 
--]]
function changeTallyEvolveLvInBag( p_itemId, p_curLv )
	for g_id, v_info  in pairs(_bagInfo.tally) do
		if ( tonumber(v_info.item_id) == tonumber(p_itemId) ) then
			_bagInfo.tally[g_id].va_item_text.tallyEvolve = "" .. p_curLv
			break
		end
	end
end

---------------------------------------------------战车缓存---------------------------------------------------

--[[
	@desc 	: 修改战车强化等级
	@param 	: pItemId 物品id pCurLv 强化等级
	@return : 
--]]
function updateChariotEnforceLvInBag( pItemId, pCurLv )
	for g_id, v_info  in pairs(_bagInfo.chariotBag) do
		if ( tonumber(v_info.item_id) == tonumber(pItemId) ) then
			_bagInfo.chariotBag[g_id].va_item_text.chariotEnforce = pCurLv
			break
		end
	end
end







