-- FileName: GodWeaponCopyData.lua
-- Author: LLP
-- Date: 14-12-15
-- Purpose: function description of module

module("GodWeaponCopyData", package.seeall)

local _copyInfo 		= nil --副本数据
local _RankInfo 		= nil --排行数据
local _OpponentInfo 	= nil --对手数据
local _RwardInfo 		= nil --奖励数据
local _shopInfo         = nil --商店数据
local _clickTable 		= nil --点击过的按钮table
local _posInfo 			= {} --阵容
local _chooseHeroData 	= {} --被选择的副将数据
local _pIndex 			= nil
local _sweepResult 		= nil --扫荡结果
local _pChangllegeTimes = 0
kTypeBattle		= 1001
kTypeBuff 		= 1002
kTypeNormalBox 	= 1003
kTypeGodBox 	= 1004

--------------------------------------enter命令获取的神兵副本数据--------------------------
--uid,
--refresh_time 刷新时间,
--luxurybox_num 开宝藏宝箱的次数,
--cur_base 当前位置,
--pass_num 今天通关的个数,
--point 当前积分,
--star_star 当前星星数量,
--coin 神兵币,
--va_pass
--	=> array
--	    (
--       heroInfo =>( hid => array( currHp,currRage, 因为没有看到UI，不完全)),
--       chestShow => array( freeBox => int, goldBox => int ), 0是没处理 1是处理过了
--       buffShow => array( array(status => int, buff => int )), 0是没处理 1是处理过了
--       formation => array( int => hid,  ),
--       buffInfo => array(),
--      )
-----------------------------------------------------------------------------------------

-- 设置神兵副本数据
function setCopyInfo( data )
	_copyInfo = data
	hadFormation()
end

-- 得到神兵副本数据
function getCopyInfo( ... )
	return _copyInfo
end

--
function hadFormation( ... )
	--设置阵容数据
	if(not table.isEmpty(_copyInfo["va_pass"])and _copyInfo["va_pass"]["formation"]~=nil )then
		local posData = _copyInfo["va_pass"]["formation"]
		local posDataCache = {}
		for k,v in pairs(posData) do
       		 posDataCache["" .. (tonumber(k)-1)] = tonumber(v)
   		end
		GodWeaponCopyData.setFormationInfo(posDataCache)
	end
end

-- 根据hid查看武将是否在神兵副本的阵容中
function isOnCopyFormationBy( hid )
	local isOn = false
	local isBench = false
	hid = tonumber(hid)

	local copyInfo = GodWeaponCopyData.getCopyInfo()
	if table.isEmpty(copyInfo) then
		return false
	end

	print_t(copyInfo.va_pass.bench)
	if(table.isEmpty(copyInfo.va_pass.bench))then
		isBench = false
	else
		for k,v in pairs(copyInfo.va_pass.bench)do
			if(tonumber(hid)==tonumber(v) and tonumber(v)~=0)then
				isBench = true
			end
		end
	end

	if(not table.isEmpty(_copyInfo.va_pass.formation) ) then
		for k, m_hid in pairs(_copyInfo.va_pass.formation) do
			if(tonumber(hid) == tonumber(m_hid))then
				isOn = true
				break
			end
		end
	end

	local isOn = isOn or isBench
	return isOn
end

-- 更改buff状态
function setBuffInfo( pTag,pStatus )
	-- body
	_copyInfo["va_pass"]["buffShow"][tonumber(pTag)]["status"] = pStatus
end

-- buff
function getCopyBuff()
	local buff = {}
	if( not table.isEmpty(_copyInfo.va_pass) )then
		buff = _copyInfo.va_pass.buffInfo
	end

	return buff
end

-- hpNum
function setHpNum( pHpNum,hid )
	-- body
	_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currHp"] = pHpNum
end

-- RangeNum
function setRangeNum( pRangeNum,hid )
	-- body
	_copyInfo["va_pass"]["heroInfo"][tostring(hid)]["currRage"] = pRangeNum
end

-- 星星数
function getStarNumber()
	local stars = 0
	if ( _copyInfo.star_star ) then
		stars = tonumber(_copyInfo.star_star)
	end
	return stars
end

-----------------------------------getOpponentList----------------------------------------
-- 0 => array
-- 		{
-- 		    uid,
-- 		    utid,
-- 		    name,
-- 		    level,
-- 		    fightForce,
-- 		    attackBefore,
-- 		    arrHero = array
-- 		    (
-- 		        pos => array(
-- 		                        hid,
-- 		                        htid,
-- 		                        level,
-- 		                        evolve_level,
-- 		                        currRage,
-- 		                    )
-- 		    );
-- 		},
-- 1 => array{},
-- 2 => array{},
--------------------------------------------------------------------------------------

-- 设置对手信息数据
function setOpponentInfo( data )
	_OpponentInfo = data
end

-- 得到对手信息数据
function getOpponentInfo( ... )
	return _OpponentInfo
end

-----------------------------------getRankList----------------------------------------
 --'top' => array
 --        (
 --         rank =>
 --                uid,
 --                utid,
 --                name,
 --                level,
 --                guild_name,
 --                point,
 --        )
 -- 'myRank' => int
--------------------------------------------------------------------------------------

-- 设置排行信息数据
function setRankInfo( data )
	_RankInfo = data
end

-- 得到排行信息数据
function getRankInfo( ... )
	return _RankInfo
end

-----------------------------------attack----------------------------------------
-- 攻击一个据点的某一个难度

-- return:
--  appraisal =>''
--  fightStr =>''
--------------------------------------------------------------------------------------
-- 设置战斗信息数据
function setAttackInfo( data )
	_AttackInfo = data
end

-- 得到战斗信息数据
function getAttackInfo( ... )
	return _AttackInfo
end

-----------------------------------dealChest----------------------------------------
-- 攻击一个据点的某一个难度

-- return:
--  appraisal =>''
--  fightStr =>''
--------------------------------------------------------------------------------------
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

--设置购买金币宝箱次数
function setluxuryNum( pNum )
	-- body
	_copyInfo.luxurybox_num = pNum
end

--设置副本星数
function setStarNum( pNum )
	-- body
	_copyInfo.star_star = pNum
end

--判断通关
function isHavePass( ... )
	-- body
	local allPass = false
	if(tonumber(_copyInfo["pass_num"])==table.count(DB_Overcome.Overcome))then
		allPass = true
	end
	return allPass
end

--不得已而为之
-- 当前是否是最后一关
function isEndCopy()
	if( table.count(DB_Overcome.Overcome) - tonumber(_copyInfo["pass_num"])== 1) then
		return true
	end
	return false
end

--判断发奖
function isRewardTime( ... )
	-- body
	local isRewardTime = false
	local mergeTime = TimeUtil.getSvrTimeByOffset(0)
	mergeTime = TimeUtil.getTimeAtDay(mergeTime)
	local userInfo = UserModel.getUserInfo()
    if userInfo == nil then
        return
    end
    local endTime = tonumber(userInfo["timeConf"]["pass"]["handsOffBeginTime"])+tonumber(userInfo["timeConf"]["pass"]["handsOffLastSeconds"])
	if(tonumber(mergeTime)<tonumber(userInfo["timeConf"]["pass"]["handsOffBeginTime"]) or tonumber(mergeTime)>endTime)then
		isRewardTime 	= false
	else
		isRewardTime 	= true
	end
	return isRewardTime
end

-- 场景
function getCopyBgName()
	local bgName = "copy_1.jpg"
	if( not table.isEmpty(_copyInfo)  )then
		local overcomeInfo = DB_Overcome.getDataById(_copyInfo.cur_base)
		bgName = overcomeInfo.copyBackground
	end

	return bgName
end

-- 设置普通宝箱已经完成
function setNormalBoxOver()
	if(not table.isEmpty(_copyInfo.va_pass) )then
		if (table.isEmpty(_copyInfo.va_pass.chestShow) ) then
			_copyInfo.va_pass.chestShow = {}
		end
		_copyInfo.va_pass.chestShow.freeChest = 1
	end
end

-- 设置金币宝箱已经完成
function setGoldBoxOver()
	if(not table.isEmpty(_copyInfo.va_pass) )then
		if (table.isEmpty(_copyInfo.va_pass.chestShow) ) then
			_copyInfo.va_pass.chestShow = {}
		end
		_copyInfo.va_pass.chestShow.goldChest = 1
	end
end

function setEnterInfo( passData,pCurBase,pPassNum,pPoint,pStar,pLoseNum,pBuyNum )
	-- body
	_copyInfo.va_pass = passData
	_copyInfo.cur_base = tonumber(pCurBase)
	_copyInfo.pass_num = tonumber(pPassNum)
	_copyInfo.point = pPoint
	_copyInfo.star_star = pStar
	_copyInfo.lose_num = pLoseNum
	_copyInfo.buy_num = pBuyNum
end

-- 不得已而为之
-- 是否此关仅差这一项 当前关卡就完成了
--mark one if no else
function justRemainOnce()
	local str = (isBattlePass() == true) and (isNormalBoxPass() == true) and (isGodBoxPass() == true) and (isBuffPass() == true)
	return str
end

-- 战斗是否已经完成
function isBattlePass()
	local isPass = false
	if ( tonumber(_copyInfo["pass_num"]) == tonumber(_copyInfo["cur_base"]) ) then
		isPass = true
	end

	return isPass
end

-- 普通宝箱是否完成
function isNormalBoxPass()
	local isPass = false
	local overcomeInfo = DB_Overcome.getDataById(_copyInfo.cur_base)
	if( overcomeInfo.fixedNumber == nil)then
		isPass = true
	else
		if(not table.isEmpty(_copyInfo.va_pass) and not table.isEmpty(_copyInfo.va_pass.chestShow) )then
			if(tonumber(_copyInfo.va_pass.chestShow.freeChest) == 1 )then
				isPass = true
			end
		end
	end

	return isPass
end


-- 金币宝箱是否完成
function isGodBoxPass()
	local isPass = false
	local overcomeInfo = DB_Overcome.getDataById(_copyInfo.cur_base)
	if( overcomeInfo.goldNumber == nil)then
		isPass = true
	else
		if(not table.isEmpty(_copyInfo.va_pass) and not table.isEmpty(_copyInfo.va_pass.chestShow) )then
			if(tonumber(_copyInfo.va_pass.chestShow.goldChest) == 1)then
				isPass = true
			end
		end
	end

	return isPass
end


-- Buff是否已经完成
function isBuffPass()
	local isPass = true
	local overcomeInfo = DB_Overcome.getDataById(_copyInfo.cur_base)
	if( overcomeInfo.randomBuff ~= nil)then
		if(not table.isEmpty(_copyInfo.va_pass) and not table.isEmpty(_copyInfo.va_pass.buffShow) )then
			for k, buff_info in pairs(_copyInfo.va_pass.buffShow) do
				if(tonumber(buff_info.status) == 0 )then
					isPass = false
					break
				end
			end
		else
			isPass = false
		end
	end

	return isPass
end

------------- 副本阵型
function getFormationInfo()
	return _posInfo
end

function setFormationInfo(pInfo)
	_posInfo = pInfo

	local index = 0
	for k,v in pairs(_copyInfo.va_pass.formation)do
		index = index+1
		print("index=="..index)
		if(index<7)then
			if(pInfo[tostring(index-1)]~=nil)then
				_copyInfo.va_pass.formation[index] = pInfo[tostring(index-1)]
			else
				_copyInfo.va_pass.formation[index] = pInfo[(index-1)]
			end
		else
			break
		end
	end
end

--设置加过buff的table
function setClickTable( pTable )
	-- body
	_clickTable = pTable
end
--
function getClickTable()
	-- body
	return _clickTable
end

function setChooseHeroData( p_HeroData )
	-- body
	_chooseHeroData = p_HeroData
end

function getChooseHeroData( ... )
	-- body
	return _chooseHeroData
end

function setChooseWhich( p_Index )
	-- body
	_pIndex = p_Index
end

function getChooseWhich( ... )
	-- body
	return _pIndex
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
	return _copyInfo.buy_num
end

function addBuyTimes( p_Times )
	-- body
	_copyInfo.buy_num = _copyInfo.buy_num+p_Times
end
function setBenchData( p_Data )
	-- body
	for k,v in pairs(p_Data)do
		_copyInfo.va_pass.bench[k] = p_Data[k]
	end
end

function isHaveSweep()
	--是否扫荡过
	return _copyInfo.va_pass.sweepInfo.isSweeped
end

function lastPassNum()
	--上次通关数
	local passNumLastTime = tonumber(_copyInfo.va_pass.sweepInfo.count)
	return passNumLastTime
end

function isCanSweep()
	local isAlreadySweep = isHaveSweep()
	local passNumLastTime = lastPassNum()
	if(isAlreadySweep~=true and isAlreadySweep~="true" and tonumber(passNumLastTime)>1)then
		print("true")
		return true
	else
		print("false")
		return false
	end
end

function setHaveSweep()
	-- body
	_copyInfo.va_pass.sweepInfo.isSweeped = true
end

function isBuyChestBefore()
	--购买宝箱数量
	local alreadyBuyChest = tonumber(_copyInfo.va_pass.sweepInfo.buyChest)
	if(alreadyBuyChest~=0)then
		return true
	else
		return false
	end
end

function isBuyBuffBefore()
	--购买buff
	local alreadyBuyBuff = tonumber(_copyInfo.va_pass.sweepInfo.buyBuff)
	if(alreadyBuyBuff~=0)then
		return true
	else
		return false
	end
end

function setSweepResult( pResult )
	-- body
	_sweepResult = pResult
end

function setCurBase()
	-- body
	_copyInfo.va_pass.sweepInfo.count = _copyInfo.cur_base
end

function getSweepResult()
	-- body
	local itemTable = {}
	local buffTable = {}
	for k,v in pairs(_sweepResult)do
		v.baseNum = k
		if(k%2==1)then
			table.insert(itemTable,v)
		else
			table.insert(buffTable,v)
		end
	end
	local function keySort ( itemTable1, itemTable2 )
		return tonumber(itemTable1.baseNum) < tonumber(itemTable2.baseNum)
	end
	table.sort(itemTable,keySort)

	local function keySortBuff ( buffTable1, buffTable2 )
		return tonumber(buffTable1.baseNum) < tonumber(buffTable2.baseNum)
	end
	table.sort(buffTable,keySortBuff)
	return itemTable,buffTable
end