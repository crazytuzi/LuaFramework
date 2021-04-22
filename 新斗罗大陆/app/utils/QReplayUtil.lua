-- @qinyuanji
-- A class to wrap all the operations for replay
-- All the replays are saved locally when uploading to server, in order to avoid unnecessary download.

local QReplayUtil = class("QReplayUtil")
local QUIViewController = import("..ui.QUIViewController")
local QDungeonResourceLoader = import("..loader.QDungeonResourceLoader")
local QMyAppUtils = import(".QMyAppUtils")
local QActorProp = import("..models.QActorProp")
local QBattleLog = import("..controllers.QBattleLog")

local lastReplay = "last.reppb"
local replaysDir = "replays"

-- 援助技能
local function tableIndexof(supports, actorId)
    for i, v in pairs(supports or {}) do
        if v.actorId == actorId then
            return i
        end
    end
end

function QReplayUtil:getBattleTypeNumByReportType(reportType)
    local battleType
    if reportType == REPORT_TYPE.GLORY_TOWER then
        battleType = BattleTypeEnum.GLORY_TOWER
    elseif reportType == REPORT_TYPE.ARENA then
        battleType = BattleTypeEnum.ARENA
    elseif reportType == REPORT_TYPE.SILVERMINE then
        -- 魂兽森林
        battleType = BattleTypeEnum.SILVER_MINE
    elseif reportType == REPORT_TYPE.PLUNDER then
        -- 公会狩猎
        battleType = BattleTypeEnum.KUAFU_MINE
    elseif reportType == REPORT_TYPE.GLORY_ARENA then
        --  荣耀争霸赛
        battleType = BattleTypeEnum.GLORY_COMPETITION
    elseif reportType == REPORT_TYPE.STORM_ARENA then
        -- 风暴竞技场
        battleType = BattleTypeEnum.STORM
    elseif reportType == REPORT_TYPE.MARITIME then
        -- 海商  
        battleType = BattleTypeEnum.MARITIME
    elseif reportType == REPORT_TYPE.METAL_CITY then
        -- 金属之城  
        battleType = BattleTypeEnum.METAL_CITY
    elseif reportType == REPORT_TYPE.FIGHT_CLUB then
        -- 地狱杀戮场
        battleType = BattleTypeEnum.FIGHT_CLUB
    elseif reportType == REPORT_TYPE.SANCTUARY_WAR then
        -- 全大陆精英赛
        battleType = BattleTypeEnum.SANCTUARY_WAR
    elseif reportType == REPORT_TYPE.DRAGON_WAR then
        -- 武魂战
        battleType = BattleTypeEnum.DRAGON_WAR
    elseif reportType == REPORT_TYPE.CONSORTIA_WAR then
        -- 宗门战
        battleType = BattleTypeEnum.CONSORTIA_WAR
    elseif reportType == REPORT_TYPE.SOTO_TEAM then
        -- 宗门战
        battleType = BattleTypeEnum.SOTO_TEAM
    elseif reportType == REPORT_TYPE.MOCK_BATTLE then
        -- 大师赛
        battleType = BattleTypeEnum.MOCK_BATTLE   
    elseif reportType == REPORT_TYPE.SILVES_ARENA then
        battleType = BattleTypeEnum.SILVES_ARENA 
    elseif reportType == REPORT_TYPE.SOUL_TOWER then
        -- 升灵台
        battleType = BattleTypeEnum.SOUL_TOWER    
    else
        assert(false, "unknown report type: "..tostring(reportType))
    end
    
    return battleType
end

-- 全局属性
function QReplayUtil:getUserAttrList()
    local userAttrList = {}
    userAttrList.soulGuideLevel = remote.user.soulGuideLevel or 0
    userAttrList.reformInfo = {}

    local heroIds = remote.herosUtil:getHaveHero()
    for _, actorId in pairs(heroIds) do
        local heroInfo = remote.herosUtil:getHeroByID(actorId) or {}
        local mountInfo = heroInfo.zuoqi
        if mountInfo and mountInfo.reformLevel and mountInfo.reformLevel > 0 then
            table.insert(userAttrList.reformInfo, {zuoqiId = mountInfo.zuoqiId, reformLevel = mountInfo.reformLevel})
        end
    end

    userAttrList.skinPictureIds = remote.fashion:getSkinPictureIds()
    
    return userAttrList
end

-- 获取fighter对象中的全局属性
-- attrList 中只保留当前的两个数据，其他的都丢弃
function QReplayUtil:getAttrListByFighterAttrList(attrList)
    if attrList == nil then return {} end

    local newAttrList = {}
    newAttrList.soulGuideLevel = attrList.soulGuideLevel
    newAttrList.reformInfo = attrList.reformInfo
    newAttrList.skinPictureIds = attrList.skinPictureIds

    return newAttrList
end


function QReplayUtil:getLocalCachedReplay(replayId, typeModel)
    return string.format("%s/%s_%d_%s.reppb", replaysDir, remote.user.userId, replayId or 0, typeModel)
end

-- Upload replay
-- Read replay content from last replay and save it locally
function QReplayUtil:uploadReplay(replayId, replayInfo, success, fail, typeModel)
    if typeModel ~= REPORT_TYPE.SILVES_ARENA and not fileExists(lastReplay) then
        printError("Replay file doesn't exist")
        fail()
    else
        local battleType = self:getBattleTypeNumByReportType(typeModel)
        app:getClient():globalFightUploadFightersDataRequest(battleType, replayId, replayInfo, function ()
            if success then
                success()
            end
            printInfoWithColor(PRINT_FRONT_COLOR_PURPLE, PRINT_BACK_COLOR_YELLOW, "Upload replay " .. replayId .. ".reppb to server successfully")
        end, function ()
            if fail then
                fail()
            end
        end)
    end
end

-- Download replay
-- Replay ID is unique, so check if replay is saved on disk. If not, download from server.
-- isGetReplayInfo 详细
function QReplayUtil:downloadReplay(replayId, success, fail, typeModel, isGetReplayInfo)
    local target = lastReplay
    if nil == typeModel then
        return
    end

    local fileutil = CCFileUtils:sharedFileUtils()
    if directoryExists(replaysDir) or createSubDirectory(replaysDir) then
        target = self:getLocalCachedReplay(replayId, typeModel)
    end

    if fileExists(target) and target ~= lastReplay then
        local replayInfo = nil
        if isGetReplayInfo then
            local content = readFromBinaryFile(target)
            local info = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayList", content)
            if info.replayList then
                replayInfo = info.replayList[1]
            end
        end
        success(target, replayInfo)
    else
        local battleType = self:getBattleTypeNumByReportType(typeModel)
        app:getClient():globalFightGetFightReportDataRequest(battleType, replayId, function (data)
                local fightReportData = data.gfGetFightReportDataResponse.fightReportData
                if not fightReportData or fightReportData == "" then
                    app.tip:floatTip("战报不存在！")
                    return
                end
                local content = crypto.decodeBase64(fightReportData)
                writeToBinaryFile(target, content)

                local replayInfo = nil
                if isGetReplayInfo then
                    local info = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayList", content)
                    if info.replayList then
                        replayInfo = info.replayList[1]
                    end
                end
                success(target, replayInfo)
            end, function()
                if fail then
                    fail()
                end
            end)
    end
end

function QReplayUtil:downloadSilvesArenaReplay(replayId, index, success, fail, isFightEndWatch)
    if isFightEndWatch == nil then
        isFightEndWatch = true
    end

    local replayFilePath = lastReplay

    local fileutil = CCFileUtils:sharedFileUtils()
    if directoryExists(replaysDir) or createSubDirectory(replaysDir) then
        replayFilePath = self:getLocalCachedReplay(replayId, REPORT_TYPE.SILVES_ARENA)
    end

    if not isFightEndWatch and fileExists(replayFilePath) and replayFilePath ~= lastReplay then
        local replayInfo = nil
        if isGetReplayInfo then
            local content = readFromBinaryFile(replayFilePath)
            local info = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayList", content)
            if info.replayList then
                replayInfo = info.replayList[1]
            end
        end
        success(replayFilePath)
        return
    end

    remote.silvesArena:silvesArenaWatchFightReportRequest(replayId, isFightEndWatch, index, function (data)
        if data.silvesArenaInfoResponse and data.silvesArenaInfoResponse.battleReport and data.silvesArenaInfoResponse.battleReport[1] 
            and data.silvesArenaInfoResponse.battleReport[1].fighterReportData and data.silvesArenaInfoResponse.battleReport[1].fighterReportData ~= "" then
            local fightReportData = data.silvesArenaInfoResponse.battleReport[1].fighterReportData
            if not isFightEndWatch then
                local content = crypto.decodeBase64(fightReportData)
                writeToBinaryFile(replayFilePath, content)
                success(replayFilePath)
            else
                -- 取统计数据
                local statsDataList = data.silvesArenaInfoResponse.battleReport[1].statsDataList
                success(fightReportData, statsDataList, data.silvesArenaInfoResponse.fightEndAddScore)
            end
        else
            app.tip:floatTip("战斗数据异常，请稍后查看战报～")
        end
    end, function()
        if fail then
            fail()
        end
    end)
end

-- 单队战报基本信息存数据库
function QReplayUtil:generateReplayInfo(myInfo, rivalInfo, result, teamKey)
    local heroInfoes = {}
    local userAlternateInfos = {}
    local sub1Fighter1 = {}
    local sub2Fighter1 = {}
    local sub3Fighter1 = {}
    local team1HeroSkillIndex = 1
    local team1HeroSkillIndex2 = 1
    local team1HeroSkillIndex3 = 1
    local team1HeroSoulSpirits = {}
    local team1GodarmList = {}
    if teamKey then
        local teamHero = remote.teamManager:getActorIdsByKey(teamKey, remote.teamManager.TEAM_INDEX_MAIN)
        for _, heroId in ipairs(teamHero) do
            local heroInfo = remote.herosUtil:getHeroByID(heroId)
            table.insert(heroInfoes, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        local teamHero = remote.teamManager:getAlternateIdsByKey(teamKey, remote.teamManager.TEAM_INDEX_MAIN)
        for _, heroId in ipairs(teamHero) do
            local heroInfo = remote.herosUtil:getHeroByID(heroId)
            table.insert(userAlternateInfos, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        local teamHero1 = remote.teamManager:getActorIdsByKey(teamKey, remote.teamManager.TEAM_INDEX_HELP)
        for _, heroId in ipairs(teamHero1) do
            local heroInfo = remote.herosUtil:getHeroByID(heroId)
            table.insert(sub1Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        local teamHero2 = remote.teamManager:getActorIdsByKey(teamKey, remote.teamManager.TEAM_INDEX_HELP2)
        for _, heroId in ipairs(teamHero2) do
            local heroInfo = remote.herosUtil:getHeroByID(heroId)
            table.insert(sub2Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        local teamHero3 = remote.teamManager:getActorIdsByKey(teamKey, remote.teamManager.TEAM_INDEX_HELP3)
        for _, heroId in ipairs(teamHero3) do
            local heroInfo = remote.herosUtil:getHeroByID(heroId)
            table.insert(sub3Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        local teamSoulSpirits = remote.teamManager:getSpiritIdsByKey(teamKey, remote.teamManager.TEAM_INDEX_MAIN)
        for _, soulSpiritId in ipairs(teamSoulSpirits) do
            local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
            table.insert(team1HeroSoulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo))
        end

        local godArmTeam1 = remote.teamManager:getGodArmIdsByKey(teamKey, 5)
        for _, heroId in ipairs(godArmTeam1) do
            local godArmInfo = remote.godarm:getGodarmById(heroId)
            table.insert(team1GodarmList,QMyAppUtils:getGodarmInfo(godArmInfo))
        end      

        local skillSupports = remote.teamManager:getSkillByKey(teamKey, remote.teamManager.TEAM_INDEX_HELP)
        team1HeroSkillIndex = table.indexof(teamHero1, skillSupports[1]) or 1
        local skillSupports2 = remote.teamManager:getSkillByKey(teamKey, remote.teamManager.TEAM_INDEX_HELP2)
        team1HeroSkillIndex2 = table.indexof(teamHero2, skillSupports2[1]) or 1
        local skillSupports3 = remote.teamManager:getSkillByKey(teamKey, remote.teamManager.TEAM_INDEX_HELP3)
        team1HeroSkillIndex3 = table.indexof(teamHero3, skillSupports3[1]) or 1
    else
        for _, heroInfo in ipairs(myInfo.heros or {}) do
            table.insert(heroInfoes, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        for _, heroInfo in ipairs(myInfo.alternateHeros or {}) do
            table.insert(userAlternateInfos, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        for _, heroInfo in ipairs(myInfo.subheros or {}) do
            table.insert(sub1Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        for _, heroInfo in ipairs(myInfo.sub2heros or {}) do
            table.insert(sub2Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        for _, heroInfo in ipairs(myInfo.sub3heros or {}) do
            table.insert(sub3Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
        end
        for _, soulSpiritInfo in ipairs(myInfo.soulSpirits or myInfo.soulSpirit or {}) do
            table.insert(team1HeroSoulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo))
        end

        for _, member in ipairs(myInfo.godArm1List or {}) do
            local info = clone(member)
            table.insert(team1GodarmList,QMyAppUtils:getGodarmInfo(info))
        end

        team1HeroSkillIndex = tableIndexof(myInfo.subheros, myInfo.activeSubActorId) or 1
        team1HeroSkillIndex2 = tableIndexof(myInfo.sub2heros, myInfo.activeSub2ActorId) or 1
        team1HeroSkillIndex3 = tableIndexof(myInfo.sub3heros, myInfo.activeSub3ActorId) or 1
    end

    local pvp_rivals = {}
    local enemyAlternateInfos = {}
    local sub1Fighter2 = {}
    local sub2Fighter2 = {}
    local sub3Fighter2 = {}
    local team1EnemySkillIndex = 1
    local team1EnemySkillIndex2 = 1
    local team1EnemySkillIndex3 = 1
    local team1EnemySoulSpirits = {}
    local team1EnemyGodarmList = {}
    if rivalInfo then
        for _, enemyInfo in ipairs(rivalInfo.heros or {}) do
            table.insert(pvp_rivals, QMyAppUtils:getBaseHeroInfo(enemyInfo))
        end
        for _, enemyInfo in ipairs(rivalInfo.alternateHeros or {}) do
            table.insert(enemyAlternateInfos, QMyAppUtils:getBaseHeroInfo(enemyInfo))
        end
        for _, enemyInfo in ipairs(rivalInfo.subheros or {}) do
            table.insert(sub1Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
        end
        for _, enemyInfo in ipairs(rivalInfo.sub2heros or {}) do
            table.insert(sub2Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
        end
        for _, enemyInfo in ipairs(rivalInfo.sub3heros or {}) do
            table.insert(sub3Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
        end
        for _, enemyInfo in ipairs(rivalInfo.soulSpirit or {}) do
            table.insert(team1EnemySoulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(enemyInfo))
        end

        for _, member in ipairs(rivalInfo.godArm1List or {}) do
            local info = clone(member)
            table.insert(team1EnemyGodarmList,QMyAppUtils:getGodarmInfo(info))
        end

        team1EnemySkillIndex = tableIndexof(rivalInfo.subheros, rivalInfo.activeSubActorId) or 1
        team1EnemySkillIndex2 = tableIndexof(rivalInfo.sub2heros, rivalInfo.activeSub2ActorId) or 1
        team1EnemySkillIndex3 = tableIndexof(rivalInfo.sub3heros, rivalInfo.activeSub3ActorId) or 1
    end

    local replayInfo = {}
    replayInfo.team1Name = myInfo.name or remote.user.nickname
    replayInfo.team1Icon = myInfo.avatar or remote.user.avatar
    replayInfo.team1Level = myInfo.level or remote.user.level
    replayInfo.team2Name = rivalInfo.name
    replayInfo.team2Icon = rivalInfo.avatar
    replayInfo.team2Level = rivalInfo.level
    replayInfo.fighter1 = heroInfoes
    replayInfo.fighter2 = pvp_rivals
    replayInfo.userAlternateInfos = userAlternateInfos
    replayInfo.enemyAlternateInfos = enemyAlternateInfos
    replayInfo.sub1Fighter1 = sub1Fighter1
    replayInfo.sub1Fighter2 = sub1Fighter2
    replayInfo.sub2Fighter1 = sub2Fighter1
    replayInfo.sub2Fighter2 = sub2Fighter2
    replayInfo.sub3Fighter1 = sub3Fighter1
    replayInfo.sub3Fighter2 = sub3Fighter2
    replayInfo.team1HeroSkillIndex = team1HeroSkillIndex
    replayInfo.team1HeroSkillIndex2 = team1HeroSkillIndex2
    replayInfo.team1HeroSkillIndex3 = team1HeroSkillIndex3
    replayInfo.team1EnemySkillIndex = team1EnemySkillIndex
    replayInfo.team1EnemySkillIndex2 = team1EnemySkillIndex2
    replayInfo.team1EnemySkillIndex3 = team1EnemySkillIndex3
    replayInfo.team1HeroSoulSpirits = team1HeroSoulSpirits
    replayInfo.team1EnemySoulSpirits = team1EnemySoulSpirits
    replayInfo.team1GodarmList = team1GodarmList
    replayInfo.team1EnemyGodarmList = team1EnemyGodarmList
    replayInfo.result = result
    replayInfo.version = app:getBattleVersion()

    -- QPrintTable(replayInfo)
    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayInfo", replayInfo)
    return crypto.encodeBase64(buff)
end

-- 双队战报基本信息存数据库
function QReplayUtil:generateMultipleTeamReplayInfo(myInfo, rivalInfo, teamInfo, result, nodeEncodeMessage)
    local heroInfoes = {}
    local sub1Fighter1 = {}
    local team2HeroInfoes = {}
    local team2Sub1Fighter1 = {}
    local team1HeroSoulSpirits = {}
    local team2HeroSoulSpirits = {}
    local team1GodarmList = {}
    local team2GodarmList = {}

    for _, heroInfo in ipairs(teamInfo[1].hero.heroes or {}) do
        table.insert(heroInfoes, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(teamInfo[1].hero.supports or {}) do
        table.insert(sub1Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, soulSpiritInfo in ipairs(teamInfo[1].hero.soulSpirits or {}) do
        table.insert(team1HeroSoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    for _,godarmInfo in pairs(teamInfo[1].hero.godArmIdList or {}) do
        table.insert(team1GodarmList,godarmInfo)
    end

    for _, heroInfo in ipairs(teamInfo[2].hero.heroes or {}) do
        table.insert(team2HeroInfoes, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(teamInfo[2].hero.supports or {}) do
        table.insert(team2Sub1Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, soulSpiritInfo in ipairs(teamInfo[2].hero.soulSpirits or {}) do
        table.insert(team2HeroSoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    for _,godarmInfo in pairs(teamInfo[2].hero.godArmIdList or {}) do
        table.insert(team2GodarmList,godarmInfo)
    end

    local team1HeroSkillIndex = teamInfo[1].hero.supportSkillHeroIndex
    local team1HeroSkillIndex2 = teamInfo[1].hero.supportSkillHeroIndex2
    local team2HeroSkillIndex = teamInfo[2].hero.supportSkillHeroIndex
    local team2HeroSkillIndex2 = teamInfo[2].hero.supportSkillHeroIndex2


    local pvp_rivals = {}
    local sub1Fighter2 = {}
    local team2Rivals = {}
    local team2Sub1Fighter2 = {}
    local team1EnemySoulSpirits = {}
    local team2EnemySoulSpirits = {}
    local team1EnemyGodarmList = {}
    local team2EnemyGodarmList = {}

    for _, enemyInfo in ipairs(teamInfo[1].enemy.heroes or {}) do
        table.insert(pvp_rivals, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    end
    for _, enemyInfo in ipairs(teamInfo[1].enemy.supports or {}) do
        table.insert(sub1Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    end
    for _, soulSpiritInfo in ipairs(teamInfo[1].enemy.soulSpirits or {}) do
        table.insert(team1EnemySoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    team1EnemyGodarmList = teamInfo[1].enemy.godArmIdList or {}

    for _, enemyInfo in ipairs(teamInfo[2].enemy.heroes or {}) do
        table.insert(team2Rivals, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    end
    for _, enemyInfo in ipairs(teamInfo[2].enemy.supports or {}) do
        table.insert(team2Sub1Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    end
    for _, soulSpiritInfo in ipairs(teamInfo[2].enemy.soulSpirits or {}) do
        table.insert(team2EnemySoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    team2EnemyGodarmList = teamInfo[2].enemy.godArmIdList or {}

    local team1EnemySkillIndex = teamInfo[1].enemy.supportSkillHeroIndex
    local team1EnemySkillIndex2 = teamInfo[1].enemy.supportSkillHeroIndex2
    local team2EnemySkillIndex = teamInfo[2].enemy.supportSkillHeroIndex
    local team2EnemySkillIndex2 = teamInfo[2].enemy.supportSkillHeroIndex2

    local replayInfo = {}
    replayInfo.team1Name = myInfo.name
    replayInfo.team1Icon = myInfo.avatar
    replayInfo.team1Level = myInfo.level
    replayInfo.team2Name = rivalInfo.name
    replayInfo.team2Icon = rivalInfo.avatar
    replayInfo.team2Level = rivalInfo.level
    replayInfo.fighter1 = heroInfoes
    replayInfo.sub1Fighter1 = sub1Fighter1
    replayInfo.team2HeroInfoes = team2HeroInfoes
    replayInfo.team2Sub1Fighter1 = team2Sub1Fighter1
    replayInfo.fighter2 = pvp_rivals
    replayInfo.sub1Fighter2 = sub1Fighter2
    replayInfo.team2Rivals = team2Rivals
    replayInfo.team2Sub1Fighter2 = team2Sub1Fighter2
    replayInfo.team1HeroSkillIndex = team1HeroSkillIndex
    replayInfo.team1HeroSkillIndex2 = team1HeroSkillIndex2
    replayInfo.team2HeroSkillIndex = team2HeroSkillIndex
    replayInfo.team2HeroSkillIndex2 = team2HeroSkillIndex2
    replayInfo.team1EnemySkillIndex = team1EnemySkillIndex
    replayInfo.team1EnemySkillIndex2 = team1EnemySkillIndex2
    replayInfo.team2EnemySkillIndex = team2EnemySkillIndex
    replayInfo.team2EnemySkillIndex2 = team2EnemySkillIndex2
    replayInfo.team1HeroSoulSpirits = team1HeroSoulSpirits
    replayInfo.team2HeroSoulSpirits = team2HeroSoulSpirits
    replayInfo.team1GodarmList = team1GodarmList
    replayInfo.team2GodarmList = team2GodarmList
    replayInfo.team1EnemySoulSpirits = team1EnemySoulSpirits
    replayInfo.team2EnemySoulSpirits = team2EnemySoulSpirits
    replayInfo.team1EnemyGodarmList = team1EnemyGodarmList
    replayInfo.team2EnemyGodarmList = team2EnemyGodarmList

    replayInfo.result = result
    replayInfo.version = app:getBattleVersion()

    -- QPrintTable(replayInfo)
    if nodeEncodeMessage == nil then nodeEncodeMessage = true end
    if nodeEncodeMessage == true then
        local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayInfo", replayInfo)
        return crypto.encodeBase64(buff)
    else
        return replayInfo
    end
end

-- 双队战报基本信息存数据库
function QReplayUtil:generatePVEMultipleTeamReplayInfo(myInfo, rivalInfo, teamInfo, result, nodeEncodeMessage)
    local heroInfoes = {}
    local sub1Fighter1 = {}
    local team2HeroInfoes = {}
    local team2Sub1Fighter1 = {}
    local team1HeroSoulSpirits = {}
    local team2HeroSoulSpirits = {}
    local team1GodarmList = {}
    local team2GodarmList = {}

    for _, heroInfo in ipairs(teamInfo[1].heroes or {}) do
        table.insert(heroInfoes, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(teamInfo[1].supports or {}) do
        table.insert(sub1Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, soulSpiritInfo in ipairs(teamInfo[1].soulSpirits or {}) do
        table.insert(team1HeroSoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    for _,godarmInfo in pairs(teamInfo[1].godArmIdList or {}) do
        table.insert(team1GodarmList,godarmInfo)
    end

    for _, heroInfo in ipairs(teamInfo[2].heroes or {}) do
        table.insert(team2HeroInfoes, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(teamInfo[2].supports or {}) do
        table.insert(team2Sub1Fighter1, QMyAppUtils:getBaseHeroInfo(heroInfo))
    end
    for _, soulSpiritInfo in ipairs(teamInfo[2].soulSpirits or {}) do
        table.insert(team2HeroSoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    end

    for _,godarmInfo in pairs(teamInfo[2].godArmIdList or {}) do
        table.insert(team2GodarmList,godarmInfo)
    end

    local team1HeroSkillIndex = teamInfo[1].supportSkillHeroIndex
    local team1HeroSkillIndex2 = teamInfo[1].supportSkillHeroIndex2
    local team2HeroSkillIndex = teamInfo[2].supportSkillHeroIndex
    local team2HeroSkillIndex2 = teamInfo[2].supportSkillHeroIndex2


    local pvp_rivals = {}
    local sub1Fighter2 = {}
    local team2Rivals = {}
    local team2Sub1Fighter2 = {}
    local team1EnemySoulSpirits = {}
    local team2EnemySoulSpirits = {}
    local team1EnemyGodarmList = {}
    local team2EnemyGodarmList = {}

    -- for _, enemyInfo in ipairs(teamInfo[1].enemy.heroes or {}) do
    --     table.insert(pvp_rivals, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    -- end
    -- for _, enemyInfo in ipairs(teamInfo[1].enemy.supports or {}) do
    --     table.insert(sub1Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    -- end
    -- for _, soulSpiritInfo in ipairs(teamInfo[1].enemy.soulSpirits or {}) do
    --     table.insert(team1EnemySoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    -- end

    -- team1EnemyGodarmList = teamInfo[1].enemy.godArmIdList or {}

    -- for _, enemyInfo in ipairs(teamInfo[2].enemy.heroes or {}) do
    --     table.insert(team2Rivals, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    -- end
    -- for _, enemyInfo in ipairs(teamInfo[2].enemy.supports or {}) do
    --     table.insert(team2Sub1Fighter2, QMyAppUtils:getBaseHeroInfo(enemyInfo))
    -- end
    -- for _, soulSpiritInfo in ipairs(teamInfo[2].enemy.soulSpirits or {}) do
    --     table.insert(team2EnemySoulSpirits, QMyAppUtils:getSoulSpiritInfo(soulSpiritInfo))
    -- end

    -- team2EnemyGodarmList = teamInfo[2].enemy.godArmIdList or {}

    -- local team1EnemySkillIndex = teamInfo[1].enemy.supportSkillHeroIndex
    -- local team1EnemySkillIndex2 = teamInfo[1].enemy.supportSkillHeroIndex2
    -- local team2EnemySkillIndex = teamInfo[2].enemy.supportSkillHeroIndex
    -- local team2EnemySkillIndex2 = teamInfo[2].enemy.supportSkillHeroIndex2

    local replayInfo = {}
    replayInfo.team1Name = myInfo.name
    replayInfo.team1Icon = myInfo.avatar
    replayInfo.team1Level = myInfo.level
    replayInfo.team2Name = rivalInfo.name
    replayInfo.team2Icon = rivalInfo.avatar
    replayInfo.team2Level = rivalInfo.level
    replayInfo.fighter1 = heroInfoes
    replayInfo.sub1Fighter1 = sub1Fighter1
    replayInfo.team2HeroInfoes = team2HeroInfoes
    replayInfo.team2Sub1Fighter1 = team2Sub1Fighter1
    replayInfo.fighter2 = pvp_rivals
    replayInfo.sub1Fighter2 = sub1Fighter2
    replayInfo.team2Rivals = team2Rivals
    replayInfo.team2Sub1Fighter2 = team2Sub1Fighter2
    replayInfo.team1HeroSkillIndex = team1HeroSkillIndex
    replayInfo.team1HeroSkillIndex2 = team1HeroSkillIndex2
    replayInfo.team2HeroSkillIndex = team2HeroSkillIndex
    replayInfo.team2HeroSkillIndex2 = team2HeroSkillIndex2
    replayInfo.team1EnemySkillIndex = team1EnemySkillIndex
    replayInfo.team1EnemySkillIndex2 = team1EnemySkillIndex2
    replayInfo.team2EnemySkillIndex = team2EnemySkillIndex
    replayInfo.team2EnemySkillIndex2 = team2EnemySkillIndex2
    replayInfo.team1HeroSoulSpirits = team1HeroSoulSpirits
    replayInfo.team2HeroSoulSpirits = team2HeroSoulSpirits
    replayInfo.team1GodarmList = team1GodarmList
    replayInfo.team2GodarmList = team2GodarmList
    replayInfo.team1EnemySoulSpirits = team1EnemySoulSpirits
    replayInfo.team2EnemySoulSpirits = team2EnemySoulSpirits
    replayInfo.team1EnemyGodarmList = team1EnemyGodarmList
    replayInfo.team2EnemyGodarmList = team2EnemyGodarmList

    replayInfo.result = result
    replayInfo.version = app:getBattleVersion()

    -- QPrintTable(replayInfo)
    if nodeEncodeMessage == nil then nodeEncodeMessage = true end
    if nodeEncodeMessage == true then
        local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayInfo", replayInfo)
        return crypto.encodeBase64(buff)
    else
        return replayInfo
    end
end

-- Download replay info from server
function QReplayUtil:getReplayInfo(replayId, success, fail, typeModel)
    local battleType = self:getBattleTypeNumByReportType(typeModel)
    app:getClient():globalFightGetFightersDataRequest(battleType, replayId, function (data)
            if data.gfGetFightersDataResponse.fightersData and data.gfGetFightersDataResponse.fightersData ~= "" then
                local content = crypto.decodeBase64(data.gfGetFightersDataResponse.fightersData)
                local replayInfo = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayInfo", content)
                success(replayInfo)
            else
                app.tip:floatTip("战报不存在！")
            end
        end, function()
            if fail then
                fail()
            end
        end)
end

function QReplayUtil:play(replay)
    app:loadBattleRecordFromProtobuf(replay)

    self:playRecord()
end

function QReplayUtil:playSilvesArena(fightReportData, statsDataList, fightEndAddScore, index, isFightEnd, callback, battleResultCallback, isFightEndWatch)
    if isFightEndWatch == nil then
        isFightEndWatch = true
    end
    if isFightEndWatch then
        local content = crypto.decodeBase64(fightReportData)
        app:parseBinaryBattleRecord(content)

        self:playSilvesArenaRecord(statsDataList, fightEndAddScore, index, isFightEnd, callback, battleResultCallback, isFightEndWatch)
    else
        app:loadBattleRecordFromProtobuf(fightReportData)

        self:playSilvesArenaRecord(nil, nil, nil, nil, nil, nil, false)
    end
end

function QReplayUtil:playRecord()
    local record = app:getBattleRecord()
    if not record then
        return
    end

    local config = record.dungeonConfig
    config.isReplay = true
    config.replayTimeSlices = record.recordTimeSlices
    config.replayRandomSeed = record.recordRandomSeed

    local loader = QDungeonResourceLoader.new(config)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
end

function QReplayUtil:playSilvesArenaRecord(statsDataList, fightEndAddScore, index, isFightEnd, callback, battleResultCallback, isFightEndWatch)
    local record = app:getBattleRecord()
    if not record then
        return
    end

    local config = record.dungeonConfig
    config.isReplay = true
    config.replayTimeSlices = record.recordTimeSlices
    config.replayRandomSeed = record.recordRandomSeed

    if isFightEndWatch then
        config.isQuick = true
        
        config.fightEndAddScore = fightEndAddScore
        config.statsDataList = statsDataList
        config.isFightEnd = isFightEnd
        config.isSilvesArena = true
        config.isSilvesArenaBattle = true
        config.index = index
        config.callback = callback
    else
        config.isSilvesArena = true
    end

    --[[Kumo]]
    -- print("[playSilvesArenaRecord] ", fightEndAddScore, index, isFightEnd)
    if battleResultCallback then
        battleResultCallback(config)
    else
        local loader = QDungeonResourceLoader.new(config)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_PAGE, uiClass = "QUIPageLoadResources", options = {dungeon = config, isKeepOldPage = true, loader = loader}})
    end
end

-- 创建战报数据存文件
function QReplayUtil:createReplayBuffer(teamName, dungeonConfig)
    local dungeon = QMyAppUtils:generateDungeonConfig(dungeonConfig)

    local skillSupports = remote.teamManager:getSkillByKey(teamName, remote.teamManager.TEAM_INDEX_SKILL)
    local supportSkillHeroIndex = table.indexof(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP), skillSupports[1]) or 1

    local skillSupports2 = remote.teamManager:getSkillByKey(teamName, remote.teamManager.TEAM_INDEX_SKILL2)
    local supportSkillHeroIndex2 = table.indexof(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP2), skillSupports2[1]) or 1
    
    local skillSupports3 = remote.teamManager:getSkillByKey(teamName, remote.teamManager.TEAM_INDEX_SKILL3)
    local supportSkillHeroIndex3 = table.indexof(remote.teamManager:getActorIdsByKey(teamName, remote.teamManager.TEAM_INDEX_HELP3), skillSupports3[1]) or 1

    local supportSkillEnemyIndex = 1
    local supportSkillRival = dungeonConfig.pvp_rivals3
    if supportSkillRival then
        for index, info in ipairs(dungeonConfig.pvp_rivals2) do
            if info.actorId == supportSkillRival.actorId then
                supportSkillEnemyIndex = index
            end
        end
    end

    local supportSkillEnemyIndex2 = 1
    local supportSkillRival2 = dungeonConfig.pvp_rivals5
    if supportSkillRival2 then
        for index, info in ipairs(dungeonConfig.pvp_rivals4) do
            if info.actorId == supportSkillRival2.actorId then
                supportSkillEnemyIndex2 = index
            end
        end
    end

    local supportSkillEnemyIndex3 = 1
    local supportSkillRival3 = dungeonConfig.pvp_rivals7
    if supportSkillRival3 then
        for index, info in ipairs(dungeonConfig.pvp_rivals6) do
            if info.actorId == supportSkillRival3.actorId then
                supportSkillEnemyIndex3 = index
            end
        end
    end

    dungeon.supportSkillHeroIndex = supportSkillHeroIndex
    dungeon.supportSkillHeroIndex2 = supportSkillHeroIndex2
    dungeon.supportSkillHeroIndex3 = supportSkillHeroIndex3
    dungeon.supportSkillEnemyIndex = supportSkillEnemyIndex
    dungeon.supportSkillEnemyIndex2 = supportSkillEnemyIndex2
    dungeon.supportSkillEnemyIndex3 = supportSkillEnemyIndex3

    dungeon.last_enable_fragment_id = 0 --[[remote.user.archaeologyInfo and remote.user.archaeologyInfo.last_enable_fragment_id]]
    local prop, id = remote.sunWar:getHeroBuffPropTable()
    dungeon.sunWarBuffID = id
    local targetOrder = remote.sunWar:getCurrentWaveTargetOrder() or {}
    dungeon.sunwarTargetOrder = targetOrder
    local targetOrder = remote.tower:getCurrentFloorTargetOrder() or {}
    dungeon.gloryTargetOrder = targetOrder

    local timeGearChange = {}
    dungeon.timeGearChange = timeGearChange

    local disableAIChange = {}
    dungeon.disableAIChange = disableAIChange

    local playerAction = {}
    dungeon.playerAction = playerAction

    local forceAutoChange = {}
    dungeon.forceAutoChange = forceAutoChange

    local recordTimeSlices = {}

    local record = {}
    local replayCord = {}
    replayCord.replayList = {}

    record.dungeonConfig = dungeon
    record.recordRandomSeed = q.OSTime()
    record.recordFrameCount = #recordTimeSlices
    record.recordTimeSlices = recordTimeSlices
    
    table.insert(replayCord.replayList, record)

    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayList", replayCord)
    return buff, record
end

-- 创建战报数据存文件
function QReplayUtil:createSilvesReplayBuffer(dungeonConfig)
    local dungeon = QMyAppUtils:generateDungeonConfig(dungeonConfig)

    dungeon.supportSkillHeroIndex = dungeonConfig.supportSkillHeroIndex
    dungeon.supportSkillHeroIndex2 = dungeonConfig.supportSkillHeroIndex2
    dungeon.supportSkillHeroIndex3 = dungeonConfig.supportSkillHeroIndex3
    dungeon.supportSkillEnemyIndex = dungeonConfig.supportSkillEnemyIndex
    dungeon.supportSkillEnemyIndex2 = dungeonConfig.supportSkillEnemyIndex2
    dungeon.supportSkillEnemyIndex3 = dungeonConfig.supportSkillEnemyIndex3

    local timeGearChange = {}
    dungeon.timeGearChange = timeGearChange

    local disableAIChange = {}
    dungeon.disableAIChange = disableAIChange

    local playerAction = {}
    dungeon.playerAction = playerAction

    local forceAutoChange = {}
    dungeon.forceAutoChange = forceAutoChange

    local recordTimeSlices = {}

    local record = {}
    local replayCord = {}
    replayCord.replayList = {}

    record.dungeonConfig = dungeon
    record.recordRandomSeed = q.OSTime()
    record.recordFrameCount = #recordTimeSlices
    record.recordTimeSlices = recordTimeSlices
    
    table.insert(replayCord.replayList, record)

    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayList", replayCord)
    return buff, record
end

-- 创建只有己方记录的pb buffer，用于直接给后端做某一方的开战信息
function QReplayUtil:createReplayFighterBuffer(teamName1, teamName2)
    local replayFighter = self:_createReplayFighterFromSelf(teamName1, teamName2)
    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayFighter", replayFighter)
    return buff
end

function QReplayUtil:_createReplayFighterFromSelf(teamName1, teamName2)
    local teamForce1 = remote.teamManager:getBattleForceForAllTeam(teamName1)
    local teamForce2 = 0
    if teamName2 then
        teamForce2 =  remote.teamManager:getBattleForceForAllTeam(teamName2)
    end
    local teamInfo1 = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = teamForce1, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}
    local teamInfo2 = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = teamForce2, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}

    --1队主力
    local heroTeam1 = remote.teamManager:getActorIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_MAIN)
    for _, heroId in ipairs(heroTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(teamInfo1.heroes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local helpTeam1 = remote.teamManager:getActorIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP)
    for _, heroId in ipairs(helpTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
       table.insert(teamInfo1.supports, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_MAIN)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        table.insert(teamInfo1.soulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo))
    end

    local godArmTeam1 = remote.teamManager:getGodArmIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_GODARM)
    for _, heroId in pairs(godArmTeam1) do
        local godArmInfo = remote.godarm:getGodarmById(heroId)
        local v =  QMyAppUtils:getGodarmInfo(godArmInfo)
        table.insert(teamInfo1.godArmIdList,  v)
    end

    --2队主力
    local heroTeam2 = remote.teamManager:getActorIdsByKey(teamName2, remote.teamManager.TEAM_INDEX_MAIN)
    for _, heroId in ipairs(heroTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(teamInfo2.heroes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local helpTeam2 = remote.teamManager:getActorIdsByKey(teamName2, remote.teamManager.TEAM_INDEX_HELP)
    for _, heroId in ipairs(helpTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(teamInfo2.supports, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName2, remote.teamManager.TEAM_INDEX_MAIN)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        table.insert(teamInfo2.soulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo))
    end

    local godArmTeam2 = remote.teamManager:getGodArmIdsByKey(teamName2, remote.teamManager.TEAM_INDEX_GODARM)
    for _, heroId in pairs(godArmTeam2) do
        local godArmInfo = remote.godarm:getGodarmById(heroId)
        local v =  QMyAppUtils:getGodarmInfo(godArmInfo)
        table.insert(teamInfo2.godArmIdList,  v)
    end
    
    --1队技能
    local teamSkills = remote.teamManager:getSkillByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP)
    local supports = teamInfo1.supports
    local supportSkillHeroIndex = tableIndexof(supports, teamSkills[1] or 0)
    local supportSkillHeroIndex2 = tableIndexof(supports, teamSkills[2] or 0)
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    teamInfo1.supportSkillHeroIndex = supportSkillHeroIndex
    teamInfo1.supportSkillHeroIndex2 = supportSkillHeroIndex2

    --2队技能
    local teamSkills = remote.teamManager:getSkillByKey(teamName2, remote.teamManager.TEAM_INDEX_HELP)
    local supports = teamInfo2.supports
    local supportSkillHeroIndex = tableIndexof(supports, teamSkills[1] or 0)
    local supportSkillHeroIndex2 = tableIndexof(supports, teamSkills[2] or 0)
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    teamInfo2.supportSkillHeroIndex = supportSkillHeroIndex
    teamInfo2.supportSkillHeroIndex2 = supportSkillHeroIndex2

    ----
    local teamInfos = {teamInfo1, teamInfo2}
    local replayFighter = {}
    replayFighter.teamName = remote.user.nickname
    replayFighter.teamInfo = teamInfos
    replayFighter.heroRecords = remote.user.collectedHeros or {}
    replayFighter.userConsortiaSkill = remote.union:hasUnion() and remote.user.userConsortiaSkill or {}
    replayFighter.userAvatar = remote.user.avatar
    replayFighter.userLastEnableFragmentId = remote.archaeology:getLastEnableFragmentID()
    replayFighter.userLevel = remote.user.level
    replayFighter.userTitle = remote.user.title
    replayFighter.userTitles = remote.headProp:getHeadList()
    replayFighter.userNightmareDungeonPassCount = (ENABLE_BADGE_IN_PVP and (remote.user.nightmareDungeonPassCount or 0) or -1)
    replayFighter.userHeroTeamGlyphs = remote.herosUtil:getGlyphTeamProp()
    replayFighter.mountRecords = remote.user.collectedZuoqis or {}
    replayFighter.userSoulTrial = remote.user.soulTrial
    replayFighter.soulSpiritCollectInfo = remote.soulSpirit:getMySoulSpiritHandBookInfoList() or {}
    replayFighter.userAttrList = self:getUserAttrList()
    replayFighter.allHeroGodArmIdList = remote.godarm:getHaveGodarmListForBattle() or {}
    replayFighter.userGodArmList = remote.godarm:getHaveGodarmLists() or {}
    replayFighter.extraProp = app.extraProp:getSelfExtraProp()


    return replayFighter
end

-- 创建只有己方记录的pb buffer，用于直接给后端做某一方的开战信息
function QReplayUtil:createReplayFighterSingleTeamBuffer(teamName1)
    local replayFighter = self:_createReplayFighterSingleTeamFromSelf(teamName1)
    local buff = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayFighter", replayFighter)
    return buff
end

function QReplayUtil:_createReplayFighterSingleTeamFromSelf(teamName1)
     local heroes = {}
     local supports = {}
     local godArmIdList = {}
     local soulSpirits = {}
     local support2 = {}
     local support3 = {}
     local force =  remote.teamManager:getBattleForceForAllTeam(teamName1)
     local supportSkillHeroIndex
     local supportSkillHeroIndex2
     local supportSkillHeroIndex3

    --主力
    local heroTeam1 = remote.teamManager:getActorIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_MAIN)
    for _, heroId in ipairs(heroTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
        table.insert(heroes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    --替补
    local helpTeam1 = remote.teamManager:getActorIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP)
    for _, heroId in ipairs(helpTeam1) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
       table.insert(supports, QMyAppUtils:getHeroInfo(heroInfo))
    end
    --魂灵
    local soulSpiritIds = remote.teamManager:getSpiritIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_MAIN)
    for i, soulSpiritId in ipairs(soulSpiritIds) do
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(soulSpiritId)
        table.insert(soulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(soulSpiritInfo))
    end

    --神器
    local godArmTeam1 = remote.teamManager:getGodArmIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_GODARM)
    for _, heroId in pairs(godArmTeam1) do
        local godArmInfo = remote.godarm:getGodarmById(heroId)
        local v =  QMyAppUtils:getGodarmInfo(godArmInfo)
        table.insert(godArmIdList,  v)
    end
    --援助2
    local helpTeam2 = remote.teamManager:getActorIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP2)
    for _, heroId in ipairs(helpTeam2) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
       table.insert(support2, QMyAppUtils:getHeroInfo(heroInfo))
    end
    --援助3
    local helpTeam3 = remote.teamManager:getActorIdsByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP3)
    for _, heroId in ipairs(helpTeam3) do
        local heroInfo = remote.herosUtil:getHeroByID(heroId)
       table.insert(support3, QMyAppUtils:getHeroInfo(heroInfo))
    end
    local teamSkills1_2 = remote.teamManager:getSkillByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP2)
    local teamSkills1_3 = remote.teamManager:getSkillByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP3)
    supportSkillHeroIndex2 = tableIndexof(support2, teamSkills1_2[1] or 0)
    supportSkillHeroIndex3 = tableIndexof(support3, teamSkills1_3[1] or 0)
    --援助2技能
    if #support2 > 0 and not supportSkillHeroIndex2 then
        supportSkillHeroIndex2 = 1
    end
    --援助3技能
    if #support3 > 0 and not supportSkillHeroIndex3 then
        supportSkillHeroIndex3 = 1
    end
    local teamSkills = remote.teamManager:getSkillByKey(teamName1, remote.teamManager.TEAM_INDEX_HELP)
    --替补 技能1
    supportSkillHeroIndex = tableIndexof(supports, teamSkills[1] or 0)
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end

    local replayFighter = {}

    --单队数据赋值
    replayFighter.heroes = heroes
    replayFighter.supports = supports
    replayFighter.force = force
    replayFighter.supportSkillHeroIndex = supportSkillHeroIndex
    replayFighter.supportSkillHeroIndex2 = supportSkillHeroIndex2
    replayFighter.soulSpirits = soulSpirits
    replayFighter.godArmIdList = godArmIdList
    replayFighter.support2 = support2
    replayFighter.support3 = support3
    replayFighter.supportSkillHeroIndex3 = supportSkillHeroIndex3

    replayFighter.teamName = remote.user.nickname
    replayFighter.heroRecords = remote.user.collectedHeros or {}
    replayFighter.userConsortiaSkill = remote.union:hasUnion() and remote.user.userConsortiaSkill or {}
    replayFighter.userAvatar = remote.user.avatar
    replayFighter.userLastEnableFragmentId = remote.archaeology:getLastEnableFragmentID()
    replayFighter.userLevel = remote.user.level
    replayFighter.userTitle = remote.user.title
    replayFighter.userTitles = remote.headProp:getHeadList()
    replayFighter.userNightmareDungeonPassCount = (ENABLE_BADGE_IN_PVP and (remote.user.nightmareDungeonPassCount or 0) or -1)
    replayFighter.userHeroTeamGlyphs = remote.herosUtil:getGlyphTeamProp()
    replayFighter.mountRecords = remote.user.collectedZuoqis or {}
    replayFighter.userSoulTrial = remote.user.soulTrial
    replayFighter.soulSpiritCollectInfo = remote.soulSpirit:getMySoulSpiritHandBookInfoList() or {}
    replayFighter.userAttrList = self:getUserAttrList()
    replayFighter.allHeroGodArmIdList = remote.godarm:getHaveGodarmListForBattle() or {}
    replayFighter.userGodArmList = remote.godarm:getHaveGodarmLists() or {}
    replayFighter.extraProp = app.extraProp:getSelfExtraProp()     

    return replayFighter
end


-- fighterInfo 转 replayFighter
function QReplayUtil:_createReplayFighterFromFighterInfo(fighter, index)
    local replayFighter = self:_createReplayFighterFromFighter(fighter)

    local buffer = app:getProtocol():encodeMessageToBuffer("cc.qidea.wow.client.battle.ReplayFighter", replayFighter)
    writeToBinaryFile("fighter"..index, buffer)

    return  buffer
end

-- fighterInfo 转 replayFighter -- 只用于2小队
function QReplayUtil:_createReplayFighterFromFighter(fighter)
    local teamInfo1 = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}
    local teamInfo2 = {heroes = {}, supports = {}, godArmIdList = {}, soulSpirits = {}, force = 0, supportSkillHeroIndex = 0, supportSkillHeroIndex2 = 0}

    for _, heroInfo in ipairs(fighter.heros or {}) do
        table.insert(teamInfo1.heroes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    remote.teamManager:sortTeam(teamInfo1.heroes)
    for _, heroInfo in ipairs(fighter.subheros or {}) do
       table.insert(teamInfo1.supports, QMyAppUtils:getHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(fighter.godArm1List or {}) do
        local v = QMyAppUtils:getGodarmInfo(heroInfo)
        table.insert(teamInfo1.godArmIdList,  v)
    end

    for _, heroInfo in ipairs(fighter.main1Heros or {}) do
        table.insert(teamInfo2.heroes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    remote.teamManager:sortTeam(teamInfo2.heroes)
    for _, heroInfo in ipairs(fighter.sub1heros or {}) do
        table.insert(teamInfo2.supports, QMyAppUtils:getHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(fighter.godArm2List or {}) do
        local v = QMyAppUtils:getGodarmInfo(heroInfo)
        table.insert(teamInfo2.godArmIdList,  v)
    end
    if fighter.soulSpirit then
        for k,v in pairs(fighter.soulSpirit or {}) do
            table.insert(teamInfo1.soulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(v))
        end
        -- table.insert(teamInfo1.soulSpirits, fighter.soulSpirit) --魂灵变成2个后遗弃
    end
    if fighter.soulSpirit2 then
        for k,v in pairs(fighter.soulSpirit2 or {}) do
            table.insert(teamInfo2.soulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(v))
        end        
        -- table.insert(teamInfo2.soulSpirits, fighter.soulSpirit2) --魂灵变成2个后遗弃
    end

    local supports = teamInfo1.supports
    local supportSkillHeroIndex = tableIndexof(supports, fighter.activeSubActorId or 0)
    local supportSkillHeroIndex2 = tableIndexof(supports, fighter.active1SubActorId or 0)
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    teamInfo1.supportSkillHeroIndex = supportSkillHeroIndex
    teamInfo1.supportSkillHeroIndex2 = supportSkillHeroIndex2

    local supports = teamInfo2.supports
    local supportSkillHeroIndex = tableIndexof(supports, fighter.activeSub2ActorId or 0)
    local supportSkillHeroIndex2 = tableIndexof(supports, fighter.active1Sub2ActorId or 0)
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end
    if not supportSkillHeroIndex2 and #supports >= 2 then
        supportSkillHeroIndex2 = 2
    end
    teamInfo2.supportSkillHeroIndex = supportSkillHeroIndex
    teamInfo2.supportSkillHeroIndex2 = supportSkillHeroIndex2
    
    local userConsortiaSkill = {}
    for i, v in pairs(fighter.dragonDesignInfo or {}) do
        local skill = {}
        skill.skillId = v.dragonDesignId
        skill.skillLevel = v.grade
        table.insert(userConsortiaSkill, skill)
    end
    local teamInfos = {teamInfo1, teamInfo2}

    local replayFighter = {}
    replayFighter.teamName = fighter.name
    replayFighter.teamInfo = teamInfos
    replayFighter.heroRecords = fighter.collectedHero or {}
    replayFighter.userConsortiaSkill = userConsortiaSkill
    replayFighter.userAvatar = fighter.avatar
    replayFighter.userLastEnableFragmentId = fighter.archaeology.last_enable_fragment_id or 0
    replayFighter.userLevel = fighter.level
    replayFighter.userTitle = fighter.title
    replayFighter.userTitles = fighter.userTitle
    replayFighter.userNightmareDungeonPassCount = fighter.nightmareDungeonPassCount or 0
    replayFighter.userHeroTeamGlyphs = fighter.heroTeamGlyphs
    replayFighter.mountRecords = fighter.collectedZuoqi or {}
    replayFighter.userSoulTrial = fighter.soulTrial
    replayFighter.soulSpiritCollectInfo = fighter.soulSpiritCollectInfo or {}
    replayFighter.extraProp = app.extraProp:getExtraPropByFighter(fighter)
    replayFighter.heroSkins = fighter.heroSkins or {}
    replayFighter.userGodArmList ={}
    replayFighter.allHeroGodArmIdList ={}

    replayFighter.userAttrList = self:getAttrListByFighterAttrList(fighter.attrList)

    if fighter.attrList and fighter.attrList.godArmList then
        replayFighter.userGodArmList = fighter.attrList.godArmList or {}
        for k,v in pairs(fighter.attrList.godArmList or {}) do
            table.insert(replayFighter.allHeroGodArmIdList, v.id .. ";"..v.grade)
        end
    end


    return replayFighter
end

-- 只用于单队
function QReplayUtil:_createReplayFighterSingleTeamFromFighter(fighter)
     local heroes = {}
     local supports = {}
     local godArmIdList = {}
     local soulSpirits = {}
     local support2 = {}
     local support3 = {}
     local force = 0
     local supportSkillHeroIndex
     local supportSkillHeroIndex2
     local supportSkillHeroIndex3

    for _, heroInfo in ipairs(fighter.heros or {}) do
        table.insert(heroes, QMyAppUtils:getHeroInfo(heroInfo))
    end
    remote.teamManager:sortTeam(heroes)
    for _, heroInfo in ipairs(fighter.subheros or {}) do
       table.insert(supports, QMyAppUtils:getHeroInfo(heroInfo))
    end
    for _, heroInfo in ipairs(fighter.godArm1List or {}) do
        local v = QMyAppUtils:getGodarmInfo(heroInfo)
        table.insert(godArmIdList,  v)
    end
    if fighter.soulSpirit then
        for k,v in pairs(fighter.soulSpirit or {}) do
            table.insert(soulSpirits, QMyAppUtils:getBaseSoulSpiritInfo(v))
        end
    end

    supportSkillHeroIndex = tableIndexof(supports, fighter.activeSubActorId or 0)
    if not supportSkillHeroIndex and #supports >= 1 then
        supportSkillHeroIndex = 1
    end

    for _, heroInfo in ipairs(fighter.sub2heros or {}) do
       table.insert(support2, QMyAppUtils:getHeroInfo(heroInfo))
    end

    for _, heroInfo in ipairs(fighter.sub3heros or {}) do
       table.insert(support3, QMyAppUtils:getHeroInfo(heroInfo))
    end    

    supportSkillHeroIndex2 = tableIndexof(support2, fighter.activeSub2ActorId or 0)
    supportSkillHeroIndex3 = tableIndexof(support3, fighter.activeSub3ActorId or 0)

    if #support2 > 0 and not support2SkillHeroIndex then
        supportSkillHeroIndex2 = 1
    end
    if #support3 > 0 and not support3SkillHeroIndex then
        support3SkillHeroIndex = 1
    end

    local replayFighter = {}
    replayFighter.teamName = fighter.name
    --单队数据赋值
    replayFighter.heroes = heroes
    replayFighter.supports = supports
    replayFighter.force = force
    replayFighter.supportSkillHeroIndex = supportSkillHeroIndex
    replayFighter.supportSkillHeroIndex2 = supportSkillHeroIndex2
    replayFighter.soulSpirits = soulSpirits
    replayFighter.godArmIdList = godArmIdList
    replayFighter.support2 = support2
    replayFighter.support3 = support3
    replayFighter.supportSkillHeroIndex3 = supportSkillHeroIndex3

    local userConsortiaSkill = {}
    for i, v in pairs(fighter.dragonDesignInfo or {}) do
        local skill = {}
        skill.skillId = v.dragonDesignId
        skill.skillLevel = v.grade
        table.insert(userConsortiaSkill, skill)
    end

    replayFighter.heroRecords = fighter.collectedHero or {}
    replayFighter.userConsortiaSkill = userConsortiaSkill
    replayFighter.userAvatar = fighter.avatar
    replayFighter.userLastEnableFragmentId = fighter.archaeology.last_enable_fragment_id or 0
    replayFighter.userLevel = fighter.level
    replayFighter.userTitle = fighter.title
    replayFighter.userTitles = fighter.userTitle
    replayFighter.userNightmareDungeonPassCount = fighter.nightmareDungeonPassCount or 0
    replayFighter.userHeroTeamGlyphs = fighter.heroTeamGlyphs
    replayFighter.mountRecords = fighter.collectedZuoqi or {}
    replayFighter.userSoulTrial = fighter.soulTrial
    replayFighter.soulSpiritCollectInfo = fighter.soulSpiritCollectInfo or {}
    replayFighter.extraProp = app.extraProp:getExtraPropByFighter(fighter)
    replayFighter.heroSkins = fighter.heroSkins or {}
    replayFighter.userGodArmList ={}
    replayFighter.allHeroGodArmIdList ={}

    replayFighter.userAttrList = self:getAttrListByFighterAttrList(fighter.attrList)

    if fighter.attrList and fighter.attrList.godArmList then
        replayFighter.userGodArmList = fighter.attrList.godArmList or {}
        for k,v in pairs(fighter.attrList.godArmList or {}) do
            table.insert(replayFighter.allHeroGodArmIdList, v.id .. ";"..v.grade)
        end
    end

    
    return replayFighter

end



function QReplayUtil:getFighterAdditionalInfos(fighterInfo)
    if fighterInfo == nil then return {} end

    local userConsortiaSkill = {}
    for i, v in pairs(fighterInfo.dragonDesignInfo or {}) do
        local skill = {}
        skill.skillId = v.dragonDesignId
        skill.skillLevel = v.grade
        table.insert(userConsortiaSkill, skill)
    end

    local attrList = fighterInfo.attrList or {}
    local godArmList = {}
    if attrList.godArmList then
        godArmList = attrList.godArmList
    end
    local attrListProp = {}
    if attrList then
        local soulGuidProp = db:calculateSoulGuideLevelProp(attrList.soulGuideLevel or 0)
        QActorProp:getPropByConfig(soulGuidProp, attrListProp)

        for i, mountInfo in pairs(attrList.reformInfo or {}) do
            local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
            local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, mountInfo.reformLevel) or {}
            QActorProp:getPropByConfig(refromProp, attrListProp)
        end
    end

    local archaeology = fighterInfo.archaeology or {}
    local additionalInfos = {
        superSkillInfos = db:calculateSuperSkillIDArray(fighterInfo.collectedHero or {}),
        combinationProps = db:calculateCombinationPropByIDArray(fighterInfo.collectedHero or {}),
        unionSkillProp = db:calculateUnionSkillProp(userConsortiaSkill),
        avatarProp = db:calculateAvatarProp(fighterInfo.avatar, fighterInfo.title, fighterInfo.userTitle),
        archaeologyProp = db:calculateArchaeologyProp(archaeology.last_enable_fragment_id or 0),
        teamGlyphInfo = fighterInfo.heroTeamGlyphs or {},
        badgeProp = db:getBadgeByCount(fighterInfo.nightmareDungeonPassCount or 0),
        mountCombinationProp = db:calculateMountCombinationProp(fighterInfo.collectedZuoqi or {}),
        soulSpiritCombinationProp = db:calculateSoulSpiritCombinationProp(fighterInfo.soulSpiritCollectInfo or {}),
        soulTrialProp = db:calculateSoulTrialProp(fighterInfo.soulTrial),
        godarmReformProp = db:getGodArmPropByList(godArmList),
        attrListProp = attrListProp,
    }

    return additionalInfos
end

function QReplayUtil:getSelfAdditionalInfos()
    local userLastEnableFragmentId = remote.archaeology:getLastEnableFragmentID()
    local userNightmareDungeonPassCount = ENABLE_BADGE_IN_PVP and (remote.user.nightmareDungeonPassCount or 0) or -1
    
    local attrListProp = {}
    local attrList = self:getUserAttrList()
    if attrList then
        local soulGuidProp = db:calculateSoulGuideLevelProp(attrList.soulGuideLevel or 0)
        QActorProp:getPropByConfig(soulGuidProp, attrListProp)

        for i, mountInfo in pairs(attrList.reformInfo or {}) do
            local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
            local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, mountInfo.reformLevel) or {}
            QActorProp:getPropByConfig(refromProp, attrListProp)
        end
    end
    local additionalInfos = {
        superSkillInfos = db:calculateSuperSkillIDArray(remote.user.collectedHeros or {}),
        combinationProps = db:calculateCombinationPropByIDArray(remote.user.collectedHeros or {}),
        unionSkillProp = db:calculateUnionSkillProp(remote.union:hasUnion() and remote.user.userConsortiaSkill or {}),
        avatarProp = db:calculateAvatarProp(remote.user.avatar, remote.user.title, remote.headProp:getHeadList()),
        archaeologyProp = db:calculateArchaeologyProp(userLastEnableFragmentId),
        teamGlyphInfo = remote.herosUtil:getGlyphTeamProp() or {},
        badgeProp = db:getBadgeByCount(userNightmareDungeonPassCount or 0),
        mountCombinationProp = db:calculateMountCombinationProp(remote.user.collectedZuoqis or {}),
        soulSpiritCombinationProp = db:calculateSoulSpiritCombinationProp(remote.soulSpirit:getMySoulSpiritHandBookInfoList() or {}),
        godarmReformProp = remote.herosUtil:getGodarmReformProp() or {},
        soulTrialProp = db:calculateSoulTrialProp(remote.user.soulTrial),
        attrListProp = attrListProp,
    }

    return additionalInfos
end

function QReplayUtil:getAdditionalInfoByDungeon(dungeonConfig, isAttack)
    if dungeonConfig == nil then return {} end

    local collectedHero = dungeonConfig.pvpRivalHeroRecords or {}
    local consortiaSkill = dungeonConfig.enemyConsortiaSkill or {}
    local avatar = dungeonConfig.enemyAvatar
    local title = dungeonConfig.enemyTitle
    local titles = dungeonConfig.enemyTitles
    local lastEnableFragmentId = dungeonConfig.enemyLastEnableFragmentId
    local teamGlyphInfo = dungeonConfig.enemyHeroTeamGlyphs or {}
    local collectedZuoqi = dungeonConfig.pvpRivalMountRecords or {}
    local soulSpiritCollectInfo = dungeonConfig.enemySoulSpiritCollectInfo or {}
    local soulTrial = dungeonConfig.enemySoulTrial
    local attrList = dungeonConfig.enemyAttrList or {}
    local godArmList = dungeonConfig.enemyGodArmList or {}

    if isAttack then
        collectedHero = dungeonConfig.heroRecords or {}
        consortiaSkill = dungeonConfig.userConsortiaSkill or {}
        avatar = dungeonConfig.userAvatar
        title = dungeonConfig.userTitle
        titles = dungeonConfig.userTitles
        lastEnableFragmentId = dungeonConfig.userLastEnableFragmentId
        teamGlyphInfo = dungeonConfig.userHeroTeamGlyphs or {}
        collectedZuoqi = dungeonConfig.mountRecords or {}
        soulSpiritCollectInfo = dungeonConfig.userSoulSpiritCollectInfo or {}
        soulTrial = dungeonConfig.userSoulTrial
        attrList = dungeonConfig.userAttrList or {}
        godArmList = dungeonConfig.userGodArmList or {}
    end

    local attrListProp = {}
    if attrList then
        local soulGuidProp = db:calculateSoulGuideLevelProp(attrList.soulGuideLevel or 0)
        QActorProp:getPropByConfig(soulGuidProp, attrListProp)

        for i, mountInfo in pairs(attrList.reformInfo or {}) do
            local mountConfig = db:getCharacterByID(mountInfo.zuoqiId)
            local refromProp = db:getReformConfigByAptitudeAndLevel(mountConfig.aptitude, mountInfo.reformLevel) or {}
            QActorProp:getPropByConfig(refromProp, attrListProp)
        end
    end

    local additionalInfos = {
        superSkillInfos = db:calculateSuperSkillIDArray(collectedHero),
        combinationProps = db:calculateCombinationPropByIDArray(collectedHero),
        unionSkillProp = db:calculateUnionSkillProp(consortiaSkill),
        avatarProp = db:calculateAvatarProp(avatar, title, titles),
        archaeologyProp = db:calculateArchaeologyProp(lastEnableFragmentId or 0),
        teamGlyphInfo = teamGlyphInfo,
        badgeProp = db:getBadgeByCount(0),
        mountCombinationProp = db:calculateMountCombinationProp(collectedZuoqi),
        soulSpiritCombinationProp = db:calculateSoulSpiritCombinationProp(soulSpiritCollectInfo),
        soulTrialProp = db:calculateSoulTrialProp(soulTrial),
        godarmReformProp = db:getGodArmPropByList(godArmList),
        attrListProp = attrListProp,
    }

    return additionalInfos
end

-- 从战报里拿出英雄信息
function QReplayUtil:getFighterFromReplayInfo(replayInfo, isHero)
    local fighter = {}
    local dungeonConfig = replayInfo.dungeonConfig
    if isHero then
        fighter.name = dungeonConfig.team1Name
        fighter.level = dungeonConfig.userLevel
        fighter.avatar = dungeonConfig.userAvatar
        fighter.vip = dungeonConfig.userVip
        fighter.force = dungeonConfig.userForce
        fighter.consortiaName = dungeonConfig.userConsortiaName

        if dungeonConfig.heroInfos then
            fighter.heros = dungeonConfig.heroInfos
        end
        if dungeonConfig.userSoulSpirits then
            fighter.soulSpirit = dungeonConfig.userSoulSpirits
        end
        if dungeonConfig.userAlternateInfos then
            fighter.alternateHeros = dungeonConfig.userAlternateInfos
        end
        if dungeonConfig.supportHeroInfos then
            fighter.subheros = dungeonConfig.supportHeroInfos
        end
        if dungeonConfig.supportHeroInfos2 then
            fighter.sub2heros = dungeonConfig.supportHeroInfos2
        end
        if dungeonConfig.supportHeroInfos3 then
            fighter.sub3heros = dungeonConfig.supportHeroInfos3
        end

        if dungeonConfig.pvpMultipleTeams then
            local pvpMultipleTeams1 = dungeonConfig.pvpMultipleTeams[1] or {}
            local pvpMultipleTeams2 = dungeonConfig.pvpMultipleTeams[2] or {}
            if pvpMultipleTeams1.hero.heroes then
                fighter.heros = pvpMultipleTeams1.hero.heroes
            end
            if pvpMultipleTeams1.hero.supports then
                fighter.subheros = pvpMultipleTeams1.hero.supports
            end
            if pvpMultipleTeams1.hero.soulSpirits then
                fighter.soulSpirit = pvpMultipleTeams1.hero.soulSpirits
            end
            if pvpMultipleTeams2.hero.heroes then
                fighter.main1Heros = pvpMultipleTeams2.hero.heroes
            end
            if pvpMultipleTeams2.hero.supports then
                fighter.sub1heros = pvpMultipleTeams2.hero.supports
            end
            if pvpMultipleTeams2.hero.soulSpirits then
                fighter.soulSpirit2 = pvpMultipleTeams2.hero.soulSpirits
            end
        end
    else
        fighter.name = dungeonConfig.team2Name
        fighter.level = dungeonConfig.enemyLevel
        fighter.avatar = dungeonConfig.enemyAvatar
        fighter.vip = dungeonConfig.enemyVip
        fighter.force = dungeonConfig.enemyForce
        fighter.consortiaName = dungeonConfig.enemyConsortiaName

        if dungeonConfig.pvp_rivals then
            fighter.heros = dungeonConfig.pvp_rivals
        end
        if dungeonConfig.pvp_rivals2 then
            fighter.subheros = dungeonConfig.pvp_rivals2
        end
        if dungeonConfig.pvp_rivals4 then
            fighter.sub2heros = dungeonConfig.pvp_rivals4
        end
        if dungeonConfig.pvp_rivals6 then
            fighter.sub3heros = dungeonConfig.pvp_rivals6
        end
        if dungeonConfig.enemySoulSpirits then
            fighter.soulSpirit = dungeonConfig.enemySoulSpirits
        end
        if dungeonConfig.enemyAlternateInfos then
            fighter.alternateHeros = dungeonConfig.enemyAlternateInfos
        end
        if dungeonConfig.pvpMultipleTeams then
            local pvpMultipleTeams1 = dungeonConfig.pvpMultipleTeams[1] or {}
            local pvpMultipleTeams2 = dungeonConfig.pvpMultipleTeams[2] or {}
            if pvpMultipleTeams1.enemy.heroes then
                fighter.heros = pvpMultipleTeams1.enemy.heroes
            end
            if pvpMultipleTeams1.enemy.supports then
                fighter.subheros = pvpMultipleTeams1.enemy.supports
            end
            if pvpMultipleTeams1.enemy.soulSpirits then
                fighter.soulSpirit = pvpMultipleTeams1.enemy.soulSpirits
            end
            if pvpMultipleTeams2.enemy.heroes then
                fighter.main1Heros = pvpMultipleTeams2.enemy.heroes
            end
            if pvpMultipleTeams2.enemy.supports then
                fighter.sub1heros = pvpMultipleTeams2.enemy.supports
            end
            if pvpMultipleTeams2.enemy.soulSpirits then
                fighter.soulSpirit2 = pvpMultipleTeams2.enemy.soulSpirits
            end
        end
    end

    return fighter
end

return QReplayUtil
