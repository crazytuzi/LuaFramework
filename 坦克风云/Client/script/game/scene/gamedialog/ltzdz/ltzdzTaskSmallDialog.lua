ltzdzTaskSmallDialog=smallDialog:new()

function ltzdzTaskSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    local function addPlist()
        spriteController:addPlist("public/youhuaUI3.plist")
        spriteController:addTexture("public/youhuaUI3.png")
    end
    G_addResource8888(addPlist)
	return nc
end

--任务显示面板
function ltzdzTaskSmallDialog:showTaskSmallDialog(layerNum,isuseami,istouch,callback)
    local function refreshTask(event,data)
        -- self:refresh()
    end
    self.refreshListener=refreshTask
    eventDispatcher:addEventListener("ltzdz.updateTask",refreshTask)

  	local sd=ltzdzTaskSmallDialog:new()
	sd:initTaskSmallDialog(layerNum,isuseami,callback)
end

function ltzdzTaskSmallDialog:initTaskSmallDialog(layerNum,isuseami,istouch,callback)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzTaskSmallDialog",self)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local taskList=ltzdzFightApi:getTaskList()
    local trueTaskTb=ltzdzFightApi:getSortTask(1,taskList[1])
    local cellNum=SizeOfTable(trueTaskTb)
    self.tabTb={}

    local size=CCSizeMake(562,580)
    self.bgSize=size
    local dialogBg=G_getNewDialogBg2(size,self.layerNum,nil,getlocal("ltzdz_task_title"),28,G_ColorWhite)

    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self:show()

  	self.bgLayer:setPosition(self.dialogLayer:getContentSize().width/2,self.dialogLayer:getContentSize().height/2+30)
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)

    local tvWidth=518
    local tvHeight=400
    local cellWidth,cellHeight=tvWidth,100

    local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("btnPanelBg.png",CCRect(95,70,2,2),function () end)
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight+50))
    tvBg:ignoreAnchorPointForPosition(false)
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-35))
    self.bgLayer:addChild(tvBg)

    local selectedTabIndex,oldSelectedTabIndex=0,0
    local function tabClick(idx)
        oldSelectedTabIndex=selectedTabIndex    
        for k,v in pairs(self.tabTb) do
            if v:getTag()==idx then
                v:setEnabled(false)
                selectedTabIndex=idx
                local btnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
            else
                v:setEnabled(true)
                local btnLabel=tolua.cast(v:getChildByTag(31),"CCLabelTTF")
            end
        end
        if oldSelectedTabIndex~=selectedTabIndex then
            trueTaskTb=ltzdzFightApi:getSortTask(idx,taskList[idx])
            cellNum=SizeOfTable(trueTaskTb)
            if self.tv then
                self.tv:reloadData()
            end
        end
    end

    local priority=-(self.layerNum-1)*20-8
    local tbArr={getlocal("plat_war_notice_command"),getlocal("resource"),getlocal("ltzdz_killStr1"),getlocal("alienMines_Occupied")}
    local tabBtn=CCMenu:create()
    tabBtn:setTouchPriority(priority)
    for k,v in pairs(tbArr) do
        local tabItem=CCMenuItemImage:create("smallTabBtn.png", "smallTabBtn_Selected.png","smallTabBtn_Selected.png")
        tabItem:setAnchorPoint(CCPointMake(0.5,0.5))
        local tabWidth=tabItem:getContentSize().width
        local pos=ccp(3+tabWidth*0.5+(k-1)*(tabWidth),tvBg:getContentSize().height-23)
        tabItem:setPosition(pos)
        tabItem:registerScriptTapHandler(tabClick)
        local lb=GetTTFLabelWrap(v,24,CCSizeMake(tabItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(CCPointMake(tabItem:getContentSize().width/2,tabItem:getContentSize().height/2))
        lb:setTag(31)
        tabItem:addChild(lb)
        tabBtn:addChild(tabItem)
        tabItem:setTag(k)
        self.tabTb[k]=tabItem
    end
    tabBtn:setPosition(0,0)
    tvBg:addChild(tabBtn)
    tabClick(1)

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(size.width/2,30))
    mLine:setContentSize(CCSizeMake(size.width-10,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)

    local noticeLb=GetTTFLabelWrap(getlocal("ltzdz_task_promptStr2"),18,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeLb:setPosition(ccp(size.width/2,30+noticeLb:getContentSize().height/2))
    noticeLb:setColor(G_ColorRed)
    self.bgLayer:addChild(noticeLb)
    local noticeLb2=GetTTFLabelWrap(getlocal("ltzdz_task_promptStr"),18,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeLb2:setPosition(ccp(size.width/2,noticeLb:getPositionY()+noticeLb:getContentSize().height/2+noticeLb2:getContentSize().height/2))
    noticeLb2:setColor(G_ColorRed)
    self.bgLayer:addChild(noticeLb2)


    base:addNeedRefresh(self)
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

            local task=trueTaskTb[idx+1]
            local tid=task.id
			local taskCfg=ltzdzVoApi:getWarCfg().task
            local state=task.state    
            if tid and taskCfg[tid] then
            	local cfg=taskCfg[tid]
                local descStr=ltzdzFightApi:getTaskInfoById(tid)
                local stateStr,stateColor="",G_ColorWhite
                local colorTab,color={G_ColorWhite,G_ColorYellowPro,G_ColorWhite},G_ColorWhite
                if state==1 then --已领取
                    stateStr=getlocal("ltzdz_hasget")
                    stateColor=G_ColorGray
                    colorTab={G_ColorGray,G_ColorGray,G_ColorGray}
                    color=G_ColorGray
                elseif state==2 then --已完成
                    stateStr=getlocal("activity_wanshengjiedazuozhan_complete")
                    stateColor=G_ColorYellowPro
                else --未完成
                    stateStr=getlocal("local_war_incomplete")
                end           
                local descLb,lbHeight=G_getRichTextLabel(descStr,colorTab,20,cellWidth-150,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                descLb:setAnchorPoint(ccp(0,0.5))
                descLb:setPosition(20,cellHeight-lbHeight/2-10)
                cell:addChild(descLb)

            	local rewardLb=GetTTFLabel(getlocal("donateReward"),18)
            	rewardLb:setAnchorPoint(ccp(0,0.5))
            	rewardLb:setPosition(20,rewardLb:getContentSize().height/2+15)
                rewardLb:setColor(color)
            	cell:addChild(rewardLb)

                local pointSp=CCSprite:createWithSpriteFrameName("ltzdzPointIcon.png")
                pointSp:setAnchorPoint(ccp(0,0.5))
                local scale=32/pointSp:getContentSize().width
                pointSp:setScale(scale)
                pointSp:setPosition(rewardLb:getPositionX()+rewardLb:getContentSize().width,rewardLb:getPositionY())
                cell:addChild(pointSp)

                local pointLb=GetTTFLabel(getlocal("ltzdz_feat").."+"..cfg.point,18)
                pointLb:setAnchorPoint(ccp(0,0.5))
                if state==1 then
                    pointLb:setColor(G_ColorGray)
                else
                    pointLb:setColor(G_ColorGreen)
                end
                pointLb:setPosition(pointSp:getPositionX()+pointSp:getContentSize().width*scale,rewardLb:getPositionY())
                cell:addChild(pointLb)

            	local priority=-(self.layerNum-1)*20-3
                local stateLb=GetTTFLabelWrap(stateStr,20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                stateLb:setPosition(cellWidth-stateLb:getContentSize().width/2,stateLb:getContentSize().height/2+15)
                stateLb:setColor(stateColor)
                cell:addChild(stateLb)

                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function ()end)
                lineSp:setContentSize(CCSizeMake((cellWidth-4),2))
                lineSp:setRotation(180)
                lineSp:setPosition(cellWidth/2,0)
                cell:addChild(lineSp)
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
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(0,0))
    tvBg:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
    
    local function touchLuaSpr()
         
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255*0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

    G_addArrowPrompt(self.bgLayer,nil,-60)

    local function close()
    	self:close()
    end
    G_addForbidForSmallDialog(self.dialogLayer,self.bgLayer,-(self.layerNum-1)*20-4,close)
end

-- function ltzdzTaskSmallDialog:refresh()
--     self.taskList=ltzdzFightApi:getSortTask()
--     self.cellNum=SizeOfTable(self.taskList)
--     if self.tv then
--         self.tv:reloadData()
--     end
-- end

--显示任务结算页面
function ltzdzTaskSmallDialog:showTaskCompleteDialog(tasklist,layerNum,callback)
    local sd=ltzdzTaskSmallDialog:new()
    sd:initTaskCompleteDialog(tasklist,layerNum,callback)
end

function ltzdzTaskSmallDialog:initTaskCompleteDialog(tasklist,layerNum,callback)
    -- tasklist={t1=30,t2=30,t3=30,t4=30,t5=30,t6=30,t7=30,t8=30,t9=30,t10=30,t11=30,t12=30,t13=30,t14=30,t15=30}
    if tasklist==nil or SizeOfTable(tasklist)==0 then
        do return end
    end
    local sortTaskTb={}
    local taskCfg=ltzdzVoApi:getWarCfg().task    
    for k,v in pairs(tasklist) do
        local cfg=taskCfg[k]
        local sortId=cfg.sort
        table.insert(sortTaskTb,{k,v,sortId})
    end
    local function sortFunc(a,b)
        if a[3]<b[3] then
            return true
        end
        return false
    end
    table.sort(sortTaskTb,sortFunc)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzTaskSmallDialog",self)
    self.isTouch=false
    self.isUseAmi=true
    self.layerNum=layerNum

    local size=CCSizeMake(550,500)
    self.bgSize=size
    local function nilFunc()
    end
    local dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30,30,1,1),nilFunc)
    dialogBg:setContentSize(self.bgSize)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self:show()

    local bgLayerPosY=G_VisibleSizeHeight/2-60
    self.bgLayer:setPosition(G_VisibleSizeWidth/2,bgLayerPosY)
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)

    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelSuccessBg.png",CCRect(158,20,1,1),function () end)
    titleBg:setContentSize(CCSizeMake(self.bgSize.width-120,titleBg:getContentSize().height))
    titleBg:setPosition(self.bgSize.width/2,self.bgSize.height+titleBg:getContentSize().height/2+25)
    self.bgLayer:addChild(titleBg,2)
    local titleLineSp=CCSprite:createWithSpriteFrameName("rewardPanelSuccessLight.png")
    titleLineSp:setPosition(ccp(titleBg:getPositionX(),titleBg:getPositionY()))
    self.bgLayer:addChild(titleLineSp)

    local titleLb=GetTTFLabelWrap(getlocal("ltzdz_task_finished"),28,CCSizeMake(size.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2+20)
    titleLb:setColor(G_ColorYellow)
    titleBg:addChild(titleLb)

    local taskWidth,taskHeight=self.bgSize.width-60,240
    local clipperSize=CCSizeMake(taskWidth,taskHeight)
    local clipper=CCClippingNode:create()
    clipper:setContentSize(clipperSize)
    clipper:setAnchorPoint(ccp(0.5,0.5))
    clipper:setPosition(G_VisibleSizeWidth/2,bgLayerPosY+self.bgSize.height/2-taskHeight/2-10)
    local stencil=CCDrawNode:getAPolygon(clipperSize,1,1)
    clipper:setStencil(stencil) --遮罩
    self.dialogLayer:addChild(clipper,3)
    stencil:setPosition(0,0)

    local leftPos=ccp(-clipperSize.width/2,clipperSize.height/2)
    local centerPos=ccp(clipperSize.width/2,clipperSize.height/2)
    local rightPos=ccp(3*clipperSize.width/2,clipperSize.height/2)
    local outScreenPos=ccp(10000,clipperSize.height/2)
    local taskLayerTb={}
    local curPage,maxPage,taskCount=1,1,0
    local showTaskTb={}
    local actionTb={}
    local addPoint=0
    for k,v in pairs(sortTaskTb) do
        if maxPage*4<=taskCount then
            maxPage=maxPage+1
        end
        if showTaskTb[maxPage]==nil then
            showTaskTb[maxPage]={}
        end
        table.insert(showTaskTb[maxPage],v)
        taskCount=taskCount+1
        addPoint=addPoint+(v[2] or 0)
    end

    local function refreshPagePoint(lastPage,curPage)
        if self.pagePointTb[lastPage] and self.pagePointTb[curPage] then
            local lastPointSp=tolua.cast(self.pagePointTb[lastPage],"LuaCCSprite")
            local curPointSp=tolua.cast(self.pagePointTb[curPage],"LuaCCSprite")
            local frame1=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pagePoint.png")
            local frame2=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("pagePointLight.png")
            if lastPointSp and curPointSp then
                if frame1 then
                    lastPointSp:setDisplayFrame(frame1)
                end
                if frame2 then
                    curPointSp:setDisplayFrame(frame2)
                end
            end
        end
    end

    local lastPoint=0
    local scrollFlag=false
    local turnInterval=0.3
    local function leftPageHandler()
        if scrollFlag==true then
            do return end
        end
        scrollFlag=true
        local nextPage=curPage-1
        if nextPage<1 then
            scrollFlag=false
            do return end
        end
        local newTaskItem=taskLayerTb[nextPage]
        local taskItem=taskLayerTb[curPage]
        newTaskItem:setPosition(leftPos)
        local function playEndCallback()
            scrollFlag=false
            local lastPage=curPage
            curPage=nextPage
            taskItem:setPosition(outScreenPos)
            refreshPagePoint(lastPage,curPage)
        end
        
        local mvTo1=CCMoveTo:create(turnInterval,rightPos)
        local mvTo2=CCMoveTo:create(turnInterval,centerPos)
        local callFunc=CCCallFuncN:create(playEndCallback)

        local acArr=CCArray:create()
        acArr:addObject(mvTo1)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        taskItem:runAction(seq)

        local acArr1=CCArray:create()
        acArr1:addObject(mvTo2)
        local seq1=CCSequence:create(acArr1)
        newTaskItem:runAction(seq1)
    end
    local function rightPageHandler(actionFlag)
        if scrollFlag==true then
            do return end
        end
        scrollFlag=true
        local nextPage=curPage+1
        if nextPage>maxPage then
            scrollFlag=false
            do return end
        end
        local newTaskItem=taskLayerTb[nextPage]
        local taskItem=taskLayerTb[curPage]
        newTaskItem:setPosition(rightPos)
        local function playEndCallback()
            scrollFlag=false
            local lastPage=curPage
            curPage=nextPage
            taskItem:setPosition(outScreenPos)
            refreshPagePoint(lastPage,curPage)
            if actionFlag and actionFlag==true then
                G_RunActionCombo(actionTb[curPage])
            end
        end
        
        local mvTo1=CCMoveTo:create(turnInterval,leftPos)
        local mvTo2=CCMoveTo:create(turnInterval,centerPos)
        local callFunc=CCCallFuncN:create(playEndCallback)

        local acArr=CCArray:create()
        acArr:addObject(mvTo1)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        taskItem:runAction(seq)

        local acArr1=CCArray:create()
        acArr1:addObject(mvTo2)
        local seq1=CCSequence:create(acArr1)
        newTaskItem:runAction(seq1)
    end

    local function playAddPoint(ap)
        if self.pointLb then
            lastPoint=lastPoint+ap
            self.pointLb:setString("+"..lastPoint)
        end    
    end
    self.pagePointTb={}
    local pspace,pw=15,30
    for i=1,maxPage do
        local taskLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function () end)
        taskLayer:setOpacity(0)
        taskLayer:setContentSize(clipperSize)
        if i==1 then
            taskLayer:setPosition(centerPos)
            curPage=i
        else
            taskLayer:setPosition(outScreenPos)
        end
        clipper:addChild(taskLayer)

        local taskTb=showTaskTb[i]
        for k,v in pairs(taskTb) do
            local itemHeight=60
            local itemPosY=taskHeight-itemHeight/2-(k-1)*itemHeight
            local taskSp=CCNode:create()
            taskSp:setContentSize(CCSizeMake(taskWidth,itemHeight))
            taskSp:setAnchorPoint(ccp(0.5,0.5))
            taskSp:setPosition(rightPos.x,itemPosY)
            taskLayer:addChild(taskSp)

            local tid,point=v[1],v[2]
            local taskCfg=ltzdzVoApi:getWarCfg().task
            if tid and taskCfg[tid] then
                local cfg=taskCfg[tid]
                local descStr,simpleDescStr=ltzdzFightApi:getTaskInfoById(tid,cfg.conditions)
                local colorTab={G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
                local descLb,lbHeight=G_getRichTextLabel(descStr,colorTab,20,taskWidth-150,kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                descLb:setAnchorPoint(ccp(0,0.5))
                descLb:setPosition(25,taskSp:getContentSize().height/2+lbHeight/2)
                taskSp:addChild(descLb)

                local finishLb=GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_complete"),20)
                finishLb:setAnchorPoint(ccp(1,0.5))
                finishLb:setPosition(taskWidth-25,taskSp:getContentSize().height/2)
                taskSp:addChild(finishLb)
            end
            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function () end)
            lineSp:setContentSize(CCSizeMake(436,2))
            lineSp:setPosition(taskWidth/2,0)
            taskSp:addChild(lineSp)

            if actionTb[i]==nil then
                actionTb[i]={}
            end
            local function addPointHandler()
               playAddPoint(point)
            end
            local playHandler
            if k==SizeOfTable(taskTb) then
                local function callback()
                    addPointHandler()
                    rightPageHandler(true)
                end
                playHandler=callback
            else
                playHandler=addPointHandler
            end
            actionTb[i]["taskSp"..k]={{1,101},taskSp,nil,nil,ccp(centerPos.x,itemPosY),k*0.3,0.4,nil,playHandler}
        end
        taskLayerTb[i]=taskLayer

        local pointPic="pagePoint.png"
        if curPage==i then
            pointPic="pagePointLight.png"
        end
        local pposX=self.bgSize.width/2-math.floor(maxPage/2)*pw-pspace
        if maxPage%2==0 then
            pposX=self.bgSize.width/2-(maxPage/2-0.5)*(pw+pspace)
        end
        local pagePointSp=LuaCCSprite:createWithSpriteFrameName(pointPic,function () end)
        pagePointSp:setPosition(pposX+(i-1)*(pspace+pw),self.bgSize.height-taskHeight-30)
        self.bgLayer:addChild(pagePointSp)
        self.pagePointTb[i]=pagePointSp
    end
    G_RunActionCombo(actionTb[curPage])

    local arrowPosY=self.bgSize.height-120
    local arrowCfg={
        {startPos=ccp(45,arrowPosY),targetPos=ccp(25,arrowPosY),callback=leftPageHandler,angle=0},
        {startPos=ccp(self.bgSize.width-45,arrowPosY),targetPos=ccp(self.bgSize.width-25,arrowPosY),callback=rightPageHandler,angle=180}
    }
    for i=1,2 do
        local cfg=arrowCfg[i]
        local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",cfg.callback,11,nil,nil)
        arrowBtn:setRotation(cfg.angle)
        local arrowMenu=CCMenu:createWithItem(arrowBtn)
        arrowMenu:setAnchorPoint(ccp(0.5,0.5))
        arrowMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        arrowMenu:setPosition(cfg.startPos)
        self.bgLayer:addChild(arrowMenu)

        local moveTo=CCMoveTo:create(0.5,cfg.targetPos)
        local fadeIn=CCFadeIn:create(0.5)
        local carray=CCArray:create()
        carray:addObject(moveTo)
        carray:addObject(fadeIn)
        local spawn=CCSpawn:create(carray)

        local moveTo2=CCMoveTo:create(0.5,cfg.startPos)
        local fadeOut=CCFadeOut:create(0.5)
        local carray2=CCArray:create()
        carray2:addObject(moveTo2)
        carray2:addObject(fadeOut)
        local spawn2=CCSpawn:create(carray2)

        local seq=CCSequence:createWithTwoActions(spawn2,spawn)
        arrowMenu:runAction(CCRepeatForever:create(seq))
    end

    local kuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),nilFunc)
    kuangSp:setContentSize(CCSizeMake(size.width-100,100))
    kuangSp:setPosition(size.width/2,150)
    self.bgLayer:addChild(kuangSp)

    local promptLb=GetTTFLabelWrap(getlocal("you_get_title"),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0,0.5))
    promptLb:setPosition(20,kuangSp:getContentSize().height/2)
    -- promptLb:setColor(G_ColorYellow)
    kuangSp:addChild(promptLb)

    local pointSp=CCSprite:createWithSpriteFrameName("ltzdzPointIcon.png")
    pointSp:setAnchorPoint(ccp(0,0.5))
    local scale=60/pointSp:getContentSize().width
    pointSp:setScale(scale)
    pointSp:setPosition(kuangSp:getContentSize().width/2+10,kuangSp:getContentSize().height/2)
    kuangSp:addChild(pointSp)

    local pointNameLb=GetTTFLabelWrap(getlocal("ltzdz_feat"),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    pointNameLb:setAnchorPoint(ccp(0,0.5))
    pointNameLb:setPosition(pointSp:getPositionX()+pointSp:getContentSize().width*scale+10,kuangSp:getContentSize().height/2+20)
    kuangSp:addChild(pointNameLb)

    local pointLb=GetTTFLabelWrap("+"..lastPoint,20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    pointLb:setAnchorPoint(ccp(0,0.5))
    pointLb:setPosition(pointNameLb:getPositionX(),kuangSp:getContentSize().height/2-20)
    pointLb:setColor(G_ColorGreen)
    kuangSp:addChild(pointLb)
    self.pointLb=pointLb

    local function confirm()
        self:close()
        if callback then
            callback()
        end
    end
    G_createBotton(self.bgLayer,ccp(size.width/2,50),{getlocal("confirm")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirm,0.8,-(self.layerNum-1)*20-4)
    
    local function touchLuaSpr()
         
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255*0.8)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg);

    self:addForbidSp(self.bgLayer,size,self.layerNum,nil,nil,true)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function ltzdzTaskSmallDialog:dispose()
	self.pagePointTb={}
    self.pointLb=nil
    self.taskLayerTb={}
    if self.refreshListener then
        eventDispatcher:removeEventListener("ltzdz.updateTask",self.refreshListener)
        self.refreshListener=nil
    end
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzTaskSmallDialog")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")

end