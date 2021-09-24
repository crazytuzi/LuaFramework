ltzdzSelectTankSmallDialog=smallDialog:new()

function ltzdzSelectTankSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- pType 
function ltzdzSelectTankSmallDialog:showTankList(layerNum,istouch,isuseami,callBack,titleStr,
    pType,cid)
	local sd=ltzdzSelectTankSmallDialog:new()
    sd:initTankList(layerNum,istouch,isuseami,callBack,titleStr,
        pType,cid)
    return sd
end

function ltzdzSelectTankSmallDialog:initTankList(layerNum,istouch,isuseami,pCallBack,titleStr,
    pType,cid)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.cid=cid
    self.pType=pType

    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzSelectTankSmallDialog",self)


    -- limitNum 带兵量限制
    self.limitNum=0
    local fightNum=ltzdzFightApi:getFightNum()
    local emblemID = emblemVoApi:getTmpEquip(self.pType)
    local addNum=0
    if emblemID then
        local emTroopVo=ltzdzFightApi:getEmblemTroopById(emblemID)
        addNum=emblemVoApi:getTroopsAddById(emblemID,emTroopVo)
    end
    self.limitNum=fightNum+addNum





    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

     local function touchLuaSpr()
        -- PlayEffect(audioCfg.mouseClick)
        -- return self:close()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local bgSize=CCSizeMake(600,760)

    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(bgSize,titleStr,25,nil,self.layerNum,true,closeFunc,G_ColorBlue)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.bgLayer=dialogBg

    local tvBgH=450
    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,tvBgH))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-70)
    self.bgLayer:addChild(tvBg)

    G_addForbidForSmallDialog2(dialogBg,tvBg,-(self.layerNum-1)*20-3,nil,1)


    self.cellWidth=600
    self.cellHeight=210
    local clancrossinfo=ltzdzVoApi.clancrossinfo or {}
    self.keyTable=clancrossinfo.troops or {}
    local totalNum=SizeOfTable(self.keyTable)
    self.hei=math.ceil(totalNum/3)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,tvBgH-20),nil)
    self.tv:setTableViewTouchPriority((-(self.layerNum-1)*20-3))
    self.tv:setPosition(ccp(0,tvBg:getPositionY()-tvBgH+10))
    self.bgLayer:addChild(self.tv,3)
    self.tv:setMaxDisToBottomOrTop(120)

    

    local btnScale=1
    local btnlbSize=25
    local btnY=30+40
    local function touchOkFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if pCallBack and self.selectTankId then
            local num=math.ceil(self.slider:getValue())
            pCallBack(self.selectTankId,num)
        end
        self:close()
    end
    local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOkFunc,nil,getlocal("confirm"),btnlbSize/btnScale)
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    okItem:setScale(btnScale)
    okBtn:setPosition(self.bgLayer:getContentSize().width/2+125,btnY)
    self.bgLayer:addChild(okBtn)

    local function touchCancelFunc()
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
    local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",touchCancelFunc,nil,getlocal("cancel"),btnlbSize/btnScale)
    local cancelBtn=CCMenu:createWithItem(cancelItem)
    cancelBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    cancelItem:setScale(btnScale)
    cancelBtn:setPosition(self.bgLayer:getContentSize().width/2-125,btnY)
    self.bgLayer:addChild(cancelBtn)

    -- 滑动条
    local sliderH=150
    local m_numLb=GetTTFLabel(" ",30)
    m_numLb:setPosition(80,sliderH)
    self.bgLayer:addChild(m_numLb,2)
    

    self.reserveNum=ltzdzFightApi:getCanUseTroopsNum(self.pType,self.cid)


    local function sliderTouch(handler,object)
        local newValue = object:getValue()
        local formatValue = string.format("%.2f",newValue)
        local valueNum = tonumber(formatValue)
        local count = math.ceil(valueNum)
        if count>self.reserveNum then
            count=self.reserveNum
            object:setValue(count)

        end
        if self.reserveLb then
            self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-count}))
        end
        if count>0 then
            m_numLb:setString(count)
        end
    end
    local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
    local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
    local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
    self.slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
    self.slider:setTouchPriority(-(layerNum-1)*20-5);
    self.slider:setIsSallow(true);
    
    if self.reserveNum==0 then
        self.slider:setMinimumValue(0);
        self.slider:setMaximumValue(0);
    else
        self.slider:setMinimumValue(1);
        self.slider:setMaximumValue(self.limitNum)
    end
    
    
    self.slider:setValue(self.reserveNum);
    self.slider:setPosition(ccp(365,sliderH))
    self.slider:setTag(99)
    self.bgLayer:addChild(self.slider,2)
    m_numLb:setString(math.ceil(self.slider:getValue()))
    self.m_numLb=m_numLb

    local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
    bgSp:setAnchorPoint(ccp(0,0.5));
    bgSp:setPosition(15,sliderH);
    self.bgLayer:addChild(bgSp,1);
    
    
    local function touchAdd()
        local nowValue=math.ceil(self.slider:getValue())
        if nowValue+1<=self.reserveNum then
            self.slider:setValue(nowValue+1)
            if self.reserveLb then
                self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-nowValue-1}))
            end
        end
    end
    
    local function touchMinus()
        local nowValue=math.ceil(self.slider:getValue())
        if nowValue-1>0 then
            self.slider:setValue(nowValue-1);
            if self.reserveLb then
                self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-nowValue+1}))
            end
        end
    
    end
    
    local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
    addSp:setPosition(ccp(560,sliderH))
    self.bgLayer:addChild(addSp,1)
    addSp:setTouchPriority(-(layerNum-1)*20-4);
    
    
    local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
    minusSp:setPosition(ccp(168,sliderH))
    self.bgLayer:addChild(minusSp,1)
    minusSp:setTouchPriority(-(layerNum-1)*20-4)

    -- 预备役显示
    local nowValue=math.ceil(self.slider:getValue())
    local reserveLb=GetTTFLabel(getlocal("ltzdz_reserve",{self.reserveNum-nowValue}),25)
    self.bgLayer:addChild(reserveLb)
    reserveLb:setAnchorPoint(ccp(0.5,0.5))
    reserveLb:setPosition(bgSize.width/2,sliderH+60)
    self.reserveLb=reserveLb


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end

function ltzdzSelectTankSmallDialog:eventHandler(handler,fn,idx,cel)
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
       local tmpSize
       tmpSize=CCSizeMake(self.cellWidth,self.hei*self.cellHeight)
       return tmpSize
   elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local totalHeight=self.hei*self.cellHeight

        for k,v in pairs(self.keyTable) do
            local bgWidth -- 宽度
            local bgHeight -- 高度

            local numId=k

            local remainder=numId%3 -- 余数
            if remainder==1 then
                bgWidth=self.cellWidth/2-170
            elseif remainder==2 then
                bgWidth=self.cellWidth/2
            else
                bgWidth=self.cellWidth/2+170
            end

            local bussess=math.ceil(numId/3)

            bgHeight=totalHeight-(bussess-1)*self.cellHeight-self.cellHeight/2

            -- local index=v.index
            local key=tonumber(RemoveFirstChar(v))

            local backSprie
            local tankIcon
            local function cellClick(hd,fn,tag)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end

                    if tag==self.selectTankId then
                        return
                    end
                    PlayEffect(audioCfg.mouseClick)

                    self.selectTankId=tag

                    self.slider:setValue(self.reserveNum)
                    local nowValue=math.ceil(self.slider:getValue())
                    self.reserveLb:setString(getlocal("ltzdz_reserve",{self.reserveNum-nowValue}))
                   
                    -- local child=tolua.cast(cell:getChildByTag(tag),"LuaCCScale9Sprite")
                    -- if self.selectSp and child then
                        self.selectSp:setPosition(backSprie:getPositionX(),backSprie:getPositionY()+(backSprie:getContentSize().height/2-tankIcon:getContentSize().height/2))
                    -- end
                end
            end

            backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
            backSprie:setContentSize(CCSizeMake(150, self.cellHeight-5))
            backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
            backSprie:setPosition(bgWidth,bgHeight)
            backSprie:setTag(key)
            cell:addChild(backSprie,1)
            backSprie:setOpacity(0)

            local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
            lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-70,lineSp:getContentSize().height))
            lineSp:setPosition(ccp(self.cellWidth/2,bgHeight-self.cellHeight/2))
            cell:addChild(lineSp)

            local backSize=backSprie:getContentSize()


            local function showInfoHandler(hd,fn,idx)
                if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)
                    -- local id = G_pickedList(key)
                    local tankInfo=ltzdzFightApi:getTankInfoByTid("a" .. key)
                    require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTankInfoDialog"
                    ltzdzTankInfoDialog:create(nil,tonumber(key),self.layerNum+1,true,tankInfo)

                end
            end
            local tipItem = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfoHandler,nil,nil,nil)
            local spScale=0.7
            tipItem:setScale(spScale)
            local tipMenu = CCMenu:createWithItem(tipItem)
            tipMenu:setPosition(bgWidth+backSize.width/2-10-tipItem:getContentSize().width/2*spScale,bgHeight+backSize.height/2-10-tipItem:getContentSize().height/2*spScale)
            tipMenu:setTouchPriority(-(self.layerNum-1)*20-2)
            cell:addChild(tipMenu,3)

            local skinId = ltzdzFightApi:getSkinIdByTankId(key)
            tankIcon=tankVoApi:getTankIconSp(key,skinId,nil,false)
            backSprie:addChild(tankIcon)
            tankIcon:setPosition(backSize.width/2,backSize.height-tankIcon:getContentSize().height/2)

            if k==1 then
                local function nilFunc()
                end
                self.selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("newSelectKuang.png",CCRect(30, 30, 1, 1),nilFunc)
                cell:addChild(self.selectSp,2)
                self.selectSp:setPosition(backSprie:getPositionX(),backSprie:getPositionY()+(backSize.height/2-tankIcon:getContentSize().height/2))
                self.selectSp:setContentSize(tankIcon:getContentSize())
                -- self.selectSp:setContentSize(backSize)
                self.selectTankId=key
            end

            

            

            local nameLb=GetTTFLabelWrap(getlocal(tankCfg[key].name),22,CCSizeMake(24*7,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,0.5));
            nameLb:setPosition(ccp(backSize.width/2,30));
            backSprie:addChild(nameLb,2)

            if G_pickedList(key)~=key then
                local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
                tankIcon:addChild(pickedIcon)
                pickedIcon:setPosition(tankIcon:getContentSize().width*0.7,tankIcon:getContentSize().height*0.5-20)
            end
            
        end

        -- if #self.keyTable==0 then
            -- local noTankLb = GetTTFLabelWrap(noTankStr,25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            --   backSprie:addChild(noTankLb)
            --   noTankLb:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height/2+50)
        -- end
        
       return cell
       
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end


function ltzdzSelectTankSmallDialog:dispose()
    self.keyTable=nil
    self.hei=nil
    self.selectTankId=nil
    self.selectSp=nil
    self.tankTable=nil
    self.cid=nil
    self.pType=nil
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzSelectTankSmallDialog")
end