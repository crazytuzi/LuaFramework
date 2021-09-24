ltzdzCampaignDialog = commonDialog:new()

function ltzdzCampaignDialog:new(layerNum,sFlag)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.layerNum=layerNum
    nc.sFlag=sFlag -- 1:组团 2：个人征战
    nc.isPop=true
    nc.upSpTb={}
    local function addPlist()
        spriteController:addPlist("public/ltzdz/ltzdzMainUI.plist")
        spriteController:addTexture("public/ltzdz/ltzdzMainUI.png")
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")
    return nc
end

function ltzdzCampaignDialog:resetTab()
 --    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	-- self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
end

function ltzdzCampaignDialog:initTableView( )
end

function ltzdzCampaignDialog:doUserHandler()
    local upTb={}
    local upH=G_VisibleSizeHeight-155

    if(G_isIphone5()==false)then
        upH=G_VisibleSizeHeight-140
    end

    if self.sFlag==1 then
        upTb={{str=getlocal("ltzdz_activation_troop"),pos=ccp(G_VisibleSizeWidth/2-240,upH),pic="ltzdz_activeTroops.png"},{str=getlocal("ltzdz_compose_team"),pos=ccp(G_VisibleSizeWidth/2-80,upH),pic="ltzdz_friendMake.png"},{str=getlocal("ltzdz_mathc_enemy"),pos=ccp(G_VisibleSizeWidth/2+80,upH),pic="ltzdz_match.png"},{str=getlocal("serverwarteam_enter_battlefield"),pos=ccp(G_VisibleSizeWidth/2+240,upH),pic="ltzdz_enterBattle.png"}}
    else
        upTb={{str=getlocal("ltzdz_activation_troop"),pos=ccp(G_VisibleSizeWidth/2-160,upH),pic="ltzdz_activeTroops.png"},{},{str=getlocal("ltzdz_mathc_enemy"),pos=ccp(G_VisibleSizeWidth/2,upH),pic="ltzdz_match.png"},{str=getlocal("serverwarteam_enter_battlefield"),pos=ccp(G_VisibleSizeWidth/2+160,upH),pic="ltzdz_enterBattle.png"}}
    end
    self:initUp(upTb)

    self.newLayer=CCLayer:create()
    self.bgLayer:addChild(self.newLayer)
    -- local index=1
    local state=ltzdzVoApi:stepState()
    -- local warState=ltzdzVoApi:getWarState()
    if self.sFlag==2 and state==2 then
        state=3
    end
    self.index=state
    self:refreshUp()
    self:initOrRefreshNewLayer(self.index)

    --如果没有激活部队，就触发激活部队的引导
    if otherGuideMgr:checkGuide(44)==false and state==1 and ltzdzVoApi:isQualifying()==true then
        otherGuideMgr:showGuide(44)
    end
end

function ltzdzCampaignDialog:initUp(upTb)
    for k,v in pairs(upTb) do
        if v and v.pic then
            local bgIcon=LuaCCScale9Sprite:createWithSpriteFrameName("selectKuang.png",CCRect(11, 11, 1, 1),function()end)
            self.bgLayer:addChild(bgIcon,1)
            bgIcon:setContentSize(CCSizeMake(94,94))
            bgIcon:setPosition(v.pos)
            

            local iconSp=CCSprite:createWithSpriteFrameName(v.pic)
            self.bgLayer:addChild(iconSp,2)
            iconSp:setPosition(v.pos)
-- newSelectFrame
            local selectKuangSp=CCSprite:createWithSpriteFrameName("newSelectFrame.png")
            self.bgLayer:addChild(selectKuangSp,3)
            selectKuangSp:setPosition(v.pos)

            self.upSpTb[k]={bgIcon,iconSp,selectKuangSp}

            if k~=#upTb then
                local arrowSp=CCSprite:createWithSpriteFrameName("rightThreeArrow.png")
                self.bgLayer:addChild(arrowSp)
                arrowSp:setPosition(v.pos.x+80,v.pos.y)
            end
                
            -- print("v.str",v.str)
            local desLb=GetTTFLabelWrap(v.str,25,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            desLb:setAnchorPoint(ccp(0.5,1))
            -- print("v.pos.x,v.pos.y-60",v.pos.x,v.pos.y-60)
            desLb:setPosition(v.pos.x,v.pos.y-60)
            self.bgLayer:addChild(desLb,3)
        else
            self.upSpTb[k]={}
        end
    
    end
end

function ltzdzCampaignDialog:refreshUp()
    -- self.index
    if self.upSpTb then
        for k,v in pairs(self.upSpTb) do
            if v and v[1]  then
                -- print("self.index,k",self.index,k)
                if tonumber(self.index)==tonumber(k) then
                    v[1]:setVisible(false)
                    v[2]:setColor(G_ColorWhite)
                    v[3]:setVisible(true)
                    -- v:setColor(G_ColorWhite)
                else
                    v[1]:setVisible(true)
                    v[2]:setColor(G_ColorGray)
                    v[3]:setVisible(false)
                    -- v:setColor(G_ColorGray)
                end
            end
        end
    end
end

function ltzdzCampaignDialog:initOrRefreshNewLayer(index,directFlag)
    if index==1 then
        self:initTroopLayer()
    elseif index==2 then
        local function socketFunc()
            self:initTeamLayer()
        end
        ltzdzVoApi:socketFriend(socketFunc)
    elseif index==3 then
        self:initMatchLayer(directFlag)
    else
        -- 
        -- print("+++++++应该直接进入战斗了")
    end

end
function ltzdzCampaignDialog:initTroopLayer()
    self.newLayer:removeAllChildrenWithCleanup(true)

    local desLbH1
    if G_getIphoneType() == G_iphoneX then
        desLbH1=G_VisibleSizeHeight - 345
    elseif G_getIphoneType() == G_iphone5 then
        desLbH1=G_VisibleSizeHeight - 300
    else
        desLbH1=G_VisibleSizeHeight - 260
    end
    self.troopTb={}

    local downDesLb=GetTTFLabelWrap(getlocal("ltzdz_activation_des1"),25,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    downDesLb:setAnchorPoint(ccp(0.5,0.5))
    self.newLayer:addChild(downDesLb)
    downDesLb:setPosition(self.newLayer:getContentSize().width/2,desLbH1)

    local function touchTip()
        local tabStr={}
        tabStr={getlocal("ltzdz_active_troop_tip1"),getlocal("ltzdz_active_troop_tip2"),getlocal("ltzdz_active_troop_tip3"),getlocal("ltzdz_active_troop_tip4"),getlocal("ltzdz_active_troop_tip5"),getlocal("ltzdz_active_troop_tip6"),getlocal("ltzdz_active_troop_tip7"),getlocal("ltzdz_active_troop_tip8")}
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end

    local menuScale=1
    if(G_isIphone5()==false)then
        menuScale=0.7
    end

    local pos=ccp(G_VisibleSizeWidth-60,desLbH1)
    G_addMenuInfo(self.newLayer,self.layerNum,pos,tabStr,nil,menuScale,nil,touchTip)

    local tankBgH=self.newLayer:getContentSize().height/2-30
    if(G_isIphone5()==false)then
        tankBgH=self.newLayer:getContentSize().height/2-50
    end
    -- 激活坦克背景
    local leftFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0,0.5))
    leftFrameBg2:setPosition(ccp(0,tankBgH))
    self.newLayer:addChild(leftFrameBg2,1)
    local rightFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1,0.5))
    rightFrameBg2:setPosition(ccp(self.newLayer:getContentSize().width,tankBgH))
    self.newLayer:addChild(rightFrameBg2,1)
    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setPosition(ccp(0,tankBgH))
    self.newLayer:addChild(leftFrameBg1,1)
    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setPosition(ccp(self.newLayer:getContentSize().width,tankBgH))
    self.newLayer:addChild(rightFrameBg1,1)

    local troopsBg = LuaCCScale9Sprite:createWithSpriteFrameName("st_background.png",CCRect(5, 5, 1, 1),function ()end)
    self.newLayer:addChild(troopsBg)
    troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-55,rightFrameBg1:getContentSize().height))
    -- troopsBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20,centerSprie:getContentSize().height))
    troopsBg:setPosition(self.newLayer:getContentSize().width/2,tankBgH)
    -- troopsBg:setVisible(false)

    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setAnchorPoint(ccp(0.5,0.5))
    lineSp1:setPosition(self.newLayer:getContentSize().width/2,leftFrameBg2:getPositionY()+leftFrameBg2:getContentSize().height/2)
    self.newLayer:addChild(lineSp1,3)

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setAnchorPoint(ccp(0.5,0.5))
    lineSp2:setPosition(self.newLayer:getContentSize().width/2,leftFrameBg2:getPositionY()-leftFrameBg2:getContentSize().height/2)
    self.newLayer:addChild(lineSp2,3)

    -- 激活tank
    local newLayerSize=self.newLayer:getContentSize()
    local tempTb={}

    local warCfg=ltzdzVoApi:getWarCfg()
    local placeNum=warCfg.placeNum

    local unLockNum=ltzdzVoApi:getUnLockNum()
    -- print("unLockNum",unLockNum)
    for i=1,3 do -- 3行
        for j=1,2 do -- 2列
            local bgSp
            local headNameLb
            local bgSpTag=(i-1)*2+j+200
            local function touchSelect(hd,fn,tag)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                local posNum=tag-200
                -- print("+++++++未解锁",posNum,unLockNum)
                if posNum>unLockNum then -- 未解锁
                    return 
                end
                local opacity=bgSp:getOpacity()
                -- print("opacity",opacity)

                if opacity==0 then
                    local function callBack(id,num)
                        table.insert(self.troopTb,id)
                        -- print("+++++++id,num",id,num)
                        -- editTroopsLayer:addTouchSp
                        -- tankVoApi:setTanksByType(self.type,tag,id,num)
                        bgSp:setOpacity(255)
                        self:addTouchSp(bgSp,id,num)
                        headNameLb:setString(getlocal("serverwarteam_activated"))
                        tempTb[tag]=id
                        self:removeAddEffect(bgSp)
                    end
                    ltzdzVoApi:showActiveTankDialog(self.layerNum+1,true,true,callBack,getlocal("dialog_title_prompt"),self.troopTb)

                else
                    
                    for i=#self.troopTb,1,-1 do
                        -- print("++++++tempTb[tag]",tempTb[tag])
                        if tempTb[tag]==self.troopTb[i] then
                            table.remove(self.troopTb,i)
                        end
                    end
                    headNameLb:setString(getlocal("serverwarteam_notActivated"))
                    tempTb[tag]=nil
                    bgSp:setOpacity(0)
                    bgSp:removeAllChildrenWithCleanup(true)

                    self:playAddEffect(bgSp,ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height/2-16))
                end
            end
            bgSp=LuaCCSprite:createWithSpriteFrameName("st_select2.png",touchSelect)
            bgSp:setTouchPriority(-(self.layerNum-1)*20-4)
            bgSp:setOpacity(0)
            self.newLayer:addChild(bgSp,2)
            bgSp:setTag(bgSpTag)

            local bgSize=bgSp:getContentSize()
            bgSp:setPosition(newLayerSize.width/2+((j-1.5)*2*(bgSize.width/2+20)),tankBgH+((2-i)*(bgSize.height+6)))
            local bgSp1 = CCSprite:createWithSpriteFrameName("st_select1.png")
            bgSp1:setPosition(bgSp:getPositionX(),bgSp:getPositionY())
            self.newLayer:addChild(bgSp1,1)
            bgSp1:setPosition(bgSp:getPosition())

            if i==1 and j==1 then --测试代码
                otherGuideMgr:setGuideStepField(44,nil,true,{bgSp,1})
            end

            local posNum=bgSpTag-200
            if posNum>unLockNum then -- 未解锁
                local seg=ltzdzVoApi:getSegByLevel(placeNum[posNum])
                local lockStr=getlocal("ltzdz_lock_seg",{getlocal("ltzdz_segment" .. seg)})

                local lockLb=GetTTFLabelWrap(lockStr,25,CCSizeMake(bgSp1:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                bgSp1:addChild(lockLb)
                lockLb:setPosition(bgSp1:getContentSize().width/2,bgSp1:getContentSize().height/2-10)
            else
                local nullTankSp = CCSprite:createWithSpriteFrameName("selectTankBg1.png")
                nullTankSp:setAnchorPoint(ccp(0.5,0.5))
                nullTankSp:setPosition(ccp(bgSize.width/2,bgSize.height/2-10))
                -- nullTankSp:setVisible(false)
                bgSp1:addChild(nullTankSp,1)
                nullTankSp:setScale(0.8)

                local selectTankBg2=CCSprite:createWithSpriteFrameName("selectTankBg2.png")
                selectTankBg2:setAnchorPoint(ccp(0.5,0.5))
                selectTankBg2:setPosition(ccp(nullTankSp:getContentSize().width/2,nullTankSp:getContentSize().height/2-35))
                nullTankSp:addChild(selectTankBg2)

                local capInSet = CCRect(20, 20, 10, 10)
                local function touch(hd,fn,idx)
                end
                local headNameBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
                headNameBg:setContentSize(CCSizeMake(bgSize.width,40))
                headNameBg:setAnchorPoint(ccp(0.5,0.5))
                headNameBg:setPosition(ccp(bgSp:getPositionX()-0,bgSp:getPositionY()+bgSp:getContentSize().height/2-headNameBg:getContentSize().height/2))
                self.newLayer:addChild(headNameBg,6)
                headNameBg:setOpacity(0)
                -- 头顶显示文字
                headNameLb=GetTTFLabel(getlocal("serverwarteam_notActivated"),20)
                headNameLb:setAnchorPoint(ccp(0.5,0.5))
                headNameLb:setPosition(ccp(headNameBg:getContentSize().width/2,headNameBg:getContentSize().height/2+5))
                headNameLb:setTag(12)
                headNameBg:addChild(headNameLb,1)

                self:playAddEffect(bgSp,ccp(bgSp:getContentSize().width/2,bgSp:getContentSize().height/2-16))
            end
            
            
        end
    end

    local btnPosY=80
    if(G_isIphone5()==false)then
        btnPosY=55
    end
    -- 匹配按钮
    local function touchTeamFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- 判断是否在报名时间内
        local flag,curDuan=ltzdzVoApi:canSignTime()
        if flag==0 then
            local openTime=ltzdzVoApi.openTime
            local openStr = string.format("%02d:%02d",openTime[1][1],openTime[1][2])
            G_showNewSureSmallDialog(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_signUp_expired",{openStr}),nil)
            do return end
        end

        local setNum=SizeOfTable(self.troopTb)
        -- print("setNum",setNum)
        if setNum==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_please_active_troop"),30)
            do return end
        end
        
        local function matchFunc()
            local carrayGems=tonumber(self.lastNumValue)
            
            local function setTroopAndGemsFunc()
                local function refreshFunc()
                    playerVoApi:setGems(playerVoApi:getGems() - carrayGems)
                    if self.sFlag==1 then
                        local state=2
                        self:allyNext(state)
                    else
                        local state=3
                        self:allyNext(state)
                    end
                end
                local trueTroopTb={}
                for k,v in pairs(self.troopTb) do
                    local key="a" .. v
                    table.insert(trueTroopTb,key)
                end
                ltzdzVoApi:socketSetTroop(trueTroopTb,carrayGems,refreshFunc)
            end
            if carrayGems==0 then
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_carray_gems_des"),false,setTroopAndGemsFunc,nil,nil)
            else
                setTroopAndGemsFunc()
            end
        end
        if unLockNum>setNum then
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_troop_notBig"),false,matchFunc,nil,nil)
        else
            matchFunc()
        end

        -- 扣除坦克
    end
    local btnScale=1
    local mathItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchTeamFunc,nil,getlocal("ltzdz_match_battle"),25/btnScale)
    local matchBtn=CCMenu:createWithItem(mathItem)
    matchBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    mathItem:setScale(btnScale)
    matchBtn:setPosition(G_VisibleSizeWidth/2,btnPosY)
    self.newLayer:addChild(matchBtn)

    local downLbH=btnPosY+180
    if(G_isIphone5()==false)then
        downLbH=btnPosY+110
    end

    local downDesLb=GetTTFLabelWrap(getlocal("ltzdz_activation_des2"),25,CCSizeMake(560,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    downDesLb:setAnchorPoint(ccp(0.5,0.5))
    self.newLayer:addChild(downDesLb)
    downDesLb:setPosition(self.newLayer:getContentSize().width/2,downLbH)

    -- 金币信息
    local goldPosY=btnPosY+120
    if(G_isIphone5()==false)then
        goldPosY=btnPosY+65
    end
    local ownDeslb=GetTTFLabelWrap(getlocal("serverwarteam_own_gems",{""}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    ownDeslb:setAnchorPoint(ccp(0,0.5))
    self.newLayer:addChild(ownDeslb)
    ownDeslb:setPosition(30,goldPosY)

    local ownBgPos=ccp(ownDeslb:getContentSize().width+30,goldPosY)
    local function nilFunc()
    end
    local ownBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzDisplayBox.png",CCRect(7,7,1,1),nilFunc)
    ownBg:setPosition(ownBgPos)
    ownBg:setContentSize(CCSize(120,40))
    self.newLayer:addChild(ownBg)

    local gems=playerVoApi:getGems()
    local ownNumLb=GetTTFLabel(gems,25)
    ownBg:addChild(ownNumLb)
    ownNumLb:setAnchorPoint(ccp(0,0.5))
    ownNumLb:setPosition(5,ownBg:getContentSize().height/2)

    local carryDeslb=GetTTFLabelWrap(getlocal("ltzdz_carry_gems",{""}),25,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    carryDeslb:setAnchorPoint(ccp(0,0.5))
    self.newLayer:addChild(carryDeslb)
    carryDeslb:setPosition(320,goldPosY)

    local function callbackInput(fn,eB,str,type)
        if type==1 then  --检测文本内容变化
            if str=="" then
                self.lastNumValue="0"
                self.numShowLb:setString(self.lastNumValue)
                do return end
            end
            local strNum=tonumber(str)
            if strNum==nil then
                eB:setText(self.lastNumValue)
            else
                if strNum==0 then
                    self.lastNumValue="0"
                    eB:setText("0")
                elseif strNum>=0 and strNum<=gems then
                    self.lastNumValue=strNum
                    eB:setText(strNum)
                else
                    if(strNum<0)then
                        eB:setText("0")
                        self.lastNumValue="0"
                    elseif strNum>gems then
                        eB:setText(gems)
                        self.lastNumValue=tostring(gems)
                    end
                end
            end
            self.numShowLb:setString(self.lastNumValue)
        elseif type==2 then --检测文本输入结束
            eB:setVisible(false)
            self.numShowLb:setString(self.lastNumValue)
        end
    end
    self.lastNumValue="0"
    
    local centerPoint=ccp(320+carryDeslb:getContentSize().width,goldPosY)
    local numEditBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzInputBox.png",CCRect(7,7,1,1),nilFunc)
    numEditBoxBg:setContentSize(CCSize(120,40))
    local showLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzInputBox.png",CCRect(7,7,1,1),nilFunc)
    showLbBg:setContentSize(CCSize(120,40))
    showLbBg:setPosition(centerPoint)
    self.newLayer:addChild(showLbBg)
    self.numShowLb=GetTTFLabel(self.lastNumValue,25)
    self.numShowLb:setPosition(getCenterPoint(showLbBg))
    showLbBg:addChild(self.numShowLb)
    local numEditBox
    numEditBox=CCEditBox:createForLua(CCSize(120,40),numEditBoxBg,nil,nil,callbackInput)
    if G_isIOS()==true then
        numEditBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        numEditBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end
    numEditBox:setPosition(centerPoint)
    numEditBox:setText(0)
    numEditBox:setVisible(false)
    self.newLayer:addChild(numEditBox)

    local function showEditBox()
        numEditBox:setText(self.lastNumValue)
        numEditBox:setVisible(true)
    end
    local numEditBoxBg2=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzInputBox.png",CCRect(7,7,1,1),showEditBox)
    numEditBoxBg2:setPosition(centerPoint)
    numEditBoxBg2:setContentSize(CCSize(120,40))
    numEditBoxBg2:setTouchPriority(-(self.layerNum-1)*20-4)
    numEditBoxBg2:setOpacity(0)
    self.newLayer:addChild(numEditBoxBg2)

    otherGuideMgr:setGuideStepField(45,nil,true,{numEditBoxBg2,1})
end
function ltzdzCampaignDialog:addTouchSp(bgSp,id,num)
    local touchSp= tankVoApi:getTankIconSp(id)
    local spScale=0.6
    touchSp:setPosition(ccp(10+touchSp:getContentSize().width*spScale/2,bgSp:getContentSize().height/2-15))
    touchSp:setScale(spScale)
    bgSp:addChild(touchSp,3)
    if id~=G_pickedList(id) then
        local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
        touchSp:addChild(pickedIcon)
        pickedIcon:setPosition(touchSp:getContentSize().width-30,30)
        pickedIcon:setScale(1.5)
    end

    local spDelect=CCSprite:createWithSpriteFrameName("IconFault.png")
    spDelect:setAnchorPoint(ccp(1,0))
    spDelect:setScale(0.7)
    spDelect:setPosition(ccp(bgSp:getContentSize().width-8,8))
    bgSp:addChild(spDelect,5)

    local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[id].name),20,CCSizeMake(130,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    soldiersLbName:setAnchorPoint(ccp(0,0.5))
    soldiersLbName:setPosition(ccp(touchSp:getPositionX()+touchSp:getContentSize().width*spScale/2+3,touchSp:getPositionY()+touchSp:getContentSize().height*spScale/2-13))
    bgSp:addChild(soldiersLbName,2)

    local soldiersLbNum = GetTTFLabel(num,20)
    soldiersLbNum:setAnchorPoint(ccp(0,0.5))
    soldiersLbNum:setPosition(ccp(touchSp:getPositionX()+touchSp:getContentSize().width*spScale/2+3,touchSp:getPositionY()-touchSp:getContentSize().height*spScale/2+10))
    bgSp:addChild(soldiersLbNum,2)

end
function ltzdzCampaignDialog:initTeamLayer()
    self.newLayer:removeAllChildrenWithCleanup(true)

    self.flag,self.curDuan,self.curEndTime=ltzdzVoApi:canSignTime()

    -- 今天不能报名了
    local function noSignUpFunc(event,data)
        self:refreshDateTv()
    end
    self.signUpListener=noSignUpFunc
    eventDispatcher:addEventListener("ltzdz.signUpExpired",self.signUpListener)

    -- self.newLayer
    -- 好友列表背景
    local leftPosx=10
    local leftFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    leftFrameBg2:setAnchorPoint(ccp(0,0.5))
    leftFrameBg2:setPosition(ccp(leftPosx,self.newLayer:getContentSize().height/2))
    self.newLayer:addChild(leftFrameBg2)
    local rightFrameBg2=CCSprite:createWithSpriteFrameName("st_frameBg2.jpg")
    rightFrameBg2:setFlipX(true)
    rightFrameBg2:setFlipY(true)
    rightFrameBg2:setAnchorPoint(ccp(1,0.5))
    rightFrameBg2:setPosition(ccp(self.newLayer:getContentSize().width-leftPosx,self.newLayer:getContentSize().height/2))
    self.newLayer:addChild(rightFrameBg2)
    local leftFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    leftFrameBg1:setAnchorPoint(ccp(0,0.5))
    leftFrameBg1:setPosition(ccp(leftPosx,self.newLayer:getContentSize().height/2))
    self.newLayer:addChild(leftFrameBg1)
    local rightFrameBg1=CCSprite:createWithSpriteFrameName("st_frameBg1.png")
    rightFrameBg1:setFlipX(true)
    rightFrameBg1:setAnchorPoint(ccp(1,0.5))
    rightFrameBg1:setPosition(ccp(self.newLayer:getContentSize().width-leftPosx,self.newLayer:getContentSize().height/2))
    self.newLayer:addChild(rightFrameBg1)

    local function nilFunc()
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("greenBlackBg2.png",CCRect(10,10,12,12),nilFunc)
    tvBg:setContentSize(CCSizeMake(self.newLayer:getContentSize().width-80,leftFrameBg2:getContentSize().height))
    self.newLayer:addChild(tvBg)
    tvBg:setPosition(self.newLayer:getContentSize().width/2,leftFrameBg2:getPositionY()) 
    -- tvBg:setOpacity(0)
    local tvbgSize=tvBg:getContentSize()

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(tvbgSize.width/2,-50))
    mLine:setContentSize(CCSizeMake(tvbgSize.width,mLine:getContentSize().height))
    tvBg:addChild(mLine)

    local friendDes=GetTTFLabelWrap(getlocal("ltzdz_friend_list_des"),25,CCSizeMake(tvbgSize.width - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tvBg:addChild(friendDes)
    friendDes:setPosition(tvbgSize.width/2,-30)

    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setAnchorPoint(ccp(0.5,0.5))
    lineSp1:setPosition(self.newLayer:getContentSize().width/2,leftFrameBg2:getPositionY()+leftFrameBg2:getContentSize().height/2)
    self.newLayer:addChild(lineSp1,1)

    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setAnchorPoint(ccp(0.5,0.5))
    lineSp2:setPosition(self.newLayer:getContentSize().width/2,leftFrameBg2:getPositionY()-leftFrameBg2:getContentSize().height/2)
    self.newLayer:addChild(lineSp2,1)

    local cellWidth=tvbgSize.width-40
    local cellHeight=140
    self.friendList=ltzdzVoApi:getTrueFriendList()
    self.cellNum=SizeOfTable(self.friendList)

    -- if self.cellNum==0 then
        local noFriendLb=GetTTFLabelWrap(getlocal("ltzdz_no_friend_des"),25,CCSizeMake(tvbgSize.width - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        tvBg:addChild(noFriendLb)
        noFriendLb:setPosition(tvbgSize.width/2,tvbgSize.height/2)
        self.noFriendLb=noFriendLb
        noFriendLb:setVisible(false)
    -- end
    if self.cellNum==0 then
        noFriendLb:setVisible(true)
    end 

    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.cellNum
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(cellWidth,cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local value=self.friendList[idx+1]
            local index=value.index

            local childTb={}
            local photoName=playerVoApi:getPersonPhotoName(value.pic)
            table.insert(childTb,{pic=photoName,order=2,tag=2,size=90})
            table.insert(childTb,{pic="icon_bg_gray.png",order=1,tag=1,size=100})
            local function nilFunc()
                ltzdzVoApi:showPlayerInfoSmallDialog(self.layerNum+1,true,true,callBack,getlocal("ltzdz_compete_file"),value)
            end
            local composeIcon=G_getComposeIcon(nilFunc,CCSizeMake(100,100),childTb)
            composeIcon:setPosition(70,cellHeight/2)
            cell:addChild(composeIcon)
            composeIcon:setTouchPriority(-(self.layerNum-1)*20-2)

            local nameLb=GetTTFLabel(value.nickname,25)
            cell:addChild(nameLb)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setPosition(140,cellHeight/2+30)
            nameLb:setColor(G_ColorYellowPro)

            local fightLb=GetTTFLabel(getlocal("world_war_power",{FormatNumber(value.fc)}),22)
            cell:addChild(fightLb)
            fightLb:setAnchorPoint(ccp(0,0.5))
            fightLb:setPosition(140,cellHeight/2-30)

            local function refeshList()
                
                -- self.friendList=ltzdzVoApi:getTrueFriendList()
                -- self.cellNum=SizeOfTable(self.friendList)
                -- local recordPoint=self.tv:getRecordPoint()
                -- self.tv:reloadData()
                -- self.tv:recoverToRecordPoint(recordPoint)
            end

            local function showInviteDialog()
                if self.dialog2 then
                    return
                end
                local pic=value.pic or 1
                local iconPic=playerVoApi:getPersonPhotoName(pic)
                local inviteInfo={icon=iconPic,iconBg="icon_bg_gray.png",fight=value.fc,name=value.nickname or "",uid=value.uid}
                self.dialog2=ltzdzVoApi:showInviteDialog(self.layerNum+1,true,true,refeshList,getlocal("dialog_title_prompt"),inviteInfo)
            end

            
            if ltzdzVoApi:isPopBeInviteDialog() and self.isPop and self.dialog2==nil then
                local invitelist=ltzdzVoApi.clancrossinfo.invitelist
                local uid=invitelist[#invitelist].uid
                if tonumber(uid)==tonumber(value.uid) then
                    local function showBeInviteDialog()
                        if self.dialog then
                            self.dialog:close()
                        end
                        local pic=value.pic or 1
                        local iconPic=playerVoApi:getPersonPhotoName(pic)
                        local inviteInfo={icon=iconPic,iconBg="icon_bg_gray.png",fight=value.fc,name=value.nickname or "",uid=value.uid}
                        self.dialog=ltzdzVoApi:showBeInvitedDialog(self.layerNum+1,true,true,refeshList,getlocal("dialog_title_prompt"),inviteInfo)
                    end
                    showBeInviteDialog()
                end
            end


            local btnStr=""
            local touchFlag=true
            -- ltzdz_team
            if index>10000 then
                btnStr=getlocal("ltzdz_is_inviting")
                touchFlag=false
                showInviteDialog()
            elseif index>1000 then
                btnStr=getlocal("accpet")
            else
                btnStr=getlocal("ltzdz_team")
            end

            local btnScale=0.7
            local btnlbSize=25
            local function touchOkFunc()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                local function refreshFunc(action)
                    -- self:refreshTv()
                    if action==1 then
                        ltzdzVoApi:invitySendPrivateChat(value.nickname,value.uid)
                    end
                end
                if index>10000 then
                elseif index>1000 then
                    ltzdzVoApi:socketOperateFriend(refreshFunc,value.uid,2)
                else
                    ltzdzVoApi:socketOperateFriend(refreshFunc,value.uid,1)
                end

            end
            local whatItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOkFunc,nil,btnStr,btnlbSize/btnScale)
            whatItem:setEnabled(touchFlag)
            whatItem:setScale(btnScale)

            local whatBtn=CCMenu:createWithItem(whatItem)
            whatBtn:setTouchPriority(-(self.layerNum-1)*20-2)
            whatBtn:setPosition(cellWidth-85,cellHeight/2)
            cell:addChild(whatBtn)




            if idx+1~=self.cellNum then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
                lineSp:setContentSize(CCSizeMake(cellWidth,lineSp:getContentSize().height))
                lineSp:setPosition(ccp((cellWidth)/2,0))
                cell:addChild(lineSp)
            end
            return cell
        elseif fn=="ccTouchBegan" then
            self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            self.isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end

    local function callback(...)
        return eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvbgSize.width,tvbgSize.height - 10),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(60,lineSp2:getPositionY()+5)
    self.newLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)

    local btnPosY=70
    -- 匹配按钮
    local function touchTeamFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        -- 判断是否在报名时间内
        local flag,curDuan=ltzdzVoApi:canSignTime()
        if flag==0 then
            local openTime=ltzdzVoApi.openTime
            local openStr = string.format("%02d:%02d",openTime[1][1],openTime[1][2])
            G_showNewSureSmallDialog(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_signUp_expired",{openStr}),nil)
            do return end
        end

        -- print("+++++++++下一步")
        self:initMatchLayer()

    end
    local btnScale=1
    local nextItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchTeamFunc,nil,getlocal("ltzdz_match_battle"),25/btnScale)
    local nextBtn=CCMenu:createWithItem(nextItem)
    nextBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    nextItem:setScale(btnScale)
    nextBtn:setPosition(G_VisibleSizeWidth/2,btnPosY)
    self.newLayer:addChild(nextBtn)

    local function refreshList(event,data)
        self:refreshTv(data[1])
    end
    self.friendListener=refreshList
    eventDispatcher:addEventListener("ltzdz.friend",self.friendListener)

    local function allyFunc(event,data)
        local state=3
        -- print("直接进入，不掉joinbattle")
        -- directFlag 直接进入，不掉joinbattle
        self:allyNext(state,true)
    end
    self.allyListener=allyFunc
    eventDispatcher:addEventListener("ltzdz.ally",self.allyListener)

end

-- 1 邀请，2 接受邀请，3 拒绝邀请 4:取消邀请
function ltzdzCampaignDialog:refreshTv(flag)
    -- print("++++flag",flag)
    if self.index==2 then
        if flag==1 then
            self.isPop=true
            if self.dialog then
                self.dialog:close()
                self.dialog=nil
            end
            if self.dialog2 then
                self.dialog2:close()
                self.dialog2=nil
            end
        elseif flag==2 then
            self:allyNext(3)
            self.isPop=false
            return
        elseif flag==3 then
            self.isPop=false
            if self.dialog then
                self.dialog:close()
                self.dialog=nil
            end
        elseif flag==4 then
            self.isPop=false
            if self.dialog2 then
                self.dialog2:close()
                self.dialog2=nil
            end
            if self.dialog then
                self.dialog:close()
                self.dialog=nil
            end
        elseif flag>=100 then
            local trueNum=flag-100
            if trueNum==3 or trueNum==4 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_refuse_friend"),30)
            end

            if self.dialog2 then
                local invite=ltzdzVoApi.clancrossinfo.invite
                if invite and invite.uid then
                    self.isPop=false
                else
                    self.dialog2:close()
                    self.dialog2=nil
                end
                
            else
                self.isPop=true
                if self.dialog then
                    self.dialog:close()
                    self.dialog=nil
                end
            end
        end
        self:justRefreshTv()
        self.isPop=true
        
    end
end

function ltzdzCampaignDialog:justRefreshTv()
    if self.tv then
        self.friendList=ltzdzVoApi:getTrueFriendList()
        self.cellNum=SizeOfTable(self.friendList)

        if self.cellNum==0 then
            self.noFriendLb:setVisible(true)
        else
            self.noFriendLb:setVisible(false)
        end
        -- local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        -- self.tv:recoverToRecordPoint(recordPoint)
    end
end

function ltzdzCampaignDialog:allyNext(state,directFlag)
    if self.index==2 then
        if self.dialog then
            self.dialog:close()
            self.dialog=nil
        end
        if self.dialog2 then
            self.dialog2:close()
            self.dialog2=nil
        end
        if self.friendListener then
            eventDispatcher:removeEventListener("ltzdz.friend",self.friendListener)
            self.friendListener=nil
        end
        if self.allyListener then
            eventDispatcher:removeEventListener("ltzdz.ally",self.allyListener)
            self.allyListener=nil
        end
        if self.signUpListener then
            eventDispatcher:removeEventListener("ltzdz.signUpExpired",self.signUpListener)
            self.signUpListener=nil
        end
        
        self.tv=nil
    end
    self.index=state
    self:refreshUp()
    -- if self.newLayer then
    --     self.newLayer:removeAllChildrenWithCleanup(true)
    -- end
    
    self:initOrRefreshNewLayer(self.index,directFlag)
    
end

function ltzdzCampaignDialog:closeAndTip()
    local openTime=ltzdzVoApi.openTime
    local openStr = string.format("%02d:%02d",openTime[1][1],openTime[1][2])
    G_showNewSureSmallDialog(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_signUp_expired",{openStr}),nil)
    self:close()
end

function ltzdzCampaignDialog:refreshDateTv()
    self:updateAndRefreshTv()
end

function ltzdzCampaignDialog:initMatchLayer(directFlag)
    if not self then
        return
    end
    if self.newLayer then
        self.newLayer:removeAllChildrenWithCleanup(true)
    end
    -- print("刷新")
    self.index=3
    self:refreshUp()

    if not self.bgLayer then
        return
    end

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,30))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)


    local tankBg=CCSprite:createWithSpriteFrameName("dwLoading4.png")
    tankBg:setPosition(G_VisibleSizeWidth/2-80,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(tankBg)
    self.tankSp1=CCSprite:createWithSpriteFrameName("dwLoading2.png")
    self.tankSp1:setPosition(G_VisibleSizeWidth/2-80,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(self.tankSp1)
    self.tankSp2=CCSprite:createWithSpriteFrameName("dwLoading3.png")
    self.tankSp2:setVisible(false)
    self.tankSp2:setPosition(G_VisibleSizeWidth/2-80,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(self.tankSp2)
    for i=1,4 do
        local wheelSp=CCSprite:createWithSpriteFrameName("dwLoading1.png")
        wheelSp:setPosition(G_VisibleSizeWidth/2-80 - 32 + 16*(i - 1) + 8,G_VisibleSizeHeight/2 - 22)
        self.bgLayer:addChild(wheelSp)
        local rotateBy=CCRotateBy:create(0.4,-360)
        wheelSp:runAction(CCRepeatForever:create(rotateBy))
    end
    local roundPoint=CCSprite:createWithSpriteFrameName("dwLoading5.png")
    roundPoint:setAnchorPoint(ccp(-3.8,0.5))
    roundPoint:setPosition(G_VisibleSizeWidth/2-80,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(roundPoint)
    local rotateBy=CCRotateBy:create(1,360)
    roundPoint:runAction(CCRepeatForever:create(rotateBy))

    local matchLb=GetTTFLabelWrap(getlocal("ltzdz_match_battle_in"),25,CCSizeMake(240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    self.bgLayer:addChild(matchLb)
    matchLb:setAnchorPoint(ccp(0,0))
    matchLb:setPosition(G_VisibleSizeWidth/2+10,G_VisibleSizeHeight/2+10)
    local timeLb=GetTTFLabel("0s",28)
    timeLb:setAnchorPoint(ccp(0,1))
    timeLb:setPosition(G_VisibleSizeWidth/2+10,G_VisibleSizeHeight/2-10)
    timeLb:setColor(G_ColorGreen)
    self.bgLayer:addChild(timeLb)
    self.timeLb=timeLb

    local function enterBattle(event,data)
        self.enterBattleFlag=true
    end
    self.enterBattleListener=enterBattle
    eventDispatcher:addEventListener("ltzdz.enterBattle",self.enterBattleListener)


    self.directFlag=directFlag
    self:enterBattle(true)
end

function ltzdzCampaignDialog:enterBattle(notDirectEnter)
    print("notDirectEnter",notDirectEnter)
    local function refreshFunc()
        self.directFlag=true
        local function closeFunc()
            self:close()
        end
        ltzdzFightApi:showMap(self.layerNum+1,closeFunc,notDirectEnter)
    end
    if self.directFlag then
        refreshFunc()
    else
        ltzdzFightApi:joinBattle(refreshFunc)
    end
end

function ltzdzCampaignDialog:tick()
    if self.curEndTime then
        local subTime=self.curEndTime-base.serverTime
        if subTime<0 then
            local flag,curDuan,curEndTime=ltzdzVoApi:canSignTime()
            if flag==0 then
                self.flag,self.curDuan,self.curEndTime=ltzdzVoApi:canSignTime()
                self:closeAndTip()
            else
                subTime=0
                self.flag,self.curDuan,self.curEndTime=ltzdzVoApi:canSignTime()
                if self.dialog2 then
                else
                    self:updateAndRefreshTv()  
                end
            end
        end
    end
    if self.timeLb then
        local timeStr=self.timeLb:getString()
        local arr=Split(timeStr,"s")
        local newStr=tonumber(arr[1])+1
        self.timeLb:setString(newStr .. "s")
        -- self.enterBattleFlag
        if newStr>=3 and self.enterBattleFlag then
            self.enterBattleFlag=false
            self:enterBattle()
        elseif newStr==15 then
            local function sureCallback()
                self.timeLb:setString("0s")
                self:enterBattle(true)
            end
            local function cancelCallback()
                self:close()
            end
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("ltzdz_network_timeout"),false,sureCallback,nil,cancelCallback)
        else
        end
    end
end

function ltzdzCampaignDialog:updateAndRefreshTv()  
    local function justRefreshTv()
        self:justRefreshTv()
    end
    ltzdzVoApi:crossInit(justRefreshTv,self.layerNum+1)
end

function ltzdzCampaignDialog:playAddEffect(target,pos)
    if target==nil then
        do return end
    end
    local addSp=CCSprite:createWithSpriteFrameName("st_addIcon.png")
    addSp:setPosition(pos)
    addSp:setTag(101)
    target:addChild(addSp,2)
    -- 忽隐忽现
    local fade1=CCFadeTo:create(1,55)
    local fade2=CCFadeTo:create(1,255)
    local seq=CCSequence:createWithTwoActions(fade1,fade2)
    local repeatEver=CCRepeatForever:create(seq)
    addSp:runAction(repeatEver)
end

function ltzdzCampaignDialog:removeAddEffect(target)
    if target==nil then
        do return end
    end
    local addSp=tolua.cast(target:getChildByTag(101),"CCSprite")
    if addSp then
        addSp:setVisible(false)
    end
end


function ltzdzCampaignDialog:fastTick()  
end

function ltzdzCampaignDialog:dispose()
    print("ltzdzCampaignDialog close")
    self.sFlag=nil
    self.upSpTb=nil
    self.layerNum=nil
    self.newLayer=nil
    self.timeLb=nil
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.bgLayer=nil
    spriteController:removePlist("public/ltzdz/ltzdzMainUI.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzMainUI.png")
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
end