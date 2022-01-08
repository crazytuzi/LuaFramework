--[[
******祈愿界面*******

	-- by Chikui Peng
	-- 2016/2/25
]]
local QiYuanLayer = class("QiYuanLayer", BaseLayer)

function QiYuanLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.shop.QiYuanMain")
end

function QiYuanLayer:initUI(ui)
	self.super.initUI(self,ui)
    self.generalHead = CommonManager:addGeneralHead( self ,10)
    self.generalHead:setData(ModuleType.QiYuan,{HeadResType.COIN,HeadResType.SYCEE})

    self.panel_rolelist = TFDirector:getChildByPath(ui, 'panel_rolelist')
    self.btn_genghuan   = TFDirector:getChildByPath(ui, 'btn_genghuan')
    self.btn_genghuan:setVisible(true)
    self.btn_qiyuan     = TFDirector:getChildByPath(ui, 'btn_qiyuan')
    self.txt_roleName   = TFDirector:getChildByPath(ui, 'txt_name')
    self.img_quallity   = TFDirector:getChildByPath(ui, 'img_quality_icon')
    self.img_diwen      = TFDirector:getChildByPath(ui, 'img_diwen1')
    -- self.img_role       = TFDirector:getChildByPath(ui, 'img_role')
    self.panel_role       = TFDirector:getChildByPath(ui, 'panel_role')
    self.img_roleblack  = TFDirector:getChildByPath(ui, 'img_rolehei')
    self.panel_content  = TFDirector:getChildByPath(ui, 'panel_content')
    self.img_huawen     = TFDirector:getChildByPath(ui, 'img_huawen')
    self.txt_time       = TFDirector:getChildByPath(ui, 'txt_time')
    self.txt_time2      = TFDirector:getChildByPath(ui, 'txt_time2')
    self.img_qiyuanshi  = TFDirector:getChildByPath(ui, 'img_qiyuanshi')
    self.txt_qiyuanshi  = TFDirector:getChildByPath(self.img_qiyuanshi, 'txt_num')  
    self.txt_days       = TFDirector:getChildByPath(ui, 'txt_days')
    self.btn_xiangzi    = TFDirector:getChildByPath(ui, 'btn_xiangzi')
    self.btn_help       = TFDirector:getChildByPath(ui, 'btn_help')
    self.role_list      = nil
    self.img_starList = {}
    for i=1,5 do
        self.img_starList[i] = TFDirector:getChildByPath(ui, "img_starliang_"..i)
        self.img_starList[i]:setVisible(false)
    end
    self.cardList = {}
    for i = 1,3 do
        self.cardList[i] = TFDirector:getChildByPath(ui, "panel_icon"..i)
    end
    self.updateTimerID = TFDirector:addTimer(1000, -1, nil, 
    function() 
        if nil == QiYuanManager:getSelectedRoleId() then
            return
        end
        self:UpdateCDTime()
    end)
    self.btnState = nil
    self.isQiYuaning = false
    self.roleId = QiYuanManager:getSelectedRoleId()
    self.txt_time2:setVisible(true)
    self.txt_time:setVisible(true)
    self.txt_time2:setText("")
    self.img_qiyuanshi:setVisible(false)
    if self.roleId ~= nil then
        self:setData()
    end
end

function QiYuanLayer:UpdateCDTime()
    local times = QiYuanManager:getTimes()
    local time = QiYuanManager:getQiYuanCD()
    if time > 0 then
        if self.bBrushBtn ~= true then
            self.bBrushBtn = true
            self:brushBtnState()
            self:brushTimerState()
        end
        local nMin = math.floor(time/60)
        local nSec = time%60
        if nil ~= self.timerTxt then
            --self.timerTxt:setText(string.format("%02d",nMin)..":"..string.format("%02d",nSec).."后免费")
            self.timerTxt:setText(stringUtils.format(localizable.qiyuanLayer_free,nMin,nSec))
        end
    else
        if self.bBrushBtn ~= false then
            self.bBrushBtn = false
            self:brushBtnState()
            self:brushTimerState()
        end
    end
end

function QiYuanLayer:brushTimerState()
    local times = QiYuanManager:getTimes() 
    if QiYuanManager:getQiYuanItemNum() > 0 then
        self.timerTxt = self.txt_time2
        
        if times.maxTimes <= times.curTimes then
            self.txt_time2:setText("")
            self.txt_time:setText("")
            self.timerTxt = nil
            self.img_qiyuanshi:setVisible(true)
        else
            if QiYuanManager:getQiYuanCD() > 0 then
                self.txt_time:setText("")
                self.img_qiyuanshi:setVisible(true)
            else
                self.txt_time2:setText("")
                self.img_qiyuanshi:setVisible(false)
                self:brushTimer1State()
            end
        end
    else
        self.img_qiyuanshi:setVisible(false)
        self.timerTxt = self.txt_time
        self.txt_time2:setText("")
        if times.maxTimes <= times.curTimes or  QiYuanManager:getQiYuanCD() <= 0 then
            self.timerTxt = nil
            self:brushTimer1State()
        end
    end
end

function QiYuanLayer:brushTimer1State()
    local times = QiYuanManager:getTimes()
    local lefttime = times.maxTimes - times.curTimes
    if lefttime < 0 then
        lefttime = 0
    end 
    --self.txt_time:setText("免费("..lefttime.."/"..times.maxTimes..")")
    self.txt_time:setText(stringUtils.format(localizable.qiyuanLayer_free_times,lefttime,times.maxTimes))
    if times.maxTimes <= times.curTimes then
        self.txt_time:setColor(ccc3(255,0,0))
    else
        self.txt_time:setColor(ccc3(255,255,255))
    end
end

function QiYuanLayer:brushBtnState()
    if QiYuanManager:isCanQiyuan() == true then
        self:setBtnState(1)
    else
        self:setBtnState(0)
    end
end

function QiYuanLayer:setBtnState(nState)
    if nil == self.roleId then
        nState = 0
    end
    if nState == self.btnState then
        return
    end
    self.btnState = nState
    if nState == 0 then
        self.btn_qiyuan:setTextureNormal("ui_new/shop/btn_qiyuan2.png")
        self.btn_qiyuan:setTouchEnabled(false)
        Public:addBtnWaterEffect(self.btn_qiyuan, false,1)
    else
        self.btn_qiyuan:setTextureNormal("ui_new/shop/btn_qiyuan1.png")
        self.btn_qiyuan:setTouchEnabled(true)
        Public:addBtnWaterEffect(self.btn_qiyuan, true,1)
    end
end

function QiYuanLayer:removeUI()
    self.super.removeUI(self)
end

function QiYuanLayer:onInitData( data )
    print("onInitData")
    self.roleId = QiYuanManager:getSelectedRoleId()
    if nil ~= QiYuanManager:getSelectedRoleId() then
        self:setData()
    end
    self.isQiYuaning = false
    self:refreshUI()
end

function QiYuanLayer:onRefreshData( data )
    self:setData()
    self:showRewardDay()
    for i = 1,3 do
        self.cardList[i]:getChildByName("img_zhengmian"):setVisible(false)
        self.cardList[i]:getChildByName("img_beimian"):setVisible(true)
    end
    self.bBrushBtn = nil
    self:UpdateCDTime()
    self:showQiYuanShiNum()
    self:PlayAc1()
end

function QiYuanLayer:onDayReward( data )
    self:showRewardDay()
end

function QiYuanLayer:onBuyReward( data )
    self:setData()
end

function QiYuanLayer:registerEvents()
    self.super.registerEvents(self)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
    self.panel_rolelist:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnSelectRoleClick,self)))
    self.btn_genghuan:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnSelectRoleClick,self)))
    self.btn_qiyuan:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnQiYuanClick,self)))
    self.btn_xiangzi:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnGetDayRewardClick,self)))
    self.btn_help:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnRuleClick,self)))
    for i=1,3 do
        local btn = self.cardList[i]:getChildByName("img_zhengmian")
        btn.Idx = i
        btn:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnCardClick,self)))
        btn = self.cardList[i]:getChildByName("img_beimian")
        btn:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(QiYuanLayer.OnQiYuanClick,self)))
    end
    self.onBuyRewardHandler = function(event)
        self:onBuyReward()
    end;

    self.onInitDataHandler = function(event)
        self:onInitData()
    end;

    self.onRefreshDataHandler = function(event)
        self:onRefreshData()
    end;

    self.onDayRewardHandler = function(event)
        self:onDayReward()
    end;
    TFDirector:addMEGlobalListener(QiYuanManager.Buy_Reward ,self.onBuyRewardHandler)
    TFDirector:addMEGlobalListener(QiYuanManager.Init_Data ,self.onInitDataHandler)
    TFDirector:addMEGlobalListener(QiYuanManager.Refresh_Data ,self.onRefreshDataHandler)
    TFDirector:addMEGlobalListener(QiYuanManager.Day_Reward ,self.onDayRewardHandler)
end

function QiYuanLayer:removeEvents()
    TFDirector:removeMEGlobalListener(QiYuanManager.Buy_Reward ,self.onBuyRewardHandler)
    TFDirector:removeMEGlobalListener(QiYuanManager.Init_Data ,self.onInitDataHandler)
    TFDirector:removeMEGlobalListener(QiYuanManager.Refresh_Data ,self.onRefreshDataHandler)
    TFDirector:removeMEGlobalListener(QiYuanManager.Day_Reward ,self.onDayRewardHandler)
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.super.removeEvents(self)
end

function QiYuanLayer:OnGetDayRewardClick( sender )
    local rewardDay, maxDay= QiYuanManager:getDay()
    if rewardDay < maxDay then
        -- local msg = string.format(TFLanguageManager:getString(ErrorCodeData.QIYUAN_NOTENOUGH_DAY),maxDay)
        local msg = stringUtils.format(localizable.QIYUAN_NOTENOUGH_DAY, maxDay)
        toastMessage(msg)
        return
    end
    QiYuanManager:requestGetReward()
    if self.role_list ~= nil then
        self.role_list:clear()
        self.role_list = nil
    end
    
end

function QiYuanLayer:OnCardClick( sender )
    local infos = QiYuanManager:getInfos()
    if infos[sender.Idx].isGetReward > 0 then
        return
    end
    if infos[sender.Idx].roleSycee > 0 then
        local roleConfig = RoleData:objectByID(infos[sender.Idx].roleId)
        local roleName = roleConfig.name
        --local warningMsg = "是否花费"..infos[sender.Idx].roleSycee.."元宝购买"..infos[sender.Idx].roleNum.."个"..roleName.."侠魂？"
        local warningMsg = stringUtils.format(localizable.qiyuanLayer_buy, infos[sender.Idx].roleSycee, infos[sender.Idx].roleNum, roleName)
        
        CommonManager:showOperateSureLayer(
            function()
                QiYuanManager:requestBuyReward(sender.Idx)
            end,
            nil,
            {
                msg = warningMsg
            }
        )
    else
        QiYuanManager:requestBuyReward(sender.Idx)
    end
end

function QiYuanLayer:OnRuleClick( sender )
    CommonManager:showRuleLyaer('qiyuan')
end

function QiYuanLayer:getQiYuanType()
    local nType = 1
    local times = QiYuanManager:getTimes()
    if QiYuanManager:getQiYuanItemNum() > 0 then
        if QiYuanManager:getQiYuanCD() > 0 then
            nType = 2
        else
            if times.maxTimes <= times.curTimes then
                nType = 2
            end
        end
    else
        if times.maxTimes <= times.curTimes then
            nType = 0
        end
    end
    return nType
end

function QiYuanLayer:OnQiYuanClick( sender )
    if self.isQiYuaning == true then
        return
    end
    local requestType = 0
    local nType = self:getQiYuanType()
    if nType == 0 then
        toastMessage(localizable.QIYUAN_NOTENOUGH_COUNT)
        return
    elseif nType == 1 then
        requestType = 1
    elseif nType == 2 then
        requestType = 2
        if QiYuanManager:isAllBought() == false then
            requestType = 3
        end
    end
    if nil == self.roleId then
        --toastMessage("请先选择祈愿的侠客")
        toastMessage(localizable.qiyuanLayer_check)
        return
    end
    self:requestQiYuan(requestType)
end

function QiYuanLayer:requestQiYuan(nType)
    if nType == 1 then
        QiYuanManager:GetFree()
        QiYuanManager:requestQiYuan(self.roleId)
        self.isQiYuaning = true
    elseif nType == 2 then
        QiYuanManager:GetFree()
        QiYuanManager:requestUseItem(self.roleId)
        self.isQiYuaning = true
    elseif nType == 3 then
        --local warningMsg = "当前还有侠魂未购买，是否确定祈愿？"
        local warningMsg = localizable.qiyuanLayer_qiyuan
        CommonManager:showOperateSureLayer(
            function()
                QiYuanManager:GetFree()
                QiYuanManager:requestUseItem(self.roleId)
                self.isQiYuaning = true
            end,
            nil,
            {
                msg = warningMsg
            }
        )
    end
end

function QiYuanLayer.sortFunc( cardRole1, cardRole2 )
    if cardRole1.quality < cardRole2.quality then
        return false
    elseif cardRole1.quality == cardRole2.quality and
           cardRole1:getpower() <= cardRole2:getpower() then
        return false
    end
    return true
end

function QiYuanLayer:getRoleList()
    self.role_list = TFArray:new()
    for card in CardRoleManager.cardRoleList:iterator() do
        if card.quality < 5 and card:getIsMainPlayer() == false then
            self.role_list:pushBack(card)
        end
    end
    self.role_list:sort(self.sortFunc)
end

function QiYuanLayer:OnSelectRoleClick( sender )
    if self.role_list == nil then
        self:getRoleList()
    end
    --[[if QiYuanManager:getQiYuanCD() > 0 then
        return
    end
    local times = QiYuanManager:getTimes()
    if times.maxTimes <= times.curTimes then
        return
    end]]
    --local tipsTxt = "选择侠客，可免费获得该侠客侠魂"
    local tipsTxt = localizable.qiyuanLayer_check_free
    local layer  = require("lua.logic.factionPractice.PracticeRoleSelect2"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK,AlertManager.TWEEN_NONE)
    self.clickCallBack = function (cardRole)
        layer:moveOut()
        self.roleId = cardRole.id
        play_buzhenluoxia()
    end
    layer:initDate(self.role_list,tipsTxt,self.clickCallBack)
    AlertManager:show()
end

function QiYuanLayer:PlayAc1()
    do
        local resPath = "effect/qiyuan_ac1.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("qiyuan_ac1_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()
        end)
        local pos = self.img_huawen:getPosition()
        pos.x = pos.x - 157
        effect:setPosition(pos)
        self.panel_content:removeChildByTag(10086,true);
        for i = 1,3 do
            self.cardList[i]:removeChildByTag(10086,true);
        end
        self.panel_content:addChild(effect,1,10086)
        effect:playByIndex(0, -1, -1, 0)
    end
    for i=1,3 do
        local resPath = "effect/qiyuan_ac2.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("qiyuan_ac2_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)

        effect:addMEListener(TFARMATURE_COMPLETE,function()
            effect:removeMEListener(TFARMATURE_COMPLETE) 
            effect:removeFromParent()
        end)
        local size = self.cardList[i]:getContentSize()
        effect:setPosition(ccp(size.width*0.5,size.height*0.5))
        self.cardList[i]:addChild(effect,1,10086)
        effect:playByIndex(0, -1, -1, 0)
        self.cardList[i]:getChildByName("img_zhengmian"):setVisible(false)
        self.cardList[i]:getChildByName("img_beimian"):setVisible(false)
    end
    local delay = CCDelayTime:create(0.58)
    local callFunc = CCCallFunc:create(handler(QiYuanLayer.ShowResult,self))
    local seq = CCSequence:createWithTwoActions(delay,callFunc)
    self.img_huawen:stopAllActions()
    self.img_huawen:runAction(seq)
end

function QiYuanLayer:ShowResult()
    print("ShowResult")
    for i = 1,3 do
        self.cardList[i]:getChildByName("img_zhengmian"):setVisible(true)
        self.cardList[i]:getChildByName("img_beimian"):setVisible(false)
    end
    self.isQiYuaning = false
end

function QiYuanLayer:roleSelected()
    print("roleSelected")
    local cardRole = CardRoleManager:getRoleById(self.roleId)
    if nil == cardRole then
        self.roleId = nil
        self:defaultShow()
        return
    end
    self.txt_roleName:setText(cardRole.name)
    self.img_quallity:setTexture(GetFontByQuality(cardRole.quality))
    self.img_diwen:setTexture(GetRoleNameBgByQuality(cardRole.quality))
    -- self.img_role:setTexture(cardRole:getBigImagePath())
    -- self.img_role:setVisible(true)
    
    local model = self.panel_role.model
    if model then 
        model:removeFromParent() 
    end
    model = Public:addModel(cardRole.image, self.panel_role, 0, 0, "stand", 1)
    model:setScale(0.75)
    self.panel_role.model = model
    self.img_roleblack:setVisible(false)
    for i=1,5 do
        self.img_starList[i]:setVisible(false)
    end
    for i=1,cardRole.starlevel do
        local starIdx = i
        local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
        if i > 5 then
            starTextrue = 'ui_new/common/xl_dadian23_icon.png'
            starIdx = i - 5
        end
        self.img_starList[starIdx]:setTexture(starTextrue)
        self.img_starList[starIdx]:setVisible(true)
    end
end

function QiYuanLayer:defaultShow()
    --self.txt_roleName:setText("请选择侠客")
    self.txt_roleName:setText(localizable.practiceChooseLayer_check_hero)
    
    self.img_quallity:setTexture(GetFontByQuality(1))
    self.img_diwen:setTexture(GetRoleNameBgByQuality(1))
    -- self.img_role:setVisible(false)
    local model = self.panel_role.model
    if model then 
        model:removeFromParent() 
    end
    self.img_roleblack:setVisible(true)
    for i=1,5 do
        self.img_starList[i]:setVisible(false)
    end 
end
-----断线重连支持方法
function QiYuanLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    QiYuanManager:refreshData()
    self:refreshUI()
end

function QiYuanLayer:showRight()
    print("showRight")
    self.panel_content:removeChildByTag(10086,true);
    for i = 1,3 do
        self.cardList[i]:removeChildByTag(10086,true);
    end
    local bVisible = false
    if nil == QiYuanManager:getSelectedRoleId() then
        bVisible = true
    end
    for i = 1,3 do
        self.cardList[i]:getChildByName("img_zhengmian"):setVisible(not bVisible)
        self.cardList[i]:getChildByName("img_beimian"):setVisible(bVisible)
    end
end

function QiYuanLayer:setData()
    print("setData")
    local infos = QiYuanManager:getInfos()
    for i = 1,3 do
        local nodeZM    = self.cardList[i]:getChildByName("img_zhengmian")
        local img_icon  = nodeZM:getChildByName("img_role")
        local txt_num   = nodeZM:getChildByName("txt_rolenum")
        local img_got   = nodeZM:getChildByName("img_yilingqu")
        local node_cost = nodeZM:getChildByName("img_di")
        local img_pec   = nodeZM:getChildByName("img_pec")
        local img_gold  = node_cost:getChildByName("img_qiyuanshi")
        local txt_cost  = node_cost:getChildByName("txt_num")
        local roleConfig = RoleData:objectByID(infos[i].roleId)
        if nil ~= roleConfig then
            img_icon:setTexture(roleConfig:getIconPath())
            nodeZM:setTexture(GetColorIconByQuality(roleConfig.quality))
            img_pec:setTexture("ui_new/common/icon_bg/s"..roleConfig.quality..".png")
        end
        txt_num:setText(infos[i].roleNum.."")
        if infos[i].isGetReward >=1 then
            img_got:setVisible(true)
        else
            img_got:setVisible(false)
        end
        if infos[i].roleSycee > 0 then
            txt_cost:setText(""..infos[i].roleSycee)
            img_gold:setVisible(true)
        else
            --txt_cost:setText("免费")
            txt_cost:setText(localizable.common_free)
            img_gold:setVisible(false)
        end
    end
end

function QiYuanLayer:showRewardDay()
    local rewardDay, maxDay= QiYuanManager:getDay()
    if rewardDay >= maxDay then
        rewardDay = maxDay
        if self.EscortingEffect == nil then
            local resPath = "effect/escorting.xml"
            TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
            local effect = TFArmature:create("escorting_anim")
            local node   = self.btn_xiangzi
            effect:setAnimationFps(GameConfig.ANIM_FPS)
            node:addChild(effect, 1)
            effect:setPosition(ccp(0, -17))
            effect:setAnchorPoint(ccp(0.5, 0.5))
            effect:setScale(1.2)
            self.EscortingEffect = effect
            self.EscortingEffect:playByIndex(0, -1, -1, 1)
        end
    else
        if self.EscortingEffect ~= nil then
            self.EscortingEffect:removeFromParent()
            self.EscortingEffect = nil
        end
    end
    
    self.txt_days:setText(rewardDay.."/"..maxDay)
end

function QiYuanLayer:showQiYuanShiNum()
    local num = QiYuanManager:getQiYuanItemNum()
    self.txt_qiyuanshi:setText(num.."")
end

function QiYuanLayer:refreshUI()
    print("refreshUI")
    if nil == self.roleId then
        self:defaultShow()
    else
        self:roleSelected()
    end
    if self.isQiYuaning ~= true then
        self:showRight()
        self.bBrushBtn = nil
        self:UpdateCDTime()
        self:showRewardDay()
        self:showQiYuanShiNum()
    end
end

function QiYuanLayer:dispose()
    TFDirector:removeTimer(self.updateTimerID)

    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

return QiYuanLayer
