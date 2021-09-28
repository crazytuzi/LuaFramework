
local WushFasterLayer = class("WushFasterLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.dead_battle_info")

function WushFasterLayer:ctor(json,color)
    self.super.ctor(self, json,color)
    self:showAtCenter(true)
    self._itemList = {}
    self._finish = false
    self._curFloor = 0
    self._totalHeight = 0

    self:initWidgets()
end

function WushFasterLayer:initWidgets( )
    self._doubleLabel = self:getLabelByName("Label_double")
    self._doubleLabel:createStroke(Colors.strokeBrown, 1)
    self._fightLabel = self:getLabelByName("Label_fighting")
    self._finishButton =  self:getButtonByName("Button_finish")
    self._finishImg =  self:getImageViewByName("Image_finish")
    self._closeButton =  self:getButtonByName("Button_close")
    self._scrollView =  self:getScrollViewByName("ScrollView_List")
    self._finishImg:loadTexture("ui/text/txt-big-btn/saodangwancheng.png")
    self:getImageViewByName("Image_title"):loadTexture("ui/text/txt-title/sanxingsaodang.png")
    local node = EffectNode.new("effect_around2")     
    node:setScale(1.8) 
    node:setPosition(ccp(0,-2))
    node:play()
    -- node:setVisible(false)
    self._finishButton:addNode(node)
    self._effectNode = node

    self._doubleLabel:setVisible(G_Me.activityData.custom:isWushActive())
    self._fightLabel:setText(G_lang:get("LANG_WUSH_FAST_TIPS",{floor=G_Me.wushData:getFastMax()}))

    self:registerBtnClickEvent("Button_finish", function()
        if self._finish then
            self:onBack()
        else
            self._finish = true
            self:updateView()
        end
    end)
    self:registerBtnClickEvent("Button_close", function()
        self:onBack()
    end)
end

function WushFasterLayer.create(func)
    local layer = WushFasterLayer.new("ui_layout/wush_fastLayer.json",require("app.setting.Colors").modelColor) 
    layer:setFunc(func)
    return layer
end

function WushFasterLayer:setFunc(func)
    self._func = func
end

function WushFasterLayer:onLayerEnter( )
    self:registerKeypadEvent(true)
    EffectSingleMoving.run(self:getWidgetByName("Image_bg"), "smoving_bounce")
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_CHALLENGE_REPORT, self._onChallengeReportRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_GET_BUFF, self._onWushBuffRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_APPLY_BUFF, self._onBuffApply, self)
    
    if G_Me.wushData:needBuff() then
        G_HandlersManager.wushHandler:sendWushGetBuff()
    else
        G_HandlersManager.wushHandler:sendWushChallenge(2,true,false)
    end
    -- G_HandlersManager.wushHandler:sendWushChallenge(2,true,false)
    self:updateView()
end

function WushFasterLayer:onBack()
    self._finish = true
    if self._func then
        self._func()
    end

    self:animationToClose()

    return true
end

function WushFasterLayer:onBackKeyEvent()
    self:onBack()
    return true
end
 
function WushFasterLayer:_onWushBuffRsp( data )
    local list = G_Me.wushData:getBuffToChoose()
    if not self._finish then
        local star = G_Me.wushData:getStarCur()
        local index = math.floor(star/3)
        if index <= 0 then
            return
        end
        if index > 3 then
            index = 3 
        end
        G_Me.wushData:setBuffToChooseIndex(index)
        G_HandlersManager.wushHandler:sendWushApplyBuff(list[index])
    end
end

function WushFasterLayer:_onBuffApply( data )
    if data.ret == NetMsg_ERROR.RET_OK then
        self:updateBuff(data.buff_id)
        -- if G_Me.wushData:getFloor() > G_Me.wushData:getFastMax() then
        --     self._finish = true
        --     self:updateView()
        -- else
        --     G_HandlersManager.wushHandler:sendWushChallenge(2,true,false)
        -- end
    end
end

function WushFasterLayer:_onChallengeReportRsp( data)
    if data.ret == NetMsg_ERROR.RET_OK then
        self:showList(data)
    end
end


function WushFasterLayer:updateView()
    -- self._closeButton:setVisible(self._finish)
    self._finishButton:setVisible(self._finish)
    self._fightLabel:setVisible(not self._finish)
    -- self._curFloor = G_Me.wushData:getFloor()
    -- self._effectNode:setVisible(self._finish)
    -- self._finishImg:loadTexture(self._finish and "ui/text/txt-big-btn/saodangwancheng.png" or "ui/text/txt-big-btn/tingzhitiaozhan.png")
end

function WushFasterLayer:showList( data)
    local floor = G_Me.wushData:getFloor()
    floor = floor - 1
    local item = require("app.scenes.wush.WushFastCell").new()
    item:updateView(floor,data,true)
    table.insert(self._itemList,#self._itemList+1,item)
    self._scrollView:addChild(item)
    local size = item:getContentSize()
    self._totalHeight = self._totalHeight + size.height
    self:itemMove()
    item:start(function ( )
        if floor%3 == 0 then
            self:updateAward()
        else
            if floor >= G_Me.wushData:getFastMax() then
                self._finish = true
                self:updateView()
            elseif not self._finish then
                G_HandlersManager.wushHandler:sendWushChallenge(2,true,false)
            end
        end
    end)
end

function WushFasterLayer:updateAward()
    local floor = G_Me.wushData:getFloor() - 1
    local item = require("app.scenes.wush.WushFastAward").new()
    item:updateView(floor)
    table.insert(self._itemList,#self._itemList+1,item)
    self._scrollView:addChild(item)
    local size = item:getContentSize()
    self._totalHeight = self._totalHeight + size.height
    self:itemMove()
    item:start(function ( )
        if not self._finish then
            G_HandlersManager.wushHandler:sendWushGetBuff()
        end
    end)
end

function WushFasterLayer:updateBuff(buff_id)
    local floor = G_Me.wushData:getFloor() - 1
    local item = require("app.scenes.wush.WushFastCell").new()
    item:updateBuff(buff_id)
    table.insert(self._itemList,#self._itemList+1,item)
    self._scrollView:addChild(item)
    local size = item:getContentSize()
    self._totalHeight = self._totalHeight + size.height
    self:itemMove()
    item:start(function ( )
        if G_Me.wushData:getFloor() > G_Me.wushData:getFastMax() then
            self._finish = true
            self:updateView()
        else
            if not self._finish then
                G_HandlersManager.wushHandler:sendWushChallenge(2,true,false)
            end
        end
    end)
end

function WushFasterLayer:itemMove()
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


function WushFasterLayer:onLayerExit()

end

function WushFasterLayer:onLayerUnload( ... )

end

return WushFasterLayer
