--[[	
	文件名称：QActivityRounds.lua
	创建时间：2016-09-17 09:49:53
	作者：nieming
	描述：轮次类型活动(豪华转盘 团购)
]]

local QBaseModel = import("..models.QBaseModel")
local QActivityRounds = class("QActivityRounds",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QActivityTurntable = import(".QActivityTurntable")
local QActiviyGroupBuy = import(".QActiviyGroupBuy")
local QActiviyDivination = import(".QActivityDivination")
local QActiviyRushBuy = import(".QActiviyRushBuy")
local QActivityWeekFund = import(".QActivityWeekFund")
local QCelebrityHallRank = import("..network.models.QCelebrityHallRank")
local QActivityNewServiceFund = import(".QActivityNewServiceFund")
local QActivityForge = import(".QActivityForge")
local QActivitySoulLetter = import(".QActivitySoulLetter")
local QActivityPrizeWheel = import(".QActivityPrizeWheel")
local QActivityRatFestival = import(".QActivityRatFestival")
local QActivityZhangbichenPreheat = import(".QActivityZhangbichenPreheat")
local QActivitySkyFall = import(".QActivitySkyFall")
local QActivityZhangbichen = import(".QActivityZhangbichen")
local QActivityHighTea = import(".QActivityHighTea")
local QMazeExplore = import(".QMazeExplore")
local QActivityNewServerRecharge = import(".QActivityNewServerRecharge")
local QActivityTreasures = import(".QActivityTreasures")
local QActivityCustomShop = import(".QActivityCustomShop")


QActivityRounds.LuckyType ={
	LUXURIOUS_ROLLING = "LUXURIOUS_ROLLING",								-- // 豪华转盘
    GROUP_BUYING = "GROUP_BUYING",											-- // 团购
    DIVINATION = "DIVINATION",												-- // 占卜
    HOLIDAY_ACTIVITY = "",													--  // 节日活动掉落
    RUSH_BUY =  "RUSH_BUY",													--  // 6元夺宝
    GUESS_CARD = "GUESS_CARD",												--  // 翻牌活动
    SKY_FALL_REWARD =  "SKY_FALL_REWARD",									--  // 天降福袋
    TURN_CARD =  "TURN_CARD",												--  // 登录翻牌送钻石
    CELEBRITY_HALL_RANK =  "CELEBRITY_HALL_RANK",							--  // 名人堂排行奖励
    WEEK_FUND = "WEEK_FUND",												--   // 周基金
    HOLIDAY_ACTIVITY2 =  "HOLIDAY_ACTIVITY2",								--  // 节日活动掉落2
    NEW_WEEK_FUND =  "NEW_WEEK_FUND",										--  // 新服周基金
    FORGE_ACTIVITY =  "FORGE_ACTIVITY",										--  // 铸造活动--打铁
    SOUL_LETTER =  "SOUL_LETTER",											--  // 魂师手札
    PLAYER_COME_BACK =  "PLAYER_COME_BACK",									--  // 老玩家回归
    PRIZE_WHEEL_ACTIVITY =  "PRIZE_WHEEL_ACTIVITY",							--  // 活跃转盘活动
    RAT_FESTIVAL =  "RAT_FESTIVAL",											--  // 鼠年新春福袋活动
    THEME_PREHEAT =  "THEME_PREHEAT",										--  //张碧晨主题曲预热活动
    THEME_FORMAL =  "THEME_FORMAL",											--  //张碧晨主题曲正式活动
    WEEK_PLAY_TEA =  "WEEK_PLAY_TEA",										--  //周活跃-下午茶活动
    MAZE_EXPLORE =  "MAZE_EXPLORE",											--  //破碎位面（走部署逻辑）
    NEW_SERVER_RECHARGE =  "NEW_SERVER_RECHARGE",							--  //新服直冲（不需要走配置）
    RESOURCE_TREASURES =  "RESOURCE_TREASURES",							    --  //资源夺宝
    CUSTOM_SHOP = "CUSTOM_SHOP"
}

QActivityRounds.TURNTABLE_UPDATE = "TURNTABLE_UPDATE"
QActivityRounds.GROUPBUY_UPDATE = "GROUPBUY_UPDATE"
QActivityRounds.GROUPBUY_GOODSCHANGE = "GROUPBUY_GOODSCHANGE"
QActivityRounds.DIVINATION_UPDATE = "DIVINATION_UPDATE"
QActivityRounds.RUSHBUY_UPDATE = "RUSHBUY_UPDATE"
QActivityRounds.RUSHBUY_CHANGE = "RUSHBUY_CHANGE"
QActivityRounds.RUSHBUY_RECORD_CHANGE = "RUSHBUY_RECORD_CHANGE"
QActivityRounds.WEEKFUND_UPDATE = "WEEKFUND_UPDATE"
QActivityRounds.NEW_SERVICE_FUND_UPDATE = "NEW_SERVICE_FUND_UPDATE"
QActivityRounds.FORGE_UPDATE = "FORGE_UPDATE"
QActivityRounds.SOUL_LETTER_UPDATE = "SOUL_LETTER_UPDATE"
QActivityRounds.SOUL_LETTER_END = "SOUL_LETTER_END"
QActivityRounds.PRIZA_WHEEL_UPDATE = "PRIZA_WHEEL_UPDATE"
QActivityRounds.RAT_FESTIVAL_UPDATE = "RAT_FESTIVAL_UPDATE"
QActivityRounds.EVENT_RAT_FESTIVAL_TAVERN_UPDATE = "EVENT_RAT_FESTIVAL_TAVERN_UPDATE"
QActivityRounds.ZHANGBICHEN_PREHEAT_UPDATE = "ZHANGBICHEN_PREHEAT_UPDATE"
QActivityRounds.ZHANGBICHEN_UPDATE = "ZHANGBICHEN_UPDATE"
QActivityRounds.SKY_FALL_UPDATE = "SKY_FALL_UPDATE"
QActivityRounds.MAZE_EXPLORE_UPDATE = "MAZE_EXPLORE_UPDATE"
QActivityRounds.HIGHTEA_UPDATE = "HIGHTEA_UPDATE"
QActivityRounds.NEW_SERVER_RECHARGE_UPDATE = "NEW_SERVER_RECHARGE_UPDATE"
QActivityRounds.RESOURCE_TREASURES_OFF_LINE = "RESOURCE_TREASURES_OFF_LINE"
QActivityRounds.CUSTOM_SHOP_UPDATE = "CUSTOM_SHOP_UPDATE"
QActivityRounds.CUSTOM_SHOP_ACTIVITY_CLOSE = "CUSTOM_SHOP_ACTIVITY_CLOSE"


QActivityRounds.WEEKFUND_TYPE = "activity_zjj"
QActivityRounds.NEWSERVICE_FUND_TYPE = "activity_xfjj"

function QActivityRounds:ctor( ... )
	-- body
	QActivityRounds.super.ctor(self,...)
	self.children = {}
end


function QActivityRounds:getTurntable( )
	-- body
	return self.children[QActivityRounds.LuckyType.LUXURIOUS_ROLLING] 
end

function QActivityRounds:getGroupBuy( )
	-- body
	return self.children[QActivityRounds.LuckyType.GROUP_BUYING] 
end

function QActivityRounds:getDivination( )
	-- body
	return self.children[QActivityRounds.LuckyType.DIVINATION] 
end

function QActivityRounds:getRushBuy( )
	-- body
	return self.children[QActivityRounds.LuckyType.RUSH_BUY] 
end

function QActivityRounds:getWeekFund()
	return self.children[QActivityRounds.LuckyType.WEEK_FUND]
end

function QActivityRounds:getNewServiceFund()
	return self.children[QActivityRounds.LuckyType.NEW_WEEK_FUND]
end

function QActivityRounds:getForge()
	return self.children[QActivityRounds.LuckyType.FORGE_ACTIVITY]
end

function QActivityRounds:getSoulLetter()
	return self.children[QActivityRounds.LuckyType.SOUL_LETTER]
end

function QActivityRounds:getPrizaWheel()
	return self.children[QActivityRounds.LuckyType.PRIZE_WHEEL_ACTIVITY]
end

function QActivityRounds:getRatFestival()
	return self.children[QActivityRounds.LuckyType.RAT_FESTIVAL]
end

function QActivityRounds:getZhangbichenPreheat()
	return self.children[QActivityRounds.LuckyType.THEME_PREHEAT]
end

function QActivityRounds:getSkyFall( )
	return self.children[QActivityRounds.LuckyType.SKY_FALL_REWARD]
end

function QActivityRounds:getZhangbichen()
	return self.children[QActivityRounds.LuckyType.THEME_FORMAL]
end

function QActivityRounds:getHighTea()
	return self.children[QActivityRounds.LuckyType.WEEK_PLAY_TEA]
end

function QActivityRounds:getMazeExplore()
	return self.children[QActivityRounds.LuckyType.MAZE_EXPLORE]
end

function QActivityRounds:getRoundInfoByType(roundType)
	return self.children[roundType]
end

--创建时初始化事件
function QActivityRounds:didappear()
   	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.timeRefreshHandler))
end

function QActivityRounds:disappear()
	self.children = nil
	if self._userEventProxy then
		self._userEventProxy:removeAllEventListeners()
		self._userEventProxy = nil
	end
end

function QActivityRounds:timeRefreshHandler( event )
	-- body
	for k ,v in pairs(self.children) do
		if v.isOpen then
			v:timeRefresh(event)
		end
	end
end

function QActivityRounds:loginEnd( )
	-- body
	for k ,v in pairs(self.children) do
		if v.isOpen then
			v:getActivityInfoWhenLogin()
		end
	end
end

--检查来自普通活动是否完成
function QActivityRounds:checkActivityComplete(info)
	if info.roundType == nil then
		return false
	end
	local activityData = self.children[info.roundType]
	if activityData == nil then
		return false
	end
	if activityData.checkActivityComplete == nil then
		return false
	end
	return activityData:checkActivityComplete(info)
end

function QActivityRounds:createActvityModelByType( luckyType )
	if luckyType == QActivityRounds.LuckyType.LUXURIOUS_ROLLING then
		return QActivityTurntable.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.GROUP_BUYING then
		return QActiviyGroupBuy.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.DIVINATION then
		return QActiviyDivination.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.RUSH_BUY then
		return QActiviyRushBuy.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.CELEBRITY_HALL_RANK then
		return remote.celebrityHallRank or QCelebrityHallRank.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.WEEK_FUND then
		return QActivityWeekFund.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.NEW_WEEK_FUND then
		return QActivityNewServiceFund.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.FORGE_ACTIVITY then
		return QActivityForge.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.SOUL_LETTER then
		return QActivitySoulLetter.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.PRIZE_WHEEL_ACTIVITY then
		return QActivityPrizeWheel.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.RAT_FESTIVAL then
		return QActivityRatFestival.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.THEME_PREHEAT then
		return QActivityZhangbichenPreheat.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.SKY_FALL_REWARD then
		return QActivitySkyFall.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.THEME_FORMAL then
		return QActivityZhangbichen.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.WEEK_PLAY_TEA then
		return QActivityHighTea.new(luckyType)	
	elseif luckyType == QActivityRounds.LuckyType.MAZE_EXPLORE then
		return QMazeExplore.new(luckyType)	
	elseif luckyType == QActivityRounds.LuckyType.NEW_SERVER_RECHARGE then
		return QActivityNewServerRecharge.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.RESOURCE_TREASURES then
		return QActivityTreasures.new(luckyType)
	elseif luckyType == QActivityRounds.LuckyType.CUSTOM_SHOP then
		return QActivityCustomShop.new(luckyType)		
	end
	return nil
end

--登入获取
function QActivityRounds:setActivitysInfoByLogin( data )
	for k ,v in pairs(data) do
		if not (v.luckyType == QActivityRounds.LuckyType.SOUL_LETTER and FinalSDK.needHideActivity()) then
			local imp = self.children[v.luckyType]
			if not imp then
				imp = self:createActvityModelByType(v.luckyType)
				if imp then
					self.children[v.luckyType] = imp
				end
			end
			if imp then
				imp:setActivityInfo(v)
				imp:handleOnLine()
			end
		end
	end
end

--处理推送
function QActivityRounds:handleNotify( data )
	if data.type == "ONLINE_LUCKY_DRAW_INFO" then
		local imp = self.children[data.info.luckyType]
		if not imp then
			imp = self:createActvityModelByType(data.info.luckyType)
			self.children[data.info.luckyType] = imp
		end
		if imp then
			imp:setActivityInfo(data.info)
			imp:handleOnLine()
		end
	elseif data.type == "OFFLINE_LUCKY_DRAW_INFO" then
		local imp = self.children[data.info.luckyType]
		if imp then
			imp.isOpen = false
			imp:handleOffLine()
		end
	end
end

return QActivityRounds