acYswjSmallDialog=smallDialog:new()

function acYswjSmallDialog:new()
	local nc={
        cellHeightTb={},
    }
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- 新奖励提示（不再是简单的飘字）
function acYswjSmallDialog:showYswjRewardDialog(bgSrc,size,inRect,title,content,layerNum,isuseami,isTouch,isOneByOne,isUseNewUi,desc,specialFlag)
	local sd=acYswjSmallDialog:new()
    sd:initYswjRewardDialog(bgSrc,size,inRect,title,content,layerNum,isuseami,isTouch,isOneByOne,isUseNewUi,desc,specialFlag)
end

-- isXiushi:是否有顶部的修饰
function acYswjSmallDialog:initYswjRewardDialog(bgSrc,size,inRect,title,content,layerNum,isuseami,isTouch,isOneByOne,isUseNewUi,desc,specialFlag)
	self.isTouch=isTouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.content=content
    self.isOneByOne=isOneByOne or false
    self.isUseNewUi=isUseNewUi or false
    self.specialFlag = specialFlag

    local rlayer=CCNode:create()
    rlayer:setContentSize(CCSizeMake(size.width,1))
    rlayer:setAnchorPoint(ccp(0.5,1))

    local bgHeight=30
    if self.isUseNewUi==true then
        bgHeight=70
    end
    local cellWidth=size.width-30
    local cellHeightTb={}
    local tvHeight=G_VisibleSizeHeight-400
    local posY=0
    if title and self.isUseNewUi==false then
        local titleStr=title[1]
        local color=title[2] or G_ColorWhite
        local tsize=title[3] or 28
        if titleStr then
            local titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
            titleLb:setAnchorPoint(ccp(0.5,1))
            titleLb:setPosition(ccp(size.width/2,posY))
            titleLb:setColor(color)
            rlayer:addChild(titleLb)
            posY=posY-titleLb:getContentSize().height
            local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSp:setAnchorPoint(ccp(0.5,1))
            lineSp:setScaleX((size.width-60)/lineSp:getContentSize().width)
            lineSp:setScaleY(1.2)
            lineSp:setPosition(ccp(size.width/2,posY))
            rlayer:addChild(lineSp,2)
            bgHeight=bgHeight+titleLb:getContentSize().height+20
            posY=posY-20
        end
    end
    local rc=4 --每一行显示的奖励个数
    -- local titleW=160 --主标题的宽度
    local titleW=200
    if self.specialFlag == "xlys" then
        titleW = size.width - 20
    end
    local subTitleW=cellWidth-20 --副标题显示的宽度
    local iconSize=100 --奖励图标的大小
    local spaceY=10
    self.rc=rc
    self.titleW=titleW
    self.subTitleW=subTitleW
    self.spaceY=spaceY
    self.iconSize=iconSize
    self.cellWidth=cellWidth
    local totalCellH=0
    for k,v in pairs(content) do
        totalCellH=totalCellH+self:getCellHeight(k)
    end
    local scrollFlag=true
    if tvHeight>totalCellH then
        tvHeight=totalCellH
        scrollFlag=false
    end
    bgHeight=bgHeight+tvHeight
    bgHeight=bgHeight+120
    local descHeight=0
    if desc then
        local descStr=desc[1] or ""
        -- local descColor=desc[2] or G_ColorWhite
        local descSize=desc[3] or 24
        local descLabel=GetTTFLabelWrap(descStr,descSize,CCSizeMake(size.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        descHeight=descLabel:getContentSize().height
        bgHeight=bgHeight+descHeight+20
    end
    size=CCSizeMake(size.width,bgHeight)

    local function touchHandler()
    
    end
    local dialogBg
    if self.isUseNewUi==true then
        local titleStr,titleSize,titleColor="",28,G_ColorWhite
        if title then
            titleStr=title[1]
            titleColor=title[2] or G_ColorWhite
            titleSize=title[3] or 28
        end
        local function closeCallback( ... )
            self:close()
        end
        dialogBg=G_getNewDialogBg(size,titleStr,titleSize,nil,self.layerNum,true,closeCallback,titleColor)
    else
        dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    end
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self.bgLayer:addChild(rlayer)
    self:show()

    self.bgLayer:setContentSize(size)
    rlayer:setPosition(size.width/2,bgHeight-30)

    local isMoved=false
    local cellNum=SizeOfTable(content)
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,self:getCellHeight(idx+1))
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local item=content[idx+1]
            local cellHeight=self:getCellHeight(idx+1)
            if isOneByOne and isOneByOne==true then
                self.cellTb[idx+1]=cell
                if idx==0 then
                    self:createCell(cell,item,idx+1)
                end
            else
                self:createCell(cell,item,idx+1)
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
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,120))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth*0.43,120))
    mLine:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-10,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    if desc then
        self.tv:setPositionY(self.tv:getPositionY()+descHeight+10)
        mLine:setPositionY(mLine:getPositionY()+descHeight+10)
        local descStr=desc[1] or ""
        local descColor=desc[2] or G_ColorWhite
        local descSize=desc[3] or 24
        local descLabel=GetTTFLabelWrap(descStr,descSize,CCSizeMake(self.bgSize.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        descLabel:setAnchorPoint(ccp(0.5,1))
        descLabel:setPosition(self.bgSize.width/2,mLine:getPositionY()-10)
        descLabel:setColor(descColor)
        self.bgLayer:addChild(descLabel)
    end

    if self.tv then
        self.refreshData.tableView=self.tv
    end

    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end

    local sureItem
    if self.isUseNewUi==true then
        sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,getlocal("ok"),25/0.8)
        sureItem:setScale(0.8)
    else
        sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",sureHandler,2,getlocal("ok"),25)
    end
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(size.width/2,70))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(sureMenu)

    local function touchDialog()
    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    self:addForbidSp(self.bgLayer,size,self.layerNum,nil,nil,true)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function acYswjSmallDialog:fastTick()
    if self.isOneByOne==true and self.cellTb and self.content then
        self.tickIndex=self.tickIndex+1
        if(self.tickIndex%3==0)then
            self.cellInitIndex=self.cellInitIndex+1
            if(self.cellTb[self.cellInitIndex]) and self.cellInitIndex>1 then
                local cell=self.cellTb[self.cellInitIndex]
                local item=self.content[self.cellInitIndex]
                self:createCell(cell,item,self.cellInitIndex)
            end
        end
        if(self.cellInitIndex>=self.cellNum)then
            base:removeFromNeedRefresh(self)
        end
    end
end

function acYswjSmallDialog:getCellHeight(idx)
    local height=0
    if self.content then
        local rc=self.rc
        if self.cellHeightTb[idx]==nil then
            local item=self.content[idx]
            if item then
                height=height+48
                local title=item.subTitle
                if title then
                    local titleStr=title[1]
                    local tsize=title[3] or 23
                    local titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(self.subTitleW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    height=height+titleLb:getContentSize().height+15
                end
                local rewardlist=item.rewardlist
                local count=SizeOfTable(rewardlist)
                if count%rc>0 then
                    count=math.floor(count/rc)+1
                else
                    count=math.floor(count/rc)
                end
                height=height+count*self.iconSize+(count-1)*self.spaceY
                height=height+20
            end
            self.cellHeightTb[idx]=height+10
        else
            height=self.cellHeightTb[idx]
        end
    end
    return height
end

function acYswjSmallDialog:createCell(cell,item,idx)
    local titleAddPosY = 0

    if item then
        local cellWidth=self.cellWidth
        local cellHeight=self:getCellHeight(idx)
        local iconSize=self.iconSize
        local posY=cellHeight
        local title=item.title
        local titleStr=title[1]
        local color=title[2] or G_ColorWhite
        local tsize=title[3] or 23

        local tabItemSp,tvBg

        local jjLb = GetTTFLabel(titleStr,tsize)
        if jjLb:getContentSize().width > self.titleW then
            titleAddPosY = 10
        end
        if self.specialFlag and self.specialFlag == "xlys" then
            titleAddPosY = titleAddPosY + 10
        end

        local lb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(self.titleW,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setColor(color)
        local lb2=GetTTFLabel(titleStr,tsize)
        local lbW=lb2:getContentSize().width
        if lbW>lb:getContentSize().width then
            lbW=lb:getContentSize().width
        end
        if self.isUseNewUi==true then
            tabItemSp=CCNode:create()
            tabItemSp:setContentSize(CCSizeMake(self.cellWidth,48))
            if not self.specialFlag or self.specialFlag~="xlys" then
                for i=1,2 do
                    local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
                    local anchorX=1
                    local posX=self.cellWidth/2-(lbW/2+20)
                    local pointX=-7
                    if i==2 then
                        anchorX=0
                        posX=self.cellWidth/2+(lbW/2+20)
                        pointX=15
                    end
                    pointSp:setAnchorPoint(ccp(anchorX,0.5))
                    pointSp:setPosition(posX,tabItemSp:getContentSize().height/2-10)
                    tabItemSp:addChild(pointSp)

                    local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
                    pointLineSp:setAnchorPoint(ccp(0,0.5))
                    pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
                    pointSp:addChild(pointLineSp)
                    if i==1 then
                        pointLineSp:setRotation(180)
                    end
                end
                local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
                lightSp:setAnchorPoint(ccp(0.5,0))
                lightSp:setScaleX(2)
                lightSp:setPosition(tabItemSp:getContentSize().width/2,-2)
                tabItemSp:addChild(lightSp)
            end
            tvBg=G_createItemKuang(CCSizeMake(cellWidth,cellHeight-58))
            lb:setPosition(tabItemSp:getContentSize().width/2,tabItemSp:getContentSize().height/2-10+titleAddPosY)
        else
            tabItemSp=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
            tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
            lb:setPosition(getCenterPoint(tabItemSp))
        end
        tabItemSp:addChild(lb)
        tabItemSp:setAnchorPoint(ccp(0,1))
        tabItemSp:setPosition(ccp(10,posY))
        cell:addChild(tabItemSp,1)
        posY=posY-48

        tvBg:setTouchPriority(-(self.layerNum-1)*20-1)
        tvBg:setContentSize(CCSizeMake(cellWidth,cellHeight-58))
        tvBg:ignoreAnchorPointForPosition(false)
        tvBg:setAnchorPoint(ccp(0,1))
        tvBg:setPosition(ccp(0,posY))
        cell:addChild(tvBg,1)
        local bgH=tvBg:getContentSize().height
        posY=bgH-10
        title=item.subTitle
        if title then
            titleStr=title[1]
            color=title[2] or G_ColorWhite
            tsize=title[3] or 23
            local descLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(self.subTitleW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(10,posY))
            tvBg:addChild(descLb,1)
            posY=posY-descLb:getContentSize().height-2

            local lineSp
            if self.isUseNewUi==true then
                lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
                lineSp:setContentSize(CCSizeMake(cellWidth-60,lineSp:getContentSize().height))
            else
                lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp:setScaleX((cellWidth-60)/lineSp:getContentSize().width)
            end
            lineSp:setAnchorPoint(ccp(0.5,1))
            lineSp:setPosition(ccp(cellWidth/2,posY))
            tvBg:addChild(lineSp,2)
            posY=posY-13
        end
        local rc=self.rc
        local spaceY=self.spaceY
        local spaceX=20
        local firstPosX=(cellWidth-rc*iconSize-(rc-1)*spaceX)/2
        for k,reward in pairs(item.rewardlist) do
            local icon,scale
            local function showNewPropDialog()
                G_showNewPropInfo(self.layerNum+1,true,true,nil,reward,nil,nil,nil,nil,true)
            end
            if self.isUseNewUi==true then
                if reward.type == "se" then
                    icon,scale=G_getItemIcon(reward,iconSize,true,self.layerNum,nil,self.tv,nil,nil,nil,nil,true)
                else
                    icon,scale=G_getItemIcon(reward,iconSize,false,self.layerNum,showNewPropDialog,self.tv)
                end
            else
                icon,scale=G_getItemIcon(reward,iconSize,true,self.layerNum,nil,self.tv)
            end
            if icon then
                icon:setAnchorPoint(ccp(0,1))
                if #item.rewardlist == 1 then
                    icon:setPosition(tvBg:getContentSize().width/2-iconSize/2,posY-math.floor(((k-1)/rc))*(iconSize+spaceY))
                else
                    icon:setPosition(firstPosX+((k-1)%rc)*(iconSize+spaceX),posY-math.floor(((k-1)/rc))*(iconSize+spaceY))
                end
                icon:setTouchPriority(-(self.layerNum-1)*20-2)
                icon:setIsSallow(false)
                tvBg:addChild(icon,1)
                if reward.type == "h" then
                    icon:setScale(0.6)
                end
                local numLb=GetTTFLabel("x"..FormatNumber(reward.num),23)
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
            end
        end
    end
end