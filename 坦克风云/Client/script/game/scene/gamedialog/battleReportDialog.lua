local battleReportDialog={} --战斗报告

function battleReportDialog:new(report,chatSender)
	local nc={
		report=report,
		baseShowType=nil,
		detailShowType=nil,
		cellHeightTb1=nil,
		cellHeightTb2=nil,
		tvTb=nil,
		chatSender=chatSender,
		resource=nil,
		troops=nil,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function battleReportDialog:initReportLayer(layerNum)
	if self.report==nil then
		do return end
	end
	self.isAttacker=emailVoApi:isAttacker(self.report,self.chatSender)
	self.islandType=self.report.islandType
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/reportyouhua.plist")
    spriteController:addTexture("public/reportyouhua.png")
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
  	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")

	if self.islandType==8 then
		spriteController:addPlist("scene/allianceCityImages.plist")
		spriteController:addTexture("scene/allianceCityImages.png")
	end

	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	self.baseLayer=CCLayer:create()
	self.detailLayer=CCLayer:create()

	self.baseLayer:setPosition(0,0)
	self.detailLayer:setPosition(G_VisibleSizeWidth,0)
	self.bgLayer:addChild(self.baseLayer,1)
	self.bgLayer:addChild(self.detailLayer,1)

	self:initShowType() --初始化战报显示元素类型
	self.baseNum=SizeOfTable(self.baseShowType)
	self.detailNum=0
	if self.detailShowType then
		self.detailNum=SizeOfTable(self.detailShowType)
	end
	--初始化战斗目标点信息
	local successFlag=false
	local resultBg,resultPic,targetStr,myInfo,enemyInfo,myLandform,enemyLandform,myNameStr,enemyNameStr	
	if self.isAttacker==true then
		if self.report.isVictory==1 then --我方胜利
			successFlag=true
		else --我方失败
			successFlag=false
		end
		if self.islandType<6 then
			targetStr=getlocal("battleReport_attack_type2",{G_getIslandName(self.islandType)})
		elseif self.islandType==6 then
			if self.report.defender then
				targetStr=getlocal("battleReport_attack_type1",{self.report.defender.name})
			end
		elseif self.islandType==7 then
			local rebelData=self.report.rebel or {}
			local rebelLv=rebelData.rebelLv or 1
			local rpic=rebelData.rpic or 1
			local rebelID=rebelData.rebelID or 1
			local nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,false,rpic)
			targetStr=getlocal("battleReport_attack_type4",{nameStr})
		elseif self.islandType==8 then
			local nameStr=G_getIslandName(self.islandType,self.report.defender.allianceName)
			targetStr=getlocal("battleReport_attack_type2",{nameStr})
		elseif self.islandType==9 then
			targetStr = getlocal("battleReport_attack_type2",{getlocal("airShip_worldTroops")})
		end
		myInfo,enemyInfo,myLandform,enemyLandform=self.report.attacker,self.report.defender,self.report.aLandform,self.report.dLandform
		myNameStr,enemyNameStr=myInfo.name,enemyInfo.name
		if self.report.helpDefender and self.report.helpDefender~="" then --敌方显示协防玩家的名称
			enemyNameStr=self.report.helpDefender
		end
	else
		if self.report.isVictory==1 then --我方失败
			successFlag=false
		else --我方胜利
			successFlag=true
		end
		if self.islandType<6 then
			targetStr=getlocal("battleReport_defend_type2",{G_getIslandName(self.islandType)})
		elseif self.islandType==6 then
			targetStr=getlocal("battleReport_defend_type1",{self.report.defender.name})
		elseif self.islandType==7 then
			local rebelData=self.report.rebel or {}
			local rebelLv=rebelData.rebelLv or 1
			local rpic=rebelData.rpic or 1
			local rebelID=rebelData.rebelID or 1
			local nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,false,rpic)
			targetStr=getlocal("battleReport_attack_type4",{nameStr})
		elseif self.islandType==8 then
			local nameStr=G_getIslandName(self.islandType,self.report.defender.allianceName)
			targetStr=getlocal("battleReport_defend_type2",{nameStr})
		elseif self.islandType==9 then
			targetStr = getlocal("battleReport_attack_type2",{getlocal("airShip_worldTroops")})
		end
		myInfo,enemyInfo,myLandform,enemyLandform=self.report.defender,self.report.attacker,self.report.dLandform,self.report.aLandform
		myNameStr,enemyNameStr=myInfo.name,enemyInfo.name
		if self.report.helpDefender and self.report.helpDefender~="" then --我方是协防玩家，显示协防玩家的名称
			myNameStr=self.report.helpDefender
		end
	end
	if successFlag==true then --我方胜利
		resultBg="reportSuccessBg.png"
		if G_getCurChoseLanguage()=="cn" then
			resultPic="reportSuccessIcon_cn.png"
		elseif G_getCurChoseLanguage()=="tw" then
			resultPic="reportSuccessIcon_tw.png"
		else
			resultPic="reportSuccessIcon_en.png"
		end
	else --我方失败
		resultBg="reportFailBg.png"
		if G_getCurChoseLanguage()=="cn" then
			resultPic="reportFailIcon_cn.png"
		elseif G_getCurChoseLanguage()=="tw" then
			resultPic="reportFailIcon_tw.png"
		else
			resultPic="reportFailIcon_en.png"
		end
	end

	local infoBgSize=CCSizeMake(640,116)
	local infoBg=CCSprite:createWithSpriteFrameName(resultBg)
	infoBg:setAnchorPoint(ccp(0.5,1))
	infoBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
	self.bgLayer:addChild(infoBg)

	--战斗结果
	if resultPic then
		local resultSp=CCSprite:createWithSpriteFrameName(resultPic)
		resultSp:setAnchorPoint(ccp(0,0.5))
		resultSp:setPosition(50,infoBgSize.height/2)
		infoBg:addChild(resultSp)
	end
	local fontSize=22
	if G_isAsia() == false then
		fontSize = 15
	end
	if targetStr then
		--战斗地点
		local targetLb=GetTTFLabelWrap(targetStr,fontSize,CCSizeMake(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
		targetLb:setAnchorPoint(ccp(1,1))
		targetLb:setColor(G_ColorYellowPro)
		targetLb:setPosition(infoBgSize.width-20,infoBgSize.height/2+targetLb:getContentSize().height+30)
		infoBg:addChild(targetLb)
		--战斗地点坐标
		if self.report.place then
			local menu,menuItem,placeLb
			-- defender显示进攻方基地坐标,不显示发生战斗的地方
			if self.isAttacker == false and self.islandType == 6 and self.report.attackerPlace then
				menu,menuItem,placeLb=G_createReportPositionLabel(ccp(self.report.attackerPlace.x,self.report.attackerPlace.y),fontSize,nil,nil,G_ColorRed)
			else
				menu,menuItem,placeLb=G_createReportPositionLabel(ccp(self.report.place.x,self.report.place.y),fontSize)
			end
			
			-- local placeLb=GetTTFLabel(getlocal("city_info_coordinate_style",{self.report.place.x,self.report.place.y}),fontSize)
			menu:setAnchorPoint(ccp(1,0.5))
			menuItem:setAnchorPoint(ccp(1,0.5))
			menu:setPosition(targetLb:getPositionX(),infoBgSize.height/2)
			infoBg:addChild(menu)
		end
		--战斗时间
		if self.report and self.report.time then
			local timeLb=GetTTFLabel(emailVoApi:getTimeStr(self.report.time),fontSize)
			timeLb:setAnchorPoint(ccp(1,1))
			timeLb:setPosition(targetLb:getPositionX(),infoBgSize.height/2-30)
			infoBg:addChild(timeLb)
		end
	end
	--我方信息
	local iconWidth,infoWidth,infoHeight=90,630/2-1,110
	local myInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportBlueBg.png",CCRect(4, 4, 1, 1),function ()end)
    myInfoBg:setAnchorPoint(ccp(0.5,1))
    myInfoBg:setContentSize(CCSizeMake(infoWidth,infoHeight))
    myInfoBg:setPosition(5+infoWidth/2,infoBg:getPositionY()-infoBgSize.height)
    self.bgLayer:addChild(myInfoBg)
    if myInfo then
    	local fight,pic,fhid=(myInfo.fight or 0),(myInfo.pic or headCfg.default),(myInfo.fhid or headFrameCfg.default)
    	local function showMyInfo()
    		if myInfo.fight then
    			local player={uid=myInfo.id,name=myNameStr,level=myInfo.level,pic=pic,fhid=fhid,vip=myInfo.vip,rank=myInfo.rank,fight=myInfo.fight,alliance=myInfo.allianceName}
    			smallDialog:showReportPlayerInfoSmallDialog(player,self.layerNum+1,true,nil,false)
    		end
    	end
    	local picName=playerVoApi:getPersonPhotoName(pic)
    	-- print("pic,picName----???",pic,picName)
    	local myIconSp=playerVoApi:GetPlayerBgIcon(picName,showMyInfo,nil,nil,iconWidth,fhid)
    	myIconSp:setPosition(2+iconWidth/2,infoHeight/2)
    	myIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
    	myInfoBg:addChild(myIconSp)
       	local lvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
        lvBg:setRotation(180)
        lvBg:setContentSize(CCSizeMake(50,20))
        lvBg:setPosition(myIconSp:getPositionX()+iconWidth/2-lvBg:getContentSize().width/2-6,myIconSp:getPositionY()-iconWidth/2+lvBg:getContentSize().height/2+2)
        myInfoBg:addChild(lvBg)
    	local lvLb=GetTTFLabel(getlocal("fightLevel",{myInfo.level}),fontSize-4)
        lvLb:setAnchorPoint(ccp(1,0.5))
        lvLb:setPosition(lvBg:getPositionX()+lvBg:getContentSize().width/2-5,lvBg:getPositionY())
    	myInfoBg:addChild(lvLb,2)
		local nameLb=GetTTFLabelWrap(myNameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(myIconSp:getPositionX()+5+iconWidth/2,myIconSp:getPositionY()+iconWidth/2)
		myInfoBg:addChild(nameLb)
		local allianceName="["..getlocal("noAlliance").."]"
		if myInfo.allianceName and myInfo.allianceName~="" then
			allianceName=myInfo.allianceName
		else
			if self.islandType==7 then --如果攻打的是叛军，但没有军团数据的话，不显示军团
				allianceName=""
			end
		end
		local allianceLb=GetTTFLabelWrap(allianceName,fontSize-4,CCSizeMake(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		allianceLb:setAnchorPoint(ccp(0,0.5))
		allianceLb:setPosition(nameLb:getPositionX(),infoHeight/2)
		myInfoBg:addChild(allianceLb)

		if fight>0 then
			local fightSp=CCSprite:createWithSpriteFrameName("picked_icon2.png")
			fightSp:setAnchorPoint(ccp(0,0.5))
			fightSp:setScale(0.5)
	    	local fightLb=GetTTFLabel(FormatNumber(fight),fontSize-4) --战斗力
	        fightLb:setAnchorPoint(ccp(0,0.5))
	        fightLb:setPosition(nameLb:getPositionX()+fightSp:getContentSize().width*0.5+10,10+fightLb:getContentSize().height/2)
	    	myInfoBg:addChild(fightLb)
			fightSp:setPosition(nameLb:getPositionX(),fightLb:getPositionY())
			myInfoBg:addChild(fightSp)
		end
    	local landformSp=CCSprite:createWithSpriteFrameName("world_ground_"..myLandform..".png")
    	landformSp:setPosition(infoWidth-landformSp:getContentSize().width/2-10,infoHeight/2)
		landformSp:setScale(0.8)
    	myInfoBg:addChild(landformSp)

       	local campBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg.png",CCRect(30,0,2,24),function ()end)
        campBg:setContentSize(CCSizeMake(100,24))
        campBg:setPosition(infoWidth-campBg:getContentSize().width/2,campBg:getContentSize().height/2)
        campBg:setOpacity(255*0.1)
        myInfoBg:addChild(campBg)
        local campStr,campStrColor=""
        if self.isAttacker==true then
        	campStr=getlocal("battleCamp1")
        	campStrColor=G_LowfiColorGreen
        else
        	campStr=getlocal("battleCamp2")
        	campStrColor=G_LowfiColorRed
        end
    	local campLb=GetTTFLabel(campStr,fontSize)
        campLb:setPosition(campBg:getContentSize().width/2+10,campBg:getContentSize().height/2)
        campLb:setColor(campStrColor)
    	campBg:addChild(campLb)
    end
    
	local enemyInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportRedBg.png",CCRect(4, 4, 1, 1),function ()end)
    enemyInfoBg:setAnchorPoint(ccp(0.5,1))
    enemyInfoBg:setContentSize(CCSizeMake(infoWidth,infoHeight))
    enemyInfoBg:setPosition(G_VisibleSizeWidth-infoWidth/2-5,infoBg:getPositionY()-infoBgSize.height)
    self.bgLayer:addChild(enemyInfoBg)
    local enemyIconSp,enemyLv,nameStr
  	local rpx,rpy=infoWidth-iconWidth/2-2,infoHeight/2
	local rightPosX=rpx-iconWidth/2-5
    if self.islandType<6 and (self.report.islandOwner==nil or self.report.islandOwner==0) then --攻打无人占领的矿点
		local resStr=worldBaseVoApi:getBaseResource(self.islandType)
        enemyIconSp=LuaCCSprite:createWithSpriteFrameName("icon_bg_gray.png",function () end)
    	enemyIconSp:setScale(iconWidth/enemyIconSp:getContentSize().width)
    	local mineSp=LuaCCSprite:createWithSpriteFrameName(resStr,function () end)
    	mineSp:setPosition(getCenterPoint(enemyIconSp))
    	mineSp:setScale(enemyIconSp:getContentSize().width/mineSp:getContentSize().width)
    	enemyIconSp:addChild(mineSp)

    	enemyLv=self.report.level
		nameStr=G_getIslandName(self.islandType)
		local mineStateStr,stateColor,disappearTimeStr
		local mineStateStr2
		if base.wl==1 and base.goldmine==1 and self.report.goldMineLv and self.report.goldMineLv>0 then --金矿
			mineStateStr,stateColor,disappearTimeStr=getlocal("goldmine"),G_ColorYellowPro,G_getDataTimeStr(self.report.disappearTime)..getlocal("time_disappear")
		elseif base.richMineOpen==1 and base.landFormOpen==1 and self.report.richLevel and self.report.richLevel>0 then
			mineStateStr,stateColor=getlocal("richmine"),worldBaseVoApi:getRichMineColorByLv(self.report.richLevel)
		else
			mineStateStr,stateColor=getlocal("custom_mine"),G_ColorWhite
		end
		if self.report.privateMine then
			mineStateStr2 = getlocal("privateMineName")
		end

		if disappearTimeStr then
			local disappearLb=GetTTFLabelWrap(disappearTimeStr,fontSize-4,CCSizeMake(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
			disappearLb:setAnchorPoint(ccp(1,0.5))
			disappearLb:setPosition(rightPosX,infoHeight/2)
			enemyInfoBg:addChild(disappearLb)
		end
		if mineStateStr then
			local mineStateLb=GetTTFLabelWrap(mineStateStr,fontSize-4,CCSizeMake(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
			mineStateLb:setAnchorPoint(ccp(1,0.5))
			mineStateLb:setPosition(rightPosX,10+mineStateLb:getContentSize().height/2)
			mineStateLb:setColor(stateColor)
			enemyInfoBg:addChild(mineStateLb)
		end
		if mineStateStr2 then
			local mineStateLb2=GetTTFLabelWrap(mineStateStr2,fontSize-4,CCSizeMake(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
			mineStateLb2:setAnchorPoint(ccp(1,0.5))
			mineStateLb2:setPosition(rightPosX,10+mineStateLb2:getContentSize().height * 2)
			enemyInfoBg:addChild(mineStateLb2)
		end
	elseif self.islandType==6 or self.islandType==8 or (self.islandType<6 and self.report.islandOwner and self.report.islandOwner>0) then --攻打 玩家、有人占领的矿点、协防玩家、有人驻防的军团城市的话显示被攻打玩家信息
		local fight,pic,fhid=(enemyInfo.fight or 0),(enemyInfo.pic or headCfg.default),(enemyInfo.fhid or headFrameCfg.default)
    	local function showMyInfo()
    		if enemyInfo.fight then
    			local player={uid=enemyInfo.id,name=enemyNameStr,level=enemyInfo.level,pic=pic,fhid=fhid,vip=enemyInfo.vip,rank=enemyInfo.rank,fight=enemyInfo.fight,alliance=enemyInfo.allianceName}
    			smallDialog:showReportPlayerInfoSmallDialog(player,self.layerNum+1,true,nil,false)
    		end
    	end
		local picName=playerVoApi:getPersonPhotoName(pic)
    	enemyIconSp=playerVoApi:GetPlayerBgIcon(picName,showMyInfo,nil,nil,iconWidth,fhid)
    	enemyIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
    	enemyLv=enemyInfo.level
    	nameStr=enemyNameStr

		local allianceName="["..getlocal("noAlliance").."]"
		if enemyInfo.allianceName and enemyInfo.allianceName~="" then
			allianceName=enemyInfo.allianceName
		end
		local allianceLb=GetTTFLabelWrap(allianceName,fontSize-4,CCSizeMake(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
		allianceLb:setAnchorPoint(ccp(1,0.5))
		allianceLb:setPosition(rightPosX,infoHeight/2)
		enemyInfoBg:addChild(allianceLb)
		if fight>0 then
			local fightLb=GetTTFLabel(FormatNumber(fight),fontSize-4)
	        fightLb:setAnchorPoint(ccp(1,0.5))
	        fightLb:setPosition(rightPosX,10+fightLb:getContentSize().height/2)
	    	enemyInfoBg:addChild(fightLb)
			local fightSp=CCSprite:createWithSpriteFrameName("picked_icon2.png")
			fightSp:setAnchorPoint(ccp(1,0.5))
			fightSp:setScale(0.5)
			fightSp:setPosition(fightLb:getPositionX()-fightLb:getContentSize().width,fightLb:getPositionY())
			enemyInfoBg:addChild(fightSp)
		end
	elseif self.islandType==7 then --攻打叛军
		local rebelData=self.report.rebel or {}
		local pic=rebelData.pic or 1
		local rebelLv=rebelData.rebelLv or 1
		local rebelID=rebelData.rebelID or 1
		local rebelTotalLife=rebelData.rebelTotalLife or 0
		local rebelLeftLife=rebelData.rebelLeftLife or 0
		local reduceLife=rebelData.reduceLife or 0
		local tankId=rebelVoApi:getRebelIconTank(rebelLv,rebelID)
		local rpic=rebelData.rpic or 1

	    if tankId then
	    	local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
	    	if rpic and rpic>=100 then
	    		local picName=rebelVoApi:getSpecialRebelPic(rpic)
	    		if picName then
	    			enemyIconSp=CCSprite:createWithSpriteFrameName(picName)
	    		end
	    	end
	    	if enemyIconSp==nil then
	        	enemyIconSp=tankVoApi:getTankIconSp(tid,nil,nil,false)--CCSprite:createWithSpriteFrameName(tankCfg[tid].icon)
	    	end
	    	if enemyIconSp then
			    enemyIconSp:setScale(iconWidth/enemyIconSp:getContentSize().width)

		    	enemyLv=rebelLv
		    	nameStr=rebelVoApi:getRebelName(rebelLv,rebelID,false,rpic)

			    local scalex=0.4
			    local leftPer=(rebelLeftLife/rebelTotalLife)*100
		        local scheduleStr=""
		        if leftPer>0 and leftPer<1 then
		            scheduleStr="1%"
		        else
		        	scheduleStr=G_keepNumber(leftPer,0).."%"
		        end
			    AddProgramTimer(enemyInfoBg,ccp(rightPosX-286*scalex*0.5-5,infoHeight/2),11,12,scheduleStr,"rebelProgressBg.png","rebelProgress.png",13,scalex,1,nil,nil,18)
		        local per=(rebelLeftLife/rebelTotalLife)*100
		        local timerSpriteLv=enemyInfoBg:getChildByTag(11)
		        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
		        timerSpriteLv:setPercentage(per)
		        local lb=tolua.cast(timerSpriteLv:getChildByTag(12),"CCLabelTTF")
		        lb:setScaleX(1/scalex)
		        local reducePer=(reduceLife/rebelTotalLife)*100
		        reducePer=string.format("%.2f", reducePer)
		        local perLb=GetTTFLabel("-"..reducePer.."%",fontSize)
		        perLb:setAnchorPoint(ccp(1,0.5))
			    perLb:setPosition(rightPosX,10+perLb:getContentSize().height/2)
			    perLb:setColor(G_LowfiColorRed)
				enemyInfoBg:addChild(perLb)
	    	end
	    end
	-- elseif self.islandType==8 then --攻打军团城市
	    -- enemyIconSp=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	    -- enemyIconSp:setContentSize(CCSizeMake(iconWidth,iconWidth))
	    -- local citySp=allianceCityVoApi:getAllianceCityIcon()
	    -- citySp:setPosition(getCenterPoint(enemyIconSp))
	    -- citySp:setScale((iconWidth+10)/citySp:getContentSize().width)
	    -- enemyIconSp:addChild(citySp)

	    -- -- enemyLv=
	    -- nameStr=G_getIslandName(self.islandType,self.report.attacker.allianceName)
	elseif self.islandType == 9 then --攻打欧米伽小队(飞艇boss)
		local shipboss = self.report.shipboss
		if shipboss and shipboss.bType then
			enemyIconSp = CCSprite:createWithSpriteFrameName(airShipVoApi:getBossIconPic(shipboss.bType))
			nameStr = getlocal("airShip_bossNameType" .. shipboss.bType)
			local reduceLife = FormatNumber(tonumber(shipboss.reduceLife) or 0)
			if shipboss.attNum > 1 then
				reduceLife = reduceLife .. "x" .. shipboss.attNum
			end
			local reduceLb=GetTTFLabel("-" .. reduceLife, fontSize)
	        reduceLb:setAnchorPoint(ccp(1,0.5))
		    reduceLb:setPosition(rightPosX,10+reduceLb:getContentSize().height/2)
		    reduceLb:setColor(G_LowfiColorRed)
			enemyInfoBg:addChild(reduceLb)
		end
    end
    if enemyIconSp then
      	local rpx,rpy=infoWidth-iconWidth/2-2,infoHeight/2	
		enemyIconSp:setPosition(rpx,rpy)
	    enemyInfoBg:addChild(enemyIconSp)
        if enemyLv then
	    	local lvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
	    	lvBg:setRotation(180)
		    lvBg:setContentSize(CCSizeMake(50,20))
		    lvBg:setPosition(enemyIconSp:getPositionX()+iconWidth/2-lvBg:getContentSize().width/2-6,enemyIconSp:getPositionY()-iconWidth/2+lvBg:getContentSize().height/2+2)
		    lvBg:setOpacity(150)
		    enemyInfoBg:addChild(lvBg)
			local lvLb=GetTTFLabel(getlocal("fightLevel",{enemyLv}),fontSize-4)
		    lvLb:setAnchorPoint(ccp(1,0.5))
		    lvLb:setPosition(lvBg:getPositionX()+lvBg:getContentSize().width/2-5,lvBg:getPositionY())
			enemyInfoBg:addChild(lvLb)
	    end
	   	if nameStr then
	   		local nameLb=GetTTFLabelWrap(nameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
			nameLb:setAnchorPoint(ccp(1,1))
			nameLb:setPosition(rightPosX,enemyIconSp:getPositionY()+iconWidth/2)
			enemyInfoBg:addChild(nameLb)
	   	end
    end

    local landformSp=CCSprite:createWithSpriteFrameName("world_ground_"..enemyLandform..".png")
	landformSp:setPosition(landformSp:getContentSize().width/2+10,infoHeight/2)
	landformSp:setScale(0.8)
	enemyInfoBg:addChild(landformSp)
   	local enemyCampBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg2.png",CCRect(0,0,2,24),function ()end)
    enemyCampBg:setContentSize(CCSizeMake(100,24))
    enemyCampBg:setPosition(enemyCampBg:getContentSize().width/2,enemyCampBg:getContentSize().height/2)
    enemyCampBg:setOpacity(255*0.1)
    enemyInfoBg:addChild(enemyCampBg)
    local campStr,campStrColor=""
    if self.isAttacker==true then
    	campStr=getlocal("battleCamp2")
    	campStrColor=G_LowfiColorRed
    else
    	campStr=getlocal("battleCamp1")
    	campStrColor=G_LowfiColorGreen
    end
	local enemyCampLb=GetTTFLabel(campStr,fontSize)
    enemyCampLb:setPosition(enemyCampBg:getContentSize().width/2-10,enemyCampBg:getContentSize().height/2)
    enemyCampLb:setColor(campStrColor)
	enemyInfoBg:addChild(enemyCampLb)

	local arrowSp=CCSprite:createWithSpriteFrameName("reportLandformArrow.png")
	arrowSp:setPosition(G_VisibleSizeWidth/2,myInfoBg:getPositionY()-myInfoBg:getContentSize().height/2)
	if self.isAttacker==false then
		arrowSp:setFlipX(true)
	end
	self.bgLayer:addChild(arrowSp,3)

	local function showLandfromInfo()
	  	--显示战报地形信息
		--_aIslandID,_dIslandID: 攻/守方地形ID
		G_showReportIslandInfo(self.layerNum+1,self.report.aLandform,self.report.dLandform)
	end
	local landformTouchSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),showLandfromInfo)
    landformTouchSp:setContentSize(CCSizeMake(140,60))
    landformTouchSp:setPosition(arrowSp:getPosition())
    landformTouchSp:setTouchPriority(-(self.layerNum-1)*20-4)
    landformTouchSp:setOpacity(0)
    self.bgLayer:addChild(landformTouchSp,3)

	self.tvTb={}
	self.tvWidth,self.tvHeight=630,G_VisibleSizeHeight-450
	if self.detailNum==0 then
		self.tvHeight=self.tvHeight+30
	end
	local shareFlag=false --是否显示首次分享得金币
	if self.isAttacker==true then
		if self.report.isVictory==1 and self.chatSender==nil and self.report.islandType==6 then
			if G_isShowShareBtn() and G_isKakao()==false then
				shareFlag=true
			end
		end
	else
		if self.report.isVictory~=1 and self.chatSender==nil then
			if G_isShowShareBtn() and G_isKakao()==false then
				shareFlag=true
			end
		end
	end
	if shareFlag==true then
		local feedDescLb=GetTTFLabelWrap(getlocal("feedDesc"),18,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        feedDescLb:setPosition(G_VisibleSizeWidth/2,80+feedDescLb:getContentSize().height/2)
		self.bgLayer:addChild(feedDescLb,3)
		self.tvHeight=self.tvHeight-feedDescLb:getContentSize().height-10
	end

	for i=1,2 do
		local function callBack(...)
			if i==1 then
				return self:battleReportEventHandler1(...)
			else
				return self:battleReportEventHandler2(...)
			end
	    end
	    local hd=LuaEventHandler:createHandler(callBack)
		local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
		tv:setAnchorPoint(ccp(0,0))
	    tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,myInfoBg:getPositionY()-myInfoBg:getContentSize().height-self.tvHeight)
		tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		if i==1 then
			self.baseLayer:addChild(tv)
		else
			self.detailLayer:addChild(tv)
		end
		self.tvTb[i]=tv
	end

	--显示实力对比
	if self.detailShowType and self.detailNum>0 then
		self.showIdx=1
		local tv=tolua.cast(self.tvTb[1],"LuaCCTableView")
		local function showDetail()
			if self.detailBtn then
				local function realShow()
					local detailLb=tolua.cast(self.detailBtn:getChildByTag(101),"CCLabelTTF")
					local moveDis=0
					if self.showIdx==1 then
						self.showIdx=2
						detailLb:setString(getlocal("checkReportBaseInfoStr"))
						moveDis=-G_VisibleSizeWidth
					else
						self.showIdx=1
						detailLb:setString(getlocal("checkReportDetailStr"))
						moveDis=G_VisibleSizeWidth
					end
					local infoTv=tolua.cast(self.tvTb[self.showIdx],"LuaCCTableView")
					if infoTv then
						infoTv:reloadData()
					end
					self.moving=true
					for i=1,2 do
						local moveBy=CCMoveBy:create(0.5,ccp(moveDis,0))
						local function moveEnd()
							self.moving=false
						end
						if i==1 then
							self.baseLayer:runAction(CCSequence:createWithTwoActions(moveBy,CCCallFunc:create(moveEnd)))
						else
							self.detailLayer:runAction(moveBy)
						end
					end
				end
				
        		G_touchedItem(self.detailBtn,realShow,0.9)
			end
		end
		local detailBtn=LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png",showDetail)
		detailBtn:setPosition(G_VisibleSizeWidth/2,tv:getPositionY()-detailBtn:getContentSize().height/2)
		detailBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(detailBtn,5)
		self.detailBtn=detailBtn
		for i=1,2 do
			local arrowSp=CCSprite:createWithSpriteFrameName("reportArrow.png")
			if i==1 then
				arrowSp:setPosition(150,detailBtn:getContentSize().height/2)
			else
				arrowSp:setPosition(detailBtn:getContentSize().width-150,detailBtn:getContentSize().height/2)
				arrowSp:setRotation(180)
			end
			detailBtn:addChild(arrowSp)
		end
		local detailLb=GetTTFLabelWrap(getlocal("checkReportDetailStr"),22,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		detailLb:setPosition(getCenterPoint(detailBtn))
		detailLb:setTag(101)
		detailBtn:addChild(detailLb)
	else
		local tv=tolua.cast(self.tvTb[1],"LuaCCTableView")
		if tv then
			local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
			mLine:setPosition(ccp(G_VisibleSizeWidth/2,tv:getPositionY()-mLine:getContentSize().height/2))
			mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth-10,mLine:getContentSize().height))
			self.bgLayer:addChild(mLine)
		end
	end

	return self.bgLayer
end

--战斗报告基础战事信息的处理
function battleReportDialog:battleReportEventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.baseNum	
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self:getReportCellHeight1(idx+1))
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth,cellHeight=self.tvWidth,self:getReportCellHeight1(idx+1)
        local showType=self.baseShowType[idx+1]
        if showType==1 then --资源信息
            local resourceTb=self:getReportResource()
            G_reportResourceLayout(cell,cellWidth,cellHeight,resourceTb,getlocal("fight_award"),self.layerNum,self.report,self.isAttacker)
    	elseif showType==2 then --繁荣度信息
    		if self.report and self.report.report and self.report.report.bm then
				G_getReportGloryLayout(cell,cellWidth,cellHeight,self.report.report.bm,self.isAttacker,self.layerNum,idx~=1)
    		end
		elseif showType==3 then --部队损耗信息
			local troops=self:getReportTroopsLost()
			G_getBattleReportTroopsLayout(cell,cellWidth,cellHeight,troops,self.layerNum,self.report,self.isAttacker,idx~=1)
		elseif showType==10 then --攻打叛军时的战斗信息
			local titleBg=G_createReportTitle(cellWidth-20,getlocal("fight_content_fight_info"),idx~=1)
			titleBg:setAnchorPoint(ccp(0.5,1))
			titleBg:setPosition(cellWidth/2,cellHeight-5)
			cell:addChild(titleBg,2)
			local fontSize,fontWidth=20,self.tvWidth-60
			local rebelData=self.report.rebel or {}
			local multiNum=rebelData.multiNum or 0
			local attNum=rebelData.attNum or 0
			local posY=cellHeight-32-15
			if multiNum and multiNum>1 then
				local numStr=getlocal("email_report_rebel_multiple_num",{multiNum})
				local colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite}
				local numLb,lbHeight=G_getRichTextLabel(numStr,colorTab,fontSize,fontWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                numLb:setAnchorPoint(ccp(0.5,1))
                numLb:setPosition(cellWidth/2,posY)
                cell:addChild(numLb,1)
                posY=posY-lbHeight-10
            end
			if attNum and attNum>0 then
	            local attNumStr=getlocal("email_report_rebel_attack_num",{attNum})
				local colorTab={G_ColorWhite,G_ColorGreen,G_ColorWhite}
				local attNumLb,lbHeight=G_getRichTextLabel(attNumStr,colorTab,fontSize,fontWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                attNumLb:setAnchorPoint(ccp(0.5,1))
                attNumLb:setPosition(cellWidth/2,posY)
                cell:addChild(attNumLb,1)
            	posY=posY-lbHeight-10

            	local buff=rebelCfg.attackBuff*100*attNum
            	local buffLb=GetTTFLabel(getlocal("worldRebel_comboBuff",{buff.."%%"}),fontSize)
            	buffLb:setAnchorPoint(ccp(0.5,1))
			    buffLb:setPosition(cellWidth/2,posY)
			    buffLb:setColor(G_ColorGreen)
				cell:addChild(buffLb,1)
			end
        end

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

--战斗报告实力对比信息的处理
function battleReportDialog:battleReportEventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.detailNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self:getReportCellHeight2(idx+1))
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

		local cellWidth,cellHeight=self.tvWidth,self:getReportCellHeight2(idx+1)
        local showType=self.detailShowType[idx+1]
        if showType==4 then --装甲矩阵
        	G_getReportArmorMatrixLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,self.isAttacker)
    	elseif showType==5 then --配件
        	G_getReportAccessoryLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,self.isAttacker)
    	elseif showType==6 then --将领
			G_getReportHeroLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,self.isAttacker)
    	elseif showType==7 then --超级武器
			G_getReportSuperWeaponLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,self.isAttacker)
    	elseif showType==8 then --军徽
			G_getReportEmblemLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,self.isAttacker)
    	elseif showType==9 then --飞机
			G_getReportPlaneLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,self.isAttacker)
		elseif showType==11 then --AI部队
			G_getBattleReportAITroopsLayout(cell,cellWidth,cellHeight,(self.report.aitroops or {}),self.layerNum,self.report,self.isAttacker)
		elseif showType==12 then --飞艇
			G_getReportAirShipLayout(cell,cellWidth,cellHeight,self.report,self.isAttacker)
    	end

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

--战斗报告每个显示元素的高度
function battleReportDialog:getReportCellHeight1(idx)
	if self.cellHeightTb1==nil then
		self.cellHeightTb1={}
	end
	if self.cellHeightTb1[idx]==nil then
		local height=0
		local showType=self.baseShowType[idx]
		if showType==1 then --战斗资源相关
			local resource=self:getReportResource()
			height=G_reportResourceCellHeight(resource)
		elseif showType==2 then --繁荣度信息
			height=G_getReportGloryHeight()
		elseif showType==3 then --战斗部队损耗
			height=G_getBattleReportTroopsHeight(self.report)
		elseif showType==10 then --攻打叛军时的战斗信息
			height=32
			local fontSize,fontWidth=20,self.tvWidth-60
			local rebelData=self.report.rebel or {}
			local multiNum=rebelData.multiNum or 0
			local attNum=rebelData.attNum or 0
			if multiNum and multiNum>1 then
				local numStr=getlocal("email_report_rebel_multiple_num",{multiNum})
				local numLb,lbHeight=G_getRichTextLabel(numStr,{},fontSize,fontWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				height=height+lbHeight+15
				if attNum==nil or attNum==0 then
					height=height+10
				end
            end
			if attNum and attNum>0 then
            	local buff=rebelCfg.attackBuff*100*attNum
            	local buffLb=GetTTFLabel(getlocal("worldRebel_comboBuff",{buff.."%%"}),fontSize)	
	            local attNumStr=getlocal("email_report_rebel_attack_num",{attNum})
				local attNumLb,lbHeight=G_getRichTextLabel(attNumStr,{},fontSize,fontWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				height=height+buffLb:getContentSize().height+lbHeight+30
			end
		end
		self.cellHeightTb1[idx]=height
	end
	return self.cellHeightTb1[idx]
end

--战斗报告每个显示元素的高度
function battleReportDialog:getReportCellHeight2(idx)
	if self.cellHeightTb2==nil then
		self.cellHeightTb2={}
	end
	if self.cellHeightTb2[idx]==nil then
		local height=0
		local showType=self.detailShowType[idx]
		-- print("showType----???",showType)
		if showType==4 then --装甲矩阵
			height=G_getReportArmorMatrixHeight()
    	elseif showType==5 then --配件
			height=G_getReportAccessoryHeight()
    	elseif showType==6 then --将领
    		height=G_getReportHeroLayoutHeight()
    	elseif showType==7 then --超级武器
			height=G_getReportSuperWeaponLayoutHeight()
    	elseif showType==8 then --军徽
			height=G_getReportEmblemLayoutHeight()
    	elseif showType==9 then --飞机
			height=G_getReportPlaneLayoutHeight()
		elseif showType==11 then --AI部队
			height=G_getBattleReportAITroopsHeight()
		elseif showType==12 then --飞艇
			height=G_getReportAirShipLayoutHeight()
		end
		self.cellHeightTb2[idx]=height
	end
	return self.cellHeightTb2[idx]
end

--战斗资源相关
function battleReportDialog:getReportResource()
	if self.resource==nil then
		self.resource=G_getReportResource(self.report)
	end
	return self.resource
end

--战斗损耗部队详情
function battleReportDialog:getReportTroopsLost()
	if self.troops then
		do return self.troops end
	end
	if self.report.troops then --新的战报部队数据格式
		if self.isAttacker==true then
			self.troops=self.report.troops
		else
			self.troops={self.report.troops[2],self.report.troops[1]}
		end
	else
		local attTotal,attLost,defTotal,defLost --部队损失情况
		if self.report.lostShip.attackerLost then
			if self.report.lostShip.attackerLost.o then
				attLost=FormatItem(self.report.lostShip.attackerLost,false)
			else
				attLost=self.report.lostShip.attackerLost
			end
		end

		if self.report.lostShip.defenderLost then
			if self.report.lostShip.defenderLost.o then
				defLost=FormatItem(self.report.lostShip.defenderLost,false)
			else
				defLost=self.report.lostShip.defenderLost
			end
		end

		if self.report.lostShip.attackerTotal then
			if self.report.lostShip.attackerTotal.o then
				attTotal=FormatItem(self.report.lostShip.attackerTotal,false)
			else
				attTotal=self.report.lostShip.attackerTotal
			end
		end
		if self.report.lostShip.defenderTotal then
			if self.report.lostShip.defenderTotal.o then
				defTotal=FormatItem(self.report.lostShip.defenderTotal,false)
			else
				defTotal=self.report.lostShip.defenderTotal
			end
		end
		self.troops={attTotal,attLost,defTotal,defLost}
	end
	
	return self.troops
end

--根据战报的类型来初始化报告详情的显示类型
--showType：1.资源，2.繁荣度，3.部队损耗，4.装甲矩阵，5.配件，6.将领，7.超级武器，8.军徽，9.飞机，10.攻打叛军时的战斗信息,11.AI部队
function battleReportDialog:initShowType()
	self.baseShowType={1} --默认有奖励
	if self.report.islandType==7 then --攻打叛军
		local rebelData=self.report.rebel or {}
		local multiNum=rebelData.multiNum or 0
		local attNum=rebelData.attNum or 0
		if (attNum and attNum>0) or (multiNum and multiNum>1) then
			table.insert(self.baseShowType,10) --攻打叛军时的战斗信息
		end
	end
	if base.isGlory==1 and self.report.report and self.report.report.bm and SizeOfTable(self.report.report.bm)>0 then
		table.insert(self.baseShowType,2) --繁荣度
	end
	table.insert(self.baseShowType,3) --部队损耗

	if (self.report.islandType<6 and (self.report.islandOwner==nil or self.report.islandOwner==0)) or self.report.islandType==7 or self.report.islandType==9 then --如果攻打矿点但该矿点没有玩家占领或者攻打的是叛军的话，没有战斗实力对比
		do return end
	end
	self.detailShowType={}
	local armorMatrixFlag=emailVoApi:isShowArmorMatrix(self.report)
	if armorMatrixFlag==true then
		table.insert(self.detailShowType,4) --装甲矩阵
	end
	local accessoryFlag=emailVoApi:isShowAccessory(self.report)
	if accessoryFlag==true then
		table.insert(self.detailShowType,5) --配件
	end
	local heroFlag=emailVoApi:isShowHero(self.report)
	if heroFlag==true then
		table.insert(self.detailShowType,6) --将领
	end
	local superWeaponFlag=emailVoApi:isShowSuperWeapon(self.report)
	if superWeaponFlag==true then
		table.insert(self.detailShowType,7) --超级武器
	end
	local aiFlag=G_isShowAITroopsInReport(self.report) --AI部队
	if aiFlag==true then
		table.insert(self.detailShowType,11)
	end
	local emblemFlag=emailVoApi:isShowEmblem(self.report)
	if emblemFlag==true then
		table.insert(self.detailShowType,8) --军徽
	end
	local planeFlag=G_isShowPlaneInReport(self.report)
	if planeFlag==true then
		table.insert(self.detailShowType,9) --飞机
	end
	if airShipVoApi:isShowAirshipInReport(self.report) == true then --飞艇
        table.insert(self.detailShowType,12)
    end
end

function battleReportDialog:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.tvWidth=nil
	self.tvHeight=nil
	self.isMoved=nil
	self.report=nil
	self.layerNum=nil
	self.baseShowType=nil
	self.detailShowType=nil
	self.cellHeightTb1=nil
	self.cellHeightTb2=nil
	self.baseLayer=nil
	self.detailLayer=nil
	self.tvTb=nil
	self.baseNum=nil
	self.detailNum=nil
	self.resource=nil
	self.troops=nil
    spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
	if self.islandType==8 then
		spriteController:addPlist("scene/allianceCityImages.plist")
		spriteController:addTexture("scene/allianceCityImages.png")
	end
	self.isAttacker=nil
	self.islandType=nil
	self.chatSender=nil
end

return battleReportDialog