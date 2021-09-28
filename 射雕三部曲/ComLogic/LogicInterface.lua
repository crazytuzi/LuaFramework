--[[
local FightRetData = {
    isSuccess =  bool , 是否请求成功
    FightResult = bool, --是否胜利(true:胜利; false:失败)
    Round = index, 回合数
    Step = index,  当前回合的步骤数
    RoundEnding = bool, 是否是回合结束
    FightAtom = {
        {
            atomType = type,  数据类型
            fromPos = index,   出手人的位置(宠物)
            rp = number,    出手人的怒气变化（规则：攻击者会增长怒气）
            skillId = index,    出手人使用的技能id
            to = {
                {
                    {
                        atomType = type,  数据类型
                        toPos = index,    挨打人的位置
                        hp = number,    挨打人的血量变化
                        rp = number,    挨打人的怒气变化
                        effet = type,   挨打人的伤害值表现类型（暴击，普通，闪避等）
                        dead = {
                            rp = number,        攻击者的怒气变化
                        }
                    }
                },
                ......
            }
        },
        {
            atomType = type,  数据类型
            uniqueId = index,   buff唯一标识
            buffId = index,     buffId
            from_pos = index ,     buff的发起人的位置
            type = type,        buff(附加，结束，触发)
            to_pos = index,    目标的位置
            exec = {
                {}
            }
        },
    },
    CoreData = {
        heroList = {
            {
                hp = 1,
                rp = 1,
                mhp = 1,
                dead = false,
            },
            ......
        },
        storageList = {
            enemy = {
                hp = 1,
                rp = 1,
                mhp = 1,
                dead = false,
            },
            teammate = {
                hp = 1,
                rp = 1,
                mhp = 1,
            },
        },
    }
}

InitParams = {
    MaxRound,       最大回合数
    RandSeed,       随机种子
    IsPVP,          是否是pvp,决定出手顺序
    FullInfo,(bool) 返回所有人的生命值和怒气值
    ProjectName,    项目名
    HeroList = {
        {
            hero1  (见LogicHero)
        },
        {
            hero2
        }
        ......
    },
    StorageList = {
        enemy = {
            {hero1}
            {hero2}
        },
        teammate = {
            {hero1}
            {hero2}
        }
    },
    PetList = {
        {hero1},
        {hero2}
        ......
    },
    TeamData = {
        Friend = { --友方数据
            Fsp = 3, --先攻值
            Fap = 1, --战力值
            totalAttr = hero,我方总属性值
            friendList = {},小伙伴列表
        },
        Enemy = { --敌方数据
            Fsp = 2, --先攻值
            Fap = 1, --战力值
            totalAttr = hero,敌方总属性值
            friendList = {},小伙伴列表
        },
    }
}
--]]

require("ComLogic.LogicDefine")
require("ComLogic.StatisticsManager")

local ComLogic = class("ComLogic", function(params)
    return {params = nil}
end)

--[[
    params:
        InitParams
    return:
        result      是否初始化成功
        FightRetData
]]
function ComLogic:init(params)
    if (not params) or (type(params.HeroList) ~= "table")
        or (not params.RandSeed) or (type(params.TeamData) ~= "table")
        or (not params.MaxRound) then
        dump(params)
        error("logic params is not correct！")
    end
    self.data = require("ComLogic.LogicData").new(params)
    -- 初始化统计数据
    StatisticsManager.reset(self.data:getHeroList(), self.data.PetList, self.data.PetList3)
    self.process = require("ComLogic.LogicProcess").new(self.data)
    return self.process:init()
end

--[[
    params:
        autoPlay        是否是自动战斗
        skill           使用技能的位置
        multi           连续使用几个技能
    return:
        FightRetData
]]
function ComLogic:calc(params)
    return self.process:excute(params)
end

return ComLogic