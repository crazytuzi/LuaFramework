
local WushFastLayer = class("WushFastLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.dead_battle_info")

function WushFastLayer:ctor(jsonFile)
    self.super.ctor(self, jsonFile)
    self:showAtCenter(true)
    -- self:setClickClose(true)
    self._itemList = {}
    self._finish = false
    -- self._curFloor = 0
    self._totalHeight = 0

    self._doubleLabel = self:getLabelByName("Label_double")
    self._doubleLabel:createStroke(Colors.strokeBrown, 1)
    self._fightLabel = self:getLabelByName("Label_fighting")
    self._finishButton =  self:getButtonByName("Button_finish")
    self._closeButton =  self:getButtonByName("Button_close")
    self._scrollView =  self:getScrollViewByName("ScrollView_List")

    local node = EffectNode.new("effect_around2")     
    node:setScale(1.8) 
    node:setPosition(ccp(0,-2))
    node:play()
    self._finishButton:addNode(node)

    self._doubleLabel:setVisible(G_Me.activityData.custom:isWushActive())

    self:registerBtnClickEvent("Button_finish", function()
        if self._func then
            self._func()
        end
        self:animationToClose()
    end)
    self:registerBtnClickEvent("Button_close", function()
        if self._func then
            self._func()
        end
        self:animationToClose()
    end)
end

function WushFastLayer.create(func,...)
    local layer = WushFastLayer.new("ui_layout/wush_fastLayer.json",require("app.setting.Colors").modelColor,...) 
    layer:setFunc(func)
    return layer
end

function WushFastLayer:setFunc(func)
    self._func = func
end

function WushFastLayer:onLayerEnter( )
    EffectSingleMoving.run(self:getWidgetByName("Image_bg"), "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_CHALLENGE_REPORT, self._onChallengeReportRsp, self)
    G_HandlersManager.wushHandler:sendWushChallenge(2,false,false)
    self:updateView()
end
 
-- function WushFastLayer:onBackKeyEvent( ... )
--     self:close()
--     return true
-- end

function WushFastLayer:_onChallengeReportRsp( data)
    if data.ret == 1 then
        self:showList(data)
    end
end


function WushFastLayer:updateView()
    self._closeButton:setVisible(self._finish)
    self._finishButton:setVisible(self._finish)
    self._fightLabel:setVisible(not self._finish)
    -- self._curFloor = G_Me.wushData:getFloor()
end

function WushFastLayer:showList( data)
    local floor = G_Me.wushData:getFloor()
    local win = data.battle_report.is_win
    -- local win = true
    floor = win and floor - 1 or floor
    local item = require("app.scenes.wush.WushFastCell").new()
    item:updateView(floor,data,data.battle_report.is_win)
    table.insert(self._itemList,#self._itemList+1,item)
    self._scrollView:addChild(item)
    local size = item:getContentSize()
    self._totalHeight = self._totalHeight + size.height
    self:itemMove()
    item:start(function ( )
        if not win then
            self._finish = true
            self:updateView()
        elseif floor%3 == 0 then
            self._finish = true
            self:updateView()
            self:updateAward()
        else
            G_HandlersManager.wushHandler:sendWushChallenge(2,false,false)
        end
    end)
end

function WushFastLayer:updateAward()
    local floor = G_Me.wushData:getFloor() - 1
    local item = require("app.scenes.wush.WushFastAward").new()
    item:updateView(floor)
    table.insert(self._itemList,#self._itemList+1,item)
    self._scrollView:addChild(item)
    local size = item:getContentSize()
    self._totalHeight = self._totalHeight + size.height
    self:itemMove()
    item:start(function ( )
        self._finish = true
        self:updateView()
    end)
end

function WushFastLayer:itemMove()
    local size = self._scrollView:getContentSize()
    local height = size.height
    height = height > self._totalHeight and height or self._totalHeight
    self._scrollView:setInnerContainerSize(CCSize(size.width,height))
    for k , v in pairs(self._itemList) do
        local size = v:getContentSize()
        height = height - size.height
        v:setPosition(ccp(0,height))
    end    
    self._scrollView:scrollToPercentVertical(100,0.02,false)
end


function WushFastLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushFastLayer:onLayerUnload( ... )

end

return WushFastLayer
