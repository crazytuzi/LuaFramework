
-- 大师赛数据处理类

local QBaseModel = import("...models.QBaseModel")
local QMockBattle = class("QMockBattle", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QActorProp = import("...models.QActorProp")
local QSoulSpiritProp = import("...models.QSoulSpiritProp")
local QUnitData = import("...models.QUnitData")


QMockBattle.MOCKBATTLE_PHASE_UPDATE = "MOCKBATTLE_PHASE_UPDATE"
QMockBattle.EVENT_MOCK_BATTLE_MY_INFO = "EVENT_MOCK_BATTLE_MY_INFO"
QMockBattle.EVENT_MOCK_BATTLE_SEASON_INFO = "EVENT_MOCK_BATTLE_SEASON_INFO"


QMockBattle.CARD_TYPE_HERO = 1
QMockBattle.CARD_TYPE_MOUNT = 2
QMockBattle.CARD_TYPE_SOUL = 3
QMockBattle.CARD_TYPE_GODARM = 4


QMockBattle.PHASE_SIGNUP = 1
QMockBattle.PHASE_PICK = 2
QMockBattle.PHASE_MATCH = 3
QMockBattle.PHASE_END = 4
QMockBattle.PHASE_SEASON_END = 5
QMockBattle.PHASE_UNOPEN = 6


QMockBattle.SEASON_TYPE_SINGLE = 1  
QMockBattle.SEASON_TYPE_DOUBLE = 2




function QMockBattle:createFakeData()

    self._heroInfoList ={28.,27,24,23,15,16,17,18}
    self._mountInfoList ={1011,1012,1016,1014,1015,1008,1001,1002}
    self._soulSpiritInfoList ={2002,2001}
    self._godArmInfoList ={3002,3003,3004,3005}
 
end

function QMockBattle:ctor()
    QMockBattle.super.ctor(self)

end

function QMockBattle:init()
    self._mockBattleCardInfo = {}
    self:resetData()
    self._dispatchList = {}
    self._cardsNumTable = {}
    self._cardsNumTable[QMockBattle.SEASON_TYPE_SINGLE] = {}
    self._cardsNumTable[QMockBattle.SEASON_TYPE_DOUBLE] = {}
end

function QMockBattle:resetData()

    self._heroInfoList = {} -- 玩家选择的魂师信息
    self._soulSpiritInfoList = {} -- 玩家选择的魂灵信息
    self._mountInfoList = {} -- 玩家选择的暗器信息
    self._godArmInfoList = {} -- 玩家选择的神器信息


    self._isOpen = false
    self._mockBattleSeasonInfo =  {}
    self._mockBattleUserInfo =  {}
    self._mockBattleRoundInfo =  {}
    self._mockBattleUserCenterBattle =  {}
    self._mockBattleFightEndReward = ""
    self._mockBattleTotalWinReward = "str_"
    self._mockBattleWinReward = "str_"
    self._mockBattleGlobalFightReport = {}
    self._mockBattleheroDatas = {}
    
    self._mockBattleOldWinCount = 0


    self._isRoundEnd = false
    self._isMockBattle = false
    self._isMockBattleWin = 0 -- 1:win 2:lose
    self._seasonType = QMockBattle.SEASON_TYPE_SINGLE
    self._cardsNumTable = {}
    print("QMockBattle:resetData() ==========")
    self._cardsNumTable[QMockBattle.SEASON_TYPE_SINGLE] = {}
    self._cardsNumTable[QMockBattle.SEASON_TYPE_DOUBLE] = {}
    self._old_WinNum = 0

end



function QMockBattle:loginEnd(success)
    if success then
        success()
    end

    if self:checkMockBattleIsUnLock() then
        self:mockBattleGetMainInfoRequest()
    end
end

function QMockBattle:disappear()
    QMockBattle.super.disappear(self)
    self:_removeEvent()
end

function QMockBattle:_addEvent()
    self:_removeEvent()
end

function QMockBattle:_removeEvent()
end


function QMockBattle:checkMockBattleIsUnLock(isTips)

    if self:getMockBattleSeasonTypeIsSingle() then
        if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", isTips)  then
            return false
        end
    else
        if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE2", false)  then
            if isTips then
                local configs = app.unlock:getConfigByKey("UNLOCK_MOCK_BATTLE2")
                if configs.team_level ~= nil then
                  local str = "本周为双队赛季，%s级开启，单队赛季下周开启"
                  app.tip:floatTip(string.format(str, configs.team_level))
                end
            end
            return false
        end

    end

    return true
end

function QMockBattle:checkMockBattleIsUnLockByType(isTips ,season_type)

    if QMockBattle.SEASON_TYPE_SINGLE == season_type then
       if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE", isTips)  then
            return false
        end
    else
        if not app.unlock:checkLock("UNLOCK_MOCK_BATTLE2", isTips)  then
            return false
        end
    end
    return true
end


-- 红点
function QMockBattle:checkRedTips()

    if not self:checkMockBattleIsUnLock() then
        return false
    end
    if not self:checkIsInSeason() then
        return false
    end     
    
    if self:checkScoreRewardRedTips() then
        return true
    end

    if self:checkShopRedTips() then
        return true
    end
    
    if self:getCurTicketNum() > 0 and self:checkIsInSeason(true)  and not self:checkAllScoreRewardGetten()  then
        return true
    end

    return false
end

function QMockBattle:checkScoreRewardRedTips()
    local dailyScore = remote.mockbattle:getMockBattleUserInfo().totalScore or 0   
    local configs = db:getStaticByName("mock_battle_reward")
    for _,value in pairs(configs) do
        if self:checkIntegralRewardInfoIsGet(value.id) == false and value.condition <= dailyScore  and value.type == 2 and value.season_type == self._seasonType then
            --print("value.id  ===="..value.id .." value.condition ======".. value.condition.."dailyScore ===="..dailyScore)
            return true
        end
    end
    return false

end

function QMockBattle:checkAllScoreRewardGetten()
    local configs = db:getStaticByName("mock_battle_reward")
    for _,value in pairs(configs) do
        if value.type == 2  and self:checkIntegralRewardInfoIsGet(value.id) == false and value.season_type == self._seasonType then
            return false
        end
    end
    return true
end


function QMockBattle:checkShopRedTips()
    if remote.stores:checkFuncShopRedTips(SHOP_ID.mockbattleShop) then
        return true
    end
    return false
end

--打开界面
function QMockBattle:openDialog(callback)
end

function QMockBattle:openMockBattleDialog(callback)

    if not self:checkMockBattleIsUnLock(true) then
        return false
    end    
	--app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMockBattle"})
    
    self:mockBattleGetMainInfoRequest(function()
        if next(self._mockBattleSeasonInfo) == nil then
            return 
        end
        if not self:checkMockBattleIsUnLock(true) then -- 两次判断 屏蔽当前周为双队周触发单队引导
            return 
        end    

        if callback then
            callback()
        end
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMockBattle"})
    end)
    
end

--------------------LOCAL-----------------------------
function QMockBattle:initMockBattleCardInfo()

    self._mockBattleCardInfo = {}
    local mockBattleCard = db:getMockBattleCardConfig()
    for _,v in pairs(mockBattleCard) do
        local _id = v.id 
        local target_id = v.character_id 
        local target_type = v.type 

        if self._cardsNumTable[QMockBattle.SEASON_TYPE_SINGLE][target_type] == nil
            and tonumber(self._cardsNumTable[QMockBattle.SEASON_TYPE_SINGLE][target_type]) == nil then
            self._cardsNumTable[QMockBattle.SEASON_TYPE_SINGLE][target_type] = v.random_max_count
        end
        if self._cardsNumTable[QMockBattle.SEASON_TYPE_DOUBLE][target_type] == nil 
            and tonumber(self._cardsNumTable[QMockBattle.SEASON_TYPE_DOUBLE][target_type]) == nil  then
            self._cardsNumTable[QMockBattle.SEASON_TYPE_DOUBLE][target_type] = v.random_max_count_2
        end
        if target_type == QMockBattle.CARD_TYPE_HERO  then
            local heroInfo = {}
            local character = db:getCharacterByID(target_id)
            if character.talent ~= nil then
                heroInfo = QUnitData.new({utype = QUnitData.TYPE_HERO , data = v})
                heroInfo.id = _id
                heroInfo.cType = target_type
                table.insert(self._mockBattleCardInfo,heroInfo)
            end
        elseif target_type == QMockBattle.CARD_TYPE_MOUNT  then
            local mountInfo = {}
            mountInfo = QUnitData.new({utype = QUnitData.TYPE_MOUNT , data = v})
            mountInfo.id = _id
            mountInfo.cType = target_type
            table.insert(self._mockBattleCardInfo,mountInfo)
        elseif target_type == QMockBattle.CARD_TYPE_SOUL  then
            local soulSpiritInfo = {}
            soulSpiritInfo = QUnitData.new({utype = QUnitData.TYPE_SOUL , data = v})
            soulSpiritInfo.id = _id
            soulSpiritInfo.cType = target_type
            table.insert(self._mockBattleCardInfo,soulSpiritInfo)
        elseif target_type == QMockBattle.CARD_TYPE_GODARM  then
            local godarmInfo = {}
            godarmInfo = QUnitData.new({utype = QUnitData.TYPE_GODARM , data = v})
            godarmInfo.id = _id
            godarmInfo.cType = target_type
            table.insert(self._mockBattleCardInfo,godarmInfo)    
        end
    end
end


function QMockBattle:getCardMaxBySeasonAndType(season_type, card_type)
    if q.isEmpty(self._cardsNumTable[1]) or q.isEmpty(self._cardsNumTable[2])  then
        self:initMockBattleCardInfo()
    end
    return self._cardsNumTable[season_type][card_type] 
end

function QMockBattle:getTotalCardMaxNumBySeasonType(season_type)
    if q.isEmpty(self._cardsNumTable) then
        self:initMockBattleCardInfo()
    end
    local max_num = 0
    for i=1,4 do
        max_num = max_num + self:getCardMaxBySeasonAndType(season_type,i)
    end
    return max_num
end



function QMockBattle:getCardInfoByIndex(index)
    if next(self._mockBattleCardInfo)  == nil then
        self:initMockBattleCardInfo()
    end

    for _,v in pairs( self._mockBattleCardInfo) do
        if tonumber(v.id) == tonumber(index) then
            return v
        end
    end
    print("getCardInfoByIndex = nil  index = "..index)

    return nil
end

function QMockBattle:getCardInfoById(actorId)
    if next(self._mockBattleCardInfo)  == nil then
        self:initMockBattleCardInfo()
    end

    for _,v in pairs( self._mockBattleCardInfo) do
        if tonumber(v.actorId) == tonumber(actorId) then
            return v
        end
    end
    print("getCardInfoById = nil  actorId = "..actorId)
    return nil
end

function QMockBattle:getCardUiInfoById(actorId)
    return self:getCardInfoById(actorId).uiModel or nil
end



--hero_jewelry_breakthrough  备注 饰品突破后饰品id会改变
--hero_equip_enhance
--hero_jewelry_enhance
--hero_equip_enchant
--hero_jewelry_enchant
function QMockBattle:initEquipment(heroId,cardInfo)
    local characterInfo = db:getCharacterByID(heroId)
    local breakConfig = db:getBreakthroughByTalentLevel(characterInfo.talent,cardInfo.hero_breakthrough) --突破配置表
    local equipments = {}
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.weapon,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.clothes,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.bracelet,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_equip_enhance or 0,itemId=breakConfig.shoes,enhance_exp = 0,enchants=cardInfo.hero_equip_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_jewelry_enhance or 0,itemId=breakConfig.jewelry1,enhance_exp = 0,enchants=cardInfo.hero_jewelry_enchant or 0})
    table.insert(equipments,{level=cardInfo.hero_jewelry_enhance or 0,itemId=breakConfig.jewelry2,enhance_exp = 0 ,enchants=cardInfo.hero_jewelry_enchant or 0})

    return equipments
end

--hero_skill_level
function QMockBattle:initSkill(heroId,cardInfo)
    local breakHeroConfig = db:getBreakthroughHeroByActorId(heroId) --突破数值表
    local skills = {}
    local index = 1
    if breakHeroConfig ~= nil then
        for _,value in pairs(breakHeroConfig) do
            if tonumber(value.breakthrough_level) <= tonumber(cardInfo.hero_breakthrough) then
                for i=1,3 do
                    local slotId = value["skill_id_"..i]
                    if slotId ~= nil then
                        local slotInfo = db:getSkillByActorAndSlot(heroId,slotId)
                        if slotInfo then
                            skills[index] = {}
                            skills[index].slotId = slotId
                            skills[index].slotLevel = cardInfo.hero_skill_level
                            --skills[index].info = {slotLevel = cardInfo.hero_skill_level}
                            local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(heroId, slotId)
                            --skills[index].skillId = skillId
                            index = index + 1
                        end
                    end                
                end

                local slotId = value.skill_id_4
                if slotId ~= nil then
                    local slotInfo = db:getSkillByActorAndSlot(heroId,slotId)
                    if slotInfo then
                        skills[index] = {}
                        skills[index].slotId = slotId
                        skills[index].slotLevel = cardInfo.hero_skill_level
                        --skills[index].info = {slotLevel = cardInfo.hero_skill_level}
                        local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(heroId, slotId)
                        --skills[index].skillId = skillId
                        index = index + 1
                    end
                end
            end
        end
    end

    return skills
end

--stone_id_1
--stone_enhance_1
--stone_breakthrough_1
function QMockBattle:initGemstone(heroId,cardInfo)
    local gemstones = {}
    local gemstonesList = string.split(cardInfo.stone_id_1, ";")
    local index_ = 1
    for _,id in pairs(gemstonesList) do
        table.insert(gemstones,{itemId= id or 0,level=cardInfo.stone_enhance_1 or 0, craftLevel = cardInfo.stone_breakthrough_1 or 0 ,sid = index_})
        index_ = index_ + 1
    end
    return gemstones
end

--liushi_id
--spar_star_1
--spar_enhance_1
function QMockBattle:initSpar(heroId,cardInfo)
    local spars = {}
    local sparsList = string.split(cardInfo.liushi_id, ";")

    for _,id in pairs(sparsList) do
        table.insert(spars,{itemId= id or 0,level= cardInfo.spar_enhance_1 or 0, grade = cardInfo.spar_star_1 or 0})
    end
    return spars
end

--artifact_level
--artifact_star
function QMockBattle:initArtifact(heroId,cardInfo)
    local artifactProp = {}
    local character= db:getCharacterByID(heroId)
    if character.artifact_id ~= nil then
        local skillConfig = db:getArtifactSkillConfigById(character.artifact_id) or {}
        local skills = {}
        for _, config in ipairs(skillConfig) do
            if config.skill_order <= cardInfo.artifact_star then
                skills[config.skill_order] = { skillId = config.skill_id , skillLevel = config.skill_level }
            end
        end
        artifactProp ={ artifactLevel = cardInfo.artifact_level , artifactBreakthrough = cardInfo.artifact_star , artifactSkillList = skills  }
    end
    --QPrintTable(artifactProp)
    return artifactProp
end

--magic_herb_id
--magic_herb_star
--magic_herb_level
function QMockBattle:initMagicHerb(heroId,cardInfo)
    local magicHerbs = {}
    local magicHerbsList = string.split(cardInfo.magic_herb_id, ";")
    for _,id in pairs(magicHerbsList) do
        table.insert(magicHerbs,{itemId= id or 0,level= cardInfo.magic_herb_level or 0, grade = cardInfo.magic_herb_star or 0})
    end
    return magicHerbs
end

function QMockBattle:initMount(id,cardInfo)
    local mountInfo = {}
    mountInfo = {zuoqiId = id,enhanceLevel = cardInfo.enhance ,grade = cardInfo.star}
    local character = db:getCharacterByID(id)
    --给ss暗器添加附属暗器
    if character and character.aptitude == APTITUDE.SS then
        local wearZuoqiInfo ={ zuoqiId = id , grade = cardInfo.wear_anqi_star , superZuoqiId = id}
        mountInfo.wearZuoqiInfo = wearZuoqiInfo
    end
    return mountInfo
end

function QMockBattle:initSoulSpirit(id,cardInfo)
    local soulSpiritInfo = {}
    soulSpiritInfo= {zuoqiId = id,enhanceLevel = cardInfo.enhance ,grade = cardInfo.star}
    return soulSpiritInfo
end




-------------------------------------------------
function QMockBattle:getMyHeroInfoList()
    --QPrintTable(self._heroInfoList)
    return self._heroInfoList or {}
end

function QMockBattle:getMySoulSpiritInfoList()
    --QPrintTable(self._soulSpiritInfoList)
    return self._soulSpiritInfoList or {}
end

function QMockBattle:getMyMountInfoList()
    --QPrintTable(self._mountInfoList)
    return self._mountInfoList or {}
end

function QMockBattle:getHaveGodarmList()
    --QPrintTable(self._godArmInfoList)
    return self._godArmInfoList or {}
end


function QMockBattle:getUnlockTeamByIndex(team_index)
    if team_index == remote.teamManager.TEAM_INDEX_MAIN then
        return true
    elseif team_index == remote.teamManager.TEAM_INDEX_HELP then
        return true
    elseif team_index == remote.teamManager.TEAM_INDEX_HELP2 then
        return false
    elseif team_index == remote.teamManager.TEAM_INDEX_HELP3 then
        return true
    elseif team_index == remote.teamManager.TEAM_INDEX_MAIN then
        return true
    end
    return false
end


function QMockBattle:checkHeroHaveAssistHero(actorId)
    local assistHeroInfo = QStaticDatabase:sharedDatabase():getAssistSkill(actorId)
    if assistHeroInfo == nil then return false, false end
    
    local teams = self:getMyHeroInfoList() or {}

    local assistHero = true
    local haveAssistHero = false

    local index = 1
    while assistHeroInfo["Deputy_hero"..index] do
        if assistHeroInfo["show_hero"..index] == 1 then return true, false end
        local isHave = false
        for i = 1, #teams, 1 do
            local card_data = self:getCardInfoByIndex(teams[i])
            if card_data.actorId == assistHeroInfo["Deputy_hero"..index] then
                isHave = true
                break
            end
        end
        if isHave == false then
            haveAssistHero = false
            break
        else
            haveAssistHero = isHave
        end
        index = index + 1
    end
    return assistHero, haveAssistHero
end


function QMockBattle:checkHeroHasChoosen(actorId)
    for _, value in ipairs(self._mockBattleRoundInfo.chooseInfo or {} ) do
       local card_data = self:getCardInfoByIndex(value)
        if card_data.actorId == actorId then
            return true
        end
    end
    return false
end

function QMockBattle:getCurPhase(isOpen)
	if self:checkIsInSeason(true) then

		if self._mockBattleRoundInfo then
            if self._isRoundEnd then
                return QMockBattle.PHASE_END
            end
			if self._mockBattleRoundInfo.roundId == nil or self._mockBattleRoundInfo.isEnd then
				return QMockBattle.PHASE_SIGNUP
			end
			if self._mockBattleRoundInfo.nowGridInfo and next(self._mockBattleRoundInfo.nowGridInfo) ~= nil then
				return QMockBattle.PHASE_PICK
			else
				return QMockBattle.PHASE_MATCH
			end
		end
    elseif self:checkIsInSeason(false) then
        return QMockBattle.PHASE_SEASON_END
	end
	return QMockBattle.PHASE_SEASON_END
end

function QMockBattle:getCurTicketNum()

    local num = db:getConfigurationValue("MOCK_BATTLE_CHALLENGE_TICKET_DEFAULT_NUM")
    local buynum = self._mockBattleUserInfo.buyCount or 0
    local fightnum = self._mockBattleUserInfo.fightCount or 0

    num = num + buynum  - fightnum
    return num
end


function QMockBattle:getCurSeasonEndCountDown( )
    local currTime = q.serverTime()
    local endTime = remote.mockbattle:getMockBattleSeasonInfo().endAt or 0
    endTime = endTime / 1000
    -- temp
    --endTime = endTime - 7 * DAY 
    endTime = endTime - currTime

    return endTime
end


function QMockBattle:getNextSeasonStartCountDown( )
    local currTime = q.serverTime()
    local endTime = remote.mockbattle:getMockBattleSeasonInfo().endAt or 0
    endTime = endTime / 1000
    endTime = endTime - currTime
    return endTime
end

function QMockBattle:checkIsInSeason(_canFight)--可战斗为赛季结束7天前

	if not self._isOpen then return false end

	if self._mockBattleSeasonInfo then
	    local curTime = q.serverTime()
	    local startAt = self._mockBattleSeasonInfo.startAt or 0
	    local endAt = self._mockBattleSeasonInfo.endAt  or 0
	    startAt = startAt /1000
	    endAt = endAt /1000 
    -- temp
        -- if _canFight  then
        --     -- endAt = endAt - 7 * DAY
        -- end

	    if startAt and endAt  then
	        if curTime <= endAt and curTime >= startAt then
	            return true 
	        end
	    end
	end
    return false 
end


function QMockBattle:checkIsMatchRound()
    if self._mockBattleRoundInfo and self._mockBattleRoundInfo.roundDetail  then
        return self._mockBattleRoundInfo.roundDetail.matchingMirrorId ~=nil and string.len(self._mockBattleRoundInfo.roundDetail.matchingMirrorId) ~= 0
    end
    return false 
end

function QMockBattle:checkIntegralRewardInfoIsGet( id )
    -- body

    if self._mockBattleUserInfo == nil then 
        return false
    end
    local score_awards = self._mockBattleUserInfo.getIntegralReward or {}
 
    for k, v in pairs(score_awards) do
        if id == v then
            return true
        end
    end
    return false
end




-- //这里的id都是量表对应的id，不是对应的英雄id
-- message BattleFormationMockBattle {
--     repeated int32 mainHeroIds = 1; //主将集合
--     repeated int32 sub1HeroIds = 2; //副将1集合
--     optional int32 activeSub1HeroId = 3; //激活援助技能的副将1集合中的英雄
--     repeated int32 sub2HeroIds = 4; //副将2集合
--     optional int32 activeSub2HeroId = 5; //激活援助技能的副将2集合中的英雄
--     repeated int32 sub3HeroIds = 6; //副将3集合
--     optional int32 activeSub3HeroId = 7; //激活援助技能的副将3集合中的英雄
--     optional int32 soulSpiritId = 8; // 上阵魂灵
--     repeated BattleFormationMockBattleWearInfo wearInfo = 9; //
-- }

-- //佩戴信息
-- message BattleFormationMockBattleWearInfo {
--     optional int32 actor_id = 1; //英雄id
--     optional int32 zuoqi_id = 2; //暗器id
-- }

function QMockBattle:encodeBattleFormation(team)
    QPrintTable(team)
    local battleFormation = {}
    battleFormation.mainHeroIds = {}
    battleFormation.sub1HeroIds = {}
    battleFormation.sub2HeroIds = {}
    battleFormation.sub3HeroIds = {}
    battleFormation.activeSub1HeroId = 0
    battleFormation.activeSub2HeroId = 0
    battleFormation.activeSub3HeroId = 0
    battleFormation.soulSpiritId = 0
    battleFormation.wearInfo = {}
    battleFormation.godArmIdList = {}


    if team[1] ~= nil then
        battleFormation.mainHeroIds = team[1].actorIds or {}
        battleFormation.soulSpiritId = (team[1].spiritIds or {})[1] or 0
    end
    if team[2] ~= nil then
        battleFormation.sub1HeroIds = team[2].actorIds or {}
        if team[2].skill ~= nil then
            battleFormation.activeSub1HeroId = team[2].skill[1] or 0
            battleFormation.activeSub2HeroId = team[2].skill[2] or 0
        end
    end
    if team[3] ~= nil then
        battleFormation.sub2HeroIds = team[3].actorIds or {}
        if team[3].skill ~= nil then
            battleFormation.activeSub2HeroId = team[3].skill[1] or 0
        end
    end
    if team[4] ~= nil then
        battleFormation.sub3HeroIds = team[4].actorIds or {}
        if team[4].skill ~= nil then
            battleFormation.activeSub3HeroId = team[4].skill[1] or 0
        end
    end

    for i,value in pairs(team[1].mountIds or {}) do
        if i <= #team[1].actorIds then
            local wearinfo = {actorId = team[1].actorIds[i],zuoqiId = value}
            table.insert(battleFormation.wearInfo,wearinfo)
        end
    end

    if team[5] ~= nil and team[5].godarmIds ~= nil then
        battleFormation.godArmIdList = team[5].godarmIds or {}
    end

    --QPrintTable(battleFormation)
    return battleFormation
end

--------------------------- server info ------------------------------
function QMockBattle:setMockBattleIsOpen(isOpen)
	self._isOpen = isOpen
end

function QMockBattle:setMockBattleisRoundEnd(isRoundEnd)
    self._isRoundEnd = isRoundEnd
end

function QMockBattle:getMockBattleOldWinValue()
    return self._old_WinNum
end

function QMockBattle:clearMockBattleisWinMark()
    self._isMockBattleWin = 0
end

function QMockBattle:saveCurWinCount()
    self._mockBattleOldWinCount  = remote.mockbattle:getMockBattleRoundInfo().winCount or 0
end




function QMockBattle:setMockBattleSeasonInfo(data_)
    if self._mockBattleSeasonInfo and data_ and self._mockBattleSeasonInfo.seasonNo ~=  data_.seasonNo then
        self:resetData()
    end
	self._mockBattleSeasonInfo = data_
    if self._mockBattleSeasonInfo and self._mockBattleSeasonInfo.seasonType  and self._mockBattleSeasonInfo.seasonType == "MOCK_BATTLE_TWO_TEAM"  then
        self._seasonType = QMockBattle.SEASON_TYPE_DOUBLE
    end
end

function QMockBattle:setMockBattleUserInfo(data_)
	self._mockBattleUserInfo = data_
end

function QMockBattle:getMockBattleMaxWinAndLoseNum()
    local  max_lose_num = 3
    local  max_win_num = 10
    if self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE then
        max_lose_num = 5
        max_win_num = 20
    end
    return max_win_num,max_lose_num
end


function QMockBattle:setMockBattleRoundInfo(data_)
    --QPrintTable(data_)
    local choosen_change = false
    local max_card_num = remote.mockbattle:getTotalCardMaxNumBySeasonType(self._seasonType)
    local  max_win_num ,max_lose_num = self:getMockBattleMaxWinAndLoseNum()

    if data_.chooseInfo ~= nil and next(data_.chooseInfo ) and #data_.chooseInfo == max_card_num then
        local local_data = self._mockBattleRoundInfo.chooseInfo or {}
        if #local_data ~= #data_.chooseInfo  then
            choosen_change = true
        end
    end
    if self._isMockBattle then
        if data_.loseCount   and data_.loseCount ~= self._mockBattleRoundInfo.loseCount then
            if data_.loseCount >= max_lose_num then
                self._isRoundEnd = true
            end
            self._isMockBattleWin = 2
        end
        if data_.winCount and data_.winCount ~= self._mockBattleRoundInfo.winCount then
            self._old_WinNum = self._mockBattleRoundInfo.winCount
            if data_.winCount >= max_win_num then
                self._isRoundEnd = true
            end
            self._isMockBattleWin = 1
        end
    end
	self._mockBattleRoundInfo = data_

    if self._isMockBattle then
        QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QMockBattle.MOCKBATTLE_PHASE_UPDATE})
        self._isMockBattle = false
    end


    if choosen_change then
        self._heroInfoList ={}
        self._mountInfoList ={}
        self._soulSpiritInfoList ={}
        self._godArmInfoList ={}
        for i,value in pairs(self._mockBattleRoundInfo.chooseInfo) do
            local card_data = self:getCardInfoByIndex(value)
            if card_data then
                if card_data.cType == QMockBattle.CARD_TYPE_HERO then
                    table.insert(self._heroInfoList,card_data.id)
                elseif card_data.cType == QMockBattle.CARD_TYPE_MOUNT then
                    table.insert(self._mountInfoList,card_data.id)
                elseif card_data.cType == QMockBattle.CARD_TYPE_SOUL then
                    table.insert(self._soulSpiritInfoList,card_data.id)
                elseif card_data.cType == QMockBattle.CARD_TYPE_GODARM then
                    table.insert(self._godArmInfoList,card_data.id)
                end
            end
        end
        -- QPrintTable(self._mockBattleRoundInfo.chooseInfo)
        -- QPrintTable(self._heroInfoList)
        -- QPrintTable(self._mountInfoList)
        -- QPrintTable(self._soulSpiritInfoList)
        -- QPrintTable(self._godArmInfoList)
    end
end



function QMockBattle:setMockBattleTotleRoundInfos(data_)
    self._mockBattleTotleRoundInfos = data_
end


function QMockBattle:setMockBattleUserCenterBattle(data_)
	self._mockBattleUserCenterBattle = data_
end

function QMockBattle:setMockBattleFightEndReward(str_)
	self._mockBattleFightEndReward = str_
end

function QMockBattle:setMockBattleTotalWinReward(str_)
	self._mockBattleTotalWinReward = str_
end

function QMockBattle:setMockBattleHeroData(data_)
    self._mockBattleheroDatas = data_
end

function QMockBattle:setMockBattleGlobalFightReport(data_)
    self._mockBattleGlobalFightReport = data_
end

function QMockBattle:setMockBattleWinReward(str_)
    self._mockBattleWinReward = str_
end

function QMockBattle:getMockBattleIsOpen()
	return self._isOpen or false
end

function QMockBattle:getMockBattleSeasonInfo()
	return self._mockBattleSeasonInfo or {}
end

function QMockBattle:getMockBattleUserInfo()
	return self._mockBattleUserInfo or {}
end

function QMockBattle:getMockBattleRoundInfo()
	return self._mockBattleRoundInfo or {}
end

function QMockBattle:getMockBattleUserCenterBattle()
	return self._mockBattleUserCenterBattle or {}
end

function QMockBattle:getMockBattleFightEndReward()
	return self._mockBattleFightEndReward or ""
end

function QMockBattle:getMockBattleTotalWinReward()
	return self._mockBattleTotalWinReward or ""
end

function QMockBattle:getMockBattleTotleRoundInfos()
    return self._mockBattleTotleRoundInfos or {}
end

function QMockBattle:getMockBattleGlobalFightReport()
    return self._mockBattleGlobalFightReport or {}
end

function QMockBattle:getMockBattleHeroData( ... )
    return self._mockBattleheroDatas or {}
end

function QMockBattle:getMockBattleWinReward()
    return self._mockBattleWinReward or ""
end

function QMockBattle:getMockBattleOldWinCount()
    return self._mockBattleOldWinCount or 0
end


function QMockBattle:getMockBattleSeasonType()
    return self._seasonType 
end

function QMockBattle:getMockBattleSeasonTypeIsSingle()
    return self._seasonType == QMockBattle.SEASON_TYPE_SINGLE
end

function QMockBattle:getMockBattleSeasonTypeIsDouble()
    return self._seasonType == QMockBattle.SEASON_TYPE_DOUBLE
end

function QMockBattle:getMockBattleBattleFormation(index)
    if self._mockBattleRoundInfo and self._mockBattleRoundInfo.roundDetail then
        if not index or index == 1 then
            return clone(self._mockBattleRoundInfo.roundDetail.battleInfo) or {}
        else
            return clone(self._mockBattleRoundInfo.roundDetail.battleInfo2) or {}
        end
    end
    return {}
end

function QMockBattle:getMockBattleReward()
   if self._mockBattleRoundInfo and self._mockBattleRoundInfo.reward then
        return clone(self._mockBattleRoundInfo.reward) or {}
    end
    return {}
end

function QMockBattle:getMockBattleWinMark()
    return self._isMockBattleWin or 0
end


function  QMockBattle:getChooseCardsNumByType(type)
    local chooseInfo = remote.mockbattle:getMockBattleRoundInfo().chooseInfo or  {}
    if q.isEmpty(chooseInfo) then
        return 0
    end
    local num = 0
    for i,v in ipairs(chooseInfo) do
        local data_ = remote.mockbattle:getCardInfoByIndex(v)
        if data_.cType == type then
            num = num + 1
        end
    end
    return num
end


function QMockBattle:_dispatchAll()
    local tbl = {}
    for _, name in pairs(self._dispatchList) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = true
        end
    end
    self._dispatchList = {}
end

----------------------------- 协议 -----------------------------
function QMockBattle:responseHandler(data, success, fail, succeeded)
	--进游戏拉取简单信息
	if data.mockBattleUserInfoResponse ~= nil then

        --赛季信息刷新
        if data.mockBattleUserInfoResponse.seasonInfo then
            self:setMockBattleSeasonInfo(data.mockBattleUserInfoResponse.seasonInfo)
            table.insert(self._dispatchList,QMockBattle.EVENT_MOCK_BATTLE_SEASON_INFO)
        end

        if data.mockBattleUserInfoResponse.isOpen then
            self:setMockBattleIsOpen(data.mockBattleUserInfoResponse.isOpen)
        end
       --个人信息刷新
        if data.mockBattleUserInfoResponse.myInfo then
            self:setMockBattleUserInfo(data.mockBattleUserInfoResponse.myInfo)
            table.insert(self._dispatchList,QMockBattle.EVENT_MOCK_BATTLE_MY_INFO)
        end
        --轮次信息刷新
        if data.api and data.api == "MOCK_BATTLE_GET_BATTLE_INFO_LIST" then
            if data.mockBattleUserInfoResponse.roundInfos and next(data.mockBattleUserInfoResponse.roundInfos) ~= nil then
                self:setMockBattleTotleRoundInfos(data.mockBattleUserInfoResponse.roundInfos)
            end
        else
            if data.mockBattleUserInfoResponse.roundInfos and next(data.mockBattleUserInfoResponse.roundInfos) ~= nil then
                self:setMockBattleRoundInfo(data.mockBattleUserInfoResponse.roundInfos[1])
            end
        end
        --战斗对手信息刷新
        if data.mockBattleUserInfoResponse.battleInfo then
            self:setMockBattleUserCenterBattle(data.mockBattleUserInfoResponse.battleInfo)
        end
        --战斗结束奖励
        if data.mockBattleUserInfoResponse.fightEndReward then
            self:setMockBattleFightEndReward(data.mockBattleUserInfoResponse.fightEndReward)
        end      
        --达到对应胜利的奖励
        if data.mockBattleUserInfoResponse.totalWinReward then
            self:setMockBattleTotalWinReward(data.mockBattleUserInfoResponse.totalWinReward)
        end   
        --英雄胜率集合
        if data.mockBattleUserInfoResponse.heroDatas then
            self:setMockBattleHeroData(data.mockBattleUserInfoResponse.heroDatas)
        end   
        --战报
        if data.mockBattleUserInfoResponse.reports then
            self:setMockBattleTotalWinReward(data.mockBattleUserInfoResponse.reports)
        end   
        --达到对应胜利的奖励
        if data.mockBattleUserInfoResponse.winReward then
            self:setMockBattleWinReward(data.mockBattleUserInfoResponse.winReward)
        end           
    end
    self:_dispatchAll()
	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end


--登录信息
function QMockBattle:mockBattleGetMyInfoRequest(success, fail)
    local request = {api = "MOCK_BATTLE_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--主界面信息
function QMockBattle:mockBattleGetMainInfoRequest(success, fail)
    local request = {api = "MOCK_BATTLE_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--报名
function QMockBattle:mockBattleSignUpRequest(success, fail)

    local request = {api = "MOCK_BATTLE_SIGN_UP"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        remote.user:addPropNumForKey("todayMockBattleTurnCount")--记录今日模拟赛开启轮次次数
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--选卡
function QMockBattle:mockBattleChooseCardRequest(cardId ,success, fail)
    local mockBattleChooseCardRequest = {cardId = cardId}
    local request = {api = "MOCK_BATTLE_CHOOSE_CARD",mockBattleChooseCardRequest = mockBattleChooseCardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--购买战斗次数
function QMockBattle:mockBattleBuyFightCountRequest(success, fail)
    local request = {api = "MOCK_BATTLE_BUY_FIGHT_COUNT"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--匹配
function QMockBattle:mockBattleMatchRequest(success, fail)
    local request = {api = "MOCK_BATTLE_MATCH"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--放弃本次战斗
function QMockBattle:mockBattleGiveUpequest(success, fail)
    local request = {api = "MOCK_BATTLE_GIVE_UP"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--领取当前轮次结束后的奖励
function QMockBattle:mockBattleGetRoundRewardRequest(success, fail)
    local request = {api = "MOCK_BATTLE_GET_ROUND_REWARD"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--积分奖励领取Request
function QMockBattle:mockBattleIntegralRewardRequest( ids, success, fail)
    local mockBattleIntegralRewardRequest = {boxIds = ids }
    local request = {api = "MOCK_BATTLE_GET_INTEGRAL_REWARD" , mockBattleIntegralRewardRequest = mockBattleIntegralRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--获取玩家对战信息集合
function QMockBattle:mockBattleGetBattleInfoListRequest(success, fail)
    local request = {api = "MOCK_BATTLE_GET_BATTLE_INFO_LIST"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--战斗开始
function QMockBattle:mockBattleFightStartRequest(battleinfo ,battleinfo2,success, fail)
    local mockBattleFightStartRequest = {battleInfo = battleinfo , battleInfo2 = battleinfo2}
    local gfStartRequest = {battleType = BattleTypeEnum.MOCK_BATTLE, mockBattleFightStartRequest = mockBattleFightStartRequest}
    self._isMockBattle = true
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}

    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--战斗结束
function QMockBattle:mockBattleFightEndRequest(battleKey,success, fail)

    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.MOCK_BATTLE , battleVerify = battleVerify , fightReportData = fightReportData}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        remote.user:addPropNumForKey("todayMockBattleFightCount")--记录今日模拟赛战斗次数
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--查看对手信息
function QMockBattle:mockBattleQueryFighterRequest(success, fail)
    local request = {api = "MOCK_BATTLE_QUERY_FIGHTER"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--获取最强英雄数据排行
function QMockBattle:mockBattleGetTopHeroRankListRequest(success, fail)
    local request = {api = "MOCK_BATTLE_GET_TOP_HERO_RANK"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--获取战报
function QMockBattle:mockBattleGetFightHistoryRequest(success, fail)
    local request = {api = "MOCK_BATTLE_FIGHT_HISTORY"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end
--[[

//这里的id都是量表对应的id，不是对应的英雄id
message BattleFormationMockBattle {
    repeated int32 mainHeroIds = 1; //主将集合
    repeated int32 sub1HeroIds = 2; //副将1集合
    optional int32 activeSub1HeroId = 3; //激活援助技能的副将1集合中的英雄
    repeated int32 sub2HeroIds = 4; //副将2集合
    optional int32 activeSub2HeroId = 5; //激活援助技能的副将2集合中的英雄
    repeated int32 sub3HeroIds = 6; //副将3集合
    optional int32 activeSub3HeroId = 7; //激活援助技能的副将3集合中的英雄
    optional int32 soulSpiritId = 8; // 上阵魂灵
    repeated BattleFormationMockBattleWearInfo wearInfo = 9; //
}

//佩戴信息
message BattleFormationMockBattleWearInfo {
    optional int32 actor_id = 1; //英雄id
    optional int32 zuoqi_id = 2; //暗器id
}

]]--

function QMockBattle:mockBattleChangeDefenseArmyRequest(battleInfo,battleInfo2, success, fail)
    local mockBattleChangeDefenseArmyRequest = {battleInfo = battleInfo,battleInfo2 = battleInfo2}
    local request = {api = "MOCK_BATTLE_CHANGE_DEFENSE_ARMY" , mockBattleChangeDefenseArmyRequest = mockBattleChangeDefenseArmyRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


return QMockBattle