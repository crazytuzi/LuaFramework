-- FileName: FightScene.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗主场景

module("FightScene", package.seeall)
require "script/fight/FightHead"

local _bgLayer         = nil
local _bgSprite        = nil
local _playerCardLayer = nil
local _enemyCardLayer  = nil
local _fightLayer      = nil
local _reportLayer     = nil
local _touchPriority   = nil
local _endCallback     = nil
local _bgName          = nil
local _armyId          = nil
local _onBattleView    = nil
local _autoVisible     = nil
local _skipVisible     = nil
local _musicName       = nil
local _forceVisible    = nil
local _isNameVisible   = nil
local _effectLayer     = nil
local _backSpeed       = nil
function init( ... )
    _isNameVisible   = true
end

function release(...)
    _bgLayer         = nil
    _bgSprite        = nil
    _playerCardLayer = nil
    _enemyCardLayer  = nil
    _touchPriority   = nil
    _fightLayer      = nil
    _endCallback     = nil
    _bgName          = nil
    _armyId          = nil
    _onBattleView    = nil
    _autoVisible     = nil
    _skipVisible     = nil
    _musicName       = nil
    _forceVisible    = nil
    _backSpeed       = nil
end

--[[
    @des:设置是否显示战斗力
--]]
function setForceVisible( pForceVisible )
    _forceVisible = pForceVisible
end

--[[
    @des:得到战斗力是否显示
--]]
function getForceVisible()
    if _forceVisible == nil then
        _forceVisible = false
    end
    return _forceVisible
end

--[[
    @des:设置背景图片名称
--]]
function setBgName( pImageName )
    _bgName = pImageName
end

--[[
    @des:得到背景名称
--]]
function getBgName()
    return _bgName or "shilianta.jpg"
end

--[[
    @des:设置背景图片名称
--]]
function setMusicName( pMusicName )
    _musicName = pMusicName
end

--[[
    @des:得到背景名称
--]]
function getMusicName()
    return _musicName or "music01.mp3"
end

--[[
    @des:设置onBattleView
--]]
function setOnBattleView( pOnBattleView )
    _onBattleView = pOnBattleView
end

--[[
   @des:updateOnBattleView 
--]]
function updateOnBattleView( pBlockInfo )
    if _onBattleView then
        _onBattleView.battleBlockChanged(pBlockInfo)
    end
end


--[[
    @des:设置当前的部队id
--]]
function setArmyId( pArmyId )
    _armyId = pArmyId
end

--[[
    @des:得到当前的部队id
--]]
function getArmyId()
    return _armyId
end

--[[
    @des:设置是否显示战斗力
--]]
function setFightForceVisible( pVisible )
   _showFightForce = pVisible
end

--[[
    @des:设置touch优先级
--]]
function setTouchPriority( pTouchPriority )
    _touchPriority = pTouchPriority
end

--[[
    @des:设置是否显示自动按钮
--]]
function setAutoVisible( pVisible )
    _autoVisible = pVisible
end

--[[
    @des:得到自动按钮显示状态
--]]
function getAutoVisible()
    if _autoVisible == nil then
        return false
    else
        return _autoVisible
    end
end

--[[
    @des:设置是否显示跳过按钮
--]]
function setSkipVisible( pVisible )
    _skipVisible = pVisible
end

--[[
    @des:得到跳过按钮显示状态
--]]
function getSkipVisible()
    if _skipVisible == nil then
        return false
    else
        return _skipVisible
    end
end


--[[
    @des:得到地方卡牌层对象
--]]
function getEnemyCardLayer()
    return _enemyCardLayer
end

--[[
    @des:得到战斗场景lahyer
--]]
function getFightLayer()
    return _fightLayer
end

--[[
    @des:得到特效层
--]]
function getEffectLayer( ... )
    return _effectLayer
end

--[[
    @des:得到战斗结算面板
--]]
function getReportLayer()
    return _reportLayer
end

--[[
    @des:设置战斗背景
--]]
function setFightBg( pBgSprite )
    if _bgSprite then
        _bgSprite:removeFromParentAndCleanup(true)
        _bgSprite = pBgSprite

    end
end

--[[
    @des:得到战斗背景
--]]
function getFightBg( ... )
    return _bgSprite
end

--[[
    @des:设置战斗结束回调
--]]
function setEndCallback( pCallback )
    _endCallback = pCallback
end

--[[
    @des:得到战斗结束会滴
--]]
function getEndCallback()
    return _endCallback
end

--[[
    @des:设置是否显示玩家姓名
--]]
function setNameVisible( pVisible )
    if not tolua.isnull(_playerCardLayer) then
        _playerCardLayer:setNameVisible(pVisible)
    end
    if not tolua.isnull(_enemyCardLayer) then
        _enemyCardLayer:setNameVisible(pVisible)
    end
end

--[[
    @des:得到现在武将名称显示状态
--]]
function getIsNameVisible()
    return _isNameVisible
end


--[[
    @des:设置玩家卡牌层
--]]
function setPlayerCardLayer( pPlayerLayer )
    if _playerCardLayer then
        _playerCardLayer:removeFromParentAndCleanup(true)
        _playerCardLayer = nil
    end
    _playerCardLayer = pPlayerLayer
    _bgLayer:addChild(_playerCardLayer, ZOrderType.P_CARD)
    _playerCardLayer:setNameVisible(_isNameVisible)
end

--[[
    @des:得到玩家卡牌层对象
--]]
function getPlayerCardLayer()
    return _playerCardLayer
end

--[[
    @des:setEnemyLayer
--]]
function setEnemyCardLayer( pEnemyLayer )
    if _enemyCardLayer then
        _enemyCardLayer:removeFromParentAndCleanup(true)
        _enemyCardLayer = nil
    end
    _enemyCardLayer = pEnemyLayer
    _bgLayer:addChild(_enemyCardLayer, ZOrderType.E_CARD)
    _enemyCardLayer:setNameVisible(_isNameVisible)
end

--[[
    @des:设置战斗结算面板
--]]
function setReportLayer( pReportLayer )
    print("setReportLayer", pReportLayer)
    if pReportLayer then
        _reportLayer = pReportLayer
        _reportLayer:retain()
    end
end

--[[
    @des:显示战斗结算面板
--]]
function showAfterBattleLayer()

    _backSpeed = CCDirector:sharedDirector():getScheduler():getTimeScale()
    CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    print("_reportLayer", _reportLayer)
    print("_reportLayer", tolua.type(_reportLayer))
    if not tolua.isnull(_reportLayer) then
       _bgLayer:addChild(_reportLayer, 3000)
    else
        closeScene()
    end
end

--[[
    @des:得到卡牌对象
    @parm: hid 武将id
--]]
function getCardByHid(hid)
    local attackCard = _enemyCardLayer:getCardByHid(hid)
    if not attackCard then
        attackCard = _playerCardLayer:getCardByHid(hid)
    end
    if attackCard == nil then
        printTable("_playerCardLayer",_playerCardLayer._cardMap)
        printTable("_enemyCardLayer",_enemyCardLayer._cardMap)
        print("error not find hid:",hid)
    end
    return attackCard
end

--[[
    @des:得到卡牌格子对象
    @parm: hid 武将id
--]]
function getGridByPos(pPosNum)
    local attackCard = _enemyCardLayer:getGridByPos(pPosNum)
    if not attackCard then
        attackCard = _playerCardLayer:getGridByPos(pPosNum)
    end
    return attackCard
end

--[[
    @des:显示战斗场景
    @parm:pCopyId 副本id
    @parm:pBaseId 据点id
    @parm:pLevel  据点难度等级
    @parm:pType   战斗类型
--]]
function showCopyFight(pCopyId, pBaseId, pLevel, pType)
    print("showCopyFight pCopyId, pBaseId, pLevel, pType", pCopyId, pBaseId, pLevel, pType)
    
    --设置战斗模式为副本战斗
    FightModel.initModel(pCopyId, pBaseId, pLevel, pType)
    FightModel.setbModel(BattleModel.COPY)
    --初始化战斗
    initFight()
    local formation = FightModel.getPalyerFormation()
    FightModel.setBattleFormation(formation)
    local playerGroup = {}
    for k, v in pairs(formation) do
        playerGroup[tonumber(k) + 1] = v
    end
    _playerCardLayer = PlayerCardNode:createWithIds(playerGroup)
    _bgLayer:addChild(_playerCardLayer, ZOrderType.P_CARD)
    _playerCardLayer:setHpVisible(false)
    _playerCardLayer:setRageVisible(false)
    --播放战斗音乐
    local musicName = FightModel.getFightMusic()
    AudioUtil.playBgm("audio/bgm/" .. musicName)

    --开场云特效
    FightController.enterBattle(function ( ... )
        FightSceneAction.playStartEffect(function ( )
            FightMainLoop.runCopyLoop()
        end)
    end)
end

--[[
    @des:显示战斗场景
    @parm:fightRet 战斗串
--]]
function showFightWithString(pFightRet)

    fightRet = pFightRet or FightTest.testFightRet
    FightStrModel.setFightRet(fightRet)
    --设置战斗模式为单场战斗
    FightModel.setbModel(BattleModel.SINGLE)
    --初始化战斗
    initFight()

    --播放战斗音乐
    local musicName = FightScene.getMusicName()
    AudioUtil.playBgm("audio/bgm/" .. musicName)

    --创建我方卡牌
    _playerCardLayer = PlayerCardNode:createWithTeamInfo(FightStrModel.getPlayerInfo())
    _bgLayer:addChild(_playerCardLayer, ZOrderType.P_CARD)
    _playerCardLayer:setHpVisible(true)
    _playerCardLayer:setRageVisible(true)

    --创建敌方卡牌
    _enemyCardLayer = EnemyCardNode:createWithTeamInfo(FightStrModel.getEnemyInfo())
    _bgLayer:addChild(_enemyCardLayer, ZOrderType.E_CARD)
    _enemyCardLayer:setHpVisible(true)
    _enemyCardLayer:setRageVisible(true)

    _playerCardLayer:playDeadEffect()
    --开场云特效
    FightSceneAction.playStartEffect(function ( )
        FightMainLoop.runBattleLoop()
    end)
end

--[[
    @des:战斗重播
--]]
function replay()
    print("FightScene replay")
    --删除死亡特效
    FightSceneAction.removeDeadEffect()
    _reportLayer:removeFromParentAndCleanup(false)
    --创建我方卡牌
    local playerTeamInfo = FightStrModel.getPlayerInfo()
    printTable("replay playerTeamInfo",playerTeamInfo)
    local playerCardLayer = PlayerCardNode:createWithTeamInfo(playerTeamInfo)
    playerCardLayer:setHpVisible(true)
    playerCardLayer:setRageVisible(true)
    FightScene.setPlayerCardLayer(playerCardLayer)

    --创建敌方卡牌
    local enemyTeamInfo = FightStrModel.getEnemyInfo()
    printTable("replay enemyTeamInfo",enemyTeamInfo)
    local enemyCardLayer = EnemyCardNode:createWithTeamInfo(enemyTeamInfo)
    enemyCardLayer:setHpVisible(true)
    enemyCardLayer:setRageVisible(true)
    FightScene.setEnemyCardLayer(enemyCardLayer)

    CCDirector:sharedDirector():getScheduler():setTimeScale(_backSpeed)
    FightMainLoop.setIsSkip(false)
    FightUILayer.setSkipVisible(true)
    FightMainLoop.runBattleLoop()
end


--[[
    @des:初始化战斗
--]]
function initFight()
    init()
    FightMainLoop.init()
    --隐藏非战斗场景
    FightUtil.hideOtherNode()
    --背景
    require "script/utils/BaseUI"
    _bgLayer = BaseUI.createMaskLayer(-450, nil, touchCallback)
    _fightLayer = _bgLayer
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(_bgLayer)
    
    --特效层
    _effectLayer = CCLayer:create()
    _bgLayer:addChild(_effectLayer, ZOrderType.EFFECT)
    
    --背景图片
    local bgName = FightModel.getBgName() or getBgName() 
    _bgSprite = FightBgSprite:createWithName(bgName)
    _bgSprite:setAnchorPoint(ccp(0.5, 0))
    _bgSprite:setPosition(ccps(0.5, 0))
    _bgLayer:addChild(_bgSprite)
    _bgSprite:setScale(g_fScaleX)

    --设置初始偏移位置
    local startPos = FightModel.getStartPos()
    _bgSprite = FightScene.getFightBg()
    if FightModel.getBaseLv() ~= 0 then
        --非npc战斗设置startPos
        _bgSprite:setOffsetPos(startPos)
    end
    --创建ui显示
    local uiLayer = FightUILayer.createLayer()
    _bgLayer:addChild(uiLayer, ZOrderType.UI)
    --外部层
    if not tolua.isnull(_onBattleView) then
        _bgLayer:addChild(_onBattleView, ZOrderType.UI)
    end
    --显示战斗
    local isShowForce = getForceVisible()
    FightUILayer.setForceVisible(isShowForce)
end

--[[
    @des:触摸回调
--]]
function touchCallback()
    if _isNameVisible == false then
        setNameVisible(true)
        _isNameVisible = true
    else
        setNameVisible(false)
        _isNameVisible = false
    end
end

--[[
    @des:关闭战斗场景
--]]
function closeScene()  
    if _reportLayer then
        _reportLayer:release()
        _reportLayer = nil
    end
    if not tolua.isnull(_bgLayer) then
        _bgLayer:removeFromParentAndCleanup(true)
        _bgLayer = nil        
    end
    --执行战斗结束回调
    if _endCallback then
        local doBattleInfo = FightModel.getDoBattleInfo()
        if doBattleInfo then
            local isWin   = FightModel.getResult()
            _endCallback(doBattleInfo.newcopyorbase, isWin, doBattleInfo.extra_reward, doBattleInfo.extra)
        else
            _endCallback()
        end
    end
    --显示隐藏掉的node
    FightUtil.showOtherNode()
    _endCallback = nil
    CCNotificationCenter:sharedNotificationCenter():postNotification("NC_FightOver")
    FightMainLoop.setIsSkip(false)
    FightMainLoop.setBattleIndex(1)
    FightStrModel.clearData()
    release()
    CCDirector:sharedDirector():getScheduler():setTimeScale(1)
    AudioUtil.playBgm("audio/main.mp3")
end