require("app.cfg.story_barrier_info")
require("app.cfg.story_dungeon_touch_info")
local StoryDungeonGateScene = class("StoryDungeonGateScene",UFCCSBaseScene)
local BOXTYPE = require("app.const.BoxType")

local roadIndex = 1

local MONSTER_EFFECT_TAG_PREFIX = 121
local WHISPER_BUBBLE_TAG = 1323

function StoryDungeonGateScene:ctor( pack, ... )
    self.super.ctor(self, ... )
    GlobalFunc.savePack(self, pack)

    self._lastScene = nil
    self._isWin = false
    -- 战斗奖励缓存
    self.bouns = {}
    self._layer = CCSNormalLayer:create("ui_layout/storydungeon_StoryDungeonGateScene.json")
    self:addUILayerComponent("StoryDungeonGateLayer111",self._layer,true)
    
    -- 记录关卡状态
    self.stageFinishStatus = {}
    self.stageFinishStatus[1] = false 
    self.stageFinishStatus[2] = false
    self.stageFinishStatus[3] = false
    self.stageFinishStatus[4] = false
    
    self._isFirstEnter = false
    self.skipList = {}
    self._lastPos =nil
    -- 是否完成副本
    self.isFinish = false
    
    -- 当前通关索引
    self.openRoadCurrIndex = 0
    
    -- 上一个通关索引 
    self.openRoadLastIndex = 0
    -- 是否在播放动画
    self.playAction = false
    
    self.effectNode = nil
    
    self._roleInfo = G_commonLayerModel:getStoryDungeonRoleInfoLayer()
    self._speedBar = G_commonLayerModel:getSpeedbarLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedBar,true)
    
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
--    if _data.type == 1 then
--        _data = story_dungeon_info.get(_data.field)
--    end
--    G_Me.storyDungeonData:setCurrField(_data.field)
    self:_loadMap(_data.json_id)
    --self:adapterLayerHeight(self._layer,nil,self._speedBar,20,0)

    --self._layer:adapterWidgetHeightWithOffset("Panel_Map",0,0)
    self._layer:adapterWidgetHeightWithOffset("ScrollView_Knight",0,0)

    self._tWhisperLayer = nil 

    self:_createMark()
    self:_initGate()
    self:_initRoad()
    
    
    self._layer:registerBtnClickEvent("Button_Back",handler(self,self._onBack))

    self:registerKeypadEvent(true)
    
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        self:showSceneEffect()
    end
    
end

function StoryDungeonGateScene:onBackKeyEvent( ... )
    self:_onBack()
    return true
end

-- 提示有奖励可以领取
function StoryDungeonGateScene:_showTips()
        self._layer:getImageViewByName("Image_Tips"):setVisible(G_Me.storyDungeonData:isHaveBouns())
end
-- 设置需要返回的scene
function StoryDungeonGateScene:setLastScene(path)
    self._lastScene = path
end

-- @desc  初始化关卡数据
function StoryDungeonGateScene:_initGate()
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
    local _knightPic = require("app.scenes.common.KnightPic")
    
    --新手光环经验
    self._layer:getLabelByName("Label_rookieInfo"):setText(
        G_Me.rookieBuffData:checkInBuff() and G_lang:get("LANG_ROOKIE_BUFF_PERIOD") or "")
    self._layer:getLabelByName("Label_rookieInfo"):createStroke(Colors.strokeBrown, 1)
    

    self._layer:getLabelByName("Label_Title"):setText(_data.name)
    self._layer:getLabelByName("Label_Title"):createStroke(Colors.strokeBrown,1)
    self._layer:getLabelByName("Label_Intro"):setText(G_lang:get("LANG_STORYDUNGEON_INTRO"))
    -- 点击武将传按钮
    self._layer:registerBtnClickEvent("Button_Desc",function() 
            local imgKnight = self._layer:getImageViewByName("Image_Knight")
            local op = imgKnight:getOpacity()
            local actionName = "expand"
            if op == 0 then actionName = "up" end
            self._layer:playAnimation(actionName,function(name,_status) end)
    end)
        
    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydata then
        self.isFinish = _storydata.is_finished
                    -- 如果是新开启状态则设置未已经开启
        if _storydata.is_entered == false then
            G_HandlersManager.storyDungeonHandler:sendSetStoryTag(G_Me.storyDungeonData:getCurrDungeonId())
        end
    end
    local descLabel = self._layer:getLabelByName("Label_Desc")
    descLabel:setText(_data.direction)
    descLabel:createStroke(Colors.strokeBrown,1)
    
    for i=1,4 do
        local _info = story_barrier_info.get(_data["barrier" .. i])
        local nameLabel = self._layer:getLabelByName("Label_Name" .. i)
        nameLabel:setColor(Colors.qualityColors[_info.quality])
        nameLabel:setText(_info.name)
        nameLabel:createStroke(Colors.strokeBrown,1)
        
        local _panel = self._layer:getPanelByName("Panel_Knight" ..i)
        if _panel then
            _panel:setBackGroundColorOpacity(0)
            local _knight = _knightPic.createKnightButton(_info.res_id, _panel,"stage_" .. i,
            self._layer,handler(self, self._onClickKnight),true)
            _knight:setTag(_info.id)
            _panel:setTag(_info.id)
            local _sprite = _knight:getVirtualRenderer()
            local _scale = _knight:getScale()
            if i == 4 then
                -- 这个是大Boss
                _knight:setScale(_scale + 0.2)
                -- 为大Boss脚底增加特效，同精英副本
                self:_createMonsterEffect(_knight, _info.res_id, true)
            end
            local pt = self:_getPosByKnight(_knight,nameLabel:getSize().height/2)
            nameLabel:setPositionXY(pt.x,pt.y)
            -- 关卡是否已通关，没通关则置灰
            if _sprite then 
                _sprite = tolua.cast(_sprite, CCSPRITE)
                --_sprite = tolua.cast(_sprite,"CCSprite")
                _sprite:showAsGray(_info.front_barrier >= _storydata.barrier_id)
            end
            
            if _info.front_barrier < _storydata.barrier_id then
                self.openRoadCurrIndex = i
                if i > 1  and _storydata.barrier_id ~= _info.id then
                    self.stageFinishStatus[i] = true
                end
                
                self.openRoadLastIndex = self.openRoadCurrIndex
            end
            
--            local _img = self._layer:getImageViewByName("Image_Base".. i)
--            if _info.quality <= 2 then -- 普通
--                _img:loadTexture(G_Path.getMonsterNameBg(1))
--            elseif _info.quality == 3 then -- 经验
--                _img:loadTexture(G_Path.getMonsterNameBg(2))  
--            else
--                _img:loadTexture(G_Path.getMonsterNameBg(3))
--            end
                

            -- 增加武将的呼吸动作
            local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
            EffectSingleMoving.run(_panel, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
        end
    end

    self:_updateGate()
end

--@desc 武将传介绍动画
function StoryDungeonGateScene:_showKnightIntroAction()
    local arr = CCArray:create()
    arr:addObject(CCCallFunc:create(function()
        self._layer:playAnimation("expand",function(name,_status) end)
    end))
    arr:addObject(CCDelayTime:create(5))
    arr:addObject(CCCallFunc:create(function()
        self._layer:playAnimation("up",function(name,_status) end)
    end))

    self._layer:runAction(CCSequence:create(arr))
end
-- @desc 初始化路径
function StoryDungeonGateScene:_initRoad()
    --local _index = 1
    --for i=1,4 do
    --    if i < self.openRoadCurrIndex then
    --        while(self._layer:getImageViewByName("ImageView_Barrier".. i .. "_" .. _index)) do
    --            local _img = self._layer:getImageViewByName("ImageView_Barrier".. i .. "_" .. _index)
    --            _img:loadTexture(G_Path.DungeonIcoType.ROAD_GREEN)
    --            _index = _index +1
    --        end
    --        _index = 1
    --    end
    --end
    self:_setMarkPos()
end

-- @desc 设置当前开启关卡位置
function StoryDungeonGateScene:_getPosByKnight(_knightPic,_labelheight)
    if _knightPic == nil then return end
    local _parent = _knightPic:getParent()
    local pos = _parent:getPositionInCCPoint()
    local rect = _knightPic:getCascadeBoundingBox()
    local x = 0 y = 0
    local scale = _parent:getScale()
    x,y = _parent:getParent():convertToNodeSpaceXY(rect.origin.x,rect.origin.y,x,y)
    local _pt = ccp(0,0)
    if g_target == kTargetWinRT or g_target == kTargetWP8 then
        _pt.y = y+rect.size.height * (1 - scale) +_labelheight + 20
    else
        _pt.y = y + rect.size.height + _labelheight
    end
    _pt.x = pos.x

    return _pt
end

function StoryDungeonGateScene:_onClickKnight(widget)
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)    
    
    local _data  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    local barrierInfo = story_barrier_info.get(widget:getTag())
    if _data and barrierInfo.front_barrier < _data.barrier_id  then
        self:_stopEffect()
        G_Me.storyDungeonData:setCurrBarrierId(widget:getTag())
        self:addChild(require("app.scenes.storydungeon.StoryDungeonDropLayer").create())

        -- 如果当期ID小于当前最新关卡
        if widget:getTag() < _data.barrier_id then
            self.skipList[widget:getTag()] =  true
        else
            self.skipList[widget:getTag()] =  _data.is_finished and true or false
        end
    else
        barrierInfo = story_barrier_info.get(barrierInfo.front_barrier)
        G_MovingTip:showMovingTip(G_lang:get("LANG_PASSCONDITION",{name= barrierInfo.name}))
    end
end

-- 停止动画已经路径显示
function StoryDungeonGateScene:_stopEffect()
    roadIndex = 1
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
        
        -- 显示当前未显示路径
        --local k = 1
        --while(self._layer:getImageViewByName("ImageView_Barrier".. self.openRoadLastIndex .. "_" .. k)) do
        --    local _img = self._layer:getImageViewByName("ImageView_Barrier".. self.openRoadLastIndex .. "_" .. k)
        --    _img:loadTexture(G_Path.DungeonIcoType.ROAD_GREEN)
        --    k = k +1
        --end
    end
    
    -- 如果正在播放特效，则停止特效播放
    if self.effectNode then
        self.effectNode:removeFromParentAndCleanup(true)
        self.effectNode = nil
    end
    
    -- 如果没有路标则不需要显示
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
    local _panel = self._layer:getPanelByName("Panel_Knight" ..self.openRoadCurrIndex)
    local  _stage_data = story_barrier_info.get(_data["barrier" .. self.openRoadCurrIndex])
    

    -- 显示怪物图片
    local _knightBtn = _panel:getChildByTag(_panel:getTag())   
    if _knightBtn then 
        _knightBtn = tolua.cast(_knightBtn,"Button")
        _knightBtn:loadTextureNormal(G_Path.getKnightPic(_stage_data.res_id))
    end 
    self.openRoadLastIndex = self.openRoadCurrIndex
end

-- @desc 请求战斗 先检查需不需要显示剧情
function StoryDungeonGateScene:_requestBattle()
    local _storyDungeonConst = require("app.const.StoryDungeonConst")
    local _barrierInfo = story_barrier_info.get(G_Me.storyDungeonData:getCurrBarrierId())
    local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_STORYDUGEON,_barrierInfo.id,_storyDungeonConst,_storyDungeonConst.TOUCHTYPE.TYPE_FIRSTENTER,nil,_barrierInfo.id)
    if isHave == true then
        self:_showStoryTalkLayer({storyId = _storyId,func = handler(self,self._sendExecuteBarrier)})
    else
        self:_sendExecuteBarrier()
    end
end

-- @desc显示剧情对话
-- @param storyid 剧情id
function StoryDungeonGateScene:_showStoryTalkLayer(data)
    uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create(data))
end
-- @desc 发送执行关卡请求
function StoryDungeonGateScene:_sendExecuteBarrier()
    G_HandlersManager.storyDungeonHandler:sendExecuteBarrier(
    G_Me.storyDungeonData:getCurrDungeonId(),G_Me.storyDungeonData:getCurrBarrierId(),1)
end


-- @desc 更新最新开启关卡
function StoryDungeonGateScene:_updateGate()
    
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
    self._layer:getLabelByName("Label_ChallengeTimes"):setText(G_lang:get("LANG_STORYDUNGEON_CHALLENGETIMES"))
    self._layer:getLabelByName("Label_ChallengeTimesValue"):setText(G_Me.storyDungeonData:getExecutecount())
    self._layer:getLabelByName("Label_ChallengeTimesValue"):createStroke(Colors.strokeBrown,1)
    self._layer:getLabelByName("Label_ChallengeTimes"):createStroke(Colors.strokeBrown,1)

    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    for i=1,4 do
        local _info = story_barrier_info.get(_data["barrier" .. i])
        
        -- 如果 当前关卡前置id 小于已经开启id 并且 路径索引大于当前已经开启索引
        if _info.front_barrier < _storydata.barrier_id and i > self.openRoadCurrIndex then
            self.openRoadCurrIndex = i
        end
    end
    self:_setMarkPos()


    if self._tWhisperLayer then
        self._tWhisperLayer:removeFromParentAndCleanup(true)
        self._tWhisperLayer = nil
    end

    -- 增加当前怪物的对话
    local curNameLabel = self._layer:getLabelByName("Label_Name" .. self.openRoadCurrIndex)
    if curNameLabel then
        self:_addNpcWhisper(curNameLabel)
    end

    --新手光环经验
    self._layer:getLabelByName("Label_rookieInfo"):setText(
        G_Me.rookieBuffData:checkInBuff() and G_lang:get("LANG_ROOKIE_BUFF_PERIOD") or "")
end

function StoryDungeonGateScene:setScrollEnable( enable )
    local scrollView = self._layer:getScrollViewByName("ScrollView_Knight")
    if scrollView then
        scrollView:setScrollEnable(enable)
    end
end

-- @desc 执行战斗
function StoryDungeonGateScene:_recvExecuteBarrier(data)
    if data.ret == NetMsg_ERROR.RET_OK then
        -- 更新最新开启关卡
        self:_updateGate()

        self.bouns.awards = data.monster_awards
        self.bouns.stage_money = data.barrier_money
        self.bouns.stage_exp = data.barrier_exp
        self.bouns.stage_star = data.barrier_star
        local temp = self
        G_Loading:showLoading(function ( ... )
            if temp == nil then
                return
            end
            
            temp.scene = require("app.scenes.storydungeon.StoryDungeonBattleScene").new({_data = data,isSkip = temp.skipList[data.barrier_id],
            finishBatllCallBack = handler(temp,temp._showAnimation)})
            uf_sceneManager:pushScene(temp.scene)
            temp.skipList[data.barrier_id] = nil
        end, 
        function ( ... )
            temp.scene:play()
        end)

    end
end

function StoryDungeonGateScene:_showRoadAnimation()
    self:_playEffect()
    --local roadPic = self._layer:getImageViewByName("ImageView_Barrier" .. self.openRoadLastIndex .. "_" .. roadIndex)
    --if roadPic == nil  then
    --    self.openRoadLastIndex = self.openRoadLastIndex+1
    --end

    --if roadPic then
    --    roadPic = tolua.cast(roadPic,"ImageView")
    --    roadPic:loadTexture(G_Path.DungeonIcoType.ROAD_GREEN)
    --    roadIndex = roadIndex+1
    --else
    --    roadIndex = 1
    --    self.openRoadLastIndex = self.openRoadCurrIndex
    --    self:_playEffect()
    --    if self._timer then
    --        G_GlobalFunc.removeTimer(self._timer)
    --    end
    --    self._timer = nil
    --end
end

-- @desc 加载地图资源

function StoryDungeonGateScene:_loadMap(mapId)
    local _panel = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("storystagemap/storydungeonmap_" .. mapId .. ".json")
    self._layer:addWidget(_panel)
    self._scrollView = self._layer:getScrollViewByName("ScrollView_Knight")
    self._inner = self._scrollView:getInnerContainer()
    if g_target == kTargetWinRT or g_target == kTargetWP8 then
        self._layer:adapterWidgetHeightWithOffset(_panel,0,-35)
    end
    
    self._mapLayer = _panel
    
end

-- @desc武将出场特效
function StoryDungeonGateScene:_playEffect()
    local _panel = self._layer:getPanelByName("Panel_Knight" .. tostring(self.openRoadCurrIndex))
    if _panel == nil then return end
    local EffectNode = require "app.common.effects.EffectNode"
    local _parent = tolua.cast(_panel:getParent(),"Layout")
    self.effectNode = EffectNode.new("effect_appear", function(event, frameIndex)
        if event == "finish" then
            _parent:removeChild(self.effectNode)
            self.playAction = false
            self.effectNode = nil
            
        elseif event == "appear" then
            -- 将怪物图片点亮
            local _knightBtn = _panel:getChildByTag(_panel:getTag())    
            if _knightBtn then 
                _knightBtn = tolua.cast(_knightBtn,"Button")
                local _sprite = _knightBtn:getVirtualRenderer()
                if device.platform == "wp8" or device.platform =="winrt" then
                    _sprite = tolua.cast(_sprite, "cc.Sprite")
                else
                    _sprite = tolua.cast(_sprite,"CCSprite")
                end
               _sprite:showAsGray(false)
            end
        end
        
            end)      
            
    self.effectNode:play()
    local pt = _panel:getPositionInCCPoint()
    local sz = _panel:getContentSize()
    self.effectNode:setPosition(ccp(pt.x, pt.y))
    _parent:addNode(self.effectNode,10)
end

function StoryDungeonGateScene:initGateBox()
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
        self._layer:registerBtnClickEvent("Button_Box",function()
            local boxLayer = require("app.scenes.dungeon.DungeonBoxLayer").create(BOXTYPE.STORYGATEBOX,_data.box_drop_id,_data.box_drop_id,ccp(display.cx,display.cy))
            self:addChild(boxLayer)
        end)
        
    local _boxBtn = self._layer:getButtonByName("Button_Box")
    local _storydungeondata =  G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydungeondata.has_award == true then -- 空宝箱状态
        _boxBtn:loadTextureNormal(G_Path.getBoxPic(3))
        self:removeEffect(_boxBtn)
    else
        if _storydungeondata.is_finished then -- 宝箱开启状态
            _boxBtn:loadTextureNormal(G_Path.getBoxPic(2), UI_TEX_TYPE_LOCAL)
            self:addBoxEffect(_boxBtn,ccp(20,20))
        end
    end
end

--@desc 删除宝箱特效
function StoryDungeonGateScene:removeEffect(_parent)
    local tag = baseTag
    _parent = tolua.cast(_parent,"Widget")
    local child = _parent:getNodeByTag(1)
    if child then
        child:removeFromParentAndCleanup(true)
    end
end

--@desc 添加宝箱特效
function StoryDungeonGateScene:addBoxEffect(_parent,pos)
   -- local _parent = _parent:getParent()
    _parent = tolua.cast(_parent,"Widget")
    local effectNode = _parent:getNodeByTag(1)
    if effectNode == nil then
        local EffectNode = require "app.common.effects.EffectNode"
        effectNode = EffectNode.new("effect_box_light", function(event, frameIndex) end)      
        effectNode:play()
        effectNode:setPosition(pos)
        effectNode:setTag(1)
        _parent:addNode(effectNode,11)
    end
end

-- @desc 创建标识
function StoryDungeonGateScene:_createMark()
    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydata and not _storydata.is_finished then
--        self.tips = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/dungeon_DungeonStageTips.json")
--        self.tips = CCSNormalLayer:create("ui_layout/dungeon_DungeonStageTips.json")
--        self.tips:playAnimation("move",function() end)
        -- 创建小刀特效
         local EffectNode = require "app.common.effects.EffectNode"
         self.tips = EffectNode.new("effect_knife", function(event, frameIndex)

         end)
         self.tips:play()
        --self._layer:addChild(self.tips,10)
        self._inner:addNode(self.tips,10)
    end
end

function StoryDungeonGateScene:_recvGetList()
    self:_updateGate()
end

function StoryDungeonGateScene:onSceneEnter(...)
    if  G_Me.storyDungeonData:isNeedRequestNewData() then
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_DUNGEONLIST, self._recvGetList, self)
        G_HandlersManager.storyDungeonHandler:sendGetStoryList()
    end
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_EXECUTEBARRIER, self._recvExecuteBarrier, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_REQUESTBATTLE, self._requestBattle, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_STORYDUNGEON_GETBARRIERAWARD, self._recvGetBarrierAward, self)
    
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
    self:initGateBox()
    if not self._isFirstEnter  then
        self:_showKnightIntroAction()
        self._isFirstEnter = true
        self._scrollView:jumpToBottom()
    end

    if self._lastPos then
        self._inner:setPositionXY(self._lastPos.x,self._lastPos.y)
    end
end

function StoryDungeonGateScene:onSceneExit(...)
    uf_eventManager:removeListenerWithTarget(self)
    if self._inner then
        self._lastPos = self._inner:getPositionInCCPoint()
    end
end

-- 领取关卡奖励信息
function StoryDungeonGateScene:_recvGetBarrierAward(data)
    local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
    local _dropInfo = drop_info.get(_data.box_drop_id)
    local _list = {}
    for i=1,5 do
        _list[i] = {type = _dropInfo["type_" .. tostring(i)],value = _dropInfo["value_" .. tostring(i)],
        size = _dropInfo["max_num_" .. tostring(i)]}
    end
    
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BOX_OPEN)
    
    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(_list, function ( ... )
        if self.__EFFECT_FINISH_CALLBACK__ then 
            self.__EFFECT_FINISH_CALLBACK__()
        end
    end)
    self:addChild(_layer)
    self:initGateBox()
end

-- @desc 设置路标位置
function StoryDungeonGateScene:_setMarkPos()
    if self.tips == nil then return end
    
    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydata.is_finished then
        self.tips:setVisible(false)
        return
    end
    
    local nameLabel = self._layer:getLabelByName("Label_Name" .. self.openRoadCurrIndex)
    if nameLabel then
        local pt = nameLabel:getPositionInCCPoint()
        local size = nameLabel:getSize()
        pt.y = pt.y + size.height+20
        self.tips:setPosition(pt)
    end
end



function StoryDungeonGateScene:onSceneUnload(...)
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end

    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")

end

-- @desc 结算显示完后,显示路径
function StoryDungeonGateScene:_showAnimation(isWin)
    if isWin == false then
        return
    end

    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())    
    if self.openRoadLastIndex < self.openRoadCurrIndex then
        -- 首次战胜副本
        if self.isFinish  ==  false then
            if _storydata.is_finished == false then
                if self.stageFinishStatus[self.openRoadLastIndex] == false then
                    self.stageFinishStatus[self.openRoadLastIndex] = true
                    uf_notifyLayer:getModelNode():addChild(require("app.scenes.storydungeon.StoryDungeonPassDungeonLayer").create())
                end
                self.playAction = true
                self:_playEffect()
            end
        end
    end

    -- 最后一个大Boss的情况
    if _storydata.is_finished == true and _storydata._isReallyFinished == false then
        if self.stageFinishStatus[self.openRoadLastIndex] == false then
            self.stageFinishStatus[self.openRoadLastIndex] = true
            uf_notifyLayer:getModelNode():addChild(require("app.scenes.storydungeon.StoryDungeonPassDungeonLayer").create())
        end
        _storydata._isReallyFinished = true
    end

end

function StoryDungeonGateScene:_onBack(widget)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.MAIN)
    local packScene = GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
        uf_sceneManager:replaceScene(require("app.scenes.storydungeon.StoryDungeonMainScene").new())
    end
end

function StoryDungeonGateScene:showSceneEffect()
    -- 加载场景动画
    local bgImg = tolua.cast(UIHelper:seekWidgetByName(self._mapLayer, "ImageView_BG"), "ImageView")
    self.bgPath = bgImg:textureFile()
    local _start,_end = string.find(self.bgPath,"%d-.png")
    local _sceneId = string.sub(self.bgPath,_start,_end-4)
    require("app.cfg.scene_effect_info")
    local data = scene_effect_info.get(1,tonumber(_sceneId))
    local EffectNode = require "app.common.effects.EffectNode"
    local size = bgImg:getContentSize()
    
    function getEffectPosition(pos)
        --assert(pos == 0)
        local x = 0
        local y = 0
        if pos == 1 then
            x = 0   y = 2
        elseif pos == 2 then
            x = 1   y = 2
        elseif pos == 3 then
            x = 2   y = 2
        elseif pos == 4 then
            x = 0  y = 1
        elseif pos == 5 then
            x = 1   y = 1
        elseif pos == 6 then
            x = 2   y = 1
        elseif pos == 7 then
            x = 0   y = 0
        elseif pos == 7 then
            x = 1   y = 0
        elseif pos == 7 then
            x = 2   y = 0
        end

        local size = bgImg:getContentSize()
        local pos_x =   size.width/2*x
        local pos_y = size.height/2*y
        return pos_x,pos_y
    end

    if data then
        for i=1,5 do
            if data["effect_" .. i] ~= "0" then
                if data["effect_btype_" .. i] == 1 then
                    local effectNode = EffectNode.new(data["effect_" .. i], function(event, frameIndex) end)
                    effectNode:setPosition(ccp(size.width/2,size.height/2))
                    bgImg:addNode(effectNode,data["effect_type_" .. i] == 1 and 1 or 20)
                    effectNode:setScale(1/bgImg:getScale())
                    effectNode:play()
                else
                    local emiter = CCParticleSystemQuad:create("particles/" .. data["effect_" .. i] .. ".plist")
                    local posx,posy = getEffectPosition(data["effect_position_type_" .. i])
--                    local pt = ccp(posx,posy)
--                    local x,y = 0,0
--                    x,y = bgImg:convertToNodeSpaceXY(pt.x,pt.y,x,y)
                    emiter:setPositionXY(posx,posy)
                    bgImg:addNode(emiter,30)
                    emiter:setScale(1/bgImg:getScale())
                end

            end
        end
    end
end

-- 大Boss脚底有发光特效
function StoryDungeonGateScene:_createMonsterEffect(btnKnight, nResId, isOpen)
    if not btnKnight then
        return 
    end

    local resId = nResId
    local config = decodeJsonFile(G_Path.getKnightPicConfig(resId))
    local ptPos = ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y))
 
    local MONSTER_EFFECT_TAG = btnKnight:getTag() + MONSTER_EFFECT_TAG_PREFIX
    local EffectNode = require "app.common.effects.EffectNode"
    local eff = btnKnight:getNodeByTag(MONSTER_EFFECT_TAG)
    local szEffect = "effect_judian_gq"
    if not eff and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        eff = EffectNode.new(szEffect, function(event, frameIndex) end)
        eff:play()
        eff:setPosition(ptPos)
        eff:setVisible(isOpen)
        eff:setScale(3)
        btnKnight:addNode(eff, -3, MONSTER_EFFECT_TAG)
    end 
end

function StoryDungeonGateScene:_addNpcWhisper(labelName)
    local _storydata  = G_Me.storyDungeonData:getStoryDungeon(G_Me.storyDungeonData:getCurrDungeonId())
    if _storydata and not _storydata.is_finished then

        -- 增加当前怪物的对话
        local _data = story_dungeon_info.get(G_Me.storyDungeonData:getCurrDungeonId())
        local tBarrierTmpl = story_barrier_info.get(_data["barrier" .. self.openRoadCurrIndex])
        local szTalk = (tBarrierTmpl and tBarrierTmpl.direction) and tBarrierTmpl.direction or "你是个大笨蛋~"
        local nStartX = labelName:getPositionX()
        local nEndX = self._mapLayer:getContentSize().width / 2
       
        self:_playNPCWhisper(labelName, nStartX, nEndX, ccp(0, 0), szTalk)
    end
end

-- 播放这个NPC的台词
function StoryDungeonGateScene:_playNPCWhisper(tParent, nStartX, nEndX, ptPos, text)
    local NPCWhisper = require("app.scenes.common.NPCWhisper")
    local nDir = 1

    if nStartX < nEndX then
        nDir = NPCWhisper.SPEAK_DIR.LEFT
        ptPos.x = ptPos.x + 30
        ptPos.y = ptPos.y - 100
    else
        nDir = NPCWhisper.SPEAK_DIR.RIGHT
        ptPos.x = ptPos.x - 30
        ptPos.y = ptPos.y - 100
    end

    local szText = text or "" --"宁可我负天下人，不可天下人负我！"
    if not self._tWhisperLayer then
        self._tWhisperLayer = NPCWhisper.create(nDir, szText, NPCWhisper.TYPE_STORYDUNGEON)
        self._tWhisperLayer:setTag(WHISPER_BUBBLE_TAG)
        tParent:addNode(self._tWhisperLayer, 11)
        self._tWhisperLayer:setPosition(ptPos)
    end
end


return StoryDungeonGateScene

