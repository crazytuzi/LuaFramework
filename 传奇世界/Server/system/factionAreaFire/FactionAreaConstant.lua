FACTION_FIRE_EXP = 324					-- 篝火 buff id
FACTION_ADD_FIRE_TIMES = 1				--添柴次数
FACTION_FIRE_NEED_LV = 3				--篝火开启需要行会等级
FACTION_FIRE_WOOD_CONTRIBUTION 		= 20 	--添柴一次消耗帮贡
-----------------------------------------------------------
FACTION_FIRE_DURATION = 0				--篝火 经验BUFF持续时间
FACTION_FIRE_SPACE_TIME = 0				--buff效果间隔时间
FIRE_OPEN_TIME 		=  "" --"*,*,*,*,14:00:00-21:00:00"

--[[
local buffRecord = require "data.BuffDB" 
for _, data in pairs(buffRecord or {}) do
	if FACTION_FIRE_EXP==data.id then		
		FACTION_FIRE_DURATION = tonumber(data.lastTime)/1000 or 900
		FACTION_FIRE_SPACE_TIME = tonumber(data.spaceTime)/1000 or 10
		FACTION_FIRE_NOTIFY_TIME = 300
		break
	end
end
]]

FACTION_FIRE_DURATION = 900
FACTION_FIRE_SPACE_TIME = 10
FACTION_FIRE_NOTIFY_TIME = 300

-- 行会篝火状态
FationFireState = 
{
	activityNotStart = 0,		-- 活动未开启，时间不在活动时间内
	waitLearderStart = 1,		-- 等待会长开启
	prepareStart = 2,			-- 预备开启
	start = 3,					-- 已经开启
	fireEnd = 4,				-- 结束
}

--------------------------------------------------------

--错误提示
FACTIONAREA_FIRE_OPNE					=	-1 			--行会篝火活动已经开启!
FACTIONAREA_FIRE_CLOSE					=	-2			--行会篝火活动已经结束!
FACTIONAREA_LV_NOT_ENOUGTH 				= 	-3 			--行会等级不足
FACTIONAREA_CONTRIBUTE_NOT_ENOUGTH		= 	-4			--行会贡献不足
FACTIONAREA_HAD_OPEN					=	-5 			--今日行会篝火活动已经结束!
FACTIONAREA_ADD_SUCCESS					=	-6			--火柴添加成功!