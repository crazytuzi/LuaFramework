-- Filename：	VIPBenefitData.lua
-- Author：		Fu Qiongqiong
-- Date：		2016-4-7
-- Purpose：		vip每周礼包数据层

module("VIPBenefitData", package.seeall)
require "db/DB_Vip_weekgift"
local _allweekGiftBag = {}
local _alreadyBuyWeeksGiftBag = {}
local _data 
--获取每周礼包的所有数据
function getAllWeekGiftBag( ... )
	if not table.isEmpty(_allweekGiftBag) then
        return _allweekGiftBag
    end
	for i=1,table.count(DB_Vip_weekgift.Vip_weekgift) do
		local data = DB_Vip_weekgift.getDataById(i)
		local iteminfo = setItemInfo(data)
		table.insert(_allweekGiftBag,iteminfo)
	end
	return _allweekGiftBag
end

--设置数据信息
function setItemInfo( pItemConfig )
	local itemInfo = {}
	itemInfo.id =  pItemConfig[1]
	itemInfo.vip =  pItemConfig[2]
	itemInfo.des =  pItemConfig[3]
	itemInfo.reward =  pItemConfig[4]
	itemInfo.cost =  pItemConfig[5]
	itemInfo.discount =  pItemConfig[6]
	return itemInfo
end
--获取到金币
function getGoldCost( pId )
	local costNum = 0
	for k,v in pairs(_allweekGiftBag) do
		if(tonumber(k) == tonumber(pId))then
			costNum = tonumber(v.discount)
			break
		end
	end
	return costNum
end

--判断红线是否存在(即是否现价比原价便宜)参数为现价，原价
function isRedLine( pXcost,pYcost )
	local isRedLine = false
	if(pXcost <= pYcost)then
		isRedLine = true
	end
	return isRedLine
end

--倒计时
function getCountDown( ... )
	--获取现在服务器时间
	local curTime = TimeUtil.getSvrTimeByOffset()
	local curZeroTime = TimeUtil.getCurDayZeroTime(curTime)
	local time = (curZeroTime - curTime ) + 86400
	--获取是周几
	local curDate = os.date("*t", curTime)
	local wDay = tonumber(curDate.wday)
	local day = wDay -1 
	print("day*****",day)
	if(day == 0)then
		day = 7
	end
	 local countDown = (7 - day)*86400 + time
	 return countDown
end

--在登陆时拉去了一次接口,每周礼包的信息
function setWeekGiftBag( dataInfo )
	_alreadyBuyWeeksGiftBag = dataInfo
end

--获取每周礼包的信息（是已购买礼包的信息）
function getWeekGiftBag( ... )
	print("_alreadyBuyWeeksGiftBag~~~~",_alreadyBuyWeeksGiftBag)
	print_t(_alreadyBuyWeeksGiftBag)
	return _alreadyBuyWeeksGiftBag
end
--判断是否可以购买的物品已经被购买过，false就是可以购买，true就是已经购买过了
function isCanBuy( pId )
	local isCanBy = false
	local data =getWeekGiftBag()
	if(not table.isEmpty(data))then
		for k,v in pairs(data) do
			if(tonumber(data[k]) == pId)then
				isCanBy = true
			end
		end
	end
	return isCanBy
end
--在本地修改缓存，购买后将被购买礼包的id存进去
function changeAlreadyBag( pId )
	print("pId~~~",pId)
	table.insert(_alreadyBuyWeeksGiftBag,pId)
end
--在登录时拉取了接口，获取的是每日礼包的状态
function writeHave( pData )
	_data = pData
end
--获取每日礼包的状态
function getHave( ... )
	print("_data******",_data)
	return _data
end
--每日福利界面的红点,true表示可以领取 false表示已经领取了
function dayGiftBag( ... )
	local num =getHave()
	if(num == 0)then
		return true
	else
		return false
	end
end
--VIP福利大界面的红点
function AllGiftBagTip( ... )
	--红点消失的情况,每周礼包和每日礼包的红点都消失
	local dayGiftbag = dayGiftBag()
	local weekGiftBag = getWeekGiftBag()
	if(dayGiftbag == false and not table.isEmpty(weekGiftBag))then
		return true
	else
		return false
	end

end
