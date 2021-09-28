-- Filename：	ScoreWheelData.lua
-- Author：		DJN
-- Date：		2014-11-5
-- Purpose：		积分轮盘数据
module("ScoreWheelData", package.seeall)
require "script/model/utils/ActivityConfig"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"

local _signData = {}  --从后端获取的当前已经转的信息
local _wheelData = {}  --从后端获取转盘结果
local _needGold = nil   -- 记录要扣多少金币
local vip = tonumber(UserModel.getVipLevel())

--print("获取的vip",vip)
local todayFreemNum = tonumber(DB_Vip.getDataById(vip+1).FreeTimes)
--local totalGoldNum = tonumber(DB_Vip.getDataById(vip+1).Totalnum)
local scorePerTime =  ActivityConfig.ConfigCache.roulette.data[1]["WheelScore"]

local _myRank = nil  -- 自己的排名信息
local _rankList = {} -- 排行榜数据

--得到一个table k 为宝箱id  v为宝箱id和对应领取达到的积分
function getBoxId( ... )
	local goods = ActivityConfig.ConfigCache.roulette.data[1]["BoxId"]
 --    print("goods解析前")
	-- print_t(goods)
    goods = analyzeStrToTable(goods)
    -- print("输出解析后的good")
    -- print_t(goods)
    return goods

end
--"1|2,7|4,13|6,19|8"
--将数据表中的奖励 **|**|**转换成table的形式
function analyzeStrToTable( goodsStr )
	if(goodsStr == nil)then
	    return
	end
	local goodsData = {}
	local goodTab = string.split(goodsStr, ",")

	local tableCount = table.count(goodTab)
	for i = 1,tableCount do
	    local tab = string.split(goodTab[i],"|")
	    table.insert(goodsData,tab)
	end
	return goodsData
end

local _boxTable = getBoxId()

function setSignData(data)
	-- print("setSignData")
	-- print_t(data)
    _signData = data
    _signData.today_free_num = tonumber(_signData.today_free_num)
    _signData.accum_free_num = tonumber(_signData.accum_free_num)
    _signData.accum_gold_num = tonumber(_signData.accum_gold_num)
    _signData.integeral = tonumber(_signData.integeral)
    _signData.isReceived = tonumber(_signData.isReceived)
end

function getSignData(  )
	return _signData
end

function updateSignData(p_freetime,p_goldtime)
	local freetime = tonumber(p_freetime)
	local goldtime = tonumber(p_goldtime)
	
	if(freetime ~= 0)then
		if((_signData.today_free_num + freetime) <= todayFreemNum)then
			_signData.today_free_num = _signData.today_free_num + freetime
			_signData.integeral = _signData.integeral + (freetime * scorePerTime)
			--print("更新免费次数",freetime)
		end
	end
	if(goldtime ~= 0)then
		--if((_signData.accum_gold_num + goldtime) <= totalGoldNum)then
		_signData.accum_gold_num = _signData.accum_gold_num + goldtime
		_signData.integeral = _signData.integeral + (goldtime * scorePerTime)
			--print("更新金币购买次数",goldtime)
		--end
	end
	-- print("_boxTable")
	-- print_t(_boxTable)
	for k,v in pairs(_boxTable)do
		if(tonumber(getBoxStatus(k)) == 1)then
			if(tonumber(v[2]) <= _signData.integeral)then
				updateBoxData(k,2)
				
			end
		end
	end
end

function updateBoxData(p_box,p_status)
	p_box = tonumber(p_box)
    p_status = tonumber(p_status)
	-- print("更新箱子状态前")
	-- print_t(_signData.va_boxreward)
	_signData.va_boxreward[p_box].status = p_status

	-- print("更新箱子状态成功,第*个箱子",p_box)
	-- print_t(_signData.va_boxreward)
end

function setWheelData( data )
	_wheelData = data
end

function getWheelData( ... )
	return _wheelData
end


function setNeedGold( num )
	_needGold = tonumber(num)
end

function getNeedGold( ... )
	return _needGold
	--_needGold = nil
end

--"1|2,7|4,13|6,19|8"
--将数据表中的奖励 **，**，**转换成table的形式
function analyzeDateTabStr( goodsStr )
	if(goodsStr == nil)then
	    return
	end
	local goodsData = {}
	local goodTab = string.split(goodsStr, ",")

	local tableCount = table.count(goodTab)
	for i = 1,tableCount do
	    local tab = goodTab[i]
	    table.insert(goodsData,tab)
	end
	return goodsData
end
--获取创建转盘用的物品表
function getRaffleItems( ... )
	-- require "db/DB_ScoreWheel"
 --    local goods = DB_ScoreWheel.getDataById(1).WheelReward
    
    local goods = ActivityConfig.ConfigCache.roulette.data[1]["WheelReward"]
    goods = analyzeDateTabStr(goods)
    -- print("输出解析后的good")
    -- print_t(goods)
    return goods
end

--"1|2,7|4,13|6,19|8"
--将数据表中的奖励 **|**|**转换成table的形式
function analyzeStrToTable( goodsStr )
	if(goodsStr == nil)then
	    return
	end
	local goodsData = {}
	local goodTab = string.split(goodsStr, ",")

	local tableCount = table.count(goodTab)
	for i = 1,tableCount do
	    local tab = string.split(goodTab[i],"|")
	    table.insert(goodsData,tab)
	end
	return goodsData
end
--获取转盘动作需要的物品表
function getItemsForAction( ... )
	local goods = ActivityConfig.ConfigCache.roulette.data[1]["WheelReward"]
    goods = analyzeStrToTable(goods)
    -- print("输出解析后的good,用于action")
    -- print_t(goods)
    return goods

end

--得到对应tag宝箱的奖励
function getBoxReward( tag )
	local goods = ActivityConfig.ConfigCache.roulette.data[1]["BoxReward"..tag]
	-- print("宝箱奖励")
 --    print(goods)
	return goods
end
--解析一下宝箱奖励，用于展示
function getBoxRewForShow(tag)	

	local goods = ItemUtil.getItemsDataByStr(getBoxReward(tag))
	-- print("解析后的宝箱奖励，用于展示")
	-- print_t(goods)
	return goods

end
--得到对应tag宝箱的领取状态
function getBoxStatus (tag)
    local info = getSignData()
    --local idTag = tostring(tag-1)
    -- print("获取的对应宝箱的状态",info.va_boxreward[idTag].status)
    -- return info.va_boxreward[idTag].status
    --print("获取的对应宝箱的状态",info.va_boxreward[tag].status)
    return info.va_boxreward[tag].status
end
--发奖
function updateReward(table)
	print_t(table)
	if(table ~= nil)then
		ItemUtil.addRewardByTable(table)
	end
end
--获取转一次的花费
function getOneCost( ... )
	return ActivityConfig.ConfigCache.roulette.data[1]["WheelCost"]
end
--得到点击转盘上的icon后用于展示奖励预览的list
function getItemPreviewList(p_tag)
	local rewardList = ActivityConfig.ConfigCache.roulette.data[1]["drop_"..p_tag]
	--rewardList最后还有一个权重，后端用，前端只用到前三个字段 类型|id|数量
	rewardList = ItemUtil.getItemsDataByStr(rewardList)
	return rewardList
end
--[[
    @des    :对排名进行重新排序,防止后端数据在网络解析时出错
    @param  :
    @return :
--]]
local function rankSort ( goods_1, goods_2 )
    return tonumber(goods_1.rank) < tonumber(goods_2.rank)
    end
--设置排行榜数据
function setRankData(p_data)
	--print("setRankData",p_data.rank)
	--print("SET MY RANK",p_data.rank)
	_myRank = tonumber(p_data.rank)
	_rankList = p_data.list
	table.sort( _rankList, rankSort )
end
--获取个人排名
function getPersonRank( ... )
	--print("myrank",_myRank)
	return _myRank
end
--获取排行榜list
function getRankList( ... )
	-- print("这就是我给你的排行榜")
	-- print_t(_rankList)
	return _rankList
end
--获取个人是否处在可领奖励的排名中
function ifInRank( ... )
	local netCb = function ( ... )
		local rankNum = table.count(_rankList)
		--print("榜内共有*个人",rankNum)
		--print("ifInRank _myRank,rankNum",_myRank,rankNum)
		if(_myRank <= rankNum )then
			--print("上榜了")
			return true
		else
			--print("没上榜")
			return false
		end
	end
	if(table.isEmpty(_rankList ) )then
		ScoreWheelService.getRankInfo(netCb)
	else
		netCb()
	end
	
	
end
--获取这个人的积分是否达到领奖标准
function isScoreEnhough( ... )
	--兼容
	if(ActivityConfigUtil.getDataByKey("roulette").data[1].rankscoreslimit ~= nil)then
		return _signData.integeral >= tonumber(ActivityConfigUtil.getDataByKey("roulette").data[1].rankscoreslimit)
	else
		return false
	end
end
--获取这个人是否已经领过奖励 领取过为1 没领取过为0
function ifGotReward( ... )
	return _signData.isReceived == 1
end
--设置这个人的领奖状态
function setIsReceived( p_state)
	_signData.isReceived = tonumber(p_state)
end
-- --获取个人是否有奖励未领取(做排名判断，是否已经领取判断)，
-- function ifHaveReward( ... )
-- 	if(_signData.isReceived == 0 and ifInRank() )then
-- 		return true
-- 	else
-- 		return false
-- 	end
-- end
--获取当前是否在可转盘期
function  isInWheel( ... )
	local startTime = ActivityConfigUtil.getDataByKey("roulette").start_time
	local wheelDay = ActivityConfigUtil.getDataByKey("roulette").data[1].wheelopentime --配置为聚宝期的天数
	if(wheelDay ~= nil)then
		--local curTime = TimeUtil.getSvrTimeByOffset()

		if(TimeUtil.getDifferDay(startTime) < tonumber(wheelDay))then
			return true
		else
			return false
		end
	else
		--兼容
		return true
	end
	
end
--获取奖励list
--奖励表配在活动配置里了，标题写死的，得到老大的确认了。。。就这么整吧。。。不得已而为之[摊手]
function getRewardList( ... )
	local rewardList = {}
	if(ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward1 ~= nil)then
		rewardList[1] = {}
		rewardList[2] = {}
		rewardList[3] = {}
		rewardList[4] = {}
		rewardList[5] = {}
		rewardList[1].reward = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward1
		
		rewardList[2].reward = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward2
		
		rewardList[3].reward = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward3
		
		rewardList[4].reward = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward4_10
		
		rewardList[5].reward = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward11_20
		local kuafuState,kuafu_num = getKuafuStateAndNum()
    	if(kuafuState)then
	        --有合服
	        local lastNum = 1
	        rewardList[1].title = GetLocalizeStringBy("djn_161",lastNum.."-"..(lastNum+1*kuafu_num-1))
	        lastNum = lastNum+1*kuafu_num
	        rewardList[2].title = GetLocalizeStringBy("djn_161",lastNum .. "-"..(lastNum+1*kuafu_num-1))
	        lastNum = lastNum+1*kuafu_num
	        rewardList[3].title = GetLocalizeStringBy("djn_161",lastNum .. "-"..(lastNum+1*kuafu_num-1))
	        lastNum = lastNum+1*kuafu_num
	        rewardList[4].title = GetLocalizeStringBy("djn_161",lastNum .. "-"..(lastNum+7*kuafu_num-1))
	        lastNum = lastNum+7*kuafu_num
	        rewardList[5].title = GetLocalizeStringBy("djn_161",lastNum .. "-"..(lastNum+10*kuafu_num-1))
	        lastNum = lastNum+10*kuafu_num
	    else
	    	rewardList[1].title = GetLocalizeStringBy("djn_161",1)
	    	rewardList[2].title = GetLocalizeStringBy("djn_161",2)
	    	rewardList[3].title = GetLocalizeStringBy("djn_161",3)
	    	rewardList[4].title = GetLocalizeStringBy("djn_161","4-10")
	    	rewardList[5].title = GetLocalizeStringBy("djn_161","11-20")
    	end
	end
	return rewardList

end
--获取可领取排行奖励的最小积分（当然前提是在榜内）
function getMinScoreForReward( ... )
	-- body
	if(ActivityConfigUtil.getDataByKey("roulette").data[1].rankscoreslimit ~= nil)then
		return tonumber(ActivityConfigUtil.getDataByKey("roulette").data[1].rankscoreslimit)
	else
		return 0
	end
end
--获取这个人能领取的奖励
--返回的是DB里面的格式
function getMyReward( ... )
	--print("_myRank")
	local rewardTable = nil
	if(ifInRank() == false )then
        --没在榜上
	else
		--人生自古谁不蛋疼。。。。
		if(_myRank == 1)then
			rewardTable = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward1
		elseif(_myRank == 2)then
			rewardTable = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward2
		elseif(_myRank == 3)then
			rewardTable = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward3
		elseif(_myRank <= 10)then
			rewardTable = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward4_10
		elseif(_myRank <= 20)then
			rewardTable = ActivityConfigUtil.getDataByKey("roulette").data[1].rankreward11_20
		else

		end
	end
	--print("rewardTable",rewardTable)
	return rewardTable
end
---判断各个背包是否满了
function isAllBagFull( ... )
	-- 物品背包
	if( ItemUtil.isBagFull())then
		return true
	end
	-- 武将满了
	require "script/ui/hero/HeroPublicUI"
    if HeroPublicUI.showHeroIsLimitedUI() then
    	return true
    end
	-- 宠物背包满了
	require "script/ui/pet/PetUtil"
	if PetUtil.isPetBagFull() == true then
		return true
	end
	return false
end
---获得可转盘时间的截止时间戳
function getWheelEndTime( ... )
	local startTime = ActivityConfigUtil.getDataByKey("roulette").start_time
    startTime = TimeUtil.getCurDayZeroTime(startTime)
	local wheelDay = tonumber(ActivityConfigUtil.getDataByKey("roulette").data[1].wheelopentime) --配置转盘的天数
	if(wheelDay ~= nil)then
		return startTime + (86400 * wheelDay) - 1
	else
		return tonumber(ActivityConfigUtil.getDataByKey("roulette").end_time)
	end

end
------判断当前是否在整个活动的最后一小时 （如果在最后一小时的时候，排行奖励不能手动领取）
function isInLastOneHour( ... )
    local curTime = TimeUtil.getSvrTimeByOffset()
    local endTime = ActivityConfigUtil.getDataByKey("roulette").end_time - 60*60*1
    if(curTime > endTime)then
    --已经处于活动的最后一小时
    	return true
	else
		return false
	end
end
-----获取跨服的数量 如果活动期没发生跨服 返回1
function getKuafuStateAndNum( ... )
	local kuafu_num = 1
	--print("UserModel.getUserInfo().mergeServerCount",UserModel.getUserInfo().mergeServerCount)
	
    if(tonumber(UserModel.getUserInfo().mergeServerCount) > 1 )then
    	--有合服
	    local activeZeroTime = TimeUtil.getCurDayZeroTime(ActivityConfigUtil.getDataByKey("roulette").start_time)
	    local mergeZeroTime = TimeUtil.getCurDayZeroTime(UserModel.getUserInfo().mergeServerTime)
	    --print("activeZeroTime,mergeZeroTime",activeZeroTime,mergeZeroTime)
	    if(activeZeroTime <= mergeZeroTime)then
	    	--是活动开始后合服的
	    	local wheelDay = ActivityConfigUtil.getDataByKey("roulette").data[1].wheelopentime --配置为聚宝期的天数
			if(wheelDay ~= nil)then
				--local curTime = TimeUtil.getSvrTimeByOffset()
				if(tonumber(UserModel.getUserInfo().mergeServerTime) <= activeZeroTime + wheelDay*86400)then
					--是在转盘期间和服的
					return true,tonumber(UserModel.getUserInfo().mergeServerCount)>5 and 5 or tonumber(UserModel.getUserInfo().mergeServerCount)
				end
			else
				--兼容老配置
				return true,tonumber(UserModel.getUserInfo().mergeServerCount)>5 and 5 or tonumber(UserModel.getUserInfo().mergeServerCount)
			end
		end
    end
    return false,kuafu_num
end