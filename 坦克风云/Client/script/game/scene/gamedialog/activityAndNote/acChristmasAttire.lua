acChristmasAttire={}

function acChristmasAttire:new()
	local nc={}
    nc.bgLayer=nil
    nc.forbidLayer=nil
    nc.actionLayer=nil
    nc.isEnd=false
    nc.attireBtn=nil
    nc.multiAttireBtn=nil
    nc.attireCostNode=nil
    nc.christmasNode=nil
    nc.attireCallBack=nil
    nc.isTodayFlag=true
    nc.materialSpTb=nil
    nc.url=G_downloadUrl("active/".."christmas2016/".."christmas2016_bg.jpg")
	setmetatable(nc, self)
	self.__index=self

	return nc
end	

function acChristmasAttire:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()
    return self.bgLayer
end

function acChristmasAttire:initTableView()
    self.isEnd=acChristmasAttireVoApi:acIsStop()

    self:initLayer()
end

function acChristmasAttire:resetTab()
    -- self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight-100))
    -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, self.bgLayer:getContentSize().height/2-36))
end

function acChristmasAttire:initLayer()
    local strSize=25
    if G_getCurChoseLanguage()=="ru" then
        strSize=22
    end
    local bgSize=self.bgLayer:getContentSize()
    local scale=1
    local addedH=0
    if G_isIphone5()==true then
        addedH=25
        scale=1.2
    end

    local christmasNode=CCNode:create()
    christmasNode:setAnchorPoint(ccp(0.5,0))
    christmasNode:setContentSize(CCSizeMake(592,538))
    christmasNode:setPosition(G_VisibleSizeWidth/2,140+addedH)
    self.bgLayer:addChild(christmasNode,1)
    self.christmasNode=christmasNode
    self.christmasNode:setScaleY(scale)

    local christmasNodeSize=christmasNode:getContentSize()
    local function onLoadIcon(fn,icon)
        if self and self.christmasNode then
            if self.bgLayer then
                icon:setAnchorPoint(ccp(0.5,0.5))
                self.christmasNode:addChild(icon)
                icon:setPosition(getCenterPoint(self.christmasNode))
            end
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local webImage=LuaCCWebImage:createWithURL(self.url,onLoadIcon)
    -- local icon=CCSprite:create("public/christmas2016_bg.jpg")
    -- icon:setAnchorPoint(ccp(0.5,0.5))
    -- self.christmasNode:addChild(icon)
    -- icon:setPosition(getCenterPoint(self.christmasNode))
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local goldLineSprite=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite:setAnchorPoint(ccp(0.5,1))
    goldLineSprite:setPosition(ccp(christmasNodeSize.width/2,christmasNodeSize.height))
    christmasNode:addChild(goldLineSprite,1)
    local goldLineSprite2=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite2:setAnchorPoint(ccp(0.5,1))
    goldLineSprite2:setRotation(180)
    goldLineSprite2:setPosition(ccp(christmasNodeSize.width/2,0))
    christmasNode:addChild(goldLineSprite2,1)

    local zorder=2

    local attirePointStr=getlocal("christmas_wreath").."："..acChristmasAttireVoApi:getMyPoint()
    local attirePointLb=GetTTFLabelWrap(attirePointStr,22,CCSize(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local tempLb=GetTTFLabel(attirePointStr,25)
    local lbW=tempLb:getContentSize().width
    if lbW>attirePointLb:getContentSize().width then
        lbW=attirePointLb:getContentSize().width
    end
    local pointBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    pointBg:setAnchorPoint(ccp(1,1))
    pointBg:setContentSize(CCSizeMake(lbW+40,attirePointLb:getContentSize().height+20))
    pointBg:setPosition(ccp(christmasNodeSize.width,christmasNodeSize.height-30))
    pointBg:setScaleY(1/scale)
    christmasNode:addChild(pointBg,zorder)

    attirePointLb:setPosition(pointBg:getContentSize().width/2,pointBg:getContentSize().height/2)
    pointBg:addChild(attirePointLb)
    self.attirePointLb=attirePointLb

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
    recordBtn:setScaleX(0.8)
    recordBtn:setScaleY(0.8/scale)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(christmasNodeSize.width-recordBtn:getContentSize().width*recordBtn:getScaleX(),pointBg:getPositionY()-pointBg:getContentSize().height-50))
    christmasNode:addChild(recordMenu,zorder)
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    recordBg:setAnchorPoint(ccp(0.5,1))
    recordBg:setContentSize(CCSizeMake(100,40))
    recordBg:setPosition(ccp(recordBtn:getContentSize().width/2,0))
    recordBg:setScale(1/0.8)
    recordBtn:addChild(recordBg,zorder)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width/2,recordBg:getContentSize().height/2)
    recordLb:setColor(G_ColorYellowPro)
    -- recordLb:setScaleX(1/recordBg:getScaleX())
    -- recordLb:setScaleY(1/recordBg:getScaleY())
    recordBg:addChild(recordLb)

    local cost1,cost2=acChristmasAttireVoApi:getAttireCost()
    local freeFlag=acChristmasAttireVoApi:isFreeAttire()
    local attireStr=getlocal("attire")
    if freeFlag==1 then
        attireStr=getlocal("daily_lotto_tip_2")
    end
    local function attireHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:attireHandler(1)
    end
    local attireBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",attireHandler,nil,attireStr,strSize,11)
    local attireMenu=CCMenu:createWithItem(attireBtn)
    attireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    attireMenu:setPosition(ccp(bgSize.width/2-150,70))
    self.bgLayer:addChild(attireMenu)
    self.attireBtn=attireBtn

    local attireCostNode=CCNode:create()
    attireCostNode:setAnchorPoint(ccp(0.5,0))
    attireBtn:addChild(attireCostNode)
    self.attireCostNode=attireCostNode
    local costLb=GetTTFLabel(tostring(cost1),25)
    costLb:setAnchorPoint(ccp(0,0))
    costLb:setColor(G_ColorYellowPro)
    attireCostNode:addChild(costLb)
    local costSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    costSp:setAnchorPoint(ccp(0,0))
    attireCostNode:addChild(costSp)
    local lbWidth=costLb:getContentSize().width+costSp:getContentSize().width
    attireCostNode:setContentSize(CCSizeMake(lbWidth,1))
    costLb:setPosition(ccp(0,0))
    costSp:setPosition(ccp(costLb:getContentSize().width,0))
    attireCostNode:setPosition(ccp(attireBtn:getContentSize().width/2,attireBtn:getContentSize().height))

    local function multiAttireHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:attireHandler(2)
    end
    local multiAttireBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",multiAttireHandler,nil,getlocal("multi_attire",{10}),strSize,11)
    local multiAttireMenu=CCMenu:createWithItem(multiAttireBtn)
    multiAttireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    multiAttireMenu:setPosition(ccp(bgSize.width/2+150,70))
    self.bgLayer:addChild(multiAttireMenu)
    self.multiAttireBtn=multiAttireBtn
    local multiCostNode=CCNode:create()
    multiCostNode:setAnchorPoint(ccp(0.5,0))
    multiAttireBtn:addChild(multiCostNode)
    local multiCostLb=GetTTFLabel(tostring(cost2),25)
    multiCostLb:setAnchorPoint(ccp(0,0))
    multiCostLb:setColor(G_ColorYellowPro)
    multiCostNode:addChild(multiCostLb)
    local multiCostSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    multiCostSp:setAnchorPoint(ccp(0,0))
    multiCostNode:addChild(multiCostSp)
    local lbWidth=multiCostLb:getContentSize().width+multiCostSp:getContentSize().width
    multiCostNode:setContentSize(CCSizeMake(lbWidth,1))
    multiCostLb:setPosition(ccp(0,0))
    multiCostSp:setPosition(ccp(multiCostLb:getContentSize().width,0))
    multiCostNode:setPosition(ccp(multiAttireBtn:getContentSize().width/2,multiAttireBtn:getContentSize().height))

    self:refreshAttireBtn()

    local function callback( ... )
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,christmasNodeSize.height*scale),nil)
    self.tv:setPosition(ccp(15,140+addedH))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(0)

    local tipStr=getlocal("christmas2016_exchange_pro")
    local tipLb=GetTTFLabelWrap(tipStr,23,CCSize(christmasNodeSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local tipLb2=GetTTFLabel(tipStr,23)
    local tipLbW=tipLb2:getContentSize().width
    if tipLbW>tipLb:getContentSize().width then
        tipLbW=tipLb:getContentSize().width
    end
    local tipBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    tipBg:setAnchorPoint(ccp(0.5,0))
    tipBg:setContentSize(CCSizeMake(tipLbW+40,tipLb:getContentSize().height+10))
    tipBg:setPosition(ccp(christmasNodeSize.width/2,30))
    tipBg:setOpacity(150)
    tipBg:setScaleY(1/scale)
    christmasNode:addChild(tipBg,zorder)
    tipLb:setPosition(tipBg:getContentSize().width/2,tipBg:getContentSize().height/2)
    tipLb:setColor(G_ColorYellowPro)
    tipBg:addChild(tipLb)
end

function acChristmasAttire:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.christmasNode:getContentSize().width,self.christmasNode:getContentSize().height*self.christmasNode:getScaleY())
        -- return  self.christmasNode:getContentSize()
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        self:initChristmasTree(cell)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acChristmasAttire:initChristmasTree(parent)
    if parent==nil then
        do return end
    end
    self.materialSpTb={}
    local addy=0
    if G_isIphone5() then
        addy=65
    end
    local posCfg={{262,113},{296,179},{296,245},{327,311},{361,377},{361,443}}
    local materialCfg=acChristmasAttireVoApi:getMaterialNumCfg()
    local floorCount=SizeOfTable(materialCfg)
    local materials=acChristmasAttireVoApi:getMaterials()
    local flick=acChristmasAttireVoApi:getFlick()
    local flickScale=1.3
    local mIdx=0
    local zorder=2
    for k,num in pairs(materialCfg) do
        local posX,posY
        if posCfg[k] and posCfg[k][1] and posCfg[k][2] then
            posX=posCfg[k][1]
            posY=posCfg[k][2]+addy
        end
        self.materialSpTb[k]={}        
        if posX and posY then
            for i=1,num do
                local pngName=acChristmasAttireVoApi:getMaterialPic(k,i)
                local spBg=CCSprite:createWithSpriteFrameName("material_bg.png")
                spBg:setPosition(ccp(posX,posY))
                spBg:setScale(52/spBg:getContentSize().width)
                parent:addChild(spBg,zorder)
                local snowSp=CCSprite:createWithSpriteFrameName("snowFrame.png")
                snowSp:setAnchorPoint(ccp(0.5,1))
                snowSp:setPosition(ccp(spBg:getContentSize().width/2,spBg:getContentSize().height+15))
                -- snowSp:setScale(52/snowSp:getContentSize().width)
                spBg:addChild(snowSp,zorder)
                
                self.materialSpTb[k][i]=spBg
                local count=0
                if materials and materials[k] and materials[k][i] then
                    count=materials[k][i]
                end
                local materialSp
                if count==0 then
                    materialSp=GraySprite:createWithSpriteFrameName(pngName)
                else                    
                    materialSp=CCSprite:createWithSpriteFrameName(pngName)
                end
                if materialSp then
                    materialSp:setPosition(getCenterPoint(spBg))
                    spBg:addChild(materialSp)
               
                    local numLb=GetTTFLabel(FormatNumber(count),22)
                    numLb:setAnchorPoint(ccp(1,0))
                    numLb:setPosition(spBg:getContentSize().width-10,0)
                    numLb:setScale(1/spBg:getScale())
                    spBg:addChild(numLb,4)
                    local numBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg.png")
                    numBg:setAnchorPoint(ccp(0.5,0))
                    local scaleX=spBg:getContentSize().width/numBg:getContentSize().width
                    local scaleY=1/spBg:getScale()*(numLb:getContentSize().height-5)/numBg:getContentSize().height
                    numBg:setScaleX(scaleX)
                    numBg:setScaleY(scaleY)
                    numBg:setPosition(ccp(spBg:getContentSize().width/2,5))
                    numBg:setOpacity(150)
                    spBg:addChild(numBg,3)

                    if flick[k] and flick[k]==1 then
                        G_addRectFlicker(spBg,flickScale,flickScale,ccp(spBg:getContentSize().width/2,spBg:getContentSize().height/2))
                    end
                end
                posX=posX+spBg:getContentSize().width*spBg:getScale()+20
            end
        end
        local lineSp=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
        lineSp:setAnchorPoint(ccp(0,0))
        lineSp:setScaleX((G_VisibleSizeWidth-300)/lineSp:getContentSize().width)
        lineSp:setPosition(ccp(20,posY-35))
        parent:addChild(lineSp,zorder)

        local function touchReward(object,name,tag)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
       
            local function realExchange()
                local function callback(flag)
                    self:refresh()
                    if self.materialSpTb[tag] then
                        local materialSpTb=self.materialSpTb[tag]
                        local rewardSp=tolua.cast(materialSpTb[1]:getParent():getChildByTag(tag),"LuaCCSprite")
                        self:playExchangeEffect(rewardSp)
                        for k,materialSp in pairs(materialSpTb) do
                            self:playExchangeEffect(materialSp)
                        end
                    end
                    local resultStr=getlocal("allianceShop_buySuccess")
                    if flag==true then --是否兑换消耗增加
                        resultStr=getlocal("exchange_result")
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),resultStr,30)
                    --兑换最高层时给出公告
                    local materialCfg=acChristmasAttireVoApi:getMaterialNumCfg()
                    local floorCount=SizeOfTable(materialCfg)
                    if tag==floorCount then
                        acChristmasAttireVoApi:sendRewardNotice(1)
                    end
                end
                acChristmasAttireVoApi:christmasRequest("active.christmas2016.reward",{tag},callback) 
            end
            local titleStr=getlocal("christmasTreeReward",{tag})
            require "luascript/script/game/scene/gamedialog/activityAndNote/acChristmasAttireSmallDialog"
            acChristmasAttireSmallDialog:showExchangeDialog("TankInforPanel.png",CCSizeMake(550,500),CCRect(130, 50, 1, 1),titleStr,tag,false,self.layerNum+1,realExchange)
        end
        local scale=0.6
        local lightScale=0.6
        local giftPic="friendBtn.png"
        if k==floorCount then
            giftPic="mainBtnGift.png"
            scale=1
            lightScale=0.8
        end
        local rewardSp=LuaCCSprite:createWithSpriteFrameName(giftPic,touchReward)
        rewardSp:setTouchPriority(-(self.layerNum-1)*20-5)
        rewardSp:setAnchorPoint(ccp(0.5,0.5))
        rewardSp:setPosition(80,posY-30+rewardSp:getContentSize().height*scale/2)
        rewardSp:setTag(k)
        parent:addChild(rewardSp,zorder)
        rewardSp:setScale(scale)
        local flag=acChristmasAttireVoApi:isCanExchange(k)
        if flag==true then
            local spx=rewardSp:getPositionX()
            local spy=posY-30+rewardSp:getContentSize().height*rewardSp:getScale()/2
            local guangSp1=CCSprite:createWithSpriteFrameName("equipShine.png")
            guangSp1:setPosition(ccp(spx,spy))
            parent:addChild(guangSp1)
            local guangSp2=CCSprite:createWithSpriteFrameName("equipShine.png")
            guangSp2:setPosition(ccp(spx,spy))
            parent:addChild(guangSp2)
            guangSp1:setScale(lightScale)
            guangSp2:setScale(lightScale)
            local rotateBy=CCRotateBy:create(4,360)
            local reverseBy=rotateBy:reverse()
            guangSp1:runAction(CCRepeatForever:create(rotateBy))
            guangSp2:runAction(CCRepeatForever:create(reverseBy))
            --晃动宝箱
            self:addShakeEffect(rewardSp)
        else
            local needBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
            needBg:setAnchorPoint(ccp(0.5,0))
            needBg:setContentSize(CCSizeMake(100,30))
            needBg:setPosition(ccp(rewardSp:getContentSize().width/2,0))
            needBg:setScale(1/rewardSp:getScale())
            rewardSp:addChild(needBg)
            local needStr=""
            local needNum=acChristmasAttireVoApi:getExchangeNeed(k)
            if num==1 then
                needStr=getlocal("material_need",{needNum})
            else
                needStr=getlocal("each_material_need",{needNum})
            end
            local needLb=GetTTFLabelWrap(needStr,20,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            needLb:setPosition(needBg:getContentSize().width/2,needBg:getContentSize().height/2)
            needLb:setColor(G_ColorWhite)
            needBg:addChild(needLb)
        end
    end
end

function acChristmasAttire:addShakeEffect(target)
    if target==nil then
        do return end
    end

    local time=0.1
    local rotate1=CCRotateTo:create(time,30)
    local rotate2=CCRotateTo:create(time,-30)
    local rotate3=CCRotateTo:create(time,20)
    local rotate4=CCRotateTo:create(time,-20)
    local rotate5=CCRotateTo:create(time,0)
    local delay=CCDelayTime:create(1)
    local acArr=CCArray:create()
    acArr:addObject(rotate1)
    acArr:addObject(rotate2)
    acArr:addObject(rotate3)
    acArr:addObject(rotate4)
    acArr:addObject(rotate5)
    acArr:addObject(delay)
    local seq=CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
    target:runAction(repeatForever)
end

function acChristmasAttire:refreshAttireBtn()
   if self.isEnd==true then
        self.attireBtn:setEnabled(false)
        self.multiAttireBtn:setEnabled(false)
        do return end
    end
    if self.attireBtn and self.multiAttireBtn and self.attireCostNode then
        local freeFlag=acChristmasAttireVoApi:isFreeAttire()
        local btnLb=tolua.cast(self.attireBtn:getChildByTag(11),"CCLabelTTF")
        if btnLb then
            if freeFlag==1 then
                btnLb:setString(getlocal("daily_lotto_tip_2"))
                self.attireCostNode:setVisible(false)
                self.multiAttireBtn:setEnabled(false)
            else
                btnLb:setString(getlocal("attire"))
                self.attireCostNode:setVisible(true)
                self.multiAttireBtn:setEnabled(true)
            end
        end
    end
end

function acChristmasAttire:attireHandler(attireType)
    local num=1
    if tonumber(attireType)==1 then
        num=1
    elseif tonumber(attireType)==2 then
        num=10
    end
    local function realAttire(attireNum,cost)
        local function callback(lotteryFlag,rewardlist,attireTab,score,crit)
            if lotteryFlag==false then
                self:removeForbidLayer()
                do return end
            end
            if rewardlist and type(rewardlist)=="table" then
                if cost and tonumber(cost)>0 then
                    playerVoApi:setValue("gems",playerVoApi:getGems()-tonumber(cost))
                end
                local function showRewards()
                    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"    
                    local titleStr=""
                    if crit and crit>0 then
                        titleStr=getlocal("surprise_lucky")..getlocal("multi_attire2",{tonumber(attireNum)+tonumber(crit)})
                    else
                        titleStr=getlocal("multi_attire2",{attireNum})
                    end
                    local content={}
                    for k,v in pairs(rewardlist) do
                        table.insert(content,{award=v})                        
                    end
                    local rewardPromptStr=getlocal("activity_xuyuanlu_getGolds",{score..getlocal("christmas_wreath")})
                    acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog("TankInforPanel.png",CCSizeMake(550,560),CCRect(130,50,1,1),titleStr,rewardPromptStr,heroExistStr,content,false,self.layerNum+1,nil,getlocal("confirm"),nil,nil,nil,nil,true,false)

                    self.attireCallBack=nil
                end
                self.attireCallBack=showRewards
                local function speedUp()
                    self:removeAttireEffect()
                    if self.attireCallBack then
                        self.attireCallBack()
                    end
                end
                self:playAttireEffect(attireNum,attireTab,showRewards,speedUp)   
            end
            self:removeForbidLayer()
            self:refresh()
            self:refreshAttireBtn()
        end
        local freeFlag=acChristmasAttireVoApi:isFreeAttire()
        acChristmasAttireVoApi:christmasRequest("active.christmas2016",{freeFlag,attireNum},callback)
        self:addForbidLayer()
    end
    local cost1,cost2=acChristmasAttireVoApi:getAttireCost()
    local cost=0
    local freeFlag=acChristmasAttireVoApi:isFreeAttire()
    if cost1 and cost2 then
        if attireType==1 and freeFlag==0 then
            cost=cost1
        elseif attireType==2 then
            cost=cost2
        end
    end
    if playerVoApi:getGems()<cost then
        GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
        do return end
    else
        realAttire(num,cost)
    end
end

function acChristmasAttire:recordHandler()
    local function callback()
        local function showNoRecord()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_huoxianmingjiang_log_tip0"),30)
        end
        local recordTab=acChristmasAttireVoApi:getRecordList()
        local rc=SizeOfTable(recordTab)
        if rc==0 then
            showNoRecord()
            do return end
        end
        local record={}
        for k,v in pairs(recordTab) do
            reward=v.r
            reward=FormatItem(reward)
            local colorTb={}
            local num=v.n or 0
            local desc=getlocal("multi_attire",{num})
            if v.c and v.c>0 then
                desc=desc.."，"..getlocal("extra_get",{v.c})
                colorTb={G_ColorYellowPro}
            end
            table.insert(record,{award=reward,time=v.t,desc=desc,colorTb=colorTb})
        end
        local recordCount=SizeOfTable(record)
        if recordCount==0 then
            showNoRecord()
            do return end
        end
        local recordNum=10
        local function confirmHandler()
        end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
        acMingjiangpeiyangSmallDialog:showRewardsRecordDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),getlocal("activity_customLottery_RewardRecode"),record,false,self.layerNum+1,confirmHandler,true,recordNum)
    end
    local flag=acChristmasAttireVoApi:getRequestLogFlag()
    if flag==false then
        acChristmasAttireVoApi:christmasRequest("active.christmas2016.report",nil,callback)
    else
        callback()
    end
end

function acChristmasAttire:refresh()
    if self.attirePointLb then
        local point=acChristmasAttireVoApi:getMyPoint()
        local attirePointStr=getlocal("christmas_wreath").."："..point
        self.attirePointLb:setString(attirePointStr)
    end
    if self.tv then
        self.tv:reloadData()
    end
end

function acChristmasAttire:updateUI()
    self:refresh()
end

function acChristmasAttire:addForbidLayer()
    if self.forbidLayer==nil then
        local function touch( ... )
        end
        forbidLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
        forbidLayer:setTouchPriority(-(self.layerNum-1)*20-8)
        forbidLayer:setContentSize(G_VisibleSize)
        forbidLayer:setOpacity(0)
        forbidLayer:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(forbidLayer,10)
        self.forbidLayer=forbidLayer
    end
end

function acChristmasAttire:removeForbidLayer()
    if self.forbidLayer then
        self.forbidLayer:removeFromParentAndCleanup(true)
        self.forbidLayer=nil
    end
end

function acChristmasAttire:playAttireEffect(attireNum,attireTab,endCallback,speedUp)
    if self.actionLayer then
        do return end
    end
    local function removeAction()
        if speedUp then
            speedUp()
        end
    end
    local actionLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),removeAction)
    actionLayer:setTouchPriority(-(self.layerNum-1)*20-8)
    actionLayer:setContentSize(G_VisibleSize)
    actionLayer:setOpacity(120)
    actionLayer:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(actionLayer,10)
    self.actionLayer=actionLayer

    local actime=0.3
    local totalTime=0
    local delayTime=0
    local spaceTime=0.2
    for k,v in pairs(attireTab) do
        if self.materialSpTb and self.materialSpTb[v[1]] and self.materialSpTb[v[1]][v[2]] then
            local isDelay=false
            if k>=2 then
                isDelay=true
            end
            delayTime=delayTime+spaceTime
            local materialSp=self.materialSpTb[v[1]][v[2]]
            local targetPos=materialSp:convertToWorldSpaceAR(ccp(0,0))
            local function dropMaterial(target,isDelay)
                if target then
                    local acArr=CCArray:create()
                    if isDelay and isDelay==true then
                        local delay=CCDelayTime:create(delayTime)
                        acArr:addObject(delay)
                    end
                    local out=CCScaleTo:create(0.2,1)
                    local effect=CCEaseBounceInOut:create(out)
                    acArr:addObject(effect)
                    local moveTo=CCMoveTo:create(actime,targetPos)
                    local scaleTo=CCScaleTo:create(actime,0.5)
                    local spwanArr=CCArray:create()
                    spwanArr:addObject(moveTo)
                    spwanArr:addObject(scaleTo)
                    local swpanAc=CCSpawn:create(spwanArr)
                    acArr:addObject(swpanAc)
                    local subseq=CCSequence:create(acArr)
                    target:runAction(subseq)                    
                end
            end
            local pngName=acChristmasAttireVoApi:getMaterialPic(v[1],v[2])
            local targetSp=CCSprite:createWithSpriteFrameName(pngName)
            if targetSp==nil then
                do break end
            end
            local posX=0
            local posY=0
            if attireNum==1 then
                posX=self.bgLayer:getContentSize().width/2-150
                posY=140
            else
                posX=self.bgLayer:getContentSize().width/2+150
                posY=140
            end
            targetSp:setScale(0)
            targetSp:setPosition(ccp(posX,posY))
            actionLayer:addChild(targetSp,2)
            dropMaterial(targetSp,isDelay)
            for i=1,2 do
                local guangSp=CCSprite:createWithSpriteFrameName("equipShine.png")
                guangSp:setPosition(ccp(targetSp:getPositionX(),targetSp:getPositionY()))
                actionLayer:addChild(guangSp)
                guangSp:setScale(0)
                -- guangSp:setScale(0.8)
                dropMaterial(guangSp,isDelay)
            end
        end
    end
    local function actionEndHandler()
        if self.actionLayer then
            self.actionLayer:removeFromParentAndCleanup(true)
            self.actionLayer=nil
        end
        if endCallback then
            endCallback()
        end
    end
    totalTime=totalTime+delayTime+actime+0.4
    local acArr=CCArray:create()
    local delay=CCDelayTime:create(totalTime)
    local funcCall=CCCallFuncN:create(actionEndHandler)
    acArr:addObject(delay)
    acArr:addObject(funcCall)
    local subseq=CCSequence:create(acArr)
    self.actionLayer:runAction(subseq)
end

function acChristmasAttire:removeAttireEffect()
    if self.actionLayer then
        self.actionLayer:stopAllActions()
        self.actionLayer:removeFromParentAndCleanup(true)
        self.actionLayer=nil
    end
end

function acChristmasAttire:playExchangeEffect(parent)
    if parent==nil then
        do return end
    end
    local lineSp=CCParticleSystemQuad:create("public/hero/equipLine.plist")
    lineSp.positionType=kCCPositionTypeFree
    lineSp:setPosition(ccp(parent:getContentSize().width/2,0))
    lineSp:setScaleX(1.2)
    parent:addChild(lineSp,3)
    local function removeLine()
        if lineSp then
            lineSp:stopAllActions()
            lineSp:removeFromParentAndCleanup(true)
            lineSp=nil
            self.isPlaying=false
            if callback then
                callback()
            end
        end
    end
    local mvTo1=CCMoveBy:create(0.35,ccp(0,parent:getContentSize().height))
    local fc1=CCCallFunc:create(removeLine)
    local carray1=CCArray:create()
    carray1:addObject(mvTo1)
    carray1:addObject(fc1)
    local seq1=CCSequence:create(carray1)
    lineSp:runAction(seq1)

    local starSp=CCParticleSystemQuad:create("public/hero/equipStar.plist")
    starSp.positionType=kCCPositionTypeFree
    starSp:setPosition(ccp(parent:getContentSize().width/2,0))
    -- starSp:setScale(1/parent:getScale())
    starSp:setScaleX(1.2)

    parent:addChild(starSp,3)
    local function removeStar()
        if starSp then
            starSp:stopAllActions()
            starSp:removeFromParentAndCleanup(true)
            starSp=nil
        end
    end
    local mvTo2=CCMoveBy:create(0.5,ccp(0,parent:getContentSize().height))
    local fc2= CCCallFunc:create(removeStar)
    local carray2=CCArray:create()
    carray2:addObject(mvTo2)
    carray2:addObject(fc2)
    local seq2=CCSequence:create(carray2)
    starSp:runAction(seq2)
end

function acChristmasAttire:tick()
    local isEnd=acChristmasAttireVoApi:acIsStop()
    if isEnd~=self.isEnd and isEnd==true then
        self.isEnd=isEnd
        if self.attireBtn and self.multiAttireBtn then
            self.attireBtn:setEnabled(false)
            self.multiAttireBtn:setEnabled(false)  
        end
    end
    if isEnd==false then
        local todayFlag=acChristmasAttireVoApi:isToday()
        if self.isTodayFlag==true and todayFlag==false then
            self.isTodayFlag=false
            --重置免费次数
            acChristmasAttireVoApi:resetFreeAttire()
            self:refreshAttireBtn()
        end
    end
end

function acChristmasAttire:dispose()
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.forbidLayer=nil
    self.actionLayer=nil
    self.isEnd=false
    self.attireBtn=nil
    self.multiAttireBtn=nil
    self.attireCostNode=nil
    self.christmasNode=nil
    self.attireCallBack=nil
    self.isTodayFlag=true
    self.materialSpTb=nil
end