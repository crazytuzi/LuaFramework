--[[
    文件名：BattleUintTesting
    描述：单元测试，模拟数据等
    创建人：luoyibo
    创建时间：2016.08.15
-- ]]

local BattleUintTesting = {}

local tmpSucessArray = {
"hero_qiuchuji",
"hero_hezudao",
"hero_gongsunzhi",
"hero_gongsunlve",
"hero_huazheng",
"hero_zhouzhiruo",
"hero_tianzhusheng",
"hero_wanyanpin",
"hero_xiaozhao",
"hero_xiaolongnv",
"hero_yikexi",
"hero_yinzhiping",
"hero_nimoxing",
"hero_zhangsanfeng",
"hero_zhangwuji",
"hero_zhangcuishan",
"hero_chengjisihan",
"hero_qulingfeng",
"hero_limochou",
"hero_yangbuhui",
"hero_yangkang",
"hero_yangguo",
"hero_yangguo_hei",
"hero_yangxiao",
"hero_yangtiexing",
"hero_kezhene",
"hero_meichaofeng",
"hero_ouyangke",
"hero_ouyangfeng",
"hero_yinli",
"hero_yinsusu",
"hero_hongqigong",
"hero_xiaoxiangzi",
"hero_miejueshitai",
"hero_wangchuyi",
"hero_yinggu",
"hero_baimeiyingwang",
"hero_chengying",
"hero_munianci",
"hero_zishanlongwang",
"hero_yelvqi",
"hero_fanyao",
"hero_qiuqianren",
"hero_qiuqianchi",
"hero_zhaomin",
"hero_daerba",
"hero_guoxiaotian",
"hero_guopolu",
"hero_guofu",
"hero_guojing",
"hero_jinmaoshiwang",
"hero_jinlunfawang",
"hero_yangdingtian",
"hero_luchengfeng",
"hero_luwushuang",
"hero_chenxuanfeng",
"hero_huodu",
"hero_qingyifuwang",
"hero_hanxiaoying",
"hero_mayu",
"hero_hebiweng",
"hero_luzhangke",
"hero_huangshannv",
"hero_huangrong",
}

function BattleUintTesting:simulationData( ... )
    --显示fps
    -- cc.Director:getInstance():setDisplayStats(true)
    math.randomseed(os.clock())

    local result = {
        FightObjs = {}
    }
    for num = 1 , 1 do
        local data = {
            Heros = {},
            Pets = {},
            teamData = {},
            RandNum = math.random(),
            IsPVP = false,
        }

        local randi = math.random(1, #tmpSucessArray - 6)
        for i = 1 , 12 do
             -- local figurePic = tmpSucessArray[1]
            -- local figurePic = tmpSucessArray[i]
            --local figurePic = tmpSucessArray[i % 6 + 1]
            local figurePic = tmpSucessArray[randi + i % 6]
            -- local figurePic = "hero_wushishu"


            -- 获得编辑器数据
            local heroId = bd.interface.getHeroIdByFigure(figurePic)
            if g_editor_mode_hero_data then
                figurePic = g_editor_mode_hero_data.heroModelName

                if g_editor_mode_hero_data.heroID then
                    heroId = g_editor_mode_hero_data.heroID
                else
                    heroId = bd.interface.getHeroIdByFigure(figurePic)
                end
            end

            local heroNaid = bd.interface.getNAIDByHeroId(heroId)
            local heroRaid = bd.interface.getRAIDByHeroId(heroId)





            if heroId == 0 then
                print("Test_tmpHeroModelIdArray中没有配置这个hero的id。")
            end

            if not heroNaid then
                heroNaid = 1001050
            end
            if not heroRaid then
                heroRaid = 1002075
            end


            data.Heros[i] = {
                HP = math.random(500, 2000),
                TotalHp = 2000,
                AP = 100,
                DEF = math.random(1,50),
                RP = 100,

                HIT = 52000000,
                DOD = 0,
                CRI = math.random(1,1),
                TEN = math.random(1,1),
                BLO = math.random(1,1),
                BOG = math.random(1,1),
                CRID = math.random(1,1),
                TEND = math.random(1,1),
                NAId = heroNaid,
                RAId = heroRaid,
                HeroModelId = heroId,

                DAM = 1,--伤害值
                APR = 1, --攻击加成%
                HPR = 1, --生命加成%
                DEFR = 1, --防御加成%
                CP = 1, --治疗值
                BCP = 1, --被治疗值
                CPR = 1, --治疗率%
                BCPR = 1, --被治疗率%
                DAMADD = 1, --伤害加成
                DAMCUT = 1, --伤害减免
                DAMADDR = 1, --伤害加成%
                DAMCUTR = 1, --伤害减免%
                BuffList = "",
                IsBoss = false,

                BodyTypeR = 10000,--人物放大比例
                Step = 0,--人物突破次数
                LargePic = figurePic,
            }


            local petModel
            if g_editor_mode_hero_data then
                petModel = g_editor_mode_hero_data.petData
            end
            if petModel ~= nil then
                data.Pets[i] = {
                    RADAMADDR = 0,
                    APR = 0,
                    FSP = 0,
                    TEN = 0,
                    RP = 0,
                    RebornStep = 0,
                    STR = 0,
                    RCDAMADDR = 0,
                    Quality = 0,
                    CON = 0,
                    CP = 0,
                    DEFR = 0,
                    CPR = 0,
                    BCP = 0,
                    KCIds = "",
                    HeroModelId = petModel.ID,
                    AP = 133,
                    Step = 0,
                    BuffList = petModel.atkBuffID,
                    HP = 19829,
                    BOG = 0,
                    TEND = 0,
                    CRID = 0,
                    RCDAMCUTR = 0,
                    BLO = 0,
                    RaceId = 0,
                    CRI = 0,
                    DAMADDR = 0,
                    DEFADD = 0,
                    APADD = 0,
                    RDDAMCUTR = 0,
                    HPR = 0,
                    DOD = 0,
                    FAP = 0,
                    INTE = 0,
                    RADAMCUTR = 0,
                    BCPR = 0,
                    TaoId = 0,
                    LargePic = "",
                    RBDAMCUTR = 0,
                    DAMCUT = 0,
                    BodyTypeR = 10000,
                    DAMCUTR = 0,
                    RBDAMADDR = 0,
                    DEF = 1217,
                    TotalHp = 19829,
                    RDDAMADDR = 0,
                    HPADD = 0,
                    NAId = 0,
                    RAId = 0,
                    DAMADD = 0,
                    FormationId = 3,
                    HIT = 0,
                    IsBoss = false,
                }
            end

            -- if i == 8 then
            --     data.Heros[i].IsBoss = true
            --     data.Heros[i].BodyTypeR = 25000
            --     data.Heros[i].HP = 1
            --     data.Heros[i].TotalHp = 1
            -- elseif i > 6 then
            --     data.Heros[i] = {}
            -- end

            -- if i < 10 then
            --     data.Heros[i] = {}
            -- end

            if i < 7 then
                -- data.Heros[i].RP = 90
            end

        end
        data.TeamData = {
            { --友方数据
                Fsp = 3, --先攻值
                Fap = 1, --战力值
            },
            { --敌方数据
                Fsp = 2, --先攻值
                Fap = 1, --战力值
            },
        }
        table.insert(result.FightObjs, data)
    end

    -- result.Condition = {
    --     Type = bd.BattleChallengeType.eType2,
    --     Value = 1,
    -- }

    --result.TreasureId = 1
    return result
    --return require("ComBattle.BattleGuideConfig.BattleScript0000")
end


-- 调用测试战斗
function BattleUintTesting:TestBattle()
    require("ComBattle.BattleInit")
    local testData = self:simulationData()
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = testData,
        },
    })
end

-- 保存数据的临时代码
--[[
            -- 临时保存到文件
            local tmp_file = "/Users/john/Desktop/tmp/shediao1/temp.txt"
            local f = io.open(tmp_file , "w")
            local tmpStr = json.encode(fightData)
            f:write(tmpStr)
            f:close()
]]

-- 调用本地文件数据，模拟战斗
function BattleUintTesting:TestLocalBattle()
    local tmp_file = "/Users/john/Desktop/tmp/shediao1/temp2_hr.txt"
    local f = io.open(tmp_file , "r")
    local tmpStr = json.encode(fightData)
    local dataStr = f:read("*a")
    local fightInfo = json.decode(dataStr)
    f:close()

    require("ComBattle.BattleInit")
    LayerManager.addLayer({
        name = "ComBattle.BattleLayer",
        data = {
            data = fightInfo,
        },
    })
end


return BattleUintTesting
