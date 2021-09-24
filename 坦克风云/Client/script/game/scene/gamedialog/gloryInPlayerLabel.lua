gloryInPlayerLabel=smallDialog:new()

function gloryInPlayerLabel:new(layerNum,whiDia,parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.layerNum=layerNum
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.showDia = whiDia
	self.dialogLayer=nil
	self.renewBtn =nil
	self.gloryDgreeWithCurAndUp =nil
	self.parent =parent
	return nc
end

function gloryInPlayerLabel:init(callbackSure)
	self.dialogWidth=500
	self.dialogHeight=770
	self.isTouch=nil

	if self.showDia ==2 then
		self.dialogHeight =470
		if base.isGlory==0 then
			self.dialogHeight =400
		end
		if warStatueVoApi:isWarStatueOpened()==0 then
			self.dialogHeight=self.dialogHeight+80
		end
		if planeVoApi:isSkillTreeSystemOpen()==true then --战机革新鼓舞技能带兵量加成
			local sid="s15"
		    local addBuffTb=planeVoApi:getPlaneNewSkillAddBuff(sid)
		    if addBuffTb and addBuffTb.add and tonumber(addBuffTb.add)>0 then
				self.dialogHeight=self.dialogHeight+80
		    end
		end
		if base.isSkin == 1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
			self.dialogHeight=self.dialogHeight+80
		end
		local buildVo = buildingVoApi:getBuildiingVoByBId(15)
		if buildVo and buildVo.level and buildingVoApi then
			local rate, pnum, troopsNum= buildingVoApi:getRepairFactoryBuff(buildVo.level)
			self.repairGetTroopsNum  = troopsNum
			if self.repairGetTroopsNum and self.repairGetTroopsNum > 0 then
				self.repairLevel = buildVo.level
				self.dialogHeight = self.dialogHeight+80
			end	
		end
	end

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
	self.bgLayer:setPosition(ccp(self.bgLayer:getPositionX(),self.bgLayer:getPositionY()-50))

	if self.showDia ==1 then
		local titleBg = CCSprite:createWithSpriteFrameName("gloryTitleBg.png")
		titleBg:setAnchorPoint(ccp(0.5,0))
		titleBg:setPosition(ccp(self.bgLayer:getPositionX(),self.bgLayer:getPositionY()+self.dialogHeight*0.5))
		titleBg:setScaleX(self.dialogWidth/titleBg:getContentSize().width)
		self.dialogLayer:addChild(titleBg)

		local islandGloryStr = GetTTFLabelWrap(getlocal("islandGloryStr"),28,CCSizeMake(self.dialogWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
	  	islandGloryStr:setAnchorPoint(ccp(0.5,0))
	  	islandGloryStr:setPosition(ccp(self.bgLayer:getPositionX(),self.bgLayer:getPositionY()+self.dialogHeight*0.5+5))
	  	self.dialogLayer:addChild(islandGloryStr,10)
	  	islandGloryStr:setColor(G_ColorYellowPro)
	end


	local function close()
		print("close()---------")
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	if self.showDia ==1 then--个人信息内显示使用
		self:initUpDia()
		self:initTableView()
	elseif self.showDia ==2 then--主界面左上角按钮点击使用
		self:initShowInPlayerInfo()
	end

    local function nilFunc()
    	if self.showDia ==2 then
	    	self:close()
	    end
	end
	
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-2)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	base:addNeedRefresh(self)
	return self.dialogLayer
end

function gloryInPlayerLabel:initTableView( ... )

	local function callBack(...)
	   return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth ,self.dialogHeight*0.3),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(15,self.dialogHeight*0.15))
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-1)
	-- self.tv:setMaxDisToBottomOrTop(130)
end

function gloryInPlayerLabel:eventHandler(handler,fn,idx,cel)
	local needHeight = 200
	local strSize2 = 18
  	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =20
  	end
   if fn=="numberOfCellsInTableView" then
       return 1
   elseif fn=="tableCellSizeForIndex" then
   		
       return  CCSizeMake(self.dialogWidth ,self.dialogHeight*0.3)-- -100
   elseif fn=="tableCellAtIndex" then
       local cell=CCTableViewCell:new()
       local needHeight2 = 240

       
       	local function touch( ) end 
		self.wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touch)
		self.wholeBgSp:setContentSize(CCSizeMake(self.dialogWidth ,self.dialogHeight*0.3))
		self.wholeBgSp:setAnchorPoint(ccp(0,0))
		self.wholeBgSp:setOpacity(0)
		self.wholeBgSp:setPosition(ccp(0,0))
		cell:addChild(self.wholeBgSp)

		

		-- local directionsStr = GetTTFLabelWrap(getlocal("gloryDirection",{gloryVoApi:getPermin()}),strSize2,CCSizeMake(self.dialogWidth-105,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	 --  	directionsStr:setAnchorPoint(ccp(0,1))
	 --  	directionsStr:setPosition(ccp(40,self.wholeBgSp:getContentSize().height-5))
	 --  	self.wholeBgSp:addChild(directionsStr)
	 --  	-- directionsStr:setMaxDisToBottomOrTop(100)

	  	local desTv, desLabel = G_LabelTableView(CCSizeMake(self.dialogWidth-105, 230),getlocal("gloryDirection",{gloryVoApi:getPermin()}),20,kCCTextAlignmentLeft)
		self.wholeBgSp:addChild(desTv)
		desTv:setPosition(ccp(45,0))
		desTv:setAnchorPoint(ccp(0,0))
		desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
		desTv:setMaxDisToBottomOrTop(100)




       cell:autorelease()
       return cell
   elseif fn=="ccTouchBegan" then
       self.isMoved=false
       return true
   elseif fn=="ccTouchMoved" then
       self.isMoved=true
   elseif fn=="ccTouchEnded"  then
       
   end
end

function gloryInPlayerLabel:initUpDia( )
	local strSize2,strSize4 = 20,19
  	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2,strSize4 =22,24
  	end

  	local function renewCall( )--
  		
  		-- activityAndNoteDialog:closeAllDialog()
	   --  vipVoApi:showRechargeDialog(self.layerNum+1)
  		local needGold = math.ceil(gloryVoApi:getDestroyNeedGold( ))
  		print("renewCall~~~~",needGold)
  		if needGold > playerVoApi:getGems() then
  			local function callBack() --充值
  			 self:close()
  			 vipVoApi:showRechargeDialog(self.layerNum+1)
		    end
		    local gemsNoEnoughStr = getlocal("gemNotEnough",{needGold,playerVo.gems,needGold-playerVo.gems})
		    local tsD=smallDialog:new()
		    tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),gemsNoEnoughStr,nil,self.layerNum+1)
			do return end
  		else
  			--isRenewGloryGold

	  		local function callBack() --充值
	  			 local function renewCall(fn,data)
	  				local ret,sData = base:checkServerData(data)
			        if ret==true then
			        	-- playerVoApi:setGems(playerVoApi:getGems()-needGold)
			        	self:close()
			        	local sd=gloryInPlayerLabel:new(3,1)
					    local dialog= sd:init(nil)
			        end
	  			end 
		  		socketHelper:renewGloryByGold(renewCall)
		    end
		    local tsD=smallDialog:new()
		    tsD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callBack,getlocal("dialog_title_prompt"),getlocal("isRenewGloryGold",{needGold}),nil,self.layerNum+1)
	  	end
  	end
  	self.renewBtn = GetButtonItem("yh_BtnUp.png","yh_BtnUp_Down.png","yh_BtnUp_Down.png",renewCall,10,nil,nil)
	local renewMenu = CCMenu:createWithItem(self.renewBtn);
	renewMenu:setTouchPriority(-(self.layerNum-1)*20-3);
	renewMenu:setScale(0.8)
	self.renewBtn:setAnchorPoint(ccp(1,0.5))
	renewMenu:setPosition(ccp(self.bgLayer:getContentSize().width-100,self.bgLayer:getContentSize().height-180))
	self.bgLayer:addChild(renewMenu)

  	local lineSP1=CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP1:setScaleX((self.bgLayer:getContentSize().width-10)/lineSP1:getContentSize().width)
	lineSP1:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.8))
	self.bgLayer:addChild(lineSP1,1)

	local gloryCfg,nextGloryTb,nextStr = gloryVoApi:getPlayerGlory( )

	if gloryCfg.curBoom >= gloryCfg.curBoomMax then
		self.renewBtn:setEnabled(false)
	end

	local curLevel=playerVoApi:getPlayerLevel()
    local m_gloryPic = playerVoApi:getPlayerBuildPic(curLevel)
    local buildIcon = CCSprite:createWithSpriteFrameName(m_gloryPic)
    -- buildIcon:setScaleX(self.gloryBg:getContentSize().width/buildIcon:getContentSize().width)
    -- buildIcon:setScaleY(self.gloryBg:getContentSize().width/buildIcon:getContentSize().width)
    buildIcon:setScale(0.85)
    buildIcon:setAnchorPoint(ccp(0.5,0))
    buildIcon:setPosition(ccp(110,self.dialogHeight*0.8+5))
    self.bgLayer:addChild(buildIcon)
    local sStr = getlocal("state")..":"
    local gdStr = getlocal("gloryDegreeStr")..":"
    local ls = getlocal("military_rank_troopLeader")..":"
    local needPosWidth = 25
    local strSize3 = 25
    if G_getCurChoseLanguage() =="ar" then--military_rank_troopLeader
    	sStr = ":"..getlocal("state")
    	gdStr = ":"..getlocal("gloryDegreeStr")
    	ls = ":"..getlocal("military_rank_troopLeader")
    	needPosWidth = 335
    	strSize3 =21
    end
    local stateStr = GetTTFLabel(sStr,24)
    stateStr:setAnchorPoint(ccp(0,1))
    stateStr:setPosition(ccp(self.dialogWidth*0.43,self.dialogHeight-60))
    self.bgLayer:addChild(stateStr)

    local chooseStr = gloryVoApi:ShowStrWithGlory(gloryCfg)
    local curState = "gloryStr"--假数据 需要取相关信息确定
    if chooseStr ==3 then
    	curState ="gloryOverStr"
    elseif chooseStr ==2 then
    	curState ="gloryLaterStr"
    end
    local curStateStr = GetTTFLabel(getlocal(curState),24)
    curStateStr:setAnchorPoint(ccp(0,1))
    curStateStr:setPosition(ccp(stateStr:getContentSize().width+5+self.dialogWidth*0.43,self.dialogHeight-60))
    self.bgLayer:addChild(curStateStr)

    if chooseStr ==3 then
    	curStateStr:setColor(G_ColorRed)
    elseif chooseStr ==1 then
    	curStateStr:setColor(G_ColorGreen)
    end

    local gloryDegreeStr = GetTTFLabel(gdStr,strSize4)
    gloryDegreeStr:setAnchorPoint(ccp(0,1))
    gloryDegreeStr:setPosition(ccp(self.dialogWidth*0.43,self.dialogHeight-115))
    self.bgLayer:addChild(gloryDegreeStr)

    self.gloryDgreeWithCurAndUp = GetTTFLabel(getlocal("scheduleChapter",{gloryCfg.curBoom,gloryCfg.curBoomMax}),strSize4)--假数据 需要取相关信息确定
    self.gloryDgreeWithCurAndUp:setAnchorPoint(ccp(0,1))
    self.gloryDgreeWithCurAndUp:setPosition(ccp(gloryDegreeStr:getContentSize().width+5+self.dialogWidth*0.43,self.dialogHeight-115))
    self.bgLayer:addChild(self.gloryDgreeWithCurAndUp)



	local upLb = GetTTFLabelWrap(getlocal("current_level_2")..":",24,CCSizeMake(450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
  	upLb:setAnchorPoint(ccp(0,1))
  	upLb:setColor(G_ColorYellowPro)
  	upLb:setPosition(ccp(25,self.bgLayer:getContentSize().height*0.8-5))
  	self.bgLayer:addChild(upLb)

  	local gloryValueStr = GetTTFLabel(getlocal("gloryValueStr",{gloryCfg.level}),20);
	gloryValueStr:setAnchorPoint(ccp(0,1));
	gloryValueStr:setPosition(ccp(63,upLb:getPositionY()-30));
	self.bgLayer:addChild(gloryValueStr,2);

  	local gloryDegree = GetTTFLabel("("..gloryCfg.needGloryExp..")",20);
	gloryDegree:setAnchorPoint(ccp(0,1));
	gloryDegree:setPosition(ccp(67+gloryValueStr:getContentSize().width,upLb:getPositionY()-30));
	self.bgLayer:addChild(gloryDegree,2);

  	local leadership = GetTTFLabel(ls,20)
  	leadership:setAnchorPoint(ccp(0,1))
  	leadership:setPosition(ccp(63,gloryValueStr:getPositionY()-25))
  	self.bgLayer:addChild(leadership)

  	local troopNums = GetTTFLabel("+"..gloryCfg.troopsUp,20);
	troopNums:setAnchorPoint(ccp(0,1));
	troopNums:setPosition(ccp(67+leadership:getContentSize().width,leadership:getPositionY()));
	self.bgLayer:addChild(troopNums,2);

  	local baseResource = GetTTFLabel(getlocal("baseResource"),20)
  	baseResource:setAnchorPoint(ccp(0,1))
  	baseResource:setPosition(ccp(63,leadership:getPositionY()-25))
  	self.bgLayer:addChild(baseResource)
  	local baseResourceNums = GetTTFLabel(gloryCfg.resource,20);
	baseResourceNums:setAnchorPoint(ccp(0,1));
	baseResourceNums:setPosition(ccp(67+baseResource:getContentSize().width,baseResource:getPositionY()));
	if tonumber(gloryCfg.productAdd) < 0 then
		baseResourceNums:setColor(G_ColorRed)
	else
		baseResourceNums:setColor(G_ColorGreen)
	end
	self.bgLayer:addChild(baseResourceNums,2);
--------------
  	local middLb = GetTTFLabel(getlocal("upgradeEffectStr")..":",24)
  	middLb:setAnchorPoint(ccp(0,1))
  	middLb:setColor(G_ColorYellowPro)
  	middLb:setPosition(ccp(needPosWidth,baseResource:getPositionY()-35))
  	self.bgLayer:addChild(middLb)
  	--gloryValueStr
  	if nextGloryTb ~=nil then
	  	local nextGloryValueStr = GetTTFLabel(getlocal("gloryValueStr",{nextGloryTb.level}),20);
		nextGloryValueStr:setAnchorPoint(ccp(0,1));
		nextGloryValueStr:setPosition(ccp(63,middLb:getPositionY()-30));
		self.bgLayer:addChild(nextGloryValueStr,2);

	  	local nextGloryDegree = GetTTFLabel("("..nextGloryTb.needGloryExp..")",20);
		nextGloryDegree:setAnchorPoint(ccp(0,1));
		nextGloryDegree:setColor(G_ColorRed)
		nextGloryDegree:setPosition(ccp(67+nextGloryValueStr:getContentSize().width,nextGloryValueStr:getPositionY()));
		self.bgLayer:addChild(nextGloryDegree,2);

	  	local nextLeadership = GetTTFLabel(ls,20)
	  	nextLeadership:setAnchorPoint(ccp(0,1))
	  	nextLeadership:setPosition(ccp(63,nextGloryValueStr:getPositionY()-25))
	  	self.bgLayer:addChild(nextLeadership)

	  	local nextTroopNums = GetTTFLabel("+"..nextGloryTb.troopsUp,20);
		nextTroopNums:setAnchorPoint(ccp(0,1));
		nextTroopNums:setColor(G_ColorGreen)
		nextTroopNums:setPosition(ccp(67+nextLeadership:getContentSize().width,nextLeadership:getPositionY()));
		self.bgLayer:addChild(nextTroopNums,2);

	  	local nextBaseResource = GetTTFLabel(getlocal("baseResource"),20)
	  	nextBaseResource:setAnchorPoint(ccp(0,1))
	  	nextBaseResource:setPosition(ccp(63,nextLeadership:getPositionY()-25))
	  	self.bgLayer:addChild(nextBaseResource)

	  	local nextBaseResourceNums = GetTTFLabel(nextGloryTb.resource,20);
		nextBaseResourceNums:setAnchorPoint(ccp(0,1));
		nextBaseResourceNums:setColor(G_ColorGreen)
		nextBaseResourceNums:setPosition(ccp(67+nextBaseResource:getContentSize().width,nextBaseResource:getPositionY()));
		self.bgLayer:addChild(nextBaseResourceNums,2);
	else
		local posXXX = 40
	  	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
	    	posXXX =middLb:getPositionX()+middLb:getContentSize().width
	  	end

		topLevelStr	= GetTTFLabelWrap(nextStr,20,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	  	topLevelStr:setAnchorPoint(ccp(0,1))
	  	topLevelStr:setColor(G_ColorYellowPro)
	  	topLevelStr:setPosition(ccp(posXXX,middLb:getPositionY()-50))
	  	self.bgLayer:addChild(topLevelStr)
	end

	local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setScaleX((self.bgLayer:getContentSize().width-10)/lineSP:getContentSize().width)
	lineSP:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.5))
	self.bgLayer:addChild(lineSP,1)

	local shuoming = GetTTFLabel(getlocal("shuoming")..":",24)
	shuoming:setAnchorPoint(ccp(0,1))
	shuoming:setColor(G_ColorYellowPro)
	shuoming:setPosition(ccp(needPosWidth,lineSP:getPositionY()-10))
	self.bgLayer:addChild(shuoming)



	local function sureHandler()
    	print("sureHandler--------")
        if G_checkClickEnable()==false then
			do
				return
			end
		else
			base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
		end
		PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,getlocal("confirm"),24,100)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(self.dialogWidth*0.5,self.dialogWidth*0.13))
    sureMenu:setTouchPriority(-(self.layerNum-1)*20-3);
    self.bgLayer:addChild(sureMenu)
    local lb = sureItem:getChildByTag(100)
    if lb then
    	lb = tolua.cast(lb, "CCLabelTTF")
    	lb:setFontName("Helvetica-bold")
	end
end



function gloryInPlayerLabel:initShowInPlayerInfo( )
	local strSize2 = 20
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
    	strSize2 =28
  	end
  	local function cellClick1( ... )end
	local capInSet = CCRect(60, 20, 1, 1)
	titleBackSprie =LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",capInSet,cellClick1)
	titleBackSprie:setContentSize(CCSizeMake(self.dialogWidth-14, self.dialogHeight*0.08))
	titleBackSprie:ignoreAnchorPointForPosition(false)
	titleBackSprie:setAnchorPoint(ccp(0.5,1))
	titleBackSprie:setIsSallow(false)
	titleBackSprie:setTouchPriority(-(self.layerNum-1)*20-2)
	titleBackSprie:setPosition(ccp(self.dialogWidth*0.5-2,self.dialogHeight-33))
	self.bgLayer:addChild(titleBackSprie)
	local upTitleTb,leftTitleTb,downTitleTb,levelTb,addTroopNums
	if base.isGlory==1 then
		upTitleTb = {"help3_t3_t2","RankScene_level","amountStr"}
		leftTitleTb = {getlocal("purifying_common")," ",getlocal("become_strong_commander")," ",getlocal("help2_t1_t3")," ",getlocal("gloryStr")}
		downTitleTb = {"nextLevelStr","upgradeClaimStr","upgradeEffectStr"}
		-- local upCurShowTb = {getlocal("scheduleChapter",{playerVoApi:getPlayerCurGlory( ),playerVoApi:getPlayerGlory( ).gloryDegree}),}
		levelTb = {getlocal("fightLevel",{playerVoApi:getPlayerLevel()}),getlocal("fightLevel",{playerVoApi:getTroops()}),playerVoApi:getRankName(),getlocal("fightLevel",{gloryVoApi:getPlayerCurGloryWithLevel()})}
		addTroopNums = {playerVoApi:getTroopsLvNum(),"+",playerVoApi:getTroopsNum(),"+",playerVoApi:getRankTroops(),"+",gloryVoApi:getPlayerCurGloryWithTroop()}--fightLevel

	else
		upTitleTb = {"help3_t3_t2","RankScene_level","amountStr"}
		leftTitleTb = {getlocal("purifying_common")," ",getlocal("become_strong_commander")," ",getlocal("help2_t1_t3")}
		downTitleTb = {"nextLevelStr","upgradeClaimStr","upgradeEffectStr"}
		levelTb = {getlocal("fightLevel",{playerVoApi:getPlayerLevel()}),getlocal("fightLevel",{playerVoApi:getTroops()}),playerVoApi:getRankName()}
		addTroopNums = {playerVoApi:getTroopsLvNum(),"+",playerVoApi:getTroopsNum(),"+",playerVoApi:getRankTroops()}
	end

	if warStatueVoApi:isWarStatueOpened()==0 then --战争塑像开启
		table.insert(leftTitleTb," ")
		table.insert(leftTitleTb,getlocal("warStatue_title"))
		table.insert(levelTb,getlocal("nullStr"))
		table.insert(addTroopNums,"+")
		local battleBuff=warStatueVoApi:getTotalWarStatueAddedBuff("add")
		local warStaueAddTroops=(battleBuff.add or 0)
		table.insert(addTroopNums,warStaueAddTroops)
	end
	if planeVoApi:isSkillTreeSystemOpen()==true then --战机革新鼓舞技能带兵量加成
		local sid="s15"
	    local addBuffTb=planeVoApi:getPlaneNewSkillAddBuff(sid)
	    if addBuffTb and addBuffTb.add and tonumber(addBuffTb.add)>0 then
	        table.insert(leftTitleTb," ")
			table.insert(leftTitleTb,planeVoApi:getNewSkillNameStr(sid))
			local sinfo=planeVoApi:getNewSkillInfoById(sid)
			table.insert(levelTb,getlocal("fightLevel",{(sinfo.lv or 0)}))
			table.insert(addTroopNums,"+")
			table.insert(addTroopNums,addBuffTb.add)
	    end
	end
	if self.repairGetTroopsNum and self.repairGetTroopsNum > 0 then
		 table.insert(leftTitleTb," ")
		 table.insert(leftTitleTb,getlocal("repair_factory"))
		 table.insert(levelTb,getlocal("fightLevel",{self.repairLevel}))
		 table.insert(addTroopNums,"+")
		 table.insert(addTroopNums,self.repairGetTroopsNum)
	end

	if base.isSkin==1 and playerVoApi:getPlayerLevel() >= buildDecorateVoApi:getLevelLimit() then
		
		table.insert(leftTitleTb," ")
		table.insert(leftTitleTb,getlocal("decorateTitle"))

		table.insert(levelTb,"--")
		table.insert(addTroopNums,"+")
		table.insert(addTroopNums, buildDecorateVoApi:addTroopNum())
	end
	for i=1,3 do
		local varNum = 0.38
		-- if i ==3 then
		-- 	varNum =0.35
		-- end
		local upTitleTbStr = GetTTFLabelWrap(getlocal(upTitleTb[i]),strSize2,CCSizeMake(self.dialogWidth*0.3,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		local anPosx = 30
		if i == 3 and G_getCurChoseLanguage() =="ru" then
			anPosx =0
		end
		upTitleTbStr:setAnchorPoint(ccp(0,1))
		upTitleTbStr:setColor(G_ColorYellowPro)
		upTitleTbStr:setPosition(ccp(self.dialogWidth*((i-1)*varNum)+anPosx,self.dialogHeight-35))
		self.bgLayer:addChild(upTitleTbStr)
	end
	-- local loopNum1,loopNum2 = nil
	-- if base.isGlory ==1 then
	-- 	loopNum1 =7
	-- 	loopNum2 =4
	-- else
	-- 	loopNum1 =6
	-- 	loopNum2 =3
	-- end

	local loopNum1=SizeOfTable(leftTitleTb)
	local loopNum2=SizeOfTable(levelTb)

	for i=1,loopNum1 do
		local needWidht2 = 0
		local leftTitleStr = GetTTFLabelWrap(leftTitleTb[i],strSize2,CCSizeMake(self.dialogWidth*0.25,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		leftTitleStr:setAnchorPoint(ccp(0,1))
		leftTitleStr:setPosition(ccp(30+needWidht2,self.dialogHeight-(i-1)*40-90))
		self.bgLayer:addChild(leftTitleStr)

		local addTroopStr = GetTTFLabelWrap(addTroopNums[i],strSize2-2,CCSizeMake(self.dialogWidth*0.2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		addTroopStr:setAnchorPoint(ccp(0,1))
		addTroopStr:setPosition(ccp(self.dialogWidth*(0.36*2)+25,self.dialogHeight-(i-1)*40-90))
		self.bgLayer:addChild(addTroopStr)

		if i%2 ==0 then 
			addTroopStr:setColor(G_ColorYellowPro)
		end
	end

	for i=1,loopNum2 do
		
		local levelStr = GetTTFLabelWrap(levelTb[i],strSize2-2,CCSizeMake(self.dialogWidth*0.2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		levelStr:setAnchorPoint(ccp(0,1))
		levelStr:setPosition(ccp(self.dialogWidth*0.34+30,self.dialogHeight-(i-1)*80-90))
		self.bgLayer:addChild(levelStr)
		--addTroopNums
		-- local addTroopStr = GetTTFLabelWrap(addTroopNums[i],strSize2,CCSizeMake(self.dialogWidth*0.2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		-- addTroopStr:setAnchorPoint(ccp(0,1))
		-- addTroopStr:setPosition(ccp(self.dialogWidth*(0.36*2)+25,self.dialogHeight-(i-1)*80-90))
		-- self.bgLayer:addChild(addTroopStr)
	end

	local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png");
	lineSP:setScaleX((self.bgLayer:getContentSize().width )/lineSP:getContentSize().width)
	lineSP:setPosition(ccp(self.bgLayer:getContentSize().width*0.5,self.bgLayer:getContentSize().height*0.16))
	self.bgLayer:addChild(lineSP,1)
	--ownTroopNumsStr
	local varOwnNums = playerVoApi:getTroopsLvNum()+playerVoApi:getAddTroops()
	local ownTroopNumsStr = GetTTFLabelWrap(getlocal("ownTroopNumsStr"),strSize2,CCSizeMake(self.dialogWidth*0.8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	ownTroopNumsStr:setAnchorPoint(ccp(0,1))
	ownTroopNumsStr:setPosition(ccp(30,lineSP:getPositionY()-15))
	self.bgLayer:addChild(ownTroopNumsStr)

	local ownNums = GetTTFLabel(varOwnNums,strSize2-2)
	ownNums:setAnchorPoint(ccp(1,1))
	ownNums:setPosition(ccp(self.dialogWidth-30,lineSP:getPositionY()-15))
	self.bgLayer:addChild(ownNums)
end

function gloryInPlayerLabel:tick( )
	local isUpdata,newBoom,curGloryTb = gloryVoApi:getPerminGlory()
	if self.showDia == 1 and isUpdata == true then
		print("isUpdata newBoom~~~~~",newBoom)
		self.gloryDgreeWithCurAndUp:setString(getlocal("scheduleChapter",{newBoom,curGloryTb.curBoomMax}))
		if curGloryTb.curBoom >= curGloryTb.curBoomMax then
			self.renewBtn:setEnabled(false)
		end
	end
end
function gloryInPlayerLabel:dispose()
	self.repairLevel = nil
	self.repairGetTroopsNum = nil
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
	self.dialogLayer=nil
end
function gloryInPlayerLabel:close()
	self.repairLevel = nil
	self.repairGetTroopsNum = nil
	self.gloryDgreeWithCurAndUp =nil
	self.renewBtn =nil
	self.checkSp = nil
	self.item = nil
	self.wholeBgSp=nil
	self.dialogWidth=nil
	self.dialogHeight=nil
	self.isTouch=nil
	self.bgLayer=nil
	self.bgSize=nil
    if self and self.dialogLayer then
        self.dialogLayer:removeFromParentAndCleanup(true)
        self.dialogLayer=nil
    end
    self.showDia =nil
    base:removeFromNeedRefresh(self)
end