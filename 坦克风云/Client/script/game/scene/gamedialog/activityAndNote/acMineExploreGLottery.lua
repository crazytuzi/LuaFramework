acMineExploreGLottery={}

function acMineExploreGLottery:new()
    local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.isEnd=false
    nc.digBtn=nil
    nc.multiDigBtn=nil
    nc.digCostNode=nil
    nc.multiCostNode=nil
    nc.mainLayer=nil
    nc.mazeLayer=nil
    nc.cellSpTb=nil
    nc.digCallBack=nil
    nc.isTodayFlag=true
    nc.boxSpTb=nil
    nc.floorLb=nil
    nc.promptLb=nil
    nc.arrowTb=nil
    nc.exitLayer=nil
    nc.tipLb=nil
    nc.arrowSp=nil
    nc.pointLb=nil
    nc.rankLb=nil
    nc.rankBg=nil
    nc.costLb = nil
    nc.multiCostLb = nil
    nc.url=G_downloadUrl("active/".."mineExplore/".."mazeBg.jpg")
    setmetatable(nc, self)
    self.__index=self

    return nc
end 

function acMineExploreGLottery:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.cellSpTb={}
    self.arrowTb={}
    self:tick()
    self:initTableView()
    return self.bgLayer
end

function acMineExploreGLottery:initTableView()
    self.isEnd=acMineExploreGVoApi:isEnd()
    self:initLayer()
end

function acMineExploreGLottery:initLayer()
    local strSize=25
    local h=G_VisibleSizeHeight-160
    local w=G_VisibleSizeWidth-50 --背景框的宽度
    local bgH=120
    local strSize3 = 25--18
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() == "ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    local infoH=120
    local addH=0
    local addH2=0
    if G_isIphone5()==true then
        bgH=150
        infoH=150
        addH=50
        addH2=-30
    end
    local layerH=G_VisibleSizeHeight-infoH-180
    local scale=layerH/651
    local mainLayer=CCNode:create()
    mainLayer:setAnchorPoint(ccp(0.5,0))
    mainLayer:setContentSize(CCSizeMake(612,layerH))
    mainLayer:setPosition(G_VisibleSizeWidth/2,30)
    self.bgLayer:addChild(mainLayer,1)
    self.mainLayer=mainLayer
    -- self.mainLayer:setScaleY(scale)

    local bgSize=mainLayer:getContentSize()
    local function onLoadIcon(fn,icon)
        if self and self.mainLayer then
            if self.bgLayer then
                icon:setAnchorPoint(ccp(0.5,0.5))
                icon:setScaleY(scale)
                self.mainLayer:addChild(icon)
                icon:setPosition(getCenterPoint(self.mainLayer))
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local zorder=2

    local lightSp=CCSprite:createWithSpriteFrameName("anniversaryLight.png")
    lightSp:setPosition(bgSize.width/2,bgSize.height-40+addH2)
    mainLayer:addChild(lightSp,1)
    local starBg=CCSprite:createWithSpriteFrameName("heroBg.png")
    starBg:setAnchorPoint(ccp(0.5,1))
    starBg:setPosition(ccp(bgSize.width/2,bgSize.height-50+addH2))
    mainLayer:addChild(starBg,1)
    starBg:setScale(1.2)

    local floorLb=GetTTFLabelWrap(getlocal("activity_mineExploreG_rewardShow"),25,CCSize(bgSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    floorLb:setPosition(getCenterPoint(starBg))
    self.floorLb=floorLb
    starBg:addChild(floorLb)

    local pointStr=getlocal("activity_mineExplore_money").."："..acMineExploreGVoApi:getMyPoint()
    local pointLb=GetTTFLabelWrap(pointStr,strSize3,CCSize(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    pointLb:setAnchorPoint(ccp(0.5,1))
    pointLb:setPosition(ccp(mainLayer:getContentSize().width*0.5,h-bgH-40))
    mainLayer:addChild(pointLb,2)
    self.pointLb=pointLb

    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:recordHandler()
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    -- recordBtn:setScaleY(0.8/scale)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(bgSize.width-recordBtn:getContentSize().width*recordBtn:getScaleX()+20,h-bgH-80))
    mainLayer:addChild(recordMenu,zorder)
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    recordBg:setAnchorPoint(ccp(0.5,1))
    recordBg:setContentSize(CCSizeMake(100,40))
    recordBg:setPosition(ccp(recordBtn:getContentSize().width/2,0))
    recordBg:setScale(1/0.8)
    recordBtn:addChild(recordBg,zorder)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width/2,recordBg:getContentSize().height/2)
    recordLb:setColor(G_ColorYellowPro)
    recordBg:addChild(recordLb)

    local chestReward=acMineExploreGVoApi:getMazeChestReward()
    local rewardlist=FormatItem(chestReward,nil,true)
    if SizeOfTable(rewardlist) > 0 then
        for i=1,6 do
            local j = i>3 and 1 or 0
            local ii = i> 3 and i-3 or i
            local icon,scale=G_getItemIcon(rewardlist[i],90,true,self.layerNum+1)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setTouchPriority(-(self.layerNum-1)*20-5)
            icon:setPosition(ccp(25 + ii*125,bgSize.height*0.75-j*110))
            self.bgLayer:addChild(icon,zorder+1)
            local numLb=GetTTFLabel("x"..rewardlist[i].num,22)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-4,4))
            numLb:setScale(1/scale)
            icon:addChild(numLb)
            G_addRectFlicker(icon,1.2/scale,1.2/scale)
        end
    end

    local function noData( ) end
    local storeStrBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),noData);
    storeStrBg:setAnchorPoint(ccp(0.5,1))
    storeStrBg:setOpacity(180)
    storeStrBg:setContentSize(CCSizeMake(bgSize.width-22,bgSize.height*0.5-48))
    storeStrBg:setPosition(ccp(bgSize.width*0.5+14,bgSize.height*0.54-40))
    self.bgLayer:addChild(storeStrBg,zorder+1)

    for i=1,2 do
        local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSp:setScaleX((bgSize.width-30)/lineSp:getContentSize().width)
        lineSp:setPosition(ccp(bgSize.width*0.5+10,bgSize.height*0.27*i-10-(i-1)*30))
        self.bgLayer:addChild(lineSp,zorder+1)

        local key="p3338"
        local type="p"
        local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
        local num=acMineExploreGVoApi:getMyPoint()
        local item={type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num}
        -- local numLb=GetTTFLabel(getlocal("propInfoNum",{num}),25)
        local icon,scale=G_getItemIcon(item,100,false,self.layerNum+1)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-5)
        icon:setPosition(ccp(35,bgSize.height*0.14*i+(i-1)*50))
        self.bgLayer:addChild(icon,zorder+1)
        -- numLb:setAnchorPoint(ccp(0,1))
        -- numLb:setPosition(10,-10)
        -- numLb:setScale(1/scale)
        -- icon:addChild(numLb)

        if i == 1 then
            G_addRectFlicker(icon,1.3/scale,1.3/scale)
        end
        local nums = i == 1 and acMineExploreGVoApi:getCanDigCount() or 1
        local numsStr = "x"..nums
        local bigStr  = i==1 and getlocal("bigType") or ""
        local boxTitleStr = GetTTFLabelWrap(bigStr..getlocal("activity_mineExploreG_box").."x"..1,26,CCSize(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        boxTitleStr:setAnchorPoint(ccp(0,0.5))
        boxTitleStr:setColor(G_ColorYellowPro)
        boxTitleStr:setPosition(ccp(145,icon:getPositionY()+35))
        self.bgLayer:addChild(boxTitleStr,zorder+1)

        --activity_mineExploreG_boxOpen
        local rangeNum1,rangeNum2 = acMineExploreGVoApi:getScoreRage( )
        local storeNumStr = rangeNum1*nums.."-"..rangeNum2*nums
        local desStr = i ==1 and "activity_mineExploreG_boxOpen2" or "activity_mineExploreG_boxOpen1"
        local boxDesStr = GetTTFLabelWrap(getlocal(desStr,{storeNumStr}),23,CCSize(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        boxDesStr:setAnchorPoint(ccp(0,1))
        boxDesStr:setPosition(ccp(145,icon:getPositionY()+15))
        self.bgLayer:addChild(boxDesStr,zorder+1)
    end

    local cost1,cost2=acMineExploreGVoApi:getDigCost()
    local freeFlag=acMineExploreGVoApi:isFreeDig()
    local digStr=getlocal("buy")
    if freeFlag==1 then
        digStr=getlocal("daily_lotto_tip_2")
    end
    local function digHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:digHandler(1)
    end
    local digBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",digHandler,nil,digStr,strSize,11)
    digBtn:setAnchorPoint(ccp(1,0))
    digBtn:setScale(0.8)
    local digMenu=CCMenu:createWithItem(digBtn)
    digMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    digMenu:setPosition(ccp(bgSize.width,bgSize.height*0.27+20))
    self.bgLayer:addChild(digMenu,zorder+1)
    self.digBtn=digBtn

    local digCostNode=CCNode:create()
    digCostNode:setAnchorPoint(ccp(0.5,0))
    digBtn:addChild(digCostNode)
    self.digCostNode=digCostNode
    local costLb=GetTTFLabel(tostring(cost1),30)
    costLb:setAnchorPoint(ccp(0,0))
    digCostNode:addChild(costLb)
    self.costLb = costLb
    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0))
    digCostNode:addChild(costSp)
    local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width
    digCostNode:setContentSize(CCSizeMake(lbWidth,1))
    costLb:setPosition(ccp(0,0))
    costSp:setPosition(ccp(costLb:getContentSize().width,0))
    digCostNode:setPosition(ccp(digBtn:getContentSize().width/2,digBtn:getContentSize().height))
    if freeFlag==1 then
        self.digCostNode:setVisible(false)
    end
    local function multiDigHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:digHandler(2)
    end
    local digCount=acMineExploreGVoApi:getCanDigCount()
    local multiDigBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",multiDigHandler,nil,getlocal("buy",{digCount}),strSize2,11)
    multiDigBtn:setAnchorPoint(ccp(1,0))
    multiDigBtn:setScale(0.8)
    local multiAttireMenu=CCMenu:createWithItem(multiDigBtn)
    multiAttireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    multiAttireMenu:setPosition(ccp(bgSize.width,50))
    self.bgLayer:addChild(multiAttireMenu,zorder+1)
    self.multiDigBtn=multiDigBtn
    local costLbW=200
    local multiCostNode=CCNode:create()
    multiCostNode:setContentSize(CCSizeMake(costLbW,1))
    multiCostNode:setAnchorPoint(ccp(0.5,0))
    multiDigBtn:addChild(multiCostNode)
    multiCostNode:setPosition(ccp(multiDigBtn:getContentSize().width/2,multiDigBtn:getContentSize().height))
    local multiCostLb=GetTTFLabel(tostring(cost2),30)
    multiCostLb:setAnchorPoint(ccp(0,0))
    multiCostLb:setColor(G_ColorYellowPro)
    multiCostLb:setTag(101)
    multiCostNode:addChild(multiCostLb)
    self.multiCostLb = multiCostLb
    local multiCostSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    multiCostSp:setAnchorPoint(ccp(0,0))
    multiCostSp:setTag(102)
    multiCostNode:addChild(multiCostSp)
    local lbWidth=multiCostLb:getContentSize().width+multiCostSp:getContentSize().width
    local firstPosX=(costLbW-lbWidth)/2
    multiCostLb:setPosition(ccp(firstPosX,0))
    multiCostSp:setPosition(ccp(multiCostLb:getPositionX()+multiCostLb:getContentSize().width,0))
    self.multiCostNode=multiCostNode

    if cost1 <= playerVoApi:getGems() then
        costLb:setColor(G_ColorYellowPro)
    else
        costLb:setColor(G_ColorRed)
    end
    if cost2 <= playerVoApi:getGems() then
        multiCostLb:setColor(G_ColorYellowPro)
    else
        multiCostLb:setColor(G_ColorRed)
    end
    self:refreshDigBtn()

end

function acMineExploreGLottery:refreshDigBtn()
    if self.isEnd==true then
        self.digBtn:setEnabled(false)
        self.multiDigBtn:setEnabled(false)
        do return end
    end
    if self.digBtn and self.multiDigBtn and self.digCostNode and self.multiCostNode then
        local freeFlag=acMineExploreGVoApi:isFreeDig()
        local btnLb=tolua.cast(self.digBtn:getChildByTag(11),"CCLabelTTF")
        local btnLb2=tolua.cast(self.multiDigBtn:getChildByTag(11),"CCLabelTTF")
        if btnLb and btnLb2 then            
            if freeFlag==1 then
                btnLb:setString(getlocal("daily_lotto_tip_2"))
                self.digCostNode:setVisible(false)
                self.multiDigBtn:setEnabled(false)
            else
                btnLb:setString(getlocal("buy"))
                self.digCostNode:setVisible(true)
                self.multiDigBtn:setEnabled(true)
            end
            local cost1,cost2=acMineExploreGVoApi:getDigCost()
            local costLb=tolua.cast(self.multiCostNode:getChildByTag(101),"CCLabelTTF")
            local costSp=tolua.cast(self.multiCostNode:getChildByTag(102),"CCSprite")
            if costLb and costSp then
                costLb:setString(tostring(cost2))
                local costLbW=200
                local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width
                local firstPosX=(costLbW-lbWidth)/2
                costLb:setPosition(ccp(firstPosX,0))
                costSp:setPosition(ccp(costLb:getPositionX()+costLb:getContentSize().width,0))
            end
            if cost1 > playerVoApi:getGems() and self.costLb then
                self.costLb:setColor(G_ColorRed)
            end
            if cost2 > playerVoApi:getGems() and self.multiCostLb then
                self.multiCostLb:setColor(G_ColorRed)
            end
        end
    end
end

function acMineExploreGLottery:digHandler(dtype)
    local digNum=1
    if dtype==2 then
        digNum=acMineExploreGVoApi:getCanDigCount()
    end
    local function realDig(digNum,cost)
        local function callback(result,map,digTb,rewardlist,tipStrTb,allRewards)
            if result==false then
                do return end
            end
            local chestCount=0 --本次挖掘的宝箱的个数
            local hasExit=false
            for k,v in pairs(digTb) do
                local flag=acMineExploreGVoApi:isUnlockChest(v)
                chestCount = flag == true and chestCount +1 or chestCount
                
            end

            if cost and tonumber(cost)>0 then
                playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
            end
            if rewardlist and type(rewardlist)=="table" then           
                local function showRewards()
                        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"   
                        local isbig = dtype == 2 and getlocal("bigType") or ""
                        local titleStr=getlocal("buy")..isbig..getlocal("activity_mineExploreG_box")
                        local function callback()

                            if allRewards then
                                G_showRewardTip(allRewards)
                            end
                        end
                        acMineExploreGVoApi:showRewardSmallDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardlist,tipStrTb,false,true,self.layerNum+1,callback)
                    self:refresh(false,map,digTb)
                end
                showRewards()
            end
            self:refreshDigBtn()
        end
        local freeFlag=acMineExploreGVoApi:isFreeDig()
        acMineExploreGVoApi:mineExploreGRequest("active.mineexploreg",{freeFlag,digNum},callback)
    end
    local cost=0
    local freeFlag=acMineExploreGVoApi:isFreeDig()
    local cost1,cost2=acMineExploreGVoApi:getDigCost()
    if cost1 and cost2 then
        if dtype==1 and freeFlag==0 then
            cost=cost1
        elseif dtype==2 then
            cost=cost2
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        realDig(digNum,cost)
    end
end

function acMineExploreGLottery:recordHandler()
    local function callback()
        local function showNoRecord()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        local recordList=acMineExploreGVoApi:getRecordList()
        local rc=SizeOfTable(recordList)

        if rc==0 then
            showNoRecord()
            do return end
        end
        local recordCount=SizeOfTable(recordList)
        if recordCount==0 then
            showNoRecord()
            do return end
        end
        local recordNum=10
        local function confirmHandler()
        end

        require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
        acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("buyLogTitle"),G_ColorYellowPro},recordList,false,self.layerNum+1,confirmHandler,true,recordNum,false)
    end
    local flag=acMineExploreGVoApi:getRequestLogFlag()

    if flag==false then
        acMineExploreGVoApi:mineExploreGRequest("active.mineexploreg.report",nil,callback)
    else
        callback()
    end
end

function acMineExploreGLottery:refresh(isNext,mapData,cellTb)
    if self.pointLb then
        local point=acMineExploreGVoApi:getMyPoint()
        local pointStr=getlocal("activity_mineExplore_money").."："..point
        self.pointLb:setString(pointStr)
    end

    self:refreshDigBtn()
end

function acMineExploreGLottery:updateUI()
    if self.pointLb then
        local point=acMineExploreGVoApi:getMyPoint()
        local pointStr=getlocal("activity_mineExplore_money").."："..point
        self.pointLb:setString(pointStr)
    end
end

function acMineExploreGLottery:tick()
    local isEnd=acMineExploreGVoApi:isEnd()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
    end
    if isEnd==false then
        local todayFlag=acMineExploreGVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acMineExploreGVoApi:resetFreeDig()
            self:refreshDigBtn()
        end
    end
end

function acMineExploreGLottery:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.forbidLayer=nil
    self.isEnd=false
    self.digBtn=nil
    self.multiDigBtn=nil
    self.digCostNode=nil
    self.multiCostNode=nil
    self.mainLayer=nil
    self.mazeLayer=nil
    self.cellSpTb=nil
    self.digCallBack=nil
    self.isTodayFlag=true
    self.boxSpTb=nil
    self.floorLb=nil
    self.promptLb=nil
    self.arrowTb=nil
    self.exitLayer=nil
    self.tipLb=nil
    self.arrowSp=nil
    self.pointLb=nil

end