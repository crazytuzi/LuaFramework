acMingjiangpeiyangSmallDialog=smallDialog:new()

function acMingjiangpeiyangSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acMingjiangpeiyangSmallDialog:showRewardItemDialog(bgSrc,size,inRect,title,content,isuseami,layerNum,callBackHandler)
  	local sd=acMingjiangpeiyangSmallDialog:new()
	sd:initRewardItemDialog(bgSrc,size,inRect,title,content,isuseami,layerNum,callBackHandler)
end

function acMingjiangpeiyangSmallDialog:showGetRewardItemsDialog(bgSrc,size,inRect,title,rewardPromptStr,heroExistStr,content,isuseami,layerNum,addDesc,btnName1,btnCallBack1,btnName2,btnCallBack2,cost,isShowBtn1,isShowBtn2,promptColor,noNumBg,useNewUI)
  	local sd=acMingjiangpeiyangSmallDialog:new()
	sd:initGetRewardItemsDialog(bgSrc,size,inRect,title,rewardPromptStr,heroExistStr,content,isuseami,layerNum,addDesc,btnName1,btnCallBack1,btnName2,btnCallBack2,cost,isShowBtn1,isShowBtn2,promptColor,noNumBg,useNewUI)
end

function acMingjiangpeiyangSmallDialog:showRewardsRecordDialog(bgSrc,size,inRect,title,content,isuseami,layerNum,callBackHandler,scrollEnable,recordNum,titleSize,LableSize,noticeVisivle,bsVisivle,bigScroll,useNewUI)
  	local sd=acMingjiangpeiyangSmallDialog:new()
	sd:initRewardsRecordDialog(bgSrc,size,inRect,title,content,isuseami,layerNum,callBackHandler,scrollEnable,recordNum,titleSize,LableSize,noticeVisivle,bsVisivle,bigScroll,useNewUI)
end

function acMingjiangpeiyangSmallDialog:showSearchRewardsDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,isRefitTank,msgContent,isAddDesc,addDesc,isRebates,isJunshijiangtan,isVip,isXxjl,addDestr,addDestr2,opacity)
	local sd=acMingjiangpeiyangSmallDialog:new()
	sd:initSearchRewardsDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,isRefitTank,msgContent,isAddDesc,addDesc,isRebates,isJunshijiangtan,isVip,isXxjl,addDestr,addDestr2,opacity)
end

function acMingjiangpeiyangSmallDialog:initRewardItemDialog(bgSrc,size,inRect,title,content,isuseami,layerNum,callBackHandler)
	local strSize2 = 16
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =22
	end
	local function nilFunc() end
	if bgSrc==nil or bgSrc=="" then
		bgSrc="TankInforPanel.png"
	end
	self.isUseAmi=isuseami
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgSize=size
	self.bgLayer:setContentSize(size)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	local posY=self.bgSize.height-70
	if title then
	  	local titleLb=GetTTFLabelWrap(title,35,CCSize(self.bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleLb:setAnchorPoint(ccp(0.5,0.5))
	    titleLb:setPosition(ccp(self.bgSize.width/2,posY))
	    self.bgLayer:addChild(titleLb)
	    posY=posY-titleLb:getContentSize().height
	end
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setScaleX(self.bgSize.width/lineSp:getContentSize().width)
    lineSp:setPosition(ccp(self.bgSize.width/2,posY))
    self.bgLayer:addChild(lineSp)

    local iconSize=100
	local rewardCount=SizeOfTable(content)
	local firstPosX=self.bgSize.width/2-iconSize/2
	local spaceX=0
	if rewardCount==2 then
		firstPosX=self.bgSize.width/2-150
		spaceX=self.bgSize.width-2*firstPosX-2*100
	elseif rewardCount>=3 then
		firstPosX=60
		spaceX=(self.bgSize.width-2*firstPosX-3*100)/2
	end
	posY=posY-30-iconSize
	for k,v in pairs(content) do
        local icon,scale=G_getItemIcon(v,iconSize,true,layerNum) 
        if icon then
        	local subNUm=0
        	if k%3==0 then
        		subNUm=3
        	else
        		subNUm=k%3
        	end
            icon:setAnchorPoint(ccp(0,0))
            icon:setPosition(ccp(firstPosX+(subNUm-1)*(spaceX+iconSize),posY))
            icon:setTouchPriority(-(layerNum-1)*20-3)
            self.bgLayer:addChild(icon,1)
            icon:setScale(scale)
           	local nameLable=GetTTFLabelWrap(v.name,strSize2,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	        nameLable:setAnchorPoint(ccp(0.5,1))
	        nameLable:setPosition(ccp(icon:getContentSize().width/2,-10))
	        icon:addChild(nameLable,1)
	        if tonumber(v.num)>0 and v.type~="h" then
		        local numLable=GetTTFLabel(v.num,22)
		        numLable:setAnchorPoint(ccp(1,0))
		        numLable:setScale(1/scale)
		        numLable:setPosition(ccp(icon:getContentSize().width*scale-5,0))
		        icon:addChild(numLable,1)
	        end
        end
        if k%3==0 then
        	posY=posY-150
        end
	end
	local function close()
		-- print("close()---------")
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	--确定
    local function sureHandler()
    	-- print("sureHandler--------")
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
		if callBackHandler ~=nil then
			-- print("callbackSure------~~~~~")
			callBackHandler()
		end
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,70))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    self.bgLayer:addChild(sureMenu)

    local function nilFunc() end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function acMingjiangpeiyangSmallDialog:initGetReward(str)
  local km={"{","[","]","}",",",":","\""}
  for i=1,10 do
    table.insert(km,string.char(47 + i))
  end
  for i=1,26 do
    table.insert(km,string.char(64 + i))
  end
  for i=1,26 do
    table.insert(km,string.char(96 + i))
  end
  local km2={}
  for k,v in pairs(km) do
    km2[v]=k
  end
  local mapLength=#km
  local offset=playerVoApi:getRegdate()%mapLength
  if(offset==0)then
    offset=13
  end
  if(str==nil or type(str)~="string")then
  	return str
  end
  local strLen=string.len(str)
  local realStrTb={}
  for i=1,strLen do
    local char=string.sub(str,i,i)
    local index=km2[char]
    if(index)then
      index=index + offset
      if(index>mapLength)then
        index=index - mapLength
      end
      char=km[index]
    end
    table.insert(realStrTb,char)
  end
  local realStr=table.concat(realStrTb)
  return realStr
end

function acMingjiangpeiyangSmallDialog:initGetRewardItemsDialog(bgSrc,size,inRect,title,rewardPromptStr,heroExistStr,content,isuseami,layerNum,addDesc,btnName1,btnCallBack1,btnName2,btnCallBack2,cost,isShowBtn1,isShowBtn2,promptColor,noNumBg,useNewUI)
	local strSize2 = 22
	if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
		strSize2 =25
	end
   	local dialogH=240
	local titleBgH=0
	local titleLb
	local descLb
	local promptLb
	local existLb
	if title then
	  	titleLb=GetTTFLabelWrap(title,30,CCSize(size.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleBgH=titleBgH+titleLb:getContentSize().height
	    dialogH=dialogH+titleLb:getContentSize().height
	end
	if addDesc and addDesc~="" then
		descLb=GetTTFLabelWrap(addDesc,22,CCSize(size.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleBgH=titleBgH+descLb:getContentSize().height+10 
	    dialogH=dialogH+descLb:getContentSize().height+10
	end
	if rewardPromptStr and rewardPromptStr~="" then
		promptLb=GetTTFLabelWrap(rewardPromptStr,22,CCSize(size.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleBgH=titleBgH+promptLb:getContentSize().height+10
	    dialogH=dialogH+promptLb:getContentSize().height+10 
	end
	if heroExistStr and heroExistStr~="" then
		existLb=GetTTFLabelWrap(heroExistStr,22,CCSize(size.width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		dialogH=dialogH+existLb:getContentSize().height+10
	end
	dialogH=dialogH+20
    local iconSize=100
    local namePosY=-10
    local nameHeight=0
    for k,v in pairs(content) do
    	local item=v.award
	    if item.type=="h" then
	    	namePosY=-15
	    end
		local nameLb=GetTTFLabelWrap(item.name,22,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
		local realH=nameLb:getContentSize().height
		if realH>nameHeight then
			nameHeight=realH
		end
    end
   	local propHeight=100+math.abs(namePosY)+nameHeight+10
    local rcount=SizeOfTable(content)
	if rcount>=3 then
		tvHeight=2.5*propHeight
	end
    if rcount%3>0 then
    	rcount=math.floor(rcount/3)+1
    else
    	rcount=math.floor(rcount/3)
    end
	local cellWidth=size.width
	local cellHeight=rcount*propHeight
	local tvHeight=rcount*propHeight
    if rcount<=2 then
        dialogH=dialogH+rcount*propHeight
    else
    	dialogH=dialogH+2.2*propHeight
    	tvHeight=2.2*propHeight
    end
	local function nilFunc() end
	if bgSrc==nil or bgSrc=="" then
		bgSrc="TankInforPanel.png"
	end
	self.isUseAmi=isuseami
	local dialogBg,newUseTitleBg,newUseTitle
    -- if useNewUI==true then
    --     dialogBg = G_getNewDialogBg(size,nil,nil,nilFunc,layerNum)
    -- else
		dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,nilFunc)
	-- end
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	size=CCSizeMake(size.width,dialogH)
	self.bgSize=size
	self.bgLayer:setContentSize(size)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	if isShowBtn1==nil then
		isShowBtn1=true
	end
	if isShowBtn2==nil then
		isShowBtn2=true
	end
	local spriteTitle = CCSprite:createWithSpriteFrameName("ShapeTank.png")
	spriteTitle:setAnchorPoint(ccp(0.5,0.5))
	spriteTitle:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
	self.bgLayer:addChild(spriteTitle,1)

	local spriteTitle1 = CCSprite:createWithSpriteFrameName("ShapeGift.png");
	spriteTitle1:setAnchorPoint(ccp(0.5,0.5));
	spriteTitle1:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
	self.bgLayer:addChild(spriteTitle1,1)

	local spriteShapeInfor = CCSprite:createWithSpriteFrameName("ShapeAperture.png");
	spriteShapeInfor:setScale(1.2)
	spriteShapeInfor:setOpacity(200)
    spriteShapeInfor:setAnchorPoint(ccp(0.5,0.5))
    spriteShapeInfor:setPosition(ccp(self.bgSize.width/2,self.bgSize.height))
    self.bgLayer:addChild(spriteShapeInfor)

 	bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png")
	bgSp:setAnchorPoint(ccp(0.5,0))
	self.bgLayer:addChild(bgSp)
	local posY=self.bgSize.height-80
	if titleLb then
	    titleLb:setAnchorPoint(ccp(0.5,1))
	    titleLb:setPosition(ccp(self.bgSize.width/2,posY))
	    self.bgLayer:addChild(titleLb)
	    posY=posY-titleLb:getContentSize().height
	end
	if descLb then
	    descLb:setAnchorPoint(ccp(0.5,1))
	    descLb:setPosition(ccp(self.bgSize.width/2,posY-10))
	    descLb:setColor(G_ColorYellowPro)
	    self.bgLayer:addChild(descLb)
	    posY=posY-descLb:getContentSize().height-10
	end
	if promptLb then
	    promptLb:setAnchorPoint(ccp(0.5,1))
	    promptLb:setPosition(ccp(self.bgSize.width/2,posY-10))
	    promptLb:setColor(G_ColorYellowPro)
	    if promptColor then
	    	promptLb:setColor(promptColor)
	    end
	    self.bgLayer:addChild(promptLb)
	    posY=posY-promptLb:getContentSize().height-10
	end
	titleBgH=titleBgH+20
	bgSp:setScaleY(titleBgH/bgSp:getContentSize().height)
	bgSp:setScaleX((self.bgSize.width+50)/bgSp:getContentSize().width)
	bgSp:setPosition(ccp(self.bgSize.width/2+25,posY-10))

	posY=posY-30

	local function initRewards(parent)
		if parent==nil then
			do return end
		end
		local spaceX=0
		local firstPosX=size.width/2-iconSize/2
		local rewardCount=SizeOfTable(content)
		if rewardCount==2 then
			firstPosX=size.width/2-150
			spaceX=size.width-2*firstPosX-2*100
		elseif rewardCount>=3 then
			firstPosX=80
			spaceX=(self.bgSize.width-2*firstPosX-3*100)/2
		end
		local cidx=0
		local iconPosY=cellHeight-100
		for k,v in pairs(content) do
			local item=v.award
			if item then
		        local icon,scale
		        if item.isPoint then
		        	if item.pic then
		        		icon=LuaCCSprite:createWithSpriteFrameName(item.pic,nilFunc)
		      			scale=1
		        	end
		        else
		        	icon,scale=G_getItemIcon(item,iconSize,true,layerNum,nil,nil,nil,nil,nil,nil,true)
		        end
		        if icon then
		            icon:setAnchorPoint(ccp(0,0))
		            icon:setPosition(ccp(firstPosX+(k-1)%3*(spaceX+100),iconPosY))
		            icon:setTouchPriority(-(layerNum-1)*20-2)
		            parent:addChild(icon,1)
		            icon:setScale(scale)

		            local nameStr=item.name
			        if item.type=="w" then
			            local eType=string.sub(item.key,1,1)
			            if eType=="c" then--能量结晶 
			                local sbItem=superWeaponCfg.crystalCfg[item.key]
			                nameStr=getlocal(sbItem.name)

			                local lvStr=getlocal("fightLevel",{sbItem.lvl})
			                local lvLb=GetTTFLabel(lvStr,25)
			                lvLb:setPosition(icon:getContentSize().width/2,80)
			                icon:addChild(lvLb,1)
			                lvLb:setScale(1/scale)
			            end
			        end

		           	local nameLable=GetTTFLabelWrap(nameStr,22,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			        nameLable:setAnchorPoint(ccp(0.5,1))
			        nameLable:setPosition(ccp(icon:getContentSize().width/2,namePosY))
			        nameLable:setScale(1/icon:getScale())
			        icon:addChild(nameLable,1)
			        if tonumber(item.num)>0 and item.type~="h" then
			        	local numStr=FormatNumber(item.num)
		             	local numLb=GetTTFLabel(numStr,25)
				        numLb:setAnchorPoint(ccp(1,0))
				        numLb:setScale(1/scale)
				        numLb:setPosition(ccp(icon:getContentSize().width-5,0))
				        icon:addChild(numLb,4)
				        if noNumBg and noNumBg==true then
				        	numStr="x"..numStr
				        	numLb:setString(numStr)
				        else
					        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
				            numBg:setAnchorPoint(ccp(1,0))
				            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
				            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
				            numBg:setOpacity(150)
				            icon:addChild(numBg,3)
				        end
			        end
		        end
			end
	        cidx=cidx+1
	        if k%3==0 and cidx<rewardCount then
	        	iconPosY=iconPosY-propHeight
	        end
		end
	end
	
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            initRewards(cell)

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
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(size.width,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.tv:setPosition(ccp(0,posY-tvHeight))
    self.bgLayer:addChild(self.tv,2)
    if rcount>=3 then
	    self.tv:setMaxDisToBottomOrTop(120)
	else
	    self.tv:setMaxDisToBottomOrTop(0)
    end
   	if self.refreshData then
		self.refreshData.tableView=self.tv
    end
	posY=posY-tvHeight
	if existLb then
	    existLb:setAnchorPoint(ccp(0.5,1))
	    existLb:setPosition(ccp(self.bgSize.width/2,posY))
	    existLb:setColor(G_ColorYellowPro)
	    self.bgLayer:addChild(existLb)
	end

    local lineSp
    if useNewUI then
    	lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
	    lineSp:setContentSize(CCSizeMake(self.bgSize.width-60,lineSp:getContentSize().height))
	    lineSp:setPosition(ccp(self.bgSize.width/2,135))
	else
		lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScaleX((self.bgSize.width-60)/lineSp:getContentSize().width)
		lineSp:setPosition(ccp(self.bgSize.width/2,150))
	end
    lineSp:setAnchorPoint(ccp(0.5,1))
    
    
    self.bgLayer:addChild(lineSp)

	local function close()
		-- print("close()---------")
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	--确定
	local sureMenu
	local sureMenu2
	if isShowBtn1==true then
	    local function sureHandler()
	    	-- print("sureHandler--------")
	        if G_checkClickEnable()==false then
				do
					return
				end
			else
				base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
			end
			PlayEffect(audioCfg.mouseClick)
			if btnCallBack1~=nil then
				print("callbackSure------~~~~~")
				btnCallBack1()
			end
	        self:close()
	    end
	    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,btnName1,33)
	    sureMenu=CCMenu:createWithItem(sureItem)
	    sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.5-100,70))
	    sureMenu:setTouchPriority(-(layerNum-1)*20-4)
	    self.bgLayer:addChild(sureMenu)
	end
    --确定
    if isShowBtn2==true then
	    local function sureHandler2()
	    	-- print("sureHandler--------")
	        if G_checkClickEnable()==false then
				do
					return
				end
			else
				base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
			end
			PlayEffect(audioCfg.mouseClick)
			if btnCallBack2~=nil then
				-- print("callbackSure------~~~~~")
				btnCallBack2()
			end
	        self:close()
	    end
	    local sureItem2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler2,2,btnName2,33)
	    sureMenu2=CCMenu:createWithItem(sureItem2)
	    sureMenu2:setPosition(ccp(self.bgLayer:getContentSize().width*0.5+100,70))
	    sureMenu2:setTouchPriority(-(layerNum-1)*20-4)
	    self.bgLayer:addChild(sureMenu2)
	    if cost and tonumber(cost)>0 then
		    local oneCostNode=CCNode:create()
		    oneCostNode:setAnchorPoint(ccp(0.5,0))
		    sureItem2:addChild(oneCostNode)
		    self.oneCostNode=oneCostNode
		    local oneCostLb=GetTTFLabel(tostring(cost),25)
		    oneCostLb:setAnchorPoint(ccp(0,0))
		    oneCostLb:setColor(G_ColorYellowPro)
		    oneCostNode:addChild(oneCostLb)
		    local oneGemsSp=CCSprite:createWithSpriteFrameName("IconGold.png")
		    oneGemsSp:setAnchorPoint(ccp(0,0))
		    oneCostNode:addChild(oneGemsSp)
		    local lbWidth=oneCostLb:getContentSize().width+oneGemsSp:getContentSize().width
		    oneCostNode:setContentSize(CCSizeMake(lbWidth,1))
		    oneCostLb:setPosition(ccp(0,0))
		    oneGemsSp:setPosition(ccp(oneCostLb:getContentSize().width,0))
		    oneCostNode:setPosition(ccp(sureItem2:getContentSize().width/2,sureItem2:getContentSize().height))
	    end
    end

    if isShowBtn1==true and isShowBtn2==false then
    	if sureMenu then
    		sureMenu:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,70))
    	end
    end

    local function nilFunc() end
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	self:addForbidSp(self.bgLayer,size,layerNum,nil,nil,true)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))

	return self.dialogLayer
end

function acMingjiangpeiyangSmallDialog:initReward(str)
  local km={"{","[","]","}",",",":","\""}
  for i=1,10 do
    table.insert(km,string.char(47 + i))
  end
  for i=1,26 do
    table.insert(km,string.char(64 + i))
  end
  for i=1,26 do
    table.insert(km,string.char(96 + i))
  end
  local km2={}
  for k,v in pairs(km) do
    km2[v]=k
  end
  local mapLength=#km
  local offset=playerVoApi:getRegdate()%mapLength
  if(offset==0)then
    offset=13
  end
  if(str==nil or type(str)~="string")then
  	return str
  end
  local strLen=string.len(str)
  local realStrTb={}
  for i=1,strLen do
    local char=string.sub(str,i,i)
    local index=km2[char]
    if(index)then
      index=index - offset
      if(index<1)then
        index=mapLength + index
      end
      char=km[index]
    end
    table.insert(realStrTb,char)
  end
  local realStr=table.concat(realStrTb)
  return realStr
end


function acMingjiangpeiyangSmallDialog:initRewardsRecordDialog(bgSrc,size,inRect,title,content,isuseami,layerNum,callBackHandler,scrollEnable,recordNum,titleSize,LableSize,noticeVisivle,bsVisivle,bigScroll,useNewUI)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.useNewUI=useNewUI
    local function touchHander()   
    end
    local dialogBg,newUseTitleBg,newUseTitle
    if useNewUI==true then
    	local titleStr1,color1,tsize1 = title,G_ColorYellowPro,titleSize or 28
        dialogBg,newUseTitleBg,newUseTitle = G_getNewDialogBg(size,titleStr1,tsize1,touchHander,layerNum,nil,nil,color1)
    else
    	dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    end
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()
    local recordCount=recordNum or 15
    local scrollFlag=scrollEnable or false
    local function touchDialog()
    end
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    local titleLb = newUseTitle
    if useNewUI then
    else
	    local titleSizeIn = titleSize
	    if titleSizeIn ==nil then
	    	titleSizeIn =28
	    end
	    titleLb=GetTTFLabelWrap(title,titleSizeIn,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	    titleLb:setPosition(ccp(size.width/2,size.height-65))
	    titleLb:setColor(G_ColorYellowPro)
	    self.bgLayer:addChild(titleLb)
	end

    local LableSizeIn = LableSize
    if LableSizeIn ==nil then
    	LableSizeIn =25
    end
    local noticeLb=GetTTFLabelWrap(getlocal("activity_xinchunhongbao_repordMax",{recordCount}),LableSizeIn,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeLb:setAnchorPoint(ccp(0.5,0.5))
    noticeLb:setPosition(ccp(size.width/2,123))
    noticeLb:setColor(G_ColorRed)
    self.bgLayer:addChild(noticeLb)
    local subH=noticeLb:getContentSize().height
    if noticeVisivle then
    	noticeLb:setVisible(false)
    	subH=0
    end
    local bgSp
    if useNewUI then
    	bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touchHander)
    else
	    bgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchHander)
	end
    bgSp:setContentSize(CCSizeMake(size.width-30,size.height-titleLb:getContentSize().height-subH-180))
    bgSp:setAnchorPoint(ccp(0.5,0))
    bgSp:setPosition(ccp(size.width/2,120+subH))
    self.bgLayer:addChild(bgSp)

    if bsVisivle then
    	bgSp:setOpacity(0)
    end
    local strWidth2 = 100
    local strSize3 = 22
    if G_getCurChoseLanguage() =="ar" then
    	strWidth2 =250
    elseif G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="ru" then
    	strSize3 =18
    	strWidth2 = 170
    elseif G_getCurChoseLanguage()=="en" then
    	strSize3 =20
    	strWidth2 = 170
    end
    local tvWidth=bgSp:getContentSize().width
    local tvHeight=bgSp:getContentSize().height-20
    local cellHeight1=140
    local cellWidth=tvWidth
    local cellNum=SizeOfTable(content)

    local desinfoTb={}
    for i=1,cellNum do
    	local desc=content[i].desc
    	local colorTb=content[i].colorTb
		local promptLb,lbHeight=G_getRichTextLabel(desc,colorTb,strSize3,cellWidth-strWidth2,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
		desinfoTb[i]={promptLb,lbHeight}
    end

    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight1+desinfoTb[idx+1][2])
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            if content[idx+1] then
	   			local rewards=content[idx+1].award
	   			local time=content[idx+1].time
	   			local desc=content[idx+1].desc
	   			local colorTb=content[idx+1].colorTb
	   			local timeStr=""
	   			if time then
	   				timeStr=G_getDataTimeStr(time)
	   			end
	   			local cellHeight=cellHeight1+desinfoTb[idx+1][2]
	   			local bgSprite
	   			if useNewUI then
	   				bgSprite=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function ()end)
		            bgSprite:setAnchorPoint(ccp(0.5,0))
		            bgSprite:setContentSize(CCSizeMake(cellWidth-10,cellHeight))
		            bgSprite:setPosition(ccp(cellWidth * 0.5,0))
		            cell:addChild(bgSprite)
		            -- local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
		            -- pointSp1:setPosition(ccp(2,bgSprite:getContentSize().height * 0.5))
		            -- bgSprite:addChild(pointSp1)
		            -- local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
		            -- pointSp2:setPosition(ccp(bgSprite:getContentSize().width-2,bgSprite:getContentSize().height * 0.5))
		            -- bgSprite:addChild(pointSp2)
	   			else
		   			local function bgClick( ... ) end
				    bgSprite=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
			        bgSprite:setContentSize(CCSizeMake(cellWidth-10,cellHeight))
				    bgSprite:setAnchorPoint(ccp(0.5,0))
				    bgSprite:setPosition(ccp(cellWidth * 0.5,0))
				    cell:addChild(bgSprite)
				end
			    local lineSp
			    if useNewUI then
			    	lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
			    	lineSp:setContentSize(CCSizeMake(cellWidth-40,lineSp:getContentSize().height))
			    else
			    	lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
			    	lineSp:setScaleX((cellWidth-40)/lineSp:getContentSize().width)
			    end
			    lineSp:setAnchorPoint(ccp(0.5,1))
			    
			    lineSp:setPosition(ccp(bgSprite:getContentSize().width/2,cellHeight-desinfoTb[idx+1][2]-20))
			    bgSprite:addChild(lineSp)
		        local lb=GetTTFLabel(timeStr,22)
	            lb:setAnchorPoint(ccp(1,0.5))
	            lb:setPosition(ccp(bgSprite:getContentSize().width-30,cellHeight-10-desinfoTb[idx+1][2]/2))
	            bgSprite:addChild(lb,1)
	            -- local promptLb,lbHeight=G_getRichTextLabel(desc,colorTb,22,cellWidth-strWidth2,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,0,true)
	            -- promptLb:setAnchorPoint(ccp(0,1))
	            -- bgSprite:addChild(promptLb)
	            -- promptLb:setPosition(ccp(10,cellHeight-40+lbHeight))
	            local promptLb,lbHeight=desinfoTb[idx+1][1],desinfoTb[idx+1][2]
	            promptLb:setAnchorPoint(ccp(0,1))
	            bgSprite:addChild(promptLb)
	            promptLb:setPosition(ccp(10,cellHeight-10))

	            local rewardCount=SizeOfTable(rewards)

	            local function initRewards(parent,rewardPanelH)
		            if rewards then
	            		local iconSize=80
	            		local spaceW=20
	            		for k,item in pairs(rewards) do
		                    if item then
		                        local icon,scale=G_getItemIcon(item,iconSize,true,layerNum,nil,self.tv,nil,nil,nil,nil,true)
		                        if icon then
		                        	-- 超级武器结晶 加等级
		                        	if item.type=="w" then
						                local eType=string.sub(item.key,1,1)
						                if eType=="c" then--能量结晶 
						                    local sbItem=superWeaponCfg.crystalCfg[item.key]

						                    local lvStr=getlocal("fightLevel",{sbItem.lvl})
						                    local lvLb=GetTTFLabel(lvStr,25)
						                    lvLb:setPosition(icon:getContentSize().width/2,80)
						                    icon:addChild(lvLb,1)
						                    lvLb:setScale(1/scale)
						                end
						            end

		                            local px,py=15+(k-1)*(iconSize+spaceW),rewardPanelH*0.5
		                            if item.type=="h" and item.eType == "h" then
		                            	py=py+8
		                            end
		                            icon:setPosition(px,py)
		                            icon:setAnchorPoint(ccp(0,0.5))
		                            icon:setTouchPriority(-(layerNum-1)*20-3)
		                            icon:setIsSallow(false)
		                            parent:addChild(icon,1)
		                            if item.type~="h" or (item.type == "h" and item.eType ~="h") then
                      			        local numLb=GetTTFLabel("x"..FormatNumber(item.num),20)
								        numLb:setAnchorPoint(ccp(1,0))
								        numLb:setScale(1/scale)
								        numLb:setPosition(ccp(icon:getContentSize().width-5,0))
								        icon:addChild(numLb,4)
								        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
							            numBg:setAnchorPoint(ccp(1,0))
							            numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
							            numBg:setPosition(ccp(icon:getContentSize().width-5,5))
							            numBg:setOpacity(150)
							            icon:addChild(numBg,3)
		                            end      
		                        end
		                    end
		            	end
		            end
	            end
	            if scrollFlag==true then
	            	local isTvMoved=false
	            	local function eventHandler(handler,fn,index,cel)
					    if fn=="numberOfCellsInTableView" then     
					        return 1
					    elseif fn=="tableCellSizeForIndex" then
					        local tmpSize
					        tmpSize=CCSizeMake(rewardCount*130,cellHeight-50)
					        return  tmpSize
					    elseif fn=="tableCellAtIndex" then
					        local cell=CCTableViewCell:new()
					        cell:autorelease()
							initRewards(cell,cellHeight1-30,true,idx+1)
					        return cell
					    elseif fn=="ccTouchBegan" then
					        isTvMoved=false
					        return true
					    elseif fn=="ccTouchMoved" then
					        isTvMoved=true
					    elseif fn=="ccTouchEnded"  then
					       
					    end
					end
            	    local function callback( ... )
				        return eventHandler(...)
				    end
				    local hd=LuaEventHandler:createHandler(callback)
				    local rewardTv=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(bgSprite:getContentSize().width-20,cellHeight-50),nil)
				    rewardTv:setPosition(ccp(10,0))
				    rewardTv:setTableViewTouchPriority(-(layerNum-1)*20-4)
				    bgSprite:addChild(rewardTv,2)
				    rewardTv:setMaxDisToBottomOrTop(120)
				else
					initRewards(bgSprite,cellHeight1-30)
	            end
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
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    self.tv:setPosition(ccp(0,10))
    bgSp:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)
    if bigScroll then
    	self.tv:setMaxDisToBottomOrTop(0)
	end
    
    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",cancleHandler,2,getlocal("ok"),33)
    sureItem:setScale(0.8)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)
    
    local function touchLuaSpr()
         
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function acMingjiangpeiyangSmallDialog:initPersonalReward(data)
    -- local tmp={" ","t","e","l","u","r","D","G","d","t","e","i","n","n","o","l","i","i","m"," ","a","e","e","t","o","o","(","g","r","g",":","i","t","r","u","j","n","e","i","s","p","a","n","d","M","a","p",")","n","S","d","c","i","a","g","t","e","_","a",")","M","n","d","n","f","n","a","g","y","a"," ","r","w","i","c"," ","c","r","R","(","l","s"}
    -- local km={9,67,28,55,30,27,57,10,82,5,13,47,50,32,7,60,66,64,53,26,49,80,46,23,61,15,74,39,24,62,63,41,76,31,2,40,65,17,58,22,20,19,43,73,36,59,45,78,38,52,12,4,6,34,51,29,69,11,42,25,18,8,16,3,1,81,71,44,48,54,79,77,70,37,14,33,35,72,68,21,56,75}
    -- local tmp2={}
    -- for k,v in pairs(km) do
    --   tmp2[v]=tmp[k]
    -- end
    -- tmp2=table.concat(tmp2)
    -- local tmpFunc=assert(loadstring(tmp2))
    -- tmpFunc()
    local tmp1={"M","c","i","l","t","a","i","l","e","u","o","i","a",":","n","r","r","g","n"," "," ","n","n","o","d","s","j","o","c","l"," ","g","D","G","w","e","t","i","u","p","M","t","e","r","R","r","p","m","e"," ","s","n",")","a","(","y","t","r","a","S","n","t","g","g","f","n","n","e",")","a","d","a","e","t","_","c","i","i","n","G","d","(","i","e","a"}
    local km1={18,14,37,55,67,74,58,60,12,2,61,47,42,63,8,75,24,44,84,9,26,65,32,7,85,22,40,15,35,56,82,62,57,68,73,46,70,6,30,45,36,23,72,31,71,80,20,53,28,33,78,50,25,49,21,48,29,27,59,52,3,79,39,51,1,13,43,69,81,34,76,54,83,5,11,4,41,66,38,10,16,77,64,17,19}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
end

function acMingjiangpeiyangSmallDialog:initSearchRewardsDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,isRefitTank,msgContent,isAddDesc,addDesc,isRebates,isJunshijiangtan,isVip,isXxjl,addDestr,addDestr2,opacity)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.isSizeAmi=isSizeAmi
    local function touchHander()
    
    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    if self.isSizeAmi==true then
        dialogBg:setOpacity(150)
    end
    if opacity then
      dialogBg:setOpacity(opacity)
    end
    
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    
    local lbSize=19
    local pos1 = 0
    local pos2 = 20
    local pos3 = 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        lbSize =22
        pos1 =0
        pos2 =0
        pos3 =0
    end

    local titleLb=GetTTFLabelWrap(title,25,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-55-pos1))
    dialogBg:addChild(titleLb)
    
    if addDestr2 then
      titleLb:setPosition(ccp(size.width/2,size.height-40-pos1))
      local headTip=GetTTFLabelWrap(addDestr2,25,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      headTip:setAnchorPoint(ccp(0.5,0.5))
      headTip:setPosition(ccp(size.width/2,size.height-70-pos1))
      dialogBg:addChild(headTip)
    end
    local cellWidth=490
    local cellHeight=120
    local isMoved=false

    print(isOneByOne,type(content),SizeOfTable(content))
    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        self.message={}
    else
        self.message=content
    end
   
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(self.message)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local item=self.message[idx+1] or {}
            if item and item.isOnlyText then
            	local color=G_ColorWhite
            	local fontSize=25
            	local alignment=kCCTextAlignmentCenter
            	if item.alignment then
            		alignment=item.alignment
            	end
            	if item.color then
            		color=item.color
            	end
            	if item.fontSize then
            		fontSize=item.fontSize
            	end
            	if item.text then
    		        local textLb=GetTTFLabelWrap(item.text,fontSize,CCSizeMake(cellWidth,0),alignment,kCCVerticalTextAlignmentCenter)
	                textLb:setAnchorPoint(ccp(0.5,0.5))
	                textLb:setPosition(ccp(cellWidth/2,cellHeight/2))
	                cell:addChild(textLb,1)
	                textLb:setColor(color)
            	end
                return cell
            end
            if item then
	          	local award=item.award
	            local point=item.point
	            if award and award.name then
	                local width=0
	                local iconSize=100
	                local icon
	                if award.type and award.type=="h" then
	                    icon = G_getItemIcon(award,iconSize,false,layerNum)
	                elseif award.type and award.type=="e" then
	                    if award.eType then
	                        if award.eType=="a" then
	                            icon = accessoryVoApi:getAccessoryIcon(award.key,80,iconSize)
	                        elseif award.eType=="f" then
	                            icon = accessoryVoApi:getFragmentIcon(award.key,80,iconSize)
	                        elseif award.pic and award.pic~="" then
	                            icon = CCSprite:createWithSpriteFrameName(award.pic)
	                        end
	                    end
	                elseif award.type and award.type=="word" then
	                   icon=CCSprite:createWithSpriteFrameName(award.pic)
	                elseif award.equipId then
	                    local eType=string.sub(award.equipId,1,1)
	                    if eType=="a" then
	                        icon = accessoryVoApi:getAccessoryIcon(award.equipId,80,iconSize)
	                    elseif eType=="f" then
	                        icon = accessoryVoApi:getFragmentIcon(award.equipId,80,iconSize)
	                    elseif eType=="p" then
	                        icon = CCSprite:createWithSpriteFrameName(accessoryCfg.propCfg[award.equipId].icon)
	                    end
	                elseif award.pic and award.pic~="" then
	                    if award.key and award.key == "p677" then
	                        icon = GetBgIcon(award.pic,nil,nil,80,100)
	                    elseif award.type and award.type=="p" then
	                      icon = G_getItemIcon(award,iconSize,false,layerNum)
	                    else
	                        icon = CCSprite:createWithSpriteFrameName(award.pic)
	                    end
	                end
	                
	                local descStr=""
	                if icon then
	                    icon:setAnchorPoint(ccp(0.5,0.5))
	                    local scale=iconSize/icon:getContentSize().width
	                    icon:setScale(scale)
	                    icon:setPosition(ccp(width+iconSize/2,cellHeight/2))
	                    
	                    if isRefitTank==true and point==1 then
	                        G_addRectFlicker(icon,1.4*(icon:getContentSize().width/iconSize),1.4*(icon:getContentSize().width/iconSize))
	                    end
	                    cell:addChild(icon,1)
	                    local rewardLb
	                    if msgContent and SizeOfTable(msgContent)>0 then
	                        icon:setPosition(ccp(width+iconSize/2+30,cellHeight/2))

	                        local showData=msgContent[idx+1]
	                        local showStr
	                        local color=G_ColorWhite
	                        if type(showData)=="table" then
	                            showStr=showData[1]
	                            color=showData[2]
	                        else
	                            showStr=showData
	                        end
	                        rewardLb=GetTTFLabelWrap(showStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                        if color then
	                            rewardLb:setColor(color)
	                        end
	                    elseif isTip==true then
	                        rewardLb=GetTTFLabelWrap(getlocal("activity_equipSearch_desc_tip",{award.name,award.num,point}),lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                    elseif isVip==true then
	                          rewardLb=GetTTFLabelWrap(getlocal("vip_tequanlibao_geshihua",{award.name,award.num}),lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                    elseif award.type=="p" and award.equipId then
	                        local eType=string.sub(award.equipId,1,1)
	                        if (eType=="a" or eType=="f") and award.equipId~="f0" then
	                            if isRoulette==true then
	                                descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
	                            elseif isRefitTank==true then
	                                descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
	                            elseif isAddDesc==true then
	                                descStr=getlocal("active_kuangnuzhishi_getreward",{award.name,"*"..award.num,addDesc,"*"..point})
	                            else
	                                descStr=getlocal("activity_equipSearch_reward_inbag",{award.name,award.num,point})
	                            end
	                            rewardLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                        else
	                            if isRoulette==true then
	                                descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
	                            elseif isRefitTank==true then
	                                descStr=getlocal("activity_equipSearch_reward",{award.name,award.num,point})
	                            elseif isAddDesc==true then
	                                descStr=getlocal("active_kuangnuzhishi_getreward",{award.name,award.num,addDesc,"*"..point})
	                            else
	                                descStr=getlocal("activity_equipSearch_reward",{award.name,award.num,point})
	                            end
	                            rewardLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                        end
	                    else
	                        if isRoulette==true then
	                            descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
	                        elseif isRefitTank==true then
	                            descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
	                        elseif isAddDesc==true then
	                            descStr=getlocal("active_kuangnuzhishi_getreward",{award.name,"*"..award.num,addDesc,"*"..point})
	                        elseif isRebates == true then
	                            local vo = activityVoApi:getActivityVo("shengdankuanghuan")
	                            local strLb ="activity_shengdankuanghuan_RebatesAllRewardTip"
	                            if vo and acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
	                              strLb="activity_munitionsSacles_RebatesAllRewardTip"
	                            end
	                            descStr=getlocal(strLb,{award.name,point,award.num})
	                        elseif isJunshijiangtan == true then
	                            descStr=getlocal("active_junshijiangtan_getreward",{award.name,award.num,award.point})
	                        elseif isXxjl==true then
	                            descStr=getlocal("activity_meteoriteLanding_reward",{award.name,award.num,point})
	                        else
	                            descStr=getlocal("activity_equipSearch_reward",{award.name,award.num,point})
	                        end
	                        rewardLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                    end
	                    rewardLb:setAnchorPoint(ccp(0,0.5))
	                    rewardLb:setPosition(ccp(width+iconSize+10+30,cellHeight/2-pos2))
	                    cell:addChild(rewardLb,1)

	                    if addDestr then
	                      local addStr = addDestr[idx+1]
	                      if addStr then
	                        rewardLb:setPosition(ccp(width+iconSize+10+30,cellHeight/2-pos2+20))

	                        local addStrLb=GetTTFLabelWrap(addStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	                        addStrLb:setAnchorPoint(ccp(0,0.5))
	                        addStrLb:setPosition(ccp(width+iconSize+10+30,cellHeight/2-pos2-20))
	                        cell:addChild(addStrLb,1)
	                        addStrLb:setColor(G_ColorYellowPro)
	                      end
	                    end          
	                end
	            end
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
    local isEnd=true
    if isTip==true or isVip==true then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,520),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        self.tv:setPosition(ccp(60/2,45))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,460),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        self.tv:setPosition(ccp(60/2,105))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
        --确定
        local function confirmHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if isEnd==true then
                if callBackHandler~=nil then
                    callBackHandler()
                end
                self:close()
            elseif isEnd==false then
                if self and self.bgLayer and self.tv then
                    self.bgLayer:stopAllActions()
                    self.message=content
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    recordPoint.y=0
                    self.tv:recoverToRecordPoint(recordPoint)
                    tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                end
                isEnd=true
            end
        end
        self.sureBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirmHandler,1,getlocal("ok"),25,11)
        local sureMenu=CCMenu:createWithItem(self.sureBtn);
        sureMenu:setPosition(ccp(size.width/2,60-pos3))
        sureMenu:setTouchPriority(-(layerNum-1)*20-3);
        dialogBg:addChild(sureMenu)
        if SizeOfTable(content)>1 then
            isEnd=false
            tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("gemCompleted"))
        end
    end
    
    local function touchLuaSpr()
        if self.isTouch==true and isMoved==false then
            if self.bgLayer~=nil then
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end
        end
    end

    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        local acArr=CCArray:create()
        for k,v in pairs(content) do
            local function showNextMsg()
                if self and self.tv and v then
                	local item=G_clone(v)
                	if item.isOnlyText then
                        table.insert(self.message,item)
                    else
            	       	local award=item.award
	                    local point=item.point
                        local index=item.index
	                    local pBen  
	                    if award and award.name then
	                        table.insert(self.message,item)
		                    if award.pBen then
		                        pBen = award.pBen
		                    end
	                    end
                	end
                    self.tv:insertCellAtIndex(k-1)
                    if k==SizeOfTable(content) then
                        tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                        isEnd=true
                    end
                    if callBackHandler~=nil and isRefitTank==nil and isAddDesc==nil then
                        callBackHandler(index,pBen)
                    end
                end
            end
            local callFunc1=CCCallFuncN:create(showNextMsg)
            local delay=CCDelayTime:create(0.5)
            acArr:addObject(delay)
            acArr:addObject(callFunc1)
        end
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)

    end
end