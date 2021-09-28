-- FileName: CityData.lua
-- Author: licong
-- Date: 14-4-18
-- Purpose: 城池战数据


module("CityData", package.seeall)


local _isEnterCityTip = false --是否显示过主界面提示框


-- 根据城池id 得到配置数据
function getDataById( id )
	require "db/DB_City"
	local data = DB_City.getDataById(id)
	return data
end


--[[ 得到增益名字和数值
	增益类型ID|增益数值
	增益类型为约定好的数值
	1.军团组队银币奖励
	2.试练塔银币奖励
	3.摇钱树银币奖励
	4.普通副本银币奖励
	5.精英副本银币奖励
	6.资源矿银币奖励
--]]
function getEffectDataByCityId( id )
	local data = getDataById(id)
	local dataTab = string.split(data.occupyEffect, "|")
	local nameType = tonumber(dataTab[1])
	local num = dataTab[2]
	local nameTab = {GetLocalizeStringBy("key_2269"),GetLocalizeStringBy("key_3378"),GetLocalizeStringBy("key_2398"),GetLocalizeStringBy("key_3015"),GetLocalizeStringBy("key_2748"),GetLocalizeStringBy("key_1890")}
	return nameTab[nameType],num
end


--[[
	added  by zhz
	得到额外的增益的数据
	增益类型ID|增益数值
	增益类型为约定好的数值
	1.军团组队银币奖励
	2.试练塔银币奖励
	3.摇钱树银币奖励
	4.普通副本银币奖励
	5.精英副本银币奖励
	6.资源矿银币奖励
--]]
function getExtraRewardByCityId( id )
	local data = getDataById(id)
	local dataTab = string.split(data.occupyEffect, "|")
	local nameType = tonumber(dataTab[1])
	local num = tonumber(dataTab[2])
	local nameTab = {GetLocalizeStringBy("key_2269"),GetLocalizeStringBy("key_3378"),GetLocalizeStringBy("key_2398"),GetLocalizeStringBy("key_3015"),GetLocalizeStringBy("key_2748"),GetLocalizeStringBy("key_1890")}
	local rewardTab = {}
	-- return nameTab[nameType],num
	rewardTab.name=  nameTab[nameType] or ""
	rewardTab.rewardType= tonumber(dataTab[1])
	rewardTab.rate = (num/10000 )
	return rewardTab
end


-- 得到发奖时间字符串
-- 注：城池战之前模块显示星期几的配置均是: 星期天 - 星期六 从0-6
-- 这块配置和后端协调未果，此处按后端需求 特殊处理为: 星期一 - 星期六 从1-7
-- 这块只显示 没有时间操作影响不大
--[[
 	如果有时间操作 os.date("*t", curServerTime)中wday 是：星期天-星期六 从1-7
 	这样则无法遍历day = {GetLocalizeStringBy("zzh_1284"),GetLocalizeStringBy("key_2665"),GetLocalizeStringBy("key_2579"),GetLocalizeStringBy("key_1504"),GetLocalizeStringBy("key_2645"),GetLocalizeStringBy("zzh_1285"),GetLocalizeStringBy("key_1557")}这种配置数组
--]]
function getSendRewardTimeString( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	local dataTab = string.split(data.rewardTime, "|")
	local num1 = tonumber(dataTab[1])
	local day = {GetLocalizeStringBy("lic_1247"),GetLocalizeStringBy("key_2665"),GetLocalizeStringBy("key_2579"),GetLocalizeStringBy("key_1504"),GetLocalizeStringBy("key_2645"),GetLocalizeStringBy("lic_1246"),GetLocalizeStringBy("key_1557")}
	local num2 = dataTab[2]
	local h,m,s = string.match(num2, "(%d%d)(%d%d)(%d%d)" )
	local timeString = day[num1] .. h ..":".. m ..":".. s
	return timeString
end


-- 得到报名截止时间字符串
function getTimeOutTimeString( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	local dataTab = string.split(data.applyEndTime, "|")
	local num1 = tonumber(dataTab[1])
	local day = {GetLocalizeStringBy("lic_1247"),GetLocalizeStringBy("key_2665"),GetLocalizeStringBy("key_2579"),GetLocalizeStringBy("key_1504"),GetLocalizeStringBy("key_2645"),GetLocalizeStringBy("lic_1246"),GetLocalizeStringBy("key_1557")}
	local num2 = dataTab[2]
	local h,m,s = string.match(num2, "(%d%d)(%d%d)(%d%d)" )
	local timeString = day[num1] .. h ..":".. m ..":".. s
	return timeString
end


-- 得到 五10:00:00 格式的字符串
-- 参数：时间戳
function getTimeStrByNum( num )
	require "script/utils/TimeUtil"
	local zhou = {GetLocalizeStringBy("key_1557"),GetLocalizeStringBy("lic_1247"),GetLocalizeStringBy("key_2665"),GetLocalizeStringBy("key_2579"),GetLocalizeStringBy("key_1504"),GetLocalizeStringBy("key_2645"),GetLocalizeStringBy("lic_1246")}
	local date = os.date("*t", num)
	-- print_t(date)
	local zhouNum = tonumber(date.wday)
	local timeStr = TimeUtil.getTimeFormatAtDay(num)
	return zhou[zhouNum] .. timeStr
end


-- 得到是否可以报名 读后端时间数据
-- ret:1报名未开始，2报名已结束，3可以报名
function getIsOverApplyTime( ... )
	-- 当前服务器时间
    local curServerTime = BTUtil:getSvrTimeInterval()

	-- 服务器 报名时间 结束时间
	local serverTime = getTimeTable()
	local star_time_interval 	= serverTime.signupStart
	local end_time_interval 	= serverTime.signupEnd
	-- print("curServerTime",curServerTime)
	-- print("star_time_interval",star_time_interval)
	-- print("end_time_interval",end_time_interval)
	-- 周 判断
	if( curServerTime < star_time_interval )then
		return 1
	elseif( curServerTime  > end_time_interval )then
		return 2
	else
		return 3
	end
end


-- 获得军团相关职位的收益系数
-- 返回的是 军团长 副军团长 成员的系数
function getGuildPosionNum( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	local dataTab = string.split(data.posionEarningsRatio, ",")
	-- 普通成员dataTab[1] 军团长dataTab[2] 副军团长dataTab[3]
	return tonumber(dataTab[2])/100,tonumber(dataTab[3])/100,tonumber(dataTab[1])/100
end


-- 获得自己的职位
-- 0为平民，1为会长，2为副会长
function getMyPositionType( ... )
	-- print("UserModel.getUserUid()",UserModel.getUserUid())
	local data = GuildDataCache.getMineSigleGuildInfo()
	-- print_t(data)
    return tonumber(data.member_type)
end

-- 获得对应职位的奖励数量
-- 后端: 0表示平民,1表示会长,2表示副会长
function getRewardNumByMemberType( member_type, cityId )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	local dataTab = string.split(data.posionEarningsRatio, ",")
	local xishu = dataTab[tonumber(member_type)+1]/100
	require "db/DB_City"
	local cityData = DB_City.getDataById(cityId)
	local numTab = string.split(cityData.baseReward, "|")
	local num = numTab[3]
	local retNum = math.floor(num*xishu)
	return retNum
end

-- 根据自己的职位获得奖励系数
function getXiShuByMemberType( member_type )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	local dataTab = string.split(data.posionEarningsRatio, ",")
	local xishu = dataTab[tonumber(member_type)+1]/100
	return xishu
end

-- 得到最大可报名城池个数
function getMaxApplyCityNum( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	return tonumber(data.maxApply)
end

-- 得到进入城池地图限制
function getLimitForCityWar( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	return tonumber(data.hall_lv),tonumber(data.user_lv)
end

-- 得到破坏城池修复城池清除cd花费的金币
function getClearBreakAndRepairCityCDCost( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	return tonumber(data.repairCdGold)
end

-- 得到破坏城池修复城池清除cd时间
function getBreakAndRepairCityCDTime( ... )
	require "db/DB_Legion_citybattle"
	local data = DB_Legion_citybattle.getDataById(1)
	return tonumber(data.repairCd)
end

-- 得到城池npc的名字
function getNpcNameByCityId( cityId )
	local data = getDataById(cityId)
	if(data.defendEnemy ~= nil)then

		require "db/DB_Copy_team"
		local npcData = DB_Copy_team.getDataById(data.defendEnemy)
		return npcData.name
	else
		return ""
	end
end

-- 根据城池id判断是否报名了、
-- true 报名了
function getIsSignupById( cityid )
	local allApplyTab = getSignCity()
	local isHave = false
	for k,v in pairs(allApplyTab) do
		if( tonumber(cityid) == tonumber(v) )then
			isHave = true
			break
		end
	end
	return isHave
end

-- 得到还可以报名几个城池
function getNumForSignupCity( ... )
	local allApplyTab = getSignCity()
 	local maxNum = getMaxApplyCityNum()
 	local allHaveNum = table.count(allApplyTab)
 	local zhanlingTab = myOccupyCityInfo()
	if( not table.isEmpty(zhanlingTab) )then
		allHaveNum = allHaveNum + table.count(zhanlingTab)
	end
 	local num = maxNum - allHaveNum
 	return num
end

-- 得到城池名字和等级颜色
function getCityNameAndLvColor( cityid )
	local cityNameColorArr = {
								ccc3(0xff,0xff,0xff),
								ccc3(0x00,0xff,0x18),
								ccc3(0x00,0xe4,0xff),
								ccc3(0xf9,0x59,0xff),
							}
	local cityData = getDataById(cityid)
	return cityData.name,cityNameColorArr[tonumber(cityData.cityLevel)]
end

--------------------------------------LLP----------------------------------------
local cityInfoPass				= nil  -- 获得军团所有报名的城池信息
local infoTable = {}			--总表
local statuTable = {}			--状态表
local timeTable = {}			--时间表

-- 设置军团所有报名的城池信息
function setCityServiceInfo( data )
	cityInfoPass = nil  -- 获得军团所有报名的城池信息
	infoTable    = {}			--总表
	statuTable   = {}			--状态表
	timeTable    = {}			--时间表
	cityInfoPass = data.ret
	if(not table.isEmpty( cityInfoPass ))then
		-- for k,v in pairs(cityInfoPass.list) do
		-- 	statuTable[tostring(k)] = v
		-- end

		timeTable.signupStart = tonumber(cityInfoPass.timeConf.signupStart)
		timeTable.signupEnd   = tonumber(cityInfoPass.timeConf.signupEnd)
		timeTable.rewardStart  = tonumber(cityInfoPass.timeConf.reward[1])
		timeTable.rewardEnd  = tonumber(cityInfoPass.timeConf.reward[2])
		timeTable.prepare	   = tonumber(cityInfoPass.timeConf.prepare)

		timeTable.arrAttack = cityInfoPass.timeConf.arrAttack

		-- 添加App推送通知 addby chengliang
		require "script/utils/NotificationUtil"
		NotificationUtil.addCityResourcesWarSignNotification()
		NotificationUtil.addCityResourcesWarEnterNotification()
	end
end

-- 返回时间表
function getTimeTable()
	return timeTable
end

function getOffline()
    return cityInfoPass.offline
end

-------------
-- 获取报名信息
function getSignCity()
	if(cityInfoPass~=nil)then
		return cityInfoPass.sign
	else
		return nil
	end
end

-- 添加报名信息
function addSignCity( cityId )
	if(cityInfoPass.sign == nil)then
		cityInfoPass.sign = {}
	end
	table.insert(cityInfoPass.sign, tostring(cityId))
end

-- 获取报名成功信息
function getSucCity()
	-- body
	if(cityInfoPass~=nil)then
		return cityInfoPass.suc
	else
		return nil
	end
end

-- 获取 可攻击 city
function getAttackCity()
	return cityInfoPass.attack
end

-- 获得奖励
function getRewardCity()
	if(cityInfoPass~=nil)then
		return cityInfoPass.reward
	else
		return nil
	end
end

-- 设置已奖励
function setHaveReward()
	if(not table.isEmpty(cityInfoPass))then 
		cityInfoPass.reward = "0"
	end
end

-- 城市的占领时间
function getOcupyCityInfos()
	if(cityInfoPass~=nil)then
		return cityInfoPass.occupy
	else
		return nil
	end
end

-- 我占领的城市
function myOccupyCityInfo()
	local occupyMap = {}
	local occupyCity = CityData.getOcupyCityInfos()
	if( not table.isEmpty(occupyCity)) then
		for cityid, guildInfo in pairs(occupyCity) do
			if( tonumber(guildInfo.guild_id) ==  GuildDataCache.getGuildId())then
				occupyMap[cityid] = guildInfo
			end
		end
	end

	return occupyMap
end
--------------------------------------END----------------------------------------


-- 城池报名 推送处理
function updateSignupTable( ret )
	if(cityInfoPass.sign == nil)then
		cityInfoPass.sign = {}
	end
	cityInfoPass.sign = ret

	-- 大地图报名后 刷新
	require "script/ui/copy/BigMap"
	BigMap.cityStausMenus()

	-- 城池详细信息界面 刷新
	require "script/ui/guild/city/CityInfoLayer"
	CityInfoLayer.refreshCityStateUi()
end

----------------------------------- 城池战按钮小红圈提示 -----------------------------

-- 得到是否显示小红圈
function getIsShowTip( ... )
	local isShow = false
	local timesInfo = getTimeTable()
	if( table.isEmpty(timesInfo) )then
		return
	end
	if(TimeUtil.getSvrTimeByOffset() < timesInfo.signupEnd )then
		-- print("111111111")
		isShow = true
	elseif(TimeUtil.getSvrTimeByOffset() > tonumber(timesInfo.arrAttack[1][1])-tonumber(timesInfo.prepare) and TimeUtil.getSvrTimeByOffset() < tonumber(timesInfo.arrAttack[2][2])) then
		-- print("22222222")
        isShow = true
    elseif(TimeUtil.getSvrTimeByOffset() > timesInfo.rewardStart and TimeUtil.getSvrTimeByOffset() < timesInfo.rewardEnd )then
        local reward_city_id = getRewardCity()
        if(reward_city_id ~= "0" )then
        	-- print("333333333")
            isShow = true
        end
    end
	return isShow
end

--设置Id
function setId( id )
	-- body
	cityId = tonumber(id)
end

function getId()
	-- body
	return cityId
end
function setMissionId( id )
	-- body
	missionId = tonumber(id)
end
function getMissionLevel()
	-- body
	require "db/DB_Corps_quest"
	print(missionId)
	local des = DB_Corps_quest.getDataById(missionId)
	local tab = string.split(des.completeConditions,",")
	return  (tab[2])
end
function getType()
	-- body
	local des = DB_Corps_quest.getDataById(missionId)
	return tonumber(des.questType)
end

----------------------------------------------------------
local _lookingCityInfo = nil

-- 设置正在查看城池的详细信息
-- return:
-- table = {
-- 	cityId = _thisCityID
-- 	dbData = _thisCityBaseData
-- 	serData = _thisCityServiceData
-- }
function setLookingCityInfo( p_info )
	_lookingCityInfo = p_info
end
-- 获得正在查看城池的详细信息
function getLookingCityInfo( ... )
	return _lookingCityInfo
end


function getIsEnterCityTip()
	return _isEnterCityTip
end

function setIsEnterCityTip( pIsShow )
	_isEnterCityTip = pIsShow
end

--[[
	@des:判断主界面的按钮是否显示
--]]
function getMianBtnIsShow( ... )
	-- 功能节点没开
	if not DataCache.getSwitchNodeState(ksSwitchGuild,false) then --23军团系统
        return false
    end
    --军团等级不足
    local data = GuildDataCache.getMineSigleGuildInfo()
    if( (not table.isEmpty(data)) and data.guild_id ~= nil and tonumber(data.guild_id) > 0 ) then
        local my_hallLv = tonumber(data.guild_level)
        if(tonumber(my_hallLv)<5)then
            return false
        end
    end
    --是否已经显示过
    if getIsEnterCityTip() then
    	return false
    end

    local isShow = false
	local signCity   = CityData.getSignCity()
	local sucCity    = CityData.getSucCity()
	local occupyCity = CityData.getOcupyCityInfos()
	local rewardCity = CityData.getRewardCity()

	if signCity~=nil and not table.isEmpty(sucCity) then
		isShow = true
	end
	if sucCity~=nil and not table.isEmpty(signCity) then
		isShow = true
	end
	if occupyCity~=nil and not table.isEmpty(occupyCity) then
		isShow = true
	end
	if rewardCity~=nil and not table.isEmpty(rewardCity) then
		isShow = true
	end
	if isShow then
		local timesInfo = CityData.getTimeTable()
		if( TimeUtil.getSvrTimeByOffset()>= timesInfo.signupStart)then
			isShow = true
		else
			isShow = false
		end
	end
	return isShow
end


