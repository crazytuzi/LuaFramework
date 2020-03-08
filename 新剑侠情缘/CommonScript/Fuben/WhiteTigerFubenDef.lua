Fuben.WhiteTigerFuben = Fuben.WhiteTigerFuben or {}
local WhiteTigerFuben = Fuben.WhiteTigerFuben
WhiteTigerFuben.OPEN_LEVEL    = 30                      --开启等级
WhiteTigerFuben.DEGREE_KEY    = "WhiteTigerFuben"       --次数
WhiteTigerFuben.PREPARE_MAPID = 1026                    --准备场地图
WhiteTigerFuben.FIGHT_MAPID   = 1027                    --副本地图
WhiteTigerFuben.OUTSIDE_MAPID = 1028                    --外围副本地图
WhiteTigerFuben.SUB_ROOM_NUM  = 8                       --外围副本数量
WhiteTigerFuben.tbSubRoomTrap = {3344, 3693}            --外围副本传送点
WhiteTigerFuben.ACTIVITY_NAME = "白虎堂"
WhiteTigerFuben.PREPARE_POS   = {6940, 7268}            --准备场进入位置
WhiteTigerFuben.PREPARE_TIME  = 60*5                    --准备时间(s)
WhiteTigerFuben.PREPARE4PK    = 60                      --开始刷怪后等待开启pk的时间
WhiteTigerFuben.PEACE_TIME    = 60*4                    --主地图和平时间，准备时间结束开始计时，这段时间内，玩家处于和平状态，过了这段时间开PK
WhiteTigerFuben.BOSS_START    = {WhiteTigerFuben.PREPARE_TIME + 60*1.5, 60*5, 60*7, 60*10.5} --每层BOSS刷新时间
WhiteTigerFuben.AUTO_JOIN_TIME= 10                       --在正式开始前提示玩家随机进入的时间，使用时会提前几秒，避免因延迟导致的进入失败
WhiteTigerFuben.PREPARE_FIRE  = "1304|8043|7307"              --准备场篝火参数:npc模板ID|坐标X|坐标Y
WhiteTigerFuben.tbMainRoomTrap = {  -- 东南西北几个房间的传送点，需配置
    {2527, 8150},
    {6930,  16416},  
    {17500, 11427},
    {10185, 3601},
}
WhiteTigerFuben.STATE_NONE     = 0
WhiteTigerFuben.STATE_PREPARE  = 1
WhiteTigerFuben.STATE_FIGHTING = 2
WhiteTigerFuben.nState         = WhiteTigerFuben.nState or WhiteTigerFuben.STATE_NONE
WhiteTigerFuben.tbSubDegree    = WhiteTigerFuben.tbSubDegree or {} --已经减掉次数的玩家
WhiteTigerFuben.tbComboInfo    = WhiteTigerFuben.tbComboInfo or {}
WhiteTigerFuben.tbEnterTime    = {} --玩家进入时间，供TLog使用
WhiteTigerFuben.tbKinJoinNum   = {} --家族参加人数
WhiteTigerFuben.MAX_PRESTIGE   = 100 --每场最大威望

WhiteTigerFuben.tbBossKinPrestige = { --boss被击杀时增加的家族威望
    [932] = {5, 3, 2},
    [712] = {10, 5, 3},
    [713] = {20, 10, 5},
    [714] = {50, 25, 15},
}

WhiteTigerFuben.JOIN_CONTRIBUTION = 100
WhiteTigerFuben.tbFloorContribution = { --到下一层时的家族贡献
    [1] = 50,
    [2] = 100,
    [3] = 200,
    [4] = 500,
    [5] = 500,
}
WhiteTigerFuben.tbFloorAwardRate = {
    {nMinLevel = 40, nMaxLevel = 60, nJoinRate = 200, nFloorRate = 65}, --下限等级(包括)，上限等级，参与掉落概率，通过每层掉落概率
    {nMinLevel = 60, nMaxLevel = 100, nJoinRate = 300, nFloorRate = 100},
}
WhiteTigerFuben.tbFloorAwardRate[#WhiteTigerFuben.tbFloorAwardRate].nMaxLevel = 999 --WhiteTigerFuben.tbFloorAwardRate最后一个配置的最大等级是999
WhiteTigerFuben.tbFloorAward = {"Item", 3083, 1}

WhiteTigerFuben.FIT_KIN_IN_MAP = 3 --3个家族在一张地图为最优解
WhiteTigerFuben.CROSS_MAP_TID = 1029 --跨服地图模板ID
WhiteTigerFuben.CROSS_BOSS_TID = 1953 --跨服最终boss模板ID
WhiteTigerFuben.CROSS_FLOOR_BOSS_TID = 1954 --跨服第二层boss模板ID

--TODO:@_@ 白虎堂爆率按照时间轴给予

--[[
WhiteTigerFuben.tbCross_Award = {
    {szTimeFrame = "OpenLevel39", tbAward = {
            [3022] = {0.4, 1350000},
            [2161] = {0.15, 5000000},
            [2160] = {0.25, 1500000},
            [788]  = {0.2, 200000},
        }
    },
    {szTimeFrame = "OpenLevel59", tbAward = {
            [4849] = {0.4, 4000000},
            [3022] = {0.2, 1350000},
            [2161] = {0.1, 5000000},
            [2160] = {0.05, 1500000},
            [788]  = {0.1, 200000},
            [1526] = {0.15, 5000000},
        }
    },
    {szTimeFrame = "OpenLevel79", tbAward = {
            [4849] = {0.4, 4000000},
            [3022] = {0.05, 1350000},
            [2161] = {0.1, 5000000},
            [1526] = {0.15, 5000000},
            [10490] = {0.3, 2000000},
        }
    },
    {szTimeFrame = "OpenLevel99", tbAward = {
            [4849] = {0.4, 4000000},
            [3022] = {0.05, 1350000},
            [2161] = {0.1, 5000000},
            [1526] = {0.15, 5000000},
            [10490] = {0.15, 2000000},
            [10491] = {0.15, 2000000},
        }
    },
}
]]

WhiteTigerFuben.tbCross_Award = {
    [4849] = {0.2, 4000000},   -- 初级魂石·唐晓(唯一)
    [3022] = {0.2, 1350000},   -- 初级魂石·雷(唯一)
    [2161] = {0.1, 5000000},  -- 5级同伴技能书
    [2160] = {0.2, 1500000},  -- 4级同伴技能书
    [788] = {0.2, 200000},     -- 高级藏宝图
    [1526] = {0.1, 5000000},  -- 3级附魔石·攻击
}

WhiteTigerFuben.CROSS_TOP_FLOOR = 5
WhiteTigerFuben.SWITCH_ZONE_MAP_PERFRAME = 5 --每帧登录跨服人数
WhiteTigerFuben.CROSS_TIMEFRAME = "OpenLevel39"

function WhiteTigerFuben:IsPrepareMap(nMapTemplateId)
    if MODULE_GAMECLIENT then
        nMapTemplateId = nMapTemplateId or me.nMapTemplateId
    end
    return nMapTemplateId == self.PREPARE_MAPID
end