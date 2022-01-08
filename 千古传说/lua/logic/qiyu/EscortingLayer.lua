
local EscortingLayer = class("EscortingLayer", BaseLayer)

function EscortingLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.EscortingLayer")
end

function EscortingLayer:initUI(ui)
    self.super.initUI(self,ui)

    self.txt_coin_num       = TFDirector:getChildByPath(ui, 'txt_coin_num')
    self.txt_goods_name     = TFDirector:getChildByPath(ui, 'txt_goods_name')

    self.state = {}
    self.state[1]           = TFDirector:getChildByPath(ui, 'lbl_coming')
    self.state[2]           = TFDirector:getChildByPath(ui, 'bg_escorting')
    self.state[3]           = TFDirector:getChildByPath(ui, 'txt_complete')


    self.txt_times = {}
    self.txt_times[1]       = TFDirector:getChildByPath(self.state[1], 'txt_time_come')
    self.txt_times[2]       = TFDirector:getChildByPath(self.state[2], 'txt_times')

    self.txt_wait_time      = TFDirector:getChildByPath(self.state[1], 'txt_wait_time')

    self.btn_escorting      = TFDirector:getChildByPath(ui, 'btn_hujia')
    self.btn_escorting.logic = self

    self.btn_getReward      = TFDirector:getChildByPath(ui,'img_day')
    self.btn_getReward.logic = self

    self.txt_days           = TFDirector:getChildByPath(ui,'txt_days')

    self.reward_bg = {}
    self.reward_bg[1]     = TFDirector:getChildByPath(ui,'bg_reward_1')
    self.reward_bg[2]     = TFDirector:getChildByPath(ui,'bg_reward_2')

    --set visiable to false for all state widgets
    self:setAllStateWidgetsVisiable(false)

end

function EscortingLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

--[[
刷新显示内容
]]
function EscortingLayer:refreshUI()
    local status,waitTime = QiyuManager:getEscortingStatus()

    local escortingInfo = QiyuManager.escortingInfo
    local type = escortingInfo.type
    local finishTimes = escortingInfo.times
    local setting = EscortingSetting:objectByID(type)


    self.txt_days:setText(escortingInfo.days .. "/" .. setting.total_day)


        -- 牛逼的策划又要预览宝箱
    local reward = EscortingReward:getByTypeAndIndex(type,finishTimes+1)

    if reward == nil then
        self.btn_getReward:setTouchEnabled(true)
        self.rewardid = nil 
        return
    end

    local rewardBox = EscortingSetting:objectByID(reward.type)
    self.rewardid = rewardBox.finish_reward


    print(status, waitTime)
    if status == QiyuManager.Escorting_Status_TodayTimes_Is_Zero then
        self:setTodayFinish()
        self:removeTimer()
    elseif status == QiyuManager.Escorting_Status_Can_Challenge then
        for i = 1,#self.reward_bg do
            self.reward_bg[i]:setGrayEnabled(false)
        end

        -- local reward = EscortingReward:getByTypeAndIndex(type,finishTimes+1)
        self.txt_coin_num:setText(reward.coin)
        self:setAllStateWidgetsVisiableExclude(false,2)
        self.txt_days:setText(escortingInfo.days .. "/" .. setting.total_day)
        self.txt_times[2]:setText(escortingInfo.times+1)
        self.txt_coin_num:setVisible(true)
        self.txt_goods_name:setVisible(true)
        self:removeTimer()
    elseif status == QiyuManager.Escorting_Status_Coming then
        self:setComing()
        self:addTimer()
    end

    self.btn_getReward:setTouchEnabled(true)
    if QiyuManager.escortingFinishMark then
        -- 牛逼的策划又要预览宝箱
        -- self.btn_getReward:setTouchEnabled(true)
        -- self.btn_getReward:setGrayEnabled(false)

        self:drawEffect(true)
    else
        -- 牛逼的策划又要预览宝箱
        -- self.btn_getReward:setTouchEnabled(false)
        -- self.btn_getReward:setGrayEnabled(true)

        self:drawEffect(false)
    end


end

--[[
刺客正在准备中
]]
function EscortingLayer:setComing()
    local escortingInfo = QiyuManager.escortingInfo
    local type = escortingInfo.type
    local finishTimes = escortingInfo.times
    local setting = EscortingSetting:objectByID(type)

    for i = 1,#self.reward_bg do
        self.reward_bg[i]:setGrayEnabled(false)
    end
    local reward = EscortingReward:getByTypeAndIndex(type,finishTimes+1)
    self.txt_coin_num:setText(reward.coin)
    self:setAllStateWidgetsVisiableExclude(false,1)
    -- 牛逼的策划又要预览宝箱
    -- self.btn_getReward:setTouchEnabled(false)
    -- self.btn_getReward:setGrayEnabled(true)
    local timeWidget = TimeRecoverProperty:create(escortingInfo.enableTime, os.time(),1)
    self.txt_wait_time:setText(timeWidget:getRemainRecoverTimeString())
    self.txt_times[1]:setText(escortingInfo.times+1)
    self.txt_coin_num:setVisible(true)
    self.txt_goods_name:setVisible(true)


    self:drawEffect(false)
end

--[[
当天护驾完成
]]
function EscortingLayer:setTodayFinish()
    self:setAllStateWidgetsVisiableExclude(false,3)
    --self.txt_coin_num:setText("A/N")
    self.txt_coin_num:setVisible(false)
    self.txt_goods_name:setVisible(false)
    for i = 1,#self.reward_bg do
        self.reward_bg[i]:setGrayEnabled(true)
    end
end

--[[
设置护驾状态为完成
]]
function EscortingLayer:setToFinish()
    self:setAllStateWidgetsVisiableExclude(false,3)
    --self.txt_coin_num:setText("A/N")
    self.txt_coin_num:setVisible(false)
    self.txt_goods_name:setVisible(false)
    for i = 1,#self.reward_bg do
        self.reward_bg[i]:setGrayEnabled(true)
    end
end

--[[
set visiable for all state widgets
@params visiable 
]]
function EscortingLayer:setAllStateWidgetsVisiable(visiable)
    for i = 1,#self.state do
        self.state[i]:setVisible(visiable)
    end
end

--[[
set visiable for all state widgets
@params visiable 
]]
function EscortingLayer:setAllStateWidgetsVisiableExclude(visiable,exclude)
    for i = 1,#self.state do
        if i ~= exclude then
            self.state[i]:setVisible(visiable)
        else
            self.state[i]:setVisible(not visiable)
        end
    end

    if exclude == 2 then
        self.btn_escorting:setTouchEnabled(true)
        self.btn_escorting:setGrayEnabled(false)
    else
        self.btn_escorting:setTouchEnabled(false)
        self.btn_escorting:setGrayEnabled(true)
    end
end

function EscortingLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.btn_escorting:addMEListener(TFWIDGET_CLICK, audioClickfun(self.escortingButtonClickHandle),1)
    self.btn_getReward:addMEListener(TFWIDGET_CLICK, audioClickfun(self.getRewardButtonClickHandle),1)

    local function redraw()
        self:refreshUI()
        -- 刷新小红点
        if self.logic then
            self.logic:redraw()
        end
    end
    TFDirector:addMEGlobalListener(QiyuManager.EscortingInfoUpdate, redraw)
    TFDirector:addMEGlobalListener(QiyuManager.EscortingFinish,     redraw)
end

function EscortingLayer:addTimer()
    if not self.nTimerId then
        self.nTimerId = TFDirector:addTimer(1000, -1, nil, function(event)
            self:refreshUI()
        end, "autoRefreshEscortingLayer"); 
    end
end

function EscortingLayer:removeTimer()
    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end
end

function EscortingLayer:removeEvents()
    TFDirector:removeMEGlobalListener(QiyuManager.EscortingInfoUpdate)
    TFDirector:removeMEGlobalListener(QiyuManager.EscortingFinish)
    self:removeTimer()
    self.super.removeEvents(self)
end

function EscortingLayer.escortingButtonClickHandle(widget)
    local self = widget.logic
    QiyuManager:requestChallengeEscorting()
end

function EscortingLayer.getRewardButtonClickHandle(widget)
    local self = widget.logic
    -- QiyuManager:requestGetEscortingReward()
    -- 牛逼的策划又要预览宝箱
    local canReceiveGift = false
    if QiyuManager.escortingFinishMark then
        canReceiveGift = true
    end

    if  self.rewardid == nil then
        --toastMessage("今日奖励已领完")
        toastMessage(localizable.EscortingLayer_today_over)
        return
    end

    print("self.rewardid = ", self.rewardid)
    RewardManager:showGiftListLayer(self.rewardid, canReceiveGift,         
        function()
            QiyuManager:requestGetEscortingReward()
        end
     )
end

function EscortingLayer:playEscortingEffect()
    if self.EscortingEffect == nil  then
        local resPath = "effect/escorting.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("escorting_anim")
        local node   = self.btn_getReward --:getParent() --node:getPosition()

        effect:setAnimationFps(GameConfig.ANIM_FPS)

        node:addChild(effect, 1)
        effect:setPosition(ccp(88, 76))

        effect:setAnchorPoint(ccp(0.5, 0.5))
        effect:setScale(1.1)
        self.EscortingEffect = effect
    

        self.EscortingEffect:playByIndex(0, -1, -1, 1)
    end
end

-- 结束
function EscortingLayer:stopEscortingEffect()
    if self.EscortingEffect then
        self.EscortingEffect:removeFromParent()
        self.EscortingEffect = nil
    end
end

function EscortingLayer:drawEffect(bEffect)
    if bEffect then
        self:playEscortingEffect()
    else
        self:stopEscortingEffect()
    end
end

return EscortingLayer