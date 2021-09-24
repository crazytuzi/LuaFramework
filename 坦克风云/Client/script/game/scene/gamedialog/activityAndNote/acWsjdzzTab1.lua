acWsjdzzTab1={
}

function acWsjdzzTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.isFree=false
    self.selectIndex=nil
    self.touchLayer=nil
    self.cell=nil
    self.bgList={}
    self.selectList={}

    return nc;
end

function acWsjdzzTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.activeName=acWsjdzzVoApi:getActiveName()
    if(acWsjdzzVoApi:isNormalVersion())then
        spriteController:addPlist("public/taskYouhua.plist")
        spriteController:addTexture("public/taskYouhua.png")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        spriteController:addPlist("public/acChunjiepansheng.plist")
        spriteController:addTexture("public/acChunjiepansheng.png")
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
        CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    end
    self.rows=acWsjdzzVoApi:getMapRow()
    self.normal1Tb,self.normal2Tb,self.normal3Tb,self.boss1Tb,self.boss2Tb=acWsjdzzVoApi:getNormalAndBoss()

    local function onRechargeChange(event,data)
        self:refreshUI()
    end
    self.wsjdzzListener=onRechargeChange
    eventDispatcher:addEventListener("activity.recharge",onRechargeChange)


    self.layerNum = layerNum
    self.parent = parent
    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acWsjdzzTab1:initUI()
    local acBg
    if(acWsjdzzVoApi and acWsjdzzVoApi:isNormalVersion())then
        acBg=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        local count=math.floor((G_VisibleSizeHeight - 200)/acBg:getContentSize().height)
        local height=(G_VisibleSizeHeight - 200)/count
        local scale=height/acBg:getContentSize().height
        for i=1,count do
            acBg=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
            acBg:setAnchorPoint(ccp(0.5,0))
            acBg:setScaleX((G_VisibleSizeWidth - 50)/acBg:getContentSize().width)
            acBg:setScaleY(scale)
            acBg:setPosition(G_VisibleSizeWidth/2,35 + height*(i - 1))
            self.bgLayer:addChild(acBg)
        end
        local redBg=CCSprite:createWithSpriteFrameName("acChunjianpansheng_redLine.png")
        redBg:setScaleX(800/redBg:getContentSize().width)
        redBg:setScaleY((G_VisibleSizeWidth - 50)/redBg:getContentSize().height)
        redBg:setRotation(90)
        if(G_isIphone5())then
            redBg:setPosition(G_VisibleSizeWidth/2,470)
        else
            redBg:setPosition(G_VisibleSizeWidth/2,370)
        end
        self.bgLayer:addChild(redBg)
    else
        acBg=CCSprite:create("public/acWanshengjiedazuozhanBg.jpg")
        acBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50))
        acBg:setScale(0.95)
        self.bgLayer:addChild(acBg)
    end

    local addH=0
    if(G_isIphone5())then
        addH=15
    end

    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185-addH))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)
    
    local acVo = acWsjdzzVoApi:getAcVo()
    if acVo==nil then
        do return end
    end

    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,26)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220-addH))
    self.bgLayer:addChild(timeLabel)

    self.timeLabel = timeLabel
    self:updateAcTime()

    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local td=smallDialog:new()
        local str1,str2,str3,str4,str5
        if(acWsjdzzVoApi:isNormalVersion())then
            str1=getlocal("activity_wanshengjiedazuozhan_desc_1_n")
            str2=getlocal("activity_wanshengjiedazuozhan_desc_2_n")
            str3=getlocal("activity_wanshengjiedazuozhan_desc_3_n")
        else
            str1=getlocal("activity_wanshengjiedazuozhan_desc_1")
            str2=getlocal("activity_wanshengjiedazuozhan_desc_2")
            str3=getlocal("activity_wanshengjiedazuozhan_desc_3")
        end
        str4=getlocal("activity_wanshengjiedazuozhan_desc_4")
        str5=getlocal("activity_wanshengjiedazuozhan_desc_5")
        local tabStr={" ",str5,str4,str3,str2,str1," "}
        local colorTab={}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTab)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-200-addH))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu,3)

    local addH2=0
    if(G_isIphone5())then
        addH2=35
    end

    local timerScale=0.55
    local life,maxLife=acVo.bossLife[1],acVo.bossLife[1]
    if acVo.curBossLife and acVo.curBossLife[1] then
        life=tonumber(acVo.curBossLife[1]) or 0
    end
    if acVo.bossLife and acVo.bossLife[1] then
        maxLife=tonumber(acVo.bossLife[1]) or 0
    end
    local rateStr=life.."/"..maxLife

    AddProgramTimer(self.bgLayer,ccp(150,self.bgLayer:getContentSize().height-265-addH2),101,102,rateStr,"platWarProgressBg.png","platWarProgress1.png",103,timerScale)
    local timerSprite = tolua.cast(self.bgLayer:getChildByTag(101),"CCProgressTimer")

    -- timerSprite:setMidpoint(ccp(1,1))
    local timerLb = tolua.cast(timerSprite:getChildByTag(102),"CCLabelTTF")
    timerLb:setScaleX(1/timerScale)
    local percentage=0
    percentage=life/maxLife
    if percentage<0 then
        percentage=0
    end
    if percentage>1 then
        percentage=1
    end
    timerSprite:setPercentage(percentage*100)
    timerSprite:setRotation(180)
    timerLb:setRotation(-180)

    local lbBg=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    lbBg:setPosition(timerSprite:getContentSize().width/2,timerSprite:getContentSize().height/2)
    timerSprite:addChild(lbBg,3)
    lbBg:setScaleX(1/timerScale*120/lbBg:getContentSize().width)
    lbBg:setScaleY(1/timerScale*18/lbBg:getContentSize().height)

    local life2,maxLife2=acVo.bossLife[2],acVo.bossLife[2]
    if acVo.curBossLife and acVo.curBossLife[2] then
        life2=tonumber(acVo.curBossLife[2]) or 0
    end
    if acVo.bossLife and acVo.bossLife[2] then
        maxLife2=tonumber(acVo.bossLife[2]) or 0
    end
    local rateStr2=life2.."/"..maxLife2
    AddProgramTimer(self.bgLayer,ccp(self.bgLayer:getContentSize().width-150,self.bgLayer:getContentSize().height-265-addH2),201,202,rateStr2,"platWarProgressBg.png","platWarProgress1.png",203,timerScale)
    local timerSprite2 = tolua.cast(self.bgLayer:getChildByTag(201),"CCProgressTimer")
    local timerLb2 = tolua.cast(timerSprite2:getChildByTag(202),"CCLabelTTF")
    timerLb2:setScaleX(1/timerScale)
    -- timerSprite2:setMidpoint(ccp(1,1))
    local percentage=0
    percentage=life2/maxLife2
    if percentage<0 then
        percentage=0
    end
    if percentage>1 then
        percentage=1
    end
    timerSprite2:setPercentage(percentage*100)

    local lbBg2=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    lbBg2:setPosition(timerSprite2:getContentSize().width/2,timerSprite2:getContentSize().height/2)
    timerSprite2:addChild(lbBg2,3)
    lbBg2:setScaleX(1/timerScale*120/lbBg2:getContentSize().width)
    lbBg2:setScaleY(1/timerScale*18/lbBg2:getContentSize().height)

    

    local function showReward(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local acVo=acWsjdzzVoApi:getAcVo()
        if acVo and acVo.reward and SizeOfTable(acVo.reward)>0 then
            local showType
            local reward
            if tag==301 then
                showType=1
                reward={acVo.reward.normal1,acVo.reward.boss1}
            elseif tag==302 then
                showType=2
                reward={acVo.reward.normal2,acVo.reward.boss2}
            else
                showType=3
                reward={acVo.reward.normal3}
            end
            local title
            if(acWsjdzzVoApi:isNormalVersion())then
                title=getlocal("activity_wanshengjiedazuozhan_pumpkin"..showType.."_n")..getlocal("activity_wanshengjiedazuozhan_reward_pool")
            else
                title=getlocal("activity_wanshengjiedazuozhan_pumpkin"..showType)..getlocal("activity_wanshengjiedazuozhan_reward_pool")
            end

            require "luascript/script/game/scene/gamedialog/activityAndNote/acWsjdzzSmallDialog"
            local height=850
            if SizeOfTable(reward)==1 then
                height=540
            end
            local titleSize = 35
            if G_getCurChoseLanguage()=="ru" then
                titleSize =30
            end
            acWsjdzzSmallDialog:showWsjdzzRewardDialog("TankInforPanel.png",CCSizeMake(550,height),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,showType,reward,title,titleSize)
        end
    end
    local leftSp
    local rightSp
    leftSp=LuaCCSprite:createWithSpriteFrameName("event_goldbg.png",showReward)
    rightSp=LuaCCSprite:createWithSpriteFrameName("event_goldbg.png",showReward)
    leftSp:setPosition(ccp(90,self.bgLayer:getContentSize().height-327-addH2))
    rightSp:setPosition(ccp(self.bgLayer:getContentSize().width-90,self.bgLayer:getContentSize().height-327-addH2))
    self.bgLayer:addChild(leftSp,3)
    self.bgLayer:addChild(rightSp,3)
    leftSp:setTouchPriority(-(self.layerNum-1)*20-4)
    rightSp:setTouchPriority(-(self.layerNum-1)*20-4)
    leftSp:setTag(301)
    rightSp:setTag(302)

    local neiSp1
    if(acWsjdzzVoApi:isNormalVersion())then
        neiSp1=CCSprite:createWithSpriteFrameName("taskBox3.png")
    else
        neiSp1=CCSprite:createWithSpriteFrameName("pumpkinA1.png")
    end
    leftSp:addChild(neiSp1)
    neiSp1:setPosition(leftSp:getContentSize().width/2,leftSp:getContentSize().height/2+3)
    neiSp1:setScale(0.63)

    local neiSp2
    if(acWsjdzzVoApi:isNormalVersion())then
        neiSp2=CCSprite:createWithSpriteFrameName("taskBox4.png")
    else
        neiSp2=CCSprite:createWithSpriteFrameName("pumpkinB1.png")
    end
    rightSp:addChild(neiSp2)
    neiSp2:setPosition(rightSp:getContentSize().width/2-2,rightSp:getContentSize().height/2+3)
    neiSp2:setScale(0.69)

    local vsScale=1.2
    local vSp=LuaCCSprite:createWithSpriteFrameName("event_goldbg.png",showReward)
    -- CCSprite:createWithSpriteFrameName("event_goldbg.png")
    vSp:setTouchPriority(-(self.layerNum-1)*20-4)
    local sSp
    if(acWsjdzzVoApi:isNormalVersion())then
        sSp=CCSprite:createWithSpriteFrameName("taskBox5.png")
    else
        sSp=CCSprite:createWithSpriteFrameName("pumpkinC1.png")
    end
    vSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-330-addH2))
    sSp:setPosition(ccp(vSp:getContentSize().width/2,vSp:getContentSize().height/2+2))
    vSp:setScale(vsScale)
    sSp:setScale(1/vsScale*0.7)
    self.bgLayer:addChild(vSp,3)
    vSp:addChild(sSp,3)
    vSp:setTag(303)

    local function rewardRecordsHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function showLog()
            acWsjdzzVoApi:showLogRecord(self.layerNum+1,self.normal1Tb,self.normal2Tb,self.normal3Tb,self.boss1Tb,self.boss2Tb)
        end
        acWsjdzzVoApi:getLog(self.activeName,showLog)
    end
    local recordBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",rewardRecordsHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(G_VisibleSizeWidth-recordBtn:getContentSize().width+15,self.bgLayer:getContentSize().height-420-addH2-20))
    self.bgLayer:addChild(recordMenu)

    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setAnchorPoint(ccp(0.5,1))
    recordLb:setPosition(recordBtn:getContentSize().width*recordBtn:getScale()/2,-5)
    recordLb:setScale(1/recordBtn:getScale())
    recordBtn:addChild(recordLb)


    local isFree=acWsjdzzVoApi:isFree()

    local addh=0
    if(G_isIphone5())then
        addh=20
    end

    self.goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-20,130+addh))
    self.bgLayer:addChild(self.goldSp,3)
    self.costLb=GetTTFLabel(acVo.cost or 0,25)
    self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,130+addh))
    self.bgLayer:addChild(self.costLb,3)

    self:refreshUI()
end

function acWsjdzzTab1:updateBar(pType,value)
    if self.bgLayer then
        local acVo=acWsjdzzVoApi:getAcVo()
        local life,maxLife=0,0
        if value then
            life=tonumber(value) or 0
        elseif acVo.curBossLife and acVo.curBossLife[1] then
            life=tonumber(acVo.curBossLife[1]) or 0
        end
        if acVo.bossLife and acVo.bossLife[1] then
            maxLife=tonumber(acVo.bossLife[1]) or 0
        end
        local tag=101
        if pType==2 then
            tag=tag+100
        end
        local timerSprite = tolua.cast(self.bgLayer:getChildByTag(tag),"CCProgressTimer")
        if timerSprite then
            local percentage=0
            percentage=life/maxLife
            if percentage<0 then
                percentage=0
            end
            if percentage>1 then
                percentage=1
            end
            timerSprite:setPercentage(percentage*100)
            local timerLb = tolua.cast(timerSprite:getChildByTag(tag+1),"CCLabelTTF")
            if timerLb then
                local rateStr=life.."/"..maxLife
                timerLb:setString(rateStr)
            end
        end
    end
end

function acWsjdzzTab1:initTableView()

    self.tvaddH=0
    if(G_isIphone5())then
        self.tvaddH=70
    end

    local startH=G_VisibleSize.height-550-self.tvaddH-73
    self.mapPos={ccp(188, startH),ccp(319, startH),ccp(451, startH),ccp(122, startH-114),ccp(254, startH-114),ccp(385, startH-114),ccp(517, startH-114),ccp(188, startH-228),ccp(319, startH-228),ccp(451, startH-228)}

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height-550-self.tvaddH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,145))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(0)
end

function acWsjdzzTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height-550-self.tvaddH)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local mapPos=self.mapPos

        local map=acWsjdzzVoApi:getList()

        self.bgList={}
        for k,v in pairs(mapPos) do
            -- 南瓜背景
            local pumpkinBg=CCSprite:createWithSpriteFrameName("wsjdzz_di1.png")
            cell:addChild(pumpkinBg)
            pumpkinBg:setPosition(v)

            table.insert(self.bgList,pumpkinBg)

            -- 选中亮框
            local selectSp=CCSprite:createWithSpriteFrameName("wsjdzz_select.png")
            selectSp:setPosition(getCenterPoint(pumpkinBg))
            pumpkinBg:addChild(selectSp)
            selectSp:setTag(902)
            selectSp:setVisible(false)

            -- 南瓜头
            local pic=self:getIconPic(map[k])

            local function clickHandler(hd,fn,idx)
                self:refreshSelectSp(idx)
            end

            if pic then
                local pumpkinSp=LuaCCSprite:createWithSpriteFrameName(pic,clickHandler)
                if pumpkinSp then
                    pumpkinSp:setPosition(v)
                    pumpkinSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(pumpkinSp,1)
                    pumpkinSp:setTag(k)
                end
            end
        end

        self.cell=cell
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acWsjdzzTab1:getIconPic(num)
    local pic
    if(acWsjdzzVoApi:isNormalVersion())then
        pic="taskBox"..tostring(num + 2)..".png"
    else
        if num==1 then
            pic="pumpkinA1.png"
        elseif num==2 then
            pic="pumpkinB1.png"
        elseif num==3 then
            pic="pumpkinC1.png"
        end
    end
    return pic
end

function acWsjdzzTab1:refreshSelectSp(idx)

    PlayEffect(audioCfg.mouseClick)

    self.selectIndex=idx
    self.selectList={0,0,0,0,0,0,0,0,0,0}
    self.selectList[idx]=1
    self.selectList=self:getSelectList(idx)
    for m,n in pairs(self.selectList) do
        local slSp=tolua.cast(self.bgList[m]:getChildByTag(902),"CCSprite")
        local pumpkinSp=tolua.cast(self.cell:getChildByTag(m),"LuaCCSprite")
        pumpkinSp:stopAllActions()
        pumpkinSp:setOpacity(255)
        if n==1 then
            slSp:setVisible(true)
            pumpkinSp:runAction(self:getFadeFunc())
        else
            slSp:setVisible(false)
        end    
    end
end

function acWsjdzzTab1:getFadeFunc()
    local fadeAc1=CCFadeTo:create(0.2, 100)
    local fadeAc2=CCFadeTo:create(0.2, 255)
    local fadeAc3=CCFadeTo:create(0.2, 100)
    local fadeAc4=CCFadeTo:create(0.2, 255)
    -- local fadeAc5=CCFadeTo:create(0.3, 100)
    local arrAc=CCArray:create()
    arrAc:addObject(fadeAc1)
    arrAc:addObject(fadeAc2)
    arrAc:addObject(fadeAc3)
    arrAc:addObject(fadeAc4)
    local seq=CCSequence:create(arrAc)
    return seq
end


function acWsjdzzTab1:getSelectList(sIndex)
    local map=acWsjdzzVoApi:getList()

    local function getAroundCellById(id)
        local t = {}
        local pos1 = {-4,-3,3,4}
        local pos2 = {1,-1}

        for _,v in ipairs(pos1) do
            local n = id+v
            if map[n] and self.rows[id] ~= self.rows[n] then
              table.insert(t,n)
            end 
        end

        for k,v in pairs(pos2) do
            local n = id+v
            if self.rows[id] == self.rows[n] then
                table.insert(t,n)
            end  
        end

        return t
    end

    local function clearPumpkin(id,cells)
        if not cells then cells = {[id]=1} end

            local cellType = map[id]
            local aroundCells = getAroundCellById(id)

            for k,v in pairs(aroundCells) do
                if cells[v]==0 and map[v] == cellType then
                    cells[v] = 1
                    clearPumpkin(v,cells)
                end
            end

        return cells
    end
    local around = clearPumpkin(sIndex,self.selectList)
    return around
end

function acWsjdzzTab1:fire()
    if self.selectIndex then
        local free=acWsjdzzVoApi:isFree()
        if free==true then
        else
            local acVo = acWsjdzzVoApi:getAcVo()
            local costGem=0
            if acVo and acVo.cost then
                costGem=tonumber(acVo.cost)
                if(costGem>playerVoApi:getGems())then
                    GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
                    do return end
                end
            end
        end
        -- self.selectIndex
        local function activeCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data then
                    self:addTouchLayer()
                    local oldVo = G_clone(acWsjdzzVoApi:getAcVo())
                    if sData.data[self.activeName] then
                        acWsjdzzVoApi:updateData(sData.data[self.activeName])
                        if self.parent and self.parent.refresh then
                            self.parent:refresh()
                        end
                    end
                    self.isFree=acWsjdzzVoApi:isFree()
                    if sData and sData.data and sData.data.accessory and accessoryVoApi then
                        accessoryVoApi:onRefreshData(sData.data.accessory)
                    end
                    if sData and sData.data and sData.data.alien and alienTechVoApi then
                        alienTechVoApi:setTechData(sData.data.alien)
                    end
                    if not oldVo.map then
                        oldVo.map=oldVo.map2
                    end
                    if sData and sData.data and sData.data.report then
                        acWsjdzzVoApi:setLog(sData,oldVo.map[self.selectIndex])
                    end

                    if self.bgList then
                        local tTime=0.3
                        --血条动画
                        if oldVo and oldVo.map and self.selectIndex and oldVo.map[self.selectIndex] then
                            local pType=oldVo.map[self.selectIndex]
                            if pType==1 or pType==2 then
                                local oldLife=oldVo.bossLife[pType]
                                local curLife
                                local acVo=acWsjdzzVoApi:getAcVo()
                                if acVo.curBossLife and acVo.curBossLife[pType] then
                                    curLife=acVo.curBossLife[pType]
                                end
                                if oldVo.curBossLife and oldVo.curBossLife[pType] then
                                    oldLife=oldVo.curBossLife[pType]
                                end
                                if curLife>oldLife then
                                    curLife=0
                                end
                                local function func1( ... )
                                    self:updateBar(pType,oldLife)
                                end
                                local function func2( ... )
                                    self:updateBar(pType,curLife)
                                end
                                local delay=CCDelayTime:create(tTime)
                                local acFunc1=CCCallFuncN:create(func1)
                                local acFunc2=CCCallFuncN:create(func2)
                                local arr=CCArray:create()
                                arr:addObject(delay)
                                arr:addObject(acFunc2)
                                arr:addObject(delay)
                                arr:addObject(acFunc1)
                                arr:addObject(delay)
                                arr:addObject(acFunc2)
                                local seq=CCSequence:create(arr)
                                self.bgLayer:runAction(seq)
                            end
                        end

                        --南瓜动画
                        self:eliminatePumpkinAct(sData.data.newItem,sData,oldVo)
                        do return end

                    end

                end
            end
        end
        local cmdStr="active.halloween2016.clear"
        local index=self.selectIndex
        socketHelper:activityWsjdzz(cmdStr,index,nil,free,activeCallback)
    else
        local failStr
        if(acWsjdzzVoApi:isNormalVersion())then
            failStr=getlocal("activity_wanshengjiedazuozhan_fire_fail_n")
        else
            failStr=getlocal("activity_wanshengjiedazuozhan_fire_fail")
        end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),failStr,30)
    end
end

function acWsjdzzTab1:eliminatePumpkinAct(newItem,sData,oldVo)

    local function addAnimate(parent)
        local pzFrameName="wsjdzz_frame1.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height/2))
        parent:addChild(metalSp,2)
        metalSp:setTag(201)
        metalSp:setScale(1.4)

        local pzArr=CCArray:create()
        for kk=1,16 do
            local nameStr="wsjdzz_frame"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.02)
        local animate=CCAnimate:create(animation)
        metalSp:runAction(animate)
    end

    local function removeAnimate(parent)
        local metalSp=tolua.cast(parent:getChildByTag(201),"CCSprite")
        if metalSp~=nil then
            metalSp:removeFromParentAndCleanup(true)
            metalSp=nil
        end
    end

    local flag=false
    PlayEffect(audioCfg.eliminate)

    for k,v in pairs(self.selectList) do
        if v==1 then
            local pumpkinSp=tolua.cast(self.cell:getChildByTag(k),"CCSprite")
            pumpkinSp:removeFromParentAndCleanup(true)
            local slSp=tolua.cast(self.bgList[k]:getChildByTag(902),"CCSprite")
            slSp:setVisible(false)

            local acArr=CCArray:create()

            local function addAnimateFunc()
                addAnimate(self.bgList[k])
            end
            local function removeAnimateFunc()
                removeAnimate(self.bgList[k])

                -- 保证只调用一次，防止每一消除的南瓜都调用
                if not flag then
                    self:downAndfil(newItem,sData,oldVo)
                    flag=true
                end
            end

            -- 第二版 播放帧动画
            local addF=CCCallFunc:create(addAnimateFunc)
            local removeF=CCCallFunc:create(removeAnimateFunc)
            acArr:addObject(addF)
            local delay3=CCDelayTime:create(16*0.02)
            acArr:addObject(delay3)
            acArr:addObject(removeF)

            local seq=CCSequence:create(acArr)
            self.bgList[k]:runAction(seq)
        end
    end

end

function acWsjdzzTab1:downAndfil(newItem,sData,oldVo)

    local mapPos=self.mapPos

    local mapRows=acWsjdzzVoApi:getMapRows()

    local function clearAndFile(n)
        -- 从最后一行开始遍历
        for i = 3, 1, -1 do
            for k,v in pairs(mapRows[i]) do
                local pumpkinSp=tolua.cast(self.cell:getChildByTag(v),"LuaCCSprite")
                if not pumpkinSp then
                    if self.rows[v]==1 then
                        -- 第一行位置不南瓜，并且做下落效果
                        local function clickHandler(hd,fn,idx)
                            self:refreshSelectSp(idx)
                        end

                        local pic=self:getIconPic(n[v])
                       
                        local pumpkinSp=LuaCCSprite:createWithSpriteFrameName(pic,clickHandler)
                        if pumpkinSp then
                            pumpkinSp:setPosition(mapPos[v].x,mapPos[v].y+130)
                            pumpkinSp:setTouchPriority(-(self.layerNum-1)*20-2)
                            self.cell:addChild(pumpkinSp,1)
                            pumpkinSp:setTag(v)

                            local moveTo=CCMoveTo:create(0.2,mapPos[v])
                            pumpkinSp:runAction(moveTo)
                        end
                    else
                        -- 不是第一行，要判断上面的行能不能补{-4，-3}并且不在同一行
                        local subTb={-4,-3}
                        for kk,vv in pairs(subTb) do
                            if self.rows[v]~=self.rows[v+vv] then
                                local pumpkinSp=tolua.cast(self.cell:getChildByTag(v+vv),"LuaCCSprite")
                                if pumpkinSp then
                                    pumpkinSp:stopAllActions()
                                    pumpkinSp:setTag(v)
                                    local moveTo=CCMoveTo:create(0.2,mapPos[v])
                                    pumpkinSp:runAction(moveTo)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function clear(item)
        if item and SizeOfTable(item)>0 and SizeOfTable(item[1])>0 then
            local function acCallfunc1()
                clearAndFile(item[1])
                table.remove(item,1)
            end
            local clearFunc=CCCallFunc:create(acCallfunc1)
            local acArr=CCArray:create()

            acArr:addObject(clearFunc)

            local delay=CCDelayTime:create(0.2)
            acArr:addObject(delay)

            local function acCallfunc2()
                clear(item)
            end
            local clearFunc2=CCCallFunc:create(acCallfunc2)
            acArr:addObject(clearFunc2)

            local seq=CCSequence:create(acArr)
            self.bgLayer:runAction(seq)
        else
            local function acCallfunc1()
                self.bgLayer:stopAllActions()
                self:clearEnd(sData,oldVo)
            end
            local endFunc=CCCallFunc:create(acCallfunc1)
            local acArr=CCArray:create()
            local delay=CCDelayTime:create(0.1)
            acArr:addObject(delay)
            acArr:addObject(endFunc)
            local seq=CCSequence:create(acArr)
            self.bgLayer:runAction(seq)
        end
    end
    clear(newItem)
end

function acWsjdzzTab1:clearEnd(sData,oldVo)
    if sData.data.report then
        local content={}
        if sData.data.report.normal then
            local rewardData=sData.data.report.normal
            for k,v in pairs(rewardData) do
                local awardTb=FormatItem(v)
                for m,n in pairs(awardTb) do
                    local award=n or {}
                    table.insert(content,award)
                end
            end
                -- G_showRewardTip(content,true)
            local acVo = acWsjdzzVoApi:getAcVo()
            local num=SizeOfTable(rewardData)
            if num and acVo and num>=acVo.noticeNum then
                local paramTab={}
                paramTab.functionStr="wsjdzz"
                paramTab.addStr="take_part"
                local chatKey
                if(acWsjdzzVoApi:isNormalVersion())then
                    chatKey="activity_wanshengjiedazuozhan_chat1_n"
                else
                    chatKey="activity_wanshengjiedazuozhan_chat1"
                end
                local message={key=chatKey,param={playerVoApi:getPlayerName(),num}}
                chatVoApi:sendSystemMessage(message,paramTab)
            end
        end
        if sData.data.report.boss then
            local rewardData=sData.data.report.boss
            for k,v in pairs(rewardData) do
                -- local award=FormatItem(v)
                local awardTb=FormatItem(v)
                for m,n in pairs(awardTb) do
                    local award=n or {}
                    table.insert(content,award)
                end
                -- G_showRewardTip(award,true)

                local awardStr=G_showRewardTip(awardTb,false,true)
                local pname=""
                if oldVo and oldVo.map and self.selectIndex and oldVo.map[self.selectIndex] then
                    local pType=oldVo.map[self.selectIndex]
                    if(acWsjdzzVoApi:isNormalVersion())then
                        pname=getlocal("activity_wanshengjiedazuozhan_pumpkin"..pType.."_n")
                    else
                        pname=getlocal("activity_wanshengjiedazuozhan_pumpkin"..pType)
                    end
                end
                local paramTab={}
                paramTab.functionStr="wsjdzz"
                paramTab.addStr="take_part"
                local chatKey1
                if(acWsjdzzVoApi:isNormalVersion())then
                    chatKey1="activity_wanshengjiedazuozhan_chat2_n"
                else
                    chatKey1="activity_wanshengjiedazuozhan_chat2"
                end
                local message={key=chatKey1,param={playerVoApi:getPlayerName(),pname,awardStr}}
                chatVoApi:sendSystemMessage(message,paramTab)
            end
        end
        G_showRewardTip(content,true)
    end

    self.selectIndex=nil
    self.selectList={0,0,0,0,0,0,0,0,0,0}
    self:refreshUI()
    self.tv:reloadData()
    self:removeTouchLayer()
end



function acWsjdzzTab1:refreshUI()
    local acVo = acWsjdzzVoApi:getAcVo()
    local isFree=acWsjdzzVoApi:isFree()

    local addh=0
    if(G_isIphone5())then
        addh=20
    end

    if isFree==true then
        if self.goldSp then
            self.goldSp:setVisible(false)
        end
        if self.costLb then
            self.costLb:setString(getlocal("daily_lotto_tip_2"))
            self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,130+addh))
        end
    else
        if self.goldSp then
            self.goldSp:setVisible(true)
        end
        local cost=0
        if acVo and acVo.cost then
            cost=tonumber(acVo.cost) or 0
        end
        if self.costLb then
            self.costLb:setString(cost)
            self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,130+addh))
            if playerVoApi:getGems()<cost then
                self.costLb:setColor(G_ColorRed)
            else
                self.costLb:setColor(G_ColorWhite)
            end
        end
    end

    if self.fireMenu then
        self.fireMenu:removeFromParentAndCleanup(true)
        self.fireMenu=nil
    end
    local function fireHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        self:fire()
    end
    local fireItem
    local bStr=getlocal("activity_wanshengjiedazuozhan_fire")
    if isFree==true then
        fireItem = GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",fireHandler,21,bStr,25)
    else
        fireItem = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",fireHandler,21,bStr,25)
    end
    
    self.fireMenu = CCMenu:createWithItem(fireItem)
    self.fireMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70+addh))
    self.fireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.fireMenu,3)

    if self and self.bgLayer then
        local timerSprite = tolua.cast(self.bgLayer:getChildByTag(101),"CCProgressTimer")
        if timerSprite then
            local life,maxLife=acVo.bossLife[1],acVo.bossLife[1]
            if acVo and acVo.curBossLife and acVo.curBossLife[1] then
                life=tonumber(acVo.curBossLife[1]) or 0
            end
            if  acVo and acVo.bossLife and acVo.bossLife[1] then
                maxLife=tonumber(acVo.bossLife[1]) or 0
            end
            local rateStr=life.."/"..maxLife
            local timerLb = tolua.cast(timerSprite:getChildByTag(102),"CCLabelTTF")
            if timerLb then
                timerLb:setString(rateStr)
            end
            local percentage=0
            percentage=life/maxLife
            if percentage<0 then
                percentage=0
            end
            if percentage>1 then
                percentage=1
            end
            timerSprite:setPercentage(percentage*100)
        end

        local timerSprite2 = tolua.cast(self.bgLayer:getChildByTag(201),"CCProgressTimer")
        if timerSprite2 then
            local life2,maxLife2=acVo.bossLife[2],acVo.bossLife[2]
            if acVo and acVo.curBossLife and acVo.curBossLife[2] then
                life2=tonumber(acVo.curBossLife[2]) or 0
            end
            if acVo and acVo.bossLife and acVo.bossLife[2] then
                maxLife2=tonumber(acVo.bossLife[2]) or 0
            end
            local rateStr2=life2.."/"..maxLife2
            local timerLb2 = tolua.cast(timerSprite2:getChildByTag(202),"CCLabelTTF")
            timerLb2:setString(rateStr2)
            local percentage=0
            percentage=life2/maxLife2
            if percentage<0 then
                percentage=0
            end
            if percentage>1 then
                percentage=1
            end
            timerSprite2:setPercentage(percentage*100)
        end
    end
end

function acWsjdzzTab1:addTouchLayer()
    self.touchLayer=CCLayer:create()
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setBSwallowsTouches(true)
    self.touchLayer:setTouchPriority(-188)
    self.touchLayer:setContentSize(G_VisibleSize)
    self.bgLayer:addChild(self.touchLayer)
end
function acWsjdzzTab1:removeTouchLayer()
    if self.touchLayer then
        self.touchLayer:removeFromParentAndCleanup(true)
        self.touchLayer=nil
    end
end

function acWsjdzzTab1:updateAcTime()
    local acVo=acWsjdzzVoApi:getAcVo()
    if acVo and self.timeLabel and tolua.cast(self.timeLabel,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLabel)
    end
end
function acWsjdzzTab1:tick()
    self:updateAcTime()
    local isFree=acWsjdzzVoApi:isFree()
    if self.isFree~=isFree then
        self.isFree=true
        self:refreshUI()
    end
end

function acWsjdzzTab1:dispose()
    eventDispatcher:removeEventListener("activity.recharge",self.wsjdzzListener)
    self.cell=nil
    self.bgList={}
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    if self.touchLayer then
        self.touchLayer:removeFromParentAndCleanup(true)
    end
    self.touchLayer=nil
    self.tv=nil
    self.layerNum=nil
    self.isFree=false
    self.selectIndex=nil
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhanBg.jpg")
    if(acWsjdzzVoApi:isNormalVersion())then
        spriteController:removePlist("public/taskYouhua.plist")
        spriteController:removeTexture("public/taskYouhua.png")
        spriteController:removePlist("public/acChunjiepansheng.plist")
        spriteController:removeTexture("public/acChunjiepansheng.png")
    end
end
