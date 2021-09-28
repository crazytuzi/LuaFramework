-- FileName: MatchData.lua 
-- Author: Li Cong 
-- Date: 13-11-7 
-- Purpose: function description of module 

require "script/model/user/UserModel"
module("MatchData", package.seeall)

m_allData 					= nil 					-- 比武场得到的全部信息
m_userData 					= nil					-- 比武场玩家列表
m_useXmlData 				= nil					-- 今天使用的配置数据
m_refreshDownTime			= nil					-- 刷新倒计时
m_refreshScheduleId  		= nil					-- 刷新倒计时定时器
m_enemyData					= nil					-- 仇人列表
m_rankingListData 			= nil					-- 排行榜数据
m_top3Data					= nil					-- top3数据
m_rewardTime				= nil					-- 发奖倒计时
m_rewardState 				= nil					-- 发奖状态			
m_matchState				= nil					-- 比武场现在状态 0没有开始，1比武，2休息，3发奖
m_usedNum					= nil					-- 已用比武的次数

-- 得到今天读取的配置信息
function getXmlData( id )
	require "db/DB_Contest"
	local data = DB_Contest.getDataById(id)
	return data
end


-- 得到比武胜利后获得的积分数
-- 胜利积分 = 胜利基础积分+min(掠夺积分最大值，被攻击方积分*胜利积分比例)
function getWinScore( user_score )
	local data = nil
	data = tonumber(m_useXmlData.winBasescore) + math.min( tonumber(m_useXmlData.maxSorce), tonumber(user_score)*tonumber(m_useXmlData.winSorceratio)*0.0001 )
	return data
end

-- 得到比武失败后扣除的积分数
-- 失败积分 = 失败基础积分+ min(掠夺积分最大值，被攻击方积分*失败积分比例)
function getLoseScore( user_score )
	local data = nil
	data = tonumber(m_useXmlData.loseBasescore) + math.min( tonumber(m_useXmlData.maxSorce), tonumber(user_score)*tonumber(m_useXmlData.loseSorceratio)*0.0001 )
	return data
end

local colorTab = {ccc3(0x00,0xe4,0xff),ccc3(0x00,0xe4,0xff),ccc3(0xff,0xf6,0x00),ccc3(0xf9,0x59,0xff),ccc3(0xf9,0x59,0xff)}
local nameTab = {"lan","lan","huang","zi","zi"}
-- 得到获得的胜利积分描述
function getDescFromWinScore( win_score )
	local tScore = string.split(m_useXmlData.scoreArr, ",")
	local tDesc = string.split(m_useXmlData.scoreDec, ",")
	local des_key = nil
	-- print("tScore")
	-- print_t(tScore)
	for k,v in pairs(tScore) do
		print("win_score",tonumber(win_score))
		print("v",tonumber(v))
		if(tonumber(win_score) <= tonumber(v))then
			des_key = k
			break
		end
	end
	if(des_key == nil)then
		des_key = #tDesc
	end
	local color = colorTab[des_key]
	local name = nameTab[des_key]
	-- print("des_key",des_key)
	return tDesc[des_key], color, name
end


-- 今天是否休息，休息期间禁止比武复仇，是发奖时间
-- 返回true 是休息
function getIsRest()
	-- 当前服务器时间
    local curServerTime = BTUtil:getSvrTimeInterval()
    print("curServerTime",curServerTime)
	local date = os.date("*t", curServerTime)
	-- print_t(date)
	-- print(date.wday)
	local today = tonumber(date.wday) - 1
	print("today",today)
	print("m_useXmlData.releaseTime",m_useXmlData.releaseTime)
	print("table.count(m_top3Data)",table.count(m_top3Data))
	-- m_top3Data：后端返回不是空数组就是休息时间
	if( table.count(m_top3Data) ~= 0 or today == tonumber(m_useXmlData.releaseTime) )then
		return true
	else 
		return false
	end
end

---------------------------------------- 暂费 ----------------------------------------
-- 判断发奖状态
-- 返回 start end
-- function getRewardState( time )
-- 	if( tonumber(time) <= 0)then
-- 		return "start"
-- 	end
-- 	if(tonumber(time) > 0)then
-- 		-- 当前服务器时间
-- 	    local curServerTime = BTUtil:getSvrTimeInterval()
-- 	    print("curServerTime",curServerTime)
-- 		local date = os.date("*t", curServerTime)
-- 		-- print_t(date)
-- 		-- print(date.hour)
-- 		local today = tonumber(date.wday) - 1
-- 		local curHour = tonumber(date.hour)
-- 		local curMin = tonumber(date.min)
-- 		print("today",today)
-- 		print("m_useXmlData.releaseTime",m_useXmlData.releaseTime)
-- 		print("curHour",curHour)
-- 		print("curMin",curMin)
-- 		if(today == tonumber(m_useXmlData.releaseTime))then
-- 			return "end"
-- 		end
-- 		local rewardDay = tonumber(m_useXmlData.releaseTime) - 1
-- 		if( today == rewardDay and curHour > 23  and curMin > 30 )then
-- 			return "end"
-- 		end
-- 	end
-- end


-- 判断是否是8:00:00-23:00:00点 
-- true:在比武时间 可比武
-- false:不在这个时间段 不可比武
-- function getIsOverMatchTime( ... )
-- 	-- 当前服务器时间
--     local curServerTime = BTUtil:getSvrTimeInterval()
--     print("curServerTime",curServerTime)
-- 	local date = os.date("*t", curServerTime)
-- 	-- print_t(date)
-- 	-- print(date.hour)
-- 	local curHour = tonumber(date.hour)
-- 	local curMin = tonumber(date.min)
-- 	print("curHour",curHour)
-- 	print("curMin",curMin)
-- 	if( curHour <= 8 and  curHour >= 23 )then
-- 		return true
-- 	else 
-- 		return false
-- 	end
-- end
----------------------------------------------------------------------------------


-- 判断发奖状态
-- 返回 start end
-- 根据后端state字段判断当前比武场状态
-- 0没有开始，1比武，2休息，3发奖
function getRewardState()
	if( tonumber(m_matchState) == 0)then
		return "noOpen"
	elseif( tonumber(m_matchState) == 1 )then
		return "open"
	elseif(tonumber(m_matchState) == 3)then
		return "start"
	elseif(tonumber(m_matchState) == 2)then
		return "end"
	end
end


-- 判断是否是8:00:00-23:00:00点  这个时间读表
-- true:在比武时间 可比武
-- false:不在这个时间段 不可比武
function getIsOverMatchTime( ... )
	require "script/utils/TimeUtil"
	-- 当前服务器时间
    local curServerTime = BTUtil:getSvrTimeInterval()
    print("curServerTime",curServerTime)
	local star_time = m_useXmlData.startime
	local end_time = m_useXmlData.overtime
	local star_time_interval 	= TimeUtil.getIntervalByTime(star_time) 
	local end_time_interval 	= TimeUtil.getIntervalByTime(end_time)
	print("curServerTime",curServerTime)
	print("star_time_interval",star_time_interval)
	print("end_time_interval",end_time_interval)
	if(curServerTime >= star_time_interval and curServerTime <= end_time_interval) then
		return true
	else 
		return false
	end
end


-- 得到刷新倒计时
function getDownTimeData( ... )
	return m_refreshDownTime
end

-- 设置刷新倒计时
function setDownTimeData( data )
	m_refreshDownTime = data
end


-- 得到表配置刷新CD时间
function getCDTiemFormXml( ... )
	return tonumber(m_useXmlData.cd)
end


-- 通过uid获得对应的玩家信息
function getInfoByuid( uid )
	local data = nil
	for k,v in pairs(m_userData) do
		if(tonumber(uid) == tonumber(v.uid))then
			data = v
		end
	end
	return data
end


-- 得到挑战胜利后获得的exp
-- 表配置*自己等级
function getExpForWin()
	local base_exp = tonumber(m_useXmlData.winExp)
	require "script/model/user/UserModel"
	local level = tonumber(UserModel.getUserInfo().level)
	return base_exp*level
end


-- 得到挑战失败后获得的exp
-- 表配置*自己等级
function getExpForFail()
	local base_exp = tonumber(m_useXmlData.loseExp)
	require "script/model/user/UserModel"
	local level = tonumber(UserModel.getUserInfo().level)
	return base_exp*level
end

-- 得到挑战胜利后获得的winHonor
-- 表配置
function getHonorForWin()
	local base_honor = tonumber(m_useXmlData.winHonor)
	return base_honor
end

-- 设置自己的积分
function setMyScore( num )
	if(m_allData == nil)then
		return
	end
	m_allData.point = math.floor( tonumber(num) )
end

-- 获得自己的积分
function getMyScore( ... )
	local point = nil
	if(m_allData ~= nil)then
		point = tonumber(m_allData.point)
	end
	return point
end

-- 设置自己的排名
function setMyRank( num )
	if(m_allData == nil)then
		return
	end
	m_allData.rank = num
end

-- 获得自己的排名
function getMyRank( ... )
	local rank = nil
	if(m_allData ~= nil)then
		if(tonumber(m_allData.rank) == 0)then
			rank = "--"
		else
			rank = tonumber(m_allData.rank)
		end
	end
	return rank
end

-- 通过uid获得对应的玩家信息
function getInfoByEnemyUid( uid )
	local data = nil
	for k,v in pairs(m_enemyData) do
		if(tonumber(uid) == tonumber(v.uid))then
			data = v
		end
	end
	return data
end


-- 修改仇人的积分
-- uid: 仇人uid
-- sub_score: 仇人要扣除的分数
function setEnemyScore(uid, sub_score)
	if(m_enemyData == nil)then
		return
	end
	for k,v in pairs(m_enemyData) do
		if( tonumber(uid) == tonumber(v.uid) )then
			local data = tonumber(v.point) - tonumber(sub_score)
			v.point = data
		end
	end
end

-- 得到比武总次数
function getAllContestNum( ... )
	-- 得到自己的VIP等级
	local vip_num = UserModel.getVipLevel()
	require "db/DB_Vip"
	local vip_data = DB_Vip.getDataById( tonumber(vip_num)+1 )
	local num = 0
	local tab = string.split(vip_data.contestNum, "|")
	num = tonumber(tab[1])
	return num
end

--  得到比武的剩余次数
function getContestNum()
	local maxNum = getAllContestNum() + getBuyNum()
	num = maxNum - m_usedNum
	return num
end

-- 得到可以购买的次数 和 每次购买的费用
function getCanBuyMaxNum( ... )
	-- 得到自己的VIP等级
	local vip_num = UserModel.getVipLevel()
	require "db/DB_Vip"
	local vip_data = DB_Vip.getDataById( tonumber(vip_num)+1 )
	local num = 0
	local tab = string.split(vip_data.contestNum, "|")
	num = tonumber(tab[2])
	local costNum = tonumber(tab[3])
	return num, costNum
end

-- 增加已用的次数
function addContestNum( addNum )
	m_usedNum = m_usedNum + tonumber(addNum)
end


-- 删除成功复仇的玩家
function deleteEnemybyUid( uid )
	if(m_enemyData == nil)then
		return
	end
	for k,v in pairs(m_enemyData) do
		if( tonumber(uid) == tonumber(v.uid) )then
			table.remove(m_enemyData,k)
		end
	end
end

------------------------------ 购买次数 ------------------------------

local _buyNum 				= 0 -- 已购买次数

-- 设置已购买次数
function setBuyNum( p_num )
	_buyNum = tonumber(p_num)
end

-- 得到购买次数
function getBuyNum()
	return _buyNum
end

-- 增加购买次数
function addBuyNum( p_num )
	_buyNum = _buyNum + tonumber(p_num)
end


----------------------------- 荣誉商城 ------------------------------
local _honorShopInfo 	= nil  -- 荣誉商城信息

-- 得到荣誉值
function getHonorNum()
	return UserModel.getHonorNum()
end

-- 扣除荣誉值
function subHonorNum( p_num )
	UserModel.addHonorNum( - tonumber(p_num) )
end

-- 加荣誉值
function addHonorNum( p_num )
	UserModel.addHonorNum( tonumber(p_num) )
end

-- 设置商城信息
function setShopInfo( p_info )
	_honorShopInfo = p_info
end

-- 设置商城信息
function getShopInfo()
	return _honorShopInfo 
end


-- 得到表配置的所有商品数据
function getArenaShopDBInfo()
	require "db/DB_Contest_shop"
	local tData = {}
	for k, v in pairs(DB_Contest_shop.Contest_shop) do
		table.insert(tData, v)
	end
	local allGoods = {}
	for k,v in pairs(tData) do
		-- isSold为1的显示到出售列表
		if( tonumber(DB_Contest_shop.getDataById(v[1]).isSold) == 1 )then
			table.insert(allGoods, DB_Contest_shop.getDataById(v[1]))
		end
	end
	tData = nil

	local function keySort ( goods_1, goods_2 )
	   	return tonumber(goods_1.sortType) > tonumber(goods_2.sortType)
	end
	table.sort( allGoods, keySort )

	return allGoods
end

-- 得到商店显示数据  
-- limitType 2:永久次数限制 此类型兑换次数达上限就不显示
function getArenaAllShopInfo()
	local showGoods = {}
	local dbGoods = getArenaShopDBInfo()
	for k,v in pairs(dbGoods) do
		if( tonumber(v.limitType) == 2 )then
			local haveNum = getBuyNumBy(v.id)
			if(haveNum < tonumber(v.baseNum))then
				table.insert(showGoods,v)
			end
		else
			table.insert(showGoods,v)
		end
	end
	return showGoods
end


-- 得到兑换物品的 物品类型，物品id，物品数量
function getItemData( item_str )
	local tab = string.split(item_str,"|")
	print("tonumber(tab[1])",tonumber(tab[1]))
	print("tonumber(tab[2])",tonumber(tab[2]))
	print("tonumber(tab[3])",tonumber(tab[3]))
	return tonumber(tab[1]),tonumber(tab[2]),tonumber(tab[3])
end


-- 获取某个物品的当前购买次数
function getBuyNumBy( goods_id )
	local goods_id = tonumber(goods_id)
	local number = 0
	if(_honorShopInfo == nil)then
		return number
	end
	if(not table.isEmpty(_honorShopInfo)) then
		for k_id, v in pairs(_honorShopInfo) do
			if(tonumber(k_id) == goods_id) then
				number = tonumber(v.num)
				break
			end
		end
	end
	return number
end


-- 修改摸个商品的购买次数
function addBuyNumberBy( goods_id, n_addNum )
	local addNum = tonumber(n_addNum)
	if(table.isEmpty(_honorShopInfo)) then
		_honorShopInfo = {}
	end
	if(_honorShopInfo["" .. goods_id])then
		_honorShopInfo["" .. goods_id].num = tonumber(_honorShopInfo["" .. goods_id].num) + addNum
	else
		_honorShopInfo["" .. goods_id] = {}
		_honorShopInfo["" .. goods_id].num = addNum
	end
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













