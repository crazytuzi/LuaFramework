-- Filename: BattleLayer.lua
-- Author: k
-- Date: 2013-05-27
-- Purpose: 战斗场景

require "script/utils/extern"
require "script/battle/BT_Skill"
--require "amf3"
-- 主城场景模块声明
module("BattleLayer", package.seeall)

-------------[[常量声明]]------------
--副本类型
kNormalCopy         = 1          --普通副本
kEliteCopy          = 2          --精英副本
kActivityCopy       = 3          --活动副本
kTowerCopy          = 4          --试炼塔
kMysicalFloorCopy   = 5          --神秘层
kHeroCopy           = 6          --武将列传
kMoneyTree          = 7          --要钱书

kFogEffectTag       = 1000001    --云雾特效


--是否在战斗中
isBattleOnGoing = false
local m_isInFighting = false
local speedUpLevel = 1
local speedUp3Level = 30
local trailTime = 0.3

require "script/network/RequestCenter"
require "script/utils/LuaUtil"
require "script/battle/PlayerCardLayer"
require "script/battle/BattleCardUtil"
require "script/audio/AudioUtil"
require "script/libs/LuaCC"
require "script/ui/warcraft/WarcraftData"
require "script/model/hero/HeroModel"

local IMG_PATH = "images/battle/"               -- 图片主路径
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
local autoFightButton --战马标示
local isAutoFight = true
local skipFightButton = nil
local m_bg          -- 战斗背景
local m_playerCardLayer         -- 玩家卡牌层

local m_enemyCardLayer          -- 敌人卡牌层
--local m_enemyCardList          -- 敌人卡牌列表
local m_BattleTimeScale = 1         -- 战斗时间比例
local m_currentArmyIndex = 1         -- 当前敌人顺序

-- 战斗数据
local m_isShowBattle         -- 回调方法
local m_isShowSkipButton
local m_afterBattleView         -- 回调方法
local m_onBattleView         -- 回调方法
local m_callbackFunc         -- 回调方法
local m_copy_id          -- 副本ID
local m_base_id          -- 据点ID
local m_level          -- 难度等级
local m_copyType            --副本类型,1普通，2精英，3活动,5神秘层，6列传
local m_revivedTime = 0     --复活次数
local m_revivedCost = 200   --复活消费
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
local m_extra_reward
local m_extra_info
local m_reward              --奖励
local m_isScore              --是否得分
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
m_playerCardHidMap = {}

local m_isFirstTime = false
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

local m_visibleViews = nil
local visibleSize = g_winSize
local origin = g_origin
local isNameVisible     = true
local petNodeContainer  = {}
local visibleList       = {}
local m_dialogIndex = -1
local m_isCheckOverDialog = false
local retryTimes = 0
local m_talkCallbackFuncion
local m_talkCallbackId
local m_startEffectIsOver = false
local group = ServerList.getSelectServerInfo().group
local uid   = UserModel.getUserUid()

---战车相关
--side
local kEnemySide = 1
local kPlaySide = 2
--tag
local kAimEffTag = 1001
--mask layer
local _warCardMaskLayer = nil
local _bakWarCarDefenders = {}
local _isAddWarCardMask = false

function init( ... )
    m_startEffectIsOver = false
end



function getMainHero()

    local tAllHeroes = HeroModel.getAllHeroes()
    for k, v in pairs(tAllHeroes) do
        local htid = tonumber(v.htid)
        ----print("getMainHero:",htid,tonumber(v.htid))
        if htid==tonumber(UserModel.getUserInfo().htid) then
            return v
        end
    end
    return 0
end

function checkHeroInfoForDress(cardInfo,equipName)
    --print("card hid:",cardInfo.hid,cardInfo.htid)
    --print("cardInfo.dress[1]:",#cardInfo.dress,cardInfo.dress["1"])
    --print_table("cardInfo",cardInfo)
    cardInfo.dress = cardInfo.dress or {}
    if(cardInfo.dress["1"]~=nil and tonumber(cardInfo.dress["1"])~=0)then
        local tmplId = tonumber(cardInfo.dress["1"])
        require "db/DB_Item_dress"
        local dress = DB_Item_dress.getDataById(tmplId)
        --print("dress changeModel:",dress.changeModel)
        if(dress.changeModel == nil) then
            return
        end
        m_playerCardHidMap[cardInfo.hid .. ""] = {}
        local modelArray = lua_string_split(dress.changeModel,",")
        for modelIndex=1,#modelArray do
            local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
            local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]

            require "db/DB_Heroes"
            local heroTmpl = DB_Heroes.getDataById(tonumber(cardInfo.htid))
            if(heroTmpl.model_id == tonumber(baseHtid))then
                --print("m_playerCardHidMap[cardInfo.hid]:",cardInfo.hid,baseHtid)
                m_playerCardHidMap[cardInfo.hid .. ""].actionFile = dressFile
            end
        end
        local modelArray = lua_string_split(dress.changeRageHeadIcon,",")
        for modelIndex=1,#modelArray do
            local baseHtid = lua_string_split(modelArray[modelIndex],"|")[1]
            local dressFile = lua_string_split(modelArray[modelIndex],"|")[2]

            require "db/DB_Heroes"
            local heroTmpl = DB_Heroes.getDataById(tonumber(cardInfo.htid))
            if(heroTmpl.model_id == tonumber(baseHtid))then
                --print("m_playerCardHidMap[cardInfo.hid]:",cardInfo.hid,baseHtid)
                m_playerCardHidMap[cardInfo.hid .. ""].rageHead = dressFile
            end
        end
    end
end

function initPlayerCardHidMap()
    m_playerCardHidMap = {}
    local mainHero = getMainHero()

    -- --print("mainHero:")
    -- --print_table("mainHero",mainHero)
    checkHeroInfoForDress(mainHero,"equip")

    if(m_battleInfo~=nil and m_battleInfo.team1~=nil and m_battleInfo.team1.arrHero~=nil)then
        for i=1,#(m_battleInfo.team1.arrHero) do
            local cardInfo = m_battleInfo.team1.arrHero[i]
            if(m_battleInfo.team1.arrHero[i].dress~=nil)then
                checkHeroInfoForDress(cardInfo,"equipInfo")
            end
        end
    end
    if(m_battleInfo~=nil and m_battleInfo.team2~=nil and m_battleInfo.team2.arrHero~=nil)then
        for i=1,#(m_battleInfo.team2.arrHero) do
            local cardInfo = m_battleInfo.team2.arrHero[i]
            if(m_battleInfo.team2.arrHero[i].dress~=nil)then
                checkHeroInfoForDress(cardInfo,"equipInfo")
            end
        end
    end
end

function removeSelf(node)
    node:removeFromParentAndCleanup(true)
end

function setNodeVisible(node)
    node = tolua.cast(node,"CCNode")
    if(node~=nil)then
        -- if(node:getTag()==0)then
        --     node:setVisible(true)
        -- else
        --     visibleList[node:getTag() .. ""] = visibleList[node:getTag() .. ""]==nil and 0 or visibleList[node:getTag() .. ""]-1
        --     if(visibleList[node:getTag() .. ""]<=0)then
        --         node:setVisible(true)
        --         visibleList[node:getTag() .. ""] = 0
        --     end
        -- end
        node:setVisible(true)
    end
end

function setNodeNotVisible(node)
    if node~= nil and tolua.cast(node, "CCNode")~= nil then
        -- if(node:getTag()==0)then
        --     node:setVisible(false)
        -- else
        --     -- visibleList[node:getTag() .. ""] = visibleList[node:getTag() .. ""]==nil and 1 or visibleList[node:getTag() .. ""]+1
        --     if visibleList[tostring(node:getTag())] == nil then
        --         visibleList[node:getTag() .. ""] = 1
        --     else
        --         visibleList[node:getTag() .. ""] = visibleList[node:getTag() .. ""] + 1
        --     end
        --     if(visibleList[node:getTag() .. ""]>0)then
        --         node:setVisible(false)
        --     end
        -- end
        node:setVisible(false)
    end
end

function showAttackerVisible()
    --m_currentAttacker:setVisible(true)
    setNodeVisible(m_currentAttacker)
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
    ----print("playWalkEffect:",walkEffect)
    if(file_exists("audio/effect/" .. walkEffect .. ".mp3")) then
        ----print("playWalkEffect1:",walkEffect)

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
    ----print("currentRoundOver",m_battleIndex)
    m_isCurrentRoundOver = true
end

function createBattleCard(hid)

    BattleCardUtil.setBattleData(m_battleInfo)
    --判断主角初始时装
    local heroInfo = HeroModel.getHeroByHid(hid)
    if(heroInfo ~= nil and HeroModel.isNecessaryHero(heroInfo.htid)) then
        local cardInfo = {}
        cardInfo.hid = hid
        cardInfo.htid = heroInfo.htid
        cardInfo.dress = UserModel.getDress()
        checkHeroInfoForDress(cardInfo)
    end

    hid = tonumber(hid)
    if(hid>=10000000)then
        require "script/model/hero/HeroModel"
        local allHeros = HeroModel.getAllHeroes()

        if(allHeros==nil)then
            return BattleCardUtil.getBattlePlayerCardImage(hid,nil,nil,nil,nil,isNameVisible)
        end
        require "script/utils/LuaUtil"
        if(m_playerCardHidMap[hid..""]~=nil )then
            local htid = nil
            if(m_battleInfo~=nil)then
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
            end
            --print("find in m_playerCardHidMap:",hid,m_playerCardHidMap[hid..""].actionFile)
            return BattleCardUtil.getBattlePlayerCardImage(hid,nil,htid,nil,m_playerCardHidMap[hid..""].actionFile,isNameVisible)
        elseif(allHeros[hid..""] == nil) then
            local htid = -1
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

            return BattleCardUtil.getBattlePlayerCardImage(hid,nil,htid,nil,nil,isNameVisible)
        else
            return BattleCardUtil.getBattlePlayerCardImage(hid,nil,nil,nil,nil,isNameVisible)
        end
    else

        if(m_currentArmyId==nil)then

            return BattleCardUtil.getBattlePlayerCardImage(hid,nil,nil,nil,nil,isNameVisible)
        end

        require "db/DB_Army"
        local army = DB_Army.getDataById(m_currentArmyId)

        require "db/DB_Team"
        local team = DB_Team.getDataById(army.monster_group)
        local monsterIds = lua_string_split(team.monsterID,",")
        ----print("move3:",army.id,team.id,team.monsterID,team.bossID)
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
        ----print("outLineIdStr:",army.id,team.id,team.monsterID,outLineIdStr)
        local outLineIds = {}
        if(outLineIdStr~=nil) then
            outLineIds = lua_string_split(outLineIdStr,",")
        end
        for i=1,#outLineIds do
            if(tonumber(outLineIds[i]) == tonumber(hid))then
                isOutLine = true
                break
            end
        end

        local isdemonLoad = false

        local demonLoadIdStr = team.demonLoadId
        ----print("demonLoadIdStr:",team.demonLoadId)
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
            return BattleCardUtil.getBattleOutLinePlayerCard(hid)
        else
            return BattleCardUtil.getBattlePlayerCardImage(hid,isBoss,nil,isdemonLoad,nil,isNameVisible)
        end
    end
end

function doReviveCard(flag,hid)
    if(flag==false)then
        return
    end
    local reviveCardCallBack = function(cbFlag, dictData, bRet)
        if(dictData.ret~=nil and dictData.ret=="ok")then
            m_revivedTime = m_revivedTime+1
            require "script/model/user/UserModel"
            --修改缓存信息
            -- UserModel.changeSilverNumber(tonumber(-m_revivedTime*m_revivedCost))
            --从死亡列表中移除
            for i=1,table.maxn(m_deadPlayerCardArray) do
                if(m_deadPlayerCardArray[i]==hid)then
                    m_deadPlayerCardArray[i] = nil
                    break
                end
            end
            local currentFormation = PlayerCardLayer.getFormation()
            local pos = -1

            for j=0,5 do
                if(currentFormation["" .. j] == hid)then
                    pos = j
                    break
                end
            end
            local node = tolua.cast(m_playerCardLayer:getChildByTag(1000+pos), "CCSprite")
            if(node ~= nil) then
                node:stopAllActions()
                node:setCascadeOpacityEnabled(true)
                node:runAction(CCFadeIn:create(0.01))
                -- node:setOpacity(255)
                node:removeChildByTag(9115,true)
                node:removeChildByTag(9116,true)
            end

            --播放复活特效
            local reviveEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/fuhuo_1"), -1,CCString:create(""));
            reviveEffectSprite:retain()
            reviveEffectSprite:setAnchorPoint(ccp(0.5, 0.5));

            reviveEffectSprite:setPosition(node:getPositionX(),node:getPositionY());
            m_playerCardLayer:addChild(reviveEffectSprite,99999);
            reviveEffectSprite:release()

            if(file_exists("audio/effect/fuhuo_1.mp3")) then
                AudioUtil.playEffect("audio/effect/fuhuo_1.mp3")
            end
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
            if(dictData.ret~=nil and dictData.ret=="silver")then
                require "script/ui/tip/AlertTip"
                AlertTip.showAlert( GetLocalizeStringBy("key_3276"), nil, false, nil)
            else
                require "script/ui/tip/AlertTip"
                AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
            end
        end
    end

    if(m_copyType==1)then
        RequestCenter.ncopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,m_level,hid))
    elseif(m_copyType == kEliteCopy)then
        -- RequestCenter.ecopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,hid))
        local parmTable = {}
        parmTable.ret = "ok"
        reviveCardCallBack(nil,parmTable)
    elseif(m_copyType==4)then
        RequestCenter.ecopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,hid))
    else
        RequestCenter.acopy_reviveCard(reviveCardCallBack,Network.argsHandler(m_base_id,m_level,hid))
    end
end

function reviveCardByHid(hid)
    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(m_base_id)
    if(sh~=nil and sh.revive_mode_simple==1) then
        local isDead = false
        for i=1,table.maxn(m_deadPlayerCardArray) do
            if(m_deadPlayerCardArray[i]==hid)then
                isDead = true
                break
            end
        end
        if(isDead)then
            require "script/ui/tip/AlertTip"
            AlertTip.showAlert( GetLocalizeStringBy("key_1003") .. (m_revivedTime+1)*m_revivedCost .. GetLocalizeStringBy("key_1687"), doReviveCard, true, hid)
        end
    end
end

function checkDialogChanges()
    ----print("=============checkDialogChanges===============",m_talkCallbackId)
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    local isCallBack = true
    --替换地图
    if(army~=nil and army.dialog_scene_over~=nil)then
        local dialog_ids = army.dialog_scene_over
        local dialog_idArray = lua_string_split(dialog_ids,",")
        for i=1,#dialog_idArray do
            local dialogId = tonumber(lua_string_split(dialog_idArray[i],"|")[1])
            ----print("--------- dialogRound:",dialogRound)
            if(dialogId ~= nil and m_talkCallbackId == dialogId)then
                local backgroundFile = lua_string_split(dialog_idArray[i],"|")[2]
                ----print("--------- backgroundFile:",backgroundFile)
                if(backgroundFile~=nil)then
                --initBackground(backgroundFile)
                end
                isCallBack = false
                require "script/ui/main/MainScene"
                if(backgroundFile~=nil)then
                    local action1 = CCLayerSprite:layerSpriteWithName(CCString:create("images/guide/effect/zhuangchang/zhuangchang"),-1,CCString:create(""))
                    action1:setScale(MainScene.elementScale)
                    action1:setPosition(ccp(g_winSize.width * 0.5 - 640*MainScene.elementScale*0.5, g_winSize.height * 0.5 + 960*MainScene.elementScale*0.5))

                    local  animationEnd = function(actionName,xmlSprite)
                        action1:removeFromParentAndCleanup(true)
                        action1 = nil
                        initBackground(backgroundFile)
                        if(m_talkCallbackFuncion~=nil)then
                            m_talkCallbackFuncion()
                        end
                    end
                    local animationFrameChanged = function()
                    end
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    action1:setDelegate(delegate)

                    local runningScene = CCDirector:sharedDirector():getRunningScene()
                    runningScene:addChild(action1, 1202)
                end
            end
        end
    end

    --替换音乐
    if(army~=nil and army.dialog_music_over~=nil)then
        local dialog_ids = army.dialog_music_over
        local dialog_idArray = lua_string_split(dialog_ids,",")
        for i=1,#dialog_idArray do
            local dialogId = tonumber(lua_string_split(dialog_idArray[i],"|")[1])
            if(dialogId ~= nil and m_talkCallbackId == dialogId)then
                local backgroundFile = lua_string_split(dialog_idArray[i],"|")[2]
                if(backgroundFile~=nil)then

                    AudioUtil.playBgm("audio/bgm/" .. backgroundFile)
                end
            end
        end
    end

    if(isCallBack==true and m_talkCallbackFuncion~=nil)then
        m_talkCallbackFuncion()
    end
end

function doTalk(talkID,callbackFunc)
    m_talkCallbackFuncion = callbackFunc
    m_talkCallbackId = talkID

    local runningScene = CCDirector:sharedDirector():getRunningScene()
    require "script/ui/talk/talkLayer"
    local talkLayer = TalkLayer.createTalkLayer(talkID)
    runningScene:addChild(talkLayer,999999)
    TalkLayer.setCallbackFunction(checkDialogChanges)
end

function showBattlePrepare()
    --自动战斗
    --普通副本直接进行自动战斗，精英副本根据玩家选择，活动副本未告知
    if((isAutoFight==true or m_copyType==1) and g_network_status==g_network_connected)then

        doBattleButton:setVisible(true)
        doBattleClick(false)
        return
    end
    doBattleButton:setVisible(true)
    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    if(tonumber(army.type)==2 or m_level == 0)then
        PlayerCardLayer.setSwitchable(false)
    else
        PlayerCardLayer.setSwitchable(true)
    end
    require "script/ui/login/LoginScene"
    LoginScene.setBattleStatus(false)
    m_isInFighting = false
end

function checkPreFightDialog()
    local doPreFightDialog = function()
        require "db/DB_Army"
        local army = DB_Army.getDataById(m_currentArmyId)

        if(army.dialog_id_pre~=nil and m_isFirstTime == true)then
            doTalk(tonumber(army.dialog_id_pre),showBattlePrepare)
        else
            showBattlePrepare()
        end
    end

    local hiddenNumber = 0

    for i=0,5 do
        local card = m_playerCardLayer:getChildByTag(1000+i)
        if(card~=nil and card:isVisible()==false)then
            hiddenNumber = hiddenNumber + 1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            appearEffectSprite:setPosition(card:getPositionX(),card:getPositionY());
            m_playerCardLayer:addChild(appearEffectSprite,99999);
            --delegate
            local animationEnd = function(actionName,xmlSprite)
                card = tolua.cast(card,"CCSprite")
                card:setOpacity(0)
                card:setVisible(true)
                card:runAction(CCFadeIn:create(0.5))
                hiddenNumber = hiddenNumber - 1

                if(hiddenNumber == 0)then
                    local actionArray = CCArray:create()
                    actionArray:addObject(CCDelayTime:create(1))
                    actionArray:addObject(CCCallFunc:create(doPreFightDialog))
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

    if(hiddenNumber == 0)then
        doPreFightDialog()
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
    actionArray:addObject(CCDelayTime:create(0.5))
    actionArray:addObject(CCFadeOut:create(0.5))
    actionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
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
                card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
            --card_o:setVisible(true)
            setNodeVisible(card_o)

        end

    end

end

function getEnemyCardPointByPosition(position)

    local cardWidth = m_bg:getContentSize().width*0.2;

    local startX = 0.20*m_bg:getContentSize().width;
    local startY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale() - cardWidth*2.4;

    return ccp(startX+position%3*cardWidth*1.4, startY+math.floor(position/3)*(cardWidth*1.2)*1.2)
end

function getPlayerCardPointByPosition(position)

    return PlayerCardLayer.getPointByPosition(position)
end

function showStrength()

    local team1StrengthBg = CCSprite:create(IMG_PATH .. "strength/strength_bg.png")
    team1StrengthBg:setAnchorPoint(ccp(0.5,0))
    team1StrengthBg:setPosition(m_bg:getContentSize().width*0.13,getPlayerCardPointByPosition(0).y+m_bg:getContentSize().width*0.14)
    m_bg:addChild(team1StrengthBg,99)

    local team1Strength = m_battleInfo.team1.fightForce==nil and 0 or m_battleInfo.team1.fightForce
    local team1StrengthLabel = CCLabelTTF:create(team1Strength .. "",g_sFontName,21)
    team1StrengthLabel:setAnchorPoint(ccp(0.5,0.5))
    team1StrengthLabel:setPosition(team1StrengthBg:getContentSize().width*0.65,team1StrengthBg:getContentSize().height*0.43)
    team1StrengthBg:addChild(team1StrengthLabel)


    local team2StrengthBg = CCSprite:create(IMG_PATH .. "strength/strength_bg.png")
    team2StrengthBg:setAnchorPoint(ccp(0.5,1))
    team2StrengthBg:setPosition(m_bg:getContentSize().width*0.87,getEnemyCardPointByPosition(0).y-m_bg:getContentSize().width*0.14)
    m_bg:addChild(team2StrengthBg,99)

    local team2Strength = m_battleInfo.team2.fightForce==nil and 0 or m_battleInfo.team2.fightForce
    local team2StrengthLabel = CCLabelTTF:create(team2Strength .. "",g_sFontName,21)
    team2StrengthLabel:setAnchorPoint(ccp(0.5,0.5))
    team2StrengthLabel:setPosition(team2StrengthBg:getContentSize().width*0.65,team2StrengthBg:getContentSize().height*0.43)
    team2StrengthBg:addChild(team2StrengthLabel)

    local advantageSprite = CCSprite:create(IMG_PATH .. "strength/firstAttack.png")
    advantageSprite:setAnchorPoint(ccp(0.5,0.5))
    if(tonumber(team1Strength)>=tonumber(team2Strength))then
        advantageSprite:setPosition(team1StrengthBg:getContentSize().width*0.5,team1StrengthBg:getContentSize().height*1.5)
        team1StrengthBg:addChild(advantageSprite)
    else

        advantageSprite:setPosition(team1StrengthBg:getContentSize().width*0.5,-team1StrengthBg:getContentSize().height*0.5)
        team2StrengthBg:addChild(advantageSprite)
    end
end

--展示掉落
function showDropEffect(hid,worldPoint)
    for i=1,#m_currentHeroDropArray do
        if(tonumber(hid)==tonumber(m_currentHeroDropArray[i].mstId))then

            --增加顶栏显示
            m_resourceNumber = m_resourceNumber + 1
            if(m_resourceNumber~=nil)then
                ----print("change battleResourceLabel:","" .. (currentResSum+1))
                battleResourceLabel:setString("" .. (m_resourceNumber))
            end
            local bgPoint = m_bg:convertToNodeSpace(worldPoint)

            local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/fubendiaoluo"), -1,CCString:create(""))
            buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            buffEffectSprite:setPosition(bgPoint);
            m_bg:addChild(buffEffectSprite,99999);

            --delegate
            local animationEnd = function(actionName,xmlSprite)
                removeSelf(buffEffectSprite)
                local runningScene = CCDirector:sharedDirector():getRunningScene()
                local cardSprite = CCSprite:create("images/shop/pub/card_opp.png")
                cardSprite:setAnchorPoint(ccp(0.5,0.5))
                cardSprite:setPosition(worldPoint)
                runningScene:addChild(cardSprite,99999)
                cardSprite:setScale(0.23)
                cardSprite:runAction(CCRotateBy:create(1,7200))

                local resIconPos = battleResourceIcon:convertToWorldSpace(ccpsprite(0.5, 0.5, battleResourceIcon))
                local seqActionArray = CCArray:create()

                local spwanArray = CCArray:create()
                spwanArray:addObject(CCEaseIn:create(CCMoveTo:create(1, resIconPos), 0.5))
                spwanArray:addObject(CCScaleTo:create(1, 0.05))

                local spwan = CCSpawn:create(spwanArray)
                -- local spwan = CCSpawn:createWithTwoActions(CCMoveTo:create(1, resIconPos), CCScaleTo:create(1, 0.05))

                local callback = CCCallFunc:create(function ( ... )
                    cardSprite:removeFromParentAndCleanup(true)
                    cardSprite = nil

                    --
                    if tolua.cast(battleResourceIcon, "CCSprite") then
                        local actionA = CCEaseIn:create(CCScaleTo:create(0.5, 1.5), 0.5)
                        local actionB = CCEaseOut:create(CCScaleTo:create(0.5, 1), 0.5)
                        local resSeqArray = CCArray:create()
                        resSeqArray:addObject(actionA)
                        resSeqArray:addObject(actionB)
                        battleResourceIcon:runAction(CCSequence:create(resSeqArray))
                    end
                end)
                seqActionArray:addObject(spwan)
                seqActionArray:addObject(callback)
                cardSprite:runAction(CCSequence:create(seqActionArray))
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

function showCardNumber(node,number,numberType,damageTitle)
    number = tonumber(number)
    local damageLabel

    local damageTitleSprite = nil
    local damageTitleWidth = 0
    if(damageTitle~=nil)then
        damageTitleSprite = CCSprite:create(damageTitle)
        damageTitleSprite:setAnchorPoint(ccp(1,0.5))
        damageTitleSprite:setPosition(ccp(0,23))
        damageTitleWidth = damageTitleSprite:getContentSize().width
    end

    if node == nil or tolua.cast(node, "CCSprite") == nil  then
        return
    end

    if(numberType==0)then
        --掉血为0不显示
        if(number==0)then
            return
        end

        --掉血
        local fontWidth = 43
        damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/red","" .. number,fontWidth)
        damageLabel:setAnchorPoint(ccp(0.5,0.5))

        local damagePos = ccp(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.5)
        damageLabel:setPosition(damagePos)
        node:getParent():addChild(damageLabel,999)
        local nodeScale = node:getParent():getScale()
        if nodeScale == 1 then
            damageLabel:setScale(node:getScale())
            nodeScale = node:getScale()
        end
        if(damageTitleSprite~=nil)then
            damageLabel:addChild(damageTitleSprite)
        end

        ---[[
        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCScaleTo:create(0.1,2))
        damageActionArray:addObject(CCScaleTo:create(0.05,nodeScale))
        damageActionArray:addObject(CCDelayTime:create(1))
        damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        damageLabel:runAction(CCSequence:create(damageActionArray))

        return
    elseif(numberType==1) then
        --加血
        local fontWidth = 43
        damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/green","+" .. number,fontWidth)
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        ----print("showCardNumber x:",node:getContentSize().width*0.5,(#tostring(number)*fontWidth)/2)
        --damageLabel:setPosition(node:getPositionX()+math.random(-node:getContentSize().width*0.3,node:getContentSize().width*0.3),node:getPositionY()+math.random(-node:getContentSize().width*0.3,node:getContentSize().width*0.3))
        damageLabel:setPosition(node:getPositionX(),node:getPositionY())
        node:getParent():addChild(damageLabel,999)

        if(damageTitleSprite~=nil)then
            damageLabel:addChild(damageTitleSprite)
        end

        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCScaleTo:create(0.1,2))
        damageActionArray:addObject(CCScaleTo:create(0.05,1))
        damageActionArray:addObject(CCDelayTime:create(1))
        damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        damageLabel:runAction(CCSequence:create(damageActionArray))

        return
    elseif(numberType==2) then
        --文字部分
        local criticalLabel = CCSprite:create(IMG_PATH .. "number/critical.png")
        criticalLabel:setAnchorPoint(ccp(0.5,0.5))
        criticalLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.75)
        node:addChild(criticalLabel,999)
        criticalLabel:setOpacity(0)

        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCFadeIn:create(0.3))
        damageActionArray:addObject(CCDelayTime:create(0.7))
        damageActionArray:addObject(CCFadeOut:create(0.3))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        criticalLabel:runAction(CCSequence:create(damageActionArray))
        --数字部分
        local fontWidth = 50
        damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. "number/critical","-" .. number,fontWidth)
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)

        if(damageTitleSprite~=nil)then
            damageLabel:addChild(damageTitleSprite)
        end

        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCScaleTo:create(0.1,2))
        damageActionArray:addObject(CCScaleTo:create(0.05,1))
        damageActionArray:addObject(CCDelayTime:create(1))
        damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        damageLabel:runAction(CCSequence:create(damageActionArray))

        return
    elseif(numberType==3) then
        --怒气上升
        if(number>0)then
            damageLabel = CCSprite:create(IMG_PATH .. "number/angerup.png")
        else
            damageLabel = CCSprite:create(IMG_PATH .. "number/angerdown.png")
        end
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)

        if(number>0)then
            local damageActionArray = CCArray:create()
            damageActionArray:addObject(CCMoveBy:create(1.0, ccp(0, node:getContentSize().height/2)))
            damageActionArray:addObject(CCCallFuncN:create(removeSelf))
            damageLabel:runAction(CCSequence:create(damageActionArray))
        else
            damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.8)
            local damageActionArray = CCArray:create()
            damageActionArray:addObject(CCMoveBy:create(1.0, ccp(0, -node:getContentSize().height/2)))
            damageActionArray:addObject(CCCallFuncN:create(removeSelf))
            damageLabel:runAction(CCSequence:create(damageActionArray))
        end
        return
    elseif(numberType==4) then

        --闪避
        damageLabel = CCSprite:create(IMG_PATH .. "number/dodge.png")
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getContentSize().width*0.5,node:getContentSize().height*0.5)
        node:addChild(damageLabel,999)
    else
        --格挡
        damageLabel = CCSprite:create(IMG_PATH .. "number/block.png")
        damageLabel:setAnchorPoint(ccp(0.5,0.5))
        damageLabel:setPosition(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.9)
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

    if(damageTitleSprite~=nil)then
        damageLabel:addChild(damageTitleSprite)
    end

    ---[[
    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCMoveBy:create(1.0, ccp(0, node:getContentSize().height/2)))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))
    --]]
end


function updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex)

    enBufferArray = enBufferArray==nil and {} or enBufferArray
    deBufferArray = deBufferArray==nil and {} or deBufferArray
    imBufferArray = imBufferArray==nil and {} or imBufferArray
    bufferArray   = bufferArray==nil and {} or bufferArray

    --更新消失BUFF
    if(deBufferArray~=nil and #(deBufferArray)>=currentIndex) then
        require "db/DB_Buffer"
        local buff = DB_Buffer.getDataById(deBufferArray[currentIndex])
        if(buff~=nil and (buff.removeTimeType == timeType or timeType==nil or (buff.removeTimeType==2 and timeType==3)))then
            if(buff.disappearEff~=nil and buff.disappearEff~="")then

                local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.disappearEff), -1,CCString:create(""));
                buffEffectSprite:retain()
                buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));

                buffEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(buffEffectSprite,99999);
                else
                    m_playerCardLayer:addChild(buffEffectSprite,99999);
                end
                buffEffectSprite:release()

                --delegate
                local animationEnd = function(actionName,xmlSprite)

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
                card_o:removeChildByTag(100000+buff.id,true)
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
        require "db/DB_Buffer"
        local buff = DB_Buffer.getDataById(imBufferArray[currentIndex-#(deBufferArray)])
        if(buff~=nil and (buff.addTimeType == timeType or timeType==nil or (buff.addTimeType==2 and timeType==3)))then
            if(buff.addEff~=nil and buff.addEff~="")then
                local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.addEff), -1,CCString:create(""));
                buffEffectSprite:retain()
                buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
                buffEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(buffEffectSprite,99999);
                else
                    m_playerCardLayer:addChild(buffEffectSprite,99999);
                end
                buffEffectSprite:release()
                --delegate
                local animationEnd = function(actionName,xmlSprite)

                    damageLabel = CCSprite:create(IMG_PATH .. "number/immunity.png")
                    damageLabel:setAnchorPoint(ccp(0.5,0.5))
                    damageLabel:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.2)
                    card_o:addChild(damageLabel,999)
                    local damageActionArray = CCArray:create()
                    damageActionArray:addObject(CCScaleTo:create(0.1,2))
                    damageActionArray:addObject(CCScaleTo:create(0.05,1))
                    damageActionArray:addObject(CCDelayTime:create(1))
                    damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
                    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
                    damageLabel:runAction(CCSequence:create(damageActionArray))

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

                damageLabel = CCSprite:create(IMG_PATH .. "number/immunity.png")
                damageLabel:setAnchorPoint(ccp(0.5,0.5))
                damageLabel:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.2)
                card_o:addChild(damageLabel,999)
                local damageActionArray = CCArray:create()
                damageActionArray:addObject(CCScaleTo:create(0.1,2))
                damageActionArray:addObject(CCScaleTo:create(0.05,1))
                damageActionArray:addObject(CCDelayTime:create(1))
                damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
                damageActionArray:addObject(CCCallFuncN:create(removeSelf))
                damageLabel:runAction(CCSequence:create(damageActionArray))
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                return
            end
        else
            damageLabel = CCSprite:create(IMG_PATH .. "number/immunity.png")
            damageLabel:setAnchorPoint(ccp(0.5,0.5))
            damageLabel:setPosition(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.2)
            card_o:addChild(damageLabel,999)
            local damageActionArray = CCArray:create()
            damageActionArray:addObject(CCScaleTo:create(0.1,2))
            damageActionArray:addObject(CCScaleTo:create(0.05,1))
            damageActionArray:addObject(CCDelayTime:create(1))
            damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
            damageActionArray:addObject(CCCallFuncN:create(removeSelf))
            damageLabel:runAction(CCSequence:create(damageActionArray))
            updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
            return
        end
    end
    --更新新增BUFF
    if(enBufferArray~=nil and #(enBufferArray)>=currentIndex-#(deBufferArray)-#(imBufferArray)) then
        require "db/DB_Buffer"
        local buff = DB_Buffer.getDataById(enBufferArray[currentIndex-#(deBufferArray)-#(imBufferArray)])
        if(buff~=nil and (buff.addTimeType == timeType or timeType==nil or (buff.addTimeType==2 and timeType==3)))then
            if(buff.addEff~=nil and buff.addEff~="")then
                local buffEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.addEff), -1,CCString:create(""));
                buffEffectSprite:retain()
                buffEffectSprite:setAnchorPoint(ccp(0.5, 0.5));

                buffEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(buffEffectSprite,99999);
                else
                    m_playerCardLayer:addChild(buffEffectSprite,99999);
                end
                buffEffectSprite:release()
                --delegate
                local animationEnd = function(actionName,xmlSprite)
                    --增加buff
                    if(buff.icon~=nil and buff.icon~="")then
                        local buffSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. buff.icon), -1,CCString:create(""));
                        buffSprite:retain()
                        buffSprite:setAnchorPoint(ccp(0.5, 0));
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
                        m_cardBuffArray[card_o:getTag()][#m_cardBuffArray[card_o:getTag()]+1] = buff.id
                    end
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

                    m_cardBuffArray[card_o:getTag()][#m_cardBuffArray[card_o:getTag()]+1] = buff.id
                end
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
                return
            end
        else
            updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
            return
        end
    end

    --显示BUFF效果
    if(bufferArray~=nil and #(bufferArray)>=currentIndex-#(deBufferArray)-#(imBufferArray)-#(enBufferArray)) then
        ----print("111111111111111111111111111")
        local bufferInfo = bufferArray[currentIndex-#(deBufferArray)-#(imBufferArray)-#(enBufferArray)]
        require "db/DB_Buffer"
        local mybuff = DB_Buffer.getDataById(tonumber(bufferInfo.bufferId))

        if(mybuff~=nil and (mybuff.damageTimeType == timeType or timeType==nil or (mybuff.damageTimeType==2 and timeType==3)))then
            if(bufferInfo.type == 9) then
                --击中特效
                if(mybuff ~= nil and mybuff.damageEff ~= nil) then
                    --音效
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
                    damageEffectSprite:setAnchorPoint(ccp(0.5, 0.5));

                    damageEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY());
                    card_o:getParent():addChild(damageEffectSprite,998,card_o:getTag()+5000);
                    local animationEnd = function(actionName,xmlSprite)
                        updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
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
                    ----print("显示BUFF效果 mybuff.damageEff ~= nil")
                end
                local damageTitleStr = nil
                if(mybuff.damagetitle~=nil)then
                    damageTitleStr = IMG_PATH .. "number/" .. mybuff.damagetitle
                end
                if(tonumber(bufferInfo.data)>=0)then
                    showCardNumber(card_o,tonumber(bufferInfo.data),1,damageTitleStr)
                else
                    showCardNumber(card_o,tonumber(bufferInfo.data),0,damageTitleStr)
                end

                local damage = tonumber(bufferInfo.data)
                if(hid~=nil)then

                    local afterHp = m_currentHpTable[hid]+damage
                    m_currentHpTable[hid] = afterHp
                    if(card_o~=nil) then
                        if(afterHp<1) then
                            afterHp = 0
                            card_o:setOpacity(0)
                            local tempCard = createBattleCard(hid)
                            tempCard:setPosition(card_o:getPositionX(),card_o:getPositionY())
                            tempCard:setBasePoint(ccp(tempCard:getPositionX(),tempCard:getPositionY()))

                            BattleCardUtil.setCardHp(tempCard,0)
                            local animationEnd = function(actionName,xmlSprite)
                                tempCard:removeFromParentAndCleanup(true)
                            end

                            local animationFrameChanged = function(frameIndex,xmlSprite)
                            end

                            --增加动画监听
                            local delegate = BTAnimationEventDelegate:create()
                            delegate:registerLayerEndedHandler(animationEnd)
                            delegate:registerLayerChangedHandler(animationFrameChanged)
                            tempCard:setDelegate(delegate)

                            tempCard:runXMLAnimation(CCString:create("images/battle/xml/action/T007_0"))
                            card_o:getParent():addChild(tempCard,card_o:getZOrder())


                            if(m_currentIsAttackerEnemy == false) then
                                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. card_o:getTag()%10]

                                local deadSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/deada"), -1,CCString:create(""))
                                deadSprite:setAnchorPoint(ccp(0.5, 0.5));
                                deadSprite:setPosition(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height*0.1);
                                m_playerCardLayer:addChild(deadSprite,0,card_o:getTag()+8115);

                                local animationEnd = function(actionName,xmlSprite)
                                    deadSprite:cleanup()
                                    local ghostFireSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/guihuo"), -1,CCString:create(""))
                                    ghostFireSprite:setAnchorPoint(ccp(0.5, 0.5));
                                    ghostFireSprite:setPosition(0,-50);
                                    deadSprite:addChild(ghostFireSprite,1);
                                end

                                local animationFrameChanged = function(frameIndex,xmlSprite)
                                end

                                --增加动画监听
                                local delegate = BTAnimationEventDelegate:create()
                                delegate:registerLayerEndedHandler(animationEnd)
                                delegate:registerLayerChangedHandler(animationFrameChanged)
                                deadSprite:setDelegate(delegate)

                            end
                            showDropEffect(hid,card_o:convertToWorldSpace(ccp(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.5)))
                        end
                        if afterHp and m_maxHpTable[hid] then
                            BattleCardUtil.setCardHp(card_o,afterHp/m_maxHpTable[hid])
                        end
                    end
                else
                end
            elseif(bufferInfo.type == 28) then
                showCardNumber(card_o,tonumber(bufferInfo.data),3)
                local defenderId = hid

                --更新怒气
                if(m_currentAngerTable[defenderId] == nil) then
                    m_currentAngerTable[defenderId] = 0
                end
                m_currentAngerTable[defenderId] = m_currentAngerTable[defenderId] + tonumber(bufferInfo.data)
                BattleCardUtil.setCardAnger(card_o, m_currentAngerTable[defenderId], defenderId)
            end

            if(mybuff == nil or mybuff.damageEff == nil) then
                updateCardBuff(hid,card_o,timeType,enBufferArray,deBufferArray,imBufferArray,bufferArray,callbackFunc,currentIndex+1)
            end
            return false

        end
    end
    if callbackFunc then
        callbackFunc()
    end
end


function afterAttackUpdateBuff()
    local millisecond1 = os.clock()
    updateCardBuff(m_currentBattleBlock.attacker,m_currentAttacker,3,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,showNextMove,1)
    local millisecond2 = os.clock();
end

function goBack()
    local millisecond1 = os.clock()
    if(m_onBattleView~=nil)then
        m_onBattleView.battleBlockChanged(m_currentBattleBlock)
    end
    if tolua.cast(m_currentAttacker, "CCXMLSprite") == nil or m_currentAttackerIndex == nil then
        --战车
        showNextMove()
        return
    end

    if(m_currentIsAttackerEnemy) then
        local position = getEnemyCardPointByPosition(m_currentAttackerIndex)
        if(position.x>m_currentAttacker:getPositionX()-1 and position.x<m_currentAttacker:getPositionX()+1 and position.y>m_currentAttacker:getPositionY()-1 and position.y<m_currentAttacker:getPositionY()+1)then

            afterAttackUpdateBuff()
        else
            local attackerActionArray = CCArray:create()
            attackerActionArray:addObject(CCMoveTo:create(0.2, position))
            attackerActionArray:addObject(CCCallFunc:create(afterAttackUpdateBuff))
            m_currentAttacker:runAction(CCSequence:create(attackerActionArray))

        end
    else
        local position = getPlayerCardPointByPosition(m_currentAttackerIndex)
        if(position.x>m_currentAttacker:getPositionX()-1 and position.x<m_currentAttacker:getPositionX()+1 and position.y>m_currentAttacker:getPositionY()-1 and position.y<m_currentAttacker:getPositionY()+1)then
            afterAttackUpdateBuff()
        else

            local attackerActionArray = CCArray:create()
            local position = getPlayerCardPointByPosition(m_currentAttackerIndex)
            attackerActionArray:addObject(CCMoveTo:create(0.2, position))
            attackerActionArray:addObject(CCCallFunc:create(afterAttackUpdateBuff))
            m_currentAttacker:runAction(CCSequence:create(attackerActionArray))

        end
    end

    local millisecond2 = os.clock();
end

function updateChildDefendersBuff()
    if(m_currentChildSkillIndex==nil or m_currentBattleBlock.arrChild == nil or m_currentBattleBlock.arrChild[m_currentChildSkillIndex] == nil)then
        return
    end

    local currentChildSkillIndex = m_currentChildSkillIndex
    if(m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction==nil)then
        showChildBattleAttack()
        return
    end
    -- 更新我方
    local attackerId = m_currentBattleBlock.arrChild[currentChildSkillIndex].attacker
    local card_a = nil
    for j=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[j]
        if(role.hid==attackerId) then
            card_a = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
            isDefenderEnemy = false
            break
        end
    end

    for j=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[j]
        if(role.hid==attackerId) then
            card_a = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            break
        end
    end
    if(card_a ~= nil) then
        updateCardBuff(attackerId,card_a,nil,m_currentBattleBlock.arrChild[currentChildSkillIndex].enBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].deBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].imBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].buffer,nil,1)
    end

    --更新敌方
    for i=1,#(m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction) do
        --获得反应卡牌

        local card_o = nil
        
        local defenderId = m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].defender
        
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

        --处理伤害
        if(card_o ~= nil) then
            playClearBufferEffect(card_o, m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].clear)
            if(i==#(m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction))then
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].enBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].deBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].imBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].buffer,showChildBattleAttack,1)
            else
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].enBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].deBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].imBuffer,m_currentBattleBlock.arrChild[currentChildSkillIndex].arrReaction[i].buffer,nil,1)
            end
        end
    end
end

function showChildDefenderDamage(node,currentBattleIndex,currentSkillIndex,totalSkillTimes)
    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]

    local isEnemy = true
    if(math.floor(node:getTag()/1000)==4) then
        isEnemy = false
    end

    local hid = 0

    local damage = 0
    local isFatal = false

    local card = nil

    if(isEnemy == true) then

        for i=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[i]

            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
                break
            end
        end

    else

        for i=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[i]
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
                break
            end
        end
    end
    local isManDown = false

    for i=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) do
        if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage ~= nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender == hid) then
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
    if(m_currentSkillAttackIndex>=m_currentSkillAttackTimes)then

        local afterHp = m_currentHpTable[hid]-damage
        m_currentHpTable[hid] = afterHp
        if(card~=nil) then
            if(afterHp<1) then
                afterHp = 0
                card:setOpacity(0)
                local tempCard = createBattleCard(hid)
                tempCard:setPosition(card:getPositionX(),card:getPositionY())
                tempCard:setBasePoint(ccp(tempCard:getPositionX(),tempCard:getPositionY()))

                BattleCardUtil.setCardHp(tempCard,0)
                local animationEnd = function(actionName,xmlSprite)
                    tempCard:removeFromParentAndCleanup(true)
                end

                local animationFrameChanged = function(frameIndex,xmlSprite)
                end

                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                tempCard:setDelegate(delegate)

                tempCard:runXMLAnimation(CCString:create("images/battle/xml/action/T007_0"));

                card:getParent():addChild(tempCard,card:getZOrder())
                if(isEnemy == false) then
                    m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. node:getTag()%10]

                    local deadSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/deada"), -1,CCString:create(""))
                    deadSprite:setAnchorPoint(ccp(0.5, 0.5));
                    deadSprite:setPosition(card:getPositionX(),card:getPositionY()-card:getContentSize().height*0.1);
                    m_playerCardLayer:addChild(deadSprite,0,card:getTag()+8115);

                    local animationEnd = function(actionName,xmlSprite)
                        deadSprite:cleanup()
                        local ghostFireSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/guihuo"), -1,CCString:create(""))
                        ghostFireSprite:setAnchorPoint(ccp(0.5, 0.5));
                        ghostFireSprite:setPosition(0,-50);
                        deadSprite:addChild(ghostFireSprite,1);
                    end

                    local animationFrameChanged = function(frameIndex,xmlSprite)
                    end

                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    deadSprite:setDelegate(delegate)

                end
                showDropEffect(hid,card:convertToWorldSpace(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5)))
            end
            if afterHp and m_maxHpTable[hid] then
                BattleCardUtil.setCardHp(card,afterHp/m_maxHpTable[hid])
            end
        end
        if(node~=nil) then
            if(afterHp<1) then
                afterHp = 0
            end
            if afterHp and m_maxHpTable[hid] then
                BattleCardUtil.setCardHp(node,afterHp/m_maxHpTable[hid])
            end
        end

    end

    if(m_currentSkillAttackTimes~=0)then
        damage = damage/m_currentSkillAttackTimes
    end

    local fontWidth = 43
    local numberPath = "number/red"
    if(isFatal)then
        numberPath = "number/critical"
        fontWidth = 50
        local criticalLabel = CCSprite:create(IMG_PATH .. "number/critical.png")
        criticalLabel:setAnchorPoint(ccp(0.5,0))
        criticalLabel:setPosition(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.75)
        if(isEnemy) then
            m_enemyCardLayer:addChild(criticalLabel,999999)
        else
            m_playerCardLayer:addChild(criticalLabel,999999)
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
    damageLabel:setAnchorPoint(ccp(0.5,0.5))
    --damageLabel:setPosition(node:getPositionX()+math.random(-node:getContentSize().width*0.3,node:getContentSize().width*0.3),node:getPositionY()+node:getContentSize().height*0.5+math.random(-node:getContentSize().width*0.3,node:getContentSize().width*0.3))
    damageLabel:setPosition(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.5)
    ----print("=========== showChildDefenderDamage 4")
    if(isEnemy) then
        m_enemyCardLayer:addChild(damageLabel,999999)
    else
        m_playerCardLayer:addChild(damageLabel,999999)
    end

    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCScaleTo:create(0.1,2))
    damageActionArray:addObject(CCScaleTo:create(0.05,1))
    damageActionArray:addObject(CCDelayTime:create(1))
    damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))

    return
end

function showChildDefenderEffect(currentBattleIndex,currentSkillIndex,totalSkillTimes)

    local delayTime = 0
    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]
    ----print("===== showChildDefenderEffect:",m_currentChildSkillIndex,m_currentBattleBlock.arrChild,m_currentBattleBlock.arrChild[m_currentChildSkillIndex])
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

        ----print("===== showChildDefenderEffect 1:",m_battleIndex)
        local card_o = nil
        local isDefenderEnemy = false

        local defenderId = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
                isDefenderEnemy = false
                --m_currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                break
            end
        end

        ----print("===== showChildDefenderEffect 2:",m_battleIndex)
        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
                card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
                isDefenderEnemy = true
                break
            end
        end
        --处理伤害
        if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage ~= nil and card_o ~= nil) then
            --card_o:setVisible(false)
            if(m_currentSkillAttackIndex<=1)then
                setNodeNotVisible(card_o)
            end
            local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
            require "db/skill"
            local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid());
            ---[[
            local card = nil
            if(isDefenderEnemy) then
                card = tolua.cast(m_enemyCardLayer:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
            else
                card = tolua.cast(m_playerCardLayer:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
            end
            ----print("hurt sprite:",card)
            if(card == nil)then
                card = createBattleCard(defenderId)
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(card,card_o:getZOrder())
                else
                    m_playerCardLayer:addChild(card,card_o:getZOrder())
                end
            end
            --]]
            card:setVisible(true)
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height*0.5))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            if m_currentHpTable[defenderId] and m_maxHpTable[defenderId] then
                BattleCardUtil.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
            end
            --更新怒气
            if(m_currentAngerTable[defenderId] == nil) then
                m_currentAngerTable[defenderId] = 0
            end
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

            local callback4ShowDefenderDamage = function()
                showChildDefenderDamage(card,currentBattleIndex,currentSkillIndex,totalSkillTimes)
            end
            ----print("=========skillTime============",skillTime)
            local defenderActionArray = CCArray:create()
            --defenderActionArray:addObject(CCDelayTime:create(skillTime/2))
            defenderActionArray:addObject(CCCallFuncN:create(callback4ShowDefenderDamage))
            defenderActionArray:addObject(CCDelayTime:create(skillTime))
            ----print("showdefendereffect hurt:",m_currentSkillAttackIndex,m_currentSkillAttackTimes,m_battleIndex)
            if(m_currentSkillAttackIndex > m_currentSkillAttackTimes) then
            ----print("showdefendereffect m_currentSkillAttackIndex > m_currentSkillAttackTimes:",m_currentSkillAttackIndex,m_currentSkillAttackTimes,skill.id)
            end
            --defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes) then
                ----print("do removeCard!")
                defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
                defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
                --defenderActionArray:addObject(CCCallFuncN:create(setNodeNotVisible))
            end
            card:stopAllActions()
            card:runAction(CCSequence:create(defenderActionArray))

            local skillHitEffect = skill.hitEffct
            if((m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].reaction == 4))then
                skillHitEffect = "heffect_10"
                showCardNumber(card,GetLocalizeStringBy("key_2305"),5)
            end

            delayTime = (delayTime>skillTime) and delayTime or skillTime

            ----print("===== showChildDefenderEffect 5:",skillHitEffect,skill.mpostionType)
            ---[[
            --击中特效
            if(skillHitEffect ~= nil and tonumber(skill.mpostionType)~=7) then
                --音效
                ----print("skillHitEffect:","audio/effect/" .. skillHitEffect .. ".mp3",m_currentSkillAttackIndex,i)
                if(file_exists("audio/effect/" .. skillHitEffect .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then

                    AudioUtil.playEffect("audio/effect/" .. skillHitEffect .. ".mp3")
                end

                local damageEffectSprite
                ---[[
                if(isDefenderEnemy) then
                    damageEffectSprite = m_enemyCardLayer:getChildByTag(card_o:getTag()+5000);
                else
                    damageEffectSprite = m_playerCardLayer:getChildByTag(card_o:getTag()+5000);
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
                        m_playerCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
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

                    ----print("===== showChildDefenderEffect 6:",m_battleIndex)
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    damageEffectSprite = tolua.cast(damageEffectSprite,"CCLayerSprite")
                    damageEffectSprite:setDelegate(delegate)
                end
            end
            --]]
            ----print("m_currentSkillAttackIndex == m_currentSkillAttackTimes",m_currentSkillAttackIndex,m_currentSkillAttackTimes)
            if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
                local defenderActionArray = CCArray:create()
                defenderActionArray:addObject(CCDelayTime:create(delayTime))
                defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
                defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
                card_o:runAction(CCSequence:create(defenderActionArray))
            end
        elseif(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].reaction == 2) then
            --闪避
            --card_o:setVisible(false)

            if(m_currentSkillAttackIndex<=1)then
                setNodeNotVisible(card_o)
            end

            local card = createBattleCard(defenderId)
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            if(isDefenderEnemy) then
                m_enemyCardLayer:addChild(card,card_o:getZOrder())
            else
                m_playerCardLayer:addChild(card,card_o:getZOrder())
            end
            if m_currentHpTable[defenderId] and m_maxHpTable[defenderId] then
                BattleCardUtil.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
            end
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
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
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
            --闪避依旧播放特效

            local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
            require "db/skill"
            local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())
            local skillHitEffect = skill.hitEffct
            delayTime = (delayTime>skillTime) and delayTime or skillTime
            ---[[
            --击中特效
            if(skillHitEffect ~= nil and tonumber(skill.mpostionType)~=7) then
                --音效
                ----print("skillHitEffect:","audio/effect/" .. skillHitEffect .. ".mp3",m_currentSkillAttackIndex,i)
                if(file_exists("audio/effect/" .. skillHitEffect .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then
                    AudioUtil.playEffect("audio/effect/" .. skillHitEffect .. ".mp3")
                end

                local damageEffectSprite
                ---[[
                if(isDefenderEnemy) then
                    damageEffectSprite = m_enemyCardLayer:getChildByTag(card_o:getTag()+5000);
                else
                    damageEffectSprite = m_playerCardLayer:getChildByTag(card_o:getTag()+5000);
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
                        m_playerCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                    end
                    damageEffectSprite:release()

                end

                --print("===== showChildDefenderEffect c:",skillHitEffect,skill.mpostionType)
                if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
                    --delegate
                    local animationEnd = function(actionName,xmlSprite)
                        removeSelf(damageEffectSprite)
                    end

                    local animationFrameChanged = function(frameIndex,xmlSprite)
                    end

                    ----print("===== showChildDefenderEffect 6:",m_battleIndex)
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    damageEffectSprite = tolua.cast(damageEffectSprite,"CCLayerSprite")
                    damageEffectSprite:setDelegate(delegate)

                    --print("===== showChildDefenderEffect d:",skillHitEffect,skill.mpostionType)
                end
            end
        else
            ----print("child unknown things here")
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

function showChildAttackTrail(currentBattleIndex,currentSkillIndex,totalSkillTimes)

    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]
    if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction == nil) then
        updateChildDefendersBuff()
        return
    end
    local delayTime = 0
    for i=1,#(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) do
        --获得反应卡牌

        ----print("=========showAttackTrail============ 1",m_currentChildSkillIndex)
        local card = nil
        local currentIsDefenderEnemy = false

        local defenderId = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
        local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

        --处理伤害
        if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage ~= nil and card ~= nil and (skill.mpostionType==4 or skill.mpostionType==3) and skill.distancePath~=nil) then

            local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5))
            local endPoint = card:convertToWorldSpace(ccp(card:getContentSize().width*card:getScale()*0.5, card:getContentSize().height*card:getScale()*0.5))
            --播放音效
            ----print("AudioUtil:","audio/effect/" .. skill.distancePath .. ".mp3")
            if(file_exists("audio/effect/" .. skill.distancePath .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then

                AudioUtil.playEffect("audio/effect/" .. skill.distancePath .. ".mp3")
            end

            local trailSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.distancePath), -1,CCString:create(""))
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
    ----print("=====showChildAttackTrail delayTime:",delayTime)
    if(delayTime==0)then
        ----print("=====showChildAttackTrail showChildDefenderEffect")
        showChildDefenderEffect(currentBattleIndex,currentSkillIndex,totalSkillTimes)
    else
        local callback4ShowDefenderEffect = function()
            showChildDefenderEffect(currentBattleIndex,currentSkillIndex,totalSkillTimes)
        end

        local nextActionArray = CCArray:create()
        nextActionArray:addObject(CCDelayTime:create(delayTime))
        nextActionArray:addObject(CCCallFunc:create(callback4ShowDefenderEffect))
        m_bg:runAction(CCSequence:create(nextActionArray))
    end
end

function showChildAttackEffect()
    ----print("============ showChildAttackEffect ==================",m_battleIndex)
    ---[[
    if m_currentBattleBlock.arrChild == nil then
        return
    end
    local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action
    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

    if(skill.attackEffct==nil or skill.attackEffct=="" or m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction==nil)then
        ----print("showAttackEffect skill.attackEffct==nil")
        m_currentSkillAttackIndex = 1
        m_currentSkillAttackTimes = 1
        showChildAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
        return
    end
    ----print("showAttackEffect skill.attackEffct~=nil")

    --音效
    ----print("skill.attackEffct:","audio/effect/" .. skill.attackEffct .. ".mp3")
    if(skill.attackEffct~=nil and file_exists("audio/effect/" .. skill.attackEffct .. ".mp3")) then

        AudioUtil.playEffect("audio/effect/" .. skill.attackEffct .. ".mp3")
    end

    --释放特效
    local isShowCountDamage = false
    local isAlreadyShowCount = false
    if tonumber(skill.functionWay) == 2 or tonumber(skill.showDamage) == 1 then
        isShowCountDamage = true
    end
    if m_currentBattleBlock.arrReaction and isShowCountDamage then
        if table.count(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction) > 1 then
            isAlreadyShowCount = true
            local totalBlock = m_currentBattleBlock.arrChild[m_currentChildSkillIndex]
            performWithDelay(m_bg, function ( ... )
                -- 总伤害添加
                showTotalDamage(totalBlock)
            end, 0.5)
        end
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
                m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
            end
        else

            if(m_currentIsDefenderEnemy) then
                ----print("-------------m_currentIsDefenderEnemy")
                local position = getEnemyCardPointByPosition(1)
                spellEffectSprite:setPosition(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5));
                m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
            else
                local position = getPlayerCardPointByPosition(4)
                spellEffectSprite:setPosition(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5));
                m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
            end
        end
        --spellEffectSprite:release()

        --m_currentSkillAttackTimes = 1

        m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
        m_currentSkillAttackIndex = 0

        --delegate
        local totalBlock = m_currentBattleBlock.arrChild[m_currentChildSkillIndex]
        local animationEnd = function(actionName,xmlSprite)
            if(m_currentSkillAttackTimes>1 and isAlreadyShowCount == false and isShowCountDamage)then
                showTotalDamage(totalBlock)
            end
            endShake()
            updateChildDefendersBuff()
            spellEffectSprite:removeFromParentAndCleanup(true)
        end

        local animationFrameChanged = function(frameIndex,xmlSprite)
            ----print("animationFrameChanged:",frameIndex,xmlSprite)
            local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
            if(tempSprite:getIsKeyFrame()) then
                m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
                showChildAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
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
                    card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

            ----print("m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage:",m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction[i].arrDamage)
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
                        m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
                    end
                else
                    --脚下
                    spellEffectSprite:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height/2));
                    if(m_currentIsAttackerEnemy) then
                        m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
                    else
                        m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
                    end
                end
                spellEffectSprite:release()

                --m_currentSkillAttackTimes = 1

                m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
                m_currentSkillAttackIndex = 0

                --delegate
                local totalBlock = m_currentBattleBlock.arrChild[m_currentChildSkillIndex]
                local animationEnd = function(actionName,xmlSprite)
                    if(m_currentSkillAttackTimes>1 and isAlreadyShowCount == false and isShowCountDamage)then
                        showTotalDamage(totalBlock)
                    end
                    endShake()
                    updateChildDefendersBuff()
                    spellEffectSprite:removeFromParentAndCleanup(true)
                end

                local animationFrameChanged = function(frameIndex,xmlSprite)
                    ----print("animationFrameChanged:",frameIndex,xmlSprite,xmlSprite:getTag())
                    local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
                    if(tempSprite:getIsKeyFrame()) then
                        m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
                        showChildAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
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

function showChildBattleAttack()

    local millisecond1 = os.clock();

    m_currentChildSkillIndex = m_currentChildSkillIndex + 1
    if(m_currentBattleBlock.arrChild == nil or m_currentChildSkillIndex>#m_currentBattleBlock.arrChild)then
        ----print("child round done")
        goBack()
        return
    end
    --无反应无动作
    if(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].arrReaction == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].enBuffer == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].deBuffer == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].imBuffer == nil and m_currentBattleBlock.arrChild[m_currentChildSkillIndex].buffer == nil)then
        ----print("child round done2")
        showChildBattleAttack()
        -- currentRoundOver()
        -- goBack()
        return
    end
    print("child skill index =》", m_currentChildSkillIndex)
    --m_currentAttacker:setVisible(false)
    setNodeNotVisible(m_currentAttacker)

    local skillID = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

    local card = createBattleCard(m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker)
    card:setTag(4900)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(m_currentIsAttackerEnemy) then
        m_enemyCardLayer:addChild(card,m_currentAttacker:getZOrder())
    else
        m_playerCardLayer:addChild(card,m_currentAttacker:getZOrder())
    end
    local curHp = m_currentHpTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker]
    local maxHp = m_maxHpTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker]
    if curHp and maxHp then
        BattleCardUtil.setCardHp(card,m_currentHpTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker]/m_maxHpTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker])
    end
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker] = 0
    end
    local hid = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker
    BattleCardUtil.setCardAnger(card, m_currentAngerTable[hid], hid)
    BattleCardUtil.setCardAnger(m_currentAttacker, m_currentAngerTable[hid], hid)
    local animationEnd = function()

        showAttackerVisible()


        if(skill.attackEffct==nil or skill.attackEffct=="")then

            print("child skill index 1=》", m_currentChildSkillIndex)
            local damageActionArray = CCArray:create()
            damageActionArray:addObject(CCDelayTime:create(1))
            damageActionArray:addObject(CCCallFunc:create(updateChildDefendersBuff))
            m_bg:runAction(CCSequence:create(damageActionArray))
        end
        card:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
        ----print("animationFrameChanged:",frameIndex,skill.id,skill.actionid)
        local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
        if(tempSprite:getIsKeyFrame()) then
            ----print("showBattleAttack tempSprite:getIsKeyFrame")
            print("child skill index 2=》", m_currentChildSkillIndex)
            showChildAttackEffect()
            print("child skill index 3=》", m_currentChildSkillIndex)
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
    local hid = m_currentBattleBlock.arrChild[m_currentChildSkillIndex].attacker
    BattleCardUtil.setCardAnger(m_currentAttacker, m_currentAngerTable[hid], hid)

end

local delayDone = false
function updateDefendersBuff()

    local millisecond1 = os.clock()
    if(m_currentBattleBlock==nil or m_currentBattleBlock.arrReaction==nil)then
        --goBack()
        if(m_currentBattleBlock.arrChild==nil)then
            currentRoundOver()
        end
        showChildBattleAttack()
        return
    end
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌

        local card_o = nil
        local isDefenderEnemy = false
        ----print("m_currentBattleBlock.arrReaction[i]:",i,m_currentBattleBlock.arrReaction[i],m_battleIndex)
        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

        local isManDown = false
        for i=1,#(m_currentBattleBlock.arrReaction) do
            if(m_currentBattleBlock.arrReaction[i].defender == defenderId) then
                if(m_currentBattleBlock.arrReaction[i].mandown~=nil and m_currentBattleBlock.arrReaction[i].mandown == true)then
                    isManDown = true
                end
            end
        end
        --暂时不判断后端死亡标志位
        --处理伤害
        if(card_o ~= nil and isManDown ~= true) then
            playClearBufferEffect(card_o, m_currentBattleBlock.arrReaction[i].clear)
            if(i==#(m_currentBattleBlock.arrReaction))then
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrReaction[i].enBuffer,m_currentBattleBlock.arrReaction[i].deBuffer,m_currentBattleBlock.arrReaction[i].imBuffer,m_currentBattleBlock.arrReaction[i].buffer,showChildBattleAttack,1)
            else
                updateCardBuff(defenderId,card_o,nil,m_currentBattleBlock.arrReaction[i].enBuffer,m_currentBattleBlock.arrReaction[i].deBuffer,m_currentBattleBlock.arrReaction[i].imBuffer,m_currentBattleBlock.arrReaction[i].buffer,nil,1)
            end
        elseif(isManDown == true and card_o ~= nil)then
            if(card_o:getOpacity()>240)then
                card_o:stopAllActions()
                --card_o:runAction(CCFadeOut:create(1))

                ----print("2529 dead card:",card_o:getTag())
                card_o:setOpacity(0)
                local tempCard = createBattleCard(defenderId)
                tempCard:setPosition(card_o:getPositionX(),card_o:getPositionY())
                tempCard:setBasePoint(ccp(tempCard:getPositionX(),tempCard:getPositionY()))

                BattleCardUtil.setCardHp(tempCard,0)
                local animationEnd = function(actionName,xmlSprite)
                    tempCard:removeFromParentAndCleanup(true)
                end

                local animationFrameChanged = function(frameIndex,xmlSprite)
                end

                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                tempCard:setDelegate(delegate)
                tempCard:runXMLAnimation(CCString:create("images/battle/xml/action/T007_0"));
                card_o:getParent():addChild(tempCard,card_o:getZOrder())
                if(card_o:getTag()>=1000 and card_o:getTag()<=1005) then
                    m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. card_o:getTag()%10]

                    local deadSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/deada"), -1,CCString:create(""))
                    deadSprite:setAnchorPoint(ccp(0.5, 0.5));
                    deadSprite:setPosition(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height*0.1);
                    m_playerCardLayer:addChild(deadSprite,0,card_o:getTag()+8115);
                    local animationEnd = function(actionName,xmlSprite)
                        deadSprite:cleanup()
                        local ghostFireSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/guihuo"), -1,CCString:create(""))
                        ghostFireSprite:setAnchorPoint(ccp(0.5, 0.5));
                        ghostFireSprite:setPosition(0,-50);
                        deadSprite:addChild(ghostFireSprite,1);
                    end
                    local animationFrameChanged = function(frameIndex,xmlSprite)
                    end
                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    deadSprite:setDelegate(delegate)

                    --card:removeFromParentAndCleanup(true)
                end
                showDropEffect(hid,card_o:convertToWorldSpace(ccp(card_o:getContentSize().width*0.5,card_o:getContentSize().height*0.5)))
            end
            if(i==#(m_currentBattleBlock.arrReaction))then
                showChildBattleAttack()
            end
        end

    end

    local millisecond2 = os.clock();
----print("updatedefendersbuff millisecond:",m_battleIndex,millisecond1,millisecond2-millisecond1)
end

function showDefenderDamage(node,currentBattleIndex,currentSkillIndex,totalSkillTimes)

    local millisecond1 = os.clock();
    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]
    local m_currentSkillAttackIndex = currentSkillIndex
    local m_currentSkillAttackTimes = totalSkillTimes
    local isEnemy = true
    if(math.floor(node:getTag()/1000)==4) then
        isEnemy = false
    end
    local hid = 0
    local damage = 0
    local isFatal = false
    local card = nil

    if(isEnemy == true) then
        for i=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[i]

            ----print("-----------------role.position,node:getTag",role.position,(node:getTag()%10))
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
                break
            end
        end
    else
        for i=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[i]
            ----print("-----------------role.position,node:getTag",role.position,(node:getTag()%10))
            if(role.position==node:getTag()%10) then
                hid = role.hid
                card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
                break
            end
        end
    end
    for i=1,#(m_currentBattleBlock.arrReaction) do
        if(m_currentBattleBlock.arrReaction[i].arrDamage ~= nil and m_currentBattleBlock.arrReaction[i].defender == hid) then

            ----print("-----------------m_currentBattleBlock.arrReaction[i].defender:",m_currentBattleBlock.arrReaction[i].defender,hid,m_currentBattleBlock.arrReaction[i].arrDamage.damageValue)
            for j=1,#(m_currentBattleBlock.arrReaction[i].arrDamage) do
                damage = damage+m_currentBattleBlock.arrReaction[i].arrDamage[j].damageValue
            end
            --判断是否为暴击
            if(m_currentBattleBlock.arrReaction[i].fatal~=nil and m_currentBattleBlock.arrReaction[i].fatal == true)then
                isFatal = true
            end
        end
    end
    --更新hp
    if(m_currentSkillAttackIndex>=m_currentSkillAttackTimes)then

        local afterHp = m_currentHpTable[hid]-damage
        m_currentHpTable[hid] = afterHp
        if(card~=nil) then
            if(afterHp<1) then
                afterHp = 0
                card:setOpacity(0)
                local tempCard = createBattleCard(hid)
                tempCard:setPosition(card:getPositionX(),card:getPositionY())
                tempCard:setBasePoint(ccp(tempCard:getPositionX(),tempCard:getPositionY()))

                BattleCardUtil.setCardHp(tempCard,0)

                local animationEnd = function(actionName,xmlSprite)
                    tempCard:removeFromParentAndCleanup(true)
                end

                local animationFrameChanged = function(frameIndex,xmlSprite)
                end

                --增加动画监听
                local delegate = BTAnimationEventDelegate:create()
                delegate:registerLayerEndedHandler(animationEnd)
                delegate:registerLayerChangedHandler(animationFrameChanged)
                tempCard:setDelegate(delegate)
                tempCard:runXMLAnimation(CCString:create("images/battle/xml/action/T007_0"));

                card:getParent():addChild(tempCard,card:getZOrder())
                if(isEnemy == false) then
                    ----print("----------------------showDefenderDamage:",node:getTag()%10)
                    ----print("---------- dead card:",m_formation["" .. node:getTag()%10],node:getTag()%10)
                    m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = m_formation["" .. node:getTag()%10]

                    local deadSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/deada"), -1,CCString:create(""))
                    deadSprite:setAnchorPoint(ccp(0.5, 0.5));
                    deadSprite:setPosition(card:getPositionX(),card:getPositionY()-card:getContentSize().height*0.1);
                    m_playerCardLayer:addChild(deadSprite,0,card:getTag()+8115);

                    local animationEnd = function(actionName,xmlSprite)
                        deadSprite:cleanup()
                        local ghostFireSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/guihuo"), -1,CCString:create(""))
                        ghostFireSprite:setAnchorPoint(ccp(0.5, 0.5));
                        ghostFireSprite:setPosition(0,-50);
                        deadSprite:addChild(ghostFireSprite,1);
                    end

                    local animationFrameChanged = function(frameIndex,xmlSprite)
                    end

                    --增加动画监听
                    local delegate = BTAnimationEventDelegate:create()
                    delegate:registerLayerEndedHandler(animationEnd)
                    delegate:registerLayerChangedHandler(animationFrameChanged)
                    deadSprite:setDelegate(delegate)

                end
                showDropEffect(hid,card:convertToWorldSpace(ccp(card:getContentSize().width*0.5,card:getContentSize().height*0.5)))
            end
            if afterHp and m_maxHpTable[hid] then
                BattleCardUtil.setCardHp(card,afterHp/m_maxHpTable[hid])
            end
        end

        if(node~=nil) then
            if(afterHp<1) then
                afterHp = 0
            end
            if afterHp and m_maxHpTable[hid] then
                BattleCardUtil.setCardHp(node,afterHp/m_maxHpTable[hid])
            end
        end

    end

    if(m_currentSkillAttackTimes~=0)then
        damage = damage/m_currentSkillAttackTimes
    end
    local fontWidth = 43
    ----print("damageLabel:",damage)
    local numberPath = "number/red"
    ----print("m_currentBattleBlock.arrReaction[i].fatal:",#m_currentBattleBlock.arrReaction,m_currentBattleBlock.arrReaction[i],i)
    if(isFatal)then
        numberPath = "number/critical"
        fontWidth = 50
        ----print("do the critical")
        local criticalLabel = CCSprite:create(IMG_PATH .. "number/critical.png")
        criticalLabel:setAnchorPoint(ccp(0.5,0))


        local cardWorldPosition = node:getParent():convertToWorldSpace(ccp(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.75))
        local cardBgPosition = m_bg:convertToNodeSpace(cardWorldPosition)

        criticalLabel:setPosition(cardBgPosition)
        m_bg:addChild(criticalLabel,9999)

        criticalLabel:setOpacity(0)

        local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCFadeIn:create(0.3))
        damageActionArray:addObject(CCDelayTime:create(0.7))
        damageActionArray:addObject(CCFadeOut:create(0.3))
        damageActionArray:addObject(CCCallFuncN:create(removeSelf))
        criticalLabel:runAction(CCSequence:create(damageActionArray))
    end
    local damageLabel = LuaCC.createNumberSprite02(IMG_PATH .. numberPath,"-" .. math.ceil(damage),fontWidth)
    damageLabel:setAnchorPoint(ccp(0.5,0.5))
    if(totalSkillTimes>1)then

        local cardWorldPosition = node:getParent():convertToWorldSpace(ccp(node:getPositionX()+math.random(-node:getContentSize().width*0.3,node:getContentSize().width*0.3),node:getPositionY()+node:getContentSize().height*0.5+math.random(-node:getContentSize().width*0.3,node:getContentSize().width*0.3)))
        local cardBgPosition = m_bg:convertToNodeSpace(cardWorldPosition)
        damageLabel:setPosition(cardBgPosition)
        m_bg:addChild(damageLabel,9999)
    else

        local cardWorldPosition = node:getParent():convertToWorldSpace(ccp(node:getPositionX(),node:getPositionY()+node:getContentSize().height*0.5))
        local cardBgPosition = m_bg:convertToNodeSpace(cardWorldPosition)
        damageLabel:setPosition(cardBgPosition)
        m_bg:addChild(damageLabel,9999)

    end

    local damageActionArray = CCArray:create()
    damageActionArray:addObject(CCScaleTo:create(0.1,2))
    damageActionArray:addObject(CCScaleTo:create(0.05,1))
    damageActionArray:addObject(CCDelayTime:create(1))
    damageActionArray:addObject(CCScaleTo:create(0.08,0.01))
    damageActionArray:addObject(CCCallFuncN:create(removeSelf))
    damageLabel:runAction(CCSequence:create(damageActionArray))

    local millisecond2 = os.clock();
    ----print("showdefenderdamage millisecond:",m_battleIndex,millisecond1,millisecond2-millisecond1)
    return

end

function showDefenderEffect(targetHid,currentBattleIndex,currentSkillIndex,totalSkillTimes)
    --print("=====showDefenderEffect:",m_battleIndex)

    local millisecond1 = os.clock();

    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]
    local delayTime = 0
    ----print("showDefenderEffect m_currentBattleBlock:",m_currentBattleBlock,currentBattleIndex,m_battleIndex,currentSkillIndex,totalSkillTimes)
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌

        local card_o = nil
        local isDefenderEnemy = false

        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

        if(targetHid~=nil and defenderId~=targetHid)then
        --是否为单个显示
        else
            --处理伤害
            if(m_currentBattleBlock.arrReaction[i].arrDamage ~= nil and card_o ~= nil) then
                if(m_currentSkillAttackIndex<=1)then
                    setNodeNotVisible(card_o)
                end
                local skillID = m_currentBattleBlock.action
                require "db/skill"
                local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

                local card = nil
                if(isDefenderEnemy) then
                    card = tolua.cast(m_enemyCardLayer:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
                else
                    card = tolua.cast(m_playerCardLayer:getChildByTag(card_o:getTag()+3000),"CCXMLSprite")
                end
                ----print("hurt sprite:",card)
                if(card == nil)then
                    card = createBattleCard(defenderId)
                    if(isDefenderEnemy) then
                        m_enemyCardLayer:addChild(card,card_o:getZOrder())
                    else
                        m_playerCardLayer:addChild(card,card_o:getZOrder())
                    end
                end

                --]]
                card:setVisible(true)
                card:setTag(card_o:getTag()+3000)
                card:setAnchorPoint(ccp(0.5,0))
                card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()-card_o:getContentSize().height*0.5))
                card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
                if m_currentHpTable[defenderId] and m_maxHpTable[defenderId] then
                    BattleCardUtil.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
                end
                --更新怒气
                if(m_currentAngerTable[defenderId] == nil) then
                    m_currentAngerTable[defenderId] = 0
                end
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

                local callback4ShowDefenderDamage = function()
                    showDefenderDamage(card,currentBattleIndex,currentSkillIndex,totalSkillTimes)
                end
                local defenderActionArray = CCArray:create()
                defenderActionArray:addObject(CCCallFuncN:create(callback4ShowDefenderDamage))
                defenderActionArray:addObject(CCDelayTime:create(skillTime))
                if(m_currentSkillAttackIndex > m_currentSkillAttackTimes) then

                end
                if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes) then
                    defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
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
                    ----print("skillHitEffect:","audio/effect/" .. skillHitEffect .. ".mp3",m_currentSkillAttackIndex,i)
                    if(file_exists("audio/effect/" .. skillHitEffect .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then

                        AudioUtil.playEffect("audio/effect/" .. skillHitEffect .. ".mp3")
                    end

                    local damageEffectSprite
                    ---[[
                    if(isDefenderEnemy) then
                        damageEffectSprite = m_enemyCardLayer:getChildByTag(card_o:getTag()+5000);
                    else
                        damageEffectSprite = m_playerCardLayer:getChildByTag(card_o:getTag()+5000);
                    end

                    if(damageEffectSprite == nil) then
                        --]]
                        if(file_exists("images/battle/effect/" .. skillHitEffect .. ".plist")) then
                            damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skillHitEffect), -1,CCString:create(""))
                        else
                            local ef = isDefenderEnemy==true and "images/battle/effect/" .. skillHitEffect .. "_u" or "images/battle/effect/" .. skillHitEffect .. "_d"
                            damageEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create(ef), -1,CCString:create(""))
                        end
                        damageEffectSprite:retain()
                        damageEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
                        damageEffectSprite:setPosition(card_o:getPositionX(),card_o:getPositionY())
                        if(isDefenderEnemy) then
                            m_enemyCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000)
                        else
                            m_playerCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000)
                        end
                        --print("lcy --print skillHitEffect", skillHitEffect)
                        damageEffectSprite:release()
                    end
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
                    --end
                end
                --]]
                ----print("m_currentSkillAttackIndex == m_currentSkillAttackTimes",m_currentSkillAttackIndex,m_currentSkillAttackTimes)
                if(m_currentSkillAttackIndex >= m_currentSkillAttackTimes or m_currentSkillAttackTimes == 0) then
                    local defenderActionArray = CCArray:create()
                    defenderActionArray:addObject(CCDelayTime:create(delayTime))
                    defenderActionArray:addObject(CCCallFuncN:create(setNodeVisible))
                    if(m_currentBattleBlock.arrChild==nil and skill.mpostionType~=5)then
                        ----print("currentRoundOver 2867")
                        defenderActionArray:addObject(CCDelayTime:create(0.5))
                        defenderActionArray:addObject(CCCallFunc:create(currentRoundOver))
                    end
                    card_o:runAction(CCSequence:create(defenderActionArray))
                end
            elseif(m_currentBattleBlock.arrReaction[i].reaction == 2 and card_o~=nil) then
                ----print("m_currentBattleBlock.arrReaction[i].reaction == 2")
                --闪避
                --card_o:setVisible(false)
                if(m_currentSkillAttackIndex<=1)then
                    setNodeNotVisible(card_o)
                end

                local card = createBattleCard(defenderId)
                card:setTag(card_o:getTag()+17000)
                card:setAnchorPoint(ccp(0.5,0.5))
                card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
                card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
                if(isDefenderEnemy) then
                    m_enemyCardLayer:addChild(card,card_o:getZOrder())
                else
                    m_playerCardLayer:addChild(card,card_o:getZOrder())
                end
                if m_currentHpTable[defenderId] and m_maxHpTable[defenderId] then
                    BattleCardUtil.setCardHp(card,m_currentHpTable[defenderId]/m_maxHpTable[defenderId])
                end
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
                defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
                --defenderActionArray:addObject(CCCallFuncN:create(setNodeNotVisible))
                --end
                card:stopAllActions()
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
                local skillID = m_currentBattleBlock.action
                require "db/skill"
                local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())
                local skillHitEffect = skill.hitEffct

                --击中特效
                if(skillHitEffect ~= nil and tonumber(skill.mpostionType)~=7) then
                    --音效
                    ----print("skillHitEffect:","audio/effect/" .. skillHitEffect .. ".mp3",m_currentSkillAttackIndex,i)
                    if(file_exists("audio/effect/" .. skillHitEffect .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then

                        AudioUtil.playEffect("audio/effect/" .. skillHitEffect .. ".mp3")
                    end

                    local damageEffectSprite
                    ---[[
                    if(isDefenderEnemy) then
                        damageEffectSprite = m_enemyCardLayer:getChildByTag(card_o:getTag()+5000);
                    else
                        damageEffectSprite = m_playerCardLayer:getChildByTag(card_o:getTag()+5000);
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
                            m_playerCardLayer:addChild(damageEffectSprite,99999,card_o:getTag()+5000);
                        end
                        damageEffectSprite:release()

                    end

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
                    --end
                end

                --]]
            else
                ----print("unknown things here",m_currentBattleBlock.arrReaction[i].reaction)
                if(m_currentBattleBlock.arrChild==nil)then
                    currentRoundOver()
                end
            end
        end
    end
    local millisecond2 = os.clock();
end

function showAttackTrailThough(currentBattleIndex)

    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]
    --print("============showAttackTrailThough:",m_battleIndex)
    if(m_currentBattleBlock.arrReaction == nil) then
        --goBack()
        ----print("do updateDefendersBuff 3005")
        updateDefendersBuff()
        return
    end

    local delayTime = 0

    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

    local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));

    local endPoint = ccp(beginPoint.x,CCDirector:sharedDirector():getWinSize().height+m_currentAttacker:getContentSize().height);
    if(m_currentIsAttackerEnemy==true)then
        endPoint = ccp(beginPoint.x,-m_currentAttacker:getContentSize().height);
    end

    --播放音效
    ----print("AudioUtil:","audio/effect/" .. skill.distancePath .. ".mp3")
    if(file_exists("audio/effect/" .. skill.distancePath .. ".mp3") and m_currentSkillAttackIndex==1) then

        AudioUtil.playEffect("audio/effect/" .. skill.distancePath .. ".mp3")
    end

    local trailSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.distancePath), -1,CCString:create(""));
    trailSprite:retain()
    --trailSprite:setFlipY(m_currentIsDefenderEnemy);
    trailSprite:setAnchorPoint(ccp(0.5, 0.5));
    trailSprite:setPosition(m_bg:convertToNodeSpace(beginPoint));
    m_bg:addChild(trailSprite,11);
    trailSprite:release()
    local trailRotation = 0

    local reletivePoint = ccp(endPoint.x-beginPoint.x,endPoint.y-beginPoint.y)
    local trailRotation = math.deg(math.atan(math.abs(reletivePoint.x/reletivePoint.y)))
    if(reletivePoint.x<0)then
        trailRotation = 360 - trailRotation
    end

    if(reletivePoint.y<0)then
        trailRotation = trailRotation>180 and 540-trailRotation or 180-trailRotation
    end

    trailSprite:setRotation(trailRotation)

    local trailTime = 0.5
    -- 移动，移除，调用下个方法
    local trailActionArray = CCArray:create()
    local moveEndPoint = m_bg:convertToNodeSpace(endPoint)
    if(currentIsDefenderEnemy==false) then
    end
    trailActionArray:addObject(CCMoveTo:create(trailTime, moveEndPoint))
    trailActionArray:addObject(CCCallFuncN:create(removeSelf))
    --trailActionArray:addObject(CCCallFunc:create(showDefenderEffect))
    trailSprite:runAction(CCSequence:create(trailActionArray));


    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌

        local card = nil
        local currentIsDefenderEnemy = false
        local position = 0

        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
                currentIsDefenderEnemy = false
                --m_currentDefenderIndex = role.position
                position = role.position
                break
            end
        end

        for j=1,#(m_battleInfo.team2.arrHero) do
            local role = m_battleInfo.team2.arrHero[j]
            if(role.hid==defenderId) then
                card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
                currentIsDefenderEnemy = true
                --m_currentDefenderIndex = role.position

                position = role.position
                break
            end
        end
        ----print("m_currentBattleBlock position:",position)
        position = tonumber(position)
        --处理伤害
        if( card ~= nil and skill.distancePath~=nil) then

            local doDefenderEffect = function()

                ----print("m_currentBattleBlock showDefenderEffect:",defenderId)
                showDefenderEffect(defenderId,currentBattleIndex,1,1)
            end

            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(trailTime*0.2+trailTime*0.4*math.floor(position/3)))
            defenderActionArray:addObject(CCCallFunc:create(doDefenderEffect))
            --trailActionArray:addObject(CCCallFunc:create(showDefenderEffect))
            card:runAction(CCSequence:create(defenderActionArray));
        end

    end
    ----print("do updateDefendersBuff 3117")
    local nextActionArray = CCArray:create()
    nextActionArray:addObject(CCDelayTime:create(trailTime))
    nextActionArray:addObject(CCCallFunc:create(updateDefendersBuff))
    nextActionArray:addObject(CCDelayTime:create(0.5))
    nextActionArray:addObject(CCCallFunc:create(currentRoundOver))
    m_bg:runAction(CCSequence:create(nextActionArray))
end

function showAttackTrail(currentBattleIndex,currentSkillIndex,totalSkillTimes)

    local m_currentBattleBlock = m_battleInfo.battle[currentBattleIndex]
    ---[[
    if(m_currentBattleBlock.arrReaction == nil) then

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
                card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

        local skillID = m_currentBattleBlock.action
        require "db/skill"
        local skill =  BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid());
        --处理伤害
        --if(m_currentBattleBlock.arrReaction[i].arrDamage ~= nil and card ~= nil and (skill.mpostionType==4 or skill.mpostionType==3) and skill.distancePath~=nil) then
        if(card ~= nil and (skill.mpostionType==4 or skill.mpostionType==3) and skill.distancePath~=nil) then

            local beginPoint = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width*m_currentAttacker:getScale()*0.5, m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5));

            local endPoint = card:convertToWorldSpace(ccp(card:getContentSize().width*card:getScale()*0.5, card:getContentSize().height*card:getScale()*0.5));

            --播放音效
            --print("AudioUtil trail1:","audio/effect/" .. skill.distancePath .. ".mp3")
            if(file_exists("audio/effect/" .. skill.distancePath .. ".mp3") and m_currentSkillAttackIndex==1 and i==1) then

                --print("AudioUtil trail2:","audio/effect/" .. skill.distancePath .. ".mp3")
                AudioUtil.playEffect("audio/effect/" .. skill.distancePath .. ".mp3")
            end

            local trailSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. skill.distancePath), -1,CCString:create(""));
            trailSprite:retain()
            --trailSprite:setFlipY(m_currentIsDefenderEnemy);
            trailSprite:setAnchorPoint(ccp(0.5, 0.5));
            trailSprite:setPosition(m_bg:convertToNodeSpace(beginPoint));
            m_bg:addChild(trailSprite,11);
            trailSprite:release()
            local trailRotation = 0

            if(currentIsDefenderEnemy==false)then

            end

            local reletivePoint = ccp(endPoint.x-beginPoint.x,endPoint.y-beginPoint.y)
            local trailRotation = math.deg(math.atan(math.abs(reletivePoint.x/reletivePoint.y)))
            if(reletivePoint.x<0)then
                trailRotation = 360 - trailRotation
            end

            if(reletivePoint.y<0)then
                trailRotation = trailRotation>180 and 540-trailRotation or 180-trailRotation
            end

            trailSprite:setRotation(trailRotation)

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

    local callback4ShowDefenderEffect = function()
        showDefenderEffect(nil,currentBattleIndex,currentSkillIndex,totalSkillTimes)
    end
    local nextActionArray = CCArray:create()
    nextActionArray:addObject(CCDelayTime:create(delayTime))
    nextActionArray:addObject(CCCallFunc:create(callback4ShowDefenderEffect))
    m_bg:runAction(CCSequence:create(nextActionArray))
    --end
    --]]
end

function showTotalDamage( pBattleBlock )

    local totalDamage = 0
    if pBattleBlock.arrReaction == nil then
        return
    end

    for i=1,#(pBattleBlock.arrReaction) do

        --处理伤害
        if(pBattleBlock.arrReaction[i].arrDamage ~= nil) then
            local damage = 0
            for j=1,#(pBattleBlock.arrReaction[i].arrDamage) do
                damage = damage+pBattleBlock.arrReaction[i].arrDamage[j].damageValue
            end
            totalDamage = totalDamage + damage
        end
    end


    if totalDamage == 0 then
        return
    end

    if(file_exists("audio/effect/" .. "zongshanghai" .. ".mp3")) then
        AudioUtil.playEffect("audio/effect/" .. "zongshanghai" .. ".mp3")
    end
    local spellEffectSprite = nil
    if(file_exists("images/battle/effect/" .. "zongshanghai" ..".plist"))then
        spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/" .. "zongshanghai"), -1,CCString:create(""));
    end
    --数字
    local numberSprite = LuaCC.createNumberSprite02(IMG_PATH .. "number/red","" .. totalDamage,43)
    numberSprite:setAnchorPoint(ccp(0.5,0.5))
    numberSprite:setPosition(100,0)
    spellEffectSprite:addChild(numberSprite,999)

    spellEffectSprite:retain()
    spellEffectSprite:setPosition(ccps(0.5, 0.5))
    spellEffectSprite:setAnchorPoint(ccp(0.5, 0.5))
    battleBaseLayer:addChild(spellEffectSprite,201)
    spellEffectSprite:setScale(m_bg:getScale())
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

--连接式特效
function showAttackEffectConnect()

    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

    if(skill==nil or skill.attackEffct==nil or skill.attackEffct=="")then
        ----print("showAttackEffect skill.attackEffct==nil")
        m_currentSkillAttackIndex = 1
        m_currentSkillAttackTimes = 1
        showAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)

        return
    end

    --音效
    ----print("skill.attackEffct:",skill.id)
    if(skill.attackEffct~=nil and file_exists("audio/effect/" .. skill.attackEffct .. ".mp3")) then
        AudioUtil.playEffect("audio/effect/" .. skill.attackEffct .. ".mp3")
    end


    local effectWorldPos = m_currentAttacker:convertToWorldSpace(ccp(m_currentAttacker:getContentSize().width/2,m_currentAttacker:getContentSize().height/2))
    local effectBgPos = m_bg:convertToNodeSpace(effectWorldPos)

    local delayTime = 1

    local isDefenderEnemy = false
    for i=1,#(m_currentBattleBlock.arrReaction) do
        --获得反应卡牌

        local card_o = nil

        local defenderId = m_currentBattleBlock.arrReaction[i].defender
        for j=1,#(m_battleInfo.team1.arrHero) do
            local role = m_battleInfo.team1.arrHero[j]
            if(role.hid==defenderId) then
                card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

        --处理伤害
        if(card_o ~= nil) then

            local result = CCAnimation:create()
            local totalFrame = 1
            local height = 1
            for i=1,30 do
                local fileName = string.format(IMG_PATH .. "effect/".. skill.attackEffct .."%i.png",i)

                if(file_exists(fileName)) then
                    result:addSpriteFrameWithFileName(fileName)
                    totalFrame = i

                    local tempHeight = CCTextureCache:sharedTextureCache():addImage(fileName):getContentSize().height
                    if(i==1)then
                        height = tempHeight
                    else
                        height = height>tempHeight and tempHeight or height
                    end
                else
                    break
                end
            end

            result:setDelayPerUnit(0.1)
            delayTime = totalFrame*0.1

            local tempY = -m_bg:getPositionY()/m_bg:getScale()
            m_enemyCardLayer:setPosition(ccp(0, tempY))
            m_enemyCardLayer:setVisible(true)

            local effectSprite = CCSprite:create()
            effectSprite:setPosition(effectBgPos)
            effectSprite:setAnchorPoint(ccp(0.5,0))
            local currentLength = math.pow(math.pow((card_o:getPositionX()-m_currentAttacker:getPositionX()),2)+math.pow((card_o:getPositionY()-m_currentAttacker:getPositionY()),2),0.5)
            effectSprite:setScale(currentLength/height)

            local reletivePoint = ccp(card_o:getPositionX()-m_currentAttacker:getPositionX(),card_o:getPositionY()-m_currentAttacker:getPositionY())
            local trailRotation = math.deg(math.atan(math.abs(reletivePoint.x/reletivePoint.y)))
            if(reletivePoint.x<0)then
                trailRotation = 360 - trailRotation
            end

            if(reletivePoint.y<0)then
                trailRotation = trailRotation>180 and 540-trailRotation or 180-trailRotation
            end

            effectSprite:setRotation(trailRotation)

            m_bg:addChild(effectSprite,999,1234)

            local actionArray = CCArray:create()
            actionArray:addObject(CCAnimate:create(result))
            actionArray:addObject(CCCallFuncN:create(removeSelf))
            effectSprite:runAction(CCSequence:create(actionArray))
        end
    end

    m_currentSkillAttackIndex = 1
    m_currentSkillAttackTimes = 1
    --delegate
    local totalBlock = m_currentBattleBlock
    local animationEnd = function(actionName,xmlSprite)

        endShake()

        if(m_currentSkillAttackTimes>1)then
            showTotalDamage(totalBlock)
        end
        updateDefendersBuff()
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
        showAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
    end

    local actionArray = CCArray:create()
    actionArray:addObject(CCDelayTime:create(delayTime))
    actionArray:addObject(CCCallFunc:create(animationFrameChanged))
    actionArray:addObject(CCCallFunc:create(animationEnd))
    m_bg:runAction(CCSequence:create(actionArray))
end

function showAttackEffect()

    local millisecond1 = os.clock();

    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

    --print("showAttackEffect skill.attackEffct:",skill.attackEffct)

    local isShowCountDamage = false
    local isAlreadyShowCount = false
    if tonumber(skill.functionWay) == 2 or tonumber(skill.showDamage) == 1 then
        isShowCountDamage = true
    end

    --闪电连接
    if(skill.mpostionType==9 and isShowCountDamage)then
        showAttackEffectConnect()
        return
    end

    --音效
    ----print("skill.attackEffct:",skill.id)
    --print("skill.attackEffct sound1:",skill.attackEffct)
    if(skill.attackEffct~=nil and file_exists("audio/effect/" .. skill.attackEffct .. ".mp3")) then
        --print("skill.attackEffct sound:",skill.attackEffct)
        AudioUtil.playEffect("audio/effect/" .. skill.attackEffct .. ".mp3")
    end

    --print("showattackeffect ing 0:",skill.attackEffctPosition == nil,skill.meffectType ~= 1)

    print("block index",m_battleIndex)
    print("m_currentBattleBlock.arrReaction", m_currentBattleBlock.arrReaction)
    print("isShowCountDamage", isShowCountDamage)

    if m_currentBattleBlock.arrReaction and isShowCountDamage then
        if table.count(m_currentBattleBlock.arrReaction) > 1 then
            isAlreadyShowCount = true
            local totalBlock = m_currentBattleBlock
            performWithDelay(m_bg, function ( ... )
                -- 总伤害添加
                showTotalDamage(totalBlock)
            end, 0.5)
        end
    end

    if(skill==nil or skill.attackEffct==nil or skill.attackEffct=="")then
        ----print("showAttackEffect skill.attackEffct==nil")
        m_currentSkillAttackIndex = 1
        m_currentSkillAttackTimes = 1
        --showAttackTrail()

        if(skill.mpostionType~=5 or skill.distancePath == nil)then
            showAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
        else
            showAttackTrailThough(m_battleIndex-1)
        end
        return
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
                m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
            end
        else

            if(m_currentIsDefenderEnemy) then
                local position = getEnemyCardPointByPosition(1)
                local worldPosition = m_enemyCardLayer:convertToWorldSpace(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5))
                spellEffectSprite:setPosition(m_bg:convertToNodeSpace(worldPosition));
                m_bg:addChild(spellEffectSprite,9999,9182);
            else
                local position = getPlayerCardPointByPosition(1)
                local worldPosition = m_playerCardLayer:convertToWorldSpace(ccp(position.x,position.y-m_currentAttacker:getContentSize().height*0.5))
                spellEffectSprite:setPosition(m_bg:convertToNodeSpace(worldPosition));
                m_bg:addChild(spellEffectSprite,9999,9182);
            end
        end
        spellEffectSprite:release()

        --m_currentSkillAttackTimes = 1

        m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
        m_currentSkillAttackIndex = 0

        --delegate
        local animationEnd = function(actionName,xmlSprite)

            endShake()
            local totalBlock = m_currentBattleBlock
            if(m_currentSkillAttackTimes>1 and isAlreadyShowCount == false and isShowCountDamage)then
                showTotalDamage(totalBlock)
                isAlreadyShowCount = true
            end
            --goBack()
            if(skill.mpostionType~=5 or skill.distancePath == nil)then

                if(skill.distancePath == nil)then
                    updateDefendersBuff()
                else
                    ----print("do delay before trail")
                    local updateActionArray = CCArray:create()
                    updateActionArray:addObject(CCDelayTime:create(trailTime))
                    updateActionArray:addObject(CCCallFunc:create(updateDefendersBuff))
                    m_bg:runAction(CCSequence:create(updateActionArray))
                end
                --]]
            end
            spellEffectSprite:removeFromParentAndCleanup(true)
        end

        local animationFrameChanged = function(frameIndex,xmlSprite)
            ----print("animationFrameChanged:",frameIndex,xmlSprite)
            local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
            if(tempSprite:getIsKeyFrame()) then

                m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1

                if(skill.mpostionType~=5 or skill.distancePath == nil)then
                    showAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
                else
                    showAttackTrailThough(m_battleIndex-1)
                end
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
            showAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
            updateDefendersBuff()
            return
        end
        --print(GetLocalizeStringBy("key_2262"))
        --释放特效为敌人身上

        local isDefenderEnemy = false
        for i=1,#(m_currentBattleBlock.arrReaction) do
            --获得反应卡牌

            local card_o = nil

            local defenderId = m_currentBattleBlock.arrReaction[i].defender
            for j=1,#(m_battleInfo.team1.arrHero) do
                local role = m_battleInfo.team1.arrHero[j]
                if(role.hid==defenderId) then
                    card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

            --处理伤害
            if(card_o ~= nil) then


                local spellEffectSprite = nil
                ----print("skill.attackEffct:",skill.attackEffct)
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
                    local cardWorldPosition = card_o:convertToWorldSpace(ccp(card_o:getContentSize().width/2,card_o:getContentSize().height/2))
                    local cardBgPosition = m_bg:convertToNodeSpace(cardWorldPosition)
                    spellEffectSprite:setPosition(cardBgPosition);
                    m_bg:addChild(spellEffectSprite,999,9182)
                else
                    --脚下
                    local cardWorldPosition = card_o:convertToWorldSpace(ccp(card_o:getContentSize().width/2,0))
                    local cardBgPosition = m_bg:convertToNodeSpace(cardWorldPosition)
                    spellEffectSprite:setPosition(cardBgPosition);
                    m_bg:addChild(spellEffectSprite,999,9182)
                end
                spellEffectSprite:release()

                m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
                m_currentSkillAttackIndex = 0

                --delegate
                local totalBlock = m_currentBattleBlock
                local animationEnd = function(actionName,xmlSprite)


                    endShake()
                    if(m_currentSkillAttackTimes>1 and isAlreadyShowCount == false and isShowCountDamage)then
                        showTotalDamage(totalBlock)
                    end

                    if(skill.distancePath == nil)then
                        updateDefendersBuff()
                    else
                        ----print("do delay before trail")
                        local updateActionArray = CCArray:create()
                        updateActionArray:addObject(CCDelayTime:create(trailTime))
                        updateActionArray:addObject(CCCallFunc:create(updateDefendersBuff))
                        m_bg:runAction(CCSequence:create(updateActionArray))
                    end
                    spellEffectSprite:removeFromParentAndCleanup(true)
                    --xmlSprite:getParent():removeFromParentAndCleanup(true)
                end
                ----print("show attacteffect show one")
                local animationFrameChanged = function(frameIndex,xmlSprite)
                    ----print("animationFrameChanged:",frameIndex,xmlSprite,xmlSprite:getTag())
                    local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
                    if(tempSprite:getIsKeyFrame()==true) then
                        ----print("animationFrameChanged2:",frameIndex,m_battleIndex)
                        --showAttackTrail()
                        m_currentSkillAttackIndex = m_currentSkillAttackIndex + 1
                        showAttackTrail(m_battleIndex-1,m_currentSkillAttackIndex,m_currentSkillAttackTimes)
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
            --空格处增加特效
            if(skill.skipAble~=nil and skill.skipAble~="")then
                local posArray = lua_string_split(skill.skipAble,",")
                local defenderPos = m_currentDefender:getTag()%1000
                ----print("defenderPos",defenderPos)
                for pi=1,#posArray do
                    local posStr = posArray[pi]
                    --local realPos = defenderPos-8+pi
                    local relevantPos = defenderPos%3+(pi-1)%5-2
                    local realPos = defenderPos+(math.floor((pi-1)/5)-1)*3+(pi-1)%5-2
                    ----print("realPos:",realPos,relevantPos,pi,defenderPos)
                    if(posStr=="1" and realPos>=0 and realPos<=5 and (relevantPos>=0 and relevantPos <=2))then
                        local posCard = nil
                        if(isDefenderEnemy==true)then

                            posCard = tolua.cast(m_enemyCardLayer:getChildByTag(3000+realPos), "CCXMLSprite")
                        else

                            posCard = tolua.cast(m_playerCardLayer:getChildByTag(1000+realPos), "CCXMLSprite")
                        end

                        if(posCard==nil or posCard:getOpacity()<240)then
                            --播放特效

                            local cardPosition = nil

                            if(isDefenderEnemy==true)then
                                cardPosition = getEnemyCardPointByPosition(realPos)
                            else
                                cardPosition = getPlayerCardPointByPosition(realPos)
                            end

                            local spellEffectSprite = nil
                            ----print("skill.attackEffct:",skill.attackEffct)
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
                                spellEffectSprite:setPosition(ccp(cardPosition.x,cardPosition.y));
                                if(isDefenderEnemy) then
                                    m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
                                else
                                    m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
                                end
                            else
                                --脚下
                                spellEffectSprite:setPosition(ccp(cardPosition.x,cardPosition.y-m_currentAttacker:getContentSize().height/2));
                                if(isDefenderEnemy) then
                                    m_enemyCardLayer:addChild(spellEffectSprite,9999,9182);
                                else
                                    m_playerCardLayer:addChild(spellEffectSprite,9999,9182);
                                end
                            end
                            spellEffectSprite:release()

                            --m_currentSkillAttackTimes = 1

                            m_currentSkillAttackTimes = spellEffectSprite:getKeySprie():getMyKeyFrameCount()
                            m_currentSkillAttackIndex = 0

                            local animationEnd2 = function(actionName,xmlSprite)
                                spellEffectSprite:removeFromParentAndCleanup(true)
                            end

                            local animationFrameChanged2 = function(frameIndex,xmlSprite)
                            end

                            --增加动画监听
                            local delegate = BTAnimationEventDelegate:create()
                            delegate:registerLayerEndedHandler(animationEnd2)
                            delegate:registerLayerChangedHandler(animationFrameChanged2)

                            spellEffectSprite:setDelegate(delegate)

                        end
                    end
                end
            end

        end
    end

    local millisecond2 = os.clock();
end

function flyAttackCrush(xmlSprite)

    ----print("=====flyAttackCrush:",m_battleIndex)
    if(file_exists("audio/effect/" .. "zhuangjitx" .. ".mp3")) then

        AudioUtil.playEffect("audio/effect/" .. "zhuangjitx" .. ".mp3")
    end
    xmlSprite:setPositionY(xmlSprite:getPositionY()-xmlSprite:getContentSize().height*0.6)

    ----print("flyAttackCrush startShake")
    startShake()

    local animationEnd = function()
        ----print("flyAttackCrush animationEnd")
        endShake()
        showAttackerVisible()
        --goBack()
        if(xmlSprite:getTag()==12121)then
            ----print("do updateDefendersBuff 3968")
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
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())
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

function flyAttack(currentBattleIndex)
    ----print("=====flyAttack:",m_battleIndex)
    if(m_currentBattleBlock.arrReaction == nil) then
        --goBack()
        ----print("do updateDefendersBuff 4037")
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
                card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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

        local skillID = m_currentBattleBlock.action

        require "db/skill"
        local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

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
        ----print("fly attack target is null:",defenderId)
        end

    end

    local callback4ShowDefenderEffect = function ()
        showDefenderEffect(nil,currentBattleIndex,1,1)
    end
    local nextActionArray = CCArray:create()
    nextActionArray:addObject(CCDelayTime:create(delayTime))
    nextActionArray:addObject(CCCallFunc:create(callback4ShowDefenderEffect))
    m_bg:runAction(CCSequence:create(nextActionArray))
end

function showFlyAttack()
    setNodeNotVisible(m_currentAttacker)

    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid())

    local card = createBattleCard(m_currentBattleBlock.attacker)
    card:setTag(4900)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(m_currentIsAttackerEnemy) then
        m_enemyCardLayer:addChild(card,m_currentAttacker:getZOrder())
    else
        m_playerCardLayer:addChild(card,m_currentAttacker:getZOrder())
    end
    if m_currentHpTable[m_currentBattleBlock.attacker] and m_maxHpTable[m_currentBattleBlock.attacker] then
        BattleCardUtil.setCardHp(card,m_currentHpTable[m_currentBattleBlock.attacker]/m_maxHpTable[m_currentBattleBlock.attacker])
    end
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    BattleCardUtil.setCardAnger(card, m_currentAngerTable[m_currentBattleBlock.attacker], m_currentBattleBlock.attacker)
    BattleCardUtil.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.attacker], m_currentBattleBlock.attacker)
    local animationEnd = function()

        --应该使用SKILL释放类型判断
        flyAttack(m_battleIndex-1)
        card:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
        ----print("animationFrameChanged:",frameIndex,xmlSprite)
        local tempSprite = tolua.cast(xmlSprite,"CCXMLSprite")
        if(tempSprite:getIsKeyFrame()) then
            ----print("showFlyAttack tempSprite:getIsKeyFrame")
            showAttackEffect()
        end
    end

    --增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    --delegate:retain()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(animationFrameChanged)
    card:setDelegate(delegate)
    local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and "T003_u1_0" or "T003_d1_0")));
    local skillTime = totalFrameNum*card:getFpsInterval()

    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    if(m_currentBattleBlock.rage ~= nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = m_currentAngerTable[m_currentBattleBlock.attacker] + tonumber(m_currentBattleBlock.rage)
    end
    BattleCardUtil.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.attacker], m_currentBattleBlock.attacker)

end

function showBattleAttack()

    local millisecond1 = os.clock()

    -- --print("=====showBattleAttack:",m_battleIndex)

    require "db/skill"
    local skill = BT_Skill.getDataById(m_currentBattleBlock.action, getAttackDressId(), getAttackTid())

    ----print("skill.functionWay:",skill.id,skill.functionWay)
    -- --print("skill.id:",skill.id,skill.attackEffct,m_battleIndex)
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
    setNodeNotVisible(m_currentAttacker)

    local skillID = m_currentBattleBlock.action

    local card = createBattleCard(m_currentBattleBlock.attacker)
    card:setTag(4900)
    card:setAnchorPoint(ccp(0.5,0.5))
    card:setPosition(ccp(m_currentAttacker:getPositionX(),m_currentAttacker:getPositionY()))
    card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
    if(m_currentIsAttackerEnemy) then
        m_enemyCardLayer:addChild(card,m_currentAttacker:getZOrder())
    else
        m_playerCardLayer:addChild(card,m_currentAttacker:getZOrder())
    end
    if m_currentHpTable[m_currentBattleBlock.attacker] and m_maxHpTable[m_currentBattleBlock.attacker] then
        BattleCardUtil.setCardHp(card,m_currentHpTable[m_currentBattleBlock.attacker]/m_maxHpTable[m_currentBattleBlock.attacker])
    end
    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    BattleCardUtil.setCardAnger(card, m_currentAngerTable[m_currentBattleBlock.attacker],m_currentBattleBlock.attacker)
    BattleCardUtil.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.attacker],m_currentBattleBlock.attacker)
    local animationEnd = function()

        showAttackerVisible()


        if(skill.attackEffct==nil or skill.attackEffct=="")then
            ----print("showBattleAttack done start updateDefendersBuff")
            --goBack()

            if(skill.mpostionType~=5 or skill.distancePath == nil)then

                if(skill.distancePath == nil)then
                    updateDefendersBuff()
                else
                    ----print("do delay before trail")
                    local updateActionArray = CCArray:create()
                    updateActionArray:addObject(CCDelayTime:create(trailTime))
                    updateActionArray:addObject(CCCallFunc:create(updateDefendersBuff))
                    m_bg:runAction(CCSequence:create(updateActionArray))
                end
            end
        end

        card:removeFromParentAndCleanup(true)
    end

    local animationFrameChanged = function(frameIndex,xmlSprite)
        ----print("animationFrameChanged:",frameIndex,skill.id,skill.actionid)
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
    if(file_exists("audio/effect/" .. (skill.actionid or "") .. ".mp3")) then

        AudioUtil.playEffect("audio/effect/" .. skill.actionid .. ".mp3")
    end


    local totalFrameNum
    -- --printTable("skill", skill)
    if(file_exists("images/battle/xml/action/" .. skill.actionid .. ".xml"))then
        totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. skill.actionid));
    else
        totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/" .. (m_currentIsAttackerEnemy and skill.actionid .. "_u_0" or skill.actionid .. "_d_0")));
    end
    local skillTime = totalFrameNum*card:getFpsInterval()

    --更新怒气
    if(m_currentAngerTable[m_currentBattleBlock.attacker] == nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = 0
    end
    if(m_currentBattleBlock.rage ~= nil) then
        m_currentAngerTable[m_currentBattleBlock.attacker] = m_currentAngerTable[m_currentBattleBlock.attacker] + tonumber(m_currentBattleBlock.rage)
    end

    BattleCardUtil.setCardAnger(m_currentAttacker, m_currentAngerTable[m_currentBattleBlock.attacker], m_currentBattleBlock.attacker)

    local millisecond2 = os.clock();
end

function showRageEffect()

    local millisecond1 = os.clock()
    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid());

    -- 非怒气技能，直接播放攻击
    if(skill.functionWay~=2)then
        showBattleAttack()
        return
    end

    local hid = tonumber(m_currentBattleBlock.attacker)
    local imageFile
    local replaceFile
    local grade
    local atkHeroHtid = nil
    if(hid<10000000) then
        require "db/DB_Monsters"
        local monster = DB_Monsters.getDataById(hid)

        if(monster==nil) then
            monster = DB_Monsters.getDataById(1002011)
        end

        require "db/DB_Monsters_tmpl"
        local monsterTmpl = DB_Monsters_tmpl.getDataById(monster.htid)
        atkHeroHtid = monster.htid
        grade = monsterTmpl.star_lv
        imageFile = monsterTmpl.rage_head_icon_id
        replaceFile = monsterTmpl.body_img_id
    else
        require "script/model/hero/HeroModel"
        local allHeros = HeroModel.getAllHeroes()
        require "script/utils/LuaUtil"
        if(allHeros == nil or allHeros[hid..""] == nil) then

            grade = hid%6+1
        else
            local htid = allHeros[hid..""].htid
            atkHeroHtid = htid
            require "db/DB_Heroes"
            local hero = DB_Heroes.getDataById(htid)

            grade = hero.star_lv
            imageFile = hero.rage_head_icon_id
            replaceFile = hero.body_img_id

            if(m_playerCardHidMap[hid..""]~=nil )then
                imageFile = m_playerCardHidMap[hid..""].rageHead
            end
        end
    end
    local info = BattleCardUtil.getBattleHeroInfo(hid)
    info.turned_id = tonumber(info.turned_id) or 0
    if info.turned_id ~= 0 then
        turnedId = info.turned_id
        imageFile = HeroTurnedData.getTurnDBInfoById(info.turned_id).rage_head_icon_id
        print("showRageEffect", turnedId, imageFile, hid)
    end

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
        defenderActionArray:addObject(CCDelayTime:create(1.5))
        --defenderActionArray:addObject(CCMoveBy:create(1,ccp(0,m_currentAttacker:getContentSize().height*m_currentAttacker:getScale()*0.5)))
        defenderActionArray:addObject(CCCallFuncN:create(removeSelf))
        nameBg:runAction(CCSequence:create(defenderActionArray))
    end

    if(skill.functionWay==2 and skill.icon~=nil  and imageFile~=nil)then

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
        local bodySprite = nil
        if(file_exists("images/battle/rage_head/" .. imageFile))then
            replaceXmlSprite:setReplaceFileName(CCString:create("images/battle/rage_head/" .. imageFile))
        else
            replaceXmlSprite:setReplaceFileName(CCString:create("images/battle/card/blankcard.png"))

            --
            local stencilSprite = CCSprite:create("images/battle/rage_head/nuqitouxiang_04.png")
            stencilSprite:setAnchorPoint(ccp(0.5,0.5))
            stencilSprite:setPosition(ccp(0,0))

            local clipper = CCClippingNode:create()
            clipper:setContentSize( CCSizeMake(stencilSprite:getContentSize().width, stencilSprite:getContentSize().height) )
            clipper:setAnchorPoint( ccp(0.5, 0.5) )
            clipper:setPosition( ccp(stencilSprite:getContentSize().width,stencilSprite:getContentSize().height) )
            clipper:setInverted(false)
            clipper:setAlphaThreshold(0.9)
            clipper:setStencil(stencilSprite)
            clipper:setScale(2)
            replaceXmlSprite:addChild(clipper)

            bodySprite = CCSprite:create("images/base/hero/body_img/" .. replaceFile)
            bodySprite:setAnchorPoint(ccp(0.5,0.5))
            bodySprite:setPosition(ccp(0,0))
            --bodySprite:setScale(1.8)
            clipper:addChild(bodySprite)
            bodySprite:setVisible(false)
        end

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
            if(frameIndex==1 and bodySprite~=nil)then
                bodySprite:setVisible(true)
            end
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

        if atkHeroHtid ~= nil then
            require "script/utils/SoundEffectUtil"
            local dbData = SoundEffectUtil.getHeroAudioDataByHtid(atkHeroHtid)
            if( dbData and dbData.skill_sound )then
                SoundEffectUtil.stopHeroAudio()
                SoundEffectUtil.playHeroAudio(dbData.skill_sound)
            end
        end
    else
        showBattleAttack()
    end

    local millisecond2 = os.clock();
end

function showFullSceneEffect()

    --print("=====showFullSceneEffect:",m_battleIndex)
    local skillID = m_currentBattleBlock.action

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid());

    if(skill.fullScreen==0) then
        showRageEffect()
        --showBattleAttack()
    else
        --展示全屏效果
        showRageEffect()
        --showBattleAttack()
    end
end

function goToAttackLocation()

    local millisecond1 = os.clock();

    local skillID = m_currentBattleBlock.action

    if(skillID==0)then
        showNextMove()
        return
    end

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid());

    require("script/utils/LuaUtil")
    --获得攻击者
    local attackerId = m_currentBattleBlock.attacker
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
            m_currentDefender = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
    ----print("====================  m_currentAttackerId",m_currentBattleBlock.attacker,m_battleIndex)
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

        local locationPara = m_currentIsDefenderEnemy and -0.6 or 1.6
        if(m_currentDefender:getTag()%10>2)then
            locationPara = locationPara + (m_currentIsDefenderEnemy==true and -1.1 or 1.1)
        end
        local worldLocation = m_currentDefender:convertToWorldSpace(ccp(m_currentDefender:getContentSize().width/2,m_currentDefender:getContentSize().height*locationPara))
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

    local millisecond2 = os.clock();
end

function beforeAttackUpdateBuff()

    --获得攻击者
    local attackerId = m_currentBattleBlock.attacker
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
            m_currentDefender = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
        updateCardBuff(attackerId,m_currentAttacker,1,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,afterAttackUpdateBuff,1)
        return
    end

    require "db/skill"
    local skill = BT_Skill.getDataById(skillID, getAttackDressId(), getAttackTid());

    require("script/utils/LuaUtil")
    ----print_table ("tb", skill)

    --获得攻击者
    local attackerId = m_currentBattleBlock.attacker
    for i=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[i]
        if(role ~= nil and role.hid==attackerId) then
            m_currentAttacker = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
            m_currentDefender = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
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
        m_playerCardLayer:getParent():reorderChild(m_playerCardLayer,0)
        m_enemyCardLayer:getParent():reorderChild(m_enemyCardLayer,1)

        for i=0,5 do
            local card = m_enemyCardLayer:getChildByTag(3000+i)
            if(card~=nil) then
                m_enemyCardLayer:reorderChild(m_currentAttacker,0)
            end
        end
        m_enemyCardLayer:reorderChild(m_currentAttacker,10)
    else
        m_playerCardLayer:getParent():reorderChild(m_playerCardLayer,1)
        m_enemyCardLayer:getParent():reorderChild(m_enemyCardLayer,0)

        for i=0,5 do
            local card = m_playerCardLayer:getChildByTag(1000+i)
            if(card~=nil) then
                m_playerCardLayer:reorderChild(m_currentAttacker,0)
            end
        end
        m_playerCardLayer:reorderChild(m_currentAttacker,10)
    end
    updateCardBuff(attackerId,m_currentAttacker,1,m_currentBattleBlock.enBuffer,m_currentBattleBlock.deBuffer,m_currentBattleBlock.imBuffer,m_currentBattleBlock.buffer,goToAttackLocation,1)
end

function initCurrentEnemy()

    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)
    ----print("========== initCurrentEnemy army.monster_group:",army.monster_group)
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monstersStr = team.monsterID

    m_enemyCardLayer:setPosition(ccp(0, 0))

    initEnemyLayer(monstersStr)

    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    m_enemyCardLayer:setVisible(true)
end



function showNextMove()

    local millisecond1 = os.clock();

    SimpleAudioEngine:sharedEngine():resumeAllEffects()
    retryTimes = 0
    --层级归位
    if(m_battleIndex>1) and not tolua.isnull(m_currentAttacker) then
        if(m_currentIsAttackerEnemy)then
            m_enemyCardLayer:reorderChild(m_currentAttacker,5-m_currentAttacker:getTag()+2000)
        else
            m_playerCardLayer:reorderChild(m_currentAttacker,2)
        end
    end

    if g_system_type == kBT_PLATFORM_ANDROID then
        require "script/utils/LuaUtil"
        checkMem()
    else
        CCTextureCache:sharedTextureCache():removeUnusedTextures()
    end
    --print("shownextmove m_isFirstTime:",m_isFirstTime)
    if(m_isShowBattle ~= true and m_isFirstTime == true)then
        --判断是否播放对话
        require "db/DB_Army"
        local army = DB_Army.getDataById(m_currentArmyId)
        if(m_dialogIndex ~= m_battleIndex and army~=nil and army.dialog_ids_fighting~=nil and m_currentBattleBlock~=nil and m_battleInfo.battle[m_battleIndex]~=nil and (m_currentBattleBlock.round ~= m_battleInfo.battle[m_battleIndex].round) )then

            local dialog_ids = army.dialog_ids_fighting
            local dialog_idArray = lua_string_split(dialog_ids,",")
            for i=1,#dialog_idArray do
                local dialogRound = tonumber(lua_string_split(dialog_idArray[i],"|")[1])
                if(dialogRound ~= nil and m_currentBattleBlock.round == dialogRound)then
                    local talkId = tonumber(lua_string_split(dialog_idArray[i],"|")[2])
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
        --战斗胜利
        endShake()

        if(m_isShowBattle == true)then
            CCDirector:sharedDirector():getScheduler():setTimeScale(1)
            --closeLayer()
            if(m_afterBattleView~=nil)then
                battleBaseLayer:addChild(m_afterBattleView,99999)
                m_afterBattleView:release()
                skipFightButton:setVisible(false)
            else
                closeLayer()
            end
            return
        end

        --判断是否播放对话
        require "db/DB_Army"
        local army = DB_Army.getDataById(m_currentArmyId)
        --判断是否有战斗后对话
        if(army.dialog_id_over~=nil and m_isCheckOverDialog == false and m_isFirstTime == true)then
            doTalk(tonumber(army.dialog_id_over),showNextMove)
            m_isCheckOverDialog = true
            return
        end
        m_isCheckOverDialog = false
        --更新战果信息
        m_soulNumber = m_reward.soul==nil and  m_soulNumber or m_soulNumber+tonumber(m_reward.soul)
        if(m_reward.item~=nil and #m_reward.item>0) then
            for i=1,#m_reward.item do
                m_itemArray[#m_itemArray+1] = m_reward.item[i]
            end
        end
        ---[[
        if(m_reward.hero~=nil and #m_reward.hero>0) then
            for i=1,#m_reward.hero do
                m_heroArray[#m_heroArray+1] = m_reward.hero[i]
            end
        end
        --]]
        m_silverNumber = m_reward.silver==nil and  m_silverNumber or m_silverNumber+tonumber(m_reward.silver)
        m_expNumber = m_reward.exp==nil and  m_expNumber or m_expNumber+tonumber(m_reward.exp)

        --增加顶栏显示
        m_resourceNumber = m_resourceNumber + #m_itemArray
        if(m_resourceNumber~=nil)then
            battleResourceLabel:setString("" .. (m_resourceNumber))
        end
        battleSoulLabel:setString("" .. m_soulNumber)
        battleMoneyLabel:setString("" .. m_silverNumber)

        m_battleIndex = 1
        local actionArr = CCArray:create()
        actionArr:addObject(CCDelayTime:create(0.5))
        actionArr:addObject(CCCallFunc:create(showNextArmy))
        local actions = CCSequence:create(actionArr)
        battleBaseLayer:runAction(actions)

        return

    elseif(m_battleIndex>#(m_battleInfo.battle) and (m_appraisal=="E" or m_appraisal=="F")) then
        --战斗失败
        CCDirector:sharedDirector():getScheduler():setTimeScale(1)
        endShake()
        m_battleIndex = 1
        if(m_isShowBattle == true)then
            --closeLayer()
            if(m_afterBattleView~=nil)then
                battleBaseLayer:addChild(m_afterBattleView,99999)
                m_afterBattleView:release()
                skipFightButton:setVisible(false)
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
        m_silverNumber = m_reward.silver==nil and  m_silverNumber or m_silverNumber+tonumber(m_reward.silver)
        m_expNumber = m_reward.exp==nil and  m_expNumber or m_expNumber+tonumber(m_reward.exp)

        --增加顶栏显示
        local currentResSum = tonumber(battleResourceLabel:getString())
        if(currentResSum~=nil)then
            battleResourceLabel:setString("" .. (currentResSum+#m_itemArray))
        end
        battleSoulLabel:setString("" .. m_soulNumber)
        battleMoneyLabel:setString("" .. m_silverNumber)


        require "script/battle/BattleReportLayer"
        local reportLayer = BattleReportLayer.getBattleReportLayer(false,m_copy_id,m_base_id,m_level,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber,m_copyType,false)
        battleBaseLayer:addChild(reportLayer,99999)
        skipFightButton:setVisible(false)
        --print("BattleReportLayer.getBattleReportLayer false")
        return
    end

    m_currentBattleBlock = m_battleInfo.battle[m_battleIndex]

    m_battleIndex = m_battleIndex+1

    --更新信息
    battleRoundLabel:setString(m_currentBattleBlock.round .. "/30")

    m_isCurrentRoundOver = false

    local atkId = m_currentBattleBlock.attacker
    if tonumber(atkId) >200 then
        beforeAttackUpdateBuff()
    else
        showWarCarAction(function ( ... )
            updateDefendersBuff()
        end)
    end
    

    print("battleIndex", m_battleIndex)
    print_t(m_currentHpTable)

end

function clearEnemyLayer()
    if(m_enemyCardLayer~=NULL) then
        m_enemyCardLayer:removeAllChildrenWithCleanup(true)
    end
end

function initEnemyLayer(monsterIds)

    clearEnemyLayer()

    local cardWidth = m_bg:getContentSize().width*0.2;

    local startX = 0.28*m_bg:getContentSize().width;
    local startY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale() - cardWidth*0.7;

    local monsterIdArray = lua_string_split(monsterIds,",")

    for i=0,5 do
        if(i+1>#monsterIdArray or monsterIdArray[i+1]=="0") then

        else
            local card = createBattleCard(monsterIdArray[i+1])
            card:setTag(3000+i)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(getEnemyCardPointByPosition(i))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));
            m_enemyCardLayer:addChild(card,5-i)

        end
    end
end



function layerTouch(eventType, x, y)
    if eventType == "began" then
        if(isNameVisible == true) then
            isNameVisible = false
        else
            isNameVisible = true
        end
        BattleCardUtil.setNameVisible(isNameVisible)

        return true
    elseif eventType == "moved" then
        return true
    else
        return true
    end
end

function closeLayer()

    if(isBattleOnGoing == false and battleBaseLayer == nil)then
        return
    end

    if(skipFightButton~=nil)then
        skipFightButton:removeFromParentAndCleanup(true)
    end

    skipFightButton = nil

    AudioUtil.playBgm("audio/main.mp3")

    endShake()

    if(m_afterBattleView~=nil)then
        m_afterBattleView:removeFromParentAndCleanup(true)
    end



    if(m_callbackFunc ~=nil) then
        local isWin = true
        if(m_appraisal=="E" or m_appraisal=="F")then
            isWin = false
        end
        m_callbackFunc(m_newcopyorbase,isWin,m_extra_reward,m_extra_info)
    end

    --在回调方法中进行战斗结束的通知
    -- if(m_callbackFunc == nil) then
    --     ----print("battle scene fight over")
    --     -- CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    -- end
    CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    m_callbackFunc = nil

    if(g_network_status==g_network_connected)then
        if(m_isShowBattle == nil or m_isShowBattle == false)then
            ---[[
            if(m_copyType==1)then
                RequestCenter.ncopy_leaveBaseLevel(nil,Network.argsHandler(m_copy_id,m_base_id,m_level))
            elseif(m_copyType==2)then
                RequestCenter.ecopy_leaveCopy(nil,Network.argsHandler(m_copy_id))
            elseif(m_copyType==4)then
                RequestCenter.tower_leaveLevel(nil,Network.argsHandler(m_copy_id))
            elseif(m_copyType==5)then
                RequestCenter.tower_leaveLevel(nil,Network.argsHandler(m_copy_id))
            elseif(m_copyType==6)then
                RequestCenter.Hcopy_leaveBaseLevel(nil,Network.argsHandler(m_copy_id,m_base_id,m_level))
            else
                RequestCenter.acopy_leaveBaseLevel(nil,Network.argsHandler(m_copy_id,m_level))
            end
        end
    end

    m_isShowBattle = nil
    m_afterBattleView = nil
    m_bg=nil

    local scene = CCDirector:sharedDirector():getRunningScene()
    scene:removeChild(battleBaseLayer,true)
    battleBaseLayer = nil
    CCDirector:sharedDirector():getScheduler():setTimeScale(1)

    ---[[
    if(m_visibleViews~=nil)then
        for idx=1,m_visibleViews:count() do
            local childNode = tolua.cast(m_visibleViews:objectAtIndex(idx-1),"CCNode")
            if(childNode~=nil)then
                childNode:setVisible(true)
            end
        end
        m_visibleViews:removeAllObjects()
        m_visibleViews:release()
        m_visibleViews = nil
    end
    --]]
    isBattleOnGoing = false

    ----print("-=-=-=-=-=-= show massage =-=-=-=-=-=-=-")

    if g_system_type == kBT_PLATFORM_ANDROID then
        require "script/utils/LuaUtil"
        checkMem()
    else
        CCTextureCache:sharedTextureCache():removeUnusedTextures()
    end


    local isWin = true
    if(m_appraisal=="E" or m_appraisal=="F")then
        isWin = false
    end

    require "script/ui/login/LoginScene"
    LoginScene.setBattleStatus(false)
    m_isInFighting = false
    ----print(collectgarbage("count", 100))
    collectgarbage("collect", 100)
end

-- 回调
function getTowerInfoCallback( cbFlag, dictData, bRet  )
    if(dictData.err == "ok")then
        if(not table.isEmpty(dictData.ret))then
            TowerCache.setTowerInfo(dictData.ret)

        end
    end
end

function autoFightClick()
    isAutoFight = isAutoFight==false and true or false

    local autoFightStr = isAutoFight==true and GetLocalizeStringBy("key_1712") or GetLocalizeStringBy("key_2379")
    local autoFightLabel = tolua.cast( autoFightButton:getChildByTag(110),"CCLabelTTF")
    if(autoFightLabel~=nil)then
        autoFightLabel:setString(autoFightStr)
    end
end


--[[
@des: 是否能跳过战斗
@ret: 返回true 则可以跳过本次战斗，否则不能跳过
--]]
function canSkipBattle( ... )

    require "db/DB_Vip"
    require "db/DB_Normal_config"
    require "script/model/user/UserModel"
    local userVipLevel  = tonumber(UserModel.getVipLevel())
    local userLevel     = UserModel.getHeroLevel()
    local userVipInfo   = DB_Vip.getDataById(tostring(vipLevel))
    local configInfo    = DB_Normal_config.getDataById("1")

    local needVipLevel  = 0
    local needUserLevel = 0
    local message       = nil
    local skipResult    = nil
    if(m_copyType == kNormalCopy) then
        --普通副本
        local i = 1
        for k,v in pairs(DB_Vip.Vip) do
            local vInfo = DB_Vip.getDataById(tostring(i))
            if(tonumber(vInfo["isSkipFight"]) ~= 0) then
                needVipLevel     = tonumber(vInfo.level)
                needUserLevel    = tonumber(vInfo["isSkipFight"])
                break
            end
            i = i+1
        end

        message = "VIP".. needVipLevel ..GetLocalizeStringBy("key_1181").. needUserLevel .. GetLocalizeStringBy("key_2067")
        if(userLevel >= needUserLevel and userVipLevel >= needVipLevel) then
            skipResult = true
        else
            -- AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(m_copyType == kEliteCopy) then
        --精英副本
        local skipFightInfo = string.split(configInfo.eliteisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            -- AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(m_copyType == kActivityCopy) then
        --活动副本
        local skipFightInfo = string.split(configInfo.activitycopyisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            -- AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(m_copyType == kTowerCopy) then
        --试炼塔
        local skipFightInfo = string.split(configInfo.TesttowerisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            -- AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(m_copyType == kMysicalFloorCopy) then
        --神秘层
        local skipFightInfo = string.split(configInfo.MysicalTowerisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            -- AnimationTip.showTip(message)
            skipResult = false
        end
    elseif(m_copyType == kHeroCopy) then
        -- 武将列传
        local skipFightInfo = string.split(configInfo.GeneralsbiographyisSkipFight, "|")
        needVipLevel  = tonumber(skipFightInfo[1])
        needUserLevel = tonumber(skipFightInfo[2])
        message = "VIP".. needVipLevel ..GetLocalizeStringBy("lcy_50107").. needUserLevel .. GetLocalizeStringBy("lcy_50101")
        if(userLevel >= needUserLevel or userVipLevel >= needVipLevel) then
            skipResult = true
        else
            -- AnimationTip.showTip(message)
            skipResult = false
        end
    else
        skipResult = true
    end

    skipResult = true

    --print("skip m_copyType:", m_copyType)
    --print("skip result",  skipResult)
    --print("skip message", message)
    --print("needUserLevel", needUserLevel)
    --print("needVipLevel", needVipLevel)
    return skipResult
end



function skipClick( p_tag, p_sender)

    --开场特效没有播放完毕不能跳过
    if m_startEffectIsOver == false then
        return
    end
    --第一次还没通过该据点不能跳过
    if(m_isFirstTime == true) then
        if(canSkipBattle() == false) then
            return
        end
    end
    --战斗还没有开始不能跳过
    if(m_isInFighting==false)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_1879"))
        return
    end
    --停止删除宠物相关动画
    for k,v in pairs(petNodeContainer) do
        local node = tolua.cast(v, "CCNode")
        if(node) then
            node:cleanup()
            node:removeFromParentAndCleanup(true)
            petNodeContainer[k] = nil
        end
    end

    if _isAddWarCardMask then
        removeWarCarMask()
    end
    --隐藏跳过战斗按钮，防止重复点击
    tolua.cast(p_sender, "CCNode"):setVisible(false)
    endShake()
    m_isInFighting = false
    m_bg:cleanup()
    local bgChildList = m_bg:getChildren()
    for i=0,bgChildList:count()-1 do
        local card = tolua.cast(bgChildList:objectAtIndex(i),"CCNode")
        card:cleanup()
        card:setVisible(true)
        --print("bg child tag:",card:getTag())
        if(card:getTag()==1188 or card:getTag()==1177 or card:getTag()==2121)then

        else
            card:setVisible(false)
        end
    end

    if(m_enemyCardLayer~=nil)then
        local cardList = m_enemyCardLayer:getChildren()
        for i=0,cardList:count()-1 do
            local card = tolua.cast(cardList:objectAtIndex(i),"CCNode")
            card:cleanup()
            card:setVisible(true)
            if(card:getTag()>3005 or card:getTag()<3000)then
                card:setVisible(false)
            else
                card:setVisible(true)
                card:setPosition(getEnemyCardPointByPosition(card:getTag()-3000))
            end
        end
    end

    if(m_playerCardLayer~=nil)then
        local cardList = m_playerCardLayer:getChildren()
        for i=0,cardList:count()-1 do
            local card = tolua.cast(cardList:objectAtIndex(i),"CCNode")
            card:cleanup()
            card:setVisible(true)
            if((card:getTag()<=1005 and card:getTag()>=1000))then
                --print("m_playerCardLayer child:",card:getTag())
                card:setVisible(true)
                card:setPosition(getPlayerCardPointByPosition(card:getTag()%1000))
            else
                card:setVisible(false)
            end
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
        ----print("================ m_reward.hero ==================")
        ----print_table("m_reward.hero",m_reward.hero)
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
        ----print("change battleResourceLabel:","" .. (currentResSum+#m_itemArray))
        battleResourceLabel:setString("" .. (m_resourceNumber))
    end
    battleSoulLabel:setString("" .. m_soulNumber)
    battleMoneyLabel:setString("" .. m_silverNumber)

    local callback4ShowReport = nil

    --print("skipClick m_isShowBattle1:",m_isShowBattle)
    if(m_isShowBattle == nil)then
        m_isShowBattle = false
    end
    if(m_isShowBattle==false and (m_appraisal=="E" or m_appraisal=="F"))then

        callback4ShowReport = function()
            require "script/battle/BattleReportLayer"
            local reportLayer = BattleReportLayer.getBattleReportLayer(false,m_copy_id,m_base_id,m_level,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber,m_copyType,false)
            battleBaseLayer:addChild(reportLayer,99999)
            skipFightButton:setVisible(false)
            --print("BattleReportLayer.getBattleReportLayer false")
        end
    elseif(m_isShowBattle==false)then

        callback4ShowReport = function()
            showNextArmy()
        end
    else

        CCDirector:sharedDirector():getScheduler():setTimeScale(1)
        callback4ShowReport = function()
            if(m_afterBattleView~=nil)then

                CCDirector:sharedDirector():getScheduler():setTimeScale(1)

                battleBaseLayer:addChild(m_afterBattleView,99999)
                m_afterBattleView:release()
                skipFightButton:setVisible(false)

            else
                closeLayer()
            end
        end
    end


    local deadList = {}
    local nowBattleIndex = m_battleIndex-1
    nowBattleIndex = nowBattleIndex<1 and 1 or nowBattleIndex

    local damageList = {}
    while(nowBattleIndex<=#(m_battleInfo.battle))do
        local blockInfo = m_battleInfo.battle[nowBattleIndex]
        if(blockInfo.arrReaction~=nil)then
            for reactionIndex=1,#(blockInfo.arrReaction) do
                if(blockInfo.arrReaction[reactionIndex].mandown==true)then

                    local isCardDead = false
                    for deadListIndex=1,#deadList do
                        if(tonumber(blockInfo.arrReaction[reactionIndex].defender) == deadList[deadListIndex])then
                            isCardDead = true
                            break
                        end
                    end
                    if(isCardDead == false)then
                        --print("deadList mandown1:",blockInfo.arrReaction[reactionIndex].defender)
                        deadList[#deadList+1] = tonumber(blockInfo.arrReaction[reactionIndex].defender)
                    end
                end
                if(blockInfo.arrReaction[reactionIndex].arrDamage~=nil)then
                    local curHid = tonumber(blockInfo.arrReaction[reactionIndex].defender)
                    for damageIndex = 1,#(blockInfo.arrReaction[reactionIndex].arrDamage) do
                        if(curHid~=nil and tonumber(blockInfo.arrReaction[reactionIndex].arrDamage[damageIndex].damageValue)~=nil)then
                            if(damageList[curHid]==nil)then
                                damageList[curHid] = 0
                            end
                            damageList[curHid] = damageList[curHid]+ tonumber(blockInfo.arrReaction[reactionIndex].arrDamage[damageIndex].damageValue)
                            m_currentHpTable[curHid] = m_currentHpTable[curHid] - tonumber(blockInfo.arrReaction[reactionIndex].arrDamage[damageIndex].damageValue)
                        end
                    end
                end
                -- buff damage
                if(blockInfo.arrReaction[reactionIndex].buffer~=nil)then
                    local curHid = tonumber(blockInfo.arrReaction[reactionIndex].defender)
                    for buffIndex = 1,#(blockInfo.arrReaction[reactionIndex].buffer) do
                        if(curHid~=nil and tonumber(blockInfo.arrReaction[reactionIndex].buffer[buffIndex].type)==9)then
                            if(damageList[curHid]==nil)then
                                damageList[curHid] = 0
                            end
                            damageList[curHid] = damageList[curHid]+ tonumber(blockInfo.arrReaction[reactionIndex].buffer[buffIndex].data)
                            m_currentHpTable[curHid] = m_currentHpTable[curHid] + tonumber(blockInfo.arrReaction[reactionIndex].buffer[buffIndex].data)
                            --print("skip buff damange:",blockInfo.arrReaction[reactionIndex].buffer[buffIndex].data)
                        end
                    end
                end
            end
        end
        if(blockInfo.arrChild~=nil)then
            for arrChildIndex=1,#blockInfo.arrChild do

                if(blockInfo.arrChild[arrChildIndex].arrReaction~=nil)then
                    for reactionIndex=1,#(blockInfo.arrChild[arrChildIndex].arrReaction) do
                        if(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].mandown==true)then

                            local isCardDead = false
                            for deadListIndex=1,#deadList do
                                if(tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].defender) == deadList[deadListIndex])then
                                    isCardDead = true
                                    break
                                end
                            end
                            if(isCardDead == false)then
                                --print("deadList mandown2:",blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].defender)
                                deadList[#deadList+1] = tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].defender)
                            end
                        end

                        if(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage~=nil)then
                            local curHid = tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].defender)
                            for damageIndex = 1,#(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage) do
                                if(curHid~=nil and tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage[damageIndex].damageValue)~=nil)then
                                    if(damageList[curHid]==nil)then
                                        damageList[curHid] = 0
                                    end
                                    damageList[curHid] = damageList[curHid]+ tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage[damageIndex].damageValue)
                                    m_currentHpTable[curHid] = m_currentHpTable[curHid] - tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].arrDamage[damageIndex].damageValue)
                                end
                            end
                        end
                        -- buff damage
                        if(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer~=nil)then
                            local curHid = tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].defender)
                            for buffIndex = 1,#(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer) do
                                if(curHid~=nil and tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer[buffIndex].type)==9)then
                                    if(damageList[curHid]==nil)then
                                        damageList[curHid] = 0
                                    end
                                    damageList[curHid] = damageList[curHid]+ tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer[buffIndex].data)
                                    m_currentHpTable[curHid] = m_currentHpTable[curHid] + tonumber(blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer[buffIndex].data)
                                    --print("skip child buff damange:",blockInfo.arrChild[arrChildIndex].arrReaction[reactionIndex].buffer[buffIndex].data)
                                end
                            end
                        end
                    end
                end

            end
        end

        if(blockInfo.mandown==true)then
            local isCardDead = false
            for deadListIndex=1,#deadList do
                if(tonumber(blockInfo.attacker) == deadList[deadListIndex])then
                    isCardDead = true
                    break
                end
            end
            if(isCardDead == false)then
                --print("deadList mandown3:",blockInfo.attacker)
                deadList[#deadList+1] = tonumber(blockInfo.attacker)
            end
        end
        nowBattleIndex = nowBattleIndex+1
    end

    local  skipDone = function()
        if(m_isShowBattle==true) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCDelayTime:create(1))
            deadActionArray:addObject(CCCallFunc:create(callback4ShowReport))
            m_bg:runAction(CCSequence:create(deadActionArray))
            return
        end
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
        if(armyIdArray[m_currentArmyIndex+1]==nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCDelayTime:create(1))
            deadActionArray:addObject(CCCallFunc:create(callback4ShowReport))
            m_bg:runAction(CCSequence:create(deadActionArray))
        else
            callback4ShowReport()
        end
    end

    if(#deadList==0)then
        skipDone()
    end

    local deadEffectEndTime = 0
    local team2arr = m_battleInfo.team2.arrHero

    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local isCardDead = false

        for deadListIndex=1,#deadList do
            if(tonumber(teamInfo.hid) == deadList[deadListIndex])then
                isCardDead = true
                break
            end
        end

        local card_o = m_enemyCardLayer:getChildByTag(3000+tonumber(teamInfo.position))
        ----print("skip hp:",tonumber(teamInfo.hid),m_currentHpTable[tonumber(teamInfo.hid)],m_maxHpTable[tonumber(teamInfo.hid)])
        if m_currentHpTable[tonumber(teamInfo.hid)] and m_maxHpTable[tonumber(teamInfo.hid)] then
            BattleCardUtil.setCardHp(card_o,m_currentHpTable[tonumber(teamInfo.hid)]/m_maxHpTable[tonumber(teamInfo.hid)])
        end
        if(damageList[tonumber(teamInfo.hid)]~=nil)then
            --showCardNumber(card_o,-1-m_maxHpTable[tonumber(teamInfo.hid)]+m_currentHpTable[tonumber(teamInfo.hid)],0)
            showCardNumber(card_o,0-damageList[tonumber(teamInfo.hid)],0)

        end
        if(isCardDead == true and teamInfo.position ~= nil and m_enemyCardLayer:getChildByTag(3000+tonumber(teamInfo.position))~=nil) then
            card_o = tolua.cast(card_o,"CCXMLSprite")
            card_o:setOpacity(0)
            local tempCard = createBattleCard(tonumber(teamInfo.hid))
            tempCard:setPosition(card_o:getPositionX(),card_o:getPositionY())
            tempCard:setBasePoint(ccp(tempCard:getPositionX(),tempCard:getPositionY()))

            --showCardNumber(card_o,-1-m_currentHpTable[tonumber(teamInfo.hid)],0)
            BattleCardUtil.setCardHp(tempCard,0)
            local animationEnd = function(actionName,xmlSprite)

                deadEffectEndTime = deadEffectEndTime + 1
                --print("deadEffectEndTime:",deadEffectEndTime,#deadList)
                if(deadEffectEndTime>=#deadList)then
                    skipDone()
                end
                tempCard:removeFromParentAndCleanup(true)
            end

            local animationFrameChanged = function(frameIndex,xmlSprite)
            end

            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            tempCard:setDelegate(delegate)

            tempCard:runXMLAnimation(CCString:create("images/battle/xml/action/T007_0"))
            card_o:getParent():addChild(tempCard,card_o:getZOrder())
        end
    end
    --更新敌人层结束

    --更新玩家层
    local team1arr = m_battleInfo.team1.arrHero

    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        local isCardDead = false

        for deadListIndex=1,#deadList do
            if(tonumber(teamInfo.hid) == deadList[deadListIndex])then
                isCardDead = true
                break
            end
        end

        local card_o = m_playerCardLayer:getChildByTag(1000+tonumber(teamInfo.position))
        ----print("skip hp:",tonumber(teamInfo.hid),m_currentHpTable[tonumber(teamInfo.hid)],m_maxHpTable[tonumber(teamInfo.hid)])
        if m_currentHpTable[tonumber(teamInfo.hid)] and m_maxHpTable[tonumber(teamInfo.hid)] then
            BattleCardUtil.setCardHp(card_o,m_currentHpTable[tonumber(teamInfo.hid)]/m_maxHpTable[tonumber(teamInfo.hid)])
        end
        if(damageList[tonumber(teamInfo.hid)]~=nil)then
            --showCardNumber(card_o,-1-m_maxHpTable[tonumber(teamInfo.hid)]+m_currentHpTable[tonumber(teamInfo.hid)],0)
            showCardNumber(card_o,0-damageList[tonumber(teamInfo.hid)],0)

        end
        if(isCardDead == true and teamInfo.position ~= nil and m_playerCardLayer:getChildByTag(1000+tonumber(teamInfo.position))~=nil) then
            card_o = tolua.cast(card_o,"CCXMLSprite")
            card_o:setOpacity(0)
            local tempCard = createBattleCard(tonumber(teamInfo.hid))
            tempCard:setPosition(card_o:getPositionX(),card_o:getPositionY())
            tempCard:setBasePoint(ccp(tempCard:getPositionX(),tempCard:getPositionY()))

            --showCardNumber(card_o,-1-m_currentHpTable[tonumber(teamInfo.hid)],0)
            BattleCardUtil.setCardHp(tempCard,0)
            local animationEnd = function(actionName,xmlSprite)

                deadEffectEndTime = deadEffectEndTime + 1
                --print("deadEffectEndTime:",deadEffectEndTime,#deadList)
                if(deadEffectEndTime>=#deadList)then
                    skipDone()
                end
                tempCard:removeFromParentAndCleanup(true)
            end

            local animationFrameChanged = function(frameIndex,xmlSprite)
            end
            --增加动画监听
            local delegate = BTAnimationEventDelegate:create()
            delegate:registerLayerEndedHandler(animationEnd)
            delegate:registerLayerChangedHandler(animationFrameChanged)
            tempCard:setDelegate(delegate)

            tempCard:runXMLAnimation(CCString:create("images/battle/xml/action/T007_0"))
            card_o:getParent():addChild(tempCard,card_o:getZOrder())
        end
    end
    --记录死亡玩家
    for k,v in pairs(deadList) do
        -- m_deadPlayerCardArray[k] = v
        table.insert(m_deadPlayerCardArray, v)
    end

    
end

function speedClick1()
    ---[[
    require "script/model/user/UserModel"
    if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
        require "script/ui/tip/AnimationTip"
        AnimationTip.showTip( GetLocalizeStringBy("key_2997") .. speedUpLevel .. GetLocalizeStringBy("key_2293"))
        return
    end
    --]]
    ----print("speedClick========")
    battleSpeedButton1:setVisible(false)
    battleSpeedButton2:setVisible(true)
    battleSpeedButton3:setVisible(false)
    m_BattleTimeScale = 2
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
    CCUserDefault:sharedUserDefault():setIntegerForKey("battle_speed_"..group.."_"..uid,m_BattleTimeScale)
    CCUserDefault:sharedUserDefault():flush()
end

function speedClick2()
    ----print("speedClick========")
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
    CCUserDefault:sharedUserDefault():setIntegerForKey("battle_speed_"..group.."_"..uid,m_BattleTimeScale)
    CCUserDefault:sharedUserDefault():flush()
end

function speedClick3()
    ----print("speedClick========")
    battleSpeedButton2:setVisible(false)
    battleSpeedButton1:setVisible(true)
    battleSpeedButton3:setVisible(false)
    m_BattleTimeScale = 1
    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
    CCUserDefault:sharedUserDefault():setIntegerForKey("battle_speed_"..group.."_"..uid,m_BattleTimeScale)
    CCUserDefault:sharedUserDefault():flush()
end

function doBattleClick(isPlaySound)
    ----print("=========doBattleClick=========",isPlaySound)
    isPlaySound = (isPlaySound==nil or isPlaySound==-1) and true or isPlaySound
    ----print("=========doBattleClick=========",isPlaySound)
    if(isPlaySound==true and file_exists("audio/effect/" .. "start_fight" .. ".mp3")) then

        AudioUtil.playEffect("audio/effect/" .. "start_fight" .. ".mp3")
    end

    local army = DB_Army.getDataById(m_currentArmyId)
    ---[[
    if(tonumber(army.type)==2)then
        doBattleNpc()
    else
        doBattle()
    end
end

function initBackground(bgFile,startPosition)

    local size = CCDirector:sharedDirector():getWinSize()

    startPosition = startPosition==nil and 0 or startPosition-1
    local startY = MoveDistence*startPosition*(size.width/640)

    if(bgFile==nil) then
    end
    local originalFormat = CCTexture2D:defaultAlphaPixelFormat()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    if(m_bg==nil)then
        --m_bg = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        if(file_exists(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile))))then
            m_bg = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        else

            m_bg = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0.webp")
        end
        ----print("what is that:",m_bg,IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        if(nil~=m_bg) then
            m_bg:setAnchorPoint(ccp(0,0))
            m_bg:setPosition(ccp(0, -startY))
            m_bg:setScale(size.width/m_bg:getContentSize().width)

            local bgUper = nil

            if(file_exists(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile))))then
                bgUper = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
            else

                bgUper = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1.webp")
            end
            bgUper:setPosition(0,m_bg:getContentSize().height)
            bgUper:setAnchorPoint(ccp(0, 0))
            m_bg:addChild(bgUper,-1,2121)
        end
    else
        local texture = nil
        if(file_exists(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile))))then
            texture = CCTextureCache:sharedTextureCache():addImage(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
        else

            texture = CCTextureCache:sharedTextureCache():addImage(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_0.webp")
        end
        if(texture~=nil)then
            m_bg:setTexture(texture)
            m_bg:setTextureRect(CCRectMake(0,0,texture:getContentSize().width,texture:getContentSize().height))

            m_bg:removeChildByTag(2121,true)

            local bgUper = nil
            if(file_exists(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile))))then
                bgUper = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1" .. string.sub(bgFile,string.len(bgFile)-3,string.len(bgFile)))
            else

                bgUper = CCSprite:create(IMG_PATH .. "bg/" .. string.sub(bgFile,1,string.len(bgFile)-4) .. "_1.webp")
            end
            if(bgUper~=nil)then
                bgUper:setPosition(0,m_bg:getContentSize().height)
                bgUper:setAnchorPoint(ccp(0, 0))
                m_bg:addChild(bgUper,-1,2121)
            end
        end
    end

    CCTexture2D:setDefaultAlphaPixelFormat(originalFormat)
end

function setPlayerCardsBack()

    local cardWidth = m_bg:getContentSize().width*0.2

    for i=0,5 do

        local card = tolua.cast(m_playerCardLayer:getChildByTag(1000+i), "CCNode")
        if(card~=nil) then
            card:setPosition(getPlayerCardPointByPosition(i))
            card:setVisible(true)
        end
    end

    ---[[
    --增加逻辑，保留上次NPC战中的队友
    if(m_currentArmyIndex>1)then

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
        local lastArmy = DB_Army.getDataById(armyIdArray[m_currentArmyIndex-1])

        if(lastArmy.monster_group_npc~=nil)then

            require "db/DB_Team"
            local lastnpcTeam = DB_Team.getDataById(lastArmy.monster_group_npc)
            local lastmonsterIdArray = lua_string_split(lastnpcTeam.monsterID,",")

            for i=0,5 do
                --print("npc battle hidden:",lastmonsterIdArray[i+1],m_formationNpc["" .. i])
                if(i+1>#lastmonsterIdArray ) then
                    --print("npc battle hidden 1")
                    local card = m_playerCardLayer:getChildByTag(1000+i)
                    if(card~=nil)then
                        card:setVisible(false)
                    end
                elseif(tonumber(lastmonsterIdArray[i+1])==1)then

                    --print("npc battle hidden 2")
                elseif(m_formationNpc["" .. i]~=0 and m_formationNpc["" .. i]~=nil) then
                    local lastMid = tonumber(lastmonsterIdArray[i+1])
                    local currentMid = tonumber(m_formationNpc["" .. i])

                    --print("lastMid,currentMid:",lastMid,currentMid)

                    local lastMonsterTmpl = {}
                    if(lastMid~=0)then
                        require "db/DB_Monsters"
                        local lastMTid = DB_Monsters.getDataById(lastMid).htid
                        --print("lastMTid:",lastMTid)
                        require "db/DB_Monsters_tmpl"
                        lastMonsterTmpl = DB_Monsters_tmpl.getDataById(lastMTid)
                    end
                    require "db/DB_Monsters"
                    local currentMTid = DB_Monsters.getDataById(currentMid).htid
                    require "db/DB_Monsters_tmpl"
                    local currentMonsterTmpl = DB_Monsters_tmpl.getDataById(currentMTid)

                    --print("lastMonsterTmpl.action_module_id,currentMonsterTmpl.action_module_id:",lastMonsterTmpl.action_module_id,currentMonsterTmpl.action_module_id)
                    if(lastMonsterTmpl.action_module_id~=currentMonsterTmpl.action_module_id)then

                        --print("npc battle hidden 3")
                        local card = m_playerCardLayer:getChildByTag(1000+i)
                        --print("npc battle hidden 4",card)
                        if(card~=nil)then
                            --print("npc battle hidden 5")
                            card:setVisible(false)
                        end
                    end
                end
            end
        end
    end
    --]]
end

function initPlayerCards()

    m_playerCardLayer = CCLayer:create()
    m_playerCardLayer:setPosition(ccp(0,  -m_bg:getPositionY()/m_bg:getScale()))
    m_playerCardLayer:setAnchorPoint(ccp(0, 0))
    m_bg:addChild(m_playerCardLayer,0,1177)

    for i=0,5 do
        local card = CCSprite:create(IMG_PATH .. "card/card_1.jpg")
        card:setAnchorPoint(ccp(0.5,0.5))
        m_playerCardLayer:addChild(card)
    end
    setPlayerCardsBack()
end

function move0()
    doBattleButton:setVisible(false)
    clearEnemyLayer()

    initCurrentEnemy()


    m_enemyCardLayer:setPosition(ccp(0, MoveDistence-m_bg:getPositionY()/m_bg:getScale()))
    m_enemyCardLayer:setVisible(true)

    local moveTime = 2.5

    m_bg:runAction(CCMoveBy:create(moveTime, ccp(0, -MoveDistence*m_bg:getScale())))

    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCMoveBy:create(moveTime, ccp(0, MoveDistence)))
    layerActionArray:addObject(CCCallFunc:create(setPlayerCardsBack))
    layerActionArray:addObject(CCCallFunc:create(showTitle))
    layerActionArray:addObject(CCDelayTime:create(1))
    --layerActionArray:addObject(CCCallFunc:create(speedClick))

    layerActionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    m_playerCardLayer:runAction(CCSequence:create(layerActionArray))

    local upDownTimes = 4
    local movementY = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale()*0.05
    local moveScale = 1.05

    for i=0,5 do
        local card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+i), "CCNode")
        ----print("move0 card_o",card_o,i)
        local isDead = false
        for j=1,table.maxn(m_deadPlayerCardArray) do
            local cardHid = m_formation["" .. i]
            if(cardHid==m_deadPlayerCardArray[j])then
                isDead = true
                break
            end
        end

        if(card_o~=nil and isDead~=true and card_o:isVisible()==true) then
            card_o:setVisible(false)
            local card = createBattleCard(m_formation["" .. i])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)

            m_playerCardLayer:addChild(card,card_o:getZOrder())

            --更新怒气
            local totalFrameNum = card:runXMLAnimation(CCString:create("images/battle/xml/action/walk_0"));
            local skillTime = totalFrameNum*card:getFpsInterval()

            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
            defenderActionArray:addObject(CCCallFunc:create(endWalkEffect))
            card:runAction(CCSequence:create(defenderActionArray))
        end
    end
    startWalkEffect()
end

function move1ShowEnemey()

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
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

function move1()
    doBattleButton:setVisible(false)
    clearEnemyLayer()

    initCurrentEnemy()

    local enemyCount = 0
    local finishCount = 0

    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil) then
            card:setVisible(false)
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
            appearEffectSprite:retain()
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));

            appearEffectSprite:setPosition(card:getPositionX(),card:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
            appearEffectSprite:release()

            --delegate
            local animationEnd = function(actionName,xmlSprite)

                finishCount = finishCount+1
                if(finishCount==enemyCount)then
                    move1ShowEnemey()
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

function move2ShowEnemy()

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

function move2()
    doBattleButton:setVisible(false)
    clearEnemyLayer()

    initCurrentEnemy()

    m_enemyCardLayer:setVisible(true)

    local distence = CCDirector:sharedDirector():getWinSize().height/m_bg:getScale()*0.4;

    local temp = distence-m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));

    local moveTime = 2.0;

    local actionArray = CCArray:create()
    actionArray:addObject(CCMoveBy:create(moveTime, ccp(0, -distence)))
    actionArray:addObject(CCCallFunc:create(move2ShowEnemy))
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

            local card = createBattleCard(monsterIdArray[i+1])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)

            m_enemyCardLayer:addChild(card,card_o:getZOrder())
            --更新怒气
            local strTemp = CCString:create("images/battle/xml/action/walk_0" )
            local totalFrameNum = card:runXMLAnimation(strTemp);
            local skillTime = totalFrameNum*card:getFpsInterval()

            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
            defenderActionArray:addObject(CCCallFunc:create(endWalkEffect))
            card:runAction(CCSequence:create(defenderActionArray))
        end
    end

    startWalkEffect()

    --]]
end

function move3ShowTitle()

    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

function move3ShowAfterTalk()

    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[3]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move3ShowTitle)
    else
        move3ShowTitle()
    end


end

function move3ShowEnemy()

    m_enemyCardLayer:removeChildByTag(1234,true);

    local fadeInTime = 0.5

    local enemyCount = 0
    local finishCount = 0

    for i=0,5 do
        local card = m_enemyCardLayer:getChildByTag(3000+i)
        if(card~=nil and card:isVisible()==false) then
            enemyCount = enemyCount+1
            local appearEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/meffevt_15"), -1,CCString:create(""));
            appearEffectSprite:setAnchorPoint(ccp(0.5, 0.5));
            appearEffectSprite:setPosition(card:getPositionX(),card:getPositionY());
            m_enemyCardLayer:addChild(appearEffectSprite,99999);
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

end

function move3_1()

    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[2]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move3ShowEnemy)
    else
        move3ShowEnemy()
    end
    --doTalk(39,move3ShowEnemy)
end

function move3()
    doBattleButton:setVisible(false)
    clearEnemyLayer()

    initCurrentEnemy()

    local temp = -m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));

    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)

    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIds = lua_string_split(team.monsterID,",")
    ----print("move3:",army.id,team.id,team.monsterID,team.bossID)
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
            ----print("monsterIds[j] == bossId:",type(monsterIds[j]),type(bossId),monsterIds[j] == bossId)
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

end

function move4ShowTitle()

    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

function move4ShowTalk3()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[4]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move4ShowTitle)
    else
        move4ShowTitle()
    end
    --doTalk(39,checkPreFightDialog)
end

function move4ShowEnemey()
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

end

function move4ShowTalk2()

    ----print("---------move4ShowTalk2-----------")

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

function move4backoff()

    ----print("---------move4backoff-----------")

    local moveTime = 2.0;

    local moveTime = 2.5

    m_bg:runAction(CCMoveBy:create(moveTime, ccp(0, -MoveDistence*m_bg:getScale())))

    m_enemyCardLayer:runAction(CCMoveBy:create(moveTime, ccp(0, MoveDistence)))

    local layerActionArray = CCArray:create()
    layerActionArray:addObject(CCMoveBy:create(moveTime, ccp(0, MoveDistence)))
    layerActionArray:addObject(CCCallFunc:create(setPlayerCardsBack))
    layerActionArray:addObject(CCCallFunc:create(move4ShowTalk2))
    layerActionArray:addObject(CCDelayTime:create(0.5))
    m_playerCardLayer:runAction(CCSequence:create(layerActionArray))

    ----print("---------move4backoff 2-----------")

    require "db/DB_Army"
    local army = DB_Army.getDataById(m_currentArmyId)

    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monsterIdArray = lua_string_split(team.monsterID,",")

    --敌人移动
    for i=0,5 do
        ----print("move4:",i)
        local card_o = m_enemyCardLayer:getChildByTag(3000+i)
        ----print("move4:",card_o)
        if(card_o~=nil)then
            ----print("move4 card_o~=nil")
            card_o = tolua.cast(m_enemyCardLayer:getChildByTag(3000+i), "CCNode")
        end
        if(card_o~=nil and card_o:isVisible()==true) then
            ----print("card_o~=nil and card_o:isVisible()==true",i)
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
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
            --defenderActionArray:addObject(CCCallFunc:create(endWalkEffect))
            card:runAction(CCSequence:create(defenderActionArray))
            ----print("card_o~=nil and card_o:isVisible()==true 2",i)
        end
    end

    ----print("---------move4backoff 3-----------")
    startWalkEffect()
    --己方移动
    for i=0,5 do
        local card_o = tolua.cast(m_playerCardLayer:getChildByTag(1000+i), "CCNode")
        if(card_o~=nil and card_o:isVisible()==true) then
            card_o:setVisible(false)

            ---[[
            local card = createBattleCard(m_formation["" .. i])
            card:setTag(card_o:getTag()+3000)
            card:setAnchorPoint(ccp(0.5,0.5))
            card:setPosition(ccp(card_o:getPositionX(),card_o:getPositionY()))
            card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()))
            card:setIsLoop(true)
            card:getChildByTag(6):setVisible(false)

            m_playerCardLayer:addChild(card,card_o:getZOrder())

            local strTemp = CCString:create("images/battle/xml/action/walk_0" )
            local totalFrameNum = card:runXMLAnimation(strTemp);
            local skillTime = totalFrameNum*card:getFpsInterval()

            ----print("=========skillTime============",skillTime)
            local defenderActionArray = CCArray:create()
            defenderActionArray:addObject(CCDelayTime:create(moveTime))
            defenderActionArray:addObject(CCCallFuncN:create(BattleLayer.removeSelf))
            card:runAction(CCSequence:create(defenderActionArray))
        end
    end

end

function move4ShowTalk1()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[2]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move4backoff)
    else
        move4backoff()
    end
    --doTalk(39,move4backoff)
end

function move4()

    doBattleButton:setVisible(false)
    clearEnemyLayer()

    initCurrentEnemy()

    local temp = -m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));

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

end

function move5ShowTitle()

    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(showTitle))
    actionArray:addObject(CCDelayTime:create(1))
    actionArray:addObject(CCCallFunc:create(checkPreFightDialog))
    doBattleButton:runAction(CCSequence:create(actionArray))
end

function move5ShowTalk3()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[5]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move5ShowTitle)
    else
        move5ShowTitle()
    end
end

function move5ShowEnemey()

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

end

function move5ShowTalk2()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[4]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move5ShowEnemey)
    else
        move5ShowEnemey()
    end
    --doTalk(39,move5ShowEnemey)
end

function move5change2()
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
function move5change()

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

end

function move5ShowTalk1()
    local talkId = lua_string_split(m_currentArmyAppearStyle,"|")[3]
    if(talkId~=nil and talkId~=0) then
        doTalk(talkId,move5change)
    else
        move5change()
    end
    --doTalk(39,move5change)
end

function move5()
    doBattleButton:setVisible(false)
    clearEnemyLayer()
    initCurrentEnemy()
    local temp = -m_bg:getPositionY()/m_bg:getScale();
    m_enemyCardLayer:setVisible(true);
    m_enemyCardLayer:setPosition(ccp(0, temp));
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
                    ----print("firstIdArr[i]:",firstIdArr[i])
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
end

function showNextArmy()

    if(skipFightButton~=nil)then
    --skipFightButton:removeFromParentAndCleanup(true)
    end
    --skipFightButton = nil
    endShake()
    require "script/ui/login/LoginScene"
    --LoginScene.setBattleStatus(false)
    m_isInFighting = false
    ----print("===========showNextArmy==========")
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
        CCDirector:sharedDirector():getScheduler():setTimeScale(1)
        if((m_appraisal=="E" or m_appraisal=="F"))then
            require "script/battle/BattleReportLayer"
            local reportLayer = BattleReportLayer.getBattleReportLayer(false,m_copy_id,m_base_id,m_level,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber,m_copyType,false)
            battleBaseLayer:addChild(reportLayer,99999)
            --print("BattleReportLayer.getBattleReportLayer false")
            skipFightButton:setVisible(false)
            return
        else
            require "script/battle/BattleReportLayer"
            ----print("#m_itemArray:",#m_itemArray)
            --print("getBattleReportLayer true")
            local reportLayer = BattleReportLayer.getBattleReportLayer(true,m_copy_id,m_base_id,m_level,m_soulNumber,m_itemArray,m_silverNumber,m_expNumber,m_copyType,m_heroArray,m_isScore)
            battleBaseLayer:addChild(reportLayer,99999)
            skipFightButton:setVisible(false)
            --closeLayer()
            return
        end
    end
    require "db/DB_Army"
    local army = DB_Army.getDataById(armyIdArray[m_currentArmyIndex])
    m_currentArmyId = army.id
    m_currentArmyAppearStyle = army.appear_style
    ----print_table("army:",army)
    require "db/DB_Team"
    local team = DB_Team.getDataById(army.monster_group)
    local monstersStr = team.monsterID
    --initEnemyLayer(monstersStr)
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    m_enemyCardLayer:setVisible(true)
    if(tonumber(army.type)==2)then
        ----print("tonumber(army.type)==2")
        --判断是否为NPC战斗
        m_formationNpc = {}
        local npcTeam = DB_Team.getDataById(army.monster_group_npc)
        local monsterIdArray = lua_string_split(npcTeam.monsterID,",")
        ----print("npcTeam.monsterID:",npcTeam.monsterID,army.monster_group_npc,army.id)
        for i=0,5 do
            ----print("monsterIdArray[i+1]",monsterIdArray[i+1])
            if(i+1>#monsterIdArray or monsterIdArray[i+1]=="0") then

            elseif(tonumber(monsterIdArray[i+1])==1)then
                m_formationNpc["" .. i] = tonumber(getMainHero().hid)
            else
                m_formationNpc["" .. i] = tonumber(monsterIdArray[i+1])
            end
        end
        m_playerCardLayer:removeFromParentAndCleanup(true)
        ----print_table("m_formationNpc",m_formationNpc)
        m_playerCardLayer = PlayerCardLayer.getPlayerCardLayer(CCSizeMake(640,600),m_formationNpc)
        m_playerCardLayer:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
        m_playerCardLayer:setAnchorPoint(ccp(0, 0))
        --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
        m_bg:addChild(m_playerCardLayer,0,1177)
        PlayerCardLayer.setSwitchable(false)
        --m_playerCardLayer:setVisible(true)
        m_formation = m_formationNpc
        ---[[
        --增加逻辑，保留上次NPC战中的队友
        if(m_currentArmyIndex>1)then
            require "db/DB_Army"
            local lastArmy = DB_Army.getDataById(armyIdArray[m_currentArmyIndex-1])
            require "db/DB_Team"
            local lastnpcTeam = DB_Team.getDataById(lastArmy.monster_group_npc)
            local lastmonsterIdArray = lua_string_split(lastnpcTeam.monsterID,",")

            for i=0,5 do
                --print("npc battle hidden:",lastmonsterIdArray[i+1],m_formationNpc["" .. i])
                if(i+1>#lastmonsterIdArray ) then
                    --print("npc battle hidden 1")
                    local card = m_playerCardLayer:getChildByTag(1000+i)
                    if(card~=nil)then
                        card:setVisible(false)
                    end
                elseif(tonumber(lastmonsterIdArray[i+1])==1)then
                    --print("npc battle hidden 2")
                elseif(m_formationNpc["" .. i]~=0 and m_formationNpc["" .. i]~=nil) then
                    --elseif(tonumber(lastmonsterIdArray[i+1])~=m_formationNpc["" .. i])then
                    local lastMid = tonumber(lastmonsterIdArray[i+1])
                    local currentMid = tonumber(m_formationNpc["" .. i])
                    --print("lastMid,currentMid:",lastMid,currentMid)
                    local lastMonsterTmpl = {}
                    if(lastMid~=0)then
                        require "db/DB_Monsters"
                        local lastMTid = DB_Monsters.getDataById(lastMid).htid
                        --print("lastMTid:",lastMTid)
                        require "db/DB_Monsters_tmpl"
                        lastMonsterTmpl = DB_Monsters_tmpl.getDataById(lastMTid)
                    end
                    require "db/DB_Monsters"
                    local currentMTid = DB_Monsters.getDataById(currentMid).htid
                    require "db/DB_Monsters_tmpl"
                    local currentMonsterTmpl = DB_Monsters_tmpl.getDataById(currentMTid)
                    --print("lastMonsterTmpl.action_module_id,currentMonsterTmpl.action_module_id:",lastMonsterTmpl.action_module_id,currentMonsterTmpl.action_module_id)
                    if(lastMonsterTmpl.action_module_id~=currentMonsterTmpl.action_module_id)then

                        --print("npc battle hidden 3")
                        local card = m_playerCardLayer:getChildByTag(1000+i)
                        --print("npc battle hidden 4",card)
                        if(card~=nil)then
                            --print("npc battle hidden 5")
                            card:setVisible(false)
                        end
                    end
                end
            end
        end
        --]]
    else
        if(armyIdArray[m_currentArmyIndex-1] ~= nil)then
            local lastArmy = DB_Army.getDataById(armyIdArray[m_currentArmyIndex-1])
            if(tonumber(lastArmy.type)==2)then

                m_formation = m_formation_back
                m_playerCardLayer:removeFromParentAndCleanup(true)
                ----print_table("m_formation",m_formation)
                m_playerCardLayer = PlayerCardLayer.getPlayerCardLayer(CCSizeMake(640,600),m_formation)

                m_playerCardLayer:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
                m_playerCardLayer:setAnchorPoint(ccp(0, 0))
                --CCSizeMake(CCDirector:sharedDirector():getWinSize().width,CCSizeMake(CCDirector:sharedDirector():getWinSize().height*0.4)
                m_bg:addChild(m_playerCardLayer,0,1177)
                PlayerCardLayer.setSwitchable(false)
            end
        end
    end
    --阵亡队友处理
    if(m_battleInfo ~= nil) then
        local team1arr = m_battleInfo.team1.arrHero
        for i=1,table.maxn(m_deadPlayerCardArray) do
            local pos = -1

            for j=1,#team1arr do
                local teamInfo = team1arr[j]
                ----print("-------  deal with dead body:",teamInfo.hid,teamInfo.position,m_deadPlayerCardArray[i])
                if(teamInfo.hid == m_deadPlayerCardArray[i])then
                    pos = teamInfo.position
                    break
                end
            end

            local node = m_playerCardLayer:getChildByTag(1000+pos)

            if(node ~= nil) then
                local deadActionArray = CCArray:create()
                deadActionArray:addObject(CCFadeIn:create(0.5))
                deadActionArray:addObject(CCFadeOut:create(0.5))
                node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))

                --增加待复活特效
                local waitSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/fuhuo_2"), -1,CCString:create(""))
                waitSprite:setAnchorPoint(ccp(0.5, 0.5));
                waitSprite:setPosition(node:getContentSize().width/2,node:getContentSize().height*0.7);
                node:addChild(waitSprite,99999,9115);

                local reviveIcon = CCSprite:create(IMG_PATH .. "icon/icon_revive.png")
                reviveIcon:setAnchorPoint(ccp(0.5,0.5))
                reviveIcon:setPosition(node:getContentSize().width/2,node:getContentSize().height*0.2)
                node:addChild(reviveIcon,99999,9116)
                m_playerCardLayer:removeChildByTag(node:getTag()+8115,true)

                if m_copyType == kEliteCopy then
                    doReviveCard(true, m_deadPlayerCardArray[i])
                end
            else
             ----------move4backoff-print("-------- not found:",m_deadPlayerCardArray[i])
            end
        end
    end
    --清理卡牌信息
    ----print("--------------m_cardBuffArray-------------------")
    --print_table("m_cardBuffArray",m_cardBuffArray)
    for i=0,5 do
        local card = m_playerCardLayer:getChildByTag(1000+i)
        if(card~=nil)then
            BattleCardUtil.setCardAnger(card,0)
            BattleCardUtil.setCardHp(card,1)
            ----print("shownextarmy buff:",1000+i,m_cardBuffArray[1000+i])
            if(m_cardBuffArray[1000+i]~=nil)then
                for j=1,#m_cardBuffArray[1000+i] do

                    card:removeChildByTag(100000+m_cardBuffArray[1000+i][j],true)
                end
            end
            card:getChildByTag(6):setVisible(false)
        end
    end
    m_cardBuffArray = {}
    battleRoundLabel:setString("0/30")
    local callFunc = nil
    local appearStr = string.sub(m_currentArmyAppearStyle,1,1)
    ----print("-------appearStr:",appearStr,m_currentArmyAppearStyle)
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
    end

    local actionArr = CCArray:create()
    actionArr:addObject(CCDelayTime:create(1))
    actionArr:addObject(callFunc)
    local actions = CCSequence:create(actionArr)
    battleBaseLayer:runAction(actions)
    --doBattleButton:setVisible(true)
end

--[[
@des : 初始化顶部ui
--]]
function initUperLayer()
    require "script/ui/main/MainScene"
    MainScene.initScales()
    battleUperLayer = CCLayer:create()

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

    --线下显示战斗信息id
    if g_debug_mode and m_battleInfo then

        local bgPanel = CCLayerColor:create(ccc4(0,0,0,111))
        bgPanel:setContentSize(CCSizeMake(200,200))
        bgPanel:setAnchorPoint(ccp(0, 0.5))
        bgPanel:setPosition(ccps(0, 0.5))
        battleUperLayer:addChild(bgPanel)
        bgPanel:setScale(g_fElementScaleRatio)

        local interY = 30

        local bridLabel = CCLabelTTF:create("brid:"..m_battleInfo.brid or 0,g_sFontName,22)
        bridLabel:setAnchorPoint(ccp(0.0, 1))
        bridLabel:setPosition(10, bgPanel:getContentSize().height - 10)
        bgPanel:addChild(bridLabel)

        local firstAttack = CCLabelTTF:create("firstAttack:".. (m_battleInfo.firstAttack or 0),g_sFontName,22)
        firstAttack:setAnchorPoint(ccp(0.0, 1))
        firstAttack:setPosition(10, bgPanel:getContentSize().height - 10 - interY * 1)
        bgPanel:addChild(firstAttack)

        local musicId = CCLabelTTF:create("musicId:"..m_battleInfo.musicId or 0,g_sFontName,22)
        musicId:setAnchorPoint(ccp(0.0, 1))
        musicId:setPosition(10, bgPanel:getContentSize().height - 10 - interY * 2)
        bgPanel:addChild(musicId)

        local appraisal = CCLabelTTF:create("appraisal:"..m_battleInfo.appraisal or 0,g_sFontName,22)
        appraisal:setAnchorPoint(ccp(0.0, 1))
        appraisal:setPosition(10, bgPanel:getContentSize().height - 10 - interY * 3)
        bgPanel:addChild(appraisal)

    end

    local startX = battleBaseLayer:getContentSize().width*0.05
    local intervalX = battleBaseLayer:getContentSize().width*0.11
    local labelX = battleBaseLayer:getContentSize().width*0.05

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

    battleSpeedButton3 = CCMenuItemImage:create(IMG_PATH .. "btn/btn_speed3_n.png",IMG_PATH .. "btn/btn_speed3_d.png")
    battleSpeedButton3:setAnchorPoint(ccp(0,0))
    battleSpeedButton3:setPosition(0,0)
    battleSpeedButton3:registerScriptTapHandler(speedClick3)
    battleSpeedButton3:setScale(MainScene.elementScale)


    m_BattleTimeScale = CCUserDefault:sharedUserDefault():getIntegerForKey("battle_speed_"..group.."_"..uid)
    if(m_BattleTimeScale<=1) then
        m_BattleTimeScale = 1
        CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
        battleSpeedButton2:setVisible(false)
        battleSpeedButton3:setVisible(false)
        battleSpeedButton1:setVisible(true)
    else
        require "script/model/user/UserModel"
        if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUpLevel)then
            m_BattleTimeScale = 1
            CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
            battleSpeedButton2:setVisible(false)
            battleSpeedButton3:setVisible(false)
             battleSpeedButton1:setVisible(true)
        else
            if(UserModel.getHeroLevel()==nil or tonumber(UserModel.getHeroLevel())<speedUp3Level or (m_BattleTimeScale>=2 and m_BattleTimeScale<3))then
                m_BattleTimeScale = 2
                CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
                battleSpeedButton1:setVisible(false)
                battleSpeedButton3:setVisible(false)
                battleSpeedButton2:setVisible(true)
            else
                m_BattleTimeScale = 3
                CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
                battleSpeedButton2:setVisible(false)
                battleSpeedButton1:setVisible(false)
                battleSpeedButton3:setVisible(true)
            end
        end
    end
    CCUserDefault:sharedUserDefault():setIntegerForKey("battle_speed_"..group.."_"..uid,m_BattleTimeScale)
    CCUserDefault:sharedUserDefault():flush()


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
    menu:addChild(battleSpeedButton3)
    menu:addChild(doBattleButton)
    battleUperLayer:addChild(menu,0,1299)
    menu:setTouchPriority(-1000)

    --local menu = battleUperLayer:getChildByTag(1299)
    skipFightButton = CCMenuItemImage:create(IMG_PATH .. "icon/icon_skip_n.png",IMG_PATH .. "icon/icon_skip_h.png")
    skipFightButton:registerScriptTapHandler(skipClick)
    skipFightButton:setAnchorPoint(ccp(1,0))
    skipFightButton:setPosition(battleBaseLayer:getContentSize().width*1,0)
    menu:addChild(skipFightButton)
    skipFightButton:setScale(MainScene.elementScale)

    autoFightButton = CCMenuItemImage:create(IMG_PATH .. "icon/icon_autofight.png",IMG_PATH .. "icon/icon_autofight.png")
    autoFightButton:registerScriptTapHandler(autoFightClick)
    autoFightButton:setAnchorPoint(ccp(1,0))
    autoFightButton:setPosition(battleBaseLayer:getContentSize().width,0)
    menu:addChild(autoFightButton)
    autoFightButton:setScale(MainScene.elementScale)

    local autoFightStr = isAutoFight==true and GetLocalizeStringBy("key_1712") or GetLocalizeStringBy("key_2379")
    local autoFightLabel = CCLabelTTF:create(autoFightStr,g_sFontPangWa,autoFightButton:getContentSize().height*0.55)
    autoFightLabel:setAnchorPoint(ccp(0.5,0.5))
    autoFightLabel:setPosition(autoFightButton:getContentSize().width/2,autoFightButton:getContentSize().height/2)
    autoFightLabel:setColor(ccc3(255,220,0))
    autoFightButton:addChild(autoFightLabel,9,110)

    if(m_copyType==2)then
        autoFightButton:setVisible(true)
        skipFightButton:setPosition(skipFightButton:getPositionX(), autoFightLabel:getContentSize().height*MainScene.elementScale + 20*MainScene.elementScale )
    else
        autoFightButton:setVisible(false)
    end
    --非PVP时隐藏跳过,显示自动战斗
    if(m_isShowBattle~=true or m_isShowSkipButton~=true)then
        skipFightButton:setVisible(false)
    else
        skipFightButton:setVisible(true)
    end
    return battleUperLayer
end

function doBattleCallback(cbFlag, dictData, bRet)

    m_newcopyorbase = {}
    visibleList = {}
    if(dictData==nil or dictData.ret==nil) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
        closeLayer()
        return
    end

    if(dictData.ret.err=="nodefeatnum") then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_1001"), nil, false, nil)
        closeLayer()
        return
    end

    require("script/utils/LuaUtil")
    local btinfo = dictData.ret.fightRet==nil and dictData.ret or dictData.ret.fightRet
    ----print("btinfo:",btinfo)
    --btinfo = "eJyVVM1rFEkUn+p5mUllMia9Ezc6RokelxDyie6yB1klJGGRkAxRd4bsVk/XzLTpL6u7jXoQEmZRYcWDB2FZ4tGDByF48aAHvefi3T8gCN5F0FfVM5mPBGUbumdevd/7vV+9evX6MiRrsDC0OT1O+jKEClbloOm4xMrrXMDWi+1d3eQV7ppovdorZVk5tDwXHk1khBe5JpBhJsQyj5dpUrKkJFAXjTUgOURcZA5Sx/6jpjIKt3yO4bGxyuyIw+YoIRKhgQZIcjWlBPTC01/6gPQ32eXaESCDsf0DkCEYaovbevEkkYJPH/O98GCwFZc1okqFi9jQY2PBhMdzNJRCRqjJQgZf8CEquivD1rW2FOhOqTy98PxIp7Qnia7AXIe07Z2GtLrRHndIvjMkU0FFdrK9IsVm2u6KHEird1SytB9nfCsuOQTHyKlmRizFZ6V5V51oLzzCpFojeMBhrultuEnl60q+yUkHR9tRvl5scRx6lOcPCmidZ74VPJo8rGz3ZgnRsd8u1CzbjNebDCgCGU60GH6kPfLnGNx180BH4NfYeljOw8gIkFZ9ujezfwqNzfS0V1Pb39lOl7bTMU+zDZSeerXFMKpqWexuhOuk5bza5ayfVNXKMd8XzAqYnUqvrKxkBd9gwpQXusaFF+NpLbRM2Nw7m7H5DW5Df8YJQrwASEpo4EU2nM0Gln0D77mb5jd9MKkVcgeD4e2/dwg1qghO5EEbcKLAKkuDGgIp6+9u65Gw/5RG6vTUBPvZMJk5fY7PnpucmMmEnDmTMr/LHJ7KTuIzM5uOpJb3l8ehbzj0sMvn/QteEEKkW8GSzW5xkRzAU5yX6tNSfbqGAbJbxmC3qPteYKnZkhiHnozDbs77cL+klyMcRWqC5fj1yPIX3Ionbz4TjuVW8V9yEhLJKXyn8Z2BBMkF65Zt/+Z56xT7JsSZFUSCI3INEn+hX/XSisSgPyenozLwJgzHM7JhTkiNy6oDUOB0Acg40FV4ePwKaH+gq7RPaUACK0cqyFdry3MNbRv728WZ1eTa3hmDzf/OFACwTKvwz8L/I6tXXZwy5GjFqtbCOU+UOXzYIOo8phA8lyKL8Pj8OOi/w4PlS9oSpXFibIgx+SnI6vavwtaSzEubtK8XXZw+MRTv35j8qP0i9G+jA/pyzcX52GQtStZiAbTvseI8kdCS2vhB6JufEGoQH55dIeQrLpd/Dg=="
    local amf3_obj = Base64.decodeWithZip(btinfo)
    ----print("--------------------------")

    local lua_obj = amf3.decode(amf3_obj)

    m_battleInfo = lua_obj
    printTable("m_battleInfo",m_battleInfo)

    initPlayerCardHidMap()
    --存储COPY信息
    m_newcopyorbase = dictData.ret.newcopyorbase
    m_extra_reward = dictData.ret.extra_reward
    m_extra_info = dictData.ret.extra
    --存储战斗结果
    m_appraisal = dictData.ret.appraisal
    --储存HP信息
    m_currentHp = dictData.ret.curHp
    --储存奖励信息
    m_reward = dictData.ret.reward
    m_isScore = dictData.ret.getscore
    --掉落信息
    if(nil~=dictData.ret.reward.hero)then
        m_currentHeroDropArray = dictData.ret.reward.hero
        for i=1,#dictData.ret.reward.hero do
            m_heroDropArray[#m_heroDropArray+1] = dictData.ret.reward.hero[i]
        end
    end


    --更新敌人层
    clearEnemyLayer()

    local team2arr = m_battleInfo.team2.arrHero

    local cardWidth = m_bg:getContentSize().width*0.2;

    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));

        m_enemyCardLayer:addChild(card,5-i)

        ----print("2 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = teamInfo.currRage==nil and 0 or tonumber(teamInfo.currRage)
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        ----print("setCardAnger enemy:",m_currentAngerTable[teamInfo.hid])
        BattleCardUtil.setCardAnger(card, m_currentAngerTable[teamInfo.hid], teamInfo.hid)

    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束

    --更新玩家层
    m_playerCardLayer:removeFromParentAndCleanup(true)

    m_formation = {}

    local team1arr = m_battleInfo.team1.arrHero

    m_deadPlayerCardArray = {}

    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid

            ----print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
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
                m_currentAngerTable[teamInfo.hid] = teamInfo.currRage==nil and 0 or tonumber(teamInfo.currRage)
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
                --BattleCardUtil.setCardAnger(card, m_currentAngerTable[teamInfo.hid])
            end

        end
    end
    m_playerCardLayer = PlayerCardLayer.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_playerCardLayer:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_playerCardLayer:setAnchorPoint(ccp(0, 0))

    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            local card = m_playerCardLayer:getChildByTag(1000+tonumber(teamInfo.position))
            if(card~=nil)then
                ----print("setCardAnger player:",m_currentAngerTable[teamInfo.hid])
                card = tolua.cast(card,"CCXMLSprite")
                BattleCardUtil.setCardAnger(card, m_currentAngerTable[teamInfo.hid], teamInfo.hid)
            end
        end
    end
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

        local node = m_playerCardLayer:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
    --]]

    m_bg:addChild(m_playerCardLayer,0,1177)

    --更新玩家层结束

    ----print("=-=-=-=-=-=-=-=-=-=")
    m_battleIndex = 1

    require "script/ui/login/LoginScene"
    LoginScene.setBattleStatus(true)
    m_isInFighting = true
    PlayerCardLayer.setSwitchable(false)
    doBattleButton:setVisible(false)
    BattleCardUtil.setNameVisible(true)

    addCraftInBattle()

    showPetAtBattle(function ( ... )
        currentRoundOver()
        showNextMove()
    end)
    --显示跳过战斗按钮
    skipFightButton:setVisible(true)
end


function createPetInfoPanel( petTid, teamInfo, isFirstAttack)

    local petInfo      = DB_Pet.getDataById(petTid)
    --宠物信息面板
    local petInfoPanel = CCSprite:create("images/battle/pet/pet_info_panel.png")
    petInfoPanel:setAnchorPoint(ccp(0.5, 0.5))
    petInfoPanel:setScale(g_fScaleX)

    local battlePetWord = CCSprite:create("images/battle/pet/battle_pet.png")
    battlePetWord:setPosition(ccpsprite(0.53, 0.95, petInfoPanel))
    battlePetWord:setAnchorPoint(ccp(0.5, 0.5))
    petInfoPanel:addChild(battlePetWord, 2006)

    local petSprite = CCSprite:create("images/pet/body_img/" .. petInfo.roleModelID)
    petSprite:setPosition(ccpsprite(-0.15, 0.5, petInfoPanel))
    petSprite:setAnchorPoint(ccp(0, 0.5))
    petInfoPanel:addChild(petSprite)
    petSprite:setScale(0.5)

    --宠物名称
    local petName = CCRenderLabel:create( petInfo.roleName , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    petName:setPosition(ccpsprite(0, 0, petInfoPanel))
    petInfoPanel:addChild(petName, 2)
    petName:setColor(HeroPublicLua.getCCColorByStarLevel(petInfo.quality))
    --先后手图标
    local firstAttackImagePath = "images/battle/strength/firstAttack.png"
    local lastAttackImagePath = "images/battle/strength/lastAttack.png"
    local attackSprite = nil
    if(isFirstAttack) then
        attackSprite = CCSprite:create(firstAttackImagePath)
    else
        attackSprite = CCSprite:create(lastAttackImagePath)
    end
    -- 玩家名称
    local playName = CCRenderLabel:create( teamInfo.name , g_sFontPangWa, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    playName:setColor(ccc3(0xff,0xf6,0x00))
    local nameNode = BaseUI.createHorizontalNode({attackSprite, playName})
    nameNode:setAnchorPoint(ccp(0.5, 0.5))
    nameNode:setPosition(ccpsprite(0.5, 1.15, petInfoPanel))
    petInfoPanel:addChild(nameNode)

    --计算宠物属性数值
    require "script/ui/pet/PetUtil"
    require "script/ui/pet/PetData"
    local affixValues = PetUtil.getPetValueByInfo(teamInfo.arrPet[1])
    
    if table.isEmpty(affixValues) then
        --兼容旧版本的属性计算方法
        affixValues = PetUtil.getPetValueByInfo(teamInfo.arrPet[1].arrSkill)
    end
    affixValues = affixValues or {}
    local evolveAffix = {}
    --兼容老板代码
    if PetData.getPetTrainAttrTotalValue then
        evolveAffix = PetData.getPetTrainAttrTotalValue(teamInfo.arrPet[1])
    end
    --print("teamInfo.arrHero.arrSkill")
    --print_table("teamInfo.arrHero.arrSkill", teamInfo.arrHero.arrSkill)
    --print("affixValues pet:")
    --print_table("affixValues", affixValues)
    --宠物属性
    --生命
    affixValues["1"] = affixValues["1"] or {}
    evolveAffix["51"] = evolveAffix["51"] or {}
    local lifeName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10012") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lifeName:setColor(ccc3(0xff, 0xf6, 0x00))
    local lifeValue = CCRenderLabel:create( "+" .. (affixValues["1"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    lifeValue:setColor(ccc3(0xff, 0xff, 0xff))
    local evolveLifeValue = CCRenderLabel:create( "+" .. (evolveAffix["51"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    evolveLifeValue:setColor(ccc3(0x00, 0xff, 0x18))

    local lifeNode = BaseUI.createHorizontalNode({lifeName, lifeValue, evolveLifeValue})
    lifeNode:setAnchorPoint(ccp(0.5,0.5))
    lifeNode:setPosition(ccpsprite(0.4, 0.7, petInfoPanel))
    petInfoPanel:addChild(lifeNode)

    --攻击
    affixValues["9"] = affixValues["9"] or {}
    evolveAffix["100"] = evolveAffix["100"] or {}
    local attackName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10013") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attackName:setColor(ccc3(0xff, 0xf6, 0x00))
    local attackValue = CCRenderLabel:create( "+" .. (affixValues["9"].displayNum or 0) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    attackValue:setColor(ccc3(0xff, 0xff, 0xff))
    local evolveAttackValue = CCRenderLabel:create( "+" .. (evolveAffix["100"].displayNum or 0) , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    evolveAttackValue:setColor(ccc3(0x00, 0xff, 0x18))

    local attackNode = BaseUI.createHorizontalNode({attackName, attackValue, evolveAttackValue})
    attackNode:setAnchorPoint(ccp(0.5,0.5))
    attackNode:setPosition(ccpsprite(0.7, 0.7, petInfoPanel))
    petInfoPanel:addChild(attackNode)

    --物防
    affixValues["4"] = affixValues["4"] or {}
    evolveAffix["54"] = evolveAffix["54"] or {}
    local physicsDefenseName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10014") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    physicsDefenseName:setColor(ccc3(0xff, 0xf6, 0x00))
    local physicsDefenseValue = CCRenderLabel:create( "+" .. (affixValues["4"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    physicsDefenseValue:setColor(ccc3(0xff, 0xff, 0xff))
    local evolvePhysicsDefenseValue = CCRenderLabel:create( "+" .. (evolveAffix["54"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    evolvePhysicsDefenseValue:setColor(ccc3(0x00, 0xff, 0x18))

    local physicsDefenseNode = BaseUI.createHorizontalNode({physicsDefenseName, physicsDefenseValue, evolvePhysicsDefenseValue})
    physicsDefenseNode:setAnchorPoint(ccp(0.5,0.5))
    physicsDefenseNode:setPosition(ccpsprite(0.4, 0.3, petInfoPanel))
    petInfoPanel:addChild(physicsDefenseNode)

    --法防
    affixValues["5"] = affixValues["5"] or {}
    evolveAffix["55"] = evolveAffix["55"] or {}
    local magicDefenseName = CCRenderLabel:create( GetLocalizeStringBy("lcy_10015") , g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    magicDefenseName:setColor(ccc3(0xff, 0xf6, 0x00))
    local magicDefenseValue = CCRenderLabel:create( "+" .. (affixValues["5"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    magicDefenseValue:setColor(ccc3(0xff, 0xff, 0xff))
    local evolveMagicDefenseValue = CCRenderLabel:create( "+" .. (evolveAffix["55"].displayNum or 0), g_sFontName, 21, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    evolveMagicDefenseValue:setColor(ccc3(0x00, 0xff, 0x18))

    local magicDefenseNode = BaseUI.createHorizontalNode({magicDefenseName, magicDefenseValue, evolveMagicDefenseValue})
    magicDefenseNode:setAnchorPoint(ccp(0.5,0.5))
    magicDefenseNode:setPosition(ccpsprite(0.7, 0.3, petInfoPanel))
    petInfoPanel:addChild(magicDefenseNode)

    return petInfoPanel
end



function showPetAtBattle( callbackFunc )

    --print("show pet battle")
    petNodeContainer = {}
    --判断是否有宠物参战，显示宠物
    local pet1Tid = nil
    local pet2Tid = nil
    if(m_battleInfo.team1.arrPet ~= nil) then
        pet1Tid = m_battleInfo.team1.arrPet[1].pet_tmpl
    end
    if(m_battleInfo.team2.arrPet ~= nil) then
        pet2Tid = m_battleInfo.team2.arrPet[1].pet_tmpl
    end

    if(pet1Tid == nil and pet2Tid == nil) then
        if(callbackFunc) then
            callbackFunc()
        end
        return
    end
    local playerTeam1Pet    =   nil
    local playerTeam2Pet    =   nil

    local isBufferEffectEnd1 = false
    local isBufferEffectEnd2 = false
    local bufferEffctEndCallfunc1 = function ( ... )
        if(isBufferEffectEnd1 == true) then
            return
        end
        isBufferEffectEnd1 = true

        if(pet2Tid and isBufferEffectEnd2 == false) then
            playerTeam2Pet()
            return
        end

        if(callbackFunc and (isBufferEffectEnd2 == true or pet2Tid == nil)) then
            --print("buffer 1 callback")
            callbackFunc()
        end
    end

    local bufferEffctEndCallfunc2 = function ( ... )
        if(isBufferEffectEnd2 == true) then
            return
        end
        isBufferEffectEnd2 = true

        if(pet1Tid and isBufferEffectEnd1 == false) then
            playerTeam1Pet()
            return
        end

        if(callbackFunc and (isBufferEffectEnd1 == true or pet1Tid == nil)) then
            --print("buffer 2 callback")
            callbackFunc()
        end
    end

    local removeNodeFromPetContainer = function ( pNode )
        for k,v in pairs(petNodeContainer) do
            if(v == pNode) then
                petNodeContainer[k] = nil
            end
        end
    end

    --先后手图片路径
    local pet1FirstAttackImagePath = nil
    local pet2FirstAttackImagePath = nil
    --播放卡牌buffer效果
    local isPlayedPetBuffer = false
    local playCardPetBuffer = function ( teamNum )  -- teamNum  1,team1 buffer 效果，2 team2 buffer 效果

        isPlayedPetBuffer = true
        if(pet1Tid ~= nil and teamNum == 1) then
            --team1 宠物buffer 特效
            local cardArray  = m_playerCardLayer:getChildren()
            for i=0,cardArray:count()-1 do
                local cardSprite    = tolua.cast(cardArray:objectAtIndex(i), "CCSprite")
                if(cardSprite) then
                    local bufferEffct   = CCLayerSprite:layerSpriteWithNameAndCount("images/battle/pet/cwzhandouli", 1, CCString:create(""))
                    bufferEffct:setPosition(ccpsprite(0.5, 0.5, cardSprite))
                    cardSprite:addChild(bufferEffct, 2000)

                    local animationDelegate = BTAnimationEventDelegate:create()
                    animationDelegate:registerLayerEndedHandler(bufferEffctEndCallfunc1)
                    bufferEffct:setDelegate(animationDelegate)
                    bufferEffct:registerScriptHandler(function ( eventType )
                        if(eventType == "exit") then
                            removeNodeFromPetContainer(bufferEffct)
                        end
                    end)
                    table.insert(petNodeContainer, bufferEffct)
                end

            end
        end

        if(pet2Tid ~= nil and teamNum == 2) then
            --team2 宠物buffer 特效
            local cardArray  = m_enemyCardLayer:getChildren()
            for i=0,cardArray:count()-1 do
                local cardSprite    = tolua.cast(cardArray:objectAtIndex(i), "CCSprite")
                if(cardSprite) then
                    local bufferEffct   = CCLayerSprite:layerSpriteWithNameAndCount("images/battle/pet/cwzhandouli", 1, CCString:create(""))
                    bufferEffct:setPosition(ccpsprite(0.5, 0.5, cardSprite))
                    cardSprite:addChild(bufferEffct,2000)

                    local animationDelegate = BTAnimationEventDelegate:create()
                    animationDelegate:registerLayerEndedHandler(bufferEffctEndCallfunc2)
                    bufferEffct:setDelegate(animationDelegate)
                    bufferEffct:registerScriptHandler(function ( eventType )
                        if(eventType == "exit") then
                            removeNodeFromPetContainer(bufferEffct)
                        end
                    end)
                    table.insert(petNodeContainer, bufferEffct)
                end
            end
        end
    end

    local isTeam1First = false
    local isTeam2First = false
    if(tonumber(m_battleInfo.firstAttack) == 1) then
        --print("team1 first")
        isTeam1First = true
        if(pet1Tid == nil) then
            isTeam1First = false
            isTeam2First = true
        end
    else
        --print("team2 first")
        isTeam2First = true
        if(pet2Tid == nil) then
            isTeam1First = true
            isTeam2First = false
        end
    end

    --播放宠物出场
    playerTeam1Pet = function ( ... )
        require "db/DB_Pet"
        if(pet1Tid ~= nil) then
            local pet1Info      = DB_Pet.getDataById(pet1Tid)
            local pet1Sprite    = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/pet/cwdchdown"), -1,CCString:create("")) --
            setAdaptNode(pet1Sprite)
            pet1Sprite:setPosition(ccps(0.5, 0.5))
            battleBaseLayer:addChild(pet1Sprite, 2000)
            pet1Sprite:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(pet1Sprite)
                end
            end)
            table.insert(petNodeContainer, pet1Sprite)
            local replaceXmlSprite = tolua.cast( pet1Sprite:getChildByTag(1002) , "CCXMLSprite")
            local bodySprite = nil
            if(file_exists("images/pet/body_img/" .. pet1Info.roleModelID))then
                replaceXmlSprite:setReplaceFileName(CCString:create("images/pet/body_img/" .. pet1Info.roleModelID))
            end
            replaceXmlSprite:setVisible(false)

            local petInfoPanel = createPetInfoPanel(pet1Tid, m_battleInfo.team1, isTeam1First)
            petInfoPanel:setPosition(ccps(-0.5, 0.5))
            battleBaseLayer:addChild(petInfoPanel, 2005)
            petInfoPanel:runAction(CCMoveTo:create(0.4, ccps(0.55, 0.5)))
            petInfoPanel:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(petInfoPanel)
                end
            end)
            table.insert(petNodeContainer, petInfoPanel)

            local animationEndFunc = function ( ... )
                pet1Sprite:removeFromParentAndCleanup(true)
                pet1Sprite = nil

                petInfoPanel:removeFromParentAndCleanup(true)
                petInfoPanel = nil

                playCardPetBuffer(1)
            end

            local animationDelegate = BTAnimationEventDelegate:create()
            animationDelegate:registerLayerEndedHandler(animationEndFunc)
            pet1Sprite:setDelegate(animationDelegate)
        else
            playerTeam2Pet()
        end
    end

    playerTeam2Pet = function ( ... )
        if(pet2Tid ~= nil) then
            local pet2Info      = DB_Pet.getDataById(pet2Tid)
            local petSprite    = CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/pet/cwdchup"), -1,CCString:create("")) --
            setAdaptNode(petSprite)
            petSprite:setPosition(ccps(0.5, 0.5))
            battleBaseLayer:addChild(petSprite, 2000)
            petSprite:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(petSprite)
                end
            end)
            table.insert(petNodeContainer, petSprite)

            local replaceXmlSprite = tolua.cast( petSprite:getChildByTag(1002) , "CCXMLSprite")
            local bodySprite = nil
            if(file_exists("images/pet/body_img/" .. pet2Info.roleModelID))then
                replaceXmlSprite:setReplaceFileName(CCString:create("images/pet/body_img/" .. pet2Info.roleModelID))
            end
            replaceXmlSprite:setVisible(false)

            local petInfoPanel = createPetInfoPanel(pet2Tid, m_battleInfo.team2,  isTeam2First)
            petInfoPanel:setPosition(ccps(1.5, 0.5))
            battleBaseLayer:addChild(petInfoPanel, 2005)
            petInfoPanel:runAction(CCMoveTo:create(0.4, ccps(0.55, 0.5)))
            petInfoPanel:registerScriptHandler(function ( eventType )
                if(eventType == "exit") then
                    removeNodeFromPetContainer(petInfoPanel)
                end
            end)
            table.insert(petNodeContainer, petInfoPanel)

            local animationEndFunc = function ( ... )
                petSprite:removeFromParentAndCleanup(true)
                petSprite = nil

                petInfoPanel:removeFromParentAndCleanup(true)
                petInfoPanel = nil

                playCardPetBuffer(2)
            end

            local animationDelegate = BTAnimationEventDelegate:create()
            animationDelegate:registerLayerEndedHandler(animationEndFunc)
            petSprite:setDelegate(animationDelegate)
        else
            playerTeam1Pet()
        end
    end

    if(tonumber(m_battleInfo.firstAttack) == 1) then
        pet1FirstAttackImagePath = "images/battle/strength/firstAttack.png"
        pet2FirstAttackImagePath = "images/battle/strength/lastAttack.png"
        playerTeam1Pet()
    elseif(tonumber(m_battleInfo.firstAttack) == 2) then
        pet2FirstAttackImagePath = "images/battle/strength/firstAttack.png"
        pet1FirstAttackImagePath = "images/battle/strength/lastAttack.png"
        playerTeam2Pet()
    else
        callbackFunc()
    end
end


-- /**
--  * 得到战车势力
--  * @param  {[type]} pWarCardId  战车id 
--  * @return 势力枚举 kEnemySide 守方 kPlaySide 攻防
--  */
function getWarCardSide( pWarCardId )
    local team1 = m_battleInfo.team1.arrCar
    if team1 then
        for k,v in pairs(team1) do
            if tonumber(v.cid) == tonumber(pWarCardId) then
                return kPlaySide
            end
        end
    end
    local team2 = m_battleInfo.team2.arrCar
    if team2 then
        for k,v in pairs(team2) do
            if tonumber(v.cid) == tonumber(pWarCardId) then
                return kEnemySide
            end
        end
    end
end


-- /**
--  * 得到战车信息
--  * @param  {number} pWarCardId 战车id
--  * @return table{cid, attackSkill, tid}  
--  */
function getWarCarInfo( pWarCardId )
    local team1 = m_battleInfo.team1.arrCar
    if team1 then
        for k,v in pairs(team1) do
            if tonumber(v.cid) == tonumber(pWarCardId) then
                return v
            end
        end
    end
    local team2 = m_battleInfo.team2.arrCar
    if team2 then
        for k,v in pairs(team2) do
            if tonumber(v.cid) == tonumber(pWarCardId) then
                return v
            end
        end
    end
end


-- /**
--  * 播放战车动画
--  * @param  {Function} pCallback 回调方法
--  * @return {void}
--  */
function showWarCarAction( pCallback )
    local atkId = m_currentBattleBlock.attacker
    if tonumber(atkId) >200 then
        pCallback()
        return
    end

    require "db/DB_Warcar_skill"
    require "db/DB_Item_warcar"
    local carSide = getWarCardSide(atkId)
    local carInfo = getWarCarInfo(atkId)
    local carTid = tonumber(carInfo.tid)
    local carItemInfo = DB_Item_warcar.getDataById(carTid)
    local carSkillInfo = DB_Warcar_skill.getDataById(carItemInfo.showSkillId)
    --播放战车攻击特效
    addWarCarMask()
    playWarCarAtkAction(function ( ... )
        removeWarCarMask()
        pCallback()
    end)
end

-- /**
--  * 添加战车瞄准特效
--  */
function addWarCarAim()
    local defIdMap = {}
    -- defIdMap[m_currentBattleBlock.defender] = m_currentBattleBlock.defender
    for k,v in pairs(m_currentBattleBlock.arrReaction) do
        defIdMap[v.defender] = v.defender 
    end
    for k,v in pairs(defIdMap) do
        local card = getCardByHid(v)
        local aimEffect = XMLSprite:create("images/battle/warcar/effect/jujimiaozhunTX/jujimiaozhunTX")
        aimEffect:setPosition(ccpsprite(0.5, 0.5, card))
        card:addChild(aimEffect, 10, kAimEffTag)
        table.insert(petNodeContainer, aimEffect)
    end
    AudioUtil.playEffect("audio/effect/aim.mp3")
end

-- /**
--  * 移除瞄准特效
--  * @return {void} 
--  */
function removeCarAim()
    local defIdMap = {}
    -- defIdMap[m_currentBattleBlock.defender] = m_currentBattleBlock.defender
    for k,v in pairs(m_currentBattleBlock.arrReaction) do
        defIdMap[v.defender] = v.defender 
    end
    for k,v in pairs(defIdMap) do
        local card = getCardByHid(v)
        card:removeChildByTag(kAimEffTag,true)
    end
end

-- /**
--  * 播放战车打击特效
--  * @param  {Function} pCallback 回调方法
--  * @return {void}
--  */
function playWarCarHitAction( pCallback )
    local atkId = m_currentBattleBlock.attacker
    local carSide = getWarCardSide(atkId)
    local carInfo = getWarCarInfo(atkId)
    local carTid = tonumber(carInfo.tid)
    local carItemInfo = DB_Item_warcar.getDataById(carTid)
    local carSkillInfo = DB_Warcar_skill.getDataById(carItemInfo.showSkillId)
    local hitEffct = carSkillInfo.hitEffect
    local defIdMap = {}
    -- defIdMap[m_currentBattleBlock.defender] = m_currentBattleBlock.defender
    for k,v in pairs(m_currentBattleBlock.arrReaction) do
        defIdMap[v.defender] = {}
        defIdMap[v.defender].cardId = v.defender
        local damgeCount = 0
        for k1,v1 in pairs(v.arrDamage) do
            damgeCount = damgeCount + tonumber(v1.damageValue)
        end
        defIdMap[v.defender].damage = damgeCount
    end
    local playIndex = 0
    local playCount = table.count(defIdMap)
    local playCallback = function ( ... )
        playIndex = playIndex + 1
        if playIndex == playCount then
            if pCallback then
                pCallback()
            end
            return
        end 
    end
    --播放打击音效
    local hitMusic = carSkillInfo.hitMusic
    if hitMusic then
        AudioUtil.playEffect("audio/effect/" .. hitMusic .. ".mp3")
    end
    for k,v in pairs(defIdMap) do
        local card = getCardByHid(v.cardId)
        local aimEffect = XMLSprite:create("images/battle/effect/"..hitEffct)
        aimEffect:setPosition(ccpsprite(0.5, 0.5, card))
        aimEffect:setReplayTimes(1, true)
        aimEffect:setScale(g_fElementScaleRatio)
        card:addChild(aimEffect, 10, kAimEffTag)
        aimEffect:registerEndCallback(function ( ... )
            showCardNumber(card, -v.damage, 0)
            m_currentHpTable[v.cardId] = m_currentHpTable[v.cardId] - v.damage
            BattleCardUtil.setCardHp(card,m_currentHpTable[v.cardId]/m_maxHpTable[v.cardId])
            performWithDelay(card, function ( ... )
                playCallback()
            end, 0.5)
        end)
        table.insert(petNodeContainer, aimEffect)
    end
    showTotalDamage(m_currentBattleBlock)
end

-- /**
--  * 添加战车出场屏蔽黑层
--  */
function addWarCarMask()
    _warCardMaskLayer = CCLayerColor:create(ccc4(0, 0, 0, 200))
    battleBaseLayer:addChild(_warCardMaskLayer, 100)
    _bakWarCarDefenders = {}

    local defIdMap = {}
    -- defIdMap[m_currentBattleBlock.defender] = m_currentBattleBlock.defender
    for k,v in pairs(m_currentBattleBlock.arrReaction) do
        defIdMap[v.defender] = v.defender 
    end
    for k,v in pairs(defIdMap) do
        local card = getCardByHid(v)
        _bakWarCarDefenders[v] = {}
        _bakWarCarDefenders[v].card = card
        local x,y = card:getPosition()
        _bakWarCarDefenders[v].position = ccp(x, y)
        _bakWarCarDefenders[v].parent = card:getParent()
        _bakWarCarDefenders[v].tag = card:getTag()
        
        local cardPos = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
        card:retain()
        card:removeFromParentAndCleanup(false)
        card:setScale(m_bg:getScale())
        _warCardMaskLayer:addChild(card, 10, card:getTag())
        card:release()
        card:setPosition(cardPos)
    end
    _isAddWarCardMask = true
end

-- /**
--  * 删除战车出场屏蔽黑层
--  */
function removeWarCarMask()
    for k,v in pairs(_bakWarCarDefenders) do
        local card = v.card
        card:retain()
        card:removeFromParentAndCleanup(false)
        card:setPosition(v.position)
        card:setScale(1)
        v.parent:addChild(card, 10, v.tag)
        card:release()
    end
    if _warCardMaskLayer then
        _warCardMaskLayer:removeFromParentAndCleanup(true)
        _warCardMaskLayer = nil
        _bakWarCarDefenders = {}
        _isAddWarCardMask = false
    end
end

-- /**
--  * 播放战车弹道特效
--  * @param  {CCPoint} pBeginPos 弹道开始点
--  * @param  {Function} pCallback 回调方法
--  * @return {void}
--  */
function playBulletEffect( pBeginPos, pCallback )
    local atkId = m_currentBattleBlock.attacker
    local carSide = getWarCardSide(atkId)
    local carInfo = getWarCarInfo(atkId)
    local carTid = tonumber(carInfo.tid)
    local carItemInfo = DB_Item_warcar.getDataById(carTid)
    local carSkillInfo = DB_Warcar_skill.getDataById(carItemInfo.showSkillId)
    local bulletEffect = carSkillInfo.bulletEffect
    local defIdMap = {}
    for k,v in pairs(m_currentBattleBlock.arrReaction) do
        defIdMap[v.defender] = {}
        defIdMap[v.defender].cardId = v.defender
    end
    local playIndex = 0
    local playCount = table.count(defIdMap)
    local playCallback = function ( ... )
        playIndex = playIndex + 1
        if playIndex == playCount then
            if pCallback then
                pCallback()
            end
            return
        end 
    end
    --播放弹道音效
    local bulletMusic = carSkillInfo.bulletMusic
    if bulletMusic then
        AudioUtil.playEffect("audio/effect/" .. bulletMusic .. ".mp3")
    end
    for k,v in pairs(defIdMap) do
        local card = getCardByHid(v.cardId)
        local targetPos = card:convertToWorldSpace(ccpsprite(0.5, 0.5, card))
        local bulletEffect = XMLSprite:create("images/battle/warcar/effect/"..bulletEffect.."/"..bulletEffect)
        bulletEffect:setPosition(pBeginPos)
        bulletEffect:setScale(g_fElementScaleRatio)
        _warCardMaskLayer:addChild(bulletEffect, 100)

        local rotation = 0
        local beginPos, endPos = pBeginPos, targetPos
        local reletivePoint = ccp(endPos.x-beginPos.x,endPos.y-beginPos.y)
        local rotation = math.deg(math.atan(math.abs(reletivePoint.x/reletivePoint.y)))
        if(reletivePoint.x<0)then
            rotation = 360 - rotation
        end
        if(reletivePoint.y<0)then
            rotation = rotation>180 and 540-rotation or 180-rotation
        end
        bulletEffect:setRotation(rotation)
        local actionArr = CCArray:create()
        actionArr:addObject(CCMoveTo:create(0.2, targetPos))
        actionArr:addObject(CCCallFunc:create(function ( ... )
            bulletEffect:removeFromParentAndCleanup(true)
            bulletEffect = nil
            playCallback()
        end))
        local seqAction = CCSequence:create(actionArr)
        bulletEffect:runAction(seqAction)
        table.insert(petNodeContainer, bulletEffect)
    end
end

-- /**
--  * 播放战车攻击特效
--  * @param  {number} pCarSkillId 战车技能id
--  * @param  {Function} pCallback   
--  * @return {void}
--  */
function playWarCarAtkAction(pCallback )
    local atkId = m_currentBattleBlock.attacker
    if tonumber(atkId) > 200 then
        callback()
        return
    end
    require "db/DB_Warcar_skill"
    require "db/DB_Item_warcar"
    local carSide = getWarCardSide(atkId)
    local carInfo = getWarCarInfo(atkId)
    local carTid = tonumber(carInfo.tid)
    local carItemInfo = DB_Item_warcar.getDataById(carTid)
    local carSkillInfo = DB_Warcar_skill.getDataById(carItemInfo.showSkillId)
    --技能图标
    local skillIcon = CCSprite:create("images/battle/warcar/icon/"..carSkillInfo.icon)
    skillIcon:setPosition(ccps(0.5, 0.5))
    skillIcon:setAnchorPoint(ccp(0.5, 0.5))
    skillIcon:setScale(m_bg:getScale())
    _warCardMaskLayer:addChild(skillIcon)

    local effectName = carSkillInfo.modelEffect
    local carEffct = XMLSprite:create("images/battle/warcar/effect/"..effectName.."/"..effectName)
    if carSide == kPlaySide then
        carEffct:setPosition(g_winSize.width/2, 0)
        carEffct:setScale(g_fElementScaleRatio)
    else
        carEffct:setScale(-1*m_bg:getScale())
        carEffct:setPosition(g_winSize.width/2, g_winSize.height)
    end
    _warCardMaskLayer:addChild(carEffct, 100)
    table.insert(petNodeContainer, carEffct)
    carEffct:setReplayTimes(1, true)
    carEffct:registerKeyFrameCallback(function ( keyName )
        local actionInfo = string.split(keyName, "|")
        local actionName = actionInfo[1]
        if actionName == "aim_start" then
            print("playWarCarAtkAction aim_start")
            --开始瞄准
            addWarCarAim()
        elseif actionName == "aim_end" then
            print("playWarCarAtkAction aim_end")
            --瞄准结束，开始弹道特效
            removeCarAim()
            skillIcon:removeFromParentAndCleanup(true)
        elseif actionName == "hit" then
            print("playWarCarAtkAction hit")
            --播放打击特效
            playWarCarHitAction(function ( ... )
                if pCallback then
                    pCallback()
                end
            end)
        elseif actionName == "bullet" then
            print("playWarCarAtkAction bullet")
            local frameName = actionInfo[2]
            local frameSprite = carEffct:getFrameByName(frameName)
            local x,y = tonumber(actionInfo[3]), tonumber(actionInfo[4])
            local bulletPos = frameSprite:convertToWorldSpace(ccpsprite(x, y, frameSprite))
            --播放弹道特效
            playBulletEffect( bulletPos, function ()
                --播放打击特效
                playWarCarHitAction(function ( ... )
                    if pCallback then
                        pCallback()
                    end
                end)
            end)
        end
    end)
    --播放战车音效
    local enterMusic = carSkillInfo.enterMusic
    if enterMusic then
        AudioUtil.playEffect("audio/effect/" .. enterMusic .. ".mp3")
    end
end


-- /**
--  * 得到卡牌 
--  * @param  {[number]} pHid 武将id
--  * @return {[CCXMLSprite]}  武将卡牌
--  */
function getCardByHid( pHid )
    local card = nil
    for j=1,#(m_battleInfo.team1.arrHero) do
        local role = m_battleInfo.team1.arrHero[j]
        if tonumber(role.hid) == tonumber(pHid) then
            card = tolua.cast(m_playerCardLayer:getChildByTag(1000+role.position), "CCXMLSprite")
            break
        end
    end
    for j=1,#(m_battleInfo.team2.arrHero) do
        local role = m_battleInfo.team2.arrHero[j]
        if tonumber(role.hid) == tonumber(pHid) then
            card = tolua.cast(m_enemyCardLayer:getChildByTag(3000+role.position), "CCXMLSprite")
            break
        end
    end
    if _bakWarCarDefenders then
        for k,v in pairs(_bakWarCarDefenders) do
            if tonumber(k) == tonumber(pHid) then
                card = v.card
                break
            end
        end
    end
    return card
end


function doBattleNpc()
    ---[[
    local args = CCArray:create()
    args:addObject(CCInteger:create(m_copy_id))

    args:addObject(CCInteger:create(m_base_id))
    args:addObject(CCInteger:create(m_level))
    args:addObject(CCInteger:create(m_currentArmyId))
    args:addObject(CCArray:create())

    require("script/utils/LuaUtil")
    --print_table("tb",m_formationNpc)

    local formation = CCDictionary:create()
    for i=0,5 do
        local hid = m_formationNpc["" .. i]
        if(hid~=nil and hid~=0) then
            ----print("=========hid:",i,hid)
            formation:setObject(CCInteger:create(hid), "" .. i);

        else
            --formation:addObject(CCInteger:create(0))
            formation:setObject(CCInteger:create(0), "" .. i);
        end
    end
    ----print_table("tb",formation)
    args:addObject(formation)

    --print("m_copyType:",m_copyType)
    if(m_copyType==1)then
        RequestCenter.doBattle(BattleLayer.doBattleCallback,args)
    elseif(m_copyType==2)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.ecopy_doBattle(BattleLayer.doBattleCallback,tempArgs)
    elseif(m_copyType==4)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        --tempArgs:addObject(formation)
        RequestCenter.tower_defeatMonster(BattleLayer.doBattleCallback,tempArgs)
    elseif(m_copyType==5)then
        --print("alalalalala")
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        RequestCenter.tower_defeatSpecialTower(BattleLayer.doBattleCallback,tempArgs)
    elseif(m_copyType==6)then
        RequestCenter.Hcopy_doBattle(BattleLayer.doBattleCallback,args)
    else
        local tempArgs = Network.argsHandler(m_copy_id,m_base_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.acopy_doBattle(BattleLayer.doBattleCallback,tempArgs)
    end
end

function doBattle()
    ---[[
    local args = CCArray:create()
    args:addObject(CCInteger:create(m_copy_id))

    args:addObject(CCInteger:create(m_base_id))
    args:addObject(CCInteger:create(m_level))
    args:addObject(CCInteger:create(m_currentArmyId))

    newFormation = PlayerCardLayer.getFormation()
    local isFormationChanged = false

    for k,v in pairs(newFormation) do
        ----print("k,n,o",k,v,m_formation[k])
        if(m_formation[k] ~= v) then
            isFormationChanged = true
        end
    end

    for k,v in pairs(m_formation) do
        ----print("k,n,o",k,m_formation[k],m_formation[k])
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
    ----print_table("tb",m_formation)

    local formation = CCDictionary:create()

    if(isFormationChanged) then
        for i=0,5 do
            local hid = m_formation["" .. i]
            ----print("--------hid:",i,hid)
            if(hid~=nil and hid~=0) then
                formation:setObject(CCInteger:create(hid), "" .. i);

            else
            end
        end
    end
    ----print_table("tb",formation)
    args:addObject(formation)
    --print("aaaaaaaaaaaaaaaaaaa")

    for i=0,5 do
        local hid = m_formation["" .. i]
        ----print("--------hid:",i,hid)
        if(hid==nil) then
            m_formation["" .. i] = 0
        end
    end
    --print_table("m_formation",m_formation)
    require("script/model/user/FormationModel")
    FormationModel.setFormationInfo(m_formation)
    if(m_copyType==1)then
        RequestCenter.doBattle(BattleLayer.doBattleCallback,args)
    elseif(m_copyType==2)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.ecopy_doBattle(BattleLayer.doBattleCallback,tempArgs)
    elseif(m_copyType==4)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        --tempArgs:addObject(formation)
        RequestCenter.tower_defeatMonster(BattleLayer.doBattleCallback,tempArgs)
    elseif(m_copyType==5)then
        local tempArgs = Network.argsHandler(m_copy_id,m_currentArmyId)
        --tempArgs:addObject(formation)
        RequestCenter.tower_defeatSpecialTower(BattleLayer.doBattleCallback,tempArgs)
    elseif(m_copyType==6)then
        RequestCenter.Hcopy_doBattle(BattleLayer.doBattleCallback,args)
    else
        local tempArgs = Network.argsHandler(m_copy_id,m_base_id,m_currentArmyId)
        tempArgs:addObject(formation)
        RequestCenter.acopy_doBattle(BattleLayer.doBattleCallback,tempArgs)
    end
end

function getFormationCallBack(cbFlag, dictData, bRet)

    require("script/utils/LuaUtil")
    ----print_table ("tb", dictData)
    --设置阵型
    require("script/model/user/FormationModel")

    m_formation = {}

    for k,v in pairs(dictData.ret) do
        --local teamInfo = dictData.ret[i]
        m_formation["" .. (tonumber(k)-1)] = tonumber(v)
    end

    FormationModel.setFormationInfo(m_formation)

    m_formation_back = m_formation

    enterBattle2(m_copy_id,m_base_id,m_level)

end

function replay()

    CCDirector:sharedDirector():getScheduler():setTimeScale(m_BattleTimeScale)
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
    visibleList = {}
    m_isInFighting = true

    if(m_afterBattleView~=nil)then
        m_afterBattleView:retain()
        m_afterBattleView:removeFromParentAndCleanup(false)

    end
    m_battleIndex = 1
    m_bg:removeAllChildrenWithCleanup(true)
    m_enemyCardLayer = CCLayer:create()
    m_enemyCardLayer:setPosition(ccp(0, 0))
    m_bg:addChild(m_enemyCardLayer,0,1188)
    m_currentArmyIndex = 0
    --更新敌人层
    clearEnemyLayer()

    local team2arr = m_battleInfo.team2.arrHero

    local cardWidth = m_bg:getContentSize().width*0.2;

    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        --card:setScale(cardWidth/card:getContentSize().width)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));

        m_enemyCardLayer:addChild(card,5-i)

        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = teamInfo.currRage==nil and 0 or tonumber(teamInfo.currRage)
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        BattleCardUtil.setCardAnger(card, m_currentAngerTable[teamInfo.hid], teamInfo.hid)
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))
    --更新敌人层结束

    --更新玩家层
    --m_playerCardLayer:removeFromParentAndCleanup(true)

    m_formation = {}
    local team1arr = m_battleInfo.team1.arrHero
    m_deadPlayerCardArray = {}

    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid

            local currentHp = 0
            if(teamInfo.currHp==nil) then
                currentHp = teamInfo.maxHp
            else
                currentHp = teamInfo.currHp
            end
            if(currentHp==0)then
                m_deadPlayerCardArray[table.maxn(m_deadPlayerCardArray)+1] = teamInfo.hid
            else
                m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
                m_currentHpTable[teamInfo.hid] = currentHp
                m_currentAngerTable[teamInfo.hid] = teamInfo.currRage==nil and 0 or tonumber(teamInfo.currRage)
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end
            end
        end
    end
    m_playerCardLayer = PlayerCardLayer.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_playerCardLayer:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_playerCardLayer:setAnchorPoint(ccp(0, 0))
    --初始化怒气
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid
            local card = m_playerCardLayer:getChildByTag(1000+tonumber(teamInfo.position))
            if(card~=nil)then
                ----print("setCardAnger player:",m_currentAngerTable[teamInfo.hid])
                card = tolua.cast(card,"CCXMLSprite")
                BattleCardUtil.setCardAnger(card, m_currentAngerTable[teamInfo.hid], teamInfo.hid)
                if m_currentHpTable[teamInfo.hid] and m_maxHpTable[teamInfo.hid] then
                    BattleCardUtil.setCardHp(card,m_currentHpTable[teamInfo.hid]/m_maxHpTable[teamInfo.hid])
                end
            end
        end
    end
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

        local node = m_playerCardLayer:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end
    --]]
    --增加战斗力显示
    if(m_isShowStrengthNumber==true)then
        showStrength()
    end
    m_bg:addChild(m_playerCardLayer,0,1177)
    --更新玩家层结束
    ----print("=-=-=-=-=-=-=-=-=-=")
    m_battleIndex = 1
    PlayerCardLayer.setSwitchable(false)
    doBattleButton:setVisible(false)
    BattleCardUtil.setNameVisible(true)

    showPetAtBattle(function ( ... )
        currentRoundOver()
        showNextMove()
    end)
    --显示阵法
    addCraftInBattle()

    skipFightButton:setVisible(true)
end

function showBattleWithString(str,callbackFunc,afterBattleView,bgName,bgmName,armyIds,onBattleView,isShowSkipButton,isShowStrengthNumber,p_battleType)

    -- local amf3_objc = Base64.decodeWithZip(str1)
    -- local lua_obj1 = amf3.decode(amf3_objc)
    -- printTable("lua_obj1", lua_obj1)
    -- print("lua_obj1",lua_obj1)

    init()

    require("script/utils/LuaUtil")
    local amf3_obj = Base64.decodeWithZip(str)
    local lua_obj = amf3.decode(amf3_obj)
    m_battleInfo = lua_obj
    BattleCardUtil.setBattleData(m_battleInfo)
    printTable("m_battleInfo",m_battleInfo)

    local x = "eJzVXHl8VNXZnjtzZiaThZAFYgBRICLWCgiyuTVlCQiKFCESGkOGzIQMJDPTmQkGy6e5SYiBJCQUhBgMBhJ2warF7VMJ4ueCuFSDtHVFEYvWWq39WZHCd5a7nXPvOQn9/KNffy3Nvfes7/u8z/u8594kPkFKWuyNxUr9nupMKT5BSoEX3qJl/ghYc3JLYYrPX+wP+uDVvU/sPZLkLYoFQkFQe2RlQiRUHvQBW4Y3EpnrJ/c9CWgAANac6DqcElFuAkm9eeD6RP2iK6pfnDw/WL/4+Ov16AJd2QG8Udu2/XIX6Dw+Ig5I8R4nXqI/OLm8uNgf8Tgk0HL0BtII9kqDi5nqLfMu8cMnsGE/H76YtyLsB1IGucj1lpb7waMr8Ax99BG21i2DI/QlHVOBlA7eCpJleCKwG7DbsQkANosL1PXF63GrW9hSaOztSAdtN+t7Pcw82zKJNorx2UY7mbU/OH/+/A92PDTAU7tAw+6heFbcOmmxagNkEnJxkw9sCnhiaL+DPD5vzIsGOSuR/sz2asZI0NmRyJSSQKmP3GdnG6bPdhH5vwFw/EFg0GBg4wx6u2RcPoQP5Sk79hSxCbThUt2G+vjztfFZq8LxH02XEorhvkodVp3glOcsLA77vT5eEnag3QA7POFX9wEdjwZUkbh6kA5EDXjGnnJbmZTlUB6bUSXfG6EdvOqJU7PIEqBFRuLBk+i15nAtAvGyzSPA2a0SdyQz8javpKPT+GzvNZYjwR2c1yPY2GHHdDqgjc86B0jSpSriqO2PsgBcs4SnQlyw6rEDhzA5KJ7R2tSu8+nrsePRAB7ZBaqz9DHJPXal+QZ/fGfHk6hRXrOEinJmK8ibzVdpLGYC63dTNSAQ59h7XnhXVA2/ukLj3Bax1nC9ZASh3XqHsGG9W7PYUD0QITTVQFwzx8Lu/kHAMxg8MleHsSEgoMPVgKjPt2KJWRrS2BCBJq8ZqhL8qtNtR4lhId+sNHqKGNtumBPeUJ0qWPDpIkOy0Tqz1G0XUffmQfyQapnJp+71l1ImMjLpRXhKJ9eX1XZlWAXixmdVyw3hYhy29lguHpY2Q+3aIDbEvTfouzOsiyLgQpEl4NTNkylL2K23Dhu25jBZy8iYw/VV4oR7pxXZk40D46AnUzSYkJjEi3boo1lSfcdgw24pdskyOoFsAhj9t/YuPmdtyFTXYiQXu3EtFpG3fiSVRWhW4veE8+0aSHrigL1TtYDNBWxxxA1qYqL4wi7ii6Ykii+oZ/eqWcSKPooMvj3LMMdCPCmdsIow/ram6svgPVZWwnusLMbi8e4JhnTAeayylvkxxhtkHiGnmQJL4TQl51nQWvXdRuQxzGZnmI0y8fYUlCmMRqbYjm9kuTHPEOUWz2vv0qPE4vkzhbQ0Zx7DtE+JdeYxTPKUfLdenEHRW3KxQyijf90bBkLkWyAiX4eIfKuWCch3poh8HTzyrQ30inz5W0fku4iThhDJLeekIfjs/gKBdHWIpOvePJUhLKqhyTpELYjVwRAr5ZsHJvOJtXOigCIdIorcM8oYbkbVttjY08KyTyykwu0HhkiX6o7hFAwWINqaIKowLIzdXCHqYMHDbdOMSGLkmwmJXPmmlpUGtis2IpG0tguoz8IXNRdJgg4WXFmXzTKekTAbXZQHzYS5q8JYQhh7unvouWeGMSBZUckxo9yd0xsmAyImax8tKNTm81XltqtMuYE9EgCcIl1Q/E/i0Bou+nnj8Yr+HBHHsUahJF79bXyOe3a2oXwysdzmGzRBhpdPoOzQF28ZdKKqHoio8fAvREX9wVSB5gQiauycom/STI67b2Zltc6PNXcYbWuxqBeK+Hrvd1eoKY/IIOOzF4cJeBUwvEp5874i2ieoM+MTqxSbSDuFUrSAUbR27pbqplES1s7nShO8L6TUNcdGT1RXc7FAFgIRV3WsoHIuS1acfcgPXdmbEtgpLIET+GSlZ3MLFRYvUmFOoQoLUCrMLpBdTp7sqs7plezib/1Cat4HrqLrIrbmdQprXjXPW8TDC/2FUssp4pO2RL7U2jZKILWcQqnl4lejTmXI3p5pOUU16rpBFGdR7FKTJFkvED7bMF81mcHbUVygO42HBVGm3/5+bHJlq1vnf151SwbnVrdk8J7KW1MM9Vzelgt4zCnisdapTKQwxS3Hxv/X4vboFGFxC30vKm5tP0Zt6xKRbOuVfJJty+OTbOssOi2wNOsS0mxIUOzmiYpdF/ekUeoV6/JtgQLYzReCu67k2AI+a79ToOhcIkX3P31Eiu7ZDPFbGpcCWUvH7gwJ35aYvb11ibiD+V1NWg8zsC9w0DsXQQfzC5xd2tsgcyLZOUzwAscEE+MLHJWVeswZdHJyiZLTdiDQqy7ROcA+fy9WQmcvl/CEtQAPl1zmDfpCdwYd1ket2lG/OY2tnSIo8U2G7Vm2knUjujd1pume3QySrdmGCPinuT53MYxP5epNAUF9zvakz6BGSFoRQdIE7I2LCAMIzEXLYeOpPyuUOZZTqnqVuHgc7hZx+P3eXp5Pbrm1xzLefeFl/BxRGS8Yz8rnaLyrjQTOCk+3SHi2ZPL5Yk+miaTJMhFJu0XZ6tnJVLaiMNYxS9d8zAsit1HzsemkfTmtRtgXvgZ/0z5FpIovhjssc9GHNwgKWeE2m24UcMIcASeYXNyrYz+FFor1vVq9uGVNDh0p51ge81mdC8HWq7KFh4JM0kUdrmBe+MHVsv5kMhXCgai+dou4ZtNKAWlwTCsfmWAQnVzSiNNjhTkngftsGsgXfveX0WcoxFcOPKKDC6Cqy0V1dxyDPfVTAQsFWCpSgHHcunumpQJUCQQrwCzKKOaNt4+TtNgyy5Ft/QUUwu6P2tIjXom73Vdy6EqbEQ9xIvGwl1GI7CsES6NfwGl/jiDsTY4whL32kUw8v+CC/T1U/94VXK/nCestqDFFBRWnZGIjNk4UsfcvEcSch4k5Gl75ghOtQaLo8Qg/3OgjKKfuFAWTh1tO3dKrYPJwcxz6qCnbBE49YobrncVnU2ZUyu9MEohtjyhedujHvL0V20LLN17Oz5nrM9gXfOyxDhw6wQKjvTnW4Z/bkMc/8rkNk5ZMsCGh/3y+KStZv1bziGT7hosFsp3tSVn8aSLGFKzTwt0jEu4vTaDXSwX1gDgQLwrq5wyf8UYtA+FxO8OErOiOv8B3XVNEivtCB7tVYs5VcYyTc9V47UFUjV/DA554jeeIV7PHvrxLJ8Tov/FtYrxQ0E7nB2dDmSCzmSxozGxK4HFjg9OZ8/aWTTzxIny3FgoST4IIo3tuZr4Cpd/wFYnP8hKEyUcSJJ9FouSTwE0+l/Qq+SSIks/jPnpPjFoTbumZMv6Wds8X5J4EUe55vJBdEQVldkUUJ9YW8qFcO1OlPAUS+KWDg7EP+9Jhw3hBAJg8ww0Aa2mX8O9Ju57O0uGaRdruv1f2JsISRBHWcoUgwhJFEfZwVBRhrctE4i5ReFbu558+yFFRfCXy4mtVjI0vGsoOva8lkrfkmL6bMYbmSNydBgB71GtmqDKJa70H76ayBH1EPNfyTNlmfQjUcY/FoTFe9CgLewm++jczCutEfn37WillvjPmBJqoJFByxmOK3TPJ/PcU8qMLuB9zwMff/0SQukwG4J82WL+nTPzPE7TkNSYlaK01aaKIF3aNFmhSYc8dFZJYWyaJWOV4nuJMgbp8NSLO3klCdvEJ2KVcxC5JXHYp75FdkkTssqFIkPOTRDl/60iDkmUEaxI3aQsX89BdgngxmUB4pM8mWU5vi/MTiyyWJMLczjwKEWwe6yNCHES6II+13cIe5TKVTB/+cT/nm9WaiaJihjcer5iZLRKMfUTg6bRZfUmjn1aoncWnFZho6Ciqy9KigDgRr8cuWg7stqZMoDP7iCC7J08szvqwx+0/jjjjnKyxqDc51Ih6A01r1Si2GYnhPlxIJ4sg/eBMTrpEb8SGWJ10Y95MFiV00ZdhyTxmtLHEyJNPyaK3fdunU9thjnSF8mfv1QL5Y1q2Qf5or3G48oe1FgXJj3RxbKGHuiaa5CSjh/j2gN3fnSMSPN/M42ulz64UkLvJHPw6nrybZsVQ8n+eGLI+3WNzS7Iot+yJCHNLX1Eg7rtD8ZSia03BuEhUJfUV6hj1SxELHVNlF+mYvtxfnxnWo47pK9Qxo82piNgpS9QTvWdyC3BpWq9QdLCZQ7jiToszAdxTMG/v5EpfEaTuny5WyCkiWz15gwgzKULMhCnMiCg9hQeS6ltFR1Wau9ktUG9iN1QwX6xjXzuMvazeghSL07y69QtN85wXZAyO+D5BhF5McQSLJJMxDUhSiZHKBkylliIC03PT0dzcWk3Yd+9gow9ZaksVwXB3eo9f1qReuDS+TiSNeePxpPF8a9FB9jcSj8en7h0zL+SYpdNj1hlknlEW6zboDM39XPoz9ebTn7WWULeJc5DFH1PYnaTLCTO0D6XSo1PYXohH/3+V9PHCEUPz0Y2ws0LM0GnG2ihqzdOJTG2O4Ux0fRqXN9NEMbfzHgFB8Xui370sFRJU2r+R6jRDCieu9QvVU7ooTTTmcj7K0XtZJbkRovyY3vuPcuaKRFQ6Nz9e0av8yG6c5tZLBH7m95Twiy2+l01r7l0awv1RGhLOvDrdKg2Rvu6e+sYbXmOzEOmn9CSfKJl/Z+qnViCpXV+g97T+TA59u5XmDYcj3kDUW+py5CRF/Hd6Iz7YICkaKF3ujwCbJxoqLwU2t78iDIIp4Yg/Ggss8YN4ybN4yU0+YBsEbMll5dFAEbrwLI4EfGDNP8eklEdKF6EL15Ax/kljRhf7i30Trrl60qRxExNifm/Z1XAKT9Bb5nelfba3/dS29Z+t3ukuh31rnwollPqX+0tBMCMWinlLZ4SnhKIxsObU7eSa/Jkt8Mi521IC0Tml3hX+iCPZG4nM8EdC5Mt4dwlaA7SEpyQGf5IfGJcSDkUD+G+C2WaA9Ez/8hDc2yIyjS2jOLCkJLaoOBQp8gN566yEMm/FjDCo3pSSUlQeicxFsznT/L8qD4RvChaHkG28kbJAcAn8yYH2kRyI+csWwZk2d/zphSH4Av4vXOqN+dHd2pbkNHIzUOZ3/vzYb+blZdtsmcu9i5SmFTE4yDA45lx/IIiXcTNZ2RDjPWwFmyQ5xsDWxWDz2q6MElC7ZepSOOTgZYMrbbZS+CDock+aNCmMG44lDTueeQ823JGFGjYN2WFTGgIbaXUNadXyaj5stT8dtcruOKC1kgvCoPLb96IIKdFlgdLSyaHQMpjpU2IRvzdaHvHDVj5lotMFJWDL6xIa4jcvX6asaKDaUNlUhno9DQLKdrF2hX0CbJeoN6ai5qEwfnukjXFTEDrcg0glQubcvHMJnPPYUjRnwX0F2WTOu4Ek24BPtoN0GeARZBfuJSX4IICjaM1w82nY87dBfMOHaUtCvtv93nAoCC+SwqGiZf4Y/CkBQq4UTZlcVOKNBELoHv7rZbchY6C8VntkZRr6Q234BlJ9GeQP2anXFyX7UMwEV8AZ4cRzcRE8D7w+IBdIM0BwAXAvBPK+xHxQJfsLgLMQtlmsG7Xx70egXzbmow1mppzKVt0cg245feJTzRAdlV2w3YMXo3b3XnttJe3l5Uqjzz+Ajbb/DHvo3CsMFCrURu8jJCRaN5LuggZYaXR6g+70M3bNATboABt0gI12ACQUSY5T7C/Hw3tyIvqnD/qnL/onFbWT07FlNwfl/mD1cPkisHqQPEC334Hr5wG5zZkL7NiAEjTgfePzgfywowDYGQO2bjwBt9MyEC0w9/bHsjVgLwqD2ne+fMlgwYNGC+oNC8NAfuzTHzQrbn1jI2y404ka1v7xz5qp5XzYsG3jcmhJuFTWTs+c1OzUNPRcZU92Unp9+D6CN57qN7s+sZl6IVvp5kSMNIH0bPjgryWgZttdqGfKiy3KfMnFUSUME4qjOAAlCw/oq961e1MJeHLDZWiUE/ccVGxysRIK0wgzwShWbqgxa9M2sGt3CxzgPg8Z4JCyDHkoXH0Wnlxdfs3Xdgk6u+YO6OzqLKOzu6IwWDJygWMGSFkAbAvBO7fmg69GmD3dUfk89MumccSB19mMfqk+VrtHt+rnnyDqvIEg/FiXZax0tv8K0eYw1OiBtX/M5sTKm4ZYmVXZU6zsM8TKyK4fKVb6g7ql0Gp1hQarnTw/GFrtJ7kAzAAuHCEvxueDUxVWVjtstBqzBS02Dhli4zobh10+Ruxyo7VZVYsdmqxZrDn1YI/sMl+32EtNmsXiocWevLRHk+kDNXzwBQyHjl+ScNikeFOGxax8qWGfDR/8DTbrzCbNWm1ss+Vqs8/RaHmk2cYutlmF2uwvaLTJyqSmZo5xaruvYbtHlXat5nbj1XbfomkLSbs20+rkQWq7b1C7fNJus2mzjolqu89QuwWk3QbTvBBvugU37sspAdu3TECNxw59RaWCCNQnObpmuT6NiKvZ5WXAOVB7iMXLd1WjM7U7iHzkz0e7F8eKUPItCgWLA5Eyvw/7Tv4iQ0qLhaaQm/jW8WxMFmbs1xdD7NfnG7AP63uI/WG5wDkDSJgx5JOXw/T68o1m9K/99B4N/VmnPukypNeql6f3gwJsTijmDxYhmeMcM8mZPcaG/+McO9qZfR352efMXkR+ki6BHXICFX6f3ku+3pk9ljyWbzT2KVD66EH2RKtGS02py6xpqePQNERLQ0n8fFJpGWQtr/7SWszBVFb5XeMgi0B77l8w0I5OwsP2HUCncW2FLf94WlNbc4vGZhvDcd8ILLdQHCoxSecmAX2tWQhduGYOdiHU1pE5UHnhKiUh7EcKvuqtK2aAJSnwYlEM6moo7tLhwwwsR+d5S/1BJMrI5exQpMxbSo5jnKgMWAn5Lyka88bKowQg8s2gHlYBLnm2dr2mP3O9gr6ut5NrScrEk8yJhHzlRcoa4XM4HLRRBkG+kl/l8WhzaDdTvBFSb7uL4IIkN9oRTKlwy53HR+ARoI6RF6Asie+NkfphXYrDBNR+mpRZGkB/JjknEvAHlb+Xi/PiFIjya3OBW+oHBWeEeXzyk7fngep3EnPR6pJgFCTFVEt5UHNkn3HXgPnOceNADpS5RRFvcYxsB6rSRCR8YZmGao3JrszPdjSdannw0/1t8L85oPr4iBlg2kxQ/8xlN4P7226Z7ZhDCq+5uMiEq0rDs05bAACMvQMT8kH1Y3NNsbdu1bfHUOzNhGjqPtEvS8O7HAep4ZGuofK1SvgM1WIm9lstkH5KbjpgTF7KRFL9mW2JKF2NQSO/8dFwXaF5IP5f6DimRtOa+/7ahKScGzU80j5Z13yuMPj+jVQ1oJrfOItS28N21O7DVQO7qAG/2VFuCqjVb/+hDobKa3ejHq+kztGUWzIMFfnocBgrkpXiW1fz6OMoxPzYKC516XeDONjvgb50xtsywiT/yOwN3e9vRsx+Oxrl978t0Zk9HjL7UwVWok+VEgOQlOir0yn6RWIiwCTsUid06Stp0KWPm6uVhrZnzyCXoiTR/ebaYTajPeXNb57FLoV+bK7U/OhVfgw6syPKj9DlRYW0S5vfOH4HHLmdeKBqbTblgb+2bNLAkk3AUOHMLi7UJrlFQ9AqDSsEAo1ndk7UIHDs+MRK45L/gV4OEAjUP3fvYASBX6B2rzefoCAg73nxKnVrrTXq/L/6rbazPGVnw+GPXeoCGMiseaEtD4kdvMVXn71aY9c+CDK7l9OQQb4npmk8e+B3CDIleAd/brRR/fYm9hIzjUd/GKuqhu7unb+utJZI65rWvasqqe4TeQkc7bOu/elpqFkBbnaon5W26KWWRceGEIDpuNpTAPimOx/UrP+JCYBNR8+7EQCRgOt+98kgBRN531ejCEygR4IfqYhYPUKDSY5NA+AM4jFJzlY7tPfQgSGhxr81dyASGoHdsjZmM9Jb5fPPxakIbHqzthAhsC9e86sF+prjw+Dc769WTdr01AvoIGd/BW436iOKLyv/8oCZhOof/sGGEGXDmL1xu4aMVIiMqj9X8BC15v2vh2gkdNR3iYbENNivut3eW0Q9/9ochIH5GFFl6ToGAMRAY5ZmqYfPTtUg9fa7JdnWkGrc9FCVKs67377mjE1r1gc2k9FveSkh/cFfvlV1d/exgf1NSJaHKxj9+wTUbgrG6OFxpnbcswmnBB07HNR2piLAjkSANZSs6LQanU+U4poVIta1EFTVeyFiXx1qRuzaPxzSEPunlCgFE7nl/Fcqr6zXKXO6jro7sjWOqSg0IJbuYIDpHTZTB80PH1Yn6Igd+AYFsHNfZmn27frqTQ2w3bdfRrd7aaDqMJhd2zXAHmmfYqM4+6Mji9WtTbWp7GizactTfzQT5eovOrei3DoY59YtL2uwTkew3l8A4elU97T67W5Ucx+zkzx8Od22FcC2QIMv2d1L318HUfG1hHdXt0pBRT98cEjEHa5EdJzXt67L1PD72nNVOjDjII52pWuy5OCuY6jdQhyOLUP0dg7Yrq5QtW/D2ccRE3dOQ+3e2jCWT7HzYLPtWYRi+3dRSf7TsI7zpjY/Gu/nhLJvtPUS5+rBDKblmiUQ5TWLDbpga90yUmYBTepVLoBl1s75JqnX0NztRSAfj3XBrX/UEHM3BMK5t+/RkstTtZdoCPx46RdUkq3s+nirZqLm7gUIgi5lQI0zV4bBe51pGgL/vgGVVPvLMJGdKtEQWB4GX757vQlZTc3v/gkh679wMA6YqaHFCdGyerSZ95TA6fpCVo/purtz/6V14x/TKXY5feobTae99dNJJuaLqIAYoRbqEBBjep9MjZUV4abTbUeh18bg4lj1Wjz0WnuKyWvND7X8UqOmD4pHU96QD35kN6S6BstUFwyDg9XxqtPWtX+/VOONE4fLK41S69z+y7VEd6J+PPJaELV7b/Z6nTdgkVv5Svcsk9/WHnr5IfWcqPv46Ue0hOWGDtgwgue3+gPnpyK/ARyQi/+ldUMi/YeJZscJathGF7R0w0psaXkhqDvpk/PJr8OghHB4PDT6z3K12Hmqexg5npOUuunzpzPhjSG55GUsvLGn6jN44yqYQiS5AE1UEm+sNYsDkWjs5/g9A+zyv9H6p6s="
    local amf3_obj = Base64.decodeWithZip(x)
    local lua_obj = amf3.decode(amf3_obj)
    printTable("lua_obj",lua_obj)

    skipFightButton = nil
    visibleList = {}
    if(str==nil) then
        require "script/ui/tip/AlertTip"
        AlertTip.showAlert( GetLocalizeStringBy("key_2070"), nil, false, nil)
        closeLayer()
        return
    end
    if(isShowSkipButton==nil)then
        isShowSkipButton = true
    end
    m_isShowSkipButton = isShowSkipButton

    if(isShowStrengthNumber==nil)then
        isShowStrengthNumber = false
    end
    m_isShowStrengthNumber = isShowStrengthNumber

    require "script/ui/login/LoginScene"
    LoginScene.setBattleStatus(true)
    m_isInFighting = true
    --增加ARMYID
    m_currentArmyId = armyIds

    m_heroDropArray = {}

    --增加背景音乐
    bgmName = bgmName==nil and defaultBgm or bgmName
    AudioUtil.playBgm("audio/bgm/" .. bgmName)

    --初始化基础信息
    m_maxHpTable          = {}
    m_currentHpTable      = {}
    m_currentAngerTable   = {}
    m_soulNumber          = 0
    m_itemArray           = {}
    m_heroArray           = {}
    m_resourceNumber      = 0
    m_silverNumber        = 0
    m_expNumber           = 0
    m_deadPlayerCardArray = {}
    m_revivedTime         = 0
    m_isFirstTime         = false
    m_copyType            = kNormalCopy
    m_isShowBattle        = true
    m_callbackFunc        = callbackFunc
    m_afterBattleView     = afterBattleView
    if(m_afterBattleView  ~=nil)then
        m_afterBattleView:retain()
    end
    m_copyType = p_battleType or kNormalCopy
    CCNotificationCenter:sharedNotificationCenter():postNotification("NC_BeginFight")
    m_battleIndex = 1

    battleBaseLayer = CCLayer:create()
    battleBaseLayer:setTouchEnabled(true)
    battleBaseLayer:registerScriptTouchHandler(layerTouch,false,-498,true)

    initUperLayer()
    battleBaseLayer:addChild(battleUperLayer,200)

    bgName = bgName==nil and "chengqiang.jpg" or bgName

    initBackground(bgName)
    initPlayerCardHidMap()
    ----print("m_bg",m_bg)
    battleBaseLayer:addChild(m_bg)

    m_onBattleView = onBattleView
    --print("onBattleView:",onBattleView)
    if(m_onBattleView~=nil)then
        battleBaseLayer:addChild(m_onBattleView,9)
    end

    m_enemyCardLayer = CCLayer:create()
    --m_enemyCardLayer = CCLayerColor:create(ccc4(255,0,0,111))
    m_enemyCardLayer:setPosition(ccp(0, 0))
    m_bg:addChild(m_enemyCardLayer,0,1188)

    m_currentArmyIndex = 0
    local scene = CCDirector:sharedDirector():getRunningScene()
    ---[[
    m_visibleViews = CCArray:create()
    m_visibleViews:retain()
    local sceneChildArray = scene:getChildren()
    for idx=1,sceneChildArray:count() do
        ----print("childNode:",idx,sceneChildArray:count() )
        local childNode = tolua.cast(sceneChildArray:objectAtIndex(idx-1),"CCNode")
        if(childNode~=nil and childNode:isVisible()==true and childNode:getTag()~=90901 and childNode:getTag()~=kFogEffectTag)then
            childNode:setVisible(false)
            m_visibleViews:addObject(childNode)
        end
    end
    --]]
    scene:addChild(battleBaseLayer,1000,67890)
    local blackLayer = CCLayerColor:create(ccc4(1,1,1,255))
    battleBaseLayer:addChild(blackLayer,9999)

    local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    blackLayer:runAction(actions)


    ----print("--------------------------")


    --把最大血量传给摇钱树
    if m_copyType == kMoneyTree then
        require "script/battle/PlayerMoneyTreeLayer"
        PlayerMoneyTreeLayer.setBoosLife(tonumber(m_battleInfo.team2.arrHero[1].maxHp))
    end

    initPlayerCardHidMap()
    --存储COPY信息
    m_newcopyorbase = {}
    m_extra_reward = {}
    m_extra_info = {}
    --存储战斗结果
    m_appraisal = lua_obj.appraisal
    --储存HP信息
    m_currentHp = 1000
    --储存奖励信息
    m_reward = {}
    m_isScore = false


    --print("-----------------------------------------------------------")
    --更新敌人层
    clearEnemyLayer()

    local team2arr = m_battleInfo.team2.arrHero

    local cardWidth = m_bg:getContentSize().width*0.2;

    for i=1,#team2arr do
        local teamInfo = team2arr[i]
        local position = teamInfo.position
        local card = createBattleCard(teamInfo.hid)
        card:setTag(3000+position)
        card:setAnchorPoint(ccp(0.5,0.5))
        card:setPosition(getEnemyCardPointByPosition(position))
        card:setBasePoint(ccp(card:getPositionX(),card:getPositionY()));

        m_enemyCardLayer:addChild(card,5-i)

        local currentHp = 0
        if(teamInfo.currHp==nil) then
            currentHp = teamInfo.maxHp
        else
            currentHp = teamInfo.currHp
        end
        m_maxHpTable[teamInfo.hid] = teamInfo.maxHp
        m_currentHpTable[teamInfo.hid] = currentHp
        m_currentAngerTable[teamInfo.hid] = teamInfo.currRage==nil and 0 or tonumber(teamInfo.currRage)
        --更新怒气
        if(m_currentAngerTable[teamInfo.hid] == nil) then
            m_currentAngerTable[teamInfo.hid] = 0
        end
        BattleCardUtil.setCardAnger(card, m_currentAngerTable[teamInfo.hid], teamInfo.hid)
        if m_currentHpTable[teamInfo.hid] and m_maxHpTable[teamInfo.hid] then
            BattleCardUtil.setCardHp(card,m_currentHpTable[teamInfo.hid]/m_maxHpTable[teamInfo.hid])
        end
    end
    local tempY = -m_bg:getPositionY()/m_bg:getScale()
    m_enemyCardLayer:setPosition(ccp(0, tempY))

    m_formation = {}
    local team1arr = m_battleInfo.team1.arrHero

    m_deadPlayerCardArray = {}
    for i=1,#team1arr do
        local teamInfo = team1arr[i]
        if(teamInfo.position ~= nil) then
            m_formation["" .. teamInfo.position] = teamInfo.hid

            ----print("1 teamInfo.hid,teamInfo.maxHp,teamInfo.currHp",teamInfo.hid,teamInfo.maxHp,teamInfo.currHp)
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
                m_currentAngerTable[teamInfo.hid] = teamInfo.currRage==nil and 0 or tonumber(teamInfo.currRage)
                --更新怒气
                if(m_currentAngerTable[teamInfo.hid] == nil) then
                    m_currentAngerTable[teamInfo.hid] = 0
                end

            end
        end
    end
    m_playerCardLayer = PlayerCardLayer.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_playerCardLayer:setPosition(ccp(0, -m_bg:getPositionY()/m_bg:getScale()))
    m_playerCardLayer:setAnchorPoint(ccp(0, 0))

    for k,v in pairs(team1arr) do
        if(v.position ~= nil) then
            m_formation["" .. v.position] = v.hid
            local card = m_playerCardLayer:getChildByTag(1000+tonumber(v.position))
            print("create card", card)
            if(card~=nil)then
                print("setCardAnger player:",m_currentAngerTable[v.hid])
                card = tolua.cast(card,"CCXMLSprite")
                BattleCardUtil.setCardAnger(card, m_currentAngerTable[v.hid], v.hid)
                if m_currentHpTable[v.hid] and m_maxHpTable[v.hid] then
                    BattleCardUtil.setCardHp(card,m_currentHpTable[v.hid]/m_maxHpTable[v.hid])
                end
                BattleCardUtil.setCardAnger(card, m_currentAngerTable[v.hid], v.hid)
            end
        end
    end

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
        local node = m_playerCardLayer:getChildByTag(1000+pos)
        if(node ~= nil) then
            local deadActionArray = CCArray:create()
            deadActionArray:addObject(CCFadeIn:create(0.5))
            deadActionArray:addObject(CCFadeOut:create(0.5))
            node:runAction(CCRepeatForever:create(CCSequence:create(deadActionArray)))
        end
    end

    --]]
    --增加战斗力显示
    if(m_isShowStrengthNumber==true)then
        showStrength()
    end
    m_bg:addChild(m_playerCardLayer,0,1177)
    --更新玩家层结束
    m_battleIndex = 1
    PlayerCardLayer.setSwitchable(false)
    doBattleButton:setVisible(false)
    BattleCardUtil.setNameVisible(true)
    local battleStart = function ( ... )
        showPetAtBattle(function ( ... )
            currentRoundOver()
            local delayActionArray = CCArray:create()
            delayActionArray:addObject(CCDelayTime:create(2))
            delayActionArray:addObject(CCCallFunc:create(showNextMove))
            m_bg:runAction(CCSequence:create(delayActionArray))
            isBattleOnGoing = true
        end)
        --显示阵法
        addCraftInBattle()
    end
     --播放开场特效
    showStartEffect(battleStart)

    -- preloadBattleData() 
end

function enterBattle (copy_id,base_id,level,callbackFunc,copyType, p_isHiddenSkip)

    skipFightButton = nil
    m_onBattleView = nil
    m_isShowStrengthNumber = false
    visibleList = {}
    m_isShowBattle = p_isShowSkip or false

    init()

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

    if(m_copyType~=1 and m_copyType~= 6)then -- copyType = 6 副本类型是武将列传类型
        m_level = 1
    end

    --判断当前是否为第一次进入
    require "script/model/DataCache"
    local normalCopyList = DataCache.getNormalCopyData()
    local currentStar = 0
    for cNum=1,#normalCopyList do
        local copy_info = normalCopyList[cNum].va_copy_info
        if(copy_info~=nil and copy_info.progress~=nil and copy_info.progress["" .. m_base_id]~=nil)then
            currentStar = tonumber(copy_info.progress["" .. m_base_id])==nil and 0 or tonumber(copy_info.progress["" .. m_base_id])-2
            break
        end
    end
    --print("currentStar:",currentStar,m_level)
    if((currentStar>=m_level and m_level>0))then
        --print("m_isFirstTime: f")
        m_isFirstTime = false
    else
        --print("m_isFirstTime: t")
        m_isFirstTime = true
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
    args:addObject(CCInteger:create(copy_id))

    args:addObject(CCInteger:create(base_id))
    args:addObject(CCInteger:create(level))

    RequestCenter.getFormationInfo( BattleLayer.getFormationCallBack )


    CCNotificationCenter:sharedNotificationCenter():postNotification("NC_BeginFight")
    isBattleOnGoing = true
end

function enterBaseLvCallback(cbFlag, dictData, bRet)
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

    m_battleIndex = 1


    initPlayerCardHidMap()
    battleBaseLayer = CCLayer:create()
    battleBaseLayer:setTouchEnabled(true)
    battleBaseLayer:registerScriptTouchHandler(layerTouch,false,-498,true)

    local isAutoStart = false

    initUperLayer()
    battleBaseLayer:addChild(battleUperLayer,200)

    require "db/DB_Stronghold"
    local sh = DB_Stronghold.getDataById(base_id)
    if(level==0)then
        initBackground(sh.fire_scene,1)
    else
        initBackground(sh.fire_scene,tonumber(sh.startposition))
    end
    battleBaseLayer:addChild(m_bg)

    m_enemyCardLayer = CCLayer:create()
    m_enemyCardLayer:setPosition(ccp(0, 0))
    m_bg:addChild(m_enemyCardLayer,0,1188)

    m_currentArmyIndex = 0

    -- 发送进入副本请求
    ---[[
    local args = CCArray:create()
    args:addObject(CCInteger:create(copy_id))

    args:addObject(CCInteger:create(base_id))
    args:addObject(CCInteger:create(level))

    ----print("======copy_id,base_id,level=======",copy_id,base_id,level)

    if(m_copyType==1)then
        RequestCenter.ncopy_enterBaseLevel(BattleLayer.enterBaseLvCallback, args)
    elseif(m_copyType==2)then
        RequestCenter.ecopy_enterCopy(BattleLayer.enterBaseLvCallback, Network.argsHandler(m_copy_id))
    elseif(m_copyType==4)then
        RequestCenter.tower_enterLevel(BattleLayer.enterBaseLvCallback, Network.argsHandler(m_copy_id))
    elseif(m_copyType==5)then
        RequestCenter.tower_enterSpecailLevel(BattleLayer.enterBaseLvCallback, Network.argsHandler(m_copy_id))
    elseif(m_copyType==6)then
        RequestCenter.Hcopy_enterBaseLevel(BattleLayer.enterBaseLvCallback, args)
    else
        RequestCenter.acopy_enterBaseLevel(BattleLayer.enterBaseLvCallback, Network.argsHandler(m_copy_id,m_base_id))
    end
    --RequestCenter.enderBaseLv(BattleLayer.enterBaseLvCallback, args)
    --]]
    -- 发送进入副本请求结束
    local scene = CCDirector:sharedDirector():getRunningScene()
    ---[[
    m_visibleViews = CCArray:create()
    m_visibleViews:retain()
    local sceneChildArray = scene:getChildren()
    for idx=1,sceneChildArray:count() do
        ----print("childNode:",idx,sceneChildArray:count() )
        local childNode = tolua.cast(sceneChildArray:objectAtIndex(idx-1),"CCNode")

        if(childNode~=nil and childNode:isVisible()==true and childNode:getTag() ~= kFogEffectTag)then
            childNode:setVisible(false)
            m_visibleViews:addObject(childNode)
        end
    end
    --]]
    scene:addChild(battleBaseLayer,1000,67890)
    local blackLayer = CCLayerColor:create(ccc4(1,1,1,255))
    battleBaseLayer:addChild(blackLayer,9999)

    local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    blackLayer:runAction(actions)

    initPlayerCardHidMap()

    m_playerCardLayer = PlayerCardLayer.getPlayerCardLayer(CCSizeMake(640,600),m_formation)
    m_playerCardLayer:setPosition(ccp(0,  -m_bg:getPositionY()/m_bg:getScale()))
    m_playerCardLayer:setAnchorPoint(ccp(0, 0))

    m_bg:addChild(m_playerCardLayer,0,1177)
    PlayerCardLayer.setSwitchable(false)

    local craftInfo = {
        id = WarcraftData.getUsed() or 0,
        level = WarcraftData.getUsedWarcraftLevel() or 0,
    }
    print( "id",WarcraftData.getUsed(), "level",WarcraftData.getUsedWarcraftLevel())
    printTable("craftInfo", craftInfo)
    if craftInfo then
        addCraftInBattle(craftInfo)
    end
    local battleStart = function ( ... )
        showNextArmy()
        if(isAutoStart) then
            local actionArr = CCArray:create()
            actionArr:addObject(CCDelayTime:create(1))
            actionArr:addObject(CCCallFunc:create(move1))
            local actions = CCSequence:create(actionArr)
            battleBaseLayer:runAction(actions)
        end
    end
    --播放开场特效
    showStartEffect(battleStart)
end

function addCraftInBattle( p_carftInfo )
    -- if not DataCache.getSwitchNodeState(ksSwitchWarcraft,false) then
    --     return
    -- end
    require "db/DB_Method"
    local craftInfo = p_carftInfo
    if p_carftInfo then
        craftInfo = p_carftInfo
    else
        craftInfo = m_battleInfo.team1.craft or {level = 0,id = 0}
    end
    print("addCraftInBattle team1CraftId", team1CraftId)
    if tonumber(craftInfo.id )~= 0 then
        local needOpenLevel = tonumber(DB_Method.getDataById(craftInfo.id).needmethodlv)
        if tonumber(craftInfo.level) >= needOpenLevel then
            require "db/DB_Method"
            local effectName = DB_Method.getDataById(craftInfo.id).effect
            local effectPath = "images/warcraft/effect/" .. effectName .. "/" ..effectName
            local carftEffect = CCLayerSprite:layerSpriteWithName(CCString:create(effectPath), -1,CCString:create(""));
            local position = m_playerCardLayer:convertToNodeSpace(ccps(0.5, 0.21))
            carftEffect:setPosition(position)
            m_playerCardLayer:addChild(carftEffect, -1000)
            carftEffect:setCascadeColorEnabled(true)
            carftEffect:setColor(ccc3(200, 200, 200))
            print("addCraftInBattle 1")
        end
    end
    if m_battleInfo ~= nil then
        local team2Craft = m_battleInfo.team2.craft or {level = 0,id = 0}
        if tonumber(team2Craft.id) ~= 0 then
            local needOpenLevel = tonumber(DB_Method.getDataById(team2Craft.id).needmethodlv)
            if tonumber(team2Craft.level) >= needOpenLevel then
                require "db/DB_Method"
                local effectName = DB_Method.getDataById(team2Craft.id).effect
                local effectPath = "images/warcraft/effect/" .. effectName .. "/" ..effectName
                local carftEffect = CCLayerSprite:layerSpriteWithName(CCString:create(effectPath), -1,CCString:create(""));
                local position = m_enemyCardLayer:convertToNodeSpace(ccps(0.5, 0.79))
                carftEffect:setPosition(position)
                carftEffect:setCascadeColorEnabled(true)
                carftEffect:setColor(ccc3(200, 200, 200))
                m_enemyCardLayer:addChild(carftEffect, -1000)
                carftEffect:setScaleY(-1)
                print("addCraftInBattle 2")
            end
        end
    end
end

--[[
    @des:播放清除buffer特效
--]]
function playClearBufferEffect( pCard, pIsPlay )
    if  pIsPlay == nil or pIsPlay == "false" or pIsPlay == false then
        return
    end
    if tolua.isnull(pCard) then
        return
    end
    local effect = XMLSprite:create("images/battle/effect/jiebuff")
    effect:setReplayTimes(1, true)
    effect:setPosition(ccpsprite(0.5, 0.5, pCard))
    pCard:addChild(effect)
end

--[[
    @des: 得到当然数据块中攻击者的时装id
--]]
function getAttackDressId( ... )
    local attackerId = tonumber(m_currentBattleBlock.attacker)
    local dressId = nil

    for k,v in pairs(m_battleInfo.team1.arrHero) do
        if v.dress~=nil and v.dress[tostring(1)] ~= nil and tonumber(v.dress[tostring(1)])~=0 and tonumber(v.hid) == attackerId then
            return v.dress[tostring(1)]
        end
    end

    for k,v in pairs(m_battleInfo.team2.arrHero) do
        if v.dress~=nil and v.dress[tostring(1)] ~= nil and tonumber(v.dress[tostring(1)])~=0 and tonumber(v.hid) == attackerId then
            return v.dress[tostring(1)]
        end
    end
    return nil
end

--[[
    @des: 得到当前数据块中攻击者的htid
--]]
function getAttackTid( ... )
    local attackerId = tonumber(m_currentBattleBlock.attacker)

    for k,v in pairs(m_battleInfo.team1.arrHero) do
        if tonumber(v.hid) == attackerId then
            return v.htid
        end
    end

    for k,v in pairs(m_battleInfo.team2.arrHero) do
        if tonumber(v.hid) == attackerId then
            return v.htid
        end
    end
end


--[[
    @des: 播放战斗开场特效
--]]
function showStartEffect( p_callBack )
    -- p_callBack()
    local runningScene = CCDirector:sharedDirector():getRunningScene()

    local openEffect= CCLayerSprite:layerSpriteWithName(CCString:create("images/battle/effect/chuchangyun"), -1,CCString:create(""))
    openEffect:setPosition(g_winSize.width/2,g_winSize.height*0.5)
    openEffect:setScale(g_fBgScaleRatio)
    openEffect:setFPS_interval(1/60)
    runningScene:addChild(openEffect, 5000, kFogEffectTag)
    -- openEffect:retain()
    -- local delegate = BTAnimationEventDelegate:create()
    -- delegate:registerLayerEndedHandler(function ( ... )
    --     openEffect:removeFromParentAndCleanup(true)
    --     openEffect = nil
    --     if p_callBack then
    --         p_callBack()
    --     end
    -- end)
    -- delegate:registerLayerChangedHandler(function ( ... )

    -- end)
    -- openEffect:setDelegate(delegate)
    local callback = p_callBack
    function animationEnd( ... )
        openEffect:removeFromParentAndCleanup(true)
        openEffect = nil
        m_startEffectIsOver = true
        if callback then
            callback()
        end
    end

    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(animationEnd)
    delegate:registerLayerChangedHandler(function ( ... )

    end)
    openEffect:setDelegate(delegate)
end

--[[
    @des: 处理战斗数据，把arrChild 打到队列中
--]]
function preloadBattleData()
    local newBattleInfo = m_battleInfo.battle
    for k,v in pairs(newBattleInfo) do
        if v.arrChild ~= nil then
            for key,childData in pairs(v.arrChild) do
                table.insert(newBattleInfo, k + key, childData)
            end
            newBattleInfo[k].arrChild = nil
        end
    end
    printTable("newBattleInfo", newBattleInfo)
end



-- 退出场景，释放不必要资源
function release (...)
-- do something?
end
