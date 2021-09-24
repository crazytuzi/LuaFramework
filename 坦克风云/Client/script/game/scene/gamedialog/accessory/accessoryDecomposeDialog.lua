accessoryDecomposeDialog=smallDialog:new()

function accessoryDecomposeDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.dialogHeight=400
    self.dialogWidth=550

    self.parent=nil
    self.data=nil
    self.type=0     --是配件还是碎片
    return nc
end

function accessoryDecomposeDialog:init(layerNum,type,voData,parent)
	self.layerNum=layerNum
    self.parent=parent
    self.type=type
    self.data=voData

	local function nilFunc()
	end

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    
    local sellMaterials,sellResource=accessoryVoApi:getSellItem(self.type,self.data)
    local mNum=0
    local keyTb={}
    local numTb={}
    for k,v in pairs(sellMaterials) do
        if(v>0)then
            mNum=mNum+1
            table.insert(keyTb,k)
            table.insert(numTb,v)
        end
    end
    if(sellResource>0)then
        mNum=mNum+1
        table.insert(numTb,sellResource)
    end

    local rowNum=math.floor((mNum-1)/2)+1
    if(rowNum==1)then
        self.dialogHeight=400
    elseif(rowNum==2)then
        self.dialogHeight=500
    else
        self.dialogHeight=600
    end
    local quality=self.data:getConfigData("quality")
    if quality>=3 then 
        self.dialogHeight=self.dialogHeight+100
    end

    local titleStr
    local quality=self.data:getConfigData("quality")
    if(self.type==1)then
        if(quality==1)then
            titleStr=getlocal("accessory_greenQuality")
        elseif(quality==2)then
            titleStr=getlocal("accessory_blueQuality")
        elseif(quality==3)then
            titleStr=getlocal("accessory_purpleQuality")
        elseif(quality==4)then
            titleStr=getlocal("accessory_orangeQuality")
        elseif(quality==5)then
            titleStr=getlocal("accessory_redQuality")
        else
            titleStr=getlocal("accessory")
        end
    else
        titleStr=getlocal("elite_challenge_fragment_"..quality,{""})
    end

    local size = CCSizeMake(self.dialogWidth,self.dialogHeight)
    local dialogBg = G_getNewDialogBg(size, titleStr, 28, nil, layerNum, true, close)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.dialogLayer:setBSwallowsTouches(true)

    --遮罩层
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    local tishiDesc=nil
    if quality>=3 then
        posX,posY=self.dialogWidth/2,self.dialogHeight-100
        tishiDesc=GetTTFLabelWrap(getlocal("promptBreakDown"),20,CCSizeMake(self.dialogWidth-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        tishiDesc:setAnchorPoint(ccp(0.5,1))
        tishiDesc:setPosition(ccp(posX,posY))
        dialogBg:addChild(tishiDesc)
        tishiDesc:setColor(G_ColorYellowPro)
    end
    if tishiDesc then
        posY=posY-tishiDesc:getContentSize().height-30
    else
        posX,posY=self.dialogWidth/2,self.dialogHeight-100
    end
    
    local sellDesc2=GetTTFLabelWrap(getlocal("accessory_sell_desc2"),25,CCSizeMake(self.dialogWidth-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    sellDesc2:setAnchorPoint(ccp(0.5,1))
    sellDesc2:setPosition(ccp(posX,posY))
    dialogBg:addChild(sellDesc2)

    posY=posY-sellDesc2:getContentSize().height
    local sellDesc=GetTTFLabel(getlocal("accessory_sell_desc"),25)
    sellDesc:setAnchorPoint(ccp(0.5,0))
    posY=posY-sellDesc:getContentSize().height-5
    sellDesc:setPosition(ccp(posX,posY))
    dialogBg:addChild(sellDesc)

    for i=1,mNum do
        local iconName
        local mIcon
        local name
        if(i==mNum and sellResource>0)then
            iconName="resourse_normal_gold.png"
            name=getlocal("money")
        else
            iconName=accessoryCfg.propCfg[keyTb[i]].icon
            name=getlocal("accessory_smelt_"..keyTb[i])
        end
        if(keyTb[i]=="p8" or keyTb[i]=="p9" or keyTb[i]=="p10")then
            mIcon=GetBgIcon(iconName,nil,nil,80,80)
        else
            mIcon=CCSprite:createWithSpriteFrameName(iconName)
            mIcon:setScale(80/mIcon:getContentSize().width)
        end
        mIcon:setAnchorPoint(ccp(0,0))
        if(i%2~=0)then
            posX=20
            posY=posY-90
        else
            posX=dialogBg:getContentSize().width/2
        end
        mIcon:setPosition(posX,posY)
        dialogBg:addChild(mIcon)
        local nameLb=GetTTFLabelWrap(name,25,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(posX+90,posY+60))
        dialogBg:addChild(nameLb)
        local numLb=GetTTFLabel("x"..FormatNumber(numTb[i]),25)
        numLb:setAnchorPoint(ccp(0,0))
        numLb:setPosition(ccp(posX+90,posY))
        dialogBg:addChild(numLb)
    end

    local function onClickCancel()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local cancelItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickCancel,2,getlocal("cancel"),24/0.7)
    cancelItem:setScale(0.7)
    local cancelBtn=CCMenu:createWithItem(cancelItem);
    cancelBtn:setPosition(ccp(size.width-120,60))
    cancelBtn:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(cancelBtn)

    local function onClickSell()
        PlayEffect(audioCfg.mouseClick)
        self:sell()
    end
    self.confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickSell,2,getlocal("confirm"),24/0.7)
    self.confirmItem:setScale(0.7)
    local confirmBtn=CCMenu:createWithItem(self.confirmItem);
    confirmBtn:setPosition(ccp(120,60))
    confirmBtn:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(confirmBtn)
        
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function accessoryDecomposeDialog:sell()
    local function callback(reward)
        local str=getlocal("accessory_sell_success")
        for k,v in pairs(reward) do
            local tmp
            if(k=="resource")then
                tmp=getlocal("money").." x"..FormatNumber(v)..","
            else
                tmp=getlocal("accessory_smelt_"..k).." x"..FormatNumber(v)..","
            end
            str=str..tmp
        end
        str=string.sub(str,1,string.len(str)-1)
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),str,30)
        if(self.parent~=nil)then
            self.parent:close()
        end
        self:close()
    end
    self.confirmItem:setEnabled(false)
    if(self.type==1)then
        accessoryVoApi:sellAccessory(1,self.data.id,callback)
    else
        accessoryVoApi:sellFragment(1,self.data.id,callback)
    end
end