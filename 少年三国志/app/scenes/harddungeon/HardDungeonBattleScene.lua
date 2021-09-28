-- HardDungeonBattleScene
local _storyDungeonConst = require("app.const.StoryDungeonConst")
local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
local HardDungeonBattleScene = class("HardDungeonBattleScene", UFCCSBaseScene)

function HardDungeonBattleScene:ctor(msg, pack, ...)
    
    HardDungeonBattleScene.super.ctor(self, pack, ...)
    local _stageData = hard_dungeon_stage_info.get(msg._data.id)
    local _dungeonInfo = G_GlobalFunc.getHardDungeonData(_stageData.value)
    local path = G_Path.getDungeonBattleMap( _dungeonInfo.map)

    local alert = G_Me.hardDungeonData:getAlert(msg._data.id)
    self._alert = alert
    self._alertCount = 1
    self._totalGo = 0
    self._data = msg._data
    self._next = 1
    self._pack = pack
    
    self._isSkip = msg.isSkip
    self._stageId = self._data.id
    self._nextWaveId = self._data.next_wave_id
    --self._finishBatllCallBack = msg.finishBatllCallBack
    self.waveNum = 0
    self.waveCount = _dungeonInfo.monster_wave
    self.battleRes = {}
        
    local _isCompleted = false
    local stageInfo = G_Me.hardDungeonData:getStageById(self._stageId)
    if stageInfo then
        if stageInfo._star then
            _isCompleted = stageInfo._star == 3
        end
    end
    
    self._continuelayer = CCSNormalLayer:create("ui_layout/dungeon_DungeonContinueBattle.json")
    self._continuelayer:adapterWithScreen()
    self._continuelayer:setVisible(false)
    self._continuelayer:registerBtnClickEvent("Button_Continue",handler(self, self._onContinue))
    self:addChild(self._continuelayer,10)
    
    --G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
    local BattleLayer = require("app.scenes.battle.BattleLayer")
    
    if alert == nil then
        msg._data.info = rawget(msg._data, "info") or require "app.battlereport.story_battle_report1"
        self._battleField = BattleLayer.create({msg = msg._data.info,battleBg = path,battleType = BattleLayer.DUNGEON_BATTLE,
            skip =  self._isSkip == true and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO,waveCount = _dungeonInfo.monster_wave}, 
        handler(self, self._onBattleEvent))
        self:addChild(self._battleField)
    else
        local message = require("app.battlereport."..self._alert[self._alertCount])
        self._alertCount = self._alertCount + 1
        self._battleField = BattleLayer.create({msg = message,battleBg = path,battleType = BattleLayer.DUNGEON_BATTLE,
            skip = BattleLayer.SkipConst.SKIP_NO,moveFromOutside=true, moveFromOutsidePositions = {{1},{2,3}}}, 
        handler(self, self._onBattleEvent))
        self:addChild(self._battleField)
    end
    
    self._buff = require("app.scenes.harddungeon.HardDungeonBattleBuffLayer").create()
    self:addChild(self._buff)
    local winSize = CCDirector:sharedDirector():getWinSize()
    self._buff:setPosition(ccp(0, winSize.height/2+50))
    
end

-- 继续战斗
function HardDungeonBattleScene:_onContinue(Widget)
    if self._nextWaveId ~= 0 and self.waveNum < self.waveCount then
        G_HandlersManager.hardDungeonHandler:sendExecuteMultiStage(self._stageId, self._nextWaveId)
    else -- 显示结算
            self:finishBattleCallBack(self._data.info.is_win)
    end
end

function HardDungeonBattleScene:onSceneEnter(...)
    --self:play()
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function HardDungeonBattleScene:play()
    self.waveNum = self.waveNum + 1
    self._battleField:play()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_ENTERBATTLE,self._enterBattle,self)
end


function HardDungeonBattleScene:_enterBattle(decodeBuff)
    if self.waveNum < self.waveCount then
        self._continuelayer:setVisible(false)
        self._data = decodeBuff
        self._nextWaveId = decodeBuff.next_wave_id
        self._battleField:reset(decodeBuff.info)
        self._totalGo = 0
        if self.waveNum > 0 then
            self._battleField:move(self.waveNum)
            self.waveNum = self.waveNum + 1
        end
        self._battleField:play()
    else
        self:finishBattleCallBack(self._data.info.is_win)
    end

end

function HardDungeonBattleScene:_onBattleEvent(event,...)
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    if event == BattleLayer.BATTLE_ROUND_UPDATE then
        local params = {...}
        self._buff:updateRound(params[1])
    elseif event == BattleLayer.BATTLE_FINISH then
        if self._alert == nil then
            if self._nextWaveId ~= 0  and self.waveNum < self.waveCount then
                self._continuelayer:setVisible(true)
                G_HandlersManager.hardDungeonHandler:sendExecuteMultiStage(self._stageId, self._nextWaveId)
            else
                self:finishBattleCallBack(self._data.info.is_win)
            end
        else
            if #self._alert >= self._alertCount then
                self:_specialBattleEnd() 
            else
                self:finishBattleCallBack(true)
            end
        end
        return
    end
end

--[[
function HardDungeonBattleScene:_onBattleEvent(event,...)
    -- print("event ==== "..event)
    local monsterid = 0
    local touchtype = nil
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    if event == BattleLayer.BATTLE_FINISH then
        if self._alert == nil then
            if self._nextWaveId ~= 0  and self.waveNum < self.waveCount then
                self._continuelayer:setVisible(true)
                G_HandlersManager.hardDungeonHandler:sendExecuteMultiStage(self._stageId, self._nextWaveId)
            else
                self:finishBattleCallBack(self._data.info.is_win)
            end
        else
            if #self._alert >= self._alertCount then
                local _stageData = hard_dungeon_stage_info.get(self._stageId)
                local _storyDungeonConst = require("app.const.StoryDungeonConst")
                local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
                local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_DUNGEON,_stageData.value*self._next,_storyDungeonConst,_storyDungeonConst.TOUCHTYPE.TYPE_PASSDUNGEON,nil,_stageData.id)
                if isHave == true then
                     uf_notifyLayer:getModelNode():addChild(require("app.scenes.harddungeon.HardDungeonStoryTalkLayer").create({storyId = _storyId,func = handler(self,self._specialBattleEnd)}))
                else
                    self:_specialBattleEnd()
                end
            else
                self:finishBattleCallBack(true)
            end
        end
        return
    else
            monsterid,touchtype = storytouch.BattleEvent(event,...)
    end

    if touchtype == _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH then
        self._totalGo = self._totalGo + 1
        if self._totalGo == 2 then
            touchtype = _storyDungeonConst.TOUCHTYPE.TYPE_OUTSIDE_FINISH2
        else
            if self._totalGo > 2 then
                return
            end
        end
    end

    if touchtype and self:storyCallBack(monsterid,handler(self,self.callBack),touchtype) then
        self._battleField:hideSp()
        self._battleField:pause()
    end
end
]]--

function HardDungeonBattleScene:_specialBattleEnd()
    uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
            self._next = self._next * 10000
            local message = require("app.battlereport."..self._alert[self._alertCount])
            self._battleField:reset(message)
            self._alertCount = self._alertCount + 1
            self._battleField:replay()
    end)
end

-- @desc 剧情副本回调
function HardDungeonBattleScene:storyCallBack(id,_callBack,_touchtype)
    -- print("storyCallBack ====== ".._touchtype)
    local _stageData = hard_dungeon_stage_info.get(self._stageId)
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_DUNGEON,_stageData.value*self._next,_storyDungeonConst,_touchtype,id,_stageData.id)
    if  isHave == true then
        uf_notifyLayer:getModelNode():addChild(require("app.scenes.harddungeon.HardDungeonStoryTalkLayer").create({storyId = _storyId,func = _callBack}))
    end
    return isHave
end

-- 显示结算页面
function HardDungeonBattleScene:_showCount()
    self.battleRes = G_Me.hardDungeonData:getbattleRes()
    if self.battleRes then
        local FightEnd = require("app.scenes.common.fightend.FightEnd")
        local result = G_GlobalFunc.getHardDungeonBattleResult(self._isWin,self.battleRes.stage_star)
       FightEnd.show(FightEnd.TYPE_DUNGEON, self._isWin,
           {
              star=self.battleRes.stage_star, 
              exp=self.battleRes.stage_exp, 
              money=self.battleRes.stage_money,
              awards = self.battleRes.awards,
            },
            function() 
                --self._finishBatllCallBack()
                --uf_sceneManager:popScene()
                G_Me.hardDungeonData:setRebelData(self.battleRes.rebel,self.battleRes.rebel_level)
                uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonGateScene").new(nil, self._pack))
           end 
           ,result
        )
    else
        uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonGateScene").new(nil, self._pack)) 
    end


end

function HardDungeonBattleScene:onSceneExit( ... )
    --self._finishBatllCallBack = nil
    uf_eventManager:removeListenerWithTarget(self)
end
-- @desc完成战斗回调
-- @param isWin 是否胜利
function HardDungeonBattleScene:finishBattleCallBack(isWin)
    self._isWin = isWin
    self:_showCount()
end

function HardDungeonBattleScene:callBack()
    self._battleField:showSp()
    self._battleField:resume()
end

return HardDungeonBattleScene



