require("app.cfg.dead_battle_info")
require("app.cfg.dead_battle_award_info")
require("app.cfg.dead_battle_reset_info")
require("app.const.ShopType")
require("app.cfg.knight_info")
require("app.cfg.dead_battle_buy_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
local EffectNode = require "app.common.effects.EffectNode"
KnightPic = require("app.scenes.common.KnightPic")
local WushMainLayer = class("WushMainLayer",UFCCSNormalLayer)

-- local maxFloor = 36
local bossFloor = 3

function WushMainLayer:ctor(jsonFile, fun, scenePack)
    self._reachMax = false
    self._firstEnter = false
    self._floor = 0 --正在打的层
    self._wushItems = {}
    self._inited = false
    self.tips = nil
    self._playing = false
    self._cleaning = false
    self._showAround = false
    self.maxFloor = dead_battle_info.getLength()

    -- 是否可看见一键3星按钮
    self._canPreviewTowerFast = G_moduleUnlock:canPreviewModule(FunctionLevelConst.TOWERFAST)
    
    self.super.ctor(self, json)
    self:adapterWithScreen()

    self._resetNumber0 = self:getLabelByName("Label_cz")
    self._resetNumber = self:getPanelByName("Panel_cz2")
    self._resetNumber2 = self:getLabelByName("Label_cz2")
    self._resetNumber3 = self:getLabelByName("Label_cz3")
    self._resetNumber3:setText(G_lang:get("LANG_WUSH_ZERO_RESET"))
    self:getLabelByName("Label_cz1"):setText(G_lang:get("LANG_WUSH_RESET_YUANBAO"))
    self._resetNumber0:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_12"):createStroke(Colors.strokeBrown, 2)
    
    self:getPanelByName("Panel_cover"):setVisible(false)
    self:getPanelByName("Panel_Monster1"):setVisible(true)
    self:getPanelByName("Panel_Monster2"):setVisible(true)
    self:getPanelByName("Panel_Monster3"):setVisible(true)
    self:getImageViewByName("Image_box"):setVisible(true)

    self._fastButton = self:getButtonByName("Button_Fast")
    self._mybox = self:getImageViewByName("Image_box")
    self._myjiangli = self:getImageViewByName("Image_105")
    self._boxStartPos = ccp(self._mybox:getPosition())

    self._fastButton:setVisible(G_moduleUnlock:isModuleUnlock(FunctionLevelConst.WUSH_FAST) and G_Me.wushData:getFastMax() > 0)

    local button = self:getButtonByName("Button_Reset")
    local EffectNode = require "app.common.effects.EffectNode"
    local node = EffectNode.new("effect_around2")     
    node:setScale(1.4) 
    node:play()
    button:addNode(node)
    self._resetEffect = node
    
    G_GlobalFunc.savePack(self, scenePack)

    self:attachImageTextForBtn("Button_Reset","ImageView_reset")
    
    self:registerBtnClickEvent("Button_Back", function()
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_Fast", function()
        if self._playing then
            return
        end
        if G_Me.wushData:getFastMax() < self._floor then
            if G_Me.wushData:getFastMax() <= 1 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_SHOULD_FIGHT"))
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_CANNOT_FAST"))
            end
            return
        end
        if self._cleaning then
            return
        end
        local str = G_lang:get("LANG_WUSH_FAST_OK",{floor=G_Me.wushData:getFastMax()})
        MessageBoxEx.showYesNoMessage(nil,str,false,function()
            if G_SceneObserver:getSceneName() ~= "WushScene" then
                return
            end
            self._cleaning = true
            local fast = require("app.scenes.wush.WushFasterLayer").create(function ( )
                self._cleaning = false
                self:_createWush()

                self:_checkWushBossStatus()
            end)
            uf_sceneManager:getCurScene():addChild(fast)
        end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Default)     
    end)
    self:registerBtnClickEvent("Button_treaBorder", handler(self, self._onTreasureBorderClick))
    self:registerBtnClickEvent("Button_Shop", function()
        if self._playing then
            return
        end
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.CHUANG_GUAN))
    end)
    self:registerBtnClickEvent("Button_Reset", handler(self, self._onReset))
    self:registerBtnClickEvent("Button_Leaderboard", handler(self, self._onLeaderboard))
    self:registerWidgetClickEvent("Panel_attr", function()
        local list = G_Me.wushData:getBuffList()
        if GlobalFunc.table_is_empty(list) then
            return
        end
        p = require("app.scenes.wush.WushShowBuff").new("ui_layout/wush_curBuff.json",require("app.setting.Colors").modelColor)
        p:init()
        uf_sceneManager:getCurScene():addChild(p)
    end)
    self:registerWidgetClickEvent("Image_box", function()
        if self._playing then
            return
        end
        p = require("app.scenes.wush.WushBoxAward").new("ui_layout/wush_award.json",require("app.setting.Colors").modelColor)
        p:init(G_Me.wushData:getFloor())
        uf_sceneManager:getCurScene():addChild(p)
    end)
    self:registerWidgetClickEvent("Panel_Monster1", function()
        self:_onClickMonsterHead(1)
    end)
    self:registerWidgetClickEvent("Panel_Monster2", function()
        self:_onClickMonsterHead(2)
    end)
    self:registerWidgetClickEvent("Panel_Monster3", function()
        self:_onClickMonsterHead(3)
    end)
end

function WushMainLayer:_onBossBtnClick( ... )
    require("app.scenes.wush.boss.WushBossLayer").show()
end

function WushMainLayer:_onTreasureBorderClick( ... )
    local widget = self:getWidgetByName("Button_treaBorder")
    local xPos, yPos = widget:convertToWorldSpaceXY(0, 0)
    local top = require("app.scenes.wush.WushBuyLayer").create(ccp(xPos, yPos))
    uf_sceneManager:getCurScene():addChild(top)
end

function WushMainLayer:_onLeaderboard()
    local p = require("app.scenes.wush.WushLeaderboardLayer").new("ui_layout/wush_WushLeaderboardLayer.json",require("app.setting.Colors").modelColor)
    p:initWithWushLayer(self)
    uf_sceneManager:getCurScene():addChild(p)
end

function WushMainLayer:updateView(winFlag)
    self._win = winFlag or false
    if not self._inited then
        self:_createWush(winFlag ~= nil and not winFlag)
    end
end

function WushMainLayer:onBackKeyEvent( ... )
    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.mainscene.PlayingScene")
    end

    return true
end

function WushMainLayer:setDisplayEffect(displayEffect)
    self._showEffect = displayEffect
end

function WushMainLayer:onLayerLoad( ... )
    self.super:onLayerLoad()
    
end

function WushMainLayer:onLayerEnter( ... )
    self:registerKeypadEvent(true)
    --显示商店提示红点
    self:showWidgetByName("Image_shopTips",G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.CHUANG_GUAN))
    self:getButtonByName("Button_Reset"):setTouchEnabled(true)
    if G_Me.wushData:isNew() or not G_Me.wushData:needGo() then
        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_Header")}, true, 0.2, 2, 100)
        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_corner_mover")}, true, 0.2, 2, 100)
    end

    self._mybox:setPosition(self._boxStartPos)
    self._myjiangli:setVisible(true)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_INFO, self._onWushInfoRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_GET_BUFF, self._onWushBuffRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_RESET, self._onResetRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_CHALLENGE_REPORT, self._onChallengeReportRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_APPLY_BUFF, self._onBuffApply, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BUY, self._onBuyRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BOSS_INFO, self._initWushBossBtn, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_WUSH_BOSS_BUY, self._updateWushBossTips, self)

    if self.tips == nil then
        self.tips = EffectNode.new("effect_knife", 
            function(event, frameIndex)
                if event == "finish" then
             
                end
            end
        )
        -- self.tips:setScale(1.5)
        self.tips:play()
        self.tips:setVisible(false)
        self:getPanelByName("Panel_Tower"):addNode(self.tips) 
        self.tips:setZOrder(10)
    end
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        self._effect = EffectNode.new("effect_mooncity_cg", 
            function(event, frameIndex)
                if event == "finish" then
             
                end
            end
        )
        self._effect:setPosition(ccp(320,283))
        self._effect:play()
        self:getPanelByName("Panel_effect"):addNode(self._effect) 
    end

    if G_Me.wushData:isNew() or G_Me.wushData:isNeedRequestNewData() then
        G_HandlersManager.wushHandler:sendQueryWushInfo()
        self._inited = true
    else
        self._floor = G_Me.wushData:getFloor()
        local needAnime = G_Me.wushData:needGo()
        if needAnime then
            self._floor = self._floor - 1
        end
        self:_initOthers()
        self._playing = false
    end

    self:_checkWushBossStatus()
end

function WushMainLayer:_checkWushBossStatus(  )
    if G_Me.wushData:getBossActiveId() <= 0 then
        G_HandlersManager.wushHandler:sendWushBossInfo()
    else
        self:_initWushBossBtn()
    end
end

function WushMainLayer:_initWushBossBtn(  )
    -- 无双精英boss按钮
    if G_Me.wushData:getBossActiveId() > 0 then
        self:showWidgetByName("Button_Boss", true)
        self:registerBtnClickEvent("Button_Boss", function ()
            self:_onBossBtnClick()
        end)
        self:showWidgetByName("Image_Boss_Tips", G_Me.wushData:getCurBossChallengeTimes() > 0)
    else 
        self:showWidgetByName("Button_Boss", false)
    end
end

function WushMainLayer:_updateWushBossTips(  )
    self:showWidgetByName("Image_Boss_Tips", G_Me.wushData:getCurBossChallengeTimes() > 0)
end

function WushMainLayer:_onBuffApply()  
    self:_initOthers()
end

function WushMainLayer:onLayerUnload( ... )  
    self.super:onLayerUnload()
end

function WushMainLayer:onLayerExit()
    self.super:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function WushMainLayer:_createWush( failFromBattle )  
    self:_showAll(true)
    self.tips:setVisible(false)
    self._floor = G_Me.wushData:getFloor()
    local needAnime = G_Me.wushData:needGo()
    if needAnime then
        self._floor = self._floor - 1
    end

    self:_initOthers()

    if needAnime then
        self:_winAnime()
    else
        if not self:_chooseBuff() then
            self:_createHero()
            self:_setTipPos()
        end
    end

    if G_Me.wushData.failed == 1 or self._floor > self.maxFloor then
        self:_showEnd(true)
        self.tips:setVisible(false)
        self._cleaning = false
        if failFromBattle then 
            self:_onTreasureBorderClick()
        end
    else
        self:_showEnd(false)
    end

    self:updateResetStatus()
end

function WushMainLayer:_updateResetButton()
    if self._canPreviewTowerFast and self._floor <= self.maxFloor and G_Me.wushData.failed == 0 then
        self:getImageViewByName("ImageView_reset"):loadTexture("ui/text/txt-middle-btn/sanxingtiaozhan.png",UI_TEX_TYPE_LOCAL) 
        self:getButtonByName("Button_Reset"):loadTextureNormal("btn-middle-blue.png",UI_TEX_TYPE_PLIST)
        self._showAround = false
    else
        self:getImageViewByName("ImageView_reset"):loadTexture("ui/text/txt-middle-btn/chongzhi_red.png",UI_TEX_TYPE_LOCAL) 
        self:getButtonByName("Button_Reset"):loadTextureNormal("btn-middle-red.png",UI_TEX_TYPE_PLIST)
        self._showAround = true
    end
end

function WushMainLayer:_initOthers()
    self:getLabelByName("Label_max"):setText(G_Me.wushData:getStarHis())
    self:getLabelByName("Label_cur"):setText(G_Me.wushData:getStarTotal())
    self:getLabelByName("Label_max"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_cur"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_30"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_30_0"):createStroke(Colors.strokeBrown, 1)

    local floor = self._floor
    if floor > self.maxFloor then
        floor = self.maxFloor
    end
    local info = dead_battle_info.get(floor) 
    self:getLabelByName("Label_desc"):setText(info.success_directions)
    self:getLabelByName("Label_desc"):createStroke(Colors.strokeBrown, 1)

    self:getLabelByName("Label_79"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_81"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_star"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_star"):setText(G_Me.wushData:getStarCur())
    self:getLabelByName("Label_star_1"):createStroke(Colors.strokeBrown, 1)

    self:getLabelByName("Label_jifen"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_jifenzhi"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_jifenzhi"):setText(G_Me.userData.tower_score)

    self:getLabelByName("Label_more"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_nomore"):createStroke(Colors.strokeBrown, 1)


    self:_updateResetButton()

    local info = G_Me.wushData:getBuffList()
    local index = 1
    for k,v in pairs(info) do
        if index <= 2 then
            -- local desc = G_lang.getGrowthTypeName(k)
            -- local value = G_lang.getGrowthValue(k,v)
            -- print(index)
            local desc,value = G_Me.wushData.convertAttrTypeAndValue(k,v)
            -- self:getLabelByName("Label_attr"..index):setVisible(true)
            -- self:getLabelByName("Label_value"..index):setVisible(true)
            -- self:getLabelByName("Label_attr"..index):setText(desc)
            -- self:getLabelByName("Label_value"..index):setText("+"..value)
            local attriLabel = self:getLabelByName("Label_attr"..index)
            local valueLabel = self:getLabelByName("Label_value"..index)
            if attriLabel then 
                attriLabel:setVisible(true)
                attriLabel:setText(desc)
            end
            if valueLabel then 
                valueLabel:setVisible(true)
                valueLabel:setText("+"..value)
                if attriLabel then
                    local descSize = attriLabel:getSize()
                    local posx, posy = attriLabel:getPosition()
                    valueLabel:setPosition(ccp(posx + descSize.width, posy))
                end                
            end
        end
        index = index + 1
    end

    for i = index,2 do
        self:getLabelByName("Label_attr"..i):setVisible(false)
        self:getLabelByName("Label_value"..i):setVisible(false)
    end

    if index == 1 then
        self:getLabelByName("Label_nomore"):setVisible(true)
        self:getLabelByName("Label_more"):setVisible(false)
    elseif index > 3 then
        self:getLabelByName("Label_nomore"):setVisible(false)
        self:getLabelByName("Label_more"):setVisible(true)
    else
        self:getLabelByName("Label_nomore"):setVisible(false)
        self:getLabelByName("Label_more"):setVisible(false)
    end
end

function WushMainLayer:_createHero( )  
    -- for index = 1,#self._wushItems do 
    --     self._wushItems[index]:removeFromParentAndCleanup(true)
    -- end
    if self._cleaning then
        return
    end
    for i = 1,3 do 
        self:getPanelByName("Panel_Monster"..i):removeAllChildrenWithCleanup(true)
    end
    self._wushItems = {}
    if self._floor > self.maxFloor then
        return
    end
    local baseFloor = math.floor((self._floor - 1)/3)
    local index = self._floor - baseFloor*3
    for i = 1,3 do 
        local floor = baseFloor*3+i
        -- local item = require("app.scenes.wush.WushItem").create(floor, self)
        local item = require("app.scenes.wush.WushItem").new(floor, self)
        if i < index then
            item:pass(G_Me.wushData:getStar(floor))
        end
        if i == index then
            item:showQipao(true)
        end
        if i > index then
            item:nopass()
        end
        -- 
        self:getPanelByName("Panel_Monster"..i):addChild(item)
        self._wushItems[#self._wushItems+1] = item
    end

end

function WushMainLayer:_setTipPos()
    if self._floor == 0 then return end
    self.tips:setVisible(true)
    
    local p1,p2 = self:_getTipPos()
    self.tips:setPosition(p1)
end

function WushMainLayer:_getTipPos()
    local i = (self._floor-1)%bossFloor + 1
    local _knightPic = self:getPanelByName("Panel_Monster"..i)
    local _pt = _knightPic:getPositionInCCPoint()
    local _size = _knightPic:getContentSize()
    
    local pt1 = ccp(_pt.x+_size.width/2 ,_pt.y+_size.height+35)
    local pt2 = ccp(_pt.x+20, _pt.y + _size.height+80)
    return pt1, pt2
end

function WushMainLayer:_onWushInfoRsp( data )  
    self:_createWush()
    --显示商店提示红点
    self:showWidgetByName("Image_shopTips",G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.CHUANG_GUAN))
end

function WushMainLayer:_onClickMonsterHead(index )  
    if self._playing then
        return
    end
    if G_Me.wushData:needBuff() then
        return
    end
    local cur = (G_Me.wushData:getFloor()-1)%3+1
    if cur ~= index then
        return
    end
    -- G_HandlersManager.wushHandler:sendWushChallenge(0)
    p = require("app.scenes.wush.WushFightPreview").new("ui_layout/wush_fightPreview.json",require("app.setting.Colors").modelColor)
    p:initWithFloor(G_Me.wushData:getFloor(),function ( )
        self:_showAll(true)
    end)
    uf_sceneManager:getCurScene():addChild(p)
    self:_showAll(false)
    -- self:_winAnime()
end

function WushMainLayer:updateResetStatus()
    if G_Me.wushData:getResetCount() < G_Me.wushData:getResetFreeCount() then
        self._resetNumber:setVisible(false)
        self._resetNumber2:setVisible(true)
        self._resetNumber3:setVisible(false)
        local num = G_Me.wushData:getResetFreeCount() - G_Me.wushData:getResetCount()
        self._resetNumber2:setText(G_lang:get("LANG_WUSH_RESET_NUM", {times=num}))
        self._resetEffect:setVisible(self._showAround)
    elseif G_Me.wushData:getResetCount() < G_Me.wushData:getResetTotalCount() then
        if self._canPreviewTowerFast and self._floor <= self.maxFloor and G_Me.wushData.failed == 0 then
            self._resetNumber:setVisible(false)
            self._resetNumber2:setVisible(true)
            self._resetNumber2:setText(G_lang:get("LANG_WUSH_RESET_TIMES", {times=
                G_Me.wushData:getResetTotalCount() - G_Me.wushData:getResetCount()}))
        else
            self._resetNumber:setVisible(true)
            self._resetNumber2:setVisible(false)
        end
        self._resetNumber3:setVisible(false)
        local t = G_Me.wushData:getResetCost()
        local cost = self:getLabelByName("Label_cz")
        if t > G_Me.userData.gold then
            cost:setColor(Colors.darkColors.TIPS_01)
        else
            cost:setColor(Colors.qualityColors[7])
        end
        cost:setText(t)
        self._resetEffect:setVisible(false)
    else
        self._resetNumber:setVisible(false)
        self._resetNumber2:setVisible(false)
        self._resetNumber3:setVisible(true)
        self._resetEffect:setVisible(false)
    end
    
end

function WushMainLayer:_onReset()
    if G_Me.wushData:needBuff() then
        return
    end

    if self._floor <= self.maxFloor and G_Me.wushData.failed == 0 then
        if self._canPreviewTowerFast then
            local isUnlock = G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.TOWERFAST)
            if isUnlock then
                local ceng = math.floor((self._floor-1)/3)
                local floor3 = ceng*3+3
                if G_Me.userData.fight_value < dead_battle_info.get(floor3).monster_fight_3 then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_YOUTOOYOUNG"))
                    return
                end
                if self._cleaning then
                    self._cleaning = false
                else
                    self._cleaning = true
                    -- G_HandlersManager.wushHandler:sendWushChallenge(2)
                end
                local fast = require("app.scenes.wush.WushFastLayer").create(function ( )
                    self:_createWush()

                    self:_checkWushBossStatus()
                end)
                uf_sceneManager:getCurScene():addChild(fast)
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_RESET_NOFAIL"))
        end
        return
    end

    if G_Me.wushData:getResetCount() >= G_Me.wushData:getResetTotalCount() then 
            G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_RESET_NO_TIMES"))
        return
    end

    if G_Me.wushData:getResetCount() < G_Me.wushData:getResetFreeCount() then
            if G_Me.wushData.failed == 0 then
                local box = require("app.scenes.tower.TowerSystemMessageBox")
                box.showSpecialMessage( G_lang:get("LANG_WUSH_CHONGZHI3"), 
                function() 
                    G_HandlersManager.wushHandler:sendWushReset()
                end,
                function() end, 
                self )
            else
                local box = require("app.scenes.tower.TowerSystemMessageBox")
                box.showSpecialMessage( G_lang:get("LANG_WUSH_CHONGZHI3"), 
                function() 
                    G_HandlersManager.wushHandler:sendWushReset()
                end,
                function() end, 
                self )
            end
        else
            local t = G_Me.wushData:getResetCost()
            if G_Me.userData.gold < t then
              -- G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH"))
              require("app.scenes.shop.GoldNotEnoughDialog").show()
              return 
            end
            local box = require("app.scenes.tower.TowerSystemMessageBox")
            box.showMessage( box.TypeTower,
                t, G_Me.wushData:getResetTotalCount() - G_Me.wushData:getResetCount(), 
            function() 
                G_HandlersManager.wushHandler:sendWushReset()
            end,
            function() end, 
            self )
    end
    
end

function WushMainLayer:_reset( )  
    self:getPanelByName("Panel_Monster1"):setVisible(true)
    self:getPanelByName("Panel_Monster2"):setVisible(true)
    self:getPanelByName("Panel_Monster3"):setVisible(true)
    self:getImageViewByName("Image_box"):setVisible(true)
    -- self:_createWush()
    self:_heroAppear()
end

function WushMainLayer:_chooseBuff( )  
    if G_Me.wushData:needBuff() then
        G_HandlersManager.wushHandler:sendWushGetBuff()
        self._cleaning = false
        -- p = require("app.scenes.wush.WushBuffChoose").new("ui_layout/wush_buffChoose.json")
        -- p:init(function ( )
        --     self:_heroAppear()
        -- end)
        -- uf_sceneManager:getCurScene():addChild(p)
        return true
    end
    return false
end

function WushMainLayer:_onWushBuffRsp(data)
    if not self._buffChooseLayer and not self._cleaning then
        if G_Me.wushData:needBuff() then
            self._buffChooseLayer = require("app.scenes.wush.WushBuffChoose").new("ui_layout/wush_buffChoose.json")
            self._buffChooseLayer:init(function ( )
                self._buffChooseLayer = nil
                self:_heroAppear()
            end)
            uf_sceneManager:getCurScene():addChild(self._buffChooseLayer)
        else
            self:_createWush()
            self:_checkWushBossStatus()
        end
    end
end

function WushMainLayer:_heroAppear( )  
    local effectTag = 100000
    for i = 1,3 do 
        self:getPanelByName("Panel_Monster"..i):removeAllChildrenWithCleanup(true)
    end
    for k=1,3 do
        local EffectNode = require "app.common.effects.EffectNode"
        local effect = EffectNode.new("effect_appear", function(event, frameIndex)
            if event == "appear" then
                if k == 3 then
                    self:_createWush()
                end
            end
            if event == "finish" then
                self:getPanelByName("Panel_Tower"):removeNodeByTag(effectTag+k)
            end
                end)
        effect:play()
        local panel = self:getPanelByName("Panel_Monster"..k)
        local pt = panel:getPositionInCCPoint()
        local sz = panel:getContentSize()
        effect:setPosition(ccp(pt.x+sz.width/2-20, pt.y+100))
        self:getPanelByName("Panel_Tower"):addNode(effect)
        effect:setTag(effectTag+k)
    end
end

function WushMainLayer:_onResetRsp(data )  
    if data.ret == 1 then 
        self:_reset()
        self:_updateResetButton()
        self:updateResetStatus()
    end
end

function WushMainLayer:_getAwardIndex( )  
    local floor = self._floor-1
    return G_Me.wushData:calcCurStar(floor-2,floor)
end

function WushMainLayer:_getAward( )  
    local floor = self._floor-1
    if floor < 1 then 
        return {}
    end
    local star = G_Me.wushData:calcCurStar(floor-2,floor)
    local info = dead_battle_info.get(floor)
    local award = {}
    local found = false
    -- for k = 1,3 do 
    --     local i = 4 - k
    --     local starNeed = info["type_star_"..i]
    --     if star >= starNeed and not found then
    --         found = true
    --         local awardData = dead_battle_award_info.get(info["type_award_"..i])

    --         for j = 1,3 do 
    --             if awardData["type_"..j] ~= 0 then
    --                 local awardCell = {type=awardData["type_"..j],value=awardData["value_"..j],size=awardData["size_"..j]}
    --                 table.insert(award,#award+1,awardCell) 
    --             end
    --         end
    --     end
    -- end
    for k = 1,3 do 
        local i = 4 - k
        local starNeed = info["type_star_"..i]
        if star >= starNeed and not found then
            found = true
            award = G_Me.wushData:getAwardById(info["type_award_"..i])
        end
    end
    return award
end

function WushMainLayer:_onBuyRsp( data)  
    if data.ret == 1 then
        if self.treanode then
            self.treanode:stop()
            self.treanode:removeFromParentAndCleanup(true)
            self.treanode = nil
        end
    end
end

function WushMainLayer:_showEnd( isend)  
    self:getPanelByName("Panel_cover"):setVisible(isend)
    self._fastButton:setVisible((not isend) and G_moduleUnlock:isModuleUnlock(FunctionLevelConst.WUSH_FAST) and G_Me.wushData:getFastMax() > 0)
    -- self:getLabelByName("Label_guanshu1"):setText(G_lang:get("LANG_WUSH_GUANSHU"))
    -- self:getLabelByName("Label_guanshu2"):setText(self._floor - 1)
    -- self:getLabelByName("Label_xingshu1"):setText(G_lang:get("LANG_WUSH_XINGSHU"))
    -- self:getLabelByName("Label_xingshu2"):setText(G_Me.wushData:getStarTotal())
    -- self:getLabelByName("Label_chongzhi"):setText(G_lang:get("LANG_WUSH_CHONGZHI"))

    if isend then
        local hero = self:getPanelByName("Panel_meinv")
        hero:removeAllChildrenWithCleanup(true)
        local GlobalConst = require("app.const.GlobalConst")
        local appstoreVersion = (G_Setting:get("appstore_version") == "1")
        local knight = nil
        if appstoreVersion or IS_HEXIE_VERSION  then 
            knight = knight_info.get(GlobalConst.CAI_WEN_JI_HE_XIE_ID)
        else
            knight = knight_info.get(GlobalConst.CAI_WEN_JI_ID)
        end
        if knight then
            KnightPic.createKnightPic( knight.res_id, hero, "meinv",true )
            hero:setScale(0.5)
            local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
            self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
            self:getLabelByName("Label_talk"):setText(G_lang:get("LANG_WUSH_FIGHTEND",{floor=self._floor-1}))
            local moreLabel = self:getLabelByName("Label_needMoreLevel")
            moreLabel:setText(G_lang:get("LANG_WUSH_NEEDMORELEVEL"))
            moreLabel:setVisible(not G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").TOWERFAST))
            GlobalFunc.sayAction(self:getPanelByName("Panel_talk"),false,nil,true)
        end

        -- local item = G_Goods.convert(3, 49)
        local id = G_Me.wushData._buyId
        if id > 0 then
            self:getImageViewByName("Image_treaBg"):setVisible(true)
            local info = dead_battle_buy_info.get(id)
            local g = G_Goods.convert(info.item_type, info.item_id)
            self:getImageViewByName("Image_treaIcon"):loadTexture(g.icon)
            self:getImageViewByName("Image_ball"):loadTexture(G_Path.getEquipIconBack(g.quality))
            self:getButtonByName("Button_treaBorder"):loadTextureNormal(G_Path.getEquipColorImage(g.quality,info.item_type))
            self:getLabelByName("Label_treanum"):setText("x"..info.item_num)
            self:getLabelByName("Label_treanum"):createStroke(Colors.strokeBrown, 1)
            if G_Me.wushData._bought == false then
                if not self.treanode then
                    self.treanode = EffectNode.new("effect_around1")     
                    self.treanode:setScale(1.7) 
                    self.treanode:setPosition(ccp(5,-5))
                    self.treanode:play()
                    self:getImageViewByName("Image_treaBg"):addNode(self.treanode,10)
                end
            else
                if self.treanode then
                    self.treanode:stop()
                    self.treanode:removeFromParentAndCleanup(true)
                    self.treanode = nil
                end
            end
        else
            self:getImageViewByName("Image_treaBg"):setVisible(false)
        end
    end

    self:getPanelByName("Panel_Monster1"):setVisible(not isend)
    self:getPanelByName("Panel_Monster2"):setVisible(not isend)
    self:getPanelByName("Panel_Monster3"):setVisible(not isend)
    self:getImageViewByName("Image_box"):setVisible(not isend)
end

function WushMainLayer:_showAll( show)  
    self:getPanelByName("Panel_Monster1"):setVisible(show)
    self:getPanelByName("Panel_Monster2"):setVisible(show)
    self:getPanelByName("Panel_Monster3"):setVisible(show)
    self:getPanelByName("Panel_top_mover"):setVisible(show)
    self:getPanelByName("Panel_Corner"):setVisible(show)
    self.tips:setVisible(show)
end

function WushMainLayer:_getValueFromData(data )
    local award = data.award
    local score = 0
    local money = 0
    for k, v in pairs(award) do 
        if v.type == G_Goods.TYPE_MONEY then
            money = v.size
        elseif v.type == G_Goods.TYPE_CHUANGUAN then
            score = v.size
        end
    end
    return score,money
end    

function WushMainLayer:_onChallengeReportRsp(data )  
    -- dump(data)
    -- local score,money = self:_getValueFromData(data)
    if data.ret == 1 then 
        if self._cleaning then
            -- self._floor = G_Me.wushData:getFloor()
            -- local needAnime = G_Me.wushData:needGo()
            -- if needAnime then
            --     self._floor = self._floor - 1
            -- end
            -- self:_initOthers()
            -- if needAnime then
            --     self:_winAnime()
            -- else
            --     if not self:_chooseBuff() then
            --         self:_createHero()
            --         self:_setTipPos()
            --     end
            -- end
            -- if not data.battle_report.is_win then
            --     self._cleaning = false
            -- end
            -- if G_Me.wushData.failed == 1 or self._floor > self.maxFloor then
            --     self:_showEnd(true)
            --     self.tips:setVisible(false)
            -- else
            --     self:_showEnd(false)
            -- end
            G_Me.wushData:hasWin()
            return
        end
        if not rawget(data,"battle_report") then
            G_Me.wushData:hasWin()
            self:_createWush()
            self:_checkWushBossStatus()
            return
        end
        local index = data.index + 1
        local info = dead_battle_info.get(self._floor)
         local _tower_score = info["tower_score_"..index]
         local _tower_money = info["coins_"..index]
         local _winDesc = info.sucesss_talk
         local _loseDesc = info.fail_talk
         local score,money = self:_getValueFromData(data)
         -- print("服务器score = " .. score .. ",money = " .. money)
         -- print("本地score = " .. _tower_score .. ",money = " .. _tower_money)
         local callback = function()
             local FightEnd = require("app.scenes.common.fightend.FightEnd")
             FightEnd.show(FightEnd.TYPE_TOWER, data.battle_report.is_win,
                 {
                    tower_score=score, 
                    awards=data.award,
                    tower_money=money,
                    win_desc=_winDesc,
                    lose_desc=_loseDesc,
                    compare_value_1 = _tower_score,
                    compare_value_2 = _tower_money,
                  },        
                 function() 
                     uf_sceneManager:replaceScene(require("app.scenes.wush.WushScene").new(data.battle_report.is_win, nil, nil, nil, GlobalFunc.getPack(self)))
                 end 
              )
         end
         local battle 
         G_Loading:showLoading(function ( ... )
             --创建战斗场景
             battle = require("app.scenes.wush.WushBattleScene").new(
                 {data = data,func = callback,bg = G_Path.getDungeonBattleMap( info.map_id),floor = self._floor})
             uf_sceneManager:replaceScene(battle)
         end, 
         function ( ... )
             --开始播放战斗
             battle:play()
         end)
        --显示商店提示红点
        self:showWidgetByName("Image_shopTips",G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.CHUANG_GUAN))
     else
         MessageBoxEx.showOkMessage(nil, G_NetMsgError.getMsg(data.ret).msg)
     end  
end

function WushMainLayer:_winAnime()  
    G_Me.wushData:hasWin()
    self._playing = true
    self:getButtonByName("Button_Reset"):setTouchEnabled(false)
    local index = (self._floor-1)%3 + 1
    if index ~= 3 then
        self:_createHero()
        self.tips:setVisible(false)
        self._wushItems[index]:pass(0)
        self._wushItems[index]:showStar(G_Me.wushData:getStar(self._floor),true,function()
            local index2 = self._floor%3 + 1
            self._floor = self._floor + 1
            self._wushItems[index2]:come()
            self:_setTipPos()
            self:getButtonByName("Button_Reset"):setTouchEnabled(true)
            self._playing = false
            if self._cleaning then
                -- G_HandlersManager.wushHandler:sendWushChallenge(2)
            end
        end)
        return true
    else
        self:_createHero()
        self.tips:setVisible(false)
        self._wushItems[index]:pass(0)
        self._wushItems[index]:showStar(G_Me.wushData:getStar(self._floor),true,function()
            self._floor = self._floor + 1
            local box = self:getImageViewByName("Image_box")
            local jiangli = self:getImageViewByName("Image_105")
            local startPos = ccp(box:getPosition())
            local winSize = CCDirector:sharedDirector():getWinSize()
            local endP = ccp(winSize.width/2,winSize.height/2)
            local endPos = box:getParent():convertToNodeSpace(endP)

            jiangli:setVisible(false)
            local seq = CCSequence:createWithTwoActions(CCMoveTo:create(0.4, endPos),CCCallFunc:create(function()
                    if G_SceneObserver:getSceneName() ~= "WushScene" then
                        return
                    end
                    local EffectNode = require "app.common.effects.EffectNode"
                    effectNode = EffectNode.new("effect_box_light", function(event, frameIndex) end)      
                    effectNode:play()
                    effectNode:setPosition(ccp(0,0))
                    box:addNode(effectNode,11)
                    -- local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(self:_getAward(),function()
                        -- self:_createWush()
                        -- effectNode:removeFromParentAndCleanup(true)
                        -- jiangli:setVisible(true)
                        -- box:setPosition(startPos)
                        -- self:getButtonByName("Button_Reset"):setTouchEnabled(true)
                        -- self._playing = false
                    --  end)
                    -- uf_notifyLayer:getModelNode():addChild(_layer)

                    local pt = box:getParent():convertToWorldSpace(box:getPositionInCCPoint())
                    local boxLayer = require("app.scenes.wush.WushBoxLayer").create(pt,self:_getAwardIndex(),self:_getAward(),function()
                            -- self:_createWush()
                            if G_SceneObserver:getSceneName() ~= "WushScene" then
                                return
                            end
                            effectNode:removeFromParentAndCleanup(true)
                            jiangli:setVisible(true)
                            box:setPosition(startPos)
                            self:getButtonByName("Button_Reset"):setTouchEnabled(true)
                            self._playing = false
                            -- G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOXEND"),nil,function ()
                            --     if G_SceneObserver:getSceneName() == "WushScene" then
                            --         self:_createWush()
                            --     end
                            -- end)
                            G_flyAttribute.addNormalText(G_lang:get("LANG_WUSH_BOXEND"), nil, nil)
                            G_flyAttribute.play(function ( ... )
                                -- if G_SceneObserver:getSceneName() == "WushScene" then
                                --     self:_createWush()
                                -- end
                            end)
                            self:callAfterDelayTime(0.5, nil, function ( ... )
                                if G_SceneObserver:getSceneName() == "WushScene" then
                                    self:_createWush()
                                end
                            end)
                        end)
                    uf_sceneManager:getCurScene():addChild(boxLayer)
                    boxLayer:_setParentLayer(self)
            end))
            box:runAction(seq)
        end)

        return false
    end


end

return WushMainLayer
