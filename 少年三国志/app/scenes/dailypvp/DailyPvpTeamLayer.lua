
local DailyPvpTeamLayer = class ("DailyPvpTeamLayer", UFCCSNormalLayer)
local KnightPic = require("app.scenes.common.KnightPic")
local DailyPvpKnight = require("app.scenes.dailypvp.DailyPvpKnight")
local DailyPvpConst = require("app.const.DailyPvpConst")
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.knight_info")
require("app.cfg.daily_crosspvp_rank_title")
require("app.cfg.face_info")

DailyPvpTeamLayer.NUMZORDER = 30
DailyPvpTeamLayer.BUBBLEZORDER = 40
DailyPvpTeamLayer.HEROZORDER = 20
DailyPvpTeamLayer.CLICKEDZORDER = 25
DailyPvpTeamLayer.TOPZORDER = 50

DailyPvpTeamLayer.WAITTIME1 = 30
DailyPvpTeamLayer.WAITTIME2 = 5

function DailyPvpTeamLayer.create(...)   
    return DailyPvpTeamLayer.new("ui_layout/dailypvp_TeamLayer.json", ...) 
end

function DailyPvpTeamLayer:ctor(...)
    self.super.ctor(self, ...)
    self:registerTouchEvent(false,true,0)

    self._clickedIndex = 0
    self._moreIndex = 0
    self._moreRect = CCRectMake(0,0,0,0)
    self._matchLayer = nil
    self._friendInfoOpen = false
    self._openCheck = self:getCheckBoxByName("CheckBox_open")
    self._bubbleCheck = self:getCheckBoxByName("CheckBox_bubble")
    self._heroPanel = self:getPanelByName("Panel_content")
    self._morePanel1 = self:getPanelByName("Panel_more1")
    self._morePanel2 = self:getPanelByName("Panel_more2")
    self._morePanel1:setVisible(false)
    self._morePanel2:setVisible(false)
    self._tipsTable = nil
    self._canShowBubbles = true
    self._clickSwallow = false
    self._inTouch = false

    self:initLabels()
    self:initButtons()
    self:initPanels()
    self:updateHeros()
    self:initBubbles()

    self:getPanelByName("Panel_rongyuRank"):setVisible(false)
end

function DailyPvpTeamLayer:initLabels()
    self:getLabelByName("Label_scoreTag"):createStroke(Colors.strokeBrown, 1)
    self._scoreLabel = self:getLabelByName("Label_score")
    self._scoreLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyuTag"):createStroke(Colors.strokeBrown, 1)
    self._rongyuLabel = self:getLabelByName("Label_rongyu")
    self._rongyuLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_rongyuRankTag"):createStroke(Colors.strokeBrown, 1)
    self._rongyuRankLabel = self:getLabelByName("Label_rongyuRank")
    self._rongyuRankLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_teamAddTag"):createStroke(Colors.strokeBrown, 1)
    self._teamAddLabel = self:getLabelByName("Label_teamAdd")
    self._teamAddLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_openTxt"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_bubbleTxt"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_timesLeftDesc"):createStroke(Colors.strokeBrown, 1)
    self._timesLeftLabel = self:getLabelByName("Label_timesLeft")
    self._timesLeftLabel:createStroke(Colors.strokeBrown, 1)
end

function DailyPvpTeamLayer:updateLabels()
    local rank = G_Me.dailyPvpData:getRank()
    local rankStr = rank > 0 and G_lang:get("LANG_DAILY_MINGCI",{rank=rank}) or  "("..G_lang:get("LANG_WHEEL_NORANK")..")"
    
    self._scoreLabel:setText(G_Me.userData.dailyPVPScore)
    self._rongyuLabel:setText(G_Me.dailyPvpData:getHonor()..rankStr)
    -- self._rongyuRankLabel:setText(rank > 0 and rank or G_lang:get("LANG_WHEEL_NORANK"))
    self._teamAddLabel:setText(G_Me.dailyPvpData:getTotalBuff().."%")
    self._timesLeftLabel:setText(G_Me.dailyPvpData:getAwardCountLeft())

    self:getImageViewByName("Image_inviteTips"):setVisible(G_Me.dailyPvpData:needTips())
end

function DailyPvpTeamLayer:initPanels()
    self._members = {}
    for i = 1 , 5 do
        self._members[i] = {}
        self._members[i].scale = i > 2 and 0.9 or 1
        local diImg = self:getImageViewByName("Image_di"..i)
        local posx,posy = diImg:getPosition()
        local up = i > 2 and 1 or -1
        posy = posy + up * (display.height-853)/4
        diImg:setPositionXY(posx,posy)
        self._members[i].pos = {x=posx,y=posy}
        self._members[i].diImg = diImg
        local numImg = ImageView:create()
        numImg:loadTexture("ui/text/txt/jzhlg_"..i..".png")
        self._heroPanel:addChild(numImg,DailyPvpTeamLayer.NUMZORDER)
        numImg:setPositionXY(posx,posy-20*self._members[i].scale)
        numImg:setScale(self._members[i].scale)
        self._members[i].numImg = numImg
        local addImg = ImageView:create()
        addImg:loadTexture("ui/mainpage/jiahao.png")
        addImg:setPositionXY(posx,posy)
        addImg:setScale(self._members[i].scale*0.8)
        self._heroPanel:addChild(addImg,DailyPvpTeamLayer.HEROZORDER)
        self._members[i].addImg = addImg
    end
end

function DailyPvpTeamLayer:updateHeros()
    local teamMembers = G_Me.dailyPvpData:getTeamMembers()
    for i = 1 , 5 do 
        self._members[i].addImg:setVisible(true)
        self._members[i].hasHero = false
        self._members[i].heroData = nil
        if self._members[i].hero then
            self._members[i].hero.node:setVisible(false)
        end
    end
    for k , v in pairs(teamMembers) do 
        local resId = G_Me.dressData:getDressedResidWithClidAndCltm(v.main_role,v.dress_id,
            v.clid,v.cltm,v.clop)
        local knightInfo = knight_info.get(v.main_role)
        local titleId = v.sp6
        local pos = v.sp3+1
        local name = v.name.."[" .. string.gsub(v.sname, "^.-%((.-)%)", "%1") .. "]"
        self._members[pos].addImg:setVisible(false)
        self._members[pos].hasHero = true
        self._members[pos].heroData = v
        if self._members[pos].hero then
            self._members[pos].hero.node:setVisible(true)
            self._members[pos].hero:updateReadyKnight(resId,titleId,name,Colors.qualityColors[knightInfo.quality],v.fight_value,v.vip,v.isLeader,v.sp5>0)
        else
            local hero = DailyPvpKnight.createKnight(resId,true,titleId,name,Colors.qualityColors[knightInfo.quality],v.fight_value,v.vip,false,false)
            hero:initReady(v.isLeader,v.sp5>0)
            self._members[pos].hero = hero
            self._heroPanel:addChild(hero.node,DailyPvpTeamLayer.HEROZORDER-pos)
            local position = self._members[pos].pos
            hero.node:setPositionXY(position.x,position.y)
            hero.node:setScale(self._members[pos].scale)
        end
    end
end

function DailyPvpTeamLayer:leave()
    MessageBoxEx.showYesNoMessage(nil, 
                G_lang:get("LANG_DAILY_TEAM_LEAVE"), false, 
                function ( ... )
                    -- uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpMainScene").new())
                    G_HandlersManager.dailyPvpHandler:sendTeamPVPLeave()
                end)
end

function DailyPvpTeamLayer:initButtons()
    self:registerBtnClickEvent("Button_back", function()
        -- self:onBackKeyEvent()
        self:leave()
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
        require("app.const.ShopType")
        uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.DAILY_PVP))
    end)
    self:registerBtnClickEvent("Button_rank", function()
        local layer = require("app.scenes.dailypvp.DailyPvpTopLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    self:registerBtnClickEvent("Button_addHelp", function()
        local layer = require("app.scenes.dailypvp.DailyPvpAwardAddLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end)
    self:registerBtnClickEvent("Button_add", function()
        self:buyTimes()
    end)
    self:registerBtnClickEvent("Button_buzhen", function()
        require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer(function ( )
            G_HandlersManager.dailyPvpHandler:sendTeamPVPBattleTeamChange()
        end)
    end)
    self:registerBtnClickEvent("Button_startFight", function()
        local goStart = function ( )
            G_HandlersManager.dailyPvpHandler:sendTeamPVPMatchOtherTeam()
        end
        if G_Me.dailyPvpData:isFull() then
            if G_Me.dailyPvpData:allReady() then
                if G_Me.dailyPvpData:getAwardCountLeft()==0 and G_Me.dailyPvpData:getShowTips() then
                    local layer = require("app.scenes.dailypvp.DailyPvpTipsLayer").create()
                    layer:setCancelImg("ui/text/txt-middle-btn/jixukaiqi.png")
                    layer:setCancelCallBack(goStart)
                    uf_notifyLayer:getModelNode():addChild(layer)
                else
                    goStart()
                end
            else
                G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_NOT_READY"))
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_NOT_FULL"))
        end
    end)
    self:registerBtnClickEvent("Button_ready", function()
        local goStart = function ( )
            G_HandlersManager.dailyPvpHandler:sendTeamPVPAgreeBattle(true)
        end
        if G_Me.dailyPvpData:getAwardCountLeft()==0 and G_Me.dailyPvpData:getShowTips() then
            local layer = require("app.scenes.dailypvp.DailyPvpTipsLayer").create()
            layer:setCancelImg("ui/text/txt-middle-btn/jixuzhunbei.png")
            layer:setCancelCallBack(goStart)
            uf_notifyLayer:getModelNode():addChild(layer)
        else
            goStart()
        end
    end)
    self:registerBtnClickEvent("Button_noReady", function()
        G_HandlersManager.dailyPvpHandler:sendTeamPVPAgreeBattle(false)
    end)
    self:registerBtnClickEvent("Button_leave", function()
        self:leave()
    end)
    self:registerBtnClickEvent("Button_autoAdd", function()
        local time = G_Me.dailyPvpData:getNpcCd()
        if time > 0 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_NEXT_INVITE",{time=time}))
        else
            G_HandlersManager.dailyPvpHandler:sendTeamPVPInviteNPC()
        end
    end)
    self:registerWidgetClickEvent("Label_openTxt", function()
        self:openCheck()
    end)
    self:registerCheckboxEvent("CheckBox_open", function( widget, type, isCheck )
        self:openCheck()
    end)
    self:registerWidgetClickEvent("Label_bubbleTxt", function()
        self:bubbleCheck()
    end)
    self:registerCheckboxEvent("CheckBox_bubble", function( widget, type, isCheck )
        self:bubbleCheck()
    end)
    self:registerBtnClickEvent("Button_see1", function()
        self:seeHero()
    end)
    self:registerBtnClickEvent("Button_see2", function()
        self:seeHero()
    end)
    self:registerBtnClickEvent("Button_kick1", function()
        self:kickHero()
    end)
    self:registerBtnClickEvent("Button_kick2", function()
        self:kickHero()
    end)

    local EffectNode = require "app.common.effects.EffectNode"
    local node = EffectNode.new("effect_around2")     
    node:setScale(1.4) 
    node:play()
    self:getButtonByName("Button_ready"):addNode(node)
    self._readyEffect = node
end

function DailyPvpTeamLayer:openCheck()
    local check = G_Me.dailyPvpData:getOnlyInvited()
    G_HandlersManager.dailyPvpHandler:sendTeamPVPSetTeamOnlyInvited(not check)
end

function DailyPvpTeamLayer:bubbleCheck()
    local check = G_Me.dailyPvpData:getPopChat()
    G_HandlersManager.dailyPvpHandler:sendTeamPVPPopChat(not check)
end

function DailyPvpTeamLayer:buyTimes()
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

function DailyPvpTeamLayer:updateOpenCheck()
    local check = G_Me.dailyPvpData:getOnlyInvited()
    self._openCheck:setSelectedState(not check)
    local check2 = G_Me.dailyPvpData:getPopChat()
    self._bubbleCheck:setSelectedState(not check2)
    if not check2 then
        self:hideBubbles()
    else
        self:showBubbles()
    end

    local selfData = G_Me.dailyPvpData:getSelfData()
    self:getButtonByName("Button_startFight"):setVisible(selfData.isLeader)
    self:getButtonByName("Button_ready"):setVisible((not selfData.isLeader) and selfData.sp5 == 0)
    self:getButtonByName("Button_noReady"):setVisible((not selfData.isLeader) and selfData.sp5 > 0)
end

function DailyPvpTeamLayer:adapterLayer()
    
end

function DailyPvpTeamLayer:onLayerEnter()
    self:registerKeypadEvent(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPSETTEAMONLYINVITED, self._changeTeamOnlyInvited, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPSTATUS, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBATTLERESULT, self._onBattleResult, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITECANCELED, self.updateView, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPINVITEDJOINTEAM, self.updateView, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBEINVITED, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPBUYAWARDCNT, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPNOTINTEAM, self._refreshTeamState, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPTEAMCOMEFULL, self._teamComeFull, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPTEAMCOMENOTFULL, self._teamComeNotFull, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPGETUSERINFO, self.updateView, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPTEAMCHATMSG, self.onReceiveChatMessage, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPTEAMPOPCHAT, self.updateView, self)
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPAGREEBATTLE, self.agreeBattle, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPTEAMINMATCH, self._teamInMatch, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TEAMPVPTEAMOUTMATCH, self._teamOutMatch, self)
    self:updateView()

    G_HandlersManager.dailyPvpHandler:sendTeamPVPGetUserInfo()
    if self._schedule == nil then
        self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
    end

    if G_Me.dailyPvpData:isFull() and G_Me.dailyPvpData:allReady() then
        self:_teamComeFull()
    end
end

function DailyPvpTeamLayer:_refreshTimeLeft()
    if G_Me.dailyPvpData:isNeedRequestNewData() then
        G_HandlersManager.dailyPvpHandler:sendTeamPVPGetUserInfo()
    end
end

function DailyPvpTeamLayer:_teamComeFull( )
    -- if G_Me.dailyPvpData:isLeader() then
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_CAN_TRAG"))
    -- end
    self:showTips()
end

function DailyPvpTeamLayer:_teamComeNotFull( )
    self:hideTips()
end

function DailyPvpTeamLayer:_teamInMatch( )
    self:hideTips()
end

function DailyPvpTeamLayer:_teamOutMatch( )
    if G_Me.dailyPvpData:isFull() and G_Me.dailyPvpData:allReady() then
        self:showTips()
    end
end

function DailyPvpTeamLayer:_changeTeamOnlyInvited(data )
    self:updateView()
    local str = G_Me.dailyPvpData:getOnlyInvited() and G_lang:get("LANG_DAILY_CLOSE_TEAM") or G_lang:get("LANG_DAILY_OPEN_TEAM")
    G_MovingTip:showMovingTip(str)
end

function DailyPvpTeamLayer:_refreshTeamState( )
    G_HandlersManager.dailyPvpHandler:sendTeamPVPStatus()
end

function DailyPvpTeamLayer:updateView(data)
    local status = G_Me.dailyPvpData:getStatus()
    if status == DailyPvpConst.NOTEAM or status == DailyPvpConst.MATCHING_TEAM then
        if data and rawget(data,"kicked") then
            G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_TEAM_KICKED"))
        end
        uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpMainScene").new())
    else
        self:updateLabels()
        self:updateOpenCheck()
        self:updateHeros()
        self:updateBubbles()

        local show = G_Me.dailyPvpData:isLeader() 
        self._isLeader = show
        self:getButtonByName("Button_autoAdd"):setVisible(show)
        self:getLabelByName("Label_openTxt"):setVisible(show)
        if status == DailyPvpConst.MATCHING_FIGHT then
            if not self._matchLayer then
                self._matchLayer = require("app.scenes.dailypvp.DailyPvpMatchLayer").show()
            end
        else
            if self._matchLayer then
                self._matchLayer:close()
                self._matchLayer = nil
            end
        end
    end
end

function DailyPvpTeamLayer:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
        self._schedule = nil
    end
end

function DailyPvpTeamLayer:onBackKeyEvent( ... )
    -- local packScene = G_GlobalFunc.createPackScene(self)
    -- if packScene then 
    --    uf_sceneManager:replaceScene(packScene)
    -- else
    --    GlobalFunc.popSceneWithDefault("app.scenes.mainscene.PlayingScene")
    -- end
    self:leave()
    return true
end

---销毁函数
function DailyPvpTeamLayer:onLayerUnload( ... )
    uf_eventManager:removeListenerWithTarget(self)
end


function DailyPvpTeamLayer:onTouchBegin(x,y)
    -- print("onTouchBegin :  x= "..x..",y="..y)
    -- self:_removeTimer()
    self._friendInfoOpen = false
    self.m_nTouchBegin = self._heroPanel:convertToNodeSpace(ccp(x,y)) 
    if G_WP8.CCRectContainPt(self._moreRect, self.m_nTouchBegin) then
        self._clickSwallow = true
        return true
    end
    if self._inTouch then
        return true
    end
    self._inTouch = true

    self._clickedIndex = 0

    for i = 1 , 5 do
        local rect = DailyPvpKnight.getRect(self._members[i].pos)
        if G_WP8.CCRectContainPt(rect, self.m_nTouchBegin) then
            self._clickedIndex = i
        end
    end
    
    return true
end



function DailyPvpTeamLayer:onTouchMove(x,y)
    -- print("onTouchMove :  x= "..x..",y="..y)
    if self._clickSwallow then
        return
    end
    if not self._inTouch then
        return
    end
    if self._clickedIndex == 0 then
        return
    end  
    if not self._isLeader then
        return 
    end
    self:hideBubbles()
    local ptx,pty = self._heroPanel:convertToNodeSpaceXY(x,y) 
    local member = self._members[self._clickedIndex]
    if member.hasHero then
        member.hero.node:setPositionXY(member.pos.x+ptx-self.m_nTouchBegin.x,member.pos.y+pty-self.m_nTouchBegin.y)
        member.hero.node:setZOrder(DailyPvpTeamLayer.CLICKEDZORDER)
    end
end

function DailyPvpTeamLayer:onTouchCancel(x,y)
    self:onTouchEnd(x, y)
end


function DailyPvpTeamLayer:onTouchEnd(x,y)
        self:hideMoreLayer()
        if self._clickSwallow then
            self._clickSwallow = false
            return
        end
        if not self._inTouch then
            return
        end
        self._inTouch = false
        if self._clickedIndex == 0 then
            return
        end  
        local pt = self._heroPanel:convertToNodeSpace(ccp(x,y)) 

        if math.abs(pt.x - self.m_nTouchBegin.x) < 5 and math.abs(pt.y - self.m_nTouchBegin.y) then
            self:clickHero(self._clickedIndex)
        end

        if not self._isLeader then
            return 
        end
        self:showBubbles()
        local member = self._members[self._clickedIndex]
        if member.hasHero then
            member.hero.node:setPositionXY(member.pos.x,member.pos.y)
            member.hero.node:setZOrder(DailyPvpTeamLayer.HEROZORDER-self._clickedIndex)
            local dstIndex = 0
            for i = 1 , 5 do
                local rect = DailyPvpKnight.getRect(self._members[i].pos)
                if G_WP8.CCRectContainPt(rect, pt) then
                    dstIndex = i
                end
            end

            if dstIndex == 0 or dstIndex == self._clickedIndex then
            else
                G_HandlersManager.dailyPvpHandler:sendTeamPVPChangePosition(self._clickedIndex-1,dstIndex-1)
            end
        end
end

function DailyPvpTeamLayer:clickHero(index)
    if self._members[index].hasHero then
        if tostring(self._members[index].heroData.sid) == tostring(G_PlatformProxy:getLoginServer().id) and self._members[index].heroData.id == G_Me.userData.id then
            G_MovingTip:showMovingTip(G_lang:get("LANG_DAILY_CLICK_SELF"))
        else
            if self._isLeader then
                self:showMoreLayer(index)
            else
                self._moreIndex = index
                self:seeHero()
            end
        end
    else
        local layer = require("app.scenes.dailypvp.DailyPvpInviteLayer").create()
        uf_sceneManager:getCurScene():addChild(layer)
    end
end

function DailyPvpTeamLayer:showMoreLayer(index)
    self._moreIndex = index
    local pos = self._members[index].pos
    local scale = self._members[index].scale
    if index == 5 or index == 2 then
        self._morePanel1:setVisible(false)
        self._morePanel2:setVisible(true)
        self._morePanel2:setPositionXY(pos.x-35*scale,pos.y+85*scale)
        self._moreRect = CCRectMake(pos.x-35*scale-180,pos.y+85*scale-91,180,143)
    else
        self._morePanel1:setVisible(true)
        self._morePanel2:setVisible(false)
        self._morePanel1:setPositionXY(pos.x+35*scale,pos.y+85*scale)
        self._moreRect = CCRectMake(pos.x+35*scale+0,pos.y+85*scale-91,180,143)
    end
end

function DailyPvpTeamLayer:hideMoreLayer(index)
    self._moreIndex = 0
    self._morePanel1:setVisible(false)
    self._morePanel2:setVisible(false)
    self._moreRect = CCRectMake(0,0,0,0)
end

function DailyPvpTeamLayer:seeHero()
    local info = self._members[self._moreIndex].heroData
    self._seeHeroData = info
    self:hideMoreLayer()
    if tostring(info.sid) == tostring(G_PlatformProxy:getLoginServer().id) and info.sp2 == 0 then
        self._friendInfoOpen = true
        local input = require("app.scenes.friend.FriendInfoLayer").createByName(info.id,nil,function ( index )
        end)   
        uf_sceneManager:getCurScene():addChild(input)
    elseif tostring(info.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
        G_HandlersManager.arenaHandler:sendCheckUserInfo(self:getTrueId(info.id))
    else
        G_HandlersManager.crossWarHandler:sendGetPlayerTeam(info.sid, self:getTrueId(info.id))
    end

end

function DailyPvpTeamLayer:getTrueId(id)
    return id%2^24
end

function DailyPvpTeamLayer:_onRcvPlayerTeam(data)
    if self._seeHeroData and data.user_id == self:getTrueId(self._seeHeroData.id) and data.sid == self._seeHeroData.sid then
        local user = rawget(data, "user")
        if user ~= nil then
            user.name = self._seeHeroData.name
            local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
            uf_sceneManager:getCurScene():addChild(layer)
        end
    end
end

function DailyPvpTeamLayer:_onGetUserInfo(data)
    if self._seeHeroData and data.user.id == self:getTrueId(self._seeHeroData.id) and not self._friendInfoOpen then
        data.user.name = self._seeHeroData.name
        local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
        uf_notifyLayer:getModelNode():addChild(layer)
    end
end

function DailyPvpTeamLayer:kickHero()
    if self._moreIndex > 0 then
        local heroData = self._members[self._moreIndex].heroData
        self:hideMoreLayer()
        MessageBoxEx.showYesNoMessage(nil, 
                    G_lang:get("LANG_DAILY_TEAM_KICK",{name=heroData.name}), false, 
                    function ( ... )
                        G_HandlersManager.dailyPvpHandler:sendTeamPVPKickTeamMember(heroData)
                    end)
                    
    end
end

function DailyPvpTeamLayer:agreeBattle(data)
    local selfData = G_Me.dailyPvpData:getSelfData()
    if data.agree and G_Me.dailyPvpData:getAwardCountLeft()==0 and G_Me.dailyPvpData:getShowTips() then
        local layer = require("app.scenes.dailypvp.DailyPvpTipsLayer").create()
        uf_notifyLayer:getModelNode():addChild(layer)
    end
end

function DailyPvpTeamLayer:_onBattleResult(data)
    uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpBattleScene").new(data.report,{isReplay=false,score=data.score,honor=data.honor,double=data.double_award}))
end

function DailyPvpTeamLayer:onReceiveChatMessage(data)

    local findPos = function ( msgData )
        for i = 1 , 5 do 
            local hData = self._members[i].heroData
            if self._members[i].hasHero and hData then
                if msgData.sender_sid == hData.sid and msgData.senderId == hData.id then
                    return i
                end
            end
        end
        return 0
    end

    if data.channel == 4 then
        self:showBubble(findPos(data),data.content)
    end
end

function DailyPvpTeamLayer:initBubbles()
    self._bubbles = {}
    for i = 1 , 5 do 
        self._bubbles[i] = self:initBubble(i)
    end
end

function DailyPvpTeamLayer:initBubble(index)
    local dir = (index == 2 or index == 5 ) and -1 or 1
    local bubble = {}
    local node = CCNode:create()
    local pos = self._members[index].pos
    local scale = self._members[index].scale
    bubble.scale = scale
    bubble.hasHero = self._members[index].hasHero
    bubble.id = bubble.hasHero and self._members[index].heroData.id or 0
    bubble.sid = bubble.hasHero and self._members[index].heroData.sid or 0
    node:setPositionXY(pos.x+dir*0*scale,pos.y+120*scale)
    node:setScale(scale)
    self._heroPanel:addNode(node,DailyPvpTeamLayer.BUBBLEZORDER)
    bubble.node = node
    local bgImg = ImageView:create()
    bgImg:loadTexture("ui/dungeon/qipao.png")
    -- bgImg:setScale9Enabled(true) 
    -- bgImg:setCapInsets(CCRectMake(135, 65, 1, 1))
    -- bgImg:setSize(CCSizeMake(270,130))
    bgImg:setScale(0.8)
    bgImg:setAnchorPoint(ccp(0,0.5))
    bgImg:setScaleX(dir*0.8)
    node:addChild(bgImg,1)
    bgImg:setPositionXY(0,0)
    bubble.bgImg = bgImg
    local txtLabel = GlobalFunc.createGameLabel("", 20, Colors.lightColors.DESCRIPTION, nil,CCSizeMake(150,80))
    txtLabel:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter)
    node:addChild(txtLabel,2)
    txtLabel:setPositionXY(dir*115+5,-5)
    bubble.txtLabel = txtLabel
    node:setVisible(false)
    return bubble
end

function DailyPvpTeamLayer:checkMsg(msg,label)
    local newMsg = string.gsub(msg, "%[(%d+)%.png]", function ( id )
        local info = face_info.get(tonumber(id))
        if info then
            return "["..info.explain.."]"
        else
            return "["..id..".png]"
        end
    end )
    -- G_lang:get("LANG_DAILY_TEAM_FACE"))
    if string.len(newMsg) > 20*3 then
        newMsg = string.sub(newMsg,1,20*3).."..."
    end
    if string.len(newMsg) > 7*3 then
        label:setTextHorizontalAlignment(kCCTextAlignmentLeft)
    else
        label:setTextHorizontalAlignment(kCCTextAlignmentCenter)
    end
    return newMsg
end

function DailyPvpTeamLayer:showBubble(index,msg)
    if not G_Me.dailyPvpData:getPopChat() then
        return
    end
    if not self._canShowBubbles then
        return
    end
    local label = self._bubbles[index].txtLabel
    local newMsg = self:checkMsg(msg,label)
    label:setText(newMsg)
    local bubble = self._bubbles[index].node
    bubble:stopAllActions()
    bubble:setScale(0.1)
    bubble:setVisible(true)

    if index == 1 or index == 4 then
        bubble:setZOrder(DailyPvpTeamLayer.BUBBLEZORDER+1)
        self._bubbles[index+1].node:setZOrder(DailyPvpTeamLayer.BUBBLEZORDER)
    elseif index == 2 or index == 5 then
        bubble:setZOrder(DailyPvpTeamLayer.BUBBLEZORDER+1)
        self._bubbles[index-1].node:setZOrder(DailyPvpTeamLayer.BUBBLEZORDER)
    end

    local seqArr = CCArray:create()
    seqArr:addObject(CCEaseBackOut:create(CCScaleTo:create(0.2,self._bubbles[index].scale)))
    seqArr:addObject(CCDelayTime:create(3))
    seqArr:addObject(CCScaleTo:create(0.2,0.1))
    seqArr:addObject(CCCallFunc:create(function()
        bubble:setVisible(false)
    end))
    bubble:runAction(CCSequence:create(seqArr))
end

function DailyPvpTeamLayer:updateBubbles()
    local stopBubble = function ( index )
        self._bubbles[index].node:stopAllActions()
        self._bubbles[index].node:setVisible(false)
        self._bubbles[index].hasHero = self._members[index].hasHero
        self._bubbles[index].id = self._members[index].hasHero and self._members[index].heroData.id or 0
        self._bubbles[index].sid = self._members[index].hasHero and self._members[index].heroData.sid or 0
    end
    for index = 1 , 5 do 
        if self._members[index].hasHero == false then
            stopBubble(index)
        else
            if self._members[index].heroData.id ~= self._bubbles[index].id or self._members[index].heroData.sid ~= self._bubbles[index].sid then 
                stopBubble(index)
            end
        end
    end
end

function DailyPvpTeamLayer:hideBubbles()
    self._canShowBubbles = false
    for i = 1 , 5 do 
        self._bubbles[i].node:stopAllActions()
        self._bubbles[i].node:setVisible(false)
    end
end

function DailyPvpTeamLayer:showBubbles()
    self._canShowBubbles = true
end

function DailyPvpTeamLayer:initTips()
    local leader = G_Me.dailyPvpData:isLeader()
    local tipTable = {}
    local node = CCNode:create()
    self:getPanelByName("Panel_bottom"):addNode(node,10 )
    node:setPositionXY(320,170)
    local bgImg = ImageView:create()
    bgImg:loadTexture("title_xiaobiao.png",UI_TEX_TYPE_PLIST)
    bgImg:setScale9Enabled(true)
    bgImg:setCapInsets(CCRectMake(257, 20, 1, 1))
    bgImg:setSize(CCSizeMake(514,leader and 78 or 39))
    node:addChild(bgImg,1)
    bgImg:setPositionXY(0,0)
    tipTable.bgImg = bgImg
    tipTable.node = node

    local tipsY = leader and 15 or 0
    local tipLabel1 = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_TEAM_TIPS1"), 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
    node:addChild(tipLabel1,2)
    tipLabel1:setPositionXY(-92,tipsY)
    local tipLabel2 = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_TEAM_TIPS2"), 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
    node:addChild(tipLabel2,2)
    tipLabel2:setPositionXY(78,tipsY)
    local timeLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_TEAM_TIME",{time=DailyPvpTeamLayer.WAITTIME1}), 24, Colors.darkColors.TITLE_01, Colors.strokeBrown)
    node:addChild(timeLabel,2)
    timeLabel:setPositionXY(-13,tipsY)
    tipTable.tipLabel1 = tipLabel1
    tipTable.tipLabel2 = tipLabel2
    tipTable.timeLabel = timeLabel

    if leader then
        local tipLabel3 = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_CAN_TRAG"), 22, Colors.darkColors.TIPS_02, Colors.strokeBrown)
        node:addChild(tipLabel3,2)
        tipLabel3:setPositionXY(0,-19)
        tipTable.tipLabel3 = tipLabel3
    end

    self._tipsTable = tipTable
end

function DailyPvpTeamLayer:showTips()
    if not self._tipsTable then
        self:initTips()
    end
    local readyTime = G_Me.dailyPvpData:getReadyTime()
    if readyTime == 0 then
        return
    end
    local leftTime = readyTime + DailyPvpTeamLayer.WAITTIME1 - G_ServerTime:getTime()
    if leftTime < 0 then
        return
    end
    self._tipsTable.node:setVisible(true)
    local label = self._tipsTable.timeLabel
    label:stopAllActions()
    label:setScale(1)
    local seqArr = CCArray:create()
    for i = leftTime , 0 , -1 do 
        if i <= DailyPvpTeamLayer.WAITTIME2 then
            seqArr:addObject(CCCallFunc:create(function()
                label:setText(G_lang:get("LANG_DAILY_TEAM_TIME",{time=i}))
            end))
            seqArr:addObject(CCCallFunc:create(function()
                label:setScale(3.0)
            end))
            seqArr:addObject(CCScaleTo:create(0.2,1))
            seqArr:addObject(CCDelayTime:create(0.8))
        else
            seqArr:addObject(CCCallFunc:create(function()
                label:setText(G_lang:get("LANG_DAILY_TEAM_TIME",{time=i}))
            end))
            seqArr:addObject(CCDelayTime:create(1))
        end
    end
    seqArr:addObject(CCCallFunc:create(function()
        self:hideTips()
        -- if G_Me.dailyPvpData:isLeader() then
        --     G_HandlersManager.dailyPvpHandler:sendTeamPVPLeave()
        -- end
    end))
    label:runAction(CCSequence:create(seqArr))
end

function DailyPvpTeamLayer:hideTips()
    if not self._tipsTable then
        return
    end
    local label = self._tipsTable.timeLabel
    label:setScale(1)
    label:stopAllActions()
    self._tipsTable.node:setVisible(false)
end

return DailyPvpTeamLayer
