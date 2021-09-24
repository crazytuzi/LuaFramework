acSweetTroubleTab2 ={}
function acSweetTroubleTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.clayer =nil
    self.isMoved=false
    self.touchArr={}
    self.temSp = nil
    self.index=nil
    self.selectType=nil
    self.iconTab = {}
    self.BoxTab ={}
    self.BoxGrowTab = {}
    self.seedNumTab={}
    self.seedNumShowTab={}
    self.BoxAgingTab ={}
    self.reTimeTab={}
    self.addTimeTab = {}
    self.receiveTab ={}
    self.reTimerNow =false
    self.retimeBgTab = {}
    self.Height = G_VisibleSizeHeight-160
    self.lastTouchPic=nil
    return nc;

end
function acSweetTroubleTab2:init(layerNum)
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum
    -- local function clickk(hd,fn,idx)
    -- end
    local bigBg-- =CCSprite:createWithSpriteFrameName("halloweenBg.jpg")--LuaCCScale9Sprite:createWithSpriteFrameName("halloweenBg.jpg",CCRect(20, 20, 10, 10),clickk)
    -- bigBg:setContentSize(CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight))
    if platCfg.platCfgNewTypeAddTank==true then
        bigBg=CCSprite:create("ship/newTank/halloweenBg.jpg")
    else
        bigBg =CCSprite:createWithSpriteFrameName("halloweenBg.jpg")--LuaCCScale9Sprite:createWithSpriteFrameName("halloweenBg.jpg",CCRect(20, 20, 10, 10),clickk)
    -- bigBg:setContentSize(CCSizeMake(G_VisibleSizeWidth ,G_VisibleSizeHeight))
    end
    bigBg:setScaleX((G_VisibleSizeWidth-42)/bigBg:getContentSize().width)
    bigBg:setScaleY((G_VisibleSizeHeight-186)/bigBg:getContentSize().height)
    bigBg:ignoreAnchorPointForPosition(false)
    bigBg:setOpacity(150)
    bigBg:setAnchorPoint(ccp(0.5,0.5))
    bigBg:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5-68))
    self.bgLayer:addChild(bigBg)


    local needWidth = 15
    local needSubHeight = 50
    local strSize1 = 18
    local strSize2 = 20
    local strSize3 = 30
    local strSize4 = 28
    local subHeightPos = 10
    local subHeightPos2 = 10
    local btnNeedScal = 0.8
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize1 = 22
        strSize2 =25
        strSize4 = 35
        strSize3 =50
        subHeightPos =0
        subHeightPos2 =0
        btnNeedScal =1
    end


    local function click(hd,fn,idx)
    end
    local upBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    upBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 44,self.Height*0.45))
    upBg:ignoreAnchorPointForPosition(false)
    upBg:setAnchorPoint(ccp(0.5,1))
    upBg:setOpacity(150)
    upBg:setPosition(ccp(G_VisibleSizeWidth*0.5,self.Height))
    self.bgLayer:addChild(upBg,1)

    local middTip = GetTTFLabelWrap(getlocal("activity_sweettrouble_tap2_tip"),strSize2,CCSizeMake(G_VisibleSizeWidth*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    middTip:setAnchorPoint(ccp(0.5,0.5))
    middTip:setPosition(ccp(G_VisibleSizeWidth*0.5,self.Height-upBg:getContentSize().height-25))
    self.bgLayer:addChild(middTip,1)
    local adaH = 0
    if G_getIphoneType() == G_iphoneX then
        adaH = 35
    end
    local downBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    downBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 44,self.Height*0.45+adaH))
    downBg:setOpacity(150)
    downBg:ignoreAnchorPointForPosition(false)
    downBg:setAnchorPoint(ccp(0.5,1))
    downBg:setPosition(ccp(G_VisibleSizeWidth*0.5,middTip:getPositionY()-25))
    self.bgLayer:addChild(downBg,1)
---------
    local function touch(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end

        PlayEffect(audioCfg.mouseClick)
        if tag == 1 then
            self:openInfo()
        elseif tag >10 and tag<20 then
            local idx = tag-10
            --加速按钮
            print("--加速按钮")
            local needGems = acSweetTroubleVoApi:getGemsSecond(idx)

            local function sureCallback( )
                if playerVo.gems<needGems then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem",{getlocal("notEnoughGem")}),30)
                else
                    local function callback(fn,data)
                        local ret,sData = base:checkServerData(data)
                        if ret==true then
                           
                            if sData.data and sData.data.usegems then
                                playerVoApi:setGems(playerVoApi:getGems()-sData.data.usegems)
                                print("加速成功~~~~~")
                                acSweetTroubleVoApi:setNeedimesTab(idx)
                                self.reTimeTab[idx]:setString(getlocal("activity_sweettrouble_aging"))
                                self.addTimeTab[idx]:setVisible(false)
                                self.retimeBgTab[idx]:setVisible(true)
                                self.receiveTab[idx]:setVisible(true)
                                self.BoxTab[idx]:setVisible(false)
                                self.BoxGrowTab[idx]:setVisible(false)
                                self.BoxAgingTab[idx]:setVisible(true)
                                -- acSweetTroubleVoApi:showRewardTip(award,true,"activity_sweettrouble_seed_"..idx)
                                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_sweettrouble_plantRec",{getlocal("activity_sweettrouble_seed_"..idx,0,0)}),30)
                            end
                        end
                    end
                    socketHelper:halloweenReward("speed",callback,nil,idx)
                end
            end 

            local smallD=smallDialog:new()
            smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureCallback,getlocal("dialog_title_prompt"),getlocal("activity_sweettrouble_counsemGems",{needGems}),nil,self.layerNum+1)


        elseif tag >20 and tag<30 then
            local idx = tag-20
            --成熟时
            print("---成熟时")
            local seedGrowTimesTab = acSweetTroubleVoApi:getGrowTimesTab( )
            local whiSwe = nil
            for i=1,4 do
                if seedGrowTimesTab["p"..idx][1] =="t"..i then
                    whiSwe =i 
                end 
            end

            local function callback(fn,data)
                local ret,sData = base:checkServerData(data)
                if ret==true then
                    if sData.data and sData.data.reward then
                        local award=FormatItem(sData.data.reward) or {}
                        for k,v in pairs(award) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end
                        print("收获~~~~~")
                        -- acSweetTroubleVoApi:setCropedCounts()
                        acSweetTroubleVoApi:setNeedimesTab( idx)
                        acSweetTroubleVoApi:setNeedimesTabIdxNil(idx)
                        self.reTimeTab[idx]:setVisible(false)
                        self.retimeBgTab[idx]:setVisible(false)
                        self.receiveTab[idx]:setVisible(false)
                        self.BoxTab[idx]:setVisible(true)
                        self.BoxTab[idx]:setOpacity(70)
                        self.BoxGrowTab[idx]:setVisible(false)
                        self.BoxAgingTab[idx]:setVisible(false)

                        acSweetTroubleVoApi:showRewardTip(award,true,"activity_sweettrouble_seed_"..whiSwe)
                    end
                    if sData.data and sData.data.halloween.pc then
                        acSweetTroubleVoApi:setCropedCounts(sData.data.halloween.pc)
                    end
                end
            end
            socketHelper:halloweenReward("harvest",callback,nil,idx)

        elseif tag ==4 then
            print("get reward!!!!!!")
        end
    end

    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-30,self.Height-5))
    menuItemDesc:setScale(btnNeedScal)
    self.bgLayer:addChild(menuDesc,2)

    local upTitle = GetTTFLabelWrap(getlocal("activity_sweettrouble_sweetHouse"),strSize4,CCSizeMake(G_VisibleSizeWidth*0.6,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    upTitle:setAnchorPoint(ccp(0.5,1))
    upTitle:setPosition(ccp(G_VisibleSizeWidth*0.5,self.Height-15))
    upTitle:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(upTitle,1) 

    local upStr = GetTTFLabelWrap(getlocal("activity_sweettrouble_tap2_str"),strSize2,CCSizeMake(G_VisibleSizeWidth*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    upStr:setAnchorPoint(ccp(0.5,1))
    upStr:setPosition(ccp(G_VisibleSizeWidth*0.5,upTitle:getPositionY()-70+subHeightPos2-adaH))
    -- upStr:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(upStr,1) 

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setScale(0.95)
    lineSp2:setPosition(ccp(G_VisibleSizeWidth*0.5,upStr:getPositionY()-70-subHeightPos2))
    self.bgLayer:addChild(lineSp2,1)

    self.seedNumTab = acSweetTroubleVoApi:getTgSeedTab( )
    -- for k,v in pairs(self.seedNumTab) do
    --     print(k,v)
    -- end
    local needSubHeightInUn5 = 5
    local needSubHeightInUn5_2 = 15
    local needScale = 1
    local needHeightPos2 = 85
    local needSubBoxHeight = 50
    local needSubBoxBtn = 40
    -- local needSubHeightInUn5_2 = 
    
    if G_isIphone5() then
        needSubHeightInUn5 =30
        needSubHeightInUn5_2 = 65
        needScale =1.5
        needHeightPos2 = 110
        needSubBoxHeight =80
        needSubBoxBtn =50
    end
    
    for i=1,4 do --对应四种种子的各种信息
        local needWidth4 = 40+self.bgLayer:getContentSize().width*0.14*i+self.bgLayer:getContentSize().width*0.06*(i-1)
        local iconPic = "sweet_"..5-i..".png"
        local middlepic = nil
        if  i ==1 then
            middlepic ="equipBg_orange.png"
        elseif  i ==2 then
            middlepic ="equipBg_purple.png"
        elseif  i ==3 then
            middlepic ="equipBg_blue.png"
        elseif  i ==4 then
            middlepic ="equipBg_green.png"
        else
            middlepic = "Icon_BG.png"
        end
        local downPic = CCSprite:createWithSpriteFrameName(middlepic)
        downPic:setScale(100 / downPic:getContentSize().width)
        downPic:setPosition(ccp(needWidth4,lineSp2:getPositionY()-downPic:getContentSize().height*0.5-needSubHeightInUn5))
        downPic:setAnchorPoint(ccp(0.5,0.5))
        self.bgLayer:addChild(downPic,1)
        table.insert(self.iconTab,downPic)

        local iconPicShow = CCSprite:createWithSpriteFrameName(iconPic)
        iconPicShow:setScale(0.8)
        iconPicShow:setPosition(getCenterPoint(downPic))
        iconPicShow:setAnchorPoint(ccp(0.5,0.5))
        downPic:addChild(iconPicShow)

        local seedStr = "activity_sweettrouble_seed_"..5-i
        local seed = GetTTFLabelWrap(getlocal(seedStr),strSize2,CCSizeMake(downPic:getContentSize().width+4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        seed:setAnchorPoint(ccp(0.5,0.5))
        seed:setPosition(ccp(needWidth4,lineSp2:getPositionY()-downPic:getContentSize().height-needSubHeightInUn5_2-subHeightPos))
        self.bgLayer:addChild(seed,1)

        local seedNumBg =CCSprite:createWithSpriteFrameName("deepColorBg.png")--LuaCCScale9Sprite:createWithSpriteFrameName("deepColorBg.png",CCRect(20, 20, 10, 10),click)
        -- seedNumBg:setContentSize(CCSizeMake(downPic:getContentSize().width,downPic:getContentSize().height*0.2))
        seedNumBg:setScaleX(100 / downPic:getContentSize().width)
        seedNumBg:setScaleY(100 / downPic:getContentSize().height*0.35)
        seedNumBg:ignoreAnchorPointForPosition(false)
        seedNumBg:setAnchorPoint(ccp(0.5,0.5))
        seedNumBg:setPosition(ccp(needWidth4,seed:getPositionY()-50))
        self.bgLayer:addChild(seedNumBg,1)

        local seedNum = tostring(self.seedNumTab["t"..5-i])
        local seedNumStr = GetTTFLabelWrap(seedNum,strSize2,CCSizeMake(downPic:getContentSize().width+4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        seedNumStr:setAnchorPoint(ccp(0.5,0.5))
        seedNumStr:setPosition(ccp(needWidth4,seed:getPositionY()-50))
        self.bgLayer:addChild(seedNumStr,2)
        table.insert(self.seedNumShowTab,seedNumStr)
    end
    if G_getIphoneType() == G_iphoneX then
        adaH = 65
    end
        local m = 0
        local n = 10
        for j=1,2 do
            local jj = j-1
            for i=1,3 do
                m=m+1
                n =n+1
                local needWidth6 = 40+self.bgLayer:getContentSize().width*0.18*i+self.bgLayer:getContentSize().width*0.08*(i-1)

                local sweetBox = CCSprite:createWithSpriteFrameName("sweetBox_1.png")
                sweetBox:setScale(needScale)
                sweetBox:setPosition(ccp(needWidth6,downBg:getPositionY()-needSubBoxHeight-(sweetBox:getContentSize().height+needHeightPos2)*jj-adaH))
                sweetBox:setAnchorPoint(ccp(0.5,0.5))
                sweetBox:setOpacity(70)
                self.bgLayer:addChild(sweetBox,1)
                table.insert(self.BoxTab,sweetBox)

                local sweetBox2 = CCSprite:createWithSpriteFrameName("sweetBox_2.png")
                sweetBox2:setScale(needScale)
                sweetBox2:setPosition(ccp(needWidth6,downBg:getPositionY()-needSubBoxHeight-(sweetBox2:getContentSize().height+needHeightPos2)*jj-adaH))
                sweetBox2:setAnchorPoint(ccp(0.5,0.5))
                self.bgLayer:addChild(sweetBox2,1)
                sweetBox2:setVisible(false)
                table.insert(self.BoxGrowTab,sweetBox2)

                local sweetBox3 = CCSprite:createWithSpriteFrameName("sweetBox_3.png")
                sweetBox3:setScale(needScale)
                sweetBox3:setPosition(ccp(needWidth6,downBg:getPositionY()-needSubBoxHeight-(sweetBox3:getContentSize().height+needHeightPos2)*jj-adaH))
                sweetBox3:setAnchorPoint(ccp(0.5,0.5))
                self.bgLayer:addChild(sweetBox3,1)
                sweetBox3:setVisible(false)
                table.insert(self.BoxAgingTab,sweetBox3)

                local retime = "activity_sweettrouble_aging" --需要倒计时的配置
                local retimeStr = GetTTFLabelWrap(getlocal("activity_sweettrouble_retime",{0,0}),strSize2-2,CCSizeMake(sweetBox:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                retimeStr:setAnchorPoint(ccp(0.5,1))
                retimeStr:setVisible(false)
                retimeStr:setPosition(ccp(needWidth6-10,sweetBox:getPositionY()-sweetBox:getContentSize().height*0.3))
                self.bgLayer:addChild(retimeStr,2)
                table.insert(self.reTimeTab,retimeStr)
                --CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")-
                local retimeBg =CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")--LuaCCScale9Sprite:createWithSpriteFrameName("deepColorBg.png",CCRect(20, 2, 10, 1),click)
                -- retimeBg:setContentSize(CCSizeMake(retimeStr:getContentSize().width,30))
                retimeBg:setScaleX(2.2)
                retimeBg:setScaleY(0.7)
                retimeBg:ignoreAnchorPointForPosition(false)
                retimeBg:setAnchorPoint(ccp(0.5,1))
                retimeBg:setOpacity(200)
                retimeBg:setPosition(ccp(needWidth6-10,sweetBox:getPositionY()-sweetBox:getContentSize().height*0.3))
                self.bgLayer:addChild(retimeBg,1)
                retimeBg:setVisible(false)
                table.insert(self.retimeBgTab,retimeBg)

                local addTimeBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch,n,getlocal("accelerateBuild"),25)
                addTimeBtn:setAnchorPoint(ccp(0.5,1))
                addTimeBtn:setScale(0.7)
                addTimeBtn:setVisible(false)
                local addTimeMenu=CCMenu:createWithItem(addTimeBtn)
                addTimeMenu:setPosition(ccp(needWidth6-10,retimeStr:getPositionY()-needSubBoxBtn))
                addTimeMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                self.bgLayer:addChild(addTimeMenu,1)
                table.insert(self.addTimeTab,addTimeBtn)

                local agingBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch,10+n,getlocal("activity_sweettrouble_recev"),25)
                agingBtn:setAnchorPoint(ccp(0.5,1))
                agingBtn:setScale(0.7)
                agingBtn:setVisible(false)
                local agingMenu=CCMenu:createWithItem(agingBtn)
                agingMenu:setPosition(ccp(needWidth6-10,retimeStr:getPositionY()-needSubBoxBtn))
                agingMenu:setTouchPriority(-(self.layerNum-1)*20-2)
                self.bgLayer:addChild(agingMenu,1)
                table.insert(self.receiveTab,agingBtn)

            end
            
        end
                acSweetTroubleVoApi:setNeedimesTab( )
                acSweetTroubleVoApi:setSubTimes( )
                local reTimesTab = acSweetTroubleVoApi:getNeedTimesTab()
                for i=1,6 do
                    if reTimesTab[i] then 
                        print("reTimesTab[i]---->",reTimesTab[i])
                        if reTimesTab[i] >=0 then
                            self.reTimerNow =true
                            self.reTimeTab[i]:setString(GetTimeStr(reTimesTab[i]))
                            self.reTimeTab[i]:setVisible(true)
                            self.addTimeTab[i]:setVisible(true)
                            self.retimeBgTab[i]:setVisible(true)
                            self.BoxTab[i]:setVisible(false)
                            self.BoxGrowTab[i]:setVisible(true)
                            self.BoxAgingTab[i]:setVisible(false)
                        else
                            self.reTimeTab[i]:setString(getlocal("activity_sweettrouble_aging"))
                            self.reTimeTab[i]:setVisible(true)
                            self.addTimeTab[i]:setVisible(false)
                            self.retimeBgTab[i]:setVisible(true)
                            self.receiveTab[i]:setVisible(true)
                            self.BoxTab[i]:setVisible(false)
                            self.BoxGrowTab[i]:setVisible(false)
                            self.BoxAgingTab[i]:setVisible(true)
                        end
                    end
                end


------------------------------------------------
    self.clayer=CCLayer:create()
    -- self.clayer:setContentSize(CCSizeMake(backBgWidth,self.backBgHeight))
    self.clayer:setPosition(ccp(0,0))
    self.bgLayer:addChild(self.clayer,8)
    self.clayer:setTouchEnabled(true)
    local function tmpHandler(...)
        return self:touchEvent(...)
    end
    self.clayer:registerScriptTouchHandler(tmpHandler,false,-(self.layerNum-1)*20-4,false)
    self.touchEnable=true
------------------------------------------------
    return self.bgLayer
end

function acSweetTroubleTab2:touchEvent( fn,x,y,touch )
    if fn=="began" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
            return 0
        end
        self.isMoved=false
        self.touchArr[touch]=touch

        if SizeOfTable(self.touchArr)>1 then
            if self.temSp then
                self.temSp:removeFromParentAndCleanup(true)
                self.temSp=nil
            end
        else
            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            self.index=0
            self.selectType=0
            local bx,by=self.bgLayer:getPosition()
            local seedNumTab = acSweetTroubleVoApi:getTgSeedTab( )
            for k,v in pairs(self.iconTab) do
                local ix,iy=v:getPosition()
                local cx,cy=ix+bx,iy+by
                local w,h=v:getContentSize().width/2,v:getContentSize().height/2
                if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
                    self.index=k
                    self.selectType=1
                end
            end
            if self.index>0 and self.selectType>0 and self.temSp==nil and seedNumTab["t"..5-self.index] and seedNumTab["t"..5-self.index]>0 then
                if self.selectType==1 then
                    acSweetTroubleVoApi:setWhiSweet(self.index )
                    local icon=CCSprite:createWithSpriteFrameName("sweet_"..5-self.index..".png")
                    self.temSp=CCSprite:createWithSpriteFrameName("sweet_"..5-self.index..".png")
                    icon:setPosition(getCenterPoint(self.temSp))
                    self.temSp:addChild(icon,2)
                    self.temSp:setScale(0.9)
                end
                if self.temSp then
                    self.temSp:setAnchorPoint(ccp(0.5,0.5))
                    self.temSp:setPosition(curPos)
                    self.temSp:setOpacity(150)
                    self.clayer:addChild(self.temSp,2)
                    self.touch=touch

                end
            end
        end

        return 1
    elseif fn=="moved" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
            do
                return
            end
        end
        self.isMoved=true

        if self.touch and self.touch==touch then
            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            if self.temSp then
                self.temSp:setPosition(curPos)
            end

            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local targetIndex=0
            local bx,by=self.bgLayer:getPosition()
            if self.selectType and self.selectType==1 then
                for k,v in pairs(self.BoxTab) do
                    -- v:setVisible(true)
                    local ix,iy=v:getPosition()
                    local cx,cy=ix+bx,iy+by
                    local w,h=v:getContentSize().width/2,v:getContentSize().height/2
                    if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
                        targetIndex=k                    
                    else
                        for k,v in pairs(self.BoxTab) do
                            v:setOpacity(70)
                        end
                    end
                end
            end
            if targetIndex>0  then
                
                self.BoxTab[targetIndex]:setOpacity(200)
                targetIndex =0
            end

        end
    elseif fn=="ended" then
        if self.touchEnable==false or newGuidMgr:isNewGuiding()==true then
            do
                return
            end
        end
        if self.touch and self.touch==touch then
            if self.temSp then
                self.temSp:removeFromParentAndCleanup(true)
                self.temSp=nil
            end

            local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
            local targetIndex=0
            local bx,by=self.bgLayer:getPosition()
            if self.selectType and self.selectType==1 then
                for k,v in pairs(self.BoxTab) do
                    local ix,iy=v:getPosition()
                    local cx,cy=ix+bx,iy+by
                    local w,h=v:getContentSize().width/2,v:getContentSize().height/2
                    if curPos.x>=cx-w and curPos.x<=cx+w and curPos.y>=cy-h and curPos.y<=cy+h then
                        targetIndex=k
                    end
                end
            end
            if targetIndex>0  then
                local swe = acSweetTroubleVoApi:getWhiSwe()
                self:sendPlant(swe,targetIndex )
            end
        end
        if self.touchArr[touch]~=nil then
           self.touchArr[touch]=nil
        end
    else
        self.touchArr=nil
        self.touchArr={}
    end
end

function acSweetTroubleTab2:sendPlant(sweNum,posNum )
    local x = 1
    local seedNumTab = acSweetTroubleVoApi:getTgSeedTab( )
    local NeedTimesTab = acSweetTroubleVoApi:getNeedTimesTab( )
    if seedNumTab["t"..5-sweNum]>0 and NeedTimesTab[posNum] == nil then
        local function callback(fn,data)
            local ret,sData = base:checkServerData(data)
            if ret==true then
                if sData.data  and sData.data.halloween and sData.data.halloween.p then
                local needTimesNowTab = sData.data.halloween.p
                acSweetTroubleVoApi:subTgSeedTab(sweNum)
                self.seedNumShowTab[sweNum]:setString(seedNumTab["t"..5-sweNum])
                self.reTimeTab[posNum]:setVisible(true)
                self.addTimeTab[posNum]:setVisible(true)
                self.retimeBgTab[posNum]:setVisible(true)
                self.BoxTab[posNum]:setVisible(false)
                self.BoxGrowTab[posNum]:setVisible(true)
                self.BoxAgingTab[posNum]:setVisible(false)
                --设置第几个位置的哪种糖果需要加速
                acSweetTroubleVoApi:setAllGrowTimesTab(needTimesNowTab)
                acSweetTroubleVoApi:setWhiSweTimesInWhiPos(sweNum,posNum)
                acSweetTroubleVoApi:setNeedimesTab(nil)

                local reTimeStr = acSweetTroubleVoApi:getWhiSweTimes(sweNum,posNum)
                self.reTimeTab[posNum]:setString(reTimeStr)
                self.reTimerNow =true
                -- print("倒计时开始--可以加速",posNum,self.reTimerNow)
                end
            end
        end
        socketHelper:halloweenReward("plant",callback,"t"..5-sweNum,posNum)
    elseif seedNumTab["t"..5-sweNum]<1 then
        print("种子数量不够！！！！！！")
    elseif NeedTimesTab[posNum] then
    end
end

function acSweetTroubleTab2:tick( )
     -- print("acSweetTroubleTab2:tick( )---->",self.reTimerNow)
    if self.reTimerNow == true then
        -- self.reTimerNow =false
        -- print("here-----self.reTimerNow ==true???")
        acSweetTroubleVoApi:setSubTimes( )
        local reTimesTab = acSweetTroubleVoApi:getNeedTimesTab()
        local allRan = false
        for i=1,6 do
            if reTimesTab[i] then 
                -- print("reTimesTab[i]---->",reTimesTab[i])
                if reTimesTab[i] >-1 then
                    self.reTimeTab[i]:setString(GetTimeStr(reTimesTab[i]))
                    -- print("reTimesTab[i]---->",reTimesTab[i])
                    -- self.reTimerNow =true
                else
                    -- print("here???   reTimesTab[i] <=-1")
                    self.reTimeTab[i]:setString(getlocal("activity_sweettrouble_aging"))
                    self.addTimeTab[i]:setVisible(false)
                    self.retimeBgTab[i]:setVisible(true)
                    self.receiveTab[i]:setVisible(true)
                    self.BoxTab[i]:setVisible(false)
                    self.BoxGrowTab[i]:setVisible(false)
                    self.BoxAgingTab[i]:setVisible(true)
                end
            end
        end
        -- if allRan ==false then
        --     self.reTimerNow = false
        -- end
    end
    if acSweetTroubleVoApi:isChanData(1) ==true then
        -- print("here-----:isChanData(2)???")
        acSweetTroubleVoApi:setChanData(1,false)
        self.seedNumTab = acSweetTroubleVoApi:getTgSeedTab( )
        for i=1,4 do
            self.seedNumShowTab[i]:setString(self.seedNumTab["t"..5-i])
        end
    end
end
function acSweetTroubleTab2:updata( )
    local seedNumTab = acSweetTroubleVoApi:getTgSeedTab( )
    for i=1,4 do
        self.seedNumShowTab[i]:setString(seedNumTab["t"..5-i])
    end
end

function acSweetTroubleTab2:openInfo()
  local td=smallDialog:new()
  local seedNeedTimeTab = acSweetTroubleVoApi:getNeedtimeTab( )
  local showStr = "\n"
  local seedReward = acSweetTroubleVoApi:getSeedNeedReward( )
  local reward = FormatItem(seedReward[1])
  local strSize5 = 20
  if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize5 =23
    end
  for i=1,4 do
        local needTimes = GetTimeStr(seedNeedTimeTab["t"..i]*3600)
        local seedName = getlocal("activity_sweettrouble_seed_"..i)
        
        local reward = FormatItem(seedReward[i])
        local str = getlocal("activity_sweettrouble_seedRward",{i,seedName,needTimes,G_showRewardTip(reward,false,true)})
        showStr = showStr..str.."\n"
  end

  local tabStr = {showStr}
  local dialog=td:init("PanelPopup.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,strSize5,nil)
  sceneGame:addChild(dialog,self.layerNum+1)
end

function acSweetTroubleTab2:dispose( )
    
    self.layerNum=nil
    self.bgLayer=nil
    self.clayer = nil
    self.Height =nil
    self.isMoved=false
    self.touchEnable = nil
    self.touchArr={}
    self.temSp = nil
    self.index=nil
    self.selectType=nil
    self.iconTab = {}
    self.BoxTab ={}
    self.seedNumTab={}
    self.seedNumShowTab={}
    self.BoxGrowTab = {}
    self.BoxAgingTab ={}
    self.reTimeTab={}
    self.addTimeTab = {}
    self.receiveTab ={}
    self.retimeBgTab = {}
    self.reTimerNow =false
    self.lastTouchPic=nil
end