
-- dwk 
-- 20140808
local MonthCardGetLayer = class("MonthCardGetLayer", BaseLayer)

function MonthCardGetLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.CardGetLayer")

    self.getReward = false

    self:Draw()

end

function MonthCardGetLayer:initUI(ui)
    self.super.initUI(self,ui)
    
    -- 
    self.btn_Close     = TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_get       = TFDirector:getChildByPath(ui, 'btn_get')
    self.txt_num       = TFDirector:getChildByPath(ui, 'txt_num')
    self.txt_wenben    = TFDirector:getChildByPath(ui, "txt_wenben1")

    self.btn_get.logic = self
end

function MonthCardGetLayer:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_get:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.BtnClickHandle),1)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_Close)

    TFDirector:addMEGlobalListener("GetMonthCardPrize", function()
        -- 标记今天已领过了
        -- self.getReward = true
        play_chongzhichenggong()
        
        --toastMessage("已领取100元宝")
        toastMessage(localizable.monthCard_text1)
        self:Draw() 
    end)

    TFDirector:addMEGlobalListener("monthCardUpdate", function()
        self:Draw()
    end)

    
end

function MonthCardGetLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener("GetMonthCardPrize")
    TFDirector:removeMEGlobalListener("monthCardUpdate")
end


function MonthCardGetLayer.BtnClickHandle(sender)
    local self = sender.logic

    -- 没有领取过奖励
    if self.getReward == false then
        -- 领取奖励
        QiyuManager:GetContractPrize()
    else
        --toastMessage("今天已经领过元宝了")
        toastMessage(localizable.monthCartGet_already)
    end
end


function MonthCardGetLayer:Draw()
    -- 当前时间
    local nowTime               = MainPlayer:getNowtime()
    local secInOneDay           = 24 * 60 * 60 * 1000
    local lastRewardDayIndex    = math.floor(QiyuManager.ContractInfo.lastGotRewardTime / secInOneDay)
    local endDayIndex           = math.floor(QiyuManager.ContractInfo.endTime / secInOneDay)
    local nowDayIndex           = math.floor(nowTime * 1000 / secInOneDay)
    -- local tmpDateTab = os.date('*t',QiyuManager.ContractInfo.lastGotRewardTime/1000)
    -- local lastRewardDayIndex    = tmpDateTab.yday
    -- tmpDateTab = os.date('*t',QiyuManager.ContractInfo.endTime/1000)
    -- local endDayIndex           = tmpDateTab.yday
    -- tmpDateTab = os.date('*t',nowTime)
    -- local nowDayIndex           = tmpDateTab.yday

    -- print("now time : ",currentServerTime,nowDayIndex,endDayIndex,lastRewardDayIndex)

    lastRewardDayIndex  = math.ceil(lastRewardDayIndex)
    endDayIndex         = math.ceil(endDayIndex)
    nowDayIndex         = math.ceil(nowDayIndex)

    print(nowDayIndex, lastRewardDayIndex, endDayIndex)

    if nowDayIndex <= lastRewardDayIndex then
        self.getReward = true
    else
        self.getReward = false
    end

    local outTimeDay = endDayIndex - nowDayIndex - 1

    if outTimeDay < 0 then
        outTimeDay = 0
    end
    self.txt_num:setText(string.format("%d", outTimeDay))

    if self.getReward then
        --self.txt_wenben:setText("今日已领取")
        self.txt_wenben:setText(localizable.monthCard_text2)
    else
        --self.txt_wenben:setText("小二为你辛勤工作，赚得")
        self.txt_wenben:setText(localizable.monthCard_text3)
    end
    
    -- 设置按钮状态
    self.btn_get:setTouchEnabled(not self.getReward)
    self.btn_get:setGrayEnabled(self.getReward)

    -- local tab = os.date("*t", nowTime)

end


return MonthCardGetLayer