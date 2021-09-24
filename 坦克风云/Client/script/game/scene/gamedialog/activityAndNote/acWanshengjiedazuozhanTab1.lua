acWanshengjiedazuozhanTab1={
   rewardBtnState = nil,
}

function acWanshengjiedazuozhanTab1:new()
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
    -- self.spList={}

    return nc;
end

function acWanshengjiedazuozhanTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    

    self.layerNum = layerNum
    self.parent = parent
    self:initUI()
    self:initTableView()
    return self.bgLayer
end


function acWanshengjiedazuozhanTab1:initUI()
    local acBg
    local version=acWanshengjiedazuozhanVoApi:getVersion()
    if version and version>1 then
        acBg=CCSprite:create("public/acWanshengjiedazuozhanBg"..version..".jpg")
    else
        acBg=CCSprite:create("public/acWanshengjiedazuozhanBg.jpg")
    end
    acBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-50))
    acBg:setScale(0.95)
    self.bgLayer:addChild(acBg)


    local actTime=GetTTFLabel(getlocal("activity_timeLabel"),30)
    actTime:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-185))
    self.bgLayer:addChild(actTime,5)
    actTime:setColor(G_ColorGreen)
    
    local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
    if acVo==nil then
        do return end
    end

    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local timeLabel=GetTTFLabel(timeStr,26)
    timeLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-220))
    self.bgLayer:addChild(timeLabel)
    self.timeLb=timeLabel
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
        local str1=getlocal("activity_wanshengjiedazuozhan_desc_1")
        local str2=getlocal("activity_wanshengjiedazuozhan_desc_2")
        local str3=getlocal("activity_wanshengjiedazuozhan_desc_3")
        local str4=getlocal("activity_wanshengjiedazuozhan_desc_4")
        local str5=getlocal("activity_wanshengjiedazuozhan_desc_5")
        if version and version>1 then
            str1=getlocal("activity_wanshengjiedazuozhan_desc_1_"..version)
            str2=getlocal("activity_wanshengjiedazuozhan_desc_2_"..version)
            str3=getlocal("activity_wanshengjiedazuozhan_desc_3_"..version)
            str4=getlocal("activity_wanshengjiedazuozhan_desc_4_"..version)
            str5=getlocal("activity_wanshengjiedazuozhan_desc_5_"..version)
        end
        local tabStr={" ",str5,str4,str3,str2,str1," "}
        local colorTab={}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTab)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local menuItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-200))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu,3)

    local timerScale=0.55
    local life,maxLife=0,0
    if acVo.curBossLife and acVo.curBossLife[1] then
        life=tonumber(acVo.curBossLife[1]) or 0
    end
    if acVo.bossLife and acVo.bossLife[1] then
        maxLife=tonumber(acVo.bossLife[1]) or 0
    end
    local rateStr=life.."/"..maxLife
    AddProgramTimer(self.bgLayer,ccp(150,self.bgLayer:getContentSize().height-265),101,102,rateStr,"VipIconYellowBarBg.png","VipIconYellowBar.png",103,timerScale)
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

    local life2,maxLife2=0,0
    if acVo.curBossLife and acVo.curBossLife[2] then
        life2=tonumber(acVo.curBossLife[2]) or 0
    end
    if acVo.bossLife and acVo.bossLife[2] then
        maxLife2=tonumber(acVo.bossLife[2]) or 0
    end
    local rateStr2=life2.."/"..maxLife2
    AddProgramTimer(self.bgLayer,ccp(self.bgLayer:getContentSize().width-150,self.bgLayer:getContentSize().height-265),201,202,rateStr2,"VipIconYellowBarBg.png","VipIconYellowBar.png",203,timerScale)
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

    local vsScale=0.5
    local vSp=CCSprite:createWithSpriteFrameName("v.png")
    local sSp=CCSprite:createWithSpriteFrameName("s.png")
    vSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-25,self.bgLayer:getContentSize().height-330))
    sSp:setPosition(ccp(self.bgLayer:getContentSize().width/2+25,self.bgLayer:getContentSize().height-330))
    vSp:setScale(vsScale)
    sSp:setScale(vsScale)
    self.bgLayer:addChild(vSp,3)
    self.bgLayer:addChild(sSp,3)

    local function showReward(object,fn,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        local acVo=acWanshengjiedazuozhanVoApi:getAcVo()
        if acVo and acVo.reward and SizeOfTable(acVo.reward)>0 then
            local showType
            local reward
            if tag==301 then
                showType=1
                reward={acVo.reward.normal1,acVo.reward.boss1}
            elseif tag==302 then
                showType=2
                reward={acVo.reward.normal2,acVo.reward.boss2}
            end
            smallDialog:showAcWanchengjieRewardDialog("TankInforPanel.png",CCSizeMake(550,850),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,showType,reward)
        end
    end
    local leftSp
    local rightSp
    if version and version>1 then
        leftSp=LuaCCSprite:createWithSpriteFrameName("pumpkinA1"..version..".png",showReward)
        rightSp=LuaCCSprite:createWithSpriteFrameName("pumpkinB1"..version..".png",showReward)
    else
        leftSp=LuaCCSprite:createWithSpriteFrameName("pumpkinA1.png",showReward)
        rightSp=LuaCCSprite:createWithSpriteFrameName("pumpkinB1.png",showReward)
    end
    leftSp:setPosition(ccp(90,self.bgLayer:getContentSize().height-330))
    rightSp:setPosition(ccp(self.bgLayer:getContentSize().width-90,self.bgLayer:getContentSize().height-330))
    self.bgLayer:addChild(leftSp,3)
    self.bgLayer:addChild(rightSp,3)
    leftSp:setTouchPriority(-(self.layerNum-1)*20-4)
    rightSp:setTouchPriority(-(self.layerNum-1)*20-4)
    leftSp:setTag(301)
    rightSp:setTag(302)

    local isFree=acWanshengjiedazuozhanVoApi:isFree()
    -- local function fireHandler()
    --     if G_checkClickEnable()==false then
    --         do
    --             return
    --         end
    --     else
    --         base.setWaitTime=G_getCurDeviceMillTime()
    --     end
    --     PlayEffect(audioCfg.mouseClick)

    --     self:fire()
    -- end
    -- local fireItem
    -- if isFree==true then
    --     fireItem = GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",fireHandler,21,getlocal("activity_wanshengjiedazuozhan_fire"),25)
    -- else
    --     fireItem = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",fireHandler,21,getlocal("activity_wanshengjiedazuozhan_fire"),25)
    -- end
    -- self.fireMenu = CCMenu:createWithItem(fireItem)
    -- self.fireMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
    -- self.fireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.bgLayer:addChild(self.fireMenu,3)

    self.goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp:setPosition(ccp(self.bgLayer:getContentSize().width/2-20,130))
    self.bgLayer:addChild(self.goldSp,3)
    self.costLb=GetTTFLabel(acVo.cost or 0,25)
    self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,130))
    self.bgLayer:addChild(self.costLb,3)

    self:refreshUI()
end

function acWanshengjiedazuozhanTab1:updateBar(pType,value)
    if self.bgLayer then
        local acVo=acWanshengjiedazuozhanVoApi:getAcVo()
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

function acWanshengjiedazuozhanTab1:initTableView()
    -- local function click(hd,fn,idx)
    -- end
    -- local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
    -- tvBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-560))
    -- tvBg:ignoreAnchorPointForPosition(false)
    -- tvBg:setAnchorPoint(ccp(0,0))
    -- tvBg:setPosition(ccp(25,150))
    -- self.bgLayer:addChild(tvBg)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-50,G_VisibleSize.height-540),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(25,155))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(0)
end

function acWanshengjiedazuozhanTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSize.height-540)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local version=acWanshengjiedazuozhanVoApi:getVersion()
        self.bgList={}
        -- self.spList={}
        local cellWidth=G_VisibleSizeWidth-50
        local cellHeight=G_VisibleSize.height-540
        -- local spSize=100
        local xSpace=140
        local posY=60
        if G_isIphone5() then
            posY=100
        end
        -- local ySpace=(cellHeight-posY*2)/2
        local ySpace=140
        local list=acWanshengjiedazuozhanVoApi:getList()
        local num=SizeOfTable(list)
        for k,v in pairs(list) do
            local px,py=cellWidth/2-xSpace+((k-1)%3)*xSpace,cellHeight-posY-math.floor((k-1)/3)*ySpace
            local pumpkinBg
            if version and version>1 then
                pumpkinBg=LuaCCScale9Sprite:createWithSpriteFrameName("pumpkinBg"..version..".png",CCRect(20,20,10,10),function ()end)
            else
                pumpkinBg=LuaCCScale9Sprite:createWithSpriteFrameName("pumpkinBg.png",CCRect(20,20,10,10),function ()end)
            end
            pumpkinBg:setContentSize(CCSizeMake(125,125))
            pumpkinBg:setPosition(ccp(px,py))
            cell:addChild(pumpkinBg)
            table.insert(self.bgList,pumpkinBg)

            local function clickHandler( ... )
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                self.selectIndex=k
                self.selectList={0,0,0,0,0,0,0,0,0}
                self.selectList[k]=1
                self:getSelectList(k)
                self.tv:reloadData()
            end
            local pic
            if self.selectList and self.selectList[k] and self.selectList[k]==1 then
                if version and version>1 then
                    if v==1 then
                        pic="pumpkinA2"..version..".png"
                    elseif v==2 then
                        pic="pumpkinB2"..version..".png"
                    elseif v==3 then
                        pic="pumpkinC2"..version..".png"
                    end
                else
                    if v==1 then
                        pic="pumpkinA2.png"
                    elseif v==2 then
                        pic="pumpkinB2.png"
                    elseif v==3 then
                        pic="pumpkinC2.png"
                    end
                end
                local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(40,40,10,10),function ()end)
                selectSp:setContentSize(CCSizeMake(pumpkinBg:getContentSize().width+10,pumpkinBg:getContentSize().height+10))
                selectSp:setPosition(getCenterPoint(pumpkinBg))
                pumpkinBg:addChild(selectSp)
                selectSp:setTag(902)
            else
                if version and version>1 then
                    if v==1 then
                        pic="pumpkinA1"..version..".png"
                    elseif v==2 then
                        pic="pumpkinB1"..version..".png"
                    elseif v==3 then
                        pic="pumpkinC1"..version..".png"
                    end
                else
                    if v==1 then
                        pic="pumpkinA1.png"
                    elseif v==2 then
                        pic="pumpkinB1.png"
                    elseif v==3 then
                        pic="pumpkinC1.png"
                    end
                end
            end
            if pic then
                local pumpkinSp=LuaCCSprite:createWithSpriteFrameName(pic,clickHandler)
                if pumpkinSp then
                    -- local pumpkinMenu = CCMenu:createWithItem(pumpkinItem)
                    pumpkinSp:setPosition(ccp(px,py))
                    pumpkinSp:setTouchPriority(-(self.layerNum-1)*20-2)
                    cell:addChild(pumpkinSp,1)
                    -- table.insert(self.bgList,pumpkinMenu)
                    pumpkinSp:setTag(1000+k)
                    -- table.insert(self.spList,pumpkinSp)
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


function acWanshengjiedazuozhanTab1:getSelectList(sIndex)
    -- self.selectList={0,0,0,0,0,0,0,0,0}
    local acVo=acWanshengjiedazuozhanVoApi:getAcVo()
    local space=3
    if acVo and acVo.map and acVo.map[sIndex] then
        -- self.selectList[sIndex]=1
        local value=tonumber(acVo.map[sIndex])
        local top=sIndex-space
        if top>0 and acVo.map[top] and acVo.map[top]==value and self.selectList[top] and self.selectList[top]~=1 then
            self.selectList[top]=1
            -- table.insert(self.selectList,top)
            self:getSelectList(top)
        end

        local button=sIndex+space
        if button>0 and acVo.map[button] and acVo.map[button]==value and self.selectList[button] and self.selectList[button]~=1 then
            self.selectList[button]=1
            -- table.insert(self.selectList,button)
            self:getSelectList(button)
        end

        if sIndex%space~=1 then
            local left=sIndex-1
            if left>0 and acVo.map[left] and acVo.map[left]==value and self.selectList[left] and self.selectList[left]~=1 then
                self.selectList[left]=1
                -- table.insert(self.selectList,left)
                self:getSelectList(left)
            end
        end

        if sIndex%space~=0 then
            local right=sIndex+1
            if right>0 and acVo.map[right] and acVo.map[right]==value and self.selectList[right] and self.selectList[right]~=1 then
                self.selectList[right]=1
                -- table.insert(self.selectList,right)
                self:getSelectList(right)
            end
        end
    end
end

function acWanshengjiedazuozhanTab1:fire()
    if self.selectIndex then
        local version=acWanshengjiedazuozhanVoApi:getVersion()
        local free=acWanshengjiedazuozhanVoApi:isFree()
        if free==true then
        else
            local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
            local costGem=0
            if acVo and acVo.cost then
                costGem=tonumber(acVo.cost)
                if(costGem>playerVoApi:getGems())then
                    GemsNotEnoughDialog(nil,nil,costGem - playerVoApi:getGems(),self.layerNum+1,costGem)
                    do return end
                end
            end
        end
        local function activeCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData.data then
                    self:addTouchLayer()
                    local oldVo = G_clone(acWanshengjiedazuozhanVoApi:getAcVo())
                    if sData.data.wanshengjiedazuozhan then
                        acWanshengjiedazuozhanVoApi:updateData(sData.data.wanshengjiedazuozhan)
                        if self.parent and self.parent.refresh then
                            self.parent:refresh()
                        end
                    end
                    if sData and sData.data and sData.data.accessory and accessoryVoApi then
                        accessoryVoApi:onRefreshData(sData.data.accessory)
                    end
                    if sData and sData.data and sData.data.alien and alienTechVoApi then
                        alienTechVoApi:setTechData(sData.data.alien)
                    end
                    self.isFree=acWanshengjiedazuozhanVoApi:isFree()
                    if self.bgList then
                        local tTime=0.3
                        --血条动画
                        if oldVo and oldVo.map and self.selectIndex and oldVo.map[self.selectIndex] then
                            local pType=oldVo.map[self.selectIndex]
                            if pType==1 or pType==2 then
                                local oldLife
                                local curLife
                                local acVo=acWanshengjiedazuozhanVoApi:getAcVo()
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
                                -- arr:addObject(delay)
                                -- arr:addObject(acFunc1)
                                -- arr:addObject(acFunc2)
                                local seq=CCSequence:create(arr)
                                self.bgLayer:runAction(seq)
                            end
                        end
                        --南瓜动画
                        -- local maxRow=1
                        local rowTab={}
                        local len=SizeOfTable(self.selectList)
                        for i=len-2,len,1 do
                            local row=0
                            for j=i,1,-3 do
                                if rowTab[j]==nil then
                                    rowTab[j]=0
                                end
                                if self.selectList[j]==1 then
                                    row=row+1
                                elseif self.selectList[j]==0 then
                                    rowTab[j]=row
                                end
                            end
                        end
                        local costTime=0
                        local ySpace=140
                        local speed=6000
                        local listLen=SizeOfTable(self.bgList)
                        -- for k,v in pairs(self.bgList) do
                        for i=listLen-2,len,1 do
                            for k=i,1,-3 do
                                local v=self.bgList[k]
                                local pumpkinBg=tolua.cast(v,"LuaCCScale9Sprite")
                                if pumpkinBg then
                                    if self.selectList and self.selectList[k] then
                                        -- local pumpkinSp1=tolua.cast(pumpkinBg:getChildByTag(901),"LuaCCSprite")
                                        local selectSp=tolua.cast(pumpkinBg:getChildByTag(902),"LuaCCScale9Sprite")
                                        -- local pumpkinSp1=tolua.cast(self.spList[k],"LuaCCSprite")
                                        local pumpkinSp1=tolua.cast(self.cell:getChildByTag(1000+k),"LuaCCSprite")
                                        if self.selectList[k]==1 then
                                            local function subMvEnd( ... )
                                                if pumpkinSp1 then
                                                    pumpkinSp1:setVisible(false)
                                                    pumpkinSp1:removeFromParentAndCleanup(true)
                                                    pumpkinSp1=nil
                                                end
                                            end
                                            local subfunc=CCCallFuncN:create(subMvEnd)
                                            local fadeOut=CCFadeOut:create(tTime)
                                            local fadeIn=CCFadeIn:create(tTime)
                                            local fadeArr=CCArray:create()
                                            fadeArr:addObject(fadeOut)
                                            fadeArr:addObject(fadeIn)
                                            fadeArr:addObject(fadeOut)
                                            fadeArr:addObject(fadeIn)
                                            fadeArr:addObject(subfunc)
                                            local subseq=CCSequence:create(fadeArr)
                                            pumpkinSp1:runAction(subseq)
                                            
                                            local function subMvEnd1( ... )
                                                if selectSp then
                                                    selectSp:setVisible(false)
                                                    selectSp:removeFromParentAndCleanup(true)
                                                    selectSp=nil
                                                end
                                            end
                                            local subfunc1=CCCallFuncN:create(subMvEnd1)
                                            local fadeOut1=CCFadeOut:create(tTime)
                                            local fadeIn1=CCFadeIn:create(tTime)
                                            local fadeArr1=CCArray:create()
                                            fadeArr1:addObject(fadeOut1)
                                            fadeArr1:addObject(fadeIn1)
                                            fadeArr1:addObject(fadeOut1)
                                            fadeArr1:addObject(fadeIn1)
                                            fadeArr1:addObject(subfunc1)
                                            local subseq1=CCSequence:create(fadeArr1)
                                            selectSp:runAction(subseq1)
                                        elseif self.selectList[k]==0 then
                                            if selectSp then
                                                selectSp:setVisible(false)
                                                selectSp:removeFromParentAndCleanup(true)
                                                selectSp=nil
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        costTime=costTime+tTime*4+0.1
                        for i=listLen-2,len,1 do
                            for k=i,1,-3 do
                                local v=self.bgList[k]
                                local pumpkinBg=tolua.cast(v,"LuaCCScale9Sprite")
                                if pumpkinBg then
                                    if self.selectList and self.selectList[k] then
                                        local pumpkinSp1=tolua.cast(self.cell:getChildByTag(1000+k),"LuaCCSprite")
                                        if self.selectList[k]==0 then
                                            if pumpkinSp1 then
                                                if rowTab[k] and rowTab[k]>0 then
                                                    local distance=rowTab[k]*ySpace
                                                    local time=distance/speed
                                                    local delay=CCDelayTime:create(costTime)
                                                    local moveBy=CCMoveBy:create(time,ccp(0,-distance))
                                                    local acArr=CCArray:create()
                                                    acArr:addObject(delay)
                                                    acArr:addObject(moveBy)
                                                    local seq=CCSequence:create(acArr)
                                                    pumpkinSp1:runAction(seq)
                                                    costTime=costTime+time+0.1
                                                end
                                            end
                                        end
                                    end

                                end
                            end
                        end
                        if sData.data.newItem then
                            speed=8000
                            local tab={}
                            for k,v in pairs(sData.data.newItem) do
                                local index=v[1]
                                local sortId=(3-((index-1)%3))*10+math.ceil(index/3)
                                table.insert(tab,{v[1],v[2],sortId})
                            end
                            if tab and SizeOfTable(tab)>0 then
                                local function sortFunc(a,b)
                                    return a[3]>b[3]
                                end
                                table.sort(tab,sortFunc)
                            end
                            local num=SizeOfTable(tab)
                            -- if self.selectList and self.selectList[k] and self.selectList[k]==1 then
                            --     local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
                            --     if acVo and acVo.map and acVo.map[k] then
                            for k,v in pairs(tab) do
                                local index=v[1]
                                local spType=tonumber(v[2])
                            
                                local function clickHandler( ... )
                                    if G_checkClickEnable()==false then
                                        do
                                            return
                                        end
                                    else
                                        base.setWaitTime=G_getCurDeviceMillTime()
                                    end
                                    PlayEffect(audioCfg.mouseClick)

                                    self.selectIndex=index
                                    self.selectList={0,0,0,0,0,0,0,0,0}
                                    self.selectList[index]=1
                                    self:getSelectList(index)
                                    self.tv:reloadData()
                                end
                                -- local spType=acVo.map[index]
                                local pic
                                if version and version>1 then
                                    if spType==1 then
                                        pic="pumpkinA1"..version..".png"
                                    elseif spType==2 then
                                        pic="pumpkinB1"..version..".png"
                                    elseif spType==3 then
                                        pic="pumpkinC1"..version..".png"
                                    end
                                else
                                    if spType==1 then
                                        pic="pumpkinA1.png"
                                    elseif spType==2 then
                                        pic="pumpkinB1.png"
                                    elseif spType==3 then
                                        pic="pumpkinC1.png"
                                    end
                                end
                                if pic then
                                    local pumpkinSp=LuaCCSprite:createWithSpriteFrameName(pic,clickHandler)
                                    if pumpkinSp then
                                        local cellWidth=G_VisibleSizeWidth-50
                                        local cellHeight=G_VisibleSize.height-540
                                        local xSpace=140
                                        local posY=60
                                        if G_isIphone5() then
                                            posY=100
                                        end
                                        local ySpace=140
                                        local px,py=cellWidth/2-xSpace+((index-1)%3)*xSpace,cellHeight-posY-math.floor((index-1)/3)*ySpace
                                        -- local distance=math.floor((maxRow-1)/3)*ySpace+100*maxRow
                                        local distance=600
                                        local time=distance/speed
                                        local py1=py+distance
                                        pumpkinSp:setPosition(ccp(px,py1))
                                        pumpkinSp:setTouchPriority(-(self.layerNum-1)*20-2)
                                        self.cell:addChild(pumpkinSp,1)
                                        -- pumpkinSp:setTag(901)

                                        local function actionEndFunc( ... )
                                            if sData.data.report then
                                                if sData.data.report.normal then
                                                    local rewardData=sData.data.report.normal
                                                    if SizeOfTable(rewardData)==1 then
                                                        for k,v in pairs(rewardData) do
                                                            local award=FormatItem(v)
                                                            G_showRewardTip(award,true)
                                                        end
                                                    else
                                                        local content={}
                                                        for k,v in pairs(rewardData) do
                                                            local awardTb=FormatItem(v)
                                                            for m,n in pairs(awardTb) do
                                                                local award=n or {}
                                                                table.insert(content,{award=award})
                                                            end
                                                        end
                                                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_tankjianianhua_awardContent"),content,true,true,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,true)
                                                        local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
                                                        local num=SizeOfTable(rewardData)
                                                        if num and acVo and num>=acVo.noticeNum then
                                                            local paramTab={}
                                                            paramTab.functionStr="wanshengjiedazuozhan"
                                                            paramTab.addStr="take_part"
                                                            local chatKey="activity_wanshengjiedazuozhan_chat1"
                                                            if version and version>1 then
                                                                chatKey="activity_wanshengjiedazuozhan_chat1".."_"..version
                                                            end
                                                            local message={key=chatKey,param={playerVoApi:getPlayerName(),num}}
                                                            chatVoApi:sendSystemMessage(message,paramTab)
                                                        end
                                                    end
                                                end
                                                if sData.data.report.boss then
                                                    local rewardData=sData.data.report.boss
                                                    for k,v in pairs(rewardData) do
                                                        local award=FormatItem(v)
                                                        G_showRewardTip(award,true)

                                                        local awardStr=G_showRewardTip(award,false,true)
                                                        local pname=""
                                                        if oldVo and oldVo.map and self.selectIndex and oldVo.map[self.selectIndex] then
                                                            local pType=oldVo.map[self.selectIndex]
                                                            pname=getlocal("activity_wanshengjiedazuozhan_pumpkin"..pType)
                                                            if version and version>1 then
                                                                pname=getlocal("activity_wanshengjiedazuozhan_pumpkin"..pType.."_"..version)
                                                            end
                                                        end
                                                        local paramTab={}
                                                        paramTab.functionStr="wanshengjiedazuozhan"
                                                        paramTab.addStr="take_part"
                                                        local chatKey1="activity_wanshengjiedazuozhan_chat2"
                                                        if version and version>1 then
                                                            chatKey1="activity_wanshengjiedazuozhan_chat2".."_"..version
                                                        end
                                                        local message={key=chatKey1,param={playerVoApi:getPlayerName(),pname,awardStr}}
                                                        chatVoApi:sendSystemMessage(message,paramTab)
                                                    end
                                                end
                                            end

                                            self.selectIndex=nil
                                            self.selectList={0,0,0,0,0,0,0,0,0}
                                            self:refreshUI()
                                            self.tv:reloadData()
                                            self:removeTouchLayer()
                                        end
                                        local fc= CCCallFunc:create(actionEndFunc)
                                        local delay=CCDelayTime:create(costTime)
                                        local moveTo=CCMoveTo:create(time,ccp(px,py))
                                        local acArr=CCArray:create()
                                        acArr:addObject(delay)
                                        acArr:addObject(moveTo)
                                        if k==num then
                                            acArr:addObject(fc)
                                        end
                                        local seq=CCSequence:create(acArr)
                                        pumpkinSp:runAction(seq)
                                        costTime=costTime+time+0.1
                                    end
                                end
                            end
                        end

                    end

                end
            end
        end
        local action=1
        local index=self.selectIndex
        socketHelper:activeWanshengjiedazuozhan(action,index,nil,free,activeCallback)
    else
        local version=acWanshengjiedazuozhanVoApi:getVersion()
        local failStr=getlocal("activity_wanshengjiedazuozhan_fire_fail")
        if version and version>1 then
            failStr=getlocal("activity_wanshengjiedazuozhan_fire_fail_"..version)
        end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),failStr,30)
    end
end

function acWanshengjiedazuozhanTab1:refreshUI()
    local acVo = acWanshengjiedazuozhanVoApi:getAcVo()
    local isFree=acWanshengjiedazuozhanVoApi:isFree()
    if isFree==true then
        if self.goldSp then
            self.goldSp:setVisible(false)
        end
        if self.costLb then
            self.costLb:setString(getlocal("daily_lotto_tip_2"))
            self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,130))
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
            self.costLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,130))
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
    local version=acWanshengjiedazuozhanVoApi:getVersion()
    local bStr=getlocal("activity_wanshengjiedazuozhan_fire")
    if version and version>1 then
        bStr=getlocal("activity_wanshengjiedazuozhan_fire_"..version)
    end
    if isFree==true then
        fireItem = GetButtonItem("BigBtnGreen.png","BigBtnGreen_Down.png","BigBtnGreen_Down.png",fireHandler,21,bStr,25)
    else
        fireItem = GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",fireHandler,21,bStr,25)
    end
    self.fireMenu = CCMenu:createWithItem(fireItem)
    self.fireMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,70))
    self.fireMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.fireMenu,3)

    if self and self.bgLayer then
        local timerSprite = tolua.cast(self.bgLayer:getChildByTag(101),"CCProgressTimer")
        if timerSprite then
            local life,maxLife=0,0
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
            local life2,maxLife2=0,0
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

function acWanshengjiedazuozhanTab1:addTouchLayer()
    self.touchLayer=CCLayer:create()
    self.touchLayer:setTouchEnabled(true)
    self.touchLayer:setBSwallowsTouches(true)
    self.touchLayer:setTouchPriority(-188)
    self.touchLayer:setContentSize(G_VisibleSize)
    self.bgLayer:addChild(self.touchLayer)
end
function acWanshengjiedazuozhanTab1:removeTouchLayer()
    if self.touchLayer then
        self.touchLayer:removeFromParentAndCleanup(true)
        self.touchLayer=nil
    end
end

function acWanshengjiedazuozhanTab1:tick()
    self:updateAcTime()
    local isFree=acWanshengjiedazuozhanVoApi:isFree()
    if self.isFree~=isFree then
        self.isFree=true
        self:refreshUI()
    end
end

function acWanshengjiedazuozhanTab1:updateAcTime()
    local acVo=acWanshengjiedazuozhanVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acWanshengjiedazuozhanTab1:dispose()
    self.cell=nil
    self.bgList={}
    -- self.spList={}
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
    local version=acWanshengjiedazuozhanVoApi:getVersion()
    if version and version>1 then
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhanBg"..version..".jpg")
    else
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/acWanshengjiedazuozhanBg.jpg")
    end
end
