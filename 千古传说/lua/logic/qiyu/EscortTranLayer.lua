
local EscortTranLayer = class("EscortTranLayer", BaseLayer)

function EscortTranLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.AgencyLayer")
    
    -- self:initData()
    self.yabiaoCarList = require("lua.table.t_s_yabiao_template")
    self:redraw()
end

function EscortTranLayer:initUI(ui)
    self.super.initUI(self,ui)

    --押镖次数时间
    self.txt_Num    = TFDirector:getChildByPath(ui, 'txt_yabiaonum')
    self.txt_Time   = TFDirector:getChildByPath(ui, 'txt_yabiaotime')
    self.txt_Prize  = TFDirector:getChildByPath(ui, 'txt_yabiaojiangli')

    self.txt_Time2   = TFDirector:getChildByPath(ui, 'txt_yabiaotime2')
    self.img_yabiaoDiag = TFDirector:getChildByPath(ui, 'yunbiaozhong')

    -- 按钮
    self.btn_GetPrize   = TFDirector:getChildByPath(ui, 'btn_lingqu')
    self.btn_Begin      = TFDirector:getChildByPath(ui, 'btn_yabiao')
    self.btn_Refresh    = TFDirector:getChildByPath(ui, 'btn_shuaxin')
    self.btn_jiasu      = TFDirector:getChildByPath(ui, 'btn_jiasu')

    -- img
    self.img_EscortDone = TFDirector:getChildByPath(ui, 'img_yabiaochenggong')
    self.img_EscortIng  = TFDirector:getChildByPath(ui, 'img_yabiaozhong')
    self.img_FreeTime   = TFDirector:getChildByPath(ui, 'img_bg3')
    self.img_Cost       = TFDirector:getChildByPath(ui, 'img_bg4')
    self.img_speedCost  = TFDirector:getChildByPath(ui, 'img_speedCost')

    local eftID = "yu_tiao"
    ModelManager:addResourceFromFile(2, eftID, 1)
    self.escortEft = ModelManager:createResource(2, eftID)
    self.escortEft:setPosition(ccp(self.img_EscortDone:getSize().width / 2, self.img_EscortDone:getSize().height / 2 - 30))
    self.img_EscortDone:addChild(self.escortEft)

    self.ui             = ui

    self.btn_GetPrize.logic = self
    self.btn_Begin.logic    = self
    self.btn_Refresh.logic  = self
    self.btn_jiasu.logic    = self

    self.btn_GetPrize:setVisible(false)
    self.btn_Begin:setVisible(false)
    self.btn_Refresh:setVisible(false)
    self.img_EscortDone:setVisible(false)
    self.img_EscortIng:setVisible(false)
    self.btn_jiasu:setVisible(false)
    self.img_speedCost:setVisible(false)
end

function EscortTranLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function EscortTranLayer:refreshUI()
    -- body
    self:draw()
end

function EscortTranLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.btn_GetPrize:addMEListener(TFWIDGET_CLICK, audioClickfun(self.GetPrizeBtnClickHandle),1)
    self.btn_Begin:addMEListener(TFWIDGET_CLICK,    audioClickfun(self.BeginEscortBtnClickHandle),1)
    self.btn_Refresh:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.RefreshCarBtnClickHandle),1)
    self.btn_jiasu:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.SpeedClickHandle),1)

    TFDirector:addMEGlobalListener("refreshYaBiao", function() self:refreshYaBiao() end)
    TFDirector:addMEGlobalListener("beginYaBiao",   function() self:redraw() end)
    TFDirector:addMEGlobalListener("rewardYaBiao",  function() self:redraw() end)
end

function EscortTranLayer:removeEvents()
    self.super.removeEvents(self)
    TFDirector:removeMEGlobalListener("refreshYaBiao")
    TFDirector:removeMEGlobalListener("beginYaBiao")
    TFDirector:removeMEGlobalListener("rewardYaBiao")

    if self.nTimerId ~= nil then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end
end

function EscortTranLayer.GetPrizeBtnClickHandle(sender)
    local self = sender.logic
    -- 领取奖励
    QiyuManager:RequestGetYaBiaoReward()
end

function EscortTranLayer.BeginEscortBtnClickHandle(sender)
    local self = sender.logic

    if self.EscortTotalNum <= 0 then
        --toastMessage("今天的押镖次数已经用完")
        toastMessage(localizable.EscortTranLayer_yabiao_times_over)
    else
        -- 开始押镖
        QiyuManager:RequestBeginYaBiao()
    end
end

function EscortTranLayer.RefreshCarBtnClickHandle(sender)
    local self = sender.logic

    if self.EscortTotalNum <= 0 then
        --toastMessage("今天的押镖次数已经用完")
        toastMessage(localizable.EscortTranLayer_yabiao_times_over)

        return
    end
    TFAudio.playEffect("sound/effect/lingqu.mp3",false)
    -- 刷新镖车
    if self.EscortRefreshFreeNum > 0 then
        -- 还有免费次数  直接刷新
        QiyuManager:RequestRefreshYaBiao()
    else
        print("self.nextRefreshCostSysee = ",self.nextRefreshCostSysee)
        -- 判断资源是否足够刷新
        if MainPlayer:isEnoughSycee(self.nextRefreshCostSysee, true) then
        -- if MainPlayer:isEnoughSycee(200000, true) then
            QiyuManager:RequestRefreshYaBiao()
        end
    end

    -- local radomIndex = math.random(6)
    -- self.defaultCarIndex        = radomIndex
    -- self:draw()
end

function EscortTranLayer.SpeedClickHandle(sender)
    local self = sender.logic

    local userVip =  MainPlayer:getVipLevel()
    local needVip =  VipData:getMinLevelDeclear(4004)

    if userVip < needVip then
         local msg =  stringUtils.format(localizable.vip_escortTran_not_enough,needVip);
        CommonManager:showOperateSureLayer(
                function()
                    PayManager:showPayLayer();
                end,
                nil,
                {
                title = localizable.common_vip_up,
                msg = msg,
                uiconfig = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
                }
        )
        return
    end

    QiyuManager:RequestClearYaBiaoCD()

end


function EscortTranLayer:drawEscortCar()
    local function drawCar(index, choosed)
        local desc    = string.format("panel_biaoche%d", index)
        local node    = TFDirector:getChildByPath(self.ui, desc)

        local img_choosed           = TFDirector:getChildByPath(node, "img_xuanzhongdi")
        local txt_num               = TFDirector:getChildByPath(node, "txt_num")
        local panel_biaocheeffect   = TFDirector:getChildByPath(self.ui, "panel_biaocheeffect")

        img_choosed:setVisible(choosed)
        -- img_choosed:setVisible(false)

        local reward_coin = 1000
        local carInfo = self.yabiaoCarList:getObjectAt(index)
        if carInfo ~= nil and carInfo.reward_coin ~= nil then
            reward_coin = carInfo.reward_coin
        end
        txt_num:setText(string.format("%d", reward_coin))
        if choosed then
            self.txt_Prize:setText(txt_num:getText())
        end
        
            -- -- 绘制动画
            -- local pos           = node:getPosition()
            -- local size          = node:getContentSize()

            -- if self.action1 == nil and self.cover == nil then
            --     local resPath = "effect/yabiao2.xml"
            --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
            --     local effect = TFArmature:create("yabiao2_anim")
            --     if effect then
            --         effect:setAnimationFps(GameConfig.ANIM_FPS)
            --     end
            --     effect:setPosition(ccp(size.width/2, size.height/2 + 50))
            --     panel_biaocheeffect:addChild(effect,1)
            --     self.action1 = effect

            --     self.cover = TFImage:create("ui_new/qiyu/yabiao/yb_cover.png")
            --     node:getParent():addChild(self.cover, 10)
            -- end
            -- self.action1:playByIndex(0, -1, -1, 1)
            -- panel_biaocheeffect:setPosition(pos)
            
            -- local x = pos.x  + size.width/2
            -- local y = pos.y  + size.height/2
            -- self.cover:setPosition(ccp(x, y))
            -- print("pos", x, y)
        -- end
    end

    for i=1,5 do
        local choosed = false
        if i == self.defaultCarIndex then
            choosed = true
        end
        drawCar(i, choosed)
    end
end

function EscortTranLayer:drawFreeTime()
    self.img_FreeTime:setVisible(false)
    if self.EscortRefreshFreeNum > 0 and self.EscortStatus == 1 then
        self.img_FreeTime:setVisible(true)
        local label_num  = TFDirector:getChildByPath(self.img_FreeTime, "txt_num")

        label_num:setText(string.format("%d",self.EscortRefreshFreeNum))
    end
end

function EscortTranLayer:drawCost()
    self.img_Cost:setVisible(false)
    if self.EscortRefreshFreeNum <= 0 and self.EscortStatus == 1 then
        self.img_Cost:setVisible(true)
        local label_num  = TFDirector:getChildByPath(self.img_Cost, "txt_num")

        label_num:setText(string.format("%d",self.nextRefreshCostSysee))
    end
    
end

function EscortTranLayer:drawInfo()
    self.btn_GetPrize:setVisible(false)
    self.btn_Begin:setVisible(false)
    self.btn_Refresh:setVisible(false)
    self.img_EscortDone:setVisible(false)
    self.img_EscortIng:setVisible(false)
    self.btn_jiasu:setVisible(false)
    self.img_speedCost:setVisible(false)

    if self.EscortStatus == 1 then
        self.btn_Begin:setVisible(true)
        self.btn_Refresh:setVisible(true)

        local bCanRefresh = true
        if self.defaultCarIndex == 5 then
            bCanRefresh = false
        end

        local bCanBeginEscort = true
        if self.EscortTotalNum <= 0 then
            bCanBeginEscort = false
            bCanRefresh     = false
        end   

        -- 设置押镖按钮状态
        self.btn_Begin:setTouchEnabled(bCanBeginEscort)
        self.btn_Begin:setGrayEnabled(not bCanBeginEscort)

        -- 设置刷新按钮状态
        self.btn_Refresh:setTouchEnabled(bCanRefresh)
        self.btn_Refresh:setGrayEnabled(not bCanRefresh)

    elseif self.EscortStatus == 2 then
        -- self.btn_GetPrize:setVisible(true)
        self.img_EscortIng:setVisible(true)
        self.btn_jiasu:setVisible(true)
        self.img_speedCost:setVisible(true)
        local img_res      = TFDirector:getChildByPath(self.img_speedCost, 'img_res_icon')
        local txt_cost     = TFDirector:getChildByPath(self.img_speedCost, 'txt_price')

        local CostInfo = ConstantData:objectByID("Yabiao.Cleancd.cost")

        img_res:setTexture(GetResourceIcon(CostInfo.res_type))
        txt_cost:setText(CostInfo.value)

    elseif self.EscortStatus == 3 then
        self.btn_GetPrize:setVisible(true)
        self.img_EscortDone:setVisible(true)
        ModelManager:playWithNameAndIndex(self.escortEft, "", 0, 1, -1, -1)
        if self.nTimerId ~= nil then
            TFDirector:removeTimer(self.nTimerId)
            self.nTimerId = nil
        end
    end

    
    self.txt_Num:setText(string.format("%d", self.EscortTotalNum))

    -- self.txt_Time:setText(string.format("%d", self.EscortTotalNum)
    -- self.txt_Prize:setText(string.format("%d", 2000))

    -- 绘制倒计时等信息
    if self.EscortStatus == 1 then

        local time = self.carInfo.duration
        local sec   = time * 60
        local time1 = math.floor(sec/3600)
        local time2 = math.floor(sec/60)
        local time3 = math.fmod(sec, 60)
        self.txt_Time:setText(string.format("%02d:%02d:%02d", time1, time2, time3))
        -- self.txt_Time:setText("30:00")
    elseif self.EscortStatus == 2 then
        self:addEffect()
        self:drawCountdownTime()    
    elseif self.EscortStatus == 3 then
        self.txt_Time:setText("00:00:00")
    end
end

function EscortTranLayer:draw()
    self:drawInfo()
    self:drawEscortCar()
    self:drawCost()
    self:drawFreeTime()
end

function EscortTranLayer:redraw()
    -- 重新获取押镖数据
    self:initData()
    -- 重新绘制
    self:draw()
end

function EscortTranLayer:refresCar()
    print("EscortTranLayer:refresCar()")
    self:drawEscortCar()
end

function EscortTranLayer:drawCountdownTime()

    -- 计算当前时间和到达时间
    local nowTime = math.floor(self.endTime/1000) - MainPlayer:getNowtime()
    if nowTime <= 0 then
        nowTime = 0
    end
    -- local time = self.carInfo.duration
    local sec   = nowTime --time * 60

    -- 创建倒计时
    if self.CountdownTimeobj == nil then
        self.CountdownTimeobj = TimeRecoverProperty:create(sec,0,1)
    end

    local time1 = math.floor(sec/3600)
    local time2 = math.floor((sec-time1 * 3600)/60)
    local time3 = math.fmod(sec, 60)
    self.txt_Time:setText(string.format("%02d:%02d:%02d", time1, time2, time3))
    self.txt_Time2:setText(string.format("%02d:%02d:%02d", time1, time2, time3))
    local function update(event)
        if self.CountdownTimeobj then
            self.txt_Time:setText(self.CountdownTimeobj:getRemainRecoverTimeString())
            self.txt_Time2:setText(self.CountdownTimeobj:getRemainRecoverTimeString())
            if self.CountdownTimeobj:getRemainRecoverTime() <= 0 then
                self.CountdownTimeobj = nil
                -- 时间到了
                self.EscortStatus = 3
                self:draw()
            end
        else

        end
    end

    if not  self.nTimerId then
         self.nTimerId = TFDirector:addTimer(1000, -1, nil, update)
    end

    update()
end

function EscortTranLayer:initData()

    local nowTime = MainPlayer:getNowtime()

    local data = QiyuManager.yabiaoData
    self.defaultCarIndex        = data.id                   -- 当前选择的镖车
    self.startTime              = data.startTime            -- 开始时间
    self.endTime                = data.endTime              -- 今日剩余押镖次数
    self.EscortRefreshFreeNum   = data.leftFreeRefreshTime  -- 押镖免费刷新次数
    self.status                 = data.status               -- 押镖状态：0、空闲；1、正在押镖；2、押镖完成可以领取奖励
    self.EscortTotalNum         = data.leftYabiaoTime       -- 押镖总次数
    self.nextRefreshCostSysee   = data.nextRefreshCostSysee -- 下次刷新花费元宝

    -- 普通状态1 押镖状态2 领奖状态3
    if self.status == 0 then
        self.EscortStatus = 1
    elseif self.status == 1 then
        local endTime = math.floor(self.endTime/1000)
        print(nowTime, endTime)
        if nowTime >= endTime then
            self.EscortStatus = 3
        else
            self.EscortStatus = 2
        end
    else
        self.EscortStatus = 3
    end

    self.carInfo = self.yabiaoCarList:getObjectAt(self.defaultCarIndex)

    print("self.EscortTotalNum = %d", self.EscortTotalNum)
    print("self.EscortRefreshFreeNum= %d", self.EscortRefreshFreeNum)
    print("self.nextRefreshCostSysee= %d", self.nextRefreshCostSysee)
end


function EscortTranLayer:refreshYaBiao()
    self:redraw()
    
    -- add effect
    local index = self.defaultCarIndex
    local desc                  = string.format("panel_biaoche%d", index)
    print("EscortTranLayer:refreshYaBiao() index = ",index,desc)
    local node                  = TFDirector:getChildByPath(self.ui, desc)
    local img_choosed           = TFDirector:getChildByPath(node, "img_xuanzhongdi")
    local txt_num               = TFDirector:getChildByPath(node, "txt_num")

    -- 绘制动画
    local pos           = node:getPosition()
    local size          = node:getContentSize()
    if self.action1 ~= nil then
        if img_choosed:getParent():getChildByTag(100) == nil then
            self.action1:removeFromParentAndCleanup(true)
            self.action1 = nil
        end
    end
    if self.action1 == nil then
        local resPath = "effect/yabiao2.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("yabiao2_anim")
        if effect then
            effect:setAnimationFps(GameConfig.ANIM_FPS)
        end
        effect:setPosition(ccp(225, 60))
        effect:setTag(100)
        img_choosed:getParent():addChild(effect,1)
        self.action1 = effect

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            self.action1:removeFromParentAndCleanup(true)
            self.action1 = nil
        end)

    end
    self.action1:playByIndex(0, -1, -1, 0)
end

function EscortTranLayer:addEffect()
    -- local node = self.img_yabiaoDiag
    -- if node == nil then
    --     return
    -- end

    -- local effect = self.escortEffect
    -- if effect == nil then
    --     local resPath = "effect/Escort_tran_effect.xml"
    --     TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    --     effect = TFArmature:create("Escort_tran_effect_anim")

    --     node:addChild(effect, 100)
    --     effect:setPosition(ccp(0, 0))

    --     self.escortEffect = effect

    --     effect:addMEListener(TFARMATURE_COMPLETE,function()
    --         self.escortEffect:setVisible(false)
    --     end)
    -- end
    -- effect:setVisible(true)
    -- effect:playByIndex(0, -1, -1, 1)

    if not self.escortEffect then
        self.ui:runAnimation("Action0", -1)
    end

    self.escortEffect = true
end

return EscortTranLayer