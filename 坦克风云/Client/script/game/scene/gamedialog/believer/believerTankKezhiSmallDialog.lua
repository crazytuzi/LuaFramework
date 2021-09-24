local believerTankKezhiSmallDialog=smallDialog:new()

function believerTankKezhiSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerTankKezhiSmallDialog:init(layerNum)
	self.isTouch=nil
	self.isUseAmi=true
	self.layerNum=layerNum
	self.bgSize=CCSizeMake(560,G_VisibleSizeHeight-300)

    spriteController:addPlist("public/believer/believerKezhi.plist")
    spriteController:addTexture("public/believer/believerKezhi.png")

    local dialogBg=G_getNewDialogBg2(self.bgSize,self.layerNum,nil,getlocal("believer_ke_zhi_title"),30)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local kezhiBgWidth,kezhiBgHeight=self.bgSize.width-30,self.bgSize.height-40
    local kezhiBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),function () end)
    kezhiBg:setContentSize(CCSizeMake(kezhiBgWidth,kezhiBgHeight))
    kezhiBg:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(kezhiBg)

    --克制图解
    local kezhiSp=CCSprite:createWithSpriteFrameName("kezhiFrame.png")
    kezhiSp:setAnchorPoint(ccp(0.5,1))
    kezhiSp:setPosition(ccp(kezhiBgWidth/2,kezhiBgHeight-20))
    kezhiBg:addChild(kezhiSp)

    local fontSize=25
    if G_getCurChoseLanguage~="cn" and G_getCurChoseLanguage~="tw" then
		fontSize=22
	end

    local promptLb=GetTTFLabelWrap(getlocal("believer_match_kezhi_desc"),25,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    promptLb:setAnchorPoint(ccp(0.5,1))
    promptLb:setPosition(ccp(self.bgSize.width/2,kezhiSp:getPositionY()-kezhiSp:getContentSize().height-28))
    promptLb:setColor(G_ColorGreen)
    kezhiBg:addChild(promptLb)

    --分割线
    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function () end)
    lineSp:setContentSize(CCSizeMake(self.bgSize.width-70,2))
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(ccp(kezhiBgWidth/2,promptLb:getPositionY()-promptLb:getContentSize().height-5))
    kezhiBg:addChild(lineSp)

    local believerCfg=believerVoApi:getBelieverCfg()
    local content1={}
    local content2={}
    table.insert(content1,getlocal("believer_match_weather_effect"))
    for k,v in pairs(believerCfg.weather) do
        local str=believerVoApi:getWeatherStr(v.id)
        table.insert(content1,str)
    end
    table.insert(content2,getlocal("believer_match_landform_effect"))
    for i=1,4 do
        table.insert(content2,getlocal("believer_match_landform_effect_"..i))
    end

    local fontSize=24
    local fontDiffY=5 -- 文件上下间隔
    local tvWidth,tvHeight=self.bgSize.width-30,lineSp:getPositionY()-110
    local fontWidth=tvWidth-60
    --先计算文字高度
    local function getCellHeight()
        local retHeight=fontDiffY+20 --10为风格线预留
        local label
        local labelHei
        for k,v in pairs(content1) do
            local label,lbheight=G_getRichTextLabel(v,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            retHeight=retHeight+lbheight+fontDiffY
        end
        for k,v in pairs(content2) do
            local label,lbheight=G_getRichTextLabel(v,{},fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            retHeight=retHeight+lbheight+fontDiffY
        end
        return retHeight
    end
    local cellHeight=getCellHeight()

    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(tvWidth,cellHeight)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local colorTb={}
            local lbPosY=cellHeight-5
            for k,v in pairs(content1) do
                local label,lbheight=G_getRichTextLabel(v,colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                label:setAnchorPoint(ccp(0,1))
                label:setPosition(40,lbPosY)
                cell:addChild(label)

                lbPosY=lbPosY-lbheight-5
            end 
            lbPosY=lbPosY-10

            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function () end)
            lineSp:setContentSize(CCSizeMake(tvWidth-40,2))
            lineSp:setPosition(ccp(tvWidth/2,lbPosY))
            cell:addChild(lineSp)

            lbPosY=lbPosY-15

            colorTb={G_ColorWhite,G_ColorGreen,G_ColorWhite}
            for k,v in pairs(content2) do
                local label,lbheight=G_getRichTextLabel(v,colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                label:setAnchorPoint(ccp(0,1))
                label:setPosition(40,lbPosY)
                cell:addChild(label)

                lbPosY=lbPosY-lbheight-5
            end
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end

    local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp((self.bgSize.width-tvWidth)/2,110))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv,2)
    --确定
    local function confirmHandler(tag,object)
        self:close()
    end
    local scale,priority=0.8,-(self.layerNum-1)*20-6
    local sureItem=G_createBotton(kezhiBg,ccp(kezhiBgWidth/2,40),{getlocal("ok"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirmHandler,scale,priority)

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

	self:show()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(0,0)
	return self.dialogLayer
end

function believerTankKezhiSmallDialog:dispose()
    self.tv=nil
    spriteController:removePlist("public/believer/believerKezhi.plist")
    spriteController:removeTexture("public/believer/believerKezhi.png")
end

return believerTankKezhiSmallDialog