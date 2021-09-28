-- DungeonBattleScene
local _storyDungeonConst = require("app.const.StoryDungeonConst")
local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
local DungeonBattleScene = class("DungeonBattleScene", UFCCSBaseScene)

function DungeonBattleScene:ctor(msg, pack, ...)
    
    DungeonBattleScene.super.ctor(self, pack, ...)
    local _stageData = dungeon_stage_info.get(msg._data.id)
    local _dungeonInfo = G_GlobalFunc.getDungeonData(_stageData.value)
    local path = G_Path.getDungeonBattleMap( _dungeonInfo.map)

    local alert = G_Me.dungeonData:getAlert(msg._data.id)
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
    local stageInfo = G_Me.dungeonData:getStageById(self._stageId)
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

end

-- 继续战斗
function DungeonBattleScene:_onContinue(Widget)
    if self._nextWaveId ~= 0 and self.waveNum < self.waveCount then
        G_HandlersManager.dungeonHandler:sendExecuteMultiStage(self._stageId, self._nextWaveId)
    else -- 显示结算
            self:finishBattleCallBack(self._data.info.is_win)
    end
end

function DungeonBattleScene:onSceneEnter(...)
    --self:play()
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function DungeonBattleScene:play()
    self.waveNum = self.waveNum + 1
    self._battleField:play()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DUNGEON_ENTERBATTLE,self._enterBattle,self)
end


function DungeonBattleScene:_enterBattle(decodeBuff)
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

function DungeonBattleScene:_onBattleEvent(event,...)
    -- print("event ==== "..event)
    local monsterid = 0
    local touchtype = nil
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    if event == BattleLayer.BATTLE_FINISH then
        if self._alert == nil then
            if self._nextWaveId ~= 0  and self.waveNum < self.waveCount then
                self._continuelayer:setVisible(true)
                G_HandlersManager.dungeonHandler:sendExecuteMultiStage(self._stageId, self._nextWaveId)
            else
                self:finishBattleCallBack(self._data.info.is_win)
            end
        else
            if #self._alert >= self._alertCount then
                local _stageData = dungeon_stage_info.get(self._stageId)
                local _storyDungeonConst = require("app.const.StoryDungeonConst")
                local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
                local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_DUNGEON,_stageData.value*self._next,_storyDungeonConst,_storyDungeonConst.TOUCHTYPE.TYPE_PASSDUNGEON,nil,_stageData.id)
                if isHave == true then
                     uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = _storyId,func = handler(self,self._specialBattleEnd)}))
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

function DungeonBattleScene:_specialBattleEnd()
    uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
            self._next = self._next * 10000
            local message = require("app.battlereport."..self._alert[self._alertCount])
            self._battleField:reset(message)
            self._alertCount = self._alertCount + 1
            self._battleField:replay()
    end)
end

-- @desc 剧情副本回调
function DungeonBattleScene:storyCallBack(id,_callBack,_touchtype)
    -- print("storyCallBack ====== ".._touchtype)
    local _stageData = dungeon_stage_info.get(self._stageId)
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_DUNGEON,_stageData.value*self._next,_storyDungeonConst,_touchtype,id,_stageData.id)
    if  isHave == true then
        uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = _storyId,func = _callBack}))
    end
    return isHave
end

-- 显示结算页面
function DungeonBattleScene:_showCount()
    self.battleRes = G_Me.dungeonData:getbattleRes()
    if self.battleRes then
        local FightEnd = require("app.scenes.common.fightend.FightEnd")
        local result = G_GlobalFunc.getBattleResult(self._battleField)
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
                G_Me.dungeonData:setRebelData(self.battleRes.rebel,self.battleRes.rebel_level)
                uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonGateScene").new(nil, self._pack))
           end 
           ,result
        )
    else
        uf_sceneManager:replaceScene(require("app.scenes.dungeon.DungeonGateScene").new(nil, self._pack)) 
    end


end

function DungeonBattleScene:onSceneExit( ... )
    --self._finishBatllCallBack = nil
    uf_eventManager:removeListenerWithTarget(self)
end
-- @desc完成战斗回调
-- @param isWin 是否胜利
function DungeonBattleScene:finishBattleCallBack(isWin)
    
    self._isWin = isWin
    
    local _stageData = dungeon_stage_info.get(self._stageId)
    local _storyDungeonConst = require("app.const.StoryDungeonConst")
    local storytouch = require("app.scenes.storytouch.StoryTouchEvent")

    local isHave = false
    local _storyId = nil
    -- 只有当胜利的时候，才去判断有没有战斗结束对话
    if self._isWin == true then
        isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_DUNGEON,
                                                _stageData.value*self._next,
                                                _storyDungeonConst,
                                                _storyDungeonConst.TOUCHTYPE.TYPE_PASSDUNGEON,
                                                nil,
                                                _stageData.id)
    end
    if self._isWin == true and isHave == true then
         uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = _storyId,func = handler(self,self._showCount)}))
    else
        self:_showCount()
    end
end

function DungeonBattleScene:callBack()
    self._battleField:showSp()
    self._battleField:resume()
end

return DungeonBattleScene



