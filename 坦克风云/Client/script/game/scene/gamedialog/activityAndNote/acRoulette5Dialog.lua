acRoulette5Dialog=commonDialog:new()

function acRoulette5Dialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=layerNum

    self.bgLayer=nil
    self.playBtnBg=nil
    self.playBtn=nil
    self.rewardIconList={}
    self.halo=nil           --赌博机的光圈
    self.tickIndex=0
    self.tickInterval=5     --光圈移动的倒计时
    self.tickConst=5        --tick的间距
    self.haloPos=0     --光圈当前在第几个图标上
    self.layerNum=nil
    self.acRoulette5Dialog=nil
    self.rewardList={}
    self.reward={}
    self.lastTime=nil
    self.touchEnabledSp=nil
    self.diffPoint=nil
    self.cellHeight=nil

    self.slowStart=false
    self.endIdx=0
    self.count=0
    self.isPlay =false

    self.isToday = true

    return nc
end


function acRoulette5Dialog:initTableView()
    self:initDesc()
    self:initRoulette()
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
    self.panelLineBg:setAnchorPoint(ccp(0,0))
    self.panelLineBg:setPosition(ccp(15,15))

    -- local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    -- -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
    -- self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,self.bgLayer:getContentSize().height-340-20),nil)
    -- self.tv:setPosition(ccp(30,40))
end

--初始化上半部的今日抽奖信息
function acRoulette5Dialog:initDesc()
    -- local vo=acRoulette5VoApi:getAcVo()

    local capInSet = CCRect(20, 20, 10, 10);
    local function bgClick(hd,fn,idx)
    end
    self.titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    self.titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60, G_VisibleSize.height-660))
    self.titleBg:setAnchorPoint(ccp(0,1));
    self.titleBg:setPosition(ccp(30,G_VisibleSize.height-105))
    self.bgLayer:addChild(self.titleBg,1)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSize.width-70,G_VisibleSize.height-670),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(5,5))
    self.titleBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(50)

end
function acRoulette5Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end
        tmpSize=CCSizeMake(G_VisibleSize.width-70,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local vo=acRoulette5VoApi:getAcVo()
        if vo==nil then
            do return cell end
        end
        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end


        self.descLb1=GetTTFLabel(getlocal("activity_wheelFortune_reward_count",{acRoulette5VoApi:getUsedNum()}),25)
        self.descLb1:setAnchorPoint(ccp(0,1));
        -- self.descLb1:setPosition(ccp(10,self.cellHeight-self.numLb:getContentSize().height-10));
        self.descLb1:setPosition(ccp(10,self.cellHeight-10));
        cell:addChild(self.descLb1,2);
        self.descLb1:setColor(G_ColorGreen)


        local rouletteCfg=acRoulette5VoApi:getRouletteCfg()
        local timeTab=acRoulette5VoApi:getTimeTab()
        timeTab[3]=rouletteCfg.lotteryConsume
        local version =acRoulette5VoApi:getVersion()
        local descStr
        if version ==1 or version ==nil then
             descStr=getlocal("activity_wheelFortune5_desc_1",timeTab)
        elseif version ==2 or version ==3 then
             descStr=getlocal("activity_wheelFortune5_desc_1B",timeTab)
        end
        local descTitle
        local descTitleHeight= 0
        if version ==4 then
            descTitle =getlocal("activity_wheelFortune5_desc_4",{acRoulette5VoApi:getGameName()})
        elseif version ==5 then
            descTitle =getlocal("activity_wheelFortune5_desc_5",{acRoulette5VoApi:getGameName()})
        elseif version ==6 then
            descTitle = getlocal("activity_wheelFortune5_desc_6",{acRoulette5VoApi:getGameName()})
        elseif version ==7 then
            descTitle = getlocal("activity_wheelFortune5_desc_7",{acRoulette5VoApi:getGameName()})
        end
        if version >= 4 then
            descStr = getlocal("activity_wheelFortune5_desc_456",timeTab)
            self.descTitle =GetTTFLabelWrap(descTitle,22,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            self.descTitle:setAnchorPoint(ccp(0,1))
            self.descTitle:setPosition(ccp(10,self.cellHeight-self.descLb1:getContentSize().height-20))
            cell:addChild(self.descTitle,2)
            descTitleHeight = self.descTitle:getContentSize().height
        end
        self.descLb2=GetTTFLabelWrap(descStr,22,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.descLb2:setAnchorPoint(ccp(0,1));
        self.descLb2:setPosition(ccp(10,self.cellHeight-self.descLb1:getContentSize().height-20-descTitleHeight));
        cell:addChild(self.descLb2,2);

        local descStr1=getlocal("activity_wheelFortune4_desc_2")
        self.descLb3=GetTTFLabelWrap(descStr1,22,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        self.descLb3:setAnchorPoint(ccp(0,1));
        self.descLb3:setPosition(ccp(10,self.cellHeight-self.descLb1:getContentSize().height-20-self.descLb2:getContentSize().height-descTitleHeight));
        cell:addChild(self.descLb3,2);
        self.descLb3:setColor(G_ColorRed)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acRoulette5Dialog:getCellHeight()
    local descLb1=GetTTFLabel(getlocal("activity_wheelFortune_reward_count",{acRoulette5VoApi:getUsedNum()}),25)
    local rouletteCfg=acRoulette5VoApi:getRouletteCfg()
    local timeTab=acRoulette5VoApi:getTimeTab()
    timeTab[3]=rouletteCfg.lotteryConsume
    --table.insert(timeTab,rouletteCfg.lotteryConsume)
    local descStr=getlocal("activity_wheelFortune5_desc_1",timeTab)
    local descLb2=GetTTFLabelWrap(descStr,22,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local cellHeight=descLb1:getContentSize().height+descLb2:getContentSize().height+100
    return cellHeight
end

--初始化赌博机
function acRoulette5Dialog:initRoulette()
    local rouletteCfg=acRoulette5VoApi:getRouletteCfg()
    local rewardData=rouletteCfg
    -- local rewardPool=FormatItem(rewardData.pool,nil,true) or {}
    local rewardPool=acRoulette5VoApi:formatItemData(rewardData.pool) or {} 
    

    local capInSet = CCRect(65, 25, 1, 1);
    local function bgClick(hd,fn,idx)
    end
    local btnBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",capInSet,bgClick)

    -- local iconWidth=(G_VisibleSize.width-150)/4
    -- local iconHeight=(G_VisibleSize.height-85-80-100-30*5)/4

    local iconWidth=122
    local iconHeight=136

    btnBg:setContentSize(CCSizeMake(iconWidth*2.5,160))
    btnBg:setAnchorPoint(ccp(0.5,0))
    btnBg:setPosition(ccp(G_VisibleSize.width/2,250))
    btnBg:setTouchPriority(0)
    self.bgLayer:addChild(btnBg)
    self.playBtnBg=btnBg

    local leftChips=GetTTFLabelWrap(getlocal("activity_wheelFortune_rest_count"),28,CCSizeMake(btnBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    leftChips:setAnchorPoint(ccp(0.5,0.5));
    leftChips:setPosition(ccp(btnBg:getContentSize().width/2,(btnBg:getContentSize().height-50)/2+50));
    btnBg:addChild(leftChips,2);

    local leftNum=acRoulette5VoApi:getLeftNum()
    self.chipNumLb=GetTTFLabel(leftNum,30)
    self.chipNumLb:setAnchorPoint(ccp(0.5,0));
    self.chipNumLb:setPosition(ccp(btnBg:getContentSize().width/2,20));
    btnBg:addChild(self.chipNumLb,2);

    local function touch()
    end
    self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    self.touchEnabledSp:setAnchorPoint(ccp(0,0))
    self.touchEnabledSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.touchEnabledSp:setIsSallow(true)
    self.touchEnabledSp:setTouchPriority(-(self.layerNum-1)*20-7)
    -- sceneGame:addChild(self.touchEnabledSp,self.layerNum)
    self.bgLayer:addChild(self.touchEnabledSp,self.layerNum)
    self.touchEnabledSp:setOpacity(0)
    self.touchEnabledSp:setPosition(ccp(10000,0))
    self.touchEnabledSp:setVisible(false)

    local function onPlay()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (acRoulette5VoApi:checkCanPlay())==true then
            -- self.touchEnabledSp:setVisible(true)
            -- self.touchEnabledSp:setPosition(ccp(0,0))
            -- if self.acRoulette5Dialog then
            --     self.acRoulette5Dialog.canClickTab=false
            -- end
            local function wheelfortuneCallback(fn,data)
                self.touchEnabledSp:setVisible(true)
                self.touchEnabledSp:setPosition(ccp(0,0))
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local leftNum=acRoulette5VoApi:getLeftNum()
                    if self and self.bgLayer then

                        self.playBtn:setEnabled(false)
                        self.playTenBtn:setEnabled(false)
                        if sData and sData.data and sData.data.zhenqinghuikui and sData.data.zhenqinghuikui.clientReward then


                            local report=sData.data.zhenqinghuikui.clientReward or {}
                            self.reward={}
                            for k,v in pairs(report) do
                                local pid,ptype,pnum
                                if v then
                                    ptype = v[1]
                                    pid = v[2]
                                    pnum = v[3]

                                    for m,n in pairs(rewardPool) do
                                        if ptype == n.type and pid == n.key and pnum ==n.num then
                                            table.insert(self.reward,n)
                                        end
                                    end
                                end
                            end
                            for k,v in pairs(self.reward) do
                                G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
                                if v.type=="mm" then
                                    local kayStr="activity_zhenqinghuikui_chatSystemMessage"
                                    if kayStr and kayStr~="" then
                                        local version = acRoulette5VoApi:getVersion()
                                        local acTitle = getlocal("activity_zhenqinghuikui_title")
                                        if version >=4 then
                                            acTitle =acRoulette5VoApi:getAcName()
                                        end
                                        local message={key=kayStr,param={playerVoApi:getPlayerName(),acTitle,v.name}}
                                        chatVoApi:sendSystemMessage(message)
                                    end
                                end
                            end

                            -- self.touchEnabledSp:setVisible(true)
                            -- self.touchEnabledSp:setPosition(ccp(0,0))
                            acRoulette5VoApi:updateLeftNum(1)
                            acRoulette5VoApi:setTenUsedNum(1)
                            self:play()

                        end
                    end
                else
                    if self and self.touchEnabledSp then
                        self.touchEnabledSp:setVisible(false)
                        self.touchEnabledSp:setPosition(ccp(10000,0))
                    end
                    if self.acRoulette5Dialog then
                        self.acRoulette5Dialog.canClickTab=true
                    end
                end
            end
            local leftNum=acRoulette5VoApi:getLeftNum()
            if leftNum>0 then
                socketHelper:activeZhenqinghuikui("reward",1,wheelfortuneCallback)--是否需要添加其他参数
            end
            
        end
    end
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSize=20
    end
    self.playBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onPlay,nil,getlocal("activity_wheelFortune_reward_btn"),textSize)
    self.playBtn:setAnchorPoint(ccp(0.5,0))
    local playBtnMenu=CCMenu:createWithItem(self.playBtn)
    playBtnMenu:setAnchorPoint(ccp(0.5,0))
    playBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2+87,0-self.playBtn:getContentSize().height-10))
    playBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playBtnMenu,2)
    -- self.playBtn:setVisible(false)
    self.playBtn:setEnabled(false)

    if (acRoulette5VoApi:checkCanPlay())==true then
        self.playBtn:setEnabled(true)
    end

    local function onTenPlay()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (acRoulette5VoApi:checkCanTenPlay())==true then
            if (acRoulette5VoApi:checkCanPlay())==true then
                local leftNum1,freeNum=acRoulette5VoApi:getLeftNum()
                if freeNum and freeNum>0 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_wheelFortune2_has_free"),28)
                    do return end
                end
            end

            local function wheelfortuneCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local leftNum=acRoulette5VoApi:getLeftNum() 
                    if self and self.bgLayer then
                        if sData and sData.data and sData.data.zhenqinghuikui and sData.data.zhenqinghuikui.clientReward then
                            
                            local reportTen=sData.data.zhenqinghuikui.clientReward or {}
                            local cfg=acRoulette5VoApi:getRouletteCfg()
                            local content={}
                            self.reward={}

                            for k,v in pairs(reportTen) do
                                local pid,ptype,pnum
                                if v then
                                    ptype = v[1]
                                    pid = v[2]
                                    pnum = v[3]

                                    for m,n in pairs(rewardPool) do
                                        if ptype == n.type and pid == n.key and pnum ==n.num then
                                            table.insert(self.reward,n)
                                        end
                                    end
                                end
                            end

                            for k,v in pairs(self.reward) do
                                local award=v or {}
                                --local index=acRoulette5VoApi:getIndexByNameAndType(award.name,award.type,award.num)
                               -- if index and index>0 then
                                    table.insert(content,{award=award,point=0,index=award.index})
                                --end
                                G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                                if award.type=="mm" then
                                    local kayStr="activity_zhenqinghuikui_chatSystemMessage"
                                    if kayStr and kayStr~="" then
                                        local version = acRoulette5VoApi:getVersion()
                                        local acTitle = getlocal("activity_zhenqinghuikui_title")
                                        if version >=4 then
                                            acTitle =acRoulette5VoApi:getAcName()
                                        end
                                        local message={key=kayStr,param={playerVoApi:getPlayerName(),acTitle,v.name}}                                        
                                        chatVoApi:sendSystemMessage(message)
                                    end
                                end
                            end
                            
                            if content and SizeOfTable(content)>0 then
                                local function confirmHandler(awardIdx)
                                    if awardIdx and awardIdx>0 then
                                        if self.rewardIconList[awardIdx] then
                                            self:showFlicker(self.rewardIconList[awardIdx])
                                        end
                                    else
                                        self:hideFlicker()
                                    end
                                end
                                smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,true)
                            end
                        end
                        acRoulette5VoApi:updateLeftNum(10)
                        acRoulette5VoApi:setTenUsedNum(10)
                        self:refresh()
                    end
                end
            end
            local leftNum=acRoulette5VoApi:getLeftNum()
            if (acRoulette5VoApi:checkCanTenPlay())==true then
                socketHelper:activeZhenqinghuikui("reward",10,wheelfortuneCallback)
            end
        end
    end

    self.playTenBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onTenPlay,nil,getlocal("ten_roulette_btn"),textSize)
    self.playTenBtn:setAnchorPoint(ccp(0.5,0))
    local playTenBtnMenu=CCMenu:createWithItem(self.playTenBtn)
    playTenBtnMenu:setAnchorPoint(ccp(0.5,0))
    playTenBtnMenu:setPosition(ccp(btnBg:getContentSize().width/2-90,0-self.playBtn:getContentSize().height-10))
    playTenBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnBg:addChild(playTenBtnMenu,2)
    self.playTenBtn:setEnabled(false)

    if (acRoulette5VoApi:checkCanTenPlay())==true then
        self.playTenBtn:setEnabled(true)
    end

    local wSpace=30
    local hSpace=-10
    local xSpace=30*3
    local ySpace=30*3+20
    for k,v in pairs(rewardPool) do
        local i=k
        if v then
            local icon=self:initRewardIcon(iconBg,i,v)

            if(i<5)then
                icon:setPosition(ccp((iconWidth+wSpace)*(i-1)+xSpace,(iconHeight+hSpace)*3+hSpace+ySpace))
            elseif(i==5)then
                icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
            elseif(i==6)then
                icon:setPosition(ccp((iconWidth+wSpace)*3+xSpace,iconHeight+hSpace*2+ySpace))
            elseif(i<11)then
                icon:setPosition(ccp((iconWidth+wSpace)*(10-i)+xSpace,hSpace*1+ySpace))
            elseif(i==11)then
                icon:setPosition(ccp(xSpace,iconHeight+hSpace*2+ySpace))
            elseif(i==12)then
                icon:setPosition(ccp(xSpace,(iconHeight+hSpace)*2+hSpace+ySpace))
            end
            self.rewardIconList[i]=icon
            self.rewardList[i]=v

        end
    end
    local function nilFunc()
    end
    self.halo=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),nilFunc)
    self.halo:setContentSize(CCSizeMake(100+8,100+8))
    self.halo:setAnchorPoint(ccp(0.5,0.5))
    self.halo:setTouchPriority(0)
    self.halo:setVisible(false)
   local tx,ty=self.rewardIconList[1]:getPosition()
   self.halo:setPosition(tx,ty)
   self.bgLayer:addChild(self.halo,3)
end

function acRoulette5Dialog:showFlicker(icon)
    if newGuidMgr:isNewGuiding() then
        do return end
    end
    if self and self.bgLayer and icon then
        local iconSize=100
        local px,py=icon:getPosition()
        -- px=px-4
        -- py=py+2
        if self.flicker==nil then
            local pzFrameName="RotatingEffect1.png"
            self.flicker=CCSprite:createWithSpriteFrameName(pzFrameName)
            local m_iconScaleX=(iconSize+8)/self.flicker:getContentSize().width
            local m_iconScaleY=(iconSize+8)/self.flicker:getContentSize().height
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
            self.bgLayer:addChild(self.flicker,5)
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
function acRoulette5Dialog:hideFlicker()
    if self and self.flicker then
        self.flicker:stopAllActions()
        self.flicker:setVisible(false)
    end
end

function acRoulette5Dialog:initRewardIcon(iconBg,i,item)

    local function showInfoHandler(hd,fn,idx)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if item and item.key and item.name and item.num then


            local isAddBg=false
            if item.key=="energy" then
                isAddBg=true
            end
            local isUseLocal=nil
            if item.type=="mm" then
                isUseLocal=true
            end
            propInfoDialog:create(sceneGame,item,self.layerNum+1,isUseLocal,isAddBg)
        end
    end
    local icon
    local v=item
    if v.type=="e" then
        if v.eType=="a" then
            icon=accessoryVoApi:getAccessoryIcon(v.id,60,80,showInfoHandler)
        elseif v.eType=="f" then
            icon=accessoryVoApi:getFragmentIcon(v.id,60,80,showInfoHandler)
            -- iconScaleX=0.8
            -- iconScaleY=0.8
        elseif v.eType=="p" then
            icon=GetBgIcon(item.pic,showInfoHandler,nil,80,80)
        end
    elseif v.type=="p" and v.equipId then
        local eType=string.sub(v.equipId,1,1)
        if eType=="a" then
            icon=accessoryVoApi:getAccessoryIcon(v.equipId,60,80,showInfoHandler)
        elseif eType=="f" then
            icon=accessoryVoApi:getFragmentIcon(v.equipId,60,80,showInfoHandler)
        else
            icon=GetBgIcon(item.pic,showInfoHandler,nil,80,80)
        end
    else
        if item.key=="energy" then
            icon = GetBgIcon(item.pic,showInfoHandler)
        else
            icon = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
            if acRoulette5VoApi:getVersion() >=2 then
                icon = LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",showInfoHandler)
                local icon2 = LuaCCSprite:createWithSpriteFrameName(item.pic,showInfoHandler)
                icon2:setPosition(ccp(icon:getContentSize().width*0.5,icon:getContentSize().height*0.5))
                icon2:setAnchorPoint(ccp(0.5,0.5))
                icon2:setScale(0.8)
                icon:addChild(icon2)            
                --icon = item.pic
            end
        end
    end
    local scale=100/icon:getContentSize().width
    icon:setAnchorPoint(ccp(0.5,0.5))
    -- icon:setPosition(ccp(bgSize.width/2,bgSize.height-icon:getContentSize().height/2*scale-5))
    icon:setIsSallow(false)
    icon:setTouchPriority(-(self.layerNum-1)*20-4)
    icon:setTag(123+i)
    icon:setScale(scale)
    
    if v.type=="p" and v.id and v.id>=293 and v.id<=295 then
    else
        local nameLb=GetTTFLabel("x"..item.num,22)
        nameLb:setAnchorPoint(ccp(1,0))
        nameLb:setPosition(ccp(icon:getContentSize().width-10,5))
        nameLb:setScale(1/scale)
        icon:addChild(nameLb)
    end

    -- iconBg:addChild(icon)
    self.bgLayer:addChild(icon,1)
    return icon
end

function acRoulette5Dialog:play()
    self.tickIndex=0
    self.tickInterval=3
    self.tickConst=3
    self.intervalNum=3 --fasttick间隔 3帧一次

    self.slowStart=false
    self.haloPos=0
    
    self.endIdx=0
    for k,v in pairs(self.rewardList) do
        if self.rewardList and v and v.type==self.reward[1].type and v.key==self.reward[1].key and v.num==self.reward[1].num then
            print(k,v.index)
            self.endIdx=k
        end
    end

    self.slowTime=4

    if self.endIdx>0 then
        self.count=12*self.tickConst --转1圈之后开始减速
        if self.endIdx>self.slowTime then
            self.slowStartIndex=self.endIdx-self.slowTime
        else
            self.count=self.count-((self.slowTime-1)*self.tickConst)
            self.slowStartIndex=self.endIdx-self.slowTime+12
        end

        self.isPlay =true
        base:addNeedRefresh(self)
    else
        self:refresh()
    end

end

function acRoulette5Dialog:fastTick()

    if self.isPlay == true then
        self.tickIndex=self.tickIndex+1
        self.tickInterval=self.tickInterval-1
        if(self.tickInterval<=0)then
            self.tickInterval=self.tickConst
            self.haloPos=self.haloPos+1
            if(self.haloPos>12)then
                self.haloPos=self.haloPos-12
                -- self.haloPos=1
            end
            local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
            self.halo:setPosition(tx,ty)
            if self.halo:isVisible()==false then
                self.halo:setVisible(true)
            end

            if (self.tickIndex>=self.count) then 

                if(self.haloPos==self.slowStartIndex)then
                    self.slowStart=true
                end
                if (self.slowStart) then
                    --此处执行减速逻辑,减到一定速度(60)之后就不再减
                    -- if(self.tickIndex>self.lastTs)then
                        if (self.tickConst<self.tickConst*3) then
                            self.tickConst=self.tickConst+self.tickConst
                        elseif self.tickConst<self.intervalNum*4 then
                            self.tickConst=self.tickConst+self.tickConst*2
                        end

                end
                if self.endIdx>0 and (self.haloPos==self.endIdx) and self.tickIndex~=self.count then
                    local function playEnd()
                        self.isPlay =false
                        base:removeFromNeedRefresh(self)
                        self:playEndEffect()
                    end
                    --local delay=CCDelayTime:create(0.5)
                    local callFunc=CCCallFuncN:create(playEnd)
                    
                    local acArr=CCArray:create()
                    --acArr:addObject(delay)
                    acArr:addObject(callFunc)
                    local seq=CCSequence:create(acArr)
                    self.bgLayer:runAction(seq)

                    
                end
            end


        end
    end
    
end

function  acRoulette5Dialog:playEndEffect()

    local bgSize=self.rewardIconList[self.haloPos]:getContentSize()
    local item=self.rewardList[self.haloPos]
    
    self.rewardIconBg = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
    self.rewardIconBg:setAnchorPoint(ccp(0.5,0.5))
    local tx,ty=self.rewardIconList[self.haloPos]:getPosition()
    -- tx=tx+bgSize.width/2
    -- ty=ty+bgSize.height/2
    self.rewardIconBg:setPosition(tx,ty)


    local rewardIcon=self.rewardIconList[self.haloPos]:getChildByTag(123+self.haloPos)
    -- self.rewardIconList[self.haloPos]:removeChild(rewardIcon,true)
    if item.key=="energy" then
        rewardIcon = GetBgIcon(item.pic)
    else
        rewardIcon = CCSprite:createWithSpriteFrameName(item.pic)
    end
    rewardIcon:setAnchorPoint(ccp(0.5,0.5))
    rewardIcon:setPosition(ccp(self.rewardIconBg:getContentSize().width/2,self.rewardIconBg:getContentSize().height/2))
    self.rewardIconBg:addChild(rewardIcon)
    self.bgLayer:addChild(self.rewardIconBg,4)
    local scale=100/rewardIcon:getContentSize().width
    rewardIcon:setScale(scale)

    if self.maskSp==nil then
        local function tmpFunc()
        end
        self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        self.maskSp:setOpacity(255)
        local size=CCSizeMake(G_VisibleSize.width-60,500)
        self.maskSp:setContentSize(size)
        self.maskSp:setAnchorPoint(ccp(0.5,0.5))
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,290))
        self.maskSp:setIsSallow(true)
        self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
        self.bgLayer:addChild(self.maskSp,3)
    else
        self.maskSp:setVisible(true)
        self.maskSp:setPosition(ccp(G_VisibleSize.width/2,290))
    end

    if self.confirmBtn==nil then
        local function hideMask()
            if self then
                -- self.bgLayer:removeChild(self.rewardIconBg,true)
                self.rewardIconBg:removeFromParentAndCleanup(true)
                self.rewardIconBg=nil

                if self.maskSp then
                    self.maskSp:setPosition(ccp(10000,0))
                    self.maskSp:setVisible(false)
                end
                if self.confirmBtn then
                    self.confirmBtn:setEnabled(false)
                    self.confirmBtn:setVisible(false)
                end
                if self.halo then
                    self.halo:setVisible(false)
                end
                if self.nameLb then
                    self.nameLb:setVisible(false)
                end
                if self.itemDescLb then
                    self.itemDescLb:setVisible(false)
                end
            end
        end
        self.confirmBtn=GetButtonItem("BigBtnBlue.png","BigBtnBlue_Down.png","BigBtnBlue_Down.png",hideMask,4,getlocal("confirm"),25)
        self.confirmBtn:setAnchorPoint(ccp(0.5,0.5))
        local boxSpMenu3=CCMenu:createWithItem(self.confirmBtn)
        boxSpMenu3:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2-160))
        boxSpMenu3:setTouchPriority(-(self.layerNum-1)*20-6)
        self.maskSp:addChild(boxSpMenu3,2)

        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    else
        self.confirmBtn:setEnabled(false)
        self.confirmBtn:setVisible(false)
    end

    -- local pointStr=getlocal("activity_wheelFortune_subTitle_3").." x"..self.diffPoint
    if self.nameLb==nil then
        -- self.nameLb=GetTTFLabelWrap(item.name,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- self.nameLb=GetTTFLabel(item.name.." x"..item.num..","..pointStr,25)
        self.nameLb=GetTTFLabel(item.name.." x"..item.num,25)
        self.nameLb:setAnchorPoint(ccp(0.5,1))
        self.nameLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+60))
        self.maskSp:addChild(self.nameLb,2)
        self.nameLb:setVisible(false)
    else
        -- self.nameLb:setString(item.name.." x"..item.num..","..pointStr)
        self.nameLb:setString(item.name.." x"..item.num)
        self.nameLb:setVisible(false)
    end

    local isShowDesc=true
    for i=1,4 do
        if item.key=="r"..i then
            isShowDesc=false
        end
    end

    local descStr
    if item.type == "mm" then
        descStr = item.desc
    else
        descStr = getlocal(item.desc)
    end
    if isShowDesc==true then
        if self.itemDescLb==nil then
            self.itemDescLb=GetTTFLabelWrap(descStr,22,CCSizeMake(G_VisibleSizeWidth-180,300),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            self.itemDescLb:setAnchorPoint(ccp(0.5,1))
            self.itemDescLb:setPosition(ccp(self.maskSp:getContentSize().width/2,self.maskSp:getContentSize().height/2+20))
            self.maskSp:addChild(self.itemDescLb,2)
            self.itemDescLb:setVisible(false)
        else
            self.itemDescLb:setString(descStr)
            self.itemDescLb:setVisible(false)
        end
    else
        if self.itemDescLb then
            self.itemDescLb:setVisible(false)
        end
    end

    local function playEndCallback()
        local str=G_showRewardTip(self.reward,false)
        if self.diffPoint and self.diffPoint>0 then
            str=str..","..getlocal("activity_wheelFortune_subTitle_3").." x"..self.diffPoint
        end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,28)

        self:refresh()

        if self.confirmBtn then
            self.confirmBtn:setEnabled(true)
            self.confirmBtn:setVisible(true)
        end
        
        if self.touchEnabledSp then
            self.touchEnabledSp:setVisible(false)
            self.touchEnabledSp:setPosition(ccp(10000,0))
        end
        if self.acRoulette5Dialog then
            self.acRoulette5Dialog.canClickTab=true
        end

        if self.nameLb then
            self.nameLb:setVisible(true)
        end
        if isShowDesc==true then
            if self.itemDescLb then
                self.itemDescLb:setVisible(true)
            end
        end
    end

    local delay1=CCDelayTime:create(0.3)
    local scale1=CCScaleTo:create(0.4,150/rewardIcon:getContentSize().width/scale)
    local scale2=CCScaleTo:create(0.4,100/rewardIcon:getContentSize().width/scale)
    -- local tx,ty=self.playBtnBg:getPosition()
    local tx,ty=self.maskSp:getPosition()
    local mvTo=CCMoveTo:create(0.3,ccp(tx,ty+150))
    local scale3=CCScaleTo:create(0.1,200/rewardIcon:getContentSize().width/scale)
    local scale4=CCScaleTo:create(0.2,120/rewardIcon:getContentSize().width/scale)
    local delay2=CCDelayTime:create(0.2)
    local callFunc=CCCallFuncN:create(playEndCallback)
    
    local acArr=CCArray:create()
    acArr:addObject(delay1)
    -- acArr:addObject(scale1)
    -- acArr:addObject(scale2)
    acArr:addObject(mvTo)
    acArr:addObject(scale3)
    acArr:addObject(scale4)
    acArr:addObject(delay2)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardIconBg:runAction(seq)
end

function acRoulette5Dialog:refresh()
    if self and self.bgLayer then
        local leftNum=acRoulette5VoApi:getLeftNum()
        if self.chipNumLb and leftNum then
            self.chipNumLb:setString(leftNum)
        end

        if self.playBtn and (acRoulette5VoApi:checkCanPlay())==true then
            self.playBtn:setEnabled(true)
        else
            self.playBtn:setEnabled(false)
        end

        if self.playTenBtn and (acRoulette5VoApi:checkCanTenPlay())==true then
            self.playTenBtn:setEnabled(true)
        else
            self.playTenBtn:setEnabled(false)
        end

        if self.cellHeight==nil then
            self.cellHeight=self:getCellHeight()
        end
        if self.titleBg then
            if self.descLb1 then
                local usedNum=acRoulette5VoApi:getUsedNum()
                if usedNum then
                    self.descLb1:setString(getlocal("activity_wheelFortune_reward_count",{usedNum}))
                end
            end
        end
    end
    
end


function acRoulette5Dialog:tick()
    local vo=acRoulette5VoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    local istoday = acRoulette5VoApi:isToday()

    if istoday ~= self.isToday then

        if acRoulette5VoApi:isRouletteToday()==false then
            self:refresh()

            self.isToday = istoday
        end
    end
   
end


function acRoulette5Dialog:dispose()
    self.isPlay =false
   self.bgLayer:removeFromParentAndCleanup(true)
   self.bgLayer = nil
   self=nil
end