acEquipSearchIINewTab1={}

function acEquipSearchIINewTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acEquipSearchDialog=nil

    self.bgLayer=nil
    self.onceBtn=nil
    self.tenBtn=nil
    self.backBg=nil
    self.flicker=nil
    self.spSize=100
    self.spTab={}
    self.descLb=nil

    return nc
end

function acEquipSearchIINewTab1:init(layerNum,selectedTabIndex,acEquipSearchDialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acEquipSearchDialog=acEquipSearchDialogII
    self.bgLayer=CCLayer:create()
    self:initDesc()
    self:initAwardPool()
    self:initSearch()
    return self.bgLayer
end

function acEquipSearchIINewTab1:initDesc()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,80))
    titleBg:setAnchorPoint(ccp(0,0))
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-80))
    self.bgLayer:addChild(titleBg,1)

    local descStr,descStr2
    if acEquipSearchIIVoApi:acIsStop()==true then
        descStr=getlocal("activity_equipSearch_time_end")
    else
        descStr=acEquipSearchIIVoApi:getTimeStr()
        descStr2=acEquipSearchIIVoApi:getRewardTimeStr()
    end
    if acEquipSearchIIVoApi:acIsStop() ==true then
        self.descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.descLb:setAnchorPoint(ccp(0,0.5))
        self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2))
        titleBg:addChild(self.descLb,2)
    else
        local moveBgStarStr,timeLb1,timeLb2 = G_LabelRollView(CCSizeMake(titleBg:getContentSize().width-100,titleBg:getContentSize().height-10),descStr,25,kCCTextAlignmentLeft,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        moveBgStarStr:setAnchorPoint(ccp(0,0))
        moveBgStarStr:setPosition(ccp(15,5))
        titleBg:addChild(moveBgStarStr,2)
        self.timeLb1=timeLb1
        self.timeLb2=timeLb2
        self:updateAcTime()
    end
    local function onClickDesc()
        local strTab={" ",getlocal("activity_equipSearchIINew_tip6"),getlocal("activity_equipSearchIINew_tip5"),getlocal("activity_equipSearchIINew_tip4"),getlocal("activity_equipSearchIINew_tip3",{self.rewardItem2.name .. "*" .. self.rewardItem2.num}),getlocal("activity_equipSearchIINew_tip2",{self.rewardItem1.name .. "*" .. self.rewardItem1.num}),getlocal("activity_equipSearchIINew_tip1")," "}
        local colorTab={}
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,strTab,25,colorTab)
        sceneGame:addChild(dialogLayer,self.layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local scale=0.8
    local descBtnItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",onClickDesc)
    descBtnItem:setAnchorPoint(ccp(0.5,0.5))
    descBtnItem:setScale(scale)
    local descBtn=CCMenu:createWithItem(descBtnItem)
    descBtn:setAnchorPoint(ccp(0.5,0.5))
    descBtn:setPosition(ccp(titleBg:getContentSize().width-descBtnItem:getContentSize().width*scale/2-10,titleBg:getContentSize().height/2))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(descBtn,2)

end

function acEquipSearchIINewTab1:initAwardPool()
    local capInSet = CCRect(50, 50, 1, 1)
    local function bgClick(hd,fn,idx)
    end
    local backBgHeight=G_VisibleSize.height-524
    self.backBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",capInSet,bgClick)
    self.backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,backBgHeight))
    self.backBg:setAnchorPoint(ccp(0,0))
    self.backBg:setPosition(ccp(30,276))
    self.bgLayer:addChild(self.backBg,1)

    local everyH = (G_VisibleSize.height-524-10)/5
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    -- local awardPool=FormatItem(cfg.pool) or {}
    local awardPool=cfg.pool or {}
    local row=math.ceil(SizeOfTable(awardPool)/5)
    for k,v in pairs(awardPool) do
        local px=20+self.spSize/2+((k-1)%5)*110
        -- local space=(backBgHeight/row)-5
        local space=102
        local py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-16
        if G_isIphone5()==true then
            space=130
            py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-63
        end

        local function touch()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local content=acEquipSearchIIVoApi:formatContent(k)
            if content and SizeOfTable(content)>0 then
                -- if content.award and SizeOfTable(content.award)>0 then
                --     local function sortAsc(a, b)
                --         if a and b and a.index and b.index and tonumber(a.index) and tonumber(b.index) then
                --             return a.index < b.index
                --         end
                --     end
                --     table.sort(content.award,sortAsc)
                -- end
                smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_reward_include"),content,true,true,self.layerNum+1,nil,nil,nil,true)
            end

        end
        if v.aid then
            -- local icon = CCSprite:createWithSpriteFrameName(v.pic)
            local icon

            -- local item=getItem(v.aid,"e")
            -- if item.eType=="a" then
            --     icon=accessoryVoApi:getAccessoryIcon(v.aid,80,100,touch)
            -- elseif item.eType=="f" then
            --     icon=accessoryVoApi:getFragmentIcon(v.aid,80,100,touch)
            -- elseif item.eType=="p" then
            --     -- local pic=accessoryCfg.propCfg[v.aid].icon
            --     icon=LuaCCSprite:createWithSpriteFrameName(item.pic,touch)
            -- end

            local aid=v.aid
            local eType=string.sub(aid,1,1)
            if eType=="a" then
                icon=accessoryVoApi:getAccessoryIcon(aid,80,100,touch)
            elseif eType=="f" then
                icon=accessoryVoApi:getFragmentIcon(aid,80,100,touch)
            elseif eType=="p" then
                local pic=accessoryCfg.propCfg[aid].icon
                icon=LuaCCSprite:createWithSpriteFrameName(pic,touch)
            end
            if icon then
                icon:setAnchorPoint(ccp(0.5,0.5))
                local scale=self.spSize/icon:getContentSize().width
                local addScale=0.9
                if G_isIphone5()==true then
                    addScale=1
                end
                icon:setScale(scale*addScale)
                icon:setPosition(ccp(px,py))
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                self.backBg:addChild(icon,1)
                table.insert(self.spTab,k,icon)
            end
        end
    end

end

function acEquipSearchIINewTab1:initSearch()
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    local oneCost=cfg.oneCost
    local tenCost=cfg.tenCost

    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local costBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    costBg1:setContentSize(CCSizeMake(G_VisibleSize.width-60,120))
    costBg1:setAnchorPoint(ccp(0,0))
    costBg1:setPosition(ccp(30,153))
    self.bgLayer:addChild(costBg1,1)

    local costBg2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    costBg2:setContentSize(CCSizeMake(G_VisibleSize.width-60,120))
    costBg2:setAnchorPoint(ccp(0,0))
    costBg2:setPosition(ccp(30,30))
    self.bgLayer:addChild(costBg2,1)

    local posY = costBg1:getContentSize().height-30
    local posX = costBg1:getContentSize().width-90
    self.goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    self.goldSp1:setAnchorPoint(ccp(0,0.5))
    self.goldSp1:setPosition(ccp(posX-35,posY))
    costBg1:addChild(self.goldSp1)

    self.gemsLabel1=GetTTFLabel(oneCost[2],22)
    self.gemsLabel1:setAnchorPoint(ccp(0,0.5))
    self.gemsLabel1:setPosition(ccp(posX+5,posY))
    costBg1:addChild(self.gemsLabel1,1)

    local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp2:setAnchorPoint(ccp(0,0.5))
    goldSp2:setPosition(ccp(posX-40,posY))
    costBg2:addChild(goldSp2)

    local gemsLabel2=GetTTFLabel(tenCost[2][2],22)
    gemsLabel2:setAnchorPoint(ccp(0,0.5))
    gemsLabel2:setPosition(ccp(posX,posY))
    costBg2:addChild(gemsLabel2,1)

    for i=1,2 do
        local mustReward=acEquipSearchIIVoApi:getMustReward(i)
        local reward = mustReward.reward
        local rewardItem = FormatItem(reward)
        local backSp
        self["rewardItem" .. i]=rewardItem[1]
        if i==1 then
            backSp=costBg1
        else
            backSp=costBg2
        end
        local icon,scale=G_getItemIcon(rewardItem[1],90,true,self.layerNum)
        icon:setTouchPriority(-(self.layerNum-1)*20-2)
        icon:setPosition(60,backSp:getContentSize().height/2)
        backSp:addChild(icon)

        local numLb = GetTTFLabel("x" .. rewardItem[1].num,25)
        numLb:setAnchorPoint(ccp(1,0))
        icon:addChild(numLb)
        numLb:setPosition(icon:getContentSize().width-10,5)

        G_addRectFlicker(icon,1/scale*1.25,1/scale*1.2)

        local desLb=GetTTFLabelWrap(
        getlocal("activity_equipSearchIINew_des" .. i),22,CCSizeMake(290,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        backSp:addChild(desLb)
        desLb:setPosition(ccp(120,backSp:getContentSize().height/2)
        )
    end


    local function searchHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if acEquipSearchIIVoApi:checkCanSearch()==false then
            do return end
        end

        local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()

        local function searchCallback(fn,data)
            local isCost=acEquipSearchIIVoApi:isSearchToday()
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
                local oneCost1=cfg.oneCost[2]
                local tenCost1=cfg.tenCost[2][2]
                if tag==1 then
                    if isCost==true then
                        playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost1)
                    end
                else
                    playerVoApi:setValue("gems",playerVoApi:getGems()-tenCost1)
                end

                if sData.data.useractive and sData.data.useractive.equipSearchII then
                    local equipSearch=sData.data.useractive.equipSearchII
                    acEquipSearchIIVoApi:updateData(equipSearch)
                end

                if sData.data.equipSearchII and sData.data.equipSearchII.report and self and self.bgLayer then
                    local content={}
                    local report=sData.data.equipSearchII.report or {}
                    for k,v in pairs(report) do
                        local awardTb=FormatItem(v[1]) or {}
                        for m,n in pairs(awardTb) do
                            local award=n or {}
                            local index=acEquipSearchIIVoApi:getIndexByNameAndNum(award.key,award.num)
                            -- table.insert(content,{award=award,point=v[2],index=index})
                            -- table.insert(content,{award=award})
                            
                            if k==1 then
                                table.insert(content,getlocal("but_get"))
                            end
                            if k==2 then
                                table.insert(content,getlocal("other_ger"))
                            end

                            if v[2]==nil or v[2]==0 then
                                award.newDes=getlocal("vip_tequanlibao_geshihua",{award.name,award.num})
                            else
                                award.newDes=getlocal("activity_equipSearchNew_reward_inbag",{award.name,award.num,"*"..v[2]})
                            end

                            table.insert(content,award)
                            G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        end
                    end
                    if tag==1 then
                        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("buy"))

                        local awardIdx=content[1].index
                        if awardIdx and awardIdx>0 and self.spTab[awardIdx] then
                            self:showFlicker(self.spTab[awardIdx])
                        end
                    end
                    if content and SizeOfTable(content)>0 then
                        local function confirmHandler(awardIdx)
                            if awardIdx and awardIdx>0 and awardIdx then
                                if self.spTab[awardIdx] then
                                    self:showFlicker(self.spTab[awardIdx])
                                end
                            else
                                self:hideFlicker()
                            end
                        end
                        local isXiuzheng=false
                        if SizeOfTable(content)<5 then
                            isXiuzheng=true
                        end
                        require "luascript/script/game/scene/gamedialog/activityAndNote/newDisplayRewardSmallDialog"
                        newDisplayRewardSmallDialog:showRewardItemsWithDiffTitleDialog("TankInforPanel.png",CCSizeMake(550,650),nil,false,true,true,true,self.layerNum+1,content,confirmHandler,nil,isXiuzheng)

                        -- smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_total"),content,nil,true,self.layerNum+1,confirmHandler,true,true)
                    end
                end

                if self.acEquipSearchDialog then
                    self.acEquipSearchDialog:refresh()
                end
            end
        end
        local once=cfg.oneCost[1]
        local ten=cfg.tenCost[1]
        local oneCost=cfg.oneCost[2]
        local tenCost=cfg.tenCost[2][2]

        if activityVoApi:getLotteryIsUseProp(acEquipSearchIIVoApi:getAcVo()) ==true then
            if tag==1 and acEquipSearchIIVoApi:isSearchToday()==false then
                socketHelper:activeEquipsearchII(1,searchCallback,once)
            else
                local needPro
                if tag ==1 then
                    needPro=oneCost
                elseif tag ==2 then
                    needPro=tenCost
                end
                
                local function touchBuy( ... )
                    if tag ==1 then
                        local diffGems=oneCost-playerVoApi:getGems()
                        if diffGems>0 then
                            GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
                            do return end
                        end
                        socketHelper:activeEquipsearchII(1,searchCallback,once)
                    elseif tag ==2 then
                        local diffGems2=tenCost-playerVoApi:getGems()
                        if diffGems2>0 then
                            GemsNotEnoughDialog(nil,nil,diffGems2,self.layerNum+1,tenCost)
                            do return end
                        end
                        socketHelper:activeEquipsearchII(1,searchCallback,ten)
                    end
                   
                end
                touchBuy()
            end

        else
            if tag==1 then
                local diffGems=oneCost-playerVoApi:getGems()
                if acEquipSearchIIVoApi:isSearchToday()==false then
                
                 elseif diffGems>0 then
                    GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
                    do return end
                end
                socketHelper:activeEquipsearchII(1,searchCallback,once)
            elseif tag==2 then
                local diffGems2=tenCost-playerVoApi:getGems()
                if diffGems2>0 then
                    GemsNotEnoughDialog(nil,nil,diffGems2,self.layerNum+1,tenCost)
                    do return end
                end
                socketHelper:activeEquipsearchII(1,searchCallback,ten)
            end
        end
        
        
    end
    -- self.onceBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",searchHandler,1)
    local textSize = 25
    local scale = 0.8
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSize=20
    end
    self.onceBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",searchHandler,1,getlocal("buy"),textSize,21)
    self.onceBtn:setAnchorPoint(ccp(0.5,0))
    self.onceBtn:setScale(scale)
    local onceMune=CCMenu:createWithItem(self.onceBtn)
    -- onceMune:setAnchorPoint(ccp(0.5,0.5))
    onceMune:setPosition(ccp(costBg1:getContentSize().width-90,10))
    onceMune:setTouchPriority(-(self.layerNum-1)*20-4)
    costBg1:addChild(onceMune,1)

    self.freeBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",searchHandler,1,getlocal("activity_equipSearch_free_btn"),textSize,21)
    self.freeBtn:setAnchorPoint(ccp(0.5,0))
    self.freeBtn:setScale(scale)
    local onceMune=CCMenu:createWithItem(self.freeBtn)
    -- onceMune:setAnchorPoint(ccp(0.5,0.5))
    onceMune:setPosition(ccp(costBg1:getContentSize().width-90,10))
    onceMune:setTouchPriority(-(self.layerNum-1)*20-4)
    costBg1:addChild(onceMune,1)

    self.tenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",searchHandler,2,getlocal("buy"),textSize,22)
    self.tenBtn:setAnchorPoint(ccp(0.5,0))
    self.tenBtn:setScale(scale)
    local tenMune=CCMenu:createWithItem(self.tenBtn)
    tenMune:setAnchorPoint(ccp(0.5,0.5))
    tenMune:setPosition(ccp(costBg2:getContentSize().width-90,10))
    tenMune:setTouchPriority(-(self.layerNum-1)*20-4)
    costBg2:addChild(tenMune,1)

    if acEquipSearchIIVoApi:checkCanSearch()==false then
        self.onceBtn:setEnabled(false)
        self.tenBtn:setEnabled(false)
        self.freeBtn:setEnabled(false)
    else
        self.onceBtn:setEnabled(true)
        self.tenBtn:setEnabled(true)
        self.freeBtn:setEnabled(true)

        if acEquipSearchIIVoApi:isSearchToday()==false then
            -- tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
            self.freeBtn:setVisible(true)
            self.freeBtn:setEnabled(true)
            self.onceBtn:setVisible(false)
            self.onceBtn:setEnabled(false)
            self.gemsLabel1:setVisible(false) 
            self.goldSp1:setVisible(false) 
        else
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("buy"))
            self.gemsLabel1:setVisible(true) 
            self.goldSp1:setVisible(true) 
            self.freeBtn:setVisible(false)
            self.freeBtn:setEnabled(false)
            self.onceBtn:setVisible(true)
            self.onceBtn:setEnabled(true)
        end
    end

end

function acEquipSearchIINewTab1:showFlicker(icon)
    if newGuidMgr:isNewGuiding() then
        do return end
    end
    if self and self.backBg and icon then
        local px,py=icon:getPosition()
        -- px=px-4
        -- py=py+2
        if self.flicker==nil then
            local pzFrameName="RotatingEffect1.png"
            self.flicker=CCSprite:createWithSpriteFrameName(pzFrameName)
            local m_iconScaleX=(self.spSize+8)/self.flicker:getContentSize().width
            local m_iconScaleY=(self.spSize+8)/self.flicker:getContentSize().height
            local pzArr=CCArray:create()
            for kk=1,20 do
                local nameStr="RotatingEffect"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                pzArr:addObject(frame)
            end
            local animation=CCAnimation:createWithSpriteFrames(pzArr)
            animation:setDelayPerUnit(0.1)
            local animate=CCAnimate:create(animation)
            self.flicker:setAnchorPoint(ccp(0.5,0.5))
            self.flicker:setScaleX(m_iconScaleX)
            self.flicker:setScaleY(m_iconScaleY)
            self.flicker:setPosition(ccp(px,py))
            self.backBg:addChild(self.flicker,5)
            local repeatForever=CCRepeatForever:create(animate)
            self.flicker:runAction(repeatForever)
        else
            self.flicker:setPosition(ccp(px,py))
            if self.flicker:isVisible()==false then
                self.flicker:setVisible(true)
                local pzArr=CCArray:create()
                for kk=1,20 do
                    local nameStr="RotatingEffect"..kk..".png"
                    local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                    pzArr:addObject(frame)
                end
                local animation=CCAnimation:createWithSpriteFrames(pzArr)
                animation:setDelayPerUnit(0.1)
                local animate=CCAnimate:create(animation)
                local repeatForever=CCRepeatForever:create(animate)
                self.flicker:runAction(repeatForever)
            end
        end
    end
end
function acEquipSearchIINewTab1:hideFlicker()
    if self and self.flicker then
        self.flicker:stopAllActions()
        self.flicker:setVisible(false)
    end
end

function acEquipSearchIINewTab1:refresh()
    if self and self.bgLayer then
        if acEquipSearchIIVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
            self.tenBtn:setEnabled(false)
            self.freeBtn:setEnabled(false)
        else
            self.onceBtn:setEnabled(true)
            self.tenBtn:setEnabled(true)
            self.freeBtn:setEnabled(true)

            if acEquipSearchIIVoApi:isSearchToday()==false then
                -- tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
                self.freeBtn:setVisible(true)
                self.freeBtn:setEnabled(true)
                self.onceBtn:setVisible(false)
                self.onceBtn:setEnabled(false)

                self.gemsLabel1:setVisible(false) 
                self.goldSp1:setVisible(false) 
            else
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("buy"))
                self.gemsLabel1:setVisible(true) 
                self.goldSp1:setVisible(true) 
                self.freeBtn:setVisible(false)
                self.freeBtn:setEnabled(false)
                self.onceBtn:setVisible(true)
                self.onceBtn:setEnabled(true)
            end
        end

        if self.descLb then
            if acEquipSearchIIVoApi:acIsStop()==true then
                self.descLb:setString(getlocal("activity_equipSearch_time_end"))
            else
                local timeStr=acEquipSearchIIVoApi:getTimeStr()
                self.descLb:setString(timeStr)
            end
        end

    end
    
end

function acEquipSearchIINewTab1:tick()
    self:updateAcTime()
end

function acEquipSearchIINewTab1:updateAcTime()
    local acVo=acEquipSearchIIVoApi:getAcVo()
    if acVo and self.timeLb1 and self.timeLb2 then
        G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,true)
    end
end

function acEquipSearchIINewTab1:dispose()
    if self.flicker then
        self.flicker:stopAllActions()
    end
    self.flicker=nil
    self.layerNum=nil
    self.selectedTabIndex=nil
    self.acEquipSearchDialog=nil

    self.spTab=nil
    self.spSize=nil
    self.onceBtn=nil
    self.tenBtn=nil
    self.backBg=nil
    self.bgLayer=nil
    self.descLb=nil
    self.timeLb1=nil
    self.timeLb2=nil
    self=nil
end






