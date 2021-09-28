--[[ 全民宝地 ]]--
local FireWorkSideNode = class("FireWorkSideNode", function() return cc.Layer:create() end)

function FireWorkSideNode:ctor(objId)
    self.data = {}
    local msgids = {TREASURE_SC_REMAIN_TIME_RET}
    require("src/MsgHandler").new(self,msgids)

    local baseNode = cc.Node:create()
    self:addChild(baseNode)
    baseNode:setPosition(cc.p(0, 0))
    self.baseNode = baseNode

    self.timeBg = createSprite(baseNode, "res/mainui/sideInfo/timeBg.png", cc.p(display.width-154-171, g_scrSize.height), cc.p(0, 1))
    self.timeBg:setVisible(false)

    self:addInfo()
    g_msgHandlerInst:sendNetDataByTableExEx(TREASURE_CS_REMAIN_TIME, "TreasureReaminTimeProtocol", {})
    --addNetLoading(TREASURE_CS_REMAIN_TIME, TREASURE_SC_REMAIN_TIME_RET)
end

function FireWorkSideNode:addInfo()
    local func = function()
        self:exit()
    end
    function exitConfirm()
        MessageBoxYesNo(nil,game.getStrByKey("exit_confirm"),func,nil)
    end
    local item = createMenuItem(self.baseNode,"res/component/button/1.png", cc.p(g_scrSize.width-70, g_scrSize.height-110),exitConfirm)
    item:setSmallToBigMode(false)
    createLabel(item, game.getStrByKey("exit"), getCenterPos(item), cc.p(0.5,0.5), 22, true):setColor(MColor.lable_yellow)    

    --剩余时间
    local timeBgSize = self.timeBg:getContentSize()
    createLabel(self.timeBg, game.getStrByKey("fireWork_text4"), cc.p(timeBgSize.width/2, timeBgSize.height - 16), cc.p(0.5, 0.5), 18, true):setColor(MColor.lable_yellow)
    self.RemainTimeText = createLabel(self.timeBg, "30:00", cc.p(timeBgSize.width/2, timeBgSize.height/2-10), cc.p(0.5, 0.5), 22, true)
    self.RemainTimeText:setColor(MColor.green)
end

function FireWorkSideNode:UpdateInfo()
    print("FireWorkSideNode:UpdateInfo ..RemainTime." .. self.data.RemainTime)
    
    self.timeBg:setVisible(true)
    if self.TimeAction then
        self.TimeAction:stopAllActions()
        self.TimeAction = nil
    end

    if not self.TimeAction and self.data.RemainTime > 0 then
        self.TimeAction = startTimerActionEx(self, 1, true, function(delTime)
            self.data.RemainTime = self.data.RemainTime - delTime
            if self.data.RemainTime >= 0 then
                self.RemainTimeText:setString(self:getTimeStr(self.data.RemainTime))
            end
            if self.data.RemainTime <= 0 then
                self.TimeAction:stopAllActions()
                self.TimeAction = nil
                self:exit()
            end
        end)
    end
end

function FireWorkSideNode:exit()
    g_msgHandlerInst:sendNetDataByTableExEx(TREASURE_CS_OUT, "TreasureOutProtocol", {})
end

function FireWorkSideNode:getTimeStr(time)
    return string.format("%02d", (math.floor(time/60)%60)) .. ":" .. string.format("%02d", math.floor(time%60)) 
end

function FireWorkSideNode:networkHander(luabuffer,msgid)
    switch = {
        [TREASURE_SC_REMAIN_TIME_RET] = function()
        	local retTab = g_msgHandlerInst:convertBufferToTable("TreasureReaminTimeRetProtocol", luabuffer)
            self.data.RemainTime = retTab.remainTime --玩家在地图中的剩余时间
            self:UpdateInfo()
        end,
    }

    if switch[msgid] then
        switch[msgid]()
    end
end


return FireWorkSideNode