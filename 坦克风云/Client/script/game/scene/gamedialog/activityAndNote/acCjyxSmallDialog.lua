acCjyxSmallDialog=smallDialog:new()

function acCjyxSmallDialog:new()
	local nc={
        tickIndex=0,
        cellInitIndex=0,
        isOneByOne=false,
        layerNum=0,
        cellTb=nil,
    }
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acCjyxSmallDialog:showLogDialog(bgSrc,size,inRect,title,loglist,isuseami,layerNum,callBackHandler,scrollEnable,recordNum,isOneByOne,useNewUI,acName)
  	local sd=acCjyxSmallDialog:new()
	sd:initLogDialog(bgSrc,size,inRect,title,loglist,isuseami,layerNum,callBackHandler,scrollEnable,recordNum,isOneByOne,useNewUI,acName)
end

function acCjyxSmallDialog:initLogDialog(bgSrc,size,inRect,title,loglist,isuseami,layerNum,callBackHandler,scrollEnable,recordNum,isOneByOne,useNewUI,acName)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.isOneByOne=isOneByOne or false
    self.loglist=loglist or {}
    self.useNewUI=useNewUI
    self.acName = (acName and type(acName) == "table") and acName[1] or acName
    self.reLog = (acName and type(acName) == "table") and acName[2] or nil
    local function touchHander()   
    end
    local dialogBg
    if useNewUI==true then
        local titleStr1,color1,tsize1
        if title then
            titleStr1=title[1] or ""
            color1=title[2] or G_ColorWhite
            tsize1=title[3] or 30
        end
        dialogBg=G_getNewDialogBg(size,titleStr1,tsize1,touchHander,layerNum,nil,nil,color1)
    else
        dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    end
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()
    local recordCount=recordNum or 15
    self.scrollFlag=scrollEnable or false
    local function touchDialog()
    end
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    if useNewUI==true then
    elseif title then
    	local titleStr=title[1]
    	local color=title[2] or G_ColorWhite
    	local tsize=title[3] or 30
    	if titleStr then
		    local titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		    titleLb:setPosition(ccp(size.width/2,size.height-50))
		    titleLb:setColor(color)
		    self.bgLayer:addChild(titleLb)
    	end
    end
    local txtSize=24
    local noticeLb=GetTTFLabelWrap(getlocal("activity_xinchunhongbao_repordMax",{recordCount}),txtSize,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeLb:setAnchorPoint(ccp(0.5,0.5))
    noticeLb:setPosition(ccp(size.width/2,123))
    noticeLb:setColor(G_ColorYellowPro2)
    self.bgLayer:addChild(noticeLb)

    local tvWidth=size.width-40
    local tvHeight=size.height-240
    local tvSubedHeight = (self.acName and (self.acName == "yrj")) and 30 or 0
    if self.acName == "hljbLog" then
        tvSubedHeight = -10
    end
    self.cellWidth=tvWidth
    self.cellHeightTb={}
    self.titleW=size.width-220
    self.propSize=70
    self.spaceX=10
    self.spaceY=10
    self.num=4
    if self.useNewUI==true then
        self.num=6
    end
    self.cellNum=SizeOfTable(self.loglist)

    base:addNeedRefresh(self)
    self.cellTb={}
    local isMoved=false

    if self.acName and self.acName == "yrj" and self.cellNum == 0 then
        self.tipPosx,self.tipPosy = self.cellWidth * 0.5 + 20,(tvHeight - tvSubedHeight) * 0.5 + size.height-90-tvHeight
        self.curNotRewardLogStr = GetTTFLabelWrap(getlocal("curNotRewardLog"),26,CCSizeMake(self.cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        self.curNotRewardLogStr:setPosition(ccp(self.tipPosx,self.tipPosy))
        self.bgLayer:addChild(self.curNotRewardLogStr,1)
        self.curNotRewardLogStr:setColor(G_ColorGray)
    else
        local tvOffseth = 0
        if self.acName == "hljbLog" then
            local secTitleLb=self:initUpSecTitle(getlocal("activity_hljbLogTIp"))
            tvOffseth = secTitleLb:getContentSize().height + 10
        end
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return self.cellNum
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(self.cellWidth,self:getCellHeight(idx+1))
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()
                if isOneByOne and isOneByOne==true then
                    self.cellTb[idx+1]=cell
                    if idx==0 then
                        cellSp=self:getCell(idx+1)
                        cell:addChild(cellSp)
                    end
                else
                    local cellSp=self:getCell(idx+1)
                    cell:addChild(cellSp)
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
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight - tvSubedHeight - tvOffseth),nil)    
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
        self.tv:setPosition(ccp(20,size.height-90-tvHeight))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
    end
    if self.tv then
        self.refreshData.tableView=self.tv
    end
    
    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth*0.43,size.height-90-tvHeight))
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    if self.acName then
        if self.acName == "yrj" then
            self:initTv2(tvWidth,tvHeight - tvSubedHeight,20,size.height-90-tvHeight)
            self:initSubTab(size.height - 90 - tvSubedHeight)
        end
    end

    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end
    local sureItem
    if self.useNewUI==true then
        sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",cancleHandler,2,getlocal("ok"),25/0.8)
        sureItem:setScale(0.8)
    else
        sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    end
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    dialogBg:addChild(sureMenu)
    
    local function touchLuaSpr()
         
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    self:addForbidSp(self.bgLayer,size,layerNum,nil,nil,true)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function acCjyxSmallDialog:getCellHeight(idx)
    if self.cellHeightTb==nil then
        self.cellHeightTb={}
    end
    if self.cellHeightTb[idx]==nil then
        local height=0
        local log=self.loglist[idx]
        local titleStr=log.title[1] or ""
        local color=log.title[2] or G_ColorWhite
        local tsize=log.title[3] or 25
        local append=log.append
        local subW=self.titleW
        local appendW=0
        local appendLb
        if append then
            subW=self.titleW*0.5
            appendW=self.titleW*0.5
            local astr=append[1] or ""
            local atsize=append[3] or 25
            appendLb=GetTTFLabelWrap(astr,atsize,CCSizeMake(appendW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
        end
        local subTitleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(subW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
        subTitleLb:setColor(color)
        local h1=subTitleLb:getContentSize().height
        height=h1            
        if appendLb then
            local h2=appendLb:getContentSize().height
            if h2>height then
                height=h2
            end
        end
        if log.subhead then --副标题
            local subhead=log.subhead
            local titleStr=subhead[1] or ""
            local color=subhead[2] or G_ColorWhite
            local tsize=subhead[3] or 25
            local headLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(subW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
            height=height+headLb:getContentSize().height
        end
        height=height+20
        local content=log.content
        local num=self.num
        for k,item in pairs(content) do
            local rewardlist=item[1] --每一项的奖励
            local count=SizeOfTable(rewardlist)
            if count%num>0 then
                count=math.floor(count/num)+1
            else
                count=math.floor(count/num)
            end
            height=height+count*self.propSize+(count-1)*self.spaceY
        end
        local itemCount=SizeOfTable(content)
        height=height+(itemCount-1)*20+20
        self.cellHeightTb[idx]=height+20
    end
    return self.cellHeightTb[idx]
end

function acCjyxSmallDialog:getCell(idx)
    local cellWidth=self.cellWidth
    local cellHeight=self:getCellHeight(idx)
    local propSize=self.propSize
    local cellSp=CCNode:create()
    cellSp:setContentSize(CCSizeMake(cellWidth,cellHeight))
    cellSp:setAnchorPoint(ccp(0,0))
    cellSp:setPosition(0,0)

    local log=self.loglist[idx]
    if log then
        local content=log.content
        local ts=log.ts or base.serverTime
        local title=log.title
        local titleStr=title[1] or ""
        local colorCur=title[2] or G_ColorWhite
        local tsize=log.title[3] or 25
        local timeStr=G_getDataTimeStr(ts)
        local append=log.append
        local titleW=self.titleW
        local subW=titleW
        local appendW=0
        local appendLb,subheadLb
        if G_getCurChoseLanguage() ~="cn" and G_getCurChoseLanguage() ~="tw" and G_getCurChoseLanguage() ~="ja" and G_getCurChoseLanguage() ~="ko" then
            tsize = 21
        end
        if append then
            subW=titleW*0.5
            appendW=titleW*0.5
            local astr=append[1] or ""
            local acolor=append[2] or G_ColorWhite
            local atsize=append[3] or 25
            appendLb=GetTTFLabelWrap(astr,atsize,CCSizeMake(appendW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
            appendLb:setColor(acolor)
        end
        local titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(subW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
        titleLb:setColor(colorCur)
        local h1=titleLb:getContentSize().height
        local bgHeight=h1
        if appendLb then
            local h2=appendLb:getContentSize().height
            if h2>bgHeight then
                bgHeight=h2
            end
        end
        if log.subhead then --副标题
            local subhead=log.subhead
            local titleStr=subhead[1] or ""
            local color=subhead[2] or G_ColorWhite
            local tsize=subhead[3] or 20
            subheadLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(subW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
            subheadLb:setColor(color)
            bgHeight=bgHeight+subheadLb:getContentSize().height
        end
        bgHeight=bgHeight+20
        if bgHeight<50 then
            bgHeight=50
        end
        local function bgClick()
        end
        local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),bgClick)
        titleBg:setContentSize(CCSizeMake(cellWidth,bgHeight))
        titleBg:setAnchorPoint(ccp(0,1))
        titleBg:setPosition(ccp(0,cellHeight))
        -- titleBg:setScaleY(bgHeight/titleBg:getContentSize().height)
        cellSp:addChild(titleBg,3)
        local titleBg2=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),bgClick)
        titleBg2:setContentSize(CCSizeMake(cellWidth,bgHeight))
        titleBg2:setAnchorPoint(ccp(0,1))
        titleBg2:setPosition(ccp(0,cellHeight))
        -- titleBg2:setScaleY(bgHeight/titleBg2:getContentSize().height)
        cellSp:addChild(titleBg2,2)
        titleLb:setAnchorPoint(ccp(0,0.5))
        titleLb:setPosition(ccp(10,bgHeight/2))
        titleBg:addChild(titleLb,1)
        if appendLb then
            appendLb:setAnchorPoint(ccp(0,0.5))
            appendLb:setPosition(titleLb:getPositionX()+titleLb:getContentSize().width+10,bgHeight/2)
            titleBg:addChild(appendLb,1)
        end
        if subheadLb then
            titleLb:setPositionY(bgHeight/2+titleLb:getContentSize().height/2)
            if appendLb then
                appendLb:setPositionY(titleLb:getPositionY())
            end
            subheadLb:setAnchorPoint(ccp(0,0.5))
            subheadLb:setPosition(titleLb:getPositionX(),bgHeight/2-subheadLb:getContentSize().height/2)
            titleBg:addChild(subheadLb,1)
        end

        local posY=cellHeight-bgHeight
        local timeLb=GetTTFLabel(timeStr,22)
        timeLb:setAnchorPoint(ccp(1,0.5))
        timeLb:setPosition(ccp(cellWidth-20,bgHeight/2))
        titleBg:addChild(timeLb,1)

        local function nilfunc()
        end
        local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20,20,1,1),nilfunc)
        detailBg:setContentSize(CCSizeMake(cellWidth,cellHeight-bgHeight+10))
        detailBg:setAnchorPoint(ccp(0.5,1))
        detailBg:setPosition(cellWidth/2,posY+20)
        cellSp:addChild(detailBg)
        if self.useNewUI==true then
            titleBg:setOpacity(0)
            titleBg2:setOpacity(0)
            detailBg:setOpacity(0)

            local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
            cellBg:setAnchorPoint(ccp(0,1))
            cellBg:setContentSize(CCSizeMake(cellWidth,cellHeight-10))
            cellBg:setPosition(ccp(0,cellHeight))
            cellSp:addChild(cellBg)
            -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
            -- pointSp1:setPosition(ccp(5,cellBg:getContentSize().height/2))
            -- cellBg:addChild(pointSp1)
            -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
            -- pointSp2:setPosition(ccp(cellBg:getContentSize().width-5,cellBg:getContentSize().height/2))
            -- cellBg:addChild(pointSp2)
            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
            lineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width-20,lineSp:getContentSize().height))
            lineSp:setPosition(ccp(cellBg:getContentSize().width/2,cellBg:getContentSize().height-bgHeight+5))
            cellBg:addChild(lineSp)
        end

        local itemCount=SizeOfTable(content)
        posY=posY-10
        local function initRewards(parent,rewardPanelH)
            for k,item in pairs(content) do
                local title=item[2] or ""
                local color=item[3] or G_ColorWhite
                local tsize=item[4] or 25
                local subTitleW=120
                local cnSubPosY = 30
                if G_getCurChoseLanguage() ~="cn" and G_getCurChoseLanguage() ~="tw" and G_getCurChoseLanguage() ~="ja" and G_getCurChoseLanguage() ~="ko" then
                    tsize = 21
                    cnSubPosY = 0
                elseif G_isIOS() == false and G_getCurChoseLanguage() =="ko" then
                    subTitleW = 140
                end
                local subTitleLb=GetTTFLabelWrap(title,tsize,CCSizeMake(subTitleW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                subTitleLb:setAnchorPoint(ccp(0,1))
                subTitleLb:setPosition(ccp(10,posY-cnSubPosY))
                subTitleLb:setColor(color)
                parent:addChild(subTitleLb)
                local rewardlist=item[1] --每一项的奖励
                local firstPosX= title =="" and 10 or subTitleLb:getPositionX()+subTitleW+10
                local firstPosY=posY
                local count=0
                local num=self.num
                for k,reward in pairs(rewardlist) do
                    local newCallback=nil
                    local icon,scale
                    if reward.type == "ac" and reward.eType ~= "c" and self.acName == "yrj" then
                        local scoreItem = acYrjVoApi:getScoreItem(80,70,reward.num)
                        local function showNewPropInfo()
                            G_showNewPropInfo(self.layerNum+1,true,true,nil,acYrjVoApi:getScoreItem(90,90,reward.num),nil,nil,nil,nil,true)
                            return false
                        end
                        icon,scale = G_universalAcGetItemIcon(scoreItem,showNewPropInfo)
                    else 
                        if self.useNewUI==true then
                            local function showNewPropInfo()
                                if reward.type == "at" and reward.eType == "a" then --AI部队
                                    local troopsVo = AITroopsVoApi:getMaxLvAITroopsVo(reward.key, true)
                                    AITroopsVoApi:showTroopsInfoDialog(troopsVo, true, self.layerNum + 1)
                                else
                                    G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
                                end
                                return false
                            end
                            newCallback=showNewPropInfo
                        end
                        if reward.type == "se" then
                            icon,scale=G_getItemIcon(reward,100,true,self.layerNum,nil,self.tv,nil,nil,nil,nil,true)
                        else
                            icon,scale=G_getItemIcon(reward,100,true,self.layerNum,newCallback,self.tv,nil,nil,nil,nil,true)
                        end
                    end
                    if icon then
                        
                        icon:setAnchorPoint(ccp(0,1))
                        icon:setPosition(firstPosX+((k-1)%num)*(propSize+self.spaceX),firstPosY-math.floor(((k-1)/num))*(propSize+self.spaceY))
                        icon:setTouchPriority(-(self.layerNum-1)*20-2)
                        icon:setIsSallow(false)
                        if self.acName == "znkh2019" then
                            icon:setScale(propSize/icon:getContentSize().height)
                        else
                            icon:setScale(propSize/icon:getContentSize().width)
                        end
                        parent:addChild(icon,1)

                        local numLb=GetTTFLabel(FormatNumber(reward.num),23)
                        numLb:setAnchorPoint(ccp(1,0))
                        numLb:setScale(1/scale)
                        numLb:setPosition(ccp(icon:getContentSize().width-5,0))
                        icon:addChild(numLb,4)
                        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                        numBg:setAnchorPoint(ccp(1,0))
                        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                        numBg:setOpacity(150)
                        icon:addChild(numBg,3)
                        count=count+1 
                    end
                end
                if count%num>0 then
                    count=math.floor(count/num)+1
                else
                    count=math.floor(count/num)
                end
                posY=posY-count*propSize-(count-1)*self.spaceY-5
                if k~=itemCount then
                    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                    lineSp:setAnchorPoint(ccp(0.5,1))
                    lineSp:setScaleX((cellWidth-40)/lineSp:getContentSize().width)
                    lineSp:setPosition(ccp(cellWidth/2,posY))
                    parent:addChild(lineSp)
                    posY=posY-10
                end
                posY=posY-5
            end
        end

        -- if self.scrollFlag==true and self.useNewUI==true then
        --     local isTvMoved=false
        --     local function eventHandler2(handler,fn,index,cel)
        --         if fn=="numberOfCellsInTableView" then     
        --             return 1
        --         elseif fn=="tableCellSizeForIndex" then
        --             local tmpSize
        --             tmpSize=CCSizeMake(itemCount*130,cellHeight-50)
        --             return  tmpSize
        --         elseif fn=="tableCellAtIndex" then
        --             local cell=CCTableViewCell:new()
        --             cell:autorelease()
        --             initRewards(cell)
        --             return cell
        --         elseif fn=="ccTouchBegan" then
        --             isTvMoved=false
        --             return true
        --         elseif fn=="ccTouchMoved" then
        --             isTvMoved=true
        --         elseif fn=="ccTouchEnded"  then
                   
        --         end
        --     end
        --     local function callback( ... )
        --         return eventHandler2(...)
        --     end
        --     local hd=LuaEventHandler:createHandler(callback)
        --     local rewardTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(cellSp:getContentSize().width-20,cellHeight-50),nil)
        --     rewardTv:setPosition(ccp(10,0))
        --     rewardTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
        --     cellSp:addChild(rewardTv,2)
        --     rewardTv:setMaxDisToBottomOrTop(120)
        -- else
            initRewards(cellSp)
        -- end
    end
    return cellSp
end

function acCjyxSmallDialog:fastTick()
    if self.isOneByOne==true and self.cellTb then
        self.tickIndex=self.tickIndex+1
        if(self.tickIndex%3==0)then
            self.cellInitIndex=self.cellInitIndex+1
            if(self.cellTb[self.cellInitIndex]) and self.cellInitIndex>1 then
                local cellSp=self:getCell(self.cellInitIndex)
                self.cellTb[self.cellInitIndex]:addChild(cellSp)
            end
        end
        if(self.cellInitIndex>=self.cellNum)then
            base:removeFromNeedRefresh(self)
        end
    end
end

function acCjyxSmallDialog:showFireworksEffectDialog() --玩家收到礼花弹奖励公告后全屏播放礼花动画
    local function playParticleBomb(plist,pos,zorder)
        local fire=CCParticleSystemQuad:create(plist)
        fire:setAutoRemoveOnFinish(true)
        if fire then
            if zorder==nil then
                zorder=1
            end
            fire.positionType=kCCPositionTypeFree
            fire:setPosition(pos)
            sceneGame:addChild(fire,zorder)
        end
        return fire
    end
    local firePosCfg={{377,G_VisibleSizeHeight-200},{165,G_VisibleSizeHeight-350},{473,G_VisibleSizeHeight-400},{G_VisibleSizeWidth/2,G_VisibleSizeHeight-400}}
    local dtimeCfg={0,0.2,0.5}
    local movetime=0.5
    for i=1,3 do
        local fire=playParticleBomb("public/YanHuo01_ShengQi.plist",ccp(G_VisibleSizeWidth/2,80),1)
        local fireArr=CCArray:create()
        local delay=CCDelayTime:create(dtimeCfg[i])
        fireArr:addObject(delay)
        local moveTo=CCMoveTo:create(movetime,ccp(firePosCfg[i][1],firePosCfg[i][2]))
        fireArr:addObject(moveTo)
        local function clearFire()
            fire:removeFromParentAndCleanup(true)
            fire=nil
            local posX=firePosCfg[i][1]
            local posY=firePosCfg[i][2]
            local bomb=playParticleBomb("public/YanHuo01.plist",ccp(posX,posY),1)
        end
        local funcCall=CCCallFuncN:create(clearFire)
        fireArr:addObject(funcCall)
        local subseq=CCSequence:create(fireArr)
        fire:runAction(subseq)
    end
end

function acCjyxSmallDialog:initSubTab(usePosy)
    if self.acName == "yrj" then
        self.AllSubTabNums, self.useSubTabNum = 2, 1
        self.subLbStrTb,self.subLbBgTb = {}, {}
        self.curSubTabLbTb = {getlocal("activity_lmqrj_smallDialogTabTitle1"),getlocal("recharge")}
    end

    local function selectSubTabCall(object,name,tag)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.useSubTabNum ~= tag - 100 and self.AllSubTabNums >= tag - 100 then
            self.useSubTabNum = tag - 100
            -- print("self.useSubTabNum======>>>>",self.useSubTabNum)
            local function calSelfSubInfo(selectShop,chooseSuTabNum)
                self:curSubTabInfo(selectShop,chooseSuTabNum)
            end

            if self.subTabBgDown and self.subLbBgTb[self.useSubTabNum] then
                self.subTabBgDown:setPositionX(self.subLbBgTb[self.useSubTabNum]:getPositionX())

                if self.useSubTabNum == 1 then
                    self.reLogBg:setVisible(false)
                    if self.tv2 then
                        self.tv2:setVisible(false)
                        self.tv2:setPositionX(G_VisibleSizeWidth * 10)
                    else
                        self.curNotRechargeLogStr:setVisible(false)
                        self.curNotRechargeLogStr:setPositionX(G_VisibleSizeWidth * 10)
                    end
                    if self.tv then
                        self.tv:setVisible(true)
                        self.tv:setPositionX(20)
                    else--curNotRewardLogStr
                        self.curNotRewardLogStr:setVisible(true)
                        self.curNotRewardLogStr:setPositionX(self.tipPosx)
                    end
                else
                    if self.tipIcon then
                        self.tipIcon:setVisible(false)
                        self.tipIcon:removeFromParentAndCleanup(true)
                        self.tipIcon = nil
                        acYrjVoApi:setRechargeTip(false)
                    end
                    if self.tv then
                        self.tv:setVisible(false)
                        self.tv:setPositionX(G_VisibleSizeWidth * 10)
                    else
                        self.curNotRewardLogStr:setVisible(false)
                        self.curNotRewardLogStr:setPositionX(G_VisibleSizeWidth * 10)
                    end
                    self.reLogBg:setVisible(true)
                    if self.tv2 then
                        self.tv2:setVisible(true)
                        self.tv2:setPositionX(20)
                    else
                        self.curNotRechargeLogStr:setVisible(true)
                        self.curNotRechargeLogStr:setPositionX(self.tipPosx) 
                    end
                end
            end
        end
    end

    for i=1,self.AllSubTabNums do
            local subTabBg = LuaCCSprite:createWithSpriteFrameName("tabBtnSp4.png",selectSubTabCall)
            subTabBg:setPosition(ccp(subTabBg:getContentSize().width*0.5 * i + 4 + (i - 1) * 4 + (i -1) * subTabBg:getContentSize().width * 0.5 + 16,subTabBg:getContentSize().height*0.5 + usePosy + 2))
            subTabBg:setTag(100 + i)
            subTabBg:setTouchPriority(-(self.layerNum-1)*20-4)
            self.subLbBgTb[i] = subTabBg
            self.bgLayer:addChild(subTabBg)
            local strSzie = 22

            local subTabStr = GetTTFLabelWrap(self.curSubTabLbTb[i],strSzie,CCSizeMake(subTabBg:getContentSize().width -4,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            subTabStr:setPosition(ccp(subTabBg:getPositionX(),subTabBg:getPositionY()))
            self.subLbStrTb[i] = subTabStr
            self.bgLayer:addChild(subTabStr,2)

            if i == 2 and acYrjVoApi:getRechargeTip( ) then
                self.tipIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",CCRect(17, 17, 1, 1),function( ) end)
                self.tipIcon:setPosition(ccp(subTabBg:getContentSize().width - 5,subTabBg:getContentSize().height - 5))
                subTabBg:addChild(self.tipIcon,6)
                self.tipIcon:setScale(0.7)
            end
    end

    if self.subTabBgDown == nil then
        self.subTabBgDown = CCSprite:createWithSpriteFrameName("tabBtnSp4_down.png")
        self.bgLayer:addChild(self.subTabBgDown,1)
        self.subTabBgDown:setPosition(ccp(self.subLbBgTb[1]:getPositionX(),self.subLbBgTb[1]:getPositionY()))--容错
    end
end
function acCjyxSmallDialog:initTv2(tvWidth2,tvHeight2,tvPosx2,tvPosy2)
    if not self.reLogBg then
        local reLogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
        reLogBg:setContentSize(CCSizeMake(tvWidth2,tvHeight2))
        reLogBg:setAnchorPoint(ccp(0,0))
        reLogBg:setPosition(ccp(20,tvPosy2))
        self.bgLayer:addChild(reLogBg,1)
        self.reLogBg = reLogBg
        self.reLogBg:setVisible(false)
    end

    if self.reLog == nil or SizeOfTable(self.reLog) == 0 then
        self.tipPosx,self.tipPosy = self.tipPosx or self.cellWidth * 0.5 + tvPosx2,self.tipPosy or tvHeight2 * 0.5 + tvPosy2
        self.curNotRechargeLogStr = GetTTFLabelWrap(getlocal("curNotRechrageLog"),26,CCSizeMake(self.cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        self.curNotRechargeLogStr:setPosition(ccp(self.tipPosx,self.tipPosy))
        self.bgLayer:addChild(self.curNotRechargeLogStr,1)
        self.curNotRechargeLogStr:setColor(G_ColorGray)
        self.curNotRechargeLogStr:setVisible(false)
    else
        self.reLogNum = SizeOfTable(self.reLog)
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return self.reLogNum
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(self.cellWidth,70)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()
                local logTb = self.reLog[idx + 1]

                local timeStr = GetTTFLabel(logTb[1],22,"Helvetica-bold")
                timeStr:setAnchorPoint(ccp(0,0.5))
                timeStr:setPosition(ccp(5,35))
                cell:addChild(timeStr,1)

                local reStr = GetTTFLabelWrap(logTb[2],22,CCSizeMake(self.cellWidth * 0.78,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                reStr:setPosition(ccp(self.cellWidth * 0.26,35))
                reStr:setAnchorPoint(ccp(0,0.5))
                cell:addChild(reStr,1)

                local bottomLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
                bottomLine:setContentSize(CCSizeMake(self.cellWidth - 10,bottomLine:getContentSize().height))
                bottomLine:setPosition(ccp(self.cellWidth * 0.5, 0))
                cell:addChild(bottomLine,1)

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
        self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth2,tvHeight2),nil)
        self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        self.tv2:setPosition(ccp(tvPosx2 + G_VisibleSizeWidth * 10,tvPosy2))
        self.bgLayer:addChild(self.tv2,2)
        self.tv2:setMaxDisToBottomOrTop(120)
    end
end
function acCjyxSmallDialog:initUpSecTitle(secTitle)
    local secTitleLb = GetTTFLabelWrap(secTitle,22,CCSizeMake(self.cellWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    secTitleLb:setAnchorPoint(ccp(0,0))
    secTitleLb:setPosition(20,self.bgSize.height - 75 - secTitleLb:getContentSize().height)
    self.bgLayer:addChild(secTitleLb)
    return secTitleLb
end

function acCjyxSmallDialog:dispose()
    self.tickIndex=0
    self.cellInitIndex=0
    self.isOneByOne=false
    self.loglist=nil
    self.cellHeightTb=nil
    self.cellTb=nil
end