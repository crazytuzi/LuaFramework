acHongchangyuebingDialog=commonDialog:new()

function acHongchangyuebingDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.partTb={}
	self.effectTb={}
	self.playingEffect=nil
	self.tagOffset=518
	self.cellHeight=nil
    spriteController:addPlist("serverWar/serverWar.plist")
    spriteController:addTexture("serverWar/serverWar.pvr.ccz")

	return nc
end

function acHongchangyuebingDialog:initTableView()
	self.tankId=acHongchangyuebingVoApi:getComposeTankID()	
	self.tankNameStr = getlocal("tank_name_"..self.tankId)
	local version=acHongchangyuebingVoApi:getVersion()
	if version==1 then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/tankImage_a10134.plist")
	else
		spriteController:addPlist("public/tankImage_a"..self.tankId..".plist")
    	spriteController:addTexture("public/tankImage_a"..self.tankId..".png")
	end
	self.version=version
	self:initData()
	self:initUp()
	self:initDown()
end

function acHongchangyuebingDialog:initData()
	local numTb=acHongchangyuebingVoApi:getNumTb()
	local function onClickIcon(object,fn,tag)
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		if(tag)then
			self:buyFragment(tag-self.tagOffset)
		end
	end
	for i=1,acHongchangyuebingVoApi.partNum do
		local data={}
		data.pic=LuaCCSprite:createWithSpriteFrameName("a"..acHongchangyuebingVoApi:getComposeTankID().."_p"..i..".png",onClickIcon)
		data.pic:setTag(self.tagOffset+i)
		data.pic:setTouchPriority(-(self.layerNum-1)*20-4)
		data.num=numTb[i]
		data.numLb=GetTTFLabel("x"..data.num,20)
		data.id=i
		self.partTb[i]=data
	end
	local criticalPercent=acHongchangyuebingVoApi:getCriticalPercent()
	self.effectTb={}
	for i=1,criticalPercent do
		self.effectTb[i]={}
		for j=1,acHongchangyuebingVoApi.partNum do
			local sp=CCSprite:createWithSpriteFrameName("AperturePhoto.png")
			local spContent=CCSprite:createWithSpriteFrameName("a"..acHongchangyuebingVoApi:getComposeTankID().."_p"..j..".png")
			spContent:setPosition(getCenterPoint(sp))
			spContent:setScale(0.8)
			sp:addChild(spContent)
			sp:setVisible(false)
			sp:setPosition(ccp(999333,0))
			self.bgLayer:addChild(sp,4)
			self.effectTb[i][j]=sp
		end
	end
end

function acHongchangyuebingDialog:initUp()
	local function showInfo()
		PlayEffect(audioCfg.mouseClick)
		local tabStr={};
		local tabColor ={};
		local td=smallDialog:new()
		tabStr = {"\n",getlocal("activity_hongchangyuebing_info5"),"\n",getlocal("activity_stormrocket_info4"),"\n",getlocal("activity_hongchangyuebing_info3",{self.tankNameStr}),"\n",getlocal("activity_hongchangyuebing_info2",{self.tankNameStr}),"\n",getlocal("activity_stormrocket_info1"),"\n"}
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,{})
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	infoItem:setScale(0.9)
	infoItem:setAnchorPoint(ccp(0,1))
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setAnchorPoint(ccp(0,1))
	infoBtn:setPosition(ccp(20,G_VisibleSizeHeight-90))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	self.bgLayer:addChild(infoBtn,3);
	local girlScale
	local  lbWidth
	if(G_isIphone5())then
		self.girlHeight=250
		girlSize=CCSizeMake(450,200)
		lbWidth=340
		lbPosX=100
		self.btnBgHeight=220
	else
		self.girlHeight=210
		girlSize=CCSizeMake(450,170)
		lbWidth=390
		lbPosX=50
		self.btnBgHeight=190
	end
	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	girlImg:setScale(self.girlHeight/girlImg:getContentSize().height)
	girlImg:setAnchorPoint(ccp(0,1))
	girlImg:setPosition(ccp(20,G_VisibleSizeHeight-90))
	self.bgLayer:addChild(girlImg,2)
	local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(girlSize)
	girlDescBg:setAnchorPoint(ccp(0,1))
	girlDescBg:setPosition(170,G_VisibleSizeHeight-110)
	self.bgLayer:addChild(girlDescBg,1)
	--local girlDescLb=GetTTFLabelWrap(getlocal("activity_stormrocket_desc"),20,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	
    local function eventCallBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(eventCallBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(300,girlDescBg:getContentSize().height-20),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv:setPosition(ccp(80,15))
   	girlDescBg:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(50)

	--girlDescLb:setAnchorPoint(ccp(0,1))
	--girlDescLb:setPosition(ccp(lbPosX,girlDescBg:getContentSize().height-10))
	--girlDescBg:addChild(girlDescLb)
	local boxImg=CCSprite:createWithSpriteFrameName("SeniorBox.png")
	boxImg:setScale(0.9)
	self.boxImgX=G_VisibleSizeWidth-75
	self.boxImgY=G_VisibleSizeHeight-90-self.girlHeight+40
	boxImg:setPosition(ccp(self.boxImgX,self.boxImgY))
	self.bgLayer:addChild(boxImg,2)

	local btnBg=LuaCCScale9Sprite:createWithSpriteFrameName("RegistrationAwardsBox.png",CCRect(40, 40, 1, 1),function () end)
	btnBg:setAnchorPoint(ccp(0.5,1))
	btnBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,self.btnBgHeight))
	btnBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-90-self.girlHeight))

	local iconGold1=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold1:setAnchorPoint(ccp(0.5,0))
	iconGold1:setPosition(ccp(100,self.btnBgHeight/2+10))
	btnBg:addChild(iconGold1)

	local price1
	if(acHongchangyuebingVoApi:hasFreeTime())then
		price1=getlocal("daily_lotto_tip_2")
	else
		price1=acHongchangyuebingVoApi:getSingleCost()
	end
	self.price1Lb=GetTTFLabel(price1,25)
	self.price1Lb:setAnchorPoint(ccp(0,0))
	self.price1Lb:setPosition(ccp(130,self.btnBgHeight/2+10))
	btnBg:addChild(self.price1Lb)

	local iconGold2=CCSprite:createWithSpriteFrameName("IconGold.png")
	iconGold2:setAnchorPoint(ccp(0.5,0))
	iconGold2:setPosition(ccp(400,self.btnBgHeight/2+10))
	btnBg:addChild(iconGold2)

	local price2Lb=GetTTFLabel(acHongchangyuebingVoApi:getTuhaoCost(),25)
	price2Lb:setAnchorPoint(ccp(0,0))
	price2Lb:setPosition(ccp(430,self.btnBgHeight/2+10))
	btnBg:addChild(price2Lb)

	local function onClickOnce()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:play(1)
	end
	local rect = CCRect(20,20,10,10)
	local onceSp1=LuaCCScale9Sprite:createWithSpriteFrameName("BtnCancleSmall.png",rect,function () end)
	local onceSp2=LuaCCScale9Sprite:createWithSpriteFrameName("BtnCancleSmall_Down.png",rect,function () end)
	onceSp1:setContentSize(CCSizeMake((G_VisibleSizeWidth-150)/2,80))
	onceSp2:setContentSize(CCSizeMake((G_VisibleSizeWidth-150)/2,80))
	local onceItem=CCMenuItemSprite:create(onceSp1, onceSp2)
	onceItem:registerScriptTapHandler(onClickOnce)

	local onceLb=GetTTFLabel(getlocal("active_lottery_btn1"),25)
	onceLb:setPosition(getCenterPoint(onceItem))
	onceItem:addChild(onceLb)
	onceItem:setAnchorPoint(ccp(0,1))

	local onceBtn = CCMenu:createWithItem(onceItem)
	onceBtn:setAnchorPoint(ccp(0,1))
	onceBtn:setPosition(ccp(30,self.btnBgHeight/2))
	onceBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	btnBg:addChild(onceBtn)

	local function onClickTen()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		self:play(2)
	end
	local tenSp1=LuaCCScale9Sprite:createWithSpriteFrameName("BtnCancleSmall.png",rect,function () end)
	local tenSp2=LuaCCScale9Sprite:createWithSpriteFrameName("BtnCancleSmall_Down.png",rect,function () end)
	tenSp1:setContentSize(CCSizeMake((G_VisibleSizeWidth-150)/2,80))
	tenSp2:setContentSize(CCSizeMake((G_VisibleSizeWidth-150)/2,80))
	local tenItem=CCMenuItemSprite:create(tenSp1, tenSp2)
	tenItem:registerScriptTapHandler(onClickTen)

	local tenLb=GetTTFLabel(getlocal("active_lottery_btn2"),25)
	tenLb:setPosition(getCenterPoint(tenItem))
	tenItem:addChild(tenLb)
	tenItem:setAnchorPoint(ccp(1,1))

	local tenBtn = CCMenu:createWithItem(tenItem)
	tenBtn:setAnchorPoint(ccp(1,1))
	tenBtn:setPosition(ccp(G_VisibleSizeWidth-70,self.btnBgHeight/2))
	tenBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	btnBg:addChild(tenBtn)

	self.bgLayer:addChild(btnBg,2)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function acHongchangyuebingDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
	    local tmpSize
	    if self.cellHeight==nil then
	    	local descStr = ""
	    	if self.version==1 then
	    		descStr=getlocal("activity_hongchangyuebing_desc")
	    	else
	    		descStr=getlocal("activity_hongchangyuebing_"..self.tankId.."_desc")
	    	end
	    	local descLabel=GetTTFLabelWrap(descStr,22,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    	self.cellHeight=descLabel:getContentSize().height+25
	    end
	    tmpSize=CCSizeMake(300,self.cellHeight)
	    return  tmpSize
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local lbWidth = 300
        if G_getCurChoseLanguage() =="ar" then
        	lbWidth = 280
        end
        local descStr = ""
    	if self.version==1 then
    		descStr=getlocal("activity_hongchangyuebing_desc")
    	else
    		descStr=getlocal("activity_hongchangyuebing_"..self.tankId.."_desc")
    	end
        local descLabel=GetTTFLabelWrap(descStr,22,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if self.cellHeight==nil then
	    	self.cellHeight=descLabel:getContentSize().height+25
	    end	
	    descLabel:setAnchorPoint(ccp(0,1))
	    descLabel:setPosition(ccp(0,self.cellHeight))
	    cell:addChild(descLabel,1)
		descLabel:setColor(G_ColorGreen)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function acHongchangyuebingDialog:initDown()
	local panelBgHeight=G_VisibleSize.height-90-self.girlHeight-self.btnBgHeight-30
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,panelBgHeight))
	self.panelLineBg:setPosition(ccp(20,20))
	self.composeLb=GetTTFLabelWrap(getlocal("activity_hongchangyuebing_compose",{acHongchangyuebingVoApi:getComposeNum(),self.tankNameStr}),25,CCSizeMake(G_VisibleSizeWidth-80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	self.composeLb:setAnchorPoint(ccp(0,1))
	self.composeLb:setPosition(ccp(20,panelBgHeight-15))
	self.panelLineBg:addChild(self.composeLb)

	local iconWidth
	local startX
	local startY
	if(G_isIphone5())then
		iconWidth=100
		startX=160
		startY=panelBgHeight-130
	else
		iconWidth=90
		startX=160
		startY=panelBgHeight-110
	end
	for k,v in pairs(self.partTb) do
		local scale=iconWidth/v.pic:getContentSize().width
		v.pic:setScale(scale)
		v.pic:setPosition(ccp(startX+(v.id-1)%4*iconWidth,startY-math.floor((v.id-1)/4)*iconWidth))
		if(v.num<=0)then
			v.pic:setColor(G_ColorGray)
		else
			v.pic:setColor(G_ColorWhite)
		end
		v.numLb:setAnchorPoint(ccp(1,0))
		v.numLb:setPosition(ccp(iconWidth/scale-5,5))
		v.pic:addChild(v.numLb)
		self.panelLineBg:addChild(v.pic)
	end

	local id = acHongchangyuebingVoApi:getComposeTankID()
	local attack,life,accurate,avoid,critical,decritical,armor,penetrate,critDmg,decritDmg,baseAttackAdd,baseLifeAdd=tankVoApi:getTankAddProperty(id);
    local baseAttack=tonumber(tankCfg[id].attack)+baseAttackAdd
    local baseLife=tonumber(tankCfg[id].life)+baseLifeAdd

	local typeStr = "pro_ship_attacktype_"..tankCfg[acHongchangyuebingVoApi:getComposeTankID()].attackNum

	local iconHeight
	if(G_isIphone5())then
		iconHeight=startY-230
	else
		iconHeight=startY-190
	end

	local scale = 0.6
	local starX=60
	local addIconW=70

	local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
	attackTypeSp:setAnchorPoint(ccp(0,0.5));
	attackTypeSp:setPosition(ccp(starX,iconHeight))
	attackTypeSp:setScale(scale)
	self.panelLineBg:addChild(attackTypeSp,2)

	starX=starX+addIconW
	local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	attTypeLb:setAnchorPoint(ccp(0,0.5))
	attTypeLb:setPosition(ccp(starX,iconHeight))
	self.panelLineBg:addChild(attTypeLb)

	--暴击    
	-- starX=starX+100
 --    local criticalSp = CCSprite:createWithSpriteFrameName("skill_03.png");
 --    criticalSp:setAnchorPoint(ccp(0,0.5));
 --    criticalSp:setPosition(starX,iconHeight)
 --    criticalSp:setScale(scale)
 --    self.panelLineBg:addChild(criticalSp,2)
 --    -- self.panelLineBg:setScale(iconScale)
 --    starX=starX+addIconW
 --    local criticalLb=GetTTFLabel(tankCfg[id].critical.."%",20)
 --    criticalLb:setAnchorPoint(ccp(0,0.5))
 --    criticalLb:setPosition(ccp(starX,iconHeight))
 --    self.panelLineBg:addChild(criticalLb)
    
 --    self.criticalLbAdd=GetTTFLabel("+"..critical.."%",20)
 --    self.criticalLbAdd:setAnchorPoint(ccp(0,0.5))
 --    self.criticalLbAdd:setPosition(ccp(starX+criticalLb:getContentSize().width,iconHeight))
 --    self.criticalLbAdd:setColor(G_ColorGreen)
 --    self.panelLineBg:addChild(self.criticalLbAdd)

    -- 攻击
    starX=starX+130
    local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
	attackSp:setAnchorPoint(ccp(0,0.5));
	attackSp:setPosition(ccp(starX,iconHeight))
	attackSp:setScale(scale)
	self.panelLineBg:addChild(attackSp,2)

	starX=starX+addIconW
	local attLb=GetTTFLabel(tankCfg[acHongchangyuebingVoApi:getComposeTankID()].attack,20)
	attLb:setAnchorPoint(ccp(0,0.5))
	attLb:setPosition(ccp(starX,iconHeight))
	self.panelLineBg:addChild(attLb)

	-- -- 生命
	starX=starX+100
	local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
	lifeSp:setAnchorPoint(ccp(0,0.5))
	lifeSp:setPosition(ccp(starX,iconHeight))
	lifeSp:setScale(scale)
	self.panelLineBg:addChild(lifeSp,2)

	starX=starX+addIconW
	local lifeLb=GetTTFLabel(tankCfg[acHongchangyuebingVoApi:getComposeTankID()].life,20)
	lifeLb:setAnchorPoint(ccp(0,0.5))
	lifeLb:setPosition(ccp(starX,iconHeight))
	self.panelLineBg:addChild(lifeLb)

	local function onClickDetail()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		tankInfoDialog:create(self.bgLayer,acHongchangyuebingVoApi:getComposeTankID(),self.layerNum+1,nil,true)
	end
	local detailItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickDetail,nil,getlocal("playerInfo"),25)
	detailItem:setAnchorPoint(ccp(1,0))
	local detailBtn=CCMenu:createWithItem(detailItem)
	detailBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	detailBtn:setAnchorPoint(ccp(1,0))
	detailBtn:setPosition(ccp((G_VisibleSizeWidth-40)/2-70,10))
	self.panelLineBg:addChild(detailBtn)

	local function onClickCompose()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:compose()
	end
	self.composeItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickCompose,nil,getlocal("compose"),25)
	self.composeItem:setAnchorPoint(ccp(0,0))
	if(acHongchangyuebingVoApi:getComposeNum()<=0)then
		self.composeItem:setEnabled(false)
	else
		self.composeItem:setEnabled(true)
	end
	local composeBtn=CCMenu:createWithItem(self.composeItem)
	composeBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	composeBtn:setAnchorPoint(ccp(0,0))
	composeBtn:setPosition(ccp((G_VisibleSizeWidth-40)/2+70,10))
	self.panelLineBg:addChild(composeBtn)
end

function acHongchangyuebingDialog:buyFragment(id)
	if(self.partTb[id].num<=0)then
		if(playerVoApi:getGems()<acHongchangyuebingVoApi.buyGemCost)then
			self:gemNotEnough(acHongchangyuebingVoApi.buyGemCost)
			do return end
		end
		local function realBuyFragment()
			local function callback()
				self:refresh()
			end
			acHongchangyuebingVoApi:buyFragment(id,callback)
		end
		smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),realBuyFragment,getlocal("dialog_title_prompt"),getlocal("activity_stormrocket_buyFragment",{acHongchangyuebingVoApi.buyGemCost,acHongchangyuebingVoApi.buyPartNum}),nil,self.layerNum+1)
	end
end

function acHongchangyuebingDialog:play(type)
	if(self.playingEffect)then
		do return end
	end
	local paramType
	if(type==1)then
		if(acHongchangyuebingVoApi:hasFreeTime())then
			paramType=0
		else
			if(playerVoApi:getGems()<acHongchangyuebingVoApi:getSingleCost())then
				self:gemNotEnough(acHongchangyuebingVoApi:getSingleCost())
				do return end
			end
			paramType=1
		end
	else
		if(playerVoApi:getGems()<acHongchangyuebingVoApi:getTuhaoCost())then
			self:gemNotEnough(acHongchangyuebingVoApi:getTuhaoCost())
			do return end
		end
		paramType=type
	end
	local function callback(isCritical,reward)
		self:showPlayEffect(isCritical,reward)
	end
	self.playingEffect=true
	acHongchangyuebingVoApi:play(paramType,callback)
end

function acHongchangyuebingDialog:showPlayEffect(isCritical,reward)
	local function endFunc()
		self.playingEffect=false
		self:refresh()
	end
	if(reward==nil)then
		endFunc()
		do return end
	end
	local size1=100
	local bgX,bgY=self.panelLineBg:getPosition()
	self.effectNum=0
	local endIndex
	if(isCritical)then
		endIndex=#self.effectTb
	else
		endIndex=1
	end
	for i=1,endIndex do
		for k,v in pairs(reward) do
			self.effectNum=self.effectNum+1
			local id=tonumber(string.sub(k,5))
			local sp=self.effectTb[i][id]
			sp:setScale(30/sp:getContentSize().height)
			sp:setPosition(ccp(self.boxImgX,self.boxImgY))
			sp:setVisible(true)
			local acArr=CCArray:create()
			if(i>1)then
				local delay0=CCDelayTime:create(0.4*(i-1))
				acArr:addObject(delay0)
			end
			local scaleTo1=CCScaleTo:create(0.2,size1*1.1/sp:getContentSize().height)
			local scaleTo2=CCScaleTo:create(0.1,size1/sp:getContentSize().height)
			local delay=CCDelayTime:create(0.3)
			local moveTo=CCMoveTo:create(0.5,ccp(bgX+self.partTb[id].pic:getPositionX(),bgY+self.partTb[id].pic:getPositionY()))
			local function playEnd()
				sp:setPosition(ccp(999333,0))
				self.effectNum=self.effectNum-1
				if(self.effectNum<=0)then
					endFunc()
				end
			end
			local callFunc=CCCallFunc:create(playEnd)
			acArr:addObject(scaleTo1)
			acArr:addObject(scaleTo2)
			acArr:addObject(delay)
			acArr:addObject(moveTo)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			sp:runAction(seq)
		end
	end
end

function acHongchangyuebingDialog:compose()
	for k,v in pairs(self.partTb) do
		if(v.num<=0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage404"),30)
			do return end
		end
	end
	local function callback()
		local nameData={key=tankCfg[acHongchangyuebingVoApi:getComposeTankID()].name,param={}}
		local message={key="chatSystemMessage6",param={playerVoApi:getPlayerName(),nameData}}
		chatVoApi:sendSystemMessage(message)
		self:refresh()
	end
	acHongchangyuebingVoApi:compose(callback)
end

function acHongchangyuebingDialog:refresh()

	local price1
	if(acHongchangyuebingVoApi:hasFreeTime())then
		price1=getlocal("daily_lotto_tip_2")
	else
		price1=acHongchangyuebingVoApi:getSingleCost()
	end
	self.price1Lb:setString(price1)
	self.composeLb:setString(getlocal("activity_hongchangyuebing_compose",{acHongchangyuebingVoApi:getComposeNum(),self.tankNameStr}))
	if(acHongchangyuebingVoApi:getComposeNum()<=0)then
		self.composeItem:setEnabled(false)
	else
		self.composeItem:setEnabled(true)
	end


	local numTb=acHongchangyuebingVoApi:getNumTb()
	for i=1,acHongchangyuebingVoApi.partNum do
		self.partTb[i].num=numTb[i]
	end

	for k,v in pairs(self.partTb) do
		if(v.num<=0)then
			v.pic:setColor(G_ColorGray)
		else
			v.pic:setColor(G_ColorWhite)
		end
		v.numLb:setString("x"..v.num)
	end
end

function acHongchangyuebingDialog:gemNotEnough(needGems)
	local function buyGems()
        vipVoApi:showRechargeDialog(self.layerNum+1)
		self:close()
	end
	local num=needGems-playerVoApi:getGems()
	local sd=smallDialog:new()
	sd:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{needGems,playerVoApi:getGems(),num}),nil,self.layerNum+1)
end

function acHongchangyuebingDialog:tick()
    local vo=acHongchangyuebingVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
end

function acHongchangyuebingDialog:dispose()
	self.cellHeight=nil
	self.composeItem=nil
	self.playingEffect=nil
	self.effectTb=nil
	self.price1Lb=nil
	self.partTb=nil
	local version = acHongchangyuebingVoApi:getVersion()
	if version==1 then
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/tankImage_a10134.plist")
	else
		spriteController:removePlist("public/tankImage_a"..self.tankId..".plist")
    	spriteController:removeTexture("public/tankImage_a"..self.tankId..".png")
	end
    spriteController:removePlist("serverWar/serverWar.plist")
    spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
    self.tankId,self.tankNameStr=nil,nil
end