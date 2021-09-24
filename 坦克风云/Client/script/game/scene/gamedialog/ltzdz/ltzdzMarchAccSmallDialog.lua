ltzdzMarchAccSmallDialog=smallDialog:new()

function ltzdzMarchAccSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- tid 计策id cid:出发的城市 sid：队列号
function ltzdzMarchAccSmallDialog:showMarchAcc(layerNum,istouch,isuseami,callBack,titleStr,parent,accDes,tid,cid,sid)
	local sd=ltzdzMarchAccSmallDialog:new()
    sd:initMarchAcc(layerNum,istouch,isuseami,callBack,titleStr,parent,accDes,tid,cid,sid)
    return sd
end

function ltzdzMarchAccSmallDialog:initMarchAcc(layerNum,istouch,isuseami,pCallBack,titleStr,parent,accDes,tid,cid,sid)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.parent=parent
    self.scoutInfo=scoutInfo
    local nameFontSize=30


    -- base:removeFromNeedRefresh(self) --停止刷新
    base:addNeedRefresh(self)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local function touchLuaSpr()
        
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dialogSize=CCSizeMake(580,250)

    local listDesLb=GetTTFLabelWrap(accDes,25,CCSizeMake(dialogSize.width-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    listDesLb:setAnchorPoint(ccp(0,0.5))

    local dialogBg2H=listDesLb:getContentSize().height+80
    dialogSize.height=dialogSize.height+dialogBg2H



    local function touchDialogBg()
        -- print("touchDialogBg")
    end
    local function closeFunc()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg=G_getNewDialogBg(dialogSize,titleStr,28,touchDialogBg,self.layerNum,true,closeFunc,G_ColorWhite)
    dialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)

    self.bgLayer=dialogBg

    self:show()

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogSize.width-40,dialogBg2H))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    dialogBg2:setPosition(dialogSize.width/2,dialogSize.height-105)
    self.bgLayer:addChild(dialogBg2)

    dialogBg2:addChild(listDesLb)
    listDesLb:setPosition(20,dialogBg2:getContentSize().height/2)



    local tValue=ltzdzFightApi:getTvalueByTid(tid)
    local propNum=ltzdzFightApi:getPropNumByTid(tid)
    local function touchStudy()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local flag=ltzdzFightApi:isGemsEnough(tValue.gemCost)
        if flag==false then --金币不足
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("notEnoughGem"),30) 
            do return end
        end
        local function refreshFunc()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_use_success",{ltzdzVoApi:getStratagemInfoById(tid)}),30)
            if pCallBack then
                pCallBack()
            end
            self:close()
        end
        ltzdzFightApi:buyOrUsePropsRequest(2,tid,1,refreshFunc,cid,sid)
    end
    local function touchUse()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()

        end
        PlayEffect(audioCfg.mouseClick)
        local function refreshFunc()
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_use_success",{ltzdzVoApi:getStratagemInfoById(tid)}),30)
            if pCallBack then
                pCallBack()
            end
            self:close()
        end
        local propNum=ltzdzFightApi:getPropNumByTid(tid)
        if propNum>0 then
            ltzdzFightApi:buyOrUsePropsRequest(2,tid,0,refreshFunc,cid,sid)
        else
            self:close()
            ltzdzVoApi:showStratagemDialog(self.layerNum,"t2")
        end
    end
    local menuItem={}
    local scale=0.8
    local menuLbSize=25/scale
    menuItem[1]=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchStudy,nil,getlocal("ltzdz_one_key_study"),menuLbSize)
    menuItem[2]=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchUse,nil,getlocal("use"),menuLbSize)
    menuItem[1]:setScale(scale)
    menuItem[2]:setScale(scale)

    local btnMenu = CCMenu:create()
    btnMenu:addChild(menuItem[1])
    btnMenu:addChild(menuItem[2])
    btnMenu:alignItemsHorizontallyWithPadding(150)
    self.bgLayer:addChild(btnMenu)
    btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    btnMenu:setBSwallowsTouches(true)
    btnMenu:setPosition(self.bgLayer:getContentSize().width/2,60)

    

    local costH=95
    local costSize=25
    local goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldSp1:setAnchorPoint(ccp(0.5,0.5))
    goldSp1:setPositionY(costH)
    menuItem[1]:addChild(goldSp1)
    goldSp1:setScale(1/scale)

    local gemsLabel1=GetTTFLabel(tValue.gemCost,costSize/scale)
    gemsLabel1:setAnchorPoint(ccp(0.5,0.5))
    gemsLabel1:setPositionY(costH)
    menuItem[1]:addChild(gemsLabel1,1)

    
    local haveLb=GetTTFLabel(getlocal("emblem_infoOwn",{propNum}),costSize/scale)
    menuItem[2]:addChild(haveLb)
    haveLb:setPosition(menuItem[2]:getContentSize().width/2,costH)

    G_setchildPosX(menuItem[1],goldSp1,gemsLabel1)

    


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end





function ltzdzMarchAccSmallDialog:tick()
end


function ltzdzMarchAccSmallDialog:dispose()
    self.scoutInfo=nil
    self.parent=nil
end

