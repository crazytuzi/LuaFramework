warStatueDetailDialog=smallDialog:new()

function warStatueDetailDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function warStatueDetailDialog:showWarStatueDetailDialog(sid,layerNum,callback)
	local dialog=warStatueDetailDialog:new()
	dialog:initWarStatueDetailDialog(sid,layerNum,callback)
	return dialog
end

function warStatueDetailDialog:initWarStatueDetailDialog(sid,layerNum,callback)
	self.isTouch=false
    self.isUseAmi=true
    self.layerNum=layerNum
    self.sid=sid
	self.buffTb={}
	for i=1,statueCfg.openStatue do
		local buffKey,buffValue=warStatueVoApi:getWarStatueBuff(self.sid,i)
		self.buffTb[i]={buffKey,buffValue}
	end

    local function refresh(event,data)
    	if data and data.hid then
	    	self:refreshHero(data.hid)
    		self:refreshButton()

    		local rfdata={sid=self.sid,rf=false}
          	eventDispatcher:dispatchEvent("warstatue.refresh",rfdata)
    	end
    end
    self.refreshListener=refresh
    eventDispatcher:addEventListener("hero.breakthrough",refresh)

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/warStatue/warStatue_images2.plist")
    spriteController:addTexture("public/warStatue/warStatue_images2.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/warStatue/warStatue_frame1.plist")
    spriteController:addTexture("public/warStatue/warStatue_frame1.png")
    spriteController:addPlist("public/warStatue/warStatue_frame2.plist")
    spriteController:addTexture("public/warStatue/warStatue_frame2.png")

    local function close()
    	self:close()
    end
    self.bgSize=CCSizeMake(612,840)
    local statueNameStr=getlocal("warStatue_name_"..sid)
    local dialogBg=G_getNewDialogBg(self.bgSize,statueNameStr,30,nil,self.layerNum,true,close)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)

	local function nilFunc()
	end
	local  skillTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),nilFunc)
	skillTitleBg:setAnchorPoint(ccp(0,1))
	skillTitleBg:setPosition(10,self.bgSize.height-70)
	skillTitleBg:setContentSize(CCSizeMake(self.bgSize.width-100,32))
	self.bgLayer:addChild(skillTitleBg)
	local titleLb=GetTTFLabel(getlocal("skillAddStr"),28)
	titleLb:setAnchorPoint(ccp(0,0.5))
	titleLb:setPosition(10,skillTitleBg:getContentSize().height/2)
	skillTitleBg:addChild(titleLb)

   	local heroShowBg=LuaCCScale9Sprite:createWithSpriteFrameName("heroShowBg.png",CCRect(0,0,9,61),function () end)
    heroShowBg:setContentSize(CCSizeMake(586,61))
    heroShowBg:setPosition(self.bgSize.width/2,self.bgSize.height-200)
    self.bgLayer:addChild(heroShowBg)
    self.heroShowBg=heroShowBg          

	self.buffStateInfoTb={}
	local buffLvLimit,iconWidth,spaceW=statueCfg.openStatue,70,50
	local firstPosX=74
	local buffLv=warStatueVoApi:getWarStatueBuffLv(sid)
	for i=1,buffLvLimit do
		local unlockFlag=false
		if buffLv>=i then
			unlockFlag=true
		end
		local iconPosX=firstPosX+(i-1)*110
		local tag=100+i
		local iconBaseSp,iconSp
		if unlockFlag==true then
			iconBaseSp=CCSprite:createWithSpriteFrameName("warStatueBuffLv"..i..".png")
			iconSp=CCSprite:createWithSpriteFrameName("warStatueHero.png")
			tag=1000+i
		else
			iconBaseSp=GraySprite:createWithSpriteFrameName("warStatueBuffLv"..i..".png")
			iconSp=GraySprite:createWithSpriteFrameName("warStatueHero.png")
		end
		iconBaseSp:setPosition(iconPosX,40)
		heroShowBg:addChild(iconBaseSp,2)
		iconSp:setPosition(iconPosX,iconBaseSp:getPositionY()-iconBaseSp:getContentSize().height*0.5+iconSp:getContentSize().height*0.5)
		iconSp:setTag(tag)
		heroShowBg:addChild(iconSp,3)

		local touchIconSp
		local function touchHandler()
	        if G_checkClickEnable()==false then
	            do
	                return
	            end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
	        end
	        local function touchCallBack()
				if self.selectSp and touchIconSp then
					self.selectSp:setPosition(touchIconSp:getPositionX(),self.selectSp:getPositionY())
				end
				self:refreshBuffInfo(i)
	        end
        	local iconBaseSp,iconSp=self.buffStateInfoTb[i][3],self.buffStateInfoTb[i][4]
        	if iconBaseSp and iconSp then
        		G_touchedItem(iconBaseSp)
        		G_touchedItem(iconSp,touchCallBack)
        	end
		end
		touchIconSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchHandler)
		touchIconSp:setContentSize(CCSizeMake(iconSp:getContentSize().width+30,iconSp:getContentSize().height))
		touchIconSp:setPosition(iconSp:getPosition())
		touchIconSp:setOpacity(0)
		touchIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
		heroShowBg:addChild(touchIconSp,3)

		local stateStr,color=getlocal("ineffectiveStr"),G_ColorRed
		if buffLv>=i then
			stateStr,color=getlocal("takeEffectStr"),G_ColorGreen
		end

       	local buffStateLb=GetTTFLabelWrap(stateStr,18,CCSizeMake(iconWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      	local tmpLb=GetTTFLabel(stateStr,18)
      	local realW=tmpLb:getContentSize().width
      	if realW>buffStateLb:getContentSize().width then
      		realW=buffStateLb:getContentSize().width
      	end
	    local buffStateBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
	    buffStateBg:setContentSize(CCSizeMake(realW+6,buffStateLb:getContentSize().height+6))
	    buffStateBg:setOpacity(150)
	    buffStateBg:setPosition(touchIconSp:getPositionX(),touchIconSp:getPositionY()+6)
	    heroShowBg:addChild(buffStateBg,5)
        buffStateLb:setPosition(getCenterPoint(buffStateBg))
        buffStateLb:setColor(color)
        buffStateBg:addChild(buffStateLb)
        self.buffStateInfoTb[i]={buffStateLb,buffStateBg,iconBaseSp,iconSp,touchIconSp}

        if (buffLv>0 and i==buffLv) or (buffLv==0 and i==1)  then
	    	self.selectSp=CCSprite:createWithSpriteFrameName("statueHeroSelectPic.png")
			self.selectSp:setPosition(touchIconSp:getPositionX(),touchIconSp:getPositionY()+20)
			heroShowBg:addChild(self.selectSp)
        end

        if i~=buffLvLimit then
	     	local arrowSp=CCSprite:createWithSpriteFrameName("buffUpgradeArrow.png")
	     	arrowSp:setAnchorPoint(ccp(0,0.5))
			arrowSp:setPosition(iconPosX+iconBaseSp:getContentSize().width*0.5,iconBaseSp:getPositionY())
			heroShowBg:addChild(arrowSp)
        end
	end

	local kuangWidth,kuangHeight=576,286
	local detailPanel=G_getThreePointBg(CCSizeMake(kuangWidth,kuangHeight),function () end,ccp(0.5,1),ccp(self.bgSize.width/2,self.bgSize.height-230),self.bgLayer)
	local titleBg,detailLb=G_createNewTitle({getlocal("skill_detail_title"),24},CCSizeMake(kuangWidth-140,0))
	titleBg:setPosition(kuangWidth/2,kuangHeight-40)
	detailPanel:addChild(titleBg)

	local effectLb=GetTTFLabelWrap(getlocal("buffEffectStr"),22,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	effectLb:setAnchorPoint(ccp(0,0.5))
    effectLb:setPosition(20,kuangHeight-70-effectLb:getContentSize().height*0.5)
    detailPanel:addChild(effectLb)

    local buffDescStr=warStatueVoApi:getBuffDesc(self.buffTb[1][1],self.buffTb[1][2])
    local skillDescLb=GetTTFLabelWrap(buffDescStr,20,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	skillDescLb:setAnchorPoint(ccp(0,0.5))
    skillDescLb:setPosition(20,effectLb:getPositionY()-effectLb:getContentSize().height*0.5-skillDescLb:getContentSize().height*0.5-10)
    detailPanel:addChild(skillDescLb)
    self.skillDescLb=skillDescLb

	local conditionLb=GetTTFLabelWrap(getlocal("buffEffectiveCondition"),22,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
	conditionLb:setAnchorPoint(ccp(0,0.5))
    conditionLb:setPosition(20,kuangHeight-180-conditionLb:getContentSize().height*0.5)
    detailPanel:addChild(conditionLb)

    local effectConditionLb=GetTTFLabelWrap(getlocal("buffEffectiveCondition2",{statueCfg.openStatue,1}),20,CCSizeMake(kuangWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	effectConditionLb:setAnchorPoint(ccp(0,0.5))
    effectConditionLb:setPosition(20,conditionLb:getPositionY()-conditionLb:getContentSize().height*0.5-effectConditionLb:getContentSize().height*0.5-10)
    detailPanel:addChild(effectConditionLb)
    self.effectConditionLb=effectConditionLb

    if buffLv<=1 then
    	self:refreshBuffInfo(1)
    else
    	self:refreshBuffInfo(buffLv)
    end

	local  heroTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,16,1,1),nilFunc)
	heroTitleBg:setAnchorPoint(ccp(0,1))
	heroTitleBg:setPosition(10,detailPanel:getPositionY()-kuangHeight-20)
	heroTitleBg:setContentSize(CCSizeMake(self.bgSize.width-100,32))
	self.bgLayer:addChild(heroTitleBg)
	local titleLb2=GetTTFLabel(getlocal("heroAddStr"),28)
	titleLb2:setAnchorPoint(ccp(0,0.5))
	titleLb2:setPosition(10,heroTitleBg:getContentSize().height/2)
	heroTitleBg:addChild(titleLb2)

	self.heroInfoTb={}
	local heroList=statueCfg.room[sid][2]
	local heroCount=SizeOfTable(heroList)
	firstPosX=(self.bgSize.width-heroCount*iconWidth-(heroCount-1)*spaceW)*0.5

	for i=1,heroCount do
		local hid=heroList[i]
		local flag,activeLv=warStatueVoApi:getHeroActiveState(sid,hid)

		local function touchHero()
			self:touchHero(hid)
		end
		local heroSp=heroVoApi:getHeroIcon(hid,activeLv,true,touchHero)
		heroSp:setPosition(firstPosX+(2*i-1)*iconWidth*0.5+(i-1)*spaceW,heroTitleBg:getPositionY()-heroTitleBg:getContentSize().height-iconWidth*0.5-20)
		heroSp:setScale(iconWidth/heroSp:getContentSize().width)
		heroSp:setTouchPriority(-(self.layerNum-1)*20-4)
		heroSp:setTag(100+(activeLv or 0))
		self.bgLayer:addChild(heroSp)

		local heroStateBg,heroStateLb=nil,nil
		local stateStr,color=getlocal("inownStr"),G_ColorRed
		if flag==1 then
			stateStr,color=getlocal("activate_ableStr"),G_ColorGreen
		end
		if activeLv==nil or activeLv<statueCfg.openStatue then
	      	heroStateLb=GetTTFLabelWrap(stateStr,18,CCSizeMake(iconWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	      	local tmpLb=GetTTFLabel(stateStr,18)
	      	local realW=tmpLb:getContentSize().width
	      	if realW>heroStateLb:getContentSize().width then
	      		realW=heroStateLb:getContentSize().width
	      	end
		    heroStateBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function () end)
		    heroStateBg:setContentSize(CCSizeMake(realW+6,heroStateLb:getContentSize().height+6))
		    heroStateBg:setOpacity(150)
		    heroStateBg:setPosition(heroSp:getPosition())
		    self.bgLayer:addChild(heroStateBg,2)

	        heroStateLb:setPosition(getCenterPoint(heroStateBg))
	        heroStateLb:setColor(color)
	        heroStateBg:addChild(heroStateLb)
           	if flag==2 then
	        	heroStateBg:setVisible(false)
	        end
		end
        local color=heroVoApi:getHeroColor(activeLv)
        local nameStr=heroVoApi:getHeroName(hid)
     	local nameLb=GetTTFLabelWrap(nameStr,18,CCSizeMake(iconWidth+30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
     	nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(heroSp:getPositionX(),heroSp:getPositionY()-heroSp:getContentSize().height*heroSp:getScale()/2-20)
        nameLb:setColor(color)
        self.bgLayer:addChild(nameLb)
		self.heroInfoTb[hid]={heroSp,nameLb,heroStateBg,heroStateLb}
	end

	local priority=-(self.layerNum-1)*20-4
    local function activateAll() --一键激活
		local function activateHandler(lastVo,vo,oldfc,newfc)
			if self.activateBtn then
				self.activateBtn:setEnabled(false)
			end
			local function playEnd()
				local function refresh()
					self:refreshDetail()
					if(oldfc and newfc)then --战斗力发生变化
						if tonumber(oldfc)~=tonumber(newfc) then
							playerVoApi:setPlayerPower(tonumber(newfc))
		                	G_showNumberChange(oldfc,newfc)
						end
		            end
				end
				warStatueVoApi:showUpgradeBuffDialog(lastVo,vo,self.layerNum+1,refresh)
			end
			G_playBoomAction(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-120),playEnd,0.5)
		end
		warStatueVoApi:activateHero(2,self.sid,nil,activateHandler)
    end
	self.activateBtn=G_createBotton(self.bgLayer,ccp(self.bgSize.width/2,60),{getlocal("activate_once")},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",activateAll,1,priority)
	self:refreshButton()

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function warStatueDetailDialog:touchHero(hid)
    if G_checkClickEnable()==false then
        do
            return
        end
    else
        base.setWaitTime=G_getCurDeviceMillTime()
    end
	local flag,activeLv=warStatueVoApi:getHeroActiveState(self.sid,hid)
	if flag==1 then --激活处理
		local function activateHandler(lastVo,vo,oldfc,newfc)
			self:refreshButton()
			local function playEnd()
				local function refresh()
					self:refreshDetail(hid)
					if(oldfc and newfc)then --战斗力发生变化
						if tonumber(oldfc)~=tonumber(newfc) then
							playerVoApi:setPlayerPower(tonumber(newfc))
		                	G_showNumberChange(oldfc,newfc)
						end
		            end
				end
				warStatueVoApi:showUpgradeBuffDialog(lastVo,vo,self.layerNum+1,refresh)
			end
			G_playBoomAction(self.bgLayer,ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2-120),playEnd,0.5)
		end
		warStatueVoApi:activateHero(1,self.sid,hid,activateHandler)
	elseif flag==2 then --显示将领的buff详情
		warStatueVoApi:showHeroBuffDialog(self.sid,hid,self.layerNum+1)
	elseif flag==3 then --未拥有
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage11002"),28)
	end
end

function warStatueDetailDialog:refreshHero(hid)
	local heroInfo=self.heroInfoTb[hid]
	if heroInfo then
		local flag,activeLv=warStatueVoApi:getHeroActiveState(self.sid,hid)
		if flag==3 then --如果未拥有的话不需要刷新
			do return end
		end
		local stateStr,color=getlocal("inownStr"),G_ColorRed
		if flag==1 then
			stateStr,color=getlocal("activate_ableStr"),G_ColorGreen
		end
		local heroStateBg,heroStateLb=nil,nil
		if heroInfo[3] and heroInfo[4] then
	      	heroStateBg=tolua.cast(heroInfo[3],"LuaCCScale9Sprite")
	      	heroStateLb=tolua.cast(heroInfo[4],"CCLabelTTF")
		end
		if activeLv==nil or activeLv<statueCfg.openStatue then
	      	if heroStateLb and heroStateBg then
	      		heroStateBg:setVisible(true)
		        heroStateLb:setString(stateStr)
		        heroStateLb:setColor(color)
	         	if flag==2 then
		        	heroStateBg:setVisible(false)
		        end
	      	end
      	else
      		if heroStateBg and heroStateLb then
      			heroStateBg:removeFromParentAndCleanup(true)
      			self.heroInfoTb[hid][3]=nil
      			self.heroInfoTb[hid][4]=nil
      		end
		end

		local heroSp=tolua.cast(heroInfo[1],"CCSprite")
		local nameLb=tolua.cast(heroInfo[2],"CCLabelTTF")

		if heroSp then
			local lastActiveLv=heroSp:getTag()-100
			if activeLv and tonumber(activeLv)>tonumber(lastActiveLv) then --激活提升
				local function refresh()
					local px,py=heroSp:getPosition()
					local scale=heroSp:getScale()
					heroSp:removeFromParentAndCleanup(true)
					self.heroInfoTb[hid][1]=nil
					local function touchHero()
						self:touchHero(hid)
					end
					heroSp=heroVoApi:getHeroIcon(hid,activeLv,true,touchHero)
					heroSp:setPosition(px,py)
					heroSp:setTouchPriority(-(self.layerNum-1)*20-4)
					heroSp:setTag(100+activeLv)
					heroSp:setScale(scale)
					self.bgLayer:addChild(heroSp)
					self.heroInfoTb[hid][1]=heroSp

					if nameLb then
				        local color=heroVoApi:getHeroColor(activeLv)
						nameLb:setColor(color)
					end
				end
				--播放将领激活提升的动画
				self:runActivateEffect(hid,refresh)
			end
		end
	end
end

function warStatueDetailDialog:refreshDetail(hid)
	if self.buffStateInfoTb==nil then
		do return end
	end
	local buffLv=warStatueVoApi:getWarStatueBuffLv(self.sid)
	for k,v in pairs(self.buffStateInfoTb) do
		local unlockFlag=false
		if buffLv>=k then
			unlockFlag=true
		end
		local stateLb=tolua.cast(v[1],"CCLabelTTF")
		local stateBg=tolua.cast(v[2],"LuaCCScale9Sprite")
		local iconBaseSp,iconSp=tolua.cast(v[3],"CCSprite"),tolua.cast(v[4],"CCSprite")
		local tag=iconSp:getTag()
		if tag<1000 and unlockFlag==true then
			stateBg:setVisible(false)
			local function refreshStatue()
				local x1,y1=iconBaseSp:getPosition()
				local x2,y2=iconSp:getPosition()
				iconBaseSp:removeFromParentAndCleanup(true)
				iconSp:removeFromParentAndCleanup(true)
				iconBaseSp=CCSprite:createWithSpriteFrameName("warStatueBuffLv"..k..".png")
				iconSp=CCSprite:createWithSpriteFrameName("warStatueHero.png")
				iconBaseSp:setPosition(x1,y1)
				iconSp:setPosition(x2,y2)
				self.heroShowBg:addChild(iconBaseSp,2)
				self.heroShowBg:addChild(iconSp,3)
				self.buffStateInfoTb[k][3]=iconBaseSp
				self.buffStateInfoTb[k][4]=iconSp
				iconSp:setTag(1000+k)

				local stateStr,color=getlocal("ineffectiveStr"),G_ColorRed
				if unlockFlag==true then
					stateStr,color=getlocal("takeEffectStr"),G_ColorGreen
				end
				if stateLb and stateBg then
					stateBg:setVisible(true)
					stateLb:setString(stateStr)
					stateLb:setColor(color)
				end
			end
			--播放解锁雕像的动画
			local x,y=iconSp:getPosition()
			local function playBoom()
				self:playFrame(self.heroShowBg,ccp(x+5,y+15),"statueBoom_",13,0.06,nil,refreshStatue)
			end
			self:playFrame(self.heroShowBg,ccp(x+5,y+15),"statuelie_",6,0.1,0.2,playBoom)

			--刷新成最高等级的buff
			self:refreshSelectBuffLv()
		end
	end
	if hid then
		self:refreshHero(hid)
	else
		for hid,v in pairs(self.heroInfoTb) do
			self:refreshHero(hid)
		end
	end
end

function warStatueDetailDialog:refreshBuffInfo(buffLv)
	if self.skillDescLb and self.effectConditionLb then
		local buffKey,buffValue=self.buffTb[buffLv][1],self.buffTb[buffLv][2]
		if buffKey and buffValue then
			local color1,color2=G_ColorYellowPro,G_ColorGreen
			local curLv=warStatueVoApi:getWarStatueBuffLv(self.sid)
			local conditionStr=getlocal("buffEffectiveCondition2",{buffLv})
			if curLv<buffLv then
				color1,color2=G_ColorGray,G_ColorRed
			end
    		local buffDescStr=warStatueVoApi:getBuffDesc(buffKey,buffValue)
    		self.skillDescLb:setString(buffDescStr)
    		self.skillDescLb:setColor(color1)
    		self.effectConditionLb:setString(conditionStr)
    		self.effectConditionLb:setColor(color2)
		end
	end
end

function warStatueDetailDialog:refreshSelectBuffLv()
	local buffLv=warStatueVoApi:getWarStatueBuffLv(self.sid)
	local info=self.buffStateInfoTb[buffLv]
	if info and info[5] then
		local touchIconSp=tolua.cast(info[5],"LuaCCScale9Sprite")
		if self.selectSp and touchIconSp then
			self.selectSp:setPosition(touchIconSp:getPositionX(),self.selectSp:getPositionY())
		end
		self:refreshBuffInfo(buffLv)
	end
end

function warStatueDetailDialog:refreshButton()
	if self.activateBtn==nil then
		do return end
	end
	local ableFlag=false
	local heroList=statueCfg.room[self.sid][2]
	for k,hid in pairs(heroList) do
		local flag,activeLv=warStatueVoApi:getHeroActiveState(self.sid,hid)
		if flag==1 then
			ableFlag=true
			do break end
		end
	end
	self.activateBtn:setEnabled(ableFlag)
end

function warStatueDetailDialog:playFrame(target,pos,frameName,fc,ft,dt,callback)
	if target==nil then
		do return end
	end
	local frameSp=CCSprite:createWithSpriteFrameName(frameName.."1.png")
  	local lieArr=CCArray:create()
	for kk=1,fc do
	    local nameStr=frameName..kk..".png"
	    local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	    lieArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(lieArr)
	animation:setDelayPerUnit(ft)
	local animate=CCAnimate:create(animation)
	frameSp:setAnchorPoint(ccp(0.5,0.5))
	frameSp:setPosition(pos)
	target:addChild(frameSp,5)
	local acArr=CCArray:create()
	acArr:addObject(animate)
	if dt then
		local delay=CCDelayTime:create(dt)
		acArr:addObject(delay)
	end
	local function playEnd()
		frameSp:removeFromParentAndCleanup(true)
		frameSp=nil
		if callback then
			callback()
		end
	end
	local func=CCCallFunc:create(playEnd)
	acArr:addObject(func)
	local seq=CCSequence:create(acArr)
	frameSp:runAction(seq)
end

function warStatueDetailDialog:runActivateEffect(hid,callback)
	local hinfo=self.heroInfoTb[hid]
	if hinfo==nil or hinfo[1]==nil then
		do return end
	end
	local heroSp=tolua.cast(hinfo[1],"CCSprite")
	if heroSp then
	    local iconSize=heroSp:getContentSize()
	    local equipLine1=CCParticleSystemQuad:create("public/hero/equipLine.plist")
	    equipLine1:setScale(1.5)
	    equipLine1:setPosition(ccp(iconSize.width/2,10))
	    heroSp:addChild(equipLine1,3)
	    local function removeLine1()
	        if equipLine1 then
	            equipLine1:stopAllActions()
	            equipLine1:removeFromParentAndCleanup(true)
	            equipLine1=nil
	            self.isPlaying=false
	            if callback then
	                callback()
	            end
	        end
	    end
	    local mvTo1=CCMoveTo:create(0.5,ccp(iconSize.width/2,iconSize.height))
	    local fc1=CCCallFunc:create(removeLine1)
	    local carray1=CCArray:create()
	    carray1:addObject(mvTo1)
	    carray1:addObject(fc1)
	    local seq1=CCSequence:create(carray1)
	    equipLine1:runAction(seq1)


	    local equipStar1=CCParticleSystemQuad:create("public/hero/equipStar.plist")
	    equipStar1:setScale(1.5)
	    equipStar1:setPosition(ccp(iconSize.width/2,10))
	    heroSp:addChild(equipStar1,3)
	    equipStar1:setAutoRemoveOnFinish(true) 

	    local function removeLine2()
	        if equipStar1 then
	            equipStar1:stopAllActions()
	            equipStar1:removeFromParentAndCleanup(true)
	            equipStar1=nil
	        end
	        if callback then
	        	callback()
	        end
	    end
	    local mvTo2=CCMoveTo:create(0.65,ccp(iconSize.width/2,iconSize.height))
	    local fc2=CCCallFunc:create(removeLine2)
	    local carray2=CCArray:create()
	    carray2:addObject(mvTo2)
	    carray2:addObject(fc2)
	    local seq2=CCSequence:create(carray2)
	    equipStar1:runAction(seq2)
	end
end

function warStatueDetailDialog:dispose()
	self.heroInfoTb=nil
	self.buffStateInfoTb=nil
	self.buffTb=nil
	self.heroShowBg=nil
    if self.refreshListener then
        eventDispatcher:removeEventListener("hero.breakthrough",self.refreshListener)
        self.refreshListener=nil
    end
    spriteController:removePlist("public/warStatue/warStatue_images2.plist")
    spriteController:removeTexture("public/warStatue/warStatue_images2.png")
    spriteController:removePlist("public/warStatue/warStatue_frame1.plist")
    spriteController:removeTexture("public/warStatue/warStatue_frame1.png")
    spriteController:removePlist("public/warStatue/warStatue_frame2.plist")
    spriteController:removeTexture("public/warStatue/warStatue_frame2.png")
end