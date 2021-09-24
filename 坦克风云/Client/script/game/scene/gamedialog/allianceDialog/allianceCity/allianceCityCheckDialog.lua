allianceCityCheckDialog=smallDialog:new()

--isOther：是否是敌方玩家查看我方城市
function allianceCityCheckDialog:new(data,isOther)
	local nc={
		data=data,
		isOther=isOther,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function allianceCityCheckDialog:init(layerNum)
	base:addNeedRefresh(self)
	spriteController:addPlist("scene/allianceCityImages.plist")
	spriteController:addTexture("scene/allianceCityImages.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/resource_youhua.plist")
    spriteController:addTexture("public/resource_youhua.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addTexture("public/acKafkaGift.pvr.ccz")
	spriteController:addPlist("public/acKafkaGift.plist")


	self.layerNum=layerNum
	self.dialogWidth=550
	self.dialogHeight=700
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
    local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("alliance_city"),30,nil,self.layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

    local citySp=allianceCityVoApi:getAllianceCityIcon()
    citySp:setScale(0.7)
    local cityWidth,cityHeight=citySp:getContentSize().width*citySp:getScale(),citySp:getContentSize().height*citySp:getScale()
    citySp:setPosition(cityWidth/2,self.bgSize.height-80-cityHeight/2)
    self.bgLayer:addChild(citySp)

    local nameStr=self.data.allianceName
	local cityNameLb=GetTTFLabelWrap(nameStr,22,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	cityNameLb:setAnchorPoint(ccp(0,0.5))
	cityNameLb:setPosition(220,self.bgSize.height-100)
	cityNameLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(cityNameLb)
	local tempLb=GetTTFLabel(nameStr,22)
	local realW=tempLb:getContentSize().width
	if realW>cityNameLb:getContentSize().width then
		realW=cityNameLb:getContentSize().width
	end
	local cityLvLb=GetTTFLabel(getlocal("city_info_level",{self.data.level}),22)
	cityLvLb:setAnchorPoint(ccp(0,0.5))
	cityLvLb:setPosition(cityNameLb:getPositionX()+realW+5,cityNameLb:getPositionY())
	-- cityLvLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(cityLvLb)

	local mcoords={x=self.data.x,y=self.data.y}
    local coordinateLb=G_getCoordinateLb(self.bgLayer,mcoords,20)
    coordinateLb:setAnchorPoint(ccp(0,0.5))
    coordinateLb:setPosition(cityNameLb:getPositionX(),cityNameLb:getPositionY()-cityNameLb:getContentSize().height/2-20)

    --收藏
    if self.isOther==true then
		local function onFavor()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:addToFavor()
		end
		local favorItem=GetButtonItem("worldBtnCollection.png","worldBtnCollection_Down.png","worldBtnCollection.png",onFavor,2,nil,25)
		favorItem:setScale(0.7)
		local favorBtn=CCMenu:createWithItem(favorItem)
		favorBtn:setPosition(ccp(coordinateLb:getPositionX()+coordinateLb:getContentSize().width+favorItem:getContentSize().width*0.35+10,coordinateLb:getPositionY()))
		favorBtn:setTouchPriority(-(layerNum-1)*20-2)
		self.bgLayer:addChild(favorBtn)
	else
		local shildTimeLb=GetTTFLabelWrap(getlocal("shildTime",{0}),22,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		shildTimeLb:setPosition(self.bgSize.width/2-140,60)
		shildTimeLb:setVisible(false)
		self.bgLayer:addChild(shildTimeLb)
		self.shildTimeLb=shildTimeLb
    end

    local resBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),function () end)
    resBg:setContentSize(CCSizeMake(self.bgSize.width-300,70))
    resBg:setAnchorPoint(ccp(0,1))
    resBg:setPosition(cityNameLb:getPositionX()-10,coordinateLb:getPositionY()-coordinateLb:getContentSize().height/2-15)
    self.bgLayer:addChild(resBg)

    local strSize2 = 16
    if G_getCurChoseLanguage() =="cn" and G_getCurChoseLanguage() =="ja" and G_getCurChoseLanguage() =="ko" and G_getCurChoseLanguage() =="tw" then
    	strSize2 = 20
    else
    	resBg:setOpacity(0)
    end

    local resPromptLb=GetTTFLabelWrap(getlocal("dailyRobCityResStr"),strSize2,CCSizeMake(resBg:getContentSize().width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
    resPromptLb:setAnchorPoint(ccp(0,0))
    resPromptLb:setPosition(10,38)
    resBg:addChild(resPromptLb)

	local barTag,barBgTag=10,12
    local timerSprite=AddProgramTimer(resBg,ccp(0,0),barTag,nil,nil,"res_progressbg.png","resyellow_progress.png",barBgTag)
    local barSp=tolua.cast(resBg:getChildByTag(barTag),"CCProgressTimer")
    local setScaleX=220/barSp:getContentSize().width
    local setScaleY=30/barSp:getContentSize().height
    barSp:setScaleX(setScaleX)
    barSp:setScaleY(setScaleY)
    barSp:setAnchorPoint(ccp(0,0.5))
    barSp:setPosition(ccp(10,20))
    barSp:setPercentage(0)
    self.timerSprite=timerSprite

    local barBg=tolua.cast(resBg:getChildByTag(barBgTag),"CCSprite")
    barBg:setScaleX(setScaleX)
    barBg:setScaleY(setScaleY)
    barBg:setAnchorPoint(ccp(0,0.5))
    barBg:setPosition(barSp:getPosition())

    local percentLb=GetTTFLabel("",18)
    percentLb:setAnchorPoint(ccp(0.5,0.5))
    barSp:addChild(percentLb,4)
    percentLb:setScaleX(1/setScaleX)
    percentLb:setScaleY(1/setScaleY)
    self.percentLb=percentLb

	local crpic=allianceCityVoApi:getCrPic()
	local crSp=CCSprite:createWithSpriteFrameName(crpic)
	crSp:setScale(32/crSp:getContentSize().width)
	timerSprite:addChild(crSp)
	self.crSp=crSp

    local kuangWidth,kuangHeight=self.bgSize.width-40,350
	local detailPanel=G_getThreePointBg(CCSizeMake(kuangWidth,kuangHeight),function () end,ccp(0.5,1),ccp(self.bgSize.width/2,self.bgSize.height-240),self.bgLayer)
	self.detailPanel=detailPanel

	local strSize3 = 18
	if G_getCurChoseLanguage() =="cn" and G_getCurChoseLanguage() =="ja" and G_getCurChoseLanguage() =="ko" and G_getCurChoseLanguage() =="tw" then
		strSize3 = 24
	end
	self.titleBg,self.titleLb=G_createNewTitle({getlocal("garrisonPlayerNum",{getlocal("curProgressStr",{(self.data.defendc or 0),(self.data.maxdef or 0)})}),strSize3},CCSizeMake(kuangWidth-140,0))
	self.titleBg:setPosition(kuangWidth/2,kuangHeight-40)
	detailPanel:addChild(self.titleBg)

	self.cellNum,self.detailType,self.scoutFlag=SizeOfTable(self.data.defenders),1,false
	local isMoved,cellWidth,cellHeight=false,kuangWidth,50
    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return self.cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local rank,fontSize=(idx+1),20
            local user
            if self.detailType==1 then --战力排行
            	user=self.data.defenders[rank]
            else --掠夺排行
            	user=self.data.roblist[rank]
            end
            if user and user[3] and user[2] then
            	local name,value=user[3],user[2]
		        if rank<=3 then
		            local rankSp=CCSprite:createWithSpriteFrameName("top"..rank..".png")
		            rankSp:setScale(40/rankSp:getContentSize().width)
		            rankSp:setPosition(35,cellHeight/2)
		            cell:addChild(rankSp)
		        else
		            local rankStr=tostring(rank)
		            local rankLb=GetTTFLabelWrap(rankStr,fontSize,CCSizeMake(60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		            rankLb:setPosition(35,cellHeight/2)
		            cell:addChild(rankLb)
		        end

		        local nameLb=GetTTFLabelWrap(name,fontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		        nameLb:setAnchorPoint(ccp(0,0.5))
		        nameLb:setPosition(120,cellHeight/2)
		        cell:addChild(nameLb)

                local valueLb=GetTTFLabel(FormatNumber(value),fontSize)
		        valueLb:setAnchorPoint(ccp(0,0.5))
		        valueLb:setPosition(400,cellHeight/2)
		        cell:addChild(valueLb)
		        if self.detailType==2 then
					local pic=allianceCityVoApi:getCrPic()
			        local resSp=CCSprite:createWithSpriteFrameName(pic)
			        resSp:setAnchorPoint(ccp(0,0.5))
    		        local scale=32/resSp:getContentSize().width
			        resSp:setScale(scale)
			        resSp:setPosition(valueLb:getPositionX()+valueLb:getContentSize().width+5,cellHeight/2)
			        cell:addChild(resSp)
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
    local hd=LuaEventHandler:createHandler(eventHandler)
    local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,kuangHeight-80),nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    tv:setPosition(0,30)
    tv:setMaxDisToBottomOrTop(120)
    detailPanel:addChild(tv)
    self.detailTv=tv

    local strSize4,strSize5 = 18,19
    if G_getCurChoseLanguage() =="cn" and G_getCurChoseLanguage() =="ja" and G_getCurChoseLanguage() =="ko" and G_getCurChoseLanguage() =="tw" then
    	strSize4,strSize5 = 22,25
    end
	self.promptLb=GetTTFLabelWrap("",strSize4,CCSizeMake(kuangWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.promptLb:setPosition(getCenterPoint(detailPanel))
	detailPanel:addChild(self.promptLb)

	self.attentionLb=GetTTFLabelWrap("",strSize4,CCSizeMake(kuangWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.attentionLb:setColor(G_ColorRed)
	self.attentionLb:setPosition(kuangWidth/2,25)
	detailPanel:addChild(self.attentionLb)
	if self.isOther==nil or self.isOther==false then
		local function refresh()
			if self.detailType==1 then
				self.detailType=2
			else
				self.detailType=1
			end
			self:updateDetail()
		end
    	local freshIcon=LuaCCSprite:createWithSpriteFrameName("freshIcon.png",refresh)
    	freshIcon:setTouchPriority(-(self.layerNum-1)*20-4)
    	freshIcon:setPosition(kuangWidth-freshIcon:getContentSize().width/2-5,kuangHeight-freshIcon:getContentSize().height/2-5)
    	detailPanel:addChild(freshIcon)
	end

	self:updateDetail()

	local priority,btnScale=-(self.layerNum-1)*20-4,0.8
	if self.isOther==true then
		local function scoutHandler()
			self:scout()
		end
		local function attackHandler()
			local myAlliance=allianceVoApi:getSelfAlliance()
			if myAlliance==nil or myAlliance.aid==nil then
		     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("allianceCity_no_alliance_tip"),28)
		     	do return end
			end
			--判断被保护
			if self.data.ptEndTime>=base.serverTime then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage26016"),true,4)
				do return end
			end
			if allianceCityVoApi:ishasAttackTroops(self.data.x,self.data.y)==true then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("diableAttackacityStr"),true,4)
				do return end
			end
			--进攻
			--判断是否有能量
			-- if playerVoApi:getEnergy()<=0 then
			-- 	local function buyEnergy()
			-- 		G_buyEnergy(5)
			-- 	end
			-- 	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,4)
			-- 	do return end
			-- end
			self:realClose()
		    require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
			local td=tankAttackDialog:new(self.data.type,self.data,4)
			local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
			local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
			sceneGame:addChild(dialog,4)
		end
		local scoutBtn=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2-140,60),{getlocal("scout_btn")},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",scoutHandler,btnScale,priority)
		local attackBtn=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2+140,60),{getlocal("tankAtk")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",attackHandler,btnScale,priority)
	else
		local function openShieldHandler()
			local flag=allianceCityVoApi:isPrivilegeEnough()
			if flag==false then
         		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
				do return end
			end
            local cost=allianceCityVoApi:getOpenShieldCost()
			local function realOpen()
				if cost>self.data.cr then
	         		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26008"),28)
					do return end
				end
				local function openCallBack(ptEndTime)
					self.data.ptEndTime=ptEndTime
					self:tick()
				end
				allianceCityVoApi:openAllianceCityShield({self.data.x,self.data.y},openCallBack)
			end
			local shildTime=allianceCityVoApi:getShieldTime()
            local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
            local addStrTb={
                {getlocal("shieldLastTime",{GetTimeStr(shildTime)}),G_ColorYellowPro,25,kCCTextAlignmentCenter,20},
                {getlocal("dailyShieldTimes",{1}),G_ColorRed,25,kCCTextAlignmentCenter,20}
            }
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("openCityShieldPromptStr",{cost}),false,realOpen,nil,nil,desInfo,addStrTb)
		end
		local function goToAllianceCityDialog()
			self:close()
			allianceCityVoApi:showAllianceCityDialog(self.layerNum+1)
		end
		self.shieldBtn=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2-140,60),{getlocal("openCityShield"),strSize5},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",openShieldHandler,btnScale,priority)
		local enterBtn=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2+140,60),{getlocal("enterCityStr"),strSize5},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",goToAllianceCityDialog,btnScale,priority)
	end

	self:tick()

	local function touchHandler()
	end
	local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function allianceCityCheckDialog:updateDetail()
	local kuangWidth,kuangHeight=self.detailPanel:getContentSize().width,self.detailPanel:getContentSize().height
	if self.isOther==true and self.scoutFlag==false then
		self.promptLb:setString(getlocal("checkCityPromptStr2"))
		self.attentionLb:setVisible(false)
		self.titleBg:setVisible(false)
		self.timerSprite:setPercentage(0)
		self.percentLb:setString(getlocal("crNumUnkown"))
		self.percentLb:setPosition(getCenterPoint(self.timerSprite))
		self.crSp:setVisible(false)
		if G_getCurChoseLanguage() ~="cn" and G_getCurChoseLanguage() ~="ja" and G_getCurChoseLanguage() ~="ko" and G_getCurChoseLanguage() ~="tw" then
		 	self.percentLb:setString(getlocal("alienMines_unkown"))
		end
		do return end
	end
	self.attentionLb:setVisible(true)
	self.titleBg:setVisible(true)
	if self.detailType==1 then
		self.cellNum=SizeOfTable(self.data.defenders)
		if self.cellNum==0 then
			if self.isOther==true then
				self.promptLb:setString(getlocal("checkCityPromptStr3"))
			else
				self.promptLb:setString(getlocal("checkCityPromptStr6"))
			end
		else
			self.promptLb:setVisible(false)
		end
		self.attentionLb:setString(getlocal("checkCityPromptStr",{5}))
		self.titleLb:setString(getlocal("garrisonPlayerNum",{getlocal("curProgressStr",{(self.data.defendc or 0),(self.data.maxdef or 0)})}))
	elseif self.detailType==2 then
		self.cellNum=SizeOfTable(self.data.roblist)
		if self.cellNum==0 then
			self.promptLb:setString(getlocal("checkCityPromptStr5"))
		else
			self.promptLb:setVisible(false)
		end
		self.attentionLb:setString(getlocal("checkCityPromptStr4",{5}))
		self.titleLb:setString(getlocal("cityRobRankStr"))
	end
	local cfg=allianceCityCfg.city[self.data.level]
	if cfg then
		local crlimit,grabc,cr,ts=cfg.allGrabLimitR,0,self.data.cr,base.serverTime
		if self.data.grabinfo then
			grabc=self.data.grabinfo.DR or 0 --被掠夺的
			ts=self.data.grabinfo.T or base.serverTime --上次掠夺时间
		end
		-- print("crlimit,grabc,cr,ts",crlimit,grabc,cr,ts)
		if ts>0 and G_isToday(ts)==false then --跨天清空今日掠夺量
			grabc=0
		end
		if crlimit>(grabc+cr) then
			crlimit=grabc+cr
		end
		local grabcAble=crlimit-grabc
		-- print("crlimit,grabc,grabcAble",crlimit,grabc,grabcAble)
		local percent=(grabcAble/crlimit)*100
		self.timerSprite:setPercentage(percent)
		self.timerSprite:setVisible(true)
		self.percentLb:setString(grabcAble.."/"..crlimit)
		local tmpWidth=self.crSp:getContentSize().width*self.crSp:getScale()+self.percentLb:getContentSize().width+15
		self.crSp:setPosition((self.timerSprite:getContentSize().width-tmpWidth)/2+self.crSp:getContentSize().width*self.crSp:getScale()/2,self.timerSprite:getContentSize().height/2)
	    self.percentLb:setPosition(self.crSp:getPositionX()+self.crSp:getContentSize().width*self.crSp:getScale()/2+self.percentLb:getContentSize().width/2+15,self.timerSprite:getContentSize().height/2)
	end
	if self.detailTv then
		self.detailTv:reloadData()
	end
end

--收藏
function allianceCityCheckDialog:addToFavor()
	self:realClose()
	local bookmarkTypeTab={0,0,0}
	local bookmarkType
	local function operateHandler(tag1,object)
		PlayEffect(audioCfg.mouseClick)
		local selectIndex=self.btnTab[tag1]:getSelectedIndex()
		if selectIndex==1 then
			bookmarkType=tag1
		else
			bookmarkType=0
		end
		bookmarkTypeTab[tag1]=bookmarkType
	end
	self.btnTab={}
	local tabBtn=CCMenu:create()
	for i=1,3 do
		local height=0
		local tabBtnItem
		if i==1 then
			local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
			local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnSelf.png")
			local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
			local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
			local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnSelf_Down.png")
			local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
			tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
			tabBtnItem:addSubItem(menuItemSp2)
			tabBtnItem:setPosition(0,height)
		elseif i==2 then
			local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
			local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnEnemy.png")
			local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
			local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
			local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnEnemy_Down.png")
			local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
			tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
			tabBtnItem:addSubItem(menuItemSp2)
			tabBtnItem:setPosition(160,height)
		elseif i==3 then
			local selectSp1 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
			local selectSp2 = CCSprite:createWithSpriteFrameName("worldBtnFriend.png")
			local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
			local selectSp3 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
			local selectSp4 = CCSprite:createWithSpriteFrameName("worldBtnFriend_Down.png")
			local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
			tabBtnItem = CCMenuItemToggle:create(menuItemSp1)
			tabBtnItem:addSubItem(menuItemSp2)
			tabBtnItem:setPosition(320,height)
		end
		tabBtnItem:setAnchorPoint(CCPointMake(0,0))
		tabBtnItem:registerScriptTapHandler(operateHandler)
		tabBtnItem:setSelectedIndex(0)
		tabBtn:addChild(tabBtnItem)
		tabBtnItem:setTag(i)
		self.btnTab[i]=tabBtnItem
	end
	tabBtn:setPosition(ccp(70,20))
	local function returnHandler()
	end
	local function saveHandler()
		local maxNum=bookmarkVoApi:getMaxNum()
		if bookmarkVoApi:getBookmarkNum(0)>=maxNum then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("collect_border_max_num",{maxNum}),nil,4)
			do return end
		end
		if bookmarkVoApi:isBookmark(self.data.x,self.data.y) then
			smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("collect_border_same_book_mark",{self.data.x,self.data.y}),nil,4)
			do return end
		end
		local ifAddToNoTag=true
		local desc=allianceCityVoApi:getAllianceCityName(self.data.allianceName)..getlocal("city_info_level",{self.data.level})
		local function serverSuperMark(fn,data)
			base:checkServerData(data)
		end
		socketHelper:markBookmark(bookmarkTypeTab,desc,self.data.x,self.data.y,serverSuperMark)
		return true
	end
	local title=getlocal("collect_border_title")
	local content1=getlocal("collect_border_siteInfo")
	local nameStr=G_getIslandName(self.data.type,self.data.name)
	local content2=getlocal("collect_border_name_loc",{nameStr,self.data.x,self.data.y})
	local content3=getlocal("collect_border_type")
	local content={{content1,30},{content2,25},{content3,30}}
	local leftStr=getlocal("collect_border_return")
	local rightStr=getlocal("collect_border_save")
	local itemTab={tabBtn}
	smallDialog:showPlayerInfoSmallDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 400),CCRect(168, 86, 10, 10),leftStr,returnHandler,rightStr,saveHandler,title,content,nil,3,5,itemTab,nil,nil,self.data.pic)
end

function allianceCityCheckDialog:scout()
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance==nil or myAlliance.aid==nil then
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("allianceCity_no_alliance_tip"),28)
     	do return end
	end
	--判断被保护
	if self.data.ptEndTime>=base.serverTime then
		smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("backstage26016"),true,4)
		do return end
	end

   	local user=allianceCityVoApi:getAllianceCityUser()
    local cost,glory=allianceCityVoApi:getSpyCost(self.data.level),user.glory
    local function realScoutCity()
	    if cost>glory then --个人荣耀值不够
	        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26013"),28)
	        do return end
	    end
    	local function scout(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data then
					if sData.data.acitydetail then
	    	  			self.data:initWithData(sData.data.acitydetail) --更新城市数据
					end
					allianceCityVoApi:updateData(sData.data) --同步user数据
					self.scoutFlag=true
					self:updateDetail() --刷新页面
				end
			end
		end
		socketHelper:scoutAllianceCity({self.data.x,self.data.y},scout)
    end
    local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("scoutAllianceCityPromptStr",{cost}),false,realScoutCity,nil,nil,desInfo)
end

function allianceCityCheckDialog:tick()
	if self.isOther==nil or self.isOther==false then
		if self.shildTimeLb and self.shieldBtn then
			if self.data.ptEndTime>0 and base.serverTime<self.data.ptEndTime then
				self.shildTimeLb:setVisible(true)
				local lefttime=self.data.ptEndTime-base.serverTime
				self.shildTimeLb:setString(getlocal("shildTime",{GetTimeStr(lefttime)}))
				self.shieldBtn:setVisible(false)
				self.shieldBtn:setEnabled(false)
			elseif allianceCityVoApi:isTodayCanOpenShield()==true then
				self.shieldBtn:setVisible(true)
				self.shieldBtn:setEnabled(true)
			else
				self.shieldBtn:setVisible(true)
				self.shieldBtn:setEnabled(false)
			end
		end
	end
end

function allianceCityCheckDialog:dispose()
	base:removeFromNeedRefresh(self)
	spriteController:removePlist("scene/allianceCityImages.plist")
	spriteController:removeTexture("scene/allianceCityImages.png")
    spriteController:removePlist("public/resource_youhua.plist")
    spriteController:removeTexture("public/resource_youhua.png")
    spriteController:removeTexture("public/acKafkaGift.pvr.ccz")
	spriteController:removePlist("public/acKafkaGift.plist")
end