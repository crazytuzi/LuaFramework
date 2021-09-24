languageDialog={

}

function languageDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.bgLayer=nil
    self.closeBtn=nil
    self.menuItemUse=nil
    self.lanTb={}
    self.chooseLan=nil;
    self.tv=nil
    return nc;

end

function languageDialog:initInfoLayer()
    local titleLb = GetTTFLabel(getlocal("choiceLanguage"),32,true)
    titleLb:setAnchorPoint(ccp(0.5,1))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2, self.bgLayer:getContentSize().height-20))
    self.bgLayer:addChild(titleLb,2)

    local capInSet = CCRect(20, 20, 10, 10)
    local function tmpFunc()
    end
    self.panelLineBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,tmpFunc)
    self.panelLineBg:setContentSize(CCSizeMake(560,self.bgLayer:getContentSize().height-105))
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-40))
    self.bgLayer:addChild(self.panelLineBg,1)



    self.tabLan={}
    local platLanTb=platCfg.platCfgLanType[G_curPlatName()]
    if platLanTb~=nil then
        for k,v in pairs(platLanTb) do
            table.insert(self.tabLan,k)
            -- self.tabLan[k]=k
        end
    end
    if((G_curPlatName()=="androidkunlun" and G_Version<8) or (G_curPlatName()=="androidkunlunz" and G_Version<4))then
        self.tabLan={"en"}
    end

    self.chooseLan=CCUserDefault:sharedUserDefault():getStringForKey(G_local_curLanguage)




    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-20,self.bgLayer:getContentSize().height-230),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(10,120))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)



    local function use()
        PlayEffect(audioCfg.mouseClick)
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_curLanguage,self.chooseLan)
        CCUserDefault:sharedUserDefault():flush()
        base:changeServer()
        self:close()
    end
    -- self.menuItemUse = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",use,nil,getlocal("choice_language_apply"),25);
    self.menuItemUse = GetButtonItem("yh_BigBtnBlue.png","yh_BigBtnBlue_Down.png","yh_BigBtnBlue_Down.png",use,nil,getlocal("choice_language_apply"),25);

    local useBtn = CCMenu:createWithItem(self.menuItemUse)
    useBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    useBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,65))
    self.bgLayer:addChild(useBtn,2)
    self.menuItemUse:setEnabled(false);

    --[[
   local function touch(object,name,tag)
        
        local sp1=self.bgLayer:getChildByTag(tag);
        sp1:setScale(1.2)
        
        for k,v in pairs(self.lanTb) do
            if v:getTag()~=tag then
                v:setScale(1)
            end
            
            if v:getTag()==tag then
                self.chooseLan=k;
            end
        end
        local curSelLan=CCUserDefault:sharedUserDefault():getStringForKey(G_local_curLanguage)
        if self.chooseLan==curSelLan then
          self.menuItemUse:setEnabled(false);
        else
          self.menuItemUse:setEnabled(true);
        end 

        
   end
   
   local sign=0;
   local tabLan={}
   local platLanTb=platCfg.platCfgLanType[G_curPlatName()]
   if platLanTb~=nil then
       for k,v in pairs(platLanTb) do
            tabLan[k]=k
       end
   end

   for k,v in pairs(tabLan) do
       sign=sign+1
       
       local name=platCfg.platCfgLanBtn[k]
       local chSp= LuaCCSprite:createWithSpriteFrameName(name,touch);
       if sign<=4 then
           chSp:setPosition(ccp(80+(sign-1)*140,self.bgLayer:getContentSize().height-200));
       else
           chSp:setPosition(ccp(80+(sign-5)*140,self.bgLayer:getContentSize().height-360));
       end
       chSp:setTag(sign);
       chSp:setIsSallow(true)
       chSp:setTouchPriority(-(self.layerNum-1)*20-2)
       self.bgLayer:addChild(chSp,2)
       self.lanTb[k]=chSp
local curSelLan=CCUserDefault:sharedUserDefault():getStringForKey(G_local_curLanguage)
       if k==curSelLan then
          chSp:setScale(1.2)
       end

   end


    local function use()
        PlayEffect(audioCfg.mouseClick)
        CCUserDefault:sharedUserDefault():setStringForKey(G_local_curLanguage,self.chooseLan)
            CCUserDefault:sharedUserDefault():flush()
        base:changeServer()
        self:close()
     end
    self.menuItemUse = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",use,nil,getlocal("choice_language_apply"),25);

    local useBtn = CCMenu:createWithItem(self.menuItemUse)
    useBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    useBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,80))
    self.bgLayer:addChild(useBtn,2)
    self.menuItemUse:setEnabled(false);
    ]]
end

function languageDialog:init(layerNum)

    self.layerNum=layerNum;

    local function tmpFunc()
    
    end
    
    self.bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",CCRect(168, 86, 10, 10),tmpFunc)
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(580,850)
    self.bgLayer:setContentSize(rect)
    self.bgLayer:ignoreAnchorPointForPosition(false)
    self.bgLayer:setAnchorPoint(CCPointMake(0.5,0.5))
    self.bgLayer:setPosition(CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
    
    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
     end
   local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0, 0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(rect.width-closeBtnItem:getContentSize().width,rect.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)
    
    self:initInfoLayer()
    
    
    
    local function touchDialog()
          
    end
    
    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(20, 20, 10, 10)
    
    -- local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png",capInSet,touchDialog);
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect1)
    touchDialogBg:setOpacity(0)
    touchDialogBg:ignoreAnchorPointForPosition(false)
    touchDialogBg:setAnchorPoint(CCPointMake(0.5,0.5))
    touchDialogBg:setPosition(getCenterPoint(self.bgLayer))

    self.bgLayer:addChild(touchDialogBg)
    sceneGame:addChild(self.bgLayer,layerNum)
    table.insert(G_SmallDialogDialogTb,self)

    --return self.bgLayer
end

function languageDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=0
        if self.tabLan then
            num=SizeOfTable(self.tabLan)
        end
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(560,90)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local country=""
        local name=""
        if self.tabLan and self.tabLan[idx+1] then
            country=self.tabLan[idx+1]
            name=platCfg.platCfgLanDesc[country]
        end
        
        local cellWidth=550
        local cellHeight=90
        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx1)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                PlayEffect(audioCfg.mouseClick)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end

                if self.tabLan and self.chooseLan~=self.tabLan[idx1+1] then
                    self.chooseLan=self.tabLan[idx1+1]
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)

                    local curSelLan=CCUserDefault:sharedUserDefault():getStringForKey(G_local_curLanguage)
                    if self.chooseLan==curSelLan then
                        self.menuItemUse:setEnabled(false)
                    else
                        self.menuItemUse:setEnabled(true)
                    end 
                end
                
            end
        end  

        local backSprie
        if self.chooseLan==country then
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBgSelect.png",CCRect(20, 20, 10, 10),cellClick)
        else
            -- backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
        end
        backSprie:setContentSize(CCSizeMake(cellWidth-10, cellHeight-10))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0,0.5))
        backSprie:setPosition(ccp(10,cellHeight/2))
        backSprie:setIsSallow(false)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setTag(idx)
        cell:addChild(backSprie)

        local checkBg = CCSprite:createWithSpriteFrameName("BtnCheckBg.png")
        checkBg:setAnchorPoint(ccp(1,0.5))
        checkBg:setPosition(ccp(backSprie:getContentSize().width-20,backSprie:getContentSize().height/2))
        backSprie:addChild(checkBg,1)

        if self.chooseLan==country then
            local checkIcon = CCSprite:createWithSpriteFrameName("BtnCheck.png")
            --checkIcon:setAnchorPoint(ccp(0,0.5))
            checkIcon:setPosition(getCenterPoint(checkBg))
            checkBg:addChild(checkIcon,1)
        end

        local countryLabel=GetTTFLabel(name,28)
        countryLabel:setAnchorPoint(ccp(0,0.5))
        countryLabel:setPosition(ccp(15,backSprie:getContentSize().height/2))
        backSprie:addChild(countryLabel,1)
        countryLabel:setColor(G_ColorGreen)
    
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
        
    end
end



function languageDialog:close()
    self.bgLayer:removeFromParentAndCleanup(true)
    self:dispose()
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end
function languageDialog:dispose()
    self.menuItemUse=nil
    self.lanTb={}
    self.chooseLan=nil
    self.bgLayer=nil
    self.closeBtn=nil
    self.tv=nil
end
