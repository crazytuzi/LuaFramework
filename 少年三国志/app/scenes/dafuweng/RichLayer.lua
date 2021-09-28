
local RichLayer = class("RichLayer", UFCCSNormalLayer)
require("app.cfg.richman_info")
require("app.cfg.richman_event_info")
require("app.cfg.richman_prize_info")
require("app.cfg.richman_shop_info")
require("app.cfg.richman_show")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local FuCommon = require("app.scenes.dafuweng.FuCommon")

local totalIcon = 35
function RichLayer.create(...)
    return RichLayer.new("ui_layout/dafuweng_MainLayer.json", ...)
end

function RichLayer:ctor(json, fun, scenePack,...)

    self.super.ctor(self, json, fun, scenePack, ...)

    G_GlobalFunc.savePack(self, scenePack)

    self._costNum1 = self:getLabelByName("Label_costNum1")
    self._costFree1 = self:getLabelByName("Label_free1")
    self._costTitle1 = self:getLabelByName("Label_costTitle1")
    self._costImg1 = self:getImageViewByName("Image_quan1")
    self._costTitle1:setText(G_lang:get("LANG_FU_COSTTITLE"))
    self._costFree1:setText(G_lang:get("LANG_WHEEL_FREE"))
    self._costTitle1:createStroke(Colors.strokeBrown, 1)
    self._costNum1:createStroke(Colors.strokeBrown, 1)
    self._costFree1:createStroke(Colors.strokeBrown, 1)
    self._costNum2 = self:getLabelByName("Label_costNum2")
    self._costFree2 = self:getLabelByName("Label_free2")
    self._costTitle2 = self:getLabelByName("Label_costTitle2")
    self._costImg2 = self:getImageViewByName("Image_quan2")
    self._costTitle2:setText(G_lang:get("LANG_FU_COSTTITLE"))
    self._costFree2:setText(G_lang:get("LANG_WHEEL_FREE"))
    self._costTitle2:createStroke(Colors.strokeBrown, 1)
    self._costNum2:createStroke(Colors.strokeBrown, 1)
    self._costFree2:createStroke(Colors.strokeBrown, 1)
    
    self._bangNum = self:getLabelByName("Label_bangNum")
    self._bangTitle = self:getLabelByName("Label_bangTitle")
    self._bangNum:createStroke(Colors.strokeBrown, 1)
    self._bangTitle:createStroke(Colors.strokeBrown, 1)
    self._bangTitle:setText(G_lang:get("LANG_FU_BANGTITLE"))

    self._timeNum = self:getLabelByName("Label_timeNum")
    self._timeTitle = self:getLabelByName("Label_timeTitle")
    self._timeNum:createStroke(Colors.strokeBrown, 1)
    self._timeTitle:createStroke(Colors.strokeBrown, 1)
    self._timeTitle:setText(G_lang:get("LANG_FU_TIMETITLE"))
    self._timeNum:setText("")

    self._scoreNum = self:getLabelByName("Label_scoreNum")
    self._scoreTitle = self:getLabelByName("Label_scoreTitle")
    self._scoreNum:createStroke(Colors.strokeBrown, 1)
    self._scoreTitle:createStroke(Colors.strokeBrown, 1)
    self._scoreTitle:setText(G_lang:get("LANG_FU_SCORETITLE"))

    self._loopNum = self:getLabelByName("Label_loopNum")
    self._loopTitle = self:getLabelByName("Label_loopTitle")
    self._loopNum:createStroke(Colors.strokeBrown, 1)
    self._loopTitle:createStroke(Colors.strokeBrown, 1)
    self._loopTitle:setText(G_lang:get("LANG_FU_LOOPTITLE"))

    self:attachImageTextForBtn("Button_go","Image_25")
    self:attachImageTextForBtn("Button_go2","Image_26")

    self._touziNum = self:getLabelByName("Label_touzi")
    self._touziNum:createStroke(Colors.strokeBrown, 1)

    self._scrollView = self:getScrollViewByName("ScrollView_map")
    self._mainPanel = self:getPanelByName("Panel_main")
    self._mapPanel = self:getPanelByName("Panel_bg")
    self._clickPanel = self:getPanelByName("Panel_click")
    self._endPanel = self:getPanelByName("Panel_finish")
    self._endPanel:setVisible(false)
    self._midPanel = self:getPanelByName("Panel_middle")
    self._botPanel = self:getPanelByName("Panel_bottom")
    self._showPanel = self:getPanelByName("Panel_show")
    self._showPanel:setVisible(true)
    self._shopImg = self:getImageViewByName("Image_shop")
    self._touziImg = self:getImageViewByName("Image_touzi")
    self._awardTips = self:getImageViewByName("Image_awardTips")
    self._awardTips:setVisible(false)
    self._helpButton = self:getButtonByName("Button_help")

    self._totalHeight = 0
    self._hero = nil
    self._itemList = {}
    self._posList = {}
    self._curStep = G_Me.richData:getStep()
    self._timeStart = false
    self._touziList = {}
    self._touziFinishCount = 0
    self._clickPanelClick = false
    self._animing = false --正在播动画
    self._boxList = {}
    self._firstEnter = true

    self._showLoop = G_Me.richData:getLoop()
    self._loopNum:setText(self._showLoop)

    self:initMap()
    self:initMain()
    self:createHero()

    self:showEnd(true)
    self._endPanel:setVisible(false)

    self:registerBtnClickEvent("Button_shop", function()
        --商店
        if #G_Me.richData:getShopList() == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_SHOPCLICK"))
            return
        end
        if G_Me.richData:getState() ~= 1 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT"))
            return
        end
        -- local shop = require("app.scenes.dafuweng.RichShop").create()
        -- uf_sceneManager:getCurScene():addChild(shop)
        self:showShopAnime()
    end)
    self:registerBtnClickEvent("Button_touzi", function()
        if G_Me.richData:getCurTouziNum() == 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TOUZICLICK"))
            return
        end
        local _layer = require("app.scenes.dafuweng.RichRollLayer").create()
        _layer:setCallBack(function ( )
            self:stopFace()
        end)
        uf_sceneManager:getCurScene():addChild(_layer)
    end)
    self:registerBtnClickEvent("Button_help", function()
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_FU_HELP_TITLE1"), content=G_lang:get("LANG_FU_HELP_CONTENT1")},
            {title=G_lang:get("LANG_FU_HELP_TITLE2"), content=G_lang:get("LANG_FU_HELP_CONTENT2",{num=G_Me.richData.jyRankScore})},
            {title=G_lang:get("LANG_FU_HELP_TITLE3"), content=G_lang:get("LANG_FU_HELP_CONTENT3")},
            } )
    end)
    self:registerBtnClickEvent("Button_award", function()
        local award = require("app.scenes.dafuweng.RichScoreAward").create()
        uf_sceneManager:getCurScene():addChild(award)
    end)
    self:registerBtnClickEvent("Button_bang", function()
        local top = require("app.scenes.wheel.WheelTopLayer").create(2)
        uf_sceneManager:getCurScene():addChild(top)
        -- self:addTimeCount()
        -- self._curStep = 33
        -- self:moveStep(5,1)
        -- local top = require("app.scenes.dafuweng.RichMoney").create(12345)
        -- uf_sceneManager:getCurScene():addChild(top)
        -- self:showReroll(-3)
        -- self:boxAnime({type=1,value=1,size=100},0)
    end)
    self:registerBtnClickEvent("Button_getAward", function()
        if G_Me.richData:getState() == 3 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT"))
            return
        end
        local top = require("app.scenes.wheel.WheelTopAward").create(2)
        uf_sceneManager:getCurScene():addChild(top)
    end)
    self:registerBtnClickEvent("Button_back", function()
        -- uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new())
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_go", function()
        if G_Me.userData.gold < G_Me.richData:getPrice(1) then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        self:playGame(1)
    end)
    self:registerBtnClickEvent("Button_go2", function()
        if G_Me.userData.gold < G_Me.richData:getPrice(10) then
            require("app.scenes.shop.GoldNotEnoughDialog").show()
            return
        end
        self:playGame(10)
    end)
    self:registerBtnClickEvent("Button_add", function()
        require("app.scenes.common.PurchaseScoreDialog").show(24)
    end)
    self:registerWidgetClickEvent("Panel_click", function()
        if self._clickPanelClick then
            self._clickPanelClick = false
            -- self._clickPanel:setVisible(false)
            EffectSingleMoving:stop()
            self._closeImg:removeFromParentAndCleanup(true)
            self:_goAndFlip(1,self._clickPanelClickData)
        end
    end)
end

function RichLayer:setContainer( container )
    self._container = container
end

-- function RichLayer:onBackKeyEvent( ... )
--     uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new())

--     return true
-- end

function RichLayer:onBackKeyEvent( ... )
    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.dafuweng.FuMainScene",FuCommon.RICH_TYPE_ID)
    end

    return true
end

function RichLayer:onLayerEnter()
    self.super:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_INFO, self._onRichInfoRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_MOVE, self._onRichMoveRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_REWARD, self._onGetRewardRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_RANK, self._onRichRankRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._bagChanged, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RICH_BUY, self._onRichBuyRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._buyRes, self)

    G_HandlersManager.richHandler:sendRichInfo()
    G_HandlersManager.richHandler:sendRichRankingList()
    self._moving = false
    self._animing = false
    self._firstEnter = true
    self:startFace()
    -- self:updateView()
    self:_refreshTimeLeft()
    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end
end

function RichLayer:_refreshTimeLeft(  )
    local time = G_Me.richData:getTimeLeft()
    if time < 0 then
        return
    end
    if self._timeStart then
        self:updateView()
        self._timeStart = false
    end
    if time < 1 then
        self._timeStart = true
        if G_Me.richData:getState() == 1 then
            G_HandlersManager.richHandler:sendRichRankingList()
        end
        if G_Me.richData:getState() == 2 then
            G_HandlersManager.richHandler:sendRichInfo()
        end
    end
    local timeTitle = G_Me.richData:getState() == 1 and G_lang:get("LANG_FU_TIMETITLE") or G_lang:get("LANG_FU_TIMETITLE2")
    self._timeNum:setText(G_GlobalFunc.formatTimeToHourMinSec(time))
    self._timeTitle:setText(timeTitle)
end


function RichLayer:onLayerExit()
    self.super:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
    self:stopFace()
    uf_eventManager:removeListenerWithTarget(self)
end

function RichLayer:updateView()
    if self._animing then 
        return
    end
    if G_Me.richData:getState() == 1 then
        self:showEnd(false)
    elseif G_Me.richData:getState() == 2 then
        self:showEnd(true)
    elseif G_Me.richData:getState() == 3 then
        uf_sceneManager:replaceScene(require("app.scenes.dafuweng.FuMainScene").new(FuCommon.RICH_TYPE_ID))
    end
    self:updateBase()
    self:updateDelay()
    self:updateScroll()
end

function RichLayer:showEnd(state)
    self._hero:setVisible(not state)
    for k , v in pairs(self._itemList) do 
        v:setVisible(not state)
    end
    self._endPanel:setVisible(state)
    self._midPanel:setVisible(not state)
    self._botPanel:setVisible(not state)
    self._helpButton:setVisible(not state)
    self._loopTitle:setVisible(not state)
    self._loopNum:setVisible(not state)
    if state then
        self:initEndPanel()
        self:clearBox()
    end
end

function RichLayer:_buyRes(data)
    if data.ret == NetMsg_ERROR.RET_GAME_TIME_ERROR0 then
        G_HandlersManager.wheelHandler:sendWheelInfo()
        G_HandlersManager.richHandler:sendRichInfo()
    end
end

function RichLayer:initEndPanel(  )
    self:getLabelByName("Label_hasAward1"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_hasAward2"):createStroke(Colors.strokeBrown, 1)
    if G_Me.richData:getMyRank() == 0 then
        self:getLabelByName("Label_hasAward1"):setVisible(false)
        self:getLabelByName("Label_hasAward2"):setVisible(true)
        self:getButtonByName("Button_getAward"):setVisible(false)
        self:getImageViewByName("Image_got"):setVisible(false)
    else
        self:getLabelByName("Label_hasAward1"):setVisible(true)
        self:getLabelByName("Label_hasAward2"):setVisible(false)
        -- self:getButtonByName("Button_getAward"):setVisible(true)
        if G_Me.richData.got_reward then
            self:getImageViewByName("Image_got"):setVisible(true)
            self:getButtonByName("Button_getAward"):setVisible(false)
        else
            self:getImageViewByName("Image_got"):setVisible(false)
            self:getButtonByName("Button_getAward"):setVisible(true)
        end
    end
    self:getLabelByName("Label_hasAward2"):setText(G_lang:get("LANG_WHEEL_END3"))
    if G_Me.richData.score >= G_Me.richData.jyRankScore then
        self:getLabelByName("Label_hasAward1"):setText(G_lang:get("LANG_WHEEL_END1",{rank=G_Me.richData:getMyRank()}))
    else
        self:getLabelByName("Label_hasAward1"):setText(G_lang:get("LANG_WHEEL_END2",{rank=G_Me.richData:getMyRank()}))
    end
    self:initMeiNv()

    for i = 1 , 3 do 
        if i <= #G_Me.richData.rankList then
            local info = G_Me.richData.rankList[i]
            local knightBaseInfo = knight_info.get(info.mainrole)
            self:getImageViewByName("Image_rank"..i):loadTexture("ui/text/txt/phb_"..i.."st.png")
            self:getLabelByName("Label_name"..i):createStroke(Colors.strokeBrown, 1)
            self:getLabelByName("Label_name"..i):setText(info.name)
            self:getLabelByName("Label_name"..i):setColor(Colors.qualityColors[knightBaseInfo.quality])
            self:getLabelByName("Label_score"..i):setText(info.score)
            self:getPanelByName("Panel_best"..i):setVisible(true) 
        else
            self:getPanelByName("Panel_best"..i):setVisible(false) 
        end
    end
end

function RichLayer:initMeiNv(  )
    local hero = self:getPanelByName("Panel_meizi")
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
        hero:setScale(0.8)
        -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
        -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
    end
end

function RichLayer:playGame(times)
    self:checkShop(function (  )
        self:stopFace()
        if G_Me.richData:isNeedRequestNewData() then
            G_HandlersManager.richHandler:sendRichInfo()
        end
        if G_Me.richData:getState() == 1 then
            G_HandlersManager.richHandler:sendRichMove(0,times)
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT"))
        end
    end)
end

function RichLayer:_onRichMoveRsp(data)
    if data.ret == 1 then
        self._firstEnter = false
        self._shopImg:setVisible(false)
        local dice = data.dice
        if #dice == 1 then
            self:_moveOneAnime(data)
            -- self:updateBase()
        else
            self:_moveTenAnime(data)
        end
    end
end

function RichLayer:_onRichInfoRsp(data)
    self:updateView()
    if self._curStep ~= G_Me.richData:getStep() and not self._animing then
        self._curStep = G_Me.richData:getStep()
        local posx,posy = self:getHeroDstPos()
        self:heroBreathe(false)
        self._hero:setPositionXY(self:getHeroDstPos())
        self:heroBreathe(true)
        self:updateScroll()
    end
end

function RichLayer:_moveOneAnime(data)
    self:_animeStart()
    self:showOneTouzi(data.dice[1],function ( )
        self:moveStep(data.dice[1],1,function ( )
            self:actionMoving(self._curStep,data)
        end)
    end)
    -- self:moveStep(data.dice[1],function ( )
    --     self:actionMoving(self._curStep,data)
    -- end)
end

function RichLayer:_moveTenAnime(data)
    self:_animeStart()
    self._container:removeSpeedBar()
    self._botPanel:setVisible(false)
    self:showTenTouzi(data.dice,function ( )
        self._touziFinishCount = self._touziFinishCount + 1
        if self._touziFinishCount == 10 then
            -- self._closeImg = ImageView:create()
            -- self._closeImg:loadTexture("ui/text/txt/dianjijixu.png")
            -- self._showPanel:addChild(self._closeImg)
            -- self._closeImg:setPosition(ccp(320,64))
            -- EffectSingleMoving.run(self._closeImg, "smoving_wait", nil , {position = true} )

            -- EffectSingleMoving:stop()

            -- self._clickPanelClick = true
            -- self._clickPanel:setVisible(true)
            -- self._clickPanelClickData = data

            local step = 0 
            for k , v in pairs(data.dice) do 
                step = step + v
            end
            for k , v in pairs(data.reroll) do 
                step = step + v
            end
            local curStep = self._curStep
            self:heroBreathe(false)
            self:heroFly(step,function( )
                self:heroBreathe(true)
                self:_goAndFlip(1,data,curStep)
            end)
            
        end
    end)
end

function RichLayer:_goAndFlip(index,data,step)
    local dice = data.dice
    local reroll = data.reroll
    -- self:moveStep(dice[index],2,function()
    --     if reroll[index] == 0 then
    --         self:_goAndFlip2(index,data)
    --     else
    --         self:moveStep(reroll[index],2,function()
    --                 self:_goAndFlip2(index,data)
    --         end)
    --     end
    -- end)
    -- self:jumpStep(dice[index]+reroll[index],function()
    --     self:_goAndFlip2(index,data)
    -- end)
    step = step + data.dice[index] + data.reroll[index]
    self:_goAndFlip2(index,data,step)
end

function RichLayer:_goAndFlip2(index,data,step)
    local img = self._touziList[index]
    local scaleTime = 0.1
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(scaleTime/2,0,1))
    arr:addObject(CCCallFunc:create(function()
        local item,animeType = self:_changeImg(img,data,index,step)
        local arr2 = CCArray:create()
        arr2:addObject(CCScaleTo:create(scaleTime/2,1,1))
        arr2:addObject(CCDelayTime:create(0.2))
        arr2:addObject(CCCallFunc:create(function()
            if index < 10 then
                self:_goAndFlip(index+1,data,step)
            end
        end))
        local arr3 = CCArray:create()
        arr3:addObject(CCMoveTo:create(scaleTime,ccp(self:_getDstPos(step))))
        if animeType == 1 then
            arr3:addObject(CCScaleTo:create(scaleTime,0.01))
        end
        arr3:addObject(CCRotateTo:create(scaleTime,3600))
        arr2:addObject(CCSpawn:create(arr3))
        arr2:addObject(CCCallFunc:create(function()
            if index < 10 then
                -- self:_goAndFlip(index+1,data,step)
            else
                self._showPanel:removeAllChildrenWithCleanup(true)
                self:_animeEnd()
                self._botPanel:setVisible(true)
                self._container:addSpeedBar()
                local score = 0 
                local stepList = {}
                local curStep = self._curStep
                for k , v in pairs(data.dice) do 
                    score = score + v
                    curStep = curStep - v
                end
                for k , v in pairs(data.dice) do 
                    curStep = curStep + v
                    table.insert(stepList,#stepList+1,curStep)
                end
                local awardLayer = require("app.scenes.dafuweng.RichAwardTen").create(data.award,stepList,score,function ( )
                    if #G_Me.richData:getShopList() > 0 then
                        -- local shop = require("app.scenes.dafuweng.RichShop").create()
                        -- uf_sceneManager:getCurScene():addChild(shop)
                        self:showShopAnime()
                    end
                end)
                uf_sceneManager:getCurScene():addChild(awardLayer)
            end
        end))
        item:runAction(CCSequence:create(arr2))
    end))
    img:runAction(CCSequence:create(arr))
    -- local step0 = (self._curStep-1)%35+1
    -- local info = richman_info.get(step0)
    -- local event = richman_show.get(info.square_type)
    -- self:addFace(event.face,0.4)
end

function RichLayer:_getDstPos(step)
    local step0 = (self._curStep-1)%35+1
    local step1 = (step-1)%35+1
    local info = richman_info.get(step1)
    if info.square_type == 4 then
        local pos = ccp(self._shopImg:getPosition())
        pos = self._midPanel:convertToWorldSpace(pos)
        pos = self._showPanel:convertToNodeSpace(pos)
        return pos.x,pos.y
    elseif info.square_type == 2 and info.type == 3 and info.value == 87 then
        local pos = ccp(self._touziImg:getPosition())
        pos = self._midPanel:convertToWorldSpace(pos)
        pos = self._showPanel:convertToNodeSpace(pos)
        return pos.x,pos.y
    else
        local pos = ccp(self._posList[step0].x,self._posList[step0].y)
        pos = self._mainPanel:convertToWorldSpace(pos)
        pos = self._showPanel:convertToNodeSpace(pos)
        return pos.x,pos.y+150
    end
end

function RichLayer:_changeImg(img,data,index,step)
    local award = data.award[index]
    local step0 = (step-1)%35+1
    local info = richman_info.get(step0)
    local posx,posy = img:getPosition()
    local size = img:getContentSize()
    -- posx = posx - size.width/2
    -- posy = posy - size.height/2
    img:setVisible(false)
    if info.square_type == 1 or info.square_type == 2 or info.square_type == 3 then
        local g = G_Goods.convert(award.type,award.value)
        local diImg = ImageView:create()
        diImg:loadTexture("putong_bg.png",UI_TEX_TYPE_PLIST)
        self._showPanel:addChild(diImg)
        diImg:setAnchorPoint(ccp(0.5, 0.5))
        diImg:setPositionXY(posx,posy)
        local boardImg = ImageView:create()
        boardImg:loadTexture(G_Path.getEquipColorImage(g.quality,award.type))
        diImg:addChild(boardImg)
        boardImg:setPositionXY(0,0)
        local shopImg = ImageView:create()
        shopImg:loadTexture(g.icon)
        boardImg:addChild(shopImg)
        shopImg:setPositionXY(0,0)
        local numLabel = GlobalFunc.createGameLabel("x"..award.size,20, Colors.darkColors.DESCRIPTION, Colors.strokeBrown, nil, false )
        numLabel:setAnchorPoint(ccp(1,0))
        diImg:addChild(numLabel)
        numLabel:setPositionXY(50,-48)
        if info.icon_effect == 1 then
            local node = EffectNode.new("effect_around1")     
            node:setScale(1.7) 
            node:setPosition(ccp(5,-5))
            node:play()
            diImg:addNode(node,10)
        end
        diImg:setScaleX(0)
        return diImg,1
    elseif info.square_type == 4 then
        local diImg = ImageView:create()
        diImg:loadTexture("ui/yangcheng/jx_zhuangbei_lock.png")
        self._showPanel:addChild(diImg)
        -- local size0 = diImg:getContentSize()
        diImg:setAnchorPoint(ccp(0.5, 0.5))
        diImg:setPositionXY(posx,posy)
        local boardImg = ImageView:create()
        boardImg:loadTexture("pinji_icon_cheng.png",UI_TEX_TYPE_PLIST)
        diImg:addChild(boardImg)
        boardImg:setPositionXY(0,0)
        local shopImg = ImageView:create()
        shopImg:loadTexture("ui/dafuweng/icon_shenmishangdian.png")
        boardImg:addChild(shopImg)
        shopImg:setPositionXY(0,0)
        diImg:setScaleX(0)
        return diImg,2
    end
end

function RichLayer:actionMoving(step,data,rerollTimes)
    rerollTimes = rerollTimes or 1
    local index = (step-1)%35+1
    local info = richman_info.get(index)
    if info.square_type == 1 then
        --银两
        -- local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.award)
        -- uf_sceneManager:getCurScene():addChild(_layer)
        local top = require("app.scenes.dafuweng.RichMoney").create(data.award[1].size)
        uf_sceneManager:getCurScene():addChild(top)
        self:startFace()
        self:_animeEnd()
    elseif info.square_type == 2 then
        --道具
        self:boxAnime(data.award[1],0,function ( )
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.award)
            uf_sceneManager:getCurScene():addChild(_layer)
            self:startFace()
            self:_animeEnd()
        end)
    elseif info.square_type == 3 then
        --事件
        local eventInfo = richman_event_info.get(data.event[1])
        local talkLayer = require("app.scenes.dungeon.DungeonStoryTalkLayer").create({storyId = eventInfo.dialogue,func = function( ... )
            local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.award)
            uf_sceneManager:getCurScene():addChild(_layer)
            self:startFace()
            self:_animeEnd()
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BOX_OPEN)
        end})
        uf_notifyLayer:getModelNode():addChild(talkLayer)
    elseif info.square_type == 4 then
        --商店
        -- local shop = require("app.scenes.dafuweng.RichShop").create()
        -- uf_sceneManager:getCurScene():addChild(shop)
        self:showShopAnime()
        self:startFace()
        self:_animeEnd()
    elseif info.square_type == 5 then
        --移动
        self:startFace()
        local stepMore = data.reroll[1]
        -- self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5.0),CCCallFunc:create(function()
        --             self:showReroll(stepMore,function(  )
        --                 local str = stepMore > 0 and G_lang:get("LANG_FU_GO",{num=stepMore}) or G_lang:get("LANG_FU_BACK",{num=0-stepMore})
        --                 G_MovingTip:showMovingTip(str)

        --                 self._hero:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function()
        --                         self:moveStep(stepMore,1,function ( )
        --                                 self:actionMoving(self._curStep,data)
        --                         end)
        --                 end)))
        --             end)
        --     end)))
        self:showReroll(stepMore,function(  )
            local str = stepMore > 0 and G_lang:get("LANG_FU_GO",{num=stepMore}) or G_lang:get("LANG_FU_BACK",{num=0-stepMore})
            G_MovingTip:showMovingTip(str)

            self._hero:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function()
                    self:moveStep(stepMore,1,function ( )
                            self:actionMoving(self._curStep,data)
                    end)
            end)))
        end)
    else
        self:_animeEnd()
    end

end

function RichLayer:showReroll(dst,callBack)
    local state = dst > 0 and 1 or 0
    dst = math.abs(dst)
    local size = self._showPanel:getContentSize()
    local bkImg = ImageView:create()
    bkImg:loadTexture("tanchuang-board-3.png", UI_TEX_TYPE_PLIST)
    bkImg:setSize(CCSizeMake(368, 156))
    bkImg:setScale9Enabled(true)
    bkImg:setCapInsets(CCRectMake(49, 48, 1, 1))
    self._showPanel:addChild(bkImg)
    bkImg:setPositionXY(size.width/2,size.height/2)
    
    local imgLeft = ImageView:create()
    imgLeft:loadTexture("ui/yangcheng/arrow_jinjie.png")
    imgLeft:setRotation(90)
    bkImg:addChild(imgLeft)
    imgLeft:setPosition(ccp(-100,0))

    local imgRight = ImageView:create()
    imgRight:loadTexture("ui/yangcheng/arrow_jinjie.png")
    imgRight:setRotation(-90)
    bkImg:addChild(imgRight)
    imgRight:setPosition(ccp(-20,0))

    local touzi = ImageView:create()
    bkImg:addChild(touzi)
    touzi:setPositionXY(100,0)
    touzi:loadTexture("ui/dafuweng/touzi-6.png")
    -- self:touziRun(touzi,10+state,dst,callBack,true)

    self:arrowRun(imgLeft,10+state,1-state)
    self:arrowRun(imgRight,10+state,state,function ( )
        self:touziRun(touzi,10,dst,callBack,true)
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.SCROLL_NUMBER_SHORT)
    end)

    self:stopFace()
end

function RichLayer:arrowRun(img,count,final,callBack)
    img:showAsGray((count+final)%2==0)
    self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.03),CCCallFunc:create(function()
        if count > 0 then
            self:arrowRun(img,count-1,final,callBack)
        else
            if callBack then
                callBack()
            end
        end
    end)))
end

function RichLayer:_onGetRewardRsp(data)
    if data.ret == 1 and data.type == 0 then
        local award = {}
        local id = G_Me.richData.score >= G_Me.richData.jyRankScore and 2 or 1
        for i = 1 , id do 
            local info = G_Me.richData:getAward(G_Me.richData:getMyRank(),i)
            for k = 1 , 3 do 
                local item = {type=info["type_"..k],value=info["value_"..k],size=info["size_"..k]}
                table.insert(award,#award+1,item)
            end
        end
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
        uf_notifyLayer:getModelNode():addChild(_layer,1000)
        self:updateView()
    end
    if data.ret == 1 and data.type == 1 then
        self:updateView()
    end
end

function RichLayer:_bagChanged()
    self:updateBase()
end

function RichLayer:_animeStart()
    self._clickPanel:setVisible(true)
    self._animing = true
    if G_topLayer then 
        G_topLayer:hideTemplate()
    end
end

function RichLayer:_animeEnd()
    self:updateBase()
    self:updateDelay()
    self._clickPanel:setVisible(false)
    self._animing = false
    if G_topLayer then 
        G_topLayer:resumeStatus()
    end
    if G_Me.richData:getState() == 2 then
        self:updateView()
    end
end

function RichLayer:_onRichRankRsp()
    self:updateView()
end

function RichLayer:_onRichBuyRsp()
    self:updateView()
end

function RichLayer:adapterLayer()
    self:adapterWidgetHeight("ScrollView_map", "", "", -5, -120)
    self:adapterWidgetHeight("Panel_show", "", "", -5, -120)
    self:adapterWidgetHeight("Panel_click", "", "", -5, -120)
    self:getPanelByName("Panel_move"):setPositionXY(0,(display.height-853)/2)
end

function RichLayer:moveStep(step,type,endFunc)
    self:setCount(math.abs(step))
    self:showCount(type==1)
    self:stopFace()
    self:heroBreathe(false)
    local arr = CCArray:create()
    for i = 1 , math.abs(step) do 
        arr:addObject(self:moveOneStep(step>0,type,step-i))
    end
    arr:addObject(CCCallFunc:create(function()
        self:showCount(false)
        self:heroBreathe(true)
        if endFunc then
            endFunc()
        end
    end))
    self._hero:runAction(CCSequence:create(arr))
    -- self:scrollMove(0.3*step)
end

function RichLayer:jumpStep(step,endFunc)
    self:heroBreathe(false)
    local curStep = (self._curStep-1)%totalIcon+1
    local curBak = curStep
    self._curStep = self._curStep + step
    curStep = curStep + step
    local jumpTime = 0.2
    if curStep <= totalIcon then
        local arr = CCArray:create()
        arr:addObject(CCCallFunc:create(function()
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_DOWN)
        end))
        local actionTo = CCJumpTo:create(jumpTime, ccp(self:getHeroDstPos(curStep)), 80*math.abs(step), 1)
        -- self._hero:runAction(actionTo)
        arr:addObject(actionTo)
        arr:addObject(CCCallFunc:create(function()
            local _posx,_posy = self:getHeroDstPos(curStep)
            self:scrollMove(time1,_posy)
        end))
        local seqArr = CCArray:create()
        seqArr:addObject(CCSpawn:create(arr))
        seqArr:addObject(CCCallFunc:create(function()
            self:lightItem(curStep)
            self:addDst()
        end))
        -- return CCSequence:create(seqArr)
        seqArr:addObject(CCCallFunc:create(function()
            self:heroBreathe(true)
            if endFunc then
                endFunc()
            end
        end))
        self._hero:runAction(CCSequence:create(seqArr))
    else
        local arr = CCArray:create()
        -- return self:heroJump(curStep,0.12,0.2,0.2,2,0)
        arr:addObject(self:heroJump(curStep,0.12,0.2,0.2,2,0,36-curBak))
        arr:addObject(CCCallFunc:create(function()
            self:heroBreathe(true)
            if endFunc then
                endFunc()
            end
        end))
        self._hero:runAction(CCSequence:create(arr))
    end
end

function RichLayer:moveOneStep(up,type,count)
    local time1 = (type==1) and 0.4 or 0.12
    local time2 = (type==1) and 0.5 or 0.2
    local time3 = (type==1) and 3 or 0.2
    local del = up and 1 or -1
    self._curStep = self._curStep + del
    local step = self._curStep
    if (step-1)%totalIcon+1 ~= 1 or step == 1 then
        local arr = CCArray:create()
        arr:addObject(CCCallFunc:create(function()
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_DOWN)
        end))
        local actionTo = CCJumpTo:create(time1, ccp(self:getHeroDstPos(step)), 80, 1)
        -- self._hero:runAction(actionTo)
        arr:addObject(actionTo)
        arr:addObject(CCCallFunc:create(function()
            local _posx,_posy = self:getHeroDstPos(step)
            self:scrollMove(time1,_posy)
        end))
        return CCSequence:createWithTwoActions(CCSpawn:create(arr),CCCallFunc:create(function()
            self:lightItem(step)
            self:addDst()
            self:setCount(count)
        end))
    else
        -- local arr = CCArray:create()
        -- arr:addObject(CCCallFunc:create(function()
        --     self:faceInEnd(type)
        -- end))
        -- arr:addObject(CCDelayTime:create(time3))
        -- arr:addObject(self:heroJump(step,time1,time2))
        -- return CCSequence:create(arr)
        return self:heroJump(step,time1,time2,time3,type,count,1)
    end
    -- return actionTo
end

function RichLayer:heroJump(step,time1,time2,time3,type,count,endDis)
    endDis = endDis or 1
    local arr = CCArray:create()
    local delta = ccp(-50,120)
    arr:addObject(CCCallFunc:create(function()
        self:showCount(false)
        local _posx,_posy = self:getHeroDstPos(35)
        self:scrollMove(time1,_posy+120)
    end))
    arr:addObject(CCJumpTo:create(time1,ccpAdd(ccp(self:getHeroDstPos(35)),delta),80*endDis, 1))
    arr:addObject(CCCallFunc:create(function()
        self:faceInEnd(type)
        -- self._loopNum:setText(math.floor(step/35))
        self:updateLoop()
        local posx,posy = self._hero:getPosition()
        -- self:showCount(false)
        self._yanhua = EffectNode.new("effect_xunbao_yanhua",function(event, frameIndex)
                if event == "finish" then
                    self._yanhua:removeFromParentAndCleanup(true)
                end
            end
        )      
        self._yanhua:play()
        self._mainPanel:addNode( self._yanhua,19)
        self._yanhua:setPositionXY(320,posy+250)
        if type== 1 then
            local numLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_FU_LOOPFINISH",{loop=math.floor(self._curStep/35)}),40, Colors.darkColors.TITLE_01, Colors.strokeBrown, nil, false )
            self._mainPanel:addChild(numLabel,20)
            numLabel:setPositionXY(320,posy+200)
            numLabel:setOpacity(0)
            -- local animeTime = type==1 and 4.5 or 
            local seqArr = CCArray:create()
            seqArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.5,ccp(0,50)),CCFadeIn:create(0.5)) )
            seqArr:addObject(CCDelayTime:create(2.5))
            seqArr:addObject(CCCallFuncN:create(function (node)
                node:removeFromParentAndCleanup(true)
            end))
            numLabel:runAction(CCSequence:create(seqArr) )
        end
    end))
    arr:addObject(CCDelayTime:create(time3))
    arr:addObject(CCCallFunc:create(function()
            local nodePos = self._posList[35]
            nodePos = {x=nodePos.x+delta.x,y=nodePos.y+delta.y}
            self._nodeMissa = EffectNode.new("effect_miss_a")     
            self._nodeMissa:setScale(1.4) 
            self._nodeMissa:play()
            -- self._nodeMissb = EffectNode.new("effect_miss_b")     
            -- self._nodeMissb:setScale(1.4) 
            -- self._nodeMissb:play()
            self._mainPanel:addNode(self._nodeMissa,10)
            -- self._mainPanel:addNode(self._nodeMissb,10)
            self._nodeMissa:setPosition(ccp(nodePos.x-15,nodePos.y+95))
            -- self._nodeMissb:setPosition(ccp(nodePos.x-15,nodePos.y+25))
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SPECIAL)
        end))
    arr:addObject(CCScaleTo:create(time2,0.05))
    arr:addObject(CCCallFunc:create(function()
            if self._nodeMissa then
                self._nodeMissa:removeFromParentAndCleanup(true)
            end
            -- if self._nodeMissb then
            --     self._nodeMissb:removeFromParentAndCleanup(true)
            -- end
            -- local _posx,_posy = self:getHeroDstPos(step)
            local _posx,_posy = self:getHeroDstPos(0)
            self:scrollMove(0.2,_posy)
            self._hero:setPositionXY(_posx,_posy)
        end))
    arr:addObject(CCDelayTime:create(0.2))
    arr:addObject(CCCallFunc:create(function()
            -- local nodePos = self._posList[1]
            self:clearBox()
            local nodePos = self._pos0
            self._nodeBigShowa = EffectNode.new("effect_bigshow_a")     
            self._nodeBigShowa:setScale(1.4) 
            self._nodeBigShowa:play()
            -- self._nodeBigShowb = EffectNode.new("effect_bigshow_b")     
            -- self._nodeBigShowb:setScale(1.4) 
            -- self._nodeBigShowb:play()
            self._mainPanel:addNode(self._nodeBigShowa,10)
            -- self._mainPanel:addNode(self._nodeBigShowb,10)
            self._nodeBigShowa:setPosition(ccp(nodePos.x-15,nodePos.y+95))
            -- self._nodeBigShowb:setPosition(ccp(nodePos.x-15,nodePos.y+25))
        end))
    arr:addObject(CCScaleTo:create(time2,0.4))
    arr:addObject(CCCallFunc:create(function()
            if self._nodeBigShowa then
                self._nodeBigShowa:removeFromParentAndCleanup(true)
            end
            -- if self._nodeBigShowb then
            --     self._nodeBigShowb:removeFromParentAndCleanup(true)
            -- end  
            self:showCount(type==1)
            local _posx,_posy = self:getHeroDstPos(step)
            self:scrollMove(time1,_posy)
        end))
    local dis = (step-1)%35+1
    arr:addObject(CCJumpTo:create(time1,ccp(self:getHeroDstPos(step)),80*dis, 1))
    arr:addObject(CCCallFunc:create(function()
        self:setCount(count)
    end))
    return CCSequence:create(arr)
end

function RichLayer:heroFly(step,endFunc)
    local curStep = self._curStep
    self._curStep = self._curStep + step
    local dstStep = self._curStep
    local time1 = 0.4
    local time2 = 0.5
    local arr = CCArray:create()
    local delta = ccp(-50,120)
    arr:addObject(CCCallFunc:create(function()
        local _posx,_posy = self:getHeroDstPos(curStep)
        self:scrollMove(time1,_posy+120)
    end))
    arr:addObject(CCCallFunc:create(function()
            local nodePos = self._posList[(curStep-1)%35+1]
            -- nodePos = {x=nodePos.x+delta.x,y=nodePos.y+delta.y}
            self._nodeMissa = EffectNode.new("effect_miss_a")     
            self._nodeMissa:setScale(1.4) 
            self._nodeMissa:play()
            self._nodeMissb = EffectNode.new("effect_miss_b")     
            self._nodeMissb:setScale(1.4) 
            self._nodeMissb:play()
            self._mainPanel:addNode(self._nodeMissa,10)
            self._mainPanel:addNode(self._nodeMissb,10)
            self._nodeMissa:setPosition(ccp(nodePos.x-15,nodePos.y+95))
            self._nodeMissb:setPosition(ccp(nodePos.x-15,nodePos.y+25))
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_SPECIAL)
        end))
    arr:addObject(CCScaleTo:create(time2,0.05))
    arr:addObject(CCCallFunc:create(function()
            if self._nodeMissa then
                self._nodeMissa:removeFromParentAndCleanup(true)
            end
            if self._nodeMissb then
                self._nodeMissb:removeFromParentAndCleanup(true)
            end
            local _posx,_posy = self:getHeroDstPos(dstStep)
            self:scrollMove(0.2,_posy)
            self._hero:setPositionXY(_posx,_posy)
        end))
    arr:addObject(CCDelayTime:create(0.2))
    arr:addObject(CCCallFunc:create(function()
            local nodePos = self._posList[(dstStep-1)%35+1]
            self:clearBox()
            self._nodeBigShowa = EffectNode.new("effect_bigshow_a")     
            self._nodeBigShowa:setScale(1.4) 
            self._nodeBigShowa:play()
            self._nodeBigShowb = EffectNode.new("effect_bigshow_b")     
            self._nodeBigShowb:setScale(1.4) 
            self._nodeBigShowb:play()
            self._mainPanel:addNode(self._nodeBigShowa,10)
            self._mainPanel:addNode(self._nodeBigShowb,10)
            self._nodeBigShowa:setPosition(ccp(nodePos.x-15,nodePos.y+95))
            self._nodeBigShowb:setPosition(ccp(nodePos.x-15,nodePos.y+25))
        end))
    arr:addObject(CCScaleTo:create(time2,0.4))
    arr:addObject(CCCallFunc:create(function()
            if self._nodeBigShowa then
                self._nodeBigShowa:removeFromParentAndCleanup(true)
            end
            if self._nodeBigShowb then
                self._nodeBigShowb:removeFromParentAndCleanup(true)
            end  
            if endFunc then
                endFunc()
            end
        end))
    self._hero:runAction(CCSequence:create(arr)) 
end

function RichLayer:updateBase()
    local rank = G_Me.richData:getMyRank()
    self._bangNum:setText(rank <= 0 and G_lang:get("LANG_WHEEL_NORANK") or rank)
    self._scoreNum:setText(G_Me.richData.score)
    -- self._loopNum:setText(G_Me.richData:getLoop())
    -- local left = G_Me.richData:getCurQuanNum()
    local cost1 = G_Me.richData:getPrice(1)
    local cost2 = G_Me.richData:getPrice(10)
    self._costNum1:setText(cost1)
    self._costNum1:setColor(G_Me.userData.gold >= cost1 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)
    self._costNum2:setText(cost2)
    self._costNum2:setColor(G_Me.userData.gold >= cost2 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)

    self._costNum1:setVisible(cost1>0)
    self._costNum2:setVisible(cost2>0)
    self._costImg1:setVisible(cost1>0)
    self._costImg2:setVisible(cost2>0)
    self._costTitle1:setVisible(cost1>0)
    self._costTitle2:setVisible(cost2>0)
    self._costFree1:setVisible(cost1==0)
    if cost1 == 0 then
        self._costFree1:setText(G_lang:get("LANG_WHEEL_FREE2",{num=G_Me.richData:getFreeLeft()}))
    end
    self._costFree2:setVisible(cost2==0)

    self._awardTips:setVisible(G_Me.richData:hasAward())

    self:updateLoop()
end

function RichLayer:updateLoop()
    if G_Me.richData:getLoop() > self._showLoop then
        -- self._showLoop = G_Me.richData:getLoop()
        -- self._loopNum:setText(self._showLoop)
        local _time = 0.5
        local _end = G_Me.richData:getLoop()
        local _start = self._showLoop
        local action1 = CCSequence:createWithTwoActions(CCScaleTo:create(_time/2, 2), CCScaleTo:create(_time/2, 1))
        local growupNumber = CCNumberGrowupAction:create(_start, _end, _time, function ( number )
            self._loopNum:setText(number)
        end)
        action1 = CCSpawn:createWithTwoActions(growupNumber, action1)

        self._loopNum:runAction(action1)
        self._showLoop = G_Me.richData:getLoop()
    end
end

function RichLayer:updateDelay()
    local touziNum = G_Me.richData:getCurTouziNum()
    self._touziNum:setText("x"..touziNum)
    self:showTouzi(touziNum>0)
    self:showShop(#G_Me.richData:getShopList()>0)
end

function RichLayer:showTouzi(show)
    -- self:getImageViewByName("Image_touzi"):showAsGray(not show)
    -- self:getImageViewByName("Image_touziImg"):showAsGray(not show)
    -- self:getImageViewByName("Image_touziTxt"):showAsGray(not show)
    -- self:getButtonByName("Button_touzi"):showAsGray(not show)
    -- self._touziNum:setVisible(show)
    self._touziImg:setVisible(show)
end

function RichLayer:showShop(show)
    -- self:getImageViewByName("Image_shop"):showAsGray(not show)
    -- self:getImageViewByName("Image_shopImg"):showAsGray(not show)
    -- self:getImageViewByName("Image_shopTxt"):showAsGray(not show)
    -- self:getButtonByName("Button_shop"):showAsGray(not show)
    self._shopImg:setVisible(show)
end

function RichLayer:updateScroll()
    local posx,posy = self:getHeroDstPos()
    self._scrollView:jumpToPercentVertical(math.min(1,(1-(posy-600+posy*1200/self._totalHeight)/self._totalHeight))*100)
end

function RichLayer:scrollMove(time,posy)
    time = time or 0.3
    local _posx,_posy = self:getHeroDstPos()
    posy = posy or _posy
    self._scrollView:scrollToPercentVertical(math.min(1,(1-(posy-600+posy*1200/self._totalHeight)/self._totalHeight))*100,time,false)
end

function RichLayer:getHeroDstPos(step)
    step = step or self._curStep
    if step == 0 then
        return self._pos0.x,self._pos0.y
    end
    local pos = self._posList[(step-1)%totalIcon+1]
    return pos.x-25,pos.y
end

function RichLayer:initMap()
    local height = 0 
    local max = 8
    for index = 1 , max do 
        local mapItem = ImageView:create()
        local picName = "ui/dafuweng/mapMiddle.png"
        picName = (index == 1) and "ui/dafuweng/mapBegin.png" or picName
        picName = (index == max) and "ui/dafuweng/mapEnd.png" or picName
        mapItem:loadTexture(picName)
        self._mainPanel:addChild(mapItem)
        mapItem:setZOrder(1)
        mapItem:setScale(2.0)
        local rect = mapItem:getContentSize()
        mapItem:setPositionXY(rect.width,height+rect.height)
        height = height + rect.height*2
    end
    self._totalHeight = height
    self._scrollView:setInnerContainerSize(CCSizeMake(640,height))
    local men = ImageView:create()
    local menName = "ui/dafuweng/qidiandamen.png"
    men:loadTexture(menName)
    self._mainPanel:addChild(men)
    men:setScale(2.0)
    men:setZOrder(5)
    men:setPosition(ccp(380,450))

    local deng = EffectNode.new("effect_fudenglong")    
    deng:setScale(0.58) 
    deng:play()
    deng:setPosition(ccp(-12,15))
    men:addNode(deng)

    local zhongdian = ImageView:create()
    local zhongdianName = "ui/dafuweng/icon_zhongdian.png"
    zhongdian:loadTexture(zhongdianName)
    self._mainPanel:addChild(zhongdian)
    zhongdian:setZOrder(3)
    zhongdian:setPosition(ccp(260,self._totalHeight - 400))
end

function RichLayer:createHero()
    local resid = G_Me.dressData:getDressedPic()
    self._hero = KnightPic.createKnightPic(resid,self._mainPanel,"knight_img",false)
    self._hero:setScale(0.4)
    self._hero:setZOrder(9)
    self._hero:setAnchorPoint(ccp(0.5,0))
    self._hero:setPositionXY(self:getHeroDstPos())
    local config = decodeJsonFile(G_Path.getKnightPicConfig(resid))
    self._heroDstPos = ccp(tonumber(config.shadow_x - config.x),  tonumber(config.shadow_y - config.y)+250)
    local shadow = CCSprite:create(  G_Path.getKnightShadow()  )
    self._hero:addNode(shadow, -3) 
    shadow:setPosition(self._heroDstPos)
    self:addTimeCount()
    self:showCount(false)
    self:lightItem(self._curStep)
    self:heroBreathe(true)
end

function RichLayer:heroBreathe(breathe)
    if breathe then
        if not self._bossEffect then
            self._bossEffect = EffectSingleMoving.run(self._hero, "smoving_idle", nil, {})
        end
    else
        if self._bossEffect then
            self._bossEffect:stop()
            self._bossEffect = nil
            self._hero:setScale(0.4)
        end
    end
end

function RichLayer:initMain()
    for index = 1 , richman_info.getLength() do
        local info = richman_info.get(index)
        local item = Button:create()
        item:setTouchEnabled(true)
        item:loadTextureNormal(info.icon)
        item:setName("item_"..index)
        local posx,posy = self:createPos(index)
        self._mainPanel:addChild(item)
        item:setZOrder(2)
        item:setPositionXY(posx,posy)
        table.insert(self._itemList,#self._itemList+1,item)
        table.insert(self._posList,#self._posList+1,{x=posx,y=posy})
        self:registerWidgetClickEvent("item_"..index, function()
            local _layer = require("app.scenes.dafuweng.RichItemLayer").create(index)
            uf_sceneManager:getCurScene():addChild(_layer)
        end)
    end
    local pos0 = self._posList[1]
    self._pos0 = ccp(pos0.x,pos0.y-250)

    local nodePos = self._pos0
    self._nodeBigShow = EffectNode.new("effect_bigshow_1")     
    self._nodeBigShow:setScale(1.4) 
    self._nodeBigShow:play()
    self._nodeBigShow:setPosition(ccp(nodePos.x-15,nodePos.y+25))
    self._mainPanel:addNode(self._nodeBigShow,8)

    local delta = ccp(-50,120)
    local nodePos2 = self._posList[35]
    nodePos2 = {x=nodePos2.x+delta.x,y=nodePos2.y+delta.y}
    self._nodeMiss = EffectNode.new("effect_miss_1")     
    self._nodeMiss:setScale(1.4) 
    self._nodeMiss:play()
    self._mainPanel:addNode(self._nodeMiss,8)
    self._nodeMiss:setPosition(ccp(nodePos2.x-15,nodePos2.y+25))
end

function RichLayer:createPos(index)
    local rect = self._mainPanel:getContentSize()
    local rectX = 640
    local rectY = self._totalHeight
    local offsetX1 = 220
    local offsetX2 = 230
    local offsetY1 = 600
    local offsetY2 = 450
    -- local num = 3
    -- local ceng = math.floor((index+1) / num)
    -- local xindex = (index+1)%num + 1
    -- xindex = (ceng%2 == 0 ) and xindex or num+1-xindex
    -- local other = (index==richman_info.getLength()) and 1 or 0
    -- local posx = (rectX-offsetX1-offsetX2)/(num+1)*(xindex+other) + offsetX1
    local num = 7
    local xindex = (index+3)%num + 1
    local mode = xindex > num/2 and 1 or 0
    xindex = (mode == 1) and num+1-xindex or xindex
    local other = (index==richman_info.getLength()) and -1 or 0
    other = 0
    local posx = (rectX-offsetX1-offsetX2)/(3+mode)*(xindex+other) + offsetX1
    local posy = (rectY - offsetY1 - offsetY2)/totalIcon*index + offsetY2
    return posx,posy
end

function RichLayer:showOneTouzi(dst,callBack)
    local size = self._showPanel:getContentSize()
    local touzi = ImageView:create()
    self._showPanel:addChild(touzi)
    touzi:setScale(1.5)
    touzi:setPositionXY(size.width/2,size.height/2)
    self:touziRun(touzi,10,dst,callBack,true)
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.SCROLL_NUMBER_SHORT)
end

function RichLayer:showTenTouzi(dst,callBack)
    self._touziFinishCount = 0
    local size = self._showPanel:getContentSize()
    self._touziList = {}
    for i = 1 , 10 do 
        local touzi = ImageView:create()
        self._showPanel:addChild(touzi)
        table.insert(self._touziList,#self._touziList+1,touzi)
        local x = ((i-1)%5)*128+64
        local y = (1-math.floor((i-1)/5))*128+64+128
        touzi:setPositionXY(x,y)
        self:touziRun(touzi,10,dst[i],callBack,false)
    end
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.SCROLL_NUMBER_SHORT)
end

function RichLayer:touziRun(img,left,final,callBack,clean)
    if left == 0 then
        img:loadTexture("ui/dafuweng/touzi-"..final..".png")
        self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5),CCCallFunc:create(function()
            if clean then
                self._showPanel:removeAllChildrenWithCleanup(true)
            end
            if callBack then
                callBack(self)
            end
        end)))
    else
        local rand = math.floor(math.random()*6)+1
        img:loadTexture("ui/dafuweng/touzi-"..rand..".png")
        self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.03),CCCallFunc:create(function()
            self:touziRun(img,left-1,final,callBack,clean)
        end)))
    end
end

function RichLayer:lightItem(index)
    -- index = (index-1)%35+1
    -- local before = index - 1 
    -- before = before > 0 and before or before + 35

    -- self._itemList[index]:setOpacity(127)
    -- self._itemList[before]:setOpacity(255)
    -- self._nodelight = EffectNode.new("effect_bigshow_b")     
    -- self._nodelight:setScale(1.4) 
    -- self._nodelight:play()
    -- self._itemList[index]:addNode(self._nodelight)
end

function RichLayer:addDst()
    if self.dustEffect then
        self.dustEffect:removeFromParentAndCleanup(true)
        self.dustEffect = nil
    end
    self.dustEffect = require("app.common.effects.EffectNode").new("effect_card_dust", function(event) 
        if event == "finish" then
            self.dustEffect:removeFromParentAndCleanup(true)
            self.dustEffect = nil
        end
    end) 
    self.dustEffect:play()
    self.dustEffect:setPosition(self._heroDstPos)
    self.dustEffect:setScale(2.0)
    self._hero:addNode(self.dustEffect)
end

function RichLayer:addFace(id,time,func)
    local img = ImageView:create()
    img:loadTexture("ui/chat/face/"..id..".png")
    img:setAnchorPoint(ccp(0,0))
    img:setScale(0.1)
    local baseScale = CCScaleTo:create(0.18,2.5)
    local animeScale = CCEaseBounceOut:create(baseScale)
    self._hero:addChild(img)
    img:setPositionXY(180,350)
    local arr = CCArray:create()
    arr:addObject(animeScale)
    arr:addObject(CCDelayTime:create(time-0.18))
    arr:addObject(CCCallFunc:create(function()
        if self._faceImg then
            self._faceImg:removeFromParentAndCleanup(true)
            self._faceImg = nil
        end
        if func then
            func()
        end
    end))
    img:runAction(CCSequence:create(arr))
    self._faceImg = img
end

function RichLayer:addTimeCount()
    local img = ImageView:create()
    img:loadTexture("ui/city/qipao_taofa.png")
    img:setAnchorPoint(ccp(0.5,0.5))
    self._hero:addChild(img)
    img:setScale(2.0)
    img:setPositionXY(180+50,350+90)
    local label = ui.newBMFontLabel{
                text = "6",
                -- font = G_Path.getBattleCriticalLabelFont(),
                font = "ui/font/vip2.fnt",
                align = ui.TEXT_ALIGN_CENTER
            }
    label:setScale(2.5)
    label:setPositionXY(-5,5)
    img:addNode(label)
    self._countImg = img
    self._countLabel = label
end

function RichLayer:showCount(show)
    self._countImg:setVisible(show)
end

function RichLayer:setCount(count)
    self._countLabel:setString(count)
end

function RichLayer:startFace()
    local step = self._curStep
    local info = richman_info.get((step-1)%35+1)
    local curType = (step==0 or self._firstEnter) and 7 or info.square_type
    local event = richman_show.get(curType)
    self._faceStart = true
    self:addFace(event.face,2,function ( )
        if not self._faceStart then
            return
        end
        self:addDialog(event.chat,3,function ( )
            if not self._faceStart then
                return
            end
            self._faceAction = CCSequence:createWithTwoActions(CCDelayTime:create(4.0),CCCallFunc:create(function()
                if not self._faceStart then
                    return
                end
                self:startFace()
            end))
            self:runAction(self._faceAction)
        end)
    end)
end

function RichLayer:stopFace()
    self._faceStart = false
    if self._faceImg then
        transition.stopTarget(self._faceImg)
        self._faceImg:removeFromParentAndCleanup(true)
        self._faceImg = nil
    end
    if self._dialogImg then
        transition.stopTarget(self._dialogImg)
        self._dialogImg:removeFromParentAndCleanup(true)
        self._dialogImg = nil
    end
    if self._faceAction then
        transition.removeAction(self._faceAction)
        self._faceAction = nil
    end
end

function RichLayer:faceInEnd(type,callBack)
    local myType = type
    local time = (myType==1) and 1 or 0.2
    local event = richman_show.get(6)
    self:addFace(event.face,time,function ( )
        if myType == 1 then
            self:addDialog(G_lang:getByString(G_lang:get("LANG_FU_ENDFACE",{num=math.floor(self._curStep/35)})),2,function ( )
                    if callBack then
                        callBack()
                    end
            end)
        else
            if callBack then
                callBack()
            end
        end
    end)
end

function RichLayer:addDialog(txt,time,func)
    local img = ImageView:create()
    img:loadTexture("ui/storydungeon/qipao.png")
    img:setAnchorPoint(ccp(0,0.5))
    img:setScale(0.1)
    local width = img:getContentSize().width
    local baseScale = CCScaleTo:create(0.18,1.5)
    local animeScale = CCEaseBounceOut:create(baseScale)
    self._hero:addChild(img,1)
    img:setPositionXY(180,300)
    -- local textLabel = GlobalFunc.createGameLabel(txt, 20, Colors.lightColors.DESCRIPTION, nil, CCSizeMake(120, 0), true )
    -- img:addChild(textLabel,5)
    -- textLabel:setAnchorPoint(ccp(0.5,0.5))
    -- textLabel:setScale(1.66)
    -- textLabel:setPositionXY(160,0)
    local richText = CCSRichText:create(120, 100)
    richText:setFontSize(20)
    richText:setFontName(G_Path.getBattleLabelFont())
    local color = Colors.lightColors.DESCRIPTION
    richText:setColor(color)
    richText:setShowTextFromTop(true)
    richText:setPosition(ccp(160,0))
    richText:appendContent(txt, color)
    richText:reloadData()
    richText:setScale(1.66)
    img:addChild(richText,5)
    local arr = CCArray:create()
    arr:addObject(animeScale)
    arr:addObject(CCDelayTime:create(time-0.18))
    arr:addObject(CCCallFunc:create(function()
        if self._dialogImg then
            self._dialogImg:removeFromParentAndCleanup(true)
            self._dialogImg = nil
        end
        if func then
            func()
        end
    end))
    img:runAction(CCSequence:create(arr))
    self._dialogImg = img
    self._dialogLabel = textLabel
end

function RichLayer:checkShop(callBack)
    if G_Me.richData:hasShopLeft() then
        local str = G_lang:get("LANG_FU_SHOPCHECK")
        MessageBoxEx.showYesNoMessage(nil,str,false,function()
            if callBack then
                callBack()
            end
        end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Richman)
    else
        if callBack then
            callBack()
        end
    end
end

function RichLayer:showShopAnime()
    local pt = self._midPanel:convertToWorldSpace(ccp(self._shopImg:getPosition()))
    local shop = require("app.scenes.dafuweng.RichShop").create(pt)
    uf_sceneManager:getCurScene():addChild(shop)
end

function RichLayer:boxAnime(award,step,callBack)
    if not step or step==0 then
        step = self._curStep
    end
    local boxPic1 = {"ui/dungeon/baoxiangtong_guan.png","ui/dungeon/baoxiangyin_guan.png","ui/dungeon/baoxiangjin_guan.png"}
    local boxPic2 = {"ui/dungeon/baoxiangtong_kong.png","ui/dungeon/baoxiangyin_kong.png","ui/dungeon/baoxiangjin_kong.png"}
    local step0 = (self._curStep-1)%35+1
    local info = richman_info.get(step0)
    local posx,posy = self:getHeroDstPos(step)
    local box = ImageView:create()
    box:loadTexture(boxPic1[info.effect])
    local baseX = 150
    local baseY = 300
    baseX = posx<display.width/2 and baseX or 0-baseX
    local startPosX = posx+baseX
    local startPosY = baseY + posy
    self._mainPanel:addChild(box,20)
    table.insert(self._boxList,#self._boxList+1,box)
    box:setPositionXY(startPosX,startPosY)
    -- G_SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_BOX)
    
    local arr = CCArray:create()
    arr:addObject(CCEaseIn:create(CCMoveBy:create(0.3,ccp(0,15-baseY)),2))
    arr:addObject(CCCallFunc:create(function()
        self.boxDustEffect = require("app.common.effects.EffectNode").new("effect_card_dust", function(event) 
            if event == "finish" then
                self.boxDustEffect:removeFromParentAndCleanup(true)
                self.boxDustEffect = nil
            end
        end) 
        self.boxDustEffect:play()
        self.boxDustEffect:setPositionXY(startPosX,posy+15-31)
        self.boxDustEffect:setScale(0.5)
        self._mainPanel:addNode(self.boxDustEffect,30)
        G_SoundManager:playSound(require("app.const.SoundConst").BattleSound.BATTLE_BOX)
    end))
    arr:addObject(CCDelayTime:create(0.1))
    arr:addObject(self:shakeAction(3))
    arr:addObject(CCDelayTime:create(0.2))
    arr:addObject(CCCallFunc:create(function()
        local box = self._boxList[#self._boxList]
        box:loadTexture(boxPic2[info.effect])
        deltaPos = ((info.effect==2) and ccp(5,5) or ccp(4,13))
        box:setPosition(ccpAdd(ccp(box:getPosition()),deltaPos))
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BOX_OPEN)

        local g = G_Goods.convert(award.type,award.value,award.size)
        local diImg = ImageView:create()
        diImg:loadTexture("putong_bg.png",UI_TEX_TYPE_PLIST)
        self._mainPanel:addChild(diImg,30)
        diImg:setAnchorPoint(ccp(0.5, 0.5))
        diImg:setPosition(ccpAdd(ccp(box:getPosition()),ccp(-deltaPos.x,0)))
        local boardImg = ImageView:create()
        boardImg:loadTexture(G_Path.getEquipColorImage(g.quality,award.type))
        diImg:addChild(boardImg)
        boardImg:setPositionXY(0,0)
        local shopImg = ImageView:create()
        shopImg:loadTexture(g.icon)
        boardImg:addChild(shopImg)
        shopImg:setPositionXY(0,0)
        local numLabel = GlobalFunc.createGameLabel("x"..award.size,20, Colors.darkColors.DESCRIPTION, Colors.strokeBrown, nil, false )
        numLabel:setAnchorPoint(ccp(1,0))
        diImg:addChild(numLabel)
        numLabel:setPositionXY(50,-48)
        diImg:setScale(0.1)

        local effectNode = EffectNode.new("effect_box_light", function(event, frameIndex) end)      
        effectNode:play()
        effectNode:setPosition(ccp(10,15))
        effectNode:setScale(0.7)
        box:addNode(effectNode)

        local seqArr = CCArray:create()
        seqArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2,ccp(0,30)),CCScaleTo:create(0.2,0.75)))
        seqArr:addObject(CCDelayTime:create(0.3))
        seqArr:addObject(CCCallFunc:create(function ()
            local box = self._boxList[#self._boxList]
            box:removeAllNodes()
        end))
        local spArray = CCArray:create()
        local dstPos = nil
        if award.type == 3 and award.value == 87 then
            dstPos = ccp(self._touziImg:getPosition())
            dstPos = self._midPanel:convertToWorldSpace(dstPos)
            dstPos = self._mainPanel:convertToNodeSpace(dstPos)
        else
            dstPos = ccpAdd(ccp(self._hero:getPosition()),ccp(0,80))
        end
        spArray:addObject(CCJumpTo:create(0.3,dstPos,80,1))
        spArray:addObject(CCRotateTo:create(0.3,720))
        spArray:addObject(CCScaleTo:create(0.3,0.1))
        seqArr:addObject(CCSpawn:create(spArray))
        seqArr:addObject(CCCallFuncN:create(function(node)
            node:removeFromParentAndCleanup(true)
            if callBack then
                callBack()
            end
        end))
        diImg:runAction(CCSequence:create(seqArr))
    end))
    box:runAction(CCSequence:create(arr))
end

function RichLayer:shakeAction(times)
    local sqArr = CCArray:create()
    local time0 = 0.02
    local delta = 2
    local degree = 3
    for i = 1 , times do 
        sqArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(time0,ccp(0,delta)),CCRotateTo:create(time0,degree)))
        sqArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(time0,ccp(0,-delta)),CCRotateTo:create(time0,0)))
        sqArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(time0,ccp(0,delta)),CCRotateTo:create(time0,-degree)))
        sqArr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(time0,ccp(0,-delta)),CCRotateTo:create(time0,0)))
    end
    return CCSequence:create(sqArr)
end

function RichLayer:clearBox()
    for k , v in pairs(self._boxList) do 
        v:removeFromParentAndCleanup(true)
    end
    self._boxList = {}
end

return RichLayer

