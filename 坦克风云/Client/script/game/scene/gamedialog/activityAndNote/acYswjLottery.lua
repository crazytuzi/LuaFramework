acYswjLottery={}

function acYswjLottery:new()
	local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.isEnd=false
    nc.freeBtn=nil
    nc.lotteryBtn=nil
    nc.multiLotteryBtn=nil
    nc.lotteryCallBack=nil
    nc.isTodayFlag=true
    nc.actionLayer=nil
    nc.posCfg={
        ccp(83.5,359.5),
        ccp(113.5,218.5),
        ccp(237.5,257.5),
        ccp(313.5,362.5),
        ccp(366.5,215.5),
        ccp(436.5,320.5),
        ccp(561.5,352.5),
        ccp(543.5,211.5)
    }
    nc.stoneSpTb={}
    nc.gathering=false --当前是否在采集
    nc.lightSp=nil
    nc.finalAngle=nil
    nc.isAllGather=false
    nc.url=G_downloadUrl("active/".."yswj_bg.jpg")
	setmetatable(nc, self)
	self.__index=self

	return nc
end

function acYswjLottery:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()

    return self.bgLayer
end

function acYswjLottery:initTableView()
    self.isEnd=acYswjVoApi:isEnd()
    self:initLayer()
end

function acYswjLottery:initLayer()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local function onLoadIcon(fn,icon)
        if self and self.bgLayer then
            icon:setAnchorPoint(ccp(0.5,1))
            self.bgLayer:addChild(icon)
            icon:setPosition(G_VisibleSize.width/2,G_VisibleSizeHeight-160)
            if G_isIphone5() then
                icon:setScaleY(1.24)
            end
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setScaleX((icon:getContentSize().width)/lineSp:getContentSize().width)
            lineSp:setPosition(ccp(icon:getContentSize().width/2,0))
            icon:addChild(lineSp)
        end
    end
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    local blackBg=CCSprite:createWithSpriteFrameName("yswj_blackbg.png")
    blackBg:setAnchorPoint(ccp(0.5,1))
    blackBg:setScaleX((G_VisibleSizeWidth-40)/blackBg:getContentSize().width)
    blackBg:setPosition(G_VisibleSize.width/2,G_VisibleSizeHeight-160)
    self.bgLayer:addChild(blackBg,1)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local panelLineBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168,86,10,10),function (...) end)
    panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
    panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
    self.bgLayer:addChild(panelLineBg,2)

    local strSize=25
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local bgSize=self.bgLayer:getContentSize()
    local strSize2=22
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        strSize2=25
    end
    local timeLb=GetTTFLabel(getlocal("activity_timeLabel"),28)
    timeLb:setAnchorPoint(ccp(0.5,1))
    timeLb:setColor(G_ColorYellowPro)
    timeLb:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-170))
    self.bgLayer:addChild(timeLb,3)

    local timeStrLb=GetTTFLabel(acYswjVoApi:getTimeStr(),25)
    timeStrLb:setAnchorPoint(ccp(0.5,1))
    timeStrLb:setPosition(ccp(G_VisibleSizeWidth/2,timeLb:getPositionY()-timeLb:getContentSize().height))
    self.bgLayer:addChild(timeStrLb,3)
    self.timeLb=timeStrLb
    self:updateAcTime()


    local descLb=getlocal("activity_yswj_desc")
    local desTv,desLabel=G_LabelTableView(CCSizeMake(G_VisibleSizeWidth-70,100),descLb,strSize2,kCCTextAlignmentLeft)
    self.bgLayer:addChild(desTv,3)
    desTv:setPosition(ccp(35,G_VisibleSizeHeight-340))
    desTv:setAnchorPoint(ccp(0,0))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    desTv:setMaxDisToBottomOrTop(100)

    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        --显示活动信息
        self:showInfor()
    end

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-170))
    self.bgLayer:addChild(menuDesc,3)


    local lightPosX=30
    for i=1,3 do
        local pic="yswj_light"..i..".png"
        local lightSp=CCSprite:createWithSpriteFrameName(pic)
        lightSp:setAnchorPoint(ccp(0,0.5))
        lightSp:setPosition(lightPosX,G_VisibleSizeHeight-340)
        self.bgLayer:addChild(lightSp)
        lightPosX=lightPosX+lightSp:getContentSize().width-0.5
    end

    local logPosY=G_VisibleSizeHeight-350
    if G_isIphone5() then
        logPosY=G_VisibleSizeHeight-360
    end
    local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:checkRewardHandler()
    end
    local poolBtn=GetButtonItem("CommonBox.png","CommonBox.png","CommonBox.png",rewardPoolHandler,11,nil,nil)
    poolBtn:setScale(0.5)
    poolBtn:setAnchorPoint(ccp(0,1))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    poolMenu:setPosition(ccp(40,logPosY))
    self.bgLayer:addChild(poolMenu,5)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,1))
    poolBg:setContentSize(CCSizeMake(120,30))
    poolBg:setPosition(ccp(poolBtn:getContentSize().width/2,10))
    poolBg:setScale(1/poolBtn:getScale())
    poolBtn:addChild(poolBg)
    local poolLb=GetTTFLabelWrap(getlocal("award"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolLb:setColor(G_ColorYellowPro)
    poolBg:addChild(poolLb)

    local function logHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:logHandler()
    end
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logHandler,11,nil,nil)
    logBtn:setScale(0.7)
    logBtn:setAnchorPoint(ccp(0,1))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-110,logPosY))
    self.bgLayer:addChild(logMenu,5)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(120,30))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,10))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)

    local cost1,cost2=acYswjVoApi:getGatherCost()
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local todayFlag=acYswjVoApi:isToday()
        if todayFlag==false then
            --重置免费次数
            acYswjVoApi:resetFreeGather()
            self:refreshLotteryBtn()
        end
        local freeFlag=acYswjVoApi:isFreeGather()
        if freeFlag==1 then
            self:lotteryHandler(1)
        else
            self:lotteryHandler(2)
        end
    end
    local freeBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",lotteryHandler,nil,getlocal("daily_lotto_tip_2"),strSize,11)
    freeBtn:setAnchorPoint(ccp(0.5,0))
    local freeMenu=CCMenu:createWithItem(freeBtn)
    freeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    freeMenu:setPosition(ccp(bgSize.width/2-150,30))
    self.bgLayer:addChild(freeMenu)
    self.freeBtn=freeBtn
    local lotteryBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",lotteryHandler,nil,getlocal("yswj_gather"),strSize,11)
    lotteryBtn:setAnchorPoint(ccp(0.5,0))
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(ccp(bgSize.width/2-150,30))
    self.bgLayer:addChild(lotteryMenu)
    self.lotteryBtn=lotteryBtn

    local costNode=CCNode:create()
    costNode:setAnchorPoint(ccp(0.5,0))
    lotteryBtn:addChild(costNode)
    local costLb=GetTTFLabel(tostring(cost1),25)
    costLb:setAnchorPoint(ccp(0,0))
    costLb:setColor(G_ColorYellowPro)
    costNode:addChild(costLb)
    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0))
    costNode:addChild(costSp)
    local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width
    costNode:setContentSize(CCSizeMake(lbWidth,1))
    costLb:setPosition(ccp(0,0))
    costSp:setPosition(ccp(costLb:getContentSize().width,0))
    costNode:setPosition(ccp(lotteryBtn:getContentSize().width/2,lotteryBtn:getContentSize().height))
    local function multiLotteryHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:lotteryHandler(3)
    end
    local multiLotteryBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",multiLotteryHandler,nil,getlocal("yswj_allgather",{10}),strSize,11)
    multiLotteryBtn:setAnchorPoint(ccp(0.5,0))
    local multiLotteryMenu=CCMenu:createWithItem(multiLotteryBtn)
    multiLotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    multiLotteryMenu:setPosition(ccp(G_VisibleSize.width/2+150,30))
    self.bgLayer:addChild(multiLotteryMenu)
    self.multiLotteryBtn=multiLotteryBtn
    local costNode2=CCNode:create()
    costNode2:setAnchorPoint(ccp(0.5,0))
    multiLotteryBtn:addChild(costNode2)
    local multiCostLb=GetTTFLabel(tostring(cost2),25)
    multiCostLb:setAnchorPoint(ccp(0,0))
    multiCostLb:setColor(G_ColorYellowPro)
    costNode2:addChild(multiCostLb)
    local multiCostSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    multiCostSp:setAnchorPoint(ccp(0,0))
    costNode2:addChild(multiCostSp)
    local lbWidth=multiCostLb:getContentSize().width+multiCostSp:getContentSize().width
    costNode2:setContentSize(CCSizeMake(lbWidth,1))
    multiCostLb:setPosition(ccp(0,0))
    multiCostSp:setPosition(ccp(multiCostLb:getContentSize().width,0))
    costNode2:setPosition(ccp(multiLotteryBtn:getContentSize().width/2,multiLotteryBtn:getContentSize().height))

    local function onReset()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.resetBg then
            if self.resetBg:isVisible()==true then
                self:reset()
            end
        end
    end
    if(self.resetBg==nil)then
        local resetLb=GetTTFLabel(getlocal("activity_battleplane_reset"),25)
        local resetSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),onReset)
        resetSp:setTouchPriority(-(self.layerNum-1)*20-4)
        resetSp:setOpacity(0)
        resetSp:setContentSize(CCSizeMake(resetLb:getContentSize().width+20,resetLb:getContentSize().height+10))
        resetLb:setColor(G_ColorGreen)
        resetLb:setPosition(getCenterPoint(resetSp))
        resetSp:addChild(resetLb)
        local underline=CCSprite:createWithSpriteFrameName("white_line.png")
        underline:setColor(G_ColorGreen)
        underline:setScaleX(resetLb:getContentSize().width/underline:getContentSize().width)
        underline:setPosition(resetLb:getPositionX(),resetLb:getPositionY()-resetLb:getContentSize().height/2)
        resetSp:addChild(underline)
        local resetBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
        resetBg:setAnchorPoint(ccp(0.5,1))
        resetBg:setOpacity(80)
        resetBg:setContentSize(CCSizeMake(resetLb:getContentSize().width+60,resetLb:getContentSize().height+20))
        resetBg:setPosition(G_VisibleSize.width/2,G_VisibleSizeHeight-370)
        self.bgLayer:addChild(resetBg,3)
        resetBg:addChild(resetSp)
        resetSp:setPosition(resetBg:getContentSize().width/2,resetBg:getContentSize().height/2+5)
        self.resetBg=resetBg
    end

    local carSp=CCSprite:createWithSpriteFrameName("yswj_car.png")
    self.bgLayer:addChild(carSp,2)
    self.carSp=carSp
    if G_isIphone5() then
        carSp:setPosition(G_VisibleSizeWidth-carSp:getContentSize().width*carSp:getScale()/2-30,G_VisibleSizeHeight-carSp:getContentSize().height*carSp:getScale()/2-490)
    else
        carSp:setScale(0.8)
        carSp:setPosition(G_VisibleSizeWidth-carSp:getContentSize().width*carSp:getScale()/2-30,G_VisibleSizeHeight-carSp:getContentSize().height*carSp:getScale()/2-430)
    end
    self:initStoneLayer()
    self:tick()
    self:refresh()
end

function acYswjLottery:showInfor()
    local title={getlocal("activityDescription"),G_ColorYellowPro}
    textlist={}
    for i=1,4 do
        local params={}
        if i==2 then
            params={acYswjVoApi:getPlayNum()}
        end
        local text={getlocal("activity_yswj_rule"..i,params),nil,nil,nil,20}
        textlist[i]=text
    end
    if textlist then
        require "luascript/script/game/scene/gamedialog/textSmallDialog"
        textSmallDialog:showTextDialog("TankInforPanel.png",CCSizeMake(500,10),CCRect(130,50,1,1),title,textlist,true,true,self.layerNum+1)
    end
end

function acYswjLottery:reset()
    local function realReset()
        local function callback()
            self:refresh()
            self:refreshStoneLayer(true)
        end
        acYswjVoApi:yswjRequest("active.yunshiwajue.getalien",{},callback)
    end
    local resetFlag,state=acYswjVoApi:isReset()
    if resetFlag==false then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),28)
        do return end
    else
        if state==1 then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),realReset,getlocal("dialog_title_prompt"),getlocal("activity_yswj_prompt2"),nil,self.layerNum+1)
            do return end
        end
    end
    realReset()
end

function acYswjLottery:initStoneLayer()
    self:clearStoneLayer() --清除掉陨石
    local stoneList=acYswjVoApi:getStoneList()
    local rewardFlagTb=acYswjVoApi:getRewardFlagTb()
    local info=acYswjVoApi:getStoneInfo() --获取每个陨石的旋转角度和用到的图片类型
    local scaleCfg={0.45,0.75,1,0.9}
    for k,stype in pairs(stoneList) do
        local stoneSp
        if info and info[k] then
            local ptype=tonumber(info[k][1])
            local angle=tonumber(info[k][2])
            local pic="yswj_stone"..ptype..".png"
            if stype==4 then
                pic="yswj_box.png"
            end
            stoneSp=CCSprite:createWithSpriteFrameName(pic)
            if stoneSp then --神秘宝箱不旋转,不区分大小
                if stype~=4 then
                    stoneSp:setRotation(angle)
                end
                stoneSp:setScale(scaleCfg[stype])
            end
        end
        if(stoneSp)then
            if G_isIphone5() then
                stoneSp:setPosition(self.posCfg[k].x,self.posCfg[k].y+60)
            else
                stoneSp:setPosition(self.posCfg[k])
            end
            self.bgLayer:addChild(stoneSp,5)
            self.stoneSpTb[k]=stoneSp
        end
        if(rewardFlagTb[k])then --该位置本轮已经抽到过
            stoneSp:setVisible(false)
        end
    end
end

function acYswjLottery:refreshStoneLayer(resetFlag)
    if resetFlag and resetFlag==true then
        acYswjVoApi:clearRewardFlagTb()
        self:initStoneLayer()
        do return end
    end
    local rewardFlagTb=acYswjVoApi:getRewardFlagTb()
    for k,stoneSp in pairs(self.stoneSpTb) do
        if(rewardFlagTb[k])then --该位置本轮已经抽到过
            stoneSp:setVisible(false)
            self:removeShine(self.bgLayer,k)
        end
    end
end

function acYswjLottery:clearStoneLayer()
    for k,stoneSp in pairs(self.stoneSpTb) do
        stoneSp:removeFromParentAndCleanup(true)
        stoneSp=nil
        self:removeShine(self.bgLayer,k)
    end
    self.stoneSpTb={}
end

function acYswjLottery:lotteryHandler(num)
    local resetFlag,ftype=acYswjVoApi:isReset()
    if resetFlag==true and ftype and ftype==2 and num~=3 then
        local function onConfirm()
            self:reset()
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),onConfirm,getlocal("dialog_title_prompt"),getlocal("yswj_gonext_str"),nil,self.layerNum+1)
        do return end
    end
    local function realLottery(num,cost)
        local function callback(lotteryFlag,lid,rewardlist,detailStr)
            if lotteryFlag==false then
                self:removeForbidLayer()
                do return end
            end
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                local function showRewards()
                    if num==1 or num==2 then
                        G_showRewardTip(rewardlist)
                        self:refreshStoneLayer()
                    else
                        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"                      
                        local titleStr=getlocal("yswj_allgather")
                        local content={}
                        for k,v in pairs(rewardlist) do
                            table.insert(content,{award=v})
                        end
                        local function callback()
                            self:refreshStoneLayer(true)
                        end
                        acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,detailStr,nil,content,true,self.layerNum+1,nil,getlocal("confirm"),callback,nil,nil,nil,true,false)
                    end
                    self.lotteryCallBack=nil
                end
           
                self.lotteryCallBack=showRewards
                local function speedUp(callback)
                    if self.lotteryCallBack then
                        self.lotteryCallBack(callback)
                    end
                end
                self:playeLotteryEffect(num,lid,speedUp)
            end
            self:removeForbidLayer()
            self:refresh()
            self:refreshLotteryBtn()
        end
        acYswjVoApi:yswjRequest("active.yunshiwajue.rand",{rand=num},callback)
        self:addForbidLayer()
    end
    local cost1,cost2=acYswjVoApi:getGatherCost()
    local cost=0
    if cost1 and cost2 then
        if num==2 then
            cost=cost1
        elseif num==3 then
            cost=cost2
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        realLottery(num,cost)
    end
end

function acYswjLottery:checkRewardHandler()
	local content=acYswjVoApi:getRewardPool()
	local title={getlocal("award"),G_ColorYellowPro}
    require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
	acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1)
end

function acYswjLottery:logHandler()
    local function showLog()
        local function showNoLog()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        local loglist=acYswjVoApi:getLogList()
        local count=SizeOfTable(loglist)
        if count==0 then
            showNoLog()
            do return end
        end
        local limit=acYswjVoApi:getLogLimit()
        local function confirmHandler()
        end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
        acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),loglist,false,self.layerNum+1,confirmHandler,false,limit,nil,nil,nil,true)
    end
    local flag=acYswjVoApi:getRequestLogFlag()
    if flag==true then
        showLog()
    else
        acYswjVoApi:yswjRequest("active.yunshiwajue.getlog",nil,showLog)
    end
end

function acYswjLottery:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
        local isEnd=acYswjVoApi:isEnd()
        if isEnd==true then
            if self.lotteryBtn:isVisible()==true then
                self.lotteryBtn:setEnabled(false)
            end
            if self.freeBtn:isVisible()==true then
                self.freeBtn:setEnabled(false)
            end
            self.multiLotteryBtn:setEnabled(false)
            do return end
        end
        local freeFlag=acYswjVoApi:isFreeGather()
        if freeFlag==1 then
            self.lotteryBtn:setVisible(false)
            self.freeBtn:setVisible(true)
            self.multiLotteryBtn:setEnabled(false)
        else
            self.freeBtn:setVisible(false)
            self.lotteryBtn:setVisible(true)
            self.multiLotteryBtn:setEnabled(true)
        end
    end
end

function acYswjLottery:refresh()
    if self.resetBg then
        local resetFlag=acYswjVoApi:isReset()
        if resetFlag==true then
            self.resetBg:setVisible(true)
        else
            self.resetBg:setVisible(false)
        end
    end
end

function acYswjLottery:addForbidLayer(touchCallBack)
    local function touch()
       if touchCallBack then
            touchCallBack()
       end
    end
    if self.forbidLayer==nil then
        self.forbidLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
        self.forbidLayer:setTouchPriority(-(self.layerNum-1)*20-8)
        self.forbidLayer:setContentSize(G_VisibleSize)
        self.forbidLayer:setOpacity(0)
        self.forbidLayer:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(self.forbidLayer,10)
    end
end

function acYswjLottery:updateUI()
    self:refresh()
    self:refreshLotteryBtn()
end

function acYswjLottery:removeForbidLayer()
    if self.forbidLayer then
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer=nil
    end
end

function acYswjLottery:playeLotteryEffect(num,lid,endHandler)
    if self.actionLayer then
        do return end
    end
    local function showRewardsHandler(skipFlag)
        if self.lampSp then
            self.lampSp:stopAllActions()
        end
        if self.lightSp then
            self.lightSp:stopAllActions()
        end
        if self.carSp then
            self.carSp:stopAllActions()
        end
        local function realEnd()
            if endHandler then
                endHandler()
            end
            self:removeLotteryEffect()
            self.gathering=false
        end
        self.isAllGather=false
        self:playGatherAction(lid,realEnd,skipFlag)
    end
    local function speedHandler()
        if self.gathering==false then
            showRewardsHandler(true)
        end
    end
    local actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),speedHandler)
    actionLayer:setTouchPriority(-(self.layerNum-1)*20-9)
    actionLayer:setContentSize(G_VisibleSize)
    actionLayer:setOpacity(0)
    actionLayer:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(actionLayer,10)
    self.actionLayer=actionLayer

    local carPosX=self.carSp:getPositionX()
    local carPosY=self.carSp:getPositionY()

    local clipperSize=CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-535)
    if G_isIphone5() then
        clipperSize=CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-625)
    end
    local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0.5,1))
    clipper:setContentSize(clipperSize)
    clipper:setPosition(ccp(G_VisibleSizeWidth/2,carPosY+80))
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil)
    actionLayer:addChild(clipper,12)
    self.clipper=clipper

    local lampSp=CCNode:create()
    lampSp:setAnchorPoint(ccp(0.5,0.5))
    lampSp:setContentSize(CCSizeMake(1,1))
    local carPos=clipper:convertToNodeSpace(ccp(self.carSp:getPositionX(),self.carSp:getPositionY()))
    if self.carSp:isFlipY()==true then
        lampSp:setPosition(carPos.x+20,clipper:getContentSize().height-60)
    else
        lampSp:setPosition(carPos.x-20,clipper:getContentSize().height-60)
    end
    clipper:addChild(lampSp)
    self.lampSp=lampSp

    local floodPosY=1
    local floodSpTb={}
    local timeTb={}
    for i=1,3 do
        local floodSp=CCSprite:createWithSpriteFrameName("yswj_floodlight"..i..".png")
        floodSp:setAnchorPoint(ccp(0.5,1))
        floodSp:setScaleY(0)
        if i==1 then
            floodSp:setPosition(lampSp:getContentSize().width/2,0)
            lampSp:addChild(floodSp,2)
            self.lightSp=floodSp
        else
            floodPosY=floodPosY-(i-2)*(floodSp:getContentSize().height+9)
            floodSp:setPosition(self.lightSp:getContentSize().width/2,floodPosY)
            self.lightSp:addChild(floodSp)
        end
        floodSpTb[i]=floodSp
        local time=0.2*floodSp:getContentSize().height/200
        timeTb[i]=time
    end
  

    local function gather()
        self.lightSp:stopAllActions()

        local acArr=CCArray:create()
        local acArr2=CCArray:create()

        local ms=150 --每秒100像素
        local rs=80 --每秒旋转60
        local min_r=-80 --最小旋转角度
        local max_r=80 --最大旋转角度
        local carW=self.carSp:getContentSize().width*self.carSp:getScale()
        local posTb={}
        local timeTb={}
        local delaytime=0
        local leftPosX=30+carW/2
        local rightPosX=G_VisibleSizeWidth-carW/2-30
        local offestCfg={100,150,80}
        local maxIdx=3
        local time=0
        local dirFlag=self.carSp:isFlipY()
        for i=1,3 do
            local targetX=math.random(leftPosX,rightPosX)
            local spaceX=math.abs(targetX-carPosX)
            if lid==1001 then --全面采集的特殊处理
                 local function turn(turnFlag)
                        local carPos=clipper:convertToNodeSpace(ccp(self.carSp:getPositionX(),self.carSp:getPositionY()))
                        if turnFlag and turnFlag==true then
                            self.carSp:setRotation(180)
                            if self.carSp:isFlipY()==false then
                                self.carSp:setFlipY(true)
                                self.lampSp:setPosition(carPos.x+20,self.lampSp:getPositionY())
                            end
                        else
                            self.carSp:setRotation(0)
                            self.carSp:setFlipY(false)
                            self.lampSp:setPosition(carPos.x-20,self.lampSp:getPositionY())
                        end
                    end
                local idx=math.random(1,SizeOfTable(offestCfg))
                local offsetX=offestCfg[idx]
                table.remove(offestCfg,idx)
                if dirFlag==false then
                    targetX=carPosX-offsetX
                    if targetX<leftPosX then
                        local ts=(carPosX-leftPosX)/ms
                        local moveTo=CCMoveTo:create(ts,ccp(leftPosX,carPosY))
                        acArr:addObject(moveTo)
                        local function turnCar()
                            turn(true)
                        end
                        local funcCall=CCCallFuncN:create(turnCar)
                        acArr:addObject(funcCall)
                        local moveBy=CCMoveBy:create(ts,ccp(leftPosX-carPosX,0))
                        acArr2:addObject(moveBy)
                        resetPosTb={carPosX,leftPosX}
                        carPosX=leftPosX
                        targetX=leftPosX+leftPosX-targetX
                        dirFlag=true
                    end
                else
                    targetX=carPosX+offsetX
                    if targetX>rightPosX then
                        local ts=(rightPosX-carPosX)/ms
                        local moveTo=CCMoveTo:create(ts,ccp(rightPosX,carPosY))
                        acArr:addObject(moveTo)
                        local function turnCar()
                            turn(false)
                        end
                        local funcCall=CCCallFuncN:create(turnCar)
                        acArr:addObject(funcCall)
                        local moveBy=CCMoveBy:create(ts,ccp(rightPosX-carPosX,0))
                        acArr2:addObject(moveBy)
                        resetPosTb={carPosX,rightPosX}
                        carPosX=rightPosX
                        targetX=rightPosX-(targetX-rightPosX)
                        dirFlag=false
                    end
                end
                spaceX=math.abs(targetX-carPosX)
            end
            time=spaceX/ms
            timeTb[i]=time
            posTb[i]={carPosX,targetX}
            local function turn()
                local carPos=clipper:convertToNodeSpace(ccp(self.carSp:getPositionX(),self.carSp:getPositionY()))

                if posTb[i][2]-posTb[i][1]>0 then
                    self.carSp:setRotation(180)
                    if self.carSp:isFlipY()==false then
                        self.carSp:setFlipY(true)
                        lampSp:setPosition(carPos.x+20,lampSp:getPositionY())
                    end
                else
                    self.carSp:setRotation(0)
                    self.carSp:setFlipY(false)
                    lampSp:setPosition(carPos.x-20,lampSp:getPositionY())
                end
            end
            local turnCall=CCCallFuncN:create(turn)
            acArr:addObject(turnCall)
            local moveTo=CCMoveTo:create(time,ccp(targetX,carPosY))
            acArr:addObject(moveTo)
            local moveBy=CCMoveBy:create(time,ccp(targetX-carPosX,0))
            acArr2:addObject(moveBy)

            carPosX=targetX

            local function callback()
                if i==3 then
                    showRewardsHandler()
                end
            end
            local funcCall=CCCallFuncN:create(callback)
            acArr:addObject(funcCall)

            delaytime=delaytime+time
        end
        local carSeq=CCSequence:create(acArr)
        self.carSp:runAction(carSeq)
        local lampSeq=CCSequence:create(acArr2)
        lampSp:runAction(lampSeq)

        local lightAcArr=CCArray:create()
        local rt=80/rs
        local rac1=CCRotateTo:create(rt,80)
        local rac2=CCRotateTo:create(rt,0)
        local rac3=CCRotateTo:create(rt,-80)
        local rac4=CCRotateTo:create(rt,0)

        lightAcArr:addObject(rac1)
        lightAcArr:addObject(rac2)
        lightAcArr:addObject(rac3)
        lightAcArr:addObject(rac4)
        local lightSeq=CCSequence:create(lightAcArr)
        local repeatForever=CCRepeatForever:create(lightSeq)
        self.lightSp:runAction(repeatForever)
    end
    local delaytime=0
    for i=1,3 do
        local floodSp=floodSpTb[i]
        local outArr=CCArray:create()
        local delay=CCDelayTime:create(delaytime)
        outArr:addObject(delay)
        delaytime=delaytime+timeTb[i]
        local scaleTo=CCScaleTo:create(timeTb[i],1)
        outArr:addObject(scaleTo)
        if i==1 then
            local delay=CCDelayTime:create(timeTb[1]+timeTb[2]+timeTb[3]-0.5)
            outArr:addObject(delay)
            local callFunc=CCCallFuncN:create(gather)
            outArr:addObject(callFunc)
        end
        local seq=CCSequence:create(outArr)
        floodSp:runAction(seq)
    end
end

--skipFlag：是否调过动画
function acYswjLottery:playGatherAction(lid,callback,skipFlag)
    local carPos=self.clipper:convertToNodeSpace(ccp(self.carSp:getPositionX(),self.carSp:getPositionY()))
    if self.lampSp then
        if self.carSp:isFlipY()==true then
            self.lampSp:setPosition(carPos.x+20,self.clipper:getContentSize().height-60)
        else
            self.lampSp:setPosition(carPos.x-20,self.clipper:getContentSize().height-60)
        end
    end
    local function playSlotAction(stoneSp,beginPos,distance,angle,slotCallBack,actionFlag,isAll)
        local slotNode=CCNode:create()
        slotNode:setAnchorPoint(ccp(0.5,1))
        slotNode:setContentSize(CCSizeMake(1,1))
        slotNode:setPosition(beginPos)
        slotNode:setRotation(angle)
        self.clipper:addChild(slotNode,3)

        local spriteBatch=CCSpriteBatchNode:create("public/acyswj_images2.png")
        slotNode:addChild(spriteBatch)
        local slotSpTb={}
        local subH=stoneSp:getContentSize().height*stoneSp:getScale()/2
        local count=math.ceil((distance-subH)/16)
        for i=1,count do
            local sp=CCSprite:createWithSpriteFrameName("yswj_greenline.png")
            sp:setAnchorPoint(ccp(0,0.5))
            sp:setRotation(90)
            sp:setPosition(ccp(slotNode:getContentSize().width/2,0-(i-1)*16))
            if actionFlag and actionFlag==true then
                sp:setVisible(false)
            end
            spriteBatch:addChild(sp)
            slotSpTb[i]=sp
        end
        local slotArr=CCArray:create()
        if actionFlag and actionFlag==true then
            local funcArr=CCArray:create()
            local delaytime=0.8
            if isAll and isAll==true then
                delaytime=0.4
            end
            local delay=CCDelayTime:create(delaytime/count)
            funcArr:addObject(delay)
            local idx=1
            local slotCount=SizeOfTable(slotSpTb)
            local function setLine()
                local slotSp=slotSpTb[idx]
                if slotSp then
                    slotSp:setVisible(true)
                    idx=idx+1
                end
            end
            local slotFunc=CCCallFuncN:create(setLine)
            funcArr:addObject(slotFunc)
            local funcSeq=CCSequence:create(funcArr)
            local repeatAc=CCRepeat:create(funcSeq,count)
            slotArr:addObject(repeatAc)
        end
        local endFunc=CCCallFuncN:create(slotCallBack)
        slotArr:addObject(endFunc)
        local slotSeq=CCSequence:create(slotArr)
        spriteBatch:runAction(slotSeq)
    end
    if lid~=1001 then --单次采集
        local rs=60 --每秒旋转60
        local flag=false
        local stoneSp=self.stoneSpTb[lid]
        if stoneSp then
            local fx,fy=stoneSp:getPosition()
            local finalAngle=self:getFinalAngle(fx,fy)
            if finalAngle then 
                self.lightSp:stopAllActions()
                local shakeArr=CCArray:create()
                if skipFlag and skipFlag==true then
                    self.lightSp:setRotation(finalAngle)
                else
                    local angle=self.lightSp:getRotation()
                    local rt=math.abs(finalAngle-angle)/rs
                    local ac=CCRotateTo:create(rt,finalAngle)
                    shakeArr:addObject(ac)
                end
                local targetPos=self.lampSp:convertToWorldSpaceAR(ccp(0,0))
                local distance=ccpDistance(ccp(fx,fy),ccp(targetPos.x,targetPos.y))+30
                local function playShakeAction()
                    local guangSp1,guangSp2=self:addShine(self.bgLayer,fx,fy,stoneSp:getScale()+0.2,lid)

                    local blinkArr=CCArray:create()
                    local repeatAc=self:addShake(1)
                    blinkArr:addObject(repeatAc)
                    local delay=CCDelayTime:create(0.2)
                    blinkArr:addObject(delay)
                    local function actionEnd()
                        if callback then
                            callback()
                        end
                    end
                    local func=CCCallFuncN:create(actionEnd)
                    blinkArr:addObject(func)
                    local blinkSeq=CCSequence:create(blinkArr)
                    stoneSp:runAction(blinkSeq)
                end
                local function gatherCallBack()
                    self.gathering=true
                    local scaleY=(distance/3)/self.lightSp:getContentSize().height
                    self.lightSp:setScaleY(scaleY)
                    local bx,by=self.lampSp:getPosition()
                    playSlotAction(stoneSp,ccp(bx,by),distance,finalAngle,playShakeAction,true,false)
                end
                local callFunc=CCCallFuncN:create(gatherCallBack)
                shakeArr:addObject(callFunc)
                local seq=CCSequence:create(shakeArr)
                self.lightSp:runAction(seq)
                flag=true
            end
        end
        if flag==false then
           callback()
        end
    else --全面采集
        if skipFlag and skipFlag==true then
            if callback then
                callback()
            end
        else
            local targetPos=self.lampSp:convertToWorldSpaceAR(ccp(0,0))
            local bx,by=self.lampSp:getPosition()
            local count=SizeOfTable(self.stoneSpTb)
            self.lampSp:setVisible(false)
            for k,stoneSp in pairs(self.stoneSpTb) do
                if stoneSp:isVisible()==true then
                    local function playShakeAction()
                        local fx,fy=stoneSp:getPosition()
                        local guangSp1,guangSp2=self:addShine(self.bgLayer,fx,fy,stoneSp:getScale()+0.2,k)

                        local blinkArr=CCArray:create()
                        local repeatAc=self:addShake(1)
                        blinkArr:addObject(repeatAc)
                        local delay=CCDelayTime:create(0.2)
                        blinkArr:addObject(delay)
                        if k==count then
                            local function actionEnd()
                                self.gathering=true
                                if callback then
                                    callback()
                                end
                            end
                            local func=CCCallFuncN:create(actionEnd)
                            blinkArr:addObject(func)
                        end
                        local blinkSeq=CCSequence:create(blinkArr)
                        stoneSp:runAction(blinkSeq)
                    end
                    local fx,fy=stoneSp:getPosition()
                    local finalAngle=self:getFinalAngle(fx,fy)
                    local distance=ccpDistance(ccp(fx,fy),ccp(targetPos.x,targetPos.y))+30
                    playSlotAction(stoneSp,ccp(bx,by),distance,finalAngle,playShakeAction,true,true)
                end
            end
        end
    end
end

function acYswjLottery:addShine(parent,px,py,scale,idx)
    if parent then
        scale=scale or 1
        local guangSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
        guangSp1:setPosition(ccp(px,py))
        parent:addChild(guangSp1,1)
        guangSp1:setTag(1000+idx)
        local guangSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
        guangSp2:setPosition(ccp(px,py))
        parent:addChild(guangSp2,1)
        guangSp2:setTag(10000+idx)
        guangSp1:setScale(scale)
        guangSp2:setScale(scale)
        local rotateBy=CCRotateBy:create(4,360)
        local reverseBy=rotateBy:reverse()
        guangSp1:runAction(CCRepeatForever:create(rotateBy))
        guangSp2:runAction(CCRepeatForever:create(reverseBy))
        return guangSp1,guangSp2
    end
end

function acYswjLottery:removeShine(parent,idx)
    if parent then
        local guangSp1=tolua.cast(parent:getChildByTag(1000+idx),"CCSprite")
        local guangSp2=tolua.cast(parent:getChildByTag(10000+idx),"CCSprite")
        if guangSp1 and guangSp2 then
            guangSp1:removeFromParentAndCleanup(true)
            guangSp2:removeFromParentAndCleanup(true)
        end
    end
end

function acYswjLottery:addShake(num)
    local time=0.1
    local rotate1=CCRotateTo:create(time,60)
    local rotate2=CCRotateTo:create(time,-60)
    local rotate3=CCRotateTo:create(time,30)
    local rotate4=CCRotateTo:create(time,-30)
    local rotate5=CCRotateTo:create(time,0)
    local delay=CCDelayTime:create(0.1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatAc=CCRepeat:create(seq,num)

    return repeatAc
end

function acYswjLottery:removeLotteryEffect()
    if self.actionLayer then
        self.lightSp=nil
        self.finalAngle=nil
        self.gathering=false
        if self.lampSp then
            self.lampSp:stopAllActions()
            self.lampSp=nil
        end
        if self.lightSp then
            self.lightSp:stopAllActions()
            self.lightSp=nil
        end
        if self.carSp then
            self.carSp:stopAllActions()
        end
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer=nil
        self.clipper=nil
    end
end

function acYswjLottery:getFinalAngle(fx,fy)
    local angle
    if self.lampSp then
        local targetPos=self.lampSp:convertToWorldSpaceAR(ccp(0,0))
        local difPos=ccpSub(ccp(fx,fy),ccp(targetPos.x,targetPos.y))
        local angleRadians=ccpToAngle(difPos)
        angle=math.deg(angleRadians)*(-1.0)-90
    end
    return angle
end

function acYswjLottery:fastTick()
end

function acYswjLottery:tick()
    local isEnd=acYswjVoApi:isEnd()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
        if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
            if self.lotteryBtn:isVisible()==true then
                self.lotteryBtn:setEnabled(false)
            end
            if self.freeBtn:isVisible()==true then
                self.freeBtn:setEnabled(false)
            end
            self.multiLotteryBtn:setEnabled(false)
        end
    end
    if isEnd==false then
        local todayFlag=acYswjVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acYswjVoApi:resetFreeGather()
            self:refreshLotteryBtn()
        end
    end
    self:updateAcTime()
end

function acYswjLottery:updateAcTime()
    local acVo=acYswjVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acYswjLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.forbidLayer=nil
    self.isEnd=false
    self.freeBtn=nil
    self.lotteryBtn=nil
    self.multiLotteryBtn=nil
    self.lotteryCallBack=nil
    self.isTodayFlag=true
    self.actionLayer=nil
    self.stoneSpTb={}
    self.gathering=false --当前是否在采集
    self.lightSp=nil
    self.finalAngle=nil
end