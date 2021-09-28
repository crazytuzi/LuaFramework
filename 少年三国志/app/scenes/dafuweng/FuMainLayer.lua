
local FuMainLayer = class("FuMainLayer", UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local FuCommon = require("app.scenes.dafuweng.FuCommon")

function FuMainLayer.create(index)
    return FuMainLayer.new("ui_layout/dafuweng_MainLayer.json", nil,index)
end

function FuMainLayer:ctor(json,fun,index)

    self.super.ctor(self, json)
    
    self._quanNum = self:getLabelByName("Label_quanNum")
    self._quanTitle = self:getLabelByName("Label_quan")
    self._quanTitle:setText(G_lang:get("LANG_FU_QUAN"))
    self._quanTitle:createStroke(Colors.strokeBrown, 1)
    self._quanNum:createStroke(Colors.strokeBrown, 1)
    self._enterButton = self:getButtonByName("Button_go")
    self._addButton = self:getButtonByName("Button_add")
    self._quanNum:setVisible(false)
    self._quanTitle:setVisible(false)
    self._addButton:setVisible(false)
    self:getImageViewByName("Image_quanIcon"):setVisible(false)

    self:attachImageTextForBtn("Button_go","Image_15")

    --根据活动ID定义
    self._timeStart0 = false     --奇门八卦
    self._timeStart1 = false     --幸运转盘
    self._timeStart2 = false     --巡游探宝

    self._firstIndex = index or -1

    -- self:initScrollView()
    self._effect = nil

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
        self._effect = EffectNode.new("effect_fjtx")     
        self._effect:play()
        local panel = self:getPanelByName("Panel_1")
        local size = panel:getContentSize()
        local offset = display.height-960
        local posy = offset>0 and size.height/2+offset or size.height/2
        self._effect:setPosition(ccp(size.width/2,posy))
        panel:addNode(self._effect,1)
    end

    self:registerBtnClickEvent("Button_help", function()
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_FU_HELP_TITLEMAIN"), content=G_lang:get("LANG_FU_HELP_CONTENTMAIN")},
            } )
    end)
    self:registerBtnClickEvent("Button_back", function()
        -- uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_go", function()
        self:enterGame()
    end)
    self:registerBtnClickEvent("Button_add", function()
        require("app.scenes.common.PurchaseScoreDialog").show(24)
    end)
end

-- function FuMainLayer:onBackKeyEvent( ... )
--     uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())

--     return true
-- end

function FuMainLayer:onBackKeyEvent( ... )
    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.mainscene.MainScene")
    end

    return true
end

function FuMainLayer:onLayerEnter()
    self.super:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WHEEL_INFO, self.updateItems, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_INFO, self.updateItems, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TRIGRAMS_UPDATE_INFO, self.updateItems, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagChanged, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._buyRes, self)

    G_HandlersManager.wheelHandler:sendWheelInfo()
    G_HandlersManager.richHandler:sendRichInfo()
    G_HandlersManager.trigramsHandler:sendGetTrigramsInfo()

    self._moving = false
    -- self:updateView()

    self:_refreshTimeLeft()
    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end
end


function FuMainLayer:onLayerExit()

    --释放特效
    if self._effect then
        self._effect:removeFromParentAndCleanup(true)
        self._effect = nil
    end

    self.super:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
    uf_eventManager:removeListenerWithTarget(self)
end

function FuMainLayer:_refreshTimeLeft()

    --self:updateButtons() --没用

    local time0 = G_Me.trigramsData:getTimeLeft()
	if time0 < 0 then
        return
    end
    if self._timeStart0 then
        self:updateItems()
        self._timeStart0 = false
    end
    if time0 < 1 then
        self._timeStart0 = true
        if G_Me.trigramsData:getState() == FuCommon.STATE_OPEN then
            G_HandlersManager.trigramsHandler:sendGetRankList()
        end
        if G_Me.trigramsData:getState() == FuCommon.STATE_AWARD then
            G_HandlersManager.trigramsHandler:sendGetTrigramsInfo()
        end
    end

    local time1 = G_Me.wheelData:getTimeLeft()
    if time1 < 0 then
        return
    end
    if self._timeStart1 then
        self:updateItems()
        self._timeStart1 = false
    end
    if time1 < 1 then
        self._timeStart1 = true
        if G_Me.wheelData:getState() == FuCommon.STATE_OPEN then
            G_HandlersManager.wheelHandler:sendWheelRankingList()
        end
        if G_Me.wheelData:getState() == FuCommon.STATE_AWARD then
            G_HandlersManager.wheelHandler:sendWheelInfo()
        end
    end

    local time2 = G_Me.richData:getTimeLeft()
	if time2 < 0 then
        return
    end
    if self._timeStart2 then
        self:updateItems()
        self._timeStart2 = false
    end
    if time2 < 1 then
        self._timeStart2 = true
        if G_Me.richData:getState() == FuCommon.STATE_OPEN then
            G_HandlersManager.richHandler:sendRichRankingList()
        end
        if G_Me.richData:getState() == FuCommon.STATE_AWARD then
            G_HandlersManager.richHandler:sendRichInfo()
        end
    end


end

function FuMainLayer:updateItems()
    if self._scrollLayer then
        self._scrollLayer:refreshItems()
    end
end

function FuMainLayer:_bagChanged(data)
    self:updateBase()
end

function FuMainLayer:_buyRes(data)
    if data.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR0 then
        G_HandlersManager.wheelHandler:sendWheelInfo()
        G_HandlersManager.richHandler:sendRichInfo()
        G_HandlersManager.trigramsHandler:sendGetTrigramsInfo()
    end
end

function FuMainLayer:updateButtons()
    --local state = (G_Me.wheelData:getState() == 3) and (G_Me.richData:getState() == 3)
    -- self._addButton:setVisible(not state)
end

function FuMainLayer:onLayerExit()
    
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
end

function FuMainLayer:enterGame()
    if self._moving then
        return
    end

    local id = self._scrollLayer:getChoosed()

    if id == FuCommon.TRIGRAMS_TYPE_ID then
    	if G_Me.trigramsData:getState() == FuCommon.STATE_CLOSE then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
            return 
        end
        if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TRIGRAMS) == true then
            uf_sceneManager:replaceScene(require("app.scenes.trigrams.TrigramsScene").new())
            return
        end
    elseif id == FuCommon.WHEEL_TYPE_ID then
        if G_Me.wheelData:getState() == FuCommon.STATE_CLOSE then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
            return 
        end
        if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.WHEEL) == true then
            uf_sceneManager:replaceScene(require("app.scenes.wheel.WheelScene").new())
            return
        end
    elseif id == FuCommon.RICH_TYPE_ID then
       if G_Me.richData:getState() == FuCommon.STATE_CLOSE  then
           G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
           return 
       end
       if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.RICHMAN) == true then
           uf_sceneManager:replaceScene(require("app.scenes.dafuweng.RichScene").new())
           return
       end
    elseif id == FuCommon.RECHARGE_TYPE_ID then
       if not G_Me.rCardData:isOpen() then
           G_MovingTip:showMovingTip(G_lang:get("LANG_FU_NOACT"))
           return 
       end
       if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.CHANGE_CARD) == true then
           uf_sceneManager:replaceScene(require("app.scenes.dafuweng.RCardScene").new())
           return
       end
    end
    -- 要记得在主界面的入口增加显示的判断
    -- 要记得在主界面的入口增加显示的判断
    -- 要记得在主界面的入口增加显示的判断
end

function FuMainLayer:updateView()
    self:updateBase()
    self:updateButton()
    -- self:updateScrollView()
end

function FuMainLayer:updateBase()
    self._quanNum:setText(G_Me.wheelData:getCurQuanNum())
end

function FuMainLayer:updateButton()
    if self._scrollLayer then
        self._enterButton:setTouchEnabled(true)
    end
end

function FuMainLayer:initScrollView()
    if self._scrollLayer == nil then
        local list = self:createList()
        -- dump(list)
        self._scrollLayer = require("app.scenes.dafuweng.FuScrollLayer").create(list)
        local size = self:getPanelByName("Panel_middle"):getContentSize()
        -- print("size "..size.height)
        self._scrollLayer:setContainer(self)
        self._scrollLayer:setContentHeight(size.height)
        self:getPanelByName("Panel_middle"):addNode(self._scrollLayer)
        self._scrollLayer:setCallBack(self,self._moveStart,self._moveEnd)
    end
end

function FuMainLayer:createList()
    local list = {}
    local state = {FuCommon.STATE_OPEN, FuCommon.STATE_AWARD, FuCommon.STATE_CLOSE}
    
    if self._firstIndex >= 0 then
        table.insert(list,#list+1,self._firstIndex)
    end
    if self._firstIndex ~= FuCommon.RECHARGE_TYPE_ID then
        if G_Me.rCardData:isOpen() then
            table.insert(list,#list+1,FuCommon.RECHARGE_TYPE_ID)
        end
    end
    for i = 1 , FuCommon.TYPE_ID_MAX do
    	--暂时让奇门八卦放最前面

        if G_Me.trigramsData:getState() == state[i] and self._firstIndex ~= FuCommon.TRIGRAMS_TYPE_ID then
            table.insert(list,#list+1,FuCommon.TRIGRAMS_TYPE_ID)
        end

        if G_Me.richData:getState() == state[i] and self._firstIndex ~= FuCommon.RICH_TYPE_ID then
            table.insert(list,#list+1,FuCommon.RICH_TYPE_ID)
        end
        
        if G_Me.wheelData:getState() == state[i] and self._firstIndex ~= FuCommon.WHEEL_TYPE_ID then
            table.insert(list,#list+1,FuCommon.WHEEL_TYPE_ID)
        end

    end
    if self._firstIndex ~= FuCommon.RECHARGE_TYPE_ID then
        if not G_Me.rCardData:isOpen() then
            table.insert(list,#list+1,FuCommon.RECHARGE_TYPE_ID)
        end
    end

    return list
end

function FuMainLayer:_moveStart()
    -- print("_moveStart")
    self._moving = true
    self._enterButton:setTouchEnabled(false)
end

function FuMainLayer:_moveEnd()
    -- print("_moveEnd")
    self._moving = false
    self._enterButton:setTouchEnabled(true)
    self:updateButton()
end

function FuMainLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_middle", "Panel_top", "Panel_buttom", -52, -13)
    self:initScrollView()
    self:updateView()
end

return FuMainLayer

