-- FileName: GuildBossCopyData.lua
-- Author: bzx
-- Date: 15-03-31 
-- Purpose: 军团副本数据

module("GuildBossCopyData", package.seeall)

require "db/DB_GroupCopy_shop"
require "db/DB_GroupCopy_rule"
require "db/DB_GroupCopy_reward"

local _userInfo = {}		
local _copyInfo = {}
local _attackInfo = {}
local _rankList = {}
local _boxInfo = {}
local _lastBoxInfo = {}
local _openBoxInfo = {}
local _shopInfo = {}

function setUserInfo(p_userInfo)
	_userInfo = p_userInfo
end

function getUserInfo( ... )
	return _userInfo
end

function setCopyInfo( p_copyInfo )
	_copyInfo = p_copyInfo
end

function getCopyInfo( ... )
	return _copyInfo
end

function setBossInfo( pInfo )
	-- body
	_userInfo.boss_info = pInfo
end

function setBuyTime()
	-- body
	_userInfo.boss_info.buy_boss_num = _userInfo.boss_info.buy_boss_num+1
end

function getPointCopyHpInfo( p_pointCopyIndex )
	local total = 0
	local curr = 0
	if _copyInfo[tostring(p_pointCopyIndex)].hp ~= nil then
		for k, v in pairs(_copyInfo[tostring(p_pointCopyIndex)].hp) do
			total = total + v.total or 0
			curr = curr + v.curr or 0
		end
	else
		total = 1
		curr = 1
	end
	return total, curr
end

function getHeroHpInfo( p_pointCopyIndex, p_hid )
	local total = 0
	local curr = 0
	if _copyInfo[tostring(p_pointCopyIndex)].hp ~= nil then
		for k, v in pairs(_copyInfo[tostring(p_pointCopyIndex)].hp) do
			if p_hid == tonumber(k) then
				total = tonumber(v.total) or 0
				curr = tonumber(v.curr) or 0
				break
			end
		end
	else
		total = 1
		curr = 1
	end
	return total, curr
end

function getBossCopyHpInfo( ... )
	return tonumber(_userInfo.total_hp), tonumber(_userInfo.curr_hp)
end

function setAttackInfo( p_attackInfo )
	_attackInfo = p_attackInfo
end

function getAttackInfo( ... )
	return _attackInfo
end

function setRankList( p_rankList )
	_rankList = p_rankList
	for i = 1, #_rankList.all do
		local userInfo = _rankList.all[i]
		if userInfo.uname == UserModel.getUserName() then
			_rankList.myAll = userInfo
			break;
		end
	end

	for i = 1, #_rankList.guild do
		local userInfo = _rankList.guild[i]
		if userInfo.uname == UserModel.getUserName() then
			_rankList.myGuild = userInfo
			break
		end
	end

	for i = 1, #_rankList.guild_copy do
		local guildCopyInfo = _rankList.guild_copy[i]
		local guildId = GuildDataCache.getGuildId()
		if tostring(guildId) == guildCopyInfo.guild_id then
			_rankList.myGuildCopy = guildCopyInfo
			break
		end
	end
end

function getRankList( p_rankList )
	return _rankList
end

function addAtkNum( p_atkNum )
	_userInfo.atk_num = tonumber(_userInfo.atk_num) + p_atkNum
end

function addAtkBuyNum(num)
	_userInfo.buy_num = tonumber(_userInfo.buy_num) + num
	addAtkNum(num)
end

function setBoxInfo( p_boxInfo )
	_boxInfo = p_boxInfo
end

function getBoxInfo( ... )
	return _boxInfo
end

function setLastBoxInfo(p_lastBoxInfo)
	_lastBoxInfo = p_lastBoxInfo
end

function getLastBoxInfo( ... )
	return _lastBoxInfo
end

function setOpenBoxInfo( p_openBoxInfo, p_boxIndex )
	_openBoxInfo = p_openBoxInfo
	_boxInfo[tostring(p_boxIndex)] = p_openBoxInfo
	_userInfo.recv_box_reward_time = "1"
end

function getOpenBoxInfo( ... )
	return _openBoxInfo
end

function getBoxRewardInfo( ... )
	local rewardInfos = parseField(getChestData(), 2)
	for i = 1, #rewardInfos do
		local rewardInfo = rewardInfos[i]
		rewardInfo[5] = rewardInfo[4]
		for k, v in pairs(_boxInfo) do
			local boxInfo = v
			if i - 1 == tonumber(boxInfo.reward) then
				rewardInfo[5] = rewardInfo[5] - 1
			end
		end
	end
	return rewardInfos
end

function getTomorrowBoxRewardInfoByGroupCopyId( p_groupCopyId )
	local rewardInfos = parseField(getTomorrowChestData(p_groupCopyId), 2)
	for i = 1, #rewardInfos do
		local rewardInfo = rewardInfos[i]
		rewardInfo[5] = rewardInfo[4]
	end
	return rewardInfos
end



function getLastChestData( ... )
	local lastBoxInfo = getLastBoxInfo()
	local groupCopyDb = DB_GroupCopy.getDataById(tonumber(lastBoxInfo.last))
	local timeData = parseField(groupCopyDb.choose, 1)
	local curTime = TimeUtil.getSvrTimeByOffset() - 86400
	local nextTime = TimeUtil.getTimeByDate(timeData[1])
	if curTime >= nextTime then
		if timeData[2] == 1 then
			return groupCopyDb.Chest
		else -- timeData[2] == 2
			return groupCopyDb.other_chest
		end
	else
		return groupCopyDb.other_chest
	end
end

function getTomorrowChestData( p_groupCopyId )
	local curTime = TimeUtil.getSvrTimeByOffset() + 86400
 	return getChestData(p_groupCopyId, curTime)
end

function getChestData(p_groupCopyId, p_time)
	local groupCopyId = p_groupCopyId or tonumber(_userInfo.curr)
	local groupCopyDb = DB_GroupCopy.getDataById(groupCopyId)
	local timeData = parseField(groupCopyDb.choose, 1)
	local curTime = p_time or TimeUtil.getSvrTimeByOffset()
	local nextTime = TimeUtil.getTimeByDate(timeData[1])
	if curTime >= nextTime then
		if timeData[2] == 1 then
			return groupCopyDb.Chest
		else -- timeData[2] == 2
			return groupCopyDb.other_chest
		end
	else
		if timeData[2] == 1 then
			return groupCopyDb.other_chest
		else -- timeData[2] == 2
			return groupCopyDb.Chest
		end
	end
end


function buyAtkNum( ... )
	local cost = GuildBossCopyData.getBuyAttackCost()
	UserModel.addGoldNumber(-cost)
	addAtkBuyNum(1)
end

function setAtkNum(p_atkNum)
	_userInfo.atk_num = p_atkNum
end

function getAtkNum( ... )
	return tonumber(_userInfo.atk_num)
end

function buyAllKill( ... )
	local buyAllAttackInfo = GuildBossCopyData.getBuyAllAttackCostInfo()
	addAtkNum(buyAllAttackInfo[3])
	_userInfo.refresh_time = "1"
	_userInfo.refresh_num = tonumber(_userInfo.refresh_num) + 1
	UserModel.addGoldNumber(-buyAllAttackInfo[2])
	table.insert(_userInfo.refresher, UserModel.getUserName())
end

function setRefreshNum( p_refreshNum )
	_userInfo.refresh_num = p_refreshNum
end

function getRefreshNum( ... )
	return tonumber(_userInfo.refresh_num)
end

function setShopInfo( p_shopInfo ) --修改兑换剩余次数
	_shopInfo = p_shopInfo
	for k, v in pairs(_shopInfo) do
		local groupCopyShopDb = DB_GroupCopy_shop.getDataById(k)
		v.remain = getBaseNum(groupCopyShopDb.id) - tonumber(v.num)
	end
end

function getBaseNum( p_goodsId )
	print("p_goodsId")
	print(p_goodsId)
	local numberChange = 1
	local groupCopyShopDb = DB_GroupCopy_shop.getDataById(p_goodsId)
	if groupCopyShopDb.level_num == nil then --如果字段为空
		numberChange = groupCopyShopDb.bassNum 
		print("numberChange")
	    print(numberChange)
	else
		local _number,_level =getLevelnumber(groupCopyShopDb)
		numberChange = _number
		print("numberChange")
	    print(numberChange)
	    print("_level",_level)
	end
	print("numberChange")
	print(numberChange)
	return numberChange
end

function getShopInfo( ... )  --获得剩余兑换次数
	for k, v in pairs(DB_GroupCopy_shop.GroupCopy_shop) do
		local groupCopyShopId = v[1]
		if _shopInfo[tostring(groupCopyShopId)] == nil then
			local groupCopyShopDb = DB_GroupCopy_shop.getDataById(groupCopyShopId)
			local goodInfo = {
				time = 0,
				num = 0,
				remain = getBaseNum(groupCopyShopDb.id)
			}
			_shopInfo[tostring(groupCopyShopId)] = goodInfo
		end
	end
	return _shopInfo
end

function buy( p_goodsId, p_num )
	local goodInfo = _shopInfo[tostring(p_goodsId)]
	goodInfo.num = tonumber(goodInfo.num) + p_num
	goodInfo.remain = tonumber(goodInfo.remain) - p_num
end

function isPassedGroupCopy(p_groupCopyId)
	return tonumber(_userInfo.max_pass_copy) >= p_groupCopyId
end

function isOpenedGroupCopy( p_groupCopyId )
	return tonumber(_userInfo.max_pass_copy) + 1 >= p_groupCopyId
end

function isTargetGroupCopy( p_groupCopyId )
	return tonumber(_userInfo.curr) == p_groupCopyId
end

function getExtraReward( ... )
	local groupCopyDb = DB_GroupCopy.getDataById(tonumber(_userInfo.curr))
	return parseField(groupCopyDb.extra_reward, 1)[3]
end

function getRemainReward( ... )
	local groupCopyDb = DB_GroupCopy.getDataById(tonumber(_userInfo.curr))
	return parseField(groupCopyDb.num_reward, 1)[3] * tonumber(_userInfo.atk_num)
end

function getBuyAttackCost( ... )
	local groupCopyRuleDb = DB_GroupCopy_rule.getDataById(1)
	local currBuyAttackNum = tonumber(_userInfo.buy_num)
	local buySpriceInfo = parseField(groupCopyRuleDb.buy_price, 2)
	local cost = buySpriceInfo[1][2]
	for i = #buySpriceInfo, 1, -1 do
		if currBuyAttackNum >= buySpriceInfo[i][1] then
			cost = buySpriceInfo[i + 1][2]
			break
		end
	end
	return cost
end

function getBuyAllAttackCostInfo( ... )
	local groupCopyRuleDb = DB_GroupCopy_rule.getDataById(1)
	return parseField(groupCopyRuleDb.all_attack, 1)
end

function getGuildLevelLimit( ... )
	local groupCopyRuleDb = DB_GroupCopy_rule.getDataById(1)
	return parseField(groupCopyRuleDb.open_limit, 2)
end

function getAttackReward( ... )
	local groupCopyDb = DB_GroupCopy.getDataById(tonumber(_userInfo.curr))
	return parseField(groupCopyDb.time_reward, 1)
end

function getKillReward( ... )
	local groupCopyDb = DB_GroupCopy.getDataById(tonumber(_userInfo.curr))
	return parseField(groupCopyDb.boss_reward, 1)
end

function attack( p_data, p_pointCopyIndex )
	if p_data.ret == "ok" then
		local pointCopyData = _copyInfo[tostring(p_pointCopyIndex)]
		local oldHp = 0
		if pointCopyData.hp == nil then
			pointCopyData.hp = p_data.hp
			oldHp, _ = getPointCopyHpInfo(p_pointCopyIndex)
		else
			_, oldHp = getPointCopyHpInfo(p_pointCopyIndex)
			pointCopyData.hp = p_data.hp
		end
		local total, curr = getPointCopyHpInfo(p_pointCopyIndex)
		_userInfo.curr_hp = tonumber(_userInfo.curr_hp) - oldHp + curr
		_userInfo.atk_damage = tonumber(_userInfo.atk_damage) + p_data.damage
		-- if pointCopyData.max_damager == nil then
		-- 	pointCopyData.max_damager = {}
		-- 	pointCopyData.max_damager.damage = 0
		-- end
		-- if tonumber(pointCopyData.max_damager.damage) < tonumber(p_data.damage) then
		-- 	pointCopyData.max_damager.htid = UserModel.getAvatarHtid()
		-- 	pointCopyData.max_damager.uname = UserModel.getUserName()
		-- 	pointCopyData.max_damager.damage = p_data.damage
		-- end
		addAtkNum(-1)
		GuildDataCache.addExploitsCount(getAttackReward()[3])
		if p_data.kill == "1" then
			GuildDataCache.addExploitsCount(getKillReward()[3])
		end
	elseif p_data.ret == "dead" then
		local pointCopyData = _copyInfo[tostring(p_pointCopyIndex)]
		pointCopyData.hp = {}
	end
end

function recvPassReward( ... )
	_userInfo.recv_pass_reward_time = "1"
end

function setTarget( p_groupCopyId )
	_userInfo.next = p_groupCopyId
end

function isNextTargetGroupCopy(p_groupCopyId)
	return tonumber(_userInfo.next) == p_groupCopyId
end

function getGroupCopyRewardDb( p_rank )
	for i = table.count(DB_GroupCopy_reward.GroupCopy_reward), 1, -1 do
		local groupCopyRewardDb = DB_GroupCopy_reward.getDataById(i)
		if p_rank >= groupCopyRewardDb.min then
			return groupCopyRewardDb
		end
	end
end

function pushGuildcopyUpdateRefreshNum( p_data )
	if p_data.uname ~= UserModel.getUserName() then
		_userInfo.refresh_num = tonumber(_userInfo.refresh_num) + 1
		local buyAllAttackInfo = GuildBossCopyData.getBuyAllAttackCostInfo()
		addAtkNum(buyAllAttackInfo[3])
	end
	table.insert(_userInfo.refresher, p_data.uname)
end

function pushGuildcopyCurrCopyPass( ... )
	_userInfo.curr_hp = "0"
	local groupCopyDb = DB_GroupCopy.getDataById(tonumber(_userInfo.curr))
	local pointCopyIds = parseField(groupCopyDb.copy_id, 1)
	for i = 1, #pointCopyIds do
		if _copyInfo[i] ~= nil then
			_copyInfo[i].hp = {}
		end
	end
end

function couldOpenBoxOrReceive( ... )
	if _userInfo.pass_time ~= "0" then
		if _userInfo.recv_pass_reward_time == "0" or _userInfo.recv_box_reward_time == "0" then
			return true
		end
	end
	return false
end

--获取下一个级别，当前兑换次数
function getLevelnumber(goods_data)
	local nextLv = -1
	local curNum = 1
	local goodsStr = string.split(goods_data.level_num,",")
	local length = #goodsStr
	--对表进行倒序
	for i=1,length do
		local goods_info = string.split(goodsStr[length - i + 1],"|")
		local first_data = string.split(goodsStr[1],"|")
		
		if( UserModel.getHeroLevel() >= tonumber(goods_info[1]) )then
			
		 	curNum = tonumber(goods_info[2])  --当前刷新次数
		 	if( 1 == i )then
		 		-- 当达到最大等级的时候
		 		nextLv = -1    
		 	else
		 		-- 正常情况
		 		local data_goods = string.split(goodsStr[length - i +1 +1],"|")
		 		nextLv = tonumber(data_goods[1])  --要显示的下一级别
		 	end
			break
		end
	end
	return curNum,nextLv
end

-- <<<<<<< .mine

-- -- 就否已经开启
-- function isOpen( ... )
-- 	local guildLevel = GuildDataCache.getGuildHallLevel()
-- 	local guildLevelLimit = GuildBossCopyData.getGuildLevelLimit()[1][2]
-- 	return guildLevel >= guildLevelLimit
-- end
-- =======

function isOpen( ... )
	if GuildDataCache.getMineSigleGuildId() == 0 then
		return false
	end
	local guildLevel = GuildDataCache.getGuildHallLevel()
	local guildLevelLimit = GuildBossCopyData.getGuildLevelLimit()[1][2]
	if guildLevel < guildLevelLimit then
		return false
	end
	return true
end
-- >>>>>>> .r118736
