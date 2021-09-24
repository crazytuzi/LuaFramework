heroSmeltDialog = commonDialog:new()

function heroSmeltDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.listNum=1
    self.propTb={}
    self.count=0
    self.currentPropNumTb   ={}
    self.currentPropNumBgTb ={}
    self.currentPropTb      ={}
    self.currentUseNumTb    ={}
     CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/acPjjnh.plist")
    spriteController:addTexture("public/acPjjnh.png")
    return nc
end

function heroSmeltDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
end

function heroSmeltDialog:initTableView( )
end

function heroSmeltDialog:doUserHandler()
    self:addListBtn()
    self:addBg()
    self:addTouchBtn()
    self:addListProp()
    self:addSlider()
end

function heroSmeltDialog:refreshSliderData( )
    if self.slider and self.count and self.m_numLb then
        local keepInitNum,keepLimitNum = self:getLargestPropUseNum()
        self.slider:setMinimumValue(keepInitNum);
        self.slider:setMaximumValue(keepLimitNum);
        self.slider:setValue(keepInitNum);
        self.count = keepInitNum
        self.m_numLb:setString(math.ceil(self.slider:getValue()))
    end
end
function heroSmeltDialog:addSlider( )
    local keepInitNum,keepLimitNum = self:getLargestPropUseNum()

    local m_numLb=GetTTFLabel(" ",30)
    self.bgLayer:addChild(m_numLb,2);

    local function sliderTouch(handler,object)
          -- local valueNum = tonumber(string.format("%.2f", object:getValue()))
          local count = math.ceil(object:getValue())
          self.count = count
          -- print("count====>>>>>",count)
          if count >= 0 then
              m_numLb:setString(count)
              for k,v in pairs(self.currentPropNumTb) do
                    if v then
                        v:setString(count)
                    end
              end
              for k,v in pairs(self.currentUseNumTb) do
                    if k and v then
                        local rewardItem = self.propItem[k]
                        local totalNum   = bagVoApi:getItemNumId(rewardItem.id)
                        self:refreshLbColor(k,totalNum,count * v)
                    end
              end
          end  
          self:setCostLbAndItem()
    end
    local sliderScale = 0.8
    local spBg =CCSprite:createWithSpriteFrameName("proBar_n2.png");
    local spPr =CCSprite:createWithSpriteFrameName("proBar_n1.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("grayBarBtn.png");--ProduceTankIconSlide
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(self.layerNum-1)*20-5);
    self.slider:setIsSallow(true);
    self.slider:setScale(sliderScale)
    self.slider:setMinimumValue(keepInitNum);

    self.slider:setTag(99)
    self.bgLayer:addChild(self.slider,2)
    m_numLb:setString(math.ceil(self.slider:getValue()))
    m_numLb:setScale(sliderScale)
    self.m_numLb=m_numLb

    local bgSp = CCSprite:createWithSpriteFrameName("proBar_n2.png");
    bgSp:setScaleX(85/bgSp:getContentSize().width * sliderScale)
    bgSp:setAnchorPoint(ccp(0.5,0.5));
    self.bgLayer:addChild(bgSp,1);

    local function touchAdd()
       if self.slider:getValue()+1 < 100 then
           self.slider:setValue(self.slider:getValue()+1);
       end
    end

    local function touchMinus()
      if self.slider:getValue()-1>0 then
          self.slider:setValue(self.slider:getValue()-1);
      end
    end

    local addSp=LuaCCSprite:createWithSpriteFrameName("greenPlus.png",touchAdd)
    self.bgLayer:addChild(addSp,1)
    addSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local minusSp=LuaCCSprite:createWithSpriteFrameName("greenMinus.png",touchMinus)
    self.bgLayer:addChild(minusSp,1)
    minusSp:setTouchPriority(-(self.layerNum-1)*20-5);

    local sliderPosY = 490
    if G_getIphoneType() == G_iphoneX then
        sliderPosY = 555
    elseif not G_isIphone5() then
        sliderPosY = 370
    end

    local sliderAddPosx2 = 20
    local sliderAddPosx3 = 50

    self.slider:setPosition(ccp(340 * sliderScale + sliderAddPosx2 + sliderAddPosx3,sliderPosY))
    addSp:setPosition(ccp(560 * sliderScale + sliderAddPosx2 + sliderAddPosx3,sliderPosY))
    minusSp:setPosition(ccp(125 * sliderScale + sliderAddPosx2 + sliderAddPosx3,sliderPosY))
    
    bgSp:setPosition(75 * sliderScale + sliderAddPosx3,sliderPosY);
    m_numLb:setPosition(75 * sliderScale + sliderAddPosx3,sliderPosY);
    -- bgSp:setVisible(false)
    -- m_numLb:setVisible(false)

    self.slider:setMaximumValue(keepLimitNum);
    self.slider:setValue(keepInitNum);
    self.count = keepInitNum
end

function heroSmeltDialog:addListBtn()
    local listNum=SizeOfTable(heroSmeltCfg.prop1)
    self.listBtnTb={}
    self.totalListNum=listNum
    local function onSelectQuality(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if self.listNum==tag then
            return
        end
        PlayEffect(audioCfg.mouseClick)
        self.listNum=tag

        for k,v in pairs(self.listBtnTb) do
            if(k~=tag)then
                v:setColor(G_ColorGray)
                v:setScale(1)
            else
                v:setColor(G_ColorWhite)
                v:setScale(1.1)
            end
        end
        
        self:clearCurrentProp()
        self:addListProp()
    end

    local strTb={getlocal("hero_smelt_lb1"),getlocal("hero_smelt_lb2"),getlocal("daily_lotto_tip_6"),getlocal("purifying_expert"),getlocal("purifying_master")}
    local listbtnH=G_VisibleSizeHeight-140
    if(G_isIphone5()==false)then
        listbtnH=G_VisibleSizeHeight-130
    end

    for i=1,listNum do
        local tabBtn=LuaCCSprite:createWithSpriteFrameName("hero_smelt_btn".. i ..".png",onSelectQuality)
        tabBtn:setTag(i)
        tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        tabBtn:setPosition(G_VisibleSizeWidth/(listNum+1)*i,listbtnH)
        self.bgLayer:addChild(tabBtn,1)
        self.listBtnTb[i]=tabBtn
        if(i==self.listNum)then
            tabBtn:setScale(1.1)
        else
            tabBtn:setColor(G_ColorGray)
        end

        local titleLb=GetTTFLabel(strTb[i], 24, true)
        tabBtn:addChild(titleLb)
        titleLb:setPosition(tabBtn:getContentSize().width/2,-titleLb:getContentSize().height/2)
    end


end

function heroSmeltDialog:addBg()

    local sceneSpH=G_VisibleSizeHeight-230
    if(G_isIphone5()==false)then
        sceneSpH=G_VisibleSizeHeight-215
    end

    local sceneSp = LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),function ()end)
    sceneSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,sceneSpH))
    sceneSp:setAnchorPoint(ccp(0,0))
    sceneSp:setPosition(ccp(20,20))
    sceneSp:setTouchPriority(-(self.layerNum-1)*20-1)
    self.bgLayer:addChild(sceneSp)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local bigBg=CCSprite:create("public/emblem/emblemBlackBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    bigBg:setScaleY((sceneSpH-10)/bigBg:getContentSize().height)
    bigBg:setScaleX((G_VisibleSizeWidth - 60)/bigBg:getContentSize().width)
    bigBg:setAnchorPoint(ccp(0,0))
    bigBg:setPosition(ccp(30,25))
    self.bgLayer:addChild(bigBg)

    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setPosition(ccp(25,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(leftFrameBg1)
    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setPosition(ccp(self.bgLayer:getContentSize().width-25,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(rightFrameBg1)

    local blueBgH = 390
    local adaptHeight = 110
    if G_getIphoneType() == G_iphoneX then
        blueBgH = 400
        adaptHeight = 160
    elseif G_getIphoneType() == G_iphone5 then
        blueBgH=300
    end
    local blueBg=LuaCCScale9Sprite:createWithSpriteFrameName("dwEndBg1.png",CCRect(0,0,126,126),function ()end)
    blueBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 60,blueBgH))
    -- blueBg:setAnchorPoint(ccp(0.5,0))
    blueBg:setPosition(G_VisibleSizeWidth/2,adaptHeight+blueBgH/2)
    self.bgLayer:addChild(blueBg)
    -- hero_smelt_greenLine

    local greenLine1=CCSprite:createWithSpriteFrameName("hero_smelt_greenLine.png")
    greenLine1:setPosition(G_VisibleSizeWidth/2,adaptHeight+blueBgH-30)
    self.bgLayer:addChild(greenLine1)
    greenLine1:setRotation(180)
    local greenLine2=CCSprite:createWithSpriteFrameName("hero_smelt_greenLine.png")
    greenLine2:setPosition(G_VisibleSizeWidth/2,adaptHeight+35)
    self.bgLayer:addChild(greenLine2)

    --iphone型号适配
    if (G_getIphoneType() == G_iphoneX) then
        self.addH = 210
    elseif (G_getIphoneType() == G_iphone5) then
        self.addH = 130
    else
        self.addH = 0
    end
    
    -- 圈1
    local diBg1=CCSprite:createWithSpriteFrameName("hero_smelt_di1.png")
    diBg1:setPosition(323, 557+self.addH)
    self.bgLayer:addChild(diBg1)
    self.diBg1=diBg1
    local diBgSize1=diBg1:getContentSize()
    local x1,y1=diBg1:getPosition()
    local subx1=x1-diBgSize1.width/2
    local suby1=y1-diBgSize1.height/2
    self.centerPos1=ccp(x1,y1)

    self.quanTb1={ccp(324, 705.5+self.addH),ccp(464.5, 600.5+self.addH),ccp(413, 438+self.addH),ccp(234.5, 437.5+self.addH ),ccp(180, 600+self.addH)}
    -- self.propPosTb1={}
    local arcTb1={ccp(398, 669+self.addH),ccp(451.5, 519+self.addH ),ccp(324.5, 422+self.addH),ccp(195, 518+self.addH),ccp(252, 672+self.addH)}
    local lineTb1={ccp(325, 662.5+self.addH),ccp(428, 589.5+self.addH),ccp(388, 468.5+self.addH),ccp(261, 467.5+self.addH),ccp(222, 591.5+self.addH)}

    self.quanSpTb1={}
    for k,v in pairs(self.quanTb1) do
        local quanSp=CCSprite:createWithSpriteFrameName("hero_smelt_quan.png")
        self.bgLayer:addChild(quanSp,2)
        quanSp:setPosition(v)
        self.quanSpTb1[k]=quanSp
        -- self.propPosTb1[k]=ccp(subx1+v.x,suby1+v.y)
    end

    -- 圈1 的弧线
    self.arcSpTb1={}
    self.lineSpTb1={}
    for k,v in pairs(arcTb1) do
        local arcSp=CCSprite:createWithSpriteFrameName("hero_smelt_hu1.png")
        self.bgLayer:addChild(arcSp)
        arcSp:setPosition(v)
        arcSp:setVisible(false)
       
        arcSp:setScaleY(1.1)
        
        self.arcSpTb1[k]=arcSp

        local lineSp=CCSprite:createWithSpriteFrameName("acPjjnh_line.png")
        self.bgLayer:addChild(lineSp)
        lineSp:setPosition(lineTb1[k])
        lineSp:setVisible(false)
        self.lineSpTb1[k]=lineSp
        lineSp:setScaleX(0.6)

        if k==1 then
            arcSp:setRotation(-146)
            lineSp:setRotation(90)
        elseif k==2 then
            arcSp:setRotation(-74)
            lineSp:setRotation(72+90)
        elseif k==3 then
            -- arcSp:setRotation(7)
            lineSp:setRotation(72-18)
        elseif k==4 then
            arcSp:setRotation(76)
            lineSp:setRotation(-72+18)
        elseif k==5 then
            arcSp:setRotation(150)
            lineSp:setRotation(-72+90)
        end

    end

    -- 圈2
    local diBg2=CCSprite:createWithSpriteFrameName("hero_smelt_di2.png")
    diBg2:setPosition(321, 558.5+self.addH)
    self.bgLayer:addChild(diBg2)
    self.diBg2=diBg2
    diBg2:setVisible(false)
    -- 321, 637

    local diBgSize2=diBg2:getContentSize()
    local x2,y2=diBg2:getPosition()
    local subx2=x2-diBgSize2.width/2
    local suby2=y2-diBgSize2.height/2
    self.centerPos2=ccp(321, 637+self.addH)

    self.quanTb2={ccp(466.5, 469.5+self.addH),ccp(176.5, 468.5+self.addH)}
    -- self.propPosTb2={}
    self.quanSpTb2={}
    local arcTb2={ccp(322.5, 435.5+self.addH )}
    local lineTb2={ccp(411.5, 524.5+self.addH),ccp(233.5, 524.5+self.addH)}

    for k,v in pairs(self.quanTb2) do
        local quanSp=CCSprite:createWithSpriteFrameName("hero_smelt_quan.png")
        self.bgLayer:addChild(quanSp,3)
        quanSp:setPosition(v)
        quanSp:setScale(1.2)
        quanSp:setVisible(false)
        -- self.propPosTb2[k]=ccp(subx2+v.x,suby2+v.y)
        self.quanSpTb2[k]=quanSp
    end

    -- 圈2 的弧线
    self.arcSpTb2={}
    for k,v in pairs(arcTb2) do
        local arcSp=CCSprite:createWithSpriteFrameName("hero_smelt_hu2.png")
        self.bgLayer:addChild(arcSp)
        arcSp:setVisible(false)
        arcSp:setPosition(v)
        self.arcSpTb2[k]=arcSp
    end

    self.lineSpTb2={}
    for k,v in pairs(lineTb2) do
        local lineSp=CCSprite:createWithSpriteFrameName("acPjjnh_line.png")
        self.bgLayer:addChild(lineSp,2)
        lineSp:setVisible(false)
        lineSp:setPosition(v)
        lineSp:setScaleX(1.6)
        self.lineSpTb2[k]=lineSp
        if k==1 then
            lineSp:setRotation(72-25)
        else
            lineSp:setRotation(132)
        end
    end

end

function heroSmeltDialog:setBg1OrBg2(flag)
    
    local flag2=true
    if flag==true then
        flag2=false
    end
    self.diBg1:setVisible(flag)
    self.diBg2:setVisible(flag2)
    for k,v in pairs(self.quanSpTb1) do
        v:setVisible(flag)
    end
    for k,v in pairs(self.arcSpTb1) do
        v:setVisible(false)
    end
    for k,v in pairs(self.lineSpTb1) do
        v:setVisible(false)
    end

    for k,v in pairs(self.quanSpTb2) do
        v:setVisible(flag2)
    end
    for k,v in pairs(self.arcSpTb2) do
        v:setVisible(false)
    end
    for k,v in pairs(self.lineSpTb2) do
        v:setVisible(false)
    end
end


function heroSmeltDialog:addListProp()
    local strSize2 = 11
    local strWidth2 = 140
    if G_isAsia() then
        strSize2 = 20
        strWidth2 =150
        if not G_isIOS() and G_getCurChoseLanguage() == "ja" then
            strSize2 = 14
        end
    end
    
    for k,v in pairs(self.propTb) do
        v:removeFromParentAndCleanup(true)
        self.propTb[k]=nil -- 级别
    end
    if self.listNum==SizeOfTable(heroSmeltCfg.prop1) then
        -- self.diBg1:setVisible(false)
        -- self.diBg2:setVisible(true)
        self.posTb1=self.quanTb2
        self.arcSpTb=self.arcSpTb2
        self.lineSpTb=self.lineSpTb2
        self:setBg1OrBg2(false)
        self.menuItem1:setPositionX(self.menuItem1:getPositionX()+150)
        self.menuItem2:setVisible(false)
        self.menuItem2:setEnabled(false)
    else
        -- self.diBg1:setVisible(true)
        -- self.diBg2:setVisible(false)
        self.posTb1=self.quanTb1
        self.arcSpTb=self.arcSpTb1
        self.lineSpTb=self.lineSpTb1
        self:setBg1OrBg2(true)
        self.menuItem1:setPositionX(-156)
        self.menuItem2:setVisible(true)
        self.menuItem2:setEnabled(true)
    end

    if self.centerSp then
        self.centerSp:removeFromParentAndCleanup(true)
        self.centerSp=nil
    end
    
    self:setCostLbAndItem()
    -- self:refreshArcAndLineSp()
    self.currentUseNumTb={}
    self.propItem={}
    local listProp=heroSmeltCfg.prop1[self.listNum]
    local propNum=SizeOfTable(listProp)
    local firstPosX=60
    local iconWidth=100
    local spaceX=(self.bgSize.width-2*firstPosX-4*100)/3
    local posY=350

    local iconSize=100
    local subH=50
    if (G_getIphoneType() == G_iphoneX) then
        posY = 400
    elseif (G_isIphone5()==false)then
        iconSize=70
        posY=300 - 25
        subH=30
    end
    
    for i=1,propNum do
        local item=FormatItem(listProp[i])
        local num=bagVoApi:getItemNumId(item[1].id) or 0
        self.propItem[i]=item[1]
        print("self.propItem[i]-------->>>>",self.propItem[i].key,self.propItem[i].id,self.propItem[i].name)
        local function callback(hd,fn,idx)
            local function showtip(num)
                local tipStr=getlocal("hero_smelt_tip" .. num)
                self:showTipsDialog(tipStr)
            end
            local needNum
            local num=bagVoApi:getItemNumId(item[1].id) or 0
            -- 列表框中已有道具数量
            local haveNum=SizeOfTable(self.currentPropTb)       

            -- 当前道具已用在列表框的个数
            local useNum=self.currentUseNumTb[i] or 0
            if num-useNum<=0 then
                showtip(1)
                return
            end

            -- 总共需要多少道具
            if self.listNum==self.totalListNum then
                needNum=heroSmeltCfg.needNum2
            else
                needNum=heroSmeltCfg.needNum1
            end
            -- 熔炉已满
            if haveNum==needNum then
                showtip(2)
                return
            end 
            local addNum=0

            if haveNum<2 then
                if num-useNum>=2 then
                    addNum=2-haveNum
                else
                    addNum=num-useNum
                end
            else
                if num-useNum>=needNum-haveNum then
                    addNum=needNum-haveNum
                else
                    addNum=num-useNum
                end
            end

            -- if num-useNum>=needNum-haveNum then
            --     addNum=needNum-haveNum
            -- else
            --     addNum=num-useNum
            -- end
            self.currentUseNumTb[i]=(self.currentUseNumTb[i] or 0)+addNum
            print("addNum------i------->>>>",addNum,i,haveNum,needNum)
            self:addCurrentProp(addNum,i)
        end

        local jigeW=0
        local subNum=0
        if i>4 then
            jigeW=G_VisibleSizeWidth/4
            subNum=i-4
        else
            jigeW=G_VisibleSizeWidth/5
            subNum=i
        end
        
        local icon,scale=G_getItemIcon(item[1],iconWidth,nil,self.layerNum+1,callback) 
        icon:setAnchorPoint(ccp(0.5,0))
        icon:setPosition(ccp(jigeW*subNum,posY))
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(icon,4)
        scale=iconSize/icon:getContentSize().width
        icon:setScale(scale)
        self.propTb[i]=icon

        local nameLable=GetTTFLabelWrap(item[1].name,strSize2,CCSize(strWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        nameLable:setAnchorPoint(ccp(0.5,1))
        nameLable:setPosition(ccp(icon:getContentSize().width/2,-10))
        nameLable:setScale(1/scale)
        icon:addChild(nameLable,1)
        
        local numLable=GetTTFLabel(FormatNumber(tonumber(num)),20)
        numLable:setAnchorPoint(ccp(1,0))
        numLable:setScale(1/scale)
        numLable:setPosition(ccp(icon:getContentSize().width-5,0))
        numLable:setTag(101)
        icon:addChild(numLable,1)

        if not G_isIphone5() then
            icon:setScale(scale * 0.9)
        end

        local sbBg=CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
        icon:addChild(sbBg)
        sbBg:setAnchorPoint(ccp(1,0))
        sbBg:setScaleX(1/scale*(numLable:getContentSize().width+5)/sbBg:getContentSize().width)
        sbBg:setScaleY(1/scale*numLable:getContentSize().height/sbBg:getContentSize().height)
        sbBg:setPosition(numLable:getPosition())
        sbBg:setOpacity(160)
        

        if num==0 then
            numLable:setColor(G_ColorRed)
        end

        if i%4==0 then
            posY=posY-(iconSize+subH)
        end
    end
end

function heroSmeltDialog:socketHelper(method,item,cost,num)
    local function callBack(fn,data)
        local ret,sData = base:checkServerData(data)
        if ret==true then 
            playerVoApi:setValue("gems",playerVoApi:getGems() - cost * (num or 1) )

            if sData and sData.data and sData.data.reward then

                local rewardItem=FormatItem(sData.data.reward)
                -- for k,v in pairs(rewardItem) do
                --     G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                -- end
                -- self:clearCurrentProp(true)
                if method==nil or num > 1 then
                    local title = getlocal("hero_smelt_get1")
                    if num and num > 1 and method then
                        title = method == 1 and getlocal("MeltingAward") or getlocal("emblem_advance_get")
                    end
                    local rewardH=450+math.floor(SizeOfTable(rewardItem)/3)*150
                    require "luascript/script/game/scene/gamedialog/activityAndNote/acMingjiangpeiyangSmallDialog"
                    acMingjiangpeiyangSmallDialog:showRewardItemDialog("TankInforPanel.png",CCSizeMake(550,rewardH),CCRect(130, 50, 1, 1),title,rewardItem,false,self.layerNum+1,nil)
                    self:clearCurrentProp(true)
                    self:refreshArcAndLineSp()
                    self:setCostLbAndItem()
                else
                    print("self:showAward---->>>rewardItem numbers is :",SizeOfTable(rewardItem))
                    self:showAward(rewardItem,method)
                end
                
            end

        end                
    end

    socketHelper:heroSmelt(method,self.listNum,item,cost,callBack,num)
end


function heroSmeltDialog:addTouchBtn()
    local function sureHandler(tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- 一键进阶
        if tag==2 then
            if self.listNum==SizeOfTable(heroSmeltCfg.prop1) then
                local tipStr=getlocal("hero_smelt_tip4")
                self:showTipsDialog(tipStr)
                return
            end
            local gems=playerVoApi:getGems()
            local singleCost=heroSmeltCfg.cost1[self.listNum]
            if gems<singleCost then
                -- 金币不足
                local tipStr=getlocal("hero_smelt_tip5")
                self:showTipsDialog(tipStr)
                return
            end
            local totalPropNum=0
            
            for k,v in pairs(self.propItem) do
                local num=bagVoApi:getItemNumId(v.id) or 0
                totalPropNum=totalPropNum+num
            end
            if totalPropNum<heroSmeltCfg.needNum1 then
                -- 道具不足
                local tipStr=getlocal("hero_smelt_tip6")
                self:showTipsDialog(tipStr)
                return
            end

            local maxNum1=math.floor(gems/singleCost)
            local maxNum2=math.floor(totalPropNum/heroSmeltCfg.needNum1)
            local maxNum=maxNum1
            if maxNum1>maxNum2 then
                maxNum=maxNum2
            end
            local cost=maxNum*singleCost
           

            local function getSocket()
                -- self:clearCurrentProp()

                -- local totalNum=maxNum*heroSmeltCfg.needNum1

                

                -- for k,v in pairs(self.propItem) do
                --     local num=bagVoApi:getItemNumId(v.id) or 0
                --     if num<=totalNum then
                --         bagVoApi:useItemNumId(v.id,num)
                --         totalNum=totalNum-num
                --         self:refreshLbColor(k,num,num)
                --     else
                --         bagVoApi:useItemNumId(v.id,totalNum)
                --         self:refreshLbColor(k,num,totalNum)
                --         totalNum=0
                --         break
                --     end
                --     -- 
                -- end

                self:socketHelper(nil,nil,cost)
            end

            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getSocket,getlocal("dialog_title_prompt"),getlocal("hero_smelt_tip7",{cost,maxNum}),nil,self.layerNum+1)

        else -- 熔炼或者进阶
            local currentNum=SizeOfTable(self.currentPropTb)
            local num = self.count == 0 and 1 or self.count
            local method
            local item={}
            local cost=0
            if currentNum==heroSmeltCfg.needNum2 then
                method=1
                cost=heroSmeltCfg.cost2[self.listNum]
            elseif currentNum==heroSmeltCfg.needNum1 then
                method=2
                cost=heroSmeltCfg.cost1[self.listNum]
            else
                local tipStr=getlocal("hero_smelt_tip3",{heroSmeltCfg.needNum2,heroSmeltCfg.needNum1})
                self:showTipsDialog(tipStr)
                return
            end

            local gems=playerVoApi:getGems()
            if gems<cost * num then
                local function close()
                    self:close()
                end
                GemsNotEnoughDialog(nil,nil,cost * num - playerVoApi:getGems(),self.layerNum+1,cost * num,close)
                return
            end
            if num > 100 then
                G_showTipsDialog(getlocal("MeltingNumberLargeTip"))
                do return end
            end

            for k,v in pairs(self.currentUseNumTb) do
                if method==1 then
                    -- if v~=0 then
                    --     bagVoApi:useItemNumId(self.propItem[k].id,v)
                    -- end
                    for i=1,v do
                        table.insert(item,self.propItem[k].key)
                    end
                else
                    if v~=0 then
                        item[self.propItem[k].key]=v
                        -- bagVoApi:useItemNumId(self.propItem[k].id,v)
                    end
                end
            end
            
            self:socketHelper(method,item,cost,self.count)

        end
    end

    local function callback1()
        sureHandler(1)
    end
    local function callback2()
        sureHandler(2)
    end

    local toucBtnH=70
    local tmpScale = 0.7
    local tmpTextSize = 24

    local menuItem={}
    menuItem[1]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callback1,nil,getlocal("activity_gangtieronglu_tab1"),tmpTextSize/tmpScale,11)
    menuItem[2]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",callback2,nil,getlocal("emblem_btn_one_key"),tmpTextSize/tmpScale)
    menuItem[1]:setScale(tmpScale)
    menuItem[2]:setScale(tmpScale)
    self.menuItem1=menuItem[1]
    self.menuItem2=menuItem[2]
    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem[1])
    btnMenu:addChild(menuItem[2])
    btnMenu:alignItemsHorizontallyWithPadding(150)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-3)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPositionY(toucBtnH)

    for i=1,1 do
        local costNum=40
        local costLb=GetTTFLabel(costNum .. "  ",tmpTextSize/tmpScale)
        costLb:setAnchorPoint(ccp(0.5,0.5))
        menuItem[i]:addChild(costLb)
        if i==1 then
            self.costLb1=costLb
        end

        local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
        goldIcon:setAnchorPoint(ccp(0,0.5))
        goldIcon:setPosition(costLb:getContentSize().width,costLb:getContentSize().height/2)
        goldIcon:setScale(1/tmpScale)
        self.goldIcon = goldIcon
        costLb:addChild(goldIcon,1)

        costLb:setPosition(menuItem[i]:getContentSize().width * 0.5 - 10,105)
    end

end

function heroSmeltDialog:getLargestPropUseNum()
    if SizeOfTable(self.currentPropTb) == 0 then 
        return 0, 0
    end
    local returnNum = nil
    for k,v in pairs(self.currentUseNumTb) do
        local rewardItem = self.propItem[k]
        local totalNum   = bagVoApi:getItemNumId(rewardItem.id)
        if not returnNum or math.floor(totalNum / v) < returnNum then
            returnNum = math.floor(totalNum / v)
        end
    end
    returnNum = returnNum > 100 and 100 or returnNum
    return 1, returnNum
end

-- addNum 添加几个  propNum 第几个道具
function heroSmeltDialog:addCurrentProp(addNum,propNum)
    print("addCurrentProp---->>>addNum--->>>propNum : ",addNum,propNum)
    local currentNum=SizeOfTable(self.currentPropTb)
    -- local reward=heroSmeltCfg.prop1[self.listNum][propNum]
    local rewardItem=self.propItem[propNum]
    -- hero_smelt_quan1
    local quanPic=self:getQuanColorPic()
    for i=currentNum+1,currentNum+addNum do
        print("rewardItem.num------>>>>>",rewardItem.num)
        local function callback(hd,fn,idx)
            PlayEffect(audioCfg.mouseClick)
            self.currentUseNumTb[propNum]=(self.currentUseNumTb[propNum] or 0)-1
            local useNum=self.currentUseNumTb[propNum] or 0
            local totalNum=bagVoApi:getItemNumId(rewardItem.id) or 0
            self:refreshLbColor(propNum,totalNum,useNum)
            print("idx------->>>>",idx)
            self:removeCurrentProp(idx)
        end
        local bigScale=1
        if self.listNum==SizeOfTable(heroSmeltCfg.prop1) then
            bigScale=1.2
        end
        local icon=LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",callback)
        -- G_getItemIcon(rewardItem,100,nil,self.layerNum,callback) 
        -- icon:setAnchorPoint(ccp(0,0))
        icon:setPosition(self.posTb1[i])
        icon:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(icon,4)
        local scale=80/icon:getContentSize().width*bigScale
        icon:setScale(scale)
        icon:setTag(i)
        -- icon:setScale(50/icon:getContentSize().width)
        icon:setOpacity(0)
        local visibleQuanSp=CCSprite:createWithSpriteFrameName(quanPic)
        visibleQuanSp:setScale(70/visibleQuanSp:getContentSize().width*1/scale*bigScale)
        icon:addChild(visibleQuanSp)
        visibleQuanSp:setPosition(icon:getContentSize().width/2,icon:getContentSize().height/2)
        local p1Sp=CCSprite:createWithSpriteFrameName("IconFault.png")
        p1Sp:setPositionX(icon:getContentSize().width/2)
        icon:addChild(p1Sp)
        p1Sp:setTag(11)

        local curNum = GetTTFLabel(1,18)
        curNum:setAnchorPoint(ccp(1,0.5))
        curNum:setPosition(icon:getContentSize().width - 10,24)
        icon:addChild(curNum,10)

        local curNumBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
        curNumBg:setAnchorPoint(ccp(1,0.5))
        curNumBg:setScaleX( ( curNum:getContentSize().width + 2 ) / curNumBg:getContentSize().width)
        curNumBg:setScaleY( curNum:getContentSize().height / curNumBg:getContentSize().height)
        curNumBg:setPosition(icon:getContentSize().width - 12,24)
        icon:addChild(curNumBg,8)

        local visibleIcon=CCSprite:createWithSpriteFrameName(rewardItem.pic)
        -- G_getItemIcon(rewardItem,100,nil)
        visibleIcon:setPosition(icon:getContentSize().width/2,icon:getContentSize().height/2)
        icon:addChild(visibleIcon,5)
        visibleIcon:setScale(bigScale*1/scale*65/visibleIcon:getContentSize().width)
        -- visibleIcon:setVisible(false)

        table.insert(self.currentPropTb,icon)
        table.insert(self.currentPropNumTb,curNum)
        table.insert(self.currentPropNumBgTb,curNumBg)

    end

    -- 跟新道具数量颜色
    local useNum=self.currentUseNumTb[propNum] or 0
    local totalNum=bagVoApi:getItemNumId(rewardItem.id) or 0
    self:refreshLbColor(propNum,totalNum,useNum)

    self:setCostLbAndItem()
    self:refreshArcAndLineSp()
    self:refreshSliderData()
end

-- self.arcSpTb
function heroSmeltDialog:refreshArcAndLineSp()
    local currentNum=SizeOfTable(self.currentPropTb)
    if currentNum==heroSmeltCfg.needNum1 then
        for k,v in pairs(self.arcSpTb) do
            v:setVisible(true)
        end
    else
        for k,v in pairs(self.arcSpTb) do
            if k<currentNum then
                v:setVisible(true)
            else
                v:stopAllActions()
                v:setVisible(false)
            end
        end
    end
    for k,v in pairs(self.lineSpTb) do
        if k<=currentNum then
            v:setVisible(true)
        else
            v:stopAllActions()
            v:setVisible(false)
        end
    end
    if currentNum==heroSmeltCfg.needNum1 or currentNum==heroSmeltCfg.needNum2 then
        for k,v in pairs(self.arcSpTb) do
            if v:isVisible() then
                local fade1=CCFadeTo:create(0.4,50)
                local fade2=CCFadeTo:create(0.4,255)
                local seq=CCSequence:createWithTwoActions(fade1,fade2)
                v:runAction(seq)
            end
        end
        for k,v in pairs(self.lineSpTb) do
            if v:isVisible() then
                local fade1=CCFadeTo:create(0.4,50)
                local fade2=CCFadeTo:create(0.4,255)
                local seq=CCSequence:createWithTwoActions(fade1,fade2)
                v:runAction(seq)
            end
        end

        -- 中间地颜色变化
        local centerPos
        local quanPic
        if self.listNum==SizeOfTable(heroSmeltCfg.prop1) then
            centerPos=self.centerPos2
        else
            centerPos=self.centerPos1
        end

        if currentNum==heroSmeltCfg.needNum1 then
            quanPic=self:getQuanColorPic(self.listNum+1)
        else
            quanPic=self:getQuanColorPic(self.listNum)
        end
        if self.centerSp~=nil then
            self.centerSp:removeFromParentAndCleanup(true)
            self.centerSp=nil
        end
        self.centerSp=CCSprite:createWithSpriteFrameName(quanPic)
        self.bgLayer:addChild(self.centerSp,5)
        self.centerSp:setPosition(centerPos.x,centerPos.y+2)
        self.centerSp:setScale(85/self.centerSp:getContentSize().width)
    else
        if self.centerSp then
            self.centerSp:removeFromParentAndCleanup(true)
            self.centerSp=nil
        end
    end

    
end

function heroSmeltDialog:getQuanColorPic(listNum)
    if listNum==nil then
        listNum=self.listNum
    end

    local quanPic="hero_smelt_quan1.png"
    -- if listNum<3 then
        quanPic="hero_smelt_quan" .. listNum .. ".png"
    -- else
    --     quanPic="hero_smelt_quan3.png"
    -- end
    return quanPic
end



function heroSmeltDialog:refreshLbColor(propNum,totalNum,useNum)
    local lb=tolua.cast(self.propTb[propNum]:getChildByTag(101),"CCLabelTTF")

    if lb then
        lb:setString(totalNum-useNum)
        if totalNum>useNum then
            lb:setColor(G_ColorWhite)
        else
            lb:setColor(G_ColorRed)
        end
    end
end

function heroSmeltDialog:setCostLbAndItem()
    local useArrCount = self.count == 0 and 1 or self.count-- 优化内容：当前熔炼的组数 （ 2 or 5 熔炼时候的组数）
    local currentNum=SizeOfTable(self.currentPropTb)
    local lb = tolua.cast(self.menuItem1:getChildByTag(11),"CCLabelTTF")
    local cost=0
    if currentNum==heroSmeltCfg.needNum1 then
        cost=heroSmeltCfg.cost1[self.listNum] * useArrCount
        self.costLb1:setString(cost)
        lb:setString(getlocal("super_weapon_lvUp"))
    else
        cost=heroSmeltCfg.cost2[self.listNum] * useArrCount
        self.costLb1:setString(cost)
        lb:setString(getlocal("activity_gangtieronglu_tab1"))
    end
    local playerGems=playerVoApi:getGems()
    if playerGems<cost then
        self.costLb1:setColor(G_ColorRed)
    else
        self.costLb1:setColor(G_ColorWhite)
    end
    self.goldIcon:setPosition(self.costLb1:getContentSize().width,self.costLb1:getContentSize().height * 0.5)



end

function heroSmeltDialog:removeCurrentProp(num)
    self.currentPropTb[num]:removeFromParentAndCleanup(true)
    table.remove(self.currentPropNumTb,num)
    table.remove(self.currentPropNumBgTb,num)
    table.remove(self.currentPropTb,num)
    for k,v in pairs(self.currentPropTb) do
        v:setPosition(self.posTb1[k])
        v:setTag(k)
        if self.currentPropNumTb[k] and self.currentPropNumBgTb[k] then
            self.currentPropNumTb[k]:setString(1)
            self.currentPropNumBgTb[k]:setScaleX( ( self.currentPropNumTb[k]:getContentSize().width + 2 ) / self.currentPropNumBgTb[k]:getContentSize().width)
        end
    end
    self:setCostLbAndItem()
    self:refreshArcAndLineSp()
    self:refreshSliderData()
end

function heroSmeltDialog:clearCurrentProp(flag)
    for k,v in pairs(self.currentPropTb) do
        v:removeFromParentAndCleanup(true)
        self.currentPropTb[k]      =nil
        self.currentPropNumBgTb[k] =nil
        self.currentPropNumTb[k]   =nil
    end
    self.currentUseNumTb={}
    if flag then
        for k,v in pairs(self.propItem) do
            local lb=tolua.cast(self.propTb[k]:getChildByTag(101),"CCLabelTTF")
            if lb then
                local num=bagVoApi:getItemNumId(v.id) or 0
                lb:setString(num)
                if num>0 then
                    lb:setColor(G_ColorWhite)
                else
                    lb:setColor(G_ColorRed)
                end
            end
        end
    end
    if self.centerSp then
        self.centerSp:removeFromParentAndCleanup(true)
        self.centerSp=nil
    end
    self:refreshSliderData()
end

function heroSmeltDialog:showAward(award,method)
    if(self.awardLayer)then
        do return end
    end

    local centerPos
    if self.listNum==SizeOfTable(heroSmeltCfg.prop1) then
        centerPos=self.centerPos2
    else
        centerPos=self.centerPos1
    end

    local layerNum=self.layerNum + 1
    self.awardLayer = CCLayer:create()
    self.bgLayer:addChild(self.awardLayer,9)
    local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ()end)
    bgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    bgSp:setOpacity(0)
    bgSp:setAnchorPoint(ccp(0,0))
    bgSp:setPosition(ccp(0,0))
    bgSp:setTouchPriority(-(layerNum-1)*20-1)
    self.awardLayer:addChild(bgSp)
    local awardEmblem=award[1]
    local emblemID=awardEmblem.key
    if(emblemID==nil)then
        self.awardLayer:removeFromParentAndCleanup(true)
        self.awardLayer=nil
        do return end
    end

    for k,v in pairs(self.currentPropTb) do
        local p1Sp=v:getChildByTag(11)
        if p1Sp then
            p1Sp:removeFromParentAndCleanup(true)
            p1Sp=nil
        end
        local delay=CCDelayTime:create(0.5)
        local moveTo=CCMoveTo:create(1,centerPos)
        local function removeFunc()
            self:clearCurrentProp(true)
            self:refreshArcAndLineSp()
        end
        local removeFunc=CCCallFunc:create(removeFunc)
        local acArr=CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(moveTo)
        acArr:addObject(removeFunc)
        local seq=CCSequence:create(acArr)
        v:runAction(seq)
    end
    local function callback1()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemAdvance1.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(centerPos)
        self.awardLayer:addChild(particleS,10)
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemAdvance2.plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(centerPos)
        self.awardLayer:addChild(particleS,11)
    end

    local function callback4()
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemAdvance3.plist")
        particleS:setScale(2.5)
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(centerPos)
        self.awardLayer:addChild(particleS,13)
    end

    local function callback2()

        local color=self:getColor(method)
        
        local particleS = CCParticleSystemQuad:create("public/emblem/emblemGet".. color ..".plist")
        particleS:setPositionType(kCCPositionTypeFree)
        particleS:setPosition(centerPos)
        particleS:setScale(1.5)
        self.awardLayer:addChild(particleS,12)
    end
    local callFunc1=CCCallFunc:create(callback1)
    local callFunc2=CCCallFunc:create(callback2)
    local delay2=CCDelayTime:create(1.5)
    local acArr=CCArray:create()
    local function callback3()
        local titleBg = CCSprite:createWithSpriteFrameName("HelpHeaderBg.png")
        titleBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 120)
        self.awardLayer:addChild(titleBg)
        
        local promptStr
        if method==1 then
            promptStr = getlocal("hero_smelt_meltSuccess")
        else
            promptStr = getlocal("emblem_advance_success")
        end
        local lb=GetTTFLabel(promptStr,32)
        lb:setPosition(getCenterPoint(titleBg))
        titleBg:addChild(lb)
        local function callback31()
            local function onClose( ... )
                self.awardLayer:removeAllChildrenWithCleanup(true)
                self.awardLayer:removeFromParentAndCleanup(true)
                self.awardLayer=nil
            end
            local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClose,nil,getlocal("confirm"),25)
            local okBtn=CCMenu:createWithItem(okItem)
            okBtn:setTouchPriority(-(layerNum-1)*20-5)
            okBtn:setAnchorPoint(ccp(0.5,0.5))
            okBtn:setPosition(ccp(G_VisibleSizeWidth/2,150))
            self.awardLayer:addChild(okBtn,11)
        end

        -- local function showItemInfo(tag)
        --     if G_checkClickEnable()==false then
        --         do return end
        --     else
        --         base.setWaitTime=G_getCurDeviceMillTime()
        --     end
        --     emblemVoApi:showInfoDialog(eVo,layerNum + 1)
        -- end
        local mIcon = G_getItemIcon(award[1],100,true,self.layerNum+1)
        if mIcon then
            mIcon:setTouchPriority(-(layerNum-1)*20-5)
            mIcon:setScale(0)
            mIcon:setPosition(centerPos)
            self.awardLayer:addChild(mIcon,15)
            -- 名称
            local namsStr=award[1].name .. "x" .. award[1].num
            local equipNameLb = GetTTFLabelWrap(namsStr,25,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            equipNameLb:setAnchorPoint(ccp(0.5,1))
            equipNameLb:setPosition(ccp(mIcon:getContentSize().width/2,-20))
            mIcon:addChild(equipNameLb)

            -- 动画
            local callback4=CCCallFunc:create(callback4)
            local ccScaleTo = CCScaleTo:create(0.3,1.3)
            local callFunc3=CCCallFuncN:create(callback31)
            local delayTime = CCDelayTime:create(0.5)
            local iconAcArr=CCArray:create()
            iconAcArr:addObject(callback4)
            iconAcArr:addObject(delayTime)
            iconAcArr:addObject(ccScaleTo)
            iconAcArr:addObject(callFunc3)
            local seq=CCSequence:create(iconAcArr)
            mIcon:runAction(seq)
        end
    end 
    local callFunc3=CCCallFunc:create(callback3)
    local opacityAc = CCFadeTo:create(0.7,150)
    acArr:addObject(callFunc1)
    acArr:addObject(delay2)
    acArr:addObject(opacityAc)
    acArr:addObject(callFunc2)
    acArr:addObject(callFunc3)
    local seq=CCSequence:create(acArr)
    bgSp:runAction(seq)
end

-- 白绿蓝紫橙
function heroSmeltDialog:getColor(method)
    local color=4
    if method==1 then
        -- if self.listNum<3 then
            color=self.listNum+1
        -- else
        --     color=4
        -- end
    else
        -- if self.listNum<3 then
            color=self.listNum+2
        -- else
        --     color=4
        -- end
    end

    return color    
end


function heroSmeltDialog:tick()
end

function heroSmeltDialog:resetForbidLayer()
    local topY
    local topHeight
    local rect=CCSizeMake(640,G_VisibleSize.height)
    if(self.tv~=nil)then
        local tvX,tvY=self.tv:getPosition()
        topY=tvY+self.tv:getViewSize().height
        topHeight=rect.height-topY
    else
        topHeight=0
        topY=0
    end
    self.topforbidSp:setContentSize(CCSize(rect.width,topHeight))
    self.topforbidSp:setPosition(0,topY)
    if(self.tv~=nil)then
        local tvX,tvY=self.tv:getPosition()
        self.bottomforbidSp:setContentSize(CCSizeMake(self.bgSize.width,tvY))
    end
end

function heroSmeltDialog:showTipsDialog(tipStr)
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30)
end

function heroSmeltDialog:dispose()
    self.goldIcon = nil
    self.slider          = nil
    self.m_numLb         = nil
    self.count           = nil
    self.listNum         = nil
    self.propTb          = nil
    self.currentPropTb   = nil
    self.currentUseNumTb = nil
    self.currentPropNumTb   =nil
    self.currentPropNumBgTb =nil
   
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/emblem/emblemBlackBg.jpg")
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
        spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
    spriteController:removePlist("public/acPjjnh.plist")
    spriteController:removeTexture("public/acPjjnh.png")
end