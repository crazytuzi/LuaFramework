alienTechFactoryDialogTab3={}

function alienTechFactoryDialogTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.tv=nil
    self.cellWidth=580
    self.normalHeight=100
    self.extendSpTag=113
    self.expandIdx={}
    self.expandHeight=936
    self.lineWidth=20
    self.noProduceLb=nil

    return nc
end

function alienTechFactoryDialogTab3:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent

    self:initTableView()
    return self.bgLayer
end

--设置对话框里的tableView
function alienTechFactoryDialogTab3:initTableView()
    self.allReductionTank=alienTechVoApi:getAllReductionTank()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    self.numForEveryPing=(self.bgLayer:getContentSize().height-85-120)/self.normalHeight or 0

    self.noProduceLb=GetTTFLabelWrap(getlocal("tank_reduction_des"),24,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.noProduceLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
    self.noProduceLb:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(self.noProduceLb,2)
    self.noProduceLb:setColor(G_ColorGray)

    
    self.cellNum=SizeOfTable(self.allReductionTank) or 0
    if SizeOfTable(self.allReductionTank)>0 then
        self.noProduceLb:setVisible(false)
    else
        self.noProduceLb:setVisible(true)
    end
end

function alienTechFactoryDialogTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.allReductionTank)
    elseif fn=="tableCellSizeForIndex" then
        if self.expandIdx and self.expandIdx["k"..idx]~=nil then
            tmpSize=CCSizeMake(self.cellWidth,self.expandHeight)
        else
            tmpSize=CCSizeMake(self.cellWidth,self.normalHeight)
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local allReductionTank=self.allReductionTank
        local tid=allReductionTank[idx+1][1]

        local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
        id = G_pickedList(id)

        local expanded=false
        if self.expandIdx and self.expandIdx["k"..idx]~=nil then
            expanded=true
        end
        if expanded then
            cell:setContentSize(CCSizeMake(self.cellWidth, self.expandHeight))
        else
            cell:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight))
        end
        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);

        local function cellClick(hd,fn,idx)
                return self:cellClick(idx)
        end
        local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        headerSprie:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight-4))
        headerSprie:ignoreAnchorPointForPosition(false);
        headerSprie:setAnchorPoint(ccp(0,0));
        headerSprie:setTag(1000+idx)
        headerSprie:setIsSallow(false)
        headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
        cell:addChild(headerSprie)


        if tankCfg[id].icon and tankCfg[id].icon~="" then
            local sprite = tankVoApi:getTankIconSp(id)--CCSprite:createWithSpriteFrameName(tankCfg[id].icon);
            sprite:setAnchorPoint(ccp(0,0.5));
            sprite:setPosition(20,headerSprie:getContentSize().height/2)
            sprite:setScale(0.5)
            headerSprie:addChild(sprite,2)
        end


        local str=getlocal(tankCfg[id].name)
        -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local lbName=GetTTFLabelWrap(str,24,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        lbName:setPosition(120,headerSprie:getContentSize().height/2+22)
        lbName:setAnchorPoint(ccp(0,0.5))
        headerSprie:addChild(lbName,2)
        lbName:setColor(G_ColorGreen)

        
        local curNum=self.allReductionTank[idx+1][2]
        -- tankVoApi:getTankCountByItemId(id+40000) or 0
        str=getlocal("can_reduction_num",{curNum})
        -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local lbPoint=GetTTFLabelWrap(str,20,CCSizeMake(260,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        lbPoint:setPosition(120,headerSprie:getContentSize().height/2-22)
        lbPoint:setAnchorPoint(ccp(0,0.5));
        headerSprie:addChild(lbPoint,2)

          
        --显示加减号
        local btn
        if expanded==false then
            btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
        else
            btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
        end
        btn:setScale(0.8)
        btn:setAnchorPoint(ccp(0,0.5))
        btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height/2))
        headerSprie:addChild(btn)
        btn:setTag(self.extendSpTag)


        if expanded==true then
            self:initExpand(idx,cell)
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


function alienTechFactoryDialogTab3:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)

        if self.expandIdx==nil then
            self.expandIdx={}
        end
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

function alienTechFactoryDialogTab3:initExpand(idx,cell)
    if cell then
        local allReductionTank=self.allReductionTank

        local tankId=allReductionTank[idx+1][1]
        -- tankId = G_pickedList(tankId)
        local numTank=allReductionTank[idx+1][2]
        local m_tankIndex=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))


        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function touchHander()
  
        end
        local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
        exBg:setAnchorPoint(ccp(0,0))
        exBg:setContentSize(CCSize(self.cellWidth,self.expandHeight-self.normalHeight-280-20+40))
        exBg:setPosition(ccp(0,180-40))
        exBg:setTag(2)
        cell:addChild(exBg)
        

        local spriteIcon = tankVoApi:getTankIconSp(m_tankIndex)--CCSprite:createWithSpriteFrameName(tankCfg[m_tankIndex].icon);
        spriteIcon:setAnchorPoint(ccp(0,0.5));
        spriteIcon:setScale(0.5)
        spriteIcon:setPosition(20,exBg:getContentSize().height+60)
        exBg:addChild(spriteIcon,2)


        local function touchInfo()
            PlayEffect(audioCfg.mouseClick)
            tankInfoDialog:create(exBg,G_pickedList(m_tankIndex),self.layerNum+1)
        end

        local menuItemInfo = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,11,nil,nil)
        local menuInfo = CCMenu:createWithItem(menuItemInfo);
        menuInfo:setPosition(ccp(520,exBg:getContentSize().height+50));
        menuInfo:setTouchPriority(-(self.layerNum-1)*20-2);
        exBg:addChild(menuInfo,3);
        
        local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
        local iconScale= 50/lifeSp:getContentSize().width
        lifeSp:setAnchorPoint(ccp(0,0.5));
        lifeSp:setPosition(120,exBg:getContentSize().height+90)
        exBg:addChild(lifeSp,2)
        lifeSp:setScale(iconScale)
        
        local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
        attackSp:setAnchorPoint(ccp(0,0.5));
        attackSp:setPosition(280,exBg:getContentSize().height+90)
        exBg:addChild(attackSp,2)
        attackSp:setScale(iconScale)
        
        local typeStr = "pro_ship_attacktype_"..tankCfg[m_tankIndex].attackNum
        if tankCfg[m_tankIndex].weaponType and tonumber(tankCfg[m_tankIndex].weaponType) > 10 then
            typeStr ="pro_ship_attacktype_"..tankCfg[m_tankIndex].weaponType
        end
        local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
        attackTypeSp:setAnchorPoint(ccp(0,0.5));
        attackTypeSp:setPosition(120,exBg:getContentSize().height+35)
        exBg:addChild(attackTypeSp,2)
        attackTypeSp:setScale(iconScale)
        
        local lifeLb=GetTTFLabel(tankCfg[m_tankIndex].life,20)
        lifeLb:setAnchorPoint(ccp(0,0.5))
        lifeLb:setPosition(ccp(180,exBg:getContentSize().height+90))
        exBg:addChild(lifeLb)
        
        local attLb=GetTTFLabel(tankCfg[m_tankIndex].attack,20)
        attLb:setAnchorPoint(ccp(0,0.5))
        attLb:setPosition(ccp(340,exBg:getContentSize().height+90))
        exBg:addChild(attLb)
        
        local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(24*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        attTypeLb:setAnchorPoint(ccp(0,0.5))
        attTypeLb:setPosition(ccp(180,exBg:getContentSize().height+35))
        exBg:addChild(attTypeLb)
        
        
        local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
        bgSp:setAnchorPoint(ccp(0,0.5));
        bgSp:setPosition(0,-30);
        exBg:addChild(bgSp,1);
        

        local container=exBg
        local addH=11
        -- local costReR4=tankCfg[m_tankIndex].alienUraniumConsume or 0
        local costReR1=1

        local typeLb=GetTTFLabel(getlocal("resourceType"),20)
        typeLb:setAnchorPoint(ccp(0.5,0.5))
        typeLb:setPosition(ccp(150,container:getContentSize().height-40+addH))
        container:addChild(typeLb)

        local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
        resourceLb:setAnchorPoint(ccp(0.5,0.5))
        resourceLb:setPosition(ccp(300,container:getContentSize().height-40+addH))
        container:addChild(resourceLb)

        local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
        haveLb:setAnchorPoint(ccp(0.5,0.5))
        haveLb:setPosition(ccp(450,container:getContentSize().height-40+addH))
        container:addChild(haveLb)

        local tankIconSp = tankVoApi:getTankIconSp(tankId)--tankCfg[tankId].icon
        local tb={
            {titleStr=tankCfg[tankId].name,spName=tankIconSp,needStr=FormatNumber(costReR1),haveStr=numTank,num1=allReductionTank[idx+1][1],num2=tonumber(costReR1)},
        }

        addH=0
        local addy=70
        local spSize=50
        local countTb = {}
        for k,v in pairs(tb) do
            local resLb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            resLb:setAnchorPoint(ccp(0.5,0.5))
            resLb:setPosition(ccp(150,container:getContentSize().height-100+addH-(k-1)*addy))
            container:addChild(resLb)

            local resSp= type(v.spName) == "string" and CCSprite:createWithSpriteFrameName(v.spName) or v.spName
            resSp:setAnchorPoint(ccp(0.5,0.5))
            resSp:setPosition(ccp(40,container:getContentSize().height-100+addH-(k-1)*addy))
            container:addChild(resSp)
            resSp:setScale(spSize/resSp:getContentSize().width)
            local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
            resSp:addChild(pickedIcon)
            pickedIcon:setPosition(resSp:getContentSize().width*0.7,resSp:getContentSize().height*0.5-20)

            local needResLb=GetTTFLabel(v.needStr,20)
            needResLb:setAnchorPoint(ccp(0.5,0.5))
            needResLb:setPosition(ccp(300,container:getContentSize().height-100+addH-(k-1)*addy))
            container:addChild(needResLb)

            local haveResLb=GetTTFLabel(v.haveStr,20)
            haveResLb:setAnchorPoint(ccp(0.5,0.5))
            haveResLb:setPosition(ccp(450,container:getContentSize().height-100+addH-(k-1)*addy))
            container:addChild(haveResLb)

            local checkSp;
            if v.num1>=v.num2 then
                checkSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
            else
                checkSp=CCSprite:createWithSpriteFrameName("IconFault.png")
            end
            checkSp:setAnchorPoint(ccp(0.5,0.5))

            checkSp:setPosition(ccp(400,container:getContentSize().height-100+addH-(k-1)*addy))

            container:addChild(checkSp)
            countTb[k]=needResLb
        end


        local m_numLb=GetTTFLabel(" ",24)
        m_numLb:setPosition(70,-30);
        container:addChild(m_numLb,2);

        local function sliderTouch(handler,object)
            local count = math.floor(object:getValue())
            m_numLb:setString(count)
            if count>0 then
                for k,v in pairs(countTb) do
                    v:setString(FormatNumber(tb[k].num2*count))
                end
            end
        end
        local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
        local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
        local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
        local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
        slider:setTouchPriority(-(self.layerNum-1)*20-2);
        slider:setIsSallow(true);

        slider:setMinimumValue(0.0);

        slider:setMaximumValue(100.0);

        slider:setValue(0);
        slider:setPosition(ccp(355,-30))
        slider:setTag(99)
        container:addChild(slider,2)
        m_numLb:setString(math.floor(slider:getValue()))


        local function touchAdd()
            slider:setValue(slider:getValue()+1);
        end

        local function touchMinus()
            if slider:getValue()-1>0 then
                slider:setValue(slider:getValue()-1);
            end
        end

        local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
        addSp:setPosition(ccp(549,-30))
        container:addChild(addSp,1)
        addSp:setTouchPriority(-(self.layerNum-1)*20-3);

        local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
        minusSp:setPosition(ccp(157,-30))
        container:addChild(minusSp,1)
        minusSp:setTouchPriority(-(self.layerNum-1)*20-3);


        local function touch1()
            PlayEffect(audioCfg.mouseClick)
            local nums=math.floor(tonumber(slider:getValue()))
            local function alienAddtroopsCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    self:refresh(idx)

                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("tank_reduction_transform_success"),30)
                end
            end
            socketHelper:eTankConformCommon(allReductionTank[idx+1][1],nums,alienAddtroopsCallback)
        end
        local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("tank_reduction_transform"),24/0.8,101)
        menuItem1:setScale(0.8)
        local btnLb = menuItem1:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
        local menu1 = CCMenu:createWithItem(menuItem1);
        menu1:setPosition(ccp(460,-93));
        menu1:setTouchPriority(-(self.layerNum-1)*20-2);
        container:addChild(menu1,3);
        
        local numTab = {numTank}

        table.sort(numTab,function(a,b) return a<b end)
        -- if numTab[1]>100 then
        --    slider:setMaximumValue(100);
        -- else
           slider:setMaximumValue(numTab[1]);
        -- end
        
        if numTab[1]==1 then
            slider:setMinimumValue(1.0);
            slider:setMaximumValue(1.0);
        else
            slider:setMinimumValue(1.0);
        end
        
        slider:setValue(numTab[1]);
        menuItem1:setEnabled(true)

    end
end

function alienTechFactoryDialogTab3:refresh(idx,cell)
    if self.tv then
        
        local allReductionTank=alienTechVoApi:getAllReductionTank()
        self.allReductionTank=allReductionTank

        local recordPoint=self.tv:getRecordPoint()

        if self.cellNum~=SizeOfTable(allReductionTank) then
            for k,v in pairs(self.expandIdx) do
                self.expandIdx[k]=nil
            end

            if idx+1>self.numForEveryPing then
            else
                recordPoint.y=recordPoint.y+self.expandHeight-(idx)*self.normalHeight
            end
        else
           

        end
       
        
        
        self.cellNum=SizeOfTable(allReductionTank) or 0
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)

        

        if self.noProduceLb then
            if SizeOfTable(allReductionTank)>0 then
                self.noProduceLb:setVisible(false)
            else
                self.noProduceLb:setVisible(true)
            end
        end
    end 
end

function alienTechFactoryDialogTab3:tick()

end

function alienTechFactoryDialogTab3:dispose()
    self.tv=nil
    self.expandIdx={}
    self.noProduceLb=nil
end







