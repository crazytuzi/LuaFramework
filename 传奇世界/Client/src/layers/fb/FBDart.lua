--[[ 运镖副本 1-N ]]--
local FBDart = class("FBDart", function() return cc.Node:create() end)
local commConst = require("src/config/CommDef")

local function getTimeStr(time)
    return time-- string.format("%02d", (math.floor(time/60)%60)) .. ":" .. string.format("%02d", math.floor(time%60)) 
end

function FBDart:ctor()
    self.netData = {}
    self.state = 1
    self.isSendExitMsg = false
    userInfo.lastFBScene = commConst.CARBON_DART

    local msgids = {COMMON_SC_VITURALESCROTTIMERET, COMMON_SC_VITURALESCROTRESULT}
    require("src/MsgHandler").new(self,msgids)

    g_msgHandlerInst:sendNetDataByTableExEx(COMMON_CS_VITURALESCROTTIME, "VitrualEscrotTimeProtocol", {})

    self:setMapBlack()
    self:addDartEndPoint()
    self:addExitBtn()
end

function FBDart:addExitBtn()
    local func = function()
        self:exitFb()
    end

    function exitConfirm()
        MessageBoxYesNo(nil, game.getStrByKey("exit_confirm"), func, nil)
    end

    local item = createMenuItem(self,"res/component/button/1.png", cc.p(g_scrSize.width-70, g_scrSize.height-110),exitConfirm)
    item:setSmallToBigMode(false)
    self.exitBtnLab = createLabel(item, game.getStrByKey("fb_leave"), getCenterPos(item), cc.p(0.5,0.5), 22, true)
end

function FBDart:addLeftTime(tempTime)
    if tempTime == nil then return end

    local timeBg = createSprite(self, "res/mainui/sideInfo/timeBg.png", cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
    local timeBgSize = timeBg:getContentSize()
    createLabel(timeBg, game.getStrByKey("faction_fire_time"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), cc.p(0.5, 0.5), 18, true)
    local RemainTimeText = createLabel(timeBg, getTimeStr(tempTime), cc.p(timeBgSize.width/2, timeBgSize.height/2-10), cc.p(0.5, 0.5), 26)
    RemainTimeText:setColor(MColor.green)
    self.RemainTimeText = RemainTimeText 
    self.timeBg = timeBg

    self:timeAction(tempTime)
end

function FBDart:timeAction(tempTime)
    if self.TimeAction then
        self.TimeAction:stopAllActions()
        self.TimeAction = nil
    end

    if not self.TimeAction and tempTime > 0 then
        self.TimeAction = startTimerActionEx(self, 1, true, function(delTime)
            tempTime = tempTime - delTime
            if tempTime >= 0 and self.RemainTimeText then
                self.RemainTimeText:setString(getTimeStr(tempTime))
            end
            if tempTime <= 0 then
                self.TimeAction:stopAllActions()
                self.TimeAction = nil
                self:exitFb()
            end
        end)
    end
end

function FBDart:setMapBlack()
    if G_MAINSCENE and G_MAINSCENE.map_layer then
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(0, 126, 110, 2), 1)
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(105, 192, 2, 235 - 192), 1)
        G_MAINSCENE.map_layer:setBlockRectValue(cc.rect(74, 166, 15, 2), 1)
    end
end

function FBDart:addDartEndPoint()
    if G_MAINSCENE and G_MAINSCENE.map_layer then
        local transforEffect = Effects:create(false)
        transforEffect:setAnchorPoint(cc.p(0.5, 0.5))
        local t_pos = G_MAINSCENE.map_layer:tile2Space(cc.p(99, 191))
        transforEffect:setPosition(t_pos)
        G_MAINSCENE.map_layer:addChild(transforEffect,3)
        transforEffect:playActionData("transfor",15,2,-1)
        transforEffect:setScale(1.1)
        transforEffect:setColor(MColor.green)
        createSprite(G_MAINSCENE.map_layer, "res/mapui/transfor/2500.png", t_pos, cc.p(0.5, 0.0), 3)
    end
end

function FBDart:showResultView(ret)
    self.state = 2
    local towerEndData = {}
    towerEndData.isWin = ret

    if self.timeBg then
        self.timeBg:setVisible(false)
    end

    local func = function()
        if self.state == 2 then
            self.state = 3
            if not towerEndData.isWin then
                self:exitFb()
            else
                --成功倒计时出去
                if self.TimeAction then
                    self.TimeAction:stopAllActions()
                    self.TimeAction = nil
                end

                local tempTime = 15
                if not self.TimeAction and tempTime > 0 then
                    
                    if self.exitBtnLab then
                        self.exitBtnLab:setString(game.getStrByKey("fb_leave").. "(" .. tempTime.. ")")
                    end

                    self.TimeAction = startTimerActionEx(self, 1, true, function(delTime)
                        tempTime = tempTime - delTime

                        if tempTime >= 0 and self.exitBtnLab then
                            self.exitBtnLab:setString(game.getStrByKey("fb_leave").. "(" .. tempTime.. ")")
                        end
                        if tempTime <= 0 then
                            self.TimeAction:stopAllActions()
                            self.TimeAction = nil
                            self:exitFb()
                        end
                    end)
                end
            end
        end
    end

    if not ret then
        towerEndData.endCallFun = func
        local ret = require("src/layers/fb/FBResult").new(towerEndData)
        G_MAINSCENE:addChild(ret, 200)
    else
        func()
    end
end

function FBDart:exitFb()
    if not self.isSendExitMsg then
        self.isSendExitMsg = true
        g_msgHandlerInst:sendNetDataByTableExEx(COMMON_CS_VITURALESCROTEXIT, "VitrualEscrotExitProtocol", {})
        performWithDelay(self, function() self.isSendExitMsg = false end, 0.5)
    end
end

function FBDart:networkHander(luabuffer,msgid)
    switch = {
        [COMMON_SC_VITURALESCROTTIMERET] = function()
        	local retTab = g_msgHandlerInst:convertBufferToTable("VitrualEscrotTimeRetProtocol", luabuffer)
            self.netData.leftTime = retTab.leftTime         --玩家在地图中的剩余时间
            self:addLeftTime(self.netData.leftTime)
        end,
        [COMMON_SC_VITURALESCROTRESULT] = function()
            local retTab = g_msgHandlerInst:convertBufferToTable("VitrualEscrotResultProtocol", luabuffer)
            local ret = retTab.result
            self:showResultView(ret)
        end,
    }

    if switch[msgid] then
        switch[msgid]()
    end
end


return FBDart