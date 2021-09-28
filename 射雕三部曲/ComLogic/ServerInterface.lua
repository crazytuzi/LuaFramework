--[[
    filename: ComLogic.ServerInterface.lua
    description: 服务的校验接口
    date: 2016.11.16

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

-------------------------------------------------
require("ComLogic.common_func")
require("ComLogic.LogicDefine")
require("ComLogic.jsonlua")
require("ComLogic.LogicVersion")

debug_server_verify = false
if debug_server_verify then
    debug_server_file = "D:\\temp.txt"
end

--[[
    params:
        string_server 服务器端传给客户端的初始数据
        string_client 客户端返回给服务器端的玩家操作数据（允许为空)
    return:
        {
            result:战斗胜利还是失败
            clientVer:客户端版本号
            serverVer:服务端版本号
            clientSystemVer:客户端资源版本号
            serverSystemVer:服务器资源版本号
            stageIdx:最终关卡
            round:回合数
            heroList = {
                [1] = {
                    hp = 100,
                    rp = 100,
                    mhp = 100,
                },...
            }
            storageList = {
                enemy = {
                    [1] = {
                        hp = 100,
                        rp = 100,
                        mhp = 100,
                    },...
                },
                teammate = {
                    [1] = {
                        hp = 100,
                        rp = 100,
                        mhp = 100,
                    },...
                }
            }
        }
]]
function CheckBattleResult(string_server, string_client)
    local battleData
    if type(string_server) == "string" then
        battleData = _json._decode(string_server)
    else
        battleData = string_server
    end

    local fn = loadstring("return " .. string_client)
    if not fn then
        error(TR("请检查<客户端操作数据>格式是否正确，如转义等问题。"))
    end
    local clientData = fn and fn()
    local stageDatas = LoadServerData(battleData, clientData.maxRound)

    if debug_server_verify and clientData.verify_str then
        local f = io.open(debug_server_file , "a+")
        local client_d = _json._decode(clientData.verify_str)
        if not compare_table(battleData.FightObjs, client_d.FightObjs) then
            local tmp_server = _json._encode(battleData)
            f:write(tmp_server)
            f:write("\n")
            f:write(clientData.verify_str)
        else
            f:write("success")
        end
        f:close()
    end

    -- 校验关卡数据
    local state, round, hero, stageIdx
    for k, v in ipairs(stageDatas) do
        stageIdx = k

        state, round, hero, serverVersion = CalcStageResult(v, clientData[k])
        if type(state) == "number" then
            break
        end
        if state == false then
            break
        end
    end

    require("Config.SystemVersionNumber")
    return {
        result          = state,
        clientVer       = clientData.calcVer,
        clientSystemVer = clientData.sysVer,
        serverVer       = require("ComLogic.LogicVersion"),
        serverSystemVer = SystemVersionNumber.items[1].systemNum,
        stageIdx        = stageIdx,
        round           = round,
        heroList        = hero.heroList,
        storageList     = hero.storageList,
        -- 添加伤害数据统计
        statistsData    = _json._encode(require("ComLogic.StatisticsManager").getStatisticsData()),
    }
end


-- 校验关卡数据
function CalcStageResult(stageData, clientData)
    -- 初始化数据
    local hero = {}
    local serverRecord = {}

    local core = require("ComLogic.LogicInterface").new()
    stageData.FullInfo = true
    local result = core:init(stageData)
    if not result then
        return false, nil, nil, nil
    end
    if debug_server_verify then
        table.insert(serverRecord , clone(result))
    end

    local fightResult

    -- 模拟战斗过程
    local autoPlay = true
    local step = 1
    local round = 1
    -- 客户端操作数据
    local input = clientData and clientData.input
    local skip = clientData and clientData.skip
    local maxStep = clientData and clientData.mStep or 0

    while true do
        local tmp

        local in_ = input and input[step]
        if in_ then
            tmp = {autoPlay = in_[1], skill = in_[2], multi = in_[3]}
            autoPlay = in_[1]
        elseif step <= maxStep or skip ~= true then
            tmp = {autoPlay = autoPlay}
        else
            tmp = {autoPlay = true}
        end

        -- 调用逻辑计算
        local result = core:calc(tmp)
        if debug_server_verify then
            table.insert(serverRecord , clone(result))
        end
        if result.heroList then
            hero = {heroList = result.heroList, storageList = result.storageList}
        end

        if result.FightResult ~= nil then
            fightResult = result.FightResult
            round = result.Round
            break
        end

        step = step + 1
    end

    if debug_server_verify then
        local f = io.open(debug_server_file , "a+")
        local tmp_server = _json._encode(serverRecord)
        f:write(tmp_server)
        f:close()
    end

    return fightResult, round, hero, nil
end

function LoadServerData(data, maxRound)
    local stageData = {}
    if not data.FightObjs then
        error(TR("找不到FightObjs，请和服务器确认传入数据是否正确！"))
    end
    for k, v in ipairs(data.FightObjs) do
        table.insert(stageData, LoadFightObj(v, maxRound))
    end

    return stageData
end

function LoadFightObj(fightObj, maxRound)
    local result = {
        MaxRound    = maxRound or 30,
        RandSeed    = fightObj.RandNum,
        IsPVP       = fightObj.IsPVP,
        ProjectName = logic_project_name,
        HeroList    = {},
        StorageList = {enemy = {}, teammate = {},},
        PetList     = {},
        PetList2    = {},
        PetList3    = {},
        TeamData    = {},
    }

    local function loadHeroObj(info)
        if next(info) ~= nil then
            local hero = clone(info)
            hero["MHP"] = info["TotalHp"]

            local buffList = ld.split(hero["BuffList"], ",")
            if buffList then
                for k, v in pairs(buffList) do
                    buffList[k] = tonumber(v)
                end
            end
            hero["BuffList"] = buffList or {}

            local startList = ld.split(hero["KCIds"], ",")
            if startList then
                for k , v in pairs(startList) do
                    startList[k] = tonumber(v)
                end
            end
            hero["KCIds"] = startList or {}

            --转换计算单位
            --守方和攻防的: 命中,闪避, 格挡,破击,暴击,韧性,守护,必杀共8个属性,都/100.
            hero["HIT"] = (hero["HIT"] or 0)/100
            hero["DOD"] = (hero["DOD"] or 0)/100
            hero["CRI"] = (hero["CRI"] or 0)/100
            hero["TEN"] = (hero["TEN"] or 0)/100
            hero["BLO"] = (hero["BLO"] or 0)/100
            hero["BOG"] = (hero["BOG"] or 0)/100
            hero["CRID"] = (hero["CRID"] or 0)/100
            hero["TEND"] = (hero["TEND"] or 0)/100
            return hero
        end
    end

    for from, to in pairs({
        ["Heros"]  = "HeroList",   -- 主将
        ["Pets"]   = "PetList",    -- 回合技
        ["TaoObj"] = "PetList2",   -- 宠物开场技
        ["Zhenshous"]="PetList3",   -- 回合开始宠物技
    }) do
        local orginList = fightObj[from]
        if orginList then
            local targetList = result[to]
            for k, v in pairs(orginList) do
                targetList[k] = loadHeroObj(v)
            end
        end
    end

    -- 先手值
    result.TeamData.Friend = fightObj.TeamData[1]
    if result.TeamData.Friend.TotalHero then
        result.TeamData.Friend.TotalHero = loadHeroObj(result.TeamData.Friend.TotalHero)
    end
    result.TeamData.Enemy = fightObj.TeamData[2]
    if result.TeamData.Enemy.TotalHero then
        result.TeamData.Enemy.TotalHero = loadHeroObj(result.TeamData.Enemy.TotalHero)
    end
    return result
end
