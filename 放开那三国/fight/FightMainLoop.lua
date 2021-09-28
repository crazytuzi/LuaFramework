-- FileName: FightMainLoop.lua
-- Author: lcy
-- Date: 2015-07-24
-- Purpose: function description of module
--[[TODO List]]

module("FightMainLoop", package.seeall)

local _battleIndex = 1
local _isSkip = false
local _armyIndex = 1

function init( ... )
    _armyIndex = 1
    _battleIndex = 1
end

--[[
    @des:得到当前播放索引
--]]
function getBattleIndex()
    return _battleIndex
end

--[[
    @des:得到当前播放索引
--]]
function setBattleIndex( pIndex )
    _battleIndex = pIndex
end

--[[
    @des:是否跳过战斗
--]]
function getIsSkip()
    return _isSkip
end

--[[
    @des:设置是否已经跳过战斗
--]]
function setIsSkip( pIsSkip )
    _isSkip = pIsSkip
end

--[[
    @des:得到当前部队索引
--]]
function getArmyIndex()
    return _armyIndex
end


--[[
    @des:执行副本战斗主循环
--]]
function runCopyLoop()
    _armyIndex = 1
    showArmyIndex(nextArmyCallback)
end

--[[
    @des:执行下一个部队的回调
--]]
function nextArmyCallback ()
     --1.判断上次战斗是否胜利
    local isWin = FightModel.getResult()
    if _armyIndex + 1 <= FightModel.getArmyCount() and isWin then
        _armyIndex = _armyIndex + 1
        --1.复活死亡的卡牌
        --2.进行下一波战斗
        print("进行下一波战斗")
        print("_armyIndex", _armyIndex)
        print("FightModel.getArmyCount()", FightModel.getArmyCount())
        print("isWin", isWin)
        print(debug.traceback())
        showArmyIndex(nextArmyCallback)
    else
        if _isSkip then
            --战斗结束
            FightSceneAction.showCopyAfterBattleLayer()
        else
            FightSceneAction.showCopyAfterBattleLayer()
        end
        _battleIndex = 1
        _isSkip = false    
    end
end
--[[
    des:播放一个部队的战斗
--]]
function showArmyIndex( pCallback )
    --清除战斗数据
    FightStrModel.clearData()
    FightMainLoop.setIsSkip(false)
    FightSceneAction.moveToArmy(function ()
        --播放npc出场特效
        FightSceneAction.playEnemyAppearEffect(function ()
            --播发我方卡牌出场特效
            FightSceneAction.playNpcAppear(function()
                --切换阵容
                FightSceneAction.switchForamtion(function ()
                    --播放战斗前对话
                    FightSceneAction.playTalk(FightTalkTime.BEFORE, function ()
                        --请求战斗数据
                        FightSceneAction.requestBattleInfo(function ()
                            --开始战斗
                            runBattleLoop(function ()
                                --播放结束前对话
                                FightSceneAction.playTalk(FightTalkTime.END, function ()
                                    print("showArmyIndex", _armyIndex, pCallback)
                                    if pCallback then
                                        pCallback()
                                    end
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end)
    end)
end

--[[
	@des:执行战斗主循环
--]]
function runBattleLoop( pCallback )
	_battleIndex = 1
    FightUILayer.setSkipVisible(true)
    --显示宠物
    FightPetAction.showPetAtBattle(function ()
        --战斗回合
        showRoundIndex( function ()
            --1.刷新ui显示
            FightUILayer.updateRes()
            if pCallback then
                pCallback()
            end
        end)
    end)
end

--[[
	@des:主回合循环
--]]
function showRoundIndex( pCallback )
    local blockInfo = FightStrModel.getBlockByIndex(_battleIndex)
    --刷新ui显示
    FightUILayer.updateUI()
    FightScene.updateOnBattleView(blockInfo)
    --执行战斗
    if blockInfo and not _isSkip then
        --执行攻击动作
        FightCardAction.playSkillAction(blockInfo, function ()
            --下个回合
            _battleIndex = _battleIndex + 1
            showRoundIndex(pCallback)
        end)
    else
        if FightModel.getbModel() == BattleModel.SINGLE then
            --战斗结束
            if not _isSkip then
                FightScene.showAfterBattleLayer()
            end
        end
        if pCallback then
            pCallback()
        end
    end
end
