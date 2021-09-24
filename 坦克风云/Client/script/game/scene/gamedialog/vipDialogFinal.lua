--require "luascript/script/componet/commonDialog"
vipDialogFinal=commonDialog:new()

function vipDialogFinal:new(isShowVipReward)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.isShowVipReward=isShowVipReward
    self.vipDescLabel=nil
    self.rechargeBtn=nil
    self.menuRecharge=nil
    self.buygems=nil
    self.timerSprite=nil
    self.vipBgSprie=nil
    self.vipLevelLabel=nil
    self.vipIcon=nil

    self.expandIdx={}
    self.normalHeight=60
    self.lbTab={}

    self.tv2CellHeight= nil
    self.tv2CellBsHeight=nil
    self.tv2CellBtnUpStrHeight =nil
    self.tv2cellBtnHeight =nil
    self.heightTab={}
    self.notIncludeLb=nil
    self.vipNum=playerVoApi:getMaxLvByKey("maxVip")+1
    self.showVip=self.vipNum
    self.vipPageDialog=nil
    self.vipLayer=nil
    self.page=1
    self.curPageFlag=nil
    self.pageFlagList={}
    self.tvTab={}
    self.rewardNum=0
    self.fontSize=25 --字体大小
    self.vSpace=15 --字行间距
    self.curVipLevel=0
    self.backSpTab={}
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage2.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/vipFinal.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/acFirstRechargenew.plist")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/acChunjiepansheng.plist")
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")
    return nc
end


--设置对话框里的tableView
function vipDialogFinal:initTableView()
    local gem4vipCfg1=Split(G_getPlatVipCfg(),",")
    local vipMaxNum=SizeOfTable(gem4vipCfg1)+1
    if self.vipNum>vipMaxNum then
        self.vipNum=vipMaxNum
    end
    if platCfg.platCfgShowVip[G_curPlatName()]~=nil then
        if playerVoApi:getVipLevel()==0 then
            self.showVip=2
        elseif playerVoApi:getVipLevel()>=1 and playerVoApi:getVipLevel()<5 then
            self.showVip=6
        elseif playerVoApi:getVipLevel()>=5 then
            self.showVip=playerVoApi:getVipLevel()+2
            if self.showVip>=self.vipNum then
                self.showVip=self.vipNum
            end
        end
    end
    if self.showVip>vipMaxNum then
        self.showVip=vipMaxNum
    end
    
    if self and self.isShowVipReward==true then
        self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-430-10))
        self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-127-5))
    else
        self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-430+60-19))
        self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-127+60/2-5))
    end

    local function touch(hd,fn,idx)
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    self.vipBgSprie=CCSprite:create("public/vipHeadBg.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.vipBgSprie:setAnchorPoint(ccp(0.5,1))
    self.vipBgSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-115+15))
    self.bgLayer:addChild(self.vipBgSprie,1)
    

    local function touch1(hd,fn,idx)

    end
    self.vipIcon=CCSprite:createWithSpriteFrameName("vipTitleBg.png")
    self.vipIcon:setPosition(ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-15))
    self.vipBgSprie:addChild(self.vipIcon,1)
	
    self:updateVipSchedule()

    self.bgy=self.panelLineBg:getPositionY()-self.panelLineBg:getContentSize().height/2+5


    self.page=playerVoApi:getVipLevel()+1
    local space=30
    self.list={}
    self.dlist={}
    self.pageFlagList={}
    local pageNum=self.showVip
    for i=1,pageNum do
        local backSprie=self:initVipDetail(i)

        self.list[i]=backSprie
        -- self.dlist[i]=backSprie

        local pfScale=0.8
        local pageFlag=CCSprite:createWithSpriteFrameName("circlenormal.png")
        pageFlag:setScale(pfScale)
        pageFlag:setTag(100 + i)
        local pox=self.panelLineBg:getContentSize().width/2-(space/2*(pageNum-1))+(i-1)*space
        pageFlag:setPosition(ccp(pox,23))
        self.panelLineBg:addChild(pageFlag,1)
        if self.page==i then
            self:initVipDetailTv(i-1)
            self.curPageFlag=CCSprite:createWithSpriteFrameName("circleSelect.png")
            self.curPageFlag:setScale(pfScale)
            self.curPageFlag:setPosition(ccp(pox,23))
            self.panelLineBg:addChild(self.curPageFlag,2)
        end
        self.pageFlagList[i]=pageFlag
    end


    self.vipPageDialog=pageDialog:new()
    
    local isShowBg=false
    local isShowPageBtn=true
    local function onPage(topage)
        self.page=topage
        if self.curPageFlag then
            local pox=self.panelLineBg:getContentSize().width/2-(space/2*(pageNum-1))+(topage-1)*space
            self.curPageFlag:setPositionX(pox)
        end
    end
    local posY=self.panelLineBg:getContentSize().height-45
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.panelLineBg:getContentSize().width-40,posY)
    local function movedCallback(turnType,isTouch)
        local canMove=true
        if self.page and self.tvTab then
            local turnPage=self.page+1
            if turnType==1 then
                turnPage=self.page-1
            end
            if turnPage<=0 then
                turnPage=pageNum
            elseif turnPage>pageNum then
                turnPage=1
            end
            -- print("turnPage",turnPage)
            if self.tvTab[turnPage] then
            else
                self:initVipDetailTv(turnPage-1)
            end
            if self.tvTab[self.page] and isTouch==true then
                local tv=self.tvTab[self.page]
                if tv and tv.getScrollEnable and tv.getIsScrolled then
                    canMove=false
                    if tv:getScrollEnable()==true and tv:getIsScrolled()==false then
                        canMove=true
                    end
                end
            end
        end
        return canMove
    end
    self.vipLayer=self.vipPageDialog:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.panelLineBg,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback,nil,nil,"vipArrow.png",true)
    -- self.curTankTab=self.dlist[1]
    -- self.curTankTab.isShow=true

    local maskSpHeight=self.bgLayer:getContentSize().height-405
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        -- leftMaskSp:setPosition(0,pos.y+25)
        leftMaskSp:setPosition(0,100)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        -- rightMaskSp:setRotation(180)
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,115)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end

end

function vipDialogFinal:initVipDetail(indx)
    local index=indx-1
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
    backSprie:setContentSize(CCSizeMake(self.panelLineBg:getContentSize().width, self.panelLineBg:getContentSize().height))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    backSprie:setPosition(ccp(0,0))
    self.panelLineBg:addChild(backSprie)
    backSprie:setOpacity(0)
    self.backSpTab[index+1]=backSprie
    local bgWidth=backSprie:getContentSize().width
    local bgHeight=backSprie:getContentSize().height
    local headHeight=80


    -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    -- lineSp:setScale(backSprie:getContentSize().width/lineSp:getContentSize().width)
    -- lineSp:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-85))
    -- backSprie:addChild(lineSp,3)

    local vipStr=""
    if index>0 then
        -- local vipLevel=playerVoApi:getVipLevel()
        local vipLevelCfg=Split(playerCfg.vipLevel,",")
        local gem4vipCfg=Split(G_getPlatVipCfg(),",")
        local needTotalGems=tonumber(gem4vipCfg[index])
        vipStr=getlocal("VIPStr1",{index})..getlocal("new_vip_total_recharge",{needTotalGems})
    else
        vipStr=getlocal("VIPStr1",{index})
    end
    local vipTitleLb=GetTTFLabelWrap(vipStr,24,CCSizeMake(bgWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("orangeMask.png",CCRect(20,0,552,42),function ( ... )end)
    titleBg:setContentSize(CCSizeMake(bgWidth-200,vipTitleLb:getContentSize().height+20))
    titleBg:setPosition(bgWidth/2,bgHeight-(headHeight/2)-5)
    backSprie:addChild(titleBg)
    local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine:setPosition(ccp(titleBg:getContentSize().width/2,titleBg:getContentSize().height))
    titleBg:addChild(orangeLine)
    local orangeLine=CCSprite:createWithSpriteFrameName("acChunjiepansheng_orangeLine.png")
    orangeLine:setPosition(ccp(titleBg:getContentSize().width/2,0))
    titleBg:addChild(orangeLine)
    vipTitleLb:setPosition(getCenterPoint(titleBg))
    titleBg:addChild(vipTitleLb)


    -- local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg4.png",CCRect(10,10,10,10),function()end)
    -- local detailBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),function()end)
    -- detailBg:setAnchorPoint(ccp(0.5,1))
    -- detailBg:setContentSize(CCSizeMake(bgWidth-20,bgHeight-100))
    -- detailBg:setPosition(ccp(bgWidth/2,bgHeight-headHeight))
    -- backSprie:addChild(detailBg,1)
    local contentHeight=bgHeight-120
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local vipDetailBg=CCSprite:create("public/vipDetailBg.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    vipDetailBg:setScaleX((bgWidth-20)/vipDetailBg:getContentSize().width)
    vipDetailBg:setScaleY(contentHeight/vipDetailBg:getContentSize().height)
    vipDetailBg:ignoreAnchorPointForPosition(false)
    vipDetailBg:setAnchorPoint(ccp(0.5,0))
    -- vipDetailBg:setPosition(getCenterPoint(detailBg))
    -- detailBg:addChild(vipDetailBg)
    vipDetailBg:setPosition(ccp(bgWidth/2,120-headHeight))
    backSprie:addChild(vipDetailBg,1)

    return backSprie
end

function vipDialogFinal:initVipDetailTv(index)
    local backSprie=self.backSpTab[index+1]
    if backSprie then
        backSprie=tolua.cast(backSprie,"LuaCCScale9Sprite")
        local bgWidth=backSprie:getContentSize().width
        local bgHeight=backSprie:getContentSize().height
        local contentHeight=bgHeight-120
        local num,strData,height=self:getCellHeight(index)
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return num
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(bgWidth-20,height[idx+1] or 0)
                return tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local cellHeight=height[idx+1] or 0
                if strData and strData[idx+1] and strData[idx+1][1] then
                    local indexLb=GetTTFLabel((idx+1)..". ",20)
                    indexLb:setAnchorPoint(ccp(0,1))
                    indexLb:setPosition(ccp(10,cellHeight-5))
                    cell:addChild(indexLb,1)
                    local str=strData[idx+1][1]
                    local color=strData[idx+1][2]
                    local isUp=strData[idx+1][3]
                    -- print("str",str)

                    local colorTab={}
                    if color then
                        colorTab={G_ColorYellowPro}
                        indexLb:setColor(color)
                        local newSp=CCSprite:createWithSpriteFrameName("vipNewIcon.png")
                        newSp:setPosition(ccp(bgWidth-20-30,cellHeight-23))
                        cell:addChild(newSp,1)
                    else
                        colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite}
                        if isUp and isUp==true then
                            local upSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
                            upSp:setPosition(ccp(bgWidth-20-30,cellHeight-21))
                            cell:addChild(upSp,1)
                        end
                    end

                    local descLb,lbHeight=G_getRichTextLabel(str,colorTab,20,bgWidth-125,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,self.vSpace)
                    descLb:setAnchorPoint(ccp(0,1))
                    descLb:setPosition(ccp(55,cellHeight-5))
                    cell:addChild(descLb,1)
                    if G_isShowRichLabel()==true then
                    elseif color then
                        descLb:setColor(color)
                    end
                    
                    local colorLine=CCSprite:createWithSpriteFrameName("lineWhite.png")
                    colorLine:setColor(G_ColorGreen)
                    colorLine:setScaleX((bgWidth-30)/colorLine:getContentSize().width)
                    colorLine:setPosition(ccp((bgWidth-20)/2,3))
                    cell:addChild(colorLine)
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
        local hd= LuaEventHandler:createHandler(tvCallBack)
        local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgWidth-20,contentHeight-20),nil)
        -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
        tv:setPosition(ccp(10,50))
        backSprie:addChild(tv,2)
        tv:setMaxDisToBottomOrTop(80)
        self.tvTab[index+1]=tv
    end
end

function vipDialogFinal:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
        if index==0 then
            if self.isShowVipReward==true then
                tabBtnItem:setPosition(self.bgSize.width/2-tabBtnItem:getContentSize().width/2-2,self.bgSize.height-tabBtnItem:getContentSize().height/2-266-10)
            else
                tabBtnItem:setPosition(10000,0)
            end
            -- tabBtnItem:setScale(0.96)
        elseif index==1 then
            if self.isShowVipReward==true then
                tabBtnItem:setPosition(self.bgSize.width/2+tabBtnItem:getContentSize().width/2+2,self.bgSize.height-tabBtnItem:getContentSize().height/2-266-10)
            else
                tabBtnItem:setPosition(10000,0)
            end
            -- tabBtnItem:setScale(0.96)
        end
        if index==self.selectedTabIndex then
            tabBtnItem:setEnabled(false)
        end 
        index=index+1
    end
end

function vipDialogFinal:tabClick(idx)
    if newGuidMgr:isNewGuiding() then --新手引导
        do
            return
        end
    end
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx         
         else
            v:setEnabled(true)
         end
    end
    
    if idx==1 then
        if self.tv2==nil then
            local function callBack2(...)
                return self:eventHandler2(...)
            end
            local hd= LuaEventHandler:createHandler(callBack2)
            self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.panelLineBg:getContentSize().width-20,self.panelLineBg:getContentSize().height-10),nil)
            self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
            self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
            self.tv2:setAnchorPoint(ccp(0.5,1))
            self.tv2:setPosition(ccp(9000,0))

            -- self.panelLineBg:addChild(self.tv2)
            self.bgLayer:addChild(self.tv2)
            self.tv2:setMaxDisToBottomOrTop(80)
            self.tv2:setVisible(false)

            if self.cellNum==0 and playerVoApi:getVipLevel() == self.vipNum-1 then
                local  showAllLb= GetTTFLabelWrap(getlocal("vip_tequanlibao_allready_des"),30,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                showAllLb:setColor(G_ColorYellow)
                showAllLb:setAnchorPoint(ccp(0.5,0.5))
                showAllLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2))
                self.panelLineBg:addChild(showAllLb)
                self.showAllLb=showAllLb
                if self.tv2:isVisible()==true then
                    self.showAllLb:setVisible(true)
                else
                    self.showAllLb:setVisible(false)
                end
            end
        end


        if self.vipPageDialog and self.list then
            self.vipPageDialog:setEnabled(false)
            for k,v in pairs(self.list) do
                if v and v.setPosition then
                    v:setPosition(ccp(10000,0))
                end
            end
        end
        if self.pageFlagList then
            for k,v in pairs(self.pageFlagList) do
                if v and v.setVisible then
                    v:setVisible(false)
                end
            end
        end
        if self.curPageFlag then
            self.curPageFlag:setVisible(false)
        end
        -- self.tv:setVisible(false)
        self.tv2:setVisible(true)
        -- self.tv2:setPosition(ccp(self.panelLineBg:getContentSize().width/2-self.tv2:getContentSize().width/2,5))
        self.tv2:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.tv2:getContentSize().width/2,self.bgy))
        -- self.tv:setPosition(ccp(9000,0))
        self:refreshVisible()
    elseif idx==0 then
        -- self.tv:setVisible(true)
        -- -- self.tv:setPosition(ccp(self.panelLineBg:getContentSize().width/2-self.tv:getContentSize().width/2,5))
        -- -- self.tv:setPosition(ccp(self.bgLayer:getContentSize().width/2-self.tv:getContentSize().width/2,self.bgy))
        -- self.tv:setPosition(ccp(30,92))

        if self.vipPageDialog and self.list then
            self.vipPageDialog:setEnabled(true)
            for k,v in pairs(self.list) do
                if v and v.setPosition then
                    if self.page==k then
                        v:setPosition(ccp(0,0))
                    else
                        v:setPosition(ccp(10000,0))
                    end
                end
            end
        end
        if self.pageFlagList then
            for k,v in pairs(self.pageFlagList) do
                if v and v.setVisible then
                    v:setVisible(true)
                end
            end
        end
        if self.curPageFlag then
            self.curPageFlag:setVisible(true)
        end
        if self.tv2 then
            self.tv2:setVisible(false)
            self.tv2:setPosition(ccp(9000,0))
        end
        self:refreshVisible()
    end
end

function vipDialogFinal:refreshVisible()
    if self.tv2 then
        if self.cellNum==0 and playerVoApi:getVipLevel() == self.vipNum-1 and self.tv2:isVisible()==true then
            if self.showAllLb then
                self.showAllLb:setVisible(true)
            else
                local  showAllLb= GetTTFLabelWrap(getlocal("vip_tequanlibao_allready_des"),30,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                showAllLb:setColor(G_ColorYellow)
                showAllLb:setAnchorPoint(ccp(0.5,0.5))
                showAllLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.panelLineBg:getContentSize().height/2))
                self.panelLineBg:addChild(showAllLb)
                self.showAllLb=showAllLb
            end             
        end
        if self.tv2:isVisible()==false then
            if self.showAllLb then
                self.showAllLb:setVisible(false)
            end
        end
    end
end

function vipDialogFinal:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local vipLevel=playerVoApi:getVipLevel()
        local vf = vipVoApi:getVf()
        local subNum = SizeOfTable(vf)
        self.cellNum = 0
        if vipLevel+1>(self.vipNum-1) then
            self.cellNum = vipLevel*2+2-subNum
        elseif vipLevel+2>(self.vipNum-1) then
            self.cellNum = (vipLevel+1)*2+2-subNum
        else
            self.cellNum = (vipLevel+2)*2+2-subNum
        end
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        self.tv2CellHeight = 180
        -- self.tv2CellBsHeight =0.6
        -- self.tv2CellBtnUpStrHeight =50
        -- self.tv2cellBtnHeight =0
        -- if G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        --     self.tv2CellHeight =270
        -- elseif G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage() =="ru" or G_getCurChoseLanguage() =="in" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage() =="tu" then
        --     self.tv2CellHeight =380
        --     self.tv2CellBsHeight =0.7
        --     self.tv2CellBtnUpStrHeight =80
        --     self.tv2cellBtnHeight =50
        -- end
        local tempSize = CCSizeMake(400,self.tv2CellHeight)
        return tempSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease() 
        local function touch(hd,fn,idx)
        end
        local vipBgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("VipLineYellow.png",CCRect(20, 20, 10, 10),touch)
        local strHeight = self.tv2CellHeight-50
        vipBgSprie:setContentSize(CCSizeMake(580,strHeight))
        vipBgSprie:ignoreAnchorPointForPosition(false)
        vipBgSprie:setAnchorPoint(ccp(0,0))
        vipBgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
        vipBgSprie:setPosition(ccp(0,10))
        cell:addChild(vipBgSprie,1)


        local RewardList = vipVoApi:getVipReward(idx+1)
        local reward=FormatItem(RewardList,false,true) or {}
        local flick=vipVoApi:getVipRewardFlick(idx+1)

        local vipTitleBg = CCSprite:createWithSpriteFrameName("vipFadeBg.png")
        vipTitleBg:setAnchorPoint(ccp(0,0))
        vipTitleBg:setPosition(ccp(10,vipBgSprie:getContentSize().height))
        vipTitleBg:setScaleY(40/vipTitleBg:getContentSize().height)
        vipBgSprie:addChild(vipTitleBg)
        local str =  reward[1].name 
        local titleLb = GetTTFLabel(str,24,true)
        titleLb:setAnchorPoint(ccp(0,0))
        titleLb:setPosition(ccp(15,vipBgSprie:getContentSize().height+5))
        titleLb:setColor(G_ColorYellow)
        vipBgSprie:addChild(titleLb,1)


        local RewardList = vipVoApi:getVipContent(idx+1)
        local reward=FormatItem(RewardList,false,true) or {}
        for k,v in pairs(reward) do
            local icon,scale=G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv2)
            icon:setPosition(ccp(80+120*(k-1),vipBgSprie:getContentSize().height/2))
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            vipBgSprie:addChild(icon,1)
            local numLb=GetTTFLabel("x"..FormatNumber(v.num),25)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(icon:getContentSize().width-5*(1/scale),5*(1/scale)))
            numLb:setScale(1/scale)
            icon:addChild(numLb)
            if flick and flick[k] and flick[k]==1 then
                G_addRectFlicker(icon,1.4*(1/scale),1.4*(1/scale))
            end
        end


        local function onConfirmSell(tag,object)
            if self.tv2:getIsScrolled()==true then
                do return end
            end
            PlayEffect(audioCfg.mouseClick)
            
            local needVipLv=vipVoApi:getVip(idx+1)
            if needVipLv> playerVoApi:getVipLevel() then
                local tipStr=""--getlocal("vip_tequanlibao_tip1")
                if vipVoApi:getPrice(idx+1)==0 then
                    tipStr=getlocal("vip_tequanlibao_lingqu",{needVipLv})
                else
                    tipStr=getlocal("vip_tequanlibao_goumai",{needVipLv})
                end
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,30)
                return
            end

            if playerVoApi:getGems()<vipVoApi:getPrice(idx+1) then
                GemsNotEnoughDialog(nil,nil,vipVoApi:getPrice(idx+1)-playerVoApi:getGems(),self.layerNum+1,vipVoApi:getPrice(idx+1))
                return
            else
                local function goumaiOrLingquCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        -- local RewardList = vipVoApi:getVipContent(idx+1)
                        -- local reward=FormatItem(RewardList,false,true) or {}     
                        -- for k,v in pairs(reward) do
                        --   G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        -- end
                        local libaoList = vipVoApi:getVipReward(idx+1,false,true)
                        local libaoReward = FormatItem(libaoList,false,true) or {} 
                        for k,v in pairs(libaoReward) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                        end

                        if vipVoApi:getPrice(idx+1)==0 then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("vip_tequanlibao_goumai_success"),30)
                        end

                        playerVoApi:setValue("gems",playerVoApi:getGems()-vipVoApi:getPrice(idx+1))
                        vipVoApi:InsertVf(vipVoApi:getId(idx+1))
                        local vf = vipVoApi:getVf(vf)
                        for k,v in pairs(vf) do
                            vipVoApi:setRealReward(v)
                        end 
                        self.tv2:reloadData()
                        self:refreshVisible()
                    end
                end
                socketHelper:vipgiftLingquOrGoumai(vipVoApi:getId(idx+1),goumaiOrLingquCallback)
                return
            end          
                 
        end
        local btnPosx=vipBgSprie:getContentSize().width-90
        local okItem
        local str=getlocal("buy")
        if vipVoApi:getPrice(idx+1)==0 then
            str=getlocal("daily_scene_get")
        end

        if vipVoApi:getVip(idx+1)<= playerVoApi:getVipLevel() then
            okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirmSell,101,str,25,100)
            -- self.tv2cellBtnHeight =0
        else
            okItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",onConfirmSell,102,str,25,100)
        end
        local lb = okItem:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb, "CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        
        okItem:setScale(0.8)
        local okBtn=CCMenu:createWithItem(okItem)
        okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        okBtn:setAnchorPoint(ccp(1,0.5))
        -- okBtn:setPosition(vipBgSprie:getContentSize().width-70,vipBgSprie:getContentSize().height*0.5-self.tv2cellBtnHeight)
        okBtn:setPosition(ccp(btnPosx,40))
        vipBgSprie:addChild(okBtn)


        -- local desTv, desLabel = G_LabelTableView(CCSizeMake(230, backSprie:getContentSize().height*0.9),getlocal(reward[1].desc),25,kCCTextAlignmentLeft)
        -- backSprie:addChild(desTv,1)
        -- desTv:setPosition(ccp(5,10))
        -- desTv:setAnchorPoint(ccp(0.5,1))
        -- desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
        -- desTv:setMaxDisToBottomOrTop(100)

        
        local lbPosx=btnPosx-15
        local goldIconPosx=btnPosx+30
        local realLbPosy=vipBgSprie:getContentSize().height-20
        local realLb = GetTTFLabel(vipVoApi:getRealPrice(idx+1),20)
        realLb:setAnchorPoint(ccp(0.5,0.5))
        realLb:setPosition(ccp(lbPosx,realLbPosy))
        vipBgSprie:addChild(realLb)

        local realCost = CCSprite:createWithSpriteFrameName("IconGold.png")
        realCost:setAnchorPoint(ccp(0.5,0.5))
        realCost:setPosition(ccp(goldIconPosx,realLbPosy))
        vipBgSprie:addChild(realCost)

        local redLine = CCSprite:createWithSpriteFrameName("redline.jpg")
        redLine:setAnchorPoint(ccp(0.5,0.5))
        redLine:setScaleX(100/redLine:getContentSize().width)
        redLine:setPosition(ccp(btnPosx,realLbPosy))
        vipBgSprie:addChild(redLine,1)

        local disPosy=vipBgSprie:getContentSize().height/2+18
        if vipVoApi:getPrice(idx+1)~=0 then
            local dazheLb = GetTTFLabel(vipVoApi:getPrice(idx+1),20)
            dazheLb:setAnchorPoint(ccp(0.5,0.5))
            dazheLb:setPosition(ccp(lbPosx,disPosy))
            dazheLb:setColor(G_ColorYellowPro)
            vipBgSprie:addChild(dazheLb)

            local dazheCost = CCSprite:createWithSpriteFrameName("IconGold.png")
            dazheCost:setAnchorPoint(ccp(0.5,0.5))
            dazheCost:setPosition(ccp(goldIconPosx,disPosy))
            vipBgSprie:addChild(dazheCost)
        else
            local freeLb = GetTTFLabel(getlocal("daily_lotto_tip_2"),20)
            freeLb:setAnchorPoint(ccp(0.5,0.5))
            freeLb:setPosition(ccp(btnPosx,disPosy))
            freeLb:setColor(G_ColorYellowPro)
            vipBgSprie:addChild(freeLb)
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

--用户处理特殊需求,没有可以不写此方法
function vipDialogFinal:doUserHandler()
    --[[
    if self.buygems==nil then
    self.buygems=playerVoApi:getBuygems()
    end
    ]]
    if self.buygems~=playerVoApi:getVipExp() then
        self.buygems=playerVoApi:getVipExp()	

        self:updateVipSchedule()
    end

    if self.rechargeBtn==nil or self.menuRecharge==nil then
        local function touch1(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            end
            PlayEffect(audioCfg.mouseClick)
            vipVoApi:showRechargeDialog(self.layerNum+1)
            self:close()
        end
        self.rechargeBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touch1,nil,getlocal("moreMoney"),30,100)
        self.menuRecharge=CCMenu:createWithItem(self.rechargeBtn);
        self.menuRecharge:setPosition(ccp(self.bgLayer:getContentSize().width/2,45))
        self.menuRecharge:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(self.menuRecharge,2)
        local lb = self.rechargeBtn:getChildByTag(100)
        if lb then
            lb = tolua.cast(lb,"CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
    end

    if self.isShowVipReward==true and self.allTabs and self.allTabs[2] then
        local num=vipVoApi:getCanRewardNum()
        -- print("self.rewardNum,num",self.rewardNum,num)
        if self.rewardNum~=num then
            self.rewardNum=num
            if num>0 then
                self:setTipsVisibleByIdx(true,2,num)
            else
                self:setTipsVisibleByIdx(false,2,num)
            end
        end
    end
end

function vipDialogFinal:tick()
    if(self.fixVip~=true)then
        self.fixVip=true
        local gem4vipCfg=Split(G_getPlatVipCfg(),",")
        local fixVip=0
        local vipExp=tonumber(playerVoApi:getVipExp()) or 0
        local maxVip=tonumber(playerVoApi:getMaxLvByKey("maxVip"))
        for i=1,maxVip do
            if(tonumber(gem4vipCfg[i])<=vipExp)then
                fixVip=i
            else
                break
            end
        end
        if(fixVip~=tonumber(playerVoApi:getVipLevel()))then
            local function callback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    self:updateVipSchedule()
                end
            end
            socketHelper:userefvip(callback)            
        end
    end
    self:doUserHandler()
end

function vipDialogFinal:updateVipSchedule()
    local vipLevel=playerVoApi:getVipLevel()
    local vipLevelCfg=Split(playerCfg.vipLevel,",")
    local gem4vipCfg=Split(G_getPlatVipCfg(),",")
    if self.vipIcon then
        self.curVipLevel=0
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            if self.vipLevelLabel==nil then
                local textSize = 30
                -- if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                --     textSize=25
                -- end
                self.vipLevelLabel=GetTTFLabel(getlocal("VIPStr1",{vipLevel}),textSize)
                self.vipLevelLabel:setAnchorPoint(ccp(0.5,0.5))
                self.vipLevelLabel:setPosition(getCenterPoint(self.vipIcon))
                self.vipIcon:addChild(self.vipLevelLabel,1)
            else
                self.vipLevelLabel:setString(getlocal("VIPStr1",{vipLevel}))
            end
        else
            if self.vipLevelLabel==nil or self.curVipLevel~=vipLevel then
                if self.curVipLevel~=vipLevel then
                    if self.vipLevelLabel then
                        self.vipLevelLabel:removeFromParentAndCleanup(true)
                        self.vipLevelLabel=nil
                    end
                end
                self.vipLevelLabel=CCSprite:createWithSpriteFrameName("chatVip"..(vipLevel)..".png")
                self.vipLevelLabel:setAnchorPoint(ccp(0.5,0.5))
                self.vipLevelLabel:setPosition(getCenterPoint(self.vipIcon))
                self.vipLevelLabel:setScale(1.2)
                self.vipIcon:addChild(self.vipLevelLabel,1)
                self.curVipLevel=vipLevel
            end
        end
  	end
  	local offHeight = -10
  	--[[if G_country == "tw" then
  		offHeight = 10
  		end]]
  	if self.timerSprite==nil and self.vipBgSprie then
    		-- AddProgramTimer(self.vipBgSprie,ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-55+offHeight),10,nil,nil,"VipIconYellowBarBg.png","VipIconYellowBar.png",11)
        AddProgramTimer(self.vipBgSprie,ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-55+offHeight),10,12,"","vipBarBg.png","vipBar.png",11,nil,nil,nil,nil,nil,ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-55+offHeight-4.5))
    		self.timerSprite = tolua.cast(self.vipBgSprie:getChildByTag(10),"CCProgressTimer")
  	end
  	if self.timerSprite then
        local needGems,buyGems=0,0
		local percentage=0
		if tonumber(vipLevel) >= tonumber(vipLevelCfg[SizeOfTable(vipLevelCfg)]) then
  			percentage=1
		else
  			local curLevelGems=0
  			if vipLevel>0 then
  			    curLevelGems=gem4vipCfg[vipLevel]
  			end
  			local nextLevelGems=gem4vipCfg[vipLevel+1]
            if(nextLevelGems)then
  			    needGems=nextLevelGems-curLevelGems
                buyGems=playerVoApi:getVipExp()-curLevelGems
                percentage=buyGems/needGems
            else
                percentage=1
            end
		end
		if percentage<0 then
  			percentage=0
		end
		if percentage>1 then
  			percentage=1
		end
		self.timerSprite:setPercentage(percentage*100)
        if tonumber(vipLevel) >= tonumber(playerVoApi:getMaxLvByKey("maxVip")) or tonumber(vipLevel) >= tonumber(vipLevelCfg[SizeOfTable(vipLevelCfg)])  then
            self.timerSprite:setPercentage(100)
        end
        local lb=tolua.cast(self.timerSprite:getChildByTag(12),"CCLabelTTF")
        if lb then
            if tonumber(vipLevel) >= tonumber(playerVoApi:getMaxLvByKey("maxVip")) or tonumber(vipLevel) >= tonumber(vipLevelCfg[SizeOfTable(vipLevelCfg)]) then
                local curLevelGems=tonumber(gem4vipCfg[tonumber(vipLevel)])
                needGems=curLevelGems
                lb:setString(getlocal("scheduleChapter",{needGems,needGems}))
            else
                lb:setString(getlocal("scheduleChapter",{buyGems,needGems}))
            end
        end
    end
  	
    local vipStr = ""
    local isUseRichLb=false
    local vipStrTmp=""
    local isMaxLevel=false
    if tonumber(vipLevel) >= tonumber(playerVoApi:getMaxLvByKey("maxVip")) or tonumber(vipLevel) >= tonumber(vipLevelCfg[SizeOfTable(vipLevelCfg)]) then
        vipStr = getlocal("richMan")
        isMaxLevel=true
    else
        local nextVip=vipLevel+1
        local nextGem=gem4vipCfg[nextVip]
        local needGem=nextGem-self.buygems
        --vipStr = getlocal("currentVip",{vipLevel})
        -- vipStr = vipStr..getlocal("nextVip",{needGem,nextVip}).."\n"..getlocal("notInclude")
        if G_isShowRichLabel()==true then
            isUseRichLb=true
            vipStr = vipStr..getlocal("nextVip2",{"<rayimg>"..needGem.."<rayimg>","<rayimg>VIP"..nextVip.."<rayimg>"})
        else
            vipStr = vipStr..getlocal("nextVip2",{needGem,"VIP"..nextVip})
        end
    end
  	if self.vipBgSprie then
        local textSize=22
        local subPosY = 50
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ru" then
            textSize=self.fontSize
            subPosY = 38
        end
        textSize = 20 --文字优化修改
        if self.vipDescLabel then
            self.vipDescLabel:removeFromParentAndCleanup(true)
        end
        local colorTab={G_ColorWhite,G_ColorYellowPro,G_ColorWhite,G_ColorYellowPro,G_ColorWhite}
        self.vipDescLabel=G_getRichTextLabel(vipStr,colorTab,textSize,self.vipBgSprie:getContentSize().width-40,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        self.vipDescLabel:setAnchorPoint(ccp(0.5,1))
        self.vipDescLabel:setPosition(ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-75+offHeight-4))
        self.vipBgSprie:addChild(self.vipDescLabel,1)

        if self.notIncludeLb==nil then
            self.notIncludeLb=GetTTFLabel(getlocal("notInclude"),textSize)
            self.notIncludeLb:setAnchorPoint(ccp(0.5,1))
            self.notIncludeLb:setPosition(ccp(self.vipBgSprie:getContentSize().width/2,self.vipBgSprie:getContentSize().height-75+offHeight-subPosY))
            self.vipBgSprie:addChild(self.notIncludeLb,1)
        end
        if isMaxLevel==true then
            self.notIncludeLb:setVisible(false)
        end
  	end
end

--idx：vip等级
--str：文字
--value：类型为string，是配置；类型为table，是文字参数
--prop：获取的配置的值的调整数值
--idxProp：配置取第几个值的调整数值
--isRich：是否使用富文本
function vipDialogFinal:formatVipStr(idx,str,value,prop,idxProp,isRich)
    if prop==nil then prop=0 end
    if idxProp==nil then idxProp=0 end
    if value then
        if type(value)=="string" then
            if G_isShowRichLabel()==true and isRich==true then
                return getlocal(str,{"<rayimg>"..(Split(value,",")[idx+1+idxProp]+prop).."<rayimg>"})
            else
                return getlocal(str,{Split(value,",")[idx+1+idxProp]+prop})
            end
        elseif type(value)=="table" then
            if G_isShowRichLabel()==true and isRich==true then
                local tb={}
                for k,v in pairs(value) do
                    if v then
                        table.insert(tb,"<rayimg>"..v.."<rayimg>")
                    end
                end
                return getlocal(str,tb)
            else
                return getlocal(str,value)
            end
        end
    end
    return getlocal(str)
end

function vipDialogFinal:getCellHeight(idx)
    local num,strData,height=0,{},{}
    if self.heightTab[idx+1] then
        num=self.heightTab[idx+1].num
        strData=self.heightTab[idx+1].strData
        height=self.heightTab[idx+1].height
    else
        self.heightTab[idx+1]={}
        local function getVipLocal(str,value,prop,idxProp,isRich)
            local vipLocalStr=self:formatVipStr(idx,str,value,prop,idxProp,isRich)
            return vipLocalStr
        end
        --vIdx：第几项文字描述(VIPStr1,VIPStr2...)
        --dType：1.num根据具体值变化，2.cfg取配置的值变化
        --num：根据num值判断是否有变化
        --cfg：根据cfg配置获取的值判断是否有变化
        --key：配置的key
        local function insertVipData(vIdx,dType,tb,str,num,cfg,key)
            if tb and str and vIdx then
                local curLv=playerVoApi:getVipLevel()
                local isUp=false
                local tmpCfg={}
                if cfg then
                    if type(cfg)=="string" then
                        tmpCfg=Split(cfg,",")
                    else
                        tmpCfg=cfg
                    end
                    -- if idx>0 then
                        local selfNum
                        local curNum
                        if key then
                            selfNum=tonumber(tmpCfg[key..curLv]) or 0
                        else
                            selfNum=tonumber(tmpCfg[curLv+1]) or 0
                        end
                        if key then
                            curNum=tonumber(tmpCfg[key..idx]) or 0
                        else
                            curNum=tonumber(tmpCfg[idx+1]) or 0
                        end
                        if selfNum and curNum and curNum>selfNum then
                            isUp=true
                        end
                    -- end
                end
                
                if dType==1 and num then
                    if curLv>=idx then
                        str=string.gsub(str,"<rayimg>","")
                        table.insert(tb,{str,nil,false,playerCfg.vipSortCfg[vIdx].sortId})
                    -- elseif idx==num then
                    elseif curLv<num then
                        str=string.gsub(str,"<rayimg>","")
                        table.insert(tb,{str,G_ColorYellowPro,isUp,playerCfg.vipSortCfg[vIdx].sortId})
                    else
                        if isUp==false then
                            str=string.gsub(str,"<rayimg>","")
                        end
                        table.insert(tb,{str,nil,isUp,playerCfg.vipSortCfg[vIdx].sortId})
                    end
                elseif dType==2 and tmpCfg then
                    local isNew=false
                    -- if idx>0 then
                    --     local lastNum=tonumber(tmpCfg[idx]) or 0
                        local selfNum=tonumber(tmpCfg[curLv+1]) or 0
                        if selfNum then
                            if selfNum==0 then
                                isNew=true
                            end
                        end
                    -- end
                    if curLv>=idx then
                        str=string.gsub(str,"<rayimg>","")
                        table.insert(tb,{str,nil,false,playerCfg.vipSortCfg[vIdx].sortId})
                    elseif isNew==true then
                        str=string.gsub(str,"<rayimg>","")
                        table.insert(tb,{str,G_ColorYellowPro,isUp,playerCfg.vipSortCfg[vIdx].sortId})
                    else
                        if isUp==false then
                            str=string.gsub(str,"<rayimg>","")
                        end
                        table.insert(tb,{str,nil,isUp,playerCfg.vipSortCfg[vIdx].sortId})
                    end
                end
            end
        end
        local data={}
        local vipData={}
        if idx==0 then
            local vStr2,vStr4,vStr5,vStr7--=getVipLocal("VIPStr2"),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr5"),getVipLocal("VIPStr7",playerCfg.actionFleets)
            -- data = {vStr4,vStr7}
            vStr4,vStr7=getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue,nil,nil,true),getVipLocal("VIPStr7",playerCfg.actionFleets,nil,nil,true)
            insertVipData(4,1,vipData,vStr4,-1,playerCfg.vip4DailyBuyEnergyQueue)
            insertVipData(7,1,vipData,vStr7,-1,playerCfg.actionFleets)
        elseif idx>0 then
            if G_getCurChoseLanguage()=="ru" then
                local vStr3,vStr4,vStr6,vStr7--=getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets)
                -- data = {vStr3,vStr4,vStr6,vStr7}
                vStr3,vStr4,vStr6,vStr7=getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2,nil,true),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue,nil,nil,true),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue,nil,nil,true),getVipLocal("VIPStr7",playerCfg.actionFleets,nil,nil,true)
                insertVipData(3,1,vipData,vStr3,1,playerCfg.vip4BuildQueue)
                insertVipData(4,1,vipData,vStr4,-1,playerCfg.vip4DailyBuyEnergyQueue)
                insertVipData(6,1,vipData,vStr6,1,playerCfg.vip4BuildQueue)
                insertVipData(7,1,vipData,vStr7,-1,playerCfg.actionFleets)
            else
                local vStr3,vStr4,vStr6,vStr7--=getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue),getVipLocal("VIPStr7",playerCfg.actionFleets)
                -- data = {vStr3,vStr4,vStr6,vStr7}
                vStr3,vStr4,vStr6,vStr7=getVipLocal("VIPStr3",playerCfg.vip4BuildQueue,-2,nil,true),getVipLocal("VIPStr4",playerCfg.vip4DailyBuyEnergyQueue,nil,nil,true),getVipLocal("VIPStr6",playerCfg.vip4BuildQueue,nil,nil,true),getVipLocal("VIPStr7",playerCfg.actionFleets,nil,nil,true)
                insertVipData(3,1,vipData,vStr3,1,playerCfg.vip4BuildQueue)
                insertVipData(4,1,vipData,vStr4,-1,playerCfg.vip4DailyBuyEnergyQueue)
                insertVipData(6,1,vipData,vStr6,1,playerCfg.vip4BuildQueue)
                insertVipData(7,1,vipData,vStr7,-1,playerCfg.actionFleets)
            end
        end
        if eliteChallengeCfg and base.ifAccessoryOpen==1 then
            if eliteChallengeCfg.resetNum and eliteChallengeCfg.resetNum[idx+1] then
                local ecResetNum=eliteChallengeCfg.resetNum[idx+1]
                if ecResetNum and ecResetNum>0 then
                    local vStr10--=getVipLocal("VIPStr10",{ecResetNum})
                    -- table.insert(data,vStr10)
                    vStr10=getVipLocal("VIPStr10",{ecResetNum},nil,nil,true)
                    insertVipData(10,2,vipData,vStr10,nil,eliteChallengeCfg.resetNum)
                end
            end
        end

        if arenaCfg and base.ifMilitaryOpen==1 then
            local key = "vip"..idx
            local lastKey = "vip"..(idx-1)
            local num
            local cfg
            if base.ma==1 then
                num =arenaCfg.buyChallengingTimes2[key]
                cfg=arenaCfg.buyChallengingTimes2
            else
                num =arenaCfg.buyChallengingTimes[key]
                cfg=arenaCfg.buyChallengingTimes
            end
            local vStr11--=getVipLocal("VIPStr11",{num})
            -- table.insert(data,vStr11)
            vStr11=getVipLocal("VIPStr11",{num},nil,nil,true)
            insertVipData(11,1,vipData,vStr11,-1,cfg,"vip")
        end

        --vip相关的其他配置
        -- vipRelatedCfg={
        --     createAllianceGems={1,0},   --vip1以上:用金币建立军团免费
        --     addCreateProps={2,6},       -- vip2以上:装置车间增加可制作物品：5种中型资源开采，急速前行
        --     raidEliteChallenge={4,1},   --vip4以上:自动扫荡补给线
        --     freeSeniorLotteryNum={5,1}, --vip5以上:高级抽奖每日免费一次
        --     protectResources={7,2},     --vip7以上:仓库资源保护量加倍*2
        --     donateAddNum={9,2},         --vip9以上:每日捐献次数上限增加2次
        -- },
        local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
        local createAllianceGems=vipRelatedCfg.createAllianceGems or {}
        local addCreateProps=vipRelatedCfg.addCreateProps or {}
        local raidEliteChallenge=vipRelatedCfg.raidEliteChallenge or {}
        local freeSeniorLotteryNum=vipRelatedCfg.freeSeniorLotteryNum or {}
        local protectResources=vipRelatedCfg.protectResources or {}
        local donateAddNum=vipRelatedCfg.donateAddNum or {}
        local dailySign=vipRelatedCfg.dailySign or {}

        local vipPrivilegeSwitch=base.vipPrivilegeSwitch or {}
        if idx>=createAllianceGems[1] then
            local vStr29--=getVipLocal("VIPStr29")
            -- table.insert(data,vStr29)
            vStr29=getVipLocal("VIPStr29",nil,nil,nil,true)
            insertVipData(29,1,vipData,vStr29,1)
        end
         
        --创建军团不花金币
        if vipPrivilegeSwitch.vca==1 then
            if createAllianceGems[1] and idx>=createAllianceGems[1] then
                local vStr12--=getVipLocal("VIPStr12")
                -- table.insert(data,vStr12)
                vStr12=getVipLocal("VIPStr12",nil,nil,nil,true)
                insertVipData(12,1,vipData,vStr12,createAllianceGems[1])
            end
        end
        -- vip 增加战斗经验
        if vipPrivilegeSwitch.vax==1 then
            if playerCfg.vipForAddExp[idx+1] and playerCfg.vipForAddExp[idx+1]>0 then
                local vStr13--=getVipLocal("VIPStr13",{(playerCfg.vipForAddExp[idx+1]*100).."%%"})
                -- table.insert(data,vStr13)
                vStr13=getVipLocal("VIPStr13",{(playerCfg.vipForAddExp[idx+1]*100).."%%"},nil,nil,true)
                insertVipData(13,2,vipData,vStr13,nil,playerCfg.vipForAddExp)
            end
        end
        --装置车间增加可制造物品
        if vipPrivilegeSwitch.vap==1 then
            if idx>=addCreateProps[1] then
                local vStr14--=getVipLocal("VIPStr14")
                -- table.insert(data,vStr14)
                vStr14=getVipLocal("VIPStr14",nil,nil,nil,true)
                insertVipData(14,1,vipData,vStr14,addCreateProps[1])
            end
        end
        --配件合成概率提高
        if vipPrivilegeSwitch.vea==1 then
            if playerCfg.vipForEquipStrengthenRate[idx+1] and playerCfg.vipForEquipStrengthenRate[idx+1]>0 then
                local vStr15--=getVipLocal("VIPStr15",{(playerCfg.vipForEquipStrengthenRate[idx+1]*100).."%%"})
                -- table.insert(data,vStr15)
                vStr15=getVipLocal("VIPStr15",{(playerCfg.vipForEquipStrengthenRate[idx+1]*100).."%%"},nil,nil,true)
                insertVipData(15,2,vipData,vStr15,nil,playerCfg.vipForEquipStrengthenRate)
            end
        end
        --精英副本扫荡
        if vipPrivilegeSwitch.vec==1 then
            if idx>=raidEliteChallenge[1] and base.ifAccessoryOpen==1 then
                local vStr16--=getVipLocal("VIPStr16")
                -- table.insert(data,vStr16)
                vStr16=getVipLocal("VIPStr16",nil,nil,nil,true)
                insertVipData(16,1,vipData,vStr16,raidEliteChallenge[1])
            end
        end
        --高级抽奖每日免费1次
        if vipPrivilegeSwitch.vfn==1 then
            if FuncSwitchApi:isEnabled("luck_lottery") == true and idx>=freeSeniorLotteryNum[1] then
                local str --= getVipLocal("VIPStr17")
                -- if G_getBHVersion()==2 then
                --     str = getVipLocal("newVIPStr17")
                -- end
                -- table.insert(data,str)
                str = getVipLocal("VIPStr17",nil,nil,nil,true)
                if G_getBHVersion()==2 then
                    str = getVipLocal("newVIPStr17",nil,nil,nil,true)
                end
                insertVipData(17,1,vipData,str,freeSeniorLotteryNum[1])
            end
        end
        --仓库保护资源量
        if vipPrivilegeSwitch.vps==1 then
            if idx>=protectResources[1] then
                local vStr18--=getVipLocal("VIPStr18")
                -- table.insert(data,vStr18)
                vStr18=getVipLocal("VIPStr18",nil,nil,nil,true)
                insertVipData(18,1,vipData,vStr18,protectResources[1])
            end
        end
        --每日捐献次数上限
        if vipPrivilegeSwitch.vdn==1 then
            if idx>=donateAddNum[1] and base.isAllianceSkillSwitch==1 then
                local addNum=donateAddNum[2]
                if addNum>0 then
                    local vStr19--=getVipLocal("VIPStr19",{addNum})
                    -- table.insert(data,vStr19)
                    vStr19=getVipLocal("VIPStr19",{addNum},nil,nil,true)
                    insertVipData(19,1,vipData,vStr19,donateAddNum[1])
                end
            end
        end
        --每日签到双倍奖励
        if(vipPrivilegeSwitch.vsr==1)then
            if base.isSignSwitch==1 and idx>=dailySign[1] then
                local addNum=dailySign[2]
                if(addNum>1)then
                    local vStr34--=getVipLocal("VIPStr34",{addNum})
                    -- table.insert(data,vStr34)
                    vStr34=getVipLocal("VIPStr34",{addNum},nil,nil,true)
                    insertVipData(34,1,vipData,vStr34,dailySign[1])
                end
            end
        end
        local productTankSpeed=playerCfg.productTankSpeed[idx+1]
        if productTankSpeed>0 then
            local productTankSpeedStr = productTankSpeed*100
            local vStr20--=getVipLocal("VIPStr20",{productTankSpeedStr.."%%"})
            -- table.insert(data,vStr20)
            vStr20=getVipLocal("VIPStr20",{productTankSpeedStr.."%%"},nil,nil,true)
            insertVipData(20,2,vipData,vStr20,nil,playerCfg.productTankSpeed)
        end
        local refitTankSpeed=playerCfg.refitTankSpeed[idx+1]
        if refitTankSpeed>0 then
            local refitTankSpeedStr = refitTankSpeed*100
            local vStr21--=getVipLocal("VIPStr21",{refitTankSpeedStr.."%%"})
            -- table.insert(data,vStr21)
            vStr21=getVipLocal("VIPStr21",{refitTankSpeedStr.."%%"},nil,nil,true)
            insertVipData(21,2,vipData,vStr21,nil,playerCfg.refitTankSpeed)
        end
        local tecSpeed=playerCfg.tecSpeed[idx+1]
        if tecSpeed>0 then
            local tecSpeedStr = tecSpeed*100
            local vStr22--=getVipLocal("VIPStr22",{tecSpeedStr.."%%"})
            -- table.insert(data,vStr22)
            vStr22=getVipLocal("VIPStr22",{tecSpeedStr.."%%"},nil,nil,true)
            insertVipData(22,2,vipData,vStr22,nil,playerCfg.tecSpeed)
        end
        local commandedSpeed=playerCfg.commandedSpeed[idx+1]
        if commandedSpeed>0 then
            local commandedSpeedStr = commandedSpeed*100
            local vStr23--=getVipLocal("VIPStr23",{commandedSpeedStr.."%%"})
            -- table.insert(data,vStr23)
            vStr23=getVipLocal("VIPStr23",{commandedSpeedStr.."%%"},nil,nil,true)
            insertVipData(23,2,vipData,vStr23,nil,playerCfg.commandedSpeed)
        end
        local marchSpeed=playerCfg.marchSpeed[idx+1]
        if marchSpeed>0 then
            local marchSpeedStr = marchSpeed*100
            local vStr24--=getVipLocal("VIPStr24",{marchSpeedStr.."%%"})
            -- table.insert(data,vStr24)
            vStr24=getVipLocal("VIPStr24",{marchSpeedStr.."%%"},nil,nil,true)
            insertVipData(24,2,vipData,vStr24,nil,playerCfg.marchSpeed)
        end
        local warehouseStorage=playerCfg.warehouseStorage[idx+1]
        if warehouseStorage>0 then
            local warehouseStorageStr = warehouseStorage*100
            local vStr25--=getVipLocal("VIPStr25",{warehouseStorageStr.."%%"})
            -- table.insert(data,vStr25)
            vStr25=getVipLocal("VIPStr25",{warehouseStorageStr.."%%"},nil,nil,true)
            insertVipData(25,2,vipData,vStr25,nil,playerCfg.warehouseStorage)
        end
        if  idx>=playerCfg.vipRelatedCfg.allianceDuplicateNum[1] then
            local vStr28--=getVipLocal("VIPStr28")
            -- table.insert(data,vStr28)
            vStr28=getVipLocal("VIPStr28",nil,nil,nil,true)
            insertVipData(28,1,vipData,vStr28,playerCfg.vipRelatedCfg.allianceDuplicateNum[1])
        end
        if  idx>=playerCfg.vipRelatedCfg.storyLoss[1] then
            local storyLoss= playerCfg.vipRelatedCfg.storyLoss[2]*100
            local vStr26--=getVipLocal("VIPStr26",{storyLoss.."%%"})
            -- table.insert(data,vStr26)
            vStr26=getVipLocal("VIPStr26",{storyLoss.."%%"},nil,nil,true)
            insertVipData(26,1,vipData,vStr26,playerCfg.vipRelatedCfg.storyLoss[1])
        end
        
        if  idx>=playerCfg.vipRelatedCfg.storyPhysical[1] then
            local vStr27--=getVipLocal("VIPStr27")
            -- table.insert(data,vStr27)
            vStr27=getVipLocal("VIPStr27",nil,nil,nil,true)
            insertVipData(27,1,vipData,vStr27,playerCfg.vipRelatedCfg.storyPhysical[1])
        end
        if  idx>=9 and base.heroSwitch==1 and base.expeditionSwitch==1 then
            local vStr30--=getVipLocal("VIPStr30")
            -- table.insert(data,vStr30)
            vStr30=getVipLocal("VIPStr30",nil,nil,nil,true)
            insertVipData(30,1,vipData,vStr30,9)
        end
        if base.ifSuperWeaponOpen==1 then
            local resetTab=swChallengeCfg.resetNum
            local maxResetNum=resetTab[idx+1]
            local vStr31--=getVipLocal("VIPStr31",{maxResetNum})
            -- table.insert(data,vStr31)
            vStr31=getVipLocal("VIPStr31",{maxResetNum},nil,nil,true)
            insertVipData(31,1,vipData,vStr31,-1,resetTab)
            local buyTab=swChallengeCfg.challengeBuyNum
            local maxBuyNum=buyTab[idx+1]
            local vStr32--=getVipLocal("VIPStr32",{maxBuyNum})
            -- table.insert(data,vStr32)
            vStr32=getVipLocal("VIPStr32",{maxBuyNum},nil,nil,true)
            insertVipData(32,1,vipData,vStr32,-1,buyTab)
            local energyBuyNumTab=weaponrobCfg.energyGemsBuyNum
            local energyBuyNum=energyBuyNumTab[idx+1]
            local vStr33--=getVipLocal("VIPStr33",{energyBuyNum})
            -- table.insert(data,vStr33)
            vStr33=getVipLocal("VIPStr33",{energyBuyNum},nil,nil,true)
            insertVipData(33,1,vipData,vStr33,-1,energyBuyNumTab)
        end
        if idx>=playerCfg.vipRelatedCfg.hchallengeSweepNeedVip and base.he==1 then
            local vStr35--=getVipLocal("VIPStr35")
            -- table.insert(data,vStr35)
            vStr35=getVipLocal("VIPStr35",nil,nil,nil,true)
            insertVipData(35,1,vipData,vStr35,playerCfg.vipRelatedCfg.hchallengeSweepNeedVip)
        end
        if base.he==1 then
            local resetNum=hChallengeCfg.resetNum[idx+1]
            local vStr36--=getVipLocal("VIPStr36",{resetNum})
            -- table.insert(data,vStr36)
            vStr36=getVipLocal("VIPStr36",{resetNum},nil,nil,true)
            insertVipData(36,1,vipData,vStr36,-1,hChallengeCfg.resetNum)
        end
        -- if idx>=2 then
        --     table.insert(data,getVipLocal("VIPStrInclude",{idx-1}))
        -- end
        -- if idx>=1 then
        --     local vStr8=getVipLocal("VIPStr8",playerCfg.gem4vip,0,-1)
        --     table.insert(data,vStr8)
        --     insertVipData(1,vipData,vStr8,1)
        -- end
        if base.fs==1 then
            local freeTime = playerVoApi:getFreeTime(idx,true)
            if freeTime>0 then
                local str,vIdx1 = self:getFreeTimeStr(freeTime,nil,idx)
                table.insert(data,1,str)
                if G_isShowRichLabel()==true then
                    str,vIdx1 = self:getFreeTimeStr(freeTime,true,idx)
                end
                local isNew=false
                local isUp=false
                local curLv=playerVoApi:getVipLevel()
                local selfNum=playerVoApi:getFreeTime(curLv,true) or 0
                if selfNum then
                    if selfNum==0 then
                        isNew=true
                    end
                    if freeTime>selfNum then
                        isUp=true
                    end
                end
                local curLv=playerVoApi:getVipLevel() 
                if curLv>=idx then
                    str=string.gsub(str,"<rayimg>","")
                    table.insert(vipData,1,{str,nil,false,playerCfg.vipSortCfg[vIdx1].sortId})
                elseif isNew==true then
                    str=string.gsub(str,"<rayimg>","")
                    table.insert(vipData,1,{str,G_ColorYellowPro,isUp,playerCfg.vipSortCfg[vIdx1].sortId})
                else
                    if isUp==false then
                        str=string.gsub(str,"<rayimg>","")
                    end
                    table.insert(vipData,1,{str,nil,isUp,playerCfg.vipSortCfg[vIdx1].sortId})
                end
            end
        end
        --攻打叛军的体力购买次数
        if base.isRebelOpen==1 then
            local vipBuyLimit=rebelCfg.vipBuyLimit[idx+1]
            local vStr40=getVipLocal("VIPStr40",{vipBuyLimit},nil,nil,true)
            insertVipData(40,2,vipData,vStr40,nil,rebelCfg.vipBuyLimit)
        end

        --扫荡关卡
        if base.raids==1 then
            local vipQueue=challengeRaidCfg.vipQueueForShow[idx+1]
            if vipQueue and vipQueue>0 and FuncSwitchApi:isEnabled("elite") == true then
                local vStr41=getVipLocal("VIPStr41",{vipQueue},nil,nil,true)
                insertVipData(41,2,vipData,vStr41,nil,challengeRaidCfg.vipQueueForShow)
            end

            local vipBuyNums=challengeRaidCfg.vipBuyNums[idx+1]
            if vipBuyNums and vipBuyNums>0 then
                local vStr42=getVipLocal("VIPStr42",{vipBuyNums},nil,nil,true)
                insertVipData(42,2,vipData,vStr42,nil,challengeRaidCfg.vipBuyNums)
            end
        end

        if mapScoutCfg and mapScoutCfg.vipScout then
            local vipScoutLimit=mapScoutCfg.vipScout[idx+1]
            local vStr43=getVipLocal("VIPStr43",{vipScoutLimit},nil,nil,true)
            insertVipData(43,2,vipData,vStr43,nil,mapScoutCfg.vipScout)
        end
        local maxVip=tonumber(playerVoApi:getMaxLvByKey("maxVip"))
        --要想动态显示增加状态的话，必须要传一个配置过去，配置的格式是{1,1,2…5}这样，因此在这里重新组织一下格式
        if(playerCfg and playerCfg.vipRelatedCfg and playerCfg.vipRelatedCfg.headCfg and FuncSwitchApi:isEnabled("individuation") == true)then
            local tmpCfg={}
            for i=1,maxVip + 1 do
                if(i==1)then
                    tmpCfg[i]=0
                else
                    tmpCfg[i]=tmpCfg[i - 1]
                end
                if(playerCfg.vipRelatedCfg.headCfg[tostring(i - 1)])then
                    tmpCfg[i]=tmpCfg[i] + #playerCfg.vipRelatedCfg.headCfg[tostring(i - 1)]
                end
            end
            if(tmpCfg[idx + 1] and tmpCfg[idx + 1]>0)then
                local vipStr44=getVipLocal("VIPStr44",{tmpCfg[idx + 1]},nil,nil,true)
                insertVipData(44,2,vipData,vipStr44,nil,tmpCfg)
            end
        end
        if(headFrameCfg and headFrameCfg.list and FuncSwitchApi:isEnabled("individuation") == true)then
            local tmpCfg={}
            for i=1,maxVip + 1 do
                tmpCfg[i]=0
            end
            local num=0
            for k,v in pairs(headFrameCfg.list) do
                if(v.vip)then
                    for i=v.vip + 1,maxVip + 1 do
                        tmpCfg[i]=tmpCfg[i] + 1
                    end
                end
            end
            if(tmpCfg[idx + 1] and tmpCfg[idx + 1]>0)then
                local vipStr45=getVipLocal("VIPStr45",{tmpCfg[idx + 1]},nil,nil,true)
                insertVipData(45,2,vipData,vipStr45,nil,tmpCfg)
            end
        end

        local vipStr = ""
        -- local vipCellLabel
        -- for k,v in pairs(data) do
        --     -- vipStr = vipStr .. "\n" .. v
        --     local lb=GetTTFLabelWrap(v,26,CCSizeMake(30*18, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        --     table.insert(height,lb:getContentSize().height+20)
        -- end

        local function sortFunc(a,b)
            if a and b and a[4] and b[4] and a[4]~=b[4] then
                return a[4]<b[4]
            end
        end
        table.sort(vipData,sortFunc)

        for k,v in pairs(vipData) do
            if v and v[1] then
                num=num+1
                local str=v[1]
                local color=v[2]
                local colorTab={}
                if color then
                    colorTab={color}
                else
                    colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite,G_ColorGreen,G_ColorWhite}
                end
                local descLb,lbHeight=G_getRichTextLabel(str,colorTab,20,self.panelLineBg:getContentSize().width-125,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,self.vSpace)
                table.insert(height,lbHeight)
            end
        end
        -- vipCellLabel=GetTTFLabelWrap(vipStr,26,CCSizeMake(30*18, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        -- num=vipCellLabel:getContentSize().height+90
        self.heightTab[idx+1].num=num
        -- self.heightTab[idx+1].data=data
        self.heightTab[idx+1].height=height
        self.heightTab[idx+1].strData=vipData
        strData=vipData
    end
    return num,strData,height
end

function vipDialogFinal:getFreeTimeStr(freeTime,isRich,idx)
    local function getVipLocal(str,value,prop,idxProp,isRich1)
        local vipLocalStr=self:formatVipStr(idx,str,value,prop,idxProp,isRich1)
        return vipLocalStr
    end
    local vIdx=0
    local freeStr=""
    if freeTime<60 then
        freeStr=getVipLocal("VIPStr39",{freeTime})
        if isRich==true then
            freeStr=getVipLocal("VIPStr39",{"<rayimg>"..(freeTime).."<rayimg>"})
        end
        vIdx=39
    elseif freeTime%60==0 then
        freeStr=getVipLocal("VIPStr37",{freeTime/60})
        if isRich==true then
            freeStr=getVipLocal("VIPStr37",{"<rayimg>"..(freeTime/60).."<rayimg>"})
        end
        vIdx=37
    else
        local fen = math.floor(freeTime/60)
        local miao = freeTime%60
        freeStr=getVipLocal("VIPStr38",{fen,miao})
        if isRich==true then
            freeStr=getVipLocal("VIPStr38",{"<rayimg>"..(fen).."<rayimg>","<rayimg>"..(miao).."<rayimg>"})
        end
        vIdx=38
    end
    return freeStr,vIdx
end

function vipDialogFinal:dispose()
    if self.vipPageDialog then
        self.vipPageDialog:dispose()
        self.vipPageDialog=nil
    end
    self.vipLayer=nil
    self.list={}
    self.dlist={}
    self.isShowVipReward=nil
    self.vipDescLabel=nil
    self.rechargeBtn=nil
    self.menuRecharge=nil
    self.buygems=nil
    self.timerSprite=nil
    self.vipBgSprie=nil
    self.vipLevelLabel=nil
    self.vipIcon=nil
    self.expandIdx={}
    self.normalHeight=60
    self.lbTab={}
    self.heightTab={}
    self.notIncludeLb=nil
    self.page=1
    self.curPageFlag=nil
    self.pageFlagList={}
    self.tvTab={}
    self.rewardNum=0
    self.curVipLevel=0
    self.backSpTab={}
    self.fixVip=nil
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage2.plist")
    spriteController:removePlist("public/vipFinal.plist")
    -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/acFirstRechargenew.plist")
    -- CCTextureCache:sharedTextureCache():removeTextureForKey("public/acFirstRechargenew.png")
    -- spriteController:removePlist("public/acChunjiepansheng.plist")
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("serverWar/serverWar.plist")
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    self=nil
end



