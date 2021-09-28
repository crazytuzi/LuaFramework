-- Filename: BattleLayerLee.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景



require "script/utils/extern"
--require "amf3"
-- 主城场景模块声明
module("BattleLayerLee", package.seeall)

--是否在战斗中
isBattleOnGoing = false
local speedUpLevel = 1

require "script/network/RequestCenter"
require "script/utils/LuaUtil"
require "script/guide/overture/PlayerCardLayerLee"
require "script/guide/overture/BattleCardUtilLee"
require "script/audio/AudioUtil"
require "script/libs/LuaCC"
require "script/guide/overture/OTBattleData"

local IMG_PATH = "images/battle/"				-- 图片主路径

--我恨注释……
--MoveDistence = 480        --前进位移
MoveDistence = (2400-640*CCDirector:sharedDirector():getWinSize().height/CCDirector:sharedDirector():getWinSize().width)/3

local defaultBgm = "music01.mp3"

local battleBaseLayer --战斗基础层
local battleUperLayer --战斗上层（界面层）
local battleRoundIcon --回合标示
local battleRoundLabel -- 回合标签
local battleMoneyIcon --金钱标示
local battleMoneyLabel --金钱标签
local battleCardIcon --卡牌标示
local battleCardLabel --卡牌标签
local battlePieceIcon --碎片标示
local battlePieceLabel -- 碎片标签
local battleEquipmentIcon --装备标示
local battleEquipmentLabel --装备标签
local battleResourceIcon --材料标示
local battleResourceLabel --材料标签
local battleSoulIcon --将魂标示
local battleSoulLabel --将魂标签
local battleSpeedButton1 --战斗速度按键
local battleSpeedButton2 --战斗速度按键
local doBattleButton --战斗速度按键
local battleHorseSprite --战马标示

local m_bg			-- 战斗背景
local m_PlayerCardLayerLee			-- 玩家卡牌层
--local m_playerCardList          -- 玩家卡牌列表
local m_enemyCardLayer			-- 敌人卡牌层
--local m_enemyCardList          -- 敌人卡牌列表
local m_BattleTimeScale = 1         -- 战斗时间比例
local m_currentArmyIndex = 1         -- 当前敌人顺序

-- 战斗数据
local m_isShowBattle         -- 回调方法
local m_afterBattleView         -- 回调方法
local m_callbackFunc         -- 回调方法
local m_copy_id          -- 副本ID
local m_base_id          -- 据点ID
local m_level          -- 难度等级
local m_copyType            --副本类型,1普通，2精英，3活动
local m_revivedTime = 0     --复活次数
local m_currentArmyId         -- 当前战斗编号
local m_currentArmyAppearStyle         -- 当前战斗编号
local m_formation           -- 阵型信息
local m_formation_back           -- 阵型信息
local m_formationNpc           -- 阵型信息
local m_battleInfo          -- 战斗信息
local m_battleIndex         -- 当前战斗编号
local m_maxHpTable = {}          -- 最大血量
local m_currentHpTable = {}          -- 当前血量
local m_currentAngerTable = {}          -- 最大血量
local m_currentBattleBlock         -- 当前战斗编号
local m_newcopyorbase          -- 战斗信息
local m_reward              --奖励
local m_appraisal           --战果
local m_currentHp           --储存HP信息
local m_soulNumber           --
local m_itemArray           --
local m_heroArray           --
local m_resourceNumber           --
local m_silverNumber           --
local m_expNumber           --
local m_deadPlayerCardArray = {}     --死亡同伴队列
local m_cardBuffArray = {}     --buff队列
local m_currentHeroDropArray = {}     --掉落队列
local m_heroDropArray = {}     --掉落队列

local m_isCurrentRoundOver         -- 当前回合是否完毕（一个攻击回合，非右上角的回合）
local m_currentAttacker         -- 当前攻击者
local m_currentAttackerIndex         -- 当前攻击者位置
local m_currentDefender         -- 当前防守者
local m_currentDefenderIndex         -- 当前防守者位置
local m_currentIsAttackerEnemy         -- 当前攻击者是否敌人
local m_currentIsDefenderEnemy         -- 当前防守者是否敌人
local m_currentSkillAttackTimes = 1         -- 当前技能攻击次数
local m_currentSkillAttackIndex = 1         -- 当前技能攻击进度
local m_currentChildSkillIndex = 0         -- 当前技能攻击进度

local visibleSize = g_winSize
local origin = g_origin
local showNextMove
local showNextArmy
local doBattle
local doBattleNpc
local initEnemyLayer
local initBackground
local showChildBattleAttack 

function getMainHero()
    require "script/model/hero/HeroModel"
    local tAllHeroes = HeroModel.getAllHeroes()
    for k, v in pairs(tAllHeroes) do
      local htid = tonumber(v.htid)
      --print("getMainHero:",htid,tonumber(v.htid))
      if htid==tonumber(UserModel.getUserInfo().htid) then
         return v
     end
 end
 return 0
end

function removeSelf(node)
    node:removeFromParentAndCleanup(true)
end

function setNodeVisible(node)
    node:setVisible(true)
end

function setNodeNotVisible(node)
    node:setVisible(false)
end

function showAttackerVisible()
    m_currentAttacker:setVisible(true)
end

function doShake()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    
    math.randomseed(os.time())
    local shakeY = math.floor(math.random()*3+1)*CCDirector:sharedDirector():getWinSize().height*0.003
    
    if(runningScene:getPositionY()>=0) then
        shakeY = -shakeY
    end
    
    runningScene:setPosition(0,shakeY)
end

function startShake()
    
	local runningScene = CCDirector:sharedDirector():getRunningScene()
    if(runningScene:getActionByTag(5678)==nil)then
        local action = schedule(runningScene,doShake,0.05)
        action:setTag(5678)
    end
end

function endShake()

local runningScene = CCDirector:sharedDirector():getRunningScene()
runningScene:stopActionByTag(5678)
runningScene:setPosition(0,0)
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

function currentRoundOver()
    m_isCurrentRoundOver = true
end

function createBattleCard(hid)
    --[[
    if(hid == 2007242999)then
        return BattleCardUtilLee.getBattlePlayerCard(hid,true)
    else
        return BattleCardUtilLee.getBattlePlayerCard(hid)
    end
    --]]
    hid = tonumber(hid)
    if(hid>=10000000)then
        
            local htid = UserModel.getAvatarHtid()
            for j=1,#(m_battleInfo.team1.arrHero) do
                local role = m_battleInfo.team1.arrHero[j]
                if(tonumber(role.hid)==tonumber(hid)) then
                    htid = role.htid
                    break
                end
            end
            
            for j=1,#(m_battleInfo.team2.arrHero) do
                local role = m_battleInfo.team2.arrHero[j]
                if(tonumber(role.hid)==tonumber(hid)) then
                    htid = role.htid
                    break
                end
            end
            print("createBattleCard:",hid,htid)
            return BattleCardUtilLee.getBattlePlayerCard(hid,nil,htid)
    else
        
        if(m_currentArmyId==nil)then
            
            return BattleCardUtilLee.getBattlePlayerCard(hid)
        end
        
        require "db/DB_Army"
        local army = DB_Army.getDataById(m_currentArmyId)
        
        require "db/DB_Team"
        local team = DB_Team.getDataById(army.monster_group)
        local monsterIds = lua_string_split(team.monsterID,",")
        print("move3:",army.id,team.id,team.monsterID,team.bossID)
        local bossIds = {}
        if(team.bossID~=nil) then
            bossIds = lua_string_split(team.bossID,",")
        end
        local isBoss = false
        for i=1,#bossIds do
            if(tonumber(bossIds[i]) == tonumber(hid))then
                isBoss = true
                break
            end
        end
        
        local isOutLine = false
        
        local outLineIdStr = team.outlineId
        print("team-----------------------------")
        print_t(team)
        print("team.outlineId :", team.outlineId)
        --print("move3:",army.id,team.id,team.monsterID,team.bossID)
        local outLineIds = {}
        if(outLineIdStr~=nil) then
            outLineIds = lua_string_split(outLineIdStr,",")
        end
        for i=1,#outLineIds do
            print("outLineIds[i] :", outLineIds[i], "     hid:", hid)
            if(tonumber(outLineIds[i]) == tonumber(hid))then
                isOutLine = true
                break
            end
        end
        
        local isdemonLoad = false
        
        local demonLoadIdStr = team.demonLoadId
        --print("move3:",army.id,team.id,team.monsterID,team.bossID)
        local demonLoadIds = {}
        if(demonLoadIdStr~=nil) then
            demonLoadIds = lua_string_split(demonLoadIdStr,",")
        end
        for i=1,#demonLoadIds do
            if(tonumber(demonLoadIds[i]) == tonumber(hid))then
                isdemonLoad = true
                break
            end
        end
        
        if(isOutLine==true)then
            return BattleCardUtilLee.getBattleOutLinePlayerCard(hid)
        else
            return BattleCardUtilLee.getBattlePlayerCard(hid,isBoss,nil,isdemonLoad)
        end
    end
    --return BattleCardUtilLee.getBattlePlayerCard(hid)
end

function doReviveCard(flag,hid)
    if(flag==false)then
        return
    end
    --print("============doReviveCard==============",hid)
    
    function reviveCardCallBack(cbFlag, dictData, bRet)
    --print_table("",dictData)
    --print("============reviveCardCallBack==============",hid)
    if(dictData.ret~=nil and dictData.ret=="ok")then
        
        m_revivedTime = m_revivedTime+1
        
        
            --从死亡列表中移除
            for i=1,table.maxn(m_deadPlayerCardArray) do
                if(m_deadPlayerCardArray[i]==hid)then
                    m_deadPlayerCardArray[i] = nil
                    break
                end
            end
            
            
            local currentFormation = PlayerCardLayerLee.getFormation()
            local pos = -1
            
            for j=0,5 do
                    --print("doReviveCard:",j,currentFormation["" .. j],hid)
                    if(currentFormation["" .. j] == hid)then
                        pos = j
                        break
                    end
                end
                
                local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
                if(node ~= nil) then
                    node:stopAllActions()
                    --node:runAction(CCFadeIn:create(0.01))
                    node:setOpacity(255)
                end
                
                --播放复活特效
                local reviveEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/fuhuo_1"), -1,CCString:create(""));
                reviveEffectSprite:retain()
                reviveEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                
                reviveEffectSprite:setPosition(node:getPositionX(),node:getPositionY());
                m_PlayerCardLayerLee:addChild(reviveEffectSprite,99999);
                reviveEffectSprite:release()
                
            --delegate
            local animationEnd = function(actionName,xmlSprite)
            removeSelf(reviveEffectSprite)
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end
    
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            reviveEffectSprite:setDelegate(delegate)
            
        else
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
            return
        end
    end

    if(m_copyType==1)then
        
        RequestCenter.ncopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,m_level,hid))
        elseif(m_copyType==2)then
            
            RequestCenter.ecopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,hid))
        else
            
            RequestCenter.acopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,m_level,hid))
        end
    --RequestCenter.ncopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,m_level,hid))
end

function reviveCardByHid(hid)
    --print("--------------reviveCardByHid:",hid)
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    if(sh~=nil and sh.revive_mode_simple==1) then
        
        local isDead = false
        
        --print("table.maxn(m_deadPlayerCardArray):",table.maxn(m_deadPlayerCardArray))
        --print("table.maxn(m_deadPlayerCardArray):",table.maxn(m_deadPlayerCardArray))
        for i=1,table.maxn(m_deadPlayerCardArray) do
            --print("reviveCardByHid m_deadPlayerCardArray:",m_deadPlayerCardArray[i])
            if(m_deadPlayerCardArray[i]==hid)then
                isDead = true
                break
            end
        end
        
        if(isDead)then
            
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_1003") .. (m_revivedTime+1)*1000 .. GetLocalizeStringBy("key_1687"), doReviveCard, true, hid)
            
        end
    end
end

local m_talkCallbackFuncion
local m_talkCallbackId

local function checkDialogChanges()
    print("=============checkDialogChanges===============",m_talkCallbackId)
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    --替换地图
    if(army~=nil and army.dialog_scene_over~=nil)then
        local dialog_ids = army.dialog_scene_over
        local dialog_idArray = lua_string_split(dialog_ids,",")
        for i=1,#dialog_idArray do
            local dialogId = tonumber(lua_string_split(dialog_idArray[i],"|")[1])
            print("--------- dialogRound:",dialogRound)
            if(dialogId ~= nil and m_talkCallbackId == dialogId)then
                local backgroundFile = lua_string_split(dialog_idArray[i],"|")[2]
                print("--------- backgroundFile:",backgroundFile)
                if(backgroundFile~=nil)then
                    print(GetLocalizeStringBy("key_1444")) 

                    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/zhuangchang/zhuangchang"),-1,CCString:create(""))
                    action1:setScale(getScaleParm())
                    action1:setPosition(ccp(g_winSize.width * 0.5 - 640*getScaleParm()*0.5, g_winSize.height * 0.5 + 960*getScaleParm()*0.5))
                    local animationDelegate = BTAnimationEventDelegate:create()
                    action1:setDelegate(animationDelegate)
                    animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
                        action1:removeFromParentAndCleanup(true)
                        action1 = nil
                        initBackground(backgroundFile)
                        showNextArmy()
                        local action2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/heidong/heidong"),-1,CCString:create(""))
                        action2:setPosition(ccp(g_winSize.width *0.5/m_bg:getScale(),g_winSize.height *0.5/m_bg:getScale()))
                        m_enemyCardLayer:addChild(action2,-1)
                    end)
                    local runningScene = CCDirector:sharedDirector():getRunningScene()
                    runningScene:addChild(action1, 1202)
                    
                end
            end
        end
    end
    
    --替换音乐
    if(army~=nil and army.dialog_music_over~=nil)then
        --print("=============army.dialog_music_over===============")
        local dialog_ids = army.dialog_music_over
        local dialog_idArray = lua_string_split(dialog_ids,",")
        for i=1,#dialog_idArray do
            --print("=============dialog_idArray===============")
            local dialogId = tonumber(lua_string_split(dialog_idArray[i],"|")[1])
            --print("--------- dialogRound:",dialogRound)
            if(dialogId ~= nil and m_talkCallbackId == dialogId)then
                --print("=============m_talkCallbackId===============")
                local backgroundFile = lua_string_split(dialog_idArray[i],"|")[2]
                --print("--------- backgroundFile:",backgroundFile)
                if(backgroundFile~=nil)then
                    
                    AudioUtil.playBgm("audio/bgm/" .. backgroundFile)
                end
            end
        end
    end
    
    if(m_talkCallbackFuncion~=nil)then
        pcall(m_talkCallbackFuncion)
    end
end

local function doTalk(talkID,callbackFunc)
    m_talkCallbackFuncion = callbackFunc
    m_talkCallbackId = talkID
    
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    require "script/ui/talk/talkLayer"
    local talkLayer = TalkLayer.createTalkLayer(talkID)
    runningScene:addChild(talkLayer,999999)
    TalkLayer.setCallbackFunction(checkDialogChanges)
end

function showBattlePrepare()
    -- doBattleButton:setVisible(true)
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    if(tonumber(army.type)==2 or m_level == 0)then
        PlayerCardLayerLee.setSwitchable(false)
    else
        PlayerCardLayerLee.setSwitchable(true)
    end
    --直接开启战斗
    -- if(m_currentArmyIndex == 1) then
    --     doBattleCallback(OTBattleData.boy[1])
    -- elseif(m_currentArmyIndex == 2) then
    --     doBattleCallback(OTBattleData.boy[2])
    -- elseif(m_currentArmyIndex == 3) then
    --     doBattleCallback(OTBattleData.boy[3])
    -- end

    if(m_currentArmyIndex == 1) then
        if(UserModel.getUserUtid() == 1) then
            --女
            print(GetLocalizeStringBy("key_1169"))
            doBattleCallback(OTBattleData.girl[1])
        else
            --男
            print(GetLocalizeStringBy("key_2494"))
            doBattleCallback(OTBattleData.boy[1])
        end
    elseif(m_currentArmyIndex == 2) then
        if(UserModel.getUserUtid() == 1) then
            --女
            print(GetLocalizeStringBy("key_1165"))
            doBattleCallback(OTBattleData.girl[2])
        else
            --男
             print(GetLocalizeStringBy("key_2478"))
            doBattleCallback(OTBattleData.boy[2])
        end
    elseif(m_currentArmyIndex == 3) then
        if(UserModel.getUserUtid() == 1) then
            --女
            print(GetLocalizeStringBy("key_1166"))
            doBattleCallback(OTBattleData.girl[3])
        else
            --男
            print(GetLocalizeStringBy("key_2480"))
            doBattleCallback(OTBattleData.boy[3])
        end
    end
    --[[
    local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    cache:addSpriteFramesWithFile("images/battle/effect/heffect_5.plist", "images/battle/effect/heffect_5.png")
    
    local animFrames = CCArray:create();
    animFrames:retain()
    
    for i=10,16 do
        --看PLIST里的图片名字
        local frame = cache:spriteFrameByName( "heffect_5_" .. i .. ".png" );
        if(nil~=frame)then
            animFrames:addObject(frame)
        end
    end
            
    local animation = CCAnimation:createWithSpriteFrames(animFrames,0.1)
            
    cache:removeSpriteFrames()
    animFrames:release()
    
    local temp = CCSprite:create()
        temp:setAnchorPoint(ccp(0.5,0.5))
        temp:setPosition(doBattleButton:getPositionX(),doBattleButton:getPositionY())
        doBattleButton:getParent():getParent():addChild(temp,99999)
        
    temp:runAction(CCRepeatForever:create( CCAnimate:create(animation)))
    --]]
end

function checkPreFightDialog()
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    if(army.dialog_id_pre~=nil)then
        doTalk(tonumber(army.dialog_id_pre),showBattlePrepare)
    else
        showBattlePrepare()
    end
end

function showTitle()
    
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(m_level==1) then
        levelStr = "simple"
        elseif(m_level==2) then
            levelStr = "normal"
            elseif(m_level==3) then
                levelStr = "hard"
            else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
    else
        armyIds = sh["army_ids_" .. levelStr]
    end
    
    local armyIdArray = lua_string_split(armyIds,",")
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    
    tileName = army.display_name
    number1 = m_currentArmyIndex
    number2 = #armyIdArray
    require "script/ui/main/MainScene"
    
    --显示标题
    local title = CCSprite:create(IMG_PATH .. "title/title_bg.png")
    title:setAnchorPoint(ccp(0.5,0.5))
    title:setPosition(battleBaseLayer:getContentSize().width/2,battleBaseLayer:getContentSize().height*0.7)
    title:setCascadeOpacityEnabled(true)
    battleBaseLayer:addChild(title,999,999)
    title:setOpacity(0)
    title:setScale(MainScene.elementScale)
    
    local displayName = CCLabelTTF:create(tileName,g_sFontName,title:getContentSize().height*0.4)
    --local displayName = CCRenderLabel:create(GetLocalizeStringBy("key_1457"), g_sFontName, 36, 0, ccc3( 0x2b, 0x06, 0x00), type_stroke)
    --displayName:setSourceAndTargetColor(ccc3( 0xff, 0xf9, 0xff), ccc3( 0xff, 0xbd, 0x2f));
    displayName:setAnchorPoint(ccp(0.5,0.5))
    displayName:setPosition(title:getContentSize().width/2,title:getContentSize().height*0.7)
    title:addChild(displayName)
    
    local progressLabel = CCLabelTTF:create(GetLocalizeStringBy("key_1343"),g_sFontName,title:getContentSize().height/4)
    progressLabel:setAnchorPoint(ccp(0.5,0.5))
    progressLabel:setPosition(title:getContentSize().width*0.35,title:getContentSize().height*0.25)
    title:addChild(progressLabel)
    
    require "script/libs/LuaCC"
    local currentProgress = LuaCC.createNumberSprite02(IMG_PATH .. "title","" .. number1,15)
    currentProgress:setAnchorPoint(ccp(0.5,0.5))
    currentProgress:setPosition(title:getContentSize().width*0.45,title:getContentSize().height*0.25)
    title:addChild(currentProgress)
    
    local separator = CCSprite:create(IMG_PATH .. "title/separator.png")
    separator:setAnchorPoint(ccp(0.5,0.5))
    separator:setPosition(title:getContentSize().width*0.55,title:getContentSize().height*0.25)
    title:addChild(separator)
    
    local totalProgress = LuaCC.createNumberSprite02(IMG_PATH .. "title","" .. number2,15)
    totalProgress:setAnchorPoint(ccp(0.5,0.5))
    totalProgress:setPosition(title:getContentSize().width*0.6,title:getContentSize().height*0.25)
    title:addChild(totalProgress)
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(0))
    actionArray:addObject(CCFadeOut:create(0))
    actionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
    title:runAction(CCSequence:create(actionArray))
end

function showDefenderVisible()
    --m_currentDefender:setVisible(true)
    
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌
        
        local card_o = nil
        
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            break
        end
    end
    
    for j=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[j]
        if(role.hid==defenderId) then
        card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
        break
    end
end

if(card_o ~= nil) then
    card_o:setVisible(true)
    
end

end

end

function getEnemyCardPointByPosition(position)
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    local startX = 0.20*m_bg:getContentSize().width;
    local startY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale() - cardWidth*2.4;
    
    return ccp(startX+position%3*cardWidth*1.4, startY+math.floor(position/3)*(cardWidth*1.2)*1.2)
end
local function getPlayerCardPointByPosition(position)
    
    return PlayerCardLayerLee.getPointByPosition(position)
end

--展示掉落
local function showDropEffect(hid,worldPoint)
    print("============showDropEffect,",hid,worldPoint.x,worldPoint.y,#m_currentHeroDropArray)
    for i=1,#m_currentHeroDropArray do
        print("showDropEffect do chose:",hid,m_currentHeroDropArray[i].mstId)
        if(tonumber(hid)==tonumber(m_currentHeroDropArray[i].mstId))then
            print("showDropEffect do show:",hid,m_currentHeroDropArray[i].mstId)
            
            --增加顶栏显示
            m_resourceNumber = m_resourceNumber + 1
            if(m_resourceNumber~=nil)then
                --print("change battleResourceLabel:","" .. (currentResSum+1))
                battleResourceLabel:setString("" .. (m_resourceNumber))
            end
            local bgPoint = m_bg:convertToNodeSpace(worldPoint)
            
            local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/fubendiaoluo"), -1,CCString:create(""))
            buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            buffEffectSprite:setPosition(bgPoint);
            m_bg:addChild(buffEffectSprite,99999);
            --buffEffectSprite:setFPS_interval(60)
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
                removeSelf(buffEffectSprite)
            end
            
            local animationFrameChanged = function(frameIndex,xmlSprite)
                
            end
            
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            buffEffectSprite:setDelegate(delegate)
            break
        end
    end
end

local function showCardNumber(node,number,numberType)
    --print("showCardNumber:",number,numberType)
    number = tonumber(number)
    local damageLabel
    if(numberType==0)then
        --掉血为0不显示
        if(number==0)then
            return
        end
        
        --掉血
        local fontWidth = 43
        damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/red","" .. number,fontWidth)
        damageLabel:setAnchorPoint(ccp(0,0.5))
        --print("showCardNumber x:",node:getContentSize().width*0.5,(#tostring(number)*fontWidth)/2)
        damageLabel:setPosition(node:getContentSize().width*0.5-(#tostring(number)*fontWidth)/2,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)
    elseif(numberType==1) then
        
        --加血
        local fontWidth = 43
        damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/green","+" .. number,fontWidth)
        damageLabel:setAnchorPoint(ccp(0,0.5))
        --print("showCardNumber x:",node:getContentSize().width*0.5,(#tostring(number)*fontWidth)/2)
        damageLabel:setPosition(node:getContentSize().width*0.5-(#tostring(number)*fontWidth)/2,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)
    elseif(numberType==2) then
        
        --暴击
        
        --文字部分
        --print("------------- numberType==2 --------------")
        local criticalLabel = CCSprite:create(IMG_PATH .. "number/critical.png")
        criticalLabel:setAnchorPoint(ccp(0.5,0.5))
        criticalLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.5)
        node:addChild(criticalLabel,999)
        criticalLabel:setOpacity(0)
        
        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCFadeIn:create(0.3))
        damageActionArray:addObject(CCDelayTime:create(0.7))
        damageActionArray:addObject(CCFadeOut:create(0.3))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        criticalLabel:runAction(CCSequence:create(damageActionArray))
        --print("------------- numberType==2 --------------")
        
        
        --数字部分
        local fontWidth = 50
        damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/critical","-" .. number,fontWidth)
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getContentSize().width*0.5-(#tostring(number)*fontWidth)/2,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)
        
        elseif(numberType==3) then
            
        --怒气上升
        if(number>=0)then
            damageLabel = CCSprite:create(IMG_PATH .. "number/angerup.png")
        else
            damageLabel = CCSprite:create(IMG_PATH .. "number/angerdown.png")
        end
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)
        elseif(numberType==4) then
            
        --闪避
        damageLabel = CCSprite:create(IMG_PATH .. "number/dodge.png")
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)
    else
        print("showcardnumber showblock")
        --格挡
        damageLabel = CCSprite:create(IMG_PATH .. "number/block.png")
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        --damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.8)
        --node:addChild(damageLabel,9999)
        damageLabel:setPosition(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.8)
        node:getParent():addChild(damageLabel,999999)
        --damageLabel:setOpacity(0)
        
        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCFadeIn:create(0.3))
        damageActionArray:addObject(CCDelayTime:create(1.5))
        damageActionArray:addObject(CCFadeOut:create(0.3))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        damageLabel:runAction(CCSequence:create(damageActionArray))
        return
    end
    ---[[
    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCMoveBy:create(1.0, ccp(0, node:getContentSize().height/2)))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))
    --]]
end


local function updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex)
    
    --print("============updateCardBuff begin===============",m_battleIndex,currentIndex)
    
    enBufferArray = enBufferArray==nil and {} or enBufferArray
    deBufferArray = deBufferArray==nil and {} or deBufferArray
    imBufferArray = imBufferArray==nil and {} or imBufferArray
    bufferArray = bufferArray==nil and {} or bufferArray
    
    --更新消失BUFF
    if(deBufferArray~=nil and #(deBufferArray)>=currentIndex) then
        --print("============deBufferArray begin===============",currentIndex,deBufferArray[currentIndex])
        require "db/DB_Buffer"
        local buff = DB_Buffer.getDataById(deBufferArray[currentIndex])
        --print("---------- start deBufferArray:",buff,buff.removeTimeType,timeType)
        if(buff~=nil and (buff.removeTimeType == timeType or timeType==nil))then
            --print("---------- start deBufferArray 2:",buff,buff.removeTimeType,timeType)
            if(buff.disappearEff~=nil and buff.disappearEff~="")then
                
                local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.disappearEff), -1,CCString:create(""));
                buffEffectSprite:retain()
                buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                
                buffEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                if(isDefenderEnemy) then
                m_enemyCardLayer:addChild(buffEffectSprite,99999);
            else
                m_PlayerCardLayerLee:addChild(buffEffectSprite,99999);
            end
            buffEffectSprite:release()
            
                --delegate
                local animationEnd = function(actionName,xmlSprite)
                
                
                
                --print("----------  deBufferArray updateCardBuff",m_battleIndex,currentIndex)
                --next buff
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                
                if(m_cardBuffArray[card_o:getTag()] == nil)then
                    m_cardBuffArray[card_o:getTag()] = {}
                end
                
                for n=1,#m_cardBuffArray[card_o:getTag()] do
                    if(m_cardBuffArray[card_o:getTag()][n]==buff.id)then
                        m_cardBuffArray[card_o:getTag()][n] = 0
                    end
                end
                --删除buff
                card_o:removeChildByTag(100000+buff.id,true)
                removeSelf(buffEffectSprite)
            end
            
            local animationFrameChanged = function(frameIndex,xmlSprite)
            
        end
        
                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                buffEffectSprite:setDelegate(delegate)
                return
            else
        
        --print("remove buff id:",card_o:getTag(),buff.id)
                --删除buff
                card_o:removeChildByTag(100000+buff.id,true)
        
        --print("----------  deBufferArray updateCardBuff",m_battleIndex,currentIndex)
                --next buff
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
        
                if(m_cardBuffArray[card_o:getTag()] == nil)then
                    m_cardBuffArray[card_o:getTag()] = {}
                end
                
                for n=1,#m_cardBuffArray[card_o:getTag()] do
                    if(m_cardBuffArray[card_o:getTag()][n]==buff.id)then
                        m_cardBuffArray[card_o:getTag()][n] = 0
                    end
                end
                return
            end
        else
            updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
            return
        end
    end

    --更新免疫BUFF
    if(imBufferArray~=nil and #(imBufferArray)>=currentIndex-#(deBufferArray)) then
        
        --print("============imBufferArray begin===============",currentIndex)
        require "db/DB_Buffer"
        local buff = DB_Buffer.getDataById(imBufferArray[currentIndex-#(deBufferArray)])
        if(buff~=nil and (buff.addTimeType == timeType or timeType==nil))then
            
            if(buff.addEff~=nil and buff.addEff~="")then
                
                local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.addEff), -1,CCString:create(""));
                buffEffectSprite:retain()
                buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                
                buffEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                if(isDefenderEnemy) then
                m_enemyCardLayer:addChild(buffEffectSprite,99999);
            else
                m_PlayerCardLayerLee:addChild(buffEffectSprite,99999);
            end
            buffEffectSprite:release()
            
                --delegate
                local animationEnd = function(actionName,xmlSprite)
                
                
                --print("----------  imBufferArray updateCardBuff",m_battleIndex,currentIndex)
                --next buff
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                removeSelf(buffEffectSprite)
            end
            
            local animationFrameChanged = function(frameIndex,xmlSprite)
            
        end

                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                buffEffectSprite:setDelegate(delegate)
                return
            else
        
        --print("----------  imBufferArray updateCardBuff",m_battleIndex,currentIndex)
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                return
            end
else
print("----------  imBufferArray updateCardBuff",m_battleIndex,currentIndex)
            updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
            return
        end
    end

    --更新新增BUFF
    if(enBufferArray~=nil and #(enBufferArray)>=currentIndex-#(deBufferArray)-#(imBufferArray)) then
        
        --print("============enBufferArray begin===============",card_o:getTag(),currentIndex)
        require "db/DB_Buffer"
        local buff = DB_Buffer.getDataById(enBufferArray[currentIndex-#(deBufferArray)-#(imBufferArray)])
        if(buff~=nil and (buff.addTimeType == timeType or timeType==nil))then
            
            if(buff.addEff~=nil and buff.addEff~="")then
                
                local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.addEff), -1,CCString:create(""));
                buffEffectSprite:retain()
                buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                
                buffEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                if(isDefenderEnemy) then
                m_enemyCardLayer:addChild(buffEffectSprite,99999);
            else
                m_PlayerCardLayerLee:addChild(buffEffectSprite,99999);
            end
            buffEffectSprite:release()
            
                --delegate
                local animationEnd = function(actionName,xmlSprite)
                
                    --增加buff
                    if(buff.icon~=nil and buff.icon~="")then
                        local buffSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.icon), -1,CCString:create(""));
                        buffSprite:retain()
                        buffSprite:setAnchorPoint(ccp(0.5, 0));
                        print("enBufferArray add:",buff.positon)
                        ---[[
                        --判断BUFF挂点
                        if(buff.positon==1)then
                            buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.85);
                        elseif(buff.positon==2)then
                            buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.55);
                        else
                            buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.15);
                        end
                        --]]
                        
                        --buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.15);
                        --print("add buff id:",card_o:getTag(),buff.id)
                        card_o:addChild(buffSprite,10,100000+buff.id)
                        buffSprite:release()
                        
                        if(m_cardBuffArray[card_o:getTag()] == nil)then
                            m_cardBuffArray[card_o:getTag()] = {}
                        end
                        --print("add card buff:",card_o:getTag(),buff.id)
                        m_cardBuffArray[card_o:getTag()][#m_cardBuffArray[card_o:getTag()]+1] = buff.id
                        --print("after add card buff size:",#m_cardBuffArray[card_o:getTag()])
                    end
                --print("----------  enBufferArray updateCardBuff",m_battleIndex,currentIndex)
                    --next buff
                    updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                    removeSelf(buffEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
                
            end

                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                buffEffectSprite:setDelegate(delegate)
                return
            else
                
                --增加buff
                if(buff.icon~=nil and buff.icon~="")then
                    local buffSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.icon), -1,CCString:create(""));
                    buffSprite:retain()
                    buffSprite:setAnchorPoint(ccp(0.5, 0));
                    
                    --buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.15);
                    
                    --判断BUFF挂点
                    if(buff.positon==1)then
                        buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.85);
                        elseif(buff.positon==2)then
                        buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.55);
                        else
                        buffSprite:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.15);
                    end
                    
                    card_o:addChild(buffSprite,10,100000+buff.id)
                    buffSprite:release()
                    
                    if(m_cardBuffArray[card_o:getTag()] == nil)then
                        m_cardBuffArray[card_o:getTag()] = {}
                    end
                    
                    --print("add card buff:",card_o:getTag(),buff.id)
                    m_cardBuffArray[card_o:getTag()][#m_cardBuffArray[card_o:getTag()]+1] = buff.id
                    --print("after add card buff size:",#m_cardBuffArray[card_o:getTag()])
                end
        --print("----------  enBufferArray updateCardBuff",m_battleIndex,currentIndex)
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                return
            end
else
print("----------  enBufferArray updateCardBuff",m_battleIndex,currentIndex)
            updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
            return
        end
    end

print("bufferArray size:",#(bufferArray),currentIndex,currentIndex-#(deBufferArray)-#(imBufferArray)-#(enBufferArray))

    --显示BUFF效果
    if(bufferArray~=nil and #(bufferArray)>=currentIndex-#(deBufferArray)-#(imBufferArray)-#(enBufferArray)) then
        --print("111111111111111111111111111")
        local bufferInfo = bufferArray[currentIndex-#(deBufferArray)-#(imBufferArray)-#(enBufferArray)]
        --print("bufferArray:",bufferInfo.type,bufferInfo.data,bufferInfo.bufferId)
        require "db/DB_Buffer"
        local mybuff = DB_Buffer.getDataById(tonumber(bufferInfo.bufferId))
        
        --print("bufferArray:",bufferInfo.type,bufferInfo.data,mybuff.damageTimeType,timeType)
if(mybuff~=nil and (mybuff.damageTimeType == timeType or timeType==nil))then
    --print("go in buff")
        if(bufferInfo.type == 9) then
            
            --print("bufferInfo.type:9")
            --print("--------------------------")
            --print_table("mybuff:",mybuff)
            --print("--------------------------")
            --击中特效
            if(mybuff ~= nil and mybuff.damageEff ~= nil) then
                --音效
                --print("skill.hitEffct:","audio/effect/" .. mybuff.damageEff .. ".mp3",m_currentSkillAttackIndex,i)
                if(file_exists("audio/effect/" .. mybuff.damageEff .. ".mp3")) then
                    
                    AudioUtil.playEffect("audio/effect/" .. mybuff.damageEff .. ".mp3")
                end
                
                local damageEffectSprite
                ---[[
                    --]]
                    if(file_exists("images/battle/effect/" .. mybuff.damageEff .. ".plist")) then
                        damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. mybuff.damageEff), -1,CCString:create(""));
                    else
                        local ef = isDefenderEnemy==true and "images/battle/effect/" .. mybuff.damageEff .. "_u" or "images/battle/effect/" .. mybuff.damageEff .. "_d"
                        damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(ef), -1,CCString:create(""));
                    end
                    --damageEffectSprite:retain()
                    damageEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    damageEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                    --print("damageEffectSprite is 999999",isDefenderEnemy)
                --[[
                    if(isDefenderEnemy) then
                        --print("m_enemyCardLayer:addChild is 999999")
                        m_enemyCardLayer:addChild(damageEffectSprite,999999,card_o:getTag()+5000);
                    else
                        --print("m_PlayerCardLayerLee:addChild is 999999")
                        m_PlayerCardLayerLee:addChild(damageEffectSprite,999999,card_o:getTag()+5000);
                    end
                    --]]
                    card_o:getParent():addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                    --damageEffectSprite:release()
                    
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    --print("buff effect end!")
                    
                --next buff
                --print("----------  BufferArray updateCardBuff",m_battleIndex,currentIndex)
                        updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                        removeSelf(damageEffectSprite)
                    end
                    
                    local animationFrameChanged = function(frameIndex,xmlSprite)
                    
                        --print("buff effect Changed!")
                    end
                    
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    damageEffectSprite = tolua.cast(damageEffectSprite,"CCLayerSprite")
                    damageEffectSprite:setDelegate(delegate)
                    --print("显示BUFF效果 mybuff.damageEff ~= nil")
                end
                --print("show buff value:",bufferInfo.data)
                if(tonumber(bufferInfo.data)>=0)then
                    showCardNumber(card_o,tonumber(bufferInfo.data),1)
                else
                    showCardNumber(card_o,tonumber(bufferInfo.data),0)
                end

                local damage = tonumber(bufferInfo.data)

                --print("buff hid:",hid)
                if(hid~=nil)then
                    
    --print("m_currentHpTable:",m_currentHpTable[hid],damage,m_currentAttacker)
    local afterHp = m_currentHpTable[hid]+damage
    m_currentHpTable[hid] = afterHp
    if(card_o~=nil) then
                --print_table("tb",m_currentHpTable)
                if(afterHp<1) then
                    afterHp = 0
                    card_o:runAction(CCFadeOut:create(1))
                    if(m_currentIsAttackerEnemy == false) then
                        --print("----------------------showDefenderDamage:",node:getTag()%10)
                        --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                        m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. card_o:getTag()%10]
                        --card:removeFromParentAndCleanup(true)
                    end
                    showDropEffect(hid,card_o:convertToWorldSpace(ccp(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.5)))
                end
                BattleCardUtilLee.setCardHp(card_o,afterHp/m_maxHpTable[hid])
            end
        else
            --print("buff hid==nil")
        end
        elseif(bufferInfo.type == 28) then
            --print("bufferInfo.type:28")
            showCardNumber(card_o,tonumber(bufferInfo.data),3)
            local defenderId = hid

            --更新怒气
            if(m_currentAngerTable[defenderId] == nil) then
                m_currentAngerTable[defenderId] = 0
            end
            m_currentAngerTable[defenderId] = m_currentAngerTable[defenderId] + tonumber(bufferInfo.data)
            BattleCardUtilLee.setCardAnger(card_o, m_currentAngerTable[defenderId])
        end

--next buff
if(mybuff == nil or mybuff.damageEff == nil) then
    --print(GetLocalizeStringBy("key_2181"))
    --print("----------  BufferArray updateCardBuff",m_battleIndex,currentIndex)
    updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
end
print(GetLocalizeStringBy("key_2160"))
return false
    
end
end

print("============updateCardBuff done===============",m_battleIndex,currentIndex)
pcall(callbackFunc)
end


local function afterAttackUpdateBuff()
    
    --print("============afterAttackUpdateBuff begin===============")
    
    --[[
     --假BUFF信息
     local enBufferArray = {}
     local deBufferArray = {}
     local imBufferArray = {}
     local bufferArray = {}
     enBufferArray[1] = 441
     deBufferArray[1] = 441
     --更新BUFF
     updateCardBuff(attackerId,m_currentAttacker,2,enBufferArray,deBufferArray,imBufferArray,bufferArray,goToAttackLocation,1)
     --]]
     
     updateCardBuff(attackerId,m_currentAttacker,3,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,showNextMove,1)
 end



 local function goBack()
    --print("=====goBack:",m_battleIndex)
    --print("===========goBack===============")
    
    if(m_currentIsAttackerEnemy) then
        
        local attackerActionArray = CCArray:create()
        --attackerActionArray:addObject(CCMoveTo:create(0.2, ccp(startX+index%3*m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*1.1, startY-math.floor(index/3)*m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*1.1)))
        local position = getEnemyCardPointByPosition(m_currentAttackerIndex)
        attackerActionArray:addObject(CCMoveTo:create(0.2, position))
        --attackerActionArray:addObject(CCCallFunc:create(showNextMove))
        attackerActionArray:addObject(CCCallFunc:create(afterAttackUpdateBuff))
        m_currentAttacker:runAction(CCSequence:create(attackerActionArray))
        
        --m_currentAttacker:setPosition()
    else
        
        local attackerActionArray = CCArray:create()
        --attackerActionArray:addObject(CCMoveTo:create(0.2, ccp(startX+index%3*m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*1.1, startY-math.floor(index/3)*m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*1.1)))
        local position = getPlayerCardPointByPosition(m_currentAttackerIndex)
        attackerActionArray:addObject(CCMoveTo:create(0.2, position))
        --attackerActionArray:addObject(CCCallFunc:create(showNextMove))
        attackerActionArray:addObject(CCCallFunc:create(afterAttackUpdateBuff))
        m_currentAttacker:runAction(CCSequence:create(attackerActionArray))
        
        --m_currentAttacker:setPosition(ccp(startX+index%3*m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*1.1, startY+math.floor(index/3)*m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*1.1))
    end
    
    if(m_currentIsAttackerEnemy)then
        m_enemyCardLayer:reorderChild(m_currentAttacker,5-m_currentAttacker:getTag()+2000)
    else
        m_PlayerCardLayerLee:reorderChild(m_currentAttacker,2)
    end
    --showNextMove()
end

local function updateChildDefendersBuff()

print("===== updateChildDefendersBuff:",m_battleIndex)

    if(m_currentChildSkillIndex==nil or m_currentBattleBlock.arrChild == nil or m_currentBattleBlock.arrChild[m_currentChildSkillIndex] == nil)then
        --showChildBattleAttack()
        return
    end
    
    local currentChildSkillIndex = m_currentChildSkillIndex
if(m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction==nil)then
    --goBack()
    showChildBattleAttack()
    --print("updateChildDefendersBuff showChildBattleAttack")
    return
end

for i=1,#(m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction) do
        --获得反应卡牌
        
    local card_o = nil
    --print("===== updateChildDefendersBuff 2:",m_battleIndex,i,m_currentBattleBlock.arrChild[currentChildSkillIndex])
        --print_table("m_currentBattleBlock",m_currentBattleBlock)
        local defenderId = m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            isDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            isDefenderEnemy = true
                --m_currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        --print("m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].arrDamage:",m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].arrDamage)
        --处理伤害
        if(card_o ~= nil) then
            if(i==1)then
                --print("============updateChildDefendersBuff begin===============")
                
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].enBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].deBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].imBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].buffer,showChildBattleAttack,1)
            else
                
                --print("============updateChildDefendersBuff begin===============")
                
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].enBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].deBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].imBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].buffer,nil,1)
            end
        end
        
    end
end

local function showChildDefenderDamage(node)

print("=========== showChildDefenderDamage:",m_battleIndex)
    ---[[
    
    local isEnemy = true
    if(math.floor(node:getTag()/1000)==4) then
        isEnemy = false
    end
    
    local hid = 0
    
    local damage = 0
    local isFatal = false
    
    local card = nil
    
    --print("-----------------isEnemy:",isEnemy)
    --print("-----------------node:getTag:",node:getTag())
    
    if(isEnemy == true) then
        
        for i=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[i]
            
            --print("-----------------role.position,node:getTag",role.position,(node:getTag()%10))
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
                break
            end
        end
        
    else
        
        for i=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[i]
            --print("-----------------role.position,node:getTag",role.position,(node:getTag()%10))
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
                break
            end
        end
    end
    
    --print("-----------------hid:",hid)
    
    local isManDown = false
    
    for i=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) do
        if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage ~= nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender == hid) then
        
            --print("-----------------m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender:",m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender,hid,m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage.damageValue)
            for j=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage) do
                damage = damage+m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage[j].damageValue
            end
            --判断是否为暴击
            if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].fatal~=nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].fatal == true)then
                isFatal = true
            end
            --判断是否死亡
            
            if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].mandown~=nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].mandown == true)then
                isManDown = true
            end
        end
    end
    
    --print("showDefenderDamage:",m_currentHpTable[hid],damage,card,m_currentSkillAttackIndex)
    --更新hp
    if(m_currentSkillAttackIndex>=m_currentSkillAttackTimes)then
        
        --print("m_currentHpTable:",m_currentHpTable[hid],damage,card)
        local afterHp = m_currentHpTable[hid]-damage
        m_currentHpTable[hid] = afterHp
        if(card~=nil) then
            --print_table("tb",m_currentHpTable)
            --if(afterHp<1 or isManDown == true) then
            if(afterHp<1) then
                afterHp = 0
                card:runAction(CCFadeOut:create(1))
                if(isEnemy == false) then
                    --print("----------------------showDefenderDamage:",node:getTag()%10)
                    --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                    m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. node:getTag()%10]
                    --card:removeFromParentAndCleanup(true)
                end
                showDropEffect(hid,card:convertToWorldSpace(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5)))
            end
            BattleCardUtilLee.setCardHp(card,afterHp/m_maxHpTable[hid])
        end
        
        if(node~=nil) then
            if(afterHp<1) then
                afterHp = 0
            end
            BattleCardUtilLee.setCardHp(node,afterHp/m_maxHpTable[hid])
        end
        
    end
    
    if(m_currentSkillAttackTimes~=0)then
        damage = damage/m_currentSkillAttackTimes
    end
    --print("-----------------damage:",damage)
    
    local fontWidth = 43
    --print("damageLabel:",damage)
    local numberPath = "number/red"
    --print("m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].fatal:",#m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction,m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i],i)
    if(isFatal)then
        numberPath = "number/critical"
        fontWidth = 50
        --print("do the critical")
        local criticalLabel = CCSprite:create(IMG_PATH .. "number/critical.png")
        criticalLabel:setAnchorPoint(ccp(0.5,0))
        criticalLabel:setPosition(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.5)
        --node:addChild(criticalLabel,999999)
        if(isEnemy) then
            m_enemyCardLayer:addChild(criticalLabel,999999)
            else
            m_PlayerCardLayerLee:addChild(criticalLabel,999999)
        end
        criticalLabel:setOpacity(0)
        
        
        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCFadeIn:create(0.3))
        damageActionArray:addObject(CCDelayTime:create(0.7))
        damageActionArray:addObject(CCFadeOut:create(0.3))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        criticalLabel:runAction(CCSequence:create(damageActionArray))
    end
    local damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. numberPath,"-" .. math.ceil(damage),fontWidth)
    damageLabel:setAnchorPoint(ccp(0,0.5))
    damageLabel:setPosition(node:getPositionX()-(#("" .. math.ceil(damage))*fontWidth)/2,node:getPositionY())
    
    if(isEnemy) then
        m_enemyCardLayer:addChild(damageLabel,999999)
    else
        m_PlayerCardLayerLee:addChild(damageLabel,999999)
    end
    
    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCMoveBy:create(1.0, ccp(0, m_currentDefender:getContentSize().height/2)))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))
    --]]
end

local function showChildDefenderEffect()
print("===== showChildDefenderEffect:",m_battleIndex)

local delayTime = 0
    
    if(m_currentChildSkillIndex==nil or m_currentBattleBlock.arrChild == nil or m_currentBattleBlock.arrChild[m_currentChildSkillIndex] == nil)then
        --showChildBattleAttack()
        
        local defenderActionArray = CCArray:create()
        defenderActionArray:addObject(CCDelayTime:create(1))
        defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
        m_bg:runAction(CCSequence:create(defenderActionArray))
        
        return
    end
    
    local currentChildSkillIndex = m_currentChildSkillIndex
    
for i=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) do
        --获得反应卡牌
        
        local card_o = nil
        local isDefenderEnemy = false
        
        local defenderId = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            isDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            isDefenderEnemy = true
            break
        end
    end
    
        --print("m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage:",m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage)
        --处理伤害
        if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage ~= nil and card_o ~= nil) then
            
            card_o:setVisible(false)
            
            local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
            
            require "db/skill"
            local skill = skill.getDataById(skillID);
            
            ---[[
            local card = nil
            if(isDefenderEnemy) then
            card = tolua.cast(m_enemyCardLayer:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
        else
            card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
        end
            --print("hurt sprite:",card)
            if(card == nil)then
                card = createBattleCard(defenderId)
                if(isDefenderEnemy) then
                m_enemyCardLayer:addChild(card,card_o:getZOrder())
            else
                m_PlayerCardLayerLee:addChild(card,card_o:getZOrder())
            end
        end
            --]]
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height*0.5))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            BattleCardUtilLee.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
            
            --更新怒气
            if(m_currentAngerTable[defenderId] == nil) then
            m_currentAngerTable[defenderId] = 0
        end
    BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[defenderId])
    
            --print("CCFileUtils:fullPathForFilename1:",CCFileUtils:sharedFileUtils():fullPathForFilename("hurt.plist"))
            --print("CCFileUtils:fullPathForFilename2:",CCFileUtils:sharedFileUtils():fullPathForFilename("hurt_s.plist"))
            local strTemp = nil
            if(tonumber(skill.mpostionType)==7)then
                if( isDefenderEnemy) then
                strTemp = CCString:create("images/battle/xml/action/hurt2_u_0" )
            else
                strTemp = CCString:create("images/battle/xml/action/hurt2_d_0" )
            end
        else
            if( isDefenderEnemy) then
            strTemp = CCString:create("images/battle/xml/action/hurt1_u_0" )
        else
            strTemp = CCString:create("images/battle/xml/action/hurt1_d_0" )
        end
    end
    local totalFrameNum = card:runXMLAnimation(strTemp);
    card:setColor(ccc3(255,0,0))
    local skillTime = totalFrameNum*card:getFpsInterval()
    
            --print("=========skillTime============",skillTime)
            local defenderActionArray = CCArray:create()
            --defenderActionArray:addObject(CCDelayTime:create(skillTime/2))
            defenderActionArray:addObject(CCCallFuncN:create(showChildDefenderDamage))
            defenderActionArray:addObject(CCDelayTime:create(skillTime))
            --print("showdefendereffect hurt:",m_currentSkillAttackIndex,m_currentSkillAttackTimes,m_battleIndex)
            if(m_currentSkillAttackIndex > m_currentSkillAttackTimes) then
                --print("showdefendereffect m_currentSkillAttackIndex > m_currentSkillAttackTimes:",m_currentSkillAttackIndex,m_currentSkillAttackTimes,skill.id)
            end
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes) then
                --print("do removeCard!")
                defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
                defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
            end
            card:stopAllActions()
            card:runAction(CCSequence:create(defenderActionArray))
            
            local skillHitEffect = skill.hitEffct
            if((m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].reaction == 4))then
                skillHitEffect = "heffect_10"
                showCardNumber(card,GetLocalizeStringBy("key_2305"),5)
            end
            
            delayTime = (delayTime>skillTime) and delayTime or skillTime
            
            ---[[
            --击中特效
            if(skillHitEffect ~= nil and tonumber(skill.mpostionType)~=7) then
                --音效
                --print("skillHitEffect:","audio/effect/" .. skillHitEffect .. ".mp3",m_currentSkillAttackIndex,i)
                if(file_exists("audio/effect/" .. skillHitEffect .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then
                    
                    AudioUtil.playEffect("audio/effect/" .. skillHitEffect .. ".mp3")
                end
                
                local damageEffectSprite
                ---[[
                if(isDefenderEnemy) then
                damageEffectSprite = m_enemyCardLayer:getChildByTag(card_o:getTag()+5000);
            else
                damageEffectSprite = m_PlayerCardLayerLee:getChildByTag(card_o:getTag()+5000);
            end
            
            if(damageEffectSprite == nil) then
                    --]]
                    if(file_exists("images/battle/effect/" .. skillHitEffect .. ".plist")) then
                        damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skillHitEffect), -1,CCString:create(""));
                    else
                        local ef = isDefenderEnemy==true and "images/battle/effect/" .. skillHitEffect .. "_u" or "images/battle/effect/" .. skillHitEffect .. "_d"
                        damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(ef), -1,CCString:create(""));
                    end
                    damageEffectSprite:retain()
                    damageEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    damageEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                    if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                else
                    m_PlayerCardLayerLee:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                end
                damageEffectSprite:release()
                
            end
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    removeSelf(damageEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
            end
            
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            damageEffectSprite = tolua.cast(damageEffectSprite,"CCLayerSprite")
            damageEffectSprite:setDelegate(delegate)
        end
    end
    --]]
    --print("m_currentSkillAttackIndex == m_currentSkillAttackTimes",m_currentSkillAttackIndex,m_currentSkillAttackTimes)
    if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
        local defenderActionArray = CCArray:create()
        defenderActionArray:addObject(CCDelayTime:create(delayTime))
        defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
        defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
        card_o:runAction(CCSequence:create(defenderActionArray))
    end
    elseif(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].reaction == 2) then
    --闪避
    card_o:setVisible(false)
    
    local card = createBattleCard(defenderId)
    card:setTag(card_o:getTag()+3000)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(isDefenderEnemy) then
    m_enemyCardLayer:addChild(card,card_o:getZOrder())
else
    m_PlayerCardLayerLee:addChild(card,card_o:getZOrder())
end
BattleCardUtilLee.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
local strTemp = nil
if( isDefenderEnemy) then
strTemp = CCString:create("images/battle/xml/action/dodge_u" )
else
    strTemp = CCString:create("images/battle/xml/action/dodge_d" )
end
local totalFrameNum = card:runXMLAnimation(strTemp);
local skillTime = totalFrameNum*card:getFpsInterval()

local defenderActionArray = CCArray:create()
defenderActionArray:addObject(CCDelayTime:create(skillTime))
    --if(m_currentSkillAttackIndex == m_currentSkillAttackTimes) then
    defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
    --end
    card:runAction(CCSequence:create(defenderActionArray))
    
    showCardNumber(card,GetLocalizeStringBy("key_2368"),4)
    
    delayTime = (delayTime>skillTime) and delayTime or skillTime
    
    if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes  or m_currentSkillAttackTimes == 0) then
        local defenderActionArray = CCArray:create()
        defenderActionArray:addObject(CCDelayTime:create(delayTime))
        defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
        defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
        card_o:runAction(CCSequence:create(defenderActionArray))
    end
else
    --print("child unknown things here")
    
    if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes  or m_currentSkillAttackTimes == 0) then
        local defenderActionArray = CCArray:create()
        defenderActionArray:addObject(CCDelayTime:create(1.5))
        defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
        defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
        card_o:runAction(CCSequence:create(defenderActionArray))
    end
end

end

end

function showChildAttackTrail()
    --print("=====showChildAttackTrail:",m_battleIndex)
    --print("=========showAttackTrail============")
    ---[[
    if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction == nil) then
        updateChildDefendersBuff()
        return
    end
    
    local delayTime = 0
    
    for i=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) do
        --获得反应卡牌
        
        local card = nil
        local currentIsDefenderEnemy = false
        
        local defenderId = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        
        local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
        
        require "db/skill"
        local skill = skill.getDataById(skillID);
        
        --处理伤害
        if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage ~= nil and card ~= nil and (skill.mpostionType==4 or skill.mpostionType==3) and skill.distancePath~=nil) then
            
            local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));
            
            local endPoint = card:convertToWorldSpace(ccp(card:getContentSize().width*card:getScale()*0.5, card:getContentSize().height*card:getScale()*0.5));
            
            --播放音效
            --print("AudioUtil:","audio/effect/" .. skill.distancePath .. ".mp3")
            if(file_exists("audio/effect/" .. skill.distancePath .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then
                
                AudioUtil.playEffect("audio/effect/" .. skill.distancePath .. ".mp3")
            end
            
            local trailSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.distancePath), -1,CCString:create(""));
            trailSprite:retain()
            --trailSprite:setFlipY(m_currentIsDefenderEnemy);
            trailSprite:setAnchorPoint(ccp(0.5, 0.5));
            trailSprite:setPosition(m_bg:convertToNodeSpace(beginPoint));
            m_bg:addChild(trailSprite,11);
            trailSprite:release()
            if(currentIsDefenderEnemy==false)then
            local frameArray = trailSprite:getChildren()
            for i=0,frameArray:count()-1 do
                local xmlSp = tolua.cast(frameArray:objectAtIndex(i),"CCXMLSprite")
                xmlSp:setFlipY(true)
            end
            end
        
            --local trailDistence = math.abs(endPoint.x-beginPoint.x)+math.abs(endPoint.y-beginPoint.y)
            --local trailTime = trailDistence/1000.0
            local trailTime = 0.3
            -- 移动，移除，调用下个方法
            local trailActionArray = CCArray:create()
            local moveEndPoint = m_bg:convertToNodeSpace(endPoint)
            if(currentIsDefenderEnemy==false) then
            trailSprite:setPositionY(trailSprite:getPositionY()+m_currentAttacker:getContentSize().height);
            moveEndPoint = ccp(moveEndPoint.x,moveEndPoint.y+m_currentAttacker:getContentSize().height)
            end
            trailActionArray:addObject(CCMoveTo:create(trailTime, moveEndPoint))
            trailActionArray:addObject(CCCallFuncN:create(removeSelf))
            --trailActionArray:addObject(CCCallFunc:create(showDefenderEffect))
            trailSprite:runAction(CCSequence:create(trailActionArray));
            
            delayTime = (delayTime>trailTime) and delayTime or trailTime
        end
        
    end
    
    local nextActionArray = CCArray:create()
    nextActionArray:addObject(CCDelayTime:create(delayTime))
    nextActionArray:addObject(CCCallFunc:create(showChildDefenderEffect))
    m_bg:runAction(CCSequence:create(nextActionArray))
end

local function showChildAttackEffect()
    --print("============ showChildAttackEffect ==================",m_battleIndex)
    ---[[
    --释放特效
    
    local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    
    if(skill.attackEffct==nil or skill.attackEffct=="")then
        --print("showAttackEffect skill.attackEffct==nil")
        m_currentSkillAttackIndex = 1
        m_currentSkillAttackTimes = 1
        showChildAttackTrail()
        --[[
        local trailActionArray = CCArray:create()
        trailActionArray:addObject(CCDelayTime:create(1.5))
        trailActionArray:addObject(CCCallFunc:create(updateChildDefendersBuff))
        m_currentAttacker:runAction(CCSequence:create(trailActionArray));
         --]]
        return
    end
    --print("showAttackEffect skill.attackEffct~=nil")
    
    --音效
    --print("skill.attackEffct:","audio/effect/" .. skill.attackEffct .. ".mp3")
    if(skill.attackEffct~=nil and file_exists("audio/effect/" .. skill.attackEffct .. ".mp3")) then
        
        AudioUtil.playEffect("audio/effect/" .. skill.attackEffct .. ".mp3")
    end
    
    --判断释放地点
    if(skill.attackEffctPosition == nil or skill.meffectType ~= 1)then
        
        --释放地点不在对方身上
        
        local spellEffectSprite = nil
        
        if(file_exists("images/battle/effect/" .. skill.attackEffct ..".plist"))then
            spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct), -1,CCString:create(""));
        else
            if(m_currentIsAttackerEnemy) then
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_u"), -1,CCString:create(""));
            else
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_d"), -1,CCString:create(""));
            end
        end
        --spellEffectSprite:retain()
        spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        if(skill.meffectType == nil or skill.meffectType == 1)then
            spellEffectSprite:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()-m_currentAttacker:getContentSize().height/2));
            if(m_currentIsAttackerEnemy) then
                m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
            else
                m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
            end
        else
            
            if(m_currentIsDefenderEnemy) then
                --print("-------------m_currentIsDefenderEnemy")
                local position = getEnemyCardPointByPosition(1)
                spellEffectSprite:setPosition(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5));
                m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
            else
                local position = getPlayerCardPointByPosition(4)
                spellEffectSprite:setPosition(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5));
                m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
            end
        end
        --spellEffectSprite:release()
        
        --m_currentSkillAttackTimes = 1
        
        m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
        m_currentSkillAttackIndex = 0
        
        --delegate
        local animationEnd = function(actionName,xmlSprite)
        
        endShake()
        updateChildDefendersBuff()
        spellEffectSprite:removeFromParentAndCleanup(true)
    end
    
    local animationFrameChanged = function(frameIndex,xmlSprite)
    --print("animationFrameChanged:",frameIndex,xmlSprite)
    local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
    if(tempSprite:getIsKeyFrame()) then
        m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
        showChildAttackTrail()
    end
end

--增加动画监听
local delegate = BTAnimationEventDelegate:create()
delegate:registerLayerEndedHandler(animationEnd)
delegate:registerLayerChangedHandler(animationFrameChanged)
spellEffectSprite:setDelegate(delegate)
--震屏，应该用Ragetype判断,暂时用特效次数
if(m_currentSkillAttackTimes>1) then
    startShake()
end

else

--释放特效为敌人身上
for i=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) do
    --获得反应卡牌
    
    local card_o = nil
    local isDefenderEnemy = false
    
    local defenderId = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender
    for j=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[j]
        if(role.hid==defenderId) then
        card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
        isDefenderEnemy = false
        break
    end
end

for j=1,#(m_battleInfo.team2.arrHero) do
    local role = m_battleInfo.team2.arrHero[j]
    if(role.hid==defenderId) then
    card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
    isDefenderEnemy = true
    break
end
end

    --print("m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage:",m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage)
    --处理伤害
    if(card_o ~= nil) then
        
        
        local spellEffectSprite = nil
        
        if(file_exists("images/battle/effect/" .. skill.attackEffct ..".plist"))then
            spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct), -1,CCString:create(""));
        else
            if(m_currentIsAttackerEnemy) then
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_u"), -1,CCString:create(""));
            else
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_d"), -1,CCString:create(""));
            end
        end
        spellEffectSprite:retain()
        spellEffectSprite:setAnchorPoint(ccp(0.5, 0));
        --判断放置位置
        if(skill.attackEffctPosition==2)then
            --身上
            spellEffectSprite:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()));
            if(m_currentIsAttackerEnemy) then
                m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
            else
                m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
            end
        else
            --脚下
            spellEffectSprite:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height/2));
            if(m_currentIsAttackerEnemy) then
                m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
            else
                m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
            end
        end
        spellEffectSprite:release()
        
        --m_currentSkillAttackTimes = 1
        
        m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
        m_currentSkillAttackIndex = 0
        
        --delegate
        local animationEnd = function(actionName,xmlSprite)
        
        
        endShake()
        updateChildDefendersBuff()
        spellEffectSprite:removeFromParentAndCleanup(true)
    end
    
    local animationFrameChanged = function(frameIndex,xmlSprite)
    --print("animationFrameChanged:",frameIndex,xmlSprite,xmlSprite:getTag())
    local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
    if(tempSprite:getIsKeyFrame()) then
        m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
        showChildAttackTrail()
    end
end

local animationEnd2 = function(actionName,xmlSprite)
spellEffectSprite:removeFromParentAndCleanup(true)
end

local animationFrameChanged2 = function(frameIndex,xmlSprite)
end

--增加动画监听
local delegate = BTAnimationEventDelegate:create()
if(i==1)then
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
else
    delegate:registerLayerEndedHandler(animationEnd2)
    delegate:registerLayerChangedHandler(animationFrameChanged2)
end
spellEffectSprite:setDelegate(delegate)
--震屏，应该用Ragetype判断,暂时用特效次数
if(m_currentSkillAttackTimes>1) then
    startShake()
end

end
end
end

end

showChildBattleAttack = function ()
    
    --print("=====showChildBattleAttack:",m_battleIndex,m_currentChildSkillIndex)
    
    m_currentChildSkillIndex = m_currentChildSkillIndex + 1
    if(m_currentBattleBlock.arrChild == nil or m_currentChildSkillIndex>#m_currentBattleBlock.arrChild)then
        --print("child round done")
        goBack()
        return
    end
--无反应无动作
if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].enBuffer == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].deBuffer == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].imBuffer == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].buffer == nil)then
    --print("child round done2")
    currentRoundOver()
    goBack()
    return
end

    m_currentAttacker:setVisible(false)
    
    local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    
    local card = createBattleCard(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker)
    card:setTag(4000)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(m_currentIsAttackerEnemy) then
        m_enemyCardLayer:addChild(card,m_currentAttacker:getZOrder())
    else
        m_PlayerCardLayerLee:addChild(card,m_currentAttacker:getZOrder())
    end
    BattleCardUtilLee.setCardHp(card,m_currentHpTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker]/m_maxHpTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker])
    
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] = 0
    end
    BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker])
    
    local animationEnd = function()
    
    showAttackerVisible()
    
    
    if(skill.attackEffct==nil or skill.attackEffct=="")then
        --print("showBattleAttack done start updateDefendersBuff")
        --goBack()
        updateChildDefendersBuff()
    end
    card:removeFromParentAndCleanup(true)
end

local animationFrameChanged = function(frameIndex,xmlSprite)
--print("animationFrameChanged:",frameIndex,skill.id,skill.actionid)
local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
if(tempSprite:getIsKeyFrame()) then
    --print("showBattleAttack tempSprite:getIsKeyFrame")
    showChildAttackEffect()
end
end

--增加动画监听
local delegate = BTAnimationEventDelegate:create()
--delegate:retain()
delegate:registerLayerEndedHandler(animationEnd)
delegate:registerLayerChangedHandler(animationFrameChanged)
card:setDelegate(delegate)

--播放音效
if(file_exists("audio/effect/" .. skill.actionid .. ".mp3")) then
    
    AudioUtil.playEffect("audio/effect/" .. skill.actionid .. ".mp3")
end


local totalFrameNum
if(file_exists("images/battle/xml/action/" .. skill.actionid .. ".xml"))then
    totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. skill.actionid));
else
    totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and skill.actionid .. "_u_0" or skill.actionid .. "_d_0")));
end
local skillTime = totalFrameNum*card:getFpsInterval()

--更新怒气
if(m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] == nil) then
    m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] = 0
end
if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].rage ~= nil) then
    m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] = m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] + tonumber(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].rage)
end
BattleCardUtilLee.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker])

end

local function updateDefendersBuff()

print("=====updateDefendersBuff:",m_battleIndex)

if(m_currentBattleBlock.arrReaction==nil)then
    --goBack()
    showChildBattleAttack()
    return
end

for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌
        
        local card_o = nil
        local isDefenderEnemy = false
        
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            isDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            isDefenderEnemy = true
                --m_currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
    
    local isManDown = false
    
    for i=1,#(m_currentBattleBlock.arrReaction) do
        if(m_currentBattleBlock.arrReaction[i].defender == defenderId) then
            if(m_currentBattleBlock.arrReaction[i].mandown~=nil and m_currentBattleBlock.arrReaction[i].mandown == true)then
                isManDown = true
            end
        end
    end
    
        --print("m_currentBattleBlock.arrReaction[i].arrDamage:",m_currentBattleBlock.arrReaction[i].arrDamage)
        --处理伤害
        if(card_o ~= nil and isManDown ~= true) then
            if(i==1)then
                --print("============updateDefendersBuff begin===============")
                
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrReaction[i].enBuffer,m_currentBattleBlock.arrReaction[i].deBuffer,m_currentBattleBlock.arrReaction[i].imBuffer,m_currentBattleBlock.arrReaction[i].buffer,showChildBattleAttack,1)
            else
                
                --print("============updateDefendersBuff begin===============")
                
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrReaction[i].enBuffer,m_currentBattleBlock.arrReaction[i].deBuffer,m_currentBattleBlock.arrReaction[i].imBuffer,m_currentBattleBlock.arrReaction[i].buffer,nil,1)
            end
        elseif(isManDown == true)then
            if(card_o:getOpacity()>240)then
                card_o:stopAllActions()
                card_o:runAction(CCFadeOut:create(1))
                if(isEnemy == false) then
                    m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. card_o:getTag()%10]
                    --card:removeFromParentAndCleanup(true)
                end
                showDropEffect(hid,card_o:convertToWorldSpace(ccp(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.5)))
            end
            if(i==1)then
                showChildBattleAttack()
            end
        end

    end
end

local function showDefenderDamage(node)
    
    
    --print("===========showDefenderDamage:",m_battleIndex)
    ---[[
    
    local isEnemy = true
    if(math.floor(node:getTag()/1000)==4) then
        isEnemy = false
    end
    
    local hid = 0
    
    local damage = 0
    local isFatal = false
    
    local card = nil
    
    --print("-----------------isEnemy:",isEnemy)
    --print("-----------------node:getTag:",node:getTag())
    
    if(isEnemy == true) then
        
        for i=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[i]
            
            --print("-----------------role.position,node:getTag",role.position,(node:getTag()%10))
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
                break
            end
        end
        
    else
        
        for i=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[i]
            --print("-----------------role.position,node:getTag",role.position,(node:getTag()%10))
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
                break
            end
        end
    end
    
    --print("-----------------hid:",hid)
    
    for i=1,#(m_currentBattleBlock.arrReaction) do
        if(m_currentBattleBlock.arrReaction[i].arrDamage ~= nil and m_currentBattleBlock.arrReaction[i].defender == hid) then
        
            --print("-----------------m_currentBattleBlock.arrReaction[i].defender:",m_currentBattleBlock.arrReaction[i].defender,hid,m_currentBattleBlock.arrReaction[i].arrDamage.damageValue)
            for j=1,#(m_currentBattleBlock.arrReaction[i].arrDamage) do
                damage = damage+m_currentBattleBlock.arrReaction[i].arrDamage[j].damageValue
            end
            --判断是否为暴击
            if(m_currentBattleBlock.arrReaction[i].fatal~=nil and m_currentBattleBlock.arrReaction[i].fatal == true)then
                isFatal = true
            end
        end
    end
    
    --print("showDefenderDamage:",m_currentHpTable[hid],damage,card,m_currentSkillAttackIndex)
    --更新hp
    if(m_currentSkillAttackIndex>=m_currentSkillAttackTimes)then
        
        --print("m_currentHpTable:",m_currentHpTable[hid],damage,card)
        local afterHp = m_currentHpTable[hid]-damage
        m_currentHpTable[hid] = afterHp
        if(card~=nil) then
            --print_table("tb",m_currentHpTable)
            if(afterHp<1) then
                afterHp = 0
                card:runAction(CCFadeOut:create(1))
                if(isEnemy == false) then
                    --print("----------------------showDefenderDamage:",node:getTag()%10)
                    --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                    m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. node:getTag()%10]
                    --card:removeFromParentAndCleanup(true)
                end
                showDropEffect(hid,card:convertToWorldSpace(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5)))
            end
            BattleCardUtilLee.setCardHp(card,afterHp/m_maxHpTable[hid])
        end
        
        if(node~=nil) then
            if(afterHp<1) then
                afterHp = 0
            end
            BattleCardUtilLee.setCardHp(node,afterHp/m_maxHpTable[hid])
        end
        
    end
    
    if(m_currentSkillAttackTimes~=0)then
        damage = damage/m_currentSkillAttackTimes
    end
    --print("-----------------damage:",damage)
    
    --showCardNumber(node,math.floor(damage),0)
    
    local fontWidth = 43
    --print("damageLabel:",damage)
    local numberPath = "number/red"
    --print("m_currentBattleBlock.arrReaction[i].fatal:",#m_currentBattleBlock.arrReaction,m_currentBattleBlock.arrReaction[i],i)
    if(isFatal)then
        numberPath = "number/critical"
        fontWidth = 50
        --print("do the critical")
        local criticalLabel = CCSprite:create(IMG_PATH .. "number/critical.png")
        criticalLabel:setAnchorPoint(ccp(0.5,0))
        criticalLabel:setPosition(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.5)
        --node:addChild(criticalLabel,999999)
        if(isEnemy) then
            m_enemyCardLayer:addChild(criticalLabel,999999)
            else
            m_PlayerCardLayerLee:addChild(criticalLabel,999999)
        end
        criticalLabel:setOpacity(0)
        
        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCFadeIn:create(0.3))
        damageActionArray:addObject(CCDelayTime:create(0.7))
        damageActionArray:addObject(CCFadeOut:create(0.3))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        criticalLabel:runAction(CCSequence:create(damageActionArray))
    end
    local damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. numberPath,"-" .. math.ceil(damage),fontWidth)
    damageLabel:setAnchorPoint(ccp(0,0.5))
    damageLabel:setPosition(node:getPositionX()-(#("" .. math.ceil(damage))*fontWidth)/2,node:getPositionY())
    
    --local damageLabel = CCLabelTTF:create("-" .. math.floor(damage),g_sFontName,m_currentDefender:getContentSize().height/2)
    --damageLabel:setColor(ccc3(255, 0, 0))
    --damageLabel:setAnchorPoint(ccp(0.5,0.5))
    --damageLabel:setPosition(ccp(node:getPositionX(),node:getPositionY()))
    if(isEnemy) then
        m_enemyCardLayer:addChild(damageLabel,999999)
    else
        m_PlayerCardLayerLee:addChild(damageLabel,999999)
    end
    
    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCMoveBy:create(1.0, ccp(0, m_currentDefender:getContentSize().height/2)))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))
    --]]
end

local function showDefenderEffect()
print("=====showDefenderEffect:",m_battleIndex)
    --[[
     local defenderActionArray = CCArray:create()
     defenderActionArray:addObject(CCDelayTime:create(0.4))
     defenderActionArray:addObject(CCCallFunc:create(showDefenderDamage))
     defenderActionArray:addObject(CCTintTo:create(0.3,255,0,0))
     defenderActionArray:addObject(CCTintTo:create(0.1,255,255,255))
     defenderActionArray:addObject(CCCallFunc:create(goBack))
     m_currentDefender:runAction(CCSequence:create(defenderActionArray))
     --]]
     
     local delayTime = 0
     
     for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌
        
        local card_o = nil
        local isDefenderEnemy = false
        
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            isDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            isDefenderEnemy = true
                --m_currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        --print("m_currentBattleBlock.arrReaction[i].arrDamage:",m_currentBattleBlock.arrReaction[i].arrDamage)
        --处理伤害
        if(m_currentBattleBlock.arrReaction[i].arrDamage ~= nil and card_o ~= nil) then
            --goBack()
            --return
            
            card_o:setVisible(false)
            
            local skillID = m_currentBattleBlock.action
            
            require "db/skill"
            local skill = skill.getDataById(skillID);
            ---[[
            --print("m_currentDefender:getreplaceFileName():",m_currentDefender:getreplaceFileName())
            --local card = CCXMLSprite:create(m_currentDefender:getreplaceFileName():getCString())
            --card:retain()
            --card:initXMLSprite(CCString:create(m_currentDefender:getreplaceFileName():getCString()));
            
            --local card = createBattleCard(defenderId)
            ---[[
            local card = nil
            if(isDefenderEnemy) then
            card = tolua.cast(m_enemyCardLayer:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
        else
            card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
        end
            --print("hurt sprite:",card)
            if(card == nil)then
                card = createBattleCard(defenderId)
                if(isDefenderEnemy) then
                m_enemyCardLayer:addChild(card,card_o:getZOrder())
            else
                m_PlayerCardLayerLee:addChild(card,card_o:getZOrder())
            end
        end
            --]]
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height*0.5))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            BattleCardUtilLee.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
            
            --更新怒气
            if(m_currentAngerTable[defenderId] == nil) then
            m_currentAngerTable[defenderId] = 0
        end
    BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[defenderId])
    
            --print("CCFileUtils:fullPathForFilename1:",CCFileUtils:sharedFileUtils():fullPathForFilename("hurt.plist"))
            --print("CCFileUtils:fullPathForFilename2:",CCFileUtils:sharedFileUtils():fullPathForFilename("hurt_s.plist"))
            local strTemp = nil
            if(tonumber(skill.mpostionType)==7)then
                if( isDefenderEnemy) then
                strTemp = CCString:create("images/battle/xml/action/hurt2_u_0" )
            else
                strTemp = CCString:create("images/battle/xml/action/hurt2_d_0" )
            end
        else
            if( isDefenderEnemy) then
            strTemp = CCString:create("images/battle/xml/action/hurt1_u_0" )
        else
            strTemp = CCString:create("images/battle/xml/action/hurt1_d_0" )
        end
    end
    local totalFrameNum = card:runXMLAnimation(strTemp);
    card:setColor(ccc3(255,0,0))
    local skillTime = totalFrameNum*card:getFpsInterval()
    
            --print("=========skillTime============",skillTime)
            local defenderActionArray = CCArray:create()
            --defenderActionArray:addObject(CCDelayTime:create(skillTime/2))
            defenderActionArray:addObject(CCCallFuncN:create(showDefenderDamage))
            defenderActionArray:addObject(CCDelayTime:create(skillTime))
            --print("showdefendereffect hurt:",m_currentSkillAttackIndex,m_currentSkillAttackTimes,m_battleIndex)
            if(m_currentSkillAttackIndex > m_currentSkillAttackTimes) then
                --print("showdefendereffect m_currentSkillAttackIndex > m_currentSkillAttackTimes:",m_currentSkillAttackIndex,m_currentSkillAttackTimes,skill.id)
            end
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes) then
                --print("do removeCard!")
                defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
                --defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
            end
            card:stopAllActions()
            card:runAction(CCSequence:create(defenderActionArray))
            
            local skillHitEffect = skill.hitEffct
            
            if((m_currentBattleBlock.arrReaction[i].reaction == 4))then
                
                skillHitEffect = "heffect_10"
                showCardNumber(card,GetLocalizeStringBy("key_2305"),5)
            end
            
            delayTime = (delayTime>skillTime) and delayTime or skillTime
            
            ---[[
             --击中特效
             if(skillHitEffect ~= nil and tonumber(skill.mpostionType)~=7) then
                --音效
                --print("skillHitEffect:","audio/effect/" .. skillHitEffect .. ".mp3",m_currentSkillAttackIndex,i)
                if(file_exists("audio/effect/" .. skillHitEffect .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then
                    
                    AudioUtil.playEffect("audio/effect/" .. skillHitEffect .. ".mp3")
                end
                
                local damageEffectSprite
                ---[[
                if(isDefenderEnemy) then
                damageEffectSprite = m_enemyCardLayer:getChildByTag(card_o:getTag()+5000);
            else
                damageEffectSprite = m_PlayerCardLayerLee:getChildByTag(card_o:getTag()+5000);
            end
            
            if(damageEffectSprite == nil) then
                    --]]
                    if(file_exists("images/battle/effect/" .. skillHitEffect .. ".plist")) then
                        damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skillHitEffect), -1,CCString:create(""));
                    else
                        local ef = isDefenderEnemy==true and "images/battle/effect/" .. skillHitEffect .. "_u" or "images/battle/effect/" .. skillHitEffect .. "_d"
                        damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(ef), -1,CCString:create(""));
                    end
                    damageEffectSprite:retain()
                    damageEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    damageEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                    if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                else
                    m_PlayerCardLayerLee:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                end
                damageEffectSprite:release()
                
            end
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    removeSelf(damageEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
            end
            
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    damageEffectSprite = tolua.cast(damageEffectSprite,"CCLayerSprite")
                    damageEffectSprite:setDelegate(delegate)
                end
            end
             --]]
            --print("m_currentSkillAttackIndex == m_currentSkillAttackTimes",m_currentSkillAttackIndex,m_currentSkillAttackTimes)
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
                local defenderActionArray = CCArray:create()
                defenderActionArray:addObject(CCDelayTime:create(delayTime))
                defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
                if(m_currentBattleBlock.arrChild==nil)then
                    defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
                end
                card_o:runAction(CCSequence:create(defenderActionArray))
            end
            elseif(m_currentBattleBlock.arrReaction[i].reaction == 2) then
            --闪避
            card_o:setVisible(false)
            
            local card = createBattleCard(defenderId)
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            if(isDefenderEnemy) then
            m_enemyCardLayer:addChild(card,card_o:getZOrder())
        else
            m_PlayerCardLayerLee:addChild(card,card_o:getZOrder())
        end
        BattleCardUtilLee.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
        local strTemp = nil
        if( isDefenderEnemy) then
            strTemp = CCString:create("images/battle/xml/action/dodge_u" )
        else
            strTemp = CCString:create("images/battle/xml/action/dodge_d" )
        end
        local totalFrameNum = card:runXMLAnimation(strTemp);
        local skillTime = totalFrameNum*card:getFpsInterval()
        
        local defenderActionArray = CCArray:create()
        defenderActionArray:addObject(CCDelayTime:create(skillTime))
            --if(m_currentSkillAttackIndex == m_currentSkillAttackTimes) then
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
            --end
            card:runAction(CCSequence:create(defenderActionArray))
            
            showCardNumber(card,GetLocalizeStringBy("key_2368"),4)
            
            delayTime = (delayTime>skillTime) and delayTime or skillTime
    
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes  or m_currentSkillAttackTimes == 0) then
                local defenderActionArray = CCArray:create()
                defenderActionArray:addObject(CCDelayTime:create(delayTime))
                defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
                if(m_currentBattleBlock.arrChild==nil)then
                    defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
                end
                card_o:runAction(CCSequence:create(defenderActionArray))
            end
        else
            --print("unknown things here",m_currentBattleBlock.arrReaction[i].reaction)
            
            if(m_currentBattleBlock.arrChild==nil)then
                currentRoundOver()
            end
            --[[
            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(2))
            defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
            defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
            card_o:runAction(CCSequence:create(defenderActionArray))
             --]]
            --setNodeVisible(card_o)
            --currentRoundOver()
        end

    end

    --print("=========showDefenderEffect============",delayTime)
    
    --[[
    local defenderActionArray = CCArray:create()
    defenderActionArray:addObject(CCDelayTime:create(delayTime))
    defenderActionArray:addObject(CCCallFunc:create(BattleLayerLee.showDefenderVisible))
    --defenderActionArray:addObject(CCCallFunc:create(goBack))
    m_bg:runAction(CCSequence:create(defenderActionArray))
    --]]
end

function showAttackTrail()
    --print("=====showAttackTrail:",m_battleIndex)
    --print("=========showAttackTrail============")
    ---[[
    if(m_currentBattleBlock.arrReaction == nil) then
        --goBack()
        updateDefendersBuff()
        return
    end
    
    local delayTime = 0
    
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌
        
        local card = nil
        local currentIsDefenderEnemy = false
        
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        --处理buff
        --[[
         --不在此处处理
        if(m_currentBattleBlock.arrReaction[i].buffer ~= nil and card ~= nil) then
            --buff类型判断
            if(m_currentBattleBlock.arrReaction[i].type == 28) then
                showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,3)
            elseif(m_currentBattleBlock.arrReaction[i].type == 9 and tonumber(m_currentBattleBlock.arrReaction[i].buffer[1].data)>0)then
                --加血BUFF
                
                local damage = tonumber(m_currentBattleBlock.arrReaction[i].buffer[1].data)
                local hid = defenderId
                --print("m_currentHpTable:",m_currentHpTable[hid],damage,m_currentAttacker)
                local afterHp = m_currentHpTable[hid]+damage
                m_currentHpTable[hid] = afterHp
                --print_table("tb",m_currentHpTable)
                if(afterHp<1) then
                    afterHp = 0
                    card:runAction(CCFadeOut:create(1))
                    if(currentIsDefenderEnemy == false) then
                        --print("----------------------showDefenderDamage:",node:getTag()%10)
                        --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                        m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. m_currentAttacker:getTag()%10]
                        --card:removeFromParentAndCleanup(true)
                    end
                end
                BattleCardUtilLee.setCardHp(card,afterHp/m_maxHpTable[hid])
                
                showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,1)
            else
                
                local damage = tonumber(m_currentBattleBlock.arrReaction[i].buffer[1].data)
                local hid = defenderId
                --print("m_currentHpTable:",m_currentHpTable[hid],damage,m_currentAttacker)
                local afterHp = m_currentHpTable[hid]+damage
                m_currentHpTable[hid] = afterHp
                --print_table("tb",m_currentHpTable)
                if(afterHp<1) then
                    afterHp = 0
                    card:runAction(CCFadeOut:create(1))
                    if(currentIsDefenderEnemy == false) then
                        --print("----------------------showDefenderDamage:",node:getTag()%10)
                        --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                        m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. m_currentAttacker:getTag()%10]
                        --card:removeFromParentAndCleanup(true)
                    end
                end
                BattleCardUtilLee.setCardHp(card,afterHp/m_maxHpTable[hid])
                
                showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,0)
            end
            delayTime = (delayTime>0.1) and delayTime or 0.1
        end
        --]]
        
        local skillID = m_currentBattleBlock.action
        
        require "db/skill"
        local skill = skill.getDataById(skillID);
        
        --处理伤害
        if(m_currentBattleBlock.arrReaction[i].arrDamage ~= nil and card ~= nil and (skill.mpostionType==4 or skill.mpostionType==3) and skill.distancePath~=nil) then
            
            local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));
            
            local endPoint = card:convertToWorldSpace(ccp(card:getContentSize().width*card:getScale()*0.5, card:getContentSize().height*card:getScale()*0.5));
            
            --[[
            local trailSprite
            if(file_exists("images/battle/effect/" .. skill.distancePath .. ".plist"))then
                local trailSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.distancePath), -1,CCString:create(""));
            else
                
            end
            --]]
            
            --播放音效
            --print("AudioUtil:","audio/effect/" .. skill.distancePath .. ".mp3")
            if(file_exists("audio/effect/" .. skill.distancePath .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then
                
                AudioUtil.playEffect("audio/effect/" .. skill.distancePath .. ".mp3")
            end
            
            local trailSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.distancePath), -1,CCString:create(""));
            trailSprite:retain()
            --trailSprite:setFlipY(m_currentIsDefenderEnemy);
            trailSprite:setAnchorPoint(ccp(0.5, 0.5));
            trailSprite:setPosition(m_bg:convertToNodeSpace(beginPoint));
            m_bg:addChild(trailSprite,11);
            trailSprite:release()
            if(currentIsDefenderEnemy==false)then
            local frameArray = trailSprite:getChildren()
            for i=0,frameArray:count()-1 do
                local xmlSp = tolua.cast(frameArray:objectAtIndex(i),"CCXMLSprite")
                xmlSp:setFlipY(true)
            end
        end
        
            --local trailDistence = math.abs(endPoint.x-beginPoint.x)+math.abs(endPoint.y-beginPoint.y)
            --local trailTime = trailDistence/1000.0
            local trailTime = 0.3
            -- 移动，移除，调用下个方法
            local trailActionArray = CCArray:create()
            local moveEndPoint = m_bg:convertToNodeSpace(endPoint)
            if(currentIsDefenderEnemy==false) then
            trailSprite:setPositionY(trailSprite:getPositionY()+m_currentAttacker:getContentSize().height);
            moveEndPoint = ccp(moveEndPoint.x,moveEndPoint.y+m_currentAttacker:getContentSize().height)
        end
        trailActionArray:addObject(CCMoveTo:create(trailTime, moveEndPoint))
        trailActionArray:addObject(CCCallFuncN:create(removeSelf))
            --trailActionArray:addObject(CCCallFunc:create(showDefenderEffect))
            trailSprite:runAction(CCSequence:create(trailActionArray));
            
            delayTime = (delayTime>trailTime) and delayTime or trailTime
        end
        
    end
    
    --if(delayTime==0) then
    --    goBack()
    --else
    local nextActionArray = CCArray:create()
    nextActionArray:addObject(CCDelayTime:create(delayTime))
    nextActionArray:addObject(CCCallFunc:create(showDefenderEffect))
    m_bg:runAction(CCSequence:create(nextActionArray))
    --end
    --]]
    
    --[[
     --老版
     if(m_currentBattleBlock.arrReaction[1].arrDamage == nil) then
     goBack()
     return
     end
     
     local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));
     
     local endPoint = m_currentDefender:convertToWorldSpace(ccp(m_currentDefender:getContentSize().width*m_currentDefender:getScale()*0.5, m_currentDefender:getContentSize().height*m_currentDefender:getScale()*0.5));
     
     local result = CCAnimation:create();
     
     for i=1,10 do
     local fileName = string.format(IMG_PATH .. "skill/trail/trail_%04i.png",i)
     result:addSpriteFrameWithFileName(fileName);
     end
     
     result:setDelayPerUnit(0.1);
     result:setRestoreOriginalFrame(false);
     
     local trailSprite = CCSprite:create();
     trailSprite:setFlipY(m_currentIsDefenderEnemy);
     trailSprite:setAnchorPoint(ccp(0.5, 0.7));
     trailSprite:setPosition(m_bg:convertToNodeSpace(beginPoint));
     trailSprite:setScale(0.6);
     
     --trailSprite:setRotation(20);
     
     m_bg:addChild(trailSprite,9);
     
     -- 动画
     trailSprite:runAction(CCAnimate:create(result));
     
     -- 移动，移除，调用下个方法
     local trailActionArray = CCArray:create()
     trailActionArray:addObject(CCMoveTo:create(0.5, m_bg:convertToNodeSpace(endPoint)))
     trailActionArray:addObject(CCCallFuncN:create(removeSelf))
     trailActionArray:addObject(CCCallFunc:create(showDefenderEffect))
     trailSprite:runAction(CCSequence:create(trailActionArray));
     --]]
 end

 local function showAttackEffect()
    --print("============showAttackEffect==================",m_battleIndex)
    ---[[
    --释放特效
    --print("=====showAttackEffect:",m_battleIndex)
    
    local skillID = m_currentBattleBlock.action
    
    require "db/skill"
    local skill = skill.getDataById(skillID);

    if(skill==nil or skill.attackEffct==nil or skill.attackEffct=="")then
        --print("showAttackEffect skill.attackEffct==nil")
        m_currentSkillAttackIndex = 1
        m_currentSkillAttackTimes = 1
        showAttackTrail()
        --endShake()
        --goBack()
        
        --[[
        local trailActionArray = CCArray:create()
        trailActionArray:addObject(CCDelayTime:create(0.5))
        trailActionArray:addObject(CCCallFunc:create(goBack))
        m_currentAttacker:runAction(CCSequence:create(trailActionArray));
        --]]
        return
    end
    --print("showAttackEffect skill.attackEffct~=nil")
    
    --音效
    --print("skill.attackEffct:","audio/effect/" .. skill.attackEffct .. ".mp3")
    if(skill.attackEffct~=nil and file_exists("audio/effect/" .. skill.attackEffct .. ".mp3")) then
        
        AudioUtil.playEffect("audio/effect/" .. skill.attackEffct .. ".mp3")
    end
    
    --判断释放地点
    if(skill.attackEffctPosition == nil or skill.meffectType ~= 1)then
        
        --释放地点不在对方身上
        
    --if(skill.attackEffct ~= nil) then
    local spellEffectSprite = nil
    
    if(file_exists("images/battle/effect/" .. skill.attackEffct ..".plist"))then
        spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct), -1,CCString:create(""));
    else
        if(m_currentIsAttackerEnemy) then
            spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_u"), -1,CCString:create(""));
        else
            spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_d"), -1,CCString:create(""));
        end
    end
    spellEffectSprite:retain()
    spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
    if(skill.meffectType == nil or skill.meffectType == 1)then
        spellEffectSprite:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()-m_currentAttacker:getContentSize().height/2));
        if(m_currentIsAttackerEnemy) then
            m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
        else
            m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
        end
    else
        
        if(m_currentIsDefenderEnemy) then
            --print("-------------m_currentIsDefenderEnemy")
            local position = getEnemyCardPointByPosition(1)
            spellEffectSprite:setPosition(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5));
            m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
        else
            local position = getPlayerCardPointByPosition(4)
            spellEffectSprite:setPosition(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5));
            m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
        end
    end
    spellEffectSprite:release()
    
    --m_currentSkillAttackTimes = 1
    
    m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
    m_currentSkillAttackIndex = 0
    
    --delegate
    local animationEnd = function(actionName,xmlSprite)
        --showAttackTrail()
        --removeSelf(spellEffectSprite)
    --print("animationEnd:",spellEffectSprite,xmlSprite)
    
    endShake()
    --goBack()
    updateDefendersBuff()
    spellEffectSprite:removeFromParentAndCleanup(true)
    --xmlSprite:getParent():removeFromParentAndCleanup(true)
end

local animationFrameChanged = function(frameIndex,xmlSprite)
    --print("animationFrameChanged:",frameIndex,xmlSprite)
    local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
    if(tempSprite:getIsKeyFrame()) then
        --print("animationFrameChanged:",frameIndex,m_battleIndex)
        --showAttackTrail()
        --showAttackEffect()
        m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
        --print("showattackeffect start showAttackTrail 2656")
        showAttackTrail()
    end
end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    spellEffectSprite:setDelegate(delegate)
    --震屏，应该用Ragetype判断,暂时用特效次数
    if(m_currentSkillAttackTimes>1) then
        startShake()
    end

else

if(m_currentBattleBlock.arrReaction==nil)then
    m_currentSkillAttackTimes = 1
    m_currentSkillAttackIndex = 1
    showAttackTrail()
    return
end

    --释放特效为敌人身上
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌
        
        local card_o = nil
        local isDefenderEnemy = false
        
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            isDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            isDefenderEnemy = true
                --m_currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        --print("m_currentBattleBlock.arrReaction[i].arrDamage:",m_currentBattleBlock.arrReaction[i].arrDamage)
        --处理伤害
        if(card_o ~= nil) then
            
            
            local spellEffectSprite = nil
            
            if(file_exists("images/battle/effect/" .. skill.attackEffct ..".plist"))then
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct), -1,CCString:create(""));
            else
                if(m_currentIsAttackerEnemy) then
                    spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_u"), -1,CCString:create(""));
                else
                    spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.attackEffct .."_d"), -1,CCString:create(""));
                end
            end
            spellEffectSprite:retain()
            spellEffectSprite:setAnchorPoint(ccp(0.5, 0));
            --判断放置位置
            if(skill.attackEffctPosition==2)then
                --身上
                spellEffectSprite:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()));
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
                else
                    m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
                end
            else
                --脚下
                spellEffectSprite:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height/2));
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
                else
                    m_PlayerCardLayerLee:addChild(spellEffectSprite,9999,9182);
                end
            end
            spellEffectSprite:release()
            
            --m_currentSkillAttackTimes = 1
            
            m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
            m_currentSkillAttackIndex = 0
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
            --showAttackTrail()
            --removeSelf(spellEffectSprite)
            --print("animationEnd:",spellEffectSprite,xmlSprite)
            
            --goBack()
            
            endShake()
            updateDefendersBuff()
            spellEffectSprite:removeFromParentAndCleanup(true)
            --xmlSprite:getParent():removeFromParentAndCleanup(true)
        end
print("show attacteffect show one")
        local animationFrameChanged = function(frameIndex,xmlSprite)
            --print("animationFrameChanged:",frameIndex,xmlSprite,xmlSprite:getTag())
            local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
            if(tempSprite:getIsKeyFrame()==true) then
                    --print("animationFrameChanged2:",frameIndex,m_battleIndex)
                    --showAttackTrail()
                    --showAttackEffect()
                    m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
                --print("show attacteffect start showAttackTrail",frameIndex)
                    showAttackTrail()
                end
            end

            local animationEnd2 = function(actionName,xmlSprite)
            spellEffectSprite:removeFromParentAndCleanup(true)
            end

            local animationFrameChanged2 = function(frameIndex,xmlSprite)
            end

            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            if(i==1)then
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
            else
                delegate:registerLayerEndedHandler(animationEnd2)
                delegate:registerLayerChangedHandler(animationFrameChanged2)
            end
            spellEffectSprite:setDelegate(delegate)
            --震屏，应该用Ragetype判断,暂时用特效次数
            if(m_currentSkillAttackTimes>1) then
                startShake()
            end

        end
    end
end

end

local function flyAttackCrush(xmlSprite)
    
    --print("=====flyAttackCrush:",m_battleIndex)
    if(file_exists("audio/effect/" .. "zhuangjitx" .. ".mp3")) then
        
        AudioUtil.playEffect("audio/effect/" .. "zhuangjitx" .. ".mp3")
    end
    xmlSprite:setPositionY(xmlSprite:getPositionY()-xmlSprite:getContentSize().height*0.6)
    
    --print("flyAttackCrush startShake")
    startShake()
    
    local animationEnd = function()
    --print("flyAttackCrush animationEnd")
    endShake()
    showAttackerVisible()
    
        --goBack()
        if(xmlSprite:getTag()==12121)then
            updateDefendersBuff()
        end
        xmlSprite:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
    
end


    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)

    xmlSprite = tolua.cast(xmlSprite,"CCXMLSprite")
    xmlSprite:setDelegate(delegate)

    xmlSprite:setBasePoint(ccp(xmlSprite:getPositionX(),xmlSprite:getPositionY()));
    xmlSprite:runXMLAnimation(CCString:create("images/battle/xml/action/T003_d2_0"))

    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = skill.getDataById(skillID);
    --击中特效
    if(skill.hitEffct ~= nil ) then
        local damageEffectSprite
        if(file_exists("images/battle/effect/" .. skill.hitEffct .. ".plist")) then
            damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.hitEffct), -1,CCString:create(""));
        else
            local ef = isDefenderEnemy==true and "images/battle/effect/" .. skill.hitEffct .. "_u" or "images/battle/effect/" .. skill.hitEffct .. "_d"
            damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(ef), -1,CCString:create(""));
        end
        damageEffectSprite:retain()
        damageEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        
        damageEffectSprite:setPosition(xmlSprite:getPositionX(),xmlSprite:getPositionY()+xmlSprite:getContentSize().height*0.5);
        m_bg:addChild(damageEffectSprite,99999);
        damageEffectSprite:release()
        --[[
        local damageEffectActionArray = CCArray:create()
        damageEffectActionArray:addObject(CCDelayTime:create(damageEffectSprite:getAnimationTime()))
        damageEffectActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
        damageEffectSprite:runAction(CCSequence:create(damageEffectActionArray))
        --]]
        
        --delegate
        local animationEnd = function(actionName,xmlSprite)
        removeSelf(damageEffectSprite)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
end

        --增加动画监听
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(animationEnd)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        damageEffectSprite = tolua.cast(damageEffectSprite,"CCLayerSprite")
        damageEffectSprite:setDelegate(delegate)
    end
end

local function flyAttack()
    --print("=====flyAttack:",m_battleIndex)
    if(m_currentBattleBlock.arrReaction == nil) then
        --goBack()
        updateDefendersBuff()
        return
    end
    
    local delayTime = 0
    
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌
        
        local card = nil
        local currentIsDefenderEnemy = nil
        
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
            card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            currentIsDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
            card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            currentIsDefenderEnemy = true
                --m_currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position
                break
            end
        end
        
        --处理buff
        --[[
         --不在此处处理
        if(m_currentBattleBlock.arrReaction[i].buffer ~= nil and card ~= nil) then
            
            --showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,3)
            
            if(m_currentBattleBlock.arrReaction[i].type == 28) then
                showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,3)
            elseif(m_currentBattleBlock.arrReaction[i].type == 9 and tonumber(m_currentBattleBlock.arrReaction[i].buffer[1].data)>0)then
                
                local damage = tonumber(m_currentBattleBlock.arrReaction[i].buffer[1].data)
                local hid = defenderId
                --print("m_currentHpTable:",m_currentHpTable[hid],damage,m_currentAttacker)
                local afterHp = m_currentHpTable[hid]+damage
                m_currentHpTable[hid] = afterHp
                --print_table("tb",m_currentHpTable)
                if(afterHp<1) then
                    afterHp = 0
                    card:runAction(CCFadeOut:create(1))
                    if(currentIsDefenderEnemy == false) then
                        --print("----------------------showDefenderDamage:",node:getTag()%10)
                        --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                        m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. m_currentAttacker:getTag()%10]
                        --card:removeFromParentAndCleanup(true)
                    end
                end
                BattleCardUtilLee.setCardHp(card,afterHp/m_maxHpTable[hid])
                
                showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,1)
            else
                
                local damage = tonumber(m_currentBattleBlock.arrReaction[i].buffer[1].data)
                local hid = defenderId
                --print("m_currentHpTable:",m_currentHpTable[hid],damage,m_currentAttacker)
                local afterHp = m_currentHpTable[hid]+damage
                m_currentHpTable[hid] = afterHp
                --print_table("tb",m_currentHpTable)
                if(afterHp<1) then
                    afterHp = 0
                    card:runAction(CCFadeOut:create(1))
                    if(currentIsDefenderEnemy == false) then
                        --print("----------------------showDefenderDamage:",node:getTag()%10)
                        --print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                        m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. m_currentAttacker:getTag()%10]
                        --card:removeFromParentAndCleanup(true)
                    end
                end
                BattleCardUtilLee.setCardHp(card,afterHp/m_maxHpTable[hid])
                
                showCardNumber(card,m_currentBattleBlock.arrReaction[i].buffer[1].data,0)
            end
            delayTime = (delayTime>0.1) and delayTime or 0.1
        end
        --]]
        
        local skillID = m_currentBattleBlock.action
        
        require "db/skill"
        local skill = skill.getDataById(skillID);
        
        --处理伤害
        if(card ~= nil) then
            
            local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));
            
            local endPoint = card:convertToWorldSpace(ccp(card:getContentSize().width*card:getScale()*0.5, card:getContentSize().height*card:getScale()*0.2));
            
            
            local trailSprite = createBattleCard(m_currentBattleBlock.attacker)
            trailSprite:retain()
            trailSprite:setAnchorPoint(ccp(0.5, 0.5));
            trailSprite:setPosition(m_bg:convertToNodeSpace(beginPoint));
            trailSprite:setBasePoint(ccp(trailSprite:getPositionX(),trailSprite:getPositionY()));
            m_bg:addChild(trailSprite);
            trailSprite:release()
            
            if(i==1)then
                trailSprite:setTag(12121)
            end
            
            --local trailDistence = math.abs(endPoint.x-beginPoint.x)+math.abs(endPoint.y-beginPoint.y)
            --local trailTime = trailDistence/1000.0
            local trailTime = 0.1
            -- 移动，移除，调用下个方法
            local trailActionArray = CCArray:create()
            trailActionArray:addObject(CCMoveTo:create(trailTime, m_bg:convertToNodeSpace(endPoint)))
            trailActionArray:addObject(CCCallFuncN:create(flyAttackCrush))
            trailSprite:runAction(CCSequence:create(trailActionArray));
            
            startShake()
            delayTime = (delayTime>trailTime) and delayTime or trailTime
        else
            --print("fly attack target is null:",defenderId)
        end
        
    end
    
    local nextActionArray = CCArray:create()
    nextActionArray:addObject(CCDelayTime:create(delayTime))
    nextActionArray:addObject(CCCallFunc:create(showDefenderEffect))
    m_bg:runAction(CCSequence:create(nextActionArray))
end

local function showFlyAttack()
    
    --print("=====showFlyAttack:",m_battleIndex)
    m_currentAttacker:setVisible(false)
    
    local skillID = m_currentBattleBlock.action
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    ---[[
    --print("m_currentAttacker:getreplaceFileName():",m_currentAttacker:getreplaceFileName())
    --local card = CCXMLSprite:create(m_currentAttacker:getreplaceFileName():getCString())
    --card:retain()
    --card:initXMLSprite(CCString:create(m_currentAttacker:getreplaceFileName():getCString()));
    
    local card = createBattleCard(m_currentBattleBlock.attacker)
    card:setTag(4000)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(m_currentIsAttackerEnemy) then
        m_enemyCardLayer:addChild(card,m_currentAttacker:getZOrder())
    else
        m_PlayerCardLayerLee:addChild(card,m_currentAttacker:getZOrder())
    end
    BattleCardUtilLee.setCardHp(card,m_currentHpTable[m_currentBattleBlock.attacker]/m_maxHpTable[m_currentBattleBlock.attacker])
    
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[m_currentBattleBlock.attacker])
    
    local animationEnd = function()
    
         --应该使用SKILL释放类型判断
         flyAttack()
         card:removeFromParentAndCleanup(true)
     end

     local animationFrameChanged = function(frameIndex,xmlSprite)
    --print("animationFrameChanged:",frameIndex,xmlSprite)
    local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
if(tempSprite:getIsKeyFrame()) then
    --print("showFlyAttack tempSprite:getIsKeyFrame")
        showAttackEffect()
    end
end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    card:setDelegate(delegate)


    --local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. skill.actionid));
    local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and "T003_u1_0" or "T003_d1_0")));
    --local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and "T001_u_0" or "T001_d_0")));
    local skillTime = totalFrameNum*card:getFpsInterval()

    --增加技能名称显示
    --不再展示
--[[
    if(skill~=nil and skill.name~=nil) then
        local skillNameLabel = CCLabelTTF:create(skill.name .. "",g_sFontPangWa,card:getContentSize().height*0.4)
        skillNameLabel:setAnchorPoint(ccp(0.5,0.5))
        skillNameLabel:setPosition(card:getContentSize().width/2,card:getContentSize().height/2)
        skillNameLabel:setColor(ccc3(255,220,0))
        card:addChild(skillNameLabel,999)
        
        local skillNameLabelActionArray = CCArray:create()
        skillNameLabelActionArray:addObject(CCScaleTo:create(skillTime*0.3,2))
        skillNameLabelActionArray:addObject(CCScaleTo:create(skillTime*0.05,1.8))
        skillNameLabel:runAction(CCSequence:create(skillNameLabelActionArray))
    end
    --]]
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    if(m_currentBattleBlock.rage ~= nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = m_currentAngerTable[m_currentBattleBlock.attacker] + tonumber(m_currentBattleBlock.rage)
    end
    BattleCardUtilLee.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.attacker])

end

local function showBattleAttack()
    
    --print("=====showBattleAttack:",m_battleIndex)
    
    require "db/skill"
    local skill = skill.getDataById(m_currentBattleBlock.action);
    
    --print("skill.functionWay:",skill.id,skill.functionWay)
    --非怒气技能，直接播放攻击
    if(skill.functionWay==2)then
        
        local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "meffect_31"), -1,CCString:create(""));
        local worldPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width/2,m_currentAttacker:getContentSize().height*0.5))
        local bgPoint = m_bg:convertToNodeSpace(worldPoint)
        spellEffectSprite:retain()
        spellEffectSprite:setPosition(bgPoint)
        spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        m_bg:addChild(spellEffectSprite,9999);
        spellEffectSprite:release()
        
        --delegate
        local animationEnd = function(actionName,xmlSprite)
            spellEffectSprite:removeFromParentAndCleanup(true)
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        end

        --增加动画监听
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(animationEnd)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        spellEffectSprite:setDelegate(delegate)
    end

    m_currentAttacker:setVisible(false)
    
    local skillID = m_currentBattleBlock.action
    
    --require "db/skill"
    --local skill = skill.getDataById(skillID);
    ---[[
    --print("m_currentAttacker:getreplaceFileName():",m_currentAttacker:getreplaceFileName())
    --local card = CCXMLSprite:create(m_currentAttacker:getreplaceFileName():getCString())
    --card:retain()
    --card:initXMLSprite(CCString:create(m_currentAttacker:getreplaceFileName():getCString()));
    
    local card = createBattleCard(m_currentBattleBlock.attacker)
    card:setTag(4000)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(m_currentIsAttackerEnemy) then
        m_enemyCardLayer:addChild(card,m_currentAttacker:getZOrder())
    else
        m_PlayerCardLayerLee:addChild(card,m_currentAttacker:getZOrder())
    end
    BattleCardUtilLee.setCardHp(card,m_currentHpTable[m_currentBattleBlock.attacker]/m_maxHpTable[m_currentBattleBlock.attacker])
    
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[m_currentBattleBlock.attacker])
    
    local animationEnd = function()
    
    showAttackerVisible()
    
    
    if(skill.attackEffct==nil or skill.attackEffct=="")then
        --print("showBattleAttack done start updateDefendersBuff")
        --goBack()
        updateDefendersBuff()
    end
    --[[
        --应该使用SKILL释放类型判断
        if(m_currentIsAttackerEnemy)then
            showAttackerVisible()
            card:removeFromParentAndCleanup(true)
        else
            flyAttack()
            card:removeFromParentAndCleanup(true)
        end
        --]]
        card:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
--print("animationFrameChanged:",frameIndex,skill.id,skill.actionid)
local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
if(tempSprite:getIsKeyFrame()) then
            --print("showBattleAttack tempSprite:getIsKeyFrame")
            showAttackEffect()
        end
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    card:setDelegate(delegate)

--播放音效
if(file_exists("audio/effect/" .. skill.actionid .. ".mp3")) then
    
    AudioUtil.playEffect("audio/effect/" .. skill.actionid .. ".mp3")
end


local totalFrameNum
if(file_exists("images/battle/xml/action/" .. skill.actionid .. ".xml"))then
    totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. skill.actionid));
else
    totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and skill.actionid .. "_u_0" or skill.actionid .. "_d_0")));
end
    --local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and "T001_u_0" or "T004_d1_0")));
    --local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and "T001_u_0" or "T001_d_0")));
    local skillTime = totalFrameNum*card:getFpsInterval()
    
    --[[
     --释放特效
     --if(skill.attackEffct ~= nil) then
         local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/texiao_1"), -1,CCString:create(""));
         spellEffectSprite:retain()
         spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        spellEffectSprite:setPosition(card:getPositionX(),card:getPositionY()-card:getContentSize().height/2);
         if(m_currentIsAttackerEnemy) then
             m_enemyCardLayer:addChild(spellEffectSprite,9999);
         else
             m_PlayerCardLayerLee:addChild(spellEffectSprite,9999);
         end
         spellEffectSprite:release()
    
        local delayTime = spellEffectSprite:getAnimationTime()
        --print("----------------spellEffectSprite:getAnimationTime:",spellEffectSprite:getAnimationTime())
        local spellEffectActionArray = CCArray:create()
        spellEffectActionArray:addObject(CCDelayTime:create(delayTime))
        spellEffectActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
        spellEffectSprite:runAction(CCSequence:create(spellEffectActionArray))
     --end
     --]]
     
    --[[
    local attackerActionArray = CCArray:create()
    --attackerActionArray:addObject(CCScaleBy:create(0.2, 1.1))
    --attackerActionArray:addObject(CCScaleBy:create(0.2, 1.0/1.1))
    attackerActionArray:addObject(CCDelayTime:create(skillTime))
    --attackerActionArray:addObject(CCCallFunc:create(BattleLayerLee.showAttackTrail))
    attackerActionArray:addObject(CCCallFunc:create(BattleLayerLee.showAttackerVisible))
    attackerActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
    card:runAction(CCSequence:create(attackerActionArray))
    --]]
    
--增加技能名称显示
--不再展示
--[[
    if(skill~=nil and skill.name~=nil) then
        local skillNameLabel = CCLabelTTF:create(skill.name .. "",g_sFontPangWa,card:getContentSize().height*0.4)
        skillNameLabel:setAnchorPoint(ccp(0.5,0.5))
        skillNameLabel:setPosition(card:getContentSize().width/2,card:getContentSize().height/2)
        skillNameLabel:setColor(ccc3(255,220,0))
        card:addChild(skillNameLabel,999)
        
        local skillNameLabelActionArray = CCArray:create()
        skillNameLabelActionArray:addObject(CCScaleTo:create(skillTime*0.3,2))
        skillNameLabelActionArray:addObject(CCScaleTo:create(skillTime*0.05,1.8))
        skillNameLabel:runAction(CCSequence:create(skillNameLabelActionArray))
    end
    --]]
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    if(m_currentBattleBlock.rage ~= nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = m_currentAngerTable[m_currentBattleBlock.attacker] + tonumber(m_currentBattleBlock.rage)
    end
--[[
    if(m_currentAngerTable[m_currentBattleBlock.attacker] > 4) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 4
    end
 --]]
    BattleCardUtilLee.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.attacker])
    
    --[[
     m_currentAttacker:setBasePoint(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()));
     local totalFrameNum = m_currentAttacker:runXMLAnimation(CCString:create("images/battle/xml/action/" .. skill.actionid))
     local skillTime = totalFrameNum*card:getFpsInterval()
     
     local attackerActionArray = CCArray:create()
     attackerActionArray:addObject(CCDelayTime:create(skillTime))
     attackerActionArray:addObject(CCCallFunc:create(BattleLayerLee.showAttackTrail))
     --attackerActionArray:addObject(CCCallFunc:create(BattleLayerLee.showAttackerVisible))
     --attackerActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
     --m_currentAttacker:runAction(CCSequence:create(attackerActionArray))
     --]]
 end

 local function showRageEffect()
    
    --print("=====showRageEffect:",m_battleIndex)
    local skillID = m_currentBattleBlock.action
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    
    --print("skill.functionWay:",skill.id,skill.functionWay)
    --非怒气技能，直接播放攻击
    if(skill.functionWay~=2)then
        showBattleAttack()
        return
    end
    
    local hid = tonumber(m_currentBattleBlock.attacker)
    local imageFile
    local grade
    if(hid<10000000) then
        require "db/DB_Monsters"
        local monster = DB_Monsters.getDataById(hid)
        
        if(monster==nil) then
            monster = DB_Monsters.getDataById(1002011)
        end
        
        require "db/DB_Monsters_tmpl"
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        
        grade = monsterTmpl.star_lv
        imageFile = monsterTmpl.rage_head_icon_id
    else
        require "script/model/hero/HeroModel"
        local allHeros = HeroModel.getAllHeroes()
        require "script/utils/LuaUtil"
        --print_table("tb",allHeros)
        --print("----------- allHeros[hid].htid",allHeros[hid..""])
        --print("----------- allHeros[hid].htid",allHeros[hid])
        if(allHeros[hid..""] == nil) then
            
            grade = hid%6+1
        else
            local htid = allHeros[hid..""].htid
            
            require "db/DB_Heroes"
            local hero = DB_Heroes.getDataById(htid)
            
            grade = hero.star_lv
            imageFile = hero.rage_head_icon_id
        end
    end
     
    --print("rage:",skill.icon,skill.name,imageFile,hid,type(imageFile),imageFile~=nil,skill.name)
    if(skill.icon==nil and skill.name~=nil and skill.name~="")then
        local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));
        
        local nameBg = CCSprite:create(IMG_PATH .. "skill_bg.png")
        nameBg:setAnchorPoint(ccp(0.5,0.5))
        nameBg:setPosition(m_bg:convertToNodeSpace(beginPoint))
        
        m_bg:addChild(nameBg,9999)
        
        local nameLabel = CCLabelTTF:create(skill.name,g_sFontName,30)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(nameBg:getContentSize().width*0.5,nameBg:getContentSize().height*0.5)
        nameBg:addChild(nameLabel)
        
        local defenderActionArray = CCArray:create()
        --defenderActionArray:addObject(CCDelayTime:create(1))
        defenderActionArray:addObject(CCMoveBy:create(1,ccp(0,m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5)))
        defenderActionArray:addObject(CCCallFuncN:create(removeSelf))
        nameBg:runAction(CCSequence:create(defenderActionArray))
    end
    
    if(skill.functionWay==2 and skill.icon~=nil  and imageFile~=nil)then
    --if(skill.functionWay==2 and skill.icon~=nil and imageFile~=nil and imageFile~="")then
        --怒气释放
        --print("skill.functionWay")
        
        --音效
        --print("skill.icon:","audio/effect/" .. "nuqitouxiang" .. ".mp3")
        if(file_exists("audio/effect/" .. "nuqitouxiang" .. ".mp3")) then
            
            AudioUtil.playEffect("audio/effect/" .. "nuqitouxiang" .. ".mp3")
        end
        local spellEffectSprite = nil
        if(file_exists("images/battle/effect/" .. "nuqitouxiang" ..".plist"))then
            spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nuqitouxiang"), -1,CCString:create(""));
        else
            if(m_currentIsAttackerEnemy) then
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nuqitouxiang" .."_u"), -1,CCString:create(""));
            else
                spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nuqitouxiang" .."_d"), -1,CCString:create(""));
            end
        end
        
        --替换头像
        local replaceXmlSprite = tolua.cast( spellEffectSprite:getChildByTag(1003) , "CCXMLSprite")
        replaceXmlSprite:setReplaceFileName(CCString:create("images/battle/rage_head/" .. imageFile))
        
        spellEffectSprite:retain()
        spellEffectSprite:setPosition(320,(-m_bg:getPositionY()+CCDirector:sharedDirector():getWinSize().height*0.5)/m_bg:getScale())
        spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        m_bg:addChild(spellEffectSprite,9999);
        spellEffectSprite:release()
        
        --delegate
        local animationEnd = function(actionName,xmlSprite)
        
        showBattleAttack()
        spellEffectSprite:removeFromParentAndCleanup(true)
    end
    
    local animationFrameChanged = function(frameIndex,xmlSprite)
    
end

        --增加动画监听
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(animationEnd)
        delegate:registerLayerChangedHandler(animationFrameChanged)
        spellEffectSprite:setDelegate(delegate)

        --文字动画

        local labelEffectSprite = nil
        if(file_exists("images/battle/effect/" .. "nqtxjnmz" ..".plist"))then
            labelEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nqtxjnmz"), -1,CCString:create(""));
        else
            if(m_currentIsAttackerEnemy) then
                labelEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nqtxjnmz" .."_u"), -1,CCString:create(""));
            else
                labelEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "nqtxjnmz" .."_d"), -1,CCString:create(""));
            end
        end

        --替换头像
        local replaceXmlSprite2 = tolua.cast( labelEffectSprite:getChildByTag(1000) , "CCXMLSprite")
        replaceXmlSprite2:setReplaceFileName(CCString:create("images/battle/rage_head/" .. skill.icon))

        labelEffectSprite:retain()
        labelEffectSprite:setPosition(320,(-m_bg:getPositionY()+CCDirector:sharedDirector():getWinSize().height*0.5)/m_bg:getScale())
        labelEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
        m_bg:addChild(labelEffectSprite,9999);
        labelEffectSprite:release()

        --delegate
        local animationEnd2 = function(actionName,xmlSprite)
        labelEffectSprite:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged2 = function(frameIndex,xmlSprite)

end

        --增加动画监听
        local delegate = BTAnimationEventDelegate:create()
        delegate:registerLayerEndedHandler(animationEnd2)
        delegate:registerLayerChangedHandler(animationFrameChanged2)
        labelEffectSprite:setDelegate(delegate)


    else
        showBattleAttack()
    end
end

local function showFullSceneEffect()
    
    --print("=====showFullSceneEffect:",m_battleIndex)
    local skillID = m_currentBattleBlock.action
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    
    if(skill.fullScreen==0) then
        showRageEffect()
        --showBattleAttack()
    else
        --展示全屏效果
        showRageEffect()
        --showBattleAttack()
    end
end

local function goToAttackLocation()
    
    local skillID = m_currentBattleBlock.action
    
    if(skillID==0)then
        showNextMove()
        return
    end
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    
    require("script/utils/LuaUtil")
    --print_table ("tb", skill)
    --print("=====goToAttackLocation:",m_battleIndex,skill.mpostionType)
    --获得攻击者
    local attackerId = m_currentBattleBlock.attacker
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            m_currentIsAttackerEnemy = false
            m_currentAttackerIndex = role.position
            break
        end
    end
    
    for i=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            m_currentIsAttackerEnemy = true
            m_currentAttackerIndex = role.position
            break
        end
    end
    
    --获得防守者
    local defenderId = m_currentBattleBlock.defender
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role.hid==defenderId) then
        m_currentDefender = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
        m_currentIsDefenderEnemy = false
        m_currentDefenderIndex = role.position
        break
    end
end

for i=1,#(m_battleInfo.team2.arrHero) do
    local role = m_battleInfo.team2.arrHero[i]
    if(role.hid==defenderId) then
    m_currentDefender = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
    m_currentIsDefenderEnemy = true
    m_currentDefenderIndex = role.position
    break
end
end

if(m_currentAttacker == nil)then
       --print("====================  m_currentAttackerId",m_currentBattleBlock.attacker,m_battleIndex)
   end
    --print("=====goToAttackLocation:",m_battleIndex,skill.mpostionType)
    if(skill.mpostionType==1) then
        --近身释放
        local locationPara = m_currentIsDefenderEnemy and -0.6 or 1.6
        local worldLocation = m_currentDefender:convertToWorldSpace(ccp(m_currentDefender:getContentSize().width/2,m_currentDefender:getContentSize().height*locationPara))
        local gotoLocation = m_currentAttacker:getParent():convertToNodeSpace(worldLocation)
        
        local attackerActionArray = CCArray:create()
        attackerActionArray:addObject(CCMoveTo:create(0.1, gotoLocation))
        attackerActionArray:addObject(CCCallFunc:create(showFullSceneEffect))
        m_currentAttacker:runAction(CCSequence:create(attackerActionArray))
        
        elseif(skill.mpostionType==2) then
        --原地释放
        
        m_currentAttacker:runAction(CCCallFunc:create(showFullSceneEffect))
        elseif(skill.mpostionType==3) then
        --固定地点
        
        local worldLocation = ccp(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height/2)
        local gotoLocation = m_currentAttacker:getParent():convertToNodeSpace(worldLocation)
        
        local attackerActionArray = CCArray:create()
        attackerActionArray:addObject(CCMoveTo:create(0.1, gotoLocation))
        attackerActionArray:addObject(CCCallFunc:create(showFullSceneEffect))
        m_currentAttacker:runAction(CCSequence:create(attackerActionArray))
        
        elseif(skill.mpostionType==4) then
        --原地弹道
        
        m_currentAttacker:runAction(CCCallFunc:create(showFullSceneEffect))
        elseif(skill.mpostionType==5) then
        --固定点弹道
        
        local worldLocation = ccp(CCDirector:sharedDirector():getWinSize().width/2,CCDirector:sharedDirector():getWinSize().height/2)
        local gotoLocation = m_currentAttacker:getParent():convertToNodeSpace(worldLocation)
        
        local attackerActionArray = CCArray:create()
        attackerActionArray:addObject(CCMoveTo:create(0.1, gotoLocation))
        attackerActionArray:addObject(CCCallFunc:create(showFullSceneEffect))
        m_currentAttacker:runAction(CCSequence:create(attackerActionArray))
        elseif(skill.mpostionType==7) then
        --撞击
        
        showFlyAttack()
    else
        --全屏
        m_currentAttacker:runAction(CCCallFunc:create(showFullSceneEffect))
    end
end

local function beforeAttackUpdateBuff()
    
    --print("============beforeAttackUpdateBuff begin===============",m_battleIndex)
    --获得攻击者
    local attackerId = m_currentBattleBlock.attacker
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            m_currentIsAttackerEnemy = false
            m_currentAttackerIndex = role.position
            break
        end
    end
    
    for i=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            m_currentIsAttackerEnemy = true
            m_currentAttackerIndex = role.position
            break
        end
    end
    
    --获得防守者
    local defenderId = m_currentBattleBlock.defender
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role.hid==defenderId) then
            m_currentDefender = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            m_currentIsDefenderEnemy = false
            m_currentDefenderIndex = role.position
            break
        end
    end
    
    for i=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[i]
        if(role.hid==defenderId) then
            m_currentDefender = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            m_currentIsDefenderEnemy = true
            m_currentDefenderIndex = role.position
            break
        end
    end

    local skillID = m_currentBattleBlock.action
    
    if(skillID==0)then
        currentRoundOver()
        --showNextMove()
        --print("beforeAttackUpdateBuff skillID==0 updateCardBuff")
        updateCardBuff(attackerId,m_currentAttacker,1,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,afterAttackUpdateBuff,1)
        return
    end
    
    require "db/skill"
    local skill = skill.getDataById(skillID);
    
    require("script/utils/LuaUtil")
    --print_table ("tb", skill)
    
    --获得攻击者
    local attackerId = m_currentBattleBlock.attacker
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
            m_currentIsAttackerEnemy = false
            m_currentAttackerIndex = role.position
            break
        end
    end
    
    for i=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            m_currentIsAttackerEnemy = true
            m_currentAttackerIndex = role.position
            break
        end
    end
    
    --获得防守者
    local defenderId = m_currentBattleBlock.defender
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role.hid==defenderId) then
        m_currentDefender = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+role.position), "CCXMLSprite")
        m_currentIsDefenderEnemy = false
        m_currentDefenderIndex = role.position
        break
    end
end

for i=1,#(m_battleInfo.team2.arrHero) do
    local role = m_battleInfo.team2.arrHero[i]
    if(role.hid==defenderId) then
    m_currentDefender = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
    m_currentIsDefenderEnemy = true
    m_currentDefenderIndex = role.position
    break
end
end

    --更新层次等级
    if(m_currentIsAttackerEnemy)then
        m_PlayerCardLayerLee:getParent():reorderChild(m_PlayerCardLayerLee,0)
        m_enemyCardLayer:getParent():reorderChild(m_enemyCardLayer,1)
        m_enemyCardLayer:reorderChild(m_currentAttacker,10)
    else
        m_PlayerCardLayerLee:getParent():reorderChild(m_PlayerCardLayerLee,1)
        m_enemyCardLayer:getParent():reorderChild(m_enemyCardLayer,0)
        m_PlayerCardLayerLee:reorderChild(m_currentAttacker,10)
    end
    
    --[[
    --假BUFF信息
    local enBufferArray = {}
    local deBufferArray = {}
    local imBufferArray = {}
    local bufferArray = {}
    enBufferArray[1] = 441
    deBufferArray[1] = 441
    --更新BUFF
    updateCardBuff(attackerId,m_currentAttacker,2,enBufferArray,deBufferArray,imBufferArray,bufferArray,goToAttackLocation,1)
    --]]
    
    --print("============beforeAttackUpdateBuff 2===============",m_battleIndex)
    
    if(skillID==0)then
        updateCardBuff(attackerId,m_currentAttacker,1,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,afterAttackUpdateBuff,1)
    else
        updateCardBuff(attackerId,m_currentAttacker,1,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,goToAttackLocation,1)
    end
end

local function initCurrentEnemy()
    
    --[[
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(level==1) then
        levelStr = "simple"
        elseif(level==2) then
        levelStr = "normal"
        elseif(level==3) then
        levelStr = "hard"
        else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
        else
        armyIds = sh["army_ids_" .. levelStr]
    end
    
    local armyIdArray = lua_string_split(armyIds,",")
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    --]]
    print("initCurrentEnemy")
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    --print("========== initCurrentEnemy army.monster_group:",army.monster_group)
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monstersStr = team.monsterID
    
    m_enemyCardLayer:setPosition(ccp(0, 0))
    
    initEnemyLayer(monstersStr)
    
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    m_enemyCardLayer:setVisible(true)
end

local m_dialogIndex = -1
local m_isCheckOverDialog = false
local retryTimes = 0

showNextMove = function ()
    print("===========showNextMove==========",m_battleIndex)
    --判断是否可以进行下一回合
    if(m_isCurrentRoundOver~=nil and m_isCurrentRoundOver~=true and retryTimes<30)then
        local actionArr = CCArray:create()
        actionArr:addObject(CCDelayTime:create(0.1))
        actionArr:addObject(CCCallFunc:create(showNextMove))
        local actions = CCSequence:create(actionArr)
        battleBaseLayer:runAction(actions)
        retryTimes = retryTimes+1
        return
    elseif(retryTimes>=30)then
        currentRoundOver()
    end

    retryTimes = 0
    --CCTextureCache:sharedTextureCache():removeUnusedTextures()
    if(m_isShowBattle ~= true)then
        --判断是否播放对话
        require "db/DB_Army"
        local army = DB_Army.getDataById(m_currentArmyId)
        print("============ army.dialog_ids_fighting",army.dialog_ids_fighting)
        print("============ dialoginfo:",m_dialogIndex)
        print("============ dialoginfo:",m_battleIndex)
        print("============ dialoginfo:",m_battleInfo.battle[m_battleIndex])
        print("============ dialoginfo:",m_currentBattleBlock==nil and 0 or m_currentBattleBlock.round)
        print("============ dialoginfo:",m_battleInfo.battle[m_battleIndex]==nil and 0 or m_battleInfo.battle[m_battleIndex].round)
        if(m_dialogIndex ~= m_battleIndex and army~=nil and army.dialog_ids_fighting~=nil and m_currentBattleBlock~=nil and m_battleInfo.battle[m_battleIndex]~=nil and (m_currentBattleBlock.round ~= m_battleInfo.battle[m_battleIndex].round) )then
            
            local dialog_ids = army.dialog_ids_fighting
            local dialog_idArray = lua_string_split(dialog_ids,",")
            for i=1,#dialog_idArray do
                local dialogRound = tonumber(lua_string_split(dialog_idArray[i],"|")[1])
                print("--------- dialogRound:",dialogRound)
                if(dialogRound ~= nil and m_currentBattleBlock.round == dialogRound)then
                    local talkId = tonumber(lua_string_split(dialog_idArray[i],"|")[2])
                    print("--------- talkId:",talkId)
                    if(talkId~=nil)then
                        doTalk(talkId,showNextMove)
                        m_dialogIndex = m_battleIndex
                        return
                    end
                end
            end
        end
    end

    m_dialogIndex = -1
    --判断对话完结
    require("script/utils/LuaUtil")

    m_currentChildSkillIndex = 0

    if(m_battleIndex>#(m_battleInfo.battle) and m_appraisal~="E" and m_appraisal~="F") then
        print("======================  showNextMove break",m_battleIndex)
        if(m_isShowBattle == true)then
                --closeLayer()
                if(m_afterBattleView~=nil)then
                    battleBaseLayer:addChild(m_afterBattleView,99999)
                    m_afterBattleView:release()
                else
                    closeLayer()
                end
                return
            end
            
            --判断是否播放对话
            require "db/DB_Army"
            local army = DB_Army.getDataById(m_currentArmyId)
            --判断是否有战斗后对话
            if(army.dialog_id_over~=nil and m_isCheckOverDialog == false)then
                doTalk(tonumber(army.dialog_id_over),showNextMove)
                m_isCheckOverDialog = true
                return
            end
            m_isCheckOverDialog = false
            print("======================  showNextMove break2",m_battleIndex)
            
        
            print("======================  showNextMove break3",m_battleIndex)
        --增加顶栏显示
        m_resourceNumber = m_resourceNumber + #m_itemArray
        if(m_resourceNumber~=nil)then
            --print("change battleResourceLabel:","" .. (currentResSum+#m_itemArray))
            battleResourceLabel:setString("" .. (m_resourceNumber))
        end
            battleSoulLabel:setString("" .. m_soulNumber)
            battleMoneyLabel:setString("" .. m_silverNumber)
             print("======================  showNextMove break4",m_battleIndex)
            m_battleIndex = 1
            local actionArr = CCArray:create()
            actionArr:addObject(CCDelayTime:create(0.5))
            if(m_currentArmyIndex~=2)then
                actionArr:addObject(CCCallFunc:create(showNextArmy))
            end
            local actions = CCSequence:create(actionArr)
            battleBaseLayer:runAction(actions)
            print("======================  showNextMove break5",m_battleIndex)
            return
            
            elseif(m_battleIndex>#(m_battleInfo.battle) and (m_appraisal=="E" or m_appraisal=="F")) then
                m_battleIndex = 1
                if(m_isShowBattle == true)then
                --closeLayer()
                if(m_afterBattleView~=nil)then
                    battleBaseLayer:addChild(m_afterBattleView,99999)
                    m_afterBattleView:release()
                else
                    closeLayer()
                end
                return
            end

            --更新战果信息
            m_soulNumber = m_reward.soul==nil and  m_soulNumber or m_soulNumber+tonumber(m_reward.soul)
            if(m_reward.item~=nil and #m_reward.item>0) then
                for i=1,#m_reward.item do
                    m_itemArray[#m_itemArray+1] = m_reward.item[i]
                end
            end
            --前端不再处理英雄增加，后端推送
            --[[
            if(m_reward.hero~=nil and #m_reward.hero>0) then
                for i=1,#m_reward.hero do
                    m_heroArray[#m_heroArray+1] = m_reward.hero[i]
                end
            end
            --]]
            m_silverNumber = m_reward.silver==nil and  m_silverNumber or m_silverNumber+tonumber(m_reward.silver)
            m_expNumber = m_reward.exp==nil and  m_expNumber or m_expNumber+tonumber(m_reward.exp)
            
            --battleResourceLabel:setString("" .. #m_itemArray)
        
        --增加顶栏显示
        local currentResSum = tonumber(battleResourceLabel:getString())
        if(currentResSum~=nil)then
            --print("change battleResourceLabel:","" .. (currentResSum+#m_itemArray))
            battleResourceLabel:setString("" .. (currentResSum+#m_itemArray))
        end
            battleSoulLabel:setString("" .. m_soulNumber)
            battleMoneyLabel:setString("" .. m_silverNumber)
            
            require "script/guide/overture/BattleReportLayerLee"
            local reportLayer = BattleReportLayerLee.getBattleReportLayer(false,m_copy_id,m_base_id,m_level,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber,m_copyType)
            battleBaseLayer:addChild(reportLayer,99999)
            
            return
        end

    m_currentBattleBlock = m_battleInfo.battle[m_battleIndex]

    --require("script/utils/LuaUtil")
    --print_table ("tb", m_currentBattleBlock)

    m_battleIndex = m_battleIndex+1

    --更新信息
    battleRoundLabel:setString(m_currentBattleBlock.round .. "/30")

    m_isCurrentRoundOver = false

    --showAttack()
    --goToAttackLocation()
    beforeAttackUpdateBuff()

    print("======================  showNextMove end")
end

local function clearEnemyLayer()
    if(m_enemyCardLayer~=NULL) then
        print("clearEnemyLayer mothed")
        m_enemyCardLayer:removeAllChildrenWithCleanup(true)
    end
end

initEnemyLayer = function(monsterIds)

if(m_currentArmyIndex ~= 1) then
    clearEnemyLayer()
end


local cardWidth = m_bg:getContentSize().width*0.2;

local startX = 0.28*m_bg:getContentSize().width;
local startY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale() - cardWidth*0.7;

local monsterIdArray = lua_string_split(monsterIds,",")

for i=0,5 do
    if(i+1>#monsterIdArray or monsterIdArray[i+1]=="0") then
        
    else
        
            --print("initEnemyLayer:",monsterIdArray[i+1])
            --local card = CCXMLSprite:create(IMG_PATH .. "card/card_2.png")
            --card:retain()
            --card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_2.png"));
            
            local card = createBattleCard(monsterIdArray[i+1])
            card:setTag(3000+i)
            --card:setScale(cardWidth/card:getContentSize().width)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(getEnemyCardPointByPosition(i))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            m_enemyCardLayer:addChild(card,5-i)
            
            --BattleCardUtilLee.setCardHp(card,0.5)
        end
    end
end

local function layerTouch(eventType, x, y)
    
    if eventType == "began" then
        return true
        elseif eventType == "moved" then
            return true
        else
            return true
        end
    end

function closeLayer()
    --print("==========closeLayer===============")
    
    
    AudioUtil.playBgm("audio/main.mp3")
    --SimpleAudioEngine:sharedEngine():stopBackgroundMusic(false)
    
    endShake()
    --[[
    if(m_newcopyorbase~=nil and m_callbackFunc ~=nil) then
        --print("m_battleInfo.newcopyorbase:",m_newcopyorbase)
        m_callbackFunc(m_newcopyorbase)
    end
    --]]
    
    if(m_afterBattleView~=nil)then
        m_afterBattleView:removeFromParentAndCleanup(true)
    end



    if(m_callbackFunc ~=nil) then
        --print("m_battleInfo.newcopyorbase:",m_newcopyorbase)
        local isWin = true
        if(m_appraisal=="E" or m_appraisal=="F")then
            isWin = false
        end
        m_callbackFunc(m_newcopyorbase,isWin)
    end

    if(m_callbackFunc == nil) then
        --print("battle scene fight over")
        CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    end

    m_callbackFunc = nil
    
    if(m_isShowBattle == nil or m_isShowBattle == false)then
        
        -- if(m_copyType==1)then
            -- RequestCenter.ncopy_leaveBaseLevel(nil,Network.argsHandler(m_copy_id,m_base_id,m_level))
            -- elseif(m_copyType==2)then
            --     RequestCenter.ecopy_leaveCopy(nil,Network.argsHandler(m_copy_id))
            -- else
            --     RequestCenter.acopy_leaveBaseLevel(nil,Network.argsHandler(m_copy_id,m_level))
            -- end
        --RequestCenter.ncopy_leaveBaseLevel(nil,Network.argsHandler(m_copy_id,m_base_id,m_level))
    end
    
    m_isShowBattle = nil
    m_afterBattleView = nil
    m_bg=nil
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChild(battleBaseLayer,true)
    CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    
        isBattleOnGoing = false
    
    if g_system_type == kBT_PLATFORM_ANDROID then
        require "script/utils/LuaUtil"
        checkMem()
    else
        CCTextureCache:sharedTextureCache():removeUnusedTextures()
    end
    -- CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    --print("=============================")
    --print("battleBaseLayer retain count:",battleBaseLayer:retainCount())
     --]]
    local isWin = true
    --print("m_appraisal:",m_appraisal)
    if(m_appraisal=="E" or m_appraisal=="F")then
        isWin = false
    end
    
    --print(collectgarbage("count", 100))
    collectgarbage("collect", 100)
    --print(collectgarbage("count", 100))
    --[[
    --修改缓存信息 ,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber
    if(isWin) then
        --print("-------------isWin----------------")
        UserModel.addExpValue(tonumber(m_expNumber),"battlelee")
        UserModel.addSilverNumber(tonumber(m_silverNumber))
        UserModel.addSoulNum(tonumber(m_soulNumber))
        --UserModel.addExpValue(expNumber)
    end
     --]]
    --print("==========closeLayer===============")
end

local function skipClick()
    if(m_isShowBattle)then
        m_bg:cleanup()
        if(m_enemyCardLayer~=nil)then
            local cardList = m_enemyCardLayer:getChildren()
            for i=0,cardList:count()-1 do
                local card = tolua.cast(cardList:objectAtIndex(i),"CCNode")
                card:cleanup()
            end
        end
        
        if(m_PlayerCardLayerLee~=nil)then
            local cardList = m_PlayerCardLayerLee:getChildren()
            for i=0,cardList:count()-1 do
                local card = tolua.cast(cardList:objectAtIndex(i),"CCNode")
                card:cleanup()
            end
        end
        
        if(m_afterBattleView~=nil)then
            battleBaseLayer:addChild(m_afterBattleView,99999)
            m_afterBattleView:release()
            else
            closeLayer()
        end
    else
        
        m_bg:cleanup()
        if(m_enemyCardLayer~=nil)then
            local cardList = m_enemyCardLayer:getChildren() 
            print("skipClick m_enemyCardLayer:getChildren:",cardList:count())
            for i=0,cardList:count()-1 do
                print("skipClick m_enemyCardLayer for:",i)
                local card = tolua.cast(cardList:objectAtIndex(i),"CCNode")
                card:cleanup()
            end
        end
        
        if(m_PlayerCardLayerLee~=nil)then
            local cardList = m_PlayerCardLayerLee:getChildren()
            print("skipClick m_PlayerCardLayerLee:getChildren:",cardList:count())
            for i=0,cardList:count()-1 do
                print("skipClick m_PlayerCardLayerLee for:",i)
                local card = tolua.cast(cardList:objectAtIndex(i),"CCNode")
                card:cleanup()
            end
        end
        
        --更新战果信息
        m_soulNumber = m_reward.soul==nil and  m_soulNumber or m_soulNumber+tonumber(m_reward.soul)
        if(m_reward.item~=nil and #m_reward.item>0) then
            for i=1,#m_reward.item do
                m_itemArray[#m_itemArray+1] = m_reward.item[i]
            end
        end
        ---[[
        if(m_reward.hero~=nil and #m_reward.hero>0) then
            --print("================ m_reward.hero ==================")
            print_table("m_reward.hero",m_reward.hero)
            for i=1,#m_reward.hero do
                m_heroArray[#m_heroArray+1] = m_reward.hero[i]
            end
        end
        --]]
        m_silverNumber = m_reward.silver==nil and  m_silverNumber or m_silverNumber+tonumber(m_reward.silver)
        m_expNumber = m_reward.exp==nil and  m_expNumber or m_expNumber+tonumber(m_reward.exp)
        
        --battleResourceLabel:setString("" .. #m_itemArray)
        
        --增加顶栏显示
        m_resourceNumber = m_resourceNumber + #m_itemArray
        if(m_resourceNumber~=nil)then
            --print("change battleResourceLabel:","" .. (currentResSum+#m_itemArray))
            battleResourceLabel:setString("" .. (m_resourceNumber))
        end
        battleSoulLabel:setString("" .. m_soulNumber)
        battleMoneyLabel:setString("" .. m_silverNumber)
        
        showNextArmy()
    end
end

local function speedClick1()
    ---[[
    require "script/model/user/UserModel"
    if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_1429"))
        return
    end
     --]]
    --print("speedClick========")
    battleSpeedButton1:setVisible(false)
    battleSpeedButton2:setVisible(true)
    m_BattleTimeScale = 2
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
end

local function speedClick2()
    --print("speedClick========")
    battleSpeedButton2:setVisible(false)
    battleSpeedButton1:setVisible(true)
    m_BattleTimeScale = 1
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
end

local function doBattleClick()
    --print("=========doBattleClick=========")
    
    if(file_exists("audio/effect/" .. "start_fight" .. ".mp3")) then
        
        AudioUtil.playEffect("audio/effect/" .. "start_fight" .. ".mp3")
    end
    
    local army = DB_Army.getDataById(m_currentArmyId)
    if(m_currentArmyIndex == 1) then
        if(UserModel.getUserUtid() == 1) then
            --女
            print(GetLocalizeStringBy("key_1169"))
            doBattleCallback(OTBattleData.girl[1])
        else
            --男
            print(GetLocalizeStringBy("key_2494"))
            doBattleCallback(OTBattleData.boy[1])
        end
    elseif(m_currentArmyIndex == 2) then
        if(UserModel.getUserUtid() == 1) then
            --女
            print(GetLocalizeStringBy("key_1165"))
            doBattleCallback(OTBattleData.girl[2])
        else
            --男
             print(GetLocalizeStringBy("key_2478"))
            doBattleCallback(OTBattleData.boy[2])
        end
    elseif(m_currentArmyIndex == 3) then
        if(UserModel.getUserUtid() == 1) then
            --女
            print(GetLocalizeStringBy("key_1166"))
            doBattleCallback(OTBattleData.girl[3])
        else
            --男
            print(GetLocalizeStringBy("key_2480"))
            doBattleCallback(OTBattleData.boy[3])
        end
    end
    
    ---[[
    -- if(tonumber(army.type)==2)then
    --     doBattleNpc()
    -- else
    --     doBattle()
    -- end
    --]]
    --[=[
    require "script/battle/BattleTest"
    
    m_battleInfo = getTestBattleInfo()
    --存储COPY信息
    m_newcopyorbase = {}
    --存储战斗结果
    m_appraisal = m_battleInfo.appraisal
    --储存HP信息
    m_currentHp = 1000
    --储存奖励信息
    m_reward = {}
    
    print_table("m_battleInfo",m_battleInfo)
    
    --更新敌人层
    clearEnemyLayer()
    
    local team2arr = m_battleInfo.team2.arrHero
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        --local card = CCXMLSprite:create(IMG_PATH .. "card/card_2.png")
        --card:retain()
        --card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_2.png"))
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
        
        m_enemyCardLayer:addChild(card,5-i)
        
        --print("2 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
            else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = currRage
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        --[[
        if(m_currentAngerTable[teamInfo.hid] > 4) then
            m_currentAngerTable[teamInfo.hid] = 4
        end
         --]]
        BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束
    
    --更新玩家层
    m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
    
    m_formation = {}
    
    local team1arr = m_battleInfo.team1.arrHero
    
    m_deadPlayerCardArray = {}
    
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            
            --print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
            local currentHp = 0
            if(teamInfo.currHp==nil) then
                currentHp = teamInfo.maxHp
                else
                currentHp = teamInfo.currHp
            end
            if(currentHp==0)then
                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = teamInfo.hid
                --m_formation["" .. teamInfo.position] = 0
                else
                m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
                m_currentHpTable[teamInfo.hid] = currentHp
                m_currentAngerTable[teamInfo.hid] = currRage
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
                --[[
                if(m_currentAngerTable[teamInfo.hid] > 4) then
                    m_currentAngerTable[teamInfo.hid] = 4
                end
                 --]]
                --BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
            end
        end
    end
    m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
    
    ---[[
    --阵亡队友处理
    for i=1,table.maxn(m_deadPlayerCardArray) do
        local pos = -1
        
        for j=1,#team1arr do
            local teamInfo = team1arr[j]
            if(teamInfo.hid == m_deadPlayerCardArray[i])then
                pos = teamInfo.position
                break
            end
        end
        
        local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
    --]]
    
    --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
    m_bg:addChild(m_PlayerCardLayerLee)
    
    --更新玩家层结束
    
    m_battleIndex = 1
    
    PlayerCardLayerLee.setSwitchable(false)
    doBattleButton:setVisible(false)
    currentRoundOver()
    showNextMove()
    --]=]
end

initBackground = function (bgFile)

local size = CCDirector:sharedDirector():getWinSize()

if(bgFile==nil) then
        --print("bgFile==nil")
        --bgFile = "zd_copy_1.jpg"
    end
    local originalFormat = CCTexture2D:defaultAlphaPixelFormat()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    --m_bg = CCSprite:create(IMG_PATH .. "bg/fight_bg_1.jpg")
    if(m_bg==nil)then
        m_bg = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        --print("what is that:",m_bg,IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        if(nil~=m_bg) then
            m_bg:setAnchorPoint(ccp(0,0))
            m_bg:setPosition(ccp(0, 0))
            m_bg:setScale(size.width/m_bg:getContentSize().width)
            
            local bgUper = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
            bgUper:setPosition(0,m_bg:getContentSize().height)
            bgUper:setAnchorPoint(ccp(0, 0))
            m_bg:addChild(bgUper,-1,2121)
        end
    else
        local texture = CCTextureCache:sharedTextureCache():addImage(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        if(texture~=nil)then
            m_bg:setTexture(texture)
            m_bg:setTextureRect(CCRectMake(0,0,texture:getContentSize().width,texture:getContentSize().height))
            
            m_bg:removeChildByTag(2121,true)
            
            local bgUper = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
            if(bgUper~=nil)then
                bgUper:setPosition(0,m_bg:getContentSize().height)
                bgUper:setAnchorPoint(ccp(0, 0))
                m_bg:addChild(bgUper,-1,2121)
            end
        end
    end

    CCTexture2D:setDefaultAlphaPixelFormat(originalFormat)
end

local function setPlayerCardsBack()
    
    --print("---------setPlayerCardsBack-----------")
    local cardWidth = m_bg:getContentSize().width*0.2
    
    for i=0,5 do
        
        local card = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+i), "CCNode")
        if(card~=nil) then
            --card:stopAllActions()
            --card:setScale(cardWidth/card:getContentSize().width)
            card:setPosition(getPlayerCardPointByPosition(i))
            card:setVisible(true)
        end
    end
end

local function initPlayerCards()
    
    m_PlayerCardLayerLee = CCLayer:create()
    m_PlayerCardLayerLee:setPosition(ccp(0, 0))
    m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
    m_bg:addChild(m_PlayerCardLayerLee)
    
    for i=0,5 do
        local card = CCSprite:create(IMG_PATH .. "card/card_1.jpg")
        card:setAnchorPoint(ccp(0.5,0.5))
        m_PlayerCardLayerLee:addChild(card)
    end
    setPlayerCardsBack()
end

local function move0()

    print("move0")

    doBattleButton:setVisible(false)
    clearEnemyLayer()
    
    initCurrentEnemy()
    
    
    m_enemyCardLayer:setPosition(ccp(0, MoveDistence*3-m_bg:getPositionY()/m_bg:getScale()))
    m_enemyCardLayer:setVisible(true)
    
    local moveTime = 2.5*3
    
    m_bg:runAction(CCMoveBy:create(moveTime, ccp(0, -MoveDistence*3*m_bg:getScale())))
    
    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCMoveBy:create(moveTime, ccp(0, MoveDistence*3)))
    layerActionArray:addObject(CCCallFunc:create(setPlayerCardsBack))
    layerActionArray:addObject(CCCallFunc:create(showTitle))
    layerActionArray:addObject(CCDelayTime:create(1))
    --layerActionArray:addObject(CCCallFunc:create(speedClick))
    
    layerActionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    m_PlayerCardLayerLee:runAction(CCSequence:create(layerActionArray))
    
    local upDownTimes = 4
    local movementY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale()*0.05
    local moveScale = 1.05
    
    for i=0,5 do
        local card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+i), "CCNode")
        --print("move0 card_o",card_o,i)
        local isDead = false
        for j=1,table.maxn(m_deadPlayerCardArray) do
            local cardHid = m_formation["" .. i]
            if(cardHid==m_deadPlayerCardArray[j])then
                isDead = true
                break
            end
        end
        
        if(card_o~=nil and isDead~=true) then
            card_o:setVisible(false)
            --print("card_o moving",card_o:getPositionX(),card_o:getPositionY(),m_formation["" .. i])
            ---[[
            --print("m_currentDefender:getreplaceFileName():",m_currentDefender:getreplaceFileName())
            --local card = CCXMLSprite:create(m_currentDefender:getreplaceFileName():getCString())
            --card:retain()
            --card:initXMLSprite(CCString:create(m_currentDefender:getreplaceFileName():getCString()));
            local card = createBattleCard(m_formation["" .. i])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)
            
            m_PlayerCardLayerLee:addChild(card,card_o:getZOrder())
            
            --更新怒气
            --[=[
            if(m_currentAngerTable[m_formation["" .. i]] == nil) then
                m_currentAngerTable[m_formation["" .. i]] = 0
            end
            BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[m_formation["" .. i]])
            --]=]
            --local strTemp = CCString:create("images/battle/xml/action/walk" )
            local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0" ));
            local skillTime = totalFrameNum*card:getFpsInterval()
            
            --print("=========skillTime============",skillTime)
            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
            defenderActionArray:addObject(CCCallFunc:create(endWalkEffect))
            card:runAction(CCSequence:create(defenderActionArray))
        end
    end
    startWalkEffect()
end

local function move1ShowEnemey()
    
    m_enemyCardLayer:removeChildByTag(1234,true);
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    local startX = 0.28*m_bg:getContentSize().width;
    local startY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale() - cardWidth*0.7;
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card = tolua.cast(card,"CCSprite")
            card:setOpacity(0)
            card:setVisible(true)
            card:runAction(CCFadeIn:create(0.5));
        end
    end
    
    local actionArray = CCArray:create()
    -- actionArray:addObject(CCDelayTime:create(1))
    -- actionArray:addObject(CCCallFunc:create(showTitle))
    -- actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    --actionArray:addObject(CCCallFunc:create(showNextMove))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

local function move1()
    print("move1")
    doBattleButton:setVisible(false)
    clearEnemyLayer()
    
    initCurrentEnemy()

    if(m_currentArmyIndex == 3) then
        local action2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/heidong/heidong"),-1,CCString:create(""))
        action2:setPosition(ccp(g_winSize.width *0.5/m_bg:getScale(),g_winSize.height *0.5/m_bg:getScale()))
        m_enemyCardLayer:addChild(action2,-1)
    end

    local enemyCount = 0
    local finishCount = 0
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffect_37"), -1,CCString:create(""));
            appearEffectSprite:retain()
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            
            appearEffectSprite:setPosition(card:getPositionX(),card:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
            appearEffectSprite:release()
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
                
                finishCount = finishCount+1
                if(finishCount==enemyCount)then
                    -- move1ShowEnemey()
                end
                removeSelf(appearEffectSprite)
            end
        
            local animationFrameChanged = function(frameIndex,xmlSprite)
        
            end
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            appearEffectSprite:setDelegate(delegate)
            
        end
    end
    move1ShowEnemey()
    --[[
    local result = CCAnimation:create()
    for i=1,16 do
        local fileName = string.format(IMG_PATH .. "effect/appear_effect_%04i.png",i)
        result:addSpriteFrameWithFileName(fileName)
    end
    
    result:setDelayPerUnit(0.1)
    
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    m_enemyCardLayer:setVisible(true)
    
    local effectX = 0.5*m_bg:getContentSize().width
    local effectY = 0.8*CCDirector:sharedDirector():getWinSize().height/m_bg:getScale()
    
    local effectSprite = CCSprite:create()
    effectSprite:setPosition(ccp(effectX, effectY))
    effectSprite:setAnchorPoint(ccp(0.5,0.5))
    effectSprite:setScale(1.8)
    
    m_enemyCardLayer:addChild(effectSprite,10,1234)
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCAnimate:create(result))
    actionArray:addObject(CCCallFunc:create(move1ShowEnemey))
    effectSprite:runAction(CCSequence:create(actionArray))
    --]]
end

function move8( ... )
    print("move8")
    -- doBattleButton:setVisible(false)
    -- clearEnemyLayer()
    initCurrentEnemy()
    -- move1ShowEnemey()
    showBattlePrepare()
end

local function move2ShowEnemy()
    
    for i=0,5 do
        local card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+i), "CCNode")
        if(card_o~=nil) then
            card_o:setVisible(true)
        end
    end
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
    --checkPreFightDialog()
end

local function move2()
    print("move2")
    doBattleButton:setVisible(false)
    clearEnemyLayer()
    
    initCurrentEnemy()
    
    m_enemyCardLayer:setVisible(true)
    
    local distence = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale()*0.4;
    
    local temp = distence-m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));
    
    local moveTime = 2.0;
    
    --m_enemyCardLayer:runAction(CCEaseIn:create(CCMoveBy:create(moveTime, ccp(0, -distence)), 0.5) );
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCMoveBy:create(moveTime, ccp(0, -distence)))
    actionArray:addObject(CCCallFunc:create(move2ShowEnemy))
    --actionArray:addObject(CCCallFunc:create(showNextMove))
    m_enemyCardLayer:runAction(CCSequence:create(actionArray));
    ---[[
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIdArray = lua_string_split(team.monsterID,",")
    
    for i=0,5 do
        local card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+i), "CCNode")
        if(card_o~=nil) then
            card_o:setVisible(false)
            
            --print("m_currentDefender:getreplaceFileName():",m_currentDefender:getreplaceFileName())
            --local card = CCXMLSprite:create(m_currentDefender:getreplaceFileName():getCString())
            --card:retain()
            --card:initXMLSprite(CCString:create(m_currentDefender:getreplaceFileName():getCString()));
            local card = createBattleCard(monsterIdArray[i+1])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)
            
            m_enemyCardLayer:addChild(card,card_o:getZOrder())
            --更新怒气
            --[=[
            if(m_currentAngerTable[m_formation["" .. i]] == nil) then
                m_currentAngerTable[m_formation["" .. i]] = 0
            end
            BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[m_formation["" .. i]])
            --]=]
            local strTemp = CCString:create("images/battle/xml/action/walk_0" )
            local totalFrameNum = card:runXMLAnimation(strTemp);
            local skillTime = totalFrameNum*card:getFpsInterval()
            
            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
            defenderActionArray:addObject(CCCallFunc:create(endWalkEffect))
            card:runAction(CCSequence:create(defenderActionArray))
        end
    end
    
    startWalkEffect()
    
     --]]
 end

 local function move3ShowTitle()
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

local function move3ShowAfterTalk()
    
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[3]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move3ShowTitle)
    else
        move3ShowTitle()
    end
    
    --[[
     local runningScene = CCDirector:sharedDirector():getRunningScene()
     require "script/ui/talk/talkLayer"
     local talkLayer = TalkLayer.createTalkLayer(39)
     runningScene:addChild(talkLayer,999999)
     TalkLayer.setCallbackFunction(move1)
     --]]
 end

 local function move3ShowEnemy()
    
    m_enemyCardLayer:removeChildByTag(1234,true);
    
    local fadeInTime = 0.5
    
    local enemyCount = 0
    local finishCount = 0
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil and card:isVisible()==false) then
            
            
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
            --appearEffectSprite:retain()
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            
            appearEffectSprite:setPosition(card:getPositionX(),card:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
            --appearEffectSprite:release()
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
            
            finishCount = finishCount+1
            
            card = tolua.cast(card,"CCSprite")
            card:setOpacity(0)
            card:setVisible(true)
            card:runAction(CCFadeIn:create(fadeInTime))
            if(finishCount==enemyCount)then
                local actionArray = CCArray:create()
                actionArray:addObject(CCDelayTime:create(fadeInTime+0.5))
                actionArray:addObject(CCCallFunc:create(move3ShowAfterTalk))
                battleBaseLayer:runAction(CCSequence:create(actionArray))
            end
            removeSelf(appearEffectSprite)
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end
    
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            appearEffectSprite:setDelegate(delegate)
            
        end
    end
    --[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(fadeInTime+0.5))
    actionArray:addObject(CCCallFunc:create(move3ShowAfterTalk))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
end

local function move3_1()
    
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[2]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move3ShowEnemy)
    else
        move3ShowEnemy()
    end
    --doTalk(39,move3ShowEnemy)
end

local function move3()
    print("move3")
    doBattleButton:setVisible(false)
    clearEnemyLayer()
    
    initCurrentEnemy()
    
    local temp = -m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));
    --[[
    -- 获取XML信息
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(m_level==1) then
        levelStr = "simple"
        elseif(m_level==2) then
        levelStr = "normal"
        elseif(m_level==3) then
        levelStr = "hard"
        else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
        else
        armyIds = sh["army_ids_" .. levelStr]
    end
    
    local armyIdArray = lua_string_split(armyIds,",")
    
    --showTitle(sh.name,m_currentArmyIndex,#armyIdArray)
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    m_currentArmyId = army.id
    --]]
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIds = lua_string_split(team.monsterID,",")
    --print("move3:",army.id,team.id,team.monsterID,team.bossID)
    local bossIds = {}
    if(team.bossID~=nil) then
        bossIds = lua_string_split(team.bossID,",")
    end
    local fadeInTime = 0.5
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
        end
    end
    local enemyCount = 0
    local finishCount = 0
    for i=1,#bossIds do
        local bossId = bossIds[i]
        for j=1,#monsterIds do
            --print("monsterIds[j] == bossId:",type(monsterIds[j]),type(bossId),monsterIds[j] == bossId)
            if(monsterIds[j] == bossId)then
                local boss = m_enemyCardLayer:getChildByTag(3000+j-1)
                if(boss~=nil) then
                    boss = tolua.cast(boss,"CCSprite")
                    boss:setVisible(true)
                    boss:setOpacity(0)
                    
                    
                    enemyCount = enemyCount+1
                    local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
                    --appearEffectSprite:retain()
                    appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    appearEffectSprite:setPosition(boss:getPositionX(),boss:getPositionY());
                    m_enemyCardLayer:addChild(appearEffectSprite,99999);
                    --appearEffectSprite:release()
                    
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    
                    finishCount = finishCount+1
                    boss:runAction(CCFadeIn:create(fadeInTime))
                    if(finishCount==enemyCount)then
                        local actionArray = CCArray:create()
                        actionArray:addObject(CCDelayTime:create(fadeInTime))
                        actionArray:addObject(CCCallFunc:create(move3_1))
                        battleBaseLayer:runAction(CCSequence:create(actionArray))
                    end
                    removeSelf(appearEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
                
            end
            
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    appearEffectSprite:setDelegate(delegate)
                    
                end
            end
        end
    end

    --[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(fadeInTime))
    actionArray:addObject(CCCallFunc:create(move3_1))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
    --[[
     local runningScene = CCDirector:sharedDirector():getRunningScene()
     require "script/ui/talk/talkLayer"
     local talkLayer = TalkLayer.createTalkLayer(39)
     runningScene:addChild(talkLayer,999999)
     TalkLayer.setCallbackFunction(move3ShowEnemy)
     --]]
 end

 local function move4ShowTitle()
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

local function move4ShowTalk3()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[4]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move4ShowTitle)
    else
        move4ShowTitle()
    end
    --doTalk(39,checkPreFightDialog)
end

local function move4ShowEnemey()
    local enemyCount = 0
    local finishCount = 0
    
    for i=0,5 do
        local card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+i), "CCSprite")
        if(card_o~=nil and card_o:isVisible()==false) then
            card_o:setOpacity(0)
            card_o:setVisible(true)
            
            
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
            --appearEffectSprite:retain()
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            
            appearEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
            --appearEffectSprite:release()
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
            
            finishCount = finishCount+1
            
            card_o:runAction(CCFadeIn:create(0.5))
            
            if(finishCount==enemyCount)then
                
                local actionArray = CCArray:create()
                actionArray:addObject(CCDelayTime:create(1))
                actionArray:addObject(CCCallFunc:create(move4ShowTalk3))
                battleBaseLayer:runAction(CCSequence:create(actionArray))

            end
            removeSelf(appearEffectSprite)
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end
    
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            appearEffectSprite:setDelegate(delegate)
            
        end
    end
    --[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(move4ShowTalk3))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
end

local function move4ShowTalk2()
    
    --print("---------move4ShowTalk2-----------")
    
    endWalkEffect()
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIds = lua_string_split(team.monsterID,",")
    local bossIds = {}
    if(team.bossID~=nil) then
        bossIds = lua_string_split(team.bossID,",")
    end
    local fadeInTime = 1
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
        end
    end
    
    for i=1,#bossIds do
        local bossId = bossIds[i]
        for j=1,#monsterIds do
            if(monsterIds[j] == bossId)then
                local boss = m_enemyCardLayer:getChildByTag(3000+j-1)
                if(boss~=nil) then
                    boss:setVisible(true)
                end
            end
        end
    end
    
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[3]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move4ShowEnemey)
    else
        move4ShowEnemey()
    end
    --doTalk(39,move4ShowEnemey)
end

local function move4backoff()
    
    --print("---------move4backoff-----------")
    
    local moveTime = 2.0;
    
    local moveTime = 2.5
    
    m_bg:runAction(CCMoveBy:create(moveTime, ccp(0, -MoveDistence*m_bg:getScale())))
    
    m_enemyCardLayer:runAction(CCMoveBy:create(moveTime, ccp(0, MoveDistence)))
    
    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCMoveBy:create(moveTime, ccp(0, MoveDistence)))
    layerActionArray:addObject(CCCallFunc:create(setPlayerCardsBack))
    layerActionArray:addObject(CCCallFunc:create(move4ShowTalk2))
    layerActionArray:addObject(CCDelayTime:create(0.5))
    m_PlayerCardLayerLee:runAction(CCSequence:create(layerActionArray))
    
    --print("---------move4backoff 2-----------")
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIdArray = lua_string_split(team.monsterID,",")
    
    --敌人移动
    for i=0,5 do
        --print("move4:",i)
        local card_o = m_enemyCardLayer:getChildByTag(3000+i)
        --print("move4:",card_o)
        if(card_o~=nil)then
            --print("move4 card_o~=nil")
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+i), "CCNode")
        end
        if(card_o~=nil and card_o:isVisible()==true) then
            --print("card_o~=nil and card_o:isVisible()==true",i)
            card_o:setVisible(false)
            
            local card = createBattleCard(monsterIdArray[i+1])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)
            
            m_enemyCardLayer:addChild(card,card_o:getZOrder())
            
            local strTemp = CCString:create("images/battle/xml/action/walk_0" )
            local totalFrameNum = card:runXMLAnimation(strTemp);
            
            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
            --defenderActionArray:addObject(CCCallFunc:create(endWalkEffect))
            card:runAction(CCSequence:create(defenderActionArray))
            --print("card_o~=nil and card_o:isVisible()==true 2",i)
        end
    end
    
    --print("---------move4backoff 3-----------")
    startWalkEffect()
    --己方移动
    for i=0,5 do
        local card_o = tolua.cast(m_PlayerCardLayerLee:getChildByTag(1000+i), "CCNode")
        if(card_o~=nil) then
            card_o:setVisible(false)
            
            ---[[
            local card = createBattleCard(m_formation["" .. i])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)
            
            m_PlayerCardLayerLee:addChild(card,card_o:getZOrder())
            --更新怒气
            --[=[
            if(m_currentAngerTable[m_formation["" .. i]] == nil) then
                m_currentAngerTable[m_formation["" .. i]] = 0
            end
            
            BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[m_formation["" .. i]])
            --]=]
            local strTemp = CCString:create("images/battle/xml/action/walk_0" )
            local totalFrameNum = card:runXMLAnimation(strTemp);
            local skillTime = totalFrameNum*card:getFpsInterval()
            
            --print("=========skillTime============",skillTime)
            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime or 0))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayerLee.removeSelf))
            card:runAction(CCSequence:create(defenderActionArray))
        end
    end
    
end

local function move4ShowTalk1()
    --print("---------move4ShowTalk1---------")
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[2]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move4backoff)
    else
        move4backoff()
    end
    --doTalk(39,move4backoff)
end

local function move4()
    print("move4")
    doBattleButton:setVisible(false)
    clearEnemyLayer()
    
    initCurrentEnemy()
    
    local temp = -m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));
    --[[
    -- 获取XML信息
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(m_level==1) then
        levelStr = "simple"
        elseif(m_level==2) then
        levelStr = "normal"
        elseif(m_level==3) then
        levelStr = "hard"
        else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
        else
        armyIds = sh["army_ids_" .. levelStr]
    end
    
    local armyIdArray = lua_string_split(armyIds,",")
    
    --showTitle(sh.name,m_currentArmyIndex,#armyIdArray)
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    m_currentArmyId = army.id
    --]]
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIds = lua_string_split(team.monsterID,",")
    local bossIds = {}
    if(team.bossID~=nil) then
        bossIds = lua_string_split(team.bossID,",")
    end
    local fadeInTime = 0.5
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
        end
    end
    
    local enemyCount = 0
    local finishCount = 0
    
    for i=1,#bossIds do
        local bossId = bossIds[i]
        for j=1,#monsterIds do
            if(monsterIds[j] == bossId)then
                local boss = m_enemyCardLayer:getChildByTag(3000+j-1)
                if(boss~=nil) then
                    
                    boss = tolua.cast(boss,"CCSprite")
                    boss:setVisible(true)
                    boss:setOpacity(0)
                    
                    
                    enemyCount = enemyCount+1
                    local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
                    --appearEffectSprite:retain()
                    appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    appearEffectSprite:setPosition(boss:getPositionX(),boss:getPositionY());
                    m_enemyCardLayer:addChild(appearEffectSprite,99999);
                    --appearEffectSprite:release()
                    
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    
                    finishCount = finishCount+1
                    boss:runAction(CCFadeIn:create(fadeInTime))
                    if(finishCount==enemyCount)then
                        
                        local actionArray = CCArray:create()
                        actionArray:addObject(CCDelayTime:create(fadeInTime))
                        actionArray:addObject(CCCallFunc:create(move4ShowTalk1))
                        battleBaseLayer:runAction(CCSequence:create(actionArray))
                        
                    end
                    removeSelf(appearEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
                
            end
            
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    appearEffectSprite:setDelegate(delegate)
                    
                end
            end
        end
    end
    --[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(fadeInTime))
    actionArray:addObject(CCCallFunc:create(move4ShowTalk1))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
    
end

local function move5ShowTitle()
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

local function move5ShowTalk3()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[5]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move5ShowTitle)
    else
        move5ShowTitle()
    end
    --doTalk(39,checkPreFightDialog)
end

local function move5ShowEnemey()
    
    local enemyCount = 0
    local finishCount = 0
    
    for i=0,5 do
        local card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+i), "CCNode")
        if(card_o~=nil and card_o:isVisible()==false) then
            local card_o = tolua.cast(card_o,"CCSprite")
            card_o:setOpacity(0)
            card_o:setVisible(true)
            
            
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
            --appearEffectSprite:retain()
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            
            appearEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
            --appearEffectSprite:release()
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
            
            finishCount = finishCount+1
            
            card_o:runAction(CCFadeIn:create(0.5))
            
            if(finishCount==enemyCount)then
                
                local actionArray = CCArray:create()
                actionArray:addObject(CCDelayTime:create(1))
                actionArray:addObject(CCCallFunc:create(move5ShowTalk3))
                battleBaseLayer:runAction(CCSequence:create(actionArray))
                
            end
            removeSelf(appearEffectSprite)
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end
    
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            appearEffectSprite:setDelegate(delegate)
            
        end
    end
    --[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(move5ShowTalk3))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
end

local function move5ShowTalk2()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[4]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move5ShowEnemey)
    else
        move5ShowEnemey()
    end
    --doTalk(39,move5ShowEnemey)
end

local function move5change2()
    --[[
    -- 获取XML信息
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(m_level==1) then
        levelStr = "simple"
        elseif(m_level==2) then
        levelStr = "normal"
        elseif(m_level==3) then
        levelStr = "hard"
        else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
        else
        armyIds = sh["army_ids_" .. levelStr]
    end
    
    local armyIdArray = lua_string_split(armyIds,",")
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    m_currentArmyId = army.id
    --]]
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIds = lua_string_split(team.monsterID,",")
    local bossIds = {}
    if(team.bossID~=nil) then
        bossIds = lua_string_split(team.bossID,",")
    end
    local fadeInTime = 0.5
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
        end
    end
    
    local enemyCount = 0
    local finishCount = 0
    
    for i=1,#bossIds do
        local bossId = bossIds[i]
        for j=1,#monsterIds do
            if(monsterIds[j] == bossId)then
                local boss = m_enemyCardLayer:getChildByTag(3000+j-1)
                if(boss~=nil) then
                    local card_o = tolua.cast(boss,"CCSprite")
                    card_o:setOpacity(0)
                    card_o:setVisible(true)
                    
                    
                    enemyCount = enemyCount+1
                    local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
                    --appearEffectSprite:retain()
                    appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    appearEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                    m_enemyCardLayer:addChild(appearEffectSprite,99999);
                    --appearEffectSprite:release()
                    
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    
                    finishCount = finishCount+1
                    
                    card_o:runAction(CCFadeIn:create(fadeInTime))
                    
                    if(finishCount==enemyCount)then
                        
                        local actionArray = CCArray:create()
                        actionArray:addObject(CCDelayTime:create(1))
                        actionArray:addObject(CCCallFunc:create(move5ShowTalk2))
                        battleBaseLayer:runAction(CCSequence:create(actionArray))
                        
                    end
                    removeSelf(appearEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
                
            end
            
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    appearEffectSprite:setDelegate(delegate)
                    
                end
            end
        end
    end

end
local function move5change()
    
    local enemyCount = 0
    local finishCount = 0
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(6000+i)
        if(card~=nil and card:isVisible()==true) then
            local card_o = tolua.cast(card,"CCSprite")
            card_o:setVisible(true)
            
            
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffect_16"), -1,CCString:create(""));
            --appearEffectSprite:retain()
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            
            appearEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
            --appearEffectSprite:release()
            
            --delegate
            local animationEnd = function(actionName,xmlSprite)
            
            finishCount = finishCount+1
            
            local cardActionArray = CCArray:create()
            cardActionArray:addObject(CCFadeOut:create(1))
            cardActionArray:addObject(CCCallFuncN:create(removeSelf))
            card_o:runAction(CCSequence:create(cardActionArray))
            
            if(finishCount==enemyCount)then
                
                local actionArray = CCArray:create()
                actionArray:addObject(CCDelayTime:create(1))
                actionArray:addObject(CCCallFunc:create(move5change2))
                battleBaseLayer:runAction(CCSequence:create(actionArray))
                
            end
            removeSelf(appearEffectSprite)
        end
        
        local animationFrameChanged = function(frameIndex,xmlSprite)
        
    end
    
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            appearEffectSprite:setDelegate(delegate)
            
        end
    end
--[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(move5change2))
    --actionArray:addObject(CCDelayTime:create(1))
    --actionArray:addObject(CCCallFunc:create(move5ShowTalk2))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
end

local function move5ShowTalk1()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[3]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move5change)
    else
        move5change()
    end
    --doTalk(39,move5change)
end

local function move5()
    print("move5")
    doBattleButton:setVisible(false)
    clearEnemyLayer()
    
    initCurrentEnemy()
    
    local temp = -m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));
    --[[
    -- 获取XML信息
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(m_level==1) then
        levelStr = "simple"
        elseif(m_level==2) then
        levelStr = "normal"
        elseif(m_level==3) then
        levelStr = "hard"
        else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
        else
        armyIds = sh["army_ids_" .. levelStr]
    end
    
    local armyIdArray = lua_string_split(armyIds,",")
    
    --showTitle(sh.name,m_currentArmyIndex,#armyIdArray)
    
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    m_currentArmyId = army.id
    --]]
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIds = lua_string_split(team.monsterID,",")
    local bossIds = {}
    if(team.bossID~=nil) then
        bossIds = lua_string_split(team.bossID,",")
    end
    local fadeInTime = 0.5
    
    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
        end
    end
    
    local firstIds = lua_string_split(m_currentArmyAppearStyle,"|")[2]
    local firstIdArr = lua_string_split(firstIds,",")
    
    local enemyCount = 0
    local finishCount = 0
    
    for i=1,#bossIds do
        local bossId = bossIds[i]
        for j=1,#monsterIds do
            if(monsterIds[j] == bossId)then
                local boss = m_enemyCardLayer:getChildByTag(3000+j-1)
                if(boss~=nil and i<=#firstIdArr) then
                    
                    require "db/DB_Monsters"
                    --print("firstIdArr[i]:",firstIdArr[i])
                    local monster = DB_Monsters.getDataById(firstIdArr[i])
                    local monSprite = createBattleCard(monster.hid)
                    monSprite:setPosition(boss:getPositionX(),boss:getPositionY())
                    monSprite:setTag(6000+i)
                    m_enemyCardLayer:addChild(monSprite,boss:getZOrder())
                    monSprite:getChildByTag(6):setVisible(false)
                    
                    local card_o = monSprite
                    card_o:setOpacity(0)
                    card_o:setVisible(true)
                    
                    
                    enemyCount = enemyCount+1
                    local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
                    --appearEffectSprite:retain()
                    appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                    
                    appearEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                    m_enemyCardLayer:addChild(appearEffectSprite,99999);
                    --appearEffectSprite:release()
                    
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                    
                    finishCount = finishCount+1
                    
                    card_o:runAction(CCFadeIn:create(fadeInTime))
                    
                    if(finishCount==enemyCount)then
                        
                        local actionArray = CCArray:create()
                        actionArray:addObject(CCDelayTime:create(fadeInTime))
                        actionArray:addObject(CCCallFunc:create(move5ShowTalk1))
                        battleBaseLayer:runAction(CCSequence:create(actionArray))
                        
                        
                    end
                    removeSelf(appearEffectSprite)
                end
                
                local animationFrameChanged = function(frameIndex,xmlSprite)
                
            end
            
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    appearEffectSprite:setDelegate(delegate)
                    
                end
            end
        end
    end
    --[[
    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(fadeInTime))
    actionArray:addObject(CCCallFunc:create(move5ShowTalk1))
    battleBaseLayer:runAction(CCSequence:create(actionArray))
    --]]
end

showNextArmy = function()
    print("===========showNextArmy==========")
    m_currentArmyIndex = m_currentArmyIndex+1
    m_currentBattleBlock = nil
    -- 获取XML信息
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    local levelStr = nil
    if(m_level==1) then
        levelStr = "simple"
    elseif(m_level==2) then
        levelStr = "normal"
    elseif(m_level==3) then
        levelStr = "hard"
    else
        -- NPC战斗
        levelStr = "simple"
    end
    
    local armyIds = nil
    if(m_level==0) then
        armyIds = sh["npc_army_ids_" .. levelStr]
    else
        armyIds = sh["army_ids_" .. levelStr]
    end

    local armyIdArray = lua_string_split(armyIds,",")
    
    --判断是否结束
    if(armyIdArray[m_currentArmyIndex]==nil) then
        --print("结束喽~~~~~~~~")
        
        --前端不再处理英雄增加，后端推送
        --[[
        --增加武将
        if(m_heroArray~=nil and #m_heroArray>0)then
            require "script/model/hero/HeroModel"
            for i=1,#m_heroArray do
                for hid,data in pairs (m_heroArray[i]) do
                    HeroModel.addHeroWithHid(hid,data)
                end
            end
        end
        --]]                                                                                                                                  
        -- require "script/guide/overture/BattleReportLayerLee"
        --print("#m_itemArray:",#m_itemArray)
        -- local reportLayer = BattleReportLayerLee.getBattleReportLayer(true,m_copy_id,m_base_id,m_level,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber,m_copyType,m_heroArray)
        -- battleBaseLayer:addChild(reportLayer,99999)
        AudioUtil.playEffect("audio/overture/jiaochan_down.mp3")

        local overEffectPlay = function ( ... )
            local blackColorLayer = CCLayerColor:create(ccc4(0,0,0,255))
            local runningScene    = CCDirector:sharedDirector():getRunningScene()
            runningScene:addChild(blackColorLayer, 1201)

            local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/jiewei/jiewei"),-1,CCString:create(""))
            action1:setScale(getScaleParm())
            action1:setPosition(ccps(0.5,0.5))
            --action1:setFPS_interval(1/60.0)
            local animationDelegate = BTAnimationEventDelegate:create()
            action1:setDelegate(animationDelegate)
            animationDelegate:registerLayerEndedHandler(function ( eventType,layerSprite )
                action1:removeFromParentAndCleanup(true)
                action1 = nil
                runningScene:removeChild(blackColorLayer, true)
                closeLayer()
            end)
            runningScene:addChild(action1, 1202)   
        end

        local runningScene = CCDirector:sharedDirector():getRunningScene()
        require "script/ui/talk/talkLayer"
        local talkLayer = TalkLayer.createTalkLayer(265)
        runningScene:addChild(talkLayer,999999)
        TalkLayer.setCallbackFunction(overEffectPlay)
        
        return
    end

    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    m_currentArmyId = army.id
    m_currentArmyAppearStyle = army.appear_style
    --print_table("army:",army)
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monstersStr = team.monsterID

    --initEnemyLayer(monstersStr)

    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    m_enemyCardLayer:setVisible(true)

    if(tonumber(army.type)==2)then
        --print("tonumber(army.type)==2")
        --判断是否为NPC战斗
        m_formationNpc = {}
        local npcTeam = DB_Team.getDataById(army.monster_group_npc)
        
        local monsterIdArray = lua_string_split(npcTeam.monsterID,",")
        --print("npcTeam.monsterID:",npcTeam.monsterID,army.monster_group_npc,army.id)
        for i=0,5 do
            --print("monsterIdArray[i+1]",monsterIdArray[i+1])
            if(i+1>#monsterIdArray or monsterIdArray[i+1]=="0") then
                
            elseif(tonumber(monsterIdArray[i+1])==1)then
                m_formationNpc["" .. i] = tonumber(getMainHero().hid)
            else
                m_formationNpc["" .. i] = tonumber(monsterIdArray[i+1])
            end
        end
        
        m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
        
        print_table("m_formationNpc",m_formationNpc)
        m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formationNpc)
        
        m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
        m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
        --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_PlayerCardLayerLee)
        PlayerCardLayerLee.setSwitchable(false)
        --m_PlayerCardLayerLee:setVisible(true)
        m_formation = m_formationNpc
    else
        if(armyIdArray[m_currentArmyIndex-1] ~= nil)then
            local lastArmy = DB_Army.getDataById(armyIdArray[m_currentArmyIndex-1])
            if(tonumber(lastArmy.type)==2)then
                
                m_formation = m_formation_back
                m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
                
                --print_table("m_formation",m_formation)
                m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
                
                m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
                m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
                --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
                m_bg:addChild(m_PlayerCardLayerLee)
                PlayerCardLayerLee.setSwitchable(false)
            end
        end
    end

---[[
--阵亡队友处理
if(m_battleInfo ~= nil) then
    local team1arr = m_battleInfo.team1.arrHero
    for i=1,table.maxn(m_deadPlayerCardArray) do
        local pos = -1
        
        for j=1,#team1arr do
            local teamInfo = team1arr[j]
            --print("-------  deal with dead body:",teamInfo.hid,teamInfo.position,m_deadPlayerCardArray[i])
            if(teamInfo.hid == m_deadPlayerCardArray[i])then
                pos = teamInfo.position
                break
            end
        end
        
        local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        else
            --print("-------- not found:",m_deadPlayerCardArray[i])
        end
    end
end
 --]]

--清理卡牌信息
print("--------------m_cardBuffArray-------------------")
print_table("m_cardBuffArray",m_cardBuffArray)
for i=0,5 do
    local card = m_PlayerCardLayerLee:getChildByTag(1000+i)
    if(card~=nil)then
        BattleCardUtilLee.setCardAnger(card,0)
        BattleCardUtilLee.setCardHp(card,1)
        --print("shownextarmy buff:",1000+i,m_cardBuffArray[1000+i])
        if(m_cardBuffArray[1000+i]~=nil)then
            for j=1,#m_cardBuffArray[1000+i] do
                
                card:removeChildByTag(100000+m_cardBuffArray[1000+i][j],true)
            end
        end
        card:getChildByTag(6):setVisible(false)
    end
end

m_cardBuffArray = {}


-- battleRoundLabel:setString("0/30")


    local callFunc = nil
    local appearStr = string.sub(m_currentArmyAppearStyle,1,1)
    print("-------appearStr:",appearStr,m_currentArmyAppearStyle)
    print("showNextArmy m_currentArmyIndex = ", m_currentArmyIndex)
    if(m_currentArmyIndex == 1) then
        appearStr = "8"
    end
    if(m_currentArmyIndex == 2) then
        appearStr = "0"
    end

    if(appearStr=="0") then
        callFunc = CCCallFunc:create(move0)
    elseif(appearStr=="1") then
        callFunc = CCCallFunc:create(move1)
    elseif(appearStr=="2") then
        callFunc = CCCallFunc:create(move2)
    elseif(appearStr=="3") then
        callFunc = CCCallFunc:create(move3)
    elseif(appearStr=="4") then
        callFunc = CCCallFunc:create(move4)
    elseif(appearStr=="5") then
        callFunc = CCCallFunc:create(move5)
    elseif(appearStr=="8") then
        callFunc = CCCallFunc:create(move8)
    end

    local actionArr = CCArray:create()
    actionArr:addObject(CCDelayTime:create(0))
    actionArr:addObject(callFunc)
    local actions = CCSequence:create(actionArr)
    battleBaseLayer:runAction(actions)

    --doBattleButton:setVisible(true)
end

local function initUperLayer()
    
    require "script/ui/main/MainScene"
    MainScene.initScales()
    battleUperLayer = CCLayer:create()
    battleUperLayer:setVisible(false)
    local blackBackLayer = CCLayerColor:create(ccc4(0,0,0,111))
    blackBackLayer:setContentSize(CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCDirector:sharedDirector():getWinSize().height*0.05))
    blackBackLayer:setPosition(0,CCDirector:sharedDirector():getWinSize().height*0.96)
    battleUperLayer:addChild(blackBackLayer)
    
    battleRoundIcon = CCLabelTTF:create(GetLocalizeStringBy("key_1672"),g_sFontName,battleBaseLayer:getContentSize().height/35)
    battleRoundIcon:setAnchorPoint(ccp(0.5,0.5))
    battleRoundIcon:setPosition(battleBaseLayer:getContentSize().width*0.75,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleRoundIcon)
    
    battleRoundLabel = CCLabelTTF:create("0/30",g_sFontName,battleBaseLayer:getContentSize().height/35)
    battleRoundLabel:setAnchorPoint(ccp(0.5,0.5))
    battleRoundLabel:setPosition(battleBaseLayer:getContentSize().width*0.9,battleBaseLayer:getContentSize().height*0.98)
    battleUperLayer:addChild(battleRoundLabel)
    
    local startX = battleBaseLayer:getContentSize().width*0.05
    local intervalX = battleBaseLayer:getContentSize().width*0.11
    local labelX = battleBaseLayer:getContentSize().width*0.05
    --[[
    battleMoneyIcon = CCSprite:create(IMG_PATH .. "icon/icon_money.png")
    battleMoneyIcon:setAnchorPoint(ccp(0.5,1))
    battleMoneyIcon:setPosition(startX+intervalX*5,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleMoneyIcon)
    
    battleMoneyLabel = CCLabelTTF:create("12345",g_sFontName,battleBaseLayer:getContentSize().height/30)
    battleMoneyLabel:setAnchorPoint(ccp(0.5,1))
    battleMoneyLabel:setPosition(startX+intervalX*5+labelX*2,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleMoneyLabel)
    
    battleCardIcon = CCSprite:create(IMG_PATH .. "icon/icon_card.png")
    battleCardIcon:setAnchorPoint(ccp(0.5,1))
    battleCardIcon:setPosition(startX+intervalX*4,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleCardIcon)
    
    battleCardLabel = CCLabelTTF:create("12",g_sFontName,battleBaseLayer:getContentSize().height/30)
    battleCardLabel:setAnchorPoint(ccp(0.5,1))
    battleCardLabel:setPosition(startX+intervalX*4+labelX,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleCardLabel)
    
    battlePieceIcon = CCSprite:create(IMG_PATH .. "icon/icon_piece.png")
    battlePieceIcon:setAnchorPoint(ccp(0.5,1))
    battlePieceIcon:setPosition(startX+intervalX*3,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battlePieceIcon)
    
    battlePieceLabel = CCLabelTTF:create("23",g_sFontName,battleBaseLayer:getContentSize().height/30)
    battlePieceLabel:setAnchorPoint(ccp(0.5,1))
    battlePieceLabel:setPosition(startX+intervalX*3+labelX,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battlePieceLabel)
    
    battleEquipmentIcon = CCSprite:create(IMG_PATH .. "icon/icon_card.png")
    battleEquipmentIcon:setAnchorPoint(ccp(0.5,1))
    battleEquipmentIcon:setPosition(startX+intervalX*2,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleEquipmentIcon)
    
    battleEquipmentLabel = CCLabelTTF:create("34",g_sFontName,battleBaseLayer:getContentSize().height/30)
    battleEquipmentLabel:setAnchorPoint(ccp(0.5,1))
    battleEquipmentLabel:setPosition(startX+intervalX*2+labelX,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleEquipmentLabel)
    
    battleResourceIcon = CCSprite:create(IMG_PATH .. "icon/icon_resource.png")
    battleResourceIcon:setAnchorPoint(ccp(0.5,1))
    battleResourceIcon:setPosition(startX+intervalX*1,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleResourceIcon)
    
    battleResourceLabel = CCLabelTTF:create("45",g_sFontName,battleBaseLayer:getContentSize().height/30)
    battleResourceLabel:setAnchorPoint(ccp(0.5,1))
    battleResourceLabel:setPosition(startX+intervalX*1+labelX,battleBaseLayer:getContentSize().height)
    battleUperLayer:addChild(battleResourceLabel)
     
     battleSoulIcon = CCSprite:create(IMG_PATH .. "icon/icon_resource.png")
     battleSoulIcon:setAnchorPoint(ccp(0.5,1))
     battleSoulIcon:setPosition(startX+intervalX*0,battleBaseLayer:getContentSize().height)
     battleUperLayer:addChild(battleSoulIcon)
     
     battleSoulLabel = CCLabelTTF:create("56",g_sFontName,battleBaseLayer:getContentSize().height/30)
     battleSoulLabel:setAnchorPoint(ccp(0.5,1))
     battleSoulLabel:setPosition(startX+intervalX*0+labelX,battleBaseLayer:getContentSize().height)
     battleUperLayer:addChild(battleSoulLabel)
     
     --]]
     
     battleResourceIcon = CCSprite:create(IMG_PATH .. "icon/icon_resource.png")
     battleResourceIcon:setAnchorPoint(ccp(0.5,0.5))
     battleResourceIcon:setPosition(startX+intervalX*0,battleBaseLayer:getContentSize().height*0.98)
     battleUperLayer:addChild(battleResourceIcon)
     battleResourceIcon:setScale(MainScene.elementScale)
     
     battleResourceLabel = CCLabelTTF:create("0",g_sFontName,battleBaseLayer:getContentSize().height/35)
     battleResourceLabel:setAnchorPoint(ccp(0,0.5))
     battleResourceLabel:setPosition(startX+intervalX*0.5,battleBaseLayer:getContentSize().height*0.98)
     battleUperLayer:addChild(battleResourceLabel)
     
     battleSoulIcon = CCSprite:create(IMG_PATH .. "icon/icon_soul.png")
     battleSoulIcon:setAnchorPoint(ccp(0.5,0.5))
     battleSoulIcon:setPosition(startX+intervalX*2,battleBaseLayer:getContentSize().height*0.98)
     battleUperLayer:addChild(battleSoulIcon)
     battleSoulIcon:setScale(MainScene.elementScale)
     
     battleSoulLabel = CCLabelTTF:create("0",g_sFontName,battleBaseLayer:getContentSize().height/35)
     battleSoulLabel:setAnchorPoint(ccp(0,0.5))
     battleSoulLabel:setPosition(startX+intervalX*2.5,battleBaseLayer:getContentSize().height*0.98)
     battleUperLayer:addChild(battleSoulLabel)
     
     battleMoneyIcon = CCSprite:create(IMG_PATH .. "icon/icon_money.png")
     battleMoneyIcon:setAnchorPoint(ccp(0.5,0.5))
     battleMoneyIcon:setPosition(startX+intervalX*4,battleBaseLayer:getContentSize().height*0.98)
     battleUperLayer:addChild(battleMoneyIcon)
     battleMoneyIcon:setScale(MainScene.elementScale)
     
     battleMoneyLabel = CCLabelTTF:create("0",g_sFontName,battleBaseLayer:getContentSize().height/35)
     battleMoneyLabel:setAnchorPoint(ccp(0,0.5))
     battleMoneyLabel:setPosition(startX+intervalX*4.5,battleBaseLayer:getContentSize().height*0.98)
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
    
    if(m_BattleTimeScale<=1) then
        m_BattleTimeScale = 1
        CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
        battleSpeedButton2:setVisible(false)
    else
        require "script/model/user/UserModel"
        if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
            m_BattleTimeScale = 1
            CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
            battleSpeedButton2:setVisible(false)
        else
            m_BattleTimeScale = 2
            CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
            battleSpeedButton1:setVisible(false)
        end
    end
    
    --doBattleButton = CCMenuItemLabel:create(CCLabelTTF:create(GetLocalizeStringBy("key_2658"),g_sFontName,battleBaseLayer:getContentSize().height/10))
    doBattleButton = CCMenuItemImage:create(IMG_PATH .. "btn/btn_start_n.png",IMG_PATH .. "btn/btn_start_d.png")
    doBattleButton:setAnchorPoint(ccp(0.5,0.5))
    doBattleButton:setPosition(battleBaseLayer:getContentSize().width/2,battleBaseLayer:getContentSize().height/2)
    doBattleButton:registerScriptTapHandler(doBattleClick)
    doBattleButton:setScale(MainScene.elementScale)
    doBattleButton:setVisible(false)
    
    
    local menu = CCMenu:create()
    menu:setAnchorPoint(ccp(0,0))
    menu:setPosition(0,0)
    menu:addChild(battleSpeedButton1)
    menu:addChild(battleSpeedButton2)
    menu:addChild(doBattleButton)
    battleUperLayer:addChild(menu)
    menu:setTouchPriority(-505)
    
    --battleHorseSprite = CCSprite:create(IMG_PATH .. "icon/icon_horse.png")
    battleHorseSprite = CCMenuItemImage:create(IMG_PATH .. "icon/icon_skip_n.png",IMG_PATH .. "icon/icon_skip_h.png")
    battleHorseSprite:registerScriptTapHandler(skipClick)
    battleHorseSprite:setAnchorPoint(ccp(1,0))
    --battleHorseSprite:setScale(0.3)
    battleHorseSprite:setPosition(battleBaseLayer:getContentSize().width,0)
    menu:addChild(battleHorseSprite)
    battleHorseSprite:setScale(MainScene.elementScale)
    
    --[[
     --非PVP时隐藏跳过
     if(m_isShowBattle~=true)then
         battleHorseSprite:setVisible(false)
     end
     --]]
    
    return battleUperLayer
end

function doBattleCallback(fightRet)
    
    -- if(dictData.ret==nil) then
    --     require "script/ui/tip/AlertTip"
    --     AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
    --     closeLayer()
    --     return
    -- end
    
    -- if(dictData.ret.err=="nodefeatnum") then
    --     require "script/ui/tip/AlertTip"
    --     AlertTip.showAlert( GetLocalizeStringBy("key_1001"), nil, false, nil)
    --     closeLayer()
    --     return
    -- end
    
    -- --print("=-=-=-=-=-=-=-=-=-=")
    -- require("script/utils/LuaUtil")
    -- print_table("doBattleCallback",dictData)
    
    -- --print(dictData.ret.fightRet)
    
    -- --local data = dec(dictData.ret.fightRet)
    -- --local _obj, _size = amf3.decode(data)
    
    -- --print_table ("tb", _obj)
    -- --local amf3_obj = Base64.decodeWithZip(dictData.ret)
    -- local btinfo = dictData.ret.fightRet==nil and dictData.ret or dictData.ret.fightRet
    --print("btinfo:",btinfo)
    
    --print("--------------------------")
    local amf3_obj = Base64.decodeWithZip(fightRet)
    local lua_obj = amf3.decode(amf3_obj)
    m_battleInfo = lua_obj
    --存储COPY信息
    -- m_newcopyorbase = dictData.ret.newcopyorbase
    -- --存储战斗结果
    -- m_appraisal = dictData.ret.appraisal
    -- --储存HP信息
    -- m_currentHp = dictData.ret.curHp
    -- --储存奖励信息
    -- m_reward = dictData.ret.reward
    -- --掉落信息
    -- if(nil~=dictData.ret.reward.hero)then
    --     m_currentHeroDropArray = dictData.ret.reward.hero
    --     for i=1,#dictData.ret.reward.hero do
    --         m_heroDropArray[#m_heroDropArray+1] = dictData.ret.reward.hero[i]
    --     end
    -- end
    
    print_table("m_battleInfo",m_battleInfo)
    
    --更新敌人层
    clearEnemyLayer()
    if(m_currentArmyIndex == 3) then
        local action2 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/heidong/heidong"),-1,CCString:create(""))
        action2:setPosition(ccp(g_winSize.width *0.5/m_bg:getScale(),g_winSize.height *0.5/m_bg:getScale()))
        m_enemyCardLayer:addChild(action2,-1)
    end
    
    local team2arr = m_battleInfo.team2.arrHero
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        --local card = CCXMLSprite:create(IMG_PATH .. "card/card_2.png")
        --card:retain()
        --card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_2.png"))
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
        
        m_enemyCardLayer:addChild(card,5-i)
        
        --print("2 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = currRage
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束
    
    --更新玩家层
    m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
    
    m_formation = {}
    
    local team1arr = m_battleInfo.team1.arrHero
    
    m_deadPlayerCardArray = {}
    
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            
            --print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
            local currentHp = 0
            if(teamInfo.currHp==nil) then
                currentHp = teamInfo.maxHp
            else
                currentHp = teamInfo.currHp
            end
            if(currentHp==0)then
                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = teamInfo.hid
                --m_formation["" .. teamInfo.position] = 0
            else
                m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
                m_currentHpTable[teamInfo.hid] = currentHp
                m_currentAngerTable[teamInfo.hid] = currRage
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
                --BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
            end
        end
    end
    m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
    
    ---[[
    --阵亡队友处理
    for i=1,table.maxn(m_deadPlayerCardArray) do
        local pos = -1
        
        for j=1,#team1arr do
            local teamInfo = team1arr[j]
            if(teamInfo.hid == m_deadPlayerCardArray[i])then
                pos = teamInfo.position
                break
            end
        end
        
        local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
     --]]
     
    --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_PlayerCardLayerLee)
    
    --更新玩家层结束
    
    --print("=-=-=-=-=-=-=-=-=-=")
    m_battleIndex = 1
    
    PlayerCardLayerLee.setSwitchable(false)
    doBattleButton:setVisible(false)
    currentRoundOver()
    showNextMove()
end

doBattleNpc = function()
---[[
local args = CCArray:create()
args:addObject(CCInteger:create(m_copy_id))

args:addObject(CCInteger:create(m_base_id))
args:addObject(CCInteger:create(m_level))
args:addObject(CCInteger:create(m_currentArmyId))
args:addObject(CCArray:create())

require("script/utils/LuaUtil")
print_table("tb",m_formationNpc)

local formation = CCDictionary:create()
--local formation = CCArray:create()

--print_table("tb",formation)
    --print("========formation change=========")
    for i=0,5 do
        local hid = m_formationNpc["" .. i]
        --print("--------m_formationNpc hid:",i,hid)
        --print("--------m_formationNpc hid2:",hid~=nil , hid~=0)
        if(hid~=nil and hid~=0) then
            --print("=========hid:",i,hid)
            formation:setObject(CCInteger:create(hid), "" .. i);
            
            --formation:addObject(CCInteger:create(hid));
        else
            --formation:addObject(CCInteger:create(0))
            formation:setObject(CCInteger:create(0), "" .. i);
        end
    end
--print_table("tb",formation)
args:addObject(formation)

print("m_copyType:",m_copyType)
if(m_copyType==1)then
    RequestCenter.doBattle(BattleLayerLee.doBattleCallback,args)
    elseif(m_copyType==2)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.ecopy_doBattle(BattleLayerLee.doBattleCallback,tempArgs)
    else
        local tempArgs = Network.argsHandler(m_copy_id,m_base_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.acopy_doBattle(BattleLayerLee.doBattleCallback,tempArgs)
    end
end

doBattle = function()
---[[
local args = CCArray:create()
args:addObject(CCInteger:create(m_copy_id))

args:addObject(CCInteger:create(m_base_id))
args:addObject(CCInteger:create(m_level))
args:addObject(CCInteger:create(m_currentArmyId))

newFormation = PlayerCardLayerLee.getFormation()
local isFormationChanged = false

for k,v in pairs(newFormation) do
     --print("k,n,o",k,v,m_formation[k])
     if(m_formation[k] ~= v) then
       isFormationChanged = true
   end
end

for k,v in pairs(m_formation) do
     --print("k,n,o",k,m_formation[k],m_formation[k])
     if(newFormation[k] ~= v) then
       isFormationChanged = true
   end
end

m_formation = {}
for k,v in pairs(newFormation) do
     --local teamInfo = dictData.ret[i]
     m_formation["" .. k] = v
 end
 
 require("script/utils/LuaUtil")
 print_table("tb",m_formation)
 
 local formation = CCDictionary:create()
 --local formation = CCArray:create()
 
 --print_table("tb",formation)
 if(isFormationChanged) then
    --print("========formation change=========")
    for i=0,5 do
         local hid = m_formation["" .. i]
         --print("--------hid:",i,hid)
         if(hid~=nil and hid~=0) then
             --print("=========hid:",i,hid)
             formation:setObject(CCInteger:create(hid), "" .. i);
             
             --formation:addObject(CCInteger:create(hid));
         else
             --formation:addObject(CCInteger:create(0))
         end
     end
 end
 --print_table("tb",formation)
 args:addObject(formation)


 if(m_copyType==1)then
    RequestCenter.doBattle(BattleLayerLee.doBattleCallback,args)
    elseif(m_copyType==2)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.ecopy_doBattle(BattleLayerLee.doBattleCallback,tempArgs)
    else
        local tempArgs = Network.argsHandler(m_copy_id,m_base_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.acopy_doBattle(BattleLayerLee.doBattleCallback,tempArgs)
    end
 --RequestCenter.doBattle(BattleLayerLee.doBattleCallback,args)
 --]]

--[[
local args = CCArray:create()
local team1 = CCArray:create()
for i=0,3 do
    local role = CCDictionary:create()
    role:setObject(CCInteger:create(10000000+i*2), "hid")
    role:setObject(CCInteger:create(i), "position")
    role:setObject(CCInteger:create(20001), "htid")
    role:setObject(CCInteger:create(210), "attackSkill")
    team1:addObject(role)
end
args:addObject(team1)

local team2 = CCArray:create()
for i=0,4 do
    local role = CCDictionary:create()
    role:setObject(CCInteger:create(1001011), "hid")
    role:setObject(CCInteger:create(i), "position")
    role:setObject(CCInteger:create(10000+i), "htid")
    role:setObject(CCInteger:create(206), "attackSkill")
    team2:addObject(role)
end
args:addObject(team2)

RequestCenter.test(BattleLayerLee.doBattleCallback,args)
--]]
end

function getFormationCallBack(cbFlag, dictData, bRet)
    
    --print("==============getFormationCallBack==============")
    --获取阵型
    require("script/utils/LuaUtil")
    print_table ("tb", dictData)
    --设置阵型
    require("script/model/user/FormationModel")
    
    m_formation = {}
    
    for k,v in pairs(dictData.ret) do
        --local teamInfo = dictData.ret[i]
        m_formation["" .. (tonumber(k)-1)] = tonumber(v)
    end
    
    FormationModel.setFormationInfo(m_formation)
    --m_formation = dictData.ret
    
    m_formation_back = m_formation
    --print("==============getFormationCallBack==============")
    

    
end

function replay()
    
    --初始化基础信息
    m_maxHpTable = {}
    m_currentHpTable = {}
    m_currentAngerTable = {}
    m_soulNumber = 0
    m_itemArray = {}
    m_heroArray = {}
    m_resourceNumber = 0
    m_silverNumber = 0
    m_expNumber = 0
    m_deadPlayerCardArray = {}
    m_revivedTime = 0
    
    if(m_afterBattleView~=nil)then
        m_afterBattleView:retain()
        m_afterBattleView:removeFromParentAndCleanup(false)
    end
    
    
    m_battleIndex = 1
    
    m_bg:removeAllChildrenWithCleanup(true)
    
    m_enemyCardLayer = CCLayer:create()
    --m_enemyCardLayer = CCLayerColor:create(ccc4(255,0,0,111))
    m_enemyCardLayer:setPosition(ccp(0, 0))
    m_bg:addChild(m_enemyCardLayer)
    
    m_currentArmyIndex = 0
    
    print_table("m_battleInfo",m_battleInfo)
    
    --更新敌人层
    clearEnemyLayer()
    
    local team2arr = m_battleInfo.team2.arrHero
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        --local card = CCXMLSprite:create(IMG_PATH .. "card/card_2.png")
        --card:retain()
        --card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_2.png"))
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
        
        m_enemyCardLayer:addChild(card,5-i)
        
        --print("2 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = currRage
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束
    
    --更新玩家层
    --m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
    
    m_formation = {}
    
    local team1arr = m_battleInfo.team1.arrHero
    
    m_deadPlayerCardArray = {}
    
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            
            --print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
            local currentHp = 0
            if(teamInfo.currHp==nil) then
                currentHp = teamInfo.maxHp
            else
                currentHp = teamInfo.currHp
            end
            if(currentHp==0)then
                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = teamInfo.hid
                --m_formation["" .. teamInfo.position] = 0
            else
                m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
                m_currentHpTable[teamInfo.hid] = currentHp
                m_currentAngerTable[teamInfo.hid] = currRage
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
                --BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
            end
        end
    end
    m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
    
    ---[[
    --阵亡队友处理
    for i=1,table.maxn(m_deadPlayerCardArray) do
        local pos = -1
        
        for j=1,#team1arr do
            local teamInfo = team1arr[j]
            if(teamInfo.hid == m_deadPlayerCardArray[i])then
                pos = teamInfo.position
                break
            end
        end
        
        local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
    --]]
    
    --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_PlayerCardLayerLee)
    --更新玩家层结束
    
    --print("=-=-=-=-=-=-=-=-=-=")
    m_battleIndex = 1
    
    PlayerCardLayerLee.setSwitchable(false)
    doBattleButton:setVisible(false)
    currentRoundOver()
    showNextMove()
    
end

function showBattleWithString(str,callbackFunc,afterBattleView,bgName)
    
    if(str==nil) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
        closeLayer()
        return
    end
    
    m_heroDropArray = {}
    
    --增加背景音乐
    
    AudioUtil.playBgm("audio/bgm/" .. defaultBgm)
    
    --初始化基础信息
    m_maxHpTable = {}
    m_currentHpTable = {}
    m_currentAngerTable = {}
    m_soulNumber = 0
    m_itemArray = {}
    m_heroArray = {}
    m_resourceNumber = 0
    m_silverNumber = 0
    m_expNumber = 0
    m_battleInfo = nil
    m_deadPlayerCardArray = {}
    m_revivedTime = 0
    
    m_isShowBattle = true
    m_callbackFunc = callbackFunc
    m_afterBattleView = afterBattleView
    if(m_afterBattleView~=nil)then
        m_afterBattleView:retain()
    end
    
    
    m_battleIndex = 1
    
    battleBaseLayer = CCLayer:create()
    battleBaseLayer:setTouchEnabled(true)
    battleBaseLayer:registerScriptTouchHandler(layerTouch,false,-500,true)
    
    initUperLayer()
    battleBaseLayer:addChild(battleUperLayer,1)
    
    bgName = bgName==nil and "chengqiang.jpg" or bgName
    
    initBackground(bgName)
    --print("m_bg",m_bg)
    battleBaseLayer:addChild(m_bg)
    
    m_enemyCardLayer = CCLayer:create()
    --m_enemyCardLayer = CCLayerColor:create(ccc4(255,0,0,111))
    m_enemyCardLayer:setPosition(ccp(0, 0))
    m_bg:addChild(m_enemyCardLayer)
    
    m_currentArmyIndex = 0
    
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(battleBaseLayer,1000,67890)
    local blackLayer = CCLayerColor:create(ccc4(1,1,1,255))
    battleBaseLayer:addChild(blackLayer,9999)
    
    local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    blackLayer:runAction(actions)
    
    
    require("script/utils/LuaUtil")
    local amf3_obj = Base64.decodeWithZip(str)
    --print("--------------------------")
    
    local lua_obj = amf3.decode(amf3_obj)
    
    m_battleInfo = lua_obj
    --存储COPY信息
    m_newcopyorbase = {}
    --存储战斗结果
    m_appraisal = lua_obj.appraisal
    --储存HP信息
    m_currentHp = 1000
    --储存奖励信息
    m_reward = {}
    
    print_table("m_battleInfo",m_battleInfo)
    
    --更新敌人层
    clearEnemyLayer()
    
    local team2arr = m_battleInfo.team2.arrHero
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        --local card = CCXMLSprite:create(IMG_PATH .. "card/card_2.png")
        --card:retain()
        --card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_2.png"))
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
        
        m_enemyCardLayer:addChild(card,5-i)
        
        --print("2 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = currRage
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束
    
    --更新玩家层
    --m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
    
    m_formation = {}
    
    local team1arr = m_battleInfo.team1.arrHero
    
    m_deadPlayerCardArray = {}
    
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            
            --print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
            local currentHp = 0
            if(teamInfo.currHp==nil) then
                currentHp = teamInfo.maxHp
            else
                currentHp = teamInfo.currHp
            end
            if(currentHp==0)then
                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = teamInfo.hid
                --m_formation["" .. teamInfo.position] = 0
            else
                m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
                m_currentHpTable[teamInfo.hid] = currentHp
                m_currentAngerTable[teamInfo.hid] = currRage
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
                --BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
            end
        end
    end
    m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
    
    ---[[
    --阵亡队友处理
    for i=1,table.maxn(m_deadPlayerCardArray) do
        local pos = -1
        
        for j=1,#team1arr do
            local teamInfo = team1arr[j]
            if(teamInfo.hid == m_deadPlayerCardArray[i])then
                pos = teamInfo.position
                break
            end
        end
        
        local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
    --]]
    
    --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_PlayerCardLayerLee)
    --更新玩家层结束
    
    --print("=-=-=-=-=-=-=-=-=-=")
    m_battleIndex = 1
    
    PlayerCardLayerLee.setSwitchable(false)
    doBattleButton:setVisible(false)
    currentRoundOver()
    showNextMove()
    
    -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_BeginFight")
    isBattleOnGoing = true
end


function showBattleWithTable(fightInfo,callbackFunc)
    
    if(fightInfo==nil) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
        closeLayer()
        return
    end
    
    m_heroDropArray = {}
    
    --增加背景音乐
    
    AudioUtil.playBgm("audio/bgm/" .. defaultBgm)
    
    --初始化基础信息
    m_maxHpTable = {}
    m_currentHpTable = {}
    m_currentAngerTable = {}
    m_soulNumber = 0
    m_itemArray = {}
    m_heroArray = {}
    m_resourceNumber = 0
    m_silverNumber = 0
    m_expNumber = 0
    m_battleInfo = nil
    m_deadPlayerCardArray = {}
    m_revivedTime = 0
    
    m_isShowBattle = true
    m_callbackFunc = callbackFunc
    
    
    m_battleIndex = 1
    
    battleBaseLayer = CCLayer:create()
    battleBaseLayer:setTouchEnabled(true)
    battleBaseLayer:registerScriptTouchHandler(layerTouch,false,-500,true)
    
    initUperLayer()
    battleBaseLayer:addChild(battleUperLayer,1)
    
    initBackground("chengqiang.jpg")
    --print("m_bg",m_bg)
    battleBaseLayer:addChild(m_bg)
    
    m_enemyCardLayer = CCLayer:create()
    --m_enemyCardLayer = CCLayerColor:create(ccc4(255,0,0,111))
    m_enemyCardLayer:setPosition(ccp(0, 0))
    m_bg:addChild(m_enemyCardLayer)
    
    m_currentArmyIndex = 0
    
    
    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(battleBaseLayer,1000,67890)
    local blackLayer = CCLayerColor:create(ccc4(1,1,1,255))
    battleBaseLayer:addChild(blackLayer,9999)
    
    local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    blackLayer:runAction(actions)
    
    
    --require("script/utils/LuaUtil")
    --local amf3_obj = Base64.decodeWithZip(str)
    --print("--------------------------")
    
    local lua_obj = fightInfo
    
    m_battleInfo = lua_obj
    --存储COPY信息
    m_newcopyorbase = {}
    --存储战斗结果
    m_appraisal = lua_obj.appraisal
    --储存HP信息
    m_currentHp = 1000
    --储存奖励信息
    m_reward = {}
    
    print_table("m_battleInfo",m_battleInfo)
    
    --更新敌人层
    clearEnemyLayer()
    
    local team2arr = m_battleInfo.team2.arrHero
    
    local cardWidth = m_bg:getContentSize().width*0.2;
    
    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        --local card = CCXMLSprite:create(IMG_PATH .. "card/card_2.png")
        --card:retain()
        --card:initXMLSprite(CCString:create(IMG_PATH .. "card/card_2.png"))
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
        
        m_enemyCardLayer:addChild(card,5-i)
        
        --print("2 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = currRage
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束
    
    --更新玩家层
    --m_PlayerCardLayerLee:removeFromParentAndCleanup(true)
    
    m_formation = {}
    
    local team1arr = m_battleInfo.team1.arrHero
    
    m_deadPlayerCardArray = {}
    
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            
            --print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
            local currentHp = 0
            if(teamInfo.currHp==nil) then
                currentHp = teamInfo.maxHp
            else
                currentHp = teamInfo.currHp
            end
            if(currentHp==0)then
                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = teamInfo.hid
                --m_formation["" .. teamInfo.position] = 0
            else
                m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
                m_currentHpTable[teamInfo.hid] = currentHp
                m_currentAngerTable[teamInfo.hid] = currRage
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
                --BattleCardUtilLee.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
            end
        end
    end
    m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_PlayerCardLayerLee:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
    
    ---[[
    --阵亡队友处理
    for i=1,table.maxn(m_deadPlayerCardArray) do
        local pos = -1
        
        for j=1,#team1arr do
            local teamInfo = team1arr[j]
            if(teamInfo.hid == m_deadPlayerCardArray[i])then
                pos = teamInfo.position
                break
            end
        end
        
        local node = m_PlayerCardLayerLee:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
    --]]
    
    --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_PlayerCardLayerLee)
    --更新玩家层结束
    
    --print("=-=-=-=-=-=-=-=-=-=")
    m_battleIndex = 1
    
    PlayerCardLayerLee.setSwitchable(false)
    doBattleButton:setVisible(false)
    currentRoundOver()
    showNextMove()
    
    -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_BeginFight")
    isBattleOnGoing = true
end

function enterBattle (copy_id,base_id,level,callbackFunc,copyType)
    print("-------enterBattle-------",copy_id,base_id,level,copyType)
    
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(base_id)
    
    --增加背景音乐
    
    if(sh~=nil and sh.fire_music ~= nil)then
        AudioUtil.playBgm("audio/bgm/" .. sh.fire_music)
    else
        AudioUtil.playBgm("audio/bgm/" .. defaultBgm)
    end
    
    m_copy_id = copy_id
    m_base_id = base_id
    m_level = level
    m_callbackFunc = callbackFunc
    m_copyType = copyType==nil and 1 or copyType
    
    if(m_copyType~=1)then
        m_level = 1
    end
    
    --初始化基础信息
    m_maxHpTable = {}
    m_currentHpTable = {}
    m_currentAngerTable = {}
    m_soulNumber = 0
    m_itemArray = {}
    m_heroArray = {}
    m_resourceNumber = 0
    m_silverNumber = 0
    m_expNumber = 0
    m_battleInfo = nil
    m_deadPlayerCardArray = {}
    m_revivedTime = 0
    m_afterBattleView = nil
    m_heroDropArray = {}
    
    local args = CCArray:create()
    -- args:addObject(CCInteger:create(copy_id))
    
    args:addObject(CCInteger:create(base_id))
    args:addObject(CCInteger:create(level))
    
    -- RequestCenter.getFormationInfo( BattleLayerLee.getFormationCallBack )
    
    
    require "script/guide/overture/PlayerCardLayerLee"
    PlayerCardLayerLee.setFormation(m_formation)
    enterBattle2(m_copy_id,m_base_id,m_level)

    isBattleOnGoing = true

end 

function enterBaseLvCallback(cbFlag, dictData, bRet)
    --print("=======enterBaseLvCallback=======")
    print_table("enterBaseLvCallback",dictData)
    if(dictData.err ~= "ok")then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_3168"), nil, false, nil)
        closeLayer()
        return
    end
    if(dictData.ret == "execution") then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_3355"), nil, false, nil)
        closeLayer()
        elseif (dictData.ret == "bag") then
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_2027"), nil, false, nil)
            closeLayer()
        end
    --doBattle()
end

-- 进入战斗场景, 初始化相关资源
function enterBattle2 (copy_id,base_id,level)
    
    --require "script/guide/overture/BattleLayerLee"
    --local battleLayer = BattleLayerLee.enterBattle()
    
    --[[file = io.open(IMG_PATH .. "data1","r")
     file = io.open("/Users/23509/CardSango/CardSango/CardSango/Resources/images/battle/bdata1","r")
     local str = ""
     for line in file:lines() do
     --print(line)
     str = str .. line
     end
     file:close()
     
     file = io.open("/Users/23509/CardSango/CardSango/CardSango/Resources/images/battle/bdata1","rb")
     local str = ""
     for line in file:lines() do
     --print(line)
     str = str .. line
     end
     file:close()
     
     local battleString = "eJy9WN1O2zAUrtPTtGla2rSF8j/xApNgA8bdpDFUpmlCDKFpmtY5jQsRaZM5yYDtCoa0d9i4Z7d7AF5hd3uKPURnJx2gtJMCi3uR9tjHPuc753x2HOdVVNSx51lE+YTyKtKYjFsHhMLpj8uvmkHapGuw1uVZs4hbnml34eR8QaW23zUA1TGl2yTsV9J8PvCRGu33gYR4p0LxHoFe7/c3iashsC3DqZ4DlP87j/cVAFWZyXXcYRMUlSvGjaCxc+wQkOphYxdbPoHAdAWgBqlQylxJ8pWU5VIwcgympMBJAFHmYeRA6rtnyqCbASiHfiuAandycSPAMxrx0I/xf11Eo0gnGsVACOlIjaT+sCgMyN/gwPWwiDWIaS0zzNqwDGdGkGE5YZ70er3PA2tBjq6FKxfSHYoYDSEbN5/ZEeQzJ3zd5UYQhZJUFGobe9hKX5PjfIAcSoLkGBpMXnhJ8smWZDAENS7FVdFICnGRFEQjKQ5HMpRjRdEcG0uKYxPpf2Z0THRGS3FrWxKNpBwXSVk0Eu0WLNOSYdlNCkThVITvZZXBjEJSGZWuzSdynItmpxrrnFaNeU6rxSVhTTQJx+MiGReNZOIWy2EiwU13EEk9Vq3rMWs9GTfDk6IzPBUXyZRoJNNxkUyLRjITF8lMskiGbsGzo/himhV9YJkT/iKZG0Et5oVHMZ9gFFXsOBSbLrbk9NMiJYeYGkyvuLZvwZd9pWWbXfhZzpIjhzdNj3QUhLI63mN/qtuyKYHSTJcctmzn2KY6dgmbnl5UMki+5ztGs2vTDraaXM0VSwwdQoq+t2lASvH4RVOq1PFdsxV06NQ0YEvzqdXkorywvGqstsiKvtzGa/qisaJ6BHcWOcIu7hC56D1cevRgLeuzaSfn91WLfCAWoLpns0+8hvPEdj2YLmFKG4TaYday+2wsz5qy7zHp10fNsV0zuEBDG4DUDj5qOHCRK7Z8Ns0BQ+PCNr9Uu8hVyXvfdDa7bRtpzOrLA9OyWCKq/M4taECqHl7qhS3GCKSZ7paFjwlNowD9EgPxGFLrABuQb0DhWYjrOS/zC/6zxTXSNnwnO+zZZc8r9Jp5ecOW4VvGAPSO7TZ/ABWQ4eA="
     
     require("script/battle/base64")
     
     local amfData = from_base64(battleString)
     
     --print("amfData",amfData)
     
     local myTable,data_size = amf3.decode(amfData)
     
     --print("myTable",myTable)
     --print("data_size",data_size)
     
     require("script/utils/LuaUtil")
     print_table ("tb", myTable)
     
     --]]
    local blackColorLayer = CCLayerColor:create(ccc4(0,0,0,255))
    local runningScene    = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(blackColorLayer, 999999996)
    local oveSeqArray = CCArray:create()
    oveSeqArray:addObject(CCDelayTime:create(0.7))
    oveSeqArray:addObject(CCCallFunc:create(function ( ... )
        runningScene:removeChild(blackColorLayer, true)
    end))
    local overSeq = CCSequence:create(oveSeqArray)
    runningScene:runAction(overSeq)
     m_battleIndex = 1
     
    --local temp = createBaseLayer(nil,true,false,false)
    --print("width:" .. temp:getContentSize().width .. "height:" .. temp:getContentSize().height)
    --changeLayer(temp,"123")
    
    battleBaseLayer = CCLayer:create()
    battleBaseLayer:setTouchEnabled(true)
    battleBaseLayer:registerScriptTouchHandler(layerTouch,false,-500,true)
    
    local isAutoStart = false
    
    initUperLayer()
    battleBaseLayer:addChild(battleUperLayer,1)

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:addChild(battleBaseLayer,1000,67890)

    local pMenu = CCMenu:create()
    pMenu:setAnchorPoint(ccp(0, 0))
    pMenu:setPosition(ccp(0, 0))
    pMenu:setTouchPriority(-6000)
    scene:addChild(pMenu,99999999)

      --跳过按钮
    local skipButton = CCMenuItemImage:create("images/intro/skip1.png","images/intro/skip2.png")
    skipButton:setAnchorPoint(ccp(1, 0))
    skipButton:setPosition(ccps(0.95, 0.05))
    skipButton:registerScriptTapHandler(function ( ... )
        SimpleAudioEngine:sharedEngine():stopAllEffects()
        m_callbackFunc()
    end)
    pMenu:addChild(skipButton)
    skipButton:setVisible(false)
    setAdaptNode(skipButton)

    local m_IntroLayer = CCLayer:create()
    m_IntroLayer:setTouchEnabled(true)
    m_IntroLayer:registerScriptTouchHandler(function ( eventType,x,y )
        print("m_IntroLayer touch and type = ", eventType)
        if(eventType == "began") then
            if(skipButton:isVisible() == true) then
                skipButton:setVisible(false)
            else
                skipButton:setVisible(true)
            end
        elseif(eventType == "moved") then

        elseif(eventType == "ended") then

        end
    end,false,-501,false)
    scene:addChild(m_IntroLayer,99999999)

  

    

    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    initBackground(sh.fire_scene)
    print("sh.fire_scene :", sh.fire_scene)
    print_t(sh)
    print("-----------------------------------------")

    battleBaseLayer:addChild(m_bg)
     local amf3_obj = nil
    if(UserModel.getUserUtid() == 1) then
        --女
        print(GetLocalizeStringBy("key_1169"))
        amf3_obj = Base64.decodeWithZip(OTBattleData.girl[1])
    else
        print(GetLocalizeStringBy("key_2494"))
        --男
        amf3_obj = Base64.decodeWithZip(OTBattleData.boy[1])
    end


    
    local lua_obj = amf3.decode(amf3_obj)
    m_battleInfo = lua_obj
    print("m_battleInfo")
    print_t(m_battleInfo)

    local team1arr = m_battleInfo.team1.arrHero
    local team2arr = m_battleInfo.team2.arrHero
    local playerFormationInfo = {}
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            playerFormationInfo["" .. teamInfo.position] = teamInfo.hid
        end
    end
    PlayerCardLayerLee.setFormation(playerFormationInfo)

    local enemyFormationInfo = {}
    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        if(teamInfo.position ~= nil) then
            enemyFormationInfo["" .. teamInfo.position] = teamInfo.hid
        end
    end


    local leeBattle = function ( ... )
        print("action 1 player over")
            --print("--------- sh:",sh)
            m_enemyCardLayer = CCLayer:create()
            --m_enemyCardLayer = CCLayerColor:create(ccc4(255,0,0,111))
            m_enemyCardLayer:setPosition(ccp(0, 0))
            m_bg:addChild(m_enemyCardLayer)
            
            m_currentArmyIndex = 0
            --[[
            m_currentArmyIndex = 1
            
            require "db/DB_Stronghold"
            local sh = DB_Stronghold.getDataById(base_id)
            local levelStr = nil
            if(level==1) then
                levelStr = "simple"
                elseif(level==2) then
                levelStr = "normal"
                elseif(level==3) then
                levelStr = "hard"
                else
                -- NPC战斗
                levelStr = "simple"
            end
            
            local armyIds = nil
            if(level==0) then
                armyIds = sh["npc_army_ids_" .. levelStr]
                else
                armyIds = sh["army_ids_" .. levelStr]
            end
            
            local armyIdArray = lua_string_split(armyIds,",")
            
            showTitle(sh.name,m_currentArmyIndex,#armyIdArray)
            --]]
            --[=[
            -- 获取XML信息
            require "db/DB_Army"
            require "db/DB_Team"
            
            local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
            m_currentArmyId = army.id
            
            --判断是否为NPC战斗
            if(tonumber(army.type)==2)then
                m_formationNpc = {}
                local npcTeam = DB_Team.getDataById(army.monster_group_npc)
                
                local monsterIdArray = lua_string_split(monsterIds,",")
                
                for i=0,5 do
                    if(i+1>#monsterIdArray or monsterIdArray[i+1]=="0") then
                        
                    elseif(monsterIdArray[i+1]=="1")then
                        m_formationNpc["" .. i] = tonumber(getMainHero().hid)
                    else
                        m_formationNpc["" .. i] = tonumber(monsterIdArray[i+1])
                    end
                end
            end
            
            local team = DB_Team.getDataById(army.monster_group)
            local monstersStr = team.monsterID
            
            m_enemyCardLayer:setPosition(ccp(0, 0))
            
            initEnemyLayer(monstersStr)
            
            local tempY = -m_bg:getPositionY()/m_bg:getScale()
            m_enemyCardLayer:setPosition(ccp(0, tempY))
            m_enemyCardLayer:setVisible(true)
            --]=]
            
            -- 发送进入副本请求
            --[[
            local args = CCArray:create()
            args:addObject(CCInteger:create(copy_id))
            
            args:addObject(CCInteger:create(base_id))
            args:addObject(CCInteger:create(level))
            
            --print("======copy_id,base_id,level=======",copy_id,base_id,level)
            
            if(m_copyType==1)then
                RequestCenter.ncopy_enterBaseLevel(BattleLayerLee.enterBaseLvCallback, args)
                elseif(m_copyType==2)then
                    RequestCenter.ecopy_enterCopy(BattleLayerLee.enterBaseLvCallback, Network.argsHandler(m_copy_id))
                else
                    RequestCenter.acopy_enterBaseLevel(BattleLayerLee.enterBaseLvCallback, Network.argsHandler(m_copy_id,m_base_id))
                end
            --RequestCenter.enderBaseLv(BattleLayerLee.enterBaseLvCallback, args)
            --]]
            -- 发送进入副本请求结束
            
        isAutoStart = true
            
        m_PlayerCardLayerLee = PlayerCardLayerLee.getPlayerCardLayer(CCSizeMake(640,600),playerFormationInfo)
        m_PlayerCardLayerLee:setPosition(ccp(0, 0))
        m_PlayerCardLayerLee:setAnchorPoint(ccp(0, 0))
        --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_PlayerCardLayerLee)
        PlayerCardLayerLee.setSwitchable(false)
        showNextArmy()
        -- [[
         -- initPlayerCards()
         -- local xsp = CCXMLSprite:create();
         -- xsp:retain()
         -- local texture = CCTextureCache:sharedTextureCache():addImage("Default.png")
         -- xsp:setTexture(texture)
         -- xsp:setTextureRect(CCRect(0,0,texture:getContentSize().width,texture:getContentSize().height))
         --]]
         
        --[[
         --print("==============enterBattle==============")
         local xsp = CCXMLSprite:create("Default.png");
         
         xsp:initXMLSprite(CCString:create("Default.png"));
         xsp:setAnchorPoint(ccp(0.5,0.5))
         xsp:setPosition(ccp(CCDirector:sharedDirector():getWinSize().width/2, CCDirector:sharedDirector():getWinSize().height/2));
         xsp:setBasePoint(ccp(CCDirector:sharedDirector():getWinSize().width/2, CCDirector:sharedDirector():getWinSize().height/2));
         battleBaseLayer:addChild(xsp,999);
         
         xsp:runXMLAnimation(CCString:create("test/animtest/test_0"));
         --print("==============enterBattle==============")
         --]]
    
         if(isAutoStart) then
            local function overtureMove( ... )
                -- doBattleButton:setVisible(false)
                -- clearEnemyLayer()
                -- initCurrentEnemy()
                -- move1ShowEnemey()
            end

            local actionArr = CCArray:create()
            actionArr:addObject(CCDelayTime:create(1))
            actionArr:addObject(CCCallFunc:create(overtureMove))
            local actions = CCSequence:create(actionArr)
            battleBaseLayer:runAction(actions)
            print("isAutoStart ==  Yes")
        end                
    end

    print("action 1 player begin")
    require "script/guide/overture/OvertrueLayer"
    OvertrueLayer.playerFormation = playerFormationInfo
    OvertrueLayer.enemyFormation  = enemyFormationInfo
    OvertrueLayer.play(leeBattle)
    
end

-- 退出场景，释放不必要资源
function release (...) 
    -- do something?
end


















