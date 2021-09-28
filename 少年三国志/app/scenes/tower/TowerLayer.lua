require("app.cfg.tower_info")
require("app.cfg.tower_reset_info")
require("app.cfg.passive_skill_info")
Path = require("app.setting.Path")
Goods = require("app.setting.Goods")
local AwardConst = require("app.const.AwardConst")
local EffectNode = require "app.common.effects.EffectNode"
local TowerLayer = class("TowerLayer",UFCCSNormalLayer)

local cleanupTime = 30
local maxFloor = 60
local saodangFloor = 10
local bossFloor = 5
local maxTry= 5
local pointTotal = 12

function TowerLayer:ctor(jsonFile, fun, scenePack)
    self._reachMax = false
    self._floor = 0 --正在打的层
    self._towerInfo = nil
    self._selectedBuffId = 0
    self._cleanupCountdown = 0
    self._schedule = nil
    self.cleanupTimeSum = 0
    self._towerItems = {}
    self._pointsItems = {}
    self._ableReset = true
    self._resetFreeCount = 2
    self._resetTotalCount = 5
    self._cleanupStart = 0
    self._anime = false
    
    self.super.ctor(self, json)
    self:adapterWithScreen()
    
    G_GlobalFunc.savePack(self, scenePack)
   
    -- 蓝色箭头
    -- self.tips = CCSNormalLayer:create("ui_layout/dungeon_DungeonStageTips.json")
    -- self.tips:playAnimation("move",function() end)
    self.tips= EffectNode.new("effect_knife", 
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
    
    self:registerBtnClickEvent("Button_Back", function()
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_Shop", function()
        require("app.const.ShopType")
                uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.CHUANG_GUAN))
    end)
end

function TowerLayer:onBackKeyEvent( ... )
    local packScene = G_GlobalFunc.createPackScene(self)
    if not packScene then 
        packScene = require("app.scenes.mainscene.PlayingScene").new()
    end
    uf_sceneManager:replaceScene(packScene)

    return true
end

function TowerLayer:setDisplayEffect(displayEffect)
    self._showEffect = displayEffect
end

function TowerLayer:onLayerLoad( ... )
    __Log("-------------tower load")
    self.super:onLayerLoad()
    self._resetNumber = self:getLabelByName("Label_cz")
    self._resetNumber2 = self:getLabelByName("Label_cz2")
    self._historyNumber = self:getLabelByName("Label_TowerName")

    self._cleanupBtn = self:getButtonByName("Button_Cleanup")
    self._cleanupImg = self:getImageViewByName("ImageView_Cleanup")
    self._cleanupReportImg = self:getImageViewByName("ImageView_CleanupReport")

    self._towerPanel = self:getPanelByName("Panel_Tower")
    
    self:strokeBrown(self:getLabelByName("Label_TowerName"))

    self:getLabelByName("Label_Time"):setVisible(false)

    self._pointParts = {1,4,7,10,13}
    self._firstEnter = true
    
    self._towerPanels = {}
    for i=1,5 do
        self._towerPanels[#self._towerPanels+1] = self:getPanelByName("Panel_Monster"..i)
    end

    self:getLabelByName("Label_jifen"):setText(G_lang:get("LANG_TOWER_ZHANGONG"))
    self:strokeBrown(self:getLabelByName("Label_jifen"))
    self:_setResetCount()
    
    self:registerBtnClickEvent("Button_Reset", handler(self, self._onReset))
    self:registerBtnClickEvent("Button_Cleanup", handler(self, self._onCleanup))
    self:registerBtnClickEvent("Button_Leaderboard", handler(self, self._onLeaderboard))

    -- G_HandlersManager.towerHandler:sendQueryTowerInfo()

end

function TowerLayer:onLayerEnter( ... )
    __Log("-------------tower Enter")
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_Header")}, true, 0.2, 2, 100)
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_corner_mover")}, true, 0.2, 2, 100)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_INFO, self._onTowerInfoRsp, self)
    --uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_RESET, self._onResetRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_START_CLEANUP, self._onStartCleanupRsp, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_RESET, self._onResetRsp, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_CHALLENGE_REPORT, self._onChallengeReportRsp, self)
    
    -- uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECV_ROLE_INFO, self._updateTowerScore, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TOWER_STOP_CLEANUP, self._onStopCleanupRsp, self)
    if self._firstEnter then 
        G_HandlersManager.towerHandler:sendQueryTowerInfo()
        self._firstEnter = false
    end
    self:_scrollMove()

    self._effect = EffectNode.new("effect_mooncity_cg", 
        function(event, frameIndex)
            if event == "finish" then
         
            end
        end
    )
    self._effect:setPosition(ccp(320,570))
    self._effect:play()
    self:getPanelByName("Panel_effect"):addNode(self._effect) 
    -- self:getPanelByName("Panel_Tower"):addNode(self._effect) 
    -- self.tips:setZOrder(10)
end

function TowerLayer:onLayerUnload( ... )
    __Log("-------------tower unload")
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
    end
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
    end
    
    self.super:onLayerUnload()
end

function TowerLayer:onLayerExit()
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
    end
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
    end
    self._effect:removeFromParentAndCleanup(true)
    uf_eventManager:removeListenerWithTarget(self)
end

function TowerLayer:_setResetCount()
    local total = tower_reset_info.getLength()
    local free = 0
    for i = 1, total do 
        if tower_reset_info.get(i).cost == 0 then 
            free = free + 1
        end
    end
    total = G_Me.vipData:getData(8).value
    self._resetFreeCount = free
    self._resetTotalCount = total
end

function TowerLayer:_getCurResetCost()
    return tower_reset_info.get(self._towerInfo.reset_count + 1).cost * self:getMaxFloor()
end

function TowerLayer:updateView(win)
    -- G_HandlersManager.towerHandler:sendQueryTowerInfo()
    -- local points = {}
    -- for k=1,5 do
    --     local p = self:getPanelByName("Panel_Monster"..k)
    --     points[#points+1] = ccp(p:getPositionInCCPoint().x+p:getContentSize().width/2, 
    --             p:getPositionInCCPoint().y+p:getContentSize().height/2)        
    -- end
    -- self:_setTipPos()
    self._win = win or false
end

function TowerLayer:_updateHeroPos()
    local panel = self:getPanelByName("Panel_Tower")
    local hero1 = self:getPanelByName("Panel_Monster1")
    local hero2 = self:getPanelByName("Panel_Monster2")
    local hero3 = self:getPanelByName("Panel_Monster3")
    
    hero1:setPosition(ccp(ccp(hero1:getPosition()).x,17*panel:getContentSize().height/400))
    hero2:setPosition(ccp(ccp(hero2:getPosition()).x,99*panel:getContentSize().height/400))
    hero3:setPosition(ccp(ccp(hero3:getPosition()).x,174*panel:getContentSize().height/400))
end

function TowerLayer:_onLeaderboard()
    local p = require("app.scenes.tower.TowerLeaderboardLayer").new("ui_layout/tower_TowerLeaderboardLayer.json",require("app.setting.Colors").modelColor)
    p:initWithTowerLayer(self)
    uf_notifyLayer:getModelNode():addChild(p)
end

function TowerLayer:_onResetRsp(data)
    __Log("-------------tower reset rsp")
    if data.ret == 1 then
        uf_funcCallHelper:callNextFrame(function (  )
                uf_eventManager:removeListenerWithTarget(self)
		local s = require("app.scenes.tower.TowerScene").new()
                s:setDisplayEffect(true)
                uf_sceneManager:replaceScene(s)
	end)
    else
        -- G_MovingTip:showMovingTip(G_NetMsgError.getMsg(data.ret))
        -- MessageBoxEx.showOkMessage("error", G_lang:get("LANG_TOWER_CANNOT_RESET"))
    end
end

function TowerLayer:_onReset()
    __LogTag("tower", "-------------tower reset")
    if self._towerInfo.doing_cleanup then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_IS_CLEANING"))
        return
    end

    if self._floor <= 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_FIRST_FLOOR_RESET"))
        return
    end

    -- if self._towerInfo.reset_count >= self._resetTotalCount then 
    --     G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_RESET_NO_TIMES"))
    --     return
    -- end
    -- print(G_Me.vipData:getNextData(8))
    if self._towerInfo.reset_count >= self._resetTotalCount then 
        local vipLevel = G_Me.vipData:getNextData(8)
        if vipLevel == -1 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_RESET_NO_TIMES"))
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_RESET_NO_TIMES2",{vip=vipLevel}))
        end
        return
    end

    if self._towerInfo.reset_count < self._resetFreeCount then
            local t = self:_getCurResetCost()
            local box = require("app.scenes.tower.TowerSystemMessageBox")
            box.showSpecialMessage( G_lang:get("LANG_TOWER_RESET_TIP"), 
            function() 
                __Log("-------------tower reset request")
                G_HandlersManager.towerHandler:sendTowerReset()
                self._towerInfo.reset_count = self._towerInfo.reset_count + 1
                self:updateResetStatus()
            end,
            function() end, 
            self )
        else
            local t = self:_getCurResetCost()
            local box = require("app.scenes.tower.TowerSystemMessageBox")
            box.showMessage( box.TypeTower,
                t, self._resetTotalCount - self._towerInfo.reset_count, 
            function() 
                __Log("-------------tower reset request")
                G_HandlersManager.towerHandler:sendTowerReset()
                self._towerInfo.reset_count = self._towerInfo.reset_count + 1
                self:updateResetStatus()
            end,
            function() end, 
            self )
    end
    
end

function TowerLayer:updateResetStatus()
    if self._towerInfo.reset_count < self._resetFreeCount then
        self._resetNumber:setVisible(false)
        self._resetNumber2:setVisible(true)
        self._resetNumber2:setText(G_lang:get("LANG_TOWER_FREE_RESET", {resetNumber=(self._resetFreeCount - self._towerInfo.reset_count)}))
        self:getImageViewByName("ImageView_yuanbao"):setVisible(false)
    elseif self._towerInfo.reset_count < self._resetTotalCount then
        self._resetNumber:setVisible(true)
        self._resetNumber2:setVisible(false)
        local t = self:_getCurResetCost()
        self._resetNumber:setText(G_lang:get("LANG_TOWER_COST_RESET", {resetCost=t}))
        self:getImageViewByName("ImageView_yuanbao"):setVisible(true)
    else
        self._resetNumber:setVisible(false)
        self._resetNumber2:setVisible(true)
        self._resetNumber2:setText(G_lang:get("LANG_TOWER_ZERO_RESET"))
        self:getImageViewByName("ImageView_yuanbao"):setVisible(false)
    end

    if self._towerInfo.doing_cleanup or self._floor <= 1 or self._towerInfo.reset_count >= self._resetTotalCount  then
        self:_setResetButton(false)
    else
        self:_setResetButton(true)
    end
    
    self:strokeBrown(self._resetNumber)
    
end

function TowerLayer:_setResetButton(able)
    local resetButton = self:getButtonByName("Button_Reset")
    if able and not self._ableReset then
        resetButton:loadTextureNormal("btn-middle-blue.png",UI_TEX_TYPE_PLIST)
        self:getImageViewByName("ImageView_1147"):showAsGray(false)
    elseif not able and self._ableReset then
        resetButton:loadTextureNormal("btn-middle-unable.png",UI_TEX_TYPE_PLIST)
        self:getImageViewByName("ImageView_1147"):showAsGray(true)
    end
    self._ableReset = able
end

function TowerLayer:_onCleanup()
    __LogTag("tower", "-------------tower cleanup")
    if not self._towerInfo.doing_cleanup then
        if self._floor-1 < self:getMaxFloor() and  self._floor-1 < maxFloor then
            require("app.scenes.tower.TowerCleanMessageBox").showSpecialMessage(  nil, 
                self:_convertTime2String2(self:_cleanUpTotal(self:getMaxFloor()-self._floor+1)),
                self:getMaxFloor(),
                " ", 
                false, 
            function() 
                G_HandlersManager.towerHandler:sendTowerStartCleanup()
            end,
            function() end, 
            self )
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CANNOT_CLEANUP"))
        end
    else
        MessageBoxEx.showYesNoMessage( "提示", G_lang:get("LANG_TOWER_CLEANUP_WARNING"), false, 
            function() 
                if self._towerInfo.doing_cleanup then
                    G_HandlersManager.towerHandler:sendTowerStopCleanup() 
                end
            end,
            function() end, 
            self )

    end
    self:updateResetStatus()
end

function TowerLayer:_startCleanup()
    self:getLabelByName("Label_Time"):setVisible(true)
    self:getLabelByName("Label_Time"):setText(self:_convertTime2String(self:_cleanUpTotal(self:getMaxFloor()-self._floor+1)))
    self:updateResetStatus()
end

function TowerLayer:_stopCleanup()
    self:getLabelByName("Label_Time"):setVisible(false)
    if self._floor ~= self._cleanupStart then
        self:_goAward()
    end
end

function TowerLayer:cleanupReportClosed()
    self:updateResetStatus()
end

function TowerLayer:_onStartCleanupRsp(data)
    if data.ret == 1 then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CLEANUP_START"))
        self._cleanupImg:setVisible(false)
        self._cleanupReportImg:setVisible(true)
        self._towerInfo.cleanup_time = data.cleanup_time
        self._towerInfo.doing_cleanup = true
        self._towerInfo.cleanup_floor = self._floor
        local t = data.cleanup_time - G_ServerTime:getTime()
        t = self:_convertTime2String(t)
        
        self._cleanupStart = self._floor
        self._cleanupCountdown = self._towerInfo.cleanup_time - G_ServerTime:getTime()

        if self._cleanupCountdown > 0 then
            self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
        end
        self._towerInfo.doing_cleanup = true
        self:_startCleanup()
    else
        -- MessageBoxEx.showOkMessage("error", G_lang:get("LANG_TOWER_CANNOT_CLEANUP"))
    end
end

function TowerLayer:_loadTower(floorId)
    local item = require("app.scenes.tower.TowerItem").create(floorId, self)
    local i = math.floor((floorId - 1)%bossFloor) + 1
    self:getPanelByName("Panel_Monster"..i):addNode(item)
    self._towerItems[#self._towerItems+1] = item
end

function TowerLayer:getCurrentFloor()
    return self._floor
end

function TowerLayer:getTowerInfo()
    return self._towerInfo
end

function TowerLayer:_refreshHero()
    self._curTryLeft = self._curTryLeft - 1
    local i = math.floor((self._floor - 1)%bossFloor) + 1
    self:_scrollMove()
    self._towerItems[i]:refresh(self._curTryLeft)  
end

function TowerLayer:_onTowerInfoRsp(data)
    self._towerInfo = data

    if self._win then 
        self._floor = data.floor
        -- self._towerInfo
    else
        self._floor = data.floor + 1
    end

    -- self._floor = data.floor + 1
    self._curTryLeft = self:getMaxTry() - data.next_floor_ct

    self._refreshBuffNumber = data.free_refresh_count
    
    -- local i = math.floor((self._floor - 1)/bossFloor)
    -- local ri =  tower_info.get(self._floor)
    -- if not ri then
    --     i = i - 1
    --     self._reachMax = true
    --     self._floor = self._floor - 1
    -- end    
    
    if data.doing_cleanup then
        self._cleanupStart = data.cleanup_floor+1
        self._cleanupCountdown = self._towerInfo.cleanup_time - G_ServerTime:getTime()
        
        if self._cleanupCountdown > 0 then
            local startt = self._towerInfo.cleanup_time - (self._towerInfo.next_challenge - self._towerInfo.cleanup_floor)*cleanupTime
            self._floor = math.floor((G_ServerTime:getTime() - startt)/cleanupTime) + self._towerInfo.cleanup_floor
            __Log("clean up floor:"..self._floor)
            -- self:_adjustTime()
            self.cleanupTimeSum = (cleanupTime - self._cleanupCountdown%cleanupTime)%cleanupTime
            self._cleanupImg:setVisible(false)
            self._cleanupReportImg:setVisible(true)
            self._schedule = GlobalFunc.addTimer(1, handler(self, self._refreshTimeLeft))
            self:getLabelByName("Label_Time"):setVisible(true)
        else
            self._towerInfo.doing_cleanup = false
            -- G_HandlersManager.towerHandler:sendTowerRequestAward()
            -- G_HandlersManager.towerHandler:sendQueryTowerInfo()
            return
        end
    end
    
    if self._showEffect then
        self:_playEffect()
    else
        self:_showTower()
    end

    self:updateResetStatus()
    
    self:_setTop()
    
    self:_adjustHistory()
    self:_updateTower()

    if self._win then 
        self:_challengeSucceed()
    end
end

function TowerLayer:_adjustHistory()
    local i  = self:getMaxFloor()
        if i >= maxFloor then
            i = maxFloor
        end
    self._historyNumber:setText(G_lang:get("LANG_TOWER_HISTORY_MAX", {historyMax=i}))
    self:strokeBrown(self._historyNumber)
end

function TowerLayer:_convertTime2String(t)
    local minu = t%3600;
    return string.format("%02d:%02d:%02d", math.floor(t/3600), math.floor(minu/60), math.floor(minu%60))
end

function TowerLayer:_convertTime2String2(t)
    local str
    local min=math.floor(t/60)
    local sec=t%60
    if sec == 0 then 
        str = G_lang:get("LANG_TOWER_TIME_FORMAT2", {min=math.floor(t/60)})
    else
        str = G_lang:get("LANG_TOWER_TIME_FORMAT", {min=math.floor(t/60),sec=t%60})
    end
    return str
end

function TowerLayer:_cleanUpTotal(floor)
    return cleanupTime*floor
end

function TowerLayer:_refreshTimeLeft()

    self.cleanupTimeSum = self.cleanupTimeSum + 1
    if self.cleanupTimeSum >= cleanupTime then
        self.cleanupTimeSum = 0
        
        self:forwardNextFloor()
        -- uf_eventManager:dispatchEvent(EventMsgID.EVENT_TOWER_CLEANUP_REPORT_REFRESH, nil, false,nil)
    end
    self._cleanupCountdown = self._cleanupCountdown - 1
    if self._cleanupCountdown <= 0 then
        
        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end
        
        self._towerInfo.doing_cleanup = false
        -- G_HandlersManager.towerHandler:sendTowerRequestAward()
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CLEANUP_END"))
        
        self:stopCleanup(self:getFloor()-1)
    else
        local t = self:_convertTime2String(self._cleanupCountdown)
        self:getLabelByName("Label_Time"):setText(t)
    end
    
end

function TowerLayer:_refreshTower()
    local cur = math.floor((self._floor-1)%bossFloor)+1
    local idx = 1
    for i = 1, #self._pointsItems do
        local roadPic = self._pointsItems[i]
        if roadPic then 
            roadPic:loadTexture(G_Path.DungeonIcoType.ROAD_GRAY)
        end
    end
    self:_playEffect()
end

function TowerLayer:stopCleanup(fl)
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
    end

    self._cleanupImg:setVisible(true)
    self._cleanupReportImg:setVisible(false)
    self._towerInfo.doing_cleanup = false
    if self._floor <= 1 or self._towerInfo.reset_count >= self._resetTotalCount  then
        self:_setResetButton(false)
    else
        self:_setResetButton(true)
    end

    if fl+1 ~= self:getFloor() then
        self:_refreshTower()
    end
    self:_stopCleanup()
end

function TowerLayer:_isBoss(fid)
    return fid%bossFloor == 0
end


function TowerLayer:_updateTower()
    if self._floor <= maxFloor then
        local i = math.floor(self._floor-1)%bossFloor + 1
        for k,v in pairs(self._towerItems) do
            if k < i then
                v:pass()
                self:_clearRoad(self._pointParts[k+1])
            elseif k == i then
                v:come()
            end
        end
    else
        for k,v in pairs(self._towerItems) do
            v:pass()
        end
    end

    self:updateResetStatus()
end

function TowerLayer:_showTower()
    if self._floor == 0 then return end
    self:_scrollMove()
    self:_setTipPos()
    self:_createRoad() 
    self:_setTop()
    self:_adjustHistory()
    self.tips:setVisible(true)

    for i = 1, #self._towerItems do 
        self._towerItems[i]:removeFromParentAndCleanup(true)
    end
    self._towerItems = {}

    if self._floor <= maxFloor then
        local i = math.floor((self._floor - 1)/bossFloor)
        for j = 1, bossFloor do 
            self:_loadTower(bossFloor*i+j)
        end
    else
        local i = math.floor(self._floor /bossFloor - 1)
        for j = 1, bossFloor do 
            self:_loadTower(bossFloor*i+j)
        end
        self.tips:setVisible(false)
        self._towerItems[bossFloor]:showMax(true)
    end
    
    self:_updateTower()
    
end

function TowerLayer:_scrollMove()
    local scroll = self:getScrollViewByName("ScrollView_tower")
    scroll:scrollToPercentVertical(100,0.02,false)
end

function TowerLayer:_playEffect()
    self._anime = false
    local cnt = 0
    for k=1,bossFloor do
        local EffectNode = require "app.common.effects.EffectNode"
        local effect
        effect = EffectNode.new("effect_appear", function(event, frameIndex)
            if event == "appear" then
                cnt = cnt + 1
                if cnt == bossFloor then
                    self:_showTower()
                end
            end
            if event == "finish" then
                self._towerPanel:removeChild(effect)
                self._anime = false
            end
                end)
        effect:play()
        local pt = self._towerPanels[k]:getPositionInCCPoint()
        local sz = self._towerPanels[k]:getContentSize()
        effect:setPosition(ccp(pt.x+sz.width/2-20, pt.y+100))
        self._towerPanel:addNode(effect)
    end
end


function TowerLayer:_setTipPos()
    if self._floor == 0 then return end
    self.tips:setVisible(true)
    
    local p1,p2 = self:_getTipPos()
    self.tips:setPosition(p1)
end

function TowerLayer:_getTipPos()
    local i = (self._floor-1)%bossFloor + 1
    local _knightPic = self:getPanelByName("Panel_Monster"..i)
    local _pt = _knightPic:getPositionInCCPoint()
    local _size = _knightPic:getContentSize()
    
    local pt1 = ccp(_pt.x+_size.width/2 ,_pt.y+_size.height+135)
    local pt2 = ccp(_pt.x+20, _pt.y + _size.height+80)
    return pt1, pt2
end

function TowerLayer:_isBossFloor()
    return math.floor(self._floor%bossFloor)==0
end

function TowerLayer:_createRoad()

    if #self._pointsItems > 0 then
        for i = 1, pointTotal do 
            self._pointsItems[i]:loadTexture(G_Path.DungeonIcoType.ROAD_GRAY)
            self._pointsItems[i]:setVisible(true)
        end
        return 
    end

    for j = 1, pointTotal do 
        self._pointsItems[j] = self:getImageViewByName("Image_point_"..j)
        self._pointsItems[j]:loadTexture(G_Path.DungeonIcoType.ROAD_GRAY)
    end
    
end

local index = 1
function TowerLayer:lightRoad()
    local i = math.floor((self._floor-1)%bossFloor)

    for k,v in pairs(self._towerItems) do
        if k < i+1 then
            v:pass()
        end
    end
        if index < self._pointParts[i] then 
            index = self._pointParts[i]
        end
        local roadPic = self._pointsItems[index]
        if roadPic == nil or index == self._pointParts[i+1]  then
            self:_clearRoad(index)
            self:_setTop()
            self:_adjustHistory()
            self:_updateTower()
            self:_setTipPos()
            self._anime = false
            G_GlobalFunc.removeTimer(self._timer)
            return
        end
        roadPic:loadTexture(G_Path.DungeonIcoType.ROAD_GREEN)
        index = index+1
end

function TowerLayer:_clearRoad(endPoint)
    for i = 1, endPoint - 1 do 
        self._pointsItems[i]:setVisible(false)
    end
end

-- 显示动画
function TowerLayer:_showRoadAnimation()
    index = 1
    self._timer = G_GlobalFunc.addTimer(0.2,handler(self,self.lightRoad))
    self.tips:setVisible(false)
end

function TowerLayer:forwardNextFloor()
    self._floor = self._floor + 1
    self._anime = true
    if self._floor > maxFloor then 
        if self._floor > self._towerInfo.next_challenge then
            self._towerInfo.next_challenge = self._floor
        end
        for k,v in pairs(self._towerItems) do
                v:pass()
        end
        self:_setTop()
        self:_adjustHistory()
        self.tips:setVisible(false)
        self._towerItems[bossFloor]:showMax(true)
        return 
    end
    if self._floor > self._towerInfo.next_challenge then
        self._towerInfo.next_challenge = self._floor
    end
    __Log("current floor:"..self._floor)
    if self._floor%bossFloor == 1 then
            for k,v in pairs(self._towerItems) do
                    v:pass()
            end
            self:_refreshTower()
        -- end
    else
        local i = math.floor((self._floor - 1)/bossFloor)
        local ri =  tower_info.get(self._floor)
        if not ri then
            i = i - 1
        end
        
        self:_showRoadAnimation()
    end
    
end

function TowerLayer:getCleanupStartFloor()
    if self._towerInfo.cleanup_floor ~= 0 then
        return self._towerInfo.cleanup_floor
    else
        return 1
    end
end

function TowerLayer:getMaxFloor()
    if self._floor > self._towerInfo.next_challenge then
        return self._floor-1
    else
        return self._towerInfo.next_challenge-1
    end
end

function TowerLayer:getFloor()
    return self._floor
end

function TowerLayer:getSelectedBuffId()
    return self._selectedBuffId
end
function TowerLayer:setSelectedBuffId(buffId)
    self._selectedBuffId = buffId
    if passive_skill_info.get(buffId) then
    local imgPath = Path.getBuffIcon(passive_skill_info.get(buffId).icon)
    self._selectedBuffImg:loadTexture(imgPath)
    self._selectedBuffImg:setScale(80/213)
    end
end
function TowerLayer:getRefreshNumber()
    return self._refreshBuffNumber
end
function TowerLayer:setRefreshNumber(num)
    self._refreshBuffNumber = num
end
function TowerLayer:getTowerInfo()
    return self._towerInfo
end
function TowerLayer:getMaxTry()
    return maxTry
end

function TowerLayer:getCurTryLeft()
    return self._curTryLeft
end

function TowerLayer:_onClickQipao(fid)
    local p = nil
    if fid%bossFloor == 0 then
        p = require("app.scenes.tower.AwardPreviewLayer").new("ui_layout/tower_AwardBossLayer.json",require("app.setting.Colors").modelColor)
        p:initWithFloor(fid)
    else
        p = require("app.scenes.tower.AwardPreviewLayer").new("ui_layout/tower_AwardLayer.json",require("app.setting.Colors").modelColor)
        p:initWithFloor(fid)
    end
    
    -- uf_notifyLayer:getModelNode():addChild(p)
    uf_sceneManager:getCurScene():addChild(p)
end

function TowerLayer:_onClickMonsterHead(fid)
    __Log("----------click tower-----------------------")
    G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    if self._towerInfo.doing_cleanup then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_IS_CLEANING2"))
        return
    end

     if fid < self._floor then
         G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CLEANUP_TIP2"))
         return
     elseif fid > self._floor or self._anime then
         -- G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CLEANUP_TIP1"))
         self:_onClickQipao(fid)
         return
     end

     -- if self._towerInfo.next_floor_ct == self:getMaxTry() then
     --     G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_CISHUYONGWAN"))
     --     return
     -- end
     if self._reachMax then
        G_MovingTip:showMovingTip(G_lang:get("LANG_TOWER_MAX_FLOOR"))
        return
    end

    local full = require("app.scenes.common.CheckFunc").checkEquipmentFull()
    if full then 
        return
    end

    local p = nil
    if fid%bossFloor == 0 then
        p = require("app.scenes.tower.TowerFightPreview").new("ui_layout/tower_TowerFightPreview.json",require("app.setting.Colors").modelColor)
        p:initWithFloor(self, self._floor, true)
        uf_sceneManager:getCurScene():addChild(p)
    else
        p = require("app.scenes.tower.TowerFightPreview").new("ui_layout/tower_TowerFightPreview2.json",require("app.setting.Colors").modelColor)
        p:initWithFloor(self, self._floor, false)
        uf_sceneManager:getCurScene():addChild(p)
        -- G_HandlersManager.towerHandler:sendTowerChallenge(0)
    end  
end



function TowerLayer:_onChallengeReportRsp(data)
    print("ldx----------battle report _onChallengeReportRsp-----------------------" .. tostring(self))

   if data.ret == 1 then 
        -- local desc = ""
        -- if data.battle_report.is_win then
        --     desc = G_lang:get("LANG_TOWER_WIN", {tiaojian=tower_info.get(self:getFloor()).success_directions})
        -- else
        --     desc = G_lang:get("LANG_TOWER_LOSE", {tiaojian=tower_info.get(self:getFloor()).success_directions})
        -- end
        local score = self:_calcResult()
        local _money = tower_info.get(self:getFloor()).coins
        local _winDesc = tower_info.get(self:getFloor()).sucesss_talk
        local _loseDesc = tower_info.get(self:getFloor()).fail_talk
        local callback = function()
            local FightEnd = require("app.scenes.common.fightend.FightEnd")
            FightEnd.show(FightEnd.TYPE_TOWER, data.battle_report.is_win,
                {
                   tower_score=score, 
                   awards=data.award,
                   money=_money,
                   win_desc=_winDesc,
                   lose_desc=_loseDesc,
                 },        
                function() 
                    -- G_Loading:showLoading(function ( ... )
                    --     uf_sceneManager:popScene()
                    --     if data.battle_report.is_win then
                    --         self:_challengeSucceed()
                    --     end
                    -- end, 
                    -- function ( ... )
                    --    --应该可以什么都不做
                       
                    -- end)
                    -- uf_sceneManager:popScene()
                    uf_sceneManager:replaceScene(require("app.scenes.tower.TowerScene").new(data.battle_report.is_win))
                    -- if data.battle_report.is_win then
                    --     self:_challengeSucceed()
                    -- else
                    --     self:_refreshHero()
                    -- end
                end 
             )
        end
        local battle 
        G_Loading:showLoading(function ( ... )
            --创建战斗场景
            battle = require("app.scenes.tower.TowerBattleScene").new(
                {data = data,func = callback,bg = G_Path.getDungeonBattleMap( tower_info.get(self:getFloor()).map)})
            -- uf_sceneManager:pushScene(battle)
            uf_sceneManager:replaceScene(battle)
        end, 
        function ( ... )
            --开始播放战斗
            battle:play()
        end)
        
    else
        MessageBoxEx.showOkMessage(nil, G_NetMsgError.getMsg(data.ret))
    end  
end

-- 计算结果
function TowerLayer:_calcResult()
    local score  = 0

    local ti = tower_info.get(self:getFloor())
    score = score + ti.tower_score

   return score
end

function TowerLayer:_challengeSucceed()
    __Log("------------challenge succeed ----------------")
    self._curTryLeft = self:getMaxTry()
    self:_scrollMove()
     self:forwardNextFloor()
end

function TowerLayer:_onStopCleanupRsp(data)
    if data and data.ret == 1 then
        if self._schedule then
            GlobalFunc.removeTimer(self._schedule)
            self._schedule = nil
        end

        self:stopCleanup(data.floor)
    end
end

function TowerLayer:adapterLayer(...)
    -- G_HandlersManager.towerHandler:sendQueryTowerInfo()
    --self:adapterWidgetHeight("Panel_Tower", "Panel_Header","Panel_Corner",0,0)
end

function TowerLayer:strokeBrown(label)
    label:createStroke(Colors.strokeBrown, 1)
end

function TowerLayer:_setTop()
    local ti = tower_info.get(self:getFloor())
    if not ti then 
        ti = tower_info.get(self:getFloor() - 1)
    end
    local tiaojian = self:getLabelByName("Label_30")
    tiaojian:setText(G_lang:get("LANG_TOWER_TIAOJIAN"))
    self:strokeBrown(tiaojian)
    self:getLabelByName("Label_Floor"):setText(ti.success_name)
    self:strokeBrown(self:getLabelByName("Label_Floor"))
    self:getLabelByName("Label_win"):setText(ti.success_directions)
    self:strokeBrown(self:getLabelByName("Label_win"))

    self:getLabelByName("Label_jifenzhi"):setText(G_Me.userData.tower_score)
    self:strokeBrown(self:getLabelByName("Label_jifenzhi"))
end

function TowerLayer:_goAward()
    local giftMailLayer = require("app.scenes.giftmail.GiftMailLayer").create()
    uf_notifyLayer:getModelNode():addChild(giftMailLayer)
    giftMailLayer:showAtCenter(true)
end

return TowerLayer
