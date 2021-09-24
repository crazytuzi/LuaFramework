local believerDialog=commonDialog:new()
function believerDialog:new()
	local nc={
		keepTick=true,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerDialog:doUserHandler()
	believerVoApi:computeSeason() --计算当前的赛季时间

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/believer/believerMain.plist")
    spriteController:addTexture("public/believer/believerMain.png")
    spriteController:addPlist("public/believer/believerTexture.plist")
    spriteController:addTexture("public/believer/believerTexture.png")
	spriteController:addPlist("scene/allianceCityImages.plist")
	spriteController:addTexture("scene/allianceCityImages.png")
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    spriteController:addPlist("public/dailyNews.plist")
    spriteController:addTexture("public/dailyNews.png")
    spriteController:addPlist("public/believer/killRaceEffectImage1.plist")
    spriteController:addTexture("public/believer/killRaceEffectImage1.pvr.ccz")
    spriteController:addPlist("public/believer/killRaceEffectImage2.plist")
    spriteController:addTexture("public/believer/killRaceEffectImage2.pvr.ccz")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)

    self.iphoneType=G_getIphoneType()

    --eType: 1.段位变化时，需要显示变化小面板，并刷新主页手。变化小面板会插入显示队列，当此bgLayer显示的时候，才会弹出
    --2.战斗结束，无段位变化，刷新主页数据即可
	local function refreshListener(event,data)
        if data then
        	if data.eType==1 then
	        	--加入等待队列，当此dialog显示的时候执行，此队列长度为1
	        	if self.waitShowChangeTb==nil then
	        		self.waitShowChangeTb={}
	        	else
	        		--队列之前有等待的显示了，则清楚掉，加入最新的
	        		if self.waitShowChangeTb[1]~=nil then
	        			self.waitShowChangeTb={}
	        		end
	        	end
	        	table.insert(self.waitShowChangeTb,data)
        	end
        	if self.bgLayer and self.believerLayer then
        		self:refreshMainLayer()
        	end
        end
    end
    self.refreshListener=refreshListener
    eventDispatcher:addEventListener("believer.main.refresh",refreshListener)

    local function dayRefresh(event,data)
    	if self.bgLayer and self.believerLayer then
    		self:refreshMainLayer()
    	end
    end
    self.dayRefreshListener=dayRefresh
    eventDispatcher:addEventListener("believer.day.refresh",dayRefresh)

	local user=believerVoApi:getMyUser()
    if user==nil or user.entry==0 then --未报名的话显示报名的板子
    	self:initSignLayer()
    else --主面板
    	self:initMainLayer()
    end
    local gives=believerVoApi:getTroopsGives()
    if gives then
    	self.gives=G_clone(gives)
    	believerVoApi:clearTroopsGives()
    	local function showReceiveTroopsDialog()
    		believerVoApi:showReceiveTroopsDialog(self.gives,self.layerNum+1)
    		self.gives=nil
    	end
    	local seq=CCSequence:createWithTwoActions(CCDelayTime:create(0.4),CCCallFunc:create(showReceiveTroopsDialog))
    	self.bgLayer:runAction(seq)
    end
end

function believerDialog:initMainLayer()
	if self.signLayer then
		self.signLayer:removeFromParentAndCleanup(true)
		self.signLayer=nil
		self.cdTimeLb=nil
	end
	local believerCfg=believerVoApi:getBelieverCfg()
    local believerLayer=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
	believerLayer:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-100))
    believerLayer:setAnchorPoint(ccp(0.5,1))
    believerLayer:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
    self.bgLayer:addChild(believerLayer,2)
    self.believerLayer=believerLayer
    local layerSize=believerLayer:getContentSize()

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    local bgSp=CCSprite:create("public/ltzdz/segInfoBg.png")
    bgSp:setAnchorPoint(ccp(0.5,1))
    bgSp:setScaleX((layerSize.width-4)/bgSp:getContentSize().width)
    bgSp:setScaleY((layerSize.height-2)/bgSp:getContentSize().height)
    bgSp:setPosition(layerSize.width/2,layerSize.height)
    believerLayer:addChild(bgSp)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local seasonTimeBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png",CCRect(103,0,2,80),function()end)
	seasonTimeBg:setContentSize(CCSizeMake(612,80))
	seasonTimeBg:setAnchorPoint(ccp(0.5,1))
	seasonTimeBg:setPosition(layerSize.width/2,layerSize.height)
	believerLayer:addChild(seasonTimeBg)
	local seasonSt,seasonEt=believerVoApi:getSeasonTime()
	local timeLb=GetTTFLabelWrap(getlocal("believer_seasonTime",{G_getDateStr(seasonSt,true,true),G_getDateStr(seasonEt,true,true)}),25,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setPosition(seasonTimeBg:getContentSize().width/2,seasonTimeBg:getContentSize().height-25)
	seasonTimeBg:addChild(timeLb)

	local addH=0
	if self.iphoneType==G_iphone4 then
		addH=50
	end
    
    local function touchHandler()
    	self:showSegmentInfoDialog()
    end
	local grade,queue=believerVoApi:getMySegment()
    local segIconSp=believerVoApi:getSegmentIcon(grade,queue,nil,touchHandler)
    segIconSp:setTouchPriority(-(self.layerNum-1)*20-3)
    segIconSp:setPosition(layerSize.width/2,layerSize.height-300+addH)
    believerLayer:addChild(segIconSp,3)
    self.segIconSp=segIconSp

    --播放特效
  	--循环的亮晶晶
    local repeatStarParticle=CCParticleSystemQuad:create("public/believer/killRaceRepeatStar.plist")
    repeatStarParticle:setPositionType(kCCPositionTypeGrouped)
    repeatStarParticle:setPosition(ccp(segIconSp:getPositionX(),segIconSp:getPositionY()+20))
    repeatStarParticle:setAutoRemoveOnFinish(true) -- 自动移除
    self.believerLayer:addChild(repeatStarParticle,7)

    local function showBoomAction()
    	if self.segIconSp==nil then
    		do return end
    	end
    	--播放一次的爆炸
	    local boomParticle=CCParticleSystemQuad:create("public/believer/killRaceBoom.plist")
	    boomParticle:setPositionType(kCCPositionTypeGrouped)
	    boomParticle:setPosition(ccp(self.segIconSp:getPositionX(),self.segIconSp:getPositionY()+15))
	    boomParticle:setAutoRemoveOnFinish(true) --自动移除
	    self.believerLayer:addChild(boomParticle,7)
    end
    local boomDelay=CCDelayTime:create(math.random(6,8))
    local showBoomCallFunc=CCCallFunc:create(showBoomAction)
    local particleSeq=CCSequence:createWithTwoActions(boomDelay,showBoomCallFunc)
    local particleRepeat=CCRepeatForever:create(particleSeq)
    bgSp:runAction(particleRepeat)

    self:addGradeAction(segIconSp)
    self:showBgAction(segIconSp:getPositionX(),segIconSp:getPositionY())

	local function touchTip()
		local args={
			arg2={believerCfg.season,believerCfg.offSeason},
			arg3={believerCfg.troopsNum},
		}
		local strTb={}
		for i=1,11 do
			local str=getlocal("believer_play_info_"..i,args["arg"..i])
			table.insert(strTb,str)
		end
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),strTb)
	end
	G_addMenuInfo(seasonTimeBg,self.layerNum,ccp(layerSize.width-40,seasonTimeBg:getContentSize().height/2),{},nil,nil,28,touchTip,true)

	local seasonBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelTitleBg.png",CCRect(84,25,1,1),function ()end)
	seasonBg:setAnchorPoint(ccp(0.5,1))
	seasonBg:setContentSize(CCSizeMake(250,50))
	seasonBg:setPosition(layerSize.width/2,layerSize.height-50)
	believerLayer:addChild(seasonBg)
	local season=believerVoApi:getSeason()
	local seasonLb=GetTTFLabel(getlocal("serverWarLadderSeasonTitle",{season}),30,true)
	seasonLb:setColor(G_ColorYellowPro)
	seasonLb:setPosition(getCenterPoint(seasonBg))
	seasonBg:addChild(seasonLb)

	local iphoneXAddH=0
	if self.iphoneType==G_iphoneX then
		iphoneXAddH=-60
	end
	local cdTimeBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20,20,10,10),function()end)
	cdTimeBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,36))
	cdTimeBg:setOpacity(0.7*255)
	cdTimeBg:setPosition(layerSize.width/2,layerSize.height-450+addH+iphoneXAddH)
	believerLayer:addChild(cdTimeBg)
	-- 状态与倒计时
    self.status,self.cdTime=believerVoApi:checkSeasonStatus()
    -- 倒计时
	local cdTimeLb=GetTTFLabelWrap(getlocal("believer_match_status_"..self.status).."："..GetTimeForItemStrState(self.cdTime),25,CCSizeMake(G_VisibleSizeWidth-40-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	cdTimeLb:setAnchorPoint(ccp(0.5,0.5))
	cdTimeLb:setPosition(getCenterPoint(cdTimeBg))
	cdTimeLb:setColor(G_ColorYellowPro)
	cdTimeBg:addChild(cdTimeLb)
	self.cdTimeLb=cdTimeLb

	local infoBgH=0
	if self.iphoneType==G_iphone4 then
		infoBgH=30
	end
	local infoBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerInfoBg.png",CCRect(20,0,10,235),function()end)
	infoBg:setContentSize(CCSizeMake(408,235))
	infoBg:setAnchorPoint(ccp(0,1))
	infoBg:setPosition(20,layerSize.height-520+addH+infoBgH+iphoneXAddH)
	believerLayer:addChild(infoBg)
	local x,y=G_getSpriteWorldPosAndSize(infoBg)
	y=(y<0) and (y+G_VisibleSizeHeight) or y
    --添加裁切层
    local clipperSize=CCSizeMake(infoBg:getContentSize().width,infoBg:getContentSize().height-20) 
    local clipper=CCClippingNode:create()
    clipper:setAnchorPoint(ccp(0.5,0.5))
    clipper:setContentSize(clipperSize)
    clipper:setPosition(x,y)
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(clipperSize.width,clipperSize.height),1,1)
    clipper:setStencil(stencil)
    self.bgLayer:addChild(clipper,5)
    self.clipper=clipper

    self.switchIdx,self.switching=1,false
	local arrowPosX,arrowPosY=infoBg:getPositionX()+infoBg:getContentSize().width/2,infoBg:getPositionY()-infoBg:getContentSize().height
    local priority=-(self.layerNum-1)*20-4
	local function switchHandler()
		if self.switchIdx==nil or self.switchBtn==nil or self.clipper==nil or self.switching==true then
			do return end
		end
		local grade=believerVoApi:getMySegment()
		if grade==5 then
			do return end
		end
		if self.switchIdx==1 then
			self.switchBtn:setRotation(180)
		else
			self.switchBtn:setRotation(0)
		end
		self.switching=true
		for i=1,2 do
			local moveHeight=0
			local segPage=tolua.cast(self.clipper:getChildByTag(100+i),"LuaCCScale9Sprite")
			if segPage then
				if self.switchIdx==1 then
					moveHeight=segPage:getContentSize().height
				else
					moveHeight=-segPage:getContentSize().height
				end
				local moveBy=CCMoveBy:create(0.5,ccp(0,moveHeight))
				local function moveEnd()
					if i==2 then
						self.switching=false
						if self.switchIdx==1 then
							self.switchIdx=2
						else
							self.switchIdx=1
						end
					end
				end
				local func=CCCallFunc:create(moveEnd)
				segPage:runAction(CCSequence:createWithTwoActions(moveBy,func))
			end
		end
	end
	self.switchBtn=LuaCCSprite:createWithSpriteFrameName("believerArrow.png",switchHandler)
	self.switchBtn:setPosition(arrowPosX,arrowPosY)
	self.switchBtn:setTouchPriority(priority)
	believerLayer:addChild(self.switchBtn,3)
	local acArr=CCArray:create()
	local fadeIn=CCFadeIn:create(0.5)
	local fadeOut=CCFadeOut:create(0.5)
	acArr:addObject(fadeIn)
	acArr:addObject(fadeOut)
	local anim=CCRepeatForever:create(CCSequence:create(acArr))
	self.switchBtn:runAction(anim)

	self:initSegBaseInfo()

    local function matchHandler()
	    local function realHandler()
	    	self.status,self.cdTime=believerVoApi:checkSeasonStatus()
	        if self.status~=1 then
	        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage28106"),28)
	        	do return end
	        end
	        local function showMatchInfo(isuseani,matchEffectFlag)
	    		self:goToSubDialogHandler()
	        	believerVoApi:showMatchInfoDialog(self.layerNum+1,self,isuseani,matchEffectFlag)
	        end
	        local autoFlag=believerVoApi:getAutoBattleFlag()
			local matchFlag=believerVoApi:hasMatchPlayer()

	        if matchFlag==true then --查看对手信息
	        	showMatchInfo()
	        elseif autoFlag==true then --自动匹配
	        	local flag=believerVoApi:isTroopsCanAutoBattle()
	        	if flag==false then
	        		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_battle_trooplack"),28)
	        		do return end
	        	end
				self:goToSubDialogHandler()    	
	        	local function showSettlementDialog(data) --显示结算面板
	        		if data and data.result then
						self:goToSubDialogHandler()
	        			believerVoApi:showAutoBattleResultDialog(data.result,self.layerNum+1,nil,self)
	        		end
	        	end
	        	believerVoApi:showWaitingBattleDialog(self.layerNum+1,showSettlementDialog)
	        	believerVoApi:autoBattle()
	        else --单个匹配
		        local function matchCallBack()
			    	if self.matchLb then
	        			self.matchLb:setString(getlocal("believer_troop_look_marry"))
	        		end
		        	believerVoApi:showMatchSmallDialog(self.layerNum+1,showMatchInfo)
		        end
		        believerVoApi:requestMatch(matchCallBack)
		    end
	    end
	    G_touchedItem(self.matchBtn,realHandler,0.8)
    end
    local btnPosX,btnPosY=layerSize.width-100,infoBg:getPositionY()-infoBg:getContentSize().height/2
	self.matchBtn=G_createBotton(believerLayer,ccp(btnPosX,btnPosY),nil,"believerMatch3.png","believerMatch3.png","believerMatch.png",matchHandler,1,priority)

	local btnEffectSp=CCNode:create()
	btnEffectSp:setAnchorPoint(ccp(0.5,0.5))
	btnEffectSp:setPosition(getCenterPoint(self.matchBtn))
	self.matchBtn:addChild(btnEffectSp,2)
	self.btnEffectSp=btnEffectSp
	for i=1,5 do
		local frameNode=CCNode:create()
		frameNode:setAnchorPoint(ccp(0.5,0.5))
		frameNode:setRotation((i-1)*72)
		frameNode:setPosition(getCenterPoint(btnEffectSp))
		btnEffectSp:addChild(frameNode,2)
		local frameSp=CCSprite:createWithSpriteFrameName("believerMatch2.png")
		frameSp:setAnchorPoint(ccp(0.5,1))
		frameSp:setPosition(frameNode:getContentSize().width/2,70)
		frameNode:addChild(frameSp)

		local moveUp=CCMoveBy:create(0.5,ccp(0,-3))
		local moveDown=CCMoveBy:create(0.5,ccp(0,3))
		local seq=CCSequence:createWithTwoActions(moveUp,moveDown)
		frameSp:runAction(CCRepeatForever:create(seq))
	end
	local matchLbBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
	matchLbBg:setOpacity(120)
	matchLbBg:setContentSize(CCSizeMake(150,50))
	matchLbBg:setPosition(btnPosX,btnPosY)
	believerLayer:addChild(matchLbBg,2)

	local adaSize = 30
	if G_isAsia() == false then
		adaSize = 25
		if G_getCurChoseLanguage() == "de" then
			adaSize = 20
		end
	end
	local matchLb=GetTTFLabel("",adaSize,true)
	matchLb:setPosition(getCenterPoint(matchLbBg))
	matchLbBg:addChild(matchLb)
	self.matchLb=matchLb
	self:refreshMatchBtn() --刷新匹配按钮

	local score=believerVoApi:getMyUser().score
	if base.bab==1 and score<=believerCfg.contiLimit then --自动匹配5次开关
		local checkBox,uncheckBox
		local isCheck=believerVoApi:getAutoBattleFlag()
		local function selectAutoBattle()
			if isCheck==false then
		 		isCheck=true
        		if checkBox then
					checkBox:setVisible(isCheck)
				end
		        believerVoApi:setAutoBattleFlag(true)
			else
				isCheck=false
				if checkBox then
					checkBox:setVisible(isCheck)
				end
	        	believerVoApi:setAutoBattleFlag(false)
			end
		end
		local boxSize=40
		checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",selectAutoBattle)
		checkBox:setAnchorPoint(ccp(0,0.5))
		checkBox:setVisible(isCheck)
		checkBox:setScale(boxSize/checkBox:getContentSize().width)
		checkBox:setTouchPriority(-(self.layerNum-1)*20-3)
		uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",selectAutoBattle)
		uncheckBox:setAnchorPoint(ccp(0,0.5))
		uncheckBox:setScale(boxSize/uncheckBox:getContentSize().width)
		uncheckBox:setTouchPriority(-(self.layerNum-1)*20-3)
		local adaWidth = 200
		if G_isAsia() == false then
			adaWidth = 120
			if G_getCurChoseLanguage() == "ar" then
				adaWidth = 100
			end
		end
		local autoMatchLb=GetTTFLabelWrap(getlocal("believer_auto_battle",{believerCfg.contiMatch}),20,CCSizeMake(adaWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		autoMatchLb:setAnchorPoint(ccp(0,0.5))
		local checkBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
		checkBoxBg:setOpacity(0)
		checkBoxBg:setAnchorPoint(ccp(0,0.5))
		checkBoxBg:setContentSize(CCSizeMake(200,boxSize))
		checkBoxBg:setPosition(btnPosX-70,btnPosY-120)
		believerLayer:addChild(checkBoxBg,2)
		checkBox:setPosition(0,boxSize/2)
		uncheckBox:setPosition(0,boxSize/2)
		autoMatchLb:setPosition(ccp(uncheckBox:getPositionX()+boxSize+10,checkBox:getPositionY()))
		checkBoxBg:addChild(checkBox,4)
		checkBoxBg:addChild(uncheckBox,3)
		checkBoxBg:addChild(autoMatchLb,3)

		self.checkBoxBg=checkBoxBg
	end
	
	self:initBottom()

    --名人堂 点赞 请求数据
    local function needSuperManDataCall( )
    	self:initSuperManAccessDia()
    end 
    believerVoApi:superManHttpPost(needSuperManDataCall)

	--页面初始化完成后检测一下段位有没有发生变化
	believerVoApi:checkSegmentChanged()
end

--显示段位信息
function believerDialog:showSegmentInfoDialog()
	if self.segIconSp==nil then
		do return end
	end
	local function realHandler()
		self:goToSubDialogHandler()
		believerVoApi:showSegmentInfoDialog(self.layerNum+1,self)
	end
    G_touchedItem(self.segIconSp,realHandler,0.8)
end

function believerDialog:initSegBaseInfo()
	if self.clipper==nil then
		do return end
	end
	self.switchIdx,self.switching=1,false
	local grade=believerVoApi:getMySegment()
	if grade==5 and self.switchBtn then
		self.switchBtn:setVisible(false)
	end
	local believerCfg=believerVoApi:getBelieverCfg()
	local believerCfgVer=believerVoApi:getBelieverVerCfg()
	local clipperSize=self.clipper:getContentSize()
	local lbpos_x,lbpos_y=20,clipperSize.height-20
	local fontSize,fontWidth,fontSpace=20,220,20
	-- if G_getCurChoseLanguage() == "ar" then
	-- 	fontWidth = fontWidth - 30
	-- end
	if G_isIOS() == false and G_getCurChoseLanguage() ~= "ar" then
		fontWidth = fontWidth + 100
	end

	
	for i=1,2 do
		local tag=100+i
		local segPage=tolua.cast(self.clipper:getChildByTag(tag),"LuaCCScale9Sprite")
		if segPage then
			segPage:removeFromParentAndCleanup(true)
			segPage=nil
		end
		segPage=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function () end)
		segPage:setAnchorPoint(ccp(0.5,0.5))
		segPage:setContentSize(clipperSize)
		segPage:setOpacity(0)
		segPage:setTag(tag)
		segPage:setPosition(clipperSize.width/2,clipperSize.height/2-(i-1)*clipperSize.height)
		self.clipper:addChild(segPage)

		local user=believerVoApi:getMyUser()
		local gradeTask=user.grade_task --段位任务完成情况
		local grade,queue,score,fightNum,gradeFightNum,aveDmgRate,limitNum=1,1,0,0,0,0,-1
		if i==1 then
			grade,queue=believerVoApi:getMySegment()
			score=user.score or 0
			fightNum=user.total_battle_num or 0
			gradeFightNum=user.grade_battle_num or 0
			aveDmgRate=user.ave_dmg_rate or 0
			aveDmgRate=aveDmgRate/10
			if believerCfgVer.groupMsg[grade] and believerCfgVer.groupMsg[grade][queue] then
				limitNum=believerCfgVer.groupMsg[grade][queue].numLimit
			end
		else
			grade,queue=believerVoApi:getMySegment()
			grade,queue=believerVoApi:getNextSegment(grade,queue)
			if believerCfgVer.groupMsg[grade] and believerCfgVer.groupMsg[grade][queue] then
				local segCfg=believerCfgVer.groupMsg[grade][queue]
				score=segCfg.scoreRequire
				gradeFightNum=0
				aveDmgRate=0
				if believerCfg.levelTask[grade] then
					aveDmgRate=believerCfg.levelTask[grade].t[2]
					gradeFightNum=believerCfg.levelTask[grade].t[3]
				end
				limitNum=segCfg.numLimit
			end
		end
		local colorTb={nil,G_ColorYellowPro,nil}
		local segNameStr=""
		if i==2 then
			segNameStr=getlocal("believer_next_grade")
		else
			segNameStr=getlocal("believer_seg",{""})
		end
		local segmentLb,lbHeight1=G_getRichTextLabel(segNameStr,colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    segmentLb:setAnchorPoint(ccp(0,1))
	    segmentLb:setPosition(lbpos_x,lbpos_y)
	    segPage:addChild(segmentLb)
	    local tempLb=GetTTFLabel(segNameStr,fontSize)
	    local realW=tempLb:getContentSize().width
	    if realW>fontWidth then
	    	realW=fontWidth
	    end
	    local iconWidth=50
		local segIconSp=believerVoApi:getSegmentIcon(grade,queue,iconWidth)
		if G_getCurChoseLanguage() == "ar" then
			segIconSp:setPosition(lbpos_x+realW+iconWidth/2-70,lbpos_y-lbHeight1/2)
		else
			segIconSp:setPosition(lbpos_x+realW+iconWidth/2-10,lbpos_y-lbHeight1/2)
		end
		segPage:addChild(segIconSp)

		local user=believerVoApi:getMyUser()
		if i==2 then
			if score>(user.score or 0) then
				colorTb={nil,G_ColorRed,nil}
			else
				colorTb={nil,G_ColorGreen,nil}
			end
		end
	    local pointLb,lbHeight2=G_getRichTextLabel(getlocal("believer_point",{score}),colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    pointLb:setAnchorPoint(ccp(0,1))
	    pointLb:setPosition(lbpos_x,segmentLb:getPositionY()-lbHeight1-fontSpace)
	    segPage:addChild(pointLb)

	    local battleNumStr=""
	    if i==2 then
			if gradeTask>=grade then --该段位任务已经完成过
				colorTb={nil,G_ColorGreen,nil}
			else
				if gradeFightNum>(user.grade_battle_num or 0) then
					colorTb={nil,G_ColorRed,nil}
				else
					colorTb={nil,G_ColorGreen,nil}
				end
			end
			battleNumStr=getlocal("believer_grade_num",{gradeFightNum})
		else
			battleNumStr=getlocal("believer_battle_num",{gradeFightNum,fightNum})
	    end
	    local fightNumLb,lbHeight3=G_getRichTextLabel(battleNumStr,colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    fightNumLb:setAnchorPoint(ccp(0,1))
	    fightNumLb:setPosition(lbpos_x,pointLb:getPositionY()-lbHeight2-fontSpace)
	    segPage:addChild(fightNumLb)

	    if i==2 then
			if gradeTask>=grade then --该段位任务已经完成过
				colorTb={nil,G_ColorGreen,nil}
			else
				if aveDmgRate>((user.ave_dmg_rate or 0)/10) then
					colorTb={nil,G_ColorRed,nil}
				else
					colorTb={nil,G_ColorGreen,nil}
				end
			end
	    end
	    local aveDmgRateLb,lbHeight4=G_getRichTextLabel(getlocal("believer_avedmgRate",{aveDmgRate}),colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    aveDmgRateLb:setAnchorPoint(ccp(0,1))
	    aveDmgRateLb:setPosition(lbpos_x,fightNumLb:getPositionY()-lbHeight3-fontSpace)
	    segPage:addChild(aveDmgRateLb)

	    if limitNum>0 then
	    	colorTb={nil,G_ColorWhite,nil}
		    local limitLb,lbHeight5=G_getRichTextLabel(getlocal("capacity")..limitNum,colorTb,fontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		    limitLb:setAnchorPoint(ccp(0,1))
		    limitLb:setPosition(lbpos_x,aveDmgRateLb:getPositionY()-lbHeight4-fontSpace)
		    segPage:addChild(limitLb)
	    end
	end
end

function believerDialog:initSignLayer()
	local signLayer=CCLayer:create()
	signLayer:setAnchorPoint(ccp(0,0))
	signLayer:setPosition(0,0)
	self.bgLayer:addChild(signLayer,2)
	self.signLayer=signLayer

	local fontSize=25
	local seasonSt,seasonEt=believerVoApi:getSeasonTime()
	local timeLb=GetTTFLabelWrap(getlocal("believer_seasonTime",{G_getDateStr(seasonSt,true,true),G_getDateStr(seasonEt,true,true)}),fontSize,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-120)
	self.signLayer:addChild(timeLb)
	local believerCfg=believerVoApi:getBelieverCfg()
	local function touchTip()
        local str1=getlocal("believer_sign_info_1")
        local str2=getlocal("believer_sign_info_2",{believerCfg.levelLimit})
        local str3=getlocal("believer_sign_info_3",{believerCfg.season,believerCfg.offSeason})
        local str4=getlocal("believer_sign_info_4")
        local str5=getlocal("believer_sign_info_5")
        local strTb={str1,str2,str3,str4,str5}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),strTb)
	end
	G_addMenuInfo(self.signLayer,self.layerNum,ccp(G_VisibleSizeWidth-50,timeLb:getPositionY()),{},nil,nil,28,touchTip,true)

	local mainBg=CCSprite:create("public/believer/believerSignBg.png")
	mainBg:setAnchorPoint(ccp(0.5,1))
	mainBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
	self.signLayer:addChild(mainBg)

    local backSprite=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
	backSprite:setContentSize(CCSizeMake(616,G_VisibleSizeHeight-160-mainBg:getContentSize().height-30))
    backSprite:setAnchorPoint(ccp(0.5,1))
    backSprite:setPosition(G_VisibleSizeWidth/2,mainBg:getPositionY()-mainBg:getContentSize().height-5)
    self.signLayer:addChild(backSprite)
	--赛季阶段
	local statusBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    statusBg:setPosition(backSprite:getContentSize().width/2,backSprite:getContentSize().height-10-statusBg:getContentSize().height/2)
    backSprite:addChild(statusBg)
    -- 状态与倒计时
    self.status,self.cdTime=believerVoApi:checkSeasonStatus()
    -- 倒计时
	local cdTimeLb=GetTTFLabelWrap(getlocal("believer_match_status_"..self.status).."："..GetTimeForItemStrState(self.cdTime),fontSize,CCSizeMake(G_VisibleSizeWidth-180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	cdTimeLb:setPosition(getCenterPoint(statusBg))
	statusBg:addChild(cdTimeLb)
	self.cdTimeLb=cdTimeLb
	--功能描述
    local descTb={
        {getlocal("believer_sign_play_desc")}
    }
    local desTv=G_LabelTableViewNew(CCSizeMake(G_VisibleSizeWidth-80,backSprite:getContentSize().height-180),descTb,fontSize-2,kCCTextAlignmentLeft,G_ColorGreen)
    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	desTv:setAnchorPoint(ccp(0,0))
    desTv:setPosition(ccp(40,110))
    backSprite:addChild(desTv)

	local priority=-(self.layerNum-1)*20-4
	local function sign()
        if believerVoApi:getSeason()>0 and believerVoApi:checkSeasonStatus()==1 then
			local function signCallBack()
				self:initMainLayer()
			end
			believerVoApi:believerSign(signCallBack)
        else
	    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_sign_stauts_prompt"),28)
        end
	end
	local signBtn=G_createBotton(backSprite,ccp(G_VisibleSizeWidth/2,60),{getlocal("allianceWar_sign")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sign,1,priority)
end

function believerDialog:initBottom()
	local addH=0
	if self.iphoneType==G_iphone4 then
		addH=-40
	end
	local layerSize=self.believerLayer:getContentSize()
	local firstPosX=80
	local spaceX=(G_VisibleSizeWidth-2*firstPosX)/4
	local bottomBg=LuaCCScale9Sprite:createWithSpriteFrameName("believerBottomBg.png",CCRect(20,0,20,34),function()end)
	bottomBg:setContentSize(CCSizeMake(600,34))
	bottomBg:setPosition(layerSize.width/2,80+addH)
	self.believerLayer:addChild(bottomBg)

	local priority=-(self.layerNum-1)*20-4

    local function reportHandler()
    	local function requestCallBack()
			self:goToSubDialogHandler()
			believerVoApi:showReportListDialog(self.layerNum+1,self)
		end
		believerVoApi:battleReportHttpRequest(requestCallBack)
    end
    local function rankHandler()
    	self:goToSubDialogHandler()
    	believerVoApi:showRankDialog(self.layerNum+1,self)
    end
   	local function shopHandler()
    	self:goToSubDialogHandler()
    	believerVoApi:showShopDialog(self.layerNum+1,self)
    end
   	local function rewardHandler()
    	self:goToSubDialogHandler()	
   		believerVoApi:showRewardDialog(self.layerNum+1,self)
    end
   	local function exchangeHandler()
    	self:goToSubDialogHandler()
    	believerVoApi:showTankExchangeDialog(self.layerNum+1,self)
    end
	local btnCfg={
		{pic="territoryIcon.png",callback=exchangeHandler,name=getlocal("believer_exchange_place")},
		{pic="mainBtnRank.png",callback=rankHandler,name=getlocal("google_rank")},	
		{pic="mainBtnMail.png",callback=reportHandler,name=getlocal("allianceWar_battleReport")},
		{pic="mainBtnItems.png",callback=shopHandler,name=getlocal("market")},
		{pic="mainBtnGift.png",callback=rewardHandler,name=getlocal("award")},
	}

	for k,v in pairs(btnCfg) do
		local btnItem=nil
		local btnPosX,btnPosY=firstPosX+(k-1)*spaceX,110+addH
		local btnScale=1
		if k==1 then
			btnScale=0.8
		end
		local targetScale=0.8*btnScale
		local function touchHandler()
			local function realHandler()
				if v.callback then
					v.callback()
				end
			end
       		G_touchedItem(btnItem,realHandler,targetScale)
		end
		
		btnItem=G_createBotton(self.believerLayer,ccp(btnPosX,btnPosY),nil,v.pic,v.pic,v.pic,touchHandler,btnScale,priority)
		local adaWidth1 = 85
		local strSize = 20
		if G_isAsia() == false then
			adaWidth1 = 100
			if (k == 2 or k == 5) and G_getCurChoseLanguage() == "fr" then
				strSize = 16
			end
		end
    	local btnNameLb=GetTTFLabelWrap(v.name,strSize,CCSizeMake(adaWidth1,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    	btnNameLb:setAnchorPoint(ccp(0.5,1))
    	btnNameLb:setPosition(btnPosX,btnPosY-36)
    	btnNameLb:setColor(G_ColorGreen3)
    	self.believerLayer:addChild(btnNameLb)
	end
end

function believerDialog:refreshMainLayer()
	if self.believerLayer==nil then
		do return end
	end
	self.status,self.cdTime=believerVoApi:checkSeasonStatus()
	if self.segIconSp and tolua.cast(self.segIconSp,"LuaCCSprite") then
		local segPosX,segPosY=self.segIconSp:getPosition()
		self.segIconSp:removeFromParentAndCleanup(true)
		self.segIconSp=nil
		local function touchHandler()
			self:showSegmentInfoDialog()
		end
		local grade,queue=believerVoApi:getMySegment()
	    local segIconSp=believerVoApi:getSegmentIcon(grade,queue,nil,touchHandler)
	    segIconSp:setTouchPriority(-(self.layerNum-1)*20-3)
	    segIconSp:setPosition(segPosX,segPosY)
	    self.believerLayer:addChild(segIconSp,3)
	    self.segIconSp=segIconSp
	    self:addGradeAction(segIconSp)
	end
	local believerCfg=believerVoApi:getBelieverCfg()
	self:initSegBaseInfo()
	self:refreshMatchBtn()
	if self.checkBoxBg then
		local score=believerVoApi:getMyUser().score
		if base.bab==1 and score<=believerCfg.contiLimit then --自动匹配5次开关
			self.checkBoxBg:setVisible(true)
		else
			self.checkBoxBg:setVisible(false)
			believerVoApi:setAutoBattleFlag(false)
		end
	end
end

function believerDialog:refreshMatchBtn()
	if self.matchLb and self.matchBtn then
		local matchFlag,mathPlayer=believerVoApi:hasMatchPlayer()
		local matchBtnStr=getlocal("believer_match")
		local canMatch=true
		if matchFlag==true then
			matchBtnStr=getlocal("believer_troop_look_marry")
		end
		if self.status~=1 then
			matchBtnStr=getlocal("believer_match_status_2")
			canMatch=false
		end
		self.matchBtn:setEnabled(canMatch)
		self.matchLb:setString(matchBtnStr)
		if canMatch==false and self.btnEffectSp then
			self.btnEffectSp:setVisible(false)
		end
	end
end

function believerDialog:initTableView()
	
end

--进入所有界面，需要隐藏此主页
function believerDialog:goToSubDialogHandler()
	self.keepTick=false
end

--返回到此主页
function believerDialog:backToMainDialogHandler()
	self.keepTick=true
end

function believerDialog:tick()
	if self.keepTick==true then
		if self.bgLayer and self.bgLayer:isVisible()==true then
			if battleScene and battleScene.isBattleing==true then
				do return end
			end
			if self.waitShowChangeTb and self.waitShowChangeTb[1]~=nil then
				for k,v in pairs(self.waitShowChangeTb) do
					local function showGivesHandler()
						if v.gives then
    						believerVoApi:showReceiveTroopsDialog(v.gives,self.layerNum+2)
						end
					end
					believerVoApi:showGradeChangeSmallDialog(v.info,showGivesHandler,self.layerNum+2)
					do break end
				end
				self.waitShowChangeTb={}
			end
		end
		local gives=believerVoApi:getTroopsGives()
		if gives then
			believerVoApi:showReceiveTroopsDialog(gives,self.layerNum+2)
			believerVoApi:clearTroopsGives()
		end
	end
	if believerVoApi:isThumpUp() == 0 then 
		if self.grayPraiseIcon then
	   		self.grayPraiseIcon:setVisible(false)
	   	end
	end
	if self.cdTimeLb and tolua.cast(self.cdTimeLb,"CCLabelTTF") and self.cdTime and self.cdTime>0 and self.status then
		self.cdTime=self.cdTime-1
		if self.cdTime<=0 then
	    	self.status,self.cdTime=believerVoApi:checkSeasonStatus()
			self:refreshMatchBtn() --赛季状态发生变化时刷新匹配按钮
		end
	    self.cdTimeLb:setString(getlocal("believer_match_status_"..self.status).."："..GetTimeForItemStrState(self.cdTime))
	end
end
function believerDialog:initSuperManAccessDia()
	self.superManNum,self.superManTb = believerVoApi:getSuperManTbData()
	if self.superManNum == 0 or self.superManTb == nil then
		do return end
	end
	local curSuperManTb = self.superManTb[1]
	local bgHeightScale = 0.68
	if self.iphoneType==G_iphone5 then
		bgHeightScale = 0.68
	elseif self.iphoneType==G_iphoneX then
		bgHeightScale=0.7
	end
	local bgSpWidth,bgSpHeight = 145,240
	local smBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function()end)
    smBgSp:setContentSize(CCSizeMake(bgSpWidth,bgSpHeight))
    smBgSp:setPosition(ccp(95,G_VisibleSizeHeight * bgHeightScale))
    self.bgLayer:addChild(smBgSp,50)
    self.smBgSp = smBgSp

    local superManStr = GetTTFLabelWrap(getlocal("believer_superManStr"),25,CCSizeMake(144,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    superManStr:setAnchorPoint(ccp(0.5,0))
    superManStr:setColor(G_ColorYellowPro2)
    superManStr:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight - 45))
    smBgSp:addChild(superManStr)

    local picName=playerVoApi:getPersonPhotoName(curSuperManTb[4])
    local superManIcon = playerVoApi:GetPlayerBgIcon(picName,nil,nil,nil,100,"h3001")
    superManIcon:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight - 100))
    -- superManIcon:setScale(0.95)
    self.superManIconScale = 100/superManIcon:getContentSize().height
    self.superManIcon = superManIcon
    smBgSp:addChild(superManIcon)
    -- self.superManIconBorde = believerVoApi:addIconBorder(smBgSp,superManIcon,100)
    -- self.superManIconBordeScale = 100/self.superManIconBorde:getContentSize().height

	--服务器
    local timeStr = GetTTFLabel(GetServerNameByID(curSuperManTb[3],true),22)--"S"..curSuperManTb[1]
    timeStr:setAnchorPoint(ccp(0.5,1))
    timeStr:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight - 150))
    smBgSp:addChild(timeStr)
    if timeStr:getContentSize().width > bgSpWidth then
    	timeStr:setScale((bgSpWidth-4)/timeStr:getContentSize().width)
    end
    --玩家  - 名字
    local superManName = GetTTFLabel(curSuperManTb[5],22)
    superManName:setAnchorPoint(ccp(0.5,1))
    superManName:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight - 175))
    if superManName:getContentSize().width > bgSpWidth then
    	superManName:setScale((bgSpWidth-4)/superManName:getContentSize().width)
    end
    smBgSp:addChild(superManName)

    local function initSuperManDiaCall( )
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
    	local function realShow()
    		believerVoApi:initSuperManDia(self.layerNum + 1,self)	
    	end
    	if self.superManIcon then
	    	G_touchedItem(self.superManIcon,realShow,0.8)
	    end
	    -- if self.superManIconBorde then
	    	-- G_touchedItem(self.superManIconBorde,realShow,0.4)
	    -- end
    end 
    local touchDialog = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),initSuperManDiaCall);
    touchDialog:setOpacity(0)
    touchDialog:setContentSize(CCSizeMake(bgSpWidth,150))
    touchDialog:setIsSallow(false)
   	touchDialog:setTouchPriority(-(self.layerNum-1)*20-2)
   	touchDialog:setAnchorPoint(ccp(0.5,1))
   	touchDialog:setPosition(ccp(bgSpWidth * 0.5,bgSpHeight))
   	smBgSp:addChild(touchDialog)

   	local praiseIcon=CCSprite:createWithSpriteFrameName("newsPraiseIcon.png")
   	praiseIcon:setAnchorPoint(ccp(0,0))
   	praiseIcon:setScale(0.8)
   	praiseIcon:setPosition(ccp(28,8))
   	smBgSp:addChild(praiseIcon)
   	self.praiseIcon = praiseIcon

   	local grayPraiseIcon = GraySprite:createWithSpriteFrameName("newsPraiseIcon.png")
   	grayPraiseIcon:setPosition(getCenterPoint(praiseIcon))
   	praiseIcon:addChild(grayPraiseIcon)
   	grayPraiseIcon:setVisible(false)
   	self.grayPraiseIcon = grayPraiseIcon

	local praiseLb=GetTTFLabel(curSuperManTb[9],24)
	praiseLb:setAnchorPoint(ccp(0,0))
   	praiseLb:setPosition(ccp(praiseIcon:getPositionX() + praiseIcon:getContentSize().width + 5,8))
   	smBgSp:addChild(praiseLb)
   	self.praiseLb = praiseLb

   	if believerVoApi:isThumpUp() == 1 then
   		self.grayPraiseIcon:setVisible(true)
	end

   	local function thumpUpCall( )
   		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        --测试用
		--
   		if believerVoApi:isThumpUp() == 1 then--believer_praiseTip
   			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_praiseTip"),30)
   			do return end
   		end
   		local function callback( )
   			if self.praiseIcon then
	    		-- local scaleTo1 = CCScaleTo:create(0.2,0.6)
		    	-- local scaleTo2 = CCScaleTo:create(0.2,0.8)
		    	-- local function funcCall()
		    		self.grayPraiseIcon:setVisible(true)	
		    	-- end
		    	-- local callFunc = CCCallFuncN:create(funcCall)
		    	-- local arr = CCArray:create()
		    	-- arr:addObject(scaleTo1)
		    	-- arr:addObject(scaleTo2)
		    	-- arr:addObject(callFunc)
		    	-- local seq = CCSequence:create(arr)
		    	-- self.praiseIcon:runAction(seq)

		    	G_touchedItem(self.praiseIcon,nil,0.6)
		    end
   			self.praiseLb:setString(curSuperManTb[9] + 1)
   			local addKcoin = believerVoApi:getBelieverCfg().thumbs
   			smallDialog:showSpAndTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),addKcoin,28,nil,nil,nil,nil,nil,"believerKcoin.png")
   		end 
    	believerVoApi:socketThumpUp(callback,curSuperManTb[1])
    end 
    local touchDialog2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),thumpUpCall);
    touchDialog2:setOpacity(0)
    touchDialog2:setContentSize(CCSizeMake(bgSpWidth*0.5,50))
    touchDialog2:setIsSallow(false)
   	touchDialog2:setTouchPriority(-(self.layerNum-1)*20-2)
   	touchDialog2:setAnchorPoint(ccp(0.5,0))
   	touchDialog2:setPosition(ccp(bgSpWidth * 0.25,0))
   	smBgSp:addChild(touchDialog2)

   	--curSuperManTb[8]--点赞数
end

function believerDialog:addGradeAction(parent)

	local nowGrade = believerVoApi:getMySegment()
	if nowGrade<3 then
		do return end
	end

	local unitTime = 0.08
	local actionSp
	local pzArr
	local nameStr
	local frame
	local animation
	local animate
	local repeatForever

	if nowGrade==3 then

		local lightSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_1_1.png")
		lightSp:setAnchorPoint(ccp(0.5,0))
		lightSp:setPosition(ccp(parent:getContentSize().width/2,48))
		parent:addChild(lightSp)

		pzArr=CCArray:create()
		for kk=1,20 do
		    nameStr = "kr_action_"..nowGrade.."_1_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		local waitTime = 3
		local delay1 = CCDelayTime:create(unitTime*12+waitTime)
		local seq = CCSequence:createWithTwoActions(animate,delay1)
		repeatForever=CCRepeatForever:create(seq)
		lightSp:runAction(repeatForever)

		local wingSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_2_1.png")
		wingSp:setAnchorPoint(ccp(0.5,0.5))
		wingSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height/2-2))
		wingSp:setScaleX(1.01)
		parent:addChild(wingSp)

		pzArr=CCArray:create()
		for kk=1,11 do
		    nameStr = "kr_action_"..nowGrade.."_2_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		delay1 = CCDelayTime:create(unitTime*21)
		local delay2 = CCDelayTime:create(waitTime)
		local acArr = CCArray:create()
		acArr:addObject(delay1)
		acArr:addObject(animate)
		acArr:addObject(delay2)
		seq = CCSequence:create(acArr)
		repeatForever=CCRepeatForever:create(seq)
		wingSp:runAction(repeatForever)

	elseif nowGrade==4 then
		local fireSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_1_1.png")
		fireSp:setAnchorPoint(ccp(0.5,1))
		fireSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height+33))
		fireSp:setScaleX(0.95)
		parent:addChild(fireSp)

		pzArr=CCArray:create()
		for kk=1,20 do
		    nameStr = "kr_action_"..nowGrade.."_1_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		repeatForever=CCRepeatForever:create(animate)
		fireSp:runAction(repeatForever)

		local lightSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_2_1.png")
		lightSp:setAnchorPoint(ccp(0.5,0))
		lightSp:setPosition(ccp(parent:getContentSize().width/2,50))
		parent:addChild(lightSp)

		pzArr=CCArray:create()
		for kk=1,16 do
		    nameStr = "kr_action_"..nowGrade.."_2_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		local waitTime = 3
		local delay1 = CCDelayTime:create(unitTime*19+waitTime)
		local seq = CCSequence:createWithTwoActions(animate,delay1)
		repeatForever=CCRepeatForever:create(seq)
		lightSp:runAction(repeatForever)

		local wingSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_3_1.png")
		wingSp:setAnchorPoint(ccp(0.5,1))
		wingSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height-23))
		wingSp:setScaleX(0.95)
		parent:addChild(wingSp)

		pzArr=CCArray:create()
		for kk=1,18 do
		    nameStr = "kr_action_"..nowGrade.."_3_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		delay1 = CCDelayTime:create(unitTime*17)
		local delay2 = CCDelayTime:create(waitTime)
		local acArr = CCArray:create()
		acArr:addObject(delay1)
		acArr:addObject(animate)
		acArr:addObject(delay2)
		seq = CCSequence:create(acArr)
		repeatForever=CCRepeatForever:create(seq)
		wingSp:runAction(repeatForever)
	elseif nowGrade==5 then

		local fireSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_3_1.png")
		fireSp:setAnchorPoint(ccp(0.5,1))
		fireSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height+17))
		parent:addChild(fireSp)

		pzArr=CCArray:create()
		for kk=1,15 do
		    nameStr = "kr_action_"..nowGrade.."_3_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		repeatForever=CCRepeatForever:create(animate)
		fireSp:runAction(repeatForever)

		local lightSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_1_1.png")
		lightSp:setAnchorPoint(ccp(0.5,0))
		lightSp:setPosition(ccp(parent:getContentSize().width/2,38))
		parent:addChild(lightSp)

		pzArr=CCArray:create()
		for kk=1,16 do
		    nameStr = "kr_action_"..nowGrade.."_1_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		local waitTime = 3
		local delay1 = CCDelayTime:create(unitTime*20+waitTime)
		local seq = CCSequence:createWithTwoActions(animate,delay1)
		repeatForever=CCRepeatForever:create(seq)
		lightSp:runAction(repeatForever)

		local wingSp = CCSprite:createWithSpriteFrameName("kr_action_"..nowGrade.."_2_1.png")
		wingSp:setAnchorPoint(ccp(0.5,1))
		wingSp:setPosition(ccp(parent:getContentSize().width/2,parent:getContentSize().height-30))
		parent:addChild(wingSp)

		pzArr=CCArray:create()
		for kk=1,19 do
		    nameStr = "kr_action_"..nowGrade.."_2_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		delay1 = CCDelayTime:create(unitTime*17)
		local delay2 = CCDelayTime:create(waitTime)
		local acArr = CCArray:create()
		acArr:addObject(delay1)
		acArr:addObject(animate)
		acArr:addObject(delay2)
		seq = CCSequence:create(acArr)
		repeatForever=CCRepeatForever:create(seq)
		wingSp:runAction(repeatForever)
	end
end

function believerDialog:showBgAction(centerPosX,centerPosY)
	for k=1,3 do
		local picName = ""
		local startScale = 0.7
		local endScale = 1.08
		local time = 1.5
		local startOpacity = 150
		if k==1 then -- 外部圆圈
			picName = "kr_effect_circle.png"
		elseif k==2 then -- 内部小方形框
			startOpacity = 255
			startScale = 0.5
			endScale = 1.1
			time = 1.5
			picName = "kr_effect_rect.png"
		elseif k==3 then -- 内部大方形框
			startScale = 1
			endScale = 1.5
			time = 1.5
			picName = "kr_effect_rect.png"
		end
		local circleSp = CCSprite:createWithSpriteFrameName(picName)
		circleSp:setAnchorPoint(ccp(0.5,0.5))
		circleSp:setPosition(ccp(centerPosX,centerPosY))
		circleSp:setScale(startScale)
		circleSp:setOpacity(0)
		self.believerLayer:addChild(circleSp)

		local circleFadeTo1 = CCFadeTo:create(time/2,startOpacity)
		local circleFadeTo2 = CCFadeTo:create(time/2,0)
		local fadeSeq = CCSequence:createWithTwoActions(circleFadeTo1,circleFadeTo2)
		local circleScale = CCScaleTo:create(time,endScale,endScale)
		local circleSpawn = CCSpawn:createWithTwoActions(fadeSeq,circleScale)
		local function resetCircleScale()
			if circleSp then
				circleSp:setOpacity(0)
				circleSp:setScale(startScale)
			end
		end
		local circleCallFunc = CCCallFunc:create(resetCircleScale)
		local circleSeq = CCSequence:createWithTwoActions(circleSpawn,circleCallFunc)
		local circleRepeat = CCRepeatForever:create(circleSeq)
		circleSp:runAction(circleRepeat)
	end

	local unitTime = 0.14
	local actionSp
	local pzArr
	local nameStr
	local frame
	local animation
	local animate
	local repeatForever

	for k=1,4 do -- 方形四角
		local actionSp = CCSprite:createWithSpriteFrameName("kr_effect_1_1.png")
		actionSp:setAnchorPoint(ccp(0.5,0.5))
		if k==1 then -- 左上角
			actionSp:setPosition(ccp(centerPosX-65,centerPosY+65))
		elseif k==2 then -- 右上角
			actionSp:setPosition(ccp(centerPosX+65,centerPosY+65))
			actionSp:setFlipX(true)
		elseif k==3 then -- 左下角
			actionSp:setPosition(ccp(centerPosX-65,centerPosY-65))
			actionSp:setFlipY(true)
		else -- 右下角
			actionSp:setPosition(ccp(centerPosX+65,centerPosY-65))
			actionSp:setFlipX(true)
			actionSp:setFlipY(true)
		end
		actionSp:setOpacity(150)
		self.believerLayer:addChild(actionSp)
		
		pzArr=CCArray:create()
		for kk=1,10 do
		    nameStr = "kr_effect_1_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		repeatForever=CCRepeatForever:create(animate)
		actionSp:runAction(repeatForever)
	end

	for k=1,4 do -- 外部大箭头
		local actionSp = CCSprite:createWithSpriteFrameName("kr_effect_2_1.png")
		actionSp:setAnchorPoint(ccp(0.5,0.5))
		if k==1 then -- 上
			actionSp:setPosition(ccp(centerPosX,centerPosY+145))
		elseif k==2 then -- 下
			actionSp:setPosition(ccp(centerPosX,centerPosY-145))
			actionSp:setFlipY(true)
		elseif k==3 then -- 左
			actionSp:setPosition(ccp(centerPosX-145,centerPosY))
			actionSp:setRotation(-90)
		else -- 右
			actionSp:setPosition(ccp(centerPosX+145,centerPosY))
			actionSp:setRotation(90)
		end
		actionSp:setOpacity(150)
		self.believerLayer:addChild(actionSp)
		
		pzArr=CCArray:create()
		for kk=1,10 do
		    nameStr = "kr_effect_2_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		repeatForever=CCRepeatForever:create(animate)
		actionSp:runAction(repeatForever)
	end

	for k=1,4 do -- 内部小箭头
		local actionSp = CCSprite:createWithSpriteFrameName("kr_effect_3_1.png")
		actionSp:setAnchorPoint(ccp(0.5,0.5))
		if k==1 then -- 上
			actionSp:setPosition(ccp(centerPosX,centerPosY+95))
			actionSp:setRotation(90)
		elseif k==2 then -- 下
			actionSp:setPosition(ccp(centerPosX,centerPosY-95))
			actionSp:setRotation(-90)
		elseif k==3 then -- 左
			actionSp:setPosition(ccp(centerPosX-95,centerPosY))
		else -- 右
			actionSp:setPosition(ccp(centerPosX+95,centerPosY))
			actionSp:setFlipX(true)
		end
		actionSp:setOpacity(150)
		self.believerLayer:addChild(actionSp)
		
		pzArr=CCArray:create()
		for kk=1,10 do
		    nameStr = "kr_effect_3_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		repeatForever=CCRepeatForever:create(animate)
		actionSp:runAction(repeatForever)
	end

	for k=1,4 do -- 半弧线四角
		local actionSp = CCSprite:createWithSpriteFrameName("kr_effect_4_1.png")
		actionSp:setAnchorPoint(ccp(0.5,0.5))
		if k==1 then -- 左上角
			actionSp:setPosition(ccp(centerPosX-120,centerPosY+120))
			actionSp:setRotation(-41)
		elseif k==2 then -- 右上角
			actionSp:setPosition(ccp(centerPosX+120,centerPosY+120))
			actionSp:setRotation(49)
		elseif k==3 then -- 左下角
			actionSp:setPosition(ccp(centerPosX-120,centerPosY-120))
			actionSp:setRotation(41)
			actionSp:setFlipY(true)
		else -- 右下角
			actionSp:setPosition(ccp(centerPosX+120,centerPosY-120))
			actionSp:setRotation(-41)
			actionSp:setFlipY(true)
			actionSp:setFlipX(true)
		end
		actionSp:setOpacity(150)
		self.believerLayer:addChild(actionSp)	
		
		pzArr=CCArray:create()
		for kk=1,10 do
		    nameStr = "kr_effect_4_"..kk..".png"
		    frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		    pzArr:addObject(frame)
		end
		animation=CCAnimation:createWithSpriteFrames(pzArr)
		animation:setDelayPerUnit(unitTime)
		animate=CCAnimate:create(animation)
		repeatForever=CCRepeatForever:create(animate)
		actionSp:runAction(repeatForever)
	end
end

function believerDialog:dispose()
	spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
    spriteController:removePlist("public/believer/believerTexture.plist")
    spriteController:removeTexture("public/believer/believerTexture.png")
	spriteController:removePlist("scene/allianceCityImages.plist")
	spriteController:removeTexture("scene/allianceCityImages.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/dailyNews.plist")
    spriteController:removeTexture("public/dailyNews.png")
    spriteController:removePlist("public/believer/killRaceEffectImage1.plist")
    spriteController:removeTexture("public/believer/killRaceEffectImage1.pvr.ccz")
    spriteController:removePlist("public/believer/killRaceEffectImage2.plist")
    spriteController:removeTexture("public/believer/killRaceEffectImage2.pvr.ccz")
    self.signLayer=nil
    self.believerLayer=nil
    self.clipper=nil
    self.switchBtn=nil
    self.switchIdx=nil
    self.switching=nil
    self.matchLb=nil
    self.btnEffectSp=nil
    self.checkBox=nil
    self.uncheckBox=nil
    self.iphoneType=nil
    self.cdTimeLb=nil
    self.gives=nil
    self.waitShowChangeTb=nil
    if self.refreshListener then
		eventDispatcher:removeEventListener("believer.main.refresh",self.refreshListener)
		self.refreshListener=nil
    end
    if self.dayRefreshListener then
	    eventDispatcher:removeEventListener("believer.day.refresh",self.dayRefreshListener)
	    self.dayRefreshListener=nil
    end
end

return believerDialog