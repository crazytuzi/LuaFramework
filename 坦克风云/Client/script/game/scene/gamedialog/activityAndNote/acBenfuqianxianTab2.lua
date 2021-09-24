acBenfuqianxianTab2={}

function acBenfuqianxianTab2:new()
    local nc={}
    nc.taskList={}
    nc.numberCell=0
    nc.integralBg=nil
    nc.integralIcon=nil
    nc.integralLb=nil
    nc.cellWidth=0
    nc.cellHeight=200

    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acBenfuqianxianTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.taskList=acBenfuqianxianVoApi:getTasks()
    self.numberCell=SizeOfTable(self.taskList)
    self.cellWidth=G_VisibleSizeWidth-40
    self.cellHeight=200

    self:initTableView()
    self:doUserHandler()

    -- self:refresh()

    return self.bgLayer
end

function acBenfuqianxianTab2:initTableView()
    local w=G_VisibleSizeWidth-20 -- 背景框的宽度
    local function nilFunc()
    end
    local lineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(168, 86, 10, 10),nilFunc)
    lineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-66))
    lineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-180))
    self.bgLayer:addChild(lineBg)

    local integralBg=LuaCCScale9Sprite:createWithSpriteFrameName("acRadar_integralBg.png",CCRect(75,35,50,30),nilFunc)
    integralBg:setAnchorPoint(ccp(0.5,1))
    integralBg:setContentSize(CCSizeMake(G_VisibleSize.width-300,80))
    integralBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-180))
    self.bgLayer:addChild(integralBg,1)
    local integralIcon=CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
    integralIcon:setAnchorPoint(ccp(0,0.5))
    integralBg:addChild(integralIcon)
    local integralLb=GetTTFLabel(acBenfuqianxianVoApi:getIntegralCount(),25)
    integralLb:setAnchorPoint(ccp(0,0.5))
    integralBg:addChild(integralLb)
    local cwidth=integralIcon:getContentSize().width+integralLb:getContentSize().width
    integralIcon:setPosition(ccp((integralBg:getContentSize().width-cwidth)/2,integralBg:getContentSize().height/2+12))
    integralLb:setPosition(ccp(integralIcon:getPositionX()+integralIcon:getContentSize().width,integralBg:getContentSize().height/2+12))
    self.integralBg=integralBg
    self.integralIcon=integralIcon
    self.integralLb=integralLb
    local fadeLineSp=CCSprite:createWithSpriteFrameName("acNewYearFadeLight.png")
    fadeLineSp:setScaleY(0.5)
    fadeLineSp:setPosition(ccp(G_VisibleSize.width/2,integralBg:getPositionY()-integralBg:getContentSize().height/2))
    self.bgLayer:addChild(fadeLineSp)

	local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-280),nil)
 	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,30))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acBenfuqianxianTab2:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.numberCell
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.cellWidth,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

        local task=self.taskList[idx+1]
        local desc,exchangeStr,titleStr,iconStr,hasBg,btnName=acBenfuqianxianVoApi:getTaskContent(task)
        if desc and exchangeStr and iconStr and titleStr then
            local cellWidth=self.cellWidth
            local cellHeight=self.cellHeight
            local fontSize=21
            local strSize2 = 18
            local needPosH = 5
             if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
                fontSize =fontSize+3
                strSize2 = strSize2+3
                needPosH = 0
            end
            local capInSet=CCRect(20, 20, 20, 20)
            local function cellClick(hd,fn,idx)
            end
            local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("acChunjiepansheng_orangeBg.png",capInSet,cellClick)
            backSprie:setContentSize(CCSizeMake(cellWidth-20,cellHeight-40))
            backSprie:ignoreAnchorPointForPosition(false)
            backSprie:setAnchorPoint(ccp(0.5,0))
            backSprie:setIsSallow(false)
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setPosition(ccp(cellWidth/2,0))
            cell:addChild(backSprie,1)

            local titleSp=CCSprite:createWithSpriteFrameName("orangeMask.png")
            titleSp:setAnchorPoint(ccp(0.5,0))
            titleSp:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height))
            backSprie:addChild(titleSp)
            local titleLb = GetTTFLabel(titleStr,30)
            titleLb:setPosition(ccp(titleSp:getContentSize().width/2,titleSp:getContentSize().height/2))
            titleSp:addChild(titleLb)

            if hasBg==false then
                local iconBg=CCSprite:createWithSpriteFrameName("Icon_BG.png")
                iconBg:setAnchorPoint(ccp(0,0.5))
                iconBg:setPosition(ccp(10,backSprie:getContentSize().height/2))
                iconBg:setScale(100/iconBg:getContentSize().width)
                backSprie:addChild(iconBg)

                local taskIconSp=CCSprite:createWithSpriteFrameName(iconStr)
                taskIconSp:setPosition(ccp(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2))
                taskIconSp:setScale(0.7/iconBg:getScale())
                iconBg:addChild(taskIconSp)
            else
                local taskIconSp=CCSprite:createWithSpriteFrameName(iconStr)
                taskIconSp:setAnchorPoint(ccp(0,0.5))
                taskIconSp:setPosition(ccp(10,backSprie:getContentSize().height/2))
                backSprie:addChild(taskIconSp)
            end
            local colorTab={nil,G_ColorYellowPro,nil}
            local descLb,lbHeight=G_getRichTextLabel(desc,colorTab,fontSize,cellWidth-300,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
            descLb:setAnchorPoint(ccp(0,1))
            backSprie:addChild(descLb)
            descLb:setPosition(110,backSprie:getContentSize().height/2+45+needPosH)
        
            local exchangeLb=GetTTFLabelWrap(exchangeStr,strSize2,CCSizeMake(cellWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            exchangeLb:setAnchorPoint(ccp(0,1))
            exchangeLb:setPosition(110,backSprie:getContentSize().height/2-45+exchangeLb:getContentSize().height-needPosH)
            exchangeLb:setColor(G_ColorYellow)
            backSprie:addChild(exchangeLb)

            local function goHandler()
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
                    end
                    PlayEffect(audioCfg.mouseClick)
                    self:goTaskDialog(task.tid)
                end
            end
            local btnPicName="BtnOkSmall.png"
            local btnDownPicName="BtnOkSmall_Down.png"
            if btnName=="recharge" then
                btnPicName="BtnCancleSmall.png"
                btnDownPicName="BtnCancleSmall_Down.png"
            end
            local goItem=GetButtonItem(btnPicName,btnDownPicName,btnDownPicName,goHandler,nil,getlocal(btnName),28)
            local goBtn=CCMenu:createWithItem(goItem)
            goBtn:setTouchPriority(-(self.layerNum-1)*20-2)
            goItem:setScale(0.8)
            goBtn:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2-20))
            backSprie:addChild(goBtn)

            local pointSp = CCSprite:createWithSpriteFrameName("acRadar_integralIcon.png")
            pointSp:setAnchorPoint(ccp(0,0))
            pointSp:setScale(0.6)
            pointSp:setPosition(ccp(backSprie:getContentSize().width-180,backSprie:getContentSize().height/2-10+goItem:getContentSize().height*goItem:getScaleY()/2))
            backSprie:addChild(pointSp,6)

            local numLb = GetTTFLabel(task.curPoint.."/"..task.maxPoint,22)
            numLb:setAnchorPoint(ccp(0,0))
            numLb:setPosition(ccp(pointSp:getPositionX()+pointSp:getContentSize().width*pointSp:getScaleX(),pointSp:getPositionY()))
            numLb:setColor(G_ColorYellowPro)
            backSprie:addChild(numLb)
            if task.cur>=task.max then
                local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),function ( ... )end)
                lbBg:setContentSize(CCSizeMake(backSprie:getContentSize().width+20,backSprie:getContentSize().height))
                lbBg:setAnchorPoint(ccp(0.5,0))
                lbBg:setPosition(ccp(cellWidth/2,0))
                lbBg:setOpacity(150)
                cell:addChild(lbBg,3)
                local rightIcon=CCSprite:createWithSpriteFrameName("IconCheck.png")
                rightIcon:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2-20))
                lbBg:addChild(rightIcon,1)
                goBtn:setVisible(false)
            end
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

function acBenfuqianxianTab2:goTaskDialog(tid)
    if tid then
        tid=tostring(tid)
        if tostring(tid)=="t1" or tostring(tid)=="t2" or tostring(tid)=="t3" or tostring(tid)=="t4" then
            G_goToDialog("pp",self.layerNum+1,true)
        elseif tostring(tid)=="t5" then
            vipVoApi:showRechargeDialog(self.layerNum+1)
        end
    end
end
function acBenfuqianxianTab2:doUserHandler()

end

function acBenfuqianxianTab2:updateUI()
    if self then
        self:refresh()
        if self.tv then
            self.taskList=acBenfuqianxianVoApi:getTasks()
            self.tv:reloadData()
        end
    end
end

function acBenfuqianxianTab2:refresh()
    if self and self.integralBg and self.integralIcon and self.integralLb then
        self.integralLb:setString(acBenfuqianxianVoApi:getIntegralCount())
        local cwidth=self.integralIcon:getContentSize().width+self.integralLb:getContentSize().width
        self.integralIcon:setPosition(ccp((self.integralBg:getContentSize().width-cwidth)/2,self.integralBg:getContentSize().height/2+12))
        self.integralLb:setPosition(ccp(self.integralIcon:getPositionX()+self.integralIcon:getContentSize().width,self.integralBg:getContentSize().height/2+12))
    end
end

function acBenfuqianxianTab2:tick()
    local isEnd=acBenfuqianxianVoApi:isEnd()
    if isEnd==false then
        if acBenfuqianxianVoApi:getFlag(2)==0 then
            self:updateUI()
            acBenfuqianxianVoApi:setFlag(2,1)
        end
    end
end

function acBenfuqianxianTab2:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.layerNum=nil
    self.taskList={}
    self.numberCell=0
    self.integralBg=nil
    self.integralIcon=nil
    self.integralLb=nil
    self.cellWidth=0
    self.cellHeight=200
end