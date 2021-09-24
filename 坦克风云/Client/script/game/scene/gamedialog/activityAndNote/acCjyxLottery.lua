acCjyxLottery={}

function acCjyxLottery:new()
	local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.showList={}
    nc.cellNum=0
    nc.cellHeight=110
    nc.isEnd=false
    nc.freeBtn=nil
    nc.lotteryBtn=nil
    nc.multiLotteryBtn=nil
    nc.lotteryCallBack=nil
    nc.propSize=70
    nc.isTodayFlag=true
    nc.actionLayer=nil
    nc.mustModeFlag=false
    nc.url=G_downloadUrl("active/".."cjyx/".."cjyx_bg.jpg")
    nc.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        nc.adaH = 50
    end
	setmetatable(nc, self)
	self.__index=self
	return nc
end

function acCjyxLottery:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.mustModeFlag=acCjyxVoApi:getMustMode()

    self:initTableView()

    return self.bgLayer
end

function acCjyxLottery:initTableView()
    self.showList=acCjyxVoApi:getLotteryReward(4)
    self.cellNum=SizeOfTable(self.showList)
    self.isEnd=acCjyxVoApi:acIsStop()
    if G_isIphone5()==true then
        self.propSize=100
    end
    self:initLayer()
end

function acCjyxLottery:initLayer()
    local strSize=25
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local strSize2 = 22
    local strSize3 = 20
    local strSize4 = 25
    local strSize5 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 25
        strSize3 = 25
        strSize4 = 30
        strSize5 = 25
    end
    local bgSize=self.bgLayer:getContentSize()
    local h=G_VisibleSizeHeight-160-150
    local showH=130
    local showAddH=0
    local offsetH=0
    if G_isIphone5()==true then
        showH=160
        offsetH=40
        showAddH=-20
    end
    local function nilFunc()
    end
    local showbg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),nilFunc)
    showbg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,showH))
    showbg:setAnchorPoint(ccp(0.5,1))
    showbg:setPosition(ccp(bgSize.width/2,h))
    self.bgLayer:addChild(showbg,2)
    local showbgSize=showbg:getContentSize()
    local titleBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    titleBg:setAnchorPoint(ccp(0.5,1))
    titleBg:setScaleX(showbgSize.width/titleBg:getContentSize().width)
    titleBg:setScaleY(40/titleBg:getContentSize().height)
    titleBg:setPosition(ccp(showbgSize.width/2,showbgSize.height))
    showbg:addChild(titleBg)
    local showLb=GetTTFLabelWrap(getlocal("cjyx_reward_show"),28,CCSize(showbgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    showLb:setPosition(ccp(showbgSize.width/2,showbgSize.height-20))
    showbg:addChild(showLb)
    self.cellHeight=showbg:getContentSize().height-titleBg:getContentSize().height*titleBg:getScaleY()

    if self.mustModeFlag==false then

        local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
        lightSp:setAnchorPoint(ccp(0.5,0))
        lightSp:setPosition(G_VisibleSizeWidth/2,h-showH-50-self.adaH)
        self.bgLayer:addChild(lightSp)

        local caidaiSp=CCSprite:createWithSpriteFrameName("anniversaryRibbon.png")
        caidaiSp:setAnchorPoint(ccp(0.5,1))
        caidaiSp:setScaleX(0.8)
        caidaiSp:setPosition(G_VisibleSizeWidth/2,h-showH-10-self.adaH)
        self.bgLayer:addChild(caidaiSp)

        local subTitleLb=GetTTFLabelWrap(getlocal("activity_cjyx_name"),strSize4,CCSize(220,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        subTitleLb:setAnchorPoint(ccp(0.5,1))
        subTitleLb:setPosition(ccp(G_VisibleSizeWidth/2,h-showH-20-self.adaH))
        subTitleLb:setColor(G_ColorYellowPro)
        self.bgLayer:addChild(subTitleLb)

        if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
        else
            local dlongPos={180,G_VisibleSizeWidth-180}
            for i=1,2 do
                local dlongSp=CCSprite:createWithSpriteFrameName("cjyx_dlong.png")
                dlongSp:setAnchorPoint(ccp(0.5,1))
                dlongSp:setPosition(ccp(dlongPos[i],h-showH-10-self.adaH))
                self.bgLayer:addChild(dlongSp)
            end
        end
    end

    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(showbg:getContentSize().width-80,self.cellHeight),nil)
    self.tv:setPosition(ccp(40,0))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    showbg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

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
    logBtn:setScale(0.8)
    logBtn:setAnchorPoint(ccp(0,1))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(40,h-showH-10))
    self.bgLayer:addChild(logMenu)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,1))
    logBg:setContentSize(CCSizeMake(logBtn:getContentSize().width+10,40))
    logBg:setPosition(ccp(logBtn:getContentSize().width/2,0))
    logBg:setScale(1/logBtn:getScale())
    logBtn:addChild(logBg)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)

    local pointStr=getlocal("cjyx_point_str").."："..acCjyxVoApi:getMyPoint()
    local pointLb=GetTTFLabelWrap(pointStr,strSize2,CCSize(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
    local tempLb=GetTTFLabel(pointStr,25)
    local lbW=tempLb:getContentSize().width
    if lbW>pointLb:getContentSize().width then
        lbW=pointLb:getContentSize().width
    end
    local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    pointBg:setAnchorPoint(ccp(1,1))
    pointBg:setContentSize(CCSizeMake(lbW+20,pointLb:getContentSize().height))
    pointBg:setPosition(ccp(G_VisibleSizeWidth-20,h-showH-10))
    self.bgLayer:addChild(pointBg)
    pointLb:setAnchorPoint(ccp(1,1))
    pointLb:setPosition(G_VisibleSizeWidth-30,h-showH-10)
    pointLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(pointLb)
    self.pointLb=pointLb

    local btnZorder=2
    local btnStr=""
    local multiBtnStr=""

    if self.mustModeFlag==true then
        btnStr=getlocal("buy")
        multiBtnStr=getlocal("buy")
    else
        btnStr=getlocal("cjyx_lottery")
        multiBtnStr=getlocal("cjyx_multilottery",{10})
    end
    local cost1,cost2=acCjyxVoApi:getLotteryCost()
    local function lotteryHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:lotteryHandler(1)
    end
    local freeBtnScale,lotteryBtnScale=1,1
    local freeBtnImage1,freeBtnImage2,freeBtnImage3="BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
    local lotteryBtnImage1,lotteryBtnImage2,lotteryBtnImage3="BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png"
    if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
        freeBtnScale,lotteryBtnScale=0.8,0.8
        freeBtnImage1,freeBtnImage2,freeBtnImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
        lotteryBtnImage1,lotteryBtnImage2,lotteryBtnImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    end
    local freeBtn=GetButtonItem(freeBtnImage1,freeBtnImage2,freeBtnImage3,lotteryHandler,nil,getlocal("daily_lotto_tip_2"),strSize/freeBtnScale,11)
    freeBtn:setAnchorPoint(ccp(0.5,0))
    freeBtn:setScale(freeBtnScale)
    local freeMenu=CCMenu:createWithItem(freeBtn)
    freeMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    freeMenu:setPosition(ccp(bgSize.width/2-150,30+self.adaH/5*3))
    self.bgLayer:addChild(freeMenu,btnZorder)
    self.freeBtn=freeBtn
    local lotteryBtn=GetButtonItem(lotteryBtnImage1,lotteryBtnImage2,lotteryBtnImage3,lotteryHandler,nil,btnStr,strSize/lotteryBtnScale,11)
    lotteryBtn:setAnchorPoint(ccp(0.5,0))
    lotteryBtn:setScale(lotteryBtnScale)
    local lotteryMenu=CCMenu:createWithItem(lotteryBtn)
    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    lotteryMenu:setPosition(ccp(bgSize.width/2-150,30+self.adaH/5*3))
    self.bgLayer:addChild(lotteryMenu,btnZorder)
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
        self:lotteryHandler(10)
    end
    local btnScale=1
    local btnImage1,btnImage2,btnImage3="BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png"
    if acCjyxVoApi:getAcShowType()==acCjyxVoApi.acShowType.TYPE_2 then
        btnScale=0.8
        btnImage1,btnImage2,btnImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
    end
    local multiLotteryBtn=GetButtonItem(btnImage1,btnImage2,btnImage3,multiLotteryHandler,nil,multiBtnStr,strSize5/btnScale,11)
    multiLotteryBtn:setAnchorPoint(ccp(0.5,0))
    multiLotteryBtn:setScale(btnScale)
    local multiLotteryMenu=CCMenu:createWithItem(multiLotteryBtn)
    multiLotteryMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    multiLotteryMenu:setPosition(ccp(G_VisibleSize.width/2+150,30+self.adaH/5*3))
    self.bgLayer:addChild(multiLotteryMenu,btnZorder)
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

    if self.mustModeFlag==true then
        local lotteryBgH=210
        local iconSize=80
        local wzSize=22
        local desTvH=55
        if G_isIphone5() then
            lotteryBgH=270
            -- iconSize=100
            wzSize=23
            desTvH=70
        end
        local function nilfunc()
        end
        local lotteryBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),nilfunc)
        lotteryBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,lotteryBgH))
        lotteryBg:setAnchorPoint(ccp(0.5,0))
        lotteryBg:setPosition(G_VisibleSizeWidth/2,30)
        self.bgLayer:addChild(lotteryBg)
        local bgSize=lotteryBg:getContentSize()
        local idx=2
        local mustRewardCfg=acCjyxVoApi:getMustReward()
        for i=1,2 do
            local reward=mustRewardCfg[i]
            if reward then
                local icon,iconScale=G_getItemIcon(reward,iconSize,true,self.layerNum+1)
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(10,lotteryBgH*0.25+(idx-1)*lotteryBgH*0.5)
                lotteryBg:addChild(icon)

                local num=GetTTFLabel("x"..FormatNumber(reward.num),20/iconScale)
                num:setAnchorPoint(ccp(1,0))
                num:setPosition(icon:getContentSize().width-10,10)
                icon:addChild(num)

                G_addRectFlicker(icon,1.3,1.3,ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))

                local nameLb=GetTTFLabelWrap(reward.name.."x"..FormatNumber(reward.num),wzSize,CCSize(bgSize.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
                nameLb:setAnchorPoint(ccp(0,0))
                nameLb:setColor(G_ColorGreen)
                nameLb:setPosition(icon:getPositionX()+iconSize+10,icon:getPositionY()+15)
                lotteryBg:addChild(nameLb)

                -- local descLb=GetTTFLabelWrap(getlocal("cjyx_buy_desc"..i,{reward.name.."x"..FormatNumber(reward.num)}),wzSize,CCSize(bgSize.width-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                -- descLb:setAnchorPoint(ccp(0,1))
                -- descLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-5)
                -- lotteryBg:addChild(descLb)

                local desTv,desLabel=G_LabelTableView(CCSizeMake(bgSize.width-240,desTvH),getlocal("cjyx_buy_desc"..i),wzSize,kCCTextAlignmentLeft)
                lotteryBg:addChild(desTv)
                desTv:setPosition(ccp(nameLb:getPositionX(),nameLb:getPositionY()-desTvH-5))
                desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
                desTv:setMaxDisToBottomOrTop(100)

                idx=idx-1
            end
        end
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setPosition(getCenterPoint(lotteryBg))
        lotteryBg:addChild(lineSp)

        local proStr=getlocal("cjyx_rpool_pro")
        local promptLb=GetTTFLabelWrap(proStr,21,CCSize(250,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local tempLb=GetTTFLabel(proStr,25)
        local lbW=tempLb:getContentSize().width
        if lbW>promptLb:getContentSize().width then
            lbW=promptLb:getContentSize().width
        end
        local promptBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
        promptBg:setAnchorPoint(ccp(1,0))
        promptBg:setContentSize(CCSizeMake(lbW+20,promptLb:getContentSize().height))
        promptBg:setPosition(ccp(G_VisibleSizeWidth-20,lotteryBgH+40))
        self.bgLayer:addChild(promptBg)
        promptLb:setPosition(getCenterPoint(promptBg))
        promptBg:addChild(promptLb)

        local btnScale=0.8
        freeBtn:setScale(btnScale)
        lotteryBtn:setScale(btnScale)
        multiLotteryBtn:setScale(btnScale)
        freeMenu:setPosition(G_VisibleSizeWidth-100,28+lotteryBgH*0.75-freeBtn:getContentSize().height/2)
        lotteryMenu:setPosition(G_VisibleSizeWidth-100,28+lotteryBgH*0.75-lotteryBtn:getContentSize().height/2)
        multiLotteryMenu:setPosition(G_VisibleSizeWidth-100,28+lotteryBgH*0.25-multiLotteryBtn:getContentSize().height/2)
    end

    local firstPosX=(G_VisibleSizeWidth-4*100-3*30)/2
    local fwPos={{G_VisibleSizeWidth/2,360},{120,280},{G_VisibleSizeWidth/2,200},{G_VisibleSizeWidth-120,300}}
    self.fwSpTb={}
    local offsetY=0
    if G_getIphoneType() == G_iphoneX then
        offsetY = 140
    elseif G_isIphone5()==true then
        offsetY=80
    end
    local iconScale=1
    local posAddCfg=nil
    if self.mustModeFlag==true then
        iconScale=0.8
        if G_isIphone5() then
            posAddCfg={{0,140},{20,140},{0,150},{-20,140}}
        else
            posAddCfg={{0,100},{20,100},{0,110},{-20,100}}
        end
    end
    for i=1,4 do
        local pic="fireworks"..i..".png"
        local bgpic="fireworksBg"..i..".png"
        local function callback()
            local rewardlist=acCjyxVoApi:getLotteryReward(i)
            if rewardlist then
                local name=acCjyxVoApi:getFirecrackersName(i)
                local desStr=name..getlocal("super_weapon_challenge_reward_preview")
                acCjyxVoApi:showSmallDialog(true,true,self.layerNum+1,desStr,"TankInforPanel.png",CCSizeMake(500,570),CCRect(130, 50, 1, 1),rewardlist)
            end
        end
        local addX=0
        local addY=0
        if posAddCfg then
            addX=posAddCfg[i][1]
            addY=posAddCfg[i][2]
        end
        local icon=LuaCCSprite:createWithSpriteFrameName(pic,callback)
        icon:setTouchPriority(-(self.layerNum-1)*20-5)
        icon:setPosition(fwPos[i][1]+addX,fwPos[i][2]+offsetY+addY)
        icon:setScale(iconScale)
        self.bgLayer:addChild(icon,2)
        local nameStr=acCjyxVoApi:getFirecrackersName(i)
        local nameLb=GetTTFLabelWrap(nameStr,strSize3,CCSize(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(icon:getContentSize().width/2,-5)
        icon:addChild(nameLb)

        local iconBg=CCSprite:createWithSpriteFrameName(bgpic)
        iconBg:setPosition(fwPos[i][1]+addX,fwPos[i][2]+offsetY+addY)
        iconBg:setScale(iconScale)
        self.bgLayer:addChild(iconBg)

        self.fwSpTb[i]=icon
    end
    self:tick()
end

function acCjyxLottery:eventHandler(handler,fn,idx,cel)
     if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.cellNum*self.propSize+(self.cellNum-1)*10+20,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local iconSize=self.propSize
        local flickScale=1.3
        for k,v in pairs(self.showList) do
            local icon,iconScale=G_getItemIcon(v,iconSize,true,self.layerNum,nil,self.tv)
            icon:setTouchPriority(-(self.layerNum-1)*20-4)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(10+(k-1)*(iconSize+10),self.cellHeight/2)
            cell:addChild(icon)

            local num=GetTTFLabel("x"..FormatNumber(v.num),20/iconScale)
            num:setAnchorPoint(ccp(1,0))
            num:setPosition(icon:getContentSize().width-10,10)
            icon:addChild(num)

            G_addRectFlicker(icon,flickScale,flickScale,ccp(icon:getContentSize().width/2,icon:getContentSize().height/2))
        end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
        
    end
end

function acCjyxLottery:lotteryHandler(num)
    local function realLottery(num,cost)
        local function callback(lotteryFlag,rewardlist,detailStr,noticeR,lottery,score)
            if lotteryFlag==false then
                self:removeForbidLayer()
                do return end
            end
            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then
                if noticeR then
                    acCjyxVoApi:sendCjyxNotice({ntype=1,ltype=4,rewardlist=noticeR,num=num})
                end
                local function showRewards(callback)
                    if self.mustModeFlag==true then
                        local mustRewardCfg=acCjyxVoApi:getMustReward()
                        local mustReward
                        if num==1 then
                            mustReward=mustRewardCfg[1]
                        else
                            mustReward=mustRewardCfg[2]
                        end
                        local contentTb={}
                        contentTb[1]={mustReward} or {}
                        contentTb[2]=rewardlist
                        local tipStrTb={{getlocal("cjyx_rpool_fixReward")},{getlocal("activity_mineExploreG_otherReward")}}
                        local titleStr=getlocal("cjyx_buy",{mustReward.name.."x"..FormatNumber(mustReward.num)})
                        local addStr=getlocal("cjyx_point_str").."："..score
                        require "luascript/script/game/scene/gamedialog/activityAndNote/acMineExploreSmallDialog"    
                        local dialog=acMineExploreSmallDialog:new()
                        dialog:init("PanelHeaderPopup.png",CCSizeMake(550,560),CCRect(168,86,10,10),titleStr,contentTb,tipStrTb,false,true,self.layerNum+1,callback,addStr)
                    else
                        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"                      
                        local titleStr=getlocal("cjyx_multilottery",{num})
                        local content={}
                        for k,v in pairs(rewardlist) do
                            table.insert(content,{award=v})              
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
                self:playeLotteryEffect(num,lottery,speedUp,rewardlist)
            end
            self:removeForbidLayer()
            self:refresh()
            self:refreshLotteryBtn()
        end
        local freeFlag=acCjyxVoApi:isFreeLottery()
        acCjyxVoApi:cjyxAcRequest("active.cjyx",{free=freeFlag,num=num},callback)
        self:addForbidLayer()
    end
    local cost1,cost2=acCjyxVoApi:getLotteryCost()
    local cost=0
    local freeFlag=acCjyxVoApi:isFreeLottery()
    if cost1 and cost2 then
        if num==1 and freeFlag==0 then
            cost=cost1
        elseif num==10 then
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

function acCjyxLottery:logHandler()
    local function showLog()
        local function showNoLog()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        local loglist=acCjyxVoApi:getLogList()
        local count=SizeOfTable(loglist)
        if count==0 then
            showNoLog()
            do return end
        end
        local limit=acCjyxVoApi:getLogLimit()
        local title={getlocal("activity_customLottery_RewardRecode")}
        local function confirmHandler()
        end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
        acCjyxSmallDialog:showLogDialog("PanelHeaderPopup.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(168,86,10,10),title,loglist,false,self.layerNum+1,confirmHandler,true,recordNum,true)
    end
    local flag=acCjyxVoApi:getRequestLogFlag()
    if flag==true then
        showLog()
    else
        acCjyxVoApi:cjyxAcRequest("active.cjyx.report",nil,showLog)
    end
end

function acCjyxLottery:refreshLotteryBtn()
    if self.freeBtn and self.lotteryBtn and self.multiLotteryBtn then
        local isEnd=acCjyxVoApi:acIsStop()
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
        local freeFlag=acCjyxVoApi:isFreeLottery()
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

function acCjyxLottery:refresh()
    if self.pointLb then
        local point=acCjyxVoApi:getMyPoint()
        local pointStr=getlocal("cjyx_point_str").."："..point
        self.pointLb:setString(pointStr)
    end
end

function acCjyxLottery:addForbidLayer(touchCallBack)
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

function acCjyxLottery:updateUI()
    self:refresh()
    self:refreshLotteryBtn()
end

function acCjyxLottery:removeForbidLayer()
    if self.forbidLayer then
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer=nil
    end
end

function acCjyxLottery:playeLotteryEffect(num,lottery,endHandler,rewardlist)
    if self.actionLayer then
        do return end
    end
    local function closeLottery()
        self:removeLotteryEffect()
    end
    local function speedUp()
        if endHandler then
            endHandler(closeLottery)
        end
    end
    local actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),speedUp)
    actionLayer:setTouchPriority(-(self.layerNum-1)*20-9)
    actionLayer:setContentSize(G_VisibleSize)
    actionLayer:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(actionLayer,11)
    self.actionLayer=actionLayer
    
    local function onLoadIcon(fn,icon)
        if self and self.actionLayer then
            icon:setAnchorPoint(ccp(0.5,1))
            icon:setScaleX(G_VisibleSizeWidth/icon:getContentSize().width)
            icon:setScaleY(G_VisibleSizeHeight/icon:getContentSize().height)
            icon:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight)
            self.actionLayer:addChild(icon)
            icon:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight)
        end
    end
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local acArr=CCArray:create()
    local time=0
    local ltype=lottery[1]
    local bombNum=tonumber(lottery[2])
    local delaytime=0
    if ltype then
        if ltype==1 then --窜天猴
            delaytime=self:playFireworks1(false)
            local beginX=G_VisibleSizeWidth/2
            local beginY=250
            local targetX=beginX
            local targetY=math.random(550,G_VisibleSizeHeight-200)
            self:playFireworks1(true,ccp(beginX,beginY),ccp(targetX,targetY),rewardlist)
        elseif ltype==2 then --二踢脚
            delaytime=self:playFireworks2(false)
            local beginX=G_VisibleSizeWidth/2
            local beginY=250
            local targetX=math.random(100,G_VisibleSizeWidth-100)
            local targetY=math.random(550,G_VisibleSizeHeight-200)
            self:playFireworks2(true,ccp(beginX,beginY),ccp(targetX,targetY),rewardlist)
        elseif ltype==3 then --挂鞭炮
            delaytime=self:playFireworks3(false,nil,bombNum)
            self:playFireworks3(true,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-220),bombNum,false,rewardlist)
        elseif ltype==4 then --礼花弹
            delaytime=self:playFireworks4(false,1)
            self:playFireworks4(true,1)
            local function rewardShow()
                local count=SizeOfTable(rewardlist)
                local firstPosX=0
                local firstPosY=G_VisibleSizeHeight-400
                if count>5 then
                    firstPosX=(G_VisibleSizeWidth-5*100-4*30)/2
                else
                    firstPosX=(G_VisibleSizeWidth-count*100-(count-1)*30)/2
                end
                for k,reward in pairs(rewardlist) do
                    local posX=firstPosX+40+math.floor((k-1)%5)*130
                    local posY=firstPosY-40-math.floor((k-1)/5)*120
                    self:rewardShow(reward,ccp(posX,posY),5,100)     
                end
            end
            local delay=CCDelayTime:create(delaytime)
            acArr:addObject(delay)
            local showFunc=CCCallFuncN:create(rewardShow)
            acArr:addObject(showFunc)
            delaytime=1.5
        elseif ltype==5 then --10连抽
            delaytime=3.5
            -- self:playFireworks3(true,ccp(120,G_VisibleSizeHeight-220),5,true,nil,0,0.35)
            -- self:playFireworks3(true,ccp(G_VisibleSizeWidth-120,G_VisibleSizeHeight-220),5,true,nil,0.5,0.5)
            local firstPosX=180
            local spaceX=(G_VisibleSizeWidth-2*firstPosX)/4
            local beginY=250
            local randomTb={1,2,3,4,5}
            local dtimeCfg={0.3,0.5,0.6,0.8,0.9}
            for i=1,5 do
                local anode=CCNode:create()
                self.actionLayer:addChild(anode,5)
                local arr=CCArray:create()
                local delay=CCDelayTime:create(dtimeCfg[i])
                arr:addObject(delay)
                local function play()
                    local max=SizeOfTable(randomTb)
                    local index=math.random(1,max)
                    local fidx=randomTb[index]
                    table.remove(randomTb,index)
                    local beginX=firstPosX+(fidx-1)*spaceX
                    local targetX=math.random(200,G_VisibleSizeWidth-200)
                    local targetY=math.random(550,G_VisibleSizeHeight-200)
                    local difPos=ccpSub(ccp(targetX,targetY),ccp(beginX,beginY))
                    local angleRadians=ccpToAngle(difPos)
                    local angleDegrees=math.deg(angleRadians)*(-1.0)+90
                    self:playFireworks1(true,ccp(beginX,beginY),ccp(targetX,targetY),nil,angleDegrees)
                end
                local pFunc=CCCallFuncN:create(play)
                arr:addObject(pFunc)
                local subseq=CCSequence:create(arr)
                anode:runAction(subseq)
            end
            local firenode=CCNode:create()
            self.actionLayer:addChild(firenode,5)
            local arr=CCArray:create()
            local function playFire()
                self:playFireworks4(true)
            end
            local delay=CCDelayTime:create(0.5)
            arr:addObject(delay)
            local funcCall=CCCallFuncN:create(playFire)
            local delay2=CCDelayTime:create(1)
            local function playFire2( ... )
                self:playFireworks4(true,nil,60)
            end
            local funcCall2=CCCallFuncN:create(playFire2)
            arr:addObject(funcCall)
            arr:addObject(delay2)
            arr:addObject(funcCall2)
            local subseq=CCSequence:create(arr)
            firenode:runAction(subseq)
        end
    end
    local function actionEndHandler()
        if endHandler then
            endHandler(closeLottery)
        end
    end
    local delay1=CCDelayTime:create(delaytime)
    local funcCall1=CCCallFuncN:create(actionEndHandler)
    acArr:addObject(delay1)
    acArr:addObject(funcCall1)
    local subseq=CCSequence:create(acArr)
    actionLayer:runAction(subseq)
end

function acCjyxLottery:rewardShow(reward,pos,zorder,iconSize)
    if reward and reward.type then
        if iconSize==nil then
            iconSize=80
        end
        local icon,scale=G_getItemIcon(reward,iconSize,true)
        if icon then
            icon:setPosition(pos)
            if zorder==nil then
                zorder=1
            end
            self.actionLayer:addChild(icon,zorder)
            icon:setScale(0)
            local numLb=GetTTFLabel(FormatNumber(reward.num),23)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setScale(1/scale)
            numLb:setPosition(ccp(icon:getContentSize().width-5,0))
            icon:addChild(numLb,4)
            local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
            numBg:setAnchorPoint(ccp(1,0))
            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
            numBg:setOpacity(150)
            icon:addChild(numBg,3)

            local maxScale=100/icon:getContentSize().width
            local arr=CCArray:create()
            local scaleAc=CCScaleTo:create(0.5,maxScale)
            local out=CCEaseBounceInOut:create(scaleAc)
            local scaleAc2=CCScaleTo:create(0.2,scale)
            arr:addObject(out)
            arr:addObject(scaleAc2)
            local subseq=CCSequence:create(arr)
            icon:runAction(subseq)
        end
    end
end

function acCjyxLottery:playBomb(bombPic,pos,zorder,reward,rewardPos,scale,iconSize)
    local bombSp=CCSprite:createWithSpriteFrameName(bombPic)
    if bombSp then
        bombSp:setPosition(pos)
        bombSp:setScale(0)
        if zorder==nil then
            zorder=1
        end
        if scale==nil then
            scale=1.2
        end
        self.actionLayer:addChild(bombSp,zorder)
        local acArr=CCArray:create()
        local scaleOut=CCScaleTo:create(0.1,scale)
        local outAction=CCFadeTo:create(0.1,255)
        local arr1=CCArray:create()
        arr1:addObject(scaleOut)
        arr1:addObject(outAction)
        local swpan1=CCSpawn:create(arr1)
        acArr:addObject(swpan1)
        local scaleIn=CCScaleTo:create(0.2,0)
        local inAction=CCFadeTo:create(0.2,0)
        local function rewardShow() --在爆炸效果出抽到的奖励
            local iconPos=rewardPos or pos
            self:rewardShow(reward,iconPos,zorder+1,iconSize)
        end
        local rsfunc=CCCallFuncN:create(rewardShow)
        local arr2=CCArray:create()
        arr2:addObject(scaleIn)
        arr2:addObject(inAction)
        arr2:addObject(rsfunc)
        local swpan2=CCSpawn:create(arr2)
        acArr:addObject(swpan2)

        local function clearSp()
           bombSp:removeFromParentAndCleanup(true)
           bombSp=nil
        end
        local funcCall=CCCallFuncN:create(clearSp)
        acArr:addObject(funcCall)
        local subseq=CCSequence:create(acArr)
        bombSp:runAction(subseq)
    end
end

function acCjyxLottery:playParticleBomb(plist,pos,parent,zorder)
    local fire=CCParticleSystemQuad:create(plist)
    if fire then
        fire:setAutoRemoveOnFinish(true)
        fire:setPositionType(kCCPositionTypeFree)
        -- fire.positionType=kCCPositionTypeFree
        fire:setPosition(pos)
        fire:setScale(1.2)
        if parent==nil then
            parent=self.actionLayer
        end
        if zorder==nil then
            zorder=1
        end
        parent:addChild(fire,zorder)
    end
    return fire
end

function acCjyxLottery:playFireworks1(showFlag,beginPos,targetPos,rewardlist,angle) --窜天猴动画
    local delaytime=0
    local dtime=0.2
    local jumptime=0.5
    delaytime=delaytime+jumptime+dtime+1
    if showFlag and showFlag==true then
        local beginX=G_VisibleSizeWidth/2
        local beginY=250
        local targetX=beginX
        local targetY=math.random(550,G_VisibleSizeHeight-200)

        local icon=CCSprite:createWithSpriteFrameName("single_fire1.png")
        icon:setAnchorPoint(ccp(0.5,0))
        icon:setPosition(beginPos)
        if angle==nil then
            angle=0
        end
        icon:setRotation(angle)
        self.actionLayer:addChild(icon,2)
        local fireAcArr=CCArray:create()
        local delay1=CCDelayTime:create(dtime)
        fireAcArr:addObject(delay1)
        local actionUp=CCJumpTo:create(jumptime,targetPos,30,1)
        fireAcArr:addObject(actionUp)
        local function bomb()
            local reward
            if rewardlist then
                reward=rewardlist[1]
            end
            self:playBomb("cjyx_bomb2.png",targetPos,5,reward,nil,nil,100)
        end
        local funcCall1=CCCallFuncN:create(bomb)
        fireAcArr:addObject(funcCall1)
        local function clearSp()
           icon:removeFromParentAndCleanup(true)
           icon=nil
        end
        local funcCall2=CCCallFuncN:create(clearSp)
        fireAcArr:addObject(funcCall2)
        local action=CCSequence:create(fireAcArr)
        icon:runAction(action)

        local flameSp=self:playParticleBomb("public/CuanTianHou_ShengQi.plist",ccp(beginPos.x,beginPos.y-icon:getContentSize().height/2))
        -- flameSp:setRotation(angle)
        local arr=CCArray:create()
        local flameDelay=CCDelayTime:create(dtime)
        arr:addObject(flameDelay)
        local jumpTo=CCJumpTo:create(jumptime,ccp(targetPos.x,targetPos.y-icon:getContentSize().height/2),30,1)
        arr:addObject(jumpTo)
        local function clearSp()
            flameSp:removeFromParentAndCleanup(true)
            flameSp=nil
        end
        local funcCall=CCCallFuncN:create(clearSp)
        arr:addObject(funcCall)
        local subseq=CCSequence:create(arr)
        flameSp:runAction(subseq)
    end
    return delaytime
end

function acCjyxLottery:playFireworks2(showFlag,beginPos,targetPos,rewardlist) --二踢脚动画
    local delaytime=0
    local dtime=0.5
    local jumptime=1
    delaytime=delaytime+dtime+jumptime+1.2
    if showFlag and showFlag==true then
        local function bomb1()
            local reward
            if rewardlist then
                reward=rewardlist[1]
            end
            self:playBomb("cjyx_bomb1.png",ccp(beginPos.x-15,beginPos.y+30),5,reward,nil,nil,100)
        end
        local function bomb2()
            local reward
            if rewardlist then
                reward=rewardlist[2]
            end
            self:playBomb("cjyx_bomb2.png",targetPos,5,reward,nil,nil,100)
        end
        local icon=CCSprite:createWithSpriteFrameName("single_fire2.png")
        icon:setPosition(beginPos)
        self.actionLayer:addChild(icon,2)

        local bombPos=ccp(icon:getContentSize().width/2-15,icon:getContentSize().height)
        self:playParticleBomb("public/BianPao1_1.plist",bombPos,icon)
        self:playParticleBomb("public/BianPao1_2.plist",bombPos,icon)
        self:playParticleBomb("public/BianPao1_3.plist",bombPos,icon)

        local fireAcArr=CCArray:create()
        local delay1=CCDelayTime:create(dtime)
        fireAcArr:addObject(delay1)
        local funcCall1=CCCallFuncN:create(bomb1)
        fireAcArr:addObject(funcCall1)
        local rotateBy=CCRotateBy:create(jumptime,2*360)
        local actionUp=CCJumpTo:create(jumptime,targetPos,30,1)
        local spwanArr=CCArray:create()
        spwanArr:addObject(rotateBy)
        spwanArr:addObject(actionUp)
        local swpanAc=CCSpawn:create(spwanArr)
        fireAcArr:addObject(swpanAc)
        local funcCall2=CCCallFuncN:create(bomb2)
        fireAcArr:addObject(funcCall2)
        local function clearSp()
           icon:removeFromParentAndCleanup(true)
           icon=nil
        end
        local funcCall3=CCCallFuncN:create(clearSp)
        fireAcArr:addObject(funcCall3)
        local action=CCSequence:create(fireAcArr)
        icon:runAction(action)
    end
    return delaytime
end

function acCjyxLottery:playFireworks3(showFlag,showPos,bombNum,isRepeatForever,rewardlist,pdelayTime,bombScale) --挂鞭炮动画
    local delaytime=0
    -- local posCfg={{333,513},{276,430},{370,415},{238,332},{337,279}}
    local posCfg={{333,513},{433,443},{300,360},{430,290},{337,200}}
    -- local posCfg={{333,513},{240,480},{370,415},{238,400},{337,279}} --鞭炮的爆炸坐标
    -- local rPosCfg={{330,513},{230,413},{430,413},{330,313},{330,213}} --奖励的显示坐标
    local timeCfg={0.2,0.3,0.4,0.5,0.6}
    local delayCfg={0,1,0.2,0.3,0.4,0.5}
    local rotateCfg={0,30,80,100,120}
    local randomTb={}
    local numTb={}
    for i=1,bombNum do
        randomTb[i]=i
    end
    for i=1,bombNum do --随机鞭炮的位置
        local max=SizeOfTable(randomTb)
        local index=math.random(1,max)
        numTb[i]=randomTb[index]
        table.remove(randomTb,index)
    end
    if showFlag and showFlag==true then
        local icon=CCSprite:createWithSpriteFrameName("single_fire3.png")
        icon:setAnchorPoint(ccp(0.5,1))
        icon:setScale(1.5)
        icon:setPosition(showPos)
        self.actionLayer:addChild(icon,2)
        local beginX=showPos.x
        local beginY=showPos.y-icon:getContentSize().height-40
        for i=1,3 do
            local plistStr="public/BianPao1_"..i..".plist"
            local fire=self:playParticleBomb(plistStr,ccp(beginX,beginY))
            if isRepeatForever==false then
                local fireArr=CCArray:create()
                local delay=CCDelayTime:create(1.5)
                fireArr:addObject(delay)
                local function clearFire()
                    fire:removeFromParentAndCleanup(true)
                    fire=nil
                end
                local clearFunc=CCCallFuncN:create(clearFire)
                fireArr:addObject(clearFunc)
                local action=CCSequence:create(fireArr)
                fire:runAction(action)
            end
        end
        local offsetX=showPos.x-G_VisibleSizeWidth/2
        for k,v in pairs(numTb) do
            local time=timeCfg[v] or 0.2
            local dtime=delayCfg[v] or 0.2
            if pdelayTime then
                dtime=dtime+pdelayTime
            end
            local angle=rotateCfg[v] or 0
            local targetX=posCfg[v][1]+offsetX
            local targetY=posCfg[v][2]
            if G_isIphone5()==true then
                targetY=targetY+160
            end
            local fire=CCSprite:createWithSpriteFrameName("single_fire2.png")
            fire:setScale(0.35)
            fire:setPosition(beginX,beginY)
            fire:setRotation(angle)
            self.actionLayer:addChild(fire,3)
            local arr=CCArray:create()
            local delay=CCDelayTime:create(dtime)
            arr:addObject(delay)
            local function visible()
                fire:setVisible(true)
            end
            local visibleFunc=CCCallFuncN:create(visible)
            arr:addObject(visibleFunc)
            local jumpTo=CCJumpTo:create(time,ccp(targetX,targetY),30,1)
            arr:addObject(jumpTo)
            local function bomb()
                local reward
                if rewardlist then
                    reward=rewardlist[k]
                end
                -- local rpos=ccp(rPosCfg[k][1],rPosCfg[k][2])
                if bombScale==nil then
                    bombScale=1
                end
                -- self:playBomb("cjyx_bomb1.png",ccp(targetX,targetY),5,reward,rpos,bombScale)
                self:playBomb("cjyx_bomb1.png",ccp(targetX,targetY),5,reward,nil,bombScale)

            end
            local bombFunc=CCCallFuncN:create(bomb)
            arr:addObject(bombFunc)
            if isRepeatForever and isRepeatForever==true then
                local function disVisible()
                    fire:setVisible(false)
                end
                local visibleFunc=CCCallFuncN:create(disVisible)
                arr:addObject(visibleFunc)
                local action=CCSequence:create(arr)
                fire:runAction(CCRepeatForever:create(action))
            else
                local function clearSp()
                    fire:removeFromParentAndCleanup(true)
                    fire=nil
                end
                local clearFunc=CCCallFuncN:create(clearSp)
                arr:addObject(clearFunc)
                local action=CCSequence:create(arr)
                fire:runAction(action)
            end
        end
    else
        local time1=0
        local time2=0
        for k,v in pairs(numTb) do --遍历播放鞭炮动画
            local time=timeCfg[v] or 0.2
            local dtime=delayCfg[v] or 0.2
            if time>time1 then
                time1=time
            end
            if dtime>time2 then
                time2=dtime
            end
        end
        delaytime=time1+time2+2
    end
    return delaytime
end

function acCjyxLottery:playFireworks4(showFlag,num,offsetY) --礼花弹动画
    -- local firePosCfg={{377,561},{165,569},{473,609}}
    -- local firePosCfg={{368,501},{271,442},{368,369},{271,302},{368,234}}
    local firePosCfg={{377,G_VisibleSizeHeight-200},{165,G_VisibleSizeHeight-350},{473,G_VisibleSizeHeight-400},{G_VisibleSizeWidth/2,G_VisibleSizeHeight-400}}
    local dtimeCfg={0,0.2,0.5,1}
    local delaytime=0
    local movetime=0.5
    local bombNum=3
    if num==1 then
        bombNum=bombNum+1
    end
    if offsetY==nil then
        offsetY=0
    end
    delaytime=delaytime+movetime+dtimeCfg[bombNum]+0.5
    if showFlag and showFlag==true then
        for i=1,bombNum do
            local fire=self:playParticleBomb("public/YanHuo01_ShengQi.plist",ccp(G_VisibleSizeWidth/2,80))
            local fireArr=CCArray:create()
            local delay=CCDelayTime:create(dtimeCfg[i])
            fireArr:addObject(delay)
            local moveTo=CCMoveTo:create(movetime,ccp(firePosCfg[i][1],firePosCfg[i][2]-offsetY))
            fireArr:addObject(moveTo)
            local function clearFire()
                fire:removeFromParentAndCleanup(true)
                fire=nil
                local posX=firePosCfg[i][1]
                local posY=firePosCfg[i][2]
                local bomb=self:playParticleBomb("public/YanHuo01.plist",ccp(posX,posY),nil,10)
            end
            local funcCall=CCCallFuncN:create(clearFire)
            fireArr:addObject(funcCall)
            local subseq=CCSequence:create(fireArr)
            fire:runAction(subseq)
        end
    end
    return delaytime
end

function acCjyxLottery:removeLotteryEffect()
    if self.actionLayer then
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer=nil
    end
end

function acCjyxLottery:tick()
    local isEnd=acCjyxVoApi:acIsStop()
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
        local todayFlag=acCjyxVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acCjyxVoApi:resetFreeLottery()
            self:refreshLotteryBtn()
        end
    end
end

function acCjyxLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.forbidLayer=nil
    self.showList={}
    self.cellNum=0
    self.cellHeight=110
    self.isEnd=false
    self.freeBtn=nil
    self.lotteryBtn=nil
    self.multiLotteryBtn=nil
    self.lotteryCallBack=nil
    self.propSize=80
    self.isTodayFlag=true
    self.actionLayer=nil
    self.mustModeFlag=false
end