ltzdzStratagemDialog=commonDialog:new()

--tid：要跳转的计策id
function ltzdzStratagemDialog:new(tid)
    local nc={
        tid=tid,
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzStratagemDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
    G_addCommonGradient(self.bgLayer,G_VisibleSize.height-80)
end

function ltzdzStratagemDialog:initTableView()
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzStratagemDialog",self)
	self.tactics=ltzdzVoApi:getWarCfg().tactics
	self.cellNum=SizeOfTable(self.tactics)
    self.warCfg=ltzdzVoApi:getWarCfg()
    self.itemBtnTb={}
    self.coolingFlag=ltzdzVoApi:isStratagemCooling()
    if otherGuideMgr:checkGuide(66)==false then
        self.guildCellTb={} --需要教学的计策item
    end
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSize.width-30,G_VisibleSize.height-220),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
    self.tv:setPosition(ccp(15,130))
    self.bgLayer:addChild(self.tv)

    local proStr=getlocal("ltzdz_study_time")
    local studyProLb=GetTTFLabelWrap(proStr,25,CCSizeMake(G_VisibleSize.width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    studyProLb:setAnchorPoint(ccp(0,0.5))
    studyProLb:setPosition(40,60)
    self.bgLayer:addChild(studyProLb)
    local tempLb=GetTTFLabel(proStr,25)
    local realW=tempLb:getContentSize().width
    if realW>studyProLb:getContentSize().width then
    	realW=studyProLb:getContentSize().width
    end
    local timeStr=GetTimeForItemStrState(0) --获取总的冷却时间
    local studyTimeLb=GetTTFLabel(timeStr,25)
    studyTimeLb:setAnchorPoint(ccp(0,0.5))
    studyTimeLb:setPosition(studyProLb:getPositionX()+realW,studyProLb:getPositionY())
    self.bgLayer:addChild(studyTimeLb)
    self.studyTimeLb=studyTimeLb
    self:refreshStudyTime()

    if otherGuideMgr:checkGuide(67)==false then
        local width=realW+studyTimeLb:getContentSize().width+20
        local height=studyProLb:getContentSize().height+10
        local x,y=(studyProLb:getPositionX()+width*0.5-10),studyProLb:getPositionY()
        otherGuideCfg[67].otherRectTb={{x,y,width,height}}
        self.tid=nil --如果有教学出现，则跳转效果清除
    end

    --重置冷却时间
    local function resetHandler()
        local clearFlag=ltzdzVoApi:isClearCooling()
        if clearFlag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_clearTime"),30)
            do return end
        end
        local cost=ltzdzVoApi:getResetCoolingTimeCost()
        local flag,own,lack=ltzdzFightApi:isGemsEnough(cost)
        if flag==false then --金币不足
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30)
            do return end
        end
        local function realReset()
            local function resetCallBack()
               self:refresh()
            end
            ltzdzFightApi:buyOrUsePropsRequest(3,nil,nil,resetCallBack)
        end
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("ltzdz_resettime"),getlocal("ltzdz_resettime_prompt",{cost}),false,realReset)
    end
    local priority=-(self.layerNum-1)*20-4
    local resetItem=G_createBotton(self.bgLayer,ccp(G_VisibleSize.width-100,60),{getlocal("dailyTaskReset")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",resetHandler,0.8,priority)

    otherGuideMgr:setGuideStepField(68,nil,true,{resetItem,1})

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function () end)
    mLine:setPosition(ccp(G_VisibleSize.width/2,120))
    mLine:setContentSize(CCSizeMake(G_VisibleSize.width,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    if otherGuideMgr:checkGuide(66)==false and ltzdzVoApi:isQualifying()==true then --计策面板教学开始
        local otherRectTb={}
        local cellWidth,cellHeight=G_VisibleSize.width-30,120
        for k,v in pairs(self.guildCellTb) do
            local x,y,width,height=G_getSpriteWorldPosAndSize(v)
            table.insert(otherRectTb,{x+cellWidth*0.5,G_VisibleSize.height+y+cellHeight*0.5,cellWidth,cellHeight})
        end
        otherGuideCfg[66].otherRectTb=otherRectTb
        otherGuideMgr:showGuide(66)
        self.guildCellTb=nil
    end
end

function ltzdzStratagemDialog:eventHandler(handler,fn,idx,cel)
   	if fn=="numberOfCellsInTableView" then
   		return self.cellNum
   	elseif fn=="tableCellSizeForIndex" then
       	local tmpSize=CCSizeMake(G_VisibleSize.width-30,130)
       	return tmpSize
   	elseif fn=="tableCellAtIndex" then
   	    local cell=CCTableViewCell:new()
        cell:autorelease()

        local nameFontSize,descFontSize=20,18
        local cellWidth=G_VisibleSize.width-30
        local cellHeight=120
        local function nilFunc()
        end
        local itemBg=G_getThreePointBg(CCSizeMake(cellWidth,cellHeight),nilFunc,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)
        if self.guildCellTb and idx<=1 then
            table.insert(self.guildCellTb,cell)
        end
        local stratagemId="t"..(idx+1)
		local stratagemCfg=self.tactics[stratagemId]
        local nameStr,descStr,iconPic=ltzdzVoApi:getStratagemInfoById(stratagemId)
        local function touchHandler()
        end
        local iconSp=LuaCCSprite:createWithSpriteFrameName(iconPic,touchHandler)
        iconSp:setAnchorPoint(ccp(0,0.5))
        iconSp:setPosition(ccp(15,itemBg:getContentSize().height/2))
        itemBg:addChild(iconSp)
        local iconWidth=iconSp:getContentSize().width*iconSp:getScaleX()
        local iconHeight=iconSp:getContentSize().height*iconSp:getScaleY()

        local nameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(cellWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(15+iconWidth+10,cellHeight-nameLb:getContentSize().height/2-10)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorYellowPro)
        itemBg:addChild(nameLb)
                
        local descLb=GetTTFLabelWrap(descStr,descFontSize,CCSizeMake(cellWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setPosition(15+iconWidth+10,nameLb:getPositionY()-nameLb:getContentSize().height/2-20)
        descLb:setAnchorPoint(ccp(0,1))
        itemBg:addChild(descLb)

        local function exchangeHandler()
            if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                local function buyCallBack()
                    self:refresh()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_buy_propmtStr",{1,nameStr}),30)
                end
                ltzdzFightApi:buyOrUsePropsRequest(1,stratagemId,false,buyCallBack)
			end
        end
        local priority=-(self.layerNum-1)*20-2
        local exchangeBtn=G_createBotton(itemBg,ccp(cellWidth-80,cellHeight/2-20),{getlocal("code_gift"),23},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",exchangeHandler,0.7,priority)
        self.itemBtnTb[idx+1]=exchangeBtn
        if self.coolingFlag==true then
            exchangeBtn:setEnabled(false)
        end

        local tmIcon=CCSprite:createWithSpriteFrameName("IconTime.png")
        tmIcon:setAnchorPoint(ccp(0,0.5))
        itemBg:addChild(tmIcon)
        local timeLb=GetTTFLabel(GetTimeForItemStrState(stratagemCfg.timeCost),descFontSize)
        timeLb:setAnchorPoint(ccp(0,0.5))
        itemBg:addChild(timeLb)
        local timeWidth=tmIcon:getContentSize().width+timeLb:getContentSize().width
        tmIcon:setPosition(cellWidth-80-timeWidth/2,cellHeight/2+23)
        timeLb:setPosition(tmIcon:getPositionX()+tmIcon:getContentSize().width,tmIcon:getPositionY())

        if self.tid and self.tid==stratagemId then
            local highLightSp=LuaCCScale9Sprite:createWithSpriteFrameName("guideHighLight.png",CCRect(11,11,1,1),function ()end)
            highLightSp:setPosition(cellWidth/2,cellHeight/2)
            highLightSp:setContentSize(itemBg:getContentSize())
            cell:addChild(highLightSp,2)

            --淡入淡出效果
            local fadeIn=CCFadeIn:create(0.8)
            local fadeOut=CCFadeOut:create(0.8)
            local seq=CCSequence:createWithTwoActions(fadeIn,fadeOut)
            local repeatAc=CCRepeatForever:create(seq)
            highLightSp:runAction(repeatAc)
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

function ltzdzStratagemDialog:tick()
    self:refreshStudyTime()
end

function ltzdzStratagemDialog:refresh()
    if self.tv then
        local recordPoint=self.tv:getRecordPoint() 
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    self:refreshStudyTime()
end

function ltzdzStratagemDialog:refreshStudyTime()
    local flag,lefttime=ltzdzVoApi:isStratagemCooling()
    if self.studyTimeLb then
        if lefttime>=0 then
            local timeStr=GetTimeForItemStrState(lefttime)
            self.studyTimeLb:setString(timeStr)
        end
    end
    if flag~=self.coolingFlag and self.itemBtnTb then
        for k,exchangeBtn in pairs(self.itemBtnTb) do
            exchangeBtn=tolua.cast(exchangeBtn,"CCMenuItemSprite")
            if exchangeBtn then
                exchangeBtn:setEnabled(self.coolingFlag)
            end
        end
        self.coolingFlag=flag
    end
end

function ltzdzStratagemDialog:dispose()
	self.studyTimeLb=nil
    self.itemBtnTb=nil
    self.guildCellTb=nil
    self.tid=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzStratagemDialog",self)
end