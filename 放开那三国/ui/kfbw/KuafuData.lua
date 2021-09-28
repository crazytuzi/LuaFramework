-- FileName: KuafuData.lua 
-- Author: yangrui
-- Date: 15-09-29
-- Purpose: function description of module 

module("KuafuData", package.seeall)

require "db/DB_Kuafu_contest"
require "db/DB_Kuafu_contest_dayreward"

local _worldCompeteInfo = nil  -- 跨服比武信息
local _enemyData        = {}   -- 对手信息
local _rewardData       = {}   -- 已领取奖励信息
local _isFury           = nil  -- 开启狂怒模式
local _atkTimes         = nil  -- 挑战完成次数
local _winTimes         = nil  -- 挑战胜利次数
local _haveAtkNum       = nil  -- 已购买的挑战次数
local _freeRefreshTimes = nil  -- 免费刷新次数
local _crossHonor       = nil  -- 跨服荣誉
local _prostrateTimes   = nil  -- 膜拜完成次数
local _rankData         = nil  -- 排行榜信息

local _innerRankData    = nil  -- 服内排行榜信息
local _crossRankData    = nil  -- 跨服排行榜信息
local _userInnerRank    = nil  -- 玩家服内排行
local _userCrossRank    = nil  -- 玩家跨服排行

local _isOpenKuafuShop  = false
local _championData     = nil

--[[
	@des 	: 设置跨服比武信息
	@param 	: 
	@return : 
--]]
function setWorldCompeteInfo( pWorldCompeteData )
	_worldCompeteInfo = pWorldCompeteData
	if pWorldCompeteData.ret == "ok" then
		_isOpenKuafuShop = true
		
		setEnemyData()
		setAtkTimes()
		setWinTimes()
		setBuyAtkNum()
		setFreeRefreshTimes()
		setProstrateTimes()
		setRewardData()
	end
end

--[[
	@des    : 获取跨服比武信息
	@para   : 
	@return : 
--]]
function getWorldCompeteInfo( ... )
	return _worldCompeteInfo
end

--[[
	@des    : 是否可以开启跨服比武商店
	@para   : 
	@return : 
--]]
function isOpenKuafuShop( ... )
	print("===|_isOpenKuafuShop|===",_isOpenKuafuShop)
	return _isOpenKuafuShop
end

--[[
	@des 	: 设置挑战完成次数
	@param 	: 
	@return : 
--]]
function setAtkTimes( pAtkTimes )
	if pAtkTimes == nil then
		_atkTimes = tonumber(_worldCompeteInfo.atk_num)
	else
		_atkTimes = _atkTimes+pAtkTimes
	end
end

--[[
	@des 	: 获取挑战完成次数
	@param 	: 
	@return : 
--]]
function getAtkTimes( ... )
	return _atkTimes
end

--[[
	@des 	: 设置挑战胜利次数
	@param 	: 
	@return : 
--]]
function setWinTimes( pNum )
	if pNum == nil then
		_winTimes = tonumber(_worldCompeteInfo.suc_num)
	else
		_winTimes = _winTimes+pNum
	end
end

--[[
	@des 	: 获取挑战胜利次数
	@param 	: 
	@return : 
--]]
function getWinTimes( ... )
	return _winTimes
end

--[[
	@des 	: 设置挑战购买次数
	@param 	: 
	@return : 
--]]
function setBuyAtkNum( pNum )
	if pNum == nil then
		_haveAtkNum = tonumber(_worldCompeteInfo.buy_atk_num)
	else
		local num = tonumber(pNum)
		_haveAtkNum = _haveAtkNum+num
	end
end

--[[
	@des 	: 获取挑战购买次数
	@param 	: 
	@return : 
--]]
function getBuyAtkNum( ... )
	return _haveAtkNum
end

--[[
	@des 	: 获取已刷新次数
	@param 	: 
	@return : 
--]]
function getRefreshTimes( ... )
	return tonumber(_worldCompeteInfo.refresh_num)
end

--[[
	@des 	: 设置膜拜完成次数
	@param 	: 
	@return : 
--]]
function setProstrateTimes( pNum )
	if pNum == nil then
		_prostrateTimes = tonumber(_worldCompeteInfo.worship_num)
	else
		_prostrateTimes = _prostrateTimes+pNum
	end
end

--[[
	@des 	: 获取膜拜完成次数
	@param 	: 
	@return : 
--]]
function getProstrateTimes( ... )
	return _prostrateTimes
end

--[[
	@des 	: 获取本次比武的最大荣誉
	@param 	: 
	@return : 
--]]
function getCurBattleMaxHonor( ... )
	return tonumber(_worldCompeteInfo.max_honor)
end

--[[
	@des 	: 获取本次活动开启的时间
	@param 	: 
	@return : 
--]]
function getStartTime( ... )
	return tonumber(_worldCompeteInfo.begin_time)
end

--[[
	@des 	: 获取本次活动结束的时间  后端
	@param 	: 
	@return : 
--]]
function getEndTime( ... )
	return tonumber(_worldCompeteInfo.end_time)
end

--[[
	@des 	: 获取发奖结束时间  膜拜结束
	@param 	: 
	@return : 
--]]
function getRewardEndTime( ... )
	return tonumber(_worldCompeteInfo.reward_end_time)
end

--[[
	@des 	: 获取整个活动结束的时间  也是下一个活动开启时间
	@param 	: 
	@return : 
--]]
function getPeriedEndTime( ... )
	return tonumber(_worldCompeteInfo.period_end_time)
end

--[[
	@des 	: 设置比武对象的信息
	@param 	: 
	@return : 
--]]
function setEnemyData( pEnemyData )
	_enemyData = {}
	if pEnemyData == nil then
		_enemyData = _worldCompeteInfo.rival
	else
		_enemyData = pEnemyData
	end
end

--[[
	@des 	: 设置比武后对象的信息
	@param 	: pid & server_id
	@return : 
--]]
function modifyEnemyData( pPid, pServer_id )
	local pid = tonumber(pPid)
	local server_id = tonumber(pServer_id)
	for index,hero in pairs(_enemyData) do
		local heroPid = tonumber(hero.pid)
		local heroServerId = tonumber(hero.server_id)
		if (pid == heroPid and server_id == heroServerId) then
			hero.status = 1
		end
	end
end

--[[
	@des 	: 获取比武对象的信息
	@param 	: 
	@return : 
--]]
function getEnemyData( ... )
	return _enemyData
end

--[[
	@des 	: 设置已领取的奖励信息
	@param 	: 
	@return : 
--]]
function setRewardData( pRewardData )
	if pRewardData == nil then
		_rewardData = {}
		_rewardData = _worldCompeteInfo.prize
	else
		table.insert(_rewardData,pRewardData)
	end
end

--[[
	@des 	: 获取已领取奖励信息
	@param 	: 
	@return : 
--]]
function getRewardData( ... )
	return _rewardData
end

--[[
	@des 	: 获取可得到跨服荣誉值和文字颜色
	@param 	: pForce  敌方战斗力  pHtid  敌方索引
	@return : 跨服荣誉值和文字颜色
--]]
function getHonorAndFontColor( pForce, pHtid )
	-- yr_2002 跨服荣誉
	local htid = tonumber(pHtid)
	local heroInfo = HeroUtil.getHeroLocalInfoByHtid(htid)
	local nameColor = HeroPublicLua.getCCColorByStarLevel(heroInfo.star_lv)
	return getShouldAddHonor(pForce) .. GetLocalizeStringBy("yr_2002"),nameColor

end

--[[
	@des 	: 获取可得到跨服荣誉值
	@param 	: pForce  敌方战斗力
	@return : 跨服荣誉值
--]]
function getShouldAddHonor( pForce )
	-- 计算跨服荣誉
	-- 基础积分*min(max(int(（敌方战力/我方战力）*10)/10,1),1.5)（基础积分读配置）  旧
	-- 积分计算公式修改   int( 基础积分+min((敌方战力/20000),100))                新
	local basicScore = tonumber(DB_Kuafu_contest.getDataById(1).win)
	local enemyForce = pForce
	local honorValue = math.floor(basicScore+math.min((enemyForce/20000),150))
	print("===|getShouldAddHonor|===")
	print(basicScore,enemyForce,honorValue)
	return tonumber(honorValue)
end

--[[
	@des 	: 通过 pid & server_id 获取对手信息
	@param 	: 
	@return : 
--]]
function getEnemyDataByHeroPidAndServerId( pPid, pServer_id )
	local pid = tonumber(pPid)
	local server_id = tonumber(pServer_id)
	for index,hero in pairs(_enemyData) do
		if pid == tonumber(hero.pid) and server_id == tonumber(hero.server_id) then
			return hero
		end
	end
end

--[[
	@des 	: 设置狂怒模式状态
	@param 	: 
	@return : 
--]]
function setFury( pFury )
	_isFury = pFury
end

--[[
	@des 	: 获取狂怒模式状态
	@param 	: 
	@return : 狂怒的状态
--]]
function getFury( ... )
	return _isFury
end

--[[
	@des 	: 判断当前的宝箱奖励是否领取
	@param 	: 
	@return : 
--]]
function isGetCurChestById( pId )
	local id = tonumber(pId)
	local isGet = false
	local getRewardData = getRewardData()
	if getRewardData == nil then
		return isGet
	end
	local needWinTimes = getNeedWinTimes(id)
	for index,sucNum in pairs(getRewardData) do
		if tonumber(sucNum) == needWinTimes then
			isGet = true
			break
		end
	end
	return isGet
end

--[[
	@des 	: 得到宝箱的状态
	@param 	: pId 宝箱的id   1木  2铜  3银  4金
	@return : 
--]]
function getChestStateInfoById( pId )
	local id = pId
	local state = 1
	local needWinTimes = getNeedWinTimes(id)
	local isGet = isGetCurChestById(id)
	if isGet then
		-- 已领取状态 3
		state = 3
	else
		local curWinTimes = getWinTimes()
		if ( curWinTimes >= needWinTimes ) then
			-- 可领取状态 2
			state = 2
		else
			-- 不可领取状态 1
			state = 1
		end
	end
	return state,needWinTimes
end

--[[
	@des 	: 设置排行榜信息
	@param 	: 
	@return : 
--]]
function setRankData( pRankData )
	_rankData = {}
	_rankData = pRankData
end

--[[
	@des 	: 获取服内排行榜信息
	@param 	: 
	@return : 
--]]
function getInnerRankData( ... )
	return _rankData.inner
end

--[[
	@des 	: 获取跨服排行榜信息
	@param 	: 
	@return : 
--]]
function getCrossRankData( ... )
	return _rankData.cross
end

--[[
	@des 	: 获取玩家服内排行信息
	@param 	: 
	@return : 
--]]
function getUserInnerRank( ... )
	return tonumber(_rankData.my_inner_rank)
end

--[[
	@des 	: 获取玩家跨服排行信息
	@param 	: 
	@return : 
--]]
function getUserCrossRank( ... )
	return tonumber(_rankData.my_cross_rank)
end

--[[
	@des 	: 获取跨服排行榜第一人  用于膜拜
	@param 	: 
	@return : 
--]]
function getCrossRankNo1( ... )
	for index,playerInfo in pairs(_rankData.cross) do
		if tonumber(playerInfo.rank) == 1 then
			return _rankData.cross[index]
		end
	end
end

--[[
	@des 	: 设置膜拜对象数据
	@param 	: 
	@return : 
--]]
function setChampionData( pChampionData )
	_championData = {}
	_championData = pChampionData
end

--[[
	@des 	: 获取膜拜对象数据
	@param 	: 
	@return : 
--]]
function getChampionData( ... )
	return _championData.cross[1]
end

------------------------------------------------------------------------------- kuafu_contest

--[[
	@des 	: 设置免费刷新次数
	@param 	: 
	@return : 
--]]
function setFreeRefreshTimes( pSubFreeTimes )
	if pSubFreeTimes == nil then
		_freeRefreshTimes = tonumber(DB_Kuafu_contest.getDataById(1).free_refresh)
	else
		local subFreeTimes = tonumber(pSubFreeTimes)
		_freeRefreshTimes = _freeRefreshTimes+subFreeTimes
	end
end

--[[
	@des 	: 获取免费刷新次数
	@param 	: 
	@return : 
--]]
function getFreeRefreshTimes( ... )
	return _freeRefreshTimes
end

--[[
	@des 	: 获取刷新金币消耗
	@param 	: 
	@return : 
--]]
function getRefreshCost( ... )
	return tonumber(DB_Kuafu_contest.getDataById(1).refresh_cost)
end

--[[
	@des 	: 获取每日免费挑战次数
	@param 	: 
	@return : 
--]]
function getFreeChallengeTimes( ... )
	return tonumber(DB_Kuafu_contest.getDataById(1).challenge_free)
end

--[[
	@des 	: 获取购买挑战次数金币消耗数据
	@param 	: 
	@return : 
--]]
function getChallengeTimesCost( ... )
	return DB_Kuafu_contest.getDataById(1).challenge_cost
end

--[[
	@des 	: 根据当前已购买挑战次数得到所需购买的金币消耗
	@param 	: 
	@return : 
--]]
function getCurBuyChallengeTimesCost( ... )
	local buyChallengeTimes = getBuyAtkNum()
	local nextBuyChallengeTimes = buyChallengeTimes+1
	local costData = getChallengeTimesCost()
	print("===|nextBuyChallengeTimes|===",nextBuyChallengeTimes)
	local retTab = string.split(costData,",")
	local cost = nil
	for k,v in pairs(retTab) do
		local tmp = string.split(v,"|")
		if nextBuyChallengeTimes >= tonumber(tmp[1]) then
			cost = tonumber(tmp[2])
		end
	end
	return cost
end

--[[
	@des 	: 获取购买挑战次数的总花费
	@param 	: pNum  购买次数
	@return : 
--]]
function getTotalCostByBuyTimes( pNum )
	local buyNum = tonumber(pNum)
	print("buyNum",buyNum)
	-- 已经购买的次数
	local stepNum = getBuyAtkNum()
	print("stepNum",stepNum)
	local costData = getChallengeTimesCost()
	local retTab = string.split(costData,",")
	local cost = 0
	local leftBuyNum = buyNum
	for i=#retTab,1,-1 do
		if buyNum == 0 then
			print("if buyNum == 0 ===",buyNum)
			return cost
		end
		local tmp = string.split(retTab[i],"|")
		local curNeedTimes = tonumber(tmp[1])
		local curCost = tonumber(tmp[2])
		if buyNum+stepNum >= curNeedTimes then
			if stepNum >= curNeedTimes then
				leftBuyNum = 0
				cost = cost+(buyNum-leftBuyNum)*curCost
				return cost
			else
				leftBuyNum = curNeedTimes-1
				cost = cost+(buyNum+stepNum-leftBuyNum)*curCost
			end
			print("step === cost")
			print(i,cost)
			buyNum = leftBuyNum-stepNum
		end
	end
	return cost
end

--[[
	@des 	: 根据当前金币数获取最多可购买的挑战次数
	@param 	: 
	@return : 
--]]
function getMaxBuyChallengeTimesByGoldNum( pGoldNum )
	local curGoldNum = tonumber(pGoldNum)
	local leftCanButTimes = getBuyChallengeTimesLimit()-getBuyAtkNum()
	local canBuyNum = 0
	for i=1,leftCanButTimes do
		if curGoldNum < getTotalCostByBuyTimes(i) then
			canBuyNum = i-1
			break
		end
	end
	return canBuyNum
end

--[[
	@des 	: 获取购买挑战次数上限
	@param 	: 
	@return : 
--]]
function getBuyChallengeTimesLimit( ... )
	return tonumber(DB_Kuafu_contest.getDataById(1).challenge_buy)
end

--[[
	@des 	: 获取狂怒模式消耗挑战次数
	@param 	: 
	@return : 
--]]
function getFuryCostChallengeTimes( ... )
	return tonumber(DB_Kuafu_contest.getDataById(1).crazy_cost)
end

--[[
	@des 	: 获取一次膜拜奖励
	@param 	: 
	@return : 
--]]
function getFirstProstrateReward( ... )
	return DB_Kuafu_contest.getDataById(1).fir_worship
end

--[[
	@des 	: 获取二次膜拜奖励
	@param 	: 
	@return : 
--]]
function getSecondProstrateReward( ... )
	return DB_Kuafu_contest.getDataById(1).sec_worship
end

--[[
	@des 	: 获取二次膜拜条件
	@param 	: 
	@return : 
--]]
function getSecondProstrateCondition( ... )
	return DB_Kuafu_contest.getDataById(1).level_vip
end

--[[
	@des 	: 获取显示二次膜拜等级
	@param 	: 
	@return : 
--]]
function getShowSecondProstrateLevel( ... )
	return tonumber(DB_Kuafu_contest.getDataById(1).show_level)
end

--[[
	@des 	: 获取失败基础跨服荣誉
	@param 	: 
	@return : 
--]]
function getFailHonor( ... )
	return tonumber(DB_Kuafu_contest.getDataById(1).fail)
end

------------------------------------------------------------------------------- kuafu_contest_dayreward

--[[
	@des 	: 获取需要胜场
	@param 	: 
	@return : 
--]]
function getNeedWinTimes( pId )
	local id = tonumber(pId)
	return tonumber(DB_Kuafu_contest_dayreward.getDataById(id).neednum)
end

--[[
	@des 	: 获取胜场奖励
	@param 	: 
	@return : 
--]]
function getWinRewardById( pId )
	local id = tonumber(pId)
	return DB_Kuafu_contest_dayreward.getDataById(id).reward
end
