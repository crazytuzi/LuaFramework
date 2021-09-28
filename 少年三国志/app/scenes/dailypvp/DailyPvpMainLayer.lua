
local DailyPvpMainLayer = class ("DailyPvpMainLayer", UFCCSNormalLayer)
local KnightPic = require("app.scenes.common.KnightPic")
local DailyPvpConst = require("app.const.DailyPvpConst")
require("app.const.ShopType")
require("app.cfg.knight_info")
require("app.cfg.daily_crosspvp_rank_title")

function DailyPvpMainLayer.create(...)   
    return DailyPvpMainLayer.new("ui_layout/dailypvp_MainLayer.json", ...) 
end

function DailyPvpMainLayer:ctor(json,invite,...)
    self.super.ctor(self, ...)

    self._invite = invite
    self._heroPanel = self:getPanelByName("Panel_hero")
    self:initLabels()
    self:updateHero()
    self:initButtons()
    self._matchLayer = nil

    self:getPanelByName("Panel_rongyuRank"):setVisible(false)
end

function DailyPvpMainLayer:initLabels()
    self:getLabelByName("Label_scoreTag"):createStroke(Colors.strokeBrown, 1)
    self._scoreLabel = self:getLabelByName("Label_score")
    self._scoreLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyuTag"):createStroke(Colors.strokeBrown, 1)
    self._rongyuLabel = self:getLabelByName("Label_rongyu")
    self._rongyuLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyuRankTag"):createStroke(Colors.strokeBrown, 1)
    self._rongyuRankLabel = self:getLabelByName("Label_rongyuRank")
    self._rongyuRankLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_auto"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_team"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_timesLeftDesc"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_tips"):createStroke(Colors.strokeBrown, 1)
    self._timesLeftLabel = self:getLabelByName("Label_timesLeft")
    self._timesLeftLabel:createStroke(Colors.strokeBrown, 1)
    self._nameTitleLabel = self:getLabelByName("Label_nameTitle")
    self._nameTitleLabel:createStroke(Colors.strokeBrown, 1)
    self._nameLabel = self:getLabelByName("Label_name")
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._zhanliLabel = self:getLabelByName("Label_zhanli")
    self._zhanliLabel:createStroke(Colors.strokeBrown, 1)
    self._vipImg = self:getImageViewByName("Image_vipNum")
end

function DailyPvpMainLayer:updateLabels()
    local rank = G_Me.dailyPvpData:getRank()
    local rankStr = rank > 0 and G_lang:get("LANG_DAILY_MINGCI",{rank=rank}) or "("..G_lang:get("LANG_WHEEL_NORANK")..")"
    -- self._rongyuRankLabel:setText(rank > 0 and rank or G_lang:get("LANG_WHEEL_NORANK"))
    self._scoreLabel:setText(G_Me.userData.dailyPVPScore)
    self._rongyuLabel:setText(G_Me.dailyPvpData:getHonor()..rankStr)
    self._timesLeftLabel:setText(G_Me.dailyPvpData:getAwardCountLeft())

    local titleId = G_Me.dailyPvpData:getTitle()
    titleId = (titleId > 0 and titleId < 8) and titleId or 7
    local titleInfo = daily_crosspvp_rank_title.get(titleId)
    self._nameTitleLabel:setText(titleInfo.text)
    self._nameTitleLabel:setColor(Colors.qualityColors[titleInfo.quality])
    self._nameLabel:setText(G_Me.userData.name)
    local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, 1)
    local info = knight_info.get(baseId)
    self._nameLabel:setColor(Colors.qualityColors[info.quality])
    self._zhanliLabel:setText(G_lang:get("LANG_DAILY_ZHANLI")..GlobalFunc.ConvertNumToCharacter4(G_Me.userData.fight_value))
    self._vipImg:loadTexture("ui/vip/vip_lv_"..G_Me.userData.vip..".png")

    self:getImageViewByName("Image_inviteTips"):setVisible(G_Me.dailyPvpData:needTips())
    self:showWidgetByName("Image_shopTips",G_Me.shopData:checkAwardTipsByType(SCORE_TYPE.DAILY_PVP))
end

function DailyPvpMainLayer:updateHero()
    self._heroPanel:removeAllChildrenWithCleanup(true)

    local hero = KnightPic.createKnightPic( G_Me.dressData:getDressedPic(), self._heroPanel, "meinv" )
    self._heroPanel:setScale(0.5)
    -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    -- self._bossEffect = EffectSingleMoving.run(hero, "smoving_idle", nil, {})
end

function DailyPvpMainLayer:initButtons()
    self:registerBtnClickEvent("Button_back", function()
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_help", function()
        require("app.scenes.common.CommonHelpLayer").show({
            {title=G_lang:get("LANG_DAILY_HELP_TITLE1"), content=G_lang:get("LANG_DAILY_HELP_TEXT1")},
            {title=G_lang:get("LANG_DAILY_HELP_TITLE2"), content=G_lang:get("LANG_DAILY_HELP_TEXT2")},
            {title=G_lang:get("LANG_DAILY_HELP_TITLE3"), content=G_lang:get("LANG_DAILY_HELP_TEXT3")},
            {title=G_lang:get("LANG_DAILY_HELP_TITLE4"), content=G_lang:get("LANG_DAILY_HELP_TEXT4")},
            } )
    end)
    self:registerBtnClickEvent("Button_invite", function()
        local layer = require("app.scenes.dailypvp.DailyPvpInvitedLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    self:registerBtnClickEvent("Button_shop", function()
        -- G_HandlersManager.dailyPvpHandler:sendTeamPVPLeave()
        require("app.const.ShopType")
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.DAILY_PVP))
    end)
    self:registerBtnClickEvent("Button_rank", function()
        local layer = require("app.scenes.dailypvp.DailyPvpTopLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    self:registerBtnClickEvent("Button_replay", function()
        local layer = require("app.scenes.dailypvp.DailyPvpReplayLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    self:registerBtnClickEvent("Button_auto", function()
        G_HandlersManager.dailyPvpHandler:sendTeamPVPJoinTeam()
    end)
    self:registerBtnClickEvent("Button_team", function()
        G_HandlersManager.dailyPvpHandler:sendTeamPVPCreateTeam()
    end)
    self:registerBtnClickEvent("Button_add", function()
        self:buyTimes()
    end)
end

function DailyPvpMainLayer:buyTimes()
    local priceData = shop_price_info.get(31,G_Me.dailyPvpData:getBuyCount()+1)
    if not priceData then
        G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_BUY_OVER"))
        return
    end
    local price = priceData.price
    if G_Me.userData.gold < price then
        require("app.scenes.shop.GoldNotEnoughDialog").show()
        return
    else
        MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_DAILY_BUY_TIMES",{gold=price}), false, 
                    function ( ... )
                        G_HandlersManager.dailyPvpHandler:sendTeamPVPBuyAwardCnt()
                    end)
    end
end

function DailyPvpMainLayer:adapterLayer()
    
end

function DailyPvpMainLayer:onLayerEnter()
    self:registerKeypadEvent(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPSTATUS, self._onGetStatus, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBUYAWARDCNT, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITEDJOINTEAM, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITECANCELED, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBEINVITED, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPGETUSERINFO, self.updateView, self)

    self:updateLabels()
    G_HandlersManager.dailyPvpHandler:sendTeamPVPStatus()
    G_HandlersManager.dailyPvpHandler:sendTeamPVPGetUserInfo()

    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end
end

function DailyPvpMainLayer:_refreshTimeLeft()
    if G_Me.dailyPvpData:isNeedRequestNewData() then
        G_HandlersManager.dailyPvpHandler:sendTeamPVPGetUserInfo()
    end
end

function DailyPvpMainLayer:_onGetStatus()
    self:updateView()
end

function DailyPvpMainLayer:updateView()
    local status = G_Me.dailyPvpData:getStatus()
    if status == DailyPvpConst.NOTEAM or status == DailyPvpConst.MATCHING_TEAM then
        self:updateLabels()
        if status == DailyPvpConst.MATCHING_TEAM then
            if not self._matchLayer then
                self._matchLayer = require("app.scenes.dailypvp.DailyPvpMatchLayer").show()
            end
        else
            if self._matchLayer then
                self._matchLayer:close()
                self._matchLayer = nil
            end
        end

        if self._invite then
            self._invite = false
            local layer = require("app.scenes.dailypvp.DailyPvpInvitedLayer").create()
            uf_sceneManager:getCurScene():addChild(layer)
        end
    else
        uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpTeamScene").new())
    end
end

function DailyPvpMainLayer:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
end

function DailyPvpMainLayer:onBackKeyEvent( ... )
    local packScene = G_GlobalFunc.createPackScene(self)
    if packScene then 
       uf_sceneManager:replaceScene(packScene)
    else
       GlobalFunc.popSceneWithDefault("app.scenes.mainscene.PlayingScene")
    end

    return true
end

---销毁函数
function DailyPvpMainLayer:onLayerUnload( ... )
    
end

return DailyPvpMainLayer
