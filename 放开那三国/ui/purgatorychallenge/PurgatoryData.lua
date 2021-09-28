-- FileName: PurgatoryData.lua
-- Author: LLP
-- Date: 15-5-21
-- Purpose: function description of module

module("PurgatoryData", package.seeall)

require "db/DB_Lianyutiaozhan_copy"
require "db/DB_Lianyutiaozhan_reward"

local _copyInfo 		= nil --副本数据
local _RankInfo 		= nil --排行数据
local _OpponentInfo 	= nil --对手数据
local _RwardInfo 		= nil --奖励数据
local _shopInfo         = nil --商店数据
local _clickTable 		= nil --点击过的按钮table
local _posInfo 			= {} --阵容
local _chooseHeroData 	= {} --被选择的副将数据
local _pIndex 			= nil
local _pChangllegeTimes = 0
local _pIndexPoint 		= 0
kTypeBattle		= 1001
kTypeBuff 		= 1002
kTypeNormalBox 	= 1003
kTypeGodBox 	= 1004

--------------------------------------enter命令获取的神兵副本数据--------------------------
	-- /**
	--  * 获得基本信息
	--  * @return array
	--  * {
	--  * 		ret										'ok'/'no' 为no时代表这个服不在任何分组内,没有以下字段
	--  * 		passed_stage							当前通关的最大关卡0-6
	--  * 		curr_point 								本次闯关的总积分
	--  * 		hell_point								炼狱积分
	--  * 		atk_num									攻击次数
	--  * 		buy_atk_num								购买的攻击次数
	--  * 		refresh_num								刷新备选武将列表的次数
	--  * 		monster									每个关卡初始化的怪物，一旦初始化好，就不能改啦，当前关卡的怪
	--  * 		choice => array							index取值0-4，代表5个备选武将格子，如果这个位置上没有武将，htid为0
	--  * 		[
	--  * 			index => htid
	--  * 		]
	--  * 		formation => array						index取值0-5，代表6个位置。如果位置上没有武将，htid为0
	--  * 		[
	--  * 			index => htid
	--  * 		]
	--  * 		point => array							index取值0-n，代表每次闯关的积分
	--  * 		[
	--  * 			index => point
	--  * 		]
	--  * }
	--  */
-----------------------------------------------------------------------------------------

-- 设置神兵副本数据
function setCopyInfo( data )
	_copyInfo = data

	local pTable = {}

	local index = 0

	for k,v in pairs(_copyInfo.formation) do
		pTable[index]=v
		index = index+1
	end

	_copyInfo.formation = pTable

	setNextTime()
	-- hadFormation()
end

-- 得到神兵副本数据
function getCopyInfo( ... )
	return _copyInfo
end

-- 设置下次开始时间
function setNextTime( ... )
	-- body
	local curServerTime = BTUtil:getSvrTimeInterval()
	if(curServerTime>=tonumber(_copyInfo.end_time))then
		_copyInfo.begin_time = _copyInfo.period_end_time
	end
end

-- 根据hid查看武将是否在神兵副本的阵容中
function isOnCopyFormationBy( hid )
	local isOn = false
	local isBench = false
	hid = tonumber(hid)

	local copyInfo = PurgatoryData.getCopyInfo()
	if table.isEmpty(copyInfo) then
		return false
	end

	if(table.isEmpty(copyInfo.choice))then
		isBench = false
	else
		for k,v in pairs(copyInfo.choice)do
			if(tonumber(hid)==tonumber(v) and tonumber(v)~=0)then
				isBench = true
			end
		end
	end

	if(not table.isEmpty(_copyInfo.formation) ) then
		for k, m_hid in pairs(_copyInfo.formation) do
			if(tonumber(hid) == tonumber(m_hid))then
				isOn = true
				break
			end
		end
	end

	local isOn = isOn or isBench
	return isOn
end

--改变炼狱令数量
function addMoney( pNum )
	-- body
	_copyInfo.hell_point = tonumber(_copyInfo.hell_point)+pNum
end

-- 星星数
function getStarNumber()
	local stars = 0
	if ( _copyInfo.star_star ) then
		stars = tonumber(_copyInfo.star_star)
	end
	return stars
end

-- 设置排行信息数据
function setRankInfo( data )
	_RankInfo = data
	data.inner = data.inner or {}
	data.cross = data.cross or {}
end

-- 得到排行信息数据
function getRankInfo( ... )
	return _RankInfo
end


function getRankRewardDb( p_rank )
	for i = 1, table.count(DB_Lianyutiaozhan_reward.Lianyutiaozhan_reward) do
		local rewardDb = DB_Lianyutiaozhan_reward.getDataById(i)
		if p_rank >= rewardDb.num1 and p_rank <= rewardDb.num2 then
			return rewardDb
		end
	end
end

-- 设置奖励信息数据
function setRewardInfo( data )
	_RwardInfo = data
end

-- 得到奖励信息数据
function getRewardInfo( ... )
	return _RwardInfo
end

----------------------------------------商店-------------------------------------------
---设置商店信息数据
function setShopInfo( data )
	_shopInfo = data
end

---得到商店信息数据
function getShopInfo( ... )
	return _shopInfo
end
--------------------------------------------------------------------------------------

--判断通关
function isHavePass( ... )
	-- body
	local allPass = false
	if(tonumber(_copyInfo["passed_stage"])>=table.count(DB_Lianyutiaozhan_copy.Lianyutiaozhan_copy))then
		allPass = true
	end
	return allPass
end

-- 重置
function reset(pInfo)
	_copyInfo = pInfo
end

function setChoice( pInfo )
	-- body
	_copyInfo.choice = pInfo
end

function setEnterInfo( pPoint,pHellPoint,pChoice )
	-- body
	_copyInfo.curr_point = tonumber(_copyInfo.curr_point) + tonumber(pPoint)
	_copyInfo.hell_point = _copyInfo.hell_point+tonumber(pHellPoint)
	_copyInfo.choice = pChoice
	if(tonumber(_copyInfo.passed_stage)~=6)then
		if(tonumber(_copyInfo.passed_stage)==5)then
			_copyInfo.atk_num = tonumber(_copyInfo.atk_num)-1
		end
		_copyInfo.passed_stage = tonumber(_copyInfo.passed_stage) + 1
	else

	end
end

------------- 副本阵型
function getFormationInfo()
	return _posInfo
end

function setFormationInfo(pInfo)
	_posInfo = pInfo

	local index = 0
	for i=6,11 do
		_copyInfo.formation[tonumber(index)] = tonumber(pInfo[i])
		index = index+1
	end
end

function setChooseHeroData( p_HeroData )
	-- body
	_chooseHeroData = p_HeroData
end

function getChooseHeroData( ... )
	-- body
	return _chooseHeroData
end

function setLoseTimes( p_Times )
	-- body
	_pLoseTimes = p_Times
end

function getLoseTimes( ... )
	-- body
	return _pLoseTimes
end

function setBuyTimes( p_Times )
	-- body
	_pChangllegeTimes = p_Times
end

function getBuyTimes( ... )
	-- body
	return _copyInfo.buy_atk_num
end

function addBuyTimes( p_Times )
	-- body
	_copyInfo.buy_atk_num = tonumber(_copyInfo.buy_atk_num)+p_Times
	_copyInfo.atk_num = tonumber(_copyInfo.atk_num)+p_Times
end

function addFreshTimes()
	-- body
	_copyInfo.refresh_num = _copyInfo.refresh_num+1
end
function setBenchData( p_Data )
	-- body
	for k,v in pairs(p_Data)do
		_copyInfo.choice[k] = p_Data[k]
	end
end
