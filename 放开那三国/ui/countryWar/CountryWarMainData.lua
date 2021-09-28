
-- FileName: CountryWarData.lua
-- Author: lichenyang
-- Date: 2015-11-06
-- Purpose: 国战主数据层

module("CountryWarMainData", package.seeall)

require "script/ui/countryWar/CountryWarDef"
require "db/DB_National_war"

local _countryWarInfo = {}
local _loginInfo = {}

function setCountryWarInfo( pInfo )
	_countryWarInfo = pInfo
end

function getCountryWarInfo()
	return _countryWarInfo
end

--[[
	@des:得到登陆拉取信息
--]]
function setLoginInfo( pInfo )
	_loginInfo = pInfo
end

--[[
	@des:得到登陆拉取国战信息
	@parm:void
	@ret:ret table
--]]
function getLoginInfo()
	return _loginInfo
end

--[[
	@des:得到分组信息
	@parm:void 
	@ret:teadId int
--]]
function getTeamId()
	return tonumber(_loginInfo.teamId) or -1 
end

--[[
	@des:活动是否开启
	@parm:void 
	@ret:ret bool 为真则开启
--]]
function isOpen()
	local ret = true
	--是否有分组
	if getTeamId() < 0 then
		ret = false
	end
	--是否满足开服天数
	local openServerTime = tonumber(ServerList.getSelectServerInfo().openDateTime)
	local openDay = math.floor((TimeUtil.getSvrTimeByOffset() - openServerTime)/86400)
	local needOpenDay = tonumber(getNeedDay())
	if openDay < needOpenDay then
		ret = false
	end
	--玩家等级是否满足
	if UserModel.getHeroLevel() < tonumber(getNeedLevel()) then
		ret = false
	end
	return ret
end

--[[
	@des:是否显示主界面快捷入口
--]]
function isShowQuickIcon()
	--没有开启
	if not isOpen() then
		return false
	end
	--比赛报名和比赛时间段内
	local curStage = getCurStage()
	if curStage >= CountryWarDef.SIGNUP and curStage < CountryWarDef.WORSHIP then
		return true
	else
		return false
	end
end

--[[
	@des 	: 获取登陆时拉取的膜拜时间
	@param 	: 
	@return : 
--]]
function getWorShipTime( ... )
	return tonumber(_loginInfo.worship_time)
end

--[[
	@des 	: 设置登陆时拉取的膜拜时间
	@param 	: 
	@return : 
--]]
function setWorShipTime( pTime )
	_loginInfo.worship_time = pTime
end

--[[
	@des 	: 如果玩家没有膜拜的话，入口图标加上红点提示 add by yangrui 
	@param 	: 
	@return : 
--]]
function isShowRedTip( ... )
	local isShow = nil
	-- 判断活动是否开启
	if not isOpen() then
		return false
	end
	-- 膜拜时间
	local worshipTime = getWorShipTime()
	local curTIme = TimeUtil.getSvrTimeByOffset(0)
	local curStage = getCurStage()
	-- 当前阶段为膜拜阶段
	if curStage == CountryWarDef.WORSHIP then
		if TimeUtil.isSameDay(worshipTime,curTIme) then
			isShow = false
		else
			isShow = true
		end
	end
	return isShow
end

--[[
	@des:得到当前阶段
	@ret:int
--]]
function getCurStage()
	local curTime = TimeUtil.getSvrTimeByOffset(-3)
	local timeConfig = _countryWarInfo.timeConfig or _loginInfo.timeConfig
	--如果没有时间配置，默认为分组阶段
	if table.isEmpty(timeConfig) then
		return CountryWarDef.TEAM
	end
	for k,v in pairs(timeConfig) do
		timeConfig[k] = tonumber(v)
	end
	local stage = -1
	if curTime >= timeConfig.teamBegin and curTime < timeConfig.signupBegin then
		--分组阶段
		stage = CountryWarDef.TEAM
	elseif curTime >= timeConfig.signupBegin and curTime < timeConfig.rangeRoomBegin then
		-- 报名阶段
		stage = CountryWarDef.SIGNUP
	elseif curTime >= timeConfig.rangeRoomBegin and curTime < timeConfig.auditonBegin then
		-- 分房阶段
		stage = CountryWarDef.ASSIGN_ROOM
	elseif curTime >= timeConfig.auditonBegin and curTime < timeConfig.auditonBegin + getAuditionReadyTime() then
		-- 初赛准备阶段
		stage = CountryWarDef.AUDITION_READY
	elseif curTime >= timeConfig.auditonBegin + getAuditionReadyTime() and curTime < timeConfig.supportBegin  then
		-- 初赛阶段
		stage = CountryWarDef.AUDITION
	elseif curTime >= timeConfig.supportBegin and curTime < timeConfig.finaltionBegin  then
		-- 助威阶段
		stage = CountryWarDef.SUPPORT
	elseif curTime >= timeConfig.finaltionBegin and curTime < timeConfig.finaltionBegin + getAuditionReadyTime() then
		-- 决赛准备阶段
		stage = CountryWarDef.FINALTION_READY
	elseif curTime >= timeConfig.finaltionBegin + getAuditionReadyTime() and curTime < timeConfig.worshipBegin then
		-- 决赛阶段
		stage = CountryWarDef.FINALTION
	elseif curTime >= timeConfig.worshipBegin then
		-- 膜拜阶段
		stage = CountryWarDef.WORSHIP
	else
		print("error: error stage")
	end
	return stage
end

--[[
	@des:得到阶段开始时间
	@parm:pStage 阶段标识
	@ret:int time
--]]
function getStageStartTime( pStage )
	local timeConfig = _countryWarInfo.timeConfig
	local config = {
		[CountryWarDef.TEAM]            = timeConfig.teamBegin,
		[CountryWarDef.SIGNUP]          = timeConfig.signupBegin,
		[CountryWarDef.ASSIGN_ROOM]     = timeConfig.rangeRoomBegin,
		[CountryWarDef.AUDITION_READY]  = timeConfig.auditonBegin,
		[CountryWarDef.AUDITION]        = timeConfig.auditonBegin + getAuditionReadyTime(),
		[CountryWarDef.SUPPORT]         = timeConfig.supportBegin,
		[CountryWarDef.FINALTION_READY] = timeConfig.finaltionBegin,
		[CountryWarDef.FINALTION]       = timeConfig.finaltionBegin + getAuditionReadyTime(),
		[CountryWarDef.WORSHIP]         = timeConfig.worshipBegin,
	}
	return config[pStage] or 0
end

--[[
	@des:得到阶段结束时间
	@parm:pStage 阶段标识
	@ret:int time
--]]
function getStageOverTime( pStage )
	local timeConfig = _countryWarInfo.timeConfig
	local config = {
		[CountryWarDef.TEAM]            = timeConfig.signupBegin,
		[CountryWarDef.SIGNUP]          = timeConfig.rangeRoomBegin,
		[CountryWarDef.ASSIGN_ROOM]     = timeConfig.rangeRoomBegin,
		[CountryWarDef.AUDITION_READY]  = timeConfig.auditonBegin + getAuditionReadyTime(),
		[CountryWarDef.AUDITION]        = timeConfig.supportBegin,
		[CountryWarDef.SUPPORT]         = timeConfig.finaltionBegin,
		[CountryWarDef.FINALTION_READY] = timeConfig.finaltionBegin + getAuditionReadyTime(),
		[CountryWarDef.FINALTION]       = timeConfig.worshipBegin,
		[CountryWarDef.WORSHIP]         = timeConfig.teamBegin,
	}
	return config[pStage] or 0
end

--[[
	@des:得到国战币
	@ret:number 当前国战币
--]]
function getCocoin()
	return tonumber(_countryWarInfo.cocoin) or 0
end

--[[
	@des:得到国战币
	@ret:number 当前国战币
--]]
function addCocoin( pNumber )
	_countryWarInfo.cocoin = getCocoin() + pNumber
end

--[[
	@des:初赛准备时间
	@ret: int
--]]
function getAuditionReadyTime()
	return 30
end

--[[
	@des:得到膜拜信息
--]]
function getWorShipInfo()
	if _countryWarInfo then
		return _countryWarInfo.detail
	end
	return nil
end

--[[
	@des:得到报名信息
--]]
function getSignUpInfo()
	if _countryWarInfo then
		return _countryWarInfo.detail
	end
	return nil
end

--[[
	@des:得到助威信息
--]]
function getSupportInfo( ... )
	if _countryWarInfo then
	    print("得到助威信息:")
	    print_t(_countryWarInfo.detail)
		return _countryWarInfo.detail
	end
	return nil
end


--[[
	@des:得到势力信息
--]]
function getForceInfo()
	return _countryWarInfo.detail.forceInfo
end

--[[
	@des:得到我的势力
--]]
function getMySide()
	return tonumber(_countryWarInfo.detail.side) or 0
end

--[[
	@des:得到敌方势力
--]]
function getEnemySide( ... )
	if getMySide() == CountryWarDef.COUNTRY_SIDE_1 then
		return CountryWarDef.COUNTRY_SIDE_2
	else
		return CountryWarDef.COUNTRY_SIDE_1
	end
end

--[[
	@des:得到参赛需要等级
--]]
function getNeedLevel()
	local dbInfo = DB_National_war.getDataById(1)
	return dbInfo.level
end

--[[
    @des:开服多少天参与
--]]
function getNeedDay()
    local dbInfo = DB_National_war.getDataById(1)
    return dbInfo.days
end


--[[
	@des:得到决赛进入资格
--]]
function isEnterFinal( ... )
	if tonumber(_countryWarInfo.detail.qualify) > 0 then
		return true
	else
		return false
	end
end


