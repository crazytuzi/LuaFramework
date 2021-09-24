acEquipSearchIITab1={}

function acEquipSearchIITab1:new()
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
    self.adaH = 0
    if G_getIphoneType() == G_iphoneX then
        self.adaH = 1250 - 1136
    end
    return nc
end

function acEquipSearchIITab1:init(layerNum,selectedTabIndex,acEquipSearchDialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acEquipSearchDialog=acEquipSearchDialogII
    self.bgLayer=CCLayer:create()
    self:initDesc()
    self:initAwardPool()
    self:initSearch()
    return self.bgLayer
end

function acEquipSearchIITab1:initDesc()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,80))
    titleBg:setAnchorPoint(ccp(0,0))
    titleBg:setOpacity(0)
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-80))
    self.bgLayer:addChild(titleBg,1)
    local count=math.floor((G_VisibleSizeHeight-160)/80)
    if G_getIphoneType() == G_iphoneX then
        count = count + 1
    end
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_getIphoneType() == G_iphoneX and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+45))
        elseif G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

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
        local strTab={getlocal("activity_equipSearch_search_tip_1"),getlocal("activity_equipSearch_search_tip_2"),getlocal("activity_equipSearch_search_tip_3"),getlocal("activity_equipSearch_search_tip_4"),getlocal("activity_equipSearch_search_tip_5"),getlocal("activity_equipSearch_search_tip_6")}
        local colorTab = {G_ColorWhite,G_ColorYellow,G_ColorWhite,G_ColorWhite,G_ColorYellow,G_ColorYellow}
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,strTab,colorTab,25)
    end
    local scale=0.8
    local descBtnItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",onClickDesc)
    descBtnItem:setAnchorPoint(ccp(0.5,0.5))
    -- descBtnItem:setScale(scale)
    local descBtn=CCMenu:createWithItem(descBtnItem)
    descBtn:setAnchorPoint(ccp(0.5,0.5))
    descBtn:setPosition(ccp(titleBg:getContentSize().width-descBtnItem:getContentSize().width*scale/2-10,titleBg:getContentSize().height/2))
    descBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    titleBg:addChild(descBtn,2)

end

function acEquipSearchIITab1:initAwardPool()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local backBgHeight=G_VisibleSize.height-500-self.adaH
    self.backBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),bgClick)
    self.backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,backBgHeight))
    self.backBg:setAnchorPoint(ccp(0,0))
    self.backBg:setPosition(ccp(30,247+self.adaH/2))
    self.bgLayer:addChild(self.backBg,1)


    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    -- local awardPool=FormatItem(cfg.pool) or {}
    local awardPool=cfg.pool or {}
    local row=math.ceil(SizeOfTable(awardPool)/5)
    for k,v in pairs(awardPool) do
        local flickerTb = acEquipSearchIIVoApi:getFlickerTipTb(k)
        local px=20+self.spSize/2+((k-1)%5)*110
        -- local space=(backBgHeight/row)-5
        local space=110
        local py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-16
        if G_isIphone5()==true then
            space=145
            py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-50
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
                local newBg = "rewardPanelBg1.png"--"TankInforPanel.png"
                local specialShowTb = flickerTb and flickerTb["inF"] or nil
                smallDialog:showSearchEquipDialog(newBg,CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(30, 30, 1, 1),getlocal("activity_equipSearch_reward_include"),content,true,true,self.layerNum+1,nil,nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,specialShowTb)
            end

        end
        if v.aid then
            local icon

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
                icon:setScale(scale)
                icon:setPosition(ccp(px,py))
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                self.backBg:addChild(icon,1)
                table.insert(self.spTab,k,icon)

                if flickerTb and flickerTb["flicker"] then
                    local specShowTb = {y=3}
                    G_addRectFlicker2(icon,1.1,1.1,specShowTb[flickerTb["flicker"]],flickerTb["flicker"],nil,55)
                end
            end
        end
    end

end

function acEquipSearchIITab1:initSearch()
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 = 25
    end
    local cfg=acEquipSearchIIVoApi:getEquipSearchCfg()
    local oneCost=cfg.oneCost
    local tenCost=cfg.tenCost

    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local costBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    costBg1:setContentSize(CCSizeMake(370,100))
    costBg1:setOpacity(0)
    costBg1:setPosition(ccp(G_VisibleSizeWidth*0.25,188))
    self.bgLayer:addChild(costBg1,1)

    local searchLb1=GetTTFLabelWrap(getlocal("activity_equipSearch_search_times",{oneCost[1]}),strSize2,CCSizeMake(costBg1:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    searchLb1:setAnchorPoint(ccp(0.5,0.5))
    searchLb1:setPosition(ccp(costBg1:getContentSize().width/2,costBg1:getContentSize().height-30))
    costBg1:addChild(searchLb1,2)

    local IconStr
    local scale
    local iconSize=30
    if activityVoApi:getLotteryIsUseProp(acEquipSearchIIVoApi:getAcVo()) ==true then
        IconStr = "Ticket.png"
        scale=0.5
    else
        IconStr = "IconGold.png"
        scale=0.7
    end

    
    local gemIcon1 = CCSprite:createWithSpriteFrameName(IconStr)
    gemIcon1:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/gemIcon1:getContentSize().width
    local hPos=gemIcon1:getContentSize().height/2*scale+10
    gemIcon1:setScale(scale)
    gemIcon1:setPosition(ccp(costBg1:getContentSize().width/2,hPos))
    costBg1:addChild(gemIcon1,2)

    local needLb1=GetTTFLabel(getlocal("activity_equipSearch_need"),22)
    needLb1:setAnchorPoint(ccp(1,0.5))
    needLb1:setPosition(ccp(costBg1:getContentSize().width/2-iconSize/2,hPos))
    costBg1:addChild(needLb1,2)
    needLb1:setColor(G_ColorYellowPro)

    local costLb1=GetTTFLabel(oneCost[2],22)
    costLb1:setAnchorPoint(ccp(0,0.5))
    costLb1:setPosition(ccp(costBg1:getContentSize().width/2+iconSize/2,hPos))
    costBg1:addChild(costLb1,2)
    costLb1:setColor(G_ColorYellowPro)



    local costBg2=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    costBg2:setContentSize(CCSizeMake(370,100))
    costBg2:setOpacity(0)
    costBg2:setPosition(ccp(G_VisibleSizeWidth*0.75,188))
    self.bgLayer:addChild(costBg2,1)

    local searchLb2=GetTTFLabelWrap(getlocal("activity_equipSearch_search_times",{tenCost[1]}),strSize2,CCSizeMake(costBg2:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    searchLb2:setAnchorPoint(ccp(0.5,0.5))
    searchLb2:setPosition(ccp(costBg2:getContentSize().width/2,costBg2:getContentSize().height-30))
    costBg2:addChild(searchLb2,2)

    local lSpace=45
    local gemIcon2 = CCSprite:createWithSpriteFrameName(IconStr)
    gemIcon2:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/gemIcon2:getContentSize().width
    gemIcon2:setScale(scale)
    gemIcon2:setPosition(ccp(costBg2:getContentSize().width/2-lSpace,hPos))
    costBg2:addChild(gemIcon2,2)

    local needLb2=GetTTFLabel(getlocal("activity_equipSearch_need"),22)
    needLb2:setAnchorPoint(ccp(1,0.5))
    needLb2:setPosition(ccp(costBg2:getContentSize().width/2-iconSize/2-lSpace,hPos))
    costBg2:addChild(needLb2,2)
    needLb2:setColor(G_ColorYellowPro)

    local costLb2=GetTTFLabel(tenCost[2][1],28)
    costLb2:setAnchorPoint(ccp(0,0.5))
    costLb2:setPosition(ccp(costBg2:getContentSize().width/2+iconSize/2-lSpace,hPos))
    costBg2:addChild(costLb2,2)
    costLb2:setColor(G_ColorYellowPro)

    local costLb2x,costLb2y=costLb2:getPosition()
    local gemIcon3 = CCSprite:createWithSpriteFrameName(IconStr)
    gemIcon3:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/gemIcon2:getContentSize().width
    gemIcon3:setScale(scale)
    gemIcon3:setPosition(ccp(costLb2x+75+iconSize/2,hPos))
    costBg2:addChild(gemIcon3,2)

    local costLb3=GetTTFLabel(tenCost[2][2],22)
    costLb3:setAnchorPoint(ccp(0,0.5))
    costLb3:setPosition(ccp(costLb2x+75+iconSize,hPos))
    costBg2:addChild(costLb3,2)
    costLb3:setColor(G_ColorYellowPro)

    local line = CCSprite:createWithSpriteFrameName("redline.jpg")
    line:setScaleX((costLb2:getContentSize().width+iconSize+10)/line:getContentSize().width)
    line:setAnchorPoint(ccp(0,0.5))
    line:setPosition(ccp(costLb2x-iconSize,hPos))
    costBg2:addChild(line,5)


    

    
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
                            table.insert(content,{award=award,point=v[2],index=index})
                            G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
                        end
                    end
                    if tag==1 then
                        tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))

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
                        local newBg = "rewardPanelBg1.png"--"TankInforPanel.png"
                        smallDialog:showSearchEquipDialog(newBg,CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(30, 30, 1, 1),getlocal("activity_equipSearch_total"),content,nil,true,self.layerNum+1,confirmHandler,true,true)
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
                local smallD=smallDialog:new()
                local newBg = "rewardPanelBg1.png"
                smallD:initSureAndCancle(newBg,CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(30, 30, 1, 1),touchBuy,getlocal("dialog_title_prompt"),getlocal("activity_republicHui_notEnough",{needPro,needPro,getlocal("activity_republicHui_propName")}),nil,self.layerNum+1)
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

    local textSize = 31
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
        textSize=27
    end
    self.onceBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",searchHandler,1,getlocal("activity_equipSearch_once_btn"),textSize,21)
    self.onceBtn:setAnchorPoint(ccp(0.5,0.5))
    self.onceBtn:setScale(0.9)
    local onceMune=CCMenu:createWithItem(self.onceBtn)
    onceMune:setPosition(ccp(G_VisibleSizeWidth*0.25,95))
    onceMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(onceMune,1)

    self.tenBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",searchHandler,2,getlocal("activity_equipSearch_ten_btn"),textSize,22)
    self.tenBtn:setAnchorPoint(ccp(0.5,0.5))
    self.tenBtn:setScale(0.9)
    local tenMune=CCMenu:createWithItem(self.tenBtn)
    tenMune:setPosition(ccp(G_VisibleSizeWidth*0.75,95))
    tenMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tenMune,1)

    if acEquipSearchIIVoApi:checkCanSearch()==false then
        self.onceBtn:setEnabled(false)
        self.tenBtn:setEnabled(false)
    else
        self.onceBtn:setEnabled(true)
        self.tenBtn:setEnabled(true)

        if acEquipSearchIIVoApi:isSearchToday()==false then
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
        else
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
        end
    end

end

function acEquipSearchIITab1:showFlicker(icon)
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
function acEquipSearchIITab1:hideFlicker()
    if self and self.flicker then
        self.flicker:stopAllActions()
        self.flicker:setVisible(false)
    end
end

function acEquipSearchIITab1:refresh()
    if self and self.bgLayer then
        if acEquipSearchIIVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
            self.tenBtn:setEnabled(false)
        else
            self.onceBtn:setEnabled(true)
            self.tenBtn:setEnabled(true)

            if acEquipSearchIIVoApi:isSearchToday()==false then
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
            else
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
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

function acEquipSearchIITab1:tick()
   self:updateAcTime()
end

function acEquipSearchIITab1:updateAcTime()
    local acVo=acEquipSearchIIVoApi:getAcVo()
    if acVo and self.timeLb1 and self.timeLb2 then
        G_updateActiveTime(acVo,self.timeLb1,self.timeLb2,true)
    end
end

function acEquipSearchIITab1:dispose()
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






