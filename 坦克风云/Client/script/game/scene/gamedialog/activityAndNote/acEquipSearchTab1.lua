acEquipSearchTab1={}

function acEquipSearchTab1:new()
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

function acEquipSearchTab1:init(layerNum,selectedTabIndex,acEquipSearchDialog)
    self.layerNum=layerNum
    self.selectedTabIndex=selectedTabIndex
    self.acEquipSearchDialog=acEquipSearchDialog
    self.bgLayer=CCLayer:create()
    self:initDesc()
    self:initAwardPool()
    self:initSearch()
    return self.bgLayer
end

function acEquipSearchTab1:initDesc()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    titleBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,80))
    titleBg:setAnchorPoint(ccp(0,0))
    titleBg:setPosition(ccp(30,G_VisibleSize.height-85-80-80))
    self.bgLayer:addChild(titleBg,1)

    local descStr
    if acEquipSearchVoApi:acIsStop()==true then
        descStr=getlocal("activity_equipSearch_time_end")
    else
        descStr=acEquipSearchVoApi:getTimeStr()
        descStr2=acEquipSearchVoApi:getRewardTimeStr( )
    end
    -- self.descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- self.descLb:setAnchorPoint(ccp(0,0.5))
    -- self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2))
    -- titleBg:addChild(self.descLb,2)
    if acEquipSearchVoApi:acIsStop()==true then
        self.descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(titleBg:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.descLb:setAnchorPoint(ccp(0,0.5))
        self.descLb:setPosition(ccp(15,titleBg:getContentSize().height/2))
        titleBg:addChild(self.descLb,2)
    else
        local moveBgStarStr,timeLb,rewardTimeLb = G_LabelRollView(CCSizeMake(titleBg:getContentSize().width-100,titleBg:getContentSize().height-10),descStr,25,kCCTextAlignmentLeft,G_ColorGreen,nil,descStr2,G_ColorYellowPro,2,2,2,nil)
        moveBgStarStr:setAnchorPoint(ccp(0,0))
        moveBgStarStr:setPosition(ccp(15,5))
        titleBg:addChild(moveBgStarStr,2)
        self.timeLb=timeLb
        self.rewardTimeLb=rewardTimeLb
        local vo=acEquipSearchVoApi:getAcVo()
        G_updateActiveTime(vo,self.timeLb,self.rewardTimeLb,true)
    end
    local function onClickDesc()
        local strTab={" ",getlocal("activity_equipSearch_search_tip_6"),getlocal("activity_equipSearch_search_tip_5"),getlocal("activity_equipSearch_search_tip_4"),getlocal("activity_equipSearch_search_tip_3"),getlocal("activity_equipSearch_search_tip_2"),getlocal("activity_equipSearch_search_tip_1")," "}
        local colorTab={nil,G_ColorYellow,G_ColorYellow,G_ColorWhite,G_ColorWhite,G_ColorYellow,G_ColorWhite,nil}
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

function acEquipSearchTab1:initAwardPool()
    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local backBgHeight=G_VisibleSize.height-500
    self.backBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    self.backBg:setContentSize(CCSizeMake(G_VisibleSize.width-60,backBgHeight))
    self.backBg:setAnchorPoint(ccp(0,0))
    self.backBg:setPosition(ccp(30,247))
    self.bgLayer:addChild(self.backBg,1)


    local cfg=acEquipSearchVoApi:getEquipSearchCfg()
    -- local awardPool=FormatItem(cfg.pool) or {}
    local awardPool=cfg.pool or {}
    local row=math.ceil(SizeOfTable(awardPool)/5)
    for k,v in pairs(awardPool) do
        local px=20+self.spSize/2+((k-1)%5)*110
        -- local space=(backBgHeight/row)-5
        local space=110
        local py=self.backBg:getContentSize().height-(math.ceil(k/5)-1)*space-self.spSize/2-16
        if G_isIphone5()==true then
            space=135
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

            -- local cfg=acEquipSearchVoApi:getEquipSearchCfg()
            -- local reward=cfg.pool[k].content
            -- local content={}

            -- for p,q in pairs(reward) do
            --     local rewardType=p
            --     for m,n in pairs(q) do
            --         local key
            --         local point=0
            --         local num=0
            --         local index=0
            --         local name,pic,desc,id,nouse,eType,equipId
            --         for i,j in pairs(n) do
            --             if j then
            --                 if i=="wz" then
            --                     if type(j)=="table" and j[1] and j[2] then
            --                         point=j[1].."~"..j[2]
            --                     else
            --                         point=tonumber(j)
            --                     end
            --                 elseif i=="index" then
            --                     index=tonumber(j)
            --                 else
            --                     key=i
            --                     num=tonumber(j)
            --                     name,pic,desc,id,nouse,eType,equipId=getItem(i,rewardType)
            --                 end
            --             end
            --         end
            --         local award={name=name,num=num,pic=pic,desc=desc,id=id,type=rewardType,index=index,key=key,eType=eType,equipId=equipId}
            --         local function sortAsc(a, b)
            --             if a and b and a.index and b.index and tonumber(a.index) and tonumber(b.index) then
            --                 return a.index < b.index
            --             end
            --         end
            --         table.sort(award,sortAsc)
            --         table.insert(content,{award=award,point=point})
            --     end
            -- end

            local content=acEquipSearchVoApi:formatContent(k)
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
                icon:setScale(scale)
                icon:setPosition(ccp(px,py))
                icon:setTouchPriority(-(self.layerNum-1)*20-4)
                self.backBg:addChild(icon,1)
                table.insert(self.spTab,k,icon)
            end
        end
    end

end

function acEquipSearchTab1:initSearch()
    local cfg=acEquipSearchVoApi:getEquipSearchCfg()
    local oneCost=cfg.oneCost
    local tenCost=cfg.tenCost

    local capInSet = CCRect(20, 20, 10, 10)
    local function bgClick(hd,fn,idx)
    end
    local costBg1=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,bgClick)
    costBg1:setContentSize(CCSizeMake(370,100))
    costBg1:setAnchorPoint(ccp(0,0.5))
    costBg1:setPosition(ccp(30,188))
    self.bgLayer:addChild(costBg1,1)

    local searchLb1=GetTTFLabelWrap(getlocal("activity_equipSearch_search_times",{oneCost[1]}),25,CCSizeMake(costBg1:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    searchLb1:setAnchorPoint(ccp(0.5,0.5))
    searchLb1:setPosition(ccp(costBg1:getContentSize().width/2,costBg1:getContentSize().height-30))
    costBg1:addChild(searchLb1,2)

    local scale=0.7
    local iconSize=30
    local gemIcon1 = CCSprite:createWithSpriteFrameName("IconGold.png")
    gemIcon1:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/gemIcon1:getContentSize().width
    local hPos=gemIcon1:getContentSize().height/2*scale+10
    gemIcon1:setScale(scale)
    gemIcon1:setPosition(ccp(costBg1:getContentSize().width/2,hPos))
    costBg1:addChild(gemIcon1,2)

    -- local needLb1=GetTTFLabelWrap(getlocal("activity_equipSearch_need"),22,CCSizeMake(costBg1:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
    costBg2:setAnchorPoint(ccp(0,0.5))
    costBg2:setPosition(ccp(30,82))
    self.bgLayer:addChild(costBg2,1)

    local searchLb2=GetTTFLabelWrap(getlocal("activity_equipSearch_search_times",{tenCost[1]}),25,CCSizeMake(costBg2:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    searchLb2:setAnchorPoint(ccp(0.5,0.5))
    searchLb2:setPosition(ccp(costBg2:getContentSize().width/2,costBg2:getContentSize().height-30))
    costBg2:addChild(searchLb2,2)

    local lSpace=45
    local gemIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    gemIcon2:setAnchorPoint(ccp(0.5,0.5))
    local scale=iconSize/gemIcon2:getContentSize().width
    gemIcon2:setScale(scale)
    gemIcon2:setPosition(ccp(costBg2:getContentSize().width/2-lSpace,hPos))
    costBg2:addChild(gemIcon2,2)

    -- local needLb2=GetTTFLabelWrap(getlocal("activity_equipSearch_need"),22,CCSizeMake(costBg2:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
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
    local gemIcon3 = CCSprite:createWithSpriteFrameName("IconGold.png")
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

        if acEquipSearchVoApi:checkCanSearch()==false then
            do return end
        end

        local cfg=acEquipSearchVoApi:getEquipSearchCfg()

        local oneCost=cfg.oneCost[2]
        local tenCost=cfg.tenCost[2][2]
        if tag==1 then
            local diffGems=oneCost-playerVoApi:getGems()
            if acEquipSearchVoApi:isSearchToday()==false then
                
            elseif diffGems>0 then
                GemsNotEnoughDialog(nil,nil,diffGems,self.layerNum+1,oneCost)
                do return end
            end
        else
            local diffGems2=tenCost-playerVoApi:getGems()
            if diffGems2>0 then
                GemsNotEnoughDialog(nil,nil,diffGems2,self.layerNum+1,tenCost)
                do return end
            end
        end

        local function searchCallback(fn,data)
            local isCost=acEquipSearchVoApi:isSearchToday()
            local ret,sData=base:checkServerData(data)
            if ret==true then
                local cfg=acEquipSearchVoApi:getEquipSearchCfg()
                local oneCost1=cfg.oneCost[2]
                local tenCost1=cfg.tenCost[2][2]
                if tag==1 then
                    if isCost==true then
                        playerVoApi:setValue("gems",playerVoApi:getGems()-oneCost1)
                    end
                else
                    playerVoApi:setValue("gems",playerVoApi:getGems()-tenCost1)
                end

                if sData.data.useractive and sData.data.useractive.equipSearch then
                    local equipSearch=sData.data.useractive.equipSearch
                    acEquipSearchVoApi:updateData(equipSearch)
                end

                if sData.data.equipSearch and sData.data.equipSearch.report and self and self.bgLayer then
                    local content={}
                    local report=sData.data.equipSearch.report or {}
                    for k,v in pairs(report) do
                        local awardTb=FormatItem(v[1]) or {}
                        for m,n in pairs(awardTb) do
                            local award=n or {}
                            local index=acEquipSearchVoApi:getIndexByNameAndNum(award.key,award.num)
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
                        smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_equipSearch_total"),content,nil,true,self.layerNum+1,confirmHandler,true,true)
                    end
                end

                if self.acEquipSearchDialog then
                    self.acEquipSearchDialog:refresh()
                end
            end
        end
        local once=cfg.oneCost[1]
        local ten=cfg.tenCost[1]
        if tag==1 then
            socketHelper:activeEquipsearch(1,searchCallback,once)
        elseif tag==2 then
            socketHelper:activeEquipsearch(1,searchCallback,ten)
        end
        
    end
    -- self.onceBtn=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",searchHandler,1)
    local textSize = 25
    if platCfg.platCfgBMImage[G_curPlatName()]~=nil  then
        textSize=20
    end
    self.onceBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",searchHandler,1,getlocal("activity_equipSearch_once_btn"),textSize,21)
    self.onceBtn:setAnchorPoint(ccp(0.5,0.5))
    local onceMune=CCMenu:createWithItem(self.onceBtn)
    onceMune:setAnchorPoint(ccp(0.5,0.5))
    onceMune:setPosition(ccp(self.bgLayer:getContentSize().width-self.onceBtn:getContentSize().width/2-50,188))
    onceMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(onceMune,1)

    self.tenBtn=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",searchHandler,2,getlocal("activity_equipSearch_ten_btn"),textSize,22)
    self.tenBtn:setAnchorPoint(ccp(0.5,0.5))
    local tenMune=CCMenu:createWithItem(self.tenBtn)
    tenMune:setAnchorPoint(ccp(0.5,0.5))
    tenMune:setPosition(ccp(self.bgLayer:getContentSize().width-self.tenBtn:getContentSize().width/2-50,82))
    tenMune:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tenMune,1)

    if acEquipSearchVoApi:checkCanSearch()==false then
        self.onceBtn:setEnabled(false)
        self.tenBtn:setEnabled(false)
    else
        self.onceBtn:setEnabled(true)
        self.tenBtn:setEnabled(true)

        if acEquipSearchVoApi:isSearchToday()==false then
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
        else
            tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
        end
    end

end

function acEquipSearchTab1:showFlicker(icon)
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
function acEquipSearchTab1:hideFlicker()
    if self and self.flicker then
        self.flicker:stopAllActions()
        self.flicker:setVisible(false)
    end
end

function acEquipSearchTab1:refresh()
    if self and self.bgLayer then
        if acEquipSearchVoApi:checkCanSearch()==false then
            self.onceBtn:setEnabled(false)
            self.tenBtn:setEnabled(false)
        else
            self.onceBtn:setEnabled(true)
            self.tenBtn:setEnabled(true)

            if acEquipSearchVoApi:isSearchToday()==false then
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_free_btn"))
            else
                tolua.cast(self.onceBtn:getChildByTag(21),"CCLabelTTF"):setString(getlocal("activity_equipSearch_once_btn"))
            end
        end

        if self.descLb then
            if acEquipSearchVoApi:acIsStop()==true then
                self.descLb:setString(getlocal("activity_equipSearch_time_end"))
            else
                local timeStr=acEquipSearchVoApi:getTimeStr()
                self.descLb:setString(timeStr)
            end
        end

    end
    
end

function acEquipSearchTab1:tick()
    if self.timeLb and self.rewardTimeLb then
        local vo=acEquipSearchVoApi:getAcVo()
        G_updateActiveTime(vo,self.timeLb,self.rewardTimeLb,true)
    end
end

function acEquipSearchTab1:dispose()
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
    self.timeLb=nil
    self.rewardTimeLb=nil
    self=nil
end






