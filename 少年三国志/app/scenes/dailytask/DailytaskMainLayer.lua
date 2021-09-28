
local DailytaskMainLayer = class("DailytaskMainLayer",UFCCSNormalLayer)
require("app.cfg.daily_mission_info")
require("app.cfg.daily_box_info")

local baseTag = 100

function DailytaskMainLayer.create( scene)   
    local layer = DailytaskMainLayer.new("ui_layout/dailytask_dailytaskMainLayer.json",require("app.setting.Colors").modelColor) 
    layer:updateView(scene)
    return layer
end

function DailytaskMainLayer:ctor(...)
    self.super.ctor(self, ...)
    -- self:showAtCenter(true)

    self._taskData = {}

    self:getLabelByName("Label_10"):setText(G_lang:get("LANG_DAILYTASK_SCORE"))
    self:getLabelByName("Label_10"):createStroke(Colors.strokeBrown, 2)
    self._score = self:getLabelByName("Label_jifen") 
    self._score1 = self:getLabelByName("Label_jifen1") 
    self._score2 = self:getLabelByName("Label_jifen2") 
    self._score3 = self:getLabelByName("Label_jifen3") 
    self._score4 = self:getLabelByName("Label_jifen4") 
    self._score:createStroke(Colors.strokeBrown, 2)
    self._score1:createStroke(Colors.strokeBrown, 2)
    self._score2:createStroke(Colors.strokeBrown, 2)
    self._score3:createStroke(Colors.strokeBrown, 2)
    self._score4:createStroke(Colors.strokeBrown, 2)

    self._note1 = self:getLabelByName("Label_tishi1") 
    self._note2 = self:getLabelByName("Label_tishi2") 
    self._note1:setText(G_lang:get("LANG_DAILYTASK_NOTE1"))
    self._note2:setText(G_lang:get("LANG_DAILYTASK_NOTE2"))
    self._note1:createStroke(Colors.strokeBrown, 1)

    self._box1 = self:getImageViewByName("Image_box1")
    self._box2 = self:getImageViewByName("Image_box2")
    self._box3 = self:getImageViewByName("Image_box3")
    self._box4 = self:getImageViewByName("Image_box4")

    self._progress = self:getLoadingBarByName("LoadingBar_Pro")

    self:registerWidgetClickEvent("Image_box1", function ( ... )
      self:_boxClicked(1)
    end)
    self:registerWidgetClickEvent("Image_box2", function ( ... )
      self:_boxClicked(2)
    end)
    self:registerWidgetClickEvent("Image_box3", function ( ... )
      self:_boxClicked(3)
    end)
    self:registerWidgetClickEvent("Image_box4", function ( ... )
      self:_boxClicked(4)
    end)

    self:registerBtnClickEvent("Button_Back", function()
        if self._scene then
            self._scene:_onUpdatedDaytaskButton()
        end
        self:close()
    end)

end

function DailytaskMainLayer:onLayerEnter( )
    -- self:closeAtReturn(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DAILYTASK_GETDAILYMISSION, self._onMission, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DAILYTASK_FINISHDAILYMISSION, self._onGetFinish, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DAILYTASK_GETDAILYMISSIONAWARD, self._onGetAward, self)

    G_HandlersManager.dailytaskHandler:sendGetDailyMission()
end

function DailytaskMainLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function DailytaskMainLayer:updateView(scene)
    self._scene = scene
end

function DailytaskMainLayer:adapterLayer()
  
    self:adapterWidgetHeight("Panel_24", "Panel_10", "", 0, 0)

    self:_initScrollView()
end

function DailytaskMainLayer:_initScrollView()
    self._listView = CCSListViewEx:createWithPanel(self:getPanelByName("Panel_list"), LISTVIEW_DIR_VERTICAL)
    self._listView:setSpaceBorder(0, 40)
    self._listView:setCreateCellHandler(function ( list, index)
        return require("app.scenes.dailytask.DailytaskListCell").new(list, index)
    end)
    self._listView:setUpdateCellHandler(function ( list, index, cell)
        local data = self:_getTaskList()
        if  index < #data then
           cell:updateData(data[index+1]) 
        end
    end)
    self._listView:initChildWithDataLength( 0)
end

local sortFunc = function(a,b)
    local as = G_Me.dailytaskData:getTaskStatus(a.id)
    local bs = G_Me.dailytaskData:getTaskStatus(b.id)
    if  as ~= bs then
        return as > bs
    end
    return a.id < b.id
end

function DailytaskMainLayer:_getTaskList()
    local data = G_Me.dailytaskData:getTask()
    local list = {}
    for key, value in pairs(data) do 
         table.insert(list, #list + 1, value)
    end
    table.sort(list, sortFunc)
    return list
end

function DailytaskMainLayer:_onMission(data)
    -- print("_onMission")
    self._listView:reloadWithLength(#G_Me.dailytaskData:getTask(),0,0.2)
    -- self._listView:refreshAllCell()
    self:_initBox()
end

function DailytaskMainLayer:_refresh()
    self._listView:refreshAllCell()
    self:_initBox()
end

function DailytaskMainLayer:_onGetFinish(data)
    -- print("_onGetFinish")
    if data.ret == 1 then
        self:_refresh()
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
    end
end

function DailytaskMainLayer:_onGetAward(data)
    -- print("_onGetAward")
    if data.ret == 1 then
        self:_refresh()
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
    end
end

function DailytaskMainLayer:_initBox()
    local score = G_Me.dailytaskData:getScore()
    self._score:setText(score)
    local img = G_Me.dailytaskData:getBoxImg()
    -- self._box1:loadTexture(img[1])
    -- self._box2:loadTexture(img[2])
    -- self._box3:loadTexture(img[3])
    local st = G_Me.dailytaskData:getBoxStatus()
    for i = 1,4 do 
        local box = self:getImageViewByName("Image_box"..i)
        box:loadTexture(img[i])
        if st[i] == 2 then
            self:addBoxEffect(box,ccp(10,15))
        else
            self:removeEffect(box)
        end
    end
    
    local per = score/530*111*100/30
    if per > 100 then
        per = 100
    end
    -- self._progress:setPercent(per)
    self._progress:runToPercent(per,0.5)
end

--@desc 添加宝箱特效
function DailytaskMainLayer:addBoxEffect(_parent,pos)
    local tag = baseTag
    _parent = tolua.cast(_parent,"Widget")
    local effectNode = _parent:getNodeByTag(tag)
    if effectNode == nil then
        local EffectNode = require "app.common.effects.EffectNode"
        effectNode = EffectNode.new("effect_box_light", function(event, frameIndex) end)      
        effectNode:play()
        effectNode:setPosition(pos)
        effectNode:setTag(tag)
        effectNode:setScale(0.7)
        _parent:addNode(effectNode,5)
    end

end

--@desc 删除宝箱特效
function DailytaskMainLayer:removeEffect(_parent)
    local tag = baseTag
    _parent = tolua.cast(_parent,"Widget")
    local child = _parent:getNodeByTag(tag)
    if child then
        child:removeFromParentAndCleanup(true)
    end
end

function DailytaskMainLayer:_boxClicked(type)
    local widget = self:getImageViewByName("Image_box"..type)
    -- if self._taskScore >= scoreList[type] then
    --     local pt = widget:getParent():convertToWorldSpace(widget:getPositionInCCPoint())
    --     local boxLayer = require("app.scenes.dailytask.DailytaskBoxLayer").create(widget:getName(),widget:getTag(),widget:getTag(),pt)
    --     uf_notifyLayer:getModelNode():addChild(boxLayer)
    --     boxLayer:_setParentLayer(self)
    -- else

    -- end
    local boxId = G_Me.dailytaskData:getBoxId()
    local pt = widget:getParent():convertToWorldSpace(widget:getPositionInCCPoint())
    local boxLayer = require("app.scenes.dailytask.DailytaskBoxLayer").create(widget:getName(),widget:getTag(),boxId[type],pt)
    -- uf_notifyLayer:getModelNode():addChild(boxLayer)
    uf_sceneManager:getCurScene():addChild(boxLayer)
    boxLayer:_setParentLayer(self)
end

return DailytaskMainLayer

