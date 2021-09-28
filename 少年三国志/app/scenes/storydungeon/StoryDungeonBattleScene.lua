-- StoryDungeonBattleScene
require("app.cfg.story_barrier_info")
local _storyDungeonConst = require("app.const.StoryDungeonConst")
local storytouch = require("app.scenes.storytouch.StoryTouchEvent")

local StoryDungeonBattleScene = class("StoryDungeonBattleScene", UFCCSBaseScene)

function StoryDungeonBattleScene:ctor(msg,...)
    
    StoryDungeonBattleScene.super.ctor(self, ...)
--    local _stageData = dungeon_stage_info.get(msg._data.id)
    local _barrierInfo = story_barrier_info.get(G_Me.storyDungeonData:getCurrBarrierId())
    local path = G_Path.getDungeonBattleMap(_barrierInfo.battle_background)

    self._data = msg._data
    self._finishBatllCallBack = msg.finishBatllCallBack
    self._next_wave_id = msg._data.next_wave_id
    self._isSkip = msg.isSkip
    --self._stageId = msg._data.id
    local BattleLayer = require("app.scenes.battle.BattleLayer")
    self._battleField = BattleLayer.create({msg = msg._data.info,battleBg = path,skip =  self._isSkip == true and BattleLayer.SkipConst.SKIP_YES or BattleLayer.SkipConst.SKIP_NO,waveCount =_barrierInfo.waves_num}, handler(self, self._onBattleEvent))
    self:addChild(self._battleField)
    
    self._continuelayer = CCSNormalLayer:create("ui_layout/dungeon_DungeonContinueBattle.json")
    self._continuelayer:adapterWithScreen()
    self._continuelayer:setVisible(false)
    self._continuelayer:registerBtnClickEvent("Button_Continue",handler(self, self._onContinue))
    self:addChild(self._continuelayer,10)
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_EXECUTEBARRIER, self._recvExecuteBarrier, self)
        
end

-- 继续战斗
function StoryDungeonBattleScene:_onContinue(Widget)
    if self._next_wave_id ~= 0 then
        G_HandlersManager.storyDungeonHandler:sendExecuteBarrier(
            G_Me.storyDungeonData:getCurrDungeonId(),G_Me.storyDungeonData:getCurrBarrierId(),self._next_wave_id)
    end
end

-- @desc 执行多波战斗
function StoryDungeonBattleScene:_recvExecuteBarrier(data)
    if data.ret == NetMsg_ERROR.RET_OK then
        self._continuelayer:setVisible(false)
        self._data = data
        self._battleField:reset(data.info)
        if self._next_wave_id > 0 then
            -- 多波怪最多移动两次，所以需要减1
            self._battleField:move(self._next_wave_id-1)
        end
        self._next_wave_id = data.next_wave_id
        self._battleField:play()
    end
end

function StoryDungeonBattleScene:play()
    self._battleField:play()
end
    
function StoryDungeonBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function StoryDungeonBattleScene:onSceneExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

function StoryDungeonBattleScene:_onBattleEvent(event,...)
     local monsterid = 0
    local touchtype = nil
    local BattleLayer = require "app.scenes.battle.BattleLayer"
    if event == BattleLayer.BATTLE_FINISH then
        if self._next_wave_id == 0 or self._next_wave_id > 3 then
            self:onFinishBattleCallBack(self._data.info.is_win)
        else
             self._continuelayer:setVisible(true)
            G_HandlersManager.storyDungeonHandler:sendExecuteBarrier(
                G_Me.storyDungeonData:getCurrDungeonId(),G_Me.storyDungeonData:getCurrBarrierId(),self._next_wave_id)
            return
        end
    else
         monsterid,touchtype = storytouch.BattleEvent(event,...)
    end

    if touchtype and self:storyCallBack(monsterid,handler(self,self.callBack),touchtype) then
        self._battleField:hideSp()
        self._battleField:pause()
    end
    
end

-- @desc 名将副本
function StoryDungeonBattleScene:storyCallBack(id,_callBack,_touchtype)
   local _barrierInfo = story_barrier_info.get(G_Me.storyDungeonData:getCurrBarrierId())
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_STORYDUGEON,
                                                   _barrierInfo.dungeon,
                                                   _storyDungeonConst,
                                                   _touchtype,
                                                   nil,
                                                   _barrierInfo.id)
    if  isHave == true then
        self:_showStoryTalkLayer({storyId = _storyId,func = handler(self,self._callBack)})
    end
    return isHave
end

function StoryDungeonBattleScene:callBack()
    self._battleField:showSp()
    self._battleField:resume()
end

function StoryDungeonBattleScene:onFinishBattleCallBack(isWin)
    self._isWin = isWin    
    local _barrierInfo = story_barrier_info.get(G_Me.storyDungeonData:getCurrBarrierId())
    local isHave = false
    local _storyId = nil
    if self._isWin then
        isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_STORYDUGEON,
                                                   _barrierInfo.dungeon,
                                                   _storyDungeonConst,
                                                   _storyDungeonConst.TOUCHTYPE.TYPE_PASSDUNGEON,
                                                   nil,
                                                   _barrierInfo.id)
    end
    -- 判断是否需要显示剧情
    if self._isWin == true and isHave == true then 
         self:_showStoryTalkLayer({storyId = _storyId,func = handler(self,self._showCount)})
    else
        self:_showCount()
    end
end

-- @desc显示剧情对话
-- @param storyid 剧情id
function StoryDungeonBattleScene:_showStoryTalkLayer(storyid)
    uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create(storyid))
end

-- 显示结算页面
function StoryDungeonBattleScene:_showCount()
    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    local result = G_GlobalFunc.getBattleResult(self._battleField)
   FightEnd.show(FightEnd.TYPE_DUNGEON, self._isWin,
       {
          star=self._data.barrier_star, 
          exp=self._data.barrier_exp, 
          money=self._data.barrier_money,
         awards = self._data.monster_awards,
        },
        function() 
            if self._finishBatllCallBack then
                self._finishBatllCallBack(self._data.info.is_win)
            end
        uf_sceneManager:popScene()

       end,
       result
    )
end


return StoryDungeonBattleScene



