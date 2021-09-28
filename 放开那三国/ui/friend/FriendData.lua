-- FileName: FriendData.lua 
-- Author: Li Cong 
-- Date: 13-8-27 
-- Purpose: function description of module 


module("FriendData", package.seeall)

-- 所有好友数据
allfriendData = nil
-- 显示好友页数
friendPage = 1
-- 显示好友数据
showFriendData = nil
-- 得到系统推荐好友数据
recomdFriendData = nil
-- 显示推荐好友数据
showRecomdData = nil
-- 显示推荐好友页数
showRecomdPage = 1
-- 搜索的好友数据
searchFriendData = nil
-- 获取体力剩余次数
local receiveTimes = 0
-- 获取体力列表数据
receiveListInfo	= nil
-- 可领取列表数据
local receiveList = nil


-- 得到显示的好友数据
-- 好友数据10个分一页
-- num：是大于从1开始 点击一次更多按钮加1
function getShowMyFriendData( num )
	if(allfriendData == nil)then
		return
	end
	local tab = {}
	-- 好友总数
	local all_count = table.count(allfriendData)
	-- 如果好友数不超过10个则不用添加更多好友按钮
	if( all_count <= 10 )then
		for i=1,#allfriendData do
			tab[i] = allfriendData[i]
		end
	end
	if( all_count > 10)then
		if( num*10 >= all_count )then
			-- 当数据不满num*10时不用加更多按钮
			for i=1,#allfriendData do
				tab[i] = allfriendData[i]
			end
		else
			for i=1,10*num do
				tab[i] = allfriendData[i]
			end
			-- 在数据最后添加 更多好友 标识
			local temTab = { more = true, status = 3 }
			table.insert(tab,temTab)
		end
	end
	-- print(GetLocalizeStringBy("key_1174"))
	-- print_t(tab)
	return tab
end

-- 得到好友总数
function getAllFriendCount( ... )
	if(allfriendData == nil)then
		return 0
	end
	return table.count(allfriendData)
end


-- 得到好友的姓名
function getMyfriendName( uid )
	local name = nil
	local utid = nil
	for k,v in pairs(allfriendData) do
		if(tonumber(uid) == tonumber(v.uid))then
			name = v.uname
			utid = v.utid
		end
	end
	return name,utid
end


-- 删除好友数据
function deleteFriendData( uid )
	if(allfriendData == nil)then
		return
	end
	local tab = {}
	for k,v in pairs(allfriendData) do
		if(tonumber(v.uid) == tonumber(uid))then
			allfriendData[k] = nil
		else
			tab[#tab+1] = allfriendData[k]
		end
	end
	-- print(GetLocalizeStringBy("key_1172"))
	-- print_t(tab)
	allfriendData = tab
end

-- 是否是好友
function isMyFriendByUid( uid )
	local isFriend = false
	if(allfriendData == nil)then
		return isFriend
	end
	for k,v in pairs(allfriendData) do
		if(tonumber(v.uid) == tonumber(uid))then
			isFriend = true
			break
		end
	end
	return isFriend
end

-- 根据uid得到index
function getIndexByUid( uid )
	local index = 1
	for k,v in pairs(allfriendData) do
		if(tonumber(v.uid) == tonumber(uid))then
			index = tonumber(k)
		end
	end
	return index
end

-- 设置显示数据
function setShowRecomdData( data )
	showRecomdData = data
end

-- 显示推荐好友数据
-- 多于返回4个，不足4个返回全部
-- num:点击更多好友次数  最小为1次
function getShowRecomdData( num )
	-- print(GetLocalizeStringBy("key_1929"))
	-- print_t(showRecomdData)
	-- print(num)
	local tab = {}
	-- 好友总数
	local all_count = table.count(showRecomdData)
	-- 不超过4*num个,显示cout-4*(num-1)个
	if( all_count <= 4*num )then
		for i=4*(num-1)+1, #showRecomdData do
			tab[#tab+1] = showRecomdData[i]
		end
	else
		for i=4*(num-1)+1, 4*num do
			tab[#tab+1] = showRecomdData[i]
		end
	end
	-- print_t(tab)
	return tab
 end 


-- 判断是否有更多好友
-- num:点击更多好友次数
function isHaveMore(num)
	-- 好友总数
	local all_count = table.count(showRecomdData)
	if((num*4 - all_count) >= 4)then
		return false
	else
		return true
	end
end


-- 设置好友上线状态
-- online = 1
function setFriendOnline( tabData )
	for k,v in pairs(allfriendData) do
		for i,j in pairs(tabData) do
			if( tonumber(v.uid) == tonumber(j) )then
				v.status = 1
			end
		end
	end
end

-- 设置好友上线状态
-- offline = 2
function setFriendOffline( tabData )
	for k,v in pairs(allfriendData) do
		for i,j in pairs(tabData) do
			if( tonumber(v.uid) == tonumber(j) )then
				v.status = 2
			end
		end
	end
end


-- 好友排序 在线在前
function sortByOnline()
	-- print("在线排序前")
	-- print_t(showFriendData)
	-- 按时间先后排序 时间由大到小排列
	local function timeUpSort( a, b )
		-- print(".....",a.status,b.status)
		return tonumber(b.status) > tonumber(a.status)
	end
	table.sort( showFriendData, timeUpSort )
	-- print(GetLocalizeStringBy("key_1014"))
	-- print_t(showFriendData)
end


------------------------------------------- 好友赠送体力 ---------------------------------------

-- 得到总共可领取的次数
function getOneDayTotalTimes( ... )
	require "db/DB_Give_stamina"
	local times = 0
	local data = DB_Give_stamina.getDataById(1)
	times = tonumber(data.get_stamina_times)
	return times
end

-- 得到一次可赠送的体力值
function getGiveStaminaNum( ... )
	require "db/DB_Give_stamina"
	local num = 0
	local data = DB_Give_stamina.getDataById(1)
	num = tonumber(data.give_stamina_num)
	return num
end


-- 判断当天是否赠送过该玩家体力
-- timeData：时间戳
function isGiveTodayByTime( timeData )
	print("year:",os.date("*t", timeData).year,"month:",os.date("*t", timeData).month,"day:",os.date("*t", timeData).day,"hour:",os.date("*t", timeData).hour)
	local curServerTime = BTUtil:getSvrTimeInterval()
	local date = os.date("*t", curServerTime)
	-- print_t(date)
	print("curMonth",date.month)
	print("curDay",date.day)
	local curHour = tonumber(date.hour)
	print("curHour",curHour)
	local curMin = tonumber(date.min)
	print("curMin",curMin)
	local cruSec = tonumber(date.sec)
	print("cruSec",cruSec)
	-- 今天从0点到现在的所有秒数
	local curTotal = curHour*3600 + curMin*60 + cruSec
	-- timeData 跟 现在时间 的时间差
	local subTime = curServerTime - tonumber(timeData)
	-- 判断是否在同一天
	-- 两个时间段相差的秒数
	local overTime =  subTime - curTotal
	-- overTime 大于0表明不是今天
	if( overTime > 0)then
		return false
	else
		return true
	end
end

-- 得到体力有效时间 返回一个str 如:GetLocalizeStringBy("key_3270")
local tDay = {
	GetLocalizeStringBy("key_3270"), GetLocalizeStringBy("key_3244"), GetLocalizeStringBy("key_2185"), GetLocalizeStringBy("key_2952"), GetLocalizeStringBy("key_3253"), GetLocalizeStringBy("key_1113"), GetLocalizeStringBy("key_3370"), GetLocalizeStringBy("key_1785"), GetLocalizeStringBy("key_2186"), GetLocalizeStringBy("key_3048"), GetLocalizeStringBy("key_2990"), GetLocalizeStringBy("key_1072"), GetLocalizeStringBy("key_1403"), GetLocalizeStringBy("key_1111"), GetLocalizeStringBy("key_2720"),GetLocalizeStringBy("key_1329")
}
-- timeData：时间戳
function getValidTime( time )
	local timeData = tonumber(time)
	if( timeData == nil)then
		return " "
	end
	print("year:",os.date("*t", timeData).year,"month:",os.date("*t", timeData).month,"day:",os.date("*t", timeData).day,"hour:",os.date("*t", timeData).hour)
	local curServerTime = BTUtil:getSvrTimeInterval()
	local date = os.date("*t", curServerTime)
	-- print_t(date)
	print("curMonth",date.month)
	print("curDay",date.day)
	local curHour = tonumber(date.hour)
	print("curHour",curHour)
	local curMin = tonumber(date.min)
	print("curMin",curMin)
	local cruSec = tonumber(date.sec)
	print("cruSec",cruSec)
	-- 今天从0点到现在的所有秒数
	local curTotal = curHour*3600 + curMin*60 + cruSec
	-- timeData 跟 现在时间 的时间差
	local subTime = curServerTime - tonumber(timeData)
	-- 判断是否在同一天
	-- 两个时间段相差的秒数
	local overTime =  subTime - curTotal
	-- overTime 大于0表明不是今天
	if( overTime > 0)then
		-- 向上取整 1天前为1
		local num = math.ceil(overTime/(24*3600))
		print("num:",num)
		return tDay[num+1]
	else
		return tDay[1]
	end
end


-- 得到好友的数据
function getThisFriendDataByUid( uid )
	if(allfriendData == nil)then
		return
	end
	print("============= uid ",uid)
	local data = {}
	for k,v in pairs(allfriendData) do
		if(tonumber(uid) == tonumber(v.uid))then
			data = v
		end
	end
	return data
end


-- 得到今日剩余次数
function getTodayReceiveTimes( ... )
	return receiveTimes
end

-- 设置今日剩余次数
function setTodayReceiveTimes( data )
	receiveTimes = tonumber(data)
end

-- 设置可领取列表
function setReceiveList( listData )
	receiveList = {}
	for k,v in pairs(listData) do
		receiveList[#receiveList+1] = listData[k]
	end
	print("receiveList:")
	print_t(receiveList)
	-- 按时间由大到小排序
	local function timeDownSort( a, b )
		return tonumber(a.time) > tonumber(b.time)
	end
	table.sort( receiveList, timeDownSort )
	print(GetLocalizeStringBy("key_1065"))
	print_t(receiveList)
end

-- 得到可领取列表
function getReceiveList( ... )
	return receiveList
end

-- 删除已领取的数据
-- delStaminaDataByTimeAndUid
function delStaminaDataByTimeAndUid( time, uid )
	local data = {}
	local oldData = getReceiveList()
	for k,v in pairs(oldData) do
		if(tonumber(time) == tonumber(v.time) and tonumber(uid) == tonumber(v.uid))then
			oldData[k] = nil
		else
			data[#data+1] = oldData[k]
		end
	end
	setReceiveList( data )
end


-- 把当前时间设置为上次赠送的时间
function setGiveTimeByUid( uid )
	if(allfriendData == nil)then
		return
	end
	print("============= uid ",uid)
	local data = {}
	for k,v in pairs(allfriendData) do
		if(tonumber(uid) == tonumber(v.uid))then
			local curServerTime = BTUtil:getSvrTimeInterval()
			v.lovedTime = curServerTime
		end
	end 
end


------------------------------ 添加提示红圈 -------------------------
-- 列表数据
local isShow = nil
local showCount = 0
-- 设置可领取列表数据
function setReceiveInfo( ret )
	local data = ret
	if(data == nil)then
		return
	end
	-- 今天领取了的次数
	local num = tonumber(data.num)
	-- 今天总共可以领取的次数
	local allNum = getOneDayTotalTimes()
	local subData = allNum - num
	-- 设置可以领取的次数
	setTodayReceiveTimes(subData)
	if(not table.isEmpty(data.va_love) and subData > 0)then
		setShowTipSprite(true)
		setReceiveListCount( table.count( data.va_love ) )
	else
		setShowTipSprite(false)
		setReceiveListCount( table.count( data.va_love ) )
	end
end

-- 设置是否显好友图标上的红圈
function setShowTipSprite( isShowData )
	isShow = isShowData
end

-- 得到是否显好友图标上的红圈
function getIsShowTipSprite( ... )
	return isShow
end

-- 设置可领取耐力的条数
function setReceiveListCount( num )
	showCount = tonumber(num)
end

-- 可领取的耐力条数
function getReceiveListCount( ... )
	return showCount
end


----------------------------------------- 好友PK数据 -------------------------------
-- 得到配置数据
-- 1.今天可以PK最大次数 2.今天可以被PK最大次数 3.今天PK同一好友最大次数
function getPKMaxNum( ... )
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local strTab = string.split(data.friendsPk, "|")
    local maxCanPkNum = tonumber(strTab[1])
    local maxBePkNum = tonumber(strTab[2])
    local maxSamePkNum = tonumber(strTab[3])
    return maxCanPkNum,maxBePkNum,maxSamePkNum
end

----------------------------------------- 黑名单数据 --------------------------------
local _blackListData = nil

-- 设置黑名单数据
function setBlackListData( data )
	_blackListData = data
end

-- 得到黑名单数据
function getBlackListData( ... )
	return _blackListData
end

-- 解除黑名单
function deleteBlacekDataByUid( uid )
	local tab = {}
	for k,v in pairs(_blackListData) do
		if(tonumber(v.uid) ~= tonumber(uid))then
			table.insert(tab,v)
		end
	end
	setBlackListData( tab )
end















