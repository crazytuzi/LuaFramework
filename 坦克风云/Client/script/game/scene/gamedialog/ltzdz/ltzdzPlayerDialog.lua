require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"

ltzdzPlayerDialog=commonDialog:new()

function ltzdzPlayerDialog:new(parent)
    local nc={
        selectedTabIndex=1,
        oldSelectedTabIndex=1,
        tabTb={},
        parent=parent,
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzPlayerDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
    local function click()
    end
    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("btnPanelBg.png",CCRect(96, 70, 1, 1),click)
    tvBg:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-320))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-226))
    self.bgLayer:addChild(tvBg)
    self.tvBg=tvBg

    local priority=-(self.layerNum-1)*20-8
    local tbArr={getlocal("ltzdz_player_simpleinfo"),getlocal("ltzdz_player_armyinfo"),getlocal("ltzdz_player_buildinginfo")}
    local tabBtn=CCMenu:create()
    tabBtn:setTouchPriority(priority)
    for k,v in pairs(tbArr) do
        local function tabClick(idx)
            self.oldSelectedTabIndex=self.selectedTabIndex
            return self:tabClick(idx)
        end
        local tabItem=CCMenuItemImage:create("smallTabBtn.png", "smallTabBtn_Selected.png","smallTabBtn_Selected.png")
        tabItem:setAnchorPoint(CCPointMake(0.5,0.5))
        local tabWidth=tabItem:getContentSize().width
        local pos=ccp(15+tabWidth*0.5+(k-1)*(tabWidth+2),G_VisibleSizeHeight-250)
        tabItem:setPosition(pos)
        tabItem:registerScriptTapHandler(tabClick)
        local lb=GetTTFLabelWrap(v,24,CCSizeMake(tabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(CCPointMake(tabItem:getContentSize().width/2,tabItem:getContentSize().height/2))
        lb:setTag(31)
        -- if k~=self.selectedTabIndex then
        --     lb:setColor(G_TabLBColorGreen)
        -- end
        tabItem:addChild(lb)
        tabBtn:addChild(tabItem)
        tabItem:setTag(k)
        self.tabTb[k]=tabItem
    end
    tabBtn:setPosition(0,0)
    self.bgLayer:addChild(tabBtn)
    self:tabClick(1)
end

function ltzdzPlayerDialog:tabClick(idx)
    for k,v in pairs(self.tabTb) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            local btnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
            -- btnLabel:setColor(G_ColorWhite)
            local bgWidth,bgHeight=616,G_VisibleSizeHeight-320
            if idx==2 or idx==3 then
                bgHeight=G_VisibleSizeHeight-250
            end
            if self.tvBg then
                self.tvBg:setContentSize(CCSizeMake(bgWidth,bgHeight))
            end
        else
            v:setEnabled(true)
            local btnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
            -- btnLabel:setColor(G_TabLBColorGreen)
        end
    end
    self:switchTab(idx)
end

function ltzdzPlayerDialog:switchTab(idx)
    local tablayer=self["layerTab"..idx]
    if tablayer==nil then
        if idx==1 then
            tablayer=self:initSimpleInfoLayer()
        elseif idx==2 then
            tablayer=self:initArmyInfoLayer()
        elseif idx==3 then
            tablayer=self:initBuildingInfoLayer()
        end
        self.bgLayer:addChild(tablayer,2)
        tablayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-275)
        self["layerTab"..idx]=tablayer
    else
        self["layerTab"..idx]:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-275)
        self["layerTab"..idx]:setVisible(true)
    end
    for i=1,3 do
        if i~=idx then
            local tablayer=self["layerTab"..i]
            if tablayer then
                tablayer:setPosition(9999,G_VisibleSizeHeight-275)
                tablayer:setVisible(false)
            end
        end
    end
end

function ltzdzPlayerDialog:initTableView()
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzPlayerDialog",self)

    local gems,money,oil=0,0
    local myinfo=ltzdzFightApi:getUserInfo()
    if myinfo then
        gems=myinfo.gems or 0
        money=myinfo.metal or 0
        oil=myinfo.oil or 0
    end
    local iconSize=100
    local function nilFunc()
    end
    local personPhotoName=playerVoApi:getPersonPhotoName(myinfo.pic)
    local playerIconSp=playerVoApi:GetPlayerBgIcon(personPhotoName,nilFunc)
    playerIconSp:setTouchPriority(-(self.layerNum-1)*20-3)
    playerIconSp:setAnchorPoint(ccp(0,0.5))
    playerIconSp:setPosition(20,G_VisibleSize.height-150)
    playerIconSp:setScale(iconSize/playerIconSp:getContentSize().width)
    self.bgLayer:addChild(playerIconSp)
    local nameLb=GetTTFLabelWrap(myinfo.nickname,24,CCSize(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    nameLb:setAnchorPoint(ccp(0,1))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(playerIconSp:getPositionX()+iconSize+10,G_VisibleSize.height-100)
    self.bgLayer:addChild(nameLb)

    local flag=ltzdzVoApi:isQualifying() --是否在定级赛中
    if flag==true then
        local qualifyingLb=GetTTFLabelWrap(getlocal("ltzdz_qualifying"),25,CCSize(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        qualifyingLb:setAnchorPoint(ccp(0,0.5))
        qualifyingLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height/2-50)
        self.bgLayer:addChild(qualifyingLb)
        local noSegLb=GetTTFLabelWrap(getlocal("ltzdz_noseg"),25,CCSize(200,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        noSegLb:setAnchorPoint(ccp(1,0.5))
        noSegLb:setPosition(G_VisibleSizeWidth-30,G_VisibleSizeHeight-150)
        self.bgLayer:addChild(noSegLb)
    else
        local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
        local segNameStr=ltzdzVoApi:getSegName(seg,smallLevel)
        local segmentLb=GetTTFLabelWrap(segNameStr,22,CCSize(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        segmentLb:setAnchorPoint(ccp(0,1))
        segmentLb:setPosition(nameLb:getPositionX(),nameLb:getPositionY()-nameLb:getContentSize().height)
        self.bgLayer:addChild(segmentLb)

        local segmentSp=ltzdzVoApi:getSegIcon(seg,smallLevel)
        segmentSp:setPosition(G_VisibleSize.width-100,G_VisibleSizeHeight-150)
        segmentSp:setTouchPriority(-(self.layerNum-1)*20-3)
        segmentSp:setScale(0.6)
        self.bgLayer:addChild(segmentSp)

        --当前段位经验条
        local perNum,proStr=ltzdzVoApi:getNextSegInfo()
        local percent=perNum
        AddProgramTimer(self.bgLayer,ccp(nameLb:getPositionX()+290*0.5,segmentLb:getPositionY()-segmentLb:getContentSize().height-30),21,22," ","res_progressbg.png","resyellow_progress.png",23)
        local timerSpriteLv=self.bgLayer:getChildByTag(21)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(percent)
        local barBg=self.bgLayer:getChildByTag(23)
        barBg=tolua.cast(barBg,"CCSprite")
        local scaleY=30/timerSpriteLv:getContentSize().height
        timerSpriteLv:setScaleY(scaleY)
        barBg:setScaleY(scaleY)

        local valueLb=timerSpriteLv:getChildByTag(22)
        valueLb=tolua.cast(valueLb,"CCLabelTTF")
        valueLb:setColor(G_ColorWhite)
        valueLb:setScaleY(1/scaleY)
        valueLb:setString(proStr)
    end
end

function ltzdzPlayerDialog:getNumLabelPrompt(size,promptStrInfo,numStrInfo,target,pos,spaceW)
    local promptStr=promptStrInfo[1] or ""
    local color=promptStrInfo[2] or G_ColorWhite
    local fontSize=promptStrInfo[3] or 20

    local promptLb=GetTTFLabelWrap(promptStr,fontSize,size,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0,1))
    if target then
        promptLb:setColor(color)
        promptLb:setPosition(pos)
        target:addChild(promptLb)
        if spaceW then
        else
            local tempLb=GetTTFLabel(promptStr,fontSize)
            spaceW=tempLb:getContentSize().width
            if spaceW>promptLb:getContentSize().width then
                spaceW=promptLb:getContentSize().width
            end
        end

        local numStr=numStrInfo[1] or ""
        color=numStrInfo[2] or G_ColorWhite
        fontSize=numStrInfo[3] or 20
        local numLb=GetTTFLabel(numStr,fontSize)
        numLb:setAnchorPoint(ccp(0,0.5))
        numLb:setPosition(promptLb:getPositionX()+spaceW,promptLb:getPositionY()-promptLb:getContentSize().height/2)
        numLb:setColor(color)
        target:addChild(numLb)
    end
    return promptLb,promptLb:getContentSize().height
end

function ltzdzPlayerDialog:initSimpleInfoLayer()
    local rc,oc,mec,trbNum,tobNum,tmetalbNum,tReserveNum,metal,oil,cityNum,bigNum,smallNum=ltzdzVoApi:getPlayerTotalData()
    -- print("rc,oc,mec,trbNum,tobNum,tmetalbNum,tReserveNum,metal,oil,cityNum,bigNum,smallNum--->>>",rc,oc,mec,trbNum,tobNum,tmetalbNum,tReserveNum,metal,oil,cityNum,bigNum,smallNum)
    local mapCfg=ltzdzVoApi:getMapCfg()
    local maxCityNum=SizeOfTable(mapCfg.citycfg)
    local bgSize=CCSizeMake(612,G_VisibleSizeHeight-375)
    local function nilfunc()
    end
    local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),nilfunc)
    detailBg:setContentSize(bgSize)
    detailBg:setAnchorPoint(ccp(0.5,1))
    detailBg:setOpacity(0)

    local titleFontSize,descFontSize=22,20
    local cellWidth=bgSize.width
    local cellHeightTb={}
    local function getCellHeight(idx)
        if cellHeightTb[idx]==nil then
            local cellHeight=0
            cellHeight=32 
            if idx==1 then
                local ownCityLb,lbheight=self:getNumLabelPrompt(CCSize(cellWidth-60,0),{getlocal("ltzdz_ownCity"),titleFontSize})
                cellHeight=cellHeight+lbheight+100

                local infoTb={
                    {getlocal("ltzdz_reservestr"),FormatNumber(tReserveNum),getlocal("ltzdz_reservespeed"),rc},
                    {getlocal("ltzdz_ownOil"),FormatNumber(oil),getlocal("ltzdz_capacity"),oc},
                    {getlocal("ltzdz_ownMetal"),FormatNumber(metal),getlocal("ltzdz_capacity"),mec}
                }

                for k,v in pairs(infoTb) do
                    local lb,lbheight1=self:getNumLabelPrompt(CCSize(150,0),{v[1],nil,descFontSize})
                    local speedlb,lbheight2=self:getNumLabelPrompt(CCSize(150,0),{v[3],nil,descFontSize})
                    if lbheight1>lbheight2 then
                        cellHeight=cellHeight+lbheight1+30
                    else
                        cellHeight=cellHeight+lbheight2+30
                    end
                end
            elseif idx==2 then
                local fontWidth=cellWidth-80
                local segment=ltzdzVoApi:getSegment()
                local segNameStr=ltzdzVoApi:getSegName(segment)
                local segNameLb=GetTTFLabel(segNameStr,titleFontSize)
                cellHeight=cellHeight+segNameLb:getContentSize().height+20

                local colorTab={G_ColorWhite,G_ColorYellowPro}
                local resBuff=ltzdzFightApi:getTitleBuff(segment,1)
                if resBuff>0 then
                    local segDes1Lb,lbheight1=G_getRichTextLabel(getlocal("ltzdz_seg_des1",{resBuff*100}),colorTab,descFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
                    cellHeight=cellHeight+lbheight1+10

                    local segDes2Lb,lbheight2=G_getRichTextLabel(getlocal("ltzdz_seg_des2",{resBuff*100}),colorTab,descFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
                    cellHeight=cellHeight+lbheight2+10
                end

                local desStr3=""
                if segment==1 then
                    desStr3=getlocal("ltzdz_seg_des3_1")
                else
                    desStr3=getlocal("ltzdz_seg_des3")
                end
                local segDes3Lb,lbheight3=G_getRichTextLabel(desStr3,colorTab,descFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,0)
                cellHeight=cellHeight+lbheight3+10

                local iconSize=80
                local promptStr=getlocal("ltzdz_settlement_reward")
                local rewardsLb=GetTTFLabelWrap(promptStr,descFontSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                if rewardsLb:getContentSize().height>iconSize then
                    cellHeight=cellHeight+rewardsLb:getContentSize().height
                else
                    cellHeight=cellHeight+iconSize+20
                end
            end
            cellHeightTb[idx]=cellHeight
        end
        return cellHeightTb[idx]
    end

    local function getCell(idx)
        local titleBgHeight=32
        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),function () end)
        titleBg:setAnchorPoint(ccp(0,1))
        titleBg:setContentSize(CCSizeMake(cellWidth,titleBgHeight))
        local posY=0
        if idx==1 then
            local titleLb=GetTTFLabelWrap(getlocal("ltzdz_player_simpleinfo"),titleFontSize,CCSize(cellWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setPosition(15,titleBg:getContentSize().height/2)
            titleBg:addChild(titleLb)
            posY=posY-8
            local ownCityLb,lbheight=self:getNumLabelPrompt(CCSize(cellWidth-60,0),{getlocal("ltzdz_ownCity"),nil,titleFontSize},{cityNum.."/"..maxCityNum},titleBg,ccp(20,posY))
            posY=posY-lbheight
            local bigCityPic=ltzdzFightApi:getCityPic(1,1)
            local smallCityPic=ltzdzFightApi:getCityPic(2,1)
            local bigCitySp=CCSprite:createWithSpriteFrameName(bigCityPic)
            bigCitySp:setScale(100/bigCitySp:getContentSize().height)
            bigCitySp:setPosition(cellWidth/2-180,posY-40)
            titleBg:addChild(bigCitySp)
            local bigCityNumLb=GetTTFLabel("x"..bigNum,descFontSize)
            bigCityNumLb:setAnchorPoint(ccp(0,0.5))
            bigCityNumLb:setPosition(bigCitySp:getPositionX()+bigCitySp:getContentSize().width*bigCitySp:getScale()*0.5+10,bigCitySp:getPositionY())
            titleBg:addChild(bigCityNumLb)

            local smallCitySp=CCSprite:createWithSpriteFrameName(smallCityPic)
            smallCitySp:setScale(80/smallCitySp:getContentSize().height)
            smallCitySp:setPosition(cellWidth/2+150,posY-40)
            titleBg:addChild(smallCitySp)
            local smallCityNumLb=GetTTFLabel("x"..smallNum,descFontSize)
            smallCityNumLb:setAnchorPoint(ccp(0,0.5))
            smallCityNumLb:setPosition(smallCitySp:getPositionX()+smallCitySp:getContentSize().width*smallCitySp:getScale()*0.5+10,smallCitySp:getPositionY())
            titleBg:addChild(smallCityNumLb)

            posY=posY-85

            local leftPosX,rightPosX=20,300
            local infoTb={
                {getlocal("ltzdz_reservestr"),FormatNumber(tReserveNum),getlocal("ltzdz_reservespeed"),rc},
                {getlocal("ltzdz_ownOil"),FormatNumber(oil),getlocal("ltzdz_capacity"),oc},
                {getlocal("ltzdz_ownMetal"),FormatNumber(metal),getlocal("ltzdz_capacity"),mec}
            }

            for k,v in pairs(infoTb) do
                local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp:setAnchorPoint(ccp(0.5,1))
                lineSp:setScaleX((cellWidth-40)/lineSp:getContentSize().width)
                lineSp:setPosition(ccp(cellWidth/2,posY))
                titleBg:addChild(lineSp)
                posY=posY-20
                local lb,lbheight1=self:getNumLabelPrompt(CCSize(150,0),{v[1],nil,descFontSize},{v[2],G_ColorGreen,descFontSize},titleBg,ccp(leftPosX,posY),170)
                local speedlb,lbheight2=self:getNumLabelPrompt(CCSize(150,0),{v[3],nil,descFontSize},{v[4].."/m",G_ColorGreen,descFontSize},titleBg,ccp(rightPosX,posY),170)
                if lbheight1>lbheight2 then
                    posY=posY-lbheight1-10
                else
                    posY=posY-lbheight2-10
                end
            end
        elseif idx==2 then
            local titleLb=GetTTFLabelWrap(getlocal("ltzdz_segment_detail"),titleFontSize,CCSize(cellWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setPosition(15,titleBg:getContentSize().height/2)
            titleBg:addChild(titleLb)

            posY=posY-10
            local fontWidth=cellWidth-80
            local fontSize=20
            local leftPosX=20
            local segment=1
            local flag=ltzdzVoApi:isQualifying() --是否在定级赛中
            if flag==false then
                segment=ltzdzVoApi:getSegment()
            end
            local segNameStr=ltzdzVoApi:getSegName(segment)
            local segNameLb=GetTTFLabel(segNameStr,titleFontSize)
            segNameLb:setAnchorPoint(ccp(0,1))
            segNameLb:setColor(G_ColorYellowPro)
            segNameLb:setPosition(leftPosX,posY)
            titleBg:addChild(segNameLb)
            posY=posY-segNameLb:getContentSize().height-15

            local colorTab={G_ColorWhite,G_ColorYellowPro}
            local resBuff=ltzdzFightApi:getTitleBuff(segment,1)
            if resBuff>0 then
                local segDes1Lb,lbheight1=G_getRichTextLabel(getlocal("ltzdz_seg_des1",{resBuff*100}),colorTab,descFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                segDes1Lb:setAnchorPoint(ccp(0,0.5))
                segDes1Lb:setPosition(leftPosX,posY)
                titleBg:addChild(segDes1Lb)
                posY=posY-lbheight1-10

                local segDes2Lb,lbheight2=G_getRichTextLabel(getlocal("ltzdz_seg_des2",{resBuff*100}),colorTab,descFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                segDes2Lb:setAnchorPoint(ccp(0,0.5))
                segDes2Lb:setPosition(leftPosX,posY)
                titleBg:addChild(segDes2Lb)
                posY=posY-lbheight2-10
            end

            local desStr3=""
            if segment==1 then
                desStr3=getlocal("ltzdz_seg_des3_1")
            else
                desStr3=getlocal("ltzdz_seg_des3")
            end
            local segDes3Lb=GetTTFLabelWrap(desStr3,descFontSize,CCSizeMake(fontWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            local lbheight3=segDes3Lb:getContentSize().height
            posY=posY-lbheight3/2
            segDes3Lb:setAnchorPoint(ccp(0,0.5))
            segDes3Lb:setPosition(leftPosX,posY)
            titleBg:addChild(segDes3Lb)
            posY=posY-lbheight3/2-10

            local iconSize=80
            local promptStr=getlocal("ltzdz_settlement_reward")
            local rewardsLb=GetTTFLabelWrap(promptStr,descFontSize,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            rewardsLb:setAnchorPoint(ccp(0,0.5))
            if rewardsLb:getContentSize().height>iconSize then
                posY=posY-rewardsLb:getContentSize().height*0.5
            else
                posY=posY-(iconSize+10)*0.5
            end
            rewardsLb:setPosition(leftPosX,posY)
            titleBg:addChild(rewardsLb)

            local tempLb=GetTTFLabel(promptStr,descFontSize)
            local realW=tempLb:getContentSize().width
            if realW>rewardsLb:getContentSize().width then
                realW=rewardsLb:getContentSize().width
            end
            local rewardlist=ltzdzVoApi:getFinalRewards(segment)
            for k,item in pairs(rewardlist) do
                local function showNewPropInfo()
                    G_showNewPropInfo(self.layerNum+1,true,true,nil,item)
                    return false
                end
                local iconSp,scale=G_getItemIcon(item,80,true,self.layerNum+1,showNewPropInfo)
                iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
                iconSp:setAnchorPoint(ccp(0,0.5))
                iconSp:setPosition(rewardsLb:getPositionX()+realW+(k-1)*(iconSize+10),rewardsLb:getPositionY())
                titleBg:addChild(iconSp)

                local numLb=GetTTFLabel(item.num,18)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setScale(1/scale)
                numLb:setPosition(iconSp:getContentSize().width-5,3)
                iconSp:addChild(numLb)
            end

            local function touchOtherInfo()
                ltzdzVoApi:showSegmentInfoDialog(self.layerNum+1)
            end
            local pos=ccp(cellWidth-100,-40)
            G_createBotton(titleBg,pos,{getlocal("ltzdz_other_segment"),titleFontSize},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchOtherInfo,0.7,-(self.layerNum-1)*20-4)
        end
        return titleBg
    end

    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 2
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,getCellHeight(idx+1))
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local cellHeight=getCellHeight(idx+1)
            local cellSp=getCell(idx+1)
            cellSp:setPosition(0,cellHeight)
            cell:addChild(cellSp)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,bgSize,nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(0,0))
    detailBg:addChild(tv)

    local priority=-(self.layerNum-1)*20-4
    local function giveupHandler() --投降
        local giveupFlag,gt=ltzdzFightApi:isCanGiveup()
        if giveupFlag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_giveup_disable",{G_getDataTimeStr(gt)}),30)
            do return end
        end
        local function realGiveUp()
            local function giveupCallBack()
                --返回主页面
                self:close()
                if self.parent and self.parent.close then
                    self.parent:close()
                end
            end
            ltzdzFightApi:giveup(giveupCallBack,self.layerNum-1)
        end
        local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("ltzdz_giveup"),getlocal("ltzdz_giveup_tip"),false,realGiveUp,nil,nil,desInfo)    
    end
    local pos=ccp(cellWidth/2-120,-50)
    G_createBotton(detailBg,pos,{getlocal("ltzdz_giveup")},"newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",giveupHandler,0.8,priority)

    local function foreignHandler() --外交
       ltzdzVoApi:showForeignDialog(self.layerNum+1)
    end
    pos=ccp(cellWidth/2+120,-50)
    G_createBotton(detailBg,pos,{getlocal("ltzdz_diplomacy")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",foreignHandler,0.8,priority)

    return detailBg
end

function ltzdzPlayerDialog:initArmyInfoLayer()
    local rc,oc,mec,trbNum,tobNum,tmetalbNum,tReserveNum,metal,oil,cityNum,bigNum,smallNum=ltzdzVoApi:getPlayerTotalData()

    local bgSize=CCSizeMake(612,G_VisibleSizeHeight-300)
    local function nilfunc()
    end
    local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),nilfunc)
    detailBg:setContentSize(bgSize)
    detailBg:setAnchorPoint(ccp(0.5,1))
    detailBg:setOpacity(0)

    local leftPosX,rightPosX=20,300
    local posY=bgSize.height-5
    local lbheight=0
    local citylb,lbheight1=self:getNumLabelPrompt(CCSize(150,0),{getlocal("ltzdz_ownCity"),G_ColorYellowPro},{cityNum,G_ColorYellowPro},detailBg,ccp(leftPosX,posY))
    local rlb,lbheight2=self:getNumLabelPrompt(CCSize(150,0),{getlocal("ltzdz_reservestr"),G_ColorYellowPro},{tReserveNum,G_ColorYellowPro},detailBg,ccp(rightPosX,posY))
    lbheight=lbheight1
    if lbheight<lbheight2 then
        lbheight=lbheight2
    end
    posY=posY-lbheight-10
    local rspeedlb,lbheight3=self:getNumLabelPrompt(CCSize(bgSize.width-80,0),{getlocal("ltzdz_reservespeed"),G_ColorYellowPro},{rc.."/m",G_ColorYellowPro},detailBg,ccp(leftPosX,posY))
    posY=posY-lbheight3-10

    local titleWidth=bgSize.width
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function () end)
    local itemWidth,itemHeight=140,0
    local itemInfoTb={getlocal("world_ground_name_6"),getlocal("ltzdz_reservename"),getlocal("ltzdz_rspeed"),getlocal("ltzdz_darmy")}
    local lbTb={}
    for k,v in pairs(itemInfoTb) do
        local lb=GetTTFLabelWrap(v,22,CCSize(itemWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local lbheight=lb:getContentSize().height
        detailBg:addChild(lb,2)
        if itemHeight<lbheight then
            itemHeight=lbheight
        end
        lbTb[k]=lb
    end
    itemHeight=itemHeight+20
    titleBg:setContentSize(CCSizeMake(titleWidth,itemHeight))
    titleBg:setPosition(bgSize.width/2,posY-itemHeight/2)
    detailBg:addChild(titleBg)
    for k,lb in pairs(lbTb) do
        lb=tolua.cast(lb,"CCLabelTTF")
        lb:setPosition(itemWidth/2+(k-1)*(itemWidth+10),posY-itemHeight/2)
    end

    local citylist=ltzdzVoApi:getMyCityList()
    local cellNum=SizeOfTable(citylist)

    local cellWidth,cellHeight=bgSize.width,40
    local tvHeight=bgSize.height-lbheight-lbheight3-itemHeight-25
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local city=citylist[idx+1]
            local cityId=city.id
            local cityNameStr=ltzdzCityVoApi:getCityName(cityId)
            local rspeed=ltzdzCityVoApi:getCityCapacity(cityId) --预备役产出速度
            local tankTb=ltzdzFightApi:getDefenceByCid(cityId) --防守部队
            local tankNum=0
            for i=1,6 do
                local tank=tankTb[i]
                if tank and tank[1] then
                    local tankId=tank[1]
                    local num=tank[2] or 0
                    tankNum=tankNum+num
                end
            end
            local itemWidth=140
            local itemInfoTb={cityNameStr,city.reserve,rspeed,tankNum}
            for k,v in pairs(itemInfoTb) do
                local lb=GetTTFLabelWrap(tostring(v),20,CCSize(itemWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                lb:setPosition(itemWidth/2+(k-1)*(itemWidth+10),cellHeight/2)
                cell:addChild(lb,2)
            end

            if (idx+1)%2==0 then
                local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function () end)
                itemBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
                itemBg:setPosition(cellWidth/2,cellHeight/2)
                cell:addChild(itemBg)
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSize(cellWidth,tvHeight),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(0,0))
    detailBg:addChild(tv)

    return detailBg
end

function ltzdzPlayerDialog:initBuildingInfoLayer()
    local rc,oc,mec,trbNum,tobNum,tmetalbNum,tReserveNum,metal,oil,cityNum,bigNum,smallNum=ltzdzVoApi:getPlayerTotalData()

    local bgSize=CCSizeMake(612,G_VisibleSizeHeight-300)
    local function nilfunc()
    end
    local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),nilfunc)
    detailBg:setContentSize(bgSize)
    detailBg:setAnchorPoint(ccp(0.5,1))
    detailBg:setOpacity(0)

    local leftPosX,rightPosX,fontWidth=20,300,200
    local posY=bgSize.height-5
    local rowHeight1,rowHeight2=0,0
    local citylb,lbheight1=self:getNumLabelPrompt(CCSize(fontWidth,0),{getlocal("ltzdz_ownCity"),G_ColorYellowPro},{cityNum,G_ColorYellowPro},detailBg,ccp(leftPosX,posY)) --拥有城市
    local trblb,lbheight2=self:getNumLabelPrompt(CCSize(fontWidth,0),{getlocal("ltzdz_totalNum",{getlocal("ltzdz_building_name4")}),G_ColorYellowPro},{trbNum,G_ColorYellowPro},detailBg,ccp(rightPosX,posY)) --工厂总数
    rowHeight1=lbheight1
    if rowHeight1<lbheight2 then
        rowHeight1=lbheight2
    end
    posY=posY-rowHeight1-10
    local tmetallb,lbheight3=self:getNumLabelPrompt(CCSize(fontWidth,0),{getlocal("ltzdz_totalNum",{getlocal("ltzdz_building_name5")}),G_ColorYellowPro},{tmetalbNum,G_ColorYellowPro},detailBg,ccp(leftPosX,posY)) --市场总数
    local toblb,lbheight4=self:getNumLabelPrompt(CCSize(fontWidth,0),{getlocal("ltzdz_totalNum",{getlocal("ltzdz_building_name3")}),G_ColorYellowPro},{tobNum,G_ColorYellowPro},detailBg,ccp(rightPosX,posY)) --油井总数
    rowHeight2=lbheight3
    if rowHeight2<lbheight4 then
        rowHeight2=lbheight4
    end
    posY=posY-rowHeight2-10

    local titleWidth=bgSize.width
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function () end)
    local itemWidth,itemHeight=110,0
    local itemInfoTb={getlocal("world_ground_name_6"),getlocal("island"),getlocal("ltzdz_building_name4"),getlocal("ltzdz_building_name5"),getlocal("ltzdz_building_name3")}
    local lbTb={}
    for k,v in pairs(itemInfoTb) do
        local lb=GetTTFLabelWrap(v,22,CCSize(itemWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local lbheight=lb:getContentSize().height
        detailBg:addChild(lb,2)
        if itemHeight<lbheight then
            itemHeight=lbheight
        end
        lbTb[k]=lb
    end
    itemHeight=itemHeight+20
    titleBg:setContentSize(CCSizeMake(titleWidth,itemHeight))
    titleBg:setPosition(bgSize.width/2,posY-itemHeight/2)
    detailBg:addChild(titleBg)
    for k,lb in pairs(lbTb) do
        lb=tolua.cast(lb,"CCLabelTTF")
        lb:setPosition(itemWidth/2+(k-1)*(itemWidth+10),posY-itemHeight/2)
    end

    local citylist=ltzdzVoApi:getMyCityList()
    local cellNum=SizeOfTable(citylist)

    local cellWidth,cellHeight=bgSize.width,40
    local tvHeight=bgSize.height-rowHeight1-rowHeight2-itemHeight-25
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local city=citylist[idx+1]
            local cityId=city.id
            local blv=getlocal("fightLevel",{city.mbLv})
            local cityNameStr=ltzdzCityVoApi:getCityName(cityId)
            local reserve,oil,money,rbNum,obNum,mebNum=ltzdzCityVoApi:getCityCapacity(cityId)

            local itemWidth=110
            local itemInfoTb={cityNameStr,blv,rbNum,mebNum,obNum}
            for k,v in pairs(itemInfoTb) do
                local lb=GetTTFLabelWrap(tostring(v),20,CCSize(itemWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                lb:setPosition(itemWidth/2+(k-1)*(itemWidth+10),cellHeight/2)
                cell:addChild(lb,2)
            end

            if (idx+1)%2==0 then
                local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function () end)
                itemBg:setContentSize(CCSizeMake(cellWidth,cellHeight))
                itemBg:setPosition(cellWidth/2,cellHeight/2)
                cell:addChild(itemBg)
            end
            
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSize(cellWidth,tvHeight),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(0,0))
    detailBg:addChild(tv)

    return detailBg
end

function ltzdzPlayerDialog:dispose()
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzPlayerDialog")
end
