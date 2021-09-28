
require("app.cfg.battlefield_info")
require("app.cfg.battlefield_award_info")
require("app.cfg.battlefield_position_info")

require("app.const.ShopType")
require("app.cfg.knight_info")

local CrusadeCommon = require("app.scenes.crusade.CrusadeCommon")

local FunctionLevelConst = require("app.const.FunctionLevelConst")
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local CrusadeMainLayer = class("CrusadeMainLayer",UFCCSNormalLayer)

local BF_MAXLINE = 18  -- 需要点亮的线条最大数 

function CrusadeMainLayer:adapterLayer()
    self:adapterWidgetHeight("ScrollView_Stage", "Panel_Top", "Panel_Bottom", 0, 0)
end


function CrusadeMainLayer.create(scenePack,... )
    return CrusadeMainLayer.new("ui_layout/crusade_MainLayer.json",scenePack)
end

function CrusadeMainLayer:_createStrokes( ... )
    
    self:enableLabelStroke("Label_Score", Colors.strokeBrown, 2)
    self:enableLabelStroke("Label_ScoreValue", Colors.strokeBrown, 2)
    self:enableLabelStroke("Label_Treasure", Colors.strokeBrown, 2)

    self:enableLabelStroke("Label_LeftChallenge", Colors.strokeBrown, 1)
    self:enableLabelStroke("Label_LeftChaTimes", Colors.strokeBrown, 1)
    self:enableLabelStroke("Label_FreeReset", Colors.strokeBrown, 1)

    self:enableLabelStroke("Label_ResetZero", Colors.strokeBrown, 1)
    self:enableLabelStroke("Label_ResetCost", Colors.strokeBrown, 1)
    self:enableLabelStroke("Label_ResetYB", Colors.strokeBrown, 1)
    self:enableLabelStroke("Label_FreeResetNum", Colors.strokeBrown, 1)


end

function CrusadeMainLayer:_initView()
    
    self:getLabelByName("Label_ResetYB"):setText(G_lang:get("LANG_CRUSADE_RESET_YUANBAO"))
    self:getLabelByName("Label_Treasure"):setText(G_lang:get("LANG_CRUSADE_TREASURE_TITLE"))
    self:getLabelByName("Label_Score"):setText(G_lang:get("LANG_CRUSADE_PET_SCORE"))

    self._resetZero:setText(G_lang:get("LANG_CRUSADE_ZERO_RESET"))

    self._treasureName:setText("")
    self._currentScore:setText("")
    self._challengeNum:setText("")
    self._resetCost:setText("")
    self._freeResetNum:setText("")

    self._stageScrollView:setVisible(false)

    self:_showShopTip()
    self:_showTreasureTip() 

    for i=1, self._maxStage do
        local stageImage = self:getImageViewByName("Image_Stage"..i)
        local stageItem = require("app.scenes.crusade.CrusadeStageItem").new(i, stageImage)
        stageItem:setVisible(false)
        self._stageItems[i] = stageItem

    end

    for i=1, BF_MAXLINE do
        local lineImage = self:getImageViewByName("Image_line"..i)
        local lineItem = require("app.scenes.crusade.CrusadeLineItem").new(i, lineImage)
        lineItem:setVisible(false)
        self._lineItems[i] = lineItem
    end

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
        local effect  = EffectNode.new("effect_ST")
        effect:play()
        local widget = self:getPanelByName("Panel_treasureEffect")
        if widget then 
            effect:setScaleX(1.1)
            effect:setPositionXY(0, 70)
            widget:addNode(effect)
            effect:setTag(1000)
        end
    end

end


function CrusadeMainLayer:ctor(jsonFile, scenePack, ...)

    self._crusadeHeroes = {}   
    self._stageItems = {}
    self._lineItems = {}

    --关卡总数
    self._maxStage = battlefield_info.getLength()
    --每关对手数
    self._maxGate = battlefield_position_info.getLength()

    self._addPetPoints = 0
    self._delayUpdateView = false
    self._scrollViewOffsetY = 0

    self.super.ctor(self)
    self:adapterWithScreen()

    self._treasureName = self:getLabelByName("Label_Treasure")
    self._currentScore = self:getLabelByName("Label_ScoreValue")
    self._challengeNum = self:getLabelByName("Label_LeftChaTimes")
    self._resetCost = self:getLabelByName("Label_ResetCost")

    self._resetPanel = self:getPanelByName("Panel_Reset")
    self._freeReset = self:getLabelByName("Label_FreeReset")
    self._freeResetNum = self:getLabelByName("Label_FreeResetNum")
    self._resetZero = self:getLabelByName("Label_ResetZero")
    
    self._stageScrollView = self:getScrollViewByName("ScrollView_Stage")
    self._stageScrollView:setClippingEnabled(false)   --避免背景图被裁剪

    self._resetButton = self:getButtonByName("Button_Reset")
    self._nextButton = self:getButtonByName("Button_Next")

    self._nextButton:runAction(CCRepeatForever:create(
        CCSequence:createWithTwoActions(CCScaleTo:create(1,1.1), CCScaleTo:create(1,1))))
    G_GlobalFunc.savePack(self, scenePack)
    
    self:_createStrokes()
    self:_initView()

end

function CrusadeMainLayer:_onBackKeyEvent( ... )


    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.mainscene.PlayingScene")
    end
 

end

function CrusadeMainLayer:_onHelpClicked( ... )
    
    require("app.scenes.common.CommonHelpLayer").show(
        {
            {title = G_lang:get("LANG_CRUSADE_HELP_TITLE_1"), content = G_lang:get("LANG_CRUSADE_HELP_CONTENT_1")},
        })
    
end

function CrusadeMainLayer:onClickTreasure()  

    --已通关，并开启所有宝藏，
    if G_Me.crusadeData:hasPassStage() and G_Me.crusadeData:getLeftOpenTreasureTimes() == 0  then
        --通过所有关  
        if G_Me.crusadeData:getCurStage() == self._maxStage then
            G_MovingTip:showMovingTip(G_lang:get("LANG_CRUSADE_PASS_ALL_STAGE"))
        else      
            local box = require("app.scenes.tower.TowerSystemMessageBox")
                box.showSpecialMessage( G_lang:get("LANG_CRUSADE_NEXT_STAGE"), 
                function()
                    --G_Me.crusadeData:initData()
                    G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_NEXT)
                end,
                function() end, 
                self )
        end
    else
        local preview = require("app.scenes.crusade.CrusadeTreasurePreview").create(function()
            -- body
            end)
    
        uf_sceneManager:getCurScene():addChild(preview)
    end
end

function CrusadeMainLayer:onLayerLoad( ... )

    self.super:onLayerLoad()
    
    self:registerBtnClickEvent("Button_Back", function()
        self:_onBackKeyEvent()
    end)

    self:registerBtnClickEvent("Button_Help", function()
        self:_onHelpClicked()
    end)

    self:registerBtnClickEvent("Button_Treasure", function()
        self:onClickTreasure()
    end)

    self:registerBtnClickEvent("Button_Rank", function()
        require("app.scenes.crusade.CrusadeRankListLayer").show()
    end)

    self:registerBtnClickEvent("Button_Shop", function()
        local FunctionLevelConst = require "app.const.FunctionLevelConst"
        local result = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET_SHOP)
        if result then
            uf_sceneManager:replaceScene(require("app.scenes.pet.shop.PetShopScene").new(nil, nil, nil, nil, GlobalFunc.sceneToPack("app.scenes.crusade.CrusadeScene")))
        end
    end)

    self:registerBtnClickEvent("Button_Reset", function()
        self:_onReset()
    end)

    self:registerBtnClickEvent("Button_Next", function()
        self:_onNext()
    end)

end

function CrusadeMainLayer:onLayerEnter( ... )

    self:registerKeypadEvent(true)

    self._delayUpdateView = false

    --uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_FLUSH_DATA, self._updatePoints, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_BATTLEFIELD_INFO, self._onUpdateView, self)
    --uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_FLUSH_BATTLEFIELD_INFO, self._onUnlockHeroes, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_CHALLENGE_REPORT, self._onChallengeReport, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_AWARD_INFO, self._onOpenTreasure, self)
    
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_Header")}, true, 0.2, 2, 100)
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_BottomInfo")}, true, 0.2, 2, 100)

    --第二天重新拉数据
    if G_Me.crusadeData:isNeedRequestNewData() then
        G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_INIT)
    end

end


function CrusadeMainLayer:onLayerUnload( ... ) 

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then 
        local widget = self:getPanelByName("Panel_treasureEffect")
        if widget then 
            widget:removeNodeByTag(1000)
        end
    end

    for index = 1, self._maxGate do 
        self._crusadeHeroes[index]:destory()
    end

    self._nextButton:stopAllActions()
    self._resetButton:stopAllActions()

    self.super:onLayerUnload()
end

function CrusadeMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


function CrusadeMainLayer:_showShopTip()
    self:getImageViewByName("Image_shopTips"):setVisible(G_Me.shopData:shouldShowPetShop())
end

function CrusadeMainLayer:_showTreasureTip()
    self:getImageViewByName("Image_TreasureTips"):setVisible(G_Me.crusadeData:canOpenTreasureFree())
end


function CrusadeMainLayer:_updateProgressBar()

    for i=1, self._maxStage do
        self._stageItems[i]:updateState()
    end

end

function CrusadeMainLayer:_updateLines()
    for i=1, BF_MAXLINE do
        self._lineItems[i]:updateLight(i)
    end
end


function CrusadeMainLayer:_updateResetStatus()

    self._resetPanel:setVisible(false)
    self._resetZero:setVisible(false)
    self._freeReset:setVisible(false)
    self._freeResetNum:setVisible(false)

    self._resetButton:setVisible(false)
    self._resetButton:stopAllActions()
    self._nextButton:getParent():setVisible(false)

    self._challengeNum:setText(tostring(G_Me.crusadeData:getLeftChallengeTimes()))

    if G_Me.crusadeData:hasPassStage() and not G_Me.crusadeData:hasPassAllStage() 
        and G_Me.crusadeData:getLeftChallengeTimes() > 0 then
        self._nextButton:getParent():setVisible(true)
    else
        self._resetButton:setVisible(true)

        --没有挑战次数 但可以重置的时候增加个动效
        if G_Me.crusadeData:getLeftChallengeTimes() == 0 and G_Me.crusadeData:getResetCount() > 0 then
            
            self._resetButton:runAction(CCRepeatForever:create(
                CCSequence:createWithTwoActions(CCScaleTo:create(1,1.05), CCScaleTo:create(1,1))))
        end

        if G_Me.crusadeData:getFreeResetCount() > 0 then
            self._freeReset:setVisible(true)
            self._freeResetNum:setVisible(true)
            self._freeReset:setText(G_lang:get("LANG_CRUSADE_RESET_NUM"))
            self._freeResetNum:setText(tostring(G_Me.crusadeData:getFreeResetCount()))
        elseif G_Me.crusadeData:getResetCount() > 0 then
            self._resetPanel:setVisible(true)
            local cost = G_Me.crusadeData:getResetCost()
            self._resetCost:setText(tostring(cost))
            if cost > G_Me.userData.gold then
                self._resetCost:setColor(Colors.darkColors.TIPS_01)
            else
                self._resetCost:setColor(Colors.darkColors.TITLE_01)
            end
        else
            self._resetZero:setVisible(true)
        end
    end
    
end

function CrusadeMainLayer:updateView(_winFlag)

    local winFlag = _winFlag or false

    self:_updateLines()  --要在updatehero之前执行 否则 光线解锁状态判断不对
    self:_updateProgressBar()
    self:_updateResetStatus()
    self:_updatePoints()

    self:_updateHeroes()

    --显示商店提示红点
    self:_showShopTip()
    self:_showTreasureTip() 

    self:_showAll(true)

    --自适应
    self:adapterLayer()

    --local percent = G_Me.crusadeData:canOpenTreasureFree() and 0 or 100
    --self._stageScrollView:jumpToPercentVertical(percent)     --可调整

    local posY = G_Me.crusadeData:getLastPos()
    local currentTarget = G_Me.crusadeData:getCurrentId()

    --有免费奖励可以领取
    if G_Me.crusadeData:canOpenTreasureFree() then
        self._stageScrollView:jumpToPercentVertical(0)
    --重进游戏 根据上次攻打目标定位
    elseif currentTarget > 3 then
        local percentV = 20*math.floor(currentTarget/3)
        self._stageScrollView:jumpToPercentVertical(100-percentV)
    else
        self._stageScrollView:getInnerContainer():setPositionY(posY)
    end

end

function CrusadeMainLayer:_showAll( show)  

    for i=1, self._maxStage do
        self._stageItems[i]:setVisible(show)
    end

    for i=1, BF_MAXLINE do
        self._lineItems[i]:setVisible(show)
    end

    self._stageScrollView:setVisible(show)

    local battle_field = battlefield_info.get(G_Me.crusadeData:getCurStage())
    if battle_field then
        self._treasureName:setText(battle_field.award_name)
    end

    self._currentScore:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData:getPetPoints()))

    self:showWidgetByName("Button_Shop",G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.PET_SHOP))
end



function CrusadeMainLayer:_updateHeroes( )  

    for i = 1, self._maxGate do 
        self:getPanelByName("Panel_Hero"..i):removeAllChildrenWithCleanup(true)
    end

    self._crusadeHeroes = {}

    for index = 1, self._maxGate do 
        
        local item = require("app.scenes.crusade.CrusadeHero").new(index, self)

        item:updateView()

        self:getPanelByName("Panel_Hero"..index):addChild(item)
        self._crusadeHeroes[#self._crusadeHeroes+1] = item
    end

end

--更新战宠积分
function CrusadeMainLayer:_updatePoints( data )  

    self._currentScore:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData:getPetPoints() - self._addPetPoints))

end


-- increase the score by jumping the number out
function CrusadeMainLayer:_playAddNum(labelNum, oldNum, newNum)
    -- create the action array
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCScaleTo:create(0.25, 2))
    arr:addObject(CCScaleTo:create(0.25, 1))

    local scale = CCSequence:create(arr)
    local growUp = CCNumberGrowupAction:create(oldNum, newNum, 0.5, function(number) 
        labelNum:setText(tostring(number))
    end)
    local act = CCSpawn:createWithTwoActions(scale, growUp)
    labelNum:runAction(act)
end


function CrusadeMainLayer:_onUpdateView( data )  

    if self._delayUpdateView == false then
        self:updateView(false)
    end
    
end

--解锁新的对手
function CrusadeMainLayer:_onUnlockHeroes( data )  

    if not data or type(data) ~= "table" then return end

    if rawget(data, "battle_field") and type(data.battle_field) == "table" then
        for i=1, #data.battle_field do
            local bf_sample = data.battle_field[i]
            if G_Me.crusadeData:getNewUnlocked() then 
                self._crusadeHeroes[bf_sample.id]:updateView()
            end
        end
    end

end

function CrusadeMainLayer:_onNext( ... )

    --提醒有宝藏未开启
    if G_Me.crusadeData:canOpenTreasureFree() then
        local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showSpecialMessage( G_lang:get("LANG_CRUSADE_RESET_WARNING"), 
        function()
            self.onClickTreasure()
        end,
        function() end, 
        self )
    elseif G_Me.crusadeData:getCurStage() < self._maxStage then
        --G_Me.crusadeData:initData()
        G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_NEXT)
    end


end

function CrusadeMainLayer:_onReset()

    if G_Me.crusadeData:getResetCount() <= 0 then 
        G_MovingTip:showMovingTip(G_lang:get("LANG_CRUSADE_NO_RESET"))
        return
    end

    if G_Me.crusadeData:canOpenTreasureFree() then
        local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showSpecialMessage( G_lang:get("LANG_CRUSADE_RESET_WARNING"), 
        function()
            self.onClickTreasure()
        end,
        function() end, 
        self )
    elseif G_Me.crusadeData:getFreeResetCount() > 0 then
        local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showSpecialMessage( G_lang:get("LANG_CRUSADE_RESET_TIP"), 
        function()
            --self:_showAll(false)
            --G_Me.crusadeData:initData()
            G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_RESET)
        end,
        function() end, 
        self )           
    elseif G_Me.crusadeData:getResetCount() > 0 then
        local t = G_Me.crusadeData:getResetCost()
        if G_Me.userData.gold < t then
          -- G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH"))
          require("app.scenes.shop.GoldNotEnoughDialog").show()
          return 
        end
        local box = require("app.scenes.tower.TowerSystemMessageBox")
        box.showMessage( box.TypeCrusade,
            t, G_Me.crusadeData:getResetCount(), 
        function() 
            --self:_showAll(false)
            --G_Me.crusadeData:initData()
            G_HandlersManager.crusadeHandler:sendGetBattleFieldInfo(CrusadeCommon.GET_BF_TYPE_RESET)
        end,
        function() end, 
        self )
    end
    
end

function CrusadeMainLayer:_onFightEnd( result )

    local curSceneName = G_SceneObserver:getSceneName()
    if not self or curSceneName ~= "CrusadeScene" and curSceneName ~= "CrusadeBattleScene" then
        return
    end

    -- pop the battle scene
    uf_sceneManager:popScene()

    local lastPetPoints = G_Me.userData:getPetPoints() - self._addPetPoints
    -- jump out the new score and medal number
    if self._addPetPoints > 0 then
        self:_playAddNum(self._currentScore, lastPetPoints, G_Me.userData:getPetPoints())
    end

    --重置
    self._addPetPoints = 0


end


function CrusadeMainLayer:_onOpenTreasure(data) 
    self:_showTreasureTip()
end


function CrusadeMainLayer:_onChallengeReport(data)  
    
    --dump(data)

    --延迟刷新界面
    self._delayUpdateView = true  

    --self._scrollViewOffsetY = self._stageScrollView:getContentOffset().y
    local posY = self._stageScrollView:getInnerContainer():getPositionY()
    G_Me.crusadeData:setLastPos(posY)

    local heroInfo = G_Me.crusadeData:getHeroInfo(data.id)

    --记录增加的积分
    self._addPetPoints = data.pet_point

    local callback = function(result)

        local curSceneName = G_SceneObserver:getSceneName()

        if not self or curSceneName ~= "CrusadeScene" and curSceneName ~= "CrusadeBattleScene" then
            return
        end

        --dump(data.awards)
        local award = nil
        if data.awards and #data.awards > 0 then
            award = data.awards[1]
        end

        local FightEnd = require("app.scenes.common.fightend.FightEnd")
        FightEnd.show(FightEnd.TYPE_CRUSADE, data.info.is_win,
            {
                crusade_pet_point = data.pet_point,
                crusade_beat_user = heroInfo.user,
                crusade_award_size = award and award.size or 0
            },        
    
            handler(self, self._onFightEnd), result)
    end

    G_Loading:showLoading(
        function ( ... )
            --创建战斗场景
            self._battleScene = require("app.scenes.crusade.CrusadeBattleScene").new(data.info, heroInfo.user, callback)
            uf_sceneManager:pushScene(self._battleScene)
        end,

        function ( ... )
            --开始播放战斗
            if self._battleScene then
                self._battleScene:play()
            end
        end
    )

    --else
    --    MessageBoxEx.showOkMessage(nil, G_NetMsgError.getMsg(data.ret).msg)
    --end  
end

return CrusadeMainLayer
