tankBufSmallDialog=smallDialog:new()

function tankBufSmallDialog:new(layerNum,tankId,curTankNums)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.tankId = tankId 
    self.curTankNums = curTankNums
    self.layerNum=layerNum
    self.wholeBgSp=nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    self.dialogLayer=nil
    self.bufAllTb={}
    return nc
end

function tankBufSmallDialog:init(bufAllTb)
    self.dialogWidth=500
    self.dialogHeight=550
    self.bufAllTb =bufAllTb
    if SizeOfTable(bufAllTb)>8 then
        self.dialogHeight =600
    end
    self.isTouch=nil
    local addW = 110
    local addH = 130
    local function nilFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()
    self.dialogLayer:addChild(self.bgLayer,1)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local bgSp =CCSprite:createWithSpriteFrameName(tankCfg[self.tankId].icon)--G_getItemIcon(tankCfg[self.tankId].icon,100,false,self.layerNum,nil)
    bgSp:setAnchorPoint(ccp(0,1))
    bgSp:setPosition(30, self.dialogHeight-40)
    bgSp:setScale(100/bgSp:getContentSize().width)
    dialogBg:addChild(bgSp)

    local tankData = {getlocal(tankCfg[self.tankId].name),getlocal("schedule_ship_num",{self.curTankNums})}
    for i=1,2 do

        local tankStrShow=GetTTFLabel(tankData[i],25)
        tankStrShow:setAnchorPoint(ccp(0,1))
        tankStrShow:setPosition(bgSp:getPositionX()+bgSp:getContentSize().width-15, bgSp:getPositionY()-(i-1)*50-5)
        dialogBg:addChild(tankStrShow,1)
    end

    local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX(self.dialogWidth*0.8/lineSP:getContentSize().width)
    lineSP:setPosition(ccp(self.dialogWidth*0.5,bgSp:getPositionY()-130))
    dialogBg:addChild(lineSP,2)

    local addW = 110
    local addH = 130
    local cellHeight = bgSp:getPositionY()-150
    for k,v in pairs(self.bufAllTb) do
        local aHeight = math.floor((v.idx-1)/4)
        local awidth = v.idx%4
        if awidth==0 then
            awidth=4
        end
        local bufSp =CCSprite:createWithSpriteFrameName(v.iconName)--G_getItemIcon(v,100,true,self.layerNum,nil)
        bufSp:setPosition(80+addW*(awidth-1), cellHeight-60-130*aHeight)
        bufSp:setScale(100/bufSp:getContentSize().width)
        dialogBg:addChild(bufSp)

        if v.num then
         local numBg = CCSprite:createWithSpriteFrameName("numBg.png")
         numBg:setAnchorPoint(ccp(1,0))
         numBg:setPosition(ccp(bufSp:getContentSize().width-8,8))
         bufSp:addChild(numBg)
         numBg:setScale(bufSp:getContentSize().height*0.3/numBg:getContentSize().height)

         local num = v.num
         local numStr = GetTTFLabel(num,23)
         numStr:setAnchorPoint(ccp(0.5,0.5))
         numStr:setPosition(getCenterPoint(numBg))
         numBg:addChild(numStr)
         numStr:setScale(numBg:getContentSize().height/numStr:getContentSize().height)
        end
    end

    local function nilFunc2()
        print("close()---------")
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc2)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function tankBufSmallDialog:dispose()
    self.id = nil
    self.checkSp = nil
    self.item = nil
    self.wholeBgSp=nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    self.dialogLayer=nil
    self.bufAllTb=nil
end
function tankBufSmallDialog:close()

    self.id = nil
    self.checkSp = nil
    self.item = nil
    self.wholeBgSp=nil
    self.dialogWidth=nil
    self.dialogHeight=nil
    self.isTouch=nil
    self.bgLayer=nil
    self.bgSize=nil
    self.bufAllTb=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    -- if self and self.bgLayer then
    --     self.bgLayer:removeFromParentAndCleanup(true)
    --     self.bgLayer=nil
    -- end
    base:removeFromNeedRefresh(self)
end