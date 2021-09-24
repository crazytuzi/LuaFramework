acLoversDayTab2={}

function acLoversDayTab2:new(closeCallback)
    local nc={}
    self.cellHeight=180
    self.cellWidth=0
    self.cellNum=0
    self.shopCfg=nil
    self.saleList=nil
    self.numLb=nil
    self.shopIndexTb=nil
    self.txjNum =0
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function acLoversDayTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.cellWidth=self.bgLayer:getContentSize().width-40
    self.saleList={}
    self.shopCfg=acLoversDayVoApi:getShopCfg()
    self.shopIndexTb=acLoversDayVoApi:getShopIndexTb() or {}
    for k,v in pairs(self.shopCfg) do
        if v.reward then
            self.saleList[k]=FormatItem(v.reward)[1]
        end
    end
    self.cellNum=SizeOfTable(self.shopCfg)
    self.cellHeight=280
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
        self.cellHeight=180
    end
    self:initTableView()
    return self.bgLayer
end

function acLoversDayTab2:initTableView()
    local function bgClick()
    end
    local h=G_VisibleSizeHeight-160
    local w=G_VisibleSizeWidth-50 --背景框的宽度
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),bgClick)
    backSprie:setContentSize(CCSizeMake(w,130))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth/2,h))
    backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie:setIsSallow(true)
    self.bgLayer:addChild(backSprie,10)

    local txjStr = GetTTFLabel(getlocal("sample_prop_name_3348")..": ",25)
    txjStr:setAnchorPoint(ccp(0,1))
    txjStr:setPosition(ccp(30,backSprie:getContentSize().height-15))
    txjStr:setColor(G_ColorYellowPro)
    backSprie:addChild(txjStr)

    local txjNum = GetTTFLabel( acLoversDayVoApi:getMyPoint(),25)
    txjNum:setAnchorPoint(ccp(0,1))
    txjNum:setPosition(ccp(txjStr:getPositionX()+txjStr:getContentSize().width,backSprie:getContentSize().height-15))
    txjNum:setColor(G_ColorYellowPro)
    self.txjNum =txjNum
    backSprie:addChild(txjNum)

    -- local key="p3338"
    -- local type="p"
    -- local name,pic,desc,id,index,eType,equipId,bgname=getItem(key,type)
    -- local num=acLoversDayVoApi:getMyPoint()
    -- local item={type=type,key=key,id=id,name=name,pic=pic,bgname=bgname,desc=desc,num=num}
    -- local numLb=GetTTFLabel(getlocal("propInfoNum",{num}),25)
    -- local icon,scale=G_getItemIcon(item,100,true,self.layerNum+1)
    -- icon:setAnchorPoint(ccp(0,0.5))
    -- icon:setTouchPriority(-(self.layerNum-1)*20-5)
    -- icon:setPosition(ccp(20,backSprie:getContentSize().height/2+numLb:getContentSize().height/2+5))
    -- backSprie:addChild(icon)
    -- numLb:setAnchorPoint(ccp(0,1))
    -- numLb:setPosition(0,-10)
    -- numLb:setScale(1/scale)
    -- icon:addChild(numLb)
    -- self.numLb=numLb

    local txjIcon = CCSprite:createWithSpriteFrameName("txjIcon.png")
    txjIcon:setAnchorPoint(ccp(0,0))
    txjIcon:setPosition(ccp(15,15))
    backSprie:addChild(txjIcon)

    local desTv,desLabel=G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-220,60),getlocal("sample_prop_des_3348"),25,kCCTextAlignmentLeft)
    backSprie:addChild(desTv)
    desTv:setPosition(ccp(txjIcon:getPositionX()+txjIcon:getContentSize().width+10,10))
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    desTv:setMaxDisToBottomOrTop(100)

    local function touch(tag,object)
        PlayEffect(audioCfg.mouseClick)
        --显示活动信息
        self:showInfor()
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(w-10,backSprie:getContentSize().height*0.5))
    backSprie:addChild(menuDesc)

    local posY = 35
    local goldLineSprite1 = CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite1:setAnchorPoint(ccp(0.5,0))
    goldLineSprite1:setScale(1.05)
    goldLineSprite1:setPosition(ccp(G_VisibleSizeWidth*0.5,self.bgLayer:getContentSize().height-190-170+posY))
    self.bgLayer:addChild(goldLineSprite1)

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.bgLayer:getContentSize().height-190-170),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,posY))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acLoversDayTab2:showInfor()
    local tabStr={}
    local tabColor={}
    local tabAlignment={}
    tabStr={"\n",getlocal("activity_loversDay_shopRule3"),"\n",getlocal("activity_loversDay_shopRule2"),"\n",getlocal("activity_loversDay_shopRule1"),"\n",getlocal("activityDescription"),"\n"}
    tabColor={nil,nil,nil,nil,nil,nil,nil,G_ColorYellowPro,nil}
    tabAlignment={nil,nil,nil,nil,nil,nil,nil,kCCTextAlignmentCenter,nil}
    local td=smallDialog:new()
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor,nil,nil,nil,tabAlignment)
    sceneGame:addChild(dialog,self.layerNum+1)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acLoversDayTab2:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.cellWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local indexCfg=self.shopIndexTb[idx+1]
        if indexCfg==nil then
            do return end
        end
        local saleId=indexCfg.saleId
        local saleCfg=self.shopCfg[saleId]
        local saleItem=self.saleList[saleId]
        if saleCfg==nil or saleItem==nil then
            do return end
        end
        local price=saleCfg.g --现价
        local oldPrice=saleCfg.p --原价
        local ownNum=acLoversDayVoApi:getMyPoint()
        local cellWidth=self.bgLayer:getContentSize().width-30

        local capInSet=CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        bgSp:setContentSize(CCSizeMake(self.cellWidth-10,self.cellHeight))
        bgSp:ignoreAnchorPointForPosition(false)
        -- bgSp:setAnchorPoint(ccp(0.5,0))
        bgSp:setIsSallow(false)
        bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
        bgSp:setPosition(ccp(self.cellWidth/2,self.cellHeight/2))
        cell:addChild(bgSp,1)
        local bgSize=bgSp:getContentSize()

        local scale=1
        local propSp=G_getItemIcon(saleItem,100,nil,self.layerNum+1)
        propSp:setAnchorPoint(ccp(0,0.5))
        propSp:setScale(scale)
        propSp:setPosition(ccp(15,bgSize.height/2))
        bgSp:addChild(propSp,1)
        if saleCfg.isflick and saleCfg.isflick==1 then
            G_addRectFlicker(propSp,1.4,1.4)
        end
        local itemW=propSp:getContentSize().width*scale
        local itemH=propSp:getContentSize().height*scale

        local numLb=GetTTFLabel("x"..saleItem.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemW-5,5))
        numLb:setScale(1/propSp:getScale())
        propSp:addChild(numLb,1)

        local priceSize=24
        local gemScale=0.4
        local addH=0
        local newPriceLb=GetTTFLabel(price,priceSize)--,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        newPriceLb:setAnchorPoint(ccp(0,0.5))
        newPriceLb:setColor(G_ColorYellowPro)
        bgSp:addChild(newPriceLb)

        local newPriceLb2=GetTTFLabel(price,priceSize+2)
        local realW=newPriceLb2:getContentSize().width
        local lbw=newPriceLb:getContentSize().width
        if realW>lbw then
            realW=lbw
        end
        if saleCfg.bn and tonumber(saleCfg.bn)>0 then
            addH=newPriceLb:getContentSize().height/2            
        end
        local priceLbPosX= G_getCurChoseLanguage() =="ar" and bgSize.width-realW-70 or bgSize.width-realW-50
        local secSubPosX = G_getCurChoseLanguage() =="ar" and 5 or 0
        newPriceLb:setPosition(ccp(priceLbPosX,self.cellHeight/2+newPriceLb:getContentSize().height/2+20-addH))
        local gemSp1=CCSprite:createWithSpriteFrameName("txjIcon.png")
        gemSp1:setAnchorPoint(ccp(0,0.5))
        gemSp1:setScale(gemScale)
        gemSp1:setPosition(ccp(newPriceLb:getPositionX()+newPriceLb:getContentSize().width+3,newPriceLb:getPositionY()))
        bgSp:addChild(gemSp1)
        if ownNum<price then
            newPriceLb:setColor(G_ColorRed)
        else
            newPriceLb:setColor(G_ColorYellowPro)
        end
        if saleCfg.bn and tonumber(saleCfg.bn)>0 then
            local discountIcon=CCSprite:createWithSpriteFrameName("monthlysignFreeVip.png")
            discountIcon:setAnchorPoint(ccp(0,1))
            discountIcon:setPosition(0,propSp:getContentSize().height)
            propSp:addChild(discountIcon)
            local discount=(10-tonumber(saleCfg.bn))*10
            local discountLb=GetTTFLabel("-"..discount.."%",18)
            -- discountLb:setColor(G_ColorYellowPro)
            discountLb:setAnchorPoint(ccp(0.5,0.5))
            discountLb:setRotation(-45)
            discountLb:setPosition(discountIcon:getContentSize().width/2-12,discountIcon:getContentSize().height/2+11)
            discountIcon:addChild(discountLb)  
            -- local oldPriceLb=GetTTFLabelWrap(oldPrice,priceSize-2,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            local oldPriceLb=GetTTFLabel(oldPrice,priceSize-4)
            local realW=oldPriceLb:getContentSize().width
            local lbw=oldPriceLb:getContentSize().width
            if realW>lbw then
                realW=lbw
            end
            local priceLbPosX=bgSize.width-realW-50
            local subPosX = G_getCurChoseLanguage() =="ar" and 5 or 0
            oldPriceLb:setAnchorPoint(ccp(0,0.5))
            oldPriceLb:setPosition(ccp(priceLbPosX-subPosX,newPriceLb:getPositionY()+oldPriceLb:getContentSize().height/2+20))
            bgSp:addChild(oldPriceLb)
            
            local gemW=gemSp1:getContentSize().width*gemScale
            local lbH=oldPriceLb:getContentSize().height
            local rotation=math.floor(math.deg(math.atan(lbH/(realW+gemW))))
            local rline=CCSprite:createWithSpriteFrameName("redline.jpg")
            rline:setAnchorPoint(ccp(0.5,0.5))
            rline:setScaleX((realW+10)/rline:getContentSize().width)
            rline:setPosition(ccp(priceLbPosX-10+realW/2+10,oldPriceLb:getPositionY()))
            rline:setRotation(rotation)
            bgSp:addChild(rline,1)
        end

        local nameWidth=250
        local lbName=GetTTFLabelWrap(saleItem.name,26,CCSizeMake(nameWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        lbName:setPosition(propSp:getPositionX()+itemW+10,bgSp:getContentSize().height-15)
        lbName:setAnchorPoint(ccp(0,1))
        bgSp:addChild(lbName,2)
        lbName:setColor(G_ColorGreen2)
        local cur=acLoversDayVoApi:getBuyData(saleId) or 0
        if saleCfg.limit and saleCfg.limit>0 then --限购
            local countLb=GetTTFLabel(cur.."/"..saleCfg.limit,25)
            countLb:setAnchorPoint(ccp(0.5,1))
            countLb:setPosition(ccp(propSp:getContentSize().width/2,0))
            propSp:addChild(countLb)
            if cur>=saleCfg.limit then
                cur=saleCfg.limit
                countLb:setColor(G_ColorRed)
            else
                countLb:setColor(G_ColorYellow)
            end
        end
        local lbSize=CCSize(330,0)
        local descLb=GetTTFLabelWrap(getlocal(saleItem.desc),22,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        local desPosY=lbName:getPositionY()-lbName:getContentSize().height-10
        descLb:setPosition(lbName:getPositionX(),desPosY)
        descLb:setAnchorPoint(ccp(0,1))
        bgSp:addChild(descLb,2)

        
        local function exchange(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                local ownNum=acLoversDayVoApi:getMyPoint()
                if ownNum<price then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage1996"),nil,self.layerNum+1)
                    do return end
                end
                -- local saleId="i"..tag
                local saleItem=self.saleList[saleId]
                local name=saleItem.name
                local function callback()
                    self:refresh()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("expeditionBuySuccess",{name}),30)
                    -- print("saleCfg.notice------>",saleCfg.notice)
                    if saleCfg.notice and saleCfg.notice==1 then
                        acLoversDayVoApi:sendRewardNotice(2,saleItem)
                    end
                end
                acLoversDayVoApi:loversDayRequest("active.wuduyouou.buy",{saleId},callback)
            end
        end
        local buyItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",exchange,idx+1,getlocal("code_gift"),25)
        local buyBtn=CCMenu:createWithItem(buyItem)
        buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
        buyItem:setScale(0.8)
        buyBtn:setPosition(ccp(cellWidth-90,self.cellHeight/2-30-addH))
        bgSp:addChild(buyBtn,1)
        if (ownNum<price) or (cur and saleCfg.limit and tonumber(cur)>=tonumber(saleCfg.limit)) then
            buyItem:setEnabled(false)
        else
            buyItem:setEnabled(true)
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

function acLoversDayTab2:refresh()
    local num=acLoversDayVoApi:getMyPoint()
    if self.txjNum then
        self.txjNum:setString(acLoversDayVoApi:getMyPoint())
    end
    self.shopIndexTb=acLoversDayVoApi:getShopIndexTb()
    if self.shopIndexTb and self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end

function acLoversDayTab2:updateUI()
    self:refresh()
end

function acLoversDayTab2:tick()
end

function acLoversDayTab2:dispose()
    self.cellHeight=180
    self.cellWidth=0
    self.cellNum=0
    self.shopCfg=nil
    self.saleList=nil
    self.numLb=nil
    self.shopIndexTb=nil
    self.txjNum =nil
end