-- Filename：	GuildBattle.lua
-- Author：		Li Pan
-- Date：		2014-2-18
-- Purpose：		军团战

module("GuildBattle", package.seeall)

require "script/ui/main/BulletinLayer"
require "script/ui/main/MainScene"
require "script/utils/BaseUI"

require "script/battle/BattleCardUtil"
require "script/battle/BattleLayer"




BattleForGuild          = 101
BattleForCity           = 102
local m_battleType        = BattleForGuild


IMG_PATH = "images/battle/"


local defaultBgm = "music01.mp3"

local speedUpLevel          = 5
local speedUp3Level         = 40
local m_BattleTimeScale     = 1
local m_isRepeat            = false

battleBaseLayer             = nil
local m_bg                  = nil
local battleUperLayer       = nil
local m_team1CardLayer      = nil
local m_team2CardLayer      = nil

local battleMoneyLabel      = nil
local battleSoulLabel       = nil
local battleResourceLabel   = nil
local battleRoundLabel      = nil

local blockTypeCrossingFire = 1
local blockTypeMove         = 2
local team1Info             = nil
local team2Info             = nil
local m_battleData          = nil
local battleBlocks          = nil
local cardsPosition         = nil
local battleBlockIndex      = 1
local currentBattleBlock    = nil
local maxWinningCount       = 999
local winningCountMap       = {}
local maxHpMap              = {}
local currentHpMap          = {}
local retraitArray          = {}
local m_afterBattleLayer    = nil
local m_isReport            = false
function getPlayMaxWinCount( uid )
    for k,v in pairs(m_battleData.server.team1.memberList) do
        if(tonumber(v.uid) == tonumber(uid)) then
            return v.maxWin
        end
    end
    for k,v in pairs(m_battleData.server.team2.memberList) do
        if(tonumber(v.uid) == tonumber(uid)) then
            return v.maxWin
        end
    end
    return nil
end

function getCardByTeamId(teamId)
    teamId = teamId .. ""
    --print("getCardByTeamId:",teamId)
    if(team1Info.members~=nil)then
        for key, value in pairs(team1Info.members) do
            if(teamId==key)then
                --print(key, value)
                local htid               = tonumber(value.htid)
                
                local replaceImage       = value.replaceImage
                
                local resultCard         = BattleCardUtil.getBattlePlayerCardImage(0,false,htid,false,replaceImage)
                
                local nameColor          = value.color
                
                local nameLabel          = CCLabelTTF:create(value.name .. "",g_sFontPangWa,25)
                --nameLabel:setColor(ccc3(0xff,0xf6,0x00))
                nameLabel:setColor(nameColor)
                nameLabel:setAnchorPoint(ccp(0.5,0.5))
                nameLabel:setPosition(resultCard:getContentSize().width/2,-resultCard:getContentSize().height*0.3)
                resultCard:addChild(nameLabel,91)
                
                local winningLabel       = CCLabelTTF:create(GetLocalizeStringBy("key_1950"),g_sFontPangWa,21)
                winningLabel:setColor(ccc3(0xff,0xff,0xff))
                winningLabel:setAnchorPoint(ccp(0.5,0.5))
                winningLabel:setPosition(resultCard:getContentSize().width*0.25,-resultCard:getContentSize().height*0.6)
                resultCard:addChild(winningLabel,92)
                
                local winningCount       = winningCountMap[teamId .. ""]
                winningCount             = winningCount==nil and 0 or winningCount
                
                local playeMaxWin        = value.maxWin or maxWinningCount
                
                local winningNumberLabel = CCLabelTTF:create(winningCount .. "/" .. playeMaxWin,g_sFontPangWa,25)
                winningNumberLabel:setColor(ccc3(0x00,0xff,0x18))
                winningNumberLabel:setAnchorPoint(ccp(0.5,0.5))
                winningNumberLabel:setPosition(resultCard:getContentSize().width*0.7,-resultCard:getContentSize().height*0.6)
                resultCard:addChild(winningNumberLabel,93,93)
                
                return resultCard
            end
        end
    end
    if(team2Info~=nil)then
        for key, value in pairs(team2Info.members) do
            
            if(teamId==key)then
                --print(key, value)
                local htid               = tonumber(value.htid)
                
                local replaceImage       = value.replaceImage
                
                local resultCard         = BattleCardUtil.getBattlePlayerCardImage(0,false,htid,false,replaceImage)
                
                local nameColor          = value.color
                
                local nameLabel          = CCLabelTTF:create(value.name .. "",g_sFontPangWa,25)
                --nameLabel:setColor(ccc3(0xff,0xf6,0x00))
                nameLabel:setColor(nameColor)
                nameLabel:setAnchorPoint(ccp(0.5,0.5))
                nameLabel:setPosition(resultCard:getContentSize().width/2,resultCard:getContentSize().height*1.3)
                resultCard:addChild(nameLabel,91)
                
                local winningLabel       = CCLabelTTF:create(GetLocalizeStringBy("key_1950"),g_sFontPangWa,21)
                winningLabel:setColor(ccc3(0xff,0xff,0xff))
                winningLabel:setAnchorPoint(ccp(0.5,0.5))
                winningLabel:setPosition(resultCard:getContentSize().width*0.25,resultCard:getContentSize().height*1.6)
                resultCard:addChild(winningLabel,92)
                
                local winningCount       = winningCountMap[teamId .. ""]
                winningCount             = winningCount==nil and 0 or winningCount
                
                local playeMaxWin        = value.maxWin or maxWinningCount
                
                local winningNumberLabel = CCLabelTTF:create(winningCount .. "/" .. playeMaxWin,g_sFontPangWa,25)
                winningNumberLabel:setColor(ccc3(0x00,0xff,0x18))
                winningNumberLabel:setAnchorPoint(ccp(0.5,0.5))
                winningNumberLabel:setPosition(resultCard:getContentSize().width*0.7,resultCard:getContentSize().height*1.6)
                resultCard:addChild(winningNumberLabel,93,93)
                
                return resultCard
            end
        end
    end
    return nil
end

function removeSelf(node)
    node:removeFromParentAndCleanup(true)
end

function getCardPosition(teamId)
    for key, value in pairs(cardsPosition) do
        if(tonumber(value) == tonumber(teamId))then
            return tonumber(key)
        end
    end
end

function initBackground(bgFile)
    
    
    if(bgFile==nil) then
        --print("bgFile==nil")
        bgFile = "zuduifuben_1.jpg"
    end
    local originalFormat = CCTexture2D:defaultAlphaPixelFormat()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    
    m_bg = CCSprite:create(IMG_PATH .. "bg/" .. bgFile)
    
    local size = CCDirector:sharedDirector():getWinSize()
    m_bg:setAnchorPoint(ccp(0.5,0.5))
    m_bg:setPosition(size.width/2,size.height/2)
    m_bg:setScale(size.width/m_bg:getContentSize().width)
    
    CCTexture2D:setDefaultAlphaPixelFormat(originalFormat)
end

function layerTouch()
    return true
end

function initTeamInfo()

    currentHpMap = {}
    maxHpMap = {}
    --init team1Info
    team1Info                 = {}
    team1Info.memberCount     = m_battleData.server.team1.memberCount
    team1Info.name            = m_battleData.server.team1.name
    team1Info.level           = m_battleData.server.team1.level
    team1Info.members         = {}
    team1Info.memberCount     = 0
    team1Info.leftMemberCount = 0
    --init team2info
    team2Info                 = {}
    team2Info.memberCount     = m_battleData.server.team2.memberCount
    team2Info.name            = m_battleData.server.team2.name
    team2Info.level           = m_battleData.server.team2.level
    team2Info.members         = {}
    team2Info.memberCount     = 0
    team2Info.leftMemberCount = 0
    
    --检查是否双方都有战斗成员，如若一方没有战斗成员则直接胜利
    local isSingleMemberBattle = true
    if(table.count(m_battleData.server.team1.memberList) == 0 or table.count(m_battleData.server.team2.memberList) == 0) then
        return false    
    end
    --team1Info 
    for i=1,#(m_battleData.server.team1.memberList) do
        
        local uid                        = m_battleData.server.team1.memberList[i].uid .. ""
        
        currentHpMap[uid]                = tonumber(m_battleData.server.team1.memberList[i].maxHp)
        maxHpMap[uid]                    = tonumber(m_battleData.server.team1.memberList[i].maxHp)
        
        team1Info.members[uid]           = {}
        team1Info.members[uid].maxHp     = tonumber(m_battleData.server.team1.memberList[i].maxHp)
        team1Info.members[uid].currentHp = tonumber(m_battleData.server.team1.memberList[i].maxHp)
        team1Info.members[uid].name      = m_battleData.server.team1.memberList[i].name
        team1Info.members[uid].maxWin    = m_battleData.server.team1.memberList[i].maxWin
        team1Info.memberCount            = team1Info.memberCount + 1
        team1Info.leftMemberCount        = team1Info.leftMemberCount + 1
        if(tonumber(uid)>20000)then
            team1Info.members[uid].htid  = tonumber(m_battleData.server.team1.memberList[i].htid)
            
            local curHeroData            = DB_Heroes.getDataById(team1Info.members[uid].htid)
            
            require "script/ui/hero/HeroPublicLua"
            team1Info.members[uid].color = HeroPublicLua.getCCColorByStarLevel(curHeroData.star_lv)
        else
            local armyId = tonumber(m_battleData.server.team1.memberList[i].name)
            require "db/DB_Army"
            local army = DB_Army.getDataById(armyId)
            require "db/DB_Team"
            local team = DB_Team.getDataById(army.monster_group)
            
            local monsterHtid = team.copyTeamShowId
            print("monsterHtid:",monsterHtid,army.monster_group,armyId)
            require "db/DB_Monsters_tmpl"
            local monsterTmpl = DB_Monsters_tmpl.getDataById(monsterHtid)
            
            team1Info.members[uid].htid = tonumber(monsterHtid)
            team1Info.members[uid].name = monsterTmpl.name
            
            require "script/ui/hero/HeroPublicLua"
            team1Info.members[uid].color = HeroPublicLua.getCCColorByStarLevel(monsterTmpl.star_lv)
        end
        --print("m_battleData.server.team1.memberList[i].dress:",m_battleData.server.team1.memberList[i].dress,#(m_battleData.server.team1.memberList[i].dress))
        if(m_battleData.server.team1.memberList[i].dress~=nil )then
            for key,value in pairs (m_battleData.server.team1.memberList[i].dress) do
                local dressId = tonumber(value)
                require "db/DB_Item_dress"
                local dress = DB_Item_dress.getDataById(dressId)
                print("dress changeModel:",dress.changeModel)
                if(dress.changeModel == nil) then
                    break
                end
                local modelArray = lua_string_split(dress.changeModel,",")
                
                for modelIndex=1,#modelArray do
                    local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
                    local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]
                    
                    require "db/DB_Heroes"
                    local heroTmpl = DB_Heroes.getDataById(team1Info.members[uid].htid)
                    if(heroTmpl.model_id == tonumber(baseHtid))then
                        --print("m_playerCardHidMap[cardInfo.hid]:",cardInfo.hid,baseHtid)
                        team1Info.members[uid].replaceImage = dressFile
                    end
                end
            end
        end
    end
    
    --team2info
    for i=1,#(m_battleData.server.team2.memberList) do
        
        local uid = m_battleData.server.team2.memberList[i].uid .. ""
        
        currentHpMap[uid] = tonumber(m_battleData.server.team2.memberList[i].maxHp)
        maxHpMap[uid] = tonumber(m_battleData.server.team2.memberList[i].maxHp)
        
        team2Info.members[uid] = {}
        team2Info.members[uid].maxHp = tonumber(m_battleData.server.team2.memberList[i].maxHp)
        team2Info.members[uid].currentHp = tonumber(m_battleData.server.team2.memberList[i].maxHp)
        team2Info.members[uid].name = m_battleData.server.team2.memberList[i].name
        team2Info.memberCount = team2Info.memberCount + 1
        team2Info.leftMemberCount = team2Info.leftMemberCount + 1
        team2Info.members[uid].maxWin = m_battleData.server.team2.memberList[i].maxWin
        if(tonumber(uid)>20000)then
            team2Info.members[uid].htid = tonumber(m_battleData.server.team2.memberList[i].htid)
            
            local curHeroData = DB_Heroes.getDataById(team2Info.members[uid].htid)
            
            require "script/ui/hero/HeroPublicLua"
            team2Info.members[uid].color = HeroPublicLua.getCCColorByStarLevel(curHeroData.star_lv)
        else
            local armyId = tonumber(m_battleData.server.team2.memberList[i].name)
            require "db/DB_Army"
            local army = DB_Army.getDataById(armyId)
            require "db/DB_Team"
            local team = DB_Team.getDataById(army.monster_group)
            
            local monsterHtid = team.copyTeamShowId
            print("monsterHtid:",monsterHtid,army.monster_group,armyId)
            require "db/DB_Monsters_tmpl"
            local monsterTmpl = DB_Monsters_tmpl.getDataById(monsterHtid)
            
            team2Info.members[uid].htid = tonumber(monsterHtid)
            team2Info.members[uid].name = monsterTmpl.name
            
            require "script/ui/hero/HeroPublicLua"
            team2Info.members[uid].color = HeroPublicLua.getCCColorByStarLevel(monsterTmpl.star_lv)
        end
        
        if(m_battleData.server.team2.memberList[i].dress~=nil )then
            for key,value in pairs (m_battleData.server.team2.memberList[i].dress) do
                local dressId = tonumber(value)
                require "db/DB_Item_dress"
                local dress = DB_Item_dress.getDataById(dressId)
                --print("dress changeModel:",dress.changeModel)
                if(dress.changeModel == nil) then
                    break
                end
                
                local modelArray = lua_string_split(dress.changeModel,",")
                
                for modelIndex=1,#modelArray do
                    local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
                    local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]
                    
                    require "db/DB_Heroes"
                    local heroTmpl = DB_Heroes.getDataById(team2Info.members[uid].htid)
                    if(heroTmpl.model_id == tonumber(baseHtid))then
                        --print("m_playerCardHidMap[cardInfo.hid]:",cardInfo.hid,baseHtid)
                        team2Info.members[uid].replaceImage = dressFile
                    end
                end
            end
        end
    end
    return true
end

function isUidInTeam1(uid)
    local memberInfo = team1Info.members[uid .. ""]
    
    local result = not (memberInfo==nil)
    --print("isUidInTeam1:",uid,result,memberInfo)
    return result
end

function initBattleBlocks()
    
    local rawPosition1BlockArray = {}
    local rawPosition2BlockArray = {}
    local rawPosition3BlockArray = {}
    
    for processId=1,#(m_battleData.server.arrProcess) do
        if(m_battleData.server.arrProcess[processId][1].brid~=nil)then
            print("m_battleData.server.arrProcess[processId].1.brid:",m_battleData.server.arrProcess[processId][1].brid)
            for simpleRecordId=1,#(m_battleData.server.arrProcess[processId][1].simpleRecord) do
                local arrIndex = #rawPosition1BlockArray+1
                rawPosition1BlockArray[arrIndex] = {}
                rawPosition1BlockArray[arrIndex].roundNumber = processId
                if(isUidInTeam1(m_battleData.server.arrProcess[processId][1].attacker)==true)then
                    rawPosition1BlockArray[arrIndex].attacker = m_battleData.server.arrProcess[processId][1].attacker
                    rawPosition1BlockArray[arrIndex].defender = m_battleData.server.arrProcess[processId][1].defender
                    rawPosition1BlockArray[arrIndex].attackerDamage = m_battleData.server.arrProcess[processId][1].simpleRecord[simpleRecordId][1]
                    rawPosition1BlockArray[arrIndex].defenderDamage = m_battleData.server.arrProcess[processId][1].simpleRecord[simpleRecordId][2]
                    if(simpleRecordId==#(m_battleData.server.arrProcess[processId][1].simpleRecord))then
                        rawPosition1BlockArray[arrIndex].isFightOver = true
                        if(m_battleData.server.arrProcess[processId][1].appraise=="F")then
                            rawPosition1BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition1BlockArray[arrIndex].isDefenderLeave = false
                            rawPosition1BlockArray[arrIndex].isAttackerWin = false
                        elseif(m_battleData.server.arrProcess[processId][1].appraise=="E")then
                            rawPosition1BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition1BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition1BlockArray[arrIndex].isAttackerWin = false
                        else
                            rawPosition1BlockArray[arrIndex].isAttackerLeave = false
                            rawPosition1BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition1BlockArray[arrIndex].isAttackerWin = true
                        end
                    end
                else
                    
                    rawPosition1BlockArray[arrIndex].attacker = m_battleData.server.arrProcess[processId][1].defender
                    rawPosition1BlockArray[arrIndex].defender = m_battleData.server.arrProcess[processId][1].attacker
                    rawPosition1BlockArray[arrIndex].attackerDamage = m_battleData.server.arrProcess[processId][1].simpleRecord[simpleRecordId][2]
                    rawPosition1BlockArray[arrIndex].defenderDamage = m_battleData.server.arrProcess[processId][1].simpleRecord[simpleRecordId][1]
                    if(simpleRecordId==#(m_battleData.server.arrProcess[processId][1].simpleRecord))then
                        rawPosition1BlockArray[arrIndex].isFightOver = true
                        if(m_battleData.server.arrProcess[processId][1].appraise=="F")then
                            rawPosition1BlockArray[arrIndex].isAttackerLeave = false
                            rawPosition1BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition1BlockArray[arrIndex].isAttackerWin = true
                        elseif(m_battleData.server.arrProcess[processId][1].appraise=="E")then
                            rawPosition1BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition1BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition1BlockArray[arrIndex].isAttackerWin = false
                        else
                            rawPosition1BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition1BlockArray[arrIndex].isDefenderLeave = false
                            rawPosition1BlockArray[arrIndex].isAttackerWin = false
                        end
                    end
                end
            end
        end
        if(m_battleData.server.arrProcess[processId][2].brid~=nil)then
            print("m_battleData.server.arrProcess[processId].2.brid:",m_battleData.server.arrProcess[processId][2].brid)
            for simpleRecordId=1,#(m_battleData.server.arrProcess[processId][2].simpleRecord) do
                local arrIndex = #rawPosition2BlockArray+1
                rawPosition2BlockArray[arrIndex] = {}
                rawPosition2BlockArray[arrIndex].roundNumber = processId
                if(isUidInTeam1(m_battleData.server.arrProcess[processId][2].attacker)==true)then
                    rawPosition2BlockArray[arrIndex].attacker = m_battleData.server.arrProcess[processId][2].attacker
                    rawPosition2BlockArray[arrIndex].defender = m_battleData.server.arrProcess[processId][2].defender
                    rawPosition2BlockArray[arrIndex].attackerDamage = m_battleData.server.arrProcess[processId][2].simpleRecord[simpleRecordId][1]
                    rawPosition2BlockArray[arrIndex].defenderDamage = m_battleData.server.arrProcess[processId][2].simpleRecord[simpleRecordId][2]
                    if(simpleRecordId==#(m_battleData.server.arrProcess[processId][2].simpleRecord))then
                        rawPosition2BlockArray[arrIndex].isFightOver = true
                        if(m_battleData.server.arrProcess[processId][2].appraise=="F")then
                            rawPosition2BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition2BlockArray[arrIndex].isDefenderLeave = false
                            rawPosition2BlockArray[arrIndex].isAttackerWin = false
                            elseif(m_battleData.server.arrProcess[processId][2].appraise=="E")then
                            rawPosition2BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition2BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition2BlockArray[arrIndex].isAttackerWin = false
                            else
                            rawPosition2BlockArray[arrIndex].isAttackerLeave = false
                            rawPosition2BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition2BlockArray[arrIndex].isAttackerWin = true
                        end
                    end
                    else
                    
                    rawPosition2BlockArray[arrIndex].attacker = m_battleData.server.arrProcess[processId][2].defender
                    rawPosition2BlockArray[arrIndex].defender = m_battleData.server.arrProcess[processId][2].attacker
                    rawPosition2BlockArray[arrIndex].attackerDamage = m_battleData.server.arrProcess[processId][2].simpleRecord[simpleRecordId][2]
                    rawPosition2BlockArray[arrIndex].defenderDamage = m_battleData.server.arrProcess[processId][2].simpleRecord[simpleRecordId][1]
                    if(simpleRecordId==#(m_battleData.server.arrProcess[processId][2].simpleRecord))then
                        rawPosition2BlockArray[arrIndex].isFightOver = true
                        if(m_battleData.server.arrProcess[processId][2].appraise=="F")then
                            rawPosition2BlockArray[arrIndex].isAttackerLeave = false
                            rawPosition2BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition2BlockArray[arrIndex].isAttackerWin = true
                            elseif(m_battleData.server.arrProcess[processId][2].appraise=="E")then
                            rawPosition2BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition2BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition2BlockArray[arrIndex].isAttackerWin = false
                            else
                            rawPosition2BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition2BlockArray[arrIndex].isDefenderLeave = false
                            rawPosition2BlockArray[arrIndex].isAttackerWin = false
                        end
                    end
                end
            end
        end
        if(m_battleData.server.arrProcess[processId][3].brid~=nil)then
            print("m_battleData.server.arrProcess[processId].3.brid:",m_battleData.server.arrProcess[processId][3].brid)
            for simpleRecordId=1,#(m_battleData.server.arrProcess[processId][3].simpleRecord) do
                local arrIndex = #rawPosition3BlockArray+1
                rawPosition3BlockArray[arrIndex] = {}
                rawPosition3BlockArray[arrIndex].roundNumber = processId
                if(isUidInTeam1(m_battleData.server.arrProcess[processId][3].attacker)==true)then
                    rawPosition3BlockArray[arrIndex].attacker = m_battleData.server.arrProcess[processId][3].attacker
                    rawPosition3BlockArray[arrIndex].defender = m_battleData.server.arrProcess[processId][3].defender
                    rawPosition3BlockArray[arrIndex].attackerDamage = m_battleData.server.arrProcess[processId][3].simpleRecord[simpleRecordId][1]
                    rawPosition3BlockArray[arrIndex].defenderDamage = m_battleData.server.arrProcess[processId][3].simpleRecord[simpleRecordId][2]
                    if(simpleRecordId==#(m_battleData.server.arrProcess[processId][3].simpleRecord))then
                        rawPosition3BlockArray[arrIndex].isFightOver = true
                        if(m_battleData.server.arrProcess[processId][3].appraise=="F")then
                            rawPosition3BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition3BlockArray[arrIndex].isDefenderLeave = false
                            rawPosition3BlockArray[arrIndex].isAttackerWin = false
                            elseif(m_battleData.server.arrProcess[processId][3].appraise=="E")then
                            rawPosition3BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition3BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition3BlockArray[arrIndex].isAttackerWin = false
                            else
                            rawPosition3BlockArray[arrIndex].isAttackerLeave = false
                            rawPosition3BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition3BlockArray[arrIndex].isAttackerWin = true
                        end
                    end
                    else
                    
                    rawPosition3BlockArray[arrIndex].attacker = m_battleData.server.arrProcess[processId][3].defender
                    rawPosition3BlockArray[arrIndex].defender = m_battleData.server.arrProcess[processId][3].attacker
                    rawPosition3BlockArray[arrIndex].attackerDamage = m_battleData.server.arrProcess[processId][3].simpleRecord[simpleRecordId][2]
                    rawPosition3BlockArray[arrIndex].defenderDamage = m_battleData.server.arrProcess[processId][3].simpleRecord[simpleRecordId][1]
                    if(simpleRecordId==#(m_battleData.server.arrProcess[processId][3].simpleRecord))then
                        rawPosition3BlockArray[arrIndex].isFightOver = true
                        if(m_battleData.server.arrProcess[processId][3].appraise=="F")then
                            rawPosition3BlockArray[arrIndex].isAttackerLeave = false
                            rawPosition3BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition3BlockArray[arrIndex].isAttackerWin = true
                            elseif(m_battleData.server.arrProcess[processId][3].appraise=="E")then
                            rawPosition3BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition3BlockArray[arrIndex].isDefenderLeave = true
                            rawPosition3BlockArray[arrIndex].isAttackerWin = false
                            else
                            rawPosition3BlockArray[arrIndex].isAttackerLeave = true
                            rawPosition3BlockArray[arrIndex].isDefenderLeave = false
                            rawPosition3BlockArray[arrIndex].isAttackerWin = false
                        end
                    end
                end
            end
        end
    end
    
    print("============rawPosition1BlockArray==============")
    print_table("rawPosition1BlockArray",rawPosition1BlockArray)
    print("============rawPosition2BlockArray==============")
    print_table("rawPosition2BlockArray",rawPosition2BlockArray)
    print("============rawPosition3BlockArray==============")
    print_table("rawPosition3BlockArray",rawPosition3BlockArray)
    
    --初始化卡牌状态
    local cardStates = {}
    for key, value in pairs(team1Info.members) do
        cardStates[key .. ""] = 0
    end
    for key, value in pairs(team2Info.members) do
        cardStates[key .. ""] = 0
    end
    
    local position1Index = 1;
    local position2Index = 1;
    local position3Index = 1;
    battleBlocks = {}
    battleBlocks["1"] = {}
    battleBlocks["2"] = {}
    battleBlocks["3"] = {}
    
    local function hasPreFight(teamId,roundNumber)
        print("hasPreFight:",teamId .. "," .. roundNumber)
        if(tonumber(roundNumber)==1)then
            print("hasPreFight false:",teamId .. "," .. roundNumber)
            return false
        end
        
        for processId=1,roundNumber-1 do
            for i=1,3 do
                --print("hasPreFight info:",processId,i,m_battleData.server.arrProcess[processId][i].defender .. "," ..m_battleData.server.arrProcess[processId][i].attacker)
                if(m_battleData.server.arrProcess[processId][i].defender~=nil and tonumber(m_battleData.server.arrProcess[processId][i].defender)==tonumber(teamId))then
                    --print("hasPreFight true:",teamId .. "," .. roundNumber)
                    return true
                end
                if(m_battleData.server.arrProcess[processId][i].attacker~=nil and tonumber(m_battleData.server.arrProcess[processId][i].attacker)==tonumber(teamId))then
                    --print("hasPreFight true:",teamId .. "," .. roundNumber)
                    return true
                end
            end
        end
        print("hasPreFight false:",teamId .. "," .. roundNumber)
        return false
    end
    
    for i=1,9999 do
        if(position1Index>#rawPosition1BlockArray and position2Index>#rawPosition2BlockArray and position3Index>#rawPosition3BlockArray)then
            print("battleBlocks.blockLength:",battleBlocks.blockLength)
            battleBlocks.blockLength = i
            break
        end
        
        local usedCards = {}
        
        if(rawPosition1BlockArray[position1Index]~=nil)then
            local bBlock = rawPosition1BlockArray[position1Index]
            local isAttackerFree = (cardStates[bBlock.attacker .. ""] == 0 and not hasPreFight(bBlock.attacker,bBlock.roundNumber)) or (cardStates[bBlock.attacker .. ""] == 4)
            local isDefenderFree = (cardStates[bBlock.defender .. ""] == 0 and not hasPreFight(bBlock.defender,bBlock.roundNumber)) or (cardStates[bBlock.defender .. ""] == 4)
            if((isAttackerFree==true and isDefenderFree==true ) or(cardStates[bBlock.attacker .. ""] == 1 and cardStates[bBlock.defender .. ""] == 1))then
                battleBlocks["1"][i] = bBlock
                
                if(bBlock.isFightOver==true)then
                    cardStates[bBlock.attacker .. ""] = 4
                    cardStates[bBlock.defender .. ""] = 4
                    else
                    cardStates[bBlock.attacker .. ""] = 1
                    cardStates[bBlock.defender .. ""] = 1
                end
                position1Index = position1Index + 1
                usedCards[#usedCards+1] = bBlock.attacker .. ""
                usedCards[#usedCards+1] = bBlock.defender .. ""
            end
        end
        
        if(rawPosition2BlockArray[position2Index]~=nil)then
            local bBlock = rawPosition2BlockArray[position2Index]
            local isCardUesd = false
            for usedIndex=1,#usedCards do
                if(usedCards[usedIndex] == (bBlock.attacker .. "") or usedCards[usedIndex] == (bBlock.defender .. ""))then
                    isCardUesd = true
                end
            end
            if(isCardUesd==false)then
                local isAttackerFree = (cardStates[bBlock.attacker .. ""] == 0 and not hasPreFight(bBlock.attacker,bBlock.roundNumber)) or (cardStates[bBlock.attacker .. ""] == 4)
                local isDefenderFree = (cardStates[bBlock.defender .. ""] == 0 and not hasPreFight(bBlock.defender,bBlock.roundNumber)) or (cardStates[bBlock.defender .. ""] == 4)
                if((isAttackerFree==true and isDefenderFree==true ) or(cardStates[bBlock.attacker .. ""] == 2 and cardStates[bBlock.defender .. ""] == 2))then
                    battleBlocks["2"][i] = bBlock
                    
                    if(bBlock.isFightOver==true)then
                        cardStates[bBlock.attacker .. ""] = 4
                        cardStates[bBlock.defender .. ""] = 4
                        else
                        cardStates[bBlock.attacker .. ""] = 2
                        cardStates[bBlock.defender .. ""] = 2
                    end
                    position2Index = position2Index + 1
                    usedCards[#usedCards+1] = bBlock.attacker .. ""
                    usedCards[#usedCards+1] = bBlock.defender .. ""
                end
            end
        end
        
        if(rawPosition3BlockArray[position3Index]~=nil)then
            local bBlock = rawPosition3BlockArray[position3Index]
            local isCardUesd = false
            for usedIndex=1,#usedCards do
                if(usedCards[usedIndex] == (bBlock.attacker .. "") or usedCards[usedIndex] == (bBlock.defender .. ""))then
                    isCardUesd = true
                end
            end
            if(isCardUesd==false)then
                local isAttackerFree = (cardStates[bBlock.attacker .. ""] == 0 and not hasPreFight(bBlock.attacker,bBlock.roundNumber)) or (cardStates[bBlock.attacker .. ""] == 4)
                local isDefenderFree = (cardStates[bBlock.defender .. ""] == 0 and not hasPreFight(bBlock.defender,bBlock.roundNumber)) or (cardStates[bBlock.defender .. ""] == 4)
                if((isAttackerFree==true and isDefenderFree==true ) or(cardStates[bBlock.attacker .. ""] == 3 and cardStates[bBlock.defender .. ""] == 3))then
                    battleBlocks["3"][i] = bBlock
                    
                    if(bBlock.isFightOver==true)then
                        cardStates[bBlock.attacker .. ""] = 4
                        cardStates[bBlock.defender .. ""] = 4
                        else
                        cardStates[bBlock.attacker .. ""] = 3
                        cardStates[bBlock.defender .. ""] = 3
                    end
                    position3Index = position3Index + 1
                end
            end
        end
        
    end
    
    --print("============battleBlocks==============")
    --print_table("battleBlocks",battleBlocks)
end

function getTeam1PointByPosition(position)
    position = position - 1
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    local startX = 0.20*m_bg:getContentSize().width;
    --local startY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale() - cardWidth*2.4;
    
    local startY = 0.5*m_bg:getContentSize().height
    
    return ccp(startX+position%3*cardWidth*1.4, startY-cardWidth*1.2)
end

function playWalkEffect()
    
    local walkEffect = "walk0" .. math.floor(math.random()*5+1)
    --print("playWalkEffect:",walkEffect)
    if(file_exists("audio/effect/" .. walkEffect .. ".mp3")) then
        --print("playWalkEffect1:",walkEffect)
        
        AudioUtil.playEffect("audio/effect/" .. walkEffect .. ".mp3")
    end
end

function startWalkEffect()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    if(runningScene:getActionByTag(5643)==nil)then
        local action = schedule(runningScene,playWalkEffect,0.45)
        action:setTag(5643)
    end
end

function endWalkEffect()
    
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:stopActionByTag(5643)
    runningScene:setPosition(0,0)
end

function getTeam2PointByPosition(index)
    index = index - 1
    
    local cardWidth = m_bg:getContentSize().width*0.2
    
    local startX = 0.20*m_bg:getContentSize().width;
    --local startY = 0.48*CCDirector:sharedDirector():getWinSize().height/m_bg:getScale()
    
    local startY = 0.5*m_bg:getContentSize().height
    
    return ccp(startX+index%3*cardWidth*1.4, startY+cardWidth*1.2)
end

function setTeam1Back()
    
    local teamChildArray = m_team1CardLayer:getChildren()
    for idx=1,teamChildArray:count() do
        --print("childNode:",idx,teamChildArray:count() )
        local childNode = tolua.cast(teamChildArray:objectAtIndex(idx-1),"CCNode")
        local nodeTag = childNode:getTag()
        if( math.floor(nodeTag/10)==100)then
            
            childNode:setVisible(true)
        else
            childNode:cleanup()
            childNode:setVisible(false)
            childNode:setTag(0)
            --childNode:removeFromParentAndCleanup(true)
        end
    end
    endWalkEffect()
end

function setTeam2Back()
    
    local teamChildArray = m_team2CardLayer:getChildren()
    for idx=1,teamChildArray:count() do
        --print("childNode:",idx,teamChildArray:count() )
        local childNode = tolua.cast(teamChildArray:objectAtIndex(idx-1),"CCNode")
        
        local nodeTag = childNode:getTag()
        if( math.floor(nodeTag/10)==200)then
            
            childNode:setVisible(true)
        else
            childNode:cleanup()
            childNode:setVisible(false)
            childNode:setTag(0)
            --childNode:removeFromParentAndCleanup(true)
        end
    end
    endWalkEffect()
end

function showDamage(node,damageValue)
    
    --掉血
    local fontWidth = 43
    damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/red","" .. damageValue,fontWidth)
    damageLabel:setAnchorPoint(ccp(0.5,0.5))
    local damagePos = ccp(0,0)
    if(math.floor(node:getTag()/1000)==1)then
        
        damagePos = ccp(node:getPositionX(),node:getPositionY()-node:getContentSize().height*0.0)
    else
        
        damagePos = ccp(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.0)
    end
    damageLabel:setPosition(damagePos)
    node:getParent():addChild(damageLabel,999)
    
    if(damageTitleSprite~=nil)then
        damageLabel:addChild(damageTitleSprite)
    end
    
    ---[[
    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCScaleTo:create(0.1,2))
    damageActionArray:addObject(CCScaleTo:create(0.05,1))
    damageActionArray:addObject(CCDelayTime:create(1))
    damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))
    
end

function closeLayer()
    
    CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    if(m_visibleViews~=nil)then
        for idx=1,m_visibleViews:count() do
            local childNode = tolua.cast(m_visibleViews:objectAtIndex(idx-1),"CCNode")
            print("closeLayer childNode:getTag():",childNode:getTag())
            if(childNode~=nil and childNode:getTag()~=90901)then
                childNode:setVisible(true)
            end
        end
        m_visibleViews:removeAllObjects()
        m_visibleViews:release()
        m_visibleViews = nil
    end
    battleBaseLayer:removeFromParentAndCleanup(true)
    
    AudioUtil.playBgm("audio/main.mp3")
    
    require "script/ui/login/LoginScene"
    LoginScene.setBattleStatus(false)
end

function showAfterBattleLayer()
    print("show battle report")
    if(m_afterBattleLayer) then
        battleBaseLayer:addChild(m_afterBattleLayer,1111,9569)
        m_afterBattleLayer:release()
        print("show extern battle report layer")
        return
    end

    if(m_battleType == BattleForGuild) then
        require "script/ui/guild/GuildAfterBattleLayer"
        local layer = GuildAfterBattleLayer.createAfterBattleLayer(m_battleData,m_isRepeat)
        battleBaseLayer:addChild(layer,1111,9569)
        print("show BattleForGuild report layer")
    elseif(m_battleType == BattleForCity) then
        require "script/ui/guild/city/CityAfterBattleLayer"
        local layer = CityAfterBattleLayer.createAfterBattleLayer(m_battleData,m_isRepeat)
        battleBaseLayer:addChild(layer,1111,9569)
        print("show BattleForCity report layer")
    end
end

function blockEnd()
    
    print("blockEnd start")
    
    battleBlockIndex = battleBlockIndex + 1
    
    print("battleBlockIndex,battleBlocks.blockLength:",battleBlockIndex,battleBlocks.blockLength)
    if(battleBlockIndex>=battleBlocks.blockLength)then
        if(m_battleData.reward == nil) then
            m_battleData.reward ={}
        end
        if(m_battleData.reward.silver~=nil and battleMoneyLabel)then
            battleMoneyLabel:setString(m_battleData.reward.silver .. "")
        end
        if(m_battleData.reward.soul~=nil and battleSoulLabel)then
            battleSoulLabel:setString(m_battleData.reward.soul .. "")
        end
        if(m_battleData.reward.item~=nil and battleResourceLabel)then
            local itemCount = 0
            for key, value in pairs(m_battleData.reward.item) do
                itemCount = itemCount+1
            end
            battleResourceLabel:setString(itemCount .. "")
        end

        local team1ActionArray = CCArray:create()
        team1ActionArray:addObject(CCDelayTime:create(1.5))
        team1ActionArray:addObject(CCCallFunc:create(showAfterBattleLayer))
        m_team1CardLayer:runAction(CCSequence:create(team1ActionArray))
        --closeLayer()
        return
    end
    --moveInBeforeFight()
    
    local team1ActionArray = CCArray:create()
    team1ActionArray:addObject(CCDelayTime:create(1))
    team1ActionArray:addObject(CCCallFunc:create(moveInBeforeFight))
    m_team1CardLayer:runAction(CCSequence:create(team1ActionArray))
end

local function showReport()
    if(m_battleType == BattleForCity) then
        require "script/ui/guild/copy/GuildBattleReportLayer"
        GuildBattleReportLayer.showLayer(m_battleData,true,-560,11111,true)
    else
        require "script/ui/guild/copy/GuildBattleReportLayer"
        GuildBattleReportLayer.showLayer(m_battleData,true,-560,11111)
    end

end

local function speedClick1()
    ---[[
    require "script/model/user/UserModel"
    if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_2997") .. speedUpLevel .. GetLocalizeStringBy("key_2293"))
        return
    end
    --]]
    --print("speedClick========")
    battleSpeedButton1:setVisible(false)
    battleSpeedButton2:setVisible(true)
    battleSpeedButton3:setVisible(false)
    m_BattleTimeScale = 2
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
end

local function speedClick2()
    --print("speedClick========")
    require "script/model/user/UserModel"
    if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUp3Level)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_2997") .. speedUp3Level .. GetLocalizeStringBy("key_2462"))
        
        battleSpeedButton2:setVisible(false)
        battleSpeedButton1:setVisible(true)
        battleSpeedButton3:setVisible(false)
        m_BattleTimeScale = 1
        CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
        
        return
    end
    battleSpeedButton2:setVisible(false)
    battleSpeedButton1:setVisible(false)
    battleSpeedButton3:setVisible(true)
    m_BattleTimeScale = 3
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
end

local function speedClick3()
    --print("speedClick========")
    battleSpeedButton2:setVisible(false)
    battleSpeedButton1:setVisible(true)
    battleSpeedButton3:setVisible(false)
    m_BattleTimeScale = 1
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
end

local function skipClick()

    require "db/DB_Normal_config"
    local teamcopyisSkipFight = lua_string_split(DB_Normal_config.getDataById(1).teamcopyisSkipFight, "|")
    local vipLeve = tonumber(teamcopyisSkipFight[1])
    local userLevel = tonumber(teamcopyisSkipFight[2])

    if UserModel.getVipLevel() < vipLeve or UserModel.getHeroLevel() < userLevel then
        AnimationTip.showTip(GetLocalizeStringBy("lcyx_104",vipLeve, userLevel))
        return
    end
    
    m_bg:removeAllChildrenWithCleanup(true)
    endWalkEffect()
    -- m_team1CardLayer:removeAllChildrenWithCleanup(true)
    -- m_team1CardLayer:removeFromParentAndCleanup(true)
    m_team1CardLayer = nil
    -- m_team2CardLayer:removeAllChildrenWithCleanup(true)
    -- m_team2CardLayer:removeFromParentAndCleanup(true)
    m_team2CardLayer = nil


    if(m_afterBattleLayer) then
        battleBaseLayer:addChild(m_afterBattleLayer,1111,9569)
        m_afterBattleLayer:release()
        print("show extern battle report layer")
        return
    end

    if(m_battleType == BattleForGuild) then
        require "script/ui/guild/GuildAfterBattleLayer"
        local layer = GuildAfterBattleLayer.createAfterBattleLayer(m_battleData,m_isRepeat )
        battleBaseLayer:addChild(layer,1111,9569)
    elseif(m_battleType == BattleForCity) then
        print("skipClick BattleForCity")
        require "script/ui/guild/city/CityAfterBattleLayer"
        local layer = CityAfterBattleLayer.createAfterBattleLayer(m_battleData,m_isRepeat)
        battleBaseLayer:addChild(layer,1111,9569)
    end
    
    -- closeLayer()
end

function initCityUperLayer( ... )
    require "script/ui/main/MainScene"
    MainScene.initScales()
    battleUperLayer = CCLayer:create()
    
    local blackBackLayer = CCLayerColor:create(ccc4(0,0,0,111))
    blackBackLayer:setContentSize(CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCDirector:sharedDirector():getWinSize().height*0.05))
    blackBackLayer:setPosition(0,CCDirector:sharedDirector():getWinSize().height*0.96)
    battleUperLayer:addChild(blackBackLayer)


    
    --battleRoundIcon = CCLabelTTF:create(GetLocalizeStringBy("key_1728"),g_sFontName,battleBaseLayer:getContentSize().height/35)
    local attackerSprite = CCSprite:create(IMG_PATH .. "city/attacker.png")
    attackerSprite:setAnchorPoint(ccp(0,0.5))
    attackerSprite:setPosition(battleBaseLayer:getContentSize().width*0.01,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(attackerSprite)

    attackerCountLabel = CCLabelTTF:create(team1Info.memberCount .. "/" .. team1Info.memberCount,g_sFontPangWa,battleBaseLayer:getContentSize().height/35)
    attackerCountLabel:setAnchorPoint(ccp(0.5,0.5))
    attackerCountLabel:setPosition(battleBaseLayer:getContentSize().width*0.25,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(attackerCountLabel)
    attackerCountLabel:setColor(ccc3(0xe8,0,0))

    battleRoundIcon = CCSprite:create(IMG_PATH .. "city/defender.png")
    battleRoundIcon:setAnchorPoint(ccp(0.5,0.5))
    battleRoundIcon:setPosition(battleBaseLayer:getContentSize().width*0.75,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleRoundIcon)
    
    battleRoundLabel = CCLabelTTF:create(team2Info.memberCount .. "/" .. team2Info.memberCount,g_sFontPangWa,battleBaseLayer:getContentSize().height/35)
    battleRoundLabel:setAnchorPoint(ccp(0.5,0.5))
    battleRoundLabel:setPosition(battleBaseLayer:getContentSize().width*0.9,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleRoundLabel)
    battleRoundLabel:setColor(ccc3(0x00, 0xe4, 0xff))
    
    local startX = battleBaseLayer:getContentSize().width*0.05
    local intervalX = battleBaseLayer:getContentSize().width*0.11
    local labelX = battleBaseLayer:getContentSize().width*0.05
    
    
    --battleSpeedButton = CCMenuItemLabel:create(CCLabelTTF:create("X1",g_sFontName,battleBaseLayer:getContentSize().height/20))
    battleSpeedButton1 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed1_n.png",IMG_PATH .. "btn/btn_speed1_d.png")
    battleSpeedButton1:setAnchorPoint(ccp(0,0))
    battleSpeedButton1:setPosition(0,0)
    battleSpeedButton1:registerScriptTapHandler(speedClick1)
    battleSpeedButton1:setScale(MainScene.elementScale)
    
    battleSpeedButton2 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed2_n.png",IMG_PATH .. "btn/btn_speed2_d.png")
    battleSpeedButton2:setAnchorPoint(ccp(0,0))
    battleSpeedButton2:setPosition(0,0)
    battleSpeedButton2:registerScriptTapHandler(speedClick2)
    battleSpeedButton2:setScale(MainScene.elementScale)
    
    battleSpeedButton3 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed3_n.png",IMG_PATH .. "btn/btn_speed3_d.png")
    battleSpeedButton3:setAnchorPoint(ccp(0,0))
    battleSpeedButton3:setPosition(0,0)
    battleSpeedButton3:registerScriptTapHandler(speedClick3)
    battleSpeedButton3:setScale(MainScene.elementScale)
    
    if(m_BattleTimeScale<=1) then
        m_BattleTimeScale = 1
        CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
        battleSpeedButton2:setVisible(false)
        battleSpeedButton3:setVisible(false)
        else
        require "script/model/user/UserModel"
        if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
            m_BattleTimeScale = 1
            CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
            battleSpeedButton2:setVisible(false)
            battleSpeedButton3:setVisible(false)
            else
            if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUp3Level or (m_BattleTimeScale>=2 and m_BattleTimeScale<3))then
                m_BattleTimeScale = 2
                CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
                battleSpeedButton1:setVisible(false)
                battleSpeedButton3:setVisible(false)
                else
                m_BattleTimeScale = 3
                CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
                battleSpeedButton2:setVisible(false)
                battleSpeedButton1:setVisible(false)
            end
        end
    end
    
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    --menu:addChild(battleSpeedButton1)
    --menu:addChild(battleSpeedButton2)
    --menu:addChild(battleSpeedButton3)
    battleUperLayer:addChild(menu,0,1299)
    menu:setTouchPriority(-550)
    
    --local menu = battleUperLayer:getChildByTag(1299)
    -- if(m_isReport) then
    skipFightButton = CCMenuItemImage:create(IMG_PATH .. "icon/icon_skip_n.png",IMG_PATH .. "icon/icon_skip_h.png")
    skipFightButton:registerScriptTapHandler(skipClick)
    skipFightButton:setAnchorPoint(ccp(1,0))
    skipFightButton:setPosition(battleBaseLayer:getContentSize().width*1,0)
    menu:addChild(skipFightButton)
    skipFightButton:setScale(MainScene.elementScale)
    -- end

    
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(180,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(180,64))
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    disabledSprite:setContentSize(CCSizeMake(180,64))
    local refreshMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    refreshMenuItem:setAnchorPoint(ccp(0.5,0))
    refreshMenuItem:setPosition(ccp(battleBaseLayer:getContentSize().width*0.5,2))
    menu:addChild(refreshMenuItem)
    local  refreshMenuItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1924"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    refreshMenuItem_font:setAnchorPoint(ccp(0.5,0.5))
    refreshMenuItem_font:setColor(ccc3(0xfe,0xdb,0x1c))
    refreshMenuItem_font:setPosition(ccp(refreshMenuItem:getContentSize().width*0.5,refreshMenuItem:getContentSize().height*0.5+2))
    refreshMenuItem:addChild(refreshMenuItem_font)
    refreshMenuItem:registerScriptTapHandler(showReport)
    refreshMenuItem:setScale(MainScene.elementScale)

    --攻放玩家名称
    local attackerIconBg    = CCScale9Sprite:create("images/battle/guild/iconBg.png")
    attackerIconBg:setContentSize(CCSizeMake(173, 49))
    attackerIconBg:setPosition(ccps(0, 0.47))
    attackerIconBg:setAnchorPoint(ccp(0, 0.5))
    battleUperLayer:addChild(attackerIconBg,100)
    attackerIconBg:setScale(MainScene.elementScale)

    local attackerIcon      = CCSprite:create("images/battle/guild/attackerIcon.png")
    attackerIcon:setAnchorPoint(ccp(0,0.5))
    attackerIcon:setPosition(ccp(0, attackerIconBg:getContentSize().height/2))
    attackerIconBg:addChild(attackerIcon)
    
    local attackerName      = CCRenderLabel:create( m_battleData.server.team1.name, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    attackerName:setAnchorPoint(ccp(0, 0.5))
    attackerName:setPosition(attackerIcon:getContentSize().width + 5, attackerIconBg:getContentSize().height/2)
    attackerIconBg:addChild(attackerName)

    --守方玩家名称
    local defenderIconBg    = CCScale9Sprite:create("images/battle/guild/iconBg.png")
    defenderIconBg:setContentSize(CCSizeMake(173, 49))
    defenderIconBg:setPosition(ccps(1, 0.53))
    defenderIconBg:setAnchorPoint(ccp(1, 0.5))
    battleUperLayer:addChild(defenderIconBg,100)
    defenderIconBg:setScale(MainScene.elementScale)

    local defenderIcon      = CCSprite:create("images/battle/guild/defenderIcon.png")
    defenderIcon:setAnchorPoint(ccp(0,0.5))
    defenderIcon:setPosition(ccp(0, defenderIconBg:getContentSize().height/2))
    defenderIconBg:addChild(defenderIcon)
    
    local defenderName      = CCRenderLabel:create( m_battleData.server.team2.name, g_sFontPangWa, 24, 1, ccc3(0x00,0x00,0x00), type_stroke)
    defenderName:setAnchorPoint(ccp(0, 0.5))
    defenderName:setPosition(defenderIcon:getContentSize().width + 5, defenderIconBg:getContentSize().height/2)
    defenderIconBg:addChild(defenderName)

    return battleUperLayer
end


local function initGuildUperLayer()
    
    require "script/ui/main/MainScene"
    MainScene.initScales()
    battleUperLayer = CCLayer:create()
    
    local blackBackLayer = CCLayerColor:create(ccc4(0,0,0,111))
    blackBackLayer:setContentSize(CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCDirector:sharedDirector():getWinSize().height*0.05))
    blackBackLayer:setPosition(0,CCDirector:sharedDirector():getWinSize().height*0.96)
    battleUperLayer:addChild(blackBackLayer)
    
    --battleRoundIcon = CCLabelTTF:create(GetLocalizeStringBy("key_1728"),g_sFontName,battleBaseLayer:getContentSize().height/35)
    battleRoundIcon = CCSprite:create(IMG_PATH .. "guild/enemy.png")
    battleRoundIcon:setAnchorPoint(ccp(0.5,0.5))
    battleRoundIcon:setPosition(battleBaseLayer:getContentSize().width*0.75,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleRoundIcon)
    
    battleRoundLabel = CCLabelTTF:create(team2Info.memberCount .. "/" .. team2Info.memberCount,g_sFontPangWa,battleBaseLayer:getContentSize().height/35)
    battleRoundLabel:setAnchorPoint(ccp(0.5,0.5))
    battleRoundLabel:setPosition(battleBaseLayer:getContentSize().width*0.9,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleRoundLabel)
    
    local startX = battleBaseLayer:getContentSize().width*0.05
    local intervalX = battleBaseLayer:getContentSize().width*0.11
    local labelX = battleBaseLayer:getContentSize().width*0.05
    
    
    local battleResourceIcon = CCSprite:create(IMG_PATH .. "icon/icon_resource.png")
    battleResourceIcon:setAnchorPoint(ccp(0.5,0.5))
    battleResourceIcon:setPosition(startX+intervalX*0,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleResourceIcon)
    battleResourceIcon:setScale(MainScene.elementScale)
    
    battleResourceLabel = CCLabelTTF:create("0",g_sFontName,battleBaseLayer:getContentSize().height/35)
    battleResourceLabel:setAnchorPoint(ccp(0,0.5))
    battleResourceLabel:setPosition(startX+intervalX*0.5,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleResourceLabel)
    
    local battleSoulIcon = CCSprite:create(IMG_PATH .. "icon/icon_soul.png")
    battleSoulIcon:setAnchorPoint(ccp(0.5,0.5))
    battleSoulIcon:setPosition(startX+intervalX*1.5,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleSoulIcon)
    battleSoulIcon:setScale(MainScene.elementScale)
    
    battleSoulLabel = CCLabelTTF:create("0",g_sFontName,battleBaseLayer:getContentSize().height/35)
    battleSoulLabel:setAnchorPoint(ccp(0,0.5))
    battleSoulLabel:setPosition(startX+intervalX*2,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleSoulLabel)
    
    local battleMoneyIcon = CCSprite:create(IMG_PATH .. "icon/icon_money.png")
    battleMoneyIcon:setAnchorPoint(ccp(0.5,0.5))
    battleMoneyIcon:setPosition(startX+intervalX*3.5,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleMoneyIcon)
    battleMoneyIcon:setScale(MainScene.elementScale)
    
    battleMoneyLabel = CCLabelTTF:create("0",g_sFontName,battleBaseLayer:getContentSize().height/35)
    battleMoneyLabel:setAnchorPoint(ccp(0,0.5))
    battleMoneyLabel:setPosition(startX+intervalX*4,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleMoneyLabel)
    battleMoneyLabel:setColor(ccc3(0xff,0xdc,0x20))
    
    --battleSpeedButton = CCMenuItemLabel:create(CCLabelTTF:create("X1",g_sFontName,battleBaseLayer:getContentSize().height/20))
    battleSpeedButton1 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed1_n.png",IMG_PATH .. "btn/btn_speed1_d.png")
    battleSpeedButton1:setAnchorPoint(ccp(0,0))
    battleSpeedButton1:setPosition(0,0)
    battleSpeedButton1:registerScriptTapHandler(speedClick1)
    battleSpeedButton1:setScale(MainScene.elementScale)
    
    battleSpeedButton2 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed2_n.png",IMG_PATH .. "btn/btn_speed2_d.png")
    battleSpeedButton2:setAnchorPoint(ccp(0,0))
    battleSpeedButton2:setPosition(0,0)
    battleSpeedButton2:registerScriptTapHandler(speedClick2)
    battleSpeedButton2:setScale(MainScene.elementScale)
    
    battleSpeedButton3 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed3_n.png",IMG_PATH .. "btn/btn_speed3_d.png")
    battleSpeedButton3:setAnchorPoint(ccp(0,0))
    battleSpeedButton3:setPosition(0,0)
    battleSpeedButton3:registerScriptTapHandler(speedClick3)
    battleSpeedButton3:setScale(MainScene.elementScale)
    
    if(m_BattleTimeScale<=1) then
        m_BattleTimeScale = 1
        CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
        battleSpeedButton2:setVisible(false)
        battleSpeedButton3:setVisible(false)
        else
        require "script/model/user/UserModel"
        if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
            m_BattleTimeScale = 1
            CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
            battleSpeedButton2:setVisible(false)
            battleSpeedButton3:setVisible(false)
            else
            if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUp3Level or (m_BattleTimeScale>=2 and m_BattleTimeScale<3))then
                m_BattleTimeScale = 2
                CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
                battleSpeedButton1:setVisible(false)
                battleSpeedButton3:setVisible(false)
                else
                m_BattleTimeScale = 3
                CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
                battleSpeedButton2:setVisible(false)
                battleSpeedButton1:setVisible(false)
            end
        end
    end
    
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    --menu:addChild(battleSpeedButton1)
    --menu:addChild(battleSpeedButton2)
    --menu:addChild(battleSpeedButton3)
    battleUperLayer:addChild(menu,0,1299)
    menu:setTouchPriority(-550)
    
    --local menu = battleUperLayer:getChildByTag(1299)
    -- if(m_isReport) then
        skipFightButton = CCMenuItemImage:create(IMG_PATH .. "icon/icon_skip_n.png",IMG_PATH .. "icon/icon_skip_h.png")
        skipFightButton:registerScriptTapHandler(skipClick)
        skipFightButton:setAnchorPoint(ccp(1,0))
        skipFightButton:setPosition(battleBaseLayer:getContentSize().width*1,0)
        menu:addChild(skipFightButton)
        skipFightButton:setScale(MainScene.elementScale)
    -- end
    
    local normalSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    normalSprite:setContentSize(CCSizeMake(180,64))
    local selectSprite  = CCScale9Sprite:create("images/common/btn/btn_purple2_h.png")
    selectSprite:setContentSize(CCSizeMake(180,64))
    local disabledSprite = CCScale9Sprite:create("images/common/btn/btn_purple2_n.png")
    disabledSprite:setContentSize(CCSizeMake(180,64))
    local refreshMenuItem = CCMenuItemSprite:create(normalSprite,selectSprite,disabledSprite)
    refreshMenuItem:setAnchorPoint(ccp(0.5,0))
    refreshMenuItem:setPosition(ccp(battleBaseLayer:getContentSize().width*0.5,2))
    menu:addChild(refreshMenuItem)
    local  refreshMenuItem_font = CCRenderLabel:create( GetLocalizeStringBy("key_1924"), g_sFontPangWa, 35, 1, ccc3(0x00,0x00,0x00), type_stroke)
    refreshMenuItem_font:setAnchorPoint(ccp(0.5,0.5))
    refreshMenuItem_font:setColor(ccc3(0xfe,0xdb,0x1c))
    refreshMenuItem_font:setPosition(ccp(refreshMenuItem:getContentSize().width*0.5,refreshMenuItem:getContentSize().height*0.5+2))
    refreshMenuItem:addChild(refreshMenuItem_font)
    refreshMenuItem:registerScriptTapHandler(showReport)
    refreshMenuItem:setScale(MainScene.elementScale)

    
    return battleUperLayer
end


function showFailAnimation(card)
    --card:removeFromParentAndCleanup(true)
    print("showFailAnimation start:",card:getTag())
    local moveY = 0
    if(math.floor(card:getTag()/1000)==1)then
        moveY = -500
    else
        moveY = 500
    end
    card:setTag(0)
    
    local damageActionArray = CCArray:create()
    --damageActionArray:addObject(CCRotateTo:create(1,360*5))
    --damageActionArray:addObject(CCMoveBy:create(1,ccp(0,moveY)))
    damageActionArray:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(1,360*5), CCMoveBy:create(1,ccp(0,moveY))))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    card:runAction(CCSequence:create(damageActionArray))
end

function showBump()
    print("showBump start")
    local animationCount = 0
    local finishCount = 0
    
    local function bumpEnd(actionName,xmlSprite)
        finishCount = finishCount + 1
        print("bumpEnd start:",finishCount,animationCount)
        
        local teamNumber = math.floor(xmlSprite:getTag()/1000)
        local positionNumber = math.floor(xmlSprite:getTag()%10)
        local damageValue = 0
        local uid = 0
        
        xmlSprite:cleanup()
        xmlSprite:setVisible(false)
        xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500):setVisible(true)
        
        --[[
        local shakeSprite = getCardByTeamId()
        
        local function showOldCard(actionName,xmlSprite2)
            print("==========showOldCard===========")
            xmlSprite2:getParent():getChildByTag(xmlSprite:getTag()-500):setVisible(true)
            
        end
        
        --delegate
        local animationFrameChanged = function(frameIndex,xmlSprite)
        end
        
        --增加动画监听
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(showOldCard)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        xmlSprite:setDelegate(delegate)
        --xmlSprite:setIsLoop(true)
    
        if(teamNumber==1)then
            xmlSprite:runXMLAnimation(CCString:create("images/battle/xml/action/T0010_d_0"))
        else
            xmlSprite:runXMLAnimation(CCString:create("images/battle/xml/action/T0010_u_0"))
        end
        --]]
        
        if(teamNumber==1)then
            damageValue = battleBlocks[positionNumber .. ""][battleBlockIndex].attackerDamage
            uid = battleBlocks[positionNumber .. ""][battleBlockIndex].attacker
        else
            damageValue = battleBlocks[positionNumber .. ""][battleBlockIndex].defenderDamage
            uid = battleBlocks[positionNumber .. ""][battleBlockIndex].defender
        end
        currentHpMap[uid .. ""] = currentHpMap[uid .. ""]+damageValue
        BattleCardUtil.setCardHp(xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500),currentHpMap[uid .. ""]/maxHpMap[uid .. ""])
        showDamage(xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500),damageValue)
        --showDamage()
        
        --判断当前是否结束
        if(battleBlocks[positionNumber .. ""][battleBlockIndex].isFightOver==true)then
            
            winningCountMap[uid] = winningCountMap[uid]==nil and 0 or winningCountMap[uid]
            
            if(battleBlocks[positionNumber .. ""][battleBlockIndex].appraise=="E")then
                
            else
                if(battleBlocks[positionNumber .. ""][battleBlockIndex].isAttackerWin==true and teamNumber==1)then
                    winningCountMap[uid] = winningCountMap[uid] + 1
                    showTalkDialog(xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500), false, winningCountMap[uid], 2)
                elseif(battleBlocks[positionNumber .. ""][battleBlockIndex].isAttackerWin==false and teamNumber==2)then
                    winningCountMap[uid] = winningCountMap[uid] + 1
                    showTalkDialog(xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500), true, winningCountMap[uid], 2)
                end
            end
            
            local playeMaxWin = getPlayMaxWinCount(uid) or maxWinningCount
            if(winningCountMap[uid]>=tonumber(playeMaxWin))then
                retraitArray[#retraitArray+1] = xmlSprite:getTag()-500
                --连胜到达上限，退场，更新剩余战队数量
                if(m_battleType == BattleForCity) then
                    for k,v in pairs(m_battleData.server.team1.memberList) do
                        if(tonumber(v.uid) == tonumber(uid)) then
                            if team1Info.leftMemberCount < 0 then
                                team1Info.leftMemberCount = 0
                            end
                            team1Info.leftMemberCount = team1Info.leftMemberCount -1
                            attackerCountLabel:setString(team1Info.leftMemberCount .. "/" .. team1Info.memberCount)
                            break
                        end
                    end
                    for k,v in pairs(m_battleData.server.team2.memberList) do
                        if(tonumber(v.uid) == tonumber(uid)) then
                            team2Info.leftMemberCount = team2Info.leftMemberCount -1
                            if team2Info.leftMemberCount < 0 then
                                team2Info.leftMemberCount = 0
                            end
                            battleRoundLabel:setString(team2Info.leftMemberCount .. "/" .. team2Info.memberCount)
                            break
                        end
                    end
                end
            end
            print("bumpEnd info:",teamNumber,battleBlocks[positionNumber .. ""][battleBlockIndex].isAttackerLeave,battleBlocks[positionNumber .. ""][battleBlockIndex].isDefenderLeave)
            if(teamNumber==1 and battleBlocks[positionNumber .. ""][battleBlockIndex].isAttackerLeave==true)then
                showFailAnimation(xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500))
                cardsPosition[xmlSprite:getTag()-500] = nil
                if(m_battleType == BattleForCity) then
                    team1Info.leftMemberCount = team1Info.leftMemberCount -1
                    if team1Info.leftMemberCount < 0 then
                        team1Info.leftMemberCount = 0
                    end
                    attackerCountLabel:setString(team1Info.leftMemberCount .. "/" .. team1Info.memberCount)
                end
            elseif(teamNumber==2 and battleBlocks[positionNumber .. ""][battleBlockIndex].isDefenderLeave==true)then
                showFailAnimation(xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500))
                cardsPosition[xmlSprite:getTag()-500] = nil
                team2Info.leftMemberCount = team2Info.leftMemberCount -1
                if team2Info.leftMemberCount < 0 then
                    team2Info.leftMemberCount = 0
                end
                battleRoundLabel:setString(team2Info.leftMemberCount .. "/" .. team2Info.memberCount)
            end
            
            local originalCard = xmlSprite:getParent():getChildByTag(xmlSprite:getTag()-500)
            if(originalCard~=nil)then
                local numberLabel = tolua.cast( originalCard:getChildByTag(93),"CCLabelTTF")
                numberLabel:setString(winningCountMap[uid] .. "/" .. playeMaxWin)
            end
        end
        
        if(finishCount<animationCount)then
        elseif(finishCount==animationCount)then
            
            blockEnd()
        else
            print(" finish count out of animation count")
        end
    end
    
    for i=1,3 do
        local blockInfo = battleBlocks[i .. ""][battleBlockIndex]
        print("blockInfo:",battleBlockIndex,blockInfo)
        if(blockInfo~=nil and m_team2CardLayer ~= nil)then
            local defendCard = m_team2CardLayer:getChildByTag(i+2000)
            print("m_team2CardLayer child start")
            local sceneChildArray = m_team2CardLayer:getChildren()
            for idx=1,sceneChildArray:count() do
                --print("childNode:",idx,sceneChildArray:count() )
                local childNode = tolua.cast(sceneChildArray:objectAtIndex(idx-1),"CCNode")
                print("m_team2CardLayer child node tag:",childNode:getTag())
            end
            
            m_team1CardLayer:removeChildByTag(1500+i,true)
            m_team2CardLayer:removeChildByTag(2500+i,true)
            
            if(defendCard~=nil and m_team1CardLayer ~= nil)then
                defendCard:setVisible(false)
                
                local defendActionCard = getCardByTeamId(blockInfo.defender)
                defendActionCard:setTag(2500+i)
                defendActionCard:setAnchorPoint(ccp(0.5,0.5))
                defendActionCard:setPosition(getTeam2PointByPosition(i))
                defendActionCard:setBasePoint(getTeam2PointByPosition(i))
                m_team2CardLayer:addChild(defendActionCard,i)
                
                --delegate
                local animationFrameChanged = function(frameIndex,xmlSprite)
                end
            
                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(bumpEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                defendActionCard:setDelegate(delegate)
                
                print("currentHp:",currentHpMap[blockInfo.defender .. ""],maxHpMap[blockInfo.defender .. ""])
                BattleCardUtil.setCardHp(defendActionCard,currentHpMap[blockInfo.defender .. ""]/maxHpMap[blockInfo.defender .. ""])
                
                defendActionCard:setVisible(true)
                defendActionCard:setIsLoop(false)
                defendActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/T008_u_0"))
                
                animationCount = animationCount + 1
            end
            
            local attackCard = m_team1CardLayer:getChildByTag(i+1000)
            if(attackCard~=nil)then
                attackCard:setVisible(false)
                
                local attackActionCard = getCardByTeamId(blockInfo.attacker)
                attackActionCard:setTag(1500+i)
                attackActionCard:setAnchorPoint(ccp(0.5,0.5))
                attackActionCard:setPosition(getTeam1PointByPosition(i))
                attackActionCard:setBasePoint(getTeam1PointByPosition(i))
                m_team1CardLayer:addChild(attackActionCard,i)
                
                --delegate
                local animationFrameChanged = function(frameIndex,xmlSprite)
                    if(frameIndex==15)then
                        
                        if(file_exists("audio/effect/" .. "zhuangjitx" .. ".mp3")) then
                            AudioUtil.playEffect("audio/effect/" .. "zhuangjitx" .. ".mp3")
                        end
                        
                        local bgEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/zhuangjitx"), -1,CCString:create(""))
                        local function crashFrameChanged()
                        end
                        local function crashFrameEnd()
                            bgEffectSprite:removeFromParentAndCleanup(true)
                        end
                        
                        local delegate = BTAnimationEventDelegate:create()
                        delegate:registerLayerEndedHandler(crashFrameEnd)
                        delegate:registerLayerChangedHandler(crashFrameChanged)
                        bgEffectSprite:setDelegate(delegate)
        
                        bgEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                        bgEffectSprite:setPosition(xmlSprite:getPositionX(),xmlSprite:getPositionY()+xmlSprite:getContentSize().height/2);
                        m_bg:addChild(bgEffectSprite,88)
                    end
                end
        
                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(bumpEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                attackActionCard:setDelegate(delegate)
        
                print("currentHp:",currentHpMap[blockInfo.attacker .. ""],maxHpMap[blockInfo.attacker .. ""])
                BattleCardUtil.setCardHp(attackActionCard,currentHpMap[blockInfo.attacker .. ""]/maxHpMap[blockInfo.attacker .. ""])
                
                attackActionCard:setVisible(true)
                attackActionCard:setIsLoop(false)
                attackActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/T008_d_0"))
            
                animationCount = animationCount + 1
            end
            
        end
    end
end

function moveInBeforeFight()
    
    print("moveInBeforeFight start:",battleBlockIndex)
    
    local delayTime = 0
    
    if(retraitArray~=nil and #retraitArray>0)then
        for i=1,#retraitArray do
            local tag = retraitArray[i]
            local positionNumber = retraitArray[i]%10
            print("retraitArray:",tag,cardsPosition[tag .. ""])
            if(math.floor(tag/1000)==1)then
                
                m_team1CardLayer:removeChildByTag(tag,true)
                
                local tempLayer = CCLayer:create()
                tempLayer:setAnchorPoint(ccp(0,0))
                tempLayer:setPosition(0,0)
                m_team1CardLayer:addChild(tempLayer,5)
                
                local attackActionCard = getCardByTeamId(cardsPosition[tag .. ""])
                attackActionCard:setTag(1510+i)
                attackActionCard:setAnchorPoint(ccp(0.5,0.5))
                attackActionCard:setPosition(getTeam1PointByPosition(positionNumber))
                attackActionCard:setBasePoint(getTeam1PointByPosition(positionNumber))
                tempLayer:addChild(attackActionCard,positionNumber)
                
                local retraitLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2199"),g_sFontName,35)
                retraitLabel:setColor(ccc3(0xff,0xf6,0x00))
                retraitLabel:setAnchorPoint(ccp(0.5,0.5))
                retraitLabel:setPosition(attackActionCard:getContentSize().width*0.5,attackActionCard:getContentSize().height*0.5)
                attackActionCard:addChild(retraitLabel,91)
                
                attackActionCard:setIsLoop(true)
                attackActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"))
                
                local function moveDone()
                    --attackCard:setVisible(true)
                    removeSelf(tempLayer)
                end
                
                
                local team1ActionArray = CCArray:create()
                team1ActionArray:addObject(CCMoveBy:create(2,ccp(0,-500)))
                team1ActionArray:addObject(CCCallFunc:create(moveDone))
                tempLayer:runAction(CCSequence:create(team1ActionArray))
                
                
                delayTime = delayTime>2 and delayTime or 2
            elseif(math.floor(tag/1000)==2)then
                
                m_team2CardLayer:removeChildByTag(tag,true)
                
                local tempLayer = CCLayer:create()
                tempLayer:setAnchorPoint(ccp(0,0))
                tempLayer:setPosition(0,0)
                m_team2CardLayer:addChild(tempLayer,5)
                
                local attackActionCard = getCardByTeamId(cardsPosition[tag .. ""])
                attackActionCard:setTag(2510+i)
                attackActionCard:setAnchorPoint(ccp(0.5,0.5))
                attackActionCard:setPosition(getTeam2PointByPosition(positionNumber))
                attackActionCard:setBasePoint(getTeam2PointByPosition(positionNumber))
                tempLayer:addChild(attackActionCard,positionNumber)
                
                attackActionCard:setIsLoop(true)
                attackActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"))
                
                local function moveDone()
                    --attackCard:setVisible(true)
                    removeSelf(tempLayer)
                end
                
                
                local team2ActionArray = CCArray:create()
                team2ActionArray:addObject(CCMoveBy:create(2,ccp(0,500)))
                team2ActionArray:addObject(CCCallFunc:create(moveDone))
                tempLayer:runAction(CCSequence:create(team2ActionArray))
                
                delayTime = delayTime>2 and delayTime or 2
            end
        end
    end

    retraitArray = {}

    for i=1,3 do
        local blockInfo = battleBlocks[i .. ""][battleBlockIndex]
        print("blockInfo:",i,battleBlockIndex)
        print_table("blockInfo",blockInfo)
        if(blockInfo~=nil)then
            
            local attackerTag = getCardPosition(tonumber(blockInfo.attacker))
            
            local defenderTag = getCardPosition(tonumber(blockInfo.defender))
            print("cardsPosition:",i,attackerTag,defenderTag,blockInfo.attacker,blockInfo.defender)
            print_table("cardsPosition",cardsPosition)
            --[[
            m_team1CardLayer:removeChildByTag(1000+i,true)
            m_team1CardLayer:removeChildByTag(1500+i,true)
            m_team2CardLayer:removeChildByTag(2000+i,true)
            m_team2CardLayer:removeChildByTag(2500+i,true)
            --]]
            
            if(attackerTag==nil)then
                m_team1CardLayer:removeChildByTag(1000+i,true)
                m_team1CardLayer:removeChildByTag(1500+i,true)
                
                local attackCard = getCardByTeamId(blockInfo.attacker)
                attackCard:setTag(1000+i)
                attackCard:setAnchorPoint(ccp(0.5,0.5))
                attackCard:setPosition(getTeam1PointByPosition(i))
                m_team1CardLayer:addChild(attackCard,i)
                attackCard:setVisible(false)
                
                local tempLayer = CCLayer:create()
                tempLayer:setAnchorPoint(ccp(0,0))
                tempLayer:setPosition(0,-500)
                m_team1CardLayer:addChild(tempLayer,5)
            
                local attackActionCard = getCardByTeamId(blockInfo.attacker)
                attackActionCard:setTag(1500+i)
                attackActionCard:setAnchorPoint(ccp(0.5,0.5))
                attackActionCard:setPosition(getTeam1PointByPosition(i))
                attackActionCard:setBasePoint(getTeam1PointByPosition(i))
                tempLayer:addChild(attackActionCard,i)
            
                attackActionCard:setIsLoop(true)
                attackActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"))
                
                local function moveDone()
                
                    attackCard:setVisible(true)
                    removeSelf(tempLayer)
                end
                
            
                local team1ActionArray = CCArray:create()
                team1ActionArray:addObject(CCMoveBy:create(2,ccp(0,500)))
                team1ActionArray:addObject(CCCallFunc:create(moveDone))
                tempLayer:runAction(CCSequence:create(team1ActionArray))
            
            delayTime = delayTime>2 and delayTime or 2
            
            elseif(attackerTag~=(1000+i))then
                local attackCard = m_team1CardLayer:getChildByTag(attackerTag)
                attackCard:setTag(1000+i)
                attackCard:setAnchorPoint(ccp(0.5,0.5))
                --attackCard:setPosition(getTeam1PointByPosition(i))
                --m_team1CardLayer:addChild(attackCard,i)
                local function setAttackerCardPosition()
                    attackCard:setPosition(getTeam1PointByPosition(i))
                end
                local team1ActionArray = CCArray:create()
                team1ActionArray:addObject(CCFadeOut:create(0.5))
                team1ActionArray:addObject(CCCallFunc:create(setAttackerCardPosition))
                team1ActionArray:addObject(CCDelayTime:create(0.2))
                team1ActionArray:addObject(CCFadeIn:create(1))
                attackCard:runAction(CCSequence:create(team1ActionArray))
        
                cardsPosition[attackerTag .. ""] = nil
                cardsPosition[(1000+i) .. ""] = blockInfo.attacker
        
                delayTime = delayTime>1.8 and delayTime or 1.8
            else
                
            end
        
            --team2处理
        
            if(defenderTag==nil)then
                
                m_team2CardLayer:removeChildByTag(2000+i,true)
                m_team2CardLayer:removeChildByTag(2500+i,true)
                
                local defendCard = getCardByTeamId(blockInfo.defender)
                defendCard:setTag(2000+i)
                defendCard:setAnchorPoint(ccp(0.5,0.5))
                defendCard:setPosition(getTeam2PointByPosition(i))
                m_team2CardLayer:addChild(defendCard,i)
                defendCard:setVisible(false)
                
                local tempLayer = CCLayer:create()
                tempLayer:setAnchorPoint(ccp(0,0))
                tempLayer:setPosition(0,500)
                m_team2CardLayer:addChild(tempLayer,5)
                
                local defendActionCard = getCardByTeamId(blockInfo.defender)
                defendActionCard:setTag(2500+i)
                defendActionCard:setAnchorPoint(ccp(0.5,0.5))
                defendActionCard:setPosition(getTeam2PointByPosition(i))
                defendActionCard:setBasePoint(getTeam2PointByPosition(i))
                tempLayer:addChild(defendActionCard,i)
                
                defendActionCard:setIsLoop(true)
                defendActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"))
                
                local function moveDone()
                    
                    defendCard:setVisible(true)
                    removeSelf(tempLayer)
                end
                
                
                local team2ActionArray = CCArray:create()
                team2ActionArray:addObject(CCMoveBy:create(2,ccp(0,-500)))
                team2ActionArray:addObject(CCCallFunc:create(moveDone))
                tempLayer:runAction(CCSequence:create(team2ActionArray))
    
    delayTime = delayTime>2 and delayTime or 2
    
    
            elseif(defenderTag~=(2000+i))then
                local defendCard = m_team2CardLayer:getChildByTag(defenderTag)
                defendCard:setTag(2000+i)
                defendCard:setAnchorPoint(ccp(0.5,0.5))
                --defendCard:setPosition(getTeam2PointByPosition(i))
                --m_team2CardLayer:addChild(defendCard,i)
                local function setdefenderCardPosition()
                    defendCard:setPosition(getTeam2PointByPosition(i))
                end
                local team2ActionArray = CCArray:create()
                team2ActionArray:addObject(CCFadeOut:create(0.5))
                team2ActionArray:addObject(CCCallFunc:create(setdefenderCardPosition))
                team2ActionArray:addObject(CCDelayTime:create(0.2))
                team2ActionArray:addObject(CCFadeIn:create(1))
                defendCard:runAction(CCSequence:create(team2ActionArray))

                cardsPosition[defenderTag .. ""] = nil
                cardsPosition[(2000+i) .. ""] = blockInfo.defender

                print("1057 cardsPosition:",i,battleBlockIndex,defenderTag,blockInfo.defender)
                print_table("cardsPosition",cardsPosition)

                delayTime = delayTime>1.8 and delayTime or 1.8
            else
    
            end
            
            cardsPosition[(1000+i) .. ""] = tonumber(blockInfo.attacker)
            cardsPosition[(2000+i) .. ""] = tonumber(blockInfo.defender)
    
        else

        end
    end
    if(delayTime==0)then
        --showBump()
        showRoundTimes()
    else
        local team1ActionArray = CCArray:create()
        team1ActionArray:addObject(CCDelayTime:create(delayTime))
        --team1ActionArray:addObject(CCCallFunc:create(showBump))
        team1ActionArray:addObject(CCCallFunc:create(showRoundTimes))
        m_team1CardLayer:runAction(CCSequence:create(team1ActionArray))
    end
end

function showRoundTimes()
    
    local roundLayer = CCLayerColor:create(ccc4(1,1,1,166))
    roundLayer:setPosition(0,0)
    battleBaseLayer:addChild(roundLayer)
    
    local roundBg = CCSprite:create(IMG_PATH .. "guild/bg.png")
    roundBg:setAnchorPoint(ccp(0.5,0.5))
    roundBg:setPosition(ccp(roundLayer:getContentSize().width*0.5,roundLayer:getContentSize().height*0.5))
    roundLayer:addChild(roundBg,2)
    
    local splitSp = CCSprite:create(IMG_PATH .. "guild/split.png")
    splitSp:setAnchorPoint(ccp(0.5,0.5))
    splitSp:setPosition(ccp(-roundLayer:getContentSize().width*0.1,roundLayer:getContentSize().height*0.5))
    roundLayer:addChild(splitSp,1)
    
    splitSp:runAction(CCMoveBy:create(0.3,ccp(roundLayer:getContentSize().width*0.6,0)))
    
    local roundSp = LuaCC.createNumberSprite02(IMG_PATH .. "guild","" .. battleBlockIndex,0)
    roundSp:setAnchorPoint(ccp(0,0.5))
    roundSp:setPosition(ccp(roundLayer:getContentSize().width*1.07-roundSp:getContentSize().width*0.5,roundLayer:getContentSize().height*0.5))
    roundLayer:addChild(roundSp,3)
    
    roundSp:runAction(CCMoveBy:create(0.3,ccp(-roundLayer:getContentSize().width*0.6,0)))
    
    local team1ActionArray = CCArray:create()
    team1ActionArray:addObject(CCDelayTime:create(1))
    team1ActionArray:addObject(CCCallFunc:create(showBump))
    team1ActionArray:addObject(CCCallFuncN:create(removeSelf))
    roundLayer:runAction(CCSequence:create(team1ActionArray))
end

function startFight()
    
    cardsPosition = {}
    
    battleBlockIndex = 1
    --currentBattleBlock = battleBlocks[battleBlockIndex]
    
    local moveDistance = 200
    local moveTime = 2
    local delayTime = 0.8
    
     m_team1CardLayer = CCLayer:create()
    m_team1CardLayer:setPosition(0,-moveDistance)
     m_team2CardLayer = CCLayer:create()
    m_team2CardLayer:setPosition(0,moveDistance)
    
    for i=1,3 do
        local blockInfo = battleBlocks[i .. ""][battleBlockIndex]
        if(blockInfo~=nil)then
            
        cardsPosition[(1000+i) .. ""] = tonumber(blockInfo.attacker)
        cardsPosition[(2000+i) .. ""] = tonumber(blockInfo.defender)
        
        local attackCard = getCardByTeamId(blockInfo.attacker)
        attackCard:setTag(1000+i)
        attackCard:setAnchorPoint(ccp(0.5,0.5))
        attackCard:setPosition(getTeam1PointByPosition(i))
        m_team1CardLayer:addChild(attackCard,i)
        --attackCard:setVisible(false)
        -- showTalkDialog(attackCard, false, nil, 2.5)
        
        local attackActionCard = getCardByTeamId(blockInfo.attacker)
        attackActionCard:setTag(1500+i)
        attackActionCard:setAnchorPoint(ccp(0.5,0.5))
        attackActionCard:setPosition(getTeam1PointByPosition(i))
        attackActionCard:setBasePoint(getTeam1PointByPosition(i))
        m_team1CardLayer:addChild(attackActionCard,i)
        attackActionCard:setVisible(false)
        showTalkDialog(attackActionCard, false, nil, 2.5)

        local defendCard = getCardByTeamId(blockInfo.defender)
        defendCard:setTag(2000+i)
        defendCard:setAnchorPoint(ccp(0.5,0.5))
        defendCard:setPosition(getTeam2PointByPosition(i))
        m_team2CardLayer:addChild(defendCard,i)
        --defendCard:setVisible(false)
        -- showTalkDialog(defendCard, true, nil, 2.5)
        
        local defendActionCard = getCardByTeamId(blockInfo.defender)
        defendActionCard:setTag(2500+i)
        defendActionCard:setAnchorPoint(ccp(0.5,0.5))
        defendActionCard:setPosition(getTeam2PointByPosition(i))
        defendActionCard:setBasePoint(getTeam2PointByPosition(i))
        m_team2CardLayer:addChild(defendActionCard,i)
        defendActionCard:setVisible(false)
        showTalkDialog(defendActionCard, true, nil, 2.5)
        
        end
    end
    
    function startWalk()
        
        for i=1,3 do
            local attackActionCard = tolua.cast(m_team1CardLayer:getChildByTag(1500+i), "CCXMLSprite")
            if(attackActionCard~=nil)then
                
                m_team1CardLayer:getChildByTag(1000+i):setVisible(false)
                
                attackActionCard:setVisible(true)
                attackActionCard:setIsLoop(true)
                attackActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"))
            end
            
            local defendActionCard = tolua.cast(m_team2CardLayer:getChildByTag(2500+i), "CCXMLSprite")
            
            if(attackActionCard~=nil)then
                
                m_team2CardLayer:getChildByTag(2000+i):setVisible(false)
                
                defendActionCard:setVisible(true)
                defendActionCard:setIsLoop(true)
                defendActionCard:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"))
            end
        end
        startWalkEffect()
    end
    
    m_bg:addChild(m_team1CardLayer)
    m_bg:addChild(m_team2CardLayer)
    
    local team1ActionArray = CCArray:create()
    team1ActionArray:addObject(CCDelayTime:create(delayTime))
    team1ActionArray:addObject(CCCallFunc:create(startWalk))
    team1ActionArray:addObject(CCMoveBy:create(moveTime,ccp(0,moveDistance)))
    team1ActionArray:addObject(CCCallFuncN:create(setTeam1Back))
    team1ActionArray:addObject(CCDelayTime:create(0.5))
    team1ActionArray:addObject(CCCallFunc:create(moveInBeforeFight))
    m_team1CardLayer:runAction(CCSequence:create(team1ActionArray))
    
    local team2ActionArray = CCArray:create()
    team2ActionArray:addObject(CCDelayTime:create(delayTime))
    team2ActionArray:addObject(CCMoveBy:create(moveTime,ccp(0,-moveDistance)))
    team2ActionArray:addObject(CCCallFuncN:create(setTeam2Back))
    team2ActionArray:addObject(CCDelayTime:create(0.5))
    m_team2CardLayer:runAction(CCSequence:create(team2ActionArray))
    
end


--[[
    @des    :创建并进入一个多人战的战斗场景
    @pram   :battleData         多人战后端战斗数据
            :battleType         战斗类型 （BattleForGuild -- 军团战  BattleForCity --城池战）
            :afterBattleLayer   外部创建的战斗结束面板
            :isReport           是否战报播放 true 战报播放模式，可以跳过
--]]

function createLayer(battleData, battleType, afterBattleLayer, isReport)

	print("battleData:")
    print_table("battleData",battleData)
    math.randomseed(os.time())
    local bgmName       = nil
    m_battleType        = BattleForGuild
    m_afterBattleLayer  = nil
    if(battleType) then
        m_battleType = battleType
    end
    battleType = BattleForCity
    if(afterBattleLayer) then
        m_afterBattleLayer = afterBattleLayer
        m_afterBattleLayer:retain()
    end
    m_isReport = isReport or nil
            
    if(battleData.copyTeamInfo~=nil and battleData.copyTeamInfo.cur_guild_copy~=nil)then
        require "db/DB_Copy_team"
        local cTeam = DB_Copy_team.getDataById(tonumber(battleData.copyTeamInfo.cur_guild_copy))
        if(cTeam~=nil and cTeam.strongHold~=nil)then
            require "db/DB_Stronghold"
            local sh = DB_Stronghold.getDataById(tonumber(cTeam.strongHold))
            if(sh~=nil)then
                bgmName = sh.fire_music
            end
        end
    end
    print("guildbattle bgmName:",bgmName)
    --增加背景音乐
    bgmName = bgmName==nil and defaultBgm or bgmName
    AudioUtil.playBgm("audio/bgm/" .. bgmName)
    
    --数据处理
    m_battleData = battleData
    m_isRepeat = false
    maxWinningCount = tonumber(m_battleData.server.maxWin)
    print("maxWinningCount:",maxWinningCount)
    winningCountMap = {}
    retraitArray = {}
    
    local isBattleOver = false
    if(initTeamInfo() == false) then
        isBattleOver = true
    else
        initBattleBlocks()
    end
    initBackground()
    
    battleBaseLayer = CCLayer:create()
    battleBaseLayer:setTouchEnabled(true)
    battleBaseLayer:registerScriptTouchHandler(layerTouch,false,-499,true)
    
    battleBaseLayer:addChild(m_bg)
    
    --界面层
    local uperLayer = nil
    if(battleType == nil or battleType == BattleForGuild) then
        uperLayer = initGuildUperLayer()
    elseif(battleType == BattleForCity) then
        uperLayer = initCityUperLayer()
    end 
    
    battleBaseLayer:addChild(uperLayer,10)
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    
    ---[[
    m_visibleViews = CCArray:create()
    m_visibleViews:retain()
    local sceneChildArray = scene:getChildren()
    for idx=1,sceneChildArray:count() do
        --print("childNode:",idx,sceneChildArray:count() )
        local childNode = tolua.cast(sceneChildArray:objectAtIndex(idx-1),"CCNode")
        if(childNode~=nil and childNode:isVisible()==true)then
            childNode:setVisible(false)
            m_visibleViews:addObject(childNode)
        end
    end
    --]]
    BattleCardUtil.setNameVisible(false)
    scene:addChild(battleBaseLayer,999,67891)
    local blackLayer = CCLayerColor:create(ccc4(1,1,1,255))
    battleBaseLayer:addChild(blackLayer,9998)
    
    local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    blackLayer:runAction(actions)
    
    if(isBattleOver == true) then
        showAfterBattleLayer()
    else
        startFight()
    end
   
    
    require "script/ui/login/LoginScene"
    LoginScene.setBattleStatus(true)
end

--显示气泡动画
function showTalkDialog( CardSprite , isUp, winTimes, showTime )
    
    require "db/DB_Legion_copy"
    local beginTalks = lua_string_split(DB_Legion_copy.getDataById(1).begin_talk, "|")
    local winTalks   = lua_string_split(DB_Legion_copy.getDataById(1).win_talk, ",")

    
    local talkIndex   = math.random(1, #beginTalks)
    local talkContent = beginTalks[talkIndex]
    
    if(winTalks[tonumber(winTimes)]) then
        local rtalks = lua_string_split(winTalks[tonumber(winTimes)],"|")
        talkContent  = rtalks[math.random(1,#rtalks)]
    end

    local talkLabel   = CCLabelTTF:create(talkContent, g_sFontName, "23")
    talkLabel:setHorizontalAlignment(kCCTextAlignmentLeft)  
    local talkDialog  = nil
    if(isUp) then
        talkDialog = CCScale9Sprite:create("images/battle/talk_up_bg.png")
        talkDialog:setCapInsets(CCRectMake(94, 18, 70, 9))
        talkDialog:setAnchorPoint(ccp(0.5, 1))
        talkLabel:setAnchorPoint(ccp(0, 0))
        talkLabel:setPosition(ccp(5,5))
    else
        talkDialog = CCScale9Sprite:create("images/battle/talk_down_bg.png")
        talkDialog:setCapInsets(CCRectMake(11, 10, 66, 8))
        talkDialog:setAnchorPoint(ccp(0.5, 0))
        talkLabel:setAnchorPoint(ccp(0, 1))
        talkLabel:setPosition(ccp(5,talkLabel:getContentSize().height + 25))
    end
    talkDialog:setContentSize(CCSizeMake( talkLabel:getContentSize().width + 20, talkLabel:getContentSize().height +30))
    talkDialog:addChild(talkLabel)
    
    CardSprite:addChild(talkDialog, 100)
    if(isUp) then
        talkDialog:setPosition(ccp(CardSprite:getContentSize().width/2, -10))
    else
        talkDialog:setPosition(ccp(CardSprite:getContentSize().width/2, CardSprite:getContentSize().height + 30))
    end

    local actionArray = CCArray:create()
    -- actionArray:addObject(CCFadeTo:create(showTime or 2.0, 0))
    actionArray:addObject(CCDelayTime:create(showTime or 2.0))
    actionArray:addObject(CCCallFunc:create(function ( ... )
        talkDialog:removeFromParentAndCleanup(true)
    end))
    talkDialog:runAction(CCSequence:create(actionArray))
end


