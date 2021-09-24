ltzdzBattleEndSmallDialog=smallDialog:new()

function ltzdzBattleEndSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	spriteController:addPlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:addTexture("public/ltzdz/ltzdzSegImages2.png")
	return nc
end

function ltzdzBattleEndSmallDialog:showEnd(layerNum,istouch,isuseami,taskFunc,endInfo,state)
	local sd=ltzdzBattleEndSmallDialog:new()
    sd:initEnd(layerNum,istouch,isuseami,taskFunc,endInfo,state)
    return sd
end

-- state 2：胜利 3：平局 4：失败
function ltzdzBattleEndSmallDialog:initEnd(layerNum,istouch,isuseami,taskFunc,endInfo,state)
	self.layerNum=layerNum
	self.istouch=istouch
	self.isuseami=isuseami

	self.dialogLayer=CCLayer:create()
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setTouchEnabled(true)
    self.dialogLayer:setBSwallowsTouches(true)
    
    local function touchHandler() end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(0,0,40,40),touchHandler)
    dialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight))
    self.dialogLayer:addChild(dialogBg,2)
    dialogBg:setPosition(0,0)
    dialogBg:setAnchorPoint(ccp(0,0))
    dialogBg:setOpacity(0)
    self.bgLayer=dialogBg
    self:show()

    local dialogSize=dialogBg:getContentSize()

	-- 上

	if state==2 then
		self.victory=true
	else
		self.victory=false
	end

	self:addNeedPlist()

 	local function initCenterAndBottom()
 		local dTime=0 -- 延迟时间

 		local actionTb={}

 		local resultH
 		-- if(G_isIphone5()==false)then
 		-- 	resultH=G_VisibleSizeHeight-200
 		-- else
 			resultH=G_VisibleSizeHeight-295
 		-- end
 		-- 上
 		local resultStr=""
 		if state==2 then
 			if endInfo and endInfo.a and endInfo.a[2] then
	 			resultStr=getlocal("ltzdz_win_title2",{endInfo.a[2]})
	 		else
	 			resultStr=getlocal("ltzdz_win_title1")
	 		end
 		elseif state==3 then
 			resultStr=getlocal("ltzdz_draw_title")
 		else
 			if endInfo and endInfo.df and endInfo.df[2] then
	 			local loserName=endInfo.df[2]
	 			resultStr=getlocal("ltzdz_lose_title1",{loserName})
	 		else
	 			resultStr=getlocal("ltzdz_lose_title2")
 			end
 		end
		local resultLb=GetTTFLabelWrap(resultStr,28,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		self.bgLayer:addChild(resultLb)
		resultLb:setPosition(G_VisibleSizeWidth/2,resultH)

 		-- 中

 		local centerStartH
 		-- if(G_isIphone5()==false)then
 		-- 	centerStartH=G_VisibleSizeHeight-420
 		-- else
 			centerStartH=G_VisibleSizeHeight-510
 		-- end
 		local centerSubH=50

 		local upH=160

 		local function add888()
 			local startLineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
	 		self.bgLayer:addChild(startLineSp,2)
	 		startLineSp:setPosition(G_VisibleSizeWidth/2,centerStartH+upH)

	 		local circleSp=CCSprite:createWithSpriteFrameName("semicircleGreen.png")
	 		circleSp:setAnchorPoint(ccp(0.5,0))
	 		self.bgLayer:addChild(circleSp)
	 		circleSp:setRotation(180)
	 		circleSp:setPosition(G_VisibleSizeWidth/2,centerStartH+upH)
	 		circleSp:setScale(G_VisibleSizeWidth/circleSp:getContentSize().width)
 		end
 		G_addResource8888(add888)

 		local function nilFunc()
 		end
 		local upBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
		upBgSp:setAnchorPoint(ccp(0.5,0))
		upBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,upH-20))
		upBgSp:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,centerStartH+20)
		self.bgLayer:addChild(upBgSp)
		upBgSp:setOpacity(0)
		actionTb["upBgSp"]={{1,101},upBgSp,nil,nil,ccp(G_VisibleSizeWidth/2,centerStartH+20),dTime,0.5,nil}


		local nowPoint=ltzdzVoApi.clancrossinfo.rpoint or 0
		-- nowPoint=229

		local addPoint=endInfo.rp or 0 -- 本局增加或者减少的段位分
		-- addPoint=-1
 		local unit
 		if addPoint==0 then
 			unit=0
 		else
 			unit=addPoint/math.abs(addPoint)
 		end
 		local lastPoint=nowPoint-addPoint

 		local seg,smallLevel=ltzdzVoApi:getSegment(lastPoint)
 	
 		self:addSegIcon(seg,smallLevel,upBgSp)

 		
		local barName = "fleet_slot_bar_green.png"
		local barBgName = "fleet_slot_bar_bg.png"
		local timerSprite=AddProgramTimer(upBgSp,ccp(upBgSp:getContentSize().width/2,upBgSp:getContentSize().height/2-15),2,12,"",barBgName,barName,11,nil,nil,nil,nil,16,nil,nil)
		local scaleX=200/timerSprite:getContentSize().width
		local scaleY=30/timerSprite:getContentSize().height
		timerSprite:setScaleX(scaleX)
		timerSprite:setScaleY(scaleY)

		local timeBg=tolua.cast(upBgSp:getChildByTag(11),"CCSprite")
		if timeBg then
			timeBg:setScaleX(scaleX)
			timeBg:setScaleY(scaleY)
		end


		local lbPer = tolua.cast(timerSprite:getChildByTag(12),"CCLabelTTF")
		lbPer:setScaleX(1/scaleX)
		lbPer:setScaleY(1/scaleY)

		local segLb=GetTTFLabel(getlocal("ltzdz_seg_point",{addPoint}),22)
		timerSprite:addChild(segLb)
		segLb:setPosition(timerSprite:getContentSize().width/2,timerSprite:getContentSize().height+15)
		segLb:setScaleX(1/scaleX)

		
		

		-- print("lastPoint,nowPoint,unit",lastPoint,nowPoint,unit)
		local fullFlag1,limitNum=ltzdzVoApi:segIsFull(nowPoint)
		local fullFlag2=ltzdzVoApi:segIsFull(lastPoint)

		-- print("fullFlag1,fullFlag2",fullFlag1,fullFlag2)

		local function getMAdnD(lastP)
			local seg,smallLevel,totalSeg=ltzdzVoApi:getSegByLevel(lastP)
			local upLimit,downLimit=ltzdzVoApi:getNextSmallSeg(totalSeg)
			local molecular=lastP-downLimit -- 分子
			local Denominator=upLimit-downLimit -- 分母
			return molecular,Denominator
		end


		local function recurs(lastP,initialFlag)
			local fullFlag2,setLimitNum=ltzdzVoApi:segIsFull(lastP)
			if fullFlag2==true then -- 最高段位特殊处理
				timerSprite:setPercentage(100)
				-- if lastP>=nowPoint then
				-- 	lastP=nowPoint
				-- end
				-- print("lastP-setLimitNum",lastP,setLimitNum)
				lbPer:setString(lastP-setLimitNum)

				if lastP-setLimitNum==1 and addPoint>0 and (not initialFlag) then
					local function nextRecurs()
						recurs(lastP+unit)
					end
					local upgradeCallback
					if lastP~=nowPoint then
						upgradeCallback=nextRecurs
					end
					local seg,smallLevel=ltzdzVoApi:getSegment(lastP)
					if self.segIcon then
						self.segIcon:removeFromParentAndCleanup(true)
					end
					self:addSegIcon(seg,smallLevel,upBgSp)
					local lastSeg,lastSmallLv=ltzdzVoApi:getSegment(lastP-unit)
					-- print("lastSeg,lastSmallLv,seg,smallLevel",lastSeg,lastSmallLv,seg,smallLevel)
					ltzdzVoApi:showSegUpgradeSmallDialog(seg,smallLevel,upgradeCallback,self.layerNum+1,lastSeg,lastSmallLv)
					do return end
				end

				if lastP~=nowPoint then
					local function nextRecurs()
						recurs(lastP+unit)
	                end
	                local callFunc=CCCallFunc:create(nextRecurs)
	                local delay=CCDelayTime:create(0.05)
	                local acArr=CCArray:create()
	                acArr:addObject(delay)
	                acArr:addObject(callFunc)
	                local seq=CCSequence:create(acArr)
	                lbPer:runAction(seq)
				end
			else
				-- if lastP>=nowPoint then
				-- 	lastP=nowPoint
				-- end
				local molecular,Denominator=getMAdnD(lastP)
				local lbStr=molecular .. "/" .. Denominator
				lbPer:setString(lbStr)
				timerSprite:setPercentage(molecular/Denominator*100)

				if ((molecular==1 and unit>0) or (Denominator==molecular and unit<0)) and addPoint~=0 and (not initialFlag) then
					local function nextRecurs()
						recurs(lastP+unit)
					end
					local upgradeCallback
					if lastP~=nowPoint then
						upgradeCallback=nextRecurs
					end
					local seg,smallLevel=ltzdzVoApi:getSegment(lastP)


					if self.segIcon then
						self.segIcon:removeFromParentAndCleanup(true)
					end
					self:addSegIcon(seg,smallLevel,upBgSp)
					local lastSeg,lastSmallLv=ltzdzVoApi:getSegment(lastP-unit)
					-- print("lastSeg,lastSmallLv,seg,smallLevel",lastSeg,lastSmallLv,seg,smallLevel)
					ltzdzVoApi:showSegUpgradeSmallDialog(seg,smallLevel,upgradeCallback,self.layerNum+1,lastSeg,lastSmallLv)
					do return end
				end

				if lastP~=nowPoint then
					local function nextRecurs()
						recurs(lastP+unit)
	                end
	                local callFunc=CCCallFunc:create(nextRecurs)
	                local delay=CCDelayTime:create(0.05)
	                local acArr=CCArray:create()
	                acArr:addObject(delay)
	                acArr:addObject(callFunc)
	                local seq=CCSequence:create(acArr)
	                lbPer:runAction(seq)
				end
			end
		end

		-- if fullFlag1 and fullFlag2 then
		-- 	recurs(lastPoint,true)
		-- 	timerSprite:setPercentage(100)
		-- else
			recurs(lastPoint,true)
		-- end
		

 		local function noData( )  end
		local damageBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("lightGreenBg.png",CCRect(32,16,1,1),noData)
		damageBg1:setAnchorPoint(ccp(0.5,0.5))
		self.bgLayer:addChild(damageBg1,2)
		damageBg1:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,32))
		damageBg1:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,centerStartH)

		dTime=dTime+0.1
		actionTb["damageBg1"]={{1,101},damageBg1,nil,nil,ccp(G_VisibleSizeWidth/2,centerStartH),dTime,0.5,nil }

		local damageBgH=damageBg1:getContentSize().height
		local damageBgW=damageBg1:getContentSize().width

		local lbWidth=damageBgW-150

		local desLb1=GetTTFLabelWrap(getlocal("ltzdz_end_des1"),22,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb1:setAnchorPoint(ccp(0,0.5))
		damageBg1:addChild(desLb1)
		desLb1:setPosition(30,damageBgH/2)
		local scaleY1=(desLb1:getContentSize().height+10)/damageBgH
		damageBg1:setScaleY(scaleY1)
		desLb1:setScaleY(1/scaleY1)

		local desNumLb1=GetTTFLabel(FormatNumber(endInfo.k or 0),22)
		desNumLb1:setAnchorPoint(ccp(0,0.5))
		damageBg1:addChild(desNumLb1)
		desNumLb1:setPosition(damageBgW-100,damageBgH/2)
		desNumLb1:setScaleY(1/scaleY1)



		local damageBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("lightGreenBg.png",CCRect(32,16,1,1),noData)
		damageBg2:setAnchorPoint(ccp(0.5,0.5))
		self.bgLayer:addChild(damageBg2,2)
		damageBg2:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,32))
		damageBg2:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,centerStartH-centerSubH)
		dTime=dTime+0.1
		actionTb["damageBg2"]={{1,101},damageBg2,nil,nil,ccp(G_VisibleSizeWidth/2,centerStartH-centerSubH),dTime,0.5,nil }

		local desLb2=GetTTFLabelWrap(getlocal("ltzdz_end_des2"),22,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb2:setAnchorPoint(ccp(0,0.5))
		damageBg2:addChild(desLb2)
		desLb2:setPosition(30,damageBgH/2)
		local scaleY1=(desLb2:getContentSize().height+10)/damageBgH
		damageBg2:setScaleY(scaleY1)
		desLb2:setScaleY(1/scaleY1)

		local desNumLb2=GetTTFLabel(FormatNumber(endInfo.mc or 0),22)
		desNumLb2:setAnchorPoint(ccp(0,0.5))
		damageBg2:addChild(desNumLb2)
		desNumLb2:setPosition(damageBgW-100,damageBgH/2)
		desNumLb2:setScaleY(1/scaleY1)

		local damageBg3 = LuaCCScale9Sprite:createWithSpriteFrameName("lightGreenBg.png",CCRect(32,16,1,1),noData)
		damageBg3:setAnchorPoint(ccp(0.5,0.5))
		self.bgLayer:addChild(damageBg3,2)
		damageBg3:setContentSize(CCSizeMake(G_VisibleSizeWidth-100,32))
		damageBg3:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,centerStartH-centerSubH*2)
		dTime=dTime+0.1
		actionTb["damageBg3"]={{1,101},damageBg3,nil,nil,ccp(G_VisibleSizeWidth/2,centerStartH-centerSubH*2),dTime,0.5,nil }

		local desLb3=GetTTFLabelWrap(getlocal("ltzdz_end_des3"),22,CCSizeMake(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb3:setAnchorPoint(ccp(0,0.5))
		damageBg3:addChild(desLb3)
		desLb3:setPosition(30,damageBgH/2)
		local scaleY1=(desLb3:getContentSize().height+10)/damageBgH
		damageBg3:setScaleY(scaleY1)
		desLb3:setScaleY(1/scaleY1)

		local sbD=endInfo.d or {}
		local sbNum=SizeOfTable(sbD)
		local desNumLb3=GetTTFLabel(FormatNumber(sbNum or 0),22)
		desNumLb3:setAnchorPoint(ccp(0,0.5))
		damageBg3:addChild(desNumLb3)
		desNumLb3:setPosition(damageBgW-100,damageBgH/2)
		desNumLb3:setScaleY(1/scaleY1)

		-- 下
		local downStartH=centerStartH-centerSubH*3-50
		local titleTb={getlocal("ltzdz_end_des4"),25,G_ColorYellowPro}
		local titleLbSize=CCSizeMake(G_VisibleSizeWidth-200,0)
		local titleBg,titleLb=G_createNewTitle(titleTb,titleLbSize)
		self.bgLayer:addChild(titleBg)
		titleBg:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,downStartH)

		dTime=dTime+0.1
		actionTb["titleBg"]={{1,101},titleBg,nil,nil,ccp(G_VisibleSizeWidth/2,downStartH),dTime,0.5,nil }

		local function ninfunc()
		end

		local downLb1H=downStartH-60
		local downSp1 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),ninfunc)
		downSp1:setAnchorPoint(ccp(0.5,0))
		downSp1:setContentSize(CCSizeMake(G_VisibleSizeWidth,55))
		downSp1:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,downLb1H)
		self.bgLayer:addChild(downSp1)
		downSp1:setOpacity(0)
		dTime=dTime+0.1
		actionTb["downSp1"]={{1,101},downSp1,nil,nil,ccp(G_VisibleSizeWidth/2,downLb1H),dTime,0.5,nil }
		
		local desLb4=GetTTFLabelWrap(getlocal("ltzdz_end_des4"),22,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
		downSp1:addChild(desLb4)
		desLb4:setAnchorPoint(ccp(0,0))
		desLb4:setPosition(50,0)

		local icon1=CCSprite:createWithSpriteFrameName("ltzdzPointIcon.png")
		downSp1:addChild(icon1)
		icon1:setAnchorPoint(ccp(0,0))
		icon1:setPosition(G_VisibleSizeWidth-140,0)
		icon1:setScale(30/icon1:getContentSize().width)

		local addStr1=0
		if self.victory==true then
			addStr1=(endInfo.bp or 0)
		else
			addStr1=(endInfo.bp or 0)+(endInfo.p or 0)
		end
		local addNumLb1=GetTTFLabel("+" .. addStr1,22)
		addNumLb1:setColor(G_ColorGreen)
		downSp1:addChild(addNumLb1)
		addNumLb1:setAnchorPoint(ccp(0,0))
		addNumLb1:setPosition(G_VisibleSizeWidth-100,0)

		local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp1:setPosition(G_VisibleSizeWidth/2,downLb1H-5)
		self.bgLayer:addChild(lineSp1)

		-- 胜利才会有，平局和失败不会有，大菜说的
		if self.victory==true then
			local addDesStr=getlocal("ltzdz_end_des6")
			if endInfo and endInfo.a and endInfo.a[2] then -- 有盟友
				addDesStr=getlocal("ltzdz_end_des5")
			end

			local downLb2H=downLb1H-60

			local downSp2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),ninfunc)
			downSp2:setAnchorPoint(ccp(0.5,0))
			downSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth,55))
			downSp2:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,downLb2H)
			self.bgLayer:addChild(downSp2)
			downSp2:setOpacity(0)
			dTime=dTime+0.1
			actionTb["downSp2"]={{1,101},downSp2,nil,nil,ccp(G_VisibleSizeWidth/2,downLb2H),dTime,0.5,nil }

			local desLb5=GetTTFLabelWrap(addDesStr,22,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
			downSp2:addChild(desLb5)
			desLb5:setAnchorPoint(ccp(0,0))
			desLb5:setPosition(50,0)

			local icon2=CCSprite:createWithSpriteFrameName("ltzdzPointIcon.png")
			downSp2:addChild(icon2)
			icon2:setAnchorPoint(ccp(0,0))
			icon2:setPosition(G_VisibleSizeWidth-140,0)
			icon2:setScale(30/icon2:getContentSize().width)

			local addNumLb2=GetTTFLabel("+" .. (endInfo.p or 0),22)
			addNumLb2:setColor(G_ColorGreen)
			downSp2:addChild(addNumLb2)
			addNumLb2:setAnchorPoint(ccp(0,0))
			addNumLb2:setPosition(G_VisibleSizeWidth-100,0)

			local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
			lineSp2:setPosition(G_VisibleSizeWidth/2,downLb2H-5)
			self.bgLayer:addChild(lineSp2)

			-- local downLb3H=downLb2H-60
			-- local downSp3 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),ninfunc)
			-- downSp3:setAnchorPoint(ccp(0.5,0))
			-- downSp3:setContentSize(CCSizeMake(G_VisibleSizeWidth,55))
			-- downSp3:setPosition(G_VisibleSizeWidth/2+G_VisibleSizeWidth,downLb3H)
			-- self.bgLayer:addChild(downSp3)
			-- downSp3:setOpacity(0)

			-- dTime=dTime+0.1
			-- actionTb["downSp3"]={{1,101},downSp3,nil,nil,ccp(G_VisibleSizeWidth/2,downLb3H),dTime,0.5,nil }
			-- local desLb6=GetTTFLabelWrap(getlocal("ltzdz_end_des6"),22,CCSizeMake(G_VisibleSizeWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
			-- downSp3:addChild(desLb6)
			-- desLb6:setAnchorPoint(ccp(0,0))
			-- desLb6:setPosition(50,0)

			-- local icon3=CCSprite:createWithSpriteFrameName("IconGold.png")
			-- downSp3:addChild(icon3)
			-- icon3:setAnchorPoint(ccp(0,0))
			-- icon3:setPosition(G_VisibleSizeWidth-140,0)

			-- local addNumLb3=GetTTFLabel("+4",22)
			-- addNumLb3:setColor(G_ColorGreen)
			-- downSp3:addChild(addNumLb3)
			-- addNumLb3:setAnchorPoint(ccp(0,0))
			-- addNumLb3:setPosition(G_VisibleSizeWidth-100,0)

			-- local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
			-- lineSp3:setPosition(G_VisibleSizeWidth/2,downLb3H-5)
			-- self.bgLayer:addChild(lineSp3)
		end
		

		-- 按钮
		local btnH=60
		local function touchNewJourney()
	    	if G_checkClickEnable()==false then
			    do
			        return
			    end
			else
			    base.setWaitTime=G_getCurDeviceMillTime()
			end
			PlayEffect(audioCfg.mouseClick)
			if taskFunc then
				taskFunc()
			end
			self:close()
	    end
		local journeyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touchNewJourney,1,getlocal("ltzdz_new_journey"),25)
		journeyItem:setAnchorPoint(ccp(0.5,0.5))
		local journeyMenu=CCMenu:createWithItem(journeyItem)
		journeyMenu:setPosition(ccp(dialogSize.width/2+G_VisibleSizeWidth,btnH))
		journeyMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		self.bgLayer:addChild(journeyMenu,2)

		dTime=dTime+0.1
		actionTb["journeyMenu"]={{1,101},journeyMenu,nil,nil,ccp(dialogSize.width/2,btnH),dTime,0.5,nil }


		G_RunActionCombo(actionTb)
 	end

 	-- 上
 	local animyPosy
 	-- if(G_isIphone5()==false)then
 	-- 	animyPosy=G_VisibleSizeHeight-120
 	-- else
 		animyPosy=G_VisibleSizeHeight-160
 	-- end
 	local bgSrc2
	if self.victory then -- 上面的动画走完才可以初始化（策划要求的）
		G_battleWinAni(self.bgLayer,initCenterAndBottom,animyPosy)
		bgSrc2 = "WinnerBgSp.jpg"
	else
		G_battleLoseAni(self.bgLayer,initCenterAndBottom,animyPosy)
		bgSrc2 = "loserBgSp.jpg"
	end

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
	local dialogBg2 = CCSprite:create("public/"..bgSrc2)
	dialogBg2:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
	self.dialogLayer:addChild(dialogBg2)

	if G_getIphoneType() == G_iphoneX then
        dialogBg2:setScaleY(G_VisibleSizeHeight/dialogBg2:getContentSize().height)
    end

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(0,0)
    return self.dialogLayer
end

function ltzdzBattleEndSmallDialog:addNeedPlist()
    local function addPlist()
	    if self.victory then
	        spriteController:addPlist("public/winR_newImage170612.plist")
	        spriteController:addTexture("public/winR_newImage170612.png")
	    else
	        spriteController:addPlist("public/loseR_newImage170612.plist")
	        spriteController:addTexture("public/loseR_newImage170612.png")
	    end	    
	end
    G_addResource8888(addPlist)
end

function ltzdzBattleEndSmallDialog:addSegIcon(seg,smallLevel,upBgSp)
	local function touchSeg()
    end
	local segIcon=ltzdzVoApi:getSegIcon(seg,smallLevel,touchSeg)
	segIcon:setScale(0.5)
	upBgSp:addChild(segIcon)
	segIcon:setAnchorPoint(ccp(0,0.5))
	segIcon:setPosition(50,upBgSp:getContentSize().height/2)
	self.segIcon=segIcon
end



function ltzdzBattleEndSmallDialog:dispose()
	if self.victory then
        spriteController:removePlist("public/winR_newImage170612.plist")
        spriteController:removeTexture("public/winR_newImage170612.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/WinnerBgSp.jpg")
    else
        spriteController:removePlist("public/loseR_newImage170612.plist")
        spriteController:removeTexture("public/loseR_newImage170612.png")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/loserBgSp.jpg")
    end
    spriteController:removePlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegImages2.png")
	self.layerNum=nil
	self.istouch=nil
	self.isuseami=nil
end