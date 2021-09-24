newShowSureSmallDialog=smallDialog:new()

function newShowSureSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function newShowSureSmallDialog:showNewSure(layerNum,istouch,isuseami,titleStr,contentDes,pCallback)
	local sd=newShowSureSmallDialog:new()
    sd:initNewSure(layerNum,istouch,isuseami,titleStr,contentDes,pCallback)
    return sd
end

function newShowSureSmallDialog:initNewSure(layerNum,istouch,isuseami,titleStr,contentDes,pCallback)
	self.isTouch=istouch
    self.isUseAmi=isuseami
    self.layerNum=layerNum
    local nameFontSize=30


    base:removeFromNeedRefresh(self) --停止刷新

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayerColor:create(ccc4(0,0,0,180))
    self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local jianGeH=30
    local btnH=100
    local bgSize=CCSizeMake(560,10+jianGeH*2+btnH)

    local listDesLb=GetTTFLabelWrap(contentDes,25,CCSizeMake(bgSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    listDesLb:setColor(G_ColorWhite)

    local dialogBg2H=listDesLb:getContentSize().height+100
    bgSize.height=bgSize.height+dialogBg2H


    -- rewardItem
    local function touchHandler()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:setContentSize(bgSize)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)


    -- 标题
    local lightSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
    lightSp:setAnchorPoint(ccp(0.5,0.5))
    lightSp:setScaleX(3)
    lightSp:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-50)
    self.bgLayer:addChild(lightSp)

    local nameLb=GetTTFLabelWrap(titleStr,nameFontSize,CCSizeMake(320,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    nameLb:setAnchorPoint(ccp(0.5,0.5))
    nameLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(bgSize.width/2,bgSize.height-40)
    self.bgLayer:addChild(nameLb)

    local nameLb2=GetTTFLabel(titleStr,nameFontSize)
    local realNameW=nameLb2:getContentSize().width
    if realNameW>nameLb:getContentSize().width then
        realNameW=nameLb:getContentSize().width
    end
    for i=1,2 do
        local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
        local anchorX=1
        local posX=bgSize.width/2-(realNameW/2+20)
        local pointX=-7
        if i==2 then
            anchorX=0
            posX=bgSize.width/2+(realNameW/2+20)
            pointX=15
        end
        pointSp:setAnchorPoint(ccp(anchorX,0.5))
        pointSp:setPosition(posX,nameLb:getPositionY())
        self.bgLayer:addChild(pointSp)

        local pointLineSp=CCSprite:createWithSpriteFrameName("newPointLine.png")
        pointLineSp:setAnchorPoint(ccp(0,0.5))
        pointLineSp:setPosition(pointX,pointSp:getContentSize().height/2)
        pointSp:addChild(pointLineSp)
        if i==1 then
            pointLineSp:setRotation(180)
        end
    end

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,dialogBg2H))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    dialogBg2:setPosition(self.bgLayer:getContentSize().width/2,bgSize.height-60)
    self.bgLayer:addChild(dialogBg2)

    dialogBg2:addChild(listDesLb)
    listDesLb:setPosition(getCenterPoint(dialogBg2))



    local scale=0.8
    local function touchOKFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end 
        PlayEffect(audioCfg.mouseClick)
        if pCallback then
            pCallback()
        end
        self:close()
    end
    local okMenuItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOKFunc,2,getlocal("confirm"),25/scale)
    okMenuItem:setAnchorPoint(ccp(0.5,0.5))
    okMenuItem:setScale(scale)
    local okMenuBtn=CCMenu:createWithItem(okMenuItem)
    okMenuBtn:setPosition(ccp(self.bgLayer:getContentSize().width/2,60))
    okMenuBtn:setTouchPriority(-(self.layerNum-1)*20-3)
    self.bgLayer:addChild(okMenuBtn,2)



    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp2)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer

end