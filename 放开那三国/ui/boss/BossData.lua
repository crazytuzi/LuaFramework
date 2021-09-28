
-- Filename：	BossData.lua
-- Author：		Li Pan
-- Date：		2013-12-26
-- Purpose：		世界boss

require "RequestCenter"

module("BossData", package.seeall)

--基本信息
bossInfo = nil
--排行
rankList = nil

--鼓舞消息	
inspireInfo = nil

--攻击数据
attackData = nil

--复活的数据
rebirthData = nil 

-- 奖励
prizeData = nil

-- 离开
leaveBossData = nil

_bossTimeOffset = 0 -- 世界boss开启时间的偏移 addBy chengliang

-- 排名消息
rankInfo = nil 
--击杀boss的名字
killName = nil

-- 获取世界boss开启时间的偏移 addBy chengliang
function getBossTimeOffset()
	return _bossTimeOffset
end

-- 设置世界boss开启时间的偏移  addBy chengliang
function setBossTimeOffset( bossTimeOffset )
	_bossTimeOffset = tonumber(bossTimeOffset)
end

-- 条件1:周二、四、 六 是新boos 其他是老boos
-- 条件2:boss1等级达到xx级后才能打新boss
function getIsNewBoos( ... )
	local retData = false
	local cur_time = TimeUtil.getSvrTimeByOffset()
	local curDate = os.date("*t", cur_time)
	local wDay = tonumber(curDate.wday) -- 星期天为1
	require "db/DB_Worldboss"
	local boos2TimeStr = DB_Worldboss.getDataById(1).boss2Time
	local boos2TimeData = string.split(boos2TimeStr, ",")
	for k,v in pairs(boos2TimeData) do
		if( wDay-1 == tonumber(v) )then
			retData = true
		end
	end

	-- 如果boss等级低则不开启新boss
	if( tonumber(bossInfo.level) < tonumber(DB_Worldboss.getDataById(1).boss2level))then
		retData = false
	end
	return retData
end

-- 得到新boos奖励预览的id数组
function getNewBoosRewardIds( ... )
	require "db/DB_Worldboss"
	local boos2Data = DB_Worldboss.getDataById(1).boss2RewardIds
	local boos2Ids = string.split(boos2Data, ",")
	return boos2Ids
end

-- 得到老boos奖励预览的id数组
function getOldBoosRewardIds( ... )
	require "db/DB_Worldboss"
	local boos1Data = DB_Worldboss.getDataById(1).boss1RewardIds
	local boos1Ids = string.split(boos1Data, ",")
	return boos1Ids
end

--[[
	@author:			bzx
	@desc:				得到Boss阵型
--]]
function getFormation( ... )
	if bossInfo.va_boss_atk.formation == nil then
		return {}
	else
		return bossInfo.va_boss_atk.formation["1"]
	end
end

--[[
	@author:		bzx
	@desc: 			设置Boss阵型
--]]
function setFormation( p_formation )
	bossInfo.va_boss_atk.formation["1"] = p_formation
end

--[[
	@author:	bzx
	@desc:		得到是否使用Boss阵型("1"表示使用，"0"表示不使用)
--]]
function isUseFormation( ... )
	return bossInfo.formation_switch
end

--[[
	@author:				bzx
	@desc:					设置是否使用Boss阵型
	@param:		p_use 		"1"表示使用，"0"表示不使用
--]]
function setUseFormation( p_use )
	bossInfo.formation_switch = p_use 
end


--[[
	@des 	: 获得是否可以自动打龙
	@param 	: 
	@return :
--]]
function getIsOpenAutoFight( ... )
	require "db/DB_Vip"
	-- 需要的vip
	local needVip = 0
	local i = 1
	for k,v in pairs(DB_Vip.Vip) do
        local vInfo = DB_Vip.getDataById(tostring(i))
        local data = vInfo.worldbossAutoAttack
        -- 1是开启0是未开启
        if(tonumber(data) == 1)then
        	needVip = tonumber(vInfo.level)
            break
        end
        i = i+1
    end

    require "db/DB_Normal_config"
    local needLeve = tonumber(DB_Normal_config.getDataById(1).boss_needlv)
    -- 是否开启
    local isOpen = false
    if(UserModel.getVipLevel() >= needVip or  UserModel.getHeroLevel() >= needLeve )then
    	isOpen = true
    else
    	isOpen = false
    end

	return isOpen, needLeve, needVip
end







