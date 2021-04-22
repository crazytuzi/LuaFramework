local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSunWarFireEffect = class("QUIWidgetSunWarFireEffect", QUIWidget)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetSunWarFireEffect:ctor(options)
    QUIWidgetSunWarFireEffect.super.ctor(self, nil, nil, options)
end

function QUIWidgetSunWarFireEffect:onExit()  
    if self._fireScheduleGlobal then
        scheduler.unscheduleGlobal(self._fireScheduleGlobal)
        self._fireScheduleGlobal = nil
    end
    if self._firePerformWithDelayGlobal then
        scheduler.unscheduleGlobal(self._firePerformWithDelayGlobal)
        self._firePerformWithDelayGlobal = nil
    end
end

function QUIWidgetSunWarFireEffect:showBuffEffect(startX, startY, endX, endY, callBack)
    self._callBack = callBack
    self._fireEndX = endX
    self._fireEndY = endY
   
    -- self._fireStartX, self._fireStartY = self._ccbOwner.node_tips:getPosition()
    self._fireStartX = startX
    self._fireStartY = startY

    if not self._fires or #self._fires == 0 then
        self._fires = {}
        self._scaleTbl = {}

        for i = 1, 3, 1 do
            -- local _, urls = remote.sunWar:getBuffFireURL(i)
            local ccbFile = "ccb/effects/zhanchang_fire_guang.ccbi"
            self._fires[i] = QUIWidgetAnimationPlayer.new()
            self._fires[i]:playAnimation(ccbFile, nil, nil, false)
            self._fires[i]:setScaleX(1)
            self._fires[i]:setScaleY(1)
            self:getView():addChild(self._fires[i])
            self._fires[i]:setVisible(false)
        end
    end

    local pos, ccbFile = remote.sunWar:getBuffTextToFireURL()
    local aniPlayer = QUIWidgetAnimationPlayer.new()
    self:getView():addChild(aniPlayer)
    aniPlayer:setPosition(self._fireStartX, self._fireStartY)
    aniPlayer:playAnimation(ccbFile, function ()
        -- self._ccbOwner.node_buff_text:setVisible(false)
    end, function ()
        self:_getFirePostions()
        self._fireScheduleGlobal = scheduler.scheduleGlobal(handler(self, QUIWidgetSunWarFireEffect._fireAnimations), 0)
    end)
end

function QUIWidgetSunWarFireEffect:_getFirePostions()
    if not self._firePositions or #self._firePositions == 0 then
        self._firePositions = {}
        local totalFrame = 20
        local step = 1 / totalFrame
        -- (x, y) 三段贝塞尔曲线公式中间点的坐标， SF是前段空多少祯（不动，保持原来的坐标），EF是后段空多少祯（没有坐标）
        local ps = {{x = 0, y = -30, sf = 0, ef = 10}, {sf = 10, ef = 0}, {x = ((self._fireEndX - self._fireStartX)/2 + self._fireStartX)*2, y = 30, sf = 5, ef = 5}}
        
        for _, p in pairs(ps) do
            local tbl = {}
            if not p.x then
                -- 直线
                -- print("[Kumo] 直线")
                local step = 1 / (totalFrame - p.ef)
                local x0, x1 = self._fireStartX, self._fireEndX
                local y0, y1 = self._fireStartY, self._fireEndY
                table.insert(tbl, {x = x0, y = y0})
                for i = 0, 1, step do
                    local x = x0
                    local y = y0
                    if i > p.sf * step then
                        x = (1-i)*x0 + i*x1
                        y = (1-i)*y0 + i*y1
                    end
                    table.insert(tbl, {x = x, y = y})
                end
                table.insert(tbl, {x = x1, y = y1})
            else
                -- 曲线
                -- print("[Kumo] 曲线")
                local step = 1 / (totalFrame - p.ef)
                local x0, x1, x2 = self._fireStartX, p.x, self._fireEndX
                local y0, y1, y2 = self._fireStartY, p.y, self._fireEndY
                table.insert(tbl, {x = x0, y = y0})
                for i = 0, 1, step do
                    local x = x0
                    local y = y0
                    if i > p.sf * step then
                        x = (1-i)*(1-i)*x0 + 2*i*(1-i)*x1 + i*i*x2
                        y = (1-i)*(1-i)*y0 + 2*i*(1-i)*y1 + i*i*y2
                    end
                    table.insert(tbl, {x = x, y = y})
                end
                table.insert(tbl, {x = x2, y = y2})
            end
            table.insert(self._firePositions, tbl)
        end
    end
    
    -- QPrintTable(self._firePositions)
end

function QUIWidgetSunWarFireEffect:_fireAnimations()
    if not self._firePositions or #self._firePositions < 3 then return end

    if not self._fires or #self._fires == 0 then
        self._fires = {}
        self._scaleTbl = {}

        for i = 1, 3, 1 do
            -- local _, urls = remote.sunWar:getBuffFireURL(i)
            local ccbFile = "ccb/effects/zhanchang_fire_guang.ccbi"
            self._fires[i] = QUIWidgetAnimationPlayer.new()
            self._fires[i]:playAnimation(ccbFile, nil, nil, false)
            self._fires[i]:setScaleX(1)
            self._fires[i]:setScaleY(1)
            self:getView():addChild(self._fires[i])
            self._fires[i]:setVisible(false)
        end
    end

    if not self._isFirePlaying then
        -- 准备播放
        self._fireIndex = 1
        self._isfireEnd = {false, false, false}
        self._isShowBuff = false
        for _, fire in pairs(self._fires) do
            fire:setVisible(true)
            fire:setScaleX(1)
            fire:setScaleY(1)
            fire:setRotation(0)
        end
        -- remote.sunWar:setIsBuffEffectPlaying(true)
    end

    self._isFirePlaying = true
    
    for id = 1, #self._fires, 1 do
        local node = self._fires[id]
        -- print(id, self._fireIndex, self._firePositions[id][self._fireIndex].x, self._firePositions[id][self._fireIndex].y)
        if self._firePositions[id][self._fireIndex] then
            if self._firePositions[id][self._fireIndex].x ~= self._fireStartX or self._firePositions[id][self._fireIndex].y ~= self._fireStartY then
                if node:getRotation() == 0 then
                    local moveFrame = #self._firePositions[id] - self._fireIndex - 1
                    local scaleYStep = 1 / moveFrame
                    local scaleXStep = 0.1 / moveFrame
                    self._scaleTbl[id] = {scaleXStep = scaleXStep, scaleYStep = scaleYStep}
                    -- print("[Kumo] ",id, #self._firePositions[id], self._fireIndex, moveFrame)
                    -- QPrintTable(self._scaleTbl)
                end

                local x1, y1 = self._firePositions[id][self._fireIndex - 1].x, self._firePositions[id][self._fireIndex - 1].y
                local x2, y2 = self._firePositions[id][self._fireIndex].x, self._firePositions[id][self._fireIndex].y
                local a = math.deg(math.atan((x2-x1)/(y2-y1)))
                
                node:setRotation(180 + a)
                -- print("[Kumo] 角度： ", id, 180+a)
                if self._scaleTbl[id] then
                    local scaleX = node:getScaleX() - self._scaleTbl[id].scaleXStep
                    local scaleY = node:getScaleY() + self._scaleTbl[id].scaleYStep
                    node:setScaleX(scaleX)
                    node:setScaleY(scaleY)
                    -- print("[Kumo] 形变， ", id, scaleX, scaleY)
                end
            end
            node:setPosition(self._firePositions[id][self._fireIndex].x, self._firePositions[id][self._fireIndex].y)
        else
            self._isfireEnd[id] = true
            node:setVisible(false)
        end
    end

    self._fireIndex = self._fireIndex + 1

    local isEnd = true

    for id = 1, #self._fires, 1 do
        if not self._isfireEnd[id] then
            isEnd = false
        else
            if not self._isShowBuff then
                self._isShowBuff = true
                -- remote.sunWar:addBuff( true )
            end
        end
    end

    if isEnd then
        if self._fireScheduleGlobal ~= nil then
            scheduler.unscheduleGlobal(self._fireScheduleGlobal)
            self._fireScheduleGlobal = nil
        end

        for _, fire in pairs(self._fires) do
            fire:setVisible(false)
        end

        self._isFirePlaying = false
        -- self._ccbOwner.node_buff_text:setVisible(true)
        -- self._firePerformWithDelayGlobal = scheduler.performWithDelayGlobal(function ()
            self._firePerformWithDelayGlobal = nil
            self:playEnd()
        -- end, 0.5)
        -- self:_showBuffEffect()
    end
end

function QUIWidgetSunWarFireEffect:playEnd()
    if self._callBack then
        self:_callBack()
    end
end

return QUIWidgetSunWarFireEffect