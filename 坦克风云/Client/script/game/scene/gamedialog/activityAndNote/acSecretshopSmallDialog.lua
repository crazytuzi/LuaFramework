acSecretshopSmallDialog=smallDialog:new()

function acSecretshopSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acSecretshopSmallDialog:showRefresh(layerNum,istouch,isuseami,callBack,titleStr,contentStr,costNum,parent)
	local sd=acSecretshopSmallDialog:new()
    sd:initRefresh(layerNum,istouch,isuseami,callBack,titleStr,contentStr,costNum,parent)
    return sd
end

function acSecretshopSmallDialog:initRefresh(layerNum,istouch,isuseami,pCallBack,titleStr,contentStr,costNum,parent)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    self.costNum=costNum
    self.parent=parent
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
        -- PlayEffect(audioCfg.mouseClick)
        -- if pCallBack then
        --     pCallBack()
        -- end
        -- self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(255)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local dgSize=CCSizeMake(600,260)

    local dialogWidth2=dgSize.width-40

    local contentLb=GetTTFLabelWrap(contentStr,24,CCSizeMake(dialogWidth2-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

    local dialogBg2H=contentLb:getContentSize().height+60
    dgSize.height=dgSize.height+dialogBg2H

    

    local function closeFunc()
        self:close()
    end
    local dialogBg=G_getNewDialogBg(dgSize,titleStr,30,nil,self.layerNum+1,true,closeFunc)
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer=dialogBg

    self:show()

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogWidth2,dialogBg2H))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,dgSize.height-100)
    self.bgLayer:addChild(dialogBg2)

    dialogBg2:addChild(contentLb)
    contentLb:setPosition(getCenterPoint(dialogBg2))


    local picStr1
    local picStr2
    if costNum==0 then
        picStr1="newGreenBtn.png"
        picStr2="newGreenBtn_down.png"
    else
        picStr1="creatRoleBtn.png"
        picStr2="creatRoleBtn_Down.png"
    end
    local function touchRefreshFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if pCallBack then
            pCallBack()
        end
        self:close()
    end
    local scale=160/207
    local refreshMenuItem=GetButtonItem(picStr1,picStr2,picStr2,touchRefreshFunc,1,getlocal("dailyTaskFlush"),24/scale)
    refreshMenuItem:setScale(scale)
    local refreshBtn = CCMenu:createWithItem(refreshMenuItem)
    dialogBg:addChild(refreshBtn,1)
    refreshBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    refreshBtn:setBSwallowsTouches(true)
    refreshBtn:setPosition(dialogBg:getContentSize().width/2,60)

    if costNum==0 then
        local freeLb=GetTTFLabel(getlocal("daily_lotto_tip_2"),22/scale)
        refreshMenuItem:addChild(freeLb)
        freeLb:setPosition(refreshMenuItem:getContentSize().width/2,90)
    else
        local costLb1=GetTTFLabel(costNum,22/scale)
        refreshMenuItem:addChild(costLb1)
        costLb1:setPositionY(90)
        local iconGold1=CCSprite:createWithSpriteFrameName("IconGold.png")
        iconGold1:setScale(1/scale*0.8)
        refreshMenuItem:addChild(iconGold1)
        iconGold1:setPositionY(95)
        G_setchildPosX(refreshMenuItem,costLb1,iconGold1)
    end


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end



function acSecretshopSmallDialog:tick()
end


function acSecretshopSmallDialog:dispose()
    self.parent=nil
    self.costNum=nil
end

