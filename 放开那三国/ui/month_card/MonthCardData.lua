-- Filename：	MonthCardData.lua
-- Author：		zhz
-- Date：		2013-6-12
-- Purpose：		月卡功能的数据层，还有方法层

module("MonthCardData", package.seeall)

require "db/DB_Vip_card"
require "script/ui/item/ItemUtil"
require "script/ui/login/ServerList"
require "script/ui/rechargeActive/ActiveCache"
require "script/utils/TimeUtil"
require "script/model/user/UserModel"
require "script/model/utils/ActivityConfigUtil"

local _vipCardData	= DB_Vip_card.getDataById(1)
local _vipCardInfo 			-- 月卡后端传来的数据
 kNormalMonthCard  	= 1    	--普通月卡
 kSuperMonthCard   	= 2	   	--超值月卡

--读表中月卡的信息
function getVipCardDatafromXml( pId )
	return DB_Vip_card.getDataById(pId)
end
function getCardInfo( )
	return  _vipCardInfo
end

function setCardInfo(cardInfo )
	_vipCardInfo = {}
	for k,v in pairs(cardInfo) do
		_vipCardInfo[tonumber(k)] = v
	end
end
--用于月卡大礼包中点击领取后手动改变礼包状态
function changeGiftStatus( value )
	_vipCardInfo[3].gift_status = tonumber(value)
end
--判断是否可以购买月卡
function isCanBuy( pId )
	local isCanBuy = true
	local chargeGold = tonumber(getVipCardDatafromXml(pId).payneedgold)
	if(tonumber(_vipCardInfo[tonumber(pId)].charge_gold) < chargeGold)then
		isCanBuy = false
	end
	return isCanBuy
end
--判断是购买月卡按钮还是领取按钮
function isBuyOrRecive( pId )
	local data = getCardInfo()
	local data1 = data[tonumber(pId)]
	if(data1.due_time == nil)then
		print("isBuyOrRecive due_time")
		return true
	else
		--当剩余天数为0
	local day = getLeftDay(pId)
		if(day <= 0)then
			return true
		else
			return false
		end
	end	
end



-- 得到是否已经领取过了每日奖励， 如果没有买，就认为 false
function getCanReceive(pId)
	if(_vipCardInfo[tonumber(pId)].due_time == nil)then
		return true
	end
	
	if( ActiveCache.isToday( tonumber( _vipCardInfo[tonumber(pId)].va_card_info.monthly_card.reward_time))) then
		return false
	else
		return true
	end
end

-- 判断是否购买了月卡，并且月卡是否有效
function isMonthCardEffect(pId)
	if(_vipCardInfo[tonumber(pId)].due_time == nil)then
		print("isMonthCardEffect false")
		return false
	end
	if( not table.isEmpty( _vipCardInfo[tonumber(pId)].va_card_info) and  tonumber( _vipCardInfo[tonumber(pId)].due_time)> BTUtil:getSvrTimeInterval() ) then
		return true
	else
		return false	
	end
end


-- 周期充值多少 add by chengliang
function addMonthChargeGold( pId,gold_num )
	if(table.isEmpty(  _vipCardInfo[tonumber(pId)] )  )then
		 _vipCardInfo = {}
		 _vipCardInfo.charge_gold = tonumber(gold_num)
	else
		if(  _vipCardInfo[tonumber(pId)].charge_gold == nil)then
			 _vipCardInfo[tonumber(pId)].charge_gold = tonumber(gold_num)
		else
			 _vipCardInfo[tonumber(pId)].charge_gold = tonumber( _vipCardInfo[tonumber(pId)].charge_gold) + tonumber(gold_num)
		end
	end
end

-- 得到当前周期充值了多少
function getMonthChargeGold(pId)
	local gold_num = 0
	if( not table.isEmpty( _vipCardInfo[tonumber(pId)]) and  _vipCardInfo[tonumber(pId)].charge_gold ~= nil )then
		gold_num = tonumber( _vipCardInfo[tonumber(pId)].charge_gold)
	end
	return gold_num
end

-- 得到每日领取的奖励
function getCardReward( pId )
	_vipCardData = DB_Vip_card.getDataById(pId)
	local items= ItemUtil.getItemsDataByStr( _vipCardData.cardReward)
	return items
end

-- 得到月卡礼包的奖励
function getFirstReward( )
	_vipCardData = DB_Vip_card.getDataById(1)
	if(_vipCardData.firstReward == nil) then

		print(" error ! firstReward为 空")
		return {}
	end

	local items= ItemUtil.getItemsDataByStr( _vipCardData.firstReward)
	return items
end

--
--得到月卡剩余天数
function getLeftDay(pId)
	print("getLeftDay(pId)",pId)
	if( _vipCardInfo[tonumber(pId)].due_time == nil) then
		return 0
	end
	if(tonumber( _vipCardInfo[tonumber(pId)].due_time)< BTUtil:getSvrTimeInterval())then
		return 0
	end
	-- _vipCardInfo.due_time记录的是活动结束的时间，减去当前的服务器时间，得到还剩余的时间
	local lastTime=  _vipCardInfo[tonumber(pId)].due_time- BTUtil:getSvrTimeInterval()
	local leftDay= math.ceil( lastTime/(24*3600))
	return leftDay 
end
--策划要求在界面上面显示的变为美术数字
function getSpriteNum( pId )
	local spriteNum1,spriteNum2
	local dayNum = tonumber(getLeftDay(pId))
	if(dayNum <= 0)then
		spriteNum1 = 0
		spriteNum2 = 0
	elseif dayNum == 30 then
		spriteNum1 =3
		spriteNum2 = 0
	elseif 20<= dayNum and dayNum< 30 then
		spriteNum1 = 2
		spriteNum2 = tonumber(dayNum%20)
	elseif 10<=dayNum and dayNum< 20 then
		spriteNum1 = 1
		spriteNum2 = tonumber(dayNum%10)
	elseif 0<dayNum and dayNum<= 9 then
		spriteNum1 = 0
		spriteNum2 = dayNum
	else
		spriteNum1 = 3
		spriteNum2 = 0
	end
	return spriteNum1,spriteNum2
end
--是否已购买月卡
function haveBuyCard()
	local haveBuy = false
	if( _vipCardInfo[tonumber(pId)].due_time == nil) then
		return haveBuy
	end
	if(tonumber( _vipCardInfo[tonumber(pId)].due_time)< BTUtil:getSvrTimeInterval())then
		return haveBuy
	end
	local lastTime =  _vipCardInfo[tonumber(pId)].due_time- BTUtil:getSvrTimeInterval()
	if tonumber(lastTime) > 0 then
		haveBuy = true
	end 
	return haveBuy
end

--[[
	@desc:  判断当前在开服第几天，开服当天为第一天。开服7天内有礼包, 7天后没有礼包。so，7天后（第8天）以后都是8天

	@param: 
--]]
function getOpenServerDay( )
	-- 开服时间
	local openDateTime= tonumber(ServerList.getSelectServerInfo().openDateTime)
	print("openDateTime is ", openDateTime)
	local day=1
	local lastTime= BTUtil:getSvrTimeInterval() - openDateTime
	local lastDay= math.ceil(lastTime/(24*60*60)) 
    print("lastDay is ", lastDay)
    return lastDay
end

--[[
	@des 	:月卡合服活动开始时间
	@param 	:
	@return :开始时间戳
--]]
function mergeGameBeginTime()
	--合服时间
	local mergeDateTime = UserModel.getMergeServerTime() or 0
	--合服当天0点时间戳
	local mergeZeroTime = TimeUtil.getCurDayZeroTime(tonumber(mergeDateTime))
	local beginTime = mergeZeroTime + 24*3600
	return beginTime
end

--[[
	@des 	:月卡合服活动结束时间
	@param 	:
	@return :结束时间戳
--]]
function mergeGameEndTime()
	--合服时间
	local mergeDateTime = UserModel.getMergeServerTime() or 0
	--合服当天0点时间戳
	local mergeZeroTime = TimeUtil.getCurDayZeroTime(tonumber(mergeDateTime))
	local endTime = mergeZeroTime + 24*3600*31 - 1
	return endTime
end

--[[
	@des 	:是否在合服25天内
	@param 	:
	@return :是：true，否：false
--]]
function isInMergeTime()
	local isInGame = false
	local currentTime = tonumber(TimeUtil.getSvrTimeByOffset())

	--如果在合服25天内
	if currentTime >= mergeGameBeginTime() and currentTime <= mergeGameEndTime() then
		-- print("月卡活动开始时间",mergeGameBeginTime())
		-- print("月卡活动结束时间",mergeGameEndTime())
		isInGame = true
	end

	return isInGame
end

--[[
	@des 	:判断是否是15天内开的服
	@param 	:
	@return :true or false
--]]
function isNewServer( )
	--如果没有买过月卡，且开服在15天内
	if( isHaveNotBuyMouthCard() and getOpenServerDay()<=15 ) then
		return true
	else
		return false
	end	 

end

--[[
	@des 	:判断是否是15天后开的服
	@param 	:
	@return :true or false
--]]
function isOldServer()
	--没有购买过月卡，且开服大于15天，且开了老服月卡活动
	if (isHaveNotBuyMouthCard() and (getOpenServerDay() > 15)) and ActivityConfigUtil.isActivityOpen("monthlyCardGift") then
		return true
	else
		return false
	end
end

--[[
	@des 	:判断是否有合服活动
	@param 	:
	@return :true or false
--]]
function isMergeOpen()
	local hasOpen = false
	if (UserModel.getMergeServerTime() ~= nil) and (tonumber(UserModel.getMergeServerTime()) ~= 0) and (isInMergeTime()) then
		hasOpen = true
	end

	return hasOpen
end


--判断是否合服
function isMerge( )
	local has = false
	if (UserModel.getMergeServerTime() ~= nil) and (tonumber(UserModel.getMergeServerTime()) ~= 0) then
		has = true
	end

	return has
end

--[[
	@des 	:是否有礼包
	@param 	:
	@return :true or false
--]]
function wetherHaveBag()
	local staues =  tonumber(_vipCardInfo[3].gift_status)
	print("staues的状态~~~~~~~~",staues)
	local curTime = TimeUtil.getSvrTimeByOffset()
	if(staues == 3)then
		--月卡已经被领取的状态
		return false
	elseif staues == 2 then
		--月卡可以领取的状态
		return true
	else
		--月卡不可以被领取的状态
		if(isMerge())then
			--合服状态
			if(curTime - mergeGameBeginTime() <= 30*24*3600) then
				--合服不超过30天
				return true
			else
				return false
			end
		else
			--未合服状态
			if(getOpenServerDay() <= 15)then
				--未合服状态不超过15天
				return true
			else
				return false
			end

		end
	end
end

-- 得到月卡的按钮
function getGiftStatus( )

	return tonumber(  _vipCardInfo[3].gift_status)
	
end

function setGiftStatus()

		 _vipCardInfo[3].gift_status= 3
end

--[[
	@des 	:获得活动结束时间
	@param 	:15天的活动开始时间 => 1 		3天的活动开始时间 => 2
	@return :活动开始时间戳
--]]
function getBeginTime(kind)
	returnTime = 0
	if kind == 1 then
		returnTime = tonumber(ServerList.getSelectServerInfo().openDateTime)
	elseif kind == 2 then
		returnTime = tonumber(ActivityConfigUtil.getDataByKey("monthlyCardGift").start_time)
	else
		returnTime = 0
	end

	return returnTime
end

--[[
	@des 	:获得活动结束时间
	@param 	:15天的活动结束时间 => 1 		3天的活动结束时间 => 2
	@return :活动结束时间戳
--]]
function getEndTime(kind)
	returnTime = 0
	if kind == 1 then
		returnTime = tonumber(ServerList.getSelectServerInfo().openDateTime) + 15*3600*24
	elseif kind == 2 then
		returnTime = tonumber(ActivityConfigUtil.getDataByKey("monthlyCardGift").end_time)
	else
		returnTime = 0
	end

	return returnTime
end

--[[
	@des 	:获得倒计时
	@param 	:15天的活动剩余时间 => 1 		3天的活动剩余时间 => 2
	@return :活动剩余时间戳
--]]
function minusTime(kind)
	print("kind",kind)
	local currentTime = TimeUtil.getSvrTimeByOffset()
	returnTime = 0
	if kind == 1 then
		print("1")
		returnTime = getEndTime(1) - tonumber(currentTime)
	elseif kind == 2 then
		print("2")
		returnTime = getEndTime(2) - tonumber(currentTime)
	elseif kind == 3 then
		print("3")
		returnTime = mergeGameEndTime() - tonumber(currentTime)
	else
		print("4")
		returnTime = 0
	end
	print("returnTime",returnTime)
	return returnTime
end

--[[
	@des 	:倒计时格式
	@param 	:15天的活动剩余时间 => 1 	3天的活动剩余时间 => 2
	@return :格式后的倒计时
--]]
function remainTimeFormat(kind)
	local remainTime = minusTime(kind)

	--天数
	local DNum = math.floor(remainTime/(3600*24))
	remainTime = remainTime - DNum*3600*24
	--小时数
	local HNum = math.floor(remainTime/3600)
	remainTime = remainTime - HNum*3600
	--分数
	local MNum = math.floor(remainTime/60)
	remainTime = remainTime - MNum*60
	--秒数
	local SNum = remainTime

	--用于存储时间格式
	local timeString = ""

	--如果够一天
	if DNum > 0 then
		timeString = DNum .. GetLocalizeStringBy("key_10189") .. HNum .. GetLocalizeStringBy("key_10190") .. MNum .. GetLocalizeStringBy("key_10191") .. SNum .. GetLocalizeStringBy("key_10192")
	--如果够一小时
	elseif HNum > 0 then
		timeString = HNum .. GetLocalizeStringBy("key_10190") .. MNum .. GetLocalizeStringBy("key_10191") .. SNum .. GetLocalizeStringBy("key_10192")
	--如果够一分钟
	elseif MNum > 0 then
		timeString = MNum .. GetLocalizeStringBy("key_10191") .. SNum .. GetLocalizeStringBy("key_10192")
	--如果够一秒
	else
		timeString = SNum .. GetLocalizeStringBy("key_10192")
	end

	return timeString
end

--[[
	@des 	:得到活动的种类
	@param 	:
	@return :活动种类 1 => 新服开服15天内购买月卡可以获得月卡大礼包 	
					 2 => 刚上月卡的时候为了让老服玩家也能有月卡礼包，所以老服开服3天内购买月卡有大礼包（月卡刚推出的时候有的活动，现在没了） 	
					 3 => 合服25天内，购买月卡，可以获得月卡大礼包
					 0 => 没有活动
--]]
function getTypeNumber()
	local gameType = 0
	if getOpenServerDay() <= 15 then
		gameType = 1
	elseif ActivityConfigUtil.isActivityOpen("monthlyCardGift") then
		gameType = 2
	--已经合服且合服时间小于25天
	elseif isMergeOpen() then
		gameType = 3
	else
		gameType = 0
	end

	return gameType
end

--[[
	@desc: 	判断是否购买了月卡
	@return: bool 
--]]
function isHaveNotBuyMouthCard()
	local haveNotBuy = (table.isEmpty(_vipCardInfo[kNormalMonthCard].va_card_info) and table.isEmpty( _vipCardInfo[kSuperMonthCard].va_card_info))
	return haveNotBuy
end
	 