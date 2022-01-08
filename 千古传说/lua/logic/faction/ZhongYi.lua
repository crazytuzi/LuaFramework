--[[
    This module is developed by

    -- by quanhuan
    -- 2015/10/29

    -- by eason
    -- 2015/11/3
]]

local ZhongYiLayer = class("ZhongYiLayer", BaseLayer)

local localVars = {
    factionName = "",
    factionLevel = 1,
    factionExp = 0,
    factionMaxExp = 1,
    factionProsperity = 0,
    individualContributions = 0,
    worship = 0,
    progressValue = 0,
    lastPlayerName = "",
    selectedDrink = 0,
    drawTreasureChests = {},
    progressValueOld = 0,
    currWorshipCount = 0,

    selectedChest = 0,

    level = 1,
    worshipPlanConfig = nil,
    guildWorshipConfig = nil,
}

function ZhongYiLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.ZhongYi")
end

function ZhongYiLayer:initUI( ui )
	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.Zyt_Faction, {HeadResType.FACTION_GX,HeadResType.COIN,HeadResType.SYCEE}) 

    --帮派信息
    self.nameLabel = TFDirector:getChildByPath(ui, "txt_name")
    self.level = TFDirector:getChildByPath(ui, "txt_level")
    self.expBar = TFDirector:getChildByPath(ui, "bar_exp")
    self.fanrong = TFDirector:getChildByPath(ui, "txt_fangrong")
    self.gongxian = TFDirector:getChildByPath(ui, "txt_gongxian")
    self.txtExp = TFDirector:getChildByPath(ui, "txt_exp")
    self.expBar:setDirection(TFLOADINGBAR_LEFT)
    self.expBar:setVisible(true)

    --宝箱
    self.normalBar = TFDirector:getChildByPath(ui, "bar_exp1")
    self.specialBar = TFDirector:getChildByPath(ui, "bar_exp2")
    self.loadingTxt = TFDirector:getChildByPath(ui, "txt_jindu")
    self.lastName = TFDirector:getChildByPath(ui, "img_lastname")
    self.lastNameTxt = TFDirector:getChildByPath(ui, "Label_ZhongYi_1")

    --self.bg_jindu = TFDirector:getChildByPath(ui, "bg_jindu")
    self.loadingBarWidth = self.normalBar:getContentSize().width -10
    self.loadingBarX = self.normalBar:getPositionX() - math.floor(self.loadingBarWidth/2)

    self.boxBtn = {}
    for i = 1,5 do
        self.boxBtn[i] = TFDirector:getChildByPath(ui, "btn_baoxiang" .. i)

        local resPath = "effect/factionbox" .. i .. ".xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("factionbox"..i.."_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(0, -10))
        self.boxBtn[i]:addChild(effect, 100)
        self.boxBtn[i].effect = effect
        effect:setTag(222)
        effect:setVisible(false)
        effect:playByIndex(0, -1, -1, 1)
    end

    self.normalBar:setDirection(TFLOADINGBAR_LEFT)
    self.normalBar:setVisible(true)  
    self.specialBar:setDirection(TFLOADINGBAR_LEFT)
    self.specialBar:setVisible(true)

    --喝酒
    self.drinkTable = {}
    for i = 1, 3 do
        local node = TFDirector:getChildByPath(ui, "btn_jibai" .. i)
        self.drinkTable[i] = {}
        self.drinkTable[i].btn = node
        self.drinkTable[i].fanrongAdd = TFDirector:getChildByPath(node, "txt1")
        self.drinkTable[i].expAdd = TFDirector:getChildByPath(node, "txt2")
        self.drinkTable[i].personalAdd = TFDirector:getChildByPath(node, "txt3")
        self.drinkTable[i].loadingAdd = TFDirector:getChildByPath(node, "txt_jibai")
        self.drinkTable[i].doneImg = TFDirector:getChildByPath(ui, "Icon_jibai"..i)
        self.drinkTable[i].doneImg:setVisible(false)
        self.drinkTable[i].texPrice = TFDirector:getChildByPath(node, "txt_price")
    end

    self.drinkTimes = TFDirector:getChildByPath(ui, "txt_cishu")
end

function ZhongYiLayer:removeUI()
   	self.super.removeUI(self)
end

function ZhongYiLayer:onShow()
    self.super.onShow(self)
    FactionManager:requestGuildStateInfo()
    self.generalHead:onShow()


    self:refreshWindow()

    for i = 1, 3 do
        --self.drinkTable[i].fanrongAdd:setText("帮派繁荣度+" .. localVars.guildWorshipConfig[i].boom)
        --self.drinkTable[i].expAdd:setText("帮派经验值+" .. localVars.guildWorshipConfig[i].exp)
        --self.drinkTable[i].personalAdd:setText("个人贡献+" .. localVars.guildWorshipConfig[i].dedication)
        self.drinkTable[i].fanrongAdd:setText(stringUtils.format(localizable.zhongyi_add1,  localVars.guildWorshipConfig[i].boom))
        self.drinkTable[i].expAdd:setText(stringUtils.format(localizable.zhongyi_add2,  localVars.guildWorshipConfig[i].exp))
        self.drinkTable[i].personalAdd:setText(stringUtils.format(localizable.zhongyi_add3,  localVars.guildWorshipConfig[i].dedication))

        if localVars.guildWorshipConfig[i].money_type == 3 then
            self.drinkTable[i].texPrice:setText(  stringUtils.format(localizable.fun_wan_desc, math.ceil(localVars.guildWorshipConfig[i].num / 10000) ))
        else
            self.drinkTable[i].texPrice:setText(localVars.guildWorshipConfig[i].num)
        end
    end
    self.drinkTable[1].loadingAdd:setText("+"..localVars.worshipPlanConfig.plan1)
    self.drinkTable[2].loadingAdd:setText("+"..localVars.worshipPlanConfig.plan2)
    self.drinkTable[3].loadingAdd:setText("+"..localVars.worshipPlanConfig.plan3)
end

function ZhongYiLayer:registerEvents()
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    for i=1,5 do
        self.boxBtn[i].idx = i
        self.boxBtn[i].logic = self
        self.boxBtn[i]:addMEListener(TFWIDGET_CLICK, audioClickfun(self.boxButtonClick))
    end

    for i = 1, 3 do
        self.drinkTable[i].btn.idx = i
        self.drinkTable[i].btn.logic = self
        self.drinkTable[i].btn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.drinkButtonClick))
    end

    self.onUpdate = function(event)
        print("self.onUpdate")
        print(event.data)

        if event.data[1].userdata == "info" then
            localVars.progressValue = event.data[1].secondlyProgress
            localVars.lastPlayerName = event.data[1].lastPlayerName
            localVars.currWorshipCount = event.data[1].worshipCount
            localVars.progressValueOld = localVars.progressValue


        elseif event.data[1].userdata == "worship" then
            local addBoom = localVars.guildWorshipConfig[localVars.selectedDrink].boom
            local addExp = localVars.guildWorshipConfig[localVars.selectedDrink].exp
            local addDedication = localVars.guildWorshipConfig[localVars.selectedDrink].dedication

            FactionManager:updateDataAfterWorship(addExp, addBoom, addDedication, localVars.selectedDrink)

            if localVars.selectedDrink == 1 then
                localVars.progressValue = localVars.progressValue + localVars.worshipPlanConfig.plan1

            elseif localVars.selectedDrink == 2 then
                localVars.progressValue = localVars.progressValue + localVars.worshipPlanConfig.plan2

            elseif localVars.selectedDrink == 3 then
                localVars.progressValue = localVars.progressValue + localVars.worshipPlanConfig.plan3
                localVars.lastPlayerName = MainPlayer:getPlayerName()
            end

            --toastMessage("祭拜成功")
            toastMessage(localizable.zhongyi_text1)
        elseif event.data[1].userdata == "worshipbox" then
            FactionManager:updateDataAfterOpenWorshipBox(localVars.selectedChest)
        end
        
        self:refreshWindow()
    end
    TFDirector:addMEGlobalListener(FactionManager.updateZhongYiLayer, self.onUpdate)
end

function ZhongYiLayer:removeEvents()
    self.super.removeEvents(self)
    if self.generalHead then
        self.generalHead:removeEvents()
    end

    for i=1,5 do
        self.boxBtn[i]:removeMEListener(TFWIDGET_CLICK)
    end

    for i = 1, 3 do
        self.drinkTable[i].btn:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(FactionManager.updateZhongYiLayer, self.onUpdate)
    if self.progressTimer then
        TFDirector:removeTimer(self.progressTimer)
        self.progressTimer = nil 
    end
end

function ZhongYiLayer:dispose()
    self.super.dispose(self)

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
end

function ZhongYiLayer:refreshWindow()
    print("ZhongYiLayer:refreshWindow()")
   
    -- 设置界面数据
    local factionInfo = FactionManager:getFactionInfo()
    localVars.factionName = factionInfo.name
    localVars.factionLevel = factionInfo.level
    localVars.factionExp = factionInfo.exp
    localVars.factionMaxExp = FactionManager:getFactionLevelUpExp(localVars.factionLevel + 1)
    localVars.factionProsperity = factionInfo.boom

    localVars.level = FactionManager:getZhongyiLevel()

    localVars.worshipPlanConfig = WorshipPlanConfig:getDataByLevel(localVars.level)
    localVars.guildWorshipConfig = GuildWorshipConfig:getDataByLevel(localVars.level)
    --
    --1
    self.boxDataInfo = {}
    for i=1,5 do
        if i <= localVars.worshipPlanConfig.number then
            self.boxBtn[i]:setVisible(true)
            local boxPlan = string.split(localVars.worshipPlanConfig['box'..i],',')
            self.boxDataInfo[i] = {}
            self.boxDataInfo[i].id = tonumber(boxPlan[1])
            self.boxDataInfo[i].point = tonumber(boxPlan[2])
            maxWidth = tonumber(boxPlan[2])
        else
            self.boxBtn[i]:setVisible(false)
        end
    end
    
    --动态设置宝箱的位置
    for i=1,#self.boxDataInfo do
        local currWidth = math.floor(self.boxDataInfo[i].point*self.loadingBarWidth/maxWidth)
        local currX = self.loadingBarX + currWidth
        self.boxBtn[i]:setPositionX(currX)        
    end

    local personalInfo = FactionManager:getPersonalInfo()
    print(personalInfo)
    localVars.individualContributions = personalInfo.dedication
    localVars.worship = personalInfo.worship
    localVars.drawTreasureChests = personalInfo.drawTreasureChests

    self.nameLabel:setText(localVars.factionName)
    self.level:setText(localVars.factionLevel .. "d")
    self.expBar:setPercent(math.floor(localVars.factionExp * 100 / localVars.factionMaxExp))
    self.txtExp:setText(localVars.factionExp.."/"..localVars.factionMaxExp)

    --显示宝箱领取特效
    local function searchFun( exp )
        for i=1,#localVars.drawTreasureChests do
            if localVars.drawTreasureChests[i] == exp then
                return true
            end
        end
        return false
    end
    
    for i=1, #self.boxDataInfo do
        if localVars.progressValue >= self.boxDataInfo[i].point then
            if searchFun(self.boxDataInfo[i].point) then
                self.boxBtn[i].effect:setVisible(false)
                --changeBtnStateToNormal
                --self.boxBtn[i]:setGrayEnabled(true)
                self.boxBtn[i]:setShaderProgram("GrayShader", true)
                self.boxBtn[i]:setTouchEnabled(false)
            else
                self.boxBtn[i].effect:setVisible(true)
                -- self.boxBtn[i]:setGrayEnabled(false)
                self.boxBtn[i]:setShaderProgram("GrayShader", false)
                self.boxBtn[i]:setTouchEnabled(true)
            end
        else
            self.boxBtn[i].effect:setVisible(false)
            -- self.boxBtn[i]:setGrayEnabled(false)
            self.boxBtn[i]:setShaderProgram("GrayShader", false)
            self.boxBtn[i]:setTouchEnabled(true)
        end
    end

    -- 开启或禁用祭拜按钮
    for i = 1, 3 do
        if localVars.worship == 0 then
            self.drinkTable[i].btn:setOpacity(255)
            self.drinkTable[i].btn:setTouchEnabled(true)
            self.drinkTable[i].btn:setGrayEnabled(false)
            self.drinkTable[i].doneImg:setVisible(false)
        else
            if localVars.worship == i then                
                -- self.drinkTable[i].btn:setTouchEnabled(false)
                -- self.drinkTable[i].btn:setGrayEnabled(false)
                self.drinkTable[i].doneImg:setVisible(true)
            else
                -- self.drinkTable[i].btn:setTouchEnabled(false)
                -- self.drinkTable[i].btn:setGrayEnabled(true)
                self.drinkTable[i].doneImg:setVisible(false)
            end
            self.drinkTable[i].btn:setTouchEnabled(false)
            self.drinkTable[i].btn:setOpacity(123)
        end
    end

    self.fanrong:setText(localVars.factionProsperity)
    self.gongxian:setText(MainPlayer:getDedication())

    if localVars.progressValue > localVars.progressValueOld then
        local dValue = localVars.progressValue - localVars.progressValueOld
        if self.progressTimer then
            TFDirector:removeTimer(self.progressTimer)
            self.progressTimer = nil 
        end
        self.progressTimer = TFDirector:addTimer(20, dValue,
            function () 
                localVars.progressValueOld = localVars.progressValue
                TFDirector:removeTimer(self.progressTimer)
                self.progressTimer = nil                
                self:playAnimWithProgress(localVars.progressValueOld)
            end,
            function () 
                localVars.progressValueOld = localVars.progressValueOld + 1
                if localVars.progressValueOld >= localVars.progressValue then
                    localVars.progressValueOld = localVars.progressValue
                    TFDirector:removeTimer(self.progressTimer)
                    self.progressTimer = nil
                end
                self:playAnimWithProgress(localVars.progressValueOld)
            end)
    else
        self:playAnimWithProgress(localVars.progressValue)
    end
 

    if localVars.worship == 0 then
        self.drinkTimes:setText("1")
    else
        self.drinkTimes:setText("0")
    end
end

function ZhongYiLayer:playAnimWithProgress(currValue)
    local normalProgress = currValue
    local specialProgress = normalProgress

    -- 显示或隐藏玩家名字
    if localVars.lastPlayerName == "" then
        self.lastName:setVisible(false)
    else
        self.lastName:setVisible(true)
        self.lastNameTxt:setText(localVars.lastPlayerName)

        if normalProgress > localVars.worshipPlanConfig.max_plan then
            normalProgress = localVars.worshipPlanConfig.max_plan
        end
        normalProgress = normalProgress - localVars.worshipPlanConfig.plan3
    end

    self.normalBar:setPercent(math.floor(normalProgress * 100 / localVars.worshipPlanConfig.max_plan))
    self.specialBar:setPercent(math.floor(specialProgress * 100 / localVars.worshipPlanConfig.max_plan))
    self.loadingTxt:setText(localVars.progressValue .. "/" .. localVars.worshipPlanConfig.max_plan)
    
    if localVars.lastPlayerName ~= "" then
        local percent = specialProgress / localVars.worshipPlanConfig.max_plan
        if percent > 1.0 then
            percent = 1.0
        end
        self.lastName:setPositionX(self.specialBar:getSize().width * percent - self.specialBar:getSize().width / 2)
    end
end

function ZhongYiLayer.boxButtonClick(btn)
    local self = btn.logic
    localVars.selectedChest = self.boxDataInfo[btn.idx].point
    if localVars.progressValue >= localVars.selectedChest then
        FactionManager:OpenWorshipBox(localVars.selectedChest)
    else
        local goodsId = self.boxDataInfo[btn.idx].id
        --预览宝箱   

        local calculateRewardList = TFArray:new();
        local rewardConfigure = DropData:objectByID(goodsId);
        local rewardInfo = {}
        rewardInfo.type = rewardConfigure.type
        rewardInfo.itemId = rewardConfigure.itemid
        rewardInfo.number = rewardConfigure.maxamount
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
        
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.zyBoxPop",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);        
        layer:loadData(calculateRewardList, localVars.selectedChest);
        AlertManager:show();
    end
end

function ZhongYiLayer.drinkButtonClick(btn)
    local moneyType = localVars.guildWorshipConfig[btn.idx].money_type
    local costMoney = localVars.guildWorshipConfig[btn.idx].num

    local maxMember = FactionManager:getWorshipMaxCount()
    if localVars.currWorshipCount >= maxMember then
        --toastMessage("帮派今日祭拜"..maxMember.."次已达到上限")
        toastMessage(stringUtils.format(localizable.zhongyi_text2,maxMember))
        return
    end

    local isMoneyEnough = true
    if moneyType == 3 then
        if MainPlayer:getCoin() < costMoney then
            isMoneyEnough = false
        end

    elseif moneyType == 4 then
        if MainPlayer:getSycee() < costMoney then
            isMoneyEnough = false
        end
    end

    if isMoneyEnough then
        localVars.selectedDrink = btn.idx
        FactionManager:worship(btn.idx)
    else
        if moneyType == 3 then
            --toastMessage("铜币不足")
            toastMessage(localizable.common_no_tongbi)
        elseif moneyType == 4 then
            -- toastMessage("元宝不足")
            MainPlayer:isEnoughSycee(costMoney, true)
        end
    end
end

return ZhongYiLayer