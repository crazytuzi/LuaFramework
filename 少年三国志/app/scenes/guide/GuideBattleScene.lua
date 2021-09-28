--GuideBattleScene.lua

local BattleLayer = require("app.scenes.battle.BattleLayer")
local GuideBattleScene = class("GuideBattleScene", UFCCSBaseScene)
local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
local _storyDungeonConst = require("app.const.StoryDungeonConst")

function GuideBattleScene._guide_create_( step_id, callbackFunc )
	return require("app.scenes.guide.GuideBattleScene").new( step_id,1, nil, callbackFunc )
end

function GuideBattleScene:ctor( step_id,_type, asyncFunc, callbackFunc )
	self.super.ctor( self, step_id, asyncFunc, callbackFunc)
	self._finishCallback = callbackFunc
	self._stepId = step_id
    self._type = _type or 1
        self.storyIdList = {}
        self.isMove = false
        self._totalGo = 0
	--uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_BATTLE, self._onReceiveTestBattle, self)
	--G_HandlersManager.battleHandler:sendBattleTest()

	
end

function GuideBattleScene:onSceneEnter(...)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
    self._totalGo = 0
    self:_onReceiveTestBattle()

    if self._type == 1 then
        self._skipLayer = self:addUILayerComponent("SkipLayer", "ui_layout/createrole_skipLayer.json", false, true)
        self._skipLayer:registerBtnClickEvent("Button_skip", function ( ... )
            self:removeComponent(SCENE_COMPONENT_GUI, "SkipLayer")
            if self._finishCallback then 
                self._finishCallback()
            end
        end)
        self._skipLayer:setZOrder(10)
    end
end

function GuideBattleScene:_onReceiveTestBattle(  )
	require("app.common.tools.Tool")
	--dumpTable(message)

	-- if not self._stepId then
	-- 	return __LogError("invalid step_id")
	-- end

	-- local guideInfo = newplay_guide_info.get(self._stepId)
	-- if not guideInfo then
	-- 	return __LogError("invalid step_id:", self._stepId)
	-- end

	G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
	
--	message["info"]["own_teams"][1]["units"][1].id = 10*G_Me.bagData.knightsData:getMainKnightBaseId() + 4
	
	--uf_sceneManager:getCurScene():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = 101, func = function ( ... )
		self:_onStoryTalkEnd()
	--end}))   
end

function GuideBattleScene:_onStoryTalkEnd( ... )
    local _type = self._type or 1
    local message = nil
    local move = {}
    if _type == 1 then
        message = require("app.cfg.guide_battle").info
        move = {{1, 3, 5}}
    elseif _type == 2 then
        message = require("app.battlereport.story_battle_report1")
        move = {{1},{2,3}}
    end
    if not message then 
        return
    end
    G_Loading:showLoading(function ( ... )
        self._battle = BattleLayer.create({msg = message, skip=BattleLayer.SkipConst.SKIP_NO, battleBg="pic/dungeonbattle_map/31010.png", moveFromOutside=true, moveFromOutsidePositions=move, curWave=2, double=2 }, 
			handler(self, self._onBattleEvent))
    	self:addChild(self._battle)
    end,
    function ( ... )
        self._battle:play()
    end)

end

function GuideBattleScene:onSceneLoad( step_id, asyncFunc, callbackFunc )
		
end


function GuideBattleScene:_onBattleEvent( event,... )
     local monsterid = 0
    local touchtype = nil
    local BattleLayer = require "app.scenes.battle.BattleLayer"
	if event == BattleLayer.BATTLE_FINISH then
                if self._finishCallback then
                    if self:storyCallBack(0,self._finishCallback,_storyDungeonConst.TOUCHTYPE.TYPE_PASSDUNGEON) == false then
                        self._finishCallback()
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
        end
    end

    if touchtype and self:storyCallBack(monsterid,handler(self,self.callBack),touchtype) then
        self._battle:hideSp()
        self._battle:pause()
    end
end

function GuideBattleScene:callBack()
    uf_funcCallHelper:callAfterFrameCount(2, function ( ... )
        self._battle:showSp()
        self._battle:resume()
        if self._type == 1 and self.isMove == false then
            self._battle:move(2, true, true)
            self.isMove = true
        end
    end)
end

-- @desc 剧情副本回调
function GuideBattleScene:storyCallBack(id,_callBack,_touchtype)
    local _type = self._type or 1
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_NEWGUIDE,_type,_storyDungeonConst,_touchtype,nil,1)
    if  isHave == true then
        if self.storyIdList[_storyId] == nil then
            self.storyIdList[_storyId] = _storyId
            --uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = _storyId,func = _callBack}))
            uf_sceneManager:getCurScene():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = _storyId,func = _callBack, rapid=true}))
        else
            return false
        end
    end
    return isHave
end

return GuideBattleScene

