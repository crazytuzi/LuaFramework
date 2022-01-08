--[[
******跨服个人战-资格赛排名信息*******

	-- by quanhuan
	-- 2016/2/22
	
]]

local FightMainLayer = class("FightMainLayer",BaseLayer)

function FightMainLayer:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.kuafuwulin.KuaFuMain")
end

function FightMainLayer:initUI( ui )

	self.super.initUI(self, ui)

    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.KFWLDH,{HeadResType.SYCEE})

    local titleNode = TFDirector:getChildByPath(ui,'Panel_Content')
    self.titleFlag = {}
    for i=1,3 do
        self.titleFlag[i] = {}
        self.titleFlag[i].imgTips = TFDirector:getChildByPath(titleNode, 'img_jifen'..i)
        self.titleFlag[i].imgTips:setVisible(false)
        self.titleFlag[i].txtTips = TFDirector:getChildByPath(titleNode, 'txt_tips'..i)
        self.titleFlag[i].txtTips:setVisible(false)
    end

    local cellNode = TFDirector:getChildByPath(ui, 'panel_jifen2')
    self.cellModel = TFDirector:getChildByPath(cellNode, 'img_heidi1')
    self.cellModel:setVisible(false)

    self.txtTime = {}
    for i=1,3 do
        self.txtTime[i] = {}
        self.txtTime[i].txtNode = TFDirector:getChildByPath(cellNode, 'txt_time'..i)
        self.txtTime[i].txtNum = TFDirector:getChildByPath(self.txtTime[i].txtNode, 'txt_num1')
        self.txtTime[i].txtNode:setVisible(false)
    end

    self.myRankNode = TFDirector:getChildByPath(cellNode, 'txt_paiming')
    self.txtMyRank = TFDirector:getChildByPath(self.myRankNode, 'txt_num1')

    self.panel_list = TFDirector:getChildByPath(cellNode, 'panel_kaiqi');
    local pageView = TPageView:create()
    self.pageView = pageView
    pageView:setBounceEnabled(true)
    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    self.pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index);
    end 
    self.pageView:setAddFunc(itemAdd)
    self.panel_list:addChild(pageView);

    self.btn_jinggong = TFDirector:getChildByPath(ui, 'btn_jinggong')
    self.btn_fangshou = TFDirector:getChildByPath(ui, 'btn_fangshou')
    self.btn_kfsd = TFDirector:getChildByPath(ui, 'btn_kfsd')
    self.btn_jiangli = TFDirector:getChildByPath(ui, 'btn_jiangli')
    self.btn_guizhe = TFDirector:getChildByPath(ui, 'btn_guizhe')

    self.btn_left = TFDirector:getChildByPath(ui, "btn_left")
    self.btn_right = TFDirector:getChildByPath(ui, "btn_right")
    self.btn_buy = TFDirector:getChildByPath(ui, "btn_sycs")
end

function FightMainLayer:removeUI()
	self.super.removeUI(self)
end

function FightMainLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function FightMainLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_jinggong:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onAtkBtnClick))
    self.btn_fangshou:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onDefBtnClick))
    self.btn_kfsd:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShopBtnClick))
    self.btn_jiangli:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRewardBtnClick))
    self.btn_guizhe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRuleBtnClick))
    self.btn_left:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onLeftBtnClick))
    self.btn_left.logic = self
    self.btn_right:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onRightBtnClick))
    self.btn_right.logic = self
    self.btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBuyQualificationClick))
    self.btn_buy.logic = self
    self.registerEventCallFlag = true 

    self.buyQualificationCallBack = function ()
        MultiServerFightManager:requestQualificationInfos(nil,true)
    end
    TFDirector:addMEGlobalListener(MultiServerFightManager.buyQualification, self.buyQualificationCallBack)

    self.qualificationInfoBrushCallBack = function ()
        self.rankDataInfo = MultiServerFightManager:getRankInfosByState( self.currStateType )
        self:showBuyBtn(false)
        local pageIndex = self.pageView:_getCurPageIndex()
        self:showPage(pageIndex)
        local myRank = 0
        if self.currStateType == MultiServerFightManager.ActivityState_1 then    
            myRank = self.rankDataInfo.myRank
        else        
            if self.rankDataInfo.ranks then
                for k,v in pairs(self.rankDataInfo.ranks) do 
                    if v.playerId == MainPlayer:getPlayerId() then
                        myRank = k
                        break
                    end
                end
            end
        end
        self:showMyInfo(myRank)
        self:showCutDownTimer()    

        
        toastMessage(localizable.FightMainLayer_BuyQualification_txt3)
    end
    TFDirector:addMEGlobalListener(MultiServerFightManager.qualificationInfoBrush, self.qualificationInfoBrushCallBack) 
end

function FightMainLayer:removeEvents()

    self.super.removeEvents(self)

	if self.generalHead then
        self.generalHead:removeEvents()
    end	

    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end

    self.registerEventCallFlag = nil

    TFDirector:removeMEGlobalListener(MultiServerFightManager.qualificationInfoBrush, self.qualificationInfoBrushCallBack) 
    TFDirector:removeMEGlobalListener(MultiServerFightManager.buyQualification, self.buyQualificationCallBack) 
end

function FightMainLayer:dispose()
	self.super.dispose(self)
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end    
end

function FightMainLayer:setData(stateType)
    self.currStateType = stateType

    self.btn_left:setVisible(false)
    self.btn_right:setVisible(false)

    self.rankDataInfo = MultiServerFightManager:getRankInfosByState( self.currStateType )
    print('self.rankDataInfo = ',self.rankDataInfo)
    
    local myRank = 0
    if self.currStateType == MultiServerFightManager.ActivityState_1 then    
        myRank = self.rankDataInfo.myRank
    else        
        if self.rankDataInfo.ranks then
            for k,v in pairs(self.rankDataInfo.ranks) do 
                if v.playerId == MainPlayer:getPlayerId() then
                    myRank = k
                    break
                end
            end
        end
    end
    self:showMyInfo(myRank)
    self:showCutDownTimer()        
    self:showPage(1)
    self:showBuyBtn()
end

function FightMainLayer:showBuyBtn(isShow)
    if isShow == nil then
        if self.currStateType ~= MultiServerFightManager.ActivityState_1 then
            isShow = false
        else
            isShow = true
            for k,v in pairs(self.rankDataInfo.rankInfos) do 
                if v.playerId == MainPlayer:getPlayerId() then
                    isShow = false
                    break
                end
            end
        end
    end
    self.btn_buy:setVisible(isShow)
end

function FightMainLayer:showPage(pageIndex)
    self.pageView:_removeAllPages();

    local len
    if self.currStateType == MultiServerFightManager.ActivityState_1 then
        if self.rankDataInfo.rankInfos == nil then
            self.rankDataInfo.rankInfos = {}
        end
        len = #self.rankDataInfo.rankInfos
    else
        len = #self.rankDataInfo.ranks
    end
    if math.ceil(len/8) <= 1 then
        len = math.ceil(len/8)
        self.pageView:setTouchEnabled(false)
    else
        self.pageView:setTouchEnabled(true)
        len = math.ceil(len/8)
    end

    self.pageCount = len
    self.pageView:setMaxLength(len)

    self:showInfoForPage(pageIndex);

    self.pageView:InitIndex(pageIndex);      
end

function FightMainLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex()
    self:showInfoForPage(pageIndex);
end

function FightMainLayer:addPage(pageIndex) 
    local page = TFPanel:create();
    page:setSize(self.panel_list:getContentSize())
    local currPos = nil
    for i=1,8 do    
        local rank = (pageIndex-1)*8 + i   
        local data  
        if self.currStateType == MultiServerFightManager.ActivityState_1 then
            data = self.rankDataInfo.rankInfos[rank]
        else
            data = self.rankDataInfo.ranks[rank]
        end
        if data then
            local node = self.cellModel:clone()
            node:setVisible(true)
            local size = node:getContentSize()
            
            if currPos then
                node:setPosition(ccp(currPos.x, currPos.y-size.height-1))        
            end
            currPos = nil
            currPos = node:getPosition()
            page:addChild(node)

            local imgRank = TFDirector:getChildByPath(node, 'img_paiming')
            local txtRank = TFDirector:getChildByPath(node, 'txt_shunxu')
            if rank <= 3 then
                imgRank:setVisible(true)
                imgRank:setTexture('ui_new/leaderboard/no'..rank..'.png')
                txtRank:setVisible(false)
            else
                imgRank:setVisible(false)
                txtRank:setVisible(true)
                txtRank:setText(rank)
            end

            local txtName = TFDirector:getChildByPath(node, 'txt_name')
            txtName:setText(data.name)

            local txtPower = TFDirector:getChildByPath(node, 'txt_zhanli1')
            txtPower:setText(data.power)

            local txtGuild = TFDirector:getChildByPath(node, 'txt_bangpai1')
            local txtGuildName = TFDirector:getChildByPath(node, 'txt_bangpai')
            local txtServer = TFDirector:getChildByPath(node, 'txt_server')

            if self.currStateType == MultiServerFightManager.ActivityState_1 then
                txtGuildName:setVisible(true)
                if data.guildName then
                    txtGuild:setVisible(true)
                    txtGuild:setText(data.guildName)
                else
                    txtGuild:setVisible(false)
                end
                txtServer:setVisible(false)                
            else
                txtGuildName:setVisible(false)
                txtServer:setVisible(true)   
                txtServer:setText(data.serverName)
            end
        end
    end  
    return page;
end

function FightMainLayer:showInfoForPage(pageIndex)
    self.selectIndex = pageIndex;
    self.btn_left:setVisible(false)
    self.btn_right:setVisible(false)
    
    if pageIndex < self.pageCount and self.pageCount > 1 then
        self.btn_right:setVisible(true)
    end 

    if pageIndex > 1 and self.pageCount > 1  then
        self.btn_left:setVisible(true)
    end
end

function FightMainLayer:showCutDownTimer()
    if self.countDownTimer then
        TFDirector:removeTimer(self.countDownTimer)
        self.countDownTimer = nil
    end
    local timeInfo = MultiServerFightManager:getFightTimeByState( self.currStateType )
    local currTime = MultiServerFightManager:getCurrSecond()

    local stateIndex = math.ceil(self.currStateType/2)
    self.titleFlag[stateIndex].imgTips:setVisible(true)
    self.titleFlag[stateIndex].txtTips:setVisible(true)
    local timeNode = self.txtTime[stateIndex]
    if timeNode == nil then
        print('cannot find the timeNode stateType = ', self.currStateType)
        return
    end

    if self.currStateType == MultiServerFightManager.ActivityState_5 then
        local countDown = MultiServerFightManager:getSwitchLayerTime()
        countDown = countDown - currTime
        if countDown < 0 then
            countDown = 0
        end
        timeNode.txtNode:setVisible(true)
        timeNode.txtNum:setText(FactionFightManager:getTimeString( countDown ))
        self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
            if countDown <= 0 then
                if self.countDownTimer then
                    TFDirector:removeTimer(self.countDownTimer)
                    self.countDownTimer = nil
                end
                MultiServerFightManager:openCurrLayer()
            else
                countDown = countDown - 1
                print('countDown = ',countDown)
                -- switchTime = switchTime - 1
                timeNode.txtNum:setText(FactionFightManager:getTimeString( countDown ))
            end
        end)
        return
    end

    
    local countDown = timeInfo.fightTime - currTime
    local switchTime = timeInfo.preFightTime - currTime

    
    timeNode.txtNode:setVisible(true)
    timeNode.txtNum:setText(FactionFightManager:getTimeString( countDown ))

    self.countDownTimer = TFDirector:addTimer(1000, -1, nil, function ()
        if countDown <= 0 then
            if self.countDownTimer then
                TFDirector:removeTimer(self.countDownTimer)
                self.countDownTimer = nil
            end
            -- MultiServerFightManager:openCurrLayer()
        else
            countDown = countDown - 1
            switchTime = switchTime - 1
            timeNode.txtNum:setText(FactionFightManager:getTimeString( countDown ))
        end
    end)
end

function FightMainLayer:showMyInfo(rank)
    if rank == 0 then
        self.txtMyRank:setText(localizable.multiFight_noRank)
    else
        self.txtMyRank:setText(rank)
    end
end

function FightMainLayer.onAtkBtnClick(btn)
   MultiServerFightManager:btnAtkClick()
end
function FightMainLayer.onDefBtnClick(btn)
   MultiServerFightManager:btnDefClick()
end
function FightMainLayer.onShopBtnClick(btn)
   MallManager:openMallLayerByType(EnumMallType.HonorMall,1)
end
function FightMainLayer.onRewardBtnClick(btn)
   MultiServerFightManager:openRewardLayer()
end
function FightMainLayer.onRuleBtnClick(btn)
   MultiServerFightManager:openRuleLayer()
end

function FightMainLayer.onLeftBtnClick( btn )
    local self = btn.logic;
    local pageIndex = self.pageView:getCurPageIndex();
    self.pageView:scrollToPage(pageIndex - 1);
end

function FightMainLayer.onRightBtnClick( btn )
    local self = btn.logic;
    local pageIndex = self.pageView:getCurPageIndex();
    self.pageView:scrollToPage(pageIndex + 1);
end

function FightMainLayer.onBuyQualificationClick( btn )
    local self = btn.logic;
    local curNum = #(self.rankDataInfo.rankInfos or {})
    if curNum >= 8+24 then
        toastMessage(localizable.FightMainLayer_BuyQualification_txt1)
        return
    end
    local num = BagManager:getItemNumById(30121)
    if num <= 0 then
        local dataConfig = ItemData:objectByID(30121)
        local itemName = dataConfig.name
        toastMessage(stringUtils.format(localizable.Common_good_buzu,itemName))
        return
    end
    local warningMsg = localizable.FightMainLayer_BuyQualification_txt2
        
    CommonManager:showOperateSureLayer(
        function()
            MultiServerFightManager:requestBuyQualification()
        end,
        nil,
        {
            msg = warningMsg
        }
    )
    
end
return FightMainLayer