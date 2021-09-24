unlockPlaneDialog=commonDialog:new()

function unlockPlaneDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
    self.space1=210
    self.space2=210
	return nc
end

function unlockPlaneDialog:initTableView()
    spriteController:addPlist("public/vipFinal.plist")
    spriteController:addTexture("public/vipFinal.png")

    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,15))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSize.height-95))

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local planeUnlockBg=CCSprite:create("public/plane/planeUnlockBg.jpg")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    planeUnlockBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-200-50))
    planeUnlockBg:setScaleX((G_VisibleSizeWidth-40)/planeUnlockBg:getContentSize().width)
    self.bgLayer:addChild(planeUnlockBg)

    local planeList=planeVoApi:getLockPlanes()
	local planeNum=SizeOfTable(planeList)
    self.sortPidTb={}
    self.planeSpTb={}
    if planeNum>0 then
        self.list={}
        self.dlist={}
        self.planeTb={}

        local function pageRefresh()
        end
        require "luascript/script/game/scene/gamedialog/plane/planeInfoDialog"
        local idx=0
        for k,v in pairs(planeList) do
            idx=idx+1
            local planeLayer,planePage=self:newPageLayer(v.pid,pageRefresh)
            self.bgLayer:addChild(planeLayer,2)
            planeLayer:setPosition(ccp(0,0))

            if idx==1 then
                planePage:initTableView()
            end

            self.list[idx]=planeLayer
            self.dlist[idx]=planePage
            self.planeTb[idx]=v.pid
        end

        self.pageDialog=pageDialog:new()
        self.page=1

        local isShowBg=false
        local isShowPageBtn=false

        local function onPage(topage)
            self.page=topage
        end
        local function movedCallback(turnType,isTouch)
            local planeNum1=SizeOfTable(self.list)
            local page
            if turnType==1 then -- 左
                if self.planeSpTb and SizeOfTable(self.planeSpTb)==2 and self.removePid==nil then
                    local sp=tolua.cast(self.planeSpTb[2],"CCSprite")
                    if sp and sp:getPositionX()==G_VisibleSizeWidth/2+self.space1 then
                        do return false end
                    end
                end
                page=self.page-1
                if page<1 then
                    page=planeNum1
                end
            else
                if self.planeSpTb and SizeOfTable(self.planeSpTb)==2 and self.removePid==nil then
                    local sp=tolua.cast(self.planeSpTb[2],"CCSprite")
                    if sp and sp:getPositionX()==G_VisibleSizeWidth/2-self.space1 then
                        do return false end
                    end
                end
                page=self.page+1
                if page>planeNum1 then
                    page=1
                end
            end

            if not self.dlist[page].tv then
                self.dlist[page]:initTableView()
            else
                -- self.dlist[page]:refresh(self.planeTb[page],planeList1)
            end

            if self.pageDialog and self.pageDialog.isAnimation==true then
                do return false end
            else
                self:planeMoveAction(turnType)
            end

            return true
        end

        local posY=G_VisibleSizeHeight-200-50
        local leftBtnPos=ccp(60,posY)
        local rightBtnPos=ccp(self.bgLayer:getContentSize().width-60,posY)
        self.pageLayer=self.pageDialog:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback,-(self.layerNum-1)*20-4,nil,"vipArrow.png",true,nil,180)

        if planeNum==1 then
            self.pageDialog:setEnabled(false)
        end

        self.sortPidTb=G_clone(self.planeTb)
        self:updateShowPlane()
    end

    local function unlockHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
      	local function realUnlock()
	       	local function unlockCallBack()
                local ableNum=planeVoApi:getUnlockAbleNum() 
		        if ableNum==0 then --如果当前没有可解锁的飞机，则显示空中打击系统主页面
    		        planeVoApi:showMainDialog(self.layerNum+1)
                    self:closeDialog()
                    self:close()
                else
                    self:refreshPageLayer()
		        end
                local data={btype=106}
                eventDispatcher:dispatchEvent("baseBuilding.build.refresh",data)
	        end
            local planeId=self.planeTb[self.page]
	        planeVoApi:unlock(planeId,unlockCallBack)
        end
        local planeId=self.planeTb[self.page]    
        local nameStr=getlocal("plane_name_"..planeId)
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realUnlock,getlocal("dialog_title_prompt"),getlocal("unlock_prompt_str",{nameStr}),nil,self.layerNum+1) 
    end
    local scale=0.8
	local unlockItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",unlockHandler,nil,getlocal("activity_fbReward_unlock"),25/scale)
	unlockItem:setAnchorPoint(ccp(0.5,0.5))
	unlockItem:setScale(scale)
	local unlockBtn=CCMenu:createWithItem(unlockItem)
	unlockBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	unlockBtn:setPosition(ccp(G_VisibleSizeWidth/2,140))
	self.bgLayer:addChild(unlockBtn)

    local ableNum=planeVoApi:getUnlockAbleNum()
   	local unlockLb=GetTTFLabelWrap(getlocal("unlock_able",{ableNum}),25,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
   	unlockLb:setAnchorPoint(ccp(0.5,1))
   	unlockLb:setPosition(G_VisibleSizeWidth/2,80)
   	self.bgLayer:addChild(unlockLb)
   	self.unlockLb=unlockLb

    local maskSpHeight=self.bgLayer:getContentSize().height-125
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        -- leftMaskSp:setPosition(0,pos.y+25)
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        -- rightMaskSp:setRotation(180)
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end
    if otherGuideMgr.isGuiding and otherGuideMgr.curStep==32 then
        otherGuideMgr:toNextStep()
    end
end

function unlockPlaneDialog:newPageLayer(id,pageRefresh)
    local tvHeight=self.tvHeight
	local planePage=planeInfoDialog:new(pageRefresh)
    local planeList=planeVoApi:getLockPlanes()
    local planeLayer=planePage:init(id,planeList,self.layerNum)
	return planeLayer,planePage
end

function unlockPlaneDialog:refreshPageLayer()
    local planeList=planeVoApi:getLockPlanes()
    local planeNum=SizeOfTable(planeList)
    if planeNum==0 then
        self:closeDialog()
        do return end
    elseif planeNum==1 then
        self.pageDialog:setEnabled(false)
    end
    local ableNum=planeVoApi:getUnlockAbleNum() 
    if self.unlockLb then
        self.unlockLb:setString(getlocal("unlock_able",{ableNum}))
    end
    local curPage=self.page
    local function customCallback()
        -- for i=#self.list,planeNum+1,-1 do
        --     table.remove(self.list,i)
        --     self.dlist[i]:dispose()
        --     table.remove(self.dlist,i)
        --     table.remove(self.planeTb,i)
        -- end
        if self.list[curPage] then
            table.remove(self.list,curPage)
            self.dlist[curPage]:dispose()
            table.remove(self.dlist,curPage)
            table.remove(self.planeTb,curPage)
            if self.pageDialog and self.pageDialog.page then
                if curPage>SizeOfTable(self.list) then
                    self.pageDialog.page=1
                    self.page=1
                else
                    self.pageDialog.page=curPage
                    self.page=curPage
                end
            end
        end
    end

    self.removePid=self.planeTb[self.page]
    local turnToPage
    if planeNum<self.page then
        self.page=1
        -- local pid=self.planeTb[self.page]
        -- self.dlist[self.page]:refresh(pid,planeList)
        -- self.pageDialog:rightPage(true,self.page,customCallback)
        turnToPage=self.page
    else
        -- local pid=self.planeTb[self.page+1]
        -- self.dlist[self.page]:refresh(pid,planeList)
        -- self.pageDialog:rightPage(true,self.page+1,customCallback)
        turnToPage=self.page+1
    end
    local pageType=2
    if self.planeSpTb and SizeOfTable(self.planeSpTb)==2 then
        local sp=tolua.cast(self.planeSpTb[2],"CCSprite")
        if sp and sp:getPositionX()==G_VisibleSizeWidth/2-self.space1 then
            pageType=1
        end
    end
    if pageType==1 then
        self.pageDialog:leftPage(true,turnToPage,customCallback)
    else
        self.pageDialog:rightPage(true,turnToPage,customCallback)
    end
end

function unlockPlaneDialog:planeMoveAction(turnType)
    if self.sortPidTb and SizeOfTable(self.sortPidTb)>1 then
        local planeNum=SizeOfTable(self.sortPidTb)
        local minScale,maxScale=0.5,0.8
        if self.removePid then
            local curPlaneNum=0
            if self.sortPidTb then
                for k,v in pairs(self.sortPidTb) do
                    if v and v==self.removePid then
                        table.remove(self.sortPidTb,k)
                        break
                    end
                end
                curPlaneNum=SizeOfTable(self.sortPidTb)
            end
            if curPlaneNum>=1 then
                for k,v in pairs(self.planeSpTb) do
                    if k==1 and v then
                        table.remove(self.planeSpTb,k)
                        v:removeFromParentAndCleanup(true)
                        v=nil
                        break
                    end
                end
                if curPlaneNum>=3 then
                    local pid=self.sortPidTb[2]
                    local pic="plane_icon_"..pid..".png"
                    local planeSp=CCSprite:createWithSpriteFrameName(pic)
                    if planeSp then
                        planeSp:setPosition(G_VisibleSizeWidth/2+self.space1+self.space2,G_VisibleSizeHeight-self.space1)
                        planeSp:setScale(minScale)
                        local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                        planeSp:setTag(id)
                        self.bgLayer:addChild(planeSp,5)
                        table.insert(self.planeSpTb,2,planeSp)
                    end
                end
                for k,v in pairs(self.planeSpTb) do
                    local sp=tolua.cast(v,"CCSprite")
                    local posx,scale
                    if k==1 then
                        posx=G_VisibleSizeWidth/2
                        scale=maxScale
                        self:playAction(sp,posx,scale)
                    elseif k==2 and curPlaneNum>=3 then
                        posx=G_VisibleSizeWidth/2+self.space1
                        scale=minScale
                        self:playAction(sp,posx,scale)
                    end
                end
            end
            self:planeSetColor()
            self.removePid=nil
        else
            if self.sortPidTb then
                local tmpTb={}
                local oldPlaneNum=SizeOfTable(self.sortPidTb)
                for k,v in pairs(self.sortPidTb) do
                    local idx
                    if turnType==1 then
                        idx=k+1
                        if idx>oldPlaneNum then
                            idx=1
                        end
                    else
                        idx=k-1
                        if idx<1 then
                            idx=oldPlaneNum
                        end
                    end
                    tmpTb[idx]=v
                end
                self.sortPidTb={}
                self.sortPidTb=tmpTb
                local curPlaneNum=SizeOfTable(self.sortPidTb)

                for k,v in pairs(self.planeSpTb) do
                    local sp=tolua.cast(v,"CCSprite")
                    local posx,scale
                    if turnType==1 then
                        if k==1 then
                            posx=G_VisibleSizeWidth/2+self.space1
                            scale=minScale
                        elseif k==2 then
                            if curPlaneNum==2 then
                                posx=G_VisibleSizeWidth/2
                                scale=maxScale
                            else
                                posx=G_VisibleSizeWidth/2+self.space1+self.space2
                            end
                        elseif k==3 then
                            posx=G_VisibleSizeWidth/2
                            scale=maxScale
                        end
                    else 
                        if k==1 then
                            posx=G_VisibleSizeWidth/2-self.space1
                            scale=minScale
                        elseif k==2 then
                            posx=G_VisibleSizeWidth/2
                            scale=maxScale
                        elseif k==3 then
                            posx=G_VisibleSizeWidth/2-self.space1-self.space2
                        end
                    end
                    if k==SizeOfTable(self.planeSpTb) then
                        local function moveEndHandler1( ... )
                            if curPlaneNum>=2 then
                                self:updateShowPlane()
                            -- elseif curPlaneNum==2 then
                            --     -- local tmpSpTb=G_clone(self.planeSpTb)
                            --     -- self.planeSpTb={}
                            --     -- self.planeSpTb={tmpSpTb[2],tmpSpTb[1]}
                            --     self.planeSpTb={self.planeSpTb[2],self.planeSpTb[1]}
                            end
                        end
                        self:playAction(sp,posx,scale,moveEndHandler1)
                    else
                        self:playAction(sp,posx,scale)
                    end
                end
                
                if curPlaneNum>=3 then
                    local pid,oldPosx,posx,scale
                    if turnType==1 then
                        pid=self.sortPidTb[curPlaneNum]
                        oldPosx=G_VisibleSizeWidth/2-self.space1-self.space2
                        posx=G_VisibleSizeWidth/2-self.space1
                        scale=minScale
                    else
                        pid=self.sortPidTb[2]
                        oldPosx=G_VisibleSizeWidth/2+self.space1+self.space2
                        posx=G_VisibleSizeWidth/2+self.space1
                        scale=minScale
                    end
                    local pic="plane_icon_"..pid..".png"
                    local movePlaneSp=CCSprite:createWithSpriteFrameName(pic)
                    if movePlaneSp then
                        movePlaneSp:setPosition(oldPosx,G_VisibleSizeHeight-200-50)
                        movePlaneSp:setScale(scale)
                        self.bgLayer:addChild(movePlaneSp,5)
                        movePlaneSp:setColor(G_ColorBlack)
                        local function moveEndHandler( ... )
                            movePlaneSp:removeFromParentAndCleanup(true)
                            movePlaneSp=nil
                        end
                        self:playAction(movePlaneSp,posx,scale,moveEndHandler)
                    end
                end
            end
        end
    end
end

function unlockPlaneDialog:updateShowPlane()
    if self.sortPidTb and SizeOfTable(self.sortPidTb)>0 then
        local curPlaneNum=SizeOfTable(self.sortPidTb)
        local pDataTb={}
        if self.planeSpTb then
            for k,v in pairs(self.planeSpTb) do
                if v then
                    if curPlaneNum==2 then
                        -- local pData={px=v:getPositionX(),scale=v:getScale(),pid="p"..v:getTag()}
                        local pid="p"..v:getTag()
                        pDataTb[pid]={px=v:getPositionX(),scale=v:getScale()}
                        -- table.insert(pDataTb,pData)
                    end
                    v:removeFromParentAndCleanup(true)
                    v=nil
                end
            end
        end
        self.planeSpTb={}
        for k,pid in pairs(self.sortPidTb) do
            local posx
            local scale=0.5
            local color=G_ColorBlack
            if k==1 then
                posx=G_VisibleSizeWidth/2
                scale=0.8
            elseif k==2 then
                posx=G_VisibleSizeWidth/2+self.space1
            elseif k==SizeOfTable(self.sortPidTb) then
                posx=G_VisibleSizeWidth/2-self.space1
            end
            if pDataTb and pDataTb[pid] then
                local pData=pDataTb[pid]
                if pData.px and pData.scale then
                    posx,scale=pData.px,pData.scale
                end
            end
            if posx then
                local pic="plane_icon_"..pid..".png"
                local planeSp=CCSprite:createWithSpriteFrameName(pic)
                if planeSp then
                    planeSp:setPosition(posx,G_VisibleSizeHeight-200-50)
                    planeSp:setScale(scale)
                    local id=(tonumber(pid) or tonumber(RemoveFirstChar(pid)))
                    planeSp:setTag(id)
                    self.bgLayer:addChild(planeSp,5)
                    table.insert(self.planeSpTb,planeSp)
                end
            end
        end
        self:planeSetColor()
    end
end

function unlockPlaneDialog:playAction(sp,posx,scale,callback)
    if sp then
        sp:setColor(G_ColorBlack)
        local actime=0.3
        local acArr=CCArray:create()
        local function moveEndCallback( ... )
            self:planeSetColor()
            if callback then
                callback()
            end
        end    
        local callFunc=CCCallFunc:create(moveEndCallback)
        local pos=ccp(posx,sp:getPositionY())
        local moveTo=CCMoveTo:create(actime,pos)
        local spwanArr=CCArray:create()
        spwanArr:addObject(moveTo)
        if scale then
            local scaleTo=CCScaleTo:create(actime,scale)
            spwanArr:addObject(scaleTo)
        end
        local swpanAc=CCSpawn:create(spwanArr)
        acArr:addObject(swpanAc)
        acArr:addObject(callFunc)
        local seq=CCSequence:create(acArr)
        sp:runAction(seq)
    end
end

function unlockPlaneDialog:planeSetColor()
    if self.planeSpTb then
        for k,v in pairs(self.planeSpTb) do
            local sp=tolua.cast(v,"CCSprite")
            if sp then
                if sp:getPositionX()==G_VisibleSizeWidth/2 then
                    sp:setColor(G_ColorWhite)
                else
                    sp:setColor(G_ColorBlack)
                end
            end
        end
    end
end

function unlockPlaneDialog:closeDialog()
    self:close()
    self.pageDialog:dispose()
    self.pageLayer:removeFromParentAndCleanup(true)
    self.pageDialog=nil
    self.pageLayer=nil
    self.dlist={}
    self.list={}
    self.planeTb={}
    self.planeSpTb={}
    self.sortPidTb={}
    self.removePid=nil
end

function unlockPlaneDialog:dispose()
    spriteController:removePlist("public/vipFinal.plist")
    spriteController:removeTexture("public/vipFinal.png")
end

