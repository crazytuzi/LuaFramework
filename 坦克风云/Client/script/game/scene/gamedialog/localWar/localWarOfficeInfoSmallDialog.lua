localWarOfficeInfoSmallDialog=smallDialog:new()

function localWarOfficeInfoSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.dialogWidth=600
	self.dialogHeight=800

	-- self.parent=parent
	-- self.cityID=1
	return nc
end

function localWarOfficeInfoSmallDialog:init(layerNum,officeId,index)
	self.layerNum=layerNum
	self.officeId=officeId
	self.index=index

	if self.officeId==nil then
		do return end
	end

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()


	local cfg=localWarCfg.jobs[self.officeId]
	local title=cfg.title
	local pic=cfg.pic
	local buffTab=cfg.buff
	local bgHeight=250
	if buffTab then
		for k,v in pairs(buffTab) do
			if v and localWarCfg.buff[v] then
				local buffStr=localWarVoApi:getBuffStr(v)
				-- buffStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
				if buffStr and buffStr~="" then
					local buffLb=GetTTFLabelWrap(buffStr,25,CCSizeMake(self.dialogWidth-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					bgHeight=bgHeight+buffLb:getContentSize().height+20
				end
			end
		end
	end
	bgHeight=bgHeight+50


	self.dialogHeight=bgHeight
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);


	-- local function close()
	-- 	PlayEffect(audioCfg.mouseClick)
	-- 	return self:close()
	-- end
	-- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	-- closeBtnItem:setPosition(0,0)
	-- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	-- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	-- self.closeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	-- self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	-- dialogBg:addChild(self.closeBtn)


	
	local titleLb=GetTTFLabel(getlocal(title),40)
	titleLb:setAnchorPoint(ccp(0.5,0.5))
	titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
	dialogBg:addChild(titleLb)
	titleLb:setColor(G_ColorYellowPro)


	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	lineSp:setAnchorPoint(ccp(0.5,0.5))
	lineSp:setScaleX(self.dialogWidth/lineSp:getContentSize().width)
	lineSp:setScaleY(1.2)
	lineSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight-80))
	dialogBg:addChild(lineSp,2) 

	local officeSp
	local spScale=0.8
	local bgScale=1
	local playerInfo=localWarVoApi:getOfficeByType(self.officeId,self.index)
	-- if playerInfo and playerInfo[5] then
	-- 	-- pic="photo"..playerInfo[5]..".png"
 --    	spScale=1.3
 --    	bgScale=0.8/spScale
	-- end
    local officeSp
    if playerInfo and playerInfo[5] then
        officeSp=playerVoApi:getPersonPhotoSp(playerInfo[5])
        local scale=officeSp:getScale()
        spScale=scale*1.3
        bgScale=0.8/spScale
    else
        officeSp=CCSprite:createWithSpriteFrameName(pic)
    end
	officeSp:setPosition(ccp(86,size.height-160))
	dialogBg:addChild(officeSp)
	local officeBg=CCSprite:createWithSpriteFrameName("heroHead1.png")
	officeBg:setPosition(getCenterPoint(officeSp))
	officeSp:addChild(officeBg)
	officeSp:setScale(spScale)
	officeBg:setScale(bgScale)
	

	local lbTab={}
	local officerName=getlocal("alliance_info_content")
    
    if playerInfo and playerInfo[2] then
        playerName=playerInfo[2]
    end
	if playerInfo and SizeOfTable(playerInfo)>0 then
		officerName=playerInfo[2]
		local level=playerInfo[3] or 1
		local fight=playerInfo[4] or 0
		local lb1={getlocal("world_war_level",{level}),25,ccp(0,0.5),ccp(160,self.dialogHeight-165),dialogBg,1,G_ColorWhite,CCSize(self.dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter}
		local lb2={getlocal("world_war_power",{FormatNumber(fight)}),25,ccp(0,0.5),ccp(160,self.dialogHeight-205),dialogBg,1,G_ColorWhite,CCSize(self.dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter}
		table.insert(lbTab,lb1)
		table.insert(lbTab,lb2)
	end
	-- officerName="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
	local lb={officerName,30,ccp(0,0.5),ccp(160,self.dialogHeight-115),dialogBg,1,G_ColorWhite,CCSize(self.dialogWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter}
	table.insert(lbTab,lb)

	for k,v in pairs(lbTab) do
		local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
		local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
	end
	

	
	local buffPosY=self.dialogHeight-240
	if buffTab then
		for k,v in pairs(buffTab) do
			if v and localWarCfg.buff[v] then
				local buffStr=localWarVoApi:getBuffStr(v)
				-- buffStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
				if buffStr and buffStr~="" then
					local buffLb=GetTTFLabelWrap(buffStr,25,CCSizeMake(self.dialogWidth-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				    buffLb:setAnchorPoint(ccp(0,1))
					buffLb:setColor(G_ColorGreen)
					dialogBg:addChild(buffLb,2)
					buffLb:setPosition(ccp(35,buffPosY))
					local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
					lbBg:setAnchorPoint(ccp(0,1))
					lbBg:setContentSize(CCSizeMake(self.dialogWidth-40,buffLb:getContentSize().height+10))
					lbBg:setOpacity(180)
					lbBg:setPosition(ccp(20,buffPosY+5))
					dialogBg:addChild(lbBg,1)

					buffPosY=buffPosY-buffLb:getContentSize().height-20
					bgHeight=bgHeight+buffLb:getContentSize().height+20
				end
			end
		end
	end


    local function touchDialog()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1)
		
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

end



