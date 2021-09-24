armorMatrixBagDialog=commonDialog:new()

function armorMatrixBagDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    spriteController:addPlist("public/vipFinal.plist")
    self.btnScale1=160/205
    return nc
end

function armorMatrixBagDialog:doUserHandler()

    local function onLoadIcon(fn,icon)
        if self and self.bgLayer and icon then
            self.bgLayer:addChild(icon)
            icon:setScaleX(self.bgLayer:getContentSize().width/icon:getContentSize().width)
            icon:setScaleY((self.bgLayer:getContentSize().height-80)/icon:getContentSize().height)
            icon:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40)
            icon:setOpacity(180)
        end
    end
    local url=G_downloadUrl("active/buyreward/acBuyrewardjpg4.jpg")
    local webImage = LuaCCWebImage:createWithURL(url,onLoadIcon)

	local startH=G_VisibleSizeHeight-90

	local headerH=200
	local headerPosH=startH
	self:initHeader(headerH,headerPosH)

    self.midH=80
    self.midPosH=startH-headerH-10
    

	local bottomH=100
	local bottomPosH=35
    self:initBottom(bottomPosH)

    self.tvPosH=bottomPosH+bottomH
    self.tvHeight=self.midPosH-self.midH-self.tvPosH

    self.panelLineBg:setContentSize(CCSizeMake(600,startH-headerH-30))
    self.panelLineBg:setAnchorPoint(ccp(0,0))
    self.panelLineBg:setPosition(ccp(20,20))
    self.panelLineBg:setVisible(true)
    self.bgLayer:reorderChild(self.panelLineBg,2)
end

--设置对话框里的tableView
function armorMatrixBagDialog:initTableView()
    self.bagList = armorMatrixVoApi:getBagList()
    self.everyCellNum=armorMatrixVoApi:perPageShowNum()

	self.cellNum=SizeOfTable(self.bagList)
    local totalNum=math.ceil(self.cellNum/self.everyCellNum)
    self:expansionRefresh()

    if totalNum>0 then
        self.list={}
        self.dlist={}

        local function pageRefresh()
            self:severanceRefresh()
        end

        require "luascript/script/game/scene/gamedialog/armorMatrix/armorMatrixBagPage"

        
        for i=1,totalNum do
            local bagLayer,bagPage=self:newPageLayer(i,pageRefresh)
            self.bgLayer:addChild(bagLayer,2)
            bagLayer:setPosition(ccp(0,0))

            if i==1 then
                bagPage:initTableView(self.bagList,self.cellNum)
            end

            self.list[i]=bagLayer
            self.dlist[i]=bagPage
        end

        self.pageDialog=pageDialog:new()
        self.page=1

        local isShowBg=false
        local isShowPageBtn=true



        local function onPage(topage)
            self.page=topage
            if self.sbNode then
                local child=self.sbNode:getChildByTag(100+self.page)
                if child then
                    self.curPageFlag:setVisible(true)
                    local posX=child:getPositionX()
                    self.curPageFlag:setPositionX(posX)
                end
            end
        end
        local function movedCallback(turnType,isTouch)
            local page
            if turnType==1 then -- 左
                page=self.page-1
                if page<1 then
                    local totalNum=math.ceil(self.cellNum/self.everyCellNum)
                    page=totalNum
                end
            else
                page=self.page+1
                local totalNum=math.ceil(self.cellNum/self.everyCellNum)
                if page>totalNum then
                    page=1
                end
            end

            if not self.dlist[page].tv then
                self.dlist[page]:initTableView(self.bagList,self.cellNum)
            else
                self.dlist[page]:refresh(self.cellNum,self.bagList)
            end

            return true
        end

        local posY=self.midPosH-self.midH/2
        local leftBtnPos=ccp(60,posY)
        local rightBtnPos=ccp(self.bgLayer:getContentSize().width-60,posY)
        self.pageLayer=self.pageDialog:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,self.page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos,movedCallback,-(self.layerNum-1)*20-4,nil,"vipArrow.png",true,nil,180)
        self.curTankTab=self.dlist[1]

        if totalNum==1 then
            self.pageDialog:setEnabled(false)
            -- self:resetForbidLayer(G_VisibleSizeHeight-(self.tvPosH+self.tvHeight),self.tvPosH)
            self:addUseLessTv(self.tvHeight+self.midH-10)
        else
            self:initMiddle(self.midH,self.midPosH,totalNum)
            -- self:resetForbidLayer(G_VisibleSizeHeight-(self.tvPosH+self.tvHeight-(self.midH-10)),self.tvPosH)
            self:addUseLessTv(self.tvHeight)
        end
    else
        self:addGetMatrix()
    end
    

end

-- 主要是为了屏蔽层
function armorMatrixBagDialog:addUseLessTv(tvHeight)
   local hd= LuaEventHandler:createHandler(function(...) return self:eventHandler(...) end)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,tvHeight),nil)
    self.tv:setPosition(20,self.tvPosH)
    
end

function armorMatrixBagDialog:newPageLayer(id,pageRefresh)
    local tvHeight=self.tvHeight
	local bagPage=armorMatrixBagPage:new(pageRefresh)
    local bagLayer=bagPage:init(self.layerNum,id,tvHeight,self.tvPosH,self.everyCellNum,self.midH)
	return bagLayer,bagPage
end

function armorMatrixBagDialog:initHeader(headerH,posH)

	local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
	headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,headerH))
	headerSprie:ignoreAnchorPointForPosition(false)
	headerSprie:setAnchorPoint(ccp(0.5,1))
	headerSprie:setIsSallow(false)
	headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	headerSprie:setPosition(ccp(G_VisibleSizeWidth/2,posH))
	self.bgLayer:addChild(headerSprie,2)

	local headSize=headerSprie:getContentSize()

	local posy=headSize.height-40
	local lineSp1=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
	lineSp1:setAnchorPoint(ccp(0,0.5))
	lineSp1:setPosition(ccp(200,posy))
	headerSprie:addChild(lineSp1,1)
	lineSp1:setRotation(180)
	local lineSp2=CCSprite:createWithSpriteFrameName("lineAndPoint.png")
	lineSp2:setAnchorPoint(ccp(0,0.5))
	lineSp2:setPosition(ccp(headSize.width-200,posy))
	headerSprie:addChild(lineSp2,1)

    local strSize2 = 21
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
	local titleLb=GetTTFLabelWrap(getlocal("armorMatrix_epoor"),strSize2,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	-- titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(headSize.width/2,posy))
	headerSprie:addChild(titleLb,1)
	titleLb:setColor(G_ColorYellowPro)

    if G_getCurChoseLanguage() ~="cn" and G_getCurChoseLanguage() ~="tw" and G_getCurChoseLanguage() ~="ja" and G_getCurChoseLanguage() ~="ko" then
        lineSp1:setPositionX(titleLb:getPositionX() - titleLb:getContentSize().width*0.5 -5)
        lineSp2:setPositionX(titleLb:getPositionX() + titleLb:getContentSize().width*0.5 +5)
    end

	local iconSp=CCSprite:createWithSpriteFrameName("equipBg_blue.png")
	iconSp:setAnchorPoint(ccp(0,0.5))
	iconSp:setPosition(20,(posy-titleLb:getContentSize().height/2)/2)
	headerSprie:addChild(iconSp)

    local expIcon=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
    iconSp:addChild(expIcon)
    expIcon:setPosition(getCenterPoint(iconSp))

    local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
	local expPosX=130
	local haveExpLb=GetTTFLabelWrap(getlocal("ownedXp",{armorMatrixInfo.exp or 0}),24,CCSizeMake(headSize.width-expPosX-15,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
	iconSp:addChild(haveExpLb)
	haveExpLb:setAnchorPoint(ccp(0,0))
	haveExpLb:setPosition(expPosX,iconSp:getContentSize().height/2+15)
    self.haveExpLb=haveExpLb

	local expDesLb=GetTTFLabelWrap(getlocal("armorMatrix_exp_des"),20,CCSizeMake(headSize.width-expPosX-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	iconSp:addChild(expDesLb)
	expDesLb:setAnchorPoint(ccp(0,1))
	expDesLb:setPosition(expPosX,iconSp:getContentSize().height/2+5)
end

function armorMatrixBagDialog:initMiddle(midH,midPosH,totalNum)
    local sbNode=LuaCCScale9Sprite:createWithSpriteFrameName("rank1ItemBg.png",CCRect(20,20,10,10),function () end)
    -- CCNode:create()
    sbNode:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,midH))
    sbNode:setAnchorPoint(ccp(0.5,1))
    sbNode:setPosition(G_VisibleSizeWidth/2,midPosH)
    self.bgLayer:addChild(sbNode,2)
    sbNode:setOpacity(0)
    self.sbNode=sbNode

    self.pointListNum=totalNum
    local space=50
    self.space=space
    for i=1,totalNum do
        local pageFlag=CCSprite:createWithSpriteFrameName("unselectedPoint.png")
        pageFlag:setTag(100 + i)
        local pox=sbNode:getContentSize().width/2-(space/2*(totalNum-1))+(i-1)*space
        pageFlag:setPosition(ccp(pox,midH/2))
        sbNode:addChild(pageFlag,1)

        if self.page==i then
            self.curPageFlag=CCSprite:createWithSpriteFrameName("selectedPoint.png")
            self.curPageFlag:setPosition(ccp(pox,midH/2))
            sbNode:addChild(self.curPageFlag,2)
        end
    end


end

function armorMatrixBagDialog:initBottom(bottomPosH)
    local strSize2 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
	local function expansionFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local cost=armorMatrixVoApi:getAddBagCost()
        if not cost then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage9053"),nil,self.layerNum+1)
            return
        end

        -- 金币不足
        local gems=playerVoApi:getGems()
        if cost>gems then
            local function onSure()
                activityAndNoteDialog:closeAllDialog()
            end
            GemsNotEnoughDialog(nil,nil,cost-gems,self.layerNum+1,cost,onSure)
            return
        end

        local function onConfirm()
            local function refreshCalback()
                playerVoApi:setGems(gems-cost)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_expansion_tip"),30)
                self:expansionRefresh(true)
            end
            armorMatrixVoApi:armorAddBag(refreshCalback)
        end
        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("armorMatrix_expansion_des",{cost}),nil,self.layerNum+1)

    end
    local lbStr=getlocal("armorMatrix_expansion")

    local expansionItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",expansionFunc,nil,lbStr,24/self.btnScale1,11)
    expansionItem:setAnchorPoint(ccp(0.5,0))
    expansionItem:setScale(self.btnScale1)
    local btnLb = expansionItem:getChildByTag(11)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end

    local expansionBtn=CCMenu:createWithItem(expansionItem);
    expansionBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    expansionBtn:setPosition(ccp(G_VisibleSizeWidth/2-200,bottomPosH))
    self.bgLayer:addChild(expansionBtn,2)

    -- armorMatrix_capacity
    local capacityLb=GetTTFLabelWrap("",25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.bgLayer:addChild(capacityLb,2)
    capacityLb:setAnchorPoint(ccp(0.5,0.5))
    capacityLb:setPosition(G_VisibleSizeWidth/2,bottomPosH+expansionItem:getContentSize().height*self.btnScale1/2)
    self.capacityLb=capacityLb
    

    -- 不能批量分解橙色
    local function severanceFunc()
        local strSize2 = 18
        if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
            strSize2 =30
        end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        local function sellBack(selectQualityList,closeFunc)
            local sellTb={}
            local totalExp=0
            local num4=0
            for k,v in pairs(self.bagList) do
                local mid,level=armorMatrixVoApi:getMidAndLevelById(v)
                local cfg=armorMatrixVoApi:getCfgByMid(mid)
                if selectQualityList[cfg.quality] then
                    table.insert(sellTb,v)

                    local exp=armorMatrixVoApi:getDecomposeExp(mid,level)
                    totalExp=totalExp+exp

                    -- 记录紫色装甲的个数
                    if cfg.quality==4 then
                        num4=num4+1
                    end
                end
            end

            if(#sellTb==0)then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("armorMatrix_no_bulk_sale"),strSize2)
                do return end
            end
            local qualityTb={}
            for k,v in pairs(selectQualityList) do
                if v then
                    table.insert(qualityTb,k)
                end
                
            end

            -- 算批量分解的经验
            local dataInfo={}
            local reward={am={exp=totalExp}}
            local rewardItem=FormatItem(reward)
            dataInfo.reward=rewardItem
            dataInfo.sellNum=#sellTb
            dataInfo.num4=num4
            dataInfo.num5=0

            local function decomposeFunc()
                local function refreshCalback()
                    if closeFunc then
                        closeFunc()
                    end
                    G_showRewardTip(rewardItem,true)
                    self.bagList=armorMatrixVoApi:getBagList()
                    self:severanceRefresh()
                end

                armorMatrixVoApi:armorResolve(nil,qualityTb,refreshCalback)
            end
            local titleStr=getlocal("armorMatrix_batch_severance")
            local desStr=getlocal("armorMatrix_decompose_des1",{dataInfo.sellNum})
            armorMatrixVoApi:showSellRewardDialog(self.layerNum+2,decomposeFunc,titleStr,desStr,dataInfo)

        end
        armorMatrixVoApi:showBulkSaleDialog(self.layerNum+1,sellBack)
        
    end
    local lbStr2=getlocal("armorMatrix_batch_severance")

    local severanceItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",severanceFunc,nil,lbStr2,strSize2/self.btnScale1,11)
    severanceItem:setAnchorPoint(ccp(0.5,0))
    severanceItem:setScale(self.btnScale1)
    local btnLb = severanceItem:getChildByTag(11)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end

    local severanceBtn=CCMenu:createWithItem(severanceItem);
    severanceBtn:setTouchPriority(-(self.layerNum-1)*20-4);
    severanceBtn:setPosition(ccp(G_VisibleSizeWidth/2+200,bottomPosH))
    self.bgLayer:addChild(severanceBtn,2)
   
end

-- 扩充的时候需要刷新
-- flag -- 是否做动画
function armorMatrixBagDialog:expansionRefresh(flag)
    local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
    local armorCfg=armorMatrixVoApi:getArmorCfg()
    local limitNum=armorCfg.storeHouseMaxNum
   
	if self.capacityLb then
		self.capacityLb:setString(getlocal("armorMatrix_capacity",{self.cellNum .. "/" .. armorMatrixInfo.count}))
        if flag then
            local scaleTo1 = CCScaleTo:create(0.15,1.5)
            local scaleTo2 = CCScaleTo:create(0.15,1)
            local carray=CCArray:create()
            carray:addObject(scaleTo1)
            carray:addObject(scaleTo2)
            local seq=CCSequence:create(carray)
            self.capacityLb:runAction(seq)
        end
	end


end

-- 遣散的时候需要刷新
function armorMatrixBagDialog:severanceRefresh()
    local armorMatrixInfo=armorMatrixVoApi:getArmorMatrixInfo()
    self.haveExpLb:setString(getlocal("ownedXp",{armorMatrixInfo.exp or 0}))

    self.cellNum=SizeOfTable(self.bagList)

    self:expansionRefresh()


    local totalNum=math.ceil(self.cellNum/self.everyCellNum)

    if totalNum<=1 then
        self:resetSelfForbidLayer(G_VisibleSizeHeight-(self.tvPosH+self.tvHeight+(self.midH-10)),self.tvPosH)
    end

    local function customCallback()
        for i=#self.list,totalNum+1,-1 do
            table.remove(self.list,i)
            self.dlist[i]:dispose()
            table.remove(self.dlist,i)
        end
    end

    if totalNum==1 then
        self.pageDialog:setEnabled(false)
    end

    

    if self.cellNum==0 then
        if self and self.pageDialog and self.pageDialog.dispose then
            self.pageDialog:setEnabled(false)
            self.pageDialog:dispose()
            self.pageLayer:removeFromParentAndCleanup(true)
            self.pageDialog=nil
            self.pageLayer=nil

        end
        customCallback()
        self:refreshMiddle(totalNum)
        self:addGetMatrix()
        return
    end

    if totalNum<self.page then
        self.page=1
        self.dlist[self.page]:refresh(self.cellNum,self.bagList)
        self.pageDialog:rightPage(true,self.page,customCallback)
    else
        self.dlist[self.page]:refresh(self.cellNum,self.bagList)
        customCallback()
    end
    
    self:refreshMiddle(totalNum)

end

-- 刷新页数列表
function armorMatrixBagDialog:refreshMiddle(totalNum)
    if totalNum<=1 then
        if self.sbNode then
            self.sbNode:removeFromParentAndCleanup(true)
            self.sbNode=nil
        end
    else
        for i=totalNum+1,self.pointListNum do
            local child=self.sbNode:getChildByTag(100+i)
            if child then
                child:setVisible(false)
                child:removeFromParentAndCleanup(true)
                child=nil
            end
        end
        self.pointListNum=totalNum
        for i=1,self.pointListNum do
            local child=self.sbNode:getChildByTag(100+i)
            if child then
                if i<=totalNum then
                    local pox=self.sbNode:getContentSize().width/2-(self.space/2*(totalNum-1))+(i-1)*self.space
                    local child=self.sbNode:getChildByTag(100+i)
                    if child then
                        child:setPositionX(pox)
                    end
                end

            end
        end
        if self.sbNode then
            local child=self.sbNode:getChildByTag(100+self.page)
            if child then
                local posX=child:getPositionX()
                self.curPageFlag:setPositionX(posX)
            end
        end
    end
end

function armorMatrixBagDialog:resetSelfForbidLayer(height1,height2)
    if height1 and height2 then
        -- self.topforbidSp:setVisible(true)
        -- self.bottomforbidSp:setVisible(true)
        self.topforbidSp:setAnchorPoint(ccp(0,1))
        self.topforbidSp:setPosition(0,G_VisibleSizeHeight)
        self.topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height1))

        self.bottomforbidSp:setPosition(0,0)
        self.bottomforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth, height2))
    end
    
    
end

function armorMatrixBagDialog:addGetMatrix()
    local strSize2 = 16
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2 =24
    end
    -- self.bgLayer
    local uselessNode=CCNode:create()
    uselessNode:setContentSize(CCSizeMake(G_VisibleSizeWidth,300))
    self.bgLayer:addChild(uselessNode,2)
    uselessNode:setAnchorPoint(ccp(0.5,0.5))
    uselessNode:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    uselessNode:setTag(1001)

    local uselessLb=GetTTFLabelWrap(getlocal("armorMatrix_bag_noMatrix"),strSize2,CCSizeMake(550,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    uselessLb:setAnchorPoint(ccp(0.5,0))
    uselessLb:setPosition(G_VisibleSizeWidth/2,uselessNode:getContentSize().height/2+10)
    uselessNode:addChild(uselessLb)

    local function goObtainFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        self:close()
        armorMatrixVoApi:showRecruitDialog(self.layerNum)
    end
    local obtainItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goObtainFunc,nil,getlocal("accessory_get"),strSize2/self.btnScale1)
    obtainItem:setScale(self.btnScale1)
    obtainItem:setAnchorPoint(ccp(0.5,1))
    local obtainMenu = CCMenu:createWithItem(obtainItem)
    uselessNode:addChild(obtainMenu)
    obtainMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    obtainMenu:setBSwallowsTouches(true)
    obtainMenu:setPosition(G_VisibleSizeWidth/2,uselessNode:getContentSize().height/2-10)
end


function armorMatrixBagDialog:tick()

end

function armorMatrixBagDialog:dispose()
    spriteController:removePlist("public/vipFinal.plist")
    if self.dlist then
        for k,v in pairs(self.dlist) do
            if v and v.dispose then
                v:dispose()
            end
        end
    end
    if self and self.pageDialog and self.pageDialog.dispose then
        self.pageDialog:dispose()
    end

end




