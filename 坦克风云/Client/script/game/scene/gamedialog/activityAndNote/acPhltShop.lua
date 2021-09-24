acPhltShop={}

function acPhltShop:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    nc.tv=nil
    nc.bgLayer=nil
    nc.layerNum=nil
    nc.cellHeight=185
    nc.strSize3 = 25
    return nc;
end

function acPhltShop:init(layerNum,parent)
    spriteController:addPlist("public/acNewYearsEva.plist")
    spriteController:addTexture("public/acNewYearsEva.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/yellowFlicker.plist")
    spriteController:addTexture("public/yellowFlicker.png")
    spriteController:addPlist("public/activePicUseInNewGuid.plist")
    spriteController:addTexture("public/activePicUseInNewGuid.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    if G_getCurChoseLanguage() =="ru" then
        self.strSize3 =22
    end
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initUp()
    self:initTableView()
    return self.bgLayer
end

function acPhltShop:initUp()
    local startH=self.bgLayer:getContentSize().height-165
    local headerSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function (...)end)
    headerSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,120))
    headerSprie:ignoreAnchorPointForPosition(false);
    headerSprie:setAnchorPoint(ccp(0.5,1));
    headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    headerSprie:setPosition(self.bgLayer:getContentSize().width/2,startH)
    self.bgLayer:addChild(headerSprie)
    self.headerSprie=headerSprie

    local strHeight2=5
    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="tw" then
        strHeight2=0
    end

    local scoreLb=GetTTFLabel(getlocal("activity_tccx_skilled_score2",{acPhltVoApi:getPoint()}),25)
    headerSprie:addChild(scoreLb)
    scoreLb:setAnchorPoint(ccp(0,0))
    scoreLb:setPosition(20,headerSprie:getContentSize().height/2+5+strHeight2)
    scoreLb:setColor(G_ColorYellowPro)
    self.scoreLb=scoreLb

    local scoreDesLb=GetTTFLabelWrap(getlocal("activity_tccx_skill_des"),25,CCSizeMake(headerSprie:getContentSize().width-40-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    headerSprie:addChild(scoreDesLb)
    scoreDesLb:setAnchorPoint(ccp(0,1))
    scoreDesLb:setPosition(20,headerSprie:getContentSize().height/2-5+strHeight2)

    local function infoHandler(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local tabStr={}
        for i=1,2 do
            table.insert(tabStr,getlocal("activity_phlt_exrule"..i))
        end
        local titleStr=getlocal("activity_baseLeveling_ruleTitle")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,25)
    end

    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",infoHandler)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(0.8)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(headerSprie:getContentSize().width-10,headerSprie:getContentSize().height/2))
    headerSprie:addChild(menuDesc)
end

function acPhltShop:initTableView()
    local startH=self.bgLayer:getContentSize().height-165
    local function nilFunc()
    end
    local bottomBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50, 50, 1, 1),nilFunc)
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,startH-self.headerSprie:getContentSize().height-40))
    bottomBg:setPosition(ccp(G_VisibleSizeWidth/2,35))
    bottomBg:setAnchorPoint(ccp(0.5,0))
    self.bgLayer:addChild(bottomBg)

    local goldLineSprite=CCSprite:createWithSpriteFrameName("acNewYearGoldLine.png")
    goldLineSprite:setAnchorPoint(ccp(0.5,1))
    goldLineSprite:setPosition(ccp(bottomBg:getContentSize().width/2,bottomBg:getContentSize().height-3))
    bottomBg:addChild(goldLineSprite)

    self.shop=acPhltVoApi:getShop()
    self.shopNum=SizeOfTable(self.shop)
    self.trueShop=acPhltVoApi:getSortShop()
    self.salelist={}
    for id,v in pairs(self.shop) do
        self.salelist[id]=FormatItem(v.reward)[1]
    end

    local function callBack(...)
         return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    local tvHeight=bottomBg:getContentSize().height-goldLineSprite:getContentSize().height-15
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-80,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(40,45))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local function forbidClick()
    end
    local topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),forbidClick)
    local forbidHeight=G_VisibleSizeHeight-(self.tv:getPositionY()+tvHeight)
    topforbidSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,forbidHeight))
    topforbidSp:setTouchPriority(-(self.layerNum-1)*20-3)
    topforbidSp:setAnchorPoint(ccp(0.5,0))
    topforbidSp:setPosition(G_VisibleSizeWidth/2,self.tv:getPositionY()+tvHeight)
    topforbidSp:setVisible(false)
    self.bgLayer:addChild(topforbidSp)
end

function acPhltShop:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.shopNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(G_VisibleSizeWidth-80,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function nilFunc()
        end
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("titlesDesBg.png",CCRect(50, 20, 1, 1),nilFunc)
        backSprie:setContentSize(CCSizeMake(
        G_VisibleSizeWidth-80,self.cellHeight))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0))
        backSprie:setPosition(ccp(0,0))
        cell:addChild(backSprie)

        local id=self.trueShop[idx+1].id
        local rewardItem=self.salelist[id]
        local nowCost=self.shop[id].needPt
        local blog=acPhltVoApi:getBuyBlog()
        local buyNum=blog[id] or 0
        local limit=self.shop[id].limit
        local myPoint=acPhltVoApi:getPoint()



        local nameLb=GetTTFLabel(rewardItem.name,self.strSize3)
        nameLb:setAnchorPoint(ccp(0,1))
        nameLb:setPosition(ccp(10,backSprie:getContentSize().height-8))
        backSprie:addChild(nameLb,1)
        nameLb:setColor(G_ColorYellowPro)

        local numLb=GetTTFLabel("(" .. buyNum .. "/" .. limit .. ")",25)
        nameLb:addChild(numLb)
        numLb:setAnchorPoint(ccp(0,0.5))
        numLb:setPosition(nameLb:getContentSize().width,nameLb:getContentSize().height/2)

        local desBg2=LuaCCScale9Sprite:createWithSpriteFrameName("titlesBG.png",CCRect(35, 0, 1, 33),nilFunc)
        desBg2:setContentSize(CCSizeMake(nameLb:getContentSize().width+numLb:getContentSize().width+35,nameLb:getContentSize().height+8))
        desBg2:setAnchorPoint(ccp(0,1))
        desBg2:setPosition(ccp(8,backSprie:getContentSize().height-5))
        backSprie:addChild(desBg2)

        local priority=-(self.layerNum-1)*20-1
        local centerH=backSprie:getContentSize().height/2-15
        local starW=65
        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,rewardItem)
            return false
        end
        local icon=G_getItemIcon(rewardItem,100,true,self.layerNum,showNewPropInfo)
        icon:setTouchPriority(priority)
        icon:setPosition(ccp(starW,centerH))
        backSprie:addChild(icon)

        local numLb=GetTTFLabel(FormatNumber(rewardItem.num),20)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(icon:getContentSize().width-5,5))
        icon:addChild(numLb,4)
        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
        numBg:setAnchorPoint(ccp(1,0))
        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()))
        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
        numBg:setOpacity(150)
        icon:addChild(numBg,3) 

        if self.shop[id].isflick and tonumber(self.shop[id].isflick)==1 then
            G_addRectFlicker2(icon,1.2,1.2,2,"y")
        end

        local strSize2=18
        if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" or G_getCurChoseLanguage()=="tw" then
            strSize2=25
        end

        local desX=starW+60
        local desLb=GetTTFLabelWrap(getlocal(rewardItem.desc),strSize2,CCSizeMake(backSprie:getContentSize().width-desX-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0,0.5))
        desLb:setPosition(desX,centerH)
        backSprie:addChild(desLb)

        local btnX=backSprie:getContentSize().width-95
        local btnDes=getlocal("code_gift")
        if buyNum>=limit then
            btnDes=getlocal("activity_tccx_already_change")
        end
        local function touchBuy()
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                local function refreshFunc()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_change_sucess"),30)
                    G_showRewardTip({rewardItem},true)
                    G_addPlayerAward(rewardItem.type,rewardItem.key,rewardItem.id,rewardItem.num,nil,true)

                    if self.shop[id].notice and tonumber(self.shop[id].notice)==1 then
                        local desStr
                        desStr="activity_tccx_chatMessage1"
                        local paramTab={}
                        paramTab.functionStr="phlt"
                        paramTab.addStr="i_also_want"
                        local message={key=desStr,param={playerVoApi:getPlayerName(),getlocal("activity_phlt_title"),rewardItem.name}}
                        chatVoApi:sendSystemMessage(message,paramTab)
                    end
                    self:refresh()
                end
                acPhltVoApi:acPhltRequest({action=2,tid=id},refreshFunc)
            end
        end
        local buyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchBuy,nil,btnDes,25/0.8)
        buyItem:setScale(0.8)
        local buyBtn=CCMenu:createWithItem(buyItem);
        buyBtn:setTouchPriority(priority);
        buyBtn:setPosition(ccp(btnX,centerH-20))
        backSprie:addChild(buyBtn)

        local scoreLb=GetTTFLabel(nowCost,25)
        backSprie:addChild(scoreLb)
        scoreLb:setPosition(btnX,centerH+30)
        if nowCost>myPoint then
            scoreLb:setColor(G_ColorRed)
            buyItem:setEnabled(false)
        else
            scoreLb:setColor(G_ColorYellowPro)
        end

        if buyNum>=limit then
            scoreLb:setColor(G_ColorYellowPro)
            buyItem:setEnabled(false)
        end

        local scoreDesLb=GetTTFLabel(getlocal("activity_tccx_skilled_score1"),25)
        backSprie:addChild(scoreDesLb)
        scoreDesLb:setPosition(btnX,centerH+30+30)
        scoreDesLb:setColor(G_ColorYellowPro)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acPhltShop:updateUI()
    self:refresh()
end

function acPhltShop:refresh()
    if self.tv then
        self.trueShop=acPhltVoApi:getSortShop()
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    if self.scoreLb then
        self.scoreLb:setString(getlocal("activity_tccx_skilled_score2",{acPhltVoApi:getPoint()}))
    end
end

function acPhltShop:dispose()
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil
    self.tv=nil
    self.layerNum=nil
    spriteController:removePlist("public/acNewYearsEva.plist")
    spriteController:removeTexture("public/acNewYearsEva.png")
    spriteController:removePlist("public/yellowFlicker.plist")
    spriteController:removeTexture("public/yellowFlicker.png")
    spriteController:removePlist("public/activePicUseInNewGuid.plist")
    spriteController:removeTexture("public/activePicUseInNewGuid.png")
end