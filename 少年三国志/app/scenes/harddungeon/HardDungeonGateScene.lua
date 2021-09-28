require("app.cfg.hard_dungeon_chapter_info")
require("app.cfg.hard_dungeon_info")

local _knightPic = require("app.scenes.common.KnightPic")
local HardDungeonGateScene = class("HardDungeonGateScene",UFCCSBaseScene)
local BOXTYPE = require("app.const.BoxType")

local GateType = 
{
    TYPE_MONSTER  = 1,   -- 武将关卡
    TYPE_BOX     = 2    -- 关卡宝箱
}

-- 光卡宝箱状态
local GateBoxStatus = 
{
    STATUS_CLOSE = 1,   -- 关闭状态
    STATUS_OPNE = 2,    -- 开启状态
    STATUS_EMPTY = 3,   -- 空状态
}

local baseTag = 100
local StageNum = 13
local nameTag = 1000000
local haloName = "halo"

local MONSTER_ORDER = 10
local MONSTERNAME_ORDER = 10
-- 是否进入战斗
local isEnter = true

local WHISPER_BUBBLE_TAG = 11111
local MONSTER_EFFECT_TAG_PREFIX = 110

local RIOT_GATE_LAYER_TAG = 557

function HardDungeonGateScene:ctor(stageId, pack, ...)
    self.super.ctor(self,...)
    G_GlobalFunc.savePack(self, pack)

    self.bouns = {}
    -- 叛军
    self.rebel = false
    self._battleInfo = nil
    self._isWin = false
    self.stageId = 0
    self._scrollView = nil
    self._inner = nil
    self._isFirstEnter = true
    
    self.tips = nil
    self._mapLayer = nil 
    
    self.starNode = nil
    
    -- 武将页面快捷进入
    self.quickStageId = stageId
    
    
    self.ChapterId = G_Me.hardDungeonData:getCurrChapterId()
    
    self.effectNode = nil
    -- 记录容器大小
    self._innerSize = {}
    
    --记录当前滑动层容器Y坐标
    self._innerPosY = 0
    -- 记录当前关卡y坐标
    self._currPosY = 0 
    
    -- 记录跳过列表
    self.skipList = {}
    
    -- 是否触发叛军
    self.isHaveRebel = false
    
    -- 是否已经显示新开启章节动画
    self.showNewChapterAction = false

    -- 当前关卡索引
    self.stageIndex = 0

    -- 是否是新开启关卡
    self.newStage = false

    -- 是否新开启宝箱
    self.newBoxIndex = 0

    -- 地图背景图路径
    self.bgPath = nil
    -- 记录scrollView移动距离
    self.moveLength = 0
        -- 是否在播放动画    
    self._layer = CCSNormalLayer:create("ui_layout/dungeon_Hard_DungeonGateScene.json")
    self:addUILayerComponent("DungeonMainGateLayer",self._layer,true)
    
    local data = hard_dungeon_chapter_info.get(G_Me.hardDungeonData:getCurrChapterId())

    self:_loadMap(data.map)  
    self._roleInfo = G_commonLayerModel:getDungeonRoleKongInfoLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    GlobalFunc.flyIntoScreenLR({self._roleInfo}, true, 0.4, 2, 100)
    GlobalFunc.flyIntoScreenLR({self._layer:getWidgetByName("ImageView_Bottom")}, false, 0.4, 2, 100)
    self:setNewestStageIndex()
    self:_init()

    self._layer:registerBtnClickEvent("top",handler(self, self._onClick))
    self._layer:registerBtnClickEvent("Button_BuZhen",handler(self, self._onClick))
    self._layer:registerBtnClickEvent("back",handler(self, self._onClick))
    self._layer:registerBtnClickEvent("copperbox",handler(self, self._onClickBox))
    self._layer:registerBtnClickEvent("silverbox",handler(self, self._onClickBox))
    self._layer:registerBtnClickEvent("goldbox",handler(self, self._onClickBox))

    
    
    self:registerKeypadEvent(true)
    
    --self:scheduleUpdateWithPriorityLua(handler(self,self.update),1)
    -- 快捷通道
--    if stageId ~= nil then
--        if type(stageId) == "number"  and stageId ~= 0 then
--            local _data = hard_dungeon_stage_info.get(stageId) 
--            self:_onChallengesStage(_data.premise_id,stageId)
--        end
--    end

    self._nCurStageId = 1

    -- 地图减小的高度
    self._nMapCurHeight = 400
end

--@desc 设置最新的关卡索引
function HardDungeonGateScene:setNewestStageIndex()
  -- 新关卡id 
  local _list = G_Me.hardDungeonData:getCurrChapterStageList(G_Me.hardDungeonData:getCurrChapterId())
   self.stageIndex = 0
   -- 是否新章节
   self.newStage = G_Me.hardDungeonData:isNewStage()
  local keys = table.keys(_list)
  table.sort(keys)

  for i=1,#keys do
         if _list[keys[i]]._isOpen then
          local _stage_data = hard_dungeon_stage_info.get(keys[i])
              if _stage_data then
                    if _list[keys[i]]._isFinished == false  and _stage_data.type == GateType.TYPE_MONSTER then
                        self.stageIndex = _list[keys[i]].index
                        if self.newBoxIndex ~= self.stageIndex-1 then
                            self.newBoxIndex = 0
                        end
                        break
                    end
                    -- 查找前一关卡是否是宝箱
                    if self.newStage == true then
                        local lastStagedata = hard_dungeon_stage_info.get(_stage_data.premise_id)
                        if  _stage_data.type == GateType.TYPE_BOX then
                            self.newBoxIndex = _stage_data.index
                        end
                    end
              end
         end
  end
    G_Me.hardDungeonData:clearOpenNewStageId()

end

function HardDungeonGateScene:onBackKeyEvent( ... )
    self:_onClick(self._layer:getButtonByName("back"))
    return true
end

-- 显示震屏幕
function HardDungeonGateScene:_showShake()
    if self.shake == nil then
        self.shake = require("app.common.action.Action").newShake(1,0,20)
        self.shake:startWithTarget(self._layer)
    end
        self:scheduleUpdate(handler(self, self._update), 0)
end

function HardDungeonGateScene:_update(dt)
    if self.shake:isDone() == false then
        self.shake:step(1)
    else
        self.shake:stop()
        self:unscheduleUpdate()
    end
end

function HardDungeonGateScene:setScrollEnable( enable )
    if self._mapLayer then 
        self._mapLayer:setIsMove(enable)
    end
end

-- @desc显示剧情对话
-- @param storyid 剧情id
function HardDungeonGateScene:_showStoryTalkLayer(storyid)
--    uf_notifyLayer:getModelNode():addChild(require("app.scenes.harddungeon.HardDungeonStoryTalkLayer").create(storyid))
end




-- 收到关闭秒杀框
function HardDungeonGateScene:_recvCloseSeckillWindows()
    self:_showEnterGateLayer(G_Me.hardDungeonData:getCurrStageId())
end



function HardDungeonGateScene:_loadMap(mapId)
    self._mapLayer = require("app.scenes.harddungeon.HardDungeonMapLayer").create(mapId)
    
    -- 创建小刀特效
    local EffectNode = require "app.common.effects.EffectNode"
    self.tips = EffectNode.new("effect_knife", function(event, frameIndex)
        
    end)
    self.tips:play()
    
    self._mapLayer:addChild(self.tips,MONSTERNAME_ORDER+1)
    self:addChild(self._mapLayer,-1)

end


function HardDungeonGateScene:showSceneEffect()
    -- 加载场景动画
    local bgImg = self._mapLayer:getImageViewByName("ImageView_Bg")
    self.bgPath = bgImg:textureFile()
    local _start,_end = string.find(self.bgPath,"%d-.png")
    local _sceneId = string.sub(self.bgPath,_start,_end-4)
    require("app.cfg.scene_effect_info")
    local data = scene_effect_info.get(1,tonumber(_sceneId))
    local EffectNode = require "app.common.effects.EffectNode"
    local size = self._mapLayer:getContentSize()
    size.height = size.height - self._nMapCurHeight

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

        local size = self._mapLayer:getSize()
        local pos_x =   size.width/2*x
        local pos_y = (size.height - self._nMapCurHeight)/2*y
        return pos_x,pos_y
    end

    if data then
        for i=1,5 do
            if data["effect_" .. i] ~= "0" then
                if data["effect_btype_" .. i] == 1 then
                    local effectNode = EffectNode.new(data["effect_" .. i], function(event, frameIndex) end)
                    effectNode:setPosition(ccp(size.width/2,size.height/2))
                    self._mapLayer:getRootWidget():addNode(effectNode,data["effect_type_" .. i] == 1 and 1 or 20)
                    effectNode:play()
                else
                    local emiter = CCParticleSystemQuad:create("particles/" .. data["effect_" .. i] .. ".plist")
                    local posx,posy = getEffectPosition(data["effect_position_type_" .. i])
                    local pt = ccp(posx,posy)
                    local x,y = 0,0
                    x,y = self._mapLayer:convertToNodeSpaceXY(pt.x,pt.y,x,y)
                    emiter:setPositionXY(x,y)
                    self._mapLayer:addChild(emiter,30)
                end

            end
        end
    end
end

function HardDungeonGateScene:_recvGetBoxBouns(data)
    if data.ret == G_NetMsgError.RET_OK then
        self:_updateBoxStatus()
        self:getChapterBoxBouns(data.ch_id,data.box_type)
    end
end

-- @desc 更新宝箱状态
function HardDungeonGateScene:_updateBoxStatus()
    local _isGetCopperBoxBouns,_isGetSilverBoxBouns,_isGetGoldBoxBouns = 
        G_Me.hardDungeonData:getBoxStuatus(G_Me.hardDungeonData:getCurrChapterId())
    local data = hard_dungeon_chapter_info.get(G_Me.hardDungeonData:getCurrChapterId())
    local _totalStar = G_Me.hardDungeonData:getChapterStar(G_Me.hardDungeonData:getCurrChapterId())

   self:_setBoxShowImage("copperbox",_isGetCopperBoxBouns,_totalStar >= data.copperbox_star, 
       G_Path.DungeonIcoType.COPPERBOX_OPEN,G_Path.DungeonIcoType.COPPERBOX_EMPTY)
   self:_setBoxShowImage("silverbox",_isGetSilverBoxBouns,_totalStar >= data.silverbox_star,
       G_Path.DungeonIcoType.SILVERBOX_OPEN,G_Path.DungeonIcoType.SILVERBOX_EMPTY)
   self:_setBoxShowImage("goldbox",_isGetGoldBoxBouns,_totalStar >= data.goldbox_star,
       G_Path.DungeonIcoType.GOLDBOX_OPEN,G_Path.DungeonIcoType.GOLDBOX_EMPTY)
end

-- @desc 设置宝箱显示图片
-- @param boxName 宝箱名字
-- @param isGet    是否领取
-- @param 
function HardDungeonGateScene:_setBoxShowImage(boxName,isGet,isOpen,openImg,emptyImg)
    if isGet == true then
        local img = self._layer:getButtonByName(boxName) 
        img:loadTextureNormal(emptyImg)
        self:removeEffect(img)
    else
        if isOpen then
            self._layer:getButtonByName(boxName):loadTextureNormal(openImg)
            self:addBoxEffect(self._layer:getButtonByName(boxName),ccp(20,15))
        end
    end
end

--@desc 删除宝箱特效
function HardDungeonGateScene:removeEffect(_parent)
    local tag = baseTag
    _parent = tolua.cast(_parent,"Widget")
    local child = _parent:getNodeByTag(tag)
    if child then
        child:setVisible(false)
        child:removeFromParentAndCleanup(true)
    end
end

--@desc 添加宝箱特效
function HardDungeonGateScene:addBoxEffect(_parent,pos)
    local tag = baseTag
   -- local _parent = _parent:getParent()
    _parent = tolua.cast(_parent,"Widget")
    local effectNode = _parent:getNodeByTag(tag)
    if effectNode == nil then
        local EffectNode = require "app.common.effects.EffectNode"
        effectNode = EffectNode.new("effect_box_light", function(event, frameIndex) end)      
        effectNode:play()
        effectNode:setPosition(pos)
        effectNode:setTag(tag)
        _parent:addNode(effectNode,11)
    end
end

-- @desc 关卡结果
-- @param data 战斗结果
function HardDungeonGateScene:_executeStage(data)
    if data then
        if(data.ret == G_NetMsgError.RET_OK) then
            
        self.bouns.awards = data.awards
        self.bouns.stage_money = data.stage_money
        self.bouns.stage_exp = data.stage_exp
        self.bouns.stage_star = data.stage_star
        self.rebel = data.rebel
    
        local _stage_data = hard_dungeon_stage_info.get(data.id)
            if _stage_data then
                if _stage_data.type == GateType.TYPE_BOX then -- 领取关卡宝箱
                    self:getGateBoxBouns(_stage_data.value)
                    
                    local _name = "box_" .. data.id
                    local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(_stage_data.index))
                    local _boxBtn = _panel:getChildByName(_name)
                    local _data = G_Me.hardDungeonData:getStageById(data.id)
                    if _data._isFinished == true then
                        -- 删除发光特效
                        _boxBtn:loadTextureNormal(G_Path.getBoxPic(GateBoxStatus.STATUS_EMPTY))
                        self:removeEffect(_boxBtn)
                    end
                    --self:_updateStage()
                end
            end  
       end
    end
    --self:_updateStage()
end


-- @desc 进入战斗场景
function HardDungeonGateScene:_enterBattle(data)
    if isEnter == true then
        isEnter = false

    local _skipList = self.skipList[data.id]
    local scene = nil
    G_Loading:showLoading(function ( ... )
    --创建战斗场景
    --pushScene()
        if _skipList == nil then
            _skipList = false
        end
         scene = require("app.scenes.harddungeon.HardDungeonBattleScene").new({_data = data,isSkip = _skipList }, GlobalFunc.getPack(self))
        uf_sceneManager:replaceScene(scene)
    end,
    function ( ... )
        if scene ~= nil then
            scene:play()
        end
        --self.skipList[data.id] = nil
        --开始播放战斗
    end)
    end
end

-- @desc 发送执行副本
function HardDungeonGateScene:_sendExeStage()
-- print("_sendExeStage "..G_Me.hardDungeonData:getCurrStageId())
    G_HandlersManager.hardDungeonHandler:sendExecuteStage(G_Me.hardDungeonData:getCurrStageId())
end

-- @desc 请求战斗
function HardDungeonGateScene:_requestBattle()
    -- 不需要对话机制
    --[[
    local _storyDungeonConst = require("app.const.StoryDungeonConst")
    local _stageData = hard_dungeon_stage_info.get(G_Me.hardDungeonData:getCurrStageId())
    local storytouch = require("app.scenes.storytouch.StoryTouchEvent")
    local isHave,_storyId = storytouch.isHaveStory(_storyDungeonConst.STORYTYPE.TYPE_DUNGEON,_stageData.value,_storyDungeonConst,_storyDungeonConst.TOUCHTYPE.TYPE_FIRSTENTER,nil,_stageData.id)
    if  isHave == true and _storyId then
        self:_showStoryTalkLayer({storyId = _storyId,func = handler(self,self._sendExeStage)})
    else
        self:_sendExeStage()
    end
    ]]

    self:_sendExeStage()
end

function HardDungeonGateScene:onSceneExit()
   uf_eventManager:removeListenerWithTarget(self)
end


function HardDungeonGateScene:onSceneUnload( )
    --uf_eventManager:removeListenerWithTarget(self)
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end

     self:removeComponent(SCENE_COMPONENT_GUI, "RoleInfoUI")

end

function HardDungeonGateScene:_onClick(widget)
   local name = widget:getName()
   if name == "back" then
        local packScene = G_GlobalFunc.createPackScene(self)
        if not packScene then 
            packScene = require("app.scenes.harddungeon.HardDungeonMainScene").new()
        end
        G_Me.hardDungeonData:clearOpenNewStageId()
        G_Me.hardDungeonData:setCurrStageId(0)
        uf_sceneManager:replaceScene(packScene)
   elseif name == "top" then
       self:addChild(require("app.scenes.harddungeon.HardDungeonTopLayer").create())
   elseif name == "Button_BuZhen" then
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
   end
end

-- @desc 设置文本
-- @param widget 要设置的对象
-- @childName 子类名字
-- @txt 文字内容

function HardDungeonGateScene:_setText(widget,childName,txt)
        local _name = widget:getWidgetByName(childName) 
        _name = tolua.cast(_name,"Label")
    if _name then
        _name:setText(txt)
        _name:createStroke(Colors.strokeBrown,1)
        
    end
end

--@desc 播放章节动画

function HardDungeonGateScene:playChapterNameAnimation()
    local _panel = self._layer:getPanelByName("Panel_ChapterName")
    local EffectNode = require "app.common.effects.EffectNode"
    local blinkNode = EffectNode.new("effect_faguang", function(event, frameIndex)
        if event == "finish" then
        elseif event == "appear" then
        end
    end)                  
    blinkNode:play()
    local size = blinkNode:getContentSize()
    blinkNode:setPosition(ccp(-30,20))
    _panel:addNode(blinkNode,1)
end

-- @desc 初始化宝箱数据
function HardDungeonGateScene:_init()
    local data = hard_dungeon_chapter_info.get(G_Me.hardDungeonData:getCurrChapterId())
    if data then
        self._layer:getWidgetByName("copperbox"):setTag(data.copperbox_id)
        self._layer:getWidgetByName("silverbox"):setTag(data.silverbox_id)
        self._layer:getWidgetByName("goldbox"):setTag(data.goldbox_id)
        self:_setText(self._layer,"chaptername",G_lang:get("LANG_DUNGEON_CHPATERNUM",{num=data.id}) .. data.name)
        --self._layer:getImageViewByName("ImageView_1882"):runAction(CCBlink:create(1,3))
        self:playChapterNameAnimation()
        self._layer:getLabelByName("Label_CopperStar"):setText(tostring(data.copperbox_star))
        self._layer:getLabelByName("Label_SilverStar"):setText(tostring(data.silverbox_star))
        self._layer:getLabelByName("Label_GoldStar"):setText(tostring(data.goldbox_star))
        self._layer:getLabelByName("Label_TotalStar"):setText(
         tostring(G_Me.hardDungeonData:getChapterStar(G_Me.hardDungeonData:getCurrChapterId())) .. "/" .. tostring(data.star))
    end
    
    self:_createStroke("Label_CopperStar")
    self:_createStroke("Label_SilverStar")
    self:_createStroke("Label_GoldStar")
    self:_createStroke("Label_TotalStar")
        
    local _list = G_Me.hardDungeonData:getCurrChapterStageList(G_Me.hardDungeonData:getCurrChapterId())

    for i=1,20 do
        local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(i))
        if _panel then
            _panel:setVisible(false)
        else
            break
        end
    end
end

-- @desc 字体描边
function HardDungeonGateScene:_createStroke(labelName)
    self._layer:getLabelByName(labelName):createStroke(Colors.strokeBlack,1)
end

-- @param label 怪物名字文本
-- @param tag stageId
function HardDungeonGateScene:_setMonsterNameColor(label,id,_type)
    require("app.cfg.hard_dungeon_info")
    local _stageData = hard_dungeon_stage_info.get(id)
    if _stageData then
         local dugeon = G_GlobalFunc.getHardDungeonData(_stageData.value) 
         if dugeon then
             if _type == GateType.TYPE_MONSTER then
                if dugeon.difficulty == 1 then              -- 普通怪
                    label:setColor(Colors.qualityColors[1])       -- 白色
                 elseif dugeon.difficulty == 2 then         -- 精英怪
                    label:setColor(Colors.qualityColors[2])           -- 绿色
                 elseif dugeon.difficulty == 3 then         -- boss怪
                    label:setColor(Colors.qualityColors[4])        -- 紫色
                 end
             else
                 label:setColor(ccc3(255,255,0))            -- 黄色
             end
         end
    end
end

-- @desc 用于设置关卡怪物信息
-- @param _panel 怪物底板
-- @param _star 通关星数
-- @param monstername 怪物名字
-- @param _type 关卡类型 1 怪物 2 宝箱
function HardDungeonGateScene:_setMonsterData(_panel,_star,monsterName,_type,isOpen,index)
           
        local widget = self._mapLayer:getChildByTag(_panel:getTag()+nameTag)
        
        if widget == nil then
            widget = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/dungeon_DungeonGateItem.json")
            
            local _pt = self:_getPosByKnight(_panel:getPositionInCCPoint(),_panel:getChildByTag(_panel:getTag()))
            widget:setPosition(_pt)
            widget:setScale(1-0.02*index)
            self._mapLayer:addChild(widget,MONSTERNAME_ORDER,_panel:getTag()+nameTag)
        end
        widget = tolua.cast(widget,"Widget")
        widget:setVisible(isOpen)
        
        local _name = widget:getChildByName("name")
        self:_setMonsterNameColor(_name,_panel:getTag(),_type)
        _name:setVisible(_type == GateType.TYPE_MONSTER)
        _name = tolua.cast(_name,"Label")
        _name:setText(monsterName)
        _name:createStroke(Colors.strokeBlack,1)
        --self:_createStroke("name")
         
        
        if _type == GateType.TYPE_MONSTER then
            local EffectNode = require "app.common.effects.EffectNode"
            local starEffectNode = widget:getNodeByTag(100)
            
            -- 当前关卡id 则显示上一次星星数量
            if _star == nil then _star = 0 end
            local newStarNum = false
            if _panel:getTag() == G_Me.hardDungeonData:getCurrStageId() then
                local lastStarNum = G_Me.hardDungeonData:getCurrStageLastStar()
                if lastStarNum == -1 then
                    G_Me.hardDungeonData:setCurrStageLastStar(_star)
                    lastStarNum = _star
                else
                    if _star > 0 then
                        newStarNum = _star > lastStarNum
                    end
                    _star = lastStarNum
                end
            end
    
            if starEffectNode == nil  then
                starEffectNode = EffectNode.new("effect_" .. _star .. "star", function(event, frameIndex)
                end)   
                starEffectNode:setTag(100)
               --starEffectNode:setPosition(pt)
               local _x = _name:getPositionX()
               local _y = _name:getPositionY()+_name:getContentSize().height
               widget:addNode(starEffectNode,10)
               starEffectNode:setPosition(ccp(_x,_y))
            end
            if newStarNum == true then
                self.starNode = starEffectNode
            end
  
            self:_createMonsterEffect(_panel:getChildByTag(_panel:getTag()), isOpen)
        end
end

-- 创建一个新的星星
function HardDungeonGateScene:createNewStar()
    if self.starNode then 
        local data = G_Me.hardDungeonData:getStageById(G_Me.hardDungeonData:getCurrStageId())
        if data then
            G_Me.hardDungeonData:setCurrStageLastStar(data._star)
            local EffectNode = require "app.common.effects.EffectNode"
            local starEffectNode = EffectNode.new("effect_" .. data._star .. "star_play", function(event, frameIndex)
                if event == "finish" then
                    self:_showAnimation()
                end
            end)   
            starEffectNode:setTag(100)
            starEffectNode:setPosition(self.starNode:getPositionInCCPoint())
            starEffectNode:play()
            self.starNode:getParent():addNode(starEffectNode)
            self.starNode:removeFromParentAndCleanup(true)
            self.starNode = nil
        end

    end
end


function HardDungeonGateScene:_showRebelScene()
    local rebelData = G_Me.hardDungeonData:getRebelData()
    if  rebelData.rebelId > 0  then
            --进入魔神信息界面
        G_GlobalFunc.showRebelDialog(rebelData.rebelId,rebelData.rebelLevel,function() end)
        G_Me.hardDungeonData:setRebelData(0,0)
    end
end

-- @desc设置箱子状态
-- @param widget 箱子对象
-- @param _isOpen 箱子是否打开
-- @param stageId 关卡id
function HardDungeonGateScene:_setGateBoxStatus(widget,_isOpen,stageId,ico,index)    

    local _name = "box_" .. stageId
    local _boxBtn = widget:getChildByName(_name)
    if _boxBtn == nil then
        _boxBtn = Button:create()
        _boxBtn:setTouchEnabled(true)
        _boxBtn:setTag(stageId)
        _boxBtn:setName(_name)
        _boxBtn:setAnchorPoint(ccp(0.5,0)) 
        widget:setScale(1)
        widget:setTag(stageId)
        widget:addChild(_boxBtn,2)
        _boxBtn:setScale(0.8)
        self._mapLayer:registerBtnClickEvent(_name,handler(self, self._onClickMonster))
    end
    
    _boxBtn = tolua.cast(_boxBtn,"Button")
    local _data = G_Me.hardDungeonData:getStageById(stageId)
    if _data._isFinished == true then
        _boxBtn:loadTextureNormal(G_Path.getBoxPic(GateBoxStatus.STATUS_EMPTY))
        self:removeEffect(_boxBtn)
    else
        -- 如果不需要显示路径动画
        if (index ~= self.newBoxIndex and  index < self.stageIndex) or self.stageIndex == 0 then
            _boxBtn:loadTextureNormal(ico, UI_TEX_TYPE_LOCAL)
            if ico == G_Path.getBoxPic(GateBoxStatus.STATUS_OPNE) then
                self:addBoxEffect(_boxBtn,ccp(20,_boxBtn:getContentSize().height/2+15))
            end
        else
            _boxBtn:loadTextureNormal(G_Path.getBoxPic(GateBoxStatus.STATUS_CLOSE), UI_TEX_TYPE_LOCAL)
        end
    end
    _boxBtn:setAnchorPoint(ccp(0.5,0))
end

-- @desc初始化关卡
function HardDungeonGateScene:_updateStage()
    local _list = G_Me.hardDungeonData:getCurrChapterStageList(G_Me.hardDungeonData:getCurrChapterId())

    for k,v in pairs(_list) do
        local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(v.index))
        if _panel then
        _panel:setZOrder(8)
                local pt = _panel:getPositionInCCPoint()
                local  _stage_data = hard_dungeon_stage_info.get(k)
                _stage_data.seen_id = 0
                if  _stage_data.seen_id <= G_Me.hardDungeonData:getCurrStageId() then
                    _panel:setBackGroundColorOpacity(0)
                                         
                    local _isShow = (not v._isOpen   and _stage_data.type == GateType.TYPE_MONSTER)

                    if _stage_data.type == GateType.TYPE_BOX then -- 检查箱子是否已领取
                       self:_setGateBoxStatus(_panel,v._isOpen,k,v.ico,v.index)
                        -- 未开始关卡不显示星级和名字
                        self:_setMonsterData(_panel,v._star,_stage_data.name,
                            _stage_data.type, not _isShow,v.index)
                    else    
                        -- 创建怪物
                        if v._isOpen == true and self.newStage == true and self.stageIndex == v.index then
                            _isShow = false
                        else
                            _isShow = v._isOpen
                        end
                        self:_createMonster(_stage_data,_panel,k,v._star,_isShow,v.index)
                    end
                    _panel:setVisible(true)
                else
                    _panel:setVisible(false)
                end
        end
        
        local data = hard_dungeon_chapter_info.get(G_Me.hardDungeonData:getCurrChapterId())
        self._layer:getLabelByName("Label_TotalStar"):setText(
         tostring(G_Me.hardDungeonData:getChapterStar(G_Me.hardDungeonData:getCurrChapterId())) .. "/" .. tostring(data.star))
         self:_createStroke("Label_TotalStar")
    end
    self:_findTipsPos()


    if self._isFirstEnter == true  then
        self:_showShortcutPos()
        local posY,scale = G_Me.hardDungeonData:getMapLayerPosYAndScale()
        if posY == 100 or self.newStage == true then
            self._mapLayer:setPos(self._currPosY)
            G_Me.hardDungeonData:setMapLayerPosYAndScale(self._mapLayer:getPositionY(),self._mapLayer:getScale())
        else
            self._mapLayer:setPositionY(posY)
            self._mapLayer:setScale(scale)
        end
        self._isFirstEnter = false
    end
end

-- @desc 创建怪物
-- @param _stage_data 关卡信息
-- @param _panel 父节点
-- @param knightId 角色id
-- @param _starNum 星数
-- @param _isShow 是否显示灰度图
function HardDungeonGateScene:_createMonster(_stage_data, _panel,knightId,_starNum,_isShow,index)
    local _knight = _panel:getChildByName("stage_" .. _stage_data.id)
    if _knight == nil then
        _knight = _knightPic.createKnightButton(_stage_data.image, _panel,"stage_" .. _stage_data.id,
            self._mapLayer,handler(self, self._onClickMonster),true)
        _knight:setTag(_stage_data.id)
        _panel:setTag(_stage_data.id)
        _panel:setZOrder(MONSTER_ORDER)
        _knight:setZOrder(5)
    end
    
    -- --侠客呼吸动作
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    EffectSingleMoving.run(_panel, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
    _knight:setVisible(_isShow)
 
    -- 未开始关卡不显示星级和名字
    self:_setMonsterData(_panel,_starNum,_stage_data.name,_stage_data.type,_isShow,index)


end

-- @desc武将出场特效
function HardDungeonGateScene:_showMonsterAction()
    self.newStage = false
    local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(self.stageIndex))
    if _panel == nil then return end

    local  _stage_data = hard_dungeon_stage_info.get(_panel:getTag())
    local _knightBtn = _panel:getChildByName("stage_" .. _panel:getTag())
    local pt = _panel:getPositionInCCPoint()
    local startPt = ccp(0,pt.y)
    if pt.x > self._mapLayer:getContentSize().width/2 then
        startPt.x = self._mapLayer:getContentSize().width
    end

    local x,y =0,0
    x,y=self._mapLayer:convertToWorldSpaceXY(startPt.x,startPt.y,x,y)
    local pt_x,pt_y =0,0
    pt_x,pt_y = self._mapLayer:convertToWorldSpaceXY(pt.x,pt.y,pt_x,pt_y)
    -- pt.y = pt.y + self._mapLayer:getPositionY()*self._mapLayer:getScale()

     local JumpBackCard = require("app.scenes.common.JumpBackCard")
     self.jumpMonster = JumpBackCard.create()
     self._mapLayer:addChild(self.jumpMonster,MONSTERNAME_ORDER)
     self.jumpMonster:play(_stage_data.image, ccp(x,y), _panel:getScale(), ccp(pt_x,pt_y), _panel:getScale(), function() 
            if _knightBtn then    
               _knightBtn:setVisible(true)
            end
            if self.tips then
                self.tips:setVisible(true)
            end           
            self:_showLastMonsterName()
            self.jumpMonster:removeFromParentAndCleanup(true)
            self.jumpMonster = nil
            -- 显示脚底下的特效
            local MONSTER_EFFECT_TAG = _panel:getChildByTag(_panel:getTag()):getTag() + MONSTER_EFFECT_TAG_PREFIX
            local tMonsterEffect = _panel:getChildByTag(_panel:getTag()):getNodeByTag(MONSTER_EFFECT_TAG)
            if tMonsterEffect then
                tMonsterEffect:setVisible(true)
            end
    end )
end

-- 查找Tips位置(其实是小刀特效的位置)
function HardDungeonGateScene:_findTipsPos()
    if self.tips == nil then return end
    
    local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(self.stageIndex))
    local _pt = ccp(0, 0)
    if _panel then
         _pt = self:_getPosByKnight(_panel:getPositionInCCPoint(),_panel:getChildByTag(_panel:getTag()))
         _pt.y = _pt.y + 50
        self.tips:setPosition(_pt)
        if self.stageIndex > 1 then
            local lastPanel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(self.stageIndex-1))
            local  _stage_data = hard_dungeon_stage_info.get(lastPanel:getTag())
            -- 此关卡为宝箱
            if _stage_data and  _stage_data.type == GateType.TYPE_BOX  and self.stageIndex-2 > 0 then
                 lastPanel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(self.stageIndex-2))
            end
            if lastPanel then
                self._currPosY = lastPanel:getPositionY() - 120
            end
        else
            self._currPosY = _panel:getPositionY() - 120
        end
    end
    
    if self.newStage == true or self.stageIndex == 0 then
        self.tips:setVisible(false)
    end

    if self.tips:isVisible() then
        -- NPC台词
        self._nCurStageId = _panel:getTag()
        local nPanelPosX = _panel:getPositionX()
        self:_playNPCWhisper(nPanelPosX, self._mapLayer:getContentSize().width / 2, ccp(_pt.x, _pt.y - 50))
    end
end

-- @desc 设置当前开启关卡位置
function HardDungeonGateScene:_getPosByKnight(pos,_knightPic)
    if _knightPic == nil then return end
    local _size = _knightPic:getContentSize()
    if g_target ~= kTargetWinRT and g_target ~= kTargetWP8 then
        _size = _knightPic:getCascadeBoundingBox(false).size
    end
    local _parent = _knightPic:getParent()
    _h = _size.height*_parent:getScale()
    local _pt = ccp(0,0)
    _pt.y = pos.y+_h
    _pt.x = pos.x
    return _pt
end


function HardDungeonGateScene:onSceneEnter( ... )
--   self:_showStoryTalkLayer(nil)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_ENTERBATTLE, self._enterBattle, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_GETBOUNSSUCC, self._recvGetBoxBouns, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_EXECUTESTAGE, self._executeStage, self)
    --uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_REQUESTBATTLE, self._requestBattle, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_SECKILL, self._recvCloseSeckillWindows, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_UPDATETIPS, self._showTopTips, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_GETSTARBOUNS, self._showTopTips, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_SHOWSHAKE, self._showShake, self)
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_CLOSESUBTITLElAYER,self._updateStage, self)
    -- 暴动
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_RIOT_UPDATE_MAIN_LAYER, self._onEnemyEscaped, self)

    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVE)
    self:_updateBoxStatus()
    
    -- -- 如果没有请求星数排行,则去请求
    -- if G_Me.hardDungeonData:getDungeonStarBounsList() == nil then
    --     G_HandlersManager.hardDungeonHandler:sendFinishChapterAchvRwdInfo()
    -- end
    
    -- -- 已经请求星数排行，查看是否达到新的成就
    -- if G_Me.hardDungeonData:getDungeonStarBounsList() ~= nil then
    --     self:_showTopTips()
    -- end
    
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        self:showSceneEffect()
    end 

    -- 不需要章节开启和结束时的文字介绍
    if G_Me.hardDungeonData:isFirstEnter(G_Me.hardDungeonData:getCurrChapterId()) == false then     
    --  uf_sceneManager:getCurScene():addChild(require("app.scenes.harddungeon.HardDungeonSubtitleLayer").create(self.bgPath))
        G_HandlersManager.hardDungeonHandler:sendFirstEnterChapter(G_Me.hardDungeonData:getCurrChapterId())
    else
        self:_updateStage()
    end      
    self:_updateStage()

    self:createNewStar()
    self:_showRebelScene()

    self:_createMapEffect(self)


    self:_initRiotEvent()
end


-- 设置快捷进入 屏幕拖动位置
function HardDungeonGateScene:_showShortcutPos()
    if self.quickStageId then
        if type(self.quickStageId) == "number" then
            --local _list = G_Me.hardDungeonData:getCurrChapterStageList(G_Me.hardDungeonData:getCurrChapterId())
            for i=1, 5 do
                local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(i))
                if _panel   then
                    if _panel:getTag() == self.quickStageId then
                        -- 精英副本比普通模式的地图要短400
                        self._currPosY = _panel:getPositionY() - 400
                        break
                    end
                else
                    break
                end
            end
        end
    end
end

function HardDungeonGateScene:_showEnterGateLayer(widget)
    local tag = widget:getTag()
    local _data = hard_dungeon_stage_info.get(tag) 

     if _data.type == GateType.TYPE_BOX then -- 关卡宝箱
        local x,y=0,0
        local pt = widget:getPositionInCCPoint()
         x,y = widget:getParent():convertToWorldSpaceXY(pt.x,pt.y,x,y)
        local boxLayer = require("app.scenes.harddungeon.HardDungeonBoxLayer").create(BOXTYPE.DUNGEONGATEBOX, _data.value, tag, ccp(x,y))
        self:addChild(boxLayer,0)    
       boxLayer:_setParentLayer(self)
     else
         self:_onChallengesStage(_data.premise_id,tag)
     end
end

-- 挑战关卡
function HardDungeonGateScene:_onChallengesStage(premise_id,stageId)
    local stage_data = G_Me.hardDungeonData:getStageById(stageId)
    if stage_data._isOpen  then

         self.stageId = stageId
             -- 需要重新拉数据
        if  G_Me.hardDungeonData:isNeedRequestNewData()  then
            uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HARD_DUNGEON_RECVCHAPTERLIST, self._recvChpaterList, self)
            G_HandlersManager.hardDungeonHandler:sendGetChapterListMsg()
        else
            self:addChild(require("app.scenes.harddungeon.HardDungeonEnterGateLayer").create(stageId,stage_data._star,handler(self,self._requestBattle)))
        end
        
        -- 战斗是否跳过
        self.skipList[self.stageId] = stage_data._star == 3
     else -- 没有开启提示通关上一副本
         local _data = hard_dungeon_stage_info.get(premise_id) 
         G_MovingTip:showMovingTip(G_lang:get("LANG_PASSCONDITION") .. _data.name)
     end   
end

-- 点击关卡
function HardDungeonGateScene:_onClickMonster(widget,_type)
--    local boxLayer = require("app.scenes.common.BounsLayer").create({1,2,3})
--    self:addChild(boxLayer)
    if self._mapLayer:getTouchMove() == false  then
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
        self:_showEnterGateLayer(widget)
        isEnter = true
        G_Me.hardDungeonData:setMapLayerPosYAndScale(self._mapLayer:getPositionY(),self._mapLayer:getScale())

        G_Me.hardDungeonData._tAttackState._nChapterId = self.ChapterId
        G_Me.hardDungeonData._tAttackState._nMapPosY = self._mapLayer:getPositionY()
        G_Me.hardDungeonData._tAttackState._nMapScale = self._mapLayer:getScale()
    end

end

function HardDungeonGateScene:_recvChpaterList()
    local stage_data = G_Me.hardDungeonData:getStageById(self.stageId)
    if stage_data then
            local layer = require("app.scenes.harddungeon.HardDungeonEnterGateLayer").create(self.stageId,stage_data._star)
            self:addChild(layer)
    end

end

function HardDungeonGateScene:_onClickBox(widget)
    local name = widget:getName()
    
    local box_Type = BOXTYPE.COPPERBOX
    if name == "silverbox" then -- 银宝箱
        box_Type = BOXTYPE.SIVLERBOX
    elseif name == "goldbox" then   -- 金宝箱
        box_Type = BOXTYPE.GOLDBOX
    end
    
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    local pt = widget:getPositionInCCPoint()
    local x,y=0,0
     x,y=widget:getParent():convertToWorldSpaceXY(pt.x,pt.y,x,y)
    local boxLayer = require("app.scenes.harddungeon.HardDungeonBoxLayer").create(box_Type,widget:getTag(),widget:getTag(),ccp(x,y))
    self:addChild(boxLayer, 0)
    boxLayer:_setParentLayer(self)

end


function HardDungeonGateScene:_showRoadAnimation()
    local index = self.stageIndex
    if self.newBoxIndex > 0 then
        index= self.newBoxIndex
        self.newBoxIndex = 0 
    end
    local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(index))
    if _panel then
     local  _stage_data = hard_dungeon_stage_info.get(_panel:getTag())
         if _stage_data and  _stage_data.type == GateType.TYPE_BOX then
            -- 前置宝箱
                 local btn = _panel:getChildByTag(_panel:getTag())
                if btn then
                 local _list = G_Me.hardDungeonData:getCurrChapterStageList(G_Me.hardDungeonData:getCurrChapterId())
                    btn = tolua.cast(btn,"Button")
                    btn:loadTextureNormal(_list[_panel:getTag()].ico)
                    btn:setAnchorPoint(ccp(0.5,0))
                    self:addBoxEffect(btn,ccp(20,btn:getContentSize().height/2+15))
                end
        else
            if _stage_data and _stage_data.type == GateType.TYPE_MONSTER then
                self:_showMonsterAction()
            end

            if self._timer then
                G_GlobalFunc.removeTimer(self._timer)
                self._timer = nil
            end
        end
    else
             if self._timer then
                G_GlobalFunc.removeTimer(self._timer)
                self._timer = nil
            end
    end  
end
        
-- 显示怪物名字
function HardDungeonGateScene:_showLastMonsterName()
    local _panel = self._mapLayer:getPanelByName("Panel_Stage" .. tostring(self.stageIndex))
    if _panel then
        local _namePanel = self._mapLayer:getChildByTag(_panel:getTag()+nameTag)
        if _namePanel then 
           -- _namePanel:setPosition(self.tips:getPositionInCCPoint())
            _namePanel:setVisible(true) 

            -- NPC台词 
            self._nCurStageId = _panel:getTag()
            self:_playNPCWhisper(_namePanel:getPositionX(), self._mapLayer:getContentSize().width / 2, _namePanel:getPositionInCCPoint())
        end
    end

end

-- 显示动画
function HardDungeonGateScene:_showAnimation()
    --self:_recvStageInfo()
    if self.newStage then
       self._timer = G_GlobalFunc.addTimer(0.3,handler(self,self._showRoadAnimation))
    end


    -- 开启新章节
    if G_Me.hardDungeonData:getOpenNewChapterId() ~= 0 and G_Me.hardDungeonData:getNewChapterAction() == false then 
        G_Me.hardDungeonData:finishNewChapterAction()
        self:_showFinishChapterAction()
    end
    
    if self.rebel == true then
        G_GlobalFunc.showRebelDialog(nil)
    end
end

function HardDungeonGateScene:_showFinishChapterAction()
    -- 章节结束后，会有文字介绍章节结束，这里不需要
--    uf_sceneManager:getCurScene():addChild(require("app.scenes.harddungeon.HardDungeonSubtitleLayer").create(self.bgPath))  
    -- 由于策划设定，打完一个新的章节后，不主动跳出到MainScene中，而是等待玩家点击返回按钮，主动跳出到MainScene  
--    uf_sceneManager:replaceScene(require("app.scenes.harddungeon.HardDungeonMainScene").new())
end

-- @desc 得到金银铜宝箱奖励
-- @param chapter_id 章节宝箱
-- @param box_type 宝箱类型

function HardDungeonGateScene:getChapterBoxBouns(chapter_id,box_type)
    local data = hard_dungeon_chapter_info.get(chapter_id)
    local id = 0
        -- 获取掉落奖励
    if box_type == 1 then       -- 铜宝箱
        id = data.copperbox_id
    elseif box_type == 2 then   -- 银宝箱
        id = data.silverbox_id
    else                        -- 金宝箱
        id = data.goldbox_id
    end
    -- local _dropInfo = drop_info.get(id)
    -- local _list = {}
    -- for i=1,5 do
    --     _list[i] = {type = _dropInfo["type_" .. tostring(i)],value = _dropInfo["value_" .. tostring(i)],
    --     size = _dropInfo["max_num_" .. tostring(i)]}
    -- end
    local _list = G_Drops.convert(id).goodsArray

    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BOX_OPEN)

    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(_list, function ( ... )
        if self.__EFFECT_FINISH_CALLBACK__ then 
            self.__EFFECT_FINISH_CALLBACK__()
        end
    end)

    self:addChild(_layer)
end

-- @desc 关卡宝箱奖励
function HardDungeonGateScene:getGateBoxBouns(value)
    local _dropInfo = drop_info.get(value)
    local _list = {}
    for i=1,5 do
        _list[i] = {type = G_Drops.convertType(_dropInfo["type_" .. tostring(i)]),value = _dropInfo["value_" .. tostring(i)],
        size = _dropInfo["max_num_" .. tostring(i)]}
    end
    
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BOX_OPEN)
    local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(_list, function ( ... )
        if self.__EFFECT_FINISH_CALLBACK__ then 
            self.__EFFECT_FINISH_CALLBACK__()
        end
    end)
    self:addChild(_layer)
end

 -- @desc 提示有奖励
function HardDungeonGateScene:_showTopTips()
--    local _tips = self._layer:getWidgetByName("ImageView_Tips")
--    if _tips then
--        local _starNum = G_Me.hardDungeonData:getAllStar()
--         _tips:setVisible(false)
--        for k=1,dungeon_allstar_info.getLength() do
--            local v = dungeon_allstar_info.indexOf(k)
--            if _starNum >= v.allstar_num then
--                if not G_Me.hardDungeonData:getBounsById(v.id) then
--                    _tips:setVisible(true)
--                end
--            else
--                break
--            end
--        end
--    end
end

-- 播放这个NPC的台词
function HardDungeonGateScene:_playNPCWhisper(nStartX, nEndX, ptPos)
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

    local tStageTmpl = hard_dungeon_stage_info.get(self._nCurStageId)
    local tDungeonInfo = GlobalFunc.getHardDungeonData(tStageTmpl.value)
    local szText = tDungeonInfo and tDungeonInfo.talk or "" --"宁可我负天下人，不可天下人负我！"
    local tWishperBubble = self._mapLayer:getChildByTag(WHISPER_BUBBLE_TAG)
    if not tWishperBubble then
        tWishperBubble = NPCWhisper.create(nDir, szText)
        tWishperBubble:setTag(WHISPER_BUBBLE_TAG)
        self._mapLayer:addChild(tWishperBubble, 11)
        tWishperBubble:setPosition(ptPos)
    end
end

function HardDungeonGateScene:_createMapEffect(scene)
    local SCENE_EFFECT_TAG = 3321
    local EffectNode = require "app.common.effects.EffectNode"
    local eff = scene:getChildByTag(SCENE_EFFECT_TAG)
    if not eff and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        eff = EffectNode.new("effect_fb_yawu", function(event, frameIndex)
            if event == "finish" then
    
            end
        end)
        eff:play()
        local tSize = CCDirector:sharedDirector():getWinSize()
        eff:setPosition(ccp(tSize.width / 2, tSize.height / 2))
        scene:addChild(eff, 0, SCENE_EFFECT_TAG)
    end
end

-- 每个怪物脚底有发光特效
function HardDungeonGateScene:_createMonsterEffect(btnKnight, isOpen)
    if not btnKnight then
        return 
    end
    local nStageId = btnKnight:getTag() or 1
    local tStageTmpl = hard_dungeon_stage_info.get(nStageId)
    local resId = tStageTmpl.image
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

--------------------------------------------------------------------------------------------

function HardDungeonGateScene:_initRiotEvent()
    -- 若敌方援军被击杀，也属于没有了
    local isExistRiot = G_Me.hardDungeonData:checkExistRiotById(G_Me.hardDungeonData:getCurrChapterId())

    if not isExistRiot then
        self._layer:showWidgetByName("Panel_RiotHead", false)
        return
    end

    if isExistRiot and G_Me.hardDungeonData:getShowRiotGateLayer() then
        self:_initRiotKnightHead()
        self:_createRiotGateLayer()
    elseif isExistRiot and not G_Me.hardDungeonData:getShowRiotGateLayer() then
        self:_initRiotKnightHead()
        self._layer:showWidgetByName("Panel_RiotHead", true)
        G_Me.hardDungeonData:setShowRiotGateLayer(false)
    end
end

function HardDungeonGateScene:_createRiotGateLayer()
    local function hideCallback()
        self._layer:showWidgetByName("Panel_RiotHead", true)
    end

    local nChapterId = G_Me.hardDungeonData:getCurrChapterId()
    local tRiotGateLayer = require("app.scenes.harddungeon.riot.RiotGateLayer").create(nChapterId, hideCallback)
    local PanelRiot = self._layer:getPanelByName("Panel_Riot")
    local tSize = PanelRiot:getSize()
    tRiotGateLayer:adapterWithSize(CCSizeMake(tSize.width, tSize.height))
    tRiotGateLayer:setTag(RIOT_GATE_LAYER_TAG)
    self._layer:getPanelByName("Panel_Riot"):addNode(tRiotGateLayer)

    self._layer:showWidgetByName("Panel_RiotHead", false)
end

-- 敌方援军的头像
function HardDungeonGateScene:_initRiotKnightHead()
    local nChapterId = G_Me.hardDungeonData:getCurrChapterId()
    local tRiotChapter = G_Me.hardDungeonData:getRiotChapterById(nChapterId)
    local tRiotDungeonTmpl = hard_dungeon_roit_info.get(tRiotChapter._nRiotId)
    local nResId = (tRiotDungeonTmpl and tRiotDungeonTmpl.image) and tRiotDungeonTmpl.image or 14016
    self._layer:getImageViewByName("ImageView_Icon"):loadTexture(G_Path.getKnightIcon(nResId))
    local szKnightName = (tRiotDungeonTmpl and tRiotDungeonTmpl.name) and tRiotDungeonTmpl.name or ""
    local labelKinghtName = self._layer:getLabelByName("Label_KinghtName")
    local nQuality = (tRiotDungeonTmpl and tRiotDungeonTmpl.quality) and tRiotDungeonTmpl.quality or 1
    if labelKinghtName then
        labelKinghtName:setText(szKnightName)
        labelKinghtName:setColor(Colors.qualityColors[nQuality])
        labelKinghtName:createStroke(Colors.strokeBrown, 1)
    end
    local labelTitle = self._layer:getLabelByName("Label_Title")
    if labelTitle then
        labelTitle:setText(G_lang:get("LANG_HARD_RIOT_ENEMY_RESCUE"))
        labelTitle:createStroke(Colors.strokeBrown, 1)
    end
    local imgFrame = self._layer:getImageViewByName("ImageView_Frame")
    if imgFrame then
        imgFrame:loadTexture(G_Path.getEquipColorImage(nQuality), UI_TEX_TYPE_PLIST)
    end

    -- 特效
    local EffectNode = require "app.common.effects.EffectNode"
    local eff = EffectNode.new("effect_around1", function(event, frameIndex) end)
    self._layer:getImageViewByName("ImageView_Frame"):addNode(eff)
    eff:setScale(1.5)
    local x = eff:getPositionX()
    eff:setPositionX(x+4)
    eff:play()


    -- 点击头像
    self._layer:registerWidgetTouchEvent("ImageView_Frame", handler(self, self._onCreateRiotGateLayer))
end

function HardDungeonGateScene:_onCreateRiotGateLayer(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        self:_createRiotGateLayer()
    end
end

-- 入侵敌军逃跑了
function HardDungeonGateScene:_onEnemyEscaped()
    local isExistRiot = G_Me.hardDungeonData:checkExistRiotById(G_Me.hardDungeonData:getCurrChapterId())
    if not isExistRiot then
        if self._layer:getPanelByName("Panel_RiotHead"):isVisible() then
            -- 弹tips
            G_MovingTip:showMovingTip(G_lang:get("LANG_HARD_RIOT_ENEMY_EVACUATE"))
        end
        local tRiotGateLayer = self._layer:getPanelByName("Panel_Riot"):getNodeByTag(RIOT_GATE_LAYER_TAG)
        if tRiotGateLayer then
            -- 弹tips
            G_MovingTip:showMovingTip(G_lang:get("LANG_HARD_RIOT_ENEMY_EVACUATE"))
            tRiotGateLayer:removeFromParentAndCleanup(true)
        end

        self._layer:showWidgetByName("Panel_RiotHead", false)
    end
end

return HardDungeonGateScene

