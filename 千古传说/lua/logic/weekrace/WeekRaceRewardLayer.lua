
local WeekRaceRewardLayer = class("WeekRaceRewardLayer", BaseLayer)


-- AwardItemData = require('lua.table.t_s_goods')

function WeekRaceRewardLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.zhenbashai.ZhenbashaiReward")
end

function WeekRaceRewardLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.closeBtn       = TFDirector:getChildByPath(ui, 'btn_close')

    self.numTable = {}
    local NodeName = {'bg','bg_2','bg_3','bg_4'}
    for i=1,4 do
    	local bgNode = TFDirector:getChildByPath(ui, NodeName[i])
    	self.numTable[i] = {}
    	self.numTable[i].txt_yb = TFDirector:getChildByPath(bgNode, 'txt1')
    	self.numTable[i].txt_coin = TFDirector:getChildByPath(bgNode, 'txt2')
    end

    local rankData = {1,2,3,5}
    for i=1,#rankData do
        local itemData = ChampionsAwardData:getRewardData( 2, rankData[i] )
        if itemData then
            local rewardlist = itemData:getReward()

            if rewardlist[1] ~= nil then
                self.numTable[i].txt_coin:setText('x'..rewardlist[1].number)
            else
                self.numTable[i].txt_coin:setText('x0')
            end
            if rewardlist[2] ~= nil then
                self.numTable[i].txt_yb:setText('x'..rewardlist[2].number)
            else
                self.numTable[i].txt_yb:setText('x0')
            end

        end
    end
    
end

function WeekRaceRewardLayer:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);
end

function WeekRaceRewardLayer:removeEvents()
    self.super.removeEvents(self)

end

function WeekRaceRewardLayer.closeBtnClickHandle(sender)
    AlertManager:close(AlertManager.TWEEN_1);
end

return WeekRaceRewardLayer